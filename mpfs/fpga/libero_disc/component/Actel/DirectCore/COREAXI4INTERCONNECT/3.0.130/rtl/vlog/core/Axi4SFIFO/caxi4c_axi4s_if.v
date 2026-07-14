// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 43978 $
// SVN $Date: 2023-09-01 12:37:32 +0530 (Fri, 01 Sep 2023) $
//
// IP Core : CoreAXI4SInterconnect
//
// Module  : COREFIFO_AXI4S_IF
//
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP.
// Notes    :
// ******************************************************************************************************/


`timescale 1ns / 1ns

module caxi4c_corefifo_axi4s_if
   (
      M_AXIS_ACLK_i,
      S_AXIS_ACLK_i,
      M_AXIS_ARESETN_i,
      S_AXIS_ARESETN_i,
      //Initiator Port Interface Signals
      M_AXIS_TVALID_o,
      M_AXIS_TREADY_i,
      M_AXIS_TDATA_o,
      //Target Port Interface Signals
      S_AXIS_TVALID_i,
      S_AXIS_TREADY_o,
      S_AXIS_TDATA_i,

      FIFO_WR_DATA_AXI4_S_o,
      FIFO_RD_DATA_AXI4_S_i,
      FIFO_WE_EN_AXI4_S_o,
      FIFO_RE_EN_AXI4_S_o,
      FIFO_FULL_i,
      FIFO_EMPTY_i
   );

      parameter                           SYNC             = 0;
      parameter                           RESET_TYPE       = 0;
      parameter                           NUM_STAGES       = 2;
      parameter                           READ_MODE        = 0;
      parameter                           PIPE             = 1;
      parameter                           ECC              = 0;


      parameter                           AXIS_TTDATA_WIDTH = 512;
      parameter                           AXIS_ITDATA_WIDTH = 512;
      parameter                           AXIS_TTID_WIDTH   = 32;
      parameter                           AXIS_ITID_WIDTH   = 32;
      parameter                           AXIS_TTDEST_WIDTH = 32;
      parameter                           AXIS_ITDEST_WIDTH = 32;
      parameter                           AXIS_TTUSER_WIDTH = 4096;
      parameter                           AXIS_ITUSER_WIDTH = 4096;
      parameter                           WWIDTH_CORE       = 9281;
      parameter                           RWIDTH_CORE       = 9281;

      parameter                           ENABLE_TSTRB     = 0;
      parameter                           ENABLE_TKEEP     = 0;
      parameter                           ENABLE_TLAST     = 0;
      parameter                           ENABLE_TUSER     = 0;
      parameter                           ENABLE_TDEST     = 0;
      parameter                           ENABLE_TID       = 0;
	  
      input                               M_AXIS_ACLK_i;
      input                               S_AXIS_ACLK_i;
      input                               M_AXIS_ARESETN_i;
      input                               S_AXIS_ARESETN_i;
      //Initiator Port Interface Signals
      output                              M_AXIS_TVALID_o;
      input                               M_AXIS_TREADY_i;
      output [AXIS_ITDATA_WIDTH-1:0]      M_AXIS_TDATA_o;

      //Target Port Interface Signals
      input                               S_AXIS_TVALID_i;
      output                              S_AXIS_TREADY_o;
      input  [AXIS_TTDATA_WIDTH-1:0]      S_AXIS_TDATA_i;


      output [WWIDTH_CORE-1:0]            FIFO_WR_DATA_AXI4_S_o;
      input  [RWIDTH_CORE-1:0]            FIFO_RD_DATA_AXI4_S_i;
      output                              FIFO_WE_EN_AXI4_S_o;
      output                              FIFO_RE_EN_AXI4_S_o;
      input                               FIFO_FULL_i;
      input                               FIFO_EMPTY_i;




      wire aresetn;
      wire sresetn;

      assign aresetn = (RESET_TYPE == 1) ? 1'b1 : M_AXIS_ARESETN_i;
      assign sresetn = (RESET_TYPE == 1) ? M_AXIS_ARESETN_i : 1'b1;

      caxi4c_axi4s_target_if #(
         .RESET_TYPE             (RESET_TYPE        ),
         .NUM_STAGES             (NUM_STAGES        ),
         .READ_MODE              (READ_MODE         ),

         .TTDATA_WIDTH           (AXIS_TTDATA_WIDTH ),
         .TTID_WIDTH             (AXIS_TTID_WIDTH   ),
         .TTDEST_WIDTH           (AXIS_TTDEST_WIDTH ),
         .TTUSER_WIDTH           (AXIS_TTUSER_WIDTH ),

         .ITDATA_WIDTH           (AXIS_ITDATA_WIDTH ),
         .ITID_WIDTH             (AXIS_ITID_WIDTH   ),
         .ITDEST_WIDTH           (AXIS_ITDEST_WIDTH ),
         .ITUSER_WIDTH           (AXIS_ITUSER_WIDTH ),

         .WIDTH_CORE             (WWIDTH_CORE       ),

         .ENABLE_TSTRB           (ENABLE_TSTRB      ),
         .ENABLE_TKEEP           (ENABLE_TKEEP      ),
         .ENABLE_TLAST           (ENABLE_TLAST      ),
         .ENABLE_TUSER           (ENABLE_TUSER      ),
         .ENABLE_TDEST           (ENABLE_TDEST      ),
         .ENABLE_TID             (ENABLE_TID        )
      )
      U_COREFIFO_AXI4S_TARGET_IF (
         .S_AXIS_ACLK_i          (S_AXIS_ACLK_i         ),
         .S_AXIS_ARESETN_i       (S_AXIS_ARESETN_i      ),
         .S_AXIS_TVALID_i        (S_AXIS_TVALID_i       ),
         .S_AXIS_TREADY_o        (S_AXIS_TREADY_o       ),
         .S_AXIS_TDATA_i         (S_AXIS_TDATA_i        ),

         .FIFO_WR_DATA_AXIS_o    (FIFO_WR_DATA_AXI4_S_o ),
         .FIFO_WE_EN_AXIS_o      (FIFO_WE_EN_AXI4_S_o   ),
         .FIFO_FULL_i            (FIFO_FULL_i           )
      );

      caxi4c_axi4s_initiator_if #(
         .RESET_TYPE             (RESET_TYPE        ),
         .NUM_STAGES             (NUM_STAGES        ),
         .READ_MODE              (READ_MODE         ),
         .PIPE                   (PIPE              ),
         .ECC                    (ECC               ),

         .ITDATA_WIDTH           (AXIS_ITDATA_WIDTH ),
         .ITID_WIDTH             (AXIS_ITID_WIDTH   ),
         .ITDEST_WIDTH           (AXIS_ITDEST_WIDTH ),
         .ITUSER_WIDTH           (AXIS_ITUSER_WIDTH ),

         .TTDATA_WIDTH           (AXIS_TTDATA_WIDTH ),
         .TTID_WIDTH             (AXIS_TTID_WIDTH   ),
         .TTDEST_WIDTH           (AXIS_TTDEST_WIDTH ),
         .TTUSER_WIDTH           (AXIS_TTUSER_WIDTH ),

         .WIDTH_CORE             (RWIDTH_CORE       ),

         .ENABLE_TSTRB           (ENABLE_TSTRB      ),
         .ENABLE_TKEEP           (ENABLE_TKEEP      ),
         .ENABLE_TLAST           (ENABLE_TLAST      ),
         .ENABLE_TUSER           (ENABLE_TUSER      ),
         .ENABLE_TDEST           (ENABLE_TDEST      ),
         .ENABLE_TID             (ENABLE_TID        )

      )
      U_COREFIFO_AXI4S_INITIATOR_IF (
         .M_AXIS_ACLK_i          (M_AXIS_ACLK_i        ),
         .M_AXIS_ARESETN_i       (M_AXIS_ARESETN_i     ),
         .M_AXIS_TVALID_o        (M_AXIS_TVALID_o      ),
         .M_AXIS_TREADY_i        (M_AXIS_TREADY_i      ),
         .M_AXIS_TDATA_o         (M_AXIS_TDATA_o       ),

         .FIFO_RD_DATA_AXIS_i    (FIFO_RD_DATA_AXI4_S_i),
         .FIFO_RD_EN_AXIS_o      (FIFO_RE_EN_AXI4_S_o  ),
         .FIFO_EMPTY_i           (FIFO_EMPTY_i         )
      );
	  
endmodule
