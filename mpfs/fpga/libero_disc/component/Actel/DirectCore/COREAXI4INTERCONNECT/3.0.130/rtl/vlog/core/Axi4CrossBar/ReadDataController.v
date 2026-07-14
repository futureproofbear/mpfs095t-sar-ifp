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
// SVN $Revision: 51202 $
// SVN $Date: 2026-04-16 20:10:05 +0530 (Thu, 16 Apr 2026) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_ReadDataController # 
	(
		parameter [3:0] INITIATOR_NUM				= 4'b0,				// port number
				
		parameter integer NUM_INITIATORS			= 2, 				// defines number of initiators
		parameter integer NUM_INITIATORS_WIDTH		= 1, 				// defines number of bits to encode initiator number
		
		parameter integer NUM_TARGETS     		= 2, 				// defines number of targets
		parameter integer NUM_TARGETS_WIDTH 		= 1,				// defines number of bits to encoode target number

		parameter integer ID_WIDTH   			= 1, 
		parameter integer DATA_WIDTH 			= 32,

		parameter integer SUPPORT_USER_SIGNALS 	= 0,
		parameter integer USER_WIDTH 			= 1,

		parameter integer CROSSBAR_MODE			= 1,				// defines whether non-blocking (ie set 1) or shared access data path

		parameter integer OPEN_RDTRANS_MAX		= 2,
		
		parameter [(16*32)-1:0] NUM_THREADS  	= {16{32'h1}},				// number of independent threads per initiator supported
		parameter [(16*32)-1:0] OPEN_TRANS_MAX	= {16{32'h2}},				// max number of outstanding transactions per thread
		
		parameter [NUM_TARGETS-1:0]		INITIATOR_READ_CONNECTIVITY 		= {NUM_TARGETS{1'b1}},
		
		parameter  HI_FREQ	= 1,										// used to add registers to allow a higher freq of operation at cost of latency
	
		parameter	RD_ARB_EN = 1,										// select arb or ordered rdata
        parameter   PIPE        = 0,
        parameter   CROSSBAR_RAM_TYPE        = 3,
        parameter   SYNC_RESET  = 0
		
   
	)
	(
		// Global Signals
		input  wire                                                    	sysClk,
		input  wire                                                    	arst_sync,			// active low reset synchronoise to RE AClk - asserted async.
		input  wire                                                    	srst_sync,			// active low reset synchronoise to RE AClk - asserted async.
   
		//====================== Target Data Ports  ================================================//
  
		input  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 		TARGET_ID,
		input  wire [NUM_TARGETS*DATA_WIDTH-1:0]    						TARGET_DATA,
		input  wire [NUM_TARGETS*2-1:0]                         			TARGET_RESP,
		input  wire [NUM_TARGETS-1:0]                           			TARGET_LAST,
		input  wire [NUM_TARGETS*USER_WIDTH-1:0]         				    TARGET_USER,
		input  wire [NUM_TARGETS-1:0]                           			TARGET_VALID,
		
		output wire [NUM_TARGETS-1:0]                           			TARGET_READY,		// output will have only 1 bit asserted for target active
		
		//====================== Initiator Data  Ports  ================================================//
		
		output wire [ NUM_INITIATORS_WIDTH + ID_WIDTH-1:0]  	   		initiatorID,
		output wire [DATA_WIDTH-1:0]     								INITIATOR_DATA,
		output wire [1:0]                          						INITIATOR_RESP,
		output wire                             						INITIATOR_LAST,
		output wire [USER_WIDTH-1:0]          							INITIATOR_USER,
		output wire          		                  					INITIATOR_VALID,

		input  wire			                           					INITIATOR_READY,
   
		//====================== DataControl Port ============================================//
		
		output wire	[(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 				currDataTransID,	// current data transaction ID
		output wire	[NUM_TARGETS_WIDTH-1:0]     		    			currdatatrgt,	// current data transaction ID
		output wire					  									openTransDec,		// indicates thread matching currDataTransID to be decremented

		//======================= Read Address Controller Port======================================//
		input wire														rdDataFifoWr,
		input wire	[(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 				rdSrcPort,
		input wire	[NUM_TARGETS_WIDTH-1:0]								rdDestPort
		
	);
   						 

//================================================================================================
// Local Parameters
//================================================================================================

	localparam INITIATORID_WIDTH		= ( NUM_INITIATORS_WIDTH + ID_WIDTH );			// defines width initiatorID - includes infrastructure ID plus ID
	localparam THREAD_VEC_WIDTH		= ( INITIATORID_WIDTH + NUM_TARGETS_WIDTH );	// defines width of per thread vector elements width

	// FIFO depth calculation for RdFifoDualPort.
	// - CROSSBAR_MODE=1: Per-initiator FIFO needs depth based on OPEN_RDTRANS_MAX
	// - CROSSBAR_MODE=0: Shared mode now enforces single outstanding transaction via
	//                    AddressController's shared_mode_busy signal, so minimal depth is sufficient.
	// For shared mode, AWIDTH=2 (depth=4) provides safety margin.
	// For crossbar mode, calculate based on OPEN_RDTRANS_MAX with minimum AWIDTH=3 (depth=8).
	localparam OPEN_RDTRANS_MAX_FIFO_AWIDTH = (CROSSBAR_MODE == 0) ? 2 :   // Shared mode: minimal depth (single outstanding)
	                                          (OPEN_RDTRANS_MAX < 5 ) ? 3 :
	                                          (OPEN_RDTRANS_MAX < 9 ) ? 4 : 
	                                          (OPEN_RDTRANS_MAX < 17) ? 5 : 
											  6;
	
//=================================================================================================
// Local Declarationes
//=================================================================================================

	wire [NUM_TARGETS_WIDTH-1:0]					requestorSelEnc;
	
	wire										requestorSelValid;
	wire										arbEnable;
	wire [NUM_TARGETS-1:0]                       targetValidQual;
	
	wire										rdFifoValid;
	

	generate 
		if ( RD_ARB_EN )		// arb between target_RVALIDs - use when highly variable READ DATA paths
			begin : rdArb
		
				wire [NUM_TARGETS-1:0]			requestorSel;		
				
				//===========================================================================================================
				// caxi4interconnect_RequestQual - only asserted bits in targetValidQual for ports what are requesting access to initiator that
				// matches this caxi4interconnect_ReadDataController instance.
				//============================================================================================================	
				caxi4interconnect_RequestQual #	(
									.NUM_TARGETS 			( NUM_TARGETS ),
									.NUM_INITIATORS_WIDTH		( NUM_INITIATORS_WIDTH ), 	
									.ID_WIDTH   			( ID_WIDTH ),
									.CROSSBAR_MODE			( CROSSBAR_MODE )
								)
						reqQual(
									.TARGET_VALID		( TARGET_VALID ),
									.INITIATOR_NUM			( INITIATOR_NUM ),
									.TARGET_ID			( TARGET_ID ),
									.READ_CONNECTIVITY	( INITIATOR_READ_CONNECTIVITY ),
									.targetValidQual		( targetValidQual )
								) ;
								
								
				//===========================================================================================================
				// Slot Aribrator - performs a round-robin arbitration among valid requestors for ownership
				// of data bus.
				//============================================================================================================
				caxi4interconnect_RoundRobinArb #( .N( NUM_TARGETS ), .N_WIDTH( NUM_TARGETS_WIDTH ), .HI_FREQ ( HI_FREQ )     )
							rrArb 	(
										// global signals
										.sysClk		( sysClk ),
										.arst_sync	( arst_sync ),
										.srst_sync	( srst_sync ),

										.requestor		( targetValidQual ),
										.arbEnable		( arbEnable ),				// arb again when selected initiator asserts increment (only 1 will)						
										.grant			( requestorSel 	 ),			// bit per initiator - 1-bit should only be set
										.grantEnc		( requestorSelEnc 	 ),		// encoded version of requestorSel
										.grantValid		( requestorSelValid )		// asserted when grant is valid
							
									);
									
			end	
		else		// use a caxi4interconnect_FIFO to determine order targets will be serviced
			begin : rdFif
	
					wire 						rdAddrInitiatorWr;
			
					wire [NUM_TARGETS_WIDTH-1:0]	rdfifoRdData;
	
					wire rdFifoEmptyQ1;
					wire rdFifoOverRunErr;
					wire rdFifoUnderRunErr;
					
					// Pick out Infrastructure ID from srcPort to determine which initiator this read is for - in not crossbar mode
					// all AR writes written into caxi4interconnect_FIFO as shared datapath
				// Match comparison widths by truncating INITIATOR_NUM
					assign rdAddrInitiatorWr = rdDataFifoWr & ( CROSSBAR_MODE	? ( rdSrcPort[INITIATORID_WIDTH-1 : ID_WIDTH]  == INITIATOR_NUM[NUM_INITIATORS_WIDTH-1:0] )
																			: 1'b1    );

					//===========================================================================================================
					// caxi4interconnect_RequestQual - only asserted bits in targetValidQual for ports that are requesting access to initiator that
					// matches this caxi4interconnect_ReadDataController instance.
					//============================================================================================================	
					caxi4interconnect_RequestQual #	(
										.NUM_TARGETS 			( NUM_TARGETS ),
										.NUM_INITIATORS_WIDTH		( NUM_INITIATORS_WIDTH ), 	
										.ID_WIDTH   			( ID_WIDTH ),
										.CROSSBAR_MODE			( CROSSBAR_MODE )
									)
						reqQual(
										.TARGET_VALID		( TARGET_VALID ),
										.INITIATOR_NUM			( INITIATOR_NUM ),
										.TARGET_ID			( TARGET_ID ),
										.READ_CONNECTIVITY	( INITIATOR_READ_CONNECTIVITY ),
										.targetValidQual		( targetValidQual )
								);					
								

					//====================================================================================================
					// caxi4interconnect_FIFO to hold open read transactions - pushed on Address read cycle and popped on read data
					// cycle.
					//=====================================================================================================
					caxi4interconnect_RdFifoDualPort #        (
					                    .HI_FREQ              ( HI_FREQ                        ),
										.FIFO_AWIDTH          ( OPEN_RDTRANS_MAX_FIFO_AWIDTH   ),
										.FIFO_WIDTH           ( NUM_TARGETS_WIDTH              ),
										.NEAR_FULL            ( 'd2                            ),
										.NUM_TARGETS          ( NUM_TARGETS                    ),
										.PIPE                 ( PIPE                           ),
										.CROSSBAR_RAM_TYPE    ( CROSSBAR_RAM_TYPE              ),
										.SYNC_RESET           ( SYNC_RESET                     )
	                            )
						rdFif	(
										.HCLK(	sysClk ),
										.fifo_areset( arst_sync ),
										.fifo_sreset( srst_sync ),
					
										// Write Port
										.fifoWrite( rdAddrInitiatorWr ),
										.fifoWrData( rdDestPort ),				// target read from

										// Read Port
										.fifoRead( arbEnable ),
										.fifoRdData( rdfifoRdData ),
										.targetValidQual( targetValidQual ),
										.requestorSelValid( requestorSelValid ),
					
										// Status bits
										.fifoRdValid ( rdFifoValid ),
										.fifoOverRunErr( rdFifoOverRunErr ),
										.fifoUnderRunErr( rdFifoUnderRunErr )
								);
 
					
					assign requestorSelEnc 	 = rdfifoRdData;

   							
			end

	endgenerate
	

	
	//===========================================================================================================
	// Target Data Mux and Control - performs the MUX of target requestor data vector to initiator and
	// controls response from initiator. 
	//============================================================================================================
	
	caxi4interconnect_ReadDataMux # 
		(
			.NUM_INITIATORS_WIDTH			( NUM_INITIATORS_WIDTH         ), 			// defines number of bits to encode initiator number
			
			.NUM_TARGETS     			    ( NUM_TARGETS                  ), 				// defines number of targets
			.NUM_TARGETS_WIDTH 			    ( NUM_TARGETS_WIDTH            ),			// defines number of bits to encoode target number

			.ID_WIDTH   				    ( ID_WIDTH                     ), 
			.DATA_WIDTH 				    ( DATA_WIDTH                   ),
		
			.SUPPORT_USER_SIGNALS 		    ( SUPPORT_USER_SIGNALS         ),
			.USER_WIDTH 				    ( USER_WIDTH                   ),

			.INITIATOR_READ_CONNECTIVITY 	( INITIATOR_READ_CONNECTIVITY  ),
			.RD_ARB_EN 	                    ( RD_ARB_EN                    )
			
   
		)
	rdmx	(
			// Global Signals
			.sysClk 	( sysClk ),
			.arst_sync	( arst_sync ),					// active low reset synchronoise to RE AClk - asserted async.
			.srst_sync	( srst_sync ),					// active low reset synchronoise to RE AClk - asserted async.

			// Slot Arbitrator
			.requestorSelValid( requestorSelValid ),	// indicates that slot arb has selected valid requestor to drive to Target
			.requestorSelEnc( requestorSelEnc 	),		// indicates requestor selected by slot arb when requestorSelValid is asserted
			.arbEnable		( arbEnable			),
		
			// Target Data Ports
			.TARGET_ID( TARGET_ID ),
			.TARGET_DATA( TARGET_DATA ),
			.TARGET_RESP( TARGET_RESP ),
			.TARGET_LAST( TARGET_LAST ),
			.TARGET_USER( TARGET_USER ),
			.TARGET_VALID( TARGET_VALID ),
			.TARGET_READY( TARGET_READY ),
		
			// Initiator Data  Ports
			.initiatorID( initiatorID ),
			.INITIATOR_DATA( INITIATOR_DATA ),
			.INITIATOR_RESP( INITIATOR_RESP ),
			.INITIATOR_LAST( INITIATOR_LAST ),
			.INITIATOR_USER( INITIATOR_USER ),
			.INITIATOR_VALID( INITIATOR_VALID ),
			.INITIATOR_READY( INITIATOR_READY ),
			
			// AddressControl Port 		
			.currDataTransID( currDataTransID ),	// current data transaction ID
			.currdatatrgt( currdatatrgt ),	// current data transaction ID
			.openTransDec( openTransDec ),			// indicates thread matching currDataTransID to be decremented   
			.targetValidQual (targetValidQual)
		) ;

 
		
endmodule // caxi4interconnect_ReadDataController.v
