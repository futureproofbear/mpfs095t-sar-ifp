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
// SVN $Revision: 46137 $
// SVN $Date: 2024-02-23 01:29:51 +0530 (Fri, 23 Feb 2024) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_TrgtAxi4ProtConvWrite #

	(
	
		parameter integer 	TARGET_NUMBER		        = 0,			//current target
		parameter [1:0] 	TARGET_TYPE			        = 2'b11,		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11	
		
		parameter integer 	ADDR_WIDTH      	        = 20,			// valid values - 16 - 64
		parameter integer 	DATA_WIDTH 			        = 32,			// valid widths - 32, 64, 128, 256
		
		parameter integer 	USER_WIDTH 			        = 1,			// defines the number of bits for USER signals RUSER and WUSER
	
		parameter integer 	ID_WIDTH   			        = 1,				// number of bits for ID (ie AID, WID, BID) - valid 1-8 
		parameter integer 	TRGT_AXI4PRT_ADDRDEPTH 		= 8,		// Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
		parameter integer 	TRGT_AXI4PRT_DATADEPTH		= 8,			// Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
		parameter integer 	MAX_TRANS           		= 8,			// Maximum transactions
		parameter           READ_INTERLEAVE             = 1,
	    parameter           PIPE                        = 1,
	    parameter           PROTOCONV_RAM_TYPE          = 3,
        parameter           SYNC_RESET                  = 0,
        parameter           DWC_ENABLED                 = 0             // 1 - DWC enabled, filter dummy (WSTRB=0) responses
	)
	(

	//=====================================  Global Signals   ========================================================================
	input  wire           			ACLK,
	input  wire          			arst_sync,
	input  wire          			srst_sync,
  // External side

	// Target Write Address Ports
	output wire [ID_WIDTH-1:0]   	TARGET_AWID,	
	output wire [ADDR_WIDTH-1:0] 	TARGET_AWADDR,
	output reg [3:0]    	       	TARGET_AWLEN,
	output wire [2:0]           	TARGET_AWSIZE,
	output wire [1:0]           	TARGET_AWBURST,
	output wire [1:0]            	TARGET_AWLOCK,
	output wire [3:0] 	         	TARGET_AWCACHE,
	output wire [2:0]           	TARGET_AWPROT,
	output reg	                 	TARGET_AWVALID,
	input wire                		TARGET_AWREADY,

	
	// Target Write Data Ports	
	output wire [ID_WIDTH-1:0]   	TARGET_WID,	
	output wire [DATA_WIDTH-1:0]  	TARGET_WDATA,
	output wire [(DATA_WIDTH/8)-1:0] TARGET_WSTRB,
	output reg                   	TARGET_WLAST,
	output reg                  	TARGET_WVALID,
	input wire                   	TARGET_WREADY,

			
	// Target Write Response Ports	
	input wire [ID_WIDTH-1:0]		TARGET_BID,
	input  wire [1:0]           	TARGET_BRESP,
	input  wire      				TARGET_BVALID,
	output reg						TARGET_BREADY,


	//================================================= Internal AXI4 Side Ports  ================================================//

	// Target Write Address Ports	
	input  wire [ID_WIDTH-1:0]   	int_targetAWID,
	input  wire [ADDR_WIDTH-1:0] 	int_targetAWADDR,
	input  wire [7:0]           	int_targetAWLEN,
	input  wire [2:0]           	int_targetAWSIZE,
	input  wire [1:0]           	int_targetAWBURST,
	input  wire [1:0]            	int_targetAWLOCK,
	input  wire [3:0]          		int_targetAWCACHE,
	input  wire [2:0]           	int_targetAWPROT,
	input  wire [3:0]           	int_targetAWREGION,
	input  wire [3:0]           	int_targetAWQOS,
	input  wire [USER_WIDTH-1:0] 	int_targetAWUSER,
	input  wire                  	int_targetAWVALID,
	output reg                		int_targetAWREADY,
	
	// Target Write Data Ports	
	input wire [ID_WIDTH-1:0]   	int_targetWID,
	input wire [DATA_WIDTH-1:0]   	int_targetWDATA,
	input wire [(DATA_WIDTH/8)-1:0]	int_targetWSTRB,
	input wire                   	int_targetWLAST,
	input wire [USER_WIDTH-1:0] 	int_targetWUSER,
	input wire                  	int_targetWVALID,
	output reg                  	int_targetWREADY,
	
	// Target Write Response Ports	
	output wire [ID_WIDTH-1:0]		int_targetBID,
	output wire [1:0]           	int_targetBRESP,
	output wire [USER_WIDTH-1:0]  	int_targetBUSER,
	output reg      				int_targetBVALID,
	input wire						int_targetBREADY

	);
	

	//================================== Local parameters ==============================
	
localparam	AWLEN_BITS	       = ( TARGET_TYPE == 2'b11 ) ? 4 : 8;			// AXI3 bursts brokwn into 16 beats or less, AXILite into single beat
localparam	[7:0] MAX_BEATS	       = ( TARGET_TYPE == 2'b11 ) ? 8'd16 : 8'd1;		// AXI3 max bursts beats 16, AXILite is 1	
localparam	integer DATA_WIDTH_BYTES_LOG_INT = $clog2(DATA_WIDTH/8);
localparam	[2:0] DATA_WIDTH_BYTES_LOG = DATA_WIDTH_BYTES_LOG_INT[2:0];
	localparam  WID_RAM_ADDR_WIDTH = (MAX_TRANS < 4) ? 2 : $clog2 (MAX_TRANS);
	localparam  WID_RAM_DEPTH      = (2 ** WID_RAM_ADDR_WIDTH);
	// Number of unique IDs for READ_INTERLEAVE=1 out-of-order B response tracking
	localparam NUM_IDS = (1 << ID_WIDTH);
    localparam [0:0] WGetData      = 1'b0;
    localparam [1:0] WSendData     = 2'b00;
	
	localparam [1:0] IdleAWrite    = 2'b00,	
	                 AWrite        = 2'b01, 
					 WaitFifoEmpty = 2'b10;
    localparam [0:0] Idle_WrResp   = 1'b0,	
	                 SendWrResp	   = 1'b1;					 
	
	
	//================================== Internal ==============================

	//Write ID+number of responses to combine caxi4interconnect_FIFO
/*	reg 					wrFifoIdRd;
	reg 					wrFifoIdWr;
	wire 					wrFifoIdFull;
	wire 					wrFifoIdEmpty;
	
	wire [ID_WIDTH-1:0]	wrIdFifDIn;				// AWID bits
	wire [ID_WIDTH-1:0]	wrIdFifDOut;			// AWID bits
*/
    //Write ID+number of responses to combine caxi4interconnect_FIFO
	reg 					wrFifoLenRd;
	reg 					wrFifoLenWr;
	wire 					wrFifoLenFull;
	wire 					wrFifoLenEmpty;
    
    // wire                    lastBurstOutstanding;       // jhayes : Used to indicate that ID caxi4interconnect_FIFO has only entry remaining.
     // bbriscoe: lastBurstOutstanding not needed, using latAxi3Long instead.
	
	wire [(ID_WIDTH+8-1):0]	wrLenFifDIn;			// AWLEN bits
	wire [(ID_WIDTH+8-1):0]	wrLenFifDOut;			// AWLEN bits 
	
	//Write Data + last caxi4interconnect_FIFO
	reg 					wrFifoDataRd;
	reg 					wrFifoDataWr;
	wire 					wrFifoDataFull;
	wire 					wrFifoDataEmpty;
	wire [(DATA_WIDTH/8)+DATA_WIDTH:0] 	wrDataFifDIn;  // WSTRB width + data width + last bit indication
	wire [(DATA_WIDTH/8)+DATA_WIDTH:0] 	wrDataFifDOut; // WSTRB width + data width + last bit indication

	// andreag: signals for correct WRAP burst address computation
	wire [10:0] wrap_nibble;
	wire [10:0] wrap_mask;

    wire        wid_mem_empty;
    wire        wid_mem_full;
	
	// Per-ID FIFO full signal for READ_INTERLEAVE=1 backpressure
	wire anyidfifofull;
	wire bfifo_backpressure;
	// Backpressure: for READ_INTERLEAVE=0, only check wrFifoLenFull
	// For READ_INTERLEAVE=1, also check per-ID FIFO full signals
	assign bfifo_backpressure = (READ_INTERLEAVE == 0) ? wrFifoLenFull : (wrFifoLenFull | anyidfifofull);
	
    // Dummy write beat tracking (WSTRB=0) - for DWC response filtering
    wire         current_beat_is_dummy;

  // Data & address timing control
    reg [4:0]   beatCnt;
    wire        wrlenfifo_itvld;
    wire        wrlenfifo_ttrdy;
    wire        wrdtfifo_ttrdy;
    wire        wrdtfifo_itvld;  	
    wire         cfifo_rst;
	
//========================= AWChan registers ==========================

	reg						latchAWAll;
	
	reg 					loadNumTrans;
	reg 					decrNumTrans;
	reg 					clearNumTrans;
	
	reg [AWLEN_BITS-1:0]	numTrans;
	
	reg [ID_WIDTH-1:0]		latAWID;
	reg [2:0]				latAWSIZE;
	reg [1:0]				latAWBURST;
	reg [1:0]				latAWLOCK;
	reg [3:0]				latAWCACHE;
	reg [2:0]				latAWPROT;
	reg [7:0]				latAWLEN;
	
	wire [3:0]				lastTransLen;		// only used in AXI3 target
	
	reg						loadAddrW;
	reg						incrAddrW;
	reg	[ADDR_WIDTH-1:0]	currentAddrW;
	
	//Address Write Channel States
	
	reg [1:0]				currStateAWr, nextStateAWr;
	
    reg                     setFirstTrans;
    reg                     clearFirstTrans;
    reg                     firstTrans;
	
//============================ WChan registers ====================================	
// Write Data Channel Get data from initiator States
//=================================================================================

	
	reg [0:0]				currStateWrGD, nextStateWrGD;
	
//============================ WChan registers ====================================	
//Write Data Channel Send data to target States
//=================================================================================

    reg [1:0]				WWaitEndBurst = 2'b01;
    reg [1:0]				WWaitRestartData = 2'b10;
    reg [1:0]				currStateWrSD, nextStateWrSD;
    	
    //WChan registers
    reg 					incrCountWrData;
    reg 					setCountWrData;
    reg [3:0]				countWrData;	
    	
    wire					W_last;
	
//============================ Response channel registers =============================
// Response Channel States
//=====================================================================================

    reg        [0:0]		currStateResp, nextStateResp;
    	
    // RespChan registers
    reg 					setResponseCombi; //combined response value
    reg						clearResponseCombi;
    reg [1:0] 				responseCombi;
    	
    reg [AWLEN_BITS-1:0]	countResp;
    reg						resetCountResp;
    reg						incrCountResp;
    
    // For out-of-order B response handling (READ_INTERLEAVE=1, TARGET_TYPE=AXI3):
    // active_resp_count    : per-ID counter in interleave mode, global counter otherwise
    // expected_resp_count  : per-ID FIFO output in interleave mode, wrLenFifDOut otherwise
    // resp_has_outstanding : per-ID FIFO !empty in interleave mode, !wrFifoLenEmpty otherwise
    wire [AWLEN_BITS-1:0]   active_resp_count;
    wire [AWLEN_BITS-1:0]   expected_resp_count;
    wire                    resp_has_outstanding;
    
    wire [ID_WIDTH-1:0] 		latBID_sel;	
    reg [ID_WIDTH-1:0] 		latBID;
    reg						setBID;
	
	
	

    assign       cfifo_rst = (SYNC_RESET == 0) ? arst_sync : srst_sync; 	

	//============================================================================				
	// Holds Write Address from Initiator. Used to decouple Initiator side from target
	// side by allowing caxi4interconnect_FIFO to hold multiple entries. Written on Address phase
	// but not popped unit Response complete.
	//=============================================================================

generate 
  if(PIPE > 0) begin 
    assign wrFifoLenFull  = ~wrlenfifo_ttrdy;
    assign wrFifoLenEmpty = ~wrlenfifo_itvld;	
    assign wrFifoDataFull  = ~wrdtfifo_ttrdy;
    assign wrFifoDataEmpty = ~wrdtfifo_itvld;	
	
	if(TRGT_AXI4PRT_ADDRDEPTH != 1) begin 
      caxi4c_coreaxi4s_fifo #
      (
         .RESET_TYPE         (SYNC_RESET),//
         .SYNC               (1),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
         .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
         .ECC                (0),// 0: ECC disable , 1: ECC enable
         .RAM_TYPE           (PROTOCONV_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
         .NUM_STAGES         (0),// To select number of synchronizer stages.
         .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
         .WFIFO_DEPTH        (TRGT_AXI4PRT_ADDRDEPTH),
         .RFIFO_DEPTH        (TRGT_AXI4PRT_ADDRDEPTH),
         .AXIS_TTDATA_WIDTH  (8+ID_WIDTH), // Bytes
         .AXIS_ITDATA_WIDTH  (8+ID_WIDTH),  // Bytes
         .AXIS_TTID_WIDTH    (1), // Bits
         .AXIS_ITID_WIDTH    (1), // Bits
         .AXIS_TTDEST_WIDTH  (1), // Bits
         .AXIS_ITDEST_WIDTH  (1), // Bits
         .AXIS_TTUSER_WIDTH  (1), // Bits
         .AXIS_ITUSER_WIDTH  (1), // Bits
         .ENABLE_AFULL       (0),
         .AFULL_THR          (2),
         .ENABLE_TSTRB       (0),
         .ENABLE_TKEEP       (0),
         .ENABLE_TLAST       (0),
         .ENABLE_TUSER       (0),
         .ENABLE_TDEST       (0),
         .ENABLE_TID         (0),
         .EOP_OFFSET         (0)
      ) wrLen_fwftFif
      (
         .AXI4S_ACLK         (ACLK),
         .AXI4S_IACLK        (ACLK),
         .AXI4S_TACLK        (ACLK),
         .AXI4S_ARESETN      (cfifo_rst),
         .AXI4S_IARESETN     (cfifo_rst),
         .AXI4S_TARESETN     (cfifo_rst),
         .AXI4S_ITREADY      (wrFifoLenRd),
         .AXI4S_ITVALID      (wrlenfifo_itvld),
         .AXI4S_ITDATA       (wrLenFifDOut),
         .AXI4S_TTVALID      (wrFifoLenWr),
         .AXI4S_TTDATA       (wrLenFifDIn),
         .AXI4S_TTREADY      (wrlenfifo_ttrdy)
      );
	end else begin 

	  caxi4interconnect_RegisterSlice #
	  
	  	(
	  		.AWCHAN	                ( 1'b1                 ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ARCHAN	                ( 1'b0                 ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.RCHAN	                ( 1'b0                 ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.WCHAN	                ( 1'b0                 ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.BCHAN	                ( 1'b0                 ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ID_WIDTH   			( ID_WIDTH             ), 
	  		.ADDR_WIDTH      		( 1'b1                 ),
	  		.DATA_WIDTH 			( 1                    ), 
	  		.SUPPORT_USER_SIGNALS 	( 1'b0                 ),
	  		.USER_WIDTH 			( 1'b1                 ),
	  		.READY_REG   			( 1'b0                 )
	  	)
	  	wrLen_rgsl(
	        .sysClk	                    ( ACLK                                           ),
	        .arst_sync	                ( arst_sync                                      ),
	        .srst_sync	                ( srst_sync                                      ),	  
	        
	        
	        .srcAWID                    ( latAWID                                        ),
	        .srcAWADDR                  ( 0                                              ),
	        .srcAWLEN                   ( latAWLEN                                       ),
	        .srcAWSIZE                  ( 0                                              ),
	        .srcAWBURST                 ( 0                                              ),
	        .srcAWLOCK                  ( 0                                              ),
	        .srcAWCACHE                 ( 0                                              ),
	        .srcAWPROT                  ( 0                                              ),
	        .srcAWREGION                ( 0                                              ),
	        .srcAWQOS                   ( 0                                              ),
  	        .srcAWUSER                  ( 0                                              ),
	        .srcAWVALID                 ( wrFifoLenWr                                    ),
	        .srcAWREADY                 ( wrlenfifo_ttrdy                                ),
	        
	        .dstAWID                    ( wrLenFifDOut[ID_WIDTH+8-1:8]                   ),
	        .dstAWADDR                  (                                                ),
	        .dstAWLEN                   ( wrLenFifDOut[7:0]                              ),
	        .dstAWSIZE                  (                                                ),
	        .dstAWBURST                 (                                                ),
	        .dstAWLOCK                  (                                                ),
	        .dstAWCACHE                 (                                                ),
	        .dstAWPROT                  (                                                ),
	        .dstAWREGION                (                                                ),
	        .dstAWQOS                   (                                                ),
	        .dstAWUSER                  (                                                ),
	        .dstAWVALID                 ( wrlenfifo_itvld                                ),
	        .dstAWREADY                 ( wrFifoLenRd                                    )
	  	);	
	end 
    if(TRGT_AXI4PRT_DATADEPTH != 1) begin 
      caxi4c_coreaxi4s_fifo #
      (
         .RESET_TYPE         (SYNC_RESET),//
         .SYNC               (1),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
         .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
         .ECC                (0),// 0: ECC disable , 1: ECC enable
         .RAM_TYPE           (PROTOCONV_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
         .NUM_STAGES         (0),// To select number of synchronizer stages.
         .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
         .WFIFO_DEPTH        (TRGT_AXI4PRT_DATADEPTH),
         .RFIFO_DEPTH        (TRGT_AXI4PRT_DATADEPTH),
         .AXIS_TTDATA_WIDTH  ((DATA_WIDTH/8)+DATA_WIDTH+1), // Bytes
         .AXIS_ITDATA_WIDTH  ((DATA_WIDTH/8)+DATA_WIDTH+1),  // Bytes
         .AXIS_TTID_WIDTH    (1), // Bits
         .AXIS_ITID_WIDTH    (1), // Bits
         .AXIS_TTDEST_WIDTH  (1), // Bits
         .AXIS_ITDEST_WIDTH  (1), // Bits
         .AXIS_TTUSER_WIDTH  (1), // Bits
         .AXIS_ITUSER_WIDTH  (1), // Bits
         .ENABLE_AFULL       (0),
         .AFULL_THR          (2),
         .ENABLE_TSTRB       (0),
         .ENABLE_TKEEP       (0),
         .ENABLE_TLAST       (0),
         .ENABLE_TUSER       (0),
         .ENABLE_TDEST       (0),
         .ENABLE_TID         (0),
         .EOP_OFFSET         (0)
      ) wrData_fwftFif
      (
         .AXI4S_ACLK         (ACLK),
         .AXI4S_IACLK        (ACLK),
         .AXI4S_TACLK        (ACLK),
         .AXI4S_ARESETN      (cfifo_rst),
         .AXI4S_IARESETN     (cfifo_rst),
         .AXI4S_TARESETN     (cfifo_rst),
         .AXI4S_ITREADY      (wrFifoDataRd),
         .AXI4S_ITVALID      (wrdtfifo_itvld),
         .AXI4S_ITDATA       (wrDataFifDOut),
         .AXI4S_TTVALID      (wrFifoDataWr),
         .AXI4S_TTDATA       (wrDataFifDIn),
         .AXI4S_TTREADY      (wrdtfifo_ttrdy)
      );
	end else begin 
	  caxi4interconnect_RegisterSlice #
	  
	  	(
	  		.AWCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ARCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.RCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.WCHAN	                ( 1'b1                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.BCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ID_WIDTH   			( 1'b1                         ), 
	  		.ADDR_WIDTH      		( 1'b1                         ),
	  		.DATA_WIDTH 			( DATA_WIDTH                   ), 
	  		.SUPPORT_USER_SIGNALS 	( 1'b0                         ),
	  		.USER_WIDTH 			( 1'b1                         ),
	  		.READY_REG   			( 1'b0                         )
	  	)
	  	wrData_rgsl(
	  
	  			//=====================================  Global Signals   =====================================================
	  			.sysClk	    ( ACLK                                                      ),
	  			.arst_sync	( arst_sync                                                 ),
	  			.srst_sync	( srst_sync                                                 ),	  
															                            
	  			// Write Data Channel	                                                
	  			.srcWID	    ( 0                                                         ),
	  			.srcWDATA	( wrDataFifDIn[DATA_WIDTH-1+1:1]                            ),
	  			.srcWSTRB	( wrDataFifDIn[(DATA_WIDTH/8)+DATA_WIDTH-1+1:DATA_WIDTH+1]  ),
	  			.srcWLAST	( wrDataFifDIn[0]                                           ),
	  			.srcWUSER	( 0                                                         ),
	  			.srcWVALID	( wrFifoDataWr                                              ),
	  			.srcWREADY	( wrdtfifo_ttrdy                                            ),
	  
	            .dstWID     (                                                           ),
	  			.dstWDATA	( wrDataFifDOut[DATA_WIDTH-1+1:1]                           ),
	  			.dstWSTRB	( wrDataFifDOut[(DATA_WIDTH/8)+DATA_WIDTH-1+1:DATA_WIDTH+1] ),
	  			.dstWLAST	( wrDataFifDOut[0]                                          ),
	  			.dstWUSER	(                                                           ),
	  			.dstWVALID	( wrdtfifo_itvld                                            ),
	  			.dstWREADY	( wrFifoDataRd                                              )	  
        );	
	end   
  end else begin     
    if(TRGT_AXI4PRT_ADDRDEPTH != 1) begin 
      caxi4interconnect_FifoDualPort #	(	.FIFO_AWIDTH( $clog2(TRGT_AXI4PRT_ADDRDEPTH) ),		// depth of holding buffer 2^TRGT_AXI4PRT_ADDRDEPTH
	  					.FIFO_WIDTH	( 8+ID_WIDTH ),		// Storing AWLEN[7:0] - so burst can be broken into smaller bursts 
	  					.HI_FREQ	( 1'b0 )						
	  				)
	  	wrLenFif(
	  				.HCLK		 ( ACLK ),
	  				.fifo_areset ( arst_sync ),
	  				.fifo_sreset ( srst_sync ),
	  
	  				// Write Port
	  				.fifoWrite	( wrFifoLenWr ),
	  				.fifoWrData	( wrLenFifDIn ),
	  
	  				// Read Port
	  				.fifoRead	( wrFifoLenRd ),
	  				.fifoRdData	( wrLenFifDOut ),
	  				
	  				// Status bits
	  				.fifoEmpty	( wrFifoLenEmpty ) ,
	  				.fifoOneAvail( ),
	  				.fifoRdValid ( ),
	  				.fifoFull	( wrFifoLenFull ),
	  				.fifoNearFull( ),
	  				.fifoOverRunErr( ),
	  				.fifoUnderRunErr( ) 
	  			);
	end else begin 
      assign wrFifoLenFull  = ~wrlenfifo_ttrdy;
      assign wrFifoLenEmpty = ~wrlenfifo_itvld;		
	  caxi4interconnect_RegisterSlice #
	  
	  	(
	  		.AWCHAN	                ( 1'b1                 ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ARCHAN	                ( 1'b0                 ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.RCHAN	                ( 1'b0                 ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.WCHAN	                ( 1'b0                 ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.BCHAN	                ( 1'b0                 ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ID_WIDTH   			( ID_WIDTH             ), 
	  		.ADDR_WIDTH      		( 1'b1                 ),
	  		.DATA_WIDTH 			( 1                    ), 
	  		.SUPPORT_USER_SIGNALS 	( 1'b0                 ),
	  		.USER_WIDTH 			( 1'b1                 ),
	  		.READY_REG   			( 1'b0                 )
	  	)
	  	wrLen_rgsl(
	        .sysClk	                    ( ACLK                                           ),
	        .arst_sync	                ( arst_sync                                      ),
	        .srst_sync	                ( srst_sync                                      ),	  
	        
	        
	        .srcAWID                    ( latAWID                                        ),
	        .srcAWADDR                  ( 0                                              ),
	        .srcAWLEN                   ( latAWLEN                                       ),
	        .srcAWSIZE                  ( 0                                              ),
	        .srcAWBURST                 ( 0                                              ),
	        .srcAWLOCK                  ( 0                                              ),
	        .srcAWCACHE                 ( 0                                              ),
	        .srcAWPROT                  ( 0                                              ),
	        .srcAWREGION                ( 0                                              ),
	        .srcAWQOS                   ( 0                                              ),
  	        .srcAWUSER                  ( 0                                              ),
	        .srcAWVALID                 ( wrFifoLenWr                                    ),
	        .srcAWREADY                 ( wrlenfifo_ttrdy                                ),
	        
	        .dstAWID                    ( wrLenFifDOut[ID_WIDTH+8-1:8]                   ),
	        .dstAWADDR                  (                                                ),
	        .dstAWLEN                   ( wrLenFifDOut[7:0]                              ),
	        .dstAWSIZE                  (                                                ),
	        .dstAWBURST                 (                                                ),
	        .dstAWLOCK                  (                                                ),
	        .dstAWCACHE                 (                                                ),
	        .dstAWPROT                  (                                                ),
	        .dstAWREGION                (                                                ),
	        .dstAWQOS                   (                                                ),
	        .dstAWUSER                  (                                                ),
	        .dstAWVALID                 ( wrlenfifo_itvld                                ),
	        .dstAWREADY                 ( wrFifoLenRd                                    )
	  	);
	end 
                  
	if(TRGT_AXI4PRT_DATADEPTH != 1) begin   	
	  	//==========================================================================				
	  	// Data caxi4interconnect_FIFO to decouple Initiator from Target sides. Initiator writes in an
	  	// target reads out - can be operating on different "burst"
	  	//==========================================================================
	  	caxi4interconnect_FifoDualPort #(	.FIFO_AWIDTH( $clog2(TRGT_AXI4PRT_DATADEPTH) ),
	  					.FIFO_WIDTH	( (DATA_WIDTH/8)+DATA_WIDTH+1 ),
	  					.HI_FREQ 	( 1'b0 )
	  					)
	  	wrDataFif(
	  				.HCLK( ACLK ),
	  				.fifo_areset ( arst_sync ),
	  				.fifo_sreset ( srst_sync ),
	  
	  				// Write Port
	  				.fifoWrite( wrFifoDataWr ),
	  				.fifoWrData( wrDataFifDIn ),
	  
	  				// Read Port
	  				.fifoRead( wrFifoDataRd ),
	  				.fifoRdData( wrDataFifDOut),
	  				
	  				// Status bits
	  				.fifoEmpty ( wrFifoDataEmpty ) ,
	  				.fifoOneAvail( ),
	  				.fifoRdValid ( ),
	  				.fifoFull( wrFifoDataFull ),
	  				.fifoNearFull( ),
	  				.fifoOverRunErr( ),
	  				.fifoUnderRunErr( )
	  			   
	  			);   
	end else begin 
      assign wrFifoDataFull  = ~wrdtfifo_ttrdy;
      assign wrFifoDataEmpty = ~wrdtfifo_itvld;		
	  caxi4interconnect_RegisterSlice #
	  
	  	(
	  		.AWCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ARCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.RCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.WCHAN	                ( 1'b1                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.BCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ID_WIDTH   			( 1'b1                         ), 
	  		.ADDR_WIDTH      		( 1'b1                         ),
	  		.DATA_WIDTH 			( DATA_WIDTH                   ), 
	  		.SUPPORT_USER_SIGNALS 	( 1'b0                         ),
	  		.USER_WIDTH 			( 1'b1                         ),
	  		.READY_REG   			( 1'b0                         )
	  	)
	  	wrData_rgsl(
	  
	  			//=====================================  Global Signals   =====================================================
	  			.sysClk	    ( ACLK                                                      ),
	  			.arst_sync	( arst_sync                                                 ),
	  			.srst_sync	( srst_sync                                                 ),	  
															                            
	  			// Write Data Channel	                                                
	  			.srcWID	    ( 0                                                         ),
	  			.srcWDATA	( wrDataFifDIn[DATA_WIDTH-1+1:1]                            ),
	  			.srcWSTRB	( wrDataFifDIn[(DATA_WIDTH/8)+DATA_WIDTH-1+1:DATA_WIDTH+1]  ),
	  			.srcWLAST	( wrDataFifDIn[0]                                           ),
	  			.srcWUSER	( 0                                                         ),
	  			.srcWVALID	( wrFifoDataWr                                              ),
	  			.srcWREADY	( wrdtfifo_ttrdy                                            ),
	  
	            .dstWID     (                                                           ),
	  			.dstWDATA	( wrDataFifDOut[DATA_WIDTH-1+1:1]                           ),
	  			.dstWSTRB	( wrDataFifDOut[(DATA_WIDTH/8)+DATA_WIDTH-1+1:DATA_WIDTH+1] ),
	  			.dstWLAST	( wrDataFifDOut[0]                                          ),
	  			.dstWUSER	(                                                           ),
	  			.dstWVALID	( wrdtfifo_itvld                                            ),
	  			.dstWREADY	( wrFifoDataRd                                              )	  
        );	
	end 
  end
endgenerate
	
//=========================================================================== 

assign TARGET_AWID 		= READ_INTERLEAVE ? ((TARGET_TYPE == 2'b01) ? {ID_WIDTH{1'b0}} : latAWID) : {ID_WIDTH{1'b0}};
assign TARGET_AWSIZE 	= (TARGET_TYPE == 2'b01) ? DATA_WIDTH_BYTES_LOG : latAWSIZE;
assign TARGET_AWBURST 	= latAWBURST;
assign TARGET_AWLOCK 	= latAWLOCK;
assign TARGET_AWCACHE 	= latAWCACHE;
assign TARGET_AWPROT 	= latAWPROT;
assign TARGET_AWADDR 	= currentAddrW;

// bbriscoe: USing latched versions as we've moved caxi4interconnect_FIFO writing to second state (When TARGET_AWREADY = 1)
assign wrLenFifDIn 		= { latAWID, latAWLEN};    // Save AWLEN to be used to drive out in bursts to target. 
//assign wrIdFifDIn 		= latAWID;		// Save AWID to be used to drive out in bursts to target.

assign wrap_nibble = 11'h00f << latAWSIZE;
assign wrap_mask = ({7'b0000000, lastTransLen} << latAWSIZE);

//===========================================================================
// Address recalculation
//===========================================================================
always @(posedge ACLK or negedge arst_sync )
	begin	
		if (~arst_sync | ~srst_sync )
			begin
				currentAddrW <= 0;
			end
		else if (loadAddrW)
			begin
				currentAddrW <= int_targetAWADDR;
			end
		else if (incrAddrW)
			begin
				//====================================================================		
				// Compute address based on Burst-type and address alginment
				// Fixed =00, Incr=01, Wrap =10 - Wrap not handled as not needed
				// for AXI3 and makes no sense for AXI4Lite (Caches not used here)
				//======================================================================			
				if ( latAWBURST == 2'b00 )			// Fixed type burst
					begin
						currentAddrW	<= currentAddrW;		// all beats use the same address.
					end
				else if (( latAWBURST == 2'b10 ) && (TARGET_TYPE == 2'b01))
					begin
						if ((currentAddrW[10:0] & wrap_mask) == (wrap_mask & wrap_nibble)) begin
						        currentAddrW <= {currentAddrW[ADDR_WIDTH-1:11], (currentAddrW[10:0] & ~wrap_mask)};
					        end else begin
					currentAddrW <= currentAddrW + ({ { (ADDR_WIDTH-1){1'b0} }, 1'b1 } << latAWSIZE); // AXI4-Lite burst length is always 1
						end
					end
				else	
					begin
						/// compute bytes sent in burst - handle mis-aligned
						case (latAWSIZE)
							3'd0	: currentAddrW <= currentAddrW + MAX_BEATS;
							3'd1	: currentAddrW <= { currentAddrW[ADDR_WIDTH-1:1] + MAX_BEATS, 1'd0 };
							3'd2	: currentAddrW <= { currentAddrW[ADDR_WIDTH-1:2] + MAX_BEATS, 2'd0 };
							3'd3	: currentAddrW <= { currentAddrW[ADDR_WIDTH-1:3] + MAX_BEATS, 3'd0 };
							3'd4	: currentAddrW <= { currentAddrW[ADDR_WIDTH-1:4] + MAX_BEATS, 4'd0 };
							3'd5	: currentAddrW <= { currentAddrW[ADDR_WIDTH-1:5] + MAX_BEATS, 5'd0 };
							3'd6	: currentAddrW <= { currentAddrW[ADDR_WIDTH-1:6] + MAX_BEATS, 6'd0 };
							3'd7	: currentAddrW <= { currentAddrW[ADDR_WIDTH-1:7] + MAX_BEATS, 7'd0 };
						endcase
					end
			end
		else 
			begin
				currentAddrW <= currentAddrW;
			end
	end	

	
//========================================================================	
// numTrans indicates how many burst to be done
//========================================================================
always @(posedge ACLK or negedge arst_sync)
	begin
		if (~arst_sync | ~srst_sync )
			begin
				numTrans <= 0;
			end
		else if ( clearNumTrans )
			begin
				numTrans <= 0;
			end			
		else if ( loadNumTrans )
			begin
				numTrans <= int_targetAWLEN[7:8-AWLEN_BITS];
			end
		else if ( decrNumTrans )
			begin
				numTrans <= numTrans - 1'b1;
			end
		else 
			begin
				numTrans <= numTrans;
			end
	end	
	
	
//===========================================================================
// Latch the data for re-transaction 
//===========================================================================
always @(posedge ACLK or negedge arst_sync)
	begin
	
		if (~arst_sync | ~srst_sync )
			begin
				latAWID 	<= 0;
				latAWSIZE 	<= 0;
				latAWBURST 	<= 0;
				latAWLOCK 	<= 0;
				latAWCACHE 	<= 0;
				latAWPROT   <= 0;
                latAWLEN    <= 0;
			end
		else if ( latchAWAll )
			begin
				latAWID 	<= int_targetAWID;
				latAWSIZE 	<= int_targetAWSIZE;
				latAWBURST 	<= int_targetAWBURST;
				latAWLOCK 	<= int_targetAWLOCK;
				latAWCACHE 	<= int_targetAWCACHE;
				latAWPROT 	<= int_targetAWPROT;
                latAWLEN    <= int_targetAWLEN;
			end
	
	end	

assign lastTransLen = latAWLEN[3:0]; // bbriscoe: Only need bottom 4 bits for last tx, all others will be 16
		
//==============================================================================
// Address Write channel from AXI4 port (XBAR) State Machine	
//==============================================================================
 always @(posedge ACLK or negedge arst_sync )
	begin
		if (~arst_sync | ~srst_sync )
			begin
				currStateAWr <= IdleAWrite;
        firstTrans <= 0;
			end
		else
			begin
      
				currStateAWr <= nextStateAWr;
        
        if(setFirstTrans) firstTrans <= 1;
        if(clearFirstTrans) firstTrans <= 0;
 
			end
			
	end
 

 
 // Code generated by MCHP Chatbot
always @(*)
    begin
        int_targetAWREADY   = 0;
        wrFifoLenWr        = 0;
        latchAWAll         = 0;
        loadAddrW          = 0;
        loadNumTrans       = 0;
        clearNumTrans      = 0;
        incrAddrW          = 0;
        decrNumTrans       = 0;
        TARGET_AWLEN[3:0]  = 0;     // only used in AXI3 - AXILite does not use TARGET_AWLEN
        TARGET_AWVALID     = 0;

        setFirstTrans      = 0;
        clearFirstTrans    = 0;

        nextStateAWr       = currStateAWr;

        case( currStateAWr )
            IdleAWrite:
                begin
                    if (int_targetAWVALID)
                        begin
                            // bfifo_backpressure includes wrFifoLenFull and anyidfifofull for interleave mode
                            if (!bfifo_backpressure & !wid_mem_full) 
                                begin
                                    int_targetAWREADY    = 1'b1;
                                    loadAddrW           = 1'b1;
                                    latchAWAll          = 1'b1;
                                    loadNumTrans        = 1'b1;            
                                    // wrFifoIdWr       = 1'b1;

                                    nextStateAWr        = AWrite;
                                    setFirstTrans       = 1; // bbriscoe: setting for the first transaction
                                end
                        end
                end
            AWrite:
                begin
                    if (TARGET_AWREADY & firstTrans & !wid_mem_full)
                        begin
                            // wrFifoIdWr       = 1'b1; // bbriscoe: Delaying writing to the caxi4interconnect_FIFO until TARGET_WREADY is asserted.
                            wrFifoLenWr        = 1'b1; // bbriscoe: Delaying writing to the caxi4interconnect_FIFO until TARGET_WREADY is asserted.
                            clearFirstTrans    = 1; // bbriscoe: cleared after writing the to the caxi4interconnect_FIFO
                        end
                    if ( numTrans == 0 )    //last transfer in the burst
                        begin
                            TARGET_AWLEN[3:0] = lastTransLen;    // only used in AXI3 - AXILite does not use TARGET_AWLEN
                            //TARGET_AWVALID  = 1'b1;
                            TARGET_AWVALID    = !wid_mem_full;

                            if (TARGET_AWREADY & !wid_mem_full)
                                begin
                                    clearNumTrans    = 1'b1;                      
                                    nextStateAWr     = IdleAWrite;
                                end
                        end
                    else //Not the last transfer burst
                        begin
                            TARGET_AWLEN[3:0] = 4'b1111;         // only used in AXI3 - AXILite does not use TARGET_AWLEN
                            //TARGET_AWVALID  = 1'b1;
                            TARGET_AWVALID    = !wid_mem_full;

                            if (TARGET_AWREADY & !wid_mem_full)
                                begin
                                    incrAddrW       = 1'b1;
                                    decrNumTrans    = 1'b1;            
                                end
                        end
                end

            WaitFifoEmpty:      // jhayes : Waiting in this state for Len caxi4interconnect_FIFO to empty in the case of large AXI3 transactions.
                begin
                    if(wrFifoLenEmpty)
                        begin
                            nextStateAWr = IdleAWrite;
                        end
                end
            default:
                begin        
                  int_targetAWREADY  = 0;
                  wrFifoLenWr        = 0;
                  latchAWAll         = 0;
                  loadAddrW          = 0;
                  loadNumTrans       = 0;
                  clearNumTrans      = 0;
                  incrAddrW          = 0;
                  decrNumTrans       = 0;
                  TARGET_AWLEN[3:0]  = 0;     // only used in AXI3 - AXILite does not use TARGET_AWLEN
                  TARGET_AWVALID     = 0;
                  setFirstTrans      = 0;
                  clearFirstTrans    = 0;
                  nextStateAWr       = currStateAWr;
                end

        endcase

    end	
	

//==================== ============================ ========================

assign wrDataFifDIn = {int_targetWSTRB, int_targetWDATA, int_targetWLAST};  //Write Data stored in wrDataFifo


//=================================================================================
// Data Write channel State Machine (store data from initiator)
//=================================================================================
always @(posedge ACLK or negedge arst_sync )
	begin
	
		if (~arst_sync | ~srst_sync )
			begin
				currStateWrGD <= WGetData;
			end
		else
			begin
				currStateWrGD <= nextStateWrGD;
			end
	end
 
 
 always @(*)
    begin
        int_targetWREADY = 1'b0;
        wrFifoDataWr     = 1'b0;
        nextStateWrGD    = currStateWrGD;

        case( currStateWrGD )
            WGetData:
                begin
                    if ( int_targetWVALID )
                        begin
                            if ( !wrFifoDataFull )
                                begin
                                    wrFifoDataWr    = 1'b1;
                                    int_targetWREADY = 1'b1;
                                end
                        end
                end
            default:
                begin
                  int_targetWREADY = 1'b0;
                  wrFifoDataWr     = 1'b0;
                  nextStateWrGD    = currStateWrGD;
                end

        endcase

    end
	

//=================================================================================

// assign W_last = ( TARGET_TYPE == 2'b11 ) ? wrDataFifDOut[0] : 1'b1;		// For AXILite 1- beat so always W_last - to help trim logic for AXI4Lite
assign W_last = wrDataFifDOut[0]; 
assign TARGET_WSTRB 	= wrDataFifDOut[(DATA_WIDTH/8)+DATA_WIDTH:DATA_WIDTH+1];
assign TARGET_WDATA 	= wrDataFifDOut[DATA_WIDTH:1];



//=================================================================================
// Counter to assert target WLAST at correct time
//=================================================================================
always @(posedge ACLK or negedge arst_sync )
	begin
		if (~arst_sync | ~srst_sync )
			begin
				countWrData <= 4'b0000;
			end
		else if ( setCountWrData )
			begin
				countWrData <= 4'b0000;
			end
		else if (incrCountWrData)
			begin
				countWrData <= countWrData + 1'b1;
			end
		else 
			begin
				countWrData <= countWrData;
			end
	end	

	
//=================================================================================
// Data Write channel State Machine (send data to target)
//=================================================================================
always @(posedge ACLK or negedge arst_sync )
	begin
		if (~arst_sync | ~srst_sync )
			begin
				currStateWrSD <= WSendData;
			end
		else
			begin
				currStateWrSD <= nextStateWrSD;
			end
			
	end
 
 
 always @(*)
    begin
        TARGET_WLAST    = 0;
        TARGET_WVALID   = 0;
        wrFifoDataRd    = 0;
        setCountWrData  = 0;
        incrCountWrData = 0;
        nextStateWrSD   = currStateWrSD;

        case( currStateWrSD )
            WSendData:
                begin
                    if ( !wrFifoDataEmpty & !wid_mem_empty ) // & !wid_mem_empty ) // bbriscoe: extra control added, !wid_mem_empty, to make sure that data does not pass out command
                        begin
                            if ( ( countWrData == ( MAX_BEATS - 1'b1 ) ) | W_last )  // each last beat transfer or last transfer in the burst
                                begin
                                    TARGET_WLAST = 1'b1;
                                end

                            TARGET_WVALID = 1'b1;

                            if ( TARGET_WREADY )
                                begin
                                    wrFifoDataRd = 1'b1;

                                    if ( W_last ) // last transfer in the burst
                                        begin
                                            setCountWrData = 1'b1;
                                        end
                                    else // Not the last transfer in the burst
                                        begin
                                            incrCountWrData = 1'b1;
                                        end
                                end
                        end
                end

            default:
                begin
                  TARGET_WLAST    = 0;
                  TARGET_WVALID   = 0;
                  wrFifoDataRd    = 0;
                  setCountWrData  = 0;
                  incrCountWrData = 0;
                  nextStateWrSD   = currStateWrSD;
                end
        endcase
    end	

//=================================================================================
	
always @(posedge ACLK or negedge arst_sync )
	begin
	
		if (~arst_sync | ~srst_sync )
			begin
				responseCombi <= 0;
			end
		else if ( clearResponseCombi )
			begin
				responseCombi <= 0;
			end			
		else if ( setResponseCombi )
			begin
				responseCombi <= TARGET_BRESP;
			end
	end

//==================================================================================================	
// Dummy write beat tracking (WSTRB=0) for DWC response filtering
// Only enabled when DWC is active (DWC_ENABLED=1) and target is AXI4-Lite (TARGET_TYPE=2'b01)
// Tracks which beats have WSTRB=0 so their error responses can be filtered
//==================================================================================================
generate
if ((DWC_ENABLED == 1) && (TARGET_TYPE == 2'b01)) begin : gen_dummy_beat_tracking
    
    reg [255:0] dummy_beat_reg;      // Register array: 1=dummy (WSTRB=0), 0=valid
    reg [7:0]   wr_beat_cnt;         // Count of write data beats sent
    
    // Track dummy flag for each beat when W data is sent to target
    // Use wr_beat_cnt as index so beat 0's flag is at index 0, beat 1 at index 1, etc.
    always @(posedge ACLK or negedge arst_sync) begin
        if (~arst_sync) begin
            dummy_beat_reg <= 256'b0;
            wr_beat_cnt    <= 8'b0;
        end
        else if (~srst_sync) begin
            dummy_beat_reg <= 256'b0;
            wr_beat_cnt    <= 8'b0;
        end
        else if (clearResponseCombi) begin
            // Clear register when transaction completes
            dummy_beat_reg <= 256'b0;
            wr_beat_cnt    <= 8'b0;
        end
        else if (TARGET_WVALID & TARGET_WREADY) begin
            // Store dummy flag at current beat index
            // 1 if WSTRB==0 (dummy beat), 0 if WSTRB!=0 (valid beat)
            dummy_beat_reg[wr_beat_cnt] <= (TARGET_WSTRB == {(DATA_WIDTH/8){1'b0}});
            wr_beat_cnt <= wr_beat_cnt + 1'b1;
        end
    end
    
    // Current beat being responded to is dummy if corresponding register bit is set
    // Use active_resp_count to support both interleave (per-ID) and non-interleave (global) modes
    assign current_beat_is_dummy = dummy_beat_reg[active_resp_count];
    
end else begin : gen_no_dummy_tracking
    // No filtering when DWC not enabled or target is not AXI4-Lite
    assign current_beat_is_dummy = 1'b0;
end
endgenerate

//==================================================================================================	
// Responses counter (How many responses to combine from target before sending response to initiator)
//==================================================================================================
always @(posedge ACLK or negedge arst_sync )
	begin
	
		if (~arst_sync | ~srst_sync )
			begin
				countResp <= 0;
			end
		else if ( resetCountResp )
			begin
				countResp <= 0;
			end
		else if ( incrCountResp )
			begin
				countResp <= countResp + 1'b1;
			end
		else
			begin
				countResp <= countResp;
			end
	end
         assign latBID_sel = wrLenFifDOut[ID_WIDTH+8-1:8]; // jhayes :  ensuring that an AXI4 Lite transaction will have a BID field when converting back to AXI4.

	// Note: active_resp_count, expected_resp_count, resp_has_outstanding declared near countResp (line ~258)
	// These are driven by generate blocks below for interleave/non-interleave mode

always @(posedge ACLK or negedge arst_sync )
	begin
		if (~arst_sync | ~srst_sync )
			begin
				latBID <= 0;
			end
		else if ( setBID )
			begin
			  if(READ_INTERLEAVE)
			    begin 
			      if(TARGET_TYPE == 2'b01)
                    latBID <= latBID_sel;
			      else 
                    latBID <= TARGET_BID;
				end 
			  else 
			    begin 
				  latBID <= latBID_sel;
				end 
			end
		else
			begin
				latBID <= latBID;
			end
	end

	
//=================================================================================
// Response channel State Machine
//=================================================================================
always @(posedge ACLK or negedge arst_sync )
	begin
		if (~arst_sync | ~srst_sync )
			begin
				currStateResp <= Idle_WrResp;
			end
		else
			begin
				currStateResp <= nextStateResp;
			end
	end
 
 assign int_targetBID 	= latBID;
 assign int_targetBUSER 	= 0;
 assign int_targetBRESP 	= responseCombi;

 
always @(*)
    begin        
        wrFifoLenRd        = 0;
        setBID             = 0;
        setResponseCombi   = 0;
        incrCountResp      = 0;
        resetCountResp     = 0;
        int_targetBVALID   = 0;
        clearResponseCombi = 0;
        TARGET_BREADY      = 1'b0;
        nextStateResp      = currStateResp;

        case( currStateResp )
            Idle_WrResp:
                begin
                    // resp_has_outstanding: 
                    //   - Interleave mode: per-ID FIFO for currentbid not empty
                    //   - Non-interleave mode: global FIFO not empty (!wrFifoLenEmpty)
                    if (resp_has_outstanding)
                        begin
                            TARGET_BREADY = 1'b1;

                            if ( TARGET_BVALID )
                                begin
                                    setBID = 1'b1;

                                    if ( TARGET_BRESP != 2'b00 )
                                        begin
                                            // Only update responseCombi if this is NOT a dummy beat (WSTRB != 0)
                                            // Dummy beats have WSTRB=0 and their error responses should be filtered
                                            if ( (responseCombi == 2'b00) && !current_beat_is_dummy )
                                                begin
                                                    setResponseCombi = 1'b1;
                                                end
                                        end

                                    // Compare active response count with expected count
                                    // active_resp_count is per-ID in interleave mode, global otherwise
                                    // expected_resp_count is per-ID FIFO output in interleave mode
                                    if ( active_resp_count == expected_resp_count)
                                        begin
                                            nextStateResp = SendWrResp;
                                        end
                                    else
                                        begin
                                            incrCountResp = 1'b1;
                                        end
                                end
                        end
                end
            SendWrResp:
                begin
                    int_targetBVALID = 1'b1;

                    if ( int_targetBREADY ) // from initiator-side
                        begin
                            wrFifoLenRd = 1'b1;
                            clearResponseCombi = 1'b1;
                            resetCountResp = 1'b1;
                            nextStateResp = Idle_WrResp;
                        end
                end
            default:
                begin
                  wrFifoLenRd        = 0;
                  setBID             = 0;
                  setResponseCombi   = 0;
                  incrCountResp      = 0;
                  resetCountResp     = 0;
                  int_targetBVALID   = 0;
                  clearResponseCombi = 0;
                  TARGET_BREADY      = 1'b0;
                  nextStateResp      = currStateResp;
                end

        endcase

    end

	

generate 
  if((TARGET_TYPE == 2'b11) && (READ_INTERLEAVE == 1))  //WID logic for AXI3 target
    begin
      reg  [WID_RAM_ADDR_WIDTH:0]    wid_mem_wraddr;
      reg  [WID_RAM_ADDR_WIDTH:0]    wid_mem_rdaddr;
      reg  [ID_WIDTH-1:0]            wid_mem [WID_RAM_DEPTH-1:0] /* synthesis syn_ramstyle = "registers" */;
	
      //Logic to drive WID of AXI3. AXI4 initiator doesn't have WID port so when AXI4 Initiator access AXI3 target with different AWID, WID for 
      //target needs to be generated locally.To drive the WID, AWID is stored into the buffer when AWVALID and AWREADY are high.
      	
      
      //Logic for write address. Write address is incremented when AWVALID and AWREADY are high. 	
      	
      always @(posedge ACLK or negedge arst_sync )
      	begin      	
      	  if (~arst_sync | ~srst_sync )
      		wid_mem_wraddr <= 0;
          else if(TARGET_AWVALID & TARGET_AWREADY)
            wid_mem_wraddr <= wid_mem_wraddr + 1'b1;      
      	end
      
      
      //Logic for read address. read address counter is incremented when last beat write transfer condition is detected  
      	
      always @(posedge ACLK or negedge arst_sync )
      	begin	
      	  if (~arst_sync | ~srst_sync )
      	    wid_mem_rdaddr <= 0;
      	  else if((TARGET_WVALID & TARGET_WREADY & TARGET_WLAST))
            wid_mem_rdaddr <= wid_mem_rdaddr + 1'b1;		
      	end
      
      //Store the AWID in memory. 
      	
      always @(posedge ACLK)
        if(TARGET_AWVALID & TARGET_AWREADY) 
          wid_mem[wid_mem_wraddr[WID_RAM_ADDR_WIDTH-1:0]] <= TARGET_AWID;
      
      
      //Logic to drive WID. There can be a situation when both Address and Data are valid and both address are pointing to the same location.
      //In this scenerio, assign AWID to WID otherwise use AWID stored into the buffer.
      	
      assign TARGET_WID =  (wid_mem_wraddr == wid_mem_rdaddr) ? TARGET_AWID : wid_mem[wid_mem_rdaddr[WID_RAM_ADDR_WIDTH-1:0]];
	  assign wid_mem_empty = (wid_mem_wraddr == wid_mem_rdaddr);
	  assign wid_mem_full  = ({~wid_mem_wraddr[WID_RAM_ADDR_WIDTH],wid_mem_wraddr[WID_RAM_ADDR_WIDTH-1:0]} == wid_mem_rdaddr);
	end 
  else   //For AXI4-Lite target, WID is driven to 0
    begin 
	  assign TARGET_WID = 0;
	  assign wid_mem_empty = 0;
	  assign wid_mem_full = 0;
	end 
endgenerate	

//=================================================================================
// Per-ID response tracking for out-of-order B response handling
// When READ_INTERLEAVE=1 and TARGET_TYPE=AXI3, B responses can arrive out of order.
// We need per-ID FIFOs to store the expected burst split count (AWLEN[7:4]) so when
// a B response arrives, we can look up the correct count for that BID.
// Note: active_resp_count and resp_has_outstanding are declared earlier (near line 1121)
//=================================================================================
generate
	if ((TARGET_TYPE == 2'b11) && (READ_INTERLEAVE == 1)) begin : gen_interleave_resp
		//=========================================================================
		// INTERLEAVE MODE: Per-ID FIFO array for out-of-order B response tracking
		// Store AWLEN[7:4] (burst split count) per ID when AW phase completes
		// Look up by TARGET_BID when B response arrives
		//=========================================================================
		
		wire [NUM_IDS-1:0] idfifowr_arr;
		wire [NUM_IDS-1:0] idfiford_arr;
		wire [NUM_IDS-1:0] idfifoempty_arr;
		wire [NUM_IDS-1:0] idfifofull_arr;
		wire [3:0] idfifodout_arr [0:NUM_IDS-1];  // 4 bits for AWLEN[7:4]
		
		// Per-ID response counter
		reg [AWLEN_BITS-1:0] respcnt_arr [0:NUM_IDS-1];
		
		wire [ID_WIDTH-1:0] currentbid;
		assign currentbid = TARGET_BID;
		
		// Current expected burst split count from per-ID FIFO
		wire [3:0] currentawlen;
		assign currentawlen = idfifodout_arr[currentbid];
		
		// Response complete when per-ID counter matches per-ID AWLEN[7:4]
		assign expected_resp_count = currentawlen;
		
		// Backpressure from the per-ID FIFO selected by the incoming AWID
		assign anyidfifofull = idfifofull_arr[int_targetAWID];
		
		// Generate per-ID FIFOs
		genvar id_idx;
		for (id_idx = 0; id_idx < NUM_IDS; id_idx = id_idx + 1) begin : gen_idfifo
			
			// Write to per-ID FIFO when AW phase completes for this ID
			assign idfifowr_arr[id_idx] = wrFifoLenWr && (latAWID == id_idx[ID_WIDTH-1:0]);
			
			// Read from per-ID FIFO when B response completes for this ID
			// (when we send response to initiator in SendWrResp state)
			assign idfiford_arr[id_idx] = (currStateResp == SendWrResp) && int_targetBREADY && 
			                              (latBID == id_idx[ID_WIDTH-1:0]);
			
			if (PIPE > 0) begin : gen_pipe_fifo
				if (TRGT_AXI4PRT_ADDRDEPTH != 1) begin : gen_fifo
					wire idfifo_ttrdy;
					wire idfifo_itvld;
					
					caxi4c_coreaxi4s_fifo #(
						.RESET_TYPE         (SYNC_RESET),
						.SYNC               (1),
						.PIPE               (PIPE),
						.ECC                (0),
						.RAM_TYPE           (PROTOCONV_RAM_TYPE),
						.NUM_STAGES         (0),
						.READ_MODE          (0),
						.WFIFO_DEPTH        (TRGT_AXI4PRT_ADDRDEPTH),
						.RFIFO_DEPTH        (TRGT_AXI4PRT_ADDRDEPTH),
						.AXIS_TTDATA_WIDTH  (4),  // Only AWLEN[7:4]
						.AXIS_ITDATA_WIDTH  (4),
						.AXIS_TTID_WIDTH    (1),
						.AXIS_ITID_WIDTH    (1),
						.AXIS_TTDEST_WIDTH  (1),
						.AXIS_ITDEST_WIDTH  (1),
						.AXIS_TTUSER_WIDTH  (1),
						.AXIS_ITUSER_WIDTH  (1),
						.ENABLE_AFULL       (0),
						.AFULL_THR          (2),
						.ENABLE_TSTRB       (0),
						.ENABLE_TKEEP       (0),
						.ENABLE_TLAST       (0),
						.ENABLE_TUSER       (0),
						.ENABLE_TDEST       (0),
						.ENABLE_TID         (0),
						.EOP_OFFSET         (0)
					) idfifo_inst (
						.AXI4S_ACLK         (ACLK),
						.AXI4S_IACLK        (ACLK),
						.AXI4S_TACLK        (ACLK),
						.AXI4S_ARESETN      (cfifo_rst),
						.AXI4S_IARESETN     (cfifo_rst),
						.AXI4S_TARESETN     (cfifo_rst),
						.AXI4S_ITREADY      (idfiford_arr[id_idx]),
						.AXI4S_ITVALID      (idfifo_itvld),
						.AXI4S_ITDATA       (idfifodout_arr[id_idx]),
						.AXI4S_TTVALID      (idfifowr_arr[id_idx]),
						.AXI4S_TTDATA       (latAWLEN[7:4]),
						.AXI4S_TTREADY      (idfifo_ttrdy)
					);
					
					assign idfifofull_arr[id_idx]  = ~idfifo_ttrdy;
					assign idfifoempty_arr[id_idx] = ~idfifo_itvld;
					
				end else begin : gen_regslice
					wire idfifo_ttrdy;
					wire idfifo_itvld;
					
					caxi4interconnect_RegisterSlice #(
						.AWCHAN             (1'b1),
						.ARCHAN             (1'b0),
						.RCHAN              (1'b0),
						.WCHAN              (1'b0),
						.BCHAN              (1'b0),
						.ID_WIDTH           (1),
						.ADDR_WIDTH         (1'b1),
						.DATA_WIDTH         (1),
						.SUPPORT_USER_SIGNALS(1'b0),
						.USER_WIDTH         (1'b1),
						.READY_REG          (1'b0)
					) idfifo_rgsl_inst (
						.sysClk             (ACLK),
						.arst_sync          (arst_sync),
						.srst_sync          (srst_sync),
						.srcAWID            (1'b0),
						.srcAWADDR          (1'b0),
						.srcAWLEN           ({4'b0, latAWLEN[7:4]}),  // AWLEN[7:4] in lower bits
						.srcAWSIZE          (3'b0),
						.srcAWBURST         (2'b0),
						.srcAWLOCK          (2'b0),
						.srcAWCACHE         (4'b0),
						.srcAWPROT          (3'b0),
						.srcAWREGION        (4'b0),
						.srcAWQOS           (4'b0),
						.srcAWUSER          (1'b0),
						.srcAWVALID         (idfifowr_arr[id_idx]),
						.srcAWREADY         (idfifo_ttrdy),
						.dstAWID            (),
						.dstAWADDR          (),
						.dstAWLEN           ({idfifodout_arr[id_idx]}),
						.dstAWSIZE          (),
						.dstAWBURST         (),
						.dstAWLOCK          (),
						.dstAWCACHE         (),
						.dstAWPROT          (),
						.dstAWREGION        (),
						.dstAWQOS           (),
						.dstAWUSER          (),
						.dstAWVALID         (idfifo_itvld),
						.dstAWREADY         (idfiford_arr[id_idx])
					);
					
					assign idfifofull_arr[id_idx]  = ~idfifo_ttrdy;
					assign idfifoempty_arr[id_idx] = ~idfifo_itvld;
				end
			end else begin : gen_nopipe_blk
				if (TRGT_AXI4PRT_ADDRDEPTH != 1) begin : gen_fifo_nopipe
					caxi4interconnect_FifoDualPort #(
						.FIFO_AWIDTH  ($clog2(TRGT_AXI4PRT_ADDRDEPTH)),
						.FIFO_WIDTH   (4),
						.HI_FREQ      (1'b0)
					) idfifo_inst (
						.HCLK           (ACLK),
						.fifo_areset    (arst_sync),
						.fifo_sreset    (srst_sync),
						.fifoWrite      (idfifowr_arr[id_idx]),
						.fifoWrData     (latAWLEN[7:4]),
						.fifoRead       (idfiford_arr[id_idx]),
						.fifoRdData     (idfifodout_arr[id_idx]),
						.fifoEmpty      (idfifoempty_arr[id_idx]),
						.fifoFull       (idfifofull_arr[id_idx]),
						.fifoOneAvail   (),
						.fifoRdValid    (),
						.fifoNearFull   (),
						.fifoOverRunErr (),
						.fifoUnderRunErr()
					);
				end else begin : gen_regslice_nopipe
					wire idfifo_ttrdy;
					wire idfifo_itvld;
					
					caxi4interconnect_RegisterSlice #(
						.AWCHAN             (1'b1),
						.ARCHAN             (1'b0),
						.RCHAN              (1'b0),
						.WCHAN              (1'b0),
						.BCHAN              (1'b0),
						.ID_WIDTH           (1),
						.ADDR_WIDTH         (1'b1),
						.DATA_WIDTH         (1),
						.SUPPORT_USER_SIGNALS(1'b0),
						.USER_WIDTH         (1'b1),
						.READY_REG          (1'b0)
					) idfifo_rgsl_inst (
						.sysClk             (ACLK),
						.arst_sync          (arst_sync),
						.srst_sync          (srst_sync),
						.srcAWID            (1'b0),
						.srcAWADDR          (1'b0),
						.srcAWLEN           ({4'b0, latAWLEN[7:4]}),
						.srcAWSIZE          (3'b0),
						.srcAWBURST         (2'b0),
						.srcAWLOCK          (2'b0),
						.srcAWCACHE         (4'b0),
						.srcAWPROT          (3'b0),
						.srcAWREGION        (4'b0),
						.srcAWQOS           (4'b0),
						.srcAWUSER          (1'b0),
						.srcAWVALID         (idfifowr_arr[id_idx]),
						.srcAWREADY         (idfifo_ttrdy),
						.dstAWID            (),
						.dstAWADDR          (),
						.dstAWLEN           ({idfifodout_arr[id_idx]}),
						.dstAWSIZE          (),
						.dstAWBURST         (),
						.dstAWLOCK          (),
						.dstAWCACHE         (),
						.dstAWPROT          (),
						.dstAWREGION        (),
						.dstAWQOS           (),
						.dstAWUSER          (),
						.dstAWVALID         (idfifo_itvld),
						.dstAWREADY         (idfiford_arr[id_idx])
					);
					
					assign idfifofull_arr[id_idx]  = ~idfifo_ttrdy;
					assign idfifoempty_arr[id_idx] = ~idfifo_itvld;
				end
			end
		end
		
		//=========================================================================
		// Per-ID response counter management
		// In interleave mode, each ID tracks its own response count independently
		// This is critical for out-of-order B responses where BID may not match
		// the order of transactions in wrLenFifo
		//=========================================================================
		integer rc_idx;
		always @(posedge ACLK or negedge arst_sync) begin
			if (~arst_sync | ~srst_sync) begin
				for (rc_idx = 0; rc_idx < NUM_IDS; rc_idx = rc_idx + 1)
					respcnt_arr[rc_idx] <= {AWLEN_BITS{1'b0}};
			end else if (resetCountResp) begin
				// Reset latched BID because TARGET_BID is not guaranteed stable in SendWrResp
				respcnt_arr[latBID] <= {AWLEN_BITS{1'b0}};
			end else if (incrCountResp) begin
				// Increment the counter for current BID on each target B response
				respcnt_arr[currentbid] <= respcnt_arr[currentbid] + 1'b1;
			end
		end
		
		// In interleave mode, use per-ID counter indexed by current BID
		assign active_resp_count = respcnt_arr[currentbid];
		
		// In interleave mode, check per-ID FIFO for outstanding transaction
		// We have outstanding work if the per-ID FIFO for current BID is not empty
		// This is checked after TARGET_BID arrives with TARGET_BVALID=1
		assign resp_has_outstanding = !idfifoempty_arr[currentbid];
		
	end else begin : gen_non_interleave_resp
		//=========================================================================
		// NON-INTERLEAVE MODE: Use wrLenFifDOut (FIFO head) directly
		// Responses are in-order, so FIFO head always matches current response
		//=========================================================================
		assign expected_resp_count = wrLenFifDOut[7:8-AWLEN_BITS];
		assign anyidfifofull = 1'b0;
		
		// In non-interleave mode, use global counter (responses are in-order)
		assign active_resp_count = countResp;
		
		// In non-interleave mode, check global FIFO for outstanding transaction
		assign resp_has_outstanding = !wrFifoLenEmpty;
	end
endgenerate

	
endmodule		// caxi4interconnect_TrgtAxi4ProtConvWrite.v
