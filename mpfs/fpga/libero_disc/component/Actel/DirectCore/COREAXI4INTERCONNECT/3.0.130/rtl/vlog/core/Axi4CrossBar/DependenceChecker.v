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
// SVN $Revision: 51465 $
// SVN $Date: 2026-05-07 06:31:35 -0400 (Thu, 07 May 2026) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_DependenceChecker #
(
	parameter NUM_TARGETS 			                                                                  = 4,		// defines number of targets	- includes derrTarget
	parameter NUM_TARGETS_WIDTH 	                                                                  = 2,		// defines number of bits to encoode target number - includes derrTarget

	parameter INITIATORID_WIDTH		                                                                  = 4,		// defines number of bits to in initiatorID - includes Infrastructure ID + requestor ID
	
	parameter ADDR_WIDTH 			                                                                  = 32,		// number of address bits to be decoded


	parameter UPPER_COMPARE_BIT 	                                                                  = 15,		// Defines the upper bit of range to compare
	parameter LOWER_COMPARE_BIT 	                                                                  = 12,		// Defines lower bound of compare - bits below are dont care

	// No address space defined for derrSlace
	parameter [ ( (NUM_TARGETS-1)* (ADDR_WIDTH-UPPER_COMPARE_BIT) )-1 : 0 ] 		SLOT_BASE_VEC     = 0,		// SLOT Base per target 
	parameter [ ( (NUM_TARGETS-1)* (UPPER_COMPARE_BIT-LOWER_COMPARE_BIT))-1 : 0 ] 	SLOT_MIN_VEC      = 0,		// SLOT Min per target 
	parameter [ ( (NUM_TARGETS-1)* (UPPER_COMPARE_BIT-LOWER_COMPARE_BIT))-1 : 0 ] 	SLOT_MAX_VEC      = 1,		// SLOT Max per target 

	parameter [NUM_TARGETS-1:0]		CONNECTIVITY	                                                  = {NUM_TARGETS{1'b1}},			// onnectivity map - ie which targets this initiator can access
	parameter                       ACHNL_WIDTH                                                       = 80,   
	parameter                       AUSER_WIDTH                                                       = 1,   
	parameter [NUM_TARGETS-1:0]     TARGET_READ_INTERLEAVE                                            = 1,   
	parameter                       ID_WIDTH                                                          = 1   

)
(
	input                                            sysClk,
	input                                            arst_sync,
	input                                            srst_sync,
	//========================== Initiator Port ==========================================

	input 	[ADDR_WIDTH-1:0]			             src_addr,									// address to be decoded
	input								             dst_intravalid,								    // indicates Initiator has a valid address available
	output                                           dst_intraready,
										             
	input	[INITIATORID_WIDTH-1:0]		             dst_intrid,									// unique ID per infrastructure Initiator port - includes infrastructure + ID

	//========================== caxi4interconnect_TransactionController Port ===========================
	
	input	                     		             threadValid,								// indicates matched currTransID and threadCount and threadTargetID valid
										             
	output								             currTransTargetValid,						// asserted when currTransTargetID is valid
	output	[NUM_TARGETS_WIDTH-1:0] 	             currTransTargetID,							// matched targetID
	output	[INITIATORID_WIDTH-1:0]		             currTransID,								// ID for current transaction


	//========================== SlotArbitrator Port  ===================================
	
	output								             validQual,									// Indictaes this target matched address
										             
	output reg                                       query_valid,
	output reg [NUM_TARGETS_WIDTH-1:0]               query_target_id,
	output reg [INITIATORID_WIDTH-1:0]               query_trans_id, 
										             
    output     [NUM_TARGETS-2:0]                     targetMatch, 	
    input      [NUM_TARGETS-2:0]                     dst_trgtmatch   
);

	
//=====================================================================================
// Local Declarations
//=====================================================================================

	localparam	[NUM_TARGETS_WIDTH-1:0]	DERR_TARGETID	= NUM_TARGETS-1;				// Target ID for DERR Target
	
    localparam ONEHOT_WIDTH                             = NUM_TARGETS-2;
    localparam BIN_WIDTH                                = (ONEHOT_WIDTH < 2) ? 1 : $clog2(ONEHOT_WIDTH);
	



	
	
	wire	[NUM_TARGETS-1:0]			validQualVec;							// Indictaes target matched - one-hot encoded
																				// (MSB is derrTarget)
	
	// Intermediate wire to capture fnc_hot2enc result for bit-select
	wire    [NUM_TARGETS_WIDTH-1:0]     hot2enc_trgtmatch;


	
	//=====================================================================================
	// Generates a binary coded from onehotone encoded
	//====================================================================================
	function [NUM_TARGETS_WIDTH-1:0] fnc_hot2enc
    (
      input [31:0]  one_hot
    );
        integer enc_i;
        begin
            fnc_hot2enc = {NUM_TARGETS_WIDTH{1'b0}};
            for (enc_i = 0; enc_i < 32; enc_i = enc_i + 1) begin
                if (one_hot[enc_i]) begin
                    fnc_hot2enc = enc_i;
                end
            end
        end
    endfunction	
	

	//================================================================================================
	// Generare a Initiator Address Decoder for each configured target - but not for not derrTarget
	//================================================================================================
	
		
	genvar i;
	generate
		for (i=0; i< NUM_TARGETS-1; i=i+1 )		// do not decode for derrTarget
			begin
				caxi4interconnect_InitiatorAddressDecoder #
				   ( 	
				        .NUM_TARGETS_WIDTH	( NUM_TARGETS_WIDTH 	                                          ), // defines number of targets
						.NUM_TARGETS		( NUM_TARGETS-1	   	                                              ), // defines number of targets	- does not include derrTarget
						.TARGET_NUM	 	  	( i 				                                              ), // defines target that this decoder is for
						.ADDR_WIDTH 	 	( ADDR_WIDTH		                                              ), // number of address bits to be decoded
						.UPPER_COMPARE_BIT  ( UPPER_COMPARE_BIT                                               ), // Defines the upper bit of range to compare
						.LOWER_COMPARE_BIT  ( LOWER_COMPARE_BIT                                               ), // Defines lower bound of compare - bits below are dont care
						.SLOT_BASE_ADDR		( SLOT_BASE_VEC[ (i+1)*(ADDR_WIDTH-UPPER_COMPARE_BIT)-1: 
						                                      i*(ADDR_WIDTH-UPPER_COMPARE_BIT)]               ), // slot base address
						.SLOT_MIN_ADDR		( SLOT_MIN_VEC [ ((i+1)*(UPPER_COMPARE_BIT-LOWER_COMPARE_BIT))-1:
						                                      i*(UPPER_COMPARE_BIT-LOWER_COMPARE_BIT)]        ), // slot min address
						.SLOT_MAX_ADDR 		( SLOT_MAX_VEC [ ((i+1)*(UPPER_COMPARE_BIT-LOWER_COMPARE_BIT))-1:
						                                      i*(UPPER_COMPARE_BIT-LOWER_COMPARE_BIT) ]       ), // slot max address
						.CONNECTIVITY		( CONNECTIVITY[NUM_TARGETS-1:0]	                                  )	 // connectivity map - ie which targets this initiator can access

					)
				u_InitrAdrDec 
					(
						.src_addr            ( src_addr                                           ),					
						.match               ( targetMatch[i]                                     ),					
						.targetMatched       (                                                    )
					);
	
				
				//=====================================================================================================
				// Check dependancy of current request to avoid deadlocks - this transaction is qualified to
				// request arbitration if valid asserted (ie active request) and if (a) there are no outstanding
				// transactions for thread or (b) the current transaction matches target (ie targetID) of outstanding
				// transaction and not reached max outstanding transactions for this thread.
				//=====================================================================================================
                 
				assign 	validQualVec[i]     = (dst_intravalid & dst_trgtmatch[i] & threadValid);					// not reach max open transaction
                
			end
	endgenerate

	assign currTransTargetValid = ( dst_trgtmatch != 0 );						// asserted when a target has been decoded

	//===========================================================================================================
	// Define validQualVec for Derr Target to be same as other targets to allow normal logic transInc/Dec to work
	// - bar only decoded when no other target decoded.
	//===========================================================================================================

	assign validQualVec[NUM_TARGETS-1]	= dst_intravalid & !currTransTargetValid;
														
	// Explicit bit-select to match NUM_TARGETS_WIDTH (fnc_hot2enc returns 5 bits for max 32 targets)
	// Avoid zero-width replication when all 32 external targets are present.
	generate
		if ((NUM_TARGETS-1) == 32) begin : gen_hot2enc_full
			assign hot2enc_trgtmatch = fnc_hot2enc(dst_trgtmatch);
		end else begin : gen_hot2enc_extend
			assign hot2enc_trgtmatch = fnc_hot2enc({{(32-(NUM_TARGETS-1)){1'b0}}, dst_trgtmatch});
		end
	endgenerate
	assign currTransTargetID            = currTransTargetValid ? hot2enc_trgtmatch
										                	   : DERR_TARGETID;
															   
    always@(*) begin 
      query_valid                 = dst_intravalid;				
      query_target_id             = currTransTargetID;
      query_trans_id              = currTransID; 
    end 
							            
	assign  currTransID           = dst_intrid;
	//assign  currTransID           = TARGET_READ_INTERLEAVE[fnc_hot2enc(dst_trgtmatch)] == 1'b1 ?  dst_intrid : 
	//                                {dst_intrid[INITIATORID_WIDTH-1:ID_WIDTH],{ID_WIDTH{1'b0}}};	// ID for current transaction
							            
	assign	validQual             = ( validQualVec == 0 ) ? 1'b0 : 1'b1;		// assert if any bit in vector set.

	assign  dst_intraready        = threadValid;
	
endmodule // caxi4interconnect_DependenceChecker.v
