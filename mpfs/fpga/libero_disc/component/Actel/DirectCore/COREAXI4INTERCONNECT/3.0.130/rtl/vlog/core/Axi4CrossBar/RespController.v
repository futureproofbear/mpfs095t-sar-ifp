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
// SVN $Revision: 49514 $
// SVN $Date: 2025-08-10 00:53:16 +0530 (Sun, 10 Aug 2025) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_RespController # 
	(
		parameter integer NUM_INITIATORS			= 2, 				// defines number of initiators
		parameter integer NUM_INITIATORS_WIDTH		= 1, 				// defines number of bits to encode initiator number
		
		parameter integer NUM_TARGETS     		    = 2, 			    // defines number of targets
		parameter integer NUM_TARGETS_WIDTH 		= 1,				// defines number of bits to encoode target number

		parameter integer ID_WIDTH   			= 1, 

		parameter integer SUPPORT_USER_SIGNALS 	= 0,
		parameter integer USER_WIDTH 			= 1,

		parameter [NUM_INITIATORS*NUM_TARGETS-1:0] 		INITIATOR_WRITE_CONNECTIVITY 		= {NUM_INITIATORS*NUM_TARGETS{1'b1}},
		parameter [NUM_INITIATORS*NUM_TARGETS-1:0] 		INITIATOR_READ_CONNECTIVITY 		= {NUM_INITIATORS*NUM_TARGETS{1'b1}},
		
		parameter	HI_FREQ						= 0					// used to add registers to allow a higher freq of operation at cost of latency
   
	)
	(
		// Global Signals
		input  wire                                                    	sysClk,
		input  wire                                                    	arst_sync,			// active low reset synchronoise to RE AClk - asserted async.
		input  wire                                                    	srst_sync,			// active low reset synchronoise to RE AClk - asserted async.
   
		//====================== Target Data Ports  ================================================//
  
		input  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 		TARGET_ID,
		input  wire [NUM_TARGETS*2-1:0]                         			TARGET_RESP,
		input  wire [NUM_TARGETS*USER_WIDTH-1:0]         				    TARGET_USER,
		input  wire [NUM_TARGETS-1:0]                           			TARGET_VALID,
		
		output wire [NUM_TARGETS-1:0]                           			TARGET_READY,
		
		//====================== Initiator Data  Ports  ================================================//

		output wire [NUM_INITIATORS*ID_WIDTH-1:0]          				    INITIATOR_ID,
		output wire [NUM_INITIATORS*2-1:0]                          		INITIATOR_RESP,
		output wire [NUM_INITIATORS*USER_WIDTH-1:0]          				INITIATOR_USER,
		output wire [NUM_INITIATORS-1:0]                            		INITIATOR_VALID,

		input  wire [NUM_INITIATORS-1:0]                            		INITIATOR_READY,
   
		//====================== DataControl Port ============================================//
		
		output wire	[NUM_INITIATORS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 	currDataTransID,	// current data transaction ID
		output wire	[(NUM_INITIATORS*NUM_TARGETS_WIDTH)-1:0]            	currdatatrgt,	// current data transaction ID
		output wire	[NUM_INITIATORS-1:0]  									openTransDec		// indicates thread matching currDataTransID to be decremented
	
	);
   						 
						 
//================================================================================================
// Local Parameters
//================================================================================================

	localparam INITIATORID_WIDTH		= ( NUM_INITIATORS_WIDTH + ID_WIDTH );			// defines width initiatorID - includes infrastructure ID plus ID
	localparam THREAD_VEC_WIDTH		    = ( INITIATORID_WIDTH + NUM_TARGETS_WIDTH );	// defines width of per thread vector elements width

	
//=================================================================================================
// Local Declarationes
//=================================================================================================
 	wire	[NUM_TARGETS-1:0]					requestorSel;
	wire	[NUM_TARGETS_WIDTH-1:0]				requestorSelEnc;
	wire										requestorSelValid;
	wire										arbEnable;
	
	
	//===========================================================================================================
	// Slot Aribrator - performs a round-robin arbitration among valid requestors for ownership
	// of data bus.
	//============================================================================================================
	caxi4interconnect_RoundRobinArb #( .N( NUM_TARGETS ), .N_WIDTH( NUM_TARGETS_WIDTH ), .HI_FREQ( HI_FREQ )    )
				rrArb 	(
							// global signals
							.sysClk		( sysClk ),
							.arst_sync	( arst_sync ),
							.srst_sync	( srst_sync ),

							.requestor		( TARGET_VALID ),
							.arbEnable		( arbEnable ),				// arb again when selected initiator asserts increment (only 1 will)						
							.grant			( requestorSel 	 ),			// bit per initiator - 1-bit should only be set
							.grantEnc		( requestorSelEnc 	),		// encoded version of requestorSel
							.grantValid		( requestorSelValid )		// asserted when grant is valid
				
						);
	
	
	
	//===========================================================================================================
	// Target Data Mux and Control - performs the MUX of target requestor data vector to initiator and
	// controls response from initiator. 
	//============================================================================================================
	
	caxi4interconnect_TargetDataMuxController # 
		(
			.NUM_INITIATORS				( NUM_INITIATORS ), 				// defines number of initiators
			.NUM_INITIATORS_WIDTH			( NUM_INITIATORS_WIDTH ), 			// defines number of bits to encode initiator number
			
			.NUM_TARGETS     			( NUM_TARGETS ), 				// defines number of targets
			.NUM_TARGETS_WIDTH 			( NUM_TARGETS_WIDTH ),			// defines number of bits to encoode target number

			.ID_WIDTH   				( ID_WIDTH ), 
		
			.SUPPORT_USER_SIGNALS 		( SUPPORT_USER_SIGNALS ),
			.USER_WIDTH 				( USER_WIDTH   ),

			.INITIATOR_READ_CONNECTIVITY 	( INITIATOR_READ_CONNECTIVITY  )
   
		)
	slmx	(
			// Global Signals
			.sysClk 	( sysClk ),
			.arst_sync	( arst_sync ),					// active low reset synchronoise to RE AClk - asserted async.
			.srst_sync	( srst_sync ),					// active low reset synchronoise to RE AClk - asserted async.

			// Slot Arbitrator
			.requestorSelValid( requestorSelValid ),	// indicates that slot arb has selected valid requestor to drive to Target
			.requestorSelEnc( requestorSelEnc	),		// indicates requestor selected by slot arb when requestorSelValid is asserted			
			.arbEnable		( arbEnable			),
		
			// Target Data Ports
			.TARGET_ID( TARGET_ID ),
			.TARGET_RESP( TARGET_RESP ),
			.TARGET_USER( TARGET_USER ),
			.TARGET_VALID( TARGET_VALID ),
			.TARGET_READY( TARGET_READY ),
		
			// Initiator Data  Ports
			.INITIATOR_ID( INITIATOR_ID ),
			.INITIATOR_RESP( INITIATOR_RESP ),
			.INITIATOR_USER( INITIATOR_USER ),
			.INITIATOR_VALID( INITIATOR_VALID ),
			.INITIATOR_READY( INITIATOR_READY ),
			
			// AddressControl Port 		
			.currDataTransID( currDataTransID ),	// current data transaction ID
			.currdatatrgt( currdatatrgt ),	// current data transaction ID
			.openTransDec( openTransDec )			// indicates thread matching currDataTransID to be decremented   
		);

 
		
endmodule // caxi4interconnect_RespController.v
