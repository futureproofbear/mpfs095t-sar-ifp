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
module caxi4interconnect_IntrAHBtoAXI4Converter #

	(
		parameter integer 	ADDR_WIDTH      	= 20,			// valid values - 16 - 64
		parameter integer 	DATA_WIDTH 			= 32,			// valid widths - 32, 64, 128, 256
		
		parameter integer 	USER_WIDTH 			= 1,			// defines the number of bits for USER signals RUSER and WUSER

        parameter [7:0]		DEF_BURST_LEN		= 8'h1,
	
		parameter integer 	ID_WIDTH   			= 1,				// number of bits for ID (ie AID, WID, BID) - valid 1-8
        parameter [31:0]    BRESP_CNT_WIDTH     = 'h8,
        parameter [1:0]     BRESP_CHECK_MODE    = 2'b00 
		
	)
	(

	//=====================================  Global Signals   ========================================================================
    input  wire                     ACLK,
    input  wire                     iarst_sync,			// active low reset synchronoise to RE AClk - asserted async.
    input  wire                     isrst_sync,			// active low reset synchronoise to RE AClk - asserted async.
		
	output wire [ID_WIDTH-1:0] 		int_initiatorARID,
	output wire [ADDR_WIDTH-1:0]	int_initiatorARADDR,
	output wire [7:0]        		int_initiatorARLEN,
	output wire [2:0]          		int_initiatorARSIZE,
	output wire [1:0]          		int_initiatorARBURST,
	output wire [1:0]          		int_initiatorARLOCK,
	output wire [3:0]           	int_initiatorARCACHE,
	output wire [2:0]         		int_initiatorARPROT,
	output wire [3:0]          		int_initiatorARREGION,
	output wire [3:0]          		int_initiatorARQOS,
	output wire [USER_WIDTH-1:0]	int_initiatorARUSER,
	output wire            			int_initiatorARVALID,
	input wire             			int_initiatorARREADY,

	// Initiator Read Data Ports	
	input wire [ID_WIDTH-1:0]   	int_initiatorRID,
	input wire [DATA_WIDTH-1:0]		int_initiatorRDATA,
	input wire [1:0]           		int_initiatorRRESP,
	input wire                		int_initiatorRLAST,
	input wire [USER_WIDTH-1:0] 	int_initiatorRUSER,
	input wire                 		int_initiatorRVALID,
	output wire               		int_initiatorRREADY,

	// Initiator Write Address Ports	
	output wire [ID_WIDTH-1:0]  	int_initiatorAWID,
	output wire [ADDR_WIDTH-1:0] 	int_initiatorAWADDR,
	output wire [7:0]           	int_initiatorAWLEN,
	output wire [2:0]           	int_initiatorAWSIZE,
	output wire [1:0]           	int_initiatorAWBURST,
	output wire [1:0]           	int_initiatorAWLOCK,
	output wire [3:0]          		int_initiatorAWCACHE,
	output wire [2:0]           	int_initiatorAWPROT,
	output wire [3:0]            	int_initiatorAWREGION,
	output wire [3:0]           	int_initiatorAWQOS,
	output wire [USER_WIDTH-1:0]   	int_initiatorAWUSER,
	output wire                 	int_initiatorAWVALID,
	input wire                		int_initiatorAWREADY,
	
	// Initiator Write Data Ports	
	output wire [ID_WIDTH-1:0]      int_initiatorWID,
	output wire [DATA_WIDTH-1:0]  	int_initiatorWDATA,
	output wire [(DATA_WIDTH/8)-1:0]int_initiatorWSTRB,
	output wire                  	int_initiatorWLAST,
	output wire [USER_WIDTH-1:0] 	int_initiatorWUSER,
	output wire                  	int_initiatorWVALID,
	input wire                   	int_initiatorWREADY,
			
	// Initiator Write Response Ports	
	input  wire [ID_WIDTH-1:0]		int_initiatorBID,
	input  wire [1:0]           	int_initiatorBRESP,
	input  wire [USER_WIDTH-1:0] 	int_initiatorBUSER,
	input  wire      				int_initiatorBVALID,
	output wire						int_initiatorBREADY,

	//================================================= External Side Ports  ================================================//
        // AHB interface
	input wire[31:0]                INITIATOR_HADDR,
	input wire[2:0]                 INITIATOR_HBURST,
	input wire                      INITIATOR_HMASTLOCK,
	input wire[6:0]                 INITIATOR_HPROT,					
	input wire[2:0]                 INITIATOR_HSIZE,
	input wire                      INITIATOR_HNONSEC,
	input wire[1:0]                 INITIATOR_HTRANS,
	input wire[DATA_WIDTH-1:0]      INITIATOR_HWDATA,
	output wire[DATA_WIDTH-1:0]     INITIATOR_HRDATA,
	input wire                      INITIATOR_HWRITE,
//	input wire                      INITIATOR_HEXCL,
	input wire                      INITIATOR_HSEL,
	output wire                     INITIATOR_HREADY,
	output wire                     INITIATOR_HRESP
//	output wire INITIATOR_HEXOKAY

	);


	caxi4interconnect_AHB_SM_Undefburst #
			(
				.ID_WIDTH( ID_WIDTH ),
				.ADDR_WIDTH( ADDR_WIDTH ),				
				.DATA_WIDTH( DATA_WIDTH ),
                .LOG_BYTE_WIDTH( $clog2(DATA_WIDTH/8) ),
				.DEF_BURST_LEN( DEF_BURST_LEN ),
				.USER_WIDTH( USER_WIDTH ),
                .BRESP_CNT_WIDTH ( BRESP_CNT_WIDTH ),
				.BRESP_CHECK_MODE( BRESP_CHECK_MODE )
			)
	AHB_SM_i (
				// Global Signals
				.ACLK( ACLK ),
				.iarst_sync( iarst_sync ),	
				.isrst_sync( isrst_sync ),	

				// AHB interface							
				.INITIATOR_HADDR			( INITIATOR_HADDR ),
				.INITIATOR_HBURST			( INITIATOR_HBURST ),
				.INITIATOR_HMASTLOCK			( INITIATOR_HMASTLOCK ),
				.INITIATOR_HPROT			( INITIATOR_HPROT ),					
				.INITIATOR_HSIZE			( INITIATOR_HSIZE ),
				.INITIATOR_HNONSEC			( INITIATOR_HNONSEC ),
				.INITIATOR_HTRANS			( INITIATOR_HTRANS ),
				.INITIATOR_HWDATA			( INITIATOR_HWDATA ),
				.INITIATOR_HRDATA			( INITIATOR_HRDATA ),
				.INITIATOR_HWRITE			( INITIATOR_HWRITE ),
				.INITIATOR_HREADY			( INITIATOR_HREADY),
				.INITIATOR_HSEL			( INITIATOR_HSEL ),
				.INITIATOR_HRESP			( INITIATOR_HRESP ),
//				.INITIATOR_HEXOKAY			( INITIATOR_HEXOKAY ),
//				.INITIATOR_HEXCL			( INITIATOR_HEXCL ),


				// AXI4 interface
				.int_initiatorARID			( int_initiatorARID ),
				.int_initiatorARADDR		( int_initiatorARADDR ),
				.int_initiatorARLEN		( int_initiatorARLEN ),
				.int_initiatorARSIZE		( int_initiatorARSIZE ),
				.int_initiatorARBURST		( int_initiatorARBURST ),
				.int_initiatorARLOCK		( int_initiatorARLOCK ),
				.int_initiatorARCACHE		( int_initiatorARCACHE ),
				.int_initiatorARPROT		( int_initiatorARPROT ),
				.int_initiatorARREGION		( int_initiatorARREGION ),
				.int_initiatorARQOS		( int_initiatorARQOS ),
				.int_initiatorARUSER		( int_initiatorARUSER ),
				.int_initiatorARVALID		( int_initiatorARVALID ),
				.int_initiatorAWQOS		( int_initiatorAWQOS ),
				.int_initiatorAWREGION		( int_initiatorAWREGION ),
				.int_initiatorAWID			( int_initiatorAWID ),
				.int_initiatorAWADDR		( int_initiatorAWADDR ),
				.int_initiatorAWLEN		( int_initiatorAWLEN ),
				.int_initiatorAWSIZE		( int_initiatorAWSIZE ),
				.int_initiatorAWBURST		( int_initiatorAWBURST ),
				.int_initiatorAWLOCK		( int_initiatorAWLOCK ),
				.int_initiatorAWCACHE		( int_initiatorAWCACHE ),
				.int_initiatorAWPROT		( int_initiatorAWPROT ),
				.int_initiatorAWUSER		( int_initiatorAWUSER ),
				.int_initiatorAWVALID		( int_initiatorAWVALID ),
				.int_initiatorWID		    ( int_initiatorWID ),
				.int_initiatorWDATA		( int_initiatorWDATA ),
				.int_initiatorWSTRB		( int_initiatorWSTRB ),
				.int_initiatorWLAST		( int_initiatorWLAST ),
				.int_initiatorWUSER		( int_initiatorWUSER ),
				.int_initiatorWVALID		( int_initiatorWVALID ),
				.int_initiatorBREADY		( int_initiatorBREADY ),
				.int_initiatorRREADY		( int_initiatorRREADY ),
				.int_initiatorARREADY 		( int_initiatorARREADY ),
				.int_initiatorRID 			( int_initiatorRID ),
				.int_initiatorRDATA 		( int_initiatorRDATA ),
				.int_initiatorRRESP 		( int_initiatorRRESP ),
				.int_initiatorRUSER 		( int_initiatorRUSER ),
				.int_initiatorBID 			( int_initiatorBID ),
				.int_initiatorBRESP 		( int_initiatorBRESP ),
				.int_initiatorBUSER 		( int_initiatorBUSER ),
				.int_initiatorRLAST 		( int_initiatorRLAST ),
				.int_initiatorRVALID 		( int_initiatorRVALID ),
				.int_initiatorAWREADY 		( int_initiatorAWREADY ),
				.int_initiatorWREADY 		( int_initiatorWREADY ),
				.int_initiatorBVALID 		( int_initiatorBVALID )

			); 

endmodule
