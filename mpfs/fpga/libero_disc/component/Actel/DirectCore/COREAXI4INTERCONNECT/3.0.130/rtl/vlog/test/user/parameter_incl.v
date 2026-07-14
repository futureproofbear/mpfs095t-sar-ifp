// ********************************************************************
//  Microsemi Corporation Proprietary and Confidential
//  Copyright 2017 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: This file states the parameters needed to change the
//              behaviour of the core during testing.
//
// Revision Information:
// Date     Description:
// Feb17    Revision 1.0
//
// Notes:
// best viewed with tabstops set to "4"
// ********************************************************************

  //=====================================================================
  // Global parameters
  //=====================================================================

  parameter integer FAMILY           = 19;
    
  parameter integer NUM_INITIATORS      = 4;        // defines number of initiator ports 
  parameter integer NUM_TARGETS         = 4;        // defines number of targets

  parameter integer ID_WIDTH         = 3;        // number of bits for ID (ie AID, WID, BID) - valid 1-8 
  parameter integer ADDR_WIDTH       = 32;        // valid values - 16 - 64
  parameter integer ADDR_WIDTH_INT   = (ADDR_WIDTH > 32) ? 32 : ADDR_WIDTH;       

  //====================================================================
  // Crossbar parameters
  //====================================================================
  parameter integer DATA_WIDTH       = 64;        // valid widths - 32, 64, 128

  parameter NUM_THREADS           = 4;        // defined number of indpendent threads per initiator supported - valid range 1-8
  parameter OPEN_TRANS_MAX        = 2;        // max number of outstanding transactions per thread - valid range 1-8

  parameter OPEN_WRTRANS_MAX        = OPEN_TRANS_MAX*2;    // max number of outstanding write transactions - valid range 2-8 - 2**OPEN_WRTRANS_MAX
  parameter OPEN_RDTRANS_MAX        = OPEN_TRANS_MAX*2;    // max number of outstanding read transactions - valid range  2-8 - 2**OPEN_RDTRANS_MAX


  `define DECWIDTH  4           // Defines width of address decode for each target slot
                                // Allow space for undefined memory spaces - to allow for testing
                                // decode errors.


  parameter UPPER_COMPARE_BIT     = ADDR_WIDTH- `DECWIDTH;      // Defines the upper bit of range to compare
  parameter LOWER_COMPARE_BIT     = UPPER_COMPARE_BIT - 4;      // Defines lower bound of compare - bits below are dont care

  parameter [31:0]  TARGET0_START_ADDR  = 'h00000000;          // Defines the start address for Target 0 
  parameter [31:0]  TARGET1_START_ADDR  = 'h10000000;          // Defines the start address for Target 1 
  parameter [31:0]  TARGET2_START_ADDR  = 'h20000000;          // Defines the start address for Target 2 
  parameter [31:0]  TARGET3_START_ADDR  = 'h30000000;          // Defines the start address for Target 3 
  parameter [31:0]  TARGET4_START_ADDR  = 'h40000000;          // Defines the start address for Target 4 
  parameter [31:0]  TARGET5_START_ADDR  = 'h50000000;          // Defines the start address for Target 5 
  parameter [31:0]  TARGET6_START_ADDR  = 'h60000000;          // Defines the start address for Target 6 
  parameter [31:0]  TARGET7_START_ADDR  = 'h70000000;          // Defines the start address for Target 7 
  parameter [31:0]  TARGET8_START_ADDR  = 'h80000000;          // Defines the start address for Target 8 
  parameter [31:0]  TARGET9_START_ADDR  = 'h90000000;          // Defines the start address for Target 9 
  parameter [31:0]  TARGET10_START_ADDR = 'ha0000000;          // Defines the start address for Target 10
  parameter [31:0]  TARGET11_START_ADDR = 'hb0000000;          // Defines the start address for Target 11
  parameter [31:0]  TARGET12_START_ADDR = 'hc0000000;          // Defines the start address for Target 12
  parameter [31:0]  TARGET13_START_ADDR = 'hd0000000;          // Defines the start address for Target 13
  parameter [31:0]  TARGET14_START_ADDR = 'he0000000;          // Defines the start address for Target 14
  parameter [31:0]  TARGET15_START_ADDR = 'hf0000000;          // Defines the start address for Target 15

  parameter [31:0]  TARGET0_END_ADDR  = 'h0fffffff;          // Defines the end address for Target 0 
  parameter [31:0]  TARGET1_END_ADDR  = 'h1fffffff;          // Defines the end address for Target 1 
  parameter [31:0]  TARGET2_END_ADDR  = 'h2fffffff;          // Defines the end address for Target 2 
  parameter [31:0]  TARGET3_END_ADDR  = 'h3fffffff;          // Defines the end address for Target 3 
  parameter [31:0]  TARGET4_END_ADDR  = 'h4fffffff;          // Defines the end address for Target 4 
  parameter [31:0]  TARGET5_END_ADDR  = 'h5fffffff;          // Defines the end address for Target 5 
  parameter [31:0]  TARGET6_END_ADDR  = 'h6fffffff;          // Defines the end address for Target 6 
  parameter [31:0]  TARGET7_END_ADDR  = 'h7fffffff;          // Defines the end address for Target 7 
  parameter [31:0]  TARGET8_END_ADDR  = 'h8fffffff;          // Defines the end address for Target 8 
  parameter [31:0]  TARGET9_END_ADDR  = 'h9fffffff;          // Defines the end address for Target 9 
  parameter [31:0]  TARGET10_END_ADDR = 'hafffffff;          // Defines the end address for Target 10
  parameter [31:0]  TARGET11_END_ADDR = 'hbfffffff;          // Defines the end address for Target 11
  parameter [31:0]  TARGET12_END_ADDR = 'hcfffffff;          // Defines the end address for Target 12
  parameter [31:0]  TARGET13_END_ADDR = 'hdfffffff;          // Defines the end address for Target 13
  parameter [31:0]  TARGET14_END_ADDR = 'hefffffff;          // Defines the end address for Target 14
  parameter [31:0]  TARGET15_END_ADDR = 'hffffffff;          // Defines the end address for Target 15

  
  parameter integer USER_WIDTH         = 4;        // defines the number of bits for USER signals RUSER and WUSER
  parameter integer CROSSBAR_MODE      = 1;        // defines whether non-blocking (ie set 1) or shared access data path

  parameter [0:0]    INITIATOR0_WRITE_TARGET0  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET1  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET2  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET3  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET4  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET5  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET6  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET7  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET8  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET9  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET10 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET11 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET12 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET13 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET14 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET15 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET16 = 1'b1;     // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR0_WRITE_TARGET17 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET18 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET19 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET20 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET21 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET22 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET23 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET24 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET25 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET26 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET27 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET28 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET29 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET30 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET31 = 1'b1;     // bit for target indicating if an initiator can write to that port            
  parameter [0:0]    INITIATOR1_WRITE_TARGET0  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET1  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET2  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET3  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET4  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET5  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET6  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET7  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET8  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET9  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET10 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET11 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET12 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET13 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET14 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET15 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET16 = 1'b1;     // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR1_WRITE_TARGET17 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET18 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET19 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET20 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET21 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET22 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET23 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET24 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET25 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET26 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET27 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET28 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET29 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET30 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET31 = 1'b1;     // bit for target indicating if an initiator can write to that port

  parameter [0:0]    INITIATOR2_WRITE_TARGET0  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET1  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET2  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET3  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET4  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET5  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET6  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET7  = 1'b1;     // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR2_WRITE_TARGET8  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET9  = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET10 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET11 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET12 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET13 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET14 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET15 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET16 = 1'b1;     // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR2_WRITE_TARGET17 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET18 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET19 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET20 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET21 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET22 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET23 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET24 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET25 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET26 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET27 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET28 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET29 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET30 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET31 = 1'b1;     // bit for target indicating if an initiator can write to that port            
  parameter [0:0]    INITIATOR3_WRITE_TARGET0 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET1 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET2 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET3 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET4 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET5 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET6 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET7 = 1'b1;      // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR3_WRITE_TARGET8 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET9 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET10 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET11 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET12 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET13 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET14 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET15 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET16 = 1'b1;     // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR3_WRITE_TARGET17 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET18 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET19 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET20 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET21 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET22 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET23 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET24 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET25 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET26 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET27 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET28 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET29 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET30 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET31 = 1'b1;     // bit for target indicating if an initiator can write to that port            
  parameter [0:0]    INITIATOR4_WRITE_TARGET0 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET1 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET2 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET3 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET4 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET5 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET6 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET7 = 1'b1;      // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR4_WRITE_TARGET8 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET9 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET10 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET11 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET12 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET13 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET14 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET15 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET16 = 1'b1;     // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR4_WRITE_TARGET17 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET18 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET19 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET20 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET21 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET22 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET23 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET24 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET25 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET26 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET27 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET28 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET29 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET30 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET31 = 1'b1;     // bit for target indicating if an initiator can write to that port            
  parameter [0:0]    INITIATOR5_WRITE_TARGET0 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET1 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET2 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET3 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET4 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET5 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET6 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET7 = 1'b1;      // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR5_WRITE_TARGET8 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET9 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET10 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET11 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET12 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET13 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET14 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET15 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET16 = 1'b1;     // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR5_WRITE_TARGET17 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET18 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET19 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET20 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET21 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET22 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET23 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET24 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET25 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET26 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET27 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET28 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET29 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET30 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET31 = 1'b1;     // bit for target indicating if an initiator can write to that port            
  parameter [0:0]    INITIATOR6_WRITE_TARGET0 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET1 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET2 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET3 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET4 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET5 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET6 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET7 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET8 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET9 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET10 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET11 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET12 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET13 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET14 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET15 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET16 = 1'b1;     // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR6_WRITE_TARGET17 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET18 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET19 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET20 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET21 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET22 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET23 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET24 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET25 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET26 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET27 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET28 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET29 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET30 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET31 = 1'b1;     // bit for target indicating if an initiator can write to that port              
  parameter [0:0]    INITIATOR7_WRITE_TARGET0 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET1 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET2 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET3 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET4 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET5 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET6 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET7 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET8 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET9 = 1'b1;      // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET10 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET11 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET12 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET13 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET14 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET15 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET16 = 1'b1;     // bit for target indicating if an initiator can write to that port  
  parameter [0:0]    INITIATOR7_WRITE_TARGET17 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET18 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET19 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET20 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET21 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET22 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET23 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET24 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET25 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET26 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET27 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET28 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET29 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET30 = 1'b1;     // bit for target indicating if an initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET31 = 1'b1;     // bit for target indicating if an initiator can write to that port

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////              

  parameter [0:0]    INITIATOR0_READ_TARGET0 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET1 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET2 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET3 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET4 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET5 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET6 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET7 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET8 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET9 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET10 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET11 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET12 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET13 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET14 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET15 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET16 = 1'b1;     // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR0_READ_TARGET17 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET18 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET19 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET20 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET21 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET22 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET23 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET24 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET25 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET26 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET27 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET28 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET29 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET30 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET31 = 1'b1;     // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR1_READ_TARGET0 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET1 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET2 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET3 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET4 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET5 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET6 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET7 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET8 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET9 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET10 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET11 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET12 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET13 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET14 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET15 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET16 = 1'b1;     // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR1_READ_TARGET17 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET18 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET19 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET20 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET21 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET22 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET23 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET24 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET25 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET26 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET27 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET28 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET29 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET30 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET31 = 1'b1;     // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR2_READ_TARGET0 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET1 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET2 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET3 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET4 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET5 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET6 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET7 = 1'b1;      // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR2_READ_TARGET8 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET9 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET10 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET11 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET12 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET13 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET14 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET15 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET16 = 1'b1;     // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR2_READ_TARGET17 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET18 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET19 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET20 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET21 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET22 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET23 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET24 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET25 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET26 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET27 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET28 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET29 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET30 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET31 = 1'b1;     // bit for target indicating if an initiator can read to that port   
  parameter [0:0]    INITIATOR3_READ_TARGET0 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET1 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET2 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET3 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET4 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET5 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET6 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET7 = 1'b1;      // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR3_READ_TARGET8 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET9 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET10 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET11 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET12 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET13 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET14 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET15 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET16 = 1'b1;     // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR3_READ_TARGET17 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET18 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET19 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET20 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET21 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET22 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET23 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET24 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET25 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET26 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET27 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET28 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET29 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET30 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET31 = 1'b1;     // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR4_READ_TARGET0 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET1 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET2 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET3 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET4 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET5 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET6 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET7 = 1'b1;      // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR4_READ_TARGET8 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET9 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET10 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET11 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET12 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET13 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET14 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET15 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET16 = 1'b1;     // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR4_READ_TARGET17 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET18 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET19 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET20 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET21 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET22 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET23 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET24 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET25 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET26 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET27 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET28 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET29 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET30 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET31 = 1'b1;     // bit for target indicating if an initiator can read to that port   
  parameter [0:0]    INITIATOR5_READ_TARGET0 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET1 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET2 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET3 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET4 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET5 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET6 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET7 = 1'b1;      // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR5_READ_TARGET8 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET9 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET10 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET11 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET12 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET13 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET14 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET15 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET16 = 1'b1;     // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR5_READ_TARGET17 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET18 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET19 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET20 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET21 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET22 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET23 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET24 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET25 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET26 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET27 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET28 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET29 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET30 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET31 = 1'b1;     // bit for target indicating if an initiator can read to that port   
  parameter [0:0]    INITIATOR6_READ_TARGET0 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET1 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET2 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET3 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET4 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET5 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET6 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET7 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET8 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET9 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET10 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET11 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET12 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET13 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET14 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET15 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET16 = 1'b1;     // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR6_READ_TARGET17 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET18 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET19 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET20 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET21 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET22 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET23 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET24 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET25 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET26 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET27 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET28 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET29 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET30 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET31 = 1'b1;     // bit for target indicating if an initiator can read to that port   
  parameter [0:0]    INITIATOR7_READ_TARGET0 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET1 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET2 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET3 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET4 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET5 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET6 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET7 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET8 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET9 = 1'b1;      // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET10 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET11 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET12 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET13 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET14 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET15 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET16 = 1'b1;     // bit for target indicating if an initiator can read to that port  
  parameter [0:0]    INITIATOR7_READ_TARGET17 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET18 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET19 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET20 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET21 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET22 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET23 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET24 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET25 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET26 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET27 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET28 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET29 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET30 = 1'b1;     // bit for target indicating if an initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET31 = 1'b1;     // bit for target indicating if an initiator can read to that port 

  parameter  OPT_HIFREQ          = 0;        // increases freq of operation at cost of added latency
  parameter  RD_ARB_EN           = 1;        // select arb or ordered rdata

  //====================================================================
  // Port Protocol Convertor / Data Width Convertor parameters
  //====================================================================
  parameter [1:0] INITIATOR0_TYPE  = 2'b10;           // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3, 10 = AHB
  parameter [1:0] INITIATOR1_TYPE  = 2'b01;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3, 10 = AHB
  parameter [1:0] INITIATOR2_TYPE  = 2'b11;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3, 10 = AHB
  parameter [1:0] INITIATOR3_TYPE  = 2'b00;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3, 10 = AHB
  parameter [1:0] INITIATOR4_TYPE  = INITIATOR0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3, 10 = AHB
  parameter [1:0] INITIATOR5_TYPE  = INITIATOR0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3, 10 = AHB
  parameter [1:0] INITIATOR6_TYPE  = INITIATOR0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3, 10 = AHB
  parameter [1:0] INITIATOR7_TYPE  = INITIATOR0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3, 10 = AHB
  
  parameter [1:0] TARGET0_TYPE  = 2'b11;          // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET1_TYPE  = 2'b00;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET2_TYPE  = 2'b01;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET3_TYPE  = 2'b00;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET4_TYPE  = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET5_TYPE  = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET6_TYPE  = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET7_TYPE  = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET8_TYPE  = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET9_TYPE  = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET10_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET11_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET12_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET13_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET14_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET15_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET16_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET17_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET18_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET19_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET20_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET21_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET22_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET23_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET24_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET25_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET26_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET27_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET28_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET29_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET30_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET31_TYPE = TARGET0_TYPE;    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3

  parameter  [31:0] INITIATOR0_DATA_WIDTH  =  512;                       // Defines data width of Initiator0
  parameter  [31:0] INITIATOR1_DATA_WIDTH  =  32;                       // Defines data width of Initiator1
  parameter  [31:0] INITIATOR2_DATA_WIDTH  =  64;                       // Defines data width of Initiator2
  parameter  [31:0] INITIATOR3_DATA_WIDTH  =  256;                       // Defines data width of Initiator3
  parameter  [31:0] INITIATOR4_DATA_WIDTH  =  INITIATOR0_DATA_WIDTH;       // Defines data width of Initiator4
  parameter  [31:0] INITIATOR5_DATA_WIDTH  =  INITIATOR0_DATA_WIDTH;       // Defines data width of Initiator5
  parameter  [31:0] INITIATOR6_DATA_WIDTH  =  INITIATOR0_DATA_WIDTH;     // Defines data width of Initiator6
  parameter  [31:0] INITIATOR7_DATA_WIDTH  =  INITIATOR0_DATA_WIDTH;     // Defines data width of Initiator7
  
  parameter  [31:0] TARGET0_DATA_WIDTH  =  32;                     // Defines data width of Target0
  parameter  [31:0] TARGET1_DATA_WIDTH  =  64;      				  // Defines data width of Target1
  parameter  [31:0] TARGET2_DATA_WIDTH  =  128;      // Defines data width of Target2
  parameter  [31:0] TARGET3_DATA_WIDTH  =  256;      // Defines data width of Target3
  parameter  [31:0] TARGET4_DATA_WIDTH  =  TARGET0_DATA_WIDTH;      // Defines data width of Target4
  parameter  [31:0] TARGET5_DATA_WIDTH  =  TARGET0_DATA_WIDTH;      // Defines data width of Target5
  parameter  [31:0] TARGET6_DATA_WIDTH  =  TARGET0_DATA_WIDTH;      // Defines data width of Target6
  parameter  [31:0] TARGET7_DATA_WIDTH  =  TARGET0_DATA_WIDTH;      // Defines data width of Target7
  parameter  [31:0] TARGET8_DATA_WIDTH  =  TARGET0_DATA_WIDTH;      // Defines data width of Target8
  parameter  [31:0] TARGET9_DATA_WIDTH  =  TARGET0_DATA_WIDTH;      // Defines data width of Target9
  parameter  [31:0] TARGET10_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target10
  parameter  [31:0] TARGET11_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target11
  parameter  [31:0] TARGET12_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target12
  parameter  [31:0] TARGET13_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target13
  parameter  [31:0] TARGET14_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target14
  parameter  [31:0] TARGET15_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target15
  parameter  [31:0] TARGET16_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target16
  parameter  [31:0] TARGET17_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target17
  parameter  [31:0] TARGET18_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target18
  parameter  [31:0] TARGET19_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target19
  parameter  [31:0] TARGET20_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target20
  parameter  [31:0] TARGET21_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target21
  parameter  [31:0] TARGET22_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target22
  parameter  [31:0] TARGET23_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target23
  parameter  [31:0] TARGET24_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target24
  parameter  [31:0] TARGET25_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target25
  parameter  [31:0] TARGET26_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target26
  parameter  [31:0] TARGET27_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target27
  parameter  [31:0] TARGET28_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target28
  parameter  [31:0] TARGET29_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target29
  parameter  [31:0] TARGET30_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target30
  parameter  [31:0] TARGET31_DATA_WIDTH =  TARGET0_DATA_WIDTH;      // Defines data width of Target31
  
  
  parameter integer  TRGT_AXI4PRT_ADDRDEPTH = 3;          // valid 2-6 , Number transactions 2^TRGT_AXI4PRT_ADDRDEPTH
  parameter integer  TRGT_AXI4PRT_DATADEPTH = 3;          // valid 2-6 , Number transactions 2^TRGT_AXI4PRT_DATADEPTH
  
  parameter integer MAX_TX_INITR_TRGT = 1;

  //====================================================================
  // Register Slice parameters
  //====================================================================
  parameter [0:0] INITIATOR0_CHAN_RS = 1'b1;
  parameter [0:0] INITIATOR1_CHAN_RS = INITIATOR0_CHAN_RS;
  parameter [0:0] INITIATOR2_CHAN_RS = INITIATOR0_CHAN_RS;
  parameter [0:0] INITIATOR3_CHAN_RS = INITIATOR0_CHAN_RS;
  parameter [0:0] INITIATOR4_CHAN_RS = INITIATOR0_CHAN_RS;
  parameter [0:0] INITIATOR5_CHAN_RS = INITIATOR0_CHAN_RS;
  parameter [0:0] INITIATOR6_CHAN_RS = INITIATOR0_CHAN_RS;
  parameter [0:0] INITIATOR7_CHAN_RS = INITIATOR0_CHAN_RS;
  
  parameter [0:0] TARGET0_CHAN_RS = 1'b1;
  parameter [0:0] TARGET1_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET2_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET3_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET4_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET5_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET6_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET7_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET8_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET9_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET10_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET11_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET12_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET13_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET14_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET15_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET16_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET17_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET18_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET19_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET20_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET21_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET22_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET23_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET24_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET25_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET26_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET27_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET28_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET29_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET30_CHAN_RS = TARGET0_CHAN_RS;
  parameter [0:0] TARGET31_CHAN_RS = TARGET0_CHAN_RS;
 //==================================================================
  parameter  [7:0] INITIATOR0_DEF_BURST_LEN  =  8'hf;      // Defines the default burst length if the AHB interface of Initiator0
  parameter  [7:0] INITIATOR1_DEF_BURST_LEN  =  8'h1;      // Defines the default burst length if the AHB interface of Initiator1
  parameter  [7:0] INITIATOR2_DEF_BURST_LEN  =  8'h00;      // Defines the default burst length if the AHB interface of Initiator2
  parameter  [7:0] INITIATOR3_DEF_BURST_LEN  =  8'h0a;      // Defines the default burst length if the AHB interface of Initiator3
  parameter  [7:0] INITIATOR4_DEF_BURST_LEN  =  8'h11;      // Defines the default burst length if the AHB interface of Initiator4
  parameter  [7:0] INITIATOR5_DEF_BURST_LEN  =  8'h0f;      // Defines the default burst length if the AHB interface of Initiator5
  parameter  [7:0] INITIATOR6_DEF_BURST_LEN  =  8'hf;      // Defines the default burst length if the AHB interface of Initiator6
  parameter  [7:0] INITIATOR7_DEF_BURST_LEN  =  8'h1;      // Defines the default burst length if the AHB interface of Initiator7

  parameter  [13:0] TARGET0_DWC_DATA_FIFO_DEPTH   =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target0
  parameter  [13:0] TARGET1_DWC_DATA_FIFO_DEPTH   =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target1
  parameter  [13:0] TARGET2_DWC_DATA_FIFO_DEPTH   =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target2
  parameter  [13:0] TARGET3_DWC_DATA_FIFO_DEPTH   =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target3
  parameter  [13:0] TARGET4_DWC_DATA_FIFO_DEPTH   =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target4
  parameter  [13:0] TARGET5_DWC_DATA_FIFO_DEPTH   =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target5
  parameter  [13:0] TARGET6_DWC_DATA_FIFO_DEPTH   =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target6
  parameter  [13:0] TARGET7_DWC_DATA_FIFO_DEPTH   =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target7
  parameter  [13:0] TARGET8_DWC_DATA_FIFO_DEPTH   =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target8
  parameter  [13:0] TARGET9_DWC_DATA_FIFO_DEPTH   =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target9
  parameter  [13:0] TARGET10_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target10
  parameter  [13:0] TARGET11_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target11
  parameter  [13:0] TARGET12_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target12
  parameter  [13:0] TARGET13_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target13
  parameter  [13:0] TARGET14_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target14
  parameter  [13:0] TARGET15_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target15
  parameter  [13:0] TARGET16_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target16
  parameter  [13:0] TARGET17_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target17
  parameter  [13:0] TARGET18_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target18
  parameter  [13:0] TARGET19_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target19
  parameter  [13:0] TARGET20_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target20
  parameter  [13:0] TARGET21_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target21
  parameter  [13:0] TARGET22_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target22
  parameter  [13:0] TARGET23_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target23
  parameter  [13:0] TARGET24_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target24
  parameter  [13:0] TARGET25_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target25
  parameter  [13:0] TARGET26_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target26
  parameter  [13:0] TARGET27_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target27
  parameter  [13:0] TARGET28_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target28
  parameter  [13:0] TARGET29_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target29
  parameter  [13:0] TARGET30_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target30
  parameter  [13:0] TARGET31_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Target31

  parameter  [13:0] INITIATOR0_DWC_DATA_FIFO_DEPTH  =  14'hc;      // Defines the depth of the data FIFO in the datawidth converter of Initiator0
  parameter  [13:0] INITIATOR1_DWC_DATA_FIFO_DEPTH  =  14'h3;      // Defines the depth of the data FIFO in the datawidth converter of Initiator1
  parameter  [13:0] INITIATOR2_DWC_DATA_FIFO_DEPTH  =  14'hb;      // Defines the depth of the data FIFO in the datawidth converter of Initiator2
  parameter  [13:0] INITIATOR3_DWC_DATA_FIFO_DEPTH  =  14'h5;      // Defines the depth of the data FIFO in the datawidth converter of Initiator3
  parameter  [13:0] INITIATOR4_DWC_DATA_FIFO_DEPTH  =  14'h11;      // Defines the depth of the data FIFO in the datawidth converter of Initiator4
  parameter  [13:0] INITIATOR5_DWC_DATA_FIFO_DEPTH  =  14'h10;      // Defines the depth of the data FIFO in the datawidth converter of Initiator5
  parameter  [13:0] INITIATOR6_DWC_DATA_FIFO_DEPTH  =  14'h4;      // Defines the depth of the data FIFO in the datawidth converter of Initiator6
  parameter  [13:0] INITIATOR7_DWC_DATA_FIFO_DEPTH  =  14'h8;      // Defines the depth of the data FIFO in the datawidth converter of Initiator7

  parameter [31:0] XBAR_CLK_PERIOD = 10;

  parameter [31:0] INITIATOR0_CLK_PERIOD  = 6;
  parameter [31:0] INITIATOR1_CLK_PERIOD  = 7;
  parameter [31:0] INITIATOR2_CLK_PERIOD  = 7;
  parameter [31:0] INITIATOR3_CLK_PERIOD  = 9;
  parameter [31:0] INITIATOR4_CLK_PERIOD  = INITIATOR0_CLK_PERIOD;
  parameter [31:0] INITIATOR5_CLK_PERIOD  = INITIATOR0_CLK_PERIOD;
  parameter [31:0] INITIATOR6_CLK_PERIOD  = INITIATOR0_CLK_PERIOD;
  parameter [31:0] INITIATOR7_CLK_PERIOD  = INITIATOR0_CLK_PERIOD;
  
  parameter [31:0] TARGET0_CLK_PERIOD    = XBAR_CLK_PERIOD;
  parameter [31:0] TARGET1_CLK_PERIOD    = 5;
  parameter [31:0] TARGET2_CLK_PERIOD    = 11;
  parameter [31:0] TARGET3_CLK_PERIOD    = 20;
  parameter [31:0] TARGET4_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET5_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET6_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET7_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET8_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET9_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET10_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET11_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET12_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET13_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET14_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET15_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET16_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET17_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET18_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET19_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET20_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET21_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET22_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET23_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET24_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET25_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET26_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET27_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET28_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET29_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET30_CLK_PERIOD    = TARGET0_CLK_PERIOD;
  parameter [31:0] TARGET31_CLK_PERIOD    = TARGET0_CLK_PERIOD;



  parameter integer XBAR_PHASE = 0;

  parameter integer INITIATOR0_PHASE  = XBAR_PHASE;  
  parameter integer INITIATOR1_PHASE  = INITIATOR0_PHASE;  
  parameter integer INITIATOR2_PHASE  = INITIATOR0_PHASE;  
  parameter integer INITIATOR3_PHASE  = INITIATOR0_PHASE;  
  parameter integer INITIATOR4_PHASE  = INITIATOR0_PHASE;  
  parameter integer INITIATOR5_PHASE  = INITIATOR0_PHASE;  
  parameter integer INITIATOR6_PHASE  = INITIATOR0_PHASE;  
  parameter integer INITIATOR7_PHASE  = INITIATOR0_PHASE;    
  
  parameter integer TARGET0_PHASE    = XBAR_PHASE;
  parameter integer TARGET1_PHASE    = TARGET0_PHASE;
  parameter integer TARGET2_PHASE    = TARGET0_PHASE;
  parameter integer TARGET3_PHASE    = TARGET0_PHASE;
  parameter integer TARGET4_PHASE    = TARGET0_PHASE;
  parameter integer TARGET5_PHASE    = TARGET0_PHASE;
  parameter integer TARGET6_PHASE    = TARGET0_PHASE;
  parameter integer TARGET7_PHASE    = TARGET0_PHASE;
  parameter integer TARGET8_PHASE    = TARGET0_PHASE;
  parameter integer TARGET9_PHASE    = TARGET0_PHASE;
  parameter integer TARGET10_PHASE    = TARGET0_PHASE;
  parameter integer TARGET11_PHASE    = TARGET0_PHASE;
  parameter integer TARGET12_PHASE    = TARGET0_PHASE;
  parameter integer TARGET13_PHASE    = TARGET0_PHASE;
  parameter integer TARGET14_PHASE    = TARGET0_PHASE;
  parameter integer TARGET15_PHASE    = TARGET0_PHASE;
  parameter integer TARGET16_PHASE    = TARGET0_PHASE;
  parameter integer TARGET17_PHASE    = TARGET0_PHASE;
  parameter integer TARGET18_PHASE    = TARGET0_PHASE;
  parameter integer TARGET19_PHASE    = TARGET0_PHASE;
  parameter integer TARGET20_PHASE    = TARGET0_PHASE;
  parameter integer TARGET21_PHASE    = TARGET0_PHASE;
  parameter integer TARGET22_PHASE    = TARGET0_PHASE;
  parameter integer TARGET23_PHASE    = TARGET0_PHASE;
  parameter integer TARGET24_PHASE    = TARGET0_PHASE;
  parameter integer TARGET25_PHASE    = TARGET0_PHASE;
  parameter integer TARGET26_PHASE    = TARGET0_PHASE;
  parameter integer TARGET27_PHASE    = TARGET0_PHASE;
  parameter integer TARGET28_PHASE    = TARGET0_PHASE;
  parameter integer TARGET29_PHASE    = TARGET0_PHASE;
  parameter integer TARGET30_PHASE    = TARGET0_PHASE;
  parameter integer TARGET31_PHASE    = TARGET0_PHASE;


  //====================================================================
  // AXI4Initiator /Target  parameters
  //====================================================================

  parameter OPEN_MTTRANS_MAX         = OPEN_WRTRANS_MAX;      // max. number of outstanding transaction in InitiatorGen
  parameter OPEN_SLTRANS_MAX         = OPEN_WRTRANS_MAX;      // max. number of outstanding transaction in TargetGen

  parameter integer   NUM_AXITARGET_BITS     = 'd8;    // Defines lower bound of compare - bits below are dont care
  parameter integer  RNDEN         = 0;    // Enables (1) or Disables (0) randomising in the tests - if RREADY/WREADY idles cycles

  parameter [31:0] CNT_INIT = 0;

  //====================================================================
  // AHB Initiator parameters
  //====================================================================
  parameter AHB_AWIDTH = 32;
  parameter [7:0] UNDEF_BURST_INITIATOR0 = 8'hf;
  parameter [7:0] UNDEF_BURST_INITIATOR1 = 8'h1;
  parameter [7:0] UNDEF_BURST_INITIATOR2 = 8'h00;
  parameter [7:0] UNDEF_BURST_INITIATOR3 = 8'h0a;
  parameter [7:0] UNDEF_BURST_INITIATOR4 = 8'h11;
  parameter [7:0] UNDEF_BURST_INITIATOR5 = 8'h0f;
  parameter [7:0] UNDEF_BURST_INITIATOR6 = 8'hf;
  parameter [7:0] UNDEF_BURST_INITIATOR7 = 8'h1;
  
