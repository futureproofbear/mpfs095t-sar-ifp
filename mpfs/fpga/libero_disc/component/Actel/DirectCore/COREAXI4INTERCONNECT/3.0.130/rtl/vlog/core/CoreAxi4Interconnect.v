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
// SVN $Revision: 51339 $
// SVN $Date: 2026-04-26 06:25:24 -0400 (Sun, 26 Apr 2026) $
//
//
// *********************************************************************/

`timescale 1ns / 1ns

module COREAXI4INTERCONNECT #
(
   
   //=====================================================================
   // Global Parameters
   //=====================================================================
   
  parameter integer FAMILY                                 = 26,
  parameter         RESET_TYPE                             = 0,        // 0 - Asynchronous 1 - Synchronous
  parameter         PIPE                                   = 0,        // 0 - Async Read 1 - Non Pipeline Read
  parameter         EXPOSE_RST                             = 0,
    
  parameter integer NUM_INITIATORS                         = 4,        // defines number of initiator ports 
  parameter integer NUM_INITIATORS_WIDTH                   = 2,  
  parameter integer NUM_TARGETS                            = 8,        // defines number of targets

  parameter integer ID_WIDTH                               = 1,        // number of bits for ID (ie AID, WID, BID) - valid 1-8 
  parameter integer ADDR_WIDTH                             = 64,        // valid values - 16 - 64  
  parameter integer OPTIMIZATION                           = 1,

  //                                                       ====================================================================
  // Crossbar parameters
  //                                                       ====================================================================
  parameter integer DATA_WIDTH                             = 512,        // valid widths - 32, 64, 128

  parameter integer MAX_OUTSTNDG_TRANS                     = 1,        // max number of outstanding transactions per thread - valid range 1-8
    
  parameter integer ADDR_WIDTH_INT                         = 20,

  //SLOTy_START_ADDR parameter is added for each target

  parameter [ADDR_WIDTH_INT-1:0] TARGET0_START_ADDR        = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET1_START_ADDR        = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET2_START_ADDR        = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET3_START_ADDR        = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET4_START_ADDR        = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET5_START_ADDR        = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET6_START_ADDR        = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET7_START_ADDR        = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET8_START_ADDR        = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET9_START_ADDR        = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET10_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET11_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET12_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET13_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET14_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET15_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET16_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET17_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET18_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET19_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET20_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET21_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET22_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET23_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET24_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET25_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET26_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET27_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET28_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET29_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET30_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET31_START_ADDR       = {ADDR_WIDTH_INT{1'b0}},

  parameter [ADDR_WIDTH_INT-1:0] TARGET0_START_ADDR_UPPER  = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET1_START_ADDR_UPPER  = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET2_START_ADDR_UPPER  = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET3_START_ADDR_UPPER  = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET4_START_ADDR_UPPER  = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET5_START_ADDR_UPPER  = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET6_START_ADDR_UPPER  = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET7_START_ADDR_UPPER  = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET8_START_ADDR_UPPER  = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET9_START_ADDR_UPPER  = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET10_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET11_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET12_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET13_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET14_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET15_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET16_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET17_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET18_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET19_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET20_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET21_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET22_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET23_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET24_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET25_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET26_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET27_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET28_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET29_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET30_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET31_START_ADDR_UPPER = {ADDR_WIDTH_INT{1'b0}},
  
 //SLOTy_END_ADDR parameter is added for each target 
 
  parameter [ADDR_WIDTH_INT-1:0] TARGET0_END_ADDR          = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET1_END_ADDR          = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET2_END_ADDR          = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET3_END_ADDR          = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET4_END_ADDR          = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET5_END_ADDR          = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET6_END_ADDR          = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET7_END_ADDR          = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET8_END_ADDR          = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET9_END_ADDR          = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET10_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET11_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET12_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET13_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET14_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET15_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET16_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET17_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET18_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET19_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET20_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET21_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET22_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET23_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET24_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET25_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET26_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET27_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET28_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET29_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET30_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET31_END_ADDR         = {ADDR_WIDTH_INT{1'b0}},  
 
  
  parameter [ADDR_WIDTH_INT-1:0] TARGET0_END_ADDR_UPPER    = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET1_END_ADDR_UPPER    = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET2_END_ADDR_UPPER    = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET3_END_ADDR_UPPER    = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET4_END_ADDR_UPPER    = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET5_END_ADDR_UPPER    = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET6_END_ADDR_UPPER    = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET7_END_ADDR_UPPER    = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET8_END_ADDR_UPPER    = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET9_END_ADDR_UPPER    = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET10_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET11_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET12_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET13_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET14_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET15_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET16_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET17_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET18_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET19_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET20_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET21_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET22_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET23_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET24_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET25_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET26_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET27_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET28_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET29_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET30_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},
  parameter [ADDR_WIDTH_INT-1:0] TARGET31_END_ADDR_UPPER   = {ADDR_WIDTH_INT{1'b0}},  
  
  parameter integer USER_WIDTH                             = 32,        // defines the number of bits for USER signals RUSER and WUSER
  parameter integer CROSSBAR_MODE                          = 1,         // defines whether non-blocking (ie set 1) or shared access data path

  parameter [0:0]    INITIATOR0_WRITE_TARGET0              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET1              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET2              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET3              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET4              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET5              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET6              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET7              = 1'b1,      // bit for target indicating if a initiator can write to that port

  parameter [0:0]    INITIATOR0_WRITE_TARGET8              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET9              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET10             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET11             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET12             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET13             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET14             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET15             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET16             = 1'b1,      // bit for target indicating if a initiator can write to that port  
  parameter [0:0]    INITIATOR0_WRITE_TARGET17             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET18             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET19             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET20             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET21             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET22             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET23             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET24             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET25             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET26             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET27             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET28             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET29             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET30             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR0_WRITE_TARGET31             = 1'b1,      // bit for target indicating if a initiator can write to that port
            
  parameter [0:0]    INITIATOR1_WRITE_TARGET0              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET1              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET2              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET3              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET4              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET5              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET6              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET7              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET8              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET9              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET10             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET11             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET12             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET13             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET14             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET15             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET16             = 1'b1,      // bit for target indicating if a initiator can write to that port  
  parameter [0:0]    INITIATOR1_WRITE_TARGET17             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET18             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET19             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET20             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET21             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET22             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET23             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET24             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET25             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET26             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET27             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET28             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET29             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET30             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR1_WRITE_TARGET31             = 1'b1,      // bit for target indicating if a initiator can write to that port

  parameter [0:0]    INITIATOR2_WRITE_TARGET0              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET1              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET2              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET3              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET4              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET5              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET6              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET7              = 1'b1,      // bit for target indicating if a initiator can write to that port  

  parameter [0:0]    INITIATOR2_WRITE_TARGET8              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET9              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET10             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET11             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET12             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET13             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET14             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET15             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET16             = 1'b1,      // bit for target indicating if a initiator can write to that port  
  parameter [0:0]    INITIATOR2_WRITE_TARGET17             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET18             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET19             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET20             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET21             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET22             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET23             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET24             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET25             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET26             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET27             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET28             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET29             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET30             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR2_WRITE_TARGET31             = 1'b1,      // bit for target indicating if a initiator can write to that port
            
  parameter [0:0]    INITIATOR3_WRITE_TARGET0              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET1              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET2              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET3              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET4              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET5              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET6              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET7              = 1'b1,      // bit for target indicating if a initiator can write to that port  
  
  parameter [0:0]    INITIATOR3_WRITE_TARGET8              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET9              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET10             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET11             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET12             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET13             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET14             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET15             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET16             = 1'b1,      // bit for target indicating if a initiator can write to that port  
  parameter [0:0]    INITIATOR3_WRITE_TARGET17             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET18             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET19             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET20             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET21             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET22             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET23             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET24             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET25             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET26             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET27             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET28             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET29             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET30             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR3_WRITE_TARGET31             = 1'b1,      // bit for target indicating if a initiator can write to that port
            
  parameter [0:0]    INITIATOR4_WRITE_TARGET0              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET1              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET2              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET3              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET4              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET5              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET6              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET7              = 1'b1,      // bit for target indicating if a initiator can write to that port  

  parameter [0:0]    INITIATOR4_WRITE_TARGET8              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET9              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET10             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET11             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET12             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET13             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET14             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET15             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET16             = 1'b1,      // bit for target indicating if a initiator can write to that port  
  parameter [0:0]    INITIATOR4_WRITE_TARGET17             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET18             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET19             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET20             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET21             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET22             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET23             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET24             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET25             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET26             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET27             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET28             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET29             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET30             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR4_WRITE_TARGET31             = 1'b1,      // bit for target indicating if a initiator can write to that port
            
  parameter [0:0]    INITIATOR5_WRITE_TARGET0              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET1              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET2              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET3              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET4              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET5              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET6              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET7              = 1'b1,      // bit for target indicating if a initiator can write to that port  

  parameter [0:0]    INITIATOR5_WRITE_TARGET8              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET9              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET10             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET11             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET12             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET13             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET14             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET15             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET16             = 1'b1,      // bit for target indicating if a initiator can write to that port  
  parameter [0:0]    INITIATOR5_WRITE_TARGET17             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET18             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET19             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET20             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET21             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET22             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET23             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET24             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET25             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET26             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET27             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET28             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET29             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET30             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR5_WRITE_TARGET31             = 1'b1,      // bit for target indicating if a initiator can write to that port
            
  parameter [0:0]    INITIATOR6_WRITE_TARGET0              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET1              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET2              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET3              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET4              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET5              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET6              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET7              = 1'b1,      // bit for target indicating if a initiator can write to that port

  parameter [0:0]    INITIATOR6_WRITE_TARGET8              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET9              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET10             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET11             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET12             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET13             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET14             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET15             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET16             = 1'b1,      // bit for target indicating if a initiator can write to that port  
  parameter [0:0]    INITIATOR6_WRITE_TARGET17             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET18             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET19             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET20             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET21             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET22             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET23             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET24             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET25             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET26             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET27             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET28             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET29             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET30             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR6_WRITE_TARGET31             = 1'b1,      // bit for target indicating if a initiator can write to that port
              
  parameter [0:0]    INITIATOR7_WRITE_TARGET0              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET1              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET2              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET3              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET4              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET5              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET6              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET7              = 1'b1,      // bit for target indicating if a initiator can write to that port

  parameter [0:0]    INITIATOR7_WRITE_TARGET8              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET9              = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET10             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET11             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET12             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET13             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET14             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET15             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET16             = 1'b1,      // bit for target indicating if a initiator can write to that port  
  parameter [0:0]    INITIATOR7_WRITE_TARGET17             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET18             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET19             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET20             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET21             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET22             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET23             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET24             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET25             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET26             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET27             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET28             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET29             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET30             = 1'b1,      // bit for target indicating if a initiator can write to that port
  parameter [0:0]    INITIATOR7_WRITE_TARGET31             = 1'b1,      // bit for target indicating if a initiator can write to that port
  
  parameter [0:0]    INITIATOR8_WRITE_TARGET0              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET1              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET2              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET3              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET4              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET5              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET6              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET7              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR8_WRITE_TARGET8              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET9              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET10             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET11             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET12             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET13             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET14             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET15             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET16             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET17             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET18             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET19             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET20             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET21             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET22             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET23             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET24             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET25             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET26             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET27             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET28             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET29             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET30             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR8_WRITE_TARGET31             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR9_WRITE_TARGET0              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET1              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET2              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET3              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET4              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET5              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET6              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET7              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR9_WRITE_TARGET8              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET9              = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET10             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET11             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET12             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET13             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET14             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET15             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET16             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET17             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET18             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET19             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET20             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET21             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET22             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET23             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET24             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET25             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET26             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET27             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET28             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET29             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET30             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR9_WRITE_TARGET31             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR10_WRITE_TARGET0             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET1             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET2             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET3             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET4             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET5             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET6             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET7             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR10_WRITE_TARGET8             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET9             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET10            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET11            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET12            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET13            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET14            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET15            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET16            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET17            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET18            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET19            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET20            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET21            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET22            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET23            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET24            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET25            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET26            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET27            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET28            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET29            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET30            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR10_WRITE_TARGET31            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR11_WRITE_TARGET0             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET1             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET2             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET3             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET4             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET5             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET6             = 1'b1,     // bit for target indicating if a initiator can write to that port   
  parameter [0:0]    INITIATOR11_WRITE_TARGET7             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR11_WRITE_TARGET8             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET9             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET10            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET11            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET12            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET13            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET14            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET15            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET16            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET17            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET18            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET19            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET20            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET21            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET22            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET23            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET24            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET25            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET26            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET27            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET28            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET29            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET30            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR11_WRITE_TARGET31            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR12_WRITE_TARGET0             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET1             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET2             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET3             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET4             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET5             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET6             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET7             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR12_WRITE_TARGET8             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET9             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET10            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET11            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET12            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET13            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET14            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET15            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET16            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET17            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET18            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET19            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET20            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET21            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET22            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET23            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET24            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET25            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET26            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET27            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET28            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET29            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET30            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR12_WRITE_TARGET31            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR13_WRITE_TARGET0             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET1             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET2             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET3             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET4             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET5             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET6             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET7             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR13_WRITE_TARGET8             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET9             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET10            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET11            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET12            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET13            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET14            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET15            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET16            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET17            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET18            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET19            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET20            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET21            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET22            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET23            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET24            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET25            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET26            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET27            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET28            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET29            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET30            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR13_WRITE_TARGET31            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR14_WRITE_TARGET0             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET1             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET2             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET3             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET4             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET5             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET6             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET7             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR14_WRITE_TARGET8             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET9             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET10            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET11            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET12            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET13            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET14            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET15            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET16            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET17            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET18            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET19            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET20            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET21            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET22            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET23            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET24            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET25            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET26            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET27            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET28            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET29            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET30            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR14_WRITE_TARGET31            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR15_WRITE_TARGET0             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET1             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET2             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET3             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET4             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET5             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET6             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET7             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  
  parameter [0:0]    INITIATOR15_WRITE_TARGET8             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET9             = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET10            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET11            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET12            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET13            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET14            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET15            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET16            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET17            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET18            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET19            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET20            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET21            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET22            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET23            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET24            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET25            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET26            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET27            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET28            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET29            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET30            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  parameter [0:0]    INITIATOR15_WRITE_TARGET31            = 1'b1,     // bit for target indicating if a initiator can write to that port 
  

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////              

  parameter [0:0]    INITIATOR0_READ_TARGET0               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET1               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET2               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET3               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET4               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET5               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET6               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET7               = 1'b1,      // bit for target indicating if a initiator can read to that port

  parameter [0:0]    INITIATOR0_READ_TARGET8               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET9               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET10              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET11              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET12              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET13              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET14              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET15              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET16              = 1'b1,      // bit for target indicating if a initiator can read to that port  
  parameter [0:0]    INITIATOR0_READ_TARGET17              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET18              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET19              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET20              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET21              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET22              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET23              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET24              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET25              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET26              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET27              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET28              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET29              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET30              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR0_READ_TARGET31              = 1'b1,      // bit for target indicating if a initiator can read to that port

  
  parameter [0:0]    INITIATOR1_READ_TARGET0               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET1               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET2               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET3               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET4               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET5               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET6               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET7               = 1'b1,      // bit for target indicating if a initiator can read to that port

  parameter [0:0]    INITIATOR1_READ_TARGET8               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET9               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET10              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET11              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET12              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET13              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET14              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET15              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET16              = 1'b1,      // bit for target indicating if a initiator can read to that port  
  parameter [0:0]    INITIATOR1_READ_TARGET17              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET18              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET19              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET20              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET21              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET22              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET23              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET24              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET25              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET26              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET27              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET28              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET29              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET30              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR1_READ_TARGET31              = 1'b1,      // bit for target indicating if a initiator can read to that port

  
  parameter [0:0]    INITIATOR2_READ_TARGET0               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET1               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET2               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET3               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET4               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET5               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET6               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET7               = 1'b1,      // bit for target indicating if a initiator can read to that port  

  parameter [0:0]    INITIATOR2_READ_TARGET8               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET9               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET10              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET11              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET12              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET13              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET14              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET15              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET16              = 1'b1,      // bit for target indicating if a initiator can read to that port  
  parameter [0:0]    INITIATOR2_READ_TARGET17              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET18              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET19              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET20              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET21              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET22              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET23              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET24              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET25              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET26              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET27              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET28              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET29              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET30              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR2_READ_TARGET31              = 1'b1,      // bit for target indicating if a initiator can read to that port     

  
  parameter [0:0]    INITIATOR3_READ_TARGET0               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET1               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET2               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET3               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET4               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET5               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET6               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET7               = 1'b1,      // bit for target indicating if a initiator can read to that port  

  parameter [0:0]    INITIATOR3_READ_TARGET8               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET9               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET10              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET11              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET12              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET13              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET14              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET15              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET16              = 1'b1,      // bit for target indicating if a initiator can read to that port  
  parameter [0:0]    INITIATOR3_READ_TARGET17              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET18              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET19              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET20              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET21              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET22              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET23              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET24              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET25              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET26              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET27              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET28              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET29              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET30              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR3_READ_TARGET31              = 1'b1,      // bit for target indicating if a initiator can read to that port 

  
  parameter [0:0]    INITIATOR4_READ_TARGET0               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET1               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET2               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET3               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET4               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET5               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET6               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET7               = 1'b1,      // bit for target indicating if a initiator can read to that port  

  parameter [0:0]    INITIATOR4_READ_TARGET8               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET9               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET10              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET11              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET12              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET13              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET14              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET15              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET16              = 1'b1,      // bit for target indicating if a initiator can read to that port  
  parameter [0:0]    INITIATOR4_READ_TARGET17              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET18              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET19              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET20              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET21              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET22              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET23              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET24              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET25              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET26              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET27              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET28              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET29              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET30              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR4_READ_TARGET31              = 1'b1,      // bit for target indicating if a initiator can read to that port 

  
  parameter [0:0]    INITIATOR5_READ_TARGET0               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET1               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET2               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET3               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET4               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET5               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET6               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET7               = 1'b1,      // bit for target indicating if a initiator can read to that port  

  parameter [0:0]    INITIATOR5_READ_TARGET8               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET9               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET10              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET11              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET12              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET13              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET14              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET15              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET16              = 1'b1,      // bit for target indicating if a initiator can read to that port  
  parameter [0:0]    INITIATOR5_READ_TARGET17              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET18              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET19              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET20              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET21              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET22              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET23              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET24              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET25              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET26              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET27              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET28              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET29              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET30              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR5_READ_TARGET31              = 1'b1,      // bit for target indicating if a initiator can read to that port 

  
  parameter [0:0]    INITIATOR6_READ_TARGET0               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET1               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET2               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET3               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET4               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET5               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET6               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET7               = 1'b1,      // bit for target indicating if a initiator can read to that port

  parameter [0:0]    INITIATOR6_READ_TARGET8               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET9               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET10              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET11              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET12              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET13              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET14              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET15              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET16              = 1'b1,      // bit for target indicating if a initiator can read to that port  
  parameter [0:0]    INITIATOR6_READ_TARGET17              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET18              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET19              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET20              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET21              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET22              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET23              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET24              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET25              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET26              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET27              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET28              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET29              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET30              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR6_READ_TARGET31              = 1'b1,      // bit for target indicating if a initiator can read to that port 

  
  parameter [0:0]    INITIATOR7_READ_TARGET0               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET1               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET2               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET3               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET4               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET5               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET6               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET7               = 1'b1,      // bit for target indicating if a initiator can read to that port

  parameter [0:0]    INITIATOR7_READ_TARGET8               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET9               = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET10              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET11              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET12              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET13              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET14              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET15              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET16              = 1'b1,      // bit for target indicating if a initiator can read to that port  
  parameter [0:0]    INITIATOR7_READ_TARGET17              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET18              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET19              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET20              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET21              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET22              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET23              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET24              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET25              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET26              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET27              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET28              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET29              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET30              = 1'b1,      // bit for target indicating if a initiator can read to that port
  parameter [0:0]    INITIATOR7_READ_TARGET31              = 1'b1,      // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR8_READ_TARGET0               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET1               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET2               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET3               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET4               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET5               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET6               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET7               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR8_READ_TARGET8               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET9               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET10              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET11              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET12              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET13              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET14              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET15              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET16              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET17              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET18              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET19              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET20              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET21              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET22              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET23              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET24              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET25              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET26              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET27              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET28              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET29              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET30              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR8_READ_TARGET31              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR9_READ_TARGET0               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET1               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET2               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET3               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET4               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET5               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET6               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET7               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR9_READ_TARGET8               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET9               = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET10              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET11              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET12              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET13              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET14              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET15              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET16              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET17              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET18              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET19              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET20              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET21              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET22              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET23              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET24              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET25              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET26              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET27              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET28              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET29              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET30              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR9_READ_TARGET31              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR10_READ_TARGET0              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET1              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET2              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET3              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET4              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET5              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET6              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET7              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR10_READ_TARGET8              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET9              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET10             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET11             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET12             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET13             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET14             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET15             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET16             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET17             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET18             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET19             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET20             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET21             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET22             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET23             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET24             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET25             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET26             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET27             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET28             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET29             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET30             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR10_READ_TARGET31             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR11_READ_TARGET0              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET1              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET2              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET3              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET4              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET5              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET6              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET7              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR11_READ_TARGET8              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET9              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET10             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET11             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET12             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET13             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET14             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET15             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET16             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET17             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET18             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET19             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET20             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET21             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET22             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET23             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET24             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET25             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET26             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET27             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET28             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET29             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET30             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR11_READ_TARGET31             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR12_READ_TARGET0              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET1              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET2              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET3              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET4              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET5              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET6              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET7              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR12_READ_TARGET8              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET9              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET10             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET11             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET12             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET13             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET14             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET15             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET16             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET17             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET18             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET19             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET20             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET21             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET22             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET23             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET24             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET25             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET26             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET27             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET28             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET29             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET30             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR12_READ_TARGET31             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR13_READ_TARGET0              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET1              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET2              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET3              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET4              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET5              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET6              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET7              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR13_READ_TARGET8              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET9              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET10             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET11             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET12             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET13             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET14             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET15             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET16             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET17             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET18             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET19             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET20             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET21             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET22             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET23             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET24             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET25             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET26             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET27             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET28             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET29             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET30             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR13_READ_TARGET31             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR14_READ_TARGET0              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET1              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET2              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET3              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET4              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET5              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET6              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET7              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR14_READ_TARGET8              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET9              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET10             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET11             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET12             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET13             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET14             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET15             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET16             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET17             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET18             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET19             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET20             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET21             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET22             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET23             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET24             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET25             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET26             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET27             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET28             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET29             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET30             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR14_READ_TARGET31             = 1'b1,     // bit for target indicating if a initiator can read to that port .
  
  parameter [0:0]    INITIATOR15_READ_TARGET0              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET1              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET2              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET3              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET4              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET5              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET6              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET7              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  
  parameter [0:0]    INITIATOR15_READ_TARGET8              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET9              = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET10             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET11             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET12             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET13             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET14             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET15             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET16             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET17             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET18             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET19             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET20             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET21             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET22             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET23             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET24             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET25             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET26             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET27             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET28             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET29             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET30             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  parameter [0:0]    INITIATOR15_READ_TARGET31             = 1'b1,     // bit for target indicating if a initiator can read to that port 
  

  parameter  RD_ARB_EN                                     = 1'b0,        // select arb or ordered rdata

  parameter [0:0]  INITIATOR0_CLOCK_DOMAIN_CROSSING        = 1'b1,  
  parameter [0:0]  INITIATOR1_CLOCK_DOMAIN_CROSSING        = 1'b1,  
  parameter [0:0]  INITIATOR2_CLOCK_DOMAIN_CROSSING        = 1'b1,  
  parameter [0:0]  INITIATOR3_CLOCK_DOMAIN_CROSSING        = 1'b1,  
  parameter [0:0]  INITIATOR4_CLOCK_DOMAIN_CROSSING        = 1'b1,  
  parameter [0:0]  INITIATOR5_CLOCK_DOMAIN_CROSSING        = 1'b1,  
  parameter [0:0]  INITIATOR6_CLOCK_DOMAIN_CROSSING        = 1'b1,  
  parameter [0:0]  INITIATOR7_CLOCK_DOMAIN_CROSSING        = 1'b1,    
  parameter [0:0]  INITIATOR8_CLOCK_DOMAIN_CROSSING        = 1'b0,
  parameter [0:0]  INITIATOR9_CLOCK_DOMAIN_CROSSING        = 1'b0,
  parameter [0:0]  INITIATOR10_CLOCK_DOMAIN_CROSSING       = 1'b0,
  parameter [0:0]  INITIATOR11_CLOCK_DOMAIN_CROSSING       = 1'b0,
  parameter [0:0]  INITIATOR12_CLOCK_DOMAIN_CROSSING       = 1'b0,
  parameter [0:0]  INITIATOR13_CLOCK_DOMAIN_CROSSING       = 1'b0,
  parameter [0:0]  INITIATOR14_CLOCK_DOMAIN_CROSSING       = 1'b0,
  parameter [0:0]  INITIATOR15_CLOCK_DOMAIN_CROSSING       = 1'b0,

  parameter [0:0]  INITIATOR0_CDC_PLACEMENT                = 1'b1,  
  parameter [0:0]  INITIATOR1_CDC_PLACEMENT                = 1'b0,  
  parameter [0:0]  INITIATOR2_CDC_PLACEMENT                = 1'b0,  
  parameter [0:0]  INITIATOR3_CDC_PLACEMENT                = 1'b0,  
  parameter [0:0]  INITIATOR4_CDC_PLACEMENT                = 1'b1,  
  parameter [0:0]  INITIATOR5_CDC_PLACEMENT                = 1'b1,  
  parameter [0:0]  INITIATOR6_CDC_PLACEMENT                = 1'b1,  
  parameter [0:0]  INITIATOR7_CDC_PLACEMENT                = 1'b1,    
  parameter [0:0]  INITIATOR8_CDC_PLACEMENT                = 1'b0,
  parameter [0:0]  INITIATOR9_CDC_PLACEMENT                = 1'b0,
  parameter [0:0]  INITIATOR10_CDC_PLACEMENT               = 1'b0,
  parameter [0:0]  INITIATOR11_CDC_PLACEMENT               = 1'b0,
  parameter [0:0]  INITIATOR12_CDC_PLACEMENT               = 1'b0,
  parameter [0:0]  INITIATOR13_CDC_PLACEMENT               = 1'b0,
  parameter [0:0]  INITIATOR14_CDC_PLACEMENT               = 1'b0,
  parameter [0:0]  INITIATOR15_CDC_PLACEMENT               = 1'b0,
  
  parameter integer  INITIATOR0_CDC_FIFO_DEPTH             = 1,  
  parameter integer  INITIATOR1_CDC_FIFO_DEPTH             = 1,  
  parameter integer  INITIATOR2_CDC_FIFO_DEPTH             = 16,  
  parameter integer  INITIATOR3_CDC_FIFO_DEPTH             = 16,  
  parameter integer  INITIATOR4_CDC_FIFO_DEPTH             = 16,  
  parameter integer  INITIATOR5_CDC_FIFO_DEPTH             = 16,  
  parameter integer  INITIATOR6_CDC_FIFO_DEPTH             = 16,  
  parameter integer  INITIATOR7_CDC_FIFO_DEPTH             = 16,    
  parameter integer  INITIATOR8_CDC_FIFO_DEPTH             = 16,
  parameter integer  INITIATOR9_CDC_FIFO_DEPTH             = 16,
  parameter integer  INITIATOR10_CDC_FIFO_DEPTH            = 16,
  parameter integer  INITIATOR11_CDC_FIFO_DEPTH            = 16,
  parameter integer  INITIATOR12_CDC_FIFO_DEPTH            = 16,
  parameter integer  INITIATOR13_CDC_FIFO_DEPTH            = 16,
  parameter integer  INITIATOR14_CDC_FIFO_DEPTH            = 16,
  parameter integer  INITIATOR15_CDC_FIFO_DEPTH            = 16,

  parameter integer  INITIATOR0_CDC_ADDR_RESP_FIFO_DEPTH   = 1,  
  parameter integer  INITIATOR1_CDC_ADDR_RESP_FIFO_DEPTH   = 1,  
  parameter integer  INITIATOR2_CDC_ADDR_RESP_FIFO_DEPTH   = 1,  
  parameter integer  INITIATOR3_CDC_ADDR_RESP_FIFO_DEPTH   = 32,  
  parameter integer  INITIATOR4_CDC_ADDR_RESP_FIFO_DEPTH   = 32,  
  parameter integer  INITIATOR5_CDC_ADDR_RESP_FIFO_DEPTH   = 32,  
  parameter integer  INITIATOR6_CDC_ADDR_RESP_FIFO_DEPTH   = 32,  
  parameter integer  INITIATOR7_CDC_ADDR_RESP_FIFO_DEPTH   = 32,    
  parameter integer  INITIATOR8_CDC_ADDR_RESP_FIFO_DEPTH   = 32,
  parameter integer  INITIATOR9_CDC_ADDR_RESP_FIFO_DEPTH   = 32,
  parameter integer  INITIATOR10_CDC_ADDR_RESP_FIFO_DEPTH  = 32,
  parameter integer  INITIATOR11_CDC_ADDR_RESP_FIFO_DEPTH  = 32,
  parameter integer  INITIATOR12_CDC_ADDR_RESP_FIFO_DEPTH  = 32,
  parameter integer  INITIATOR13_CDC_ADDR_RESP_FIFO_DEPTH  = 32,
  parameter integer  INITIATOR14_CDC_ADDR_RESP_FIFO_DEPTH  = 32,
  parameter integer  INITIATOR15_CDC_ADDR_RESP_FIFO_DEPTH  = 32,
  
  
  parameter [0:0]  TARGET0_CLOCK_DOMAIN_CROSSING           = 1'b0,  
  parameter [0:0]  TARGET1_CLOCK_DOMAIN_CROSSING           = 1'b0,  
  parameter [0:0]  TARGET2_CLOCK_DOMAIN_CROSSING           = 1'b0,  
  parameter [0:0]  TARGET3_CLOCK_DOMAIN_CROSSING           = 1'b0,
  parameter [0:0]  TARGET4_CLOCK_DOMAIN_CROSSING           = 1'b0,  
  parameter [0:0]  TARGET5_CLOCK_DOMAIN_CROSSING           = 1'b0,  
  parameter [0:0]  TARGET6_CLOCK_DOMAIN_CROSSING           = 1'b0,  
  parameter [0:0]  TARGET7_CLOCK_DOMAIN_CROSSING           = 1'b0,
  parameter [0:0]  TARGET8_CLOCK_DOMAIN_CROSSING           = 1'b0,
  parameter [0:0]  TARGET9_CLOCK_DOMAIN_CROSSING           = 1'b0,
  parameter [0:0]  TARGET10_CLOCK_DOMAIN_CROSSING          = 1'b0,
  parameter [0:0]  TARGET11_CLOCK_DOMAIN_CROSSING          = 1'b0,
  parameter [0:0]  TARGET12_CLOCK_DOMAIN_CROSSING          = 1'b0,
  parameter [0:0]  TARGET13_CLOCK_DOMAIN_CROSSING          = 1'b0,
  parameter [0:0]  TARGET14_CLOCK_DOMAIN_CROSSING          = 1'b0,
  parameter [0:0]  TARGET15_CLOCK_DOMAIN_CROSSING          = 1'b0,
  parameter [0:0]  TARGET16_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET17_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET18_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET19_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET20_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET21_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET22_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET23_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET24_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET25_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET26_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET27_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET28_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET29_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET30_CLOCK_DOMAIN_CROSSING          = 1'b1,
  parameter [0:0]  TARGET31_CLOCK_DOMAIN_CROSSING          = 1'b1,

  parameter [0:0]  TARGET0_CDC_PLACEMENT                   = 1'b0,  
  parameter [0:0]  TARGET1_CDC_PLACEMENT                   = 1'b0,  
  parameter [0:0]  TARGET2_CDC_PLACEMENT                   = 1'b0,  
  parameter [0:0]  TARGET3_CDC_PLACEMENT                   = 1'b0,
  parameter [0:0]  TARGET4_CDC_PLACEMENT                   = 1'b0,  
  parameter [0:0]  TARGET5_CDC_PLACEMENT                   = 1'b0,  
  parameter [0:0]  TARGET6_CDC_PLACEMENT                   = 1'b0,  
  parameter [0:0]  TARGET7_CDC_PLACEMENT                   = 1'b0,
  parameter [0:0]  TARGET8_CDC_PLACEMENT                   = 1'b0,
  parameter [0:0]  TARGET9_CDC_PLACEMENT                   = 1'b0,
  parameter [0:0]  TARGET10_CDC_PLACEMENT                  = 1'b0,
  parameter [0:0]  TARGET11_CDC_PLACEMENT                  = 1'b0,
  parameter [0:0]  TARGET12_CDC_PLACEMENT                  = 1'b0,
  parameter [0:0]  TARGET13_CDC_PLACEMENT                  = 1'b0,
  parameter [0:0]  TARGET14_CDC_PLACEMENT                  = 1'b0,
  parameter [0:0]  TARGET15_CDC_PLACEMENT                  = 1'b0,
  parameter [0:0]  TARGET16_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET17_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET18_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET19_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET20_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET21_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET22_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET23_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET24_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET25_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET26_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET27_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET28_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET29_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET30_CDC_PLACEMENT                  = 1'b1,
  parameter [0:0]  TARGET31_CDC_PLACEMENT                  = 1'b1,

  parameter        TARGET0_CDC_FIFO_DEPTH                  = 16,  
  parameter        TARGET1_CDC_FIFO_DEPTH                  = 16,  
  parameter        TARGET2_CDC_FIFO_DEPTH                  = 16,  
  parameter        TARGET3_CDC_FIFO_DEPTH                  = 16,
  parameter        TARGET4_CDC_FIFO_DEPTH                  = 16,  
  parameter        TARGET5_CDC_FIFO_DEPTH                  = 16,  
  parameter        TARGET6_CDC_FIFO_DEPTH                  = 16,  
  parameter        TARGET7_CDC_FIFO_DEPTH                  = 16,
  parameter        TARGET8_CDC_FIFO_DEPTH                  = 16,
  parameter        TARGET9_CDC_FIFO_DEPTH                  = 16,
  parameter        TARGET10_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET11_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET12_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET13_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET14_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET15_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET16_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET17_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET18_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET19_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET20_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET21_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET22_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET23_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET24_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET25_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET26_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET27_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET28_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET29_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET30_CDC_FIFO_DEPTH                 = 16,
  parameter        TARGET31_CDC_FIFO_DEPTH                 = 16,


  parameter        TARGET0_CDC_ADDR_RESP_FIFO_DEPTH        = 32,  
  parameter        TARGET1_CDC_ADDR_RESP_FIFO_DEPTH        = 32,  
  parameter        TARGET2_CDC_ADDR_RESP_FIFO_DEPTH        = 32,  
  parameter        TARGET3_CDC_ADDR_RESP_FIFO_DEPTH        = 32,
  parameter        TARGET4_CDC_ADDR_RESP_FIFO_DEPTH        = 32,  
  parameter        TARGET5_CDC_ADDR_RESP_FIFO_DEPTH        = 32,  
  parameter        TARGET6_CDC_ADDR_RESP_FIFO_DEPTH        = 32,  
  parameter        TARGET7_CDC_ADDR_RESP_FIFO_DEPTH        = 32,
  parameter        TARGET8_CDC_ADDR_RESP_FIFO_DEPTH        = 32,
  parameter        TARGET9_CDC_ADDR_RESP_FIFO_DEPTH        = 32,
  parameter        TARGET10_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET11_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET12_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET13_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET14_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET15_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET16_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET17_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET18_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET19_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET20_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET21_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET22_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET23_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET24_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET25_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET26_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET27_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET28_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET29_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET30_CDC_ADDR_RESP_FIFO_DEPTH       = 32,
  parameter        TARGET31_CDC_ADDR_RESP_FIFO_DEPTH       = 32,

  //                                                       ====================================================================
  // Port Protocol Convertor / Data Width Convertor parameters
  //                                                       ====================================================================
  parameter [1:0] INITIATOR0_TYPE                          = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] INITIATOR1_TYPE                          = 2'b01,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] INITIATOR2_TYPE                          = 2'b11,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] INITIATOR3_TYPE                          = 2'b10,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] INITIATOR4_TYPE                          = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] INITIATOR5_TYPE                          = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] INITIATOR6_TYPE                          = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] INITIATOR7_TYPE                          = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3  
  parameter [1:0] INITIATOR8_TYPE                          = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3  
  parameter [1:0] INITIATOR9_TYPE                          = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3  
  parameter [1:0] INITIATOR10_TYPE                         = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3  
  parameter [1:0] INITIATOR11_TYPE                         = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3  
  parameter [1:0] INITIATOR12_TYPE                         = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3  
  parameter [1:0] INITIATOR13_TYPE                         = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3  
  parameter [1:0] INITIATOR14_TYPE                         = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3  
  parameter [1:0] INITIATOR15_TYPE                         = 2'b00,   // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3  

  parameter [1:0] TARGET0_TYPE                             = 2'b00,      // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET1_TYPE                             = 2'b01,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET2_TYPE                             = 2'b11,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET3_TYPE                             = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET4_TYPE                             = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET5_TYPE                             = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET6_TYPE                             = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET7_TYPE                             = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET8_TYPE                             = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET9_TYPE                             = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET10_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET11_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET12_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET13_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET14_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET15_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET16_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET17_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET18_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET19_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET20_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET21_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET22_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET23_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET24_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET25_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET26_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET27_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET28_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET29_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET30_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  parameter [1:0] TARGET31_TYPE                            = 2'b00,    // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3  

  parameter  [31:0] INITIATOR0_DATA_WIDTH                  =  32,      // Defines data width of INITIATOR0
  parameter  [31:0] INITIATOR1_DATA_WIDTH                  =  64,      // Defines data width of INITIATOR1
  parameter  [31:0] INITIATOR2_DATA_WIDTH                  =  128,      // Defines data width of INITIATOR2
  parameter  [31:0] INITIATOR3_DATA_WIDTH                  =  256,      // Defines data width of INITIATOR3
  parameter  [31:0] INITIATOR4_DATA_WIDTH                  =  512,      // Defines data width of INITIATOR4
  parameter  [31:0] INITIATOR5_DATA_WIDTH                  =  32,      // Defines data width of INITIATOR5
  parameter  [31:0] INITIATOR6_DATA_WIDTH                  =  32,      // Defines data width of INITIATOR6
  parameter  [31:0] INITIATOR7_DATA_WIDTH                  =  32,      // Defines data width of INITIATOR7
  parameter  [31:0] INITIATOR8_DATA_WIDTH                  =  32,      // Defines data width of INITIATOR8
  parameter  [31:0] INITIATOR9_DATA_WIDTH                  =  32,      // Defines data width of INITIATOR9
  parameter  [31:0] INITIATOR10_DATA_WIDTH                 =  32,      // Defines data width of INITIATOR10
  parameter  [31:0] INITIATOR11_DATA_WIDTH                 =  32,      // Defines data width of INITIATOR11
  parameter  [31:0] INITIATOR12_DATA_WIDTH                 =  32,      // Defines data width of INITIATOR12
  parameter  [31:0] INITIATOR13_DATA_WIDTH                 =  32,      // Defines data width of INITIATOR13
  parameter  [31:0] INITIATOR14_DATA_WIDTH                 =  32,      // Defines data width of INITIATOR14
  parameter  [31:0] INITIATOR15_DATA_WIDTH                 =  32,      // Defines data width of INITIATOR15
  
  parameter  [31:0] TARGET0_DATA_WIDTH                     =  32,      // Defines data width of Target0
  parameter  [31:0] TARGET1_DATA_WIDTH                     =  64,      // Defines data width of Target1
  parameter  [31:0] TARGET2_DATA_WIDTH                     =  128,      // Defines data width of Target2
  parameter  [31:0] TARGET3_DATA_WIDTH                     =  256,      // Defines data width of Target3
  parameter  [31:0] TARGET4_DATA_WIDTH                     =  512,      // Defines data width of Target4
  parameter  [31:0] TARGET5_DATA_WIDTH                     =  32,      // Defines data width of Target5
  parameter  [31:0] TARGET6_DATA_WIDTH                     =  32,      // Defines data width of Target6
  parameter  [31:0] TARGET7_DATA_WIDTH                     =  32,      // Defines data width of Target7
  parameter  [31:0] TARGET8_DATA_WIDTH                     =  32,      // Defines data width of Target8
  parameter  [31:0] TARGET9_DATA_WIDTH                     =  32,      // Defines data width of Target9
  parameter  [31:0] TARGET10_DATA_WIDTH                    =  32,      // Defines data width of Target10
  parameter  [31:0] TARGET11_DATA_WIDTH                    =  32,      // Defines data width of Target11
  parameter  [31:0] TARGET12_DATA_WIDTH                    =  32,      // Defines data width of Target12
  parameter  [31:0] TARGET13_DATA_WIDTH                    =  32,      // Defines data width of Target13
  parameter  [31:0] TARGET14_DATA_WIDTH                    =  32,      // Defines data width of Target14
  parameter  [31:0] TARGET15_DATA_WIDTH                    =  32,      // Defines data width of Target15
  parameter  [31:0] TARGET16_DATA_WIDTH                    =  32,      // Defines data width of Target16
  parameter  [31:0] TARGET17_DATA_WIDTH                    =  32,      // Defines data width of Target17
  parameter  [31:0] TARGET18_DATA_WIDTH                    =  32,      // Defines data width of Target18
  parameter  [31:0] TARGET19_DATA_WIDTH                    =  32,      // Defines data width of Target19
  parameter  [31:0] TARGET20_DATA_WIDTH                    =  32,      // Defines data width of Target20
  parameter  [31:0] TARGET21_DATA_WIDTH                    =  32,      // Defines data width of Target21
  parameter  [31:0] TARGET22_DATA_WIDTH                    =  32,      // Defines data width of Target22
  parameter  [31:0] TARGET23_DATA_WIDTH                    =  32,      // Defines data width of Target23
  parameter  [31:0] TARGET24_DATA_WIDTH                    =  32,      // Defines data width of Target24
  parameter  [31:0] TARGET25_DATA_WIDTH                    =  32,      // Defines data width of Target25
  parameter  [31:0] TARGET26_DATA_WIDTH                    =  32,      // Defines data width of Target26
  parameter  [31:0] TARGET27_DATA_WIDTH                    =  32,      // Defines data width of Target27
  parameter  [31:0] TARGET28_DATA_WIDTH                    =  32,      // Defines data width of Target28
  parameter  [31:0] TARGET29_DATA_WIDTH                    =  32,      // Defines data width of Target29
  parameter  [31:0] TARGET30_DATA_WIDTH                    =  32,      // Defines data width of Target30
  parameter  [31:0] TARGET31_DATA_WIDTH                    =  32,      // Defines data width of Target31
  
  parameter integer  TRGT_AXI4PRT_ADDRDEPTH                = 4,          // Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
  parameter integer  TRGT_AXI4PRT_DATADEPTH                = 4,          // Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
  
  //                                                       ====================================================================
  // Register Slice parameters
  //                                                       ====================================================================
  parameter [0:0] INITIATOR0_CHAN_RS                       = 1'b1,
  parameter [0:0] INITIATOR1_CHAN_RS                       = 1'b1,
  parameter [0:0] INITIATOR2_CHAN_RS                       = 1'b1,
  parameter [0:0] INITIATOR3_CHAN_RS                       = 1'b1,
  parameter [0:0] INITIATOR4_CHAN_RS                       = 1'b1,
  parameter [0:0] INITIATOR5_CHAN_RS                       = 1'b1,
  parameter [0:0] INITIATOR6_CHAN_RS                       = 1'b1,
  parameter [0:0] INITIATOR7_CHAN_RS                       = 1'b1,
  parameter [0:0] INITIATOR8_CHAN_RS                       = 1'b1,
  parameter [0:0] INITIATOR9_CHAN_RS                       = 1'b1,
  parameter [0:0] INITIATOR10_CHAN_RS                      = 1'b1,
  parameter [0:0] INITIATOR11_CHAN_RS                      = 1'b1,
  parameter [0:0] INITIATOR12_CHAN_RS                      = 1'b1,
  parameter [0:0] INITIATOR13_CHAN_RS                      = 1'b1,
  parameter [0:0] INITIATOR14_CHAN_RS                      = 1'b1,
  parameter [0:0] INITIATOR15_CHAN_RS                      = 1'b1,
  
  parameter [0:0] TARGET0_CHAN_RS                          = 1'b1,
  parameter [0:0] TARGET1_CHAN_RS                          = 1'b1,
  parameter [0:0] TARGET2_CHAN_RS                          = 1'b1,
  parameter [0:0] TARGET3_CHAN_RS                          = 1'b1,
  parameter [0:0] TARGET4_CHAN_RS                          = 1'b1,
  parameter [0:0] TARGET5_CHAN_RS                          = 1'b1,
  parameter [0:0] TARGET6_CHAN_RS                          = 1'b1,
  parameter [0:0] TARGET7_CHAN_RS                          = 1'b1,
  parameter [0:0] TARGET8_CHAN_RS                          = 1'b1,
  parameter [0:0] TARGET9_CHAN_RS                          = 1'b1,
  parameter [0:0] TARGET10_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET11_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET12_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET13_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET14_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET15_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET16_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET17_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET18_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET19_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET20_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET21_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET22_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET23_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET24_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET25_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET26_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET27_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET28_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET29_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET30_CHAN_RS                         = 1'b1,
  parameter [0:0] TARGET31_CHAN_RS                         = 1'b1,  

  parameter  [13:0] TARGET0_DWC_DATA_FIFO_DEPTH            =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target0
  parameter  [13:0] TARGET1_DWC_DATA_FIFO_DEPTH            =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target1
  parameter  [13:0] TARGET2_DWC_DATA_FIFO_DEPTH            =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target2
  parameter  [13:0] TARGET3_DWC_DATA_FIFO_DEPTH            =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target3
  parameter  [13:0] TARGET4_DWC_DATA_FIFO_DEPTH            =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target4
  parameter  [13:0] TARGET5_DWC_DATA_FIFO_DEPTH            =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target5
  parameter  [13:0] TARGET6_DWC_DATA_FIFO_DEPTH            =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target6
  parameter  [13:0] TARGET7_DWC_DATA_FIFO_DEPTH            =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target7
  
  parameter  [13:0] TARGET8_DWC_DATA_FIFO_DEPTH            =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target8
  parameter  [13:0] TARGET9_DWC_DATA_FIFO_DEPTH            =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target9
  parameter  [13:0] TARGET10_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target10
  parameter  [13:0] TARGET11_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target11
  parameter  [13:0] TARGET12_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target12
  parameter  [13:0] TARGET13_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target13
  parameter  [13:0] TARGET14_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target14
  parameter  [13:0] TARGET15_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target15
  parameter  [13:0] TARGET16_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target16
  parameter  [13:0] TARGET17_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target17
  parameter  [13:0] TARGET18_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target18
  parameter  [13:0] TARGET19_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target19
  parameter  [13:0] TARGET20_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target20
  parameter  [13:0] TARGET21_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target21
  parameter  [13:0] TARGET22_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target22
  parameter  [13:0] TARGET23_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target23
  parameter  [13:0] TARGET24_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target24
  parameter  [13:0] TARGET25_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target25
  parameter  [13:0] TARGET26_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target26
  parameter  [13:0] TARGET27_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target27
  parameter  [13:0] TARGET28_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target28
  parameter  [13:0] TARGET29_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target29
  parameter  [13:0] TARGET30_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target30
  parameter  [13:0] TARGET31_DWC_DATA_FIFO_DEPTH           =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of Target31

  parameter [0:0] TARGET0_DWC_CHAN_RS                      = 1'b0,
  parameter [0:0] TARGET1_DWC_CHAN_RS                      = 1'b0,
  parameter [0:0] TARGET2_DWC_CHAN_RS                      = 1'b0,
  parameter [0:0] TARGET3_DWC_CHAN_RS                      = 1'b0,
  parameter [0:0] TARGET4_DWC_CHAN_RS                      = 1'b0,
  parameter [0:0] TARGET5_DWC_CHAN_RS                      = 1'b0,
  parameter [0:0] TARGET6_DWC_CHAN_RS                      = 1'b0,
  parameter [0:0] TARGET7_DWC_CHAN_RS                      = 1'b0,
  parameter [0:0] TARGET8_DWC_CHAN_RS                      = 1'b0,
  parameter [0:0] TARGET9_DWC_CHAN_RS                      = 1'b0,
  parameter [0:0] TARGET10_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET11_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET12_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET13_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET14_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET15_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET16_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET17_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET18_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET19_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET20_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET21_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET22_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET23_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET24_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET25_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET26_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET27_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET28_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET29_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET30_DWC_CHAN_RS                     = 1'b0,
  parameter [0:0] TARGET31_DWC_CHAN_RS                     = 1'b0, 

  
  parameter  [13:0] INITIATOR0_DWC_DATA_FIFO_DEPTH         =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR0
  parameter  [13:0] INITIATOR1_DWC_DATA_FIFO_DEPTH         =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR1
  parameter  [13:0] INITIATOR2_DWC_DATA_FIFO_DEPTH         =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR2
  parameter  [13:0] INITIATOR3_DWC_DATA_FIFO_DEPTH         =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR3
  parameter  [13:0] INITIATOR4_DWC_DATA_FIFO_DEPTH         =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR4
  parameter  [13:0] INITIATOR5_DWC_DATA_FIFO_DEPTH         =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR5
  parameter  [13:0] INITIATOR6_DWC_DATA_FIFO_DEPTH         =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR6
  parameter  [13:0] INITIATOR7_DWC_DATA_FIFO_DEPTH         =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR7
  parameter  [13:0] INITIATOR8_DWC_DATA_FIFO_DEPTH         =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR8
  parameter  [13:0] INITIATOR9_DWC_DATA_FIFO_DEPTH         =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR9
  parameter  [13:0] INITIATOR10_DWC_DATA_FIFO_DEPTH        =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR10
  parameter  [13:0] INITIATOR11_DWC_DATA_FIFO_DEPTH        =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR11
  parameter  [13:0] INITIATOR12_DWC_DATA_FIFO_DEPTH        =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR12
  parameter  [13:0] INITIATOR13_DWC_DATA_FIFO_DEPTH        =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR13
  parameter  [13:0] INITIATOR14_DWC_DATA_FIFO_DEPTH        =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR14
  parameter  [13:0] INITIATOR15_DWC_DATA_FIFO_DEPTH        =  14'h10,      // Defines the depth of the data caxi4interconnect_FIFO in the datawidth converter of INITIATOR15

  parameter [0:0]   INITIATOR0_DWC_CHAN_RS                 = 1'b0,
  parameter [0:0]   INITIATOR1_DWC_CHAN_RS                 = 1'b0,
  parameter [0:0]   INITIATOR2_DWC_CHAN_RS                 = 1'b0,
  parameter [0:0]   INITIATOR3_DWC_CHAN_RS                 = 1'b0,
  parameter [0:0]   INITIATOR4_DWC_CHAN_RS                 = 1'b0,
  parameter [0:0]   INITIATOR5_DWC_CHAN_RS                 = 1'b0,
  parameter [0:0]   INITIATOR6_DWC_CHAN_RS                 = 1'b0,
  parameter [0:0]   INITIATOR7_DWC_CHAN_RS                 = 1'b0,
  parameter [0:0]   INITIATOR8_DWC_CHAN_RS                 = 1'b0,
  parameter [0:0]   INITIATOR9_DWC_CHAN_RS                 = 1'b0,
  parameter [0:0]   INITIATOR10_DWC_CHAN_RS                = 1'b0,
  parameter [0:0]   INITIATOR11_DWC_CHAN_RS                = 1'b0,
  parameter [0:0]   INITIATOR12_DWC_CHAN_RS                = 1'b0,
  parameter [0:0]   INITIATOR13_DWC_CHAN_RS                = 1'b0,
  parameter [0:0]   INITIATOR14_DWC_CHAN_RS                = 1'b0,
  parameter [0:0]   INITIATOR15_DWC_CHAN_RS                = 1'b0,

  parameter integer DWC_ADDR_FIFO_DEPTH                    = 'h08,
  
  parameter  [0:0] INITIATOR0_READ_INTERLEAVE              = 1'b1,
  parameter  [0:0] INITIATOR1_READ_INTERLEAVE              = 1'b1,
  parameter  [0:0] INITIATOR2_READ_INTERLEAVE              = 1'b1,
  parameter  [0:0] INITIATOR3_READ_INTERLEAVE              = 1'b1,
  parameter  [0:0] INITIATOR4_READ_INTERLEAVE              = 1'b1,
  parameter  [0:0] INITIATOR5_READ_INTERLEAVE              = 1'b1,
  parameter  [0:0] INITIATOR6_READ_INTERLEAVE              = 1'b1,
  parameter  [0:0] INITIATOR7_READ_INTERLEAVE              = 1'b1,
  parameter  [0:0] INITIATOR8_READ_INTERLEAVE              = 1'b0,
  parameter  [0:0] INITIATOR9_READ_INTERLEAVE              = 1'b0,
  parameter  [0:0] INITIATOR10_READ_INTERLEAVE             = 1'b0,
  parameter  [0:0] INITIATOR11_READ_INTERLEAVE             = 1'b0,
  parameter  [0:0] INITIATOR12_READ_INTERLEAVE             = 1'b0,
  parameter  [0:0] INITIATOR13_READ_INTERLEAVE             = 1'b0,
  parameter  [0:0] INITIATOR14_READ_INTERLEAVE             = 1'b0,
  parameter  [0:0] INITIATOR15_READ_INTERLEAVE             = 1'b0,
  
  parameter  [0:0]  TARGET0_READ_INTERLEAVE                = 1'b0,
  parameter  [0:0]  TARGET1_READ_INTERLEAVE                = 1'b0,
  parameter  [0:0]  TARGET2_READ_INTERLEAVE                = 1'b0,
  parameter  [0:0]  TARGET3_READ_INTERLEAVE                = 1'b0,
  parameter  [0:0]  TARGET4_READ_INTERLEAVE                = 1'b0,
  parameter  [0:0]  TARGET5_READ_INTERLEAVE                = 1'b0,
  parameter  [0:0]  TARGET6_READ_INTERLEAVE                = 1'b0,
  parameter  [0:0]  TARGET7_READ_INTERLEAVE                = 1'b0,
  parameter  [0:0]  TARGET8_READ_INTERLEAVE                = 1'b0,
  parameter  [0:0]  TARGET9_READ_INTERLEAVE                = 1'b0,
  parameter  [0:0]  TARGET10_READ_INTERLEAVE               = 1'b0,
  parameter  [0:0]  TARGET11_READ_INTERLEAVE               = 1'b0,
  parameter  [0:0]  TARGET12_READ_INTERLEAVE               = 1'b0,
  parameter  [0:0]  TARGET13_READ_INTERLEAVE               = 1'b0,
  parameter  [0:0]  TARGET14_READ_INTERLEAVE               = 1'b0,
  parameter  [0:0]  TARGET15_READ_INTERLEAVE               = 1'b0,
  parameter  [0:0]  TARGET16_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET17_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET18_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET19_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET20_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET21_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET22_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET23_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET24_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET25_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET26_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET27_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET28_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET29_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET30_READ_INTERLEAVE               = 1'b1,
  parameter  [0:0]  TARGET31_READ_INTERLEAVE               = 1'b1,
  
  parameter  [7:0] INITIATOR0_DEF_BURST_LEN                =  8'h10,     // Defines the default burst length if the AHB interface of INITIATOR0
  parameter  [7:0] INITIATOR1_DEF_BURST_LEN                =  8'h10,     // Defines the default burst length if the AHB interface of INITIATOR1
  parameter  [7:0] INITIATOR2_DEF_BURST_LEN                =  8'h10,     // Defines the default burst length if the AHB interface of INITIATOR2
  parameter  [7:0] INITIATOR3_DEF_BURST_LEN                =  8'h10,     // Defines the default burst length if the AHB interface of INITIATOR3
  parameter  [7:0] INITIATOR4_DEF_BURST_LEN                =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR4
  parameter  [7:0] INITIATOR5_DEF_BURST_LEN                =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR5
  parameter  [7:0] INITIATOR6_DEF_BURST_LEN                =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR6
  parameter  [7:0] INITIATOR7_DEF_BURST_LEN                =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR7
  parameter  [7:0] INITIATOR8_DEF_BURST_LEN                =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR8
  parameter  [7:0] INITIATOR9_DEF_BURST_LEN                =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR9
  parameter  [7:0] INITIATOR10_DEF_BURST_LEN               =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR10
  parameter  [7:0] INITIATOR11_DEF_BURST_LEN               =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR11
  parameter  [7:0] INITIATOR12_DEF_BURST_LEN               =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR12
  parameter  [7:0] INITIATOR13_DEF_BURST_LEN               =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR13
  parameter  [7:0] INITIATOR14_DEF_BURST_LEN               =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR14
  parameter  [7:0] INITIATOR15_DEF_BURST_LEN               =  8'h00,     // Defines the default burst length if the AHB interface of INITIATOR15


  parameter integer TGIGEN_DISPLAY_SYMBOL                  = 1,
  
  parameter [3:0] NUM_RS_STAGES_INITR0                     = 1,
  parameter [3:0] NUM_RS_STAGES_INITR1                     = 1,
  parameter [3:0] NUM_RS_STAGES_INITR2                     = 1,
  parameter [3:0] NUM_RS_STAGES_INITR3                     = 1,
  parameter [3:0] NUM_RS_STAGES_INITR4                     = 1,
  parameter [3:0] NUM_RS_STAGES_INITR5                     = 1,
  parameter [3:0] NUM_RS_STAGES_INITR6                     = 1,
  parameter [3:0] NUM_RS_STAGES_INITR7                     = 1,
  parameter [3:0] NUM_RS_STAGES_INITR8                     = 0,
  parameter [3:0] NUM_RS_STAGES_INITR9                     = 0,
  parameter [3:0] NUM_RS_STAGES_INITR10                    = 0,
  parameter [3:0] NUM_RS_STAGES_INITR11                    = 0,
  parameter [3:0] NUM_RS_STAGES_INITR12                    = 0,
  parameter [3:0] NUM_RS_STAGES_INITR13                    = 0,
  parameter [3:0] NUM_RS_STAGES_INITR14                    = 0,
  parameter [3:0] NUM_RS_STAGES_INITR15                    = 0,

  parameter [3:0] NUM_RS_STAGES_TRGT0                      = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT1                      = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT2                      = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT3                      = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT4                      = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT5                      = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT6                      = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT7                      = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT8                      = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT9                      = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT10                     = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT11                     = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT12                     = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT13                     = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT14                     = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT15                     = 1,
  parameter [3:0] NUM_RS_STAGES_TRGT16                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT17                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT18                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT19                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT20                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT21                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT22                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT23                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT24                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT25                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT26                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT27                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT28                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT29                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT30                     = 0,
  parameter [3:0] NUM_RS_STAGES_TRGT31                     = 0, 
  
  parameter [0:0] BYPASS_CROSSBAR                          = 0, 
  
  parameter integer INITIATOR0_NUM_THREADS                 = 1,
  parameter integer INITIATOR1_NUM_THREADS                 = 1,
  parameter integer INITIATOR2_NUM_THREADS                 = 1,
  parameter integer INITIATOR3_NUM_THREADS                 = 1,
  parameter integer INITIATOR4_NUM_THREADS                 = 1,
  parameter integer INITIATOR5_NUM_THREADS                 = 1,
  parameter integer INITIATOR6_NUM_THREADS                 = 1,
  parameter integer INITIATOR7_NUM_THREADS                 = 1,
  parameter integer INITIATOR8_NUM_THREADS                 = 1,
  parameter integer INITIATOR9_NUM_THREADS                 = 1,
  parameter integer INITIATOR10_NUM_THREADS                = 1,
  parameter integer INITIATOR11_NUM_THREADS                = 1,
  parameter integer INITIATOR12_NUM_THREADS                = 1,
  parameter integer INITIATOR13_NUM_THREADS                = 1,
  parameter integer INITIATOR14_NUM_THREADS                = 1,
  parameter integer INITIATOR15_NUM_THREADS                = 1,
  
  parameter integer INITIATOR0_OPEN_TRANS_MAX              = 1,
  parameter integer INITIATOR1_OPEN_TRANS_MAX              = 1,
  parameter integer INITIATOR2_OPEN_TRANS_MAX              = 1,
  parameter integer INITIATOR3_OPEN_TRANS_MAX              = 1,
  parameter integer INITIATOR4_OPEN_TRANS_MAX              = 1,
  parameter integer INITIATOR5_OPEN_TRANS_MAX              = 1,
  parameter integer INITIATOR6_OPEN_TRANS_MAX              = 1,
  parameter integer INITIATOR7_OPEN_TRANS_MAX              = 1,
  parameter integer INITIATOR8_OPEN_TRANS_MAX              = 1,
  parameter integer INITIATOR9_OPEN_TRANS_MAX              = 1,
  parameter integer INITIATOR10_OPEN_TRANS_MAX             = 1,
  parameter integer INITIATOR11_OPEN_TRANS_MAX             = 1,
  parameter integer INITIATOR12_OPEN_TRANS_MAX             = 1,
  parameter integer INITIATOR13_OPEN_TRANS_MAX             = 1,
  parameter integer INITIATOR14_OPEN_TRANS_MAX             = 1,
  parameter integer INITIATOR15_OPEN_TRANS_MAX             = 1,

  parameter         CROSSBAR_RAM_TYPE                      = 3,  
  parameter         DWC_RAM_TYPE                           = 3,  
  parameter         CDC_RAM_TYPE                           = 3,  
  parameter         PROTOCONV_RAM_TYPE                     = 3,

  // Repeat for index 0 to 15
  parameter         I0_LOCK_WIDTH                          = 2,
  parameter         I1_LOCK_WIDTH                          = 2,
  parameter         I2_LOCK_WIDTH                          = 2,
  parameter         I3_LOCK_WIDTH                          = 2,
  parameter         I4_LOCK_WIDTH                          = 2,
  parameter         I5_LOCK_WIDTH                          = 2,
  parameter         I6_LOCK_WIDTH                          = 2,
  parameter         I7_LOCK_WIDTH                          = 2,
  parameter         I8_LOCK_WIDTH                          = 2,
  parameter         I9_LOCK_WIDTH                          = 2,
  parameter         I10_LOCK_WIDTH                         = 2,
  parameter         I11_LOCK_WIDTH                         = 2,
  parameter         I12_LOCK_WIDTH                         = 2,
  parameter         I13_LOCK_WIDTH                         = 2,
  parameter         I14_LOCK_WIDTH                         = 2,
  parameter         I15_LOCK_WIDTH                         = 2,  
  parameter         T0_LOCK_WIDTH                          = 2,
  parameter         T1_LOCK_WIDTH                          = 2,
  parameter         T2_LOCK_WIDTH                          = 2,
  parameter         T3_LOCK_WIDTH                          = 2,
  parameter         T4_LOCK_WIDTH                          = 2,
  parameter         T5_LOCK_WIDTH                          = 2,
  parameter         T6_LOCK_WIDTH                          = 2,
  parameter         T7_LOCK_WIDTH                          = 2,
  parameter         T8_LOCK_WIDTH                          = 2,
  parameter         T9_LOCK_WIDTH                          = 2,
  parameter         T10_LOCK_WIDTH                         = 2,
  parameter         T11_LOCK_WIDTH                         = 2,
  parameter         T12_LOCK_WIDTH                         = 2,
  parameter         T13_LOCK_WIDTH                         = 2,
  parameter         T14_LOCK_WIDTH                         = 2,
  parameter         T15_LOCK_WIDTH                         = 2,
  parameter         T16_LOCK_WIDTH                         = 2,
  parameter         T17_LOCK_WIDTH                         = 2,
  parameter         T18_LOCK_WIDTH                         = 2,
  parameter         T19_LOCK_WIDTH                         = 2,
  parameter         T20_LOCK_WIDTH                         = 2,
  parameter         T21_LOCK_WIDTH                         = 2,
  parameter         T22_LOCK_WIDTH                         = 2,
  parameter         T23_LOCK_WIDTH                         = 2,
  parameter         T24_LOCK_WIDTH                         = 2,
  parameter         T25_LOCK_WIDTH                         = 2,
  parameter         T26_LOCK_WIDTH                         = 2,
  parameter         T27_LOCK_WIDTH                         = 2,
  parameter         T28_LOCK_WIDTH                         = 2,
  parameter         T29_LOCK_WIDTH                         = 2,
  parameter         T30_LOCK_WIDTH                         = 2,
  parameter         T31_LOCK_WIDTH                         = 2

)
(
  //===================================================================================================================================

  //================================================= Global Signals  ==============================================//
  input  wire         ACLK,
  input  wire         ARESETN,      // active low reset synchronoise to RE AClk - asserted async.
  output wire         ARESETN_SYNC,
   
  //================================================= INITIATOR Ports  ================================================//
  // AHB interface
  
  input wire  [31:0]  INITIATOR0_HADDR,     INITIATOR1_HADDR,     INITIATOR2_HADDR,     INITIATOR3_HADDR,     INITIATOR4_HADDR,     
                      INITIATOR5_HADDR,     INITIATOR6_HADDR,     INITIATOR7_HADDR,     INITIATOR8_HADDR,     INITIATOR9_HADDR,     
					  INITIATOR10_HADDR,    INITIATOR11_HADDR,    INITIATOR12_HADDR,    INITIATOR13_HADDR,    INITIATOR14_HADDR,     
					  INITIATOR15_HADDR, 
  input wire  [2:0]   INITIATOR0_HBURST,    INITIATOR1_HBURST,    INITIATOR2_HBURST,    INITIATOR3_HBURST,    INITIATOR4_HBURST, 
                      INITIATOR5_HBURST,    INITIATOR6_HBURST,    INITIATOR7_HBURST,    INITIATOR8_HBURST,    INITIATOR9_HBURST,    
					  INITIATOR10_HBURST,   INITIATOR11_HBURST,   INITIATOR12_HBURST,   INITIATOR13_HBURST,   INITIATOR14_HBURST,   
					  INITIATOR15_HBURST, 
  input wire          INITIATOR0_HMASTLOCK,  INITIATOR1_HMASTLOCK,  INITIATOR2_HMASTLOCK,  INITIATOR3_HMASTLOCK,  INITIATOR4_HMASTLOCK, 
                      INITIATOR5_HMASTLOCK,  INITIATOR6_HMASTLOCK,  INITIATOR7_HMASTLOCK,  INITIATOR8_HMASTLOCK,  INITIATOR9_HMASTLOCK, 
					  INITIATOR10_HMASTLOCK, INITIATOR11_HMASTLOCK, INITIATOR12_HMASTLOCK, INITIATOR13_HMASTLOCK, INITIATOR14_HMASTLOCK, 
					  INITIATOR15_HMASTLOCK, 
  input wire  [6:0]   INITIATOR0_HPROT,     INITIATOR1_HPROT,     INITIATOR2_HPROT,     INITIATOR3_HPROT,     INITIATOR4_HPROT,     
                      INITIATOR5_HPROT,     INITIATOR6_HPROT,     INITIATOR7_HPROT,     INITIATOR8_HPROT,     INITIATOR9_HPROT,     
					  INITIATOR10_HPROT,    INITIATOR11_HPROT,    INITIATOR12_HPROT,    INITIATOR13_HPROT,    INITIATOR14_HPROT,   
					  INITIATOR15_HPROT, 
  input wire  [2:0]   INITIATOR0_HSIZE,     INITIATOR1_HSIZE,     INITIATOR2_HSIZE,     INITIATOR3_HSIZE,     INITIATOR4_HSIZE,     
                      INITIATOR5_HSIZE,     INITIATOR6_HSIZE,     INITIATOR7_HSIZE,     INITIATOR8_HSIZE,     INITIATOR9_HSIZE,     
					  INITIATOR10_HSIZE,    INITIATOR11_HSIZE,    INITIATOR12_HSIZE,    INITIATOR13_HSIZE,    INITIATOR14_HSIZE, 
					  INITIATOR15_HSIZE, 
  input wire          INITIATOR0_HNONSEC,   INITIATOR1_HNONSEC,   INITIATOR2_HNONSEC,   INITIATOR3_HNONSEC,   INITIATOR4_HNONSEC,   
                      INITIATOR5_HNONSEC,   INITIATOR6_HNONSEC,   INITIATOR7_HNONSEC,   INITIATOR8_HNONSEC,   INITIATOR9_HNONSEC,   
					  INITIATOR10_HNONSEC,  INITIATOR11_HNONSEC,  INITIATOR12_HNONSEC,  INITIATOR13_HNONSEC,  INITIATOR14_HNONSEC, 
					  INITIATOR15_HNONSEC, 
  input wire  [1:0]   INITIATOR0_HTRANS,    INITIATOR1_HTRANS,    INITIATOR2_HTRANS,    INITIATOR3_HTRANS,    INITIATOR4_HTRANS,    
                      INITIATOR5_HTRANS,    INITIATOR6_HTRANS,    INITIATOR7_HTRANS,    INITIATOR8_HTRANS,    INITIATOR9_HTRANS,    
					  INITIATOR10_HTRANS,   INITIATOR11_HTRANS,   INITIATOR12_HTRANS,   INITIATOR13_HTRANS,   INITIATOR14_HTRANS,   
					  INITIATOR15_HTRANS, 
  input wire          INITIATOR0_HWRITE,    INITIATOR1_HWRITE,    INITIATOR2_HWRITE,    INITIATOR3_HWRITE,    INITIATOR4_HWRITE,    
                      INITIATOR5_HWRITE,    INITIATOR6_HWRITE,    INITIATOR7_HWRITE,    INITIATOR8_HWRITE,    INITIATOR9_HWRITE,    
					  INITIATOR10_HWRITE,   INITIATOR11_HWRITE,   INITIATOR12_HWRITE,   INITIATOR13_HWRITE,   INITIATOR14_HWRITE,   
					  INITIATOR15_HWRITE, 
  output wire         INITIATOR0_HREADY,    INITIATOR1_HREADY,    INITIATOR2_HREADY,    INITIATOR3_HREADY,    INITIATOR4_HREADY,    
                      INITIATOR5_HREADY,    INITIATOR6_HREADY,    INITIATOR7_HREADY,    INITIATOR8_HREADY,    INITIATOR9_HREADY,    
					  INITIATOR10_HREADY,   INITIATOR11_HREADY,   INITIATOR12_HREADY,   INITIATOR13_HREADY,   INITIATOR14_HREADY,  
					  INITIATOR15_HREADY, 
  output wire         INITIATOR0_HRESP,     INITIATOR1_HRESP,     INITIATOR2_HRESP,     INITIATOR3_HRESP,     INITIATOR4_HRESP,     
                      INITIATOR5_HRESP,     INITIATOR6_HRESP,     INITIATOR7_HRESP,     INITIATOR8_HRESP,     INITIATOR9_HRESP,     
					  INITIATOR10_HRESP,    INITIATOR11_HRESP,    INITIATOR12_HRESP,    INITIATOR13_HRESP,    INITIATOR14_HRESP, 
					  INITIATOR15_HRESP, 
  input wire          INITIATOR0_HSEL,      INITIATOR1_HSEL,      INITIATOR2_HSEL,      INITIATOR3_HSEL,      INITIATOR4_HSEL,      
                      INITIATOR5_HSEL,      INITIATOR6_HSEL,      INITIATOR7_HSEL,      INITIATOR8_HSEL,      INITIATOR9_HSEL,      
					  INITIATOR10_HSEL,     INITIATOR11_HSEL,     INITIATOR12_HSEL,     INITIATOR13_HSEL,     INITIATOR14_HSEL,     
					  INITIATOR15_HSEL, 

  // AHB data ports
  

  input  wire [INITIATOR0_DATA_WIDTH-1:0]     INITIATOR0_HWDATA,
  input  wire [INITIATOR1_DATA_WIDTH-1:0]     INITIATOR1_HWDATA,
  input  wire [INITIATOR2_DATA_WIDTH-1:0]     INITIATOR2_HWDATA,
  input  wire [INITIATOR3_DATA_WIDTH-1:0]     INITIATOR3_HWDATA,
  input  wire [INITIATOR4_DATA_WIDTH-1:0]     INITIATOR4_HWDATA,
  input  wire [INITIATOR5_DATA_WIDTH-1:0]     INITIATOR5_HWDATA,
  input  wire [INITIATOR6_DATA_WIDTH-1:0]     INITIATOR6_HWDATA,
  input  wire [INITIATOR7_DATA_WIDTH-1:0]     INITIATOR7_HWDATA,
  input  wire [INITIATOR8_DATA_WIDTH-1:0]     INITIATOR8_HWDATA,
  input  wire [INITIATOR9_DATA_WIDTH-1:0]     INITIATOR9_HWDATA,
  input  wire [INITIATOR10_DATA_WIDTH-1:0]    INITIATOR10_HWDATA,
  input  wire [INITIATOR11_DATA_WIDTH-1:0]    INITIATOR11_HWDATA,
  input  wire [INITIATOR12_DATA_WIDTH-1:0]    INITIATOR12_HWDATA,
  input  wire [INITIATOR13_DATA_WIDTH-1:0]    INITIATOR13_HWDATA,
  input  wire [INITIATOR14_DATA_WIDTH-1:0]    INITIATOR14_HWDATA,
  input  wire [INITIATOR15_DATA_WIDTH-1:0]    INITIATOR15_HWDATA,

  output  wire [INITIATOR0_DATA_WIDTH-1:0]     INITIATOR0_HRDATA,
  output  wire [INITIATOR1_DATA_WIDTH-1:0]     INITIATOR1_HRDATA,
  output  wire [INITIATOR2_DATA_WIDTH-1:0]     INITIATOR2_HRDATA,
  output  wire [INITIATOR3_DATA_WIDTH-1:0]     INITIATOR3_HRDATA,
  output  wire [INITIATOR4_DATA_WIDTH-1:0]     INITIATOR4_HRDATA,
  output  wire [INITIATOR5_DATA_WIDTH-1:0]     INITIATOR5_HRDATA,
  output  wire [INITIATOR6_DATA_WIDTH-1:0]     INITIATOR6_HRDATA,
  output  wire [INITIATOR7_DATA_WIDTH-1:0]     INITIATOR7_HRDATA,
  output  wire [INITIATOR8_DATA_WIDTH-1:0]     INITIATOR8_HRDATA,
  output  wire [INITIATOR9_DATA_WIDTH-1:0]     INITIATOR9_HRDATA,
  output  wire [INITIATOR10_DATA_WIDTH-1:0]    INITIATOR10_HRDATA,
  output  wire [INITIATOR11_DATA_WIDTH-1:0]    INITIATOR11_HRDATA,
  output  wire [INITIATOR12_DATA_WIDTH-1:0]    INITIATOR12_HRDATA,
  output  wire [INITIATOR13_DATA_WIDTH-1:0]    INITIATOR13_HRDATA,
  output  wire [INITIATOR14_DATA_WIDTH-1:0]    INITIATOR14_HRDATA,
  output  wire [INITIATOR15_DATA_WIDTH-1:0]    INITIATOR15_HRDATA,



  // INITIATOR Write Address Ports            
  

  input  wire [ID_WIDTH-1:0]    INITIATOR0_AWID,     INITIATOR1_AWID,     INITIATOR2_AWID,     INITIATOR3_AWID,     INITIATOR4_AWID,     
                                INITIATOR5_AWID,     INITIATOR6_AWID,     INITIATOR7_AWID,     INITIATOR8_AWID,     INITIATOR9_AWID,     
								INITIATOR10_AWID,    INITIATOR11_AWID,    INITIATOR12_AWID,    INITIATOR13_AWID,    INITIATOR14_AWID,  
								INITIATOR15_AWID,
  input  wire [ADDR_WIDTH-1:0]  INITIATOR0_AWADDR,   INITIATOR1_AWADDR,   INITIATOR2_AWADDR,   INITIATOR3_AWADDR,   INITIATOR4_AWADDR,   
                                INITIATOR5_AWADDR,   INITIATOR6_AWADDR,   INITIATOR7_AWADDR,   INITIATOR8_AWADDR,   INITIATOR9_AWADDR,   
								INITIATOR10_AWADDR,  INITIATOR11_AWADDR,  INITIATOR12_AWADDR,  INITIATOR13_AWADDR,  INITIATOR14_AWADDR,   
								INITIATOR15_AWADDR,
  input  wire [7:0]             INITIATOR0_AWLEN,    INITIATOR1_AWLEN,    INITIATOR2_AWLEN,    INITIATOR3_AWLEN,    INITIATOR4_AWLEN,    
                                INITIATOR5_AWLEN,    INITIATOR6_AWLEN,    INITIATOR7_AWLEN,    INITIATOR8_AWLEN,    INITIATOR9_AWLEN,    
								INITIATOR10_AWLEN,   INITIATOR11_AWLEN,   INITIATOR12_AWLEN,   INITIATOR13_AWLEN,   INITIATOR14_AWLEN,    
								INITIATOR15_AWLEN,
  input  wire [2:0]             INITIATOR0_AWSIZE,   INITIATOR1_AWSIZE,   INITIATOR2_AWSIZE,   INITIATOR3_AWSIZE,   INITIATOR4_AWSIZE,   
                                INITIATOR5_AWSIZE,   INITIATOR6_AWSIZE,   INITIATOR7_AWSIZE,   INITIATOR8_AWSIZE,   INITIATOR9_AWSIZE,   
								INITIATOR10_AWSIZE,  INITIATOR11_AWSIZE,  INITIATOR12_AWSIZE,  INITIATOR13_AWSIZE,  INITIATOR14_AWSIZE,   
								INITIATOR15_AWSIZE,

  input  wire [1:0]             INITIATOR0_AWBURST,   INITIATOR1_AWBURST,   INITIATOR2_AWBURST,   INITIATOR3_AWBURST,   INITIATOR4_AWBURST,
                                INITIATOR5_AWBURST,   INITIATOR6_AWBURST,   INITIATOR7_AWBURST,   INITIATOR8_AWBURST,   INITIATOR9_AWBURST,
                                INITIATOR10_AWBURST,  INITIATOR11_AWBURST,  INITIATOR12_AWBURST,  INITIATOR13_AWBURST,  INITIATOR14_AWBURST,
                                INITIATOR15_AWBURST,
  
// AWLOCK (0 to 15)
  input  wire [I0_LOCK_WIDTH-1:0]   INITIATOR0_AWLOCK,
  input  wire [I1_LOCK_WIDTH-1:0]   INITIATOR1_AWLOCK,
  input  wire [I2_LOCK_WIDTH-1:0]   INITIATOR2_AWLOCK,
  input  wire [I3_LOCK_WIDTH-1:0]   INITIATOR3_AWLOCK,
  input  wire [I4_LOCK_WIDTH-1:0]   INITIATOR4_AWLOCK,
  input  wire [I5_LOCK_WIDTH-1:0]   INITIATOR5_AWLOCK,
  input  wire [I6_LOCK_WIDTH-1:0]   INITIATOR6_AWLOCK,
  input  wire [I7_LOCK_WIDTH-1:0]   INITIATOR7_AWLOCK,
  input  wire [I8_LOCK_WIDTH-1:0]   INITIATOR8_AWLOCK,
  input  wire [I9_LOCK_WIDTH-1:0]   INITIATOR9_AWLOCK,
  input  wire [I10_LOCK_WIDTH-1:0]  INITIATOR10_AWLOCK,
  input  wire [I11_LOCK_WIDTH-1:0]  INITIATOR11_AWLOCK,
  input  wire [I12_LOCK_WIDTH-1:0]  INITIATOR12_AWLOCK,
  input  wire [I13_LOCK_WIDTH-1:0]  INITIATOR13_AWLOCK,
  input  wire [I14_LOCK_WIDTH-1:0]  INITIATOR14_AWLOCK,
  input  wire [I15_LOCK_WIDTH-1:0]  INITIATOR15_AWLOCK,  
  
  
  input  wire [3:0]             INITIATOR0_AWCACHE,   INITIATOR1_AWCACHE,   INITIATOR2_AWCACHE,   INITIATOR3_AWCACHE,   INITIATOR4_AWCACHE,
                                INITIATOR5_AWCACHE,   INITIATOR6_AWCACHE,   INITIATOR7_AWCACHE,   INITIATOR8_AWCACHE,   INITIATOR9_AWCACHE,
                                INITIATOR10_AWCACHE,  INITIATOR11_AWCACHE,  INITIATOR12_AWCACHE,  INITIATOR13_AWCACHE,  INITIATOR14_AWCACHE,
                                INITIATOR15_AWCACHE,
  
  input  wire [2:0]             INITIATOR0_AWPROT,    INITIATOR1_AWPROT,    INITIATOR2_AWPROT,    INITIATOR3_AWPROT,    INITIATOR4_AWPROT,
                                INITIATOR5_AWPROT,    INITIATOR6_AWPROT,    INITIATOR7_AWPROT,    INITIATOR8_AWPROT,    INITIATOR9_AWPROT,
                                INITIATOR10_AWPROT,   INITIATOR11_AWPROT,   INITIATOR12_AWPROT,   INITIATOR13_AWPROT,   INITIATOR14_AWPROT,
                                INITIATOR15_AWPROT,
  
  input  wire [3:0]             INITIATOR0_AWREGION,  INITIATOR1_AWREGION,  INITIATOR2_AWREGION,  INITIATOR3_AWREGION,  INITIATOR4_AWREGION,
                                INITIATOR5_AWREGION,  INITIATOR6_AWREGION,  INITIATOR7_AWREGION,  INITIATOR8_AWREGION,  INITIATOR9_AWREGION,
                                INITIATOR10_AWREGION, INITIATOR11_AWREGION, INITIATOR12_AWREGION, INITIATOR13_AWREGION, INITIATOR14_AWREGION,
                                INITIATOR15_AWREGION,
  
  input  wire [3:0]             INITIATOR0_AWQOS,     INITIATOR1_AWQOS,     INITIATOR2_AWQOS,     INITIATOR3_AWQOS,     INITIATOR4_AWQOS,
                                INITIATOR5_AWQOS,     INITIATOR6_AWQOS,     INITIATOR7_AWQOS,     INITIATOR8_AWQOS,     INITIATOR9_AWQOS,
                                INITIATOR10_AWQOS,    INITIATOR11_AWQOS,    INITIATOR12_AWQOS,    INITIATOR13_AWQOS,    INITIATOR14_AWQOS,
                                INITIATOR15_AWQOS,

  input  wire [USER_WIDTH-1:0]  INITIATOR0_AWUSER, INITIATOR1_AWUSER,    INITIATOR2_AWUSER,    INITIATOR3_AWUSER,    INITIATOR4_AWUSER,
                                INITIATOR5_AWUSER, INITIATOR6_AWUSER,    INITIATOR7_AWUSER,    INITIATOR8_AWUSER,    INITIATOR9_AWUSER,
                                INITIATOR10_AWUSER,INITIATOR11_AWUSER,   INITIATOR12_AWUSER,   INITIATOR13_AWUSER,   INITIATOR14_AWUSER,
                                INITIATOR15_AWUSER,
  
  input  wire                   INITIATOR0_AWVALID,  INITIATOR1_AWVALID,  INITIATOR2_AWVALID,  INITIATOR3_AWVALID,  INITIATOR4_AWVALID,
                                INITIATOR5_AWVALID,  INITIATOR6_AWVALID,  INITIATOR7_AWVALID,  INITIATOR8_AWVALID,  INITIATOR9_AWVALID,
                                INITIATOR10_AWVALID, INITIATOR11_AWVALID, INITIATOR12_AWVALID, INITIATOR13_AWVALID, INITIATOR14_AWVALID,
                                INITIATOR15_AWVALID,
  
  output wire                   INITIATOR0_AWREADY,   INITIATOR1_AWREADY,  INITIATOR2_AWREADY,  INITIATOR3_AWREADY,  INITIATOR4_AWREADY,
                                INITIATOR5_AWREADY,   INITIATOR6_AWREADY,  INITIATOR7_AWREADY,  INITIATOR8_AWREADY,  INITIATOR9_AWREADY,
                                INITIATOR10_AWREADY,  INITIATOR11_AWREADY, INITIATOR12_AWREADY, INITIATOR13_AWREADY, INITIATOR14_AWREADY,
                                INITIATOR15_AWREADY,

  input  wire                   I_CLK0,  I_CLK1,  I_CLK2,  I_CLK3,  I_CLK4,  I_CLK5,  I_CLK6,  I_CLK7,
                                I_CLK8,  I_CLK9,  I_CLK10, I_CLK11, I_CLK12, I_CLK13, I_CLK14, I_CLK15,  
  output wire                   I_SYNC_RSTN0,  I_SYNC_RSTN1,  I_SYNC_RSTN2,  I_SYNC_RSTN3,  I_SYNC_RSTN4,  
                                I_SYNC_RSTN5,  I_SYNC_RSTN6,  I_SYNC_RSTN7,  I_SYNC_RSTN8,  I_SYNC_RSTN9, 
								I_SYNC_RSTN10, I_SYNC_RSTN11, I_SYNC_RSTN12, I_SYNC_RSTN13, I_SYNC_RSTN14,
								I_SYNC_RSTN15,   								     
  input wire                    T_CLK0,  T_CLK1,  T_CLK2,  T_CLK3,  T_CLK4,  T_CLK5,  T_CLK6,  T_CLK7, 
                                T_CLK8,  T_CLK9,  T_CLK10, T_CLK11, T_CLK12, T_CLK13, T_CLK14, T_CLK15, 
                                T_CLK16, T_CLK17, T_CLK18, T_CLK19, T_CLK20, T_CLK21, T_CLK22, T_CLK23, 
                                T_CLK24, T_CLK25, T_CLK26, T_CLK27, T_CLK28, T_CLK29, T_CLK30, T_CLK31,
  output wire                   T_SYNC_RSTN0,  T_SYNC_RSTN1,  T_SYNC_RSTN2,  T_SYNC_RSTN3,  T_SYNC_RSTN4,  
                                T_SYNC_RSTN5,  T_SYNC_RSTN6,  T_SYNC_RSTN7,  T_SYNC_RSTN8,  T_SYNC_RSTN9,  
								T_SYNC_RSTN10, T_SYNC_RSTN11, T_SYNC_RSTN12, T_SYNC_RSTN13, T_SYNC_RSTN14, 
								T_SYNC_RSTN15, T_SYNC_RSTN16, T_SYNC_RSTN17, T_SYNC_RSTN18, T_SYNC_RSTN19, 
								T_SYNC_RSTN20, T_SYNC_RSTN21, T_SYNC_RSTN22, T_SYNC_RSTN23, T_SYNC_RSTN24, 
								T_SYNC_RSTN25, T_SYNC_RSTN26, T_SYNC_RSTN27, T_SYNC_RSTN28, T_SYNC_RSTN29, 
								T_SYNC_RSTN30, T_SYNC_RSTN31,

  // INITIATOR Write Data Ports
  input  wire [ID_WIDTH-1:0]    INITIATOR0_WID,  INITIATOR1_WID,  INITIATOR2_WID,  INITIATOR3_WID,  INITIATOR4_WID,  INITIATOR5_WID,  
                                INITIATOR6_WID,  INITIATOR7_WID,  INITIATOR8_WID,  INITIATOR9_WID,  INITIATOR10_WID,  INITIATOR11_WID,  
								INITIATOR12_WID,  INITIATOR13_WID,  INITIATOR14_WID,  INITIATOR15_WID,
  
  input  wire [INITIATOR0_DATA_WIDTH-1:0]    INITIATOR0_WDATA,  
  input  wire [INITIATOR1_DATA_WIDTH-1:0]    INITIATOR1_WDATA,  
  input  wire [INITIATOR2_DATA_WIDTH-1:0]    INITIATOR2_WDATA,  
  input  wire [INITIATOR3_DATA_WIDTH-1:0]    INITIATOR3_WDATA,  
  input  wire [INITIATOR4_DATA_WIDTH-1:0]    INITIATOR4_WDATA,  
  input  wire [INITIATOR5_DATA_WIDTH-1:0]    INITIATOR5_WDATA,  
  input  wire [INITIATOR6_DATA_WIDTH-1:0]    INITIATOR6_WDATA,  
  input  wire [INITIATOR7_DATA_WIDTH-1:0]    INITIATOR7_WDATA,
  input  wire [INITIATOR8_DATA_WIDTH-1:0]    INITIATOR8_WDATA,
  input  wire [INITIATOR9_DATA_WIDTH-1:0]    INITIATOR9_WDATA,
  input  wire [INITIATOR10_DATA_WIDTH-1:0]   INITIATOR10_WDATA,
  input  wire [INITIATOR11_DATA_WIDTH-1:0]   INITIATOR11_WDATA,
  input  wire [INITIATOR12_DATA_WIDTH-1:0]   INITIATOR12_WDATA,
  input  wire [INITIATOR13_DATA_WIDTH-1:0]   INITIATOR13_WDATA,
  input  wire [INITIATOR14_DATA_WIDTH-1:0]   INITIATOR14_WDATA,
  input  wire [INITIATOR15_DATA_WIDTH-1:0]   INITIATOR15_WDATA,  
  
  input  wire [(INITIATOR0_DATA_WIDTH/8)-1:0]  INITIATOR0_WSTRB,  
  input  wire [(INITIATOR1_DATA_WIDTH/8)-1:0]  INITIATOR1_WSTRB,  
  input  wire [(INITIATOR2_DATA_WIDTH/8)-1:0]  INITIATOR2_WSTRB,  
  input  wire [(INITIATOR3_DATA_WIDTH/8)-1:0]  INITIATOR3_WSTRB,  
  input  wire [(INITIATOR4_DATA_WIDTH/8)-1:0]  INITIATOR4_WSTRB,  
  input  wire [(INITIATOR5_DATA_WIDTH/8)-1:0]  INITIATOR5_WSTRB,  
  input  wire [(INITIATOR6_DATA_WIDTH/8)-1:0]  INITIATOR6_WSTRB,  
  input  wire [(INITIATOR7_DATA_WIDTH/8)-1:0]  INITIATOR7_WSTRB,
  input  wire [(INITIATOR8_DATA_WIDTH/8)-1:0]  INITIATOR8_WSTRB,
  input  wire [(INITIATOR9_DATA_WIDTH/8)-1:0]  INITIATOR9_WSTRB,
  input  wire [(INITIATOR10_DATA_WIDTH/8)-1:0] INITIATOR10_WSTRB,
  input  wire [(INITIATOR11_DATA_WIDTH/8)-1:0] INITIATOR11_WSTRB,
  input  wire [(INITIATOR12_DATA_WIDTH/8)-1:0] INITIATOR12_WSTRB,
  input  wire [(INITIATOR13_DATA_WIDTH/8)-1:0] INITIATOR13_WSTRB,
  input  wire [(INITIATOR14_DATA_WIDTH/8)-1:0] INITIATOR14_WSTRB,
  input  wire [(INITIATOR15_DATA_WIDTH/8)-1:0] INITIATOR15_WSTRB,  
  
// Code generated by MCHP Chatbot
  input  wire                   INITIATOR0_WLAST,    INITIATOR1_WLAST,    INITIATOR2_WLAST,    INITIATOR3_WLAST,    INITIATOR4_WLAST,
                                INITIATOR5_WLAST,    INITIATOR6_WLAST,    INITIATOR7_WLAST,    INITIATOR8_WLAST,    INITIATOR9_WLAST,
                                INITIATOR10_WLAST,   INITIATOR11_WLAST,   INITIATOR12_WLAST,   INITIATOR13_WLAST,   INITIATOR14_WLAST,
                                INITIATOR15_WLAST,
  
  input  wire [USER_WIDTH-1:0]  INITIATOR0_WUSER,    INITIATOR1_WUSER,    INITIATOR2_WUSER,    INITIATOR3_WUSER,    INITIATOR4_WUSER,
                                INITIATOR5_WUSER,    INITIATOR6_WUSER,    INITIATOR7_WUSER,    INITIATOR8_WUSER,    INITIATOR9_WUSER,
                                INITIATOR10_WUSER,   INITIATOR11_WUSER,   INITIATOR12_WUSER,   INITIATOR13_WUSER,   INITIATOR14_WUSER,
                                INITIATOR15_WUSER,
  
  input  wire                   INITIATOR0_WVALID,   INITIATOR1_WVALID,   INITIATOR2_WVALID,   INITIATOR3_WVALID,   INITIATOR4_WVALID,
                                INITIATOR5_WVALID,   INITIATOR6_WVALID,   INITIATOR7_WVALID,   INITIATOR8_WVALID,   INITIATOR9_WVALID,
                                INITIATOR10_WVALID,  INITIATOR11_WVALID,  INITIATOR12_WVALID,  INITIATOR13_WVALID,  INITIATOR14_WVALID,
                                INITIATOR15_WVALID,
  
  output wire                   INITIATOR0_WREADY,   INITIATOR1_WREADY,   INITIATOR2_WREADY,   INITIATOR3_WREADY,   INITIATOR4_WREADY,
                                INITIATOR5_WREADY,   INITIATOR6_WREADY,   INITIATOR7_WREADY,   INITIATOR8_WREADY,   INITIATOR9_WREADY,
                                INITIATOR10_WREADY,  INITIATOR11_WREADY,  INITIATOR12_WREADY,  INITIATOR13_WREADY,  INITIATOR14_WREADY,
                                INITIATOR15_WREADY,
  
  // INITIATOR Write Response Ports
  output wire [ID_WIDTH-1:0]    INITIATOR0_BID,      INITIATOR1_BID,      INITIATOR2_BID,      INITIATOR3_BID,      INITIATOR4_BID,
                                INITIATOR5_BID,      INITIATOR6_BID,      INITIATOR7_BID,      INITIATOR8_BID,      INITIATOR9_BID,
                                INITIATOR10_BID,     INITIATOR11_BID,     INITIATOR12_BID,     INITIATOR13_BID,     INITIATOR14_BID,
                                INITIATOR15_BID,

  output wire [1:0]             INITIATOR0_BRESP,    INITIATOR1_BRESP,    INITIATOR2_BRESP,    INITIATOR3_BRESP,    INITIATOR4_BRESP,
                                INITIATOR5_BRESP,    INITIATOR6_BRESP,    INITIATOR7_BRESP,    INITIATOR8_BRESP,    INITIATOR9_BRESP,
                                INITIATOR10_BRESP,   INITIATOR11_BRESP,   INITIATOR12_BRESP,   INITIATOR13_BRESP,   INITIATOR14_BRESP,
                                INITIATOR15_BRESP,
  
  output wire [USER_WIDTH-1:0]  INITIATOR0_BUSER,    INITIATOR1_BUSER,    INITIATOR2_BUSER,    INITIATOR3_BUSER,    INITIATOR4_BUSER,
                                INITIATOR5_BUSER,    INITIATOR6_BUSER,    INITIATOR7_BUSER,    INITIATOR8_BUSER,    INITIATOR9_BUSER,
                                INITIATOR10_BUSER,   INITIATOR11_BUSER,   INITIATOR12_BUSER,   INITIATOR13_BUSER,   INITIATOR14_BUSER,
                                INITIATOR15_BUSER,
  
  output wire                   INITIATOR0_BVALID,   INITIATOR1_BVALID,   INITIATOR2_BVALID,   INITIATOR3_BVALID,   INITIATOR4_BVALID,
                                INITIATOR5_BVALID,   INITIATOR6_BVALID,   INITIATOR7_BVALID,   INITIATOR8_BVALID,   INITIATOR9_BVALID,
                                INITIATOR10_BVALID,  INITIATOR11_BVALID,  INITIATOR12_BVALID,  INITIATOR13_BVALID,  INITIATOR14_BVALID,
                                INITIATOR15_BVALID,

  input  wire                   INITIATOR0_BREADY,   INITIATOR1_BREADY,   INITIATOR2_BREADY,   INITIATOR3_BREADY,   INITIATOR4_BREADY,
                                INITIATOR5_BREADY,   INITIATOR6_BREADY,   INITIATOR7_BREADY,   INITIATOR8_BREADY,   INITIATOR9_BREADY,
                                INITIATOR10_BREADY,  INITIATOR11_BREADY,  INITIATOR12_BREADY,  INITIATOR13_BREADY,  INITIATOR14_BREADY,
                                INITIATOR15_BREADY,
  // INITIATOR Read Address Ports            

  input  wire [ID_WIDTH-1:0]    INITIATOR0_ARID,     INITIATOR1_ARID,     INITIATOR2_ARID,     INITIATOR3_ARID,     INITIATOR4_ARID,
                                INITIATOR5_ARID,     INITIATOR6_ARID,     INITIATOR7_ARID,     INITIATOR8_ARID,     INITIATOR9_ARID,
                                INITIATOR10_ARID,    INITIATOR11_ARID,    INITIATOR12_ARID,    INITIATOR13_ARID,    INITIATOR14_ARID,
                                INITIATOR15_ARID,
  
  input  wire [ADDR_WIDTH-1:0]  INITIATOR0_ARADDR,   INITIATOR1_ARADDR,   INITIATOR2_ARADDR,   INITIATOR3_ARADDR,   INITIATOR4_ARADDR,
                                INITIATOR5_ARADDR,   INITIATOR6_ARADDR,   INITIATOR7_ARADDR,   INITIATOR8_ARADDR,   INITIATOR9_ARADDR,
                                INITIATOR10_ARADDR,  INITIATOR11_ARADDR,  INITIATOR12_ARADDR,  INITIATOR13_ARADDR,  INITIATOR14_ARADDR,
                                INITIATOR15_ARADDR,
  
  input  wire [7:0]             INITIATOR0_ARLEN,    INITIATOR1_ARLEN,    INITIATOR2_ARLEN,    INITIATOR3_ARLEN,    INITIATOR4_ARLEN,
                                INITIATOR5_ARLEN,    INITIATOR6_ARLEN,    INITIATOR7_ARLEN,    INITIATOR8_ARLEN,    INITIATOR9_ARLEN,
                                INITIATOR10_ARLEN,   INITIATOR11_ARLEN,   INITIATOR12_ARLEN,   INITIATOR13_ARLEN,   INITIATOR14_ARLEN,
                                INITIATOR15_ARLEN,
  
  input  wire [2:0]             INITIATOR0_ARSIZE,   INITIATOR1_ARSIZE,   INITIATOR2_ARSIZE,   INITIATOR3_ARSIZE,   INITIATOR4_ARSIZE,
                                INITIATOR5_ARSIZE,   INITIATOR6_ARSIZE,   INITIATOR7_ARSIZE,   INITIATOR8_ARSIZE,   INITIATOR9_ARSIZE,
                                INITIATOR10_ARSIZE,  INITIATOR11_ARSIZE,  INITIATOR12_ARSIZE,  INITIATOR13_ARSIZE,  INITIATOR14_ARSIZE,
                                INITIATOR15_ARSIZE,
  
  input  wire [1:0]             INITIATOR0_ARBURST,  INITIATOR1_ARBURST,  INITIATOR2_ARBURST,  INITIATOR3_ARBURST,  INITIATOR4_ARBURST,
                                INITIATOR5_ARBURST,  INITIATOR6_ARBURST,  INITIATOR7_ARBURST,  INITIATOR8_ARBURST,  INITIATOR9_ARBURST,
                                INITIATOR10_ARBURST, INITIATOR11_ARBURST, INITIATOR12_ARBURST, INITIATOR13_ARBURST, INITIATOR14_ARBURST,
                                INITIATOR15_ARBURST,
  
  // ARLOCK (0 to 15)
  input  wire [I0_LOCK_WIDTH-1:0]   INITIATOR0_ARLOCK,
  input  wire [I1_LOCK_WIDTH-1:0]   INITIATOR1_ARLOCK,
  input  wire [I2_LOCK_WIDTH-1:0]   INITIATOR2_ARLOCK,
  input  wire [I3_LOCK_WIDTH-1:0]   INITIATOR3_ARLOCK,
  input  wire [I4_LOCK_WIDTH-1:0]   INITIATOR4_ARLOCK,
  input  wire [I5_LOCK_WIDTH-1:0]   INITIATOR5_ARLOCK,
  input  wire [I6_LOCK_WIDTH-1:0]   INITIATOR6_ARLOCK,
  input  wire [I7_LOCK_WIDTH-1:0]   INITIATOR7_ARLOCK,
  input  wire [I8_LOCK_WIDTH-1:0]   INITIATOR8_ARLOCK,
  input  wire [I9_LOCK_WIDTH-1:0]   INITIATOR9_ARLOCK,
  input  wire [I10_LOCK_WIDTH-1:0]  INITIATOR10_ARLOCK,
  input  wire [I11_LOCK_WIDTH-1:0]  INITIATOR11_ARLOCK,
  input  wire [I12_LOCK_WIDTH-1:0]  INITIATOR12_ARLOCK,
  input  wire [I13_LOCK_WIDTH-1:0]  INITIATOR13_ARLOCK,
  input  wire [I14_LOCK_WIDTH-1:0]  INITIATOR14_ARLOCK,
  input  wire [I15_LOCK_WIDTH-1:0]  INITIATOR15_ARLOCK,

  
  input  wire [3:0]             INITIATOR0_ARCACHE,  INITIATOR1_ARCACHE,  INITIATOR2_ARCACHE,  INITIATOR3_ARCACHE,  INITIATOR4_ARCACHE,
                                INITIATOR5_ARCACHE,  INITIATOR6_ARCACHE,  INITIATOR7_ARCACHE,  INITIATOR8_ARCACHE,  INITIATOR9_ARCACHE,
                                INITIATOR10_ARCACHE, INITIATOR11_ARCACHE, INITIATOR12_ARCACHE, INITIATOR13_ARCACHE, INITIATOR14_ARCACHE,
                                INITIATOR15_ARCACHE,
  
  input  wire [2:0]             INITIATOR0_ARPROT,   INITIATOR1_ARPROT,   INITIATOR2_ARPROT,   INITIATOR3_ARPROT,   INITIATOR4_ARPROT,
                                INITIATOR5_ARPROT,   INITIATOR6_ARPROT,   INITIATOR7_ARPROT,   INITIATOR8_ARPROT,   INITIATOR9_ARPROT,
                                INITIATOR10_ARPROT,  INITIATOR11_ARPROT,  INITIATOR12_ARPROT,  INITIATOR13_ARPROT,  INITIATOR14_ARPROT,
                                INITIATOR15_ARPROT,
  
  input  wire [3:0]             INITIATOR0_ARREGION, INITIATOR1_ARREGION, INITIATOR2_ARREGION, INITIATOR3_ARREGION, INITIATOR4_ARREGION,
                                INITIATOR5_ARREGION, INITIATOR6_ARREGION, INITIATOR7_ARREGION, INITIATOR8_ARREGION, INITIATOR9_ARREGION,
                                INITIATOR10_ARREGION,INITIATOR11_ARREGION,INITIATOR12_ARREGION,INITIATOR13_ARREGION,INITIATOR14_ARREGION,
                                INITIATOR15_ARREGION,
  
  input  wire [3:0]             INITIATOR0_ARQOS,    INITIATOR1_ARQOS,    INITIATOR2_ARQOS,    INITIATOR3_ARQOS,    INITIATOR4_ARQOS,
                                INITIATOR5_ARQOS,    INITIATOR6_ARQOS,    INITIATOR7_ARQOS,    INITIATOR8_ARQOS,    INITIATOR9_ARQOS,
                                INITIATOR10_ARQOS,   INITIATOR11_ARQOS,   INITIATOR12_ARQOS,   INITIATOR13_ARQOS,   INITIATOR14_ARQOS,
                                INITIATOR15_ARQOS,
  
  input  wire [USER_WIDTH-1:0]  INITIATOR0_ARUSER,   INITIATOR1_ARUSER,   INITIATOR2_ARUSER,   INITIATOR3_ARUSER,   INITIATOR4_ARUSER,
                                INITIATOR5_ARUSER,   INITIATOR6_ARUSER,   INITIATOR7_ARUSER,   INITIATOR8_ARUSER,   INITIATOR9_ARUSER,
                                INITIATOR10_ARUSER,  INITIATOR11_ARUSER,  INITIATOR12_ARUSER,  INITIATOR13_ARUSER,  INITIATOR14_ARUSER,
                                INITIATOR15_ARUSER,
  
  input  wire                   INITIATOR0_ARVALID,  INITIATOR1_ARVALID,  INITIATOR2_ARVALID,  INITIATOR3_ARVALID,  INITIATOR4_ARVALID,
                                INITIATOR5_ARVALID,  INITIATOR6_ARVALID,  INITIATOR7_ARVALID,  INITIATOR8_ARVALID,  INITIATOR9_ARVALID,
                                INITIATOR10_ARVALID, INITIATOR11_ARVALID, INITIATOR12_ARVALID, INITIATOR13_ARVALID, INITIATOR14_ARVALID,
                                INITIATOR15_ARVALID,
  
  output wire                   INITIATOR0_ARREADY,  INITIATOR1_ARREADY,  INITIATOR2_ARREADY,  INITIATOR3_ARREADY,  INITIATOR4_ARREADY,
                                INITIATOR5_ARREADY,  INITIATOR6_ARREADY,  INITIATOR7_ARREADY,  INITIATOR8_ARREADY,  INITIATOR9_ARREADY,
                                INITIATOR10_ARREADY, INITIATOR11_ARREADY, INITIATOR12_ARREADY, INITIATOR13_ARREADY, INITIATOR14_ARREADY,
                                INITIATOR15_ARREADY,
                
  // INITIATOR Read Data Ports                
  output wire [ID_WIDTH-1:0]    INITIATOR0_RID,  INITIATOR1_RID,  INITIATOR2_RID,  INITIATOR3_RID,  INITIATOR4_RID,  
                                INITIATOR5_RID,  INITIATOR6_RID,  INITIATOR7_RID,  INITIATOR8_RID,  INITIATOR9_RID,  
								INITIATOR10_RID, INITIATOR11_RID, INITIATOR12_RID, INITIATOR13_RID, INITIATOR14_RID,  
								INITIATOR15_RID,
  output wire [INITIATOR0_DATA_WIDTH-1:0]    INITIATOR0_RDATA,
  output wire [INITIATOR1_DATA_WIDTH-1:0]    INITIATOR1_RDATA,  
  output wire [INITIATOR2_DATA_WIDTH-1:0]    INITIATOR2_RDATA,  
  output wire [INITIATOR3_DATA_WIDTH-1:0]    INITIATOR3_RDATA,  
  output wire [INITIATOR4_DATA_WIDTH-1:0]    INITIATOR4_RDATA,  
  output wire [INITIATOR5_DATA_WIDTH-1:0]    INITIATOR5_RDATA,  
  output wire [INITIATOR6_DATA_WIDTH-1:0]    INITIATOR6_RDATA,  
  output wire [INITIATOR7_DATA_WIDTH-1:0]    INITIATOR7_RDATA,
  output wire [INITIATOR8_DATA_WIDTH-1:0]    INITIATOR8_RDATA,
  output wire [INITIATOR9_DATA_WIDTH-1:0]    INITIATOR9_RDATA,
  output wire [INITIATOR10_DATA_WIDTH-1:0]   INITIATOR10_RDATA,
  output wire [INITIATOR11_DATA_WIDTH-1:0]   INITIATOR11_RDATA,
  output wire [INITIATOR12_DATA_WIDTH-1:0]   INITIATOR12_RDATA,
  output wire [INITIATOR13_DATA_WIDTH-1:0]   INITIATOR13_RDATA,
  output wire [INITIATOR14_DATA_WIDTH-1:0]   INITIATOR14_RDATA,
  output wire [INITIATOR15_DATA_WIDTH-1:0]   INITIATOR15_RDATA,
  
  output wire [1:0]                      INITIATOR0_RRESP,  INITIATOR1_RRESP,  INITIATOR2_RRESP,  INITIATOR3_RRESP,  INITIATOR4_RRESP,  
                                         INITIATOR5_RRESP,  INITIATOR6_RRESP,  INITIATOR7_RRESP,  INITIATOR8_RRESP,  INITIATOR9_RRESP,  
										 INITIATOR10_RRESP, INITIATOR11_RRESP, INITIATOR12_RRESP, INITIATOR13_RRESP, INITIATOR14_RRESP,  
										 INITIATOR15_RRESP,
  output wire                            INITIATOR0_RLAST,  INITIATOR1_RLAST,  INITIATOR2_RLAST,  INITIATOR3_RLAST,  INITIATOR4_RLAST,  
                                         INITIATOR5_RLAST,  INITIATOR6_RLAST,  INITIATOR7_RLAST,  INITIATOR8_RLAST,  INITIATOR9_RLAST, 
										 INITIATOR10_RLAST, INITIATOR11_RLAST, INITIATOR12_RLAST, INITIATOR13_RLAST, INITIATOR14_RLAST,  
										 INITIATOR15_RLAST,
  output wire [USER_WIDTH-1:0]           INITIATOR0_RUSER,  INITIATOR1_RUSER,  INITIATOR2_RUSER,  INITIATOR3_RUSER,  INITIATOR4_RUSER,  
                                         INITIATOR5_RUSER,  INITIATOR6_RUSER,  INITIATOR7_RUSER,  INITIATOR8_RUSER,  INITIATOR9_RUSER,  
										 INITIATOR10_RUSER, INITIATOR11_RUSER, INITIATOR12_RUSER, INITIATOR13_RUSER, INITIATOR14_RUSER,  
										 INITIATOR15_RUSER,
  output wire                            INITIATOR0_RVALID,  INITIATOR1_RVALID,  INITIATOR2_RVALID,  INITIATOR3_RVALID,  INITIATOR4_RVALID, 
                                         INITIATOR5_RVALID,  INITIATOR6_RVALID,  INITIATOR7_RVALID,  INITIATOR8_RVALID,  INITIATOR9_RVALID, 
										 INITIATOR10_RVALID, INITIATOR11_RVALID, INITIATOR12_RVALID, INITIATOR13_RVALID, INITIATOR14_RVALID, 
										 INITIATOR15_RVALID,
  input  wire                            INITIATOR0_RREADY,  INITIATOR1_RREADY,  INITIATOR2_RREADY,  INITIATOR3_RREADY,  INITIATOR4_RREADY, 
                                         INITIATOR5_RREADY,  INITIATOR6_RREADY,  INITIATOR7_RREADY,  INITIATOR8_RREADY,  INITIATOR9_RREADY, 
										 INITIATOR10_RREADY, INITIATOR11_RREADY, INITIATOR12_RREADY, INITIATOR13_RREADY, INITIATOR14_RREADY, 
										 INITIATOR15_RREADY,
                   

  //================================================ Target Ports  ======================================================================//
   
  // Target Write Address Port - Target ID is composed of INITIATOR Port ID concatenated with transaction ID
  output wire [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]  TARGET0_AWID,     TARGET1_AWID,     TARGET2_AWID,      TARGET3_AWID,     TARGET4_AWID,   
                                                     TARGET5_AWID,     TARGET6_AWID,     TARGET7_AWID,      TARGET8_AWID,     TARGET9_AWID,     
													 TARGET10_AWID,    TARGET11_AWID,    TARGET12_AWID,     TARGET13_AWID,    TARGET14_AWID,   
													 TARGET15_AWID,    TARGET16_AWID,    TARGET17_AWID,     TARGET18_AWID,    TARGET19_AWID,   
													 TARGET20_AWID,    TARGET21_AWID,    TARGET22_AWID,     TARGET23_AWID,    TARGET24_AWID,  
													 TARGET25_AWID,    TARGET26_AWID,    TARGET27_AWID,     TARGET28_AWID,    TARGET29_AWID,  
													 TARGET30_AWID,    TARGET31_AWID,
                                                  
  output wire [ADDR_WIDTH-1:0]    TARGET0_AWADDR,   TARGET1_AWADDR,   TARGET2_AWADDR,   TARGET3_AWADDR,    TARGET4_AWADDR,   
                                  TARGET5_AWADDR,   TARGET6_AWADDR,   TARGET7_AWADDR,   TARGET8_AWADDR,    TARGET9_AWADDR,   
								  TARGET10_AWADDR,  TARGET11_AWADDR,  TARGET12_AWADDR,  TARGET13_AWADDR,   TARGET14_AWADDR,  
								  TARGET15_AWADDR,  TARGET16_AWADDR,  TARGET17_AWADDR,  TARGET18_AWADDR,   TARGET19_AWADDR,   
								  TARGET20_AWADDR,  TARGET21_AWADDR,  TARGET22_AWADDR,  TARGET23_AWADDR,   TARGET24_AWADDR,  
								  TARGET25_AWADDR,  TARGET26_AWADDR,  TARGET27_AWADDR,  TARGET28_AWADDR,   TARGET29_AWADDR,  
								  TARGET30_AWADDR,  TARGET31_AWADDR,
								  
                                                  
  output wire [7:0]               TARGET0_AWLEN,    TARGET1_AWLEN,    TARGET2_AWLEN,    TARGET3_AWLEN,    TARGET4_AWLEN,    TARGET5_AWLEN,    
                                  TARGET6_AWLEN,    TARGET7_AWLEN,    TARGET8_AWLEN,    TARGET9_AWLEN,    TARGET10_AWLEN,   TARGET11_AWLEN,  
								  TARGET12_AWLEN,   TARGET13_AWLEN,   TARGET14_AWLEN,   TARGET15_AWLEN,   TARGET16_AWLEN,   TARGET17_AWLEN, 
								  TARGET18_AWLEN,   TARGET19_AWLEN,   TARGET20_AWLEN,   TARGET21_AWLEN,   TARGET22_AWLEN,   TARGET23_AWLEN,
                                  TARGET24_AWLEN,   TARGET25_AWLEN,   TARGET26_AWLEN,   TARGET27_AWLEN,   TARGET28_AWLEN,   TARGET29_AWLEN, 
								  TARGET30_AWLEN,   TARGET31_AWLEN,
                                                  
  
  output wire [2:0]               TARGET0_AWSIZE,   TARGET1_AWSIZE,   TARGET2_AWSIZE,   TARGET3_AWSIZE,   TARGET4_AWSIZE,   TARGET5_AWSIZE,   
                                  TARGET6_AWSIZE,   TARGET7_AWSIZE,   TARGET8_AWSIZE,   TARGET9_AWSIZE,   TARGET10_AWSIZE,  TARGET11_AWSIZE, 
								  TARGET12_AWSIZE,  TARGET13_AWSIZE,  TARGET14_AWSIZE,  TARGET15_AWSIZE,  TARGET16_AWSIZE,  TARGET17_AWSIZE,  
								  TARGET18_AWSIZE,  TARGET19_AWSIZE,  TARGET20_AWSIZE,  TARGET21_AWSIZE,  TARGET22_AWSIZE,  TARGET23_AWSIZE,
                                  TARGET24_AWSIZE,  TARGET25_AWSIZE,  TARGET26_AWSIZE,  TARGET27_AWSIZE,  TARGET28_AWSIZE,  TARGET29_AWSIZE,  
								  TARGET30_AWSIZE,  TARGET31_AWSIZE,


  output wire [1:0]               TARGET0_AWBURST,  TARGET1_AWBURST,  TARGET2_AWBURST,   TARGET3_AWBURST,  TARGET4_AWBURST,  TARGET5_AWBURST,  
                                  TARGET6_AWBURST,  TARGET7_AWBURST,  TARGET8_AWBURST,   TARGET9_AWBURST,  TARGET10_AWBURST, TARGET11_AWBURST,
								  TARGET12_AWBURST, TARGET13_AWBURST, TARGET14_AWBURST,  TARGET15_AWBURST, TARGET16_AWBURST, TARGET17_AWBURST, 
								  TARGET18_AWBURST, TARGET19_AWBURST, TARGET20_AWBURST,  TARGET21_AWBURST, TARGET22_AWBURST, TARGET23_AWBURST,
                                  TARGET24_AWBURST, TARGET25_AWBURST, TARGET26_AWBURST,  TARGET27_AWBURST, TARGET28_AWBURST, TARGET29_AWBURST, 
								  TARGET30_AWBURST,  TARGET31_AWBURST,

  
  output wire [T0_LOCK_WIDTH-1:0]  TARGET0_AWLOCK,
  output wire [T1_LOCK_WIDTH-1:0]  TARGET1_AWLOCK,
  output wire [T2_LOCK_WIDTH-1:0]  TARGET2_AWLOCK,
  output wire [T3_LOCK_WIDTH-1:0]  TARGET3_AWLOCK,
  output wire [T4_LOCK_WIDTH-1:0]  TARGET4_AWLOCK,
  output wire [T5_LOCK_WIDTH-1:0]  TARGET5_AWLOCK,
  output wire [T6_LOCK_WIDTH-1:0]  TARGET6_AWLOCK,
  output wire [T7_LOCK_WIDTH-1:0]  TARGET7_AWLOCK,
  output wire [T8_LOCK_WIDTH-1:0]  TARGET8_AWLOCK,
  output wire [T9_LOCK_WIDTH-1:0]  TARGET9_AWLOCK,
  output wire [T10_LOCK_WIDTH-1:0] TARGET10_AWLOCK,
  output wire [T11_LOCK_WIDTH-1:0] TARGET11_AWLOCK,
  output wire [T12_LOCK_WIDTH-1:0] TARGET12_AWLOCK,
  output wire [T13_LOCK_WIDTH-1:0] TARGET13_AWLOCK,
  output wire [T14_LOCK_WIDTH-1:0] TARGET14_AWLOCK,
  output wire [T15_LOCK_WIDTH-1:0] TARGET15_AWLOCK,
  output wire [T16_LOCK_WIDTH-1:0] TARGET16_AWLOCK,
  output wire [T17_LOCK_WIDTH-1:0] TARGET17_AWLOCK,
  output wire [T18_LOCK_WIDTH-1:0] TARGET18_AWLOCK,
  output wire [T19_LOCK_WIDTH-1:0] TARGET19_AWLOCK,
  output wire [T20_LOCK_WIDTH-1:0] TARGET20_AWLOCK,
  output wire [T21_LOCK_WIDTH-1:0] TARGET21_AWLOCK,
  output wire [T22_LOCK_WIDTH-1:0] TARGET22_AWLOCK,
  output wire [T23_LOCK_WIDTH-1:0] TARGET23_AWLOCK,
  output wire [T24_LOCK_WIDTH-1:0] TARGET24_AWLOCK,
  output wire [T25_LOCK_WIDTH-1:0] TARGET25_AWLOCK,
  output wire [T26_LOCK_WIDTH-1:0] TARGET26_AWLOCK,
  output wire [T27_LOCK_WIDTH-1:0] TARGET27_AWLOCK,
  output wire [T28_LOCK_WIDTH-1:0] TARGET28_AWLOCK,
  output wire [T29_LOCK_WIDTH-1:0] TARGET29_AWLOCK,
  output wire [T30_LOCK_WIDTH-1:0] TARGET30_AWLOCK,
  output wire [T31_LOCK_WIDTH-1:0] TARGET31_AWLOCK,

  output wire [3:0]               TARGET0_AWCACHE,   TARGET1_AWCACHE,   TARGET2_AWCACHE,   TARGET3_AWCACHE,   TARGET4_AWCACHE,   TARGET5_AWCACHE,
                                  TARGET6_AWCACHE,   TARGET7_AWCACHE,   TARGET8_AWCACHE,   TARGET9_AWCACHE,   TARGET10_AWCACHE,  TARGET11_AWCACHE,  
								  TARGET12_AWCACHE,  TARGET13_AWCACHE,  TARGET14_AWCACHE,  TARGET15_AWCACHE,  TARGET16_AWCACHE,  TARGET17_AWCACHE,  
                                  TARGET18_AWCACHE,  TARGET19_AWCACHE,  TARGET20_AWCACHE,  TARGET21_AWCACHE,  TARGET22_AWCACHE,  TARGET23_AWCACHE,
                                  TARGET24_AWCACHE,  TARGET25_AWCACHE,  TARGET26_AWCACHE,  TARGET27_AWCACHE,  TARGET28_AWCACHE,  TARGET29_AWCACHE, 
								  TARGET30_AWCACHE,  TARGET31_AWCACHE,

  output wire [2:0]               TARGET0_AWPROT,   TARGET1_AWPROT,   TARGET2_AWPROT,   TARGET3_AWPROT,   TARGET4_AWPROT,   TARGET5_AWPROT,   
                                  TARGET6_AWPROT,   TARGET7_AWPROT,   TARGET8_AWPROT,   TARGET9_AWPROT,   TARGET10_AWPROT,  TARGET11_AWPROT,  
                                  TARGET12_AWPROT,  TARGET13_AWPROT,  TARGET14_AWPROT,  TARGET15_AWPROT,  TARGET16_AWPROT,  TARGET17_AWPROT,  
                                  TARGET18_AWPROT,  TARGET19_AWPROT,  TARGET20_AWPROT,  TARGET21_AWPROT,  TARGET22_AWPROT,  TARGET23_AWPROT,  
                                  TARGET24_AWPROT,  TARGET25_AWPROT,  TARGET26_AWPROT,  TARGET27_AWPROT,  TARGET28_AWPROT,  TARGET29_AWPROT,  
								  TARGET30_AWPROT,  TARGET31_AWPROT,


  output wire [3:0]               TARGET0_AWREGION,   TARGET1_AWREGION,   TARGET2_AWREGION,   TARGET3_AWREGION,   TARGET4_AWREGION,   
                                  TARGET5_AWREGION,   TARGET6_AWREGION,   TARGET7_AWREGION,   TARGET8_AWREGION,   TARGET9_AWREGION,   
								  TARGET10_AWREGION,  TARGET11_AWREGION,  TARGET12_AWREGION,  TARGET13_AWREGION,  TARGET14_AWREGION,  
                                  TARGET15_AWREGION,  TARGET16_AWREGION,  TARGET17_AWREGION,  TARGET18_AWREGION,  TARGET19_AWREGION,  
								  TARGET20_AWREGION,  TARGET21_AWREGION,  TARGET22_AWREGION,  TARGET23_AWREGION,  TARGET24_AWREGION,  
								  TARGET25_AWREGION,  TARGET26_AWREGION,  TARGET27_AWREGION,  TARGET28_AWREGION,  TARGET29_AWREGION,  
								  TARGET30_AWREGION,  TARGET31_AWREGION,

  output wire [3:0]               TARGET0_AWQOS,   TARGET1_AWQOS,  TARGET2_AWQOS,   TARGET3_AWQOS,  TARGET4_AWQOS,   TARGET5_AWQOS,   
                                  TARGET6_AWQOS,   TARGET7_AWQOS,  TARGET8_AWQOS,   TARGET9_AWQOS,  TARGET10_AWQOS,  TARGET11_AWQOS, 
								  TARGET12_AWQOS,  TARGET13_AWQOS, TARGET14_AWQOS,  TARGET15_AWQOS, TARGET16_AWQOS,  TARGET17_AWQOS, 
								  TARGET18_AWQOS,  TARGET19_AWQOS, TARGET20_AWQOS,  TARGET21_AWQOS, TARGET22_AWQOS,  TARGET23_AWQOS,  
                                  TARGET24_AWQOS,  TARGET25_AWQOS, TARGET26_AWQOS,  TARGET27_AWQOS, TARGET28_AWQOS,  TARGET29_AWQOS,
								  TARGET30_AWQOS,  TARGET31_AWQOS,
                                  
                                  
  output wire [USER_WIDTH-1:0]    TARGET0_AWUSER,   TARGET1_AWUSER,   TARGET2_AWUSER,   TARGET3_AWUSER,   TARGET4_AWUSER,   TARGET5_AWUSER,   
                                  TARGET6_AWUSER,   TARGET7_AWUSER,   TARGET8_AWUSER,   TARGET9_AWUSER,   TARGET10_AWUSER,  TARGET11_AWUSER,  
								  TARGET12_AWUSER,  TARGET13_AWUSER,  TARGET14_AWUSER,  TARGET15_AWUSER,  TARGET16_AWUSER,  TARGET17_AWUSER,  
								  TARGET18_AWUSER,  TARGET19_AWUSER,  TARGET20_AWUSER,  TARGET21_AWUSER,  TARGET22_AWUSER,  TARGET23_AWUSER,
                                  TARGET24_AWUSER,  TARGET25_AWUSER,  TARGET26_AWUSER,  TARGET27_AWUSER,  TARGET28_AWUSER,  TARGET29_AWUSER,  
								  TARGET30_AWUSER,  TARGET31_AWUSER,

  output wire                     TARGET0_AWVALID,   TARGET1_AWVALID,   TARGET2_AWVALID,   TARGET3_AWVALID,   TARGET4_AWVALID,  TARGET5_AWVALID,  
                                  TARGET6_AWVALID,   TARGET7_AWVALID,   TARGET8_AWVALID,   TARGET9_AWVALID,   TARGET10_AWVALID, TARGET11_AWVALID, 
								  TARGET12_AWVALID,  TARGET13_AWVALID,  TARGET14_AWVALID,  TARGET15_AWVALID,  TARGET16_AWVALID, TARGET17_AWVALID, 
								  TARGET18_AWVALID,  TARGET19_AWVALID,  TARGET20_AWVALID,  TARGET21_AWVALID,  TARGET22_AWVALID, TARGET23_AWVALID,  
                                  TARGET24_AWVALID,  TARGET25_AWVALID,  TARGET26_AWVALID,  TARGET27_AWVALID,  TARGET28_AWVALID, TARGET29_AWVALID, 
								  TARGET30_AWVALID,  TARGET31_AWVALID,

  input  wire                     TARGET0_AWREADY,   TARGET1_AWREADY,   TARGET2_AWREADY,   TARGET3_AWREADY,   TARGET4_AWREADY,   TARGET5_AWREADY, 
                                  TARGET6_AWREADY,   TARGET7_AWREADY,   TARGET8_AWREADY,   TARGET9_AWREADY,   TARGET10_AWREADY,  TARGET11_AWREADY,
								  TARGET12_AWREADY,  TARGET13_AWREADY,  TARGET14_AWREADY,  TARGET15_AWREADY,  TARGET16_AWREADY,  TARGET17_AWREADY,
								  TARGET18_AWREADY,  TARGET19_AWREADY,  TARGET20_AWREADY,  TARGET21_AWREADY,  TARGET22_AWREADY,  TARGET23_AWREADY,
                                  TARGET24_AWREADY,  TARGET25_AWREADY,  TARGET26_AWREADY,  TARGET27_AWREADY,  TARGET28_AWREADY,  TARGET29_AWREADY,
								  TARGET30_AWREADY,  TARGET31_AWREADY,
   
  // Target Write Data Ports
  output wire [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]  TARGET0_WID,  TARGET1_WID,  TARGET2_WID,  TARGET3_WID,  TARGET4_WID,  TARGET5_WID,  
                                                     TARGET6_WID,  TARGET7_WID,  TARGET8_WID,  TARGET9_WID,  TARGET10_WID, TARGET11_WID, 
													 TARGET12_WID, TARGET13_WID, TARGET14_WID, TARGET15_WID, TARGET16_WID, TARGET17_WID, 
													 TARGET18_WID, TARGET19_WID, TARGET20_WID, TARGET21_WID, TARGET22_WID, TARGET23_WID, 
													 TARGET24_WID, TARGET25_WID, TARGET26_WID, TARGET27_WID, TARGET28_WID, TARGET29_WID, 
													 TARGET30_WID, TARGET31_WID,

  output wire [TARGET0_DATA_WIDTH-1:0]      TARGET0_WDATA,  
  output wire [TARGET1_DATA_WIDTH-1:0]      TARGET1_WDATA,  
  output wire [TARGET2_DATA_WIDTH-1:0]      TARGET2_WDATA,  
  output wire [TARGET3_DATA_WIDTH-1:0]      TARGET3_WDATA,  
  output wire [TARGET4_DATA_WIDTH-1:0]      TARGET4_WDATA,  
  output wire [TARGET5_DATA_WIDTH-1:0]      TARGET5_WDATA,  
  output wire [TARGET6_DATA_WIDTH-1:0]      TARGET6_WDATA,   
  output wire [TARGET7_DATA_WIDTH-1:0]      TARGET7_WDATA,  
  output wire [TARGET8_DATA_WIDTH-1:0]      TARGET8_WDATA,  
  output wire [TARGET9_DATA_WIDTH-1:0]      TARGET9_WDATA,  
  output wire [TARGET10_DATA_WIDTH-1:0]     TARGET10_WDATA,  
  output wire [TARGET11_DATA_WIDTH-1:0]     TARGET11_WDATA,  
  output wire [TARGET12_DATA_WIDTH-1:0]     TARGET12_WDATA,  
  output wire [TARGET13_DATA_WIDTH-1:0]     TARGET13_WDATA,  
  output wire [TARGET14_DATA_WIDTH-1:0]     TARGET14_WDATA,   
  output wire [TARGET15_DATA_WIDTH-1:0]     TARGET15_WDATA,  
  output wire [TARGET16_DATA_WIDTH-1:0]     TARGET16_WDATA,  
  output wire [TARGET17_DATA_WIDTH-1:0]     TARGET17_WDATA,  
  output wire [TARGET18_DATA_WIDTH-1:0]     TARGET18_WDATA,  
  output wire [TARGET19_DATA_WIDTH-1:0]     TARGET19_WDATA,  
  output wire [TARGET20_DATA_WIDTH-1:0]     TARGET20_WDATA,  
  output wire [TARGET21_DATA_WIDTH-1:0]     TARGET21_WDATA,  
  output wire [TARGET22_DATA_WIDTH-1:0]     TARGET22_WDATA,   
  output wire [TARGET23_DATA_WIDTH-1:0]     TARGET23_WDATA,  
  output wire [TARGET24_DATA_WIDTH-1:0]     TARGET24_WDATA,  
  output wire [TARGET25_DATA_WIDTH-1:0]     TARGET25_WDATA,  
  output wire [TARGET26_DATA_WIDTH-1:0]     TARGET26_WDATA,  
  output wire [TARGET27_DATA_WIDTH-1:0]     TARGET27_WDATA,  
  output wire [TARGET28_DATA_WIDTH-1:0]     TARGET28_WDATA,  
  output wire [TARGET29_DATA_WIDTH-1:0]     TARGET29_WDATA,  
  output wire [TARGET30_DATA_WIDTH-1:0]     TARGET30_WDATA,   
  output wire [TARGET31_DATA_WIDTH-1:0]     TARGET31_WDATA,
  
  
  output wire [(TARGET0_DATA_WIDTH/8)-1:0]     TARGET0_WSTRB,
  output wire [(TARGET1_DATA_WIDTH/8)-1:0]     TARGET1_WSTRB,  
  output wire [(TARGET2_DATA_WIDTH/8)-1:0]     TARGET2_WSTRB,  
  output wire [(TARGET3_DATA_WIDTH/8)-1:0]     TARGET3_WSTRB,  
  output wire [(TARGET4_DATA_WIDTH/8)-1:0]     TARGET4_WSTRB,  
  output wire [(TARGET5_DATA_WIDTH/8)-1:0]     TARGET5_WSTRB,  
  output wire [(TARGET6_DATA_WIDTH/8)-1:0]     TARGET6_WSTRB,  
  output wire [(TARGET7_DATA_WIDTH/8)-1:0]     TARGET7_WSTRB,
  output wire [(TARGET8_DATA_WIDTH/8)-1:0]     TARGET8_WSTRB,
  output wire [(TARGET9_DATA_WIDTH/8)-1:0]     TARGET9_WSTRB,  
  output wire [(TARGET10_DATA_WIDTH/8)-1:0]    TARGET10_WSTRB,  
  output wire [(TARGET11_DATA_WIDTH/8)-1:0]    TARGET11_WSTRB,  
  output wire [(TARGET12_DATA_WIDTH/8)-1:0]    TARGET12_WSTRB,  
  output wire [(TARGET13_DATA_WIDTH/8)-1:0]    TARGET13_WSTRB,  
  output wire [(TARGET14_DATA_WIDTH/8)-1:0]    TARGET14_WSTRB,  
  output wire [(TARGET15_DATA_WIDTH/8)-1:0]    TARGET15_WSTRB,
  output wire [(TARGET16_DATA_WIDTH/8)-1:0]    TARGET16_WSTRB,
  output wire [(TARGET17_DATA_WIDTH/8)-1:0]    TARGET17_WSTRB,  
  output wire [(TARGET18_DATA_WIDTH/8)-1:0]    TARGET18_WSTRB,  
  output wire [(TARGET19_DATA_WIDTH/8)-1:0]    TARGET19_WSTRB,  
  output wire [(TARGET20_DATA_WIDTH/8)-1:0]    TARGET20_WSTRB,  
  output wire [(TARGET21_DATA_WIDTH/8)-1:0]    TARGET21_WSTRB,  
  output wire [(TARGET22_DATA_WIDTH/8)-1:0]    TARGET22_WSTRB,  
  output wire [(TARGET23_DATA_WIDTH/8)-1:0]    TARGET23_WSTRB,
  output wire [(TARGET24_DATA_WIDTH/8)-1:0]    TARGET24_WSTRB,
  output wire [(TARGET25_DATA_WIDTH/8)-1:0]    TARGET25_WSTRB,  
  output wire [(TARGET26_DATA_WIDTH/8)-1:0]    TARGET26_WSTRB,  
  output wire [(TARGET27_DATA_WIDTH/8)-1:0]    TARGET27_WSTRB,  
  output wire [(TARGET28_DATA_WIDTH/8)-1:0]    TARGET28_WSTRB,  
  output wire [(TARGET29_DATA_WIDTH/8)-1:0]    TARGET29_WSTRB,  
  output wire [(TARGET30_DATA_WIDTH/8)-1:0]    TARGET30_WSTRB,  
  output wire [(TARGET31_DATA_WIDTH/8)-1:0]    TARGET31_WSTRB,
  
  
  output wire                         TARGET0_WLAST,  TARGET1_WLAST,  TARGET2_WLAST,  TARGET3_WLAST,  TARGET4_WLAST,  TARGET5_WLAST,  
                                      TARGET6_WLAST,  TARGET7_WLAST,  TARGET8_WLAST,  TARGET9_WLAST,  TARGET10_WLAST, TARGET11_WLAST, 
									  TARGET12_WLAST, TARGET13_WLAST, TARGET14_WLAST, TARGET15_WLAST, TARGET16_WLAST, TARGET17_WLAST, 
									  TARGET18_WLAST, TARGET19_WLAST, TARGET20_WLAST, TARGET21_WLAST, TARGET22_WLAST, TARGET23_WLAST, 
                                      TARGET24_WLAST, TARGET25_WLAST, TARGET26_WLAST, TARGET27_WLAST, TARGET28_WLAST, TARGET29_WLAST, 
									  TARGET30_WLAST, TARGET31_WLAST,
                                      
  output wire [USER_WIDTH-1:0]        TARGET0_WUSER,  TARGET1_WUSER,  TARGET2_WUSER,  TARGET3_WUSER,  TARGET4_WUSER,  TARGET5_WUSER,  
                                      TARGET6_WUSER,  TARGET7_WUSER,  TARGET8_WUSER,  TARGET9_WUSER,  TARGET10_WUSER, TARGET11_WUSER, 
									  TARGET12_WUSER, TARGET13_WUSER, TARGET14_WUSER, TARGET15_WUSER, TARGET16_WUSER, TARGET17_WUSER, 
									  TARGET18_WUSER, TARGET19_WUSER, TARGET20_WUSER, TARGET21_WUSER, TARGET22_WUSER, TARGET23_WUSER, 
                                      TARGET24_WUSER, TARGET25_WUSER, TARGET26_WUSER, TARGET27_WUSER, TARGET28_WUSER, TARGET29_WUSER, 
									  TARGET30_WUSER, TARGET31_WUSER,
                                      
  output wire                         TARGET0_WVALID,  TARGET1_WVALID,  TARGET2_WVALID,  TARGET3_WVALID,  TARGET4_WVALID,  TARGET5_WVALID,  
                                      TARGET6_WVALID,  TARGET7_WVALID,  TARGET8_WVALID,  TARGET9_WVALID,  TARGET10_WVALID, TARGET11_WVALID, 
									  TARGET12_WVALID, TARGET13_WVALID, TARGET14_WVALID, TARGET15_WVALID, TARGET16_WVALID, TARGET17_WVALID, 
									  TARGET18_WVALID, TARGET19_WVALID, TARGET20_WVALID, TARGET21_WVALID, TARGET22_WVALID, TARGET23_WVALID, 
                                      TARGET24_WVALID, TARGET25_WVALID, TARGET26_WVALID, TARGET27_WVALID, TARGET28_WVALID, TARGET29_WVALID,
									  TARGET30_WVALID, TARGET31_WVALID,
                                      
  input  wire                         TARGET0_WREADY,  TARGET1_WREADY,  TARGET2_WREADY,  TARGET3_WREADY,  TARGET4_WREADY,  TARGET5_WREADY,  
                                      TARGET6_WREADY,  TARGET7_WREADY,  TARGET8_WREADY,  TARGET9_WREADY,  TARGET10_WREADY, TARGET11_WREADY, 
									  TARGET12_WREADY, TARGET13_WREADY, TARGET14_WREADY, TARGET15_WREADY, TARGET16_WREADY, TARGET17_WREADY, 
									  TARGET18_WREADY, TARGET19_WREADY, TARGET20_WREADY, TARGET21_WREADY, TARGET22_WREADY, TARGET23_WREADY, 
                                      TARGET24_WREADY, TARGET25_WREADY, TARGET26_WREADY, TARGET27_WREADY, TARGET28_WREADY, TARGET29_WREADY,
									  TARGET30_WREADY, TARGET31_WREADY,

  // Target Write Response Ports
  input  wire [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] TARGET0_BID,  TARGET1_BID,  TARGET2_BID,  TARGET3_BID,  TARGET4_BID,  TARGET5_BID,  
                                                    TARGET6_BID,  TARGET7_BID,  TARGET8_BID,  TARGET9_BID,  TARGET10_BID, TARGET11_BID, 
													TARGET12_BID, TARGET13_BID, TARGET14_BID, TARGET15_BID, TARGET16_BID, TARGET17_BID, 
													TARGET18_BID, TARGET19_BID, TARGET20_BID, TARGET21_BID, TARGET22_BID, TARGET23_BID, 
                                                    TARGET24_BID, TARGET25_BID, TARGET26_BID, TARGET27_BID, TARGET28_BID, TARGET29_BID, 
													TARGET30_BID, TARGET31_BID,
                                                    
  input  wire [1:0]                                 TARGET0_BRESP,  TARGET1_BRESP,  TARGET2_BRESP,  TARGET3_BRESP,  TARGET4_BRESP,  TARGET5_BRESP, 
                                                    TARGET6_BRESP,  TARGET7_BRESP,  TARGET8_BRESP,  TARGET9_BRESP,  TARGET10_BRESP, TARGET11_BRESP, 
													TARGET12_BRESP, TARGET13_BRESP, TARGET14_BRESP, TARGET15_BRESP, TARGET16_BRESP, TARGET17_BRESP, 
													TARGET18_BRESP, TARGET19_BRESP, TARGET20_BRESP, TARGET21_BRESP, TARGET22_BRESP, TARGET23_BRESP, 
                                                    TARGET24_BRESP, TARGET25_BRESP, TARGET26_BRESP, TARGET27_BRESP, TARGET28_BRESP, TARGET29_BRESP,
													TARGET30_BRESP, TARGET31_BRESP,
                            
  input  wire [USER_WIDTH-1:0]                      TARGET0_BUSER,  TARGET1_BUSER,  TARGET2_BUSER,  TARGET3_BUSER,  TARGET4_BUSER,  TARGET5_BUSER,
                                                    TARGET6_BUSER,  TARGET7_BUSER,  TARGET8_BUSER,  TARGET9_BUSER,  TARGET10_BUSER, TARGET11_BUSER, 
													TARGET12_BUSER, TARGET13_BUSER, TARGET14_BUSER, TARGET15_BUSER, TARGET16_BUSER, TARGET17_BUSER, 
													TARGET18_BUSER, TARGET19_BUSER, TARGET20_BUSER, TARGET21_BUSER, TARGET22_BUSER, TARGET23_BUSER, 
                                                    TARGET24_BUSER, TARGET25_BUSER, TARGET26_BUSER, TARGET27_BUSER, TARGET28_BUSER, TARGET29_BUSER,
													TARGET30_BUSER, TARGET31_BUSER,
                                                    
  input  wire                                       TARGET0_BVALID,  TARGET1_BVALID,  TARGET2_BVALID,  TARGET3_BVALID,  TARGET4_BVALID,  
                                                    TARGET5_BVALID,  TARGET6_BVALID,  TARGET7_BVALID,  TARGET8_BVALID,  TARGET9_BVALID,  
													TARGET10_BVALID, TARGET11_BVALID, TARGET12_BVALID, TARGET13_BVALID, TARGET14_BVALID, 
													TARGET15_BVALID, TARGET16_BVALID, TARGET17_BVALID, TARGET18_BVALID, TARGET19_BVALID, 
													TARGET20_BVALID, TARGET21_BVALID, TARGET22_BVALID, TARGET23_BVALID, TARGET24_BVALID, 
													TARGET25_BVALID, TARGET26_BVALID, TARGET27_BVALID, TARGET28_BVALID, TARGET29_BVALID, 
													TARGET30_BVALID, TARGET31_BVALID,

  output wire                                       TARGET0_BREADY,  TARGET1_BREADY,  TARGET2_BREADY,  TARGET3_BREADY,  TARGET4_BREADY,  
                                                    TARGET5_BREADY,  TARGET6_BREADY,  TARGET7_BREADY,  TARGET8_BREADY,  TARGET9_BREADY,  
													TARGET10_BREADY, TARGET11_BREADY, TARGET12_BREADY, TARGET13_BREADY, TARGET14_BREADY,
													TARGET15_BREADY, TARGET16_BREADY, TARGET17_BREADY, TARGET18_BREADY, TARGET19_BREADY, 
													TARGET20_BREADY, TARGET21_BREADY, TARGET22_BREADY, TARGET23_BREADY, TARGET24_BREADY, 
													TARGET25_BREADY, TARGET26_BREADY, TARGET27_BREADY, TARGET28_BREADY, TARGET29_BREADY, 
													TARGET30_BREADY, TARGET31_BREADY,
   
  // Target Read Address Port
  output wire [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] TARGET0_ARID,  TARGET1_ARID,  TARGET2_ARID,  TARGET3_ARID,  TARGET4_ARID,  TARGET5_ARID, 
                                                    TARGET6_ARID,  TARGET7_ARID,  TARGET8_ARID,  TARGET9_ARID,  TARGET10_ARID, TARGET11_ARID, 
													TARGET12_ARID, TARGET13_ARID, TARGET14_ARID, TARGET15_ARID, TARGET16_ARID, TARGET17_ARID, 
													TARGET18_ARID, TARGET19_ARID, TARGET20_ARID, TARGET21_ARID, TARGET22_ARID, TARGET23_ARID, 
                                                    TARGET24_ARID, TARGET25_ARID, TARGET26_ARID, TARGET27_ARID, TARGET28_ARID, TARGET29_ARID, 
													TARGET30_ARID, TARGET31_ARID,
  
  
  
  output wire [ADDR_WIDTH-1:0]      TARGET0_ARADDR,  TARGET1_ARADDR,  TARGET2_ARADDR,  TARGET3_ARADDR,  TARGET4_ARADDR,  TARGET5_ARADDR,  
                                    TARGET6_ARADDR,  TARGET7_ARADDR,  TARGET8_ARADDR,  TARGET9_ARADDR,  TARGET10_ARADDR, TARGET11_ARADDR, 
									TARGET12_ARADDR, TARGET13_ARADDR, TARGET14_ARADDR, TARGET15_ARADDR, TARGET16_ARADDR, TARGET17_ARADDR, 
									TARGET18_ARADDR, TARGET19_ARADDR, TARGET20_ARADDR, TARGET21_ARADDR, TARGET22_ARADDR, TARGET23_ARADDR, 
                                    TARGET24_ARADDR, TARGET25_ARADDR, TARGET26_ARADDR, TARGET27_ARADDR, TARGET28_ARADDR, TARGET29_ARADDR, 
									TARGET30_ARADDR, TARGET31_ARADDR,


  output wire [7:0]                 TARGET0_ARLEN,  TARGET1_ARLEN,  TARGET2_ARLEN,  TARGET3_ARLEN,  TARGET4_ARLEN,  TARGET5_ARLEN,  
                                    TARGET6_ARLEN,  TARGET7_ARLEN,  TARGET8_ARLEN,  TARGET9_ARLEN,  TARGET10_ARLEN, TARGET11_ARLEN, 
									TARGET12_ARLEN, TARGET13_ARLEN, TARGET14_ARLEN, TARGET15_ARLEN, TARGET16_ARLEN, TARGET17_ARLEN, 
									TARGET18_ARLEN, TARGET19_ARLEN, TARGET20_ARLEN, TARGET21_ARLEN, TARGET22_ARLEN, TARGET23_ARLEN, 
                                    TARGET24_ARLEN, TARGET25_ARLEN, TARGET26_ARLEN, TARGET27_ARLEN, TARGET28_ARLEN, TARGET29_ARLEN, 
									TARGET30_ARLEN, TARGET31_ARLEN,


  output wire [2:0]                 TARGET0_ARSIZE,  TARGET1_ARSIZE,  TARGET2_ARSIZE,  TARGET3_ARSIZE,  TARGET4_ARSIZE,  TARGET5_ARSIZE,  
                                    TARGET6_ARSIZE,  TARGET7_ARSIZE,  TARGET8_ARSIZE,  TARGET9_ARSIZE,  TARGET10_ARSIZE, TARGET11_ARSIZE, 
									TARGET12_ARSIZE, TARGET13_ARSIZE, TARGET14_ARSIZE, TARGET15_ARSIZE, TARGET16_ARSIZE, TARGET17_ARSIZE, 
									TARGET18_ARSIZE, TARGET19_ARSIZE, TARGET20_ARSIZE, TARGET21_ARSIZE, TARGET22_ARSIZE, TARGET23_ARSIZE, 
                                    TARGET24_ARSIZE, TARGET25_ARSIZE, TARGET26_ARSIZE, TARGET27_ARSIZE, TARGET28_ARSIZE, TARGET29_ARSIZE, 
									TARGET30_ARSIZE, TARGET31_ARSIZE,


  output wire [1:0]                 TARGET0_ARBURST,  TARGET1_ARBURST,  TARGET2_ARBURST,  TARGET3_ARBURST,  TARGET4_ARBURST,  TARGET5_ARBURST,  
                                    TARGET6_ARBURST,  TARGET7_ARBURST,  TARGET8_ARBURST,  TARGET9_ARBURST,  TARGET10_ARBURST, TARGET11_ARBURST,
									TARGET12_ARBURST, TARGET13_ARBURST, TARGET14_ARBURST, TARGET15_ARBURST, TARGET16_ARBURST, TARGET17_ARBURST, 
									TARGET18_ARBURST, TARGET19_ARBURST, TARGET20_ARBURST, TARGET21_ARBURST, TARGET22_ARBURST, TARGET23_ARBURST, 
                                    TARGET24_ARBURST, TARGET25_ARBURST, TARGET26_ARBURST, TARGET27_ARBURST, TARGET28_ARBURST, TARGET29_ARBURST, 
									TARGET30_ARBURST, TARGET31_ARBURST,


  output wire [T0_LOCK_WIDTH-1:0]  TARGET0_ARLOCK,
  output wire [T1_LOCK_WIDTH-1:0]  TARGET1_ARLOCK,
  output wire [T2_LOCK_WIDTH-1:0]  TARGET2_ARLOCK,
  output wire [T3_LOCK_WIDTH-1:0]  TARGET3_ARLOCK,
  output wire [T4_LOCK_WIDTH-1:0]  TARGET4_ARLOCK,
  output wire [T5_LOCK_WIDTH-1:0]  TARGET5_ARLOCK,
  output wire [T6_LOCK_WIDTH-1:0]  TARGET6_ARLOCK,
  output wire [T7_LOCK_WIDTH-1:0]  TARGET7_ARLOCK,
  output wire [T8_LOCK_WIDTH-1:0]  TARGET8_ARLOCK,
  output wire [T9_LOCK_WIDTH-1:0]  TARGET9_ARLOCK,
  output wire [T10_LOCK_WIDTH-1:0] TARGET10_ARLOCK,
  output wire [T11_LOCK_WIDTH-1:0] TARGET11_ARLOCK,
  output wire [T12_LOCK_WIDTH-1:0] TARGET12_ARLOCK,
  output wire [T13_LOCK_WIDTH-1:0] TARGET13_ARLOCK,
  output wire [T14_LOCK_WIDTH-1:0] TARGET14_ARLOCK,
  output wire [T15_LOCK_WIDTH-1:0] TARGET15_ARLOCK,
  output wire [T16_LOCK_WIDTH-1:0] TARGET16_ARLOCK,
  output wire [T17_LOCK_WIDTH-1:0] TARGET17_ARLOCK,
  output wire [T18_LOCK_WIDTH-1:0] TARGET18_ARLOCK,
  output wire [T19_LOCK_WIDTH-1:0] TARGET19_ARLOCK,
  output wire [T20_LOCK_WIDTH-1:0] TARGET20_ARLOCK,
  output wire [T21_LOCK_WIDTH-1:0] TARGET21_ARLOCK,
  output wire [T22_LOCK_WIDTH-1:0] TARGET22_ARLOCK,
  output wire [T23_LOCK_WIDTH-1:0] TARGET23_ARLOCK,
  output wire [T24_LOCK_WIDTH-1:0] TARGET24_ARLOCK,
  output wire [T25_LOCK_WIDTH-1:0] TARGET25_ARLOCK,
  output wire [T26_LOCK_WIDTH-1:0] TARGET26_ARLOCK,
  output wire [T27_LOCK_WIDTH-1:0] TARGET27_ARLOCK,
  output wire [T28_LOCK_WIDTH-1:0] TARGET28_ARLOCK,
  output wire [T29_LOCK_WIDTH-1:0] TARGET29_ARLOCK,
  output wire [T30_LOCK_WIDTH-1:0] TARGET30_ARLOCK,
  output wire [T31_LOCK_WIDTH-1:0] TARGET31_ARLOCK,


  output wire [3:0]                 TARGET0_ARCACHE,  TARGET1_ARCACHE,  TARGET2_ARCACHE,  TARGET3_ARCACHE,  TARGET4_ARCACHE,  TARGET5_ARCACHE,  
                                    TARGET6_ARCACHE,  TARGET7_ARCACHE,  TARGET8_ARCACHE,  TARGET9_ARCACHE,  TARGET10_ARCACHE, TARGET11_ARCACHE, 
									TARGET12_ARCACHE, TARGET13_ARCACHE, TARGET14_ARCACHE, TARGET15_ARCACHE, TARGET16_ARCACHE, TARGET17_ARCACHE, 
									TARGET18_ARCACHE, TARGET19_ARCACHE, TARGET20_ARCACHE, TARGET21_ARCACHE, TARGET22_ARCACHE, TARGET23_ARCACHE, 
                                    TARGET24_ARCACHE, TARGET25_ARCACHE, TARGET26_ARCACHE, TARGET27_ARCACHE, TARGET28_ARCACHE, TARGET29_ARCACHE, 
									TARGET30_ARCACHE, TARGET31_ARCACHE,


  output wire [2:0]                 TARGET0_ARPROT,  TARGET1_ARPROT,  TARGET2_ARPROT,  TARGET3_ARPROT,  TARGET4_ARPROT,  TARGET5_ARPROT,  
                                    TARGET6_ARPROT,  TARGET7_ARPROT,  TARGET8_ARPROT,  TARGET9_ARPROT,  TARGET10_ARPROT, TARGET11_ARPROT, 
									TARGET12_ARPROT, TARGET13_ARPROT, TARGET14_ARPROT, TARGET15_ARPROT, TARGET16_ARPROT, TARGET17_ARPROT, 
									TARGET18_ARPROT, TARGET19_ARPROT, TARGET20_ARPROT, TARGET21_ARPROT, TARGET22_ARPROT, TARGET23_ARPROT, 
                                    TARGET24_ARPROT, TARGET25_ARPROT, TARGET26_ARPROT, TARGET27_ARPROT, TARGET28_ARPROT, TARGET29_ARPROT, 
									TARGET30_ARPROT, TARGET31_ARPROT,


  output wire [3:0]                 TARGET0_ARREGION,  TARGET1_ARREGION,  TARGET2_ARREGION,  TARGET3_ARREGION,  TARGET4_ARREGION,  
                                    TARGET5_ARREGION,  TARGET6_ARREGION,  TARGET7_ARREGION,  TARGET8_ARREGION,  TARGET9_ARREGION,  
									TARGET10_ARREGION, TARGET11_ARREGION, TARGET12_ARREGION, TARGET13_ARREGION, TARGET14_ARREGION, 
									TARGET15_ARREGION, TARGET16_ARREGION, TARGET17_ARREGION, TARGET18_ARREGION, TARGET19_ARREGION, 
									TARGET20_ARREGION, TARGET21_ARREGION, TARGET22_ARREGION, TARGET23_ARREGION, TARGET24_ARREGION, 
									TARGET25_ARREGION, TARGET26_ARREGION, TARGET27_ARREGION, TARGET28_ARREGION, TARGET29_ARREGION, 
									TARGET30_ARREGION, TARGET31_ARREGION,


  output wire [3:0]                 TARGET0_ARQOS,  TARGET1_ARQOS,  TARGET2_ARQOS,  TARGET3_ARQOS,  TARGET4_ARQOS,  TARGET5_ARQOS,  
                                    TARGET6_ARQOS,  TARGET7_ARQOS,  TARGET8_ARQOS,  TARGET9_ARQOS,  TARGET10_ARQOS, TARGET11_ARQOS, 
									TARGET12_ARQOS, TARGET13_ARQOS, TARGET14_ARQOS, TARGET15_ARQOS, TARGET16_ARQOS, TARGET17_ARQOS, 
									TARGET18_ARQOS, TARGET19_ARQOS, TARGET20_ARQOS, TARGET21_ARQOS, TARGET22_ARQOS, TARGET23_ARQOS, 
                                    TARGET24_ARQOS, TARGET25_ARQOS, TARGET26_ARQOS, TARGET27_ARQOS, TARGET28_ARQOS, TARGET29_ARQOS,
									TARGET30_ARQOS, TARGET31_ARQOS,

  output wire [USER_WIDTH-1:0]      TARGET0_ARUSER,  TARGET1_ARUSER,  TARGET2_ARUSER,  TARGET3_ARUSER,  TARGET4_ARUSER,  TARGET5_ARUSER,  
                                    TARGET6_ARUSER,  TARGET7_ARUSER,  TARGET8_ARUSER,  TARGET9_ARUSER,  TARGET10_ARUSER, TARGET11_ARUSER, 
									TARGET12_ARUSER, TARGET13_ARUSER, TARGET14_ARUSER, TARGET15_ARUSER, TARGET16_ARUSER, TARGET17_ARUSER, 
									TARGET18_ARUSER, TARGET19_ARUSER, TARGET20_ARUSER, TARGET21_ARUSER, TARGET22_ARUSER, TARGET23_ARUSER, 
                                    TARGET24_ARUSER, TARGET25_ARUSER, TARGET26_ARUSER, TARGET27_ARUSER, TARGET28_ARUSER, TARGET29_ARUSER,
									TARGET30_ARUSER, TARGET31_ARUSER,


  output wire                       TARGET0_ARVALID,  TARGET1_ARVALID,  TARGET2_ARVALID,  TARGET3_ARVALID,  TARGET4_ARVALID,  TARGET5_ARVALID,  
                                    TARGET6_ARVALID,  TARGET7_ARVALID,  TARGET8_ARVALID,  TARGET9_ARVALID,  TARGET10_ARVALID, TARGET11_ARVALID, 
									TARGET12_ARVALID, TARGET13_ARVALID, TARGET14_ARVALID, TARGET15_ARVALID, TARGET16_ARVALID, TARGET17_ARVALID, 
									TARGET18_ARVALID, TARGET19_ARVALID, TARGET20_ARVALID, TARGET21_ARVALID, TARGET22_ARVALID, TARGET23_ARVALID, 
                                    TARGET24_ARVALID, TARGET25_ARVALID, TARGET26_ARVALID, TARGET27_ARVALID, TARGET28_ARVALID, TARGET29_ARVALID,
									TARGET30_ARVALID, TARGET31_ARVALID,

  
  input  wire                       TARGET0_ARREADY,  TARGET1_ARREADY,  TARGET2_ARREADY,  TARGET3_ARREADY,  TARGET4_ARREADY,  TARGET5_ARREADY,  
                                    TARGET6_ARREADY,  TARGET7_ARREADY,  TARGET8_ARREADY,  TARGET9_ARREADY,  TARGET10_ARREADY, TARGET11_ARREADY, 
									TARGET12_ARREADY, TARGET13_ARREADY, TARGET14_ARREADY, TARGET15_ARREADY, TARGET16_ARREADY, TARGET17_ARREADY, 
									TARGET18_ARREADY, TARGET19_ARREADY, TARGET20_ARREADY, TARGET21_ARREADY, TARGET22_ARREADY, TARGET23_ARREADY, 
                                    TARGET24_ARREADY, TARGET25_ARREADY, TARGET26_ARREADY, TARGET27_ARREADY, TARGET28_ARREADY, TARGET29_ARREADY, 
									TARGET30_ARREADY, TARGET31_ARREADY,


  // Target Read Data Ports
  input  wire [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] TARGET0_RID,  TARGET1_RID,  TARGET2_RID,  TARGET3_RID,  TARGET4_RID,  TARGET5_RID,  
                                                    TARGET6_RID,  TARGET7_RID,  TARGET8_RID,  TARGET9_RID,  TARGET10_RID, TARGET11_RID, 
													TARGET12_RID, TARGET13_RID, TARGET14_RID, TARGET15_RID, TARGET16_RID, TARGET17_RID, 
													TARGET18_RID, TARGET19_RID, TARGET20_RID, TARGET21_RID, TARGET22_RID, TARGET23_RID, 
                                                    TARGET24_RID, TARGET25_RID, TARGET26_RID, TARGET27_RID, TARGET28_RID, TARGET29_RID,
													TARGET30_RID, TARGET31_RID,
                                                    
  input  wire [TARGET0_DATA_WIDTH-1:0]    TARGET0_RDATA,
  input  wire [TARGET1_DATA_WIDTH-1:0]    TARGET1_RDATA,
  input  wire [TARGET2_DATA_WIDTH-1:0]    TARGET2_RDATA,
  input  wire [TARGET3_DATA_WIDTH-1:0]    TARGET3_RDATA,
  input  wire [TARGET4_DATA_WIDTH-1:0]    TARGET4_RDATA,
  input  wire [TARGET5_DATA_WIDTH-1:0]    TARGET5_RDATA,
  input  wire [TARGET6_DATA_WIDTH-1:0]    TARGET6_RDATA,
  input  wire [TARGET7_DATA_WIDTH-1:0]    TARGET7_RDATA,
  input  wire [TARGET8_DATA_WIDTH-1:0]    TARGET8_RDATA,
  input  wire [TARGET9_DATA_WIDTH-1:0]    TARGET9_RDATA,
  input  wire [TARGET10_DATA_WIDTH-1:0]   TARGET10_RDATA,
  input  wire [TARGET11_DATA_WIDTH-1:0]   TARGET11_RDATA,
  input  wire [TARGET12_DATA_WIDTH-1:0]   TARGET12_RDATA,
  input  wire [TARGET13_DATA_WIDTH-1:0]   TARGET13_RDATA,
  input  wire [TARGET14_DATA_WIDTH-1:0]   TARGET14_RDATA,
  input  wire [TARGET15_DATA_WIDTH-1:0]   TARGET15_RDATA,
  input  wire [TARGET16_DATA_WIDTH-1:0]   TARGET16_RDATA,
  input  wire [TARGET17_DATA_WIDTH-1:0]   TARGET17_RDATA,
  input  wire [TARGET18_DATA_WIDTH-1:0]   TARGET18_RDATA,
  input  wire [TARGET19_DATA_WIDTH-1:0]   TARGET19_RDATA,
  input  wire [TARGET20_DATA_WIDTH-1:0]   TARGET20_RDATA,
  input  wire [TARGET21_DATA_WIDTH-1:0]   TARGET21_RDATA,
  input  wire [TARGET22_DATA_WIDTH-1:0]   TARGET22_RDATA,
  input  wire [TARGET23_DATA_WIDTH-1:0]   TARGET23_RDATA,
  input  wire [TARGET24_DATA_WIDTH-1:0]   TARGET24_RDATA,
  input  wire [TARGET25_DATA_WIDTH-1:0]   TARGET25_RDATA,
  input  wire [TARGET26_DATA_WIDTH-1:0]   TARGET26_RDATA,
  input  wire [TARGET27_DATA_WIDTH-1:0]   TARGET27_RDATA,
  input  wire [TARGET28_DATA_WIDTH-1:0]   TARGET28_RDATA,
  input  wire [TARGET29_DATA_WIDTH-1:0]   TARGET29_RDATA,
  input  wire [TARGET30_DATA_WIDTH-1:0]   TARGET30_RDATA,
  input  wire [TARGET31_DATA_WIDTH-1:0]   TARGET31_RDATA,
  
  
  input  wire [1:0]                 TARGET0_RRESP,  TARGET1_RRESP,  TARGET2_RRESP,  TARGET3_RRESP,  TARGET4_RRESP,  TARGET5_RRESP,  
                                    TARGET6_RRESP,  TARGET7_RRESP,  TARGET8_RRESP,  TARGET9_RRESP,  TARGET10_RRESP, TARGET11_RRESP, 
									TARGET12_RRESP, TARGET13_RRESP, TARGET14_RRESP, TARGET15_RRESP, TARGET16_RRESP, TARGET17_RRESP, 
									TARGET18_RRESP, TARGET19_RRESP, TARGET20_RRESP, TARGET21_RRESP, TARGET22_RRESP, TARGET23_RRESP, 
                                    TARGET24_RRESP, TARGET25_RRESP, TARGET26_RRESP, TARGET27_RRESP, TARGET28_RRESP, TARGET29_RRESP, 
									TARGET30_RRESP, TARGET31_RRESP,

  input  wire                       TARGET0_RLAST,  TARGET1_RLAST,  TARGET2_RLAST,  TARGET3_RLAST,  TARGET4_RLAST,  TARGET5_RLAST,  
                                    TARGET6_RLAST,  TARGET7_RLAST,  TARGET8_RLAST,  TARGET9_RLAST,  TARGET10_RLAST, TARGET11_RLAST, 
									TARGET12_RLAST, TARGET13_RLAST, TARGET14_RLAST, TARGET15_RLAST, TARGET16_RLAST, TARGET17_RLAST, 
									TARGET18_RLAST, TARGET19_RLAST, TARGET20_RLAST, TARGET21_RLAST, TARGET22_RLAST, TARGET23_RLAST, 
                                    TARGET24_RLAST, TARGET25_RLAST, TARGET26_RLAST, TARGET27_RLAST, TARGET28_RLAST, TARGET29_RLAST, 
									TARGET30_RLAST, TARGET31_RLAST,
                                                    
                                                    
  input  wire [USER_WIDTH-1:0]      TARGET0_RUSER,  TARGET1_RUSER,  TARGET2_RUSER,  TARGET3_RUSER,  TARGET4_RUSER,  TARGET5_RUSER,  
                                    TARGET6_RUSER,  TARGET7_RUSER,  TARGET8_RUSER,  TARGET9_RUSER,  TARGET10_RUSER, TARGET11_RUSER, 
									TARGET12_RUSER, TARGET13_RUSER, TARGET14_RUSER, TARGET15_RUSER, TARGET16_RUSER, TARGET17_RUSER, 
									TARGET18_RUSER, TARGET19_RUSER, TARGET20_RUSER, TARGET21_RUSER, TARGET22_RUSER, TARGET23_RUSER, 
                                    TARGET24_RUSER, TARGET25_RUSER, TARGET26_RUSER, TARGET27_RUSER, TARGET28_RUSER, TARGET29_RUSER, 
									TARGET30_RUSER, TARGET31_RUSER,
                                                    
                                                    
  input  wire                       TARGET0_RVALID,  TARGET1_RVALID,  TARGET2_RVALID,  TARGET3_RVALID,  TARGET4_RVALID,  TARGET5_RVALID,  
                                    TARGET6_RVALID,   TARGET7_RVALID, TARGET8_RVALID,  TARGET9_RVALID,  TARGET10_RVALID, TARGET11_RVALID, 
									TARGET12_RVALID, TARGET13_RVALID, TARGET14_RVALID, TARGET15_RVALID, TARGET16_RVALID, TARGET17_RVALID,
									TARGET18_RVALID, TARGET19_RVALID, TARGET20_RVALID, TARGET21_RVALID, TARGET22_RVALID, TARGET23_RVALID, 
                                    TARGET24_RVALID, TARGET25_RVALID, TARGET26_RVALID, TARGET27_RVALID, TARGET28_RVALID, TARGET29_RVALID, 
									TARGET30_RVALID, TARGET31_RVALID,
                                                    
                                                    
  output wire                       TARGET0_RREADY,  TARGET1_RREADY,  TARGET2_RREADY,  TARGET3_RREADY,  TARGET4_RREADY,  TARGET5_RREADY,  
                                    TARGET6_RREADY,  TARGET7_RREADY,  TARGET8_RREADY,  TARGET9_RREADY,  TARGET10_RREADY, TARGET11_RREADY, 
									TARGET12_RREADY, TARGET13_RREADY, TARGET14_RREADY, TARGET15_RREADY, TARGET16_RREADY, TARGET17_RREADY, 
									TARGET18_RREADY, TARGET19_RREADY, TARGET20_RREADY, TARGET21_RREADY, TARGET22_RREADY, TARGET23_RREADY, 
                                    TARGET24_RREADY, TARGET25_RREADY, TARGET26_RREADY, TARGET27_RREADY, TARGET28_RREADY, TARGET29_RREADY, 
									TARGET30_RREADY, TARGET31_RREADY
);

  
  //As new parameters TARGET_START_ADDR and TARGET_END_ADDR,UPPER_COMPARE_BIT and LOWER_COMPARE_BIT parameters are no longer required.
  //However to remove warnings/errors,UPPER_COMPARE_BIT is assigned to ADDR_WIDTH and LOWER_COMPARE_BIT is assigned to 0
  
  localparam UPPER_COMPARE_BIT = ADDR_WIDTH;
  localparam LOWER_COMPARE_BIT = 0;
  localparam SYNC_RESET        = RESET_TYPE;
  localparam NUM_STAGES        = 3;
  
  
  //Local parameter used to assign START ADDRESS for each target to minimize the RTL Change
  
  localparam [ADDR_WIDTH-1: 0]   SLOT0_MIN_VEC  = {TARGET0_START_ADDR_UPPER,TARGET0_START_ADDR};           // SLOT0 start address
  localparam [ADDR_WIDTH-1: 0]   SLOT1_MIN_VEC  = {TARGET1_START_ADDR_UPPER,TARGET1_START_ADDR};           // SLOT1 start address
  localparam [ADDR_WIDTH-1: 0]   SLOT2_MIN_VEC  = {TARGET2_START_ADDR_UPPER,TARGET2_START_ADDR};           // SLOT2 start address
  localparam [ADDR_WIDTH-1: 0]   SLOT3_MIN_VEC  = {TARGET3_START_ADDR_UPPER,TARGET3_START_ADDR};           // SLOT3 start address
  localparam [ADDR_WIDTH-1: 0]   SLOT4_MIN_VEC  = {TARGET4_START_ADDR_UPPER,TARGET4_START_ADDR};           // SLOT4 start address
  localparam [ADDR_WIDTH-1: 0]   SLOT5_MIN_VEC  = {TARGET5_START_ADDR_UPPER,TARGET5_START_ADDR};           // SLOT5 start address
  localparam [ADDR_WIDTH-1: 0]   SLOT6_MIN_VEC  = {TARGET6_START_ADDR_UPPER,TARGET6_START_ADDR};           // SLOT6 start address
  localparam [ADDR_WIDTH-1: 0]   SLOT7_MIN_VEC  = {TARGET7_START_ADDR_UPPER,TARGET7_START_ADDR};           // SLOT7 start address
  localparam [ADDR_WIDTH-1: 0]   SLOT8_MIN_VEC  = {TARGET8_START_ADDR_UPPER,TARGET8_START_ADDR};           // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT9_MIN_VEC  = {TARGET9_START_ADDR_UPPER,TARGET9_START_ADDR};           // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT10_MIN_VEC = {TARGET10_START_ADDR_UPPER,TARGET10_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT11_MIN_VEC = {TARGET11_START_ADDR_UPPER,TARGET11_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT12_MIN_VEC = {TARGET12_START_ADDR_UPPER,TARGET12_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT13_MIN_VEC = {TARGET13_START_ADDR_UPPER,TARGET13_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT14_MIN_VEC = {TARGET14_START_ADDR_UPPER,TARGET14_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT15_MIN_VEC = {TARGET15_START_ADDR_UPPER,TARGET15_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT16_MIN_VEC = {TARGET16_START_ADDR_UPPER,TARGET16_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT17_MIN_VEC = {TARGET17_START_ADDR_UPPER,TARGET17_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT18_MIN_VEC = {TARGET18_START_ADDR_UPPER,TARGET18_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT19_MIN_VEC = {TARGET19_START_ADDR_UPPER,TARGET19_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT20_MIN_VEC = {TARGET20_START_ADDR_UPPER,TARGET20_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT21_MIN_VEC = {TARGET21_START_ADDR_UPPER,TARGET21_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT22_MIN_VEC = {TARGET22_START_ADDR_UPPER,TARGET22_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT23_MIN_VEC = {TARGET23_START_ADDR_UPPER,TARGET23_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT24_MIN_VEC = {TARGET24_START_ADDR_UPPER,TARGET24_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT25_MIN_VEC = {TARGET25_START_ADDR_UPPER,TARGET25_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT26_MIN_VEC = {TARGET26_START_ADDR_UPPER,TARGET26_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT27_MIN_VEC = {TARGET27_START_ADDR_UPPER,TARGET27_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT28_MIN_VEC = {TARGET28_START_ADDR_UPPER,TARGET28_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT29_MIN_VEC = {TARGET29_START_ADDR_UPPER,TARGET29_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT30_MIN_VEC = {TARGET30_START_ADDR_UPPER,TARGET30_START_ADDR};          // Defines the start address for Target 7 decode
  localparam [ADDR_WIDTH-1: 0]   SLOT31_MIN_VEC = {TARGET31_START_ADDR_UPPER,TARGET31_START_ADDR};          // Defines the start address for Target 7 decode
  
  //Local parameter used to assign END ADDRESS for each target to minimize the RTL Change
  
  localparam [ADDR_WIDTH-1: 0]   SLOT0_MAX_VEC  = {TARGET0_END_ADDR_UPPER,TARGET0_END_ADDR};           // SLOT0 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT1_MAX_VEC  = {TARGET1_END_ADDR_UPPER,TARGET1_END_ADDR};           // SLOT1 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT2_MAX_VEC  = {TARGET2_END_ADDR_UPPER,TARGET2_END_ADDR};           // SLOT2 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT3_MAX_VEC  = {TARGET3_END_ADDR_UPPER,TARGET3_END_ADDR};           // SLOT3 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT4_MAX_VEC  = {TARGET4_END_ADDR_UPPER,TARGET4_END_ADDR};           // SLOT4 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT5_MAX_VEC  = {TARGET5_END_ADDR_UPPER,TARGET5_END_ADDR};           // SLOT5 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT6_MAX_VEC  = {TARGET6_END_ADDR_UPPER,TARGET6_END_ADDR};           // SLOT6 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT7_MAX_VEC  = {TARGET7_END_ADDR_UPPER,TARGET7_END_ADDR};           // SLOT7 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT8_MAX_VEC  = {TARGET8_END_ADDR_UPPER,TARGET8_END_ADDR};           // SLOT8 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT9_MAX_VEC  = {TARGET9_END_ADDR_UPPER,TARGET9_END_ADDR};           // SLOT9 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT10_MAX_VEC = {TARGET10_END_ADDR_UPPER,TARGET10_END_ADDR};          // SLOT10 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT11_MAX_VEC = {TARGET11_END_ADDR_UPPER,TARGET11_END_ADDR};          // SLOT11 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT12_MAX_VEC = {TARGET12_END_ADDR_UPPER,TARGET12_END_ADDR};          // SLOT12 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT13_MAX_VEC = {TARGET13_END_ADDR_UPPER,TARGET13_END_ADDR};          // SLOT13 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT14_MAX_VEC = {TARGET14_END_ADDR_UPPER,TARGET14_END_ADDR};          // SLOT14 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT15_MAX_VEC = {TARGET15_END_ADDR_UPPER,TARGET15_END_ADDR};          // SLOT15 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT16_MAX_VEC = {TARGET16_END_ADDR_UPPER,TARGET16_END_ADDR};          // SLOT16 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT17_MAX_VEC = {TARGET17_END_ADDR_UPPER,TARGET17_END_ADDR};          // SLOT17 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT18_MAX_VEC = {TARGET18_END_ADDR_UPPER,TARGET18_END_ADDR};          // SLOT18 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT19_MAX_VEC = {TARGET19_END_ADDR_UPPER,TARGET19_END_ADDR};          // SLOT19 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT20_MAX_VEC = {TARGET20_END_ADDR_UPPER,TARGET20_END_ADDR};          // SLOT20 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT21_MAX_VEC = {TARGET21_END_ADDR_UPPER,TARGET21_END_ADDR};          // SLOT21 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT22_MAX_VEC = {TARGET22_END_ADDR_UPPER,TARGET22_END_ADDR};          // SLOT22 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT23_MAX_VEC = {TARGET23_END_ADDR_UPPER,TARGET23_END_ADDR};          // SLOT23 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT24_MAX_VEC = {TARGET24_END_ADDR_UPPER,TARGET24_END_ADDR};          // SLOT24 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT25_MAX_VEC = {TARGET25_END_ADDR_UPPER,TARGET25_END_ADDR};          // SLOT25 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT26_MAX_VEC = {TARGET26_END_ADDR_UPPER,TARGET26_END_ADDR};          // SLOT26 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT27_MAX_VEC = {TARGET27_END_ADDR_UPPER,TARGET27_END_ADDR};          // SLOT27 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT28_MAX_VEC = {TARGET28_END_ADDR_UPPER,TARGET28_END_ADDR};          // SLOT28 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT29_MAX_VEC = {TARGET29_END_ADDR_UPPER,TARGET29_END_ADDR};          // SLOT29 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT30_MAX_VEC = {TARGET30_END_ADDR_UPPER,TARGET30_END_ADDR};          // SLOT30 End address
  localparam [ADDR_WIDTH-1: 0]   SLOT31_MAX_VEC = {TARGET31_END_ADDR_UPPER,TARGET31_END_ADDR};          // SLOT31 End address
  
  
  localparam OPEN_WRTRANS_MAX       = (MAX_OUTSTNDG_TRANS > 2) ? MAX_OUTSTNDG_TRANS : 2;        // max number of outstanding write transactions - valid range 2-8 - 2**OPEN_WRTRANS_MAX
  localparam OPEN_RDTRANS_MAX       = OPEN_WRTRANS_MAX;
  localparam MAX_TRANS              = OPEN_WRTRANS_MAX;


  


  localparam [ADDR_WIDTH-1:0]  SLOT0_BASE_VEC = 'h0;          // Defines the base address for Target 0 decode
  localparam [ADDR_WIDTH-1:0]  SLOT1_BASE_VEC = 'h1;          // Defines the base address for Target 1 decode
  localparam [ADDR_WIDTH-1:0]  SLOT2_BASE_VEC = 'h2;          // Defines the base address for Target 2 decode
  localparam [ADDR_WIDTH-1:0]  SLOT3_BASE_VEC = 'h3;          // Defines the base address for Target 3 decode
  localparam [ADDR_WIDTH-1:0]  SLOT4_BASE_VEC = 'h4;          // Defines the base address for Target 4 decode
  localparam [ADDR_WIDTH-1:0]  SLOT5_BASE_VEC = 'h5;          // Defines the base address for Target 5 decode
  localparam [ADDR_WIDTH-1:0]  SLOT6_BASE_VEC = 'h6;          // Defines the base address for Target 6 decode
  localparam [ADDR_WIDTH-1:0]  SLOT7_BASE_VEC = 'h7;          // Defines the base address for Target 7 decode
  localparam [ADDR_WIDTH-1:0]  SLOT8_BASE_VEC  = 'h8;          // Defines the base address for Target 8 decode
  localparam [ADDR_WIDTH-1:0]  SLOT9_BASE_VEC  = 'h9;          // Defines the base address for Target 9 decode
  localparam [ADDR_WIDTH-1:0]  SLOT10_BASE_VEC = 'ha;          // Defines the base address for Target 10 decode
  localparam [ADDR_WIDTH-1:0]  SLOT11_BASE_VEC = 'hb;          // Defines the base address for Target 11 decode
  localparam [ADDR_WIDTH-1:0]  SLOT12_BASE_VEC = 'hc;          // Defines the base address for Target 12 decode
  localparam [ADDR_WIDTH-1:0]  SLOT13_BASE_VEC = 'hd;          // Defines the base address for Target 13 decode
  localparam [ADDR_WIDTH-1:0]  SLOT14_BASE_VEC = 'he;          // Defines the base address for Target 14 decode
  localparam [ADDR_WIDTH-1:0]  SLOT15_BASE_VEC = 'hf;          // Defines the base address for Target 15 decode
  localparam [ADDR_WIDTH-1:0]  SLOT16_BASE_VEC = 'h10;          // Defines the base address for Target 16 decode
  localparam [ADDR_WIDTH-1:0]  SLOT17_BASE_VEC = 'h11;          // Defines the base address for Target 17 decode
  localparam [ADDR_WIDTH-1:0]  SLOT18_BASE_VEC = 'h12;          // Defines the base address for Target 18 decode
  localparam [ADDR_WIDTH-1:0]  SLOT19_BASE_VEC = 'h13;          // Defines the base address for Target 19 decode
  localparam [ADDR_WIDTH-1:0]  SLOT20_BASE_VEC = 'h14;          // Defines the base address for Target 20 decode
  localparam [ADDR_WIDTH-1:0]  SLOT21_BASE_VEC = 'h15;          // Defines the base address for Target 21 decode
  localparam [ADDR_WIDTH-1:0]  SLOT22_BASE_VEC = 'h16;          // Defines the base address for Target 22 decode
  localparam [ADDR_WIDTH-1:0]  SLOT23_BASE_VEC = 'h17;          // Defines the base address for Target 23 decode
  localparam [ADDR_WIDTH-1:0]  SLOT24_BASE_VEC = 'h18;          // Defines the base address for Target 24 decode
  localparam [ADDR_WIDTH-1:0]  SLOT25_BASE_VEC = 'h19;          // Defines the base address for Target 25 decode
  localparam [ADDR_WIDTH-1:0]  SLOT26_BASE_VEC = 'h1a;          // Defines the base address for Target 26 decode
  localparam [ADDR_WIDTH-1:0]  SLOT27_BASE_VEC = 'h1b;          // Defines the base address for Target 27 decode
  localparam [ADDR_WIDTH-1:0]  SLOT28_BASE_VEC = 'h1c;          // Defines the base address for Target 28 decode
  localparam [ADDR_WIDTH-1:0]  SLOT29_BASE_VEC = 'h1d;          // Defines the base address for Target 29 decode
  localparam [ADDR_WIDTH-1:0]  SLOT30_BASE_VEC = 'h1e;          // Defines the base address for Target 30 decode
  localparam [ADDR_WIDTH-1:0]  SLOT31_BASE_VEC = 'h1f;          // Defines the base address for Target 31 decode
  
  //SAR 94407 Change End
  
  localparam integer SUPPORT_USER_SIGNALS   = 0;        // Not used. 



  localparam [0:0] TARGET0_READ_ZERO_TARGET_ID    = 1'b1;                            // Disable target read data interleave
  localparam [0:0] TARGET1_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET2_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET3_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET4_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET5_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET6_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET7_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET8_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET9_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET10_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET11_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET12_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET13_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET14_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET15_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET16_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET17_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET18_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET19_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET20_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET21_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET22_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET23_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET24_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET25_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET26_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET27_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET28_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET29_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET30_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET31_READ_ZERO_TARGET_ID    = TARGET0_READ_ZERO_TARGET_ID;    // Disable target read data interleave

  localparam [0:0] TARGET0_WRITE_ZERO_TARGET_ID    = 1'b1;                           // Disable target read data interleave
  localparam [0:0] TARGET1_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET2_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET3_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET4_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET5_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET6_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET7_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;     // Disable target read data interleave
  localparam [0:0] TARGET8_WRITE_ZERO_TARGET_ID     = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET9_WRITE_ZERO_TARGET_ID     = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET10_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET11_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET12_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET13_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET14_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET15_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET16_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET17_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET18_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET19_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET20_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET21_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET22_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET23_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET24_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET25_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET26_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET27_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET28_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET29_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET30_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave
  localparam [0:0] TARGET31_WRITE_ZERO_TARGET_ID    = TARGET0_WRITE_ZERO_TARGET_ID;    // Disable target read data interleave

  
  localparam [0:0]  INITIATOR0_AWCHAN_RS = INITIATOR0_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR1_AWCHAN_RS = INITIATOR1_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR2_AWCHAN_RS = INITIATOR2_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR3_AWCHAN_RS = INITIATOR3_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR4_AWCHAN_RS = INITIATOR4_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR5_AWCHAN_RS = INITIATOR5_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR6_AWCHAN_RS = INITIATOR6_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR7_AWCHAN_RS = INITIATOR7_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR8_AWCHAN_RS = INITIATOR8_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR9_AWCHAN_RS = INITIATOR9_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR10_AWCHAN_RS = INITIATOR10_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR11_AWCHAN_RS = INITIATOR11_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR12_AWCHAN_RS = INITIATOR12_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR13_AWCHAN_RS = INITIATOR13_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR14_AWCHAN_RS = INITIATOR14_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [0:0]  INITIATOR15_AWCHAN_RS = INITIATOR15_CHAN_RS;  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
              
  localparam [0:0]  INITIATOR0_ARCHAN_RS = INITIATOR0_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR1_ARCHAN_RS = INITIATOR1_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR2_ARCHAN_RS = INITIATOR2_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR3_ARCHAN_RS = INITIATOR3_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR4_ARCHAN_RS = INITIATOR4_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR5_ARCHAN_RS = INITIATOR5_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR6_ARCHAN_RS = INITIATOR6_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR7_ARCHAN_RS = INITIATOR7_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR8_ARCHAN_RS = INITIATOR8_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR9_ARCHAN_RS = INITIATOR9_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR10_ARCHAN_RS = INITIATOR10_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR11_ARCHAN_RS = INITIATOR11_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR12_ARCHAN_RS = INITIATOR12_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR13_ARCHAN_RS = INITIATOR13_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR14_ARCHAN_RS = INITIATOR14_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [0:0]  INITIATOR15_ARCHAN_RS = INITIATOR15_CHAN_RS;  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
             
  localparam [0:0]  INITIATOR0_WCHAN_RS = INITIATOR0_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR1_WCHAN_RS = INITIATOR1_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR2_WCHAN_RS = INITIATOR2_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR3_WCHAN_RS = INITIATOR3_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR4_WCHAN_RS = INITIATOR4_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR5_WCHAN_RS = INITIATOR5_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR6_WCHAN_RS = INITIATOR6_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR7_WCHAN_RS = INITIATOR7_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR8_WCHAN_RS = INITIATOR8_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR9_WCHAN_RS = INITIATOR9_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR10_WCHAN_RS = INITIATOR10_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR11_WCHAN_RS = INITIATOR11_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR12_WCHAN_RS = INITIATOR12_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR13_WCHAN_RS = INITIATOR13_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR14_WCHAN_RS = INITIATOR14_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [0:0]  INITIATOR15_WCHAN_RS = INITIATOR15_CHAN_RS;  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
             
  localparam [0:0]  INITIATOR0_RCHAN_RS = INITIATOR0_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR1_RCHAN_RS = INITIATOR1_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR2_RCHAN_RS = INITIATOR2_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR3_RCHAN_RS = INITIATOR3_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR4_RCHAN_RS = INITIATOR4_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR5_RCHAN_RS = INITIATOR5_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR6_RCHAN_RS = INITIATOR6_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR7_RCHAN_RS = INITIATOR7_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR8_RCHAN_RS = INITIATOR8_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR9_RCHAN_RS = INITIATOR9_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR10_RCHAN_RS = INITIATOR10_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR11_RCHAN_RS = INITIATOR11_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR12_RCHAN_RS = INITIATOR12_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR13_RCHAN_RS = INITIATOR13_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR14_RCHAN_RS = INITIATOR14_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [0:0]  INITIATOR15_RCHAN_RS = INITIATOR15_CHAN_RS;  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
              
  localparam [0:0]  INITIATOR0_BCHAN_RS = INITIATOR0_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR1_BCHAN_RS = INITIATOR1_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR2_BCHAN_RS = INITIATOR2_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR3_BCHAN_RS = INITIATOR3_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR4_BCHAN_RS = INITIATOR4_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR5_BCHAN_RS = INITIATOR5_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR6_BCHAN_RS = INITIATOR6_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR7_BCHAN_RS = INITIATOR7_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR8_BCHAN_RS = INITIATOR8_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR9_BCHAN_RS = INITIATOR9_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR10_BCHAN_RS = INITIATOR10_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR11_BCHAN_RS = INITIATOR11_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR12_BCHAN_RS = INITIATOR12_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR13_BCHAN_RS = INITIATOR13_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR14_BCHAN_RS = INITIATOR14_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [0:0]  INITIATOR15_BCHAN_RS = INITIATOR15_CHAN_RS;  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
              
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
  
 
  //Changed AHB_INITIATORx_BRESP_CHECK_MODE and AHB_INITIATORx_BRESP_CNT_WIDTH parameters from parameter to local. 
  //These parameters are no longer used. Just to remove warnings/errors it is replaced with localparam. 
  
  localparam [1:0] AHB_INITIATOR0_BRESP_CHECK_MODE  =  2'b11;      // Defines wait response flag of INITIATOR0
  localparam [1:0] AHB_INITIATOR1_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR1
  localparam [1:0] AHB_INITIATOR2_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR2
  localparam [1:0] AHB_INITIATOR3_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR3
  localparam [1:0] AHB_INITIATOR4_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR4
  localparam [1:0] AHB_INITIATOR5_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR5
  localparam [1:0] AHB_INITIATOR6_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR6
  localparam [1:0] AHB_INITIATOR7_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR7
  localparam [1:0] AHB_INITIATOR8_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR8
  localparam [1:0] AHB_INITIATOR9_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR9
  localparam [1:0] AHB_INITIATOR10_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR10
  localparam [1:0] AHB_INITIATOR11_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR11
  localparam [1:0] AHB_INITIATOR12_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR12
  localparam [1:0] AHB_INITIATOR13_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR13
  localparam [1:0] AHB_INITIATOR14_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR14
  localparam [1:0] AHB_INITIATOR15_BRESP_CHECK_MODE  =  AHB_INITIATOR0_BRESP_CHECK_MODE;      // Defines wait response flag of INITIATOR15
 
  localparam [31:0] AHB_INITIATOR0_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR1_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR2_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR3_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR4_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR5_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR6_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR7_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR8_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR9_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR10_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR11_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR12_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR13_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR14_BRESP_CNT_WIDTH = 'h8;
  localparam [31:0] AHB_INITIATOR15_BRESP_CNT_WIDTH = 'h8;
  
     //===================================================================================================================================


  
  localparam HI_FREQ = ((CROSSBAR_MODE == 1) || ((CROSSBAR_MODE == 0) && (RD_ARB_EN == 0))) ? 1 : 0;        // increases freq of operation at cost of added latency
  
  localparam integer NUM_TARGETS_WIDTH  = (NUM_TARGETS == 1) ? 1 : $clog2(NUM_TARGETS);
            
  localparam integer ADDR_WIDTH_BITS  = ( ADDR_WIDTH <= 16 ) ? 4 : $clog2(ADDR_WIDTH);
    
  localparam INITIATORID_WIDTH    = ( NUM_INITIATORS_WIDTH + ID_WIDTH );      // defines width initiatorID - includes infrastructure port number plus ID
  
  localparam  BASE_WIDTH = ADDR_WIDTH;//-UPPER_COMPARE_BIT;

  localparam [ ( NUM_TARGETS* BASE_WIDTH )-1 : 0 ]   SLOT_BASE_VEC = { SLOT31_BASE_VEC[BASE_WIDTH-1:0], SLOT30_BASE_VEC[BASE_WIDTH-1:0], SLOT29_BASE_VEC[BASE_WIDTH-1:0], SLOT28_BASE_VEC[BASE_WIDTH-1:0],
                                                                      SLOT27_BASE_VEC[BASE_WIDTH-1:0], SLOT26_BASE_VEC[BASE_WIDTH-1:0], SLOT25_BASE_VEC[BASE_WIDTH-1:0], SLOT24_BASE_VEC[BASE_WIDTH-1:0],
                                                                      SLOT23_BASE_VEC[BASE_WIDTH-1:0], SLOT22_BASE_VEC[BASE_WIDTH-1:0], SLOT21_BASE_VEC[BASE_WIDTH-1:0], SLOT20_BASE_VEC[BASE_WIDTH-1:0],
                                                                      SLOT19_BASE_VEC[BASE_WIDTH-1:0], SLOT18_BASE_VEC[BASE_WIDTH-1:0], SLOT17_BASE_VEC[BASE_WIDTH-1:0], SLOT16_BASE_VEC[BASE_WIDTH-1:0],
                                                                      SLOT15_BASE_VEC[BASE_WIDTH-1:0], SLOT14_BASE_VEC[BASE_WIDTH-1:0], SLOT13_BASE_VEC[BASE_WIDTH-1:0], SLOT12_BASE_VEC[BASE_WIDTH-1:0],
                                                                      SLOT11_BASE_VEC[BASE_WIDTH-1:0], SLOT10_BASE_VEC[BASE_WIDTH-1:0], SLOT9_BASE_VEC[BASE_WIDTH-1:0], SLOT8_BASE_VEC[BASE_WIDTH-1:0],
                                                                      SLOT7_BASE_VEC[BASE_WIDTH-1:0], SLOT6_BASE_VEC[BASE_WIDTH-1:0], SLOT5_BASE_VEC[BASE_WIDTH-1:0], SLOT4_BASE_VEC[BASE_WIDTH-1:0],
                                                                      SLOT3_BASE_VEC[BASE_WIDTH-1:0], SLOT2_BASE_VEC[BASE_WIDTH-1:0], SLOT1_BASE_VEC[BASE_WIDTH-1:0], SLOT0_BASE_VEC[BASE_WIDTH-1:0] };
                                                          

  
  localparam CMPR_WIDTH = UPPER_COMPARE_BIT-LOWER_COMPARE_BIT;

  localparam [ ( NUM_TARGETS* (CMPR_WIDTH) )-1 : 0 ]   SLOT_MIN_VEC  = 
                              { SLOT31_MIN_VEC[CMPR_WIDTH-1:0], SLOT30_MIN_VEC[CMPR_WIDTH-1:0], SLOT29_MIN_VEC[CMPR_WIDTH-1:0], SLOT28_MIN_VEC[CMPR_WIDTH-1:0],
                                SLOT27_MIN_VEC[CMPR_WIDTH-1:0], SLOT26_MIN_VEC[CMPR_WIDTH-1:0], SLOT25_MIN_VEC[CMPR_WIDTH-1:0], SLOT24_MIN_VEC[CMPR_WIDTH-1:0],
                                SLOT23_MIN_VEC[CMPR_WIDTH-1:0], SLOT22_MIN_VEC[CMPR_WIDTH-1:0], SLOT21_MIN_VEC[CMPR_WIDTH-1:0], SLOT20_MIN_VEC[CMPR_WIDTH-1:0],
                                SLOT19_MIN_VEC[CMPR_WIDTH-1:0], SLOT18_MIN_VEC[CMPR_WIDTH-1:0], SLOT17_MIN_VEC[CMPR_WIDTH-1:0], SLOT16_MIN_VEC[CMPR_WIDTH-1:0],
                                SLOT15_MIN_VEC[CMPR_WIDTH-1:0], SLOT14_MIN_VEC[CMPR_WIDTH-1:0], SLOT13_MIN_VEC[CMPR_WIDTH-1:0], SLOT12_MIN_VEC[CMPR_WIDTH-1:0],
                                SLOT11_MIN_VEC[CMPR_WIDTH-1:0], SLOT10_MIN_VEC[CMPR_WIDTH-1:0], SLOT9_MIN_VEC[CMPR_WIDTH-1:0],  SLOT8_MIN_VEC[CMPR_WIDTH-1:0],
                                SLOT7_MIN_VEC[CMPR_WIDTH-1:0],  SLOT6_MIN_VEC[CMPR_WIDTH-1:0],  SLOT5_MIN_VEC[CMPR_WIDTH-1:0],  SLOT4_MIN_VEC[CMPR_WIDTH-1:0],
                                SLOT3_MIN_VEC[CMPR_WIDTH-1:0],  SLOT2_MIN_VEC[CMPR_WIDTH-1:0],  SLOT1_MIN_VEC[CMPR_WIDTH-1:0],  SLOT0_MIN_VEC[CMPR_WIDTH-1:0] };        // SLOT Min per target 
                            
  localparam [ ( NUM_TARGETS* (CMPR_WIDTH) )-1 : 0 ]   SLOT_MAX_VEC  = 
                              { SLOT31_MAX_VEC[CMPR_WIDTH-1:0], SLOT30_MAX_VEC[CMPR_WIDTH-1:0], SLOT29_MAX_VEC[CMPR_WIDTH-1:0], SLOT28_MAX_VEC[CMPR_WIDTH-1:0],
                                SLOT27_MAX_VEC[CMPR_WIDTH-1:0], SLOT26_MAX_VEC[CMPR_WIDTH-1:0], SLOT25_MAX_VEC[CMPR_WIDTH-1:0], SLOT24_MAX_VEC[CMPR_WIDTH-1:0],
                                SLOT23_MAX_VEC[CMPR_WIDTH-1:0], SLOT22_MAX_VEC[CMPR_WIDTH-1:0], SLOT21_MAX_VEC[CMPR_WIDTH-1:0], SLOT20_MAX_VEC[CMPR_WIDTH-1:0],
                                SLOT19_MAX_VEC[CMPR_WIDTH-1:0], SLOT18_MAX_VEC[CMPR_WIDTH-1:0], SLOT17_MAX_VEC[CMPR_WIDTH-1:0], SLOT16_MAX_VEC[CMPR_WIDTH-1:0],
                                SLOT15_MAX_VEC[CMPR_WIDTH-1:0], SLOT14_MAX_VEC[CMPR_WIDTH-1:0], SLOT13_MAX_VEC[CMPR_WIDTH-1:0], SLOT12_MAX_VEC[CMPR_WIDTH-1:0],
                                SLOT11_MAX_VEC[CMPR_WIDTH-1:0], SLOT10_MAX_VEC[CMPR_WIDTH-1:0], SLOT9_MAX_VEC[CMPR_WIDTH-1:0],  SLOT8_MAX_VEC[CMPR_WIDTH-1:0],
                                SLOT7_MAX_VEC[CMPR_WIDTH-1:0],  SLOT6_MAX_VEC[CMPR_WIDTH-1:0],  SLOT5_MAX_VEC[CMPR_WIDTH-1:0],  SLOT4_MAX_VEC[CMPR_WIDTH-1:0],
                                SLOT3_MAX_VEC[CMPR_WIDTH-1:0],  SLOT2_MAX_VEC[CMPR_WIDTH-1:0],  SLOT1_MAX_VEC[CMPR_WIDTH-1:0],  SLOT0_MAX_VEC[CMPR_WIDTH-1:0] };        // SLOT Max per target
                                
  // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3, 10 = AHB
  localparam [(NUM_INITIATORS*2)-1:0] INITIATOR_TYPE  = { INITIATOR15_TYPE, INITIATOR14_TYPE, INITIATOR13_TYPE, INITIATOR12_TYPE,
                                                    INITIATOR11_TYPE, INITIATOR10_TYPE, INITIATOR9_TYPE, INITIATOR8_TYPE,
                                                    INITIATOR7_TYPE, INITIATOR6_TYPE, INITIATOR5_TYPE, INITIATOR4_TYPE,
                                                    INITIATOR3_TYPE, INITIATOR2_TYPE, INITIATOR1_TYPE, INITIATOR0_TYPE };    
  
  //SAR76987 SMG should be NUM_TARGETS not NUM_INITIATORS
  // Valid Values - 00 = AXI4, 01=AXI4-Lite, 11 = AXI3
  localparam [(NUM_TARGETS*2)-1:0] TARGET_TYPE    = { TARGET31_TYPE, TARGET30_TYPE, TARGET29_TYPE, TARGET28_TYPE, TARGET27_TYPE, TARGET26_TYPE, TARGET25_TYPE, TARGET24_TYPE,
                                                    TARGET23_TYPE, TARGET22_TYPE, TARGET21_TYPE, TARGET20_TYPE, TARGET19_TYPE, TARGET18_TYPE, TARGET17_TYPE, TARGET16_TYPE,
                                                    TARGET15_TYPE, TARGET14_TYPE, TARGET13_TYPE, TARGET12_TYPE, TARGET11_TYPE, TARGET10_TYPE, TARGET9_TYPE,  TARGET8_TYPE,
                                                    TARGET7_TYPE,  TARGET6_TYPE,  TARGET5_TYPE,  TARGET4_TYPE,  TARGET3_TYPE,  TARGET2_TYPE,  TARGET1_TYPE,  TARGET0_TYPE };    

  localparam [NUM_TARGETS-1:0] TARGET_READ_ZERO_TARGET_ID    = { TARGET31_READ_ZERO_TARGET_ID, TARGET30_READ_ZERO_TARGET_ID, TARGET29_READ_ZERO_TARGET_ID, TARGET28_READ_ZERO_TARGET_ID, TARGET27_READ_ZERO_TARGET_ID, TARGET26_READ_ZERO_TARGET_ID, TARGET25_READ_ZERO_TARGET_ID, TARGET24_READ_ZERO_TARGET_ID,
                                                    TARGET23_READ_ZERO_TARGET_ID, TARGET22_READ_ZERO_TARGET_ID, TARGET21_READ_ZERO_TARGET_ID, TARGET20_READ_ZERO_TARGET_ID, TARGET19_READ_ZERO_TARGET_ID, TARGET18_READ_ZERO_TARGET_ID, TARGET17_READ_ZERO_TARGET_ID, TARGET16_READ_ZERO_TARGET_ID,
                                                    TARGET15_READ_ZERO_TARGET_ID, TARGET14_READ_ZERO_TARGET_ID, TARGET13_READ_ZERO_TARGET_ID, TARGET12_READ_ZERO_TARGET_ID, TARGET11_READ_ZERO_TARGET_ID, TARGET10_READ_ZERO_TARGET_ID, TARGET9_READ_ZERO_TARGET_ID,  TARGET8_READ_ZERO_TARGET_ID,
                                                    TARGET7_READ_ZERO_TARGET_ID,  TARGET6_READ_ZERO_TARGET_ID,  TARGET5_READ_ZERO_TARGET_ID,  TARGET4_READ_ZERO_TARGET_ID,  TARGET3_READ_ZERO_TARGET_ID,  TARGET2_READ_ZERO_TARGET_ID,  TARGET1_READ_ZERO_TARGET_ID,  TARGET0_READ_ZERO_TARGET_ID };    

  localparam [NUM_TARGETS-1:0] TARGET_WRITE_ZERO_TARGET_ID    = { TARGET31_WRITE_ZERO_TARGET_ID, TARGET30_WRITE_ZERO_TARGET_ID, TARGET29_WRITE_ZERO_TARGET_ID, TARGET28_WRITE_ZERO_TARGET_ID, TARGET27_WRITE_ZERO_TARGET_ID, TARGET26_WRITE_ZERO_TARGET_ID, TARGET25_WRITE_ZERO_TARGET_ID, TARGET24_WRITE_ZERO_TARGET_ID,
                                                    TARGET23_WRITE_ZERO_TARGET_ID, TARGET22_WRITE_ZERO_TARGET_ID, TARGET21_WRITE_ZERO_TARGET_ID, TARGET20_WRITE_ZERO_TARGET_ID, TARGET19_WRITE_ZERO_TARGET_ID, TARGET18_WRITE_ZERO_TARGET_ID, TARGET17_WRITE_ZERO_TARGET_ID, TARGET16_WRITE_ZERO_TARGET_ID,
                                                    TARGET15_WRITE_ZERO_TARGET_ID, TARGET14_WRITE_ZERO_TARGET_ID, TARGET13_WRITE_ZERO_TARGET_ID, TARGET12_WRITE_ZERO_TARGET_ID, TARGET11_WRITE_ZERO_TARGET_ID, TARGET10_WRITE_ZERO_TARGET_ID, TARGET9_WRITE_ZERO_TARGET_ID,  TARGET8_WRITE_ZERO_TARGET_ID,
                                                    TARGET7_WRITE_ZERO_TARGET_ID,  TARGET6_WRITE_ZERO_TARGET_ID,  TARGET5_WRITE_ZERO_TARGET_ID,  TARGET4_WRITE_ZERO_TARGET_ID,  TARGET3_WRITE_ZERO_TARGET_ID,  TARGET2_WRITE_ZERO_TARGET_ID,  TARGET1_WRITE_ZERO_TARGET_ID,  TARGET0_WRITE_ZERO_TARGET_ID };    

  localparam [NUM_INITIATORS-1:0]  INITIATOR_AWCHAN_RS = {INITIATOR15_AWCHAN_RS, INITIATOR14_AWCHAN_RS, INITIATOR13_AWCHAN_RS, INITIATOR12_AWCHAN_RS,  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR11_AWCHAN_RS, INITIATOR10_AWCHAN_RS, INITIATOR9_AWCHAN_RS, INITIATOR8_AWCHAN_RS,  
                                                    INITIATOR7_AWCHAN_RS, INITIATOR6_AWCHAN_RS, INITIATOR5_AWCHAN_RS, INITIATOR4_AWCHAN_RS,  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR3_AWCHAN_RS, INITIATOR2_AWCHAN_RS, INITIATOR1_AWCHAN_RS, INITIATOR0_AWCHAN_RS };

  localparam [NUM_INITIATORS-1:0]  INITIATOR_ARCHAN_RS = {INITIATOR15_ARCHAN_RS, INITIATOR14_ARCHAN_RS, INITIATOR13_ARCHAN_RS, INITIATOR12_ARCHAN_RS,  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR11_ARCHAN_RS, INITIATOR10_ARCHAN_RS, INITIATOR9_ARCHAN_RS, INITIATOR8_ARCHAN_RS,
                                                    INITIATOR7_ARCHAN_RS, INITIATOR6_ARCHAN_RS, INITIATOR5_ARCHAN_RS, INITIATOR4_ARCHAN_RS,  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR3_ARCHAN_RS, INITIATOR2_ARCHAN_RS, INITIATOR1_ARCHAN_RS, INITIATOR0_ARCHAN_RS };

  localparam [NUM_INITIATORS-1:0]  INITIATOR_WCHAN_RS = { INITIATOR15_WCHAN_RS, INITIATOR14_WCHAN_RS, INITIATOR13_WCHAN_RS, INITIATOR12_WCHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR11_WCHAN_RS, INITIATOR10_WCHAN_RS, INITIATOR9_WCHAN_RS, INITIATOR8_WCHAN_RS,
                                                    INITIATOR7_WCHAN_RS, INITIATOR6_WCHAN_RS, INITIATOR5_WCHAN_RS, INITIATOR4_WCHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR3_WCHAN_RS, INITIATOR2_WCHAN_RS, INITIATOR1_WCHAN_RS, INITIATOR0_WCHAN_RS };

  localparam [NUM_INITIATORS-1:0]  INITIATOR_RCHAN_RS = { INITIATOR15_RCHAN_RS, INITIATOR14_RCHAN_RS, INITIATOR13_RCHAN_RS, INITIATOR12_RCHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR11_RCHAN_RS, INITIATOR10_RCHAN_RS, INITIATOR9_RCHAN_RS, INITIATOR8_RCHAN_RS,
                                                    INITIATOR7_RCHAN_RS, INITIATOR6_RCHAN_RS, INITIATOR5_RCHAN_RS, INITIATOR4_RCHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR3_RCHAN_RS, INITIATOR2_RCHAN_RS, INITIATOR1_RCHAN_RS, INITIATOR0_RCHAN_RS };

  localparam [NUM_INITIATORS-1:0]  INITIATOR_BCHAN_RS = { INITIATOR15_BCHAN_RS, INITIATOR14_BCHAN_RS, INITIATOR13_BCHAN_RS, INITIATOR12_BCHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR11_BCHAN_RS, INITIATOR10_BCHAN_RS, INITIATOR9_BCHAN_RS, INITIATOR8_BCHAN_RS,
                                                    INITIATOR7_BCHAN_RS, INITIATOR6_BCHAN_RS, INITIATOR5_BCHAN_RS, INITIATOR4_BCHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR3_BCHAN_RS, INITIATOR2_BCHAN_RS, INITIATOR1_BCHAN_RS, INITIATOR0_BCHAN_RS };

  localparam [15:0]                INITIATOR_DWC_CHAN_RS = { INITIATOR15_DWC_CHAN_RS, INITIATOR14_DWC_CHAN_RS, INITIATOR13_DWC_CHAN_RS, INITIATOR12_DWC_CHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR11_DWC_CHAN_RS, INITIATOR10_DWC_CHAN_RS, INITIATOR9_DWC_CHAN_RS, INITIATOR8_DWC_CHAN_RS,
                                                    INITIATOR7_DWC_CHAN_RS, INITIATOR6_DWC_CHAN_RS, INITIATOR5_DWC_CHAN_RS, INITIATOR4_DWC_CHAN_RS,    // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
                                                    INITIATOR3_DWC_CHAN_RS, INITIATOR2_DWC_CHAN_RS, INITIATOR1_DWC_CHAN_RS, INITIATOR0_DWC_CHAN_RS };
                                                    
													
  // 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
  localparam [NUM_TARGETS-1:0] TARGET_AWCHAN_RS = { TARGET31_AWCHAN_RS, TARGET30_AWCHAN_RS, TARGET29_AWCHAN_RS, TARGET28_AWCHAN_RS, TARGET27_AWCHAN_RS, TARGET26_AWCHAN_RS, TARGET25_AWCHAN_RS, TARGET24_AWCHAN_RS,
                                                  TARGET23_AWCHAN_RS, TARGET22_AWCHAN_RS, TARGET21_AWCHAN_RS, TARGET20_AWCHAN_RS, TARGET19_AWCHAN_RS, TARGET18_AWCHAN_RS, TARGET17_AWCHAN_RS, TARGET16_AWCHAN_RS,
                                                  TARGET15_AWCHAN_RS, TARGET14_AWCHAN_RS, TARGET13_AWCHAN_RS, TARGET12_AWCHAN_RS, TARGET11_AWCHAN_RS, TARGET10_AWCHAN_RS, TARGET9_AWCHAN_RS,  TARGET8_AWCHAN_RS,
                                                  TARGET7_AWCHAN_RS,  TARGET6_AWCHAN_RS,  TARGET5_AWCHAN_RS,  TARGET4_AWCHAN_RS,  TARGET3_AWCHAN_RS,  TARGET2_AWCHAN_RS,  TARGET1_AWCHAN_RS,  TARGET0_AWCHAN_RS };
  
  // 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
  localparam [NUM_TARGETS-1:0] TARGET_ARCHAN_RS = { TARGET31_ARCHAN_RS, TARGET30_ARCHAN_RS, TARGET29_ARCHAN_RS, TARGET28_ARCHAN_RS, TARGET27_ARCHAN_RS, TARGET26_ARCHAN_RS, TARGET25_ARCHAN_RS, TARGET24_ARCHAN_RS,
                                                  TARGET23_ARCHAN_RS, TARGET22_ARCHAN_RS, TARGET21_ARCHAN_RS, TARGET20_ARCHAN_RS, TARGET19_ARCHAN_RS, TARGET18_ARCHAN_RS, TARGET17_ARCHAN_RS, TARGET16_ARCHAN_RS,
                                                  TARGET15_ARCHAN_RS, TARGET14_ARCHAN_RS, TARGET13_ARCHAN_RS, TARGET12_ARCHAN_RS, TARGET11_ARCHAN_RS, TARGET10_ARCHAN_RS, TARGET9_ARCHAN_RS,  TARGET8_ARCHAN_RS,
                                                  TARGET7_ARCHAN_RS,  TARGET6_ARCHAN_RS,  TARGET5_ARCHAN_RS,  TARGET4_ARCHAN_RS,  TARGET3_ARCHAN_RS,  TARGET2_ARCHAN_RS,  TARGET1_ARCHAN_RS,  TARGET0_ARCHAN_RS };

  // 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
  localparam [NUM_TARGETS-1:0] TARGET_WCHAN_RS = { TARGET31_WCHAN_RS, TARGET30_WCHAN_RS, TARGET29_WCHAN_RS, TARGET28_WCHAN_RS, TARGET27_WCHAN_RS, TARGET26_WCHAN_RS, TARGET25_WCHAN_RS, TARGET24_WCHAN_RS,
                                                 TARGET23_WCHAN_RS, TARGET22_WCHAN_RS, TARGET21_WCHAN_RS, TARGET20_WCHAN_RS, TARGET19_WCHAN_RS, TARGET18_WCHAN_RS, TARGET17_WCHAN_RS, TARGET16_WCHAN_RS,
                                                 TARGET15_WCHAN_RS, TARGET14_WCHAN_RS, TARGET13_WCHAN_RS, TARGET12_WCHAN_RS, TARGET11_WCHAN_RS, TARGET10_WCHAN_RS, TARGET9_WCHAN_RS,  TARGET8_WCHAN_RS,
                                                 TARGET7_WCHAN_RS,  TARGET6_WCHAN_RS,  TARGET5_WCHAN_RS,  TARGET4_WCHAN_RS,  TARGET3_WCHAN_RS,  TARGET2_WCHAN_RS,  TARGET1_WCHAN_RS,  TARGET0_WCHAN_RS  };

  // 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
  localparam [NUM_TARGETS-1:0] TARGET_RCHAN_RS = { TARGET31_RCHAN_RS, TARGET30_RCHAN_RS, TARGET29_RCHAN_RS, TARGET28_RCHAN_RS, TARGET27_RCHAN_RS, TARGET26_RCHAN_RS, TARGET25_RCHAN_RS, TARGET24_RCHAN_RS,
                                                 TARGET23_RCHAN_RS, TARGET22_RCHAN_RS, TARGET21_RCHAN_RS, TARGET20_RCHAN_RS, TARGET19_RCHAN_RS, TARGET18_RCHAN_RS, TARGET17_RCHAN_RS, TARGET16_RCHAN_RS,
                                                 TARGET15_RCHAN_RS, TARGET14_RCHAN_RS, TARGET13_RCHAN_RS, TARGET12_RCHAN_RS, TARGET11_RCHAN_RS, TARGET10_RCHAN_RS, TARGET9_RCHAN_RS,  TARGET8_RCHAN_RS,
                                                 TARGET7_RCHAN_RS,  TARGET6_RCHAN_RS,  TARGET5_RCHAN_RS,  TARGET4_RCHAN_RS,  TARGET3_RCHAN_RS,  TARGET2_RCHAN_RS,  TARGET1_RCHAN_RS,  TARGET0_RCHAN_RS  };

  // 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
  localparam [NUM_TARGETS-1:0] TARGET_BCHAN_RS = { TARGET31_BCHAN_RS, TARGET30_BCHAN_RS, TARGET29_BCHAN_RS, TARGET28_BCHAN_RS, TARGET27_BCHAN_RS, TARGET26_BCHAN_RS, TARGET25_BCHAN_RS, TARGET24_BCHAN_RS,
                                                 TARGET23_BCHAN_RS, TARGET22_BCHAN_RS, TARGET21_BCHAN_RS, TARGET20_BCHAN_RS, TARGET19_BCHAN_RS, TARGET18_BCHAN_RS, TARGET17_BCHAN_RS, TARGET16_BCHAN_RS,
                                                 TARGET15_BCHAN_RS, TARGET14_BCHAN_RS, TARGET13_BCHAN_RS, TARGET12_BCHAN_RS, TARGET11_BCHAN_RS, TARGET10_BCHAN_RS, TARGET9_BCHAN_RS,  TARGET8_BCHAN_RS,
                                                 TARGET7_BCHAN_RS,  TARGET6_BCHAN_RS,  TARGET5_BCHAN_RS,  TARGET4_BCHAN_RS,  TARGET3_BCHAN_RS,  TARGET2_BCHAN_RS,  TARGET1_BCHAN_RS,  TARGET0_BCHAN_RS };

  localparam [31:0]            TARGET_DWC_CHAN_RS = { TARGET31_DWC_CHAN_RS, TARGET30_DWC_CHAN_RS, TARGET29_DWC_CHAN_RS, TARGET28_DWC_CHAN_RS, TARGET27_DWC_CHAN_RS, TARGET26_DWC_CHAN_RS, TARGET25_DWC_CHAN_RS, TARGET24_DWC_CHAN_RS,
                                                 TARGET23_DWC_CHAN_RS, TARGET22_DWC_CHAN_RS, TARGET21_DWC_CHAN_RS, TARGET20_DWC_CHAN_RS, TARGET19_DWC_CHAN_RS, TARGET18_DWC_CHAN_RS, TARGET17_DWC_CHAN_RS, TARGET16_DWC_CHAN_RS,
                                                 TARGET15_DWC_CHAN_RS, TARGET14_DWC_CHAN_RS, TARGET13_DWC_CHAN_RS, TARGET12_DWC_CHAN_RS, TARGET11_DWC_CHAN_RS, TARGET10_DWC_CHAN_RS, TARGET9_DWC_CHAN_RS,  TARGET8_DWC_CHAN_RS,
                                                 TARGET7_DWC_CHAN_RS,  TARGET6_DWC_CHAN_RS,  TARGET5_DWC_CHAN_RS,  TARGET4_DWC_CHAN_RS,  TARGET3_DWC_CHAN_RS,  TARGET2_DWC_CHAN_RS,  TARGET1_DWC_CHAN_RS,  TARGET0_DWC_CHAN_RS };

  localparam [(2*NUM_INITIATORS)-1:0] AHB_INITIATOR_PORTS_BRESP_CHECK_MODE = { AHB_INITIATOR15_BRESP_CHECK_MODE, AHB_INITIATOR14_BRESP_CHECK_MODE, AHB_INITIATOR13_BRESP_CHECK_MODE, AHB_INITIATOR12_BRESP_CHECK_MODE, AHB_INITIATOR11_BRESP_CHECK_MODE, AHB_INITIATOR10_BRESP_CHECK_MODE, AHB_INITIATOR9_BRESP_CHECK_MODE, AHB_INITIATOR8_BRESP_CHECK_MODE,
                                                                         AHB_INITIATOR7_BRESP_CHECK_MODE,  AHB_INITIATOR6_BRESP_CHECK_MODE,  AHB_INITIATOR5_BRESP_CHECK_MODE,  AHB_INITIATOR4_BRESP_CHECK_MODE,  AHB_INITIATOR3_BRESP_CHECK_MODE,  AHB_INITIATOR2_BRESP_CHECK_MODE,  AHB_INITIATOR1_BRESP_CHECK_MODE, AHB_INITIATOR0_BRESP_CHECK_MODE };

  localparam [(32*NUM_INITIATORS)-1:0] AHB_INITIATOR_PORTS_BRESP_CNT_WIDTH = {AHB_INITIATOR15_BRESP_CNT_WIDTH,AHB_INITIATOR14_BRESP_CNT_WIDTH,AHB_INITIATOR13_BRESP_CNT_WIDTH,AHB_INITIATOR12_BRESP_CNT_WIDTH,AHB_INITIATOR11_BRESP_CNT_WIDTH,AHB_INITIATOR10_BRESP_CNT_WIDTH,AHB_INITIATOR9_BRESP_CNT_WIDTH,AHB_INITIATOR8_BRESP_CNT_WIDTH,
                                                                        AHB_INITIATOR7_BRESP_CNT_WIDTH, AHB_INITIATOR6_BRESP_CNT_WIDTH, AHB_INITIATOR5_BRESP_CNT_WIDTH, AHB_INITIATOR4_BRESP_CNT_WIDTH, AHB_INITIATOR3_BRESP_CNT_WIDTH, AHB_INITIATOR2_BRESP_CNT_WIDTH, AHB_INITIATOR1_BRESP_CNT_WIDTH,AHB_INITIATOR0_BRESP_CNT_WIDTH};



  localparam [(NUM_INITIATORS*32)-1:0] INITIATOR_PORTS_DATA_WIDTH = {INITIATOR15_DATA_WIDTH,INITIATOR14_DATA_WIDTH,INITIATOR13_DATA_WIDTH,INITIATOR12_DATA_WIDTH,INITIATOR11_DATA_WIDTH,INITIATOR10_DATA_WIDTH,INITIATOR9_DATA_WIDTH,INITIATOR8_DATA_WIDTH,
                                                               INITIATOR7_DATA_WIDTH, INITIATOR6_DATA_WIDTH, INITIATOR5_DATA_WIDTH, INITIATOR4_DATA_WIDTH, INITIATOR3_DATA_WIDTH, INITIATOR2_DATA_WIDTH, INITIATOR1_DATA_WIDTH,INITIATOR0_DATA_WIDTH};
  
  localparam [(NUM_TARGETS*32)-1:0]  TARGET_PORTS_DATA_WIDTH  = {
                                      TARGET31_DATA_WIDTH,
                                      TARGET30_DATA_WIDTH,
                                      TARGET29_DATA_WIDTH,
                                      TARGET28_DATA_WIDTH,
                                      TARGET27_DATA_WIDTH,
                                      TARGET26_DATA_WIDTH,
                                      TARGET25_DATA_WIDTH,
                                      TARGET24_DATA_WIDTH,
                                      TARGET23_DATA_WIDTH,
                                      TARGET22_DATA_WIDTH,
                                      TARGET21_DATA_WIDTH,
                                      TARGET20_DATA_WIDTH,
                                      TARGET19_DATA_WIDTH,
                                      TARGET18_DATA_WIDTH,
                                      TARGET17_DATA_WIDTH,
                                      TARGET16_DATA_WIDTH,  
                                      TARGET15_DATA_WIDTH,
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
                          
                                    
  localparam integer INITIATOR_DATA_WIDTH_PORT = ( INITIATOR15_DATA_WIDTH + INITIATOR14_DATA_WIDTH + INITIATOR13_DATA_WIDTH + INITIATOR12_DATA_WIDTH + 
                                                INITIATOR11_DATA_WIDTH + INITIATOR10_DATA_WIDTH + INITIATOR9_DATA_WIDTH + INITIATOR8_DATA_WIDTH +
                                                INITIATOR7_DATA_WIDTH + INITIATOR6_DATA_WIDTH + INITIATOR5_DATA_WIDTH + INITIATOR4_DATA_WIDTH + 
                                                INITIATOR3_DATA_WIDTH + INITIATOR2_DATA_WIDTH + INITIATOR1_DATA_WIDTH + INITIATOR0_DATA_WIDTH);
  
  // SAR#LINT-001: Explicit bit-select to avoid width overflow warnings
  // Max cumulative width: 16 initiators x 512 bits = 8192 bits (fits in 13 bits)
  localparam [12:0] MDW0_UPPER = INITIATOR0_DATA_WIDTH[12:0];
  localparam [12:0] MDW1_UPPER = (MDW0_UPPER + INITIATOR1_DATA_WIDTH[12:0]);
  localparam [12:0] MDW2_UPPER = (MDW1_UPPER + INITIATOR2_DATA_WIDTH[12:0]);
  localparam [12:0] MDW3_UPPER = (MDW2_UPPER + INITIATOR3_DATA_WIDTH[12:0]);
  localparam [12:0] MDW4_UPPER = (MDW3_UPPER + INITIATOR4_DATA_WIDTH[12:0]);
  localparam [12:0] MDW5_UPPER = (MDW4_UPPER + INITIATOR5_DATA_WIDTH[12:0]);
  localparam [12:0] MDW6_UPPER = (MDW5_UPPER + INITIATOR6_DATA_WIDTH[12:0]);
  localparam [12:0] MDW7_UPPER = (MDW6_UPPER + INITIATOR7_DATA_WIDTH[12:0]);
  localparam [12:0] MDW8_UPPER = (MDW7_UPPER + INITIATOR8_DATA_WIDTH[12:0]);
  localparam [12:0] MDW9_UPPER = (MDW8_UPPER + INITIATOR9_DATA_WIDTH[12:0]);
  localparam [12:0] MDW10_UPPER = (MDW9_UPPER + INITIATOR10_DATA_WIDTH[12:0]);
  localparam [12:0] MDW11_UPPER = (MDW10_UPPER + INITIATOR11_DATA_WIDTH[12:0]);
  localparam [12:0] MDW12_UPPER = (MDW11_UPPER + INITIATOR12_DATA_WIDTH[12:0]);
  localparam [12:0] MDW13_UPPER = (MDW12_UPPER + INITIATOR13_DATA_WIDTH[12:0]);
  localparam [12:0] MDW14_UPPER = (MDW13_UPPER + INITIATOR14_DATA_WIDTH[12:0]);
  localparam [12:0] MDW15_UPPER = (MDW14_UPPER + INITIATOR15_DATA_WIDTH[12:0]);

  localparam integer TARGET_DATA_WIDTH_PORT = ( TARGET31_DATA_WIDTH + TARGET30_DATA_WIDTH + TARGET29_DATA_WIDTH + TARGET28_DATA_WIDTH + TARGET27_DATA_WIDTH +
                                               TARGET26_DATA_WIDTH + TARGET25_DATA_WIDTH + TARGET24_DATA_WIDTH + TARGET23_DATA_WIDTH + TARGET22_DATA_WIDTH +
                                               TARGET21_DATA_WIDTH + TARGET20_DATA_WIDTH + TARGET19_DATA_WIDTH + TARGET18_DATA_WIDTH + TARGET17_DATA_WIDTH +
                                               TARGET16_DATA_WIDTH + TARGET15_DATA_WIDTH + TARGET14_DATA_WIDTH + TARGET13_DATA_WIDTH + TARGET12_DATA_WIDTH +
                                               TARGET11_DATA_WIDTH + TARGET10_DATA_WIDTH + TARGET9_DATA_WIDTH + TARGET8_DATA_WIDTH +
                                               TARGET7_DATA_WIDTH + TARGET6_DATA_WIDTH + TARGET5_DATA_WIDTH + TARGET4_DATA_WIDTH +
                                               TARGET3_DATA_WIDTH + TARGET2_DATA_WIDTH + TARGET1_DATA_WIDTH + TARGET0_DATA_WIDTH);
  
  // SAR#LINT-001: Explicit bit-select to avoid width overflow warnings
  // Max cumulative width: 32 targets x 512 bits = 16384 bits (fits in 14 bits, using 13 with safe truncation)
  localparam [12:0] SDW0_UPPER = TARGET0_DATA_WIDTH[12:0];
  localparam [12:0] SDW1_UPPER = (SDW0_UPPER + TARGET1_DATA_WIDTH[12:0]);
  localparam [12:0] SDW2_UPPER = (SDW1_UPPER + TARGET2_DATA_WIDTH[12:0]);
  localparam [12:0] SDW3_UPPER = (SDW2_UPPER + TARGET3_DATA_WIDTH[12:0]);
  localparam [12:0] SDW4_UPPER = (SDW3_UPPER + TARGET4_DATA_WIDTH[12:0]);
  localparam [12:0] SDW5_UPPER = (SDW4_UPPER + TARGET5_DATA_WIDTH[12:0]);
  localparam [12:0] SDW6_UPPER = (SDW5_UPPER + TARGET6_DATA_WIDTH[12:0]);
  localparam [12:0] SDW7_UPPER = (SDW6_UPPER + TARGET7_DATA_WIDTH[12:0]);
  localparam [12:0] SDW8_UPPER  = (SDW7_UPPER  + TARGET8_DATA_WIDTH[12:0]);
  localparam [12:0] SDW9_UPPER  = (SDW8_UPPER  + TARGET9_DATA_WIDTH[12:0]);
  localparam [12:0] SDW10_UPPER = (SDW9_UPPER  + TARGET10_DATA_WIDTH[12:0]);
  localparam [12:0] SDW11_UPPER = (SDW10_UPPER + TARGET11_DATA_WIDTH[12:0]);
  localparam [12:0] SDW12_UPPER = (SDW11_UPPER + TARGET12_DATA_WIDTH[12:0]);
  localparam [12:0] SDW13_UPPER = (SDW12_UPPER + TARGET13_DATA_WIDTH[12:0]);
  localparam [12:0] SDW14_UPPER = (SDW13_UPPER + TARGET14_DATA_WIDTH[12:0]);
  localparam [12:0] SDW15_UPPER = (SDW14_UPPER + TARGET15_DATA_WIDTH[12:0]);
  localparam [12:0] SDW16_UPPER = (SDW15_UPPER + TARGET16_DATA_WIDTH[12:0]);
  localparam [12:0] SDW17_UPPER = (SDW16_UPPER + TARGET17_DATA_WIDTH[12:0]);
  localparam [12:0] SDW18_UPPER = (SDW17_UPPER + TARGET18_DATA_WIDTH[12:0]);
  localparam [12:0] SDW19_UPPER = (SDW18_UPPER + TARGET19_DATA_WIDTH[12:0]);
  localparam [12:0] SDW20_UPPER = (SDW19_UPPER + TARGET20_DATA_WIDTH[12:0]);
  localparam [12:0] SDW21_UPPER = (SDW20_UPPER + TARGET21_DATA_WIDTH[12:0]);
  localparam [12:0] SDW22_UPPER = (SDW21_UPPER + TARGET22_DATA_WIDTH[12:0]);
  localparam [12:0] SDW23_UPPER = (SDW22_UPPER + TARGET23_DATA_WIDTH[12:0]);
  localparam [12:0] SDW24_UPPER = (SDW23_UPPER + TARGET24_DATA_WIDTH[12:0]);
  localparam [12:0] SDW25_UPPER = (SDW24_UPPER + TARGET25_DATA_WIDTH[12:0]);
  localparam [12:0] SDW26_UPPER = (SDW25_UPPER + TARGET26_DATA_WIDTH[12:0]);
  localparam [12:0] SDW27_UPPER = (SDW26_UPPER + TARGET27_DATA_WIDTH[12:0]);
  localparam [12:0] SDW28_UPPER = (SDW27_UPPER + TARGET28_DATA_WIDTH[12:0]);
  localparam [12:0] SDW29_UPPER = (SDW28_UPPER + TARGET29_DATA_WIDTH[12:0]);
  localparam [12:0] SDW30_UPPER = (SDW29_UPPER + TARGET30_DATA_WIDTH[12:0]);
  localparam [12:0] SDW31_UPPER = (SDW30_UPPER + TARGET31_DATA_WIDTH[12:0]);

  localparam [13*NUM_INITIATORS-1:0] MDW_UPPER_VEC = { MDW15_UPPER, MDW14_UPPER, MDW13_UPPER, MDW12_UPPER, MDW11_UPPER, MDW10_UPPER, MDW9_UPPER, MDW8_UPPER, MDW7_UPPER, MDW6_UPPER, MDW5_UPPER, MDW4_UPPER, MDW3_UPPER, MDW2_UPPER, MDW1_UPPER, MDW0_UPPER };
  localparam [13*NUM_INITIATORS-1:0] MDW_LOWER_VEC = { MDW14_UPPER, MDW13_UPPER, MDW12_UPPER, MDW11_UPPER, MDW10_UPPER, MDW9_UPPER,  MDW8_UPPER, MDW7_UPPER, MDW6_UPPER, MDW5_UPPER, MDW4_UPPER, MDW3_UPPER, MDW2_UPPER, MDW1_UPPER, MDW0_UPPER, 13'h0 };
  
  localparam [13*NUM_TARGETS-1:0] SDW_UPPER_VEC = { SDW31_UPPER, SDW30_UPPER, SDW29_UPPER, SDW28_UPPER, 
                                          SDW27_UPPER, SDW26_UPPER, SDW25_UPPER, SDW24_UPPER, 
                                          SDW23_UPPER, SDW22_UPPER, SDW21_UPPER, SDW20_UPPER,
                                          SDW19_UPPER, SDW18_UPPER, SDW17_UPPER, SDW16_UPPER, 
                                          SDW15_UPPER, SDW14_UPPER, SDW13_UPPER, SDW12_UPPER, 
                                          SDW11_UPPER, SDW10_UPPER, SDW9_UPPER, SDW8_UPPER, 
                                          SDW7_UPPER, SDW6_UPPER, SDW5_UPPER, SDW4_UPPER, 
                                          SDW3_UPPER, SDW2_UPPER, SDW1_UPPER, SDW0_UPPER  };
                                          
  localparam [13*NUM_TARGETS-1:0] SDW_LOWER_VEC = { SDW30_UPPER, SDW29_UPPER, SDW28_UPPER, SDW27_UPPER, 
                                          SDW26_UPPER, SDW25_UPPER, SDW24_UPPER, SDW23_UPPER, 
                                          SDW22_UPPER, SDW21_UPPER, SDW20_UPPER, SDW19_UPPER, 
                                          SDW18_UPPER, SDW17_UPPER, SDW16_UPPER, SDW15_UPPER, 
                                          SDW14_UPPER, SDW13_UPPER, SDW12_UPPER, SDW11_UPPER, 
                                          SDW10_UPPER, SDW9_UPPER, SDW8_UPPER, SDW7_UPPER, 
                                          SDW6_UPPER, SDW5_UPPER, SDW4_UPPER,SDW3_UPPER, 
                                          SDW2_UPPER, SDW1_UPPER, SDW0_UPPER, 13'h0 };
  
  localparam integer INITIATOR_STRB_WIDTH_PORT = ( INITIATOR0_DATA_WIDTH/8 + INITIATOR1_DATA_WIDTH/8 + INITIATOR2_DATA_WIDTH/8 + INITIATOR3_DATA_WIDTH/8 + INITIATOR4_DATA_WIDTH/8 + INITIATOR5_DATA_WIDTH/8 + INITIATOR6_DATA_WIDTH/8 + INITIATOR7_DATA_WIDTH/8 +
                                                INITIATOR8_DATA_WIDTH/8 + INITIATOR9_DATA_WIDTH/8 + INITIATOR10_DATA_WIDTH/8 + INITIATOR11_DATA_WIDTH/8 + INITIATOR12_DATA_WIDTH/8 + INITIATOR13_DATA_WIDTH/8 + INITIATOR14_DATA_WIDTH/8 + INITIATOR15_DATA_WIDTH/8);
  
  localparam integer TARGET_STRB_WIDTH_PORT = ( TARGET31_DATA_WIDTH/8 + TARGET30_DATA_WIDTH/8 + TARGET29_DATA_WIDTH/8 + TARGET28_DATA_WIDTH/8 + 
                                               TARGET27_DATA_WIDTH/8 + TARGET26_DATA_WIDTH/8 + TARGET25_DATA_WIDTH/8 + TARGET24_DATA_WIDTH/8 + 
                                               TARGET23_DATA_WIDTH/8 + TARGET22_DATA_WIDTH/8 + TARGET21_DATA_WIDTH/8 + TARGET20_DATA_WIDTH/8 + 
                                               TARGET19_DATA_WIDTH/8 + TARGET18_DATA_WIDTH/8 + TARGET17_DATA_WIDTH/8 + TARGET16_DATA_WIDTH/8 + 
                                               TARGET15_DATA_WIDTH/8 + TARGET14_DATA_WIDTH/8 + TARGET13_DATA_WIDTH/8 + TARGET12_DATA_WIDTH/8 + 
                                               TARGET11_DATA_WIDTH/8 + TARGET10_DATA_WIDTH/8 + TARGET9_DATA_WIDTH/8 + TARGET8_DATA_WIDTH/8 + 
                                               TARGET7_DATA_WIDTH/8 + TARGET6_DATA_WIDTH/8 + TARGET5_DATA_WIDTH/8 + TARGET4_DATA_WIDTH/8 + 
                                               TARGET3_DATA_WIDTH/8 + TARGET2_DATA_WIDTH/8 + TARGET1_DATA_WIDTH/8 + TARGET0_DATA_WIDTH/8 );

  localparam [NUM_TARGETS-1:0]   INITIATOR0_WRITE_CONNECTIVITY   = { INITIATOR0_WRITE_TARGET31, INITIATOR0_WRITE_TARGET30, INITIATOR0_WRITE_TARGET29, INITIATOR0_WRITE_TARGET28, INITIATOR0_WRITE_TARGET27, INITIATOR0_WRITE_TARGET26, INITIATOR0_WRITE_TARGET25, INITIATOR0_WRITE_TARGET24, 
                                                                 INITIATOR0_WRITE_TARGET23, INITIATOR0_WRITE_TARGET22, INITIATOR0_WRITE_TARGET21, INITIATOR0_WRITE_TARGET20, INITIATOR0_WRITE_TARGET19, INITIATOR0_WRITE_TARGET18, INITIATOR0_WRITE_TARGET17, INITIATOR0_WRITE_TARGET16, 
                                                                 INITIATOR0_WRITE_TARGET15, INITIATOR0_WRITE_TARGET14, INITIATOR0_WRITE_TARGET13, INITIATOR0_WRITE_TARGET12, INITIATOR0_WRITE_TARGET11, INITIATOR0_WRITE_TARGET10, INITIATOR0_WRITE_TARGET9,  INITIATOR0_WRITE_TARGET8,  
                                                                 INITIATOR0_WRITE_TARGET7,  INITIATOR0_WRITE_TARGET6,  INITIATOR0_WRITE_TARGET5,  INITIATOR0_WRITE_TARGET4,  INITIATOR0_WRITE_TARGET3,  INITIATOR0_WRITE_TARGET2,  INITIATOR0_WRITE_TARGET1,  INITIATOR0_WRITE_TARGET0 } ;

  localparam [NUM_TARGETS-1:0]   INITIATOR1_WRITE_CONNECTIVITY   = { INITIATOR1_WRITE_TARGET31, INITIATOR1_WRITE_TARGET30, INITIATOR1_WRITE_TARGET29, INITIATOR1_WRITE_TARGET28, INITIATOR1_WRITE_TARGET27, INITIATOR1_WRITE_TARGET26, INITIATOR1_WRITE_TARGET25, INITIATOR1_WRITE_TARGET24, 
                                                                 INITIATOR1_WRITE_TARGET23, INITIATOR1_WRITE_TARGET22, INITIATOR1_WRITE_TARGET21, INITIATOR1_WRITE_TARGET20, INITIATOR1_WRITE_TARGET19, INITIATOR1_WRITE_TARGET18, INITIATOR1_WRITE_TARGET17, INITIATOR1_WRITE_TARGET16, 
                                                                 INITIATOR1_WRITE_TARGET15, INITIATOR1_WRITE_TARGET14, INITIATOR1_WRITE_TARGET13, INITIATOR1_WRITE_TARGET12, INITIATOR1_WRITE_TARGET11, INITIATOR1_WRITE_TARGET10, INITIATOR1_WRITE_TARGET9,  INITIATOR1_WRITE_TARGET8,  
                                                                 INITIATOR1_WRITE_TARGET7,  INITIATOR1_WRITE_TARGET6,  INITIATOR1_WRITE_TARGET5,  INITIATOR1_WRITE_TARGET4,  INITIATOR1_WRITE_TARGET3,  INITIATOR1_WRITE_TARGET2,  INITIATOR1_WRITE_TARGET1,  INITIATOR1_WRITE_TARGET0 };
  
  localparam [NUM_TARGETS-1:0]   INITIATOR2_WRITE_CONNECTIVITY   = { INITIATOR2_WRITE_TARGET31, INITIATOR2_WRITE_TARGET30, INITIATOR2_WRITE_TARGET29, INITIATOR2_WRITE_TARGET28, INITIATOR2_WRITE_TARGET27, INITIATOR2_WRITE_TARGET26, INITIATOR2_WRITE_TARGET25, INITIATOR2_WRITE_TARGET24, 
                                                                 INITIATOR2_WRITE_TARGET23, INITIATOR2_WRITE_TARGET22, INITIATOR2_WRITE_TARGET21, INITIATOR2_WRITE_TARGET20, INITIATOR2_WRITE_TARGET19, INITIATOR2_WRITE_TARGET18, INITIATOR2_WRITE_TARGET17, INITIATOR2_WRITE_TARGET16, 
                                                                 INITIATOR2_WRITE_TARGET15, INITIATOR2_WRITE_TARGET14, INITIATOR2_WRITE_TARGET13, INITIATOR2_WRITE_TARGET12, INITIATOR2_WRITE_TARGET11, INITIATOR2_WRITE_TARGET10, INITIATOR2_WRITE_TARGET9,  INITIATOR2_WRITE_TARGET8,  
                                                                 INITIATOR2_WRITE_TARGET7,  INITIATOR2_WRITE_TARGET6,  INITIATOR2_WRITE_TARGET5,  INITIATOR2_WRITE_TARGET4,  INITIATOR2_WRITE_TARGET3,  INITIATOR2_WRITE_TARGET2,  INITIATOR2_WRITE_TARGET1,  INITIATOR2_WRITE_TARGET0 };

  localparam [NUM_TARGETS-1:0]   INITIATOR3_WRITE_CONNECTIVITY   = { INITIATOR3_WRITE_TARGET31, INITIATOR3_WRITE_TARGET30, INITIATOR3_WRITE_TARGET29, INITIATOR3_WRITE_TARGET28, INITIATOR3_WRITE_TARGET27, INITIATOR3_WRITE_TARGET26, INITIATOR3_WRITE_TARGET25, INITIATOR3_WRITE_TARGET24, 
                                                                 INITIATOR3_WRITE_TARGET23, INITIATOR3_WRITE_TARGET22, INITIATOR3_WRITE_TARGET21, INITIATOR3_WRITE_TARGET20, INITIATOR3_WRITE_TARGET19, INITIATOR3_WRITE_TARGET18, INITIATOR3_WRITE_TARGET17, INITIATOR3_WRITE_TARGET16, 
                                                                 INITIATOR3_WRITE_TARGET15, INITIATOR3_WRITE_TARGET14, INITIATOR3_WRITE_TARGET13, INITIATOR3_WRITE_TARGET12, INITIATOR3_WRITE_TARGET11, INITIATOR3_WRITE_TARGET10, INITIATOR3_WRITE_TARGET9,  INITIATOR3_WRITE_TARGET8,  
                                                                 INITIATOR3_WRITE_TARGET7,  INITIATOR3_WRITE_TARGET6,  INITIATOR3_WRITE_TARGET5,  INITIATOR3_WRITE_TARGET4,  INITIATOR3_WRITE_TARGET3,  INITIATOR3_WRITE_TARGET2,  INITIATOR3_WRITE_TARGET1,  INITIATOR3_WRITE_TARGET0 };

  localparam [NUM_TARGETS-1:0]   INITIATOR4_WRITE_CONNECTIVITY   = { INITIATOR4_WRITE_TARGET31, INITIATOR4_WRITE_TARGET30, INITIATOR4_WRITE_TARGET29, INITIATOR4_WRITE_TARGET28, INITIATOR4_WRITE_TARGET27, INITIATOR4_WRITE_TARGET26, INITIATOR4_WRITE_TARGET25, INITIATOR4_WRITE_TARGET24, 
                                                                 INITIATOR4_WRITE_TARGET23, INITIATOR4_WRITE_TARGET22, INITIATOR4_WRITE_TARGET21, INITIATOR4_WRITE_TARGET20, INITIATOR4_WRITE_TARGET19, INITIATOR4_WRITE_TARGET18, INITIATOR4_WRITE_TARGET17, INITIATOR4_WRITE_TARGET16, 
                                                                 INITIATOR4_WRITE_TARGET15, INITIATOR4_WRITE_TARGET14, INITIATOR4_WRITE_TARGET13, INITIATOR4_WRITE_TARGET12, INITIATOR4_WRITE_TARGET11, INITIATOR4_WRITE_TARGET10, INITIATOR4_WRITE_TARGET9,  INITIATOR4_WRITE_TARGET8,  
                                                                 INITIATOR4_WRITE_TARGET7,  INITIATOR4_WRITE_TARGET6,  INITIATOR4_WRITE_TARGET5,  INITIATOR4_WRITE_TARGET4,  INITIATOR4_WRITE_TARGET3,  INITIATOR4_WRITE_TARGET2,  INITIATOR4_WRITE_TARGET1,  INITIATOR4_WRITE_TARGET0 };

  localparam [NUM_TARGETS-1:0]   INITIATOR5_WRITE_CONNECTIVITY   = { INITIATOR5_WRITE_TARGET31, INITIATOR5_WRITE_TARGET30, INITIATOR5_WRITE_TARGET29, INITIATOR5_WRITE_TARGET28, INITIATOR5_WRITE_TARGET27, INITIATOR5_WRITE_TARGET26, INITIATOR5_WRITE_TARGET25, INITIATOR5_WRITE_TARGET24, 
                                                                 INITIATOR5_WRITE_TARGET23, INITIATOR5_WRITE_TARGET22, INITIATOR5_WRITE_TARGET21, INITIATOR5_WRITE_TARGET20, INITIATOR5_WRITE_TARGET19, INITIATOR5_WRITE_TARGET18, INITIATOR5_WRITE_TARGET17, INITIATOR5_WRITE_TARGET16, 
                                                                 INITIATOR5_WRITE_TARGET15, INITIATOR5_WRITE_TARGET14, INITIATOR5_WRITE_TARGET13, INITIATOR5_WRITE_TARGET12, INITIATOR5_WRITE_TARGET11, INITIATOR5_WRITE_TARGET10, INITIATOR5_WRITE_TARGET9,  INITIATOR5_WRITE_TARGET8,  
                                                                 INITIATOR5_WRITE_TARGET7,  INITIATOR5_WRITE_TARGET6,  INITIATOR5_WRITE_TARGET5,  INITIATOR5_WRITE_TARGET4,  INITIATOR5_WRITE_TARGET3,  INITIATOR5_WRITE_TARGET2,  INITIATOR5_WRITE_TARGET1,  INITIATOR5_WRITE_TARGET0 };
                            
  localparam [NUM_TARGETS-1:0]   INITIATOR6_WRITE_CONNECTIVITY   = { INITIATOR6_WRITE_TARGET31, INITIATOR6_WRITE_TARGET30, INITIATOR6_WRITE_TARGET29, INITIATOR6_WRITE_TARGET28, INITIATOR6_WRITE_TARGET27, INITIATOR6_WRITE_TARGET26, INITIATOR6_WRITE_TARGET25, INITIATOR6_WRITE_TARGET24, 
                                                                 INITIATOR6_WRITE_TARGET23, INITIATOR6_WRITE_TARGET22, INITIATOR6_WRITE_TARGET21, INITIATOR6_WRITE_TARGET20, INITIATOR6_WRITE_TARGET19, INITIATOR6_WRITE_TARGET18, INITIATOR6_WRITE_TARGET17, INITIATOR6_WRITE_TARGET16, 
                                                                 INITIATOR6_WRITE_TARGET15, INITIATOR6_WRITE_TARGET14, INITIATOR6_WRITE_TARGET13, INITIATOR6_WRITE_TARGET12, INITIATOR6_WRITE_TARGET11, INITIATOR6_WRITE_TARGET10, INITIATOR6_WRITE_TARGET9,  INITIATOR6_WRITE_TARGET8,  
                                                                 INITIATOR6_WRITE_TARGET7,  INITIATOR6_WRITE_TARGET6,  INITIATOR6_WRITE_TARGET5,  INITIATOR6_WRITE_TARGET4,  INITIATOR6_WRITE_TARGET3,  INITIATOR6_WRITE_TARGET2,  INITIATOR6_WRITE_TARGET1,  INITIATOR6_WRITE_TARGET0 };

  localparam [NUM_TARGETS-1:0]   INITIATOR7_WRITE_CONNECTIVITY   = { INITIATOR7_WRITE_TARGET31, INITIATOR7_WRITE_TARGET30, INITIATOR7_WRITE_TARGET29, INITIATOR7_WRITE_TARGET28, INITIATOR7_WRITE_TARGET27, INITIATOR7_WRITE_TARGET26, INITIATOR7_WRITE_TARGET25, INITIATOR7_WRITE_TARGET24, 
                                                                 INITIATOR7_WRITE_TARGET23, INITIATOR7_WRITE_TARGET22, INITIATOR7_WRITE_TARGET21, INITIATOR7_WRITE_TARGET20, INITIATOR7_WRITE_TARGET19, INITIATOR7_WRITE_TARGET18, INITIATOR7_WRITE_TARGET17, INITIATOR7_WRITE_TARGET16, 
                                                                 INITIATOR7_WRITE_TARGET15, INITIATOR7_WRITE_TARGET14, INITIATOR7_WRITE_TARGET13, INITIATOR7_WRITE_TARGET12, INITIATOR7_WRITE_TARGET11, INITIATOR7_WRITE_TARGET10, INITIATOR7_WRITE_TARGET9,  INITIATOR7_WRITE_TARGET8,  
                                                                 INITIATOR7_WRITE_TARGET7,  INITIATOR7_WRITE_TARGET6,  INITIATOR7_WRITE_TARGET5,  INITIATOR7_WRITE_TARGET4,  INITIATOR7_WRITE_TARGET3,  INITIATOR7_WRITE_TARGET2,  INITIATOR7_WRITE_TARGET1,  INITIATOR7_WRITE_TARGET0 };
																 
  localparam [NUM_TARGETS-1:0]   INITIATOR8_WRITE_CONNECTIVITY   =  {INITIATOR8_WRITE_TARGET31, INITIATOR8_WRITE_TARGET30, INITIATOR8_WRITE_TARGET29, INITIATOR8_WRITE_TARGET28, INITIATOR8_WRITE_TARGET27, INITIATOR8_WRITE_TARGET26, INITIATOR8_WRITE_TARGET25, INITIATOR8_WRITE_TARGET24,
                                                                 INITIATOR8_WRITE_TARGET23, INITIATOR8_WRITE_TARGET22, INITIATOR8_WRITE_TARGET21, INITIATOR8_WRITE_TARGET20, INITIATOR8_WRITE_TARGET19, INITIATOR8_WRITE_TARGET18, INITIATOR8_WRITE_TARGET17, INITIATOR8_WRITE_TARGET16,
                                                                 INITIATOR8_WRITE_TARGET15, INITIATOR8_WRITE_TARGET14, INITIATOR8_WRITE_TARGET13, INITIATOR8_WRITE_TARGET12, INITIATOR8_WRITE_TARGET11, INITIATOR8_WRITE_TARGET10, INITIATOR8_WRITE_TARGET9,  INITIATOR8_WRITE_TARGET8,
                                                                 INITIATOR8_WRITE_TARGET7,  INITIATOR8_WRITE_TARGET6,  INITIATOR8_WRITE_TARGET5,  INITIATOR8_WRITE_TARGET4,  INITIATOR8_WRITE_TARGET3,  INITIATOR8_WRITE_TARGET2,  INITIATOR8_WRITE_TARGET1,  INITIATOR8_WRITE_TARGET0
                                                                };
  localparam [NUM_TARGETS-1:0]   INITIATOR9_WRITE_CONNECTIVITY   =  {INITIATOR9_WRITE_TARGET31, INITIATOR9_WRITE_TARGET30, INITIATOR9_WRITE_TARGET29, INITIATOR9_WRITE_TARGET28, INITIATOR9_WRITE_TARGET27, INITIATOR9_WRITE_TARGET26, INITIATOR9_WRITE_TARGET25, INITIATOR9_WRITE_TARGET24,
                                                                 INITIATOR9_WRITE_TARGET23, INITIATOR9_WRITE_TARGET22, INITIATOR9_WRITE_TARGET21, INITIATOR9_WRITE_TARGET20, INITIATOR9_WRITE_TARGET19, INITIATOR9_WRITE_TARGET18, INITIATOR9_WRITE_TARGET17, INITIATOR9_WRITE_TARGET16,
                                                                 INITIATOR9_WRITE_TARGET15, INITIATOR9_WRITE_TARGET14, INITIATOR9_WRITE_TARGET13, INITIATOR9_WRITE_TARGET12, INITIATOR9_WRITE_TARGET11, INITIATOR9_WRITE_TARGET10, INITIATOR9_WRITE_TARGET9,  INITIATOR9_WRITE_TARGET8,
                                                                 INITIATOR9_WRITE_TARGET7,  INITIATOR9_WRITE_TARGET6,  INITIATOR9_WRITE_TARGET5,  INITIATOR9_WRITE_TARGET4,  INITIATOR9_WRITE_TARGET3,  INITIATOR9_WRITE_TARGET2,  INITIATOR9_WRITE_TARGET1,  INITIATOR9_WRITE_TARGET0
                                                                };
  localparam [NUM_TARGETS-1:0]   INITIATOR10_WRITE_CONNECTIVITY   =  {INITIATOR10_WRITE_TARGET31, INITIATOR10_WRITE_TARGET30, INITIATOR10_WRITE_TARGET29, INITIATOR10_WRITE_TARGET28, INITIATOR10_WRITE_TARGET27, INITIATOR10_WRITE_TARGET26, INITIATOR10_WRITE_TARGET25, INITIATOR10_WRITE_TARGET24,
                                                                 INITIATOR10_WRITE_TARGET23, INITIATOR10_WRITE_TARGET22, INITIATOR10_WRITE_TARGET21, INITIATOR10_WRITE_TARGET20, INITIATOR10_WRITE_TARGET19, INITIATOR10_WRITE_TARGET18, INITIATOR10_WRITE_TARGET17, INITIATOR10_WRITE_TARGET16,
                                                                 INITIATOR10_WRITE_TARGET15, INITIATOR10_WRITE_TARGET14, INITIATOR10_WRITE_TARGET13, INITIATOR10_WRITE_TARGET12, INITIATOR10_WRITE_TARGET11, INITIATOR10_WRITE_TARGET10, INITIATOR10_WRITE_TARGET9,  INITIATOR10_WRITE_TARGET8,
                                                                 INITIATOR10_WRITE_TARGET7,  INITIATOR10_WRITE_TARGET6,  INITIATOR10_WRITE_TARGET5,  INITIATOR10_WRITE_TARGET4,  INITIATOR10_WRITE_TARGET3,  INITIATOR10_WRITE_TARGET2,  INITIATOR10_WRITE_TARGET1,  INITIATOR10_WRITE_TARGET0
                                                                };
  localparam [NUM_TARGETS-1:0]   INITIATOR11_WRITE_CONNECTIVITY   =  {INITIATOR11_WRITE_TARGET31, INITIATOR11_WRITE_TARGET30, INITIATOR11_WRITE_TARGET29, INITIATOR11_WRITE_TARGET28, INITIATOR11_WRITE_TARGET27, INITIATOR11_WRITE_TARGET26, INITIATOR11_WRITE_TARGET25, INITIATOR11_WRITE_TARGET24,
                                                                 INITIATOR11_WRITE_TARGET23, INITIATOR11_WRITE_TARGET22, INITIATOR11_WRITE_TARGET21, INITIATOR11_WRITE_TARGET20, INITIATOR11_WRITE_TARGET19, INITIATOR11_WRITE_TARGET18, INITIATOR11_WRITE_TARGET17, INITIATOR11_WRITE_TARGET16,
                                                                 INITIATOR11_WRITE_TARGET15, INITIATOR11_WRITE_TARGET14, INITIATOR11_WRITE_TARGET13, INITIATOR11_WRITE_TARGET12, INITIATOR11_WRITE_TARGET11, INITIATOR11_WRITE_TARGET10, INITIATOR11_WRITE_TARGET9,  INITIATOR11_WRITE_TARGET8,
                                                                 INITIATOR11_WRITE_TARGET7,  INITIATOR11_WRITE_TARGET6,  INITIATOR11_WRITE_TARGET5,  INITIATOR11_WRITE_TARGET4,  INITIATOR11_WRITE_TARGET3,  INITIATOR11_WRITE_TARGET2,  INITIATOR11_WRITE_TARGET1,  INITIATOR11_WRITE_TARGET0
                                                                };
  localparam [NUM_TARGETS-1:0]   INITIATOR12_WRITE_CONNECTIVITY   =  {INITIATOR12_WRITE_TARGET31, INITIATOR12_WRITE_TARGET30, INITIATOR12_WRITE_TARGET29, INITIATOR12_WRITE_TARGET28, INITIATOR12_WRITE_TARGET27, INITIATOR12_WRITE_TARGET26, INITIATOR12_WRITE_TARGET25, INITIATOR12_WRITE_TARGET24,
                                                                 INITIATOR12_WRITE_TARGET23, INITIATOR12_WRITE_TARGET22, INITIATOR12_WRITE_TARGET21, INITIATOR12_WRITE_TARGET20, INITIATOR12_WRITE_TARGET19, INITIATOR12_WRITE_TARGET18, INITIATOR12_WRITE_TARGET17, INITIATOR12_WRITE_TARGET16,
                                                                 INITIATOR12_WRITE_TARGET15, INITIATOR12_WRITE_TARGET14, INITIATOR12_WRITE_TARGET13, INITIATOR12_WRITE_TARGET12, INITIATOR12_WRITE_TARGET11, INITIATOR12_WRITE_TARGET10, INITIATOR12_WRITE_TARGET9,  INITIATOR12_WRITE_TARGET8,
                                                                 INITIATOR12_WRITE_TARGET7,  INITIATOR12_WRITE_TARGET6,  INITIATOR12_WRITE_TARGET5,  INITIATOR12_WRITE_TARGET4,  INITIATOR12_WRITE_TARGET3,  INITIATOR12_WRITE_TARGET2,  INITIATOR12_WRITE_TARGET1,  INITIATOR12_WRITE_TARGET0
                                                                };
  localparam [NUM_TARGETS-1:0]   INITIATOR13_WRITE_CONNECTIVITY   =  {INITIATOR13_WRITE_TARGET31, INITIATOR13_WRITE_TARGET30, INITIATOR13_WRITE_TARGET29, INITIATOR13_WRITE_TARGET28, INITIATOR13_WRITE_TARGET27, INITIATOR13_WRITE_TARGET26, INITIATOR13_WRITE_TARGET25, INITIATOR13_WRITE_TARGET24,
                                                                 INITIATOR13_WRITE_TARGET23, INITIATOR13_WRITE_TARGET22, INITIATOR13_WRITE_TARGET21, INITIATOR13_WRITE_TARGET20, INITIATOR13_WRITE_TARGET19, INITIATOR13_WRITE_TARGET18, INITIATOR13_WRITE_TARGET17, INITIATOR13_WRITE_TARGET16,
                                                                 INITIATOR13_WRITE_TARGET15, INITIATOR13_WRITE_TARGET14, INITIATOR13_WRITE_TARGET13, INITIATOR13_WRITE_TARGET12, INITIATOR13_WRITE_TARGET11, INITIATOR13_WRITE_TARGET10, INITIATOR13_WRITE_TARGET9,  INITIATOR13_WRITE_TARGET8,
                                                                 INITIATOR13_WRITE_TARGET7,  INITIATOR13_WRITE_TARGET6,  INITIATOR13_WRITE_TARGET5,  INITIATOR13_WRITE_TARGET4,  INITIATOR13_WRITE_TARGET3,  INITIATOR13_WRITE_TARGET2,  INITIATOR13_WRITE_TARGET1,  INITIATOR13_WRITE_TARGET0
                                                                };
  localparam [NUM_TARGETS-1:0]   INITIATOR14_WRITE_CONNECTIVITY   =  {INITIATOR14_WRITE_TARGET31, INITIATOR14_WRITE_TARGET30, INITIATOR14_WRITE_TARGET29, INITIATOR14_WRITE_TARGET28, INITIATOR14_WRITE_TARGET27, INITIATOR14_WRITE_TARGET26, INITIATOR14_WRITE_TARGET25, INITIATOR14_WRITE_TARGET24,
                                                                 INITIATOR14_WRITE_TARGET23, INITIATOR14_WRITE_TARGET22, INITIATOR14_WRITE_TARGET21, INITIATOR14_WRITE_TARGET20, INITIATOR14_WRITE_TARGET19, INITIATOR14_WRITE_TARGET18, INITIATOR14_WRITE_TARGET17, INITIATOR14_WRITE_TARGET16,
                                                                 INITIATOR14_WRITE_TARGET15, INITIATOR14_WRITE_TARGET14, INITIATOR14_WRITE_TARGET13, INITIATOR14_WRITE_TARGET12, INITIATOR14_WRITE_TARGET11, INITIATOR14_WRITE_TARGET10, INITIATOR14_WRITE_TARGET9,  INITIATOR14_WRITE_TARGET8,
                                                                 INITIATOR14_WRITE_TARGET7,  INITIATOR14_WRITE_TARGET6,  INITIATOR14_WRITE_TARGET5,  INITIATOR14_WRITE_TARGET4,  INITIATOR14_WRITE_TARGET3,  INITIATOR14_WRITE_TARGET2,  INITIATOR14_WRITE_TARGET1,  INITIATOR14_WRITE_TARGET0
                                                                };
  localparam [NUM_TARGETS-1:0]   INITIATOR15_WRITE_CONNECTIVITY   =  {INITIATOR15_WRITE_TARGET31, INITIATOR15_WRITE_TARGET30, INITIATOR15_WRITE_TARGET29, INITIATOR15_WRITE_TARGET28, INITIATOR15_WRITE_TARGET27, INITIATOR15_WRITE_TARGET26, INITIATOR15_WRITE_TARGET25, INITIATOR15_WRITE_TARGET24,
                                                                 INITIATOR15_WRITE_TARGET23, INITIATOR15_WRITE_TARGET22, INITIATOR15_WRITE_TARGET21, INITIATOR15_WRITE_TARGET20, INITIATOR15_WRITE_TARGET19, INITIATOR15_WRITE_TARGET18, INITIATOR15_WRITE_TARGET17, INITIATOR15_WRITE_TARGET16,
                                                                 INITIATOR15_WRITE_TARGET15, INITIATOR15_WRITE_TARGET14, INITIATOR15_WRITE_TARGET13, INITIATOR15_WRITE_TARGET12, INITIATOR15_WRITE_TARGET11, INITIATOR15_WRITE_TARGET10, INITIATOR15_WRITE_TARGET9,  INITIATOR15_WRITE_TARGET8,
                                                                 INITIATOR15_WRITE_TARGET7,  INITIATOR15_WRITE_TARGET6,  INITIATOR15_WRITE_TARGET5,  INITIATOR15_WRITE_TARGET4,  INITIATOR15_WRITE_TARGET3,  INITIATOR15_WRITE_TARGET2,  INITIATOR15_WRITE_TARGET1,  INITIATOR15_WRITE_TARGET0
                                                                };

  localparam [NUM_TARGETS-1:0]   INITIATOR0_READ_CONNECTIVITY   = { INITIATOR0_READ_TARGET31, INITIATOR0_READ_TARGET30, INITIATOR0_READ_TARGET29, INITIATOR0_READ_TARGET28, INITIATOR0_READ_TARGET27, INITIATOR0_READ_TARGET26, INITIATOR0_READ_TARGET25, INITIATOR0_READ_TARGET24, 
                                                                INITIATOR0_READ_TARGET23, INITIATOR0_READ_TARGET22, INITIATOR0_READ_TARGET21, INITIATOR0_READ_TARGET20, INITIATOR0_READ_TARGET19, INITIATOR0_READ_TARGET18, INITIATOR0_READ_TARGET17, INITIATOR0_READ_TARGET16, 
                                                                INITIATOR0_READ_TARGET15, INITIATOR0_READ_TARGET14, INITIATOR0_READ_TARGET13, INITIATOR0_READ_TARGET12, INITIATOR0_READ_TARGET11, INITIATOR0_READ_TARGET10, INITIATOR0_READ_TARGET9,  INITIATOR0_READ_TARGET8,  
                                                                INITIATOR0_READ_TARGET7,  INITIATOR0_READ_TARGET6,  INITIATOR0_READ_TARGET5,  INITIATOR0_READ_TARGET4,  INITIATOR0_READ_TARGET3,  INITIATOR0_READ_TARGET2,  INITIATOR0_READ_TARGET1,  INITIATOR0_READ_TARGET0 } ;

  localparam [NUM_TARGETS-1:0]   INITIATOR1_READ_CONNECTIVITY   = { INITIATOR1_READ_TARGET31, INITIATOR1_READ_TARGET30, INITIATOR1_READ_TARGET29, INITIATOR1_READ_TARGET28, INITIATOR1_READ_TARGET27, INITIATOR1_READ_TARGET26, INITIATOR1_READ_TARGET25, INITIATOR1_READ_TARGET24, 
                                                                INITIATOR1_READ_TARGET23, INITIATOR1_READ_TARGET22, INITIATOR1_READ_TARGET21, INITIATOR1_READ_TARGET20, INITIATOR1_READ_TARGET19, INITIATOR1_READ_TARGET18, INITIATOR1_READ_TARGET17, INITIATOR1_READ_TARGET16, 
                                                                INITIATOR1_READ_TARGET15, INITIATOR1_READ_TARGET14, INITIATOR1_READ_TARGET13, INITIATOR1_READ_TARGET12, INITIATOR1_READ_TARGET11, INITIATOR1_READ_TARGET10, INITIATOR1_READ_TARGET9,  INITIATOR1_READ_TARGET8,  
                                                                INITIATOR1_READ_TARGET7,  INITIATOR1_READ_TARGET6,  INITIATOR1_READ_TARGET5,  INITIATOR1_READ_TARGET4,  INITIATOR1_READ_TARGET3,  INITIATOR1_READ_TARGET2,  INITIATOR1_READ_TARGET1,  INITIATOR1_READ_TARGET0 };
  
  localparam [NUM_TARGETS-1:0]   INITIATOR2_READ_CONNECTIVITY   = { INITIATOR2_READ_TARGET31, INITIATOR2_READ_TARGET30, INITIATOR2_READ_TARGET29, INITIATOR2_READ_TARGET28, INITIATOR2_READ_TARGET27, INITIATOR2_READ_TARGET26, INITIATOR2_READ_TARGET25, INITIATOR2_READ_TARGET24, 
                                                                INITIATOR2_READ_TARGET23, INITIATOR2_READ_TARGET22, INITIATOR2_READ_TARGET21, INITIATOR2_READ_TARGET20, INITIATOR2_READ_TARGET19, INITIATOR2_READ_TARGET18, INITIATOR2_READ_TARGET17, INITIATOR2_READ_TARGET16, 
                                                                INITIATOR2_READ_TARGET15, INITIATOR2_READ_TARGET14, INITIATOR2_READ_TARGET13, INITIATOR2_READ_TARGET12, INITIATOR2_READ_TARGET11, INITIATOR2_READ_TARGET10, INITIATOR2_READ_TARGET9,  INITIATOR2_READ_TARGET8,  
                                                                INITIATOR2_READ_TARGET7,  INITIATOR2_READ_TARGET6,  INITIATOR2_READ_TARGET5,  INITIATOR2_READ_TARGET4,  INITIATOR2_READ_TARGET3,  INITIATOR2_READ_TARGET2,  INITIATOR2_READ_TARGET1,  INITIATOR2_READ_TARGET0 };

  localparam [NUM_TARGETS-1:0]   INITIATOR3_READ_CONNECTIVITY   = { INITIATOR3_READ_TARGET31, INITIATOR3_READ_TARGET30, INITIATOR3_READ_TARGET29, INITIATOR3_READ_TARGET28, INITIATOR3_READ_TARGET27, INITIATOR3_READ_TARGET26, INITIATOR3_READ_TARGET25, INITIATOR3_READ_TARGET24, 
                                                                INITIATOR3_READ_TARGET23, INITIATOR3_READ_TARGET22, INITIATOR3_READ_TARGET21, INITIATOR3_READ_TARGET20, INITIATOR3_READ_TARGET19, INITIATOR3_READ_TARGET18, INITIATOR3_READ_TARGET17, INITIATOR3_READ_TARGET16, 
                                                                INITIATOR3_READ_TARGET15, INITIATOR3_READ_TARGET14, INITIATOR3_READ_TARGET13, INITIATOR3_READ_TARGET12, INITIATOR3_READ_TARGET11, INITIATOR3_READ_TARGET10, INITIATOR3_READ_TARGET9,  INITIATOR3_READ_TARGET8,  
                                                                INITIATOR3_READ_TARGET7,  INITIATOR3_READ_TARGET6,  INITIATOR3_READ_TARGET5,  INITIATOR3_READ_TARGET4,  INITIATOR3_READ_TARGET3,  INITIATOR3_READ_TARGET2,  INITIATOR3_READ_TARGET1,  INITIATOR3_READ_TARGET0 };

  localparam [NUM_TARGETS-1:0]   INITIATOR4_READ_CONNECTIVITY   = { INITIATOR4_READ_TARGET31, INITIATOR4_READ_TARGET30, INITIATOR4_READ_TARGET29, INITIATOR4_READ_TARGET28, INITIATOR4_READ_TARGET27, INITIATOR4_READ_TARGET26, INITIATOR4_READ_TARGET25, INITIATOR4_READ_TARGET24, 
                                                                INITIATOR4_READ_TARGET23, INITIATOR4_READ_TARGET22, INITIATOR4_READ_TARGET21, INITIATOR4_READ_TARGET20, INITIATOR4_READ_TARGET19, INITIATOR4_READ_TARGET18, INITIATOR4_READ_TARGET17, INITIATOR4_READ_TARGET16, 
                                                                INITIATOR4_READ_TARGET15, INITIATOR4_READ_TARGET14, INITIATOR4_READ_TARGET13, INITIATOR4_READ_TARGET12, INITIATOR4_READ_TARGET11, INITIATOR4_READ_TARGET10, INITIATOR4_READ_TARGET9,  INITIATOR4_READ_TARGET8,  
                                                                INITIATOR4_READ_TARGET7,  INITIATOR4_READ_TARGET6,  INITIATOR4_READ_TARGET5,  INITIATOR4_READ_TARGET4,  INITIATOR4_READ_TARGET3,  INITIATOR4_READ_TARGET2,  INITIATOR4_READ_TARGET1,  INITIATOR4_READ_TARGET0 };

  localparam [NUM_TARGETS-1:0]   INITIATOR5_READ_CONNECTIVITY   = { INITIATOR5_READ_TARGET31, INITIATOR5_READ_TARGET30, INITIATOR5_READ_TARGET29, INITIATOR5_READ_TARGET28, INITIATOR5_READ_TARGET27, INITIATOR5_READ_TARGET26, INITIATOR5_READ_TARGET25, INITIATOR5_READ_TARGET24, 
                                                                INITIATOR5_READ_TARGET23, INITIATOR5_READ_TARGET22, INITIATOR5_READ_TARGET21, INITIATOR5_READ_TARGET20, INITIATOR5_READ_TARGET19, INITIATOR5_READ_TARGET18, INITIATOR5_READ_TARGET17, INITIATOR5_READ_TARGET16, 
                                                                INITIATOR5_READ_TARGET15, INITIATOR5_READ_TARGET14, INITIATOR5_READ_TARGET13, INITIATOR5_READ_TARGET12, INITIATOR5_READ_TARGET11, INITIATOR5_READ_TARGET10, INITIATOR5_READ_TARGET9,  INITIATOR5_READ_TARGET8,  
                                                                INITIATOR5_READ_TARGET7,  INITIATOR5_READ_TARGET6,  INITIATOR5_READ_TARGET5,  INITIATOR5_READ_TARGET4,  INITIATOR5_READ_TARGET3,  INITIATOR5_READ_TARGET2,  INITIATOR5_READ_TARGET1,  INITIATOR5_READ_TARGET0 };
                            
  localparam [NUM_TARGETS-1:0]   INITIATOR6_READ_CONNECTIVITY   = { INITIATOR6_READ_TARGET31, INITIATOR6_READ_TARGET30, INITIATOR6_READ_TARGET29, INITIATOR6_READ_TARGET28, INITIATOR6_READ_TARGET27, INITIATOR6_READ_TARGET26, INITIATOR6_READ_TARGET25, INITIATOR6_READ_TARGET24, 
                                                                INITIATOR6_READ_TARGET23, INITIATOR6_READ_TARGET22, INITIATOR6_READ_TARGET21, INITIATOR6_READ_TARGET20, INITIATOR6_READ_TARGET19, INITIATOR6_READ_TARGET18, INITIATOR6_READ_TARGET17, INITIATOR6_READ_TARGET16, 
                                                                INITIATOR6_READ_TARGET15, INITIATOR6_READ_TARGET14, INITIATOR6_READ_TARGET13, INITIATOR6_READ_TARGET12, INITIATOR6_READ_TARGET11, INITIATOR6_READ_TARGET10, INITIATOR6_READ_TARGET9,  INITIATOR6_READ_TARGET8,  
                                                                INITIATOR6_READ_TARGET7,  INITIATOR6_READ_TARGET6,  INITIATOR6_READ_TARGET5,  INITIATOR6_READ_TARGET4,  INITIATOR6_READ_TARGET3,  INITIATOR6_READ_TARGET2,  INITIATOR6_READ_TARGET1,  INITIATOR6_READ_TARGET0 };

  localparam [NUM_TARGETS-1:0]   INITIATOR7_READ_CONNECTIVITY   = { INITIATOR7_READ_TARGET31, INITIATOR7_READ_TARGET30, INITIATOR7_READ_TARGET29, INITIATOR7_READ_TARGET28, INITIATOR7_READ_TARGET27, INITIATOR7_READ_TARGET26, INITIATOR7_READ_TARGET25, INITIATOR7_READ_TARGET24, 
                                                                INITIATOR7_READ_TARGET23, INITIATOR7_READ_TARGET22, INITIATOR7_READ_TARGET21, INITIATOR7_READ_TARGET20, INITIATOR7_READ_TARGET19, INITIATOR7_READ_TARGET18, INITIATOR7_READ_TARGET17, INITIATOR7_READ_TARGET16, 
                                                                INITIATOR7_READ_TARGET15, INITIATOR7_READ_TARGET14, INITIATOR7_READ_TARGET13, INITIATOR7_READ_TARGET12, INITIATOR7_READ_TARGET11, INITIATOR7_READ_TARGET10, INITIATOR7_READ_TARGET9,  INITIATOR7_READ_TARGET8,  
                                                                INITIATOR7_READ_TARGET7,  INITIATOR7_READ_TARGET6,  INITIATOR7_READ_TARGET5,  INITIATOR7_READ_TARGET4,  INITIATOR7_READ_TARGET3,  INITIATOR7_READ_TARGET2,  INITIATOR7_READ_TARGET1,  INITIATOR7_READ_TARGET0 };
																
  localparam [NUM_TARGETS-1:0]   INITIATOR8_READ_CONNECTIVITY   = { INITIATOR8_READ_TARGET31, INITIATOR8_READ_TARGET30, INITIATOR8_READ_TARGET29, INITIATOR8_READ_TARGET28, INITIATOR8_READ_TARGET27, INITIATOR8_READ_TARGET26, INITIATOR8_READ_TARGET25, INITIATOR8_READ_TARGET24, 
                                                                INITIATOR8_READ_TARGET23, INITIATOR8_READ_TARGET22, INITIATOR8_READ_TARGET21, INITIATOR8_READ_TARGET20, INITIATOR8_READ_TARGET19, INITIATOR8_READ_TARGET18, INITIATOR8_READ_TARGET17, INITIATOR8_READ_TARGET16, 
                                                                INITIATOR8_READ_TARGET15, INITIATOR8_READ_TARGET14, INITIATOR8_READ_TARGET13, INITIATOR8_READ_TARGET12, INITIATOR8_READ_TARGET11, INITIATOR8_READ_TARGET10, INITIATOR8_READ_TARGET9,  INITIATOR8_READ_TARGET8,  
                                                                INITIATOR8_READ_TARGET7,  INITIATOR8_READ_TARGET6,  INITIATOR8_READ_TARGET5,  INITIATOR8_READ_TARGET4,  INITIATOR8_READ_TARGET3,  INITIATOR8_READ_TARGET2,  INITIATOR8_READ_TARGET1,  INITIATOR8_READ_TARGET0 };
																
  localparam [NUM_TARGETS-1:0]   INITIATOR9_READ_CONNECTIVITY   = { INITIATOR9_READ_TARGET31, INITIATOR9_READ_TARGET30, INITIATOR9_READ_TARGET29, INITIATOR9_READ_TARGET28, INITIATOR9_READ_TARGET27, INITIATOR9_READ_TARGET26, INITIATOR9_READ_TARGET25, INITIATOR9_READ_TARGET24, 
                                                                INITIATOR9_READ_TARGET23, INITIATOR9_READ_TARGET22, INITIATOR9_READ_TARGET21, INITIATOR9_READ_TARGET20, INITIATOR9_READ_TARGET19, INITIATOR9_READ_TARGET18, INITIATOR9_READ_TARGET17, INITIATOR9_READ_TARGET16, 
                                                                INITIATOR9_READ_TARGET15, INITIATOR9_READ_TARGET14, INITIATOR9_READ_TARGET13, INITIATOR9_READ_TARGET12, INITIATOR9_READ_TARGET11, INITIATOR9_READ_TARGET10, INITIATOR9_READ_TARGET9,  INITIATOR9_READ_TARGET8,  
                                                                INITIATOR9_READ_TARGET7,  INITIATOR9_READ_TARGET6,  INITIATOR9_READ_TARGET5,  INITIATOR9_READ_TARGET4,  INITIATOR9_READ_TARGET3,  INITIATOR9_READ_TARGET2,  INITIATOR9_READ_TARGET1,  INITIATOR9_READ_TARGET0 };
																
  localparam [NUM_TARGETS-1:0]   INITIATOR10_READ_CONNECTIVITY   = { INITIATOR10_READ_TARGET31, INITIATOR10_READ_TARGET30, INITIATOR10_READ_TARGET29, INITIATOR10_READ_TARGET28, INITIATOR10_READ_TARGET27, INITIATOR10_READ_TARGET26, INITIATOR10_READ_TARGET25, INITIATOR10_READ_TARGET24, 
                                                                 INITIATOR10_READ_TARGET23, INITIATOR10_READ_TARGET22, INITIATOR10_READ_TARGET21, INITIATOR10_READ_TARGET20, INITIATOR10_READ_TARGET19, INITIATOR10_READ_TARGET18, INITIATOR10_READ_TARGET17, INITIATOR10_READ_TARGET16, 
                                                                 INITIATOR10_READ_TARGET15, INITIATOR10_READ_TARGET14, INITIATOR10_READ_TARGET13, INITIATOR10_READ_TARGET12, INITIATOR10_READ_TARGET11, INITIATOR10_READ_TARGET10, INITIATOR10_READ_TARGET9,  INITIATOR10_READ_TARGET8,  
                                                                 INITIATOR10_READ_TARGET7,  INITIATOR10_READ_TARGET6,  INITIATOR10_READ_TARGET5,  INITIATOR10_READ_TARGET4,  INITIATOR10_READ_TARGET3,  INITIATOR10_READ_TARGET2,  INITIATOR10_READ_TARGET1,  INITIATOR10_READ_TARGET0 };
																
  localparam [NUM_TARGETS-1:0]   INITIATOR11_READ_CONNECTIVITY   = { INITIATOR11_READ_TARGET31, INITIATOR11_READ_TARGET30, INITIATOR11_READ_TARGET29, INITIATOR11_READ_TARGET28, INITIATOR11_READ_TARGET27, INITIATOR11_READ_TARGET26, INITIATOR11_READ_TARGET25, INITIATOR11_READ_TARGET24, 
                                                                 INITIATOR11_READ_TARGET23, INITIATOR11_READ_TARGET22, INITIATOR11_READ_TARGET21, INITIATOR11_READ_TARGET20, INITIATOR11_READ_TARGET19, INITIATOR11_READ_TARGET18, INITIATOR11_READ_TARGET17, INITIATOR11_READ_TARGET16, 
                                                                 INITIATOR11_READ_TARGET15, INITIATOR11_READ_TARGET14, INITIATOR11_READ_TARGET13, INITIATOR11_READ_TARGET12, INITIATOR11_READ_TARGET11, INITIATOR11_READ_TARGET10, INITIATOR11_READ_TARGET9,  INITIATOR11_READ_TARGET8,  
                                                                 INITIATOR11_READ_TARGET7,  INITIATOR11_READ_TARGET6,  INITIATOR11_READ_TARGET5,  INITIATOR11_READ_TARGET4,  INITIATOR11_READ_TARGET3,  INITIATOR11_READ_TARGET2,  INITIATOR11_READ_TARGET1,  INITIATOR11_READ_TARGET0 };
																
  localparam [NUM_TARGETS-1:0]   INITIATOR12_READ_CONNECTIVITY   = { INITIATOR12_READ_TARGET31, INITIATOR12_READ_TARGET30, INITIATOR12_READ_TARGET29, INITIATOR12_READ_TARGET28, INITIATOR12_READ_TARGET27, INITIATOR12_READ_TARGET26, INITIATOR12_READ_TARGET25, INITIATOR12_READ_TARGET24, 
                                                                 INITIATOR12_READ_TARGET23, INITIATOR12_READ_TARGET22, INITIATOR12_READ_TARGET21, INITIATOR12_READ_TARGET20, INITIATOR12_READ_TARGET19, INITIATOR12_READ_TARGET18, INITIATOR12_READ_TARGET17, INITIATOR12_READ_TARGET16, 
                                                                 INITIATOR12_READ_TARGET15, INITIATOR12_READ_TARGET14, INITIATOR12_READ_TARGET13, INITIATOR12_READ_TARGET12, INITIATOR12_READ_TARGET11, INITIATOR12_READ_TARGET10, INITIATOR12_READ_TARGET9,  INITIATOR12_READ_TARGET8,  
                                                                 INITIATOR12_READ_TARGET7,  INITIATOR12_READ_TARGET6,  INITIATOR12_READ_TARGET5,  INITIATOR12_READ_TARGET4,  INITIATOR12_READ_TARGET3,  INITIATOR12_READ_TARGET2,  INITIATOR12_READ_TARGET1,  INITIATOR12_READ_TARGET0 };
																 
  localparam [NUM_TARGETS-1:0]   INITIATOR13_READ_CONNECTIVITY   = { INITIATOR13_READ_TARGET31, INITIATOR13_READ_TARGET30, INITIATOR13_READ_TARGET29, INITIATOR13_READ_TARGET28, INITIATOR13_READ_TARGET27, INITIATOR13_READ_TARGET26, INITIATOR13_READ_TARGET25, INITIATOR13_READ_TARGET24, 
                                                                 INITIATOR13_READ_TARGET23, INITIATOR13_READ_TARGET22, INITIATOR13_READ_TARGET21, INITIATOR13_READ_TARGET20, INITIATOR13_READ_TARGET19, INITIATOR13_READ_TARGET18, INITIATOR13_READ_TARGET17, INITIATOR13_READ_TARGET16, 
                                                                 INITIATOR13_READ_TARGET15, INITIATOR13_READ_TARGET14, INITIATOR13_READ_TARGET13, INITIATOR13_READ_TARGET12, INITIATOR13_READ_TARGET11, INITIATOR13_READ_TARGET10, INITIATOR13_READ_TARGET9,  INITIATOR13_READ_TARGET8,  
                                                                 INITIATOR13_READ_TARGET7,  INITIATOR13_READ_TARGET6,  INITIATOR13_READ_TARGET5,  INITIATOR13_READ_TARGET4,  INITIATOR13_READ_TARGET3,  INITIATOR13_READ_TARGET2,  INITIATOR13_READ_TARGET1,  INITIATOR13_READ_TARGET0 };

  localparam [NUM_TARGETS-1:0]   INITIATOR14_READ_CONNECTIVITY   = { INITIATOR14_READ_TARGET31, INITIATOR14_READ_TARGET30, INITIATOR14_READ_TARGET29, INITIATOR14_READ_TARGET28, INITIATOR14_READ_TARGET27, INITIATOR14_READ_TARGET26, INITIATOR14_READ_TARGET25, INITIATOR14_READ_TARGET24, 
                                                                 INITIATOR14_READ_TARGET23, INITIATOR14_READ_TARGET22, INITIATOR14_READ_TARGET21, INITIATOR14_READ_TARGET20, INITIATOR14_READ_TARGET19, INITIATOR14_READ_TARGET18, INITIATOR14_READ_TARGET17, INITIATOR14_READ_TARGET16, 
                                                                 INITIATOR14_READ_TARGET15, INITIATOR14_READ_TARGET14, INITIATOR14_READ_TARGET13, INITIATOR14_READ_TARGET12, INITIATOR14_READ_TARGET11, INITIATOR14_READ_TARGET10, INITIATOR14_READ_TARGET9,  INITIATOR14_READ_TARGET8,  
                                                                 INITIATOR14_READ_TARGET7,  INITIATOR14_READ_TARGET6,  INITIATOR14_READ_TARGET5,  INITIATOR14_READ_TARGET4,  INITIATOR14_READ_TARGET3,  INITIATOR14_READ_TARGET2,  INITIATOR14_READ_TARGET1,  INITIATOR14_READ_TARGET0 };

  localparam [NUM_TARGETS-1:0]   INITIATOR15_READ_CONNECTIVITY   = { INITIATOR15_READ_TARGET31, INITIATOR15_READ_TARGET30, INITIATOR15_READ_TARGET29, INITIATOR15_READ_TARGET28, INITIATOR15_READ_TARGET27, INITIATOR15_READ_TARGET26, INITIATOR15_READ_TARGET25, INITIATOR15_READ_TARGET24, 
                                                                 INITIATOR15_READ_TARGET23, INITIATOR15_READ_TARGET22, INITIATOR15_READ_TARGET21, INITIATOR15_READ_TARGET20, INITIATOR15_READ_TARGET19, INITIATOR15_READ_TARGET18, INITIATOR15_READ_TARGET17, INITIATOR15_READ_TARGET16, 
                                                                 INITIATOR15_READ_TARGET15, INITIATOR15_READ_TARGET14, INITIATOR15_READ_TARGET13, INITIATOR15_READ_TARGET12, INITIATOR15_READ_TARGET11, INITIATOR15_READ_TARGET10, INITIATOR15_READ_TARGET9,  INITIATOR15_READ_TARGET8,  
                                                                 INITIATOR15_READ_TARGET7,  INITIATOR15_READ_TARGET6,  INITIATOR15_READ_TARGET5,  INITIATOR15_READ_TARGET4,  INITIATOR15_READ_TARGET3,  INITIATOR15_READ_TARGET2,  INITIATOR15_READ_TARGET1,  INITIATOR15_READ_TARGET0 };
  
  localparam [NUM_INITIATORS*NUM_TARGETS-1:0] INITIATOR_WRITE_CONNECTIVITY = { INITIATOR15_WRITE_CONNECTIVITY, 
																		INITIATOR14_WRITE_CONNECTIVITY,
																		INITIATOR13_WRITE_CONNECTIVITY,
																		INITIATOR12_WRITE_CONNECTIVITY, 
                                                                        INITIATOR11_WRITE_CONNECTIVITY, 
																		INITIATOR10_WRITE_CONNECTIVITY, 
																		INITIATOR9_WRITE_CONNECTIVITY, 
																		INITIATOR8_WRITE_CONNECTIVITY,
                                                                        INITIATOR7_WRITE_CONNECTIVITY, 
																		INITIATOR6_WRITE_CONNECTIVITY,
																		INITIATOR5_WRITE_CONNECTIVITY,
																		INITIATOR4_WRITE_CONNECTIVITY, 
                                                                        INITIATOR3_WRITE_CONNECTIVITY, 
																		INITIATOR2_WRITE_CONNECTIVITY, 
																		INITIATOR1_WRITE_CONNECTIVITY, 
																		INITIATOR0_WRITE_CONNECTIVITY };  // bit per port indicating if a initiator can write to a target port

  localparam [NUM_INITIATORS*NUM_TARGETS-1:0] INITIATOR_READ_CONNECTIVITY  = { INITIATOR15_READ_CONNECTIVITY, 
																		INITIATOR14_READ_CONNECTIVITY,
																		INITIATOR13_READ_CONNECTIVITY, 
																		INITIATOR12_READ_CONNECTIVITY, 
                                                                        INITIATOR11_READ_CONNECTIVITY, 
																		INITIATOR10_READ_CONNECTIVITY,
																		INITIATOR9_READ_CONNECTIVITY,
																		INITIATOR8_READ_CONNECTIVITY,
                                                                        INITIATOR7_READ_CONNECTIVITY, 
																		INITIATOR6_READ_CONNECTIVITY,
																		INITIATOR5_READ_CONNECTIVITY, 
																		INITIATOR4_READ_CONNECTIVITY, 
                                                                        INITIATOR3_READ_CONNECTIVITY, 
																		INITIATOR2_READ_CONNECTIVITY,
																		INITIATOR1_READ_CONNECTIVITY,
																		INITIATOR0_READ_CONNECTIVITY };  // bit per port indicating if a initiator can write to a target port

  localparam [NUM_INITIATORS*8-1:0] INITIATOR_DEF_BURST_LEN = {    
                                                                INITIATOR15_DEF_BURST_LEN,
                                                                INITIATOR14_DEF_BURST_LEN,
                                                                INITIATOR13_DEF_BURST_LEN,
                                                                INITIATOR12_DEF_BURST_LEN,
                                                                INITIATOR11_DEF_BURST_LEN,
                                                                INITIATOR10_DEF_BURST_LEN,
                                                                INITIATOR9_DEF_BURST_LEN,
                                                                INITIATOR8_DEF_BURST_LEN,
															    INITIATOR7_DEF_BURST_LEN,
                                                                INITIATOR6_DEF_BURST_LEN,
                                                                INITIATOR5_DEF_BURST_LEN,
                                                                INITIATOR4_DEF_BURST_LEN,
                                                                INITIATOR3_DEF_BURST_LEN,
                                                                INITIATOR2_DEF_BURST_LEN,
                                                                INITIATOR1_DEF_BURST_LEN,
                                                                INITIATOR0_DEF_BURST_LEN
                                                              };


  localparam [NUM_TARGETS*14-1:0] TARGET_DWC_DATA_FIFO_DEPTH = {  TARGET31_DWC_DATA_FIFO_DEPTH, TARGET30_DWC_DATA_FIFO_DEPTH, TARGET29_DWC_DATA_FIFO_DEPTH, TARGET28_DWC_DATA_FIFO_DEPTH, 
                                                                TARGET27_DWC_DATA_FIFO_DEPTH, TARGET26_DWC_DATA_FIFO_DEPTH, TARGET25_DWC_DATA_FIFO_DEPTH, TARGET24_DWC_DATA_FIFO_DEPTH, 
                                                                TARGET23_DWC_DATA_FIFO_DEPTH, TARGET22_DWC_DATA_FIFO_DEPTH, TARGET21_DWC_DATA_FIFO_DEPTH, TARGET20_DWC_DATA_FIFO_DEPTH, 
                                                                TARGET19_DWC_DATA_FIFO_DEPTH, TARGET18_DWC_DATA_FIFO_DEPTH, TARGET17_DWC_DATA_FIFO_DEPTH, TARGET16_DWC_DATA_FIFO_DEPTH, 
                                                                TARGET15_DWC_DATA_FIFO_DEPTH, TARGET14_DWC_DATA_FIFO_DEPTH, TARGET13_DWC_DATA_FIFO_DEPTH, TARGET12_DWC_DATA_FIFO_DEPTH, 
                                                                TARGET11_DWC_DATA_FIFO_DEPTH, TARGET10_DWC_DATA_FIFO_DEPTH, TARGET9_DWC_DATA_FIFO_DEPTH, TARGET8_DWC_DATA_FIFO_DEPTH, 
                                                                TARGET7_DWC_DATA_FIFO_DEPTH, TARGET6_DWC_DATA_FIFO_DEPTH, TARGET5_DWC_DATA_FIFO_DEPTH, TARGET4_DWC_DATA_FIFO_DEPTH, 
                                                                TARGET3_DWC_DATA_FIFO_DEPTH, TARGET2_DWC_DATA_FIFO_DEPTH, TARGET1_DWC_DATA_FIFO_DEPTH, TARGET0_DWC_DATA_FIFO_DEPTH
                                                               };

  localparam [NUM_INITIATORS*14-1:0] INITIATOR_DWC_DATA_FIFO_DEPTH = {  INITIATOR15_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR14_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR13_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR12_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR11_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR10_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR9_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR8_DWC_DATA_FIFO_DEPTH,
																  INITIATOR7_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR6_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR5_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR4_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR3_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR2_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR1_DWC_DATA_FIFO_DEPTH,
                                                                  INITIATOR0_DWC_DATA_FIFO_DEPTH
                                                                  };

  localparam [NUM_TARGETS-1:0] T_CDC = { TARGET31_CLOCK_DOMAIN_CROSSING,
                                         TARGET30_CLOCK_DOMAIN_CROSSING, 
										 TARGET29_CLOCK_DOMAIN_CROSSING, 
										 TARGET28_CLOCK_DOMAIN_CROSSING, 
                                         TARGET27_CLOCK_DOMAIN_CROSSING,
                                         TARGET26_CLOCK_DOMAIN_CROSSING,
                                         TARGET25_CLOCK_DOMAIN_CROSSING,
                                         TARGET24_CLOCK_DOMAIN_CROSSING,
                                         TARGET23_CLOCK_DOMAIN_CROSSING,
                                         TARGET22_CLOCK_DOMAIN_CROSSING,
                                         TARGET21_CLOCK_DOMAIN_CROSSING,
                                         TARGET20_CLOCK_DOMAIN_CROSSING,
                                         TARGET19_CLOCK_DOMAIN_CROSSING,
                                         TARGET18_CLOCK_DOMAIN_CROSSING,
                                         TARGET17_CLOCK_DOMAIN_CROSSING,
                                         TARGET16_CLOCK_DOMAIN_CROSSING,
                                         TARGET15_CLOCK_DOMAIN_CROSSING,
                                         TARGET14_CLOCK_DOMAIN_CROSSING,
                                         TARGET13_CLOCK_DOMAIN_CROSSING,
                                         TARGET12_CLOCK_DOMAIN_CROSSING,
                                         TARGET11_CLOCK_DOMAIN_CROSSING,
                                         TARGET10_CLOCK_DOMAIN_CROSSING,
                                         TARGET9_CLOCK_DOMAIN_CROSSING,
                                         TARGET8_CLOCK_DOMAIN_CROSSING,
                                         TARGET7_CLOCK_DOMAIN_CROSSING,
                                         TARGET6_CLOCK_DOMAIN_CROSSING,
                                         TARGET5_CLOCK_DOMAIN_CROSSING,
                                         TARGET4_CLOCK_DOMAIN_CROSSING,
                                         TARGET3_CLOCK_DOMAIN_CROSSING,
                                         TARGET2_CLOCK_DOMAIN_CROSSING,
                                         TARGET1_CLOCK_DOMAIN_CROSSING,
                                         TARGET0_CLOCK_DOMAIN_CROSSING
                                      };

  localparam [NUM_TARGETS-1:0] T_CDC_PLACEMENT = { 
                                                   TARGET31_CDC_PLACEMENT,
                                                   TARGET30_CDC_PLACEMENT, 
										           TARGET29_CDC_PLACEMENT, 
										           TARGET28_CDC_PLACEMENT, 
                                                   TARGET27_CDC_PLACEMENT,
                                                   TARGET26_CDC_PLACEMENT,
                                                   TARGET25_CDC_PLACEMENT,
                                                   TARGET24_CDC_PLACEMENT,
                                                   TARGET23_CDC_PLACEMENT,
                                                   TARGET22_CDC_PLACEMENT,
                                                   TARGET21_CDC_PLACEMENT,
                                                   TARGET20_CDC_PLACEMENT,
                                                   TARGET19_CDC_PLACEMENT,
                                                   TARGET18_CDC_PLACEMENT,
                                                   TARGET17_CDC_PLACEMENT,
                                                   TARGET16_CDC_PLACEMENT,
                                                   TARGET15_CDC_PLACEMENT,
                                                   TARGET14_CDC_PLACEMENT,
                                                   TARGET13_CDC_PLACEMENT,
                                                   TARGET12_CDC_PLACEMENT,
                                                   TARGET11_CDC_PLACEMENT,
                                                   TARGET10_CDC_PLACEMENT,
                                                   TARGET9_CDC_PLACEMENT,
                                                   TARGET8_CDC_PLACEMENT,
                                                   TARGET7_CDC_PLACEMENT,
                                                   TARGET6_CDC_PLACEMENT,
                                                   TARGET5_CDC_PLACEMENT,
                                                   TARGET4_CDC_PLACEMENT,
                                                   TARGET3_CDC_PLACEMENT,
                                                   TARGET2_CDC_PLACEMENT,
                                                   TARGET1_CDC_PLACEMENT,
                                                   TARGET0_CDC_PLACEMENT
                                                 };
									  
  localparam [(32*32)-1:0] T_CDC_FIFO_DEPTH = { TARGET31_CDC_FIFO_DEPTH,
                                         TARGET30_CDC_FIFO_DEPTH, 
										 TARGET29_CDC_FIFO_DEPTH, 
										 TARGET28_CDC_FIFO_DEPTH, 
                                         TARGET27_CDC_FIFO_DEPTH,
                                         TARGET26_CDC_FIFO_DEPTH,
                                         TARGET25_CDC_FIFO_DEPTH,
                                         TARGET24_CDC_FIFO_DEPTH,
                                         TARGET23_CDC_FIFO_DEPTH,
                                         TARGET22_CDC_FIFO_DEPTH,
                                         TARGET21_CDC_FIFO_DEPTH,
                                         TARGET20_CDC_FIFO_DEPTH,
                                         TARGET19_CDC_FIFO_DEPTH,
                                         TARGET18_CDC_FIFO_DEPTH,
                                         TARGET17_CDC_FIFO_DEPTH,
                                         TARGET16_CDC_FIFO_DEPTH,
                                         TARGET15_CDC_FIFO_DEPTH,
                                         TARGET14_CDC_FIFO_DEPTH,
                                         TARGET13_CDC_FIFO_DEPTH,
                                         TARGET12_CDC_FIFO_DEPTH,
                                         TARGET11_CDC_FIFO_DEPTH,
                                         TARGET10_CDC_FIFO_DEPTH,
                                         TARGET9_CDC_FIFO_DEPTH,
                                         TARGET8_CDC_FIFO_DEPTH,
                                         TARGET7_CDC_FIFO_DEPTH,
                                         TARGET6_CDC_FIFO_DEPTH,
                                         TARGET5_CDC_FIFO_DEPTH,
                                         TARGET4_CDC_FIFO_DEPTH,
                                         TARGET3_CDC_FIFO_DEPTH,
                                         TARGET2_CDC_FIFO_DEPTH,
                                         TARGET1_CDC_FIFO_DEPTH,
                                         TARGET0_CDC_FIFO_DEPTH
                                      };

  localparam [(32*32)-1:0] T_CDC_ADDR_RESP_FIFO_DEPTH = { TARGET31_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET30_CDC_ADDR_RESP_FIFO_DEPTH, 
										 TARGET29_CDC_ADDR_RESP_FIFO_DEPTH, 
										 TARGET28_CDC_ADDR_RESP_FIFO_DEPTH, 
                                         TARGET27_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET26_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET25_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET24_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET23_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET22_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET21_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET20_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET19_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET18_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET17_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET16_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET15_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET14_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET13_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET12_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET11_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET10_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET9_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET8_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET7_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET6_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET5_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET4_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET3_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET2_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET1_CDC_ADDR_RESP_FIFO_DEPTH,
                                         TARGET0_CDC_ADDR_RESP_FIFO_DEPTH
                                      };
									  
  localparam [NUM_INITIATORS-1:0] I_CDC = {INITIATOR15_CLOCK_DOMAIN_CROSSING, 
										INITIATOR14_CLOCK_DOMAIN_CROSSING, 
										INITIATOR13_CLOCK_DOMAIN_CROSSING,
										INITIATOR12_CLOCK_DOMAIN_CROSSING,
										INITIATOR11_CLOCK_DOMAIN_CROSSING,
										INITIATOR10_CLOCK_DOMAIN_CROSSING, 
										INITIATOR9_CLOCK_DOMAIN_CROSSING, 
										INITIATOR8_CLOCK_DOMAIN_CROSSING,
                                        INITIATOR7_CLOCK_DOMAIN_CROSSING, 
										INITIATOR6_CLOCK_DOMAIN_CROSSING, 
										INITIATOR5_CLOCK_DOMAIN_CROSSING,
										INITIATOR4_CLOCK_DOMAIN_CROSSING,
										INITIATOR3_CLOCK_DOMAIN_CROSSING,
										INITIATOR2_CLOCK_DOMAIN_CROSSING, 
										INITIATOR1_CLOCK_DOMAIN_CROSSING, 
										INITIATOR0_CLOCK_DOMAIN_CROSSING};

  localparam [NUM_INITIATORS-1:0] I_CDC_PLACEMENT = {
                                                       INITIATOR15_CDC_PLACEMENT, 
										               INITIATOR14_CDC_PLACEMENT, 
										               INITIATOR13_CDC_PLACEMENT,
										               INITIATOR12_CDC_PLACEMENT,
										               INITIATOR11_CDC_PLACEMENT,
										               INITIATOR10_CDC_PLACEMENT, 
										               INITIATOR9_CDC_PLACEMENT, 
										               INITIATOR8_CDC_PLACEMENT,
                                                       INITIATOR7_CDC_PLACEMENT, 
										               INITIATOR6_CDC_PLACEMENT, 
										               INITIATOR5_CDC_PLACEMENT,
										               INITIATOR4_CDC_PLACEMENT,
										               INITIATOR3_CDC_PLACEMENT,
										               INITIATOR2_CDC_PLACEMENT, 
										               INITIATOR1_CDC_PLACEMENT, 
										               INITIATOR0_CDC_PLACEMENT
													};



  localparam [(16*32)-1:0] I_CDC_FIFO_DEPTH = {INITIATOR15_CDC_FIFO_DEPTH, 
										INITIATOR14_CDC_FIFO_DEPTH, 
										INITIATOR13_CDC_FIFO_DEPTH,
										INITIATOR12_CDC_FIFO_DEPTH,
										INITIATOR11_CDC_FIFO_DEPTH,
										INITIATOR10_CDC_FIFO_DEPTH, 
										INITIATOR9_CDC_FIFO_DEPTH, 
										INITIATOR8_CDC_FIFO_DEPTH,
                                        INITIATOR7_CDC_FIFO_DEPTH, 
										INITIATOR6_CDC_FIFO_DEPTH, 
										INITIATOR5_CDC_FIFO_DEPTH,
										INITIATOR4_CDC_FIFO_DEPTH,
										INITIATOR3_CDC_FIFO_DEPTH,
										INITIATOR2_CDC_FIFO_DEPTH, 
										INITIATOR1_CDC_FIFO_DEPTH, 
										INITIATOR0_CDC_FIFO_DEPTH};
										
  localparam [(16*32)-1:0] I_CDC_ADDR_RESP_FIFO_DEPTH = {INITIATOR15_CDC_ADDR_RESP_FIFO_DEPTH, 
										INITIATOR14_CDC_ADDR_RESP_FIFO_DEPTH, 
										INITIATOR13_CDC_ADDR_RESP_FIFO_DEPTH,
										INITIATOR12_CDC_ADDR_RESP_FIFO_DEPTH,
										INITIATOR11_CDC_ADDR_RESP_FIFO_DEPTH,
										INITIATOR10_CDC_ADDR_RESP_FIFO_DEPTH, 
										INITIATOR9_CDC_ADDR_RESP_FIFO_DEPTH, 
										INITIATOR8_CDC_ADDR_RESP_FIFO_DEPTH,
                                        INITIATOR7_CDC_ADDR_RESP_FIFO_DEPTH, 
										INITIATOR6_CDC_ADDR_RESP_FIFO_DEPTH, 
										INITIATOR5_CDC_ADDR_RESP_FIFO_DEPTH,
										INITIATOR4_CDC_ADDR_RESP_FIFO_DEPTH,
										INITIATOR3_CDC_ADDR_RESP_FIFO_DEPTH,
										INITIATOR2_CDC_ADDR_RESP_FIFO_DEPTH, 
										INITIATOR1_CDC_ADDR_RESP_FIFO_DEPTH, 
										INITIATOR0_CDC_ADDR_RESP_FIFO_DEPTH};
										

  localparam [NUM_INITIATORS-1:0] INITIATOR_READ_INTERLEAVE = {INITIATOR15_READ_INTERLEAVE,
                                                         INITIATOR14_READ_INTERLEAVE,
                                                         INITIATOR13_READ_INTERLEAVE,
                                                         INITIATOR12_READ_INTERLEAVE,
                                                         INITIATOR11_READ_INTERLEAVE,
                                                         INITIATOR10_READ_INTERLEAVE,
                                                         INITIATOR9_READ_INTERLEAVE,
                                                         INITIATOR8_READ_INTERLEAVE,
                                                         INITIATOR7_READ_INTERLEAVE,
                                                         INITIATOR6_READ_INTERLEAVE,
                                                         INITIATOR5_READ_INTERLEAVE,
                                                         INITIATOR4_READ_INTERLEAVE,
                                                         INITIATOR3_READ_INTERLEAVE,
                                                         INITIATOR2_READ_INTERLEAVE,
                                                         INITIATOR1_READ_INTERLEAVE,
                                                         INITIATOR0_READ_INTERLEAVE
														};
  localparam [NUM_TARGETS-1:0] TARGET_READ_INTERLEAVE = {TARGET31_READ_INTERLEAVE,
                                                       TARGET30_READ_INTERLEAVE,
                                                       TARGET29_READ_INTERLEAVE,
                                                       TARGET28_READ_INTERLEAVE,
                                                       TARGET27_READ_INTERLEAVE,
                                                       TARGET26_READ_INTERLEAVE,
                                                       TARGET25_READ_INTERLEAVE,
                                                       TARGET24_READ_INTERLEAVE,
                                                       TARGET23_READ_INTERLEAVE,
                                                       TARGET22_READ_INTERLEAVE,
                                                       TARGET21_READ_INTERLEAVE,
                                                       TARGET20_READ_INTERLEAVE,
                                                       TARGET19_READ_INTERLEAVE,
                                                       TARGET18_READ_INTERLEAVE,
                                                       TARGET17_READ_INTERLEAVE,
                                                       TARGET16_READ_INTERLEAVE,
                                                       TARGET15_READ_INTERLEAVE,
                                                       TARGET14_READ_INTERLEAVE,
                                                       TARGET13_READ_INTERLEAVE,
                                                       TARGET12_READ_INTERLEAVE,
                                                       TARGET11_READ_INTERLEAVE,
                                                       TARGET10_READ_INTERLEAVE,
                                                       TARGET9_READ_INTERLEAVE,
                                                       TARGET8_READ_INTERLEAVE,
                                                       TARGET7_READ_INTERLEAVE,
                                                       TARGET6_READ_INTERLEAVE,
                                                       TARGET5_READ_INTERLEAVE,
                                                       TARGET4_READ_INTERLEAVE,
                                                       TARGET3_READ_INTERLEAVE,
                                                       TARGET2_READ_INTERLEAVE,
                                                       TARGET1_READ_INTERLEAVE,
                                                       TARGET0_READ_INTERLEAVE
                                                      };														
   localparam                  CROSSBAR_INTERLEAVE      = ((| INITIATOR_READ_INTERLEAVE) || (| TARGET_READ_INTERLEAVE));		
   localparam                  NUM_INITIATORS_WIDTH_ADJ = (NUM_INITIATORS_WIDTH == 0) ? 1 : NUM_INITIATORS_WIDTH;   
   localparam                  TARGET_ID_WIDTH          = (NUM_INITIATORS_WIDTH + ID_WIDTH);   
   
   localparam [(NUM_INITIATORS*4)-1:0] NUM_RS_STAGES_INITR = {
                                                       NUM_RS_STAGES_INITR15,
                                                       NUM_RS_STAGES_INITR14,
                                                       NUM_RS_STAGES_INITR13,
                                                       NUM_RS_STAGES_INITR12,
                                                       NUM_RS_STAGES_INITR11,
                                                       NUM_RS_STAGES_INITR10,
                                                       NUM_RS_STAGES_INITR9,
                                                       NUM_RS_STAGES_INITR8,
                                                       NUM_RS_STAGES_INITR7,
                                                       NUM_RS_STAGES_INITR6,
                                                       NUM_RS_STAGES_INITR5,
                                                       NUM_RS_STAGES_INITR4,
                                                       NUM_RS_STAGES_INITR3,
                                                       NUM_RS_STAGES_INITR2,
                                                       NUM_RS_STAGES_INITR1,
                                                       NUM_RS_STAGES_INITR0
                                                     };					

   localparam [(NUM_TARGETS*4)-1:0]    NUM_RS_STAGES_TRGT = {
                                                       NUM_RS_STAGES_TRGT31,
                                                       NUM_RS_STAGES_TRGT30,
                                                       NUM_RS_STAGES_TRGT29,
                                                       NUM_RS_STAGES_TRGT28,
                                                       NUM_RS_STAGES_TRGT27,
                                                       NUM_RS_STAGES_TRGT26,
                                                       NUM_RS_STAGES_TRGT25,
                                                       NUM_RS_STAGES_TRGT24,
                                                       NUM_RS_STAGES_TRGT23,
                                                       NUM_RS_STAGES_TRGT22,
                                                       NUM_RS_STAGES_TRGT21,
                                                       NUM_RS_STAGES_TRGT20,
                                                       NUM_RS_STAGES_TRGT19,
                                                       NUM_RS_STAGES_TRGT18,
                                                       NUM_RS_STAGES_TRGT17,
                                                       NUM_RS_STAGES_TRGT16,
                                                       NUM_RS_STAGES_TRGT15,
                                                       NUM_RS_STAGES_TRGT14,
                                                       NUM_RS_STAGES_TRGT13,
                                                       NUM_RS_STAGES_TRGT12,
                                                       NUM_RS_STAGES_TRGT11,
                                                       NUM_RS_STAGES_TRGT10,
                                                       NUM_RS_STAGES_TRGT9,
                                                       NUM_RS_STAGES_TRGT8,
                                                       NUM_RS_STAGES_TRGT7,
                                                       NUM_RS_STAGES_TRGT6,
                                                       NUM_RS_STAGES_TRGT5,
                                                       NUM_RS_STAGES_TRGT4,
                                                       NUM_RS_STAGES_TRGT3,
                                                       NUM_RS_STAGES_TRGT2,
                                                       NUM_RS_STAGES_TRGT1,
                                                       NUM_RS_STAGES_TRGT0
                                                     };
													 
  localparam integer CB_DWIDTH = (BYPASS_CROSSBAR == 0) ? DATA_WIDTH : TARGET0_DATA_WIDTH;     
  
  localparam [(16*32)-1:0] I_NUM_THREADS = {
                                              INITIATOR15_NUM_THREADS, 
										      INITIATOR14_NUM_THREADS, 
										      INITIATOR13_NUM_THREADS,
										      INITIATOR12_NUM_THREADS,
										      INITIATOR11_NUM_THREADS,
										      INITIATOR10_NUM_THREADS, 
										      INITIATOR9_NUM_THREADS, 
										      INITIATOR8_NUM_THREADS,
                                              INITIATOR7_NUM_THREADS, 
										      INITIATOR6_NUM_THREADS, 
										      INITIATOR5_NUM_THREADS,
										      INITIATOR4_NUM_THREADS,
										      INITIATOR3_NUM_THREADS,
										      INITIATOR2_NUM_THREADS, 
										      INITIATOR1_NUM_THREADS, 
										      INITIATOR0_NUM_THREADS
										   };
										   
  
  localparam [(16*32)-1:0] I_OPEN_TRANS_MAX = {
                                                 INITIATOR15_OPEN_TRANS_MAX, 
										         INITIATOR14_OPEN_TRANS_MAX, 
										         INITIATOR13_OPEN_TRANS_MAX,
										         INITIATOR12_OPEN_TRANS_MAX,
										         INITIATOR11_OPEN_TRANS_MAX,
										         INITIATOR10_OPEN_TRANS_MAX, 
										         INITIATOR9_OPEN_TRANS_MAX, 
										         INITIATOR8_OPEN_TRANS_MAX,
                                                 INITIATOR7_OPEN_TRANS_MAX, 
										         INITIATOR6_OPEN_TRANS_MAX, 
										         INITIATOR5_OPEN_TRANS_MAX,
										         INITIATOR4_OPEN_TRANS_MAX,
										         INITIATOR3_OPEN_TRANS_MAX,
										         INITIATOR2_OPEN_TRANS_MAX, 
										         INITIATOR1_OPEN_TRANS_MAX, 
										         INITIATOR0_OPEN_TRANS_MAX
											  };
   
  //==================================================================================================================================
  // Variable Declarations
  //==================================================================================================================================  

  //====================== Target Read Address Ports  ================================================//
  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0] targetARID;
  wire [NUM_TARGETS*ADDR_WIDTH-1:0]                   targetARADDR;
  wire [NUM_TARGETS*8-1:0]                            targetARLEN;
  wire [NUM_TARGETS*3-1:0]                            targetARSIZE;
  wire [NUM_TARGETS*2-1:0]                            targetARBURST;
  wire [NUM_TARGETS*2-1:0]                            targetARLOCK;
  wire [NUM_TARGETS*4-1:0]                            targetARCACHE;
  wire [NUM_TARGETS*3-1:0]                            targetARPROT;
  wire [NUM_TARGETS*4-1:0]                            targetARREGION;
  wire [NUM_TARGETS*4-1:0]                            targetARQOS;
  wire [NUM_TARGETS*USER_WIDTH-1:0]                   targetARUSER;
  wire [NUM_TARGETS-1:0]                              targetARVALID;
  wire [NUM_TARGETS-1:0]                              targetARREADY;

  //====================== Target Read Data Ports  ====================================================//
  wire [NUM_TARGETS-1:0]                               targetRVALID;
  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0]  targetRID;
  wire [NUM_TARGETS*CB_DWIDTH-1:0]                     targetRDATA;
  wire [NUM_TARGETS*2-1:0]                             targetRRESP;
  wire [NUM_TARGETS-1:0]                               targetRLAST;
  wire [NUM_TARGETS*USER_WIDTH-1:0]                    targetRUSER;
    
  wire [NUM_TARGETS-1:0]                               targetRREADY;

  //====================== Target Write Address Ports  ====================================================//
  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0]  targetAWID;
  wire [NUM_TARGETS*ADDR_WIDTH-1:0]                    targetAWADDR;
  wire [NUM_TARGETS*8-1:0]                             targetAWLEN;
  wire [NUM_TARGETS*3-1:0]                             targetAWSIZE;
  wire [NUM_TARGETS*2-1:0]                             targetAWBURST;
  wire [NUM_TARGETS*2-1:0]                             targetAWLOCK;
  wire [NUM_TARGETS*4-1:0]                             targetAWCACHE;
  wire [NUM_TARGETS*3-1:0]                             targetAWPROT;
  wire [NUM_TARGETS*4-1:0]                             targetAWREGION;
  wire [NUM_TARGETS*4-1:0]                             targetAWQOS;
  wire [NUM_TARGETS*USER_WIDTH-1:0]                    targetAWUSER;
  wire [NUM_TARGETS-1:0]                               targetAWVALID;
  wire [NUM_TARGETS-1:0]                               targetAWREADY;

  //====================== Target Write Data Ports  ====================================================//
  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0]  targetWID;
  wire [NUM_TARGETS*CB_DWIDTH-1:0]                     targetWDATA;
  wire [NUM_TARGETS*CB_DWIDTH/8-1:0]                   targetWSTRB;
  wire [NUM_TARGETS-1:0]                               targetWLAST;
  wire [NUM_TARGETS*USER_WIDTH-1:0]                    targetWUSER;
  wire [NUM_TARGETS-1:0]                               targetWVALID;
  wire [NUM_TARGETS-1:0]                               targetWREADY;

  //====================== Target Write Response Ports  ====================================================//
  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0]  targetBID;
  wire [NUM_TARGETS*2-1:0]                             targetBRESP;
  wire [NUM_TARGETS*USER_WIDTH-1:0]                    targetBUSER;
  wire [NUM_TARGETS-1:0]                               targetBVALID;
  wire [NUM_TARGETS-1:0]                               targetBREADY;


  //====================== Target Read Address Ports  ================================================//
  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0]    TARGET_ARID;
  wire [NUM_TARGETS*ADDR_WIDTH-1:0]                      TARGET_ARADDR;
  wire [NUM_TARGETS*8-1:0]                               TARGET_ARLEN;
  wire [NUM_TARGETS*3-1:0]                               TARGET_ARSIZE;
  wire [NUM_TARGETS*2-1:0]                               TARGET_ARBURST;
  wire [NUM_TARGETS*2-1:0]                               TARGET_ARLOCK;
  wire [NUM_TARGETS*4-1:0]                               TARGET_ARCACHE;
  wire [NUM_TARGETS*3-1:0]                               TARGET_ARPROT;
  wire [NUM_TARGETS*4-1:0]                               TARGET_ARREGION;
  wire [NUM_TARGETS*4-1:0]                               TARGET_ARQOS;
  wire [NUM_TARGETS*USER_WIDTH-1:0]                      TARGET_ARUSER;
  wire [NUM_TARGETS-1:0]                                 TARGET_ARVALID;
  wire [NUM_TARGETS-1:0]                                 TARGET_ARREADY;

  //====================== Target Read Data Ports  ====================================================//
  wire [NUM_TARGETS-1:0]                                 TARGET_RVALID;
  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0]    TARGET_RID;
  wire [TARGET_DATA_WIDTH_PORT-1:0]                      TARGET_RDATA;
  wire [NUM_TARGETS*2-1:0]                               TARGET_RRESP;
  wire [NUM_TARGETS-1:0]                                 TARGET_RLAST;
  wire [NUM_TARGETS*USER_WIDTH-1:0]                      TARGET_RUSER;    
  wire [NUM_TARGETS-1:0]                                 TARGET_RREADY;

  //====================== Target Write Address Ports  ====================================================//
  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0]    TARGET_AWID;
  wire [NUM_TARGETS*ADDR_WIDTH-1:0]                      TARGET_AWADDR;
  wire [NUM_TARGETS*8-1:0]                               TARGET_AWLEN;
  wire [NUM_TARGETS*3-1:0]                               TARGET_AWSIZE;
  wire [NUM_TARGETS*2-1:0]                               TARGET_AWBURST;
  wire [NUM_TARGETS*2-1:0]                               TARGET_AWLOCK;
  wire [NUM_TARGETS*4-1:0]                               TARGET_AWCACHE;
  wire [NUM_TARGETS*3-1:0]                               TARGET_AWPROT;
  wire [NUM_TARGETS*4-1:0]                               TARGET_AWREGION;
  wire [NUM_TARGETS*4-1:0]                               TARGET_AWQOS;
  wire [NUM_TARGETS*USER_WIDTH-1:0]                      TARGET_AWUSER;
  wire [NUM_TARGETS-1:0]                                 TARGET_AWVALID;
  wire [NUM_TARGETS-1:0]                                 TARGET_AWREADY;
  
  //====================== Target Write Data Ports  ====================================================//
  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0]    TARGET_WID;
  wire [TARGET_DATA_WIDTH_PORT-1:0]                      TARGET_WDATA;
  wire [TARGET_DATA_WIDTH_PORT/8-1:0]                    TARGET_WSTRB;
  wire [NUM_TARGETS-1:0]                                 TARGET_WLAST;
  wire [NUM_TARGETS*USER_WIDTH-1:0]                      TARGET_WUSER;
  wire [NUM_TARGETS-1:0]                                 TARGET_WVALID;
  wire [NUM_TARGETS-1:0]                                 TARGET_WREADY;

  //====================== Target Write Response Ports  ====================================================//
  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0]    TARGET_BID;
  wire [NUM_TARGETS*2-1:0]                               TARGET_BRESP;
  wire [NUM_TARGETS*USER_WIDTH-1:0]                      TARGET_BUSER;
  wire [NUM_TARGETS-1:0]                                 TARGET_BVALID;
  wire [NUM_TARGETS-1:0]                                 TARGET_BREADY;
       
  //====================== INITIATOR Read Address Ports  ================================================//
  wire [NUM_INITIATORS*ID_WIDTH-1:0]                       initiatorARID;
  wire [NUM_INITIATORS*ADDR_WIDTH-1:0]                     initiatorARADDR;
  wire [NUM_INITIATORS*8-1:0]                              initiatorARLEN;
  wire [NUM_INITIATORS*3-1:0]                              initiatorARSIZE;
  wire [NUM_INITIATORS*2-1:0]                              initiatorARBURST;
  wire [NUM_INITIATORS*2-1:0]                              initiatorARLOCK;
  wire [NUM_INITIATORS*4-1:0]                              initiatorARCACHE;
  wire [NUM_INITIATORS*3-1:0]                              initiatorARPROT;
  wire [NUM_INITIATORS*4-1:0]                              initiatorARREGION;
  wire [NUM_INITIATORS*4-1:0]                              initiatorARQOS;    // not used
  wire [NUM_INITIATORS*USER_WIDTH-1:0]                     initiatorARUSER;
  wire [NUM_INITIATORS-1:0]                                initiatorARVALID;
  wire [NUM_INITIATORS-1:0]                                initiatorARREADY;
    
  //====================== INITIATOR Read Data Ports  ===================================================//
  wire [NUM_INITIATORS*ID_WIDTH-1:0]                       initiatorRID;
  wire [NUM_INITIATORS*CB_DWIDTH-1:0]                      initiatorRDATA;
  wire [NUM_INITIATORS*2-1:0]                              initiatorRRESP;
  wire [NUM_INITIATORS-1:0]                                initiatorRLAST;
  wire [NUM_INITIATORS*USER_WIDTH-1:0]                     initiatorRUSER;
  wire [NUM_INITIATORS-1:0]                                initiatorRVALID;

  wire [NUM_INITIATORS-1:0]                                initiatorRREADY;
   
  //====================== INITIATOR Write Address Ports  ===================================================//
  wire [NUM_INITIATORS*ID_WIDTH-1:0]                       initiatorAWID;
  wire [NUM_INITIATORS*ADDR_WIDTH-1:0]                     initiatorAWADDR;
  wire [NUM_INITIATORS*8-1:0]                              initiatorAWLEN;
  wire [NUM_INITIATORS*3-1:0]                              initiatorAWSIZE;
  wire [NUM_INITIATORS*2-1:0]                              initiatorAWBURST;
  wire [NUM_INITIATORS*2-1:0]                              initiatorAWLOCK;
  wire [NUM_INITIATORS*4-1:0]                              initiatorAWCACHE;
  wire [NUM_INITIATORS*3-1:0]                              initiatorAWPROT;
  wire [NUM_INITIATORS*4-1:0]                              initiatorAWREGION;
  wire [NUM_INITIATORS*4-1:0]                              initiatorAWQOS;        // not used
  wire [NUM_INITIATORS*USER_WIDTH-1:0]                     initiatorAWUSER;        // not used
  wire [NUM_INITIATORS-1:0]                                initiatorAWVALID;
  wire [NUM_INITIATORS-1:0]                                initiatorAWREADY;
    
  //====================== INITIATOR Write Data Ports  ===================================================//
  wire [NUM_INITIATORS*ID_WIDTH-1:0]                       initiatorWID;
  wire [NUM_INITIATORS*CB_DWIDTH-1:0]                      initiatorWDATA;
  wire [NUM_INITIATORS*CB_DWIDTH/8-1:0]                    initiatorWSTRB;
  wire [NUM_INITIATORS-1:0]                                initiatorWLAST;
  wire [NUM_INITIATORS*USER_WIDTH-1:0]                     initiatorWUSER;
  wire [NUM_INITIATORS-1:0]                                initiatorWVALID;
  wire [NUM_INITIATORS-1:0]                                initiatorWREADY;
 
  //====================== INITIATOR Write Response Ports  ===================================================//
  wire [NUM_INITIATORS*ID_WIDTH-1:0]                       initiatorBID;
  wire [NUM_INITIATORS*2-1:0]                              initiatorBRESP;
  wire [NUM_INITIATORS*USER_WIDTH-1:0]                     initiatorBUSER;
  wire [NUM_INITIATORS-1:0]                                initiatorBVALID;
  wire [NUM_INITIATORS-1:0]                                initiatorBREADY;



  //==============================Wires between INITIATOR inputs/outputs And caxi4interconnect_INITIATORConvertor=============================
  // CB INITIATOR Write Address Ports
  wire [NUM_INITIATORS*ID_WIDTH-1:0]                     INITIATOR_AWID;
  wire [NUM_INITIATORS*ADDR_WIDTH-1:0]                   INITIATOR_AWADDR;
  wire [NUM_INITIATORS*8-1:0]                            INITIATOR_AWLEN;
  wire [NUM_INITIATORS*3-1:0]                            INITIATOR_AWSIZE;
  wire [NUM_INITIATORS*2-1:0]                            INITIATOR_AWBURST;
  wire [NUM_INITIATORS*2-1:0]                            INITIATOR_AWLOCK;
  wire [NUM_INITIATORS*4-1:0]                            INITIATOR_AWCACHE;
  wire [NUM_INITIATORS*3-1:0]                            INITIATOR_AWPROT;
  wire [NUM_INITIATORS*4-1:0]                            INITIATOR_AWQOS;      // not used
  wire [NUM_INITIATORS*USER_WIDTH-1:0]                   INITIATOR_AWUSER;      // not used
  wire [NUM_INITIATORS-1:0]                              INITIATOR_AWVALID;
  wire [NUM_INITIATORS-1:0]                              INITIATOR_AWREADY;
  wire [NUM_INITIATORS*4-1:0]                            INITIATOR_AWREGION;
  
  // CB INITIATOR Write Data Ports
  wire [NUM_INITIATORS*ID_WIDTH-1:0]                     INITIATOR_WID;
  wire [INITIATOR_DATA_WIDTH_PORT-1:0]                   INITIATOR_WDATA;
  wire [INITIATOR_DATA_WIDTH_PORT/8-1:0]                 INITIATOR_WSTRB;
  wire [NUM_INITIATORS-1:0]                              INITIATOR_WLAST;
  wire [NUM_INITIATORS*USER_WIDTH-1:0]                   INITIATOR_WUSER;
  wire [NUM_INITIATORS-1:0]                              INITIATOR_WVALID;
  wire [NUM_INITIATORS-1:0]                              INITIATOR_WREADY;
                                              
  // CB INITIATOR Write Response Ports
  wire [NUM_INITIATORS*ID_WIDTH-1:0]                     INITIATOR_BID;
  wire [NUM_INITIATORS*2-1:0]                            INITIATOR_BRESP;
  wire [NUM_INITIATORS*USER_WIDTH-1:0]                   INITIATOR_BUSER;
  wire [NUM_INITIATORS-1:0]                              INITIATOR_BVALID;
  wire [NUM_INITIATORS-1:0]                              INITIATOR_BREADY;

  // CB INITIATOR Read Address Ports
  wire [NUM_INITIATORS*ID_WIDTH-1:0]                     INITIATOR_ARID;
  wire [NUM_INITIATORS*ADDR_WIDTH-1:0]                   INITIATOR_ARADDR;
  wire [NUM_INITIATORS*8-1:0]                            INITIATOR_ARLEN;
  wire [NUM_INITIATORS*3-1:0]                            INITIATOR_ARSIZE;
  wire [NUM_INITIATORS*2-1:0]                            INITIATOR_ARBURST;
  wire [NUM_INITIATORS*2-1:0]                            INITIATOR_ARLOCK;
  wire [NUM_INITIATORS*4-1:0]                            INITIATOR_ARCACHE;
  wire [NUM_INITIATORS*3-1:0]                            INITIATOR_ARPROT;
  wire [NUM_INITIATORS*4-1:0]                            INITIATOR_ARREGION;
  wire [NUM_INITIATORS*4-1:0]                            INITIATOR_ARQOS;    // not used
  wire [NUM_INITIATORS*USER_WIDTH-1:0]                   INITIATOR_ARUSER;
  wire [NUM_INITIATORS-1:0]                              INITIATOR_ARVALID;
  wire [NUM_INITIATORS-1:0]                              INITIATOR_ARREADY;

  // CB INITIATOR Read Data Ports
  wire [NUM_INITIATORS*ID_WIDTH-1:0]                     INITIATOR_RID;
  wire [INITIATOR_DATA_WIDTH_PORT-1:0]                   INITIATOR_RDATA;
  wire [NUM_INITIATORS*2-1:0]                            INITIATOR_RRESP;
  wire [NUM_INITIATORS-1:0]                              INITIATOR_RLAST;
  wire [NUM_INITIATORS*USER_WIDTH-1:0]                   INITIATOR_RUSER;
  wire [NUM_INITIATORS-1:0]                              INITIATOR_RVALID;
  wire [NUM_INITIATORS-1:0]                              INITIATOR_RREADY;

        // AHB interface
  wire[(NUM_INITIATORS*32)-1:0]                          INITIATOR_HADDR;
  wire[(NUM_INITIATORS*3)-1:0]                           INITIATOR_HBURST;
  wire[NUM_INITIATORS-1:0]                               INITIATOR_HMASTLOCK;
  wire[(NUM_INITIATORS*7)-1:0]                           INITIATOR_HPROT;          
  wire[(NUM_INITIATORS*3)-1:0]                           INITIATOR_HSIZE;
  wire[NUM_INITIATORS-1:0]                               INITIATOR_HNONSEC;
  wire[(NUM_INITIATORS*2)-1:0]                           INITIATOR_HTRANS;
  wire[INITIATOR_DATA_WIDTH_PORT-1:0]                    INITIATOR_HWDATA;
  wire[INITIATOR_DATA_WIDTH_PORT-1:0]                    INITIATOR_HRDATA;
  wire[NUM_INITIATORS-1:0]                               INITIATOR_HWRITE;
  wire[NUM_INITIATORS-1:0]                               INITIATOR_HREADY;
  wire[NUM_INITIATORS-1:0]                               INITIATOR_HRESP;
  // wire[7:0]                                           INITIATOR_HEXOKAY;
  // wire[7:0]                                           INITIATOR_HEXCL;
  wire[NUM_INITIATORS-1:0]                               INITIATOR_HSEL;

 // wire[NUM_INITIATORS-1:0] I_CLK;
  wire[16-1:0] I_CLK;
  wire[32-1:0] T_CLK;
  
  wire [15:0]  i_sync_rstn;
  wire [31:0]  t_sync_rstn;

   //SAR77215 fix
  //========================== Wire declarations for modified initiator QoS and Region signals ================ 
   

  wire [3:0]      MOD_INITIATOR0_AWREGION,  MOD_INITIATOR1_AWREGION,  MOD_INITIATOR2_AWREGION,  MOD_INITIATOR3_AWREGION,  MOD_INITIATOR4_AWREGION,  MOD_INITIATOR5_AWREGION,  MOD_INITIATOR6_AWREGION,  MOD_INITIATOR7_AWREGION,
                  MOD_INITIATOR8_AWREGION,  MOD_INITIATOR9_AWREGION,  MOD_INITIATOR10_AWREGION, MOD_INITIATOR11_AWREGION, MOD_INITIATOR12_AWREGION, MOD_INITIATOR13_AWREGION, MOD_INITIATOR14_AWREGION, MOD_INITIATOR15_AWREGION;
  wire [3:0]      MOD_INITIATOR0_AWQOS,     MOD_INITIATOR1_AWQOS,     MOD_INITIATOR2_AWQOS,     MOD_INITIATOR3_AWQOS,     MOD_INITIATOR4_AWQOS,     MOD_INITIATOR5_AWQOS,     MOD_INITIATOR6_AWQOS,     MOD_INITIATOR7_AWQOS,
                  MOD_INITIATOR8_AWQOS,     MOD_INITIATOR9_AWQOS,     MOD_INITIATOR10_AWQOS,    MOD_INITIATOR11_AWQOS,    MOD_INITIATOR12_AWQOS,    MOD_INITIATOR13_AWQOS,    MOD_INITIATOR14_AWQOS,    MOD_INITIATOR15_AWQOS;
  wire [3:0]      MOD_INITIATOR0_ARREGION,  MOD_INITIATOR1_ARREGION,  MOD_INITIATOR2_ARREGION,  MOD_INITIATOR3_ARREGION,  MOD_INITIATOR4_ARREGION,  MOD_INITIATOR5_ARREGION,  MOD_INITIATOR6_ARREGION,  MOD_INITIATOR7_ARREGION,
                  MOD_INITIATOR8_ARREGION,  MOD_INITIATOR9_ARREGION,  MOD_INITIATOR10_ARREGION, MOD_INITIATOR11_ARREGION, MOD_INITIATOR12_ARREGION, MOD_INITIATOR13_ARREGION, MOD_INITIATOR14_ARREGION, MOD_INITIATOR15_ARREGION;
  wire [3:0]      MOD_INITIATOR0_ARQOS,     MOD_INITIATOR1_ARQOS,     MOD_INITIATOR2_ARQOS,     MOD_INITIATOR3_ARQOS,     MOD_INITIATOR4_ARQOS,     MOD_INITIATOR5_ARQOS,     MOD_INITIATOR6_ARQOS,     MOD_INITIATOR7_ARQOS,
                  MOD_INITIATOR8_ARQOS,     MOD_INITIATOR9_ARQOS,     MOD_INITIATOR10_ARQOS,    MOD_INITIATOR11_ARQOS,    MOD_INITIATOR12_ARQOS,    MOD_INITIATOR13_ARQOS,    MOD_INITIATOR14_ARQOS,    MOD_INITIATOR15_ARQOS;   
  
  //=========================== Wire declarations for ARESETN synchronizer in ACLK domain ==================
  
  wire            arst_sync;
  wire            srst_sync;
  
  wire            CB_CLK;
   
   //========================== Zero INITIATOR Region and QoS values fir initiator type 3  (AXI3) (tc:) ===========
   
  assign  MOD_INITIATOR0_AWQOS    = (INITIATOR0_TYPE == 2'b11) ? 4'b0 : INITIATOR0_AWQOS;
  assign  MOD_INITIATOR0_AWREGION = (INITIATOR0_TYPE == 2'b11) ? 4'b0 : INITIATOR0_AWREGION;
  assign  MOD_INITIATOR0_ARQOS    = (INITIATOR0_TYPE == 2'b11) ? 4'b0 : INITIATOR0_ARQOS;
  assign  MOD_INITIATOR0_ARREGION = (INITIATOR0_TYPE == 2'b11) ? 4'b0 : INITIATOR0_ARREGION;
   
  assign  MOD_INITIATOR1_AWQOS    = (INITIATOR1_TYPE == 2'b11) ? 4'b0 : INITIATOR1_AWQOS;
  assign  MOD_INITIATOR1_AWREGION = (INITIATOR1_TYPE == 2'b11) ? 4'b0 : INITIATOR1_AWREGION;
  assign  MOD_INITIATOR1_ARQOS    = (INITIATOR1_TYPE == 2'b11) ? 4'b0 : INITIATOR1_ARQOS;
  assign  MOD_INITIATOR1_ARREGION = (INITIATOR1_TYPE == 2'b11) ? 4'b0 : INITIATOR1_ARREGION;
   
  assign  MOD_INITIATOR2_AWQOS    = (INITIATOR2_TYPE == 2'b11) ? 4'b0 : INITIATOR2_AWQOS;
  assign  MOD_INITIATOR2_AWREGION = (INITIATOR2_TYPE == 2'b11) ? 4'b0 : INITIATOR2_AWREGION;
  assign  MOD_INITIATOR2_ARQOS    = (INITIATOR2_TYPE == 2'b11) ? 4'b0 : INITIATOR2_ARQOS;
  assign  MOD_INITIATOR2_ARREGION = (INITIATOR2_TYPE == 2'b11) ? 4'b0 : INITIATOR2_ARREGION;

  assign  MOD_INITIATOR3_AWQOS    = (INITIATOR3_TYPE == 2'b11) ? 4'b0 : INITIATOR3_AWQOS;
  assign  MOD_INITIATOR3_AWREGION = (INITIATOR3_TYPE == 2'b11) ? 4'b0 : INITIATOR3_AWREGION;
  assign  MOD_INITIATOR3_ARQOS    = (INITIATOR3_TYPE == 2'b11) ? 4'b0 : INITIATOR3_ARQOS;
  assign  MOD_INITIATOR3_ARREGION = (INITIATOR3_TYPE == 2'b11) ? 4'b0 : INITIATOR3_ARREGION;
  
  assign  MOD_INITIATOR4_AWQOS    = (INITIATOR4_TYPE == 2'b11) ? 4'b0 : INITIATOR4_AWQOS;
  assign  MOD_INITIATOR4_AWREGION = (INITIATOR4_TYPE == 2'b11) ? 4'b0 : INITIATOR4_AWREGION;
  assign  MOD_INITIATOR4_ARQOS    = (INITIATOR4_TYPE == 2'b11) ? 4'b0 : INITIATOR4_ARQOS;
  assign  MOD_INITIATOR4_ARREGION = (INITIATOR4_TYPE == 2'b11) ? 4'b0 : INITIATOR4_ARREGION;
   
  assign  MOD_INITIATOR5_AWQOS    = (INITIATOR5_TYPE == 2'b11) ? 4'b0 : INITIATOR5_AWQOS;
  assign  MOD_INITIATOR5_AWREGION = (INITIATOR5_TYPE == 2'b11) ? 4'b0 : INITIATOR5_AWREGION;
  assign  MOD_INITIATOR5_ARQOS    = (INITIATOR5_TYPE == 2'b11) ? 4'b0 : INITIATOR5_ARQOS;
  assign  MOD_INITIATOR5_ARREGION = (INITIATOR5_TYPE == 2'b11) ? 4'b0 : INITIATOR5_ARREGION;
   
  assign  MOD_INITIATOR6_AWQOS    = (INITIATOR6_TYPE == 2'b11) ? 4'b0 : INITIATOR6_AWQOS;
  assign  MOD_INITIATOR6_AWREGION = (INITIATOR6_TYPE == 2'b11) ? 4'b0 : INITIATOR6_AWREGION;
  assign  MOD_INITIATOR6_ARQOS    = (INITIATOR6_TYPE == 2'b11) ? 4'b0 : INITIATOR6_ARQOS;
  assign  MOD_INITIATOR6_ARREGION = (INITIATOR6_TYPE == 2'b11) ? 4'b0 : INITIATOR6_ARREGION;
   
  assign  MOD_INITIATOR7_AWQOS    = (INITIATOR7_TYPE == 2'b11) ? 4'b0 : INITIATOR7_AWQOS;
  assign  MOD_INITIATOR7_AWREGION = (INITIATOR7_TYPE == 2'b11) ? 4'b0 : INITIATOR7_AWREGION;
  assign  MOD_INITIATOR7_ARQOS    = (INITIATOR7_TYPE == 2'b11) ? 4'b0 : INITIATOR7_ARQOS;
  assign  MOD_INITIATOR7_ARREGION = (INITIATOR7_TYPE == 2'b11) ? 4'b0 : INITIATOR7_ARREGION;
  
  assign  MOD_INITIATOR8_AWQOS    = (INITIATOR8_TYPE == 2'b11) ? 4'b0 : INITIATOR8_AWQOS;
  assign  MOD_INITIATOR8_AWREGION = (INITIATOR8_TYPE == 2'b11) ? 4'b0 : INITIATOR8_AWREGION;
  assign  MOD_INITIATOR8_ARQOS    = (INITIATOR8_TYPE == 2'b11) ? 4'b0 : INITIATOR8_ARQOS;
  assign  MOD_INITIATOR8_ARREGION = (INITIATOR8_TYPE == 2'b11) ? 4'b0 : INITIATOR8_ARREGION;
  
  assign  MOD_INITIATOR9_AWQOS    = (INITIATOR9_TYPE == 2'b11) ? 4'b0 : INITIATOR9_AWQOS;
  assign  MOD_INITIATOR9_AWREGION = (INITIATOR9_TYPE == 2'b11) ? 4'b0 : INITIATOR9_AWREGION;
  assign  MOD_INITIATOR9_ARQOS    = (INITIATOR9_TYPE == 2'b11) ? 4'b0 : INITIATOR9_ARQOS;
  assign  MOD_INITIATOR9_ARREGION = (INITIATOR9_TYPE == 2'b11) ? 4'b0 : INITIATOR9_ARREGION;
  
  assign  MOD_INITIATOR10_AWQOS    = (INITIATOR10_TYPE == 2'b11) ? 4'b0 : INITIATOR10_AWQOS;
  assign  MOD_INITIATOR10_AWREGION = (INITIATOR10_TYPE == 2'b11) ? 4'b0 : INITIATOR10_AWREGION;
  assign  MOD_INITIATOR10_ARQOS    = (INITIATOR10_TYPE == 2'b11) ? 4'b0 : INITIATOR10_ARQOS;
  assign  MOD_INITIATOR10_ARREGION = (INITIATOR10_TYPE == 2'b11) ? 4'b0 : INITIATOR10_ARREGION;
  
  assign  MOD_INITIATOR11_AWQOS    = (INITIATOR11_TYPE == 2'b11) ? 4'b0 : INITIATOR11_AWQOS;
  assign  MOD_INITIATOR11_AWREGION = (INITIATOR11_TYPE == 2'b11) ? 4'b0 : INITIATOR11_AWREGION;
  assign  MOD_INITIATOR11_ARQOS    = (INITIATOR11_TYPE == 2'b11) ? 4'b0 : INITIATOR11_ARQOS;
  assign  MOD_INITIATOR11_ARREGION = (INITIATOR11_TYPE == 2'b11) ? 4'b0 : INITIATOR11_ARREGION;
  
  assign  MOD_INITIATOR12_AWQOS    = (INITIATOR12_TYPE == 2'b11) ? 4'b0 : INITIATOR12_AWQOS;
  assign  MOD_INITIATOR12_AWREGION = (INITIATOR12_TYPE == 2'b11) ? 4'b0 : INITIATOR12_AWREGION;
  assign  MOD_INITIATOR12_ARQOS    = (INITIATOR12_TYPE == 2'b11) ? 4'b0 : INITIATOR12_ARQOS;
  assign  MOD_INITIATOR12_ARREGION = (INITIATOR12_TYPE == 2'b11) ? 4'b0 : INITIATOR12_ARREGION;
  
  assign  MOD_INITIATOR13_AWQOS    = (INITIATOR13_TYPE == 2'b11) ? 4'b0 : INITIATOR13_AWQOS;
  assign  MOD_INITIATOR13_AWREGION = (INITIATOR13_TYPE == 2'b11) ? 4'b0 : INITIATOR13_AWREGION;
  assign  MOD_INITIATOR13_ARQOS    = (INITIATOR13_TYPE == 2'b11) ? 4'b0 : INITIATOR13_ARQOS;
  assign  MOD_INITIATOR13_ARREGION = (INITIATOR13_TYPE == 2'b11) ? 4'b0 : INITIATOR13_ARREGION;
  
  assign  MOD_INITIATOR14_AWQOS    = (INITIATOR14_TYPE == 2'b11) ? 4'b0 : INITIATOR14_AWQOS;
  assign  MOD_INITIATOR14_AWREGION = (INITIATOR14_TYPE == 2'b11) ? 4'b0 : INITIATOR14_AWREGION;
  assign  MOD_INITIATOR14_ARQOS    = (INITIATOR14_TYPE == 2'b11) ? 4'b0 : INITIATOR14_ARQOS;
  assign  MOD_INITIATOR14_ARREGION = (INITIATOR14_TYPE == 2'b11) ? 4'b0 : INITIATOR14_ARREGION;
  
  assign  MOD_INITIATOR15_AWQOS    = (INITIATOR15_TYPE == 2'b11) ? 4'b0 : INITIATOR15_AWQOS;
  assign  MOD_INITIATOR15_AWREGION = (INITIATOR15_TYPE == 2'b11) ? 4'b0 : INITIATOR15_AWREGION;
  assign  MOD_INITIATOR15_ARQOS    = (INITIATOR15_TYPE == 2'b11) ? 4'b0 : INITIATOR15_ARQOS;
  assign  MOD_INITIATOR15_ARREGION = (INITIATOR15_TYPE == 2'b11) ? 4'b0 : INITIATOR15_ARREGION;
  
    
  //==============================INITIATOR Combine Signals===============================================

  //===================================================================================================

  // INITIATOR 0
  //===================================================================================================

  //output to initiator converter   

  assign  INITIATOR_ARID[(0+1)*ID_WIDTH-1:0*ID_WIDTH]                                        = INITIATOR0_ARID;
  assign  INITIATOR_ARADDR[(0+1)*ADDR_WIDTH-1:0*ADDR_WIDTH]                                  = INITIATOR0_ARADDR;
  assign  INITIATOR_ARLEN[(0+1)*8-1:0*8]                                                     = INITIATOR0_ARLEN;
  assign  INITIATOR_ARSIZE[(0+1)*3-1:0*3]                                                    = INITIATOR0_ARSIZE;
  assign  INITIATOR_ARBURST[(0+1)*2-1:0*2]                                                   = INITIATOR0_ARBURST;
  // SAR#LINT-001: Explicit bit-select to avoid width overflow (AXI4 uses 1-bit LOCK, AXI3 uses 2-bit)
  assign  INITIATOR_ARLOCK[(0+1)*2-1:0*2]                                                    = INITIATOR0_TYPE == 2'b11 ? INITIATOR0_ARLOCK[1:0] : {1'b0,INITIATOR0_ARLOCK[0]};
  assign  INITIATOR_ARCACHE[(0+1)*4-1:0*4]                                                   = INITIATOR0_ARCACHE;
  assign  INITIATOR_ARPROT[(0+1)*3-1:0*3]                                                    = INITIATOR0_ARPROT;
  assign  INITIATOR_ARREGION[(0+1)*4-1:0*4]                                                  = MOD_INITIATOR0_ARREGION;
  assign  INITIATOR_ARQOS[(0+1)*4-1:0*4]                                                     = MOD_INITIATOR0_ARQOS;
  assign  INITIATOR_ARUSER[(0+1)*USER_WIDTH-1:0*USER_WIDTH]                                  = INITIATOR0_ARUSER;
  assign  INITIATOR_ARVALID[0]                                                               = INITIATOR0_ARVALID;
  assign  INITIATOR_AWQOS[(0+1)*4-1:0*4]                                                     = MOD_INITIATOR0_AWQOS;
  assign  INITIATOR_AWREGION[(0+1)*4-1:0*4]                                                  = MOD_INITIATOR0_AWREGION;
  assign  INITIATOR_AWID[(0+1)*ID_WIDTH-1:0*ID_WIDTH]                                        = INITIATOR0_AWID;  
  assign  INITIATOR_AWADDR[(0+1)*ADDR_WIDTH-1:0*ADDR_WIDTH]                                  = INITIATOR0_AWADDR;  
  assign  INITIATOR_AWLEN[(0+1)*8-1:0*8]                                                     = INITIATOR0_AWLEN;  
  assign  INITIATOR_AWSIZE[(0+1)*3-1:0*3]                                                    = INITIATOR0_AWSIZE;  
  assign  INITIATOR_AWBURST[(0+1)*2-1:0*2]                                                   = INITIATOR0_AWBURST;  
  // SAR#LINT-001: Explicit bit-select to avoid width overflow (AXI4 uses 1-bit LOCK, AXI3 uses 2-bit)
  assign  INITIATOR_AWLOCK[(0+1)*2-1:0*2]                                                    = (INITIATOR0_TYPE == 2'b11) ? INITIATOR0_AWLOCK[1:0] : {1'b0,INITIATOR0_AWLOCK[0]};  
  assign  INITIATOR_AWCACHE[(0+1)*4-1:0*4]                                                   = INITIATOR0_AWCACHE;  
  assign  INITIATOR_AWPROT[(0+1)*3-1:0*3]                                                    = INITIATOR0_AWPROT;  
  assign  INITIATOR_AWUSER[(0+1)*USER_WIDTH-1:0*USER_WIDTH]                                  = INITIATOR0_AWUSER;  
  assign  INITIATOR_AWVALID[0]                                                               = INITIATOR0_AWVALID;  
  assign  INITIATOR_WID  [(0+1)*ID_WIDTH-1:0*ID_WIDTH]                                       = INITIATOR0_WID;  
  assign  INITIATOR_WDATA[MDW_UPPER_VEC[(0+1)*13-1:13*0]-1:MDW_LOWER_VEC[(0+1)*13-1:13*0]]   = INITIATOR0_WDATA;  
  assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(0+1)*13-1:13*0]/8-1:MDW_LOWER_VEC[(0+1)*13-1:13*0]] = INITIATOR0_WSTRB;  
  assign  INITIATOR_WLAST[0]                                                                 = INITIATOR0_WLAST;  
  assign  INITIATOR_WUSER[(0+1)*USER_WIDTH-1:0*USER_WIDTH]                                   = INITIATOR0_WUSER;  
  assign  INITIATOR_WVALID[0]                                                                = INITIATOR0_WVALID;  
  assign  INITIATOR_BREADY[0]                                                                = INITIATOR0_BREADY;  
  assign  INITIATOR_RREADY[0]                                                                = INITIATOR0_RREADY;

  assign  INITIATOR0_RID           = INITIATOR_RID[(0+1)*ID_WIDTH-1:0*ID_WIDTH];
  assign  INITIATOR0_RDATA         = INITIATOR_RDATA[MDW_UPPER_VEC[(0+1)*13-1:13*0]-1:MDW_LOWER_VEC[(0+1)*13-1:13*0]];
  assign  INITIATOR0_RRESP         = INITIATOR_RRESP[(0+1)*2-1:0*2];
  assign  INITIATOR0_RUSER         = INITIATOR_RUSER[(0+1)*USER_WIDTH-1:0*USER_WIDTH];
  assign  INITIATOR0_BID           = INITIATOR_BID[(0+1)*ID_WIDTH-1:0*ID_WIDTH];
  assign  INITIATOR0_BRESP         = INITIATOR_BRESP[(0+1)*2-1:0*2];
  assign  INITIATOR0_BUSER         = INITIATOR_BUSER[(0+1)*USER_WIDTH-1:0*USER_WIDTH];
  assign  INITIATOR0_ARREADY       = INITIATOR_ARREADY[0];
  assign  INITIATOR0_RLAST         = INITIATOR_RLAST[0];
  assign  INITIATOR0_RVALID        = INITIATOR_RVALID[0];
  assign  INITIATOR0_AWREADY       = INITIATOR_AWREADY[0];
  assign  INITIATOR0_WREADY        = INITIATOR_WREADY[0];
  assign  INITIATOR0_BVALID        = INITIATOR_BVALID[0];

        // AHB interface
  assign INITIATOR_HADDR[32*(0+1)-1:32*0]                                                    = INITIATOR0_HADDR;
  assign INITIATOR_HBURST[3*(0+1)-1:3*0]                                                     = INITIATOR0_HBURST;
  assign INITIATOR_HMASTLOCK[0]                                                              = INITIATOR0_HMASTLOCK;
  assign INITIATOR_HPROT[7*(0+1)-1:7*0]                                                      = INITIATOR0_HPROT;          
  assign INITIATOR_HSIZE[3*(0+1)-1:3*0]                                                      = INITIATOR0_HSIZE;
  assign INITIATOR_HNONSEC[0]                                                                = INITIATOR0_HNONSEC;
  assign INITIATOR_HTRANS[2*(0+1)-1:2*0]                                                     = INITIATOR0_HTRANS;
  assign INITIATOR_HWDATA[MDW_UPPER_VEC[(0+1)*13-1:13*0]-1:MDW_LOWER_VEC[(0+1)*13-1:13*0]]   = INITIATOR0_HWDATA;
  assign INITIATOR0_HRDATA                                                                   = INITIATOR_HRDATA[MDW_UPPER_VEC[(0+1)*13-1:13*0]-1:MDW_LOWER_VEC[(0+1)*13-1:13*0]];
  assign INITIATOR_HWRITE[0]                                                                 = INITIATOR0_HWRITE;
  assign INITIATOR0_HRESP                                                                    = INITIATOR_HRESP[0];
  // assign INITIATOR0_HEXOKAY                                                                  = INITIATOR_HEXOKAY[0];
  // assign INITIATOR_HEXCL[0]                                                                  = INITIATOR0_HEXCL;
  assign INITIATOR_HSEL[0]                                                                   = INITIATOR0_HSEL;
  assign INITIATOR0_HREADY                                                                   = INITIATOR_HREADY[0];
  
  assign CB_CLK                                                                              = (BYPASS_CROSSBAR == 0) ? ACLK : T_CLK0;

  //===================================================================================================
  //INITIATOR 1
  //===================================================================================================  

  if ( NUM_INITIATORS > 1)
    begin
      //output to initiator converter 
      
      assign   INITIATOR_ARID[(1+1)*ID_WIDTH-1:1*ID_WIDTH]                                         = INITIATOR1_ARID;
      assign   INITIATOR_ARADDR[(1+1)*ADDR_WIDTH-1:1*ADDR_WIDTH]                                   = INITIATOR1_ARADDR;
      assign   INITIATOR_ARLEN[(1+1)*8-1:1*8]                                                      = INITIATOR1_ARLEN;
      assign   INITIATOR_ARSIZE[(1+1)*3-1:1*3]                                                     = INITIATOR1_ARSIZE;
      assign   INITIATOR_ARBURST[(1+1)*2-1:1*2]                                                    = INITIATOR1_ARBURST;
      assign   INITIATOR_ARLOCK[(1+1)*2-1:1*2]                                                     = (INITIATOR1_TYPE == 2'b11) ? INITIATOR1_ARLOCK[1:0] : {1'b0, INITIATOR1_ARLOCK[0]};
      assign   INITIATOR_ARCACHE[(1+1)*4-1:1*4]                                                    = INITIATOR1_ARCACHE;
      assign   INITIATOR_ARPROT[(1+1)*3-1:1*3]                                                     = INITIATOR1_ARPROT;
      assign   INITIATOR_ARREGION[(1+1)*4-1:1*4]                                                   = MOD_INITIATOR1_ARREGION;
      assign   INITIATOR_ARQOS[(1+1)*4-1:1*4]                                                      = MOD_INITIATOR1_ARQOS;
      assign   INITIATOR_ARUSER[(1+1)*USER_WIDTH-1:1*USER_WIDTH]                                   = INITIATOR1_ARUSER;
      assign   INITIATOR_ARVALID[1]                                                                = INITIATOR1_ARVALID;
      assign   INITIATOR_AWQOS[(1+1)*4-1:1*4]                                                      = MOD_INITIATOR1_AWQOS;
      assign   INITIATOR_AWREGION[(1+1)*4-1:1*4]                                                   = MOD_INITIATOR1_AWREGION;
      assign  INITIATOR_AWID[(1+1)*ID_WIDTH-1:1*ID_WIDTH]                                          = INITIATOR1_AWID;  
      assign  INITIATOR_AWADDR[(1+1)*ADDR_WIDTH-1:1*ADDR_WIDTH]                                    = INITIATOR1_AWADDR;  
      assign  INITIATOR_AWLEN[(1+1)*8-1:1*8]                                                       = INITIATOR1_AWLEN;  
      assign  INITIATOR_AWSIZE[(1+1)*3-1:1*3]                                                      = INITIATOR1_AWSIZE;  
      assign  INITIATOR_AWBURST[(1+1)*2-1:1*2]                                                     = INITIATOR1_AWBURST;  
      assign  INITIATOR_AWLOCK[(1+1)*2-1:1*2]                                                      = (INITIATOR1_TYPE == 2'b11) ? INITIATOR1_AWLOCK[1:0] : {1'b0, INITIATOR1_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(1+1)*4-1:1*4]                                                     = INITIATOR1_AWCACHE;  
      assign  INITIATOR_AWPROT[(1+1)*3-1:1*3]                                                      = INITIATOR1_AWPROT;  
      assign  INITIATOR_AWUSER[(1+1)*USER_WIDTH-1:1*USER_WIDTH]                                    = INITIATOR1_AWUSER;  
      assign  INITIATOR_AWVALID[1]                                                                 = INITIATOR1_AWVALID; 
      assign  INITIATOR_WID  [(1+1)*ID_WIDTH-1:1*ID_WIDTH]                                         = INITIATOR1_WID;  	  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(1+1)*13-1:13*1]-1:MDW_LOWER_VEC[(1+1)*13-1:13*1]]     = INITIATOR1_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(1+1)*13-1:13*1]/8-1:MDW_LOWER_VEC[(1+1)*13-1:13*1]/8] = INITIATOR1_WSTRB;  
      assign  INITIATOR_WLAST[1]                                                                   = INITIATOR1_WLAST;  
      assign  INITIATOR_WUSER[(1+1)*USER_WIDTH-1:1*USER_WIDTH]                                     = INITIATOR1_WUSER;  
      assign  INITIATOR_WVALID[1]                                                                  = INITIATOR1_WVALID;  
      assign  INITIATOR_BREADY[1]                                                                  = INITIATOR1_BREADY;  
      assign  INITIATOR_RREADY[1]                                                                  = INITIATOR1_RREADY;  

      assign INITIATOR1_RID        = INITIATOR_RID[(1+1)*ID_WIDTH-1:1*ID_WIDTH];
      assign INITIATOR1_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(1+1)*13-1:13*1]-1:MDW_LOWER_VEC[(1+1)*13-1:13*1]];
      assign INITIATOR1_RRESP      = INITIATOR_RRESP[(1+1)*2-1:1*2];
      assign INITIATOR1_RUSER      = INITIATOR_RUSER[(1+1)*USER_WIDTH-1:1*USER_WIDTH];
      assign INITIATOR1_BID        = INITIATOR_BID[(1+1)*ID_WIDTH-1:1*ID_WIDTH];
      assign INITIATOR1_BRESP      = INITIATOR_BRESP[(1+1)*2-1:1*2];
      assign INITIATOR1_BUSER      = INITIATOR_BUSER[(1+1)*USER_WIDTH-1:1*USER_WIDTH];
      assign INITIATOR1_ARREADY    = INITIATOR_ARREADY[1];
      assign INITIATOR1_RLAST      = INITIATOR_RLAST[1];
      assign INITIATOR1_RVALID     = INITIATOR_RVALID[1];
      assign INITIATOR1_AWREADY    = INITIATOR_AWREADY[1];
      assign INITIATOR1_WREADY     = INITIATOR_WREADY[1];
      assign INITIATOR1_BVALID     = INITIATOR_BVALID[1];

      // AHB interface
      assign INITIATOR_HADDR[32*(1+1)-1:32*1]                                                  = INITIATOR1_HADDR;
      assign INITIATOR_HBURST[3*(1+1)-1:3*1]                                                   = INITIATOR1_HBURST;
      assign INITIATOR_HMASTLOCK[1]                                                            = INITIATOR1_HMASTLOCK;
      assign INITIATOR_HPROT[7*(1+1)-1:7*1]                                                    = INITIATOR1_HPROT;          
      assign INITIATOR_HSIZE[3*(1+1)-1:3*1]                                                    = INITIATOR1_HSIZE;
      assign INITIATOR_HNONSEC[1]                                                              = INITIATOR1_HNONSEC;
      assign INITIATOR_HTRANS[2*(1+1)-1:2*1]                                                   = INITIATOR1_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(1+1)*13-1:13*1]-1:MDW_LOWER_VEC[(1+1)*13-1:13*1]] = INITIATOR1_HWDATA;
      assign INITIATOR1_HRDATA                                                                 = INITIATOR_HRDATA[MDW_UPPER_VEC[(1+1)*13-1:13*1]-1:MDW_LOWER_VEC[(1+1)*13-1:13*1]];
      assign INITIATOR_HWRITE[1]                                                               = INITIATOR1_HWRITE;
      assign INITIATOR1_HRESP                                                                  = INITIATOR_HRESP[1];
//      assign INITIATOR1_HEXOKAY                                                              = INITIATOR_HEXOKAY[1];
//    assign INITIATOR_HEXCL[1]                                                                = INITIATOR1_HEXCL;
      assign INITIATOR_HSEL[1]                                                                 = INITIATOR1_HSEL;
      assign INITIATOR1_HREADY                                                                 = INITIATOR_HREADY[1];

    end

  //===================================================================================================
  //INITIATOR 2
  //===================================================================================================
  if ( NUM_INITIATORS > 2 )
    begin
      //output to initiator converter 
      assign  INITIATOR_ARID[(2+1)*ID_WIDTH-1:2*ID_WIDTH]                                          = INITIATOR2_ARID;
      assign  INITIATOR_ARADDR[(2+1)*ADDR_WIDTH-1:2*ADDR_WIDTH]                                    = INITIATOR2_ARADDR;
      assign  INITIATOR_ARLEN[(2+1)*8-1:2*8]                                                       = INITIATOR2_ARLEN;
      assign  INITIATOR_ARSIZE[(2+1)*3-1:2*3]                                                      = INITIATOR2_ARSIZE;
      assign  INITIATOR_ARBURST[(2+1)*2-1:2*2]                                                     = INITIATOR2_ARBURST;
      assign  INITIATOR_ARLOCK[(2+1)*2-1:2*2]                                                      = (INITIATOR2_TYPE == 2'b11) ? INITIATOR2_ARLOCK[1:0]
                                                                                                      : {1'b0, INITIATOR2_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(2+1)*4-1:2*4]                                                     = INITIATOR2_ARCACHE;
      assign  INITIATOR_ARPROT[(2+1)*3-1:2*3]                                                      = INITIATOR2_ARPROT;
      assign  INITIATOR_ARREGION[(2+1)*4-1:2*4]                                                    = MOD_INITIATOR2_ARREGION;
      assign  INITIATOR_ARQOS[(2+1)*4-1:2*4]                                                       = MOD_INITIATOR2_ARQOS;
      assign  INITIATOR_ARUSER[(2+1)*USER_WIDTH-1:2*USER_WIDTH]                                    = INITIATOR2_ARUSER;
      assign  INITIATOR_ARVALID[2]                                                                 = INITIATOR2_ARVALID;
      assign  INITIATOR_AWQOS[(2+1)*4-1:2*4]                                                       = MOD_INITIATOR2_AWQOS;
      assign  INITIATOR_AWREGION[(2+1)*4-1:2*4]                                                    = MOD_INITIATOR2_AWREGION;
      assign  INITIATOR_AWID[(2+1)*ID_WIDTH-1:2*ID_WIDTH]                                          = INITIATOR2_AWID;  
      assign  INITIATOR_AWADDR[(2+1)*ADDR_WIDTH-1:2*ADDR_WIDTH]                                    = INITIATOR2_AWADDR;  
      assign  INITIATOR_AWLEN[(2+1)*8-1:2*8]                                                       = INITIATOR2_AWLEN;  
      assign  INITIATOR_AWSIZE[(2+1)*3-1:2*3]                                                      = INITIATOR2_AWSIZE;  
      assign  INITIATOR_AWBURST[(2+1)*2-1:2*2]                                                     = INITIATOR2_AWBURST;  
      assign  INITIATOR_AWLOCK[(2+1)*2-1:2*2]                                                      = (INITIATOR2_TYPE == 2'b11) ? INITIATOR2_AWLOCK[1:0] : {1'b0, INITIATOR2_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(2+1)*4-1:2*4]                                                     = INITIATOR2_AWCACHE;  
      assign  INITIATOR_AWPROT[(2+1)*3-1:2*3]                                                      = INITIATOR2_AWPROT;  
      assign  INITIATOR_AWUSER[(2+1)*USER_WIDTH-1:2*USER_WIDTH]                                    = INITIATOR2_AWUSER;  
      assign  INITIATOR_AWVALID[2]                                                                 = INITIATOR2_AWVALID;  
	  assign  INITIATOR_WID  [(2+1)*ID_WIDTH-1:2*ID_WIDTH]                                         = INITIATOR2_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(2+1)*13-1:13*2]-1:MDW_LOWER_VEC[(2+1)*13-1:13*2]]     = INITIATOR2_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(2+1)*13-1:13*2]/8-1:MDW_LOWER_VEC[(2+1)*13-1:13*2]/8] = INITIATOR2_WSTRB;  
      assign  INITIATOR_WLAST[2]                                                                   = INITIATOR2_WLAST;  
      assign  INITIATOR_WUSER[(2+1)*USER_WIDTH-1:2*USER_WIDTH]                                     = INITIATOR2_WUSER;  
      assign  INITIATOR_WVALID[2]                                                                  = INITIATOR2_WVALID;  
      assign  INITIATOR_BREADY[2]                                                                  = INITIATOR2_BREADY;  
      assign  INITIATOR_RREADY[2]                                                                  = INITIATOR2_RREADY;  

      assign INITIATOR2_RID        = INITIATOR_RID[(2+1)*ID_WIDTH-1:2*ID_WIDTH];
      assign INITIATOR2_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(2+1)*13-1:13*2]-1:MDW_LOWER_VEC[(2+1)*13-1:13*2]];
      assign INITIATOR2_RRESP      = INITIATOR_RRESP[(2+1)*2-1:2*2];
      assign INITIATOR2_RUSER      = INITIATOR_RUSER[(2+1)*USER_WIDTH-1:2*USER_WIDTH];
      assign INITIATOR2_BID        = INITIATOR_BID[(2+1)*ID_WIDTH-1:2*ID_WIDTH];
      assign INITIATOR2_BRESP      = INITIATOR_BRESP[(2+1)*2-1:2*2];
      assign INITIATOR2_BUSER      = INITIATOR_BUSER[(2+1)*USER_WIDTH-1:2*USER_WIDTH];
      assign INITIATOR2_ARREADY    = INITIATOR_ARREADY[2];
      assign INITIATOR2_RLAST      = INITIATOR_RLAST[2];
      assign INITIATOR2_RVALID     = INITIATOR_RVALID[2];
      assign INITIATOR2_AWREADY    = INITIATOR_AWREADY[2];
      assign INITIATOR2_WREADY     = INITIATOR_WREADY[2];
      assign INITIATOR2_BVALID     = INITIATOR_BVALID[2];

      // AHB interface
      assign INITIATOR_HADDR[32*(2+1)-1:32*2]                                                  = INITIATOR2_HADDR;
      assign INITIATOR_HBURST[3*(2+1)-1:3*2]                                                   = INITIATOR2_HBURST;
      assign INITIATOR_HMASTLOCK[2]                                                            = INITIATOR2_HMASTLOCK;
      assign INITIATOR_HPROT[7*(2+1)-1:7*2]                                                    = INITIATOR2_HPROT;          
      assign INITIATOR_HSIZE[3*(2+1)-1:3*2]                                                    = INITIATOR2_HSIZE;
      assign INITIATOR_HNONSEC[2]                                                              = INITIATOR2_HNONSEC;
      assign INITIATOR_HTRANS[2*(2+1)-1:2*2]                                                   = INITIATOR2_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(2+1)*13-1:13*2]-1:MDW_LOWER_VEC[(2+1)*13-1:13*2]] = INITIATOR2_HWDATA;
      assign INITIATOR2_HRDATA                                                                 = INITIATOR_HRDATA[MDW_UPPER_VEC[(2+1)*13-1:13*2]-1:MDW_LOWER_VEC[(2+1)*13-1:13*2]];
      assign INITIATOR_HWRITE[2]                                                               = INITIATOR2_HWRITE;
      assign INITIATOR2_HRESP                                                                  = INITIATOR_HRESP[2];
//      assign INITIATOR2_HEXOKAY                                                              = INITIATOR_HEXOKAY[2];
//                  assign INITIATOR_HEXCL[2]                                                  = INITIATOR2_HEXCL;
      assign INITIATOR_HSEL[2]                                                                 = INITIATOR2_HSEL;
      assign INITIATOR2_HREADY                                                                 = INITIATOR_HREADY[2];

    end
    
  //===================================================================================================
  // INITIATOR 3
  //===================================================================================================
  if ( NUM_INITIATORS > 3)
    begin    
      //output to initiator converter 
      
      assign  INITIATOR_ARID[(3+1)*ID_WIDTH-1:3*ID_WIDTH]                                          = INITIATOR3_ARID;
      assign  INITIATOR_ARADDR[(3+1)*ADDR_WIDTH-1:3*ADDR_WIDTH]                                    = INITIATOR3_ARADDR;
      assign  INITIATOR_ARLEN[(3+1)*8-1:3*8]                                                       = INITIATOR3_ARLEN;
      assign  INITIATOR_ARSIZE[(3+1)*3-1:3*3]                                                      = INITIATOR3_ARSIZE;
      assign  INITIATOR_ARBURST[(3+1)*2-1:3*2]                                                     = INITIATOR3_ARBURST;
      assign  INITIATOR_ARLOCK[(3+1)*2-1:3*2]                                                      = (INITIATOR3_TYPE == 2'b11) ? INITIATOR3_ARLOCK[1:0] : {1'b0, INITIATOR3_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(3+1)*4-1:3*4]                                                     = INITIATOR3_ARCACHE;
      assign  INITIATOR_ARPROT[(3+1)*3-1:3*3]                                                      = INITIATOR3_ARPROT;
      assign  INITIATOR_ARREGION[(3+1)*4-1:3*4]                                                    = MOD_INITIATOR3_ARREGION;
      assign  INITIATOR_ARQOS[(3+1)*4-1:3*4]                                                       = MOD_INITIATOR3_ARQOS;
      assign  INITIATOR_ARUSER[(3+1)*USER_WIDTH-1:3*USER_WIDTH]                                    = INITIATOR3_ARUSER;
      assign  INITIATOR_ARVALID[3]                                                                 = INITIATOR3_ARVALID;
      assign  INITIATOR_AWQOS[(3+1)*4-1:3*4]                                                       = MOD_INITIATOR3_AWQOS;
      assign  INITIATOR_AWREGION[(3+1)*4-1:3*4]                                                    = MOD_INITIATOR3_AWREGION;
      assign  INITIATOR_AWID[(3+1)*ID_WIDTH-1:3*ID_WIDTH]                                          = INITIATOR3_AWID;  
      assign  INITIATOR_AWADDR[(3+1)*ADDR_WIDTH-1:3*ADDR_WIDTH]                                    = INITIATOR3_AWADDR;  
      assign  INITIATOR_AWLEN[(3+1)*8-1:3*8]                                                       = INITIATOR3_AWLEN;  
      assign  INITIATOR_AWSIZE[(3+1)*3-1:3*3]                                                      = INITIATOR3_AWSIZE;  
      assign  INITIATOR_AWBURST[(3+1)*2-1:3*2]                                                     = INITIATOR3_AWBURST;  
      assign  INITIATOR_AWLOCK[(3+1)*2-1:3*2]                                                      = (INITIATOR3_TYPE == 2'b11) ? INITIATOR3_AWLOCK[1:0] : {1'b0, INITIATOR3_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(3+1)*4-1:3*4]                                                     = INITIATOR3_AWCACHE;  
      assign  INITIATOR_AWPROT[(3+1)*3-1:3*3]                                                      = INITIATOR3_AWPROT;  
      assign  INITIATOR_AWUSER[(3+1)*USER_WIDTH-1:3*USER_WIDTH]                                    = INITIATOR3_AWUSER;  
      assign  INITIATOR_AWVALID[3]                                                                 = INITIATOR3_AWVALID;  
	  assign  INITIATOR_WID  [(3+1)*ID_WIDTH-1:3*ID_WIDTH]                                         = INITIATOR3_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(3+1)*13-1:13*3]-1:MDW_LOWER_VEC[(3+1)*13-1:13*3]]     = INITIATOR3_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(3+1)*13-1:13*3]/8-1:MDW_LOWER_VEC[(3+1)*13-1:13*3]/8] = INITIATOR3_WSTRB;  
      assign  INITIATOR_WLAST[3]                                                                   = INITIATOR3_WLAST;  
      assign  INITIATOR_WUSER[(3+1)*USER_WIDTH-1:3*USER_WIDTH]                                     = INITIATOR3_WUSER;  
      assign  INITIATOR_WVALID[3]                                                                  = INITIATOR3_WVALID;  
      assign  INITIATOR_BREADY[3]                                                                  = INITIATOR3_BREADY;  
      assign  INITIATOR_RREADY[3]                                                                  = INITIATOR3_RREADY;  

      assign INITIATOR3_RID        = INITIATOR_RID[(3+1)*ID_WIDTH-1:3*ID_WIDTH];
      assign INITIATOR3_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(3+1)*13-1:13*3]-1:MDW_LOWER_VEC[(3+1)*13-1:13*3]];
      assign INITIATOR3_RRESP      = INITIATOR_RRESP[(3+1)*2-1:3*2];
      assign INITIATOR3_RUSER      = INITIATOR_RUSER[(3+1)*USER_WIDTH-1:3*USER_WIDTH];
      assign INITIATOR3_BID        = INITIATOR_BID[(3+1)*ID_WIDTH-1:3*ID_WIDTH];
      assign INITIATOR3_BRESP      = INITIATOR_BRESP[(3+1)*2-1:3*2];
      assign INITIATOR3_BUSER      = INITIATOR_BUSER[(3+1)*USER_WIDTH-1:3*USER_WIDTH];
      assign INITIATOR3_ARREADY    = INITIATOR_ARREADY[3];
      assign INITIATOR3_RLAST      = INITIATOR_RLAST[3];
      assign INITIATOR3_RVALID     = INITIATOR_RVALID[3];
      assign INITIATOR3_AWREADY    = INITIATOR_AWREADY[3];
      assign INITIATOR3_WREADY     = INITIATOR_WREADY[3];
      assign INITIATOR3_BVALID     = INITIATOR_BVALID[3];

      // AHB interface
      assign INITIATOR_HADDR[32*(3+1)-1:32*3]                                                  = INITIATOR3_HADDR;
      assign INITIATOR_HBURST[3*(3+1)-1:3*3]                                                   = INITIATOR3_HBURST;
      assign INITIATOR_HMASTLOCK[3]                                                            = INITIATOR3_HMASTLOCK;
      assign INITIATOR_HPROT[7*(3+1)-1:7*3]                                                    = INITIATOR3_HPROT;          
      assign INITIATOR_HSIZE[3*(3+1)-1:3*3]                                                    = INITIATOR3_HSIZE;
      assign INITIATOR_HNONSEC[3]                                                              = INITIATOR3_HNONSEC;
      assign INITIATOR_HTRANS[2*(3+1)-1:2*3]                                                   = INITIATOR3_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(3+1)*13-1:13*3]-1:MDW_LOWER_VEC[(3+1)*13-1:13*3]] = INITIATOR3_HWDATA;
      assign INITIATOR3_HRDATA                                                                 = INITIATOR_HRDATA[MDW_UPPER_VEC[(3+1)*13-1:13*3]-1:MDW_LOWER_VEC[(3+1)*13-1:13*3]];
      assign INITIATOR_HWRITE[3]                                                               = INITIATOR3_HWRITE;
      assign INITIATOR3_HRESP                                                                  = INITIATOR_HRESP[3];
//      assign INITIATOR3_HEXOKAY                                                              = INITIATOR_HEXOKAY[3];
//      assign INITIATOR_HEXCL[3]                                                              = INITIATOR3_HEXCL;
      assign INITIATOR_HSEL[3]                                                                 = INITIATOR3_HSEL;
      assign INITIATOR3_HREADY = INITIATOR_HREADY[3];
    end
    
  //===================================================================================================
  // INITIATOR 4
  //===================================================================================================
  if ( NUM_INITIATORS > 4)
    begin  
      //output to initiator converter
      
      assign   INITIATOR_ARID[(4+1)*ID_WIDTH-1:4*ID_WIDTH]                                         = INITIATOR4_ARID;
      assign   INITIATOR_ARADDR[(4+1)*ADDR_WIDTH-1:4*ADDR_WIDTH]                                   = INITIATOR4_ARADDR;
      assign   INITIATOR_ARLEN[(4+1)*8-1:4*8]                                                      = INITIATOR4_ARLEN;
      assign   INITIATOR_ARSIZE[(4+1)*3-1:4*3]                                                     = INITIATOR4_ARSIZE;
      assign   INITIATOR_ARBURST[(4+1)*2-1:4*2]                                                    = INITIATOR4_ARBURST;
      assign   INITIATOR_ARLOCK[(4+1)*2-1:4*2]                                                     = (INITIATOR4_TYPE == 2'b11) ? INITIATOR4_ARLOCK[1:0] : {1'b0, INITIATOR4_ARLOCK[0]};
      assign   INITIATOR_ARCACHE[(4+1)*4-1:4*4]                                                    = INITIATOR4_ARCACHE;
      assign   INITIATOR_ARPROT[(4+1)*3-1:4*3]                                                     = INITIATOR4_ARPROT;
      assign   INITIATOR_ARREGION[(4+1)*4-1:4*4]                                                   = MOD_INITIATOR4_ARREGION;
      assign   INITIATOR_ARQOS[(4+1)*4-1:4*4]                                                      = MOD_INITIATOR4_ARQOS;
      assign   INITIATOR_ARUSER[(4+1)*USER_WIDTH-1:4*USER_WIDTH]                                   = INITIATOR4_ARUSER;
      assign   INITIATOR_ARVALID[4]                                                                = INITIATOR4_ARVALID;
      assign   INITIATOR_AWQOS[(4+1)*4-1:4*4]                                                      = MOD_INITIATOR4_AWQOS;
      assign   INITIATOR_AWREGION[(4+1)*4-1:4*4]                                                   = MOD_INITIATOR4_AWREGION;
      assign  INITIATOR_AWID[(4+1)*ID_WIDTH-1:4*ID_WIDTH]                                          = INITIATOR4_AWID;  
      assign  INITIATOR_AWADDR[(4+1)*ADDR_WIDTH-1:4*ADDR_WIDTH]                                    = INITIATOR4_AWADDR;  
      assign  INITIATOR_AWLEN[(4+1)*8-1:4*8]                                                       = INITIATOR4_AWLEN;  
      assign  INITIATOR_AWSIZE[(4+1)*3-1:4*3]                                                      = INITIATOR4_AWSIZE;  
      assign  INITIATOR_AWBURST[(4+1)*2-1:4*2]                                                     = INITIATOR4_AWBURST;  
      assign  INITIATOR_AWLOCK[(4+1)*2-1:4*2]                                                      = (INITIATOR4_TYPE == 2'b11) ? INITIATOR4_AWLOCK[1:0] : {1'b0, INITIATOR4_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(4+1)*4-1:4*4]                                                     = INITIATOR4_AWCACHE;  
      assign  INITIATOR_AWPROT[(4+1)*3-1:4*3]                                                      = INITIATOR4_AWPROT;  
      assign  INITIATOR_AWUSER[(4+1)*USER_WIDTH-1:4*USER_WIDTH]                                    = INITIATOR4_AWUSER;  
      assign  INITIATOR_AWVALID[4]                                                                 = INITIATOR4_AWVALID;  
	  assign  INITIATOR_WID  [(4+1)*ID_WIDTH-1:4*ID_WIDTH]                                         = INITIATOR4_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(4+1)*13-1:13*4]-1:MDW_LOWER_VEC[(4+1)*13-1:13*4]]     = INITIATOR4_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(4+1)*13-1:13*4]/8-1:MDW_LOWER_VEC[(4+1)*13-1:13*4]/8] = INITIATOR4_WSTRB;  
      assign  INITIATOR_WLAST[4]                                                                   = INITIATOR4_WLAST;  
      assign  INITIATOR_WUSER[(4+1)*USER_WIDTH-1:4*USER_WIDTH]                                     = INITIATOR4_WUSER;  
      assign  INITIATOR_WVALID[4]                                                                  = INITIATOR4_WVALID;  
      assign  INITIATOR_BREADY[4]                                                                  = INITIATOR4_BREADY;  
      assign  INITIATOR_RREADY[4]                                                                  = INITIATOR4_RREADY;

      assign INITIATOR4_RID        = INITIATOR_RID[(4+1)*ID_WIDTH-1:4*ID_WIDTH];
      assign INITIATOR4_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(4+1)*13-1:13*4]-1:MDW_LOWER_VEC[(4+1)*13-1:13*4]];
      assign INITIATOR4_RRESP      = INITIATOR_RRESP[(4+1)*2-1:4*2];
      assign INITIATOR4_RUSER      = INITIATOR_RUSER[(4+1)*USER_WIDTH-1:4*USER_WIDTH];
      assign INITIATOR4_BID        = INITIATOR_BID[(4+1)*ID_WIDTH-1:4*ID_WIDTH];
      assign INITIATOR4_BRESP      = INITIATOR_BRESP[(4+1)*2-1:4*2];
      assign INITIATOR4_BUSER      = INITIATOR_BUSER[(4+1)*USER_WIDTH-1:4*USER_WIDTH];
      assign INITIATOR4_ARREADY    = INITIATOR_ARREADY[4];
      assign INITIATOR4_RLAST      = INITIATOR_RLAST[4];
      assign INITIATOR4_RVALID     = INITIATOR_RVALID[4];
      assign INITIATOR4_AWREADY    = INITIATOR_AWREADY[4];
      assign INITIATOR4_WREADY     = INITIATOR_WREADY[4];
      assign INITIATOR4_BVALID     = INITIATOR_BVALID[4];

      // AHB interface
      assign INITIATOR_HADDR[32*(4+1)-1:32*4]                                                  = INITIATOR4_HADDR;
      assign INITIATOR_HBURST[3*(4+1)-1:3*4]                                                   = INITIATOR4_HBURST;
      assign INITIATOR_HMASTLOCK[4]                                                            = INITIATOR4_HMASTLOCK;
      assign INITIATOR_HPROT[7*(4+1)-1:7*4]                                                    = INITIATOR4_HPROT;          
      assign INITIATOR_HSIZE[3*(4+1)-1:3*4]                                                    = INITIATOR4_HSIZE;
      assign INITIATOR_HNONSEC[4]                                                              = INITIATOR4_HNONSEC;
      assign INITIATOR_HTRANS[2*(4+1)-1:2*4]                                                   = INITIATOR4_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(4+1)*13-1:13*4]-1:MDW_LOWER_VEC[(4+1)*13-1:13*4]] = INITIATOR4_HWDATA;
      assign INITIATOR4_HRDATA                                                                 = INITIATOR_HRDATA[MDW_UPPER_VEC[(4+1)*13-1:13*4]-1:MDW_LOWER_VEC[(4+1)*13-1:13*4]];
      assign INITIATOR_HWRITE[4]                                                               = INITIATOR4_HWRITE;
      assign INITIATOR4_HRESP                                                                  = INITIATOR_HRESP[4];
//      assign INITIATOR4_HEXOKAY                                                              = INITIATOR_HEXOKAY[4];
//      assign INITIATOR_HEXCL[4]                                                              = INITIATOR4_HEXCL;
      assign INITIATOR_HSEL[4]                                                                 = INITIATOR4_HSEL;
      assign INITIATOR4_HREADY                                                                 = INITIATOR_HREADY[4];
    end
    
  //===================================================================================================
  // INITIATOR 5
  //===================================================================================================
  if ( NUM_INITIATORS > 5)
    begin  
      //output to initiator converter 

      assign  INITIATOR_ARID[(5+1)*ID_WIDTH-1:5*ID_WIDTH]                                          = INITIATOR5_ARID;
      assign  INITIATOR_ARADDR[(5+1)*ADDR_WIDTH-1:5*ADDR_WIDTH]                                    = INITIATOR5_ARADDR;
      assign  INITIATOR_ARLEN[(5+1)*8-1:5*8]                                                       = INITIATOR5_ARLEN;
      assign  INITIATOR_ARSIZE[(5+1)*3-1:5*3]                                                      = INITIATOR5_ARSIZE;
      assign  INITIATOR_ARBURST[(5+1)*2-1:5*2]                                                     = INITIATOR5_ARBURST;
      assign  INITIATOR_ARLOCK[(5+1)*2-1:5*2]                                                      = (INITIATOR5_TYPE == 2'b11) ? INITIATOR5_ARLOCK[1:0] : {1'b0, INITIATOR5_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(5+1)*4-1:5*4]                                                     = INITIATOR5_ARCACHE;
      assign  INITIATOR_ARPROT[(5+1)*3-1:5*3]                                                      = INITIATOR5_ARPROT;
      assign  INITIATOR_ARREGION[(5+1)*4-1:5*4]                                                    = MOD_INITIATOR5_ARREGION;
      assign  INITIATOR_ARQOS[(5+1)*4-1:5*4]                                                       = MOD_INITIATOR5_ARQOS;
      assign  INITIATOR_ARUSER[(5+1)*USER_WIDTH-1:5*USER_WIDTH]                                    = INITIATOR5_ARUSER;
      assign  INITIATOR_ARVALID[5]                                                                 = INITIATOR5_ARVALID;
      assign  INITIATOR_AWQOS[(5+1)*4-1:5*4]                                                       = MOD_INITIATOR5_AWQOS;
      assign  INITIATOR_AWREGION[(5+1)*4-1:5*4]                                                    = MOD_INITIATOR5_AWREGION;
      assign  INITIATOR_AWID[(5+1)*ID_WIDTH-1:5*ID_WIDTH]                                          = INITIATOR5_AWID;  
      assign  INITIATOR_AWADDR[(5+1)*ADDR_WIDTH-1:5*ADDR_WIDTH]                                    = INITIATOR5_AWADDR;  
      assign  INITIATOR_AWLEN[(5+1)*8-1:5*8]                                                       = INITIATOR5_AWLEN;  
      assign  INITIATOR_AWSIZE[(5+1)*3-1:5*3]                                                      = INITIATOR5_AWSIZE;  
      assign  INITIATOR_AWBURST[(5+1)*2-1:5*2]                                                     = INITIATOR5_AWBURST;  
      assign  INITIATOR_AWLOCK[(5+1)*2-1:5*2]                                                      = (INITIATOR5_TYPE == 2'b11) ? INITIATOR5_AWLOCK[1:0] : {1'b0, INITIATOR5_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(5+1)*4-1:5*4]                                                     = INITIATOR5_AWCACHE;  
      assign  INITIATOR_AWPROT[(5+1)*3-1:5*3]                                                      = INITIATOR5_AWPROT;  
      assign  INITIATOR_AWUSER[(5+1)*USER_WIDTH-1:5*USER_WIDTH]                                    = INITIATOR5_AWUSER;  
      assign  INITIATOR_AWVALID[5]                                                                 = INITIATOR5_AWVALID;  
	  assign  INITIATOR_WID  [(5+1)*ID_WIDTH-1:5*ID_WIDTH]                                         = INITIATOR5_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(5+1)*13-1:13*5]-1:MDW_LOWER_VEC[(5+1)*13-1:13*5]]     = INITIATOR5_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(5+1)*13-1:13*5]/8-1:MDW_LOWER_VEC[(5+1)*13-1:13*5]/8] = INITIATOR5_WSTRB;  
      assign  INITIATOR_WLAST[5]                                                                   = INITIATOR5_WLAST;  
      assign  INITIATOR_WUSER[(5+1)*USER_WIDTH-1:5*USER_WIDTH]                                     = INITIATOR5_WUSER;  
      assign  INITIATOR_WVALID[5]                                                                  = INITIATOR5_WVALID;  
      assign  INITIATOR_BREADY[5]                                                                  = INITIATOR5_BREADY;  
      assign  INITIATOR_RREADY[5]                                                                  = INITIATOR5_RREADY;

      assign  INITIATOR5_RID       = INITIATOR_RID[(5+1)*ID_WIDTH-1:5*ID_WIDTH];
      assign  INITIATOR5_RDATA     = INITIATOR_RDATA[MDW_UPPER_VEC[(5+1)*13-1:13*5]-1:MDW_LOWER_VEC[(5+1)*13-1:13*5]];
      assign  INITIATOR5_RRESP     = INITIATOR_RRESP[(5+1)*2-1:5*2];
      assign  INITIATOR5_RUSER     = INITIATOR_RUSER[(5+1)*USER_WIDTH-1:5*USER_WIDTH];
      assign  INITIATOR5_BID       = INITIATOR_BID[(5+1)*ID_WIDTH-1:5*ID_WIDTH];
      assign  INITIATOR5_BRESP     = INITIATOR_BRESP[(5+1)*2-1:5*2];
      assign  INITIATOR5_BUSER     = INITIATOR_BUSER[(5+1)*USER_WIDTH-1:5*USER_WIDTH];
      assign  INITIATOR5_ARREADY   = INITIATOR_ARREADY[5];
      assign  INITIATOR5_RLAST     = INITIATOR_RLAST[5];
      assign  INITIATOR5_RVALID    = INITIATOR_RVALID[5];
      assign  INITIATOR5_AWREADY   = INITIATOR_AWREADY[5];
      assign  INITIATOR5_WREADY    = INITIATOR_WREADY[5];
      assign  INITIATOR5_BVALID    = INITIATOR_BVALID[5];

      // AHB interface
      assign INITIATOR_HADDR[32*(5+1)-1:32*5]                                                  = INITIATOR5_HADDR;
      assign INITIATOR_HBURST[3*(5+1)-1:3*5]                                                   = INITIATOR5_HBURST;
      assign INITIATOR_HMASTLOCK[5]                                                            = INITIATOR5_HMASTLOCK;
      assign INITIATOR_HPROT[7*(5+1)-1:7*5]                                                    = INITIATOR5_HPROT;          
      assign INITIATOR_HSIZE[3*(5+1)-1:3*5]                                                    = INITIATOR5_HSIZE;
      assign INITIATOR_HNONSEC[5]                                                              = INITIATOR5_HNONSEC;
      assign INITIATOR_HTRANS[2*(5+1)-1:2*5]                                                   = INITIATOR5_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(5+1)*13-1:13*5]-1:MDW_LOWER_VEC[(5+1)*13-1:13*5]] = INITIATOR5_HWDATA;
      assign INITIATOR5_HRDATA                                                                 = INITIATOR_HRDATA[MDW_UPPER_VEC[(5+1)*13-1:13*5]-1:MDW_LOWER_VEC[(5+1)*13-1:13*5]];
      assign INITIATOR_HWRITE[5]                                                               = INITIATOR5_HWRITE;
      assign INITIATOR5_HRESP                                                                  = INITIATOR_HRESP[5];
//      assign INITIATOR5_HEXOKAY                                                              = INITIATOR_HEXOKAY[5];
//      assign INITIATOR_HEXCL[5]                                                              = INITIATOR5_HEXCL;
      assign INITIATOR_HSEL[5]                                                                 = INITIATOR5_HSEL;
      assign INITIATOR5_HREADY                                                                 = INITIATOR_HREADY[5];

    end
    
  //===================================================================================================
  // INITIATOR 6
  //===================================================================================================
  if ( NUM_INITIATORS > 6)
    begin  
      //output to initiator converter

      assign  INITIATOR_ARID[(6+1)*ID_WIDTH-1:6*ID_WIDTH]                                          = INITIATOR6_ARID;
      assign  INITIATOR_ARADDR[(6+1)*ADDR_WIDTH-1:6*ADDR_WIDTH]                                    = INITIATOR6_ARADDR;
      assign  INITIATOR_ARLEN[(6+1)*8-1:6*8]                                                       = INITIATOR6_ARLEN;
      assign  INITIATOR_ARSIZE[(6+1)*3-1:6*3]                                                      = INITIATOR6_ARSIZE;
      assign  INITIATOR_ARBURST[(6+1)*2-1:6*2]                                                     = INITIATOR6_ARBURST;
      assign  INITIATOR_ARLOCK[(6+1)*2-1:6*2]                                                      = (INITIATOR6_TYPE == 2'b11) ? INITIATOR6_ARLOCK[1:0] : {1'b0, INITIATOR6_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(6+1)*4-1:6*4]                                                     = INITIATOR6_ARCACHE;
      assign  INITIATOR_ARPROT[(6+1)*3-1:6*3]                                                      = INITIATOR6_ARPROT;
      assign  INITIATOR_ARREGION[(6+1)*4-1:6*4]                                                    = MOD_INITIATOR6_ARREGION;
      assign  INITIATOR_ARQOS[(6+1)*4-1:6*4]                                                       = MOD_INITIATOR6_ARQOS;
      assign  INITIATOR_ARUSER[(6+1)*USER_WIDTH-1:6*USER_WIDTH]                                    = INITIATOR6_ARUSER;
      assign  INITIATOR_ARVALID[6]                                                                 = INITIATOR6_ARVALID;
      assign  INITIATOR_AWQOS[(6+1)*4-1:6*4]                                                       = MOD_INITIATOR6_AWQOS;
      assign  INITIATOR_AWREGION[(6+1)*4-1:6*4]                                                    = MOD_INITIATOR6_AWREGION;
      assign  INITIATOR_AWID[(6+1)*ID_WIDTH-1:6*ID_WIDTH]                                          = INITIATOR6_AWID;  
      assign  INITIATOR_AWADDR[(6+1)*ADDR_WIDTH-1:6*ADDR_WIDTH]                                    = INITIATOR6_AWADDR;  
      assign  INITIATOR_AWLEN[(6+1)*8-1:6*8]                                                       = INITIATOR6_AWLEN;  
      assign  INITIATOR_AWSIZE[(6+1)*3-1:6*3]                                                      = INITIATOR6_AWSIZE;  
      assign  INITIATOR_AWBURST[(6+1)*2-1:6*2]                                                     = INITIATOR6_AWBURST;  
      assign  INITIATOR_AWLOCK[(6+1)*2-1:6*2]                                                      = (INITIATOR6_TYPE == 2'b11) ? INITIATOR6_AWLOCK[1:0] : {1'b0, INITIATOR6_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(6+1)*4-1:6*4]                                                     = INITIATOR6_AWCACHE;  
      assign  INITIATOR_AWPROT[(6+1)*3-1:6*3]                                                      = INITIATOR6_AWPROT;  
      assign  INITIATOR_AWUSER[(6+1)*USER_WIDTH-1:6*USER_WIDTH]                                    = INITIATOR6_AWUSER;  
      assign  INITIATOR_AWVALID[6]                                                                 = INITIATOR6_AWVALID;  
	  assign  INITIATOR_WID  [(6+1)*ID_WIDTH-1:6*ID_WIDTH]                                         = INITIATOR6_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(6+1)*13-1:13*6]-1:MDW_LOWER_VEC[(6+1)*13-1:13*6]]     = INITIATOR6_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(6+1)*13-1:13*6]/8-1:MDW_LOWER_VEC[(6+1)*13-1:13*6]/8] = INITIATOR6_WSTRB;  
      assign  INITIATOR_WLAST[6]                                                                   = INITIATOR6_WLAST;  
      assign  INITIATOR_WUSER[(6+1)*USER_WIDTH-1:6*USER_WIDTH]                                     = INITIATOR6_WUSER;  
      assign  INITIATOR_WVALID[6]                                                                  = INITIATOR6_WVALID;  
      assign  INITIATOR_BREADY[6]                                                                  = INITIATOR6_BREADY;  
      assign  INITIATOR_RREADY[6]                                                                  = INITIATOR6_RREADY;

      assign INITIATOR6_RID        = INITIATOR_RID[(6+1)*ID_WIDTH-1:6*ID_WIDTH];
      assign INITIATOR6_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(6+1)*13-1:13*6]-1:MDW_LOWER_VEC[(6+1)*13-1:13*6]];
      assign INITIATOR6_RRESP      = INITIATOR_RRESP[(6+1)*2-1:6*2];
      assign INITIATOR6_RUSER      = INITIATOR_RUSER[(6+1)*USER_WIDTH-1:6*USER_WIDTH];
      assign INITIATOR6_BID        = INITIATOR_BID[(6+1)*ID_WIDTH-1:6*ID_WIDTH];
      assign INITIATOR6_BRESP      = INITIATOR_BRESP[(6+1)*2-1:6*2];
      assign INITIATOR6_BUSER      = INITIATOR_BUSER[(6+1)*USER_WIDTH-1:6*USER_WIDTH];
      assign INITIATOR6_ARREADY    = INITIATOR_ARREADY[6];
      assign INITIATOR6_RLAST      = INITIATOR_RLAST[6];
      assign INITIATOR6_RVALID     = INITIATOR_RVALID[6];
      assign INITIATOR6_AWREADY    = INITIATOR_AWREADY[6];
      assign INITIATOR6_WREADY     = INITIATOR_WREADY[6];
      assign INITIATOR6_BVALID     = INITIATOR_BVALID[6];

      // AHB interface
      assign INITIATOR_HADDR[32*(6+1)-1:32*6]                                                  = INITIATOR6_HADDR;
      assign INITIATOR_HBURST[3*(6+1)-1:3*6]                                                   = INITIATOR6_HBURST;
      assign INITIATOR_HMASTLOCK[6]                                                            = INITIATOR6_HMASTLOCK;
      assign INITIATOR_HPROT[7*(6+1)-1:7*6]                                                    = INITIATOR6_HPROT;          
      assign INITIATOR_HSIZE[3*(6+1)-1:3*6]                                                    = INITIATOR6_HSIZE;
      assign INITIATOR_HNONSEC[6]                                                              = INITIATOR6_HNONSEC;
      assign INITIATOR_HTRANS[2*(6+1)-1:2*6]                                                   = INITIATOR6_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(6+1)*13-1:13*6]-1:MDW_LOWER_VEC[(6+1)*13-1:13*6]] = INITIATOR6_HWDATA;
      assign INITIATOR6_HRDATA                                                                 = INITIATOR_HRDATA[MDW_UPPER_VEC[(6+1)*13-1:13*6]-1:MDW_LOWER_VEC[(6+1)*13-1:13*6]];
      assign INITIATOR_HWRITE[6]                                                               = INITIATOR6_HWRITE;
      assign INITIATOR6_HRESP                                                                  = INITIATOR_HRESP[6];
//      assign INITIATOR6_HEXOKAY                                                              = INITIATOR_HEXOKAY[6];
//      assign INITIATOR_HEXCL[6]                                                              = INITIATOR6_HEXCL;
      assign INITIATOR_HSEL[6]                                                                 = INITIATOR6_HSEL;
      assign INITIATOR6_HREADY                                                                 = INITIATOR_HREADY[6];

    end
    
  //===================================================================================================
  // INITIATOR 7
  //===================================================================================================
  if ( NUM_INITIATORS > 7 )
    begin  
      //output to initiator converter
      
      assign  INITIATOR_ARID[(7+1)*ID_WIDTH-1:7*ID_WIDTH]                                          = INITIATOR7_ARID;
      assign  INITIATOR_ARADDR[(7+1)*ADDR_WIDTH-1:7*ADDR_WIDTH]                                    = INITIATOR7_ARADDR;
      assign  INITIATOR_ARLEN[(7+1)*8-1:7*8]                                                       = INITIATOR7_ARLEN;
      assign  INITIATOR_ARSIZE[(7+1)*3-1:7*3]                                                      = INITIATOR7_ARSIZE;
      assign  INITIATOR_ARBURST[(7+1)*2-1:7*2]                                                     = INITIATOR7_ARBURST;
      assign  INITIATOR_ARLOCK[(7+1)*2-1:7*2]                                                      = (INITIATOR7_TYPE == 2'b11) ? INITIATOR7_ARLOCK[1:0] : {1'b0, INITIATOR7_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(7+1)*4-1:7*4]                                                     = INITIATOR7_ARCACHE;
      assign  INITIATOR_ARPROT[(7+1)*3-1:7*3]                                                      = INITIATOR7_ARPROT;
      assign  INITIATOR_ARREGION[(7+1)*4-1:7*4]                                                    = MOD_INITIATOR7_ARREGION;
      assign  INITIATOR_ARQOS[(7+1)*4-1:7*4]                                                       = MOD_INITIATOR7_ARQOS;
      assign  INITIATOR_ARUSER[(7+1)*USER_WIDTH-1:7*USER_WIDTH]                                    = INITIATOR7_ARUSER;
      assign  INITIATOR_ARVALID[7]                                                                 = INITIATOR7_ARVALID;
      assign  INITIATOR_AWQOS[(7+1)*4-1:7*4]                                                       = MOD_INITIATOR7_AWQOS;
      assign  INITIATOR_AWREGION[(7+1)*4-1:7*4]                                                    = MOD_INITIATOR7_AWREGION;
      assign  INITIATOR_AWID[(7+1)*ID_WIDTH-1:7*ID_WIDTH]                                          = INITIATOR7_AWID;  
      assign  INITIATOR_AWADDR[(7+1)*ADDR_WIDTH-1:7*ADDR_WIDTH]                                    = INITIATOR7_AWADDR;  
      assign  INITIATOR_AWLEN[(7+1)*8-1:7*8]                                                       = INITIATOR7_AWLEN;  
      assign  INITIATOR_AWSIZE[(7+1)*3-1:7*3]                                                      = INITIATOR7_AWSIZE;  
      assign  INITIATOR_AWBURST[(7+1)*2-1:7*2]                                                     = INITIATOR7_AWBURST;  
      assign  INITIATOR_AWLOCK[(7+1)*2-1:7*2]                                                      = (INITIATOR7_TYPE == 2'b11) ? INITIATOR7_AWLOCK[1:0] : {1'b0, INITIATOR7_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(7+1)*4-1:7*4]                                                     = INITIATOR7_AWCACHE;  
      assign  INITIATOR_AWPROT[(7+1)*3-1:7*3]                                                      = INITIATOR7_AWPROT;  
      assign  INITIATOR_AWUSER[(7+1)*USER_WIDTH-1:7*USER_WIDTH]                                    = INITIATOR7_AWUSER;  
      assign  INITIATOR_AWVALID[7]                                                                 = INITIATOR7_AWVALID;  
	  assign  INITIATOR_WID  [(7+1)*ID_WIDTH-1:7*ID_WIDTH]                                         = INITIATOR7_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(7+1)*13-1:13*7]-1:MDW_LOWER_VEC[(7+1)*13-1:13*7]]     = INITIATOR7_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(7+1)*13-1:13*7]/8-1:MDW_LOWER_VEC[(7+1)*13-1:13*7]/8] = INITIATOR7_WSTRB;  
      assign  INITIATOR_WLAST[7]                                                                   = INITIATOR7_WLAST;  
      assign  INITIATOR_WUSER[(7+1)*USER_WIDTH-1:7*USER_WIDTH]                                     = INITIATOR7_WUSER;  
      assign  INITIATOR_WVALID[7]                                                                  = INITIATOR7_WVALID;  
      assign  INITIATOR_BREADY[7]                                                                  = INITIATOR7_BREADY;  
      assign  INITIATOR_RREADY[7]                                                                  = INITIATOR7_RREADY;

      assign   INITIATOR7_RID      = INITIATOR_RID[(7+1)*ID_WIDTH-1:7*ID_WIDTH];
      assign   INITIATOR7_RDATA    = INITIATOR_RDATA[MDW_UPPER_VEC[(7+1)*13-1:13*7]-1:MDW_LOWER_VEC[(7+1)*13-1:13*7]];
      assign   INITIATOR7_RRESP    = INITIATOR_RRESP[(7+1)*2-1:7*2];
      assign   INITIATOR7_RUSER    = INITIATOR_RUSER[(7+1)*USER_WIDTH-1:7*USER_WIDTH];
      assign   INITIATOR7_BID      = INITIATOR_BID[(7+1)*ID_WIDTH-1:7*ID_WIDTH];
      assign   INITIATOR7_BRESP    = INITIATOR_BRESP[(7+1)*2-1:7*2];
      assign   INITIATOR7_BUSER    = INITIATOR_BUSER[(7+1)*USER_WIDTH-1:7*USER_WIDTH];
      assign   INITIATOR7_ARREADY  = INITIATOR_ARREADY[7];
      assign   INITIATOR7_RLAST    = INITIATOR_RLAST[7];
      assign   INITIATOR7_RVALID   = INITIATOR_RVALID[7];
      assign   INITIATOR7_AWREADY  = INITIATOR_AWREADY[7];
      assign   INITIATOR7_WREADY   = INITIATOR_WREADY[7];
      assign   INITIATOR7_BVALID   = INITIATOR_BVALID[7];

      // AHB interface
      assign INITIATOR_HADDR[32*(7+1)-1:32*7]                                                  = INITIATOR7_HADDR;
      assign INITIATOR_HBURST[3*(7+1)-1:3*7]                                                   = INITIATOR7_HBURST;
      assign INITIATOR_HMASTLOCK[7]                                                            = INITIATOR7_HMASTLOCK;
      assign INITIATOR_HPROT[7*(7+1)-1:7*7]                                                    = INITIATOR7_HPROT;          
      assign INITIATOR_HSIZE[3*(7+1)-1:3*7]                                                    = INITIATOR7_HSIZE;
      assign INITIATOR_HNONSEC[7]                                                              = INITIATOR7_HNONSEC;
      assign INITIATOR_HTRANS[2*(7+1)-1:2*7]                                                   = INITIATOR7_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(7+1)*13-1:13*7]-1:MDW_LOWER_VEC[(7+1)*13-1:13*7]] = INITIATOR7_HWDATA;
      assign INITIATOR7_HRDATA                                                                 = INITIATOR_HRDATA[MDW_UPPER_VEC[(7+1)*13-1:13*7]-1:MDW_LOWER_VEC[(7+1)*13-1:13*7]];
      assign INITIATOR_HWRITE[7]                                                               = INITIATOR7_HWRITE;
      assign INITIATOR7_HRESP                                                                  = INITIATOR_HRESP[7];
//      assign INITIATOR7_HEXOKAY                                                              = INITIATOR_HEXOKAY[7];
//      assign INITIATOR_HEXCL[7]                                                              = INITIATOR7_HEXCL;
      assign INITIATOR_HSEL[7]                                                                 = INITIATOR7_HSEL;
      assign INITIATOR7_HREADY                                                                 = INITIATOR_HREADY[7];

    end
      
	  
  //===================================================================================================
  // INITIATOR 8
  //===================================================================================================
  if ( NUM_INITIATORS > 8)
    begin
      //output to initiator converter
      assign  INITIATOR_ARID[(8+1)*ID_WIDTH-1:8*ID_WIDTH]                                                  = INITIATOR8_ARID;
      assign  INITIATOR_ARADDR[(8+1)*ADDR_WIDTH-1:8*ADDR_WIDTH]                                            = INITIATOR8_ARADDR;
      assign  INITIATOR_ARLEN[(8+1)*8-1:8*8]                                                               = INITIATOR8_ARLEN;
      assign  INITIATOR_ARSIZE[(8+1)*3-1:8*3]                                                              = INITIATOR8_ARSIZE;
      assign  INITIATOR_ARBURST[(8+1)*2-1:8*2]                                                             = INITIATOR8_ARBURST;
      assign  INITIATOR_ARLOCK[(8+1)*2-1:8*2]                                                              = (INITIATOR8_TYPE == 2'b11) ? INITIATOR8_ARLOCK[1:0] : {1'b0, INITIATOR8_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(8+1)*4-1:8*4]                                                             = INITIATOR8_ARCACHE;
      assign  INITIATOR_ARPROT[(8+1)*3-1:8*3]                                                              = INITIATOR8_ARPROT;
      assign  INITIATOR_ARREGION[(8+1)*4-1:8*4]                                                            = MOD_INITIATOR8_ARREGION;
      assign  INITIATOR_ARQOS[(8+1)*4-1:8*4]                                                               = MOD_INITIATOR8_ARQOS;
      assign  INITIATOR_ARUSER[(8+1)*USER_WIDTH-1:8*USER_WIDTH]                                            = INITIATOR8_ARUSER;
      assign  INITIATOR_ARVALID[8]                                                                         = INITIATOR8_ARVALID;
      assign  INITIATOR_AWQOS[(8+1)*4-1:8*4]                                                               = MOD_INITIATOR8_AWQOS;
      assign  INITIATOR_AWREGION[(8+1)*4-1:8*4]                                                            = MOD_INITIATOR8_AWREGION;
      assign  INITIATOR_AWID[(8+1)*ID_WIDTH-1:8*ID_WIDTH]                                                  = INITIATOR8_AWID;  
      assign  INITIATOR_AWADDR[(8+1)*ADDR_WIDTH-1:8*ADDR_WIDTH]                                            = INITIATOR8_AWADDR;  
      assign  INITIATOR_AWLEN[(8+1)*8-1:8*8]                                                               = INITIATOR8_AWLEN;  
      assign  INITIATOR_AWSIZE[(8+1)*3-1:8*3]                                                              = INITIATOR8_AWSIZE;  
      assign  INITIATOR_AWBURST[(8+1)*2-1:8*2]                                                             = INITIATOR8_AWBURST;  
      assign  INITIATOR_AWLOCK[(8+1)*2-1:8*2]                                                              = (INITIATOR8_TYPE == 2'b11) ? INITIATOR8_AWLOCK[1:0] : {1'b0, INITIATOR8_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(8+1)*4-1:8*4]                                                             = INITIATOR8_AWCACHE;  
      assign  INITIATOR_AWPROT[(8+1)*3-1:8*3]                                                              = INITIATOR8_AWPROT;  
      assign  INITIATOR_AWUSER[(8+1)*USER_WIDTH-1:8*USER_WIDTH]                                            = INITIATOR8_AWUSER;  
      assign  INITIATOR_AWVALID[8]                                                                         = INITIATOR8_AWVALID;  
      assign  INITIATOR_WID  [(8+1)*ID_WIDTH-1:8*ID_WIDTH]                                                 = INITIATOR8_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(8+1)*13-1:13*8]-1:MDW_LOWER_VEC[(8+1)*13-1:13*8]]             = INITIATOR8_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(8+1)*13-1:13*8]/8-1:MDW_LOWER_VEC[(8+1)*13-1:13*8]/8]         = INITIATOR8_WSTRB;  
      assign  INITIATOR_WLAST[8]                                                                           = INITIATOR8_WLAST;  
      assign  INITIATOR_WUSER[(8+1)*USER_WIDTH-1:8*USER_WIDTH]                                             = INITIATOR8_WUSER;  
      assign  INITIATOR_WVALID[8]                                                                          = INITIATOR8_WVALID;  
      assign  INITIATOR_BREADY[8]                                                                          = INITIATOR8_BREADY;  
      assign  INITIATOR_RREADY[8]                                                                          = INITIATOR8_RREADY;
      
      assign INITIATOR8_RID        = INITIATOR_RID[(8+1)*ID_WIDTH-1:8*ID_WIDTH];
      assign INITIATOR8_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(8+1)*13-1:13*8]-1:MDW_LOWER_VEC[(8+1)*13-1:13*8]];
      assign INITIATOR8_RRESP      = INITIATOR_RRESP[(8+1)*2-1:8*2];
      assign INITIATOR8_RUSER      = INITIATOR_RUSER[(8+1)*USER_WIDTH-1:8*USER_WIDTH];
      assign INITIATOR8_BID        = INITIATOR_BID[(8+1)*ID_WIDTH-1:8*ID_WIDTH];
      assign INITIATOR8_BRESP      = INITIATOR_BRESP[(8+1)*2-1:8*2];
      assign INITIATOR8_BUSER      = INITIATOR_BUSER[(8+1)*USER_WIDTH-1:8*USER_WIDTH];
      assign INITIATOR8_ARREADY    = INITIATOR_ARREADY[8];
      assign INITIATOR8_RLAST      = INITIATOR_RLAST[8];
      assign INITIATOR8_RVALID     = INITIATOR_RVALID[8];
      assign INITIATOR8_AWREADY    = INITIATOR_AWREADY[8];
      assign INITIATOR8_WREADY     = INITIATOR_WREADY[8];
      assign INITIATOR8_BVALID     = INITIATOR_BVALID[8];
      
      // AHB interface
      assign INITIATOR_HADDR[32*(8+1)-1:32*8]                                                         = INITIATOR8_HADDR;
      assign INITIATOR_HBURST[3*(8+1)-1:3*8]                                                          = INITIATOR8_HBURST;
      assign INITIATOR_HMASTLOCK[8]                                                                   = INITIATOR8_HMASTLOCK;
      assign INITIATOR_HPROT[7*(8+1)-1:7*8]                                                           = INITIATOR8_HPROT;          
      assign INITIATOR_HSIZE[3*(8+1)-1:3*8]                                                           = INITIATOR8_HSIZE;
      assign INITIATOR_HNONSEC[8]                                                                     = INITIATOR8_HNONSEC;
      assign INITIATOR_HTRANS[2*(8+1)-1:2*8]                                                          = INITIATOR8_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(8+1)*13-1:13*8]-1:MDW_LOWER_VEC[(8+1)*13-1:13*8]]        = INITIATOR8_HWDATA;
      assign INITIATOR8_HRDATA                                                                        = INITIATOR_HRDATA[MDW_UPPER_VEC[(8+1)*13-1:13*8]-1:MDW_LOWER_VEC[(8+1)*13-1:13*8]];
      assign INITIATOR_HWRITE[8]                                                                      = INITIATOR8_HWRITE;
      assign INITIATOR8_HRESP                                                                         = INITIATOR_HRESP[8];
//      assign INITIATOR8_HEXOKAY                                                                     = INITIATOR_HEXOKAY[8];
//      assign INITIATOR_HEXCL[8]                                                                     = INITIATOR8_HEXCL;
      assign INITIATOR_HSEL[8]                                                                        = INITIATOR8_HSEL;
      assign INITIATOR8_HREADY                                                                        = INITIATOR_HREADY[8];
    end
    
  //===================================================================================================
  // INITIATOR 9
  //===================================================================================================
  if ( NUM_INITIATORS > 9)
    begin
      //output to initiator converter
      assign  INITIATOR_ARID[(9+1)*ID_WIDTH-1:9*ID_WIDTH]                                                  = INITIATOR9_ARID;
      assign  INITIATOR_ARADDR[(9+1)*ADDR_WIDTH-1:9*ADDR_WIDTH]                                            = INITIATOR9_ARADDR;
      assign  INITIATOR_ARLEN[(9+1)*8-1:9*8]                                                               = INITIATOR9_ARLEN;
      assign  INITIATOR_ARSIZE[(9+1)*3-1:9*3]                                                              = INITIATOR9_ARSIZE;
      assign  INITIATOR_ARBURST[(9+1)*2-1:9*2]                                                             = INITIATOR9_ARBURST;
      assign  INITIATOR_ARLOCK[(9+1)*2-1:9*2]                                                              = (INITIATOR9_TYPE == 2'b11) ? INITIATOR9_ARLOCK[1:0] : {1'b0, INITIATOR9_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(9+1)*4-1:9*4]                                                             = INITIATOR9_ARCACHE;
      assign  INITIATOR_ARPROT[(9+1)*3-1:9*3]                                                              = INITIATOR9_ARPROT;
      assign  INITIATOR_ARREGION[(9+1)*4-1:9*4]                                                            = MOD_INITIATOR9_ARREGION;
      assign  INITIATOR_ARQOS[(9+1)*4-1:9*4]                                                               = MOD_INITIATOR9_ARQOS;
      assign  INITIATOR_ARUSER[(9+1)*USER_WIDTH-1:9*USER_WIDTH]                                            = INITIATOR9_ARUSER;
      assign  INITIATOR_ARVALID[9]                                                                         = INITIATOR9_ARVALID;
      assign  INITIATOR_AWQOS[(9+1)*4-1:9*4]                                                               = MOD_INITIATOR9_AWQOS;
      assign  INITIATOR_AWREGION[(9+1)*4-1:9*4]                                                            = MOD_INITIATOR9_AWREGION;
      assign  INITIATOR_AWID[(9+1)*ID_WIDTH-1:9*ID_WIDTH]                                                  = INITIATOR9_AWID;  
      assign  INITIATOR_AWADDR[(9+1)*ADDR_WIDTH-1:9*ADDR_WIDTH]                                            = INITIATOR9_AWADDR;  
      assign  INITIATOR_AWLEN[(9+1)*8-1:9*8]                                                               = INITIATOR9_AWLEN;  
      assign  INITIATOR_AWSIZE[(9+1)*3-1:9*3]                                                              = INITIATOR9_AWSIZE;  
      assign  INITIATOR_AWBURST[(9+1)*2-1:9*2]                                                             = INITIATOR9_AWBURST;  
      assign  INITIATOR_AWLOCK[(9+1)*2-1:9*2]                                                              = (INITIATOR9_TYPE == 2'b11) ? INITIATOR9_AWLOCK[1:0] : {1'b0, INITIATOR9_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(9+1)*4-1:9*4]                                                             = INITIATOR9_AWCACHE;  
      assign  INITIATOR_AWPROT[(9+1)*3-1:9*3]                                                              = INITIATOR9_AWPROT;  
      assign  INITIATOR_AWUSER[(9+1)*USER_WIDTH-1:9*USER_WIDTH]                                            = INITIATOR9_AWUSER;  
      assign  INITIATOR_AWVALID[9]                                                                         = INITIATOR9_AWVALID;  
      assign  INITIATOR_WID  [(9+1)*ID_WIDTH-1:9*ID_WIDTH]                                                 = INITIATOR9_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(9+1)*13-1:13*9]-1:MDW_LOWER_VEC[(9+1)*13-1:13*9]]             = INITIATOR9_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(9+1)*13-1:13*9]/8-1:MDW_LOWER_VEC[(9+1)*13-1:13*9]/8]         = INITIATOR9_WSTRB;  
      assign  INITIATOR_WLAST[9]                                                                           = INITIATOR9_WLAST;  
      assign  INITIATOR_WUSER[(9+1)*USER_WIDTH-1:9*USER_WIDTH]                                             = INITIATOR9_WUSER;  
      assign  INITIATOR_WVALID[9]                                                                          = INITIATOR9_WVALID;  
      assign  INITIATOR_BREADY[9]                                                                          = INITIATOR9_BREADY;  
      assign  INITIATOR_RREADY[9]                                                                          = INITIATOR9_RREADY;
      
      assign INITIATOR9_RID        = INITIATOR_RID[(9+1)*ID_WIDTH-1:9*ID_WIDTH];
      assign INITIATOR9_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(9+1)*13-1:13*9]-1:MDW_LOWER_VEC[(9+1)*13-1:13*9]];
      assign INITIATOR9_RRESP      = INITIATOR_RRESP[(9+1)*2-1:9*2];
      assign INITIATOR9_RUSER      = INITIATOR_RUSER[(9+1)*USER_WIDTH-1:9*USER_WIDTH];
      assign INITIATOR9_BID        = INITIATOR_BID[(9+1)*ID_WIDTH-1:9*ID_WIDTH];
      assign INITIATOR9_BRESP      = INITIATOR_BRESP[(9+1)*2-1:9*2];
      assign INITIATOR9_BUSER      = INITIATOR_BUSER[(9+1)*USER_WIDTH-1:9*USER_WIDTH];
      assign INITIATOR9_ARREADY    = INITIATOR_ARREADY[9];
      assign INITIATOR9_RLAST      = INITIATOR_RLAST[9];
      assign INITIATOR9_RVALID     = INITIATOR_RVALID[9];
      assign INITIATOR9_AWREADY    = INITIATOR_AWREADY[9];
      assign INITIATOR9_WREADY     = INITIATOR_WREADY[9];
      assign INITIATOR9_BVALID     = INITIATOR_BVALID[9];
      
      // AHB interface
      assign INITIATOR_HADDR[32*(9+1)-1:32*9]                                                         = INITIATOR9_HADDR;
      assign INITIATOR_HBURST[3*(9+1)-1:3*9]                                                          = INITIATOR9_HBURST;
      assign INITIATOR_HMASTLOCK[9]                                                                   = INITIATOR9_HMASTLOCK;
      assign INITIATOR_HPROT[7*(9+1)-1:7*9]                                                           = INITIATOR9_HPROT;          
      assign INITIATOR_HSIZE[3*(9+1)-1:3*9]                                                           = INITIATOR9_HSIZE;
      assign INITIATOR_HNONSEC[9]                                                                     = INITIATOR9_HNONSEC;
      assign INITIATOR_HTRANS[2*(9+1)-1:2*9]                                                          = INITIATOR9_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(9+1)*13-1:13*9]-1:MDW_LOWER_VEC[(9+1)*13-1:13*9]]        = INITIATOR9_HWDATA;
      assign INITIATOR9_HRDATA                                                                        = INITIATOR_HRDATA[MDW_UPPER_VEC[(9+1)*13-1:13*9]-1:MDW_LOWER_VEC[(9+1)*13-1:13*9]];
      assign INITIATOR_HWRITE[9]                                                                      = INITIATOR9_HWRITE;
      assign INITIATOR9_HRESP                                                                         = INITIATOR_HRESP[9];
//      assign INITIATOR9_HEXOKAY                                                                     = INITIATOR_HEXOKAY[9];
//      assign INITIATOR_HEXCL[9]                                                                     = INITIATOR9_HEXCL;
      assign INITIATOR_HSEL[9]                                                                        = INITIATOR9_HSEL;
      assign INITIATOR9_HREADY                                                                        = INITIATOR_HREADY[9];
    end
    
  //===================================================================================================
  // INITIATOR 10
  //===================================================================================================
  if ( NUM_INITIATORS > 10)
    begin
      //output to initiator converter
      assign  INITIATOR_ARID[(10+1)*ID_WIDTH-1:10*ID_WIDTH]                                                    = INITIATOR10_ARID;
      assign  INITIATOR_ARADDR[(10+1)*ADDR_WIDTH-1:10*ADDR_WIDTH]                                              = INITIATOR10_ARADDR;
      assign  INITIATOR_ARLEN[(10+1)*8-1:10*8]                                                                 = INITIATOR10_ARLEN;
      assign  INITIATOR_ARSIZE[(10+1)*3-1:10*3]                                                                = INITIATOR10_ARSIZE;
      assign  INITIATOR_ARBURST[(10+1)*2-1:10*2]                                                               = INITIATOR10_ARBURST;
      assign  INITIATOR_ARLOCK[(10+1)*2-1:10*2]                                                                = (INITIATOR10_TYPE == 2'b11) ? INITIATOR10_ARLOCK[1:0] : {1'b0, INITIATOR10_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(10+1)*4-1:10*4]                                                               = INITIATOR10_ARCACHE;
      assign  INITIATOR_ARPROT[(10+1)*3-1:10*3]                                                                = INITIATOR10_ARPROT;
      assign  INITIATOR_ARREGION[(10+1)*4-1:10*4]                                                              = MOD_INITIATOR10_ARREGION;
      assign  INITIATOR_ARQOS[(10+1)*4-1:10*4]                                                                 = MOD_INITIATOR10_ARQOS;
      assign  INITIATOR_ARUSER[(10+1)*USER_WIDTH-1:10*USER_WIDTH]                                              = INITIATOR10_ARUSER;
      assign  INITIATOR_ARVALID[10]                                                                            = INITIATOR10_ARVALID;
      assign  INITIATOR_AWQOS[(10+1)*4-1:10*4]                                                                 = MOD_INITIATOR10_AWQOS;
      assign  INITIATOR_AWREGION[(10+1)*4-1:10*4]                                                              = MOD_INITIATOR10_AWREGION;
      assign  INITIATOR_AWID[(10+1)*ID_WIDTH-1:10*ID_WIDTH]                                                    = INITIATOR10_AWID;  
      assign  INITIATOR_AWADDR[(10+1)*ADDR_WIDTH-1:10*ADDR_WIDTH]                                              = INITIATOR10_AWADDR;  
      assign  INITIATOR_AWLEN[(10+1)*8-1:10*8]                                                                 = INITIATOR10_AWLEN;  
      assign  INITIATOR_AWSIZE[(10+1)*3-1:10*3]                                                                = INITIATOR10_AWSIZE;  
      assign  INITIATOR_AWBURST[(10+1)*2-1:10*2]                                                               = INITIATOR10_AWBURST;  
      assign  INITIATOR_AWLOCK[(10+1)*2-1:10*2]                                                                = (INITIATOR10_TYPE == 2'b11) ? INITIATOR10_AWLOCK[1:0] : {1'b0, INITIATOR10_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(10+1)*4-1:10*4]                                                               = INITIATOR10_AWCACHE;  
      assign  INITIATOR_AWPROT[(10+1)*3-1:10*3]                                                                = INITIATOR10_AWPROT;  
      assign  INITIATOR_AWUSER[(10+1)*USER_WIDTH-1:10*USER_WIDTH]                                              = INITIATOR10_AWUSER;  
      assign  INITIATOR_AWVALID[10]                                                                            = INITIATOR10_AWVALID;  
      assign  INITIATOR_WID  [(10+1)*ID_WIDTH-1:10*ID_WIDTH]                                                   = INITIATOR10_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(10+1)*13-1:13*10]-1:MDW_LOWER_VEC[(10+1)*13-1:13*10]]             = INITIATOR10_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(10+1)*13-1:13*10]/8-1:MDW_LOWER_VEC[(10+1)*13-1:13*10]/8]         = INITIATOR10_WSTRB;  
      assign  INITIATOR_WLAST[10]                                                                              = INITIATOR10_WLAST;  
      assign  INITIATOR_WUSER[(10+1)*USER_WIDTH-1:10*USER_WIDTH]                                               = INITIATOR10_WUSER;  
      assign  INITIATOR_WVALID[10]                                                                             = INITIATOR10_WVALID;  
      assign  INITIATOR_BREADY[10]                                                                             = INITIATOR10_BREADY;  
      assign  INITIATOR_RREADY[10]                                                                             = INITIATOR10_RREADY;
      
      assign INITIATOR10_RID        = INITIATOR_RID[(10+1)*ID_WIDTH-1:10*ID_WIDTH];
      assign INITIATOR10_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(10+1)*13-1:13*10]-1:MDW_LOWER_VEC[(10+1)*13-1:13*10]];
      assign INITIATOR10_RRESP      = INITIATOR_RRESP[(10+1)*2-1:10*2];
      assign INITIATOR10_RUSER      = INITIATOR_RUSER[(10+1)*USER_WIDTH-1:10*USER_WIDTH];
      assign INITIATOR10_BID        = INITIATOR_BID[(10+1)*ID_WIDTH-1:10*ID_WIDTH];
      assign INITIATOR10_BRESP      = INITIATOR_BRESP[(10+1)*2-1:10*2];
      assign INITIATOR10_BUSER      = INITIATOR_BUSER[(10+1)*USER_WIDTH-1:10*USER_WIDTH];
      assign INITIATOR10_ARREADY    = INITIATOR_ARREADY[10];
      assign INITIATOR10_RLAST      = INITIATOR_RLAST[10];
      assign INITIATOR10_RVALID     = INITIATOR_RVALID[10];
      assign INITIATOR10_AWREADY    = INITIATOR_AWREADY[10];
      assign INITIATOR10_WREADY     = INITIATOR_WREADY[10];
      assign INITIATOR10_BVALID     = INITIATOR_BVALID[10];
      
      // AHB interface
      assign INITIATOR_HADDR[32*(10+1)-1:32*10]                                                           = INITIATOR10_HADDR;
      assign INITIATOR_HBURST[3*(10+1)-1:3*10]                                                            = INITIATOR10_HBURST;
      assign INITIATOR_HMASTLOCK[10]                                                                      = INITIATOR10_HMASTLOCK;
      assign INITIATOR_HPROT[7*(10+1)-1:7*10]                                                             = INITIATOR10_HPROT;          
      assign INITIATOR_HSIZE[3*(10+1)-1:3*10]                                                             = INITIATOR10_HSIZE;
      assign INITIATOR_HNONSEC[10]                                                                        = INITIATOR10_HNONSEC;
      assign INITIATOR_HTRANS[2*(10+1)-1:2*10]                                                            = INITIATOR10_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(10+1)*13-1:13*10]-1:MDW_LOWER_VEC[(10+1)*13-1:13*10]]        = INITIATOR10_HWDATA;
      assign INITIATOR10_HRDATA                                                                           = INITIATOR_HRDATA[MDW_UPPER_VEC[(10+1)*13-1:13*10]-1:MDW_LOWER_VEC[(10+1)*13-1:13*10]];
      assign INITIATOR_HWRITE[10]                                                                         = INITIATOR10_HWRITE;
      assign INITIATOR10_HRESP                                                                            = INITIATOR_HRESP[10];
//      assign INITIATOR10_HEXOKAY                                                                        = INITIATOR_HEXOKAY[10];
//      assign INITIATOR_HEXCL[10]                                                                        = INITIATOR10_HEXCL;
      assign INITIATOR_HSEL[10]                                                                           = INITIATOR10_HSEL;
      assign INITIATOR10_HREADY                                                                           = INITIATOR_HREADY[10];
    end
    
  //===================================================================================================
  // INITIATOR 11
  //===================================================================================================
  if ( NUM_INITIATORS > 11)
    begin
      //output to initiator converter
      assign  INITIATOR_ARID[(11+1)*ID_WIDTH-1:11*ID_WIDTH]                                                    = INITIATOR11_ARID;
      assign  INITIATOR_ARADDR[(11+1)*ADDR_WIDTH-1:11*ADDR_WIDTH]                                              = INITIATOR11_ARADDR;
      assign  INITIATOR_ARLEN[(11+1)*8-1:11*8]                                                                 = INITIATOR11_ARLEN;
      assign  INITIATOR_ARSIZE[(11+1)*3-1:11*3]                                                                = INITIATOR11_ARSIZE;
      assign  INITIATOR_ARBURST[(11+1)*2-1:11*2]                                                               = INITIATOR11_ARBURST;
      assign  INITIATOR_ARLOCK[(11+1)*2-1:11*2]                                                                = (INITIATOR11_TYPE == 2'b11) ? INITIATOR11_ARLOCK[1:0] : {1'b0, INITIATOR11_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(11+1)*4-1:11*4]                                                               = INITIATOR11_ARCACHE;
      assign  INITIATOR_ARPROT[(11+1)*3-1:11*3]                                                                = INITIATOR11_ARPROT;
      assign  INITIATOR_ARREGION[(11+1)*4-1:11*4]                                                              = MOD_INITIATOR11_ARREGION;
      assign  INITIATOR_ARQOS[(11+1)*4-1:11*4]                                                                 = MOD_INITIATOR11_ARQOS;
      assign  INITIATOR_ARUSER[(11+1)*USER_WIDTH-1:11*USER_WIDTH]                                              = INITIATOR11_ARUSER;
      assign  INITIATOR_ARVALID[11]                                                                            = INITIATOR11_ARVALID;
      assign  INITIATOR_AWQOS[(11+1)*4-1:11*4]                                                                 = MOD_INITIATOR11_AWQOS;
      assign  INITIATOR_AWREGION[(11+1)*4-1:11*4]                                                              = MOD_INITIATOR11_AWREGION;
      assign  INITIATOR_AWID[(11+1)*ID_WIDTH-1:11*ID_WIDTH]                                                    = INITIATOR11_AWID;  
      assign  INITIATOR_AWADDR[(11+1)*ADDR_WIDTH-1:11*ADDR_WIDTH]                                              = INITIATOR11_AWADDR;  
      assign  INITIATOR_AWLEN[(11+1)*8-1:11*8]                                                                 = INITIATOR11_AWLEN;  
      assign  INITIATOR_AWSIZE[(11+1)*3-1:11*3]                                                                = INITIATOR11_AWSIZE;  
      assign  INITIATOR_AWBURST[(11+1)*2-1:11*2]                                                               = INITIATOR11_AWBURST;  
      assign  INITIATOR_AWLOCK[(11+1)*2-1:11*2]                                                                = (INITIATOR11_TYPE == 2'b11) ? INITIATOR11_AWLOCK[1:0] : {1'b0, INITIATOR11_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(11+1)*4-1:11*4]                                                               = INITIATOR11_AWCACHE;  
      assign  INITIATOR_AWPROT[(11+1)*3-1:11*3]                                                                = INITIATOR11_AWPROT;  
      assign  INITIATOR_AWUSER[(11+1)*USER_WIDTH-1:11*USER_WIDTH]                                              = INITIATOR11_AWUSER;  
      assign  INITIATOR_AWVALID[11]                                                                            = INITIATOR11_AWVALID;  
      assign  INITIATOR_WID  [(11+1)*ID_WIDTH-1:11*ID_WIDTH]                                                   = INITIATOR11_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(11+1)*13-1:13*11]-1:MDW_LOWER_VEC[(11+1)*13-1:13*11]]             = INITIATOR11_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(11+1)*13-1:13*11]/8-1:MDW_LOWER_VEC[(11+1)*13-1:13*11]/8]         = INITIATOR11_WSTRB;  
      assign  INITIATOR_WLAST[11]                                                                              = INITIATOR11_WLAST;  
      assign  INITIATOR_WUSER[(11+1)*USER_WIDTH-1:11*USER_WIDTH]                                               = INITIATOR11_WUSER;  
      assign  INITIATOR_WVALID[11]                                                                             = INITIATOR11_WVALID;  
      assign  INITIATOR_BREADY[11]                                                                             = INITIATOR11_BREADY;  
      assign  INITIATOR_RREADY[11]                                                                             = INITIATOR11_RREADY;
      
      assign INITIATOR11_RID        = INITIATOR_RID[(11+1)*ID_WIDTH-1:11*ID_WIDTH];
      assign INITIATOR11_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(11+1)*13-1:13*11]-1:MDW_LOWER_VEC[(11+1)*13-1:13*11]];
      assign INITIATOR11_RRESP      = INITIATOR_RRESP[(11+1)*2-1:11*2];
      assign INITIATOR11_RUSER      = INITIATOR_RUSER[(11+1)*USER_WIDTH-1:11*USER_WIDTH];
      assign INITIATOR11_BID        = INITIATOR_BID[(11+1)*ID_WIDTH-1:11*ID_WIDTH];
      assign INITIATOR11_BRESP      = INITIATOR_BRESP[(11+1)*2-1:11*2];
      assign INITIATOR11_BUSER      = INITIATOR_BUSER[(11+1)*USER_WIDTH-1:11*USER_WIDTH];
      assign INITIATOR11_ARREADY    = INITIATOR_ARREADY[11];
      assign INITIATOR11_RLAST      = INITIATOR_RLAST[11];
      assign INITIATOR11_RVALID     = INITIATOR_RVALID[11];
      assign INITIATOR11_AWREADY    = INITIATOR_AWREADY[11];
      assign INITIATOR11_WREADY     = INITIATOR_WREADY[11];
      assign INITIATOR11_BVALID     = INITIATOR_BVALID[11];
      
      // AHB interface
      assign INITIATOR_HADDR[32*(11+1)-1:32*11]                                                           = INITIATOR11_HADDR;
      assign INITIATOR_HBURST[3*(11+1)-1:3*11]                                                            = INITIATOR11_HBURST;
      assign INITIATOR_HMASTLOCK[11]                                                                      = INITIATOR11_HMASTLOCK;
      assign INITIATOR_HPROT[7*(11+1)-1:7*11]                                                             = INITIATOR11_HPROT;          
      assign INITIATOR_HSIZE[3*(11+1)-1:3*11]                                                             = INITIATOR11_HSIZE;
      assign INITIATOR_HNONSEC[11]                                                                        = INITIATOR11_HNONSEC;
      assign INITIATOR_HTRANS[2*(11+1)-1:2*11]                                                            = INITIATOR11_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(11+1)*13-1:13*11]-1:MDW_LOWER_VEC[(11+1)*13-1:13*11]]        = INITIATOR11_HWDATA;
      assign INITIATOR11_HRDATA                                                                           = INITIATOR_HRDATA[MDW_UPPER_VEC[(11+1)*13-1:13*11]-1:MDW_LOWER_VEC[(11+1)*13-1:13*11]];
      assign INITIATOR_HWRITE[11]                                                                         = INITIATOR11_HWRITE;
      assign INITIATOR11_HRESP                                                                            = INITIATOR_HRESP[11];
//      assign INITIATOR11_HEXOKAY                                                                        = INITIATOR_HEXOKAY[11];
//      assign INITIATOR_HEXCL[11]                                                                        = INITIATOR11_HEXCL;
      assign INITIATOR_HSEL[11]                                                                           = INITIATOR11_HSEL;
      assign INITIATOR11_HREADY                                                                           = INITIATOR_HREADY[11];
    end
    
  //===================================================================================================
  // INITIATOR 12
  //===================================================================================================
  if ( NUM_INITIATORS > 12)
    begin
      //output to initiator converter
      assign  INITIATOR_ARID[(12+1)*ID_WIDTH-1:12*ID_WIDTH]                                                    = INITIATOR12_ARID;
      assign  INITIATOR_ARADDR[(12+1)*ADDR_WIDTH-1:12*ADDR_WIDTH]                                              = INITIATOR12_ARADDR;
      assign  INITIATOR_ARLEN[(12+1)*8-1:12*8]                                                                 = INITIATOR12_ARLEN;
      assign  INITIATOR_ARSIZE[(12+1)*3-1:12*3]                                                                = INITIATOR12_ARSIZE;
      assign  INITIATOR_ARBURST[(12+1)*2-1:12*2]                                                               = INITIATOR12_ARBURST;
      assign  INITIATOR_ARLOCK[(12+1)*2-1:12*2]                                                                = (INITIATOR12_TYPE == 2'b11) ? INITIATOR12_ARLOCK[1:0] : {1'b0, INITIATOR12_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(12+1)*4-1:12*4]                                                               = INITIATOR12_ARCACHE;
      assign  INITIATOR_ARPROT[(12+1)*3-1:12*3]                                                                = INITIATOR12_ARPROT;
      assign  INITIATOR_ARREGION[(12+1)*4-1:12*4]                                                              = MOD_INITIATOR12_ARREGION;
      assign  INITIATOR_ARQOS[(12+1)*4-1:12*4]                                                                 = MOD_INITIATOR12_ARQOS;
      assign  INITIATOR_ARUSER[(12+1)*USER_WIDTH-1:12*USER_WIDTH]                                              = INITIATOR12_ARUSER;
      assign  INITIATOR_ARVALID[12]                                                                            = INITIATOR12_ARVALID;
      assign  INITIATOR_AWQOS[(12+1)*4-1:12*4]                                                                 = MOD_INITIATOR12_AWQOS;
      assign  INITIATOR_AWREGION[(12+1)*4-1:12*4]                                                              = MOD_INITIATOR12_AWREGION;
      assign  INITIATOR_AWID[(12+1)*ID_WIDTH-1:12*ID_WIDTH]                                                    = INITIATOR12_AWID;  
      assign  INITIATOR_AWADDR[(12+1)*ADDR_WIDTH-1:12*ADDR_WIDTH]                                              = INITIATOR12_AWADDR;  
      assign  INITIATOR_AWLEN[(12+1)*8-1:12*8]                                                                 = INITIATOR12_AWLEN;  
      assign  INITIATOR_AWSIZE[(12+1)*3-1:12*3]                                                                = INITIATOR12_AWSIZE;  
      assign  INITIATOR_AWBURST[(12+1)*2-1:12*2]                                                               = INITIATOR12_AWBURST;  
      assign  INITIATOR_AWLOCK[(12+1)*2-1:12*2]                                                                = (INITIATOR12_TYPE == 2'b11) ? INITIATOR12_AWLOCK[1:0] : {1'b0, INITIATOR12_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(12+1)*4-1:12*4]                                                               = INITIATOR12_AWCACHE;  
      assign  INITIATOR_AWPROT[(12+1)*3-1:12*3]                                                                = INITIATOR12_AWPROT;  
      assign  INITIATOR_AWUSER[(12+1)*USER_WIDTH-1:12*USER_WIDTH]                                              = INITIATOR12_AWUSER;  
      assign  INITIATOR_AWVALID[12]                                                                            = INITIATOR12_AWVALID;  
      assign  INITIATOR_WID  [(12+1)*ID_WIDTH-1:12*ID_WIDTH]                                                   = INITIATOR12_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(12+1)*13-1:13*12]-1:MDW_LOWER_VEC[(12+1)*13-1:13*12]]             = INITIATOR12_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(12+1)*13-1:13*12]/8-1:MDW_LOWER_VEC[(12+1)*13-1:13*12]/8]         = INITIATOR12_WSTRB;  
      assign  INITIATOR_WLAST[12]                                                                              = INITIATOR12_WLAST;  
      assign  INITIATOR_WUSER[(12+1)*USER_WIDTH-1:12*USER_WIDTH]                                               = INITIATOR12_WUSER;  
      assign  INITIATOR_WVALID[12]                                                                             = INITIATOR12_WVALID;  
      assign  INITIATOR_BREADY[12]                                                                             = INITIATOR12_BREADY;  
      assign  INITIATOR_RREADY[12]                                                                             = INITIATOR12_RREADY;
      
      assign INITIATOR12_RID        = INITIATOR_RID[(12+1)*ID_WIDTH-1:12*ID_WIDTH];
      assign INITIATOR12_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(12+1)*13-1:13*12]-1:MDW_LOWER_VEC[(12+1)*13-1:13*12]];
      assign INITIATOR12_RRESP      = INITIATOR_RRESP[(12+1)*2-1:12*2];
      assign INITIATOR12_RUSER      = INITIATOR_RUSER[(12+1)*USER_WIDTH-1:12*USER_WIDTH];
      assign INITIATOR12_BID        = INITIATOR_BID[(12+1)*ID_WIDTH-1:12*ID_WIDTH];
      assign INITIATOR12_BRESP      = INITIATOR_BRESP[(12+1)*2-1:12*2];
      assign INITIATOR12_BUSER      = INITIATOR_BUSER[(12+1)*USER_WIDTH-1:12*USER_WIDTH];
      assign INITIATOR12_ARREADY    = INITIATOR_ARREADY[12];
      assign INITIATOR12_RLAST      = INITIATOR_RLAST[12];
      assign INITIATOR12_RVALID     = INITIATOR_RVALID[12];
      assign INITIATOR12_AWREADY    = INITIATOR_AWREADY[12];
      assign INITIATOR12_WREADY     = INITIATOR_WREADY[12];
      assign INITIATOR12_BVALID     = INITIATOR_BVALID[12];
      
      // AHB interface
      assign INITIATOR_HADDR[32*(12+1)-1:32*12]                                                           = INITIATOR12_HADDR;
      assign INITIATOR_HBURST[3*(12+1)-1:3*12]                                                            = INITIATOR12_HBURST;
      assign INITIATOR_HMASTLOCK[12]                                                                      = INITIATOR12_HMASTLOCK;
      assign INITIATOR_HPROT[7*(12+1)-1:7*12]                                                             = INITIATOR12_HPROT;          
      assign INITIATOR_HSIZE[3*(12+1)-1:3*12]                                                             = INITIATOR12_HSIZE;
      assign INITIATOR_HNONSEC[12]                                                                        = INITIATOR12_HNONSEC;
      assign INITIATOR_HTRANS[2*(12+1)-1:2*12]                                                            = INITIATOR12_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(12+1)*13-1:13*12]-1:MDW_LOWER_VEC[(12+1)*13-1:13*12]]        = INITIATOR12_HWDATA;
      assign INITIATOR12_HRDATA                                                                           = INITIATOR_HRDATA[MDW_UPPER_VEC[(12+1)*13-1:13*12]-1:MDW_LOWER_VEC[(12+1)*13-1:13*12]];
      assign INITIATOR_HWRITE[12]                                                                         = INITIATOR12_HWRITE;
      assign INITIATOR12_HRESP                                                                            = INITIATOR_HRESP[12];
//      assign INITIATOR12_HEXOKAY                                                                        = INITIATOR_HEXOKAY[12];
//      assign INITIATOR_HEXCL[12]                                                                        = INITIATOR12_HEXCL;
      assign INITIATOR_HSEL[12]                                                                           = INITIATOR12_HSEL;
      assign INITIATOR12_HREADY                                                                           = INITIATOR_HREADY[12];
    end
    
  //===================================================================================================
  // INITIATOR 13
  //===================================================================================================
  if ( NUM_INITIATORS > 13)
    begin
      //output to initiator converter
      assign  INITIATOR_ARID[(13+1)*ID_WIDTH-1:13*ID_WIDTH]                                                    = INITIATOR13_ARID;
      assign  INITIATOR_ARADDR[(13+1)*ADDR_WIDTH-1:13*ADDR_WIDTH]                                              = INITIATOR13_ARADDR;
      assign  INITIATOR_ARLEN[(13+1)*8-1:13*8]                                                                 = INITIATOR13_ARLEN;
      assign  INITIATOR_ARSIZE[(13+1)*3-1:13*3]                                                                = INITIATOR13_ARSIZE;
      assign  INITIATOR_ARBURST[(13+1)*2-1:13*2]                                                               = INITIATOR13_ARBURST;
      assign  INITIATOR_ARLOCK[(13+1)*2-1:13*2]                                                                = (INITIATOR13_TYPE == 2'b11) ? INITIATOR13_ARLOCK[1:0] : {1'b0, INITIATOR13_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(13+1)*4-1:13*4]                                                               = INITIATOR13_ARCACHE;
      assign  INITIATOR_ARPROT[(13+1)*3-1:13*3]                                                                = INITIATOR13_ARPROT;
      assign  INITIATOR_ARREGION[(13+1)*4-1:13*4]                                                              = MOD_INITIATOR13_ARREGION;
      assign  INITIATOR_ARQOS[(13+1)*4-1:13*4]                                                                 = MOD_INITIATOR13_ARQOS;
      assign  INITIATOR_ARUSER[(13+1)*USER_WIDTH-1:13*USER_WIDTH]                                              = INITIATOR13_ARUSER;
      assign  INITIATOR_ARVALID[13]                                                                            = INITIATOR13_ARVALID;
      assign  INITIATOR_AWQOS[(13+1)*4-1:13*4]                                                                 = MOD_INITIATOR13_AWQOS;
      assign  INITIATOR_AWREGION[(13+1)*4-1:13*4]                                                              = MOD_INITIATOR13_AWREGION;
      assign  INITIATOR_AWID[(13+1)*ID_WIDTH-1:13*ID_WIDTH]                                                    = INITIATOR13_AWID;  
      assign  INITIATOR_AWADDR[(13+1)*ADDR_WIDTH-1:13*ADDR_WIDTH]                                              = INITIATOR13_AWADDR;  
      assign  INITIATOR_AWLEN[(13+1)*8-1:13*8]                                                                 = INITIATOR13_AWLEN;  
      assign  INITIATOR_AWSIZE[(13+1)*3-1:13*3]                                                                = INITIATOR13_AWSIZE;  
      assign  INITIATOR_AWBURST[(13+1)*2-1:13*2]                                                               = INITIATOR13_AWBURST;  
      assign  INITIATOR_AWLOCK[(13+1)*2-1:13*2]                                                                = (INITIATOR13_TYPE == 2'b11) ? INITIATOR13_AWLOCK[1:0] : {1'b0, INITIATOR13_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(13+1)*4-1:13*4]                                                               = INITIATOR13_AWCACHE;  
      assign  INITIATOR_AWPROT[(13+1)*3-1:13*3]                                                                = INITIATOR13_AWPROT;  
      assign  INITIATOR_AWUSER[(13+1)*USER_WIDTH-1:13*USER_WIDTH]                                              = INITIATOR13_AWUSER;  
      assign  INITIATOR_AWVALID[13]                                                                            = INITIATOR13_AWVALID;  
      assign  INITIATOR_WID  [(13+1)*ID_WIDTH-1:13*ID_WIDTH]                                                   = INITIATOR13_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(13+1)*13-1:13*13]-1:MDW_LOWER_VEC[(13+1)*13-1:13*13]]             = INITIATOR13_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(13+1)*13-1:13*13]/8-1:MDW_LOWER_VEC[(13+1)*13-1:13*13]/8]         = INITIATOR13_WSTRB;  
      assign  INITIATOR_WLAST[13]                                                                              = INITIATOR13_WLAST;  
      assign  INITIATOR_WUSER[(13+1)*USER_WIDTH-1:13*USER_WIDTH]                                               = INITIATOR13_WUSER;  
      assign  INITIATOR_WVALID[13]                                                                             = INITIATOR13_WVALID;  
      assign  INITIATOR_BREADY[13]                                                                             = INITIATOR13_BREADY;  
      assign  INITIATOR_RREADY[13]                                                                             = INITIATOR13_RREADY;
      
      assign INITIATOR13_RID        = INITIATOR_RID[(13+1)*ID_WIDTH-1:13*ID_WIDTH];
      assign INITIATOR13_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(13+1)*13-1:13*13]-1:MDW_LOWER_VEC[(13+1)*13-1:13*13]];
      assign INITIATOR13_RRESP      = INITIATOR_RRESP[(13+1)*2-1:13*2];
      assign INITIATOR13_RUSER      = INITIATOR_RUSER[(13+1)*USER_WIDTH-1:13*USER_WIDTH];
      assign INITIATOR13_BID        = INITIATOR_BID[(13+1)*ID_WIDTH-1:13*ID_WIDTH];
      assign INITIATOR13_BRESP      = INITIATOR_BRESP[(13+1)*2-1:13*2];
      assign INITIATOR13_BUSER      = INITIATOR_BUSER[(13+1)*USER_WIDTH-1:13*USER_WIDTH];
      assign INITIATOR13_ARREADY    = INITIATOR_ARREADY[13];
      assign INITIATOR13_RLAST      = INITIATOR_RLAST[13];
      assign INITIATOR13_RVALID     = INITIATOR_RVALID[13];
      assign INITIATOR13_AWREADY    = INITIATOR_AWREADY[13];
      assign INITIATOR13_WREADY     = INITIATOR_WREADY[13];
      assign INITIATOR13_BVALID     = INITIATOR_BVALID[13];
      
      // AHB interface
      assign INITIATOR_HADDR[32*(13+1)-1:32*13]                                                           = INITIATOR13_HADDR;
      assign INITIATOR_HBURST[3*(13+1)-1:3*13]                                                            = INITIATOR13_HBURST;
      assign INITIATOR_HMASTLOCK[13]                                                                      = INITIATOR13_HMASTLOCK;
      assign INITIATOR_HPROT[7*(13+1)-1:7*13]                                                             = INITIATOR13_HPROT;          
      assign INITIATOR_HSIZE[3*(13+1)-1:3*13]                                                             = INITIATOR13_HSIZE;
      assign INITIATOR_HNONSEC[13]                                                                        = INITIATOR13_HNONSEC;
      assign INITIATOR_HTRANS[2*(13+1)-1:2*13]                                                            = INITIATOR13_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(13+1)*13-1:13*13]-1:MDW_LOWER_VEC[(13+1)*13-1:13*13]]        = INITIATOR13_HWDATA;
      assign INITIATOR13_HRDATA                                                                           = INITIATOR_HRDATA[MDW_UPPER_VEC[(13+1)*13-1:13*13]-1:MDW_LOWER_VEC[(13+1)*13-1:13*13]];
      assign INITIATOR_HWRITE[13]                                                                         = INITIATOR13_HWRITE;
      assign INITIATOR13_HRESP                                                                            = INITIATOR_HRESP[13];
//      assign INITIATOR13_HEXOKAY                                                                        = INITIATOR_HEXOKAY[13];
//      assign INITIATOR_HEXCL[13]                                                                        = INITIATOR13_HEXCL;
      assign INITIATOR_HSEL[13]                                                                           = INITIATOR13_HSEL;
      assign INITIATOR13_HREADY                                                                           = INITIATOR_HREADY[13];
    end
    
  //===================================================================================================
  // INITIATOR 14
  //===================================================================================================
  if ( NUM_INITIATORS > 14)
    begin
      //output to initiator converter
      assign  INITIATOR_ARID[(14+1)*ID_WIDTH-1:14*ID_WIDTH]                                                    = INITIATOR14_ARID;
      assign  INITIATOR_ARADDR[(14+1)*ADDR_WIDTH-1:14*ADDR_WIDTH]                                              = INITIATOR14_ARADDR;
      assign  INITIATOR_ARLEN[(14+1)*8-1:14*8]                                                                 = INITIATOR14_ARLEN;
      assign  INITIATOR_ARSIZE[(14+1)*3-1:14*3]                                                                = INITIATOR14_ARSIZE;
      assign  INITIATOR_ARBURST[(14+1)*2-1:14*2]                                                               = INITIATOR14_ARBURST;
      assign  INITIATOR_ARLOCK[(14+1)*2-1:14*2]                                                                = (INITIATOR14_TYPE == 2'b11) ? INITIATOR14_ARLOCK[1:0] : {1'b0, INITIATOR14_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(14+1)*4-1:14*4]                                                               = INITIATOR14_ARCACHE;
      assign  INITIATOR_ARPROT[(14+1)*3-1:14*3]                                                                = INITIATOR14_ARPROT;
      assign  INITIATOR_ARREGION[(14+1)*4-1:14*4]                                                              = MOD_INITIATOR14_ARREGION;
      assign  INITIATOR_ARQOS[(14+1)*4-1:14*4]                                                                 = MOD_INITIATOR14_ARQOS;
      assign  INITIATOR_ARUSER[(14+1)*USER_WIDTH-1:14*USER_WIDTH]                                              = INITIATOR14_ARUSER;
      assign  INITIATOR_ARVALID[14]                                                                            = INITIATOR14_ARVALID;
      assign  INITIATOR_AWQOS[(14+1)*4-1:14*4]                                                                 = MOD_INITIATOR14_AWQOS;
      assign  INITIATOR_AWREGION[(14+1)*4-1:14*4]                                                              = MOD_INITIATOR14_AWREGION;
      assign  INITIATOR_AWID[(14+1)*ID_WIDTH-1:14*ID_WIDTH]                                                    = INITIATOR14_AWID;  
      assign  INITIATOR_AWADDR[(14+1)*ADDR_WIDTH-1:14*ADDR_WIDTH]                                              = INITIATOR14_AWADDR;  
      assign  INITIATOR_AWLEN[(14+1)*8-1:14*8]                                                                 = INITIATOR14_AWLEN;  
      assign  INITIATOR_AWSIZE[(14+1)*3-1:14*3]                                                                = INITIATOR14_AWSIZE;  
      assign  INITIATOR_AWBURST[(14+1)*2-1:14*2]                                                               = INITIATOR14_AWBURST;  
      assign  INITIATOR_AWLOCK[(14+1)*2-1:14*2]                                                                = (INITIATOR14_TYPE == 2'b11) ? INITIATOR14_AWLOCK[1:0] : {1'b0, INITIATOR14_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(14+1)*4-1:14*4]                                                               = INITIATOR14_AWCACHE;  
      assign  INITIATOR_AWPROT[(14+1)*3-1:14*3]                                                                = INITIATOR14_AWPROT;  
      assign  INITIATOR_AWUSER[(14+1)*USER_WIDTH-1:14*USER_WIDTH]                                              = INITIATOR14_AWUSER;  
      assign  INITIATOR_AWVALID[14]                                                                            = INITIATOR14_AWVALID;  
      assign  INITIATOR_WID  [(14+1)*ID_WIDTH-1:14*ID_WIDTH]                                                   = INITIATOR14_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(14+1)*13-1:13*14]-1:MDW_LOWER_VEC[(14+1)*13-1:13*14]]             = INITIATOR14_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(14+1)*13-1:13*14]/8-1:MDW_LOWER_VEC[(14+1)*13-1:13*14]/8]         = INITIATOR14_WSTRB;  
      assign  INITIATOR_WLAST[14]                                                                              = INITIATOR14_WLAST;  
      assign  INITIATOR_WUSER[(14+1)*USER_WIDTH-1:14*USER_WIDTH]                                               = INITIATOR14_WUSER;  
      assign  INITIATOR_WVALID[14]                                                                             = INITIATOR14_WVALID;  
      assign  INITIATOR_BREADY[14]                                                                             = INITIATOR14_BREADY;  
      assign  INITIATOR_RREADY[14]                                                                             = INITIATOR14_RREADY;
      
      assign INITIATOR14_RID        = INITIATOR_RID[(14+1)*ID_WIDTH-1:14*ID_WIDTH];
      assign INITIATOR14_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(14+1)*13-1:13*14]-1:MDW_LOWER_VEC[(14+1)*13-1:13*14]];
      assign INITIATOR14_RRESP      = INITIATOR_RRESP[(14+1)*2-1:14*2];
      assign INITIATOR14_RUSER      = INITIATOR_RUSER[(14+1)*USER_WIDTH-1:14*USER_WIDTH];
      assign INITIATOR14_BID        = INITIATOR_BID[(14+1)*ID_WIDTH-1:14*ID_WIDTH];
      assign INITIATOR14_BRESP      = INITIATOR_BRESP[(14+1)*2-1:14*2];
      assign INITIATOR14_BUSER      = INITIATOR_BUSER[(14+1)*USER_WIDTH-1:14*USER_WIDTH];
      assign INITIATOR14_ARREADY    = INITIATOR_ARREADY[14];
      assign INITIATOR14_RLAST      = INITIATOR_RLAST[14];
      assign INITIATOR14_RVALID     = INITIATOR_RVALID[14];
      assign INITIATOR14_AWREADY    = INITIATOR_AWREADY[14];
      assign INITIATOR14_WREADY     = INITIATOR_WREADY[14];
      assign INITIATOR14_BVALID     = INITIATOR_BVALID[14];
      
      // AHB interface
      assign INITIATOR_HADDR[32*(14+1)-1:32*14]                                                           = INITIATOR14_HADDR;
      assign INITIATOR_HBURST[3*(14+1)-1:3*14]                                                            = INITIATOR14_HBURST;
      assign INITIATOR_HMASTLOCK[14]                                                                      = INITIATOR14_HMASTLOCK;
      assign INITIATOR_HPROT[7*(14+1)-1:7*14]                                                             = INITIATOR14_HPROT;          
      assign INITIATOR_HSIZE[3*(14+1)-1:3*14]                                                             = INITIATOR14_HSIZE;
      assign INITIATOR_HNONSEC[14]                                                                        = INITIATOR14_HNONSEC;
      assign INITIATOR_HTRANS[2*(14+1)-1:2*14]                                                            = INITIATOR14_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(14+1)*13-1:13*14]-1:MDW_LOWER_VEC[(14+1)*13-1:13*14]]        = INITIATOR14_HWDATA;
      assign INITIATOR14_HRDATA                                                                           = INITIATOR_HRDATA[MDW_UPPER_VEC[(14+1)*13-1:13*14]-1:MDW_LOWER_VEC[(14+1)*13-1:13*14]];
      assign INITIATOR_HWRITE[14]                                                                         = INITIATOR14_HWRITE;
      assign INITIATOR14_HRESP                                                                            = INITIATOR_HRESP[14];
//      assign INITIATOR14_HEXOKAY                                                                        = INITIATOR_HEXOKAY[14];
//      assign INITIATOR_HEXCL[14]                                                                        = INITIATOR14_HEXCL;
      assign INITIATOR_HSEL[14]                                                                           = INITIATOR14_HSEL;
      assign INITIATOR14_HREADY                                                                           = INITIATOR_HREADY[14];
    end
    
  //===================================================================================================
  // INITIATOR 15
  //===================================================================================================
  if ( NUM_INITIATORS > 15)
    begin
      //output to initiator converter
      assign  INITIATOR_ARID[(15+1)*ID_WIDTH-1:15*ID_WIDTH]                                                    = INITIATOR15_ARID;
      assign  INITIATOR_ARADDR[(15+1)*ADDR_WIDTH-1:15*ADDR_WIDTH]                                              = INITIATOR15_ARADDR;
      assign  INITIATOR_ARLEN[(15+1)*8-1:15*8]                                                                 = INITIATOR15_ARLEN;
      assign  INITIATOR_ARSIZE[(15+1)*3-1:15*3]                                                                = INITIATOR15_ARSIZE;
      assign  INITIATOR_ARBURST[(15+1)*2-1:15*2]                                                               = INITIATOR15_ARBURST;
      assign  INITIATOR_ARLOCK[(15+1)*2-1:15*2]                                                                 = (INITIATOR15_TYPE == 2'b11) ? INITIATOR15_ARLOCK[1:0] : {1'b0, INITIATOR15_ARLOCK[0]};
      assign  INITIATOR_ARCACHE[(15+1)*4-1:15*4]                                                               = INITIATOR15_ARCACHE;
      assign  INITIATOR_ARPROT[(15+1)*3-1:15*3]                                                                = INITIATOR15_ARPROT;
      assign  INITIATOR_ARREGION[(15+1)*4-1:15*4]                                                              = MOD_INITIATOR15_ARREGION;
      assign  INITIATOR_ARQOS[(15+1)*4-1:15*4]                                                                 = MOD_INITIATOR15_ARQOS;
      assign  INITIATOR_ARUSER[(15+1)*USER_WIDTH-1:15*USER_WIDTH]                                              = INITIATOR15_ARUSER;
      assign  INITIATOR_ARVALID[15]                                                                            = INITIATOR15_ARVALID;
      assign  INITIATOR_AWQOS[(15+1)*4-1:15*4]                                                                 = MOD_INITIATOR15_AWQOS;
      assign  INITIATOR_AWREGION[(15+1)*4-1:15*4]                                                              = MOD_INITIATOR15_AWREGION;
      assign  INITIATOR_AWID[(15+1)*ID_WIDTH-1:15*ID_WIDTH]                                                    = INITIATOR15_AWID;  
      assign  INITIATOR_AWADDR[(15+1)*ADDR_WIDTH-1:15*ADDR_WIDTH]                                              = INITIATOR15_AWADDR;  
      assign  INITIATOR_AWLEN[(15+1)*8-1:15*8]                                                                 = INITIATOR15_AWLEN;  
      assign  INITIATOR_AWSIZE[(15+1)*3-1:15*3]                                                                = INITIATOR15_AWSIZE;  
      assign  INITIATOR_AWBURST[(15+1)*2-1:15*2]                                                               = INITIATOR15_AWBURST;  
      assign  INITIATOR_AWLOCK[(15+1)*2-1:15*2]                                                                = (INITIATOR15_TYPE == 2'b11) ? INITIATOR15_AWLOCK[1:0] : {1'b0, INITIATOR15_AWLOCK[0]};
      assign  INITIATOR_AWCACHE[(15+1)*4-1:15*4]                                                               = INITIATOR15_AWCACHE;  
      assign  INITIATOR_AWPROT[(15+1)*3-1:15*3]                                                                = INITIATOR15_AWPROT;  
      assign  INITIATOR_AWUSER[(15+1)*USER_WIDTH-1:15*USER_WIDTH]                                              = INITIATOR15_AWUSER;  
      assign  INITIATOR_AWVALID[15]                                                                            = INITIATOR15_AWVALID;  
      assign  INITIATOR_WID  [(15+1)*ID_WIDTH-1:15*ID_WIDTH]                                                   = INITIATOR15_WID;  
      assign  INITIATOR_WDATA[MDW_UPPER_VEC[(15+1)*13-1:13*15]-1:MDW_LOWER_VEC[(15+1)*13-1:13*15]]             = INITIATOR15_WDATA;  
      assign  INITIATOR_WSTRB[MDW_UPPER_VEC[(15+1)*13-1:13*15]/8-1:MDW_LOWER_VEC[(15+1)*13-1:13*15]/8]         = INITIATOR15_WSTRB;  
      assign  INITIATOR_WLAST[15]                                                                              = INITIATOR15_WLAST;  
      assign  INITIATOR_WUSER[(15+1)*USER_WIDTH-1:15*USER_WIDTH]                                               = INITIATOR15_WUSER;  
      assign  INITIATOR_WVALID[15]                                                                             = INITIATOR15_WVALID;  
      assign  INITIATOR_BREADY[15]                                                                             = INITIATOR15_BREADY;  
      assign  INITIATOR_RREADY[15]                                                                             = INITIATOR15_RREADY;
      
      assign INITIATOR15_RID        = INITIATOR_RID[(15+1)*ID_WIDTH-1:15*ID_WIDTH];
      assign INITIATOR15_RDATA      = INITIATOR_RDATA[MDW_UPPER_VEC[(15+1)*13-1:13*15]-1:MDW_LOWER_VEC[(15+1)*13-1:13*15]];
      assign INITIATOR15_RRESP      = INITIATOR_RRESP[(15+1)*2-1:15*2];
      assign INITIATOR15_RUSER      = INITIATOR_RUSER[(15+1)*USER_WIDTH-1:15*USER_WIDTH];
      assign INITIATOR15_BID        = INITIATOR_BID[(15+1)*ID_WIDTH-1:15*ID_WIDTH];
      assign INITIATOR15_BRESP      = INITIATOR_BRESP[(15+1)*2-1:15*2];
      assign INITIATOR15_BUSER      = INITIATOR_BUSER[(15+1)*USER_WIDTH-1:15*USER_WIDTH];
      assign INITIATOR15_ARREADY    = INITIATOR_ARREADY[15];
      assign INITIATOR15_RLAST      = INITIATOR_RLAST[15];
      assign INITIATOR15_RVALID     = INITIATOR_RVALID[15];
      assign INITIATOR15_AWREADY    = INITIATOR_AWREADY[15];
      assign INITIATOR15_WREADY     = INITIATOR_WREADY[15];
      assign INITIATOR15_BVALID     = INITIATOR_BVALID[15];
      
      // AHB interface
      assign INITIATOR_HADDR[32*(15+1)-1:32*15]                                                           = INITIATOR15_HADDR;
      assign INITIATOR_HBURST[3*(15+1)-1:3*15]                                                            = INITIATOR15_HBURST;
      assign INITIATOR_HMASTLOCK[15]                                                                      = INITIATOR15_HMASTLOCK;
      assign INITIATOR_HPROT[7*(15+1)-1:7*15]                                                             = INITIATOR15_HPROT;          
      assign INITIATOR_HSIZE[3*(15+1)-1:3*15]                                                             = INITIATOR15_HSIZE;
      assign INITIATOR_HNONSEC[15]                                                                        = INITIATOR15_HNONSEC;
      assign INITIATOR_HTRANS[2*(15+1)-1:2*15]                                                            = INITIATOR15_HTRANS;
      assign INITIATOR_HWDATA[MDW_UPPER_VEC[(15+1)*13-1:13*15]-1:MDW_LOWER_VEC[(15+1)*13-1:13*15]]        = INITIATOR15_HWDATA;
      assign INITIATOR15_HRDATA                                                                           = INITIATOR_HRDATA[MDW_UPPER_VEC[(15+1)*13-1:13*15]-1:MDW_LOWER_VEC[(15+1)*13-1:13*15]];
      assign INITIATOR_HWRITE[15]                                                                         = INITIATOR15_HWRITE;
      assign INITIATOR15_HRESP                                                                            = INITIATOR_HRESP[15];
//      assign INITIATOR15_HEXOKAY                                                                        = INITIATOR_HEXOKAY[15];
//      assign INITIATOR_HEXCL[15]                                                                        = INITIATOR15_HEXCL;
      assign INITIATOR_HSEL[15]                                                                           = INITIATOR15_HSEL;
      assign INITIATOR15_HREADY                                                                           = INITIATOR_HREADY[15];
    end
    
	  
  //===================================================================
  //Target0 Combine Signals
  //===================================================================
  //======================= TARGET0 TO/FROM External Side=================
  //Outputs
  //
  assign  TARGET0_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[0*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(0+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
  assign  TARGET0_AWADDR   = TARGET_AWADDR[(0+1)*ADDR_WIDTH-1:0*ADDR_WIDTH];  
  assign  TARGET0_AWLEN    = TARGET_AWLEN[(0+1)*8-1:0*8];  
  assign  TARGET0_AWSIZE   = TARGET_AWSIZE[(0+1)*3-1:0*3];  
  assign  TARGET0_AWBURST  = TARGET_AWBURST[(0+1)*2-1:0*2];  
  // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
  assign  TARGET0_AWLOCK   = (TARGET0_TYPE == 2'b11) ? TARGET_AWLOCK[(0+1)*2-1:0*2] : {1'b0, TARGET_AWLOCK[0*2]};  
  assign  TARGET0_AWCACHE  = TARGET_AWCACHE[(0+1)*4-1:0*4];  
  assign  TARGET0_AWPROT   = TARGET_AWPROT[(0+1)*3-1:0*3];  
  assign  TARGET0_AWREGION = TARGET_AWREGION[(0+1)*4-1:0*4];   
  assign  TARGET0_AWQOS    = TARGET_AWQOS[(0+1)*4-1:0*4];  
  assign  TARGET0_AWUSER   = TARGET_AWUSER[(0+1)*USER_WIDTH-1:0*USER_WIDTH];  
  assign  TARGET0_AWVALID  = TARGET_AWVALID[0];  
  assign  TARGET0_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[0*(ID_WIDTH+1) +:ID_WIDTH] : TARGET_WID[(0+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
  assign  TARGET0_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(0+1)*13-1:13*0]-1:SDW_LOWER_VEC[(0+1)*13-1:13*0]];  
  assign  TARGET0_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(0+1)*13-1:13*0]/8-1:SDW_LOWER_VEC[(0+1)*13-1:13*0]];  
  assign  TARGET0_WLAST    = TARGET_WLAST[0];  
  assign  TARGET0_WUSER    = TARGET_WUSER[(0+1)*USER_WIDTH-1:0*USER_WIDTH];  
  assign  TARGET0_WVALID   = TARGET_WVALID[0];      
  assign  TARGET0_BREADY   = TARGET_BREADY[0];        
  assign  TARGET0_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[0*(ID_WIDTH+1) +:ID_WIDTH] : TARGET_ARID[(0+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
  assign  TARGET0_ARADDR   = TARGET_ARADDR[(0+1)*ADDR_WIDTH-1:0*ADDR_WIDTH];  
  assign  TARGET0_ARLEN    = TARGET_ARLEN[(0+1)*8-1:0*8];  
  assign  TARGET0_ARSIZE   = TARGET_ARSIZE[(0+1)*3-1:0*3];  
  assign  TARGET0_ARBURST  = TARGET_ARBURST[(0+1)*2-1:0*2];  
  // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
  assign  TARGET0_ARLOCK   = (TARGET0_TYPE == 2'b11) ? TARGET_ARLOCK[(0+1)*2-1:0*2] : {1'b0, TARGET_ARLOCK[0*2]};  
  assign  TARGET0_ARCACHE  = TARGET_ARCACHE[(0+1)*4-1:0*4] ;  
  assign  TARGET0_ARPROT   = TARGET_ARPROT[(0+1)*3-1:0*3] ;  
  assign  TARGET0_ARREGION = TARGET_ARREGION[(0+1)*4-1:0*4];   
  assign  TARGET0_ARQOS    = TARGET_ARQOS[(0+1)*4-1:0*4];  
  assign  TARGET0_ARUSER   = TARGET_ARUSER[(0+1)*USER_WIDTH-1:0*USER_WIDTH];  
  assign  TARGET0_ARVALID  = TARGET_ARVALID[0];      
  assign  TARGET0_RREADY   = TARGET_RREADY[0];  

  //Inputs      
  assign  TARGET_AWREADY[0]                                                                               = TARGET0_AWREADY;          
  assign  TARGET_WREADY[0]                                                                                = TARGET0_WREADY;        
  assign  TARGET_BID[(0+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET0_BID} : TARGET0_BID;  
  assign  TARGET_BRESP[(0+1)*2-1:0*2]                                                                     = TARGET0_BRESP;  
  assign  TARGET_BUSER[(0+1)*USER_WIDTH-1:0*USER_WIDTH]                                                   = TARGET0_BUSER;  
  assign  TARGET_BVALID[0]                                                                                = TARGET0_BVALID;        
  assign  TARGET_ARREADY[0]                                                                               = TARGET0_ARREADY;        
  assign  TARGET_RID[(0+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:0*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET0_RID} : TARGET0_RID;  
  assign  TARGET_RDATA[SDW_UPPER_VEC[(0+1)*13-1:13*0]-1:SDW_LOWER_VEC[(0+1)*13-1:13*0]]                   = TARGET0_RDATA;  
  assign  TARGET_RRESP[(0+1)*2-1:0*2]                                                                     = TARGET0_RRESP;  
  assign  TARGET_RLAST[0]                                                                                 = TARGET0_RLAST;  
  assign  TARGET_RUSER[(0+1)*USER_WIDTH-1:0*USER_WIDTH]                                                   = TARGET0_RUSER;  
  assign  TARGET_RVALID[0]                                                                                = TARGET0_RVALID;

  if ( NUM_TARGETS > 1 )
    begin
      //===================================================================
      //Target1 Combine Signals
      //===================================================================
      //======================= TARGET1 TO/FROM External Side=================
      //Outputs
      //
      assign  TARGET1_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[1*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(1+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:1*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET1_AWADDR   = TARGET_AWADDR[(1+1)*ADDR_WIDTH-1:1*ADDR_WIDTH];  
      assign  TARGET1_AWLEN    = TARGET_AWLEN[(1+1)*8-1:1*8];  
      assign  TARGET1_AWSIZE   = TARGET_AWSIZE[(1+1)*3-1:1*3];  
      assign  TARGET1_AWBURST  = TARGET_AWBURST[(1+1)*2-1:1*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET1_AWLOCK   = (TARGET1_TYPE  == 2'b11) ? TARGET_AWLOCK[(1+1)*2-1:1*2]   : {1'b0, TARGET_AWLOCK[1*2]};
      assign  TARGET1_AWCACHE  = TARGET_AWCACHE[(1+1)*4-1:1*4];  
      assign  TARGET1_AWPROT   = TARGET_AWPROT[(1+1)*3-1:1*3];  
      assign  TARGET1_AWREGION = TARGET_AWREGION[(1+1)*4-1:1*4];   
      assign  TARGET1_AWQOS    = TARGET_AWQOS[(1+1)*4-1:1*4];  
      assign  TARGET1_AWUSER   = TARGET_AWUSER[(1+1)*USER_WIDTH-1:1*USER_WIDTH];  
      assign  TARGET1_AWVALID  = TARGET_AWVALID[1];        
      assign  TARGET1_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(1+1)*13-1:13*1]-1:SDW_LOWER_VEC[(1+1)*13-1:13*1]];  
      assign  TARGET1_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(1+1)*13-1:13*1]/8-1:SDW_LOWER_VEC[(1+1)*13-1:13*1]/8];  
      assign  TARGET1_WLAST    = TARGET_WLAST[1];  
      assign  TARGET1_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[1*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(1+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:1*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET1_WUSER    = TARGET_WUSER[(1+1)*USER_WIDTH-1:1*USER_WIDTH];  
      assign  TARGET1_WVALID   = TARGET_WVALID[1];      
      assign  TARGET1_BREADY   = TARGET_BREADY[1];        
      assign  TARGET1_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[1*(ID_WIDTH+1) +: ID_WIDTH] :  TARGET_ARID[(1+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:1*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET1_ARADDR   = TARGET_ARADDR[(1+1)*ADDR_WIDTH-1:1*ADDR_WIDTH];  
      assign  TARGET1_ARLEN    = TARGET_ARLEN[(1+1)*8-1:1*8];  
      assign  TARGET1_ARSIZE   = TARGET_ARSIZE[(1+1)*3-1:1*3];  
      assign  TARGET1_ARBURST  = TARGET_ARBURST[(1+1)*2-1:1*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET1_ARLOCK   = (TARGET1_TYPE  == 2'b11) ? TARGET_ARLOCK[(1+1)*2-1:1*2]   : {1'b0, TARGET_ARLOCK[1*2]};
      assign  TARGET1_ARCACHE  = TARGET_ARCACHE[(1+1)*4-1:1*4] ;  
      assign  TARGET1_ARPROT   = TARGET_ARPROT[(1+1)*3-1:1*3] ;  
      assign  TARGET1_ARREGION = TARGET_ARREGION[(1+1)*4-1:1*4];   
      assign  TARGET1_ARQOS    = TARGET_ARQOS[(1+1)*4-1:1*4];  
      assign  TARGET1_ARUSER   = TARGET_ARUSER[(1+1)*USER_WIDTH-1:1*USER_WIDTH];  
      assign  TARGET1_ARVALID  = TARGET_ARVALID[1];      
      assign  TARGET1_RREADY   = TARGET_RREADY[1];  

      //Inputs      
      assign  TARGET_AWREADY[1]                                                                               = TARGET1_AWREADY;          
      assign  TARGET_WREADY[1]                                                                                = TARGET1_WREADY;        
      assign  TARGET_BID[(1+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:1*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET1_BID} : TARGET1_BID;  
      assign  TARGET_BRESP[(1+1)*2-1:1*2]                                                                     = TARGET1_BRESP;  
      assign  TARGET_BUSER[(1+1)*USER_WIDTH-1:1*USER_WIDTH]                                                   = TARGET1_BUSER;  
      assign  TARGET_BVALID[1]                                                                                = TARGET1_BVALID;        
      assign  TARGET_ARREADY[1]                                                                               = TARGET1_ARREADY;        
      assign  TARGET_RID[(1+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:1*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET1_RID} : TARGET1_RID; 
      assign  TARGET_RDATA[SDW_UPPER_VEC[(1+1)*13-1:13*1]-1:SDW_LOWER_VEC[(1+1)*13-1:13*1]]                   = TARGET1_RDATA;  
      assign  TARGET_RRESP[(1+1)*2-1:1*2]                                                                     = TARGET1_RRESP;  
      assign  TARGET_RLAST[1]                                                                                 = TARGET1_RLAST;  
      assign  TARGET_RUSER[(1+1)*USER_WIDTH-1:1*USER_WIDTH]                                                   = TARGET1_RUSER;  
      assign  TARGET_RVALID[1]                                                                                = TARGET1_RVALID;
    end
    
  if ( NUM_TARGETS > 2 )
    begin
      //===================================================================
      //Target2 Combine Signals
      //===================================================================
      //======================= TARGET2 TO/FROM External Side=================
      //Outputs
      //
      assign  TARGET2_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[2*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(2+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:2*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET2_AWADDR   = TARGET_AWADDR[(2+1)*ADDR_WIDTH-1:2*ADDR_WIDTH];  
      assign  TARGET2_AWLEN    = TARGET_AWLEN[(2+1)*8-1:2*8];  
      assign  TARGET2_AWSIZE   = TARGET_AWSIZE[(2+1)*3-1:2*3];  
      assign  TARGET2_AWBURST  = TARGET_AWBURST[(2+1)*2-1:2*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET2_AWLOCK   = (TARGET2_TYPE  == 2'b11) ? TARGET_AWLOCK[(2+1)*2-1:2*2]   : {1'b0, TARGET_AWLOCK[2*2]};
      assign  TARGET2_AWCACHE  = TARGET_AWCACHE[(2+1)*4-1:2*4];  
      assign  TARGET2_AWPROT   = TARGET_AWPROT[(2+1)*3-1:2*3];  
      assign  TARGET2_AWREGION = TARGET_AWREGION[(2+1)*4-1:2*4];   
      assign  TARGET2_AWQOS    = TARGET_AWQOS[(2+1)*4-1:2*4];  
      assign  TARGET2_AWUSER   = TARGET_AWUSER[(2+1)*USER_WIDTH-1:2*USER_WIDTH];  
      assign  TARGET2_AWVALID  = TARGET_AWVALID[2];
      assign  TARGET2_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[2*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(2+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:2*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET2_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(2+1)*13-1:13*2]-1:SDW_LOWER_VEC[(2+1)*13-1:13*2]];  
      assign  TARGET2_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(2+1)*13-1:13*2]/8-1:SDW_LOWER_VEC[(2+1)*13-1:13*2]/8];  
      assign  TARGET2_WLAST    = TARGET_WLAST[2];  
      assign  TARGET2_WUSER    = TARGET_WUSER[(2+1)*USER_WIDTH-1:2*USER_WIDTH];  
      assign  TARGET2_WVALID   = TARGET_WVALID[2];      
      assign  TARGET2_BREADY   = TARGET_BREADY[2];        
      assign  TARGET2_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[2*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(2+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:2*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET2_ARADDR   = TARGET_ARADDR[(2+1)*ADDR_WIDTH-1:2*ADDR_WIDTH];  
      assign  TARGET2_ARLEN    = TARGET_ARLEN[(2+1)*8-1:2*8];  
      assign  TARGET2_ARSIZE   = TARGET_ARSIZE[(2+1)*3-1:2*3];  
	  assign  TARGET2_ARBURST  = TARGET_ARBURST[(2+1)*2-1:2*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET2_ARLOCK   = (TARGET2_TYPE  == 2'b11) ? TARGET_ARLOCK[(2+1)*2-1:2*2]   : {1'b0, TARGET_ARLOCK[2*2]};
      assign  TARGET2_ARCACHE  = TARGET_ARCACHE[(2+1)*4-1:2*4] ;  
      assign  TARGET2_ARPROT   = TARGET_ARPROT[(2+1)*3-1:2*3] ;  
      assign  TARGET2_ARREGION = TARGET_ARREGION[(2+1)*4-1:2*4];   
      assign  TARGET2_ARQOS    = TARGET_ARQOS[(2+1)*4-1:2*4];  
      assign  TARGET2_ARUSER   = TARGET_ARUSER[(2+1)*USER_WIDTH-1:2*USER_WIDTH];  
      assign  TARGET2_ARVALID  = TARGET_ARVALID[2];      
      assign  TARGET2_RREADY   = TARGET_RREADY[2];  

      //Inputs      
      assign  TARGET_AWREADY[2]                                                                               = TARGET2_AWREADY;          
      assign  TARGET_WREADY[2]                                                                                = TARGET2_WREADY;        
      assign  TARGET_BID[(2+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:2*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET2_BID} : TARGET2_BID;  
      assign  TARGET_BRESP[(2+1)*2-1:2*2]                                                                     = TARGET2_BRESP;  
      assign  TARGET_BUSER[(2+1)*USER_WIDTH-1:2*USER_WIDTH]                                                   = TARGET2_BUSER;  
      assign  TARGET_BVALID[2]                                                                                = TARGET2_BVALID;        
      assign  TARGET_ARREADY[2]                                                                               = TARGET2_ARREADY;        
      assign  TARGET_RID[(2+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:2*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET2_RID} : TARGET2_RID;     
      assign  TARGET_RDATA[SDW_UPPER_VEC[(2+1)*13-1:13*2]-1:SDW_LOWER_VEC[(2+1)*13-1:13*2]]                   = TARGET2_RDATA;  
      assign  TARGET_RRESP[(2+1)*2-1:2*2]                                                                     = TARGET2_RRESP;  
      assign  TARGET_RLAST[2]                                                                                 = TARGET2_RLAST;  
      assign  TARGET_RUSER[(2+1)*USER_WIDTH-1:2*USER_WIDTH]                                                   = TARGET2_RUSER;  
      assign  TARGET_RVALID[2]                                                                                = TARGET2_RVALID;
    end
    
  if ( NUM_TARGETS > 3 )
    begin    
      //===================================================================
      //Target3 Combine Signals
      //===================================================================
      //======================= TARGET3 TO/FROM External Side=================
      //Outputs
      assign  TARGET3_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[3*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(3+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:3*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET3_AWADDR   = TARGET_AWADDR[(3+1)*ADDR_WIDTH-1:3*ADDR_WIDTH];  
      assign  TARGET3_AWLEN    = TARGET_AWLEN[(3+1)*8-1:3*8];  
      assign  TARGET3_AWSIZE   = TARGET_AWSIZE[(3+1)*3-1:3*3];  
      assign  TARGET3_AWBURST  = TARGET_AWBURST[(3+1)*2-1:3*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET3_AWLOCK   = (TARGET3_TYPE  == 2'b11) ? TARGET_AWLOCK[(3+1)*2-1:3*2]   : {1'b0, TARGET_AWLOCK[3*2]};
      assign  TARGET3_AWCACHE  = TARGET_AWCACHE[(3+1)*4-1:3*4];  
      assign  TARGET3_AWPROT   = TARGET_AWPROT[(3+1)*3-1:3*3];  
      assign  TARGET3_AWREGION = TARGET_AWREGION[(3+1)*4-1:3*4];   
      assign  TARGET3_AWQOS    = TARGET_AWQOS[(3+1)*4-1:3*4];  
      assign  TARGET3_AWUSER   = TARGET_AWUSER[(3+1)*USER_WIDTH-1:3*USER_WIDTH];  
      assign  TARGET3_AWVALID  = TARGET_AWVALID[3];        
      assign  TARGET3_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[3*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(3+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:3*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET3_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(3+1)*13-1:13*3]-1:SDW_LOWER_VEC[(3+1)*13-1:13*3]];  
      assign  TARGET3_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(3+1)*13-1:13*3]/8-1:SDW_LOWER_VEC[(3+1)*13-1:13*3]/8];  
      assign  TARGET3_WLAST    = TARGET_WLAST[3];  
      assign  TARGET3_WUSER    = TARGET_WUSER[(3+1)*USER_WIDTH-1:3*USER_WIDTH];  
      assign  TARGET3_WVALID   = TARGET_WVALID[3];      
      assign  TARGET3_BREADY   = TARGET_BREADY[3];        
      assign  TARGET3_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[3*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(3+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:3*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET3_ARADDR   = TARGET_ARADDR[(3+1)*ADDR_WIDTH-1:3*ADDR_WIDTH];  
      assign  TARGET3_ARLEN    = TARGET_ARLEN[(3+1)*8-1:3*8];  
      assign  TARGET3_ARSIZE   = TARGET_ARSIZE[(3+1)*3-1:3*3];  
      assign  TARGET3_ARBURST  = TARGET_ARBURST[(3+1)*2-1:3*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET3_ARLOCK   = (TARGET3_TYPE  == 2'b11) ? TARGET_ARLOCK[(3+1)*2-1:3*2]   : {1'b0, TARGET_ARLOCK[3*2]};
      assign  TARGET3_ARCACHE  = TARGET_ARCACHE[(3+1)*4-1:3*4] ;  
      assign  TARGET3_ARPROT   = TARGET_ARPROT[(3+1)*3-1:3*3] ;  
      assign  TARGET3_ARREGION = TARGET_ARREGION[(3+1)*4-1:3*4];   
      assign  TARGET3_ARQOS    = TARGET_ARQOS[(3+1)*4-1:3*4];  
      assign  TARGET3_ARUSER   = TARGET_ARUSER[(3+1)*USER_WIDTH-1:3*USER_WIDTH];  
      assign  TARGET3_ARVALID  = TARGET_ARVALID[3];      
      assign  TARGET3_RREADY   = TARGET_RREADY[3];  

      //Inputs      
      assign  TARGET_AWREADY[3]                                                                               = TARGET3_AWREADY;          
      assign  TARGET_WREADY[3]                                                                                = TARGET3_WREADY;        
      assign  TARGET_BID[(3+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:3*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET3_BID} : TARGET3_BID; 
      assign  TARGET_BRESP[(3+1)*2-1:3*2]                                                                     = TARGET3_BRESP;  
      assign  TARGET_BUSER[(3+1)*USER_WIDTH-1:3*USER_WIDTH]                                                   = TARGET3_BUSER;  
      assign  TARGET_BVALID[3]                                                                                = TARGET3_BVALID;        
      assign  TARGET_ARREADY[3]                                                                               = TARGET3_ARREADY;        
      assign  TARGET_RID[(3+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:3*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET3_RID} : TARGET3_RID;   
      assign  TARGET_RDATA[SDW_UPPER_VEC[(3+1)*13-1:13*3]-1:SDW_LOWER_VEC[(3+1)*13-1:13*3]]                   = TARGET3_RDATA;  
      assign  TARGET_RRESP[(3+1)*2-1:3*2]                                                                     = TARGET3_RRESP;  
      assign  TARGET_RLAST[3]                                                                                 = TARGET3_RLAST;  
      assign  TARGET_RUSER[(3+1)*USER_WIDTH-1:3*USER_WIDTH]                                                   = TARGET3_RUSER;  
      assign  TARGET_RVALID[3]                                                                                = TARGET3_RVALID;
    end
    
  if ( NUM_TARGETS > 4 )
    begin
      //===================================================================
      //Target4 Combine Signals
      //===================================================================
      //======================= TARGET4 TO/FROM External Side=================
      //Outputs
      //
      assign  TARGET4_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[4*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(4+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:4*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET4_AWADDR   = TARGET_AWADDR[(4+1)*ADDR_WIDTH-1:4*ADDR_WIDTH];  
      assign  TARGET4_AWLEN    = TARGET_AWLEN[(4+1)*8-1:4*8];  
      assign  TARGET4_AWSIZE   = TARGET_AWSIZE[(4+1)*3-1:4*3];  
      assign  TARGET4_AWBURST  = TARGET_AWBURST[(4+1)*2-1:4*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET4_AWLOCK   = (TARGET4_TYPE  == 2'b11) ? TARGET_AWLOCK[(4+1)*2-1:4*2]   : {1'b0, TARGET_AWLOCK[4*2]};
      assign  TARGET4_AWCACHE  = TARGET_AWCACHE[(4+1)*4-1:4*4];  
      assign  TARGET4_AWPROT   = TARGET_AWPROT[(4+1)*3-1:4*3];  
      assign  TARGET4_AWREGION = TARGET_AWREGION[(4+1)*4-1:4*4];   
      assign  TARGET4_AWQOS    = TARGET_AWQOS[(4+1)*4-1:4*4];  
      assign  TARGET4_AWUSER   = TARGET_AWUSER[(4+1)*USER_WIDTH-1:4*USER_WIDTH];  
      assign  TARGET4_AWVALID  = TARGET_AWVALID[4];  
      assign  TARGET4_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[4*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(4+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:4*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET4_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(4+1)*13-1:13*4]-1:SDW_LOWER_VEC[(4+1)*13-1:13*4]];  
      assign  TARGET4_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(4+1)*13-1:13*4]/8-1:SDW_LOWER_VEC[(4+1)*13-1:13*4]/8];  
      assign  TARGET4_WLAST    = TARGET_WLAST[4];  
      assign  TARGET4_WUSER    = TARGET_WUSER[(4+1)*USER_WIDTH-1:4*USER_WIDTH];  
      assign  TARGET4_WVALID   = TARGET_WVALID[4];      
      assign  TARGET4_BREADY   = TARGET_BREADY[4];        
      assign  TARGET4_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[4*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(4+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:4*(NUM_INITIATORS_WIDTH+ID_WIDTH)];  
      assign  TARGET4_ARADDR   = TARGET_ARADDR[(4+1)*ADDR_WIDTH-1:4*ADDR_WIDTH];  
      assign  TARGET4_ARLEN    = TARGET_ARLEN[(4+1)*8-1:4*8];  
      assign  TARGET4_ARSIZE   = TARGET_ARSIZE[(4+1)*3-1:4*3];  
      assign  TARGET4_ARBURST  = TARGET_ARBURST[(4+1)*2-1:4*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET4_ARLOCK   = (TARGET4_TYPE  == 2'b11) ? TARGET_ARLOCK[(4+1)*2-1:4*2]   : {1'b0, TARGET_ARLOCK[4*2]};
      assign  TARGET4_ARCACHE  = TARGET_ARCACHE[(4+1)*4-1:4*4] ;  
      assign  TARGET4_ARPROT   = TARGET_ARPROT[(4+1)*3-1:4*3] ;  
      assign  TARGET4_ARREGION = TARGET_ARREGION[(4+1)*4-1:4*4];   
      assign  TARGET4_ARQOS    = TARGET_ARQOS[(4+1)*4-1:4*4];  
      assign  TARGET4_ARUSER   = TARGET_ARUSER[(4+1)*USER_WIDTH-1:4*USER_WIDTH];  
      assign  TARGET4_ARVALID  = TARGET_ARVALID[4];      
      assign  TARGET4_RREADY   = TARGET_RREADY[4];  

      //Inputs      
      assign  TARGET_AWREADY[4]                                                                               = TARGET4_AWREADY;          
      assign  TARGET_WREADY[4]                                                                                = TARGET4_WREADY;        
      assign  TARGET_BID[(4+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:4*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET4_BID} : TARGET4_BID; 
      assign  TARGET_BRESP[(4+1)*2-1:4*2]                                                                     = TARGET4_BRESP;  
      assign  TARGET_BUSER[(4+1)*USER_WIDTH-1:4*USER_WIDTH]                                                   = TARGET4_BUSER;  
      assign  TARGET_BVALID[4]                                                                                = TARGET4_BVALID;        
      assign  TARGET_ARREADY[4]                                                                               = TARGET4_ARREADY;        
      assign  TARGET_RID[(4+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:4*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET4_RID} : TARGET4_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(4+1)*13-1:13*4]-1:SDW_LOWER_VEC[(4+1)*13-1:13*4]]                   = TARGET4_RDATA;  
      assign  TARGET_RRESP[(4+1)*2-1:4*2]                                                                     = TARGET4_RRESP;  
      assign  TARGET_RLAST[4]                                                                                 = TARGET4_RLAST;  
      assign  TARGET_RUSER[(4+1)*USER_WIDTH-1:4*USER_WIDTH]                                                   = TARGET4_RUSER;  
      assign  TARGET_RVALID[4]                                                                                = TARGET4_RVALID;
    end
    
  if ( NUM_TARGETS > 5 )
    begin        
      //===================================================================
      //Target5 Combine Signals
      //===================================================================
      //======================= TARGET5 TO/FROM External Side=================
      //Outputs  
      assign  TARGET5_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[5*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_AWID[(5+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 5*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET5_AWADDR   = TARGET_AWADDR[(5+1)*ADDR_WIDTH-1:5*ADDR_WIDTH];  
      assign  TARGET5_AWLEN    = TARGET_AWLEN[(5+1)*8-1:5*8];  
      assign  TARGET5_AWSIZE   = TARGET_AWSIZE[(5+1)*3-1:5*3];  
      assign  TARGET5_AWBURST  = TARGET_AWBURST[(5+1)*2-1:5*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET5_AWLOCK   = (TARGET5_TYPE  == 2'b11) ? TARGET_AWLOCK[(5+1)*2-1:5*2]   : {1'b0, TARGET_AWLOCK[5*2]};
      assign  TARGET5_AWCACHE  = TARGET_AWCACHE[(5+1)*4-1:5*4];  
      assign  TARGET5_AWPROT   = TARGET_AWPROT[(5+1)*3-1:5*3];  
      assign  TARGET5_AWREGION = TARGET_AWREGION[(5+1)*4-1:5*4];   
      assign  TARGET5_AWQOS    = TARGET_AWQOS[(5+1)*4-1:5*4];  
      assign  TARGET5_AWUSER   = TARGET_AWUSER[(5+1)*USER_WIDTH-1:5*USER_WIDTH];  
      assign  TARGET5_AWVALID  = TARGET_AWVALID[5];
      assign  TARGET5_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[5*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_WID[(5+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 5*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET5_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(5+1)*13-1:13*5]-1:SDW_LOWER_VEC[(5+1)*13-1:13*5]];  
      assign  TARGET5_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(5+1)*13-1:13*5]/8-1:SDW_LOWER_VEC[(5+1)*13-1:13*5]/8];  
      assign  TARGET5_WLAST    = TARGET_WLAST[5];  
      assign  TARGET5_WUSER    = TARGET_WUSER[(5+1)*USER_WIDTH-1:5*USER_WIDTH];  
      assign  TARGET5_WVALID   = TARGET_WVALID[5];      
      assign  TARGET5_BREADY   = TARGET_BREADY[5];        
      assign  TARGET5_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[5*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_ARID[(5+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 5*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET5_ARADDR   = TARGET_ARADDR[(5+1)*ADDR_WIDTH-1:5*ADDR_WIDTH];  
      assign  TARGET5_ARLEN    = TARGET_ARLEN[(5+1)*8-1:5*8];  
      assign  TARGET5_ARSIZE   = TARGET_ARSIZE[(5+1)*3-1:5*3];  
      assign  TARGET5_ARBURST  = TARGET_ARBURST[(5+1)*2-1:5*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET5_ARLOCK   = (TARGET5_TYPE  == 2'b11) ? TARGET_ARLOCK[(5+1)*2-1:5*2]   : {1'b0, TARGET_ARLOCK[5*2]};
      assign  TARGET5_ARCACHE  = TARGET_ARCACHE[(5+1)*4-1:5*4] ;  
      assign  TARGET5_ARPROT   = TARGET_ARPROT[(5+1)*3-1:5*3] ;  
      assign  TARGET5_ARREGION = TARGET_ARREGION[(5+1)*4-1:5*4];   
      assign  TARGET5_ARQOS    = TARGET_ARQOS[(5+1)*4-1:5*4];  
      assign  TARGET5_ARUSER   = TARGET_ARUSER[(5+1)*USER_WIDTH-1:5*USER_WIDTH];  
      assign  TARGET5_ARVALID  = TARGET_ARVALID[5];      
      assign  TARGET5_RREADY   = TARGET_RREADY[5];  

      //Inputs      
      assign  TARGET_AWREADY[5]                                                                               = TARGET5_AWREADY;          
      assign  TARGET_WREADY[5]                                                                                = TARGET5_WREADY;        
      assign  TARGET_BID[(5+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:5*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET5_BID} : TARGET5_BID; 
      assign  TARGET_BRESP[(5+1)*2-1:5*2]                                                                     = TARGET5_BRESP;  
      assign  TARGET_BUSER[(5+1)*USER_WIDTH-1:5*USER_WIDTH]                                                   = TARGET5_BUSER;  
      assign  TARGET_BVALID[5]                                                                                = TARGET5_BVALID;        
      assign  TARGET_ARREADY[5]                                                                               = TARGET5_ARREADY;        
      assign  TARGET_RID[(5+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:5*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET5_RID} : TARGET5_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(5+1)*13-1:13*5]-1:SDW_LOWER_VEC[(5+1)*13-1:13*5]]                   = TARGET5_RDATA;  
      assign  TARGET_RRESP[(5+1)*2-1:5*2]                                                                     = TARGET5_RRESP;  
      assign  TARGET_RLAST[5]                                                                                 = TARGET5_RLAST;  
      assign  TARGET_RUSER[(5+1)*USER_WIDTH-1:5*USER_WIDTH]                                                   = TARGET5_RUSER;  
      assign  TARGET_RVALID[5]                                                                                = TARGET5_RVALID;
    end
    
  if ( NUM_TARGETS > 6 )
    begin
      
      //===================================================================
      //Target6 Combine Signals
      //===================================================================
      //======================= TARGET6 TO/FROM External Side=================
      //Outputs
      assign  TARGET6_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[6*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_AWID[(6+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 6*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET6_AWADDR   = TARGET_AWADDR[(6+1)*ADDR_WIDTH-1:6*ADDR_WIDTH];  
      assign  TARGET6_AWLEN    = TARGET_AWLEN[(6+1)*8-1:6*8];  
      assign  TARGET6_AWSIZE   = TARGET_AWSIZE[(6+1)*3-1:6*3];  
      assign  TARGET6_AWBURST  = TARGET_AWBURST[(6+1)*2-1:6*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET6_AWLOCK   = (TARGET6_TYPE  == 2'b11) ? TARGET_AWLOCK[(6+1)*2-1:6*2]   : {1'b0, TARGET_AWLOCK[6*2]};
      assign  TARGET6_AWCACHE  = TARGET_AWCACHE[(6+1)*4-1:6*4];  
      assign  TARGET6_AWPROT   = TARGET_AWPROT[(6+1)*3-1:6*3];  
      assign  TARGET6_AWREGION = TARGET_AWREGION[(6+1)*4-1:6*4];   
      assign  TARGET6_AWQOS    = TARGET_AWQOS[(6+1)*4-1:6*4];  
      assign  TARGET6_AWUSER   = TARGET_AWUSER[(6+1)*USER_WIDTH-1:6*USER_WIDTH];  
      assign  TARGET6_AWVALID  = TARGET_AWVALID[6];  
      assign  TARGET6_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[6*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_WID[(6+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 6*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET6_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(6+1)*13-1:13*6]-1:SDW_LOWER_VEC[(6+1)*13-1:13*6]];  
      assign  TARGET6_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(6+1)*13-1:13*6]/8-1:SDW_LOWER_VEC[(6+1)*13-1:13*6]/8];  
      assign  TARGET6_WLAST    = TARGET_WLAST[6];  
      assign  TARGET6_WUSER    = TARGET_WUSER[(6+1)*USER_WIDTH-1:6*USER_WIDTH];  
      assign  TARGET6_WVALID   = TARGET_WVALID[6];      
      assign  TARGET6_BREADY   = TARGET_BREADY[6];        
      assign  TARGET6_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[6*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_ARID[(6+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 6*(NUM_INITIATORS_WIDTH+ID_WIDTH)];      
      assign  TARGET6_ARADDR   = TARGET_ARADDR[(6+1)*ADDR_WIDTH-1:6*ADDR_WIDTH];  
      assign  TARGET6_ARLEN    = TARGET_ARLEN[(6+1)*8-1:6*8];  
      assign  TARGET6_ARSIZE   = TARGET_ARSIZE[(6+1)*3-1:6*3];  
      assign  TARGET6_ARBURST  = TARGET_ARBURST[(6+1)*2-1:6*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET6_ARLOCK   = (TARGET6_TYPE  == 2'b11) ? TARGET_ARLOCK[(6+1)*2-1:6*2]   : {1'b0, TARGET_ARLOCK[6*2]};
      assign  TARGET6_ARCACHE  = TARGET_ARCACHE[(6+1)*4-1:6*4] ;  
      assign  TARGET6_ARPROT   = TARGET_ARPROT[(6+1)*3-1:6*3] ;  
      assign  TARGET6_ARREGION = TARGET_ARREGION[(6+1)*4-1:6*4];   
      assign  TARGET6_ARQOS    = TARGET_ARQOS[(6+1)*4-1:6*4];  
      assign  TARGET6_ARUSER   = TARGET_ARUSER[(6+1)*USER_WIDTH-1:6*USER_WIDTH];  
      assign  TARGET6_ARVALID  = TARGET_ARVALID[6];      
      assign  TARGET6_RREADY   = TARGET_RREADY[6];  

      //Inputs      
      assign  TARGET_AWREADY[6]                                                                               = TARGET6_AWREADY;          
      assign  TARGET_WREADY[6]                                                                                = TARGET6_WREADY;        
      assign  TARGET_BID[(6+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:6*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET6_BID} : TARGET6_BID; 
      assign  TARGET_BRESP[(6+1)*2-1:6*2]                                                                     = TARGET6_BRESP;  
      assign  TARGET_BUSER[(6+1)*USER_WIDTH-1:6*USER_WIDTH]                                                   = TARGET6_BUSER;  
      assign  TARGET_BVALID[6]                                                                                = TARGET6_BVALID;        
      assign  TARGET_ARREADY[6]                                                                               = TARGET6_ARREADY;        
      assign  TARGET_RID[(6+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:6*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET6_RID} : TARGET6_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(6+1)*13-1:13*6]-1:SDW_LOWER_VEC[(6+1)*13-1:13*6]]                   = TARGET6_RDATA;  
      assign  TARGET_RRESP[(6+1)*2-1:6*2]                                                                     = TARGET6_RRESP;  
      assign  TARGET_RLAST[6]                                                                                 = TARGET6_RLAST;  
      assign  TARGET_RUSER[(6+1)*USER_WIDTH-1:6*USER_WIDTH]                                                   = TARGET6_RUSER;  
      assign  TARGET_RVALID[6]                                                                                = TARGET6_RVALID;
    end
      
  if ( NUM_TARGETS > 7 )
    begin
      //===================================================================
      //Target7 Combine Signals
      //===================================================================
      //======================= TARGET7 TO/FROM External Side=================
      //Outputs
      assign  TARGET7_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[7*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_AWID[(7+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 7*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET7_AWADDR   = TARGET_AWADDR[(7+1)*ADDR_WIDTH-1:7*ADDR_WIDTH];  
      assign  TARGET7_AWLEN    = TARGET_AWLEN[(7+1)*8-1:7*8];  
      assign  TARGET7_AWSIZE   = TARGET_AWSIZE[(7+1)*3-1:7*3];  
      assign  TARGET7_AWBURST  = TARGET_AWBURST[(7+1)*2-1:7*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET7_AWLOCK   = (TARGET7_TYPE  == 2'b11) ? TARGET_AWLOCK[(7+1)*2-1:7*2]   : {1'b0, TARGET_AWLOCK[7*2]};
      assign  TARGET7_AWCACHE  = TARGET_AWCACHE[(7+1)*4-1:7*4];  
      assign  TARGET7_AWPROT   = TARGET_AWPROT[(7+1)*3-1:7*3];  
      assign  TARGET7_AWREGION = TARGET_AWREGION[(7+1)*4-1:7*4];   
      assign  TARGET7_AWQOS    = TARGET_AWQOS[(7+1)*4-1:7*4];  
      assign  TARGET7_AWUSER   = TARGET_AWUSER[(7+1)*USER_WIDTH-1:7*USER_WIDTH];  
      assign  TARGET7_AWVALID  = TARGET_AWVALID[7];  
      assign  TARGET7_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[7*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_WID[(7+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 7*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET7_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(7+1)*13-1:13*7]-1:SDW_LOWER_VEC[(7+1)*13-1:13*7]];  
      assign  TARGET7_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(7+1)*13-1:13*7]/8-1:SDW_LOWER_VEC[(7+1)*13-1:13*7]/8];  
      assign  TARGET7_WLAST    = TARGET_WLAST[7];  
      assign  TARGET7_WUSER    = TARGET_WUSER[(7+1)*USER_WIDTH-1:7*USER_WIDTH];  
      assign  TARGET7_WVALID   = TARGET_WVALID[7];      
      assign  TARGET7_BREADY   = TARGET_BREADY[7];        
      assign  TARGET7_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[7*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_ARID[(7+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 7*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET7_ARADDR   = TARGET_ARADDR[(7+1)*ADDR_WIDTH-1:7*ADDR_WIDTH];  
      assign  TARGET7_ARLEN    = TARGET_ARLEN[(7+1)*8-1:7*8];  
      assign  TARGET7_ARSIZE   = TARGET_ARSIZE[(7+1)*3-1:7*3];  
      assign  TARGET7_ARBURST  = TARGET_ARBURST[(7+1)*2-1:7*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET7_ARLOCK   = (TARGET7_TYPE  == 2'b11) ? TARGET_ARLOCK[(7+1)*2-1:7*2]   : {1'b0, TARGET_ARLOCK[7*2]};
      assign  TARGET7_ARCACHE  = TARGET_ARCACHE[(7+1)*4-1:7*4] ;  
      assign  TARGET7_ARPROT   = TARGET_ARPROT[(7+1)*3-1:7*3] ;  
      assign  TARGET7_ARREGION = TARGET_ARREGION[(7+1)*4-1:7*4];   
      assign  TARGET7_ARQOS    = TARGET_ARQOS[(7+1)*4-1:7*4];  
      assign  TARGET7_ARUSER   = TARGET_ARUSER[(7+1)*USER_WIDTH-1:7*USER_WIDTH];  
      assign  TARGET7_ARVALID  = TARGET_ARVALID[7];      
      assign  TARGET7_RREADY   = TARGET_RREADY[7];  

      //Inputs      
      assign  TARGET_AWREADY[7]                                                                               = TARGET7_AWREADY;          
      assign  TARGET_WREADY[7]                                                                                = TARGET7_WREADY;        
      assign  TARGET_BID[(7+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:7*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET7_BID} : TARGET7_BID; 
      assign  TARGET_BRESP[(7+1)*2-1:7*2]                                                                     = TARGET7_BRESP;  
      assign  TARGET_BUSER[(7+1)*USER_WIDTH-1:7*USER_WIDTH]                                                   = TARGET7_BUSER;  
      assign  TARGET_BVALID[7]                                                                                = TARGET7_BVALID;        
      assign  TARGET_ARREADY[7]                                                                               = TARGET7_ARREADY;        
      assign  TARGET_RID[(7+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:7*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET7_RID} : TARGET7_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(7+1)*13-1:13*7]-1:SDW_LOWER_VEC[(7+1)*13-1:13*7]]                   = TARGET7_RDATA;  
      assign  TARGET_RRESP[(7+1)*2-1:7*2]                                                                     = TARGET7_RRESP;  
      assign  TARGET_RLAST[7]                                                                                 = TARGET7_RLAST;  
      assign  TARGET_RUSER[(7+1)*USER_WIDTH-1:7*USER_WIDTH]                                                   = TARGET7_RUSER;  
      assign  TARGET_RVALID[7]                                                                                = TARGET7_RVALID;
    end
    
   
    
    if ( NUM_TARGETS > 8 )
    begin
      //===================================================================
      //Target8 Combine Signals
      //===================================================================
      //======================= TARGET8 TO/FROM External Side=================
      //Outputs
      assign  TARGET8_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[8*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_AWID[(8+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 8*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET8_AWADDR   = TARGET_AWADDR[(8+1)*ADDR_WIDTH-1:8*ADDR_WIDTH];  
      assign  TARGET8_AWLEN    = TARGET_AWLEN[(8+1)*8-1:8*8];  
      assign  TARGET8_AWSIZE   = TARGET_AWSIZE[(8+1)*3-1:8*3];  
      assign  TARGET8_AWBURST  = TARGET_AWBURST[(8+1)*2-1:8*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET8_AWLOCK   = (TARGET8_TYPE  == 2'b11) ? TARGET_AWLOCK[(8+1)*2-1:8*2]   : {1'b0, TARGET_AWLOCK[8*2]};
      assign  TARGET8_AWCACHE  = TARGET_AWCACHE[(8+1)*4-1:8*4];  
      assign  TARGET8_AWPROT   = TARGET_AWPROT[(8+1)*3-1:8*3];  
      assign  TARGET8_AWREGION = TARGET_AWREGION[(8+1)*4-1:8*4];   
      assign  TARGET8_AWQOS    = TARGET_AWQOS[(8+1)*4-1:8*4];  
      assign  TARGET8_AWUSER   = TARGET_AWUSER[(8+1)*USER_WIDTH-1:8*USER_WIDTH];  
      assign  TARGET8_AWVALID  = TARGET_AWVALID[8];  
      assign  TARGET8_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[8*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_WID[(8+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 8*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET8_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(8+1)*13-1:13*8]-1:SDW_LOWER_VEC[(8+1)*13-1:13*8]];  
      assign  TARGET8_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(8+1)*13-1:13*8]/8-1:SDW_LOWER_VEC[(8+1)*13-1:13*8]/8];  
      assign  TARGET8_WLAST    = TARGET_WLAST[8];  
      assign  TARGET8_WUSER    = TARGET_WUSER[(8+1)*USER_WIDTH-1:8*USER_WIDTH];  
      assign  TARGET8_WVALID   = TARGET_WVALID[8];      
      assign  TARGET8_BREADY   = TARGET_BREADY[8];        
      assign  TARGET8_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[8*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_ARID[(8+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 8*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET8_ARADDR   = TARGET_ARADDR[(8+1)*ADDR_WIDTH-1:8*ADDR_WIDTH];  
      assign  TARGET8_ARLEN    = TARGET_ARLEN[(8+1)*8-1:8*8];  
      assign  TARGET8_ARSIZE   = TARGET_ARSIZE[(8+1)*3-1:8*3];  
      assign  TARGET8_ARBURST  = TARGET_ARBURST[(8+1)*2-1:8*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET8_ARLOCK   = (TARGET8_TYPE  == 2'b11) ? TARGET_ARLOCK[(8+1)*2-1:8*2]   : {1'b0, TARGET_ARLOCK[8*2]};
      assign  TARGET8_ARCACHE  = TARGET_ARCACHE[(8+1)*4-1:8*4] ;  
      assign  TARGET8_ARPROT   = TARGET_ARPROT[(8+1)*3-1:8*3] ;  
      assign  TARGET8_ARREGION = TARGET_ARREGION[(8+1)*4-1:8*4];   
      assign  TARGET8_ARQOS    = TARGET_ARQOS[(8+1)*4-1:8*4];  
      assign  TARGET8_ARUSER   = TARGET_ARUSER[(8+1)*USER_WIDTH-1:8*USER_WIDTH];  
      assign  TARGET8_ARVALID  = TARGET_ARVALID[8];      
      assign  TARGET8_RREADY   = TARGET_RREADY[8];  

      //Inputs      
      assign  TARGET_AWREADY[8]                                                                               = TARGET8_AWREADY;          
      assign  TARGET_WREADY[8]                                                                                = TARGET8_WREADY;        
      assign  TARGET_BID[(8+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:8*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET8_BID} : TARGET8_BID; 
      assign  TARGET_BRESP[(8+1)*2-1:8*2]                                                                     = TARGET8_BRESP;  
      assign  TARGET_BUSER[(8+1)*USER_WIDTH-1:8*USER_WIDTH]                                                   = TARGET8_BUSER;  
      assign  TARGET_BVALID[8]                                                                                = TARGET8_BVALID;        
      assign  TARGET_ARREADY[8]                                                                               = TARGET8_ARREADY;        
      assign  TARGET_RID[(8+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:8*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET8_RID} : TARGET8_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(8+1)*13-1:13*8]-1:SDW_LOWER_VEC[(8+1)*13-1:13*8]]                   = TARGET8_RDATA;  
      assign  TARGET_RRESP[(8+1)*2-1:8*2]                                                                     = TARGET8_RRESP;  
      assign  TARGET_RLAST[8]                                                                                 = TARGET8_RLAST;  
      assign  TARGET_RUSER[(8+1)*USER_WIDTH-1:8*USER_WIDTH]                                                   = TARGET8_RUSER;  
      assign  TARGET_RVALID[8]                                                                                = TARGET8_RVALID;
    end
    
    if ( NUM_TARGETS > 9 )
    begin
      //===================================================================
      //Target9 Combine Signals
      //===================================================================
      //======================= TARGET9 TO/FROM External Side=================
      //Outputs
      assign  TARGET9_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[9*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_AWID[(9+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 9*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET9_AWADDR   = TARGET_AWADDR[(9+1)*ADDR_WIDTH-1:9*ADDR_WIDTH];  
      assign  TARGET9_AWLEN    = TARGET_AWLEN[(9+1)*8-1:9*8];  
      assign  TARGET9_AWSIZE   = TARGET_AWSIZE[(9+1)*3-1:9*3];  
      assign  TARGET9_AWBURST  = TARGET_AWBURST[(9+1)*2-1:9*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET9_AWLOCK   = (TARGET9_TYPE  == 2'b11) ? TARGET_AWLOCK[(9+1)*2-1:9*2]   : {1'b0, TARGET_AWLOCK[9*2]};
      assign  TARGET9_AWCACHE  = TARGET_AWCACHE[(9+1)*4-1:9*4];  
      assign  TARGET9_AWPROT   = TARGET_AWPROT[(9+1)*3-1:9*3];  
      assign  TARGET9_AWREGION = TARGET_AWREGION[(9+1)*4-1:9*4];   
      assign  TARGET9_AWQOS    = TARGET_AWQOS[(9+1)*4-1:9*4];  
      assign  TARGET9_AWUSER   = TARGET_AWUSER[(9+1)*USER_WIDTH-1:9*USER_WIDTH];  
      assign  TARGET9_AWVALID  = TARGET_AWVALID[9];  
      assign  TARGET9_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[9*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_WID[(9+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 9*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET9_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(9+1)*13-1:13*9]-1:SDW_LOWER_VEC[(9+1)*13-1:13*9]];  
      assign  TARGET9_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(9+1)*13-1:13*9]/8-1:SDW_LOWER_VEC[(9+1)*13-1:13*9]/8];  
      assign  TARGET9_WLAST    = TARGET_WLAST[9];  
      assign  TARGET9_WUSER    = TARGET_WUSER[(9+1)*USER_WIDTH-1:9*USER_WIDTH];  
      assign  TARGET9_WVALID   = TARGET_WVALID[9];      
      assign  TARGET9_BREADY   = TARGET_BREADY[9];        
      assign  TARGET9_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[9*(ID_WIDTH+1) +: ID_WIDTH]  : TARGET_ARID[(9+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 9*(NUM_INITIATORS_WIDTH+ID_WIDTH)];      
      assign  TARGET9_ARADDR   = TARGET_ARADDR[(9+1)*ADDR_WIDTH-1:9*ADDR_WIDTH];  
      assign  TARGET9_ARLEN    = TARGET_ARLEN[(9+1)*8-1:9*8];  
      assign  TARGET9_ARSIZE   = TARGET_ARSIZE[(9+1)*3-1:9*3];  
      assign  TARGET9_ARBURST  = TARGET_ARBURST[(9+1)*2-1:9*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET9_ARLOCK   = (TARGET9_TYPE  == 2'b11) ? TARGET_ARLOCK[(9+1)*2-1:9*2]   : {1'b0, TARGET_ARLOCK[9*2]};
      assign  TARGET9_ARCACHE  = TARGET_ARCACHE[(9+1)*4-1:9*4] ;  
      assign  TARGET9_ARPROT   = TARGET_ARPROT[(9+1)*3-1:9*3] ;  
      assign  TARGET9_ARREGION = TARGET_ARREGION[(9+1)*4-1:9*4];   
      assign  TARGET9_ARQOS    = TARGET_ARQOS[(9+1)*4-1:9*4];  
      assign  TARGET9_ARUSER   = TARGET_ARUSER[(9+1)*USER_WIDTH-1:9*USER_WIDTH];  
      assign  TARGET9_ARVALID  = TARGET_ARVALID[9];      
      assign  TARGET9_RREADY   = TARGET_RREADY[9];  

      //Inputs      
      assign  TARGET_AWREADY[9]                                                                               = TARGET9_AWREADY;          
      assign  TARGET_WREADY[9]                                                                                = TARGET9_WREADY;        
      assign  TARGET_BID[(9+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:9*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET9_BID} : TARGET9_BID; 
      assign  TARGET_BRESP[(9+1)*2-1:9*2]                                                                     = TARGET9_BRESP;  
      assign  TARGET_BUSER[(9+1)*USER_WIDTH-1:9*USER_WIDTH]                                                   = TARGET9_BUSER;  
      assign  TARGET_BVALID[9]                                                                                = TARGET9_BVALID;        
      assign  TARGET_ARREADY[9]                                                                               = TARGET9_ARREADY;        
      assign  TARGET_RID[(9+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:9*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET9_RID} : TARGET9_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(9+1)*13-1:13*9]-1:SDW_LOWER_VEC[(9+1)*13-1:13*9]]                   = TARGET9_RDATA;  
      assign  TARGET_RRESP[(9+1)*2-1:9*2]                                                                     = TARGET9_RRESP;  
      assign  TARGET_RLAST[9]                                                                                 = TARGET9_RLAST;  
      assign  TARGET_RUSER[(9+1)*USER_WIDTH-1:9*USER_WIDTH]                                                   = TARGET9_RUSER;  
      assign  TARGET_RVALID[9]                                                                                = TARGET9_RVALID;
    end
    
    if ( NUM_TARGETS > 10 )
    begin
      //===================================================================
      //Target10 Combine Signals
      //===================================================================
      //======================= TARGET10 TO/FROM External Side=================
      //Outputs
      assign  TARGET10_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[10*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(10+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 10*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET10_AWADDR   = TARGET_AWADDR[(10+1)*ADDR_WIDTH-1:10*ADDR_WIDTH];  
      assign  TARGET10_AWLEN    = TARGET_AWLEN[(10+1)*8-1:10*8];  
      assign  TARGET10_AWSIZE   = TARGET_AWSIZE[(10+1)*3-1:10*3];  
      assign  TARGET10_AWBURST  = TARGET_AWBURST[(10+1)*2-1:10*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET10_AWLOCK   = (TARGET10_TYPE == 2'b11) ? TARGET_AWLOCK[(10+1)*2-1:10*2] : {1'b0, TARGET_AWLOCK[10*2]};
      assign  TARGET10_AWCACHE  = TARGET_AWCACHE[(10+1)*4-1:10*4];  
      assign  TARGET10_AWPROT   = TARGET_AWPROT[(10+1)*3-1:10*3];  
      assign  TARGET10_AWREGION = TARGET_AWREGION[(10+1)*4-1:10*4];   
      assign  TARGET10_AWQOS    = TARGET_AWQOS[(10+1)*4-1:10*4];  
      assign  TARGET10_AWUSER   = TARGET_AWUSER[(10+1)*USER_WIDTH-1:10*USER_WIDTH];  
      assign  TARGET10_AWVALID  = TARGET_AWVALID[10];  
      assign  TARGET10_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[10*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(10+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 10*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET10_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(10+1)*13-1:13*10]-1:SDW_LOWER_VEC[(10+1)*13-1:13*10]];  
      assign  TARGET10_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(10+1)*13-1:13*10]/8-1:SDW_LOWER_VEC[(10+1)*13-1:13*10]/8];  
      assign  TARGET10_WLAST    = TARGET_WLAST[10];  
      assign  TARGET10_WUSER    = TARGET_WUSER[(10+1)*USER_WIDTH-1:10*USER_WIDTH];  
      assign  TARGET10_WVALID   = TARGET_WVALID[10];      
      assign  TARGET10_BREADY   = TARGET_BREADY[10];        
      assign  TARGET10_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[10*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(10+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 10*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET10_ARADDR   = TARGET_ARADDR[(10+1)*ADDR_WIDTH-1:10*ADDR_WIDTH];  
      assign  TARGET10_ARLEN    = TARGET_ARLEN[(10+1)*8-1:10*8];  
      assign  TARGET10_ARSIZE   = TARGET_ARSIZE[(10+1)*3-1:10*3];  
      assign  TARGET10_ARBURST  = TARGET_ARBURST[(10+1)*2-1:10*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET10_ARLOCK   = (TARGET10_TYPE == 2'b11) ? TARGET_ARLOCK[(10+1)*2-1:10*2] : {1'b0, TARGET_ARLOCK[10*2]};
      assign  TARGET10_ARCACHE  = TARGET_ARCACHE[(10+1)*4-1:10*4] ;  
      assign  TARGET10_ARPROT   = TARGET_ARPROT[(10+1)*3-1:10*3] ;  
      assign  TARGET10_ARREGION = TARGET_ARREGION[(10+1)*4-1:10*4];   
      assign  TARGET10_ARQOS    = TARGET_ARQOS[(10+1)*4-1:10*4];  
      assign  TARGET10_ARUSER   = TARGET_ARUSER[(10+1)*USER_WIDTH-1:10*USER_WIDTH];  
      assign  TARGET10_ARVALID  = TARGET_ARVALID[10];      
      assign  TARGET10_RREADY   = TARGET_RREADY[10];  

      //Inputs      
      assign  TARGET_AWREADY[10]                                                                               = TARGET10_AWREADY;          
      assign  TARGET_WREADY[10]                                                                                = TARGET10_WREADY;        
      assign  TARGET_BID[(10+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:10*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET10_BID} : TARGET10_BID; 
      assign  TARGET_BRESP[(10+1)*2-1:10*2]                                                                    = TARGET10_BRESP;  
      assign  TARGET_BUSER[(10+1)*USER_WIDTH-1:10*USER_WIDTH]                                                  = TARGET10_BUSER;  
      assign  TARGET_BVALID[10]                                                                                = TARGET10_BVALID;        
      assign  TARGET_ARREADY[10]                                                                               = TARGET10_ARREADY;        
      assign  TARGET_RID[(10+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:10*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET10_RID} : TARGET10_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(10+1)*13-1:13*10]-1:SDW_LOWER_VEC[(10+1)*13-1:13*10]]                = TARGET10_RDATA;  
      assign  TARGET_RRESP[(10+1)*2-1:10*2]                                                                    = TARGET10_RRESP;  
      assign  TARGET_RLAST[10]                                                                                 = TARGET10_RLAST;  
      assign  TARGET_RUSER[(10+1)*USER_WIDTH-1:10*USER_WIDTH]                                                  = TARGET10_RUSER;  
      assign  TARGET_RVALID[10]                                                                                = TARGET10_RVALID;
    end
    
    if ( NUM_TARGETS > 11 )
    begin
      //===================================================================
      //Target11 Combine Signals
      //===================================================================
      //======================= TARGET11 TO/FROM External Side=================
      //Outputs
      assign  TARGET11_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[11*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(11+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 11*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET11_AWADDR   = TARGET_AWADDR[(11+1)*ADDR_WIDTH-1:11*ADDR_WIDTH];  
      assign  TARGET11_AWLEN    = TARGET_AWLEN[(11+1)*8-1:11*8];  
      assign  TARGET11_AWSIZE   = TARGET_AWSIZE[(11+1)*3-1:11*3];  
      assign  TARGET11_AWBURST  = TARGET_AWBURST[(11+1)*2-1:11*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET11_AWLOCK   = (TARGET11_TYPE == 2'b11) ? TARGET_AWLOCK[(11+1)*2-1:11*2] : {1'b0, TARGET_AWLOCK[11*2]};
      assign  TARGET11_AWCACHE  = TARGET_AWCACHE[(11+1)*4-1:11*4];  
      assign  TARGET11_AWPROT   = TARGET_AWPROT[(11+1)*3-1:11*3];  
      assign  TARGET11_AWREGION = TARGET_AWREGION[(11+1)*4-1:11*4];   
      assign  TARGET11_AWQOS    = TARGET_AWQOS[(11+1)*4-1:11*4];  
      assign  TARGET11_AWUSER   = TARGET_AWUSER[(11+1)*USER_WIDTH-1:11*USER_WIDTH];  
      assign  TARGET11_AWVALID  = TARGET_AWVALID[11];  
      assign  TARGET11_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[11*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(11+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 11*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET11_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(11+1)*13-1:13*11]-1:SDW_LOWER_VEC[(11+1)*13-1:13*11]];  
      assign  TARGET11_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(11+1)*13-1:13*11]/8-1:SDW_LOWER_VEC[(11+1)*13-1:13*11]/8];  
      assign  TARGET11_WLAST    = TARGET_WLAST[11];  
      assign  TARGET11_WUSER    = TARGET_WUSER[(11+1)*USER_WIDTH-1:11*USER_WIDTH];  
      assign  TARGET11_WVALID   = TARGET_WVALID[11];      
      assign  TARGET11_BREADY   = TARGET_BREADY[11];        
      assign  TARGET11_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[11*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(11+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 11*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET11_ARADDR   = TARGET_ARADDR[(11+1)*ADDR_WIDTH-1:11*ADDR_WIDTH];  
      assign  TARGET11_ARLEN    = TARGET_ARLEN[(11+1)*8-1:11*8];  
      assign  TARGET11_ARSIZE   = TARGET_ARSIZE[(11+1)*3-1:11*3];  
      assign  TARGET11_ARBURST  = TARGET_ARBURST[(11+1)*2-1:11*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET11_ARLOCK   = (TARGET11_TYPE == 2'b11) ? TARGET_ARLOCK[(11+1)*2-1:11*2] : {1'b0, TARGET_ARLOCK[11*2]};
      assign  TARGET11_ARCACHE  = TARGET_ARCACHE[(11+1)*4-1:11*4] ;  
      assign  TARGET11_ARPROT   = TARGET_ARPROT[(11+1)*3-1:11*3] ;  
      assign  TARGET11_ARREGION = TARGET_ARREGION[(11+1)*4-1:11*4];   
      assign  TARGET11_ARQOS    = TARGET_ARQOS[(11+1)*4-1:11*4];  
      assign  TARGET11_ARUSER   = TARGET_ARUSER[(11+1)*USER_WIDTH-1:11*USER_WIDTH];  
      assign  TARGET11_ARVALID  = TARGET_ARVALID[11];      
      assign  TARGET11_RREADY   = TARGET_RREADY[11];  

      //Inputs      
      assign  TARGET_AWREADY[11]                                                                              = TARGET11_AWREADY;          
      assign  TARGET_WREADY[11]                                                                               = TARGET11_WREADY;        
      assign  TARGET_BID[(11+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:11*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET11_BID} : TARGET11_BID; 
      assign  TARGET_BRESP[(11+1)*2-1:11*2]                                                                   = TARGET11_BRESP;  
      assign  TARGET_BUSER[(11+1)*USER_WIDTH-1:11*USER_WIDTH]                                                 = TARGET11_BUSER;  
      assign  TARGET_BVALID[11]                                                                               = TARGET11_BVALID;        
      assign  TARGET_ARREADY[11]                                                                              = TARGET11_ARREADY;        
      assign  TARGET_RID[(11+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:11*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET11_RID} : TARGET11_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(11+1)*13-1:13*11]-1:SDW_LOWER_VEC[(11+1)*13-1:13*11]]               = TARGET11_RDATA;  
      assign  TARGET_RRESP[(11+1)*2-1:11*2]                                                                   = TARGET11_RRESP;  
      assign  TARGET_RLAST[11]                                                                                = TARGET11_RLAST;  
      assign  TARGET_RUSER[(11+1)*USER_WIDTH-1:11*USER_WIDTH]                                                 = TARGET11_RUSER;  
      assign  TARGET_RVALID[11]                                                                               = TARGET11_RVALID;
    end
    
    if ( NUM_TARGETS > 12 )
    begin
      //===================================================================
      //Target12 Combine Signals
      //===================================================================
      //======================= TARGET12 TO/FROM External Side=================
      //Outputs
      assign  TARGET12_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[12*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(12+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 12*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET12_AWADDR   = TARGET_AWADDR[(12+1)*ADDR_WIDTH-1:12*ADDR_WIDTH];  
      assign  TARGET12_AWLEN    = TARGET_AWLEN[(12+1)*8-1:12*8];  
      assign  TARGET12_AWSIZE   = TARGET_AWSIZE[(12+1)*3-1:12*3];  
      assign  TARGET12_AWBURST  = TARGET_AWBURST[(12+1)*2-1:12*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET12_AWLOCK   = (TARGET12_TYPE == 2'b11) ? TARGET_AWLOCK[(12+1)*2-1:12*2] : {1'b0, TARGET_AWLOCK[12*2]};
      assign  TARGET12_AWCACHE  = TARGET_AWCACHE[(12+1)*4-1:12*4];  
      assign  TARGET12_AWPROT   = TARGET_AWPROT[(12+1)*3-1:12*3];  
      assign  TARGET12_AWREGION = TARGET_AWREGION[(12+1)*4-1:12*4];   
      assign  TARGET12_AWQOS    = TARGET_AWQOS[(12+1)*4-1:12*4];  
      assign  TARGET12_AWUSER   = TARGET_AWUSER[(12+1)*USER_WIDTH-1:12*USER_WIDTH];  
      assign  TARGET12_AWVALID  = TARGET_AWVALID[12];  
      assign  TARGET12_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[12*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(12+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 12*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET12_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(12+1)*13-1:13*12]-1:SDW_LOWER_VEC[(12+1)*13-1:13*12]];  
      assign  TARGET12_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(12+1)*13-1:13*12]/8-1:SDW_LOWER_VEC[(12+1)*13-1:13*12]/8];  
      assign  TARGET12_WLAST    = TARGET_WLAST[12];  
      assign  TARGET12_WUSER    = TARGET_WUSER[(12+1)*USER_WIDTH-1:12*USER_WIDTH];  
      assign  TARGET12_WVALID   = TARGET_WVALID[12];      
      assign  TARGET12_BREADY   = TARGET_BREADY[12];        
      assign  TARGET12_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[12*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(12+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 12*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET12_ARADDR   = TARGET_ARADDR[(12+1)*ADDR_WIDTH-1:12*ADDR_WIDTH];  
      assign  TARGET12_ARLEN    = TARGET_ARLEN[(12+1)*8-1:12*8];  
      assign  TARGET12_ARSIZE   = TARGET_ARSIZE[(12+1)*3-1:12*3];  
      assign  TARGET12_ARBURST  = TARGET_ARBURST[(12+1)*2-1:12*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET12_ARLOCK   = (TARGET12_TYPE == 2'b11) ? TARGET_ARLOCK[(12+1)*2-1:12*2] : {1'b0, TARGET_ARLOCK[12*2]};
      assign  TARGET12_ARCACHE  = TARGET_ARCACHE[(12+1)*4-1:12*4] ;  
      assign  TARGET12_ARPROT   = TARGET_ARPROT[(12+1)*3-1:12*3] ;  
      assign  TARGET12_ARREGION = TARGET_ARREGION[(12+1)*4-1:12*4];   
      assign  TARGET12_ARQOS    = TARGET_ARQOS[(12+1)*4-1:12*4];  
      assign  TARGET12_ARUSER   = TARGET_ARUSER[(12+1)*USER_WIDTH-1:12*USER_WIDTH];  
      assign  TARGET12_ARVALID  = TARGET_ARVALID[12];      
      assign  TARGET12_RREADY   = TARGET_RREADY[12];  

      //Inputs      
      assign  TARGET_AWREADY[12]                                                                               = TARGET12_AWREADY;          
      assign  TARGET_WREADY[12]                                                                                = TARGET12_WREADY;        
      assign  TARGET_BID[(12+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:12*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET12_BID} : TARGET12_BID; 
      assign  TARGET_BRESP[(12+1)*2-1:12*2]                                                                    = TARGET12_BRESP;  
      assign  TARGET_BUSER[(12+1)*USER_WIDTH-1:12*USER_WIDTH]                                                  = TARGET12_BUSER;  
      assign  TARGET_BVALID[12]                                                                                = TARGET12_BVALID;        
      assign  TARGET_ARREADY[12]                                                                               = TARGET12_ARREADY;        
      assign  TARGET_RID[(12+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:12*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET12_RID} : TARGET12_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(12+1)*13-1:13*12]-1:SDW_LOWER_VEC[(12+1)*13-1:13*12]]                = TARGET12_RDATA;  
      assign  TARGET_RRESP[(12+1)*2-1:12*2]                                                                    = TARGET12_RRESP;  
      assign  TARGET_RLAST[12]                                                                                 = TARGET12_RLAST;  
      assign  TARGET_RUSER[(12+1)*USER_WIDTH-1:12*USER_WIDTH]                                                  = TARGET12_RUSER;  
      assign  TARGET_RVALID[12]                                                                                = TARGET12_RVALID;
    end
    
    if ( NUM_TARGETS > 13 )
    begin
      //===================================================================
      //Target13 Combine Signals
      //===================================================================
      //======================= TARGET13 TO/FROM External Side=================
      //Outputs
      assign  TARGET13_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[13*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(13+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 13*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET13_AWADDR   = TARGET_AWADDR[(13+1)*ADDR_WIDTH-1:13*ADDR_WIDTH];  
      assign  TARGET13_AWLEN    = TARGET_AWLEN[(13+1)*8-1:13*8];  
      assign  TARGET13_AWSIZE   = TARGET_AWSIZE[(13+1)*3-1:13*3];  
      assign  TARGET13_AWBURST  = TARGET_AWBURST[(13+1)*2-1:13*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET13_AWLOCK   = (TARGET13_TYPE == 2'b11) ? TARGET_AWLOCK[(13+1)*2-1:13*2] : {1'b0, TARGET_AWLOCK[13*2]};
      assign  TARGET13_AWCACHE  = TARGET_AWCACHE[(13+1)*4-1:13*4];  
      assign  TARGET13_AWPROT   = TARGET_AWPROT[(13+1)*3-1:13*3];  
      assign  TARGET13_AWREGION = TARGET_AWREGION[(13+1)*4-1:13*4];   
      assign  TARGET13_AWQOS    = TARGET_AWQOS[(13+1)*4-1:13*4];  
      assign  TARGET13_AWUSER   = TARGET_AWUSER[(13+1)*USER_WIDTH-1:13*USER_WIDTH];  
      assign  TARGET13_AWVALID  = TARGET_AWVALID[13];  
      assign  TARGET13_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[13*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(13+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 13*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET13_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(13+1)*13-1:13*13]-1:SDW_LOWER_VEC[(13+1)*13-1:13*13]];  
      assign  TARGET13_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(13+1)*13-1:13*13]/8-1:SDW_LOWER_VEC[(13+1)*13-1:13*13]/8];  
      assign  TARGET13_WLAST    = TARGET_WLAST[13];  
      assign  TARGET13_WUSER    = TARGET_WUSER[(13+1)*USER_WIDTH-1:13*USER_WIDTH];  
      assign  TARGET13_WVALID   = TARGET_WVALID[13];      
      assign  TARGET13_BREADY   = TARGET_BREADY[13];        
      assign  TARGET13_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[13*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(13+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 13*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET13_ARADDR   = TARGET_ARADDR[(13+1)*ADDR_WIDTH-1:13*ADDR_WIDTH];  
      assign  TARGET13_ARLEN    = TARGET_ARLEN[(13+1)*8-1:13*8];  
      assign  TARGET13_ARSIZE   = TARGET_ARSIZE[(13+1)*3-1:13*3];  
      assign  TARGET13_ARBURST  = TARGET_ARBURST[(13+1)*2-1:13*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET13_ARLOCK   = (TARGET13_TYPE == 2'b11) ? TARGET_ARLOCK[(13+1)*2-1:13*2] : {1'b0, TARGET_ARLOCK[13*2]};
      assign  TARGET13_ARCACHE  = TARGET_ARCACHE[(13+1)*4-1:13*4] ;  
      assign  TARGET13_ARPROT   = TARGET_ARPROT[(13+1)*3-1:13*3] ;  
      assign  TARGET13_ARREGION = TARGET_ARREGION[(13+1)*4-1:13*4];   
      assign  TARGET13_ARQOS    = TARGET_ARQOS[(13+1)*4-1:13*4];  
      assign  TARGET13_ARUSER   = TARGET_ARUSER[(13+1)*USER_WIDTH-1:13*USER_WIDTH];  
      assign  TARGET13_ARVALID  = TARGET_ARVALID[13];      
      assign  TARGET13_RREADY   = TARGET_RREADY[13];  

      //Inputs      
      assign  TARGET_AWREADY[13]                                                                               = TARGET13_AWREADY;          
      assign  TARGET_WREADY[13]                                                                                = TARGET13_WREADY;        
      assign  TARGET_BID[(13+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:13*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET13_BID} : TARGET13_BID; 
      assign  TARGET_BRESP[(13+1)*2-1:13*2]                                                                    = TARGET13_BRESP;  
      assign  TARGET_BUSER[(13+1)*USER_WIDTH-1:13*USER_WIDTH]                                                  = TARGET13_BUSER;  
      assign  TARGET_BVALID[13]                                                                                = TARGET13_BVALID;        
      assign  TARGET_ARREADY[13]                                                                               = TARGET13_ARREADY;        
      assign  TARGET_RID[(13+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:13*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET13_RID} : TARGET13_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(13+1)*13-1:13*13]-1:SDW_LOWER_VEC[(13+1)*13-1:13*13]]                = TARGET13_RDATA;  
      assign  TARGET_RRESP[(13+1)*2-1:13*2]                                                                    = TARGET13_RRESP;  
      assign  TARGET_RLAST[13]                                                                                 = TARGET13_RLAST;  
      assign  TARGET_RUSER[(13+1)*USER_WIDTH-1:13*USER_WIDTH]                                                  = TARGET13_RUSER;  
      assign  TARGET_RVALID[13]                                                                                = TARGET13_RVALID;
    end
    
    if ( NUM_TARGETS > 14 )
    begin
      //===================================================================
      //Target14 Combine Signals
      //===================================================================
      //======================= TARGET14 TO/FROM External Side=================
      //Outputs
      assign  TARGET14_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[14*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(14+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 14*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET14_AWADDR   = TARGET_AWADDR[(14+1)*ADDR_WIDTH-1:14*ADDR_WIDTH];  
      assign  TARGET14_AWLEN    = TARGET_AWLEN[(14+1)*8-1:14*8];  
      assign  TARGET14_AWSIZE   = TARGET_AWSIZE[(14+1)*3-1:14*3];  
      assign  TARGET14_AWBURST  = TARGET_AWBURST[(14+1)*2-1:14*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET14_AWLOCK   = (TARGET14_TYPE == 2'b11) ? TARGET_AWLOCK[(14+1)*2-1:14*2] : {1'b0, TARGET_AWLOCK[14*2]};
      assign  TARGET14_AWCACHE  = TARGET_AWCACHE[(14+1)*4-1:14*4];  
      assign  TARGET14_AWPROT   = TARGET_AWPROT[(14+1)*3-1:14*3];  
      assign  TARGET14_AWREGION = TARGET_AWREGION[(14+1)*4-1:14*4];   
      assign  TARGET14_AWQOS    = TARGET_AWQOS[(14+1)*4-1:14*4];  
      assign  TARGET14_AWUSER   = TARGET_AWUSER[(14+1)*USER_WIDTH-1:14*USER_WIDTH];  
      assign  TARGET14_AWVALID  = TARGET_AWVALID[14];  
      assign  TARGET14_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[14*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(14+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 14*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET14_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(14+1)*13-1:13*14]-1:SDW_LOWER_VEC[(14+1)*13-1:13*14]];  
      assign  TARGET14_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(14+1)*13-1:13*14]/8-1:SDW_LOWER_VEC[(14+1)*13-1:13*14]/8];  
      assign  TARGET14_WLAST    = TARGET_WLAST[14];  
      assign  TARGET14_WUSER    = TARGET_WUSER[(14+1)*USER_WIDTH-1:14*USER_WIDTH];  
      assign  TARGET14_WVALID   = TARGET_WVALID[14];      
      assign  TARGET14_BREADY   = TARGET_BREADY[14];        
      assign  TARGET14_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[14*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(14+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 14*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET14_ARADDR   = TARGET_ARADDR[(14+1)*ADDR_WIDTH-1:14*ADDR_WIDTH];  
      assign  TARGET14_ARLEN    = TARGET_ARLEN[(14+1)*8-1:14*8];  
      assign  TARGET14_ARSIZE   = TARGET_ARSIZE[(14+1)*3-1:14*3];  
      assign  TARGET14_ARBURST  = TARGET_ARBURST[(14+1)*2-1:14*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET14_ARLOCK   = (TARGET14_TYPE == 2'b11) ? TARGET_ARLOCK[(14+1)*2-1:14*2] : {1'b0, TARGET_ARLOCK[14*2]};
      assign  TARGET14_ARCACHE  = TARGET_ARCACHE[(14+1)*4-1:14*4] ;  
      assign  TARGET14_ARPROT   = TARGET_ARPROT[(14+1)*3-1:14*3] ;  
      assign  TARGET14_ARREGION = TARGET_ARREGION[(14+1)*4-1:14*4];   
      assign  TARGET14_ARQOS    = TARGET_ARQOS[(14+1)*4-1:14*4];  
      assign  TARGET14_ARUSER   = TARGET_ARUSER[(14+1)*USER_WIDTH-1:14*USER_WIDTH];  
      assign  TARGET14_ARVALID  = TARGET_ARVALID[14];      
      assign  TARGET14_RREADY   = TARGET_RREADY[14];  

      //Inputs      
      assign  TARGET_AWREADY[14]                                                                               = TARGET14_AWREADY;
      assign  TARGET_WREADY[14]                                                                                = TARGET14_WREADY;
      assign  TARGET_BID[(14+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:14*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET14_BID} : TARGET14_BID; 
      assign  TARGET_BRESP[(14+1)*2-1:14*2]                                                                    = TARGET14_BRESP;
      assign  TARGET_BUSER[(14+1)*USER_WIDTH-1:14*USER_WIDTH]                                                  = TARGET14_BUSER;
      assign  TARGET_BVALID[14]                                                                                = TARGET14_BVALID;
      assign  TARGET_ARREADY[14]                                                                               = TARGET14_ARREADY;
      assign  TARGET_RID[(14+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:14*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET14_RID} : TARGET14_RID;
      assign  TARGET_RDATA[SDW_UPPER_VEC[(14+1)*13-1:13*14]-1:SDW_LOWER_VEC[(14+1)*13-1:13*14]]                = TARGET14_RDATA;
      assign  TARGET_RRESP[(14+1)*2-1:14*2]                                                                    = TARGET14_RRESP;
      assign  TARGET_RLAST[14]                                                                                 = TARGET14_RLAST;
      assign  TARGET_RUSER[(14+1)*USER_WIDTH-1:14*USER_WIDTH]                                                  = TARGET14_RUSER;
      assign  TARGET_RVALID[14]                                                                                = TARGET14_RVALID;
    end
    
    if ( NUM_TARGETS > 15 )
    begin
      //===================================================================
      //Target15 Combine Signals
      //===================================================================
      //======================= TARGET15 TO/FROM External Side=================
      //Outputs
      assign  TARGET15_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[15*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(15+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 15*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET15_AWADDR   = TARGET_AWADDR[(15+1)*ADDR_WIDTH-1:15*ADDR_WIDTH];  
      assign  TARGET15_AWLEN    = TARGET_AWLEN[(15+1)*8-1:15*8];  
      assign  TARGET15_AWSIZE   = TARGET_AWSIZE[(15+1)*3-1:15*3];  
      assign  TARGET15_AWBURST  = TARGET_AWBURST[(15+1)*2-1:15*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET15_AWLOCK   = (TARGET15_TYPE == 2'b11) ? TARGET_AWLOCK[(15+1)*2-1:15*2] : {1'b0, TARGET_AWLOCK[15*2]};
      assign  TARGET15_AWCACHE  = TARGET_AWCACHE[(15+1)*4-1:15*4];  
      assign  TARGET15_AWPROT   = TARGET_AWPROT[(15+1)*3-1:15*3];  
      assign  TARGET15_AWREGION = TARGET_AWREGION[(15+1)*4-1:15*4];   
      assign  TARGET15_AWQOS    = TARGET_AWQOS[(15+1)*4-1:15*4];  
      assign  TARGET15_AWUSER   = TARGET_AWUSER[(15+1)*USER_WIDTH-1:15*USER_WIDTH];  
      assign  TARGET15_AWVALID  = TARGET_AWVALID[15];  
      assign  TARGET15_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[15*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(15+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 15*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET15_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(15+1)*13-1:13*15]-1:SDW_LOWER_VEC[(15+1)*13-1:13*15]];  
      assign  TARGET15_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(15+1)*13-1:13*15]/8-1:SDW_LOWER_VEC[(15+1)*13-1:13*15]/8];  
      assign  TARGET15_WLAST    = TARGET_WLAST[15];  
      assign  TARGET15_WUSER    = TARGET_WUSER[(15+1)*USER_WIDTH-1:15*USER_WIDTH];  
      assign  TARGET15_WVALID   = TARGET_WVALID[15];      
      assign  TARGET15_BREADY   = TARGET_BREADY[15];        
      assign  TARGET15_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[15*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(15+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 15*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET15_ARADDR   = TARGET_ARADDR[(15+1)*ADDR_WIDTH-1:15*ADDR_WIDTH];  
      assign  TARGET15_ARLEN    = TARGET_ARLEN[(15+1)*8-1:15*8];  
      assign  TARGET15_ARSIZE   = TARGET_ARSIZE[(15+1)*3-1:15*3];  
      assign  TARGET15_ARBURST  = TARGET_ARBURST[(15+1)*2-1:15*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET15_ARLOCK   = (TARGET15_TYPE == 2'b11) ? TARGET_ARLOCK[(15+1)*2-1:15*2] : {1'b0, TARGET_ARLOCK[15*2]};
      assign  TARGET15_ARCACHE  = TARGET_ARCACHE[(15+1)*4-1:15*4] ;  
      assign  TARGET15_ARPROT   = TARGET_ARPROT[(15+1)*3-1:15*3] ;  
      assign  TARGET15_ARREGION = TARGET_ARREGION[(15+1)*4-1:15*4];   
      assign  TARGET15_ARQOS    = TARGET_ARQOS[(15+1)*4-1:15*4];  
      assign  TARGET15_ARUSER   = TARGET_ARUSER[(15+1)*USER_WIDTH-1:15*USER_WIDTH];  
      assign  TARGET15_ARVALID  = TARGET_ARVALID[15];      
      assign  TARGET15_RREADY   = TARGET_RREADY[15];  

      //Inputs      
      assign  TARGET_AWREADY[15]                                                                               = TARGET15_AWREADY;          
      assign  TARGET_WREADY[15]                                                                                = TARGET15_WREADY;        
      assign  TARGET_BID[(15+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:15*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET15_BID} : TARGET15_BID; 
      assign  TARGET_BRESP[(15+1)*2-1:15*2]                                                                    = TARGET15_BRESP;  
      assign  TARGET_BUSER[(15+1)*USER_WIDTH-1:15*USER_WIDTH]                                                  = TARGET15_BUSER;  
      assign  TARGET_BVALID[15]                                                                                = TARGET15_BVALID;        
      assign  TARGET_ARREADY[15]                                                                               = TARGET15_ARREADY;        
      assign  TARGET_RID[(15+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:15*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET15_RID} : TARGET15_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(15+1)*13-1:13*15]-1:SDW_LOWER_VEC[(15+1)*13-1:13*15]]                = TARGET15_RDATA;  
      assign  TARGET_RRESP[(15+1)*2-1:15*2]                                                                    = TARGET15_RRESP;  
      assign  TARGET_RLAST[15]                                                                                 = TARGET15_RLAST;  
      assign  TARGET_RUSER[(15+1)*USER_WIDTH-1:15*USER_WIDTH]                                                  = TARGET15_RUSER;  
      assign  TARGET_RVALID[15]                                                                                = TARGET15_RVALID;
    end
    
    if ( NUM_TARGETS > 16 )
    begin
      //===================================================================
      //Target16 Combine Signals
      //===================================================================
      //======================= TARGET16 TO/FROM External Side=================
      //Outputs
      assign  TARGET16_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[16*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(16+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 16*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET16_AWADDR   = TARGET_AWADDR[(16+1)*ADDR_WIDTH-1:16*ADDR_WIDTH];  
      assign  TARGET16_AWLEN    = TARGET_AWLEN[(16+1)*8-1:16*8];  
      assign  TARGET16_AWSIZE   = TARGET_AWSIZE[(16+1)*3-1:16*3];  
      assign  TARGET16_AWBURST  = TARGET_AWBURST[(16+1)*2-1:16*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET16_AWLOCK   = (TARGET16_TYPE == 2'b11) ? TARGET_AWLOCK[(16+1)*2-1:16*2] : {1'b0, TARGET_AWLOCK[16*2]};
      assign  TARGET16_AWCACHE  = TARGET_AWCACHE[(16+1)*4-1:16*4];  
      assign  TARGET16_AWPROT   = TARGET_AWPROT[(16+1)*3-1:16*3];  
      assign  TARGET16_AWREGION = TARGET_AWREGION[(16+1)*4-1:16*4];   
      assign  TARGET16_AWQOS    = TARGET_AWQOS[(16+1)*4-1:16*4];  
      assign  TARGET16_AWUSER   = TARGET_AWUSER[(16+1)*USER_WIDTH-1:16*USER_WIDTH];  
      assign  TARGET16_AWVALID  = TARGET_AWVALID[16];  
      assign  TARGET16_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[16*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(16+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 16*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET16_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(16+1)*13-1:13*16]-1:SDW_LOWER_VEC[(16+1)*13-1:13*16]];  
      assign  TARGET16_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(16+1)*13-1:13*16]/8-1:SDW_LOWER_VEC[(16+1)*13-1:13*16]/8];  
      assign  TARGET16_WLAST    = TARGET_WLAST[16];  
      assign  TARGET16_WUSER    = TARGET_WUSER[(16+1)*USER_WIDTH-1:16*USER_WIDTH];  
      assign  TARGET16_WVALID   = TARGET_WVALID[16];      
      assign  TARGET16_BREADY   = TARGET_BREADY[16];        
      assign  TARGET16_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[16*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(16+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 16*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET16_ARADDR   = TARGET_ARADDR[(16+1)*ADDR_WIDTH-1:16*ADDR_WIDTH];  
      assign  TARGET16_ARLEN    = TARGET_ARLEN[(16+1)*8-1:16*8];  
      assign  TARGET16_ARSIZE   = TARGET_ARSIZE[(16+1)*3-1:16*3];  
      assign  TARGET16_ARBURST  = TARGET_ARBURST[(16+1)*2-1:16*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET16_ARLOCK   = (TARGET16_TYPE == 2'b11) ? TARGET_ARLOCK[(16+1)*2-1:16*2] : {1'b0, TARGET_ARLOCK[16*2]};
      assign  TARGET16_ARCACHE  = TARGET_ARCACHE[(16+1)*4-1:16*4] ;  
      assign  TARGET16_ARPROT   = TARGET_ARPROT[(16+1)*3-1:16*3] ;  
      assign  TARGET16_ARREGION = TARGET_ARREGION[(16+1)*4-1:16*4];   
      assign  TARGET16_ARQOS    = TARGET_ARQOS[(16+1)*4-1:16*4];  
      assign  TARGET16_ARUSER   = TARGET_ARUSER[(16+1)*USER_WIDTH-1:16*USER_WIDTH];  
      assign  TARGET16_ARVALID  = TARGET_ARVALID[16];      
      assign  TARGET16_RREADY   = TARGET_RREADY[16];  

      //Inputs      
      assign  TARGET_AWREADY[16]                                                                              = TARGET16_AWREADY;          
      assign  TARGET_WREADY[16]                                                                               = TARGET16_WREADY;        
      assign  TARGET_BID[(16+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:16*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET16_BID} : TARGET16_BID; 
      assign  TARGET_BRESP[(16+1)*2-1:16*2]                                                                   = TARGET16_BRESP;  
      assign  TARGET_BUSER[(16+1)*USER_WIDTH-1:16*USER_WIDTH]                                                 = TARGET16_BUSER;  
      assign  TARGET_BVALID[16]                                                                               = TARGET16_BVALID;        
      assign  TARGET_ARREADY[16]                                                                              = TARGET16_ARREADY;        
      assign  TARGET_RID[(16+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:16*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET16_RID} : TARGET16_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(16+1)*13-1:13*16]-1:SDW_LOWER_VEC[(16+1)*13-1:13*16]]               = TARGET16_RDATA;  
      assign  TARGET_RRESP[(16+1)*2-1:16*2]                                                                   = TARGET16_RRESP;  
      assign  TARGET_RLAST[16]                                                                                = TARGET16_RLAST;  
      assign  TARGET_RUSER[(16+1)*USER_WIDTH-1:16*USER_WIDTH]                                                 = TARGET16_RUSER;  
      assign  TARGET_RVALID[16]                                                                               = TARGET16_RVALID;
    end
    
    if ( NUM_TARGETS > 17 )
    begin
      //===================================================================
      //Target17 Combine Signals
      //===================================================================
      //======================= TARGET17 TO/FROM External Side=================
      //Outputs
      assign  TARGET17_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[17*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(17+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 17*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET17_AWADDR   = TARGET_AWADDR[(17+1)*ADDR_WIDTH-1:17*ADDR_WIDTH];  
      assign  TARGET17_AWLEN    = TARGET_AWLEN[(17+1)*8-1:17*8];  
      assign  TARGET17_AWSIZE   = TARGET_AWSIZE[(17+1)*3-1:17*3];  
      assign  TARGET17_AWBURST  = TARGET_AWBURST[(17+1)*2-1:17*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET17_AWLOCK   = (TARGET17_TYPE == 2'b11) ? TARGET_AWLOCK[(17+1)*2-1:17*2] : {1'b0, TARGET_AWLOCK[17*2]};
      assign  TARGET17_AWCACHE  = TARGET_AWCACHE[(17+1)*4-1:17*4];  
      assign  TARGET17_AWPROT   = TARGET_AWPROT[(17+1)*3-1:17*3];  
      assign  TARGET17_AWREGION = TARGET_AWREGION[(17+1)*4-1:17*4];   
      assign  TARGET17_AWQOS    = TARGET_AWQOS[(17+1)*4-1:17*4];  
      assign  TARGET17_AWUSER   = TARGET_AWUSER[(17+1)*USER_WIDTH-1:17*USER_WIDTH];  
      assign  TARGET17_AWVALID  = TARGET_AWVALID[17];  
      assign  TARGET17_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[17*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(17+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 17*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET17_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(17+1)*13-1:13*17]-1:SDW_LOWER_VEC[(17+1)*13-1:13*17]];  
      assign  TARGET17_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(17+1)*13-1:13*17]/8-1:SDW_LOWER_VEC[(17+1)*13-1:13*17]/8];  
      assign  TARGET17_WLAST    = TARGET_WLAST[17];  
      assign  TARGET17_WUSER    = TARGET_WUSER[(17+1)*USER_WIDTH-1:17*USER_WIDTH];  
      assign  TARGET17_WVALID   = TARGET_WVALID[17];      
      assign  TARGET17_BREADY   = TARGET_BREADY[17];        
      assign  TARGET17_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[17*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(17+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 17*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET17_ARADDR   = TARGET_ARADDR[(17+1)*ADDR_WIDTH-1:17*ADDR_WIDTH];  
      assign  TARGET17_ARLEN    = TARGET_ARLEN[(17+1)*8-1:17*8];  
      assign  TARGET17_ARSIZE   = TARGET_ARSIZE[(17+1)*3-1:17*3];  
      assign  TARGET17_ARBURST  = TARGET_ARBURST[(17+1)*2-1:17*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET17_ARLOCK   = (TARGET17_TYPE == 2'b11) ? TARGET_ARLOCK[(17+1)*2-1:17*2] : {1'b0, TARGET_ARLOCK[17*2]};
      assign  TARGET17_ARCACHE  = TARGET_ARCACHE[(17+1)*4-1:17*4] ;  
      assign  TARGET17_ARPROT   = TARGET_ARPROT[(17+1)*3-1:17*3] ;  
      assign  TARGET17_ARREGION = TARGET_ARREGION[(17+1)*4-1:17*4];   
      assign  TARGET17_ARQOS    = TARGET_ARQOS[(17+1)*4-1:17*4];  
      assign  TARGET17_ARUSER   = TARGET_ARUSER[(17+1)*USER_WIDTH-1:17*USER_WIDTH];  
      assign  TARGET17_ARVALID  = TARGET_ARVALID[17];      
      assign  TARGET17_RREADY   = TARGET_RREADY[17];  

      //Inputs      
      assign  TARGET_AWREADY[17]                                                                               = TARGET17_AWREADY;          
      assign  TARGET_WREADY[17]                                                                                = TARGET17_WREADY;        
      assign  TARGET_BID[(17+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:17*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET17_BID} : TARGET17_BID; 
      assign  TARGET_BRESP[(17+1)*2-1:17*2]                                                                    = TARGET17_BRESP;  
      assign  TARGET_BUSER[(17+1)*USER_WIDTH-1:17*USER_WIDTH]                                                  = TARGET17_BUSER;  
      assign  TARGET_BVALID[17]                                                                                = TARGET17_BVALID;        
      assign  TARGET_ARREADY[17]                                                                               = TARGET17_ARREADY;        
      assign  TARGET_RID[(17+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:17*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET17_RID} : TARGET17_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(17+1)*13-1:13*17]-1:SDW_LOWER_VEC[(17+1)*13-1:13*17]]                = TARGET17_RDATA;  
      assign  TARGET_RRESP[(17+1)*2-1:17*2]                                                                    = TARGET17_RRESP;  
      assign  TARGET_RLAST[17]                                                                                 = TARGET17_RLAST;  
      assign  TARGET_RUSER[(17+1)*USER_WIDTH-1:17*USER_WIDTH]                                                  = TARGET17_RUSER;  
      assign  TARGET_RVALID[17]                                                                                = TARGET17_RVALID;
    end
    
    if ( NUM_TARGETS > 18 )
    begin
      //===================================================================
      //Target18 Combine Signals
      //===================================================================
      //======================= TARGET18 TO/FROM External Side=================
      //Outputs
      assign  TARGET18_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[18*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(18+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 18*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET18_AWADDR   = TARGET_AWADDR[(18+1)*ADDR_WIDTH-1:18*ADDR_WIDTH];  
      assign  TARGET18_AWLEN    = TARGET_AWLEN[(18+1)*8-1:18*8];  
      assign  TARGET18_AWSIZE   = TARGET_AWSIZE[(18+1)*3-1:18*3];  
      assign  TARGET18_AWBURST  = TARGET_AWBURST[(18+1)*2-1:18*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET18_AWLOCK   = (TARGET18_TYPE == 2'b11) ? TARGET_AWLOCK[(18+1)*2-1:18*2] : {1'b0, TARGET_AWLOCK[18*2]};
      assign  TARGET18_AWCACHE  = TARGET_AWCACHE[(18+1)*4-1:18*4];  
      assign  TARGET18_AWPROT   = TARGET_AWPROT[(18+1)*3-1:18*3];  
      assign  TARGET18_AWREGION = TARGET_AWREGION[(18+1)*4-1:18*4];   
      assign  TARGET18_AWQOS    = TARGET_AWQOS[(18+1)*4-1:18*4];  
      assign  TARGET18_AWUSER   = TARGET_AWUSER[(18+1)*USER_WIDTH-1:18*USER_WIDTH];  
      assign  TARGET18_AWVALID  = TARGET_AWVALID[18];  
      assign  TARGET18_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[18*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(18+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 18*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET18_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(18+1)*13-1:13*18]-1:SDW_LOWER_VEC[(18+1)*13-1:13*18]];  
      assign  TARGET18_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(18+1)*13-1:13*18]/8-1:SDW_LOWER_VEC[(18+1)*13-1:13*18]/8];  
      assign  TARGET18_WLAST    = TARGET_WLAST[18];  
      assign  TARGET18_WUSER    = TARGET_WUSER[(18+1)*USER_WIDTH-1:18*USER_WIDTH];  
      assign  TARGET18_WVALID   = TARGET_WVALID[18];      
      assign  TARGET18_BREADY   = TARGET_BREADY[18];        
      assign  TARGET18_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[18*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(18+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 18*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET18_ARADDR   = TARGET_ARADDR[(18+1)*ADDR_WIDTH-1:18*ADDR_WIDTH];  
      assign  TARGET18_ARLEN    = TARGET_ARLEN[(18+1)*8-1:18*8];  
      assign  TARGET18_ARSIZE   = TARGET_ARSIZE[(18+1)*3-1:18*3];  
      assign  TARGET18_ARBURST  = TARGET_ARBURST[(18+1)*2-1:18*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET18_ARLOCK   = (TARGET18_TYPE == 2'b11) ? TARGET_ARLOCK[(18+1)*2-1:18*2] : {1'b0, TARGET_ARLOCK[18*2]};
      assign  TARGET18_ARCACHE  = TARGET_ARCACHE[(18+1)*4-1:18*4] ;  
      assign  TARGET18_ARPROT   = TARGET_ARPROT[(18+1)*3-1:18*3] ;  
      assign  TARGET18_ARREGION = TARGET_ARREGION[(18+1)*4-1:18*4];   
      assign  TARGET18_ARQOS    = TARGET_ARQOS[(18+1)*4-1:18*4];  
      assign  TARGET18_ARUSER   = TARGET_ARUSER[(18+1)*USER_WIDTH-1:18*USER_WIDTH];  
      assign  TARGET18_ARVALID  = TARGET_ARVALID[18];      
      assign  TARGET18_RREADY   = TARGET_RREADY[18];  

      //Inputs      
      assign  TARGET_AWREADY[18]                                                                              = TARGET18_AWREADY;          
      assign  TARGET_WREADY[18]                                                                               = TARGET18_WREADY;        
      assign  TARGET_BID[(18+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:18*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET18_BID} : TARGET18_BID; 
      assign  TARGET_BRESP[(18+1)*2-1:18*2]                                                                   = TARGET18_BRESP;  
      assign  TARGET_BUSER[(18+1)*USER_WIDTH-1:18*USER_WIDTH]                                                 = TARGET18_BUSER;  
      assign  TARGET_BVALID[18]                                                                               = TARGET18_BVALID;        
      assign  TARGET_ARREADY[18]                                                                              = TARGET18_ARREADY;        
      assign  TARGET_RID[(18+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:18*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET18_RID} : TARGET18_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(18+1)*13-1:13*18]-1:SDW_LOWER_VEC[(18+1)*13-1:13*18]]               = TARGET18_RDATA;  
      assign  TARGET_RRESP[(18+1)*2-1:18*2]                                                                   = TARGET18_RRESP;  
      assign  TARGET_RLAST[18]                                                                                = TARGET18_RLAST;  
      assign  TARGET_RUSER[(18+1)*USER_WIDTH-1:18*USER_WIDTH]                                                 = TARGET18_RUSER;  
      assign  TARGET_RVALID[18]                                                                               = TARGET18_RVALID;
    end
    
    if ( NUM_TARGETS > 19 )
    begin
      //===================================================================
      //Target19 Combine Signals
      //===================================================================
      //======================= TARGET19 TO/FROM External Side=================
      //Outputs
      assign  TARGET19_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[19*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(19+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 19*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET19_AWADDR   = TARGET_AWADDR[(19+1)*ADDR_WIDTH-1:19*ADDR_WIDTH];  
      assign  TARGET19_AWLEN    = TARGET_AWLEN[(19+1)*8-1:19*8];  
      assign  TARGET19_AWSIZE   = TARGET_AWSIZE[(19+1)*3-1:19*3];  
      assign  TARGET19_AWBURST  = TARGET_AWBURST[(19+1)*2-1:19*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET19_AWLOCK   = (TARGET19_TYPE == 2'b11) ? TARGET_AWLOCK[(19+1)*2-1:19*2] : {1'b0, TARGET_AWLOCK[19*2]};
      assign  TARGET19_AWCACHE  = TARGET_AWCACHE[(19+1)*4-1:19*4];  
      assign  TARGET19_AWPROT   = TARGET_AWPROT[(19+1)*3-1:19*3];  
      assign  TARGET19_AWREGION = TARGET_AWREGION[(19+1)*4-1:19*4];   
      assign  TARGET19_AWQOS    = TARGET_AWQOS[(19+1)*4-1:19*4];  
      assign  TARGET19_AWUSER   = TARGET_AWUSER[(19+1)*USER_WIDTH-1:19*USER_WIDTH];  
      assign  TARGET19_AWVALID  = TARGET_AWVALID[19];  
      assign  TARGET19_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[19*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(19+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 19*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET19_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(19+1)*13-1:13*19]-1:SDW_LOWER_VEC[(19+1)*13-1:13*19]];  
      assign  TARGET19_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(19+1)*13-1:13*19]/8-1:SDW_LOWER_VEC[(19+1)*13-1:13*19]/8];  
      assign  TARGET19_WLAST    = TARGET_WLAST[19];  
      assign  TARGET19_WUSER    = TARGET_WUSER[(19+1)*USER_WIDTH-1:19*USER_WIDTH];  
      assign  TARGET19_WVALID   = TARGET_WVALID[19];      
      assign  TARGET19_BREADY   = TARGET_BREADY[19];        
      assign  TARGET19_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[19*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(19+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 19*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET19_ARADDR   = TARGET_ARADDR[(19+1)*ADDR_WIDTH-1:19*ADDR_WIDTH];  
      assign  TARGET19_ARLEN    = TARGET_ARLEN[(19+1)*8-1:19*8];  
      assign  TARGET19_ARSIZE   = TARGET_ARSIZE[(19+1)*3-1:19*3];  
      assign  TARGET19_ARBURST  = TARGET_ARBURST[(19+1)*2-1:19*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET19_ARLOCK   = (TARGET19_TYPE == 2'b11) ? TARGET_ARLOCK[(19+1)*2-1:19*2] : {1'b0, TARGET_ARLOCK[19*2]};
      assign  TARGET19_ARCACHE  = TARGET_ARCACHE[(19+1)*4-1:19*4] ;  
      assign  TARGET19_ARPROT   = TARGET_ARPROT[(19+1)*3-1:19*3] ;  
      assign  TARGET19_ARREGION = TARGET_ARREGION[(19+1)*4-1:19*4];   
      assign  TARGET19_ARQOS    = TARGET_ARQOS[(19+1)*4-1:19*4];  
      assign  TARGET19_ARUSER   = TARGET_ARUSER[(19+1)*USER_WIDTH-1:19*USER_WIDTH];  
      assign  TARGET19_ARVALID  = TARGET_ARVALID[19];      
      assign  TARGET19_RREADY   = TARGET_RREADY[19];  

      //Inputs      
      assign  TARGET_AWREADY[19]                                                                              = TARGET19_AWREADY;          
      assign  TARGET_WREADY[19]                                                                               = TARGET19_WREADY;        
      assign  TARGET_BID[(19+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:19*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET19_BID} : TARGET19_BID; 
      assign  TARGET_BRESP[(19+1)*2-1:19*2]                                                                   = TARGET19_BRESP;  
      assign  TARGET_BUSER[(19+1)*USER_WIDTH-1:19*USER_WIDTH]                                                 = TARGET19_BUSER;  
      assign  TARGET_BVALID[19]                                                                               = TARGET19_BVALID;        
      assign  TARGET_ARREADY[19]                                                                              = TARGET19_ARREADY;        
      assign  TARGET_RID[(19+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:19*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET19_RID} : TARGET19_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(19+1)*13-1:13*19]-1:SDW_LOWER_VEC[(19+1)*13-1:13*19]]               = TARGET19_RDATA;  
      assign  TARGET_RRESP[(19+1)*2-1:19*2]                                                                   = TARGET19_RRESP;  
      assign  TARGET_RLAST[19]                                                                                = TARGET19_RLAST;  
      assign  TARGET_RUSER[(19+1)*USER_WIDTH-1:19*USER_WIDTH]                                                 = TARGET19_RUSER;  
      assign  TARGET_RVALID[19]                                                                               = TARGET19_RVALID;
    end
    
    if ( NUM_TARGETS > 20 )
    begin
      //===================================================================
      //Target20 Combine Signals
      //===================================================================
      //======================= TARGET20 TO/FROM External Side=================
      //Outputs
      assign  TARGET20_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[20*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(20+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 20*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET20_AWADDR   = TARGET_AWADDR[(20+1)*ADDR_WIDTH-1:20*ADDR_WIDTH];  
      assign  TARGET20_AWLEN    = TARGET_AWLEN[(20+1)*8-1:20*8];  
      assign  TARGET20_AWSIZE   = TARGET_AWSIZE[(20+1)*3-1:20*3];  
      assign  TARGET20_AWBURST  = TARGET_AWBURST[(20+1)*2-1:20*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET20_AWLOCK   = (TARGET20_TYPE == 2'b11) ? TARGET_AWLOCK[(20+1)*2-1:20*2] : {1'b0, TARGET_AWLOCK[20*2]};
      assign  TARGET20_AWCACHE  = TARGET_AWCACHE[(20+1)*4-1:20*4];  
      assign  TARGET20_AWPROT   = TARGET_AWPROT[(20+1)*3-1:20*3];  
      assign  TARGET20_AWREGION = TARGET_AWREGION[(20+1)*4-1:20*4];   
      assign  TARGET20_AWQOS    = TARGET_AWQOS[(20+1)*4-1:20*4];  
      assign  TARGET20_AWUSER   = TARGET_AWUSER[(20+1)*USER_WIDTH-1:20*USER_WIDTH];  
      assign  TARGET20_AWVALID  = TARGET_AWVALID[20];  
      assign  TARGET20_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[20*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(20+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 20*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET20_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(20+1)*13-1:13*20]-1:SDW_LOWER_VEC[(20+1)*13-1:13*20]];  
      assign  TARGET20_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(20+1)*13-1:13*20]/8-1:SDW_LOWER_VEC[(20+1)*13-1:13*20]/8];  
      assign  TARGET20_WLAST    = TARGET_WLAST[20];  
      assign  TARGET20_WUSER    = TARGET_WUSER[(20+1)*USER_WIDTH-1:20*USER_WIDTH];  
      assign  TARGET20_WVALID   = TARGET_WVALID[20];      
      assign  TARGET20_BREADY   = TARGET_BREADY[20];        
      assign  TARGET20_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[20*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(20+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 20*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET20_ARADDR   = TARGET_ARADDR[(20+1)*ADDR_WIDTH-1:20*ADDR_WIDTH];  
      assign  TARGET20_ARLEN    = TARGET_ARLEN[(20+1)*8-1:20*8];  
      assign  TARGET20_ARSIZE   = TARGET_ARSIZE[(20+1)*3-1:20*3];  
      assign  TARGET20_ARBURST  = TARGET_ARBURST[(20+1)*2-1:20*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET20_ARLOCK   = (TARGET20_TYPE == 2'b11) ? TARGET_ARLOCK[(20+1)*2-1:20*2] : {1'b0, TARGET_ARLOCK[20*2]};
      assign  TARGET20_ARCACHE  = TARGET_ARCACHE[(20+1)*4-1:20*4] ;  
      assign  TARGET20_ARPROT   = TARGET_ARPROT[(20+1)*3-1:20*3] ;  
      assign  TARGET20_ARREGION = TARGET_ARREGION[(20+1)*4-1:20*4];   
      assign  TARGET20_ARQOS    = TARGET_ARQOS[(20+1)*4-1:20*4];  
      assign  TARGET20_ARUSER   = TARGET_ARUSER[(20+1)*USER_WIDTH-1:20*USER_WIDTH];  
      assign  TARGET20_ARVALID  = TARGET_ARVALID[20];      
      assign  TARGET20_RREADY   = TARGET_RREADY[20];  

      //Inputs      
      assign  TARGET_AWREADY[20]                                                                               = TARGET20_AWREADY;          
      assign  TARGET_WREADY[20]                                                                                = TARGET20_WREADY;        
      assign  TARGET_BID[(20+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:20*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET20_BID} : TARGET20_BID;  
      assign  TARGET_BRESP[(20+1)*2-1:20*2]                                                                    = TARGET20_BRESP;  
      assign  TARGET_BUSER[(20+1)*USER_WIDTH-1:20*USER_WIDTH]                                                  = TARGET20_BUSER;  
      assign  TARGET_BVALID[20]                                                                                = TARGET20_BVALID;        
      assign  TARGET_ARREADY[20]                                                                               = TARGET20_ARREADY;        
      assign  TARGET_RID[(20+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:20*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET20_RID} : TARGET20_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(20+1)*13-1:13*20]-1:SDW_LOWER_VEC[(20+1)*13-1:13*20]]                = TARGET20_RDATA;  
      assign  TARGET_RRESP[(20+1)*2-1:20*2]                                                                    = TARGET20_RRESP;  
      assign  TARGET_RLAST[20]                                                                                 = TARGET20_RLAST;  
      assign  TARGET_RUSER[(20+1)*USER_WIDTH-1:20*USER_WIDTH]                                                  = TARGET20_RUSER;  
      assign  TARGET_RVALID[20]                                                                                = TARGET20_RVALID;
    end
    
    if ( NUM_TARGETS > 21 )
    begin
      //===================================================================
      //Target21 Combine Signals
      //===================================================================
      //======================= TARGET21 TO/FROM External Side=================
      //Outputs
      assign  TARGET21_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[21*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(21+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 21*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET21_AWADDR   = TARGET_AWADDR[(21+1)*ADDR_WIDTH-1:21*ADDR_WIDTH];  
      assign  TARGET21_AWLEN    = TARGET_AWLEN[(21+1)*8-1:21*8];  
      assign  TARGET21_AWSIZE   = TARGET_AWSIZE[(21+1)*3-1:21*3];  
      assign  TARGET21_AWBURST  = TARGET_AWBURST[(21+1)*2-1:21*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET21_AWLOCK   = (TARGET21_TYPE == 2'b11) ? TARGET_AWLOCK[(21+1)*2-1:21*2] : {1'b0, TARGET_AWLOCK[21*2]};
      assign  TARGET21_AWCACHE  = TARGET_AWCACHE[(21+1)*4-1:21*4];  
      assign  TARGET21_AWPROT   = TARGET_AWPROT[(21+1)*3-1:21*3];  
      assign  TARGET21_AWREGION = TARGET_AWREGION[(21+1)*4-1:21*4];   
      assign  TARGET21_AWQOS    = TARGET_AWQOS[(21+1)*4-1:21*4];  
      assign  TARGET21_AWUSER   = TARGET_AWUSER[(21+1)*USER_WIDTH-1:21*USER_WIDTH];  
      assign  TARGET21_AWVALID  = TARGET_AWVALID[21];  
      assign  TARGET21_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[21*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(21+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 21*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET21_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(21+1)*13-1:13*21]-1:SDW_LOWER_VEC[(21+1)*13-1:13*21]];  
      assign  TARGET21_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(21+1)*13-1:13*21]/8-1:SDW_LOWER_VEC[(21+1)*13-1:13*21]/8];  
      assign  TARGET21_WLAST    = TARGET_WLAST[21];  
      assign  TARGET21_WUSER    = TARGET_WUSER[(21+1)*USER_WIDTH-1:21*USER_WIDTH];  
      assign  TARGET21_WVALID   = TARGET_WVALID[21];      
      assign  TARGET21_BREADY   = TARGET_BREADY[21];        
      assign  TARGET21_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[21*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(21+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 21*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET21_ARADDR   = TARGET_ARADDR[(21+1)*ADDR_WIDTH-1:21*ADDR_WIDTH];  
      assign  TARGET21_ARLEN    = TARGET_ARLEN[(21+1)*8-1:21*8];  
      assign  TARGET21_ARSIZE   = TARGET_ARSIZE[(21+1)*3-1:21*3];  
      assign  TARGET21_ARBURST  = TARGET_ARBURST[(21+1)*2-1:21*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET21_ARLOCK   = (TARGET21_TYPE == 2'b11) ? TARGET_ARLOCK[(21+1)*2-1:21*2] : {1'b0, TARGET_ARLOCK[21*2]};
      assign  TARGET21_ARCACHE  = TARGET_ARCACHE[(21+1)*4-1:21*4] ;  
      assign  TARGET21_ARPROT   = TARGET_ARPROT[(21+1)*3-1:21*3] ;  
      assign  TARGET21_ARREGION = TARGET_ARREGION[(21+1)*4-1:21*4];   
      assign  TARGET21_ARQOS    = TARGET_ARQOS[(21+1)*4-1:21*4];  
      assign  TARGET21_ARUSER   = TARGET_ARUSER[(21+1)*USER_WIDTH-1:21*USER_WIDTH];  
      assign  TARGET21_ARVALID  = TARGET_ARVALID[21];      
      assign  TARGET21_RREADY   = TARGET_RREADY[21];  

      //Inputs      
      assign  TARGET_AWREADY[21]                                                                                = TARGET21_AWREADY;          
      assign  TARGET_WREADY[21]                                                                                 = TARGET21_WREADY;        
      assign  TARGET_BID[(21+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:21*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET21_BID} : TARGET21_BID; 
      assign  TARGET_BRESP[(21+1)*2-1:21*2]                                                                     = TARGET21_BRESP;  
      assign  TARGET_BUSER[(21+1)*USER_WIDTH-1:21*USER_WIDTH]                                                   = TARGET21_BUSER;  
      assign  TARGET_BVALID[21]                                                                                 = TARGET21_BVALID;        
      assign  TARGET_ARREADY[21]                                                                                = TARGET21_ARREADY;        
      assign  TARGET_RID[(21+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:21*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET21_RID} : TARGET21_RID; 
      assign  TARGET_RDATA[SDW_UPPER_VEC[(21+1)*13-1:13*21]-1:SDW_LOWER_VEC[(21+1)*13-1:13*21]]                 = TARGET21_RDATA;  
      assign  TARGET_RRESP[(21+1)*2-1:21*2]                                                                     = TARGET21_RRESP;  
      assign  TARGET_RLAST[21]                                                                                  = TARGET21_RLAST;  
      assign  TARGET_RUSER[(21+1)*USER_WIDTH-1:21*USER_WIDTH]                                                   = TARGET21_RUSER;  
      assign  TARGET_RVALID[21]                                                                                 = TARGET21_RVALID;
    end
    
    if ( NUM_TARGETS > 22 )
    begin
      //===================================================================
      //Target22 Combine Signals
      //===================================================================
      //======================= TARGET22 TO/FROM External Side=================
      //Outputs
      assign  TARGET22_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[22*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(22+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 22*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET22_AWADDR   = TARGET_AWADDR[(22+1)*ADDR_WIDTH-1:22*ADDR_WIDTH];  
      assign  TARGET22_AWLEN    = TARGET_AWLEN[(22+1)*8-1:22*8];  
      assign  TARGET22_AWSIZE   = TARGET_AWSIZE[(22+1)*3-1:22*3];  
      assign  TARGET22_AWBURST  = TARGET_AWBURST[(22+1)*2-1:22*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET22_AWLOCK   = (TARGET22_TYPE == 2'b11) ? TARGET_AWLOCK[(22+1)*2-1:22*2] : {1'b0, TARGET_AWLOCK[22*2]};
      assign  TARGET22_AWCACHE  = TARGET_AWCACHE[(22+1)*4-1:22*4];  
      assign  TARGET22_AWPROT   = TARGET_AWPROT[(22+1)*3-1:22*3];  
      assign  TARGET22_AWREGION = TARGET_AWREGION[(22+1)*4-1:22*4];   
      assign  TARGET22_AWQOS    = TARGET_AWQOS[(22+1)*4-1:22*4];  
      assign  TARGET22_AWUSER   = TARGET_AWUSER[(22+1)*USER_WIDTH-1:22*USER_WIDTH];  
      assign  TARGET22_AWVALID  = TARGET_AWVALID[22];  
      assign  TARGET22_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[22*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(22+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 22*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET22_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(22+1)*13-1:13*22]-1:SDW_LOWER_VEC[(22+1)*13-1:13*22]];  
      assign  TARGET22_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(22+1)*13-1:13*22]/8-1:SDW_LOWER_VEC[(22+1)*13-1:13*22]/8];  
      assign  TARGET22_WLAST    = TARGET_WLAST[22];  
      assign  TARGET22_WUSER    = TARGET_WUSER[(22+1)*USER_WIDTH-1:22*USER_WIDTH];  
      assign  TARGET22_WVALID   = TARGET_WVALID[22];      
      assign  TARGET22_BREADY   = TARGET_BREADY[22];        
      assign  TARGET22_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[22*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(22+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 22*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET22_ARADDR   = TARGET_ARADDR[(22+1)*ADDR_WIDTH-1:22*ADDR_WIDTH];  
      assign  TARGET22_ARLEN    = TARGET_ARLEN[(22+1)*8-1:22*8];  
      assign  TARGET22_ARSIZE   = TARGET_ARSIZE[(22+1)*3-1:22*3];  
      assign  TARGET22_ARBURST  = TARGET_ARBURST[(22+1)*2-1:22*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET22_ARLOCK   = (TARGET22_TYPE == 2'b11) ? TARGET_ARLOCK[(22+1)*2-1:22*2] : {1'b0, TARGET_ARLOCK[22*2]};
      assign  TARGET22_ARCACHE  = TARGET_ARCACHE[(22+1)*4-1:22*4] ;  
      assign  TARGET22_ARPROT   = TARGET_ARPROT[(22+1)*3-1:22*3] ;  
      assign  TARGET22_ARREGION = TARGET_ARREGION[(22+1)*4-1:22*4];   
      assign  TARGET22_ARQOS    = TARGET_ARQOS[(22+1)*4-1:22*4];  
      assign  TARGET22_ARUSER   = TARGET_ARUSER[(22+1)*USER_WIDTH-1:22*USER_WIDTH];  
      assign  TARGET22_ARVALID  = TARGET_ARVALID[22];      
      assign  TARGET22_RREADY   = TARGET_RREADY[22];  

      //Inputs      
      assign  TARGET_AWREADY[22]                                                                               = TARGET22_AWREADY;          
      assign  TARGET_WREADY[22]                                                                                = TARGET22_WREADY;        
      assign  TARGET_BID[(22+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:22*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET22_BID} : TARGET22_BID; 
      assign  TARGET_BRESP[(22+1)*2-1:22*2]                                                                    = TARGET22_BRESP;  
      assign  TARGET_BUSER[(22+1)*USER_WIDTH-1:22*USER_WIDTH]                                                  = TARGET22_BUSER;  
      assign  TARGET_BVALID[22]                                                                                = TARGET22_BVALID;        
      assign  TARGET_ARREADY[22]                                                                               = TARGET22_ARREADY;        
      assign  TARGET_RID[(22+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:22*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET22_RID} : TARGET22_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(22+1)*13-1:13*22]-1:SDW_LOWER_VEC[(22+1)*13-1:13*22]]                = TARGET22_RDATA;  
      assign  TARGET_RRESP[(22+1)*2-1:22*2]                                                                    = TARGET22_RRESP;  
      assign  TARGET_RLAST[22]                                                                                 = TARGET22_RLAST;  
      assign  TARGET_RUSER[(22+1)*USER_WIDTH-1:22*USER_WIDTH]                                                  = TARGET22_RUSER;  
      assign  TARGET_RVALID[22]                                                                                = TARGET22_RVALID;
    end
    
    if ( NUM_TARGETS > 23 )
    begin
      //===================================================================
      //Target23 Combine Signals
      //===================================================================
      //======================= TARGET23 TO/FROM External Side=================
      //Outputs
      assign  TARGET23_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[23*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(23+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 23*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET23_AWADDR   = TARGET_AWADDR[(23+1)*ADDR_WIDTH-1:23*ADDR_WIDTH];  
      assign  TARGET23_AWLEN    = TARGET_AWLEN[(23+1)*8-1:23*8];  
      assign  TARGET23_AWSIZE   = TARGET_AWSIZE[(23+1)*3-1:23*3];  
      assign  TARGET23_AWBURST  = TARGET_AWBURST[(23+1)*2-1:23*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET23_AWLOCK   = (TARGET23_TYPE == 2'b11) ? TARGET_AWLOCK[(23+1)*2-1:23*2] : {1'b0, TARGET_AWLOCK[23*2]};
      assign  TARGET23_AWCACHE  = TARGET_AWCACHE[(23+1)*4-1:23*4];  
      assign  TARGET23_AWPROT   = TARGET_AWPROT[(23+1)*3-1:23*3];  
      assign  TARGET23_AWREGION = TARGET_AWREGION[(23+1)*4-1:23*4];   
      assign  TARGET23_AWQOS    = TARGET_AWQOS[(23+1)*4-1:23*4];  
      assign  TARGET23_AWUSER   = TARGET_AWUSER[(23+1)*USER_WIDTH-1:23*USER_WIDTH];  
      assign  TARGET23_AWVALID  = TARGET_AWVALID[23];  
      assign  TARGET23_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[23*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(23+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 23*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET23_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(23+1)*13-1:13*23]-1:SDW_LOWER_VEC[(23+1)*13-1:13*23]];  
      assign  TARGET23_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(23+1)*13-1:13*23]/8-1:SDW_LOWER_VEC[(23+1)*13-1:13*23]/8];  
      assign  TARGET23_WLAST    = TARGET_WLAST[23];  
      assign  TARGET23_WUSER    = TARGET_WUSER[(23+1)*USER_WIDTH-1:23*USER_WIDTH];  
      assign  TARGET23_WVALID   = TARGET_WVALID[23];      
      assign  TARGET23_BREADY   = TARGET_BREADY[23];        
      assign  TARGET23_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[23*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(23+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 23*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET23_ARADDR   = TARGET_ARADDR[(23+1)*ADDR_WIDTH-1:23*ADDR_WIDTH];  
      assign  TARGET23_ARLEN    = TARGET_ARLEN[(23+1)*8-1:23*8];  
      assign  TARGET23_ARSIZE   = TARGET_ARSIZE[(23+1)*3-1:23*3];  
      assign  TARGET23_ARBURST  = TARGET_ARBURST[(23+1)*2-1:23*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET23_ARLOCK   = (TARGET23_TYPE == 2'b11) ? TARGET_ARLOCK[(23+1)*2-1:23*2] : {1'b0, TARGET_ARLOCK[23*2]};
      assign  TARGET23_ARCACHE  = TARGET_ARCACHE[(23+1)*4-1:23*4] ;  
      assign  TARGET23_ARPROT   = TARGET_ARPROT[(23+1)*3-1:23*3] ;  
      assign  TARGET23_ARREGION = TARGET_ARREGION[(23+1)*4-1:23*4];   
      assign  TARGET23_ARQOS    = TARGET_ARQOS[(23+1)*4-1:23*4];  
      assign  TARGET23_ARUSER   = TARGET_ARUSER[(23+1)*USER_WIDTH-1:23*USER_WIDTH];  
      assign  TARGET23_ARVALID  = TARGET_ARVALID[23];      
      assign  TARGET23_RREADY   = TARGET_RREADY[23];  

      //Inputs      
      assign  TARGET_AWREADY[23]                                                                               = TARGET23_AWREADY;          
      assign  TARGET_WREADY[23]                                                                                = TARGET23_WREADY;        
      assign  TARGET_BID[(23+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:23*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET23_BID} : TARGET23_BID; 
      assign  TARGET_BRESP[(23+1)*2-1:23*2]                                                                    = TARGET23_BRESP;  
      assign  TARGET_BUSER[(23+1)*USER_WIDTH-1:23*USER_WIDTH]                                                  = TARGET23_BUSER;  
      assign  TARGET_BVALID[23]                                                                                = TARGET23_BVALID;        
      assign  TARGET_ARREADY[23]                                                                               = TARGET23_ARREADY;        
      assign  TARGET_RID[(23+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:23*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET23_RID} : TARGET23_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(23+1)*13-1:13*23]-1:SDW_LOWER_VEC[(23+1)*13-1:13*23]]                = TARGET23_RDATA;  
      assign  TARGET_RRESP[(23+1)*2-1:23*2]                                                                    = TARGET23_RRESP;  
      assign  TARGET_RLAST[23]                                                                                 = TARGET23_RLAST;  
      assign  TARGET_RUSER[(23+1)*USER_WIDTH-1:23*USER_WIDTH]                                                  = TARGET23_RUSER;  
      assign  TARGET_RVALID[23]                                                                                = TARGET23_RVALID;
    end
    
    if ( NUM_TARGETS > 24 )
    begin
      //===================================================================
      //Target24 Combine Signals
      //===================================================================
      //======================= TARGET24 TO/FROM External Side=================
      //Outputs
      assign  TARGET24_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[24*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(24+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 24*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET24_AWADDR   = TARGET_AWADDR[(24+1)*ADDR_WIDTH-1:24*ADDR_WIDTH];  
      assign  TARGET24_AWLEN    = TARGET_AWLEN[(24+1)*8-1:24*8];  
      assign  TARGET24_AWSIZE   = TARGET_AWSIZE[(24+1)*3-1:24*3];  
      assign  TARGET24_AWBURST  = TARGET_AWBURST[(24+1)*2-1:24*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET24_AWLOCK   = (TARGET24_TYPE == 2'b11) ? TARGET_AWLOCK[(24+1)*2-1:24*2] : {1'b0, TARGET_AWLOCK[24*2]};
      assign  TARGET24_AWCACHE  = TARGET_AWCACHE[(24+1)*4-1:24*4];  
      assign  TARGET24_AWPROT   = TARGET_AWPROT[(24+1)*3-1:24*3];  
      assign  TARGET24_AWREGION = TARGET_AWREGION[(24+1)*4-1:24*4];   
      assign  TARGET24_AWQOS    = TARGET_AWQOS[(24+1)*4-1:24*4];  
      assign  TARGET24_AWUSER   = TARGET_AWUSER[(24+1)*USER_WIDTH-1:24*USER_WIDTH];  
      assign  TARGET24_AWVALID  = TARGET_AWVALID[24];  
      assign  TARGET24_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[24*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(24+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 24*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET24_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(24+1)*13-1:13*24]-1:SDW_LOWER_VEC[(24+1)*13-1:13*24]];  
      assign  TARGET24_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(24+1)*13-1:13*24]/8-1:SDW_LOWER_VEC[(24+1)*13-1:13*24]/8];  
      assign  TARGET24_WLAST    = TARGET_WLAST[24];  
      assign  TARGET24_WUSER    = TARGET_WUSER[(24+1)*USER_WIDTH-1:24*USER_WIDTH];  
      assign  TARGET24_WVALID   = TARGET_WVALID[24];      
      assign  TARGET24_BREADY   = TARGET_BREADY[24];        
      assign  TARGET24_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[24*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(24+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 24*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET24_ARADDR   = TARGET_ARADDR[(24+1)*ADDR_WIDTH-1:24*ADDR_WIDTH];  
      assign  TARGET24_ARLEN    = TARGET_ARLEN[(24+1)*8-1:24*8];  
      assign  TARGET24_ARSIZE   = TARGET_ARSIZE[(24+1)*3-1:24*3];  
      assign  TARGET24_ARBURST  = TARGET_ARBURST[(24+1)*2-1:24*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET24_ARLOCK   = (TARGET24_TYPE == 2'b11) ? TARGET_ARLOCK[(24+1)*2-1:24*2] : {1'b0, TARGET_ARLOCK[24*2]};
      assign  TARGET24_ARCACHE  = TARGET_ARCACHE[(24+1)*4-1:24*4] ;  
      assign  TARGET24_ARPROT   = TARGET_ARPROT[(24+1)*3-1:24*3] ;  
      assign  TARGET24_ARREGION = TARGET_ARREGION[(24+1)*4-1:24*4];   
      assign  TARGET24_ARQOS    = TARGET_ARQOS[(24+1)*4-1:24*4];  
      assign  TARGET24_ARUSER   = TARGET_ARUSER[(24+1)*USER_WIDTH-1:24*USER_WIDTH];  
      assign  TARGET24_ARVALID  = TARGET_ARVALID[24];      
      assign  TARGET24_RREADY   = TARGET_RREADY[24];  

      //Inputs      
      assign  TARGET_AWREADY[24]                                                                               = TARGET24_AWREADY;          
      assign  TARGET_WREADY[24]                                                                                = TARGET24_WREADY;        
      assign  TARGET_BID[(24+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:24*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET24_BID} : TARGET24_BID; 
      assign  TARGET_BRESP[(24+1)*2-1:24*2]                                                                    = TARGET24_BRESP;  
      assign  TARGET_BUSER[(24+1)*USER_WIDTH-1:24*USER_WIDTH]                                                  = TARGET24_BUSER;  
      assign  TARGET_BVALID[24]                                                                                = TARGET24_BVALID;        
      assign  TARGET_ARREADY[24]                                                                               = TARGET24_ARREADY;        
      assign  TARGET_RID[(24+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:24*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET24_RID} : TARGET24_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(24+1)*13-1:13*24]-1:SDW_LOWER_VEC[(24+1)*13-1:13*24]]                = TARGET24_RDATA;  
      assign  TARGET_RRESP[(24+1)*2-1:24*2]                                                                    = TARGET24_RRESP;  
      assign  TARGET_RLAST[24]                                                                                 = TARGET24_RLAST;  
      assign  TARGET_RUSER[(24+1)*USER_WIDTH-1:24*USER_WIDTH]                                                  = TARGET24_RUSER;  
      assign  TARGET_RVALID[24]                                                                                = TARGET24_RVALID;
    end
    
    if ( NUM_TARGETS > 25 )
    begin
      //===================================================================
      //Target25 Combine Signals
      //===================================================================
      //======================= TARGET25 TO/FROM External Side=================
      //Outputs
      assign  TARGET25_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[25*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(25+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 25*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET25_AWADDR   = TARGET_AWADDR[(25+1)*ADDR_WIDTH-1:25*ADDR_WIDTH];  
      assign  TARGET25_AWLEN    = TARGET_AWLEN[(25+1)*8-1:25*8];  
      assign  TARGET25_AWSIZE   = TARGET_AWSIZE[(25+1)*3-1:25*3];  
      assign  TARGET25_AWBURST  = TARGET_AWBURST[(25+1)*2-1:25*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET25_AWLOCK   = (TARGET25_TYPE == 2'b11) ? TARGET_AWLOCK[(25+1)*2-1:25*2] : {1'b0, TARGET_AWLOCK[25*2]};
      assign  TARGET25_AWCACHE  = TARGET_AWCACHE[(25+1)*4-1:25*4];  
      assign  TARGET25_AWPROT   = TARGET_AWPROT[(25+1)*3-1:25*3];  
      assign  TARGET25_AWREGION = TARGET_AWREGION[(25+1)*4-1:25*4];   
      assign  TARGET25_AWQOS    = TARGET_AWQOS[(25+1)*4-1:25*4];  
      assign  TARGET25_AWUSER   = TARGET_AWUSER[(25+1)*USER_WIDTH-1:25*USER_WIDTH];  
      assign  TARGET25_AWVALID  = TARGET_AWVALID[25];  
      assign  TARGET25_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[25*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(25+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 25*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET25_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(25+1)*13-1:13*25]-1:SDW_LOWER_VEC[(25+1)*13-1:13*25]];  
      assign  TARGET25_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(25+1)*13-1:13*25]/8-1:SDW_LOWER_VEC[(25+1)*13-1:13*25]/8];  
      assign  TARGET25_WLAST    = TARGET_WLAST[25];  
      assign  TARGET25_WUSER    = TARGET_WUSER[(25+1)*USER_WIDTH-1:25*USER_WIDTH];  
      assign  TARGET25_WVALID   = TARGET_WVALID[25];      
      assign  TARGET25_BREADY   = TARGET_BREADY[25];        
      assign  TARGET25_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[25*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(25+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 25*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET25_ARADDR   = TARGET_ARADDR[(25+1)*ADDR_WIDTH-1:25*ADDR_WIDTH];  
      assign  TARGET25_ARLEN    = TARGET_ARLEN[(25+1)*8-1:25*8];  
      assign  TARGET25_ARSIZE   = TARGET_ARSIZE[(25+1)*3-1:25*3];  
      assign  TARGET25_ARBURST  = TARGET_ARBURST[(25+1)*2-1:25*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET25_ARLOCK   = (TARGET25_TYPE == 2'b11) ? TARGET_ARLOCK[(25+1)*2-1:25*2] : {1'b0, TARGET_ARLOCK[25*2]};
      assign  TARGET25_ARCACHE  = TARGET_ARCACHE[(25+1)*4-1:25*4] ;  
      assign  TARGET25_ARPROT   = TARGET_ARPROT[(25+1)*3-1:25*3] ;  
      assign  TARGET25_ARREGION = TARGET_ARREGION[(25+1)*4-1:25*4];   
      assign  TARGET25_ARQOS    = TARGET_ARQOS[(25+1)*4-1:25*4];  
      assign  TARGET25_ARUSER   = TARGET_ARUSER[(25+1)*USER_WIDTH-1:25*USER_WIDTH];  
      assign  TARGET25_ARVALID  = TARGET_ARVALID[25];      
      assign  TARGET25_RREADY   = TARGET_RREADY[25];  

      //Inputs      
      assign  TARGET_AWREADY[25]                                                                                = TARGET25_AWREADY;          
      assign  TARGET_WREADY[25]                                                                                 = TARGET25_WREADY;        
      assign  TARGET_BID[(25+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:25*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET25_BID} : TARGET25_BID; 
      assign  TARGET_BRESP[(25+1)*2-1:25*2]                                                                     = TARGET25_BRESP;  
      assign  TARGET_BUSER[(25+1)*USER_WIDTH-1:25*USER_WIDTH]                                                   = TARGET25_BUSER;  
      assign  TARGET_BVALID[25]                                                                                 = TARGET25_BVALID;        
      assign  TARGET_ARREADY[25]                                                                                = TARGET25_ARREADY;        
      assign  TARGET_RID[(25+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:25*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET25_RID} : TARGET25_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(25+1)*13-1:13*25]-1:SDW_LOWER_VEC[(25+1)*13-1:13*25]]                 = TARGET25_RDATA;  
      assign  TARGET_RRESP[(25+1)*2-1:25*2]                                                                     = TARGET25_RRESP;  
      assign  TARGET_RLAST[25]                                                                                  = TARGET25_RLAST;  
      assign  TARGET_RUSER[(25+1)*USER_WIDTH-1:25*USER_WIDTH]                                                   = TARGET25_RUSER;  
      assign  TARGET_RVALID[25]                                                                                 = TARGET25_RVALID;
    end
    
    if ( NUM_TARGETS > 26 )
    begin
      //===================================================================
      //Target26 Combine Signals
      //===================================================================
      //======================= TARGET26 TO/FROM External Side=================
      //Outputs
      assign  TARGET26_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[26*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(26+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 26*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET26_AWADDR   = TARGET_AWADDR[(26+1)*ADDR_WIDTH-1:26*ADDR_WIDTH];  
      assign  TARGET26_AWLEN    = TARGET_AWLEN[(26+1)*8-1:26*8];  
      assign  TARGET26_AWSIZE   = TARGET_AWSIZE[(26+1)*3-1:26*3];  
      assign  TARGET26_AWBURST  = TARGET_AWBURST[(26+1)*2-1:26*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET26_AWLOCK   = (TARGET26_TYPE == 2'b11) ? TARGET_AWLOCK[(26+1)*2-1:26*2] : {1'b0, TARGET_AWLOCK[26*2]};
      assign  TARGET26_AWCACHE  = TARGET_AWCACHE[(26+1)*4-1:26*4];  
      assign  TARGET26_AWPROT   = TARGET_AWPROT[(26+1)*3-1:26*3];  
      assign  TARGET26_AWREGION = TARGET_AWREGION[(26+1)*4-1:26*4];   
      assign  TARGET26_AWQOS    = TARGET_AWQOS[(26+1)*4-1:26*4];  
      assign  TARGET26_AWUSER   = TARGET_AWUSER[(26+1)*USER_WIDTH-1:26*USER_WIDTH];  
      assign  TARGET26_AWVALID  = TARGET_AWVALID[26];  
      assign  TARGET26_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[26*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(26+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 26*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET26_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(26+1)*13-1:13*26]-1:SDW_LOWER_VEC[(26+1)*13-1:13*26]];  
      assign  TARGET26_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(26+1)*13-1:13*26]/8-1:SDW_LOWER_VEC[(26+1)*13-1:13*26]/8];  
      assign  TARGET26_WLAST    = TARGET_WLAST[26];  
      assign  TARGET26_WUSER    = TARGET_WUSER[(26+1)*USER_WIDTH-1:26*USER_WIDTH];  
      assign  TARGET26_WVALID   = TARGET_WVALID[26];      
      assign  TARGET26_BREADY   = TARGET_BREADY[26];        
      assign  TARGET26_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[26*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(26+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 26*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET26_ARADDR   = TARGET_ARADDR[(26+1)*ADDR_WIDTH-1:26*ADDR_WIDTH];  
      assign  TARGET26_ARLEN    = TARGET_ARLEN[(26+1)*8-1:26*8];  
      assign  TARGET26_ARSIZE   = TARGET_ARSIZE[(26+1)*3-1:26*3];  
      assign  TARGET26_ARBURST  = TARGET_ARBURST[(26+1)*2-1:26*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET26_ARLOCK   = (TARGET26_TYPE == 2'b11) ? TARGET_ARLOCK[(26+1)*2-1:26*2] : {1'b0, TARGET_ARLOCK[26*2]};
      assign  TARGET26_ARCACHE  = TARGET_ARCACHE[(26+1)*4-1:26*4] ;  
      assign  TARGET26_ARPROT   = TARGET_ARPROT[(26+1)*3-1:26*3] ;  
      assign  TARGET26_ARREGION = TARGET_ARREGION[(26+1)*4-1:26*4];   
      assign  TARGET26_ARQOS    = TARGET_ARQOS[(26+1)*4-1:26*4];  
      assign  TARGET26_ARUSER   = TARGET_ARUSER[(26+1)*USER_WIDTH-1:26*USER_WIDTH];  
      assign  TARGET26_ARVALID  = TARGET_ARVALID[26];      
      assign  TARGET26_RREADY   = TARGET_RREADY[26];  

      //Inputs      
      assign  TARGET_AWREADY[26]                                                                               = TARGET26_AWREADY;          
      assign  TARGET_WREADY[26]                                                                                = TARGET26_WREADY;        
      assign  TARGET_BID[(26+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:26*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET26_BID} : TARGET26_BID; 
      assign  TARGET_BRESP[(26+1)*2-1:26*2]                                                                    = TARGET26_BRESP;  
      assign  TARGET_BUSER[(26+1)*USER_WIDTH-1:26*USER_WIDTH]                                                  = TARGET26_BUSER;  
      assign  TARGET_BVALID[26]                                                                                = TARGET26_BVALID;        
      assign  TARGET_ARREADY[26]                                                                               = TARGET26_ARREADY;        
      assign  TARGET_RID[(26+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:26*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET26_RID} : TARGET26_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(26+1)*13-1:13*26]-1:SDW_LOWER_VEC[(26+1)*13-1:13*26]]                = TARGET26_RDATA;  
      assign  TARGET_RRESP[(26+1)*2-1:26*2]                                                                    = TARGET26_RRESP;  
      assign  TARGET_RLAST[26]                                                                                 = TARGET26_RLAST;  
      assign  TARGET_RUSER[(26+1)*USER_WIDTH-1:26*USER_WIDTH]                                                  = TARGET26_RUSER;  
      assign  TARGET_RVALID[26]                                                                                = TARGET26_RVALID;
    end
    
    if ( NUM_TARGETS > 27 )
    begin
      //===================================================================
      //Target27 Combine Signals
      //===================================================================
      //======================= TARGET27 TO/FROM External Side=================
      //Outputs
      assign  TARGET27_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[27*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(27+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 27*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET27_AWADDR   = TARGET_AWADDR[(27+1)*ADDR_WIDTH-1:27*ADDR_WIDTH];  
      assign  TARGET27_AWLEN    = TARGET_AWLEN[(27+1)*8-1:27*8];  
      assign  TARGET27_AWSIZE   = TARGET_AWSIZE[(27+1)*3-1:27*3];  
      assign  TARGET27_AWBURST  = TARGET_AWBURST[(27+1)*2-1:27*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET27_AWLOCK   = (TARGET27_TYPE == 2'b11) ? TARGET_AWLOCK[(27+1)*2-1:27*2] : {1'b0, TARGET_AWLOCK[27*2]};
      assign  TARGET27_AWCACHE  = TARGET_AWCACHE[(27+1)*4-1:27*4];  
      assign  TARGET27_AWPROT   = TARGET_AWPROT[(27+1)*3-1:27*3];  
      assign  TARGET27_AWREGION = TARGET_AWREGION[(27+1)*4-1:27*4];   
      assign  TARGET27_AWQOS    = TARGET_AWQOS[(27+1)*4-1:27*4];  
      assign  TARGET27_AWUSER   = TARGET_AWUSER[(27+1)*USER_WIDTH-1:27*USER_WIDTH];  
      assign  TARGET27_AWVALID  = TARGET_AWVALID[27];  
      assign  TARGET27_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[27*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(27+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 27*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET27_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(27+1)*13-1:13*27]-1:SDW_LOWER_VEC[(27+1)*13-1:13*27]];  
      assign  TARGET27_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(27+1)*13-1:13*27]/8-1:SDW_LOWER_VEC[(27+1)*13-1:13*27]/8];  
      assign  TARGET27_WLAST    = TARGET_WLAST[27];  
      assign  TARGET27_WUSER    = TARGET_WUSER[(27+1)*USER_WIDTH-1:27*USER_WIDTH];  
      assign  TARGET27_WVALID   = TARGET_WVALID[27];      
      assign  TARGET27_BREADY   = TARGET_BREADY[27];        
      assign  TARGET27_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[27*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(27+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 27*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET27_ARADDR   = TARGET_ARADDR[(27+1)*ADDR_WIDTH-1:27*ADDR_WIDTH];  
      assign  TARGET27_ARLEN    = TARGET_ARLEN[(27+1)*8-1:27*8];  
      assign  TARGET27_ARSIZE   = TARGET_ARSIZE[(27+1)*3-1:27*3];  
      assign  TARGET27_ARBURST  = TARGET_ARBURST[(27+1)*2-1:27*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET27_ARLOCK   = (TARGET27_TYPE == 2'b11) ? TARGET_ARLOCK[(27+1)*2-1:27*2] : {1'b0, TARGET_ARLOCK[27*2]};
      assign  TARGET27_ARCACHE  = TARGET_ARCACHE[(27+1)*4-1:27*4] ;  
      assign  TARGET27_ARPROT   = TARGET_ARPROT[(27+1)*3-1:27*3] ;  
      assign  TARGET27_ARREGION = TARGET_ARREGION[(27+1)*4-1:27*4];   
      assign  TARGET27_ARQOS    = TARGET_ARQOS[(27+1)*4-1:27*4];  
      assign  TARGET27_ARUSER   = TARGET_ARUSER[(27+1)*USER_WIDTH-1:27*USER_WIDTH];  
      assign  TARGET27_ARVALID  = TARGET_ARVALID[27];      
      assign  TARGET27_RREADY   = TARGET_RREADY[27];  

      //Inputs      
      assign  TARGET_AWREADY[27]                                                                               = TARGET27_AWREADY;          
      assign  TARGET_WREADY[27]                                                                                = TARGET27_WREADY;        
      assign  TARGET_BID[(27+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:27*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET27_BID} : TARGET27_BID; 
      assign  TARGET_BRESP[(27+1)*2-1:27*2]                                                                    = TARGET27_BRESP;  
      assign  TARGET_BUSER[(27+1)*USER_WIDTH-1:27*USER_WIDTH]                                                  = TARGET27_BUSER;  
      assign  TARGET_BVALID[27]                                                                                = TARGET27_BVALID;        
      assign  TARGET_ARREADY[27]                                                                               = TARGET27_ARREADY;        
      assign  TARGET_RID[(27+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:27*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET27_RID} : TARGET27_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(27+1)*13-1:13*27]-1:SDW_LOWER_VEC[(27+1)*13-1:13*27]]                = TARGET27_RDATA;  
      assign  TARGET_RRESP[(27+1)*2-1:27*2]                                                                    = TARGET27_RRESP;  
      assign  TARGET_RLAST[27]                                                                                 = TARGET27_RLAST;  
      assign  TARGET_RUSER[(27+1)*USER_WIDTH-1:27*USER_WIDTH]                                                  = TARGET27_RUSER;  
      assign  TARGET_RVALID[27]                                                                                = TARGET27_RVALID;
    end
    
    if ( NUM_TARGETS > 28 )
    begin
      //===================================================================
      //Target28 Combine Signals
      //===================================================================
      //======================= TARGET28 TO/FROM External Side=================
      //Outputs
      assign  TARGET28_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[28*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(28+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 28*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET28_AWADDR   = TARGET_AWADDR[(28+1)*ADDR_WIDTH-1:28*ADDR_WIDTH];  
      assign  TARGET28_AWLEN    = TARGET_AWLEN[(28+1)*8-1:28*8];  
      assign  TARGET28_AWSIZE   = TARGET_AWSIZE[(28+1)*3-1:28*3];  
      assign  TARGET28_AWBURST  = TARGET_AWBURST[(28+1)*2-1:28*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET28_AWLOCK   = (TARGET28_TYPE == 2'b11) ? TARGET_AWLOCK[(28+1)*2-1:28*2] : {1'b0, TARGET_AWLOCK[28*2]};
      assign  TARGET28_AWCACHE  = TARGET_AWCACHE[(28+1)*4-1:28*4];  
      assign  TARGET28_AWPROT   = TARGET_AWPROT[(28+1)*3-1:28*3];  
      assign  TARGET28_AWREGION = TARGET_AWREGION[(28+1)*4-1:28*4];   
      assign  TARGET28_AWQOS    = TARGET_AWQOS[(28+1)*4-1:28*4];  
      assign  TARGET28_AWUSER   = TARGET_AWUSER[(28+1)*USER_WIDTH-1:28*USER_WIDTH];  
      assign  TARGET28_AWVALID  = TARGET_AWVALID[28];  
      assign  TARGET28_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[28*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(28+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 28*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET28_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(28+1)*13-1:13*28]-1:SDW_LOWER_VEC[(28+1)*13-1:13*28]];  
      assign  TARGET28_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(28+1)*13-1:13*28]/8-1:SDW_LOWER_VEC[(28+1)*13-1:13*28]/8];  
      assign  TARGET28_WLAST    = TARGET_WLAST[28];  
      assign  TARGET28_WUSER    = TARGET_WUSER[(28+1)*USER_WIDTH-1:28*USER_WIDTH];  
      assign  TARGET28_WVALID   = TARGET_WVALID[28];      
      assign  TARGET28_BREADY   = TARGET_BREADY[28];        
      assign  TARGET28_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[28*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(28+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 28*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET28_ARADDR   = TARGET_ARADDR[(28+1)*ADDR_WIDTH-1:28*ADDR_WIDTH];  
      assign  TARGET28_ARLEN    = TARGET_ARLEN[(28+1)*8-1:28*8];  
      assign  TARGET28_ARSIZE   = TARGET_ARSIZE[(28+1)*3-1:28*3];  
      assign  TARGET28_ARBURST  = TARGET_ARBURST[(28+1)*2-1:28*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET28_ARLOCK   = (TARGET28_TYPE == 2'b11) ? TARGET_ARLOCK[(28+1)*2-1:28*2] : {1'b0, TARGET_ARLOCK[28*2]};
      assign  TARGET28_ARCACHE  = TARGET_ARCACHE[(28+1)*4-1:28*4] ;  
      assign  TARGET28_ARPROT   = TARGET_ARPROT[(28+1)*3-1:28*3] ;  
      assign  TARGET28_ARREGION = TARGET_ARREGION[(28+1)*4-1:28*4];   
      assign  TARGET28_ARQOS    = TARGET_ARQOS[(28+1)*4-1:28*4];  
      assign  TARGET28_ARUSER   = TARGET_ARUSER[(28+1)*USER_WIDTH-1:28*USER_WIDTH];  
      assign  TARGET28_ARVALID  = TARGET_ARVALID[28];      
      assign  TARGET28_RREADY   = TARGET_RREADY[28];  

      //Inputs      
      assign  TARGET_AWREADY[28]                                                                               = TARGET28_AWREADY;          
      assign  TARGET_WREADY[28]                                                                                = TARGET28_WREADY;        
      assign  TARGET_BID[(28+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:28*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET28_BID} : TARGET28_BID; 
      assign  TARGET_BRESP[(28+1)*2-1:28*2]                                                                    = TARGET28_BRESP;  
      assign  TARGET_BUSER[(28+1)*USER_WIDTH-1:28*USER_WIDTH]                                                  = TARGET28_BUSER;  
      assign  TARGET_BVALID[28]                                                                                = TARGET28_BVALID;        
      assign  TARGET_ARREADY[28]                                                                               = TARGET28_ARREADY;        
      assign  TARGET_RID[(28+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:28*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET28_RID} : TARGET28_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(28+1)*13-1:13*28]-1:SDW_LOWER_VEC[(28+1)*13-1:13*28]]                = TARGET28_RDATA;  
      assign  TARGET_RRESP[(28+1)*2-1:28*2]                                                                    = TARGET28_RRESP;  
      assign  TARGET_RLAST[28]                                                                                 = TARGET28_RLAST;  
      assign  TARGET_RUSER[(28+1)*USER_WIDTH-1:28*USER_WIDTH]                                                  = TARGET28_RUSER;  
      assign  TARGET_RVALID[28]                                                                                = TARGET28_RVALID;
    end
    
    if ( NUM_TARGETS > 29 )
    begin
      //===================================================================
      //Target29 Combine Signals
      //===================================================================
      //======================= TARGET29 TO/FROM External Side=================
      //Outputs
      assign  TARGET29_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[29*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(29+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 29*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET29_AWADDR   = TARGET_AWADDR[(29+1)*ADDR_WIDTH-1:29*ADDR_WIDTH];  
      assign  TARGET29_AWLEN    = TARGET_AWLEN[(29+1)*8-1:29*8];  
      assign  TARGET29_AWSIZE   = TARGET_AWSIZE[(29+1)*3-1:29*3];  
      assign  TARGET29_AWBURST  = TARGET_AWBURST[(29+1)*2-1:29*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET29_AWLOCK   = (TARGET29_TYPE == 2'b11) ? TARGET_AWLOCK[(29+1)*2-1:29*2] : {1'b0, TARGET_AWLOCK[29*2]};
      assign  TARGET29_AWCACHE  = TARGET_AWCACHE[(29+1)*4-1:29*4];  
      assign  TARGET29_AWPROT   = TARGET_AWPROT[(29+1)*3-1:29*3];  
      assign  TARGET29_AWREGION = TARGET_AWREGION[(29+1)*4-1:29*4];   
      assign  TARGET29_AWQOS    = TARGET_AWQOS[(29+1)*4-1:29*4];  
      assign  TARGET29_AWUSER   = TARGET_AWUSER[(29+1)*USER_WIDTH-1:29*USER_WIDTH];  
      assign  TARGET29_AWVALID  = TARGET_AWVALID[29];  
      assign  TARGET29_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[29*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(29+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 29*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET29_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(29+1)*13-1:13*29]-1:SDW_LOWER_VEC[(29+1)*13-1:13*29]];  
      assign  TARGET29_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(29+1)*13-1:13*29]/8-1:SDW_LOWER_VEC[(29+1)*13-1:13*29]/8];  
      assign  TARGET29_WLAST    = TARGET_WLAST[29];  
      assign  TARGET29_WUSER    = TARGET_WUSER[(29+1)*USER_WIDTH-1:29*USER_WIDTH];  
      assign  TARGET29_WVALID   = TARGET_WVALID[29];      
      assign  TARGET29_BREADY   = TARGET_BREADY[29];        
      assign  TARGET29_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[29*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(29+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 29*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET29_ARADDR   = TARGET_ARADDR[(29+1)*ADDR_WIDTH-1:29*ADDR_WIDTH];  
      assign  TARGET29_ARLEN    = TARGET_ARLEN[(29+1)*8-1:29*8];  
      assign  TARGET29_ARSIZE   = TARGET_ARSIZE[(29+1)*3-1:29*3];  
      assign  TARGET29_ARBURST  = TARGET_ARBURST[(29+1)*2-1:29*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET29_ARLOCK   = (TARGET29_TYPE == 2'b11) ? TARGET_ARLOCK[(29+1)*2-1:29*2] : {1'b0, TARGET_ARLOCK[29*2]};
      assign  TARGET29_ARCACHE  = TARGET_ARCACHE[(29+1)*4-1:29*4] ;  
      assign  TARGET29_ARPROT   = TARGET_ARPROT[(29+1)*3-1:29*3] ;  
      assign  TARGET29_ARREGION = TARGET_ARREGION[(29+1)*4-1:29*4];   
      assign  TARGET29_ARQOS    = TARGET_ARQOS[(29+1)*4-1:29*4];  
      assign  TARGET29_ARUSER   = TARGET_ARUSER[(29+1)*USER_WIDTH-1:29*USER_WIDTH];  
      assign  TARGET29_ARVALID  = TARGET_ARVALID[29];      
      assign  TARGET29_RREADY   = TARGET_RREADY[29];  

      //Inputs      
      assign  TARGET_AWREADY[29]                                                                               = TARGET29_AWREADY;          
      assign  TARGET_WREADY[29]                                                                                = TARGET29_WREADY;        
      assign  TARGET_BID[(29+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:29*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET29_BID} : TARGET29_BID; 
      assign  TARGET_BRESP[(29+1)*2-1:29*2]                                                                    = TARGET29_BRESP;  
      assign  TARGET_BUSER[(29+1)*USER_WIDTH-1:29*USER_WIDTH]                                                  = TARGET29_BUSER;  
      assign  TARGET_BVALID[29]                                                                                = TARGET29_BVALID;        
      assign  TARGET_ARREADY[29]                                                                               = TARGET29_ARREADY;        
      assign  TARGET_RID[(29+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:29*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET29_RID} : TARGET29_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(29+1)*13-1:13*29]-1:SDW_LOWER_VEC[(29+1)*13-1:13*29]]                = TARGET29_RDATA;  
      assign  TARGET_RRESP[(29+1)*2-1:29*2]                                                                    = TARGET29_RRESP;  
      assign  TARGET_RLAST[29]                                                                                 = TARGET29_RLAST;  
      assign  TARGET_RUSER[(29+1)*USER_WIDTH-1:29*USER_WIDTH]                                                  = TARGET29_RUSER;  
      assign  TARGET_RVALID[29]                                                                                = TARGET29_RVALID;
    end
    
    if ( NUM_TARGETS > 30 )
    begin
      //===================================================================
      //Target30 Combine Signals
      //===================================================================
      //======================= TARGET30 TO/FROM External Side=================
      //Outputs
      assign  TARGET30_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[30*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(30+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 30*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET30_AWADDR   = TARGET_AWADDR[(30+1)*ADDR_WIDTH-1:30*ADDR_WIDTH];  
      assign  TARGET30_AWLEN    = TARGET_AWLEN[(30+1)*8-1:30*8];  
      assign  TARGET30_AWSIZE   = TARGET_AWSIZE[(30+1)*3-1:30*3];  
      assign  TARGET30_AWBURST  = TARGET_AWBURST[(30+1)*2-1:30*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET30_AWLOCK   = (TARGET30_TYPE == 2'b11) ? TARGET_AWLOCK[(30+1)*2-1:30*2] : {1'b0, TARGET_AWLOCK[30*2]};
      assign  TARGET30_AWCACHE  = TARGET_AWCACHE[(30+1)*4-1:30*4];  
      assign  TARGET30_AWPROT   = TARGET_AWPROT[(30+1)*3-1:30*3];  
      assign  TARGET30_AWREGION = TARGET_AWREGION[(30+1)*4-1:30*4];   
      assign  TARGET30_AWQOS    = TARGET_AWQOS[(30+1)*4-1:30*4];  
      assign  TARGET30_AWUSER   = TARGET_AWUSER[(30+1)*USER_WIDTH-1:30*USER_WIDTH];  
      assign  TARGET30_AWVALID  = TARGET_AWVALID[30];  
      assign  TARGET30_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[30*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(30+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 30*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET30_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(30+1)*13-1:13*30]-1:SDW_LOWER_VEC[(30+1)*13-1:13*30]];  
      assign  TARGET30_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(30+1)*13-1:13*30]/8-1:SDW_LOWER_VEC[(30+1)*13-1:13*30]/8];  
      assign  TARGET30_WLAST    = TARGET_WLAST[30];  
      assign  TARGET30_WUSER    = TARGET_WUSER[(30+1)*USER_WIDTH-1:30*USER_WIDTH];  
      assign  TARGET30_WVALID   = TARGET_WVALID[30];      
      assign  TARGET30_BREADY   = TARGET_BREADY[30];        
      assign  TARGET30_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[30*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(30+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 30*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET30_ARADDR   = TARGET_ARADDR[(30+1)*ADDR_WIDTH-1:30*ADDR_WIDTH];  
      assign  TARGET30_ARLEN    = TARGET_ARLEN[(30+1)*8-1:30*8];  
      assign  TARGET30_ARSIZE   = TARGET_ARSIZE[(30+1)*3-1:30*3];  
      assign  TARGET30_ARBURST  = TARGET_ARBURST[(30+1)*2-1:30*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET30_ARLOCK   = (TARGET30_TYPE == 2'b11) ? TARGET_ARLOCK[(30+1)*2-1:30*2] : {1'b0, TARGET_ARLOCK[30*2]};
      assign  TARGET30_ARCACHE  = TARGET_ARCACHE[(30+1)*4-1:30*4] ;  
      assign  TARGET30_ARPROT   = TARGET_ARPROT[(30+1)*3-1:30*3] ;  
      assign  TARGET30_ARREGION = TARGET_ARREGION[(30+1)*4-1:30*4];   
      assign  TARGET30_ARQOS    = TARGET_ARQOS[(30+1)*4-1:30*4];  
      assign  TARGET30_ARUSER   = TARGET_ARUSER[(30+1)*USER_WIDTH-1:30*USER_WIDTH];  
      assign  TARGET30_ARVALID  = TARGET_ARVALID[30];      
      assign  TARGET30_RREADY   = TARGET_RREADY[30];  

      //Inputs      
      assign  TARGET_AWREADY[30]                                                                              = TARGET30_AWREADY;          
      assign  TARGET_WREADY[30]                                                                               = TARGET30_WREADY;        
      assign  TARGET_BID[(30+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:30*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET30_BID} : TARGET30_BID; 
      assign  TARGET_BRESP[(30+1)*2-1:30*2]                                                                   = TARGET30_BRESP;  
      assign  TARGET_BUSER[(30+1)*USER_WIDTH-1:30*USER_WIDTH]                                                 = TARGET30_BUSER;  
      assign  TARGET_BVALID[30]                                                                               = TARGET30_BVALID;        
      assign  TARGET_ARREADY[30]                                                                              = TARGET30_ARREADY;        
      assign  TARGET_RID[(30+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:30*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET30_RID} : TARGET30_RID;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(30+1)*13-1:13*30]-1:SDW_LOWER_VEC[(30+1)*13-1:13*30]]               = TARGET30_RDATA;  
      assign  TARGET_RRESP[(30+1)*2-1:30*2]                                                                   = TARGET30_RRESP;  
      assign  TARGET_RLAST[30]                                                                                = TARGET30_RLAST;  
      assign  TARGET_RUSER[(30+1)*USER_WIDTH-1:30*USER_WIDTH]                                                 = TARGET30_RUSER;  
      assign  TARGET_RVALID[30]                                                                               = TARGET30_RVALID;
	  
    end
    
    if ( NUM_TARGETS > 31 )
    begin
      //===================================================================
      //Target31 Combine Signals
      //===================================================================
      //======================= TARGET31 TO/FROM External Side=================
      //Outputs
      assign  TARGET31_AWID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_AWID[31*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_AWID[(31+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 31*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET31_AWADDR   = TARGET_AWADDR[(31+1)*ADDR_WIDTH-1:31*ADDR_WIDTH];  
      assign  TARGET31_AWLEN    = TARGET_AWLEN[(31+1)*8-1:31*8];  
      assign  TARGET31_AWSIZE   = TARGET_AWSIZE[(31+1)*3-1:31*3];  
      assign  TARGET31_AWBURST  = TARGET_AWBURST[(31+1)*2-1:31*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET31_AWLOCK   = (TARGET31_TYPE == 2'b11) ? TARGET_AWLOCK[(31+1)*2-1:31*2] : {1'b0, TARGET_AWLOCK[31*2]};
      assign  TARGET31_AWCACHE  = TARGET_AWCACHE[(31+1)*4-1:31*4];  
      assign  TARGET31_AWPROT   = TARGET_AWPROT[(31+1)*3-1:31*3];  
      assign  TARGET31_AWREGION = TARGET_AWREGION[(31+1)*4-1:31*4];   
      assign  TARGET31_AWQOS    = TARGET_AWQOS[(31+1)*4-1:31*4];  
      assign  TARGET31_AWUSER   = TARGET_AWUSER[(31+1)*USER_WIDTH-1:31*USER_WIDTH];  
      assign  TARGET31_AWVALID  = TARGET_AWVALID[31];  
      assign  TARGET31_WID      = NUM_INITIATORS_WIDTH == 0 ? TARGET_WID[31*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_WID[(31+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 31*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET31_WDATA    = TARGET_WDATA[SDW_UPPER_VEC[(31+1)*13-1:13*31]-1:SDW_LOWER_VEC[(31+1)*13-1:13*31]];  
      assign  TARGET31_WSTRB    = TARGET_WSTRB[SDW_UPPER_VEC[(31+1)*13-1:13*31]/8-1:SDW_LOWER_VEC[(31+1)*13-1:13*31]/8];  
      assign  TARGET31_WLAST    = TARGET_WLAST[31];  
      assign  TARGET31_WUSER    = TARGET_WUSER[(31+1)*USER_WIDTH-1:31*USER_WIDTH];  
      assign  TARGET31_WVALID   = TARGET_WVALID[31];      
      assign  TARGET31_BREADY   = TARGET_BREADY[31];        
      assign  TARGET31_ARID     = NUM_INITIATORS_WIDTH == 0 ? TARGET_ARID[31*(ID_WIDTH+1) +: ID_WIDTH] : TARGET_ARID[(31+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1 : 31*(NUM_INITIATORS_WIDTH+ID_WIDTH)];
      assign  TARGET31_ARADDR   = TARGET_ARADDR[(31+1)*ADDR_WIDTH-1:31*ADDR_WIDTH];  
      assign  TARGET31_ARLEN    = TARGET_ARLEN[(31+1)*8-1:31*8];  
      assign  TARGET31_ARSIZE   = TARGET_ARSIZE[(31+1)*3-1:31*3];  
      assign  TARGET31_ARBURST  = TARGET_ARBURST[(31+1)*2-1:31*2];  
      // SAR#LINT-002: Explicit width for AXI4 mode (1-bit LOCK zero-padded to 2-bit)
      assign  TARGET31_ARLOCK   = (TARGET31_TYPE == 2'b11) ? TARGET_ARLOCK[(31+1)*2-1:31*2] : {1'b0, TARGET_ARLOCK[31*2]};
      assign  TARGET31_ARCACHE  = TARGET_ARCACHE[(31+1)*4-1:31*4] ;  
      assign  TARGET31_ARPROT   = TARGET_ARPROT[(31+1)*3-1:31*3] ;  
      assign  TARGET31_ARREGION = TARGET_ARREGION[(31+1)*4-1:31*4];   
      assign  TARGET31_ARQOS    = TARGET_ARQOS[(31+1)*4-1:31*4];  
      assign  TARGET31_ARUSER   = TARGET_ARUSER[(31+1)*USER_WIDTH-1:31*USER_WIDTH];  
      assign  TARGET31_ARVALID  = TARGET_ARVALID[31];      
      assign  TARGET31_RREADY   = TARGET_RREADY[31];  

      //Inputs      
      assign  TARGET_AWREADY[31]                                                                              = TARGET31_AWREADY;          
      assign  TARGET_WREADY[31]                                                                               = TARGET31_WREADY;        
      assign  TARGET_BID[(31+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:31*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET31_BID} : TARGET31_BID; 
      assign  TARGET_BRESP[(31+1)*2-1:31*2]                                                                   = TARGET31_BRESP;  
      assign  TARGET_BUSER[(31+1)*USER_WIDTH-1:31*USER_WIDTH]                                                 = TARGET31_BUSER;  
      assign  TARGET_BVALID[31]                                                                               = TARGET31_BVALID;        
      assign  TARGET_ARREADY[31]                                                                              = TARGET31_ARREADY;        
      assign  TARGET_RID[(31+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:31*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] = NUM_INITIATORS_WIDTH == 0 ? {1'b0,TARGET31_RID} : TARGET31_RID ;  
      assign  TARGET_RDATA[SDW_UPPER_VEC[(31+1)*13-1:13*31]-1:SDW_LOWER_VEC[(31+1)*13-1:13*31]]               = TARGET31_RDATA;  
      assign  TARGET_RRESP[(31+1)*2-1:31*2]                                                                   = TARGET31_RRESP;  
      assign  TARGET_RLAST[31]                                                                                = TARGET31_RLAST;  
      assign  TARGET_RUSER[(31+1)*USER_WIDTH-1:31*USER_WIDTH]                                                 = TARGET31_RUSER;  
      assign  TARGET_RVALID[31]                                                                               = TARGET31_RVALID;
    end
    
  //===============================================================================================================================

  // INITIATOR clocks
  generate
  if(INITIATOR0_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[0] = I_CLK0;
  else if(BYPASS_CROSSBAR == 1)
    assign I_CLK[0] = T_CLK0;
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
  if(INITIATOR8_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[8] = I_CLK8;
  else
    assign I_CLK[8] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR9_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[9] = I_CLK9;
  else
    assign I_CLK[9] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR10_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[10] = I_CLK10;
  else
    assign I_CLK[10] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR11_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[11] = I_CLK11;
  else
    assign I_CLK[11] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR12_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[12] = I_CLK12;
  else
    assign I_CLK[12] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR13_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[13] = I_CLK13;
  else
    assign I_CLK[13] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR14_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[14] = I_CLK14;
  else
    assign I_CLK[14] = ACLK;
  endgenerate
  
  generate
  if(INITIATOR15_CLOCK_DOMAIN_CROSSING)
    assign I_CLK[15] = I_CLK15;
  else
    assign I_CLK[15] = ACLK;
  endgenerate  
  
  //Initiator Synchronized Reset 

  generate
  if(INITIATOR0_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN0 = i_sync_rstn[0];
  else
    assign I_SYNC_RSTN0 = 1'b1;
  endgenerate

  generate
  if(INITIATOR1_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN1 = i_sync_rstn[1];
  else
    assign I_SYNC_RSTN1 = 1'b1;
  endgenerate

  generate
  if(INITIATOR2_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN2 = i_sync_rstn[2];
  else
    assign I_SYNC_RSTN2 = 1'b1;
  endgenerate

  generate
  if(INITIATOR3_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN3 = i_sync_rstn[3];
  else
    assign I_SYNC_RSTN3 = 1'b1;
  endgenerate

  generate
  if(INITIATOR4_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN4 = i_sync_rstn[4];
  else
    assign I_SYNC_RSTN4 = 1'b1;
  endgenerate

  generate
  if(INITIATOR5_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN5 = i_sync_rstn[5];
  else
    assign I_SYNC_RSTN5 = 1'b1;
  endgenerate

  generate
  if(INITIATOR6_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN6 = i_sync_rstn[6];
  else
    assign I_SYNC_RSTN6 = 1'b1;
  endgenerate

  generate
  if(INITIATOR7_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN7 = i_sync_rstn[7];
  else
    assign I_SYNC_RSTN7 = 1'b1;
  endgenerate

  generate
  if(INITIATOR8_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN8 = i_sync_rstn[8];
  else
    assign I_SYNC_RSTN8 = 1'b1;
  endgenerate

  generate
  if(INITIATOR9_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN9 = i_sync_rstn[9];
  else
    assign I_SYNC_RSTN9 = 1'b1;
  endgenerate

  generate
  if(INITIATOR10_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN10 = i_sync_rstn[10];
  else
    assign I_SYNC_RSTN10 = 1'b1;
  endgenerate

  generate
  if(INITIATOR11_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN11 = i_sync_rstn[11];
  else
    assign I_SYNC_RSTN11 = 1'b1;
  endgenerate

  generate
  if(INITIATOR12_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN12 = i_sync_rstn[12];
  else
    assign I_SYNC_RSTN12 = 1'b1;
  endgenerate

  generate
  if(INITIATOR13_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN13 = i_sync_rstn[13];
  else
    assign I_SYNC_RSTN13 = 1'b1;
  endgenerate

  generate
  if(INITIATOR14_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN14 = i_sync_rstn[14];
  else
    assign I_SYNC_RSTN14 = 1'b1;
  endgenerate

  generate
  if(INITIATOR15_CLOCK_DOMAIN_CROSSING)
    assign I_SYNC_RSTN15 = i_sync_rstn[15];
  else
    assign I_SYNC_RSTN15 = 1'b1;
  endgenerate
  
  // Target Clocks
  generate
  if(TARGET0_CLOCK_DOMAIN_CROSSING | (BYPASS_CROSSBAR == 1))
    assign T_CLK[0] = T_CLK0;
  else
    assign T_CLK[0] = CB_CLK;
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
  
  //Target Synchronized Reset 
  
  generate
  if(TARGET0_CLOCK_DOMAIN_CROSSING | (BYPASS_CROSSBAR == 1))
    assign T_SYNC_RSTN0 = t_sync_rstn[0];
  else
    assign T_SYNC_RSTN0 = 1'b1;
  endgenerate

  generate
  if(TARGET1_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN1 = t_sync_rstn[1];
  else
    assign T_SYNC_RSTN1 = 1'b1;
  endgenerate

  generate
  if(TARGET2_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN2 = t_sync_rstn[2];
  else
    assign T_SYNC_RSTN2 = 1'b1;
  endgenerate

  generate
  if(TARGET3_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN3 = t_sync_rstn[3];
  else
    assign T_SYNC_RSTN3 = 1'b1;
  endgenerate

  generate
  if(TARGET4_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN4 = t_sync_rstn[4];
  else
    assign T_SYNC_RSTN4 = 1'b1;
  endgenerate

  generate
  if(TARGET5_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN5 = t_sync_rstn[5];
  else
    assign T_SYNC_RSTN5 = 1'b1;
  endgenerate

  generate
  if(TARGET6_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN6 = t_sync_rstn[6];
  else
    assign T_SYNC_RSTN6 = 1'b1;
  endgenerate

  generate
  if(TARGET7_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN7 = t_sync_rstn[7];
  else
    assign T_SYNC_RSTN7 = 1'b1;
  endgenerate

  generate
  if(TARGET8_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN8 = t_sync_rstn[8];
  else
    assign T_SYNC_RSTN8 = 1'b1;
  endgenerate

  generate
  if(TARGET9_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN9 = t_sync_rstn[9];
  else
    assign T_SYNC_RSTN9 = 1'b1;
  endgenerate

  generate
  if(TARGET10_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN10 = t_sync_rstn[10];
  else
    assign T_SYNC_RSTN10 = 1'b1;
  endgenerate

  generate
  if(TARGET11_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN11 = t_sync_rstn[11];
  else
    assign T_SYNC_RSTN11 = 1'b1;
  endgenerate

  generate
  if(TARGET12_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN12 = t_sync_rstn[12];
  else
    assign T_SYNC_RSTN12 = 1'b1;
  endgenerate

  generate
  if(TARGET13_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN13 = t_sync_rstn[13];
  else
    assign T_SYNC_RSTN13 = 1'b1;
  endgenerate

  generate
  if(TARGET14_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN14 = t_sync_rstn[14];
  else
    assign T_SYNC_RSTN14 = 1'b1;
  endgenerate

  generate
  if(TARGET15_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN15 = t_sync_rstn[15];
  else
    assign T_SYNC_RSTN15 = 1'b1;
  endgenerate

  generate
  if(TARGET16_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN16 = t_sync_rstn[16];
  else
    assign T_SYNC_RSTN16 = 1'b1;
  endgenerate

  generate
  if(TARGET17_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN17 = t_sync_rstn[17];
  else
    assign T_SYNC_RSTN17 = 1'b1;
  endgenerate

  generate
  if(TARGET18_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN18 = t_sync_rstn[18];
  else
    assign T_SYNC_RSTN18 = 1'b1;
  endgenerate

  generate
  if(TARGET19_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN19 = t_sync_rstn[19];
  else
    assign T_SYNC_RSTN19 = 1'b1;
  endgenerate

  generate
  if(TARGET20_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN20 = t_sync_rstn[20];
  else
    assign T_SYNC_RSTN20 = 1'b1;
  endgenerate

  generate
  if(TARGET21_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN21 = t_sync_rstn[21];
  else
    assign T_SYNC_RSTN21 = 1'b1;
  endgenerate

  generate
  if(TARGET22_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN22 = t_sync_rstn[22];
  else
    assign T_SYNC_RSTN22 = 1'b1;
  endgenerate

  generate
  if(TARGET23_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN23 = t_sync_rstn[23];
  else
    assign T_SYNC_RSTN23 = 1'b1;
  endgenerate

  generate
  if(TARGET24_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN24 = t_sync_rstn[24];
  else
    assign T_SYNC_RSTN24 = 1'b1;
  endgenerate

  generate
  if(TARGET25_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN25 = t_sync_rstn[25];
  else
    assign T_SYNC_RSTN25 = 1'b1;
  endgenerate

  generate
  if(TARGET26_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN26 = t_sync_rstn[26];
  else
    assign T_SYNC_RSTN26 = 1'b1;
  endgenerate

  generate
  if(TARGET27_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN27 = t_sync_rstn[27];
  else
    assign T_SYNC_RSTN27 = 1'b1;
  endgenerate

  generate
  if(TARGET28_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN28 = t_sync_rstn[28];
  else
    assign T_SYNC_RSTN28 = 1'b1;
  endgenerate

  generate
  if(TARGET29_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN29 = t_sync_rstn[29];
  else
    assign T_SYNC_RSTN29 = 1'b1;
  endgenerate

  generate
  if(TARGET30_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN30 = t_sync_rstn[30];
  else
    assign T_SYNC_RSTN30 = 1'b1;
  endgenerate

  generate
  if(TARGET31_CLOCK_DOMAIN_CROSSING)
    assign T_SYNC_RSTN31 = t_sync_rstn[31];
  else
    assign T_SYNC_RSTN31 = 1'b1;
  endgenerate
 

  //Reset synchronizer to remove cdc violations
  
  caxi4interconnect_ResetSync #
  (
    .SYNC_RESET (SYNC_RESET ),
    .FAMILY     (FAMILY     )
  ) arst_aclk_sync
  (
    .sysClk	    ( (BYPASS_CROSSBAR == 1) ? T_CLK0 : ACLK ),
	.sysReset_L ( ARESETN    ),			// active low reset synchronoise to RE AClk - asserted async.
	.arst_sync  ( arst_sync  ), 	    // active low sysReset synchronised to ACLK
	.srst_sync  ( srst_sync  )	        // active low sysReset synchronised to ACLK
  );
  
  assign ARESETN_SYNC = (EXPOSE_RST == 1) ? (SYNC_RESET == 1) ? srst_sync : arst_sync : 1'b1;
  
  
  
generate  
  if(BYPASS_CROSSBAR == 0) begin : gen_cb_en 
    caxi4interconnect_Axi4CrossBar #
      (
        .NUM_INITIATORS                 ( NUM_INITIATORS               ),         // defines number of initiators
        .NUM_INITIATORS_WIDTH           ( NUM_INITIATORS_WIDTH_ADJ     ),
        .NUM_TARGETS                    ( NUM_TARGETS                  ),         // defines number of targets
    
        .ADDR_WIDTH                     ( ADDR_WIDTH                   ),        
        .DATA_WIDTH                     ( CB_DWIDTH                    ),
        .ID_WIDTH                       ( ID_WIDTH                     ),
    
        .NUM_THREADS                    ( I_NUM_THREADS                ),
        .OPEN_TRANS_MAX                 ( I_OPEN_TRANS_MAX             ), 
        .OPEN_WRTRANS_MAX               ( OPEN_WRTRANS_MAX             ),
        .OPEN_RDTRANS_MAX               ( OPEN_RDTRANS_MAX             ),
    
        .UPPER_COMPARE_BIT              ( UPPER_COMPARE_BIT            ),
        .LOWER_COMPARE_BIT              ( LOWER_COMPARE_BIT            ),
    
        .SLOT_BASE_VEC                  ( SLOT_BASE_VEC                ),
        .SLOT_MIN_VEC                   ( SLOT_MIN_VEC                 ),
        .SLOT_MAX_VEC                   ( SLOT_MAX_VEC                 ),
      
        .SUPPORT_USER_SIGNALS           ( SUPPORT_USER_SIGNALS         ),
        .USER_WIDTH                     ( USER_WIDTH                   ),
        .CROSSBAR_MODE                  ( CROSSBAR_MODE                ),
    
        .INITIATOR_WRITE_CONNECTIVITY   ( INITIATOR_WRITE_CONNECTIVITY ), 
        .INITIATOR_READ_CONNECTIVITY    ( INITIATOR_READ_CONNECTIVITY  ),
        .HI_FREQ                        ( HI_FREQ                      ),
        .RD_ARB_EN                      ( RD_ARB_EN                    ),
        .READ_INTERLEAVE                ( CROSSBAR_INTERLEAVE          ),
        .PIPE                           ( PIPE                         ),
        .CROSSBAR_RAM_TYPE              ( CROSSBAR_RAM_TYPE            ),
        .SYNC_RESET                     ( SYNC_RESET                   ),
        .MAX_TRANS                      ( MAX_TRANS                    ),
        .TARGET_READ_INTERLEAVE         ( TARGET_READ_INTERLEAVE       )
      )
    axicb (
        // Global Signals
        .ACLK               ( ACLK              ),
        .arst_sync          ( arst_sync         ),
        .srst_sync          ( srst_sync         ),
    
        // INITIATOR Write Address Ports
        .INITIATOR_AWID     ( initiatorAWID     ),
        .INITIATOR_AWADDR   ( initiatorAWADDR   ),
        .INITIATOR_AWLEN    ( initiatorAWLEN    ),
        .INITIATOR_AWSIZE   ( initiatorAWSIZE   ),
        .INITIATOR_AWBURST  ( initiatorAWBURST  ),
        .INITIATOR_AWLOCK   ( initiatorAWLOCK   ),
        .INITIATOR_AWCACHE  ( initiatorAWCACHE  ),
        .INITIATOR_AWPROT   ( initiatorAWPROT   ),
        .INITIATOR_AWREGION ( initiatorAWREGION ),
        .INITIATOR_AWQOS    ( initiatorAWQOS    ),        // not used
        .INITIATOR_AWUSER   ( initiatorAWUSER   ),        // not used
        .INITIATOR_AWVALID  ( initiatorAWVALID  ),
        .INITIATOR_AWREADY  ( initiatorAWREADY  ),
    
        // INITIATOR Write Data Ports
	    .INITIATOR_WID      ( initiatorWID      ),
        .INITIATOR_WDATA    ( initiatorWDATA    ),
        .INITIATOR_WSTRB    ( initiatorWSTRB    ),
        .INITIATOR_WLAST    ( initiatorWLAST    ),
        .INITIATOR_WUSER    ( initiatorWUSER    ),
        .INITIATOR_WVALID   ( initiatorWVALID   ),
        .INITIATOR_WREADY   ( initiatorWREADY   ),
    
        // INITIATOR Write Response Ports
        .INITIATOR_BID      ( initiatorBID      ),
        .INITIATOR_BRESP    ( initiatorBRESP    ),
        .INITIATOR_BUSER    ( initiatorBUSER    ),
        .INITIATOR_BVALID   ( initiatorBVALID   ),
        .INITIATOR_BREADY   ( initiatorBREADY   ),
    
        // INITIATOR Read Address Ports
        .INITIATOR_ARID     ( initiatorARID     ),
        .INITIATOR_ARADDR   ( initiatorARADDR   ),
        .INITIATOR_ARLEN    ( initiatorARLEN    ),
        .INITIATOR_ARSIZE   ( initiatorARSIZE   ),
        .INITIATOR_ARBURST  ( initiatorARBURST  ),
        .INITIATOR_ARLOCK   ( initiatorARLOCK   ),
        .INITIATOR_ARCACHE  ( initiatorARCACHE  ),
        .INITIATOR_ARPROT   ( initiatorARPROT   ),
        .INITIATOR_ARREGION ( initiatorARREGION ),
        .INITIATOR_ARQOS    ( initiatorARQOS    ),        // not used
        .INITIATOR_ARUSER   ( initiatorARUSER   ),
        .INITIATOR_ARVALID  ( initiatorARVALID  ),
        .INITIATOR_ARREADY  ( initiatorARREADY  ),
    
        // INITIATOR Read Data Ports
        .INITIATOR_RID      ( initiatorRID      ),
        .INITIATOR_RDATA    ( initiatorRDATA    ), // output from this module, initiatorRDATA = targetRDATA
        .INITIATOR_RRESP    ( initiatorRRESP    ),
        .INITIATOR_RLAST    ( initiatorRLAST    ),
        .INITIATOR_RUSER    ( initiatorRUSER    ),
        .INITIATOR_RVALID   ( initiatorRVALID   ),
        .INITIATOR_RREADY   ( initiatorRREADY   ),
     
        // Target Write Address Port
        .TARGET_AWID        ( targetAWID        ),
        .TARGET_AWADDR      ( targetAWADDR      ),
        .TARGET_AWLEN       ( targetAWLEN       ),
        .TARGET_AWSIZE      ( targetAWSIZE      ),
        .TARGET_AWBURST     ( targetAWBURST     ),
        .TARGET_AWLOCK      ( targetAWLOCK      ),
        .TARGET_AWCACHE     ( targetAWCACHE     ),
        .TARGET_AWPROT      ( targetAWPROT      ),
        .TARGET_AWREGION    ( targetAWREGION    ),      // not used
        .TARGET_AWQOS       ( targetAWQOS       ),      // not used
        .TARGET_AWUSER      ( targetAWUSER      ),
        .TARGET_AWVALID     ( targetAWVALID     ),
        .TARGET_AWREADY     ( targetAWREADY     ),
     
        // Target Write Data Ports
	    .TARGET_WID         ( targetWID         ),
        .TARGET_WDATA       ( targetWDATA       ),
        .TARGET_WSTRB       ( targetWSTRB       ),
        .TARGET_WLAST       ( targetWLAST       ),
        .TARGET_WUSER       ( targetWUSER       ),
        .TARGET_WVALID      ( targetWVALID      ),
        .TARGET_WREADY      ( targetWREADY      ),
    
        // Target Write Response Ports
        .TARGET_BID         ( targetBID         ),
        .TARGET_BRESP       ( targetBRESP       ),
        .TARGET_BUSER       ( targetBUSER       ),
        .TARGET_BVALID      ( targetBVALID      ),
        .TARGET_BREADY      ( targetBREADY      ),
     
        // Target Read Address Port
        .TARGET_ARID        ( targetARID        ),
        .TARGET_ARADDR      ( targetARADDR      ),
        .TARGET_ARLEN       ( targetARLEN       ),
        .TARGET_ARSIZE      ( targetARSIZE      ),
        .TARGET_ARBURST     ( targetARBURST     ),
        .TARGET_ARLOCK      ( targetARLOCK      ),
        .TARGET_ARCACHE     ( targetARCACHE     ),
        .TARGET_ARPROT      ( targetARPROT      ),
        .TARGET_ARREGION    ( targetARREGION    ),      // not used
        .TARGET_ARQOS       ( targetARQOS       ),      // not used
        .TARGET_ARUSER      ( targetARUSER      ),
        .TARGET_ARVALID     ( targetARVALID     ),
        .TARGET_ARREADY     ( targetARREADY     ),
     
        // Target Read Data Ports
        .TARGET_RID         ( targetRID         ),
        .TARGET_RDATA       ( targetRDATA       ), // input to this module
        .TARGET_RRESP       ( targetRRESP       ),
        .TARGET_RLAST       ( targetRLAST       ),
        .TARGET_RUSER       ( targetRUSER       ),      // not used
        .TARGET_RVALID      ( targetRVALID      ),
        .TARGET_RREADY      ( targetRREADY      )
     );
  end else begin : gen_cb_dis
    assign  targetAWID        [ID_WIDTH-1:0]      = initiatorAWID     [ID_WIDTH-1:0]      ;   
    assign  targetAWADDR      [ADDR_WIDTH-1:0]    = initiatorAWADDR   [ADDR_WIDTH-1:0]    ;
    assign  targetAWLEN       [7:0]               = initiatorAWLEN    [7:0]               ;
    assign  targetAWSIZE      [2:0]               = initiatorAWSIZE   [2:0]               ;
    assign  targetAWBURST     [1:0]               = initiatorAWBURST  [1:0]               ;
    assign  targetAWLOCK      [1:0]               = initiatorAWLOCK   [1:0]               ;
    assign  targetAWCACHE     [3:0]               = initiatorAWCACHE  [3:0]               ;
    assign  targetAWPROT      [2:0]               = initiatorAWPROT   [2:0]               ;
    assign  targetAWREGION    [3:0]               = initiatorAWREGION [3:0]               ;
    assign  targetAWQOS       [3:0]               = initiatorAWQOS    [3:0]               ;
    assign  targetAWUSER      [USER_WIDTH-1:0]    = initiatorAWUSER   [USER_WIDTH-1:0]    ;
    assign  targetAWVALID     [0]                 = initiatorAWVALID  [0]                 ;
    assign  targetWID         [ID_WIDTH-1:0]      = initiatorWID      [ID_WIDTH-1:0]      ;
    assign  targetWDATA       [CB_DWIDTH-1:0]     = initiatorWDATA    [CB_DWIDTH-1:0]     ;
    assign  targetWSTRB       [(CB_DWIDTH/8)-1:0] = initiatorWSTRB    [(CB_DWIDTH/8)-1:0] ;
    assign  targetWLAST       [0]                 = initiatorWLAST    [0]                 ;
    assign  targetWUSER       [USER_WIDTH-1:0]    = initiatorWUSER    [USER_WIDTH-1:0]    ;
    assign  targetWVALID      [0]                 = initiatorWVALID   [0]                 ;
    assign  targetBREADY      [0]                 = initiatorBREADY   [0]                 ;
    assign  targetARID        [ID_WIDTH-1:0]      = initiatorARID     [ID_WIDTH-1:0]      ;
    assign  targetARADDR      [ADDR_WIDTH-1:0]    = initiatorARADDR   [ADDR_WIDTH-1:0]    ;
    assign  targetARLEN       [7:0]               = initiatorARLEN    [7:0]               ;
    assign  targetARSIZE      [2:0]               = initiatorARSIZE   [2:0]               ;
    assign  targetARBURST     [1:0]               = initiatorARBURST  [1:0]               ;
    assign  targetARLOCK      [1:0]               = initiatorARLOCK   [1:0]               ;
    assign  targetARCACHE     [3:0]               = initiatorARCACHE  [3:0]               ;
    assign  targetARPROT      [2:0]               = initiatorARPROT   [2:0]               ;
    assign  targetARREGION    [3:0]               = initiatorARREGION [3:0]               ;
    assign  targetARQOS       [3:0]               = initiatorARQOS    [3:0]               ;
    assign  targetARUSER      [USER_WIDTH-1:0]    = initiatorARUSER   [USER_WIDTH-1:0]    ;
    assign  targetARVALID     [0]                 = initiatorARVALID  [0]                 ;
    assign  targetRREADY      [0]                 = initiatorRREADY   [0]                 ;
    assign  initiatorAWREADY  [0]                 = targetAWREADY     [0]                 ;
    assign  initiatorWREADY   [0]                 = targetWREADY      [0]                 ;
    assign  initiatorBID      [ID_WIDTH-1:0]      = targetBID         [ID_WIDTH-1:0]      ;
    assign  initiatorBRESP    [1:0]               = targetBRESP       [1:0]               ;
    assign  initiatorBUSER    [USER_WIDTH-1:0]    = targetBUSER       [USER_WIDTH-1:0]    ;
    assign  initiatorBVALID   [0]                 = targetBVALID      [0]                 ;
    assign  initiatorARREADY  [0]                 = targetARREADY     [0]                 ;
    assign  initiatorRID      [ID_WIDTH-1:0]      = targetRID         [ID_WIDTH-1:0]      ;
    assign  initiatorRDATA    [CB_DWIDTH-1:0]     = targetRDATA       [CB_DWIDTH-1:0]     ;
    assign  initiatorRRESP    [1:0]               = targetRRESP       [1:0]               ;
    assign  initiatorRLAST    [0]                 = targetRLAST       [0]                 ;
    assign  initiatorRUSER    [USER_WIDTH-1:0]    = targetRUSER       [USER_WIDTH-1:0]    ;
    assign  initiatorRVALID   [0]                 = targetRVALID      [0]                 ;
  end 
endgenerate
   
  //===============================================================================================================================
  genvar intr;
  generate
  for (intr=0; intr<NUM_INITIATORS; intr=intr+1) begin : IntrConvertor_loop
    caxi4interconnect_InitiatorConvertor #
          (
            .DEF_BURST_LEN                 ( INITIATOR_DEF_BURST_LEN[(intr+1)*8-1:intr*8]               ),
            .DWC_DATA_FIFO_DEPTH           ( INITIATOR_DWC_DATA_FIFO_DEPTH[(intr+1)*14-1:intr*14]       ),
            .DWC_ADDR_FIFO_DEPTH           ( DWC_ADDR_FIFO_DEPTH                                        ),
            .INITIATOR_TYPE                ( INITIATOR_TYPE [(intr+1)*2-1:intr*2]                       ),   // Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b10
            .INITIATOR_NUMBER              ( intr                                                       ),          // initiator number
            .AWCHAN_RS                     ( INITIATOR_AWCHAN_RS[intr]                                  ),  // 0 means no slice on channel - 1 means full slice on channel
            .ARCHAN_RS                     ( INITIATOR_ARCHAN_RS[intr]                                  ),  // 0 means no slice on channel - 1 means full slice on channel
            .RCHAN_RS                      ( INITIATOR_RCHAN_RS[intr]                                   ),    // 0 means no slice on channel - 1 means full slice on channel
            .WCHAN_RS                      ( INITIATOR_WCHAN_RS[intr]                                   ),    // 0 means no slice on channel - 1 means full slice on channel
            .BCHAN_RS                      ( INITIATOR_BCHAN_RS[intr]                                   ),    // 0 means no slice on channel - 1 means full slice on channel
            .DWC_CHAN_RS                   ( INITIATOR_DWC_CHAN_RS[intr]                                ), 
			.MAX_TRANS                     ( MAX_TRANS                                                  ),
            .ID_WIDTH                      ( ID_WIDTH                                                   ), 
            .ADDR_WIDTH                    ( ADDR_WIDTH                                                 ),
            .DATA_WIDTH                    ( CB_DWIDTH                                                  ), 
            .INITIATOR_DATA_WIDTH          ( INITIATOR_PORTS_DATA_WIDTH[(intr+1)*32-1:intr*32]          ),
	        .AHB_BRESP_CHECK_MODE          ( AHB_INITIATOR_PORTS_BRESP_CHECK_MODE[2*(intr+1)-1:2*intr]  ),
	        .AHB_BRESP_CNT_WIDTH           ( AHB_INITIATOR_PORTS_BRESP_CNT_WIDTH[32*(intr+1)-1:32*intr] ),
            .SUPPORT_USER_SIGNALS          ( SUPPORT_USER_SIGNALS                                       ),
            .USER_WIDTH                    ( USER_WIDTH                                                 ),
            .CLOCK_DOMAIN_CROSSING         ( I_CDC[intr]                                                ),
            .CDC_PLACEMENT                 ( I_CDC_PLACEMENT[intr]                                      ),
            .CDC_FIFO_DEPTH                ( I_CDC_FIFO_DEPTH[(intr+1)*32-1:intr*32]                    ),
            .CDC_ADDR_RESP_FIFO_DEPTH      ( I_CDC_ADDR_RESP_FIFO_DEPTH[(intr+1)*32-1:intr*32]          ),
			.READ_INTERLEAVE               ( INITIATOR_READ_INTERLEAVE[intr]                            ),
			.PIPE                          ( PIPE                                                       ),
            .CDC_RAM_TYPE                  ( CDC_RAM_TYPE                                               ),			  
            .DWC_RAM_TYPE                  ( DWC_RAM_TYPE                                               ),			  			
			.SYNC_RESET                    ( SYNC_RESET                                                 ),
			.NUM_STAGES                    ( NUM_STAGES                                                 ),
			.NUM_RS_STAGES                 ( NUM_RS_STAGES_INITR[intr*4 +: 4]                           ),
            .FAMILY                        ( FAMILY                                                     ),
            .EXPOSE_RST                    ( EXPOSE_RST                                                 )
          )
      initrconv (
            // Global Signals
            .INITR_CLK                ( I_CLK[intr]                                                                                      ),
            .XBAR_CLK                 ( (BYPASS_CROSSBAR == 0 ) ? ACLK : T_CLK0                                                          ),
            .ARESETN                  ( ARESETN                                                                                          ),        // active low reset synchronoise to RE AClk - asserted async.
			.arst_sync                ( arst_sync                                                                                        ),
			.srst_sync                ( srst_sync                                                                                        ),
            .i_sync_rstn              ( i_sync_rstn[intr]                                                                                ),        
            // INITIATOR Read Address Ports
            .INITIATOR_ARID           ( INITIATOR_ARID[(intr+1)*ID_WIDTH-1:intr*ID_WIDTH]                                                ),
            .INITIATOR_ARADDR         ( INITIATOR_ARADDR[(intr+1)*ADDR_WIDTH-1:intr*ADDR_WIDTH]                                          ),
            .INITIATOR_ARLEN          ( INITIATOR_ARLEN[(intr+1)*8-1:intr*8]                                                             ),
            .INITIATOR_ARSIZE         ( INITIATOR_ARSIZE[(intr+1)*3-1:intr*3]                                                            ),
            .INITIATOR_ARBURST        ( INITIATOR_ARBURST[(intr+1)*2-1:intr*2]                                                           ),
            .INITIATOR_ARLOCK         ( INITIATOR_ARLOCK[(intr+1)*2-1:intr*2]                                                            ),
            .INITIATOR_ARCACHE        ( INITIATOR_ARCACHE[(intr+1)*4-1:intr*4]                                                           ),
            .INITIATOR_ARPROT         ( INITIATOR_ARPROT[(intr+1)*3-1:intr*3]                                                            ),
            .INITIATOR_ARREGION       ( INITIATOR_ARREGION[(intr+1)*4-1:intr*4]                                                          ),
            .INITIATOR_ARQOS          ( INITIATOR_ARQOS[(intr+1)*4-1:intr*4]                                                             ),
            .INITIATOR_ARUSER         ( INITIATOR_ARUSER[(intr+1)*USER_WIDTH-1:intr*USER_WIDTH]                                          ),
            .INITIATOR_ARVALID        ( INITIATOR_ARVALID[intr]                                                                          ),
            .INITIATOR_AWQOS          ( INITIATOR_AWQOS[(intr+1)*4-1:intr*4]                                                             ),
            .INITIATOR_AWREGION       ( INITIATOR_AWREGION[(intr+1)*4-1:intr*4]                                                          ),
            .INITIATOR_AWID           ( INITIATOR_AWID[(intr+1)*ID_WIDTH-1:intr*ID_WIDTH]                                                ),
            .INITIATOR_AWADDR         ( INITIATOR_AWADDR[(intr+1)*ADDR_WIDTH-1:intr*ADDR_WIDTH]                                          ),
            .INITIATOR_AWLEN          ( INITIATOR_AWLEN[(intr+1)*8-1:intr*8]                                                             ),
            .INITIATOR_AWSIZE         ( INITIATOR_AWSIZE[(intr+1)*3-1:intr*3]                                                            ),
            .INITIATOR_AWBURST        ( INITIATOR_AWBURST[(intr+1)*2-1:intr*2]                                                           ),
            .INITIATOR_AWLOCK         ( INITIATOR_AWLOCK[(intr+1)*2-1:intr*2]                                                            ),
            .INITIATOR_AWCACHE        ( INITIATOR_AWCACHE[(intr+1)*4-1:intr*4]                                                           ),
            .INITIATOR_AWPROT         ( INITIATOR_AWPROT[(intr+1)*3-1:intr*3]                                                            ),
            .INITIATOR_AWUSER         ( INITIATOR_AWUSER[(intr+1)*USER_WIDTH-1:intr*USER_WIDTH]                                          ),
            .INITIATOR_AWVALID        ( INITIATOR_AWVALID[intr]                                                                          ),
            .INITIATOR_WID            ( INITIATOR_WID[(intr+1)*ID_WIDTH-1:intr*ID_WIDTH]                                                 ),
            .INITIATOR_WDATA          ( INITIATOR_WDATA[MDW_UPPER_VEC[(1+intr)*13-1:13*intr]-1:MDW_LOWER_VEC[(1+intr)*13-1:13*intr]]     ),
            .INITIATOR_WSTRB          ( INITIATOR_WSTRB[MDW_UPPER_VEC[(1+intr)*13-1:13*intr]/8-1:MDW_LOWER_VEC[(1+intr)*13-1:13*intr]/8] ),
            .INITIATOR_WLAST          ( INITIATOR_WLAST[intr]                                                                            ),
            .INITIATOR_WUSER          ( INITIATOR_WUSER[(intr+1)*USER_WIDTH-1:intr*USER_WIDTH]                                           ),
            .INITIATOR_WVALID         ( INITIATOR_WVALID[intr]                                                                           ),
            .INITIATOR_BREADY         ( INITIATOR_BREADY[intr]                                                                           ),
            .INITIATOR_RREADY         ( INITIATOR_RREADY[intr]                                                                           ),
            .INITIATOR_ARREADY        ( INITIATOR_ARREADY[intr]                                                                          ),
            .INITIATOR_RID            ( INITIATOR_RID[(intr+1)*ID_WIDTH-1:intr*ID_WIDTH]                                                 ),
            .INITIATOR_RDATA          ( INITIATOR_RDATA[MDW_UPPER_VEC[(1+intr)*13-1:13*intr]-1:MDW_LOWER_VEC[(1+intr)*13-1:13*intr]]     ),
            .INITIATOR_RRESP          ( INITIATOR_RRESP[(intr+1)*2-1:intr*2]                                                             ),
            .INITIATOR_RUSER          ( INITIATOR_RUSER[(intr+1)*USER_WIDTH-1:intr*USER_WIDTH]                                           ),
            .INITIATOR_BID            ( INITIATOR_BID[(intr+1)*ID_WIDTH-1:intr*ID_WIDTH]                                                 ),
            .INITIATOR_BRESP          ( INITIATOR_BRESP[(intr+1)*2-1:intr*2]                                                             ),
            .INITIATOR_BUSER          ( INITIATOR_BUSER[(intr+1)*USER_WIDTH-1:intr*USER_WIDTH]                                           ),
            .INITIATOR_RLAST          ( INITIATOR_RLAST[intr]                                                                            ),
            .INITIATOR_RVALID         ( INITIATOR_RVALID[intr]                                                                           ),
            .INITIATOR_AWREADY        ( INITIATOR_AWREADY[intr]                                                                          ),
            .INITIATOR_WREADY         ( INITIATOR_WREADY[intr]                                                                           ),
            .INITIATOR_BVALID         ( INITIATOR_BVALID[intr]                                                                           ),

            .INITIATOR_HADDR          ( INITIATOR_HADDR[(intr+1)*32-1:intr*32]                                                           ),
            .INITIATOR_HBURST         ( INITIATOR_HBURST[(intr+1)*3-1:intr*3]                                                            ),
            .INITIATOR_HMASTLOCK      ( INITIATOR_HMASTLOCK[intr]                                                                        ),
            .INITIATOR_HPROT          ( INITIATOR_HPROT[(intr+1)*7-1:intr*7]                                                             ),          
            .INITIATOR_HSIZE          ( INITIATOR_HSIZE[(intr+1)*3-1:intr*3]                                                             ),
            .INITIATOR_HNONSEC        ( INITIATOR_HNONSEC[intr]                                                                          ),
            .INITIATOR_HTRANS         ( INITIATOR_HTRANS[(intr+1)*2-1:intr*2]                                                            ),
            .INITIATOR_HWDATA         ( INITIATOR_HWDATA[MDW_UPPER_VEC[(1+intr)*13-1:13*intr]-1:MDW_LOWER_VEC[(1+intr)*13-1:13*intr]]    ),
            .INITIATOR_HRDATA         ( INITIATOR_HRDATA[MDW_UPPER_VEC[(1+intr)*13-1:13*intr]-1:MDW_LOWER_VEC[(1+intr)*13-1:13*intr]]    ),
            .INITIATOR_HWRITE         ( INITIATOR_HWRITE[intr]                                                                           ),
            .INITIATOR_HREADY         ( INITIATOR_HREADY[intr]                                                                           ),
            .INITIATOR_HRESP          ( INITIATOR_HRESP[intr]                                                                            ),
            .INITIATOR_HSEL           ( INITIATOR_HSEL[intr]                                                                             ),

            .int_initiatorARID        ( initiatorARID[(intr+1)*ID_WIDTH-1:intr*ID_WIDTH]                                                 ),
            .int_initiatorARADDR      ( initiatorARADDR[(intr+1)*ADDR_WIDTH-1:intr*ADDR_WIDTH]                                           ),
            .int_initiatorARLEN       ( initiatorARLEN[(intr+1)*8-1:intr*8]                                                              ),
            .int_initiatorARSIZE      ( initiatorARSIZE[(intr+1)*3-1:intr*3]                                                             ),
            .int_initiatorARBURST     ( initiatorARBURST[(intr+1)*2-1:intr*2]                                                            ),
            .int_initiatorARLOCK      ( initiatorARLOCK[(intr+1)*2-1:intr*2]                                                             ),
            .int_initiatorARCACHE     ( initiatorARCACHE[(intr+1)*4-1:intr*4]                                                            ),
            .int_initiatorARPROT      ( initiatorARPROT[(intr+1)*3-1:intr*3 ]                                                            ),
            .int_initiatorARREGION    ( initiatorARREGION[(intr+1)*4-1:intr*4]                                                           ),
            .int_initiatorARQOS       ( initiatorARQOS[(intr+1)*4-1:intr*4]                                                              ),
            .int_initiatorARUSER      ( initiatorARUSER[(intr+1)*USER_WIDTH-1:intr*USER_WIDTH]                                           ),
            .int_initiatorARVALID     ( initiatorARVALID[intr]                                                                           ),
            .int_initiatorAWQOS       ( initiatorAWQOS[(intr+1)*4-1:intr*4]                                                              ),
            .int_initiatorAWREGION    ( initiatorAWREGION[(intr+1)*4-1:intr*4]                                                           ),
            .int_initiatorAWID        ( initiatorAWID[(intr+1)*ID_WIDTH-1:intr*ID_WIDTH]                                                 ),
            .int_initiatorAWADDR      ( initiatorAWADDR[(intr+1)*ADDR_WIDTH-1:intr*ADDR_WIDTH]                                           ),
            .int_initiatorAWLEN       ( initiatorAWLEN[(intr+1)*8-1:intr*8]                                                              ),
            .int_initiatorAWSIZE      ( initiatorAWSIZE[(intr+1)*3-1:intr*3]                                                             ),
            .int_initiatorAWBURST     ( initiatorAWBURST[(intr+1)*2-1:intr*2]                                                            ),
            .int_initiatorAWLOCK      ( initiatorAWLOCK[(intr+1)*2-1:intr*2]                                                             ),
            .int_initiatorAWCACHE     ( initiatorAWCACHE[(intr+1)*4-1:intr*4]                                                            ),
            .int_initiatorAWPROT      ( initiatorAWPROT[(intr+1)*3-1:intr*3]                                                             ),
            .int_initiatorAWUSER      ( initiatorAWUSER[(intr+1)*USER_WIDTH-1:intr*USER_WIDTH]                                           ),
            .int_initiatorAWVALID     ( initiatorAWVALID[intr]                                                                           ),
			.int_initiatorWID         ( initiatorWID[(intr+1)*ID_WIDTH-1:intr*ID_WIDTH]                                                  ),
            .int_initiatorWDATA       ( initiatorWDATA[(intr+1)*CB_DWIDTH-1:intr*CB_DWIDTH]                                            ),
            .int_initiatorWSTRB       ( initiatorWSTRB[(intr+1)*CB_DWIDTH/8-1:intr*CB_DWIDTH/8]                                        ),
            .int_initiatorWLAST       ( initiatorWLAST[intr]                                                                             ),
            .int_initiatorWUSER       ( initiatorWUSER[(intr+1)*USER_WIDTH-1:intr*USER_WIDTH]                                            ),
            .int_initiatorWVALID      ( initiatorWVALID[intr]                                                                            ),
            .int_initiatorBREADY      ( initiatorBREADY[intr]                                                                            ),
            .int_initiatorRREADY      ( initiatorRREADY[intr]                                                                            ),
            .int_initiatorARREADY     ( initiatorARREADY[intr]                                                                           ),
            .int_initiatorRID         ( initiatorRID[(intr+1)*ID_WIDTH-1:intr*ID_WIDTH]                                                  ),
            .int_initiatorRDATA       ( initiatorRDATA[(intr+1)*CB_DWIDTH-1:intr*CB_DWIDTH]                                            ),
            .int_initiatorRRESP       ( initiatorRRESP[(intr+1)*2-1:intr*2]                                                              ),
            .int_initiatorRUSER       ( initiatorRUSER[(intr+1)*USER_WIDTH-1:intr*USER_WIDTH]                                            ),
            .int_initiatorBID         ( initiatorBID[(intr+1)*ID_WIDTH-1:intr*ID_WIDTH]                                                  ),
            .int_initiatorBRESP       ( initiatorBRESP[(intr+1)*2-1:intr*2]                                                              ),
            .int_initiatorBUSER       ( initiatorBUSER[(intr+1)*USER_WIDTH-1:intr*USER_WIDTH]                                            ),
            .int_initiatorRLAST       ( initiatorRLAST[intr]                                                                             ),
            .int_initiatorRVALID      ( initiatorRVALID[intr]                                                                            ),
            .int_initiatorAWREADY     ( initiatorAWREADY[intr]                                                                           ),
            .int_initiatorWREADY      ( initiatorWREADY[intr]                                                                            ),
            .int_initiatorBVALID      ( initiatorBVALID[intr]                                                                            )

          );
          end // IntrConvertor_loop
  endgenerate   
  
   //===============================================================================================================================

  genvar trgt;
  generate
        for (trgt=0; trgt<NUM_TARGETS; trgt=trgt+1) begin : TrgtConvertor_loop
        caxi4interconnect_TargetConvertor #
         (
              .TARGET_TYPE                 ( TARGET_TYPE [(trgt+1)*2-1:trgt*2]                                                                  ),  // Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b10
              .DWC_DATA_FIFO_DEPTH         ( TARGET_DWC_DATA_FIFO_DEPTH[(trgt+1)*14-1:trgt*14]                                                  ),
              .DWC_ADDR_FIFO_DEPTH         ( DWC_ADDR_FIFO_DEPTH                                                                                ),
              .TARGET_NUMBER               ( trgt                                                                                               ),          // initiator number
              .AWCHAN_RS                   ( TARGET_AWCHAN_RS[trgt]                                                                             ),  // 0 means no slice on channel - 1 means full slice on channel
              .ARCHAN_RS                   ( TARGET_ARCHAN_RS[trgt]                                                                             ),  // 0 means no slice on channel - 1 means full slice on channel
              .RCHAN_RS                    ( TARGET_RCHAN_RS[trgt]                                                                              ),  // 0 means no slice on channel - 1 means full slice on channel
              .WCHAN_RS                    ( TARGET_WCHAN_RS[trgt]                                                                              ),  // 0 means no slice on channel - 1 means full slice on channel
              .BCHAN_RS                    ( TARGET_BCHAN_RS[trgt]                                                                              ),  // 0 means no slice on channel - 1 means full slice on channel  
              .DWC_CHAN_RS                 ( (BYPASS_CROSSBAR== 0) ? TARGET_DWC_CHAN_RS[trgt] : 1'b0                                            ),  // 0 means no slice on channel - 1 means full slice on channel  
              .ID_WIDTH                    ( NUM_INITIATORS_WIDTH_ADJ + ID_WIDTH                                                                ),    // includes infrastructure ID
              .ADDR_WIDTH                  ( ADDR_WIDTH                                                                                         ),        
              .DATA_WIDTH                  ( CB_DWIDTH                                                                                          ), 
              .TARGET_DATA_WIDTH           ( TARGET_PORTS_DATA_WIDTH[(trgt+1)*32-1:trgt*32]                                                     ),
              .READ_ZERO_TARGET_ID         ( TARGET_READ_ZERO_TARGET_ID[trgt] &  (TARGET_PORTS_DATA_WIDTH[(trgt+1)*32-1:trgt*32] == CB_DWIDTH)  ),
              .WRITE_ZERO_TARGET_ID        ( TARGET_WRITE_ZERO_TARGET_ID[trgt] & (TARGET_PORTS_DATA_WIDTH[(trgt+1)*32-1:trgt*32] == CB_DWIDTH)  ),
              .USER_WIDTH                  ( USER_WIDTH                                                                                         ),
              .TRGT_AXI4PRT_ADDRDEPTH      ( TRGT_AXI4PRT_ADDRDEPTH                                                                             ),  // Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
              .TRGT_AXI4PRT_DATADEPTH      ( TRGT_AXI4PRT_DATADEPTH                                                                             ),  // Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
              .CLOCK_DOMAIN_CROSSING       ( (BYPASS_CROSSBAR== 0) ? T_CDC[trgt] : 1'b0                                                         ),
              .CDC_PLACEMENT               ( T_CDC_PLACEMENT[trgt]                                                                              ),
              .CDC_FIFO_DEPTH              ( T_CDC_FIFO_DEPTH[(trgt+1)*32-1:trgt*32]                                                            ),
              .CDC_ADDR_RESP_FIFO_DEPTH    ( T_CDC_ADDR_RESP_FIFO_DEPTH[(trgt+1)*32-1:trgt*32]                                                  ),
			  .READ_INTERLEAVE             ( TARGET_READ_INTERLEAVE[trgt]                                                                       ),
			  .MAX_TRANS                   ( MAX_TRANS                                                                                          ),
              .PIPE                        ( PIPE                                                                                               ),			  
              .CDC_RAM_TYPE                ( CDC_RAM_TYPE                                                                                       ),			  
              .DWC_RAM_TYPE                ( DWC_RAM_TYPE                                                                                       ),			  
              .PROTOCONV_RAM_TYPE          ( PROTOCONV_RAM_TYPE                                                                                 ),			  
              .SYNC_RESET                  ( SYNC_RESET                                                                                         ),			  
              .NUM_STAGES                  ( NUM_STAGES                                                                                         ),			  
			  .NUM_RS_STAGES               ( NUM_RS_STAGES_TRGT[trgt*4 +: 4]                                                                    ),
              .FAMILY                      ( FAMILY                                                                                             ),
              .EXPOSE_RST                  ( EXPOSE_RST                                                                                         ),
              .BYPASS_CROSSBAR             ( BYPASS_CROSSBAR                                                                                    )
			  
          )
        trgtcnv (
              .TRGT_CLK           ( T_CLK[trgt]                                                                                          ),
              .XBAR_CLK           ( CB_CLK                                                                                               ),
              .ARESETN            ( ARESETN                                                                                              ),        // active low reset synchronoise to RE AClk - asserted async.
			  .arst_sync          ( arst_sync                                                                                            ),
			  .srst_sync          ( srst_sync                                                                                            ),
              .t_sync_rstn        ( t_sync_rstn[trgt]                                                                                    ),               

              .TARGET_AWID        ( TARGET_AWID[(trgt+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:trgt*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] ),  
              .TARGET_AWADDR      ( TARGET_AWADDR[(trgt+1)*ADDR_WIDTH-1:trgt*ADDR_WIDTH]                                                 ),  
              .TARGET_AWLEN       ( TARGET_AWLEN[(trgt+1)*8-1:trgt*8]                                                                    ),  
              .TARGET_AWSIZE      ( TARGET_AWSIZE[(trgt+1)*3-1:trgt*3]                                                                   ),  
              .TARGET_AWBURST     ( TARGET_AWBURST[(trgt+1)*2-1:trgt*2]                                                                  ),  
              .TARGET_AWLOCK      ( TARGET_AWLOCK[(trgt+1)*2-1:trgt*2]                                                                   ),  
              .TARGET_AWCACHE     ( TARGET_AWCACHE[(trgt+1)*4-1:trgt*4]                                                                  ),  
              .TARGET_AWPROT      ( TARGET_AWPROT[(trgt+1)*3-1:trgt*3]                                                                   ),  
              .TARGET_AWREGION    ( TARGET_AWREGION[(trgt+1)*4-1:trgt*4]                                                                 ),   
              .TARGET_AWQOS       ( TARGET_AWQOS[(trgt+1)*4-1:trgt*4]                                                                    ),  
              .TARGET_AWUSER      ( TARGET_AWUSER[(trgt+1)*USER_WIDTH-1:trgt*USER_WIDTH]                                                 ),  
              .TARGET_AWVALID     ( TARGET_AWVALID[trgt]                                                                                 ),
              .TARGET_WID         ( TARGET_WID[(trgt+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:trgt*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  ),
              .TARGET_WDATA       ( TARGET_WDATA[SDW_UPPER_VEC[(1+trgt)*13-1:13*trgt]-1:SDW_LOWER_VEC[(1+trgt)*13-1:13*trgt]]            ),  
              .TARGET_WSTRB       ( TARGET_WSTRB[SDW_UPPER_VEC[(1+trgt)*13-1:13*trgt]/8-1:SDW_LOWER_VEC[(1+trgt)*13-1:13*trgt]/8]        ),  
              .TARGET_WLAST       ( TARGET_WLAST[trgt]                                                                                   ),  
              .TARGET_WUSER       ( TARGET_WUSER[(trgt+1)*USER_WIDTH-1:trgt*USER_WIDTH]                                                  ),  
              .TARGET_WVALID      ( TARGET_WVALID[trgt]                                                                                  ),      
              .TARGET_BREADY      ( TARGET_BREADY[trgt]                                                                                  ),        
              .TARGET_ARID        ( TARGET_ARID[(trgt+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:trgt*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)] ),  
              .TARGET_ARADDR      ( TARGET_ARADDR[(trgt+1)*ADDR_WIDTH-1:trgt*ADDR_WIDTH]                                                 ),  
              .TARGET_ARLEN       ( TARGET_ARLEN[(trgt+1)*8-1:trgt*8]                                                                    ),  
              .TARGET_ARSIZE      ( TARGET_ARSIZE[(trgt+1)*3-1:trgt*3]                                                                   ),  
              .TARGET_ARBURST     ( TARGET_ARBURST[(trgt+1)*2-1:trgt*2]                                                                  ),  
              .TARGET_ARLOCK      ( TARGET_ARLOCK[(trgt+1)*2-1:trgt*2]                                                                   ),  
              .TARGET_ARCACHE     ( TARGET_ARCACHE[(trgt+1)*4-1:trgt*4]                                                                  ),  
              .TARGET_ARPROT      ( TARGET_ARPROT[(trgt+1)*3-1:trgt*3]                                                                   ),  
              .TARGET_ARREGION    ( TARGET_ARREGION[(trgt+1)*4-1:trgt*4]                                                                 ),   
              .TARGET_ARQOS       ( TARGET_ARQOS[(trgt+1)*4-1:trgt*4]                                                                    ),  
              .TARGET_ARUSER      ( TARGET_ARUSER[(trgt+1)*USER_WIDTH-1:trgt*USER_WIDTH]                                                 ),  
              .TARGET_ARVALID     ( TARGET_ARVALID[trgt]                                                                                 ),      
              .TARGET_RREADY      ( TARGET_RREADY[trgt]                                                                                  ),    
              .TARGET_AWREADY     ( TARGET_AWREADY[trgt]                                                                                 ),          
              .TARGET_WREADY      ( TARGET_WREADY[trgt]                                                                                  ),        
              .TARGET_BID         ( TARGET_BID[(trgt+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:trgt*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  ),  
              .TARGET_BRESP       ( TARGET_BRESP[(trgt+1)*2-1:trgt*2]                                                                    ),  
              .TARGET_BUSER       ( TARGET_BUSER[(trgt+1)*USER_WIDTH-1:trgt*USER_WIDTH]                                                  ),  
              .TARGET_BVALID      ( TARGET_BVALID[trgt]                                                                                  ),        
              .TARGET_ARREADY     ( TARGET_ARREADY[trgt]                                                                                 ),        
              .TARGET_RID         ( TARGET_RID[(trgt+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:trgt*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  ),  
              .TARGET_RDATA       ( TARGET_RDATA[SDW_UPPER_VEC[(1+trgt)*13-1:13*trgt]-1:SDW_LOWER_VEC[(1+trgt)*13-1:13*trgt]]            ),  // Input to this file
              .TARGET_RRESP       ( TARGET_RRESP[(trgt+1)*2-1:trgt*2]                                                                    ),  
              .TARGET_RLAST       ( TARGET_RLAST[trgt]                                                                                   ),  
              .TARGET_RUSER       ( TARGET_RUSER[(trgt+1)*USER_WIDTH-1:trgt*USER_WIDTH]                                                  ),  
              .TARGET_RVALID      ( TARGET_RVALID[trgt]                                                                                  ),

              .targetAWID         ( targetAWID[(trgt+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:trgt*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  ),  
              .targetAWADDR       ( targetAWADDR[(trgt+1)*ADDR_WIDTH-1:trgt*ADDR_WIDTH]                                                  ),  
              .targetAWLEN        ( targetAWLEN[(trgt+1)*8-1:trgt*8]                                                                     ),  
              .targetAWSIZE       ( targetAWSIZE[(trgt+1)*3-1:trgt*3]                                                                    ),  
              .targetAWBURST      ( targetAWBURST[(trgt+1)*2-1:trgt*2]                                                                   ),  
              .targetAWLOCK       ( targetAWLOCK[(trgt+1)*2-1:trgt*2]                                                                    ),  
              .targetAWCACHE      ( targetAWCACHE[(trgt+1)*4-1:trgt*4]                                                                   ),  
              .targetAWPROT       ( targetAWPROT[(trgt+1)*3-1:trgt*3]                                                                    ),  
              .targetAWREGION     ( targetAWREGION[(trgt+1)*4-1:trgt*4]                                                                  ),   
              .targetAWQOS        ( targetAWQOS[(trgt+1)*4-1:trgt*4]                                                                     ),  
              .targetAWUSER       ( targetAWUSER[(trgt+1)*USER_WIDTH-1:trgt*USER_WIDTH]                                                  ),  
              .targetAWVALID      ( targetAWVALID[trgt]                                                                                  ),      
              .targetWID          ( targetWID[(trgt+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:trgt*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   ), 
              .targetWDATA        ( targetWDATA[(trgt+1)*CB_DWIDTH-1:trgt*CB_DWIDTH]                                                   ),  
              .targetWSTRB        ( targetWSTRB[(trgt+1)*CB_DWIDTH/8-1:trgt*CB_DWIDTH/8]                                               ),  
              .targetWLAST        ( targetWLAST[trgt]                                                                                    ),  
              .targetWUSER        ( targetWUSER[(trgt+1)*USER_WIDTH-1:trgt*USER_WIDTH]                                                   ),  
              .targetWVALID       ( targetWVALID[trgt]                                                                                   ),      
              .targetBREADY       ( targetBREADY[trgt]                                                                                   ),        
              .targetARID         ( targetARID[(trgt+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:trgt*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]  ),  
              .targetARADDR       ( targetARADDR[(trgt+1)*ADDR_WIDTH-1:trgt*ADDR_WIDTH]                                                  ),  
              .targetARLEN        ( targetARLEN[(trgt+1)*8-1:trgt*8]                                                                     ),  
              .targetARSIZE       ( targetARSIZE[(trgt+1)*3-1:trgt*3]                                                                    ),  
              .targetARBURST      ( targetARBURST[(trgt+1)*2-1:trgt*2]                                                                   ),  
              .targetARLOCK       ( targetARLOCK[(trgt+1)*2-1:trgt*2]                                                                    ),  
              .targetARCACHE      ( targetARCACHE[(trgt+1)*4-1:trgt*4]                                                                   ),  
              .targetARPROT       ( targetARPROT[(trgt+1)*3-1:trgt*3]                                                                    ),  
              .targetARREGION     ( targetARREGION[(trgt+1)*4-1:trgt*4]                                                                  ),   
              .targetARQOS        ( targetARQOS[(trgt+1)*4-1:trgt*4]                                                                     ),  
              .targetARUSER       ( targetARUSER[(trgt+1)*USER_WIDTH-1:trgt*USER_WIDTH]                                                  ),  
              .targetARVALID      ( targetARVALID[trgt]                                                                                  ),      
              .targetRREADY       ( targetRREADY[trgt]                                                                                   ),        
              .targetAWREADY      ( targetAWREADY[trgt]                                                                                  ),          
              .targetWREADY       ( targetWREADY[trgt]                                                                                   ),        
              .targetBID          ( targetBID[(trgt+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:trgt*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   ),  
              .targetBRESP        ( targetBRESP[(trgt+1)*2-1:trgt*2]                                                                     ),  
              .targetBUSER        ( targetBUSER[(trgt+1)*USER_WIDTH-1:trgt*USER_WIDTH]                                                   ),  
              .targetBVALID       ( targetBVALID[trgt]                                                                                   ),        
              .targetARREADY      ( targetARREADY[trgt]                                                                                  ),        
              .targetRID          ( targetRID[(trgt+1)*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)-1:trgt*(NUM_INITIATORS_WIDTH_ADJ+ID_WIDTH)]   ),  
              .targetRDATA        ( targetRDATA[(trgt+1)*CB_DWIDTH-1:trgt*CB_DWIDTH]                                                   ),  // Output from this module, input to this file
              .targetRRESP        ( targetRRESP[(trgt+1)*2-1:trgt*2]                                                                     ),  
              .targetRLAST        ( targetRLAST[trgt]                                                                                    ),  
              .targetRUSER        ( targetRUSER[(trgt+1)*USER_WIDTH-1:trgt*USER_WIDTH]                                                   ),  
              .targetRVALID       ( targetRVALID[trgt]                                                                                   )
            ); 
    end //TrgtConvertor_loop
  endgenerate     
  
  //synthesis translate_off  
  
    reg [31:0] intr_aw_txn_cnt [NUM_INITIATORS-1:0]    /* synthesis syn_preserve = 1*/;
    reg [31:0] intr_w_txn_cnt  [NUM_INITIATORS-1:0]    /* synthesis syn_preserve = 1*/;
    reg [31:0] intr_b_txn_cnt  [NUM_INITIATORS-1:0]    /* synthesis syn_preserve = 1*/;
    reg [31:0] intr_ar_txn_cnt [NUM_INITIATORS-1:0]    /* synthesis syn_preserve = 1*/;
    reg [31:0] intr_r_txn_cnt  [NUM_INITIATORS-1:0]    /* synthesis syn_preserve = 1*/;
    
    reg [31:0] trgt_aw_txn_cnt [NUM_TARGETS-1:0]   /* synthesis syn_preserve = 1*/;
    reg [31:0] trgt_w_txn_cnt  [NUM_TARGETS-1:0]   /* synthesis syn_preserve = 1*/;
    reg [31:0] trgt_b_txn_cnt  [NUM_TARGETS-1:0]   /* synthesis syn_preserve = 1*/;
    reg [31:0] trgt_ar_txn_cnt [NUM_TARGETS-1:0]   /* synthesis syn_preserve = 1*/;
    reg [31:0] trgt_r_txn_cnt  [NUM_TARGETS-1:0]   /* synthesis syn_preserve = 1*/;
  
    genvar i_cnt,t_cnt;
    generate
      for(i_cnt=0; i_cnt<NUM_INITIATORS; i_cnt=i_cnt+1) begin	
        always @(posedge I_CLK[i_cnt] or negedge ARESETN) begin
          if (!ARESETN) begin
            intr_aw_txn_cnt[i_cnt] <= 32'd0;
            intr_w_txn_cnt[i_cnt]  <= 32'd0;
            intr_b_txn_cnt[i_cnt]  <= 32'd0;
            intr_ar_txn_cnt[i_cnt] <= 32'd0;
            intr_r_txn_cnt[i_cnt]  <= 32'd0;            
          end else begin
            if (INITIATOR_AWVALID[i_cnt] & INITIATOR_AWREADY[i_cnt])
                intr_aw_txn_cnt[i_cnt] <= intr_aw_txn_cnt[i_cnt] + 1;
            if (INITIATOR_WVALID[i_cnt] & INITIATOR_WREADY[i_cnt] & (INITIATOR_WLAST[i_cnt] | 
			    INITIATOR_TYPE[(i_cnt+1)*2-1:i_cnt*2] == 2'b01))
                intr_w_txn_cnt[i_cnt] <= intr_w_txn_cnt[i_cnt] + 1;
            if (INITIATOR_BVALID[i_cnt] & INITIATOR_BREADY[i_cnt])
                intr_b_txn_cnt[i_cnt] <= intr_b_txn_cnt[i_cnt] + 1;
            if (INITIATOR_ARVALID[i_cnt] & INITIATOR_ARREADY[i_cnt])
                intr_ar_txn_cnt[i_cnt] <= intr_ar_txn_cnt[i_cnt] + 1;
            if (INITIATOR_RVALID[i_cnt] & INITIATOR_RREADY[i_cnt] & (INITIATOR_RLAST[i_cnt] | 
			    INITIATOR_TYPE[(i_cnt+1)*2-1:i_cnt*2] == 2'b01))
                intr_r_txn_cnt[i_cnt] <= intr_r_txn_cnt[i_cnt] + 1;
          end				
        end
      end  
	  
      for(t_cnt=0; t_cnt<NUM_TARGETS; t_cnt=t_cnt+1) begin	
        always @(posedge T_CLK[t_cnt] or negedge ARESETN) begin
          if (!ARESETN) begin
            trgt_aw_txn_cnt[t_cnt] <= 32'd0;
            trgt_w_txn_cnt[t_cnt]  <= 32'd0;
            trgt_b_txn_cnt[t_cnt]  <= 32'd0;
            trgt_ar_txn_cnt[t_cnt] <= 32'd0;
            trgt_r_txn_cnt[t_cnt]  <= 32'd0;            
          end else begin
            if (TARGET_AWVALID[t_cnt] & TARGET_AWREADY[t_cnt])
                trgt_aw_txn_cnt[t_cnt] <= trgt_aw_txn_cnt[t_cnt] + 1;
            if (TARGET_WVALID[t_cnt] & TARGET_WREADY[t_cnt] & (TARGET_WLAST[t_cnt] | 
			    TARGET_TYPE[(t_cnt+1)*2-1:t_cnt*2] == 2'b01))
                trgt_w_txn_cnt[t_cnt] <= trgt_w_txn_cnt[t_cnt] + 1;
            if (TARGET_BVALID[t_cnt] & TARGET_BREADY[t_cnt])
                trgt_b_txn_cnt[t_cnt] <= trgt_b_txn_cnt[t_cnt] + 1;
            if (TARGET_ARVALID[t_cnt] & TARGET_ARREADY[t_cnt])
                trgt_ar_txn_cnt[t_cnt] <= trgt_ar_txn_cnt[t_cnt] + 1;
            if (TARGET_RVALID[t_cnt] & TARGET_RREADY[t_cnt] & (TARGET_RLAST[t_cnt] | 
			    TARGET_TYPE[(t_cnt+1)*2-1:t_cnt*2] == 2'b01))
                trgt_r_txn_cnt[t_cnt] <= trgt_r_txn_cnt[t_cnt] + 1;
          end				
        end
      end  

	endgenerate
	
	//synthesis translate_on
endmodule  // COREAXI4INTERCONNECT.v
