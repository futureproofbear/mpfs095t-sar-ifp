// ********************************************************************
//  Microsemi Corporation Proprietary and Confidential
//  Copyright 2017 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: COREAXI4INTERCONNECT testbench
//
// caxi4interconnect_revision Information:
// Date     Description     User Testbench to exercise COREAXI4INTERCONNECT. It exercises writes and reads from all
//                          initiators to all targets. The parameters can be changed in the parameter_incl.v file to change
//                          the core's operation. Models for AXI Initiators and Targets are used to exercise core.
// Feb17    caxi4interconnect_revision 1.0
//
// Notes:
// best viewed with tabstops set to "4"
// ********************************************************************
`timescale 1ns / 1ns



module testbench ();

`include "./parameter_incl.v"            // performs detailed verification of AXI4CROSS

  localparam integer SUPPORT_USER_SIGNALS   = 0;        // indicates where user signals upport - 0 mean no, 1 means yes
  localparam [(ADDR_WIDTH-UPPER_COMPARE_BIT) -1:0]   NXM_DEC =  `DECWIDTH;  // Memory space ADDR[31:28] == 4'd8 is undecoded space.

  //====================================================================
  // Register Slice parameters
  //====================================================================  
  localparam [0:0]  INITIATOR0_AWCHAN_RS = INITIATOR0_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR1_AWCHAN_RS = INITIATOR1_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR2_AWCHAN_RS = INITIATOR2_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR3_AWCHAN_RS = INITIATOR3_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR4_AWCHAN_RS = INITIATOR4_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR5_AWCHAN_RS = INITIATOR5_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR6_AWCHAN_RS = INITIATOR6_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR7_AWCHAN_RS = INITIATOR7_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
              
  localparam [0:0]  INITIATOR0_ARCHAN_RS = INITIATOR0_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR1_ARCHAN_RS = INITIATOR1_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR2_ARCHAN_RS = INITIATOR2_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR3_ARCHAN_RS = INITIATOR3_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR4_ARCHAN_RS = INITIATOR4_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR5_ARCHAN_RS = INITIATOR5_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR6_ARCHAN_RS = INITIATOR6_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR7_ARCHAN_RS = INITIATOR7_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
             
  localparam [0:0]  INITIATOR0_WCHAN_RS = INITIATOR0_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR1_WCHAN_RS = INITIATOR1_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR2_WCHAN_RS = INITIATOR2_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR3_WCHAN_RS = INITIATOR3_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR4_WCHAN_RS = INITIATOR4_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR5_WCHAN_RS = INITIATOR5_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR6_WCHAN_RS = INITIATOR6_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR7_WCHAN_RS = INITIATOR7_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
             
  localparam [0:0]  INITIATOR0_RCHAN_RS = INITIATOR0_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR1_RCHAN_RS = INITIATOR1_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR2_RCHAN_RS = INITIATOR2_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR3_RCHAN_RS = INITIATOR3_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR4_RCHAN_RS = INITIATOR4_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR5_RCHAN_RS = INITIATOR5_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR6_RCHAN_RS = INITIATOR6_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR7_RCHAN_RS = INITIATOR7_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
              
  localparam [0:0]  INITIATOR0_BCHAN_RS = INITIATOR0_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR1_BCHAN_RS = INITIATOR1_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR2_BCHAN_RS = INITIATOR2_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR3_BCHAN_RS = INITIATOR3_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR4_BCHAN_RS = INITIATOR4_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR5_BCHAN_RS = INITIATOR5_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR6_BCHAN_RS = INITIATOR6_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR7_BCHAN_RS = INITIATOR7_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
              
  localparam [0:0]  TARGET0_AWCHAN_RS  = TARGET0_CHAN_RS;   // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET1_AWCHAN_RS  = TARGET1_CHAN_RS;   // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET2_AWCHAN_RS  = TARGET2_CHAN_RS;   // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET3_AWCHAN_RS  = TARGET3_CHAN_RS;   // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET4_AWCHAN_RS  = TARGET4_CHAN_RS;   // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET5_AWCHAN_RS  = TARGET5_CHAN_RS;   // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET6_AWCHAN_RS  = TARGET6_CHAN_RS;   // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET7_AWCHAN_RS  = TARGET7_CHAN_RS;   // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET8_AWCHAN_RS  = TARGET8_CHAN_RS;   // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET9_AWCHAN_RS  = TARGET9_CHAN_RS;   // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET10_AWCHAN_RS = TARGET10_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET11_AWCHAN_RS = TARGET11_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET12_AWCHAN_RS = TARGET12_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET13_AWCHAN_RS = TARGET13_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET14_AWCHAN_RS = TARGET14_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET15_AWCHAN_RS = TARGET15_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET16_AWCHAN_RS = TARGET16_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET17_AWCHAN_RS = TARGET17_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET18_AWCHAN_RS = TARGET18_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET19_AWCHAN_RS = TARGET19_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET20_AWCHAN_RS = TARGET20_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET21_AWCHAN_RS = TARGET21_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET22_AWCHAN_RS = TARGET22_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET23_AWCHAN_RS = TARGET23_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET24_AWCHAN_RS = TARGET24_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET25_AWCHAN_RS = TARGET25_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET26_AWCHAN_RS = TARGET26_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET27_AWCHAN_RS = TARGET27_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET28_AWCHAN_RS = TARGET28_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET29_AWCHAN_RS = TARGET29_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET30_AWCHAN_RS = TARGET30_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  TARGET31_AWCHAN_RS = TARGET31_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
              
  localparam [0:0]  TARGET0_ARCHAN_RS  = TARGET0_CHAN_RS;   // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET1_ARCHAN_RS  = TARGET1_CHAN_RS;   // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET2_ARCHAN_RS  = TARGET2_CHAN_RS;   // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET3_ARCHAN_RS  = TARGET3_CHAN_RS;   // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET4_ARCHAN_RS  = TARGET4_CHAN_RS;   // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET5_ARCHAN_RS  = TARGET5_CHAN_RS;   // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET6_ARCHAN_RS  = TARGET6_CHAN_RS;   // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET7_ARCHAN_RS  = TARGET7_CHAN_RS;   // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET8_ARCHAN_RS  = TARGET8_CHAN_RS;   // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET9_ARCHAN_RS  = TARGET9_CHAN_RS;   // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET10_ARCHAN_RS = TARGET10_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET11_ARCHAN_RS = TARGET11_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET12_ARCHAN_RS = TARGET12_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET13_ARCHAN_RS = TARGET13_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET14_ARCHAN_RS = TARGET14_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET15_ARCHAN_RS = TARGET15_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET16_ARCHAN_RS = TARGET16_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET17_ARCHAN_RS = TARGET17_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET18_ARCHAN_RS = TARGET18_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET19_ARCHAN_RS = TARGET19_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET20_ARCHAN_RS = TARGET20_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET21_ARCHAN_RS = TARGET21_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET22_ARCHAN_RS = TARGET22_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET23_ARCHAN_RS = TARGET23_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET24_ARCHAN_RS = TARGET24_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET25_ARCHAN_RS = TARGET25_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET26_ARCHAN_RS = TARGET26_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET27_ARCHAN_RS = TARGET27_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET28_ARCHAN_RS = TARGET28_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET29_ARCHAN_RS = TARGET29_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET30_ARCHAN_RS = TARGET30_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  TARGET31_ARCHAN_RS = TARGET31_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  
  localparam [0:0]  TARGET0_WCHAN_RS  = TARGET0_CHAN_RS;   // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET1_WCHAN_RS  = TARGET1_CHAN_RS;   // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET2_WCHAN_RS  = TARGET2_CHAN_RS;   // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET3_WCHAN_RS  = TARGET3_CHAN_RS;   // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET4_WCHAN_RS  = TARGET4_CHAN_RS;   // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET5_WCHAN_RS  = TARGET5_CHAN_RS;   // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET6_WCHAN_RS  = TARGET6_CHAN_RS;   // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET7_WCHAN_RS  = TARGET7_CHAN_RS;   // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET8_WCHAN_RS  = TARGET8_CHAN_RS;   // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET9_WCHAN_RS  = TARGET9_CHAN_RS;   // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET10_WCHAN_RS = TARGET10_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET11_WCHAN_RS = TARGET11_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET12_WCHAN_RS = TARGET12_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET13_WCHAN_RS = TARGET13_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET14_WCHAN_RS = TARGET14_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET15_WCHAN_RS = TARGET15_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET16_WCHAN_RS = TARGET16_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET17_WCHAN_RS = TARGET17_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET18_WCHAN_RS = TARGET18_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET19_WCHAN_RS = TARGET19_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET20_WCHAN_RS = TARGET20_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET21_WCHAN_RS = TARGET21_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET22_WCHAN_RS = TARGET22_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET23_WCHAN_RS = TARGET23_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET24_WCHAN_RS = TARGET24_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET25_WCHAN_RS = TARGET25_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET26_WCHAN_RS = TARGET26_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET27_WCHAN_RS = TARGET27_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET28_WCHAN_RS = TARGET28_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET29_WCHAN_RS = TARGET29_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET30_WCHAN_RS = TARGET30_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  TARGET31_WCHAN_RS = TARGET31_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  
  localparam [0:0]  TARGET0_RCHAN_RS  = TARGET0_CHAN_RS;   // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET1_RCHAN_RS  = TARGET1_CHAN_RS;   // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET2_RCHAN_RS  = TARGET2_CHAN_RS;   // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET3_RCHAN_RS  = TARGET3_CHAN_RS;   // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET4_RCHAN_RS  = TARGET4_CHAN_RS;   // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET5_RCHAN_RS  = TARGET5_CHAN_RS;   // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET6_RCHAN_RS  = TARGET6_CHAN_RS;   // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET7_RCHAN_RS  = TARGET7_CHAN_RS;   // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET8_RCHAN_RS  = TARGET8_CHAN_RS;   // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET9_RCHAN_RS  = TARGET9_CHAN_RS;   // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET10_RCHAN_RS = TARGET10_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET11_RCHAN_RS = TARGET11_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET12_RCHAN_RS = TARGET12_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET13_RCHAN_RS = TARGET13_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET14_RCHAN_RS = TARGET14_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET15_RCHAN_RS = TARGET15_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET16_RCHAN_RS = TARGET16_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET17_RCHAN_RS = TARGET17_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET18_RCHAN_RS = TARGET18_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET19_RCHAN_RS = TARGET19_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET20_RCHAN_RS = TARGET20_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET21_RCHAN_RS = TARGET21_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET22_RCHAN_RS = TARGET22_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET23_RCHAN_RS = TARGET23_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET24_RCHAN_RS = TARGET24_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET25_RCHAN_RS = TARGET25_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET26_RCHAN_RS = TARGET26_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET27_RCHAN_RS = TARGET27_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET28_RCHAN_RS = TARGET28_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET29_RCHAN_RS = TARGET29_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET30_RCHAN_RS = TARGET30_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  TARGET31_RCHAN_RS = TARGET31_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  
  localparam [0:0]  TARGET0_BCHAN_RS  = TARGET0_CHAN_RS;   // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET1_BCHAN_RS  = TARGET1_CHAN_RS;   // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET2_BCHAN_RS  = TARGET2_CHAN_RS;   // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET3_BCHAN_RS  = TARGET3_CHAN_RS;   // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET4_BCHAN_RS  = TARGET4_CHAN_RS;   // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET5_BCHAN_RS  = TARGET5_CHAN_RS;   // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET6_BCHAN_RS  = TARGET6_CHAN_RS;   // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET7_BCHAN_RS  = TARGET7_CHAN_RS;   // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET8_BCHAN_RS  = TARGET8_CHAN_RS;   // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET9_BCHAN_RS  = TARGET9_CHAN_RS;   // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET10_BCHAN_RS = TARGET10_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET11_BCHAN_RS = TARGET11_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET12_BCHAN_RS = TARGET12_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET13_BCHAN_RS = TARGET13_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET14_BCHAN_RS = TARGET14_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET15_BCHAN_RS = TARGET15_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET16_BCHAN_RS = TARGET16_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET17_BCHAN_RS = TARGET17_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET18_BCHAN_RS = TARGET18_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET19_BCHAN_RS = TARGET19_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET20_BCHAN_RS = TARGET20_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET21_BCHAN_RS = TARGET21_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET22_BCHAN_RS = TARGET22_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET23_BCHAN_RS = TARGET23_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET24_BCHAN_RS = TARGET24_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET25_BCHAN_RS = TARGET25_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET26_BCHAN_RS = TARGET26_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET27_BCHAN_RS = TARGET27_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET28_BCHAN_RS = TARGET28_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET29_BCHAN_RS = TARGET29_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET30_BCHAN_RS = TARGET30_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  TARGET31_BCHAN_RS = TARGET31_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  
  //===================================================================================================================================

  localparam [64-1:0] UNDEF_AHB_BURST = { UNDEF_BURST_INITIATOR0,
                                          UNDEF_BURST_INITIATOR1,
                                          UNDEF_BURST_INITIATOR2,
                                          UNDEF_BURST_INITIATOR3,
                                          UNDEF_BURST_INITIATOR4,
                                          UNDEF_BURST_INITIATOR5,
                                          UNDEF_BURST_INITIATOR6,
                                          UNDEF_BURST_INITIATOR7
                                          };
  
  
  
  localparam integer NUM_INITIATORS_WIDTH  = (NUM_INITIATORS == 1) ? 1 : $clog2(NUM_INITIATORS);// defines number of bits to encode number of initiators
  
  localparam integer NUM_TARGETS_WIDTH  = (NUM_TARGETS == 1) ? 1 : $clog2(NUM_TARGETS);// defines number of bits to encode number of targets number

  localparam integer ADDR_WIDTH_BITS  = ( ADDR_WIDTH <= 16 ) ? 4 : $clog2(ADDR_WIDTH);// defines number of bits to encode initiator number

  localparam NUM_THREADS_WIDTH    =  (NUM_THREADS == 1) ? 1 : $clog2(NUM_THREADS);// defined number of bits to encode threads number 

  localparam OPEN_TRANS_WIDTH    = ( OPEN_TRANS_MAX == 1 ) ? 1 : $clog2(OPEN_TRANS_MAX);// width of open transaction count 

  localparam INITIATORID_WIDTH    = ( NUM_INITIATORS_WIDTH + ID_WIDTH );      // defines width initiatorID - includes infrastructure port number plus ID

  localparam  BASE_WIDTH = ADDR_WIDTH-UPPER_COMPARE_BIT;

  localparam CMPR_WIDTH = UPPER_COMPARE_BIT-LOWER_COMPARE_BIT;

  localparam [(NUM_INITIATORS*2)-1:0] INITIATOR_TYPE  = { INITIATOR7_TYPE, INITIATOR6_TYPE, INITIATOR5_TYPE, INITIATOR4_TYPE,
                                                    INITIATOR3_TYPE, INITIATOR2_TYPE, INITIATOR1_TYPE, INITIATOR0_TYPE };    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3

  localparam [(NUM_TARGETS*2)-1:0] TARGET_TYPE    = { TARGET15_TYPE, TARGET14_TYPE, TARGET13_TYPE, TARGET12_TYPE, TARGET11_TYPE, TARGET10_TYPE, TARGET9_TYPE,
													TARGET8_TYPE, TARGET7_TYPE, TARGET6_TYPE, TARGET5_TYPE, TARGET4_TYPE,
                                                    TARGET3_TYPE, TARGET2_TYPE, TARGET1_TYPE, TARGET0_TYPE };    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3

  localparam [NUM_INITIATORS-1:0]  INITIATOR_AWCHAN_RS = {  INITIATOR7_AWCHAN_RS, INITIATOR6_AWCHAN_RS, INITIATOR5_AWCHAN_RS, INITIATOR4_AWCHAN_RS,  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                      INITIATOR3_AWCHAN_RS, INITIATOR2_AWCHAN_RS, INITIATOR1_AWCHAN_RS, INITIATOR0_AWCHAN_RS };

  localparam [NUM_INITIATORS-1:0]  INITIATOR_ARCHAN_RS = {  INITIATOR7_ARCHAN_RS, INITIATOR6_ARCHAN_RS, INITIATOR5_ARCHAN_RS, INITIATOR4_ARCHAN_RS,  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                      INITIATOR3_ARCHAN_RS, INITIATOR2_ARCHAN_RS, INITIATOR1_ARCHAN_RS, INITIATOR0_ARCHAN_RS };

  localparam [NUM_INITIATORS-1:0]  INITIATOR_WCHAN_RS = { INITIATOR7_WCHAN_RS, INITIATOR6_WCHAN_RS, INITIATOR5_WCHAN_RS, INITIATOR4_WCHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR3_WCHAN_RS, INITIATOR2_WCHAN_RS, INITIATOR1_WCHAN_RS, INITIATOR0_WCHAN_RS };

  localparam [NUM_INITIATORS-1:0]  INITIATOR_RCHAN_RS = { INITIATOR7_RCHAN_RS, INITIATOR6_RCHAN_RS, INITIATOR5_RCHAN_RS, INITIATOR4_RCHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR3_RCHAN_RS, INITIATOR2_RCHAN_RS, INITIATOR1_RCHAN_RS, INITIATOR0_RCHAN_RS };

  localparam [NUM_INITIATORS-1:0]  INITIATOR_BCHAN_RS = { INITIATOR7_BCHAN_RS, INITIATOR6_BCHAN_RS, INITIATOR5_BCHAN_RS, INITIATOR4_BCHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR3_BCHAN_RS, INITIATOR2_BCHAN_RS, INITIATOR1_BCHAN_RS, INITIATOR0_BCHAN_RS };

  localparam [NUM_TARGETS-1:0]    TARGET_AWCHAN_RS = { TARGET15_AWCHAN_RS, TARGET14_AWCHAN_RS, TARGET13_AWCHAN_RS, TARGET12_AWCHAN_RS, TARGET11_AWCHAN_RS, TARGET10_AWCHAN_RS, TARGET9_AWCHAN_RS,  
													 TARGET8_AWCHAN_RS, TARGET7_AWCHAN_RS, TARGET6_AWCHAN_RS, TARGET5_AWCHAN_RS, TARGET4_AWCHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                      TARGET3_AWCHAN_RS, TARGET2_AWCHAN_RS, TARGET1_AWCHAN_RS, TARGET0_AWCHAN_RS };

  localparam [NUM_TARGETS-1:0]    TARGET_ARCHAN_RS = { TARGET15_ARCHAN_RS, TARGET14_ARCHAN_RS, TARGET13_ARCHAN_RS, TARGET12_ARCHAN_RS, TARGET11_ARCHAN_RS, TARGET10_ARCHAN_RS, TARGET9_ARCHAN_RS,
													 TARGET8_ARCHAN_RS, TARGET7_ARCHAN_RS, TARGET6_ARCHAN_RS, TARGET5_ARCHAN_RS, TARGET4_ARCHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                      TARGET3_ARCHAN_RS, TARGET2_ARCHAN_RS, TARGET1_ARCHAN_RS, TARGET0_ARCHAN_RS };

  localparam [NUM_TARGETS-1:0]    TARGET_WCHAN_RS = { TARGET15_WCHAN_RS, TARGET14_WCHAN_RS, TARGET13_WCHAN_RS, TARGET12_WCHAN_RS, TARGET11_WCHAN_RS, TARGET10_WCHAN_RS, TARGET9_WCHAN_RS,
													TARGET8_WCHAN_RS, TARGET7_WCHAN_RS, TARGET6_WCHAN_RS, TARGET5_WCHAN_RS, TARGET4_WCHAN_RS,      // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    TARGET3_WCHAN_RS, TARGET2_WCHAN_RS, TARGET1_WCHAN_RS, TARGET0_WCHAN_RS };

  localparam [NUM_TARGETS-1:0]    TARGET_RCHAN_RS = { TARGET15_RCHAN_RS, TARGET14_RCHAN_RS, TARGET13_RCHAN_RS, TARGET12_RCHAN_RS, TARGET11_RCHAN_RS, TARGET10_RCHAN_RS, TARGET9_RCHAN_RS,
													TARGET8_RCHAN_RS, TARGET7_RCHAN_RS, TARGET6_RCHAN_RS, TARGET5_RCHAN_RS, TARGET4_RCHAN_RS,      // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    TARGET3_RCHAN_RS, TARGET2_RCHAN_RS, TARGET1_RCHAN_RS, TARGET0_RCHAN_RS };

  localparam [NUM_TARGETS-1:0]    TARGET_BCHAN_RS = { TARGET15_BCHAN_RS, TARGET14_BCHAN_RS, TARGET13_BCHAN_RS, TARGET12_BCHAN_RS, TARGET11_BCHAN_RS, TARGET10_BCHAN_RS, TARGET9_BCHAN_RS,
													TARGET8_BCHAN_RS, TARGET7_BCHAN_RS, TARGET6_BCHAN_RS, TARGET5_BCHAN_RS, TARGET4_BCHAN_RS,      // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    TARGET3_BCHAN_RS, TARGET2_BCHAN_RS, TARGET1_BCHAN_RS, TARGET0_BCHAN_RS };

  localparam [7:0]   INITIATOR0_WRITE_CONNECTIVITY   = { INITIATOR0_WRITE_TARGET15, INITIATOR0_WRITE_TARGET14, INITIATOR0_WRITE_TARGET13, INITIATOR0_WRITE_TARGET12, INITIATOR0_WRITE_TARGET11, INITIATOR0_WRITE_TARGET10, 
													  INITIATOR0_WRITE_TARGET9, INITIATOR0_WRITE_TARGET8, INITIATOR0_WRITE_TARGET7, INITIATOR0_WRITE_TARGET6, INITIATOR0_WRITE_TARGET5, INITIATOR0_WRITE_TARGET4,
                                                      INITIATOR0_WRITE_TARGET3, INITIATOR0_WRITE_TARGET2, INITIATOR0_WRITE_TARGET1, INITIATOR0_WRITE_TARGET0  };

  localparam [7:0]   INITIATOR1_WRITE_CONNECTIVITY   = { INITIATOR1_WRITE_TARGET15, INITIATOR1_WRITE_TARGET14, INITIATOR1_WRITE_TARGET13, INITIATOR1_WRITE_TARGET12, INITIATOR1_WRITE_TARGET11, INITIATOR1_WRITE_TARGET10, 
													  INITIATOR1_WRITE_TARGET9, INITIATOR1_WRITE_TARGET8, INITIATOR1_WRITE_TARGET7, INITIATOR1_WRITE_TARGET6, INITIATOR1_WRITE_TARGET5, INITIATOR1_WRITE_TARGET4,
                                                      INITIATOR1_WRITE_TARGET3, INITIATOR1_WRITE_TARGET2, INITIATOR1_WRITE_TARGET1, INITIATOR1_WRITE_TARGET0  };

  localparam [7:0]   INITIATOR2_WRITE_CONNECTIVITY   = { INITIATOR2_WRITE_TARGET7, INITIATOR2_WRITE_TARGET6, INITIATOR2_WRITE_TARGET5, INITIATOR2_WRITE_TARGET4,
                                                      INITIATOR2_WRITE_TARGET3, INITIATOR2_WRITE_TARGET2, INITIATOR2_WRITE_TARGET1, INITIATOR2_WRITE_TARGET0  };

  localparam [7:0]   INITIATOR3_WRITE_CONNECTIVITY   = { INITIATOR3_WRITE_TARGET7, INITIATOR3_WRITE_TARGET6, INITIATOR3_WRITE_TARGET5, INITIATOR3_WRITE_TARGET4,
                                                      INITIATOR3_WRITE_TARGET3, INITIATOR3_WRITE_TARGET2, INITIATOR3_WRITE_TARGET1, INITIATOR3_WRITE_TARGET0  };

  localparam [7:0]   INITIATOR4_WRITE_CONNECTIVITY   = { INITIATOR4_WRITE_TARGET7, INITIATOR4_WRITE_TARGET6, INITIATOR4_WRITE_TARGET5, INITIATOR4_WRITE_TARGET4,
                                                      INITIATOR4_WRITE_TARGET3, INITIATOR4_WRITE_TARGET2, INITIATOR4_WRITE_TARGET1, INITIATOR4_WRITE_TARGET0  };

  localparam [7:0]   INITIATOR5_WRITE_CONNECTIVITY   = { INITIATOR5_WRITE_TARGET7, INITIATOR5_WRITE_TARGET6, INITIATOR5_WRITE_TARGET5, INITIATOR5_WRITE_TARGET4,
                                                      INITIATOR5_WRITE_TARGET3, INITIATOR5_WRITE_TARGET2, INITIATOR5_WRITE_TARGET1, INITIATOR5_WRITE_TARGET0  };

  localparam [7:0]   INITIATOR6_WRITE_CONNECTIVITY   = { INITIATOR6_WRITE_TARGET7, INITIATOR6_WRITE_TARGET6, INITIATOR6_WRITE_TARGET5, INITIATOR6_WRITE_TARGET4,
                                                      INITIATOR6_WRITE_TARGET3, INITIATOR6_WRITE_TARGET2, INITIATOR6_WRITE_TARGET1, INITIATOR6_WRITE_TARGET0  };

  localparam [7:0]   INITIATOR7_WRITE_CONNECTIVITY   = { INITIATOR7_WRITE_TARGET7, INITIATOR7_WRITE_TARGET6, INITIATOR7_WRITE_TARGET5, INITIATOR7_WRITE_TARGET4,
                                                      INITIATOR7_WRITE_TARGET3, INITIATOR7_WRITE_TARGET2, INITIATOR7_WRITE_TARGET1, INITIATOR7_WRITE_TARGET0  };

  localparam [7:0]   INITIATOR0_READ_CONNECTIVITY   = {  INITIATOR0_READ_TARGET15, INITIATOR0_READ_TARGET14, INITIATOR0_READ_TARGET13, INITIATOR0_READ_TARGET12, INITIATOR0_READ_TARGET11, INITIATOR0_READ_TARGET10, 
													  INITIATOR0_READ_TARGET9, INITIATOR0_READ_TARGET8, INITIATOR0_READ_TARGET7, INITIATOR0_READ_TARGET6, INITIATOR0_READ_TARGET5, INITIATOR0_READ_TARGET4,
                                                      INITIATOR0_READ_TARGET3, INITIATOR0_READ_TARGET2, INITIATOR0_READ_TARGET1, INITIATOR0_READ_TARGET0  };

  localparam [7:0]   INITIATOR1_READ_CONNECTIVITY   = {  INITIATOR1_READ_TARGET15, INITIATOR1_READ_TARGET14, INITIATOR1_READ_TARGET13, INITIATOR1_READ_TARGET12, INITIATOR1_READ_TARGET11, INITIATOR1_READ_TARGET10, 
													  INITIATOR1_READ_TARGET9, INITIATOR1_READ_TARGET8, INITIATOR1_READ_TARGET7, INITIATOR1_READ_TARGET6, INITIATOR1_READ_TARGET5, INITIATOR1_READ_TARGET4,
                                                      INITIATOR1_READ_TARGET3, INITIATOR1_READ_TARGET2, INITIATOR1_READ_TARGET1, INITIATOR1_READ_TARGET0  };
  
  localparam [7:0]   INITIATOR2_READ_CONNECTIVITY   = {  INITIATOR2_READ_TARGET7, INITIATOR2_READ_TARGET6, INITIATOR2_READ_TARGET5, INITIATOR2_READ_TARGET4,
                                                      INITIATOR2_READ_TARGET3, INITIATOR2_READ_TARGET2, INITIATOR2_READ_TARGET1, INITIATOR2_READ_TARGET0  };

  localparam [7:0]   INITIATOR3_READ_CONNECTIVITY   = {  INITIATOR3_READ_TARGET7, INITIATOR3_READ_TARGET6, INITIATOR3_READ_TARGET5, INITIATOR3_READ_TARGET4,
                                                      INITIATOR3_READ_TARGET3, INITIATOR3_READ_TARGET2, INITIATOR3_READ_TARGET1, INITIATOR3_READ_TARGET0  };

  localparam [7:0]   INITIATOR4_READ_CONNECTIVITY   = {  INITIATOR4_READ_TARGET7, INITIATOR4_READ_TARGET6, INITIATOR4_READ_TARGET5, INITIATOR4_READ_TARGET4,
                                                      INITIATOR4_READ_TARGET3, INITIATOR4_READ_TARGET2, INITIATOR4_READ_TARGET1, INITIATOR4_READ_TARGET0  };

  localparam [7:0]   INITIATOR5_READ_CONNECTIVITY   = {  INITIATOR5_READ_TARGET7, INITIATOR5_READ_TARGET6, INITIATOR5_READ_TARGET5, INITIATOR5_READ_TARGET4,
                                                      INITIATOR5_READ_TARGET3, INITIATOR5_READ_TARGET2, INITIATOR5_READ_TARGET1, INITIATOR5_READ_TARGET0  };

  localparam [7:0]   INITIATOR6_READ_CONNECTIVITY   = {  INITIATOR6_READ_TARGET7, INITIATOR6_READ_TARGET6, INITIATOR6_READ_TARGET5, INITIATOR6_READ_TARGET4,
                                                      INITIATOR6_READ_TARGET3, INITIATOR6_READ_TARGET2, INITIATOR6_READ_TARGET1, INITIATOR6_READ_TARGET0  };

  localparam [7:0]   INITIATOR7_READ_CONNECTIVITY   = {  INITIATOR7_READ_TARGET7, INITIATOR7_READ_TARGET6, INITIATOR7_READ_TARGET5, INITIATOR7_READ_TARGET4,
                                                      INITIATOR7_READ_TARGET3, INITIATOR7_READ_TARGET2, INITIATOR7_READ_TARGET1, INITIATOR7_READ_TARGET0  };

  localparam [NUM_INITIATORS*NUM_TARGETS-1:0] INITIATOR_WRITE_CONNECTIVITY = {  INITIATOR7_WRITE_CONNECTIVITY, INITIATOR6_WRITE_CONNECTIVITY, INITIATOR5_WRITE_CONNECTIVITY, INITIATOR4_WRITE_CONNECTIVITY, 
                                                                INITIATOR3_WRITE_CONNECTIVITY, INITIATOR2_WRITE_CONNECTIVITY, INITIATOR1_WRITE_CONNECTIVITY, INITIATOR0_WRITE_CONNECTIVITY };  // bit per port indicating if a initiator can write to a target port

  localparam [NUM_INITIATORS*NUM_TARGETS-1:0] INITIATOR_READ_CONNECTIVITY  = {  INITIATOR7_READ_CONNECTIVITY, INITIATOR6_READ_CONNECTIVITY, INITIATOR5_READ_CONNECTIVITY, INITIATOR4_READ_CONNECTIVITY, 
                                                                INITIATOR3_READ_CONNECTIVITY, INITIATOR2_READ_CONNECTIVITY, INITIATOR1_READ_CONNECTIVITY, INITIATOR0_READ_CONNECTIVITY };  // bit per port indicating if a initiator can read from a target port

  localparam [(NUM_INITIATORS*32)-1:0]  INITIATOR_PORTS_DATA_WIDTH    = { INITIATOR7_DATA_WIDTH,
                                                                    INITIATOR6_DATA_WIDTH,
                                                                    INITIATOR5_DATA_WIDTH,
                                                                    INITIATOR4_DATA_WIDTH,
                                                                    INITIATOR3_DATA_WIDTH,
                                                                    INITIATOR2_DATA_WIDTH,
                                                                    INITIATOR1_DATA_WIDTH,
                                                                    INITIATOR0_DATA_WIDTH
                                                                  };

  localparam [(NUM_TARGETS*32)-1:0]  TARGET_PORTS_DATA_WIDTH  = { TARGET15_DATA_WIDTH, 
																TARGET14_DATA_WIDTH,
                                                                TARGET13_DATA_WIDTH,
                                                                TARGET12_DATA_WIDTH,
                                                                TARGET11_DATA_WIDTH,
                                                                TARGET10_DATA_WIDTH,
                                                                TARGET9_DATA_WIDTH,
																TARGET8_DATA_WIDTH, 
																TARGET7_DATA_WIDTH,
                                                                TARGET6_DATA_WIDTH,
                                                                TARGET5_DATA_WIDTH,
                                                                TARGET4_DATA_WIDTH,
                                                                TARGET3_DATA_WIDTH,
                                                                TARGET2_DATA_WIDTH,
                                                                TARGET1_DATA_WIDTH,
                                                                TARGET0_DATA_WIDTH
                                                                };
  localparam [(NUM_TARGETS*32)-1:0]  TARGET_ADDR   = {
                                                       TARGET15_START_ADDR,
                                                       TARGET14_START_ADDR,
                                                       TARGET13_START_ADDR,
                                                       TARGET12_START_ADDR,
                                                       TARGET11_START_ADDR,
                                                       TARGET10_START_ADDR,
                                                       TARGET9_START_ADDR,
                                                       TARGET8_START_ADDR,
                                                       TARGET7_START_ADDR,
                                                       TARGET6_START_ADDR,
                                                       TARGET5_START_ADDR,
                                                       TARGET4_START_ADDR,
                                                       TARGET3_START_ADDR,
                                                       TARGET2_START_ADDR,
                                                       TARGET1_START_ADDR,
                                                       TARGET0_START_ADDR
                                                    };
  localparam integer INITIATOR_DATA_WIDTH_PORT = ( INITIATOR7_DATA_WIDTH + INITIATOR6_DATA_WIDTH + INITIATOR5_DATA_WIDTH + INITIATOR4_DATA_WIDTH + 
                                                INITIATOR3_DATA_WIDTH + INITIATOR2_DATA_WIDTH + INITIATOR1_DATA_WIDTH + INITIATOR0_DATA_WIDTH);

  localparam  integer ADDR_DEC_WIDTH  =   (ADDR_WIDTH-UPPER_COMPARE_BIT);

  localparam [NUM_INITIATORS*8-1:0] INITIATOR_DEF_BURST_LEN = { INITIATOR7_DEF_BURST_LEN,
                                                          INITIATOR6_DEF_BURST_LEN,
                                                          INITIATOR5_DEF_BURST_LEN,
                                                          INITIATOR4_DEF_BURST_LEN,
                                                          INITIATOR3_DEF_BURST_LEN,
                                                          INITIATOR2_DEF_BURST_LEN,
                                                          INITIATOR1_DEF_BURST_LEN,
                                                          INITIATOR0_DEF_BURST_LEN
                                                          };

  localparam [NUM_TARGETS*14-1:0] TARGET_DWC_DATA_FIFO_DEPTH = {  TARGET15_DWC_DATA_FIFO_DEPTH, 
																TARGET14_DWC_DATA_FIFO_DEPTH,
                                                                TARGET13_DWC_DATA_FIFO_DEPTH,
                                                                TARGET12_DWC_DATA_FIFO_DEPTH,
                                                                TARGET11_DWC_DATA_FIFO_DEPTH,
                                                                TARGET10_DWC_DATA_FIFO_DEPTH,
                                                                TARGET9_DWC_DATA_FIFO_DEPTH,
																TARGET8_DWC_DATA_FIFO_DEPTH, 
																TARGET7_DWC_DATA_FIFO_DEPTH,
                                                                TARGET6_DWC_DATA_FIFO_DEPTH,
                                                                TARGET5_DWC_DATA_FIFO_DEPTH,
                                                                TARGET4_DWC_DATA_FIFO_DEPTH,
                                                                TARGET3_DWC_DATA_FIFO_DEPTH,
                                                                TARGET2_DWC_DATA_FIFO_DEPTH,
                                                                TARGET1_DWC_DATA_FIFO_DEPTH,
                                                                TARGET0_DWC_DATA_FIFO_DEPTH
                                                                };

  localparam [NUM_INITIATORS*14-1:0] INITIATOR_DWC_DATA_FIFO_DEPTH = {  INITIATOR7_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR6_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR5_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR4_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR3_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR2_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR1_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR0_DWC_DATA_FIFO_DEPTH
                                                                  };

  localparam INITIATOR0_CLOCK_DOMAIN_CROSSING = (INITIATOR0_CLK_PERIOD != XBAR_CLK_PERIOD) | (INITIATOR0_PHASE != XBAR_PHASE);
  localparam INITIATOR1_CLOCK_DOMAIN_CROSSING = (INITIATOR1_CLK_PERIOD != XBAR_CLK_PERIOD) | (INITIATOR1_PHASE != XBAR_PHASE);
  localparam INITIATOR2_CLOCK_DOMAIN_CROSSING = (INITIATOR2_CLK_PERIOD != XBAR_CLK_PERIOD) | (INITIATOR2_PHASE != XBAR_PHASE);
  localparam INITIATOR3_CLOCK_DOMAIN_CROSSING = (INITIATOR3_CLK_PERIOD != XBAR_CLK_PERIOD) | (INITIATOR3_PHASE != XBAR_PHASE);
  localparam INITIATOR4_CLOCK_DOMAIN_CROSSING = (INITIATOR4_CLK_PERIOD != XBAR_CLK_PERIOD) | (INITIATOR4_PHASE != XBAR_PHASE);
  localparam INITIATOR5_CLOCK_DOMAIN_CROSSING = (INITIATOR5_CLK_PERIOD != XBAR_CLK_PERIOD) | (INITIATOR5_PHASE != XBAR_PHASE);
  localparam INITIATOR6_CLOCK_DOMAIN_CROSSING = (INITIATOR6_CLK_PERIOD != XBAR_CLK_PERIOD) | (INITIATOR6_PHASE != XBAR_PHASE);
  localparam INITIATOR7_CLOCK_DOMAIN_CROSSING = (INITIATOR7_CLK_PERIOD != XBAR_CLK_PERIOD) | (INITIATOR7_PHASE != XBAR_PHASE);

  localparam TARGET0_CLOCK_DOMAIN_CROSSING  = (TARGET0_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET0_PHASE != XBAR_PHASE);
  localparam TARGET1_CLOCK_DOMAIN_CROSSING  = (TARGET1_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET1_PHASE != XBAR_PHASE);
  localparam TARGET2_CLOCK_DOMAIN_CROSSING  = (TARGET2_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET2_PHASE != XBAR_PHASE);
  localparam TARGET3_CLOCK_DOMAIN_CROSSING  = (TARGET3_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET3_PHASE != XBAR_PHASE);
  localparam TARGET4_CLOCK_DOMAIN_CROSSING  = (TARGET4_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET4_PHASE != XBAR_PHASE);
  localparam TARGET5_CLOCK_DOMAIN_CROSSING  = (TARGET5_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET5_PHASE != XBAR_PHASE);
  localparam TARGET6_CLOCK_DOMAIN_CROSSING  = (TARGET6_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET6_PHASE != XBAR_PHASE);
  localparam TARGET7_CLOCK_DOMAIN_CROSSING  = (TARGET7_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET7_PHASE != XBAR_PHASE);
  localparam TARGET8_CLOCK_DOMAIN_CROSSING  = (TARGET8_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET8_PHASE != XBAR_PHASE);
  localparam TARGET9_CLOCK_DOMAIN_CROSSING  = (TARGET9_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET9_PHASE != XBAR_PHASE);
  localparam TARGET10_CLOCK_DOMAIN_CROSSING = (TARGET10_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET10_PHASE != XBAR_PHASE);
  localparam TARGET11_CLOCK_DOMAIN_CROSSING = (TARGET11_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET11_PHASE != XBAR_PHASE);
  localparam TARGET12_CLOCK_DOMAIN_CROSSING = (TARGET12_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET12_PHASE != XBAR_PHASE);
  localparam TARGET13_CLOCK_DOMAIN_CROSSING = (TARGET13_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET13_PHASE != XBAR_PHASE);
  localparam TARGET14_CLOCK_DOMAIN_CROSSING = (TARGET14_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET14_PHASE != XBAR_PHASE);
  localparam TARGET15_CLOCK_DOMAIN_CROSSING = (TARGET15_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET15_PHASE != XBAR_PHASE);
  localparam TARGET16_CLOCK_DOMAIN_CROSSING = (TARGET16_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET16_PHASE != XBAR_PHASE);
  localparam TARGET17_CLOCK_DOMAIN_CROSSING = (TARGET17_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET17_PHASE != XBAR_PHASE);
  localparam TARGET18_CLOCK_DOMAIN_CROSSING = (TARGET18_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET18_PHASE != XBAR_PHASE);
  localparam TARGET19_CLOCK_DOMAIN_CROSSING = (TARGET19_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET19_PHASE != XBAR_PHASE);
  localparam TARGET20_CLOCK_DOMAIN_CROSSING = (TARGET20_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET20_PHASE != XBAR_PHASE);
  localparam TARGET21_CLOCK_DOMAIN_CROSSING = (TARGET21_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET21_PHASE != XBAR_PHASE);
  localparam TARGET22_CLOCK_DOMAIN_CROSSING = (TARGET22_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET22_PHASE != XBAR_PHASE);
  localparam TARGET23_CLOCK_DOMAIN_CROSSING = (TARGET23_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET23_PHASE != XBAR_PHASE);
  localparam TARGET24_CLOCK_DOMAIN_CROSSING = (TARGET24_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET24_PHASE != XBAR_PHASE);
  localparam TARGET25_CLOCK_DOMAIN_CROSSING = (TARGET25_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET25_PHASE != XBAR_PHASE);
  localparam TARGET26_CLOCK_DOMAIN_CROSSING = (TARGET26_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET26_PHASE != XBAR_PHASE);
  localparam TARGET27_CLOCK_DOMAIN_CROSSING = (TARGET27_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET27_PHASE != XBAR_PHASE);
  localparam TARGET28_CLOCK_DOMAIN_CROSSING = (TARGET28_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET28_PHASE != XBAR_PHASE);
  localparam TARGET29_CLOCK_DOMAIN_CROSSING = (TARGET29_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET29_PHASE != XBAR_PHASE);
  localparam TARGET30_CLOCK_DOMAIN_CROSSING = (TARGET30_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET30_PHASE != XBAR_PHASE);
  localparam TARGET31_CLOCK_DOMAIN_CROSSING = (TARGET31_CLK_PERIOD != XBAR_CLK_PERIOD) | (TARGET31_PHASE != XBAR_PHASE);
  

  //=======================================================================================================================
  // Variable Declarations
  //=======================================================================================================================


  //================================================= Global Signals  =============================================//
  reg           ACLK;
  reg           I_CLK0, I_CLK1, I_CLK2, I_CLK3, I_CLK4, I_CLK5, I_CLK6, I_CLK7;
  reg           T_CLK0,  T_CLK1,  T_CLK2,  T_CLK3,  T_CLK4,  T_CLK5,  T_CLK6,  T_CLK7, 
                T_CLK8,  T_CLK9,  T_CLK10, T_CLK11, T_CLK12, T_CLK13, T_CLK14, T_CLK15, 
                T_CLK16, T_CLK17, T_CLK18, T_CLK19, T_CLK20, T_CLK21, T_CLK22, T_CLK23, 
                T_CLK24, T_CLK25, T_CLK26, T_CLK27, T_CLK28, T_CLK29, T_CLK30, T_CLK31;
                
  reg           ARESETN;      // active high reset synchronoise to RE AClk - asserted async.

  //================================================================================================================
  reg            INITIATOR_RREADY_Default, INITIATOR_WREADY_Default;    // defines whether Initiator asserts ready or waits for RVALID
  reg            d_INITIATOR_BREADY_default;

  reg [NUM_INITIATORS-1:0]  rdStart;                  // defines whether Initiator starts a transaction
  reg [NUM_INITIATORS-1:0]  wrStart;                  // defines whether Initiator starts a transaction

  reg [7:0]        rdBurstLen;      // burst length of read transaction
  reg [ADDR_WIDTH-1:0]  rdStartAddr;    // start addresss for read transaction
  reg [ID_WIDTH-1:0]    rdAID;        // AID for read transactions
  reg [2:0]         rdASize  [7:0];

  reg [1:0]        expWResp [7:0];    // expected Write Response - for AxiInitiator
  reg [1:0]        expRResp [7:0];    // expected Read Response - for AxiInitiator

  reg [1:0]        BurstType;
  reg [7:0]        wrBurstLen;
  reg [ADDR_WIDTH-1:0]  wrStartAddr;
  reg [ID_WIDTH-1:0]    wrAID;
  reg [2:0]  wrASize  [7:0];

  wire [NUM_INITIATORS-1:0]  initiatorWrAddrDone;    // Address Write transaction has been completed
  wire [NUM_INITIATORS-1:0]  initiatorWrDone;      // Asserted when a write transaction has been completed
  wire [NUM_INITIATORS-1:0]  initiatorWrStatus;      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
  wire [NUM_INITIATORS-1:0]  initiatorWAddrIdle;      // indicates Read Address Bus is idle
  wire [NUM_INITIATORS-1:0]  initiatorRespDone;      // indicates Write Response done 
  wire [NUM_INITIATORS-1:0]  initiatorRdAddrDone;
  wire [NUM_INITIATORS-1:0]  initiatorRdDone;      // Asserted when a write transaction has been completed
  wire [NUM_INITIATORS-1:0]  initiatorRdStatus;      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
  wire [NUM_INITIATORS-1:0]  initiatorRAddrIdle;

  wire [NUM_INITIATORS-1:0]  initiatorWrAddrFull;
  wire [NUM_INITIATORS-1:0]  initiatorRdAddrFull;

  reg TARGET_ARREADY_Default;
  reg TARGET_AWREADY_Default;

  reg        TARGET_DATA_IDLE_EN;        // Enables idle cycles to be inserted in Data channels
  reg [1:0]  TARGET_DATA_IDLE_CYCLES;      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3

  reg [31:0]  FORCE_ERROR;             // Forces error pn read/write RESP
  reg [7:0]   ERROR_BYTE;              // Byte to force error on - for READs

  //=================================================  AHB  ================================================//
  reg  [7:0]   start_tx;
  wire [7:0]   end_tx;
  reg  [2:0]   hburst;
  reg  [2:0]   hsize;
  reg          hwrite;
  reg  [31:0]  haddr;

  //================================================= Initiator Ports  ================================================//

  // AHB interface
  wire [31:0]    INITIATOR0_HADDR,     INITIATOR1_HADDR,     INITIATOR2_HADDR,     INITIATOR3_HADDR,     INITIATOR4_HADDR,     INITIATOR5_HADDR,     INITIATOR6_HADDR,     INITIATOR7_HADDR;
  wire [2:0]     INITIATOR0_HBURST,    INITIATOR1_HBURST,    INITIATOR2_HBURST,    INITIATOR3_HBURST,    INITIATOR4_HBURST,    INITIATOR5_HBURST,    INITIATOR6_HBURST,    INITIATOR7_HBURST;
  wire           INITIATOR0_HMASTLOCK, INITIATOR1_HMASTLOCK, INITIATOR2_HMASTLOCK, INITIATOR3_HMASTLOCK, INITIATOR4_HMASTLOCK, INITIATOR5_HMASTLOCK, INITIATOR6_HMASTLOCK, INITIATOR7_HMASTLOCK;
  wire [6:0]     INITIATOR0_HPROT,     INITIATOR1_HPROT,     INITIATOR2_HPROT,     INITIATOR3_HPROT,     INITIATOR4_HPROT,     INITIATOR5_HPROT,     INITIATOR6_HPROT,     INITIATOR7_HPROT;
  wire [2:0]     INITIATOR0_HSIZE,     INITIATOR1_HSIZE,     INITIATOR2_HSIZE,     INITIATOR3_HSIZE,     INITIATOR4_HSIZE,     INITIATOR5_HSIZE,     INITIATOR6_HSIZE,     INITIATOR7_HSIZE;
  wire           INITIATOR0_HNONSEC,   INITIATOR1_HNONSEC,   INITIATOR2_HNONSEC,   INITIATOR3_HNONSEC,   INITIATOR4_HNONSEC,   INITIATOR5_HNONSEC,   INITIATOR6_HNONSEC,   INITIATOR7_HNONSEC;
  wire [1:0]     INITIATOR0_HTRANS,    INITIATOR1_HTRANS,    INITIATOR2_HTRANS,    INITIATOR3_HTRANS,    INITIATOR4_HTRANS,    INITIATOR5_HTRANS,    INITIATOR6_HTRANS,    INITIATOR7_HTRANS;
  wire           INITIATOR0_HWRITE,    INITIATOR1_HWRITE,    INITIATOR2_HWRITE,    INITIATOR3_HWRITE,    INITIATOR4_HWRITE,    INITIATOR5_HWRITE,    INITIATOR6_HWRITE,    INITIATOR7_HWRITE;
  wire           INITIATOR0_HSEL,      INITIATOR1_HSEL,      INITIATOR2_HSEL,      INITIATOR3_HSEL,      INITIATOR4_HSEL,      INITIATOR5_HSEL,      INITIATOR6_HSEL,      INITIATOR7_HSEL;
  wire           INITIATOR0_HREADY,    INITIATOR1_HREADY,    INITIATOR2_HREADY,    INITIATOR3_HREADY,    INITIATOR4_HREADY,    INITIATOR5_HREADY,    INITIATOR6_HREADY,    INITIATOR7_HREADY;
  wire           INITIATOR0_HRESP,     INITIATOR1_HRESP,     INITIATOR2_HRESP,     INITIATOR3_HRESP,     INITIATOR4_HRESP,     INITIATOR5_HRESP,     INITIATOR6_HRESP,     INITIATOR7_HRESP;

  //================================================  AHB data ports  ======================================================================//
  wire [INITIATOR0_DATA_WIDTH-1:0]    INITIATOR0_HWDATA;
  wire [INITIATOR1_DATA_WIDTH-1:0]    INITIATOR1_HWDATA;
  wire [INITIATOR2_DATA_WIDTH-1:0]    INITIATOR2_HWDATA;
  wire [INITIATOR3_DATA_WIDTH-1:0]    INITIATOR3_HWDATA;
  wire [INITIATOR4_DATA_WIDTH-1:0]    INITIATOR4_HWDATA;
  wire [INITIATOR5_DATA_WIDTH-1:0]    INITIATOR5_HWDATA;
  wire [INITIATOR6_DATA_WIDTH-1:0]    INITIATOR6_HWDATA;
  wire [INITIATOR7_DATA_WIDTH-1:0]    INITIATOR7_HWDATA;

  wire [INITIATOR0_DATA_WIDTH-1:0]    INITIATOR0_HRDATA;
  wire [INITIATOR1_DATA_WIDTH-1:0]    INITIATOR1_HRDATA;
  wire [INITIATOR2_DATA_WIDTH-1:0]    INITIATOR2_HRDATA;
  wire [INITIATOR3_DATA_WIDTH-1:0]    INITIATOR3_HRDATA;
  wire [INITIATOR4_DATA_WIDTH-1:0]    INITIATOR4_HRDATA;
  wire [INITIATOR5_DATA_WIDTH-1:0]    INITIATOR5_HRDATA;
  wire [INITIATOR6_DATA_WIDTH-1:0]    INITIATOR6_HRDATA;
  wire [INITIATOR7_DATA_WIDTH-1:0]    INITIATOR7_HRDATA;

  //================================================  Initiator Write Address Ports  ======================================================================//
  wire [ID_WIDTH-1:0]      INITIATOR0_AWID,     INITIATOR1_AWID,     INITIATOR2_AWID,     INITIATOR3_AWID,     INITIATOR4_AWID,     INITIATOR5_AWID,     INITIATOR6_AWID,     INITIATOR7_AWID;
  wire [ADDR_WIDTH-1:0]    INITIATOR0_AWADDR,   INITIATOR1_AWADDR,   INITIATOR2_AWADDR,   INITIATOR3_AWADDR,   INITIATOR4_AWADDR,   INITIATOR5_AWADDR,   INITIATOR6_AWADDR,   INITIATOR7_AWADDR;
  wire [7:0]               INITIATOR0_AWLEN,    INITIATOR1_AWLEN,    INITIATOR2_AWLEN,    INITIATOR3_AWLEN,    INITIATOR4_AWLEN,    INITIATOR5_AWLEN,    INITIATOR6_AWLEN,    INITIATOR7_AWLEN;
  wire [2:0]               INITIATOR0_AWSIZE,   INITIATOR1_AWSIZE,   INITIATOR2_AWSIZE,   INITIATOR3_AWSIZE,   INITIATOR4_AWSIZE,   INITIATOR5_AWSIZE,   INITIATOR6_AWSIZE,   INITIATOR7_AWSIZE;
  wire [1:0]               INITIATOR0_AWBURST,  INITIATOR1_AWBURST,  INITIATOR2_AWBURST,  INITIATOR3_AWBURST,  INITIATOR4_AWBURST,  INITIATOR5_AWBURST,  INITIATOR6_AWBURST,  INITIATOR7_AWBURST;
  wire [1:0]               INITIATOR0_AWLOCK,   INITIATOR1_AWLOCK,   INITIATOR2_AWLOCK,   INITIATOR3_AWLOCK,   INITIATOR4_AWLOCK,   INITIATOR5_AWLOCK,   INITIATOR6_AWLOCK,   INITIATOR7_AWLOCK;
  wire [3:0]               INITIATOR0_AWCACHE,  INITIATOR1_AWCACHE,  INITIATOR2_AWCACHE,  INITIATOR3_AWCACHE,  INITIATOR4_AWCACHE,  INITIATOR5_AWCACHE,  INITIATOR6_AWCACHE,  INITIATOR7_AWCACHE;
  wire [2:0]               INITIATOR0_AWPROT,   INITIATOR1_AWPROT,   INITIATOR2_AWPROT,   INITIATOR3_AWPROT,   INITIATOR4_AWPROT,   INITIATOR5_AWPROT,   INITIATOR6_AWPROT,   INITIATOR7_AWPROT;
  wire [3:0]               INITIATOR0_AWREGION, INITIATOR1_AWREGION, INITIATOR2_AWREGION, INITIATOR3_AWREGION, INITIATOR4_AWREGION, INITIATOR5_AWREGION, INITIATOR6_AWREGION, INITIATOR7_AWREGION;
  wire [3:0]               INITIATOR0_AWQOS,    INITIATOR1_AWQOS,    INITIATOR2_AWQOS,    INITIATOR3_AWQOS,    INITIATOR4_AWQOS,    INITIATOR5_AWQOS,    INITIATOR6_AWQOS,    INITIATOR7_AWQOS;
  wire [USER_WIDTH-1:0]    INITIATOR0_AWUSER,   INITIATOR1_AWUSER,   INITIATOR2_AWUSER,   INITIATOR3_AWUSER,   INITIATOR4_AWUSER,   INITIATOR5_AWUSER,   INITIATOR6_AWUSER,   INITIATOR7_AWUSER;
  wire                     INITIATOR0_AWVALID,  INITIATOR1_AWVALID,  INITIATOR2_AWVALID,  INITIATOR3_AWVALID,  INITIATOR4_AWVALID,  INITIATOR5_AWVALID,  INITIATOR6_AWVALID,  INITIATOR7_AWVALID;
  wire                     INITIATOR0_AWREADY,  INITIATOR1_AWREADY,  INITIATOR2_AWREADY,  INITIATOR3_AWREADY,  INITIATOR4_AWREADY,  INITIATOR5_AWREADY,  INITIATOR6_AWREADY,  INITIATOR7_AWREADY;

  //================================================   Initiator Write Data Ports  ======================================================================//
  wire [ID_WIDTH-1:0]       INITIATOR0_WID,    INITIATOR1_WID,    INITIATOR2_WID,    INITIATOR3_WID,    INITIATOR4_WID,    INITIATOR5_WID,    INITIATOR6_WID,    INITIATOR7_WID;
  wire                      INITIATOR0_WLAST,  INITIATOR1_WLAST,  INITIATOR2_WLAST,  INITIATOR3_WLAST,  INITIATOR4_WLAST,  INITIATOR5_WLAST,  INITIATOR6_WLAST,  INITIATOR7_WLAST;
  wire [USER_WIDTH-1:0]     INITIATOR0_WUSER,  INITIATOR1_WUSER,  INITIATOR2_WUSER,  INITIATOR3_WUSER,  INITIATOR4_WUSER,  INITIATOR5_WUSER,  INITIATOR6_WUSER,  INITIATOR7_WUSER;
  wire                      INITIATOR0_WVALID, INITIATOR1_WVALID, INITIATOR2_WVALID, INITIATOR3_WVALID, INITIATOR4_WVALID, INITIATOR5_WVALID, INITIATOR6_WVALID, INITIATOR7_WVALID;
  wire                      INITIATOR0_WREADY, INITIATOR1_WREADY, INITIATOR2_WREADY, INITIATOR3_WREADY, INITIATOR4_WREADY, INITIATOR5_WREADY, INITIATOR6_WREADY, INITIATOR7_WREADY;

  wire [INITIATOR0_DATA_WIDTH-1:0]    INITIATOR0_WDATA;
  wire [INITIATOR1_DATA_WIDTH-1:0]    INITIATOR1_WDATA;
  wire [INITIATOR2_DATA_WIDTH-1:0]    INITIATOR2_WDATA;
  wire [INITIATOR3_DATA_WIDTH-1:0]    INITIATOR3_WDATA;
  wire [INITIATOR4_DATA_WIDTH-1:0]    INITIATOR4_WDATA;
  wire [INITIATOR5_DATA_WIDTH-1:0]    INITIATOR5_WDATA;
  wire [INITIATOR6_DATA_WIDTH-1:0]    INITIATOR6_WDATA;
  wire [INITIATOR7_DATA_WIDTH-1:0]    INITIATOR7_WDATA;
  wire [(INITIATOR0_DATA_WIDTH/8)-1:0]  INITIATOR0_WSTRB;
  wire [(INITIATOR1_DATA_WIDTH/8)-1:0]  INITIATOR1_WSTRB;
  wire [(INITIATOR2_DATA_WIDTH/8)-1:0]  INITIATOR2_WSTRB;
  wire [(INITIATOR3_DATA_WIDTH/8)-1:0]  INITIATOR3_WSTRB;
  wire [(INITIATOR4_DATA_WIDTH/8)-1:0]  INITIATOR4_WSTRB;
  wire [(INITIATOR5_DATA_WIDTH/8)-1:0]  INITIATOR5_WSTRB;
  wire [(INITIATOR6_DATA_WIDTH/8)-1:0]  INITIATOR6_WSTRB;
  wire [(INITIATOR7_DATA_WIDTH/8)-1:0]  INITIATOR7_WSTRB;

  //================================================  Initiator Write Response Ports  ======================================================================//
  wire [ID_WIDTH-1:0]    INITIATOR0_BID,     INITIATOR1_BID,    INITIATOR2_BID,    INITIATOR3_BID,    INITIATOR4_BID,    INITIATOR5_BID,    INITIATOR6_BID,    INITIATOR7_BID;
  wire [1:0]             INITIATOR0_BRESP,   INITIATOR1_BRESP,  INITIATOR2_BRESP,  INITIATOR3_BRESP,  INITIATOR4_BRESP,  INITIATOR5_BRESP,  INITIATOR6_BRESP,  INITIATOR7_BRESP;
  wire [USER_WIDTH-1:0]  INITIATOR0_BUSER,   INITIATOR1_BUSER,  INITIATOR2_BUSER,  INITIATOR3_BUSER,  INITIATOR4_BUSER,  INITIATOR5_BUSER,  INITIATOR6_BUSER,  INITIATOR7_BUSER;
  wire                   INITIATOR0_BVALID,  INITIATOR1_BVALID, INITIATOR2_BVALID, INITIATOR3_BVALID, INITIATOR4_BVALID, INITIATOR5_BVALID, INITIATOR6_BVALID, INITIATOR7_BVALID;
  wire                   INITIATOR0_BREADY,  INITIATOR1_BREADY, INITIATOR2_BREADY, INITIATOR3_BREADY, INITIATOR4_BREADY, INITIATOR5_BREADY, INITIATOR6_BREADY, INITIATOR7_BREADY;
  
  //================================================  Initiator Read Address Ports  ======================================================================//
  wire [ID_WIDTH-1:0]     INITIATOR0_ARID,     INITIATOR1_ARID,     INITIATOR2_ARID,     INITIATOR3_ARID,     INITIATOR4_ARID,     INITIATOR5_ARID,     INITIATOR6_ARID,     INITIATOR7_ARID;
  wire [ADDR_WIDTH-1:0]   INITIATOR0_ARADDR,   INITIATOR1_ARADDR,   INITIATOR2_ARADDR,   INITIATOR3_ARADDR,   INITIATOR4_ARADDR,   INITIATOR5_ARADDR,   INITIATOR6_ARADDR,   INITIATOR7_ARADDR;
  wire [7:0]              INITIATOR0_ARLEN,    INITIATOR1_ARLEN,    INITIATOR2_ARLEN,    INITIATOR3_ARLEN,    INITIATOR4_ARLEN,    INITIATOR5_ARLEN,    INITIATOR6_ARLEN,    INITIATOR7_ARLEN;
  wire [2:0]              INITIATOR0_ARSIZE,   INITIATOR1_ARSIZE,   INITIATOR2_ARSIZE,   INITIATOR3_ARSIZE,   INITIATOR4_ARSIZE,   INITIATOR5_ARSIZE,   INITIATOR6_ARSIZE,   INITIATOR7_ARSIZE;
  wire [1:0]              INITIATOR0_ARBURST,  INITIATOR1_ARBURST,  INITIATOR2_ARBURST,  INITIATOR3_ARBURST,  INITIATOR4_ARBURST,  INITIATOR5_ARBURST,  INITIATOR6_ARBURST,  INITIATOR7_ARBURST;
  wire [1:0]              INITIATOR0_ARLOCK,   INITIATOR1_ARLOCK,   INITIATOR2_ARLOCK,   INITIATOR3_ARLOCK,   INITIATOR4_ARLOCK,   INITIATOR5_ARLOCK,   INITIATOR6_ARLOCK,   INITIATOR7_ARLOCK;
  wire [3:0]              INITIATOR0_ARCACHE,  INITIATOR1_ARCACHE,  INITIATOR2_ARCACHE,  INITIATOR3_ARCACHE,  INITIATOR4_ARCACHE,  INITIATOR5_ARCACHE,  INITIATOR6_ARCACHE,  INITIATOR7_ARCACHE;
  wire [2:0]              INITIATOR0_ARPROT,   INITIATOR1_ARPROT,   INITIATOR2_ARPROT,   INITIATOR3_ARPROT,   INITIATOR4_ARPROT,   INITIATOR5_ARPROT,   INITIATOR6_ARPROT,   INITIATOR7_ARPROT;
  wire [3:0]              INITIATOR0_ARREGION, INITIATOR1_ARREGION, INITIATOR2_ARREGION, INITIATOR3_ARREGION, INITIATOR4_ARREGION, INITIATOR5_ARREGION, INITIATOR6_ARREGION, INITIATOR7_ARREGION;
  wire [3:0]              INITIATOR0_ARQOS,    INITIATOR1_ARQOS,    INITIATOR2_ARQOS,    INITIATOR3_ARQOS,    INITIATOR4_ARQOS,    INITIATOR5_ARQOS,    INITIATOR6_ARQOS,    INITIATOR7_ARQOS;
  wire [USER_WIDTH-1:0]   INITIATOR0_ARUSER,   INITIATOR1_ARUSER,   INITIATOR2_ARUSER,   INITIATOR3_ARUSER,   INITIATOR4_ARUSER,   INITIATOR5_ARUSER,   INITIATOR6_ARUSER,   INITIATOR7_ARUSER;
  wire                    INITIATOR0_ARVALID,  INITIATOR1_ARVALID,  INITIATOR2_ARVALID,  INITIATOR3_ARVALID,  INITIATOR4_ARVALID,  INITIATOR5_ARVALID,  INITIATOR6_ARVALID,  INITIATOR7_ARVALID;
  wire                    INITIATOR0_ARREADY,  INITIATOR1_ARREADY,  INITIATOR2_ARREADY,  INITIATOR3_ARREADY,  INITIATOR4_ARREADY,  INITIATOR5_ARREADY,  INITIATOR6_ARREADY,  INITIATOR7_ARREADY;

  //================================================  Initiator Read Data Ports  ======================================================================//
  wire [ID_WIDTH-1:0]       INITIATOR0_RID,    INITIATOR1_RID,    INITIATOR2_RID,    INITIATOR3_RID,    INITIATOR4_RID,    INITIATOR5_RID,    INITIATOR6_RID,    INITIATOR7_RID;
  wire [1:0]                INITIATOR0_RRESP,  INITIATOR1_RRESP,  INITIATOR2_RRESP,  INITIATOR3_RRESP,  INITIATOR4_RRESP,  INITIATOR5_RRESP,  INITIATOR6_RRESP,  INITIATOR7_RRESP;
  wire                      INITIATOR0_RLAST,  INITIATOR1_RLAST,  INITIATOR2_RLAST,  INITIATOR3_RLAST,  INITIATOR4_RLAST,  INITIATOR5_RLAST,  INITIATOR6_RLAST,  INITIATOR7_RLAST;
  wire [USER_WIDTH-1:0]     INITIATOR0_RUSER,  INITIATOR1_RUSER,  INITIATOR2_RUSER,  INITIATOR3_RUSER,  INITIATOR4_RUSER,  INITIATOR5_RUSER,  INITIATOR6_RUSER,  INITIATOR7_RUSER;
  wire                      INITIATOR0_RVALID, INITIATOR1_RVALID, INITIATOR2_RVALID, INITIATOR3_RVALID, INITIATOR4_RVALID, INITIATOR5_RVALID, INITIATOR6_RVALID, INITIATOR7_RVALID;
  wire                      INITIATOR0_RREADY, INITIATOR1_RREADY, INITIATOR2_RREADY, INITIATOR3_RREADY, INITIATOR4_RREADY, INITIATOR5_RREADY, INITIATOR6_RREADY, INITIATOR7_RREADY;

  wire [INITIATOR0_DATA_WIDTH-1:0]    INITIATOR0_RDATA;
  wire [INITIATOR1_DATA_WIDTH-1:0]    INITIATOR1_RDATA;
  wire [INITIATOR2_DATA_WIDTH-1:0]    INITIATOR2_RDATA;
  wire [INITIATOR3_DATA_WIDTH-1:0]    INITIATOR3_RDATA;
  wire [INITIATOR4_DATA_WIDTH-1:0]    INITIATOR4_RDATA;
  wire [INITIATOR5_DATA_WIDTH-1:0]    INITIATOR5_RDATA;
  wire [INITIATOR6_DATA_WIDTH-1:0]    INITIATOR6_RDATA;
  wire [INITIATOR7_DATA_WIDTH-1:0]    INITIATOR7_RDATA;

  //================================================ Target Ports  ======================================================================//
 
  // Target Write Address Port - Target ID is composed of Initiator Port ID concatenated with transaction ID
 wire [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]  TARGET0_AWID,     TARGET1_AWID,     TARGET2_AWID,      TARGET3_AWID,     TARGET4_AWID,     TARGET5_AWID,     TARGET6_AWID,     TARGET7_AWID,
                                          TARGET8_AWID,     TARGET9_AWID,     TARGET10_AWID,     TARGET11_AWID,    TARGET12_AWID,    TARGET13_AWID,    TARGET14_AWID,    TARGET15_AWID,
                                          TARGET16_AWID,    TARGET17_AWID,    TARGET18_AWID,     TARGET19_AWID,    TARGET20_AWID,    TARGET21_AWID,    TARGET22_AWID,    TARGET23_AWID,
                                          TARGET24_AWID,    TARGET25_AWID,    TARGET26_AWID,     TARGET27_AWID,    TARGET28_AWID,    TARGET29_AWID,    TARGET30_AWID,    TARGET31_AWID;
                                          
 wire [ADDR_WIDTH-1:0]    TARGET0_AWADDR,   TARGET1_AWADDR,   TARGET2_AWADDR,   TARGET3_AWADDR,    TARGET4_AWADDR,   TARGET5_AWADDR,   TARGET6_AWADDR,   TARGET7_AWADDR,
                          TARGET8_AWADDR,   TARGET9_AWADDR,   TARGET10_AWADDR,  TARGET11_AWADDR,   TARGET12_AWADDR,  TARGET13_AWADDR,  TARGET14_AWADDR,  TARGET15_AWADDR,
                          TARGET16_AWADDR,  TARGET17_AWADDR,  TARGET18_AWADDR,  TARGET19_AWADDR,   TARGET20_AWADDR,  TARGET21_AWADDR,  TARGET22_AWADDR,  TARGET23_AWADDR,
                          TARGET24_AWADDR,  TARGET25_AWADDR,  TARGET26_AWADDR,  TARGET27_AWADDR,   TARGET28_AWADDR,  TARGET29_AWADDR,  TARGET30_AWADDR,  TARGET31_AWADDR;
                                          
 wire [7:0]               TARGET0_AWLEN,    TARGET1_AWLEN,    TARGET2_AWLEN,    TARGET3_AWLEN,    TARGET4_AWLEN,    TARGET5_AWLEN,    TARGET6_AWLEN,    TARGET7_AWLEN,
                          TARGET8_AWLEN,    TARGET9_AWLEN,    TARGET10_AWLEN,   TARGET11_AWLEN,   TARGET12_AWLEN,   TARGET13_AWLEN,   TARGET14_AWLEN,   TARGET15_AWLEN,
                          TARGET16_AWLEN,   TARGET17_AWLEN,   TARGET18_AWLEN,   TARGET19_AWLEN,   TARGET20_AWLEN,   TARGET21_AWLEN,   TARGET22_AWLEN,   TARGET23_AWLEN,
                          TARGET24_AWLEN,   TARGET25_AWLEN,   TARGET26_AWLEN,   TARGET27_AWLEN,   TARGET28_AWLEN,   TARGET29_AWLEN,   TARGET30_AWLEN,   TARGET31_AWLEN;
                                          

 wire [2:0]               TARGET0_AWSIZE,   TARGET1_AWSIZE,   TARGET2_AWSIZE,   TARGET3_AWSIZE,   TARGET4_AWSIZE,   TARGET5_AWSIZE,   TARGET6_AWSIZE,   TARGET7_AWSIZE,
                          TARGET8_AWSIZE,   TARGET9_AWSIZE,   TARGET10_AWSIZE,  TARGET11_AWSIZE,  TARGET12_AWSIZE,  TARGET13_AWSIZE,  TARGET14_AWSIZE,  TARGET15_AWSIZE,
                          TARGET16_AWSIZE,  TARGET17_AWSIZE,  TARGET18_AWSIZE,  TARGET19_AWSIZE,  TARGET20_AWSIZE,  TARGET21_AWSIZE,  TARGET22_AWSIZE,  TARGET23_AWSIZE,
                          TARGET24_AWSIZE,  TARGET25_AWSIZE,  TARGET26_AWSIZE,  TARGET27_AWSIZE,  TARGET28_AWSIZE,  TARGET29_AWSIZE,  TARGET30_AWSIZE,  TARGET31_AWSIZE;


 wire [1:0]               TARGET0_AWBURST,  TARGET1_AWBURST,  TARGET2_AWBURST,   TARGET3_AWBURST,  TARGET4_AWBURST,  TARGET5_AWBURST,  TARGET6_AWBURST,   TARGET7_AWBURST,
                          TARGET8_AWBURST,  TARGET9_AWBURST,  TARGET10_AWBURST,  TARGET11_AWBURST, TARGET12_AWBURST, TARGET13_AWBURST, TARGET14_AWBURST,  TARGET15_AWBURST,
                          TARGET16_AWBURST, TARGET17_AWBURST, TARGET18_AWBURST,  TARGET19_AWBURST, TARGET20_AWBURST, TARGET21_AWBURST, TARGET22_AWBURST,  TARGET23_AWBURST,
                          TARGET24_AWBURST, TARGET25_AWBURST, TARGET26_AWBURST,  TARGET27_AWBURST, TARGET28_AWBURST, TARGET29_AWBURST, TARGET30_AWBURST,  TARGET31_AWBURST;


 wire [1:0]               TARGET0_AWLOCK,   TARGET1_AWLOCK,   TARGET2_AWLOCK,   TARGET3_AWLOCK,   TARGET4_AWLOCK,   TARGET5_AWLOCK,   TARGET6_AWLOCK,   TARGET7_AWLOCK,
                          TARGET8_AWLOCK,   TARGET9_AWLOCK,   TARGET10_AWLOCK,  TARGET11_AWLOCK,  TARGET12_AWLOCK,  TARGET13_AWLOCK,  TARGET14_AWLOCK,  TARGET15_AWLOCK,
                          TARGET16_AWLOCK,  TARGET17_AWLOCK,  TARGET18_AWLOCK,  TARGET19_AWLOCK,  TARGET20_AWLOCK,  TARGET21_AWLOCK,  TARGET22_AWLOCK,  TARGET23_AWLOCK,
                          TARGET24_AWLOCK,  TARGET25_AWLOCK,  TARGET26_AWLOCK,  TARGET27_AWLOCK,  TARGET28_AWLOCK,  TARGET29_AWLOCK,  TARGET30_AWLOCK,  TARGET31_AWLOCK;


 wire [3:0]               TARGET0_AWCACHE,   TARGET1_AWCACHE,   TARGET2_AWCACHE,   TARGET3_AWCACHE,   TARGET4_AWCACHE,   TARGET5_AWCACHE,   TARGET6_AWCACHE,   TARGET7_AWCACHE,
                          TARGET8_AWCACHE,   TARGET9_AWCACHE,   TARGET10_AWCACHE,  TARGET11_AWCACHE,  TARGET12_AWCACHE,  TARGET13_AWCACHE,  TARGET14_AWCACHE,  TARGET15_AWCACHE,
                          TARGET16_AWCACHE,  TARGET17_AWCACHE,  TARGET18_AWCACHE,  TARGET19_AWCACHE,  TARGET20_AWCACHE,  TARGET21_AWCACHE,  TARGET22_AWCACHE,  TARGET23_AWCACHE,
                          TARGET24_AWCACHE,  TARGET25_AWCACHE,  TARGET26_AWCACHE,  TARGET27_AWCACHE,  TARGET28_AWCACHE,  TARGET29_AWCACHE,  TARGET30_AWCACHE,  TARGET31_AWCACHE;

 wire [2:0]               TARGET0_AWPROT,   TARGET1_AWPROT,   TARGET2_AWPROT,   TARGET3_AWPROT,   TARGET4_AWPROT,   TARGET5_AWPROT,   TARGET6_AWPROT,   TARGET7_AWPROT,
                          TARGET8_AWPROT,   TARGET9_AWPROT,   TARGET10_AWPROT,  TARGET11_AWPROT,  TARGET12_AWPROT,  TARGET13_AWPROT,  TARGET14_AWPROT,  TARGET15_AWPROT,
                          TARGET16_AWPROT,  TARGET17_AWPROT,  TARGET18_AWPROT,  TARGET19_AWPROT,  TARGET20_AWPROT,  TARGET21_AWPROT,  TARGET22_AWPROT,  TARGET23_AWPROT,
                          TARGET24_AWPROT,  TARGET25_AWPROT,  TARGET26_AWPROT,  TARGET27_AWPROT,  TARGET28_AWPROT,  TARGET29_AWPROT,  TARGET30_AWPROT,  TARGET31_AWPROT;


 wire [3:0]               TARGET0_AWREGION,   TARGET1_AWREGION,   TARGET2_AWREGION,   TARGET3_AWREGION,   TARGET4_AWREGION,   TARGET5_AWREGION,   TARGET6_AWREGION,   TARGET7_AWREGION,
                          TARGET8_AWREGION,   TARGET9_AWREGION,   TARGET10_AWREGION,  TARGET11_AWREGION,  TARGET12_AWREGION,  TARGET13_AWREGION,  TARGET14_AWREGION,  TARGET15_AWREGION,
                          TARGET16_AWREGION,  TARGET17_AWREGION,  TARGET18_AWREGION,  TARGET19_AWREGION,  TARGET20_AWREGION,  TARGET21_AWREGION,  TARGET22_AWREGION,  TARGET23_AWREGION,
                          TARGET24_AWREGION,  TARGET25_AWREGION,  TARGET26_AWREGION,  TARGET27_AWREGION,  TARGET28_AWREGION,  TARGET29_AWREGION,  TARGET30_AWREGION,  TARGET31_AWREGION;

 wire [3:0]               TARGET0_AWQOS,   TARGET1_AWQOS,  TARGET2_AWQOS,   TARGET3_AWQOS,  TARGET4_AWQOS,   TARGET5_AWQOS,   TARGET6_AWQOS,   TARGET7_AWQOS,
                          TARGET8_AWQOS,   TARGET9_AWQOS,  TARGET10_AWQOS,  TARGET11_AWQOS, TARGET12_AWQOS,  TARGET13_AWQOS,  TARGET14_AWQOS,  TARGET15_AWQOS,
                          TARGET16_AWQOS,  TARGET17_AWQOS, TARGET18_AWQOS,  TARGET19_AWQOS, TARGET20_AWQOS,  TARGET21_AWQOS,  TARGET22_AWQOS,  TARGET23_AWQOS,  
                          TARGET24_AWQOS,  TARGET25_AWQOS, TARGET26_AWQOS,  TARGET27_AWQOS, TARGET28_AWQOS,  TARGET29_AWQOS,  TARGET30_AWQOS,   TARGET31_AWQOS;
                          
                          
 wire [USER_WIDTH-1:0]    TARGET0_AWUSER,   TARGET1_AWUSER,   TARGET2_AWUSER,   TARGET3_AWUSER,   TARGET4_AWUSER,   TARGET5_AWUSER,   TARGET6_AWUSER,   TARGET7_AWUSER,
                          TARGET8_AWUSER,   TARGET9_AWUSER,   TARGET10_AWUSER,  TARGET11_AWUSER,  TARGET12_AWUSER,  TARGET13_AWUSER,  TARGET14_AWUSER,  TARGET15_AWUSER,
                          TARGET16_AWUSER,  TARGET17_AWUSER,  TARGET18_AWUSER,  TARGET19_AWUSER,  TARGET20_AWUSER,  TARGET21_AWUSER,  TARGET22_AWUSER,  TARGET23_AWUSER,
                          TARGET24_AWUSER,  TARGET25_AWUSER,  TARGET26_AWUSER,  TARGET27_AWUSER,  TARGET28_AWUSER,  TARGET29_AWUSER,  TARGET30_AWUSER,  TARGET31_AWUSER;

 wire                     TARGET0_AWVALID,   TARGET1_AWVALID,   TARGET2_AWVALID,   TARGET3_AWVALID,   TARGET4_AWVALID,  TARGET5_AWVALID,   TARGET6_AWVALID,   TARGET7_AWVALID,
                          TARGET8_AWVALID,   TARGET9_AWVALID,   TARGET10_AWVALID,  TARGET11_AWVALID,  TARGET12_AWVALID, TARGET13_AWVALID,  TARGET14_AWVALID,  TARGET15_AWVALID,  
                          TARGET16_AWVALID,  TARGET17_AWVALID,  TARGET18_AWVALID,  TARGET19_AWVALID,  TARGET20_AWVALID, TARGET21_AWVALID,  TARGET22_AWVALID,   TARGET23_AWVALID,  
                          TARGET24_AWVALID,  TARGET25_AWVALID,  TARGET26_AWVALID,  TARGET27_AWVALID,  TARGET28_AWVALID,  TARGET29_AWVALID, TARGET30_AWVALID,  TARGET31_AWVALID;

 wire                     TARGET0_AWREADY,   TARGET1_AWREADY,   TARGET2_AWREADY,   TARGET3_AWREADY,   TARGET4_AWREADY,    TARGET5_AWREADY,   TARGET6_AWREADY,   TARGET7_AWREADY,
                          TARGET8_AWREADY,   TARGET9_AWREADY,   TARGET10_AWREADY,  TARGET11_AWREADY,  TARGET12_AWREADY,   TARGET13_AWREADY,  TARGET14_AWREADY,  TARGET15_AWREADY,  
                          TARGET16_AWREADY,  TARGET17_AWREADY,  TARGET18_AWREADY,  TARGET19_AWREADY,  TARGET20_AWREADY,  TARGET21_AWREADY,   TARGET22_AWREADY,  TARGET23_AWREADY,
                          TARGET24_AWREADY,  TARGET25_AWREADY,  TARGET26_AWREADY,  TARGET27_AWREADY,  TARGET28_AWREADY,  TARGET29_AWREADY,   TARGET30_AWREADY,  TARGET31_AWREADY;
   
  // Target Write Data Ports
 wire [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]  TARGET0_WID,  TARGET1_WID,  TARGET2_WID,  TARGET3_WID,  TARGET4_WID,  TARGET5_WID,  TARGET6_WID,  TARGET7_WID,
                                          TARGET8_WID,  TARGET9_WID,  TARGET10_WID, TARGET11_WID, TARGET12_WID, TARGET13_WID, TARGET14_WID, TARGET15_WID,
                                          TARGET16_WID, TARGET17_WID, TARGET18_WID, TARGET19_WID, TARGET20_WID, TARGET21_WID, TARGET22_WID, TARGET23_WID, 
                                          TARGET24_WID, TARGET25_WID, TARGET26_WID, TARGET27_WID, TARGET28_WID, TARGET29_WID, TARGET30_WID, TARGET31_WID;

 wire [TARGET0_DATA_WIDTH-1:0]      TARGET0_WDATA;  
 wire [TARGET1_DATA_WIDTH-1:0]      TARGET1_WDATA;  
 wire [TARGET2_DATA_WIDTH-1:0]      TARGET2_WDATA;  
 wire [TARGET3_DATA_WIDTH-1:0]      TARGET3_WDATA;  
 wire [TARGET4_DATA_WIDTH-1:0]      TARGET4_WDATA;  
 wire [TARGET5_DATA_WIDTH-1:0]      TARGET5_WDATA;  
 wire [TARGET6_DATA_WIDTH-1:0]      TARGET6_WDATA;   
 wire [TARGET7_DATA_WIDTH-1:0]      TARGET7_WDATA;  
 wire [TARGET8_DATA_WIDTH-1:0]      TARGET8_WDATA;  
 wire [TARGET9_DATA_WIDTH-1:0]      TARGET9_WDATA;  
 wire [TARGET10_DATA_WIDTH-1:0]     TARGET10_WDATA;  
 wire [TARGET11_DATA_WIDTH-1:0]     TARGET11_WDATA;  
 wire [TARGET12_DATA_WIDTH-1:0]     TARGET12_WDATA;  
 wire [TARGET13_DATA_WIDTH-1:0]     TARGET13_WDATA;  
 wire [TARGET14_DATA_WIDTH-1:0]     TARGET14_WDATA;   
 wire [TARGET15_DATA_WIDTH-1:0]     TARGET15_WDATA;  
 wire [TARGET16_DATA_WIDTH-1:0]     TARGET16_WDATA;  
 wire [TARGET17_DATA_WIDTH-1:0]     TARGET17_WDATA;  
 wire [TARGET18_DATA_WIDTH-1:0]     TARGET18_WDATA;  
 wire [TARGET19_DATA_WIDTH-1:0]     TARGET19_WDATA;  
 wire [TARGET20_DATA_WIDTH-1:0]     TARGET20_WDATA;  
 wire [TARGET21_DATA_WIDTH-1:0]     TARGET21_WDATA;  
 wire [TARGET22_DATA_WIDTH-1:0]     TARGET22_WDATA;   
 wire [TARGET23_DATA_WIDTH-1:0]     TARGET23_WDATA;  
 wire [TARGET24_DATA_WIDTH-1:0]     TARGET24_WDATA;  
 wire [TARGET25_DATA_WIDTH-1:0]     TARGET25_WDATA;  
 wire [TARGET26_DATA_WIDTH-1:0]     TARGET26_WDATA;  
 wire [TARGET27_DATA_WIDTH-1:0]     TARGET27_WDATA;  
 wire [TARGET28_DATA_WIDTH-1:0]     TARGET28_WDATA;  
 wire [TARGET29_DATA_WIDTH-1:0]     TARGET29_WDATA;  
 wire [TARGET30_DATA_WIDTH-1:0]     TARGET30_WDATA;   
 wire [TARGET31_DATA_WIDTH-1:0]     TARGET31_WDATA;


 wire [(TARGET0_DATA_WIDTH/8)-1:0]     TARGET0_WSTRB;
 wire [(TARGET1_DATA_WIDTH/8)-1:0]     TARGET1_WSTRB;  
 wire [(TARGET2_DATA_WIDTH/8)-1:0]     TARGET2_WSTRB;  
 wire [(TARGET3_DATA_WIDTH/8)-1:0]     TARGET3_WSTRB;  
 wire [(TARGET4_DATA_WIDTH/8)-1:0]     TARGET4_WSTRB;  
 wire [(TARGET5_DATA_WIDTH/8)-1:0]     TARGET5_WSTRB;  
 wire [(TARGET6_DATA_WIDTH/8)-1:0]     TARGET6_WSTRB;  
 wire [(TARGET7_DATA_WIDTH/8)-1:0]     TARGET7_WSTRB;
 wire [(TARGET8_DATA_WIDTH/8)-1:0]     TARGET8_WSTRB;
 wire [(TARGET9_DATA_WIDTH/8)-1:0]     TARGET9_WSTRB;  
 wire [(TARGET10_DATA_WIDTH/8)-1:0]    TARGET10_WSTRB;  
 wire [(TARGET11_DATA_WIDTH/8)-1:0]    TARGET11_WSTRB;  
 wire [(TARGET12_DATA_WIDTH/8)-1:0]    TARGET12_WSTRB;  
 wire [(TARGET13_DATA_WIDTH/8)-1:0]    TARGET13_WSTRB;  
 wire [(TARGET14_DATA_WIDTH/8)-1:0]    TARGET14_WSTRB;  
 wire [(TARGET15_DATA_WIDTH/8)-1:0]    TARGET15_WSTRB;
 wire [(TARGET16_DATA_WIDTH/8)-1:0]    TARGET16_WSTRB;
 wire [(TARGET17_DATA_WIDTH/8)-1:0]    TARGET17_WSTRB;  
 wire [(TARGET18_DATA_WIDTH/8)-1:0]    TARGET18_WSTRB;  
 wire [(TARGET19_DATA_WIDTH/8)-1:0]    TARGET19_WSTRB;  
 wire [(TARGET20_DATA_WIDTH/8)-1:0]    TARGET20_WSTRB;  
 wire [(TARGET21_DATA_WIDTH/8)-1:0]    TARGET21_WSTRB;  
 wire [(TARGET22_DATA_WIDTH/8)-1:0]    TARGET22_WSTRB;  
 wire [(TARGET23_DATA_WIDTH/8)-1:0]    TARGET23_WSTRB;
 wire [(TARGET24_DATA_WIDTH/8)-1:0]    TARGET24_WSTRB;
 wire [(TARGET25_DATA_WIDTH/8)-1:0]    TARGET25_WSTRB;  
 wire [(TARGET26_DATA_WIDTH/8)-1:0]    TARGET26_WSTRB;  
 wire [(TARGET27_DATA_WIDTH/8)-1:0]    TARGET27_WSTRB;  
 wire [(TARGET28_DATA_WIDTH/8)-1:0]    TARGET28_WSTRB;  
 wire [(TARGET29_DATA_WIDTH/8)-1:0]    TARGET29_WSTRB;  
 wire [(TARGET30_DATA_WIDTH/8)-1:0]    TARGET30_WSTRB;  
 wire [(TARGET31_DATA_WIDTH/8)-1:0]    TARGET31_WSTRB;


 wire                         TARGET0_WLAST,  TARGET1_WLAST,  TARGET2_WLAST,  TARGET3_WLAST,  TARGET4_WLAST,  TARGET5_WLAST,  TARGET6_WLAST,  TARGET7_WLAST, 
                              TARGET8_WLAST,  TARGET9_WLAST,  TARGET10_WLAST, TARGET11_WLAST, TARGET12_WLAST, TARGET13_WLAST, TARGET14_WLAST, TARGET15_WLAST, 
                              TARGET16_WLAST, TARGET17_WLAST, TARGET18_WLAST, TARGET19_WLAST, TARGET20_WLAST, TARGET21_WLAST, TARGET22_WLAST, TARGET23_WLAST, 
                              TARGET24_WLAST, TARGET25_WLAST, TARGET26_WLAST, TARGET27_WLAST, TARGET28_WLAST, TARGET29_WLAST, TARGET30_WLAST, TARGET31_WLAST;
                              
 wire [USER_WIDTH-1:0]        TARGET0_WUSER,  TARGET1_WUSER,  TARGET2_WUSER,  TARGET3_WUSER,  TARGET4_WUSER,  TARGET5_WUSER,  TARGET6_WUSER,  TARGET7_WUSER, 
                              TARGET8_WUSER,  TARGET9_WUSER,  TARGET10_WUSER, TARGET11_WUSER, TARGET12_WUSER, TARGET13_WUSER, TARGET14_WUSER, TARGET15_WUSER, 
                              TARGET16_WUSER, TARGET17_WUSER, TARGET18_WUSER, TARGET19_WUSER, TARGET20_WUSER, TARGET21_WUSER, TARGET22_WUSER, TARGET23_WUSER, 
                              TARGET24_WUSER, TARGET25_WUSER, TARGET26_WUSER, TARGET27_WUSER, TARGET28_WUSER, TARGET29_WUSER, TARGET30_WUSER, TARGET31_WUSER;
                              
 wire                         TARGET0_WVALID,  TARGET1_WVALID,  TARGET2_WVALID,  TARGET3_WVALID,  TARGET4_WVALID,  TARGET5_WVALID,  TARGET6_WVALID,  TARGET7_WVALID, 
                              TARGET8_WVALID,  TARGET9_WVALID,  TARGET10_WVALID, TARGET11_WVALID, TARGET12_WVALID, TARGET13_WVALID, TARGET14_WVALID, TARGET15_WVALID, 
                              TARGET16_WVALID, TARGET17_WVALID, TARGET18_WVALID, TARGET19_WVALID, TARGET20_WVALID, TARGET21_WVALID, TARGET22_WVALID, TARGET23_WVALID, 
                              TARGET24_WVALID, TARGET25_WVALID, TARGET26_WVALID, TARGET27_WVALID, TARGET28_WVALID, TARGET29_WVALID, TARGET30_WVALID, TARGET31_WVALID;
                              
 wire                         TARGET0_WREADY,  TARGET1_WREADY,  TARGET2_WREADY,  TARGET3_WREADY,  TARGET4_WREADY,  TARGET5_WREADY,  TARGET6_WREADY,  TARGET7_WREADY, 
                              TARGET8_WREADY,  TARGET9_WREADY,  TARGET10_WREADY, TARGET11_WREADY, TARGET12_WREADY, TARGET13_WREADY, TARGET14_WREADY, TARGET15_WREADY, 
                              TARGET16_WREADY, TARGET17_WREADY, TARGET18_WREADY, TARGET19_WREADY, TARGET20_WREADY, TARGET21_WREADY, TARGET22_WREADY, TARGET23_WREADY, 
                              TARGET24_WREADY, TARGET25_WREADY, TARGET26_WREADY, TARGET27_WREADY, TARGET28_WREADY, TARGET29_WREADY, TARGET30_WREADY, TARGET31_WREADY;

  // Target Write Response Ports
wire [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]    TARGET0_BID,  TARGET1_BID,  TARGET2_BID,  TARGET3_BID,  TARGET4_BID,  TARGET5_BID,  TARGET6_BID,  TARGET7_BID,
                                           TARGET8_BID,  TARGET9_BID,  TARGET10_BID, TARGET11_BID, TARGET12_BID, TARGET13_BID, TARGET14_BID, TARGET15_BID, 
                                           TARGET16_BID, TARGET17_BID, TARGET18_BID, TARGET19_BID, TARGET20_BID, TARGET21_BID, TARGET22_BID, TARGET23_BID, 
                                           TARGET24_BID, TARGET25_BID, TARGET26_BID, TARGET27_BID, TARGET28_BID, TARGET29_BID, TARGET30_BID, TARGET31_BID;
                                           
wire [1:0]                                 TARGET0_BRESP,  TARGET1_BRESP,  TARGET2_BRESP,  TARGET3_BRESP,  TARGET4_BRESP,  TARGET5_BRESP,  TARGET6_BRESP,  TARGET7_BRESP, 
                                           TARGET8_BRESP,  TARGET9_BRESP,  TARGET10_BRESP, TARGET11_BRESP, TARGET12_BRESP, TARGET13_BRESP, TARGET14_BRESP, TARGET15_BRESP, 
                                           TARGET16_BRESP, TARGET17_BRESP, TARGET18_BRESP, TARGET19_BRESP, TARGET20_BRESP, TARGET21_BRESP, TARGET22_BRESP, TARGET23_BRESP, 
                                           TARGET24_BRESP, TARGET25_BRESP, TARGET26_BRESP, TARGET27_BRESP, TARGET28_BRESP, TARGET29_BRESP, TARGET30_BRESP, TARGET31_BRESP;
                   
wire [USER_WIDTH-1:0]                      TARGET0_BUSER,  TARGET1_BUSER,  TARGET2_BUSER,  TARGET3_BUSER,  TARGET4_BUSER,  TARGET5_BUSER,  TARGET6_BUSER,  TARGET7_BUSER, 
                                           TARGET8_BUSER,  TARGET9_BUSER,  TARGET10_BUSER, TARGET11_BUSER, TARGET12_BUSER, TARGET13_BUSER, TARGET14_BUSER, TARGET15_BUSER, 
                                           TARGET16_BUSER, TARGET17_BUSER, TARGET18_BUSER, TARGET19_BUSER, TARGET20_BUSER, TARGET21_BUSER, TARGET22_BUSER, TARGET23_BUSER, 
                                           TARGET24_BUSER, TARGET25_BUSER, TARGET26_BUSER, TARGET27_BUSER, TARGET28_BUSER, TARGET29_BUSER, TARGET30_BUSER, TARGET31_BUSER;
                                           
wire                                       TARGET0_BVALID,  TARGET1_BVALID,  TARGET2_BVALID,  TARGET3_BVALID,  TARGET4_BVALID,  TARGET5_BVALID,  TARGET6_BVALID,  TARGET7_BVALID, 
                                           TARGET8_BVALID,  TARGET9_BVALID,  TARGET10_BVALID, TARGET11_BVALID, TARGET12_BVALID, TARGET13_BVALID, TARGET14_BVALID, TARGET15_BVALID, 
                                           TARGET16_BVALID, TARGET17_BVALID, TARGET18_BVALID, TARGET19_BVALID, TARGET20_BVALID, TARGET21_BVALID, TARGET22_BVALID, TARGET23_BVALID, 
                                           TARGET24_BVALID, TARGET25_BVALID, TARGET26_BVALID, TARGET27_BVALID, TARGET28_BVALID, TARGET29_BVALID, TARGET30_BVALID, TARGET31_BVALID;

wire                                       TARGET0_BREADY,  TARGET1_BREADY,  TARGET2_BREADY,  TARGET3_BREADY,  TARGET4_BREADY,  TARGET5_BREADY,  TARGET6_BREADY,  TARGET7_BREADY, 
                                           TARGET8_BREADY,  TARGET9_BREADY,  TARGET10_BREADY, TARGET11_BREADY, TARGET12_BREADY, TARGET13_BREADY, TARGET14_BREADY, TARGET15_BREADY, 
                                           TARGET16_BREADY, TARGET17_BREADY, TARGET18_BREADY, TARGET19_BREADY, TARGET20_BREADY, TARGET21_BREADY, TARGET22_BREADY, TARGET23_BREADY, 
                                           TARGET24_BREADY, TARGET25_BREADY, TARGET26_BREADY, TARGET27_BREADY, TARGET28_BREADY, TARGET29_BREADY, TARGET30_BREADY, TARGET31_BREADY;
   
  // Target Read Address Port
  wire [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]    TARGET0_ARID,  TARGET1_ARID,  TARGET2_ARID,  TARGET3_ARID,  TARGET4_ARID,  TARGET5_ARID,  TARGET6_ARID,  TARGET7_ARID,
                                             TARGET8_ARID,  TARGET9_ARID,  TARGET10_ARID, TARGET11_ARID, TARGET12_ARID, TARGET13_ARID, TARGET14_ARID, TARGET15_ARID, 
                                             TARGET16_ARID, TARGET17_ARID, TARGET18_ARID, TARGET19_ARID, TARGET20_ARID, TARGET21_ARID, TARGET22_ARID, TARGET23_ARID, 
                                             TARGET24_ARID, TARGET25_ARID, TARGET26_ARID, TARGET27_ARID, TARGET28_ARID, TARGET29_ARID, TARGET30_ARID, TARGET31_ARID;
 
 
 
  wire [ADDR_WIDTH-1:0]      TARGET0_ARADDR,  TARGET1_ARADDR,  TARGET2_ARADDR,  TARGET3_ARADDR,  TARGET4_ARADDR,  TARGET5_ARADDR,  TARGET6_ARADDR,  TARGET7_ARADDR, 
                             TARGET8_ARADDR,  TARGET9_ARADDR,  TARGET10_ARADDR, TARGET11_ARADDR, TARGET12_ARADDR, TARGET13_ARADDR, TARGET14_ARADDR, TARGET15_ARADDR, 
                             TARGET16_ARADDR, TARGET17_ARADDR, TARGET18_ARADDR, TARGET19_ARADDR, TARGET20_ARADDR, TARGET21_ARADDR, TARGET22_ARADDR, TARGET23_ARADDR, 
                             TARGET24_ARADDR, TARGET25_ARADDR, TARGET26_ARADDR, TARGET27_ARADDR, TARGET28_ARADDR, TARGET29_ARADDR, TARGET30_ARADDR, TARGET31_ARADDR;


  wire [7:0]                 TARGET0_ARLEN,  TARGET1_ARLEN,  TARGET2_ARLEN,  TARGET3_ARLEN,  TARGET4_ARLEN,  TARGET5_ARLEN,  TARGET6_ARLEN,  TARGET7_ARLEN, 
                             TARGET8_ARLEN,  TARGET9_ARLEN,  TARGET10_ARLEN, TARGET11_ARLEN, TARGET12_ARLEN, TARGET13_ARLEN, TARGET14_ARLEN, TARGET15_ARLEN, 
                             TARGET16_ARLEN, TARGET17_ARLEN, TARGET18_ARLEN, TARGET19_ARLEN, TARGET20_ARLEN, TARGET21_ARLEN, TARGET22_ARLEN, TARGET23_ARLEN, 
                             TARGET24_ARLEN, TARGET25_ARLEN, TARGET26_ARLEN, TARGET27_ARLEN, TARGET28_ARLEN, TARGET29_ARLEN, TARGET30_ARLEN, TARGET31_ARLEN;


  wire [2:0]                 TARGET0_ARSIZE,  TARGET1_ARSIZE,  TARGET2_ARSIZE,  TARGET3_ARSIZE,  TARGET4_ARSIZE,  TARGET5_ARSIZE,  TARGET6_ARSIZE,  TARGET7_ARSIZE, 
                             TARGET8_ARSIZE,  TARGET9_ARSIZE,  TARGET10_ARSIZE, TARGET11_ARSIZE, TARGET12_ARSIZE, TARGET13_ARSIZE, TARGET14_ARSIZE, TARGET15_ARSIZE, 
                             TARGET16_ARSIZE, TARGET17_ARSIZE, TARGET18_ARSIZE, TARGET19_ARSIZE, TARGET20_ARSIZE, TARGET21_ARSIZE, TARGET22_ARSIZE, TARGET23_ARSIZE, 
                             TARGET24_ARSIZE, TARGET25_ARSIZE, TARGET26_ARSIZE, TARGET27_ARSIZE, TARGET28_ARSIZE, TARGET29_ARSIZE, TARGET30_ARSIZE, TARGET31_ARSIZE;


  wire [1:0]                 TARGET0_ARBURST,  TARGET1_ARBURST,  TARGET2_ARBURST,  TARGET3_ARBURST,  TARGET4_ARBURST,  TARGET5_ARBURST,  TARGET6_ARBURST,  TARGET7_ARBURST, 
                             TARGET8_ARBURST,  TARGET9_ARBURST,  TARGET10_ARBURST, TARGET11_ARBURST, TARGET12_ARBURST, TARGET13_ARBURST, TARGET14_ARBURST, TARGET15_ARBURST, 
                             TARGET16_ARBURST, TARGET17_ARBURST, TARGET18_ARBURST, TARGET19_ARBURST, TARGET20_ARBURST, TARGET21_ARBURST, TARGET22_ARBURST, TARGET23_ARBURST, 
                             TARGET24_ARBURST, TARGET25_ARBURST, TARGET26_ARBURST, TARGET27_ARBURST, TARGET28_ARBURST, TARGET29_ARBURST, TARGET30_ARBURST, TARGET31_ARBURST;


  wire [1:0]                 TARGET0_ARLOCK,  TARGET1_ARLOCK,  TARGET2_ARLOCK,  TARGET3_ARLOCK,  TARGET4_ARLOCK,  TARGET5_ARLOCK,  TARGET6_ARLOCK,  TARGET7_ARLOCK, 
                             TARGET8_ARLOCK,  TARGET9_ARLOCK,  TARGET10_ARLOCK, TARGET11_ARLOCK, TARGET12_ARLOCK, TARGET13_ARLOCK, TARGET14_ARLOCK, TARGET15_ARLOCK, 
                             TARGET16_ARLOCK, TARGET17_ARLOCK, TARGET18_ARLOCK, TARGET19_ARLOCK, TARGET20_ARLOCK, TARGET21_ARLOCK, TARGET22_ARLOCK, TARGET23_ARLOCK, 
                             TARGET24_ARLOCK, TARGET25_ARLOCK, TARGET26_ARLOCK, TARGET27_ARLOCK, TARGET28_ARLOCK, TARGET29_ARLOCK, TARGET30_ARLOCK, TARGET31_ARLOCK;


  wire [3:0]                 TARGET0_ARCACHE,  TARGET1_ARCACHE,  TARGET2_ARCACHE,  TARGET3_ARCACHE,  TARGET4_ARCACHE,  TARGET5_ARCACHE,  TARGET6_ARCACHE,  TARGET7_ARCACHE, 
                             TARGET8_ARCACHE,  TARGET9_ARCACHE,  TARGET10_ARCACHE, TARGET11_ARCACHE, TARGET12_ARCACHE, TARGET13_ARCACHE, TARGET14_ARCACHE, TARGET15_ARCACHE, 
                             TARGET16_ARCACHE, TARGET17_ARCACHE, TARGET18_ARCACHE, TARGET19_ARCACHE, TARGET20_ARCACHE, TARGET21_ARCACHE, TARGET22_ARCACHE, TARGET23_ARCACHE, 
                             TARGET24_ARCACHE, TARGET25_ARCACHE, TARGET26_ARCACHE, TARGET27_ARCACHE, TARGET28_ARCACHE, TARGET29_ARCACHE, TARGET30_ARCACHE, TARGET31_ARCACHE;


  wire [2:0]                 TARGET0_ARPROT,  TARGET1_ARPROT,  TARGET2_ARPROT,  TARGET3_ARPROT,  TARGET4_ARPROT,  TARGET5_ARPROT,  TARGET6_ARPROT,  TARGET7_ARPROT, 
                             TARGET8_ARPROT,  TARGET9_ARPROT,  TARGET10_ARPROT, TARGET11_ARPROT, TARGET12_ARPROT, TARGET13_ARPROT, TARGET14_ARPROT, TARGET15_ARPROT, 
                             TARGET16_ARPROT, TARGET17_ARPROT, TARGET18_ARPROT, TARGET19_ARPROT, TARGET20_ARPROT, TARGET21_ARPROT, TARGET22_ARPROT, TARGET23_ARPROT, 
                             TARGET24_ARPROT, TARGET25_ARPROT, TARGET26_ARPROT, TARGET27_ARPROT, TARGET28_ARPROT, TARGET29_ARPROT, TARGET30_ARPROT, TARGET31_ARPROT;


  wire [3:0]                 TARGET0_ARREGION,  TARGET1_ARREGION,  TARGET2_ARREGION,  TARGET3_ARREGION,  TARGET4_ARREGION,  TARGET5_ARREGION,  TARGET6_ARREGION,  TARGET7_ARREGION, 
                             TARGET8_ARREGION,  TARGET9_ARREGION,  TARGET10_ARREGION, TARGET11_ARREGION, TARGET12_ARREGION, TARGET13_ARREGION, TARGET14_ARREGION, TARGET15_ARREGION, 
                             TARGET16_ARREGION, TARGET17_ARREGION, TARGET18_ARREGION, TARGET19_ARREGION, TARGET20_ARREGION, TARGET21_ARREGION, TARGET22_ARREGION, TARGET23_ARREGION, 
                             TARGET24_ARREGION, TARGET25_ARREGION, TARGET26_ARREGION, TARGET27_ARREGION, TARGET28_ARREGION, TARGET29_ARREGION, TARGET30_ARREGION, TARGET31_ARREGION;


  wire [3:0]                 TARGET0_ARQOS,  TARGET1_ARQOS,  TARGET2_ARQOS,  TARGET3_ARQOS,  TARGET4_ARQOS,  TARGET5_ARQOS,  TARGET6_ARQOS,  TARGET7_ARQOS, 
                             TARGET8_ARQOS,  TARGET9_ARQOS,  TARGET10_ARQOS, TARGET11_ARQOS, TARGET12_ARQOS, TARGET13_ARQOS, TARGET14_ARQOS, TARGET15_ARQOS, 
                             TARGET16_ARQOS, TARGET17_ARQOS, TARGET18_ARQOS, TARGET19_ARQOS, TARGET20_ARQOS, TARGET21_ARQOS, TARGET22_ARQOS, TARGET23_ARQOS, 
                             TARGET24_ARQOS, TARGET25_ARQOS, TARGET26_ARQOS, TARGET27_ARQOS, TARGET28_ARQOS, TARGET29_ARQOS, TARGET30_ARQOS, TARGET31_ARQOS;

  wire [USER_WIDTH-1:0]      TARGET0_ARUSER,  TARGET1_ARUSER,  TARGET2_ARUSER,  TARGET3_ARUSER,  TARGET4_ARUSER,  TARGET5_ARUSER,  TARGET6_ARUSER,  TARGET7_ARUSER, 
                             TARGET8_ARUSER,  TARGET9_ARUSER,  TARGET10_ARUSER, TARGET11_ARUSER, TARGET12_ARUSER, TARGET13_ARUSER, TARGET14_ARUSER, TARGET15_ARUSER, 
                             TARGET16_ARUSER, TARGET17_ARUSER, TARGET18_ARUSER, TARGET19_ARUSER, TARGET20_ARUSER, TARGET21_ARUSER, TARGET22_ARUSER, TARGET23_ARUSER, 
                             TARGET24_ARUSER, TARGET25_ARUSER, TARGET26_ARUSER, TARGET27_ARUSER, TARGET28_ARUSER, TARGET29_ARUSER, TARGET30_ARUSER, TARGET31_ARUSER;


  wire                       TARGET0_ARVALID,  TARGET1_ARVALID,  TARGET2_ARVALID,  TARGET3_ARVALID,  TARGET4_ARVALID,  TARGET5_ARVALID,  TARGET6_ARVALID,  TARGET7_ARVALID, 
                             TARGET8_ARVALID,  TARGET9_ARVALID,  TARGET10_ARVALID, TARGET11_ARVALID, TARGET12_ARVALID, TARGET13_ARVALID, TARGET14_ARVALID, TARGET15_ARVALID, 
                             TARGET16_ARVALID, TARGET17_ARVALID, TARGET18_ARVALID, TARGET19_ARVALID, TARGET20_ARVALID, TARGET21_ARVALID, TARGET22_ARVALID, TARGET23_ARVALID, 
                             TARGET24_ARVALID, TARGET25_ARVALID, TARGET26_ARVALID, TARGET27_ARVALID, TARGET28_ARVALID, TARGET29_ARVALID, TARGET30_ARVALID, TARGET31_ARVALID;

 
  wire                       TARGET0_ARREADY,  TARGET1_ARREADY,  TARGET2_ARREADY,  TARGET3_ARREADY,  TARGET4_ARREADY,  TARGET5_ARREADY,  TARGET6_ARREADY,  TARGET7_ARREADY, 
                             TARGET8_ARREADY,  TARGET9_ARREADY,  TARGET10_ARREADY, TARGET11_ARREADY, TARGET12_ARREADY, TARGET13_ARREADY, TARGET14_ARREADY, TARGET15_ARREADY, 
                             TARGET16_ARREADY, TARGET17_ARREADY, TARGET18_ARREADY, TARGET19_ARREADY, TARGET20_ARREADY, TARGET21_ARREADY, TARGET22_ARREADY, TARGET23_ARREADY, 
                             TARGET24_ARREADY, TARGET25_ARREADY, TARGET26_ARREADY, TARGET27_ARREADY, TARGET28_ARREADY, TARGET29_ARREADY, TARGET30_ARREADY, TARGET31_ARREADY;


  // Target Read Data Ports
 wire [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]    TARGET0_RID,  TARGET1_RID,  TARGET2_RID,  TARGET3_RID,  TARGET4_RID,  TARGET5_RID,  TARGET6_RID,  TARGET7_RID,
                                            TARGET8_RID,  TARGET9_RID,  TARGET10_RID, TARGET11_RID, TARGET12_RID, TARGET13_RID, TARGET14_RID, TARGET15_RID, 
                                            TARGET16_RID, TARGET17_RID, TARGET18_RID, TARGET19_RID, TARGET20_RID, TARGET21_RID, TARGET22_RID, TARGET23_RID, 
                                            TARGET24_RID, TARGET25_RID, TARGET26_RID, TARGET27_RID, TARGET28_RID, TARGET29_RID, TARGET30_RID, TARGET31_RID;
                                            
 wire [TARGET0_DATA_WIDTH-1:0]    TARGET0_RDATA;
 wire [TARGET1_DATA_WIDTH-1:0]    TARGET1_RDATA;
 wire [TARGET2_DATA_WIDTH-1:0]    TARGET2_RDATA;
 wire [TARGET3_DATA_WIDTH-1:0]    TARGET3_RDATA;
 wire [TARGET4_DATA_WIDTH-1:0]    TARGET4_RDATA;
 wire [TARGET5_DATA_WIDTH-1:0]    TARGET5_RDATA;
 wire [TARGET6_DATA_WIDTH-1:0]    TARGET6_RDATA;
 wire [TARGET7_DATA_WIDTH-1:0]    TARGET7_RDATA;
 wire [TARGET8_DATA_WIDTH-1:0]    TARGET8_RDATA;
 wire [TARGET9_DATA_WIDTH-1:0]    TARGET9_RDATA;
 wire [TARGET10_DATA_WIDTH-1:0]   TARGET10_RDATA;
 wire [TARGET11_DATA_WIDTH-1:0]   TARGET11_RDATA;
 wire [TARGET12_DATA_WIDTH-1:0]   TARGET12_RDATA;
 wire [TARGET13_DATA_WIDTH-1:0]   TARGET13_RDATA;
 wire [TARGET14_DATA_WIDTH-1:0]   TARGET14_RDATA;
 wire [TARGET15_DATA_WIDTH-1:0]   TARGET15_RDATA;
 wire [TARGET16_DATA_WIDTH-1:0]   TARGET16_RDATA;
 wire [TARGET17_DATA_WIDTH-1:0]   TARGET17_RDATA;
 wire [TARGET18_DATA_WIDTH-1:0]   TARGET18_RDATA;
 wire [TARGET19_DATA_WIDTH-1:0]   TARGET19_RDATA;
 wire [TARGET20_DATA_WIDTH-1:0]   TARGET20_RDATA;
 wire [TARGET21_DATA_WIDTH-1:0]   TARGET21_RDATA;
 wire [TARGET22_DATA_WIDTH-1:0]   TARGET22_RDATA;
 wire [TARGET23_DATA_WIDTH-1:0]   TARGET23_RDATA;
 wire [TARGET24_DATA_WIDTH-1:0]   TARGET24_RDATA;
 wire [TARGET25_DATA_WIDTH-1:0]   TARGET25_RDATA;
 wire [TARGET26_DATA_WIDTH-1:0]   TARGET26_RDATA;
 wire [TARGET27_DATA_WIDTH-1:0]   TARGET27_RDATA;
 wire [TARGET28_DATA_WIDTH-1:0]   TARGET28_RDATA;
 wire [TARGET29_DATA_WIDTH-1:0]   TARGET29_RDATA;
 wire [TARGET30_DATA_WIDTH-1:0]   TARGET30_RDATA;
 wire [TARGET31_DATA_WIDTH-1:0]   TARGET31_RDATA;


 wire [1:0]                 TARGET0_RRESP,  TARGET1_RRESP,  TARGET2_RRESP,  TARGET3_RRESP,  TARGET4_RRESP,  TARGET5_RRESP,  TARGET6_RRESP,  TARGET7_RRESP,
                            TARGET8_RRESP,  TARGET9_RRESP,  TARGET10_RRESP, TARGET11_RRESP, TARGET12_RRESP, TARGET13_RRESP, TARGET14_RRESP, TARGET15_RRESP, 
                            TARGET16_RRESP, TARGET17_RRESP, TARGET18_RRESP, TARGET19_RRESP, TARGET20_RRESP, TARGET21_RRESP, TARGET22_RRESP, TARGET23_RRESP, 
                            TARGET24_RRESP, TARGET25_RRESP, TARGET26_RRESP, TARGET27_RRESP, TARGET28_RRESP, TARGET29_RRESP, TARGET30_RRESP, TARGET31_RRESP;

 wire                       TARGET0_RLAST,  TARGET1_RLAST,  TARGET2_RLAST,  TARGET3_RLAST,  TARGET4_RLAST,  TARGET5_RLAST,  TARGET6_RLAST,  TARGET7_RLAST,
                            TARGET8_RLAST,  TARGET9_RLAST,  TARGET10_RLAST, TARGET11_RLAST, TARGET12_RLAST, TARGET13_RLAST, TARGET14_RLAST, TARGET15_RLAST, 
                            TARGET16_RLAST, TARGET17_RLAST, TARGET18_RLAST, TARGET19_RLAST, TARGET20_RLAST, TARGET21_RLAST, TARGET22_RLAST, TARGET23_RLAST, 
                            TARGET24_RLAST, TARGET25_RLAST, TARGET26_RLAST, TARGET27_RLAST, TARGET28_RLAST, TARGET29_RLAST, TARGET30_RLAST, TARGET31_RLAST;
                                            
                                            
 wire [USER_WIDTH-1:0]      TARGET0_RUSER,  TARGET1_RUSER,  TARGET2_RUSER,  TARGET3_RUSER,  TARGET4_RUSER,  TARGET5_RUSER,  TARGET6_RUSER,  TARGET7_RUSER,
                            TARGET8_RUSER,  TARGET9_RUSER,  TARGET10_RUSER, TARGET11_RUSER, TARGET12_RUSER, TARGET13_RUSER, TARGET14_RUSER, TARGET15_RUSER, 
                            TARGET16_RUSER, TARGET17_RUSER, TARGET18_RUSER, TARGET19_RUSER, TARGET20_RUSER, TARGET21_RUSER, TARGET22_RUSER, TARGET23_RUSER, 
                            TARGET24_RUSER, TARGET25_RUSER, TARGET26_RUSER, TARGET27_RUSER, TARGET28_RUSER, TARGET29_RUSER, TARGET30_RUSER, TARGET31_RUSER;
                                            
                                            
 wire                       TARGET0_RVALID,  TARGET1_RVALID,  TARGET2_RVALID,  TARGET3_RVALID,  TARGET4_RVALID,  TARGET5_RVALID,  TARGET6_RVALID,   TARGET7_RVALID,
                            TARGET8_RVALID,  TARGET9_RVALID,  TARGET10_RVALID, TARGET11_RVALID, TARGET12_RVALID, TARGET13_RVALID, TARGET14_RVALID, TARGET15_RVALID, 
                            TARGET16_RVALID, TARGET17_RVALID, TARGET18_RVALID, TARGET19_RVALID, TARGET20_RVALID, TARGET21_RVALID, TARGET22_RVALID, TARGET23_RVALID, 
                            TARGET24_RVALID, TARGET25_RVALID, TARGET26_RVALID, TARGET27_RVALID, TARGET28_RVALID, TARGET29_RVALID, TARGET30_RVALID, TARGET31_RVALID;
                                            
                                            
 wire                       TARGET0_RREADY,  TARGET1_RREADY,  TARGET2_RREADY,  TARGET3_RREADY,  TARGET4_RREADY,  TARGET5_RREADY,  TARGET6_RREADY,  TARGET7_RREADY,
                            TARGET8_RREADY,  TARGET9_RREADY,  TARGET10_RREADY, TARGET11_RREADY, TARGET12_RREADY, TARGET13_RREADY, TARGET14_RREADY, TARGET15_RREADY, 
                            TARGET16_RREADY, TARGET17_RREADY, TARGET18_RREADY, TARGET19_RREADY, TARGET20_RREADY, TARGET21_RREADY, TARGET22_RREADY, TARGET23_RREADY, 
                            TARGET24_RREADY, TARGET25_RREADY, TARGET26_RREADY, TARGET27_RREADY, TARGET28_RREADY, TARGET29_RREADY, TARGET30_RREADY, TARGET31_RREADY;
   
  
  wire[8-1:0] I_CLK;
  wire[32-1:0] T_CLK;

  reg [ADDR_WIDTH-1:0] next_addr, offset_addr;

  generate
  if(INITIATOR0_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[0] = I_CLK0;
  else
    assign I_CLK[0] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR1_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[1] = I_CLK1;
  else
    assign I_CLK[1] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR2_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[2] = I_CLK2;
  else
    assign I_CLK[2] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR3_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[3] = I_CLK3;
  else
    assign I_CLK[3] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR4_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[4] = I_CLK4;
  else
    assign I_CLK[4] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR5_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[5] = I_CLK5;
  else
    assign I_CLK[5] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR6_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[6] = I_CLK6;
  else
    assign I_CLK[6] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR7_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[7] = I_CLK7;
  else
    assign I_CLK[7] = ACLK;
  endgenerate
  
  generate
  if(TARGET0_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[0] = T_CLK0;
  else
    assign T_CLK[0] = ACLK;
  endgenerate
  
  generate
  if(TARGET1_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[1] = T_CLK1;
  else
    assign T_CLK[1] = ACLK;
  endgenerate
  
  generate
  if(TARGET2_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[2] = T_CLK2;
  else
    assign T_CLK[2] = ACLK;
  endgenerate
  
  generate
  if(TARGET3_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[3] = T_CLK3;
  else
    assign T_CLK[3] = ACLK;
  endgenerate
  
  generate
  if(TARGET4_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[4] = T_CLK4;
  else
    assign T_CLK[4] = ACLK;
  endgenerate
  
  generate
  if(TARGET5_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[5] = T_CLK5;
  else
    assign T_CLK[5] = ACLK;
  endgenerate
  
  generate
  if(TARGET6_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[6] = T_CLK6;
  else
    assign T_CLK[6] = ACLK;
  endgenerate
  
  generate
  if(TARGET7_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[7] = T_CLK7;
  else
    assign T_CLK[7] = ACLK;
  endgenerate
  
  generate
  if(TARGET8_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[8] = T_CLK8;
  else
    assign T_CLK[8] = ACLK;
  endgenerate
  
  generate
  if(TARGET9_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[9] = T_CLK9;
  else
    assign T_CLK[9] = ACLK;
  endgenerate
  
  generate
  if(TARGET10_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[10] = T_CLK10;
  else
    assign T_CLK[10] = ACLK;
  endgenerate
  
  generate
  if(TARGET11_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[11] = T_CLK11;
  else
    assign T_CLK[11] = ACLK;
  endgenerate
  
  generate
  if(TARGET12_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[12] = T_CLK12;
  else
    assign T_CLK[12] = ACLK;
  endgenerate
  
  generate
  if(TARGET13_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[13] = T_CLK13;
  else
    assign T_CLK[13] = ACLK;
  endgenerate
  
  generate
  if(TARGET14_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[14] = T_CLK14;
  else
    assign T_CLK[14] = ACLK;
  endgenerate
  
  generate
  if(TARGET15_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[15] = T_CLK15;
  else
    assign T_CLK[15] = ACLK;
  endgenerate
  
  generate
  if(TARGET16_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[16] = T_CLK16;
  else
    assign T_CLK[16] = ACLK;
  endgenerate
  
  generate
  if(TARGET17_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[17] = T_CLK17;
  else
    assign T_CLK[17] = ACLK;
  endgenerate
  
  generate
  if(TARGET18_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[18] = T_CLK18;
  else
    assign T_CLK[18] = ACLK;
  endgenerate
  
  generate
  if(TARGET19_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[19] = T_CLK19;
  else
    assign T_CLK[19] = ACLK;
  endgenerate
  
  generate
  if(TARGET20_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[20] = T_CLK20;
  else
    assign T_CLK[20] = ACLK;
  endgenerate
  
  generate
  if(TARGET21_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[21] = T_CLK21;
  else
    assign T_CLK[21] = ACLK;
  endgenerate
  
  generate
  if(TARGET22_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[22] = T_CLK22;
  else
    assign T_CLK[22] = ACLK;
  endgenerate
  
  generate
  if(TARGET23_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[23] = T_CLK23;
  else
    assign T_CLK[23] = ACLK;
  endgenerate
  
  generate
  if(TARGET24_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[24] = T_CLK24;
  else
    assign T_CLK[24] = ACLK;
  endgenerate
  
  generate
  if(TARGET25_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[25] = T_CLK25;
  else
    assign T_CLK[25] = ACLK;
  endgenerate
  
  generate
  if(TARGET26_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[26] = T_CLK26;
  else
    assign T_CLK[26] = ACLK;
  endgenerate
  
  generate
  if(TARGET27_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[27] = T_CLK27;
  else
    assign T_CLK[27] = ACLK;
  endgenerate
  
  generate
  if(TARGET28_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[28] = T_CLK28;
  else
    assign T_CLK[28] = ACLK;
  endgenerate
  
  generate
  if(TARGET29_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[29] = T_CLK29;
  else
    assign T_CLK[29] = ACLK;
  endgenerate
  
  generate
  if(TARGET30_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[30] = T_CLK30;
  else
    assign T_CLK[30] = ACLK;
  endgenerate
  
  generate
  if(TARGET31_CLOCK_DOMAIN_CROSSING)
    assign T_CLK[31] = T_CLK31;
  else
    assign T_CLK[31] = ACLK;
  endgenerate
  
  //==================================================================================================================================//

`ifdef WRAPPER_EN
  CoreAXI4Interconnect_w #
`else
  COREAXI4INTERCONNECT #
`endif
    (
      //=====================================================================
      // Global // parameters
      //=====================================================================
      .FAMILY               ( FAMILY ), 
      .NUM_INITIATORS       ( NUM_INITIATORS ),  // defines number of initiator ports 
	  .NUM_INITIATORS_WIDTH (NUM_INITIATORS_WIDTH),
      .NUM_TARGETS          ( NUM_TARGETS ),   // defines number of targets
      .ID_WIDTH             ( ID_WIDTH ),     // number of bits for ID (ie AID, WID, BID) - valid 1-8 
      .ADDR_WIDTH           ( ADDR_WIDTH ),   // valid values - 16 - 64
      .ADDR_WIDTH_INT       ( ADDR_WIDTH < 33 ? ADDR_WIDTH : 32),   // valid values - 16 - 64
      //====================================================================
      // Crossbar // parameters
      //====================================================================
      .DATA_WIDTH          ( DATA_WIDTH  ),        // valid widths - 32, 64, 128

      .MAX_OUTSTNDG_TRANS  ( OPEN_TRANS_MAX ),    // max number of outstanding transactions per thread - valid range 1-8

      .TARGET0_START_ADDR  ( TARGET0_START_ADDR   ),      // TARGET0 Start address
      .TARGET1_START_ADDR  ( TARGET1_START_ADDR   ),      // TARGET1 Start address
      .TARGET2_START_ADDR  ( TARGET2_START_ADDR   ),      // TARGET2 Start address
      .TARGET3_START_ADDR  ( TARGET3_START_ADDR   ),      // TARGET3 Start address
      .TARGET4_START_ADDR  ( TARGET4_START_ADDR   ),      // TARGET4 Start address
      .TARGET5_START_ADDR  ( TARGET5_START_ADDR   ),      // TARGET5 Start address
      .TARGET6_START_ADDR  ( TARGET6_START_ADDR   ),      // TARGET6 Start address
      .TARGET7_START_ADDR  ( TARGET7_START_ADDR   ),      // TARGET7 Start address
      .TARGET8_START_ADDR  ( TARGET8_START_ADDR   ),      // TARGET8 Start address
      .TARGET9_START_ADDR  ( TARGET9_START_ADDR   ),      // TARGET2 Start address
      .TARGET10_START_ADDR  ( TARGET10_START_ADDR   ),      // TARGET3 Start address
      .TARGET11_START_ADDR  ( TARGET11_START_ADDR   ),      // TARGET4 Start address
      .TARGET12_START_ADDR  ( TARGET12_START_ADDR   ),      // TARGET5 Start address
      .TARGET13_START_ADDR  ( TARGET13_START_ADDR   ),      // TARGET6 Start address
      .TARGET14_START_ADDR  ( TARGET14_START_ADDR   ),      // TARGET7 Start address
      .TARGET15_START_ADDR  ( TARGET15_START_ADDR   ),      // TARGET8 Start address
	  
      .TARGET0_START_ADDR_UPPER  ( 0  ),      // TARGET0 Start address
      .TARGET1_START_ADDR_UPPER  ( 0  ),      // TARGET1 Start address
      .TARGET2_START_ADDR_UPPER  ( 0  ),      // TARGET2 Start address
      .TARGET3_START_ADDR_UPPER  ( 0  ),      // TARGET3 Start address
      .TARGET4_START_ADDR_UPPER  ( 0  ),      // TARGET4 Start address
      .TARGET5_START_ADDR_UPPER  ( 0  ),      // TARGET5 Start address
      .TARGET6_START_ADDR_UPPER  ( 0  ),      // TARGET6 Start address
      .TARGET7_START_ADDR_UPPER  ( 0  ),      // TARGET7 Start address
      .TARGET8_START_ADDR_UPPER  ( 0  ),      // TARGET8 Start address
      .TARGET9_START_ADDR_UPPER  ( 0  ),      // TARGET2 Start address
      .TARGET10_START_ADDR_UPPER  ( 0  ),      // TARGET3 Start address
      .TARGET11_START_ADDR_UPPER  ( 0  ),      // TARGET4 Start address
      .TARGET12_START_ADDR_UPPER  ( 0  ),      // TARGET5 Start address
      .TARGET13_START_ADDR_UPPER  ( 0  ),      // TARGET6 Start address
      .TARGET14_START_ADDR_UPPER  ( 0  ),      // TARGET7 Start address
      .TARGET15_START_ADDR_UPPER  ( 0  ),      // TARGET8 Start address
	  
      .TARGET0_END_ADDR    ( TARGET0_END_ADDR ),  // TARGET0 End address
      .TARGET1_END_ADDR    ( TARGET1_END_ADDR ),  // TARGET1 End address
      .TARGET2_END_ADDR    ( TARGET2_END_ADDR ),  // TARGET2 End address
      .TARGET3_END_ADDR    ( TARGET3_END_ADDR ),  // TARGET3 End address
      .TARGET4_END_ADDR    ( TARGET4_END_ADDR ),  // TARGET4 End address
      .TARGET5_END_ADDR    ( TARGET5_END_ADDR ),  // TARGET5 End address
      .TARGET6_END_ADDR    ( TARGET6_END_ADDR ),  // TARGET6 End address
      .TARGET7_END_ADDR    ( TARGET7_END_ADDR ),  // TARGET7 End address
      .TARGET8_END_ADDR    ( TARGET8_END_ADDR ),  // TARGET8 End address
      .TARGET9_END_ADDR    ( TARGET9_END_ADDR ),  // TARGET2 End address
      .TARGET10_END_ADDR    ( TARGET10_END_ADDR ),  // TARGET3 End address
      .TARGET11_END_ADDR    ( TARGET11_END_ADDR ),  // TARGET4 End address
      .TARGET12_END_ADDR    ( TARGET12_END_ADDR ),  // TARGET5 End address
      .TARGET13_END_ADDR    ( TARGET13_END_ADDR ),  // TARGET6 End address
      .TARGET14_END_ADDR    ( TARGET14_END_ADDR ),  // TARGET7 End address
      .TARGET15_END_ADDR    ( TARGET15_END_ADDR ),  // TARGET8 End address
	  
      .TARGET0_END_ADDR_UPPER    ( 0 ),  // TARGET0 End address
      .TARGET1_END_ADDR_UPPER    ( 0 ),  // TARGET1 End address
      .TARGET2_END_ADDR_UPPER    ( 0 ),  // TARGET2 End address
      .TARGET3_END_ADDR_UPPER    ( 0 ),  // TARGET3 End address
      .TARGET4_END_ADDR_UPPER    ( 0 ),  // TARGET4 End address
      .TARGET5_END_ADDR_UPPER    ( 0 ),  // TARGET5 End address
      .TARGET6_END_ADDR_UPPER    ( 0 ),  // TARGET6 End address
      .TARGET7_END_ADDR_UPPER    ( 0 ),  // TARGET7 End address
      .TARGET8_END_ADDR_UPPER    ( 0 ),  // TARGET8 End address
      .TARGET9_END_ADDR_UPPER    ( 0 ),  // TARGET2 End address
      .TARGET10_END_ADDR_UPPER    ( 0 ),  // TARGET3 End address
      .TARGET11_END_ADDR_UPPER    ( 0 ),  // TARGET4 End address
      .TARGET12_END_ADDR_UPPER    ( 0 ),  // TARGET5 End address
      .TARGET13_END_ADDR_UPPER    ( 0 ),  // TARGET6 End address
      .TARGET14_END_ADDR_UPPER    ( 0 ),  // TARGET7 End address
      .TARGET15_END_ADDR_UPPER    ( 0 ),  // TARGET8 End address
	  
      .USER_WIDTH       ( USER_WIDTH       ),     // defines the number of bits for USER signals RUSER and WUSER
      .CROSSBAR_MODE      ( CROSSBAR_MODE      ),    // defines whether non-blocking (ie set 1) or shared access data path

      //.INITIATOR0_DEF_BURST_LEN( INITIATOR0_DEF_BURST_LEN ),
      //.INITIATOR1_DEF_BURST_LEN( INITIATOR1_DEF_BURST_LEN ),
      //.INITIATOR2_DEF_BURST_LEN( INITIATOR2_DEF_BURST_LEN ),
      //.INITIATOR3_DEF_BURST_LEN( INITIATOR3_DEF_BURST_LEN ),
      //.INITIATOR4_DEF_BURST_LEN( INITIATOR4_DEF_BURST_LEN ),
      //.INITIATOR5_DEF_BURST_LEN( INITIATOR5_DEF_BURST_LEN ),
      //.INITIATOR6_DEF_BURST_LEN( INITIATOR6_DEF_BURST_LEN ),
      //.INITIATOR7_DEF_BURST_LEN( INITIATOR7_DEF_BURST_LEN ),

      .TARGET0_DWC_DATA_FIFO_DEPTH( TARGET0_DWC_DATA_FIFO_DEPTH ),
      .TARGET1_DWC_DATA_FIFO_DEPTH( TARGET1_DWC_DATA_FIFO_DEPTH ),
      .TARGET2_DWC_DATA_FIFO_DEPTH( TARGET2_DWC_DATA_FIFO_DEPTH ),
      .TARGET3_DWC_DATA_FIFO_DEPTH( TARGET3_DWC_DATA_FIFO_DEPTH ),
      .TARGET4_DWC_DATA_FIFO_DEPTH( TARGET4_DWC_DATA_FIFO_DEPTH ),
      .TARGET5_DWC_DATA_FIFO_DEPTH( TARGET5_DWC_DATA_FIFO_DEPTH ),
      .TARGET6_DWC_DATA_FIFO_DEPTH( TARGET6_DWC_DATA_FIFO_DEPTH ),
      .TARGET7_DWC_DATA_FIFO_DEPTH( TARGET7_DWC_DATA_FIFO_DEPTH ),
      .TARGET8_DWC_DATA_FIFO_DEPTH( TARGET8_DWC_DATA_FIFO_DEPTH ),
	  .TARGET9_DWC_DATA_FIFO_DEPTH( TARGET9_DWC_DATA_FIFO_DEPTH ),
	  .TARGET10_DWC_DATA_FIFO_DEPTH( TARGET10_DWC_DATA_FIFO_DEPTH ),
	  .TARGET11_DWC_DATA_FIFO_DEPTH( TARGET11_DWC_DATA_FIFO_DEPTH ),
	  .TARGET12_DWC_DATA_FIFO_DEPTH( TARGET12_DWC_DATA_FIFO_DEPTH ),
	  .TARGET13_DWC_DATA_FIFO_DEPTH( TARGET13_DWC_DATA_FIFO_DEPTH ),
	  .TARGET14_DWC_DATA_FIFO_DEPTH( TARGET14_DWC_DATA_FIFO_DEPTH ),
	  .TARGET15_DWC_DATA_FIFO_DEPTH( TARGET15_DWC_DATA_FIFO_DEPTH ),
	 
      .INITIATOR0_DWC_DATA_FIFO_DEPTH( INITIATOR0_DWC_DATA_FIFO_DEPTH ),
      .INITIATOR1_DWC_DATA_FIFO_DEPTH( INITIATOR1_DWC_DATA_FIFO_DEPTH ),
      .INITIATOR2_DWC_DATA_FIFO_DEPTH( INITIATOR2_DWC_DATA_FIFO_DEPTH ),
      .INITIATOR3_DWC_DATA_FIFO_DEPTH( INITIATOR3_DWC_DATA_FIFO_DEPTH ),
      .INITIATOR4_DWC_DATA_FIFO_DEPTH( INITIATOR4_DWC_DATA_FIFO_DEPTH ),
      .INITIATOR5_DWC_DATA_FIFO_DEPTH( INITIATOR5_DWC_DATA_FIFO_DEPTH ),
      .INITIATOR6_DWC_DATA_FIFO_DEPTH( INITIATOR6_DWC_DATA_FIFO_DEPTH ),
      .INITIATOR7_DWC_DATA_FIFO_DEPTH( INITIATOR7_DWC_DATA_FIFO_DEPTH ),

      .INITIATOR0_WRITE_TARGET0  ( INITIATOR0_WRITE_TARGET0  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR0_WRITE_TARGET1  ( INITIATOR0_WRITE_TARGET1  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR0_WRITE_TARGET2  ( INITIATOR0_WRITE_TARGET2  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR0_WRITE_TARGET3  ( INITIATOR0_WRITE_TARGET3  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR0_WRITE_TARGET4  ( INITIATOR0_WRITE_TARGET4  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR0_WRITE_TARGET5  ( INITIATOR0_WRITE_TARGET5  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR0_WRITE_TARGET6  ( INITIATOR0_WRITE_TARGET6  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR0_WRITE_TARGET7  ( INITIATOR0_WRITE_TARGET7  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR0_WRITE_TARGET8  ( INITIATOR0_WRITE_TARGET8  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR0_WRITE_TARGET9  ( INITIATOR0_WRITE_TARGET9  ),   // bit for target indicating if an initiator can access that port
	  .INITIATOR0_WRITE_TARGET10  ( INITIATOR0_WRITE_TARGET10  ),   // bit for target indicating if an initiator can access that port
	  .INITIATOR0_WRITE_TARGET11  ( INITIATOR0_WRITE_TARGET11  ),   // bit for target indicating if an initiator can access that port
	  .INITIATOR0_WRITE_TARGET12  ( INITIATOR0_WRITE_TARGET12  ),   // bit for target indicating if an initiator can access that port
	  .INITIATOR0_WRITE_TARGET13  ( INITIATOR0_WRITE_TARGET13  ),   // bit for target indicating if an initiator can access that port
	  .INITIATOR0_WRITE_TARGET14  ( INITIATOR0_WRITE_TARGET14  ),   // bit for target indicating if an initiator can access that port
	  .INITIATOR0_WRITE_TARGET15  ( INITIATOR0_WRITE_TARGET15  ),   // bit for target indicating if an initiator can access that port
										  
      .INITIATOR1_WRITE_TARGET0  ( INITIATOR1_WRITE_TARGET0  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR1_WRITE_TARGET1  ( INITIATOR1_WRITE_TARGET1  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR1_WRITE_TARGET2  ( INITIATOR1_WRITE_TARGET2  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR1_WRITE_TARGET3  ( INITIATOR1_WRITE_TARGET3  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR1_WRITE_TARGET4  ( INITIATOR1_WRITE_TARGET4  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR1_WRITE_TARGET5  ( INITIATOR1_WRITE_TARGET5  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR1_WRITE_TARGET6  ( INITIATOR1_WRITE_TARGET6  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR1_WRITE_TARGET7  ( INITIATOR1_WRITE_TARGET7  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR2_WRITE_TARGET0  ( INITIATOR2_WRITE_TARGET0  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR2_WRITE_TARGET1  ( INITIATOR2_WRITE_TARGET1  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR2_WRITE_TARGET2  ( INITIATOR2_WRITE_TARGET2  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR2_WRITE_TARGET3  ( INITIATOR2_WRITE_TARGET3  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR2_WRITE_TARGET4  ( INITIATOR2_WRITE_TARGET4  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR2_WRITE_TARGET5  ( INITIATOR2_WRITE_TARGET5  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR2_WRITE_TARGET6  ( INITIATOR2_WRITE_TARGET6  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR2_WRITE_TARGET7  ( INITIATOR2_WRITE_TARGET7  ),   // bit for target indicating if an initiator can access that port  
      .INITIATOR3_WRITE_TARGET0  ( INITIATOR3_WRITE_TARGET0  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR3_WRITE_TARGET1  ( INITIATOR3_WRITE_TARGET1  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR3_WRITE_TARGET2  ( INITIATOR3_WRITE_TARGET2  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR3_WRITE_TARGET3  ( INITIATOR3_WRITE_TARGET3  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR3_WRITE_TARGET4  ( INITIATOR3_WRITE_TARGET4  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR3_WRITE_TARGET5  ( INITIATOR3_WRITE_TARGET5  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR3_WRITE_TARGET6  ( INITIATOR3_WRITE_TARGET6  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR3_WRITE_TARGET7  ( INITIATOR3_WRITE_TARGET7  ),   // bit for target indicating if an initiator can access that port  
      .INITIATOR4_WRITE_TARGET0  ( INITIATOR4_WRITE_TARGET0  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR4_WRITE_TARGET1  ( INITIATOR4_WRITE_TARGET1  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR4_WRITE_TARGET2  ( INITIATOR4_WRITE_TARGET2  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR4_WRITE_TARGET3  ( INITIATOR4_WRITE_TARGET3  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR4_WRITE_TARGET4  ( INITIATOR4_WRITE_TARGET4  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR4_WRITE_TARGET5  ( INITIATOR4_WRITE_TARGET5  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR4_WRITE_TARGET6  ( INITIATOR4_WRITE_TARGET6  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR4_WRITE_TARGET7  ( INITIATOR4_WRITE_TARGET7  ),   // bit for target indicating if an initiator can access that port  
      .INITIATOR5_WRITE_TARGET0  ( INITIATOR5_WRITE_TARGET0  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR5_WRITE_TARGET1  ( INITIATOR5_WRITE_TARGET1  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR5_WRITE_TARGET2  ( INITIATOR5_WRITE_TARGET2  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR5_WRITE_TARGET3  ( INITIATOR5_WRITE_TARGET3  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR5_WRITE_TARGET4  ( INITIATOR5_WRITE_TARGET4  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR5_WRITE_TARGET5  ( INITIATOR5_WRITE_TARGET5  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR5_WRITE_TARGET6  ( INITIATOR5_WRITE_TARGET6  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR5_WRITE_TARGET7  ( INITIATOR5_WRITE_TARGET7  ),   // bit for target indicating if an initiator can access that port  
      .INITIATOR6_WRITE_TARGET0  ( INITIATOR6_WRITE_TARGET0  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR6_WRITE_TARGET1  ( INITIATOR6_WRITE_TARGET1  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR6_WRITE_TARGET2  ( INITIATOR6_WRITE_TARGET2  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR6_WRITE_TARGET3  ( INITIATOR6_WRITE_TARGET3  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR6_WRITE_TARGET4  ( INITIATOR6_WRITE_TARGET4  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR6_WRITE_TARGET5  ( INITIATOR6_WRITE_TARGET5  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR6_WRITE_TARGET6  ( INITIATOR6_WRITE_TARGET6  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR6_WRITE_TARGET7  ( INITIATOR6_WRITE_TARGET7  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR7_WRITE_TARGET0  ( INITIATOR7_WRITE_TARGET0  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR7_WRITE_TARGET1  ( INITIATOR7_WRITE_TARGET1  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR7_WRITE_TARGET2  ( INITIATOR7_WRITE_TARGET2  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR7_WRITE_TARGET3  ( INITIATOR7_WRITE_TARGET3  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR7_WRITE_TARGET4  ( INITIATOR7_WRITE_TARGET4  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR7_WRITE_TARGET5  ( INITIATOR7_WRITE_TARGET5  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR7_WRITE_TARGET6  ( INITIATOR7_WRITE_TARGET6  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR7_WRITE_TARGET7  ( INITIATOR7_WRITE_TARGET7  ),   // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET0  ( INITIATOR0_READ_TARGET0  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET1  ( INITIATOR0_READ_TARGET1  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET2  ( INITIATOR0_READ_TARGET2  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET3  ( INITIATOR0_READ_TARGET3  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET4  ( INITIATOR0_READ_TARGET4  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET5  ( INITIATOR0_READ_TARGET5  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET6  ( INITIATOR0_READ_TARGET6  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET7  ( INITIATOR0_READ_TARGET7  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET8  ( INITIATOR0_READ_TARGET8  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET9  ( INITIATOR0_READ_TARGET9  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET10  ( INITIATOR0_READ_TARGET10  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET11  ( INITIATOR0_READ_TARGET11  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET12  ( INITIATOR0_READ_TARGET12  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET13  ( INITIATOR0_READ_TARGET13  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET14  ( INITIATOR0_READ_TARGET14  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR0_READ_TARGET15  ( INITIATOR0_READ_TARGET15  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET0  ( INITIATOR1_READ_TARGET0  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET1  ( INITIATOR1_READ_TARGET1  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET2  ( INITIATOR1_READ_TARGET2  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET3  ( INITIATOR1_READ_TARGET3  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET4  ( INITIATOR1_READ_TARGET4  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET5  ( INITIATOR1_READ_TARGET5  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET6  ( INITIATOR1_READ_TARGET6  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET7  ( INITIATOR1_READ_TARGET7  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET8  ( INITIATOR1_READ_TARGET8  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET9  ( INITIATOR1_READ_TARGET9  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET10  ( INITIATOR1_READ_TARGET10  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET11  ( INITIATOR1_READ_TARGET11  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET12  ( INITIATOR1_READ_TARGET12  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET13  ( INITIATOR1_READ_TARGET13  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET14  ( INITIATOR1_READ_TARGET14  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR1_READ_TARGET15  ( INITIATOR1_READ_TARGET15  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR2_READ_TARGET0  ( INITIATOR2_READ_TARGET0  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR2_READ_TARGET1  ( INITIATOR2_READ_TARGET1  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR2_READ_TARGET2  ( INITIATOR2_READ_TARGET2  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR2_READ_TARGET3  ( INITIATOR2_READ_TARGET3  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR2_READ_TARGET4  ( INITIATOR2_READ_TARGET4  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR2_READ_TARGET5  ( INITIATOR2_READ_TARGET5  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR2_READ_TARGET6  ( INITIATOR2_READ_TARGET6  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR2_READ_TARGET7  ( INITIATOR2_READ_TARGET7  ),  // bit for target indicating if an initiator can access that port  
      .INITIATOR3_READ_TARGET0  ( INITIATOR3_READ_TARGET0  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR3_READ_TARGET1  ( INITIATOR3_READ_TARGET1  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR3_READ_TARGET2  ( INITIATOR3_READ_TARGET2  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR3_READ_TARGET3  ( INITIATOR3_READ_TARGET3  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR3_READ_TARGET4  ( INITIATOR3_READ_TARGET4  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR3_READ_TARGET5  ( INITIATOR3_READ_TARGET5  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR3_READ_TARGET6  ( INITIATOR3_READ_TARGET6  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR3_READ_TARGET7  ( INITIATOR3_READ_TARGET7  ),  // bit for target indicating if an initiator can access that port  
      .INITIATOR4_READ_TARGET0  ( INITIATOR4_READ_TARGET0  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR4_READ_TARGET1  ( INITIATOR4_READ_TARGET1  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR4_READ_TARGET2  ( INITIATOR4_READ_TARGET2  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR4_READ_TARGET3  ( INITIATOR4_READ_TARGET3  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR4_READ_TARGET4  ( INITIATOR4_READ_TARGET4  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR4_READ_TARGET5  ( INITIATOR4_READ_TARGET5  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR4_READ_TARGET6  ( INITIATOR4_READ_TARGET6  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR4_READ_TARGET7  ( INITIATOR4_READ_TARGET7  ),  // bit for target indicating if an initiator can access that port  
      .INITIATOR5_READ_TARGET0  ( INITIATOR5_READ_TARGET0  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR5_READ_TARGET1  ( INITIATOR5_READ_TARGET1  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR5_READ_TARGET2  ( INITIATOR5_READ_TARGET2  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR5_READ_TARGET3  ( INITIATOR5_READ_TARGET3  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR5_READ_TARGET4  ( INITIATOR5_READ_TARGET4  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR5_READ_TARGET5  ( INITIATOR5_READ_TARGET5  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR5_READ_TARGET6  ( INITIATOR5_READ_TARGET6  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR5_READ_TARGET7  ( INITIATOR5_READ_TARGET7  ),  // bit for target indicating if an initiator can access that port  
      .INITIATOR6_READ_TARGET0  ( INITIATOR6_READ_TARGET0  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR6_READ_TARGET1  ( INITIATOR6_READ_TARGET1  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR6_READ_TARGET2  ( INITIATOR6_READ_TARGET2  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR6_READ_TARGET3  ( INITIATOR6_READ_TARGET3  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR6_READ_TARGET4  ( INITIATOR6_READ_TARGET4  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR6_READ_TARGET5  ( INITIATOR6_READ_TARGET5  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR6_READ_TARGET6  ( INITIATOR6_READ_TARGET6  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR6_READ_TARGET7  ( INITIATOR6_READ_TARGET7  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR7_READ_TARGET0  ( INITIATOR7_READ_TARGET0  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR7_READ_TARGET1  ( INITIATOR7_READ_TARGET1  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR7_READ_TARGET2  ( INITIATOR7_READ_TARGET2  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR7_READ_TARGET3  ( INITIATOR7_READ_TARGET3  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR7_READ_TARGET4  ( INITIATOR7_READ_TARGET4  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR7_READ_TARGET5  ( INITIATOR7_READ_TARGET5  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR7_READ_TARGET6  ( INITIATOR7_READ_TARGET6  ),  // bit for target indicating if an initiator can access that port
      .INITIATOR7_READ_TARGET7  ( INITIATOR7_READ_TARGET7  ),  // bit for target indicating if an initiator can access that port

      .RD_ARB_EN     ( RD_ARB_EN  ),      // select arb or ordered rdata

      //====================================================================
      // Port Protocol Convertor // parameters
      //====================================================================
      .INITIATOR0_DATA_WIDTH ( INITIATOR0_DATA_WIDTH ),      // Defines data width of Initiator0
      .INITIATOR1_DATA_WIDTH ( INITIATOR1_DATA_WIDTH ),      // Defines data width of Initiator1
      .INITIATOR2_DATA_WIDTH ( INITIATOR2_DATA_WIDTH ),      // Defines data width of Initiator2
      .INITIATOR3_DATA_WIDTH ( INITIATOR3_DATA_WIDTH ),      // Defines data width of Initiator3
      .INITIATOR4_DATA_WIDTH ( INITIATOR4_DATA_WIDTH ),      // Defines data width of Initiator4
      .INITIATOR5_DATA_WIDTH ( INITIATOR5_DATA_WIDTH ),      // Defines data width of Initiator5
      .INITIATOR6_DATA_WIDTH ( INITIATOR6_DATA_WIDTH ),      // Defines data width of Initiator6
      .INITIATOR7_DATA_WIDTH ( INITIATOR7_DATA_WIDTH ),      // Defines data width of Initiator7
 
	  .TARGET0_DATA_WIDTH ( TARGET0_DATA_WIDTH ),      // Defines data width of Target0
      .TARGET1_DATA_WIDTH ( TARGET1_DATA_WIDTH ),      // Defines data width of Target1
      .TARGET2_DATA_WIDTH ( TARGET2_DATA_WIDTH ),      // Defines data width of Target2
      .TARGET3_DATA_WIDTH ( TARGET3_DATA_WIDTH ),      // Defines data width of Target3
      .TARGET4_DATA_WIDTH ( TARGET4_DATA_WIDTH ),      // Defines data width of Target4
      .TARGET5_DATA_WIDTH ( TARGET5_DATA_WIDTH ),      // Defines data width of Target5
      .TARGET6_DATA_WIDTH ( TARGET6_DATA_WIDTH ),      // Defines data width of Target6
      .TARGET7_DATA_WIDTH ( TARGET7_DATA_WIDTH ),      // Defines data width of Target7
      .TARGET8_DATA_WIDTH ( TARGET8_DATA_WIDTH ),      // Defines data width of Target8
      .TARGET9_DATA_WIDTH ( TARGET9_DATA_WIDTH ),      // Defines data width of Target9
      .TARGET10_DATA_WIDTH ( TARGET10_DATA_WIDTH ),      // Defines data width of Target10
      .TARGET11_DATA_WIDTH ( TARGET11_DATA_WIDTH ),      // Defines data width of Target11
      .TARGET12_DATA_WIDTH ( TARGET12_DATA_WIDTH ),      // Defines data width of Target12
      .TARGET13_DATA_WIDTH ( TARGET13_DATA_WIDTH ),      // Defines data width of Target13
      .TARGET14_DATA_WIDTH ( TARGET14_DATA_WIDTH ),      // Defines data width of Target14
      .TARGET15_DATA_WIDTH ( TARGET15_DATA_WIDTH ),      // Defines data width of Target15
	  
      .INITIATOR0_TYPE  ( INITIATOR0_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .INITIATOR1_TYPE  ( INITIATOR1_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .INITIATOR2_TYPE  ( INITIATOR2_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .INITIATOR3_TYPE  ( INITIATOR3_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .INITIATOR4_TYPE  ( INITIATOR4_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .INITIATOR5_TYPE  ( INITIATOR5_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .INITIATOR6_TYPE  ( INITIATOR6_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .INITIATOR7_TYPE  ( INITIATOR7_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET0_TYPE  ( TARGET0_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET1_TYPE  ( TARGET1_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET2_TYPE  ( TARGET2_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET3_TYPE  ( TARGET3_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET4_TYPE  ( TARGET4_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET5_TYPE  ( TARGET5_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET6_TYPE  ( TARGET6_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET7_TYPE  ( TARGET7_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET8_TYPE  ( TARGET8_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET9_TYPE  ( TARGET9_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET10_TYPE  ( TARGET10_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET11_TYPE  ( TARGET11_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET12_TYPE  ( TARGET12_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET13_TYPE  ( TARGET13_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET14_TYPE  ( TARGET14_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
      .TARGET15_TYPE  ( TARGET15_TYPE   ),    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
	  
      .INITIATOR0_CLOCK_DOMAIN_CROSSING  ( INITIATOR0_CLOCK_DOMAIN_CROSSING   ),    
      .INITIATOR1_CLOCK_DOMAIN_CROSSING  ( INITIATOR1_CLOCK_DOMAIN_CROSSING   ),    
      .INITIATOR2_CLOCK_DOMAIN_CROSSING  ( INITIATOR2_CLOCK_DOMAIN_CROSSING   ),    
      .INITIATOR3_CLOCK_DOMAIN_CROSSING  ( INITIATOR3_CLOCK_DOMAIN_CROSSING   ),    
      .INITIATOR4_CLOCK_DOMAIN_CROSSING  ( INITIATOR4_CLOCK_DOMAIN_CROSSING   ),    
      .INITIATOR5_CLOCK_DOMAIN_CROSSING  ( INITIATOR5_CLOCK_DOMAIN_CROSSING   ),    
      .INITIATOR6_CLOCK_DOMAIN_CROSSING  ( INITIATOR6_CLOCK_DOMAIN_CROSSING   ),    
      .INITIATOR7_CLOCK_DOMAIN_CROSSING  ( INITIATOR7_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET0_CLOCK_DOMAIN_CROSSING  ( TARGET0_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET1_CLOCK_DOMAIN_CROSSING  ( TARGET1_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET2_CLOCK_DOMAIN_CROSSING  ( TARGET2_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET3_CLOCK_DOMAIN_CROSSING  ( TARGET3_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET4_CLOCK_DOMAIN_CROSSING  ( TARGET4_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET5_CLOCK_DOMAIN_CROSSING  ( TARGET5_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET6_CLOCK_DOMAIN_CROSSING  ( TARGET6_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET7_CLOCK_DOMAIN_CROSSING  ( TARGET7_CLOCK_DOMAIN_CROSSING   ),
      .TARGET8_CLOCK_DOMAIN_CROSSING  ( TARGET8_CLOCK_DOMAIN_CROSSING   ),
      .TARGET9_CLOCK_DOMAIN_CROSSING  ( TARGET9_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET10_CLOCK_DOMAIN_CROSSING  ( TARGET10_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET11_CLOCK_DOMAIN_CROSSING  ( TARGET11_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET12_CLOCK_DOMAIN_CROSSING  ( TARGET12_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET13_CLOCK_DOMAIN_CROSSING  ( TARGET13_CLOCK_DOMAIN_CROSSING   ),    
      .TARGET14_CLOCK_DOMAIN_CROSSING  ( TARGET14_CLOCK_DOMAIN_CROSSING   ),
      .TARGET15_CLOCK_DOMAIN_CROSSING  ( TARGET15_CLOCK_DOMAIN_CROSSING   ),
	  
      .TRGT_AXI4PRT_ADDRDEPTH ( TRGT_AXI4PRT_ADDRDEPTH  ),    // Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
      .TRGT_AXI4PRT_DATADEPTH ( TRGT_AXI4PRT_DATADEPTH  ),    // Number transations width - 1 => 2 transations, 2 => 4 transations, etc.

      //====================================================================
      // Register Slice // parameters
      //====================================================================
      .INITIATOR0_CHAN_RS   ( INITIATOR0_CHAN_RS   ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .INITIATOR1_CHAN_RS   ( INITIATOR1_CHAN_RS   ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .INITIATOR2_CHAN_RS   ( INITIATOR2_CHAN_RS   ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .INITIATOR3_CHAN_RS   ( INITIATOR3_CHAN_RS   ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .INITIATOR4_CHAN_RS   ( INITIATOR4_CHAN_RS   ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .INITIATOR5_CHAN_RS   ( INITIATOR5_CHAN_RS   ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .INITIATOR6_CHAN_RS   ( INITIATOR6_CHAN_RS   ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .INITIATOR7_CHAN_RS   ( INITIATOR7_CHAN_RS   ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted

      .TARGET0_CHAN_RS   ( TARGET0_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET1_CHAN_RS   ( TARGET1_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET2_CHAN_RS   ( TARGET2_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET3_CHAN_RS   ( TARGET3_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET4_CHAN_RS   ( TARGET4_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET5_CHAN_RS   ( TARGET5_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET6_CHAN_RS   ( TARGET6_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET7_CHAN_RS   ( TARGET7_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET8_CHAN_RS   ( TARGET8_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET9_CHAN_RS   ( TARGET9_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET10_CHAN_RS   ( TARGET10_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET11_CHAN_RS   ( TARGET11_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET12_CHAN_RS   ( TARGET12_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET13_CHAN_RS   ( TARGET13_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET14_CHAN_RS   ( TARGET14_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET15_CHAN_RS   ( TARGET15_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET16_CHAN_RS   ( TARGET16_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET17_CHAN_RS   ( TARGET17_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET18_CHAN_RS   ( TARGET18_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET19_CHAN_RS   ( TARGET19_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET20_CHAN_RS   ( TARGET20_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET21_CHAN_RS   ( TARGET21_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET22_CHAN_RS   ( TARGET22_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET23_CHAN_RS   ( TARGET23_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET24_CHAN_RS   ( TARGET24_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET25_CHAN_RS   ( TARGET25_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET26_CHAN_RS   ( TARGET26_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET27_CHAN_RS   ( TARGET27_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET28_CHAN_RS   ( TARGET28_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET29_CHAN_RS   ( TARGET29_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET30_CHAN_RS   ( TARGET30_CHAN_RS     ),  // 0 - no CHAN register slice, 1 - CHAN register slice inserted
      .TARGET31_CHAN_RS   ( TARGET31_CHAN_RS     ),   // 0 - no CHAN register slice, 1 - CHAN register slice inserted
	  
	  .INITIATOR0_READ_INTERLEAVE   (1'b0),
	  .INITIATOR1_READ_INTERLEAVE   (1'b0),
	  .INITIATOR2_READ_INTERLEAVE   (1'b0),
	  .INITIATOR3_READ_INTERLEAVE   (1'b0),
	  .INITIATOR4_READ_INTERLEAVE   (1'b0),
	  .INITIATOR5_READ_INTERLEAVE   (1'b0),
	  .INITIATOR6_READ_INTERLEAVE   (1'b0),
	  .INITIATOR7_READ_INTERLEAVE   (1'b0),
	  .INITIATOR8_READ_INTERLEAVE   (1'b0),
	  .INITIATOR9_READ_INTERLEAVE   (1'b0),
	  .INITIATOR10_READ_INTERLEAVE   (1'b0),
	  .INITIATOR11_READ_INTERLEAVE   (1'b0),
	  .INITIATOR12_READ_INTERLEAVE   (1'b0),
	  .INITIATOR13_READ_INTERLEAVE   (1'b0),
	  .INITIATOR14_READ_INTERLEAVE   (1'b0),
	  .INITIATOR15_READ_INTERLEAVE   (1'b0),
	  
	  
      .TARGET0_READ_INTERLEAVE    ( 1'b0    ),  
      .TARGET1_READ_INTERLEAVE    ( 1'b0    ),  
      .TARGET2_READ_INTERLEAVE    ( 1'b0    ),  
      .TARGET3_READ_INTERLEAVE    ( 1'b0    ),  
      .TARGET4_READ_INTERLEAVE    ( 1'b0    ),  
      .TARGET5_READ_INTERLEAVE    ( 1'b0    ),  
      .TARGET6_READ_INTERLEAVE    ( 1'b0    ),  
      .TARGET7_READ_INTERLEAVE    ( 1'b0    ),  
      .TARGET8_READ_INTERLEAVE    ( 1'b0    ),  
      .TARGET9_READ_INTERLEAVE    ( 1'b0    ),  
      .TARGET10_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET11_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET12_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET13_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET14_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET15_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET16_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET17_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET18_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET19_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET20_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET21_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET22_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET23_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET24_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET25_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET26_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET27_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET28_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET29_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET30_READ_INTERLEAVE   ( 1'b0     ), 
      .TARGET31_READ_INTERLEAVE   ( 1'b0     )


    )
  uut (

  // Global Signals
  .ACLK      ( ACLK ),
  .I_CLK0      ( I_CLK0 ),
  .I_CLK1      ( I_CLK1 ),
  .I_CLK2      ( I_CLK2 ),
  .I_CLK3      ( I_CLK3 ),
  .I_CLK4      ( I_CLK4 ),
  .I_CLK5      ( I_CLK5 ),
  .I_CLK6      ( I_CLK6 ),
  .I_CLK7      ( I_CLK7 ),

  .T_CLK0       ( T_CLK0  ),
  .T_CLK1       ( T_CLK1  ),
  .T_CLK2       ( T_CLK2  ),
  .T_CLK3       ( T_CLK3  ),
  .T_CLK4       ( T_CLK4  ),
  .T_CLK5       ( T_CLK5  ),
  .T_CLK6       ( T_CLK6  ),
  .T_CLK7       ( T_CLK7  ),
  .T_CLK8       ( T_CLK8  ),
  .T_CLK9       ( T_CLK9  ),
  .T_CLK10      ( T_CLK10 ),
  .T_CLK11      ( T_CLK11 ),
  .T_CLK12      ( T_CLK12 ),
  .T_CLK13      ( T_CLK13 ),
  .T_CLK14      ( T_CLK14 ),
  .T_CLK15      ( T_CLK15 ),
  .T_CLK16      ( T_CLK16 ),
  .T_CLK17      ( T_CLK17 ),
  .T_CLK18      ( T_CLK18 ),
  .T_CLK19      ( T_CLK19 ),
  .T_CLK20      ( T_CLK20 ),
  .T_CLK21      ( T_CLK21 ),
  .T_CLK22      ( T_CLK22 ),
  .T_CLK23      ( T_CLK23 ),
  .T_CLK24      ( T_CLK24 ),
  .T_CLK25      ( T_CLK25 ),
  .T_CLK26      ( T_CLK26 ),
  .T_CLK27      ( T_CLK27 ),
  .T_CLK28      ( T_CLK28 ),
  .T_CLK29      ( T_CLK29 ),
  .T_CLK30      ( T_CLK30 ),
  .T_CLK31      ( T_CLK31 ),

  .ARESETN    ( ARESETN ),

  //======================  Initiator Write Address Ports  ======================================================//
  .INITIATOR0_AWID          ( INITIATOR0_AWID ),
  .INITIATOR0_AWADDR        ( INITIATOR0_AWADDR ),
  .INITIATOR0_AWLEN        ( INITIATOR0_AWLEN ),
  .INITIATOR0_AWSIZE        ( INITIATOR0_AWSIZE ),
  .INITIATOR0_AWBURST      ( INITIATOR0_AWBURST ),
  .INITIATOR0_AWLOCK        ( INITIATOR0_AWLOCK ),
  .INITIATOR0_AWCACHE      ( INITIATOR0_AWCACHE ),
  .INITIATOR0_AWPROT        ( INITIATOR0_AWPROT ),
  .INITIATOR0_AWREGION      ( INITIATOR0_AWREGION ),
  .INITIATOR0_AWQOS        ( INITIATOR0_AWQOS ),        // not used internally
  .INITIATOR0_AWUSER        ( INITIATOR0_AWUSER ),        // not used internally
  .INITIATOR0_AWVALID      ( INITIATOR0_AWVALID ),
  .INITIATOR0_AWREADY      ( INITIATOR0_AWREADY ),

  .INITIATOR0_HADDR        ( INITIATOR0_HADDR ),
  .INITIATOR0_HSEL          ( INITIATOR0_HSEL ),
  .INITIATOR0_HBURST        ( INITIATOR0_HBURST ),
  .INITIATOR0_HMASTLOCK    ( INITIATOR0_HMASTLOCK ),
  .INITIATOR0_HPROT        ( INITIATOR0_HPROT ),
  .INITIATOR0_HSIZE        ( INITIATOR0_HSIZE ),
  .INITIATOR0_HNONSEC      ( INITIATOR0_HNONSEC ),
  .INITIATOR0_HTRANS        ( INITIATOR0_HTRANS ),
  .INITIATOR0_HWDATA        ( INITIATOR0_HWDATA ),
  .INITIATOR0_HRDATA        ( INITIATOR0_HRDATA ),
  .INITIATOR0_HWRITE        ( INITIATOR0_HWRITE ),
  .INITIATOR0_HREADY        ( INITIATOR0_HREADY ),
  .INITIATOR0_HRESP        ( INITIATOR0_HRESP ),

  .INITIATOR1_AWID          ( INITIATOR1_AWID ),
  .INITIATOR1_AWADDR        ( INITIATOR1_AWADDR ),
  .INITIATOR1_AWLEN        ( INITIATOR1_AWLEN ),
  .INITIATOR1_AWSIZE        ( INITIATOR1_AWSIZE ),
  .INITIATOR1_AWBURST      ( INITIATOR1_AWBURST ),
  .INITIATOR1_AWLOCK        ( INITIATOR1_AWLOCK ),
  .INITIATOR1_AWCACHE      ( INITIATOR1_AWCACHE ),
  .INITIATOR1_AWPROT        ( INITIATOR1_AWPROT ),
  .INITIATOR1_AWREGION      ( INITIATOR1_AWREGION ),
  .INITIATOR1_AWQOS        ( INITIATOR1_AWQOS ),        // not used internally
  .INITIATOR1_AWUSER        ( INITIATOR1_AWUSER ),        // not used internally
  .INITIATOR1_AWVALID      ( INITIATOR1_AWVALID ),
  .INITIATOR1_AWREADY      ( INITIATOR1_AWREADY ),

  .INITIATOR1_HADDR        ( INITIATOR1_HADDR ),
  .INITIATOR1_HSEL          ( INITIATOR1_HSEL ),
  .INITIATOR1_HBURST        ( INITIATOR1_HBURST ),
  .INITIATOR1_HMASTLOCK    ( INITIATOR1_HMASTLOCK ),
  .INITIATOR1_HPROT        ( INITIATOR1_HPROT ),
  .INITIATOR1_HSIZE        ( INITIATOR1_HSIZE ),
  .INITIATOR1_HNONSEC      ( INITIATOR1_HNONSEC ),
  .INITIATOR1_HTRANS        ( INITIATOR1_HTRANS ),
  .INITIATOR1_HWDATA        ( INITIATOR1_HWDATA ),
  .INITIATOR1_HRDATA        ( INITIATOR1_HRDATA ),
  .INITIATOR1_HWRITE        ( INITIATOR1_HWRITE ),
  .INITIATOR1_HREADY        ( INITIATOR1_HREADY ),
  .INITIATOR1_HRESP        ( INITIATOR1_HRESP ),


  .INITIATOR2_AWID          ( INITIATOR2_AWID ),
  .INITIATOR2_AWADDR        ( INITIATOR2_AWADDR ),
  .INITIATOR2_AWLEN        ( INITIATOR2_AWLEN ),
  .INITIATOR2_AWSIZE        ( INITIATOR2_AWSIZE ),
  .INITIATOR2_AWBURST      ( INITIATOR2_AWBURST ),
  .INITIATOR2_AWLOCK        ( INITIATOR2_AWLOCK ),
  .INITIATOR2_AWCACHE      ( INITIATOR2_AWCACHE ),
  .INITIATOR2_AWPROT        ( INITIATOR2_AWPROT ),
  .INITIATOR2_AWREGION      ( INITIATOR2_AWREGION ),
  .INITIATOR2_AWQOS        ( INITIATOR2_AWQOS ),        // not used internally
  .INITIATOR2_AWUSER        ( INITIATOR2_AWUSER ),        // not used internally
  .INITIATOR2_AWVALID      ( INITIATOR2_AWVALID ),
  .INITIATOR2_AWREADY      ( INITIATOR2_AWREADY ),

  .INITIATOR2_HADDR        ( INITIATOR2_HADDR ),
  .INITIATOR2_HSEL          ( INITIATOR2_HSEL ),
  .INITIATOR2_HBURST        ( INITIATOR2_HBURST ),
  .INITIATOR2_HMASTLOCK    ( INITIATOR2_HMASTLOCK ),
  .INITIATOR2_HPROT        ( INITIATOR2_HPROT ),
  .INITIATOR2_HSIZE        ( INITIATOR2_HSIZE ),
  .INITIATOR2_HNONSEC      ( INITIATOR2_HNONSEC ),
  .INITIATOR2_HTRANS        ( INITIATOR2_HTRANS ),
  .INITIATOR2_HWDATA        ( INITIATOR2_HWDATA ),
  .INITIATOR2_HRDATA        ( INITIATOR2_HRDATA ),
  .INITIATOR2_HWRITE        ( INITIATOR2_HWRITE ),
  .INITIATOR2_HREADY        ( INITIATOR2_HREADY ),
  .INITIATOR2_HRESP        ( INITIATOR2_HRESP ),


  .INITIATOR3_AWID          ( INITIATOR3_AWID ),
  .INITIATOR3_AWADDR        ( INITIATOR3_AWADDR ),
  .INITIATOR3_AWLEN        ( INITIATOR3_AWLEN ),
  .INITIATOR3_AWSIZE        ( INITIATOR3_AWSIZE ),
  .INITIATOR3_AWBURST      ( INITIATOR3_AWBURST ),
  .INITIATOR3_AWLOCK        ( INITIATOR3_AWLOCK ),
  .INITIATOR3_AWCACHE      ( INITIATOR3_AWCACHE ),
  .INITIATOR3_AWPROT        ( INITIATOR3_AWPROT ),
  .INITIATOR3_AWREGION      ( INITIATOR3_AWREGION ),
  .INITIATOR3_AWQOS        ( INITIATOR3_AWQOS ),        // not used internally
  .INITIATOR3_AWUSER        ( INITIATOR3_AWUSER ),        // not used internally
  .INITIATOR3_AWVALID      ( INITIATOR3_AWVALID ),
  .INITIATOR3_AWREADY      ( INITIATOR3_AWREADY ),

  .INITIATOR3_HADDR        ( INITIATOR3_HADDR ),
  .INITIATOR3_HSEL          ( INITIATOR3_HSEL ),
  .INITIATOR3_HBURST        ( INITIATOR3_HBURST ),
  .INITIATOR3_HMASTLOCK    ( INITIATOR3_HMASTLOCK ),
  .INITIATOR3_HPROT        ( INITIATOR3_HPROT ),
  .INITIATOR3_HSIZE        ( INITIATOR3_HSIZE ),
  .INITIATOR3_HNONSEC      ( INITIATOR3_HNONSEC ),
  .INITIATOR3_HTRANS        ( INITIATOR3_HTRANS ),
  .INITIATOR3_HWDATA        ( INITIATOR3_HWDATA ),
  .INITIATOR3_HRDATA        ( INITIATOR3_HRDATA ),
  .INITIATOR3_HWRITE        ( INITIATOR3_HWRITE ),
  .INITIATOR3_HREADY        ( INITIATOR3_HREADY ),
  .INITIATOR3_HRESP        ( INITIATOR3_HRESP ),

  .INITIATOR4_AWID          ( INITIATOR4_AWID ),
  .INITIATOR4_AWADDR        ( INITIATOR4_AWADDR ),
  .INITIATOR4_AWLEN        ( INITIATOR4_AWLEN ),
  .INITIATOR4_AWSIZE        ( INITIATOR4_AWSIZE ),
  .INITIATOR4_AWBURST      ( INITIATOR4_AWBURST ),
  .INITIATOR4_AWLOCK        ( INITIATOR4_AWLOCK ),
  .INITIATOR4_AWCACHE      ( INITIATOR4_AWCACHE ),
  .INITIATOR4_AWPROT        ( INITIATOR4_AWPROT ),
  .INITIATOR4_AWREGION      ( INITIATOR4_AWREGION ),
  .INITIATOR4_AWQOS        ( INITIATOR4_AWQOS ),        // not used internally
  .INITIATOR4_AWUSER        ( INITIATOR4_AWUSER ),        // not used internally
  .INITIATOR4_AWVALID      ( INITIATOR4_AWVALID ),
  .INITIATOR4_AWREADY      ( INITIATOR4_AWREADY ),

  .INITIATOR4_HADDR        ( INITIATOR4_HADDR ),
  .INITIATOR4_HSEL          ( INITIATOR4_HSEL ),
  .INITIATOR4_HBURST        ( INITIATOR4_HBURST ),
  .INITIATOR4_HMASTLOCK    ( INITIATOR4_HMASTLOCK ),
  .INITIATOR4_HPROT        ( INITIATOR4_HPROT ),
  .INITIATOR4_HSIZE        ( INITIATOR4_HSIZE ),
  .INITIATOR4_HNONSEC      ( INITIATOR4_HNONSEC ),
  .INITIATOR4_HTRANS        ( INITIATOR4_HTRANS ),
  .INITIATOR4_HWDATA        ( INITIATOR4_HWDATA ),
  .INITIATOR4_HRDATA        ( INITIATOR4_HRDATA ),
  .INITIATOR4_HWRITE        ( INITIATOR4_HWRITE ),
  .INITIATOR4_HREADY        ( INITIATOR4_HREADY ),
  .INITIATOR4_HRESP        ( INITIATOR4_HRESP ),

  .INITIATOR5_AWID          ( INITIATOR5_AWID ),
  .INITIATOR5_AWADDR        ( INITIATOR5_AWADDR ),
  .INITIATOR5_AWLEN        ( INITIATOR5_AWLEN ),
  .INITIATOR5_AWSIZE        ( INITIATOR5_AWSIZE ),
  .INITIATOR5_AWBURST      ( INITIATOR5_AWBURST ),
  .INITIATOR5_AWLOCK        ( INITIATOR5_AWLOCK ),
  .INITIATOR5_AWCACHE      ( INITIATOR5_AWCACHE ),
  .INITIATOR5_AWPROT        ( INITIATOR5_AWPROT ),
  .INITIATOR5_AWREGION      ( INITIATOR5_AWREGION ),
  .INITIATOR5_AWQOS        ( INITIATOR5_AWQOS ),        // not used internally
  .INITIATOR5_AWUSER        ( INITIATOR5_AWUSER ),        // not used internally
  .INITIATOR5_AWVALID      ( INITIATOR5_AWVALID ),
  .INITIATOR5_AWREADY      ( INITIATOR5_AWREADY ),

  .INITIATOR5_HADDR        ( INITIATOR5_HADDR ),
  .INITIATOR5_HSEL          ( INITIATOR5_HSEL ),
  .INITIATOR5_HBURST        ( INITIATOR5_HBURST ),
  .INITIATOR5_HMASTLOCK    ( INITIATOR5_HMASTLOCK ),
  .INITIATOR5_HPROT        ( INITIATOR5_HPROT ),
  .INITIATOR5_HSIZE        ( INITIATOR5_HSIZE ),
  .INITIATOR5_HNONSEC      ( INITIATOR5_HNONSEC ),
  .INITIATOR5_HTRANS        ( INITIATOR5_HTRANS ),
  .INITIATOR5_HWDATA        ( INITIATOR5_HWDATA ),
  .INITIATOR5_HRDATA        ( INITIATOR5_HRDATA ),
  .INITIATOR5_HWRITE        ( INITIATOR5_HWRITE ),
  .INITIATOR5_HREADY        ( INITIATOR5_HREADY ),
  .INITIATOR5_HRESP        ( INITIATOR5_HRESP ),

  .INITIATOR6_AWID          ( INITIATOR6_AWID ),
  .INITIATOR6_AWADDR        ( INITIATOR6_AWADDR ),
  .INITIATOR6_AWLEN        ( INITIATOR6_AWLEN ),
  .INITIATOR6_AWSIZE        ( INITIATOR6_AWSIZE ),
  .INITIATOR6_AWBURST      ( INITIATOR6_AWBURST ),
  .INITIATOR6_AWLOCK        ( INITIATOR6_AWLOCK ),
  .INITIATOR6_AWCACHE      ( INITIATOR6_AWCACHE ),
  .INITIATOR6_AWPROT        ( INITIATOR6_AWPROT ),
  .INITIATOR6_AWREGION      ( INITIATOR6_AWREGION ),
  .INITIATOR6_AWQOS        ( INITIATOR6_AWQOS ),        // not used internally
  .INITIATOR6_AWUSER        ( INITIATOR6_AWUSER ),        // not used internally
  .INITIATOR6_AWVALID      ( INITIATOR6_AWVALID ),
  .INITIATOR6_AWREADY      ( INITIATOR6_AWREADY ),

  .INITIATOR6_HADDR        ( INITIATOR6_HADDR ),
  .INITIATOR6_HSEL          ( INITIATOR6_HSEL ),
  .INITIATOR6_HBURST        ( INITIATOR6_HBURST ),
  .INITIATOR6_HMASTLOCK    ( INITIATOR6_HMASTLOCK ),
  .INITIATOR6_HPROT        ( INITIATOR6_HPROT ),
  .INITIATOR6_HSIZE        ( INITIATOR6_HSIZE ),
  .INITIATOR6_HNONSEC      ( INITIATOR6_HNONSEC ),
  .INITIATOR6_HTRANS        ( INITIATOR6_HTRANS ),
  .INITIATOR6_HWDATA        ( INITIATOR6_HWDATA ),
  .INITIATOR6_HRDATA        ( INITIATOR6_HRDATA ),
  .INITIATOR6_HWRITE        ( INITIATOR6_HWRITE ),
  .INITIATOR6_HREADY        ( INITIATOR6_HREADY ),
  .INITIATOR6_HRESP        ( INITIATOR6_HRESP ),

  .INITIATOR7_AWID          ( INITIATOR7_AWID ),
  .INITIATOR7_AWADDR        ( INITIATOR7_AWADDR ),
  .INITIATOR7_AWLEN        ( INITIATOR7_AWLEN ),
  .INITIATOR7_AWSIZE        ( INITIATOR7_AWSIZE ),
  .INITIATOR7_AWBURST      ( INITIATOR7_AWBURST ),
  .INITIATOR7_AWLOCK        ( INITIATOR7_AWLOCK ),
  .INITIATOR7_AWCACHE      ( INITIATOR7_AWCACHE ),
  .INITIATOR7_AWPROT        ( INITIATOR7_AWPROT ),
  .INITIATOR7_AWREGION      ( INITIATOR7_AWREGION ),
  .INITIATOR7_AWQOS        ( INITIATOR7_AWQOS ),        // not used internally
  .INITIATOR7_AWUSER        ( INITIATOR7_AWUSER ),        // not used internally
  .INITIATOR7_AWVALID      ( INITIATOR7_AWVALID ),
  .INITIATOR7_AWREADY      ( INITIATOR7_AWREADY ),

  .INITIATOR7_HADDR        ( INITIATOR7_HADDR ),
  .INITIATOR7_HSEL          ( INITIATOR7_HSEL ),
  .INITIATOR7_HBURST        ( INITIATOR7_HBURST ),
  .INITIATOR7_HMASTLOCK    ( INITIATOR7_HMASTLOCK ),
  .INITIATOR7_HPROT        ( INITIATOR7_HPROT ),
  .INITIATOR7_HSIZE        ( INITIATOR7_HSIZE ),
  .INITIATOR7_HNONSEC      ( INITIATOR7_HNONSEC ),
  .INITIATOR7_HTRANS        ( INITIATOR7_HTRANS ),
  .INITIATOR7_HWDATA        ( INITIATOR7_HWDATA ),
  .INITIATOR7_HRDATA        ( INITIATOR7_HRDATA ),
  .INITIATOR7_HWRITE        ( INITIATOR7_HWRITE ),
  .INITIATOR7_HREADY        ( INITIATOR7_HREADY ),
  .INITIATOR7_HRESP        ( INITIATOR7_HRESP ),

  //======================  Initiator Write Data Ports  =========================================================//
  .INITIATOR0_WDATA      ( INITIATOR0_WDATA ),
  .INITIATOR0_WSTRB      ( INITIATOR0_WSTRB ),
  .INITIATOR0_WLAST      ( INITIATOR0_WLAST ),
  .INITIATOR0_WUSER      ( INITIATOR0_WUSER ),
  .INITIATOR0_WVALID      ( INITIATOR0_WVALID ),
  .INITIATOR0_WREADY      ( INITIATOR0_WREADY ),

  .INITIATOR1_WDATA      ( INITIATOR1_WDATA ),
  .INITIATOR1_WSTRB      ( INITIATOR1_WSTRB ),
  .INITIATOR1_WLAST      ( INITIATOR1_WLAST ),
  .INITIATOR1_WUSER      ( INITIATOR1_WUSER ),
  .INITIATOR1_WVALID      ( INITIATOR1_WVALID ),
  .INITIATOR1_WREADY      ( INITIATOR1_WREADY ),

  .INITIATOR2_WDATA      ( INITIATOR2_WDATA ),
  .INITIATOR2_WSTRB      ( INITIATOR2_WSTRB ),
  .INITIATOR2_WLAST      ( INITIATOR2_WLAST ),
  .INITIATOR2_WUSER      ( INITIATOR2_WUSER ),
  .INITIATOR2_WVALID      ( INITIATOR2_WVALID ),
  .INITIATOR2_WREADY      ( INITIATOR2_WREADY ),

  .INITIATOR3_WDATA      ( INITIATOR3_WDATA ),
  .INITIATOR3_WSTRB      ( INITIATOR3_WSTRB ),
  .INITIATOR3_WLAST      ( INITIATOR3_WLAST ),
  .INITIATOR3_WUSER      ( INITIATOR3_WUSER ),
  .INITIATOR3_WVALID      ( INITIATOR3_WVALID ),
  .INITIATOR3_WREADY      ( INITIATOR3_WREADY ),

  .INITIATOR4_WDATA      ( INITIATOR4_WDATA ),
  .INITIATOR4_WSTRB      ( INITIATOR4_WSTRB ),
  .INITIATOR4_WLAST      ( INITIATOR4_WLAST ),
  .INITIATOR4_WUSER      ( INITIATOR4_WUSER ),
  .INITIATOR4_WVALID      ( INITIATOR4_WVALID ),
  .INITIATOR4_WREADY      ( INITIATOR4_WREADY ),

  .INITIATOR5_WDATA      ( INITIATOR5_WDATA ),
  .INITIATOR5_WSTRB      ( INITIATOR5_WSTRB ),
  .INITIATOR5_WLAST      ( INITIATOR5_WLAST ),
  .INITIATOR5_WUSER      ( INITIATOR5_WUSER ),
  .INITIATOR5_WVALID      ( INITIATOR5_WVALID ),
  .INITIATOR5_WREADY      ( INITIATOR5_WREADY ),

  .INITIATOR6_WDATA      ( INITIATOR6_WDATA ),
  .INITIATOR6_WSTRB      ( INITIATOR6_WSTRB ),
  .INITIATOR6_WLAST      ( INITIATOR6_WLAST ),
  .INITIATOR6_WUSER      ( INITIATOR6_WUSER ),
  .INITIATOR6_WVALID      ( INITIATOR6_WVALID ),
  .INITIATOR6_WREADY      ( INITIATOR6_WREADY ),

  .INITIATOR7_WDATA      ( INITIATOR7_WDATA ),
  .INITIATOR7_WSTRB      ( INITIATOR7_WSTRB ),
  .INITIATOR7_WLAST      ( INITIATOR7_WLAST ),
  .INITIATOR7_WUSER      ( INITIATOR7_WUSER ),
  .INITIATOR7_WVALID      ( INITIATOR7_WVALID ),
  .INITIATOR7_WREADY      ( INITIATOR7_WREADY ),

  //======================  Initiator Write Response Ports  =====================================================//
  .INITIATOR0_BID        ( INITIATOR0_BID ),
  .INITIATOR0_BRESP      ( INITIATOR0_BRESP ),
  .INITIATOR0_BUSER      ( INITIATOR0_BUSER ),
  .INITIATOR0_BVALID      ( INITIATOR0_BVALID ),
  .INITIATOR0_BREADY      ( INITIATOR0_BREADY ),

  .INITIATOR1_BID        ( INITIATOR1_BID ),
  .INITIATOR1_BRESP      ( INITIATOR1_BRESP ),
  .INITIATOR1_BUSER      ( INITIATOR1_BUSER ),
  .INITIATOR1_BVALID      ( INITIATOR1_BVALID ),
  .INITIATOR1_BREADY      ( INITIATOR1_BREADY ),

  .INITIATOR2_BID        ( INITIATOR2_BID ),
  .INITIATOR2_BRESP      ( INITIATOR2_BRESP ),
  .INITIATOR2_BUSER      ( INITIATOR2_BUSER ),
  .INITIATOR2_BVALID      ( INITIATOR2_BVALID ),
  .INITIATOR2_BREADY      ( INITIATOR2_BREADY ),

  .INITIATOR3_BID        ( INITIATOR3_BID ),
  .INITIATOR3_BRESP      ( INITIATOR3_BRESP ),
  .INITIATOR3_BUSER      ( INITIATOR3_BUSER ),
  .INITIATOR3_BVALID      ( INITIATOR3_BVALID ),
  .INITIATOR3_BREADY      ( INITIATOR3_BREADY ),

  .INITIATOR4_BID        ( INITIATOR4_BID ),
  .INITIATOR4_BRESP      ( INITIATOR4_BRESP ),
  .INITIATOR4_BUSER      ( INITIATOR4_BUSER ),
  .INITIATOR4_BVALID      ( INITIATOR4_BVALID ),
  .INITIATOR4_BREADY      ( INITIATOR4_BREADY ),

  .INITIATOR5_BID        ( INITIATOR5_BID ),
  .INITIATOR5_BRESP      ( INITIATOR5_BRESP ),
  .INITIATOR5_BUSER      ( INITIATOR5_BUSER ),
  .INITIATOR5_BVALID      ( INITIATOR5_BVALID ),
  .INITIATOR5_BREADY      ( INITIATOR5_BREADY ),

  .INITIATOR6_BID        ( INITIATOR6_BID ),
  .INITIATOR6_BRESP      ( INITIATOR6_BRESP ),
  .INITIATOR6_BUSER      ( INITIATOR6_BUSER ),
  .INITIATOR6_BVALID      ( INITIATOR6_BVALID ),
  .INITIATOR6_BREADY      ( INITIATOR6_BREADY ),

  .INITIATOR7_BID        ( INITIATOR7_BID ),
  .INITIATOR7_BRESP      ( INITIATOR7_BRESP ),
  .INITIATOR7_BUSER      ( INITIATOR7_BUSER ),
  .INITIATOR7_BVALID      ( INITIATOR7_BVALID ),
  .INITIATOR7_BREADY      ( INITIATOR7_BREADY ),

  //======================  Initiator Read Address Ports  =======================================================//

  .INITIATOR0_ARID        ( INITIATOR0_ARID ),
  .INITIATOR0_ARADDR      ( INITIATOR0_ARADDR ),
  .INITIATOR0_ARLEN      ( INITIATOR0_ARLEN ),
  .INITIATOR0_ARSIZE      ( INITIATOR0_ARSIZE ),
  .INITIATOR0_ARBURST    ( INITIATOR0_ARBURST ),
  .INITIATOR0_ARLOCK      ( INITIATOR0_ARLOCK ),
  .INITIATOR0_ARCACHE    ( INITIATOR0_ARCACHE ),
  .INITIATOR0_ARPROT      ( INITIATOR0_ARPROT ),
  .INITIATOR0_ARREGION    ( INITIATOR0_ARREGION ),
  .INITIATOR0_ARQOS      ( INITIATOR0_ARQOS ),    // not used
  .INITIATOR0_ARUSER      ( INITIATOR0_ARUSER ),
  .INITIATOR0_ARVALID    ( INITIATOR0_ARVALID ),
  .INITIATOR0_ARREADY    ( INITIATOR0_ARREADY ),

  .INITIATOR1_ARID        ( INITIATOR1_ARID ),
  .INITIATOR1_ARADDR      ( INITIATOR1_ARADDR ),
  .INITIATOR1_ARLEN      ( INITIATOR1_ARLEN ),
  .INITIATOR1_ARSIZE      ( INITIATOR1_ARSIZE ),
  .INITIATOR1_ARBURST    ( INITIATOR1_ARBURST ),
  .INITIATOR1_ARLOCK      ( INITIATOR1_ARLOCK ),
  .INITIATOR1_ARCACHE    ( INITIATOR1_ARCACHE ),
  .INITIATOR1_ARPROT      ( INITIATOR1_ARPROT ),
  .INITIATOR1_ARREGION    ( INITIATOR1_ARREGION ),
  .INITIATOR1_ARQOS      ( INITIATOR1_ARQOS ),    // not used
  .INITIATOR1_ARUSER      ( INITIATOR1_ARUSER ),
  .INITIATOR1_ARVALID    ( INITIATOR1_ARVALID ),
  .INITIATOR1_ARREADY    ( INITIATOR1_ARREADY ),

  .INITIATOR2_ARID        ( INITIATOR2_ARID ),
  .INITIATOR2_ARADDR      ( INITIATOR2_ARADDR ),
  .INITIATOR2_ARLEN      ( INITIATOR2_ARLEN ),
  .INITIATOR2_ARSIZE      ( INITIATOR2_ARSIZE ),
  .INITIATOR2_ARBURST    ( INITIATOR2_ARBURST ),
  .INITIATOR2_ARLOCK      ( INITIATOR2_ARLOCK ),
  .INITIATOR2_ARCACHE    ( INITIATOR2_ARCACHE ),
  .INITIATOR2_ARPROT      ( INITIATOR2_ARPROT ),
  .INITIATOR2_ARREGION    ( INITIATOR2_ARREGION ),
  .INITIATOR2_ARQOS      ( INITIATOR2_ARQOS ),    // not used
  .INITIATOR2_ARUSER      ( INITIATOR2_ARUSER ),
  .INITIATOR2_ARVALID    ( INITIATOR2_ARVALID ),
  .INITIATOR2_ARREADY    ( INITIATOR2_ARREADY ),

  .INITIATOR3_ARID        ( INITIATOR3_ARID ),
  .INITIATOR3_ARADDR      ( INITIATOR3_ARADDR ),
  .INITIATOR3_ARLEN      ( INITIATOR3_ARLEN ),
  .INITIATOR3_ARSIZE      ( INITIATOR3_ARSIZE ),
  .INITIATOR3_ARBURST    ( INITIATOR3_ARBURST ),
  .INITIATOR3_ARLOCK      ( INITIATOR3_ARLOCK ),
  .INITIATOR3_ARCACHE    ( INITIATOR3_ARCACHE ),
  .INITIATOR3_ARPROT      ( INITIATOR3_ARPROT ),
  .INITIATOR3_ARREGION    ( INITIATOR3_ARREGION ),
  .INITIATOR3_ARQOS      ( INITIATOR3_ARQOS ),    // not used
  .INITIATOR3_ARUSER      ( INITIATOR3_ARUSER ),
  .INITIATOR3_ARVALID    ( INITIATOR3_ARVALID ),
  .INITIATOR3_ARREADY    ( INITIATOR3_ARREADY ),

  .INITIATOR4_ARID        ( INITIATOR4_ARID ),
  .INITIATOR4_ARADDR      ( INITIATOR4_ARADDR ),
  .INITIATOR4_ARLEN      ( INITIATOR4_ARLEN ),
  .INITIATOR4_ARSIZE      ( INITIATOR4_ARSIZE ),
  .INITIATOR4_ARBURST    ( INITIATOR4_ARBURST ),
  .INITIATOR4_ARLOCK      ( INITIATOR4_ARLOCK ),
  .INITIATOR4_ARCACHE    ( INITIATOR4_ARCACHE ),
  .INITIATOR4_ARPROT      ( INITIATOR4_ARPROT ),
  .INITIATOR4_ARREGION    ( INITIATOR4_ARREGION ),
  .INITIATOR4_ARQOS      ( INITIATOR4_ARQOS ),    // not used
  .INITIATOR4_ARUSER      ( INITIATOR4_ARUSER ),
  .INITIATOR4_ARVALID    ( INITIATOR4_ARVALID ),
  .INITIATOR4_ARREADY    ( INITIATOR4_ARREADY ),

  .INITIATOR5_ARID        ( INITIATOR5_ARID ),
  .INITIATOR5_ARADDR      ( INITIATOR5_ARADDR ),
  .INITIATOR5_ARLEN      ( INITIATOR5_ARLEN ),
  .INITIATOR5_ARSIZE      ( INITIATOR5_ARSIZE ),
  .INITIATOR5_ARBURST    ( INITIATOR5_ARBURST ),
  .INITIATOR5_ARLOCK      ( INITIATOR5_ARLOCK ),
  .INITIATOR5_ARCACHE    ( INITIATOR5_ARCACHE ),
  .INITIATOR5_ARPROT      ( INITIATOR5_ARPROT ),
  .INITIATOR5_ARREGION    ( INITIATOR5_ARREGION ),
  .INITIATOR5_ARQOS      ( INITIATOR5_ARQOS ),    // not used
  .INITIATOR5_ARUSER      ( INITIATOR5_ARUSER ),
  .INITIATOR5_ARVALID    ( INITIATOR5_ARVALID ),
  .INITIATOR5_ARREADY    ( INITIATOR5_ARREADY ),

  .INITIATOR6_ARID        ( INITIATOR6_ARID ),
  .INITIATOR6_ARADDR      ( INITIATOR6_ARADDR ),
  .INITIATOR6_ARLEN      ( INITIATOR6_ARLEN ),
  .INITIATOR6_ARSIZE      ( INITIATOR6_ARSIZE ),
  .INITIATOR6_ARBURST    ( INITIATOR6_ARBURST ),
  .INITIATOR6_ARLOCK      ( INITIATOR6_ARLOCK ),
  .INITIATOR6_ARCACHE    ( INITIATOR6_ARCACHE ),
  .INITIATOR6_ARPROT      ( INITIATOR6_ARPROT ),
  .INITIATOR6_ARREGION    ( INITIATOR6_ARREGION ),
  .INITIATOR6_ARQOS      ( INITIATOR6_ARQOS ),    // not used
  .INITIATOR6_ARUSER      ( INITIATOR6_ARUSER ),
  .INITIATOR6_ARVALID    ( INITIATOR6_ARVALID ),
  .INITIATOR6_ARREADY    ( INITIATOR6_ARREADY ),

  .INITIATOR7_ARID        ( INITIATOR7_ARID ),
  .INITIATOR7_ARADDR      ( INITIATOR7_ARADDR ),
  .INITIATOR7_ARLEN      ( INITIATOR7_ARLEN ),
  .INITIATOR7_ARSIZE      ( INITIATOR7_ARSIZE ),
  .INITIATOR7_ARBURST    ( INITIATOR7_ARBURST ),
  .INITIATOR7_ARLOCK      ( INITIATOR7_ARLOCK ),
  .INITIATOR7_ARCACHE    ( INITIATOR7_ARCACHE ),
  .INITIATOR7_ARPROT      ( INITIATOR7_ARPROT ),
  .INITIATOR7_ARREGION    ( INITIATOR7_ARREGION ),
  .INITIATOR7_ARQOS      ( INITIATOR7_ARQOS ),    // not used
  .INITIATOR7_ARUSER      ( INITIATOR7_ARUSER ),
  .INITIATOR7_ARVALID    ( INITIATOR7_ARVALID ),
  .INITIATOR7_ARREADY    ( INITIATOR7_ARREADY ),

  //======================  Initiator Read Data Ports  ==========================================================//
  .INITIATOR0_RID        ( INITIATOR0_RID ),
  .INITIATOR0_RDATA      ( INITIATOR0_RDATA ),
  .INITIATOR0_RRESP      ( INITIATOR0_RRESP ),
  .INITIATOR0_RLAST      ( INITIATOR0_RLAST ),
  .INITIATOR0_RUSER      ( INITIATOR0_RUSER ),
  .INITIATOR0_RVALID      ( INITIATOR0_RVALID ),
  .INITIATOR0_RREADY      ( INITIATOR0_RREADY ),

  .INITIATOR1_RID        ( INITIATOR1_RID ),
  .INITIATOR1_RDATA      ( INITIATOR1_RDATA ),
  .INITIATOR1_RRESP      ( INITIATOR1_RRESP ),
  .INITIATOR1_RLAST      ( INITIATOR1_RLAST ),
  .INITIATOR1_RUSER      ( INITIATOR1_RUSER ),
  .INITIATOR1_RVALID      ( INITIATOR1_RVALID ),
  .INITIATOR1_RREADY      ( INITIATOR1_RREADY ),

  .INITIATOR2_RID        ( INITIATOR2_RID ),
  .INITIATOR2_RDATA      ( INITIATOR2_RDATA ),
  .INITIATOR2_RRESP      ( INITIATOR2_RRESP ),
  .INITIATOR2_RLAST      ( INITIATOR2_RLAST ),
  .INITIATOR2_RUSER      ( INITIATOR2_RUSER ),
  .INITIATOR2_RVALID      ( INITIATOR2_RVALID ),
  .INITIATOR2_RREADY      ( INITIATOR2_RREADY ),

  .INITIATOR3_RID        ( INITIATOR3_RID ),
  .INITIATOR3_RDATA      ( INITIATOR3_RDATA ),
  .INITIATOR3_RRESP      ( INITIATOR3_RRESP ),
  .INITIATOR3_RLAST      ( INITIATOR3_RLAST ),
  .INITIATOR3_RUSER      ( INITIATOR3_RUSER ),
  .INITIATOR3_RVALID      ( INITIATOR3_RVALID ),
  .INITIATOR3_RREADY      ( INITIATOR3_RREADY ),

  .INITIATOR4_RID        ( INITIATOR4_RID ),
  .INITIATOR4_RDATA      ( INITIATOR4_RDATA ),
  .INITIATOR4_RRESP      ( INITIATOR4_RRESP ),
  .INITIATOR4_RLAST      ( INITIATOR4_RLAST ),
  .INITIATOR4_RUSER      ( INITIATOR4_RUSER ),
  .INITIATOR4_RVALID      ( INITIATOR4_RVALID ),
  .INITIATOR4_RREADY      ( INITIATOR4_RREADY ),

  .INITIATOR5_RID        ( INITIATOR5_RID ),
  .INITIATOR5_RDATA      ( INITIATOR5_RDATA ),
  .INITIATOR5_RRESP      ( INITIATOR5_RRESP ),
  .INITIATOR5_RLAST      ( INITIATOR5_RLAST ),
  .INITIATOR5_RUSER      ( INITIATOR5_RUSER ),
  .INITIATOR5_RVALID      ( INITIATOR5_RVALID ),
  .INITIATOR5_RREADY      ( INITIATOR5_RREADY ),

  .INITIATOR6_RID        ( INITIATOR6_RID ),
  .INITIATOR6_RDATA      ( INITIATOR6_RDATA ),
  .INITIATOR6_RRESP      ( INITIATOR6_RRESP ),
  .INITIATOR6_RLAST      ( INITIATOR6_RLAST ),
  .INITIATOR6_RUSER      ( INITIATOR6_RUSER ),
  .INITIATOR6_RVALID      ( INITIATOR6_RVALID ),
  .INITIATOR6_RREADY      ( INITIATOR6_RREADY ),

  .INITIATOR7_RID        ( INITIATOR7_RID ),
  .INITIATOR7_RDATA      ( INITIATOR7_RDATA ),
  .INITIATOR7_RRESP      ( INITIATOR7_RRESP ),
  .INITIATOR7_RLAST      ( INITIATOR7_RLAST ),
  .INITIATOR7_RUSER      ( INITIATOR7_RUSER ),
  .INITIATOR7_RVALID      ( INITIATOR7_RVALID ),
  .INITIATOR7_RREADY      ( INITIATOR7_RREADY ),

  //======================  Target Write Address Port  ========================================================//



   // Target Write Address Port
  .TARGET0_AWID          ( TARGET0_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET0_AWADDR        ( TARGET0_AWADDR ),
  .TARGET0_AWLEN         ( TARGET0_AWLEN ),
  .TARGET0_AWSIZE        ( TARGET0_AWSIZE ),
  .TARGET0_AWBURST       ( TARGET0_AWBURST ),
  .TARGET0_AWLOCK        ( TARGET0_AWLOCK ),
  .TARGET0_AWCACHE       ( TARGET0_AWCACHE ),
  .TARGET0_AWPROT        ( TARGET0_AWPROT ),
  .TARGET0_AWREGION      ( TARGET0_AWREGION ),      // not used
  .TARGET0_AWQOS         ( TARGET0_AWQOS ),        // not used
  .TARGET0_AWUSER        ( TARGET0_AWUSER ),
  .TARGET0_AWVALID       ( TARGET0_AWVALID ),
  .TARGET0_AWREADY       ( TARGET0_AWREADY ),
  
  .TARGET1_AWID          ( TARGET1_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET1_AWADDR        ( TARGET1_AWADDR ),
  .TARGET1_AWLEN         ( TARGET1_AWLEN ),
  .TARGET1_AWSIZE        ( TARGET1_AWSIZE ),
  .TARGET1_AWBURST       ( TARGET1_AWBURST ),
  .TARGET1_AWLOCK        ( TARGET1_AWLOCK ),
  .TARGET1_AWCACHE       ( TARGET1_AWCACHE ),
  .TARGET1_AWPROT        ( TARGET1_AWPROT ),
  .TARGET1_AWREGION      ( TARGET1_AWREGION ),      // not used
  .TARGET1_AWQOS         ( TARGET1_AWQOS ),        // not used
  .TARGET1_AWUSER        ( TARGET1_AWUSER ),
  .TARGET1_AWVALID       ( TARGET1_AWVALID ),
  .TARGET1_AWREADY       ( TARGET1_AWREADY ),
 
  .TARGET2_AWID          ( TARGET2_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET2_AWADDR        ( TARGET2_AWADDR ),
  .TARGET2_AWLEN         ( TARGET2_AWLEN ),
  .TARGET2_AWSIZE        ( TARGET2_AWSIZE ),
  .TARGET2_AWBURST       ( TARGET2_AWBURST ),
  .TARGET2_AWLOCK        ( TARGET2_AWLOCK ),
  .TARGET2_AWCACHE       ( TARGET2_AWCACHE ),
  .TARGET2_AWPROT        ( TARGET2_AWPROT ),
  .TARGET2_AWREGION      ( TARGET2_AWREGION ),      // not used
  .TARGET2_AWQOS         ( TARGET2_AWQOS ),        // not used
  .TARGET2_AWUSER        ( TARGET2_AWUSER ),
  .TARGET2_AWVALID       ( TARGET2_AWVALID ),
  .TARGET2_AWREADY       ( TARGET2_AWREADY ),
   
  .TARGET3_AWID          ( TARGET3_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET3_AWADDR        ( TARGET3_AWADDR ),
  .TARGET3_AWLEN         ( TARGET3_AWLEN ),
  .TARGET3_AWSIZE        ( TARGET3_AWSIZE ),
  .TARGET3_AWBURST       ( TARGET3_AWBURST ),
  .TARGET3_AWLOCK        ( TARGET3_AWLOCK ),
  .TARGET3_AWCACHE       ( TARGET3_AWCACHE ),
  .TARGET3_AWPROT        ( TARGET3_AWPROT ),
  .TARGET3_AWREGION      ( TARGET3_AWREGION ),      // not used
  .TARGET3_AWQOS         ( TARGET3_AWQOS ),        // not used
  .TARGET3_AWUSER        ( TARGET3_AWUSER ),
  .TARGET3_AWVALID       ( TARGET3_AWVALID ),
  .TARGET3_AWREADY       ( TARGET3_AWREADY ),

  .TARGET4_AWID          ( TARGET4_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET4_AWADDR        ( TARGET4_AWADDR ),
  .TARGET4_AWLEN         ( TARGET4_AWLEN ),
  .TARGET4_AWSIZE        ( TARGET4_AWSIZE ),
  .TARGET4_AWBURST       ( TARGET4_AWBURST ),
  .TARGET4_AWLOCK        ( TARGET4_AWLOCK ),
  .TARGET4_AWCACHE       ( TARGET4_AWCACHE ),
  .TARGET4_AWPROT        ( TARGET4_AWPROT ),
  .TARGET4_AWREGION      ( TARGET4_AWREGION ),      // not used
  .TARGET4_AWQOS         ( TARGET4_AWQOS ),        // not used
  .TARGET4_AWUSER        ( TARGET4_AWUSER ),
  .TARGET4_AWVALID       ( TARGET4_AWVALID ),
  .TARGET4_AWREADY       ( TARGET4_AWREADY ),
  
  .TARGET5_AWID          ( TARGET5_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET5_AWADDR        ( TARGET5_AWADDR ),
  .TARGET5_AWLEN         ( TARGET5_AWLEN ),
  .TARGET5_AWSIZE        ( TARGET5_AWSIZE ),
  .TARGET5_AWBURST       ( TARGET5_AWBURST ),
  .TARGET5_AWLOCK        ( TARGET5_AWLOCK ),
  .TARGET5_AWCACHE       ( TARGET5_AWCACHE ),
  .TARGET5_AWPROT        ( TARGET5_AWPROT ),
  .TARGET5_AWREGION      ( TARGET5_AWREGION ),      // not used
  .TARGET5_AWQOS         ( TARGET5_AWQOS ),        // not used
  .TARGET5_AWUSER        ( TARGET5_AWUSER ),
  .TARGET5_AWVALID       ( TARGET5_AWVALID ),
  .TARGET5_AWREADY       ( TARGET5_AWREADY ),

  .TARGET6_AWID          ( TARGET6_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET6_AWADDR        ( TARGET6_AWADDR ),
  .TARGET6_AWLEN         ( TARGET6_AWLEN ),
  .TARGET6_AWSIZE        ( TARGET6_AWSIZE ),
  .TARGET6_AWBURST       ( TARGET6_AWBURST ),
  .TARGET6_AWLOCK        ( TARGET6_AWLOCK ),
  .TARGET6_AWCACHE       ( TARGET6_AWCACHE ),
  .TARGET6_AWPROT        ( TARGET6_AWPROT ),
  .TARGET6_AWREGION      ( TARGET6_AWREGION ),      // not used
  .TARGET6_AWQOS         ( TARGET6_AWQOS ),        // not used
  .TARGET6_AWUSER        ( TARGET6_AWUSER ),
  .TARGET6_AWVALID       ( TARGET6_AWVALID ),
  .TARGET6_AWREADY       ( TARGET6_AWREADY ),
  
  .TARGET7_AWID          ( TARGET7_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET7_AWADDR        ( TARGET7_AWADDR ),
  .TARGET7_AWLEN         ( TARGET7_AWLEN ),
  .TARGET7_AWSIZE        ( TARGET7_AWSIZE ),
  .TARGET7_AWBURST       ( TARGET7_AWBURST ),
  .TARGET7_AWLOCK        ( TARGET7_AWLOCK ),
  .TARGET7_AWCACHE       ( TARGET7_AWCACHE ),
  .TARGET7_AWPROT        ( TARGET7_AWPROT ),
  .TARGET7_AWREGION      ( TARGET7_AWREGION ),      // not used
  .TARGET7_AWQOS         ( TARGET7_AWQOS ),        // not used
  .TARGET7_AWUSER        ( TARGET7_AWUSER ),
  .TARGET7_AWVALID       ( TARGET7_AWVALID ),
  .TARGET7_AWREADY       ( TARGET7_AWREADY ),
    
  .TARGET8_AWID          ( TARGET8_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET8_AWADDR        ( TARGET8_AWADDR ),
  .TARGET8_AWLEN         ( TARGET8_AWLEN ),
  .TARGET8_AWSIZE        ( TARGET8_AWSIZE ),
  .TARGET8_AWBURST       ( TARGET8_AWBURST ),
  .TARGET8_AWLOCK        ( TARGET8_AWLOCK ),
  .TARGET8_AWCACHE       ( TARGET8_AWCACHE ),
  .TARGET8_AWPROT        ( TARGET8_AWPROT ),
  .TARGET8_AWREGION      ( TARGET8_AWREGION ),      // not used
  .TARGET8_AWQOS         ( TARGET8_AWQOS ),        // not used
  .TARGET8_AWUSER        ( TARGET8_AWUSER ),
  .TARGET8_AWVALID       ( TARGET8_AWVALID ),
  .TARGET8_AWREADY       ( TARGET8_AWREADY ),
  
  .TARGET9_AWID          ( TARGET9_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET9_AWADDR        ( TARGET9_AWADDR ),
  .TARGET9_AWLEN         ( TARGET9_AWLEN ),
  .TARGET9_AWSIZE        ( TARGET9_AWSIZE ),
  .TARGET9_AWBURST       ( TARGET9_AWBURST ),
  .TARGET9_AWLOCK        ( TARGET9_AWLOCK ),
  .TARGET9_AWCACHE       ( TARGET9_AWCACHE ),
  .TARGET9_AWPROT        ( TARGET9_AWPROT ),
  .TARGET9_AWREGION      ( TARGET9_AWREGION ),      // not used
  .TARGET9_AWQOS         ( TARGET9_AWQOS ),        // not used
  .TARGET9_AWUSER        ( TARGET9_AWUSER ),
  .TARGET9_AWVALID       ( TARGET9_AWVALID ),
  .TARGET9_AWREADY       ( TARGET9_AWREADY ),
 
  .TARGET10_AWID         ( TARGET10_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET10_AWADDR       ( TARGET10_AWADDR ),
  .TARGET10_AWLEN        ( TARGET10_AWLEN ),
  .TARGET10_AWSIZE       ( TARGET10_AWSIZE ),
  .TARGET10_AWBURST      ( TARGET10_AWBURST ),
  .TARGET10_AWLOCK       ( TARGET10_AWLOCK ),
  .TARGET10_AWCACHE      ( TARGET10_AWCACHE ),
  .TARGET10_AWPROT       ( TARGET10_AWPROT ),
  .TARGET10_AWREGION     ( TARGET10_AWREGION ),      // not used
  .TARGET10_AWQOS        ( TARGET10_AWQOS ),        // not used
  .TARGET10_AWUSER       ( TARGET10_AWUSER ),
  .TARGET10_AWVALID      ( TARGET10_AWVALID ),
  .TARGET10_AWREADY      ( TARGET10_AWREADY ),
   
  .TARGET11_AWID         ( TARGET11_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET11_AWADDR       ( TARGET11_AWADDR ),
  .TARGET11_AWLEN        ( TARGET11_AWLEN ),
  .TARGET11_AWSIZE       ( TARGET11_AWSIZE ),
  .TARGET11_AWBURST      ( TARGET11_AWBURST ),
  .TARGET11_AWLOCK       ( TARGET11_AWLOCK ),
  .TARGET11_AWCACHE      ( TARGET11_AWCACHE ),
  .TARGET11_AWPROT       ( TARGET11_AWPROT ),
  .TARGET11_AWREGION     ( TARGET11_AWREGION ),      // not used
  .TARGET11_AWQOS        ( TARGET11_AWQOS ),        // not used
  .TARGET11_AWUSER       ( TARGET11_AWUSER ),
  .TARGET11_AWVALID      ( TARGET11_AWVALID ),
  .TARGET11_AWREADY      ( TARGET11_AWREADY ),

  .TARGET12_AWID         ( TARGET12_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET12_AWADDR       ( TARGET12_AWADDR ),
  .TARGET12_AWLEN        ( TARGET12_AWLEN ),
  .TARGET12_AWSIZE       ( TARGET12_AWSIZE ),
  .TARGET12_AWBURST      ( TARGET12_AWBURST ),
  .TARGET12_AWLOCK       ( TARGET12_AWLOCK ),
  .TARGET12_AWCACHE      ( TARGET12_AWCACHE ),
  .TARGET12_AWPROT       ( TARGET12_AWPROT ),
  .TARGET12_AWREGION     ( TARGET12_AWREGION ),      // not used
  .TARGET12_AWQOS        ( TARGET12_AWQOS ),        // not used
  .TARGET12_AWUSER       ( TARGET12_AWUSER ),
  .TARGET12_AWVALID      ( TARGET12_AWVALID ),
  .TARGET12_AWREADY      ( TARGET12_AWREADY ),
  
  .TARGET13_AWID         ( TARGET13_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET13_AWADDR       ( TARGET13_AWADDR ),
  .TARGET13_AWLEN        ( TARGET13_AWLEN ),
  .TARGET13_AWSIZE       ( TARGET13_AWSIZE ),
  .TARGET13_AWBURST      ( TARGET13_AWBURST ),
  .TARGET13_AWLOCK       ( TARGET13_AWLOCK ),
  .TARGET13_AWCACHE      ( TARGET13_AWCACHE ),
  .TARGET13_AWPROT       ( TARGET13_AWPROT ),
  .TARGET13_AWREGION     ( TARGET13_AWREGION ),      // not used
  .TARGET13_AWQOS        ( TARGET13_AWQOS ),        // not used
  .TARGET13_AWUSER       ( TARGET13_AWUSER ),
  .TARGET13_AWVALID      ( TARGET13_AWVALID ),
  .TARGET13_AWREADY      ( TARGET13_AWREADY ),

  .TARGET14_AWID         ( TARGET14_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET14_AWADDR       ( TARGET14_AWADDR ),
  .TARGET14_AWLEN        ( TARGET14_AWLEN ),
  .TARGET14_AWSIZE       ( TARGET14_AWSIZE ),
  .TARGET14_AWBURST      ( TARGET14_AWBURST ),
  .TARGET14_AWLOCK       ( TARGET14_AWLOCK ),
  .TARGET14_AWCACHE      ( TARGET14_AWCACHE ),
  .TARGET14_AWPROT       ( TARGET14_AWPROT ),
  .TARGET14_AWREGION     ( TARGET14_AWREGION ),      // not used
  .TARGET14_AWQOS        ( TARGET14_AWQOS ),        // not used
  .TARGET14_AWUSER       ( TARGET14_AWUSER ),
  .TARGET14_AWVALID      ( TARGET14_AWVALID ),
  .TARGET14_AWREADY      ( TARGET14_AWREADY ),
  
  .TARGET15_AWID         ( TARGET15_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET15_AWADDR       ( TARGET15_AWADDR ),
  .TARGET15_AWLEN        ( TARGET15_AWLEN ),
  .TARGET15_AWSIZE       ( TARGET15_AWSIZE ),
  .TARGET15_AWBURST      ( TARGET15_AWBURST ),
  .TARGET15_AWLOCK       ( TARGET15_AWLOCK ),
  .TARGET15_AWCACHE      ( TARGET15_AWCACHE ),
  .TARGET15_AWPROT       ( TARGET15_AWPROT ),
  .TARGET15_AWREGION     ( TARGET15_AWREGION ),      // not used
  .TARGET15_AWQOS        ( TARGET15_AWQOS ),        // not used
  .TARGET15_AWUSER       ( TARGET15_AWUSER ),
  .TARGET15_AWVALID      ( TARGET15_AWVALID ),
  .TARGET15_AWREADY      ( TARGET15_AWREADY ),
  
  .TARGET16_AWID         ( TARGET16_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET16_AWADDR       ( TARGET16_AWADDR ),
  .TARGET16_AWLEN        ( TARGET16_AWLEN ),
  .TARGET16_AWSIZE       ( TARGET16_AWSIZE ),
  .TARGET16_AWBURST      ( TARGET16_AWBURST ),
  .TARGET16_AWLOCK       ( TARGET16_AWLOCK ),
  .TARGET16_AWCACHE      ( TARGET16_AWCACHE ),
  .TARGET16_AWPROT       ( TARGET16_AWPROT ),
  .TARGET16_AWREGION     ( TARGET16_AWREGION ),      // not used
  .TARGET16_AWQOS        ( TARGET16_AWQOS ),        // not used
  .TARGET16_AWUSER       ( TARGET16_AWUSER ),
  .TARGET16_AWVALID      ( TARGET16_AWVALID ),
  .TARGET16_AWREADY      ( TARGET16_AWREADY ),
  
  .TARGET17_AWID         ( TARGET17_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET17_AWADDR       ( TARGET17_AWADDR ),
  .TARGET17_AWLEN        ( TARGET17_AWLEN ),
  .TARGET17_AWSIZE       ( TARGET17_AWSIZE ),
  .TARGET17_AWBURST      ( TARGET17_AWBURST ),
  .TARGET17_AWLOCK       ( TARGET17_AWLOCK ),
  .TARGET17_AWCACHE      ( TARGET17_AWCACHE ),
  .TARGET17_AWPROT       ( TARGET17_AWPROT ),
  .TARGET17_AWREGION     ( TARGET17_AWREGION ),      // not used
  .TARGET17_AWQOS        ( TARGET17_AWQOS ),        // not used
  .TARGET17_AWUSER       ( TARGET17_AWUSER ),
  .TARGET17_AWVALID      ( TARGET17_AWVALID ),
  .TARGET17_AWREADY      ( TARGET17_AWREADY ),
 
  .TARGET18_AWID         ( TARGET18_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET18_AWADDR       ( TARGET18_AWADDR ),
  .TARGET18_AWLEN        ( TARGET18_AWLEN ),
  .TARGET18_AWSIZE       ( TARGET18_AWSIZE ),
  .TARGET18_AWBURST      ( TARGET18_AWBURST ),
  .TARGET18_AWLOCK       ( TARGET18_AWLOCK ),
  .TARGET18_AWCACHE      ( TARGET18_AWCACHE ),
  .TARGET18_AWPROT       ( TARGET18_AWPROT ),
  .TARGET18_AWREGION     ( TARGET18_AWREGION ),      // not used
  .TARGET18_AWQOS        ( TARGET18_AWQOS ),        // not used
  .TARGET18_AWUSER       ( TARGET18_AWUSER ),
  .TARGET18_AWVALID      ( TARGET18_AWVALID ),
  .TARGET18_AWREADY      ( TARGET18_AWREADY ),

  .TARGET19_AWID         ( TARGET19_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET19_AWADDR       ( TARGET19_AWADDR ),
  .TARGET19_AWLEN        ( TARGET19_AWLEN ),
  .TARGET19_AWSIZE       ( TARGET19_AWSIZE ),
  .TARGET19_AWBURST      ( TARGET19_AWBURST ),
  .TARGET19_AWLOCK       ( TARGET19_AWLOCK ),
  .TARGET19_AWCACHE      ( TARGET19_AWCACHE ),
  .TARGET19_AWPROT       ( TARGET19_AWPROT ),
  .TARGET19_AWREGION     ( TARGET19_AWREGION ),      // not used
  .TARGET19_AWQOS        ( TARGET19_AWQOS ),        // not used
  .TARGET19_AWUSER       ( TARGET19_AWUSER ),
  .TARGET19_AWVALID      ( TARGET19_AWVALID ),
  .TARGET19_AWREADY      ( TARGET19_AWREADY ),

  .TARGET20_AWID         ( TARGET20_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET20_AWADDR       ( TARGET20_AWADDR ),
  .TARGET20_AWLEN        ( TARGET20_AWLEN ),
  .TARGET20_AWSIZE       ( TARGET20_AWSIZE ),
  .TARGET20_AWBURST      ( TARGET20_AWBURST ),
  .TARGET20_AWLOCK       ( TARGET20_AWLOCK ),
  .TARGET20_AWCACHE      ( TARGET20_AWCACHE ),
  .TARGET20_AWPROT       ( TARGET20_AWPROT ),
  .TARGET20_AWREGION     ( TARGET20_AWREGION ),      // not used
  .TARGET20_AWQOS        ( TARGET20_AWQOS ),        // not used
  .TARGET20_AWUSER       ( TARGET20_AWUSER ),
  .TARGET20_AWVALID      ( TARGET20_AWVALID ),
  .TARGET20_AWREADY      ( TARGET20_AWREADY ),
  
  .TARGET21_AWID         ( TARGET21_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET21_AWADDR       ( TARGET21_AWADDR ),
  .TARGET21_AWLEN        ( TARGET21_AWLEN ),
  .TARGET21_AWSIZE       ( TARGET21_AWSIZE ),
  .TARGET21_AWBURST      ( TARGET21_AWBURST ),
  .TARGET21_AWLOCK       ( TARGET21_AWLOCK ),
  .TARGET21_AWCACHE      ( TARGET21_AWCACHE ),
  .TARGET21_AWPROT       ( TARGET21_AWPROT ),
  .TARGET21_AWREGION     ( TARGET21_AWREGION ),      // not used
  .TARGET21_AWQOS        ( TARGET21_AWQOS ),        // not used
  .TARGET21_AWUSER       ( TARGET21_AWUSER ),
  .TARGET21_AWVALID      ( TARGET21_AWVALID ),
  .TARGET21_AWREADY      ( TARGET21_AWREADY ),

  .TARGET22_AWID         ( TARGET22_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET22_AWADDR       ( TARGET22_AWADDR ),
  .TARGET22_AWLEN        ( TARGET22_AWLEN ),
  .TARGET22_AWSIZE       ( TARGET22_AWSIZE ),
  .TARGET22_AWBURST      ( TARGET22_AWBURST ),
  .TARGET22_AWLOCK       ( TARGET22_AWLOCK ),
  .TARGET22_AWCACHE      ( TARGET22_AWCACHE ),
  .TARGET22_AWPROT       ( TARGET22_AWPROT ),
  .TARGET22_AWREGION     ( TARGET22_AWREGION ),      // not used
  .TARGET22_AWQOS        ( TARGET22_AWQOS ),        // not used
  .TARGET22_AWUSER       ( TARGET22_AWUSER ),
  .TARGET22_AWVALID      ( TARGET22_AWVALID ),
  .TARGET22_AWREADY      ( TARGET22_AWREADY ),

  .TARGET23_AWID         ( TARGET23_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET23_AWADDR       ( TARGET23_AWADDR ),
  .TARGET23_AWLEN        ( TARGET23_AWLEN ),
  .TARGET23_AWSIZE       ( TARGET23_AWSIZE ),
  .TARGET23_AWBURST      ( TARGET23_AWBURST ),
  .TARGET23_AWLOCK       ( TARGET23_AWLOCK ),
  .TARGET23_AWCACHE      ( TARGET23_AWCACHE ),
  .TARGET23_AWPROT       ( TARGET23_AWPROT ),
  .TARGET23_AWREGION     ( TARGET23_AWREGION ),      // not used
  .TARGET23_AWQOS        ( TARGET23_AWQOS ),        // not used
  .TARGET23_AWUSER       ( TARGET23_AWUSER ),
  .TARGET23_AWVALID      ( TARGET23_AWVALID ),
  .TARGET23_AWREADY      ( TARGET23_AWREADY ),
  
  .TARGET24_AWID         ( TARGET24_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET24_AWADDR       ( TARGET24_AWADDR ),
  .TARGET24_AWLEN        ( TARGET24_AWLEN ),
  .TARGET24_AWSIZE       ( TARGET24_AWSIZE ),
  .TARGET24_AWBURST      ( TARGET24_AWBURST ),
  .TARGET24_AWLOCK       ( TARGET24_AWLOCK ),
  .TARGET24_AWCACHE      ( TARGET24_AWCACHE ),
  .TARGET24_AWPROT       ( TARGET24_AWPROT ),
  .TARGET24_AWREGION     ( TARGET24_AWREGION ),      // not used
  .TARGET24_AWQOS        ( TARGET24_AWQOS ),        // not used
  .TARGET24_AWUSER       ( TARGET24_AWUSER ),
  .TARGET24_AWVALID      ( TARGET24_AWVALID ),
  .TARGET24_AWREADY      ( TARGET24_AWREADY ),
  
  .TARGET25_AWID         ( TARGET25_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET25_AWADDR       ( TARGET25_AWADDR ),
  .TARGET25_AWLEN        ( TARGET25_AWLEN ),
  .TARGET25_AWSIZE       ( TARGET25_AWSIZE ),
  .TARGET25_AWBURST      ( TARGET25_AWBURST ),
  .TARGET25_AWLOCK       ( TARGET25_AWLOCK ),
  .TARGET25_AWCACHE      ( TARGET25_AWCACHE ),
  .TARGET25_AWPROT       ( TARGET25_AWPROT ),
  .TARGET25_AWREGION     ( TARGET25_AWREGION ),      // not used
  .TARGET25_AWQOS        ( TARGET25_AWQOS ),        // not used
  .TARGET25_AWUSER       ( TARGET25_AWUSER ),
  .TARGET25_AWVALID      ( TARGET25_AWVALID ),
  .TARGET25_AWREADY      ( TARGET25_AWREADY ),
 
  .TARGET26_AWID         ( TARGET26_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET26_AWADDR       ( TARGET26_AWADDR ),
  .TARGET26_AWLEN        ( TARGET26_AWLEN ),
  .TARGET26_AWSIZE       ( TARGET26_AWSIZE ),
  .TARGET26_AWBURST      ( TARGET26_AWBURST ),
  .TARGET26_AWLOCK       ( TARGET26_AWLOCK ),
  .TARGET26_AWCACHE      ( TARGET26_AWCACHE ),
  .TARGET26_AWPROT       ( TARGET26_AWPROT ),
  .TARGET26_AWREGION     ( TARGET26_AWREGION ),      // not used
  .TARGET26_AWQOS        ( TARGET26_AWQOS ),        // not used
  .TARGET26_AWUSER       ( TARGET26_AWUSER ),
  .TARGET26_AWVALID      ( TARGET26_AWVALID ),
  .TARGET26_AWREADY      ( TARGET26_AWREADY ),
   
  .TARGET27_AWID         ( TARGET27_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET27_AWADDR       ( TARGET27_AWADDR ),
  .TARGET27_AWLEN        ( TARGET27_AWLEN ),
  .TARGET27_AWSIZE       ( TARGET27_AWSIZE ),
  .TARGET27_AWBURST      ( TARGET27_AWBURST ),
  .TARGET27_AWLOCK       ( TARGET27_AWLOCK ),
  .TARGET27_AWCACHE      ( TARGET27_AWCACHE ),
  .TARGET27_AWPROT       ( TARGET27_AWPROT ),
  .TARGET27_AWREGION     ( TARGET27_AWREGION ),      // not used
  .TARGET27_AWQOS        ( TARGET27_AWQOS ),        // not used
  .TARGET27_AWUSER       ( TARGET27_AWUSER ),
  .TARGET27_AWVALID      ( TARGET27_AWVALID ),
  .TARGET27_AWREADY      ( TARGET27_AWREADY ),

  .TARGET28_AWID         ( TARGET28_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET28_AWADDR       ( TARGET28_AWADDR ),
  .TARGET28_AWLEN        ( TARGET28_AWLEN ),
  .TARGET28_AWSIZE       ( TARGET28_AWSIZE ),
  .TARGET28_AWBURST      ( TARGET28_AWBURST ),
  .TARGET28_AWLOCK       ( TARGET28_AWLOCK ),
  .TARGET28_AWCACHE      ( TARGET28_AWCACHE ),
  .TARGET28_AWPROT       ( TARGET28_AWPROT ),
  .TARGET28_AWREGION     ( TARGET28_AWREGION ),      // not used
  .TARGET28_AWQOS        ( TARGET28_AWQOS ),        // not used
  .TARGET28_AWUSER       ( TARGET28_AWUSER ),
  .TARGET28_AWVALID      ( TARGET28_AWVALID ),
  .TARGET28_AWREADY      ( TARGET28_AWREADY ),
  
  .TARGET29_AWID         ( TARGET29_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET29_AWADDR       ( TARGET29_AWADDR ),
  .TARGET29_AWLEN        ( TARGET29_AWLEN ),
  .TARGET29_AWSIZE       ( TARGET29_AWSIZE ),
  .TARGET29_AWBURST      ( TARGET29_AWBURST ),
  .TARGET29_AWLOCK       ( TARGET29_AWLOCK ),
  .TARGET29_AWCACHE      ( TARGET29_AWCACHE ),
  .TARGET29_AWPROT       ( TARGET29_AWPROT ),
  .TARGET29_AWREGION     ( TARGET29_AWREGION ),      // not used
  .TARGET29_AWQOS        ( TARGET29_AWQOS ),        // not used
  .TARGET29_AWUSER       ( TARGET29_AWUSER ),
  .TARGET29_AWVALID      ( TARGET29_AWVALID ),
  .TARGET29_AWREADY      ( TARGET29_AWREADY ),

  .TARGET30_AWID         ( TARGET30_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET30_AWADDR       ( TARGET30_AWADDR ),
  .TARGET30_AWLEN        ( TARGET30_AWLEN ),
  .TARGET30_AWSIZE       ( TARGET30_AWSIZE ),
  .TARGET30_AWBURST      ( TARGET30_AWBURST ),
  .TARGET30_AWLOCK       ( TARGET30_AWLOCK ),
  .TARGET30_AWCACHE      ( TARGET30_AWCACHE ),
  .TARGET30_AWPROT       ( TARGET30_AWPROT ),
  .TARGET30_AWREGION     ( TARGET30_AWREGION ),      // not used
  .TARGET30_AWQOS        ( TARGET30_AWQOS ),        // not used
  .TARGET30_AWUSER       ( TARGET30_AWUSER ),
  .TARGET30_AWVALID      ( TARGET30_AWVALID ),
  .TARGET30_AWREADY      ( TARGET30_AWREADY ),
  
  .TARGET31_AWID         ( TARGET31_AWID ),        // Target ID is composed of Initiator Port ID concatenated with transaction ID
  .TARGET31_AWADDR       ( TARGET31_AWADDR ),
  .TARGET31_AWLEN        ( TARGET31_AWLEN ),
  .TARGET31_AWSIZE       ( TARGET31_AWSIZE ),
  .TARGET31_AWBURST      ( TARGET31_AWBURST ),
  .TARGET31_AWLOCK       ( TARGET31_AWLOCK ),
  .TARGET31_AWCACHE      ( TARGET31_AWCACHE ),
  .TARGET31_AWPROT       ( TARGET31_AWPROT ),
  .TARGET31_AWREGION     ( TARGET31_AWREGION ),      // not used
  .TARGET31_AWQOS        ( TARGET31_AWQOS ),        // not used
  .TARGET31_AWUSER       ( TARGET31_AWUSER ),
  .TARGET31_AWVALID      ( TARGET31_AWVALID ),
  .TARGET31_AWREADY      ( TARGET31_AWREADY ),

  //======================  Target Write Data Ports  ==========================================================//

// Target Write Data Ports
  .TARGET0_WID          ( TARGET0_WID ),
  .TARGET0_WDATA        ( TARGET0_WDATA ),
  .TARGET0_WSTRB        ( TARGET0_WSTRB ),
  .TARGET0_WLAST        ( TARGET0_WLAST ),
  .TARGET0_WUSER        ( TARGET0_WUSER ),
  .TARGET0_WVALID       ( TARGET0_WVALID ),
  .TARGET0_WREADY       ( TARGET0_WREADY ),

  .TARGET1_WID          ( TARGET1_WID ),
  .TARGET1_WDATA        ( TARGET1_WDATA ),
  .TARGET1_WSTRB        ( TARGET1_WSTRB ),
  .TARGET1_WLAST        ( TARGET1_WLAST ),
  .TARGET1_WUSER        ( TARGET1_WUSER ),
  .TARGET1_WVALID       ( TARGET1_WVALID ),
  .TARGET1_WREADY       ( TARGET1_WREADY ),

  .TARGET2_WID          ( TARGET2_WID ),
  .TARGET2_WDATA        ( TARGET2_WDATA ),
  .TARGET2_WSTRB        ( TARGET2_WSTRB ),
  .TARGET2_WLAST        ( TARGET2_WLAST ),
  .TARGET2_WUSER        ( TARGET2_WUSER ),
  .TARGET2_WVALID       ( TARGET2_WVALID ),
  .TARGET2_WREADY       ( TARGET2_WREADY ),  
  
  .TARGET3_WID          ( TARGET3_WID ),
  .TARGET3_WDATA        ( TARGET3_WDATA ),
  .TARGET3_WSTRB        ( TARGET3_WSTRB ),
  .TARGET3_WLAST        ( TARGET3_WLAST ),
  .TARGET3_WUSER        ( TARGET3_WUSER ),
  .TARGET3_WVALID       ( TARGET3_WVALID ),
  .TARGET3_WREADY       ( TARGET3_WREADY ),
  
  .TARGET4_WID          ( TARGET4_WID ),
  .TARGET4_WDATA        ( TARGET4_WDATA ),
  .TARGET4_WSTRB        ( TARGET4_WSTRB ),
  .TARGET4_WLAST        ( TARGET4_WLAST ),
  .TARGET4_WUSER        ( TARGET4_WUSER ),
  .TARGET4_WVALID       ( TARGET4_WVALID ),
  .TARGET4_WREADY       ( TARGET4_WREADY ),

  .TARGET5_WID          ( TARGET5_WID ),
  .TARGET5_WDATA        ( TARGET5_WDATA ),
  .TARGET5_WSTRB        ( TARGET5_WSTRB ),
  .TARGET5_WLAST        ( TARGET5_WLAST ),
  .TARGET5_WUSER        ( TARGET5_WUSER ),
  .TARGET5_WVALID       ( TARGET5_WVALID ),
  .TARGET5_WREADY       ( TARGET5_WREADY ),

  .TARGET6_WID          ( TARGET6_WID ),
  .TARGET6_WDATA        ( TARGET6_WDATA ),
  .TARGET6_WSTRB        ( TARGET6_WSTRB ),
  .TARGET6_WLAST        ( TARGET6_WLAST ),
  .TARGET6_WUSER        ( TARGET6_WUSER ),
  .TARGET6_WVALID       ( TARGET6_WVALID ),
  .TARGET6_WREADY       ( TARGET6_WREADY ),

  .TARGET7_WID          ( TARGET7_WID ),
  .TARGET7_WDATA        ( TARGET7_WDATA ),
  .TARGET7_WSTRB        ( TARGET7_WSTRB ),
  .TARGET7_WLAST        ( TARGET7_WLAST ),
  .TARGET7_WUSER        ( TARGET7_WUSER ),
  .TARGET7_WVALID       ( TARGET7_WVALID ),
  .TARGET7_WREADY       ( TARGET7_WREADY ),
  
  .TARGET8_WID          ( TARGET8_WID ),
  .TARGET8_WDATA        ( TARGET8_WDATA ),
  .TARGET8_WSTRB        ( TARGET8_WSTRB ),
  .TARGET8_WLAST        ( TARGET8_WLAST ),
  .TARGET8_WUSER        ( TARGET8_WUSER ),
  .TARGET8_WVALID       ( TARGET8_WVALID ),
  .TARGET8_WREADY       ( TARGET8_WREADY ),

  .TARGET9_WID          ( TARGET9_WID ),
  .TARGET9_WDATA        ( TARGET9_WDATA ),
  .TARGET9_WSTRB        ( TARGET9_WSTRB ),
  .TARGET9_WLAST        ( TARGET9_WLAST ),
  .TARGET9_WUSER        ( TARGET9_WUSER ),
  .TARGET9_WVALID       ( TARGET9_WVALID ),
  .TARGET9_WREADY       ( TARGET9_WREADY ),

  .TARGET10_WID         ( TARGET10_WID ),
  .TARGET10_WDATA       ( TARGET10_WDATA ),
  .TARGET10_WSTRB       ( TARGET10_WSTRB ),
  .TARGET10_WLAST       ( TARGET10_WLAST ),
  .TARGET10_WUSER       ( TARGET10_WUSER ),
  .TARGET10_WVALID      ( TARGET10_WVALID ),
  .TARGET10_WREADY      ( TARGET10_WREADY ),  
  
  .TARGET11_WID         ( TARGET11_WID ),
  .TARGET11_WDATA       ( TARGET11_WDATA ),
  .TARGET11_WSTRB       ( TARGET11_WSTRB ),
  .TARGET11_WLAST       ( TARGET11_WLAST ),
  .TARGET11_WUSER       ( TARGET11_WUSER ),
  .TARGET11_WVALID      ( TARGET11_WVALID ),
  .TARGET11_WREADY      ( TARGET11_WREADY ),
  
  .TARGET12_WID         ( TARGET12_WID ),
  .TARGET12_WDATA       ( TARGET12_WDATA ),
  .TARGET12_WSTRB       ( TARGET12_WSTRB ),
  .TARGET12_WLAST       ( TARGET12_WLAST ),
  .TARGET12_WUSER       ( TARGET12_WUSER ),
  .TARGET12_WVALID      ( TARGET12_WVALID ),
  .TARGET12_WREADY      ( TARGET12_WREADY ),

  .TARGET13_WID         ( TARGET13_WID ),
  .TARGET13_WDATA       ( TARGET13_WDATA ),
  .TARGET13_WSTRB       ( TARGET13_WSTRB ),
  .TARGET13_WLAST       ( TARGET13_WLAST ),
  .TARGET13_WUSER       ( TARGET13_WUSER ),
  .TARGET13_WVALID      ( TARGET13_WVALID ),
  .TARGET13_WREADY      ( TARGET13_WREADY ),

  .TARGET14_WID         ( TARGET14_WID ),
  .TARGET14_WDATA       ( TARGET14_WDATA ),
  .TARGET14_WSTRB       ( TARGET14_WSTRB ),
  .TARGET14_WLAST       ( TARGET14_WLAST ),
  .TARGET14_WUSER       ( TARGET14_WUSER ),
  .TARGET14_WVALID      ( TARGET14_WVALID ),
  .TARGET14_WREADY      ( TARGET14_WREADY ),

  .TARGET15_WID         ( TARGET15_WID ),
  .TARGET15_WDATA       ( TARGET15_WDATA ),
  .TARGET15_WSTRB       ( TARGET15_WSTRB ),
  .TARGET15_WLAST       ( TARGET15_WLAST ),
  .TARGET15_WUSER       ( TARGET15_WUSER ),
  .TARGET15_WVALID      ( TARGET15_WVALID ),
  .TARGET15_WREADY      ( TARGET15_WREADY ),
  
  .TARGET16_WID         ( TARGET16_WID ),
  .TARGET16_WDATA       ( TARGET16_WDATA ),
  .TARGET16_WSTRB       ( TARGET16_WSTRB ),
  .TARGET16_WLAST       ( TARGET16_WLAST ),
  .TARGET16_WUSER       ( TARGET16_WUSER ),
  .TARGET16_WVALID      ( TARGET16_WVALID ),
  .TARGET16_WREADY      ( TARGET16_WREADY ),

  .TARGET17_WID         ( TARGET17_WID ),
  .TARGET17_WDATA       ( TARGET17_WDATA ),
  .TARGET17_WSTRB       ( TARGET17_WSTRB ),
  .TARGET17_WLAST       ( TARGET17_WLAST ),
  .TARGET17_WUSER       ( TARGET17_WUSER ),
  .TARGET17_WVALID      ( TARGET17_WVALID ),
  .TARGET17_WREADY      ( TARGET17_WREADY ),

  .TARGET18_WID         ( TARGET18_WID ),
  .TARGET18_WDATA       ( TARGET18_WDATA ),
  .TARGET18_WSTRB       ( TARGET18_WSTRB ),
  .TARGET18_WLAST       ( TARGET18_WLAST ),
  .TARGET18_WUSER       ( TARGET18_WUSER ),
  .TARGET18_WVALID      ( TARGET18_WVALID ),
  .TARGET18_WREADY      ( TARGET18_WREADY ),  
  
  .TARGET19_WID         ( TARGET19_WID ),
  .TARGET19_WDATA       ( TARGET19_WDATA ),
  .TARGET19_WSTRB       ( TARGET19_WSTRB ),
  .TARGET19_WLAST       ( TARGET19_WLAST ),
  .TARGET19_WUSER       ( TARGET19_WUSER ),
  .TARGET19_WVALID      ( TARGET19_WVALID ),
  .TARGET19_WREADY      ( TARGET19_WREADY ),
  
  .TARGET20_WID         ( TARGET20_WID ),
  .TARGET20_WDATA       ( TARGET20_WDATA ),
  .TARGET20_WSTRB       ( TARGET20_WSTRB ),
  .TARGET20_WLAST       ( TARGET20_WLAST ),
  .TARGET20_WUSER       ( TARGET20_WUSER ),
  .TARGET20_WVALID      ( TARGET20_WVALID ),
  .TARGET20_WREADY      ( TARGET20_WREADY ),

  .TARGET21_WID         ( TARGET21_WID ),
  .TARGET21_WDATA       ( TARGET21_WDATA ),
  .TARGET21_WSTRB       ( TARGET21_WSTRB ),
  .TARGET21_WLAST       ( TARGET21_WLAST ),
  .TARGET21_WUSER       ( TARGET21_WUSER ),
  .TARGET21_WVALID      ( TARGET21_WVALID ),
  .TARGET21_WREADY      ( TARGET21_WREADY ),

  .TARGET22_WID         ( TARGET22_WID ),
  .TARGET22_WDATA       ( TARGET22_WDATA ),
  .TARGET22_WSTRB       ( TARGET22_WSTRB ),
  .TARGET22_WLAST       ( TARGET22_WLAST ),
  .TARGET22_WUSER       ( TARGET22_WUSER ),
  .TARGET22_WVALID      ( TARGET22_WVALID ),
  .TARGET22_WREADY      ( TARGET22_WREADY ),

  .TARGET23_WID         ( TARGET23_WID ),
  .TARGET23_WDATA       ( TARGET23_WDATA ),
  .TARGET23_WSTRB       ( TARGET23_WSTRB ),
  .TARGET23_WLAST       ( TARGET23_WLAST ),
  .TARGET23_WUSER       ( TARGET23_WUSER ),
  .TARGET23_WVALID      ( TARGET23_WVALID ),
  .TARGET23_WREADY      ( TARGET23_WREADY ),
  
  .TARGET24_WID         ( TARGET24_WID ),
  .TARGET24_WDATA       ( TARGET24_WDATA ),
  .TARGET24_WSTRB       ( TARGET24_WSTRB ),
  .TARGET24_WLAST       ( TARGET24_WLAST ),
  .TARGET24_WUSER       ( TARGET24_WUSER ),
  .TARGET24_WVALID      ( TARGET24_WVALID ),
  .TARGET24_WREADY      ( TARGET24_WREADY ),

  .TARGET25_WID         ( TARGET25_WID ),
  .TARGET25_WDATA       ( TARGET25_WDATA ),
  .TARGET25_WSTRB       ( TARGET25_WSTRB ),
  .TARGET25_WLAST       ( TARGET25_WLAST ),
  .TARGET25_WUSER       ( TARGET25_WUSER ),
  .TARGET25_WVALID      ( TARGET25_WVALID ),
  .TARGET25_WREADY      ( TARGET25_WREADY ),

  .TARGET26_WID         ( TARGET26_WID ),
  .TARGET26_WDATA       ( TARGET26_WDATA ),
  .TARGET26_WSTRB       ( TARGET26_WSTRB ),
  .TARGET26_WLAST       ( TARGET26_WLAST ),
  .TARGET26_WUSER       ( TARGET26_WUSER ),
  .TARGET26_WVALID      ( TARGET26_WVALID ),
  .TARGET26_WREADY      ( TARGET26_WREADY ),  
  
  .TARGET27_WID         ( TARGET27_WID ),
  .TARGET27_WDATA       ( TARGET27_WDATA ),
  .TARGET27_WSTRB       ( TARGET27_WSTRB ),
  .TARGET27_WLAST       ( TARGET27_WLAST ),
  .TARGET27_WUSER       ( TARGET27_WUSER ),
  .TARGET27_WVALID      ( TARGET27_WVALID ),
  .TARGET27_WREADY      ( TARGET27_WREADY ),
  
  .TARGET28_WID         ( TARGET28_WID ),
  .TARGET28_WDATA       ( TARGET28_WDATA ),
  .TARGET28_WSTRB       ( TARGET28_WSTRB ),
  .TARGET28_WLAST       ( TARGET28_WLAST ),
  .TARGET28_WUSER       ( TARGET28_WUSER ),
  .TARGET28_WVALID      ( TARGET28_WVALID ),
  .TARGET28_WREADY      ( TARGET28_WREADY ),

  .TARGET29_WID         ( TARGET29_WID ),
  .TARGET29_WDATA       ( TARGET29_WDATA ),
  .TARGET29_WSTRB       ( TARGET29_WSTRB ),
  .TARGET29_WLAST       ( TARGET29_WLAST ),
  .TARGET29_WUSER       ( TARGET29_WUSER ),
  .TARGET29_WVALID      ( TARGET29_WVALID ),
  .TARGET29_WREADY      ( TARGET29_WREADY ),

  .TARGET30_WID         ( TARGET30_WID ),
  .TARGET30_WDATA       ( TARGET30_WDATA ),
  .TARGET30_WSTRB       ( TARGET30_WSTRB ),
  .TARGET30_WLAST       ( TARGET30_WLAST ),
  .TARGET30_WUSER       ( TARGET30_WUSER ),
  .TARGET30_WVALID      ( TARGET30_WVALID ),
  .TARGET30_WREADY      ( TARGET30_WREADY ),

  .TARGET31_WID         ( TARGET31_WID ),
  .TARGET31_WDATA       ( TARGET31_WDATA ),
  .TARGET31_WSTRB       ( TARGET31_WSTRB ),
  .TARGET31_WLAST       ( TARGET31_WLAST ),
  .TARGET31_WUSER       ( TARGET31_WUSER ),
  .TARGET31_WVALID      ( TARGET31_WVALID ),
  .TARGET31_WREADY      ( TARGET31_WREADY ),
  
  // Target Write Response Ports
  .TARGET0_BID            ( TARGET0_BID ),
  .TARGET0_BRESP          ( TARGET0_BRESP ),
  .TARGET0_BUSER          ( TARGET0_BUSER ),
  .TARGET0_BVALID         ( TARGET0_BVALID ),
  .TARGET0_BREADY         ( TARGET0_BREADY ),

  .TARGET1_BID            ( TARGET1_BID ),
  .TARGET1_BRESP          ( TARGET1_BRESP ),
  .TARGET1_BUSER          ( TARGET1_BUSER ),
  .TARGET1_BVALID         ( TARGET1_BVALID ),
  .TARGET1_BREADY         ( TARGET1_BREADY ),

  .TARGET2_BID            ( TARGET2_BID ),
  .TARGET2_BRESP          ( TARGET2_BRESP ),
  .TARGET2_BUSER          ( TARGET2_BUSER ),
  .TARGET2_BVALID         ( TARGET2_BVALID ),
  .TARGET2_BREADY         ( TARGET2_BREADY ),

  .TARGET3_BID            ( TARGET3_BID ),
  .TARGET3_BRESP          ( TARGET3_BRESP ),
  .TARGET3_BUSER          ( TARGET3_BUSER ),
  .TARGET3_BVALID         ( TARGET3_BVALID ),
  .TARGET3_BREADY         ( TARGET3_BREADY ),

  .TARGET4_BID            ( TARGET4_BID ),
  .TARGET4_BRESP          ( TARGET4_BRESP ),
  .TARGET4_BUSER          ( TARGET4_BUSER ),
  .TARGET4_BVALID         ( TARGET4_BVALID ),
  .TARGET4_BREADY         ( TARGET4_BREADY ),

  .TARGET5_BID            ( TARGET5_BID ),
  .TARGET5_BRESP          ( TARGET5_BRESP ),
  .TARGET5_BUSER          ( TARGET5_BUSER ),
  .TARGET5_BVALID         ( TARGET5_BVALID ),
  .TARGET5_BREADY         ( TARGET5_BREADY ),

  .TARGET6_BID            ( TARGET6_BID ),
  .TARGET6_BRESP          ( TARGET6_BRESP ),
  .TARGET6_BUSER          ( TARGET6_BUSER ),
  .TARGET6_BVALID         ( TARGET6_BVALID ),
  .TARGET6_BREADY         ( TARGET6_BREADY ),

  .TARGET7_BID            ( TARGET7_BID ),
  .TARGET7_BRESP          ( TARGET7_BRESP ),
  .TARGET7_BUSER          ( TARGET7_BUSER ),
  .TARGET7_BVALID         ( TARGET7_BVALID ),
  .TARGET7_BREADY         ( TARGET7_BREADY ),

  .TARGET8_BID            ( TARGET8_BID ),
  .TARGET8_BRESP          ( TARGET8_BRESP ),
  .TARGET8_BUSER          ( TARGET8_BUSER ),
  .TARGET8_BVALID         ( TARGET8_BVALID ),
  .TARGET8_BREADY         ( TARGET8_BREADY ),

  .TARGET9_BID            ( TARGET9_BID ),
  .TARGET9_BRESP          ( TARGET9_BRESP ),
  .TARGET9_BUSER          ( TARGET9_BUSER ),
  .TARGET9_BVALID         ( TARGET9_BVALID ),
  .TARGET9_BREADY         ( TARGET9_BREADY ),

  .TARGET10_BID           ( TARGET10_BID ),
  .TARGET10_BRESP         ( TARGET10_BRESP ),
  .TARGET10_BUSER         ( TARGET10_BUSER ),
  .TARGET10_BVALID        ( TARGET10_BVALID ),
  .TARGET10_BREADY        ( TARGET10_BREADY ),

  .TARGET11_BID           ( TARGET11_BID ),
  .TARGET11_BRESP         ( TARGET11_BRESP ),
  .TARGET11_BUSER         ( TARGET11_BUSER ),
  .TARGET11_BVALID        ( TARGET11_BVALID ),
  .TARGET11_BREADY        ( TARGET11_BREADY ),

  .TARGET12_BID           ( TARGET12_BID ),
  .TARGET12_BRESP         ( TARGET12_BRESP ),
  .TARGET12_BUSER         ( TARGET12_BUSER ),
  .TARGET12_BVALID        ( TARGET12_BVALID ),
  .TARGET12_BREADY        ( TARGET12_BREADY ),

  .TARGET13_BID           ( TARGET13_BID ),
  .TARGET13_BRESP         ( TARGET13_BRESP ),
  .TARGET13_BUSER         ( TARGET13_BUSER ),
  .TARGET13_BVALID        ( TARGET13_BVALID ),
  .TARGET13_BREADY        ( TARGET13_BREADY ),

  .TARGET14_BID           ( TARGET14_BID ),
  .TARGET14_BRESP         ( TARGET14_BRESP ),
  .TARGET14_BUSER         ( TARGET14_BUSER ),
  .TARGET14_BVALID        ( TARGET14_BVALID ),
  .TARGET14_BREADY        ( TARGET14_BREADY ),

  .TARGET15_BID           ( TARGET15_BID ),
  .TARGET15_BRESP         ( TARGET15_BRESP ),
  .TARGET15_BUSER         ( TARGET15_BUSER ),
  .TARGET15_BVALID        ( TARGET15_BVALID ),
  .TARGET15_BREADY        ( TARGET15_BREADY ),

  .TARGET16_BID           ( TARGET16_BID ),
  .TARGET16_BRESP         ( TARGET16_BRESP ),
  .TARGET16_BUSER         ( TARGET16_BUSER ),
  .TARGET16_BVALID        ( TARGET16_BVALID ),
  .TARGET16_BREADY        ( TARGET16_BREADY ),

  .TARGET17_BID           ( TARGET17_BID ),
  .TARGET17_BRESP         ( TARGET17_BRESP ),
  .TARGET17_BUSER         ( TARGET17_BUSER ),
  .TARGET17_BVALID        ( TARGET17_BVALID ),
  .TARGET17_BREADY        ( TARGET17_BREADY ),

  .TARGET18_BID           ( TARGET18_BID ),
  .TARGET18_BRESP         ( TARGET18_BRESP ),
  .TARGET18_BUSER         ( TARGET18_BUSER ),
  .TARGET18_BVALID        ( TARGET18_BVALID ),
  .TARGET18_BREADY        ( TARGET18_BREADY ),

  .TARGET19_BID           ( TARGET19_BID ),
  .TARGET19_BRESP         ( TARGET19_BRESP ),
  .TARGET19_BUSER         ( TARGET19_BUSER ),
  .TARGET19_BVALID        ( TARGET19_BVALID ),
  .TARGET19_BREADY        ( TARGET19_BREADY ),

  .TARGET20_BID           ( TARGET20_BID ),
  .TARGET20_BRESP         ( TARGET20_BRESP ),
  .TARGET20_BUSER         ( TARGET20_BUSER ),
  .TARGET20_BVALID        ( TARGET20_BVALID ),
  .TARGET20_BREADY        ( TARGET20_BREADY ),

  .TARGET21_BID           ( TARGET21_BID ),
  .TARGET21_BRESP         ( TARGET21_BRESP ),
  .TARGET21_BUSER         ( TARGET21_BUSER ),
  .TARGET21_BVALID        ( TARGET21_BVALID ),
  .TARGET21_BREADY        ( TARGET21_BREADY ),

  .TARGET22_BID           ( TARGET22_BID ),
  .TARGET22_BRESP         ( TARGET22_BRESP ),
  .TARGET22_BUSER         ( TARGET22_BUSER ),
  .TARGET22_BVALID        ( TARGET22_BVALID ),
  .TARGET22_BREADY        ( TARGET22_BREADY ),

  .TARGET23_BID           ( TARGET23_BID ),
  .TARGET23_BRESP         ( TARGET23_BRESP ),
  .TARGET23_BUSER         ( TARGET23_BUSER ),
  .TARGET23_BVALID        ( TARGET23_BVALID ),
  .TARGET23_BREADY        ( TARGET23_BREADY ),

  .TARGET24_BID           ( TARGET24_BID ),
  .TARGET24_BRESP         ( TARGET24_BRESP ),
  .TARGET24_BUSER         ( TARGET24_BUSER ),
  .TARGET24_BVALID        ( TARGET24_BVALID ),
  .TARGET24_BREADY        ( TARGET24_BREADY ),

  .TARGET25_BID           ( TARGET25_BID ),
  .TARGET25_BRESP         ( TARGET25_BRESP ),
  .TARGET25_BUSER         ( TARGET25_BUSER ),
  .TARGET25_BVALID        ( TARGET25_BVALID ),
  .TARGET25_BREADY        ( TARGET25_BREADY ),

  .TARGET26_BID           ( TARGET26_BID ),
  .TARGET26_BRESP         ( TARGET26_BRESP ),
  .TARGET26_BUSER         ( TARGET26_BUSER ),
  .TARGET26_BVALID        ( TARGET26_BVALID ),
  .TARGET26_BREADY        ( TARGET26_BREADY ),

  .TARGET27_BID           ( TARGET27_BID ),
  .TARGET27_BRESP         ( TARGET27_BRESP ),
  .TARGET27_BUSER         ( TARGET27_BUSER ),
  .TARGET27_BVALID        ( TARGET27_BVALID ),
  .TARGET27_BREADY        ( TARGET27_BREADY ),

  .TARGET28_BID           ( TARGET28_BID ),
  .TARGET28_BRESP         ( TARGET28_BRESP ),
  .TARGET28_BUSER         ( TARGET28_BUSER ),
  .TARGET28_BVALID        ( TARGET28_BVALID ),
  .TARGET28_BREADY        ( TARGET28_BREADY ),

  .TARGET29_BID           ( TARGET29_BID ),
  .TARGET29_BRESP         ( TARGET29_BRESP ),
  .TARGET29_BUSER         ( TARGET29_BUSER ),
  .TARGET29_BVALID        ( TARGET29_BVALID ),
  .TARGET29_BREADY        ( TARGET29_BREADY ),

  .TARGET30_BID           ( TARGET30_BID ),
  .TARGET30_BRESP         ( TARGET30_BRESP ),
  .TARGET30_BUSER         ( TARGET30_BUSER ),
  .TARGET30_BVALID        ( TARGET30_BVALID ),
  .TARGET30_BREADY        ( TARGET30_BREADY ),

  .TARGET31_BID           ( TARGET31_BID ),
  .TARGET31_BRESP         ( TARGET31_BRESP ),
  .TARGET31_BUSER         ( TARGET31_BUSER ),
  .TARGET31_BVALID        ( TARGET31_BVALID ),
  .TARGET31_BREADY        ( TARGET31_BREADY ),

  //======================  Target Read Address Port  =========================================================//
 // Target Read Address Port
  .TARGET0_ARID          ( TARGET0_ARID ),
  .TARGET0_ARADDR        ( TARGET0_ARADDR ),
  .TARGET0_ARLEN         ( TARGET0_ARLEN ),
  .TARGET0_ARSIZE        ( TARGET0_ARSIZE ),
  .TARGET0_ARBURST       ( TARGET0_ARBURST ),
  .TARGET0_ARLOCK        ( TARGET0_ARLOCK ),
  .TARGET0_ARCACHE       ( TARGET0_ARCACHE ),
  .TARGET0_ARPROT        ( TARGET0_ARPROT ),
  .TARGET0_ARREGION      ( TARGET0_ARREGION ),      // not used
  .TARGET0_ARQOS         ( TARGET0_ARQOS ),        // not used
  .TARGET0_ARUSER        ( TARGET0_ARUSER ),
  .TARGET0_ARVALID       ( TARGET0_ARVALID ),
  .TARGET0_ARREADY       ( TARGET0_ARREADY ),
 
  .TARGET1_ARID          ( TARGET1_ARID ),
  .TARGET1_ARADDR        ( TARGET1_ARADDR ),
  .TARGET1_ARLEN         ( TARGET1_ARLEN ),
  .TARGET1_ARSIZE        ( TARGET1_ARSIZE ),
  .TARGET1_ARBURST       ( TARGET1_ARBURST ),
  .TARGET1_ARLOCK        ( TARGET1_ARLOCK ),
  .TARGET1_ARCACHE       ( TARGET1_ARCACHE ),
  .TARGET1_ARPROT        ( TARGET1_ARPROT ),
  .TARGET1_ARREGION      ( TARGET1_ARREGION ),      // not used
  .TARGET1_ARQOS         ( TARGET1_ARQOS ),        // not used
  .TARGET1_ARUSER        ( TARGET1_ARUSER ),
  .TARGET1_ARVALID       ( TARGET1_ARVALID ),
  .TARGET1_ARREADY       ( TARGET1_ARREADY ),

  .TARGET2_ARID          ( TARGET2_ARID ),
  .TARGET2_ARADDR        ( TARGET2_ARADDR ),
  .TARGET2_ARLEN         ( TARGET2_ARLEN ),
  .TARGET2_ARSIZE        ( TARGET2_ARSIZE ),
  .TARGET2_ARBURST       ( TARGET2_ARBURST ),
  .TARGET2_ARLOCK        ( TARGET2_ARLOCK ),
  .TARGET2_ARCACHE       ( TARGET2_ARCACHE ),
  .TARGET2_ARPROT        ( TARGET2_ARPROT ),
  .TARGET2_ARREGION      ( TARGET2_ARREGION ),      // not used
  .TARGET2_ARQOS         ( TARGET2_ARQOS ),        // not used
  .TARGET2_ARUSER        ( TARGET2_ARUSER ),
  .TARGET2_ARVALID       ( TARGET2_ARVALID ),
  .TARGET2_ARREADY       ( TARGET2_ARREADY ),

  .TARGET3_ARID          ( TARGET3_ARID ),
  .TARGET3_ARADDR        ( TARGET3_ARADDR ),
  .TARGET3_ARLEN         ( TARGET3_ARLEN ),
  .TARGET3_ARSIZE        ( TARGET3_ARSIZE ),
  .TARGET3_ARBURST       ( TARGET3_ARBURST ),
  .TARGET3_ARLOCK        ( TARGET3_ARLOCK ),
  .TARGET3_ARCACHE       ( TARGET3_ARCACHE ),
  .TARGET3_ARPROT        ( TARGET3_ARPROT ),
  .TARGET3_ARREGION      ( TARGET3_ARREGION ),      // not used
  .TARGET3_ARQOS         ( TARGET3_ARQOS ),        // not used
  .TARGET3_ARUSER        ( TARGET3_ARUSER ),
  .TARGET3_ARVALID       ( TARGET3_ARVALID ),
  .TARGET3_ARREADY       ( TARGET3_ARREADY ),

  .TARGET4_ARID          ( TARGET4_ARID ),
  .TARGET4_ARADDR        ( TARGET4_ARADDR ),
  .TARGET4_ARLEN         ( TARGET4_ARLEN ),
  .TARGET4_ARSIZE        ( TARGET4_ARSIZE ),
  .TARGET4_ARBURST       ( TARGET4_ARBURST ),
  .TARGET4_ARLOCK        ( TARGET4_ARLOCK ),
  .TARGET4_ARCACHE       ( TARGET4_ARCACHE ),
  .TARGET4_ARPROT        ( TARGET4_ARPROT ),
  .TARGET4_ARREGION      ( TARGET4_ARREGION ),      // not used
  .TARGET4_ARQOS         ( TARGET4_ARQOS ),        // not used
  .TARGET4_ARUSER        ( TARGET4_ARUSER ),
  .TARGET4_ARVALID       ( TARGET4_ARVALID ),
  .TARGET4_ARREADY       ( TARGET4_ARREADY ),

  .TARGET5_ARID          ( TARGET5_ARID ),
  .TARGET5_ARADDR        ( TARGET5_ARADDR ),
  .TARGET5_ARLEN         ( TARGET5_ARLEN ),
  .TARGET5_ARSIZE        ( TARGET5_ARSIZE ),
  .TARGET5_ARBURST       ( TARGET5_ARBURST ),
  .TARGET5_ARLOCK        ( TARGET5_ARLOCK ),
  .TARGET5_ARCACHE       ( TARGET5_ARCACHE ),
  .TARGET5_ARPROT        ( TARGET5_ARPROT ),
  .TARGET5_ARREGION      ( TARGET5_ARREGION ),      // not used
  .TARGET5_ARQOS         ( TARGET5_ARQOS ),        // not used
  .TARGET5_ARUSER        ( TARGET5_ARUSER ),
  .TARGET5_ARVALID       ( TARGET5_ARVALID ),
  .TARGET5_ARREADY       ( TARGET5_ARREADY ),
  
  .TARGET6_ARID          ( TARGET6_ARID ),
  .TARGET6_ARADDR        ( TARGET6_ARADDR ),
  .TARGET6_ARLEN         ( TARGET6_ARLEN ),
  .TARGET6_ARSIZE        ( TARGET6_ARSIZE ),
  .TARGET6_ARBURST       ( TARGET6_ARBURST ),
  .TARGET6_ARLOCK        ( TARGET6_ARLOCK ),
  .TARGET6_ARCACHE       ( TARGET6_ARCACHE ),
  .TARGET6_ARPROT        ( TARGET6_ARPROT ),
  .TARGET6_ARREGION      ( TARGET6_ARREGION ),      // not used
  .TARGET6_ARQOS         ( TARGET6_ARQOS ),        // not used
  .TARGET6_ARUSER        ( TARGET6_ARUSER ),
  .TARGET6_ARVALID       ( TARGET6_ARVALID ),
  .TARGET6_ARREADY       ( TARGET6_ARREADY ),
  
  .TARGET7_ARID          ( TARGET7_ARID ),
  .TARGET7_ARADDR        ( TARGET7_ARADDR ),
  .TARGET7_ARLEN         ( TARGET7_ARLEN ),
  .TARGET7_ARSIZE        ( TARGET7_ARSIZE ),
  .TARGET7_ARBURST       ( TARGET7_ARBURST ),
  .TARGET7_ARLOCK        ( TARGET7_ARLOCK ),
  .TARGET7_ARCACHE       ( TARGET7_ARCACHE ),
  .TARGET7_ARPROT        ( TARGET7_ARPROT ),
  .TARGET7_ARREGION      ( TARGET7_ARREGION ),      // not used
  .TARGET7_ARQOS         ( TARGET7_ARQOS ),        // not used
  .TARGET7_ARUSER        ( TARGET7_ARUSER ),
  .TARGET7_ARVALID       ( TARGET7_ARVALID ),
  .TARGET7_ARREADY       ( TARGET7_ARREADY ),
  
  .TARGET8_ARID          ( TARGET8_ARID ),
  .TARGET8_ARADDR        ( TARGET8_ARADDR ),
  .TARGET8_ARLEN         ( TARGET8_ARLEN ),
  .TARGET8_ARSIZE        ( TARGET8_ARSIZE ),
  .TARGET8_ARBURST       ( TARGET8_ARBURST ),
  .TARGET8_ARLOCK        ( TARGET8_ARLOCK ),
  .TARGET8_ARCACHE       ( TARGET8_ARCACHE ),
  .TARGET8_ARPROT        ( TARGET8_ARPROT ),
  .TARGET8_ARREGION      ( TARGET8_ARREGION ),      // not used
  .TARGET8_ARQOS         ( TARGET8_ARQOS ),        // not used
  .TARGET8_ARUSER        ( TARGET8_ARUSER ),
  .TARGET8_ARVALID       ( TARGET8_ARVALID ),
  .TARGET8_ARREADY       ( TARGET8_ARREADY ),
 
  .TARGET9_ARID          ( TARGET9_ARID ),
  .TARGET9_ARADDR        ( TARGET9_ARADDR ),
  .TARGET9_ARLEN         ( TARGET9_ARLEN ),
  .TARGET9_ARSIZE        ( TARGET9_ARSIZE ),
  .TARGET9_ARBURST       ( TARGET9_ARBURST ),
  .TARGET9_ARLOCK        ( TARGET9_ARLOCK ),
  .TARGET9_ARCACHE       ( TARGET9_ARCACHE ),
  .TARGET9_ARPROT        ( TARGET9_ARPROT ),
  .TARGET9_ARREGION      ( TARGET9_ARREGION ),      // not used
  .TARGET9_ARQOS         ( TARGET9_ARQOS ),        // not used
  .TARGET9_ARUSER        ( TARGET9_ARUSER ),
  .TARGET9_ARVALID       ( TARGET9_ARVALID ),
  .TARGET9_ARREADY       ( TARGET9_ARREADY ),

  .TARGET10_ARID         ( TARGET10_ARID ),
  .TARGET10_ARADDR       ( TARGET10_ARADDR ),
  .TARGET10_ARLEN        ( TARGET10_ARLEN ),
  .TARGET10_ARSIZE       ( TARGET10_ARSIZE ),
  .TARGET10_ARBURST      ( TARGET10_ARBURST ),
  .TARGET10_ARLOCK       ( TARGET10_ARLOCK ),
  .TARGET10_ARCACHE      ( TARGET10_ARCACHE ),
  .TARGET10_ARPROT       ( TARGET10_ARPROT ),
  .TARGET10_ARREGION     ( TARGET10_ARREGION ),      // not used
  .TARGET10_ARQOS        ( TARGET10_ARQOS ),        // not used
  .TARGET10_ARUSER       ( TARGET10_ARUSER ),
  .TARGET10_ARVALID      ( TARGET10_ARVALID ),
  .TARGET10_ARREADY      ( TARGET10_ARREADY ),

  .TARGET11_ARID         ( TARGET11_ARID ),
  .TARGET11_ARADDR       ( TARGET11_ARADDR ),
  .TARGET11_ARLEN        ( TARGET11_ARLEN ),
  .TARGET11_ARSIZE       ( TARGET11_ARSIZE ),
  .TARGET11_ARBURST      ( TARGET11_ARBURST ),
  .TARGET11_ARLOCK       ( TARGET11_ARLOCK ),
  .TARGET11_ARCACHE      ( TARGET11_ARCACHE ),
  .TARGET11_ARPROT       ( TARGET11_ARPROT ),
  .TARGET11_ARREGION     ( TARGET11_ARREGION ),      // not used
  .TARGET11_ARQOS        ( TARGET11_ARQOS ),        // not used
  .TARGET11_ARUSER       ( TARGET11_ARUSER ),
  .TARGET11_ARVALID      ( TARGET11_ARVALID ),
  .TARGET11_ARREADY      ( TARGET11_ARREADY ),

  .TARGET12_ARID         ( TARGET12_ARID ),
  .TARGET12_ARADDR       ( TARGET12_ARADDR ),
  .TARGET12_ARLEN        ( TARGET12_ARLEN ),
  .TARGET12_ARSIZE       ( TARGET12_ARSIZE ),
  .TARGET12_ARBURST      ( TARGET12_ARBURST ),
  .TARGET12_ARLOCK       ( TARGET12_ARLOCK ),
  .TARGET12_ARCACHE      ( TARGET12_ARCACHE ),
  .TARGET12_ARPROT       ( TARGET12_ARPROT ),
  .TARGET12_ARREGION     ( TARGET12_ARREGION ),      // not used
  .TARGET12_ARQOS        ( TARGET12_ARQOS ),        // not used
  .TARGET12_ARUSER       ( TARGET12_ARUSER ),
  .TARGET12_ARVALID      ( TARGET12_ARVALID ),
  .TARGET12_ARREADY      ( TARGET12_ARREADY ),

  .TARGET13_ARID         ( TARGET13_ARID ),
  .TARGET13_ARADDR       ( TARGET13_ARADDR ),
  .TARGET13_ARLEN        ( TARGET13_ARLEN ),
  .TARGET13_ARSIZE       ( TARGET13_ARSIZE ),
  .TARGET13_ARBURST      ( TARGET13_ARBURST ),
  .TARGET13_ARLOCK       ( TARGET13_ARLOCK ),
  .TARGET13_ARCACHE      ( TARGET13_ARCACHE ),
  .TARGET13_ARPROT       ( TARGET13_ARPROT ),
  .TARGET13_ARREGION     ( TARGET13_ARREGION ),      // not used
  .TARGET13_ARQOS        ( TARGET13_ARQOS ),        // not used
  .TARGET13_ARUSER       ( TARGET13_ARUSER ),
  .TARGET13_ARVALID      ( TARGET13_ARVALID ),
  .TARGET13_ARREADY      ( TARGET13_ARREADY ),
  
  .TARGET14_ARID         ( TARGET14_ARID ),
  .TARGET14_ARADDR       ( TARGET14_ARADDR ),
  .TARGET14_ARLEN        ( TARGET14_ARLEN ),
  .TARGET14_ARSIZE       ( TARGET14_ARSIZE ),
  .TARGET14_ARBURST      ( TARGET14_ARBURST ),
  .TARGET14_ARLOCK       ( TARGET14_ARLOCK ),
  .TARGET14_ARCACHE      ( TARGET14_ARCACHE ),
  .TARGET14_ARPROT       ( TARGET14_ARPROT ),
  .TARGET14_ARREGION     ( TARGET14_ARREGION ),      // not used
  .TARGET14_ARQOS        ( TARGET14_ARQOS ),        // not used
  .TARGET14_ARUSER       ( TARGET14_ARUSER ),
  .TARGET14_ARVALID      ( TARGET14_ARVALID ),
  .TARGET14_ARREADY      ( TARGET14_ARREADY ),
  
  .TARGET15_ARID         ( TARGET15_ARID ),
  .TARGET15_ARADDR       ( TARGET15_ARADDR ),
  .TARGET15_ARLEN        ( TARGET15_ARLEN ),
  .TARGET15_ARSIZE       ( TARGET15_ARSIZE ),
  .TARGET15_ARBURST      ( TARGET15_ARBURST ),
  .TARGET15_ARLOCK       ( TARGET15_ARLOCK ),
  .TARGET15_ARCACHE      ( TARGET15_ARCACHE ),
  .TARGET15_ARPROT       ( TARGET15_ARPROT ),
  .TARGET15_ARREGION     ( TARGET15_ARREGION ),      // not used
  .TARGET15_ARQOS        ( TARGET15_ARQOS ),        // not used
  .TARGET15_ARUSER       ( TARGET15_ARUSER ),
  .TARGET15_ARVALID      ( TARGET15_ARVALID ),
  .TARGET15_ARREADY      ( TARGET15_ARREADY ),
  
  .TARGET16_ARID         ( TARGET16_ARID ),
  .TARGET16_ARADDR       ( TARGET16_ARADDR ),
  .TARGET16_ARLEN        ( TARGET16_ARLEN ),
  .TARGET16_ARSIZE       ( TARGET16_ARSIZE ),
  .TARGET16_ARBURST      ( TARGET16_ARBURST ),
  .TARGET16_ARLOCK       ( TARGET16_ARLOCK ),
  .TARGET16_ARCACHE      ( TARGET16_ARCACHE ),
  .TARGET16_ARPROT       ( TARGET16_ARPROT ),
  .TARGET16_ARREGION     ( TARGET16_ARREGION ),      // not used
  .TARGET16_ARQOS        ( TARGET16_ARQOS ),        // not used
  .TARGET16_ARUSER       ( TARGET16_ARUSER ),
  .TARGET16_ARVALID      ( TARGET16_ARVALID ),
  .TARGET16_ARREADY      ( TARGET16_ARREADY ),
 
  .TARGET17_ARID         ( TARGET17_ARID ),
  .TARGET17_ARADDR       ( TARGET17_ARADDR ),
  .TARGET17_ARLEN        ( TARGET17_ARLEN ),
  .TARGET17_ARSIZE       ( TARGET17_ARSIZE ),
  .TARGET17_ARBURST      ( TARGET17_ARBURST ),
  .TARGET17_ARLOCK       ( TARGET17_ARLOCK ),
  .TARGET17_ARCACHE      ( TARGET17_ARCACHE ),
  .TARGET17_ARPROT       ( TARGET17_ARPROT ),
  .TARGET17_ARREGION     ( TARGET17_ARREGION ),      // not used
  .TARGET17_ARQOS        ( TARGET17_ARQOS ),        // not used
  .TARGET17_ARUSER       ( TARGET17_ARUSER ),
  .TARGET17_ARVALID      ( TARGET17_ARVALID ),
  .TARGET17_ARREADY      ( TARGET17_ARREADY ),

  .TARGET18_ARID         ( TARGET18_ARID ),
  .TARGET18_ARADDR       ( TARGET18_ARADDR ),
  .TARGET18_ARLEN        ( TARGET18_ARLEN ),
  .TARGET18_ARSIZE       ( TARGET18_ARSIZE ),
  .TARGET18_ARBURST      ( TARGET18_ARBURST ),
  .TARGET18_ARLOCK       ( TARGET18_ARLOCK ),
  .TARGET18_ARCACHE      ( TARGET18_ARCACHE ),
  .TARGET18_ARPROT       ( TARGET18_ARPROT ),
  .TARGET18_ARREGION     ( TARGET18_ARREGION ),      // not used
  .TARGET18_ARQOS        ( TARGET18_ARQOS ),        // not used
  .TARGET18_ARUSER       ( TARGET18_ARUSER ),
  .TARGET18_ARVALID      ( TARGET18_ARVALID ),
  .TARGET18_ARREADY      ( TARGET18_ARREADY ),

  .TARGET19_ARID         ( TARGET19_ARID ),
  .TARGET19_ARADDR       ( TARGET19_ARADDR ),
  .TARGET19_ARLEN        ( TARGET19_ARLEN ),
  .TARGET19_ARSIZE       ( TARGET19_ARSIZE ),
  .TARGET19_ARBURST      ( TARGET19_ARBURST ),
  .TARGET19_ARLOCK       ( TARGET19_ARLOCK ),
  .TARGET19_ARCACHE      ( TARGET19_ARCACHE ),
  .TARGET19_ARPROT       ( TARGET19_ARPROT ),
  .TARGET19_ARREGION     ( TARGET19_ARREGION ),      // not used
  .TARGET19_ARQOS        ( TARGET19_ARQOS ),        // not used
  .TARGET19_ARUSER       ( TARGET19_ARUSER ),
  .TARGET19_ARVALID      ( TARGET19_ARVALID ),
  .TARGET19_ARREADY      ( TARGET19_ARREADY ),

  .TARGET20_ARID         ( TARGET20_ARID ),
  .TARGET20_ARADDR       ( TARGET20_ARADDR ),
  .TARGET20_ARLEN        ( TARGET20_ARLEN ),
  .TARGET20_ARSIZE       ( TARGET20_ARSIZE ),
  .TARGET20_ARBURST      ( TARGET20_ARBURST ),
  .TARGET20_ARLOCK       ( TARGET20_ARLOCK ),
  .TARGET20_ARCACHE      ( TARGET20_ARCACHE ),
  .TARGET20_ARPROT       ( TARGET20_ARPROT ),
  .TARGET20_ARREGION     ( TARGET20_ARREGION ),      // not used
  .TARGET20_ARQOS        ( TARGET20_ARQOS ),        // not used
  .TARGET20_ARUSER       ( TARGET20_ARUSER ),
  .TARGET20_ARVALID      ( TARGET20_ARVALID ),
  .TARGET20_ARREADY      ( TARGET20_ARREADY ),

  .TARGET21_ARID         ( TARGET21_ARID ),
  .TARGET21_ARADDR       ( TARGET21_ARADDR ),
  .TARGET21_ARLEN        ( TARGET21_ARLEN ),
  .TARGET21_ARSIZE       ( TARGET21_ARSIZE ),
  .TARGET21_ARBURST      ( TARGET21_ARBURST ),
  .TARGET21_ARLOCK       ( TARGET21_ARLOCK ),
  .TARGET21_ARCACHE      ( TARGET21_ARCACHE ),
  .TARGET21_ARPROT       ( TARGET21_ARPROT ),
  .TARGET21_ARREGION     ( TARGET21_ARREGION ),      // not used
  .TARGET21_ARQOS        ( TARGET21_ARQOS ),        // not used
  .TARGET21_ARUSER       ( TARGET21_ARUSER ),
  .TARGET21_ARVALID      ( TARGET21_ARVALID ),
  .TARGET21_ARREADY      ( TARGET21_ARREADY ),
  
  .TARGET22_ARID         ( TARGET22_ARID ),
  .TARGET22_ARADDR       ( TARGET22_ARADDR ),
  .TARGET22_ARLEN        ( TARGET22_ARLEN ),
  .TARGET22_ARSIZE       ( TARGET22_ARSIZE ),
  .TARGET22_ARBURST      ( TARGET22_ARBURST ),
  .TARGET22_ARLOCK       ( TARGET22_ARLOCK ),
  .TARGET22_ARCACHE      ( TARGET22_ARCACHE ),
  .TARGET22_ARPROT       ( TARGET22_ARPROT ),
  .TARGET22_ARREGION     ( TARGET22_ARREGION ),      // not used
  .TARGET22_ARQOS        ( TARGET22_ARQOS ),        // not used
  .TARGET22_ARUSER       ( TARGET22_ARUSER ),
  .TARGET22_ARVALID      ( TARGET22_ARVALID ),
  .TARGET22_ARREADY      ( TARGET22_ARREADY ),
  
  .TARGET23_ARID         ( TARGET23_ARID ),
  .TARGET23_ARADDR       ( TARGET23_ARADDR ),
  .TARGET23_ARLEN        ( TARGET23_ARLEN ),
  .TARGET23_ARSIZE       ( TARGET23_ARSIZE ),
  .TARGET23_ARBURST      ( TARGET23_ARBURST ),
  .TARGET23_ARLOCK       ( TARGET23_ARLOCK ),
  .TARGET23_ARCACHE      ( TARGET23_ARCACHE ),
  .TARGET23_ARPROT       ( TARGET23_ARPROT ),
  .TARGET23_ARREGION     ( TARGET23_ARREGION ),      // not used
  .TARGET23_ARQOS        ( TARGET23_ARQOS ),        // not used
  .TARGET23_ARUSER       ( TARGET23_ARUSER ),
  .TARGET23_ARVALID      ( TARGET23_ARVALID ),
  .TARGET23_ARREADY      ( TARGET23_ARREADY ),
  
  .TARGET24_ARID         ( TARGET24_ARID ),
  .TARGET24_ARADDR       ( TARGET24_ARADDR ),
  .TARGET24_ARLEN        ( TARGET24_ARLEN ),
  .TARGET24_ARSIZE       ( TARGET24_ARSIZE ),
  .TARGET24_ARBURST      ( TARGET24_ARBURST ),
  .TARGET24_ARLOCK       ( TARGET24_ARLOCK ),
  .TARGET24_ARCACHE      ( TARGET24_ARCACHE ),
  .TARGET24_ARPROT       ( TARGET24_ARPROT ),
  .TARGET24_ARREGION     ( TARGET24_ARREGION ),      // not used
  .TARGET24_ARQOS        ( TARGET24_ARQOS ),        // not used
  .TARGET24_ARUSER       ( TARGET24_ARUSER ),
  .TARGET24_ARVALID      ( TARGET24_ARVALID ),
  .TARGET24_ARREADY      ( TARGET24_ARREADY ),
 
  .TARGET25_ARID         ( TARGET25_ARID ),
  .TARGET25_ARADDR       ( TARGET25_ARADDR ),
  .TARGET25_ARLEN        ( TARGET25_ARLEN ),
  .TARGET25_ARSIZE       ( TARGET25_ARSIZE ),
  .TARGET25_ARBURST      ( TARGET25_ARBURST ),
  .TARGET25_ARLOCK       ( TARGET25_ARLOCK ),
  .TARGET25_ARCACHE      ( TARGET25_ARCACHE ),
  .TARGET25_ARPROT       ( TARGET25_ARPROT ),
  .TARGET25_ARREGION     ( TARGET25_ARREGION ),      // not used
  .TARGET25_ARQOS        ( TARGET25_ARQOS ),        // not used
  .TARGET25_ARUSER       ( TARGET25_ARUSER ),
  .TARGET25_ARVALID      ( TARGET25_ARVALID ),
  .TARGET25_ARREADY      ( TARGET25_ARREADY ),

  .TARGET26_ARID         ( TARGET26_ARID ),
  .TARGET26_ARADDR       ( TARGET26_ARADDR ),
  .TARGET26_ARLEN        ( TARGET26_ARLEN ),
  .TARGET26_ARSIZE       ( TARGET26_ARSIZE ),
  .TARGET26_ARBURST      ( TARGET26_ARBURST ),
  .TARGET26_ARLOCK       ( TARGET26_ARLOCK ),
  .TARGET26_ARCACHE      ( TARGET26_ARCACHE ),
  .TARGET26_ARPROT       ( TARGET26_ARPROT ),
  .TARGET26_ARREGION     ( TARGET26_ARREGION ),      // not used
  .TARGET26_ARQOS        ( TARGET26_ARQOS ),        // not used
  .TARGET26_ARUSER       ( TARGET26_ARUSER ),
  .TARGET26_ARVALID      ( TARGET26_ARVALID ),
  .TARGET26_ARREADY      ( TARGET26_ARREADY ),

  .TARGET27_ARID         ( TARGET27_ARID ),
  .TARGET27_ARADDR       ( TARGET27_ARADDR ),
  .TARGET27_ARLEN        ( TARGET27_ARLEN ),
  .TARGET27_ARSIZE       ( TARGET27_ARSIZE ),
  .TARGET27_ARBURST      ( TARGET27_ARBURST ),
  .TARGET27_ARLOCK       ( TARGET27_ARLOCK ),
  .TARGET27_ARCACHE      ( TARGET27_ARCACHE ),
  .TARGET27_ARPROT       ( TARGET27_ARPROT ),
  .TARGET27_ARREGION     ( TARGET27_ARREGION ),      // not used
  .TARGET27_ARQOS        ( TARGET27_ARQOS ),        // not used
  .TARGET27_ARUSER       ( TARGET27_ARUSER ),
  .TARGET27_ARVALID      ( TARGET27_ARVALID ),
  .TARGET27_ARREADY      ( TARGET27_ARREADY ),

  .TARGET28_ARID         ( TARGET28_ARID ),
  .TARGET28_ARADDR       ( TARGET28_ARADDR ),
  .TARGET28_ARLEN        ( TARGET28_ARLEN ),
  .TARGET28_ARSIZE       ( TARGET28_ARSIZE ),
  .TARGET28_ARBURST      ( TARGET28_ARBURST ),
  .TARGET28_ARLOCK       ( TARGET28_ARLOCK ),
  .TARGET28_ARCACHE      ( TARGET28_ARCACHE ),
  .TARGET28_ARPROT       ( TARGET28_ARPROT ),
  .TARGET28_ARREGION     ( TARGET28_ARREGION ),      // not used
  .TARGET28_ARQOS        ( TARGET28_ARQOS ),        // not used
  .TARGET28_ARUSER       ( TARGET28_ARUSER ),
  .TARGET28_ARVALID      ( TARGET28_ARVALID ),
  .TARGET28_ARREADY      ( TARGET28_ARREADY ),

  .TARGET29_ARID         ( TARGET29_ARID ),
  .TARGET29_ARADDR       ( TARGET29_ARADDR ),
  .TARGET29_ARLEN        ( TARGET29_ARLEN ),
  .TARGET29_ARSIZE       ( TARGET29_ARSIZE ),
  .TARGET29_ARBURST      ( TARGET29_ARBURST ),
  .TARGET29_ARLOCK       ( TARGET29_ARLOCK ),
  .TARGET29_ARCACHE      ( TARGET29_ARCACHE ),
  .TARGET29_ARPROT       ( TARGET29_ARPROT ),
  .TARGET29_ARREGION     ( TARGET29_ARREGION ),      // not used
  .TARGET29_ARQOS        ( TARGET29_ARQOS ),        // not used
  .TARGET29_ARUSER       ( TARGET29_ARUSER ),
  .TARGET29_ARVALID      ( TARGET29_ARVALID ),
  .TARGET29_ARREADY      ( TARGET29_ARREADY ),
  
  .TARGET30_ARID         ( TARGET30_ARID ),
  .TARGET30_ARADDR       ( TARGET30_ARADDR ),
  .TARGET30_ARLEN        ( TARGET30_ARLEN ),
  .TARGET30_ARSIZE       ( TARGET30_ARSIZE ),
  .TARGET30_ARBURST      ( TARGET30_ARBURST ),
  .TARGET30_ARLOCK       ( TARGET30_ARLOCK ),
  .TARGET30_ARCACHE      ( TARGET30_ARCACHE ),
  .TARGET30_ARPROT       ( TARGET30_ARPROT ),
  .TARGET30_ARREGION     ( TARGET30_ARREGION ),      // not used
  .TARGET30_ARQOS        ( TARGET30_ARQOS ),        // not used
  .TARGET30_ARUSER       ( TARGET30_ARUSER ),
  .TARGET30_ARVALID      ( TARGET30_ARVALID ),
  .TARGET30_ARREADY      ( TARGET30_ARREADY ),
  
  .TARGET31_ARID         ( TARGET31_ARID ),
  .TARGET31_ARADDR       ( TARGET31_ARADDR ),
  .TARGET31_ARLEN        ( TARGET31_ARLEN ),
  .TARGET31_ARSIZE       ( TARGET31_ARSIZE ),
  .TARGET31_ARBURST      ( TARGET31_ARBURST ),
  .TARGET31_ARLOCK       ( TARGET31_ARLOCK ),
  .TARGET31_ARCACHE      ( TARGET31_ARCACHE ),
  .TARGET31_ARPROT       ( TARGET31_ARPROT ),
  .TARGET31_ARREGION     ( TARGET31_ARREGION ),      // not used
  .TARGET31_ARQOS        ( TARGET31_ARQOS ),        // not used
  .TARGET31_ARUSER       ( TARGET31_ARUSER ),
  .TARGET31_ARVALID      ( TARGET31_ARVALID ),
  .TARGET31_ARREADY      ( TARGET31_ARREADY ),
  
  // Target Read Data Ports
  .TARGET0_RID          ( TARGET0_RID ),
  .TARGET0_RDATA        ( TARGET0_RDATA ),
  .TARGET0_RRESP        ( TARGET0_RRESP ),
  .TARGET0_RLAST        ( TARGET0_RLAST ),
  .TARGET0_RUSER        ( TARGET0_RUSER ),      // not used
  .TARGET0_RVALID       ( TARGET0_RVALID ),
  .TARGET0_RREADY       ( TARGET0_RREADY ),
   
  .TARGET1_RID          ( TARGET1_RID ),
  .TARGET1_RDATA        ( TARGET1_RDATA ),
  .TARGET1_RRESP        ( TARGET1_RRESP ),
  .TARGET1_RLAST        ( TARGET1_RLAST ),
  .TARGET1_RUSER        ( TARGET1_RUSER ),      // not used
  .TARGET1_RVALID       ( TARGET1_RVALID ),
  .TARGET1_RREADY       ( TARGET1_RREADY ),
   
  .TARGET2_RID          ( TARGET2_RID ),
  .TARGET2_RDATA        ( TARGET2_RDATA ),
  .TARGET2_RRESP        ( TARGET2_RRESP ),
  .TARGET2_RLAST        ( TARGET2_RLAST ),
  .TARGET2_RUSER        ( TARGET2_RUSER ),      // not used
  .TARGET2_RVALID       ( TARGET2_RVALID ),
  .TARGET2_RREADY       ( TARGET2_RREADY ),  
 
  .TARGET3_RID          ( TARGET3_RID ),
  .TARGET3_RDATA        ( TARGET3_RDATA ),
  .TARGET3_RRESP        ( TARGET3_RRESP ),
  .TARGET3_RLAST        ( TARGET3_RLAST ),
  .TARGET3_RUSER        ( TARGET3_RUSER ),      // not used
  .TARGET3_RVALID       ( TARGET3_RVALID ),
  .TARGET3_RREADY       ( TARGET3_RREADY ),
   
  .TARGET4_RID          ( TARGET4_RID ),
  .TARGET4_RDATA        ( TARGET4_RDATA ),
  .TARGET4_RRESP        ( TARGET4_RRESP ),
  .TARGET4_RLAST        ( TARGET4_RLAST ),
  .TARGET4_RUSER        ( TARGET4_RUSER ),      // not used
  .TARGET4_RVALID       ( TARGET4_RVALID ),
  .TARGET4_RREADY       ( TARGET4_RREADY ),
   
  .TARGET5_RID          ( TARGET5_RID ),
  .TARGET5_RDATA        ( TARGET5_RDATA ),
  .TARGET5_RRESP        ( TARGET5_RRESP ),
  .TARGET5_RLAST        ( TARGET5_RLAST ),
  .TARGET5_RUSER        ( TARGET5_RUSER ),      // not used
  .TARGET5_RVALID       ( TARGET5_RVALID ),
  .TARGET5_RREADY       ( TARGET5_RREADY ),
   
  .TARGET6_RID          ( TARGET6_RID ),
  .TARGET6_RDATA        ( TARGET6_RDATA ),
  .TARGET6_RRESP        ( TARGET6_RRESP ),
  .TARGET6_RLAST        ( TARGET6_RLAST ),
  .TARGET6_RUSER        ( TARGET6_RUSER ),      // not used
  .TARGET6_RVALID       ( TARGET6_RVALID ),
  .TARGET6_RREADY       ( TARGET6_RREADY ),
   
  .TARGET7_RID          ( TARGET7_RID ),
  .TARGET7_RDATA        ( TARGET7_RDATA ),
  .TARGET7_RRESP        ( TARGET7_RRESP ),
  .TARGET7_RLAST        ( TARGET7_RLAST ),
  .TARGET7_RUSER        ( TARGET7_RUSER ),      // not used
  .TARGET7_RVALID       ( TARGET7_RVALID ),
  .TARGET7_RREADY       ( TARGET7_RREADY ),
   
  .TARGET8_RID          ( TARGET8_RID ),
  .TARGET8_RDATA        ( TARGET8_RDATA ),
  .TARGET8_RRESP        ( TARGET8_RRESP ),
  .TARGET8_RLAST        ( TARGET8_RLAST ),
  .TARGET8_RUSER        ( TARGET8_RUSER ),      // not used
  .TARGET8_RVALID       ( TARGET8_RVALID ),
  .TARGET8_RREADY       ( TARGET8_RREADY ),
   
  .TARGET9_RID          ( TARGET9_RID ),
  .TARGET9_RDATA        ( TARGET9_RDATA ),
  .TARGET9_RRESP        ( TARGET9_RRESP ),
  .TARGET9_RLAST        ( TARGET9_RLAST ),
  .TARGET9_RUSER        ( TARGET9_RUSER ),      // not used
  .TARGET9_RVALID       ( TARGET9_RVALID ),
  .TARGET9_RREADY       ( TARGET9_RREADY ),  
 
  .TARGET10_RID         ( TARGET10_RID ),
  .TARGET10_RDATA       ( TARGET10_RDATA ),
  .TARGET10_RRESP       ( TARGET10_RRESP ),
  .TARGET10_RLAST       ( TARGET10_RLAST ),
  .TARGET10_RUSER       ( TARGET10_RUSER ),      // not used
  .TARGET10_RVALID      ( TARGET10_RVALID ),
  .TARGET10_RREADY      ( TARGET10_RREADY ),
   
  .TARGET11_RID         ( TARGET11_RID ),
  .TARGET11_RDATA       ( TARGET11_RDATA ),
  .TARGET11_RRESP       ( TARGET11_RRESP ),
  .TARGET11_RLAST       ( TARGET11_RLAST ),
  .TARGET11_RUSER       ( TARGET11_RUSER ),      // not used
  .TARGET11_RVALID      ( TARGET11_RVALID ),
  .TARGET11_RREADY      ( TARGET11_RREADY ),
   
  .TARGET12_RID         ( TARGET12_RID ),
  .TARGET12_RDATA       ( TARGET12_RDATA ),
  .TARGET12_RRESP       ( TARGET12_RRESP ),
  .TARGET12_RLAST       ( TARGET12_RLAST ),
  .TARGET12_RUSER       ( TARGET12_RUSER ),      // not used
  .TARGET12_RVALID      ( TARGET12_RVALID ),
  .TARGET12_RREADY      ( TARGET12_RREADY ),
   
  .TARGET13_RID         ( TARGET13_RID ),
  .TARGET13_RDATA       ( TARGET13_RDATA ),
  .TARGET13_RRESP       ( TARGET13_RRESP ),
  .TARGET13_RLAST       ( TARGET13_RLAST ),
  .TARGET13_RUSER       ( TARGET13_RUSER ),      // not used
  .TARGET13_RVALID      ( TARGET13_RVALID ),
  .TARGET13_RREADY      ( TARGET13_RREADY ),
   
  .TARGET14_RID         ( TARGET14_RID ),
  .TARGET14_RDATA       ( TARGET14_RDATA ),
  .TARGET14_RRESP       ( TARGET14_RRESP ),
  .TARGET14_RLAST       ( TARGET14_RLAST ),
  .TARGET14_RUSER       ( TARGET14_RUSER ),      // not used
  .TARGET14_RVALID      ( TARGET14_RVALID ),
  .TARGET14_RREADY      ( TARGET14_RREADY ),
   
  .TARGET15_RID         ( TARGET15_RID ),
  .TARGET15_RDATA       ( TARGET15_RDATA ),
  .TARGET15_RRESP       ( TARGET15_RRESP ),
  .TARGET15_RLAST       ( TARGET15_RLAST ),
  .TARGET15_RUSER       ( TARGET15_RUSER ),      // not used
  .TARGET15_RVALID      ( TARGET15_RVALID ),
  .TARGET15_RREADY      ( TARGET15_RREADY ),
   
  .TARGET16_RID         ( TARGET16_RID ),
  .TARGET16_RDATA       ( TARGET16_RDATA ),
  .TARGET16_RRESP       ( TARGET16_RRESP ),
  .TARGET16_RLAST       ( TARGET16_RLAST ),
  .TARGET16_RUSER       ( TARGET16_RUSER ),      // not used
  .TARGET16_RVALID      ( TARGET16_RVALID ),
  .TARGET16_RREADY      ( TARGET16_RREADY ),  
 
  .TARGET17_RID         ( TARGET17_RID ),
  .TARGET17_RDATA       ( TARGET17_RDATA ),
  .TARGET17_RRESP       ( TARGET17_RRESP ),
  .TARGET17_RLAST       ( TARGET17_RLAST ),
  .TARGET17_RUSER       ( TARGET17_RUSER ),      // not used
  .TARGET17_RVALID      ( TARGET17_RVALID ),
  .TARGET17_RREADY      ( TARGET17_RREADY ),
   
  .TARGET18_RID         ( TARGET18_RID ),
  .TARGET18_RDATA       ( TARGET18_RDATA ),
  .TARGET18_RRESP       ( TARGET18_RRESP ),
  .TARGET18_RLAST       ( TARGET18_RLAST ),
  .TARGET18_RUSER       ( TARGET18_RUSER ),      // not used
  .TARGET18_RVALID      ( TARGET18_RVALID ),
  .TARGET18_RREADY      ( TARGET18_RREADY ),
   
  .TARGET19_RID         ( TARGET19_RID ),
  .TARGET19_RDATA       ( TARGET19_RDATA ),
  .TARGET19_RRESP       ( TARGET19_RRESP ),
  .TARGET19_RLAST       ( TARGET19_RLAST ),
  .TARGET19_RUSER       ( TARGET19_RUSER ),      // not used
  .TARGET19_RVALID      ( TARGET19_RVALID ),
  .TARGET19_RREADY      ( TARGET19_RREADY ),
   
  .TARGET20_RID         ( TARGET20_RID ),
  .TARGET20_RDATA       ( TARGET20_RDATA ),
  .TARGET20_RRESP       ( TARGET20_RRESP ),
  .TARGET20_RLAST       ( TARGET20_RLAST ),
  .TARGET20_RUSER       ( TARGET20_RUSER ),      // not used
  .TARGET20_RVALID      ( TARGET20_RVALID ),
  .TARGET20_RREADY      ( TARGET20_RREADY ),
   
  .TARGET21_RID         ( TARGET21_RID ),
  .TARGET21_RDATA       ( TARGET21_RDATA ),
  .TARGET21_RRESP       ( TARGET21_RRESP ),
  .TARGET21_RLAST       ( TARGET21_RLAST ),
  .TARGET21_RUSER       ( TARGET21_RUSER ),      // not used
  .TARGET21_RVALID      ( TARGET21_RVALID ),
  .TARGET21_RREADY      ( TARGET21_RREADY ),
   
  .TARGET22_RID         ( TARGET22_RID ),
  .TARGET22_RDATA       ( TARGET22_RDATA ),
  .TARGET22_RRESP       ( TARGET22_RRESP ),
  .TARGET22_RLAST       ( TARGET22_RLAST ),
  .TARGET22_RUSER       ( TARGET22_RUSER ),      // not used
  .TARGET22_RVALID      ( TARGET22_RVALID ),
  .TARGET22_RREADY      ( TARGET22_RREADY ),
   
  .TARGET23_RID         ( TARGET23_RID ),
  .TARGET23_RDATA       ( TARGET23_RDATA ),
  .TARGET23_RRESP       ( TARGET23_RRESP ),
  .TARGET23_RLAST       ( TARGET23_RLAST ),
  .TARGET23_RUSER       ( TARGET23_RUSER ),      // not used
  .TARGET23_RVALID      ( TARGET23_RVALID ),
  .TARGET23_RREADY      ( TARGET23_RREADY ),  
 
  .TARGET24_RID         ( TARGET24_RID ),
  .TARGET24_RDATA       ( TARGET24_RDATA ),
  .TARGET24_RRESP       ( TARGET24_RRESP ),
  .TARGET24_RLAST       ( TARGET24_RLAST ),
  .TARGET24_RUSER       ( TARGET24_RUSER ),      // not used
  .TARGET24_RVALID      ( TARGET24_RVALID ),
  .TARGET24_RREADY      ( TARGET24_RREADY ),
   
  .TARGET25_RID         ( TARGET25_RID ),
  .TARGET25_RDATA       ( TARGET25_RDATA ),
  .TARGET25_RRESP       ( TARGET25_RRESP ),
  .TARGET25_RLAST       ( TARGET25_RLAST ),
  .TARGET25_RUSER       ( TARGET25_RUSER ),      // not used
  .TARGET25_RVALID      ( TARGET25_RVALID ),
  .TARGET25_RREADY      ( TARGET25_RREADY ),
   
  .TARGET26_RID         ( TARGET26_RID ),
  .TARGET26_RDATA       ( TARGET26_RDATA ),
  .TARGET26_RRESP       ( TARGET26_RRESP ),
  .TARGET26_RLAST       ( TARGET26_RLAST ),
  .TARGET26_RUSER       ( TARGET26_RUSER ),      // not used
  .TARGET26_RVALID      ( TARGET26_RVALID ),
  .TARGET26_RREADY      ( TARGET26_RREADY ),
   
  .TARGET27_RID         ( TARGET27_RID ),
  .TARGET27_RDATA       ( TARGET27_RDATA ),
  .TARGET27_RRESP       ( TARGET27_RRESP ),
  .TARGET27_RLAST       ( TARGET27_RLAST ),
  .TARGET27_RUSER       ( TARGET27_RUSER ),      // not used
  .TARGET27_RVALID      ( TARGET27_RVALID ),
  .TARGET27_RREADY      ( TARGET27_RREADY ),
   
  .TARGET28_RID         ( TARGET28_RID ),
  .TARGET28_RDATA       ( TARGET28_RDATA ),
  .TARGET28_RRESP       ( TARGET28_RRESP ),
  .TARGET28_RLAST       ( TARGET28_RLAST ),
  .TARGET28_RUSER       ( TARGET28_RUSER ),      // not used
  .TARGET28_RVALID      ( TARGET28_RVALID ),
  .TARGET28_RREADY      ( TARGET28_RREADY ),

  .TARGET29_RID         ( TARGET29_RID ),
  .TARGET29_RDATA       ( TARGET29_RDATA ),
  .TARGET29_RRESP       ( TARGET29_RRESP ),
  .TARGET29_RLAST       ( TARGET29_RLAST ),
  .TARGET29_RUSER       ( TARGET29_RUSER ),      // not used
  .TARGET29_RVALID      ( TARGET29_RVALID ),
  .TARGET29_RREADY      ( TARGET29_RREADY ),
   
  .TARGET30_RID         ( TARGET30_RID ),
  .TARGET30_RDATA       ( TARGET30_RDATA ),
  .TARGET30_RRESP       ( TARGET30_RRESP ),
  .TARGET30_RLAST       ( TARGET30_RLAST ),
  .TARGET30_RUSER       ( TARGET30_RUSER ),      // not used
  .TARGET30_RVALID      ( TARGET30_RVALID ),
  .TARGET30_RREADY      ( TARGET30_RREADY ),
   
  .TARGET31_RID         ( TARGET31_RID ),
  .TARGET31_RDATA       ( TARGET31_RDATA ),
  .TARGET31_RRESP       ( TARGET31_RRESP ),
  .TARGET31_RLAST       ( TARGET31_RLAST ),
  .TARGET31_RUSER       ( TARGET31_RUSER ),      // not used
  .TARGET31_RVALID      ( TARGET31_RVALID ),
  .TARGET31_RREADY      ( TARGET31_RREADY )
  
  );

//====================================================================================================================================
// AXI4 Target transactor models - one for each mirrored target interface
//====================================================================================================================================  
  Axi4TargetGen # 
        (
          .TARGET_NUM              ( 0 ),             // defines target port number
          .ID_WIDTH                ( INITIATORID_WIDTH ), 
          .ADDR_WIDTH              ( ADDR_WIDTH ),
          .DATA_WIDTH             ( TARGET0_DATA_WIDTH ),
          .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH             ( USER_WIDTH ),
          .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
          .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
        )
      trgt0  (
          // Global Signals
          .sysClk         ( T_CLK[0] ),
          .ARESETN        ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

          // Target Read Address Port
          .TARGET_ARID      ( TARGET0_ARID ),
          .TARGET_ARADDR    ( TARGET0_ARADDR ),
          .TARGET_ARLEN    ( TARGET0_ARLEN ),
          .TARGET_ARSIZE    ( TARGET0_ARSIZE ),
          .TARGET_ARBURST  ( TARGET0_ARBURST ),
          .TARGET_ARLOCK    ( TARGET0_ARLOCK ),
          .TARGET_ARCACHE  ( TARGET0_ARCACHE ),
          .TARGET_ARPROT    ( TARGET0_ARPROT ),
          .TARGET_ARREGION  ( TARGET0_ARREGION ),      // not used
          .TARGET_ARQOS    ( TARGET0_ARQOS ),        // not used
          .TARGET_ARUSER    ( TARGET0_ARUSER ),
          .TARGET_ARVALID  ( TARGET0_ARVALID ),
          .TARGET_ARREADY  ( TARGET0_ARREADY ),

          //====================== Target Data Ports  ================================================//
          .TARGET_RVALID    ( TARGET0_RVALID ),
          .TARGET_RID      ( TARGET0_RID ),
          .TARGET_RDATA    ( TARGET0_RDATA ),
          .TARGET_RRESP    ( TARGET0_RRESP ),
          .TARGET_RLAST    ( TARGET0_RLAST ),
          .TARGET_RUSER    ( TARGET0_RUSER ),
          .TARGET_RREADY    ( TARGET0_RREADY ),

          //====================== Target Write Address Ports  ================================================//
          .TARGET_AWID      ( TARGET0_AWID ),
          .TARGET_AWADDR    ( TARGET0_AWADDR ),
          .TARGET_AWLEN    ( TARGET0_AWLEN ),
          .TARGET_AWSIZE    ( TARGET0_AWSIZE ),
          .TARGET_AWBURST  ( TARGET0_AWBURST ),
          .TARGET_AWLOCK    ( TARGET0_AWLOCK ),
          .TARGET_AWCACHE  ( TARGET0_AWCACHE ),
          .TARGET_AWPROT    ( TARGET0_AWPROT ),
          .TARGET_AWREGION  ( TARGET0_AWREGION ),      // not used
          .TARGET_AWQOS    ( TARGET0_AWQOS ),        // not used
          .TARGET_AWUSER    ( TARGET0_AWUSER ),
          .TARGET_AWVALID  ( TARGET0_AWVALID ),
          .TARGET_AWREADY  ( TARGET0_AWREADY ),

          //===================== Target Write Data Ports  ============================================//
          .TARGET_WDATA    ( TARGET0_WDATA ),
          .TARGET_WSTRB    ( TARGET0_WSTRB ),
          .TARGET_WLAST    ( TARGET0_WLAST ),
          .TARGET_WUSER    ( TARGET0_WUSER ),
          .TARGET_WVALID   ( TARGET0_WVALID ),
          .TARGET_WREADY   ( TARGET0_WREADY ),

          // ===============  Target Write Response Ports  =======================================//
          // Initiator Write Response Ports
          .TARGET_BID      ( TARGET0_BID ),
          .TARGET_BRESP    ( TARGET0_BRESP ),
          .TARGET_BUSER    ( TARGET0_BUSER ),
          .TARGET_BVALID   ( TARGET0_BVALID ),
          .TARGET_BREADY   ( TARGET0_BREADY ),

          // ===============  Control Signals  =======================================================//
          .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
          .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
          .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
          .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
          .FORCE_ERROR           ( FORCE_ERROR[0] ),              // Forces error pn read/write RESP
          .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
        );

  Axi4TargetGen # 
        (
          .TARGET_NUM              ( 1 ),             // defines target port number
          .ID_WIDTH                ( INITIATORID_WIDTH ), 
          .ADDR_WIDTH              ( ADDR_WIDTH ),
          .DATA_WIDTH             ( TARGET1_DATA_WIDTH ),
          .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH             ( USER_WIDTH ),
          .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
          .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )

        )
      trgt1  (
          // Global Signals
          .sysClk         ( T_CLK[1] ),
          .ARESETN        ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

          // Target Read Address Port
          .TARGET_ARID      ( TARGET1_ARID ),
          .TARGET_ARADDR    ( TARGET1_ARADDR ),
          .TARGET_ARLEN    ( TARGET1_ARLEN ),
          .TARGET_ARSIZE    ( TARGET1_ARSIZE ),
          .TARGET_ARBURST  ( TARGET1_ARBURST ),
          .TARGET_ARLOCK    ( TARGET1_ARLOCK ),
          .TARGET_ARCACHE  ( TARGET1_ARCACHE ),
          .TARGET_ARPROT    ( TARGET1_ARPROT ),
          .TARGET_ARREGION  ( TARGET1_ARREGION ),      // not used
          .TARGET_ARQOS    ( TARGET1_ARQOS ),        // not used
          .TARGET_ARUSER    ( TARGET1_ARUSER ),
          .TARGET_ARVALID  ( TARGET1_ARVALID ),
          .TARGET_ARREADY  ( TARGET1_ARREADY ),

          //====================== Target Data Ports  =================================================//
          .TARGET_RVALID    ( TARGET1_RVALID ),
          .TARGET_RID      ( TARGET1_RID ),
          .TARGET_RDATA    ( TARGET1_RDATA ),
          .TARGET_RRESP    ( TARGET1_RRESP ),
          .TARGET_RLAST    ( TARGET1_RLAST ),
          .TARGET_RUSER    ( TARGET1_RUSER ),
          .TARGET_RREADY    ( TARGET1_RREADY),

          //====================== Target Write Address Ports  ========================================//
          .TARGET_AWID      ( TARGET1_AWID ),
          .TARGET_AWADDR    ( TARGET1_AWADDR ),
          .TARGET_AWLEN    ( TARGET1_AWLEN ),
          .TARGET_AWSIZE    ( TARGET1_AWSIZE ),
          .TARGET_AWBURST  ( TARGET1_AWBURST ),
          .TARGET_AWLOCK    ( TARGET1_AWLOCK ),
          .TARGET_AWCACHE  ( TARGET1_AWCACHE ),
          .TARGET_AWPROT    ( TARGET1_AWPROT ),
          .TARGET_AWREGION  ( TARGET1_AWREGION ),      // not used
          .TARGET_AWQOS    ( TARGET1_AWQOS ),        // not used
          .TARGET_AWUSER    ( TARGET1_AWUSER ),
          .TARGET_AWVALID  ( TARGET1_AWVALID ),
          .TARGET_AWREADY  ( TARGET1_AWREADY ),

          //===================== Target Write Data Ports  ============================================//
          .TARGET_WDATA    ( TARGET1_WDATA ),
          .TARGET_WSTRB    ( TARGET1_WSTRB ),
          .TARGET_WLAST    ( TARGET1_WLAST ),
          .TARGET_WUSER    ( TARGET1_WUSER ),
          .TARGET_WVALID   ( TARGET1_WVALID ),
          .TARGET_WREADY   ( TARGET1_WREADY ),

          // ===============  Target Write Response Ports  ===========================================//
          .TARGET_BID      ( TARGET1_BID ),
          .TARGET_BRESP    ( TARGET1_BRESP ),
          .TARGET_BUSER    ( TARGET1_BUSER ),
          .TARGET_BVALID   ( TARGET1_BVALID ),
          .TARGET_BREADY   ( TARGET1_BREADY ),

          // ===============  Control Signals  =======================================================//
          .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
          .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
          .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
          .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
          .FORCE_ERROR           ( FORCE_ERROR[1] ),              // Forces error pn read/write RESP
          .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
        );

  Axi4TargetGen # 
        (
          .TARGET_NUM              ( 2 ),             // defines target port number
          .ID_WIDTH               ( INITIATORID_WIDTH ), 
          .ADDR_WIDTH              ( ADDR_WIDTH ),
          .DATA_WIDTH             ( TARGET2_DATA_WIDTH ),
          .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH             ( USER_WIDTH ),
          .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
          .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
        )
      trgt2  (
          // Global Signals
          .sysClk         ( T_CLK[2] ),
          .ARESETN        ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

          //====================== Target Read Address Port  ==========================================//
          .TARGET_ARID      ( TARGET2_ARID ),
          .TARGET_ARADDR    ( TARGET2_ARADDR ),
          .TARGET_ARLEN    ( TARGET2_ARLEN ),
          .TARGET_ARSIZE    ( TARGET2_ARSIZE ),
          .TARGET_ARBURST  ( TARGET2_ARBURST ),
          .TARGET_ARLOCK    ( TARGET2_ARLOCK ),
          .TARGET_ARCACHE  ( TARGET2_ARCACHE ),
          .TARGET_ARPROT    ( TARGET2_ARPROT ),
          .TARGET_ARREGION  ( TARGET2_ARREGION ),      // not used
          .TARGET_ARQOS    ( TARGET2_ARQOS ),        // not used
          .TARGET_ARUSER    ( TARGET2_ARUSER ),
          .TARGET_ARVALID  ( TARGET2_ARVALID ),
          .TARGET_ARREADY  ( TARGET2_ARREADY ),

          //====================== Target Data Ports  ================================================//
          .TARGET_RVALID    ( TARGET2_RVALID ),
          .TARGET_RID      ( TARGET2_RID ),
          .TARGET_RDATA    ( TARGET2_RDATA ),
          .TARGET_RRESP    ( TARGET2_RRESP ),
          .TARGET_RLAST    ( TARGET2_RLAST ),
          .TARGET_RUSER    ( TARGET2_RUSER ),
          .TARGET_RREADY    ( TARGET2_RREADY),

          //====================== Target Write Address Ports  =======================================//
          .TARGET_AWID      ( TARGET2_AWID ),
          .TARGET_AWADDR    ( TARGET2_AWADDR ),
          .TARGET_AWLEN    ( TARGET2_AWLEN ),
          .TARGET_AWSIZE    ( TARGET2_AWSIZE ),
          .TARGET_AWBURST  ( TARGET2_AWBURST ),
          .TARGET_AWLOCK    ( TARGET2_AWLOCK ),
          .TARGET_AWCACHE  ( TARGET2_AWCACHE ),
          .TARGET_AWPROT    ( TARGET2_AWPROT ),
          .TARGET_AWREGION  ( TARGET2_AWREGION ),      // not used
          .TARGET_AWQOS    ( TARGET2_AWQOS ),        // not used
          .TARGET_AWUSER    ( TARGET2_AWUSER ),
          .TARGET_AWVALID  ( TARGET2_AWVALID ),
          .TARGET_AWREADY  ( TARGET2_AWREADY ),

          //===================== Target Write Data Ports  ============================================//
          .TARGET_WDATA    ( TARGET2_WDATA ),
          .TARGET_WSTRB    ( TARGET2_WSTRB ),
          .TARGET_WLAST    ( TARGET2_WLAST ),
          .TARGET_WUSER    ( TARGET2_WUSER ),
          .TARGET_WVALID   ( TARGET2_WVALID ),
          .TARGET_WREADY   ( TARGET2_WREADY ),
          
          //===================== Target Write Response Ports  ============================================//
          .TARGET_BID      ( TARGET2_BID ),
          .TARGET_BRESP    ( TARGET2_BRESP ),
          .TARGET_BUSER    ( TARGET2_BUSER ),
          .TARGET_BVALID   ( TARGET2_BVALID ),
          .TARGET_BREADY   ( TARGET2_BREADY ),

          // ===============  Control Signals  =======================================================//
          .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
          .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
           .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
          .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
          .FORCE_ERROR           ( FORCE_ERROR[2] ),              // Forces error pn read/write RESP
          .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
        );


  Axi4TargetGen # 
        (
          .TARGET_NUM              ( 3 ),             // defines target port number
          .ID_WIDTH               ( INITIATORID_WIDTH ), 
          .ADDR_WIDTH              ( ADDR_WIDTH ),
          .DATA_WIDTH             ( TARGET3_DATA_WIDTH ),
          .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH             ( USER_WIDTH ),
          .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
          .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
        )
      trgt3  (
          // Global Signals
          .sysClk         ( T_CLK[3] ),
          .ARESETN        ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

          // Target Read Address Port
          .TARGET_ARID      ( TARGET3_ARID ),
          .TARGET_ARADDR    ( TARGET3_ARADDR ),
          .TARGET_ARLEN    ( TARGET3_ARLEN ),
          .TARGET_ARSIZE    ( TARGET3_ARSIZE ),
          .TARGET_ARBURST  ( TARGET3_ARBURST ),
          .TARGET_ARLOCK    ( TARGET3_ARLOCK ),
          .TARGET_ARCACHE  ( TARGET3_ARCACHE ),
          .TARGET_ARPROT    ( TARGET3_ARPROT ),
          .TARGET_ARREGION  ( TARGET3_ARREGION ),      // not used
          .TARGET_ARQOS    ( TARGET3_ARQOS ),        // not used
          .TARGET_ARUSER    ( TARGET3_ARUSER ),
          .TARGET_ARVALID  ( TARGET3_ARVALID ),
          .TARGET_ARREADY  ( TARGET3_ARREADY ),

          //====================== Target Data Ports  ================================================//
          .TARGET_RVALID    ( TARGET3_RVALID ),
          .TARGET_RID      ( TARGET3_RID ),
          .TARGET_RDATA    ( TARGET3_RDATA ),
          .TARGET_RRESP    ( TARGET3_RRESP ),
          .TARGET_RLAST    ( TARGET3_RLAST ),
          .TARGET_RUSER    ( TARGET3_RUSER ),
          .TARGET_RREADY    ( TARGET3_RREADY),   

          //====================== Target Write Address Ports  ================================================//
          .TARGET_AWID      ( TARGET3_AWID ),
          .TARGET_AWADDR    ( TARGET3_AWADDR ),
          .TARGET_AWLEN    ( TARGET3_AWLEN ),
          .TARGET_AWSIZE    ( TARGET3_AWSIZE ),
          .TARGET_AWBURST  ( TARGET3_AWBURST ),
          .TARGET_AWLOCK    ( TARGET3_AWLOCK ),
          .TARGET_AWCACHE  ( TARGET3_AWCACHE ),
          .TARGET_AWPROT    ( TARGET3_AWPROT ),
          .TARGET_AWREGION  ( TARGET3_AWREGION ),      // not used
          .TARGET_AWQOS    ( TARGET3_AWQOS ),        // not used
          .TARGET_AWUSER    ( TARGET3_AWUSER ),
          .TARGET_AWVALID  ( TARGET3_AWVALID ),
          .TARGET_AWREADY  ( TARGET3_AWREADY ),

          //===================== Target Write Data Ports  ============================================//
          .TARGET_WDATA    ( TARGET3_WDATA ),
          .TARGET_WSTRB    ( TARGET3_WSTRB ),
          .TARGET_WLAST    ( TARGET3_WLAST ),
          .TARGET_WUSER    ( TARGET3_WUSER ),
          .TARGET_WVALID   ( TARGET3_WVALID ),
          .TARGET_WREADY   ( TARGET3_WREADY ),

          //===================== Target Write Response Ports  ========================================//
          .TARGET_BID      ( TARGET3_BID ),
          .TARGET_BRESP    ( TARGET3_BRESP ),
          .TARGET_BUSER    ( TARGET3_BUSER ),
          .TARGET_BVALID   ( TARGET3_BVALID ),
          .TARGET_BREADY   ( TARGET3_BREADY ),

          // ===============  Control Signals  =======================================================//
          .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
          .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
          .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
          .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
          .FORCE_ERROR           ( FORCE_ERROR[3] ),              // Forces error pn read/write RESP
          .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
        );

  Axi4TargetGen # 
        (
          .TARGET_NUM              ( 4 ),             // defines target port number
          .ID_WIDTH                ( INITIATORID_WIDTH ),
          .ADDR_WIDTH              ( ADDR_WIDTH ),
          .DATA_WIDTH              ( TARGET4_DATA_WIDTH ),
          .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH              ( USER_WIDTH ),
          .LOWER_COMPARE_BIT      ( NUM_AXITARGET_BITS ),
          .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
        )
      trgt4  (
          //======================  Global Signals  =================================================//
          .sysClk         ( T_CLK[4] ),
          .ARESETN        ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

          //======================  Target Read Address Port  ========================================//
          .TARGET_ARID      ( TARGET4_ARID ),
          .TARGET_ARADDR    ( TARGET4_ARADDR ),
          .TARGET_ARLEN    ( TARGET4_ARLEN ),
          .TARGET_ARSIZE    ( TARGET4_ARSIZE ),
          .TARGET_ARBURST  ( TARGET4_ARBURST ),
          .TARGET_ARLOCK    ( TARGET4_ARLOCK ),
          .TARGET_ARCACHE  ( TARGET4_ARCACHE ),
          .TARGET_ARPROT    ( TARGET4_ARPROT ),
          .TARGET_ARREGION  ( TARGET4_ARREGION ),      // not used
          .TARGET_ARQOS    ( TARGET4_ARQOS ),        // not used
          .TARGET_ARUSER    ( TARGET4_ARUSER ),
          .TARGET_ARVALID  ( TARGET4_ARVALID ),
          .TARGET_ARREADY  ( TARGET4_ARREADY ),

          //====================== Target Data Ports  ================================================//
          .TARGET_RVALID    ( TARGET4_RVALID ),
          .TARGET_RID      ( TARGET4_RID ),
          .TARGET_RDATA    ( TARGET4_RDATA ),
          .TARGET_RRESP    ( TARGET4_RRESP ),
          .TARGET_RLAST    ( TARGET4_RLAST ),
          .TARGET_RUSER    ( TARGET4_RUSER ),
          .TARGET_RREADY    ( TARGET4_RREADY),

          //====================== Target Write Address Ports  ========================================//
          .TARGET_AWID      ( TARGET4_AWID ),
          .TARGET_AWADDR    ( TARGET4_AWADDR ),
          .TARGET_AWLEN    ( TARGET4_AWLEN ),
          .TARGET_AWSIZE    ( TARGET4_AWSIZE ),
          .TARGET_AWBURST  ( TARGET4_AWBURST ),
          .TARGET_AWLOCK    ( TARGET4_AWLOCK ),
          .TARGET_AWCACHE  ( TARGET4_AWCACHE ),
          .TARGET_AWPROT    ( TARGET4_AWPROT ),
          .TARGET_AWREGION  ( TARGET4_AWREGION ),      // not used
          .TARGET_AWQOS    ( TARGET4_AWQOS ),        // not used
          .TARGET_AWUSER    ( TARGET4_AWUSER ),
          .TARGET_AWVALID  ( TARGET4_AWVALID ),
          .TARGET_AWREADY  ( TARGET4_AWREADY ),

          //===================== Target Write Data Ports  ============================================//
          .TARGET_WDATA    ( TARGET4_WDATA ),
          .TARGET_WSTRB    ( TARGET4_WSTRB ),
          .TARGET_WLAST    ( TARGET4_WLAST ),
          .TARGET_WUSER    ( TARGET4_WUSER ),
          .TARGET_WVALID   ( TARGET4_WVALID ),
          .TARGET_WREADY   ( TARGET4_WREADY ),

          //=================== Target Write Response Ports  =========================================//
          .TARGET_BID      ( TARGET4_BID ),
          .TARGET_BRESP    ( TARGET4_BRESP ),
          .TARGET_BUSER    ( TARGET4_BUSER ),
          .TARGET_BVALID   ( TARGET4_BVALID ),
          .TARGET_BREADY   ( TARGET4_BREADY ),

          // ===============  Control Signals  =======================================================//
          .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
          .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
          .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
          .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
          .FORCE_ERROR           ( FORCE_ERROR[4] ),              // Forces error pn read/write RESP
          .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
         );

  Axi4TargetGen # 
        (
          .TARGET_NUM              ( 5 ),             // defines target port number
          .ID_WIDTH               ( INITIATORID_WIDTH ), 
          .ADDR_WIDTH              ( ADDR_WIDTH ),
          .DATA_WIDTH             ( TARGET5_DATA_WIDTH ),
          .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH             ( USER_WIDTH ),
          .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
          .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )

        )
      trgt5  (
          //======================  Global Signals   =======================================================//
          .sysClk         ( T_CLK[5] ),
          .ARESETN        ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

          //=====================  Target Read Address Port  ================================================//
          .TARGET_ARID      ( TARGET5_ARID ),
          .TARGET_ARADDR    ( TARGET5_ARADDR ),
          .TARGET_ARLEN    ( TARGET5_ARLEN ),
          .TARGET_ARSIZE    ( TARGET5_ARSIZE ),
          .TARGET_ARBURST  ( TARGET5_ARBURST ),
          .TARGET_ARLOCK    ( TARGET5_ARLOCK ),
          .TARGET_ARCACHE  ( TARGET5_ARCACHE ),
          .TARGET_ARPROT    ( TARGET5_ARPROT ),
          .TARGET_ARREGION  ( TARGET5_ARREGION ),      // not used
          .TARGET_ARQOS    ( TARGET5_ARQOS ),        // not used
          .TARGET_ARUSER    ( TARGET5_ARUSER ),
          .TARGET_ARVALID  ( TARGET5_ARVALID ),
          .TARGET_ARREADY  ( TARGET5_ARREADY ),

          //====================== Target Data Ports  ================================================//
          .TARGET_RVALID    ( TARGET5_RVALID ),
          .TARGET_RID      ( TARGET5_RID ),
          .TARGET_RDATA    ( TARGET5_RDATA ),
          .TARGET_RRESP    ( TARGET5_RRESP ),
          .TARGET_RLAST    ( TARGET5_RLAST ),
          .TARGET_RUSER    ( TARGET5_RUSER ),
          .TARGET_RREADY    ( TARGET5_RREADY),

          //====================== Target Write Address Ports  ================================================//
          .TARGET_AWID      ( TARGET5_AWID ),
          .TARGET_AWADDR    ( TARGET5_AWADDR ),
          .TARGET_AWLEN    ( TARGET5_AWLEN ),
          .TARGET_AWSIZE    ( TARGET5_AWSIZE ),
          .TARGET_AWBURST  ( TARGET5_AWBURST ),
          .TARGET_AWLOCK    ( TARGET5_AWLOCK ),
          .TARGET_AWCACHE  ( TARGET5_AWCACHE ),
          .TARGET_AWPROT    ( TARGET5_AWPROT ),
          .TARGET_AWREGION  ( TARGET5_AWREGION ),      // not used
          .TARGET_AWQOS    ( TARGET5_AWQOS ),        // not used
          .TARGET_AWUSER    ( TARGET5_AWUSER ),
          .TARGET_AWVALID  ( TARGET5_AWVALID ),
          .TARGET_AWREADY  ( TARGET5_AWREADY ),

          //===================== Target Write Data Ports  ============================================//
          .TARGET_WDATA    ( TARGET5_WDATA ),
          .TARGET_WSTRB    ( TARGET5_WSTRB ),
          .TARGET_WLAST    ( TARGET5_WLAST ),
          .TARGET_WUSER    ( TARGET5_WUSER ),
          .TARGET_WVALID   ( TARGET5_WVALID ),
          .TARGET_WREADY   ( TARGET5_WREADY ),

          //==================  Target Write Response Ports  ==========================================//
          .TARGET_BID      ( TARGET5_BID ),
          .TARGET_BRESP    ( TARGET5_BRESP ),
          .TARGET_BUSER    ( TARGET5_BUSER ),
          .TARGET_BVALID   ( TARGET5_BVALID ),

          .TARGET_BREADY   ( TARGET5_BREADY ),

          // ===============  Control Signals  =======================================================//
          .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
          .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
          .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
          .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
          .FORCE_ERROR           ( FORCE_ERROR[5] ),              // Forces error pn read/write RESP
          .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
         );


  Axi4TargetGen # 
        (
          .TARGET_NUM              ( 6 ),             // defines target port number
          .ID_WIDTH               ( INITIATORID_WIDTH ), 
          .ADDR_WIDTH              ( ADDR_WIDTH ),
          .DATA_WIDTH             ( TARGET6_DATA_WIDTH ),
          .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH             ( USER_WIDTH ),
          .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
          .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
        )
      trgt6  (
          //====================  Global Signals  =====================================================//
          .sysClk         ( T_CLK[6] ),
          .ARESETN        ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

          //======================  Target Read Address Port  ==========================================//
          .TARGET_ARID      ( TARGET6_ARID ),
          .TARGET_ARADDR    ( TARGET6_ARADDR ),
          .TARGET_ARLEN    ( TARGET6_ARLEN ),
          .TARGET_ARSIZE    ( TARGET6_ARSIZE ),
          .TARGET_ARBURST  ( TARGET6_ARBURST ),
          .TARGET_ARLOCK    ( TARGET6_ARLOCK ),
          .TARGET_ARCACHE  ( TARGET6_ARCACHE ),
          .TARGET_ARPROT    ( TARGET6_ARPROT ),
          .TARGET_ARREGION  ( TARGET6_ARREGION ),      // not used
          .TARGET_ARQOS    ( TARGET6_ARQOS ),        // not used
          .TARGET_ARUSER    ( TARGET6_ARUSER ),
          .TARGET_ARVALID  ( TARGET6_ARVALID ),
          .TARGET_ARREADY  ( TARGET6_ARREADY ),

          //====================== Target Data Ports  ================================================//
          .TARGET_RVALID    ( TARGET6_RVALID ),
          .TARGET_RID      ( TARGET6_RID ),
          .TARGET_RDATA    ( TARGET6_RDATA ),
          .TARGET_RRESP    ( TARGET6_RRESP ),
          .TARGET_RLAST    ( TARGET6_RLAST ),
          .TARGET_RUSER    ( TARGET6_RUSER ),
          .TARGET_RREADY    ( TARGET6_RREADY),

          //====================== Target Write Address Ports  ================================================//
          .TARGET_AWID      ( TARGET6_AWID ),
          .TARGET_AWADDR    ( TARGET6_AWADDR ),
          .TARGET_AWLEN    ( TARGET6_AWLEN ),
          .TARGET_AWSIZE    ( TARGET6_AWSIZE ),
          .TARGET_AWBURST  ( TARGET6_AWBURST ),
          .TARGET_AWLOCK    ( TARGET6_AWLOCK ),
          .TARGET_AWCACHE  ( TARGET6_AWCACHE ),
          .TARGET_AWPROT    ( TARGET6_AWPROT ),
          .TARGET_AWREGION  ( TARGET6_AWREGION ),      // not used
          .TARGET_AWQOS    ( TARGET6_AWQOS ),        // not used
          .TARGET_AWUSER    ( TARGET6_AWUSER ),
          .TARGET_AWVALID  ( TARGET6_AWVALID ),
          .TARGET_AWREADY  ( TARGET6_AWREADY ),

          //===================== Target Write Data Ports  ============================================//
          .TARGET_WDATA    ( TARGET6_WDATA ),
          .TARGET_WSTRB    ( TARGET6_WSTRB ),
          .TARGET_WLAST    ( TARGET6_WLAST ),
          .TARGET_WUSER    ( TARGET6_WUSER ),
          .TARGET_WVALID   ( TARGET6_WVALID ),
          .TARGET_WREADY   ( TARGET6_WREADY ),

          //==================  Target Write Response Ports  ==========================================//
          .TARGET_BID      ( TARGET6_BID ),
          .TARGET_BRESP    ( TARGET6_BRESP ),
          .TARGET_BUSER    ( TARGET6_BUSER ),
          .TARGET_BVALID   ( TARGET6_BVALID ),
          .TARGET_BREADY( TARGET6_BREADY ),

          // ===============  Control Signals  =======================================================//
          .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
          .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
          .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
          .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
          .FORCE_ERROR           ( FORCE_ERROR[6] ),              // Forces error pn read/write RESP
          .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
         );


  Axi4TargetGen # 
        (
          .TARGET_NUM              ( 7 ),                 // defines target port number
          .ID_WIDTH               ( INITIATORID_WIDTH ), 
          .ADDR_WIDTH              ( ADDR_WIDTH ),
          .DATA_WIDTH             ( TARGET7_DATA_WIDTH ),
          .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH             ( USER_WIDTH ),
          .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
          .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )

        )
      trgt7  (
          //=================  Global Signals  ==========================================================//
          .sysClk         ( T_CLK[7] ),
          .ARESETN        ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

          //================  Target Read Address Port  ===================================================//
          .TARGET_ARID      ( TARGET7_ARID ),
          .TARGET_ARADDR    ( TARGET7_ARADDR ),
          .TARGET_ARLEN    ( TARGET7_ARLEN ),
          .TARGET_ARSIZE    ( TARGET7_ARSIZE ),
          .TARGET_ARBURST  ( TARGET7_ARBURST ),
          .TARGET_ARLOCK    ( TARGET7_ARLOCK ),
          .TARGET_ARCACHE  ( TARGET7_ARCACHE ),
          .TARGET_ARPROT    ( TARGET7_ARPROT ),
          .TARGET_ARREGION  ( TARGET7_ARREGION ),      // not used
          .TARGET_ARQOS    ( TARGET7_ARQOS ),        // not used
          .TARGET_ARUSER    ( TARGET7_ARUSER ),
          .TARGET_ARVALID  ( TARGET7_ARVALID ),
          .TARGET_ARREADY  ( TARGET7_ARREADY ),

          //====================== Target Data Ports  ================================================//
          .TARGET_RVALID    ( TARGET7_RVALID ),
          .TARGET_RID      ( TARGET7_RID ),
          .TARGET_RDATA    ( TARGET7_RDATA ),
          .TARGET_RRESP    ( TARGET7_RRESP ),
          .TARGET_RLAST    ( TARGET7_RLAST ),
          .TARGET_RUSER    ( TARGET7_RUSER ),
          .TARGET_RREADY    ( TARGET7_RREADY),

          //====================== Target Write Address Ports  ================================================//
          .TARGET_AWID      ( TARGET7_AWID ),
          .TARGET_AWADDR    ( TARGET7_AWADDR ),
          .TARGET_AWLEN    ( TARGET7_AWLEN ),
          .TARGET_AWSIZE    ( TARGET7_AWSIZE ),
          .TARGET_AWBURST  ( TARGET7_AWBURST ),
          .TARGET_AWLOCK    ( TARGET7_AWLOCK ),
          .TARGET_AWCACHE  ( TARGET7_AWCACHE ),
          .TARGET_AWPROT    ( TARGET7_AWPROT ),
          .TARGET_AWREGION  ( TARGET7_AWREGION ),      // not used
          .TARGET_AWQOS    ( TARGET7_AWQOS ),        // not used
          .TARGET_AWUSER    ( TARGET7_AWUSER ),
          .TARGET_AWVALID  ( TARGET7_AWVALID ),
          .TARGET_AWREADY  ( TARGET7_AWREADY ),

          //===================== Target Write Data Ports  ============================================//
          .TARGET_WDATA    ( TARGET7_WDATA ),
          .TARGET_WSTRB    ( TARGET7_WSTRB ),
          .TARGET_WLAST    ( TARGET7_WLAST ),
          .TARGET_WUSER    ( TARGET7_WUSER ),
          .TARGET_WVALID   ( TARGET7_WVALID ),

          .TARGET_WREADY   ( TARGET7_WREADY ),

          //===================  Target Write Response Ports  =========================================//
          .TARGET_BID      ( TARGET7_BID ),
          .TARGET_BRESP    ( TARGET7_BRESP ),
          .TARGET_BUSER    ( TARGET7_BUSER ),
          .TARGET_BVALID   ( TARGET7_BVALID ),

          .TARGET_BREADY   ( TARGET7_BREADY ),

          // ===============  Control Signals  =======================================================//
          .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
          .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
          .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
          .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
          .FORCE_ERROR           ( FORCE_ERROR[7] ),              // Forces error pn read/write RESP
          .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
        );


 Axi4TargetGen # (

    .TARGET_NUM              ( 8 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET8_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt8 (
  .sysClk            (T_CLK[8]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET8_ARID ),
  .TARGET_ARADDR      ( TARGET8_ARADDR ),
  .TARGET_ARLEN       ( TARGET8_ARLEN ),
  .TARGET_ARSIZE      ( TARGET8_ARSIZE ),
  .TARGET_ARBURST     ( TARGET8_ARBURST ),
  .TARGET_ARLOCK      ( TARGET8_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET8_ARCACHE ),
  .TARGET_ARPROT      ( TARGET8_ARPROT ),
  .TARGET_ARREGION    ( TARGET8_ARREGION ),
  .TARGET_ARQOS       ( TARGET8_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET8_ARUSER ),
  .TARGET_ARVALID     ( TARGET8_ARVALID ),
  .TARGET_ARREADY     ( TARGET8_ARREADY ),
                              
  // Target Read Data Ports    
  .TARGET_RID         ( TARGET8_RID ),
  .TARGET_RDATA       ( TARGET8_RDATA ),
  .TARGET_RRESP       ( TARGET8_RRESP ),
  .TARGET_RLAST       ( TARGET8_RLAST ),
  .TARGET_RUSER       ( TARGET8_RUSER ),
  .TARGET_RVALID      ( TARGET8_RVALID ),
  .TARGET_RREADY      ( TARGET8_RREADY ),
                              
  .TARGET_AWID        ( TARGET8_AWID ),
  .TARGET_AWADDR      ( TARGET8_AWADDR ),
  .TARGET_AWLEN       ( TARGET8_AWLEN ),
  .TARGET_AWSIZE      ( TARGET8_AWSIZE ),
  .TARGET_AWBURST     ( TARGET8_AWBURST ),
  .TARGET_AWLOCK      ( TARGET8_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET8_AWCACHE ),
  .TARGET_AWPROT      ( TARGET8_AWPROT ),
  .TARGET_AWREGION    ( TARGET8_AWREGION ),
  .TARGET_AWQOS       ( TARGET8_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET8_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET8_AWVALID ),
  .TARGET_AWREADY     ( TARGET8_AWREADY ),
                              
  // Target Write Data Ports   
  .TARGET_WDATA       ( TARGET8_WDATA ),
  .TARGET_WSTRB       ( TARGET8_WSTRB ),
  .TARGET_WLAST       ( TARGET8_WLAST ),
  .TARGET_WUSER       ( TARGET8_WUSER ),
  .TARGET_WVALID      ( TARGET8_WVALID ),
  .TARGET_WREADY      ( TARGET8_WREADY ),
                              
  // Target Write Response Port
  .TARGET_BID         ( TARGET8_BID ),
  .TARGET_BRESP       ( TARGET8_BRESP ),
  .TARGET_BUSER       ( TARGET8_BUSER ),
  .TARGET_BVALID      ( TARGET8_BVALID ),
  .TARGET_BREADY      ( TARGET8_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[8] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);


 Axi4TargetGen # (

    .TARGET_NUM              ( 9 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET9_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt9 (
  .sysClk            (T_CLK[9]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET9_ARID ),
  .TARGET_ARADDR      ( TARGET9_ARADDR ),
  .TARGET_ARLEN       ( TARGET9_ARLEN ),
  .TARGET_ARSIZE      ( TARGET9_ARSIZE ),
  .TARGET_ARBURST     ( TARGET9_ARBURST ),
  .TARGET_ARLOCK      ( TARGET9_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET9_ARCACHE ),
  .TARGET_ARPROT      ( TARGET9_ARPROT ),
  .TARGET_ARREGION    ( TARGET9_ARREGION ),
  .TARGET_ARQOS       ( TARGET9_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET9_ARUSER ),
  .TARGET_ARVALID     ( TARGET9_ARVALID ),
  .TARGET_ARREADY     ( TARGET9_ARREADY ),
                              
  // Target Read Data Ports    
  .TARGET_RID         ( TARGET9_RID ),
  .TARGET_RDATA       ( TARGET9_RDATA ),
  .TARGET_RRESP       ( TARGET9_RRESP ),
  .TARGET_RLAST       ( TARGET9_RLAST ),
  .TARGET_RUSER       ( TARGET9_RUSER ),
  .TARGET_RVALID      ( TARGET9_RVALID ),
  .TARGET_RREADY      ( TARGET9_RREADY ),
                              
  .TARGET_AWID        ( TARGET9_AWID ),
  .TARGET_AWADDR      ( TARGET9_AWADDR ),
  .TARGET_AWLEN       ( TARGET9_AWLEN ),
  .TARGET_AWSIZE      ( TARGET9_AWSIZE ),
  .TARGET_AWBURST     ( TARGET9_AWBURST ),
  .TARGET_AWLOCK      ( TARGET9_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET9_AWCACHE ),
  .TARGET_AWPROT      ( TARGET9_AWPROT ),
  .TARGET_AWREGION    ( TARGET9_AWREGION ),
  .TARGET_AWQOS       ( TARGET9_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET9_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET9_AWVALID ),
  .TARGET_AWREADY     ( TARGET9_AWREADY ),
                              
  // Target Write Data Ports   
  .TARGET_WDATA       ( TARGET9_WDATA ),
  .TARGET_WSTRB       ( TARGET9_WSTRB ),
  .TARGET_WLAST       ( TARGET9_WLAST ),
  .TARGET_WUSER       ( TARGET9_WUSER ),
  .TARGET_WVALID      ( TARGET9_WVALID ),
  .TARGET_WREADY      ( TARGET9_WREADY ),
                              
  // Target Write Response Port
  .TARGET_BID         ( TARGET9_BID ),
  .TARGET_BRESP       ( TARGET9_BRESP ),
  .TARGET_BUSER       ( TARGET9_BUSER ),
  .TARGET_BVALID      ( TARGET9_BVALID ),
  .TARGET_BREADY      ( TARGET9_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[9] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 10 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET10_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt10 (
  .sysClk            (T_CLK[10]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET10_ARID ),
  .TARGET_ARADDR      ( TARGET10_ARADDR ),
  .TARGET_ARLEN       ( TARGET10_ARLEN ),
  .TARGET_ARSIZE      ( TARGET10_ARSIZE ),
  .TARGET_ARBURST     ( TARGET10_ARBURST ),
  .TARGET_ARLOCK      ( TARGET10_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET10_ARCACHE ),
  .TARGET_ARPROT      ( TARGET10_ARPROT ),
  .TARGET_ARREGION    ( TARGET10_ARREGION ),
  .TARGET_ARQOS       ( TARGET10_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET10_ARUSER ),
  .TARGET_ARVALID     ( TARGET10_ARVALID ),
  .TARGET_ARREADY     ( TARGET10_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET10_RID ),
  .TARGET_RDATA       ( TARGET10_RDATA ),
  .TARGET_RRESP       ( TARGET10_RRESP ),
  .TARGET_RLAST       ( TARGET10_RLAST ),
  .TARGET_RUSER       ( TARGET10_RUSER ),
  .TARGET_RVALID      ( TARGET10_RVALID ),
  .TARGET_RREADY      ( TARGET10_RREADY ),

  .TARGET_AWID        ( TARGET10_AWID ),
  .TARGET_AWADDR      ( TARGET10_AWADDR ),
  .TARGET_AWLEN       ( TARGET10_AWLEN ),
  .TARGET_AWSIZE      ( TARGET10_AWSIZE ),
  .TARGET_AWBURST     ( TARGET10_AWBURST ),
  .TARGET_AWLOCK      ( TARGET10_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET10_AWCACHE ),
  .TARGET_AWPROT      ( TARGET10_AWPROT ),
  .TARGET_AWREGION    ( TARGET10_AWREGION ),
  .TARGET_AWQOS       ( TARGET10_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET10_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET10_AWVALID ),
  .TARGET_AWREADY     ( TARGET10_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET10_WDATA ),
  .TARGET_WSTRB       ( TARGET10_WSTRB ),
  .TARGET_WLAST       ( TARGET10_WLAST ),
  .TARGET_WUSER       ( TARGET10_WUSER ),
  .TARGET_WVALID      ( TARGET10_WVALID ),
  .TARGET_WREADY      ( TARGET10_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET10_BID ),
  .TARGET_BRESP       ( TARGET10_BRESP ),
  .TARGET_BUSER       ( TARGET10_BUSER ),
  .TARGET_BVALID      ( TARGET10_BVALID ),
  .TARGET_BREADY      ( TARGET10_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[10] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 11 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET11_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt11 (
  .sysClk            (T_CLK[11]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET11_ARID ),
  .TARGET_ARADDR      ( TARGET11_ARADDR ),
  .TARGET_ARLEN       ( TARGET11_ARLEN ),
  .TARGET_ARSIZE      ( TARGET11_ARSIZE ),
  .TARGET_ARBURST     ( TARGET11_ARBURST ),
  .TARGET_ARLOCK      ( TARGET11_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET11_ARCACHE ),
  .TARGET_ARPROT      ( TARGET11_ARPROT ),
  .TARGET_ARREGION    ( TARGET11_ARREGION ),
  .TARGET_ARQOS       ( TARGET11_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET11_ARUSER ),
  .TARGET_ARVALID     ( TARGET11_ARVALID ),
  .TARGET_ARREADY     ( TARGET11_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET11_RID ),
  .TARGET_RDATA       ( TARGET11_RDATA ),
  .TARGET_RRESP       ( TARGET11_RRESP ),
  .TARGET_RLAST       ( TARGET11_RLAST ),
  .TARGET_RUSER       ( TARGET11_RUSER ),
  .TARGET_RVALID      ( TARGET11_RVALID ),
  .TARGET_RREADY      ( TARGET11_RREADY ),

  .TARGET_AWID        ( TARGET11_AWID ),
  .TARGET_AWADDR      ( TARGET11_AWADDR ),
  .TARGET_AWLEN       ( TARGET11_AWLEN ),
  .TARGET_AWSIZE      ( TARGET11_AWSIZE ),
  .TARGET_AWBURST     ( TARGET11_AWBURST ),
  .TARGET_AWLOCK      ( TARGET11_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET11_AWCACHE ),
  .TARGET_AWPROT      ( TARGET11_AWPROT ),
  .TARGET_AWREGION    ( TARGET11_AWREGION ),
  .TARGET_AWQOS       ( TARGET11_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET11_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET11_AWVALID ),
  .TARGET_AWREADY     ( TARGET11_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET11_WDATA ),
  .TARGET_WSTRB       ( TARGET11_WSTRB ),
  .TARGET_WLAST       ( TARGET11_WLAST ),
  .TARGET_WUSER       ( TARGET11_WUSER ),
  .TARGET_WVALID      ( TARGET11_WVALID ),
  .TARGET_WREADY      ( TARGET11_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET11_BID ),
  .TARGET_BRESP       ( TARGET11_BRESP ),
  .TARGET_BUSER       ( TARGET11_BUSER ),
  .TARGET_BVALID      ( TARGET11_BVALID ),
  .TARGET_BREADY      ( TARGET11_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[11] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 12 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET12_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt12 (
  .sysClk            (T_CLK[12]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET12_ARID ),
  .TARGET_ARADDR      ( TARGET12_ARADDR ),
  .TARGET_ARLEN       ( TARGET12_ARLEN ),
  .TARGET_ARSIZE      ( TARGET12_ARSIZE ),
  .TARGET_ARBURST     ( TARGET12_ARBURST ),
  .TARGET_ARLOCK      ( TARGET12_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET12_ARCACHE ),
  .TARGET_ARPROT      ( TARGET12_ARPROT ),
  .TARGET_ARREGION    ( TARGET12_ARREGION ),
  .TARGET_ARQOS       ( TARGET12_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET12_ARUSER ),
  .TARGET_ARVALID     ( TARGET12_ARVALID ),
  .TARGET_ARREADY     ( TARGET12_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET12_RID ),
  .TARGET_RDATA       ( TARGET12_RDATA ),
  .TARGET_RRESP       ( TARGET12_RRESP ),
  .TARGET_RLAST       ( TARGET12_RLAST ),
  .TARGET_RUSER       ( TARGET12_RUSER ),
  .TARGET_RVALID      ( TARGET12_RVALID ),
  .TARGET_RREADY      ( TARGET12_RREADY ),

  .TARGET_AWID        ( TARGET12_AWID ),
  .TARGET_AWADDR      ( TARGET12_AWADDR ),
  .TARGET_AWLEN       ( TARGET12_AWLEN ),
  .TARGET_AWSIZE      ( TARGET12_AWSIZE ),
  .TARGET_AWBURST     ( TARGET12_AWBURST ),
  .TARGET_AWLOCK      ( TARGET12_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET12_AWCACHE ),
  .TARGET_AWPROT      ( TARGET12_AWPROT ),
  .TARGET_AWREGION    ( TARGET12_AWREGION ),
  .TARGET_AWQOS       ( TARGET12_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET12_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET12_AWVALID ),
  .TARGET_AWREADY     ( TARGET12_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET12_WDATA ),
  .TARGET_WSTRB       ( TARGET12_WSTRB ),
  .TARGET_WLAST       ( TARGET12_WLAST ),
  .TARGET_WUSER       ( TARGET12_WUSER ),
  .TARGET_WVALID      ( TARGET12_WVALID ),
  .TARGET_WREADY      ( TARGET12_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET12_BID ),
  .TARGET_BRESP       ( TARGET12_BRESP ),
  .TARGET_BUSER       ( TARGET12_BUSER ),
  .TARGET_BVALID      ( TARGET12_BVALID ),
  .TARGET_BREADY      ( TARGET12_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[12] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);


 Axi4TargetGen # (

    .TARGET_NUM              ( 13 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET13_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt13 (
  .sysClk            (T_CLK[13]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET13_ARID ),
  .TARGET_ARADDR      ( TARGET13_ARADDR ),
  .TARGET_ARLEN       ( TARGET13_ARLEN ),
  .TARGET_ARSIZE      ( TARGET13_ARSIZE ),
  .TARGET_ARBURST     ( TARGET13_ARBURST ),
  .TARGET_ARLOCK      ( TARGET13_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET13_ARCACHE ),
  .TARGET_ARPROT      ( TARGET13_ARPROT ),
  .TARGET_ARREGION    ( TARGET13_ARREGION ),
  .TARGET_ARQOS       ( TARGET13_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET13_ARUSER ),
  .TARGET_ARVALID     ( TARGET13_ARVALID ),
  .TARGET_ARREADY     ( TARGET13_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET13_RID ),
  .TARGET_RDATA       ( TARGET13_RDATA ),
  .TARGET_RRESP       ( TARGET13_RRESP ),
  .TARGET_RLAST       ( TARGET13_RLAST ),
  .TARGET_RUSER       ( TARGET13_RUSER ),
  .TARGET_RVALID      ( TARGET13_RVALID ),
  .TARGET_RREADY      ( TARGET13_RREADY ),

  .TARGET_AWID        ( TARGET13_AWID ),
  .TARGET_AWADDR      ( TARGET13_AWADDR ),
  .TARGET_AWLEN       ( TARGET13_AWLEN ),
  .TARGET_AWSIZE      ( TARGET13_AWSIZE ),
  .TARGET_AWBURST     ( TARGET13_AWBURST ),
  .TARGET_AWLOCK      ( TARGET13_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET13_AWCACHE ),
  .TARGET_AWPROT      ( TARGET13_AWPROT ),
  .TARGET_AWREGION    ( TARGET13_AWREGION ),
  .TARGET_AWQOS       ( TARGET13_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET13_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET13_AWVALID ),
  .TARGET_AWREADY     ( TARGET13_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET13_WDATA ),
  .TARGET_WSTRB       ( TARGET13_WSTRB ),
  .TARGET_WLAST       ( TARGET13_WLAST ),
  .TARGET_WUSER       ( TARGET13_WUSER ),
  .TARGET_WVALID      ( TARGET13_WVALID ),
  .TARGET_WREADY      ( TARGET13_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET13_BID ),
  .TARGET_BRESP       ( TARGET13_BRESP ),
  .TARGET_BUSER       ( TARGET13_BUSER ),
  .TARGET_BVALID      ( TARGET13_BVALID ),
  .TARGET_BREADY      ( TARGET13_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[13] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);


 Axi4TargetGen # (

    .TARGET_NUM              ( 14 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET14_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt14 (
  .sysClk            (T_CLK[14]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET14_ARID ),
  .TARGET_ARADDR      ( TARGET14_ARADDR ),
  .TARGET_ARLEN       ( TARGET14_ARLEN ),
  .TARGET_ARSIZE      ( TARGET14_ARSIZE ),
  .TARGET_ARBURST     ( TARGET14_ARBURST ),
  .TARGET_ARLOCK      ( TARGET14_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET14_ARCACHE ),
  .TARGET_ARPROT      ( TARGET14_ARPROT ),
  .TARGET_ARREGION    ( TARGET14_ARREGION ),
  .TARGET_ARQOS       ( TARGET14_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET14_ARUSER ),
  .TARGET_ARVALID     ( TARGET14_ARVALID ),
  .TARGET_ARREADY     ( TARGET14_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET14_RID ),
  .TARGET_RDATA       ( TARGET14_RDATA ),
  .TARGET_RRESP       ( TARGET14_RRESP ),
  .TARGET_RLAST       ( TARGET14_RLAST ),
  .TARGET_RUSER       ( TARGET14_RUSER ),
  .TARGET_RVALID      ( TARGET14_RVALID ),
  .TARGET_RREADY      ( TARGET14_RREADY ),

  .TARGET_AWID        ( TARGET14_AWID ),
  .TARGET_AWADDR      ( TARGET14_AWADDR ),
  .TARGET_AWLEN       ( TARGET14_AWLEN ),
  .TARGET_AWSIZE      ( TARGET14_AWSIZE ),
  .TARGET_AWBURST     ( TARGET14_AWBURST ),
  .TARGET_AWLOCK      ( TARGET14_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET14_AWCACHE ),
  .TARGET_AWPROT      ( TARGET14_AWPROT ),
  .TARGET_AWREGION    ( TARGET14_AWREGION ),
  .TARGET_AWQOS       ( TARGET14_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET14_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET14_AWVALID ),
  .TARGET_AWREADY     ( TARGET14_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET14_WDATA ),
  .TARGET_WSTRB       ( TARGET14_WSTRB ),
  .TARGET_WLAST       ( TARGET14_WLAST ),
  .TARGET_WUSER       ( TARGET14_WUSER ),
  .TARGET_WVALID      ( TARGET14_WVALID ),
  .TARGET_WREADY      ( TARGET14_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET14_BID ),
  .TARGET_BRESP       ( TARGET14_BRESP ),
  .TARGET_BUSER       ( TARGET14_BUSER ),
  .TARGET_BVALID      ( TARGET14_BVALID ),
  .TARGET_BREADY      ( TARGET14_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[14] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 15 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET15_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt15 (
  .sysClk            (T_CLK[15]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET15_ARID ),
  .TARGET_ARADDR      ( TARGET15_ARADDR ),
  .TARGET_ARLEN       ( TARGET15_ARLEN ),
  .TARGET_ARSIZE      ( TARGET15_ARSIZE ),
  .TARGET_ARBURST     ( TARGET15_ARBURST ),
  .TARGET_ARLOCK      ( TARGET15_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET15_ARCACHE ),
  .TARGET_ARPROT      ( TARGET15_ARPROT ),
  .TARGET_ARREGION    ( TARGET15_ARREGION ),
  .TARGET_ARQOS       ( TARGET15_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET15_ARUSER ),
  .TARGET_ARVALID     ( TARGET15_ARVALID ),
  .TARGET_ARREADY     ( TARGET15_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET15_RID ),
  .TARGET_RDATA       ( TARGET15_RDATA ),
  .TARGET_RRESP       ( TARGET15_RRESP ),
  .TARGET_RLAST       ( TARGET15_RLAST ),
  .TARGET_RUSER       ( TARGET15_RUSER ),
  .TARGET_RVALID      ( TARGET15_RVALID ),
  .TARGET_RREADY      ( TARGET15_RREADY ),

  .TARGET_AWID        ( TARGET15_AWID ),
  .TARGET_AWADDR      ( TARGET15_AWADDR ),
  .TARGET_AWLEN       ( TARGET15_AWLEN ),
  .TARGET_AWSIZE      ( TARGET15_AWSIZE ),
  .TARGET_AWBURST     ( TARGET15_AWBURST ),
  .TARGET_AWLOCK      ( TARGET15_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET15_AWCACHE ),
  .TARGET_AWPROT      ( TARGET15_AWPROT ),
  .TARGET_AWREGION    ( TARGET15_AWREGION ),
  .TARGET_AWQOS       ( TARGET15_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET15_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET15_AWVALID ),
  .TARGET_AWREADY     ( TARGET15_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET15_WDATA ),
  .TARGET_WSTRB       ( TARGET15_WSTRB ),
  .TARGET_WLAST       ( TARGET15_WLAST ),
  .TARGET_WUSER       ( TARGET15_WUSER ),
  .TARGET_WVALID      ( TARGET15_WVALID ),
  .TARGET_WREADY      ( TARGET15_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET15_BID ),
  .TARGET_BRESP       ( TARGET15_BRESP ),
  .TARGET_BUSER       ( TARGET15_BUSER ),
  .TARGET_BVALID      ( TARGET15_BVALID ),
  .TARGET_BREADY      ( TARGET15_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[15] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 16 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET16_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt16 (
  .sysClk            (T_CLK[16]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET16_ARID ),
  .TARGET_ARADDR      ( TARGET16_ARADDR ),
  .TARGET_ARLEN       ( TARGET16_ARLEN ),
  .TARGET_ARSIZE      ( TARGET16_ARSIZE ),
  .TARGET_ARBURST     ( TARGET16_ARBURST ),
  .TARGET_ARLOCK      ( TARGET16_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET16_ARCACHE ),
  .TARGET_ARPROT      ( TARGET16_ARPROT ),
  .TARGET_ARREGION    ( TARGET16_ARREGION ),
  .TARGET_ARQOS       ( TARGET16_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET16_ARUSER ),
  .TARGET_ARVALID     ( TARGET16_ARVALID ),
  .TARGET_ARREADY     ( TARGET16_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET16_RID ),
  .TARGET_RDATA       ( TARGET16_RDATA ),
  .TARGET_RRESP       ( TARGET16_RRESP ),
  .TARGET_RLAST       ( TARGET16_RLAST ),
  .TARGET_RUSER       ( TARGET16_RUSER ),
  .TARGET_RVALID      ( TARGET16_RVALID ),
  .TARGET_RREADY      ( TARGET16_RREADY ),

  .TARGET_AWID        ( TARGET16_AWID ),
  .TARGET_AWADDR      ( TARGET16_AWADDR ),
  .TARGET_AWLEN       ( TARGET16_AWLEN ),
  .TARGET_AWSIZE      ( TARGET16_AWSIZE ),
  .TARGET_AWBURST     ( TARGET16_AWBURST ),
  .TARGET_AWLOCK      ( TARGET16_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET16_AWCACHE ),
  .TARGET_AWPROT      ( TARGET16_AWPROT ),
  .TARGET_AWREGION    ( TARGET16_AWREGION ),
  .TARGET_AWQOS       ( TARGET16_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET16_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET16_AWVALID ),
  .TARGET_AWREADY     ( TARGET16_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET16_WDATA ),
  .TARGET_WSTRB       ( TARGET16_WSTRB ),
  .TARGET_WLAST       ( TARGET16_WLAST ),
  .TARGET_WUSER       ( TARGET16_WUSER ),
  .TARGET_WVALID      ( TARGET16_WVALID ),
  .TARGET_WREADY      ( TARGET16_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET16_BID ),
  .TARGET_BRESP       ( TARGET16_BRESP ),
  .TARGET_BUSER       ( TARGET16_BUSER ),
  .TARGET_BVALID      ( TARGET16_BVALID ),
  .TARGET_BREADY      ( TARGET16_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[16] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 17 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET17_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt17 (
  .sysClk            (T_CLK[17]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET17_ARID ),
  .TARGET_ARADDR      ( TARGET17_ARADDR ),
  .TARGET_ARLEN       ( TARGET17_ARLEN ),
  .TARGET_ARSIZE      ( TARGET17_ARSIZE ),
  .TARGET_ARBURST     ( TARGET17_ARBURST ),
  .TARGET_ARLOCK      ( TARGET17_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET17_ARCACHE ),
  .TARGET_ARPROT      ( TARGET17_ARPROT ),
  .TARGET_ARREGION    ( TARGET17_ARREGION ),
  .TARGET_ARQOS       ( TARGET17_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET17_ARUSER ),
  .TARGET_ARVALID     ( TARGET17_ARVALID ),
  .TARGET_ARREADY     ( TARGET17_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET17_RID ),
  .TARGET_RDATA       ( TARGET17_RDATA ),
  .TARGET_RRESP       ( TARGET17_RRESP ),
  .TARGET_RLAST       ( TARGET17_RLAST ),
  .TARGET_RUSER       ( TARGET17_RUSER ),
  .TARGET_RVALID      ( TARGET17_RVALID ),
  .TARGET_RREADY      ( TARGET17_RREADY ),

  .TARGET_AWID        ( TARGET17_AWID ),
  .TARGET_AWADDR      ( TARGET17_AWADDR ),
  .TARGET_AWLEN       ( TARGET17_AWLEN ),
  .TARGET_AWSIZE      ( TARGET17_AWSIZE ),
  .TARGET_AWBURST     ( TARGET17_AWBURST ),
  .TARGET_AWLOCK      ( TARGET17_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET17_AWCACHE ),
  .TARGET_AWPROT      ( TARGET17_AWPROT ),
  .TARGET_AWREGION    ( TARGET17_AWREGION ),
  .TARGET_AWQOS       ( TARGET17_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET17_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET17_AWVALID ),
  .TARGET_AWREADY     ( TARGET17_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET17_WDATA ),
  .TARGET_WSTRB       ( TARGET17_WSTRB ),
  .TARGET_WLAST       ( TARGET17_WLAST ),
  .TARGET_WUSER       ( TARGET17_WUSER ),
  .TARGET_WVALID      ( TARGET17_WVALID ),
  .TARGET_WREADY      ( TARGET17_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET17_BID ),
  .TARGET_BRESP       ( TARGET17_BRESP ),
  .TARGET_BUSER       ( TARGET17_BUSER ),
  .TARGET_BVALID      ( TARGET17_BVALID ),
  .TARGET_BREADY      ( TARGET17_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[17] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 18 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET18_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt18 (
  .sysClk            (T_CLK[18]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET18_ARID ),
  .TARGET_ARADDR      ( TARGET18_ARADDR ),
  .TARGET_ARLEN       ( TARGET18_ARLEN ),
  .TARGET_ARSIZE      ( TARGET18_ARSIZE ),
  .TARGET_ARBURST     ( TARGET18_ARBURST ),
  .TARGET_ARLOCK      ( TARGET18_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET18_ARCACHE ),
  .TARGET_ARPROT      ( TARGET18_ARPROT ),
  .TARGET_ARREGION    ( TARGET18_ARREGION ),
  .TARGET_ARQOS       ( TARGET18_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET18_ARUSER ),
  .TARGET_ARVALID     ( TARGET18_ARVALID ),
  .TARGET_ARREADY     ( TARGET18_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET18_RID ),
  .TARGET_RDATA       ( TARGET18_RDATA ),
  .TARGET_RRESP       ( TARGET18_RRESP ),
  .TARGET_RLAST       ( TARGET18_RLAST ),
  .TARGET_RUSER       ( TARGET18_RUSER ),
  .TARGET_RVALID      ( TARGET18_RVALID ),
  .TARGET_RREADY      ( TARGET18_RREADY ),

  .TARGET_AWID        ( TARGET18_AWID ),
  .TARGET_AWADDR      ( TARGET18_AWADDR ),
  .TARGET_AWLEN       ( TARGET18_AWLEN ),
  .TARGET_AWSIZE      ( TARGET18_AWSIZE ),
  .TARGET_AWBURST     ( TARGET18_AWBURST ),
  .TARGET_AWLOCK      ( TARGET18_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET18_AWCACHE ),
  .TARGET_AWPROT      ( TARGET18_AWPROT ),
  .TARGET_AWREGION    ( TARGET18_AWREGION ),
  .TARGET_AWQOS       ( TARGET18_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET18_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET18_AWVALID ),
  .TARGET_AWREADY     ( TARGET18_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET18_WDATA ),
  .TARGET_WSTRB       ( TARGET18_WSTRB ),
  .TARGET_WLAST       ( TARGET18_WLAST ),
  .TARGET_WUSER       ( TARGET18_WUSER ),
  .TARGET_WVALID      ( TARGET18_WVALID ),
  .TARGET_WREADY      ( TARGET18_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET18_BID ),
  .TARGET_BRESP       ( TARGET18_BRESP ),
  .TARGET_BUSER       ( TARGET18_BUSER ),
  .TARGET_BVALID      ( TARGET18_BVALID ),
  .TARGET_BREADY      ( TARGET18_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[18] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 19 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET19_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt19 (
  .sysClk            (T_CLK[19]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET19_ARID ),
  .TARGET_ARADDR      ( TARGET19_ARADDR ),
  .TARGET_ARLEN       ( TARGET19_ARLEN ),
  .TARGET_ARSIZE      ( TARGET19_ARSIZE ),
  .TARGET_ARBURST     ( TARGET19_ARBURST ),
  .TARGET_ARLOCK      ( TARGET19_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET19_ARCACHE ),
  .TARGET_ARPROT      ( TARGET19_ARPROT ),
  .TARGET_ARREGION    ( TARGET19_ARREGION ),
  .TARGET_ARQOS       ( TARGET19_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET19_ARUSER ),
  .TARGET_ARVALID     ( TARGET19_ARVALID ),
  .TARGET_ARREADY     ( TARGET19_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET19_RID ),
  .TARGET_RDATA       ( TARGET19_RDATA ),
  .TARGET_RRESP       ( TARGET19_RRESP ),
  .TARGET_RLAST       ( TARGET19_RLAST ),
  .TARGET_RUSER       ( TARGET19_RUSER ),
  .TARGET_RVALID      ( TARGET19_RVALID ),
  .TARGET_RREADY      ( TARGET19_RREADY ),

  .TARGET_AWID        ( TARGET19_AWID ),
  .TARGET_AWADDR      ( TARGET19_AWADDR ),
  .TARGET_AWLEN       ( TARGET19_AWLEN ),
  .TARGET_AWSIZE      ( TARGET19_AWSIZE ),
  .TARGET_AWBURST     ( TARGET19_AWBURST ),
  .TARGET_AWLOCK      ( TARGET19_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET19_AWCACHE ),
  .TARGET_AWPROT      ( TARGET19_AWPROT ),
  .TARGET_AWREGION    ( TARGET19_AWREGION ),
  .TARGET_AWQOS       ( TARGET19_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET19_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET19_AWVALID ),
  .TARGET_AWREADY     ( TARGET19_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET19_WDATA ),
  .TARGET_WSTRB       ( TARGET19_WSTRB ),
  .TARGET_WLAST       ( TARGET19_WLAST ),
  .TARGET_WUSER       ( TARGET19_WUSER ),
  .TARGET_WVALID      ( TARGET19_WVALID ),
  .TARGET_WREADY      ( TARGET19_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET19_BID ),
  .TARGET_BRESP       ( TARGET19_BRESP ),
  .TARGET_BUSER       ( TARGET19_BUSER ),
  .TARGET_BVALID      ( TARGET19_BVALID ),
  .TARGET_BREADY      ( TARGET19_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[19] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 20 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET20_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt20 (
  .sysClk            (T_CLK[20]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET20_ARID ),
  .TARGET_ARADDR      ( TARGET20_ARADDR ),
  .TARGET_ARLEN       ( TARGET20_ARLEN ),
  .TARGET_ARSIZE      ( TARGET20_ARSIZE ),
  .TARGET_ARBURST     ( TARGET20_ARBURST ),
  .TARGET_ARLOCK      ( TARGET20_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET20_ARCACHE ),
  .TARGET_ARPROT      ( TARGET20_ARPROT ),
  .TARGET_ARREGION    ( TARGET20_ARREGION ),
  .TARGET_ARQOS       ( TARGET20_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET20_ARUSER ),
  .TARGET_ARVALID     ( TARGET20_ARVALID ),
  .TARGET_ARREADY     ( TARGET20_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET20_RID ),
  .TARGET_RDATA       ( TARGET20_RDATA ),
  .TARGET_RRESP       ( TARGET20_RRESP ),
  .TARGET_RLAST       ( TARGET20_RLAST ),
  .TARGET_RUSER       ( TARGET20_RUSER ),
  .TARGET_RVALID      ( TARGET20_RVALID ),
  .TARGET_RREADY      ( TARGET20_RREADY ),

  .TARGET_AWID        ( TARGET20_AWID ),
  .TARGET_AWADDR      ( TARGET20_AWADDR ),
  .TARGET_AWLEN       ( TARGET20_AWLEN ),
  .TARGET_AWSIZE      ( TARGET20_AWSIZE ),
  .TARGET_AWBURST     ( TARGET20_AWBURST ),
  .TARGET_AWLOCK      ( TARGET20_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET20_AWCACHE ),
  .TARGET_AWPROT      ( TARGET20_AWPROT ),
  .TARGET_AWREGION    ( TARGET20_AWREGION ),
  .TARGET_AWQOS       ( TARGET20_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET20_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET20_AWVALID ),
  .TARGET_AWREADY     ( TARGET20_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET20_WDATA ),
  .TARGET_WSTRB       ( TARGET20_WSTRB ),
  .TARGET_WLAST       ( TARGET20_WLAST ),
  .TARGET_WUSER       ( TARGET20_WUSER ),
  .TARGET_WVALID      ( TARGET20_WVALID ),
  .TARGET_WREADY      ( TARGET20_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET20_BID ),
  .TARGET_BRESP       ( TARGET20_BRESP ),
  .TARGET_BUSER       ( TARGET20_BUSER ),
  .TARGET_BVALID      ( TARGET20_BVALID ),
  .TARGET_BREADY      ( TARGET20_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[20] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);


 Axi4TargetGen # (

    .TARGET_NUM              ( 21 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET21_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt21 (
  .sysClk            (T_CLK[21]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET21_ARID ),
  .TARGET_ARADDR      ( TARGET21_ARADDR ),
  .TARGET_ARLEN       ( TARGET21_ARLEN ),
  .TARGET_ARSIZE      ( TARGET21_ARSIZE ),
  .TARGET_ARBURST     ( TARGET21_ARBURST ),
  .TARGET_ARLOCK      ( TARGET21_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET21_ARCACHE ),
  .TARGET_ARPROT      ( TARGET21_ARPROT ),
  .TARGET_ARREGION    ( TARGET21_ARREGION ),
  .TARGET_ARQOS       ( TARGET21_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET21_ARUSER ),
  .TARGET_ARVALID     ( TARGET21_ARVALID ),
  .TARGET_ARREADY     ( TARGET21_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET21_RID ),
  .TARGET_RDATA       ( TARGET21_RDATA ),
  .TARGET_RRESP       ( TARGET21_RRESP ),
  .TARGET_RLAST       ( TARGET21_RLAST ),
  .TARGET_RUSER       ( TARGET21_RUSER ),
  .TARGET_RVALID      ( TARGET21_RVALID ),
  .TARGET_RREADY      ( TARGET21_RREADY ),

  .TARGET_AWID        ( TARGET21_AWID ),
  .TARGET_AWADDR      ( TARGET21_AWADDR ),
  .TARGET_AWLEN       ( TARGET21_AWLEN ),
  .TARGET_AWSIZE      ( TARGET21_AWSIZE ),
  .TARGET_AWBURST     ( TARGET21_AWBURST ),
  .TARGET_AWLOCK      ( TARGET21_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET21_AWCACHE ),
  .TARGET_AWPROT      ( TARGET21_AWPROT ),
  .TARGET_AWREGION    ( TARGET21_AWREGION ),
  .TARGET_AWQOS       ( TARGET21_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET21_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET21_AWVALID ),
  .TARGET_AWREADY     ( TARGET21_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET21_WDATA ),
  .TARGET_WSTRB       ( TARGET21_WSTRB ),
  .TARGET_WLAST       ( TARGET21_WLAST ),
  .TARGET_WUSER       ( TARGET21_WUSER ),
  .TARGET_WVALID      ( TARGET21_WVALID ),
  .TARGET_WREADY      ( TARGET21_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET21_BID ),
  .TARGET_BRESP       ( TARGET21_BRESP ),
  .TARGET_BUSER       ( TARGET21_BUSER ),
  .TARGET_BVALID      ( TARGET21_BVALID ),
  .TARGET_BREADY      ( TARGET21_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[21] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 22 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET22_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt22 (
  .sysClk            (T_CLK[22]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET22_ARID ),
  .TARGET_ARADDR      ( TARGET22_ARADDR ),
  .TARGET_ARLEN       ( TARGET22_ARLEN ),
  .TARGET_ARSIZE      ( TARGET22_ARSIZE ),
  .TARGET_ARBURST     ( TARGET22_ARBURST ),
  .TARGET_ARLOCK      ( TARGET22_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET22_ARCACHE ),
  .TARGET_ARPROT      ( TARGET22_ARPROT ),
  .TARGET_ARREGION    ( TARGET22_ARREGION ),
  .TARGET_ARQOS       ( TARGET22_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET22_ARUSER ),
  .TARGET_ARVALID     ( TARGET22_ARVALID ),
  .TARGET_ARREADY     ( TARGET22_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET22_RID ),
  .TARGET_RDATA       ( TARGET22_RDATA ),
  .TARGET_RRESP       ( TARGET22_RRESP ),
  .TARGET_RLAST       ( TARGET22_RLAST ),
  .TARGET_RUSER       ( TARGET22_RUSER ),
  .TARGET_RVALID      ( TARGET22_RVALID ),
  .TARGET_RREADY      ( TARGET22_RREADY ),

  .TARGET_AWID        ( TARGET22_AWID ),
  .TARGET_AWADDR      ( TARGET22_AWADDR ),
  .TARGET_AWLEN       ( TARGET22_AWLEN ),
  .TARGET_AWSIZE      ( TARGET22_AWSIZE ),
  .TARGET_AWBURST     ( TARGET22_AWBURST ),
  .TARGET_AWLOCK      ( TARGET22_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET22_AWCACHE ),
  .TARGET_AWPROT      ( TARGET22_AWPROT ),
  .TARGET_AWREGION    ( TARGET22_AWREGION ),
  .TARGET_AWQOS       ( TARGET22_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET22_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET22_AWVALID ),
  .TARGET_AWREADY     ( TARGET22_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET22_WDATA ),
  .TARGET_WSTRB       ( TARGET22_WSTRB ),
  .TARGET_WLAST       ( TARGET22_WLAST ),
  .TARGET_WUSER       ( TARGET22_WUSER ),
  .TARGET_WVALID      ( TARGET22_WVALID ),
  .TARGET_WREADY      ( TARGET22_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET22_BID ),
  .TARGET_BRESP       ( TARGET22_BRESP ),
  .TARGET_BUSER       ( TARGET22_BUSER ),
  .TARGET_BVALID      ( TARGET22_BVALID ),
  .TARGET_BREADY      ( TARGET22_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[22] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);


 Axi4TargetGen # (

    .TARGET_NUM              ( 23 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET23_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt23 (
  .sysClk            (T_CLK[23]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET23_ARID ),
  .TARGET_ARADDR      ( TARGET23_ARADDR ),
  .TARGET_ARLEN       ( TARGET23_ARLEN ),
  .TARGET_ARSIZE      ( TARGET23_ARSIZE ),
  .TARGET_ARBURST     ( TARGET23_ARBURST ),
  .TARGET_ARLOCK      ( TARGET23_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET23_ARCACHE ),
  .TARGET_ARPROT      ( TARGET23_ARPROT ),
  .TARGET_ARREGION    ( TARGET23_ARREGION ),
  .TARGET_ARQOS       ( TARGET23_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET23_ARUSER ),
  .TARGET_ARVALID     ( TARGET23_ARVALID ),
  .TARGET_ARREADY     ( TARGET23_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET23_RID ),
  .TARGET_RDATA       ( TARGET23_RDATA ),
  .TARGET_RRESP       ( TARGET23_RRESP ),
  .TARGET_RLAST       ( TARGET23_RLAST ),
  .TARGET_RUSER       ( TARGET23_RUSER ),
  .TARGET_RVALID      ( TARGET23_RVALID ),
  .TARGET_RREADY      ( TARGET23_RREADY ),

  .TARGET_AWID        ( TARGET23_AWID ),
  .TARGET_AWADDR      ( TARGET23_AWADDR ),
  .TARGET_AWLEN       ( TARGET23_AWLEN ),
  .TARGET_AWSIZE      ( TARGET23_AWSIZE ),
  .TARGET_AWBURST     ( TARGET23_AWBURST ),
  .TARGET_AWLOCK      ( TARGET23_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET23_AWCACHE ),
  .TARGET_AWPROT      ( TARGET23_AWPROT ),
  .TARGET_AWREGION    ( TARGET23_AWREGION ),
  .TARGET_AWQOS       ( TARGET23_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET23_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET23_AWVALID ),
  .TARGET_AWREADY     ( TARGET23_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET23_WDATA ),
  .TARGET_WSTRB       ( TARGET23_WSTRB ),
  .TARGET_WLAST       ( TARGET23_WLAST ),
  .TARGET_WUSER       ( TARGET23_WUSER ),
  .TARGET_WVALID      ( TARGET23_WVALID ),
  .TARGET_WREADY      ( TARGET23_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET23_BID ),
  .TARGET_BRESP       ( TARGET23_BRESP ),
  .TARGET_BUSER       ( TARGET23_BUSER ),
  .TARGET_BVALID      ( TARGET23_BVALID ),
  .TARGET_BREADY      ( TARGET23_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[23] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 24 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET24_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt24 (
  .sysClk            (T_CLK[24]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET24_ARID ),
  .TARGET_ARADDR      ( TARGET24_ARADDR ),
  .TARGET_ARLEN       ( TARGET24_ARLEN ),
  .TARGET_ARSIZE      ( TARGET24_ARSIZE ),
  .TARGET_ARBURST     ( TARGET24_ARBURST ),
  .TARGET_ARLOCK      ( TARGET24_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET24_ARCACHE ),
  .TARGET_ARPROT      ( TARGET24_ARPROT ),
  .TARGET_ARREGION    ( TARGET24_ARREGION ),
  .TARGET_ARQOS       ( TARGET24_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET24_ARUSER ),
  .TARGET_ARVALID     ( TARGET24_ARVALID ),
  .TARGET_ARREADY     ( TARGET24_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET24_RID ),
  .TARGET_RDATA       ( TARGET24_RDATA ),
  .TARGET_RRESP       ( TARGET24_RRESP ),
  .TARGET_RLAST       ( TARGET24_RLAST ),
  .TARGET_RUSER       ( TARGET24_RUSER ),
  .TARGET_RVALID      ( TARGET24_RVALID ),
  .TARGET_RREADY      ( TARGET24_RREADY ),

  .TARGET_AWID        ( TARGET24_AWID ),
  .TARGET_AWADDR      ( TARGET24_AWADDR ),
  .TARGET_AWLEN       ( TARGET24_AWLEN ),
  .TARGET_AWSIZE      ( TARGET24_AWSIZE ),
  .TARGET_AWBURST     ( TARGET24_AWBURST ),
  .TARGET_AWLOCK      ( TARGET24_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET24_AWCACHE ),
  .TARGET_AWPROT      ( TARGET24_AWPROT ),
  .TARGET_AWREGION    ( TARGET24_AWREGION ),
  .TARGET_AWQOS       ( TARGET24_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET24_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET24_AWVALID ),
  .TARGET_AWREADY     ( TARGET24_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET24_WDATA ),
  .TARGET_WSTRB       ( TARGET24_WSTRB ),
  .TARGET_WLAST       ( TARGET24_WLAST ),
  .TARGET_WUSER       ( TARGET24_WUSER ),
  .TARGET_WVALID      ( TARGET24_WVALID ),
  .TARGET_WREADY      ( TARGET24_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET24_BID ),
  .TARGET_BRESP       ( TARGET24_BRESP ),
  .TARGET_BUSER       ( TARGET24_BUSER ),
  .TARGET_BVALID      ( TARGET24_BVALID ),
  .TARGET_BREADY      ( TARGET24_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[24] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 25 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET25_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt25 (
  .sysClk            (T_CLK[25]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET25_ARID ),
  .TARGET_ARADDR      ( TARGET25_ARADDR ),
  .TARGET_ARLEN       ( TARGET25_ARLEN ),
  .TARGET_ARSIZE      ( TARGET25_ARSIZE ),
  .TARGET_ARBURST     ( TARGET25_ARBURST ),
  .TARGET_ARLOCK      ( TARGET25_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET25_ARCACHE ),
  .TARGET_ARPROT      ( TARGET25_ARPROT ),
  .TARGET_ARREGION    ( TARGET25_ARREGION ),
  .TARGET_ARQOS       ( TARGET25_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET25_ARUSER ),
  .TARGET_ARVALID     ( TARGET25_ARVALID ),
  .TARGET_ARREADY     ( TARGET25_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET25_RID ),
  .TARGET_RDATA       ( TARGET25_RDATA ),
  .TARGET_RRESP       ( TARGET25_RRESP ),
  .TARGET_RLAST       ( TARGET25_RLAST ),
  .TARGET_RUSER       ( TARGET25_RUSER ),
  .TARGET_RVALID      ( TARGET25_RVALID ),
  .TARGET_RREADY      ( TARGET25_RREADY ),

  .TARGET_AWID        ( TARGET25_AWID ),
  .TARGET_AWADDR      ( TARGET25_AWADDR ),
  .TARGET_AWLEN       ( TARGET25_AWLEN ),
  .TARGET_AWSIZE      ( TARGET25_AWSIZE ),
  .TARGET_AWBURST     ( TARGET25_AWBURST ),
  .TARGET_AWLOCK      ( TARGET25_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET25_AWCACHE ),
  .TARGET_AWPROT      ( TARGET25_AWPROT ),
  .TARGET_AWREGION    ( TARGET25_AWREGION ),
  .TARGET_AWQOS       ( TARGET25_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET25_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET25_AWVALID ),
  .TARGET_AWREADY     ( TARGET25_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET25_WDATA ),
  .TARGET_WSTRB       ( TARGET25_WSTRB ),
  .TARGET_WLAST       ( TARGET25_WLAST ),
  .TARGET_WUSER       ( TARGET25_WUSER ),
  .TARGET_WVALID      ( TARGET25_WVALID ),
  .TARGET_WREADY      ( TARGET25_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET25_BID ),
  .TARGET_BRESP       ( TARGET25_BRESP ),
  .TARGET_BUSER       ( TARGET25_BUSER ),
  .TARGET_BVALID      ( TARGET25_BVALID ),
  .TARGET_BREADY      ( TARGET25_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[25] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 26 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET26_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt26 (
  .sysClk            (T_CLK[26]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET26_ARID ),
  .TARGET_ARADDR      ( TARGET26_ARADDR ),
  .TARGET_ARLEN       ( TARGET26_ARLEN ),
  .TARGET_ARSIZE      ( TARGET26_ARSIZE ),
  .TARGET_ARBURST     ( TARGET26_ARBURST ),
  .TARGET_ARLOCK      ( TARGET26_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET26_ARCACHE ),
  .TARGET_ARPROT      ( TARGET26_ARPROT ),
  .TARGET_ARREGION    ( TARGET26_ARREGION ),
  .TARGET_ARQOS       ( TARGET26_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET26_ARUSER ),
  .TARGET_ARVALID     ( TARGET26_ARVALID ),
  .TARGET_ARREADY     ( TARGET26_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET26_RID ),
  .TARGET_RDATA       ( TARGET26_RDATA ),
  .TARGET_RRESP       ( TARGET26_RRESP ),
  .TARGET_RLAST       ( TARGET26_RLAST ),
  .TARGET_RUSER       ( TARGET26_RUSER ),
  .TARGET_RVALID      ( TARGET26_RVALID ),
  .TARGET_RREADY      ( TARGET26_RREADY ),

  .TARGET_AWID        ( TARGET26_AWID ),
  .TARGET_AWADDR      ( TARGET26_AWADDR ),
  .TARGET_AWLEN       ( TARGET26_AWLEN ),
  .TARGET_AWSIZE      ( TARGET26_AWSIZE ),
  .TARGET_AWBURST     ( TARGET26_AWBURST ),
  .TARGET_AWLOCK      ( TARGET26_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET26_AWCACHE ),
  .TARGET_AWPROT      ( TARGET26_AWPROT ),
  .TARGET_AWREGION    ( TARGET26_AWREGION ),
  .TARGET_AWQOS       ( TARGET26_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET26_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET26_AWVALID ),
  .TARGET_AWREADY     ( TARGET26_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET26_WDATA ),
  .TARGET_WSTRB       ( TARGET26_WSTRB ),
  .TARGET_WLAST       ( TARGET26_WLAST ),
  .TARGET_WUSER       ( TARGET26_WUSER ),
  .TARGET_WVALID      ( TARGET26_WVALID ),
  .TARGET_WREADY      ( TARGET26_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET26_BID ),
  .TARGET_BRESP       ( TARGET26_BRESP ),
  .TARGET_BUSER       ( TARGET26_BUSER ),
  .TARGET_BVALID      ( TARGET26_BVALID ),
  .TARGET_BREADY      ( TARGET26_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[26] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);


 Axi4TargetGen # (

    .TARGET_NUM              ( 27 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET27_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt27 (
  .sysClk            (T_CLK[27]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET27_ARID ),
  .TARGET_ARADDR      ( TARGET27_ARADDR ),
  .TARGET_ARLEN       ( TARGET27_ARLEN ),
  .TARGET_ARSIZE      ( TARGET27_ARSIZE ),
  .TARGET_ARBURST     ( TARGET27_ARBURST ),
  .TARGET_ARLOCK      ( TARGET27_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET27_ARCACHE ),
  .TARGET_ARPROT      ( TARGET27_ARPROT ),
  .TARGET_ARREGION    ( TARGET27_ARREGION ),
  .TARGET_ARQOS       ( TARGET27_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET27_ARUSER ),
  .TARGET_ARVALID     ( TARGET27_ARVALID ),
  .TARGET_ARREADY     ( TARGET27_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET27_RID ),
  .TARGET_RDATA       ( TARGET27_RDATA ),
  .TARGET_RRESP       ( TARGET27_RRESP ),
  .TARGET_RLAST       ( TARGET27_RLAST ),
  .TARGET_RUSER       ( TARGET27_RUSER ),
  .TARGET_RVALID      ( TARGET27_RVALID ),
  .TARGET_RREADY      ( TARGET27_RREADY ),

  .TARGET_AWID        ( TARGET27_AWID ),
  .TARGET_AWADDR      ( TARGET27_AWADDR ),
  .TARGET_AWLEN       ( TARGET27_AWLEN ),
  .TARGET_AWSIZE      ( TARGET27_AWSIZE ),
  .TARGET_AWBURST     ( TARGET27_AWBURST ),
  .TARGET_AWLOCK      ( TARGET27_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET27_AWCACHE ),
  .TARGET_AWPROT      ( TARGET27_AWPROT ),
  .TARGET_AWREGION    ( TARGET27_AWREGION ),
  .TARGET_AWQOS       ( TARGET27_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET27_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET27_AWVALID ),
  .TARGET_AWREADY     ( TARGET27_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET27_WDATA ),
  .TARGET_WSTRB       ( TARGET27_WSTRB ),
  .TARGET_WLAST       ( TARGET27_WLAST ),
  .TARGET_WUSER       ( TARGET27_WUSER ),
  .TARGET_WVALID      ( TARGET27_WVALID ),
  .TARGET_WREADY      ( TARGET27_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET27_BID ),
  .TARGET_BRESP       ( TARGET27_BRESP ),
  .TARGET_BUSER       ( TARGET27_BUSER ),
  .TARGET_BVALID      ( TARGET27_BVALID ),
  .TARGET_BREADY      ( TARGET27_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[27] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 28 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET28_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt28 (
  .sysClk            (T_CLK[28]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET28_ARID ),
  .TARGET_ARADDR      ( TARGET28_ARADDR ),
  .TARGET_ARLEN       ( TARGET28_ARLEN ),
  .TARGET_ARSIZE      ( TARGET28_ARSIZE ),
  .TARGET_ARBURST     ( TARGET28_ARBURST ),
  .TARGET_ARLOCK      ( TARGET28_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET28_ARCACHE ),
  .TARGET_ARPROT      ( TARGET28_ARPROT ),
  .TARGET_ARREGION    ( TARGET28_ARREGION ),
  .TARGET_ARQOS       ( TARGET28_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET28_ARUSER ),
  .TARGET_ARVALID     ( TARGET28_ARVALID ),
  .TARGET_ARREADY     ( TARGET28_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET28_RID ),
  .TARGET_RDATA       ( TARGET28_RDATA ),
  .TARGET_RRESP       ( TARGET28_RRESP ),
  .TARGET_RLAST       ( TARGET28_RLAST ),
  .TARGET_RUSER       ( TARGET28_RUSER ),
  .TARGET_RVALID      ( TARGET28_RVALID ),
  .TARGET_RREADY      ( TARGET28_RREADY ),

  .TARGET_AWID        ( TARGET28_AWID ),
  .TARGET_AWADDR      ( TARGET28_AWADDR ),
  .TARGET_AWLEN       ( TARGET28_AWLEN ),
  .TARGET_AWSIZE      ( TARGET28_AWSIZE ),
  .TARGET_AWBURST     ( TARGET28_AWBURST ),
  .TARGET_AWLOCK      ( TARGET28_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET28_AWCACHE ),
  .TARGET_AWPROT      ( TARGET28_AWPROT ),
  .TARGET_AWREGION    ( TARGET28_AWREGION ),
  .TARGET_AWQOS       ( TARGET28_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET28_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET28_AWVALID ),
  .TARGET_AWREADY     ( TARGET28_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET28_WDATA ),
  .TARGET_WSTRB       ( TARGET28_WSTRB ),
  .TARGET_WLAST       ( TARGET28_WLAST ),
  .TARGET_WUSER       ( TARGET28_WUSER ),
  .TARGET_WVALID      ( TARGET28_WVALID ),
  .TARGET_WREADY      ( TARGET28_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET28_BID ),
  .TARGET_BRESP       ( TARGET28_BRESP ),
  .TARGET_BUSER       ( TARGET28_BUSER ),
  .TARGET_BVALID      ( TARGET28_BVALID ),
  .TARGET_BREADY      ( TARGET28_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[28] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 29 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET29_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt29 (
  .sysClk            (T_CLK[29]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET29_ARID ),
  .TARGET_ARADDR      ( TARGET29_ARADDR ),
  .TARGET_ARLEN       ( TARGET29_ARLEN ),
  .TARGET_ARSIZE      ( TARGET29_ARSIZE ),
  .TARGET_ARBURST     ( TARGET29_ARBURST ),
  .TARGET_ARLOCK      ( TARGET29_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET29_ARCACHE ),
  .TARGET_ARPROT      ( TARGET29_ARPROT ),
  .TARGET_ARREGION    ( TARGET29_ARREGION ),
  .TARGET_ARQOS       ( TARGET29_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET29_ARUSER ),
  .TARGET_ARVALID     ( TARGET29_ARVALID ),
  .TARGET_ARREADY     ( TARGET29_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET29_RID ),
  .TARGET_RDATA       ( TARGET29_RDATA ),
  .TARGET_RRESP       ( TARGET29_RRESP ),
  .TARGET_RLAST       ( TARGET29_RLAST ),
  .TARGET_RUSER       ( TARGET29_RUSER ),
  .TARGET_RVALID      ( TARGET29_RVALID ),
  .TARGET_RREADY      ( TARGET29_RREADY ),

  .TARGET_AWID        ( TARGET29_AWID ),
  .TARGET_AWADDR      ( TARGET29_AWADDR ),
  .TARGET_AWLEN       ( TARGET29_AWLEN ),
  .TARGET_AWSIZE      ( TARGET29_AWSIZE ),
  .TARGET_AWBURST     ( TARGET29_AWBURST ),
  .TARGET_AWLOCK      ( TARGET29_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET29_AWCACHE ),
  .TARGET_AWPROT      ( TARGET29_AWPROT ),
  .TARGET_AWREGION    ( TARGET29_AWREGION ),
  .TARGET_AWQOS       ( TARGET29_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET29_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET29_AWVALID ),
  .TARGET_AWREADY     ( TARGET29_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET29_WDATA ),
  .TARGET_WSTRB       ( TARGET29_WSTRB ),
  .TARGET_WLAST       ( TARGET29_WLAST ),
  .TARGET_WUSER       ( TARGET29_WUSER ),
  .TARGET_WVALID      ( TARGET29_WVALID ),
  .TARGET_WREADY      ( TARGET29_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET29_BID ),
  .TARGET_BRESP       ( TARGET29_BRESP ),
  .TARGET_BUSER       ( TARGET29_BUSER ),
  .TARGET_BVALID      ( TARGET29_BVALID ),
  .TARGET_BREADY      ( TARGET29_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[29] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

 Axi4TargetGen # (

    .TARGET_NUM              ( 30 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET8_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt30 (
  .sysClk            (T_CLK[30]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET30_ARID ),
  .TARGET_ARADDR      ( TARGET30_ARADDR ),
  .TARGET_ARLEN       ( TARGET30_ARLEN ),
  .TARGET_ARSIZE      ( TARGET30_ARSIZE ),
  .TARGET_ARBURST     ( TARGET30_ARBURST ),
  .TARGET_ARLOCK      ( TARGET30_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET30_ARCACHE ),
  .TARGET_ARPROT      ( TARGET30_ARPROT ),
  .TARGET_ARREGION    ( TARGET30_ARREGION ),
  .TARGET_ARQOS       ( TARGET30_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET30_ARUSER ),
  .TARGET_ARVALID     ( TARGET30_ARVALID ),
  .TARGET_ARREADY     ( TARGET30_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET30_RID ),
  .TARGET_RDATA       ( TARGET30_RDATA ),
  .TARGET_RRESP       ( TARGET30_RRESP ),
  .TARGET_RLAST       ( TARGET30_RLAST ),
  .TARGET_RUSER       ( TARGET30_RUSER ),
  .TARGET_RVALID      ( TARGET30_RVALID ),
  .TARGET_RREADY      ( TARGET30_RREADY ),

  .TARGET_AWID        ( TARGET30_AWID ),
  .TARGET_AWADDR      ( TARGET30_AWADDR ),
  .TARGET_AWLEN       ( TARGET30_AWLEN ),
  .TARGET_AWSIZE      ( TARGET30_AWSIZE ),
  .TARGET_AWBURST     ( TARGET30_AWBURST ),
  .TARGET_AWLOCK      ( TARGET30_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET30_AWCACHE ),
  .TARGET_AWPROT      ( TARGET30_AWPROT ),
  .TARGET_AWREGION    ( TARGET30_AWREGION ),
  .TARGET_AWQOS       ( TARGET30_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET30_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET30_AWVALID ),
  .TARGET_AWREADY     ( TARGET30_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET30_WDATA ),
  .TARGET_WSTRB       ( TARGET30_WSTRB ),
  .TARGET_WLAST       ( TARGET30_WLAST ),
  .TARGET_WUSER       ( TARGET30_WUSER ),
  .TARGET_WVALID      ( TARGET30_WVALID ),
  .TARGET_WREADY      ( TARGET30_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET30_BID ),
  .TARGET_BRESP       ( TARGET30_BRESP ),
  .TARGET_BUSER       ( TARGET30_BUSER ),
  .TARGET_BVALID      ( TARGET30_BVALID ),
  .TARGET_BREADY      ( TARGET30_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[30] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);


 Axi4TargetGen # (

    .TARGET_NUM              ( 31 ),                 // defines target port number
    .ID_WIDTH               ( INITIATORID_WIDTH ), 
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .DATA_WIDTH             ( TARGET31_DATA_WIDTH ),
    .SUPPORT_USER_SIGNALS   ( SUPPORT_USER_SIGNALS ),
    .USER_WIDTH             ( USER_WIDTH ),
    .LOWER_COMPARE_BIT       ( NUM_AXITARGET_BITS ),
    .OPENTRANS_MAX          ( OPEN_SLTRANS_MAX )
  ) trgt31 (
  .sysClk            (T_CLK[31]),
  .ARESETN           ( ARESETN ),      // active high reset synchronoise to RE AClk - asserted async.

  .TARGET_ARID        ( TARGET31_ARID ),
  .TARGET_ARADDR      ( TARGET31_ARADDR ),
  .TARGET_ARLEN       ( TARGET31_ARLEN ),
  .TARGET_ARSIZE      ( TARGET31_ARSIZE ),
  .TARGET_ARBURST     ( TARGET31_ARBURST ),
  .TARGET_ARLOCK      ( TARGET31_ARLOCK ),
  .TARGET_ARCACHE     ( TARGET31_ARCACHE ),
  .TARGET_ARPROT      ( TARGET31_ARPROT ),
  .TARGET_ARREGION    ( TARGET31_ARREGION ),
  .TARGET_ARQOS       ( TARGET31_ARQOS ),    // not used
  .TARGET_ARUSER      ( TARGET31_ARUSER ),
  .TARGET_ARVALID     ( TARGET31_ARVALID ),
  .TARGET_ARREADY     ( TARGET31_ARREADY ),
  
  // Target Read Data Ports
  .TARGET_RID         ( TARGET31_RID ),
  .TARGET_RDATA       ( TARGET31_RDATA ),
  .TARGET_RRESP       ( TARGET31_RRESP ),
  .TARGET_RLAST       ( TARGET31_RLAST ),
  .TARGET_RUSER       ( TARGET31_RUSER ),
  .TARGET_RVALID      ( TARGET31_RVALID ),
  .TARGET_RREADY      ( TARGET31_RREADY ),

  .TARGET_AWID        ( TARGET31_AWID ),
  .TARGET_AWADDR      ( TARGET31_AWADDR ),
  .TARGET_AWLEN       ( TARGET31_AWLEN ),
  .TARGET_AWSIZE      ( TARGET31_AWSIZE ),
  .TARGET_AWBURST     ( TARGET31_AWBURST ),
  .TARGET_AWLOCK      ( TARGET31_AWLOCK ),
  .TARGET_AWCACHE     ( TARGET31_AWCACHE ),
  .TARGET_AWPROT      ( TARGET31_AWPROT ),
  .TARGET_AWREGION    ( TARGET31_AWREGION ),
  .TARGET_AWQOS       ( TARGET31_AWQOS ),        // not used internally
  .TARGET_AWUSER      ( TARGET31_AWUSER ),        // not used internally
  .TARGET_AWVALID     ( TARGET31_AWVALID ),
  .TARGET_AWREADY     ( TARGET31_AWREADY ),

  // Target Write Data Ports
  .TARGET_WDATA       ( TARGET31_WDATA ),
  .TARGET_WSTRB       ( TARGET31_WSTRB ),
  .TARGET_WLAST       ( TARGET31_WLAST ),
  .TARGET_WUSER       ( TARGET31_WUSER ),
  .TARGET_WVALID      ( TARGET31_WVALID ),
  .TARGET_WREADY      ( TARGET31_WREADY ),

  // Target Write Response Ports
  .TARGET_BID         ( TARGET31_BID ),
  .TARGET_BRESP       ( TARGET31_BRESP ),
  .TARGET_BUSER       ( TARGET31_BUSER ),
  .TARGET_BVALID      ( TARGET31_BVALID ),
  .TARGET_BREADY      ( TARGET31_BREADY ),

  // ===============  Control Signals  =======================================================//
  .TARGET_ARREADY_Default ( TARGET_ARREADY_Default ),      // defines whether TARGET asserts ready or waits for ARVALID
  .TARGET_AWREADY_Default ( TARGET_AWREADY_Default ),      // defines whether TARGET asserts ready or waits for WVALID
  .TARGET_DATA_IDLE_EN    ( TARGET_DATA_IDLE_EN ),          // Enables idle cycles to be inserted in Data channels
  .TARGET_DATA_IDLE_CYCLES( TARGET_DATA_IDLE_CYCLES ),      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3
  .FORCE_ERROR           ( FORCE_ERROR[31] ),              // Forces error pn read/write RESP
  .ERROR_BYTE             ( ERROR_BYTE  )                // Byte to force error on - for READs
);

  //====================================================================================================================================
  // AXI4/AHB Initiator transactor models - one for each mirrored initiator interface
  //====================================================================================================================================
  // Generate for Initiator0
  generate // initiator0
  if (NUM_INITIATORS > 0) begin
  if (INITIATOR0_TYPE != 2'b10)
  begin
    AxiInitiator #

          (
            .INITIATOR_NUM          ( 0 ),    // initiator number
            .INITIATOR_TYPE         ( INITIATOR_TYPE[1:0] ),
            .ID_WIDTH            ( ID_WIDTH ),
            .ADDR_WIDTH          ( ADDR_WIDTH ),
            .DATA_WIDTH          ( INITIATOR0_DATA_WIDTH ), 
            .SUPPORT_USER_SIGNALS( SUPPORT_USER_SIGNALS ),
            .USER_WIDTH          ( USER_WIDTH ),
            .OPENTRANS_MAX       ( OPEN_MTTRANS_MAX )  // Number of open transations width - 1 => 2 transations, 2 => 4 transations, etc.
          )
        initiator0  (
            // Global Signals
            .sysClk                 ( I_CLK[0] ),
            .ARESETN                ( ARESETN ),
            // Initiator Read Address Ports
            .INITIATOR_ARID            ( INITIATOR0_ARID ),
            .INITIATOR_ARADDR          ( INITIATOR0_ARADDR ),
            .INITIATOR_ARLEN            ( INITIATOR0_ARLEN ),
            .INITIATOR_ARSIZE          ( INITIATOR0_ARSIZE ),
            .INITIATOR_ARBURST          ( INITIATOR0_ARBURST ),
            .INITIATOR_ARLOCK          ( INITIATOR0_ARLOCK ),
            .INITIATOR_ARCACHE          ( INITIATOR0_ARCACHE ),
            .INITIATOR_ARPROT          ( INITIATOR0_ARPROT ),
            .INITIATOR_ARREGION        ( INITIATOR0_ARREGION ),    // not used
            .INITIATOR_ARQOS            ( INITIATOR0_ARQOS ),      // not used
            .INITIATOR_ARUSER          ( INITIATOR0_ARUSER ),
            .INITIATOR_ARVALID          ( INITIATOR0_ARVALID ),
            .INITIATOR_ARREADY          ( INITIATOR0_ARREADY ),

            // Initiator Read Data Ports
            .INITIATOR_RID              ( INITIATOR0_RID ),
            .INITIATOR_RDATA            ( INITIATOR0_RDATA ),
            .INITIATOR_RRESP            ( INITIATOR0_RRESP ),
            .INITIATOR_RLAST            ( INITIATOR0_RLAST ),
            .INITIATOR_RUSER            ( INITIATOR0_RUSER ),
            .INITIATOR_RVALID          ( INITIATOR0_RVALID ),
            .INITIATOR_RREADY          ( INITIATOR0_RREADY ),

            // Initiator Write Address Ports
            .INITIATOR_AWID            ( INITIATOR0_AWID ),
            .INITIATOR_AWADDR          ( INITIATOR0_AWADDR ),
            .INITIATOR_AWLEN            ( INITIATOR0_AWLEN ),
            .INITIATOR_AWSIZE          ( INITIATOR0_AWSIZE ),
            .INITIATOR_AWBURST          ( INITIATOR0_AWBURST ),
            .INITIATOR_AWLOCK          ( INITIATOR0_AWLOCK ),
            .INITIATOR_AWCACHE          ( INITIATOR0_AWCACHE ),
            .INITIATOR_AWPROT          ( INITIATOR0_AWPROT ),
            .INITIATOR_AWREGION        ( INITIATOR0_AWREGION ),    // not used
            .INITIATOR_AWQOS            ( INITIATOR0_AWQOS ),      // not used
            .INITIATOR_AWUSER          ( INITIATOR0_AWUSER ),
            .INITIATOR_AWVALID          ( INITIATOR0_AWVALID ),
            .INITIATOR_AWREADY          ( INITIATOR0_AWREADY ),

            // Initiator Write Data Ports
            .INITIATOR_WID              ( INITIATOR0_WID ),
            .INITIATOR_WDATA            ( INITIATOR0_WDATA ),
            .INITIATOR_WSTRB            ( INITIATOR0_WSTRB ),
            .INITIATOR_WLAST            ( INITIATOR0_WLAST ),
            .INITIATOR_WUSER            ( INITIATOR0_WUSER ),
            .INITIATOR_WVALID          ( INITIATOR0_WVALID ),
            .INITIATOR_WREADY          ( INITIATOR0_WREADY ),

            // Initiator Write Response Ports
            .INITIATOR_BID              ( INITIATOR0_BID ),
            .INITIATOR_BRESP            ( INITIATOR0_BRESP ),
            .INITIATOR_BUSER            ( INITIATOR0_BUSER ),
            .INITIATOR_BVALID          ( INITIATOR0_BVALID ),
            .INITIATOR_BREADY          ( INITIATOR0_BREADY ),

            // ===============  Control Signals  =======================================================//
            .INITIATOR_RREADY_Default  ( INITIATOR_RREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
            .INITIATOR_WREADY_Default  ( INITIATOR_WREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
            .d_INITIATOR_BREADY_default( d_INITIATOR_BREADY_default ),  // defines whether Initiator asserts ready or waits for RVALID
            .rdStart                ( rdStart[0] ),          // defines whether Initiator starts a transaction
            .rdBurstLen              ( rdBurstLen ),          // burst length of read transaction
            .rdStartAddr            ( rdStartAddr ),        // start addresss for read transaction
            .rdAID                  ( rdAID ),            // AID for read transactions
            .initiatorRdAddrDone        ( initiatorRdAddrDone[0] ),    // Asserted when a read transaction has been completed
            .initiatorRdDone            ( initiatorRdDone[0] ),      // Asserted when a read transaction has been completed
            .initiatorRdStatus          ( initiatorRdStatus[0] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
            .initiatorRAddrIdle            ( initiatorRAddrIdle[0] ),
            .rdASize                ( rdASize[0] ),          // read size for each transfer in burst
            .expRResp                ( expRResp[0] ),        // indicate Read Respons expected
            .expWResp                ( expWResp[0] ),        // indicate Write Respons expected
            .wrASize                 ( wrASize[0] ),          // write size for each transfer in burst
            .wrStart                ( wrStart[0] ),          // defines whether Initiator starts a transaction
            .BurstType              ( BurstType ),          // Type of burst - FIXED=00, INCR=01, WRAP=10 
            .wrBurstLen             ( wrBurstLen ),          // burst length of write transaction
            .wrStartAddr            ( wrStartAddr ),        // start addresss for write transaction
            .wrAID                  ( wrAID ),            // AID for write transactions

            .initiatorWrAddrDone        ( initiatorWrAddrDone[0] ),    // Address Write transaction has been completed
            .initiatorWrDone           ( initiatorWrDone[0] ),      // Asserted when a write transaction has been completed
            .initiatorWrStatus         ( initiatorWrStatus[0] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
            .initiatorWAddrIdle           ( initiatorWAddrIdle[0] ),      // indicates Read Address Bus is idle
            .initiatorRespDone          ( initiatorRespDone[0] ),      // Asserted when a write response transaction has completed
            .initiatorWrAddrFull          ( initiatorWrAddrFull[0]  ),      // Asserted when the internal queue for writes are full
            .initiatorRdAddrFull          ( initiatorRdAddrFull[0]  )      // Asserted when the internal queue for reads are full
      );
    end
    else if (INITIATOR0_TYPE == 2'b10)
    begin
      assign INITIATOR0_AWVALID  = 1'b0;

      assign INITIATOR0_AWID      = 0;
      assign INITIATOR0_AWADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR0_AWLEN    = 0;
      assign INITIATOR0_AWSIZE   = 0;
      assign INITIATOR0_AWBURST  = 0;
      assign INITIATOR0_AWLOCK   = 0;
      assign INITIATOR0_AWCACHE  = 0;
      assign INITIATOR0_AWPROT   = 0;
      assign INITIATOR0_AWREGION  = 0;
      assign INITIATOR0_AWQOS    = 0;    // not used
      assign INITIATOR0_AWUSER   = 0;

      assign INITIATOR0_WVALID  = 0;
      assign INITIATOR0_WDATA  = 0;
      assign INITIATOR0_WSTRB  = 0;
      assign INITIATOR0_WUSER  = 0;
      assign INITIATOR0_WLAST  = 0;

      assign INITIATOR0_ARVALID  = 1'b0;

      assign INITIATOR0_ARID      = 0;
      assign INITIATOR0_ARADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR0_ARLEN    = 0;
      assign INITIATOR0_ARSIZE   = 0;
      assign INITIATOR0_ARBURST  = 0;
      assign INITIATOR0_ARLOCK   = 0;
      assign INITIATOR0_ARCACHE  = 0;
      assign INITIATOR0_ARPROT   = 0;
      assign INITIATOR0_ARREGION  = 0;
      assign INITIATOR0_ARQOS    = 0;    // not used
      assign INITIATOR0_ARUSER   = 0;

      assign INITIATOR0_RREADY = 1'b0;


      AHBL_Initiator #(
          .AHB_AWIDTH        (AHB_AWIDTH),
          .AHB_DWIDTH        (INITIATOR0_DATA_WIDTH),
          .UNDEF_BURST      (UNDEF_BURST_INITIATOR0)
           )
      initiator0 (
        // AHB Interface
        // Global Signal
         .HCLK          (I_CLK[0]),

         .HRESETn        (ARESETN),
         .HSEL          (INITIATOR0_HSEL),
         .HADDR          (INITIATOR0_HADDR),
         .HWRITE        (INITIATOR0_HWRITE),
         .HREADY        (INITIATOR0_HREADY),
         .HTRANS        (INITIATOR0_HTRANS),
         .HSIZE          (INITIATOR0_HSIZE),
         .HWDATA        (INITIATOR0_HWDATA),
         .HBURST        (INITIATOR0_HBURST),
         .HMASTLOCK      (INITIATOR0_HMASTLOCK),
         .HRESP          (INITIATOR0_HRESP),
         .HRDATA        (INITIATOR0_HRDATA),

         .HNONSEC        (INITIATOR0_HNONSEC),
         .HPROT          (INITIATOR0_HPROT),

         .start_tx      (start_tx[0]),
         .end_tx        (end_tx[0]),
         .hburst_tx      (hburst),
         .hsize_tx      (hsize),
         .haddr_tx      (haddr),
         .hwrite_tx      (hwrite)
         );
    end
    end
    endgenerate // initiator0

  // Generate for Initiator1
  generate // initiator1
  if (NUM_INITIATORS > 1) begin
  if (INITIATOR1_TYPE != 2'b10)
  begin
    AxiInitiator #
        (
          .INITIATOR_NUM          ( 1 ),    // initiator number
          .INITIATOR_TYPE         ( INITIATOR_TYPE[3:2] ),
          .ID_WIDTH            ( ID_WIDTH ),

          .ADDR_WIDTH          ( ADDR_WIDTH ),
          .DATA_WIDTH          ( INITIATOR1_DATA_WIDTH), 
          .SUPPORT_USER_SIGNALS( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH          ( USER_WIDTH ),
          .OPENTRANS_MAX       ( OPEN_MTTRANS_MAX )  // Number of open transations width - 1 => 2 transations, 2 => 4 transations, etc.
        )
      initiator1  (
          // Global Signals
          .sysClk                 ( I_CLK[1] ),
          .ARESETN                ( ARESETN ),

          // Initiator Read Address Ports
          .INITIATOR_ARID            ( INITIATOR1_ARID ),
          .INITIATOR_ARADDR          ( INITIATOR1_ARADDR ),
          .INITIATOR_ARLEN            ( INITIATOR1_ARLEN ),
          .INITIATOR_ARSIZE          ( INITIATOR1_ARSIZE ),
          .INITIATOR_ARBURST          ( INITIATOR1_ARBURST ),
          .INITIATOR_ARLOCK          ( INITIATOR1_ARLOCK ),
          .INITIATOR_ARCACHE          ( INITIATOR1_ARCACHE ),
          .INITIATOR_ARPROT          ( INITIATOR1_ARPROT ),
          .INITIATOR_ARREGION        ( INITIATOR1_ARREGION ),    // not used
          .INITIATOR_ARQOS            ( INITIATOR1_ARQOS ),      // not used
          .INITIATOR_ARUSER          ( INITIATOR1_ARUSER ),
          .INITIATOR_ARVALID          ( INITIATOR1_ARVALID ),
          .INITIATOR_ARREADY          ( INITIATOR1_ARREADY ),

          // Initiator Read Data Ports
          .INITIATOR_RID              ( INITIATOR1_RID ),
          .INITIATOR_RDATA            ( INITIATOR1_RDATA ),
          .INITIATOR_RRESP            ( INITIATOR1_RRESP ),
          .INITIATOR_RLAST            ( INITIATOR1_RLAST ),
          .INITIATOR_RUSER            ( INITIATOR1_RUSER ),
          .INITIATOR_RVALID          ( INITIATOR1_RVALID ),
          .INITIATOR_RREADY          ( INITIATOR1_RREADY ),

          // Initiator Write Address Ports
          .INITIATOR_AWID            ( INITIATOR1_AWID ),
          .INITIATOR_AWADDR          ( INITIATOR1_AWADDR ),
          .INITIATOR_AWLEN            ( INITIATOR1_AWLEN ),
          .INITIATOR_AWSIZE          ( INITIATOR1_AWSIZE ),
          .INITIATOR_AWBURST          ( INITIATOR1_AWBURST ),
          .INITIATOR_AWLOCK          ( INITIATOR1_AWLOCK ),
          .INITIATOR_AWCACHE          ( INITIATOR1_AWCACHE ),
          .INITIATOR_AWPROT          ( INITIATOR1_AWPROT ),
          .INITIATOR_AWREGION        ( INITIATOR1_AWREGION ),    // not used
          .INITIATOR_AWQOS            ( INITIATOR1_AWQOS ),        // not used
          .INITIATOR_AWUSER          ( INITIATOR1_AWUSER ),
          .INITIATOR_AWVALID          ( INITIATOR1_AWVALID ),
          .INITIATOR_AWREADY          ( INITIATOR1_AWREADY ),

          // Initiator Write Data Ports
          .INITIATOR_WID              ( INITIATOR1_WID ),
          .INITIATOR_WDATA            ( INITIATOR1_WDATA ),
          .INITIATOR_WSTRB            ( INITIATOR1_WSTRB ),
          .INITIATOR_WLAST            ( INITIATOR1_WLAST ),
          .INITIATOR_WUSER            ( INITIATOR1_WUSER ),
          .INITIATOR_WVALID          ( INITIATOR1_WVALID ),
          .INITIATOR_WREADY          ( INITIATOR1_WREADY ),

          // Initiator Write Response Ports
          .INITIATOR_BID              ( INITIATOR1_BID ),
          .INITIATOR_BRESP            ( INITIATOR1_BRESP ),
          .INITIATOR_BUSER            ( INITIATOR1_BUSER ),
          .INITIATOR_BVALID          ( INITIATOR1_BVALID ),
          .INITIATOR_BREADY          ( INITIATOR1_BREADY ),

          // ===============  Control Signals  =======================================================//
          .INITIATOR_RREADY_Default  ( INITIATOR_RREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .INITIATOR_WREADY_Default  ( INITIATOR_WREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .d_INITIATOR_BREADY_default( d_INITIATOR_BREADY_default ),  // defines whether Initiator asserts ready or waits for RVALID
          .rdStart                ( rdStart[1] ),          // defines whether Initiator starts a transaction
          .rdBurstLen              ( rdBurstLen ),          // burst length of read transaction
          .rdStartAddr            ( rdStartAddr ),        // start addresss for read transaction
          .rdAID                  ( rdAID ),            // AID for read transactions
          .initiatorRdAddrDone        ( initiatorRdAddrDone[1] ),    // Asserted when a read transaction has been completed
          .initiatorRdDone            ( initiatorRdDone[1] ),      // Asserted when a read transaction has been completed
          .initiatorRdStatus          ( initiatorRdStatus[1] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorRAddrIdle            ( initiatorRAddrIdle[1] ),
          .rdASize                ( rdASize[1] ),          // read size for each transfer in burst
          .expRResp                ( expRResp[1] ),        // indicate Read Respons expected
          .expWResp                ( expWResp[1] ),        // indicate Write Respons expected
          .wrASize                 ( wrASize[1] ),          // write size for each transfer in burst
          .wrStart                ( wrStart[1] ),          // defines whether Initiator starts a transaction
          .BurstType              ( BurstType ),          // Type of burst - FIXED=00, INCR=01, WRAP=10 
          .wrBurstLen             ( wrBurstLen ),          // burst length of write transaction
          .wrStartAddr            ( wrStartAddr ),        // start addresss for write transaction
          .wrAID                  ( wrAID ),            // AID for write transactions

          .initiatorWrAddrDone        ( initiatorWrAddrDone[1] ),    // Address Write transaction has been completed
          .initiatorWrDone           ( initiatorWrDone[1] ),      // Asserted when a write transaction has been completed
          .initiatorWrStatus         ( initiatorWrStatus[1] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorWAddrIdle           ( initiatorWAddrIdle[1] ),      // indicates Read Address Bus is idle
          .initiatorRespDone          ( initiatorRespDone[1] ),      // Asserted when a write response transaction has completed
          .initiatorWrAddrFull          ( initiatorWrAddrFull[1]  ),      // Asserted when the internal queue for writes are full
          .initiatorRdAddrFull          ( initiatorRdAddrFull[1]  )      // Asserted when the internal queue for reads are full
    );
    end
    else if (INITIATOR1_TYPE == 2'b10)
    begin
      assign INITIATOR1_AWVALID  = 1'b0;

      assign INITIATOR1_AWID      = 0;
      assign INITIATOR1_AWADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR1_AWLEN    = 0;
      assign INITIATOR1_AWSIZE   = 0;
      assign INITIATOR1_AWBURST  = 0;
      assign INITIATOR1_AWLOCK   = 0;
      assign INITIATOR1_AWCACHE  = 0;
      assign INITIATOR1_AWPROT   = 0;
      assign INITIATOR1_AWREGION  = 0;
      assign INITIATOR1_AWQOS    = 0;    // not used
      assign INITIATOR1_AWUSER   = 0;

      assign INITIATOR1_WVALID  = 0;
      assign INITIATOR1_WDATA  = 0;
      assign INITIATOR1_WSTRB  = 0;
      assign INITIATOR1_WUSER  = 0;
      assign INITIATOR1_WLAST  = 0;

      assign INITIATOR1_ARVALID  = 1'b0;

      assign INITIATOR1_ARID      = 0;
      assign INITIATOR1_ARADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR1_ARLEN    = 0;
      assign INITIATOR1_ARSIZE   = 0;
      assign INITIATOR1_ARBURST  = 0;
      assign INITIATOR1_ARLOCK   = 0;
      assign INITIATOR1_ARCACHE  = 0;
      assign INITIATOR1_ARPROT   = 0;
      assign INITIATOR1_ARREGION  = 0;
      assign INITIATOR1_ARQOS    = 0;    // not used
      assign INITIATOR1_ARUSER   = 0;

      assign INITIATOR1_RREADY = 1'b0;

      AHBL_Initiator #(
          .AHB_AWIDTH      (AHB_AWIDTH),
          .AHB_DWIDTH      (INITIATOR1_DATA_WIDTH),
          .UNDEF_BURST      (UNDEF_BURST_INITIATOR1)
           )
      initiator1 (
        // AHB Interface
        // Global Signal
         .HCLK          (I_CLK[1]),

         .HRESETn        (ARESETN),
         .HSEL          (INITIATOR1_HSEL),
         .HADDR          (INITIATOR1_HADDR),
         .HWRITE        (INITIATOR1_HWRITE),
         .HREADY        (INITIATOR1_HREADY),
         .HTRANS        (INITIATOR1_HTRANS),
         .HSIZE          (INITIATOR1_HSIZE),
         .HWDATA        (INITIATOR1_HWDATA),
         .HBURST        (INITIATOR1_HBURST),
         .HMASTLOCK      (INITIATOR1_HMASTLOCK),
         .HRESP          (INITIATOR1_HRESP),
         .HRDATA        (INITIATOR1_HRDATA),

         .HNONSEC        (INITIATOR1_HNONSEC),
         .HPROT          (INITIATOR1_HPROT),

         .start_tx      (start_tx[1]),
         .end_tx        (end_tx[1]),
         .hburst_tx      (hburst),
         .hsize_tx      (hsize),
         .haddr_tx      (haddr),
         .hwrite_tx      (hwrite)
         );
    end
    end
    endgenerate // initiator1

  // Generate for Initiator2
  generate // initiator2
  if (NUM_INITIATORS > 2) begin
  if (INITIATOR2_TYPE != 2'b10)
  begin
    AxiInitiator # 
        (
          .INITIATOR_NUM          ( 2 ),    // initiator number
          .INITIATOR_TYPE         ( INITIATOR_TYPE[5:4] ),
          .ID_WIDTH            ( ID_WIDTH ),

          .ADDR_WIDTH          ( ADDR_WIDTH ),
          .DATA_WIDTH          ( INITIATOR2_DATA_WIDTH ), 
          .SUPPORT_USER_SIGNALS( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH          ( USER_WIDTH ),
          .OPENTRANS_MAX       ( OPEN_MTTRANS_MAX )  // Number of open transations width - 1 => 2 transations, 2 => 4 transations, etc.
        )
      initiator2  (
          // Global Signals
          .sysClk                 ( I_CLK[2] ),
          .ARESETN                ( ARESETN ),

          // Initiator Read Address Ports
          .INITIATOR_ARID            ( INITIATOR2_ARID ),
          .INITIATOR_ARADDR          ( INITIATOR2_ARADDR ),
          .INITIATOR_ARLEN            ( INITIATOR2_ARLEN ),
          .INITIATOR_ARSIZE          ( INITIATOR2_ARSIZE ),
          .INITIATOR_ARBURST          ( INITIATOR2_ARBURST ),
          .INITIATOR_ARLOCK          ( INITIATOR2_ARLOCK ),
          .INITIATOR_ARCACHE          ( INITIATOR2_ARCACHE ),
          .INITIATOR_ARPROT          ( INITIATOR2_ARPROT ),
          .INITIATOR_ARREGION        ( INITIATOR2_ARREGION ),    // not used
          .INITIATOR_ARQOS            ( INITIATOR2_ARQOS ),      // not used
          .INITIATOR_ARUSER          ( INITIATOR2_ARUSER ),
          .INITIATOR_ARVALID          ( INITIATOR2_ARVALID ),
          .INITIATOR_ARREADY          ( INITIATOR2_ARREADY ),

          // Initiator Read Data Ports
          .INITIATOR_RID              ( INITIATOR2_RID ),
          .INITIATOR_RDATA            ( INITIATOR2_RDATA ),
          .INITIATOR_RRESP            ( INITIATOR2_RRESP ),
          .INITIATOR_RLAST            ( INITIATOR2_RLAST ),
          .INITIATOR_RUSER            ( INITIATOR2_RUSER ),
          .INITIATOR_RVALID          ( INITIATOR2_RVALID ),
          .INITIATOR_RREADY          ( INITIATOR2_RREADY ),

          // Initiator Write Address Ports
          .INITIATOR_AWID            ( INITIATOR2_AWID ),
          .INITIATOR_AWADDR          ( INITIATOR2_AWADDR ),
          .INITIATOR_AWLEN            ( INITIATOR2_AWLEN ),
          .INITIATOR_AWSIZE          ( INITIATOR2_AWSIZE ),
          .INITIATOR_AWBURST          ( INITIATOR2_AWBURST ),
          .INITIATOR_AWLOCK          ( INITIATOR2_AWLOCK ),
          .INITIATOR_AWCACHE          ( INITIATOR2_AWCACHE ),
          .INITIATOR_AWPROT          ( INITIATOR2_AWPROT ),
          .INITIATOR_AWREGION        ( INITIATOR2_AWREGION ),    // not used
          .INITIATOR_AWQOS            ( INITIATOR2_AWQOS ),      // not used
          .INITIATOR_AWUSER          ( INITIATOR2_AWUSER ),
          .INITIATOR_AWVALID          ( INITIATOR2_AWVALID ),
          .INITIATOR_AWREADY          ( INITIATOR2_AWREADY ),

          // Initiator Write Data Ports
          .INITIATOR_WID              ( INITIATOR2_WID ),
          .INITIATOR_WDATA            ( INITIATOR2_WDATA ),
          .INITIATOR_WSTRB            ( INITIATOR2_WSTRB ),
          .INITIATOR_WLAST            ( INITIATOR2_WLAST ),
          .INITIATOR_WUSER            ( INITIATOR2_WUSER ),
          .INITIATOR_WVALID          ( INITIATOR2_WVALID ),
          .INITIATOR_WREADY          ( INITIATOR2_WREADY ),
  
          // Initiator Write Response Ports
          .INITIATOR_BID              ( INITIATOR2_BID ),
          .INITIATOR_BRESP            ( INITIATOR2_BRESP ),
          .INITIATOR_BUSER            ( INITIATOR2_BUSER ),
          .INITIATOR_BVALID          ( INITIATOR2_BVALID ),
          .INITIATOR_BREADY          ( INITIATOR2_BREADY ),
   
          // ===============  Control Signals  =======================================================//
          .INITIATOR_RREADY_Default  ( INITIATOR_RREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .INITIATOR_WREADY_Default  ( INITIATOR_WREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .d_INITIATOR_BREADY_default( d_INITIATOR_BREADY_default ),  // defines whether Initiator asserts ready or waits for RVALID
          .rdStart                ( rdStart[2] ),          // defines whether Initiator starts a transaction
          .rdBurstLen              ( rdBurstLen ),          // burst length of read transaction
          .rdStartAddr            ( rdStartAddr ),        // start addresss for read transaction
          .rdAID                  ( rdAID ),            // AID for read transactions
          .initiatorRdAddrDone        ( initiatorRdAddrDone[2] ),    // Asserted when a read transaction has been completed
          .initiatorRdDone            ( initiatorRdDone[2] ),      // Asserted when a read transaction has been completed
          .initiatorRdStatus          ( initiatorRdStatus[2] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorRAddrIdle            ( initiatorRAddrIdle[2] ),
          .rdASize                ( rdASize[2] ),          // read size for each transfer in burst
          .expRResp                ( expRResp[2] ),        // indicate Read Respons expected
          .expWResp                ( expWResp[2] ),        // indicate Write Respons expected
          .wrASize                 ( wrASize[2] ),          // write size for each transfer in burst
          .wrStart                ( wrStart[2] ),          // defines whether Initiator starts a transaction
          .BurstType              ( BurstType ),          // Type of burst - FIXED=00, INCR=01, WRAP=10 
          .wrBurstLen             ( wrBurstLen ),          // burst length of write transaction
          .wrStartAddr            ( wrStartAddr ),        // start addresss for write transaction
          .wrAID                  ( wrAID ),            // AID for write transactions

          .initiatorWrAddrDone        ( initiatorWrAddrDone[2] ),    // Address Write transaction has been completed
          .initiatorWrDone           ( initiatorWrDone[2] ),      // Asserted when a write transaction has been completed
          .initiatorWrStatus         ( initiatorWrStatus[2] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorWAddrIdle           ( initiatorWAddrIdle[2] ),      // indicates Read Address Bus is idle
          .initiatorRespDone          ( initiatorRespDone[2] ),      // Asserted when a write response transaction has completed
          .initiatorWrAddrFull          ( initiatorWrAddrFull[2]  ),      // Asserted when the internal queue for writes are full
          .initiatorRdAddrFull          ( initiatorRdAddrFull[2]  )      // Asserted when the internal queue for reads are full

    );
    end
    else if (INITIATOR2_TYPE == 2'b10)
    begin
      assign INITIATOR2_AWVALID  = 1'b0;

      assign INITIATOR2_AWID      = 0;
      assign INITIATOR2_AWADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR2_AWLEN    = 0;
      assign INITIATOR2_AWSIZE   = 0;
      assign INITIATOR2_AWBURST  = 0;
      assign INITIATOR2_AWLOCK   = 0;
      assign INITIATOR2_AWCACHE  = 0;
      assign INITIATOR2_AWPROT   = 0;
      assign INITIATOR2_AWREGION  = 0;
      assign INITIATOR2_AWQOS    = 0;    // not used
      assign INITIATOR2_AWUSER   = 0;

      assign INITIATOR2_WVALID  = 0;
      assign INITIATOR2_WDATA  = 0;
      assign INITIATOR2_WSTRB  = 0;
      assign INITIATOR2_WUSER  = 0;
      assign INITIATOR2_WLAST  = 0;

      assign INITIATOR2_ARVALID  = 1'b0;

      assign INITIATOR2_ARID      = 0;
      assign INITIATOR2_ARADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR2_ARLEN    = 0;
      assign INITIATOR2_ARSIZE   = 0;
      assign INITIATOR2_ARBURST  = 0;
      assign INITIATOR2_ARLOCK   = 0;
      assign INITIATOR2_ARCACHE  = 0;
      assign INITIATOR2_ARPROT   = 0;
      assign INITIATOR2_ARREGION  = 0;
      assign INITIATOR2_ARQOS    = 0;    // not used
      assign INITIATOR2_ARUSER   = 0;

      assign INITIATOR2_RREADY = 1'b0;


      AHBL_Initiator #(
          .AHB_AWIDTH        (AHB_AWIDTH),
          .AHB_DWIDTH        (INITIATOR2_DATA_WIDTH),
          .UNDEF_BURST      (UNDEF_BURST_INITIATOR2)
           )
      initiator2              (
        // AHB Interface
        // Global Signal
         .HCLK          (I_CLK[2]),

         .HRESETn        (ARESETN),
         .HSEL          (INITIATOR2_HSEL),
         .HADDR          (INITIATOR2_HADDR),
         .HWRITE        (INITIATOR2_HWRITE),
         .HREADY        (INITIATOR2_HREADY),
         .HTRANS        (INITIATOR2_HTRANS),
         .HSIZE          (INITIATOR2_HSIZE),
         .HWDATA        (INITIATOR2_HWDATA),
         .HBURST        (INITIATOR2_HBURST),
         .HMASTLOCK      (INITIATOR2_HMASTLOCK),
         .HRESP          (INITIATOR2_HRESP),
         .HRDATA        (INITIATOR2_HRDATA),

         .HNONSEC        (INITIATOR2_HNONSEC),
         .HPROT          (INITIATOR2_HPROT),

         .start_tx      (start_tx[2]),
         .end_tx        (end_tx[2]),
         .hburst_tx      (hburst),
         .hsize_tx      (hsize),
         .haddr_tx      (haddr),
         .hwrite_tx      (hwrite)
         );
    end
    end
    endgenerate // initiator2

  // Generate for Initiator3
  generate // initiator3
  if (NUM_INITIATORS > 3) begin
  if (INITIATOR3_TYPE != 2'b10)
  begin
    AxiInitiator # 
        (
          .INITIATOR_NUM          ( 3 ),    // initiator number
          .INITIATOR_TYPE         ( INITIATOR_TYPE[7:6] ),
          .ID_WIDTH            ( ID_WIDTH ),

          .ADDR_WIDTH          ( ADDR_WIDTH ),
          .DATA_WIDTH          ( INITIATOR3_DATA_WIDTH ), 
          .SUPPORT_USER_SIGNALS( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH          ( USER_WIDTH ),
          .OPENTRANS_MAX       ( OPEN_MTTRANS_MAX )  // Number of open transations width - 1 => 2 transations, 2 => 4 transations, etc.
        )
      initiator3  (
          // Global Signals
          .sysClk                 ( I_CLK[3] ),
          .ARESETN                ( ARESETN ),

          // Initiator Read Address Ports
          .INITIATOR_ARID            ( INITIATOR3_ARID ),
          .INITIATOR_ARADDR          ( INITIATOR3_ARADDR ),
          .INITIATOR_ARLEN            ( INITIATOR3_ARLEN ),
          .INITIATOR_ARSIZE          ( INITIATOR3_ARSIZE ),
          .INITIATOR_ARBURST          ( INITIATOR3_ARBURST ),
          .INITIATOR_ARLOCK          ( INITIATOR3_ARLOCK ),
          .INITIATOR_ARCACHE          ( INITIATOR3_ARCACHE ),
          .INITIATOR_ARPROT          ( INITIATOR3_ARPROT ),
          .INITIATOR_ARREGION        ( INITIATOR3_ARREGION ),    // not used
          .INITIATOR_ARQOS            ( INITIATOR3_ARQOS ),      // not used
          .INITIATOR_ARUSER          ( INITIATOR3_ARUSER ),
          .INITIATOR_ARVALID          ( INITIATOR3_ARVALID ),
          .INITIATOR_ARREADY          ( INITIATOR3_ARREADY ),

          // Initiator Read Data Ports
          .INITIATOR_RID              ( INITIATOR3_RID ),
          .INITIATOR_RDATA            ( INITIATOR3_RDATA ),
          .INITIATOR_RRESP            ( INITIATOR3_RRESP ),
          .INITIATOR_RLAST            ( INITIATOR3_RLAST ),
          .INITIATOR_RUSER            ( INITIATOR3_RUSER ),
          .INITIATOR_RVALID          ( INITIATOR3_RVALID ),
          .INITIATOR_RREADY          ( INITIATOR3_RREADY ),

          // Initiator Write Address Ports
          .INITIATOR_AWID            ( INITIATOR3_AWID ),
          .INITIATOR_AWADDR          ( INITIATOR3_AWADDR ),
          .INITIATOR_AWLEN            ( INITIATOR3_AWLEN ),
          .INITIATOR_AWSIZE          ( INITIATOR3_AWSIZE ),
          .INITIATOR_AWBURST          ( INITIATOR3_AWBURST ),
          .INITIATOR_AWLOCK          ( INITIATOR3_AWLOCK ),
          .INITIATOR_AWCACHE          ( INITIATOR3_AWCACHE ),
          .INITIATOR_AWPROT          ( INITIATOR3_AWPROT ),
          .INITIATOR_AWREGION        ( INITIATOR3_AWREGION ),    // not used
          .INITIATOR_AWQOS            ( INITIATOR3_AWQOS ),      // not used
          .INITIATOR_AWUSER          ( INITIATOR3_AWUSER ),
          .INITIATOR_AWVALID          ( INITIATOR3_AWVALID ),
          .INITIATOR_AWREADY          ( INITIATOR3_AWREADY ),

          // Initiator Write Data Ports
          .INITIATOR_WID              ( INITIATOR3_WID ),
          .INITIATOR_WDATA            ( INITIATOR3_WDATA ),
          .INITIATOR_WSTRB            ( INITIATOR3_WSTRB ),
          .INITIATOR_WLAST            ( INITIATOR3_WLAST ),
          .INITIATOR_WUSER            ( INITIATOR3_WUSER ),
          .INITIATOR_WVALID          ( INITIATOR3_WVALID ),
          .INITIATOR_WREADY          ( INITIATOR3_WREADY ),

          // Initiator Write Response Ports
          .INITIATOR_BID              ( INITIATOR3_BID ),
          .INITIATOR_BRESP            ( INITIATOR3_BRESP ),
          .INITIATOR_BUSER            ( INITIATOR3_BUSER ),
          .INITIATOR_BVALID          ( INITIATOR3_BVALID ),
          .INITIATOR_BREADY          ( INITIATOR3_BREADY ),

          // ===============  Control Signals  =======================================================//
          .INITIATOR_RREADY_Default  ( INITIATOR_RREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .INITIATOR_WREADY_Default  ( INITIATOR_WREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .d_INITIATOR_BREADY_default( d_INITIATOR_BREADY_default ),  // defines whether Initiator asserts ready or waits for RVALID
          .rdStart                ( rdStart[3] ),          // defines whether Initiator starts a transaction
          .rdBurstLen              ( rdBurstLen ),          // burst length of read transaction
          .rdStartAddr            ( rdStartAddr ),        // start addresss for read transaction
          .rdAID                  ( rdAID ),            // AID for read transactions
          .initiatorRdAddrDone        ( initiatorRdAddrDone[3] ),    // Asserted when a read transaction has been completed
          .initiatorRdDone            ( initiatorRdDone[3] ),      // Asserted when a read transaction has been completed
          .initiatorRdStatus          ( initiatorRdStatus[3] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorRAddrIdle            ( initiatorRAddrIdle[3] ),
          .rdASize                ( rdASize[3] ),          // read size for each transfer in burst
          .expRResp                ( expRResp[3] ),        // indicate Read Respons expected
          .expWResp                ( expWResp[3] ),        // indicate Write Respons expected
          .wrASize                 ( wrASize[3] ),          // write size for each transfer in burst
          .wrStart                ( wrStart[3] ),          // defines whether Initiator starts a transaction
          .BurstType              ( BurstType ),          // Type of burst - FIXED=00, INCR=01, WRAP=10 
          .wrBurstLen             ( wrBurstLen ),          // burst length of write transaction
          .wrStartAddr            ( wrStartAddr ),        // start addresss for write transaction
          .wrAID                  ( wrAID ),            // AID for write transactions

          .initiatorWrAddrDone        ( initiatorWrAddrDone[3] ),    // Address Write transaction has been completed
          .initiatorWrDone           ( initiatorWrDone[3] ),      // Asserted when a write transaction has been completed
          .initiatorWrStatus         ( initiatorWrStatus[3] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorWAddrIdle           ( initiatorWAddrIdle[3] ),      // indicates Read Address Bus is idle
          .initiatorRespDone          ( initiatorRespDone[3] ),      // Asserted when a write response transaction has completed
          .initiatorWrAddrFull          ( initiatorWrAddrFull[3]  ),      // Asserted when the internal queue for writes are full
          .initiatorRdAddrFull          ( initiatorRdAddrFull[3]  )      // Asserted when the internal queue for reads are full

    );
    end
    else if (INITIATOR3_TYPE == 2'b10)
    begin
      assign INITIATOR3_AWVALID  = 1'b0;

      assign INITIATOR3_AWID      = 0;
      assign INITIATOR3_AWADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR3_AWLEN    = 0;
      assign INITIATOR3_AWSIZE   = 0;
      assign INITIATOR3_AWBURST  = 0;
      assign INITIATOR3_AWLOCK   = 0;
      assign INITIATOR3_AWCACHE  = 0;
      assign INITIATOR3_AWPROT   = 0;
      assign INITIATOR3_AWREGION  = 0;
      assign INITIATOR3_AWQOS    = 0;    // not used
      assign INITIATOR3_AWUSER   = 0;

      assign INITIATOR3_WVALID  = 0;
      assign INITIATOR3_WDATA  = 0;
      assign INITIATOR3_WSTRB  = 0;
      assign INITIATOR3_WUSER  = 0;
      assign INITIATOR3_WLAST  = 0;

      assign INITIATOR3_ARVALID  = 1'b0;

      assign INITIATOR3_ARID      = 0;
      assign INITIATOR3_ARADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR3_ARLEN    = 0;
      assign INITIATOR3_ARSIZE   = 0;
      assign INITIATOR3_ARBURST  = 0;
      assign INITIATOR3_ARLOCK   = 0;
      assign INITIATOR3_ARCACHE  = 0;
      assign INITIATOR3_ARPROT   = 0;
      assign INITIATOR3_ARREGION  = 0;
      assign INITIATOR3_ARQOS    = 0;    // not used
      assign INITIATOR3_ARUSER   = 0;

      assign INITIATOR3_RREADY = 1'b0;


      AHBL_Initiator #(
          .AHB_AWIDTH        (AHB_AWIDTH),
          .AHB_DWIDTH        (INITIATOR3_DATA_WIDTH),
          .UNDEF_BURST      (UNDEF_BURST_INITIATOR3)
           )
      initiator3 (
        // AHB Interface
        // Global Signal
         .HCLK          (I_CLK[3]),

         .HRESETn        (ARESETN),
         .HSEL          (INITIATOR3_HSEL),
         .HADDR          (INITIATOR3_HADDR),
         .HWRITE        (INITIATOR3_HWRITE),
         .HREADY        (INITIATOR3_HREADY),
         .HTRANS        (INITIATOR3_HTRANS),
         .HSIZE          (INITIATOR3_HSIZE),
         .HWDATA        (INITIATOR3_HWDATA),
         .HBURST        (INITIATOR3_HBURST),
         .HMASTLOCK      (INITIATOR3_HMASTLOCK),
         .HRESP          (INITIATOR3_HRESP),
         .HRDATA        (INITIATOR3_HRDATA),

         .HNONSEC        (INITIATOR3_HNONSEC),
         .HPROT          (INITIATOR3_HPROT),

         .start_tx      (start_tx[3]),
         .end_tx        (end_tx[3]),
         .hburst_tx      (hburst),
         .hsize_tx      (hsize),
         .haddr_tx      (haddr),
         .hwrite_tx      (hwrite)
         );
    end
    end
    endgenerate // initiator3

  // Generate for Initiator4
  generate // initiator4
  if (NUM_INITIATORS > 4) begin
  if (INITIATOR4_TYPE != 2'b10)
  begin
    AxiInitiator # 
        (
          .INITIATOR_NUM          ( 4 ),    // initiator number
          .INITIATOR_TYPE         ( INITIATOR_TYPE[9:8] ),
          .ID_WIDTH            ( ID_WIDTH ),

          .ADDR_WIDTH          ( ADDR_WIDTH ),
          .DATA_WIDTH          ( INITIATOR4_DATA_WIDTH ), 
          .SUPPORT_USER_SIGNALS( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH          ( USER_WIDTH ),
          .OPENTRANS_MAX       ( OPEN_MTTRANS_MAX )  // Number of open transations width - 1 => 2 transations, 2 => 4 transations, etc.
        )
      initiator4  (
          // Global Signals
          .sysClk                 ( I_CLK[4] ),
          .ARESETN                ( ARESETN ),
   
          // Initiator Read Address Ports
          .INITIATOR_ARID            ( INITIATOR4_ARID ),
          .INITIATOR_ARADDR          ( INITIATOR4_ARADDR ),
          .INITIATOR_ARLEN            ( INITIATOR4_ARLEN ),
          .INITIATOR_ARSIZE          ( INITIATOR4_ARSIZE ),
          .INITIATOR_ARBURST          ( INITIATOR4_ARBURST ),
          .INITIATOR_ARLOCK          ( INITIATOR4_ARLOCK ),
          .INITIATOR_ARCACHE          ( INITIATOR4_ARCACHE ),
          .INITIATOR_ARPROT          ( INITIATOR4_ARPROT ),
          .INITIATOR_ARREGION        ( INITIATOR4_ARREGION ),    // not used
          .INITIATOR_ARQOS            ( INITIATOR4_ARQOS ),      // not used
          .INITIATOR_ARUSER          ( INITIATOR4_ARUSER ),
          .INITIATOR_ARVALID          ( INITIATOR4_ARVALID ),
          .INITIATOR_ARREADY          ( INITIATOR4_ARREADY ),

          // Initiator Read Data Ports
          .INITIATOR_RID              ( INITIATOR4_RID ),
          .INITIATOR_RDATA            ( INITIATOR4_RDATA ),
          .INITIATOR_RRESP            ( INITIATOR4_RRESP ),
          .INITIATOR_RLAST            ( INITIATOR4_RLAST ),
          .INITIATOR_RUSER            ( INITIATOR4_RUSER ),
          .INITIATOR_RVALID          ( INITIATOR4_RVALID ),
          .INITIATOR_RREADY          ( INITIATOR4_RREADY ),

          // Initiator Write Address Ports
          .INITIATOR_AWID            ( INITIATOR4_AWID ),
          .INITIATOR_AWADDR          ( INITIATOR4_AWADDR ),
          .INITIATOR_AWLEN            ( INITIATOR4_AWLEN ),
          .INITIATOR_AWSIZE          ( INITIATOR4_AWSIZE ),
          .INITIATOR_AWBURST          ( INITIATOR4_AWBURST ),
          .INITIATOR_AWLOCK          ( INITIATOR4_AWLOCK ),
          .INITIATOR_AWCACHE          ( INITIATOR4_AWCACHE ),
          .INITIATOR_AWPROT          ( INITIATOR4_AWPROT ),
          .INITIATOR_AWREGION        ( INITIATOR4_AWREGION ),    // not used
          .INITIATOR_AWQOS            ( INITIATOR4_AWQOS ),      // not used
          .INITIATOR_AWUSER          ( INITIATOR4_AWUSER ),
          .INITIATOR_AWVALID          ( INITIATOR4_AWVALID ),
          .INITIATOR_AWREADY          ( INITIATOR4_AWREADY ),

          // Initiator Write Data Ports
          .INITIATOR_WID              ( INITIATOR4_WID ),
          .INITIATOR_WDATA            ( INITIATOR4_WDATA ),
          .INITIATOR_WSTRB            ( INITIATOR4_WSTRB ),
          .INITIATOR_WLAST            ( INITIATOR4_WLAST ),
          .INITIATOR_WUSER            ( INITIATOR4_WUSER ),
          .INITIATOR_WVALID          ( INITIATOR4_WVALID ),
          .INITIATOR_WREADY          ( INITIATOR4_WREADY ),
  
          // Initiator Write Response Ports
          .INITIATOR_BID              ( INITIATOR4_BID ),
          .INITIATOR_BRESP            ( INITIATOR4_BRESP ),
          .INITIATOR_BUSER            ( INITIATOR4_BUSER ),
          .INITIATOR_BVALID          ( INITIATOR4_BVALID ),
          .INITIATOR_BREADY          ( INITIATOR4_BREADY ),
   
          // ===============  Control Signals  =======================================================//
          .INITIATOR_RREADY_Default  ( INITIATOR_RREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .INITIATOR_WREADY_Default  ( INITIATOR_WREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .d_INITIATOR_BREADY_default( d_INITIATOR_BREADY_default ),  // defines whether Initiator asserts ready or waits for RVALID
          .rdStart                ( rdStart[4] ),          // defines whether Initiator starts a transaction
          .rdBurstLen              ( rdBurstLen ),          // burst length of read transaction
          .rdStartAddr            ( rdStartAddr ),        // start addresss for read transaction
          .rdAID                  ( rdAID ),            // AID for read transactions
          .initiatorRdAddrDone        ( initiatorRdAddrDone[4] ),    // Asserted when a read transaction has been completed
          .initiatorRdDone            ( initiatorRdDone[4] ),      // Asserted when a read transaction has been completed
          .initiatorRdStatus          ( initiatorRdStatus[4] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorRAddrIdle            ( initiatorRAddrIdle[4] ),
          .rdASize                ( rdASize[4] ),          // read size for each transfer in burst
          .expRResp                ( expRResp[4] ),        // indicate Read Respons expected
          .expWResp                ( expWResp[4] ),        // indicate Write Respons expected
          .wrASize                 ( wrASize[4] ),          // write size for each transfer in burst
          .wrStart                ( wrStart[4] ),          // defines whether Initiator starts a transaction
          .BurstType              ( BurstType ),          // Type of burst - FIXED=00, INCR=01, WRAP=10 
          .wrBurstLen             ( wrBurstLen ),          // burst length of write transaction
          .wrStartAddr            ( wrStartAddr ),        // start addresss for write transaction
          .wrAID                  ( wrAID ),            // AID for write transactions

          .initiatorWrAddrDone        ( initiatorWrAddrDone[4] ),    // Address Write transaction has been completed
          .initiatorWrDone           ( initiatorWrDone[4] ),      // Asserted when a write transaction has been completed
          .initiatorWrStatus         ( initiatorWrStatus[4] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorWAddrIdle           ( initiatorWAddrIdle[4] ),      // indicates Read Address Bus is idle
          .initiatorRespDone          ( initiatorRespDone[4] ),      // Asserted when a write response transaction has completed
          .initiatorWrAddrFull          ( initiatorWrAddrFull[4]  ),      // Asserted when the internal queue for writes are full
          .initiatorRdAddrFull          ( initiatorRdAddrFull[4]  )      // Asserted when the internal queue for reads are full

    );
    end
    else if (INITIATOR4_TYPE == 2'b10)
    begin
      assign INITIATOR4_AWVALID  = 1'b0;

      assign INITIATOR4_AWID      = 0;
      assign INITIATOR4_AWADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR4_AWLEN    = 0;
      assign INITIATOR4_AWSIZE   = 0;
      assign INITIATOR4_AWBURST  = 0;
      assign INITIATOR4_AWLOCK   = 0;
      assign INITIATOR4_AWCACHE  = 0;
      assign INITIATOR4_AWPROT   = 0;
      assign INITIATOR4_AWREGION  = 0;
      assign INITIATOR4_AWQOS    = 0;    // not used
      assign INITIATOR4_AWUSER   = 0;

      assign INITIATOR4_WVALID  = 0;
      assign INITIATOR4_WDATA  = 0;
      assign INITIATOR4_WSTRB  = 0;
      assign INITIATOR4_WUSER  = 0;
      assign INITIATOR4_WLAST  = 0;

      assign INITIATOR4_ARVALID  = 1'b0;

      assign INITIATOR4_ARID      = 0;
      assign INITIATOR4_ARADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR4_ARLEN    = 0;
      assign INITIATOR4_ARSIZE   = 0;
      assign INITIATOR4_ARBURST  = 0;
      assign INITIATOR4_ARLOCK   = 0;
      assign INITIATOR4_ARCACHE  = 0;
      assign INITIATOR4_ARPROT   = 0;
      assign INITIATOR4_ARREGION  = 0;
      assign INITIATOR4_ARQOS    = 0;    // not used
      assign INITIATOR4_ARUSER   = 0;

      assign INITIATOR4_RREADY = 1'b0;

      AHBL_Initiator #(
          .AHB_AWIDTH        (AHB_AWIDTH),
          .AHB_DWIDTH        (INITIATOR4_DATA_WIDTH),
          .UNDEF_BURST      (UNDEF_BURST_INITIATOR4)
           )
      initiator4 (
        // AHB Interface
        // Global Signal
         .HCLK          (I_CLK[4]),

         .HRESETn        (ARESETN),
         .HSEL          (INITIATOR4_HSEL),
         .HADDR          (INITIATOR4_HADDR),
         .HWRITE        (INITIATOR4_HWRITE),
         .HREADY        (INITIATOR4_HREADY),
         .HTRANS        (INITIATOR4_HTRANS),
         .HSIZE          (INITIATOR4_HSIZE),
         .HWDATA        (INITIATOR4_HWDATA),
         .HBURST        (INITIATOR4_HBURST),
         .HMASTLOCK      (INITIATOR4_HMASTLOCK),
         .HRESP          (INITIATOR4_HRESP),
         .HRDATA        (INITIATOR4_HRDATA),

         .HNONSEC        (INITIATOR4_HNONSEC),
         .HPROT          (INITIATOR4_HPROT),

         .start_tx      (start_tx[4]),
         .end_tx        (end_tx[4]),
         .hburst_tx      (hburst),
         .hsize_tx      (hsize),
         .haddr_tx      (haddr),
         .hwrite_tx      (hwrite)
         );
    end
    end
    endgenerate // initiator4


  // Generate for Initiator5
  generate // initiator5
  if (NUM_INITIATORS > 5) begin
  if (INITIATOR5_TYPE != 2'b10)
  begin
    AxiInitiator # 
        (
          .INITIATOR_NUM          ( 5 ),    // initiator number
          .INITIATOR_TYPE         ( INITIATOR_TYPE[11:10] ),
          .ID_WIDTH            ( ID_WIDTH ),

          .ADDR_WIDTH          ( ADDR_WIDTH ),
          .DATA_WIDTH          ( INITIATOR5_DATA_WIDTH ), 
          .SUPPORT_USER_SIGNALS( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH          ( USER_WIDTH ),
          .OPENTRANS_MAX       ( OPEN_MTTRANS_MAX )  // Number of open transations width - 1 => 2 transations, 2 => 4 transations, etc.
        )
      initiator5  (
          // Global Signals
          .sysClk                 ( I_CLK[5] ),
          .ARESETN                ( ARESETN ),
   
          // Initiator Read Address Ports
          .INITIATOR_ARID            ( INITIATOR5_ARID ),
          .INITIATOR_ARADDR          ( INITIATOR5_ARADDR ),
          .INITIATOR_ARLEN            ( INITIATOR5_ARLEN ),
          .INITIATOR_ARSIZE          ( INITIATOR5_ARSIZE ),
          .INITIATOR_ARBURST          ( INITIATOR5_ARBURST ),
          .INITIATOR_ARLOCK          ( INITIATOR5_ARLOCK ),
          .INITIATOR_ARCACHE          ( INITIATOR5_ARCACHE ),
          .INITIATOR_ARPROT          ( INITIATOR5_ARPROT ),
          .INITIATOR_ARREGION        ( INITIATOR5_ARREGION ),    // not used
          .INITIATOR_ARQOS            ( INITIATOR5_ARQOS ),      // not used
          .INITIATOR_ARUSER          ( INITIATOR5_ARUSER ),
          .INITIATOR_ARVALID          ( INITIATOR5_ARVALID ),
          .INITIATOR_ARREADY          ( INITIATOR5_ARREADY ),

          // Initiator Read Data Ports
          .INITIATOR_RID              ( INITIATOR5_RID ),
          .INITIATOR_RDATA            ( INITIATOR5_RDATA ),
          .INITIATOR_RRESP            ( INITIATOR5_RRESP ),
          .INITIATOR_RLAST            ( INITIATOR5_RLAST ),
          .INITIATOR_RUSER            ( INITIATOR5_RUSER ),
          .INITIATOR_RVALID          ( INITIATOR5_RVALID ),
          .INITIATOR_RREADY          ( INITIATOR5_RREADY ),

          // Initiator Write Address Ports
          .INITIATOR_AWID            ( INITIATOR5_AWID ),
          .INITIATOR_AWADDR          ( INITIATOR5_AWADDR ),
          .INITIATOR_AWLEN            ( INITIATOR5_AWLEN ),
          .INITIATOR_AWSIZE          ( INITIATOR5_AWSIZE ),
          .INITIATOR_AWBURST          ( INITIATOR5_AWBURST ),
          .INITIATOR_AWLOCK          ( INITIATOR5_AWLOCK ),
          .INITIATOR_AWCACHE          ( INITIATOR5_AWCACHE ),
          .INITIATOR_AWPROT          ( INITIATOR5_AWPROT ),
          .INITIATOR_AWREGION        ( INITIATOR5_AWREGION ),    // not used
          .INITIATOR_AWQOS            ( INITIATOR5_AWQOS ),      // not used
          .INITIATOR_AWUSER          ( INITIATOR5_AWUSER ),
          .INITIATOR_AWVALID          ( INITIATOR5_AWVALID ),
          .INITIATOR_AWREADY          ( INITIATOR5_AWREADY ),

          // Initiator Write Data Ports
          .INITIATOR_WID              ( INITIATOR5_WID ),
          .INITIATOR_WDATA            ( INITIATOR5_WDATA ),
          .INITIATOR_WSTRB            ( INITIATOR5_WSTRB ),
          .INITIATOR_WLAST            ( INITIATOR5_WLAST ),
          .INITIATOR_WUSER            ( INITIATOR5_WUSER ),
          .INITIATOR_WVALID          ( INITIATOR5_WVALID ),
          .INITIATOR_WREADY          ( INITIATOR5_WREADY ),
  
          // Initiator Write Response Ports
          .INITIATOR_BID              ( INITIATOR5_BID ),
          .INITIATOR_BRESP            ( INITIATOR5_BRESP ),
          .INITIATOR_BUSER            ( INITIATOR5_BUSER ),
          .INITIATOR_BVALID          ( INITIATOR5_BVALID ),
          .INITIATOR_BREADY          ( INITIATOR5_BREADY ),
   
          // ===============  Control Signals  =======================================================//
          .INITIATOR_RREADY_Default  ( INITIATOR_RREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .INITIATOR_WREADY_Default  ( INITIATOR_WREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .d_INITIATOR_BREADY_default( d_INITIATOR_BREADY_default ),  // defines whether Initiator asserts ready or waits for RVALID
          .rdStart                ( rdStart[5] ),          // defines whether Initiator starts a transaction
          .rdBurstLen              ( rdBurstLen ),          // burst length of read transaction
          .rdStartAddr            ( rdStartAddr ),        // start addresss for read transaction
          .rdAID                  ( rdAID ),            // AID for read transactions
          .initiatorRdAddrDone        ( initiatorRdAddrDone[5] ),    // Asserted when a read transaction has been completed
          .initiatorRdDone            ( initiatorRdDone[5] ),      // Asserted when a read transaction has been completed
          .initiatorRdStatus          ( initiatorRdStatus[5] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorRAddrIdle            ( initiatorRAddrIdle[5] ),
          .rdASize                ( rdASize[5] ),          // read size for each transfer in burst
          .expRResp                ( expRResp[5] ),        // indicate Read Respons expected
          .expWResp                ( expWResp[5] ),        // indicate Write Respons expected
          .wrASize                 ( wrASize[5] ),          // write size for each transfer in burst
          .wrStart                ( wrStart[5] ),          // defines whether Initiator starts a transaction
          .BurstType              ( BurstType ),          // Type of burst - FIXED=00, INCR=01, WRAP=10 
          .wrBurstLen             ( wrBurstLen ),          // burst length of write transaction
          .wrStartAddr            ( wrStartAddr ),        // start addresss for write transaction
          .wrAID                  ( wrAID ),            // AID for write transactions

          .initiatorWrAddrDone        ( initiatorWrAddrDone[5] ),    // Address Write transaction has been completed
          .initiatorWrDone           ( initiatorWrDone[5] ),      // Asserted when a write transaction has been completed
          .initiatorWrStatus         ( initiatorWrStatus[5] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorWAddrIdle           ( initiatorWAddrIdle[5] ),      // indicates Read Address Bus is idle
          .initiatorRespDone          ( initiatorRespDone[5] ),      // Asserted when a write response transaction has completed
          .initiatorWrAddrFull          ( initiatorWrAddrFull[5]  ),      // Asserted when the internal queue for writes are full
          .initiatorRdAddrFull          ( initiatorRdAddrFull[5]  )      // Asserted when the internal queue for reads are full
    );
    end
    else if (INITIATOR5_TYPE == 2'b10)
    begin
      assign INITIATOR5_AWVALID  = 1'b0;

      assign INITIATOR5_AWID      = 0;
      assign INITIATOR5_AWADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR5_AWLEN    = 0;
      assign INITIATOR5_AWSIZE   = 0;
      assign INITIATOR5_AWBURST  = 0;
      assign INITIATOR5_AWLOCK   = 0;
      assign INITIATOR5_AWCACHE  = 0;
      assign INITIATOR5_AWPROT   = 0;
      assign INITIATOR5_AWREGION  = 0;
      assign INITIATOR5_AWQOS    = 0;    // not used
      assign INITIATOR5_AWUSER   = 0;

      assign INITIATOR5_WVALID  = 0;
      assign INITIATOR5_WDATA  = 0;
      assign INITIATOR5_WSTRB  = 0;
      assign INITIATOR5_WUSER  = 0;
      assign INITIATOR5_WLAST  = 0;

      assign INITIATOR5_ARVALID  = 1'b0;

      assign INITIATOR5_ARID      = 0;
      assign INITIATOR5_ARADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR5_ARLEN    = 0;
      assign INITIATOR5_ARSIZE   = 0;
      assign INITIATOR5_ARBURST  = 0;
      assign INITIATOR5_ARLOCK   = 0;
      assign INITIATOR5_ARCACHE  = 0;
      assign INITIATOR5_ARPROT   = 0;
      assign INITIATOR5_ARREGION  = 0;
      assign INITIATOR5_ARQOS    = 0;    // not used
      assign INITIATOR5_ARUSER   = 0;

      assign INITIATOR5_RREADY = 1'b0;


      AHBL_Initiator #(
          .AHB_AWIDTH        (AHB_AWIDTH),
          .AHB_DWIDTH        (INITIATOR5_DATA_WIDTH),
          .UNDEF_BURST      (UNDEF_BURST_INITIATOR5)
           )
      initiator5 (
        // AHB Interface
        // Global Signal
         .HCLK          (I_CLK[5]),

         .HRESETn        (ARESETN),
         .HSEL          (INITIATOR5_HSEL),
         .HADDR          (INITIATOR5_HADDR),
         .HWRITE        (INITIATOR5_HWRITE),
         .HREADY        (INITIATOR5_HREADY),
         .HTRANS        (INITIATOR5_HTRANS),
         .HSIZE          (INITIATOR5_HSIZE),
         .HWDATA        (INITIATOR5_HWDATA),
         .HBURST        (INITIATOR5_HBURST),
         .HMASTLOCK      (INITIATOR5_HMASTLOCK),
         .HRESP          (INITIATOR5_HRESP),
         .HRDATA        (INITIATOR5_HRDATA),

         .HNONSEC        (INITIATOR5_HNONSEC),
         .HPROT          (INITIATOR5_HPROT),

         .start_tx      (start_tx[5]),
         .end_tx        (end_tx[5]),
         .hburst_tx      (hburst),
         .hsize_tx      (hsize),
         .haddr_tx      (haddr),
         .hwrite_tx      (hwrite)
         );
    end
    end
    endgenerate // initiator5


  // Generate for Initiator6
  generate // initiator6
  if (NUM_INITIATORS > 6) begin
  if (INITIATOR6_TYPE != 2'b10)
  begin
    AxiInitiator # 
        (
          .INITIATOR_NUM          ( 6 ),    // initiator number
          .INITIATOR_TYPE         ( INITIATOR_TYPE[13:12] ),
          .ID_WIDTH            ( ID_WIDTH ),

          .ADDR_WIDTH          ( ADDR_WIDTH ),
          .DATA_WIDTH          ( INITIATOR6_DATA_WIDTH ), 
          .SUPPORT_USER_SIGNALS( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH          ( USER_WIDTH ),
          .OPENTRANS_MAX       ( OPEN_MTTRANS_MAX )  // Number of open transations width - 1 => 2 transations, 2 => 4 transations, etc.
        )
      initiator6  (
          // Global Signals
          .sysClk                 ( I_CLK[6] ),
          .ARESETN                ( ARESETN ),
   
          // Initiator Read Address Ports
          .INITIATOR_ARID            ( INITIATOR6_ARID ),
          .INITIATOR_ARADDR          ( INITIATOR6_ARADDR ),
          .INITIATOR_ARLEN            ( INITIATOR6_ARLEN ),
          .INITIATOR_ARSIZE          ( INITIATOR6_ARSIZE ),
          .INITIATOR_ARBURST          ( INITIATOR6_ARBURST ),
          .INITIATOR_ARLOCK          ( INITIATOR6_ARLOCK ),
          .INITIATOR_ARCACHE          ( INITIATOR6_ARCACHE ),
          .INITIATOR_ARPROT          ( INITIATOR6_ARPROT ),
          .INITIATOR_ARREGION        ( INITIATOR6_ARREGION ),    // not used
          .INITIATOR_ARQOS            ( INITIATOR6_ARQOS ),      // not used
          .INITIATOR_ARUSER          ( INITIATOR6_ARUSER ),
          .INITIATOR_ARVALID          ( INITIATOR6_ARVALID ),
          .INITIATOR_ARREADY          ( INITIATOR6_ARREADY ),

          // Initiator Read Data Ports
          .INITIATOR_RID              ( INITIATOR6_RID ),
          .INITIATOR_RDATA            ( INITIATOR6_RDATA ),
          .INITIATOR_RRESP            ( INITIATOR6_RRESP ),
          .INITIATOR_RLAST            ( INITIATOR6_RLAST ),
          .INITIATOR_RUSER            ( INITIATOR6_RUSER ),
          .INITIATOR_RVALID          ( INITIATOR6_RVALID ),
          .INITIATOR_RREADY          ( INITIATOR6_RREADY ),

          // Initiator Write Address Ports
          .INITIATOR_AWID            ( INITIATOR6_AWID ),
          .INITIATOR_AWADDR          ( INITIATOR6_AWADDR ),
          .INITIATOR_AWLEN            ( INITIATOR6_AWLEN ),
          .INITIATOR_AWSIZE          ( INITIATOR6_AWSIZE ),
          .INITIATOR_AWBURST          ( INITIATOR6_AWBURST ),
          .INITIATOR_AWLOCK          ( INITIATOR6_AWLOCK ),
          .INITIATOR_AWCACHE          ( INITIATOR6_AWCACHE ),
          .INITIATOR_AWPROT          ( INITIATOR6_AWPROT ),
          .INITIATOR_AWREGION        ( INITIATOR6_AWREGION ),    // not used
          .INITIATOR_AWQOS            ( INITIATOR6_AWQOS ),      // not used
          .INITIATOR_AWUSER          ( INITIATOR6_AWUSER ),
          .INITIATOR_AWVALID          ( INITIATOR6_AWVALID ),
          .INITIATOR_AWREADY          ( INITIATOR6_AWREADY ),

          // Initiator Write Data Ports
          .INITIATOR_WID              ( INITIATOR6_WID ),
          .INITIATOR_WDATA            ( INITIATOR6_WDATA ),
          .INITIATOR_WSTRB            ( INITIATOR6_WSTRB ),
          .INITIATOR_WLAST            ( INITIATOR6_WLAST ),
          .INITIATOR_WUSER            ( INITIATOR6_WUSER ),
          .INITIATOR_WVALID          ( INITIATOR6_WVALID ),
          .INITIATOR_WREADY          ( INITIATOR6_WREADY ),
  
          // Initiator Write Response Ports
          .INITIATOR_BID              ( INITIATOR6_BID ),
          .INITIATOR_BRESP            ( INITIATOR6_BRESP ),
          .INITIATOR_BUSER            ( INITIATOR6_BUSER ),
          .INITIATOR_BVALID          ( INITIATOR6_BVALID ),
          .INITIATOR_BREADY          ( INITIATOR6_BREADY ),
   
          // ===============  Control Signals  =======================================================//
          .INITIATOR_RREADY_Default  ( INITIATOR_RREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .INITIATOR_WREADY_Default  ( INITIATOR_WREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .d_INITIATOR_BREADY_default( d_INITIATOR_BREADY_default ),  // defines whether Initiator asserts ready or waits for RVALID
          .rdStart                ( rdStart[6] ),          // defines whether Initiator starts a transaction
          .rdBurstLen              ( rdBurstLen ),          // burst length of read transaction
          .rdStartAddr            ( rdStartAddr ),        // start addresss for read transaction
          .rdAID                  ( rdAID ),            // AID for read transactions
          .initiatorRdAddrDone        ( initiatorRdAddrDone[6] ),    // Asserted when a read transaction has been completed
          .initiatorRdDone            ( initiatorRdDone[6] ),      // Asserted when a read transaction has been completed
          .initiatorRdStatus          ( initiatorRdStatus[6] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorRAddrIdle            ( initiatorRAddrIdle[6] ),
          .rdASize                ( rdASize[6] ),          // read size for each transfer in burst
          .expRResp                ( expRResp[6] ),        // indicate Read Respons expected
          .expWResp                ( expWResp[6] ),        // indicate Write Respons expected
          .wrASize                 ( wrASize[6] ),          // write size for each transfer in burst
          .wrStart                ( wrStart[6] ),          // defines whether Initiator starts a transaction
          .BurstType              ( BurstType ),          // Type of burst - FIXED=00, INCR=01, WRAP=10 
          .wrBurstLen             ( wrBurstLen ),          // burst length of write transaction
          .wrStartAddr            ( wrStartAddr ),        // start addresss for write transaction
          .wrAID                  ( wrAID ),            // AID for write transactions

          .initiatorWrAddrDone        ( initiatorWrAddrDone[6] ),    // Address Write transaction has been completed
          .initiatorWrDone           ( initiatorWrDone[6] ),      // Asserted when a write transaction has been completed
          .initiatorWrStatus         ( initiatorWrStatus[6] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorWAddrIdle           ( initiatorWAddrIdle[6] ),      // indicates Read Address Bus is idle
          .initiatorRespDone          ( initiatorRespDone[6] ),      // Asserted when a write response transaction has completed
          .initiatorWrAddrFull          ( initiatorWrAddrFull[6]  ),      // Asserted when the internal queue for writes are full
          .initiatorRdAddrFull          ( initiatorRdAddrFull[6]  )      // Asserted when the internal queue for reads are full
    );
    end
    else if (INITIATOR6_TYPE == 2'b10)
    begin
      assign INITIATOR6_AWVALID  = 1'b0;

      assign INITIATOR6_AWID      = 0;
      assign INITIATOR6_AWADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR6_AWLEN    = 0;
      assign INITIATOR6_AWSIZE   = 0;
      assign INITIATOR6_AWBURST  = 0;
      assign INITIATOR6_AWLOCK   = 0;
      assign INITIATOR6_AWCACHE  = 0;
      assign INITIATOR6_AWPROT   = 0;
      assign INITIATOR6_AWREGION  = 0;
      assign INITIATOR6_AWQOS    = 0;    // not used
      assign INITIATOR6_AWUSER   = 0;

      assign INITIATOR6_WVALID  = 0;
      assign INITIATOR6_WDATA  = 0;
      assign INITIATOR6_WSTRB  = 0;
      assign INITIATOR6_WUSER  = 0;
      assign INITIATOR6_WLAST  = 0;

      assign INITIATOR6_ARVALID  = 1'b0;

      assign INITIATOR6_ARID      = 0;
      assign INITIATOR6_ARADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR6_ARLEN    = 0;
      assign INITIATOR6_ARSIZE   = 0;
      assign INITIATOR6_ARBURST  = 0;
      assign INITIATOR6_ARLOCK   = 0;
      assign INITIATOR6_ARCACHE  = 0;
      assign INITIATOR6_ARPROT   = 0;
      assign INITIATOR6_ARREGION  = 0;
      assign INITIATOR6_ARQOS    = 0;    // not used
      assign INITIATOR6_ARUSER   = 0;

      assign INITIATOR6_RREADY = 1'b0;

      AHBL_Initiator #(
          .AHB_AWIDTH        (AHB_AWIDTH),
          .AHB_DWIDTH        (INITIATOR6_DATA_WIDTH),
          .UNDEF_BURST      (UNDEF_BURST_INITIATOR6)
           )
      initiator6 (
        // AHB Interface
        // Global Signal
         .HCLK          (I_CLK[6]),

         .HRESETn        (ARESETN),
         .HSEL          (INITIATOR6_HSEL),
         .HADDR          (INITIATOR6_HADDR),
         .HWRITE        (INITIATOR6_HWRITE),
         .HREADY        (INITIATOR6_HREADY),
         .HTRANS        (INITIATOR6_HTRANS),
         .HSIZE          (INITIATOR6_HSIZE),
         .HWDATA        (INITIATOR6_HWDATA),
         .HBURST        (INITIATOR6_HBURST),
         .HMASTLOCK      (INITIATOR6_HMASTLOCK),
         .HRESP          (INITIATOR6_HRESP),
         .HRDATA        (INITIATOR6_HRDATA),

         .HNONSEC        (INITIATOR6_HNONSEC),
         .HPROT          (INITIATOR6_HPROT),

         .start_tx      (start_tx[6]),
         .end_tx        (end_tx[6]),
         .hburst_tx      (hburst),
         .hsize_tx      (hsize),
         .haddr_tx      (haddr),
         .hwrite_tx      (hwrite)
         );
    end
    end
    endgenerate // initiator6



  // Generate for Initiator7
  generate // initiator7
  if (NUM_INITIATORS > 7) begin
  if (INITIATOR7_TYPE != 2'b10)
  begin
    AxiInitiator # 
        (
          .INITIATOR_NUM( 7 ),    // initiator number
          .INITIATOR_TYPE ( INITIATOR_TYPE[15:14] ),
          .ID_WIDTH( ID_WIDTH ),

          .ADDR_WIDTH( ADDR_WIDTH ),
          .DATA_WIDTH( INITIATOR7_DATA_WIDTH ), 
          .SUPPORT_USER_SIGNALS( SUPPORT_USER_SIGNALS ),
          .USER_WIDTH( USER_WIDTH ),
          .OPENTRANS_MAX( OPEN_MTTRANS_MAX )  // Number of open transations width - 1 => 2 transations, 2 => 4 transations, etc.
        )
      initiator7  (
          // Global Signals
          .sysClk                 ( I_CLK[7] ),
          .ARESETN                ( ARESETN ),

          // Initiator Read Address Ports
          .INITIATOR_ARID            ( INITIATOR7_ARID ),
          .INITIATOR_ARADDR          ( INITIATOR7_ARADDR ),
          .INITIATOR_ARLEN            ( INITIATOR7_ARLEN ),
          .INITIATOR_ARSIZE          ( INITIATOR7_ARSIZE ),
          .INITIATOR_ARBURST          ( INITIATOR7_ARBURST ),
          .INITIATOR_ARLOCK          ( INITIATOR7_ARLOCK ),
          .INITIATOR_ARCACHE          ( INITIATOR7_ARCACHE ),
          .INITIATOR_ARPROT          ( INITIATOR7_ARPROT ),
          .INITIATOR_ARREGION        ( INITIATOR7_ARREGION ),    // not used
          .INITIATOR_ARQOS            ( INITIATOR7_ARQOS ),      // not used
          .INITIATOR_ARUSER          ( INITIATOR7_ARUSER ),
          .INITIATOR_ARVALID          ( INITIATOR7_ARVALID ),
          .INITIATOR_ARREADY          ( INITIATOR7_ARREADY ),

          // Initiator Read Data Ports
          .INITIATOR_RID              ( INITIATOR7_RID ),
          .INITIATOR_RDATA            ( INITIATOR7_RDATA ),
          .INITIATOR_RRESP            ( INITIATOR7_RRESP ),
          .INITIATOR_RLAST            ( INITIATOR7_RLAST ),
          .INITIATOR_RUSER            ( INITIATOR7_RUSER ),
          .INITIATOR_RVALID          ( INITIATOR7_RVALID ),
          .INITIATOR_RREADY          ( INITIATOR7_RREADY ),

          // Initiator Write Address Ports
          .INITIATOR_AWID            ( INITIATOR7_AWID ),
          .INITIATOR_AWADDR          ( INITIATOR7_AWADDR ),
          .INITIATOR_AWLEN            ( INITIATOR7_AWLEN ),
          .INITIATOR_AWSIZE          ( INITIATOR7_AWSIZE ),
          .INITIATOR_AWBURST          ( INITIATOR7_AWBURST ),
          .INITIATOR_AWLOCK          ( INITIATOR7_AWLOCK ),
          .INITIATOR_AWCACHE          ( INITIATOR7_AWCACHE ),
          .INITIATOR_AWPROT          ( INITIATOR7_AWPROT ),
          .INITIATOR_AWREGION        ( INITIATOR7_AWREGION ),    // not used
          .INITIATOR_AWQOS            ( INITIATOR7_AWQOS ),      // not used
          .INITIATOR_AWUSER          ( INITIATOR7_AWUSER ),
          .INITIATOR_AWVALID          ( INITIATOR7_AWVALID ),
          .INITIATOR_AWREADY          ( INITIATOR7_AWREADY ),

          // Initiator Write Data Ports
          .INITIATOR_WID              ( INITIATOR7_WID ),
          .INITIATOR_WDATA            ( INITIATOR7_WDATA ),
          .INITIATOR_WSTRB            ( INITIATOR7_WSTRB ),
          .INITIATOR_WLAST            ( INITIATOR7_WLAST ),
          .INITIATOR_WUSER            ( INITIATOR7_WUSER ),
          .INITIATOR_WVALID          ( INITIATOR7_WVALID ),
          .INITIATOR_WREADY          ( INITIATOR7_WREADY ),
  
          // Initiator Write Response Ports
          .INITIATOR_BID              ( INITIATOR7_BID ),
          .INITIATOR_BRESP            ( INITIATOR7_BRESP ),
          .INITIATOR_BUSER            ( INITIATOR7_BUSER ),
          .INITIATOR_BVALID          ( INITIATOR7_BVALID ),
          .INITIATOR_BREADY          ( INITIATOR7_BREADY ),
   
          // ===============  Control Signals  =======================================================//
          .INITIATOR_RREADY_Default  ( INITIATOR_RREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .INITIATOR_WREADY_Default  ( INITIATOR_WREADY_Default ),    // defines whether Initiator asserts ready or waits for RVALID
          .d_INITIATOR_BREADY_default( d_INITIATOR_BREADY_default ),  // defines whether Initiator asserts ready or waits for RVALID
          .rdStart                ( rdStart[7] ),          // defines whether Initiator starts a transaction
          .rdBurstLen              ( rdBurstLen ),          // burst length of read transaction
          .rdStartAddr            ( rdStartAddr ),        // start addresss for read transaction
          .rdAID                  ( rdAID ),            // AID for read transactions
          .initiatorRdAddrDone        ( initiatorRdAddrDone[7] ),    // Asserted when a read transaction has been completed
          .initiatorRdDone            ( initiatorRdDone[7] ),      // Asserted when a read transaction has been completed
          .initiatorRdStatus          ( initiatorRdStatus[7] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorRAddrIdle            ( initiatorRAddrIdle[7] ),
          .rdASize                ( rdASize[7] ),          // read size for each transfer in burst
          .expRResp                ( expRResp[7] ),        // indicate Read Respons expected
          .expWResp                ( expWResp[7] ),        // indicate Write Respons expected
          .wrASize                 ( wrASize[7] ),          // write size for each transfer in burst
          .wrStart                ( wrStart[7] ),          // defines whether Initiator starts a transaction
          .BurstType              ( BurstType ),          // Type of burst - FIXED=00, INCR=01, WRAP=10 
          .wrBurstLen             ( wrBurstLen ),          // burst length of write transaction
          .wrStartAddr            ( wrStartAddr ),        // start addresss for write transaction
          .wrAID                  ( wrAID ),            // AID for write transactions

          .initiatorWrAddrDone        ( initiatorWrAddrDone[7] ),    // Address Write transaction has been completed
          .initiatorWrDone           ( initiatorWrDone[7] ),      // Asserted when a write transaction has been completed
          .initiatorWrStatus         ( initiatorWrStatus[7] ),      // Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
          .initiatorWAddrIdle           ( initiatorWAddrIdle[7] ),      // indicates Read Address Bus is idle
          .initiatorRespDone          ( initiatorRespDone[7] ),      // Asserted when a write response transaction has completed
          .initiatorWrAddrFull          ( initiatorWrAddrFull[7]  ),      // Asserted when the internal queue for writes are full
          .initiatorRdAddrFull          ( initiatorRdAddrFull[7]  )      // Asserted when the internal queue for reads are full
          );

    end
    else if (INITIATOR7_TYPE == 2'b10)
    begin
      assign INITIATOR7_AWVALID  = 1'b0;

      assign INITIATOR7_AWID      = 0;
      assign INITIATOR7_AWADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR7_AWLEN    = 0;
      assign INITIATOR7_AWSIZE   = 0;
      assign INITIATOR7_AWBURST  = 0;
      assign INITIATOR7_AWLOCK   = 0;
      assign INITIATOR7_AWCACHE  = 0;
      assign INITIATOR7_AWPROT   = 0;
      assign INITIATOR7_AWREGION  = 0;
      assign INITIATOR7_AWQOS    = 0;    // not used
      assign INITIATOR7_AWUSER   = 0;

      assign INITIATOR7_WVALID  = 0;
      assign INITIATOR7_WDATA  = 0;
      assign INITIATOR7_WSTRB  = 0;
      assign INITIATOR7_WUSER  = 0;
      assign INITIATOR7_WLAST  = 0;

      assign INITIATOR7_ARVALID  = 1'b0;

      assign INITIATOR7_ARID      = 0;
      assign INITIATOR7_ARADDR   = 0;        // make up data to be easy read in simulation
      assign INITIATOR7_ARLEN    = 0;
      assign INITIATOR7_ARSIZE   = 0;
      assign INITIATOR7_ARBURST  = 0;
      assign INITIATOR7_ARLOCK   = 0;
      assign INITIATOR7_ARCACHE  = 0;
      assign INITIATOR7_ARPROT   = 0;
      assign INITIATOR7_ARREGION  = 0;
      assign INITIATOR7_ARQOS    = 0;    // not used
      assign INITIATOR7_ARUSER   = 0;

      assign INITIATOR7_RREADY = 1'b0;

      AHBL_Initiator #(
          .AHB_AWIDTH        (AHB_AWIDTH),
          .AHB_DWIDTH        (INITIATOR7_DATA_WIDTH),
          .UNDEF_BURST      (UNDEF_BURST_INITIATOR7)
           )
      initiator7 (
        // AHB Interface
        // Global Signal
         .HCLK          (I_CLK[7]),

         .HRESETn        (ARESETN),
         .HSEL          (INITIATOR7_HSEL),
         .HADDR          (INITIATOR7_HADDR),
         .HWRITE        (INITIATOR7_HWRITE),
         .HREADY        (INITIATOR7_HREADY),
         .HTRANS        (INITIATOR7_HTRANS),
         .HSIZE          (INITIATOR7_HSIZE),
         .HWDATA        (INITIATOR7_HWDATA),
         .HBURST        (INITIATOR7_HBURST),
         .HMASTLOCK      (INITIATOR7_HMASTLOCK),
         .HRESP          (INITIATOR7_HRESP),
         .HRDATA        (INITIATOR7_HRDATA),

         .HNONSEC        (INITIATOR7_HNONSEC),
         .HPROT          (INITIATOR7_HPROT),

         .start_tx      (start_tx[7]),
         .end_tx        (end_tx[7]),
         .hburst_tx      (hburst),
         .hsize_tx      (hsize),
         .haddr_tx      (haddr),
         .hwrite_tx      (hwrite)
         );
    end
    end
    endgenerate // initiator7


//======================================================================================================================================
// ACLK - system clock
//======================================================================================================================================

initial begin
   ACLK <= 0;
end
always
  begin
    #(XBAR_CLK_PERIOD/2) ACLK <= #(XBAR_PHASE) ~ACLK;
  end

generate
if (INITIATOR0_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(INITIATOR0_CLK_PERIOD/2) I_CLK0 <= #(INITIATOR0_PHASE) ~I_CLK0;
  end
end else
always @(*) begin
  I_CLK0 <= ACLK;
end
endgenerate

generate
if (INITIATOR1_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(INITIATOR1_CLK_PERIOD/2) I_CLK1 <= #(INITIATOR1_PHASE) ~I_CLK1;
  end
end else
always @(*) begin
  I_CLK1 <= ACLK;
end
endgenerate

generate
if (INITIATOR2_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(INITIATOR2_CLK_PERIOD/2) I_CLK2 <= #(INITIATOR2_PHASE) ~I_CLK2;
  end
end else
always @(*) begin
  I_CLK2 <= ACLK;
end
endgenerate

generate
if (INITIATOR3_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(INITIATOR3_CLK_PERIOD/2) I_CLK3 <= #(INITIATOR3_PHASE) ~I_CLK3;
  end
end else
always @(*) begin
  I_CLK3 <= ACLK;
end
endgenerate

generate
if (INITIATOR4_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(INITIATOR4_CLK_PERIOD/2) I_CLK4 <= #(INITIATOR4_PHASE) ~I_CLK4;
  end
end else
always @(*) begin
  I_CLK4 <= ACLK;
end
endgenerate

generate
if (INITIATOR5_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(INITIATOR5_CLK_PERIOD/2) I_CLK5 <= #(INITIATOR5_PHASE) ~I_CLK5;
  end
end else
always @(*) begin
  I_CLK5 <= ACLK;
end
endgenerate

generate
if (INITIATOR6_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(INITIATOR6_CLK_PERIOD/2) I_CLK6 <= #(INITIATOR6_PHASE) ~I_CLK6;
  end
end else
always @(*) begin
  I_CLK6 <= ACLK;
end
endgenerate

generate
if (INITIATOR7_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(INITIATOR7_CLK_PERIOD/2) I_CLK7 <= #(INITIATOR7_PHASE) ~I_CLK7;
  end
end else
always @(*) begin
  I_CLK7 <= ACLK;
end
endgenerate

generate
if (TARGET0_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET0_CLK_PERIOD/2) T_CLK0 <= #(TARGET0_PHASE) ~T_CLK0;
  end
end else begin
always @(*) begin
  T_CLK0 <= ACLK;
end
end
endgenerate

generate
if (TARGET1_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET1_CLK_PERIOD/2) T_CLK1 <= #(TARGET1_PHASE) ~T_CLK1;
  end
end else
always @(*) begin
  T_CLK1 <= ACLK;
end
endgenerate

generate
if (TARGET2_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET2_CLK_PERIOD/2) T_CLK2 <= #(TARGET2_PHASE) ~T_CLK2;
  end
end else
always @(*) begin
  T_CLK2 <= ACLK;
end
endgenerate

generate
if (TARGET3_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET3_CLK_PERIOD/2) T_CLK3 <= #(TARGET3_PHASE) ~T_CLK3;
  end
end else
always @(*) begin
  T_CLK3 <= ACLK;
end
endgenerate

generate
if (TARGET4_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET4_CLK_PERIOD/2) T_CLK4 <= #(TARGET4_PHASE) ~T_CLK4;
  end
end else
always @(*) begin
  T_CLK4 <= ACLK;
end
endgenerate

generate
if (TARGET5_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET5_CLK_PERIOD/2) T_CLK5 <= #(TARGET5_PHASE) ~T_CLK5;
  end
end else
always @(*) begin
  T_CLK5 <= ACLK;
end
endgenerate

generate
if (TARGET6_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET6_CLK_PERIOD/2) T_CLK6 <= #(TARGET6_PHASE) ~T_CLK6;
  end
end else
always @(*) begin
  T_CLK6 <= ACLK;
end
endgenerate

generate
if (TARGET7_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET7_CLK_PERIOD/2) T_CLK7 <= #(TARGET7_PHASE) ~T_CLK7;
  end  
end else
always @(*) begin
  T_CLK7 <= ACLK;
end
endgenerate

generate
if (TARGET8_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET8_CLK_PERIOD/2) T_CLK8 <= #(TARGET8_PHASE) ~T_CLK8;
  end  
end else
always @(*) begin
  T_CLK8 <= ACLK;
end
endgenerate

generate
if (TARGET9_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET8_CLK_PERIOD/2) T_CLK9 <= #(TARGET9_PHASE) ~T_CLK9;
  end  
end else
always @(*) begin
  T_CLK9 <= ACLK;
end
endgenerate

generate
if (TARGET10_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET10_CLK_PERIOD/2) T_CLK10 <= #(TARGET10_PHASE) ~T_CLK10;
  end  
end else
always @(*) begin
  T_CLK10 <= ACLK;
end
endgenerate

generate
if (TARGET11_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET11_CLK_PERIOD/2) T_CLK11 <= #(TARGET11_PHASE) ~T_CLK11;
  end  
end else
always @(*) begin
  T_CLK11 <= ACLK;
end
endgenerate

generate
if (TARGET12_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET12_CLK_PERIOD/2) T_CLK12 <= #(TARGET12_PHASE) ~T_CLK12;
  end  
end else
always @(*) begin
  T_CLK12 <= ACLK;
end
endgenerate

generate
if (TARGET13_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET13_CLK_PERIOD/2) T_CLK13 <= #(TARGET13_PHASE) ~T_CLK13;
  end  
end else
always @(*) begin
  T_CLK13 <= ACLK;
end
endgenerate

generate
if (TARGET14_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET14_CLK_PERIOD/2) T_CLK14 <= #(TARGET14_PHASE) ~T_CLK14;
  end  
end else
always @(*) begin
  T_CLK14 <= ACLK;
end
endgenerate

generate
if (TARGET15_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET15_CLK_PERIOD/2) T_CLK15 <= #(TARGET15_PHASE) ~T_CLK15;
  end  
end else
always @(*) begin
  T_CLK15 <= ACLK;
end
endgenerate

generate
if (TARGET16_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET16_CLK_PERIOD/2) T_CLK16 <= #(TARGET16_PHASE) ~T_CLK16;
  end  
end else
always @(*) begin
  T_CLK16 <= ACLK;
end
endgenerate

generate
if (TARGET17_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET17_CLK_PERIOD/2) T_CLK17 <= #(TARGET17_PHASE) ~T_CLK17;
  end  
end else
always @(*) begin
  T_CLK17 <= ACLK;
end
endgenerate

generate
if (TARGET18_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET18_CLK_PERIOD/2) T_CLK18 <= #(TARGET18_PHASE) ~T_CLK18;
  end  
end else
always @(*) begin
  T_CLK18 <= ACLK;
end
endgenerate

generate
if (TARGET19_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET19_CLK_PERIOD/2) T_CLK19 <= #(TARGET19_PHASE) ~T_CLK19;
  end  
end else
always @(*) begin
  T_CLK19 <= ACLK;
end
endgenerate

generate
if (TARGET20_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET20_CLK_PERIOD/2) T_CLK20 <= #(TARGET20_PHASE) ~T_CLK20;
  end  
end else
always @(*) begin
  T_CLK20 <= ACLK;
end
endgenerate

generate
if (TARGET21_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET21_CLK_PERIOD/2) T_CLK21 <= #(TARGET21_PHASE) ~T_CLK21;
  end  
end else
always @(*) begin
  T_CLK21 <= ACLK;
end
endgenerate

generate
if (TARGET22_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET22_CLK_PERIOD/2) T_CLK22 <= #(TARGET22_PHASE) ~T_CLK22;
  end  
end else
always @(*) begin
  T_CLK22 <= ACLK;
end
endgenerate

generate
if (TARGET23_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET23_CLK_PERIOD/2) T_CLK23 <= #(TARGET23_PHASE) ~T_CLK23;
  end  
end else
always @(*) begin
  T_CLK23 <= ACLK;
end
endgenerate

generate
if (TARGET24_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET24_CLK_PERIOD/2) T_CLK24 <= #(TARGET24_PHASE) ~T_CLK24;
  end  
end else
always @(*) begin
  T_CLK24 <= ACLK;
end
endgenerate

generate
if (TARGET25_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET25_CLK_PERIOD/2) T_CLK25 <= #(TARGET25_PHASE) ~T_CLK25;
  end  
end else
always @(*) begin
  T_CLK25 <= ACLK;
end
endgenerate

generate
if (TARGET26_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET26_CLK_PERIOD/2) T_CLK26 <= #(TARGET26_PHASE) ~T_CLK26;
  end  
end else
always @(*) begin
  T_CLK26 <= ACLK;
end
endgenerate

generate
if (TARGET27_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET27_CLK_PERIOD/2) T_CLK27 <= #(TARGET27_PHASE) ~T_CLK27;
  end  
end else
always @(*) begin
  T_CLK27 <= ACLK;
end
endgenerate

generate
if (TARGET28_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET28_CLK_PERIOD/2) T_CLK28 <= #(TARGET28_PHASE) ~T_CLK28;
  end  
end else
always @(*) begin
  T_CLK28 <= ACLK;
end
endgenerate

generate
if (TARGET29_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET29_CLK_PERIOD/2) T_CLK29 <= #(TARGET29_PHASE) ~T_CLK29;
  end  
end else
always @(*) begin
  T_CLK29 <= ACLK;
end
endgenerate

generate
if (TARGET30_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET30_CLK_PERIOD/2) T_CLK30 <= #(TARGET30_PHASE) ~T_CLK30;
  end  
end else
always @(*) begin
  T_CLK30 <= ACLK;
end
endgenerate

generate
if (TARGET31_CLOCK_DOMAIN_CROSSING) begin
always
  begin
    #(TARGET31_CLK_PERIOD/2) T_CLK31 <= #(TARGET31_PHASE) ~T_CLK31;
  end  
end else
always @(*) begin
  T_CLK31 <= ACLK;
end
endgenerate


//=======================================================================================================================================


//=========================================================================================
// AXI4Read - initate a Read transaction on the AXI4 Bus
//=========================================================================================
task AXI4Read;

  input [NUM_INITIATORS_WIDTH-1:0]  initiatorNum;
  input [ADDR_WIDTH-1:0]       readAddr;
  input [ID_WIDTH-1:0]        readID;
  input [7:0]           readLen;  
  input [1:0]            readType;
  input [2:0]            readSize;
  input [1:0]            readRResp;

begin

  //============================================
  // Drive out Address phase
  //============================================
  @( posedge I_CLK[initiatorNum])
    begin
      // define // parameters for read
      rdStartAddr      <= readAddr;
      rdBurstLen      <= readLen;
      BurstType      <= readType;
      rdAID        <= readID;
      rdASize[initiatorNum]  <= readSize;
      expRResp[initiatorNum]  <= readRResp;

      rdStart[initiatorNum]  <= 1;
    end

  @( negedge I_CLK[initiatorNum]);
  while ( initiatorRdAddrFull[initiatorNum] )    // wait till readFifo is not full
    begin
      @( negedge I_CLK[initiatorNum] );
    end    

  @( posedge I_CLK[initiatorNum])
    begin
      rdStart[initiatorNum]     <= 0;
    end
end
endtask    // AXI4Read task


//=========================================================================================
// AXI4Write - initate a Write transaction on the AXI4 Bus
//=========================================================================================
task AXI4Write;

  input [NUM_INITIATORS_WIDTH-1:0]  initiatorNum;
  input [ADDR_WIDTH-1:0]       writeAddr;
  input [ID_WIDTH-1:0]        writeID;
  input [7:0]           writeLen;
  input [1:0]            writeType;
  input [2:0]            writeSize;
  input [1:0]            writeRResp;

begin

  //============================================
  // Drive out Address phase
  //============================================
  @( posedge I_CLK[initiatorNum])
    begin
      // define // parameters for write
      wrStartAddr      <= writeAddr;
      wrBurstLen      <= writeLen;
      BurstType      <= writeType;
      wrAID        <= writeID;
      wrASize[initiatorNum]  <= writeSize;
      expWResp[initiatorNum]  <= writeRResp;

      wrStart[initiatorNum]   <= 1;
    end

  @( negedge I_CLK[initiatorNum]);
  while ( initiatorWrAddrFull[initiatorNum] )    // wait till readFifo is not full
    begin
      @( negedge I_CLK[initiatorNum] );
    end

  @( posedge I_CLK[initiatorNum])
    begin
      wrStart[initiatorNum]     <= 0;
    end
end
endtask    // AXI4Write task

//=====================================================================================================================================

reg              passStatus;

integer            j, k, i, l, burst, cnt, multiSize, TxSize;
reg no_tx;

integer a,b,c,d;

reg              fullFound;

reg [ADDR_WIDTH-1:0]     rdAddr, wrAddr;
reg [ID_WIDTH-1:0]      rdID, wrID;
reg [7:0]           rdLen, wrLen;  

reg [2:0]          wrSize    [NUM_INITIATORS-1:0];
reg [2:0]          rdSize    [NUM_INITIATORS-1:0];

reg [1:0]          wrResp, rdResp;
reg [23:0]          shiftDefault;

reg [NUM_TARGETS-1:0]    WRITE_CONNECTIVITY;
reg [NUM_TARGETS-1:0]    READ_CONNECTIVITY;

integer            startTime, elapsedTime, endTime, burstTime, numTrans, numInitiators, nPorts;

reg              fullConnectivity;

always @( passStatus )
begin
  if (passStatus == 0 )
    $stop;
end

//=================================================================================================================================
// Run tests based on Initiator/Target types
//=================================================================================================================================
initial 
begin

  // Initialize Inputs
  passStatus = 1;    // initialise to passing;

  // reset core
  I_CLK0      <= 0;
  I_CLK1      <= 0;
  I_CLK2      <= 0;
  I_CLK3      <= 0;
  I_CLK4      <= 0;
  I_CLK5      <= 0;
  I_CLK6      <= 0;
  I_CLK7      <= 0;

  T_CLK0      <= 0;
  T_CLK1      <= 0;
  T_CLK2      <= 0;
  T_CLK3      <= 0;
  T_CLK4      <= 0;
  T_CLK5      <= 0;
  T_CLK6      <= 0;
  T_CLK7      <= 0;
  T_CLK8      <= 0;
  T_CLK9      <= 0;
  T_CLK10     <= 0;
  T_CLK11     <= 0;
  T_CLK12     <= 0;
  T_CLK13     <= 0;
  T_CLK14     <= 0;
  T_CLK15     <= 0;
  T_CLK16     <= 0;
  T_CLK17     <= 0;
  T_CLK18     <= 0;
  T_CLK19     <= 0;
  T_CLK20     <= 0;
  T_CLK21     <= 0;
  T_CLK22     <= 0;
  T_CLK23     <= 0;
  T_CLK24     <= 0;
  T_CLK25     <= 0;
  T_CLK26     <= 0;
  T_CLK27     <= 0;
  T_CLK28     <= 0;
  T_CLK29     <= 0;
  T_CLK30     <= 0;
  T_CLK31     <= 0;

  ARESETN     <= 0;



  $display( "\n\n================================================================================== " );
  $display( "%t  --- Starting  Tests                                                  ", $time );
  $display( "===================================================================================\n\n" );

  @( posedge ACLK);
  @( posedge ACLK);

  //====================== Initial Initiators  ================================================//

  INITIATOR_RREADY_Default   = 1;
  INITIATOR_WREADY_Default  = 1;
  d_INITIATOR_BREADY_default  = 1;

  TARGET_ARREADY_Default   = 1;
  TARGET_AWREADY_Default   = 1;

  TARGET_DATA_IDLE_EN    = RNDEN;    // Enables idle cycles to be inserted in Data channels
  TARGET_DATA_IDLE_CYCLES  = 0;      // Idle cycles = 00= random, 01 = 1, 10=2, 11=3

  FORCE_ERROR        = 32'h0;     // Forces error pn read/write RESP
  ERROR_BYTE        = 8'h0;      // Byte to force error on - for READs

  rdAddr         = 0;
  wrAddr         = 0;

  rdBurstLen    <= 0;
  rdStartAddr    <= 0;  
  rdAID      <= 0;

  wrBurstLen    <= 0;
  wrStartAddr    <= 0;  
  wrAID      <= 0;

  BurstType    <= 2'b01;      // INCR type

  #1;

  for (k=0; k< NUM_INITIATORS; k=k+1 )
    begin
      rdStart[k]    <= 0;    
      wrStart[k]    <= 0;
      wrSize[k]    <= 0;
      rdSize[k]    <= 0;
    end

  #30;

  @( posedge ACLK)  ARESETN <= 1;

  @(posedge ACLK);

  #100;
  @(posedge ACLK);

  //================================================================================================================
  // Select Test to run
  //================================================================================================================

  //`include "./User_Tests_incl.v"            // performs detailed verification of AXI4CROSS
  // ********************************************************************
  //  Microsemi Corporation Proprietary and Confidential
  //  Copyright 2017 Microsemi Corporation.  All rights reserved.
  //
  // ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
  // ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
  // IN ADVANCE IN WRITING.
  //
  // Description: CoreAXI4Interconnect testbench
  //
  // Revision Information:
  // Date     Description:     Tests for user testbench to verify operation with all ports defined as Initiators & Targets.
  // Feb17    Revision 1.0
  //
  // Notes:
  // best viewed with tabstops set to "4"
  // ********************************************************************
  
  begin
      $display( "\n\n===============================================================================================================" );
      $display( "                        User Testing with %d Initiators and %d Targets",NUM_INITIATORS,NUM_TARGETS ); 
      $display( "===============================================================================================================\n\n" );
  
      for (multiSize = 0; multiSize < 8; multiSize = multiSize+1)
      begin
  
      for (burst = 0; burst < 3; burst = burst+1)
      begin
      
      #100;
      @(posedge ACLK);
      $display( "\n\n===============================================================================================================" );
      $display( "%t  --- Test 1 - Check Write Connectivity map - Write from each Initiator to each Target       ", $time );
      $display( "===============================================================================================================\n\n" );
  
      //===========  Write to each target from each initiator =====================
	  for ( j=0; j<NUM_INITIATORS; j=j+1 )
        begin
          WRITE_CONNECTIVITY = INITIATOR_WRITE_CONNECTIVITY[(j*NUM_TARGETS) +: NUM_TARGETS ];
        
          for ( k=0; k <NUM_TARGETS; k=k+1 )	
            begin
  
              TxSize <= multiSize % (1+($clog2(INITIATOR_PORTS_DATA_WIDTH[(32*j)+:32]/8)));
              //wrAddr[ADDR_WIDTH-1:ADDR_WIDTH-ADDR_DEC_WIDTH]	<= k[ADDR_DEC_WIDTH-1:0];
              //wrAddr[NUM_AXITARGET_BITS-1:NUM_AXITARGET_BITS-NUM_INITIATORS_WIDTH]	<= j[NUM_INITIATORS_WIDTH-1:0];		// map each Initiator into different memory area in Target
              //wrAddr[NUM_AXITARGET_BITS-NUM_INITIATORS_WIDTH-1:NUM_AXITARGET_BITS-NUM_INITIATORS_WIDTH-NUM_TARGETS_WIDTH]	<= k[NUM_TARGETS_WIDTH-1:0];		// map each Target into different memory area in Target
              //wrAddr[NUM_AXITARGET_BITS-NUM_INITIATORS_WIDTH-NUM_TARGETS_WIDTH-1:0]  <= 0;
  
  
              wrAddr <= TARGET_ADDR[(32*k)+:32] + j*64;
              @(posedge I_CLK[j]);
              @(posedge I_CLK[j]);
  
              for (cnt = 0; cnt < MAX_TX_INITR_TRGT; cnt = cnt + 1)
              begin
          
              wrID			<= k+j+1;
  
              
              wrResp			<= ( WRITE_CONNECTIVITY[k] ) ? 2'b00 : 2'b11;
  
              $display("WRITE transaction: initiator %d type %d target %d initiator data width", j, INITIATOR_TYPE[(2*j)+:2], k, INITIATOR_PORTS_DATA_WIDTH[(32*j)+:32]);
              if (INITIATOR_TYPE[(2*j)+:2] == 2'b10) begin // AHB initiator
                #1;
                hburst <= (cnt % 8);
                hsize <= TxSize;
                haddr <= 32'h0 |  (wrAddr & ~((1<< TxSize)-1));
                hwrite <= 1'b1;
                start_tx <= 1 << j;
  
                @(posedge I_CLK[j]);
                start_tx <= 'b0;
                #1;
                @(posedge end_tx[j]);
              end
              else begin
  
                offset_addr = (((((cnt+CNT_INIT)%(((burst == 1)&& (INITIATOR_TYPE[(2*j)+:2] == 2'b00) ) ? 256 : 16))+1) << TxSize));
                #1 next_addr = ((wrAddr+offset_addr));
  
                if (wrAddr[ADDR_WIDTH-1:12] == (next_addr >> 12) ) begin
                  if (burst == 2) begin
                      wrLen <= 2**((cnt % 4) + 1) - 1;
                   end
                   else begin
                      wrLen			<= (cnt+CNT_INIT) % (((burst == 1) && (INITIATOR_TYPE[(2*j)+:2] == 2'b00)) ? 256 : 16);
                   end
                   no_tx = 0;
                end
                else begin
                  if (burst == 2) begin
                    if (((13'h1000 - wrAddr[11:0]) >> TxSize) < 2) begin
                      no_tx = 1;
                      wrLen = 1;
                    end
                    else begin
                      no_tx = 0;
                      wrLen <= 2**((((13'h1000 - wrAddr[11:0]) >> TxSize) % 4) + 1) - 1;
                    end
                  end
                  else begin
                    no_tx = 0;
                    wrLen     <= ((12'hFFF - wrAddr[11:0]) >> TxSize);
                  end
                end
              
              if (burst == 2'b10) begin // WRAP burst
                wrAddr[5:0] <= 6'h0;
              end
              
              if (INITIATOR_TYPE[(2*j)+:2] == 2'b01) begin // AXI4-Lite initiator
                  wrLen <=  'b0;
                  TxSize <= $clog2(INITIATOR_PORTS_DATA_WIDTH[(32*j)+:32]/8);
              end
              if (no_tx == 0) begin
                  #1 AXI4Write( j[7:0], (wrAddr), wrID, wrLen, burst, TxSize, wrResp  );				// initiator to each target
  
                #1 $display("\n %t, Waiting for initiatorRespDone[%d] to assert for write to target[%d]\n", $time,  j, k );
            
                @(posedge initiatorRespDone[j] )
                  begin
                    #1;
  
                    if ( WRITE_CONNECTIVITY[k] )	// if initiator can write to target
                      begin
                        if ( ~initiatorWrStatus[j] )
                          begin
                            #1 $display("%t, Initiator Error - initiatorWrStatus = %b", $time,  initiatorWrStatus[j] );
                            $stop;
                          end
                        passStatus = passStatus & initiatorWrStatus[j];	
                      end
                    else							// if initiator cannot write to target - should get DECRR back
                      begin
                        if ( ~initiatorWrStatus[j] )
                          begin
                            #1 $display("%t, Initiator Error - expected DECERR- initiatorWrStatus = %b", $time,  initiatorWrStatus[j] );
                            $stop;
                          end
                        else
                          begin
                            #1 $display("\n%t, Initiator DECERR ok - expected DECERR- initiatorWrStatus = %b\n", $time,  initiatorWrStatus[j] );
                          end
                        passStatus = passStatus & initiatorWrStatus[j];
                      end
                  end
              end

            end
  
  
              if  (INITIATOR_TYPE[(2*j)+:2] == 2'b10) begin
                if (hburst == 1)
                  wrAddr <= ( wrAddr + (UNDEF_AHB_BURST[(8*j)+:8] << TxSize));
                else
                  wrAddr <= ( wrAddr + ((2**(1+hburst[2:1])+2) << TxSize));
              end
              else if (burst == 2'b10) begin
                wrAddr <= wrAddr + (2 << ($clog2(wrLen+1)+TxSize));
              end
              else begin
                wrAddr <= ( wrAddr + ((cnt+CNT_INIT+2) << TxSize));
              end
  
              end
            end
  
        end
  
        
      $display( "\n\n===============================================================================================================" );
      $display( "%t  --- Test 2 - Check Read Connectivity map - Read from each Target to each Initiator       ", $time );
      $display( "==============================================================================================================\n\n " );
    
  
      //===========  Read from each target from each initiator =====================
      for ( j=0; j<NUM_INITIATORS; j=j+1 )
        begin
          READ_CONNECTIVITY = INITIATOR_READ_CONNECTIVITY[(j*NUM_TARGETS) +: NUM_TARGETS ];
  
          for ( k=0; k <NUM_TARGETS; k=k+1 )	
			begin
              TxSize <= multiSize % (1+($clog2(INITIATOR_PORTS_DATA_WIDTH[(32*j)+:32]/8)));
              //rdAddr[ADDR_WIDTH-1:ADDR_WIDTH-ADDR_DEC_WIDTH]	<= k[ADDR_DEC_WIDTH-1:0];
              //rdAddr[NUM_AXITARGET_BITS-1:NUM_AXITARGET_BITS-NUM_INITIATORS_WIDTH]	<= j[NUM_INITIATORS_WIDTH-1:0];		// map each Initiator into different memory area in Target
              //rdAddr[NUM_AXITARGET_BITS-NUM_INITIATORS_WIDTH-1:NUM_AXITARGET_BITS-NUM_INITIATORS_WIDTH-NUM_TARGETS_WIDTH]	<= k[NUM_TARGETS_WIDTH-1:0];		// map each Target into different memory area in Target
              //rdAddr[NUM_AXITARGET_BITS-NUM_INITIATORS_WIDTH-NUM_TARGETS_WIDTH-1:0]  <= 0;
              rdAddr <= TARGET_ADDR[(32*k)+:32] + j*64;
              @(posedge I_CLK[j]);
              @(posedge I_CLK[j]);
  
              for (cnt = 0; cnt < MAX_TX_INITR_TRGT; cnt = cnt + 1)
              begin
              
                rdID			<= k+j+1;
                rdResp			<= READ_CONNECTIVITY[k] ? 2'b0 : 2'b11;
  
                $display("READ transaction: initiator %d type %d target %d initiator data width %d", j, INITIATOR_TYPE[(2*j)+:2], k, INITIATOR_PORTS_DATA_WIDTH[(32*j)+:32]);
                if (INITIATOR_TYPE[(2*j)+:2] == 2'b10) begin // AHB initiator
                  #1;
                  hburst <=  (cnt % 8);
                  hsize <= TxSize;
                  haddr <= 32'h0 | (rdAddr & ~((1<< TxSize)-1));
                  hwrite <= 1'b0;
                  start_tx <= 1 << j;
                  @(posedge I_CLK[j]);
                  start_tx <= 'b0;
                  #1;
                  @(posedge end_tx[j]);
                end
                else begin
  
                  offset_addr = (((((cnt+CNT_INIT)%(((burst == 1)&& (INITIATOR_TYPE[(2*j)+:2] == 2'b00) ) ? 256 : 16))+1) << TxSize));
                  #1 next_addr = ((rdAddr+offset_addr));
  
                  if (rdAddr[ADDR_WIDTH-1:12] == (next_addr >> 12))  begin
                    if (burst == 2) begin
                      rdLen <= 2**((cnt % 4) + 1) - 1;
                    end
                    else begin
                      rdLen			<= (cnt+CNT_INIT) % (((burst == 1) && (INITIATOR_TYPE[(2*j)+:2] == 2'b00)) ? 256 : 16);
                    end
                      no_tx = 0;
                  end
                  else begin
                    if (burst == 2) begin
                      if (((13'h1000 - rdAddr[11:0]) >> TxSize) < 2) begin
                        no_tx = 1;
                        rdLen = 1;
                      end
                      else begin
                        no_tx = 0;
                        rdLen <= 2**((((13'h1000 - rdAddr[11:0]) >> TxSize) % 4) + 1) - 1;
                      end
                    end
                    else begin
                      no_tx = 0;
                      rdLen     <= ((12'hFFF - rdAddr[11:0]) >> TxSize);
                    end
                  end
  
                if (burst == 2'b10) begin // WRAP burst
                  rdAddr[5:0] <= 6'h00;
                end
                
                if (INITIATOR_TYPE[(2*j)+:2] == 2'b01) begin // AXI4-Lite initiator
                  rdLen <=  'b0;
                  TxSize <= $clog2(INITIATOR_PORTS_DATA_WIDTH[(32*j)+:32]/8);
                end
                      
                if (no_tx == 0) begin
                  #1 AXI4Read( j[7:0], (rdAddr), rdID, rdLen, burst, TxSize, rdResp  );				// initiator to each target
  
                  #1 $display("\n %t, Waiting for initiatorRdDone[%d] to assert for read from target[%d]\n", $time,  j, k );
  
                  @(posedge initiatorRdDone[j] )
                    begin
                      #1;
                      if ( READ_CONNECTIVITY[k] )	// if initiator can read from target
                        begin
                          if ( ~initiatorRdStatus[j] )
                            begin
                              #1 $display("%t, Initiator Error - initiatorRdStatus = %b", $time,  initiatorRdStatus[j] );
                              $stop;
                            end
                          passStatus = passStatus & initiatorRdStatus[j];	
                        end
                      else							// if initiator cannot write to target - should get DECRR back
                        begin
                          if ( ~initiatorRdStatus[j] )
                            begin
                              #1 $display("%t, Initiator Error - expected DECERR- initiatorRdStatus = %b", $time,  initiatorRdStatus[j] );
                              $stop;
                            end
                          else
                            begin
                              #1 $display("\n%t, Initiator DECERR ok - expected DECERR- initiatorRdStatus = %b\n", $time,  initiatorRdStatus[j] );
                            end
                          passStatus = passStatus & initiatorRdStatus[j];
                        end
                    end
                end
               end
  
                if  (INITIATOR_TYPE[(2*j)+:2] == 2'b10) begin
                  if (hburst == 1)
                    rdAddr <= ( rdAddr + (UNDEF_AHB_BURST[(8*j)+:8] << TxSize));
                  else
                    rdAddr <= ( rdAddr + ((2**(1+hburst[2:1])+2) << TxSize));
                end
                else if (burst == 2'b10) begin
                  rdAddr <= rdAddr + (2 << ($clog2(rdLen+1)+TxSize));
                end
                else begin
                  rdAddr <= ( rdAddr + ((cnt+CNT_INIT+2) << TxSize));
                end
                
              end
          end
        end
        
      end
    end
  
  
      #50;
      if (passStatus)
        begin
          $display( "\n\n==============================================================================================" );
          $display( "%t Passed : all tests passed", $time );
          $display( "==============================================================================================\n\n" );
          //$stop;
        end
      else
        begin
          $display( "\n\n============================================================================================" );
          $display( "%t FAIL : at least 1 tests failed ", $time );
          $display( "==============================================================================================\n" );
        end
  
  
      #500 
      $stop;
      $finish;
  
  end		// User_Tests_incl.v

  end


endmodule   // User_Test.v