// ********************************************************************/
// Actel Corporation Proprietary and Confidential
//  Copyright 2011 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description:  fwft.v
//
//
// Revision Information:
// Date     Description
//
// SVN Revision Information:
// SVN $Revision: 46744 $
// SVN $Date: 2024-06-13 11:11:34 +0530 (Thu, 13 Jun 2024) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ********************************************************************/

`timescale 1ns / 1ns

module caxi4c_corefifo_fwft (
                        wr_clk,
                        rd_clk,
                        clk,
                        //reset_rclk_top,
						//reset_wclk_top,
						aresetn_wclk,
						aresetn_rclk,
						sresetn_wclk,
						sresetn_rclk,
                        empty,
                        aempty,
                        rd_en,
                        fifo_rd_en,
                        fifo_empty,
                        fifo_aempty,
                        fifo_dout,
                        wr_en,
                        din,
                        fwft_dvld,
                        reg_valid,
                        dout,
                        fifo_MEMRADDR,
                        fwft_MEMRADDR
                        );

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
   parameter                ECC             = 0;   // ECC | 0 - ECC Disable, 1 - Pipelined ECC, 2 - Non-pipelined ECC
   parameter                PIPE            = 2;   // Pipeline read data out
   parameter                RWIDTH          = 32;  
   parameter                RDEPTH          = 64;
   parameter                WWIDTH          = 64;
   parameter                WCLK_HIGH       = 1;
   parameter                RCLK_HIGH       = 1;
   parameter                RESET_LOW       = 1;
   parameter                WRITE_LOW       = 1;
   parameter                READ_LOW        = 0;
   parameter                PREFETCH        = 0;
   parameter                FWFT            = 1;
   parameter                SYNC            = 0;
   parameter                SYNC_RESET      = 1;//uncommented in v3.0

   localparam RDEPTH_CAL      = (RDEPTH == 0) ? RDEPTH  : (RDEPTH-1);

   // --------------------------------------------------------------------------
   // I/O Declaration
   // --------------------------------------------------------------------------

   //--------
   // Inputs
   //--------

   // Clocks and Reset
   input                  wr_clk;
   input                  rd_clk;
   input                  clk;
   //input                  reset_rclk_top;
   //input                  reset_wclk_top;
   input                  wr_en;
   input                  rd_en;
   output                 fifo_rd_en;
   input [RWIDTH-1 : 0]   fifo_dout;
   input                  fifo_empty;
   input                  fifo_aempty;
   input [WWIDTH - 1 : 0] din;
   input [RDEPTH_CAL : 0] fifo_MEMRADDR;

   input				  aresetn_rclk; //added in v3.0
   input				  aresetn_wclk;//added in v3.0
   input				  sresetn_rclk;//added in v3.0
   input				  sresetn_wclk;//added in v3.0
   //---------
   // Outputs
   //---------
   output                  empty;
   output                  aempty;
   output [RWIDTH-1 : 0]   dout;
   output                  fwft_dvld;
   output                  reg_valid;
   output [RDEPTH_CAL : 0] fwft_MEMRADDR;

  // --------------------------------------------------------------------------
   // Internal signals
   // --------------------------------------------------------------------------
   reg                     fifo_valid, dout_valid, middle_valid;

   wire [RWIDTH - 1 : 0]   fifo_dout;
   wire                    fifo_rd_en, fifo_empty;
   wire                    update_dout, update_middle;

   wire [RDEPTH_CAL : 0]   fwft_MEMRADDR;
  //reg [RDEPTH_CAL : 0]   fwft_MEMRADDR;

   reg                     fifo_empty_r;
   wire                    fwft_dvld;
   reg                     wr_p_r;
   reg                     reg_valid;
   wire                    we_p;
   reg                     we_p_r;
   wire                    re_p;
   reg                     re_p_d;
   wire                    pos_rclk;
   wire                    pos_wclk;

   reg                     empty_r;
   reg                     reg_valid_r;
   wire                    empty1;
   reg                     empty;
   reg                     update_dout_r;

   wire                    fifo_empty_pulse;
   reg                     fifo_empty_pulse_d;
   wire                    fifo_init_pulse;

   wire reset_wclk;
   wire reset_rclk;
   

   reg    [RWIDTH-1:0]  dout /*synthesis syn_preserve = 1*/;
   reg                       middle1_valid, middle2_valid, fifo_rd_en_d1, fifo_rd_en_r1;
   reg    [RWIDTH-1:0]  middle_dout, middle1_dout, middle2_dout; 


   // --------------------------------------------------------------------------
   // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   // ||                                                                      ||
   // ||                     Start - of - Code                                ||
   // ||                                                                      ||
   // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   // --------------------------------------------------------------------------

   // --------------------------------------------------------------------------
   // Clocks, resets and enables
   // --------------------------------------------------------------------------
   generate
      if(SYNC == 1) begin
         assign pos_rclk  = RCLK_HIGH ? clk  : ~clk;
         assign pos_wclk  = WCLK_HIGH ? clk  : ~clk;
      end
   endgenerate

   generate
      if(SYNC == 0) begin
         assign pos_rclk  = RCLK_HIGH ? rd_clk  : ~rd_clk;
         assign pos_wclk  = WCLK_HIGH ? wr_clk  : ~wr_clk;
      end
   endgenerate

   assign we_p  = WRITE_LOW ? (~wr_en) : (wr_en);
   assign re_p  = READ_LOW  ? (~rd_en) : (rd_en);



   // --------------------------------------------------------------------------
   // Generate addresses to the memory
   // --------------------------------------------------------------------------
   assign fwft_MEMRADDR = fifo_MEMRADDR ;

   // --------------------------------------------------------------------------
   // Generates the read enable to be given to the FIFO controller
   // fifo_rd_en: It is different from the top-level read enable
   // --------------------------------------------------------------------------
   //assign fifo_rd_en = fifo_init_pulse | re_p;

   // --------------------------------------------------------------------------
   // Generate empty/almost empty signal
   // --------------------------------------------------------------------------
   //assign empty   = !dout_valid | (!fifo_valid && !middle_valid && dout_valid & !update_dout & re_p);
   //assign empty   = fifo_empty_r; //!dout_valid ;  // change by mahesh
  // assign empty   = !dout_valid ;  // SAR no

   assign aempty  = fifo_aempty | empty;



   //assign reset_rclk  = reset_rclk_top;commented in v3.0
   //assign reset_wclk  = reset_wclk_top;commented in v3.0

   // --------------------------------------------------------------------------
   // Register empty signal
   // --------------------------------------------------------------------------
   always @(posedge pos_rclk or negedge aresetn_rclk) begin
      if(!aresetn_rclk | !sresetn_rclk) begin
         fifo_empty_r   <= 1'b0;
         //fifo_empty_r   <= fifo_empty;
         update_dout_r   <= 'h0;
      end
      else begin
         fifo_empty_r   <= fifo_empty;
         update_dout_r   <= update_dout;
      end
   end

   assign fifo_empty_pulse = fifo_empty_r & !fifo_empty;

   assign fifo_init_pulse = !fifo_empty_pulse_d & fifo_empty_pulse;

   //-----------------------------------------------------------------
   //  Register re_p signal
   //-----------------------------------------------------------------
    always @(posedge pos_rclk or negedge aresetn_rclk) begin
      if(!aresetn_rclk | !sresetn_rclk) begin
         re_p_d   <= 1'b0;
      end else begin
         re_p_d   <= re_p;
      end
    end

   //---------------------------------------------------------------------------
   // delayed empty pulse for the genration of fifo read enable
   //--------------------------------------------------------------------------
   always @(posedge pos_rclk or negedge aresetn_rclk) begin
      if(!aresetn_rclk  | !sresetn_rclk) begin
         fifo_empty_pulse_d   <= 1'b0;
      end
      else begin
          if (fifo_empty_pulse == 1'b1) begin
              fifo_empty_pulse_d   <= 1'b1;
          end else if (fifo_empty == 1'b0 && fifo_empty_r == 1'b0) begin
              fifo_empty_pulse_d   <= 1'b0;
          end else begin
              fifo_empty_pulse_d   <= fifo_empty_pulse_d;
          end
      end
   end

   // --------------------------------------------------------------------------
   // FWFT logic
   // --------------------------------------------------------------------------
   //assign dout = fifo_dout;

   //always @(posedge pos_rclk or negedge aresetn) begin
   //   if((!aresetn) || (!sresetn)) begin
   //       dout <= 'h0;
   //   end else begin
   //       dout <= fifo_dout;
   //   end
   //end

 
   // --------------------------------------------------------------------------
   // Generate the data valid signal
   // --------------------------------------------------------------------------
   generate
      if(FWFT == 1) begin
        // assign fwft_dvld = reg_valid | (re_p & !empty_r); SAR
           assign  fwft_dvld = dout_valid;
         //assign fwft_dvld = (re_p & !empty_r);
         //assign fwft_dvld = reg_valid | re_p;
      end
   endgenerate

   generate
      if(PREFETCH == 1) begin
        // assign fwft_dvld = (re_p) & !empty_r; SAR no
         assign  fwft_dvld = (re_p) & dout_valid; 	// SAR no
      end
   endgenerate

   // --------------------------------------------------------------------------
   // Generate the qualifying signal to sample the read data. It is also used
   // to generate the read data valid signal
   // --------------------------------------------------------------------------
   always @(*) begin
      if(re_p == 1'b1) begin
         reg_valid  = 1'b0;
      end
      else if(empty == 1'b0 && empty_r == 1'b1) begin
         reg_valid  = 1'b1;
      end
      else begin
         reg_valid  = reg_valid_r;
      end
   end

   always @(posedge pos_rclk or negedge aresetn_rclk) begin
      if(!aresetn_rclk | !sresetn_rclk) begin
         empty_r   <= 1'b0;
         reg_valid_r   <= 1'b0;
      end
      else begin
         empty_r   <= empty;
         reg_valid_r   <= reg_valid;
      end
   end

   always @(posedge pos_wclk or negedge aresetn_wclk) begin
      if(!aresetn_wclk | !sresetn_wclk) begin
         we_p_r   <= 1'b0;
      end
      else begin
         we_p_r   <= we_p;
      end
   end
   
   
generate  
if  ((PIPE == 2)&&(ECC == 1)) begin : gen_axi4s_initr_cut_through_mode_pipelined_ecc
   //Used FWFT logic from CoreFIFO

   reg              fifo_rd_en_d1;
   reg              fifo_rd_en_d2;
   reg [2:0]        fifo_rdreq_cnt;
   reg [2:0]        fifo_valid_cnt;  
   reg              pipe_reg1_valid;
   reg              pipe_reg2_valid;
   reg              pipe_reg3_valid;
   reg              pipe_reg3_1_hold;
   reg              pipe_reg3_2_hold;
   reg [RWIDTH-1:0] pipe_reg1;
   reg [RWIDTH-1:0] pipe_reg2;
   reg [RWIDTH-1:0] pipe_reg3;
 
   // --------------------------------------------------------------------------
   // Generates the read enable to be given to the FIFO controller
   // fifo_rd_en: It is different from the top-level read enable
   // --------------------------------------------------------------------------
   assign fifo_rd_en = (~fifo_empty && ((fifo_rdreq_cnt != 4) || re_p));
   
   always @(posedge pos_rclk or negedge aresetn_rclk) begin
      if(!aresetn_rclk | !sresetn_rclk) begin
	    fifo_rdreq_cnt <= 0;
	  end else if(fifo_rd_en ^ (dout_valid & re_p)) begin 
	    if(fifo_rd_en)
		  fifo_rdreq_cnt <= fifo_rdreq_cnt + 1'b1;
		else 
		  fifo_rdreq_cnt <= fifo_rdreq_cnt - 1'b1;
	  end 
   end 
	    
   always @(posedge pos_rclk or negedge aresetn_rclk) begin
      if(!aresetn_rclk | !sresetn_rclk) begin
	    fifo_valid_cnt <= 0;
	  end else if(fifo_valid ^ (dout_valid & re_p)) begin 
	    if(fifo_valid)
		  fifo_valid_cnt <= fifo_valid_cnt + 1'b1;
		else 
		  fifo_valid_cnt <= fifo_valid_cnt - 1'b1;
	  end 
   end     

   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
	   fifo_rd_en_d1  <= 0;
	 else 
	   fifo_rd_en_d1  <= fifo_rd_en;
	   
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
	   fifo_rd_en_d2  <= 0;
	 else 
	   fifo_rd_en_d2  <= fifo_rd_en_d1;	   

   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       fifo_valid  <= 1'b0;
     else 
       fifo_valid  <= fifo_rd_en_d2;
	   
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg1_valid <= 1'b0;
     else if((fifo_valid_cnt == 1) && fifo_valid && ~re_p)
       pipe_reg1_valid  <= 1'b1;
     else if((fifo_valid_cnt == 2) && fifo_valid && (re_p || pipe_reg3_valid)) 
       pipe_reg1_valid  <= 1'b1;	
     else if((fifo_valid_cnt == 2) && ~pipe_reg3_valid && ~pipe_reg2_valid && ~re_p) 
       pipe_reg1_valid  <= 1'b1;	
	 else if((fifo_valid_cnt == 3) && fifo_valid && ((re_p && pipe_reg3_1_hold) || (pipe_reg2_valid && pipe_reg3_valid)))    
       pipe_reg1_valid  <= 1'b1;
	 else if (re_p) begin  
	   if(
           ((fifo_valid_cnt == 4) && ~pipe_reg3_1_hold) || 
		   ((fifo_valid_cnt == 3) && re_p && ~pipe_reg3_valid) ||
           (((fifo_valid_cnt == 2) || (fifo_valid_cnt == 1))) ||
		   (fifo_valid_cnt == 1)
	     ) 
         pipe_reg1_valid  <= 1'b0;   
     end 
	 
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg2_valid  <= 1'b0;
     else if((fifo_valid_cnt == 2) && fifo_valid && ~re_p && ~pipe_reg3_valid) 
       pipe_reg2_valid  <= 1'b1;
     //else if((fifo_valid_cnt == 3) && fifo_valid && (~re_p || (pipe_reg3_valid && pipe_reg1_valid && ~pipe_reg3_1_hold))) 
	 else if((fifo_valid_cnt == 3) && fifo_valid && (~re_p || pipe_reg3_2_hold) && ((pipe_reg1_valid && pipe_reg3_valid)))    
       pipe_reg2_valid  <= 1'b1;	   
     else if (
	       ((fifo_valid_cnt == 4) && ~(pipe_reg1_valid && ~pipe_reg3_1_hold) && ~pipe_reg3_2_hold && re_p) ||
	       ((fifo_valid_cnt == 3) && re_p && ~(pipe_reg1_valid && ~pipe_reg3_valid)) ||
		   ((fifo_valid_cnt == 2) && fifo_valid && ~pipe_reg1_valid) ||
           (fifo_valid_cnt == 1)		   
	     )
         pipe_reg2_valid  <= 1'b0;
	 
	   
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg3_valid <= 1'b0;
     else if((fifo_valid_cnt == 3) && fifo_valid && (~re_p || (pipe_reg1_valid && pipe_reg2_valid))) 
       pipe_reg3_valid  <= 1'b1;
     else if((fifo_valid_cnt == 2) && fifo_valid && ~re_p && pipe_reg2_valid) 
       pipe_reg3_valid  <= 1'b1;	   
     else if (re_p) begin 
	   if(
	       ((fifo_valid_cnt == 4) && ~(pipe_reg1_valid && ~pipe_reg3_1_hold) && ~(pipe_reg2_valid && ~pipe_reg3_2_hold)) ||
	       ((fifo_valid_cnt == 2) && ~pipe_reg1_valid && ~pipe_reg2_valid) ||
           ((fifo_valid_cnt == 3) && ~pipe_reg2_valid) ||
		   (fifo_valid_cnt == 1)		   
	     )
         pipe_reg3_valid  <= 1'b0;
	 end   
	 
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg3_1_hold  <= 1'b0;
	 else if(~pipe_reg3_valid)
       pipe_reg3_1_hold  <= 1'b0;  
     else if(pipe_reg3_valid & ~pipe_reg1_valid)
       pipe_reg3_1_hold  <= 1'b1;

   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg3_2_hold  <= 1'b0;
	 else if(~pipe_reg3_valid)
       pipe_reg3_2_hold  <= 1'b0;  
     else if(pipe_reg3_valid & ~pipe_reg2_valid)
       pipe_reg3_2_hold  <= 1'b1;
	   
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg1  <= {RWIDTH{1'b0}};
     else if (fifo_valid && (fifo_valid_cnt == 1) && ~re_p ) 
       pipe_reg1 <= fifo_dout;
     else if((fifo_valid_cnt == 2) && fifo_valid && (re_p || pipe_reg3_valid)) 
       pipe_reg1 <= fifo_dout;
	 else if((fifo_valid_cnt == 2) && ~pipe_reg3_valid && ~pipe_reg2_valid && ~pipe_reg1_valid) 
	   pipe_reg1 <= fifo_dout;
     //else if((fifo_valid_cnt == 3) && fifo_valid && (~re_p | pipe_reg3_1_hold) && ((pipe_reg2_valid && pipe_reg3_valid)))    
	 else if((fifo_valid_cnt == 3) && fifo_valid && ~pipe_reg1_valid && ((re_p && pipe_reg3_1_hold) || (pipe_reg2_valid && pipe_reg3_valid)))    
       pipe_reg1 <= fifo_dout;	
	   
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg2  <= {RWIDTH{1'b0}};
	 else if(~pipe_reg2_valid) begin
       if((fifo_valid_cnt == 2) && fifo_valid && ~re_p && ~pipe_reg2_valid)  
	     pipe_reg2  <= fifo_dout;  
       //else if((fifo_valid_cnt == 3) && fifo_valid && (~re_p || (pipe_reg3_valid && pipe_reg1_valid)))  
	   else if((fifo_valid_cnt == 3) && fifo_valid && (~re_p || pipe_reg3_2_hold) && ((pipe_reg1_valid && pipe_reg3_valid)))    
         pipe_reg2  <= fifo_dout;  	  
	 end 
	 
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg3  <= {RWIDTH{1'b0}};  
	 else if(~pipe_reg3_valid) begin
       if((fifo_valid_cnt == 3) && fifo_valid && (~re_p || (pipe_reg1_valid && pipe_reg2_valid))) 
	     pipe_reg3  <= fifo_dout;  	   
	   else if((fifo_valid_cnt == 2) && fifo_valid && ~re_p && pipe_reg2_valid) 
	     pipe_reg3  <= fifo_dout;  	   
	 end  
	 
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       dout_valid   <= 1'b0;
     else if(fifo_valid & ~dout_valid) 
       dout_valid  <= 1'b1;
     else if((fifo_valid_cnt == 1) & re_p & ~fifo_valid) 
       dout_valid  <= 1'b0;
	   
   always @(posedge pos_rclk or negedge aresetn_rclk)
      if(!aresetn_rclk | !sresetn_rclk)
         dout <= {RWIDTH{1'b0}};
      else if(~dout_valid & fifo_valid) 
		 dout <= fifo_dout;
      else if (re_p)  		   
        case(fifo_valid_cnt)
		 4       : if(pipe_reg1_valid & ~pipe_reg3_1_hold)
		             dout <= pipe_reg1;
		           else if(pipe_reg2_valid & ~pipe_reg3_2_hold)
		             dout <= pipe_reg2;
				   else 
				     dout <= pipe_reg3;
         3       : if(pipe_reg1_valid & ~pipe_reg3_valid)
                     dout <= pipe_reg1;
                   else if(pipe_reg2_valid)
        	         dout <= pipe_reg2;
                   else 
                     dout <= pipe_reg3;				   
         2       : if(pipe_reg1_valid)  
        	         dout <= pipe_reg1;
        	       else if(pipe_reg2_valid)
        	         dout <= pipe_reg2;
				   else if(pipe_reg3_valid)
				     dout <= pipe_reg3;
				   else 
				     dout <= fifo_dout;
         1       : if(pipe_reg1_valid)
		             dout <= pipe_reg1;
		           else 
				     dout <= fifo_dout;
         default : dout <= fifo_dout;
        endcase
		
   always @(posedge pos_rclk or negedge aresetn_rclk) 
     if(!aresetn_rclk | !sresetn_rclk)
       empty   <= 1'b1;
     else if(fifo_valid & ~dout_valid)
       empty  <= 1'b0;
     else if((fifo_valid_cnt == 1) & re_p & ~fifo_valid)
       empty  <= 1'b1;
       
	   
 end 
  else if  ((PIPE == ECC) | (PIPE == 2 & ECC == 0)) begin : gen_axi4s_initr_cut_through_mode_pipelined_noecc
  
   reg [2:0]        fifo_rdreq_cnt;
   reg [2:0]        fifo_valid_cnt;  
   reg              pipe_reg1_valid;
   reg              pipe_reg2_valid;
   reg [RWIDTH-1:0] pipe_reg1;
   reg [RWIDTH-1:0] pipe_reg2;
 
   // --------------------------------------------------------------------------
   // Generates the read enable to be given to the FIFO controller
   // fifo_rd_en: It is different from the top-level read enable
   // --------------------------------------------------------------------------
   assign fifo_rd_en = (~fifo_empty && ((fifo_rdreq_cnt != 3) || re_p));
   
   always @(posedge pos_rclk or negedge aresetn_rclk) begin
      if(!aresetn_rclk | !sresetn_rclk) begin
	    fifo_rdreq_cnt <= 0;
	  end else if(fifo_rd_en ^ (dout_valid & re_p)) begin 
	    if(fifo_rd_en)
		  fifo_rdreq_cnt <= fifo_rdreq_cnt + 1'b1;
		else 
		  fifo_rdreq_cnt <= fifo_rdreq_cnt - 1'b1;
	  end 
   end 
	    
   always @(posedge pos_rclk or negedge aresetn_rclk) begin
      if(!aresetn_rclk | !sresetn_rclk) begin
	    fifo_valid_cnt <= 0;
	  end else if(fifo_valid ^ (dout_valid & re_p)) begin 
	    if(fifo_valid)
		  fifo_valid_cnt <= fifo_valid_cnt + 1'b1;
		else 
		  fifo_valid_cnt <= fifo_valid_cnt - 1'b1;
	  end 
   end     

   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
	   fifo_rd_en_d1  <= 0;
	 else 
	   fifo_rd_en_d1  <= fifo_rd_en;

   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       fifo_valid  <= 1'b0;
     else 
       fifo_valid  <= fifo_rd_en_d1;
	   
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg1_valid <= 1'b0;
     else if((fifo_valid_cnt == 1) && fifo_valid && ~re_p)
       pipe_reg1_valid  <= 1'b1;
     else if((fifo_valid_cnt == 2) && fifo_valid && (re_p | pipe_reg2_valid)) 
       pipe_reg1_valid  <= 1'b1;		 
     else if(~fifo_valid && pipe_reg2_valid && re_p && (fifo_valid_cnt == 3))  
       pipe_reg1_valid  <= 1'b1;
     else if(((fifo_valid_cnt == 2) || (fifo_valid_cnt == 3)) && re_p) 
       pipe_reg1_valid  <= 1'b0;
      
 
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg2_valid <= 1'b0;
     else if((fifo_valid_cnt == 2) && fifo_valid & ~re_p) 
       pipe_reg2_valid  <= 1'b1;
     else if(((fifo_valid_cnt == 2) && re_p && ~pipe_reg1_valid) || ((fifo_valid_cnt == 3) && re_p && ~pipe_reg1_valid)) 
       pipe_reg2_valid  <= 1'b0;
	   
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg1  <= {RWIDTH{1'b0}};
     else if (fifo_valid && (fifo_valid_cnt == 1) && ~re_p ) 
       pipe_reg1 <= fifo_dout;
     else if(fifo_valid && re_p && (fifo_valid_cnt == 2))
       pipe_reg1 <= fifo_dout;
     else if(~fifo_valid && pipe_reg2_valid && re_p && (fifo_valid_cnt == 3))
       pipe_reg1 <= fifo_dout;
	   
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       pipe_reg2  <= {RWIDTH{1'b0}};
     else if (fifo_valid && (fifo_valid_cnt == 2) && ~re_p && ~pipe_reg2_valid) 
	   pipe_reg2  <= fifo_dout;  
	   
   always @(posedge pos_rclk or negedge aresetn_rclk)
     if(!aresetn_rclk | !sresetn_rclk)
       dout_valid   <= 1'b0;
     else if(fifo_valid & ~dout_valid) 
       dout_valid  <= 1'b1;
     else if((fifo_valid_cnt == 1) & re_p & ~fifo_valid) 
       dout_valid  <= 1'b0;
	   
   always @(posedge pos_rclk or negedge aresetn_rclk)
      if(!aresetn_rclk | !sresetn_rclk)
         dout <= {RWIDTH{1'b0}};
      else if(~dout_valid & fifo_valid) 
		 dout <= fifo_dout;
      else if (re_p)  		   
        case(fifo_valid_cnt)
         3       : if(pipe_reg1_valid)
                     dout <= pipe_reg1;
                   else 
                     dout <= pipe_reg2;				 
         2       : if(pipe_reg1_valid)
		             dout <= pipe_reg1;
		           else if(~fifo_valid)
                     dout <= fifo_dout;        	         
        	       else 
        	         dout <= pipe_reg2;
         1       : dout <= fifo_dout;
         default : dout <= fifo_dout;
        endcase
		
   always @(posedge pos_rclk or negedge aresetn_rclk) 
     if(!aresetn_rclk | !sresetn_rclk)
       empty   <= 1'b1;
     else if(fifo_valid & ~dout_valid)
       empty  <= 1'b0;
     else if((fifo_valid_cnt == 1) & re_p & ~fifo_valid)
       empty  <= 1'b1;
       
 end
 else if  ((PIPE == 1) && (ECC != 1)) begin : gen_axi4s_initr_cut_through_mode_nonpipelined
   //Used FWFT logic from CoreFIFO

   assign update_middle = fifo_valid & (middle_valid == update_dout);
   assign update_dout   = (fifo_valid || middle_valid) && (re_p || !dout_valid);

   // --------------------------------------------------------------------------
   // Generates the read enable to be given to the FIFO controller
   // fifo_rd_en: It is different from the top-level read enable
   // --------------------------------------------------------------------------
   assign fifo_rd_en = !(fifo_empty) && !(middle_valid && dout_valid && fifo_valid);

   always @(posedge pos_rclk or negedge aresetn_rclk) begin
      if(!aresetn_rclk | !sresetn_rclk) begin
         fifo_valid   <= 1'b0;
         middle_valid <= 1'b0;
         dout_valid   <= 1'b0;
         dout         <= 0;
         middle_dout  <= 0;
      end
      else begin
         if(update_middle) begin
            middle_dout  <= fifo_dout;
         end
         if(update_dout) begin
            dout  <= middle_valid ? middle_dout : fifo_dout;
         end

         if(fifo_rd_en) begin
            fifo_valid  <= 1'b1;
         end
         else if(update_middle || update_dout) begin
            fifo_valid  <= 1'b0;
         end

         if(update_middle) begin
            middle_valid  <= 1'b1;
         end
         else if(update_dout) begin
            middle_valid  <= 1'b0;
         end

         if(update_dout) begin
            dout_valid  <= 1'b1;
         end
         else if(re_p) begin
            dout_valid  <= 1'b0;
         end

      end
   end
   
   always @(posedge pos_rclk or negedge aresetn_rclk) 
     if(!aresetn_rclk | !sresetn_rclk)
       empty  <= 1'b1;
     else if(update_dout)
       empty  <= 1'b0;
     else if(re_p)
       empty  <= 1'b1;
   
end
endgenerate   

endmodule // corefifo_fwft

   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------

