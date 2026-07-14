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

module caxi4interconnect_IntrDataWidthConv #

	(
		parameter [1:0] 	INITIATOR_TYPE		      = 2'b00,	// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11
		parameter integer	INITIATOR_NUMBER	      = 0,		// Initiator number
		parameter integer   MAX_TRANS			      = 2,				// max number of outstanding transactions per thread - valid range 1-8
		parameter integer   ID_WIDTH   			      = 1, 
                                                      
		parameter integer   ADDR_WIDTH      	      = 20,
		parameter integer   DATA_WIDTH 			      = 16,
		parameter integer   INITIATOR_DATA_WIDTH	  = 32,

		parameter integer   USER_WIDTH 			      = 1,
  	    parameter integer   DWC_ADDR_FIFO_DEPTH       = 'h10,
		parameter [13:0]    DATA_FIFO_DEPTH           = 14'h10,
		parameter           READ_INTERLEAVE           = 1,
		parameter           PIPE                      = 0,
		parameter           DWC_RAM_TYPE              = 0,
		parameter           SYNC_RESET                = 0
	)
	(

	//=====================================  Global Signals   ========================================================================
	input  wire           			ACLK,
	input  wire          			arst_sync,
	input  wire          			srst_sync,
 
	//=====================================  Connections to/from Crossbar   ==========================================================
 
	output wire [ID_WIDTH-1:0] 		initiatorARID,
	output wire [ADDR_WIDTH-1:0]	initiatorARADDR,
	output wire [7:0]        		initiatorARLEN,
	output wire [2:0]          		initiatorARSIZE,
	output wire [1:0]          		initiatorARBURST,
	output wire [1:0]          		initiatorARLOCK,
	output wire [3:0]           	initiatorARCACHE,
	output wire [2:0]         		initiatorARPROT,
	output wire [3:0]          		initiatorARREGION,
	output wire [3:0]          		initiatorARQOS,
	output wire [USER_WIDTH-1:0]	initiatorARUSER,
	output wire            			initiatorARVALID,
	input wire             			initiatorARREADY,

	// Initiator Read Data Ports	
	input wire [ID_WIDTH-1:0]   	initiatorRID,
	input wire [DATA_WIDTH-1:0]		initiatorRDATA,
	input wire [1:0]           		initiatorRRESP,
	input wire                		initiatorRLAST,
	input wire [USER_WIDTH-1:0] 	initiatorRUSER,
	input wire                 		initiatorRVALID,
	output wire               		initiatorRREADY,

	// Initiator Write Address Ports	
	output wire [ID_WIDTH-1:0]  	initiatorAWID,
	output wire [ADDR_WIDTH-1:0] 	initiatorAWADDR,
	output wire [7:0]           	initiatorAWLEN,
	output wire [2:0]           	initiatorAWSIZE,
	output wire [1:0]           	initiatorAWBURST,
	output wire [1:0]           	initiatorAWLOCK,
	output wire [3:0]          		initiatorAWCACHE,
	output wire [2:0]           	initiatorAWPROT,
	output wire [3:0]            	initiatorAWREGION,
	output wire [3:0]           	initiatorAWQOS,
	output wire [USER_WIDTH-1:0]   	initiatorAWUSER,
	output wire                 	initiatorAWVALID,
	input wire                		initiatorAWREADY,
	
	// Initiator Write Data Ports	
	
	output wire [ID_WIDTH-1:0]          initiatorWID,
	output wire [DATA_WIDTH-1:0]  		initiatorWDATA,
	output wire [(DATA_WIDTH/8)-1:0]	initiatorWSTRB,
	output wire                  		initiatorWLAST,
	output wire [USER_WIDTH-1:0] 		initiatorWUSER,
	output wire                  		initiatorWVALID,
	input wire                   		initiatorWREADY,
			
	// Initiator Write Response Ports	
	input  wire [ID_WIDTH-1:0]		initiatorBID,
	input  wire [1:0]           	initiatorBRESP,
	input  wire [USER_WIDTH-1:0] 	initiatorBUSER,
	input  wire      				initiatorBVALID,
	output wire						initiatorBREADY,

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
	output wire                		INITIATOR_ARREADY,
	
	// Initiator Read Data Ports	
	output wire [ID_WIDTH-1:0]  	INITIATOR_RID,
	output wire [INITIATOR_DATA_WIDTH-1:0]  	INITIATOR_RDATA,
	output wire [1:0]           	INITIATOR_RRESP,
	output wire                  	INITIATOR_RLAST,
	output wire [USER_WIDTH-1:0] 	INITIATOR_RUSER,
	output wire               		INITIATOR_RVALID,
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
	output wire                		INITIATOR_AWREADY,
	
	// Initiator Write Data Ports	
	input wire [ID_WIDTH-1:0]       INITIATOR_WID,
	input wire [INITIATOR_DATA_WIDTH-1:0]   	INITIATOR_WDATA,
	input wire [(INITIATOR_DATA_WIDTH/8)-1:0]	INITIATOR_WSTRB,
	input wire                   	INITIATOR_WLAST,
	input wire [USER_WIDTH-1:0] 	INITIATOR_WUSER,
	input wire                  	INITIATOR_WVALID,
	output wire                  	INITIATOR_WREADY,
	
	// Initiator Write Response Ports	
	output wire [ID_WIDTH-1:0]		INITIATOR_BID,
	output wire [1:0]           	INITIATOR_BRESP,
	output wire [USER_WIDTH-1:0]  	INITIATOR_BUSER,
	output wire      				INITIATOR_BVALID,
	input wire						INITIATOR_BREADY

	) ;

	
generate
		if ( INITIATOR_DATA_WIDTH == DATA_WIDTH) 		// no data-width conversion so pass-through
			begin
				//====================================== ASSIGNEMENTS =================================================
						//from Initiator to crossbar & Target
				assign initiatorAWID =	INITIATOR_AWID;
				assign initiatorAWADDR = INITIATOR_AWADDR;
				assign initiatorAWLEN = INITIATOR_AWLEN;
				assign initiatorAWSIZE = INITIATOR_AWSIZE;
				assign initiatorAWBURST = INITIATOR_AWBURST;	
				assign initiatorAWLOCK = INITIATOR_AWLOCK;
				assign initiatorAWCACHE = INITIATOR_AWCACHE;	
				assign initiatorAWPROT = INITIATOR_AWPROT;
				assign initiatorAWREGION = INITIATOR_AWREGION;
				assign initiatorAWQOS = INITIATOR_AWQOS;
				assign initiatorAWUSER = INITIATOR_AWUSER;
				assign initiatorAWVALID = INITIATOR_AWVALID;	
				assign initiatorWID   = INITIATOR_WID;
				assign initiatorWDATA = INITIATOR_WDATA;
				assign initiatorWSTRB = INITIATOR_WSTRB;
				assign initiatorWLAST = INITIATOR_WLAST;
				assign initiatorWUSER = INITIATOR_WUSER;
				assign initiatorWVALID = INITIATOR_WVALID;
				assign initiatorBREADY = INITIATOR_BREADY;
				assign initiatorARID = INITIATOR_ARID;
				assign initiatorARADDR = INITIATOR_ARADDR;
				assign initiatorARLEN = INITIATOR_ARLEN;
				assign initiatorARSIZE = INITIATOR_ARSIZE;
				assign initiatorARBURST = INITIATOR_ARBURST;	
				assign initiatorARLOCK = INITIATOR_ARLOCK;
				assign initiatorARCACHE = INITIATOR_ARCACHE;	
				assign initiatorARPROT = INITIATOR_ARPROT;
				assign initiatorARREGION = INITIATOR_ARREGION;
				assign initiatorARQOS = INITIATOR_ARQOS;
				assign initiatorARUSER = INITIATOR_ARUSER;
				assign initiatorARVALID = INITIATOR_ARVALID;	
				assign initiatorRREADY = INITIATOR_RREADY;
				//			
				//from crossbar to INITIATOR
				assign INITIATOR_AWREADY = initiatorAWREADY;	
				assign INITIATOR_WREADY = initiatorWREADY;
				assign INITIATOR_BID = initiatorBID;
				assign INITIATOR_BRESP =	initiatorBRESP;
				assign INITIATOR_BUSER =	initiatorBUSER;
				assign INITIATOR_BVALID = initiatorBVALID;	
				assign INITIATOR_ARREADY = initiatorARREADY;	
							
				assign INITIATOR_RID = initiatorRID;
				assign INITIATOR_RDATA =	initiatorRDATA;
				assign INITIATOR_RRESP =	initiatorRRESP;
				assign INITIATOR_RLAST =	initiatorRLAST;
				assign INITIATOR_RUSER =	initiatorRUSER;
				assign INITIATOR_RVALID = initiatorRVALID;	

			end
		else if ( INITIATOR_DATA_WIDTH > DATA_WIDTH) 		// down-scale
			begin

	                       localparam ADDR_FIFO_EST = (INITIATOR_DATA_WIDTH/DATA_WIDTH) * MAX_TRANS; // Minimum caxi4interconnect_FIFO depth is 4, else twice OPEN_TRAND_MAX as we need 2 cmd caxi4interconnect_FIFO locations for most wraps
	                       localparam ADDR_FIFO_DEPTH = (ADDR_FIFO_EST > DWC_ADDR_FIFO_DEPTH) ?  DWC_ADDR_FIFO_DEPTH : ADDR_FIFO_EST;


				caxi4interconnect_DownConverter #
						(
							.ID_WIDTH ( ID_WIDTH ), 	
							.ADDR_WIDTH( ADDR_WIDTH ),	
							.ADDR_FIFO_DEPTH( ADDR_FIFO_DEPTH ),
							.DATA_WIDTH_IN 	( INITIATOR_DATA_WIDTH ),
							.DATA_WIDTH_OUT ( DATA_WIDTH ),
							.STRB_WIDTH_IN 	( INITIATOR_DATA_WIDTH/8 ),
							.STRB_WIDTH_OUT ( DATA_WIDTH/8 ),
							.USER_WIDTH( USER_WIDTH ),
							.READ_INTERLEAVE( READ_INTERLEAVE ),
							.PIPE           ( PIPE ),
							.DWC_RAM_TYPE   ( DWC_RAM_TYPE ),
							.SYNC_RESET     ( SYNC_RESET )
						)
	DownConverter_inst( .INITIATOR_ARADDR(INITIATOR_ARADDR),
                             .INITIATOR_ARBURST(INITIATOR_ARBURST),
                             .INITIATOR_ARCACHE(INITIATOR_ARCACHE),
                             .INITIATOR_ARID(INITIATOR_ARID),
                             .INITIATOR_ARLEN(INITIATOR_ARLEN),
                             .INITIATOR_ARLOCK(INITIATOR_ARLOCK),
                             .INITIATOR_ARPROT(INITIATOR_ARPROT),
                             .INITIATOR_ARQOS(INITIATOR_ARQOS),
                             .INITIATOR_ARREADY(INITIATOR_ARREADY),
                             .INITIATOR_ARREGION(INITIATOR_ARREGION),
                             .INITIATOR_ARSIZE(INITIATOR_ARSIZE),
                             .INITIATOR_ARUSER(INITIATOR_ARUSER),
                             .INITIATOR_ARVALID(INITIATOR_ARVALID),
                             .INITIATOR_RDATA(INITIATOR_RDATA),
                             .INITIATOR_RID(INITIATOR_RID),
                             .INITIATOR_RLAST(INITIATOR_RLAST),
                             .INITIATOR_RREADY(INITIATOR_RREADY),
                             .INITIATOR_RRESP(INITIATOR_RRESP),
                             .INITIATOR_RUSER(INITIATOR_RUSER),
                             .INITIATOR_RVALID(INITIATOR_RVALID),
                             .INITIATOR_AWADDR(INITIATOR_AWADDR),
                             .INITIATOR_AWBURST(INITIATOR_AWBURST),
                             .INITIATOR_AWCACHE(INITIATOR_AWCACHE),
                             .INITIATOR_AWID(INITIATOR_AWID),
                             .INITIATOR_AWLEN(INITIATOR_AWLEN),
                             .INITIATOR_AWLOCK(INITIATOR_AWLOCK),
                             .INITIATOR_AWPROT(INITIATOR_AWPROT),
                             .INITIATOR_AWQOS(INITIATOR_AWQOS),
                             .INITIATOR_AWREADY(INITIATOR_AWREADY),
                             .INITIATOR_AWREGION(INITIATOR_AWREGION),
                             .INITIATOR_AWSIZE(INITIATOR_AWSIZE),
                             .INITIATOR_AWUSER(INITIATOR_AWUSER),
                             .INITIATOR_AWVALID(INITIATOR_AWVALID),
							 .INITIATOR_WID  (INITIATOR_WID),
                             .INITIATOR_WDATA(INITIATOR_WDATA),
                             .INITIATOR_WLAST(INITIATOR_WLAST),
                             .INITIATOR_WREADY(INITIATOR_WREADY),
                             .INITIATOR_WSTRB(INITIATOR_WSTRB),
                             .INITIATOR_WUSER(INITIATOR_WUSER),
                             .INITIATOR_WVALID(INITIATOR_WVALID),
                             .INITIATOR_BID(INITIATOR_BID),
                             .INITIATOR_BREADY(INITIATOR_BREADY),
                             .INITIATOR_BRESP(INITIATOR_BRESP),
                             .INITIATOR_BUSER(INITIATOR_BUSER),
                             .INITIATOR_BVALID(INITIATOR_BVALID),
                             .ACLK(ACLK),
                             .arst_sync(arst_sync),
                             .srst_sync(srst_sync),
                             .TARGET_BID(initiatorBID),
                             .TARGET_BREADY(initiatorBREADY),
                             .TARGET_BRESP(initiatorBRESP),
                             .TARGET_BUSER(initiatorBUSER),
                             .TARGET_BVALID(initiatorBVALID),
                             .TARGET_ARADDR(initiatorARADDR),
                             .TARGET_ARBURST(initiatorARBURST),
                             .TARGET_ARCACHE(initiatorARCACHE),
                             .TARGET_ARID(initiatorARID),
                             .TARGET_ARLEN(initiatorARLEN),
                             .TARGET_ARLOCK(initiatorARLOCK),
                             .TARGET_ARPROT(initiatorARPROT),
                             .TARGET_ARQOS(initiatorARQOS),
                             .TARGET_ARREADY(initiatorARREADY),
                             .TARGET_ARREGION(initiatorARREGION),
                             .TARGET_ARSIZE(initiatorARSIZE),
                             .TARGET_ARUSER(initiatorARUSER),
                             .TARGET_ARVALID(initiatorARVALID),
                             .TARGET_AWADDR(initiatorAWADDR),
                             .TARGET_AWBURST(initiatorAWBURST),
                             .TARGET_AWCACHE(initiatorAWCACHE),
                             .TARGET_AWID(initiatorAWID),
                             .TARGET_AWLEN(initiatorAWLEN),
                             .TARGET_AWLOCK(initiatorAWLOCK),
                             .TARGET_AWPROT(initiatorAWPROT),
                             .TARGET_AWQOS(initiatorAWQOS),
                             .TARGET_AWREADY(initiatorAWREADY),
                             .TARGET_AWREGION(initiatorAWREGION),
                             .TARGET_AWSIZE(initiatorAWSIZE),
                             .TARGET_AWUSER(initiatorAWUSER),
                             .TARGET_AWVALID(initiatorAWVALID),
                             .TARGET_RDATA(initiatorRDATA),
                             .TARGET_RID(initiatorRID),
                             .TARGET_RLAST(initiatorRLAST),
                             .TARGET_RREADY(initiatorRREADY),
                             .TARGET_RRESP(initiatorRRESP),
                             .TARGET_RUSER(initiatorRUSER),
                             .TARGET_RVALID(initiatorRVALID),
							 .TARGET_WID (initiatorWID),
                             .TARGET_WDATA(initiatorWDATA),
                             .TARGET_WLAST(initiatorWLAST),
                             .TARGET_WREADY(initiatorWREADY),
                             .TARGET_WSTRB(initiatorWSTRB),
                             .TARGET_WUSER(initiatorWUSER),
                             .TARGET_WVALID(initiatorWVALID)
		     );
				
			end
		else if ( INITIATOR_DATA_WIDTH < DATA_WIDTH) 		// up-scale
			begin


	                       localparam WRITE_ADDR_FIFO_EST = (DATA_WIDTH/INITIATOR_DATA_WIDTH)*MAX_TRANS; // Minimum caxi4interconnect_FIFO depth is 4, else twice OPEN_TRAND_MAX as we need 2 cmd caxi4interconnect_FIFO locations for most wraps

	                       localparam READ_ADDR_FIFO_EST  = (DATA_WIDTH/INITIATOR_DATA_WIDTH)*MAX_TRANS; // Minimum caxi4interconnect_FIFO depth is 4, else twice OPEN_TRAND_MAX as we need 2 cmd caxi4interconnect_FIFO locations for most wraps
						   
	                       localparam WRITE_ADDR_FIFO_DEPTH = (WRITE_ADDR_FIFO_EST > DWC_ADDR_FIFO_DEPTH) ?  DWC_ADDR_FIFO_DEPTH : WRITE_ADDR_FIFO_EST;

	                       localparam READ_ADDR_FIFO_DEPTH = (READ_ADDR_FIFO_EST > DWC_ADDR_FIFO_DEPTH) ?  DWC_ADDR_FIFO_DEPTH: READ_ADDR_FIFO_EST;

				caxi4interconnect_UpConverter #
						(
							.ID_WIDTH              ( ID_WIDTH ), 	
							.ADDR_WIDTH            ( ADDR_WIDTH ),						
							.DATA_WIDTH            ( DATA_WIDTH ),
							.WRITE_ADDR_FIFO_DEPTH ( WRITE_ADDR_FIFO_DEPTH ),
							.READ_ADDR_FIFO_DEPTH  ( READ_ADDR_FIFO_DEPTH ),
							.DATA_WIDTH_IN 	       ( INITIATOR_DATA_WIDTH ),
							.DATA_WIDTH_OUT        ( DATA_WIDTH ),
							.USER_WIDTH            ( USER_WIDTH ),
							.DATA_FIFO_DEPTH       ( DATA_FIFO_DEPTH ),
							.READ_INTERLEAVE       (READ_INTERLEAVE),							
                            .PIPE                  (PIPE),							
                            .DWC_RAM_TYPE          (DWC_RAM_TYPE),							
                            .SYNC_RESET            (SYNC_RESET)
						) InitrUpConv
						(
							// Global Signals
							.ACLK( ACLK ),
							.arst_sync( arst_sync ),				// active low reset synchronoise to RE AClk - asserted async.
							.srst_sync( srst_sync ),				// active low reset synchronoise to RE AClk - asserted async.
		   
							// Initiator Read Address Ports
							.INITIATOR_ARID		( INITIATOR_ARID ),
							.INITIATOR_ARADDR		( INITIATOR_ARADDR ),
							.INITIATOR_ARLEN		( INITIATOR_ARLEN ),
							.INITIATOR_ARSIZE		( INITIATOR_ARSIZE ),
							.INITIATOR_ARBURST		( INITIATOR_ARBURST ),
							.INITIATOR_ARLOCK		( INITIATOR_ARLOCK ),
							.INITIATOR_ARCACHE		( INITIATOR_ARCACHE ),
							.INITIATOR_ARPROT		( INITIATOR_ARPROT ),
							.INITIATOR_ARREGION	( INITIATOR_ARREGION ),
							.INITIATOR_ARQOS		( INITIATOR_ARQOS ),
							.INITIATOR_ARUSER		( INITIATOR_ARUSER ),
							.INITIATOR_ARVALID		( INITIATOR_ARVALID ),
							.INITIATOR_AWQOS		( INITIATOR_AWQOS ),
							.INITIATOR_AWREGION	( INITIATOR_AWREGION ),
							.INITIATOR_AWID		( INITIATOR_AWID ),
							.INITIATOR_AWADDR		( INITIATOR_AWADDR ),
							.INITIATOR_AWLEN		( INITIATOR_AWLEN ),
							.INITIATOR_AWSIZE		( INITIATOR_AWSIZE ),
							.INITIATOR_AWBURST		( INITIATOR_AWBURST ),
							.INITIATOR_AWLOCK		( INITIATOR_AWLOCK ),
							.INITIATOR_AWCACHE		( INITIATOR_AWCACHE ),
							.INITIATOR_AWPROT		( INITIATOR_AWPROT ),
							.INITIATOR_AWUSER		( INITIATOR_AWUSER ),
							.INITIATOR_AWVALID		( INITIATOR_AWVALID ),
							.INITIATOR_WID         ( INITIATOR_WID),
							.INITIATOR_WDATA		( INITIATOR_WDATA ),
							.INITIATOR_WSTRB		( INITIATOR_WSTRB ),
							.INITIATOR_WLAST		( INITIATOR_WLAST ),
							.INITIATOR_WUSER		( INITIATOR_WUSER ),
							.INITIATOR_WVALID		( INITIATOR_WVALID ),
							.INITIATOR_BREADY		( INITIATOR_BREADY ),
							.INITIATOR_RREADY		( INITIATOR_RREADY ),
							.INITIATOR_ARREADY 	( INITIATOR_ARREADY),
							.INITIATOR_RID 		( INITIATOR_RID ),
							.INITIATOR_RDATA 		( INITIATOR_RDATA ),
							.INITIATOR_RRESP 		( INITIATOR_RRESP ),
							.INITIATOR_RUSER 		( INITIATOR_RUSER ),
							.INITIATOR_BID 		( INITIATOR_BID ),
							.INITIATOR_BRESP 		( INITIATOR_BRESP ),
							.INITIATOR_BUSER 		( INITIATOR_BUSER ),
							.INITIATOR_RLAST 		( INITIATOR_RLAST ),
							.INITIATOR_RVALID 		( INITIATOR_RVALID ),
							.INITIATOR_AWREADY 	( INITIATOR_AWREADY ),
							.INITIATOR_WREADY 		( INITIATOR_WREADY ),
							.INITIATOR_BVALID 		( INITIATOR_BVALID ),
							
							.TARGET_ARID			( initiatorARID ),
							.TARGET_ARADDR		( initiatorARADDR ),
							.TARGET_ARLEN		( initiatorARLEN ),
							.TARGET_ARSIZE		( initiatorARSIZE ),
							.TARGET_ARBURST		( initiatorARBURST ),
							.TARGET_ARLOCK		( initiatorARLOCK ),
							.TARGET_ARCACHE		( initiatorARCACHE ),
							.TARGET_ARPROT		( initiatorARPROT ),
							.TARGET_ARREGION		( initiatorARREGION ),
							.TARGET_ARQOS		( initiatorARQOS ),
							.TARGET_ARUSER		( initiatorARUSER ),
							.TARGET_ARVALID		( initiatorARVALID ),
							.TARGET_AWQOS		( initiatorAWQOS ),
							.TARGET_AWREGION		( initiatorAWREGION ),
							.TARGET_AWID			( initiatorAWID ),
							.TARGET_AWADDR		( initiatorAWADDR ),
							.TARGET_AWLEN		( initiatorAWLEN ),
							.TARGET_AWSIZE		( initiatorAWSIZE ),
							.TARGET_AWBURST		( initiatorAWBURST ),
							.TARGET_AWLOCK		( initiatorAWLOCK ),
							.TARGET_AWCACHE		( initiatorAWCACHE ),
							.TARGET_AWPROT		( initiatorAWPROT ),
							.TARGET_AWUSER		( initiatorAWUSER ),
							.TARGET_AWVALID		( initiatorAWVALID ),
							.TARGET_WID          ( initiatorWID),
							.TARGET_WDATA		( initiatorWDATA ),
							.TARGET_WSTRB		( initiatorWSTRB ),
							.TARGET_WLAST		( initiatorWLAST ),
							.TARGET_WUSER		( initiatorWUSER ),
							.TARGET_WVALID		( initiatorWVALID ),
							.TARGET_BREADY		( initiatorBREADY ),
							.TARGET_RREADY		( initiatorRREADY ),
							.TARGET_ARREADY 		( initiatorARREADY ),
							.TARGET_RID 			( initiatorRID ),
							.TARGET_RDATA 		( initiatorRDATA ),
							.TARGET_RRESP 		( initiatorRRESP ),
							.TARGET_RUSER 		( initiatorRUSER ),
							.TARGET_BID 			( initiatorBID ),
							.TARGET_BRESP 		( initiatorBRESP ),
							.TARGET_BUSER 		( initiatorBUSER ),
							.TARGET_RLAST 		( initiatorRLAST ),
							.TARGET_RVALID 		( initiatorRVALID ),
							.TARGET_AWREADY 		( initiatorAWREADY ),
							.TARGET_WREADY 		( initiatorWREADY ),
							.TARGET_BVALID 		( initiatorBVALID )

						); 

			end
		else 				// this is an error condition - only 32-64 or 64-32 supported
			begin
				initial 
					begin
						#1 $display("\n\n Module has called for an unsupported data width conversion : %m\n\n" );
						$stop;
					end
			end
			
endgenerate
	
endmodule		// caxi4interconnect_IntrDataWidthConv.v
