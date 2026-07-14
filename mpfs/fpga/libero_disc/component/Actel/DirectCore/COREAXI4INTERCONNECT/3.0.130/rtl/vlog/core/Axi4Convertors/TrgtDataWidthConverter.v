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

module caxi4interconnect_TrgtDataWidthConverter #

	(
		parameter integer 	NUM_TARGETS			= 4,			// defines number of target ports
		parameter integer	TARGET_DATA_WIDTH 	= 32,			// target valid data widths - 32, 64, 128, 256
		parameter integer 	TARGET_NUMBER		= 0,			//current target
		parameter integer 	ADDR_WIDTH      	= 20,			// valid values - 16 - 64
		parameter integer 	DATA_WIDTH 			= 32,			// valid widths - 32, 64, 128, 256
		parameter integer   MAX_TRANS       	= 2,				// max number of outstanding transactions per thread - valid range 1-8
		
		parameter [1:0] 	TARGET_TYPE			= 2'b00,		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b10
		
		parameter integer 	USER_WIDTH 			= 1,			// defines the number of bits for USER signals RUSER and WUSER
	
		parameter integer 	ID_WIDTH   			= 3,			// number of bits for ID (ie AID, WID, BID) - valid 1-8 
		
	    parameter [NUM_TARGETS-1:0]		TARGET_AWCHAN_RS	= { NUM_TARGETS{1'b1} },		// 0 - no AWCHAN register slice, 1 - AWCHAN register slice inserted
	    parameter [NUM_TARGETS-1:0]		TARGET_ARCHAN_RS	= { NUM_TARGETS{1'b1} },		// 0 - no ARCHAN register slice, 1 - ARCHAN register slice inserted
	    parameter [NUM_TARGETS-1:0]		TARGET_WCHAN_RS	= { NUM_TARGETS{1'b1} },		// 0 - no WCHAN register slice, 1 - WCHAN register slice inserted
	    parameter [NUM_TARGETS-1:0]		TARGET_RCHAN_RS	= { NUM_TARGETS{1'b1} },	// 0 - no RCHAN register slice, 1 - RCHAN register slice inserted
	    parameter [NUM_TARGETS-1:0]		TARGET_BCHAN_RS	= { NUM_TARGETS{1'b1} },		// 0 - no BCHAN register slice, 1 - BCHAN register slice inserted
	    parameter [13:0] DATA_FIFO_DEPTH = 14'h10,
        parameter integer DWC_ADDR_FIFO_DEPTH         = 'h10,
	    parameter         READ_INTERLEAVE             = 1,
        parameter         PIPE                        = 0,
        parameter         DWC_RAM_TYPE                = 3,
        parameter         SYNC_RESET                  = 0
		
	
	)
	(

	//=====================================  Global Signals   ========================================================================
	input  wire           			ACLK,
	input  wire          			arst_sync,
	input  wire          			srst_sync,
  //XBar side signals
	input wire [ID_WIDTH-1:0] 		int_targetARID,
	input wire [ADDR_WIDTH-1:0]		int_targetARADDR,
	input wire [7:0]        		int_targetARLEN,
	input wire [2:0]          		int_targetARSIZE,
	input wire [1:0]          		int_targetARBURST,
	input wire [1:0]          		int_targetARLOCK,
	input wire [3:0]           		int_targetARCACHE,
	input wire [2:0]         		int_targetARPROT,
	input wire [3:0]          		int_targetARREGION,
	input wire [3:0]          		int_targetARQOS,
	input wire [USER_WIDTH-1:0]		int_targetARUSER,
	input wire            			int_targetARVALID,
	output wire             			int_targetARREADY,

	// Target Read Data Ports	
	output wire [ID_WIDTH-1:0]   	int_targetRID,
	output wire [DATA_WIDTH-1:0]	int_targetRDATA,
	output wire [1:0]           	int_targetRRESP,
	output wire                		int_targetRLAST,
	output wire [USER_WIDTH-1:0] 	int_targetRUSER,
	output wire                 	int_targetRVALID,
	input wire               		int_targetRREADY,

	// Target Write Address Ports	
	input wire [ID_WIDTH-1:0]  		int_targetAWID,
	input wire [ADDR_WIDTH-1:0] 	int_targetAWADDR,
	input wire [7:0]           		int_targetAWLEN,
	input wire [2:0]           		int_targetAWSIZE,
	input wire [1:0]           		int_targetAWBURST,
	input wire [1:0]           		int_targetAWLOCK,
	input wire [3:0]          		int_targetAWCACHE,
	input wire [2:0]           		int_targetAWPROT,
	input wire [3:0]            	int_targetAWREGION,
	input wire [3:0]           		int_targetAWQOS,
	input wire [USER_WIDTH-1:0]   	int_targetAWUSER,
	input wire                 		int_targetAWVALID,
	output wire                		int_targetAWREADY,
	
	// Target Write Data Ports	
	input wire [ID_WIDTH-1:0]  	    int_targetWID,
	input wire [DATA_WIDTH-1:0]  	int_targetWDATA,
	input wire [(DATA_WIDTH/8)-1:0]	int_targetWSTRB,
	input wire                  	int_targetWLAST,
	input wire [USER_WIDTH-1:0] 	int_targetWUSER,
	input wire                  	int_targetWVALID,
	output wire                   	int_targetWREADY,
			
	// Target Write Response Ports	
	output  wire [ID_WIDTH-1:0]		int_targetBID,
	output  wire [1:0]           	int_targetBRESP,
	output  wire [USER_WIDTH-1:0] 	int_targetBUSER,
	output  wire      				int_targetBVALID,
	input wire						int_targetBREADY,

	//================================================= Target Side Ports  ================================================//

	// Target Read Address Ports	
	output  wire [ID_WIDTH-1:0]  	TARGET_ARID,
	output  wire [ADDR_WIDTH-1:0]	TARGET_ARADDR,
	output  wire [7:0]           	TARGET_ARLEN,
	output  wire [2:0]        		TARGET_ARSIZE,
	output  wire [1:0]           	TARGET_ARBURST,
	output  wire [1:0]         		TARGET_ARLOCK,
	output  wire [3:0]          	TARGET_ARCACHE,
	output  wire [2:0]         		TARGET_ARPROT,
	output  wire [3:0]          	TARGET_ARREGION,
	output  wire [3:0]          	TARGET_ARQOS,
	output  wire [USER_WIDTH-1:0]	TARGET_ARUSER,
	output  wire                	TARGET_ARVALID,
	input wire                		TARGET_ARREADY,
	
	// Target Read Data Ports	
	input wire [ID_WIDTH-1:0]  		TARGET_RID,
	input wire [TARGET_DATA_WIDTH-1:0]  	TARGET_RDATA,
	input wire [1:0]           		TARGET_RRESP,
	input wire                  	TARGET_RLAST,
	input wire [USER_WIDTH-1:0] 	TARGET_RUSER,
	input wire               		TARGET_RVALID,
	output wire                 	TARGET_RREADY,
	
	// Target Write Address Ports	
	output  wire [ID_WIDTH-1:0]   	TARGET_AWID,
	output  wire [ADDR_WIDTH-1:0] 	TARGET_AWADDR,
	output  wire [7:0]           	TARGET_AWLEN,
	output  wire [2:0]           	TARGET_AWSIZE,
	output  wire [1:0]           	TARGET_AWBURST,
	output  wire [1:0]            	TARGET_AWLOCK,
	output  wire [3:0]          	TARGET_AWCACHE,
	output  wire [2:0]           	TARGET_AWPROT,
	output  wire [3:0]           	TARGET_AWREGION,
	output  wire [3:0]           	TARGET_AWQOS,
	output  wire [USER_WIDTH-1:0] 	TARGET_AWUSER,
	output  wire                  	TARGET_AWVALID,
	input wire                		TARGET_AWREADY,
	
	// Target Write Data Ports	
	output wire [ID_WIDTH-1:0]      TARGET_WID,
	output wire [TARGET_DATA_WIDTH-1:0]   	TARGET_WDATA,
	output wire [(TARGET_DATA_WIDTH/8)-1:0] TARGET_WSTRB,
	output wire                   	TARGET_WLAST,
	output wire [USER_WIDTH-1:0] 	TARGET_WUSER,
	output wire                  	TARGET_WVALID,
	input wire                  	TARGET_WREADY,
	
	// Target Write Response Ports	
	input wire [ID_WIDTH-1:0]		TARGET_BID,
	input wire [1:0]           		TARGET_BRESP,
	input wire [USER_WIDTH-1:0]  	TARGET_BUSER,
	input wire      				TARGET_BVALID,
	output wire						TARGET_BREADY

	);


generate
	if ( TARGET_DATA_WIDTH == DATA_WIDTH) 		// Target data width == AXI4 xBar data width => direct connection
		begin
			//====================================== ASSIGNEMENTS =================================================
					//from crossbar to Target
			assign TARGET_AWID =	int_targetAWID;
			assign TARGET_AWADDR = int_targetAWADDR;
			assign TARGET_AWLEN = int_targetAWLEN;
			assign TARGET_AWSIZE = int_targetAWSIZE;
			assign TARGET_AWBURST = int_targetAWBURST;	
			assign TARGET_AWLOCK = int_targetAWLOCK;
			assign TARGET_AWCACHE = int_targetAWCACHE;	
			assign TARGET_AWPROT = int_targetAWPROT;
			assign TARGET_AWREGION = int_targetAWREGION;
			assign TARGET_AWQOS = int_targetAWQOS;
			assign TARGET_AWUSER = int_targetAWUSER;
			assign TARGET_AWVALID = int_targetAWVALID;	
			assign TARGET_WID   = int_targetWID;
			assign TARGET_WDATA = int_targetWDATA;
			assign TARGET_WSTRB = int_targetWSTRB;
			assign TARGET_WLAST = int_targetWLAST;
			assign TARGET_WUSER = int_targetWUSER;
			assign TARGET_WVALID = int_targetWVALID;
			assign TARGET_BREADY = int_targetBREADY;
			assign TARGET_ARID = int_targetARID;
			assign TARGET_ARADDR = int_targetARADDR;
			assign TARGET_ARLEN = int_targetARLEN;
			assign TARGET_ARSIZE = int_targetARSIZE;
			assign TARGET_ARBURST = int_targetARBURST;	
			assign TARGET_ARLOCK = int_targetARLOCK;
			assign TARGET_ARCACHE = int_targetARCACHE;	
			assign TARGET_ARPROT = int_targetARPROT;
			assign TARGET_ARREGION = int_targetARREGION;
			assign TARGET_ARQOS = int_targetARQOS;
			assign TARGET_ARUSER = int_targetARUSER;
			assign TARGET_ARVALID = int_targetARVALID;	
			assign TARGET_RREADY = int_targetRREADY;
			//			
			//from		Target to crossbar	
			assign int_targetAWREADY = TARGET_AWREADY;	
			assign int_targetWREADY = TARGET_WREADY;
			assign int_targetBID = TARGET_BID;
			assign int_targetBRESP =	TARGET_BRESP;
			assign int_targetBUSER =	TARGET_BUSER;
			assign int_targetBVALID = TARGET_BVALID;	
			assign int_targetARREADY = TARGET_ARREADY;	
						
			assign int_targetRID = TARGET_RID;
			assign int_targetRDATA =	TARGET_RDATA;
			assign int_targetRRESP =	TARGET_RRESP;
			assign int_targetRLAST =	TARGET_RLAST;
			assign int_targetRUSER =	TARGET_RUSER;
			assign int_targetRVALID = TARGET_RVALID;	

		end
	else if ( TARGET_DATA_WIDTH > DATA_WIDTH) 		// upscale
		begin

	                       localparam WRITE_ADDR_FIFO_EST = 2*MAX_TRANS; // Minimum caxi4interconnect_FIFO depth is 4, else twice OPEN_TRAND_MAX as we need 2 cmd caxi4interconnect_FIFO locations for most wraps

	                       localparam READ_ADDR_FIFO_EST  = 2*MAX_TRANS; // Minimum caxi4interconnect_FIFO depth is 4, else twice OPEN_TRAND_MAX as we need 2 cmd caxi4interconnect_FIFO locations for most wraps
						   
	                       localparam WRITE_ADDR_FIFO_DEPTH = (WRITE_ADDR_FIFO_EST > DWC_ADDR_FIFO_DEPTH) ?  DWC_ADDR_FIFO_DEPTH : WRITE_ADDR_FIFO_EST;

	                       localparam READ_ADDR_FIFO_DEPTH = (READ_ADDR_FIFO_EST > DWC_ADDR_FIFO_DEPTH) ?  DWC_ADDR_FIFO_DEPTH : READ_ADDR_FIFO_EST;


			caxi4interconnect_UpConverter #
					(
						.ID_WIDTH ( ID_WIDTH ), 	
						.ADDR_WIDTH( ADDR_WIDTH ),						
						.DATA_WIDTH( DATA_WIDTH ), 
						.WRITE_ADDR_FIFO_DEPTH ( WRITE_ADDR_FIFO_DEPTH ),
						.READ_ADDR_FIFO_DEPTH ( READ_ADDR_FIFO_DEPTH ),
						.DATA_WIDTH_IN 	( DATA_WIDTH ),
						.DATA_WIDTH_OUT ( TARGET_DATA_WIDTH ),
						.USER_WIDTH( USER_WIDTH ),
						.DATA_FIFO_DEPTH ( DATA_FIFO_DEPTH ),
						.READ_INTERLEAVE (READ_INTERLEAVE),
						.PIPE (PIPE),
						.DWC_RAM_TYPE (DWC_RAM_TYPE),
						.SYNC_RESET (SYNC_RESET)
					)
			TrgtUpConv (
						// Global Signals
						.ACLK( ACLK ),
						.arst_sync( arst_sync ),				
						.srst_sync( srst_sync ),				
	   
						// Initiator Read Address Ports
						.INITIATOR_ARID		( int_targetARID ),
						.INITIATOR_ARADDR		( int_targetARADDR ),
						.INITIATOR_ARLEN		( int_targetARLEN ),
						.INITIATOR_ARSIZE		( int_targetARSIZE ),
						.INITIATOR_ARBURST		( int_targetARBURST ),
						.INITIATOR_ARLOCK		( int_targetARLOCK ),
						.INITIATOR_ARCACHE		( int_targetARCACHE ),
						.INITIATOR_ARPROT		( int_targetARPROT ),
						.INITIATOR_ARREGION	( int_targetARREGION ),
						.INITIATOR_ARQOS		( int_targetARQOS ),
						.INITIATOR_ARUSER		( int_targetARUSER ),
						.INITIATOR_ARVALID		( int_targetARVALID ),
						.INITIATOR_AWQOS		( int_targetAWQOS ),
						.INITIATOR_AWREGION	( int_targetAWREGION ),
						.INITIATOR_AWID		( int_targetAWID ),
						.INITIATOR_AWADDR		( int_targetAWADDR ),
						.INITIATOR_AWLEN		( int_targetAWLEN ),
						.INITIATOR_AWSIZE		( int_targetAWSIZE ),
						.INITIATOR_AWBURST		( int_targetAWBURST ),
						.INITIATOR_AWLOCK		( int_targetAWLOCK ),
						.INITIATOR_AWCACHE		( int_targetAWCACHE ),
						.INITIATOR_AWPROT		( int_targetAWPROT ),
						.INITIATOR_AWUSER		( int_targetAWUSER ),
						.INITIATOR_AWVALID		( int_targetAWVALID ),
						.INITIATOR_WID         ( int_targetWID   ),
						.INITIATOR_WDATA		( int_targetWDATA ),
						.INITIATOR_WSTRB		( int_targetWSTRB ),
						.INITIATOR_WLAST		( int_targetWLAST ),
						.INITIATOR_WUSER		( int_targetWUSER ),
						.INITIATOR_WVALID		( int_targetWVALID ),
						.INITIATOR_BREADY		( int_targetBREADY ),
						.INITIATOR_RREADY		( int_targetRREADY ),
						.INITIATOR_ARREADY 	( int_targetARREADY),
						.INITIATOR_RID 		( int_targetRID ),
						.INITIATOR_RDATA 		( int_targetRDATA ),
						.INITIATOR_RRESP 		( int_targetRRESP ),
						.INITIATOR_RUSER 		( int_targetRUSER ),
						.INITIATOR_BID 		( int_targetBID ),
						.INITIATOR_BRESP 		( int_targetBRESP ),
						.INITIATOR_BUSER 		( int_targetBUSER ),
						.INITIATOR_RLAST 		( int_targetRLAST ),
						.INITIATOR_RVALID 		( int_targetRVALID ),
						.INITIATOR_AWREADY 	( int_targetAWREADY ),
						.INITIATOR_WREADY 		( int_targetWREADY ),
						.INITIATOR_BVALID 		( int_targetBVALID ),
						
						.TARGET_ARID			( TARGET_ARID ),
						.TARGET_ARADDR		( TARGET_ARADDR ),
						.TARGET_ARLEN		( TARGET_ARLEN ),
						.TARGET_ARSIZE		( TARGET_ARSIZE ),
						.TARGET_ARBURST		( TARGET_ARBURST ),
						.TARGET_ARLOCK		( TARGET_ARLOCK ),
						.TARGET_ARCACHE		( TARGET_ARCACHE ),
						.TARGET_ARPROT		( TARGET_ARPROT ),
						.TARGET_ARREGION		( TARGET_ARREGION ),
						.TARGET_ARQOS		( TARGET_ARQOS ),
						.TARGET_ARUSER		( TARGET_ARUSER ),
						.TARGET_ARVALID		( TARGET_ARVALID ),
						.TARGET_AWQOS		( TARGET_AWQOS ),
						.TARGET_AWREGION		( TARGET_AWREGION ),
						.TARGET_AWID			( TARGET_AWID ),
						.TARGET_AWADDR		( TARGET_AWADDR ),
						.TARGET_AWLEN		( TARGET_AWLEN ),
						.TARGET_AWSIZE		( TARGET_AWSIZE ),
						.TARGET_AWBURST		( TARGET_AWBURST ),
						.TARGET_AWLOCK		( TARGET_AWLOCK ),
						.TARGET_AWCACHE		( TARGET_AWCACHE ),
						.TARGET_AWPROT		( TARGET_AWPROT ),
						.TARGET_AWUSER		( TARGET_AWUSER ),
						.TARGET_AWVALID		( TARGET_AWVALID ),
						.TARGET_WID          ( TARGET_WID   ),
						.TARGET_WDATA		( TARGET_WDATA ),
						.TARGET_WSTRB		( TARGET_WSTRB ),
						.TARGET_WLAST		( TARGET_WLAST ),
						.TARGET_WUSER		( TARGET_WUSER ),
						.TARGET_WVALID		( TARGET_WVALID ),
						.TARGET_BREADY		( TARGET_BREADY ),
						.TARGET_RREADY		( TARGET_RREADY ),
						.TARGET_ARREADY 		( TARGET_ARREADY ),
						.TARGET_RID 			( TARGET_RID ),
						.TARGET_RDATA 		( TARGET_RDATA ),
						.TARGET_RRESP 		( TARGET_RRESP ),
						.TARGET_RUSER 		( TARGET_RUSER ),
						.TARGET_BID 			( TARGET_BID ),
						.TARGET_BRESP 		( TARGET_BRESP ),
						.TARGET_BUSER 		( TARGET_BUSER ),
						.TARGET_RLAST 		( TARGET_RLAST ),
						.TARGET_RVALID 		( TARGET_RVALID ),
						.TARGET_AWREADY 		( TARGET_AWREADY ),
						.TARGET_WREADY 		( TARGET_WREADY ),
						.TARGET_BVALID 		( TARGET_BVALID )

					); 
		end
	else if (DATA_WIDTH > TARGET_DATA_WIDTH) 		// down-scale
		begin

                               localparam DOWNCONV_RATIO = DATA_WIDTH/TARGET_DATA_WIDTH;

	                       localparam ADDR_FIFO_EST = ((MAX_TRANS*DOWNCONV_RATIO) > 4) ? 
					                                  ((DOWNCONV_RATIO > 4) ? 4*MAX_TRANS : 
													  (DOWNCONV_RATIO*MAX_TRANS)) : 4; // Minimum caxi4interconnect_FIFO depth is 4, else twice OPEN_TRAND_MAX as we need 2 cmd caxi4interconnect_FIFO locations for most wraps
	                       localparam ADDR_FIFO_DEPTH = (ADDR_FIFO_EST > DWC_ADDR_FIFO_DEPTH) ?  DWC_ADDR_FIFO_DEPTH : ADDR_FIFO_EST;

	caxi4interconnect_DownConverter #
			(
							.ID_WIDTH ( ID_WIDTH ), 	
							.ADDR_WIDTH( ADDR_WIDTH ),	
							.ADDR_FIFO_DEPTH( ADDR_FIFO_DEPTH ),
							.DATA_WIDTH_IN 	( DATA_WIDTH ),
							.DATA_WIDTH_OUT ( TARGET_DATA_WIDTH ),
							.STRB_WIDTH_IN 	( DATA_WIDTH/8 ),
							.STRB_WIDTH_OUT ( TARGET_DATA_WIDTH/8 ),
							.USER_WIDTH( USER_WIDTH ),
							.READ_INTERLEAVE (READ_INTERLEAVE),
							.PIPE           ( PIPE ),
							.DWC_RAM_TYPE   ( DWC_RAM_TYPE ),
							.SYNC_RESET     ( SYNC_RESET )
						)
	DownConverter_inst( .INITIATOR_ARADDR(int_targetARADDR),
                             .INITIATOR_ARBURST(int_targetARBURST),
                             .INITIATOR_ARCACHE(int_targetARCACHE),
                             .INITIATOR_ARID(int_targetARID),
                             .INITIATOR_ARLEN(int_targetARLEN),
                             .INITIATOR_ARLOCK(int_targetARLOCK),
                             .INITIATOR_ARPROT(int_targetARPROT),
                             .INITIATOR_ARQOS(int_targetARQOS),
                             .INITIATOR_ARREADY(int_targetARREADY),
                             .INITIATOR_ARREGION(int_targetARREGION),
                             .INITIATOR_ARSIZE(int_targetARSIZE),
                             .INITIATOR_ARUSER(int_targetARUSER),
                             .INITIATOR_ARVALID(int_targetARVALID),
                             .INITIATOR_RDATA(int_targetRDATA),
                             .INITIATOR_RID(int_targetRID),
                             .INITIATOR_RLAST(int_targetRLAST),
                             .INITIATOR_RREADY(int_targetRREADY),
                             .INITIATOR_RRESP(int_targetRRESP),
                             .INITIATOR_RUSER(int_targetRUSER),
                             .INITIATOR_RVALID(int_targetRVALID),
                             .INITIATOR_AWADDR(int_targetAWADDR),
                             .INITIATOR_AWBURST(int_targetAWBURST),
                             .INITIATOR_AWCACHE(int_targetAWCACHE),
                             .INITIATOR_AWID(int_targetAWID),
                             .INITIATOR_AWLEN(int_targetAWLEN),
                             .INITIATOR_AWLOCK(int_targetAWLOCK),
                             .INITIATOR_AWPROT(int_targetAWPROT),
                             .INITIATOR_AWQOS(int_targetAWQOS),
                             .INITIATOR_AWREADY(int_targetAWREADY),
                             .INITIATOR_AWREGION(int_targetAWREGION),
                             .INITIATOR_AWSIZE(int_targetAWSIZE),
                             .INITIATOR_AWUSER(int_targetAWUSER),
                             .INITIATOR_AWVALID(int_targetAWVALID),
                             .INITIATOR_WID(int_targetWID),
                             .INITIATOR_WDATA(int_targetWDATA),
                             .INITIATOR_WLAST(int_targetWLAST),
                             .INITIATOR_WREADY(int_targetWREADY),
                             .INITIATOR_WSTRB(int_targetWSTRB),
                             .INITIATOR_WUSER(int_targetWUSER),
                             .INITIATOR_WVALID(int_targetWVALID),
                             .INITIATOR_BID(int_targetBID),
                             .INITIATOR_BREADY(int_targetBREADY),
                             .INITIATOR_BRESP(int_targetBRESP),
                             .INITIATOR_BUSER(int_targetBUSER),
                             .INITIATOR_BVALID(int_targetBVALID),
                             .ACLK(ACLK),
                             .arst_sync(arst_sync),
                             .srst_sync(srst_sync),
                             .TARGET_BID(TARGET_BID),
                             .TARGET_BREADY(TARGET_BREADY),
                             .TARGET_BRESP(TARGET_BRESP),
                             .TARGET_BUSER(TARGET_BUSER),
                             .TARGET_BVALID(TARGET_BVALID),
                             .TARGET_ARADDR(TARGET_ARADDR),
                             .TARGET_ARBURST(TARGET_ARBURST),
                             .TARGET_ARCACHE(TARGET_ARCACHE),
                             .TARGET_ARID(TARGET_ARID),
                             .TARGET_ARLEN(TARGET_ARLEN),
                             .TARGET_ARLOCK(TARGET_ARLOCK),
                             .TARGET_ARPROT(TARGET_ARPROT),
                             .TARGET_ARQOS(TARGET_ARQOS),
                             .TARGET_ARREADY(TARGET_ARREADY),
                             .TARGET_ARREGION(TARGET_ARREGION),
                             .TARGET_ARSIZE(TARGET_ARSIZE),
                             .TARGET_ARUSER(TARGET_ARUSER),
                             .TARGET_ARVALID(TARGET_ARVALID),
                             .TARGET_AWADDR(TARGET_AWADDR),
                             .TARGET_AWBURST(TARGET_AWBURST),
                             .TARGET_AWCACHE(TARGET_AWCACHE),
                             .TARGET_AWID(TARGET_AWID),
                             .TARGET_AWLEN(TARGET_AWLEN),
                             .TARGET_AWLOCK(TARGET_AWLOCK),
                             .TARGET_AWPROT(TARGET_AWPROT),
                             .TARGET_AWQOS(TARGET_AWQOS),
                             .TARGET_AWREADY(TARGET_AWREADY),
                             .TARGET_AWREGION(TARGET_AWREGION),
                             .TARGET_AWSIZE(TARGET_AWSIZE),
                             .TARGET_AWUSER(TARGET_AWUSER),
                             .TARGET_AWVALID(TARGET_AWVALID),
                             .TARGET_RDATA(TARGET_RDATA),
                             .TARGET_RID(TARGET_RID),
                             .TARGET_RLAST(TARGET_RLAST),
                             .TARGET_RREADY(TARGET_RREADY),
                             .TARGET_RRESP(TARGET_RRESP),
                             .TARGET_RUSER(TARGET_RUSER),
                             .TARGET_RVALID(TARGET_RVALID),
                             .TARGET_WID(TARGET_WID),
                             .TARGET_WDATA(TARGET_WDATA),
                             .TARGET_WLAST(TARGET_WLAST),
                             .TARGET_WREADY(TARGET_WREADY),
                             .TARGET_WSTRB(TARGET_WSTRB),
                             .TARGET_WUSER(TARGET_WUSER),
                             .TARGET_WVALID(TARGET_WVALID)
		     );			
		end
	else
		begin
			initial 
				begin
					#1 $display("\n\n Module has called for an unsupported data width conversion : %m\n\n" );
					$stop;
				end
		end
		
endgenerate


endmodule 	// caxi4interconnect_TrgtDataWidthConverter.v
