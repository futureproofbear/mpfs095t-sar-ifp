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

module caxi4interconnect_UpConverter #

        (
                parameter integer ID_WIDTH              = 1, 
                parameter integer ADDR_WIDTH            = 32,
                parameter integer WRITE_ADDR_FIFO_DEPTH = 2,                                // max number of outstanding transactions per thread - valid range 1-8
                parameter integer READ_ADDR_FIFO_DEPTH  = 2,                                // max number of outstanding transactions per thread - valid range 1-8
                parameter integer DATA_WIDTH            = 16, 
                parameter integer DATA_WIDTH_IN         = 32,
                parameter integer DATA_WIDTH_OUT        = 64,                
                parameter integer USER_WIDTH            = 1,
                parameter [13:0]  DATA_FIFO_DEPTH       = 14'h10,
                parameter         READ_INTERLEAVE       = 1,
				parameter         PIPE                  = 0,
				parameter         DWC_RAM_TYPE          = 3,
                parameter         SYNC_RESET            = 0
        )
        (

        //=====================================  Global Signals   ========================================================================
        input  wire                                  ACLK,
        input  wire                                  arst_sync,
        input  wire                                  srst_sync,
 
        //=====================================  Connections to/from Crossbar   ==========================================================
        // Target Read Address Ports
        output wire [ID_WIDTH-1:0]          TARGET_ARID,
        output wire [ADDR_WIDTH-1:0]        TARGET_ARADDR,
        output wire [7:0]                   TARGET_ARLEN,
        output wire [2:0]                   TARGET_ARSIZE,
        output wire [1:0]                   TARGET_ARBURST,
        output wire [1:0]                   TARGET_ARLOCK,
        output wire [3:0]                   TARGET_ARCACHE,
        output wire [2:0]                   TARGET_ARPROT,
        output wire [3:0]                   TARGET_ARREGION,
        output wire [3:0]                   TARGET_ARQOS,
        output wire [USER_WIDTH-1:0]        TARGET_ARUSER,
        output wire                         TARGET_ARVALID,
        input wire                          TARGET_ARREADY,

        // Target Read Data Ports        
        input wire [ID_WIDTH-1:0]          TARGET_RID,
        input wire [DATA_WIDTH_OUT-1:0]    TARGET_RDATA,
        input wire [1:0]                   TARGET_RRESP,
        input wire                         TARGET_RLAST,
        input wire [USER_WIDTH-1:0]        TARGET_RUSER,
        input wire                         TARGET_RVALID,
        output wire                        TARGET_RREADY,

        // Target Write Address Ports        
        output wire [ID_WIDTH-1:0]          TARGET_AWID,
        output wire [ADDR_WIDTH-1:0]        TARGET_AWADDR,
        output wire [7:0]                   TARGET_AWLEN,
        output wire [2:0]                   TARGET_AWSIZE,
        output wire [1:0]                   TARGET_AWBURST,
        output wire [1:0]                   TARGET_AWLOCK,
        output wire [3:0]                   TARGET_AWCACHE,
        output wire [2:0]                   TARGET_AWPROT,
        output wire [3:0]                   TARGET_AWREGION,
        output wire [3:0]                   TARGET_AWQOS,
        output wire [USER_WIDTH-1:0]        TARGET_AWUSER,
        output wire                         TARGET_AWVALID,
        input wire                          TARGET_AWREADY,
        
        // Target Write Data Ports        
		output wire [ID_WIDTH-1:0]                TARGET_WID,
        output wire [DATA_WIDTH_OUT-1:0]          TARGET_WDATA,
        output wire [(DATA_WIDTH_OUT/8)-1:0]      TARGET_WSTRB,
        output wire                               TARGET_WLAST,
        output wire [USER_WIDTH-1:0]              TARGET_WUSER,
        output wire                               TARGET_WVALID,
        input wire                                TARGET_WREADY,
                        
        // Target Write Response Ports        
        input  wire [ID_WIDTH-1:0]         TARGET_BID,
        input  wire [1:0]                  TARGET_BRESP,
        input  wire [USER_WIDTH-1:0]       TARGET_BUSER,
        input  wire                        TARGET_BVALID,
        output wire                        TARGET_BREADY,

        //================================================= External Side Ports  ================================================//

        // Initiator Read Address Ports        
        input  wire [ID_WIDTH-1:0]          INITIATOR_ARID,
        input  wire [ADDR_WIDTH-1:0]        INITIATOR_ARADDR,
        input  wire [7:0]                   INITIATOR_ARLEN,
        input  wire [2:0]                   INITIATOR_ARSIZE,
        input  wire [1:0]                   INITIATOR_ARBURST,
        input  wire [1:0]                   INITIATOR_ARLOCK,
        input  wire [3:0]                   INITIATOR_ARCACHE,
        input  wire [2:0]                   INITIATOR_ARPROT,
        input  wire [3:0]                   INITIATOR_ARREGION,
        input  wire [3:0]                   INITIATOR_ARQOS,
        input  wire [USER_WIDTH-1:0]        INITIATOR_ARUSER,
        input  wire                         INITIATOR_ARVALID,
        output wire                         INITIATOR_ARREADY,
        
        // Initiator Read Data Ports        
        output wire [ID_WIDTH-1:0]       INITIATOR_RID,
        output wire [DATA_WIDTH_IN-1:0]  INITIATOR_RDATA,
        output wire [1:0]                INITIATOR_RRESP,
        output wire                      INITIATOR_RLAST,
        output wire [USER_WIDTH-1:0]     INITIATOR_RUSER,
        output wire                      INITIATOR_RVALID,
        input wire                       INITIATOR_RREADY,
        
        // Initiator Write Address Ports        
        input  wire [ID_WIDTH-1:0]       INITIATOR_AWID,
        input  wire [ADDR_WIDTH-1:0]     INITIATOR_AWADDR,
        input  wire [7:0]                INITIATOR_AWLEN,
        input  wire [2:0]                INITIATOR_AWSIZE,
        input  wire [1:0]                INITIATOR_AWBURST,
        input  wire [1:0]                INITIATOR_AWLOCK,
        input  wire [3:0]                INITIATOR_AWCACHE,
        input  wire [2:0]                INITIATOR_AWPROT,
        input  wire [3:0]                INITIATOR_AWREGION,
        input  wire [3:0]                INITIATOR_AWQOS,
        input  wire [USER_WIDTH-1:0]     INITIATOR_AWUSER,
        input  wire                      INITIATOR_AWVALID,
        output wire                      INITIATOR_AWREADY,
        
        // Initiator Write Data Ports        
		input wire [ID_WIDTH-1:0]           INITIATOR_WID,
        input wire [DATA_WIDTH_IN-1:0]      INITIATOR_WDATA,
        input wire [(DATA_WIDTH_IN/8)-1:0]  INITIATOR_WSTRB,
        input wire                          INITIATOR_WLAST,
        input wire [USER_WIDTH-1:0]         INITIATOR_WUSER,
        input wire                          INITIATOR_WVALID,
        output wire                         INITIATOR_WREADY,
        
        // Initiator Write Response Ports        
        output wire [ID_WIDTH-1:0]          INITIATOR_BID,
        output wire [1:0]                   INITIATOR_BRESP,
        output wire [USER_WIDTH-1:0]        INITIATOR_BUSER,
        output wire                         INITIATOR_BVALID,
        input wire                          INITIATOR_BREADY

        ) ;
		
    localparam TOTAL_IDS     = READ_INTERLEAVE ? (2 ** ID_WIDTH) : 1;		
        
//================================== Internal ==============================

    wire [TOTAL_IDS-1:0]  rchan_cmd_fifo_full;
    wire                  rchan_wr_en_cmd;
    wire                  wchan_cmd_fifo_full;
    wire                  bchan_cmd_fifo_full;
    wire                  wchan_wr_en_cmd;
    wire                  awchan_extend;
    wire [5:0]            awaddr_intr;
    wire [2:0]            awsize_intr;
    wire [7:0]            awlen_intr;
    wire [ID_WIDTH-1:0]   awid_intr;
    wire                  wchan_wrap_flag;
    wire                  wchan_fixed_flag;
    wire                  archan_extend;
    wire [5:0]            araddr_intr;
    wire [2:0]            arsize_intr;
    wire [7:0]            arlen_intr;
    wire [ID_WIDTH-1:0]   arid_intr;
    wire                  rchan_wrap_flag;
    wire                  rchan_fixed_flag;
    wire [4:0]            archan_to_wrap_boundary;
    wire [4:0]            awchan_to_wrap_boundary;
    wire                  archan_unaligned_wrap_burst;
        
        
   
    wire        [4:0]  to_boundary_initiator_aw;
    wire        [9:0]  mask_wrap_addr_aw;  
    wire        [2:0]  sizeDiff_aw;
    wire               unaligned_wrap_burst_comb_aw;
    wire        [5:0]  len_offset_aw;
    wire               wrap_tx_aw;
    wire               fixed_flag_comb_aw;
   
    wire     [7:0]               int_INITIATOR_ARLEN;
    wire                         int_INITIATOR_ARVALID;
    wire     [ID_WIDTH - 1:0]    int_INITIATOR_ARID;
    wire     [ADDR_WIDTH - 1:0]  int_INITIATOR_ARADDR;
    wire     [1:0]               int_INITIATOR_ARBURST;
    wire     [3:0]               int_INITIATOR_ARCACHE;
    wire     [1:0]               int_INITIATOR_ARLOCK;
    wire     [2:0]               int_INITIATOR_ARSIZE;
    wire     [2:0]               int_INITIATOR_ARPROT;
    wire     [3:0]               int_INITIATOR_ARQOS;
    wire     [3:0]               int_INITIATOR_ARREGION;
    wire     [USER_WIDTH - 1:0]  int_INITIATOR_ARUSER;
    wire                         int_INITIATOR_ARREADY; // from wrCmdFifoWriteCtrl
        
   
    wire        [4:0]  to_boundary_initiator_ar;
    wire        [9:0]  mask_wrap_addr_ar;  
    wire       [2:0]   sizeDiff_ar;
    wire               unaligned_wrap_burst_comb_ar;
    wire        [5:0]  len_offset_ar;
    wire               wrap_tx_ar;
    wire               fixed_flag_comb_ar;
	
	wire        [7:0]  alen_sec_wrap_ar;
	wire        [7:0]  alen_sec_wrap_aw;
	wire        [7:0]  alen_wrap_ar;
	wire        [7:0]  alen_wrap_aw;
   
    wire     [7:0]               int_INITIATOR_AWLEN;
    wire                         int_INITIATOR_AWVALID;
    wire     [ID_WIDTH - 1:0]    int_INITIATOR_AWID;
    wire     [ADDR_WIDTH - 1:0]  int_INITIATOR_AWADDR;
    wire     [1:0]               int_INITIATOR_AWBURST;
    wire     [3:0]               int_INITIATOR_AWCACHE;
    wire     [1:0]               int_INITIATOR_AWLOCK;
    wire     [2:0]               int_INITIATOR_AWSIZE;
    wire     [2:0]               int_INITIATOR_AWPROT;
    wire     [3:0]               int_INITIATOR_AWQOS;
    wire     [3:0]               int_INITIATOR_AWREGION;
    wire     [USER_WIDTH - 1:0]  int_INITIATOR_AWUSER;
    wire                         int_INITIATOR_AWREADY; // from wrCmdFifoWriteCtrl


//=======================AW Channel====================        
caxi4interconnect_DWC_UpConv_AChannel #
      (
      .ID_WIDTH      ( ID_WIDTH ),
      .ADDR_WIDTH    ( ADDR_WIDTH ),
      .USER_WIDTH    ( USER_WIDTH ),
      .DATA_WIDTH_IN ( DATA_WIDTH_IN ),
      .DATA_WIDTH_OUT( DATA_WIDTH_OUT ),
	  .TOTAL_IDS     ( TOTAL_IDS      ),
	  .READ_INTERLEAVE (READ_INTERLEAVE)
      )
    DWC_AWChan
      (
      // Global Signals
      .ACLK                          ( ACLK ),
      .arst_sync                     ( arst_sync ),            // active low reset synchronoise to RE AClk - asserted async.
      .srst_sync                     ( srst_sync ),            // active low reset synchronoise to RE AClk - asserted async.

      .fifoFull                      ({TOTAL_IDS {(wchan_cmd_fifo_full | bchan_cmd_fifo_full)}} ),
      .last_beat_wrap                ( awchan_to_wrap_boundary ),
      .wr_en_cmd                     ( wchan_wr_en_cmd ),
      .asize_intr                     ( awsize_intr ),
      .aid_intr                       ( awid_intr ),
      .wrap_flag                     ( wchan_wrap_flag ),
      .fixed_flag                    ( wchan_fixed_flag ),
      .alen_intr                      ( awlen_intr ),
      .unaligned_wrap_burst          ( ),

      .extend_tx                     ( awchan_extend ),
      .addr_fifo                     ( awaddr_intr ),

      .alen_wrap_pre                 ( alen_wrap_aw ),
      .alen_sec_wrap_pre             ( alen_sec_wrap_aw ),
      .to_boundary_initiator_pre        ( to_boundary_initiator_aw ),
      .mask_wrap_addr_pre            ( mask_wrap_addr_aw ),
      .sizeDiff_pre                  ( sizeDiff_aw ),
      .unaligned_wrap_burst_comb_pre ( unaligned_wrap_burst_comb_aw ),
      .len_offset_pre                ( len_offset_aw ),
      .wrap_tx_pre                   ( wrap_tx_aw ),
      .fixed_flag_comb_pre           ( fixed_flag_comb_aw ),

      .INITIATOR_AID                    ( int_INITIATOR_AWID ),
      .INITIATOR_AADDR                  ( int_INITIATOR_AWADDR ),
      .INITIATOR_ALEN                   ( int_INITIATOR_AWLEN ),
      .INITIATOR_ASIZE                  ( int_INITIATOR_AWSIZE ),
      .INITIATOR_ABURST                 ( int_INITIATOR_AWBURST ),
      .INITIATOR_AQOS                   ( int_INITIATOR_AWQOS ),
      .INITIATOR_AREGION                ( int_INITIATOR_AWREGION ),
      .INITIATOR_ALOCK                  ( int_INITIATOR_AWLOCK ),
      .INITIATOR_ACACHE                 ( int_INITIATOR_AWCACHE ),
      .INITIATOR_APROT                  ( int_INITIATOR_AWPROT ),
      .INITIATOR_AUSER                  ( int_INITIATOR_AWUSER ),
      .INITIATOR_AVALID                 ( int_INITIATOR_AWVALID ),

      .INITIATOR_AREADY                 ( int_INITIATOR_AWREADY ),
      .TARGET_AID                     ( TARGET_AWID ),
      .TARGET_AADDR                   ( TARGET_AWADDR ),
      .TARGET_ALEN                    ( TARGET_AWLEN ),
      .TARGET_ASIZE                   ( TARGET_AWSIZE ),
      .TARGET_ABURST                  ( TARGET_AWBURST ),
      .TARGET_AQOS                    ( TARGET_AWQOS ),
      .TARGET_AREGION                 ( TARGET_AWREGION ),
      .TARGET_ALOCK                   ( TARGET_AWLOCK ),
      .TARGET_ACACHE                  ( TARGET_AWCACHE ),
      .TARGET_APROT                   ( TARGET_AWPROT ),
      .TARGET_AUSER                   ( TARGET_AWUSER ),
      .TARGET_AVALID                  ( TARGET_AWVALID ),

      .TARGET_AREADY                  ( TARGET_AWREADY )

      );    
//=======================AW Channel Pre Calc====================  
caxi4interconnect_DWC_UpConv_preCalcAChannel #
      (
      .DATA_WIDTH_OUT ( DATA_WIDTH_OUT ), // DATA_WIDTH_IN as it is in the read direction
      .ADDR_WIDTH     ( ADDR_WIDTH ),
      .USER_WIDTH     ( USER_WIDTH ),
      .ID_WIDTH       ( ID_WIDTH )

      )
    DWC_UpConv_preCalcAChannel_aw_inst
      (
      .clk                           ( ACLK ),
      .arst_sync                     ( arst_sync ),
      .srst_sync                     ( srst_sync ),

      .INITIATOR_ALEN_in                ( INITIATOR_AWLEN ),
      .INITIATOR_AADDR_in               ( INITIATOR_AWADDR ),
      .INITIATOR_ABURST_in              ( INITIATOR_AWBURST ),
      .INITIATOR_ACACHE_in              ( INITIATOR_AWCACHE ),
      .INITIATOR_AID_in                 ( INITIATOR_AWID ),
      .INITIATOR_ALOCK_in               ( INITIATOR_AWLOCK ),
      .INITIATOR_APROT_in               ( INITIATOR_AWPROT ),
      .INITIATOR_AQOS_in                ( INITIATOR_AWQOS ),
      .INITIATOR_AREGION_in             ( INITIATOR_AWREGION ),
      .INITIATOR_ASIZE_in               ( INITIATOR_AWSIZE ),
      .INITIATOR_AUSER_in               ( INITIATOR_AWUSER ),
      .INITIATOR_AVALID_in              ( INITIATOR_AWVALID ),

      .INITIATOR_AREADY_in              (  int_INITIATOR_AWREADY ), // from ctrl

      .INITIATOR_ALEN_out               ( int_INITIATOR_AWLEN  ),
      .INITIATOR_AADDR_out              ( int_INITIATOR_AWADDR ),
      .INITIATOR_ABURST_out             ( int_INITIATOR_AWBURST ),
      .INITIATOR_ACACHE_out             ( int_INITIATOR_AWCACHE ),
      .INITIATOR_AID_out                ( int_INITIATOR_AWID ),
      .INITIATOR_ALOCK_out              ( int_INITIATOR_AWLOCK ),
      .INITIATOR_APROT_out              ( int_INITIATOR_AWPROT ),
      .INITIATOR_AQOS_out               ( int_INITIATOR_AWQOS ),
      .INITIATOR_AREGION_out            ( int_INITIATOR_AWREGION ),
      .INITIATOR_ASIZE_out              ( int_INITIATOR_AWSIZE ),
      .INITIATOR_AUSER_out              ( int_INITIATOR_AWUSER ),
      .INITIATOR_AVALID_out             ( int_INITIATOR_AWVALID ),

      .INITIATOR_AREADY_out             ( INITIATOR_AWREADY ), // to source

      .alen_wrap_pre                 ( alen_wrap_aw ),
      .alen_sec_wrap_pre             ( alen_sec_wrap_aw ),
      .to_boundary_initiator_pre        ( to_boundary_initiator_aw ),
      .mask_wrap_addr_pre            ( mask_wrap_addr_aw ),
      .sizeDiff_pre                  ( sizeDiff_aw ),
      .unaligned_wrap_burst_comb_pre ( unaligned_wrap_burst_comb_aw ),
      .len_offset_pre                ( len_offset_aw ),
      .wrap_tx_pre                   ( wrap_tx_aw ),
      .fixed_flag_comb_pre           ( fixed_flag_comb_aw )
      );

//========================W Channel====================
caxi4interconnect_DWC_UpConv_WChannel #
      (
      .ID_WIDTH       ( ID_WIDTH ),
      .DATA_WIDTH_IN  ( DATA_WIDTH_IN ),
      .DATA_WIDTH_OUT ( DATA_WIDTH_OUT ),
      .USER_WIDTH     ( USER_WIDTH ),
      .DATA_FIFO_DEPTH( DATA_FIFO_DEPTH ),
      .ADDR_FIFO_DEPTH( WRITE_ADDR_FIFO_DEPTH ),
      .PIPE           ( PIPE ),
	  .DWC_RAM_TYPE   ( DWC_RAM_TYPE ),
      .SYNC_RESET     ( SYNC_RESET )
      ) DWC_WChan
      (
      // Global Signals
      .ACLK                        ( ACLK ),
      .arst_sync                   ( arst_sync ),                        // active low reset synchronoise to RE AClk - asserted async.
      .srst_sync                   ( srst_sync ),                        // active low reset synchronoise to RE AClk - asserted async.
      .awaddr_intr                  ( awaddr_intr ),
      .awsize_intr                  ( awsize_intr ),
      .awlen_trgt                   ( TARGET_AWLEN ),
      .awlen_intr                   ( awlen_intr ),
      .to_wrap_boundary_initiator     (awchan_to_wrap_boundary),
	  .INITIATOR_WID                  (INITIATOR_WID),
      .INITIATOR_WDATA                ( INITIATOR_WDATA ),
      .INITIATOR_WSTRB                ( INITIATOR_WSTRB ),
      .INITIATOR_WLAST                ( INITIATOR_WLAST ),
      .INITIATOR_WUSER                ( INITIATOR_WUSER ),
      .INITIATOR_WVALID               ( INITIATOR_WVALID ),

      .INITIATOR_WREADY               ( INITIATOR_WREADY ),

	  .TARGET_WID                   ( TARGET_WID ),
      .TARGET_WDATA                 ( TARGET_WDATA ),
      .TARGET_WSTRB                 ( TARGET_WSTRB ),
      .TARGET_WLAST                 ( TARGET_WLAST ),
      .TARGET_WUSER                 ( TARGET_WUSER ),
      .TARGET_WVALID                ( TARGET_WVALID ),

      .TARGET_WREADY                ( TARGET_WREADY ),
      .cmd_fifo_full               ( wchan_cmd_fifo_full ),
      .wr_en_cmd                   ( wchan_wr_en_cmd ),
      .extend_tx                   ( awchan_extend ),
      .wrap_flag                   ( wchan_wrap_flag ),
      .fixed_flag                  ( wchan_fixed_flag )
      );
                                                        
//========================B Channel====================        
caxi4interconnect_DWC_UpConv_BChannel #
      (
      .ID_WIDTH       ( ID_WIDTH ),
      .USER_WIDTH     ( USER_WIDTH ),
      .ADDR_FIFO_DEPTH( WRITE_ADDR_FIFO_DEPTH ),
      .READ_INTERLEAVE( READ_INTERLEAVE ),
      .PIPE           ( PIPE ),
	  .DWC_RAM_TYPE   ( DWC_RAM_TYPE ),
      .SYNC_RESET     ( SYNC_RESET )
      )
    DWC_BChan
      (
      // Global Signals
      .ACLK                ( ACLK ),
      .arst_sync           ( arst_sync ),  // active low reset synchronoise to RE AClk - asserted async.
      .srst_sync           ( srst_sync ),  // active low reset synchronoise to RE AClk - asserted async.
      .BRespFifoWrData     ( {awid_intr, ~awchan_extend} ),
      .INITIATOR_BID          ( INITIATOR_BID ),
      .INITIATOR_BRESP        ( INITIATOR_BRESP ),
      .INITIATOR_BUSER        ( INITIATOR_BUSER ),
      .INITIATOR_BVALID       ( INITIATOR_BVALID ),
      .INITIATOR_BREADY       ( INITIATOR_BREADY ),

      .TARGET_BID           ( TARGET_BID ),
      .TARGET_BRESP         ( TARGET_BRESP ),
      .TARGET_BUSER         ( TARGET_BUSER ),
      .TARGET_BVALID        ( TARGET_BVALID ),
      .TARGET_BREADY        ( TARGET_BREADY ),

      .bchan_cmd_fifo_full ( bchan_cmd_fifo_full ),
      .wr_en_cmd           ( wchan_wr_en_cmd )
      );

//=======================AR Channel====================
caxi4interconnect_DWC_UpConv_AChannel #
      (
      .ID_WIDTH      ( ID_WIDTH ),
      .ADDR_WIDTH    ( ADDR_WIDTH ),
      .USER_WIDTH    ( USER_WIDTH ),
      .DATA_WIDTH_IN ( DATA_WIDTH_IN ),
      .DATA_WIDTH_OUT( DATA_WIDTH_OUT ),
	  .TOTAL_IDS     (TOTAL_IDS),
	  .READ_INTERLEAVE (READ_INTERLEAVE)
      )
    DWC_ARChan 
      (
      // Global Signals
      .ACLK                          ( ACLK ),
      .arst_sync                     ( arst_sync ),        // active low reset synchronoise to RE AClk - asserted async.
      .srst_sync                     ( srst_sync ),        // active low reset synchronoise to RE AClk - asserted async.

      .fifoFull                      ( rchan_cmd_fifo_full ),
      .last_beat_wrap                ( archan_to_wrap_boundary ),
      .wr_en_cmd                     ( rchan_wr_en_cmd ),
      .asize_intr                     ( arsize_intr ),
      .wrap_flag                     ( rchan_wrap_flag ),
      .aid_intr                       ( arid_intr ),
      .fixed_flag                    ( rchan_fixed_flag ),
      .alen_intr                      ( arlen_intr ),

      .extend_tx                     ( archan_extend ),
      .addr_fifo                     ( araddr_intr ),
      .unaligned_wrap_burst          ( archan_unaligned_wrap_burst ),

      .alen_wrap_pre                 ( alen_wrap_ar ),
      .alen_sec_wrap_pre             ( alen_sec_wrap_ar ),
      .to_boundary_initiator_pre        ( to_boundary_initiator_ar ),
      .mask_wrap_addr_pre            ( mask_wrap_addr_ar ),
      .sizeDiff_pre                  ( sizeDiff_ar ),
      .unaligned_wrap_burst_comb_pre ( unaligned_wrap_burst_comb_ar ),
      .len_offset_pre                ( len_offset_ar ),
      .wrap_tx_pre                   ( wrap_tx_ar ),
      .fixed_flag_comb_pre           ( fixed_flag_comb_ar ),

      .INITIATOR_AID                    ( int_INITIATOR_ARID ),
      .INITIATOR_AADDR                  ( int_INITIATOR_ARADDR ),
      .INITIATOR_ALEN                   ( int_INITIATOR_ARLEN ),
      .INITIATOR_ASIZE                  ( int_INITIATOR_ARSIZE ),
      .INITIATOR_ABURST                 ( int_INITIATOR_ARBURST ),
      .INITIATOR_AQOS                   ( int_INITIATOR_ARQOS ),
      .INITIATOR_AREGION                ( int_INITIATOR_ARREGION ),
      .INITIATOR_ALOCK                  ( int_INITIATOR_ARLOCK ),
      .INITIATOR_ACACHE                 ( int_INITIATOR_ARCACHE ),
      .INITIATOR_APROT                  ( int_INITIATOR_ARPROT ),
      .INITIATOR_AUSER                  ( int_INITIATOR_ARUSER ),
      .INITIATOR_AVALID                 ( int_INITIATOR_ARVALID ),

      .INITIATOR_AREADY                 ( int_INITIATOR_ARREADY ),
      .TARGET_AID                     ( TARGET_ARID ),
      .TARGET_AADDR                   ( TARGET_ARADDR ),
      .TARGET_ALEN                    ( TARGET_ARLEN ),
      .TARGET_ASIZE                   ( TARGET_ARSIZE ),
      .TARGET_ABURST                  ( TARGET_ARBURST ),
      .TARGET_AQOS                    ( TARGET_ARQOS ),
      .TARGET_AREGION                 ( TARGET_ARREGION ),
      .TARGET_ALOCK                   ( TARGET_ARLOCK ),
      .TARGET_ACACHE                  ( TARGET_ARCACHE ),
      .TARGET_APROT                   ( TARGET_ARPROT ),
      .TARGET_AUSER                   ( TARGET_ARUSER ),
      .TARGET_AVALID                  ( TARGET_ARVALID ),

      .TARGET_AREADY                  ( TARGET_ARREADY )

      ); 
//=======================AR Channel Pre Calc====================  

caxi4interconnect_DWC_UpConv_preCalcAChannel #
      (
      .DATA_WIDTH_OUT ( DATA_WIDTH_OUT ), // DATA_WIDTH_IN as it is in the read direction
      .ADDR_WIDTH     ( ADDR_WIDTH ),
      .USER_WIDTH     ( USER_WIDTH ),
      .ID_WIDTH       ( ID_WIDTH )

      )
    DWC_UpConv_preCalcAChannel_ar_inst
      (
      .clk                                ( ACLK ),
      .arst_sync                          ( arst_sync ),
      .srst_sync                          ( srst_sync ),

      .INITIATOR_ALEN_in                     (  INITIATOR_ARLEN ),
      .INITIATOR_AADDR_in                    ( INITIATOR_ARADDR ),
      .INITIATOR_ABURST_in                   ( INITIATOR_ARBURST ),
      .INITIATOR_ACACHE_in                   ( INITIATOR_ARCACHE ),
      .INITIATOR_AID_in                      ( INITIATOR_ARID ),
      .INITIATOR_ALOCK_in                    ( INITIATOR_ARLOCK ),
      .INITIATOR_APROT_in                    ( INITIATOR_ARPROT ),
      .INITIATOR_AQOS_in                     ( INITIATOR_ARQOS ),
      .INITIATOR_AREGION_in                  ( INITIATOR_ARREGION ),
      .INITIATOR_ASIZE_in                    ( INITIATOR_ARSIZE ),
      .INITIATOR_AUSER_in                    ( INITIATOR_ARUSER ),
      .INITIATOR_AVALID_in                   ( INITIATOR_ARVALID ),

      .INITIATOR_AREADY_in                   (  int_INITIATOR_ARREADY ), // from ctrl

      .INITIATOR_ALEN_out                    ( int_INITIATOR_ARLEN  ),
      .INITIATOR_AADDR_out                   ( int_INITIATOR_ARADDR ),
      .INITIATOR_ABURST_out                  ( int_INITIATOR_ARBURST ),
      .INITIATOR_ACACHE_out                  ( int_INITIATOR_ARCACHE ),
      .INITIATOR_AID_out                     ( int_INITIATOR_ARID ),
      .INITIATOR_ALOCK_out                   ( int_INITIATOR_ARLOCK ),
      .INITIATOR_APROT_out                   ( int_INITIATOR_ARPROT ),
      .INITIATOR_AQOS_out                    ( int_INITIATOR_ARQOS ),
      .INITIATOR_AREGION_out                 ( int_INITIATOR_ARREGION ),
      .INITIATOR_ASIZE_out                   ( int_INITIATOR_ARSIZE ),
      .INITIATOR_AUSER_out                   ( int_INITIATOR_ARUSER ),
      .INITIATOR_AVALID_out                  ( int_INITIATOR_ARVALID ),

      .INITIATOR_AREADY_out                  ( INITIATOR_ARREADY ), // to source

      .alen_wrap_pre                      ( alen_wrap_ar ),
      .alen_sec_wrap_pre                  ( alen_sec_wrap_ar ),
      .to_boundary_initiator_pre             ( to_boundary_initiator_ar ),
      .mask_wrap_addr_pre                 ( mask_wrap_addr_ar ),
      .sizeDiff_pre                       ( sizeDiff_ar ),
      .unaligned_wrap_burst_comb_pre      ( unaligned_wrap_burst_comb_ar ),
      .len_offset_pre                     ( len_offset_ar ),
      .wrap_tx_pre                        ( wrap_tx_ar ),
      .fixed_flag_comb_pre                ( fixed_flag_comb_ar )                                       
      );
//========================R Channel====================        
caxi4interconnect_DWC_UpConv_RChannel #
      (
      .ID_WIDTH           ( ID_WIDTH ),
      .DATA_WIDTH_IN      ( DATA_WIDTH_OUT ),
      .DATA_WIDTH_OUT     ( DATA_WIDTH_IN ),
      .USER_WIDTH         ( USER_WIDTH ),
      .DATA_FIFO_DEPTH    ( DATA_FIFO_DEPTH ),
      .ADDR_FIFO_DEPTH    ( READ_ADDR_FIFO_DEPTH ),
	  .READ_INTERLEAVE    (READ_INTERLEAVE),
	  .TOTAL_IDS          (TOTAL_IDS),
      .PIPE               (PIPE),
	  .DWC_RAM_TYPE       (DWC_RAM_TYPE ),
      .SYNC_RESET         (SYNC_RESET)
      )
    DWC_RChan
      (
      // Global Signals
      .ACLK               ( ACLK ),
      .arst_sync          ( arst_sync ),        // active low reset synchronoise to RE AClk - asserted async.
      .srst_sync          ( srst_sync ),        // active low reset synchronoise to RE AClk - asserted async.
      .araddr_intrr        ( araddr_intr ),
      .arid_intrr          ( arid_intr ),
      .arlen_intrr         ( arlen_intr ),
      .INITIATOR_RSIZE       ( arsize_intr ),
      .fixed_flag         ( rchan_fixed_flag ),
      .INITIATOR_RDATA       ( INITIATOR_RDATA ),
      .INITIATOR_RLAST       ( INITIATOR_RLAST ),
      .INITIATOR_RUSER       ( INITIATOR_RUSER ),
      .INITIATOR_RVALID      ( INITIATOR_RVALID ),
      .INITIATOR_RID         ( INITIATOR_RID ),
      .INITIATOR_RRESP       ( INITIATOR_RRESP ),
      .INITIATOR_RREADY      ( INITIATOR_RREADY ),
      .TARGET_RID          ( TARGET_RID ),
      .TARGET_RDATA        ( TARGET_RDATA ),
      .TARGET_RLAST        ( TARGET_RLAST ),
      .TARGET_RUSER        ( TARGET_RUSER ),
      .TARGET_RVALID       ( TARGET_RVALID ),
      .TARGET_RREADY       ( TARGET_RREADY ),
      .TARGET_RRESP        ( TARGET_RRESP ),

      .cmd_fifo_full      ( rchan_cmd_fifo_full ),
      .wr_en_cmd          ( rchan_wr_en_cmd & (~rchan_wrap_flag | (rchan_wrap_flag & ~(archan_extend ^ archan_unaligned_wrap_burst ))) ),
      .to_boundary_initiator ( archan_to_wrap_boundary ),
      .wrap_flag          ( rchan_wrap_flag ),
      .extend_wrap        ( archan_extend )
);


endmodule // caxi4interconnect_UpConverter.v
