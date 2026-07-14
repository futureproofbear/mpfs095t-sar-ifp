// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 43990 $
// SVN $Date: 2023-09-04 14:03:37 +0530 (Mon, 04 Sep 2023) $
//
// IP Core : CoreAXI4SInterconnect
//
// Module  : COREFIFO_AXI4S_INITIATOR_IF
//
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP.
// Notes    :
// ******************************************************************************************************/


`timescale 1ns / 1ns

module caxi4c_axi4s_initiator_if
   (
      M_AXIS_ACLK_i,
      M_AXIS_ARESETN_i,
      //Initiator Port Interface Signals
      M_AXIS_TVALID_o,
      M_AXIS_TREADY_i,
      M_AXIS_TDATA_o,

      FIFO_RD_DATA_AXIS_i,
      FIFO_RD_EN_AXIS_o,
      FIFO_EMPTY_i
   );

      parameter                           RESET_TYPE    = 0;
      parameter                           NUM_STAGES    = 2;
      parameter                           READ_MODE     = 1;
      parameter                           PIPE          = 1;
      parameter                           ECC           = 0;

      parameter                           TTDATA_WIDTH   = 512;
      parameter                           TTID_WIDTH     = 32;
      parameter                           TTDEST_WIDTH   = 32;
      parameter                           TTUSER_WIDTH   = 4096;

      parameter                           ITDATA_WIDTH   = 512;
      parameter                           ITID_WIDTH     = 32;
      parameter                           ITDEST_WIDTH   = 32;
      parameter                           ITUSER_WIDTH   = 4096;

      parameter                           WIDTH_CORE   = 9281;

      parameter                           ENABLE_TSTRB     = 0;
      parameter                           ENABLE_TKEEP     = 0;
      parameter                           ENABLE_TLAST     = 0;
      parameter                           ENABLE_TUSER     = 0;
      parameter                           ENABLE_TDEST     = 0;
      parameter                           ENABLE_TID       = 0;  

      input                               M_AXIS_ACLK_i;
      input                               M_AXIS_ARESETN_i;
      //Initiator Port Interface Signals
      output                              M_AXIS_TVALID_o;
      input                               M_AXIS_TREADY_i;
      output [ITDATA_WIDTH-1:0]           M_AXIS_TDATA_o;

      input  [WIDTH_CORE-1:0]             FIFO_RD_DATA_AXIS_i;
      input                               FIFO_EMPTY_i;
      output                              FIFO_RD_EN_AXIS_o;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////

   localparam TTSTRB_OFFSET  = TTDATA_WIDTH;
   localparam TTKEEP_OFFSET  = TTSTRB_OFFSET  + (ENABLE_TSTRB ? (TTDATA_WIDTH/8)  : 0);
   localparam TTLAST_OFFSET  = TTKEEP_OFFSET  + (ENABLE_TKEEP ? (TTDATA_WIDTH/8)  : 0);
   localparam TTID_OFFSET    = TTLAST_OFFSET  + (ENABLE_TLAST ? 1                 : 0);
   localparam TTDEST_OFFSET  = TTID_OFFSET    + (ENABLE_TID   ? TTID_WIDTH        : 0);
   localparam TTUSER_OFFSET  = TTDEST_OFFSET  + (ENABLE_TDEST ? TTDEST_WIDTH      : 0);
   localparam TTWIDTH        = TTUSER_OFFSET  + (ENABLE_TUSER ? TTUSER_WIDTH      : 0);

   localparam ITSTRB_OFFSET  = ITDATA_WIDTH;
   localparam ITKEEP_OFFSET  = ITSTRB_OFFSET  + (ENABLE_TSTRB ? (ITDATA_WIDTH/8)  : 0);
   localparam ITLAST_OFFSET  = ITKEEP_OFFSET  + (ENABLE_TKEEP ? (ITDATA_WIDTH/8)  : 0);
   localparam ITID_OFFSET    = ITLAST_OFFSET  + (ENABLE_TLAST ? 1                 : 0);
   localparam ITDEST_OFFSET  = ITID_OFFSET    + (ENABLE_TID   ? ITID_WIDTH        : 0);
   localparam ITUSER_OFFSET  = ITDEST_OFFSET  + (ENABLE_TDEST ? ITDEST_WIDTH      : 0);
   localparam ITWIDTH        = ITUSER_OFFSET  + (ENABLE_TUSER ? ITUSER_WIDTH      : 0);


   wire               aresetn;
   wire               sresetn;


   wire               fifo_rd_en;

   wire [WIDTH_CORE-1:0]  m_axi4s_data;
   reg  [WIDTH_CORE-1:0]  dout;
   reg                    dout_valid;
   reg                    fifo_valid;

   assign aresetn = (RESET_TYPE == 1) ? 1'b1 : M_AXIS_ARESETN_i;
   assign sresetn = (RESET_TYPE == 1) ? M_AXIS_ARESETN_i : 1'b1;


   assign M_AXIS_TDATA_o  = m_axi4s_data[ITDATA_WIDTH-1:0];



generate  
  if  ( (READ_MODE == 0) && (PIPE == 2)&&(ECC == 1)) begin : gen_axi4s_initr_cut_through_mode_pipelined_ecc  

   reg              fifo_rd_en_d1;
   reg              fifo_rd_en_d2;
   reg [2:0]        fifo_rdreq_cnt;
   reg [2:0]        fifo_valid_cnt;  
   reg              pipe_reg1_valid;
   reg              pipe_reg2_valid;
   reg              pipe_reg3_valid;
   reg              pipe_reg3_1_hold;
   reg              pipe_reg3_2_hold;
   reg [WIDTH_CORE-1:0] pipe_reg1;
   reg [WIDTH_CORE-1:0] pipe_reg2;
   reg [WIDTH_CORE-1:0] pipe_reg3;
   
   assign fifo_rd_en = (~FIFO_EMPTY_i && ((fifo_rdreq_cnt != 4) || M_AXIS_TREADY_i));
   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
      if(!aresetn | !sresetn) begin
	    fifo_rdreq_cnt <= 0;
	  end else if(fifo_rd_en ^ (dout_valid & M_AXIS_TREADY_i)) begin 
	    if(fifo_rd_en)
		  fifo_rdreq_cnt <= fifo_rdreq_cnt + 1'b1;
		else 
		  fifo_rdreq_cnt <= fifo_rdreq_cnt - 1'b1;
	  end 
   end    
   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
      if(!aresetn | !sresetn) begin
	    fifo_valid_cnt <= 0;
	  end else if(fifo_valid ^ (dout_valid & M_AXIS_TREADY_i)) begin 
	    if(fifo_valid)
		  fifo_valid_cnt <= fifo_valid_cnt + 1'b1;
		else 
		  fifo_valid_cnt <= fifo_valid_cnt - 1'b1;
	  end 
   end     

   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
	   fifo_rd_en_d1  <= 0;
	 else 
	   fifo_rd_en_d1  <= fifo_rd_en;
	   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
	   fifo_rd_en_d2  <= 0;
	 else 
	   fifo_rd_en_d2  <= fifo_rd_en_d1;	   

   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       fifo_valid  <= 1'b0;
     else 
       fifo_valid  <= fifo_rd_en_d2;
	   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg1_valid <= 1'b0;
     else if((fifo_valid_cnt == 1) && fifo_valid && ~M_AXIS_TREADY_i)
       pipe_reg1_valid  <= 1'b1;
     else if((fifo_valid_cnt == 2) && fifo_valid && (M_AXIS_TREADY_i || pipe_reg3_valid)) 
       pipe_reg1_valid  <= 1'b1;	
     else if((fifo_valid_cnt == 2) && ~pipe_reg3_valid && ~pipe_reg2_valid && ~M_AXIS_TREADY_i) 
       pipe_reg1_valid  <= 1'b1;	
	 else if((fifo_valid_cnt == 3) && fifo_valid && ((M_AXIS_TREADY_i && pipe_reg3_1_hold) || (pipe_reg2_valid && pipe_reg3_valid)))    
       pipe_reg1_valid  <= 1'b1;
	 else if (M_AXIS_TREADY_i) begin  
	   if(
           ((fifo_valid_cnt == 4) && ~pipe_reg3_1_hold) || 
		   ((fifo_valid_cnt == 3) && M_AXIS_TREADY_i && ~pipe_reg3_valid) ||
           (((fifo_valid_cnt == 2) || (fifo_valid_cnt == 1))) ||
		   (fifo_valid_cnt == 1)
	     ) 
         pipe_reg1_valid  <= 1'b0;   
     end 
	 
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg2_valid  <= 1'b0;
     else if((fifo_valid_cnt == 2) && fifo_valid && ~M_AXIS_TREADY_i && ~pipe_reg3_valid) 
       pipe_reg2_valid  <= 1'b1;
     //else if((fifo_valid_cnt == 3) && fifo_valid && (~M_AXIS_TREADY_i || (pipe_reg3_valid && pipe_reg1_valid && ~pipe_reg3_1_hold))) 
	 else if((fifo_valid_cnt == 3) && fifo_valid && (~M_AXIS_TREADY_i || pipe_reg3_2_hold) && ((pipe_reg1_valid && pipe_reg3_valid)))    
       pipe_reg2_valid  <= 1'b1;	   
     else if (
	       ((fifo_valid_cnt == 4) && ~(pipe_reg1_valid && ~pipe_reg3_1_hold) && ~pipe_reg3_2_hold && M_AXIS_TREADY_i) ||
	       ((fifo_valid_cnt == 3) && M_AXIS_TREADY_i && ~(pipe_reg1_valid && ~pipe_reg3_valid)) ||
		   ((fifo_valid_cnt == 2) && fifo_valid && ~pipe_reg1_valid) ||
           (fifo_valid_cnt == 1)		   
	     )
         pipe_reg2_valid  <= 1'b0;
	 
	   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg3_valid <= 1'b0;
     else if((fifo_valid_cnt == 3) && fifo_valid && (~M_AXIS_TREADY_i || (pipe_reg1_valid && pipe_reg2_valid))) 
       pipe_reg3_valid  <= 1'b1;
     else if((fifo_valid_cnt == 2) && fifo_valid && ~M_AXIS_TREADY_i && pipe_reg2_valid) 
       pipe_reg3_valid  <= 1'b1;	   
     else if (M_AXIS_TREADY_i) begin 
	   if(
	       ((fifo_valid_cnt == 4) && ~(pipe_reg1_valid && ~pipe_reg3_1_hold) && ~(pipe_reg2_valid && ~pipe_reg3_2_hold)) ||
	       ((fifo_valid_cnt == 2) && ~pipe_reg1_valid && ~pipe_reg2_valid) ||
           ((fifo_valid_cnt == 3) && ~pipe_reg2_valid) ||
		   (fifo_valid_cnt == 1)		   
	     )
         pipe_reg3_valid  <= 1'b0;
	 end   
	 
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg3_1_hold  <= 1'b0;
	 else if(~pipe_reg3_valid)
       pipe_reg3_1_hold  <= 1'b0;  
     else if(pipe_reg3_valid & ~pipe_reg1_valid)
       pipe_reg3_1_hold  <= 1'b1;

   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg3_2_hold  <= 1'b0;
	 else if(~pipe_reg3_valid)
       pipe_reg3_2_hold  <= 1'b0;  
     else if(pipe_reg3_valid & ~pipe_reg2_valid)
       pipe_reg3_2_hold  <= 1'b1;
	   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg1  <= {WIDTH_CORE{1'b0}};
     else if (fifo_valid && (fifo_valid_cnt == 1) && ~M_AXIS_TREADY_i ) 
       pipe_reg1 <= FIFO_RD_DATA_AXIS_i;
     else if((fifo_valid_cnt == 2) && fifo_valid && (M_AXIS_TREADY_i || pipe_reg3_valid)) 
       pipe_reg1 <= FIFO_RD_DATA_AXIS_i;
	 else if((fifo_valid_cnt == 2) && ~pipe_reg3_valid && ~pipe_reg2_valid && ~pipe_reg1_valid) 
	   pipe_reg1 <= FIFO_RD_DATA_AXIS_i;
     //else if((fifo_valid_cnt == 3) && fifo_valid && (~M_AXIS_TREADY_i | pipe_reg3_1_hold) && ((pipe_reg2_valid && pipe_reg3_valid)))    
	 else if((fifo_valid_cnt == 3) && fifo_valid && ~pipe_reg1_valid && ((M_AXIS_TREADY_i && pipe_reg3_1_hold) || (pipe_reg2_valid && pipe_reg3_valid)))    
       pipe_reg1 <= FIFO_RD_DATA_AXIS_i;	
	   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg2  <= {WIDTH_CORE{1'b0}};
	 else if(~pipe_reg2_valid) begin
       if((fifo_valid_cnt == 2) && fifo_valid && ~M_AXIS_TREADY_i && ~pipe_reg2_valid)  
	     pipe_reg2  <= FIFO_RD_DATA_AXIS_i;  
       //else if((fifo_valid_cnt == 3) && fifo_valid && (~M_AXIS_TREADY_i || (pipe_reg3_valid && pipe_reg1_valid)))  
	   else if((fifo_valid_cnt == 3) && fifo_valid && (~M_AXIS_TREADY_i || pipe_reg3_2_hold) && ((pipe_reg1_valid && pipe_reg3_valid)))    
         pipe_reg2  <= FIFO_RD_DATA_AXIS_i;  	  
	 end 
	 
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg3  <= {WIDTH_CORE{1'b0}};  
	 else if(~pipe_reg3_valid) begin
       if((fifo_valid_cnt == 3) && fifo_valid && (~M_AXIS_TREADY_i || (pipe_reg1_valid && pipe_reg2_valid))) 
	     pipe_reg3  <= FIFO_RD_DATA_AXIS_i;  	   
	   else if((fifo_valid_cnt == 2) && fifo_valid && ~M_AXIS_TREADY_i && pipe_reg2_valid) 
	     pipe_reg3  <= FIFO_RD_DATA_AXIS_i;  	   
	 end  
	 
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       dout_valid   <= 1'b0;
     else if(fifo_valid & ~dout_valid) 
       dout_valid  <= 1'b1;
     else if((fifo_valid_cnt == 1) & M_AXIS_TREADY_i & ~fifo_valid) 
       dout_valid  <= 1'b0;
	   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
      if(!aresetn | !sresetn)
         dout <= {WIDTH_CORE{1'b0}};
      else if(~dout_valid & fifo_valid) 
		 dout <= FIFO_RD_DATA_AXIS_i;
      else if (M_AXIS_TREADY_i)  		   
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
				     dout <= FIFO_RD_DATA_AXIS_i;
         1       : if(pipe_reg1_valid)
		             dout <= pipe_reg1;
		           else 
				     dout <= FIFO_RD_DATA_AXIS_i;
         default : dout <= FIFO_RD_DATA_AXIS_i;
        endcase

   assign  m_axi4s_data = dout;

   assign  FIFO_RD_EN_AXIS_o    = fifo_rd_en;

   assign  M_AXIS_TVALID_o      = dout_valid;
 end else if ((READ_MODE == 0) && ((PIPE == ECC) | (PIPE == 2 & ECC == 0))) begin : gen_axi4s_initr_cut_through_mode_pipelined_noecc
   reg [2:0]        fifo_rdreq_cnt;
   reg [2:0]        fifo_valid_cnt;  
   reg              pipe_reg1_valid;
   reg              pipe_reg2_valid;
   reg              fifo_rd_en_d1;
   reg [WIDTH_CORE-1:0] pipe_reg1;
   reg [WIDTH_CORE-1:0] pipe_reg2;
   
 
   // --------------------------------------------------------------------------
   // Generates the read enable to be given to the FIFO controller
   // fifo_rd_en: It is different from the top-level read enable
   // --------------------------------------------------------------------------
   assign fifo_rd_en = (~FIFO_EMPTY_i && ((fifo_rdreq_cnt != 3) || M_AXIS_TREADY_i));
   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
      if(!aresetn | !sresetn) begin
	    fifo_rdreq_cnt <= 0;
	  end else if(fifo_rd_en ^ (dout_valid & M_AXIS_TREADY_i)) begin 
	    if(fifo_rd_en)
		  fifo_rdreq_cnt <= fifo_rdreq_cnt + 1'b1;
		else 
		  fifo_rdreq_cnt <= fifo_rdreq_cnt - 1'b1;
	  end 
   end 
	    
   always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
      if(!aresetn | !sresetn) begin
	    fifo_valid_cnt <= 0;
	  end else if(fifo_valid ^ (dout_valid & M_AXIS_TREADY_i)) begin 
	    if(fifo_valid)
		  fifo_valid_cnt <= fifo_valid_cnt + 1'b1;
		else 
		  fifo_valid_cnt <= fifo_valid_cnt - 1'b1;
	  end 
   end     

   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
	   fifo_rd_en_d1  <= 0;
	 else 
	   fifo_rd_en_d1  <= fifo_rd_en;

   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       fifo_valid  <= 1'b0;
     else 
       fifo_valid  <= fifo_rd_en_d1;
	   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg1_valid <= 1'b0;
     else if((fifo_valid_cnt == 1) && fifo_valid && ~M_AXIS_TREADY_i)
       pipe_reg1_valid  <= 1'b1;
     else if((fifo_valid_cnt == 2) && fifo_valid && (M_AXIS_TREADY_i | pipe_reg2_valid)) 
       pipe_reg1_valid  <= 1'b1;		 
     else if(~fifo_valid && pipe_reg2_valid && M_AXIS_TREADY_i && (fifo_valid_cnt == 3))  
       pipe_reg1_valid  <= 1'b1;
     else if(((fifo_valid_cnt == 2) || (fifo_valid_cnt == 3)) && M_AXIS_TREADY_i) 
       pipe_reg1_valid  <= 1'b0;
      
 
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg2_valid <= 1'b0;
     else if((fifo_valid_cnt == 2) && fifo_valid & ~M_AXIS_TREADY_i) 
       pipe_reg2_valid  <= 1'b1;
     else if(((fifo_valid_cnt == 2) && M_AXIS_TREADY_i && ~pipe_reg1_valid) || ((fifo_valid_cnt == 3) && M_AXIS_TREADY_i && ~pipe_reg1_valid)) 
       pipe_reg2_valid  <= 1'b0;
	   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg1  <= {WIDTH_CORE{1'b0}};
     else if (fifo_valid && (fifo_valid_cnt == 1) && ~M_AXIS_TREADY_i ) 
       pipe_reg1 <= FIFO_RD_DATA_AXIS_i;
     else if(fifo_valid && M_AXIS_TREADY_i && (fifo_valid_cnt == 2))
       pipe_reg1 <= FIFO_RD_DATA_AXIS_i;
     else if(~fifo_valid && pipe_reg2_valid && M_AXIS_TREADY_i && (fifo_valid_cnt == 3))
       pipe_reg1 <= FIFO_RD_DATA_AXIS_i;
	   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       pipe_reg2  <= {WIDTH_CORE{1'b0}};
     else if (fifo_valid && (fifo_valid_cnt == 2) && ~M_AXIS_TREADY_i && ~pipe_reg2_valid) 
	   pipe_reg2  <= FIFO_RD_DATA_AXIS_i;  
	   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if(!aresetn | !sresetn)
       dout_valid   <= 1'b0;
     else if(fifo_valid & ~dout_valid) 
       dout_valid  <= 1'b1;
     else if((fifo_valid_cnt == 1) & M_AXIS_TREADY_i & ~fifo_valid) 
       dout_valid  <= 1'b0;
	   
   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
      if(!aresetn | !sresetn)
         dout <= {WIDTH_CORE{1'b0}};
      else if(~dout_valid & fifo_valid) 
		 dout <= FIFO_RD_DATA_AXIS_i;
      else if (M_AXIS_TREADY_i)  		   
        case(fifo_valid_cnt)
         3       : if(pipe_reg1_valid)
                     dout <= pipe_reg1;
                   else 
                     dout <= pipe_reg2;				 
         2       : if(pipe_reg1_valid)
		             dout <= pipe_reg1;
		           else if(~fifo_valid)
                     dout <= FIFO_RD_DATA_AXIS_i;        	         
        	       else 
        	         dout <= pipe_reg2;
          1      : dout <= FIFO_RD_DATA_AXIS_i;
         default : dout <= FIFO_RD_DATA_AXIS_i;
        endcase

   assign  m_axi4s_data = dout;

   assign  FIFO_RD_EN_AXIS_o    = fifo_rd_en;

   assign  M_AXIS_TVALID_o      = dout_valid;

end else if  ( (READ_MODE == 0) && ((PIPE == 1) && (ECC != 1))) begin : gen_axi4s_initr_cut_through_mode_nonpipelined
   reg                   middle_valid;
   wire                  update_middle;
   
   reg  [WIDTH_CORE-1:0] middle_dout;
   wire                  update_dout;
   
   
   assign update_middle = fifo_valid & (middle_valid == update_dout);
   assign update_dout   = (fifo_valid || middle_valid) && (M_AXIS_TREADY_i || !dout_valid);

   // --------------------------------------------------------------------------
   // Generates the read enable to be given to the FIFO controller
   // fifo_rd_en: It is different from the top-level read enable
   // --------------------------------------------------------------------------
   assign fifo_rd_en = !(FIFO_EMPTY_i) && !(middle_valid && dout_valid && fifo_valid);

   always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
      if(!aresetn | !sresetn) begin
         fifo_valid   <= 1'b0;
         middle_valid <= 1'b0;
         dout_valid   <= 1'b0;
         dout         <= 0;
         middle_dout  <= 0;
      end
      else begin
         if(update_middle) begin
            middle_dout  <= FIFO_RD_DATA_AXIS_i;
         end
         if(update_dout) begin
            dout  <= middle_valid ? middle_dout : FIFO_RD_DATA_AXIS_i;
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
         else if(M_AXIS_TREADY_i) begin
            dout_valid  <= 1'b0;
         end

      end
   end
   
   assign  m_axi4s_data = dout;

   assign  FIFO_RD_EN_AXIS_o    = fifo_rd_en;

   assign  M_AXIS_TVALID_o      = dout_valid;

end
endgenerate
endmodule
