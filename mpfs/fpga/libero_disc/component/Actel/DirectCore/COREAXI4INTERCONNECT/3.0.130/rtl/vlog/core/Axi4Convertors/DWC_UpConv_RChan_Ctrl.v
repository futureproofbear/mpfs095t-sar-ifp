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
 
 
module caxi4interconnect_DWC_UpConv_RChan_Ctrl (
                              //  input ports
                              INITIATOR_RREADY,
                              INITIATOR_RLEN,
                              INITIATOR_RSIZE,
                              ACLK,
                              arst_sync,
                              srst_sync,
                              data_empty,
                              TARGET_RLAST,
                              TARGET_RVALID,
                              addr,
                              arid,
                              space_in_data_fifo,
                              //space_in_rresp_fifo,
                              fixed_flag,
                              wrap_flag,
                              to_wrap_boundary,
                              INITIATOR_RLEN_eq_0,
                              mask_pre,
                              rd_src_shift_pre,
                              rd_src_top,
 
                              //  output ports
                              INITIATOR_RLAST,
                              INITIATOR_RVALID,
                              rd_src,
                              rd_en_data,
                              data_hold,
                              TARGET_RREADY,
                              rd_en_cmd,
                              INITIATOR_RID
                              );
 
   parameter        DATA_WIDTH_IN         = 512;
   parameter        DATA_WIDTH_OUT        = 32;
   parameter        ID_WIDTH              = 1;
//  input ports
   input            INITIATOR_RREADY;
   wire             INITIATOR_RREADY;
   input     [7:0]  INITIATOR_RLEN;
   wire      [7:0]  INITIATOR_RLEN;
   input     [2:0]  INITIATOR_RSIZE;
   wire      [2:0]  INITIATOR_RSIZE;
   input            ACLK;
   wire             ACLK;
   input            arst_sync;
   input            srst_sync;
   wire             arst_sync;
   input            data_empty;
   wire             data_empty;
   input            TARGET_RLAST;
   wire             TARGET_RLAST;
   input            TARGET_RVALID;
   wire             TARGET_RVALID;
   input     [9:0]  addr;
   wire      [9:0]  addr;
   input     [ID_WIDTH - 1:0] arid;
   wire      [ID_WIDTH - 1:0] arid;
   input            space_in_data_fifo;
   wire             space_in_data_fifo;
   //input            space_in_rresp_fifo;
   //wire             space_in_rresp_fifo;
   input            fixed_flag;
   wire             fixed_flag;
   input            wrap_flag;
   wire             wrap_flag;
   input     [4:0]  to_wrap_boundary;
   wire      [4:0]  to_wrap_boundary;
   input            INITIATOR_RLEN_eq_0;
   wire             INITIATOR_RLEN_eq_0;
   input     [9:0]  mask_pre;
   wire      [9:0]  mask_pre;
   input     [9:0]  rd_src_shift_pre;
   wire      [9:0]  rd_src_shift_pre;
   input     [5:0]  rd_src_top;
   wire      [5:0]  rd_src_top;
//  output ports
   output           INITIATOR_RLAST;
   reg              INITIATOR_RLAST;
   output           INITIATOR_RVALID;
   wire             INITIATOR_RVALID;
   output    [$clog2 (DATA_WIDTH_IN / DATA_WIDTH_OUT) - 1:0] rd_src;
   wire      [$clog2 (DATA_WIDTH_IN / DATA_WIDTH_OUT) - 1:0] rd_src;
   output           rd_en_data;
   wire             rd_en_data;
   output           data_hold;
   wire             data_hold;
   output           TARGET_RREADY;
   reg              TARGET_RREADY;
   output           rd_en_cmd;
   reg              rd_en_cmd;
   output    [ID_WIDTH - 1:0] INITIATOR_RID;
   reg       [ID_WIDTH - 1:0] INITIATOR_RID;
//  local signals
   wire             last_next;
   reg       [8:0]  initiator_beat_cnt;
   wire             data_out_valid;
   wire             pass_data;
   reg              hold_data_valid;
   wire             incr_rd_src;
   wire             initiator_accept;
   reg       [9:0]  rd_src_cnt;
   wire             zero_src;
   wire      [5:0]  rd_src_full;
   wire      [5:0]  rd_src_data;
   wire      [9:0]  inc_value;
   reg              fixed_flag_comb;
   reg              fixed_flag_reg;
   wire             wrap_reach_boundary;
   wire             rd_msb;
   wire             end_cycle;
   wire             wrap_point;
   wire      [9:0]  mask_wrap_addr;
   wire             set_initiator_rlast;
   wire             data_fifo_rd_ok;
   reg              extend_wrap_tx;
   wire             set_extend;
   wire             mux_top;
   reg       [9:0]  mask_wrap_addr_reg;
   wire      [9:0]  log_wrap_len;
   wire      [9:0]  shift_wrap_mask;
   reg       [8:0]  next_initiator_beat_cnt;
   wire             clear_extend;
   reg       [8:0]  initiator_beat_cnt_plus_1;
 
 
   always@( posedge ACLK or negedge arst_sync )
   begin   :clk_rst_ctrl
 
      if (~arst_sync | ~srst_sync)
      begin
         TARGET_RREADY <= 0;
      end
      else
      begin
         TARGET_RREADY <= (space_in_data_fifo);
                           //& space_in_rresp_fifo); Removed response fifo so no use of this signal. 
      end
   end
 
 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :clk_reg_RD_SYS
 
      if (~arst_sync | ~srst_sync)
      begin
         hold_data_valid <= 0;
         INITIATOR_RID <= 0;
      end
      else
      begin
         if (pass_data)
         begin
            hold_data_valid <= data_out_valid;
            INITIATOR_RID <= arid;
         end
      end
   end
 
 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :intr_beat_cnt_ctrl
 
      if (~arst_sync | ~srst_sync)
      begin
         initiator_beat_cnt <= 0;
         initiator_beat_cnt_plus_1 <= 9'd1;
      end
      else
      begin
         initiator_beat_cnt <= next_initiator_beat_cnt;
         initiator_beat_cnt_plus_1 <= next_initiator_beat_cnt + 9'd1;
      end
   end
 
 
 
 
 
   always@( posedge ACLK or negedge arst_sync )
   begin   :src_ctrl
 
      if (~arst_sync | ~srst_sync)
      begin
         rd_src_cnt <= 0;
      end
      else
      begin
         if (zero_src)
         begin
            rd_src_cnt <= 0;
         end
         else
         begin
            if (incr_rd_src)
            begin
               rd_src_cnt <=
               rd_src_cnt + inc_value;
            end
         end
      end
   end
 
 
 
   always@(*)
   begin   :rlast_next_gen
 
      if (INITIATOR_RLAST)
      begin
         if (initiator_accept)
         begin
            if (last_next)
            begin
               if (data_out_valid)
               begin
                  rd_en_cmd = 1'b1;
               end
               else
               begin
                  rd_en_cmd = 1'b0;
               end
            end
            else
            begin
               rd_en_cmd = 1'b0;
            end
         end
         else
         begin
            rd_en_cmd = 1'b0;
         end
      end
      else
      begin
         if (last_next)
         begin
            if (data_out_valid)
            begin
               rd_en_cmd = 1'b1;
            end
            else
            begin
               rd_en_cmd = 1'b0;
            end
         end
         else
         begin
            rd_en_cmd = 1'b0;
         end
      end
   end
 
 
 
   always@( posedge ACLK or negedge arst_sync )
   begin   :Start12
 
      if (~arst_sync | ~srst_sync)
      begin
         INITIATOR_RLAST <= 1'b0;
      end
      else
      begin
         if (set_initiator_rlast)
         begin
            INITIATOR_RLAST <= 1'b1;
         end
         else
         begin
            if (end_cycle)
            begin
               INITIATOR_RLAST <= 1'b0;
            end
         end
      end
   end
 
 
 
   always@( posedge ACLK or negedge arst_sync )
   begin   :extend_flag_tx
 
      if (~arst_sync | ~srst_sync)
      begin
         extend_wrap_tx <= 1'b0;
      end
      else
      begin
         if (set_extend)
         begin
            extend_wrap_tx <= 1'b1;
         end
         else
         begin
            if (clear_extend)
            begin
               extend_wrap_tx <= 1'b0;
            end
         end
      end
   end
 
 
 
   always@( posedge ACLK or negedge arst_sync )
   begin   :mask_wrap_reg
 
      if (~arst_sync | ~srst_sync)
      begin
         mask_wrap_addr_reg <= 'b0;
      end
      else
      begin
         mask_wrap_addr_reg <= mask_wrap_addr >> INITIATOR_RSIZE;
      end
   end
 
 
 
   always@(*) begin :initiator_beat_cnt_comb
 
      if (initiator_accept)  //INITIATOR_RVALID & INITIATOR_RREADY
      begin
         if (INITIATOR_RLAST)
         begin
            next_initiator_beat_cnt = 0;
         end
         else
         begin
            next_initiator_beat_cnt = initiator_beat_cnt_plus_1;
         end
      end
      else
      begin
         next_initiator_beat_cnt = initiator_beat_cnt;
      end
   end
 
 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :Start8
 
      if (~arst_sync | ~srst_sync)
      begin
         fixed_flag_reg <= 1'b0;
      end
      else
      begin
         fixed_flag_reg <= fixed_flag_comb;
      end
   end
 
 
 
   always @(*)
   begin   :Start9
 
      if (INITIATOR_RLAST)
      begin
         fixed_flag_comb = fixed_flag_reg;
      end
      else
      begin
         fixed_flag_comb = fixed_flag;
      end
   end
 
   assign last_next = (~end_cycle & ((initiator_accept ? initiator_beat_cnt_plus_1 : initiator_beat_cnt) == {1'b0, INITIATOR_RLEN})) | (INITIATOR_RLEN_eq_0);
 
 
   assign initiator_accept = INITIATOR_RVALID & INITIATOR_RREADY;
   assign pass_data = initiator_accept | (~hold_data_valid);
   assign incr_rd_src = data_out_valid & pass_data & ~fixed_flag;
   assign data_out_valid = ~data_empty;
   assign data_hold = ~pass_data;
   assign INITIATOR_RVALID = hold_data_valid;
   assign zero_src = rd_en_cmd | set_extend;
 
   // Calculations for rd_en and rd_src
   //assign mask = ((1 << size_in) - 1) >> INITIATOR_RSIZE; // mask for read source
   //assign size_in = $clog2(DATA_WIDTH_IN/8);   // Data width as quotient
   //assign size_out = INITIATOR_RSIZE; 	       // just initiator size
 
   //assign size_diff = (size_in - size_out);   // difference in sizes
   //assign rd_src_top = (1 << size_diff) - 1;    // top of rd_src (max value)
 
   //assign addr_extend = {4'b0000, addr};
   //assign addr_extend = {4'b0000, addr}  >> INITIATOR_RSIZE ;
 
 
   assign rd_src_full = mask_pre & (((extend_wrap_tx && !end_cycle) ? (addr & mask_wrap_addr_reg) : addr) + rd_src_cnt); // full rd_src value before shift
 
   // rd_src to enter mux at register stage
   assign rd_src = rd_src_full >> rd_src_shift_pre;
 
   assign rd_src_data = rd_src_full;
 
   assign rd_en_data = data_fifo_rd_ok & ( fixed_flag | last_next | mux_top | wrap_point);
   assign data_fifo_rd_ok = data_out_valid & pass_data;
 
   assign wrap_point = wrap_flag & wrap_reach_boundary;
   assign wrap_reach_boundary = (initiator_accept | (~hold_data_valid)) & (next_initiator_beat_cnt == {4'b0000, to_wrap_boundary});
 
 
   assign log_wrap_len = (INITIATOR_RLEN == 8'h0f) ? (10'b100) : ((INITIATOR_RLEN == 8'h07) ? (10'b011) : ((INITIATOR_RLEN == 8'h03) ? (10'b010) : 10'b01));
 
   assign mask_wrap_addr = (10'h3ff << shift_wrap_mask);
   assign shift_wrap_mask = (log_wrap_len + INITIATOR_RSIZE);
 
   assign set_initiator_rlast = last_next & data_out_valid & pass_data;
 
   assign inc_value = 10'd1; // increment value for rd_src_cnt to ensure it inceases by the correct amount
 
   assign mux_top = rd_msb;
   assign rd_msb = (rd_src_data == rd_src_top);
   assign end_cycle = INITIATOR_RLAST & initiator_accept;
 
   assign set_extend = wrap_point & data_fifo_rd_ok;
   assign clear_extend = data_out_valid & last_next;
 
 
endmodule

