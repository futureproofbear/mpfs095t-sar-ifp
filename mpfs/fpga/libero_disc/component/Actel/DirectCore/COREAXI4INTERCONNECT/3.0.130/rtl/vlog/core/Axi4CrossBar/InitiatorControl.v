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
// SVN $Revision: 44682 $
// SVN $Date: 2023-10-28 01:51:11 +0530 (Sat, 28 Oct 2023) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns
module caxi4interconnect_InitiatorControl # 
	(
		parameter NUM_TARGETS 			                                                              = 4,		// defines number of targets - includes internal DERR Target
		parameter NUM_TARGETS_WIDTH 		                                                          = 2,		// defines number of bits to encoode target number

		parameter INITIATORID_WIDTH		                                                              = 4,		// defines number of bits to in dst_intrid - includes Infrastructure ID + requestor ID
	
		parameter ADDR_WIDTH 			                                                              = 32,		// number of address bits to be decoded

		parameter NUM_THREADS			                                                              = 1,		// defined number of indpendent threads per initiator supported 
		parameter OPEN_TRANS_MAX		                                                              = 3,		// max number of outstanding transactions 

		parameter UPPER_COMPARE_BIT 	                                                              = 15,		// Defines the upper bit of range to compare
		parameter LOWER_COMPARE_BIT 	                                                              = 12,		// Defines lower bound of compare - bits below are dont care

		// Define memory map for targets - none for DERR target
		parameter [ ( ( NUM_TARGETS-1)* (ADDR_WIDTH-UPPER_COMPARE_BIT) )-1 : 0 ] 		SLOT_BASE_VEC = 0,		// SLOT Base per target 
		parameter [ ( ( NUM_TARGETS-1)* (UPPER_COMPARE_BIT-LOWER_COMPARE_BIT))-1 : 0 ] 	SLOT_MIN_VEC  = 0,		// SLOT Min per target 
		parameter [ ( ( NUM_TARGETS-1)* (UPPER_COMPARE_BIT-LOWER_COMPARE_BIT))-1 : 0 ] 	SLOT_MAX_VEC  = 1,		// SLOT Max per target 
		parameter [NUM_TARGETS-1:0]		CONNECTIVITY		                                          = { NUM_TARGETS{1'b1} }, 							// onnectivity map
		parameter  WR_MODULE                                                                          = 1,   
		parameter  ACHNL_WIDTH                                                                        = 80,   
		parameter  AUSER_WIDTH                                                                        = 1,   
		parameter  [NUM_TARGETS-1:0] TARGET_READ_INTERLEAVE                                           = 0   
	)
	(
		// Global Signals
		input  wire							sysClk,
		input  wire							arst_sync,					// active low reset synchronoise to RE AClk - asserted async.
		input  wire							srst_sync,					// active low reset synchronoise to RE AClk - asserted async.
   
		//========================== Initiator Port ==========================================
		input wire 	[ADDR_WIDTH-1:0]		src_addr,					// address to be decoded
		input wire							dst_intravalid,				// indicates Initiator has a valid address available
	    output wire                         dst_intraready,
		input wire	[INITIATORID_WIDTH-1:0]	dst_intrid,					// unique ID per infrastructure Initiator port - includes infrastructure + ID


		//========================== SlotArbitrator Port  ===================================
		output wire							validQual,					// Indictaes this target matched address

		//========= caxi4interconnect_TargetMuxController Port ======================//
		input wire							openTransInc,				// Increment openTransVec for thread matching currTransID
		output wire	[NUM_TARGETS_WIDTH-1:0]	currTransTargetID,			// targetID for current transaction			
		output wire	[INITIATORID_WIDTH-1:0]	currTransID,			// targetID for current transaction			


		//========= DataControl Port =============================//
		input wire	[INITIATORID_WIDTH-1:0] 	currDataTransID,			// current data transaction ID
		input wire	[NUM_TARGETS_WIDTH-1:0]  	currdatatrgt,				// indicates thread matching currDataTransID to be decremented
		input wire							    openTransDec,
		output wire	[NUM_TARGETS-2:0]   	    targetMatch,
		input   	[NUM_TARGETS-2:0]   	    dst_trgtmatch

	);
   						 
//==================================================================================================
// Local Declarations
//==================================================================================================						 

	wire	                 			threadValid;

 	wire								currTransTargetValid;			// asserted when currTransTargetID is valid
    wire                                query_valid;
    wire    [NUM_TARGETS_WIDTH-1:0]     query_target_id;
    wire    [INITIATORID_WIDTH-1:0]     query_trans_id;
	
//====================================================================================================

						 
	caxi4interconnect_DependenceChecker #(
							.NUM_TARGETS 		    ( NUM_TARGETS            ),				// defines number of targets
							.NUM_TARGETS_WIDTH 	    ( NUM_TARGETS_WIDTH      ),		// defines number of bits to encoode target number
							.INITIATORID_WIDTH		( INITIATORID_WIDTH      ),			// defines number of bits to in dst_intrid - includes Infrastructure ID + requestor ID

							.ADDR_WIDTH 		    ( ADDR_WIDTH             ),				// number of address bits to be decoded

						
							.UPPER_COMPARE_BIT 	    ( UPPER_COMPARE_BIT      ),		// Defines the upper bit of range to compare
							.LOWER_COMPARE_BIT 	    ( LOWER_COMPARE_BIT      ),		// Defines lower bound of compare - bits below are dont care
													
							.SLOT_BASE_VEC          ( SLOT_BASE_VEC          ),				// Base address of Slot
							.SLOT_MIN_VEC           ( SLOT_MIN_VEC           ), 				// slot min address in decoded space
							.SLOT_MAX_VEC           ( SLOT_MAX_VEC           ),				// slot max address in decoded space
							.CONNECTIVITY	        ( CONNECTIVITY           ),
							.ACHNL_WIDTH	        ( ACHNL_WIDTH            ),
							.AUSER_WIDTH  	        ( AUSER_WIDTH            ),
							.TARGET_READ_INTERLEAVE ( TARGET_READ_INTERLEAVE )
						
						)
					depck 	(
					            .sysClk              ( sysClk               ),
					            .arst_sync           ( arst_sync            ),
					            .srst_sync           ( srst_sync            ),
								.src_addr		     ( src_addr 	        ),
								.dst_intravalid	     ( dst_intravalid 	    ),
								.dst_intraready	     ( dst_intraready 	    ),
								.dst_intrid		     ( dst_intrid 		    ),
								.threadValid	     ( threadValid 	        ),
								.currTransTargetValid( currTransTargetValid ),	// asserted when currTransTargetID is valid
								.currTransTargetID   ( currTransTargetID    ),			// targetID for current transaction
								.currTransID	     ( currTransID 	        ),
								.validQual		     ( validQual 	        ),
	                            .query_valid         ( query_valid          ),
	                            .query_target_id     ( query_target_id      ),		
	                            .query_trans_id      ( query_trans_id       ),		
	                            .targetMatch         ( targetMatch          ),		
	                            .dst_trgtmatch       ( dst_trgtmatch        )		
							);		
								
		
		
	caxi4interconnect_TransactionController #(
							.NUM_TARGETS_WIDTH 	    ( NUM_TARGETS_WIDTH ),		
							.INITIATORID_WIDTH		( INITIATORID_WIDTH ),			// defines number of bits to in dst_intrid - includes Infrastructure ID + requestor ID
							.NUM_THREADS		    ( NUM_THREADS       ),			// defined number of indpendent threads per initiator supported 
							.OPEN_TRANS_MAX		    ( OPEN_TRANS_MAX    ),			// max number of outstanding transactions 
							.WR_MODULE      	    ( WR_MODULE         )	    
							)
					trnscon (	
								.sysClk				( sysClk              ),
					            .arst_sync          ( arst_sync           ),
					            .srst_sync          ( srst_sync           ),								
								.currTransTargetID	( currTransTargetID    ),				// targetID for current transaction
								.currTransID		( currTransID         ),					// ID for current transaction						
								.threadValid		( threadValid         ),
								.openTransInc		( openTransInc        ),
								.currDataTransID	( currDataTransID     ),
								.currdatatrgt 	    ( currdatatrgt        ),
								.openTransDec		( openTransDec        ),
	                            .query_valid        ( query_valid         ),
	                            .query_target_id    ( query_target_id     ),
	                            .query_trans_id     ( query_trans_id      )
							);


	
endmodule // caxi4interconnect_InitiatorControl.v
