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

module caxi4interconnect_TrgtAxi4ProtocolConv #
       
	(
		parameter integer 	TARGET_NUMBER			= 0,		//current target
		parameter [1:0] 	TARGET_TYPE				= 2'b11,	// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11	
		
		parameter integer 	ADDR_WIDTH      		= 20,		// valid values - 16 - 64
		parameter integer 	DATA_WIDTH 				= 32,		// valid widths - 32, 64, 128, 256
		
		parameter integer 	USER_WIDTH 				= 1,		// defines the number of bits for USER signals RUSER and WUSER
	
		parameter integer 	ID_WIDTH   				= 1,		// number of bits for ID (ie AID, WID, BID) - valid 1-8 
		parameter integer 	TRGT_AXI4PRT_ADDRDEPTH	= 8,		// Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
		parameter integer 	TRGT_AXI4PRT_DATADEPTH	= 8,			// Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
		parameter integer 	MAX_TRANS           	= 8,			// Maximum transactions 
		parameter           READ_INTERLEAVE         = 1,
		parameter           PIPE                    = 0,
		parameter           PROTOCONV_RAM_TYPE      = 3,
		parameter           SYNC_RESET              = 0,
		parameter           DWC_ENABLED             = 0             // 1 - DWC enabled, filter dummy (WSTRB=0) responses
	)
	(

	//=====================================  Global Signals   ========================================================================
	input  wire           			ACLK,
	input  wire          			arst_sync,
	input  wire          			srst_sync,
	
	// External side
	//Target Read Address Ports
	output wire [ID_WIDTH-1:0]  	TARGET_ARID,
	output wire [ADDR_WIDTH-1:0]	TARGET_ARADDR,
	output wire [7:0]           	TARGET_ARLEN,
	output wire [2:0]        		TARGET_ARSIZE,
	output wire [1:0]           	TARGET_ARBURST,
	output wire [1:0]         		TARGET_ARLOCK,
	output wire [2:0]         		TARGET_ARPROT,
	output wire [3:0]  	        	TARGET_ARCACHE,
	output wire            			TARGET_ARVALID,
	
	input wire             			TARGET_ARREADY,


	// Target Read Data Ports
	input wire [ID_WIDTH-1:0]  		TARGET_RID,	
	input wire [DATA_WIDTH-1:0]		TARGET_RDATA,
	input wire [1:0]           		TARGET_RRESP,
	input wire                  	TARGET_RLAST,
	input wire                 		TARGET_RVALID,
	
	output wire               		TARGET_RREADY,
  

	// Target Write Address Ports
	output wire [ID_WIDTH-1:0]   	TARGET_AWID,	
	output wire [ADDR_WIDTH-1:0] 	TARGET_AWADDR,
	output wire [3:0]           	TARGET_AWLEN,
	output wire [2:0]           	TARGET_AWSIZE,
	output wire [1:0]           	TARGET_AWBURST,
	output wire [1:0]            	TARGET_AWLOCK,
	output wire [3:0]          		TARGET_AWCACHE,
	output wire [2:0]           	TARGET_AWPROT,
	output wire	                 	TARGET_AWVALID,
	
	input wire                		TARGET_AWREADY,

	
	// Target Write Data Ports	
	output wire [ID_WIDTH-1:0]   	TARGET_WID,	
	output wire [DATA_WIDTH-1:0]  	TARGET_WDATA,
	output wire [(DATA_WIDTH/8)-1:0] TARGET_WSTRB,
	output wire                   	TARGET_WLAST,
	output wire                  	TARGET_WVALID,
	
	input wire                   	TARGET_WREADY,

			
	// Target Write Response Ports	
	input wire [ID_WIDTH-1:0]		TARGET_BID,
	input  wire [1:0]           	TARGET_BRESP,
	input  wire      				TARGET_BVALID,
	
	output wire						TARGET_BREADY,


	//================================================= Internal (XBar) Side Ports  ================================================//

	// Target Read Address Ports	
	input  wire [ID_WIDTH-1:0]  	int_targetARID,
	input  wire [ADDR_WIDTH-1:0]	int_targetARADDR,
	input  wire [7:0]           	int_targetARLEN,
	input  wire [2:0]        		int_targetARSIZE,
	input  wire [1:0]           	int_targetARBURST,
	input  wire [1:0]         		int_targetARLOCK,
	input  wire [3:0]          		int_targetARCACHE,
	input  wire [2:0]         		int_targetARPROT,
	input  wire [3:0]          		int_targetARREGION,
	input  wire [3:0]          		int_targetARQOS,
	input  wire [USER_WIDTH-1:0]	int_targetARUSER,
	input  wire                		int_targetARVALID,
	
	output wire                		int_targetARREADY,
	
	// Target Read Data Ports	
	output wire [ID_WIDTH-1:0]  	int_targetRID,
	output wire [DATA_WIDTH-1:0]  	int_targetRDATA,
	output wire [1:0]           	int_targetRRESP,
	output wire                  	int_targetRLAST,
	output wire [USER_WIDTH-1:0] 	int_targetRUSER,
	output wire               		int_targetRVALID,
	
	input wire                 		int_targetRREADY,
	
	// Target Write Address Ports	
	input  wire [ID_WIDTH-1:0]   	int_targetAWID,
	input  wire [ADDR_WIDTH-1:0] 	int_targetAWADDR,
	input  wire [7:0]           	int_targetAWLEN,
	input  wire [2:0]           	int_targetAWSIZE,
	input  wire [1:0]           	int_targetAWBURST,
	input  wire [1:0]            	int_targetAWLOCK,
	input  wire [3:0]          		int_targetAWCACHE,
	input  wire [2:0]           	int_targetAWPROT,
	input  wire [3:0]           	int_targetAWREGION,
	input  wire [3:0]           	int_targetAWQOS,
	input  wire [USER_WIDTH-1:0] 	int_targetAWUSER,
	input  wire                  	int_targetAWVALID,
	output wire                		int_targetAWREADY,
	
	// Target Write Data Ports	
	input wire [ID_WIDTH-1:0]   	int_targetWID,
	input wire [DATA_WIDTH-1:0]   	int_targetWDATA,
	input wire [(DATA_WIDTH/8)-1:0]	int_targetWSTRB,
	input wire                   	int_targetWLAST,
	input wire [USER_WIDTH-1:0] 	int_targetWUSER,
	input wire                  	int_targetWVALID,
	output wire                  	int_targetWREADY,
	
	// Target Write Response Ports	
	output wire [ID_WIDTH-1:0]		int_targetBID,
	output wire [1:0]           	int_targetBRESP,
	output wire [USER_WIDTH-1:0]  	int_targetBUSER,
	output wire      				int_targetBVALID,
	input wire						int_targetBREADY
	
	
	);

	//===================================================================================

	caxi4interconnect_TrgtAxi4ProtConvWrite #

		(
			.TARGET_NUMBER 		        ( TARGET_NUMBER          ),	
			.TARGET_TYPE			    ( TARGET_TYPE            ),
			.ADDR_WIDTH 		        ( ADDR_WIDTH             ),		
			.DATA_WIDTH 		        ( DATA_WIDTH             ),
			.USER_WIDTH 		        ( USER_WIDTH             ),
			.ID_WIDTH 			        ( ID_WIDTH               ),
			.TRGT_AXI4PRT_ADDRDEPTH 	( TRGT_AXI4PRT_ADDRDEPTH ),
			.TRGT_AXI4PRT_DATADEPTH 	( TRGT_AXI4PRT_DATADEPTH ),
			.MAX_TRANS 		            ( MAX_TRANS              ),
			.READ_INTERLEAVE 		    ( READ_INTERLEAVE        ),
			.PIPE 		                ( PIPE                   ),
			.PROTOCONV_RAM_TYPE         ( PROTOCONV_RAM_TYPE     ),
			.SYNC_RESET           	    ( SYNC_RESET             ),
			.DWC_ENABLED                ( DWC_ENABLED            )
		) TrgtPCWr                      
		(
			.ACLK 				        ( ACLK                   ),
			.arst_sync 			        ( arst_sync              ),
			.srst_sync 			        ( srst_sync              ),
									    
			.TARGET_AWID 		        ( TARGET_AWID            ),	
			.TARGET_AWADDR 		        ( TARGET_AWADDR          ),
			.TARGET_AWLEN 		        ( TARGET_AWLEN           ),
			.TARGET_AWSIZE 		        ( TARGET_AWSIZE          ),
			.TARGET_AWBURST 	        ( TARGET_AWBURST         ),
			.TARGET_AWLOCK 		        ( TARGET_AWLOCK          ),
			.TARGET_AWCACHE 	        ( TARGET_AWCACHE         ),
			.TARGET_AWPROT 		        ( TARGET_AWPROT          ),
			.TARGET_AWVALID 	        ( TARGET_AWVALID         ),
			.TARGET_AWREADY 	        ( TARGET_AWREADY         ),	
			.TARGET_WID 		        ( TARGET_WID             ),	
			.TARGET_WDATA 		        ( TARGET_WDATA           ),
			.TARGET_WSTRB 		        ( TARGET_WSTRB           ),
			.TARGET_WLAST 		        ( TARGET_WLAST           ),
			.TARGET_WVALID 		        ( TARGET_WVALID          ),
			.TARGET_WREADY 		        ( TARGET_WREADY          ),	
			.TARGET_BID 		        ( TARGET_BID             ),
			.TARGET_BRESP 		        ( TARGET_BRESP           ),
			.TARGET_BVALID 		        ( TARGET_BVALID          ),
			.TARGET_BREADY 		        ( TARGET_BREADY          ),
			.int_targetAWID 		    ( int_targetAWID         ),
			.int_targetAWADDR	        ( int_targetAWADDR       ),
			.int_targetAWLEN 	        ( int_targetAWLEN        ),
			.int_targetAWSIZE	        ( int_targetAWSIZE       ),
			.int_targetAWBURST	        ( int_targetAWBURST      ),
			.int_targetAWLOCK 	        ( int_targetAWLOCK       ),
			.int_targetAWCACHE 	        ( int_targetAWCACHE      ),
			.int_targetAWPROT 	        ( int_targetAWPROT       ),
			.int_targetAWREGION 	    ( int_targetAWREGION     ),
			.int_targetAWQOS 	        ( int_targetAWQOS        ),
			.int_targetAWUSER 	        ( int_targetAWUSER       ),
			.int_targetAWVALID 	        ( int_targetAWVALID      ),
			.int_targetAWREADY 	        ( int_targetAWREADY      ),
			.int_targetWID    	        ( int_targetWID          ),
			.int_targetWDATA 	        ( int_targetWDATA        ),
			.int_targetWSTRB 	        ( int_targetWSTRB        ),
			.int_targetWLAST 	        ( int_targetWLAST        ),
			.int_targetWUSER 	        ( int_targetWUSER        ),
			.int_targetWVALID 	        ( int_targetWVALID       ),
			.int_targetWREADY 	        ( int_targetWREADY       ),	
			.int_targetBID 		        ( int_targetBID          ),
			.int_targetBRESP		    ( int_targetBRESP        ),
			.int_targetBUSER 	        ( int_targetBUSER        ),
			.int_targetBVALID 	        ( int_targetBVALID       ),
			.int_targetBREADY 	        ( int_targetBREADY       )
	    );  
	
	
	//==========================================================================

	caxi4interconnect_TrgtAxi4ProtConvRead #
		(
			.TARGET_NUMBER 		            ( TARGET_NUMBER          ),
			.TARGET_TYPE		            ( TARGET_TYPE            ),			
			.ADDR_WIDTH 		            ( ADDR_WIDTH             ),		
			.DATA_WIDTH 		            ( DATA_WIDTH             ),
			.USER_WIDTH 		            ( USER_WIDTH             ),
			.ID_WIDTH 			            ( ID_WIDTH               ),
			.TRGT_AXI4PRT_ADDRDEPTH 		( TRGT_AXI4PRT_ADDRDEPTH ),
			.TRGT_AXI4PRT_DATADEPTH 		( TRGT_AXI4PRT_DATADEPTH ),
			.READ_INTERLEAVE    		    ( READ_INTERLEAVE        ),
            .PIPE                           ( PIPE                   ),
            .PROTOCONV_RAM_TYPE             ( PROTOCONV_RAM_TYPE     ),
	      	.SYNC_RESET                     ( SYNC_RESET             )
        ) TrgtPCRd 
		(
	
			.ACLK 				            ( ACLK                   ),
			.arst_sync 			            ( arst_sync              ),
			.srst_sync 			            ( srst_sync              ),
	
			.TARGET_ARID 		            ( TARGET_ARID            ),
			.TARGET_ARADDR 		            ( TARGET_ARADDR          ),
			.TARGET_ARLEN 		            ( TARGET_ARLEN           ),
			.TARGET_ARSIZE 		            ( TARGET_ARSIZE          ),
			.TARGET_ARBURST 	            ( TARGET_ARBURST         ),
			.TARGET_ARLOCK 		            ( TARGET_ARLOCK          ),
			.TARGET_ARPROT 		            ( TARGET_ARPROT          ),
			.TARGET_ARCACHE 	            ( TARGET_ARCACHE         ),
			.TARGET_ARVALID 	            ( TARGET_ARVALID         ),
			.TARGET_ARREADY 	            ( TARGET_ARREADY         ),
			.TARGET_RID 		            ( TARGET_RID             ),	
			.TARGET_RDATA 		            ( TARGET_RDATA           ),
			.TARGET_RRESP 		            ( TARGET_RRESP           ),
			.TARGET_RLAST 		            ( TARGET_RLAST           ),
			.TARGET_RVALID 		            ( TARGET_RVALID          ),
			.TARGET_RREADY 		            ( TARGET_RREADY          ),
			.int_targetARID 		        ( int_targetARID         ),
			.int_targetARADDR 	            ( int_targetARADDR       ),
			.int_targetARLEN 	            ( int_targetARLEN        ),
			.int_targetARSIZE 	            ( int_targetARSIZE       ),
			.int_targetARBURST 	            ( int_targetARBURST      ),
			.int_targetARLOCK 	            ( int_targetARLOCK       ),
			.int_targetARCACHE 	            ( int_targetARCACHE      ),
			.int_targetARPROT 	            ( int_targetARPROT       ),
			.int_targetARREGION 	        ( int_targetARREGION     ),
			.int_targetARQOS 	            ( int_targetARQOS        ),
			.int_targetARUSER 	            ( int_targetARUSER       ),
			.int_targetARVALID 	            ( int_targetARVALID      ),
			.int_targetARREADY 	            ( int_targetARREADY      ),
			.int_targetRID 		            ( int_targetRID          ),
			.int_targetRDATA 	            ( int_targetRDATA        ),
			.int_targetRRESP 	            ( int_targetRRESP        ),
			.int_targetRLAST 	            ( int_targetRLAST        ),
			.int_targetRUSER 	            ( int_targetRUSER        ),
			.int_targetRVALID 	            ( int_targetRVALID       ),
			.int_targetRREADY 	            ( int_targetRREADY       )
	    );

//==========================================================================

	
	
endmodule	// caxi4interconnect_TrgtAxi4ProtocolConv
