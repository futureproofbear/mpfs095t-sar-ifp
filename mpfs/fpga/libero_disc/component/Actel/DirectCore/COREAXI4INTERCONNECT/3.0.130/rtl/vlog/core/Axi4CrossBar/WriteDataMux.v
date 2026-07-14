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

module caxi4interconnect_WriteDataMux # 
	(
		parameter integer NUM_INITIATORS			= 4, 				// defines number of Initiators
		parameter integer NUM_INITIATORS_WIDTH		= 2, 				// defines number of bits to encode Initiator number
		
		parameter integer NUM_TARGETS     		    = 8, 				// defines number of targets
		parameter integer NUM_TARGETS_WIDTH 		= 3,				// defines number of bits to encoode target number

		parameter integer ID_WIDTH   			    = 1, 

		parameter integer DATA_WIDTH 			    = 32,
		
		parameter integer SUPPORT_USER_SIGNALS 	    = 0,
		parameter integer USER_WIDTH 			    = 1,
		
		parameter [NUM_INITIATORS-1:0] 		WRITE_CONNECTIVITY 		= {NUM_INITIATORS{1'b1} },

		parameter HI_FREQ 						    = 0,					// increases freq of operation at cost of added latency
		
		parameter INITIATORID_WIDTH                 = NUM_INITIATORS_WIDTH + ID_WIDTH
		
  	)
	(
		// Global Signals
		input  wire                        				sysClk,
		input  wire                        				arst_sync,					// active low reset synchronoise to RE AClk - asserted async.
		input  wire                        				srst_sync,					// active low reset synchronoise to RE AClk - asserted async.

		//====================== WrFifo Ports  ======================================================//
		input  wire										wrInitiatorValid,

		output wire										dataFifoRd,					// request to pop caxi4interconnect_FIFO entry after write completed.
																				
		input	 [NUM_INITIATORS_WIDTH-1:0]				srcInitiator,

		//====================== Initiator Data  Ports  ================================================//
		input wire [NUM_INITIATORS-1:0]                    INITIATOR_WVALID,
		input wire [NUM_INITIATORS*ID_WIDTH-1:0]           INITIATOR_WID,
		input wire [NUM_INITIATORS*DATA_WIDTH-1:0]     	   INITIATOR_WDATA,
		input wire [NUM_INITIATORS*(DATA_WIDTH/8)-1:0]     INITIATOR_WSTRB,
		input wire [NUM_INITIATORS-1:0]                    INITIATOR_WLAST,
		input wire [NUM_INITIATORS*USER_WIDTH-1:0]         INITIATOR_WUSER,

		output reg [NUM_INITIATORS-1:0]                    INITIATOR_WREADY,

		//====================== target Data Ports  ==================================================//
		output  reg  				      				TARGET_WVALID,
		output  reg [INITIATORID_WIDTH-1:0]             TARGET_WID,		
		output  reg [DATA_WIDTH-1:0]    				TARGET_WDATA,
		output  reg [(DATA_WIDTH/8)-1:0]              	TARGET_WSTRB,
		output  reg                            			TARGET_WLAST,
		output  reg [USER_WIDTH-1:0]         			TARGET_WUSER,
		
		input wire                          			TARGET_WREADY
 	
	);
   						 
						 
//================================================================================================
// Local Parameters
//================================================================================================


	localparam STRB_WIDTH			= (DATA_WIDTH/8);							// defines width of write strobes 
	
	
//=================================================================================================
// Local Declarationes
//=================================================================================================

	// Initiator Data Port - output of MUX of selected requestor
	reg [INITIATORID_WIDTH-1:0]                 d_targetWID;
	reg [DATA_WIDTH-1:0]     					d_targetWDATA;
	reg [STRB_WIDTH-1:0]	       				d_targetWSTRB;
	reg 				          				d_targetWLAST;
	reg [USER_WIDTH-1:0]          				d_targetWUSER;
    

	

//================================================================================================
// MUX data vector based on srcInitiator
//================================================================================================

always @(*)
begin
    // Default values
    d_targetWID       = 0;
    d_targetWDATA     = 0;
    d_targetWSTRB     = 0;
    d_targetWLAST     = 0;
    d_targetWUSER     = 0;
    
    if (wrInitiatorValid) begin
        // Use requestorSelEnc directly as index for array slicing
        d_targetWID     = {srcInitiator,INITIATOR_WID[srcInitiator*ID_WIDTH +: ID_WIDTH]};
        d_targetWDATA   = INITIATOR_WDATA[srcInitiator*DATA_WIDTH +: DATA_WIDTH];
        d_targetWSTRB   = INITIATOR_WSTRB[srcInitiator*(DATA_WIDTH/8) +: (DATA_WIDTH/8)];
        d_targetWLAST   = INITIATOR_WLAST[srcInitiator];
        d_targetWUSER   = INITIATOR_WUSER[srcInitiator*USER_WIDTH +: USER_WIDTH];
    end
end

//=====================================================================================
// Combinational out target bus - to avoid "dead" cycles
//=====================================================================================
always @(*)
	begin
	    
		TARGET_WID      = d_targetWID;
		TARGET_WDATA 	= d_targetWDATA;
		TARGET_WSTRB 	= d_targetWSTRB;
		TARGET_WLAST 	= d_targetWLAST;
		TARGET_WUSER	= d_targetWUSER;

		TARGET_WVALID 	= 0;		// initialise to 0 to indicate no transaction
		INITIATOR_WREADY	= 0;
	
		if ( wrInitiatorValid )	// pass through VALID when active request
			begin
				TARGET_WVALID			 	= INITIATOR_WVALID[srcInitiator];
				INITIATOR_WREADY[srcInitiator]	= TARGET_WREADY;
			end
		
	end	




//=============================================================================
// Pop relevant caxi4interconnect_FIFO when completed write cycle ie last beat
//=============================================================================
assign	dataFifoRd	= TARGET_WLAST & TARGET_WREADY & TARGET_WVALID;

	
endmodule // caxi4interconnect_WriteDataMux.v
