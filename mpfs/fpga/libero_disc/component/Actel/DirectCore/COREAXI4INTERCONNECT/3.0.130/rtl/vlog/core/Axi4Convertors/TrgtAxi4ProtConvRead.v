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

module caxi4interconnect_TrgtAxi4ProtConvRead #

	(
		parameter integer 	TARGET_NUMBER		        = 0,			//current target
		parameter [1:0] 	TARGET_TYPE			        = 2'b11,		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11	
		
		parameter integer 	ADDR_WIDTH      	        = 20,			// valid values - 16 - 64
		parameter integer 	DATA_WIDTH 			        = 32,			// valid widths - 32, 64, 128, 256

		parameter integer 	USER_WIDTH 			        = 1,			// defines the number of bits for USER signals RUSER and WUSER
		parameter integer 	ID_WIDTH   			        = 1,				// number of bits for ID (ie AID, WID, BID) - valid 1-8 
		parameter integer 	TRGT_AXI4PRT_ADDRDEPTH 		= 8,		// Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
		parameter integer 	TRGT_AXI4PRT_DATADEPTH		= 8,		// Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
		parameter           READ_INTERLEAVE             = 1,
        parameter           PIPE                        = 1,
        parameter           PROTOCONV_RAM_TYPE          = 1,
        parameter           SYNC_RESET                  = 0
	)
	(

	//=====================================  Global Signals   ========================================================================
	input  wire           			ACLK,
	input  wire          			arst_sync,
	input  wire          			srst_sync,

	//Target Read Address Ports
	output wire [ID_WIDTH-1:0]  	TARGET_ARID,
	output wire [ADDR_WIDTH-1:0]	TARGET_ARADDR,
	output reg [7:0]    	       	TARGET_ARLEN,
	output wire [2:0]        		TARGET_ARSIZE,
	output wire [1:0]           	TARGET_ARBURST,
	output wire [1:0]         		TARGET_ARLOCK,
	output wire [2:0]         		TARGET_ARPROT,
	output wire [3:0]	          	TARGET_ARCACHE,
	output reg            			TARGET_ARVALID,
	input wire             			TARGET_ARREADY,


	// Target Read Data Ports
	input wire [ID_WIDTH-1:0]  		TARGET_RID,	
	input wire [DATA_WIDTH-1:0]		TARGET_RDATA,
	input wire [1:0]           		TARGET_RRESP,
	input wire                  	TARGET_RLAST,
	input wire                 		TARGET_RVALID,
	output reg               		TARGET_RREADY,


	//============================= Internal AXI4 (XBar) Side Ports  ================================================//

	// INITIATOR Read Address Ports	
	input  wire [ID_WIDTH-1:0]  	int_targetARID,
	input  wire [ADDR_WIDTH-1:0]	int_targetARADDR,
	input  wire [7:0]           	int_targetARLEN,
	input  wire [2:0]        		int_targetARSIZE,
	input  wire [1:0]           	int_targetARBURST,
	input  wire [1:0]         		int_targetARLOCK,
	input  wire [3:0]          		int_targetARCACHE,
	input  wire [2:0]         		int_targetARPROT,
	input  wire [3:0]          		int_targetARREGION,
	input  wire [3:0]          		int_targetARQOS,
	input  wire [USER_WIDTH-1:0]	int_targetARUSER,
	input  wire                		int_targetARVALID,
	output reg                		int_targetARREADY,
	
	// INITIATOR Read Data Ports	
	output wire [ID_WIDTH-1:0]  	int_targetRID,

	output wire [DATA_WIDTH-1:0]  	int_targetRDATA,
	output wire [1:0]           	int_targetRRESP,
	output reg                  	int_targetRLAST,
	output wire [USER_WIDTH-1:0] 	int_targetRUSER,
	output reg               		int_targetRVALID,
	input wire                 		int_targetRREADY
	
	);
	
	//================================== Local parameters ==============================

localparam	ARLEN_BITS	= ( TARGET_TYPE == 2'b11 ) ? 4 : 8;			// AXI3 bursts brokwn into 16 beats or less, AXILite into single beat
localparam	[7:0] MAX_BEATS	= ( TARGET_TYPE == 2'b11 ) ? 8'd16 : 8'd1;		// AXI3 max bursts beats 16, AXILite is 1	
localparam	integer DATA_WIDTH_BYTES_LOG_INT = $clog2(DATA_WIDTH/8);
localparam	[2:0] DATA_WIDTH_BYTES_LOG = DATA_WIDTH_BYTES_LOG_INT[2:0];
	localparam [1:0] IdleAddrRead = 2'b00, ReadAddr = 2'b01, WaitFifoEmpty = 2'b10;
	localparam [0:0] Idle_SendDataRd = 1'b0,	SendDataRd = 1'b1;
	localparam NUM_IDS = (1 << ID_WIDTH);  // Number of unique IDs for READ_INTERLEAVE=1
	localparam [0:0] RGetData = 1'b0;


	//================================== Internal =======================================
	
	//Read number of reads to combine caxi4interconnect_FIFO
	reg 					rdFifoIdRd;
	reg 					rdFifoIdWr;
	wire 					rdFifoIdFull;
	wire 					rdFifoIdEmpty;
	wire [(ID_WIDTH + 8)-1:0] rdFifoIdDIn; 		//hold only number of reads
	wire [(ID_WIDTH + 8)-1:0] rdFifoIdDOut;		//hold only number of reads
	
	//Read Data+last caxi4interconnect_FIFO
	reg 					rdFifoDataRd;
	reg 					rdFifoDataWr;
	wire 					rdFifoDataFull;
	wire 					rdFifoDataEmpty;
	
	// Backpressure signal for AR state machine
	wire anyidfifofull;  // Full status for current per-ID FIFO (READ_INTERLEAVE=1 only)
	wire arfifo_backpressure;
	assign arfifo_backpressure = (READ_INTERLEAVE == 0) ? rdFifoIdFull : anyidfifofull;
	
	wire [(DATA_WIDTH+ID_WIDTH+2)-1:0] 	rdFifoDataIn;		// no need to add RLAST bit 
	wire [(DATA_WIDTH+ID_WIDTH+2)-1:0] 	rdFifoDataOut;		// no need to add RLAST bit
    wire                    rdidfifo_ttrdy;
    wire                    rddtfifo_ttrdy;
    wire                    rdidfifo_itvld;
    wire                    rddtfifo_itvld;
	
    wire                    cfifo_rst;



    assign                  cfifo_rst = (SYNC_RESET == 0) ? arst_sync : srst_sync; 	

	//==========================================================================
	// Store Read Len information to allow "combination" of read bursts
	//==========================================================================
generate 
  if(PIPE > 0) begin 
	
    assign rdFifoIdFull    = ~rdidfifo_ttrdy;
    assign rdFifoIdEmpty   = ~rdidfifo_itvld;
    assign rdFifoDataFull  = ~rddtfifo_ttrdy;
    assign rdFifoDataEmpty = ~rddtfifo_itvld;	
  
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
         .AXIS_TTDATA_WIDTH  (ID_WIDTH + 8), // Bytes
         .AXIS_ITDATA_WIDTH  (ID_WIDTH + 8),  // Bytes
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
      ) rdIdFif_fwft
      (
         .AXI4S_ACLK         (ACLK),
         .AXI4S_IACLK        (ACLK),
         .AXI4S_TACLK        (ACLK),
         .AXI4S_ARESETN      (cfifo_rst),
         .AXI4S_IARESETN     (cfifo_rst),
         .AXI4S_TARESETN     (cfifo_rst),
         .AXI4S_ITREADY      (rdFifoIdRd),
         .AXI4S_ITVALID      (rdidfifo_itvld),
         .AXI4S_ITDATA       (rdFifoIdDOut),
         .AXI4S_TTVALID      ((READ_INTERLEAVE == 0) ? rdFifoIdWr : 1'b0),
         .AXI4S_TTDATA       (rdFifoIdDIn),
         .AXI4S_TTREADY      (rdidfifo_ttrdy)
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
	  	rdId_rgsl(
	        .sysClk	                    ( ACLK                                           ),
	        .arst_sync	                ( arst_sync                                      ),
	        .srst_sync	                ( srst_sync                                      ),	  
	        
	        
	        .srcAWID                    ( int_targetARID                                 ),
	        .srcAWADDR                  ( 0                                              ),
	        .srcAWLEN                   ( int_targetARLEN                                ),
	        .srcAWSIZE                  ( 0                                              ),
	        .srcAWBURST                 ( 0                                              ),
	        .srcAWLOCK                  ( 0                                              ),
	        .srcAWCACHE                 ( 0                                              ),
	        .srcAWPROT                  ( 0                                              ),
	        .srcAWREGION                ( 0                                              ),
	        .srcAWQOS                   ( 0                                              ),
  	        .srcAWUSER                  ( 0                                              ),
	        .srcAWVALID                 ( (READ_INTERLEAVE == 0) ? rdFifoIdWr : 1'b0     ),
	        .srcAWREADY                 ( rdidfifo_ttrdy                                 ),
	        
	        .dstAWID                    ( rdFifoIdDOut[ID_WIDTH+8-1:8]                   ),
	        .dstAWADDR                  (                                                ),
	        .dstAWLEN                   ( rdFifoIdDOut[7:0]                              ),
	        .dstAWSIZE                  (                                                ),
	        .dstAWBURST                 (                                                ),
	        .dstAWLOCK                  (                                                ),
	        .dstAWCACHE                 (                                                ),
	        .dstAWPROT                  (                                                ),
	        .dstAWREGION                (                                                ),
	        .dstAWQOS                   (                                                ),
	        .dstAWUSER                  (                                                ),
	        .dstAWVALID                 ( rdidfifo_itvld                                 ),
	        .dstAWREADY                 ( rdFifoIdRd                                     )
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
         .AXIS_TTDATA_WIDTH  (DATA_WIDTH + ID_WIDTH + 2), // Bytes
         .AXIS_ITDATA_WIDTH  (DATA_WIDTH + ID_WIDTH + 2),  // Bytes
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
      ) rddatafif_fwft
      (
         .AXI4S_ACLK         (ACLK),
         .AXI4S_IACLK        (ACLK),
         .AXI4S_TACLK        (ACLK),
         .AXI4S_ARESETN      (cfifo_rst),
         .AXI4S_IARESETN     (cfifo_rst),
         .AXI4S_TARESETN     (cfifo_rst),
         .AXI4S_ITREADY      (rdFifoDataRd),
         .AXI4S_ITVALID      (rddtfifo_itvld),
         .AXI4S_ITDATA       (rdFifoDataOut),
         .AXI4S_TTVALID      (rdFifoDataWr),
         .AXI4S_TTDATA       (rdFifoDataIn),
         .AXI4S_TTREADY      (rddtfifo_ttrdy)
      );
	end else begin 
	  caxi4interconnect_RegisterSlice #
	  
	  	(
	  		.AWCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ARCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.RCHAN	                ( 1'b1                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.WCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.BCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ID_WIDTH   			( ID_WIDTH                     ), 
	  		.ADDR_WIDTH      		( 1'b1                         ),
	  		.DATA_WIDTH 			( DATA_WIDTH                   ), 
	  		.SUPPORT_USER_SIGNALS 	( 1'b0                         ),
	  		.USER_WIDTH 			( 1'b1                         ),
	  		.READY_REG   			( 1'b0                         )
	  	)
	  	rddata_rgsl(
	  			.sysClk	    ( ACLK                   ),
	  			.arst_sync	( arst_sync              ),
	  			.srst_sync	( srst_sync              ),
				
			    .dstRID     ( TARGET_RID             ),
	            .dstRDATA   ( TARGET_RDATA           ),
	            .dstRRESP   ( TARGET_RRESP           ),
	            .dstRLAST   ( 0                      ),
	            .dstRUSER   ( 0                      ),
	            .dstRVALID  ( rdFifoDataWr           ),
	            .dstRREADY  ( rddtfifo_ttrdy         ),	        
				
	            .srcRID     ( rdFifoDataOut[(ID_WIDTH+2)-1:2]),
	            .srcRDATA   ( rdFifoDataOut[(DATA_WIDTH+ID_WIDTH+2)-1:ID_WIDTH+2]),
	            .srcRRESP   ( rdFifoDataOut[1:0]     ),
	            .srcRLAST   (                        ),
	            .srcRUSER   (                        ),
	            .srcRVALID  ( rddtfifo_itvld         ),
	            .srcRREADY  ( rdFifoDataRd           )
	  		);		
	end   
  end else begin 
    if(TRGT_AXI4PRT_ADDRDEPTH != 1) begin   
	  caxi4interconnect_FifoDualPort #(	.FIFO_AWIDTH( $clog2(TRGT_AXI4PRT_ADDRDEPTH) ),
	                					.FIFO_WIDTH	( ID_WIDTH + 8 ),
	  				                	.HI_FREQ	( 1'b0 	)						
	  	   			                  )
	  rdIdFif(
	  				.HCLK(	ACLK ),
	  				.fifo_areset( arst_sync ),
	  				.fifo_sreset( srst_sync ),
	  				
	  				// Write Port
	  				.fifoWrite( (READ_INTERLEAVE == 0) ? rdFifoIdWr : 1'b0 ),
	  				.fifoWrData( rdFifoIdDIn ),
	  
	  				// Read Port
	  				.fifoRead( rdFifoIdRd ),
	  				.fifoRdData( rdFifoIdDOut ),
	  				
	  				// Status bits
	  				.fifoEmpty ( rdFifoIdEmpty ) ,
	  				.fifoOneAvail( ),
	  				.fifoRdValid ( ),
	  				.fifoFull( rdFifoIdFull ),
	  				.fifoNearFull( ),
	  				.fifoOverRunErr(  ),
	  				.fifoUnderRunErr(  )
	  			   
	  			);
				
	end else begin 
      assign rdFifoIdFull  = ~rdidfifo_ttrdy;
      assign rdFifoIdEmpty = ~rdidfifo_itvld;
	
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
	  	rdId_rgsl(
	        .sysClk	                    ( ACLK                                           ),
	        .arst_sync	                ( arst_sync                                      ),
	        .srst_sync	                ( srst_sync                                      ),	  
	        
	        
	        .srcAWID                    ( int_targetARID                                 ),
	        .srcAWADDR                  ( 0                                              ),
	        .srcAWLEN                   ( int_targetARLEN                                ),
	        .srcAWSIZE                  ( 0                                              ),
	        .srcAWBURST                 ( 0                                              ),
	        .srcAWLOCK                  ( 0                                              ),
	        .srcAWCACHE                 ( 0                                              ),
	        .srcAWPROT                  ( 0                                              ),
	        .srcAWREGION                ( 0                                              ),
	        .srcAWQOS                   ( 0                                              ),
  	        .srcAWUSER                  ( 0                                              ),
	        .srcAWVALID                 ( (READ_INTERLEAVE == 0) ? rdFifoIdWr : 1'b0     ),
	        .srcAWREADY                 ( rdidfifo_ttrdy                                 ),
	        
	        .dstAWID                    ( rdFifoIdDOut[ID_WIDTH+8-1:8]                   ),
	        .dstAWADDR                  (                                                ),
	        .dstAWLEN                   ( rdFifoIdDOut[7:0]                              ),
	        .dstAWSIZE                  (                                                ),
	        .dstAWBURST                 (                                                ),
	        .dstAWLOCK                  (                                                ),
	        .dstAWCACHE                 (                                                ),
	        .dstAWPROT                  (                                                ),
	        .dstAWREGION                (                                                ),
	        .dstAWQOS                   (                                                ),
	        .dstAWUSER                  (                                                ),
	        .dstAWVALID                 ( rdidfifo_itvld                                 ),
	        .dstAWREADY                 ( rdFifoIdRd                                     )
	  	);		  
	
    end 	
	//==========================================================================
	// Store Read Data to allow "combination" of read bursts
	//==========================================================================		
	if(TRGT_AXI4PRT_DATADEPTH != 1) begin
	  caxi4interconnect_FifoDualPort #(	.FIFO_AWIDTH( $clog2(TRGT_AXI4PRT_DATADEPTH) ),
	  				.FIFO_WIDTH	( DATA_WIDTH + ID_WIDTH + 2	),		// store RDATA, RID and RRESP
	  				.HI_FREQ 	( 1'b0 			)
	  			)
	  rdDataFif(
	  				.HCLK(	ACLK ),
	  				.fifo_areset( arst_sync ),
	  				.fifo_sreset( srst_sync ),
	  				
	  				// Write Port
	  				.fifoWrite( rdFifoDataWr ),
	  				.fifoWrData( rdFifoDataIn ),
	  
	  				// Read Port
	  				.fifoRead( rdFifoDataRd ),
	  				.fifoRdData( rdFifoDataOut ),
	  				
	  				// Status bits
	  				.fifoEmpty ( rdFifoDataEmpty ) ,
	  				.fifoOneAvail( ),
	  				.fifoRdValid ( ),
	  				.fifoFull( rdFifoDataFull ),
	  				.fifoNearFull( ),
	  				.fifoOverRunErr(  ),
	  				.fifoUnderRunErr(  )
	  			   
	  			);
	end else begin 
      assign rdFifoDataFull  = ~rddtfifo_ttrdy;
      assign rdFifoDataEmpty = ~rddtfifo_itvld;
	  
	  caxi4interconnect_RegisterSlice #
	  
	  	(
	  		.AWCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ARCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.RCHAN	                ( 1'b1                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.WCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.BCHAN	                ( 1'b0                         ),			// 0 means no slice on channel - 1 means full slice on channel
	  		.ID_WIDTH   			( ID_WIDTH                     ), 
	  		.ADDR_WIDTH      		( 1'b1                         ),
	  		.DATA_WIDTH 			( DATA_WIDTH                   ), 
	  		.SUPPORT_USER_SIGNALS 	( 1'b0                         ),
	  		.USER_WIDTH 			( 1'b1                         ),
	  		.READY_REG   			( 1'b0                         )
	  	)
	  	rddata_rgsl(
	  			.sysClk	    ( ACLK                   ),
	  			.arst_sync	( arst_sync              ),
	  			.srst_sync	( srst_sync              ),
				
			    .dstRID     ( TARGET_RID             ),
	            .dstRDATA   ( TARGET_RDATA           ),
	            .dstRRESP   ( TARGET_RRESP           ),
	            .dstRLAST   ( 0                      ),
	            .dstRUSER   ( 0                      ),
	            .dstRVALID  ( rdFifoDataWr           ),
	            .dstRREADY  ( rddtfifo_ttrdy         ),	        
				
	            .srcRID     ( rdFifoDataOut[(ID_WIDTH+2)-1:2]),
	            .srcRDATA   ( rdFifoDataOut[(DATA_WIDTH+ID_WIDTH+2)-1:ID_WIDTH+2]),
	            .srcRRESP   ( rdFifoDataOut[1:0]     ),
	            .srcRLAST   (),
	            .srcRUSER   (),
	            .srcRVALID  ( rddtfifo_itvld         ),
	            .srcRREADY  ( rdFifoDataRd           )
	  		);		
	end 
  end 
endgenerate 	
	//========================== Address Read registers =======================
	
	reg [ID_WIDTH-1:0]      latARID;
	reg [2:0]   			latARSIZE;
	reg [1:0] 				latARBURST;
	reg [1:0] 				latARLOCK;
	reg [3:0] 				latARCACHE;
	reg [2:0]				latARPROT;
	reg [3:0]				lastTransLenRd; 	// only used for AXI3 targets
	
	reg						latchARAll;
	
	reg [ADDR_WIDTH-1:0]	newAddrRd; 			// Initial or Recalculated address which will be sent to Target
	reg 					loadAddr;
	reg 					incrAddr;
	
	reg [ARLEN_BITS-1:0]	numTransRd;			// Times address has to be recalculated
	reg 					loadCount;
	reg 					decrCount;
	reg						clearCount;

	reg [1:0]				currStateARd, nextStateARd;
	
	//Read Data Channel Get data from target States
	
	reg [0:0]				currStateRdGD, nextStateRdGD;

	// andreag: signals for correct WRAP burst address computation
	wire [10:0] wrap_nibble;
	wire [10:0] wrap_mask;


	//==========================================================================================
	// Drive out latched information from Read Address Cycle
	//===========================================================================================
	assign TARGET_ARID 		= READ_INTERLEAVE ? ((TARGET_TYPE == 2'b01) ? {ID_WIDTH{1'b0}} : latARID) : {ID_WIDTH{1'b0}};
	assign TARGET_ARSIZE 	= (TARGET_TYPE == 2'b01) ? DATA_WIDTH_BYTES_LOG : latARSIZE;
	assign TARGET_ARBURST 	= latARBURST;
	assign TARGET_ARLOCK 	= latARLOCK;
	assign TARGET_ARCACHE 	= latARCACHE ;
	assign TARGET_ARPROT 	= latARPROT;
	assign TARGET_ARADDR 	= newAddrRd;
	
	assign rdFifoIdDIn 		= {int_targetARID, int_targetARLEN[7:0]};			// data to be stored in rdIdFif
    
	//=================================================================================
	// Read Transaction counter for address recalculation
	//=================================================================================
	always @(posedge ACLK or negedge arst_sync )
		begin
			if (~arst_sync | ~srst_sync )
				begin
					numTransRd <= 0;
				end
			else if ( clearCount )
				begin
					numTransRd <= 0;
				end		
			else if (loadCount)
				begin
					numTransRd <= int_targetARLEN[7:8-ARLEN_BITS];
				end
			else if (decrCount)
				begin
					numTransRd <= numTransRd - 1'b1;
				end

		end

	assign wrap_nibble = 11'h00f << latARSIZE;
assign wrap_mask = ({7'b0000000, lastTransLenRd} << latARSIZE);
	
	//=================================================================================	
	// Read Address recalculation	
	//=================================================================================
	always @(posedge ACLK or negedge arst_sync )
		begin
			if (~arst_sync | ~srst_sync )
				begin
					newAddrRd <= 0;
				end
			else if (loadAddr)
				begin
					newAddrRd <= int_targetARADDR;
				end
			else if (incrAddr)
				begin
					//=====================================================================		
					// Compute address based on Burst-type and address alginment
					// Fixed =00, Incr=01, Wrap =10 - Wrap not handled as not needed
					// for AXI3 and makes no sense for AXI4Lite (Caches not used here)
					//======================================================================			
					if ( latARBURST == 2'b00 )			// Fixed type burst
						begin
							newAddrRd	<= newAddrRd;		// all beats use the same address.
						end
					else if (( latARBURST == 2'b10 ) && (TARGET_TYPE == 2'b01))
					begin
						if ((newAddrRd[10:0] & wrap_mask) == (wrap_mask & wrap_nibble)) begin
						        newAddrRd <= {newAddrRd[ADDR_WIDTH-1:11], (newAddrRd[10:0] & ~wrap_mask)};
					        end else begin
					newAddrRd <= newAddrRd + ({ { (ADDR_WIDTH-1){1'b0} }, 1'b1 } << latARSIZE); // AXI4-Lite burst length is always 1
						end
					end
					else
						begin
							case (latARSIZE)
								3'd0	: newAddrRd <= newAddrRd + MAX_BEATS;
								3'd1	: newAddrRd <= { newAddrRd[ADDR_WIDTH-1:1] + MAX_BEATS, 1'd0 };
								3'd2	: newAddrRd <= { newAddrRd[ADDR_WIDTH-1:2] + MAX_BEATS, 2'd0 };
								3'd3	: newAddrRd <= { newAddrRd[ADDR_WIDTH-1:3] + MAX_BEATS, 3'd0 };
								3'd4	: newAddrRd <= { newAddrRd[ADDR_WIDTH-1:4] + MAX_BEATS, 4'd0 };
								3'd5	: newAddrRd <= { newAddrRd[ADDR_WIDTH-1:5] + MAX_BEATS, 5'd0 };
								3'd6	: newAddrRd <= { newAddrRd[ADDR_WIDTH-1:6] + MAX_BEATS, 6'd0 };
								3'd7	: newAddrRd <= { newAddrRd[ADDR_WIDTH-1:7] + MAX_BEATS, 7'd0 };
							endcase
						end				
				
					//newAddrRd <= newAddrRd + ( MAX_BEATS << latARSIZE );	// compute bytes sent in burst
				end
	end
	
	
	//=================================================================================	
	// latch all signals from channel for retransmission 	
	//=================================================================================
	always @(posedge ACLK or negedge arst_sync )
		begin
			if (~arst_sync | ~srst_sync )
				begin
				    latARID     <= 0;
					latARSIZE 	<= 0;
					latARBURST 	<= 0;
					latARLOCK 	<= 0;
					latARCACHE 	<= 0;
					latARPROT 	<= 0;
					lastTransLenRd <= 0;
				end
			else if (latchARAll)
				begin
				    latARID     <= int_targetARID;
					latARSIZE 	<= int_targetARSIZE;
					latARBURST 	<= int_targetARBURST;
					latARLOCK 	<= int_targetARLOCK;
					latARCACHE 	<= int_targetARCACHE;
					latARPROT 	<= int_targetARPROT;
					lastTransLenRd <= int_targetARLEN[3:0];	
				end
		end
	
	
	//=================================================================================	
	// Read address channel state machine
	//================================================================================= 
	always @(posedge ACLK or negedge arst_sync)
		begin
			if (~arst_sync | ~srst_sync )
				begin
					currStateARd <= IdleAddrRead;
				end
			else
				begin
					currStateARd <= nextStateARd;
				end	
		end
 

	always @(*)
		begin
			clearCount 	      = 1'b0;
			loadCount  	      = 1'b0;
			decrCount 	      = 1'b0;
			loadAddr  	      = 1'b0;
			incrAddr 	      = 1'b0;
			int_targetARREADY = 1'b0;
			latchARAll 	      = 1'b0;
			rdFifoIdWr 	      = 1'b0;
			
			TARGET_ARLEN  	  = 0;
			TARGET_ARVALID	  = 1'b0;
			int_targetARREADY = 1'b0;
		
			nextStateARd	  = currStateARd;
		
			case( currStateARd )
				IdleAddrRead:
					begin
						if (int_targetARVALID)
							begin
								if (!arfifo_backpressure)
									begin
										int_targetARREADY = 1'b1;
										latchARAll	     = 1'b1; //latch all signals and hold for the duration of address recalculation and re-transfer
										loadCount 	     = 1'b1;								
										loadAddr 	     = 1'b1;
										rdFifoIdWr 	     = 1'b1;
										nextStateARd     = ReadAddr;
									end
							end
					end
				ReadAddr:
					begin
						if ( numTransRd == 0 ) //last burst
							begin
								TARGET_ARLEN[3:0] = lastTransLenRd; //last burst,so set LEN to be last transaction LEN - only used by AXI3 target
								TARGET_ARVALID    = 1'b1;
							
								if (TARGET_ARREADY)
									begin
                                        clearCount   = 1'b1;
                                        nextStateARd = IdleAddrRead;
									end
							end
						else //Not the last burst
							begin
								TARGET_ARLEN[3:0] = 4'b1111; // set LEN to be max (16) transfers supported by AXI3 protocol - AXILite target does not use TARGET_AWLEN
								TARGET_ARVALID    = 1'b1;

								if (TARGET_ARREADY)
									begin
										incrAddr	= 1'b1;
										decrCount 	= 1'b1;
									end
							end
					end
                default:
					begin
            			clearCount 	      = 1'b0;
            			loadCount  	      = 1'b0;
            			decrCount 	      = 1'b0;
            			loadAddr  	      = 1'b0;
            			incrAddr 	      = 1'b0;
            			int_targetARREADY = 1'b0;
            			latchARAll 	      = 1'b0;
            			rdFifoIdWr 	      = 1'b0;            			
            			TARGET_ARLEN  	  = 0;
            			TARGET_ARVALID	  = 1'b0;
            			nextStateARd	  = currStateARd;
					end
				
			endcase
		
	end
	
	
	//=================================================================================	
	// Data read channel (get data from target)
	//=================================================================================
	assign rdFifoDataIn = { TARGET_RDATA, TARGET_RID, TARGET_RRESP };

	//=================================================================================
	// Data read channel state machine (get data from target)
	//=================================================================================
	always @(posedge ACLK or negedge arst_sync )
		begin
	
			if (~arst_sync | ~srst_sync )
				begin
					currStateRdGD <= RGetData;
				end
			else
				begin
					currStateRdGD <= nextStateRdGD;
				end
			
		end

	
	always @(*)
		begin
			rdFifoDataWr    = 1'b0;
			TARGET_RREADY   = 1'b0;		
			nextStateRdGD	= currStateRdGD;
		
			case( currStateRdGD )
				RGetData:
					begin
						if (TARGET_RVALID)
							begin
								if (!rdFifoDataFull)
									begin
										rdFifoDataWr  = 1'b1;
										TARGET_RREADY = 1'b1;
									end
							end
					end
				default:
					begin
			          rdFifoDataWr    = 1'b0;
			          TARGET_RREADY   = 1'b0;		
			          nextStateRdGD	  = currStateRdGD;
					end
				
			endcase
		
		end
	

	//========================== Read Data Channel Send data to initiator =======================
	// Read Data Channel Send data to initiator States
	//=========================================================================================
	
	reg [0:0]				currStateRdSD, nextStateRdSD;
	
	//Read Data Channel Send data to initiator 
	reg [7:0]				numCombRd;				
	reg						resetNumCombRd;
	reg 					loadNumCombRd;
	reg 					decrNumCombRd;
	reg 					BAD_ERROR;
	
	//=========================================================================================
	// Common data path assignments
	//=========================================================================================
	assign int_targetRDATA	= rdFifoDataOut[(DATA_WIDTH+ID_WIDTH+2)-1:ID_WIDTH+2];
	assign int_targetRRESP 	= rdFifoDataOut[1:0];
	assign int_targetRUSER 	= 0;

	//=========================================================================================
	// Generate block for READ_INTERLEAVE mode selection
	//=========================================================================================
generate
	if (READ_INTERLEAVE == 0) begin : gen_non_interleave
		//=========================================================================
		// NON-INTERLEAVE MODE: Use existing single ID FIFO logic
		//=========================================================================
		
		// int_targetRID from ID FIFO
		assign int_targetRID = rdFifoIdDOut[(ID_WIDTH-1)+8:8];
		
		// anyidfifofull not used in this mode
		assign anyidfifofull = 1'b0;
		
		//================================================================================= 
		// Counter to calculate when to assert initiator side LAST signal
		//=================================================================================
		always @(posedge ACLK or negedge arst_sync)
			begin
		
				if (~arst_sync | ~srst_sync )
					begin
						numCombRd <= 0;
					end
				else if ( loadNumCombRd )
					begin
						numCombRd <= rdFifoIdDOut[7:0];
					end
				else if ( decrNumCombRd )
					begin
						numCombRd <= numCombRd - 1'b1;
					end	     
			end

		//=================================================================================
		// Data read channel state machine (Send data to initiator)
		//=================================================================================
		always @(posedge ACLK or negedge arst_sync)
			begin
				if (~arst_sync | ~srst_sync )
					begin
						currStateRdSD <= Idle_SendDataRd;
					end
				else
					begin
						currStateRdSD <= nextStateRdSD;
					end
				
			end
		
		
		always @(*)
			begin	
				BAD_ERROR 		 = 1'b0;
				rdFifoIdRd 		 = 1'b0;
				rdFifoDataRd 	 = 1'b0;
				int_targetRLAST  = 1'b0;
				int_targetRVALID = 1'b0;
				decrNumCombRd 	 = 0;
				loadNumCombRd 	 = 0;
				resetNumCombRd 	 = 0;		
				nextStateRdSD	 = currStateRdSD;
			
				case( currStateRdSD )
					Idle_SendDataRd:
						begin
							if ( !rdFifoDataEmpty )
								begin
									if ( rdFifoIdEmpty )
										begin
											BAD_ERROR = 1'b1;
										end
									else
										begin
											loadNumCombRd = 1'b1; 
														  
											nextStateRdSD = SendDataRd;
										end
								end
						end
					SendDataRd:
						begin
							if ( !rdFifoDataEmpty )
								begin
									if ( numCombRd == 0 )
										begin
											int_targetRLAST = 1'b1;
										end
							
									int_targetRVALID = 1'b1;

									if (int_targetRREADY)
										begin
											rdFifoDataRd 	= 1'b1;

											if ( numCombRd == 0 )
												begin
													resetNumCombRd  = 1'b1;
													rdFifoIdRd 		= 1'b1;
								
													nextStateRdSD 	= Idle_SendDataRd;
												end
											else
												begin
													decrNumCombRd 	= 1'b1;
													nextStateRdSD 	= SendDataRd;
												end
										end
								end
							else
								begin
									nextStateRdSD 	= SendDataRd;
								end
						end  
					default:
						begin
						  BAD_ERROR 		 = 1'b0;
						  rdFifoIdRd 		 = 1'b0;
						  rdFifoDataRd 	     = 1'b0;
						  int_targetRLAST    = 1'b0;
						  int_targetRVALID   = 1'b0;
						  decrNumCombRd 	 = 0;
						  loadNumCombRd 	 = 0;
						  resetNumCombRd 	 = 0;		
						  nextStateRdSD	     = currStateRdSD;					
						end
					
				endcase
			
			end
		
	end else begin : gen_interleave
		//=========================================================================
		// INTERLEAVE MODE: Per-ID FIFO array
		//=========================================================================
		
		wire [NUM_IDS-1:0] idfifowr_arr;
		wire [NUM_IDS-1:0] idfiford_arr;
		wire [NUM_IDS-1:0] idfifoempty_arr;
		wire [NUM_IDS-1:0] idfifofull_arr;
		wire [7:0] idfifodout_arr [0:NUM_IDS-1];
		
		reg [7:0] beatcount_arr [0:NUM_IDS-1];
		
		wire [ID_WIDTH-1:0] currentrid;
		assign currentrid = rdFifoDataOut[(ID_WIDTH+2)-1:2];
		
		wire [7:0] currentarlen;
		assign currentarlen = idfifodout_arr[currentrid];
		
		wire interleaverlast;
		assign interleaverlast = (beatcount_arr[currentrid] == currentarlen);
		
		assign anyidfifofull = idfifofull_arr[int_targetARID];
		
		assign int_targetRID = currentrid;
		
		// These signals are not used in interleave mode - drive to constant 0
		always @(*) begin
			rdFifoIdRd = 1'b0;
			loadNumCombRd = 1'b0;
			decrNumCombRd = 1'b0;
			resetNumCombRd = 1'b0;
		end
		
		genvar id_idx;
		for (id_idx = 0; id_idx < NUM_IDS; id_idx = id_idx + 1) begin : gen_idfifo
			
			assign idfifowr_arr[id_idx] = rdFifoIdWr && (int_targetARID == id_idx[ID_WIDTH-1:0]);
			assign idfiford_arr[id_idx] = rdFifoDataRd && (currentrid == id_idx[ID_WIDTH-1:0]) && interleaverlast;
			
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
						.AXIS_TTDATA_WIDTH  (8),
						.AXIS_ITDATA_WIDTH  (8),
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
						.AXI4S_TTDATA       (int_targetARLEN[7:0]),
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
						.srcAWLEN           (int_targetARLEN[7:0]),
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
						.dstAWLEN           (idfifodout_arr[id_idx]),
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
						.FIFO_WIDTH   (8),
						.HI_FREQ      (1'b0)
					) idfifo_inst (
						.HCLK           (ACLK),
						.fifo_areset    (arst_sync),
						.fifo_sreset    (srst_sync),
						.fifoWrite      (idfifowr_arr[id_idx]),
						.fifoWrData     (int_targetARLEN[7:0]),
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
						.srcAWLEN           (int_targetARLEN[7:0]),
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
						.dstAWLEN           (idfifodout_arr[id_idx]),
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
		
		integer bc_idx;
		always @(posedge ACLK or negedge arst_sync) begin
			if (~arst_sync | ~srst_sync) begin
				for (bc_idx = 0; bc_idx < NUM_IDS; bc_idx = bc_idx + 1)
					beatcount_arr[bc_idx] <= 8'd0;
			end else begin
				if (rdFifoDataRd) begin
					if (interleaverlast)
						beatcount_arr[currentrid] <= 8'd0;
					else
						beatcount_arr[currentrid] <= beatcount_arr[currentrid] + 8'd1;
				end
			end
		end
		
		always @(*)
			begin
				rdFifoDataRd     = 1'b0;
				int_targetRLAST  = 1'b0;
				int_targetRVALID = 1'b0;
				BAD_ERROR        = 1'b0;
				
				if (!rdFifoDataEmpty && !idfifoempty_arr[currentrid]) begin
					int_targetRVALID = 1'b1;
					int_targetRLAST  = interleaverlast;
					
					if (int_targetRREADY)
						rdFifoDataRd = 1'b1;
				end
			end
		
	end
endgenerate
	
endmodule	// caxi4interconnect_TrgtAxi4ProtocolConv.v
