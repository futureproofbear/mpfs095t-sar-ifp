// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 44143 $
// SVN $Date: 2023-09-21 20:36:05 +0530 (Thu, 21 Sep 2023) $
//
// IP Core : CoreAXI4SInterconnect
//
// Module  : COREAXI4S_FIFO
//
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP , COREAXI4S_FIFO is a configurable Soft FIFO controller with AXI4 Stream Interface.
// Notes    :
// ******************************************************************************************************/


`timescale 1ns / 1ns

module caxi4c_coreaxi4s_fifo #
(
   parameter                RESET_TYPE       = 0,   //
   parameter                SYNC             = 1,   // Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
   parameter                PIPE             = 1,   // 1: Address pipeline 2: address and data pipeline 
   parameter                ECC              = 0,   // 0: ECC disable , 1: ECC enable


   parameter                RAM_TYPE         = 0,   // 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the Tool 0 - Fabric Register 
   parameter                NUM_STAGES       = 2,   // To select number of synchronizer stages.
   parameter                READ_MODE        = 0,   // 0: flow through mode  1: wait for tlast


   parameter                WFIFO_DEPTH       = 32,
   parameter                RFIFO_DEPTH       = 32,
   parameter                AXIS_TTDATA_WIDTH = 64,  // Bytes
   parameter                AXIS_ITDATA_WIDTH = 128,  // Bytes
   parameter                AXIS_TTID_WIDTH   = 32,  // Bits
   parameter                AXIS_ITID_WIDTH   = 32,  // Bits
   parameter                AXIS_TTDEST_WIDTH = 32,  // Bits
   parameter                AXIS_ITDEST_WIDTH = 32,  // Bits
   parameter                AXIS_TTUSER_WIDTH = 256, // Bits
   parameter                AXIS_ITUSER_WIDTH = 256, // Bits


   parameter                ENABLE_AFULL     = 0,
   parameter                ENABLE_AEMPTY    = 0,
   parameter                AFULL_THR        = 32,
   parameter                AEMPTY_THR       = 1,
   parameter                ENABLE_TSTRB     = 0,
   parameter                ENABLE_TKEEP     = 0,
   parameter                ENABLE_TLAST     = 0,
   parameter                ENABLE_TUSER     = 0,
   parameter                ENABLE_TDEST     = 0,
   parameter                ENABLE_TID       = 0, 
   
   parameter                EOP_OFFSET       = 8

)(
      // --------------------------------------------------------------------------
   // I/O Declaration
   // --------------------------------------------------------------------------
   // AXI4 Stream Interface
   // ----------------------------------------
   // Inputs
   // ----------------------------------------
   // Clocks and Reset
   input                                AXI4S_ACLK,
   input                                AXI4S_IACLK,
   input                                AXI4S_TACLK,
   input                                AXI4S_ARESETN,
   input                                AXI4S_IARESETN,
   input                                AXI4S_TARESETN,
   //AXI4_S Initiator Port Interface Signals
   input                                AXI4S_ITREADY,
   output                               AXI4S_ITVALID,
   output [AXIS_ITDATA_WIDTH-1: 0]      AXI4S_ITDATA,

   //AXI4_S Target Port Interface Signals
   input                                AXI4S_TTVALID,
   input [AXIS_TTDATA_WIDTH - 1 : 0]    AXI4S_TTDATA,
   output                               AXI4S_TTREADY,

   //input [$clog2(WFIFO_AFULL_THR)-1:0]      AFULL_IN,
   output                               ALMOST_FULL,
   output                               ALMOST_EMPTY
);
   // --------------------------------------------------------------------------
   // Local PARAMETER Declaration
   // --------------------------------------------------------------------------
   //

   localparam   WWIDTH_CORE_LAST     = (ENABLE_TLAST == 0) ? (AXIS_TTDATA_WIDTH)    : (AXIS_TTDATA_WIDTH)+1;
   localparam   WWIDTH_CORE_USER     = (ENABLE_TUSER == 0) ? (WWIDTH_CORE_LAST)     : (WWIDTH_CORE_LAST+AXIS_TTUSER_WIDTH);
   localparam   WWIDTH_CORE_DEST     = (ENABLE_TDEST == 0) ? (WWIDTH_CORE_USER)     : (WWIDTH_CORE_USER+AXIS_TTDEST_WIDTH);
   localparam   WWIDTH_CORE_TID      = (ENABLE_TID   == 0) ? (WWIDTH_CORE_DEST)     : (WWIDTH_CORE_DEST+AXIS_TTID_WIDTH);
   localparam   WWIDTH_CORE_TKEEP    = (ENABLE_TKEEP == 0) ? (WWIDTH_CORE_TID)      : (WWIDTH_CORE_TID+(AXIS_TTDATA_WIDTH/8));
   localparam   WWIDTH_CORE_TSTRB    = (ENABLE_TSTRB == 0) ? (WWIDTH_CORE_TKEEP)    : (WWIDTH_CORE_TKEEP+(AXIS_TTDATA_WIDTH/8));


   localparam   RWIDTH_CORE_LAST     = (ENABLE_TLAST == 0) ? (AXIS_ITDATA_WIDTH)    : (AXIS_ITDATA_WIDTH)+1;
   localparam   RWIDTH_CORE_USER     = (ENABLE_TUSER == 0) ? (RWIDTH_CORE_LAST)     : (RWIDTH_CORE_LAST+(AXIS_ITUSER_WIDTH));
   localparam   RWIDTH_CORE_DEST     = (ENABLE_TDEST == 0) ? (RWIDTH_CORE_USER)     : (RWIDTH_CORE_USER+(AXIS_ITDEST_WIDTH));
   localparam   RWIDTH_CORE_TID      = (ENABLE_TID   == 0) ? (RWIDTH_CORE_DEST)     : (RWIDTH_CORE_DEST+(AXIS_ITID_WIDTH));
   localparam   RWIDTH_CORE_TKEEP    = (ENABLE_TKEEP == 0) ? (RWIDTH_CORE_TID)      : (RWIDTH_CORE_TID+(AXIS_ITDATA_WIDTH/8));
   localparam   RWIDTH_CORE_TSTRB    = (ENABLE_TSTRB == 0) ? (RWIDTH_CORE_TKEEP)    : (RWIDTH_CORE_TKEEP+(AXIS_ITDATA_WIDTH/8));


   localparam   FIFO_WDATA_WIDTH     = WWIDTH_CORE_TSTRB;
   localparam   FIFO_RDATA_WIDTH     = RWIDTH_CORE_TSTRB;



   // Output Status Flags

   // --------------------------------------------------------------------------
   // Internal signals
   // --------------------------------------------------------------------------

   wire                              full_s;
   wire                              empty_s;
   wire                              wr_en_s;
   wire                              rd_en_s;

   wire [FIFO_RDATA_WIDTH -1 :0]     rd_data_axi4s_s;
   wire [FIFO_WDATA_WIDTH -1 :0]     wr_data_axi4s_s;


generate 
  if(WFIFO_DEPTH > 1) begin  
    caxi4c_corefifo
    #(
     .FAMILY         (27               ),
     .SYNC           (SYNC             ),
     .RWIDTH         (FIFO_RDATA_WIDTH ),
     .WWIDTH         (FIFO_WDATA_WIDTH ),
     .RDEPTH         (RFIFO_DEPTH      ),
     .WDEPTH         (WFIFO_DEPTH      ),
     .WRITE_ACK      (1'b0             ),
     .READ_DVALID    (1'b0             ),
     .CTRL_TYPE      (RAM_TYPE         ),
     .AE_STATIC_EN   (ENABLE_AEMPTY    ),
     .AF_STATIC_EN   (ENABLE_AFULL     ),
     .AF_DYN_EN      (1'b0             ),
     .AEVAL          (AEMPTY_THR       ),
     .AFVAL          (AFULL_THR        ),
     .PIPE           (PIPE             ),
     .PREFETCH       (1'b0             ),
     .FWFT           (1'b0             ),
     .ECC            (ECC              ),
     .NUM_STAGES     (NUM_STAGES       ),
     .SYNC_RESET     (RESET_TYPE       )
    )
    u_caxi4c_corefifo(
     .CLK        (AXI4S_ACLK      ),
     .WCLOCK     (AXI4S_TACLK     ),
     .RCLOCK     (AXI4S_IACLK     ),
     .RESET_N    (AXI4S_ARESETN   ),
     .WRESET_N   (AXI4S_TARESETN  ),
     .RRESET_N   (AXI4S_IARESETN  ),
     .DATA       (wr_data_axi4s_s ),
     .WE         (wr_en_s         ),
     .RE         (rd_en_s         ),
     .Q          (rd_data_axi4s_s ),
     .FULL       (full_s          ),
     .EMPTY      (empty_s         ),
     .AFULL      (ALMOST_FULL     ),
     .AEMPTY     (ALMOST_EMPTY    )
    );

    caxi4c_corefifo_axi4s_if # 
    (
       .SYNC                   (SYNC               ),
       .READ_MODE              (READ_MODE          ),
       .PIPE                   (PIPE               ),
       .ECC                    (ECC                ),
       .RESET_TYPE             (RESET_TYPE         ),
       .NUM_STAGES             (NUM_STAGES         ),
       .AXIS_TTDATA_WIDTH      (AXIS_TTDATA_WIDTH  ),
       .AXIS_ITDATA_WIDTH      (AXIS_ITDATA_WIDTH  ),
       .AXIS_TTID_WIDTH        (AXIS_TTID_WIDTH    ),
       .AXIS_ITID_WIDTH        (AXIS_ITID_WIDTH    ),
       .AXIS_TTDEST_WIDTH      (AXIS_TTDEST_WIDTH  ),
       .AXIS_ITDEST_WIDTH      (AXIS_ITDEST_WIDTH  ),
       .AXIS_TTUSER_WIDTH      (AXIS_TTUSER_WIDTH  ),
       .AXIS_ITUSER_WIDTH      (AXIS_ITUSER_WIDTH  ),
       .WWIDTH_CORE            (FIFO_WDATA_WIDTH   ),
       .RWIDTH_CORE            (FIFO_RDATA_WIDTH   ),
    
       .ENABLE_TSTRB           (ENABLE_TSTRB       ),
       .ENABLE_TKEEP           (ENABLE_TKEEP       ),
       .ENABLE_TLAST           (ENABLE_TLAST       ),
       .ENABLE_TUSER           (ENABLE_TUSER       ),
       .ENABLE_TDEST           (ENABLE_TDEST       ),
       .ENABLE_TID             (ENABLE_TID         )
    ) u_caxi4c_corefifo_axi4s_if 
	(
      .M_AXIS_ACLK_i         (AXI4S_IACLK    ),
      .S_AXIS_ACLK_i         (AXI4S_TACLK    ),
      .M_AXIS_ARESETN_i      (AXI4S_IARESETN ),
      .S_AXIS_ARESETN_i      (AXI4S_TARESETN ),
      //Initiator Port Interface Signals
      .M_AXIS_TVALID_o       (AXI4S_ITVALID  ),
      .M_AXIS_TREADY_i       (AXI4S_ITREADY  ),
      .M_AXIS_TDATA_o        (AXI4S_ITDATA   ),
      //Target Port Interface Signals
      .S_AXIS_TVALID_i       (AXI4S_TTVALID  ),
      .S_AXIS_TREADY_o       (AXI4S_TTREADY  ),
      .S_AXIS_TDATA_i        (AXI4S_TTDATA   ),
      .FIFO_WR_DATA_AXI4_S_o (wr_data_axi4s_s),
      .FIFO_RD_DATA_AXI4_S_i (rd_data_axi4s_s),
      .FIFO_WE_EN_AXI4_S_o   (wr_en_s        ),
      .FIFO_RE_EN_AXI4_S_o   (rd_en_s        ),
      .FIFO_FULL_i           (full_s         ),
      .FIFO_EMPTY_i          (empty_s        )
    );
  end else begin 
    caxi4c_async_1deep_fwft_fifo #
    (
      .DWIDTH          (FIFO_WDATA_WIDTH ),
      .NUM_SYNC_STAGES (NUM_STAGES       ),
      .RESET_TYPE      (RESET_TYPE       )
    ) u_caxi4c_corefifo            
    (	      
      .wclk            (AXI4S_TACLK      ), 
      .wrst_n          (AXI4S_TARESETN   ), 
      .wdata           (AXI4S_TTDATA     ),
      .wready          (AXI4S_TTREADY    ),
      .wvalid          (AXI4S_TTVALID    ),
      .rclk            (AXI4S_IACLK      ),
      .rrst_n          (AXI4S_IARESETN   ),
      .rdata           (AXI4S_ITDATA     ),
      .rvalid          (AXI4S_ITVALID    ),
      .rready          (AXI4S_ITREADY    )
    );  
  end 
endgenerate
endmodule
