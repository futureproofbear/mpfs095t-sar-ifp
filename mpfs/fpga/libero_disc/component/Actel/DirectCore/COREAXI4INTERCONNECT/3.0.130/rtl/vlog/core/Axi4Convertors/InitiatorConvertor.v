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

module caxi4interconnect_InitiatorConvertor #

	(
		parameter [1:0]   INITIATOR_TYPE		        = 2'b10,	// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11, AHB - 2'b10
		parameter         INITIATOR_NUMBER	            = 0,		// Initiator number
		parameter  	      AWCHAN_RS		                = 0,		// 0 means no slice on channel - 1 means full slice on channel
		parameter  	      ARCHAN_RS		                = 0,		// 0 means no slice on channel - 1 means full slice on channel
		parameter  	      RCHAN_RS		                = 0,		// 0 means no slice on channel - 1 means full slice on channel
		parameter  	      WCHAN_RS		                = 0,		// 0 means no slice on channel - 1 means full slice on channel
		parameter  	      BCHAN_RS		                = 0,		// 0 means no slice on channel - 1 means full slice on channel
		parameter  	      DWC_CHAN_RS                   = 0,		// 0 means no slice on channel - 1 means full slice on channel
		parameter integer MAX_TRANS     				= 2,	// max number of outstanding transactions per thread - valid range 1-8
		parameter integer ID_WIDTH   			        = 1, 

		parameter integer ADDR_WIDTH      		        = 20,
		parameter integer DATA_WIDTH 			        = 16, 
		parameter integer INITIATOR_DATA_WIDTH		    = 32,

        parameter [7:0]	  DEF_BURST_LEN		            = 8'h1,

		parameter integer SUPPORT_USER_SIGNALS 	        = 0,
		parameter integer USER_WIDTH 			        = 1,
		parameter [13:0]  DWC_DATA_FIFO_DEPTH           = 14'h10,
  	    parameter integer DWC_ADDR_FIFO_DEPTH           = 'h10,
	    parameter         CLOCK_DOMAIN_CROSSING         = 1'b0,
	    parameter         CDC_FIFO_DEPTH                = 16,
	    parameter         CDC_ADDR_RESP_FIFO_DEPTH      = 1,
        parameter [31:0]  AHB_BRESP_CNT_WIDTH           = 'h8,
	    parameter [1:0]   AHB_BRESP_CHECK_MODE          = 2'b0,
	    parameter         READ_INTERLEAVE               = 1,
		parameter         PIPE                          = 0,
		parameter         DWC_RAM_TYPE                  = 3,
		parameter         CDC_RAM_TYPE                  = 3,
		parameter         SYNC_RESET                    = 0,
		parameter         NUM_STAGES                    = 2,
		parameter [3:0]   NUM_RS_STAGES                 = 0,
		parameter integer FAMILY                        = 26,
		parameter         EXPOSE_RST                    = 0,
		parameter         CDC_PLACEMENT                 = 0
		
	)
	(

	//=====================================  Global Signals   ========================================================================
	input  wire           			INITR_CLK,
	input  wire                     XBAR_CLK,
	input  wire          			ARESETN,
	input  wire          			arst_sync,
	input  wire          			srst_sync,
	output wire                     i_sync_rstn,
 
	//=====================================  Connections to/from Crossbar   ==========================================================
 
	output wire [ID_WIDTH-1:0] 		    int_initiatorARID,
	output wire [ADDR_WIDTH-1:0]	    int_initiatorARADDR,
	output wire [7:0]        		    int_initiatorARLEN,
	output wire [2:0]          		    int_initiatorARSIZE,
	output wire [1:0]          		    int_initiatorARBURST,
	output wire [1:0]          		    int_initiatorARLOCK,
	output wire [3:0]           	    int_initiatorARCACHE,
	output wire [2:0]         		    int_initiatorARPROT,
	output wire [3:0]          		    int_initiatorARREGION,
	output wire [3:0]          		    int_initiatorARQOS,
	output wire [USER_WIDTH-1:0]	    int_initiatorARUSER,
	output wire            			    int_initiatorARVALID,
	input wire             			    int_initiatorARREADY,

	// Initiator Read Data Ports	
	input wire [ID_WIDTH-1:0]   	    int_initiatorRID,
	input wire [DATA_WIDTH-1:0]		    int_initiatorRDATA,
	input wire [1:0]           		    int_initiatorRRESP,
	input wire                		    int_initiatorRLAST,
	input wire [USER_WIDTH-1:0] 	    int_initiatorRUSER,
	input wire                 		    int_initiatorRVALID,
	output wire               		    int_initiatorRREADY,

	// Initiator Write Address Ports	
	output wire [ID_WIDTH-1:0]  	    int_initiatorAWID,
	output wire [ADDR_WIDTH-1:0] 	    int_initiatorAWADDR,
	output wire [7:0]           	    int_initiatorAWLEN,
	output wire [2:0]           	    int_initiatorAWSIZE,
	output wire [1:0]           	    int_initiatorAWBURST,
	output wire [1:0]           	    int_initiatorAWLOCK,
	output wire [3:0]          		    int_initiatorAWCACHE,
	output wire [2:0]           	    int_initiatorAWPROT,
	output wire [3:0]            	    int_initiatorAWREGION,
	output wire [3:0]           	    int_initiatorAWQOS,
	output wire [USER_WIDTH-1:0]   	    int_initiatorAWUSER,
	output wire                 	    int_initiatorAWVALID,
	input wire                		    int_initiatorAWREADY,
	
	// Initiator Write Data Ports	
	output wire [ID_WIDTH-1:0]  		int_initiatorWID,
	output wire [DATA_WIDTH-1:0]  		int_initiatorWDATA,
	output wire [(DATA_WIDTH/8)-1:0]	int_initiatorWSTRB,
	output wire                  		int_initiatorWLAST,
	output wire [USER_WIDTH-1:0] 		int_initiatorWUSER,
	output wire                  		int_initiatorWVALID,
	input wire                   		int_initiatorWREADY,
			
	// Initiator Write Response Ports	
	input  wire [ID_WIDTH-1:0]		    int_initiatorBID,
	input  wire [1:0]           	    int_initiatorBRESP,
	input  wire [USER_WIDTH-1:0] 	    int_initiatorBUSER,
	input  wire      				    int_initiatorBVALID,
	output wire						    int_initiatorBREADY,

	//================================================= External Side Ports  ================================================//

	// Initiator Read Address Ports	
	input  wire [ID_WIDTH-1:0]  	            INITIATOR_ARID,
	input  wire [ADDR_WIDTH-1:0]	            INITIATOR_ARADDR,
	input  wire [7:0]           	            INITIATOR_ARLEN,
	input  wire [2:0]        		            INITIATOR_ARSIZE,
	input  wire [1:0]           	            INITIATOR_ARBURST,
	input  wire [1:0]         		            INITIATOR_ARLOCK,
	input  wire [3:0]          		            INITIATOR_ARCACHE,
	input  wire [2:0]         		            INITIATOR_ARPROT,
	input  wire [3:0]          		            INITIATOR_ARREGION,
	input  wire [3:0]          		            INITIATOR_ARQOS,
	input  wire [USER_WIDTH-1:0]	            INITIATOR_ARUSER,
	input  wire                		            INITIATOR_ARVALID,
	output wire                		            INITIATOR_ARREADY,
	
	// Initiator Read Data Ports	
	output wire [ID_WIDTH-1:0]  	            INITIATOR_RID,
	output wire [INITIATOR_DATA_WIDTH-1:0]      INITIATOR_RDATA,
	output wire [1:0]           	            INITIATOR_RRESP,
	output wire                  	            INITIATOR_RLAST,
	output wire [USER_WIDTH-1:0] 	            INITIATOR_RUSER,
	output wire               		            INITIATOR_RVALID,
	input wire                 		            INITIATOR_RREADY,
	
	// Initiator Write Address Ports	
	input  wire [ID_WIDTH-1:0]   	            INITIATOR_AWID,
	input  wire [ADDR_WIDTH-1:0] 	            INITIATOR_AWADDR,
	input  wire [7:0]           	            INITIATOR_AWLEN,
	input  wire [2:0]           	            INITIATOR_AWSIZE,
	input  wire [1:0]           	            INITIATOR_AWBURST,
	input  wire [1:0]            	            INITIATOR_AWLOCK,
	input  wire [3:0]          		            INITIATOR_AWCACHE,
	input  wire [2:0]           	            INITIATOR_AWPROT,
	input  wire [3:0]           	            INITIATOR_AWREGION,
	input  wire [3:0]           	            INITIATOR_AWQOS,
	input  wire [USER_WIDTH-1:0] 	            INITIATOR_AWUSER,
	input  wire                  	            INITIATOR_AWVALID,
	output wire                		            INITIATOR_AWREADY,
	
	// Initiator Write Data Ports	
	input wire [ID_WIDTH-1:0]		            INITIATOR_WID,
	input wire [INITIATOR_DATA_WIDTH-1:0]   	INITIATOR_WDATA,
	input wire [(INITIATOR_DATA_WIDTH/8)-1:0]	INITIATOR_WSTRB,
	input wire                   	            INITIATOR_WLAST,
	input wire [USER_WIDTH-1:0] 	            INITIATOR_WUSER,
	input wire                  	            INITIATOR_WVALID,
	output wire                  	            INITIATOR_WREADY,
	
	// Initiator Write Response Ports	
	output wire [ID_WIDTH-1:0]		            INITIATOR_BID,
	output wire [1:0]           	            INITIATOR_BRESP,
	output wire [USER_WIDTH-1:0]  	            INITIATOR_BUSER,
	output wire      				            INITIATOR_BVALID,
	input wire						            INITIATOR_BREADY,

        // AHB interface
	input wire[31:0]                            INITIATOR_HADDR,
	input wire[2:0]                             INITIATOR_HBURST,
	input wire                                  INITIATOR_HMASTLOCK,
	input wire[6:0]                             INITIATOR_HPROT,					
	input wire[2:0]                             INITIATOR_HSIZE,
	input wire                                  INITIATOR_HNONSEC,
	input wire[1:0]                             INITIATOR_HTRANS,
	input wire[INITIATOR_DATA_WIDTH-1:0]        INITIATOR_HWDATA,
	output wire[INITIATOR_DATA_WIDTH-1:0]       INITIATOR_HRDATA,
	input wire                                  INITIATOR_HWRITE,
	output wire                                 INITIATOR_HREADY,
	output wire                                 INITIATOR_HRESP,
	input wire                                  INITIATOR_HSEL
//	input wire                                  INITIATOR_HEXCL

	) ;


    localparam             DWC_CHAN_RS_EN = (DATA_WIDTH != INITIATOR_DATA_WIDTH) ? DWC_CHAN_RS : 1'b0;
	
	wire INITIATOR_HEXOKAY;

	wire	iarst_sync;
	wire	isrst_sync;

	//===================================== Internal wires =======================================//
	//wires between SliceReg block and ClockDomainCrossing

	 wire [ID_WIDTH-1:0] 		            prot_cdc_initiatorARID;
	 wire [ADDR_WIDTH-1:0]		            prot_cdc_initiatorARADDR;
	 wire [7:0]        			            prot_cdc_initiatorARLEN;
	 wire [2:0]          		            prot_cdc_initiatorARSIZE;
	 wire [1:0]          		            prot_cdc_initiatorARBURST;
	 wire [1:0]          		            prot_cdc_initiatorARLOCK;
	 wire [3:0]           		            prot_cdc_initiatorARCACHE;
	 wire [2:0]         		            prot_cdc_initiatorARPROT;
	 wire [3:0]          		            prot_cdc_initiatorARREGION;
	 wire [3:0]          		            prot_cdc_initiatorARQOS;
	 wire [USER_WIDTH-1:0]		            prot_cdc_initiatorARUSER;
	 wire            			            prot_cdc_initiatorARVALID;
	 wire             			            prot_cdc_initiatorARREADY;

	// Initiator Read Data Ports	
	 wire [ID_WIDTH-1:0]   		            prot_cdc_initiatorRID;
	 wire [INITIATOR_DATA_WIDTH-1:0]        prot_cdc_initiatorRDATA;
	 wire [1:0]           		            prot_cdc_initiatorRRESP;
	 wire                		            prot_cdc_initiatorRLAST;
	 wire [USER_WIDTH-1:0] 		            prot_cdc_initiatorRUSER;
	 wire                 		            prot_cdc_initiatorRVALID;
	 wire               		            prot_cdc_initiatorRREADY;

	// Initiator Write Address Ports	
	 wire [ID_WIDTH-1:0]  		            prot_cdc_initiatorAWID;
	 wire [ADDR_WIDTH-1:0] 		            prot_cdc_initiatorAWADDR;
	 wire [7:0]           		            prot_cdc_initiatorAWLEN;
	 wire [2:0]           		            prot_cdc_initiatorAWSIZE;
	 wire [1:0]           		            prot_cdc_initiatorAWBURST;
	 wire [1:0]           		            prot_cdc_initiatorAWLOCK;
	 wire [3:0]          		            prot_cdc_initiatorAWCACHE;
	 wire [2:0]           		            prot_cdc_initiatorAWPROT;
	 wire [3:0]            		            prot_cdc_initiatorAWREGION;
	 wire [3:0]           		            prot_cdc_initiatorAWQOS;
	 wire [USER_WIDTH-1:0]  	            prot_cdc_initiatorAWUSER;
	 wire                 		            prot_cdc_initiatorAWVALID;
	 wire                		            prot_cdc_initiatorAWREADY;
	
	// Initiator Write Data Ports	
	 wire [ID_WIDTH-1:0]                    prot_cdc_initiatorWID;
	 wire [INITIATOR_DATA_WIDTH-1:0]  	    prot_cdc_initiatorWDATA;
	 wire [(INITIATOR_DATA_WIDTH/8)-1:0]	prot_cdc_initiatorWSTRB;
	 wire                  		            prot_cdc_initiatorWLAST;
	 wire [USER_WIDTH-1:0] 		            prot_cdc_initiatorWUSER;
	 wire                  		            prot_cdc_initiatorWVALID;
	 wire                   	            prot_cdc_initiatorWREADY;
			
	// Initiator Write Response Ports	
	 wire [ID_WIDTH-1:0]		            prot_cdc_initiatorBID;
	 wire [1:0]           		            prot_cdc_initiatorBRESP;
	 wire [USER_WIDTH-1:0] 		            prot_cdc_initiatorBUSER;
	 wire      					            prot_cdc_initiatorBVALID;
	 wire						            prot_cdc_initiatorBREADY;

	//===================================== Internal wires =======================================//
	//wires between SliceReg block and caxi4interconnect_IntrProtocolConverter

	 wire [ID_WIDTH-1:0] 		dwc_sr_initiatorARID;
	 wire [ADDR_WIDTH-1:0]		dwc_sr_initiatorARADDR;
	 wire [7:0]        			dwc_sr_initiatorARLEN;
	 wire [2:0]          		dwc_sr_initiatorARSIZE;
	 wire [1:0]          		dwc_sr_initiatorARBURST;
	 wire [1:0]          		dwc_sr_initiatorARLOCK;
	 wire [3:0]           		dwc_sr_initiatorARCACHE;
	 wire [2:0]         		dwc_sr_initiatorARPROT;
	 wire [3:0]          		dwc_sr_initiatorARREGION;
	 wire [3:0]          		dwc_sr_initiatorARQOS;
	 wire [USER_WIDTH-1:0]		dwc_sr_initiatorARUSER;
	 wire            			dwc_sr_initiatorARVALID;
	 wire             			dwc_sr_initiatorARREADY;

	// Initiator Read Data Ports	
	 wire [ID_WIDTH-1:0]   		dwc_sr_initiatorRID;
	 wire [DATA_WIDTH-1:0]		dwc_sr_initiatorRDATA;
	 wire [1:0]           		dwc_sr_initiatorRRESP;
	 wire                		dwc_sr_initiatorRLAST;
	 wire [USER_WIDTH-1:0] 		dwc_sr_initiatorRUSER;
	 wire                 		dwc_sr_initiatorRVALID;
	 wire               		dwc_sr_initiatorRREADY;

	// Initiator Write Address Ports	
	 wire [ID_WIDTH-1:0]  		dwc_sr_initiatorAWID;
	 wire [ADDR_WIDTH-1:0] 		dwc_sr_initiatorAWADDR;
	 wire [7:0]           		dwc_sr_initiatorAWLEN;
	 wire [2:0]           		dwc_sr_initiatorAWSIZE;
	 wire [1:0]           		dwc_sr_initiatorAWBURST;
	 wire [1:0]           		dwc_sr_initiatorAWLOCK;
	 wire [3:0]          		dwc_sr_initiatorAWCACHE;
	 wire [2:0]           		dwc_sr_initiatorAWPROT;
	 wire [3:0]            		dwc_sr_initiatorAWREGION;
	 wire [3:0]           		dwc_sr_initiatorAWQOS;
	 wire [USER_WIDTH-1:0]  	dwc_sr_initiatorAWUSER;
	 wire                 		dwc_sr_initiatorAWVALID;
	 wire                		dwc_sr_initiatorAWREADY;
	
	// Initiator Write Data Ports	
	 wire [ID_WIDTH-1:0]        dwc_sr_initiatorWID;
	 wire [DATA_WIDTH-1:0]  	dwc_sr_initiatorWDATA;
	 wire [(DATA_WIDTH/8)-1:0]	dwc_sr_initiatorWSTRB;
	 wire                  		dwc_sr_initiatorWLAST;
	 wire [USER_WIDTH-1:0] 		dwc_sr_initiatorWUSER;
	 wire                  		dwc_sr_initiatorWVALID;
	 wire                   	dwc_sr_initiatorWREADY;
			
	// Initiator Write Response Ports	
	 wire [ID_WIDTH-1:0]		dwc_sr_initiatorBID;
	 wire [1:0]           		dwc_sr_initiatorBRESP;
	 wire [USER_WIDTH-1:0] 		dwc_sr_initiatorBUSER;
	 wire      					dwc_sr_initiatorBVALID;
	 wire						dwc_sr_initiatorBREADY;
	 
	 
//===================================== Internal wires =======================================//
//wires between caxi4interconnect_IntrProtocolConverter block and next block

	 wire [ID_WIDTH-1:0] 		            cdc_dwc_initiatorARID;
	 wire [ADDR_WIDTH-1:0]		            cdc_dwc_initiatorARADDR;
	 wire [7:0]        			            cdc_dwc_initiatorARLEN;
	 wire [2:0]          		            cdc_dwc_initiatorARSIZE;
	 wire [1:0]          		            cdc_dwc_initiatorARBURST;
	 wire [1:0]          		            cdc_dwc_initiatorARLOCK;
	 wire [3:0]           		            cdc_dwc_initiatorARCACHE;
	 wire [2:0]         		            cdc_dwc_initiatorARPROT;
	 wire [3:0]          		            cdc_dwc_initiatorARREGION;
	 wire [3:0]          		            cdc_dwc_initiatorARQOS;
	 wire [USER_WIDTH-1:0]		            cdc_dwc_initiatorARUSER;
	 wire            			            cdc_dwc_initiatorARVALID;
	 wire             			            cdc_dwc_initiatorARREADY;

	// Initiator Read Data Ports	
	 wire [ID_WIDTH-1:0]   		            cdc_dwc_initiatorRID;
	 wire [INITIATOR_DATA_WIDTH-1:0]		cdc_dwc_initiatorRDATA;
	 wire [1:0]           		            cdc_dwc_initiatorRRESP;
	 wire                		            cdc_dwc_initiatorRLAST;
	 wire [USER_WIDTH-1:0] 		            cdc_dwc_initiatorRUSER;
	 wire                 		            cdc_dwc_initiatorRVALID;
	 wire               		            cdc_dwc_initiatorRREADY;

	// Initiator Write Address Ports	
	 wire [ID_WIDTH-1:0]  		            cdc_dwc_initiatorAWID;
	 wire [ADDR_WIDTH-1:0] 		            cdc_dwc_initiatorAWADDR;
	 wire [7:0]           		            cdc_dwc_initiatorAWLEN;
	 wire [2:0]           		            cdc_dwc_initiatorAWSIZE;
	 wire [1:0]           		            cdc_dwc_initiatorAWBURST;
	 wire [1:0]           		            cdc_dwc_initiatorAWLOCK;
	 wire [3:0]          		            cdc_dwc_initiatorAWCACHE;
	 wire [2:0]           		            cdc_dwc_initiatorAWPROT;
	 wire [3:0]            		            cdc_dwc_initiatorAWREGION;
	 wire [3:0]           		            cdc_dwc_initiatorAWQOS;
	 wire [USER_WIDTH-1:0]  	            cdc_dwc_initiatorAWUSER;
	 wire                 		            cdc_dwc_initiatorAWVALID;
	 wire                		            cdc_dwc_initiatorAWREADY;
	
	// Initiator Write Data Ports	
	 wire [ID_WIDTH-1:0]                    cdc_dwc_initiatorWID;
	 wire [INITIATOR_DATA_WIDTH-1:0]  	    cdc_dwc_initiatorWDATA;
	 wire [(INITIATOR_DATA_WIDTH/8)-1:0]	cdc_dwc_initiatorWSTRB;
	 wire                  		            cdc_dwc_initiatorWLAST;
	 wire [USER_WIDTH-1:0] 		            cdc_dwc_initiatorWUSER;
	 wire                  		            cdc_dwc_initiatorWVALID;
	 wire                   	            cdc_dwc_initiatorWREADY;
			 
	// Initiator Write Response Ports	
	 wire [ID_WIDTH-1:0]		            cdc_dwc_initiatorBID;
	 wire [1:0]           		            cdc_dwc_initiatorBRESP;
	 wire [USER_WIDTH-1:0] 		            cdc_dwc_initiatorBUSER;
	 wire      					            cdc_dwc_initiatorBVALID;
	 wire						            cdc_dwc_initiatorBREADY;



	 wire [ID_WIDTH-1:0] 		            cdc_rs_initiatorARID;
	 wire [ADDR_WIDTH-1:0]		            cdc_rs_initiatorARADDR;
	 wire [7:0]        			            cdc_rs_initiatorARLEN;
	 wire [2:0]          		            cdc_rs_initiatorARSIZE;
	 wire [1:0]          		            cdc_rs_initiatorARBURST;
	 wire [1:0]          		            cdc_rs_initiatorARLOCK;
	 wire [3:0]           		            cdc_rs_initiatorARCACHE;
	 wire [2:0]         		            cdc_rs_initiatorARPROT;
	 wire [3:0]          		            cdc_rs_initiatorARREGION;
	 wire [3:0]          		            cdc_rs_initiatorARQOS;
	 wire [USER_WIDTH-1:0]		            cdc_rs_initiatorARUSER;
	 wire            			            cdc_rs_initiatorARVALID;
	 wire             			            cdc_rs_initiatorARREADY;

	// Initiator Read Data Ports	
	 wire [ID_WIDTH-1:0]   		            cdc_rs_initiatorRID;
	 wire [DATA_WIDTH-1:0]		            cdc_rs_initiatorRDATA;
	 wire [1:0]           		            cdc_rs_initiatorRRESP;
	 wire                		            cdc_rs_initiatorRLAST;
	 wire [USER_WIDTH-1:0] 		            cdc_rs_initiatorRUSER;
	 wire                 		            cdc_rs_initiatorRVALID;
	 wire               		            cdc_rs_initiatorRREADY;

	// Initiator Write Address Ports	
	 wire [ID_WIDTH-1:0]  		            cdc_rs_initiatorAWID;
	 wire [ADDR_WIDTH-1:0] 		            cdc_rs_initiatorAWADDR;
	 wire [7:0]           		            cdc_rs_initiatorAWLEN;
	 wire [2:0]           		            cdc_rs_initiatorAWSIZE;
	 wire [1:0]           		            cdc_rs_initiatorAWBURST;
	 wire [1:0]           		            cdc_rs_initiatorAWLOCK;
	 wire [3:0]          		            cdc_rs_initiatorAWCACHE;
	 wire [2:0]           		            cdc_rs_initiatorAWPROT;
	 wire [3:0]            		            cdc_rs_initiatorAWREGION;
	 wire [3:0]           		            cdc_rs_initiatorAWQOS;
	 wire [USER_WIDTH-1:0]  	            cdc_rs_initiatorAWUSER;
	 wire                 		            cdc_rs_initiatorAWVALID;
	 wire                		            cdc_rs_initiatorAWREADY;
	
	// Initiator Write Data Ports	
	 wire [ID_WIDTH-1:0]                    cdc_rs_initiatorWID;
	 wire [DATA_WIDTH-1:0]  	            cdc_rs_initiatorWDATA;
	 wire [(DATA_WIDTH/8)-1:0]	            cdc_rs_initiatorWSTRB;
	 wire                  		            cdc_rs_initiatorWLAST;
	 wire [USER_WIDTH-1:0] 		            cdc_rs_initiatorWUSER;
	 wire                  		            cdc_rs_initiatorWVALID;
	 wire                   	            cdc_rs_initiatorWREADY;
			 
	// Initiator Write Response Ports	
	 wire [ID_WIDTH-1:0]		            cdc_rs_initiatorBID;
	 wire [1:0]           		            cdc_rs_initiatorBRESP;
	 wire [USER_WIDTH-1:0] 		            cdc_rs_initiatorBUSER;
	 wire      					            cdc_rs_initiatorBVALID;
	 wire						            cdc_rs_initiatorBREADY;

//wires between caxi4interconnect_IntrClockDomainCrossing block and dwc register slice block

	 wire [ID_WIDTH-1:0] 		            dwc_rs_initiatorARID;
	 wire [ADDR_WIDTH-1:0]		            dwc_rs_initiatorARADDR;
	 wire [7:0]        			            dwc_rs_initiatorARLEN;
	 wire [2:0]          		            dwc_rs_initiatorARSIZE;
	 wire [1:0]          		            dwc_rs_initiatorARBURST;
	 wire [1:0]          		            dwc_rs_initiatorARLOCK;
	 wire [3:0]           		            dwc_rs_initiatorARCACHE;
	 wire [2:0]         		            dwc_rs_initiatorARPROT;
	 wire [3:0]          		            dwc_rs_initiatorARREGION;
	 wire [3:0]          		            dwc_rs_initiatorARQOS;
	 wire [USER_WIDTH-1:0]		            dwc_rs_initiatorARUSER;
	 wire            			            dwc_rs_initiatorARVALID;
	 wire             			            dwc_rs_initiatorARREADY;

	// Initiator Read Data Ports	
	 wire [ID_WIDTH-1:0]   		            dwc_rs_initiatorRID;
	 wire [INITIATOR_DATA_WIDTH-1:0]		dwc_rs_initiatorRDATA;
	 wire [1:0]           		            dwc_rs_initiatorRRESP;
	 wire                		            dwc_rs_initiatorRLAST;
	 wire [USER_WIDTH-1:0] 		            dwc_rs_initiatorRUSER;
	 wire                 		            dwc_rs_initiatorRVALID;
	 wire               		            dwc_rs_initiatorRREADY;

	// Initiator Write Address Ports	
	 wire [ID_WIDTH-1:0]  		            dwc_rs_initiatorAWID;
	 wire [ADDR_WIDTH-1:0] 		            dwc_rs_initiatorAWADDR;
	 wire [7:0]           		            dwc_rs_initiatorAWLEN;
	 wire [2:0]           		            dwc_rs_initiatorAWSIZE;
	 wire [1:0]           		            dwc_rs_initiatorAWBURST;
	 wire [1:0]           		            dwc_rs_initiatorAWLOCK;
	 wire [3:0]          		            dwc_rs_initiatorAWCACHE;
	 wire [2:0]           		            dwc_rs_initiatorAWPROT;
	 wire [3:0]            		            dwc_rs_initiatorAWREGION;
	 wire [3:0]           		            dwc_rs_initiatorAWQOS;
	 wire [USER_WIDTH-1:0]  	            dwc_rs_initiatorAWUSER;
	 wire                 		            dwc_rs_initiatorAWVALID;
	 wire                		            dwc_rs_initiatorAWREADY;
	
	// Initiator Write Data Ports	
	 wire [ID_WIDTH-1:0]                    dwc_rs_initiatorWID;
	 wire [INITIATOR_DATA_WIDTH-1:0]  	    dwc_rs_initiatorWDATA;
	 wire [(INITIATOR_DATA_WIDTH/8)-1:0]	dwc_rs_initiatorWSTRB;
	 wire                  		            dwc_rs_initiatorWLAST;
	 wire [USER_WIDTH-1:0] 		            dwc_rs_initiatorWUSER;
	 wire                  		            dwc_rs_initiatorWVALID;
	 wire                   	            dwc_rs_initiatorWREADY;
			 
	// Initiator Write Response Ports	
	 wire [ID_WIDTH-1:0]		            dwc_rs_initiatorBID;
	 wire [1:0]           		            dwc_rs_initiatorBRESP;
	 wire [USER_WIDTH-1:0] 		            dwc_rs_initiatorBUSER;
	 wire      					            dwc_rs_initiatorBVALID;
	 wire						            dwc_rs_initiatorBREADY;


     wire [ID_WIDTH-1:0] 	             arid_pipe_out      ;
     wire [ADDR_WIDTH-1:0]	             araddr_pipe_out    ;
     wire [7:0]        		             arlen_pipe_out     ;
     wire [2:0]          	             arsize_pipe_out    ;
     wire [1:0]          	             arburst_pipe_out   ;
     wire [1:0]          	             arlock_pipe_out    ;
     wire [3:0]           	             arcache_pipe_out   ;
     wire [2:0]         		         arprot_pipe_out    ;
     wire [3:0]          	             arregion_pipe_out  ;
     wire [3:0]          	             arqos_pipe_out     ;
     wire [USER_WIDTH-1:0]	             aruser_pipe_out    ;
     wire            		             arvalid_pipe_out   ;
     wire            		             arready_pipe_out   ;
     wire [ID_WIDTH-1:0]   	             rid_pipe_out       ;
     wire [INITIATOR_DATA_WIDTH-1:0]     rdata_pipe_out     ;
     wire [1:0]           	             rresp_pipe_out     ;
     wire                	             rlast_pipe_out     ;
     wire [USER_WIDTH-1:0] 	             ruser_pipe_out     ;
     wire                 	             rvalid_pipe_out    ;
     wire               		         rready_pipe_out    ;
     wire [ID_WIDTH-1:0]  	             awid_pipe_out      ;
     wire [ADDR_WIDTH-1:0] 	             awaddr_pipe_out    ;
     wire [7:0]           	             awlen_pipe_out     ;
     wire [2:0]           	             awsize_pipe_out    ;
     wire [1:0]           	             awburst_pipe_out   ;
     wire [1:0]           	             awlock_pipe_out    ;
     wire [3:0]          	             awcache_pipe_out   ;
     wire [2:0]           	             awprot_pipe_out    ;
     wire [3:0]            	             awregion_pipe_out  ;
     wire [3:0]           	             awqos_pipe_out     ;
     wire [USER_WIDTH-1:0]               awuser_pipe_out    ;
     wire                 	             awvalid_pipe_out   ;
     wire                	             awready_pipe_out   ;	
     wire [ID_WIDTH-1:0]                 wid_pipe_out       ;
     wire [INITIATOR_DATA_WIDTH-1:0]  	 wdata_pipe_out     ;
     wire [(INITIATOR_DATA_WIDTH/8)-1:0] wstrb_pipe_out     ;
     wire                  	             wlast_pipe_out     ;
     wire [USER_WIDTH-1:0] 	             wuser_pipe_out     ;
     wire                  	             wvalid_pipe_out    ;
     wire                   	         wready_pipe_out    ;	
     wire [ID_WIDTH-1:0]		         bid_pipe_out       ;
     wire [1:0]           	             bresp_pipe_out     ;
     wire [USER_WIDTH-1:0] 	             buser_pipe_out     ;
     wire      				             bvalid_pipe_out    ;
     wire					             bready_pipe_out    ;


	//=======================================================================================================================
	// Local system reset - asserted asynchronously to INITR_CLK and deasserted synchronous
	//=======================================================================================================================
	generate
	if(CLOCK_DOMAIN_CROSSING) 
	  begin
	    caxi4interconnect_ResetSync #
        (
		  .SYNC_RESET           ( SYNC_RESET    )
		) rsync (
	      .sysClk	            ( INITR_CLK     ),
	      .sysReset_L           ( ARESETN       ),			// active low reset synchronoise to RE AClk - asserted async.
	      .arst_sync            ( iarst_sync    ),			// active low iarst_sync synchronised to INITR_CLK
	      .srst_sync            ( isrst_sync    )			// active low iarst_sync synchronised to INITR_CLK
	    );	
      end
	else
	  begin
	    assign iarst_sync = arst_sync;
	    assign isrst_sync = srst_sync;
      end
	endgenerate
	
	assign i_sync_rstn = (EXPOSE_RST == 1) ? (SYNC_RESET == 1) ? isrst_sync : iarst_sync : 1'b1;
	
	

generate //ProtoConverter
	if (INITIATOR_TYPE == 2'b10) begin

      localparam BRESP_CNT_WIDTH = (AHB_BRESP_CNT_WIDTH < 2) ? 2: AHB_BRESP_CNT_WIDTH;

	  caxi4interconnect_IntrAHBtoAXI4Converter #
		(
			.ID_WIDTH                   ( ID_WIDTH                   ),
			.BRESP_CHECK_MODE           ( AHB_BRESP_CHECK_MODE       ),
            .BRESP_CNT_WIDTH            ( BRESP_CNT_WIDTH            ),
			.ADDR_WIDTH                 ( ADDR_WIDTH                 ),				
			.DATA_WIDTH                 ( INITIATOR_DATA_WIDTH       ), 
			.DEF_BURST_LEN              ( DEF_BURST_LEN              ),
			.USER_WIDTH                 ( USER_WIDTH                 )
		                                                             ) 
        intrAHBtoAXI4Conv 
		(
			// Global Signals
			.ACLK                       ( INITR_CLK                  ),
			.iarst_sync                 ( iarst_sync                 ),	
			.isrst_sync                 ( isrst_sync                 ),	

                                        // AHB interface							
			.INITIATOR_HADDR		 	( INITIATOR_HADDR            ),
			.INITIATOR_HSEL		        ( INITIATOR_HSEL             ),
			.INITIATOR_HBURST			( INITIATOR_HBURST           ),
			.INITIATOR_HMASTLOCK		( INITIATOR_HMASTLOCK        ),
			.INITIATOR_HPROT			( INITIATOR_HPROT            ),					
			.INITIATOR_HSIZE			( INITIATOR_HSIZE            ),
			.INITIATOR_HNONSEC			( INITIATOR_HNONSEC          ),
			.INITIATOR_HTRANS			( INITIATOR_HTRANS           ),
			.INITIATOR_HWDATA			( INITIATOR_HWDATA           ),
			.INITIATOR_HRDATA			( INITIATOR_HRDATA           ),
			.INITIATOR_HWRITE			( INITIATOR_HWRITE           ),
			.INITIATOR_HREADY			( INITIATOR_HREADY           ),
			.INITIATOR_HRESP			( INITIATOR_HRESP            ),
//			.INITIATOR_HEXOKAY			( INITIATOR_HEXOKAY          ),
//			.INITIATOR_HEXCL			( INITIATOR_HEXCL            ),

                                        // AXI4 interface
			.int_initiatorARID			( prot_cdc_initiatorARID     ),
			.int_initiatorARADDR		( prot_cdc_initiatorARADDR   ),
			.int_initiatorARLEN		    ( prot_cdc_initiatorARLEN    ),
			.int_initiatorARSIZE		( prot_cdc_initiatorARSIZE   ),
			.int_initiatorARBURST		( prot_cdc_initiatorARBURST  ),
			.int_initiatorARLOCK		( prot_cdc_initiatorARLOCK   ),
			.int_initiatorARCACHE		( prot_cdc_initiatorARCACHE  ),
			.int_initiatorARPROT		( prot_cdc_initiatorARPROT   ),
			.int_initiatorARREGION		( prot_cdc_initiatorARREGION ),
			.int_initiatorARQOS		    ( prot_cdc_initiatorARQOS    ),
			.int_initiatorARUSER		( prot_cdc_initiatorARUSER   ),
			.int_initiatorARVALID		( prot_cdc_initiatorARVALID  ),
			.int_initiatorARREADY 		( prot_cdc_initiatorARREADY  ),

			.int_initiatorAWQOS		    ( prot_cdc_initiatorAWQOS    ),
			.int_initiatorAWREGION		( prot_cdc_initiatorAWREGION ),
			.int_initiatorAWID			( prot_cdc_initiatorAWID     ),
			.int_initiatorAWADDR		( prot_cdc_initiatorAWADDR   ),
			.int_initiatorAWLEN		    ( prot_cdc_initiatorAWLEN    ),
			.int_initiatorAWSIZE		( prot_cdc_initiatorAWSIZE   ),
			.int_initiatorAWBURST		( prot_cdc_initiatorAWBURST  ),
			.int_initiatorAWLOCK		( prot_cdc_initiatorAWLOCK   ),
			.int_initiatorAWCACHE		( prot_cdc_initiatorAWCACHE  ),
			.int_initiatorAWPROT		( prot_cdc_initiatorAWPROT   ),
			.int_initiatorAWUSER		( prot_cdc_initiatorAWUSER   ),
			.int_initiatorAWVALID		( prot_cdc_initiatorAWVALID  ),

			.int_initiatorAWREADY 		( prot_cdc_initiatorAWREADY  ),
			.int_initiatorWID   		( prot_cdc_initiatorWID      ),
			.int_initiatorWDATA		    ( prot_cdc_initiatorWDATA    ),
			.int_initiatorWSTRB		    ( prot_cdc_initiatorWSTRB    ),
			.int_initiatorWLAST		    ( prot_cdc_initiatorWLAST    ),
			.int_initiatorWUSER		    ( prot_cdc_initiatorWUSER    ),
			.int_initiatorWVALID		( prot_cdc_initiatorWVALID   ),
			.int_initiatorWREADY 		( prot_cdc_initiatorWREADY   ),

			.int_initiatorBVALID 		( prot_cdc_initiatorBVALID   ),
			.int_initiatorBID 			( prot_cdc_initiatorBID      ),
			.int_initiatorBUSER 		( prot_cdc_initiatorBUSER    ),
			.int_initiatorBRESP 		( prot_cdc_initiatorBRESP    ),
			.int_initiatorBREADY		( prot_cdc_initiatorBREADY   ),

			.int_initiatorRREADY		( prot_cdc_initiatorRREADY   ),
			.int_initiatorRID 			( prot_cdc_initiatorRID      ),
			.int_initiatorRDATA 		( prot_cdc_initiatorRDATA    ),
			.int_initiatorRRESP 		( prot_cdc_initiatorRRESP    ),
			.int_initiatorRUSER 		( prot_cdc_initiatorRUSER    ),
			.int_initiatorRLAST 		( prot_cdc_initiatorRLAST    ),
			.int_initiatorRVALID 		( prot_cdc_initiatorRVALID   )
		);

        assign INITIATOR_ARREADY = 'b0;
	
		// Initiator Read Data Ports	
		assign INITIATOR_RID     = 'b0;
		assign INITIATOR_RDATA   = 'b0;
		assign INITIATOR_RRESP   = 'b0;
		assign INITIATOR_RLAST   = 'b0;
		assign INITIATOR_RUSER   = 'b0;
		assign INITIATOR_RVALID  = 'b0;

		assign INITIATOR_AWREADY = 'b0;
	
			// Initiator Write Data Ports	
		assign INITIATOR_WREADY = 'b0;
	
			// Initiator Write Response Ports	
		assign INITIATOR_BID     = 'b0;
		assign INITIATOR_BRESP   = 'b0;
		assign INITIATOR_BUSER   = 'b0;
		assign INITIATOR_BVALID  = 'b0;
	end
	else begin	
	  caxi4interconnect_IntrProtocolConverter #
		(
			.INITIATOR_TYPE             ( INITIATOR_TYPE             ) , 		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11
			.INITIATOR_NUMBER           ( INITIATOR_NUMBER           ),	// initiator number
			.ID_WIDTH                   ( ID_WIDTH                   ),
			.ADDR_WIDTH                 ( ADDR_WIDTH                 ),				
			.DATA_WIDTH                 ( INITIATOR_DATA_WIDTH       ), 
			.USER_WIDTH                 ( USER_WIDTH                 )
		) intrrProtConv 
		(
			// Global Signals
			.ACLK                       ( INITR_CLK                  ),
			.iarst_sync                 ( iarst_sync                 ),	
			.isrst_sync                 ( isrst_sync                 ),	
			
			// Initiator Read Address Ports
			.INITIATOR_ARID		        ( arid_pipe_out              ),                                       
			.INITIATOR_ARADDR		    ( araddr_pipe_out            ),
			.INITIATOR_ARLEN		    ( arlen_pipe_out             ),
			.INITIATOR_ARSIZE		    ( arsize_pipe_out            ),
			.INITIATOR_ARBURST		    ( arburst_pipe_out           ),
			.INITIATOR_ARLOCK		    ( arlock_pipe_out            ),
			.INITIATOR_ARCACHE		    ( arcache_pipe_out           ),
			.INITIATOR_ARPROT		    ( arprot_pipe_out            ),
			.INITIATOR_ARREGION	        ( arregion_pipe_out          ),
			.INITIATOR_ARQOS		    ( arqos_pipe_out             ),
			.INITIATOR_ARUSER		    ( aruser_pipe_out            ),
			.INITIATOR_ARVALID		    ( arvalid_pipe_out           ),
			.INITIATOR_ARREADY 	        ( arready_pipe_out           ),							
			.INITIATOR_RID 		        ( rid_pipe_out               ),                                       
			.INITIATOR_RDATA 		    ( rdata_pipe_out             ), // output from this module            
			.INITIATOR_RRESP 		    ( rresp_pipe_out             ),                                       
			.INITIATOR_RLAST 		    ( rlast_pipe_out             ),                                       
			.INITIATOR_RUSER 		    ( ruser_pipe_out             ),                                       
			.INITIATOR_RVALID 		    ( rvalid_pipe_out            ),                                       
			.INITIATOR_RREADY		    ( rready_pipe_out            ),
			                                                              
			                                                              
			.INITIATOR_AWID		        ( awid_pipe_out              ),                   
			.INITIATOR_AWADDR		    ( awaddr_pipe_out            ),                   
			.INITIATOR_AWLEN		    ( awlen_pipe_out             ),                   
			.INITIATOR_AWSIZE		    ( awsize_pipe_out            ),                   
			.INITIATOR_AWBURST		    ( awburst_pipe_out           ),                   
			.INITIATOR_AWLOCK		    ( awlock_pipe_out            ),                   
			.INITIATOR_AWCACHE		    ( awcache_pipe_out           ),                   
			.INITIATOR_AWPROT		    ( awprot_pipe_out            ),                   
			.INITIATOR_AWREGION	        ( awregion_pipe_out          ), 
			.INITIATOR_AWQOS		    ( awqos_pipe_out             ),
			.INITIATOR_AWUSER		    ( awuser_pipe_out            ),                    
			.INITIATOR_AWVALID		    ( awvalid_pipe_out           ),                    
			.INITIATOR_AWREADY 	        ( awready_pipe_out           ),
			.INITIATOR_WID              ( wid_pipe_out               ), 
			.INITIATOR_WDATA		    ( wdata_pipe_out             ),
			.INITIATOR_WSTRB		    ( wstrb_pipe_out             ),
			.INITIATOR_WLAST		    ( wlast_pipe_out             ),
			.INITIATOR_WUSER		    ( wuser_pipe_out             ),
			.INITIATOR_WVALID		    ( wvalid_pipe_out            ),
			.INITIATOR_WREADY 		    ( wready_pipe_out            ),
			.INITIATOR_BID 		        ( bid_pipe_out               ),
			.INITIATOR_BRESP 		    ( bresp_pipe_out             ),
			.INITIATOR_BUSER 		    ( buser_pipe_out             ),							
			.INITIATOR_BVALID 		    ( bvalid_pipe_out            ),
			.INITIATOR_BREADY		    ( bready_pipe_out            ),
			
			.int_initiatorARID			( prot_cdc_initiatorARID     ),
			.int_initiatorARADDR		( prot_cdc_initiatorARADDR   ),
			.int_initiatorARLEN		    ( prot_cdc_initiatorARLEN    ),
			.int_initiatorARSIZE		( prot_cdc_initiatorARSIZE   ),
			.int_initiatorARBURST		( prot_cdc_initiatorARBURST  ),
			.int_initiatorARLOCK		( prot_cdc_initiatorARLOCK   ),
			.int_initiatorARCACHE		( prot_cdc_initiatorARCACHE  ),
			.int_initiatorARPROT		( prot_cdc_initiatorARPROT   ),
			.int_initiatorARREGION		( prot_cdc_initiatorARREGION ),
			.int_initiatorARQOS		    ( prot_cdc_initiatorARQOS    ),
			.int_initiatorARUSER		( prot_cdc_initiatorARUSER   ),
			.int_initiatorARVALID		( prot_cdc_initiatorARVALID  ),
			.int_initiatorAWQOS		    ( prot_cdc_initiatorAWQOS    ),
			.int_initiatorAWREGION		( prot_cdc_initiatorAWREGION ),
			.int_initiatorAWID			( prot_cdc_initiatorAWID     ),
			.int_initiatorAWADDR		( prot_cdc_initiatorAWADDR   ),
			.int_initiatorAWLEN		    ( prot_cdc_initiatorAWLEN    ),
			.int_initiatorAWSIZE		( prot_cdc_initiatorAWSIZE   ),
			.int_initiatorAWBURST		( prot_cdc_initiatorAWBURST  ),
			.int_initiatorAWLOCK		( prot_cdc_initiatorAWLOCK   ),
			.int_initiatorAWCACHE		( prot_cdc_initiatorAWCACHE  ),
			.int_initiatorAWPROT		( prot_cdc_initiatorAWPROT   ),
			.int_initiatorAWUSER		( prot_cdc_initiatorAWUSER   ),
			.int_initiatorAWVALID		( prot_cdc_initiatorAWVALID  ),
			.int_initiatorWID           ( prot_cdc_initiatorWID      ),
			.int_initiatorWDATA		    ( prot_cdc_initiatorWDATA    ),
			.int_initiatorWSTRB		    ( prot_cdc_initiatorWSTRB    ),
			.int_initiatorWLAST		    ( prot_cdc_initiatorWLAST    ),
			.int_initiatorWUSER		    ( prot_cdc_initiatorWUSER    ),
			.int_initiatorWVALID		( prot_cdc_initiatorWVALID   ),
			.int_initiatorBREADY		( prot_cdc_initiatorBREADY   ),
			.int_initiatorRREADY		( prot_cdc_initiatorRREADY   ),
			.int_initiatorARREADY 		( prot_cdc_initiatorARREADY  ),
			.int_initiatorRID 			( prot_cdc_initiatorRID      ),
			.int_initiatorRDATA 		( prot_cdc_initiatorRDATA    ), // input to this module
			.int_initiatorRRESP 		( prot_cdc_initiatorRRESP    ),
			.int_initiatorRUSER 		( prot_cdc_initiatorRUSER    ),
			.int_initiatorBID 			( prot_cdc_initiatorBID      ),
			.int_initiatorBRESP 		( prot_cdc_initiatorBRESP    ),
			.int_initiatorBUSER 		( prot_cdc_initiatorBUSER    ),
			.int_initiatorRLAST 		( prot_cdc_initiatorRLAST    ),
			.int_initiatorRVALID 		( prot_cdc_initiatorRVALID   ),
			.int_initiatorAWREADY 		( prot_cdc_initiatorAWREADY  ),
			.int_initiatorWREADY 		( prot_cdc_initiatorWREADY   ),
			.int_initiatorBVALID 		( prot_cdc_initiatorBVALID   )

		);

		assign INITIATOR_HRDATA  = {INITIATOR_DATA_WIDTH{1'b0}};  // SAR#LINT-002: Explicit width
		assign INITIATOR_HREADY  = 1'b0;
		assign INITIATOR_HRESP   = 1'b0;
		assign INITIATOR_HEXOKAY = 1'b0;
	end
endgenerate		



generate //CDC Placement
  if(CDC_PLACEMENT == 0) begin 	//Before DWC. CDC->DWC_RS->DWC											
    caxi4interconnect_IntrClockDomainCrossing #
    (
    	.ID_WIDTH                   ( ID_WIDTH                   ),
    	.ADDR_WIDTH                 ( ADDR_WIDTH                 ),				
    	.INITIATOR_DATA_WIDTH       ( INITIATOR_DATA_WIDTH       ),
    	.USER_WIDTH                 ( USER_WIDTH                 ),
    	.CLOCK_DOMAIN_CROSSING      ( CLOCK_DOMAIN_CROSSING      ),
    	.CDC_FIFO_DEPTH             ( CDC_FIFO_DEPTH             ),
    	.CDC_ADDR_RESP_FIFO_DEPTH   ( CDC_ADDR_RESP_FIFO_DEPTH   ),
    	.INITIATOR_TYPE             ( INITIATOR_TYPE             ),  		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11
    	.READ_INTERLEAVE            ( READ_INTERLEAVE            ),
        .PIPE                       ( PIPE                       ),
        .CDC_RAM_TYPE               ( CDC_RAM_TYPE               ),
        .SYNC_RESET                 ( SYNC_RESET                 ),
        .NUM_STAGES                 ( NUM_STAGES                 )
    ) intrrCDC
    (
    	// Global Signals
    	.INITR_CLK                  ( INITR_CLK                  ),
    	.XBAR_CLK                   ( XBAR_CLK                   ),
    	.iarst_sync                 ( iarst_sync                 ),	
    	.isrst_sync                 ( isrst_sync                 ),	
    	.arst_sync                  ( arst_sync                  ),	
    	.srst_sync                  ( srst_sync                  ),	
    
    	// Initiator Read Address Ports
    	.INITIATOR_ARID		        ( prot_cdc_initiatorARID     ),
    	.INITIATOR_ARADDR		    ( prot_cdc_initiatorARADDR   ),
    	.INITIATOR_ARLEN		    ( prot_cdc_initiatorARLEN    ),
    	.INITIATOR_ARSIZE		    ( prot_cdc_initiatorARSIZE   ),
    	.INITIATOR_ARBURST		    ( prot_cdc_initiatorARBURST  ),
    	.INITIATOR_ARLOCK		    ( prot_cdc_initiatorARLOCK   ),
    	.INITIATOR_ARCACHE		    ( prot_cdc_initiatorARCACHE  ),
    	.INITIATOR_ARPROT		    ( prot_cdc_initiatorARPROT   ),
    	.INITIATOR_ARREGION	        ( prot_cdc_initiatorARREGION ),
    	.INITIATOR_ARQOS		    ( prot_cdc_initiatorARQOS    ),
    	.INITIATOR_ARUSER		    ( prot_cdc_initiatorARUSER   ),
    	.INITIATOR_ARVALID		    ( prot_cdc_initiatorARVALID  ),
    	.INITIATOR_AWQOS		    ( prot_cdc_initiatorAWQOS    ),
    	.INITIATOR_AWREGION	        ( prot_cdc_initiatorAWREGION ),
    	.INITIATOR_AWID		        ( prot_cdc_initiatorAWID     ),
    	.INITIATOR_AWADDR		    ( prot_cdc_initiatorAWADDR   ),
    	.INITIATOR_AWLEN		    ( prot_cdc_initiatorAWLEN    ),
    	.INITIATOR_AWSIZE		    ( prot_cdc_initiatorAWSIZE   ),
    	.INITIATOR_AWBURST		    ( prot_cdc_initiatorAWBURST  ),
    	.INITIATOR_AWLOCK		    ( prot_cdc_initiatorAWLOCK   ),
    	.INITIATOR_AWCACHE		    ( prot_cdc_initiatorAWCACHE  ),
    	.INITIATOR_AWPROT		    ( prot_cdc_initiatorAWPROT   ),
    	.INITIATOR_AWUSER		    ( prot_cdc_initiatorAWUSER   ),
    	.INITIATOR_AWVALID		    ( prot_cdc_initiatorAWVALID  ),
    	.INITIATOR_WID              ( prot_cdc_initiatorWID      ),
    	.INITIATOR_WDATA		    ( prot_cdc_initiatorWDATA    ),
    	.INITIATOR_WSTRB		    ( prot_cdc_initiatorWSTRB    ),
    	.INITIATOR_WLAST		    ( prot_cdc_initiatorWLAST    ),
    	.INITIATOR_WUSER		    ( prot_cdc_initiatorWUSER    ),
    	.INITIATOR_WVALID		    ( prot_cdc_initiatorWVALID   ),
    	.INITIATOR_BREADY		    ( prot_cdc_initiatorBREADY   ),
    	.INITIATOR_RREADY		    ( prot_cdc_initiatorRREADY   ),
    	.INITIATOR_ARREADY 	        ( prot_cdc_initiatorARREADY  ),
    	.INITIATOR_RID 		        ( prot_cdc_initiatorRID      ),
    	.INITIATOR_RDATA 		    ( prot_cdc_initiatorRDATA    ), // output from this module
    	.INITIATOR_RRESP 		    ( prot_cdc_initiatorRRESP    ),
    	.INITIATOR_RUSER 		    ( prot_cdc_initiatorRUSER    ),
    	.INITIATOR_BID 		        ( prot_cdc_initiatorBID      ),
    	.INITIATOR_BRESP 		    ( prot_cdc_initiatorBRESP    ),
    	.INITIATOR_BUSER 		    ( prot_cdc_initiatorBUSER    ),
    	.INITIATOR_RLAST 		    ( prot_cdc_initiatorRLAST    ),
    	.INITIATOR_RVALID 		    ( prot_cdc_initiatorRVALID   ),
    	.INITIATOR_AWREADY 	        ( prot_cdc_initiatorAWREADY  ),
    	.INITIATOR_WREADY 		    ( prot_cdc_initiatorWREADY   ),
    	.INITIATOR_BVALID 		    ( prot_cdc_initiatorBVALID   ),
    	
    	.int_initiatorARID			( cdc_dwc_initiatorARID      ),
    	.int_initiatorARADDR		( cdc_dwc_initiatorARADDR    ),
    	.int_initiatorARLEN		    ( cdc_dwc_initiatorARLEN     ),
    	.int_initiatorARSIZE		( cdc_dwc_initiatorARSIZE    ),
    	.int_initiatorARBURST		( cdc_dwc_initiatorARBURST   ),
    	.int_initiatorARLOCK		( cdc_dwc_initiatorARLOCK    ),
    	.int_initiatorARCACHE		( cdc_dwc_initiatorARCACHE   ),
    	.int_initiatorARPROT		( cdc_dwc_initiatorARPROT    ),
    	.int_initiatorARREGION		( cdc_dwc_initiatorARREGION  ),
    	.int_initiatorARQOS		    ( cdc_dwc_initiatorARQOS     ),
    	.int_initiatorARUSER		( cdc_dwc_initiatorARUSER    ),
    	.int_initiatorARVALID		( cdc_dwc_initiatorARVALID   ),
    	.int_initiatorAWQOS		    ( cdc_dwc_initiatorAWQOS     ),
    	.int_initiatorAWREGION		( cdc_dwc_initiatorAWREGION  ),
    	.int_initiatorAWID			( cdc_dwc_initiatorAWID      ),
    	.int_initiatorAWADDR		( cdc_dwc_initiatorAWADDR    ),
    	.int_initiatorAWLEN		    ( cdc_dwc_initiatorAWLEN     ),
    	.int_initiatorAWSIZE		( cdc_dwc_initiatorAWSIZE    ),
    	.int_initiatorAWBURST		( cdc_dwc_initiatorAWBURST   ),
    	.int_initiatorAWLOCK		( cdc_dwc_initiatorAWLOCK    ),
    	.int_initiatorAWCACHE		( cdc_dwc_initiatorAWCACHE   ),
    	.int_initiatorAWPROT		( cdc_dwc_initiatorAWPROT    ),
    	.int_initiatorAWUSER		( cdc_dwc_initiatorAWUSER    ),
    	.int_initiatorAWVALID		( cdc_dwc_initiatorAWVALID   ),
    	.int_initiatorWID           ( cdc_dwc_initiatorWID       ),
    	.int_initiatorWDATA		    ( cdc_dwc_initiatorWDATA     ),
    	.int_initiatorWSTRB		    ( cdc_dwc_initiatorWSTRB     ),
    	.int_initiatorWLAST		    ( cdc_dwc_initiatorWLAST     ),
    	.int_initiatorWUSER		    ( cdc_dwc_initiatorWUSER     ),
    	.int_initiatorWVALID		( cdc_dwc_initiatorWVALID    ),
    	.int_initiatorBREADY		( cdc_dwc_initiatorBREADY    ),
    	.int_initiatorRREADY		( cdc_dwc_initiatorRREADY    ),
    	.int_initiatorARREADY 		( cdc_dwc_initiatorARREADY   ),
    	.int_initiatorRID 			( cdc_dwc_initiatorRID       ),
    	.int_initiatorRDATA 		( cdc_dwc_initiatorRDATA     ), // Input to this module
    	.int_initiatorRRESP 		( cdc_dwc_initiatorRRESP     ),
    	.int_initiatorRUSER 		( cdc_dwc_initiatorRUSER     ),
    	.int_initiatorBID 			( cdc_dwc_initiatorBID       ),
    	.int_initiatorBRESP 		( cdc_dwc_initiatorBRESP     ),
    	.int_initiatorBUSER 		( cdc_dwc_initiatorBUSER     ),
    	.int_initiatorRLAST 		( cdc_dwc_initiatorRLAST     ),
    	.int_initiatorRVALID 		( cdc_dwc_initiatorRVALID    ),
    	.int_initiatorAWREADY 		( cdc_dwc_initiatorAWREADY   ),
    	.int_initiatorWREADY 		( cdc_dwc_initiatorWREADY    ),
    	.int_initiatorBVALID 		( cdc_dwc_initiatorBVALID    )
    )  ;
	
    caxi4interconnect_RegisterSlice #  //DWC Register Slice
    
    (
      .AWCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
      .ARCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
      .RCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
      .WCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
      .BCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
      .ID_WIDTH   			    ( ID_WIDTH             ), 
      .ADDR_WIDTH      		    ( ADDR_WIDTH           ),
      .DATA_WIDTH 			    ( INITIATOR_DATA_WIDTH ), 
      .SUPPORT_USER_SIGNALS 	( SUPPORT_USER_SIGNALS ),
      .USER_WIDTH 			    ( USER_WIDTH           )
    ) intr_dwc_rgsl
    (
    
    //=====================================  Global Signals   ========================================================================
      .sysClk	                ( XBAR_CLK                 ),
      .arst_sync	            ( arst_sync                ),
      .srst_sync	            ( srst_sync                ),
      
      // Read Address Channel
      .srcARID	                ( cdc_dwc_initiatorARID     ),
      .srcARADDR	            ( cdc_dwc_initiatorARADDR   ),
      .srcARLEN	                ( cdc_dwc_initiatorARLEN    ),
      .srcARSIZE	            ( cdc_dwc_initiatorARSIZE   ),
      .srcARBURST	            ( cdc_dwc_initiatorARBURST  ),
      .srcARLOCK	            ( cdc_dwc_initiatorARLOCK   ),
      .srcARCACHE	            ( cdc_dwc_initiatorARCACHE  ),
      .srcARPROT	            ( cdc_dwc_initiatorARPROT   ),
      .srcARREGION              ( cdc_dwc_initiatorARREGION ),
      .srcARQOS	                ( cdc_dwc_initiatorARQOS    ),
      .srcARUSER	            ( cdc_dwc_initiatorARUSER   ),
      .srcARVALID	            ( cdc_dwc_initiatorARVALID  ),
      .srcARREADY	            ( cdc_dwc_initiatorARREADY  ),
      
      .dstARID	                ( dwc_rs_initiatorARID      ),
      .dstARADDR	            ( dwc_rs_initiatorARADDR    ),
      .dstARLEN	                ( dwc_rs_initiatorARLEN     ),
      .dstARSIZE	            ( dwc_rs_initiatorARSIZE    ),
      .dstARBURST	            ( dwc_rs_initiatorARBURST   ),
      .dstARLOCK	            ( dwc_rs_initiatorARLOCK    ),
      .dstARCACHE	            ( dwc_rs_initiatorARCACHE   ),
      .dstARPROT	            ( dwc_rs_initiatorARPROT    ),
      .dstARREGION              ( dwc_rs_initiatorARREGION  ),
      .dstARQOS	                ( dwc_rs_initiatorARQOS     ),
      .dstARUSER	            ( dwc_rs_initiatorARUSER    ),
      .dstARVALID	            ( dwc_rs_initiatorARVALID   ),
      .dstARREADY	            ( dwc_rs_initiatorARREADY   ),
      
      // Read Data Channel	
      .srcRID		            ( cdc_dwc_initiatorRID      ),
      .srcRDATA	                ( cdc_dwc_initiatorRDATA    ), // Output from this module
      .srcRRESP	                ( cdc_dwc_initiatorRRESP    ),
      .srcRLAST	                ( cdc_dwc_initiatorRLAST    ),
      .srcRUSER	                ( cdc_dwc_initiatorRUSER    ),
      .srcRVALID	            ( cdc_dwc_initiatorRVALID   ),
      .srcRREADY	            ( cdc_dwc_initiatorRREADY   ),
      
      .dstRID		            ( dwc_rs_initiatorRID       ),
      .dstRDATA	                ( dwc_rs_initiatorRDATA     ), // input to this module // sr_cdc_initiatorRDATA is input to this file
      .dstRRESP	                ( dwc_rs_initiatorRRESP     ),
      .dstRLAST	                ( dwc_rs_initiatorRLAST     ),
      .dstRUSER	                ( dwc_rs_initiatorRUSER     ),
      .dstRVALID	            ( dwc_rs_initiatorRVALID    ),
      .dstRREADY	            ( dwc_rs_initiatorRREADY    ),
      
      // Write Address Channel	
      .srcAWID	                ( cdc_dwc_initiatorAWID     ),
      .srcAWADDR	            ( cdc_dwc_initiatorAWADDR   ),
      .srcAWLEN	                ( cdc_dwc_initiatorAWLEN    ),
      .srcAWSIZE	            ( cdc_dwc_initiatorAWSIZE   ),
      .srcAWBURST	            ( cdc_dwc_initiatorAWBURST  ),
      .srcAWLOCK	            ( cdc_dwc_initiatorAWLOCK   ),
      .srcAWCACHE	            ( cdc_dwc_initiatorAWCACHE  ),
      .srcAWPROT	            ( cdc_dwc_initiatorAWPROT   ),
      .srcAWREGION              ( cdc_dwc_initiatorAWREGION ),
      .srcAWQOS	                ( cdc_dwc_initiatorAWQOS    ),
      .srcAWUSER	            ( cdc_dwc_initiatorAWUSER   ),
      .srcAWVALID	            ( cdc_dwc_initiatorAWVALID  ),
      .srcAWREADY	            ( cdc_dwc_initiatorAWREADY  ),
      
      .dstAWID	                ( dwc_rs_initiatorAWID      ),
      .dstAWADDR	            ( dwc_rs_initiatorAWADDR    ),
      .dstAWLEN	                ( dwc_rs_initiatorAWLEN     ),
      .dstAWSIZE	            ( dwc_rs_initiatorAWSIZE    ),
      .dstAWBURST	            ( dwc_rs_initiatorAWBURST   ),
      .dstAWLOCK	            ( dwc_rs_initiatorAWLOCK    ),
      .dstAWCACHE	            ( dwc_rs_initiatorAWCACHE   ),
      .dstAWPROT	            ( dwc_rs_initiatorAWPROT    ),
      .dstAWREGION              ( dwc_rs_initiatorAWREGION  ),
      .dstAWQOS	                ( dwc_rs_initiatorAWQOS     ),
      .dstAWUSER	            ( dwc_rs_initiatorAWUSER    ),
      .dstAWVALID	            ( dwc_rs_initiatorAWVALID   ),
      .dstAWREADY	            ( dwc_rs_initiatorAWREADY   ),
      
      // Write Data Channel	
      .srcWID                   ( cdc_dwc_initiatorWID     ),
      .srcWDATA	                ( cdc_dwc_initiatorWDATA   ),
      .srcWSTRB	                ( cdc_dwc_initiatorWSTRB   ),
      .srcWLAST	                ( cdc_dwc_initiatorWLAST   ),
      .srcWUSER	                ( cdc_dwc_initiatorWUSER   ),
      .srcWVALID	            ( cdc_dwc_initiatorWVALID  ),
      .srcWREADY	            ( cdc_dwc_initiatorWREADY  ),
      
      .dstWID                   ( dwc_rs_initiatorWID      ),
      .dstWDATA	                ( dwc_rs_initiatorWDATA    ),
      .dstWSTRB	                ( dwc_rs_initiatorWSTRB    ),
      .dstWLAST	                ( dwc_rs_initiatorWLAST    ),
      .dstWUSER	                ( dwc_rs_initiatorWUSER    ),
      .dstWVALID	            ( dwc_rs_initiatorWVALID   ),
      .dstWREADY	            ( dwc_rs_initiatorWREADY   ),	
      
      // Write Response Channel	
      .srcBID  	                ( cdc_dwc_initiatorBID     ),
      .srcBRESP	                ( cdc_dwc_initiatorBRESP   ),
      .srcBUSER	                ( cdc_dwc_initiatorBUSER   ),
      .srcBVALID	            ( cdc_dwc_initiatorBVALID  ),
      .srcBREADY	            ( cdc_dwc_initiatorBREADY  ),
      
      .dstBID	                ( dwc_rs_initiatorBID      ),
      .dstBRESP	                ( dwc_rs_initiatorBRESP    ),
      .dstBUSER	                ( dwc_rs_initiatorBUSER    ),
      .dstBVALID	            ( dwc_rs_initiatorBVALID   ),
      .dstBREADY	            ( dwc_rs_initiatorBREADY   )
      
      ) ;
	  
    caxi4interconnect_IntrDataWidthConv #
    (
    	.INITIATOR_TYPE         ( INITIATOR_TYPE            ) , 		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11
    	.INITIATOR_NUMBER       ( INITIATOR_NUMBER          ),	// initiator number
    	.MAX_TRANS  			( MAX_TRANS                 ),
    	.ID_WIDTH               ( ID_WIDTH                  ),
    	.ADDR_WIDTH             ( ADDR_WIDTH                ),				
    	.DATA_WIDTH             ( DATA_WIDTH                ), 
    	.INITIATOR_DATA_WIDTH   ( INITIATOR_DATA_WIDTH      ),
    	.USER_WIDTH             ( USER_WIDTH                ),
    	.DWC_ADDR_FIFO_DEPTH    ( DWC_ADDR_FIFO_DEPTH       ),
    	.DATA_FIFO_DEPTH        ( DWC_DATA_FIFO_DEPTH       ),
    	.READ_INTERLEAVE        ( READ_INTERLEAVE           ),
    	.PIPE                   ( PIPE                      ),
    	.DWC_RAM_TYPE           ( DWC_RAM_TYPE              ),
    	.SYNC_RESET             ( SYNC_RESET                )
    	
    ) intrrDWC 
    (
    	// Global Signals
    	.ACLK                   ( XBAR_CLK                  ),
    	.arst_sync              ( arst_sync                 ),	
    	.srst_sync              ( srst_sync                 ),	
    
    	// Initiator Read Address Ports
    	.INITIATOR_ARID		    ( dwc_rs_initiatorARID      ),
    	.INITIATOR_ARADDR		( dwc_rs_initiatorARADDR    ),
    	.INITIATOR_ARLEN		( dwc_rs_initiatorARLEN     ),
    	.INITIATOR_ARSIZE		( dwc_rs_initiatorARSIZE    ),
    	.INITIATOR_ARBURST		( dwc_rs_initiatorARBURST   ),
    	.INITIATOR_ARLOCK		( dwc_rs_initiatorARLOCK    ),
    	.INITIATOR_ARCACHE		( dwc_rs_initiatorARCACHE   ),
    	.INITIATOR_ARPROT		( dwc_rs_initiatorARPROT    ),
    	.INITIATOR_ARREGION	    ( dwc_rs_initiatorARREGION  ),
    	.INITIATOR_ARQOS		( dwc_rs_initiatorARQOS     ),
    	.INITIATOR_ARUSER		( dwc_rs_initiatorARUSER    ),
    	.INITIATOR_ARVALID		( dwc_rs_initiatorARVALID   ),
    	.INITIATOR_AWQOS		( dwc_rs_initiatorAWQOS     ),
    	.INITIATOR_AWREGION	    ( dwc_rs_initiatorAWREGION  ),
    	.INITIATOR_AWID		    ( dwc_rs_initiatorAWID      ),
    	.INITIATOR_AWADDR		( dwc_rs_initiatorAWADDR    ),
    	.INITIATOR_AWLEN		( dwc_rs_initiatorAWLEN     ),
    	.INITIATOR_AWSIZE		( dwc_rs_initiatorAWSIZE    ),
    	.INITIATOR_AWBURST		( dwc_rs_initiatorAWBURST   ),
    	.INITIATOR_AWLOCK		( dwc_rs_initiatorAWLOCK    ),
    	.INITIATOR_AWCACHE		( dwc_rs_initiatorAWCACHE   ),
    	.INITIATOR_AWPROT		( dwc_rs_initiatorAWPROT    ),
    	.INITIATOR_AWUSER		( dwc_rs_initiatorAWUSER    ),
    	.INITIATOR_AWVALID		( dwc_rs_initiatorAWVALID   ),
    	.INITIATOR_WID          ( dwc_rs_initiatorWID       ),
    	.INITIATOR_WDATA		( dwc_rs_initiatorWDATA     ),
    	.INITIATOR_WSTRB		( dwc_rs_initiatorWSTRB     ),
    	.INITIATOR_WLAST		( dwc_rs_initiatorWLAST     ),
    	.INITIATOR_WUSER		( dwc_rs_initiatorWUSER     ),
    	.INITIATOR_WVALID		( dwc_rs_initiatorWVALID    ),
    	.INITIATOR_BREADY		( dwc_rs_initiatorBREADY    ),
    	.INITIATOR_RREADY		( dwc_rs_initiatorRREADY    ),
    	.INITIATOR_ARREADY 	    ( dwc_rs_initiatorARREADY   ),
    	.INITIATOR_RID 		    ( dwc_rs_initiatorRID       ),
    	.INITIATOR_RDATA 		( dwc_rs_initiatorRDATA     ), // output from this module
    	.INITIATOR_RRESP 		( dwc_rs_initiatorRRESP     ),
    	.INITIATOR_RUSER 		( dwc_rs_initiatorRUSER     ),
    	.INITIATOR_BID 		    ( dwc_rs_initiatorBID       ),
    	.INITIATOR_BRESP 		( dwc_rs_initiatorBRESP     ),
    	.INITIATOR_BUSER 		( dwc_rs_initiatorBUSER     ),
    	.INITIATOR_RLAST 		( dwc_rs_initiatorRLAST     ),
    	.INITIATOR_RVALID 		( dwc_rs_initiatorRVALID    ),
    	.INITIATOR_AWREADY 	    ( dwc_rs_initiatorAWREADY   ),
    	.INITIATOR_WREADY 		( dwc_rs_initiatorWREADY    ),
    	.INITIATOR_BVALID 		( dwc_rs_initiatorBVALID    ),
    	
    	.initiatorARID			( dwc_sr_initiatorARID      ),
    	.initiatorARADDR		( dwc_sr_initiatorARADDR    ),
    	.initiatorARLEN		    ( dwc_sr_initiatorARLEN     ),
    	.initiatorARSIZE		( dwc_sr_initiatorARSIZE    ),
    	.initiatorARBURST		( dwc_sr_initiatorARBURST   ),
    	.initiatorARLOCK		( dwc_sr_initiatorARLOCK    ),
    	.initiatorARCACHE		( dwc_sr_initiatorARCACHE   ),
    	.initiatorARPROT		( dwc_sr_initiatorARPROT    ),
    	.initiatorARREGION		( dwc_sr_initiatorARREGION  ),
    	.initiatorARQOS		    ( dwc_sr_initiatorARQOS     ),
    	.initiatorARUSER		( dwc_sr_initiatorARUSER    ),
    	.initiatorARVALID		( dwc_sr_initiatorARVALID   ),
    	.initiatorAWQOS		    ( dwc_sr_initiatorAWQOS     ),
    	.initiatorAWREGION		( dwc_sr_initiatorAWREGION  ),
    	.initiatorAWID			( dwc_sr_initiatorAWID      ),
    	.initiatorAWADDR		( dwc_sr_initiatorAWADDR    ),
    	.initiatorAWLEN		    ( dwc_sr_initiatorAWLEN     ),
    	.initiatorAWSIZE		( dwc_sr_initiatorAWSIZE    ),
    	.initiatorAWBURST		( dwc_sr_initiatorAWBURST   ),
    	.initiatorAWLOCK		( dwc_sr_initiatorAWLOCK    ),
    	.initiatorAWCACHE		( dwc_sr_initiatorAWCACHE   ),
    	.initiatorAWPROT		( dwc_sr_initiatorAWPROT    ),
    	.initiatorAWUSER		( dwc_sr_initiatorAWUSER    ),
    	.initiatorAWVALID		( dwc_sr_initiatorAWVALID   ),
    	.initiatorWID           ( dwc_sr_initiatorWID       ),
    	.initiatorWDATA		    ( dwc_sr_initiatorWDATA     ),
    	.initiatorWSTRB		    ( dwc_sr_initiatorWSTRB     ),
    	.initiatorWLAST		    ( dwc_sr_initiatorWLAST     ),
    	.initiatorWUSER		    ( dwc_sr_initiatorWUSER     ),
    	.initiatorWVALID		( dwc_sr_initiatorWVALID    ),
    	.initiatorBREADY		( dwc_sr_initiatorBREADY    ),
    	.initiatorRREADY		( dwc_sr_initiatorRREADY    ),
    	.initiatorARREADY 		( dwc_sr_initiatorARREADY   ),
    	.initiatorRID 			( dwc_sr_initiatorRID       ),
    	.initiatorRDATA 		( dwc_sr_initiatorRDATA     ), // Input to this module
    	.initiatorRRESP 		( dwc_sr_initiatorRRESP     ),
    	.initiatorRUSER 		( dwc_sr_initiatorRUSER     ),
    	.initiatorBID 			( dwc_sr_initiatorBID       ),
    	.initiatorBRESP 		( dwc_sr_initiatorBRESP     ),
    	.initiatorBUSER 		( dwc_sr_initiatorBUSER     ),
    	.initiatorRLAST 		( dwc_sr_initiatorRLAST     ),
    	.initiatorRVALID 		( dwc_sr_initiatorRVALID    ),
    	.initiatorAWREADY 		( dwc_sr_initiatorAWREADY   ),
    	.initiatorWREADY 		( dwc_sr_initiatorWREADY    ),
    	.initiatorBVALID 		( dwc_sr_initiatorBVALID    )
    )  ;	  
	  
	  
	caxi4interconnect_RegisterSlice #  //Crossbar Register Slice

	(
		.AWCHAN	                ( AWCHAN_RS            ),			// 0 means no slice on channel - 1 means full slice on channel
		.ARCHAN	                ( ARCHAN_RS            ),			// 0 means no slice on channel - 1 means full slice on channel
		.RCHAN	                ( RCHAN_RS             ),			// 0 means no slice on channel - 1 means full slice on channel
		.WCHAN	                ( WCHAN_RS             ),			// 0 means no slice on channel - 1 means full slice on channel
		.BCHAN	                ( BCHAN_RS             ),			// 0 means no slice on channel - 1 means full slice on channel
		.ID_WIDTH   			( ID_WIDTH             ), 
		.ADDR_WIDTH      		( ADDR_WIDTH           ),
		.DATA_WIDTH 			( DATA_WIDTH           ), 
		.SUPPORT_USER_SIGNALS 	( SUPPORT_USER_SIGNALS ),
		.USER_WIDTH 			( USER_WIDTH           )
	) rgsl
	(

	//=====================================  Global Signals   ========================================================================
	.sysClk	    ( XBAR_CLK                 ),
	.arst_sync	( arst_sync                ),
	.srst_sync	( srst_sync                ),
  
	// Read Address Channel
	.srcARID	( dwc_sr_initiatorARID     ),
	.srcARADDR	( dwc_sr_initiatorARADDR   ),
	.srcARLEN	( dwc_sr_initiatorARLEN    ),
	.srcARSIZE	( dwc_sr_initiatorARSIZE   ),
	.srcARBURST	( dwc_sr_initiatorARBURST  ),
	.srcARLOCK	( dwc_sr_initiatorARLOCK   ),
	.srcARCACHE	( dwc_sr_initiatorARCACHE  ),
	.srcARPROT	( dwc_sr_initiatorARPROT   ),
	.srcARREGION( dwc_sr_initiatorARREGION ),
	.srcARQOS	( dwc_sr_initiatorARQOS    ),
	.srcARUSER	( dwc_sr_initiatorARUSER   ),
	.srcARVALID	( dwc_sr_initiatorARVALID  ),
	.srcARREADY	( dwc_sr_initiatorARREADY  ),
	
	.dstARID	( int_initiatorARID        ),
	.dstARADDR	( int_initiatorARADDR      ),
	.dstARLEN	( int_initiatorARLEN       ),
	.dstARSIZE	( int_initiatorARSIZE      ),
	.dstARBURST	( int_initiatorARBURST     ),
	.dstARLOCK	( int_initiatorARLOCK      ),
	.dstARCACHE	( int_initiatorARCACHE     ),
	.dstARPROT	( int_initiatorARPROT      ),
	.dstARREGION( int_initiatorARREGION    ),
	.dstARQOS	( int_initiatorARQOS       ),
	.dstARUSER	( int_initiatorARUSER      ),
	.dstARVALID	( int_initiatorARVALID     ),
	.dstARREADY	( int_initiatorARREADY     ),
	
	// Read Data Channel	
	.srcRID		( dwc_sr_initiatorRID      ),
	.srcRDATA	( dwc_sr_initiatorRDATA    ), // Output from this module
	.srcRRESP	( dwc_sr_initiatorRRESP    ),
	.srcRLAST	( dwc_sr_initiatorRLAST    ),
	.srcRUSER	( dwc_sr_initiatorRUSER    ),
	.srcRVALID	( dwc_sr_initiatorRVALID   ),
	.srcRREADY	( dwc_sr_initiatorRREADY   ),
	
	.dstRID		( int_initiatorRID         ),
	.dstRDATA	( int_initiatorRDATA       ), // input to this module // sr_cdc_initiatorRDATA is input to this file
	.dstRRESP	( int_initiatorRRESP       ),
	.dstRLAST	( int_initiatorRLAST       ),
	.dstRUSER	( int_initiatorRUSER       ),
	.dstRVALID	( int_initiatorRVALID      ),
	.dstRREADY	( int_initiatorRREADY      ),
	
	// Write Address Channel	
	.srcAWID	( dwc_sr_initiatorAWID     ),
	.srcAWADDR	( dwc_sr_initiatorAWADDR   ),
	.srcAWLEN	( dwc_sr_initiatorAWLEN    ),
	.srcAWSIZE	( dwc_sr_initiatorAWSIZE   ),
	.srcAWBURST	( dwc_sr_initiatorAWBURST  ),
	.srcAWLOCK	( dwc_sr_initiatorAWLOCK   ),
	.srcAWCACHE	( dwc_sr_initiatorAWCACHE  ),
	.srcAWPROT	( dwc_sr_initiatorAWPROT   ),
	.srcAWREGION( dwc_sr_initiatorAWREGION ),
	.srcAWQOS	( dwc_sr_initiatorAWQOS    ),
	.srcAWUSER	( dwc_sr_initiatorAWUSER   ),
	.srcAWVALID	( dwc_sr_initiatorAWVALID  ),
	.srcAWREADY	( dwc_sr_initiatorAWREADY  ),
	
	.dstAWID	( int_initiatorAWID        ),
	.dstAWADDR	( int_initiatorAWADDR      ),
	.dstAWLEN	( int_initiatorAWLEN       ),
	.dstAWSIZE	( int_initiatorAWSIZE      ),
	.dstAWBURST	( int_initiatorAWBURST     ),
	.dstAWLOCK	( int_initiatorAWLOCK      ),
	.dstAWCACHE	( int_initiatorAWCACHE     ),
	.dstAWPROT	( int_initiatorAWPROT      ),
	.dstAWREGION( int_initiatorAWREGION    ),
	.dstAWQOS	( int_initiatorAWQOS       ),
	.dstAWUSER	( int_initiatorAWUSER      ),
	.dstAWVALID	( int_initiatorAWVALID     ),
	.dstAWREADY	( int_initiatorAWREADY     ),

	// Write Data Channel	
	.srcWID     ( dwc_sr_initiatorWID      ),
	.srcWDATA	( dwc_sr_initiatorWDATA    ),
	.srcWSTRB	( dwc_sr_initiatorWSTRB    ),
	.srcWLAST	( dwc_sr_initiatorWLAST    ),
	.srcWUSER	( dwc_sr_initiatorWUSER    ),
	.srcWVALID	( dwc_sr_initiatorWVALID   ),
	.srcWREADY	( dwc_sr_initiatorWREADY   ),
	
	.dstWID     ( int_initiatorWID         ),
	.dstWDATA	( int_initiatorWDATA       ),
	.dstWSTRB	( int_initiatorWSTRB       ),
	.dstWLAST	( int_initiatorWLAST       ),
	.dstWUSER	( int_initiatorWUSER       ),
	.dstWVALID	( int_initiatorWVALID      ),
	.dstWREADY	( int_initiatorWREADY      ),	

	// Write Response Channel	
	.srcBID  	( dwc_sr_initiatorBID      ),
	.srcBRESP	( dwc_sr_initiatorBRESP    ),
	.srcBUSER	( dwc_sr_initiatorBUSER    ),
	.srcBVALID	( dwc_sr_initiatorBVALID   ),
	.srcBREADY	( dwc_sr_initiatorBREADY   ),

	.dstBID	    ( int_initiatorBID         ),
	.dstBRESP	( int_initiatorBRESP       ),
	.dstBUSER	( int_initiatorBUSER       ),
	.dstBVALID	( int_initiatorBVALID      ),
	.dstBREADY	( int_initiatorBREADY      )

	) ;	
	  
  end else begin //After DWC. DWC_RS->DWC->CDC
    caxi4interconnect_RegisterSlice #  //DWC Register Slice
    
    (
      .AWCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
      .ARCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
      .RCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
      .WCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
      .BCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
      .ID_WIDTH   			    ( ID_WIDTH             ), 
      .ADDR_WIDTH      		    ( ADDR_WIDTH           ),
      .DATA_WIDTH 			    ( INITIATOR_DATA_WIDTH ), 
      .SUPPORT_USER_SIGNALS 	( SUPPORT_USER_SIGNALS ),
      .USER_WIDTH 			    ( USER_WIDTH           )
    ) intr_dwc_rgsl
    (
    
    //=====================================  Global Signals   ========================================================================
      .sysClk	                ( INITR_CLK                 ),
      .arst_sync	            ( iarst_sync                ),
      .srst_sync	            ( isrst_sync                ),
      
      // Read Address Channel
      .srcARID	                ( prot_cdc_initiatorARID     ),
      .srcARADDR	            ( prot_cdc_initiatorARADDR   ),
      .srcARLEN	                ( prot_cdc_initiatorARLEN    ),
      .srcARSIZE	            ( prot_cdc_initiatorARSIZE   ),
      .srcARBURST	            ( prot_cdc_initiatorARBURST  ),
      .srcARLOCK	            ( prot_cdc_initiatorARLOCK   ),
      .srcARCACHE	            ( prot_cdc_initiatorARCACHE  ),
      .srcARPROT	            ( prot_cdc_initiatorARPROT   ),
      .srcARREGION              ( prot_cdc_initiatorARREGION ),
      .srcARQOS	                ( prot_cdc_initiatorARQOS    ),
      .srcARUSER	            ( prot_cdc_initiatorARUSER   ),
      .srcARVALID	            ( prot_cdc_initiatorARVALID  ),
      .srcARREADY	            ( prot_cdc_initiatorARREADY  ),
      
      .dstARID	                ( dwc_rs_initiatorARID      ),
      .dstARADDR	            ( dwc_rs_initiatorARADDR    ),
      .dstARLEN	                ( dwc_rs_initiatorARLEN     ),
      .dstARSIZE	            ( dwc_rs_initiatorARSIZE    ),
      .dstARBURST	            ( dwc_rs_initiatorARBURST   ),
      .dstARLOCK	            ( dwc_rs_initiatorARLOCK    ),
      .dstARCACHE	            ( dwc_rs_initiatorARCACHE   ),
      .dstARPROT	            ( dwc_rs_initiatorARPROT    ),
      .dstARREGION              ( dwc_rs_initiatorARREGION  ),
      .dstARQOS	                ( dwc_rs_initiatorARQOS     ),
      .dstARUSER	            ( dwc_rs_initiatorARUSER    ),
      .dstARVALID	            ( dwc_rs_initiatorARVALID   ),
      .dstARREADY	            ( dwc_rs_initiatorARREADY   ),
      
      // Read Data Channel	
      .srcRID		            ( prot_cdc_initiatorRID      ),
      .srcRDATA	                ( prot_cdc_initiatorRDATA    ), // Output from this module
      .srcRRESP	                ( prot_cdc_initiatorRRESP    ),
      .srcRLAST	                ( prot_cdc_initiatorRLAST    ),
      .srcRUSER	                ( prot_cdc_initiatorRUSER    ),
      .srcRVALID	            ( prot_cdc_initiatorRVALID   ),
      .srcRREADY	            ( prot_cdc_initiatorRREADY   ),
      
      .dstRID		            ( dwc_rs_initiatorRID       ),
      .dstRDATA	                ( dwc_rs_initiatorRDATA     ), // input to this module // sr_cdc_initiatorRDATA is input to this file
      .dstRRESP	                ( dwc_rs_initiatorRRESP     ),
      .dstRLAST	                ( dwc_rs_initiatorRLAST     ),
      .dstRUSER	                ( dwc_rs_initiatorRUSER     ),
      .dstRVALID	            ( dwc_rs_initiatorRVALID    ),
      .dstRREADY	            ( dwc_rs_initiatorRREADY    ),
      
      // Write Address Channel	
      .srcAWID	                ( prot_cdc_initiatorAWID     ),
      .srcAWADDR	            ( prot_cdc_initiatorAWADDR   ),
      .srcAWLEN	                ( prot_cdc_initiatorAWLEN    ),
      .srcAWSIZE	            ( prot_cdc_initiatorAWSIZE   ),
      .srcAWBURST	            ( prot_cdc_initiatorAWBURST  ),
      .srcAWLOCK	            ( prot_cdc_initiatorAWLOCK   ),
      .srcAWCACHE	            ( prot_cdc_initiatorAWCACHE  ),
      .srcAWPROT	            ( prot_cdc_initiatorAWPROT   ),
      .srcAWREGION              ( prot_cdc_initiatorAWREGION ),
      .srcAWQOS	                ( prot_cdc_initiatorAWQOS    ),
      .srcAWUSER	            ( prot_cdc_initiatorAWUSER   ),
      .srcAWVALID	            ( prot_cdc_initiatorAWVALID  ),
      .srcAWREADY	            ( prot_cdc_initiatorAWREADY  ),
      
      .dstAWID	                ( dwc_rs_initiatorAWID      ),
      .dstAWADDR	            ( dwc_rs_initiatorAWADDR    ),
      .dstAWLEN	                ( dwc_rs_initiatorAWLEN     ),
      .dstAWSIZE	            ( dwc_rs_initiatorAWSIZE    ),
      .dstAWBURST	            ( dwc_rs_initiatorAWBURST   ),
      .dstAWLOCK	            ( dwc_rs_initiatorAWLOCK    ),
      .dstAWCACHE	            ( dwc_rs_initiatorAWCACHE   ),
      .dstAWPROT	            ( dwc_rs_initiatorAWPROT    ),
      .dstAWREGION              ( dwc_rs_initiatorAWREGION  ),
      .dstAWQOS	                ( dwc_rs_initiatorAWQOS     ),
      .dstAWUSER	            ( dwc_rs_initiatorAWUSER    ),
      .dstAWVALID	            ( dwc_rs_initiatorAWVALID   ),
      .dstAWREADY	            ( dwc_rs_initiatorAWREADY   ),
      
      // Write Data Channel	
      .srcWID                   ( prot_cdc_initiatorWID     ),
      .srcWDATA	                ( prot_cdc_initiatorWDATA   ),
      .srcWSTRB	                ( prot_cdc_initiatorWSTRB   ),
      .srcWLAST	                ( prot_cdc_initiatorWLAST   ),
      .srcWUSER	                ( prot_cdc_initiatorWUSER   ),
      .srcWVALID	            ( prot_cdc_initiatorWVALID  ),
      .srcWREADY	            ( prot_cdc_initiatorWREADY  ),
      
      .dstWID                   ( dwc_rs_initiatorWID      ),
      .dstWDATA	                ( dwc_rs_initiatorWDATA    ),
      .dstWSTRB	                ( dwc_rs_initiatorWSTRB    ),
      .dstWLAST	                ( dwc_rs_initiatorWLAST    ),
      .dstWUSER	                ( dwc_rs_initiatorWUSER    ),
      .dstWVALID	            ( dwc_rs_initiatorWVALID   ),
      .dstWREADY	            ( dwc_rs_initiatorWREADY   ),	
      
      // Write Response Channel	
      .srcBID  	                ( prot_cdc_initiatorBID     ),
      .srcBRESP	                ( prot_cdc_initiatorBRESP   ),
      .srcBUSER	                ( prot_cdc_initiatorBUSER   ),
      .srcBVALID	            ( prot_cdc_initiatorBVALID  ),
      .srcBREADY	            ( prot_cdc_initiatorBREADY  ),
      
      .dstBID	                ( dwc_rs_initiatorBID      ),
      .dstBRESP	                ( dwc_rs_initiatorBRESP    ),
      .dstBUSER	                ( dwc_rs_initiatorBUSER    ),
      .dstBVALID	            ( dwc_rs_initiatorBVALID   ),
      .dstBREADY	            ( dwc_rs_initiatorBREADY   )
      
      ) ;
	  
    caxi4interconnect_IntrDataWidthConv #
      (
      	.INITIATOR_TYPE         ( INITIATOR_TYPE            ) , 		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11
      	.INITIATOR_NUMBER       ( INITIATOR_NUMBER          ),	// initiator number
      	.MAX_TRANS  			( MAX_TRANS                 ),
      	.ID_WIDTH               ( ID_WIDTH                  ),
      	.ADDR_WIDTH             ( ADDR_WIDTH                ),				
      	.DATA_WIDTH             ( DATA_WIDTH                ), 
      	.INITIATOR_DATA_WIDTH   ( INITIATOR_DATA_WIDTH      ),
      	.USER_WIDTH             ( USER_WIDTH                ),
      	.DWC_ADDR_FIFO_DEPTH    ( DWC_ADDR_FIFO_DEPTH       ),
      	.DATA_FIFO_DEPTH        ( DWC_DATA_FIFO_DEPTH       ),
      	.READ_INTERLEAVE        ( READ_INTERLEAVE           ),
      	.PIPE                   ( PIPE                      ),
      	.DWC_RAM_TYPE           ( DWC_RAM_TYPE              ),
      	.SYNC_RESET             ( SYNC_RESET                )
      	
      ) intrrDWC 
      (
      	// Global Signals
      	.ACLK                   ( INITR_CLK                 ),
      	.arst_sync              ( iarst_sync                ),	
      	.srst_sync              ( isrst_sync                ),	
      
      	// Initiator Read Address Ports
      	.INITIATOR_ARID		    ( dwc_rs_initiatorARID      ),
      	.INITIATOR_ARADDR		( dwc_rs_initiatorARADDR    ),
      	.INITIATOR_ARLEN		( dwc_rs_initiatorARLEN     ),
      	.INITIATOR_ARSIZE		( dwc_rs_initiatorARSIZE    ),
      	.INITIATOR_ARBURST		( dwc_rs_initiatorARBURST   ),
      	.INITIATOR_ARLOCK		( dwc_rs_initiatorARLOCK    ),
      	.INITIATOR_ARCACHE		( dwc_rs_initiatorARCACHE   ),
      	.INITIATOR_ARPROT		( dwc_rs_initiatorARPROT    ),
      	.INITIATOR_ARREGION	    ( dwc_rs_initiatorARREGION  ),
      	.INITIATOR_ARQOS		( dwc_rs_initiatorARQOS     ),
      	.INITIATOR_ARUSER		( dwc_rs_initiatorARUSER    ),
      	.INITIATOR_ARVALID		( dwc_rs_initiatorARVALID   ),
      	.INITIATOR_AWQOS		( dwc_rs_initiatorAWQOS     ),
      	.INITIATOR_AWREGION	    ( dwc_rs_initiatorAWREGION  ),
      	.INITIATOR_AWID		    ( dwc_rs_initiatorAWID      ),
      	.INITIATOR_AWADDR		( dwc_rs_initiatorAWADDR    ),
      	.INITIATOR_AWLEN		( dwc_rs_initiatorAWLEN     ),
      	.INITIATOR_AWSIZE		( dwc_rs_initiatorAWSIZE    ),
      	.INITIATOR_AWBURST		( dwc_rs_initiatorAWBURST   ),
      	.INITIATOR_AWLOCK		( dwc_rs_initiatorAWLOCK    ),
      	.INITIATOR_AWCACHE		( dwc_rs_initiatorAWCACHE   ),
      	.INITIATOR_AWPROT		( dwc_rs_initiatorAWPROT    ),
      	.INITIATOR_AWUSER		( dwc_rs_initiatorAWUSER    ),
      	.INITIATOR_AWVALID		( dwc_rs_initiatorAWVALID   ),
      	.INITIATOR_WID          ( dwc_rs_initiatorWID       ),
      	.INITIATOR_WDATA		( dwc_rs_initiatorWDATA     ),
      	.INITIATOR_WSTRB		( dwc_rs_initiatorWSTRB     ),
      	.INITIATOR_WLAST		( dwc_rs_initiatorWLAST     ),
      	.INITIATOR_WUSER		( dwc_rs_initiatorWUSER     ),
      	.INITIATOR_WVALID		( dwc_rs_initiatorWVALID    ),
      	.INITIATOR_BREADY		( dwc_rs_initiatorBREADY    ),
      	.INITIATOR_RREADY		( dwc_rs_initiatorRREADY    ),
      	.INITIATOR_ARREADY 	    ( dwc_rs_initiatorARREADY   ),
      	.INITIATOR_RID 		    ( dwc_rs_initiatorRID       ),
      	.INITIATOR_RDATA 		( dwc_rs_initiatorRDATA     ), // output from this module
      	.INITIATOR_RRESP 		( dwc_rs_initiatorRRESP     ),
      	.INITIATOR_RUSER 		( dwc_rs_initiatorRUSER     ),
      	.INITIATOR_BID 		    ( dwc_rs_initiatorBID       ),
      	.INITIATOR_BRESP 		( dwc_rs_initiatorBRESP     ),
      	.INITIATOR_BUSER 		( dwc_rs_initiatorBUSER     ),
      	.INITIATOR_RLAST 		( dwc_rs_initiatorRLAST     ),
      	.INITIATOR_RVALID 		( dwc_rs_initiatorRVALID    ),
      	.INITIATOR_AWREADY 	    ( dwc_rs_initiatorAWREADY   ),
      	.INITIATOR_WREADY 		( dwc_rs_initiatorWREADY    ),
      	.INITIATOR_BVALID 		( dwc_rs_initiatorBVALID    ),
      	
      	.initiatorARID			( dwc_sr_initiatorARID      ),
      	.initiatorARADDR		( dwc_sr_initiatorARADDR    ),
      	.initiatorARLEN		    ( dwc_sr_initiatorARLEN     ),
      	.initiatorARSIZE		( dwc_sr_initiatorARSIZE    ),
      	.initiatorARBURST		( dwc_sr_initiatorARBURST   ),
      	.initiatorARLOCK		( dwc_sr_initiatorARLOCK    ),
      	.initiatorARCACHE		( dwc_sr_initiatorARCACHE   ),
      	.initiatorARPROT		( dwc_sr_initiatorARPROT    ),
      	.initiatorARREGION		( dwc_sr_initiatorARREGION  ),
      	.initiatorARQOS		    ( dwc_sr_initiatorARQOS     ),
      	.initiatorARUSER		( dwc_sr_initiatorARUSER    ),
      	.initiatorARVALID		( dwc_sr_initiatorARVALID   ),
      	.initiatorAWQOS		    ( dwc_sr_initiatorAWQOS     ),
      	.initiatorAWREGION		( dwc_sr_initiatorAWREGION  ),
      	.initiatorAWID			( dwc_sr_initiatorAWID      ),
      	.initiatorAWADDR		( dwc_sr_initiatorAWADDR    ),
      	.initiatorAWLEN		    ( dwc_sr_initiatorAWLEN     ),
      	.initiatorAWSIZE		( dwc_sr_initiatorAWSIZE    ),
      	.initiatorAWBURST		( dwc_sr_initiatorAWBURST   ),
      	.initiatorAWLOCK		( dwc_sr_initiatorAWLOCK    ),
      	.initiatorAWCACHE		( dwc_sr_initiatorAWCACHE   ),
      	.initiatorAWPROT		( dwc_sr_initiatorAWPROT    ),
      	.initiatorAWUSER		( dwc_sr_initiatorAWUSER    ),
      	.initiatorAWVALID		( dwc_sr_initiatorAWVALID   ),
      	.initiatorWID           ( dwc_sr_initiatorWID       ),
      	.initiatorWDATA		    ( dwc_sr_initiatorWDATA     ),
      	.initiatorWSTRB		    ( dwc_sr_initiatorWSTRB     ),
      	.initiatorWLAST		    ( dwc_sr_initiatorWLAST     ),
      	.initiatorWUSER		    ( dwc_sr_initiatorWUSER     ),
      	.initiatorWVALID		( dwc_sr_initiatorWVALID    ),
      	.initiatorBREADY		( dwc_sr_initiatorBREADY    ),
      	.initiatorRREADY		( dwc_sr_initiatorRREADY    ),
      	.initiatorARREADY 		( dwc_sr_initiatorARREADY   ),
      	.initiatorRID 			( dwc_sr_initiatorRID       ),
      	.initiatorRDATA 		( dwc_sr_initiatorRDATA     ), // Input to this module
      	.initiatorRRESP 		( dwc_sr_initiatorRRESP     ),
      	.initiatorRUSER 		( dwc_sr_initiatorRUSER     ),
      	.initiatorBID 			( dwc_sr_initiatorBID       ),
      	.initiatorBRESP 		( dwc_sr_initiatorBRESP     ),
      	.initiatorBUSER 		( dwc_sr_initiatorBUSER     ),
      	.initiatorRLAST 		( dwc_sr_initiatorRLAST     ),
      	.initiatorRVALID 		( dwc_sr_initiatorRVALID    ),
      	.initiatorAWREADY 		( dwc_sr_initiatorAWREADY   ),
      	.initiatorWREADY 		( dwc_sr_initiatorWREADY    ),
      	.initiatorBVALID 		( dwc_sr_initiatorBVALID    )
      );	  


    caxi4interconnect_IntrClockDomainCrossing #
    (
    	.ID_WIDTH                   ( ID_WIDTH                   ),
    	.ADDR_WIDTH                 ( ADDR_WIDTH                 ),				
    	.INITIATOR_DATA_WIDTH       ( DATA_WIDTH                 ),
    	.USER_WIDTH                 ( USER_WIDTH                 ),
    	.CLOCK_DOMAIN_CROSSING      ( CLOCK_DOMAIN_CROSSING      ),
    	.CDC_FIFO_DEPTH             ( CDC_FIFO_DEPTH             ),
    	.CDC_ADDR_RESP_FIFO_DEPTH   ( CDC_ADDR_RESP_FIFO_DEPTH   ),
    	.INITIATOR_TYPE             ( INITIATOR_TYPE             ),  		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11
    	.READ_INTERLEAVE            ( READ_INTERLEAVE            ),
        .PIPE                       ( PIPE                       ),
        .CDC_RAM_TYPE               ( CDC_RAM_TYPE               ),
        .SYNC_RESET                 ( SYNC_RESET                 ),
        .NUM_STAGES                 ( NUM_STAGES                 )
    ) intrrCDC
    (
    	// Global Signals
    	.INITR_CLK                  ( INITR_CLK                  ),
    	.XBAR_CLK                   ( XBAR_CLK                   ),
    	.iarst_sync                 ( iarst_sync                 ),	
    	.isrst_sync                 ( isrst_sync                 ),	
    	.arst_sync                  ( arst_sync                  ),	
    	.srst_sync                  ( srst_sync                  ),	
    
    	// Initiator Read Address Ports
    	.INITIATOR_ARID		        ( dwc_sr_initiatorARID     ),
    	.INITIATOR_ARADDR		    ( dwc_sr_initiatorARADDR   ),
    	.INITIATOR_ARLEN		    ( dwc_sr_initiatorARLEN    ),
    	.INITIATOR_ARSIZE		    ( dwc_sr_initiatorARSIZE   ),
    	.INITIATOR_ARBURST		    ( dwc_sr_initiatorARBURST  ),
    	.INITIATOR_ARLOCK		    ( dwc_sr_initiatorARLOCK   ),
    	.INITIATOR_ARCACHE		    ( dwc_sr_initiatorARCACHE  ),
    	.INITIATOR_ARPROT		    ( dwc_sr_initiatorARPROT   ),
    	.INITIATOR_ARREGION	        ( dwc_sr_initiatorARREGION ),
    	.INITIATOR_ARQOS		    ( dwc_sr_initiatorARQOS    ),
    	.INITIATOR_ARUSER		    ( dwc_sr_initiatorARUSER   ),
    	.INITIATOR_ARVALID		    ( dwc_sr_initiatorARVALID  ),
    	.INITIATOR_AWQOS		    ( dwc_sr_initiatorAWQOS    ),
    	.INITIATOR_AWREGION	        ( dwc_sr_initiatorAWREGION ),
    	.INITIATOR_AWID		        ( dwc_sr_initiatorAWID     ),
    	.INITIATOR_AWADDR		    ( dwc_sr_initiatorAWADDR   ),
    	.INITIATOR_AWLEN		    ( dwc_sr_initiatorAWLEN    ),
    	.INITIATOR_AWSIZE		    ( dwc_sr_initiatorAWSIZE   ),
    	.INITIATOR_AWBURST		    ( dwc_sr_initiatorAWBURST  ),
    	.INITIATOR_AWLOCK		    ( dwc_sr_initiatorAWLOCK   ),
    	.INITIATOR_AWCACHE		    ( dwc_sr_initiatorAWCACHE  ),
    	.INITIATOR_AWPROT		    ( dwc_sr_initiatorAWPROT   ),
    	.INITIATOR_AWUSER		    ( dwc_sr_initiatorAWUSER   ),
    	.INITIATOR_AWVALID		    ( dwc_sr_initiatorAWVALID  ),
    	.INITIATOR_WID              ( dwc_sr_initiatorWID      ),
    	.INITIATOR_WDATA		    ( dwc_sr_initiatorWDATA    ),
    	.INITIATOR_WSTRB		    ( dwc_sr_initiatorWSTRB    ),
    	.INITIATOR_WLAST		    ( dwc_sr_initiatorWLAST    ),
    	.INITIATOR_WUSER		    ( dwc_sr_initiatorWUSER    ),
    	.INITIATOR_WVALID		    ( dwc_sr_initiatorWVALID   ),
    	.INITIATOR_BREADY		    ( dwc_sr_initiatorBREADY   ),
    	.INITIATOR_RREADY		    ( dwc_sr_initiatorRREADY   ),
    	.INITIATOR_ARREADY 	        ( dwc_sr_initiatorARREADY  ),
    	.INITIATOR_RID 		        ( dwc_sr_initiatorRID      ),
    	.INITIATOR_RDATA 		    ( dwc_sr_initiatorRDATA    ), // output from this module
    	.INITIATOR_RRESP 		    ( dwc_sr_initiatorRRESP    ),
    	.INITIATOR_RUSER 		    ( dwc_sr_initiatorRUSER    ),
    	.INITIATOR_BID 		        ( dwc_sr_initiatorBID      ),
    	.INITIATOR_BRESP 		    ( dwc_sr_initiatorBRESP    ),
    	.INITIATOR_BUSER 		    ( dwc_sr_initiatorBUSER    ),
    	.INITIATOR_RLAST 		    ( dwc_sr_initiatorRLAST    ),
    	.INITIATOR_RVALID 		    ( dwc_sr_initiatorRVALID   ),
    	.INITIATOR_AWREADY 	        ( dwc_sr_initiatorAWREADY  ),
    	.INITIATOR_WREADY 		    ( dwc_sr_initiatorWREADY   ),
    	.INITIATOR_BVALID 		    ( dwc_sr_initiatorBVALID   ),
    	
    	.int_initiatorARID			( cdc_rs_initiatorARID      ),
    	.int_initiatorARADDR		( cdc_rs_initiatorARADDR    ),
    	.int_initiatorARLEN		    ( cdc_rs_initiatorARLEN     ),
    	.int_initiatorARSIZE		( cdc_rs_initiatorARSIZE    ),
    	.int_initiatorARBURST		( cdc_rs_initiatorARBURST   ),
    	.int_initiatorARLOCK		( cdc_rs_initiatorARLOCK    ),
    	.int_initiatorARCACHE		( cdc_rs_initiatorARCACHE   ),
    	.int_initiatorARPROT		( cdc_rs_initiatorARPROT    ),
    	.int_initiatorARREGION		( cdc_rs_initiatorARREGION  ),
    	.int_initiatorARQOS		    ( cdc_rs_initiatorARQOS     ),
    	.int_initiatorARUSER		( cdc_rs_initiatorARUSER    ),
    	.int_initiatorARVALID		( cdc_rs_initiatorARVALID   ),
    	.int_initiatorAWQOS		    ( cdc_rs_initiatorAWQOS     ),
    	.int_initiatorAWREGION		( cdc_rs_initiatorAWREGION  ),
    	.int_initiatorAWID			( cdc_rs_initiatorAWID      ),
    	.int_initiatorAWADDR		( cdc_rs_initiatorAWADDR    ),
    	.int_initiatorAWLEN		    ( cdc_rs_initiatorAWLEN     ),
    	.int_initiatorAWSIZE		( cdc_rs_initiatorAWSIZE    ),
    	.int_initiatorAWBURST		( cdc_rs_initiatorAWBURST   ),
    	.int_initiatorAWLOCK		( cdc_rs_initiatorAWLOCK    ),
    	.int_initiatorAWCACHE		( cdc_rs_initiatorAWCACHE   ),
    	.int_initiatorAWPROT		( cdc_rs_initiatorAWPROT    ),
    	.int_initiatorAWUSER		( cdc_rs_initiatorAWUSER    ),
    	.int_initiatorAWVALID		( cdc_rs_initiatorAWVALID   ),
    	.int_initiatorWID           ( cdc_rs_initiatorWID       ),
    	.int_initiatorWDATA		    ( cdc_rs_initiatorWDATA     ),
    	.int_initiatorWSTRB		    ( cdc_rs_initiatorWSTRB     ),
    	.int_initiatorWLAST		    ( cdc_rs_initiatorWLAST     ),
    	.int_initiatorWUSER		    ( cdc_rs_initiatorWUSER     ),
    	.int_initiatorWVALID		( cdc_rs_initiatorWVALID    ),
    	.int_initiatorBREADY		( cdc_rs_initiatorBREADY    ),
    	.int_initiatorRREADY		( cdc_rs_initiatorRREADY    ),
    	.int_initiatorARREADY 		( cdc_rs_initiatorARREADY   ),
    	.int_initiatorRID 			( cdc_rs_initiatorRID       ),
    	.int_initiatorRDATA 		( cdc_rs_initiatorRDATA     ), // Input to this module
    	.int_initiatorRRESP 		( cdc_rs_initiatorRRESP     ),
    	.int_initiatorRUSER 		( cdc_rs_initiatorRUSER     ),
    	.int_initiatorBID 			( cdc_rs_initiatorBID       ),
    	.int_initiatorBRESP 		( cdc_rs_initiatorBRESP     ),
    	.int_initiatorBUSER 		( cdc_rs_initiatorBUSER     ),
    	.int_initiatorRLAST 		( cdc_rs_initiatorRLAST     ),
    	.int_initiatorRVALID 		( cdc_rs_initiatorRVALID    ),
    	.int_initiatorAWREADY 		( cdc_rs_initiatorAWREADY   ),
    	.int_initiatorWREADY 		( cdc_rs_initiatorWREADY    ),
    	.int_initiatorBVALID 		( cdc_rs_initiatorBVALID    )
    )  ;
	
	caxi4interconnect_RegisterSlice #  //Crossbar Register Slice

	(
		.AWCHAN	                ( AWCHAN_RS            ),			// 0 means no slice on channel - 1 means full slice on channel
		.ARCHAN	                ( ARCHAN_RS            ),			// 0 means no slice on channel - 1 means full slice on channel
		.RCHAN	                ( RCHAN_RS             ),			// 0 means no slice on channel - 1 means full slice on channel
		.WCHAN	                ( WCHAN_RS             ),			// 0 means no slice on channel - 1 means full slice on channel
		.BCHAN	                ( BCHAN_RS             ),			// 0 means no slice on channel - 1 means full slice on channel
		.ID_WIDTH   			( ID_WIDTH             ), 
		.ADDR_WIDTH      		( ADDR_WIDTH           ),
		.DATA_WIDTH 			( DATA_WIDTH           ), 
		.SUPPORT_USER_SIGNALS 	( SUPPORT_USER_SIGNALS ),
		.USER_WIDTH 			( USER_WIDTH           )
	) rgsl
	(

	//=====================================  Global Signals   ========================================================================
	.sysClk	    ( XBAR_CLK                 ),
	.arst_sync	( arst_sync                ),
	.srst_sync	( srst_sync                ),
  
	// Read Address Channel
	.srcARID	( cdc_rs_initiatorARID     ),
	.srcARADDR	( cdc_rs_initiatorARADDR   ),
	.srcARLEN	( cdc_rs_initiatorARLEN    ),
	.srcARSIZE	( cdc_rs_initiatorARSIZE   ),
	.srcARBURST	( cdc_rs_initiatorARBURST  ),
	.srcARLOCK	( cdc_rs_initiatorARLOCK   ),
	.srcARCACHE	( cdc_rs_initiatorARCACHE  ),
	.srcARPROT	( cdc_rs_initiatorARPROT   ),
	.srcARREGION( cdc_rs_initiatorARREGION ),
	.srcARQOS	( cdc_rs_initiatorARQOS    ),
	.srcARUSER	( cdc_rs_initiatorARUSER   ),
	.srcARVALID	( cdc_rs_initiatorARVALID  ),
	.srcARREADY	( cdc_rs_initiatorARREADY  ),
	
	.dstARID	( int_initiatorARID        ),
	.dstARADDR	( int_initiatorARADDR      ),
	.dstARLEN	( int_initiatorARLEN       ),
	.dstARSIZE	( int_initiatorARSIZE      ),
	.dstARBURST	( int_initiatorARBURST     ),
	.dstARLOCK	( int_initiatorARLOCK      ),
	.dstARCACHE	( int_initiatorARCACHE     ),
	.dstARPROT	( int_initiatorARPROT      ),
	.dstARREGION( int_initiatorARREGION    ),
	.dstARQOS	( int_initiatorARQOS       ),
	.dstARUSER	( int_initiatorARUSER      ),
	.dstARVALID	( int_initiatorARVALID     ),
	.dstARREADY	( int_initiatorARREADY     ),
	
	// Read Data Channel	
	.srcRID		( cdc_rs_initiatorRID      ),
	.srcRDATA	( cdc_rs_initiatorRDATA    ), // Output from this module
	.srcRRESP	( cdc_rs_initiatorRRESP    ),
	.srcRLAST	( cdc_rs_initiatorRLAST    ),
	.srcRUSER	( cdc_rs_initiatorRUSER    ),
	.srcRVALID	( cdc_rs_initiatorRVALID   ),
	.srcRREADY	( cdc_rs_initiatorRREADY   ),
	
	.dstRID		( int_initiatorRID         ),
	.dstRDATA	( int_initiatorRDATA       ), // input to this module // sr_cdc_initiatorRDATA is input to this file
	.dstRRESP	( int_initiatorRRESP       ),
	.dstRLAST	( int_initiatorRLAST       ),
	.dstRUSER	( int_initiatorRUSER       ),
	.dstRVALID	( int_initiatorRVALID      ),
	.dstRREADY	( int_initiatorRREADY      ),
	
	// Write Address Channel	
	.srcAWID	( cdc_rs_initiatorAWID     ),
	.srcAWADDR	( cdc_rs_initiatorAWADDR   ),
	.srcAWLEN	( cdc_rs_initiatorAWLEN    ),
	.srcAWSIZE	( cdc_rs_initiatorAWSIZE   ),
	.srcAWBURST	( cdc_rs_initiatorAWBURST  ),
	.srcAWLOCK	( cdc_rs_initiatorAWLOCK   ),
	.srcAWCACHE	( cdc_rs_initiatorAWCACHE  ),
	.srcAWPROT	( cdc_rs_initiatorAWPROT   ),
	.srcAWREGION( cdc_rs_initiatorAWREGION ),
	.srcAWQOS	( cdc_rs_initiatorAWQOS    ),
	.srcAWUSER	( cdc_rs_initiatorAWUSER   ),
	.srcAWVALID	( cdc_rs_initiatorAWVALID  ),
	.srcAWREADY	( cdc_rs_initiatorAWREADY  ),
	
	.dstAWID	( int_initiatorAWID        ),
	.dstAWADDR	( int_initiatorAWADDR      ),
	.dstAWLEN	( int_initiatorAWLEN       ),
	.dstAWSIZE	( int_initiatorAWSIZE      ),
	.dstAWBURST	( int_initiatorAWBURST     ),
	.dstAWLOCK	( int_initiatorAWLOCK      ),
	.dstAWCACHE	( int_initiatorAWCACHE     ),
	.dstAWPROT	( int_initiatorAWPROT      ),
	.dstAWREGION( int_initiatorAWREGION    ),
	.dstAWQOS	( int_initiatorAWQOS       ),
	.dstAWUSER	( int_initiatorAWUSER      ),
	.dstAWVALID	( int_initiatorAWVALID     ),
	.dstAWREADY	( int_initiatorAWREADY     ),

	// Write Data Channel	
	.srcWID     ( cdc_rs_initiatorWID      ),
	.srcWDATA	( cdc_rs_initiatorWDATA    ),
	.srcWSTRB	( cdc_rs_initiatorWSTRB    ),
	.srcWLAST	( cdc_rs_initiatorWLAST    ),
	.srcWUSER	( cdc_rs_initiatorWUSER    ),
	.srcWVALID	( cdc_rs_initiatorWVALID   ),
	.srcWREADY	( cdc_rs_initiatorWREADY   ),
	
	.dstWID     ( int_initiatorWID         ),
	.dstWDATA	( int_initiatorWDATA       ),
	.dstWSTRB	( int_initiatorWSTRB       ),
	.dstWLAST	( int_initiatorWLAST       ),
	.dstWUSER	( int_initiatorWUSER       ),
	.dstWVALID	( int_initiatorWVALID      ),
	.dstWREADY	( int_initiatorWREADY      ),	

	// Write Response Channel	
	.srcBID  	( cdc_rs_initiatorBID      ),
	.srcBRESP	( cdc_rs_initiatorBRESP    ),
	.srcBUSER	( cdc_rs_initiatorBUSER    ),
	.srcBVALID	( cdc_rs_initiatorBVALID   ),
	.srcBREADY	( cdc_rs_initiatorBREADY   ),

	.dstBID	    ( int_initiatorBID         ),
	.dstBRESP	( int_initiatorBRESP       ),
	.dstBUSER	( int_initiatorBUSER       ),
	.dstBVALID	( int_initiatorBVALID      ),
	.dstBREADY	( int_initiatorBREADY      )

	) ;	
	
  end 
endgenerate

						
genvar intr_rs; //Initiator input Register Slice
generate 
  if(INITIATOR_TYPE != 2'b10) begin 
    wire [ID_WIDTH-1:0] 	            arid_pipe      [NUM_RS_STAGES:0];
    wire [ADDR_WIDTH-1:0]	            araddr_pipe    [NUM_RS_STAGES:0];
    wire [7:0]        		            arlen_pipe     [NUM_RS_STAGES:0];
    wire [2:0]          	            arsize_pipe    [NUM_RS_STAGES:0];
    wire [1:0]          	            arburst_pipe   [NUM_RS_STAGES:0];
    wire [1:0]          	            arlock_pipe    [NUM_RS_STAGES:0];
    wire [3:0]           	            arcache_pipe   [NUM_RS_STAGES:0];
    wire [2:0]         		            arprot_pipe    [NUM_RS_STAGES:0];
    wire [3:0]          	            arregion_pipe  [NUM_RS_STAGES:0];
    wire [3:0]          	            arqos_pipe     [NUM_RS_STAGES:0];
    wire [USER_WIDTH-1:0]	            aruser_pipe    [NUM_RS_STAGES:0];
    wire            		            arvalid_pipe   [NUM_RS_STAGES:0];
    wire            		            arready_pipe   [NUM_RS_STAGES:0];
    wire [ID_WIDTH-1:0]   	            rid_pipe       [NUM_RS_STAGES:0];
    wire [INITIATOR_DATA_WIDTH-1:0]	    rdata_pipe     [NUM_RS_STAGES:0];
    wire [1:0]           	            rresp_pipe     [NUM_RS_STAGES:0];
    wire                	            rlast_pipe     [NUM_RS_STAGES:0];
    wire [USER_WIDTH-1:0] 	            ruser_pipe     [NUM_RS_STAGES:0];
    wire                 	            rvalid_pipe    [NUM_RS_STAGES:0];
    wire               		            rready_pipe    [NUM_RS_STAGES:0];
    wire [ID_WIDTH-1:0]  	            awid_pipe      [NUM_RS_STAGES:0];
    wire [ADDR_WIDTH-1:0] 	            awaddr_pipe    [NUM_RS_STAGES:0];
    wire [7:0]           	            awlen_pipe     [NUM_RS_STAGES:0];
    wire [2:0]           	            awsize_pipe    [NUM_RS_STAGES:0];
    wire [1:0]           	            awburst_pipe   [NUM_RS_STAGES:0];
    wire [1:0]           	            awlock_pipe    [NUM_RS_STAGES:0];
    wire [3:0]          	            awcache_pipe   [NUM_RS_STAGES:0];
    wire [2:0]           	            awprot_pipe    [NUM_RS_STAGES:0];
    wire [3:0]            	            awregion_pipe  [NUM_RS_STAGES:0];
    wire [3:0]           	            awqos_pipe     [NUM_RS_STAGES:0];
    wire [USER_WIDTH-1:0]               awuser_pipe    [NUM_RS_STAGES:0];
    wire                 	            awvalid_pipe   [NUM_RS_STAGES:0];
    wire                	            awready_pipe   [NUM_RS_STAGES:0];	
    wire [ID_WIDTH-1:0]                 wid_pipe       [NUM_RS_STAGES:0];
    wire [INITIATOR_DATA_WIDTH-1:0]     wdata_pipe     [NUM_RS_STAGES:0];
    wire [(INITIATOR_DATA_WIDTH/8)-1:0] wstrb_pipe     [NUM_RS_STAGES:0];
    wire                  	            wlast_pipe     [NUM_RS_STAGES:0];
    wire [USER_WIDTH-1:0] 	            wuser_pipe     [NUM_RS_STAGES:0];
    wire                  	            wvalid_pipe    [NUM_RS_STAGES:0];
    wire                   	            wready_pipe    [NUM_RS_STAGES:0];	
    wire [ID_WIDTH-1:0]		            bid_pipe       [NUM_RS_STAGES:0];
    wire [1:0]           	            bresp_pipe     [NUM_RS_STAGES:0];
    wire [USER_WIDTH-1:0] 	            buser_pipe     [NUM_RS_STAGES:0];
    wire      				            bvalid_pipe    [NUM_RS_STAGES:0];
    wire					            bready_pipe    [NUM_RS_STAGES:0];

    // Connect module inputs to first stage
    assign arid_pipe[0]        = INITIATOR_ARID     ;
    assign araddr_pipe[0]      = INITIATOR_ARADDR   ;
    assign arlen_pipe[0]       = INITIATOR_ARLEN    ;
    assign arsize_pipe[0]      = INITIATOR_ARSIZE   ;
    assign arburst_pipe[0]     = INITIATOR_ARBURST  ;
    assign arlock_pipe[0]      = INITIATOR_ARLOCK   ;
    assign arcache_pipe[0]     = INITIATOR_ARCACHE  ;
    assign arprot_pipe[0]      = INITIATOR_ARPROT   ;
    assign arregion_pipe[0]    = INITIATOR_ARREGION ;
    assign arqos_pipe[0]       = INITIATOR_ARQOS    ;
    assign aruser_pipe[0]      = INITIATOR_ARUSER   ;
    assign arvalid_pipe[0]     = INITIATOR_ARVALID  ;
    assign INITIATOR_ARREADY   = arready_pipe[0]    ;

    assign INITIATOR_RID       = rid_pipe   [0]     ;
    assign INITIATOR_RDATA     = rdata_pipe [0]     ;
    assign INITIATOR_RRESP     = rresp_pipe [0]     ;
    assign INITIATOR_RLAST     = rlast_pipe [0]     ;
    assign INITIATOR_RUSER     = ruser_pipe [0]     ;
    assign INITIATOR_RVALID    = rvalid_pipe[0]     ;
    assign rready_pipe[0]      = INITIATOR_RREADY   ; 

    assign awid_pipe[0]        = INITIATOR_AWID     ;
    assign awaddr_pipe[0]      = INITIATOR_AWADDR   ;
    assign awlen_pipe[0]       = INITIATOR_AWLEN    ;
    assign awsize_pipe[0]      = INITIATOR_AWSIZE   ;
    assign awburst_pipe[0]     = INITIATOR_AWBURST  ;
    assign awlock_pipe[0]      = INITIATOR_AWLOCK   ;
    assign awcache_pipe[0]     = INITIATOR_AWCACHE  ;
    assign awprot_pipe[0]      = INITIATOR_AWPROT   ;
    assign awregion_pipe[0]    = INITIATOR_AWREGION ;
    assign awqos_pipe[0]       = INITIATOR_AWQOS    ;
    assign awuser_pipe[0]      = INITIATOR_AWUSER   ;
    assign awvalid_pipe[0]     = INITIATOR_AWVALID  ;
    assign INITIATOR_AWREADY   = awready_pipe[0]    ;
	
	assign wid_pipe    [0]     = INITIATOR_WID      ;
	assign wdata_pipe  [0]     = INITIATOR_WDATA    ;
	assign wstrb_pipe  [0]     = INITIATOR_WSTRB    ;
	assign wlast_pipe  [0]     = INITIATOR_WLAST    ;
	assign wuser_pipe  [0]     = INITIATOR_WUSER    ;
	assign wvalid_pipe [0]     = INITIATOR_WVALID   ;
	assign INITIATOR_WREADY    = wready_pipe[0]     ;
	
	assign INITIATOR_BID       = bid_pipe    [0]    ;     
	assign INITIATOR_BRESP     = bresp_pipe  [0]    ;     
	assign INITIATOR_BUSER     = buser_pipe  [0]    ;     
	assign INITIATOR_BVALID    = bvalid_pipe [0]    ;     
	assign bready_pipe[0]      = INITIATOR_BREADY   ;     
	

    if(NUM_RS_STAGES != 0) begin 
      for(intr_rs=0; intr_rs<NUM_RS_STAGES; intr_rs=intr_rs+1) begin 
        caxi4interconnect_RegisterSlice #
	    (
	    	.AWCHAN			     (1                      ),		
	    	.ARCHAN			     (1                      ),		
	    	.RCHAN			     (1                      ),		
	    	.WCHAN			     (1                      ),		
	    	.BCHAN			     (1                      ),									 
	    	.ID_WIDTH   		 (ID_WIDTH               ),							 
	    	.ADDR_WIDTH      	 (ADDR_WIDTH             ),
	    	.DATA_WIDTH 		 (INITIATOR_DATA_WIDTH   ),							 
	    	.SUPPORT_USER_SIGNALS(SUPPORT_USER_SIGNALS   ),
	    	.USER_WIDTH 		 (USER_WIDTH             ), 	
	    	.READY_REG   		 ( 1                     )  	
	    ) intr_rs_in_inst
	    (
	    //=====================================  Global Signals   ========================================================================
	      .sysClk        (INITR_CLK                    ),
	      .arst_sync     (iarst_sync                   ),
	      .srst_sync     (isrst_sync                   ),
		  
	      .srcARID       (arid_pipe       [intr_rs]    ),
	      .srcARADDR     (araddr_pipe     [intr_rs]    ),
	      .srcARLEN      (arlen_pipe      [intr_rs]    ),
	      .srcARSIZE     (arsize_pipe     [intr_rs]    ),
	      .srcARBURST    (arburst_pipe    [intr_rs]    ),
	      .srcARLOCK     (arlock_pipe     [intr_rs]    ),
	      .srcARCACHE    (arcache_pipe    [intr_rs]    ),
	      .srcARPROT     (arprot_pipe     [intr_rs]    ),
	      .srcARREGION   (arregion_pipe   [intr_rs]    ),
	      .srcARQOS      (arqos_pipe      [intr_rs]    ),
	      .srcARUSER     (aruser_pipe     [intr_rs]    ),
	      .srcARVALID    (arvalid_pipe    [intr_rs]    ),
	      .srcARREADY    (arready_pipe    [intr_rs]    ),
		  
	      .dstARID       (arid_pipe       [intr_rs+1]  ),
	      .dstARADDR     (araddr_pipe     [intr_rs+1]  ),
	      .dstARLEN      (arlen_pipe      [intr_rs+1]  ),
	      .dstARSIZE     (arsize_pipe     [intr_rs+1]  ),
	      .dstARBURST    (arburst_pipe    [intr_rs+1]  ),
	      .dstARLOCK     (arlock_pipe     [intr_rs+1]  ),
	      .dstARCACHE    (arcache_pipe    [intr_rs+1]  ),
	      .dstARPROT     (arprot_pipe     [intr_rs+1]  ),
	      .dstARREGION   (arregion_pipe   [intr_rs+1]  ),
	      .dstARQOS      (arqos_pipe      [intr_rs+1]  ),
	      .dstARUSER     (aruser_pipe     [intr_rs+1]  ),
	      .dstARVALID    (arvalid_pipe    [intr_rs+1]  ),
	      .dstARREADY    (arready_pipe    [intr_rs+1]  ),
		  
	      .dstRID        (rid_pipe        [intr_rs+1]  ),
	      .dstRDATA      (rdata_pipe      [intr_rs+1]  ),
	      .dstRRESP      (rresp_pipe      [intr_rs+1]  ),
	      .dstRLAST      (rlast_pipe      [intr_rs+1]  ),
	      .dstRUSER      (ruser_pipe      [intr_rs+1]  ),
	      .dstRVALID     (rvalid_pipe     [intr_rs+1]  ),
	      .dstRREADY     (rready_pipe     [intr_rs+1]  ),
		  
	      .srcRID        (rid_pipe        [intr_rs]    ),
	      .srcRDATA      (rdata_pipe      [intr_rs]    ),
	      .srcRRESP      (rresp_pipe      [intr_rs]    ),
	      .srcRLAST      (rlast_pipe      [intr_rs]    ),
	      .srcRUSER      (ruser_pipe      [intr_rs]    ),
	      .srcRVALID     (rvalid_pipe     [intr_rs]    ),
	      .srcRREADY     (rready_pipe     [intr_rs]    ),
		  
	      .srcAWID       (awid_pipe       [intr_rs]    ),
	      .srcAWADDR     (awaddr_pipe     [intr_rs]    ),
	      .srcAWLEN      (awlen_pipe      [intr_rs]    ),
	      .srcAWSIZE     (awsize_pipe     [intr_rs]    ),
	      .srcAWBURST    (awburst_pipe    [intr_rs]    ),
	      .srcAWLOCK     (awlock_pipe     [intr_rs]    ),
	      .srcAWCACHE    (awcache_pipe    [intr_rs]    ),
	      .srcAWPROT     (awprot_pipe     [intr_rs]    ),
	      .srcAWREGION   (awregion_pipe   [intr_rs]    ),
	      .srcAWQOS      (awqos_pipe      [intr_rs]    ),
	      .srcAWUSER     (awuser_pipe     [intr_rs]    ),
	      .srcAWVALID    (awvalid_pipe    [intr_rs]    ),
	      .srcAWREADY    (awready_pipe    [intr_rs]    ),
		  
	      .dstAWID       (awid_pipe       [intr_rs+1]  ),
	      .dstAWADDR     (awaddr_pipe     [intr_rs+1]  ),
	      .dstAWLEN      (awlen_pipe      [intr_rs+1]  ),
	      .dstAWSIZE     (awsize_pipe     [intr_rs+1]  ),
	      .dstAWBURST    (awburst_pipe    [intr_rs+1]  ),
	      .dstAWLOCK     (awlock_pipe     [intr_rs+1]  ),
	      .dstAWCACHE    (awcache_pipe    [intr_rs+1]  ),
	      .dstAWPROT     (awprot_pipe     [intr_rs+1]  ),
	      .dstAWREGION   (awregion_pipe   [intr_rs+1]  ),
	      .dstAWQOS      (awqos_pipe      [intr_rs+1]  ),
	      .dstAWUSER     (awuser_pipe     [intr_rs+1]  ),
	      .dstAWVALID    (awvalid_pipe    [intr_rs+1]  ),
	      .dstAWREADY    (awready_pipe    [intr_rs+1]  ),
		  
	      .srcWID        (wid_pipe        [intr_rs]    ),
	      .srcWDATA      (wdata_pipe      [intr_rs]    ),
	      .srcWSTRB      (wstrb_pipe      [intr_rs]    ),
	      .srcWLAST      (wlast_pipe      [intr_rs]    ),
	      .srcWUSER      (wuser_pipe      [intr_rs]    ),
	      .srcWVALID     (wvalid_pipe     [intr_rs]    ),
	      .srcWREADY     (wready_pipe     [intr_rs]    ),
		  
	      .dstWID        (wid_pipe        [intr_rs+1]  ),
	      .dstWDATA      (wdata_pipe      [intr_rs+1]  ),
	      .dstWSTRB      (wstrb_pipe      [intr_rs+1]  ),
	      .dstWLAST      (wlast_pipe      [intr_rs+1]  ),
	      .dstWUSER      (wuser_pipe      [intr_rs+1]  ),
	      .dstWVALID     (wvalid_pipe     [intr_rs+1]  ),
	      .dstWREADY     (wready_pipe     [intr_rs+1]  ),	
		  
	      .dstBID        (bid_pipe        [intr_rs+1]  ),
	      .dstBRESP      (bresp_pipe      [intr_rs+1]  ),
	      .dstBUSER      (buser_pipe      [intr_rs+1]  ),
	      .dstBVALID     (bvalid_pipe     [intr_rs+1]  ),
	      .dstBREADY     (bready_pipe     [intr_rs+1]  ),
		  
	      .srcBID        (bid_pipe        [intr_rs]    ),
	      .srcBRESP      (bresp_pipe      [intr_rs]    ),
	      .srcBUSER      (buser_pipe      [intr_rs]    ),
	      .srcBVALID     (bvalid_pipe     [intr_rs]    ),
	      .srcBREADY     (bready_pipe     [intr_rs]    )
	    );	
	  end 
	end 
	assign  arid_pipe_out                       =  arid_pipe     [NUM_RS_STAGES];   
	assign  araddr_pipe_out                     =  araddr_pipe   [NUM_RS_STAGES];  
	assign  arlen_pipe_out                      =  arlen_pipe    [NUM_RS_STAGES];  
	assign  arsize_pipe_out                     =  arsize_pipe   [NUM_RS_STAGES];  
	assign  arburst_pipe_out                    =  arburst_pipe  [NUM_RS_STAGES];  
	assign  arlock_pipe_out                     =  arlock_pipe   [NUM_RS_STAGES];  
	assign  arcache_pipe_out                    =  arcache_pipe  [NUM_RS_STAGES];  
	assign  arprot_pipe_out                     =  arprot_pipe   [NUM_RS_STAGES];  
	assign  arregion_pipe_out                   =  arregion_pipe [NUM_RS_STAGES];  
	assign  arqos_pipe_out                      =  arqos_pipe    [NUM_RS_STAGES];  
	assign  aruser_pipe_out                     =  aruser_pipe   [NUM_RS_STAGES];  
	assign  arvalid_pipe_out                    =  arvalid_pipe  [NUM_RS_STAGES];  
	assign  arready_pipe[NUM_RS_STAGES]         =  arready_pipe_out             ;  
	assign  rid_pipe    [NUM_RS_STAGES]         =  rid_pipe_out                 ;  
	assign  rdata_pipe  [NUM_RS_STAGES]         =  rdata_pipe_out               ;  
	assign  rresp_pipe  [NUM_RS_STAGES]         =  rresp_pipe_out               ;  
	assign  rlast_pipe  [NUM_RS_STAGES]         =  rlast_pipe_out               ;  
	assign  ruser_pipe  [NUM_RS_STAGES]         =  ruser_pipe_out               ;  
	assign  rvalid_pipe [NUM_RS_STAGES]         =  rvalid_pipe_out              ;  
	assign  rready_pipe_out                     =  rready_pipe   [NUM_RS_STAGES];  
	assign  awid_pipe_out                       =  awid_pipe     [NUM_RS_STAGES];  
	assign  awaddr_pipe_out                     =  awaddr_pipe   [NUM_RS_STAGES];  
	assign  awlen_pipe_out                      =  awlen_pipe    [NUM_RS_STAGES];  
	assign  awsize_pipe_out                     =  awsize_pipe   [NUM_RS_STAGES];  
	assign  awburst_pipe_out                    =  awburst_pipe  [NUM_RS_STAGES];  
	assign  awlock_pipe_out                     =  awlock_pipe   [NUM_RS_STAGES];  
	assign  awcache_pipe_out                    =  awcache_pipe  [NUM_RS_STAGES];  
	assign  awprot_pipe_out                     =  awprot_pipe   [NUM_RS_STAGES];  
	assign  awregion_pipe_out                   =  awregion_pipe [NUM_RS_STAGES];  
	assign  awqos_pipe_out                      =  awqos_pipe    [NUM_RS_STAGES];  
	assign  awuser_pipe_out                     =  awuser_pipe   [NUM_RS_STAGES];  
	assign  awvalid_pipe_out                    =  awvalid_pipe  [NUM_RS_STAGES];  
	assign  awready_pipe  [NUM_RS_STAGES]       =  awready_pipe_out             ;  
	assign  wid_pipe_out                        =  wid_pipe      [NUM_RS_STAGES];  
	assign  wdata_pipe_out                      =  wdata_pipe    [NUM_RS_STAGES];  
	assign  wstrb_pipe_out                      =  wstrb_pipe    [NUM_RS_STAGES];  
	assign  wlast_pipe_out                      =  wlast_pipe    [NUM_RS_STAGES];  
	assign  wuser_pipe_out                      =  wuser_pipe    [NUM_RS_STAGES];  
	assign  wvalid_pipe_out                     =  wvalid_pipe   [NUM_RS_STAGES];  
	assign  wready_pipe   [NUM_RS_STAGES]       = wready_pipe_out               ;  
	assign  bid_pipe      [NUM_RS_STAGES]       = bid_pipe_out                  ;  
	assign  bresp_pipe    [NUM_RS_STAGES]       = bresp_pipe_out                ;  
	assign  buser_pipe    [NUM_RS_STAGES]       = buser_pipe_out                ;  
	assign  bvalid_pipe   [NUM_RS_STAGES]       = bvalid_pipe_out               ;  
	assign  bready_pipe_out                     = bready_pipe   [NUM_RS_STAGES] ;  	
  end 
endgenerate 
endmodule		// caxi4interconnect_InitiatorConvertor.v
