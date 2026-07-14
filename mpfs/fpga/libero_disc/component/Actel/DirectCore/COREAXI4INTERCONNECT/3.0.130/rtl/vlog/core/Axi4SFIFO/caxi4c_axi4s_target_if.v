// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 44032 $
// SVN $Date: 2023-09-08 17:48:43 +0530 (Fri, 08 Sep 2023) $
//
// IP Core : CoreAXI4SInterconnect
//
// Module  : COREFIFO_AXI4S_TARGET_IF
//
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP.
// Notes    :
// ******************************************************************************************************/

`timescale 1ns / 1ns

module caxi4c_axi4s_target_if (
    S_AXIS_ACLK_i,
    S_AXIS_ARESETN_i,
    //Target Port Interface Signals
    S_AXIS_TVALID_i,
    S_AXIS_TREADY_o,
    S_AXIS_TDATA_i,

    FIFO_WR_DATA_AXIS_o,
    FIFO_WE_EN_AXIS_o,
    FIFO_FULL_i
);

  parameter RESET_TYPE = 0;
  parameter NUM_STAGES = 2;
  parameter READ_MODE = 0;

  parameter TTDATA_WIDTH = 512;
  parameter TTID_WIDTH = 32;
  parameter TTDEST_WIDTH = 32;
  parameter TTUSER_WIDTH = 4096;

  parameter ITDATA_WIDTH = 512;
  parameter ITID_WIDTH = 32;
  parameter ITDEST_WIDTH = 32;
  parameter ITUSER_WIDTH = 4096;

  parameter WIDTH_CORE = 9281;

  parameter ENABLE_TSTRB = 1;
  parameter ENABLE_TKEEP = 1;
  parameter ENABLE_TLAST = 1;
  parameter ENABLE_TUSER = 1;
  parameter ENABLE_TDEST = 1;
  parameter ENABLE_TID = 1;

  input S_AXIS_ACLK_i;
  input S_AXIS_ARESETN_i;
  //Target Port Interface Signals
  input S_AXIS_TVALID_i;
  output S_AXIS_TREADY_o;
  input [TTDATA_WIDTH-1:0] S_AXIS_TDATA_i;


  output [WIDTH_CORE-1:0] FIFO_WR_DATA_AXIS_o;
  output FIFO_WE_EN_AXIS_o;
  input FIFO_FULL_i;



  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  localparam TTSTRB_OFFSET = TTDATA_WIDTH;
  localparam TTKEEP_OFFSET = TTSTRB_OFFSET + (ENABLE_TSTRB ? (TTDATA_WIDTH / 8) : 0);
  localparam TTLAST_OFFSET = TTKEEP_OFFSET + (ENABLE_TKEEP ? (TTDATA_WIDTH / 8) : 0);
  localparam TTID_OFFSET   = TTLAST_OFFSET + (ENABLE_TLAST ? 1 : 0);
  localparam TTDEST_OFFSET = TTID_OFFSET + (ENABLE_TID ? TTID_WIDTH : 0);
  localparam TTUSER_OFFSET = TTDEST_OFFSET + (ENABLE_TDEST ? TTDEST_WIDTH : 0);
  localparam TTWIDTH       = TTUSER_OFFSET + (ENABLE_TUSER ? TTUSER_WIDTH : 0);

  localparam ITSTRB_OFFSET = ITDATA_WIDTH;
  localparam ITKEEP_OFFSET = ITSTRB_OFFSET + (ENABLE_TSTRB ? (ITDATA_WIDTH / 8) : 0);
  localparam ITLAST_OFFSET = ITKEEP_OFFSET + (ENABLE_TKEEP ? (ITDATA_WIDTH / 8) : 0);
  localparam ITID_OFFSET   = ITLAST_OFFSET + (ENABLE_TLAST ? 1 : 0);
  localparam ITDEST_OFFSET = ITID_OFFSET + (ENABLE_TID ? ITID_WIDTH : 0);
  localparam ITUSER_OFFSET = ITDEST_OFFSET + (ENABLE_TDEST ? ITDEST_WIDTH : 0);
  localparam ITWIDTH       = ITUSER_OFFSET + (ENABLE_TUSER ? ITUSER_WIDTH : 0);

  wire                    S_AXIS_TREADY_s;
  wire [WIDTH_CORE-1:0]   s_axi4s_data;


  wire                   aresetn;
  wire                   sresetn;

  assign s_axi4s_data[TTDATA_WIDTH-1:0] = S_AXIS_TDATA_i;

  assign aresetn             = (RESET_TYPE == 1) ? 1'b1 : S_AXIS_ARESETN_i;
  assign sresetn             = (RESET_TYPE == 1) ? S_AXIS_ARESETN_i : 1'b1;


  assign S_AXIS_TREADY_s     = ~FIFO_FULL_i;
  assign S_AXIS_TREADY_o     = S_AXIS_TREADY_s;
  assign FIFO_WR_DATA_AXIS_o = s_axi4s_data;
  assign FIFO_WE_EN_AXIS_o   = (S_AXIS_TREADY_s & S_AXIS_TVALID_i);
  
endmodule
