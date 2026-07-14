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
// SVN $Revision: 49514 $
// SVN $Date: 2025-08-10 00:53:16 +0530 (Sun, 10 Aug 2025) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns
 
module caxi4interconnect_DWC_brespCtrl (
                      //  input ports
                      ACLK,
                      arst_sync,
                      srst_sync,
                      INITIATOR_BREADY,
                      TARGET_BUSER,
                      TARGET_BRESP,
                      TARGET_BVALID,
                      TARGET_BID,
                      BRespFifoRdData,
                      bresp_fifo_empty,
 
                      //  output ports
                      brespFifore,
                      INITIATOR_BVALID,
                      INITIATOR_BID,
                      INITIATOR_BUSER,
                      INITIATOR_BRESP,
                      TARGET_BREADY
                      );
 
   parameter        USER_WIDTH         = 1;
   parameter        ID_WIDTH           = 1;
//  input ports
   input            ACLK;
   wire             ACLK;
   input            arst_sync;
   input            srst_sync;
   wire             arst_sync;
   input            INITIATOR_BREADY;
   wire             INITIATOR_BREADY;
   input     [USER_WIDTH - 1:0] TARGET_BUSER;
   wire      [USER_WIDTH - 1:0] TARGET_BUSER;
   input     [1:0]  TARGET_BRESP;
   wire      [1:0]  TARGET_BRESP;
   input            TARGET_BVALID;
   wire             TARGET_BVALID;
   input     [ID_WIDTH-1:0] TARGET_BID;
   input            BRespFifoRdData;
   wire             BRespFifoRdData;
   input            bresp_fifo_empty;
   wire             bresp_fifo_empty;
//  output ports
   output           brespFifore;
   wire             brespFifore;
   output           INITIATOR_BVALID;
   reg              INITIATOR_BVALID;
   output    [ID_WIDTH - 1:0] INITIATOR_BID;
   reg       [ID_WIDTH - 1:0] INITIATOR_BID;
   output    [USER_WIDTH - 1:0] INITIATOR_BUSER;
   reg       [USER_WIDTH - 1:0] INITIATOR_BUSER;
   output    [1:0]  INITIATOR_BRESP;
   reg       [1:0]  INITIATOR_BRESP;
   output           TARGET_BREADY;
   reg              TARGET_BREADY;
//  local signals
   reg              tx_in_progress;
   reg              INITIATOR_BVALID_next;
   reg              tx_in_progress_next;
   reg       [ID_WIDTH - 1:0] INITIATOR_BID_next;
   reg       [USER_WIDTH - 1:0] INITIATOR_BUSER_next;
   reg       [1:0]  INITIATOR_BRESP_next;
 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :bchan_data_ctrl
 
      if (~arst_sync | ~srst_sync)
      begin
         INITIATOR_BID <= 0;
         INITIATOR_BUSER <= 0;
         INITIATOR_BRESP <= 0;
         INITIATOR_BVALID <= 1'b0;
         tx_in_progress <= 1'b0;
      end
      else
      begin
         INITIATOR_BID <= INITIATOR_BID_next;
         INITIATOR_BUSER <= INITIATOR_BUSER_next;
         INITIATOR_BRESP <= INITIATOR_BRESP_next;
         INITIATOR_BVALID <= INITIATOR_BVALID_next;
         tx_in_progress <= tx_in_progress_next;
      end
   end
 
 
 
   always  @(INITIATOR_BID or INITIATOR_BUSER or INITIATOR_BRESP or INITIATOR_BVALID or tx_in_progress or INITIATOR_BREADY or bresp_fifo_empty or TARGET_BVALID or BRespFifoRdData or TARGET_BUSER or TARGET_BRESP or TARGET_BID)
   begin   :bchan_data_ctrl_next
 
      // default values
 
      INITIATOR_BID_next = INITIATOR_BID;
      INITIATOR_BUSER_next = INITIATOR_BUSER;
      INITIATOR_BRESP_next = INITIATOR_BRESP;
      INITIATOR_BVALID_next = INITIATOR_BVALID;
      tx_in_progress_next = tx_in_progress;
      if (tx_in_progress)
      //  T
      begin
         if (INITIATOR_BVALID)
         begin
            if (INITIATOR_BREADY)
            begin
               if (bresp_fifo_empty)
               begin
                  // initiator accept write response and caxi4interconnect_FIFO is empty.
                  // INITIATOR_BRESP is zeroed. If we wouldn't do so,
                  //      we are not able to clear an error reponse
                  //      the next time around
                  // tx_in_progress is taken away because no write
                  //      response is awaiting processing
 
                  tx_in_progress_next = 0;
                  INITIATOR_BRESP_next = 2'b00;
                  TARGET_BREADY = 0;
                  INITIATOR_BVALID_next = 0;
               end
               else
               begin
                  if (TARGET_BVALID)
                  begin
                     // valid target write response. Pass values across
 
                     TARGET_BREADY = 1;
                     INITIATOR_BVALID_next = BRespFifoRdData;
                     tx_in_progress_next = 1;
                     //INITIATOR_BID_next = BRespFifoRdData[ID_WIDTH:1];
                     INITIATOR_BID_next = TARGET_BID;
                     INITIATOR_BUSER_next = TARGET_BUSER;
                     // initiator accepts write response and
                     //      target puts down another one.
                     // We default INITIATOR_BRESP to TARGET_BRESP
 
                     INITIATOR_BRESP_next = TARGET_BRESP;
                  end
                  else
                  begin
                     // initiator accept write response and target
                     //      doesn't put down one.
                     // INITIATOR_BRESP is zeroed. If we wouldn't
                     //      do so, we are not able to clear
                     //      an error reponse the next time around
                     // tx_in_progress is taken away because
                     //      no write response is awaiting processing
 
                     TARGET_BREADY = 0;
                     INITIATOR_BVALID_next = 0;
                     tx_in_progress_next = 1'b0;
                     INITIATOR_BRESP_next = 2'b00;
                  end
               end
            end
            else
            begin
               // waiting for INITIATOR_BREADY
 
               TARGET_BREADY = 0;
               INITIATOR_BVALID_next = 1;
            end
         end
         else
         begin
            if (bresp_fifo_empty)
            begin
               TARGET_BREADY = 0;
               INITIATOR_BVALID_next = 0;
            end
            else
            begin
               if (TARGET_BVALID)
               begin
                  // valid target write response. Pass values across
 
                  TARGET_BREADY = 1;
                  INITIATOR_BVALID_next = BRespFifoRdData;
                  tx_in_progress_next = 1;
                  //INITIATOR_BID_next = BRespFifoRdData[ID_WIDTH:1];
                  INITIATOR_BID_next = TARGET_BID;
                  INITIATOR_BUSER_next = TARGET_BUSER;
                  if (INITIATOR_BRESP < TARGET_BRESP)
                  begin
                     INITIATOR_BRESP_next = TARGET_BRESP;
                  end
               end
               else
               begin
                  TARGET_BREADY = 0;
                  INITIATOR_BVALID_next = 0;
               end
            end
         end
      end
      else
      begin
         if (TARGET_BVALID)
         begin
            // valid target write response. Pass values across
 
            TARGET_BREADY = 1;
            INITIATOR_BVALID_next = BRespFifoRdData;
            tx_in_progress_next = 1;
            //INITIATOR_BID_next = BRespFifoRdData[ID_WIDTH:1];
            INITIATOR_BID_next = TARGET_BID;
            INITIATOR_BUSER_next = TARGET_BUSER;
            if (INITIATOR_BRESP < TARGET_BRESP)
            begin
               INITIATOR_BRESP_next = TARGET_BRESP;
            end
         end
         else
         begin
            TARGET_BREADY = 0;
            INITIATOR_BVALID_next = 0;
         end
      end
   end
 
   assign brespFifore = TARGET_BREADY & TARGET_BVALID;
 
 
endmodule

