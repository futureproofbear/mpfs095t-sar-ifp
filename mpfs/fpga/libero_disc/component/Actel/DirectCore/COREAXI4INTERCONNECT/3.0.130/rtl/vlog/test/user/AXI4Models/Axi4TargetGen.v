// ********************************************************************
//  Microsemi Corporation Proprietary and Confidential
//  Copyright 2017 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: This module provides a AXI4 Target test source.
//
// Revision Information:
// Date     Description:
// Feb17    Revision 1.0
//
// Notes:
// best viewed with tabstops set to "4"
// ********************************************************************
`timescale 1ns / 1ns

module Axi4TargetGen #
	(

		parameter [3:0]		TARGET_NUM				= 0,		// target number
		parameter integer 	ID_WIDTH   				= 4, 

		parameter integer 	ADDR_WIDTH      		= 32,				
		parameter integer 	DATA_WIDTH 				= 32, 

		parameter integer 	SUPPORT_USER_SIGNALS 	= 0,
		parameter integer 	USER_WIDTH 				= 1,

		
		parameter integer 	OPENTRANS_MAX			= 2,		// Number of open transations width - 1 => 2 transations, 2 => 4 transations, etc.

		parameter integer	LOWER_COMPARE_BIT 		= 'd10,		// Defines lower bound of compare - bits below are dont care
		parameter			HI_FREQ					= 0
		
	)
	(
		// Global Signals
		input  wire                                    		sysClk,
		input  wire                                    		ARESETN,			// active low reset synchronoise to RE AClk - asserted async.
   
		//====================== Target Read Address Ports  ================================================//
		// Target Read Address Port
		input wire [ID_WIDTH-1:0]          					TARGET_ARID,
		input wire [ADDR_WIDTH-1:0]          				TARGET_ARADDR,
		input wire [7:0]                         			TARGET_ARLEN,
		input wire [2:0]                         			TARGET_ARSIZE,
		input wire [1:0]                         			TARGET_ARBURST,
		input wire [1:0]                         			TARGET_ARLOCK,
		input wire [3:0]                         			TARGET_ARCACHE,
		input wire [2:0]                         			TARGET_ARPROT,
		input wire [3:0]                         			TARGET_ARREGION,			// not used
		input wire [3:0]                         			TARGET_ARQOS,			// not used
		input wire [USER_WIDTH-1:0]	        				TARGET_ARUSER,
		input wire                            				TARGET_ARVALID,				
		output  wire 	                       				TARGET_ARREADY,
   
		// Target Read Data Ports
		output  reg [ID_WIDTH-1:0]          				TARGET_RID,
		output  reg [DATA_WIDTH-1:0]    					TARGET_RDATA,
		output  reg [1:0]                     				TARGET_RRESP,
		output  reg                         				TARGET_RLAST,
		output  reg [USER_WIDTH-1:0]	        		 	TARGET_RUSER,			// not used
		output  reg                         				TARGET_RVALID,
		
		input 	wire	                       				TARGET_RREADY,
	
		// Target Write Address Port
		input wire [ID_WIDTH-1:0]          					TARGET_AWID,
		input wire [ADDR_WIDTH-1:0]          				TARGET_AWADDR,
		input wire [7:0]                         			TARGET_AWLEN,
		input wire [2:0]                         			TARGET_AWSIZE,
		input wire [1:0]                         			TARGET_AWBURST,
		input wire [1:0]                         			TARGET_AWLOCK,
		input wire [3:0]                         			TARGET_AWCACHE,
		input wire [2:0]                         			TARGET_AWPROT,
		input wire [3:0]                         			TARGET_AWREGION,			// not used
		input wire [3:0]                         			TARGET_AWQOS,			// not used
		input wire [USER_WIDTH-1:0]	        				TARGET_AWUSER,
		input wire                            				TARGET_AWVALID,				
		output wire	 	                       				TARGET_AWREADY,
   	
		// Target Write Data Ports
		input wire [DATA_WIDTH-1:0]    						TARGET_WDATA,
		input wire [(DATA_WIDTH/8)-1:0]  					TARGET_WSTRB,
		input wire                           				TARGET_WLAST,
		input wire [USER_WIDTH-1:0]	         				TARGET_WUSER,
		input wire                            				TARGET_WVALID,
		
		output reg                           				TARGET_WREADY,
		
		// Target Write Response Ports
		output reg [ID_WIDTH-1:0]           				TARGET_BID,
		output reg [1:0]                          			TARGET_BRESP,
		output reg [USER_WIDTH-1:0]          				TARGET_BUSER,
		output reg 	                            			TARGET_BVALID,

		input  wire  	                           			TARGET_BREADY,
		
		// ===============  Control Signals  =======================================================//
		input wire											TARGET_ARREADY_Default,			// defines whether TARGET asserts ready or waits for ARVALID
		input wire											TARGET_AWREADY_Default,			// defines whether TARGET asserts ready or waits for WVALID
	
		input wire											TARGET_DATA_IDLE_EN,				// Enables idle cycles to be inserted in Data channels
		input wire [1:0]									TARGET_DATA_IDLE_CYCLES,			// Idle cycles = 00= random, 01 = 1, 10=2, 11=3

		input wire											FORCE_ERROR, 					// Forces error pn read/write RESP
		input wire [7:0]									ERROR_BYTE						// Byte to force error on - for READs
		
	);
   						 
 
	localparam	[0:0]		arstIDLE = 1'h0,	arstDATA = 1'h1;

	localparam integer		NUM_BYTES 				= (DATA_WIDTH/8);			// number of bytes in each read / write 

	localparam [7:0] ALIGNED_BITS = 	$clog2(DATA_WIDTH/8);
								
	reg						d_TARGET_ARREADY, preTARGET_ARREADY;
	
	wire					sysReset;
	
	
//=================================================================================================
// Local Declarationes
//=================================================================================================
 
localparam	READFIF_WIDTH = ( ID_WIDTH + ADDR_WIDTH + 8 + 3 + 2 );			// ID, Addr, LEN and SIZE, and Burst 

reg [READFIF_WIDTH-1:0]		readFifWrData;
wire [READFIF_WIDTH-1:0]	readFifRdData;

reg							readFifWr, readFifRd;
wire						readFifoFull, readFifoEmpty;

reg [0:0]					arcurrState, arnextState;
 
reg [7:0]					burstLen, d_burstLen;

wire						rdFifoOverRunErr, rdFifoUnderRunErr;

reg	[LOWER_COMPARE_BIT+ALIGNED_BITS-1:0]	memRdAddr, memWrAddr;
reg	[LOWER_COMPARE_BIT+ALIGNED_BITS-1:0]	d_memRdAddr, d_memWrAddr;

reg [LOWER_COMPARE_BIT+ALIGNED_BITS-1:0] 	memRdAddrAlignedMask, memWrAddrAlignedMask;


wire	[DATA_WIDTH-1:0]	memRdData;
reg	[DATA_WIDTH-1:0]		memWrData;

reg							memWr;
 
reg [15:0]					arCount, d_arCount; 
reg [15:0]					rdCount, d_rdCount; 
 
reg [1:0]					d_idleRdCycles, idleRdCycles;					// holds number of idle cycles per RdData Cycle

reg [1:0]					idleRdCount;
reg 						idleRdCountClr, idleRdCountIncr;

reg [8:0] raddr_rand_sig;
reg [8:0] waddr_rand_sig;
reg [8:0] wdata_rand_sig;
 
 
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
 
//=============================================================================================
// Display messages only in Simulation - not synthesis
//=============================================================================================
`ifdef SIM_MODE

	//=============================================================================================
	// Display messages for Read Address Channel
	//=============================================================================================
	always @( posedge sysClk )
	begin
		#1;
	
		if ( TARGET_ARVALID )
			begin
				#1 $display( "%d, TARGET  %d - Starting Read Address Transaction %d, ARADDR= %h, ARBURST= %h, ARSIZE= %h, AID= %h, RXLEN= %d", 
								$time, TARGET_NUM, arCount, TARGET_ARADDR, TARGET_ARBURST, TARGET_ARSIZE, TARGET_ARID, TARGET_ARLEN );

				if ( TARGET_ARREADY )		// single beat
					begin
						#1 $display( "%d, TARGET  %d - Ending Read Address Transaction %d, AID= %h, RXLEN= %d", 
								$time, TARGET_NUM, arCount, TARGET_ARID, TARGET_ARLEN );
					end
				else
					begin
						@( posedge TARGET_ARREADY )
							#1 $display( "%d, TARGET  %d - Ending Read Address Transactions %d, AID= %h, RXLEN= %d", 
								$time, TARGET_NUM, arCount, TARGET_ARID, TARGET_ARLEN );
					end
			end
	end


	//=============================================================================================
	// Display messages for Read Data Channel
	//=============================================================================================
	always @( posedge sysClk )
		begin
			#1;
			if ( TARGET_RVALID )
				begin
					#1 $display( "%d, TARGET %d - Starting Read Data Transaction %d, AID= %h, RXLEN= %d", 
							$time, TARGET_NUM, rdCount, TARGET_RID, burstLen );

					if ( TARGET_RLAST & TARGET_RVALID & TARGET_RREADY )		// single beat
						begin
							#1 $display( "%d, TARGET %d - Ending Read Data Transaction %d, AID= %h, RXLEN= %d, RRESP=%h", 
								$time, TARGET_NUM, rdCount, TARGET_RID, burstLen, TARGET_RRESP );
						end
					else
						begin
							@( posedge ( TARGET_RLAST & TARGET_RVALID & TARGET_RREADY ) )
								#1 $display( "%d, TARGET %d - Ending Read Data Transactions %d, AID= %h, RXLEN= %d, RRESP=%h", 
									$time, TARGET_NUM, rdCount, TARGET_RID, burstLen, TARGET_RID );
						end
				end
		end 
 
 `ifdef VERBOSE
	//=============================================================================================
	// Display RDAT - data begin written from RAM
	//=============================================================================================
	always @( negedge sysClk )
		begin	
			if ( TARGET_RVALID & TARGET_RREADY )		
				begin
					$display( "%t, %m, memRdAddr=%h (%d), TARGET_RDATA= %d", $time, memRdAddr, memRdAddr, TARGET_RDATA );
				end
		end		
`endif
 
 
 
 
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
		rdFif(
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
					.fifoFull(  ),
					.fifoNearFull( readFifoFull ),
					.fifoOverRunErr( rdFifoOverRunErr ),
					.fifoUnderRunErr( rdFifoUnderRunErr )
				   
				);

 
		
//=============================================================================
// Declare Dual port RAM - store Target Data
//=============================================================================
caxi4interconnect_DualPort_RAM_SyncWr_ASyncRd_Sim #( 	.FIFO_AWIDTH( LOWER_COMPARE_BIT ),
								.FIFO_WIDTH ( DATA_WIDTH )
							)
		rdRam(
					// global signals
					.HCLK( sysClk ),

					// Write Port
					.fifoWrAddr( memWrAddr ),	
					.fifoWrite ( memWr	   ),
					.fifoWrStrb( TARGET_WSTRB ),

					.fifoWrData( memWrData ),

					// Read Port
					.fifoRdAddr( d_memRdAddr ),
					.fifoRdData( memRdData )
				   
			);

 
 
//====================================================================================================
// Target Read Address S/M
//===================================================================================================== 
 always @( * )
 begin
 
	arnextState <= arcurrState;

	readFifWrData <= { TARGET_ARID, TARGET_ARADDR, TARGET_ARLEN, TARGET_ARSIZE, TARGET_ARBURST };
	
	d_TARGET_ARREADY	<= TARGET_ARREADY_Default;		// only accept a transaction when space in fifo
	readFifWr		<= 0;

	d_arCount		<= arCount;
	
	case( arcurrState )
		arstIDLE: begin
					d_TARGET_ARREADY <= TARGET_ARREADY_Default;
		
					if ( TARGET_ARVALID & TARGET_ARREADY )		// if always ready
						begin
							d_TARGET_ARREADY	<= TARGET_ARREADY_Default;
							
							readFifWr	<= 1;
							d_arCount	<= arCount + 1'b1;

							arnextState <= arstIDLE;
						end
					else if ( TARGET_ARVALID & !TARGET_ARREADY )
						begin
							arnextState <= arstDATA;
						end
				end
		arstDATA : begin
					d_TARGET_ARREADY <= 1'b1;

					if ( TARGET_ARVALID & TARGET_ARREADY )		// 	last beat
						begin
							d_TARGET_ARREADY	<= TARGET_ARREADY_Default;

							d_arCount		<= arCount + 1'b1;
							
							readFifWr	  	<= 1;
	
							arnextState 		<= arstIDLE;

						end
				end
	endcase
end


 always @( posedge sysClk or negedge sysReset)		
 begin
	if (!sysReset)
		begin
			arcurrState 		<= arstIDLE;
			preTARGET_ARREADY	<= 0;
			
			arCount				<= 0;

		end
	else
		begin
			arcurrState 		<= arnextState;
			preTARGET_ARREADY	<= d_TARGET_ARREADY;
			raddr_rand_sig <= $random() % 100;
      waddr_rand_sig <= (raddr_rand_sig * $random()) % 100;
      wdata_rand_sig <= (waddr_rand_sig * $random()) % 100;
			arCount		<= d_arCount;

		end
end


assign TARGET_ARREADY = preTARGET_ARREADY & !readFifoFull & (raddr_rand_sig == 98);


//=================================================================================================
// Local Declarationes for Target Read Data 
//=================================================================================================
 
reg [ID_WIDTH-1:0] 			d_TARGET_RID;
reg [DATA_WIDTH-1:0]   		d_TARGET_RDATA;
reg [1:0]                   d_TARGET_RRESP;
reg                         d_TARGET_RLAST;
reg [USER_WIDTH-1:0]        d_TARGET_RUSER;
reg                         d_TARGET_RVALID;


reg	[7:0]					rxLen, d_rxLen;
reg [1:0]					rdBurstType, d_rdBurstType; 
reg [2:0]					rdRSize, d_rdRSize; 
 
reg [1:0]					rcurrState, rnextState;

localparam	[1:0]			rstIDLE = 2'h0,	rstDATA = 2'h1, rstIDLE_DATA = 2'h2;


//====================================================================================================
// Counter for Idle on each Read Data
//====================================================================================================
always @(posedge sysClk or negedge sysReset )
begin
	if ( !sysReset )
		begin
			idleRdCount	<= 0;		// initialise to 1
		end
	else if ( idleRdCountClr )
		begin
			idleRdCount	<= 0;		// initiales to 1
		end
	else if ( idleRdCountIncr )
		begin
			idleRdCount	<= idleRdCount + 1'b1;
		end
end

//=================================================================================================
// Create mask to "align" memRdAddr to size of transfer.
//=================================================================================================
always @( * )
	begin
		case( rdRSize )
			3'h0 : memRdAddrAlignedMask <=   { (LOWER_COMPARE_BIT+ALIGNED_BITS  ){1'b1} };
			3'h1 : memRdAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-1){1'b1} }, 1'b0 };
			3'h2 : memRdAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-2){1'b1} }, 2'b0 };
			3'h3 : memRdAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-3){1'b1} }, 3'b0 };
			3'h4 : memRdAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-4){1'b1} }, 4'b0 };
			3'h5 : memRdAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-5){1'b1} }, 5'b0 };
			3'h6 : memRdAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-6){1'b1} }, 6'b0 };
			3'h7 : memRdAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-7){1'b1} }, 7'b0 };
		endcase
	end
	
									
 //====================================================================================================
 // Target Read Data S/M
//===================================================================================================== 

 always @( * )
 begin
 
	rnextState <= rcurrState;
	
	d_TARGET_RID		<= TARGET_RID;
	d_TARGET_RDATA	<= { TARGET_NUM, {(DATA_WIDTH-4){1'b0}   } };
	d_TARGET_RRESP	<= TARGET_RRESP;
	d_TARGET_RLAST	<= TARGET_RLAST;
	d_TARGET_RUSER	<= 0;
	d_TARGET_RVALID	<= 0;

	d_rxLen			<= rxLen;
	d_rdBurstType 	<= rdBurstType;
	d_rdRSize		<= rdRSize;
	d_idleRdCycles	<= idleRdCycles;
	
	readFifRd		<= 0;
	
	d_memRdAddr		<= memRdAddr;
	d_burstLen	 	<= burstLen;

	d_rdCount		<= rdCount;

	idleRdCountClr	<= 1'b0;
	idleRdCountIncr	<= 1'b0;
	
	case( rcurrState )
		rstIDLE: begin
					
					d_rxLen 		<= 0;
					d_TARGET_RLAST	<= 0;
					
					idleRdCountClr	<= 1'b1;

					if ( !readFifoEmpty )				// data to read
						begin
							readFifRd		<= 1;		// pop fifo 

							d_TARGET_RDATA	<= memRdData;	

							//===========================================================================================
							//FifWrData == { TARGET_ARID, TARGET_ARADDR, TARGET_ARLEN, TARGET_ARSIZE, TARGET_ARBURST };
							//===========================================================================================
							d_rdBurstType <= readFifRdData[1:0];
							d_rdRSize	  <= readFifRdData[4:2];
							
							d_memRdAddr	<= readFifRdData[READFIF_WIDTH-ID_WIDTH-1: READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH];
							d_burstLen	<= readFifRdData[READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-1: READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-8 ]; // pickout ARLEN
							d_TARGET_RID	<= readFifRdData[READFIF_WIDTH-1: READFIF_WIDTH-ID_WIDTH];

							d_TARGET_RLAST	<= (readFifRdData[READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-1: READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-8 ] == 0);

							d_TARGET_RRESP	<= FORCE_ERROR 	? (ERROR_BYTE == 0 ) ? 2'b10  : 2'b00
															: 2'b00;

							
							//============================================================================
							// see if idle cycles to be inserted
							//============================================================================
							if ( TARGET_DATA_IDLE_EN )
								begin
									d_TARGET_RVALID	<= 1'b0;

									case (TARGET_DATA_IDLE_CYCLES)
										2'b00:		// random cycles
											begin
												`ifdef SIM_MODE		// only use random when in simulation
													d_idleRdCycles <= $random(); 
												`else
													d_idleRdCycles <= 0; 
												`endif
											end
										2'b01:		// 1 idle cycle
											begin
												d_idleRdCycles <= 4'd1; 
											end
										2'b10:		// 2 idle cycle
											begin
												d_idleRdCycles <= 4'd2; 
											end
										2'b11:		// 3 idle cycle
											begin
												d_idleRdCycles <= 4'd3; 
											end
									endcase
							
									rnextState 		<= rstIDLE_DATA;
								end
							else
								begin
									d_idleRdCycles <= 0; 
								
									d_TARGET_RVALID	<= 1'b1;	// start read cycle
									rnextState 		<= rstDATA;
								end
						end
					else
						begin

						end
						
				end
		rstIDLE_DATA : begin

					d_TARGET_RDATA	<= memRdData;	
		
					if ( idleRdCount == idleRdCycles )		// if had all idle cycles
						begin
							d_TARGET_RVALID	<= 1'b1;	// start read cycle

							rnextState 		<= rstDATA;
						end
					else
						begin
							idleRdCountIncr	<= 1'b1;
							
							rnextState 		<= rstIDLE_DATA;
						end
				end

		rstDATA : begin
					d_TARGET_RVALID	<= 1'b1;
					d_TARGET_RDATA	<= memRdData;	

					d_TARGET_RRESP	<= FORCE_ERROR 	? (rxLen == ERROR_BYTE ) ? 2'b10  : 2'b00
													: 2'b00;
					
					if ( TARGET_RVALID & TARGET_RREADY & TARGET_RLAST )		// 	last beat
						begin
							d_rdCount	<= rdCount + 1'b1;					// increment count of read transactions performed

							if ( ~readFifoEmpty )				// if another burst request - start on next clock
								begin
									readFifRd		<= 1;		// pop fifo 
								
									d_TARGET_RLAST	<= (readFifRdData[READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-1: READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-8 ] == 0);
									
									// Pick out from Read Fifo
									d_rdBurstType <= readFifRdData[1:0];
									d_rdRSize	  <= readFifRdData[4:2];
									
									d_memRdAddr	<= readFifRdData[READFIF_WIDTH-ID_WIDTH-1: READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH];
									d_burstLen	<= readFifRdData[ READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-1: READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-8 ]; // pickout ARLEN
									d_TARGET_RID	<= readFifRdData[READFIF_WIDTH-1: READFIF_WIDTH-ID_WIDTH];

									d_TARGET_RLAST	<= (readFifRdData[READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-1: READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-8 ] == 0);
									
									d_rxLen 	<= 0;

									if ( TARGET_DATA_IDLE_EN )
										begin
								
											if (TARGET_DATA_IDLE_CYCLES == 0)		// if random delays - update
												begin
													`ifdef SIM_MODE		// only use random when in simulation
														d_idleRdCycles <= $random(); 
													`else
														d_idleRdCycles <= 0; 
													`endif
												end
											d_TARGET_RVALID	<= 1'b0;	// start next read data transaction
											rnextState  	<= rstIDLE_DATA;
										end
									else
										begin
											d_idleRdCycles <= 0; 

											d_TARGET_RVALID	<= 1'b1;	// start next read data transaction
											rnextState  	<= rstDATA;
										end
								end
							else
								begin
														
									d_TARGET_RVALID	<= 1'b0;
									d_TARGET_RLAST	<= 0;
									d_burstLen		<= 0;
									d_rxLen 		<= 0;
									//d_memRdAddr		<= 0;
							
									rnextState <= rstIDLE;
								end
						end
					else if ( TARGET_RREADY & TARGET_RVALID )		// get next data
						begin
						
							case ( rdBurstType )
								2'b00 :			// fixed
									begin
										d_memRdAddr		<= memRdAddr;
									end
								2'b01 :			// increment
									begin
										d_memRdAddr <= ( memRdAddr & memRdAddrAlignedMask) + ( 1 << rdRSize );
																				// increment by number of bytes transferred										
									end
								2'b10 :			// wrap - not handling wrap correctly here
									begin
										d_memRdAddr <= ( memRdAddr & memRdAddrAlignedMask) + ( 1 << rdRSize );
																				// increment by number of bytes transferred										
									end									
								2'b11 :			// reserverd
									begin
										$stop;		// should never get here
									end										
							endcase
							
							d_TARGET_RLAST	<= ( rxLen +1'b1 == burstLen );		// reached end of burst
							
							d_rxLen 		<= rxLen + 1'b1;

							if ( TARGET_DATA_IDLE_EN )
								begin
								
									if (TARGET_DATA_IDLE_CYCLES == 0)		// if random delays - update
										begin
											`ifdef SIM_MODE		// only use random when in simulation
												d_idleRdCycles <= $random(); 
											`else
												d_idleRdCycles <= 0; 
											`endif
										end
									else
										begin
											d_idleRdCycles <= 0; 
										end
										
										d_TARGET_RVALID	<= 1'b0;	// start next read data transaction
										rnextState  	<= rstIDLE_DATA;
								end
							else
								begin
									d_TARGET_RVALID	<= 1'b1;	// start next read data transaction
									rnextState  	<= rstDATA;
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
			TARGET_RID		<= 0;
			TARGET_RDATA		<= { TARGET_NUM, {(DATA_WIDTH-4){1'b0} }  };
			TARGET_RRESP		<= 0;
			TARGET_RLAST		<= 0;
			TARGET_RUSER		<= 0;
			TARGET_RVALID	<= 0;
			
			rdBurstType	<= 0;
			rdRSize		<= 0;
			rxLen 		<= 0;
			memRdAddr	<= 0;
			burstLen	<= 0;

			rdCount		<= 0;
			idleRdCycles	<= 0;
			
			rcurrState	<= rstIDLE;
		end
	else
		begin
			TARGET_RID		<= d_TARGET_RID;
			TARGET_RDATA		<= d_TARGET_RDATA;
			TARGET_RRESP		<= d_TARGET_RRESP;
			TARGET_RLAST		<= d_TARGET_RLAST;
			TARGET_RUSER		<= d_TARGET_RUSER;
			TARGET_RVALID	<= d_TARGET_RVALID;
		
			rdBurstType <= d_rdBurstType;
			rdRSize		<= d_rdRSize;
			rxLen 		<= d_rxLen;
			memRdAddr 	<= d_memRdAddr;
			burstLen	<= d_burstLen;

			rdCount		<= d_rdCount;
			idleRdCycles <= d_idleRdCycles;
			
			rcurrState	<= rnextState;
		end
end

//always@(*)
//  TARGET_RDATA		<= d_TARGET_RDATA;


// Different paths for simulation and synthesis
// `ifdef SIM_MODE
	// `include "../component/Actel/DirectCore/CoreAXI4Interconnect_w/2.1.3/sim/AXI4Models/Axi4TargetGen_Wr.v"
	// `include "../component/Actel/DirectCore/CoreAXI4Interconnect_w/2.1.3/sim/AXI4Models/Axi4TargetGen_WrResp.v"
// `else
	//`include "./Axi4TargetGen_Wr.v"
	//`include "./Axi4TargetGen_WrResp.v"
// `endif

// ********************************************************************
//  Microsemi Corporation Proprietary and Confidential
//  Copyright 2017 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: This module provides a AXI4 Target Write Channel test
//              source. It stores the write cycle into local memory. It
//              assume write is of INCR type.
//
// Revision Information:
// Date     Description:
// Feb17    Revision 1.0
//
// Notes:
// best viewed with tabstops set to "4"
// ********************************************************************
`timescale 1ns / 1ns

//=================================================================================================
// Local Declarationes
//=================================================================================================
 
 
	localparam	RESPFIF_WIDTH = ( ID_WIDTH + 2 );			// ID, Resp

	
	reg							d_TARGET_AWREADY, preTARGET_AWREADY;

	wire [READFIF_WIDTH-1:0]	wrFifRdData;	
	reg [READFIF_WIDTH-1:0]		wrFifWrData;	
	
	wire [RESPFIF_WIDTH-1:0]	respFifRdData;	
	wire [RESPFIF_WIDTH-1:0]	respFifWrData;	

	reg							wrFifWr, wrFifRd;
	reg							respFifWr, respFifRd;
	
	wire						wrFifoFull, wrFifoEmpty;	
	wire						respFifoFull, respFifoEmpty;	
	
	wire						wrFifoOverRunErr, wrFifoUnderRunErr;
	wire						respFifoOverRunErr, respFifoUnderRunErr;

	
	reg [0:0]					awcurrState, awnextState;
	
	reg [15:0]					awCount, d_awCount;
	
	localparam	[0:0]			awstIDLE = 1'h0,	awstDATA = 1'h1;


	reg [1:0]					wcurrState, wnextState;
	
	localparam	[1:0]			wstIDLE = 1'h0,	wstDATA = 1'h1, wstIDLE_DATA = 2'h2;

	reg [1:0]					d_idleWrCycles, idleWrCycles;					// holds number of idle cycles per RdData Cycle

	reg [1:0]					idleWrCount;
	reg 						idleWrCountClr, idleWrCountIncr;
	
//======================================================================================================
// Local Declarationes for Target Write Data 
//======================================================================================================
 
reg						d_TARGET_WREADY;

reg [1:0]				wrBurstType, d_wrBurstType; 
reg [2:0]				wrWSize, d_wrWSize; 

reg	[8:0]				txLen, d_txLen, wburstLen, d_wburstLen;

reg	[ID_WIDTH-1:0]		respWID, d_respWID;
reg [1:0]				respResp;
 
reg [15:0]				txCount, d_txCount;	

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
	
			if ( TARGET_AWVALID ) 
				begin
					#1 $display( "%d, TARGET  %d - Starting Write Address Transaction %d, AWADDR= %h,AWBURST= %h, AWSIZE= %h, WID= %h, AWLEN= %d", 
							$time, TARGET_NUM, awCount, TARGET_AWADDR, TARGET_AWBURST, TARGET_AWSIZE, TARGET_AWID, TARGET_AWLEN );

					if ( TARGET_AWREADY )		// single beat
						begin
							#1 $display( "%d, TARGET  %d - Ending Write Address Transaction %d, WID= %h, AWLEN= %d", 
									$time, TARGET_NUM, awCount, TARGET_AWID, TARGET_AWLEN );
						end
					else
						begin
							@( posedge TARGET_AWREADY )
								#1 $display( "%d, TARGET  %d - Ending Write Address Transaction %d, WID= %h, AWLEN= %d", 
									$time, TARGET_NUM, awCount, TARGET_AWID, TARGET_AWLEN );
						end
				end
		end	

	//=============================================================================================
	// Display messages for Write Data Channel
	//=============================================================================================
	always @( posedge sysClk )
		begin
			#1;
	
			if ( TARGET_WVALID & ( wcurrState != wstIDLE ) )
				begin
					#1 $display( "%d, TARGET  %d - Starting Write Data Transaction %d, WADDR= %h (%d), WID= %h, TXLEN= %d", 
							$time, TARGET_NUM, txCount, memWrAddr, memWrAddr, respWID, wburstLen );

					if ( TARGET_WLAST & TARGET_WVALID & TARGET_WREADY )		// single beat
						begin
							#1 $display( "%d, TARGET  %d - Ending Write Data Transaction %d, WID= %h, TXLEN= %d", 
									$time, TARGET_NUM, txCount, respWID, txLen );
						end
					else
						begin
							@( posedge ( TARGET_WLAST & TARGET_WVALID & TARGET_WREADY ) )
								#1 $display( "%d, TARGET  %d - Ending Write Data Transaction %d, WID= %h, TXLEN= %d", 
										$time, TARGET_NUM, txCount, respWID, txLen );
						end
				end
		end

		
	//=============================================================================================
	// Display messages for checking size of burst at end of Write Data Channel
	//=============================================================================================
	always @( negedge sysClk )
		begin
			
			if ( TARGET_WVALID & TARGET_WREADY & TARGET_WLAST )		// wait until end of burst
				begin
					if ( wburstLen != txLen )
						begin
							$display( "%d, AXITARGETGEN %d WLAST Error, expBurstLen= %d, actBurstLen= %d \n\n", 
											$time, TARGET_NUM, wburstLen, txLen );
									
							#1 $stop;
						end		
				end
		end

`ifdef VERBOSE
	//=============================================================================================
	// Display WDAT - data begin written into RAM
	//=============================================================================================
	always @( negedge sysClk )
		begin	
			if ( TARGET_WVALID & TARGET_WREADY )		
				begin
					$display( "%t, %m, memWrAddr=%h (%d), TARGET_WDATA= %d, TARGET_WSTRB= %h", $time, memWrAddr, memWrAddr, TARGET_WDATA, TARGET_WSTRB );
				end
		end		
`endif

		
`endif
	
	
//===========================================================================================
 // FIFO to hold open transactions - pushed on Write Address cycle and popped on Write data
 // cycle.
 //===========================================================================================
 caxi4interconnect_FifoDualPort #(	.FIFO_AWIDTH( OPENTRANS_MAX ),
					.FIFO_WIDTH( READFIF_WIDTH ),
					.HI_FREQ( HI_FREQ ),
					.NEAR_FULL( 'd2 )
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
					.fifoOneAvail( ),
					.fifoRdValid(  ),
					.fifoFull(  ),
					.fifoNearFull( wrFifoFull ),
					.fifoOverRunErr( wrFifoOverRunErr ),
					.fifoUnderRunErr( wrFifoUnderRunErr )
				   
				);

				
caxi4interconnect_FifoDualPort #(		.FIFO_AWIDTH( OPENTRANS_MAX ),
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
					.fifoOneAvail( ),
					.fifoRdValid ( ),
					.fifoFull( respFifoFull ),
					.fifoNearFull( ),
					.fifoOverRunErr( respFifoOverRunErr ),
					.fifoUnderRunErr( respFifoUnderRunErr )
				   
				);
   
   
//====================================================================================================
// Target Write Address S/M
//===================================================================================================== 
 always @( * )
 begin
 
	awnextState <= awcurrState;
	
	d_TARGET_AWREADY	<=  (waddr_rand_sig > 50);
	wrFifWr		<= 0;

	wrFifWrData <= { TARGET_AWID, TARGET_AWADDR, TARGET_AWLEN, TARGET_AWSIZE, TARGET_AWBURST };
	
	d_awCount	<= awCount;
	
	case( awcurrState )
		awstIDLE: begin
					d_TARGET_AWREADY <= (waddr_rand_sig > 50);
		
					if ( TARGET_AWVALID & TARGET_AWREADY )		// if both ends ready for transaction
						begin
							wrFifWrData <= { TARGET_AWID, TARGET_AWADDR, TARGET_AWLEN, TARGET_AWSIZE, TARGET_AWBURST };
							wrFifWr	<= 1;
							d_awCount	<= awCount + 1'b1;

							awnextState	<= awstIDLE;
						end
					else if ( TARGET_AWVALID & !TARGET_AWREADY )
						begin
							awnextState	<= awstDATA;
						end
				end
		awstDATA : begin
					d_TARGET_AWREADY <= 1'b1;

					if ( TARGET_AWVALID & TARGET_AWREADY )		// 	last beat
						begin
							d_TARGET_AWREADY	<= (waddr_rand_sig > 50);
							
							wrFifWrData <= { TARGET_AWID, TARGET_AWADDR, TARGET_AWLEN, TARGET_AWSIZE, TARGET_AWBURST };
							wrFifWr	  	<= 1;
							d_awCount	<= awCount + 1'b1;
	
							awnextState	<= awstIDLE;

						end
				end
	endcase
end


 always @(posedge sysClk or negedge sysReset)		
 begin
	if (!sysReset)
		begin
			awcurrState 		<= awstIDLE;
			preTARGET_AWREADY	<= 0;
			awCount				<= 0;

		end
	else
		begin
			awcurrState 		<= awnextState;
			preTARGET_AWREADY	<= d_TARGET_AWREADY;
			awCount				<= d_awCount;
			
		end
end


assign TARGET_AWREADY = preTARGET_AWREADY & !wrFifoFull & (waddr_rand_sig == 98);

assign 	respFifWrData = { respWID, respResp };

//====================================================================================================
// Counter for Idle on each Write Data
//====================================================================================================
always @(posedge sysClk or negedge sysReset )
begin
	if ( !sysReset )
		begin
			idleWrCount	<= 0;		// initialise to 1
		end
	else if ( idleWrCountClr )
		begin
			idleWrCount	<= 0;		// initiales to 1
		end
	else if ( idleWrCountIncr )
		begin
			idleWrCount	<= idleWrCount + 1'b1;
		end
end


//=================================================================================================
// Create mask to "align" memWrAddr
//=================================================================================================
always @( * )
	begin
		case( wrWSize )
			3'h0 : memWrAddrAlignedMask <=   { (LOWER_COMPARE_BIT+ALIGNED_BITS  ){1'b1} };
			3'h1 : memWrAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-1){1'b1} }, 1'b0 };
			3'h2 : memWrAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-2){1'b1} }, 2'b0 };
			3'h3 : memWrAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-3){1'b1} }, 3'b0 };
			3'h4 : memWrAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-4){1'b1} }, 4'b0 };
			3'h5 : memWrAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-5){1'b1} }, 5'b0 };
			3'h6 : memWrAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-6){1'b1} }, 6'b0 };
			3'h7 : memWrAddrAlignedMask <= { { (LOWER_COMPARE_BIT+ALIGNED_BITS-7){1'b1} }, 7'b0 };
		endcase
	end
 //====================================================================================================
 // Target Write Data S/M
//===================================================================================================== 
 always @( * )
 begin
 
	wnextState 		<= wcurrState;

	memWrData <= TARGET_WDATA;
	memWr	  <= 0;
	
	d_TARGET_WREADY	<= 0;

	wrFifRd	  	<= 0;			
	respFifWr	<= 0;

	d_respWID	<= respWID;
	d_wburstLen	<= wburstLen;
	d_memWrAddr	<= memWrAddr;
	d_txLen		<= txLen;
	d_wrBurstType <= wrBurstType;
	d_wrWSize	  <= wrWSize;
	
	d_idleWrCycles <= idleWrCycles;
	
	d_txCount	<= txCount;
	
	respResp	<= FORCE_ERROR 	? 2'b10  : 2'b00;
	
	idleWrCountClr	<= 1'b0;
	idleWrCountIncr	<= 1'b0;

	case( wcurrState )
		wstIDLE: begin
					
					d_txLen <= 0;
					
					d_wburstLen	<= 0;
					d_wrWSize	<= 0;
					d_respWID	<= 0;

					//READFIF_WIDTH = ( ID_WIDTH + ADDR_WIDTH + 8 + 3 + 2 );			// ID, Addr, LEN and SIZE, and Burst 
					d_memWrAddr	<= 0;

					
					if ( ~wrFifoEmpty )
						begin
							d_TARGET_WREADY	<= 1'b1;
	
							d_wrBurstType <= wrFifRdData[1:0];
							d_wrWSize	  <= wrFifRdData[4:2 ]; 	// pickout AWSIZE

							d_wburstLen	<= wrFifRdData[READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-1: READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-8 ]; // pickout AWLEN
							d_respWID	<= wrFifRdData[READFIF_WIDTH-1: READFIF_WIDTH- ID_WIDTH];

							//localparam	READFIF_WIDTH = ( ID_WIDTH + ADDR_WIDTH + 8 + 3 + 2 );			// ID, Addr, LEN and SIZE, and Burst 
							d_memWrAddr	<= wrFifRdData[READFIF_WIDTH- ID_WIDTH-1: READFIF_WIDTH-ID_WIDTH - ADDR_WIDTH];  // pick out write start address

							wrFifRd <= 1;		// pop entry
															
							wnextState 	<= wstDATA;
						end
				end
						
		wstDATA : begin
					d_TARGET_WREADY	<= 1'b1;
					
					idleWrCountClr 	<= 1'b1;
				
					if ( TARGET_WVALID & TARGET_WREADY )		// wait until address available for start
						begin
							memWr	  <= 1'b1; //&TARGET_WSTRB;		// Hack - assumes all bytes have to be written on bus.

							case( wrBurstType )
								2'b00:		// fixed
									begin
										d_memWrAddr	<= memWrAddr;
									end
								2'b01:		// increment
									begin
										d_memWrAddr <= ( memWrAddr & memWrAddrAlignedMask) + ( 1 << wrWSize );
																				// increment by number of bytes transferred
									end
								2'b10:		// wrap - not handling wrap correctly
									begin
										d_memWrAddr <= ( memWrAddr & memWrAddrAlignedMask) + ( 1 << wrWSize );
																				// increment by number of bytes transferred
									end
								2'b11:
									begin
										$stop;		/// should not get here
									end								
							endcase
								
							if ( TARGET_WLAST )			// 1-beat
								begin													
									d_txCount		<= txCount + 1'b1;
									d_txLen			<= 0;
									
									respFifWr		<= 1'b1;
									
									if ( ~wrFifoEmpty & ~TARGET_DATA_IDLE_EN)		// another data available - and not IDLE_EN on
										begin
											d_wrBurstType <= wrFifRdData[1:0];
											d_wrWSize	  <= wrFifRdData[4:2 ]; 	// pickout AWSIZE

											d_wburstLen	<= wrFifRdData[READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-1: READFIF_WIDTH-ID_WIDTH-ADDR_WIDTH-8 ]; // pickout ARLEN
											d_respWID	<= wrFifRdData[READFIF_WIDTH-1: READFIF_WIDTH- ID_WIDTH];	
											//localparam	READFIF_WIDTH = ( ID_WIDTH + ADDR_WIDTH + 8 + 3 + 2 );			// ID, Addr, LEN and SIZE, and Burst 
											d_memWrAddr	<= wrFifRdData[READFIF_WIDTH- ID_WIDTH-1: READFIF_WIDTH-ID_WIDTH - ADDR_WIDTH];  // pick out write start address
											wrFifRd <= 1;		// pop entry
											
											d_TARGET_WREADY	<= 1'b1;									
											wnextState 		<= wstDATA;
										end
									else
										begin
											d_TARGET_WREADY	<= 1'b0;									
											wnextState 		<= wstIDLE;
										end
								end
							else
								begin
									d_txLen		<= txLen + 1'b1;
									
									//============================================================================
									// see if idle cycles to be inserted
									//============================================================================
									if ( TARGET_DATA_IDLE_EN )
										begin
											d_TARGET_WREADY	<= 1'b0;

											case (TARGET_DATA_IDLE_CYCLES)
												2'b00:		// random cycles
													begin
														`ifdef SIM_MODE		// only use random when in simulation
															d_idleWrCycles <= $random(); 
														`else
															d_idleWrCycles <= 0; 
														`endif
													end
												2'b01:		// 1 idle cycle
													begin
														d_idleWrCycles <= 4'd1; 
													end
												2'b10:		// 2 idle cycle
													begin
														d_idleWrCycles <= 4'd2; 
													end
												2'b11:		// 3 idle cycle
													begin
														d_idleWrCycles <= 4'd3; 
													end
											endcase
							
											wnextState 		<= wstIDLE_DATA;
										end
									else
										begin
											d_idleWrCycles <= 0;
											wnextState 	<= wstDATA;
										end
								end
						end
				end
		wstIDLE_DATA : begin

					d_TARGET_WREADY	<= 1'b0;
		
					if ( idleWrCount == idleWrCycles )		// if had all idle cycles
						begin
							d_TARGET_WREADY	<= 1'b1;

							wnextState 		<= wstDATA;
						end
					else
						begin
							idleWrCountIncr	<= 1'b1;
							
							wnextState 		<= wstIDLE_DATA;
						end
				end			
	endcase
end


 always @(posedge sysClk or negedge sysReset)
 begin
 
	if (!sysReset)
		begin
			txLen 			<= 0;
			memWrAddr		<= 0;
			
			respWID			<= 0;
			wburstLen		<= 0;
			TARGET_WREADY	<= 0;
			txCount			<= 0;
			wrBurstType 	<= 0;
			wrWSize			<= 0;
			
			idleWrCycles	<= 0;

			wcurrState	<= wstIDLE;
		end
	else
		begin
			txLen 			<= d_txLen;
			memWrAddr		<= d_memWrAddr;
		
			respWID			<= d_respWID;
			wburstLen		<= d_wburstLen;
			TARGET_WREADY	<= d_TARGET_WREADY & !respFifoFull;
			
			txCount		<= d_txCount;
			wrBurstType <= d_wrBurstType;
			wrWSize		<= d_wrWSize;

			idleWrCycles <= d_idleWrCycles;
		
			wcurrState	<= wnextState;
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
// Description: This module provides a AXI4 Target test source.
//
// Revision Information:
// Date     Description:
// Feb17    Revision 1.0
//
// Notes:
// best viewed with tabstops set to "4"
// ********************************************************************
`timescale 1ns / 1ns

reg [15:0]	respCount, d_respCount;

`define SIM_MODE

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
	
			if ( TARGET_BVALID )
				begin
					#1 $display( "%d, TARGET  %d - Starting Write Response Transaction %d, BID= %h, BRESP= %h", 
							$time, TARGET_NUM, respCount, TARGET_BID, TARGET_BRESP );

					if ( TARGET_BREADY & TARGET_BVALID )		// single beat
						begin
							#1 $display( "%d, TARGET  %d - Ending Write Response Transaction %d, BID= %h", 
									$time, TARGET_NUM, respCount, TARGET_BID );
						end
					else
						begin
							@( posedge ( TARGET_BREADY & TARGET_BVALID)  )
								#1 $display( "%d, TARGET  %d - Ending Write Response Transaction %d, BID= %h", 
									$time, TARGET_NUM, respCount, TARGET_BID );
						end
				end
		end

`endif



//=================================================================================================
// Local Declarationes for Target Write Response Channel 
//=================================================================================================
 
reg [ID_WIDTH-1:0] 			d_TARGET_BID;
reg [1:0]                   d_TARGET_BRESP;
reg [USER_WIDTH-1:0]        d_TARGET_BUSER;
reg                         d_TARGET_BVALID;

reg [0:0]					bcurrState, bnextState;

localparam	[0:0]			bstIDLE = 1'h0,	bstDATA = 1'h1;


 //====================================================================================================
 // Target Read Data S/M
//===================================================================================================== 
 always @( * )
 begin
 
	bnextState <= bcurrState;
	
	d_TARGET_BID		<= TARGET_BID;
	d_TARGET_BRESP	<= TARGET_BRESP;
	d_TARGET_BUSER	<= 0;
	d_TARGET_BVALID	<= 0;

	respFifRd	  	<= 0;

	d_respCount		<= respCount;

	case( bcurrState )
		bstIDLE: begin
					
					if ( ~respFifoEmpty )		// data to read
						begin
							//RESPFIF_WIDTH = ( ID_WIDTH + 2 );			// ID, Resp

							d_TARGET_BID		<= respFifRdData[RESPFIF_WIDTH-1: RESPFIF_WIDTH-ID_WIDTH];
							d_TARGET_BRESP	<= respFifRdData[RESPFIF_WIDTH-ID_WIDTH-1: 0];

							respFifRd		<= 1;		// pop fifo 

							bnextState 		<= bstDATA;
						end
				end
		rstDATA : begin
					d_TARGET_BVALID	<= 1'b1;

					if ( TARGET_BREADY & TARGET_BVALID )
						begin
						
							d_respCount		<= respCount + 1'b1;

							if ( ~respFifoEmpty )				// if another burst request - start on next clock
								begin
									d_TARGET_BVALID	<= 1'b1;
									d_TARGET_BID		<= respFifRdData[RESPFIF_WIDTH-1: RESPFIF_WIDTH-ID_WIDTH];
									d_TARGET_BRESP	<= respFifRdData[RESPFIF_WIDTH-ID_WIDTH-1: 0];
								
									respFifRd	<= 1;		// pop fifo 
									bnextState 	<= bstDATA;
								end
							else
								begin
									d_TARGET_BVALID	<= 1'b0;
									d_TARGET_BID		<= 0;
									d_TARGET_BRESP	<= 0;
									
									bnextState <= bstIDLE;
								end
						end
					else			// not ready
						begin
									
						end
				end
	endcase
end


 always @(posedge sysClk or negedge sysReset)
 begin
 
	if (!sysReset)
		begin
			TARGET_BID		<= 0;
			TARGET_BRESP		<= 0;
			TARGET_BUSER		<= 0;
			TARGET_BVALID	<= 0;
			respCount		<= 0;
			
			bcurrState	<= bstIDLE;
		end
	else
		begin
			TARGET_BID		<= d_TARGET_BID;
			TARGET_BRESP		<= d_TARGET_BRESP;
			TARGET_BUSER		<= d_TARGET_BUSER;
			TARGET_BVALID	<= d_TARGET_BVALID;	
			respCount		<= d_respCount;
			
			bcurrState	<= bnextState;
		end
end


 // Axi4TargetGen_RespWr.v

		
endmodule // Axi4TargetGen.v

