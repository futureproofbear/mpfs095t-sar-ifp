// ********************************************************************
//  Microsemi Corporation Proprietary and Confidential
//  Copyright 2017 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: This module provides a AXI4 Initiator test source. It initialiates a Initiator transmission.
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

module Axi4InitiatorGen # 
	(

		parameter [3:0]		INITIATOR_NUM				= 0,		// initiator number
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
		output  reg [ID_WIDTH-1:0]        	INITIATOR_ARID,
		output  reg [ADDR_WIDTH-1:0]      	INITIATOR_ARADDR,
		output  reg [7:0]                 	INITIATOR_ARLEN,
		output  reg [2:0]                 	INITIATOR_ARSIZE,
		output  reg [1:0]                 	INITIATOR_ARBURST,
		output  reg [1:0]                 	INITIATOR_ARLOCK,
		output  reg [3:0]                 	INITIATOR_ARCACHE,
		output  reg [2:0]                 	INITIATOR_ARPROT,
		output  reg  [3:0]                	INITIATOR_ARREGION,		// not used
		output  reg  [3:0]                	INITIATOR_ARQOS,			// not used
		output  reg [USER_WIDTH-1:0]      	INITIATOR_ARUSER,
		output  reg                       	INITIATOR_ARVALID,
		input 	wire                    		INITIATOR_ARREADY,
		
		// Initiator Read Data Ports
		input wire [ID_WIDTH-1:0]      	  	INITIATOR_RID,
		input wire [DATA_WIDTH-1:0]        	INITIATOR_RDATA,
		input wire [1:0]                    INITIATOR_RRESP,
		input wire                          INITIATOR_RLAST,
		input wire [USER_WIDTH-1:0]         INITIATOR_RUSER,
		input wire                          INITIATOR_RVALID,
		output reg                          INITIATOR_RREADY,
 
 		// Initiator Write Address Ports
		output  reg [ID_WIDTH-1:0]        	INITIATOR_AWID,
		output  reg [ADDR_WIDTH-1:0]      	INITIATOR_AWADDR,
		output  reg [7:0]                 	INITIATOR_AWLEN,
		output  reg [2:0]                 	INITIATOR_AWSIZE,
		output  reg [1:0]                 	INITIATOR_AWBURST,
		output  reg [1:0]                 	INITIATOR_AWLOCK,
		output  reg [3:0]                 	INITIATOR_AWCACHE,
		output  reg [2:0]                 	INITIATOR_AWPROT,
		output  reg [3:0]                 	INITIATOR_AWREGION,		// not used
		output  reg [3:0]                 	INITIATOR_AWQOS,			// not used
		output  reg [USER_WIDTH-1:0]      	INITIATOR_AWUSER,
		output  reg                       	INITIATOR_AWVALID,
		input 	wire                  		  INITIATOR_AWREADY,
		
		// Initiator Write Data Ports
		output reg [DATA_WIDTH-1:0]     	  INITIATOR_WDATA,
		output reg [(DATA_WIDTH/8)-1:0]     INITIATOR_WSTRB,
		output reg                          INITIATOR_WLAST,
		output reg [USER_WIDTH-1:0]         INITIATOR_WUSER,
		output reg                          INITIATOR_WVALID,
		output reg [USER_WIDTH-1:0]         INITIATOR_WID,
		input  wire                         INITIATOR_WREADY,
  
		// Initiator Write Response Ports
		input  wire [ID_WIDTH-1:0]		    	INITIATOR_BID,
		input  wire [1:0]                   INITIATOR_BRESP,
		input  wire [USER_WIDTH-1:0]        INITIATOR_BUSER,
		input  wire      	                  INITIATOR_BVALID,
		output reg	  	                    INITIATOR_BREADY,
   
		// ===============  Control Signals  =======================================================//
		input wire				   	  		INITIATOR_RREADY_Default,  	// defines whether Initiator asserts ready or waits for RVALID
		input wire				     			INITIATOR_WREADY_Default,  	// defines whether Initiator asserts ready or waits for wVALID
		input wire					     		d_INITIATOR_BREADY_default,
		input wire							    rdStart,									// defines whether Initiator starts a transaction
		input wire [7:0]				   	rdBurstLen,								// burst length of read transaction
		input wire [ADDR_WIDTH-1:0]	rdStartAddr,							// start addresss for read transaction
		input wire [ID_WIDTH-1:0]		rdAID,					  				// AID for read transactions
		input wire [2:0]				  	rdASize,									// each transfer size
		input wire [1:0]				  	expRResp,									// indicate Read Respons expected
		
		output reg					    		initiatorRdAddrDone,		// Address Read transaction has been completed
		output reg				    			initiatorRdDone,		  	// Asserted when a read transaction has been completed
		output reg					    		initiatorRdStatus,			// Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRdDone asserted
		output reg					    		initiatorRAddrIdle,		  	// indicates Read Address Bus is idle
  
		input wire					    		wrStart,			 			// defines whether Initiator starts a transaction
		input wire [1:0]			  		BurstType,					// Type of burst - FIXED=00, INCR=01, WRAP=10 
		input wire [7:0]			  		wrBurstLen,					// burst length of write transaction
		input wire [ADDR_WIDTH-1:0]	wrStartAddr,				// start addresss for write transaction
		input wire [ID_WIDTH-1:0]		wrAID,						  // AID for write transactions
		input wire [2:0]					  wrASize,				  	// each transfer size
		input wire [1:0]					  expWResp,				  	// indicate Read Respons expected
		
		output reg									initiatorWrAddrDone,		// Address Write transaction has been completed
		output reg									initiatorWrDone,		  	// Asserted when a write transaction has been completed
		output reg									initiatorRespDone,			// Asserted when a write response transaction has completed
		output reg									initiatorWrStatus,			// Status of read transaction - Pass =1, Fail=0. Only valid when initiatorRespDone asserted
		output reg									initiatorWAddrIdle,		  	// indicates Read Address Bus is idle
		output wire									initiatorWrAddrFull,			// Asserted when the internal queue for writes are full
		output wire									initiatorRdAddrFull		  	// Asserted when the internal queue for writes are full

		
	);

//================================================================================================
// Local Parameters
//================================================================================================
 
localparam	READFIF_WIDTH = ( ID_WIDTH + ADDR_WIDTH + 8 + 3 + 2 );			// ID, Addr, LEN and SIZE, and Burst 

localparam	[2:0]		INITIATOR_ASIZE_DEFAULT	= 	(DATA_WIDTH == 'd16) ? 3'h1 :
													(DATA_WIDTH == 'd32) ? 3'h2 :
													(DATA_WIDTH == 'd64) ? 3'h3 :
													(DATA_WIDTH == 'd128) ? 3'h4 :
													(DATA_WIDTH == 'd256) ? 3'h5 :
													(DATA_WIDTH == 'd512) ? 3'h6 :
													(DATA_WIDTH == 'd1024) ? 3'h7 :
														3'b000;		// not supported

wire						fifoOverRunErr, fifoUnderRunErr;
	
reg [READFIF_WIDTH-1:0]		readFifWrData;
wire [READFIF_WIDTH-1:0]	readFifRdData;

reg							readFifWr, readFifRd;
wire						readFifoFull, readFifoEmpty;
 
reg [15:0]					arCount, d_arCount; 
reg [15:0]					rdCount, d_rdCount; 

reg [5:0]					wAddrMask;

  wire [4:0]   rd_addr_beat;
  wire [4:0]   rd_to_boundary_initiator;
   wire      [9:0]  ReadAddrMaskWrap;


//====================================================================================================
// Local Declarationes for Initiator Read Address 
//====================================================================================================

localparam	[2:0]		rstIDLE = 3'h0,	rstDATA = 3'h1;

reg						d_INITIATOR_RREADY;

reg [2:0]				rcurrState, rnextState;

reg [ID_WIDTH-1:0]		transID;
reg [1:0]			burstType;

reg	[DATA_WIDTH-1:0]	d_rxLen, rxLen;

reg [7:0]				burstLen;
reg [2:0] burstSize;
wire [5:0] ReadAddrMask;
wire [ADDR_WIDTH-1:0]	startRdAddr;
reg [ADDR_WIDTH-1:0]	curRdAddr, d_curRdAddr;

reg [DATA_WIDTH-1:0]	rDataMask;
wire [DATA_WIDTH-1:0] shift_dataMask;
wire [DATA_WIDTH-1:0] mask_rDataMask;
wire [DATA_WIDTH-1:0] mask_rDataMask_exp;
wire [10:0] shift_fixed;
wire [DATA_WIDTH-1:0] addr_shift;
wire [DATA_WIDTH-1:0] exp_mask_shift;

wire					sysReset;

wire [DATA_WIDTH-1:0] baseValue;

reg [8:0] rdata_rand_sig;
reg [8:0] bready_rand_sig;

wire[5:0] align_addr_32;
wire[5:0] align_addr;
wire[31:0] mask_unalign;

genvar i;

generate
for (i=0; i<(DATA_WIDTH/8);i=i+1) begin
	assign baseValue[(8*i)+:8] = i;
end
endgenerate

assign shift_fixed = ((burstType == 2'b00) && (INITIATOR_ARSIZE > 2) && (((2**INITIATOR_ARSIZE) -  ((curRdAddr[5:0]) & ((2**INITIATOR_ARSIZE) - 1))) > 4)) ? ((8*((2**INITIATOR_ARSIZE)-(align_addr & 6'h3c))) - 32) : 0;

//=======================================================================================================================
// Local system reset - asserted asynchronously to ACLK and deasserted synchronous
//=======================================================================================================================
//caxi4interconnect_ResetSycnc  
//	rsync(
//			.sysClk	( sysClk ),
//			.sysReset_L( ARESETN ),			// active low reset synchronoise to RE AClk - asserted async.
//			.sysReset( sysReset  )			// active low sysReset synchronised to ACLK
//	);
	assign sysReset = ARESETN; // Temp reomved this block to test silicon issue

//=====================================================================================================
// Compute Mask for mis-aligned data
//=====================================================================================================
always @( * )
	begin
		rDataMask <= { DATA_WIDTH{1'b0}  };		// initialise mask to all invalid

  // The below case statement(DATA_WIDTH) allows the mask to be applied properly.
  // The size of the bus determines the max transfer size
  case (DATA_WIDTH)
    // The case statement (INITIATOR_ARSIZE) applies the 1's to the appropriate part of the mask
    // by shifting in a defined number of 1's to the appropriate location.
    // Indexing is multiplied (by 8, 16, 32, 64, 128, 256) as the mask is set on a 'per-bit' basis.
    'd32 :  case(INITIATOR_ARSIZE)
             3'b000 : rDataMask[(8*curRdAddr[1:0]) +: 8] <= {1{8'hff}};
             3'b001 : rDataMask[(16*curRdAddr[1]) +: 16] <= {2{8'hff}};
             3'b010 : rDataMask[31 : 0] <= {4{8'hff}};
            endcase
    'd64 :  case (INITIATOR_ARSIZE)
             3'b000 : rDataMask[(8*curRdAddr[2:0]) +: 8]   <= {1{8'hff}};
             3'b001 : rDataMask[(16*curRdAddr[2:1]) +: 16] <= {2{8'hff}};
             3'b010 : rDataMask[(32*curRdAddr[2]) +: 32]   <= {4{8'hff}};
             3'b011 : rDataMask[63 : 0] <= {8{8'hff}};
            endcase
    'd128 : case (INITIATOR_ARSIZE)
             3'b000 : rDataMask[(8*curRdAddr[3:0]) +: 8]   <= {1{8'hff}};
             3'b001 : rDataMask[(16*curRdAddr[3:1]) +: 16] <= {2{8'hff}};
             3'b010 : rDataMask[(32*curRdAddr[3:2]) +: 32] <= {4{8'hff}};
             3'b011 : rDataMask[(64*curRdAddr[3]) +: 64]   <= {8{8'hff}};
             3'b100 : rDataMask[127 : 0] <=  {16{8'hff}};
            endcase
    'd256 : case (INITIATOR_ARSIZE)
             3'b000 : rDataMask[(8*curRdAddr[4:0]) +: 8]     <= {1{8'hff}};
             3'b001 : rDataMask[(16*curRdAddr[4:1]) +: 16]   <= {2{8'hff}};
             3'b010 : rDataMask[(32*curRdAddr[4:2]) +: 32]   <= {4{8'hff}};
             3'b011 : rDataMask[(64*curRdAddr[4:3]) +: 64]   <= {8{8'hff}};
             3'b100 : rDataMask[(128*curRdAddr[4]) +: 128]   <= {16{8'hff}};
             3'b101 : rDataMask[255 : 0] <= {32{8'hff}};
            endcase
    'd512 : case (INITIATOR_ARSIZE)
             3'b000 : rDataMask[(8*curRdAddr[5:0]) +: 8]     <= {1{8'hff}};
             3'b001 : rDataMask[(16*curRdAddr[5:1]) +: 16]   <= {2{8'hff}};
             3'b010 : rDataMask[(32*curRdAddr[5:2]) +: 32]   <= {4{8'hff}};
             3'b011 : rDataMask[(64*curRdAddr[5:3]) +: 64]   <= {8{8'hff}};
             3'b100 : rDataMask[(128*curRdAddr[5:4]) +: 128] <= {16{8'hff}};
             3'b101 : rDataMask[(256*curRdAddr[5]) +: 256]   <= {32{8'hff}};
             3'b110 : rDataMask[511 : 0] <= {64{8'hff}};
            endcase
  endcase
end

//=============================================================================================
// Display messages only in Simulation - not synthesis
//=============================================================================================
`ifdef SIM_MODE
	
	//============================================================================================
	// Display messages for Read Address Channel	
	//=============================================================================================
	always @( posedge sysClk )
		begin
			#1;

			if ( INITIATOR_ARVALID )
				begin
					#1 $display( "%d, INITIATOR  %d - Starting Read Address Transaction %d, ARADDR= %h, ARBURST= %h, ARSIZE= %h, AID= %h, RXLEN= %d", 
											$time, INITIATOR_NUM, arCount, INITIATOR_ARADDR, INITIATOR_ARBURST, INITIATOR_ARSIZE, INITIATOR_ARID, INITIATOR_ARLEN );

					if ( INITIATOR_ARREADY )		// single beat
						begin
							#1 $display( "%d, INITIATOR  %d - Ending Read Address Transaction %d, AID= %h, RXLEN= %d", 
											$time, INITIATOR_NUM, arCount, INITIATOR_ARID, INITIATOR_ARLEN );
						end
					else
						begin
							@( posedge INITIATOR_ARREADY )
								#1 $display( "%d, INITIATOR  %d - Ending Read Address Transactions %d, AID= %h, RXLEN= %d", 
											$time, INITIATOR_NUM, arCount, INITIATOR_ARID, INITIATOR_ARLEN );
						end
				end
		end


		//=============================================================================================
		// Display messages for Read Data Channel
		//=============================================================================================
		always @( posedge sysClk )
			begin
				#1;

				if ( INITIATOR_RVALID )
					begin
						#1 $display( "%d, INITIATOR %d - Starting Read Data Transaction %d, RADDR= %h (%d), AID= %h, RXLEN= %d", 
										$time, INITIATOR_NUM, rdCount, curRdAddr, curRdAddr, INITIATOR_RID, burstLen );

						if ( INITIATOR_RLAST & INITIATOR_RVALID & INITIATOR_RREADY )		// single beat
							begin
								#1 $display( "%d, INITIATOR %d - Ending Read Data Transaction %d, AID= %h, RXLEN= %d", 
										$time, INITIATOR_NUM, rdCount, INITIATOR_RID, burstLen );
							end
						else
							begin
								@( posedge ( INITIATOR_RLAST & INITIATOR_RVALID & INITIATOR_RREADY ) )
									#1 $display( "%d, INITIATOR %d - Ending Read Data Transactions %d, AID= %h, RXLEN= %d, RRESP= %h", 
										$time, INITIATOR_NUM, rdCount, INITIATOR_RID, burstLen, INITIATOR_RRESP );
							end
					end
			end


		//=============================================================================================
		// Display messages for Read Data 
		//=============================================================================================
		always @( negedge sysClk )
			begin
				#1;

				if ( INITIATOR_RVALID & INITIATOR_RREADY )
					begin
						#1
						`ifdef VERBOSE
							$display( "%d, INITIATOR %d DATA: - RADDR= %h (%d), exp RDATA= %h, mask= %h, act RDATA= %h", $time, INITIATOR_NUM, 
												curRdAddr, curRdAddr, (rxLen+ INITIATOR_NUM + baseValue ), rDataMask & mask_rDataMask, INITIATOR_RDATA  );					
						`endif

						//===========================================================
						// For first beat in burst Mask out unused bytes
						//===========================================================
						
						if ( ( ( INITIATOR_RDATA & rDataMask & mask_rDataMask )!== ( (rxLen + INITIATOR_NUM + baseValue) & rDataMask & mask_rDataMask_exp ) ) & (expRResp == 0 ) & (burstType != 2'b00)  )
							begin
								$display( "%d, INITIATOR %d DATA ERROR - RADDR= %h (%d) exp RDATA= %h, mask= %h, act RDATA= %h", 
												$time, INITIATOR_NUM, curRdAddr, curRdAddr, ( rxLen+ INITIATOR_NUM + baseValue  ), rDataMask & mask_rDataMask, INITIATOR_RDATA  );
                $display( "360\t\t\trxLen: %h, d_rxLen: %h, INITIATOR_NUM: %h, INITIATOR_ARLEN: %h", rxLen, d_rxLen, INITIATOR_NUM, INITIATOR_ARLEN );

								initiatorRdStatus 	<= 0;
									
								if ( expRResp == 0 )		// if expect no error
									begin
										#1 $stop;
									end
							end
						else if ( ( ((( INITIATOR_RDATA  >> shift_fixed) & rDataMask ) & mask_rDataMask & (mask_unalign << 8*align_addr_32)  )!== ( ( (burstLen + INITIATOR_NUM + baseValue) & rDataMask  & mask_rDataMask_exp ) >> shift_fixed) ) & (expRResp == 0 ) & (burstType == 2'b00)  )
							begin
								$display( "%d, INITIATOR %d ERROR - exp RDATA= %h, act RDATA= %h", $time, INITIATOR_NUM, 
												( ( (burstLen + INITIATOR_NUM + baseValue) & rDataMask  & mask_rDataMask_exp ) >> shift_fixed), ((( INITIATOR_RDATA  >> shift_fixed) & rDataMask ) & mask_rDataMask & (mask_unalign << 8*align_addr_32)  )  );
								initiatorRdStatus 	<= 0;
								if ( expRResp == 0 )		// if expect no error
									begin
										#1 $stop;
									end		
							end
					end
			end
`endif


 //===========================================================================================
 // FIFO to hold open transactions - pushed on Address Read cycle and popped on read data
 // cycle.
 //===========================================================================================
 caxi4interconnect_FifoDualPort #(	.FIFO_AWIDTH( OPENTRANS_MAX ),
					.FIFO_WIDTH( READFIF_WIDTH ),
					.HI_FREQ( HI_FREQ ),
					.NEAR_FULL( 'd2 )
				)
		slFif(
					.HCLK(	sysClk ),
					.fifo_areset( sysReset ),
					.fifo_sreset( sysReset ),

					// Write Port
					.fifoWrite( readFifWr ),
					.fifoWrData( readFifWrData ),

					// Read Port
					.fifoRead( readFifRd ),
					.fifoRdData( readFifRdData ),

					// Status bits
					.fifoEmpty ( readFifoEmpty ) ,
					.fifoOneAvail(   ),
					.fifoRdValid(  ),
					.fifoFull( readFifoFull ),
					.fifoNearFull( ),
					.fifoOverRunErr( fifoOverRunErr ),
					.fifoUnderRunErr( fifoUnderRunErr )
				   
				);

assign initiatorRdAddrFull = readFifoFull;
assign startRdAddr	= readFifRdData[READFIF_WIDTH- ID_WIDTH-1: READFIF_WIDTH- ID_WIDTH- ADDR_WIDTH];

// align address to 32 bit boundary if TxSize > 32, align to TxSize otherwise
assign align_addr_32 = (((DATA_WIDTH/8)-1) & ( (INITIATOR_ARSIZE > 2) ? (curRdAddr[5:0] & 6'h3c) : (curRdAddr[5:0] & ~((1<<INITIATOR_ARSIZE)-1)) ));

// unalignement offset
assign align_addr = (curRdAddr[5:0] & ((1<<INITIATOR_ARSIZE)-1));

// valid bit within a 32 bit word for fixed
assign mask_unalign = 32'hffffffff << (curRdAddr[1:0] << 3);

// 
assign shift_dataMask = (((2**INITIATOR_ARSIZE) -  ((curRdAddr[5:0]) & ((2**INITIATOR_ARSIZE) - 1))) > 4) ? (8*(align_addr-4 + (DATA_WIDTH/8-addr_shift/8))) : 0;

// received data mask (mask out all bits but last 32 received bits
assign mask_rDataMask = ((burstType == 2'b00) && ( INITIATOR_ARSIZE > 2)) ? ((~((1 << addr_shift)-1))) : ~((1 << (8*(curRdAddr[5:0] & (DATA_WIDTH/8-1))))-1);

// expected data mask (mask out all bits but upper 32 valid bits)
assign mask_rDataMask_exp = ((burstType == 2'b00) && (INITIATOR_ARSIZE > 2)) ? (~((1 << addr_shift)-1)  << exp_mask_shift) : ~((1 << (8*(curRdAddr[5:0] & (DATA_WIDTH/8-1))))-1);

// address byte to bits within a word
assign addr_shift = (8*((curRdAddr[5:0]) & (DATA_WIDTH/8-1)));

// amount to shift the exp data mask by if TxSize > 32 bit
assign exp_mask_shift = (((2**INITIATOR_ARSIZE) -  ((curRdAddr[5:0]) & ((2**INITIATOR_ARSIZE) - 1))) > 4) ? ((8*((2**INITIATOR_ARSIZE)-(align_addr & 6'h3c))) - 32) : 0;

assign ReadAddrMaskWrap = (10'h3ff << $clog2((rdBurstLen+1) * (1 << rdASize)));

  assign rd_addr_beat = rdStartAddr[rdASize+:4] & rdBurstLen;
  assign rd_to_boundary_initiator = (rdBurstLen + 1) - rd_addr_beat;

//====================================================================================================
// Initiator Read Data S/M
//===================================================================================================== 
 always @( * )
 begin
 
 	#1;	// wait for inputs to "settle" - issue as "display" stmts 
	rnextState <= rcurrState;

	d_INITIATOR_RREADY	<= INITIATOR_RREADY_Default;
	readFifRd		<= 0;

	initiatorRdStatus	<= 1;

	d_rxLen 	<= rxLen;

	transID		= readFifRdData[READFIF_WIDTH-1: READFIF_WIDTH-ID_WIDTH];
	burstLen	= readFifRdData[READFIF_WIDTH- ID_WIDTH-ADDR_WIDTH-1: READFIF_WIDTH- ID_WIDTH- ADDR_WIDTH -8];
  burstSize = readFifRdData[4:2];
	burstType	= readFifRdData[1:0];

	d_curRdAddr	<= curRdAddr;

	initiatorRdDone	<= 0;

	d_rdCount	<= rdCount;


  

	case( rcurrState )
		rstIDLE: begin
					d_INITIATOR_RREADY <= INITIATOR_RREADY_Default;

					initiatorRdStatus 	<= 1;
					d_rxLen 		<= 0;

					d_curRdAddr <= startRdAddr;
					
					if ( INITIATOR_RVALID & INITIATOR_RREADY & INITIATOR_RLAST )		// only 1 beat
						begin
							d_INITIATOR_RREADY	<= INITIATOR_RREADY_Default;

							transID		= readFifRdData[READFIF_WIDTH-1: READFIF_WIDTH-ID_WIDTH];
							burstLen	= readFifRdData[READFIF_WIDTH- ID_WIDTH-ADDR_WIDTH-1: READFIF_WIDTH- ID_WIDTH- ADDR_WIDTH -8];

							if ( readFifoEmpty )
								begin

									$display( "%d, INITIATOR %d ERROR - Read Data cycle with no Read Address Pending", $time, INITIATOR_NUM );
									initiatorRdStatus 	<= 0;
									#1 $stop;
								end	
								
							if ( transID != INITIATOR_RID )
								begin
								
									$display( "%d, INITIATOR %d ERROR - exp RID= %h, act RID= %h", $time, INITIATOR_NUM, transID, INITIATOR_RID );
									
									initiatorRdStatus 	<= 0;
									#1 $stop;
								end
				
							if ( burstLen != rxLen )
								begin
									$display( "%d, INITIATOR %d ERROR - exp rxLen= %h, act rxLen= %h", $time, INITIATOR_NUM, burstLen, rxLen );

									initiatorRdStatus 	<= 0;

									#1 $stop;
								end		
							
							if ( INITIATOR_RRESP != expRResp )
								begin
									$display( "%d, INITIATOR %d ERROR - expRResp= %h, act RRESP= %h", $time, INITIATOR_NUM, 
													expRResp, INITIATOR_RRESP );
									initiatorRdStatus 	<= 0;

									#1 $stop;
							end		

							if ( ( ( INITIATOR_RDATA & rDataMask & mask_rDataMask )!== ( (rxLen + INITIATOR_NUM + baseValue) & rDataMask & mask_rDataMask_exp ) ) & (expRResp == 0 ) & (burstType != 2'b00)  )
								begin
									$display( "%d, INITIATOR %d ERROR - exp RDATA= %h, act RDATA= %h, mask= %h, curRdAddr= %h", $time, INITIATOR_NUM, 
												(rxLen+ INITIATOR_NUM + baseValue ), INITIATOR_RDATA, rDataMask & mask_rDataMask, curRdAddr );
									initiatorRdStatus 	<= 0;
									#1 $stop;
								end	

							else if ( ( ( ( (INITIATOR_RDATA >> shift_fixed) & rDataMask  ) & mask_rDataMask & (mask_unalign << 8*align_addr_32) )!== ( ((rxLen + INITIATOR_NUM + baseValue) & rDataMask & mask_rDataMask_exp ) >> shift_fixed) ) & (expRResp == 0 ) & (burstType == 2'b00)  )
								begin
									$display( "%d, INITIATOR %d ERROR - exp RDATA= %h, act RDATA= %h, mask= %h, exp_mask= %h, curRdAddr= %h", $time, INITIATOR_NUM, 
												(((rxLen+ INITIATOR_NUM + baseValue ) & rDataMask & mask_rDataMask_exp ) >> shift_fixed), (INITIATOR_RDATA  >> shift_fixed) & rDataMask & mask_rDataMask & (mask_unalign << 8*align_addr_32), rDataMask & mask_rDataMask & (mask_unalign << 8*align_addr_32), rDataMask & mask_rDataMask_exp, curRdAddr );
									initiatorRdStatus 	<= 0;
									#1 $stop;
								end	
								
							initiatorRdDone	<= 1;
							readFifRd		<= 1;				// pop open transaction
							
							d_rdCount	<= rdCount + 1'b1;
	
							rnextState	<= rstIDLE;
						end
					else if ( INITIATOR_RVALID & INITIATOR_RREADY & !INITIATOR_RLAST  )
						begin
							d_INITIATOR_RREADY	<= INITIATOR_RREADY_Default;
	
							d_rxLen <= rxLen + 1'b1;

		if (burstType == 2'b00) begin
			d_curRdAddr <= curRdAddr;
		end
                  else if (burstType == 2'b10) begin
                if (rxLen == (rd_to_boundary_initiator-1)) begin
                d_curRdAddr <= { curRdAddr[ADDR_WIDTH-1:10], (curRdAddr[9:0] & ReadAddrMaskWrap)};
                end else begin
                d_curRdAddr <= curRdAddr + (1 << burstSize);
                end
              end
		else begin
							d_curRdAddr	<= { curRdAddr[ADDR_WIDTH-1:6], (curRdAddr[5:0] & ReadAddrMask) }  + (1 << burstSize);		// aligned address 						
						end
							
							if ( readFifoEmpty )
								begin
								
									$display( "%d, INITIATOR %d ERROR - Read Data cycle with no Read Address Pending", $time, INITIATOR_NUM );
									initiatorRdStatus 	<= 0;
									#1 $stop;

								end	
								
							if ( transID != INITIATOR_RID )
								begin

									$display( "%d, INITIATOR %d ERROR - exp RID= %h, act RID= %h", $time, INITIATOR_NUM, transID, INITIATOR_RID );
									initiatorRdStatus 	<= 0;
									#1 $stop;
								end
								
							if ( INITIATOR_RRESP != expRResp )
								begin
									$display( "%d, INITIATOR %d ERROR - expRResp= %h, act RRESP= %h", $time, INITIATOR_NUM, 
													expRResp, INITIATOR_RRESP );
									initiatorRdStatus 	<= 0;

									#1 $stop;
							end		

							if ( ( ( INITIATOR_RDATA & rDataMask & mask_rDataMask )!== ( ( rxLen + INITIATOR_NUM + baseValue) & rDataMask & mask_rDataMask_exp ) ) & (expRResp == 0 ) & (burstType != 2'b00)  )

								begin
									$display( "%d, INITIATOR %d ERROR - exp RDATA= %h, act RDATA= %h, mask= %h", $time, INITIATOR_NUM, 
												( rxLen + INITIATOR_NUM + baseValue ), INITIATOR_RDATA, rDataMask & mask_rDataMask );
                  $display( "\t\t\trxLen: %h, d_rxLen: %h, INITIATOR_NUM: %h, INITIATOR_ARLEN: %h, burstLen: %h, rdBurstLen: %h", 
                        rxLen, d_rxLen, INITIATOR_NUM, INITIATOR_ARLEN, burstLen, rdBurstLen );
									initiatorRdStatus 	<= 0;
									#1 $stop;		
								end
							else if ( ( ( ( (INITIATOR_RDATA >> shift_fixed) & rDataMask )  & mask_rDataMask & (mask_unalign << 8*align_addr_32) )!== (( (burstLen + INITIATOR_NUM + baseValue) & rDataMask & mask_rDataMask_exp )  >> shift_fixed)) & (expRResp == 0 ) & (burstType == 2'b00)  )
								begin
									$display( "%d, INITIATOR %d ERROR - exp RDATA= %h, act RDATA= %h", $time, INITIATOR_NUM, 
												( (burstLen+ INITIATOR_NUM + baseValue ) & rDataMask & mask_rDataMask_exp) >> shift_fixed, ( ((INITIATOR_RDATA >> shift_fixed) & rDataMask) ) & mask_rDataMask & (mask_unalign << 8*align_addr_32) );
									initiatorRdStatus 	<= 0;
									#1 $stop;		
								end
								
							rnextState 		<= rstDATA;
							
						end
					else if ( INITIATOR_RVALID & !INITIATOR_RREADY  )
						begin
							d_INITIATOR_RREADY	<= INITIATOR_RREADY_Default;

							if ( readFifoEmpty )
								begin
								
									$display( "%d, INITIATOR %d ERROR - Read Data cycle with no Read Address Pending", $time, INITIATOR_NUM );
									initiatorRdStatus 	<= 0;
									#1 $stop;
								end	
								
							if ( transID != INITIATOR_RID )
								begin
									$display( "%d, INITIATOR %d ERROR - exp RID= %h, act RID= %h", $time, INITIATOR_NUM, transID, INITIATOR_RID );
									initiatorRdStatus 	<= 0;
									#1 $stop;
								
								end

							rnextState 		<= rstDATA;
							
						end
				end
		rstDATA : begin
					d_INITIATOR_RREADY <= 1'b1;

					#1;
					
					if ( INITIATOR_RVALID & INITIATOR_RREADY & INITIATOR_RLAST )		// only 1 beat
						begin
							d_INITIATOR_RREADY	<= INITIATOR_RREADY_Default;
							
							transID		= readFifRdData[READFIF_WIDTH-1: READFIF_WIDTH-ID_WIDTH];
							burstLen	= readFifRdData[READFIF_WIDTH- ID_WIDTH-ADDR_WIDTH-1: READFIF_WIDTH- ID_WIDTH- ADDR_WIDTH -8];
							
							if ( transID != INITIATOR_RID )
								begin
									$display( "%d, INITIATOR %d ERROR - exp RID= %h, act RID= %h", $time, INITIATOR_NUM, transID, INITIATOR_RID );
									initiatorRdStatus 	<= 0;
									#1 $stop;
									
								end
				
							if ( burstLen != rxLen )
								begin
									$display( "%d, INITIATOR %d ERROR - exp rxLen= %h, act rxLen= %h", $time, INITIATOR_NUM, burstLen, rxLen );
									initiatorRdStatus 	<= 0;
									#1 $stop;
									
								end	
								
							if ( INITIATOR_RRESP != expRResp )
								begin
									$display( "%d, INITIATOR %d ERROR - expRResp= %h, act RRESP= %h", $time, INITIATOR_NUM, 
													expRResp, INITIATOR_RRESP );
									initiatorRdStatus 	<= 0;

									#1 $stop;
							end		
							
							if ( ( ( INITIATOR_RDATA & rDataMask & mask_rDataMask )!== ( (rxLen + INITIATOR_NUM + baseValue) & rDataMask & mask_rDataMask_exp ) ) & (expRResp == 0 ) & (burstType != 2'b00) )
								begin
									$display( "%d, INITIATOR %d ERROR - exp RDATA= %h, act RDATA= %h, rDataMask & mask_rDataMask: %h", $time, INITIATOR_NUM, 
												(rxLen+ INITIATOR_NUM + baseValue ), INITIATOR_RDATA, rDataMask & mask_rDataMask );
                  $display( "\t\t\trxLen: %h, INITIATOR_NUM: %h, INITIATOR_ARLEN: %h, DATA+MASK: %h, curRdAddr:%h", 
                        rxLen, INITIATOR_NUM, INITIATOR_ARLEN,(INITIATOR_RDATA & rDataMask & mask_rDataMask), curRdAddr );
									initiatorRdStatus 	<= 0;
											#1 $stop;
								end	
							else if ( ( ( ( (INITIATOR_RDATA >> shift_fixed) & rDataMask )  & mask_rDataMask & (mask_unalign << 8*align_addr_32) )!== (( (rxLen + INITIATOR_NUM + baseValue) & rDataMask & mask_rDataMask_exp ) >> shift_fixed )) & (expRResp == 0 ) &  (burstType == 2'b00))
								begin
									$display( "%d, INITIATOR %d ERROR - exp RDATA= %h, act RDATA= %h, rDataMask & mask_rDataMask: %h", $time, INITIATOR_NUM, 
												((rxLen+ INITIATOR_NUM + baseValue ) >> shift_fixed), (INITIATOR_RDATA  >> shift_fixed), rDataMask & mask_rDataMask & (mask_unalign << 8*align_addr_32) );
                  $display( "\t\t\trxLen: %h, INITIATOR_NUM: %h, INITIATOR_ARLEN: %h, DATA+MASK: %h, curRdAddr:%h", 
                        rxLen, INITIATOR_NUM, INITIATOR_ARLEN,(INITIATOR_RDATA & rDataMask & mask_rDataMask & (mask_unalign << 8*align_addr_32)), curRdAddr );
									initiatorRdStatus 	<= 0;
											#1 $stop;
								end	

							d_rxLen 		<= 0;				// initialise for next burst

							d_curRdAddr	<= startRdAddr;
							
							readFifRd		<= 1;				// pop open transaction
							initiatorRdDone	<= 1;
							d_rdCount		<= rdCount + 1'b1;

							rnextState	<= rstIDLE;
						end
					else if ( INITIATOR_RVALID & INITIATOR_RREADY & !INITIATOR_RLAST  )
						begin
							d_INITIATOR_RREADY	<= INITIATOR_RREADY_Default;
							d_rxLen <= rxLen + 1'b1;
		if (burstType == 2'b00) begin
			d_curRdAddr <= curRdAddr;
		end
                      else if (burstType == 2'b10) begin
                if (rxLen == (rd_to_boundary_initiator-1)) begin
                d_curRdAddr <= { curRdAddr[ADDR_WIDTH-1:10], (curRdAddr[9:0] & ReadAddrMaskWrap)};
                end else begin
                d_curRdAddr <= curRdAddr + (1 << burstSize);
                end
              end
		else begin
              d_curRdAddr	<= { curRdAddr[ADDR_WIDTH-1:6], (curRdAddr[5:0] & ReadAddrMask) }  + (1 << burstSize);		// aligned address
      end

							if ( transID != INITIATOR_RID )
								begin
									$display( "%d, INITIATOR %d ERROR - exp RID= %h, act RID= %h", $time, INITIATOR_NUM, transID, INITIATOR_RID );
									initiatorRdStatus 	<= 0;
									#1 $stop;
									
								end
								
							if ( INITIATOR_RRESP != expRResp )
								begin
									$display( "%d, INITIATOR %d ERROR - expRResp= %h, act RRESP= %h", $time, INITIATOR_NUM, 
													expRResp, INITIATOR_RRESP );
									initiatorRdStatus 	<= 0;

									#1 $stop;
							end

							if ( ( ( INITIATOR_RDATA & rDataMask & mask_rDataMask )!== ( (rxLen /*INITIATOR_ARLEN*/ + INITIATOR_NUM + baseValue) & rDataMask & mask_rDataMask_exp ) ) & (expRResp == 0 ) & (burstType != 2'b00)  )
								begin
									$display( "%d, INITIATOR %d ERROR - exp RDATA= %h, act RDATA= %h", $time, INITIATOR_NUM, 
												(rxLen+ INITIATOR_NUM + baseValue ) & rDataMask & mask_rDataMask_exp, INITIATOR_RDATA & rDataMask & mask_rDataMask );
									initiatorRdStatus 	<= 0;
									#1 $stop;		
								end
							else if ( ( ( ( (INITIATOR_RDATA  >> shift_fixed) & rDataMask ) & mask_rDataMask & (mask_unalign << 8*align_addr_32) )!== ( ( (burstLen + INITIATOR_NUM + baseValue) & rDataMask & mask_rDataMask_exp ) >> shift_fixed ) ) & (expRResp == 0 ) & (burstType == 2'b00)  )
								begin
									$display( "%d, INITIATOR %d ERROR - exp RDATA= %h, act RDATA= %h", $time, INITIATOR_NUM, 
												((burstLen+ INITIATOR_NUM + baseValue ) & rDataMask & mask_rDataMask_exp ) >> shift_fixed, (INITIATOR_RDATA  >> shift_fixed) & rDataMask & mask_rDataMask & (mask_unalign << 8*align_addr_32) );
									initiatorRdStatus 	<= 0;
									#1 $stop;		
								end

							rnextState 		<= rstDATA;
							
						end
				end
	endcase
end

assign ReadAddrMask = 6'h3f << (readFifRdData[4:2]);

 always @(posedge sysClk or negedge sysReset )
 begin
	if (!sysReset)
		begin
			rcurrState 		<= rstIDLE;
			INITIATOR_RREADY	<= 0;
			rxLen 			<= 0;
			rdCount			<= 0;
			curRdAddr		<= 0;
		end
	else
		begin
			rcurrState 		<= rnextState;
			INITIATOR_RREADY	<= d_INITIATOR_RREADY;
			rxLen			<= d_rxLen;
			rdCount			<= d_rdCount;
			curRdAddr		<= d_curRdAddr;
		end
end


//====================================================================================================
// Local Declarationes for Initiator Read Address 
//====================================================================================================
reg [ID_WIDTH-1:0]        	d_INITIATOR_ARID;
reg [ADDR_WIDTH-1:0]      	d_INITIATOR_ARADDR;
reg [7:0]                 	d_INITIATOR_ARLEN;
reg [2:0]                 	d_INITIATOR_ARSIZE;
reg [2:0]                 	max_ARSIZE;
reg [1:0]                 	d_INITIATOR_ARBURST;
reg [1:0]                 	d_INITIATOR_ARLOCK;
reg [3:0]                 	d_INITIATOR_ARCACHE;
reg [2:0]                 	d_INITIATOR_ARPROT;
reg [3:0]					d_INITIATOR_ARREGION;
reg [3:0]                 	d_INITIATOR_ARQOS;		// not used
reg [USER_WIDTH-1:0]      	d_INITIATOR_ARUSER;
reg                       	d_INITIATOR_ARVALID;

reg [2:0]	arcurrState, arnextState;

localparam	[2:0]		arstIDLE = 3'h0,	arstDATA = 3'h1;

//====================================================================================================
// Initiator Read Address S/M
//===================================================================================================== 
 always @( * )
 begin
 
	arnextState <= arcurrState;

	d_INITIATOR_ARID		<= INITIATOR_ARID;
	d_INITIATOR_ARADDR		<= INITIATOR_ARADDR;
	d_INITIATOR_ARLEN		<= INITIATOR_ARLEN;
	d_INITIATOR_ARSIZE 	<= INITIATOR_ARSIZE;
	d_INITIATOR_ARBURST	<= INITIATOR_ARBURST;
	d_INITIATOR_ARLOCK		<= INITIATOR_ARLOCK;
	d_INITIATOR_ARCACHE	<= INITIATOR_ARCACHE;
	d_INITIATOR_ARPROT		<= INITIATOR_ARPROT;
	d_INITIATOR_ARREGION	<= INITIATOR_ARREGION;
	d_INITIATOR_ARQOS		<= INITIATOR_ARQOS;		// not used
	d_INITIATOR_ARUSER		<= INITIATOR_ARUSER;

	d_INITIATOR_ARVALID	<= INITIATOR_ARVALID;	
	
	initiatorRAddrIdle			<= 0;
	readFifWrData <= { INITIATOR_ARID, INITIATOR_ARADDR, INITIATOR_ARLEN, INITIATOR_ARSIZE, INITIATOR_ARBURST };

	readFifWr	<= 0;	

	d_arCount			<= arCount;
	initiatorRdAddrDone	<= 0;
	
	case( arcurrState )
		arstIDLE: begin
					initiatorRAddrIdle	<= 1;
			
					if ( rdStart & !readFifoFull )		// start initiator read address transaction
						begin
							d_INITIATOR_ARVALID	<= 1'b1;

							d_INITIATOR_ARID		<= rdAID;
							d_INITIATOR_ARADDR		<= rdStartAddr;				// make up data to be easy read in simulation
							d_INITIATOR_ARLEN 		<= rdBurstLen;

							
							max_ARSIZE 	<= 	(DATA_WIDTH == 'd16)  ? 3'h1 :
											(DATA_WIDTH == 'd32 ) ? 3'h2 :
											(DATA_WIDTH == 'd64 ) ? 3'h3 :
											(DATA_WIDTH == 'd128) ? 3'h4 :
											(DATA_WIDTH == 'd256) ? 3'h5 :
											(DATA_WIDTH == 'd512) ? 3'h6 :
														 3'bxxx;		// not supported;
														 
							if (rdASize > max_ARSIZE)
								begin
									d_INITIATOR_ARSIZE 	<= max_ARSIZE;
									$display( "%d, INITIATOR %d ERROR - requested transfer size = %h exceed data width limitation and is reset to %h", 
														$time, INITIATOR_NUM, rdASize, max_ARSIZE );
									#1 $stop;
								end
							else
								begin
									d_INITIATOR_ARSIZE 	<= rdASize;
								end
														
							d_INITIATOR_ARBURST	<= BurstType;	
							d_INITIATOR_ARLOCK		<= 0;
							d_INITIATOR_ARCACHE	<= 0;
							d_INITIATOR_ARPROT		<= 0;
							d_INITIATOR_ARREGION	<= 0;
							d_INITIATOR_ARQOS		<= 0;		// not used
							d_INITIATOR_ARUSER		<= 1;

							arnextState 	<= arstDATA;
						end
				end
		arstDATA : begin
					d_INITIATOR_ARVALID	<= 1'b1;
					readFifWrData <= { INITIATOR_ARID, INITIATOR_ARADDR, INITIATOR_ARLEN, INITIATOR_ARSIZE, INITIATOR_ARBURST };

					if ( INITIATOR_ARVALID & INITIATOR_ARREADY )		
						begin
						
							readFifWr			<= 1;		// push fifo 
							d_arCount			<= arCount + 1'b1;
							initiatorRdAddrDone	<= 1;
							
							if ( rdStart & !readFifoFull)				// if another burst request and space
								begin
									d_INITIATOR_ARVALID	<= 1'b1;
									
									d_INITIATOR_ARID		<= rdAID;
									d_INITIATOR_ARADDR		<= rdStartAddr;				// make up data to be easy read in simulation
									d_INITIATOR_ARLEN 		<= rdBurstLen;

									arnextState <= arstDATA;
								end
							else
								begin
									d_INITIATOR_ARVALID	<= 1'b0;
							
									arnextState <= arstIDLE;
								end
						end
					else			// not ready
						begin
									
						end
				end
	endcase
end


 always @(posedge sysClk or negedge sysReset )
 begin
 
	if (!sysReset)
		begin
			INITIATOR_ARVALID	<= 1'b0;

			INITIATOR_ARID		<= 0;
			INITIATOR_ARADDR	<= 0;				// make up data to be easy read in simulation
			INITIATOR_ARLEN 	<= 0;

			INITIATOR_ARSIZE 	<= 0;
			INITIATOR_ARBURST	<= 0;
			INITIATOR_ARLOCK	<= 0;
			INITIATOR_ARCACHE	<= 0;
			INITIATOR_ARPROT	<= 0;
			INITIATOR_ARREGION	<= 0;
			INITIATOR_ARQOS	<= 0;		// not used
			INITIATOR_ARUSER	<= 1;

			arCount			<= 0;

			arcurrState	<= arstIDLE;
		end
	else
		begin
			INITIATOR_ARVALID	<= d_INITIATOR_ARVALID;

			INITIATOR_ARID		<= d_INITIATOR_ARID;
			INITIATOR_ARADDR	<= d_INITIATOR_ARADDR;				// make up data to be easy read in simulation
			INITIATOR_ARLEN 	<= d_INITIATOR_ARLEN;

			INITIATOR_ARSIZE 	<= d_INITIATOR_ARSIZE;
			INITIATOR_ARBURST	<= d_INITIATOR_ARBURST;
			INITIATOR_ARLOCK	<= d_INITIATOR_ARLOCK;
			INITIATOR_ARCACHE	<= d_INITIATOR_ARCACHE;
			INITIATOR_ARPROT	<= d_INITIATOR_ARPROT;
			INITIATOR_ARREGION	<= d_INITIATOR_ARREGION;
			INITIATOR_ARQOS	<= d_INITIATOR_ARQOS;		// not used
			INITIATOR_ARUSER	<= d_INITIATOR_ARUSER;

			arCount			<= d_arCount;

			arcurrState	<= arnextState;
		end
end

// Different paths for simulation and synthesis
// `ifdef SIM_MODE
	// `include "../component/Actel/DirectCore/CoreAXI4Interconnect_w/2.1.3/sim/AXI4Models/Axi4InitiatorGen_Wr.v"
	// `include "../component/Actel/DirectCore/CoreAXI4Interconnect_w/2.1.3/sim/AXI4Models/Axi4InitiatorGen_WrResp.v"
// `else
	//`include "../../sim/AXI4Models/Axi4InitiatorGen_Wr.v"
	//`include "../../sim/AXI4Models/Axi4InitiatorGen_WrResp.v"
// `endif
// ********************************************************************
//  Microsemi Corporation Proprietary and Confidential
//  Copyright 2017 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: This module provides a AXI4 Initiator Write test source.
//              It initialiates a Initiator write on Write Address channel.
//
// Revision Information:
// Date     Description:
// Feb17    Revision 1.0
//
// Notes:
// best viewed with tabstops set to "4"
// ********************************************************************
`timescale 1ns / 1ns

//================================================================================================
// Local Parameters
//================================================================================================
 
localparam	WRFIF_WIDTH = ( ID_WIDTH + ADDR_WIDTH + 8 + 3 + 2 );			// ID, Addr, LEN and SIZE, and Burst 
localparam	RESPFIF_WIDTH = ( ID_WIDTH + 2 );			// ID, Resp

  wire [4:0]   wr_addr_beat;
  wire [4:0]   wr_to_boundary_initiator;
   wire      [9:0]  WriteAddrMaskWrap;

wire [(DATA_WIDTH/8)-1:0] mask_strb;

wire [5:0] 			WriteAddrMask;
wire						wrfifoOverRunErr, wrfifoUnderRunErr;

reg		[WRFIF_WIDTH-1:0]			wrFifWrData;
wire	[WRFIF_WIDTH-1:0]		wrFifRdData;
reg		[WRFIF_WIDTH-1:0]			wrFifRdDataHold;

reg							wrFifWr, wrFifRd;
wire						wrFifoFull, wrFifoEmpty, wrFifoOneAvail;

reg							respFifWr, respFifRd;
wire						respFifoFull, respFifoEmpty;

wire	[RESPFIF_WIDTH-1:0]	respFifRdData;
wire	[RESPFIF_WIDTH-1:0]	respFifWrData;	

reg		[ID_WIDTH-1:0]		respWID, d_respWID;
reg		[ADDR_WIDTH-1:0]	d_initiatorWrAddr, initiatorWrAddr;			// used to track address being sent out.

 //===========================================================================================
 // FIFO to hold open transactions - pushed on Address Read cycle and popped on write data
 // cycle.
 //===========================================================================================
 caxi4interconnect_FifoDualPort #(	.FIFO_AWIDTH( OPENTRANS_MAX ),
					.FIFO_WIDTH( WRFIF_WIDTH ),
					.HI_FREQ( HI_FREQ ),
					.NEAR_FULL ( 'd2 )
				)
		wrFif(
					.HCLK(	sysClk ),
					.fifo_areset( sysReset ),
					.fifo_sreset( sysReset ),

					// Write Port
					.fifoWrite( wrFifWr ),
					.fifoWrData( wrFifWrData ),

					// Read Port
					.fifoRead( wrFifRd ),
					.fifoRdData( wrFifRdData ),

					// Status bits
					.fifoEmpty ( wrFifoEmpty ) ,
					.fifoOneAvail( wrFifoOneAvail ),
					.fifoRdValid(	),
					.fifoFull( wrFifoFull ),
					.fifoNearFull(	),
					.fifoOverRunErr( wrfifoOverRunErr ),
					.fifoUnderRunErr( wrfifoUnderRunErr )
					 
				);

assign initiatorWrAddrFull = wrFifoFull;


//===========================================================================================
// Storage latch for data cycle to be processed
//===========================================================================================
always @(posedge sysClk or	negedge sysReset )
begin
	
	if ( !sysReset )
		begin
			wrFifRdDataHold	<= 0;
		end
	else if ( wrFifRd )
		begin
			wrFifRdDataHold	<= wrFifRdData;
		end
end


//===========================================================================================
 // FIFO to hold open transactions - pushed on Write Data cycle and popped on write response
 // cycle.
 //===========================================================================================				
	caxi4interconnect_FifoDualPort #(	.FIFO_AWIDTH( OPENTRANS_MAX ),
					.FIFO_WIDTH( RESPFIF_WIDTH ),
					.HI_FREQ( HI_FREQ ),
					.NEAR_FULL ( 'd2 )
				)
		rspFif(
					.HCLK(	sysClk ),
					.fifo_areset( sysReset ),
					.fifo_sreset( sysReset ),

					// Write Port
					.fifoWrite( respFifWr ),
					.fifoWrData( respFifWrData ),

					// Read Port
					.fifoRead( respFifRd ),
					.fifoRdData( respFifRdData ),

					// Status bits
					.fifoEmpty ( respFifoEmpty ) ,
					.fifoOneAvail(		 ),
					.fifoRdValid(	),
					.fifoFull( respFifoFull ),
					.fifoNearFull(	),
					.fifoOverRunErr( respFifoOverRunErr ),
					.fifoUnderRunErr( respFifoUnderRunErr )
					 
				);

				
assign 	respFifWrData = { respWID, expWResp };


//====================================================================================================
// Local Declarationes for Initiator Write Address 
//====================================================================================================

localparam	[2:0]		wstIDLE = 3'h0,	wstDATA = 3'h1;

reg [(DATA_WIDTH/8)-1:0]	 	d_INITIATOR_WSTRB;
reg 												d_INITIATOR_WLAST, d_INITIATOR_WVALID;
reg [USER_WIDTH-1:0]				d_INITIATOR_WUSER;

reg [2:0]				wcurrState, wnextState;

reg	[DATA_WIDTH-1:0]	d_txLen, txLen;

reg [15:0]				txCount, d_txCount;
reg [15:0]				awCount, d_awCount;

wire [7:0]				curTxLen, curTxLenHold;
wire [ID_WIDTH-1:0]		curWID, curWIDHold;


//=============================================================================================
// Display messages only in Simulation - not synthesis
//=============================================================================================
`ifdef SIM_MODE

	//=============================================================================================
	// Display messages for Write Address Channel
	//=============================================================================================
	always @( posedge sysClk )
		begin
			#1;
	
			if ( INITIATOR_AWVALID )
				begin
					#1 $display( "%d, INITIATOR %d - Starting Write Address Transaction %d, AWADDR= %h, AWBURST= %h, AWSIZE= %h, WID= %h, AWLEN= %d", 
											$time, INITIATOR_NUM, awCount, INITIATOR_AWADDR, INITIATOR_AWBURST, INITIATOR_AWSIZE, INITIATOR_AWID, INITIATOR_AWLEN );

					if ( INITIATOR_AWREADY )		// single beat
						begin
							#1 $display( "%d, INITIATOR %d - Ending Write Address Transaction %d, WID= %h, AWLEN= %d", 
											$time, INITIATOR_NUM, awCount, INITIATOR_AWID, INITIATOR_AWLEN );
						end
					else
						begin
							@( posedge INITIATOR_AWREADY )
								#1 $display( "%d, INITIATOR %d - Ending Write Address Transaction %d, WID= %h, AWLEN= %d", 
											$time, INITIATOR_NUM, awCount, INITIATOR_AWID, INITIATOR_AWLEN );
						end
				end
		end	


	//=============================================================================================
	// Display messages for Write Data Channel
	//=============================================================================================
	always @( negedge sysClk )
		begin
			#1;
	
			if ( INITIATOR_WVALID )
				begin
					#1 $display( "%d, INITIATOR %d - Starting Write Data Transaction %d, WADDR= %h (%d), WID= %h, TXLEN= %d, WSTRB= %h", 
										$time, INITIATOR_NUM, txCount, initiatorWrAddr, initiatorWrAddr, curWIDHold, curTxLenHold, INITIATOR_WSTRB );

					if ( INITIATOR_WLAST &	INITIATOR_WVALID & INITIATOR_WREADY )		// single beat
						begin
							#1 $display( "%d, INITIATOR %d - Ending Write Data Transaction %d, WID= %h, TXLEN= %d", 
										$time, INITIATOR_NUM, txCount, curWIDHold, txLen );
						end
					else
						begin
							@( posedge ( INITIATOR_WLAST &	INITIATOR_WVALID & INITIATOR_WREADY )	)
								#1 $display( "%d, INITIATOR %d - Ending Write Data Transaction %d, WID= %h, TXLEN= %d", 
										$time, INITIATOR_NUM, txCount, curWIDHold, txLen );
						end
				end
		end

`ifdef VERBOSE
	//=============================================================================================
	// Display Write Data
	//=============================================================================================
	always @( negedge sysClk )
		begin
			#1;

			if ( INITIATOR_WVALID & INITIATOR_WREADY )
				begin
					#1 $display( "%t, INITIATOR %d - ADDR= %h (%d), WDATA= %d, WSTRB= %h", 
										$time, INITIATOR_NUM, initiatorWrAddr, initiatorWrAddr, INITIATOR_WDATA, INITIATOR_WSTRB );
				end
		end		
`endif

`endif


assign	curTxLen 			= wrFifRdData[12:5];										// pick out txLen from FIFO data
assign	curTxLenHold	= wrFifRdDataHold[12:5];								// pick out txLen from Hold data

assign	curWID				= wrFifRdData[WRFIF_WIDTH-1:WRFIF_WIDTH-ID_WIDTH];				// pick out WID from FIFO data
assign	curWIDHold		= wrFifRdDataHold[WRFIF_WIDTH-1:WRFIF_WIDTH-ID_WIDTH];		// pick out WID from Hold data

wire	[ADDR_WIDTH-1:0]	wDStartAddr;
wire	[2:0]							wD_AWSIZE, repMultip;
reg		[2:0]							wD_AWSIZE_next, wD_AWSIZE_reg;
wire	[1:0]							wD_AWBURST;
 
assign repMultip		= (1 << wD_AWSIZE);
assign wDStartAddr	= wrFifRdData[WRFIF_WIDTH-ID_WIDTH-1:WRFIF_WIDTH-ID_WIDTH-ADDR_WIDTH]; 
assign wD_AWSIZE		= wrFifRdData[4:2];
assign wD_AWBURST	 	= wrFifRdData[1:0];

assign WriteAddrMask = (6'h3f << wD_AWSIZE_reg);
assign WriteAddrMaskWrap = (10'h3ff << $clog2((wrBurstLen+1) * ( 1 << wrASize )));

  assign wr_addr_beat = wrStartAddr[wrASize+:4] & wrBurstLen;
  assign wr_to_boundary_initiator = (wrBurstLen + 1) - wr_addr_beat;

//====================================================================================================
// Initiator Data S/M
//===================================================================================================== 
 always @( * )
 begin
 
	wnextState 		<= wcurrState;
	initiatorWrDone	<= 0;
	wrFifRd			<= 0;
	respFifWr		<= 0;

	d_INITIATOR_WUSER	<= INITIATOR_WUSER;

	d_INITIATOR_WLAST	<= 0;
	d_INITIATOR_WVALID	<= 0;

	d_txCount	<= txCount;

	d_respWID	<= respWID;

	d_txLen 	<= txLen;
	d_initiatorWrAddr <= initiatorWrAddr;
	wD_AWSIZE_next <= wD_AWSIZE_reg;

	case( wcurrState )
		wstIDLE: begin
					d_respWID	<= 0;
					d_respWID	<= wrFifRdData[WRFIF_WIDTH-1: WRFIF_WIDTH- ID_WIDTH];

					if ( wrFifoEmpty )
						begin
							d_txLen 		<= 0;
							d_INITIATOR_WUSER 	<= 0;
						end
					else if ( ~wrFifoEmpty )
						begin
							d_INITIATOR_WVALID	<= 1;
							d_INITIATOR_WLAST	<= ( curTxLen == 0 );		// only 1-beat

							d_initiatorWrAddr <= wDStartAddr;
							wD_AWSIZE_next <= wD_AWSIZE;

							wAddrMask <= (wDStartAddr[5:0] & ((DATA_WIDTH/8)-1)) >> wD_AWSIZE;
							d_INITIATOR_WUSER	<= 0;

							wrFifRd			<= 1;						// pop fifo - use hold for current cycle.
							
							wnextState	<= wstDATA;
						end
				end
		wstDATA : begin
					
					d_respWID	<= wrFifRdDataHold[WRFIF_WIDTH-1: WRFIF_WIDTH- ID_WIDTH];
				
					d_INITIATOR_WVALID	<= 1;
					d_INITIATOR_WLAST	<= INITIATOR_WLAST;		// only if set until VALID/READY Seen
					wAddrMask <= ((initiatorWrAddr+wD_AWSIZE*(txLen+1)) & ((DATA_WIDTH/8)-1)) >> wD_AWSIZE;

					if ( INITIATOR_WREADY & INITIATOR_WVALID & INITIATOR_WLAST)
						begin

							initiatorWrDone	<= 1;
							respFifWr		<= 1;

							d_INITIATOR_WUSER	<= 0;

							d_txLen		<= 0;
							d_txCount 	<= txLen + 1;

							if (~wrFifoEmpty)		// another data transaction available
								begin
									d_INITIATOR_WLAST	<= ( curTxLen == 0 );		
									d_INITIATOR_WVALID	<= 1;

									d_initiatorWrAddr <= wDStartAddr;

									d_respWID			<= wrFifRdData[WRFIF_WIDTH-1: WRFIF_WIDTH- ID_WIDTH];
									wrFifRd				<= 1;			// pop entry - next entry is in hold
									wnextState		<= wstDATA;
								end
							else					// no other entries to handle
								begin
									d_INITIATOR_WLAST	<= 0;		
									d_INITIATOR_WVALID	<= 0;
									d_respWID		<= wrFifRdDataHold[WRFIF_WIDTH-1: WRFIF_WIDTH- ID_WIDTH];
									wrFifRd			<= 0;

									wnextState	<= wstIDLE;
								end
						end
					else if ( INITIATOR_WREADY & INITIATOR_WVALID & ~INITIATOR_WLAST)
						begin
							d_txCount 	<= txLen + 1;
							d_txLen			<= txLen + 1;
							if (INITIATOR_AWBURST == 2'b00) begin
							 	d_initiatorWrAddr <= initiatorWrAddr;
							end
              else if (INITIATOR_AWBURST == 2'b10) begin
                if (txLen == (wr_to_boundary_initiator-1)) begin
                d_initiatorWrAddr <= { initiatorWrAddr[ADDR_WIDTH-1:10], (initiatorWrAddr[9:0] & WriteAddrMaskWrap)};
                end else begin
                d_initiatorWrAddr <= initiatorWrAddr + (1 << wD_AWSIZE_reg);
                end
              end
							else begin
								d_initiatorWrAddr <= { initiatorWrAddr[ADDR_WIDTH-1:6], (initiatorWrAddr[5:0] & WriteAddrMask) } + (1 << wD_AWSIZE_reg);
							end

							if ( (curTxLenHold -1'b1) == txLen[7:0] ) 		// last beat
								begin
									d_INITIATOR_WLAST	<= 1;
									wnextState	<= wstDATA;
								end
							else
								begin
									d_INITIATOR_WUSER	<= INITIATOR_WUSER -1'b1;		// rotate
									wnextState	<= wstDATA;
								end
						end
					end
	endcase
end

always @(*)
begin	
		//==============================================================
		// Set WSTRB bits based on alignment - just for startAddress
		//==============================================================
		// The below case statement(DATA_WIDTH) allows the strobes to be applied properly. The size of the bus determines the
		// max transfer size
			case (DATA_WIDTH)
			// The case statement (INITIATOR_AWSIZE) applies a strobe on a 'per-byte' basis. The strobe is set the the correct size, 
			// depending on the transfer size, and is then shifted by the apptoptiate number of bytes.
			'd32 :	case(wD_AWSIZE_next)
							 3'b000 : d_INITIATOR_WSTRB	<= 4'h1 << (d_initiatorWrAddr[1:0]);
							 3'b001 : d_INITIATOR_WSTRB	<= 4'h3 << 2*(d_initiatorWrAddr[1]);
							 3'b010 : d_INITIATOR_WSTRB	<= 4'hF;														 // No shift as size = data width
							endcase
			'd64 :	case(wD_AWSIZE_next)
							 3'b000 : d_INITIATOR_WSTRB	<= 8'h1 << (d_initiatorWrAddr[2:0]);
							 3'b001 : d_INITIATOR_WSTRB	<= 8'h3 << 2*(d_initiatorWrAddr[2:1]);
							 3'b010 : d_INITIATOR_WSTRB	<= 8'hF << 4*(d_initiatorWrAddr[2]);
							 3'b011 : d_INITIATOR_WSTRB	<= 8'hFF;														// No shift as size = data width
							endcase
			'd128 : case(wD_AWSIZE_next)
							 3'b000 : d_INITIATOR_WSTRB	<= 16'h1 << (d_initiatorWrAddr[3:0]);
							 3'b001 : d_INITIATOR_WSTRB	<= 16'h3 << 2*(d_initiatorWrAddr[3:1]);
							 3'b010 : d_INITIATOR_WSTRB	<= 16'hF << 4*(d_initiatorWrAddr[3:2]);
							 3'b011 : d_INITIATOR_WSTRB	<= 16'hFF << 8*(d_initiatorWrAddr[3]);
							 3'b100 : d_INITIATOR_WSTRB	<= 16'hFFFF;													// No shift as size = data width
							endcase
			'd256 : case(wD_AWSIZE_next)
							 3'b000 : d_INITIATOR_WSTRB	<= 32'h1 << (d_initiatorWrAddr[4:0]);
							 3'b001 : d_INITIATOR_WSTRB	<= 32'h3 << 2*(d_initiatorWrAddr[4:1]);
							 3'b010 : d_INITIATOR_WSTRB	<= 32'hF << 4*(d_initiatorWrAddr[4:2]);
							 3'b011 : d_INITIATOR_WSTRB	<= 32'hFF << 8*(d_initiatorWrAddr[4:3]);
							 3'b100 : d_INITIATOR_WSTRB	<= 32'hFFFF << 16*(d_initiatorWrAddr[4]);
							 3'b101 : d_INITIATOR_WSTRB	<= 32'hFFFF_FFFF;										 // No shift as size = data width
							endcase
			'd512 : case(wD_AWSIZE_next)
							 3'b000 : d_INITIATOR_WSTRB	<= 64'h1 << (d_initiatorWrAddr[5:0]);
							 3'b001 : d_INITIATOR_WSTRB	<= 64'h3 << 2*(d_initiatorWrAddr[5:1]);
							 3'b010 : d_INITIATOR_WSTRB	<= 64'hF << 4*(d_initiatorWrAddr[5:2]);
							 3'b011 : d_INITIATOR_WSTRB	<= 64'hFF << 8*(d_initiatorWrAddr[5:3]);
							 3'b100 : d_INITIATOR_WSTRB	<= 64'hFFFF << 16*(d_initiatorWrAddr[5:4]);
							 3'b101 : d_INITIATOR_WSTRB	<= 64'hFFFF_FFFF << 32*(d_initiatorWrAddr[5]);
							 3'b110 : d_INITIATOR_WSTRB	<= 64'hFFFF_FFFF_FFFF_FFFF;					 // No shift as size = data width
							endcase
			endcase

end


always @(posedge sysClk or negedge sysReset )
 begin
 
	if (!sysReset)
		begin
			wcurrState 	<= wstIDLE;

			txLen 		<= 0;
			txCount		<= 0;

			INITIATOR_WVALID	<= 0;
			INITIATOR_WID   	<= 0;
			INITIATOR_WDATA	<= 0;
			INITIATOR_WSTRB	<= 0;
			INITIATOR_WUSER	<= 0;
			INITIATOR_WLAST	<= 0;

			respWID	<= 0;
			initiatorWrAddr	<= 0;

			wD_AWSIZE_reg <= 3'h0;

		end
	else
		begin
			wcurrState	<= wnextState;

			txLen			<= d_txLen;
			txCount 	<= d_txCount;

			wD_AWSIZE_reg <= wD_AWSIZE_next;

			INITIATOR_WVALID	<= d_INITIATOR_WVALID;
			INITIATOR_WDATA	<= d_txLen + INITIATOR_NUM + baseValue;				// have all Initiator use a unique sequence
			INITIATOR_WLAST	<= d_INITIATOR_WLAST;
			INITIATOR_WSTRB	<= d_INITIATOR_WSTRB & mask_strb;
			INITIATOR_WUSER	<= d_INITIATOR_WUSER;

			respWID				<= d_respWID;
			initiatorWrAddr	<= d_initiatorWrAddr;
		end
end

assign mask_strb = ~((1 << (d_initiatorWrAddr[5:0] & ((DATA_WIDTH/8)-1)))-1);

//====================================================================================================
// Local Declarationes for Initiator Write Address 
//====================================================================================================
reg [ID_WIDTH-1:0]					d_INITIATOR_AWID;
reg [ADDR_WIDTH-1:0]				d_INITIATOR_AWADDR;
reg [7:0]								 		d_INITIATOR_AWLEN;
reg [2:0]								 		d_INITIATOR_AWSIZE;
reg [2:0]								 		max_AWSIZE;
reg [1:0]								 		d_INITIATOR_AWBURST;
reg [1:0]								 		d_INITIATOR_AWLOCK;
reg [3:0]								 		d_INITIATOR_AWCACHE;
reg [2:0]									 	d_INITIATOR_AWPROT;
reg [3:0]										d_INITIATOR_AWREGION;
reg [3:0]								 		d_INITIATOR_AWQOS;		// not used
reg [USER_WIDTH-1:0]				d_INITIATOR_AWUSER;
reg												 	d_INITIATOR_AWVALID;

reg [2:0]										awcurrState, awnextState;

localparam	[2:0]	 awstIDLE = 3'h0,	awstDATA = 3'h1;

//=====================================================================================================
// Initiator Write Address S/M
//=====================================================================================================
always @( * )
 begin

	awnextState <= awcurrState;

	d_INITIATOR_AWID			<= INITIATOR_AWID;
	d_INITIATOR_AWADDR		<= INITIATOR_AWADDR;
	d_INITIATOR_AWLEN		<= INITIATOR_AWLEN;
	d_INITIATOR_AWSIZE 	<= INITIATOR_AWSIZE;
	d_INITIATOR_AWBURST	<= INITIATOR_AWBURST;
	d_INITIATOR_AWLOCK		<= INITIATOR_AWLOCK;
	d_INITIATOR_AWCACHE	<= INITIATOR_AWCACHE;
	d_INITIATOR_AWPROT		<= INITIATOR_AWPROT;
	d_INITIATOR_AWREGION	<= INITIATOR_AWREGION;
	d_INITIATOR_AWQOS		<= INITIATOR_AWQOS;		// not used
	d_INITIATOR_AWUSER		<= INITIATOR_AWUSER;
	d_INITIATOR_AWVALID	<= INITIATOR_AWVALID;	

	initiatorWAddrIdle	<= 0;
	wrFifWr				<= 0;

	initiatorWrAddrDone	<= 0;
	if (wrASize > INITIATOR_ASIZE_DEFAULT)
		begin
			max_AWSIZE <= INITIATOR_ASIZE_DEFAULT;
			$display( "%d, INITIATOR %d ERROR - requested transfer size exceed data width limitation and is reset to %b", $time, INITIATOR_NUM, INITIATOR_ASIZE_DEFAULT );
		end
	else
		begin
			max_AWSIZE <= wrASize;
		end

	wrFifWrData <= { wrAID, wrStartAddr, wrBurstLen, max_AWSIZE, BurstType };

	d_awCount	<= awCount;

	case( awcurrState )
		awstIDLE: begin
					initiatorWAddrIdle			<= 1;

					if ( wrStart & !wrFifoFull )						// start write address transaction
						begin
							d_INITIATOR_AWVALID	<= 1'b1;

							d_INITIATOR_AWID			<= wrAID;
							d_INITIATOR_AWADDR		<= wrStartAddr;			// make up data to be easy read in simulation
							d_INITIATOR_AWLEN 		<= wrBurstLen;
							d_INITIATOR_AWSIZE 	<= max_AWSIZE;
							d_INITIATOR_AWBURST	<= BurstType;
							d_INITIATOR_AWLOCK		<= 0;
							d_INITIATOR_AWCACHE	<= 0;
							d_INITIATOR_AWPROT		<= 0;
							d_INITIATOR_AWREGION	<= 0;
							d_INITIATOR_AWQOS		<= 0;		// not used
							d_INITIATOR_AWUSER		<= 1;

							awnextState <= awstDATA;
							
							//========================================================================================
							// Initiate Write Channel early if INITIATOR_WREADY_Default asserted - ie do not wait
							// till Write Address transactioon completed.
							//=========================================================================================
							if ( INITIATOR_WREADY_Default )
								begin
									wrFifWr		<= 1;		// push fifo 
								end
						end
				end
		awstDATA : begin
					d_INITIATOR_AWVALID	<= 1'b1;

					if ( INITIATOR_AWVALID & INITIATOR_AWREADY )
						begin
						
							initiatorWrAddrDone <= 1'b1;
							d_awCount	<= awCount + 1'b1;

							//========================================================================================
							// Initiate Write Channel if INITIATOR_WREADY_Default not asserted - ie start write data
							// after Write Address transactioon completed.
							//=========================================================================================
							if ( ~INITIATOR_WREADY_Default )
								begin
									wrFifWr		<= 1;		// push fifo 
								end

							if ( wrStart & !wrFifoFull)				// if another burst request and space
								begin
									d_INITIATOR_AWVALID	<= 1'b1;
									d_INITIATOR_AWID			<= wrAID;
									d_INITIATOR_AWADDR		<= wrStartAddr;				// make up data to be easy read in simulation
									d_INITIATOR_AWLEN 		<= wrBurstLen;
									d_INITIATOR_AWSIZE 	<= max_AWSIZE;

									awnextState <= awstDATA;

									//========================================================================================
									// Initiate Write Channel early if INITIATOR_WREADY_Default asserted - ie do not wait
									// till Write Address transactioon completed.
									//=========================================================================================
									if ( INITIATOR_WREADY_Default )
										begin
											wrFifWrData <= { wrAID, wrStartAddr, wrBurstLen, max_AWSIZE, BurstType };
											wrFifWr			<= 1;		// push fifo 
										end
								end
							else
								begin
									d_INITIATOR_AWVALID	<= 1'b0;
									awnextState				<= awstIDLE;
								end
						end
					else			// not ready
						begin

						end
				end
	endcase
end


 always @(posedge sysClk or negedge sysReset )
 begin
 
	if (!sysReset)
		begin
			INITIATOR_AWVALID	<= 1'b0;

			INITIATOR_AWID	  	<= 0;
			INITIATOR_AWADDR 	<= 0;				// make up data to be easy read in simulation
			INITIATOR_AWLEN  	<= 0;
			INITIATOR_AWSIZE 	<= 0;
			INITIATOR_AWBURST	<= 0;
			INITIATOR_AWLOCK 	<= 0;
			INITIATOR_AWCACHE	<= 0;
			INITIATOR_AWPROT 	<= 0;
			INITIATOR_AWREGION	<= 0;
			INITIATOR_AWQOS	  <= 0;		// not used
			INITIATOR_AWUSER 	<= 0;

			awCount			<= 0;

			awcurrState	<= awstIDLE;
		end
	else
		begin
			INITIATOR_AWVALID	<= d_INITIATOR_AWVALID;

			INITIATOR_AWID	<= d_INITIATOR_AWID;
			INITIATOR_AWADDR	<= d_INITIATOR_AWADDR;				// make up data to be easy read in simulation
			INITIATOR_AWLEN 	<= d_INITIATOR_AWLEN;
			INITIATOR_AWSIZE 	<= d_INITIATOR_AWSIZE;
			INITIATOR_AWBURST	<= d_INITIATOR_AWBURST;
			INITIATOR_AWLOCK	<= d_INITIATOR_AWLOCK;
			INITIATOR_AWCACHE	<= d_INITIATOR_AWCACHE;
			INITIATOR_AWPROT 	<= d_INITIATOR_AWPROT;
			INITIATOR_AWREGION	<= d_INITIATOR_AWREGION;
			INITIATOR_AWQOS	<= d_INITIATOR_AWQOS;		// not used
			INITIATOR_AWUSER   <= d_INITIATOR_AWUSER;

			awCount		<= d_awCount;
			
			awcurrState	<= awnextState;
		end
end


// ********************************************************************
//  Microsemi Corporation Proprietary and Confidential
//  Copyright 2017 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: This module provides a AXI4 Initiator write response channel.
//
// Revision Information:
// Date     Description:
// Feb17    Revision 1.0
//
// Notes:
// best viewed with tabstops set to "4"
// ********************************************************************
`timescale 1ns / 1ns

//====================================================================================================
// Local Declarationes for Initiator Write Response Channel 
//====================================================================================================

localparam	[2:0]		bstIDLE = 3'h0,	bstDATA = 3'h1;

reg						d_INITIATOR_BREADY, bIdle;

reg [2:0]				bcurrState, bnextState;

reg	[15:0]				respCount, d_respCount;


//=============================================================================================
// Display messages only in Simulation - not synthesis
//=============================================================================================
`ifdef SIM_MODE

	//=============================================================================================
	// Display messages for Write Response Channel
	//=============================================================================================
	always @( posedge sysClk )
		begin
			#1;
	
			if ( INITIATOR_BVALID )
				begin
					#1 $display( "%d, INITIATOR %d - Starting Write Response Transaction %d, BID= %h, BRESP= %h", 
										$time, INITIATOR_NUM, respCount, INITIATOR_BID, INITIATOR_BRESP );

					if ( INITIATOR_BREADY & INITIATOR_BVALID)		// single beat
						begin
							#1 $display( "%d, INITIATOR %d - Ending Write Response Transaction %d, BID= %h, wrStatus= %b", 
										$time, INITIATOR_NUM, respCount, INITIATOR_BID, initiatorWrStatus );
						end
					else
						begin
							@( posedge ( INITIATOR_BREADY & INITIATOR_BVALID) )
								#1 $display( "%d, INITIATOR %d - Ending Write Response Transaction %d, BID= %h, wrStatus= %b", 
										$time, INITIATOR_NUM, respCount, INITIATOR_BID, initiatorWrStatus );
						end
				end
		end

	// Check BResp is as expected
	always @( posedge sysClk )
		begin
			#1;		
			
			if ( INITIATOR_BREADY & INITIATOR_BVALID)		// single beat
				if ( INITIATOR_BRESP != respFifRdData[RESPFIF_WIDTH-ID_WIDTH-1: 0] )
					begin
						$display( "%d, INITIATOR %d ERROR - expWResp= %h, act BRESP= %h", $time, INITIATOR_NUM, 
											respFifRdData[RESPFIF_WIDTH-ID_WIDTH-1: 0], INITIATOR_BRESP );

						#1 $stop;
					end		
		end
		
`endif



//====================================================================================================
// Initiator Write Response S/M
//===================================================================================================== 
 always @( * )
 begin
 
	bnextState <= bcurrState;

	//d_INITIATOR_BREADY	<= INITIATOR_BREADY;	
	d_INITIATOR_BREADY	<= d_INITIATOR_BREADY_default;	
	
	bIdle	 	<= 0;
	respFifRd	<= 0;
	initiatorRespDone  <= 0;
	initiatorWrStatus	<= 0;

	d_respCount <= respCount;		// running counter of number of responses completed
	
	case( bcurrState )
		bstIDLE: begin
					bIdle	<= 1;
			
					d_INITIATOR_BREADY		<= d_INITIATOR_BREADY_default;
			
					if ( INITIATOR_BVALID & INITIATOR_BREADY )	
						begin
							bIdle		<= 0;

							initiatorWrStatus <= 	( 	( INITIATOR_BID ==  respFifRdData[RESPFIF_WIDTH-1: RESPFIF_WIDTH-ID_WIDTH]   	)
												  & ( INITIATOR_BRESP == respFifRdData[RESPFIF_WIDTH-ID_WIDTH-1: 0]   				)
												);
							initiatorRespDone  <= 1;
							respFifRd		<= 1'b1;

							d_respCount <= respCount + 1'b1;
							
						end
					else if ( INITIATOR_BVALID & !INITIATOR_BREADY )		// move to assert ready
						begin
							d_INITIATOR_BREADY	<= 1'b1;
							bnextState 	<= bstDATA;
						end
				end
		bstDATA : begin
					bIdle				<= 0;
					d_INITIATOR_BREADY		<= 1'b1;
			
					if ( INITIATOR_BVALID & INITIATOR_BREADY )	
						begin
							
							initiatorWrStatus <= 	( 	( INITIATOR_BID ==  respFifRdData[RESPFIF_WIDTH-1: RESPFIF_WIDTH-ID_WIDTH]   	)
												  & ( INITIATOR_BRESP == respFifRdData[RESPFIF_WIDTH-ID_WIDTH-1: 0]   				)
												);
												
							initiatorRespDone  <= 1;
							respFifRd		<= 1'b1;

							d_respCount <= respCount + 1'b1;
					
							d_INITIATOR_BREADY	<= d_INITIATOR_BREADY_default;
							
							bnextState 	<= bstIDLE;
						end
					else			// not ready
						begin
									
						end
				end
	endcase
end


 always @(posedge sysClk or negedge sysReset )
 begin
 
	if (!sysReset)
		begin
			INITIATOR_BREADY	<= 1'b0;
			bcurrState		<= bstIDLE;
			respCount		<= 0;

		end
	else
		begin
			INITIATOR_BREADY	<= d_INITIATOR_BREADY;

			bcurrState		<= bnextState;
			
			respCount		<= d_respCount;

		end
end

		
		
 // Axi4InitiatorGen_WrResp.v
		
endmodule // Axi4InitiatorGen.v




