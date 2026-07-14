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

module caxi4interconnect_ReadDataMux # 
	(
		parameter integer NUM_INITIATORS_WIDTH		= 2, 				// defines number of bits to encode initiator number
		
		parameter integer NUM_TARGETS     		= 4, 				// defines number of targets
		parameter integer NUM_TARGETS_WIDTH 		= 2,				// defines number of bits to encoode target number

		parameter integer ID_WIDTH   			= 1, 

		parameter integer DATA_WIDTH 			= 32,
		
		parameter integer SUPPORT_USER_SIGNALS 	= 0,
		parameter integer USER_WIDTH 			= 1,

		parameter [NUM_TARGETS-1:0]  		INITIATOR_READ_CONNECTIVITY  =  {NUM_TARGETS{1'b1}},
		parameter [NUM_TARGETS-1:0]  		RD_ARB_EN 		             =  0
   
	)
	(
		// Global Signals
		input  wire                                     	sysClk,
		input  wire                                     	arst_sync,				// active low reset synchronoise to RE AClk - asserted async.
		input  wire                                     	srst_sync,				// active low reset synchronoise to RE AClk - asserted async.

		// Slot Arbitrator
		input wire											requestorSelValid,		// indicates that slot arb has selected an requestorSelValid so drive to Target
		input wire [NUM_TARGETS_WIDTH-1:0 ]					requestorSelEnc,		// indicates requestor selected by slot arb when active request is asserted - encoded
		output wire											arbEnable,
				
		//====================== Target Data Ports  ================================================//
  
		input  wire [NUM_TARGETS-1:0]                           			TARGET_VALID,
		input  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 		TARGET_ID,
		input  wire [NUM_TARGETS*DATA_WIDTH-1:0]    						TARGET_DATA,
		input  wire [NUM_TARGETS*2-1:0]                         			TARGET_RESP,
		input  wire [NUM_TARGETS-1:0]                           			TARGET_LAST,
		input  wire [NUM_TARGETS*USER_WIDTH-1:0]         			    	TARGET_USER,
		
		output reg  [NUM_TARGETS-1:0]                           			TARGET_READY,
		
		//====================== Initiator Data  Ports  ================================================//

		output reg [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]          		initiatorID,
		output reg [DATA_WIDTH-1:0]     								INITIATOR_DATA,
		output reg [1:0]                   	       						INITIATOR_RESP,
		output reg                   		          					INITIATOR_LAST,
		output reg [USER_WIDTH-1:0]          							INITIATOR_USER,
		output reg		                            					INITIATOR_VALID,

		input  wire					                            		INITIATOR_READY,
   
		//====================== AddressControl Port ============================================//
		
		output reg	[(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 				currDataTransID,	// current data transaction ID
		output reg	[NUM_TARGETS_WIDTH-1:0] 				            currdatatrgt,	// current data transaction ID
		output reg				 										openTransDec,		// indicates thread matching currDataTransID to be decremented
		
		input       [NUM_TARGETS-1:0]                                   targetValidQual
  
	);
   						 
						 
//================================================================================================
// Local Parameters
//================================================================================================

	localparam INITIATORID_WIDTH		= ( NUM_INITIATORS_WIDTH + ID_WIDTH );			// defines width initiatorID - includes infrastructure ID plus ID
	localparam THREAD_VEC_WIDTH		= ( INITIATORID_WIDTH + NUM_TARGETS_WIDTH );	// defines width of per thread vector elements width

	
//=================================================================================================
// Local Declarationes
//=================================================================================================
 
	// Initiator Data Port - output of MUX of selected requestor
	reg [INITIATORID_WIDTH-1:0]                d_initiatorID;
	reg [DATA_WIDTH-1:0]     		           d_initiatorDATA;
	reg [1:0]	                               d_initiatorRESP;
	reg 				          	           d_initiatorLAST;
	reg [USER_WIDTH-1:0]          	           d_initiatorUSER;

	reg	[(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]  d_currDataTransID;	// current data transaction ID
	reg	[NUM_TARGETS_WIDTH-1:0] 		       d_currdatatrgt;	// current data transaction ID
	
	

	wire 						               initiatorReady;	
	wire                                       xfer_cmpl;
    wire                                       selected_target_invalid;

//================================================================================================
// MUX data vector based on requestorSel
//================================================================================================

always @(*)
begin
    // Default values
    d_initiatorID       = 0;
    d_initiatorDATA     = 0;
    d_initiatorRESP     = 0;
    d_initiatorLAST     = 0;
    d_initiatorUSER     = 0;
    d_currDataTransID   = currDataTransID;
    d_currdatatrgt      = currdatatrgt;
    
    if (requestorSelValid) begin
        // Use requestorSelEnc directly as index for array slicing
        d_initiatorID     = TARGET_ID[requestorSelEnc*INITIATORID_WIDTH +: INITIATORID_WIDTH];
        d_initiatorDATA   = TARGET_DATA[requestorSelEnc*DATA_WIDTH +: DATA_WIDTH];
        d_initiatorRESP   = TARGET_RESP[requestorSelEnc*2 +: 2 ];
        d_initiatorLAST   = TARGET_LAST[requestorSelEnc];
        d_initiatorUSER   = TARGET_USER[requestorSelEnc*USER_WIDTH +: USER_WIDTH];
        d_currDataTransID = TARGET_ID[requestorSelEnc*INITIATORID_WIDTH +: INITIATORID_WIDTH];
        d_currdatatrgt    = requestorSelEnc;
    end
end

always @(posedge sysClk or negedge arst_sync )
begin
	if (~arst_sync | ~srst_sync)
		begin
			currDataTransID <= 0;
			currdatatrgt    <= 0;
			openTransDec	<= 0;
		end
	else
		begin
			openTransDec	<= 0;
	
			//if ( requestorSelValid & d_initiatorLAST )  // -- Incorrect generation of "openTransDec" when "d_initiatorLAST" gets extended .
                                                       // -- Thread Count should be decremented with the completion of the read data cycle for the same thread.
			if ( requestorSelValid & xfer_cmpl )       // -- 
				begin
					currDataTransID		<= d_currDataTransID;
					currdatatrgt		<= d_currdatatrgt;
					openTransDec		<= INITIATOR_READY;
				end

		end
end

//=====================================================================================
// Initiator bus
//=====================================================================================

always @(*)

begin
	
	initiatorID		    = d_initiatorID;
	INITIATOR_DATA  	= d_initiatorDATA;
	INITIATOR_RESP  	= d_initiatorRESP;
	INITIATOR_LAST  	= d_initiatorLAST;
	INITIATOR_USER		= d_initiatorUSER;

	INITIATOR_VALID 	= 0;		// initialise to 0 to indicate no transaction
	TARGET_READY	 	= 0;
	
	if ( requestorSelValid && (targetValidQual[requestorSelEnc]))	// pass through VALID when requestorValid
		begin
		    INITIATOR_VALID					= (TARGET_VALID[requestorSelEnc]);
			TARGET_READY[ requestorSelEnc ]	= INITIATOR_READY;  
		end

end	

assign	initiatorReady		= (INITIATOR_READY & INITIATOR_VALID );				// initiatorReady when ready is asserted on initiator targeted

assign selected_target_invalid = requestorSelValid & ~targetValidQual[requestorSelEnc];
// Completed this transaction when see LAST & VALID & READY
assign arbEnable = RD_ARB_EN ? (INITIATOR_VALID & initiatorReady) | selected_target_invalid : 
                              INITIATOR_LAST  & initiatorReady;

assign xfer_cmpl            = INITIATOR_LAST  & initiatorReady;	
	
endmodule // caxi4interconnect_ReadDataMux.v
