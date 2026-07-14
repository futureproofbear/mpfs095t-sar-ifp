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

module caxi4interconnect_RequestQual # 
	(
		parameter integer NUM_TARGETS 			= 8, 				// defines number of targets requestors  
		parameter integer NUM_INITIATORS_WIDTH		= 1, 				// defines number of bits to encode initiator number
		parameter integer ID_WIDTH   			= 1,
		parameter integer CROSSBAR_MODE			= 1				// defines whether non-blocking (ie set 1) or shared access data path
	)
	(
		input  wire [NUM_TARGETS-1:0]    								TARGET_VALID,
		input  wire [3:0]                                   			INITIATOR_NUM,     // jhayes : change to width to match maximum width possible.
  		input  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 		TARGET_ID,
		input  wire [NUM_TARGETS-1:0]									READ_CONNECTIVITY,
		
		output  reg [NUM_TARGETS-1:0]    								targetValidQual
	);
						 
//================================================================================================
// Local Parameters
//================================================================================================
	localparam INITIATORID_WIDTH		= ( NUM_INITIATORS_WIDTH + ID_WIDTH );			// defines width initiatorID - includes infrastructure ID plus ID


//=================================================================================================
// Local Declarationes
//=================================================================================================
	reg	[NUM_INITIATORS_WIDTH-1:0]		dst_target_id	[0:NUM_TARGETS-1];

//=================================================================================================

genvar i;
generate 
	for (i=0; i < NUM_TARGETS; i=i+1)
		begin
			always @(*)
				begin
				// pick out infrastructure component from TARGET_ID - ie target initiator
				dst_target_id[i] 	= TARGET_ID[(i+1)*INITIATORID_WIDTH-1:(i*INITIATORID_WIDTH)+ ID_WIDTH];
			
				// Only assert targetValidQual to arbitrator when target valid is asserted and the TARGET_ID is targetting this
				// initiator and READ_CONNECTIVITY is set for this target
				targetValidQual[i]	= READ_CONNECTIVITY[i] & TARGET_VALID[i] &  
												( CROSSBAR_MODE ?  ( dst_target_id[i] == INITIATOR_NUM[NUM_INITIATORS_WIDTH-1:0] )    // jhayes : change to use relevant bits of INITIATOR_NUM for comparison.
															    : 1'b1 );	// all targets arb togather in non-crossbar mode - does not
																			// matter which initiator they want to connect to - only one path
				end
		end
		
endgenerate


endmodule // caxi4interconnect_RequestQual.v
