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

module caxi4interconnect_RoundRobinArb (
						// global signals
						sysClk,
						arst_sync,
						srst_sync,

						requestor,
						arbEnable,					
						grant,
						grantEnc,
						grantValid
				   
					  );


//===================================================
// Parameter Declarations
//===================================================

	parameter N = 2;							// defines number bits for requestors/grants
	parameter N_WIDTH = 1;						// defines number bits for number of requestors/grants
	
	parameter HI_FREQ 			= 0;			// increases freq of operation at cost of added latency
	
	
	//===============================================
	// Memory Map - Word addressing
	//===============================================
	localparam STATUS_WORD 		= 5'h00;

	
//============================================================================
// I/O Declarations
//============================================================================

	input sysClk;									// system clock
	input arst_sync;									// system reset - synchronse to sysClk - active high
	input srst_sync;									// system reset - synchronse to sysClk - active high
	
	
	input 	[N-1:0]	requestor;						// requestors to be arbitrated between
	input			arbEnable;						// Indictaes when an arbitration should be performs among requestors
	
	output 	[N-1:0] grant;							// winner of arbitration will have grant bit set - available 1 clock tick after
													// arbEnable asserted.
	output	[N_WIDTH-1:0]	grantEnc;				// encoded version of grant which is one-hot.

	output			grantValid;						// asserted when grant is valid
//============================================================================
// Local Declarationes
//============================================================================

 reg [N-1:0]		grant;
 wire [N-1:0]		d_grant;
 
 reg [N_WIDTH-1:0]	grantEnc;				// encoded version of grant which is one-hot.

 reg			grantValid;			

 reg [N-1:0]	priorityMask;					// mask to remove winner and lower requestors
 
 reg [N-1:0]	requestorMasked;				// requestor has "granted" masked out when arbEnable asserted (as source will still be driving last request

 wire [N-1:0] 	reqMasked, mask_higher_pri_reqs, grantMasked;
 wire [N-1:0]	unmask_higher_pri_reqs, grantUnmasked;
 wire			no_req_masked;
 
 // Intermediate wire to capture fnc_hot2enc result for bit-select
 wire [N_WIDTH-1:0]     hot2enc_d_grant;

 
//===============================================================================================
// Convert N-bit one-hot to N_WIDTH-bit binary (parameterized loop-based encoder)
//===============================================================================================
function [N_WIDTH-1:0] fnc_hot2enc;
    input [N-1:0] oneHot;
    integer i;
    begin
        fnc_hot2enc = {N_WIDTH{1'b0}};
        for (i = 0; i < N; i = i + 1)
            if (oneHot[i]) fnc_hot2enc = i[N_WIDTH-1:0];
    end
endfunction

// Assign fnc_hot2enc result to wire for bit-select in sequential logic
assign hot2enc_d_grant = fnc_hot2enc(d_grant);
 
//==================================================================================
// Mask out granted request when grantValid asserted as source still driving request
//===================================================================================
generate
	if ( HI_FREQ == 1 )
		begin

			always @(posedge sysClk or negedge arst_sync)
				begin
				    if(~arst_sync | ~srst_sync)
					  requestorMasked <= 0;
					else if ( grantValid )
					  requestorMasked <= { requestor & ( ~( grant ) ) };
					else 														// handle fact we have add pipeline stage - about to set grantValid
					  requestorMasked <= { requestor & ( ~( d_grant ) ) };	// mask out questor selected in case arbEnable asserted
																				// immediately
				end
		end
	else
		begin
			always @( * )
				begin
					requestorMasked = { requestor & ( ~( grant & { N{grantValid} } ) ) };
				end		

		end

endgenerate



//==============================================================================
// Simple priority arbitration for masked portion
//==============================================================================
assign reqMasked = requestorMasked & priorityMask;
assign mask_higher_pri_reqs[N-1:1] = mask_higher_pri_reqs[N-2: 0] | reqMasked[N-2:0] ;
assign mask_higher_pri_reqs[0] = 1'b0;

assign grantMasked[N-1:0] = reqMasked[N-1:0] & ~mask_higher_pri_reqs[N-1:0];

//=================================================================================
// Simple priority arbitration for unmasked portion
//=================================================================================
assign unmask_higher_pri_reqs[N-1:1] = unmask_higher_pri_reqs[N-2:0] | requestorMasked[N-2:0];
assign unmask_higher_pri_reqs[0] = 1'b0;
assign grantUnmasked[N-1:0] = requestorMasked[N-1:0] & ~unmask_higher_pri_reqs[N-1:0];

//===================================================================================
// Use grant_masked if there is any there, otherwise use grant_unmasked.
// Coded as AND / OR rather than mux to make synthesis easier.
//===================================================================================
assign no_req_masked = ~( |reqMasked );

assign	d_grant = ( { N{ no_req_masked } } & grantUnmasked ) | grantMasked;

always @(posedge sysClk or negedge arst_sync )
begin
	if(~arst_sync | ~srst_sync)
		begin
		
			grantEnc <= 0;			// encode one-hot 

			grant 		<=  { 1'b1, { N-1{1'b0} } };		// default to highest requestorMasked granted - 0 is next
			grantValid	<= 1'b0;

		end
	else if (arbEnable | ~grantValid)						// arb no grantValid or arbEnable asserted to indicate finished with last request
		begin
			grant 		<= d_grant;
			grantEnc 	<= hot2enc_d_grant;	// Already N_WIDTH bits from parameterized function

			grantValid	<= |(requestorMasked);
		end
		
end

//===================================================================================
// Update priority mask to remove winner and lower requesters
//===================================================================================
always @ (posedge sysClk or negedge arst_sync ) 
begin
	if(~arst_sync | ~srst_sync) 
		begin
			priorityMask <= { N{1'b1} };		// initialise that requestorMasked[0] has priority
		end 
	else 
		begin
			if ( arbEnable )
				begin
					if ( |reqMasked ) 
						begin // Which arbiter was used?
							priorityMask <= mask_higher_pri_reqs;
						end 
					else 
						begin
							if ( |requestorMasked )  
								begin 		// Only update if there's a req
									priorityMask <= unmask_higher_pri_reqs;
								end 
						end
				end
		end
		
end



endmodule // caxi4interconnect_RoundRobinArb.v
