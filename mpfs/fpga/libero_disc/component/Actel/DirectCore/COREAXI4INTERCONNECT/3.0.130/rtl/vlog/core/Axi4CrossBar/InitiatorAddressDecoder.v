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

module caxi4interconnect_InitiatorAddressDecoder (
								src_addr,
								match,					
								targetMatched
							 );


//===================================================
// Parameter Declarations
//===================================================

	parameter NUM_TARGETS_WIDTH 	= 4;				// defines number bits for encoding target number
	parameter NUM_TARGETS 		= 4;				// defines number of targets	- includes derrTarget
	parameter TARGET_NUM	 		= 0;				// defines target that this decoder is for
	parameter ADDR_WIDTH 		= 32;				// number of address buts to be decoded
	
	parameter UPPER_COMPARE_BIT = 15;				// Defines the upper bit of range to compare
	parameter LOWER_COMPARE_BIT = 12;				// Defines lower bound of compare - bits below are 
													// dont care
													
	parameter [ADDR_WIDTH-1:UPPER_COMPARE_BIT]			SLOT_BASE_ADDR = 0;		// Base address of Slot
	parameter [UPPER_COMPARE_BIT-1:LOWER_COMPARE_BIT]   SLOT_MIN_ADDR = 0;		// slot min address
	parameter [UPPER_COMPARE_BIT-1:LOWER_COMPARE_BIT]   SLOT_MAX_ADDR = 0;		// slot max address
	parameter [NUM_TARGETS-1:0]							CONNECTIVITY = {NUM_TARGETS{1'b1}};	// onnectivity map - ie which targets this initiator can access
	
//==========================================================================
// I/O Declarations
//============================================================================

	input 	[ADDR_WIDTH-1:0]		src_addr;		// address to be decoded

	output							match;			// Indictaes this target matched address
	output 	[NUM_TARGETS_WIDTH-1:0]	targetMatched;	// encoded number of target
	
	
//============================================================================
// Local Declarationes
//============================================================================


	reg								match;			// Indictaes this target matched address
	wire 	[NUM_TARGETS_WIDTH-1:0] 	targetMatched;	// encoded number of target
	
 
 
//==============================================================================
// Simple decode matching
//==============================================================================

assign targetMatched = TARGET_NUM;		// simply return number of target instance

always @( * )
begin
	match  =    	( src_addr[UPPER_COMPARE_BIT-1:LOWER_COMPARE_BIT] >= SLOT_MIN_ADDR	 )
				&	( src_addr[UPPER_COMPARE_BIT-1:LOWER_COMPARE_BIT] <= SLOT_MAX_ADDR	 )
				&	CONNECTIVITY[TARGET_NUM];														// only match if initiator can access this target

end

//


endmodule // caxi4interconnect_InitiatorAddressDecoder.v
