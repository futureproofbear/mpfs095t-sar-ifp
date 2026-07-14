// ********************************************************************
//  Microsemi Corporation Proprietary and Confidential
//  Copyright 2017 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: This module provides a AXI4 Initiator test source. It
//              initialiates an Initiator transmission.
//
// Revision Information:
// Date     Description:
// Feb17    Revision 1.0
//
// Notes:
// best viewed with tabstops set to "4"
// ********************************************************************
`timescale 1ns / 1ns

`define SIM_MODE

module AxiInitiator # 
	(

		parameter [3:0]		INITIATOR_NUM				= 0,		// Initiator number
		parameter [1:0] 	INITIATOR_TYPE				= 2'b00,	// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11
		parameter integer 	ID_WIDTH   				= 2, 

		parameter integer 	ADDR_WIDTH      		= 20,				
		parameter integer 	DATA_WIDTH 				= 16, 

		parameter integer 	SUPPORT_USER_SIGNALS 	= 0,
		parameter integer 	USER_WIDTH 				= 1,
		
		parameter integer 	OPENTRANS_MAX			= 1,			// Number of open transations width - 1 => 2 transations, 2 => 4 transations, etc.

		parameter	HI_FREQ							= 0				// increases freq of operation at cost of added latency
		
	)
	(
		// Global Signals
		input  wire                         sysClk,
		input  wire                       	ARESETN,			// active high reset synchronoise to RE AClk - asserted async.
   
		//====================== Initiator Read Address Ports  ================================================//
		// Initiator Read Address Ports
		output  wire [ID_WIDTH-1:0]        	INITIATOR_ARID,
		output  wire [ADDR_WIDTH-1:0]      	INITIATOR_ARADDR,
		output  wire [7:0]                 	INITIATOR_ARLEN,
		output  wire [2:0]                 	INITIATOR_ARSIZE,
		output  wire [1:0]                 	INITIATOR_ARBURST,
		output  wire [1:0]                 	INITIATOR_ARLOCK,
		output  wire [3:0]                 	INITIATOR_ARCACHE,
		output  wire [2:0]                 	INITIATOR_ARPROT,
		output  wire [3:0]                 	INITIATOR_ARREGION,		// not used
		output  wire [3:0]                 	INITIATOR_ARQOS,			// not used
		output  wire [USER_WIDTH-1:0]      	INITIATOR_ARUSER,
		output  wire                       	INITIATOR_ARVALID,
		input 	wire                  		INITIATOR_ARREADY,
		
		// Initiator Read Data Ports
		input wire [ID_WIDTH-1:0]      		INITIATOR_RID,
		input wire [DATA_WIDTH-1:0]     	INITIATOR_RDATA,
		input wire [1:0]                    INITIATOR_RRESP,
		input wire                          INITIATOR_RLAST,
		input wire [USER_WIDTH-1:0]         INITIATOR_RUSER,
		input wire                          INITIATOR_RVALID,
		output wire                          INITIATOR_RREADY,
 
 		// Initiator Write Address Ports
		output  wire [ID_WIDTH-1:0]        	INITIATOR_AWID,
		output  wire [ADDR_WIDTH-1:0]      	INITIATOR_AWADDR,
		output  wire [7:0]                 	INITIATOR_AWLEN,
		output  wire [2:0]                 	INITIATOR_AWSIZE,
		output  wire [1:0]                 	INITIATOR_AWBURST,
		output  wire [1:0]                 	INITIATOR_AWLOCK,
		output  wire [3:0]                 	INITIATOR_AWCACHE,
		output  wire [2:0]                 	INITIATOR_AWPROT,
		output  wire [3:0]                 	INITIATOR_AWREGION,		// not used
		output  wire [3:0]                 	INITIATOR_AWQOS,			// not used
		output  wire [USER_WIDTH-1:0]      	INITIATOR_AWUSER,
		output  wire                       	INITIATOR_AWVALID,
		input 	wire                  		INITIATOR_AWREADY,
		
		// Initiator Write Data Ports
		output wire [ID_WIDTH-1:0]     	INITIATOR_WID,
		output wire [DATA_WIDTH-1:0]     	INITIATOR_WDATA,
		output wire [(DATA_WIDTH/8)-1:0]    INITIATOR_WSTRB,
		output wire                         INITIATOR_WLAST,
		output wire [USER_WIDTH-1:0]        INITIATOR_WUSER,
		output wire                         INITIATOR_WVALID,
		input  wire                         INITIATOR_WREADY,
  
		// Initiator Write Response Ports
		input  wire [ID_WIDTH-1:0]			INITIATOR_BID,
		input  wire [1:0]                   INITIATOR_BRESP,
		input  wire [USER_WIDTH-1:0]        INITIATOR_BUSER,
		input  wire      	                INITIATOR_BVALID,
		output wire	  	                    INITIATOR_BREADY,
   
		// ===============  Control Signals  =======================================================//
		input wire							INITIATOR_RREADY_Default,	// defines whether Initiator asserts ready or waits for RVALID
		input wire							INITIATOR_WREADY_Default,	// defines whether Initiator asserts ready or waits for wVALID
		input wire							d_INITIATOR_BREADY_default,
		input wire							rdStart,				// defines whether Initiator starts a transaction
		input wire [7:0]					rdBurstLen,				// burst length of read transaction
		input wire [ADDR_WIDTH-1:0]			rdStartAddr,			// start addresss for read transaction
		input wire [ID_WIDTH-1:0]			rdAID,					// AID for read transactions
		input wire [2:0]					rdASize,				// each transfer size
		input wire [1:0]					expRResp,				// indicate Read Respons expected
		
		output wire							initiatorRdAddrDone,		// Address Read transaction has been completed
		output wire							initiatorRdDone,			// Asserted when a read transaction has been completed
		output wire							initiatorRdStatus,			// Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
		output wire							initiatorRAddrIdle,			// indicates Read Address Bus is idle

		input wire							wrStart,				// defines whether Initiator starts a transaction
		input wire [1:0]					BurstType,				
		input wire [7:0]					wrBurstLen,				// burst length of write transaction
		input wire [ADDR_WIDTH-1:0]			wrStartAddr,			// start addresss for write transaction
		input wire [ID_WIDTH-1:0]			wrAID,					// AID for write transactions
		input wire [2:0]					wrASize,				// each transfer size
		input wire [1:0]					expWResp,				// indicate Read Respons expected
		
		output wire							initiatorWrAddrDone,		// Address Write transaction has been completed
		output wire							initiatorWrDone,			// Asserted when a write transaction has been completed
		output wire							initiatorRespDone,			// Asserted when a write response transaction has completed
		output wire							initiatorWrStatus,			// Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRespDone asserted
		output wire							initiatorWAddrIdle,			// indicates Read Address Bus is idle
		output wire							initiatorWrAddrFull,			// Asserted when the internal queue for writes are full
		output wire							initiatorRdAddrFull			// Asserted when the internal queue for writes are full
		

		
	);
	
	
//==========================================Local reg========================================

	wire [ID_WIDTH-1:0]        	ARID;
	wire [ADDR_WIDTH-1:0]      	ARADDR;
	wire [7:0]                 	ARLEN;
	wire [2:0]                 	ARSIZE;
	wire [1:0]                 	ARBURST;
	wire [1:0]                 	ARLOCK;
	wire [3:0]                 	ARCACHE;
	wire [2:0]                 	ARPROT;
	wire [3:0]                 	ARREGION;		// not used
	wire [3:0]                 	ARQOS;			// not used
	wire [USER_WIDTH-1:0]      	ARUSER;
	wire                       	ARVALID;
	wire                  		ARREADY;
		
	// Initiator Read Data Ports
	wire [ID_WIDTH-1:0]      	RID;
	wire [DATA_WIDTH-1:0]     	RDATA;
	wire [1:0]                  RRESP;
	wire                        RLAST;
	wire [USER_WIDTH-1:0]       RUSER;
	wire                        RVALID;
	wire                        RREADY;
 
 	// Initiator Write Address Ports
	wire [ID_WIDTH-1:0]        	AWID;
	wire [ADDR_WIDTH-1:0]      	AWADDR;
	wire [7:0]                 	AWLEN;
	wire [2:0]                 	AWSIZE;
	wire [1:0]                 	AWBURST;
	wire [1:0]                 	AWLOCK;
	wire [3:0]                 	AWCACHE;
	wire [2:0]                 	AWPROT;
	wire [3:0]                 	AWREGION;		// not used
	wire [3:0]                 	AWQOS;			// not used
	wire [USER_WIDTH-1:0]      	AWUSER;
	wire                       	AWVALID;
	wire                  		AWREADY;
		
	// Initiator Write Data Ports
	reg [ID_WIDTH-1:0]     		WID;
	wire [DATA_WIDTH-1:0]     	WDATA;
	wire [(DATA_WIDTH/8)-1:0]   WSTRB;
	wire                        WLAST;
	wire [USER_WIDTH-1:0]       WUSER;
	wire                        WVALID;
	wire                        WREADY;
  
	// Initiator Write Response Ports
	wire [ID_WIDTH-1:0]			BID;
	wire [1:0]                  BRESP;
	wire [USER_WIDTH-1:0]       BUSER;
	wire      	                BVALID;
	wire	  	                BREADY;
	/////////////////////////////////////
//modifiable signals depending on protocol
	reg [3:0] 				initrAWQOS;
	reg [3:0] 				initrAWREGION;
	reg [USER_WIDTH-1:0] 	initrAWUSER;
	reg [USER_WIDTH-1:0] 	initrWUSER;

	reg [3:0] 				initrARQOS;
	reg [3:0] 				initrARREGION;
	reg [USER_WIDTH-1:0] 	initrARUSER;
	
	reg [ID_WIDTH-1:0] 		initrAWID;
	reg [ID_WIDTH-1:0] 		initrWID;
	reg [ID_WIDTH-1:0] 		tempWID;
	reg [ID_WIDTH-1:0] 		tempBID;
	reg [ID_WIDTH-1:0]		initrBID;
	reg [ID_WIDTH-1:0]		initrRID;
	reg [ID_WIDTH-1:0]		initrARID;
	reg [ID_WIDTH-1:0]		tempARID;
	reg 			 		initrWLAST;
	reg [3:0] 				initrAWCACHE;
	reg [3:0] 				initrARCACHE;
	reg [7:0] 				initrAWLEN;
	reg [7:0] 				initrARLEN;
	reg [1:0] 				initrAWLOCK;
	reg [1:0] 				initrARLOCK;
	
	
	
//=======================================================


// Initiator Read Address Ports
assign INITIATOR_ARID = initrARID;
assign INITIATOR_ARADDR = ARADDR;
assign INITIATOR_ARLEN = initrARLEN;
assign INITIATOR_ARSIZE = ARSIZE;
assign INITIATOR_ARBURST = ARBURST;
assign INITIATOR_ARLOCK = initrARLOCK;
assign INITIATOR_ARCACHE = initrARCACHE;
assign INITIATOR_ARPROT = ARPROT;
assign INITIATOR_ARREGION = initrARREGION;
assign INITIATOR_ARQOS = initrARQOS;
assign INITIATOR_ARUSER = initrARUSER;
assign INITIATOR_ARVALID = ARVALID;
assign ARREADY = INITIATOR_ARREADY;

// Initiator Read Data Ports
assign RID = initrRID;
assign RDATA = INITIATOR_RDATA;
assign RRESP = INITIATOR_RRESP;
assign RLAST = INITIATOR_RLAST;
assign RUSER = INITIATOR_RUSER;
assign RVALID = INITIATOR_RVALID;		
assign INITIATOR_RREADY = RREADY;

// Initiator Write Address Ports
assign INITIATOR_AWID = initrAWID;
assign INITIATOR_AWADDR = AWADDR;
assign INITIATOR_AWLEN = initrAWLEN;
assign INITIATOR_AWSIZE = AWSIZE;
assign INITIATOR_AWBURST = AWBURST;
assign INITIATOR_AWLOCK  = initrAWLOCK;
assign INITIATOR_AWCACHE = initrAWCACHE;
assign INITIATOR_AWPROT = AWPROT;
assign INITIATOR_AWREGION = initrAWREGION;
assign INITIATOR_AWQOS = initrAWQOS;
assign INITIATOR_AWUSER = initrAWUSER;
assign INITIATOR_AWVALID = AWVALID;
assign AWREADY = INITIATOR_AWREADY;

// Initiator Write Data Ports
assign INITIATOR_WID = initrWID;
assign INITIATOR_WDATA = WDATA;
assign INITIATOR_WSTRB = WSTRB;
assign INITIATOR_WLAST = initrWLAST;
assign INITIATOR_WUSER = initrWUSER;
assign INITIATOR_WVALID = WVALID;
assign WREADY = INITIATOR_WREADY;

// Initiator Write Response Ports
assign BID = initrBID;
assign BRESP = INITIATOR_BRESP;
assign BUSER = INITIATOR_BUSER;
assign BVALID = INITIATOR_BVALID;
assign INITIATOR_BREADY = BREADY;



always @( * )
		begin
			  if (INITIATOR_TYPE == 2'b01)// if AXI4Lite
			  begin
				//signals not supported by AXI4Lite
				initrAWQOS = 0;
				initrAWREGION = 0;
				initrAWUSER = 0;
				initrWUSER = 0;
				initrARQOS = 0;
				initrARREGION = 0;
				initrARUSER = 0;
				//xID values are not supported by AXI4Lite protocol; all transactions must be sequential
				initrWID <= 0;
				initrARID <= 0;
				initrAWID <= 0;
				//signals defined by AXI4Lite protocol
				initrAWCACHE <= 0; 
				initrARCACHE <= 0;
				
				if (AWLEN > 0)
				begin
					$display( "%t  WARNING: AXI4Lite supports only transaction length of 1 ", $time );
				end
				if (ARLEN > 0)
				begin
					$display( "%t  WARNING: AXI4Lite supports only transaction length of 1 ", $time );
				end
				//xID values are not supported by AXI4Lite protocol; 
				if (INITIATOR_AWVALID)
				begin
					tempBID <= AWID;	
				end
				if (INITIATOR_BVALID)
				begin
					initrBID <= tempBID;
				end
				if (INITIATOR_ARVALID)
				begin
					tempARID <= ARID;	
				end
				if (INITIATOR_RVALID)
				begin
					initrRID <= tempARID;
				end

				if (WVALID)
				begin
					initrWLAST <= WLAST;
				end
				
				initrAWLEN <= 0;
				initrARLEN <= 0;
				initrAWLOCK  <= 0 ;
				initrARLOCK <= 0;
			  end
			  else if((INITIATOR_TYPE == 2'b11) | (INITIATOR_TYPE == 2'b10))//AXI3
			  begin
			  //signals not supported by AXI3
				initrAWQOS = 0;
				initrAWREGION = 0;
				initrAWUSER = 0;
				initrWUSER = 0;
				initrARQOS = 0;
				initrARREGION = 0;
				initrARUSER = 0;

				
				//required only for AXI3
				if (INITIATOR_AWVALID)
				begin
					tempWID <= AWID;
				end
				if (INITIATOR_WVALID)
				begin
					initrWID <=tempWID;
				end
				
				if (AWLEN > 15)
				begin
					$display( "%t  WARNING: AXI3 support transaction length up to 16 ", $time );
				end
				initrAWLEN[7:4] <= AWLEN[7:4]; // by protocol should be 0
				initrAWLEN[3:0] <= AWLEN[3:0];
				
				if (ARLEN > 15)
				begin
					$display( "%t  WARNING: AXI3 support transaction length up to 16 ", $time );
				end
				initrARLEN[7:4] <= ARLEN[7:4];// by protocol should be 0
				initrARLEN[3:0] <= ARLEN[3:0];
				
				initrAWID <= AWID;
				initrWLAST <= WLAST;
				initrAWCACHE <= AWCACHE; 
				initrARCACHE <= ARCACHE;
				initrAWLOCK  <= AWLOCK;
				initrARLOCK <= ARLOCK;
				initrBID <= INITIATOR_BID;
				initrARID <= ARID;
				initrRID <= INITIATOR_RID;
			  end
			  else //AXI4
			  begin
			    initrAWID <= AWID;
				initrAWQOS <= AWQOS;
				initrAWREGION <= AWREGION;
				initrAWUSER <= AWUSER;
				initrWUSER <= WUSER;
				initrARQOS <= ARQOS;
				initrARREGION <= ARREGION;
				initrARUSER <= ARUSER;
				initrWID <= 0;
				initrWLAST <= WLAST;
				initrAWCACHE <= AWCACHE; 
				initrARCACHE <= ARCACHE;
				initrAWLEN <= AWLEN;
				initrARLEN <= ARLEN;
				initrAWLOCK  <= AWLOCK;
				initrARLOCK <= ARLOCK;
				initrBID <= INITIATOR_BID;
				initrARID <= ARID;
				initrRID <= INITIATOR_RID;
			  end
		end
  

	//====================================================================================================================================
	// AXI4 Initiator transactor models - one for each mirrored initiator interface
	//====================================================================================================================================	
	Axi4InitiatorGen # 
				(
					.INITIATOR_NUM( INITIATOR_NUM ),		// target number
					.ID_WIDTH( ID_WIDTH ),

					.ADDR_WIDTH( ADDR_WIDTH ),				
					.DATA_WIDTH( DATA_WIDTH ), 
					.SUPPORT_USER_SIGNALS( SUPPORT_USER_SIGNALS ),
					.USER_WIDTH( USER_WIDTH ),
					.OPENTRANS_MAX( OPENTRANS_MAX )	// Number of open transations width - 1 => 2 transations, 2 => 4 transations, etc.
				)
			initiator0	(
					// Global Signals
					.sysClk( sysClk ),
					.ARESETN( ARESETN ),				// active high reset synchronoise to RE AClk - asserted async.
					
					// Initiator Read Address Ports
					.INITIATOR_ARID	( ARID ),
					.INITIATOR_ARADDR	( ARADDR ),
					.INITIATOR_ARLEN	( ARLEN ),
					.INITIATOR_ARSIZE	( ARSIZE ),
					.INITIATOR_ARBURST	( ARBURST ),
					.INITIATOR_ARLOCK	( ARLOCK ),
					.INITIATOR_ARCACHE	( ARCACHE ),
					.INITIATOR_ARPROT	( ARPROT ),
					.INITIATOR_ARREGION( ARREGION ),		// not used
					.INITIATOR_ARQOS	( ARQOS ),			// not used
					.INITIATOR_ARUSER	( ARUSER ),
					.INITIATOR_ARVALID	( ARVALID ),
					.INITIATOR_ARREADY	( ARREADY ),

					// Initiator Read Data Ports
					.INITIATOR_RID		( RID ),
					.INITIATOR_RDATA	( RDATA ),
					.INITIATOR_RRESP	( RRESP ),
					.INITIATOR_RLAST	( RLAST ),
					.INITIATOR_RUSER	( RUSER ),
					.INITIATOR_RVALID	( RVALID ),
					.INITIATOR_RREADY	( RREADY ),
					

					// Initiator Write Address Ports
					.INITIATOR_AWID	( AWID ),
					.INITIATOR_AWADDR	( AWADDR ),
					.INITIATOR_AWLEN	( AWLEN ),
					.INITIATOR_AWSIZE	( AWSIZE ),
					.INITIATOR_AWBURST	( AWBURST ),
					.INITIATOR_AWLOCK	( AWLOCK ),
					.INITIATOR_AWCACHE	( AWCACHE ),
					.INITIATOR_AWPROT	( AWPROT ),
					.INITIATOR_AWREGION( AWREGION ),		// not used
		          	.INITIATOR_AWQOS	( AWQOS ),				// not used
					.INITIATOR_AWUSER	( AWUSER ),
					.INITIATOR_AWVALID	( AWVALID ),
					.INITIATOR_AWREADY	( AWREADY ),
		
					// Initiator Write Data Ports
					.INITIATOR_WDATA	( WDATA ),
					.INITIATOR_WSTRB	( WSTRB ),
					.INITIATOR_WLAST	( WLAST ),
					.INITIATOR_WUSER	( WUSER ),
					.INITIATOR_WVALID	( WVALID ),
					.INITIATOR_WREADY	( WREADY ),


					// Initiator Write Response Ports
					.INITIATOR_BID		( BID ),
					.INITIATOR_BRESP	( BRESP ),
					.INITIATOR_BUSER	( BUSER ),
					.INITIATOR_BVALID	( BVALID ),
					.INITIATOR_BREADY	( BREADY ),
   
					// ===============  Control Signals  =======================================================//		
					.INITIATOR_RREADY_Default	( INITIATOR_RREADY_Default ),		// defines whether Initiator asserts ready or waits for RVALID
					.INITIATOR_WREADY_Default	( INITIATOR_WREADY_Default ),		// defines whether Initiator asserts ready or waits for RVALID
					.d_INITIATOR_BREADY_default( d_INITIATOR_BREADY_default ),		// defines whether Initiator asserts ready or waits for RVALID
					.rdStart				( rdStart ),					// defines whether Initiator starts a transaction
					.rdBurstLen				( rdBurstLen ),					// burst length of read transaction
					.rdStartAddr			( rdStartAddr ),				// start addresss for read transaction
					.rdAID					( rdAID ),						// AID for read transactions
					.rdASize				( rdASize  ),		
					.expRResp				( expRResp ),					// indicate Read Respons expected
					
					.initiatorRdAddrDone		( initiatorRdAddrDone ),		// Asserted when a read transaction has been completed
					.initiatorRdDone			( initiatorRdDone ),			// Asserted when a read transaction has been completed
					.initiatorRdStatus			( initiatorRdStatus ),			// Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
					.initiatorRAddrIdle			( initiatorRAddrIdle ),
		
					.wrStart				( wrStart ),					// defines whether Initiator starts a transaction
					.BurstType				( BurstType ),					// Type of burst - FIXED=00, INCR=01, WRAP=10 
					.wrBurstLen 			( wrBurstLen ),					// burst length of write transaction
					.wrStartAddr			( wrStartAddr ),				// start addresss for write transaction
					.wrAID					( wrAID ),						// AID for write transactions
					.wrASize				( wrASize ),
					.expWResp				( expWResp ),					// indicate Write Response expected

					.initiatorWrAddrDone		( initiatorWrAddrDone ),		// Address Write transaction has been completed
					.initiatorWrDone 			( initiatorWrDone ),			// Asserted when a write transaction has been completed
					.initiatorWrStatus 		( initiatorWrStatus ),			// Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
					.initiatorWAddrIdle 			( initiatorWAddrIdle ),			// indicates Read Address Bus is idle
					.initiatorRespDone			( initiatorRespDone ),			// Asserted when a write response transaction has completed
					.initiatorWrAddrFull			( initiatorWrAddrFull	),			// Asserted when the internal queue for writes are full
					.initiatorRdAddrFull			( initiatorRdAddrFull	)			// Asserted when the internal queue for reads are full
		);	


		
		
endmodule // AxiInitiator.v
