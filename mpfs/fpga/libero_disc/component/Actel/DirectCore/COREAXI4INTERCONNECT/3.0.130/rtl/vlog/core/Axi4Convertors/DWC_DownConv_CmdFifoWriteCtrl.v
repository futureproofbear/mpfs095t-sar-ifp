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
// SVN $Revision: 50783 $
// SVN $Date: 2026-03-16 01:41:25 +0530 (Mon, 16 Mar 2026) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_DWC_DownConv_CmdFifoWriteCtrl (
                                      //  input ports
                                      ACLK,
                                      arst_sync,
                                      srst_sync,
                                      INITIATOR_AVALID,
                                      INITIATOR_AID,
                                      INITIATOR_AADDR,
                                      INITIATOR_ABURST,
                                      INITIATOR_ACACHE,
                                      INITIATOR_ALOCK,
                                      INITIATOR_ASIZE,
                                      INITIATOR_APROT,
                                      INITIATOR_AQOS,
                                      INITIATOR_AREGION,
                                      INITIATOR_AUSER,
                                      TARGET_AREADY,
                                      CmdFifoNearlyFull,
                                      brespFifoNearlyFull,
                                      to_boundary_initiator,
                                      mask_addr,
                                      ASIZE,
                                      tot_len,
                                      max_length_comb,
                                      length_comb,
                                      WrapLogLen_comb,
                                      SizeMax,
                                      SameInitrTrgtSize,
                                      sizeCnt_comb,
                                      INITIATOR_AADDR_mux,
		                              fixed_burst,
                                      unaligned_fixed_len_iter,
 
                                      //  output ports
                                      INITIATOR_AREADY,
                                      TARGET_ALEN,
                                      TARGET_AVALID,
                                      TARGET_AID,
                                      TARGET_AADDR,
                                      TARGET_ABURST,
                                      TARGET_ACACHE,
                                      TARGET_ALOCK,
                                      TARGET_ASIZE,
                                      TARGET_APROT,
                                      TARGET_AQOS,
                                      TARGET_AREGION,
                                      TARGET_AUSER,
                                      FifoWe,
                                      CmdFifoWrData,
                                      brespFifoWrData
                                      );
 
   parameter        ADDR_WIDTH            = 20;
   parameter        ID_WIDTH              = 1;
   parameter        USER_WIDTH            = 1;
   parameter        DATA_WIDTH_IN         = 32;
   parameter        DATA_WIDTH_OUT        = 32;
   parameter        CMD_FIFO_DATA_WIDTH   = 30;   
   parameter        READ_INTERLEAVE       = 1;
   parameter        TOTAL_IDS             = (2 ** ID_WIDTH);
//  input ports
   input            ACLK;
   wire             ACLK;
   input            arst_sync;
   input            srst_sync;
   wire             arst_sync;
   input            INITIATOR_AVALID;
   wire             INITIATOR_AVALID;
   input     [ID_WIDTH - 1:0] INITIATOR_AID;
   wire      [ID_WIDTH - 1:0] INITIATOR_AID;
   input     [ADDR_WIDTH - 1:0] INITIATOR_AADDR;
   wire      [ADDR_WIDTH - 1:0] INITIATOR_AADDR;
   input     [1:0]  INITIATOR_ABURST;
   wire      [1:0]  INITIATOR_ABURST;
   input     [3:0]  INITIATOR_ACACHE;
   wire      [3:0]  INITIATOR_ACACHE;
   input     [1:0]  INITIATOR_ALOCK;
   wire      [1:0]  INITIATOR_ALOCK;
   input     [2:0]  INITIATOR_ASIZE;
   wire      [2:0]  INITIATOR_ASIZE;
   input     [2:0]  INITIATOR_APROT;
   wire      [2:0]  INITIATOR_APROT;
   input     [3:0]  INITIATOR_AQOS;
   wire      [3:0]  INITIATOR_AQOS;
   input     [3:0]  INITIATOR_AREGION;
   wire      [3:0]  INITIATOR_AREGION;
   input     [USER_WIDTH - 1:0] INITIATOR_AUSER;
   wire      [USER_WIDTH - 1:0] INITIATOR_AUSER;
   input            TARGET_AREADY;
   wire             TARGET_AREADY;
//   input     [TOTAL_IDS-1:0] CmdFifoNearlyFull;
//   wire      [TOTAL_IDS-1:0] CmdFifoNearlyFull;
   input            CmdFifoNearlyFull;
   wire             CmdFifoNearlyFull;
   input            brespFifoNearlyFull;
   wire             brespFifoNearlyFull;
   input     [4:0]  to_boundary_initiator;
   wire      [4:0]  to_boundary_initiator;
   input     [5:0]  mask_addr;
   wire      [5:0]  mask_addr;
   input     [2:0]  ASIZE;
   wire      [2:0]  ASIZE;
   input     [12:0] tot_len;
   wire      [12:0] tot_len;
   input     [8:0]  max_length_comb;
   wire      [8:0]  max_length_comb;
   input     [8:0]  length_comb;
   wire      [8:0]  length_comb;
   input     [2:0]  WrapLogLen_comb;
   wire      [2:0]  WrapLogLen_comb;
   input     [5:0]  SizeMax;
   wire      [5:0]  SizeMax;
   input            SameInitrTrgtSize;
   wire             SameInitrTrgtSize;
   input     [5:0]  sizeCnt_comb;
   wire      [5:0]  sizeCnt_comb;
   input     [ADDR_WIDTH - 1:0] INITIATOR_AADDR_mux;
   wire      [ADDR_WIDTH - 1:0] INITIATOR_AADDR_mux;
   input            fixed_burst;
   input     [6:0]  unaligned_fixed_len_iter;
//  output ports
   output           INITIATOR_AREADY;
   reg              INITIATOR_AREADY;
   output    [7:0]  TARGET_ALEN;
   reg       [7:0]  TARGET_ALEN;
   output           TARGET_AVALID;
   reg              TARGET_AVALID;
   output    [ID_WIDTH - 1:0] TARGET_AID;
   reg       [ID_WIDTH - 1:0] TARGET_AID;
   output    [ADDR_WIDTH - 1:0] TARGET_AADDR;
   reg       [ADDR_WIDTH - 1:0] TARGET_AADDR;
   output    [1:0]  TARGET_ABURST;
   reg       [1:0]  TARGET_ABURST;
   output    [3:0]  TARGET_ACACHE;
   reg       [3:0]  TARGET_ACACHE;
   output    [1:0]  TARGET_ALOCK;
   reg       [1:0]  TARGET_ALOCK;
   output    [2:0]  TARGET_ASIZE;
   reg       [2:0]  TARGET_ASIZE;
   output    [2:0]  TARGET_APROT;
   reg       [2:0]  TARGET_APROT;
   output    [3:0]  TARGET_AQOS;
   reg       [3:0]  TARGET_AQOS;
   output    [3:0]  TARGET_AREGION;
   reg       [3:0]  TARGET_AREGION;
   output    [USER_WIDTH - 1:0] TARGET_AUSER;
   reg       [USER_WIDTH - 1:0] TARGET_AUSER;
   output           FifoWe;
   wire             FifoWe;
   output    [CMD_FIFO_DATA_WIDTH - 1:0] CmdFifoWrData;
   reg       [CMD_FIFO_DATA_WIDTH - 1:0] CmdFifoWrData;
   output    [ID_WIDTH:0] brespFifoWrData;
   wire      [ID_WIDTH:0] brespFifoWrData;
//  local signals
   reg       [14:0] incr_addr;
   wire      [ADDR_WIDTH - 1:0] next_addr;
   reg       [12:0] len_latched;
   reg       [8:0]  max_length;
   wire      [1:0]  FIXED;
   wire      [1:0]  INCR;
   wire      [1:0]  WRAP;
   wire      [ADDR_WIDTH - 1:0] aligned_addr;
   reg       [2:0]  ASIZE_reg;
   reg       [2:0]  INITIATOR_ASIZE_reg;
   reg              SameInitrTrgtSize_reg;
   reg       [5:0]  SizeMax_reg;
   wire             addr_phase_accept;
   reg              fixed_flag;
   wire      [ADDR_WIDTH - 1:0] wrap_addr;
   wire      [9:0]  mask_wrap_addr;
   reg       [2:0]  WrapLogLen_reg;
   reg       [1:0]  INITIATOR_ABURST_reg;
   wire      [3:0]  wrap_mask_shift;
   reg       [ID_WIDTH - 1:0] INITIATOR_AID_reg;
   reg       [5:0]  sizeCnt_reg;
//   reg       [TOTAL_IDS-1:0] FifoNearlyFull_reg;
//   wire      [TOTAL_IDS-1:0] FifoNearlyFull;
   reg              FifoNearlyFull_reg;
   wire             FifoNearlyFull;
   reg       [8:0]  length;
   wire      [14:0] TARGET_ALEN_P1;
   reg              full_flag;
   reg              tx_in_progress;
   wire      [8:0]  to_boundary_conv;
   wire      [7:0]  tot_axi_len;
   reg       [5:0]  mask_addr_reg;
   reg       [6:0]  unaligned_fixed_burst_count;
   reg              fixed_burst_reg;
 
   parameter SEND_TRANS  = 1'b0,
             WAIT_AVALID = 1'b1;
 
 
   reg [0:0] visual_CmdFifoWriteCtrl_current, visual_CmdFifoWriteCtrl_next;
 
   reg       [7:0]  visual_TARGET_ALEN_next;
   reg              visual_TARGET_AVALID_next;
   reg       [ID_WIDTH-1:0] visual_TARGET_AID_next;
   reg       [ADDR_WIDTH - 1:0] visual_TARGET_AADDR_next;
   reg       [1:0]  visual_TARGET_ABURST_next;
   reg       [2:0]  visual_TARGET_ASIZE_next;
   reg       [CMD_FIFO_DATA_WIDTH - 1:0] visual_CmdFifoWrData_next;
   reg       [12:0] visual_len_latched_next;
   reg       [8:0]  visual_max_length_next;
   reg       [2:0]  visual_ASIZE_reg_next;
   reg       [2:0]  visual_INITIATOR_ASIZE_reg_next;
   reg              visual_SameInitrTrgtSize_reg_next;
   reg       [5:0]  visual_SizeMax_reg_next;
   reg              visual_fixed_flag_next;
   reg       [2:0]  visual_WrapLogLen_reg_next;
   reg       [1:0]  visual_INITIATOR_ABURST_reg_next;
   reg       [ID_WIDTH - 1:0] visual_INITIATOR_AID_reg_next;
   reg       [5:0]  visual_sizeCnt_reg_next;
   reg       [8:0]  visual_length_next;
   reg              visual_full_flag_next;
   reg              visual_tx_in_progress_next;
   reg       [5:0]  visual_mask_addr_reg_next;
   reg       [6:0]  visual_unaligned_fixed_burst_count_next;
   reg              visual_fixed_burst;
 
 
   // Combinational process
   always@ (*)
   begin : CmdFifoWriteCtrl_comb
      INITIATOR_AREADY = 1'b0;
      visual_TARGET_ALEN_next = TARGET_ALEN;
      visual_TARGET_AVALID_next = TARGET_AVALID;
      visual_TARGET_AID_next = TARGET_AID;
      visual_TARGET_AADDR_next = TARGET_AADDR;
      visual_TARGET_ABURST_next = TARGET_ABURST;
      visual_TARGET_ASIZE_next = TARGET_ASIZE;
      visual_CmdFifoWrData_next = CmdFifoWrData;
      visual_len_latched_next = len_latched;
      visual_max_length_next = max_length;
      visual_ASIZE_reg_next = ASIZE_reg;
      visual_INITIATOR_ASIZE_reg_next = INITIATOR_ASIZE_reg;
      visual_SameInitrTrgtSize_reg_next = SameInitrTrgtSize_reg;
      visual_SizeMax_reg_next = SizeMax_reg;
      visual_fixed_flag_next = fixed_flag;
      visual_WrapLogLen_reg_next = WrapLogLen_reg;
      visual_INITIATOR_ABURST_reg_next = INITIATOR_ABURST_reg;
      visual_INITIATOR_AID_reg_next = INITIATOR_AID_reg;
      visual_sizeCnt_reg_next = sizeCnt_reg;
      visual_length_next = length;
      visual_full_flag_next = full_flag;
      visual_tx_in_progress_next = tx_in_progress;
      visual_mask_addr_reg_next = mask_addr_reg;
	  visual_unaligned_fixed_burst_count_next = unaligned_fixed_burst_count; 
	  visual_fixed_burst = fixed_burst_reg; 
 
      case (visual_CmdFifoWriteCtrl_current)
         SEND_TRANS:
            begin
               INITIATOR_AREADY = 1'b0;
               incr_addr = ((TARGET_ALEN_P1) << ASIZE_reg);
               if (FifoNearlyFull)
               begin
                  if (FifoWe)
                  begin
                     visual_full_flag_next = 1'b1;
                     visual_TARGET_AVALID_next = 1'b0;
                     visual_tx_in_progress_next = 1'b0;
                     if (len_latched == 0)
                     begin
                        visual_CmdFifoWriteCtrl_next = WAIT_AVALID;
                     end
                     else
                     begin
                        visual_TARGET_AADDR_next = next_addr;
                        if (len_latched > {4'b0000, max_length})
                        begin
                           visual_TARGET_ALEN_next = length[7:0] - 1'b1;
                           visual_len_latched_next = len_latched - max_length;
                           visual_CmdFifoWrData_next = {fixed_burst_reg,sizeCnt_reg, INITIATOR_AID_reg, fixed_flag, next_addr[5:0], length, ASIZE_reg, INITIATOR_ASIZE_reg, SameInitrTrgtSize_reg, SizeMax_reg, 1'b0};
                           visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                        end
                        else if((unaligned_fixed_burst_count > 1) & fixed_burst_reg)
						begin 
                           visual_TARGET_ALEN_next = length[7:0] - 1'b1;
                           visual_CmdFifoWrData_next = {fixed_burst_reg,sizeCnt_reg, INITIATOR_AID_reg, fixed_flag, next_addr[5:0], length, ASIZE_reg, INITIATOR_ASIZE_reg, SameInitrTrgtSize_reg, SizeMax_reg, 1'b0};
						   visual_unaligned_fixed_burst_count_next = unaligned_fixed_burst_count - 1'b1;
                           visual_CmdFifoWriteCtrl_next = SEND_TRANS;
						end 
						else 
                        begin
                           visual_TARGET_ALEN_next = fixed_burst_reg ? (length[7:0] - 1'b1) : (((max_length == length) ? len_latched[7:0] : length[7:0]) - 1'b1);
                           visual_len_latched_next = 0;
                           visual_CmdFifoWrData_next = {fixed_burst_reg,sizeCnt_reg, INITIATOR_AID_reg, fixed_flag, next_addr[5:0], fixed_burst_reg ? length : ((max_length == length) ? len_latched[8:0] : length), ASIZE_reg, INITIATOR_ASIZE_reg,
                                                  SameInitrTrgtSize_reg, SizeMax_reg, 1'b1};
                           visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                        end
                     end
                  end
                  else
                  begin
                     visual_TARGET_AVALID_next = ~(full_flag);
                     visual_tx_in_progress_next = ~(full_flag);
                     visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                  end
               end
               else
               begin
                  visual_full_flag_next = 1'b0;
                  visual_TARGET_AVALID_next = 1'b1;
                  visual_tx_in_progress_next = 1'b1;
                  if (tx_in_progress)
                  begin
                     if (TARGET_AREADY)
                     begin
                        if (len_latched == 0)
                        begin
                           visual_TARGET_AVALID_next = 0;
                           visual_CmdFifoWriteCtrl_next = WAIT_AVALID;
                        end
                        else
                        begin
                           visual_TARGET_AADDR_next = next_addr;
                           if (len_latched > {4'b0000, max_length})
                           begin
                              visual_TARGET_ALEN_next = length[7:0] - 1'b1;
                              visual_len_latched_next = len_latched - max_length;
                              visual_CmdFifoWrData_next = {fixed_burst_reg,sizeCnt_reg, INITIATOR_AID_reg, fixed_flag, next_addr[5:0], length, ASIZE_reg, INITIATOR_ASIZE_reg, SameInitrTrgtSize_reg, SizeMax_reg, 1'b0};
                              visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                           end
                           else if((unaligned_fixed_burst_count > 1) & fixed_burst_reg)
						   begin 
                              visual_TARGET_ALEN_next = length[7:0] - 1'b1;
                              visual_CmdFifoWrData_next = {fixed_burst_reg,sizeCnt_reg, INITIATOR_AID_reg, fixed_flag, next_addr[5:0], length, ASIZE_reg, INITIATOR_ASIZE_reg, SameInitrTrgtSize_reg, SizeMax_reg, 1'b0};
                              visual_unaligned_fixed_burst_count_next = unaligned_fixed_burst_count - 1'b1;
                              visual_CmdFifoWriteCtrl_next = SEND_TRANS;
						   end						   
                           else
                           begin
                              visual_TARGET_ALEN_next = fixed_burst_reg ? (length[7:0] - 1'b1) : (((max_length == length) ? len_latched[7:0] : length[7:0]) - 1'b1);
                              visual_len_latched_next = 0;
                              visual_CmdFifoWrData_next = {fixed_burst_reg,sizeCnt_reg, INITIATOR_AID_reg, fixed_flag, next_addr[5:0], fixed_burst_reg ? length : ((max_length == length) ? len_latched[8:0] : length), ASIZE_reg, INITIATOR_ASIZE_reg,
                                                  SameInitrTrgtSize_reg, SizeMax_reg, 1'b1};
                              visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                           end
                        end
                     end
                     else
                     begin
                        visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                     end
                  end
                  else if (FifoNearlyFull_reg)
                  begin
                     visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                  end
                  else if (TARGET_AREADY)
                  begin
                     if (len_latched == 0)
                     begin
                        visual_TARGET_AVALID_next = 0;
                        visual_CmdFifoWriteCtrl_next = WAIT_AVALID;
                     end
                     else
                     begin
                        visual_TARGET_AADDR_next = next_addr;
                        if (len_latched > {4'b0000, max_length})
                        begin
                           visual_TARGET_ALEN_next = length[7:0] - 1'b1;
                           visual_len_latched_next = len_latched - max_length;
                           visual_CmdFifoWrData_next = {fixed_burst_reg,sizeCnt_reg, INITIATOR_AID_reg, fixed_flag, next_addr[5:0], length, ASIZE_reg, INITIATOR_ASIZE_reg, SameInitrTrgtSize_reg, SizeMax_reg, 1'b0};
                           visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                        end
                        else if((unaligned_fixed_burst_count > 1) & fixed_burst_reg)
						begin 
                           visual_TARGET_ALEN_next = length[7:0] - 1'b1;
                           visual_CmdFifoWrData_next = {fixed_burst_reg,sizeCnt_reg, INITIATOR_AID_reg, fixed_flag, next_addr[5:0], length, ASIZE_reg, INITIATOR_ASIZE_reg, SameInitrTrgtSize_reg, SizeMax_reg, 1'b0};
						   visual_unaligned_fixed_burst_count_next = unaligned_fixed_burst_count - 1'b1;
                           visual_CmdFifoWriteCtrl_next = SEND_TRANS;						
						end 
                        else
                        begin
                           visual_TARGET_ALEN_next = fixed_burst_reg ? (length[7:0] - 1'b1) : (((max_length == length) ? len_latched[7:0] : length[7:0]) - 1'b1);
                           visual_len_latched_next = 0;
                           visual_CmdFifoWrData_next = {fixed_burst_reg,sizeCnt_reg, INITIATOR_AID_reg, fixed_flag, next_addr[5:0], fixed_burst_reg ? length : ((max_length == length) ? len_latched[8:0] : length), ASIZE_reg, INITIATOR_ASIZE_reg,
                                                  SameInitrTrgtSize_reg, SizeMax_reg, 1'b1};
                           visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                        end
                     end
                  end
                  else
                  begin
                     visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                  end
               end
            end
 
         WAIT_AVALID:
            begin
               if (INITIATOR_AVALID)
               begin
                  if (FifoNearlyFull)
                  begin
                     visual_CmdFifoWrData_next = 0;
                     visual_TARGET_AVALID_next = 0;
                     visual_full_flag_next = FifoNearlyFull;
                     visual_tx_in_progress_next = 1'b0;
                     INITIATOR_AREADY = 1'b0;
                     incr_addr = 0;
                     visual_CmdFifoWriteCtrl_next = WAIT_AVALID;
                  end
                  else
                  begin
                     visual_full_flag_next = 1'b0;
                     visual_tx_in_progress_next = 1'b1;
                     visual_TARGET_ASIZE_next = ASIZE;
					 visual_TARGET_AID_next = INITIATOR_AID;
                     visual_TARGET_AADDR_next = INITIATOR_AADDR_mux;
                     visual_TARGET_AVALID_next = 1;
                     INITIATOR_AREADY = 1'b1;
                     visual_ASIZE_reg_next = ASIZE;
                     visual_INITIATOR_ASIZE_reg_next = INITIATOR_ASIZE;
                     visual_INITIATOR_ABURST_reg_next = INITIATOR_ABURST;
                     visual_SizeMax_reg_next = SizeMax;
                     visual_SameInitrTrgtSize_reg_next = SameInitrTrgtSize;
                     visual_WrapLogLen_reg_next = WrapLogLen_comb;
                     visual_INITIATOR_AID_reg_next = INITIATOR_AID;
                     visual_sizeCnt_reg_next = sizeCnt_comb;
                     incr_addr = ((TARGET_ALEN_P1) << ASIZE);
                     visual_mask_addr_reg_next = mask_addr;
                     visual_fixed_burst = fixed_burst;
                     if (INITIATOR_ABURST == WRAP)
                     begin
                        visual_TARGET_ALEN_next = to_boundary_conv[7:0] - 1'b1;
                        visual_len_latched_next = tot_len - to_boundary_conv;
                        visual_fixed_flag_next = 1'b0;
                        visual_TARGET_ABURST_next = INCR;
                        visual_CmdFifoWrData_next = {1'b0,sizeCnt_comb, INITIATOR_AID, 1'b0, INITIATOR_AADDR[5:0], to_boundary_conv, ASIZE, INITIATOR_ASIZE, SameInitrTrgtSize, SizeMax, (tot_len == {4'b0000, to_boundary_conv})};
                        visual_max_length_next = max_length_comb;
                        visual_length_next = length_comb;
                        visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                     end
                     else if (SameInitrTrgtSize)
                     begin
                        visual_fixed_flag_next = (INITIATOR_ABURST == FIXED);
                        visual_len_latched_next = 0;
                        visual_TARGET_ALEN_next = tot_axi_len;
                        visual_TARGET_ABURST_next = INITIATOR_ABURST;
                        visual_CmdFifoWrData_next = {fixed_burst,sizeCnt_comb, INITIATOR_AID, (INITIATOR_ABURST == FIXED), INITIATOR_AADDR[5:0], tot_len[8:0], ASIZE, INITIATOR_ASIZE, SameInitrTrgtSize, SizeMax, 1'b1};
                        visual_max_length_next = 9'h0;
                        visual_length_next = 9'h0;
                        visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                     end
                     else
                     begin
                        visual_fixed_flag_next = 1'b0;
                        if (INITIATOR_ABURST == FIXED)
                        begin
                           visual_TARGET_ALEN_next = length_comb[7:0] - 1'b1;
                           visual_len_latched_next = (unaligned_fixed_len_iter == 1) ? 13'd0 : {4'b0000, max_length_comb};
                           visual_TARGET_ABURST_next = INITIATOR_ABURST;
                           visual_CmdFifoWrData_next = {fixed_burst,sizeCnt_comb, INITIATOR_AID, 1'b0, INITIATOR_AADDR_mux[5:0], length_comb, ASIZE, INITIATOR_ASIZE, SameInitrTrgtSize, SizeMax, (unaligned_fixed_len_iter == 1)};
                           visual_max_length_next = max_length_comb;
                           visual_length_next = length_comb;
						   visual_unaligned_fixed_burst_count_next = unaligned_fixed_len_iter - 1'b1;
                           visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                        end
                        else if (tot_len > {4'b0000, max_length_comb})
                        begin
                           visual_TARGET_ALEN_next = length_comb[7:0] - 1'b1;
                           visual_len_latched_next = tot_len - max_length_comb;
                           visual_TARGET_ABURST_next = INITIATOR_ABURST;
                           visual_CmdFifoWrData_next = {fixed_burst,sizeCnt_comb, INITIATOR_AID, 1'b0, INITIATOR_AADDR_mux[5:0], length_comb, ASIZE, INITIATOR_ASIZE, SameInitrTrgtSize, SizeMax, (tot_len == {4'b0000, max_length_comb})};
                           visual_max_length_next = max_length_comb;
                           visual_length_next = length_comb;
                           visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                        end
                        else
                        begin
                           visual_len_latched_next = 0;
                           visual_TARGET_ALEN_next = tot_axi_len;
                           visual_TARGET_ABURST_next = INITIATOR_ABURST;
                           visual_CmdFifoWrData_next = {fixed_burst,sizeCnt_comb, INITIATOR_AID, (INITIATOR_ABURST == FIXED), INITIATOR_AADDR[5:0], tot_len[8:0], ASIZE, INITIATOR_ASIZE, SameInitrTrgtSize, SizeMax, 1'b1};
                           visual_max_length_next = 9'h0;
                           visual_length_next = 9'h0;
                           visual_CmdFifoWriteCtrl_next = SEND_TRANS;
                        end
                     end
                  end
               end
               else
               begin
                  visual_CmdFifoWrData_next = 0;
                  visual_TARGET_AVALID_next = 0;
                  visual_full_flag_next = FifoNearlyFull;
                  visual_tx_in_progress_next = 1'b0;
                  INITIATOR_AREADY = 1'b0;
                  incr_addr = 0;
                  visual_CmdFifoWriteCtrl_next = WAIT_AVALID;
               end
            end
 
         default:
            begin
               visual_CmdFifoWriteCtrl_next = WAIT_AVALID;
            end
      endcase
   end
 
   always@(posedge ACLK or negedge arst_sync)
   begin : CmdFifoWriteCtrl
 
      if (~arst_sync | ~srst_sync)
      begin
         TARGET_ASIZE <= 0;
         TARGET_AADDR <= 0;
         TARGET_AVALID <= 0;
         ASIZE_reg <= 0;
         INITIATOR_ASIZE_reg <= 0;
         INITIATOR_ABURST_reg <= 0;
         SizeMax_reg <= 0;
         SameInitrTrgtSize_reg <= 0;
         WrapLogLen_reg <= 0;
         len_latched <= 0;
         TARGET_ALEN <= 0;
         TARGET_ABURST <= 0;
         CmdFifoWrData <= 0;
         max_length <= 0;
         fixed_flag <= 0;
         INITIATOR_AID_reg <= 0;
         sizeCnt_reg <= 0;
		 length <= 9'd0;
         full_flag <= 1'b0;
         tx_in_progress <= 1'b0;
         mask_addr_reg <= 0;
         visual_CmdFifoWriteCtrl_current <= WAIT_AVALID;
         unaligned_fixed_burst_count <= 0;
         fixed_burst_reg <= 0;
      end
      else
      begin
         TARGET_ALEN <= visual_TARGET_ALEN_next;
         TARGET_AVALID <= visual_TARGET_AVALID_next;
         TARGET_AADDR <= visual_TARGET_AADDR_next;
         TARGET_ABURST <= visual_TARGET_ABURST_next;
         TARGET_ASIZE <= visual_TARGET_ASIZE_next;
         CmdFifoWrData <= visual_CmdFifoWrData_next;
         len_latched <= visual_len_latched_next;
         max_length <= visual_max_length_next;
         ASIZE_reg <= visual_ASIZE_reg_next;
         INITIATOR_ASIZE_reg <= visual_INITIATOR_ASIZE_reg_next;
         SameInitrTrgtSize_reg <= visual_SameInitrTrgtSize_reg_next;
         SizeMax_reg <= visual_SizeMax_reg_next;
         fixed_flag <= visual_fixed_flag_next;
         WrapLogLen_reg <= visual_WrapLogLen_reg_next;
         INITIATOR_ABURST_reg <= visual_INITIATOR_ABURST_reg_next;
         INITIATOR_AID_reg <= visual_INITIATOR_AID_reg_next;
         sizeCnt_reg <= visual_sizeCnt_reg_next;
         length <= visual_length_next;
         full_flag <= visual_full_flag_next;
         tx_in_progress <= visual_tx_in_progress_next;
         mask_addr_reg <= visual_mask_addr_reg_next;
         visual_CmdFifoWriteCtrl_current <= visual_CmdFifoWriteCtrl_next;
		 unaligned_fixed_burst_count <= visual_unaligned_fixed_burst_count_next;
		 fixed_burst_reg  <= visual_fixed_burst;
      end
   end
 
 
 
   always@( posedge ACLK or negedge arst_sync )
   begin   :AChan_unchanged_sigs
 
      if (~arst_sync | ~srst_sync)
      begin
         TARGET_ALOCK <= 0;
         TARGET_APROT <= 0;
         TARGET_AUSER <= 0;
         TARGET_AREGION <= 0;
         TARGET_AQOS <= 0;
         TARGET_ACACHE <= 0;
      end
      else
      begin
         if (addr_phase_accept)
         begin
            TARGET_ALOCK <= INITIATOR_ALOCK;
            TARGET_APROT <= INITIATOR_APROT;
            TARGET_AUSER <= INITIATOR_AUSER;
            TARGET_AREGION <= INITIATOR_AREGION;
            TARGET_AQOS <= INITIATOR_AQOS;
            TARGET_ACACHE <= INITIATOR_ACACHE;
         end
      end
   end
 
 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :CmdFifoFull_register
 
      if (~arst_sync | ~srst_sync)
      begin
         FifoNearlyFull_reg <= 0;
      end
      else
      begin
         FifoNearlyFull_reg <= FifoNearlyFull;
      end
   end
 
   // force the target to process transaction in order. It reduces the memory resources required in the converters
   //assign TARGET_AID = READ_INTERLEAVE ? INITIATOR_AID : {ID_WIDTH{1'b0}} ;
   
   always@(posedge ACLK or negedge arst_sync)
     begin
       if (~arst_sync | ~srst_sync)
	     TARGET_AID <= {ID_WIDTH{1'b0}};
	   else if(READ_INTERLEAVE)
         TARGET_AID   <= visual_TARGET_AID_next;
	   else  
	     TARGET_AID   <= {ID_WIDTH{1'b0}};
     end
 
    assign TARGET_ALEN_P1 = {7'b0000000, TARGET_ALEN} + 1'b1;
   assign wrap_mask_shift = (INITIATOR_ASIZE_reg+WrapLogLen_reg);
   assign mask_wrap_addr = (10'h3ff << wrap_mask_shift);
   assign wrap_addr = {TARGET_AADDR[ADDR_WIDTH-1:10], (TARGET_AADDR[9:0] & mask_wrap_addr)};
 
   // next address computation.
   // FIXED burst: address unchanged
   // INCR burst: address incremented by the number of byte written during the burst
   // WRAP burst: align the address to the lower wrap boundary
   assign next_addr = (INITIATOR_ABURST_reg == FIXED) ? TARGET_AADDR:
       ((INITIATOR_ABURST_reg == INCR) ? (aligned_addr + incr_addr) : wrap_addr);
 
   assign aligned_addr = {TARGET_AADDR[ADDR_WIDTH-1:6], (TARGET_AADDR[5:0] & mask_addr_reg)};
 
   assign FIXED = 2'b00;
   assign INCR = 2'b01;
   assign WRAP = 2'b10;
 
   assign addr_phase_accept = INITIATOR_AREADY & INITIATOR_AVALID;
 
   assign FifoWe = TARGET_AVALID & TARGET_AREADY;
   assign brespFifoWrData = {INITIATOR_AID_reg, CmdFifoWrData[0]};
 
   assign FifoNearlyFull = (brespFifoNearlyFull | CmdFifoNearlyFull);
 
    assign tot_axi_len = tot_len[7:0] - 1'b1;
    assign to_boundary_conv = {4'b0000, to_boundary_initiator} << (INITIATOR_ASIZE-ASIZE);
 
 
endmodule
