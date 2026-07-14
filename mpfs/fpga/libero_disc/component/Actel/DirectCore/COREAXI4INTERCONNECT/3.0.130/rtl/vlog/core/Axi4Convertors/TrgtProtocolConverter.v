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

module caxi4interconnect_TrgtProtocolConverter #

	(
		parameter integer 	NUM_TARGETS			  = 4,			// defines number of target ports
												  
		parameter integer 	TARGET_NUMBER		  = 0,			//current target
		parameter integer 	ADDR_WIDTH      	  = 20,			// valid values - 16 - 64
		parameter integer 	DATA_WIDTH 			  = 32,			// valid widths - 32, 64, 128, 256
												  
		parameter [1:0] 	TARGET_TYPE			  = 2'b11,		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11
		parameter [0:0] 	READ_ZERO_TARGET_ID	  = 1'b1,	// zero ID field		
		parameter [0:0] 	WRITE_ZERO_TARGET_ID  = 1'b1,	// zero ID field		

		parameter integer 	USER_WIDTH 			  = 1,			// defines the number of bits for USER signals RUSER and WUSER
												  
		parameter integer 	ID_WIDTH   			  = 3,			// number of bits for ID (ie AID, WID, BID) - valid 1-8 
		
		parameter integer   TRGT_AXI4PRT_ADDRDEPTH = 8,		// Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
		parameter integer   TRGT_AXI4PRT_DATADEPTH = 8,		// Number transations width - 1 => 2 transations, 2 => 4 transations, etc.		
		parameter integer   MAX_TRANS             = 8,		// Number of maximum transaction
		
		parameter           READ_INTERLEAVE       = 0,      // 1 - Enable out of order transaction 0 - Diable out of order transaction
		parameter           PIPE                  = 0,      // 1 - Enable out of order transaction 0 - Diable out of order transaction
		parameter           PROTOCONV_RAM_TYPE    = 3,      // 1 - Enable out of order transaction 0 - Diable out of order transaction
		parameter           SYNC_RESET            = 0,      // 1 - Enable out of order transaction 0 - Diable out of order transaction
		parameter           DWC_ENABLED           = 0,      // 1 - DWC enabled, filter dummy (WSTRB=0) responses
		parameter           BYPASS_CROSSBAR       = 0       // 1 - Crossbar bypassed, skip ID FIFO for pure register slice mode
	
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
	output wire             		int_targetARREADY,

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
	input wire [DATA_WIDTH-1:0]  	TARGET_RDATA,
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
	output  wire [ID_WIDTH-1:0]   	TARGET_WID,
	output wire [DATA_WIDTH-1:0]   	TARGET_WDATA,
	output wire [(DATA_WIDTH/8)-1:0] TARGET_WSTRB,
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
		if ( TARGET_TYPE == 2'b00) 		// AXI4 Target type - direct connection
			begin
				//====================================== ASSIGNEMENTS =================================================
						//from crossbar to Target
				assign TARGET_AWADDR    = int_targetAWADDR;
				assign TARGET_AWLEN     = int_targetAWLEN;
				assign TARGET_AWSIZE    = int_targetAWSIZE;
				assign TARGET_AWBURST   = int_targetAWBURST;	
				assign TARGET_AWLOCK    = int_targetAWLOCK;
				assign TARGET_AWCACHE   = int_targetAWCACHE;	
				assign TARGET_AWPROT    = int_targetAWPROT;
				assign TARGET_AWREGION  = int_targetAWREGION;
				assign TARGET_AWQOS     = int_targetAWQOS;
				assign TARGET_AWUSER    = int_targetAWUSER;
				assign TARGET_WID       = 0;
				assign TARGET_WDATA     = int_targetWDATA;
				assign TARGET_WSTRB     = int_targetWSTRB;
				assign TARGET_WLAST     = int_targetWLAST;
				assign TARGET_WUSER     = int_targetWUSER;
				assign TARGET_WVALID    = int_targetWVALID;
				assign TARGET_ARADDR    = int_targetARADDR;
				assign TARGET_ARLEN     = int_targetARLEN;
				assign TARGET_ARSIZE    = int_targetARSIZE;
				assign TARGET_ARBURST   = int_targetARBURST;	
				assign TARGET_ARLOCK    = int_targetARLOCK;
				assign TARGET_ARCACHE   = int_targetARCACHE;	
				assign TARGET_ARPROT    = int_targetARPROT;
				assign TARGET_ARREGION  = int_targetARREGION;
				assign TARGET_ARQOS     = int_targetARQOS;
				assign TARGET_ARUSER    = int_targetARUSER;
				//			
				//from		Target to crossbar	
				assign int_targetWREADY = TARGET_WREADY;
				assign int_targetBRESP  =	TARGET_BRESP;
				assign int_targetBUSER  =	TARGET_BUSER;
						
				assign int_targetRDATA  =	TARGET_RDATA;
				assign int_targetRRESP  =	TARGET_RRESP;
				assign int_targetRLAST  =	TARGET_RLAST;
				assign int_targetRUSER  =	TARGET_RUSER;


                            caxi4interconnect_TrgtAxi4ProtConvAXI4ID #
							(
								.ID_WIDTH                       ( ID_WIDTH               ),		// includes infrastructure ID
								.ZERO_TARGET_ID                 ( READ_ZERO_TARGET_ID    ),				
                                 //FIFO is implemented when Read Interleave is disabled to store the ID. 
								 //When Read Interleave is disabled, not expecting much outstanding transfer. 
								 //So keeping depth of 4 and FIFO will be implemented in the LUTs								
								.TRGT_AXI4PRT_ADDRDEPTH 		( 4                      ), 
								.READ_INTERLEAVE                ( READ_INTERLEAVE        ),
	      		                .PIPE                           ( PIPE                   ),
	      		                .PROTOCONV_RAM_TYPE             ( PROTOCONV_RAM_TYPE     ),
	      		                .SYNC_RESET                     ( SYNC_RESET             ),
	      		                .BYPASS_CROSSBAR                ( BYPASS_CROSSBAR        )
                            ) u_TrgtAxi4ReadID                  
							(
								.ACLK                           ( ACLK                   ),
								.arst_sync                      ( arst_sync              ),				// active low reset synchronoise to RE AClk - asserted async.
								.srst_sync                      ( srst_sync              ),				// active low reset synchronoise to RE AClk - asserted async.
								
								//===================== Initiator to TARGET direction==================================
								//READ Request Chan	
								.int_targetAID			        ( int_targetARID         ),	

								//READ REASPONSE Chan response
								.int_targetREADY		        ( int_targetRREADY       ),
								.int_targetVALID		        ( int_targetRVALID       ),
								//================= TARGET to Initiator direction ================================== 
								//READ DATA Chan				
								.int_targetID		            ( int_targetRID          ),

								//READ Address Request Chan Response
								.int_targetAREADY	            ( int_targetARREADY      ),
								.int_targetAVALID		        ( int_targetARVALID      ),	
								
								//READ Address Request Chan
								.TARGET_AID			            ( TARGET_ARID            ),	
								.TARGET_AREADY		            ( TARGET_ARREADY         ),	
								.TARGET_AVALID		            ( TARGET_ARVALID         ),

								//READ DATA Chan	
								.TARGET_VALID		            ( TARGET_RVALID          ),
								.TARGET_LAST		            ( TARGET_RLAST           ),
								.TARGET_READY		            ( TARGET_RREADY          ),
								.TARGET_ID			            ( TARGET_RID             )
							); 


                                
                            caxi4interconnect_TrgtAxi4ProtConvAXI4ID #
							(
								.ID_WIDTH                       ( ID_WIDTH               ),		// includes infrastructure ID
								.ZERO_TARGET_ID                 ( WRITE_ZERO_TARGET_ID   ),		
                                 //FIFO is implemented when Read Interleave is disabled to store the ID. 
								 //When Read Interleave is disabled, not expecting much outstanding transfer. 
								 //So keeping depth of 4 and FIFO will be implemented in the LUTs																
								.TRGT_AXI4PRT_ADDRDEPTH 		( 4                      ),
								.READ_INTERLEAVE                ( READ_INTERLEAVE        ),
	      		                .PIPE                           ( PIPE                   ),
	      		                .PROTOCONV_RAM_TYPE             ( PROTOCONV_RAM_TYPE     ),
	      		                .SYNC_RESET                     ( SYNC_RESET             ),
	      		                .BYPASS_CROSSBAR                ( BYPASS_CROSSBAR        )
							) u_TrgtAxi4WriteID                 
							(
								.ACLK                       ( ACLK                       ),
								.arst_sync                  ( arst_sync                  ),				// active low reset synchronoise to RE AClk - asserted async.
								.srst_sync                  ( srst_sync                  ),				// active low reset synchronoise to RE AClk - asserted async.
								
								//===================== Initiator to TARGET direction==================================
								//WRITE Request Chan	
								.int_targetAID			    ( int_targetAWID             ),	

								//WRITE REASPONSE Chan response
								.int_targetREADY		    ( int_targetBREADY           ),
								.int_targetVALID		    ( int_targetBVALID           ),
								
								//================= TARGET to Initiator direction ================================== 
								//WRITE RESPONSE Chan				
								.int_targetID		        ( int_targetBID              ),

								//WRITE Address Request Chan Response
								.int_targetAREADY	        ( int_targetAWREADY          ),
								.int_targetAVALID		    ( int_targetAWVALID          ),	
	
								//WRITE Address Request Chan
								.TARGET_AID			        ( TARGET_AWID                ),	
								.TARGET_AREADY		        ( TARGET_AWREADY             ),	
								.TARGET_AVALID		        ( TARGET_AWVALID             ),
				
								//WRITE RESPONSE Chan	
								.TARGET_VALID		        ( TARGET_BVALID              ),
								.TARGET_READY		        ( TARGET_BREADY              ),
								.TARGET_LAST		        ( 1'b1                       ),
								.TARGET_ID			        ( TARGET_BID                 )				
							); 


			end
		else if ( TARGET_TYPE == 2'b01) 		// AXI4-Lite Target type	
			begin

				//==========================================================================
				// Assign signals not used by AXI4Lite 
				//==========================================================================
				assign  TARGET_ARID 		= 0;
				assign  TARGET_ARLEN		= 0;
				assign  TARGET_ARSIZE	    = $clog2(DATA_WIDTH/8);  // andreag: set the transfer size to the full bus width (spec B1-123). Previously was tied to 0;
				assign  TARGET_ARBURST	    = 2'b01;
				assign  TARGET_ARLOCK	    = 0;
				assign  TARGET_ARCACHE	    = 0;
				assign 	TARGET_ARQOS		= 0;
				assign 	TARGET_ARUSER       = 0;

				assign  TARGET_AWID  		= 0;
				assign  TARGET_AWLEN		= 0;
				assign  TARGET_AWSIZE	    = $clog2(DATA_WIDTH/8);  // andreag: set the transfer size to the full bus width (spec B1-123). Previously was tied to 0;
				assign  TARGET_AWBURST	    = 2'b01;
				assign  TARGET_AWLOCK	    = 0;
				assign  TARGET_AWCACHE	    = 0;
				assign 	TARGET_AWQOS		= 0;
				assign  TARGET_AWUSER       = 0;

				assign TARGET_WID           = 0;
				assign TARGET_WUSER         = 0;			
				assign TARGET_WLAST 	    = 1'b1;			// always burst of 1	- set to 1 to allow models to work without change
				
				assign TARGET_AWREGION 	    = 0;		// TC: These signals exist, so need to be driven, though unused externally
				assign TARGET_ARREGION 	    = 0;		
				
 				caxi4interconnect_TrgtAxi4ProtocolConv #
							(
								.TARGET_NUMBER                  ( TARGET_NUMBER          ),		// target number
								.TARGET_TYPE                    ( 2'b01	                 ),		// AXI4Lite Target
								
								.ADDR_WIDTH                     ( ADDR_WIDTH             ),				
								.DATA_WIDTH                     ( DATA_WIDTH             ), 
								
								.USER_WIDTH                     ( USER_WIDTH             ),
								.ID_WIDTH                       ( ID_WIDTH               ),		// includes infrastructure ID								
								.TRGT_AXI4PRT_ADDRDEPTH 		( TRGT_AXI4PRT_ADDRDEPTH ),
								.TRGT_AXI4PRT_DATADEPTH 		( TRGT_AXI4PRT_DATADEPTH ),
								.MAX_TRANS                      ( 1                      ),
								.READ_INTERLEAVE                ( 1'b0                   ),
								.PIPE                           ( PIPE                   ),
								.PROTOCONV_RAM_TYPE             ( PROTOCONV_RAM_TYPE     ),
								.SYNC_RESET                     ( SYNC_RESET             ),
								.DWC_ENABLED                    ( DWC_ENABLED            )
							) u_AXILtePC 
							(
								.ACLK                       ( ACLK                ),
								.arst_sync                  ( arst_sync           ),				// active low reset synchronoise to RE AClk - asserted async.
								.srst_sync                  ( srst_sync           ),				// active low reset synchronoise to RE AClk - asserted async.
								
								//===================== Initiator to TARGET direction==================================
								//WRITE ADDRESS Chan
								.int_targetAWID			    ( int_targetAWID      ),	
								.int_targetAWADDR		    ( int_targetAWADDR    ),	
								.int_targetAWLEN			( int_targetAWLEN     ),	
								.int_targetAWSIZE		    ( int_targetAWSIZE    ),	
								.int_targetAWBURST		    ( int_targetAWBURST   ),	
								.int_targetAWLOCK		    ( int_targetAWLOCK    ),	
								.int_targetAWCACHE		    ( int_targetAWCACHE   ),	
								.int_targetAWPROT		    ( int_targetAWPROT    ),	
								.int_targetAWREGION		    ( int_targetAWREGION  ), 	
								.int_targetAWQOS			( int_targetAWQOS     ),	
								.int_targetAWUSER		    ( int_targetAWUSER    ),	
								.int_targetAWVALID		    ( int_targetAWVALID   ),	
								//WRITE DATA Chan
								.int_targetWDATA			( int_targetWDATA     ),	
								.int_targetWSTRB			( int_targetWSTRB     ),	
								.int_targetWLAST			( int_targetWLAST     ),	
								.int_targetWUSER			( int_targetWUSER     ),	
								.int_targetWVALID		    ( int_targetWVALID    ),	
								//WRITE RESPONSE Chan response
								.int_targetBREADY		    ( int_targetBREADY    ),
								//READ Request Chan	
								.int_targetARID			    ( int_targetARID      ),	
								.int_targetARADDR		    ( int_targetARADDR    ),	
								.int_targetARLEN			( int_targetARLEN     ),	
								.int_targetARSIZE		    ( int_targetARSIZE    ),	
								.int_targetARBURST		    ( int_targetARBURST   ),	
								.int_targetARLOCK		    ( int_targetARLOCK    ),	
								.int_targetARCACHE		    ( int_targetARCACHE   ),	
								.int_targetARPROT		    ( int_targetARPROT    ),	
								.int_targetARREGION		    ( int_targetARREGION  ), 	
								.int_targetARQOS			( int_targetARQOS     ),	
								.int_targetARUSER		    ( int_targetARUSER    ),	
								.int_targetARVALID		    ( int_targetARVALID   ),	
								
								//READ REASPONSE Chan response
								.int_targetRREADY		    ( int_targetRREADY    ),

								//================= TARGET to Initiator direction ================================== 
								//WRITE ADDRESS Chan response
								.int_targetAWREADY	        ( int_targetAWREADY   ),	
								//WRITE DATA Chan response
								.int_targetWREADY	        ( int_targetWREADY    ),	
								//WRITE RESPONSE Chan				
								.int_targetBID		        ( int_targetBID       ),	
								.int_targetBRESP		    ( int_targetBRESP     ),	
								.int_targetBUSER		    ( int_targetBUSER     ),	
								.int_targetBVALID	        ( int_targetBVALID    ),	
								//READ DATA Chan				
								.int_targetRID		        ( int_targetRID       ),	
								.int_targetRDATA		    ( int_targetRDATA     ),	
								.int_targetRRESP		    ( int_targetRRESP     ),	
								.int_targetRLAST		    ( int_targetRLAST     ),	
								.int_targetRUSER		    ( int_targetRUSER     ),	
								.int_targetRVALID	        ( int_targetRVALID    ),
								//READ Address Request Chan Response
								.int_targetARREADY	        ( int_targetARREADY   ),
								
								//WRITE ADDRESS Chan
								.TARGET_AWID			    (                     ),			
								.TARGET_AWADDR		        ( TARGET_AWADDR       ),	
								.TARGET_AWLEN		        (                     ),	
								.TARGET_AWSIZE		        (                     ),	
								.TARGET_AWBURST		        (                     ),	
								.TARGET_AWLOCK		        (                     ),	
								.TARGET_AWCACHE		        (                     ),	
								.TARGET_AWPROT		        ( TARGET_AWPROT       ),		
								.TARGET_AWVALID		        ( TARGET_AWVALID      ),	
								.TARGET_AWREADY		        ( TARGET_AWREADY      ),	  			
								
								//WRITE DATA Chan
								.TARGET_WDATA		        ( TARGET_WDATA        ),	
								.TARGET_WSTRB		        ( TARGET_WSTRB        ),	
								.TARGET_WLAST		        (                     ),		
								.TARGET_WVALID		        ( TARGET_WVALID       ),
								.TARGET_WREADY		        ( TARGET_WREADY       ),
								//WRITE RESPONSE Chan									
								.TARGET_BID			        ( 0                   ),	
								.TARGET_BRESP		        ( TARGET_BRESP        ),		
								.TARGET_BVALID		        ( TARGET_BVALID       ),	
								.TARGET_BREADY		        ( TARGET_BREADY       ),
								//READ Address Request Chan
								.TARGET_ARID			    (                     ),	
								.TARGET_ARADDR		        ( TARGET_ARADDR       ),	
								.TARGET_ARLEN		        (                     ),	
								.TARGET_ARSIZE		        (                     ),	
								.TARGET_ARBURST		        (                     ),	
								.TARGET_ARLOCK		        (                     ),	
								.TARGET_ARCACHE		        (                     ),	
								.TARGET_ARPROT		        ( TARGET_ARPROT       ),		
								.TARGET_ARVALID		        ( TARGET_ARVALID      ),			
								.TARGET_ARREADY		        ( TARGET_ARREADY      ),													
				
								//READ DATA Chan	
								.TARGET_RREADY		        ( TARGET_RREADY       ),
								.TARGET_RID			        ( 0                   ),				
								.TARGET_RDATA		        ( TARGET_RDATA        ),	
								.TARGET_RRESP		        ( TARGET_RRESP        ),	
								.TARGET_RLAST		        ( 1'b1                ),				// always burst of 1	
								.TARGET_RVALID		        ( TARGET_RVALID       )
							); 
 								
					end
					
		else //if ( TARGET_TYPE == 2'b11) 		// AXI4-AXI3 Target type	
			begin
			
				assign TARGET_AWLEN[7:4] = 0;	// tie upper bit to 0 as not used in AXI3
				assign TARGET_WUSER = 0;			// not used in AXI3

				assign TARGET_AWREGION = 0;		// just to pass protocol checker
				assign TARGET_AWQOS = 0;
				assign TARGET_AWUSER = 0;
			
				assign TARGET_ARREGION = 0;		// just to pass protocol checker
				assign TARGET_ARQOS = 0;
				assign TARGET_ARUSER = 0;
				
 				caxi4interconnect_TrgtAxi4ProtocolConv #
							(
								.TARGET_NUMBER                  ( TARGET_NUMBER          ),		// target number
								.TARGET_TYPE                    ( 2'b11	                 ),				// AXI3 Target

								.ID_WIDTH                       ( ID_WIDTH               ),		// includes infrastructure ID
								.ADDR_WIDTH                     ( ADDR_WIDTH             ),				
								.DATA_WIDTH                     ( DATA_WIDTH             ), 
								.USER_WIDTH                     ( USER_WIDTH             ),
								.TRGT_AXI4PRT_ADDRDEPTH 		( TRGT_AXI4PRT_ADDRDEPTH ),
								.TRGT_AXI4PRT_DATADEPTH 		( TRGT_AXI4PRT_DATADEPTH ),
								.MAX_TRANS 		                ( MAX_TRANS              ),
								.READ_INTERLEAVE                ( READ_INTERLEAVE        ),
								.PIPE                           ( PIPE                   ),
								.PROTOCONV_RAM_TYPE             ( PROTOCONV_RAM_TYPE     ),
								.SYNC_RESET                     ( SYNC_RESET             ),
								.DWC_ENABLED                    ( DWC_ENABLED            )
							) u_AXI3ProtConv 
							(
								.ACLK                       ( ACLK                ),
								.arst_sync                  ( arst_sync           ),				// active low reset synchronoise to RE AClk - asserted async.
								.srst_sync                  ( srst_sync           ),				// active low reset synchronoise to RE AClk - asserted async.
								
								//===================== Initiator to TARGET direction==================================
								//WRITE ADDRESS Chan
								.int_targetAWID			    ( int_targetAWID      ),	
								.int_targetAWADDR		    ( int_targetAWADDR    ),	
								.int_targetAWLEN			( int_targetAWLEN     ),	
								.int_targetAWSIZE		    ( int_targetAWSIZE    ),	
								.int_targetAWBURST		    ( int_targetAWBURST   ),	
								.int_targetAWLOCK		    ( int_targetAWLOCK    ),	
								.int_targetAWCACHE		    ( int_targetAWCACHE   ),	
								.int_targetAWPROT		    ( int_targetAWPROT    ),	
								.int_targetAWREGION		    ( int_targetAWREGION  ), 	
								.int_targetAWQOS			( int_targetAWQOS     ),	
								.int_targetAWUSER		    ( int_targetAWUSER    ),	
								.int_targetAWVALID		    ( int_targetAWVALID   ),	
								//WRITE DATA Chan
								.int_targetWID 			    ( int_targetWID       ),	
								.int_targetWDATA			( int_targetWDATA     ),	
								.int_targetWSTRB			( int_targetWSTRB     ),	
								.int_targetWLAST			( int_targetWLAST     ),	
								.int_targetWUSER			( int_targetWUSER     ),	
								.int_targetWVALID		    ( int_targetWVALID    ),	
								//WRITE RESPONSE Chan response
								.int_targetBREADY		    ( int_targetBREADY    ),
								//READ Request Chan	
								.int_targetARID			    ( int_targetARID      ),	
								.int_targetARADDR		    ( int_targetARADDR    ),	
								.int_targetARLEN			( int_targetARLEN     ),	
								.int_targetARSIZE		    ( int_targetARSIZE    ),	
								.int_targetARBURST		    ( int_targetARBURST   ),	
								.int_targetARLOCK		    ( int_targetARLOCK    ),	
								.int_targetARCACHE		    ( int_targetARCACHE   ),	
								.int_targetARPROT		    ( int_targetARPROT    ),	
								.int_targetARREGION		    ( int_targetARREGION  ), 	
								.int_targetARQOS			( int_targetARQOS     ),	
								.int_targetARUSER		    ( int_targetARUSER    ),	
								.int_targetARVALID		    ( int_targetARVALID   ),	
								
								//READ REASPONSE Chan response
								.int_targetRREADY		    ( int_targetRREADY    ),
//====================================TARGET to Initiator direction================================== 
								//WRITE ADDRESS Chan response
								.int_targetAWREADY		    ( int_targetAWREADY   ),	
								//WRITE DATA Chan response
								.int_targetWREADY		    ( int_targetWREADY    ),	
								//WRITE RESPONSE Chan				
								.int_targetBID			    ( int_targetBID       ),	
								.int_targetBRESP		    ( int_targetBRESP     ),	
								.int_targetBUSER		    ( int_targetBUSER     ),	
								.int_targetBVALID		    ( int_targetBVALID    ),	
								//READ DATA Chan				
								.int_targetRID			    ( int_targetRID       ),	
								.int_targetRDATA		    ( int_targetRDATA     ),	
								.int_targetRRESP		    ( int_targetRRESP     ),	
								.int_targetRLAST		    ( int_targetRLAST     ),	
								.int_targetRUSER		    ( int_targetRUSER     ),	
								.int_targetRVALID		    ( int_targetRVALID    ),
								//READ Address Request Chan Response
								.int_targetARREADY		    ( int_targetARREADY   ),
								
								//WRITE ADDRESS Chan
								.TARGET_AWID			    ( TARGET_AWID         ),	
								.TARGET_AWADDR		        ( TARGET_AWADDR       ),	
								.TARGET_AWLEN		        ( TARGET_AWLEN[3:0]   ),	
								.TARGET_AWSIZE		        ( TARGET_AWSIZE       ),	
								.TARGET_AWBURST		        ( TARGET_AWBURST      ),	
								.TARGET_AWLOCK		        ( TARGET_AWLOCK       ),	
								.TARGET_AWCACHE		        ( TARGET_AWCACHE      ),	
								.TARGET_AWPROT		        ( TARGET_AWPROT       ),		
								.TARGET_AWVALID		        ( TARGET_AWVALID      ),	
								.TARGET_AWREADY		        ( TARGET_AWREADY      ),	  			
								
								//WRITE DATA Chan
								.TARGET_WID			        ( TARGET_WID          ),
								.TARGET_WDATA		        ( TARGET_WDATA        ),	
								.TARGET_WSTRB		        ( TARGET_WSTRB        ),	
								.TARGET_WLAST		        ( TARGET_WLAST        ),		
								.TARGET_WVALID		        ( TARGET_WVALID       ),
								.TARGET_WREADY		        ( TARGET_WREADY       ),
								//WRITE RESPONSE Chan									
								.TARGET_BID			        ( TARGET_BID          ),	
								.TARGET_BRESP		        ( TARGET_BRESP        ),		
								.TARGET_BVALID		        ( TARGET_BVALID       ),	
								.TARGET_BREADY		        ( TARGET_BREADY       ),
								//READ Address Request Chan
								.TARGET_ARID			    ( TARGET_ARID         ),	
								.TARGET_ARADDR		        ( TARGET_ARADDR       ),	
								.TARGET_ARLEN		        ( TARGET_ARLEN        ),	
								.TARGET_ARSIZE		        ( TARGET_ARSIZE       ),	
								.TARGET_ARBURST		        ( TARGET_ARBURST      ),	
								.TARGET_ARLOCK		        ( TARGET_ARLOCK       ),	
								.TARGET_ARCACHE		        ( TARGET_ARCACHE      ),	
								.TARGET_ARPROT		        ( TARGET_ARPROT       ),		
								.TARGET_ARVALID		        ( TARGET_ARVALID      ),			
								.TARGET_ARREADY		        ( TARGET_ARREADY      ),													
				
								//READ DATA Chan	
								.TARGET_RREADY		        ( TARGET_RREADY       ),
								.TARGET_RID			        ( TARGET_RID          ),	
								.TARGET_RDATA		        ( TARGET_RDATA        ),	
								.TARGET_RRESP		        ( TARGET_RRESP        ),	
								.TARGET_RLAST		        ( TARGET_RLAST        ),	
								.TARGET_RVALID		        ( TARGET_RVALID       )
							); 
 								
					end

endgenerate
	
endmodule 
