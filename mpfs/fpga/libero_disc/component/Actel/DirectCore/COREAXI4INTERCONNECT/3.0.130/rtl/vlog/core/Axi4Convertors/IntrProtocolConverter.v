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
// SVN $Revision: 47415 $
// SVN $Date: 2024-09-15 15:58:24 +0530 (Sun, 15 Sep 2024) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_IntrProtocolConverter #

	(
		parameter integer 	NUM_INITIATORS			= 4,			// defines number of initiator ports 
		parameter integer 	INITIATOR_NUMBER		= 0,			//current initiator
		parameter integer 	ADDR_WIDTH      	= 20,			// valid values - 16 - 64
		parameter integer 	DATA_WIDTH 			= 32,			// valid widths - 32, 64, 128, 256
		
		parameter [1:0] 	INITIATOR_TYPE			= 2'b00,		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11
		
		parameter integer 	USER_WIDTH 			= 1,			// defines the number of bits for USER signals RUSER and WUSER
	
		parameter integer 	ID_WIDTH   			= 1				// number of bits for ID (ie AID, WID, BID) - valid 1-8 
		
	)
	(

	//=====================================  Global Signals   ========================================================================
		input  wire                         ACLK,
		input  wire                       	iarst_sync,			// active low reset synchronoise to RE AClk - asserted async.
		input  wire                       	isrst_sync,			// active low reset synchronoise to RE AClk - asserted async.
		
	output reg [ID_WIDTH-1:0] 		int_initiatorARID,
	output reg [ADDR_WIDTH-1:0]		int_initiatorARADDR,
	output reg [7:0]        		int_initiatorARLEN,
	output reg [2:0]          		int_initiatorARSIZE,
	output reg [1:0]          		int_initiatorARBURST,
	output reg [1:0]          		int_initiatorARLOCK,
	output reg [3:0]           		int_initiatorARCACHE,
	output reg [2:0]         		int_initiatorARPROT,
	output reg [3:0]          		int_initiatorARREGION,
	output reg [3:0]          		int_initiatorARQOS,
	output reg [USER_WIDTH-1:0]		int_initiatorARUSER,
	output reg            			int_initiatorARVALID,
	input wire             			int_initiatorARREADY,

	// Initiator Read Data Ports	
	input wire [ID_WIDTH-1:0]   	int_initiatorRID,
	input wire [DATA_WIDTH-1:0]		int_initiatorRDATA,
	input wire [1:0]           		int_initiatorRRESP,
	input wire                		int_initiatorRLAST,
	input wire [USER_WIDTH-1:0] 	int_initiatorRUSER,
	input wire                 		int_initiatorRVALID,
	output reg               		int_initiatorRREADY,

	// Initiator Write Address Ports	
	output reg [ID_WIDTH-1:0]  		int_initiatorAWID,
	output reg [ADDR_WIDTH-1:0] 	int_initiatorAWADDR,
	output reg [7:0]           		int_initiatorAWLEN,
	output reg [2:0]           		int_initiatorAWSIZE,
	output reg [1:0]           		int_initiatorAWBURST,
	output reg [1:0]           		int_initiatorAWLOCK,
	output reg [3:0]          		int_initiatorAWCACHE,
	output reg [2:0]           		int_initiatorAWPROT,
	output reg [3:0]            	int_initiatorAWREGION,
	output reg [3:0]           		int_initiatorAWQOS,
	output reg [USER_WIDTH-1:0]   	int_initiatorAWUSER,
	output reg                 		int_initiatorAWVALID,
	input wire                		int_initiatorAWREADY,
	
	// Initiator Write Data Ports	
	output reg [ID_WIDTH-1:0]       int_initiatorWID,
	output reg [DATA_WIDTH-1:0]  	int_initiatorWDATA,
	output reg [(DATA_WIDTH/8)-1:0]	int_initiatorWSTRB,
	output reg                  	int_initiatorWLAST,
	output reg [USER_WIDTH-1:0] 	int_initiatorWUSER,
	output reg                  	int_initiatorWVALID,
	input wire                   	int_initiatorWREADY,
			
	// Initiator Write Response Ports	
	input  wire [ID_WIDTH-1:0]		int_initiatorBID,
	input  wire [1:0]           	int_initiatorBRESP,
	input  wire [USER_WIDTH-1:0] 	int_initiatorBUSER,
	input  wire      				int_initiatorBVALID,
	output reg						int_initiatorBREADY,

	//================================================= External Side Ports  ================================================//

	// Initiator Read Address Ports	
	input  wire [ID_WIDTH-1:0]  	INITIATOR_ARID,
	input  wire [ADDR_WIDTH-1:0]	INITIATOR_ARADDR,
	input  wire [7:0]           	INITIATOR_ARLEN,
	input  wire [2:0]        		INITIATOR_ARSIZE,
	input  wire [1:0]           	INITIATOR_ARBURST,
	input  wire [1:0]         		INITIATOR_ARLOCK,
	input  wire [3:0]          		INITIATOR_ARCACHE,
	input  wire [2:0]         		INITIATOR_ARPROT,
	input  wire [3:0]          		INITIATOR_ARREGION,
	input  wire [3:0]          		INITIATOR_ARQOS,
	input  wire [USER_WIDTH-1:0]	INITIATOR_ARUSER,
	input  wire                		INITIATOR_ARVALID,
	output reg                		INITIATOR_ARREADY,
	
	// Initiator Read Data Ports	
	output reg [ID_WIDTH-1:0]  		INITIATOR_RID,
	output reg [DATA_WIDTH-1:0]  	INITIATOR_RDATA,
	output reg [1:0]           		INITIATOR_RRESP,
	output reg                  	INITIATOR_RLAST,
	output reg [USER_WIDTH-1:0] 	INITIATOR_RUSER,
	output reg               		INITIATOR_RVALID,
	input wire                 		INITIATOR_RREADY,
	
	// Initiator Write Address Ports	
	input  wire [ID_WIDTH-1:0]   	INITIATOR_AWID,
	input  wire [ADDR_WIDTH-1:0] 	INITIATOR_AWADDR,
	input  wire [7:0]           	INITIATOR_AWLEN,
	input  wire [2:0]           	INITIATOR_AWSIZE,
	input  wire [1:0]           	INITIATOR_AWBURST,
	input  wire [1:0]            	INITIATOR_AWLOCK,
	input  wire [3:0]          		INITIATOR_AWCACHE,
	input  wire [2:0]           	INITIATOR_AWPROT,
	input  wire [3:0]           	INITIATOR_AWREGION,
	input  wire [3:0]           	INITIATOR_AWQOS,
	input  wire [USER_WIDTH-1:0] 	INITIATOR_AWUSER,
	input  wire                  	INITIATOR_AWVALID,
	output reg                		INITIATOR_AWREADY,
	
	// Initiator Write Data Ports	
	input  wire [ID_WIDTH-1:0]   	INITIATOR_WID,
	input wire [DATA_WIDTH-1:0]   	INITIATOR_WDATA,
	input wire [(DATA_WIDTH/8)-1:0]	INITIATOR_WSTRB,
	input wire                   	INITIATOR_WLAST,
	input wire [USER_WIDTH-1:0] 	INITIATOR_WUSER,
	input wire                  	INITIATOR_WVALID,
	output reg                  	INITIATOR_WREADY,
	
	// Initiator Write Response Ports	
	output reg [ID_WIDTH-1:0]		INITIATOR_BID,
	output reg [1:0]           		INITIATOR_BRESP,
	output reg [USER_WIDTH-1:0]  	INITIATOR_BUSER,
	output reg      				INITIATOR_BVALID,
	input wire						INITIATOR_BREADY

	);


//================================================= External Side Ports  ================================================//
	
	
	generate
		if ( INITIATOR_TYPE == 2'b00) 		// AXI4 Initiator type - direct connection
			begin
			
				//====================================== ASSIGNEMENTS =================================================
				always @(*)
					begin
			
						//from initiator to crossbar
						int_initiatorAWID 		= INITIATOR_AWID;
						int_initiatorAWADDR 	= INITIATOR_AWADDR;
						int_initiatorAWLEN 	    = INITIATOR_AWLEN;
						int_initiatorAWSIZE 	= INITIATOR_AWSIZE;
						int_initiatorAWBURST 	= INITIATOR_AWBURST;
						int_initiatorAWLOCK 	= INITIATOR_AWLOCK;
						int_initiatorAWCACHE 	= INITIATOR_AWCACHE;
						int_initiatorAWPROT 	= INITIATOR_AWPROT;
						int_initiatorAWREGION 	= INITIATOR_AWREGION;
						int_initiatorAWQOS 	    = INITIATOR_AWQOS;				// not used
						int_initiatorAWUSER 	= INITIATOR_AWUSER;				// not used
						int_initiatorAWVALID 	= INITIATOR_AWVALID;
						int_initiatorWID        = {ID_WIDTH{1'b0}};
						int_initiatorWDATA 	    = INITIATOR_WDATA;
						int_initiatorWSTRB 	    = INITIATOR_WSTRB;
						int_initiatorWLAST 	    = INITIATOR_WLAST;
						int_initiatorWUSER 	    = INITIATOR_WUSER;
						int_initiatorWVALID	    = INITIATOR_WVALID;
						int_initiatorBREADY 	= INITIATOR_BREADY;
						int_initiatorARID 		= INITIATOR_ARID;
						int_initiatorARADDR 	= INITIATOR_ARADDR;
						int_initiatorARLEN 	    = INITIATOR_ARLEN;
						int_initiatorARSIZE 	= INITIATOR_ARSIZE;
						int_initiatorARBURST 	= INITIATOR_ARBURST;
						int_initiatorARLOCK 	= INITIATOR_ARLOCK;
						int_initiatorARCACHE 	= INITIATOR_ARCACHE;
						int_initiatorARPROT 	= INITIATOR_ARPROT;
						int_initiatorARREGION 	= INITIATOR_ARREGION;
						int_initiatorARQOS 	    = INITIATOR_ARQOS;		// not used
						int_initiatorARUSER 	= INITIATOR_ARUSER;
						int_initiatorARVALID 	= INITIATOR_ARVALID;
						int_initiatorRREADY 	= INITIATOR_RREADY;

						//================================================= External Side Ports  ===============================
						//from crossbar to initiator
						INITIATOR_AWREADY 		= int_initiatorAWREADY;
						INITIATOR_WREADY 		= int_initiatorWREADY;
						INITIATOR_BID 			= int_initiatorBID;
						INITIATOR_BRESP 		= int_initiatorBRESP;
						INITIATOR_BUSER 		= int_initiatorBUSER;
						INITIATOR_BVALID 		= int_initiatorBVALID;
						INITIATOR_ARREADY 		= int_initiatorARREADY;

						INITIATOR_RID 			= int_initiatorRID;
						INITIATOR_RDATA 		= int_initiatorRDATA;
						INITIATOR_RRESP 		= int_initiatorRRESP;
						INITIATOR_RLAST 		= int_initiatorRLAST;
						INITIATOR_RUSER 		= int_initiatorRUSER;
						INITIATOR_RVALID 		= int_initiatorRVALID;

					end
			end
			
		else if ( INITIATOR_TYPE == 2'b01) 		// AXI4-Lite Initiator type	
			begin
			
				always @(*)
					begin
					
						int_initiatorAWLEN  	= 0; 			// always single cycle
						int_initiatorAWBURST  	= 2'b01;		// burst length is defined as 1.

						int_initiatorAWLOCK     = 0;

						int_initiatorAWCACHE 	= 4'b0000;		// = 0b0000; signal discarded. All transactions are treated as Non-modifiable and Non-bufferable.
						int_initiatorWLAST 	    = 1'b1;		// 
						int_initiatorARLEN 	    = 0; 			// always 1 beat in burst
						int_initiatorARBURST  	= 2'b01;		// burst length is defined as 1.
						
						int_initiatorARLOCK     = 0;
						
						int_initiatorARCACHE  	= 4'b0000;		// = 0b0000; signal discarded. All transactions are treated as Non-modifiable and Non-bufferable.

						int_initiatorAWID       = 0;				//INITIATOR_AWID not provided. Use fixed ID value. All transactions must be in order
						// andreag: propagate the initiator transfer size for any data_width
						int_initiatorAWSIZE     = ($clog2(DATA_WIDTH/8));	//3'b010
						int_initiatorARSIZE     = ($clog2(DATA_WIDTH/8));	//3'b010
						// from initiator to crossbar
				    
						int_initiatorAWADDR 	= INITIATOR_AWADDR;
				    
						int_initiatorAWPROT 	= INITIATOR_AWPROT;
						int_initiatorAWREGION 	= 4'h0;
						int_initiatorAWQOS 	    = 4'h0;				// not used
						int_initiatorAWUSER 	= 0;				// not used
						int_initiatorAWVALID 	= INITIATOR_AWVALID;
						int_initiatorWID        = {ID_WIDTH{1'b0}};
						int_initiatorWDATA 	    = INITIATOR_WDATA;
						int_initiatorWSTRB 	    = INITIATOR_WSTRB;
						int_initiatorWUSER 	    = 0;
						int_initiatorWVALID 	= INITIATOR_WVALID;
						int_initiatorBREADY 	= INITIATOR_BREADY;
						int_initiatorARID 		= 0;
						int_initiatorARADDR 	= INITIATOR_ARADDR;

						int_initiatorARPROT 	= INITIATOR_ARPROT;
						int_initiatorARREGION 	= 4'h0;
						int_initiatorARQOS 	    = 4'h0;		// not used
						int_initiatorARUSER 	= 0;
						int_initiatorARVALID 	= INITIATOR_ARVALID;
						int_initiatorRREADY 	= INITIATOR_RREADY;
				   
						//================================= External Side Ports  ==============================================

						//from crossbar to initiator
						INITIATOR_AWREADY 	= int_initiatorAWREADY;
						INITIATOR_WREADY 	= int_initiatorWREADY;
						INITIATOR_BID 		= 0;

						if (int_initiatorBRESP == 2'b01)	//EXOKAY Not supported by AXI4Lite protocol
							begin
								INITIATOR_BRESP = 2'b00; //OKAY
							end
						else
							begin
								INITIATOR_BRESP = int_initiatorBRESP;
							end
							
						INITIATOR_BUSER 	= 0;
						INITIATOR_BVALID 	= int_initiatorBVALID;
						INITIATOR_ARREADY 	= int_initiatorARREADY;

						INITIATOR_RID 		= 0;
						INITIATOR_RDATA 	= int_initiatorRDATA;
						
						if (int_initiatorRRESP == 2'b01)	//EXOKAY Not supported by AXI4Lite protocol
							begin
								INITIATOR_RRESP = 2'b00; //OKAY
							end
						else
							begin
								INITIATOR_RRESP = int_initiatorRRESP;
							end
							
						INITIATOR_RLAST 	= 1'b1;
						INITIATOR_RUSER 	= 0;
						INITIATOR_RVALID 	= int_initiatorRVALID;
					end
			end

		else 			// Axi3 to AXI4
			begin
				always @(*)
					begin
						//from initiator to crossbar
						int_initiatorAWID 		= INITIATOR_AWID;
						int_initiatorAWADDR 	= INITIATOR_AWADDR;
						int_initiatorAWLEN 	    = INITIATOR_AWLEN;
						int_initiatorAWSIZE 	= INITIATOR_AWSIZE;
						int_initiatorAWBURST 	= INITIATOR_AWBURST;
						
						int_initiatorAWLOCK     = ( INITIATOR_AWLOCK == 2'b10 ) ? 2'b00 : INITIATOR_AWLOCK;	//map between AXI3 and AXI4 locking mechanisms
						
						int_initiatorAWCACHE 	= INITIATOR_AWCACHE;
						int_initiatorAWPROT 	= INITIATOR_AWPROT;
						int_initiatorAWREGION 	= INITIATOR_AWREGION;
						int_initiatorAWQOS 	    = INITIATOR_AWQOS;				// not used
						int_initiatorAWUSER 	= INITIATOR_AWUSER;				// not used
						int_initiatorAWVALID 	= INITIATOR_AWVALID;
						int_initiatorWID        = INITIATOR_WID;
						int_initiatorWDATA 	    = INITIATOR_WDATA;
						int_initiatorWSTRB 	    = INITIATOR_WSTRB;
						int_initiatorWLAST 	    = INITIATOR_WLAST;
						int_initiatorWUSER 	    = INITIATOR_WUSER;
						int_initiatorWVALID	    = INITIATOR_WVALID;
						int_initiatorBREADY 	= INITIATOR_BREADY;
						int_initiatorARID 		= INITIATOR_ARID;
						int_initiatorARADDR 	= INITIATOR_ARADDR;
						int_initiatorARLEN 	    = INITIATOR_ARLEN;
						int_initiatorARSIZE 	= INITIATOR_ARSIZE;
						int_initiatorARBURST 	= INITIATOR_ARBURST;
						
						int_initiatorARLOCK = ( INITIATOR_ARLOCK == 2'b10 ) ? 2'b00 : INITIATOR_AWLOCK;	//map between AXI3 and AXI4 locking mechanisms
						
						int_initiatorARCACHE 	= INITIATOR_ARCACHE;
						int_initiatorARPROT 	= INITIATOR_ARPROT;
						int_initiatorARREGION 	= INITIATOR_ARREGION;
						int_initiatorARQOS 	    = INITIATOR_ARQOS;		// not used
						int_initiatorARUSER 	= INITIATOR_ARUSER;
						int_initiatorARVALID 	= INITIATOR_ARVALID;
						int_initiatorRREADY 	= INITIATOR_RREADY;

						//================================================= External Side Ports  ===============================
						//from crossbar to initiator
						INITIATOR_AWREADY 		= int_initiatorAWREADY;
						INITIATOR_WREADY 		= int_initiatorWREADY;
						INITIATOR_BID 			= int_initiatorBID;
						INITIATOR_BRESP 		= int_initiatorBRESP;
						INITIATOR_BUSER 		= int_initiatorBUSER;
						INITIATOR_BVALID 		= int_initiatorBVALID;
						INITIATOR_ARREADY 		= int_initiatorARREADY;

						INITIATOR_RID 			= int_initiatorRID;
						INITIATOR_RDATA 		= int_initiatorRDATA;
						INITIATOR_RRESP 		= int_initiatorRRESP;
						INITIATOR_RLAST 		= int_initiatorRLAST;
						INITIATOR_RUSER 		= int_initiatorRUSER;
						INITIATOR_RVALID 		= int_initiatorRVALID;
						
					end
			end
			
	endgenerate
	
endmodule 
