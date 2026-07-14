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

module caxi4interconnect_TargetDataMuxController # 
	(
		parameter integer NUM_INITIATORS			= 4, 				// defines number of initiators
		parameter integer NUM_INITIATORS_WIDTH		= 2, 				// defines number of bits to encode initiator number
		
		parameter integer NUM_TARGETS     		    = 4, 				// defines number of targets
		parameter integer NUM_TARGETS_WIDTH 		= 2,				// defines number of bits to encoode target number

		parameter integer ID_WIDTH   			= 1, 

		parameter integer SUPPORT_USER_SIGNALS 	= 0,
		parameter integer USER_WIDTH 			= 1,
		
		parameter [NUM_INITIATORS*NUM_TARGETS-1:0] 		INITIATOR_WRITE_CONNECTIVITY 		= {NUM_INITIATORS*NUM_TARGETS{1'b1}},
		parameter [NUM_INITIATORS*NUM_TARGETS-1:0] 		INITIATOR_READ_CONNECTIVITY 		= {NUM_INITIATORS*NUM_TARGETS{1'b1}} 
   
	)
	(
		// Global Signals
		input  wire                                     	sysClk,
		input  wire                                     	arst_sync,				// active low reset synchronoise to RE AClk - asserted async.
		input  wire                                     	srst_sync,				// active low reset synchronoise to RE AClk - asserted async.

		// Slot Arbitrator
		input wire											requestorSelValid,		// indicates that slot arb has selected an requestorSelValid so drive to target
		input wire [NUM_TARGETS_WIDTH-1:0]					requestorSelEnc,		// encoded version requestorSel which is one-hot.

		output wire											arbEnable,
				
		//====================== target Data Ports  ================================================//
  
		input  wire [NUM_TARGETS-1:0]                           			TARGET_VALID,
		input  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 		TARGET_ID,
		input  wire [NUM_TARGETS*2-1:0]                         			TARGET_RESP,
		input  wire [NUM_TARGETS*USER_WIDTH-1:0]         				    TARGET_USER,
		
		output reg  [NUM_TARGETS-1:0]                           			TARGET_READY,
		
		//====================== Initiator Data  Ports  ================================================//

		output wire [NUM_INITIATORS*ID_WIDTH-1:0]          				    INITIATOR_ID,
		output wire [NUM_INITIATORS*2-1:0]                          		INITIATOR_RESP,
		output wire [NUM_INITIATORS*USER_WIDTH-1:0]          				INITIATOR_USER,
		output wire [NUM_INITIATORS-1:0]                            		INITIATOR_VALID,

		input  wire [NUM_INITIATORS-1:0]                            		INITIATOR_READY,
   
		//====================== AddressControl Port ============================================//
		
		output wire	[NUM_INITIATORS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 	currDataTransID,	// current data transaction ID
		output wire	[(NUM_INITIATORS*NUM_TARGETS_WIDTH)-1:0] 	            currdatatrgt,	// current data transaction ID
		output reg	[NUM_INITIATORS-1:0]  									openTransDec		// indicates thread matching currDataTransID to be decremented
  
	);
   						 
						 
//================================================================================================
// Local Parameters
//================================================================================================

	localparam INITIATORID_WIDTH		= ( NUM_INITIATORS_WIDTH + ID_WIDTH );			// defines width initiatorID - includes infrastructure ID plus ID
	localparam THREAD_VEC_WIDTH		    = ( INITIATORID_WIDTH + NUM_TARGETS_WIDTH );	// defines width of per thread vector elements width

	
//=================================================================================================
// Local Declarationes
//=================================================================================================
 
	// Initiator Data Port - output of MUX of selected requestor
	reg [ID_WIDTH-1:0]          	d_initiatorID, initiatorID;
	reg [1:0]	                    d_initiatorRESP, initiatorRESP;
	reg [USER_WIDTH-1:0]          	d_initiatorUSER, initiatorUSER;

	reg	[INITIATORID_WIDTH-1:0] 	d_dataTransID;	// current data transaction ID
	reg	[NUM_TARGETS_WIDTH-1:0] 	d_datatrgt;	// current data transaction ID

	reg [NUM_INITIATORS-1:0]               		initiatorVALID;
	wire 						                initiatorReady;	

   	reg [NUM_INITIATORS_WIDTH-1:0]					dst_initiator;

	reg	[(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 		dataTransID;	// current data transaction ID
	reg	[NUM_TARGETS_WIDTH-1:0]             		datatrgt;	// current data transaction ID
	
 

//================================================================================================
// MUX data vector based on requestorSel
//================================================================================================

    always @(*)
    begin
        // Default values
        d_initiatorID   = 0;
        d_initiatorRESP = 0;
        d_initiatorUSER = 0;
        d_dataTransID   = dataTransID;
        d_datatrgt      = datatrgt;
        
        if (requestorSelValid) begin
            // Use requestorSelEnc directly as index for array slicing
            d_initiatorID   = TARGET_ID[requestorSelEnc*INITIATORID_WIDTH +: ID_WIDTH];
            d_initiatorRESP = TARGET_RESP[requestorSelEnc*2 +: 2 ];
            d_initiatorUSER = TARGET_USER[requestorSelEnc*USER_WIDTH +: USER_WIDTH];
            d_dataTransID   = TARGET_ID[requestorSelEnc*INITIATORID_WIDTH +: INITIATORID_WIDTH];
            d_datatrgt      = requestorSelEnc;
        end
    end

//==============================================================================================================
// Select initiator target from target selected  - prune unwanted bits of muxing
//==============================================================================================================

    always @(*)
    begin
      dst_initiator = TARGET_ID[(requestorSelEnc*INITIATORID_WIDTH)+ID_WIDTH +: NUM_INITIATORS_WIDTH];
    end

    always @(posedge sysClk or negedge arst_sync )
    	begin
    		if(~arst_sync | ~srst_sync)
    			begin
    				dataTransID		<= 0;    
                    datatrgt      <= 0;					
    				openTransDec	<= 0;
    			end
    		else
    			begin
    				openTransDec	<= 0;    
    				if ( requestorSelValid )
    					begin
    						dataTransID					 	<= d_dataTransID;
    						datatrgt					 	<= d_datatrgt;
    						openTransDec[ dst_initiator ] 	<= INITIATOR_READY[dst_initiator];			// only assert when READY asserted - end of transaction
    					end
    
    			end
    	end

		assign	currDataTransID	=  { NUM_INITIATORS{ dataTransID } };	
		assign	currdatatrgt	=  { NUM_INITIATORS{ datatrgt } };	


		//=====================================================================================
		// Combinational out Initiator bus
		//=====================================================================================
		always @( * )
			begin
				initiatorID	    = d_initiatorID;
				initiatorRESP 	= d_initiatorRESP;
				initiatorUSER	= d_initiatorUSER;

				initiatorVALID 	= 0;		// initialise to 0 to indicate no transaction
				TARGET_READY	= 0;
	
				if ( requestorSelValid )	// pass through VALID when requestorValid
					begin
						initiatorVALID[ dst_initiator ] = TARGET_VALID[requestorSelEnc];
						TARGET_READY[ requestorSelEnc ] = INITIATOR_READY[dst_initiator];  
					end
			end	


//====================================================================================
// Connect output of clocked data vector from MUX to individual initiator ports
//====================================================================================	

genvar i;
generate
	for (i=0; i< NUM_INITIATORS; i=i+1 )
		begin
			assign INITIATOR_ID[(i+1)*ID_WIDTH-1:i*ID_WIDTH]			= initiatorID;
			assign INITIATOR_RESP[(i+1)*2-1:i*2]         				= initiatorRESP;
			assign INITIATOR_USER[(i+1)*USER_WIDTH-1:i*USER_WIDTH]   	= initiatorUSER;
	
		end
endgenerate

assign 	INITIATOR_VALID	    = initiatorVALID;

assign	initiatorReady		= |(INITIATOR_READY & INITIATOR_VALID );			// initiatorReady when ready is asserted on initiator targeted

// Completed this transaction when see VALID & READY
assign arbEnable 		    = initiatorReady;					// free to arb for Next

	
	
endmodule // caxi4interconnect_TargetDataMuxController.v
