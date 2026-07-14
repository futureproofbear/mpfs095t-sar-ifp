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
 
module caxi4interconnect_DWC_UpConv_AChannel (
                            //  input ports
                            ACLK,
                            arst_sync,
                            srst_sync,
                            INITIATOR_ALEN,
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
                            fifoFull,
                            to_boundary_initiator_pre,
                            mask_wrap_addr_pre,
                            sizeDiff_pre,
                            unaligned_wrap_burst_comb_pre,
                            len_offset_pre,
                            wrap_tx_pre,
                            fixed_flag_comb_pre,
                            alen_sec_wrap_pre,
                            alen_wrap_pre,
 
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
                            extend_tx,
                            wr_en_cmd,
                            addr_fifo,
                            asize_intr,
                            alen_intr,
                            wrap_flag,
                            fixed_flag,
                            last_beat_wrap,
                            unaligned_wrap_burst,
                            aid_intr
                            );
 
   parameter        ADDR_WIDTH                      = 20;
   parameter        ID_WIDTH                        = 1;
   parameter        USER_WIDTH                      = 1;
   parameter        DATA_WIDTH_IN                   = 32;
   parameter        DATA_WIDTH_OUT                  = 32;
   parameter        CMD_FIFO_DATA_WIDTH             = 30;
   parameter        TOTAL_IDS                       = (2 ** ID_WIDTH);
   parameter        READ_INTERLEAVE                 = 0;
//  input ports
   input            ACLK;
   wire             ACLK;
   input            arst_sync;
   input            srst_sync;
   wire             arst_sync;
   input     [7:0]  INITIATOR_ALEN;
   wire      [7:0]  INITIATOR_ALEN;
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
   input     [TOTAL_IDS-1:0] fifoFull;
   wire      [TOTAL_IDS-1:0] fifoFull;
   input     [4:0]  to_boundary_initiator_pre;
   wire      [4:0]  to_boundary_initiator_pre;
   input     [9:0]  mask_wrap_addr_pre;
   wire      [9:0]  mask_wrap_addr_pre;
   input     [2:0]  sizeDiff_pre;
   wire      [2:0]  sizeDiff_pre;
   input            unaligned_wrap_burst_comb_pre;
   wire             unaligned_wrap_burst_comb_pre;
   input     [5:0]  len_offset_pre;
   wire      [5:0]  len_offset_pre;
   input            wrap_tx_pre;
   wire             wrap_tx_pre;
   input            fixed_flag_comb_pre;
   wire             fixed_flag_comb_pre;
   input     [7:0]  alen_sec_wrap_pre;
   wire      [7:0]  alen_sec_wrap_pre;
   input     [7:0]  alen_wrap_pre;
   wire      [7:0]  alen_wrap_pre;
//  output ports
   output           INITIATOR_AREADY;
   reg              INITIATOR_AREADY;
   output    [7:0]  TARGET_ALEN;
   reg       [7:0]  TARGET_ALEN;
   output           TARGET_AVALID;
   reg              TARGET_AVALID;
   output    [ID_WIDTH - 1:0] TARGET_AID;
   wire      [ID_WIDTH - 1:0] TARGET_AID;
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
   output           extend_tx;
   reg              extend_tx;
   output           wr_en_cmd;
   wire             wr_en_cmd;
   output    [5:0]  addr_fifo;
   reg       [5:0]  addr_fifo;
   output    [2:0]  asize_intr;
   reg       [2:0]  asize_intr;
   output    [7:0]  alen_intr;
   reg       [7:0]  alen_intr;
   output           wrap_flag;
   reg              wrap_flag;
   output           fixed_flag;
   reg              fixed_flag;
   output    [4:0]  last_beat_wrap;
   reg       [4:0]  last_beat_wrap;
   output           unaligned_wrap_burst;
   reg              unaligned_wrap_burst;
   output    [ID_WIDTH - 1:0] aid_intr;
   reg       [ID_WIDTH - 1:0] aid_intr;
//  local signals
   wire      [1:0]  WRAP;
   reg       [4:0]  to_boundary_initiator;
   reg       [4:0]  to_boundary_initiator_reg;
   wire      [7:0]  alen_int;
   wire      [8:0]  alen_tot;
   wire      [7:0]  alen_wrap;
   wire      [7:0]  alen_sec_wrap;
   wire      [7:0]  wrap_alen_out;
   wire      [7:0]  alen_out;
   reg       [5:0]  len_offset;
   reg       [5:0]  len_offset_reg;
   reg       [9:0]  mask_wrap_addr;
   reg              unaligned_wrap_burst_comb;
   reg       [2:0]  sizeDiff_reg;
   reg       [2:0]  sizeDiff;
   wire             addr_phase_accept;
   reg              wrap_tx;
   reg       [9:0]  mask_wrap_addr_reg;
   reg       [7:0]  INITIATOR_ALEN_int;
   reg              fixed_flag_comb;
   reg              wait_avalid_state;
   reg       [7:0]  alen_sec_wrap_reg;
   reg       [7:0]  alen_wrap_reg;
 
   parameter SEND_TRANS  = 1'b0,
             WAIT_AVALID = 1'b1;
 
 
   reg [0:0] visual_AChan_FSM_current, visual_AChan_FSM_next;
 
   reg       [7:0]  visual_TARGET_ALEN_next;
   reg              visual_TARGET_AVALID_next;
   reg       [ID_WIDTH-1:0] visual_TARGET_AID_next;
   reg       [ADDR_WIDTH - 1:0] visual_TARGET_AADDR_next;
   reg       [1:0]  visual_TARGET_ABURST_next;
   reg       [2:0]  visual_TARGET_ASIZE_next;
   reg              visual_extend_tx_next;
   reg       [5:0]  visual_addr_fifo_next;
   reg       [2:0]  visual_asize_intr_next;
   reg       [7:0]  visual_alen_intr_next;
   reg              visual_wrap_flag_next;
   reg       [ID_WIDTH - 1:0] visual_aid_intr_next;
   
   wire             fifoFull_Ctrl = READ_INTERLEAVE ? fifoFull[INITIATOR_AID] : fifoFull;
   
   reg       [ID_WIDTH - 1:0] TARGET_AID_REG;
 
 
   // Combinational process
   always@(*)
   //always  @(TARGET_ALEN or TARGET_AVALID or TARGET_AADDR or TARGET_ABURST or TARGET_ASIZE or extend_tx or addr_fifo or asize_intr or alen_intr or wrap_flag or aid_intr or TARGET_AREADY or mask_wrap_addr or
   //          alen_out or INITIATOR_AVALID or fifoFull or INITIATOR_AADDR or unaligned_wrap_burst_comb or INITIATOR_ABURST or WRAP or INITIATOR_ASIZE or INITIATOR_ALEN or INITIATOR_AID or fixed_flag_comb or
   //          visual_AChan_FSM_current)
   begin : AChan_FSM_comb
      INITIATOR_AREADY = 1'b0;
      visual_TARGET_ALEN_next = TARGET_ALEN;
      visual_TARGET_AVALID_next = TARGET_AVALID;
      visual_TARGET_AADDR_next = TARGET_AADDR;
      visual_TARGET_ABURST_next = TARGET_ABURST;
      visual_TARGET_ASIZE_next = TARGET_ASIZE;
      visual_TARGET_AID_next = TARGET_AID;
      visual_extend_tx_next = extend_tx;
      visual_addr_fifo_next = addr_fifo;
      visual_asize_intr_next = asize_intr;
      visual_alen_intr_next = alen_intr;
      visual_wrap_flag_next = wrap_flag;
      visual_aid_intr_next = aid_intr;
      wait_avalid_state = 0;
 
 
 
      case (visual_AChan_FSM_current)
         SEND_TRANS:
            begin
               INITIATOR_AREADY = 1'b0;
               if (TARGET_AREADY)
               begin
                  if (extend_tx)
                  begin
                     visual_TARGET_AVALID_next = 1;
                     visual_TARGET_AADDR_next = {TARGET_AADDR[ADDR_WIDTH - 1:10], (TARGET_AADDR[9:0] & ~(mask_wrap_addr))};
                     visual_TARGET_ALEN_next = alen_out;
                     visual_TARGET_ABURST_next = 2'b01;
                     visual_addr_fifo_next = TARGET_AADDR[5:0] & ~(mask_wrap_addr[5:0]);
                     visual_extend_tx_next = 1'b0;
                     visual_TARGET_ASIZE_next = $clog2 (DATA_WIDTH_OUT / 8);
                     visual_AChan_FSM_next = SEND_TRANS;
                  end
                  else
                  begin
                     visual_TARGET_AVALID_next = 0;
                     visual_AChan_FSM_next = WAIT_AVALID;
                  end
               end
               else
               begin
                  visual_TARGET_AVALID_next = 1'b1;
                  visual_AChan_FSM_next = SEND_TRANS;
               end
            end
 
         WAIT_AVALID:
            begin
               wait_avalid_state = 1;
               if (INITIATOR_AVALID)
               begin
                  if (fifoFull_Ctrl)
                  begin
                     visual_TARGET_AVALID_next = 0;
                     visual_AChan_FSM_next = WAIT_AVALID;
                  end
                  else
                  begin
                     visual_TARGET_AADDR_next = INITIATOR_AADDR;
                     visual_TARGET_ALEN_next = alen_out;
                     visual_TARGET_AVALID_next = 1'b1;
					 visual_TARGET_AID_next    = INITIATOR_AID;
                     INITIATOR_AREADY = 1'b1;
                     visual_addr_fifo_next = INITIATOR_AADDR[5:0];
                     visual_extend_tx_next = unaligned_wrap_burst_comb & (INITIATOR_ABURST == WRAP);
                     visual_asize_intr_next = INITIATOR_ASIZE;
                     visual_alen_intr_next = INITIATOR_ALEN;
                     visual_aid_intr_next = INITIATOR_AID;
                     visual_TARGET_ASIZE_next = (fixed_flag_comb) ? INITIATOR_ASIZE : $clog2 (DATA_WIDTH_OUT / 8);
                     if (INITIATOR_ABURST == WRAP)
                     begin
                        visual_TARGET_ABURST_next = 2'b01;
                        visual_wrap_flag_next = 1'b1;
                        visual_AChan_FSM_next = SEND_TRANS;
                     end
                     else
                     begin
                        visual_TARGET_ABURST_next = INITIATOR_ABURST;
                        visual_wrap_flag_next = 1'b0;
                        visual_AChan_FSM_next = SEND_TRANS;
                     end
                  end
               end
               else
               begin
                  visual_TARGET_AVALID_next = 0;
                  visual_AChan_FSM_next = WAIT_AVALID;
               end
            end
 
         default:
            begin
               visual_AChan_FSM_next = WAIT_AVALID;
            end
      endcase
   end
 
   always  @(posedge ACLK or negedge arst_sync)
   begin : AChan_FSM
 
      if (~arst_sync | ~srst_sync)
      begin
         TARGET_ABURST <= 2'b00;
         TARGET_AADDR <= 0;
         TARGET_AVALID <= 0;
         TARGET_ALEN <= 0;
         TARGET_ASIZE <= 0;
         addr_fifo <= 0;
         extend_tx <= 0;
         asize_intr <= 0;
         alen_intr <= 0;
		 wrap_flag <= 0;
		 aid_intr <= 0;
         visual_AChan_FSM_current <= WAIT_AVALID;
      end
      else
      begin
         TARGET_ABURST <= visual_TARGET_ABURST_next;
		 TARGET_AADDR <= visual_TARGET_AADDR_next;
		 TARGET_AVALID <= visual_TARGET_AVALID_next;
		 TARGET_ALEN <= visual_TARGET_ALEN_next;         
         TARGET_ASIZE <= visual_TARGET_ASIZE_next;
         addr_fifo <= visual_addr_fifo_next;
         extend_tx <= visual_extend_tx_next;
         asize_intr <= visual_asize_intr_next;
         alen_intr <= visual_alen_intr_next;
         wrap_flag <= visual_wrap_flag_next;
         aid_intr <= visual_aid_intr_next;
         visual_AChan_FSM_current <= visual_AChan_FSM_next;
      end
   end
 
 
 
   always
      @( posedge ACLK or negedge arst_sync )
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
 
 
 
   always
      @( posedge ACLK or negedge arst_sync )
   begin   :ctrl_sigs_reg
 
      if (~arst_sync | ~srst_sync)
      begin
         to_boundary_initiator_reg <= 0;
         sizeDiff_reg <= 0;
         unaligned_wrap_burst <= 0;
         len_offset_reg <= 0;
         last_beat_wrap <= 0;
         mask_wrap_addr_reg <= 0;
         fixed_flag  <= 1'b0;
         alen_sec_wrap_reg <= 0;
         alen_wrap_reg <= 0;
      end
      else
      begin
         to_boundary_initiator_reg <= to_boundary_initiator;
         sizeDiff_reg <= sizeDiff;
         unaligned_wrap_burst <= unaligned_wrap_burst_comb;
         len_offset_reg <= len_offset;
         last_beat_wrap <= to_boundary_initiator - 1'b1;
         mask_wrap_addr_reg <= mask_wrap_addr;
         fixed_flag <= fixed_flag_comb;
         alen_sec_wrap_reg <= (visual_alen_intr_next - {3'b000, to_boundary_initiator}) >> sizeDiff;
         alen_wrap_reg <= (({3'b000, to_boundary_initiator} - 8'b1) >>  sizeDiff);
      end
   end
 
 
 
   always  @(*)
   begin   :comb
 
      if (wait_avalid_state)
      begin
         to_boundary_initiator =  to_boundary_initiator_pre;
         mask_wrap_addr = mask_wrap_addr_pre;
         sizeDiff = sizeDiff_pre;
         unaligned_wrap_burst_comb = unaligned_wrap_burst_comb_pre;
         INITIATOR_ALEN_int = INITIATOR_ALEN;
         len_offset = len_offset_pre;
         wrap_tx = wrap_tx_pre;
         fixed_flag_comb = fixed_flag_comb_pre;
      end
      else
      begin
         to_boundary_initiator = to_boundary_initiator_reg;
         mask_wrap_addr = mask_wrap_addr_reg;
         sizeDiff =  sizeDiff_reg;
         unaligned_wrap_burst_comb = unaligned_wrap_burst;
         INITIATOR_ALEN_int = alen_intr;
         len_offset = len_offset_reg;
         wrap_tx = extend_tx;
         fixed_flag_comb = fixed_flag;
      end
   end
 
   // use initiator address when INITIATOR_AVALID is asserted otherwise use the latched version
 
   assign wr_en_cmd = TARGET_AVALID & TARGET_AREADY; 
   assign alen_tot = (INITIATOR_ALEN_int + len_offset);
   //assign alen_wrap = ((to_boundary_initiator - 1) >>  sizeDiff);
   assign alen_wrap = wait_avalid_state ? alen_wrap_pre : alen_wrap_reg;
   //assign alen_sec_wrap = (INITIATOR_ALEN_int - to_boundary_initiator)  >>  sizeDiff;
   assign alen_sec_wrap = wait_avalid_state ? alen_sec_wrap_pre : alen_sec_wrap_reg;
   assign wrap_alen_out = (extend_tx ? alen_sec_wrap : alen_wrap );
   assign alen_int = (fixed_flag_comb) ? INITIATOR_ALEN_int : (alen_tot  >>  sizeDiff);
   // assign the number of beats left to reach the wrap boundary to alen_out for the first address phase of a wrap burst
   // assign 0 to alen_out for the second address phase of a wrap burst
   // assign the converted length (alen_int) to alen_out in case of INCR or FIXED
   assign alen_out = ((wrap_tx) ? wrap_alen_out : alen_int);
 
   assign addr_phase_accept = INITIATOR_AVALID & INITIATOR_AREADY;
 
   // force the target to process transaction in order. It reduces the memory resources required in the converters  
   
   //assign TARGET_AID = 0;
 
   generate 
     if(READ_INTERLEAVE)
	   begin 
	     always @(posedge ACLK or negedge arst_sync)
           if (~arst_sync | ~srst_sync)		 
		     TARGET_AID_REG <= {ID_WIDTH{1'b0}};
		   else 
		     TARGET_AID_REG <= visual_TARGET_AID_next;
	    
		  assign TARGET_AID = TARGET_AID_REG;
	   end 
	 else 
	   begin 
         assign TARGET_AID = 0;
	   end 
   endgenerate
   assign WRAP = 2'b10; 
endmodule

