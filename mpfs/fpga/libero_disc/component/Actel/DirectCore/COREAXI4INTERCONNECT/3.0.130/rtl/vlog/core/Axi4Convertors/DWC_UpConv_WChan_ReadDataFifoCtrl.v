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
 
module caxi4interconnect_DWC_UpConv_WChan_ReadDataFifoCtrl (
                                          //  input ports
                                          TARGET_WREADY,
                                          TARGET_WLEN,
                                          ACLK,
                                          INITIATOR_WVALID,
                                          INITIATOR_WLAST,
                                          arst_sync,
                                          srst_sync,
                                          fifo_nearly_empty,
                                          fifo_empty,
                                          incr_pkt_cnt,
                                          data_fifo_nearly_full,
                                          cmd_fifo_empty,
                                          extend_tx,
                                          wrap_flag_intr,
                                          to_boundary,
                                          size,
 
                                          //  output ports
                                          TARGET_WLAST,
                                          TARGET_WVALID,
                                          INITIATOR_WREADY,
                                          initiator_beat_cnt,
                                          pass_data,
                                          rd_en_data,
                                          rd_en_cmd_trgt,
                                          rd_en_cmd_intr,
                                          initiator_beat_cnt_eq_0,
                                          initiator_beat_cnt_shifted,
                                          initiator_beat_cnt_to_boundary_shifted
                                          );
 
   parameter        SIZE_OUT                              = 2;
   parameter        LOG_OPEN_TX                           = 3;
//  input ports
   input            TARGET_WREADY;
   wire             TARGET_WREADY;
   input     [7:0]  TARGET_WLEN;
   wire      [7:0]  TARGET_WLEN;
   input            ACLK;
   wire             ACLK;
   input            INITIATOR_WVALID;
   wire             INITIATOR_WVALID;
   input            INITIATOR_WLAST;
   wire             INITIATOR_WLAST;
   input            arst_sync;
   input            srst_sync;
   wire             arst_sync;
   input            fifo_nearly_empty;
   wire             fifo_nearly_empty;
   input            fifo_empty;
   wire             fifo_empty;
   input            incr_pkt_cnt;
   wire             incr_pkt_cnt;
   input            data_fifo_nearly_full;
   wire             data_fifo_nearly_full;
   input            cmd_fifo_empty;
   wire             cmd_fifo_empty;
   input            extend_tx;
   wire             extend_tx;
   input            wrap_flag_intr;
   wire             wrap_flag_intr;
   input     [4:0]  to_boundary;
   wire      [4:0]  to_boundary;
   input     [2:0]  size;
   wire      [2:0]  size;
//  output ports
   output           TARGET_WLAST;
   reg              TARGET_WLAST;
   output           TARGET_WVALID;
   reg              TARGET_WVALID;
   output           INITIATOR_WREADY;
   wire             INITIATOR_WREADY;
   output    [7:0]  initiator_beat_cnt;
   reg       [7:0]  initiator_beat_cnt;
   output           pass_data;
   wire             pass_data;
   output           rd_en_data;
   wire             rd_en_data;
   output           rd_en_cmd_trgt;
   wire             rd_en_cmd_trgt;
   output           rd_en_cmd_intr;
   wire             rd_en_cmd_intr;
   output           initiator_beat_cnt_eq_0;
   reg              initiator_beat_cnt_eq_0;
   output    [11:0] initiator_beat_cnt_shifted;
   reg       [11:0] initiator_beat_cnt_shifted;
   output    [11:0] initiator_beat_cnt_to_boundary_shifted;
   reg       [11:0] initiator_beat_cnt_to_boundary_shifted;
//  local signals
   reg              decr_pkt_cnt;
   wire      [8:0]  actual_wlen;
   wire             last_next;
   reg       [LOG_OPEN_TX:0] pkt_cnt;
   reg       [7:0]  target_beat_cnt;
   reg              hold_data_valid;
   wire             data_out_valid;
   wire             target_accept;
   wire             extend_wrap;
   wire             end_first_wrap_pkt;
 
   parameter IDLE      = 1'b0,
             SEND_DATA = 1'b1;
 
 
   reg [0:0] visual_SEND_DATA_SM_current, visual_SEND_DATA_SM_next;
 
   reg              visual_TARGET_WLAST_next;
   reg              visual_TARGET_WVALID_next;
   reg       [7:0]  visual_target_beat_cnt_next;
 
 
   // Combinational process
   always@(*)
   begin : SEND_DATA_SM_comb
      decr_pkt_cnt               = 0;
      visual_target_beat_cnt_next = target_beat_cnt;
      visual_TARGET_WLAST_next   = TARGET_WLAST;
      visual_TARGET_WVALID_next  = TARGET_WVALID;
 
 
 
      case (visual_SEND_DATA_SM_current)
         IDLE:
            begin
               if (pkt_cnt > 0)
               begin
                  if (fifo_empty == 1)
                  begin
                     visual_TARGET_WLAST_next  = 0;
                     visual_TARGET_WVALID_next = 0;
                     visual_SEND_DATA_SM_next  = IDLE;
                  end
                  else
                  begin
                     visual_TARGET_WVALID_next = 1;
                     if (last_next == 1)
                     begin
                        visual_TARGET_WLAST_next = 1;
                        decr_pkt_cnt = 1;
                        visual_target_beat_cnt_next = 0;
                        visual_SEND_DATA_SM_next = SEND_DATA;
                     end
                     else
                     begin
                        visual_target_beat_cnt_next = target_beat_cnt + 8'd1;
                        visual_TARGET_WLAST_next = 0;
                        visual_SEND_DATA_SM_next = SEND_DATA;
                     end
                  end
               end
               //  No point in proceesing yet,
               //  as the amount of data in the
               //  caxi4interconnect_FIFO is too low
               else if (fifo_nearly_empty == 1)
               begin
                  visual_TARGET_WLAST_next = 0;
                  visual_TARGET_WVALID_next = 0;
                  visual_SEND_DATA_SM_next = IDLE;
               end
               else
               begin
                  visual_TARGET_WVALID_next = 1;
                  if (last_next == 1)
                  begin
                     visual_TARGET_WLAST_next = 1;
                     decr_pkt_cnt = 1;
                     visual_target_beat_cnt_next = 0;
                     visual_SEND_DATA_SM_next = SEND_DATA;
                  end
                  else
                  begin
                     visual_target_beat_cnt_next = target_beat_cnt + 8'd1;
                     visual_TARGET_WLAST_next = 0;
                     visual_SEND_DATA_SM_next = SEND_DATA;
                  end
               end
            end
 
         SEND_DATA:
            begin
               if (TARGET_WREADY == 1)
               begin
                  if (fifo_empty == 1)
                  begin
                     if (pkt_cnt > 0)
                     begin
                        if (fifo_empty == 1)
                        begin
                           visual_TARGET_WLAST_next = 0;
                           visual_TARGET_WVALID_next = 0;
                           visual_SEND_DATA_SM_next = IDLE;
                        end
                        else
                        begin
                           visual_TARGET_WVALID_next = 1;
                           if (last_next == 1)
                           begin
                              visual_TARGET_WLAST_next = 1;
                              decr_pkt_cnt = 1;
                              visual_target_beat_cnt_next = 0;
                              visual_SEND_DATA_SM_next = SEND_DATA;
                           end
                           else
                           begin
                              visual_target_beat_cnt_next = target_beat_cnt + 8'd1;
                              visual_TARGET_WLAST_next = 0;
                              visual_SEND_DATA_SM_next = SEND_DATA;
                           end
                        end
                     end
                     else if (fifo_nearly_empty == 1)
                     begin
                        visual_TARGET_WLAST_next = 0;
                        visual_TARGET_WVALID_next = 0;
                        visual_SEND_DATA_SM_next = IDLE;
                     end
                     else
                     begin
                        visual_TARGET_WVALID_next = 1;
                        if (last_next == 1)
                        begin
                           visual_TARGET_WLAST_next = 1;
                           decr_pkt_cnt = 1;
                           visual_target_beat_cnt_next = 0;
                           visual_SEND_DATA_SM_next = SEND_DATA;
                        end
                        else
                        begin
                           visual_target_beat_cnt_next = target_beat_cnt + 8'd1;
                           visual_TARGET_WLAST_next = 0;
                           visual_SEND_DATA_SM_next = SEND_DATA;
                        end
                     end
                  end
                  else if (TARGET_WLAST == 1)
                  begin
                     if (pkt_cnt > 0)
                     begin
                        if (fifo_empty == 1)
                        begin
                           visual_TARGET_WLAST_next = 0;
                           visual_TARGET_WVALID_next = 0;
                           visual_SEND_DATA_SM_next = IDLE;
                        end
                        else
                        begin
                           visual_TARGET_WVALID_next = 1;
                           if (last_next == 1)
                           begin
                              visual_TARGET_WLAST_next = 1;
                              decr_pkt_cnt = 1;
                              visual_target_beat_cnt_next = 0;
                              visual_SEND_DATA_SM_next = SEND_DATA;
                           end
                           else
                           begin
                              visual_target_beat_cnt_next = target_beat_cnt + 8'd1;
                              visual_TARGET_WLAST_next = 0;
                              visual_SEND_DATA_SM_next = SEND_DATA;
                           end
                        end
                     end
                     else if (fifo_nearly_empty == 1)
                     begin
                        visual_TARGET_WLAST_next = 0;
                        visual_TARGET_WVALID_next = 0;
                        visual_SEND_DATA_SM_next = IDLE;
                     end
                     else
                     begin
                        visual_TARGET_WVALID_next = 1;
                        if (last_next == 1)
                        begin
                           visual_TARGET_WLAST_next = 1;
                           decr_pkt_cnt = 1;
                           visual_target_beat_cnt_next = 0;
                           visual_SEND_DATA_SM_next = SEND_DATA;
                        end
                        else
                        begin
                           visual_target_beat_cnt_next = target_beat_cnt + 8'd1;
                           visual_TARGET_WLAST_next = 0;
                           visual_SEND_DATA_SM_next = SEND_DATA;
                        end
                     end
                  end
                  else if (last_next == 1)
                  begin
                     visual_TARGET_WLAST_next = 1;
                     decr_pkt_cnt = 1;
                     visual_target_beat_cnt_next = 0;
                     visual_SEND_DATA_SM_next = SEND_DATA;
                  end
                  else
                  begin
                     visual_target_beat_cnt_next = target_beat_cnt + 8'd1;
                     visual_TARGET_WLAST_next = 0;
                     visual_SEND_DATA_SM_next = SEND_DATA;
                  end
               end
               else
               begin
                  visual_SEND_DATA_SM_next = SEND_DATA;
               end
            end
 
         default:
            begin
               visual_SEND_DATA_SM_next = IDLE;
            end
      endcase
   end
 
   always  @(posedge ACLK or negedge arst_sync)
   begin : SEND_DATA_SM
 
      if (~arst_sync | ~srst_sync)
      begin
         TARGET_WVALID <= 0;
         TARGET_WLAST <= 0;
         target_beat_cnt <= 0;
         visual_SEND_DATA_SM_current <= IDLE;
      end
      else
      begin
         TARGET_WLAST <= visual_TARGET_WLAST_next;
         TARGET_WVALID <= visual_TARGET_WVALID_next;
         target_beat_cnt <= visual_target_beat_cnt_next;
         visual_SEND_DATA_SM_current <= visual_SEND_DATA_SM_next;
      end
   end
 
 
 
   always
      @( posedge ACLK or negedge arst_sync )
   begin   :intrr_beat_cnt_ctrl
 
      if (~arst_sync | ~srst_sync)
      begin
         initiator_beat_cnt <= 0;
         initiator_beat_cnt_eq_0 <= 1;
         initiator_beat_cnt_shifted <= 0;
         initiator_beat_cnt_to_boundary_shifted <= 0;
      end
      else
      begin
         if (INITIATOR_WREADY == 1)
         begin
            if (INITIATOR_WVALID == 1)
            begin
               if (INITIATOR_WLAST == 1)
               begin
                  initiator_beat_cnt <= 0;
                  initiator_beat_cnt_eq_0 <= 1;
                  initiator_beat_cnt_shifted <= 0;
                  initiator_beat_cnt_to_boundary_shifted <= 0;
               end
               else
               begin
                  initiator_beat_cnt <= initiator_beat_cnt + 8'd1;
                  initiator_beat_cnt_eq_0 <= ((initiator_beat_cnt + 8'd1) == 8'd0);
                  initiator_beat_cnt_to_boundary_shifted <= (((initiator_beat_cnt + 8'd1) - (to_boundary + 8'd1)) << size);
                  initiator_beat_cnt_shifted <= (((initiator_beat_cnt + 8'd1)) << size);
               end
            end
         end
      end
   end
 
 
 
   always
      @( posedge ACLK or negedge arst_sync )
   begin   :pkts_in_wfifo_cnt
 
      if (~arst_sync | ~srst_sync)
      begin
         pkt_cnt <= 0;
      end
      else
      begin
         if (incr_pkt_cnt)
         begin
            if (decr_pkt_cnt)
            begin
            end
            else
            begin
               pkt_cnt <= pkt_cnt + 1'b1;
            end
         end
         else
         begin
            if (decr_pkt_cnt == 1)
            begin
               pkt_cnt <= pkt_cnt - 1'b1;
            end
         end
      end
   end
 
 
 
   always
      @( posedge ACLK or negedge arst_sync )
   begin   :hold_data_valid_ctrl
 
      if (~arst_sync | ~srst_sync)
      begin
         hold_data_valid <= 0;
      end
      else
      begin
         if (pass_data)
         begin
            hold_data_valid <=
            data_out_valid;
         end
      end
   end
 
   assign last_next = (target_beat_cnt == TARGET_WLEN);
 
   //assign last_next = ((target_beat_cnt + 1) == actual_wlen);
   //assign actual_wlen = TARGET_WLEN + 1;
 
   assign target_accept =  TARGET_WREADY & TARGET_WVALID;
 
   assign pass_data = (target_accept | ~hold_data_valid);
 
   assign rd_en_data = data_out_valid & pass_data;
   assign rd_en_cmd_trgt = decr_pkt_cnt;
   assign data_out_valid = ~fifo_empty;
   assign extend_wrap = (wrap_flag_intr & extend_tx);
   assign end_first_wrap_pkt = (initiator_beat_cnt == {3'b000, to_boundary});
   assign rd_en_cmd_intr = INITIATOR_WVALID & INITIATOR_WREADY & (extend_wrap ? end_first_wrap_pkt : INITIATOR_WLAST);
 
   assign INITIATOR_WREADY = !data_fifo_nearly_full & (~cmd_fifo_empty); // Space for 2 or more in data caxi4interconnect_FIFO & cmd available
 
 
endmodule

