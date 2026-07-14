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
// SVN $Revision: 49538 $
// SVN $Date: 2025-08-17 13:12:47 +0530 (Sun, 17 Aug 2025) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns



module caxi4interconnect_DWC_UpConv_WChannel #

	(
		parameter integer	ID_WIDTH	    = 1,
		parameter integer	USER_WIDTH	    = 1,
		parameter integer	DATA_FIFO_DEPTH	= 1024,
		parameter integer	ADDR_FIFO_DEPTH	= 3,
		parameter integer	DATA_WIDTH_IN	= 32,
		parameter integer	DATA_WIDTH_OUT	= 32,
        parameter           PIPE            = 0,
        parameter           DWC_RAM_TYPE    = 3,
        parameter           SYNC_RESET      = 0
	)
	(

		input wire arst_sync,
		input wire srst_sync,
		input wire ACLK,

		// Input Write channel
		// Address W channel
		input wire [5:0] awaddr_intr,
		input wire [7:0] awlen_trgt,
		input wire [2:0] awsize_intr,

		// W channel
		input wire [ID_WIDTH-1:0]           INITIATOR_WID,
		input wire[DATA_WIDTH_IN-1:0]       INITIATOR_WDATA,
		input wire[(DATA_WIDTH_IN/8)-1:0]   INITIATOR_WSTRB,
		input wire[USER_WIDTH-1:0]          INITIATOR_WUSER,
		input wire INITIATOR_WLAST,
		input wire INITIATOR_WVALID,
		output wire INITIATOR_WREADY,

		// W channel
		output wire [ID_WIDTH-1:0]      TARGET_WID,
		output wire[DATA_WIDTH_OUT-1:0] TARGET_WDATA,
		output wire[(DATA_WIDTH_OUT/8)-1:0] TARGET_WSTRB,
		output wire[USER_WIDTH-1:0] TARGET_WUSER,
		output wire TARGET_WLAST,
		output wire TARGET_WVALID,
		input wire TARGET_WREADY,

    output wire                           cmd_fifo_full,
		input wire			      wr_en_cmd,
		input wire[7:0]                            awlen_intr,
		input wire			      wrap_flag,
		input wire			      fixed_flag,
		input wire			      extend_tx,
		input wire [4:0] to_wrap_boundary_initiator
	);

	genvar i;

  
	localparam FIFO_DATA_WIDTH_IN = DATA_WIDTH_IN + DATA_WIDTH_IN/8;
	localparam FIFO_DATA_WIDTH_OUT = DATA_WIDTH_OUT + DATA_WIDTH_OUT/8;
	localparam CONV_RATIO = FIFO_DATA_WIDTH_OUT/FIFO_DATA_WIDTH_IN;
	localparam DATA_NEARLY_FULL = DATA_FIFO_DEPTH - 1;
	localparam DATA_NEARLY_EMPTY = (3*DATA_FIFO_DEPTH/4) - 1;
	
	

	wire wr_cmd_intr_fifo_full;
	wire wr_cmd_trgt_fifo_full;
	wire wr_cmd_intr_fifo_empty;

    wire data_fifo_one_from_full;

 	wire [5:0] addr_out_intr;
  
	wire [2:0] awsize_out_intr;
	wire [7:0] curr_awlen_trgt;

	wire [(CONV_RATIO)-1:0] zero_strb_data;
	wire [(CONV_RATIO)-1:0] wr_en_data;
    wire incr_pkt_cnt;

	wire [7:0] intr_beat_cnt;

	wire [(FIFO_DATA_WIDTH_OUT + USER_WIDTH + ID_WIDTH)-1:0] fifo_data_out_reg;
  
	wire [USER_WIDTH-1:0]         wuser_out;
	wire [DATA_WIDTH_OUT-1:0]     wdata_out;
	wire [(DATA_WIDTH_OUT/8)-1:0] wstrb_out;
	wire [ID_WIDTH-1:0]           wid_out;

	wire [ID_WIDTH+USER_WIDTH+DATA_WIDTH_IN+DATA_WIDTH_IN/8-1:0] fifo_data_in;

	wire pass_data;
	wire rd_en_data;

	wire rd_en_cmd_trgt;
	wire rd_en_cmd_intr;

	wire extend_out_intr;
	wire wrap_flag_out_intr;
	wire fixed_flag_out_intr;
  
	wire [7:0] awlen_intr_out_intr;
  
	wire [4:0] to_wrap_boundary_out_intr;
  
    wire data_fifo_full;
    wire data_fifo_empty;
    wire data_fifo_nearly_full;
    wire data_fifo_nearly_empty;
  

	assign cmd_fifo_full = ( wr_cmd_trgt_fifo_full | wr_cmd_intr_fifo_full ); // Both 'fifo_full' statements are really caxi4interconnect_FIFO nearly full

  
  
  // Hold signals for hold reg
  wire        wr_cmd_intr_hold_reg_empty;
  wire [4:0]  to_wrap_boundary_out_intr_hold;
  wire [7:0]  awlen_intr_out_intr_hold;
  wire        extend_out_intr_hold;
  wire        wrap_flag_out_intr_hold;

  wire        fixed_flag_out_intr_hold;
  wire        post_hold_rd_en_cmd_intr;
  
  wire [5:0]  addr_out_intr_hold;
  wire [2:0]  awsize_out_intr_hold;
        

  wire [6:0]    size_one_hot_hold;
  wire [5:0]    mask_addr_msb_hold;
  wire [5:0]    mask_addr_hold;
  wire          aligned_wrap_hold;
  wire          second_wrap_burst_hold;
  wire          extend_wrap_hold;

  
  wire [5:0]  size_shifted_out_intr_hold;
  wire initiator_beat_cnt_eq_0;
  wire [11:0]  initiator_beat_cnt_to_boundary_shifted;
  wire [11:0]  initiator_beat_cnt_shifted;
  
  wire         cfifo_rst;

  assign       cfifo_rst = (SYNC_RESET == 0) ? arst_sync : srst_sync;   
  localparam [31:0] EXTRA_DATA_WIDTH_VAL = USER_WIDTH + ID_WIDTH;
  
	caxi4interconnect_FIFO_upsizing #
	(
	  .MEM_DEPTH( DATA_FIFO_DEPTH ),
 	  .DATA_WIDTH_IN ( FIFO_DATA_WIDTH_IN ),
	  .DATA_WIDTH_OUT ( FIFO_DATA_WIDTH_OUT ), 
      .EXTRA_DATA_WIDTH( EXTRA_DATA_WIDTH_VAL ),
	  .NEARLY_FULL_THRESH ( DATA_NEARLY_FULL ),
	  .NEARLY_EMPTY_THRESH ( DATA_NEARLY_EMPTY ),
      .PIPE ( PIPE ),
      .DWC_RAM_TYPE ( DWC_RAM_TYPE ),
	  .SYNC_RESET ( SYNC_RESET )
	)
	data_fifo (
	  .arst_sync ( arst_sync ),
	  .srst_sync ( srst_sync ),
	  .clk ( ACLK ),
	  .wr_en ( wr_en_data ),
	  .rd_en ( rd_en_data ),
	  .data_in ( fifo_data_in ),
	  .data_out ( fifo_data_out_reg ),
	  .pass_data ( pass_data ),
	  .zero_data ( zero_strb_data ),
	  .fifo_full ( data_fifo_full ),
	  .fifo_empty ( data_fifo_empty ),
	  .fifo_nearly_full ( data_fifo_nearly_full ),
	  .fifo_nearly_empty ( data_fifo_nearly_empty ), //////
	  .fifo_one_from_full ( data_fifo_one_from_full ),
	  .zero_out_data	( 1'b0 )
	);	  

  generate
    if(PIPE > 0) begin 
	    localparam  FIFO_SIZE = ($clog2(ADDR_FIFO_DEPTH) < 2) ? 4 : ADDR_FIFO_DEPTH;
		wire wrcmdintrfifo_itvld;
		wire wrcmdintrfifo_ttrdy;
		wire wrcmdtrgtfifo_ttrdy;
        caxi4c_coreaxi4s_fifo #
        (
           .RESET_TYPE         (SYNC_RESET),//
           .SYNC               (1),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
           .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
           .ECC                (0),// 0: ECC disable , 1: ECC enable
           .RAM_TYPE           (DWC_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
           .NUM_STAGES         (0),// To select number of synchronizer stages.
           .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
           .WFIFO_DEPTH        (FIFO_SIZE),
           .RFIFO_DEPTH        (FIFO_SIZE),
           .AXIS_TTDATA_WIDTH  ( 1 + 6 + 3 + 1 + 1 + 8 + 5), // Bytes
           .AXIS_ITDATA_WIDTH  ( 1 + 6 + 3 + 1 + 1 + 8 + 5),  // Bytes
           .AXIS_TTID_WIDTH    (1), // Bits
           .AXIS_ITID_WIDTH    (1), // Bits
           .AXIS_TTDEST_WIDTH  (1), // Bits
           .AXIS_ITDEST_WIDTH  (1), // Bits
           .AXIS_TTUSER_WIDTH  (1), // Bits
           .AXIS_ITUSER_WIDTH  (1), // Bits
           .ENABLE_AFULL       (1),
           .AFULL_THR          (FIFO_SIZE-1),
           .ENABLE_TSTRB       (0),
           .ENABLE_TKEEP       (0),
           .ENABLE_TLAST       (0),
           .ENABLE_TUSER       (0),
           .ENABLE_TDEST       (0),
           .ENABLE_TID         (0),
           .EOP_OFFSET         (0)
        ) wr_cmd_intr_fwft
        (
           .AXI4S_ACLK         (ACLK),
           .AXI4S_IACLK        (ACLK),
           .AXI4S_TACLK        (ACLK),
           .AXI4S_ARESETN      (cfifo_rst),
           .AXI4S_IARESETN     (cfifo_rst),
           .AXI4S_TARESETN     (cfifo_rst),
           .AXI4S_ITREADY      (post_hold_rd_en_cmd_intr),
           .AXI4S_ITVALID      (wrcmdintrfifo_itvld),
           .AXI4S_ITDATA       ({fixed_flag_out_intr, addr_out_intr, awsize_out_intr, extend_out_intr, wrap_flag_out_intr, awlen_intr_out_intr, to_wrap_boundary_out_intr}),
           .AXI4S_TTVALID      (wr_en_cmd ),
           .AXI4S_TTDATA       ({fixed_flag, awaddr_intr, awsize_intr, extend_tx, wrap_flag, awlen_intr, to_wrap_boundary_initiator} ),
           .ALMOST_FULL        (wrcmdintrfifo_ttrdy)
        );
		
        assign wr_cmd_intr_fifo_full  = wrcmdintrfifo_ttrdy;
        assign wr_cmd_intr_fifo_empty = ~wrcmdintrfifo_itvld;

        caxi4c_coreaxi4s_fifo #
        (
           .RESET_TYPE         (SYNC_RESET),//
           .SYNC               (1),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
           .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
           .ECC                (0),// 0: ECC disable , 1: ECC enable
           .RAM_TYPE           (DWC_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
           .NUM_STAGES         (0),// To select number of synchronizer stages.
           .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
           .WFIFO_DEPTH        (FIFO_SIZE),
           .RFIFO_DEPTH        (FIFO_SIZE),
           .AXIS_TTDATA_WIDTH  (8), // Bytes
           .AXIS_ITDATA_WIDTH  (8),  // Bytes
           .AXIS_TTID_WIDTH    (1), // Bits
           .AXIS_ITID_WIDTH    (1), // Bits
           .AXIS_TTDEST_WIDTH  (1), // Bits
           .AXIS_ITDEST_WIDTH  (1), // Bits
           .AXIS_TTUSER_WIDTH  (1), // Bits
           .AXIS_ITUSER_WIDTH  (1), // Bits
           .ENABLE_AFULL       (1),
           .AFULL_THR          (FIFO_SIZE-1),
           .ENABLE_TSTRB       (0),
           .ENABLE_TKEEP       (0),
           .ENABLE_TLAST       (0),
           .ENABLE_TUSER       (0),
           .ENABLE_TDEST       (0),
           .ENABLE_TID         (0),
           .EOP_OFFSET         (0)
        ) wr_cmd_trgt_fwft
        (
           .AXI4S_ACLK         (ACLK),
           .AXI4S_IACLK        (ACLK),
           .AXI4S_TACLK        (ACLK),
           .AXI4S_ARESETN      (cfifo_rst),
           .AXI4S_IARESETN     (cfifo_rst),
           .AXI4S_TARESETN     (cfifo_rst),
           .AXI4S_ITREADY      (rd_en_cmd_trgt),
           .AXI4S_ITDATA       (curr_awlen_trgt ),
           .AXI4S_TTVALID      (wr_en_cmd ),
           .AXI4S_TTDATA       (awlen_trgt),
           .ALMOST_FULL        (wrcmdtrgtfifo_ttrdy)
        );
		
        assign wr_cmd_trgt_fifo_full  = wrcmdtrgtfifo_ttrdy;
        	  
	end else begin 
	  caxi4interconnect_FIFO #
	  	(
	  		.MEM_DEPTH( ADDR_FIFO_DEPTH ),
	  		.DATA_WIDTH_IN ( 1 + 6 + 3 + 1 + 1 + 8 + 5),
	  		.DATA_WIDTH_OUT ( 1 + 6 + 3 + 1 + 1 + 8  + 5), 
	  		.NEARLY_FULL_THRESH ( ADDR_FIFO_DEPTH  -1 ),
	  		.NEARLY_EMPTY_THRESH ( 0 )
	  	)
	  wr_cmd_intr (
	  		.arst (arst_sync ),
	  		.srst (srst_sync ),
	  		.clk ( ACLK ),
	  		.wr_en ( wr_en_cmd ),
	  		.rd_en ( post_hold_rd_en_cmd_intr ),
	  		.data_in ( {fixed_flag, awaddr_intr, awsize_intr, extend_tx, wrap_flag, awlen_intr, to_wrap_boundary_initiator} ),
	  		.data_out ( {fixed_flag_out_intr, addr_out_intr, awsize_out_intr, extend_out_intr, wrap_flag_out_intr, awlen_intr_out_intr, to_wrap_boundary_out_intr} ),
	  		.zero_data ( 1'b0 ),
	  		.fifo_full (  ),
	  		.fifo_empty ( wr_cmd_intr_fifo_empty ),
	  		.fifo_nearly_full ( wr_cmd_intr_fifo_full ),
	  		.fifo_nearly_empty ( ),
	  		.fifo_one_from_full ( )
	  );
	  
	  caxi4interconnect_FIFO #
	  	(
	  		.MEM_DEPTH( ADDR_FIFO_DEPTH ),
 	  		.DATA_WIDTH_IN ( 8 ),
	  		.DATA_WIDTH_OUT ( 8 ), 
	  		.NEARLY_FULL_THRESH ( ADDR_FIFO_DEPTH -1 ),
	  		.NEARLY_EMPTY_THRESH ( 1 )
	  	)
	  wr_cmd_trgt (
	  		.arst (arst_sync ),
	  		.srst (srst_sync ),
	  		.clk ( ACLK ),
	  		.wr_en ( wr_en_cmd ),
	  		.rd_en ( rd_en_cmd_trgt ),
	  		.data_in ( awlen_trgt ),
	  		.data_out ( curr_awlen_trgt ),
	  		.zero_data ( 1'b0 ),
	  		.fifo_full (  ),
	  		.fifo_empty (  ),
	  		.fifo_nearly_full ( wr_cmd_trgt_fifo_full ),
	  		.fifo_nearly_empty (  ),
	  		.fifo_one_from_full (  )
	  );
    end 
endgenerate 
  caxi4interconnect_DWC_UpConv_WChan_Hold_Reg #
    (
      .DATA_WIDTH_IN   ( DATA_WIDTH_IN ),
      .USER_WIDTH      ( USER_WIDTH ),
      .DATA_WIDTH_OUT  ( DATA_WIDTH_OUT )
    )
  caxi4interconnect_DWC_UpConv_WChan_Hold_Reg
  (
    .clk( ACLK ), // INPUT
    .arst_sync( arst_sync ), // INPUT
    .srst_sync( srst_sync ), // INPUT

    // Hold Reg Ctrl sinals
    .DWC_UpConv_hold_fifo_empty    ( wr_cmd_intr_fifo_empty ), // INPUT
    .DWC_UpConv_hold_get_next_data ( rd_en_cmd_intr ), // INPUT

    .DWC_UpConv_hold_fifo_rd_en    ( post_hold_rd_en_cmd_intr ), // OUTPUT
    .DWC_UpConv_hold_reg_empty     ( wr_cmd_intr_hold_reg_empty ), // OUTPUT

    // Inputs to be decoded (from Initiator Cmd caxi4interconnect_FIFO) - going into this holding reg
    .to_boundary     ( to_wrap_boundary_out_intr ),    
    .addr            ( addr_out_intr ),
    .size            ( awsize_out_intr ),
    .wlen_intr        ( awlen_intr_out_intr ),
    .extend_tx       ( extend_out_intr ),
    .wrap_flag       ( wrap_flag_out_intr ),
    .fixed_flag      ( fixed_flag_out_intr ),

    // outputs
    .to_boundary_out     ( to_wrap_boundary_out_intr_hold ),
    .addr_out            ( addr_out_intr_hold ),
    .wlen_intr_out        ( awlen_intr_out_intr_hold ),
    .extend_tx_out       ( extend_out_intr_hold ),
    .wrap_flag_out       ( wrap_flag_out_intr_hold ),
    .fixed_flag_out      ( fixed_flag_out_intr_hold ),
    .size_out            ( awsize_out_intr_hold ),
    .size_shifted_out    ( size_shifted_out_intr_hold ),
    
    // Decoded outputs
    .mask_addr_out         ( mask_addr_hold ),
    .aligned_wrap_out      ( aligned_wrap_hold ),
    .second_wrap_burst_out ( second_wrap_burst_hold ),
    .extend_wrap_out       ( extend_wrap_hold ) 

  );

  caxi4interconnect_DWC_UpConv_Wchan_WriteDataFifoCtrl #
    (
      .DATA_WIDTH_IN   ( DATA_WIDTH_IN ),
      .USER_WIDTH      ( USER_WIDTH ),
      .DATA_WIDTH_OUT  ( DATA_WIDTH_OUT ),	  
	  .ID_WIDTH        ( ID_WIDTH)
    )
  WriteDataCtrl
  (
      .ACLK            ( ACLK ),
      .arst_sync        ( arst_sync ),
      .srst_sync        ( srst_sync ),
      .data_fifo_nearly_full  ( data_fifo_nearly_full ), // INPUT
      .cmd_fifo_empty  ( wr_cmd_intr_hold_reg_empty ),                // INPUT

      .wready          ( INITIATOR_WREADY ),
      .wvalid          ( INITIATOR_WVALID ),
      .beat_cnt        ( intr_beat_cnt ),
      .wlast           ( INITIATOR_WLAST ),
	  
      .size_shifted    ( size_shifted_out_intr_hold ),
	  .initiator_beat_cnt_shifted (initiator_beat_cnt_shifted),
	  .initiator_beat_cnt_to_boundary_shifted (initiator_beat_cnt_to_boundary_shifted),
	  .initiator_beat_cnt_eq_0 (initiator_beat_cnt_eq_0),
     
      .to_boundary     ( to_wrap_boundary_out_intr_hold ), // from hold
      .addr            ( addr_out_intr_hold ),                // from hold
      .wlen_intr        ( awlen_intr_out_intr_hold ),           // from hold
      .extend_tx       ( extend_out_intr_hold ),              // from hold
      .wrap_flag       ( wrap_flag_out_intr_hold ),           // from hold
      .fixed_flag      ( fixed_flag_out_intr_hold ),          // from hold
      .size            ( awsize_out_intr_hold ),              // from hold
      
      .incr_pkt_cnt    ( incr_pkt_cnt ),
      .wr_en           ( wr_en_data ),         
      .data_in         ( {INITIATOR_WID,INITIATOR_WUSER, INITIATOR_WSTRB, INITIATOR_WDATA} ),     // INPUT
      .data_out        ( fifo_data_in ),            // OUTPUT
      .zero_strb_data  ( zero_strb_data ),           // OUTPUT
      
      // Decoded Inputs
      .mask_addr         ( mask_addr_hold ),
      .aligned_wrap      ( aligned_wrap_hold ),
      .second_wrap_burst ( second_wrap_burst_hold ),
      .extend_wrap       ( extend_wrap_hold )
    
  );

	generate
		for (i=0; i<(CONV_RATIO); i=i+1) begin
			assign wdata_out [DATA_WIDTH_IN*i+:DATA_WIDTH_IN]          = fifo_data_out_reg[(FIFO_DATA_WIDTH_IN)*i+:DATA_WIDTH_IN];
			assign wstrb_out [(DATA_WIDTH_IN/8)*i+:(DATA_WIDTH_IN/8)]  = fifo_data_out_reg[((FIFO_DATA_WIDTH_IN)*i+DATA_WIDTH_IN)+:(DATA_WIDTH_IN/8)];
		end
	endgenerate
    
	assign wuser_out = fifo_data_out_reg[(FIFO_DATA_WIDTH_OUT) +: USER_WIDTH];
    assign wid_out   = fifo_data_out_reg[(FIFO_DATA_WIDTH_OUT+USER_WIDTH) +: ID_WIDTH];
	
	assign TARGET_WDATA = wdata_out;
	assign TARGET_WSTRB = wstrb_out;
	assign TARGET_WUSER = wuser_out;
    assign TARGET_WID   = wid_out;
	
  caxi4interconnect_DWC_UpConv_WChan_ReadDataFifoCtrl # 
   (
      .LOG_OPEN_TX( $clog2(ADDR_FIFO_DEPTH) ),
      .SIZE_OUT           ($clog2(DATA_WIDTH_OUT/8))
   )
  wr_sys_ctrl 
   (
      .TARGET_WREADY       ( TARGET_WREADY ),
      .TARGET_WLAST        ( TARGET_WLAST ),
      .TARGET_WVALID       ( TARGET_WVALID ),
      .TARGET_WLEN         ( curr_awlen_trgt ),
      .extend_tx          ( extend_out_intr_hold ),// from hold
      .wrap_flag_intr      ( wrap_flag_out_intr_hold ),// from hold
      .ACLK               ( ACLK ),
      .INITIATOR_WVALID      ( INITIATOR_WVALID ),
      .INITIATOR_WLAST       ( INITIATOR_WLAST ),
      .INITIATOR_WREADY      ( INITIATOR_WREADY ),
      .data_fifo_nearly_full     ( data_fifo_nearly_full ), /////////////////////////////////////////////
      .arst_sync           ( arst_sync ),
      .srst_sync           ( srst_sync ),
      .fifo_nearly_empty  ( data_fifo_nearly_empty ), // Hold off trandmitting data if level of data in caxi4interconnect_FIFO is below this threshold
      .fifo_empty         ( data_fifo_empty ),
      .size            ( awsize_out_intr_hold ),              // from hold
      .incr_pkt_cnt       ( incr_pkt_cnt ),
      .initiator_beat_cnt    ( intr_beat_cnt ),
      .pass_data          ( pass_data ),
      .rd_en_data         ( rd_en_data ), 
      .rd_en_cmd_intr      ( rd_en_cmd_intr ), // output
      .rd_en_cmd_trgt      ( rd_en_cmd_trgt ),
      .cmd_fifo_empty     ( wr_cmd_intr_hold_reg_empty ),
	  .initiator_beat_cnt_eq_0 (initiator_beat_cnt_eq_0),
      .to_boundary        ( to_wrap_boundary_out_intr_hold ),
	  .initiator_beat_cnt_shifted (initiator_beat_cnt_shifted),
	  .initiator_beat_cnt_to_boundary_shifted (initiator_beat_cnt_to_boundary_shifted)
   );

endmodule
