// ********************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2023 Microchip Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// IP Core:      COREAXI4INTERCONNECT
//
// SVN Revision Information:
// SVN $Revision: 51335 $
// SVN $Date: 2026-04-24 18:00:00 +0530 (Fri, 24 Apr 2026) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns
 
 
module caxi4interconnect_DWC_DownConv_widthConvrd (
                                 //  input ports
                                 arst_sync,
                                 srst_sync,
                                 ACLK,
                                 INITIATOR_RREADY,								 
                                 TARGET_RDATA,
                                 TARGET_RLAST,
                                 TARGET_RVALID,
								 TARGET_RID,
                                 TARGET_RRESP,
                                 TARGET_RUSER,
                                 rdCmdFifoReadData,
                                 rdCmdFifoEmpty,
                                 mask_intrSize,
                                 mask_trgtSize,
                                 sizeCnt_comb_EQ_SizeMax,
                                 initiator_ADDR_masked,
                                 second_Beat_Addr,
                                 sizeCnt_comb_P1,
                                 targetSize_one_hot,
                                 sizeMax_extend,
                                 shifted_trgt_mask_bit,
                                 shifted_intr_mask_bit,
 
                                 //  output ports
                                 INITIATOR_RID,
                                 INITIATOR_RDATA,
                                 INITIATOR_RLAST,
                                 INITIATOR_RVALID,
                                 INITIATOR_RUSER,
                                 INITIATOR_RRESP,
                                 TARGET_RREADY,
                                 rdCmdFifore,
                                 shifted_trgt_mask_byte,
                                 shifted_intr_mask_byte,
								 initiator_hold
                                 );
 
   parameter        CMD_FIFO_DATA_WIDTH       = 30;
   parameter        USER_WIDTH                = 1;
   parameter        ID_WIDTH                  = 1;
   parameter        DATA_WIDTH_IN             = 32;
   parameter        DATA_WIDTH_OUT            = 32;
   parameter        READ_INTERLEAVE           = 1;
   
//  input ports
   input            arst_sync;
   input            srst_sync;
   wire             arst_sync;
   input            ACLK;
   wire             ACLK;
   input            INITIATOR_RREADY;
   wire             INITIATOR_RREADY;
   input     [DATA_WIDTH_IN - 1:0] TARGET_RDATA;
   wire      [DATA_WIDTH_IN - 1:0] TARGET_RDATA;
   input            TARGET_RLAST;
   wire             TARGET_RLAST;
   input            TARGET_RVALID;
   wire             TARGET_RVALID;
   input     [ID_WIDTH-1:0] TARGET_RID;
   input     [1:0]  TARGET_RRESP;
   wire      [1:0]  TARGET_RRESP;
   input     [USER_WIDTH - 1:0] TARGET_RUSER;
   wire      [USER_WIDTH - 1:0] TARGET_RUSER;
   input     [CMD_FIFO_DATA_WIDTH - 1:0] rdCmdFifoReadData;
   wire      [CMD_FIFO_DATA_WIDTH - 1:0] rdCmdFifoReadData;
   input            rdCmdFifoEmpty;
   wire             rdCmdFifoEmpty;
   input     [5:0]  mask_intrSize;
   wire      [5:0]  mask_intrSize;
   input     [5:0]  mask_trgtSize;
   wire      [5:0]  mask_trgtSize;
   input            sizeCnt_comb_EQ_SizeMax;
   wire             sizeCnt_comb_EQ_SizeMax;
   input     [5:0]  initiator_ADDR_masked;
   wire      [5:0]  initiator_ADDR_masked;
   input     [5:0]  second_Beat_Addr;
   wire      [5:0]  second_Beat_Addr;
   input     [5:0]  sizeCnt_comb_P1;
   wire      [5:0]  sizeCnt_comb_P1;
   input     [6:0]  targetSize_one_hot;
   wire      [6:0]  targetSize_one_hot;
   input     [5:0]  sizeMax_extend;
   wire      [5:0]  sizeMax_extend;
   input     [DATA_WIDTH_IN - 1:0] shifted_trgt_mask_bit;
   wire      [DATA_WIDTH_IN - 1:0] shifted_trgt_mask_bit;
   input     [DATA_WIDTH_OUT - 1:0] shifted_intr_mask_bit;
   wire      [DATA_WIDTH_OUT - 1:0] shifted_intr_mask_bit;
   input                            initiator_hold;
//  output ports
   output    [ID_WIDTH - 1:0] INITIATOR_RID;
   reg       [ID_WIDTH - 1:0] INITIATOR_RID;
   output    [DATA_WIDTH_OUT - 1:0] INITIATOR_RDATA;
   reg       [DATA_WIDTH_OUT - 1:0] INITIATOR_RDATA;
   output           INITIATOR_RLAST;
   reg              INITIATOR_RLAST;
   output           INITIATOR_RVALID;
   reg              INITIATOR_RVALID;
   output    [USER_WIDTH - 1:0] INITIATOR_RUSER;
   reg       [USER_WIDTH - 1:0] INITIATOR_RUSER;
   output    [1:0]  INITIATOR_RRESP;
   reg       [1:0]  INITIATOR_RRESP;
   output           TARGET_RREADY;
   wire             TARGET_RREADY;
   output           rdCmdFifore;
   wire             rdCmdFifore;
   output    [(DATA_WIDTH_IN / 8) - 1:0] shifted_trgt_mask_byte;
   wire      [(DATA_WIDTH_IN / 8) - 1:0] shifted_trgt_mask_byte;
   output    [(DATA_WIDTH_OUT / 8) - 1:0] shifted_intr_mask_byte;
   wire      [(DATA_WIDTH_OUT / 8) - 1:0] shifted_intr_mask_byte;
//  local signals
   wire      [5:0]  int_initiatorADDR;
   wire             SameInitrTrgtSize;
   wire             lastTx;
   wire             initiator_accept;
   reg       [8:0]  cnt;
   reg       [5:0]  current_addr;
   reg       [5:0]  current_addr_reg;
   wire             target_valid_data;
   wire      [5:0]  dataLoc;
   wire      [5:0]  dataLocInitr;
   wire      [5:0]  dataLocTrgt;
   reg       [DATA_WIDTH_OUT - 1:0] INITIATOR_RDATA_next;
   reg       [DATA_WIDTH_OUT - 1:0] FIXED_INITIATOR_RDATA_next;
   wire      [DATA_WIDTH_OUT - 1:0] INITIATOR_RDATA_masked;
   wire      [DATA_WIDTH_IN - 1:0] TARGET_RDATA_masked;
   wire      [5:0]  addr_mux;
   wire      [ID_WIDTH - 1:0] int_initiatorRID;
   wire             fixed_flag;
   reg       [5:0]  sizeCnt;
   reg       [5:0]  fixed_burst_sizecnt;
   reg       [5:0]  sizeCnt_reg;
   reg              cnt_EQ_zero;
   wire      [5:0]  SizeMax;
   wire      [(DATA_WIDTH_IN / 8) - 1:0] unshifted_mask;     //  TC: this mask is based on a one-hot size (not encoded size)
   wire      [$clog2 (DATA_WIDTH_OUT / 8) - $clog2 (DATA_WIDTH_IN / 8) - 1:0] target_intr_data_part;
   wire      [(2**($clog2 (DATA_WIDTH_OUT / 8) - $clog2 (DATA_WIDTH_IN / 8)))-1:0] target_intr_data_onehot;
   wire      [$clog2 (DATA_WIDTH_IN) + $clog2 (DATA_WIDTH_OUT / 8) - $clog2 (DATA_WIDTH_IN / 8) - 1:0] trgt_masked_rdata_shift;
   wire             initiator_hold_keep;
   wire      [1:0]  INITIATOR_RRESP_next;
   reg       [1:0]  TARGET_RRESP_MAX;
   wire             higher_target_rresp;
   wire             last_target_beat;
   wire             fixed_burst;
   reg              target_rddone;
   reg              fixed_burst_ctrl;
   reg              fixed_burst_ctrl_reg;
   reg              rdCmdFifoEmpty_reg;
   wire      [DATA_WIDTH_OUT - 1:0] intr_mask_bit;
   reg              fixed_burst_reg;
   reg [5:0]        sizeMax_extend_reg;
   reg              sizeMax_extend_chng;
   reg              fixed_lastTx_ctrl;
   
   genvar          i;

 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :widthConvRead_ctrl
 
      if (~arst_sync | ~srst_sync)
      begin
         INITIATOR_RVALID <= 0;
         INITIATOR_RLAST <= 0;
         INITIATOR_RDATA <= 0;
         INITIATOR_RUSER <= 0;
         INITIATOR_RID <= 0;
         INITIATOR_RRESP <= 0;
      end
      else
      begin
         if (initiator_hold_keep | initiator_hold)
         begin
         end
         else
         begin
            INITIATOR_RDATA <= INITIATOR_RDATA_next;
            INITIATOR_RUSER <= TARGET_RUSER;
			if(~READ_INTERLEAVE[0])
			  begin 
                INITIATOR_RID <= int_initiatorRID;            
			  end 
            INITIATOR_RRESP <= INITIATOR_RRESP_next;
 
            // Setting defaults
            // VALID and LAST defaulted to 0, and asserted as required.
            INITIATOR_RVALID <= 0;
            INITIATOR_RLAST <= 0;
            if (rdCmdFifoEmpty)
            begin
            end
            else
            begin
               if (TARGET_RVALID)
               begin
                  if (last_target_beat)
                  begin
                     INITIATOR_RVALID <= 1;
					 if(READ_INTERLEAVE[0])
					   begin 
					     INITIATOR_RID    <= int_initiatorRID; 
					   end 
                     INITIATOR_RLAST  <= 1;
                  end
                  else
                  begin
                     if (SameInitrTrgtSize)
                     begin
                        INITIATOR_RVALID <= 1;
						if(READ_INTERLEAVE[0])
					      begin
						    INITIATOR_RID    <= int_initiatorRID; 
						  end 
                     end
                     else
                     begin
                        if (dataLoc == sizeMax_extend)
                        begin
                           INITIATOR_RVALID <= 1;
						   if(READ_INTERLEAVE[0])
					         begin
						       INITIATOR_RID    <= int_initiatorRID; 
							 end 
                        end
                     end
                  end
               end
            end
         end
      end
   end
 
 
 
   always  @(*)
   begin   :addr_ctrl
 
      if (target_valid_data)
      begin
         if (cnt_EQ_zero & ~(fixed_burst_ctrl & fixed_burst))
         begin
            if (fixed_flag)
            begin
               if (SameInitrTrgtSize)
               begin
                  current_addr = int_initiatorADDR;
               end
               else
               begin
                  if (sizeCnt_comb_EQ_SizeMax)
                  begin
                     current_addr = initiator_ADDR_masked;
                  end
                  else
                  begin
                     current_addr = second_Beat_Addr;
                  end
               end
            end
            else
            begin
               current_addr = second_Beat_Addr;
            end
         end
         else
         begin
            if (fixed_flag | fixed_burst)
            begin
               if (SameInitrTrgtSize)
                 current_addr = int_initiatorADDR;
               else if ((sizeCnt_reg == SizeMax) & ~fixed_burst)
                 current_addr = initiator_ADDR_masked;
			   else if((fixed_burst_sizecnt == (SizeMax - sizeCnt_comb_P1)))
                 current_addr = int_initiatorADDR;					   
               else
                  current_addr = current_addr_reg + targetSize_one_hot[5:0];
            end
            else
              current_addr = current_addr_reg + targetSize_one_hot[5:0];
         end
      end
      else
      begin
         current_addr = current_addr_reg;
      end
   end
 
 
 
   always  @(*)
   begin   :sieCntCtrl
 
      if (target_valid_data)
      begin
         if (fixed_flag)
         begin
            if (SameInitrTrgtSize)
            begin
               sizeCnt = 'b0;
            end
            else
            begin
               if (cnt_EQ_zero & ~(fixed_burst_ctrl & fixed_burst))
               begin
                  if (SameInitrTrgtSize)
                  begin
                     sizeCnt = 'b0;
                  end
                  else
                  begin
                     if (sizeCnt_comb_EQ_SizeMax)
                     begin
                        sizeCnt = 'b0;
                     end
                     else
                     begin
                        sizeCnt = sizeCnt_comb_P1;
                     end
                  end
               end
               else
               begin
                  if (SameInitrTrgtSize)
                  begin
                     sizeCnt = 'b0;
                  end
                  else
                  begin
                     if (SizeMax == sizeCnt_reg)
                     begin
                        sizeCnt = 'b0;
                     end
                     else
                     begin
                        sizeCnt = sizeCnt_reg + 1;
                     end
                  end
               end
            end
         end
         else
         begin
            if (cnt_EQ_zero & ~(fixed_burst_ctrl & fixed_burst))
            begin
               if (SameInitrTrgtSize)
               begin
                  sizeCnt = 'b0;
               end
               else
               begin
                  if (sizeCnt_comb_EQ_SizeMax)
                  begin
                     sizeCnt = 'b0;
                  end
                  else
                  begin
                     sizeCnt = sizeCnt_comb_P1;
                  end
               end
            end
            else
            begin
               if (SameInitrTrgtSize)
               begin
                  sizeCnt = 'b0;
               end
               else
               begin
                  if (SizeMax == sizeCnt_reg)
                  begin
                     sizeCnt = 'b0;
                  end
                  else
                  begin
                     sizeCnt = sizeCnt_reg + 1;
                  end
               end
            end
         end
      end
      else
      begin
         sizeCnt = sizeCnt_reg;
      end
   end
 
 
 
   always
      @( posedge ACLK or negedge arst_sync )
   begin   :addrCtrl_reg
 
      if (~arst_sync | ~srst_sync)
      begin
         current_addr_reg <= 0;
         sizeCnt_reg <= 0;
      end
      else
      begin
         current_addr_reg <= current_addr;
         sizeCnt_reg <= sizeCnt;
      end
   end
 
 
 
   always
      @( posedge ACLK or negedge arst_sync )
   begin   :cnt_ctrl
 
      if (~arst_sync | ~srst_sync)
      begin
         cnt <= 0;
         cnt_EQ_zero <= 1;
      end
      else
      begin
         if (target_valid_data)
         begin
            if (TARGET_RLAST)
            begin
               cnt <= 0;
               cnt_EQ_zero <= 1;
            end
            else
            begin
               cnt <= cnt + 1;
               cnt_EQ_zero <= 0;
            end
         end
      end
   end
 
 
 
   always
      @( posedge ACLK or negedge arst_sync )
   begin   :rresp_ctrl
 
      if (~arst_sync | ~srst_sync)
      begin
         TARGET_RRESP_MAX <= 2'b00;
      end
      else
      begin
         if (rdCmdFifoEmpty)
         begin
            TARGET_RRESP_MAX <= 2'b00;
         end
         else
         begin
            if (initiator_accept)
            begin
               if (TARGET_RVALID)
               begin
                  TARGET_RRESP_MAX <= TARGET_RRESP;
               end
               else
               begin
                  TARGET_RRESP_MAX <= 2'b00;
               end
            end
            else
            begin
               if (TARGET_RVALID)
               begin
                  if (TARGET_RRESP > TARGET_RRESP_MAX)
                  begin
                     TARGET_RRESP_MAX <= TARGET_RRESP;
                  end
               end
            end
         end
      end
   end
 
 
   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       target_rddone <= 0;
	 else 
	   target_rddone <= rdCmdFifore;
	   
   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       fixed_burst_reg <= 1'b0;
	 else if(TARGET_RVALID & last_target_beat)
	   fixed_burst_reg <= 1'b0;
	 else if(fixed_burst)
	   fixed_burst_reg <= 1'b1;
	   
   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       sizeMax_extend_reg <= 0;
	 else 
	   sizeMax_extend_reg <= sizeMax_extend;

   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       sizeMax_extend_chng <= 1'b0;
	 else if((sizeMax_extend != sizeMax_extend_reg) | fixed_lastTx_ctrl)
	   sizeMax_extend_chng <= 1'b1;
	 else 
	   sizeMax_extend_chng <= 1'b0;
	 
   always@(posedge ACLK or negedge arst_sync)
     if (~arst_sync | ~srst_sync)
	   fixed_lastTx_ctrl <= 1'b0;
	 else if(lastTx)
	   fixed_lastTx_ctrl <= 1'b1;
	 else if(INITIATOR_RVALID & INITIATOR_RREADY & INITIATOR_RLAST)
	   fixed_lastTx_ctrl <= 1'b0;
	   
   always @(*)
     if(INITIATOR_RVALID & INITIATOR_RREADY & INITIATOR_RLAST & (~TARGET_RVALID | SameInitrTrgtSize | sizeMax_extend_chng ))     
	   fixed_burst_ctrl = 1'b0;
	 else if(target_rddone & fixed_burst_reg)
	   fixed_burst_ctrl = 1'b1;
	 else 
	   fixed_burst_ctrl = fixed_burst_ctrl_reg;

   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       fixed_burst_ctrl_reg <= 1'b0;
	 else 
	   fixed_burst_ctrl_reg <= fixed_burst_ctrl;
 
   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       rdCmdFifoEmpty_reg <= 1'b0;
	 else 
	   rdCmdFifoEmpty_reg <= rdCmdFifoEmpty;
 
   // Split up wrCmdFifoRdData
   //assign int_initiatorRID = READ_INTERLEAVE ? target_valid_data ? TARGET_RID : {ID_WIDTH{1'b0}}: rdCmdFifoReadData[30+ID_WIDTH-1:30];
   assign int_initiatorRID = READ_INTERLEAVE[0] ? (target_valid_data ? TARGET_RID : {ID_WIDTH{1'b0}}) : TARGET_RID ;
   assign fixed_flag = rdCmdFifoReadData[29];
   assign int_initiatorADDR = rdCmdFifoReadData[28:23];
   assign SameInitrTrgtSize = rdCmdFifoReadData[7];
   assign SizeMax = rdCmdFifoReadData[6:1]; // not used used for compering to dataLoc
   assign lastTx = rdCmdFifoReadData[0];
   assign fixed_burst = rdCmdFifoReadData[37+ID_WIDTH-1];
   
   assign rdCmdFifore = TARGET_RREADY & TARGET_RLAST & TARGET_RVALID & ~initiator_hold;
 
   assign addr_mux = cnt_EQ_zero & ~(fixed_burst_ctrl & fixed_burst)  ? int_initiatorADDR : current_addr_reg;
 
   // Location of data on Initiator bus

   assign dataLocInitr = ((DATA_WIDTH_OUT/8) - 1) & addr_mux & mask_trgtSize;
 
   assign dataLoc = ( mask_intrSize & addr_mux );
 
   // Location of data on Target bus
   assign dataLocTrgt = ((DATA_WIDTH_IN/8) - 1) & addr_mux & mask_trgtSize;
 
   assign initiator_accept = INITIATOR_RVALID & INITIATOR_RREADY;
   assign target_valid_data = TARGET_RREADY & TARGET_RVALID & ~initiator_hold;
 
   assign unshifted_mask = (1 << targetSize_one_hot) - 1;
 
   assign shifted_intr_mask_byte = unshifted_mask << dataLocInitr;
   assign shifted_trgt_mask_byte = unshifted_mask << dataLocTrgt;
 
   assign TARGET_RDATA_masked = TARGET_RDATA & shifted_trgt_mask_bit;
   assign INITIATOR_RDATA_masked = INITIATOR_RDATA & ~shifted_intr_mask_bit;
 
   assign target_intr_data_part = dataLocInitr >> $clog2(DATA_WIDTH_IN/8);
   assign trgt_masked_rdata_shift = target_intr_data_part << $clog2(DATA_WIDTH_IN); 
 
   always@(posedge ACLK or negedge arst_sync)
     if (~arst_sync | ~srst_sync)
	   FIXED_INITIATOR_RDATA_next <= 0;
	 else if((SameInitrTrgtSize & TARGET_RVALID) | ((fixed_burst_sizecnt == (SizeMax - sizeCnt_comb_P1)) & target_valid_data))
	   FIXED_INITIATOR_RDATA_next <= 0;
	 else if(fixed_burst & target_valid_data)
	   FIXED_INITIATOR_RDATA_next <= (FIXED_INITIATOR_RDATA_next | ((TARGET_RDATA_masked << trgt_masked_rdata_shift) & intr_mask_bit));
 
   always@(*)
     begin 
       if(target_valid_data)
	     begin 
	       if(fixed_burst)
	  	     INITIATOR_RDATA_next = (FIXED_INITIATOR_RDATA_next | ((TARGET_RDATA_masked << trgt_masked_rdata_shift) & intr_mask_bit));
	  	   else 
	  	     INITIATOR_RDATA_next = (INITIATOR_RDATA_masked | (TARGET_RDATA_masked << trgt_masked_rdata_shift));
	     end 
	   else 
	     INITIATOR_RDATA_next = INITIATOR_RDATA;
	 end 
 
   assign higher_target_rresp = TARGET_RVALID & (TARGET_RRESP > TARGET_RRESP_MAX);
   assign INITIATOR_RRESP_next = higher_target_rresp ? TARGET_RRESP : TARGET_RRESP_MAX;
   // TC: highest response could just arrive so use combinatorial logic
 
   assign last_target_beat = lastTx & TARGET_RLAST;
   assign initiator_hold_keep = INITIATOR_RVALID & !INITIATOR_RREADY; // Hold and keep initiator values until this is cleared
   assign TARGET_RREADY = !(rdCmdFifoEmpty | initiator_hold_keep );
 
   
   always@(posedge ACLK or negedge arst_sync)
     begin :fixburst_sizecnt
	   if (~arst_sync | ~srst_sync)
	     fixed_burst_sizecnt <= 0;
       else if((INITIATOR_RVALID & INITIATOR_RREADY & INITIATOR_RLAST & ~TARGET_RVALID) | ((fixed_burst_sizecnt == (SizeMax - sizeCnt_comb_P1)) & target_valid_data))	     
	     fixed_burst_sizecnt <= 0;
       else if (target_valid_data & fixed_burst)
	     fixed_burst_sizecnt <= fixed_burst_sizecnt + 1'b1;
     end 

   assign target_intr_data_onehot = (1 << target_intr_data_part);
   generate
     for (i=0;i<(DATA_WIDTH_OUT/DATA_WIDTH_IN);i=i+1) begin
       assign intr_mask_bit[(DATA_WIDTH_IN*i)+:DATA_WIDTH_IN] = {DATA_WIDTH_IN{target_intr_data_onehot[i]}};
     end
   endgenerate

  
endmodule

