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

module caxi4interconnect_TargetConvertor #

	(
  		parameter integer 	ID_WIDTH   		            = 3, 				// ID width includes infrastructure ID

		parameter integer 	TARGET_NUMBER	            = 0,				// Target number
		
		parameter 	        AWCHAN_RS		            = 0,		// 0 means no slice on channel - 1 means full slice on channel
		parameter 	        ARCHAN_RS		            = 0,		// 0 means no slice on channel - 1 means full slice on channel
		parameter 	        RCHAN_RS		            = 0,		// 0 means no slice on channel - 1 means full slice on channel
		parameter 	        WCHAN_RS		            = 0,		// 0 means no slice on channel - 1 means full slice on channel
		parameter 	        BCHAN_RS		            = 0,		// 0 means no slice on channel - 1 means full slice on channel
		parameter 	        DWC_CHAN_RS		            = 0,		// 0 means no slice on channel - 1 means full slice on channel
		
		parameter integer 	ADDR_WIDTH                  = 20,		
		parameter integer 	DATA_WIDTH 		            = 16, 
		parameter integer   TARGET_DATA_WIDTH	        = 32,
		
		parameter integer 	SUPPORT_USER_SIGNALS 	    = 0,
		parameter integer 	USER_WIDTH 				    = 1,

		parameter [1:0]     TARGET_TYPE			        = 2'b00,				// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11	
		parameter [0:0] 	READ_ZERO_TARGET_ID		    = 1'b1,	// disable interleave		
		parameter [0:0] 	WRITE_ZERO_TARGET_ID		= 1'b1,	// disable interleave		
		parameter integer 	TRGT_AXI4PRT_ADDRDEPTH 		= 8,		// Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
		parameter integer 	TRGT_AXI4PRT_DATADEPTH		= 8,			// Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
		parameter [13:0]    DWC_DATA_FIFO_DEPTH         = 14'h10,
  	    parameter integer   DWC_ADDR_FIFO_DEPTH         = 'h10,
        parameter           CLOCK_DOMAIN_CROSSING       = 1'b0,
        parameter           CDC_FIFO_DEPTH              = 16,
        parameter           CDC_ADDR_RESP_FIFO_DEPTH    = 16,
		parameter           READ_INTERLEAVE             = 1,
		parameter           MAX_TRANS                   = 4,
        parameter           PIPE                        = 0,
        parameter           CDC_RAM_TYPE                = 3,
        parameter           DWC_RAM_TYPE                = 3,
        parameter           PROTOCONV_RAM_TYPE          = 3,
        parameter           SYNC_RESET                  = 0,
        parameter           NUM_STAGES                  = 2,
   		parameter           NUM_RS_STAGES               = 0,
   		parameter           FAMILY                      = 26,
   		parameter           EXPOSE_RST                  = 0,
   		parameter           CDC_PLACEMENT               = 0,
   		parameter           BYPASS_CROSSBAR             = 0
		
	)
	(
	
	//================================= Global Signals  ==============================================================================
	input  wire           								TRGT_CLK,
	input  wire           								XBAR_CLK,
	input  wire          								ARESETN,
	input  wire          								arst_sync,
	input  wire          								srst_sync,
    output wire                                         t_sync_rstn,

	//================================================= to/from CrossBar Ports  =================================================
	input wire [ID_WIDTH-1:0]							targetARID,
	input wire [ADDR_WIDTH-1:0]          				targetARADDR,
	input wire [7:0]                         			targetARLEN,
	input wire [2:0]                         			targetARSIZE,
	input wire [1:0]                         			targetARBURST,
	input wire [1:0]                         			targetARLOCK,
	input wire [3:0]                         			targetARCACHE,
	input wire [2:0]                         			targetARPROT,
	input wire [3:0]                         			targetARREGION,			// not used
	input wire [3:0]                         			targetARQOS,				// not used
	input wire [USER_WIDTH-1:0]	        				targetARUSER,
	input wire                            				targetARVALID,				
	output  wire 	                       				targetARREADY,
   
	//=========================================  Target Read Data Ports  =========================================================
	output  wire [ID_WIDTH-1:0]							targetRID,
	output  wire [DATA_WIDTH-1:0]    					targetRDATA,
	output  wire [1:0]                     				targetRRESP,
	output  wire                         				targetRLAST,
	output  wire [USER_WIDTH-1:0]	        		 	targetRUSER,				// not used
	output  wire                         				targetRVALID,
		
	input 	wire	                       				targetRREADY,
	
	//=========================================  Target Write Address Port  ======================================================
	input wire [ID_WIDTH-1:0]							targetAWID,
	input wire [ADDR_WIDTH-1:0]          				targetAWADDR,
	input wire [7:0]                         			targetAWLEN,
	input wire [2:0]                         			targetAWSIZE,
	input wire [1:0]                         			targetAWBURST,
	input wire [1:0]                         			targetAWLOCK,
	input wire [3:0]                         			targetAWCACHE,
	input wire [2:0]                         			targetAWPROT,
	input wire [3:0]                         			targetAWREGION,			// not used
	input wire [3:0]                         			targetAWQOS,				// not used
	input wire [USER_WIDTH-1:0]	        				targetAWUSER,
	input wire                            				targetAWVALID,				
	output wire	 	                       				targetAWREADY,
   	
	//========================================  Target Write Data Ports  =========================================================
	input wire [ID_WIDTH-1:0]                           targetWID,
	input wire [DATA_WIDTH-1:0]    						targetWDATA,
	input wire [(DATA_WIDTH/8)-1:0]  					targetWSTRB,
	input wire                           				targetWLAST,
	input wire [USER_WIDTH-1:0]	         				targetWUSER,
	input wire                            				targetWVALID,
		
	output wire                           				targetWREADY,
		
	//========================================  Initiator Write Response Ports  ====================================================
	output wire [ID_WIDTH-1:0]							targetBID,
	output wire [1:0]                          			targetBRESP,
	output wire [USER_WIDTH-1:0]          				targetBUSER,
	output wire 	                            		targetBVALID,

	input  wire  	                           			targetBREADY,
		 
	//================================================= External Side Ports  ====================================================
	// Target Write Address Port - Target ID is composed of Initiator Port ID concatenated with transaction ID
	output wire [ID_WIDTH-1:0] 							TARGET_AWID,
	output wire [ADDR_WIDTH-1:0]          				TARGET_AWADDR,
	output wire [7:0]                         			TARGET_AWLEN,	
	output wire [2:0]                         			TARGET_AWSIZE,	
	output wire [1:0]                         			TARGET_AWBURST,	
	output wire [1:0]                         			TARGET_AWLOCK,
	output wire [3:0]                         			TARGET_AWCACHE,
	output wire [2:0]                         			TARGET_AWPROT,	
	output wire [3:0]                         			TARGET_AWREGION, 
	output wire [3:0]                         			TARGET_AWQOS,			
	output wire [USER_WIDTH-1:0]  	      	  			TARGET_AWUSER,	
	output wire      	                     			TARGET_AWVALID,	
	input  wire		                          			TARGET_AWREADY,
   
	//========================================  Target Write Data Ports  ==========================================================
	output wire [ID_WIDTH-1:0] 							TARGET_WID,
	output wire [TARGET_DATA_WIDTH-1:0]    				TARGET_WDATA,	
	output wire [(TARGET_DATA_WIDTH/8)-1:0]  			TARGET_WSTRB,	
	output wire                           				TARGET_WLAST,	
	output wire [USER_WIDTH-1:0]	         			TARGET_WUSER,	
	output wire                            				TARGET_WVALID,	
	input  wire                           				TARGET_WREADY,	

	//=======================================  Target Write Response Ports  =======================================================
	input  wire [ID_WIDTH-1:0]							TARGET_BID,		
	input  wire [1:0]                         			TARGET_BRESP,	
	input  wire [USER_WIDTH-1:0]        				TARGET_BUSER,	
	input  wire      	                     			TARGET_BVALID,	
	output wire	  	                         			TARGET_BREADY,	
   
	//=======================================  Target Read Address Port  =========================================================
	output wire [ID_WIDTH-1:0]							TARGET_ARID,	
	output wire [ADDR_WIDTH-1:0]          				TARGET_ARADDR,	
	output wire [7:0]                         			TARGET_ARLEN,	
	output wire [2:0]                         			TARGET_ARSIZE,	
	output wire [1:0]                         			TARGET_ARBURST,	
	output wire [1:0]                         			TARGET_ARLOCK,	
	output wire [3:0]                         			TARGET_ARCACHE,	
	output wire [2:0]                         			TARGET_ARPROT,	
	output wire [3:0]                         			TARGET_ARREGION, 
	output wire [3:0]                         			TARGET_ARQOS,	
	output wire [USER_WIDTH-1:0]	        			TARGET_ARUSER,	
	output wire      	                     			TARGET_ARVALID,	
	input  wire 		                          		TARGET_ARREADY,	
   
	//====================================  Target Read Data Ports  ==============================================================
	input  wire [ID_WIDTH-1:0]  						TARGET_RID,		
	input  wire [TARGET_DATA_WIDTH-1:0]    				TARGET_RDATA,	
	input  wire [1:0]                         			TARGET_RRESP,	
	input  wire          	                 			TARGET_RLAST,	
	input  wire [USER_WIDTH-1:0]	         			TARGET_RUSER,			
	input  wire      	                    			TARGET_RVALID,	
	output wire 		                           		TARGET_RREADY
    
	);

    localparam             DWC_CHAN_RS_EN = (DATA_WIDTH != TARGET_DATA_WIDTH) ? DWC_CHAN_RS : 1'b0;
    localparam             DWC_ENABLED    = (DATA_WIDTH != TARGET_DATA_WIDTH) ? 1'b1 : 1'b0;  // DWC enabled when data widths differ

	//===================================== Internal wires =======================================//

	//================================== Wires between RegSlice and caxi4interconnect_TrgtProtocolConverter ==================
	// Target Write Address Port - Target ID is composed of Initiator Port ID concatenated with transaction ID
	wire [ID_WIDTH-1:0] 						dwc_cdc_targetAWID;
	wire [ADDR_WIDTH-1:0]          				dwc_cdc_targetAWADDR;
	wire [7:0]                         			dwc_cdc_targetAWLEN;	
	wire [2:0]                         			dwc_cdc_targetAWSIZE;	
	wire [1:0]                         			dwc_cdc_targetAWBURST;	
	wire [1:0]                         			dwc_cdc_targetAWLOCK;
	wire [3:0]                         			dwc_cdc_targetAWCACHE;
	wire [2:0]                         			dwc_cdc_targetAWPROT;	
	wire [3:0]                         			dwc_cdc_targetAWREGION; 
	wire [3:0]                         			dwc_cdc_targetAWQOS;			
	wire [USER_WIDTH-1:0]  	      	  			dwc_cdc_targetAWUSER;	
	wire      	                     			dwc_cdc_targetAWVALID;	
	wire		                          		dwc_cdc_targetAWREADY;
   
	// Write Data Ports  
	wire [ID_WIDTH-1:0]      					dwc_cdc_targetWID;	
	wire [TARGET_DATA_WIDTH-1:0] 				dwc_cdc_targetWDATA;	
	wire [(TARGET_DATA_WIDTH/8)-1:0] 			dwc_cdc_targetWSTRB;	
	wire                           				dwc_cdc_targetWLAST;	
	wire [USER_WIDTH-1:0]	         			dwc_cdc_targetWUSER;	
	wire                            			dwc_cdc_targetWVALID;	
	wire                           				dwc_cdc_targetWREADY;	

	// Write Response Ports 
	wire [ID_WIDTH-1:0]							dwc_cdc_targetBID;		
	wire [1:0]                         			dwc_cdc_targetBRESP;	
	wire [USER_WIDTH-1:0]        				dwc_cdc_targetBUSER;	
	wire      	                     			dwc_cdc_targetBVALID;	
	wire	  	                         		dwc_cdc_targetBREADY;	
   
	// Read Address Port  
	wire [ID_WIDTH-1:0]							dwc_cdc_targetARID;	
	wire [ADDR_WIDTH-1:0]          				dwc_cdc_targetARADDR;	
	wire [7:0]                         			dwc_cdc_targetARLEN;	
	wire [2:0]                         			dwc_cdc_targetARSIZE;	
	wire [1:0]                         			dwc_cdc_targetARBURST;	
	wire [1:0]                         			dwc_cdc_targetARLOCK;	
	wire [3:0]                         			dwc_cdc_targetARCACHE;	
	wire [2:0]                         			dwc_cdc_targetARPROT;	
	wire [3:0]                         			dwc_cdc_targetARREGION; 
	wire [3:0]                         			dwc_cdc_targetARQOS;	
	wire [USER_WIDTH-1:0]	        			dwc_cdc_targetARUSER;	
	wire      	                     			dwc_cdc_targetARVALID;	
	wire 		                          		dwc_cdc_targetARREADY;	
   
	// Read Data Ports  
	wire [ID_WIDTH-1:0]  						dwc_cdc_targetRID;		
	wire [TARGET_DATA_WIDTH-1:0]    			dwc_cdc_targetRDATA;	
	wire [1:0]                         			dwc_cdc_targetRRESP;	
	wire          	                 			dwc_cdc_targetRLAST;	
	wire [USER_WIDTH-1:0]	         			dwc_cdc_targetRUSER;			
	wire      	                    			dwc_cdc_targetRVALID;	
	wire 										dwc_cdc_targetRREADY;

	wire [ID_WIDTH-1:0] 						cdc_dwc_targetAWID;
	wire [ADDR_WIDTH-1:0]          				cdc_dwc_targetAWADDR;
	wire [7:0]                         			cdc_dwc_targetAWLEN;	
	wire [2:0]                         			cdc_dwc_targetAWSIZE;	
	wire [1:0]                         			cdc_dwc_targetAWBURST;	
	wire [1:0]                         			cdc_dwc_targetAWLOCK;
	wire [3:0]                         			cdc_dwc_targetAWCACHE;
	wire [2:0]                         			cdc_dwc_targetAWPROT;	
	wire [3:0]                         			cdc_dwc_targetAWREGION; 
	wire [3:0]                         			cdc_dwc_targetAWQOS;			
	wire [USER_WIDTH-1:0]  	      	  			cdc_dwc_targetAWUSER;	
	wire      	                     			cdc_dwc_targetAWVALID;	
	wire		                          		cdc_dwc_targetAWREADY;
   
	// Write Data Ports  
	wire [ID_WIDTH-1:0]      					cdc_dwc_targetWID;	
	wire [DATA_WIDTH-1:0] 				        cdc_dwc_targetWDATA;	
	wire [(DATA_WIDTH/8)-1:0] 			        cdc_dwc_targetWSTRB;	
	wire                           				cdc_dwc_targetWLAST;	
	wire [USER_WIDTH-1:0]	         			cdc_dwc_targetWUSER;	
	wire                            			cdc_dwc_targetWVALID;	
	wire                           				cdc_dwc_targetWREADY;	

	// Write Response Ports 
	wire [ID_WIDTH-1:0]							cdc_dwc_targetBID;		
	wire [1:0]                         			cdc_dwc_targetBRESP;	
	wire [USER_WIDTH-1:0]        				cdc_dwc_targetBUSER;	
	wire      	                     			cdc_dwc_targetBVALID;	
	wire	  	                         		cdc_dwc_targetBREADY;	
   
	// Read Address Port  
	wire [ID_WIDTH-1:0]							cdc_dwc_targetARID;	
	wire [ADDR_WIDTH-1:0]          				cdc_dwc_targetARADDR;	
	wire [7:0]                         			cdc_dwc_targetARLEN;	
	wire [2:0]                         			cdc_dwc_targetARSIZE;	
	wire [1:0]                         			cdc_dwc_targetARBURST;	
	wire [1:0]                         			cdc_dwc_targetARLOCK;	
	wire [3:0]                         			cdc_dwc_targetARCACHE;	
	wire [2:0]                         			cdc_dwc_targetARPROT;	
	wire [3:0]                         			cdc_dwc_targetARREGION; 
	wire [3:0]                         			cdc_dwc_targetARQOS;	
	wire [USER_WIDTH-1:0]	        			cdc_dwc_targetARUSER;	
	wire      	                     			cdc_dwc_targetARVALID;	
	wire 		                          		cdc_dwc_targetARREADY;	
   
	// Read Data Ports  
	wire [ID_WIDTH-1:0]  						cdc_dwc_targetRID;		
	wire [DATA_WIDTH-1:0]           			cdc_dwc_targetRDATA;	
	wire [1:0]                         			cdc_dwc_targetRRESP;	
	wire          	                 			cdc_dwc_targetRLAST;	
	wire [USER_WIDTH-1:0]	         			cdc_dwc_targetRUSER;			
	wire      	                    			cdc_dwc_targetRVALID;	
	wire 										cdc_dwc_targetRREADY;

	wire [ID_WIDTH-1:0] 						dwc_rs_targetAWID;
	wire [ADDR_WIDTH-1:0]          				dwc_rs_targetAWADDR;
	wire [7:0]                         			dwc_rs_targetAWLEN;	
	wire [2:0]                         			dwc_rs_targetAWSIZE;	
	wire [1:0]                         			dwc_rs_targetAWBURST;	
	wire [1:0]                         			dwc_rs_targetAWLOCK;
	wire [3:0]                         			dwc_rs_targetAWCACHE;
	wire [2:0]                         			dwc_rs_targetAWPROT;	
	wire [3:0]                         			dwc_rs_targetAWREGION; 
	wire [3:0]                         			dwc_rs_targetAWQOS;			
	wire [USER_WIDTH-1:0]  	      	  			dwc_rs_targetAWUSER;	
	wire      	                     			dwc_rs_targetAWVALID;	
	wire		                          		dwc_rs_targetAWREADY;
   
	// Write Data Ports  
	wire [ID_WIDTH-1:0]      					dwc_rs_targetWID;	
	wire [TARGET_DATA_WIDTH-1:0] 				dwc_rs_targetWDATA;	
	wire [(TARGET_DATA_WIDTH/8)-1:0] 			dwc_rs_targetWSTRB;	
	wire                           				dwc_rs_targetWLAST;	
	wire [USER_WIDTH-1:0]	         			dwc_rs_targetWUSER;	
	wire                            			dwc_rs_targetWVALID;	
	wire                           				dwc_rs_targetWREADY;	

	// Write Response Ports 
	wire [ID_WIDTH-1:0]							dwc_rs_targetBID;		
	wire [1:0]                         			dwc_rs_targetBRESP;	
	wire [USER_WIDTH-1:0]        				dwc_rs_targetBUSER;	
	wire      	                     			dwc_rs_targetBVALID;	
	wire	  	                         		dwc_rs_targetBREADY;	
   
	// Read Address Port  
	wire [ID_WIDTH-1:0]							dwc_rs_targetARID;	
	wire [ADDR_WIDTH-1:0]          				dwc_rs_targetARADDR;	
	wire [7:0]                         			dwc_rs_targetARLEN;	
	wire [2:0]                         			dwc_rs_targetARSIZE;	
	wire [1:0]                         			dwc_rs_targetARBURST;	
	wire [1:0]                         			dwc_rs_targetARLOCK;	
	wire [3:0]                         			dwc_rs_targetARCACHE;	
	wire [2:0]                         			dwc_rs_targetARPROT;	
	wire [3:0]                         			dwc_rs_targetARREGION; 
	wire [3:0]                         			dwc_rs_targetARQOS;	
	wire [USER_WIDTH-1:0]	        			dwc_rs_targetARUSER;	
	wire      	                     			dwc_rs_targetARVALID;	
	wire 		                          		dwc_rs_targetARREADY;	
   
	// Read Data Ports  
	wire [ID_WIDTH-1:0]  						dwc_rs_targetRID;		
	wire [TARGET_DATA_WIDTH-1:0]    			dwc_rs_targetRDATA;	
	wire [1:0]                         			dwc_rs_targetRRESP;	
	wire          	                 			dwc_rs_targetRLAST;	
	wire [USER_WIDTH-1:0]	         			dwc_rs_targetRUSER;			
	wire      	                    			dwc_rs_targetRVALID;	
	wire 										dwc_rs_targetRREADY;


	//================================== Wires between RegSlice and caxi4interconnect_TrgtProtocolConverter ==================
	// Target Write Address Port - Target ID is composed of Initiator Port ID concatenated with transaction ID
	wire [ID_WIDTH-1:0] 						sr_dwc_targetAWID;
	wire [ADDR_WIDTH-1:0]          				sr_dwc_targetAWADDR;
	wire [7:0]                         			sr_dwc_targetAWLEN;	
	wire [2:0]                         			sr_dwc_targetAWSIZE;	
	wire [1:0]                         			sr_dwc_targetAWBURST;	
	wire [1:0]                         			sr_dwc_targetAWLOCK;
	wire [3:0]                         			sr_dwc_targetAWCACHE;
	wire [2:0]                         			sr_dwc_targetAWPROT;	
	wire [3:0]                         			sr_dwc_targetAWREGION; 
	wire [3:0]                         			sr_dwc_targetAWQOS;			
	wire [USER_WIDTH-1:0]  	      	  			sr_dwc_targetAWUSER;	
	wire      	                     			sr_dwc_targetAWVALID;	
	wire		                          		sr_dwc_targetAWREADY;
   
	// Write Data Ports  
	wire [ID_WIDTH-1:0]    		    			sr_dwc_targetWID;	
	wire [DATA_WIDTH-1:0]    					sr_dwc_targetWDATA;	
	wire [(DATA_WIDTH/8)-1:0]  					sr_dwc_targetWSTRB;	
	wire                           				sr_dwc_targetWLAST;	
	wire [USER_WIDTH-1:0]	         			sr_dwc_targetWUSER;	
	wire                            			sr_dwc_targetWVALID;	
	wire                           				sr_dwc_targetWREADY;	

	// Write Response Ports 
	wire [ID_WIDTH-1:0]							sr_dwc_targetBID;		
	wire [1:0]                         			sr_dwc_targetBRESP;	
	wire [USER_WIDTH-1:0]        				sr_dwc_targetBUSER;	
	wire      	                     			sr_dwc_targetBVALID;	
	wire	  	                         		sr_dwc_targetBREADY;	
   
	// Read Address Port  
	wire [ID_WIDTH-1:0]							sr_dwc_targetARID;	
	wire [ADDR_WIDTH-1:0]          				sr_dwc_targetARADDR;	
	wire [7:0]                         			sr_dwc_targetARLEN;	
	wire [2:0]                         			sr_dwc_targetARSIZE;	
	wire [1:0]                         			sr_dwc_targetARBURST;	
	wire [1:0]                         			sr_dwc_targetARLOCK;	
	wire [3:0]                         			sr_dwc_targetARCACHE;	
	wire [2:0]                         			sr_dwc_targetARPROT;	
	wire [3:0]                         			sr_dwc_targetARREGION; 
	wire [3:0]                         			sr_dwc_targetARQOS;	
	wire [USER_WIDTH-1:0]	        			sr_dwc_targetARUSER;	
	wire      	                     			sr_dwc_targetARVALID;	
	wire 		                          		sr_dwc_targetARREADY;	
   
	// Read Data Ports  
	wire [ID_WIDTH-1:0]  						sr_dwc_targetRID;		
	wire [DATA_WIDTH-1:0]    					sr_dwc_targetRDATA;	
	wire [1:0]                         			sr_dwc_targetRRESP;	
	wire          	                 			sr_dwc_targetRLAST;	
	wire [USER_WIDTH-1:0]	         			sr_dwc_targetRUSER;			
	wire      	                    			sr_dwc_targetRVALID;	
	wire 										sr_dwc_targetRREADY;
	
	//================================== Wires between caxi4interconnect_TrgtProtocolConverter and NextBlock ==================
	// Target Write Address Port - Target ID is composed of Initiator Port ID concatenated with transaction ID
	wire [ID_WIDTH-1:0] 						cdc_prot_targetAWID;
	wire [ADDR_WIDTH-1:0]          				cdc_prot_targetAWADDR;
	wire [7:0]                         			cdc_prot_targetAWLEN;	
	wire [2:0]                         			cdc_prot_targetAWSIZE;	
	wire [1:0]                         			cdc_prot_targetAWBURST;	
	wire [1:0]                         			cdc_prot_targetAWLOCK;
	wire [3:0]                         			cdc_prot_targetAWCACHE;
	wire [2:0]                         			cdc_prot_targetAWPROT;	
	wire [3:0]                         			cdc_prot_targetAWREGION; 
	wire [3:0]                         			cdc_prot_targetAWQOS;			
	wire [USER_WIDTH-1:0]  	      	  			cdc_prot_targetAWUSER;	
	wire      	                     			cdc_prot_targetAWVALID;	
	wire		                          		cdc_prot_targetAWREADY;
   
	// Write Data Ports  
	wire [ID_WIDTH-1:0]    			        	cdc_prot_targetWID;	
	wire [TARGET_DATA_WIDTH-1:0]    			cdc_prot_targetWDATA;	
	wire [(TARGET_DATA_WIDTH/8)-1:0]  			cdc_prot_targetWSTRB;	
	wire                           				cdc_prot_targetWLAST;	
	wire [USER_WIDTH-1:0]	         			cdc_prot_targetWUSER;	
	wire                            			cdc_prot_targetWVALID;	
	wire                           				cdc_prot_targetWREADY;	

	// Write Response Ports 
	wire [ID_WIDTH-1:0]							cdc_prot_targetBID;		
	wire [1:0]                         			cdc_prot_targetBRESP;	
	wire [USER_WIDTH-1:0]        				cdc_prot_targetBUSER;	
	wire      	                     			cdc_prot_targetBVALID;	
	wire	  	                         		cdc_prot_targetBREADY;	
   
	// Read Address Port  
	wire [ID_WIDTH-1:0]							cdc_prot_targetARID;	
	wire [ADDR_WIDTH-1:0]          				cdc_prot_targetARADDR;	
	wire [7:0]                         			cdc_prot_targetARLEN;	
	wire [2:0]                         			cdc_prot_targetARSIZE;	
	wire [1:0]                         			cdc_prot_targetARBURST;	
	wire [1:0]                         			cdc_prot_targetARLOCK;	
	wire [3:0]                         			cdc_prot_targetARCACHE;	
	wire [2:0]                         			cdc_prot_targetARPROT;	 
	wire [3:0]                         			cdc_prot_targetARREGION; 
	wire [3:0]                         			cdc_prot_targetARQOS;	
	wire [USER_WIDTH-1:0]	        			cdc_prot_targetARUSER;	
	wire      	                     			cdc_prot_targetARVALID;	
	wire 		                          		cdc_prot_targetARREADY;	
   
	// Read Data Ports  
	wire [ID_WIDTH-1:0]  						cdc_prot_targetRID;		
	wire [TARGET_DATA_WIDTH-1:0]    				cdc_prot_targetRDATA;	
	wire [1:0]                         			cdc_prot_targetRRESP;	
	wire          	                 			cdc_prot_targetRLAST;	
	wire [USER_WIDTH-1:0]	         			cdc_prot_targetRUSER;			
	wire      	                    			cdc_prot_targetRVALID;	
	wire 										cdc_prot_targetRREADY;
	
	wire                                        tarst_sync;
	wire                                        tsrst_sync;
     wire [ID_WIDTH-1:0] 	                    arid_pipe_in      ;
     wire [ADDR_WIDTH-1:0]	                    araddr_pipe_in    ;
     wire [7:0]        		                    arlen_pipe_in     ;
     wire [2:0]          	                    arsize_pipe_in    ;
     wire [1:0]          	                    arburst_pipe_in   ;
     wire [1:0]          	                    arlock_pipe_in    ;
     wire [3:0]           	                    arcache_pipe_in   ;
     wire [2:0]         		                arprot_pipe_in    ;
     wire [3:0]          	                    arregion_pipe_in  ;
     wire [3:0]          	                    arqos_pipe_in     ;
     wire [USER_WIDTH-1:0]	                    aruser_pipe_in    ;
     wire            		                    arvalid_pipe_in   ;
     wire            		                    arready_pipe_in   ;
     wire [ID_WIDTH-1:0]   	                    rid_pipe_in       ;
     wire [TARGET_DATA_WIDTH-1:0]	            rdata_pipe_in     ;
     wire [1:0]           	                    rresp_pipe_in     ;
     wire                	                    rlast_pipe_in     ;
     wire [USER_WIDTH-1:0] 	                    ruser_pipe_in     ;
     wire                 	                    rvalid_pipe_in    ;
     wire               		                rready_pipe_in    ;
     wire [ID_WIDTH-1:0]  	                    awid_pipe_in      ;
     wire [ADDR_WIDTH-1:0] 	                    awaddr_pipe_in    ;
     wire [7:0]           	                    awlen_pipe_in     ;
     wire [2:0]           	                    awsize_pipe_in    ;
     wire [1:0]           	                    awburst_pipe_in   ;
     wire [1:0]           	                    awlock_pipe_in    ;
     wire [3:0]          	                    awcache_pipe_in   ;
     wire [2:0]           	                    awprot_pipe_in    ;
     wire [3:0]            	                    awregion_pipe_in  ;
     wire [3:0]           	                    awqos_pipe_in     ;
     wire [USER_WIDTH-1:0]                      awuser_pipe_in    ;
     wire                 	                    awvalid_pipe_in   ;
     wire                	                    awready_pipe_in   ;	
     wire [ID_WIDTH-1:0]                        wid_pipe_in       ;
     wire [TARGET_DATA_WIDTH-1:0]  	            wdata_pipe_in     ;
     wire [(TARGET_DATA_WIDTH/8)-1:0]            wstrb_pipe_in     ;
     wire                  	                    wlast_pipe_in     ;
     wire [USER_WIDTH-1:0] 	                    wuser_pipe_in     ;
     wire                  	                    wvalid_pipe_in    ;
     wire                   	                wready_pipe_in    ;	
     wire [ID_WIDTH-1:0]		                bid_pipe_in       ;
     wire [1:0]           	                    bresp_pipe_in     ;
     wire [USER_WIDTH-1:0] 	                    buser_pipe_in     ;
     wire      				                    bvalid_pipe_in    ;
     wire					                    bready_pipe_in    ;
    	

	//=======================================================================================================================
	// Local system reset - asserted asynchronously to TRGT_CLK and deasserted synchronous
	//=======================================================================================================================
	generate
	if(CLOCK_DOMAIN_CROSSING) 
	  begin
	    caxi4interconnect_ResetSync #
        (
		  .SYNC_RESET           (SYNC_RESET   ),
		  .FAMILY               (FAMILY       )
		) rsync (
	      .sysClk	            ( TRGT_CLK    ),
	      .sysReset_L           ( ARESETN     ),			// active low reset synchronoise to RE AClk - asserted async.
	      .arst_sync            ( tarst_sync  ),			// active low arst_sync synchronised to INITR_CLK
	      .srst_sync            ( tsrst_sync  )			    // active low arst_sync synchronised to INITR_CLK
	    );	
      end
	else
	  begin
	    assign tarst_sync = arst_sync;
	    assign tsrst_sync = srst_sync;
      end
	endgenerate

	assign t_sync_rstn = (EXPOSE_RST == 1) ? (SYNC_RESET == 1) ? tsrst_sync : tarst_sync : 1'b1;
	
	//=======================================================================================================================
	// Insert a bank of registers on each channel as reqiored
	//=======================================================================================================================	
	caxi4interconnect_RegisterSlice # //Crossbar Register Slice

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
		)
		rgsl(

				//=====================================  Global Signals   =====================================================
				.sysClk	    ( XBAR_CLK              ),
				.arst_sync	( arst_sync             ),
				.srst_sync	( srst_sync             ),
  
				// Read Address Channel
				.srcARID	( targetARID            ),
				.srcARADDR	( targetARADDR          ),
				.srcARLEN	( targetARLEN           ),
				.srcARSIZE	( targetARSIZE          ),
				.srcARBURST	( targetARBURST         ),
				.srcARLOCK	( targetARLOCK          ),
				.srcARCACHE	( targetARCACHE         ),
				.srcARPROT	( targetARPROT          ),
				.srcARREGION( targetARREGION        ),
				.srcARQOS	( targetARQOS           ),
				.srcARUSER	( targetARUSER          ),
				.srcARVALID	( targetARVALID         ),
				.srcARREADY	( targetARREADY         ),
	
				.dstARID	( sr_dwc_targetARID     ),
				.dstARADDR	( sr_dwc_targetARADDR   ),
				.dstARLEN	( sr_dwc_targetARLEN    ),
				.dstARSIZE	( sr_dwc_targetARSIZE   ),
				.dstARBURST	( sr_dwc_targetARBURST  ),
				.dstARLOCK	( sr_dwc_targetARLOCK   ),
				.dstARCACHE	( sr_dwc_targetARCACHE  ),
				.dstARPROT	( sr_dwc_targetARPROT   ),
				.dstARREGION( sr_dwc_targetARREGION ),
				.dstARQOS	( sr_dwc_targetARQOS    ),
				.dstARUSER	( sr_dwc_targetARUSER   ),
				.dstARVALID	( sr_dwc_targetARVALID  ),
				.dstARREADY	( sr_dwc_targetARREADY  ),
	
				// Read Data Channel	
				.srcRID		( targetRID             ),
				.srcRDATA	( targetRDATA           ), // output from this module, input to this file
				.srcRRESP	( targetRRESP           ),
				.srcRLAST	( targetRLAST           ),
				.srcRUSER	( targetRUSER           ),
				.srcRVALID	( targetRVALID          ),
				.srcRREADY	( targetRREADY          ),
	
				.dstRID		( sr_dwc_targetRID      ),
				.dstRDATA	( sr_dwc_targetRDATA    ), // input to this module, 
				.dstRRESP	( sr_dwc_targetRRESP    ),
				.dstRLAST	( sr_dwc_targetRLAST    ),
				.dstRUSER	( sr_dwc_targetRUSER    ),
				.dstRVALID	( sr_dwc_targetRVALID   ),
				.dstRREADY	( sr_dwc_targetRREADY   ),
	
				// Write Address Channel	
				.srcAWID	( targetAWID            ),
				.srcAWADDR	( targetAWADDR          ),
				.srcAWLEN	( targetAWLEN           ),
				.srcAWSIZE	( targetAWSIZE          ),
				.srcAWBURST	( targetAWBURST         ),
				.srcAWLOCK	( targetAWLOCK          ),
				.srcAWCACHE	( targetAWCACHE         ),
				.srcAWPROT	( targetAWPROT          ),
				.srcAWREGION( targetAWREGION        ),
				.srcAWQOS	( targetAWQOS           ),
				.srcAWUSER	( targetAWUSER          ),
				.srcAWVALID	( targetAWVALID         ),
				.srcAWREADY	( targetAWREADY         ),
	
				.dstAWID	( sr_dwc_targetAWID     ),
				.dstAWADDR	( sr_dwc_targetAWADDR   ),
				.dstAWLEN	( sr_dwc_targetAWLEN    ),
				.dstAWSIZE	( sr_dwc_targetAWSIZE   ),
				.dstAWBURST	( sr_dwc_targetAWBURST  ),
				.dstAWLOCK	( sr_dwc_targetAWLOCK   ),
				.dstAWCACHE	( sr_dwc_targetAWCACHE  ),
				.dstAWPROT	( sr_dwc_targetAWPROT   ),
				.dstAWREGION( sr_dwc_targetAWREGION ),
				.dstAWQOS	( sr_dwc_targetAWQOS    ),
				.dstAWUSER	( sr_dwc_targetAWUSER   ),
				.dstAWVALID	( sr_dwc_targetAWVALID  ),
				.dstAWREADY	( sr_dwc_targetAWREADY  ),

				// Write Data Channel	
				.srcWID	    ( targetWID             ),
				.srcWDATA	( targetWDATA           ),
				.srcWSTRB	( targetWSTRB           ),
				.srcWLAST	( targetWLAST           ),
				.srcWUSER	( targetWUSER           ),
				.srcWVALID	( targetWVALID          ),
				.srcWREADY	( targetWREADY          ),
	
	            .dstWID     ( sr_dwc_targetWID      ),
				.dstWDATA	( sr_dwc_targetWDATA    ),
				.dstWSTRB	( sr_dwc_targetWSTRB    ),
				.dstWLAST	( sr_dwc_targetWLAST    ),
				.dstWUSER	( sr_dwc_targetWUSER    ),
				.dstWVALID	( sr_dwc_targetWVALID   ),
				.dstWREADY	( sr_dwc_targetWREADY   ),	

				// Write Response Channel	
				.srcBID		( targetBID             ),
				.srcBRESP	( targetBRESP           ),
				.srcBUSER	( targetBUSER           ),
				.srcBVALID	( targetBVALID          ),
				.srcBREADY	( targetBREADY          ),

				.dstBID		( sr_dwc_targetBID      ),
				.dstBRESP	( sr_dwc_targetBRESP    ),
				.dstBUSER	( sr_dwc_targetBUSER    ),
				.dstBVALID	( sr_dwc_targetBVALID   ),
				.dstBREADY	( sr_dwc_targetBREADY   )

			)	;
	
	//=========================================================================================
	// Currently caxi4interconnect_TrgtDataWidthConverter is a "pass-through" module - no data width conversion
	// implemented. Here as stub to minimise changes needed to hierarchy when added in.
	//=========================================================================================
generate 
  if(CDC_PLACEMENT == 1)	begin //After DWC. DWC->DWC_RS->CDC->ProtoConv	
	caxi4interconnect_TrgtDataWidthConverter #
						(
							.TARGET_TYPE            ( TARGET_TYPE         ), 		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b10
							.TARGET_NUMBER          ( TARGET_NUMBER       ),		// target number
							.MAX_TRANS		    	( MAX_TRANS           ),
							.ID_WIDTH               ( ID_WIDTH            ),
							.ADDR_WIDTH             ( ADDR_WIDTH          ),
							.DATA_WIDTH             ( DATA_WIDTH          ),
							.TARGET_DATA_WIDTH      ( TARGET_DATA_WIDTH   ),
							.USER_WIDTH             ( USER_WIDTH          ),
							.DWC_ADDR_FIFO_DEPTH    ( DWC_ADDR_FIFO_DEPTH ),
							.DATA_FIFO_DEPTH        ( DWC_DATA_FIFO_DEPTH ),
                            .READ_INTERLEAVE        ( READ_INTERLEAVE     ),                            
                            .PIPE                   ( PIPE                ),							
                            .DWC_RAM_TYPE           ( DWC_RAM_TYPE        ),							
                            .SYNC_RESET             ( SYNC_RESET          )							
						)
				trgtdwc (
							// Global Signals
							.ACLK                   ( XBAR_CLK               ),
							.arst_sync              ( arst_sync              ),				// active low reset synchronoise to RE AClk - asserted async.
							.srst_sync              ( srst_sync              ),				// active low reset synchronoise to RE AClk - asserted async.
		   
							// Initiator Read Address Ports
							.TARGET_ARID	        ( dwc_rs_targetARID     ),
							.TARGET_ARADDR		    ( dwc_rs_targetARADDR   ),
							.TARGET_ARLEN		    ( dwc_rs_targetARLEN    ),
							.TARGET_ARSIZE		    ( dwc_rs_targetARSIZE   ),
							.TARGET_ARBURST		    ( dwc_rs_targetARBURST  ),
							.TARGET_ARLOCK		    ( dwc_rs_targetARLOCK   ),
							.TARGET_ARCACHE		    ( dwc_rs_targetARCACHE  ),
							.TARGET_ARPROT		    ( dwc_rs_targetARPROT   ),
							.TARGET_ARREGION	    ( dwc_rs_targetARREGION ),
							.TARGET_ARQOS		    ( dwc_rs_targetARQOS    ),
							.TARGET_ARUSER		    ( dwc_rs_targetARUSER   ),
							.TARGET_ARVALID		    ( dwc_rs_targetARVALID  ),
							.TARGET_AWQOS		    ( dwc_rs_targetAWQOS    ),
							.TARGET_AWREGION	    ( dwc_rs_targetAWREGION ),
							.TARGET_AWID		    ( dwc_rs_targetAWID     ),
							.TARGET_AWADDR		    ( dwc_rs_targetAWADDR   ),
							.TARGET_AWLEN		    ( dwc_rs_targetAWLEN    ),
							.TARGET_AWSIZE		    ( dwc_rs_targetAWSIZE   ),
							.TARGET_AWBURST		    ( dwc_rs_targetAWBURST  ),
							.TARGET_AWLOCK		    ( dwc_rs_targetAWLOCK   ),
							.TARGET_AWCACHE		    ( dwc_rs_targetAWCACHE  ),
							.TARGET_AWPROT		    ( dwc_rs_targetAWPROT   ),
							.TARGET_AWUSER		    ( dwc_rs_targetAWUSER   ),
							.TARGET_AWVALID		    ( dwc_rs_targetAWVALID  ),
							.TARGET_WID             ( dwc_rs_targetWID      ),
							.TARGET_WDATA		    ( dwc_rs_targetWDATA    ),
							.TARGET_WSTRB		    ( dwc_rs_targetWSTRB    ),
							.TARGET_WLAST		    ( dwc_rs_targetWLAST    ),
							.TARGET_WUSER		    ( dwc_rs_targetWUSER    ),
							.TARGET_WVALID		    ( dwc_rs_targetWVALID   ),
							.TARGET_BREADY		    ( dwc_rs_targetBREADY   ),
							.TARGET_RREADY		    ( dwc_rs_targetRREADY   ),
							.TARGET_ARREADY 	    ( dwc_rs_targetARREADY  ),
							.TARGET_RID 		    ( dwc_rs_targetRID      ),
							.TARGET_RDATA 		    ( dwc_rs_targetRDATA    ), // Input from this module
							.TARGET_RRESP 		    ( dwc_rs_targetRRESP    ),
							.TARGET_RUSER 		    ( dwc_rs_targetRUSER    ),
							.TARGET_BID 		    ( dwc_rs_targetBID      ),
							.TARGET_BRESP 		    ( dwc_rs_targetBRESP    ),
							.TARGET_BUSER 		    ( dwc_rs_targetBUSER    ),
							.TARGET_RLAST 		    ( dwc_rs_targetRLAST    ),
							.TARGET_RVALID 		    ( dwc_rs_targetRVALID   ),
							.TARGET_AWREADY 	    ( dwc_rs_targetAWREADY  ),
							.TARGET_WREADY 		    ( dwc_rs_targetWREADY   ),
							.TARGET_BVALID 		    ( dwc_rs_targetBVALID   ),
							
							.int_targetARID			( sr_dwc_targetARID      ),
							.int_targetARADDR		( sr_dwc_targetARADDR    ),
							.int_targetARLEN		( sr_dwc_targetARLEN     ),
							.int_targetARSIZE		( sr_dwc_targetARSIZE    ),
							.int_targetARBURST		( sr_dwc_targetARBURST   ),
							.int_targetARLOCK		( sr_dwc_targetARLOCK    ),
							.int_targetARCACHE		( sr_dwc_targetARCACHE   ),
							.int_targetARPROT		( sr_dwc_targetARPROT    ),
							.int_targetARREGION		( sr_dwc_targetARREGION  ),
							.int_targetARQOS		( sr_dwc_targetARQOS     ),
							.int_targetARUSER		( sr_dwc_targetARUSER    ),
							.int_targetARVALID		( sr_dwc_targetARVALID   ),
							.int_targetAWQOS		( sr_dwc_targetAWQOS     ),
							.int_targetAWREGION		( sr_dwc_targetAWREGION  ),
							.int_targetAWID			( sr_dwc_targetAWID      ),
							.int_targetAWADDR		( sr_dwc_targetAWADDR    ),
							.int_targetAWLEN		( sr_dwc_targetAWLEN     ),
							.int_targetAWSIZE		( sr_dwc_targetAWSIZE    ),
							.int_targetAWBURST		( sr_dwc_targetAWBURST   ),
							.int_targetAWLOCK		( sr_dwc_targetAWLOCK    ),
							.int_targetAWCACHE		( sr_dwc_targetAWCACHE   ),
							.int_targetAWPROT		( sr_dwc_targetAWPROT    ),
							.int_targetAWUSER		( sr_dwc_targetAWUSER    ),
							.int_targetAWVALID		( sr_dwc_targetAWVALID   ),
							.int_targetWID			( sr_dwc_targetWID       ),
							.int_targetWDATA		( sr_dwc_targetWDATA     ),
							.int_targetWSTRB		( sr_dwc_targetWSTRB     ),
							.int_targetWLAST		( sr_dwc_targetWLAST     ),
							.int_targetWUSER		( sr_dwc_targetWUSER     ),
							.int_targetWVALID		( sr_dwc_targetWVALID    ),
							.int_targetBREADY		( sr_dwc_targetBREADY    ),
							.int_targetRREADY		( sr_dwc_targetRREADY    ),
							.int_targetARREADY 		( sr_dwc_targetARREADY   ),
							.int_targetRID 			( sr_dwc_targetRID       ),
							.int_targetRDATA 		( sr_dwc_targetRDATA     ), // Output from this module, goes to RS
							.int_targetRRESP 		( sr_dwc_targetRRESP     ),
							.int_targetRUSER 		( sr_dwc_targetRUSER     ),
							.int_targetBID 			( sr_dwc_targetBID       ),
							.int_targetBRESP 		( sr_dwc_targetBRESP     ),
							.int_targetBUSER 		( sr_dwc_targetBUSER     ),
							.int_targetRLAST 		( sr_dwc_targetRLAST     ),
							.int_targetRVALID 		( sr_dwc_targetRVALID    ),
							.int_targetAWREADY 		( sr_dwc_targetAWREADY   ),
							.int_targetWREADY 		( sr_dwc_targetWREADY    ),
							.int_targetBVALID 		( sr_dwc_targetBVALID    )

						)	; 	
						
    //DWC Output Register Slice						

	caxi4interconnect_RegisterSlice #

		(
			.AWCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
			.ARCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
			.RCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
			.WCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
			.BCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
			.ID_WIDTH   			( ID_WIDTH             ), 
			.ADDR_WIDTH      		( ADDR_WIDTH           ),
			.DATA_WIDTH 			( TARGET_DATA_WIDTH    ), 
			.SUPPORT_USER_SIGNALS 	( SUPPORT_USER_SIGNALS ),
			.USER_WIDTH 			( USER_WIDTH           )
		) trgt_dwc_rgsl
		(

				//=====================================  Global Signals   =====================================================
				.sysClk	    ( XBAR_CLK              ),
				.arst_sync	( arst_sync             ),
				.srst_sync	( srst_sync             ),
  
				// Read Address Channel
				.srcARID	( dwc_rs_targetARID     ),
				.srcARADDR	( dwc_rs_targetARADDR   ),
				.srcARLEN	( dwc_rs_targetARLEN    ),
				.srcARSIZE	( dwc_rs_targetARSIZE   ),
				.srcARBURST	( dwc_rs_targetARBURST  ),
				.srcARLOCK	( dwc_rs_targetARLOCK   ),
				.srcARCACHE	( dwc_rs_targetARCACHE  ),
				.srcARPROT	( dwc_rs_targetARPROT   ),
				.srcARREGION( dwc_rs_targetARREGION ),
				.srcARQOS	( dwc_rs_targetARQOS    ),
				.srcARUSER	( dwc_rs_targetARUSER   ),
				.srcARVALID	( dwc_rs_targetARVALID  ),
				.srcARREADY	( dwc_rs_targetARREADY  ),
	
				.dstARID	( dwc_cdc_targetARID     ),
				.dstARADDR	( dwc_cdc_targetARADDR   ),
				.dstARLEN	( dwc_cdc_targetARLEN    ),
				.dstARSIZE	( dwc_cdc_targetARSIZE   ),
				.dstARBURST	( dwc_cdc_targetARBURST  ),
				.dstARLOCK	( dwc_cdc_targetARLOCK   ),
				.dstARCACHE	( dwc_cdc_targetARCACHE  ),
				.dstARPROT	( dwc_cdc_targetARPROT   ),
				.dstARREGION( dwc_cdc_targetARREGION ),
				.dstARQOS	( dwc_cdc_targetARQOS    ),
				.dstARUSER	( dwc_cdc_targetARUSER   ),
				.dstARVALID	( dwc_cdc_targetARVALID  ),
				.dstARREADY	( dwc_cdc_targetARREADY  ),
	
				// Read Data Channel	
				.srcRID		( dwc_rs_targetRID       ),
				.srcRDATA	( dwc_rs_targetRDATA     ), // output from this module, input to this file
				.srcRRESP	( dwc_rs_targetRRESP     ),
				.srcRLAST	( dwc_rs_targetRLAST     ),
				.srcRUSER	( dwc_rs_targetRUSER     ),
				.srcRVALID	( dwc_rs_targetRVALID    ),
				.srcRREADY	( dwc_rs_targetRREADY    ),
	
				.dstRID		( dwc_cdc_targetRID      ),
				.dstRDATA	( dwc_cdc_targetRDATA    ), // input to this module, 
				.dstRRESP	( dwc_cdc_targetRRESP    ),
				.dstRLAST	( dwc_cdc_targetRLAST    ),
				.dstRUSER	( dwc_cdc_targetRUSER    ),
				.dstRVALID	( dwc_cdc_targetRVALID   ),
				.dstRREADY	( dwc_cdc_targetRREADY   ),
	
				// Write Address Channel	
				.srcAWID	( dwc_rs_targetAWID      ),
				.srcAWADDR	( dwc_rs_targetAWADDR    ),
				.srcAWLEN	( dwc_rs_targetAWLEN     ),
				.srcAWSIZE	( dwc_rs_targetAWSIZE    ),
				.srcAWBURST	( dwc_rs_targetAWBURST   ),
				.srcAWLOCK	( dwc_rs_targetAWLOCK    ),
				.srcAWCACHE	( dwc_rs_targetAWCACHE   ),
				.srcAWPROT	( dwc_rs_targetAWPROT    ),
				.srcAWREGION( dwc_rs_targetAWREGION  ),
				.srcAWQOS	( dwc_rs_targetAWQOS     ),
				.srcAWUSER	( dwc_rs_targetAWUSER    ),
				.srcAWVALID	( dwc_rs_targetAWVALID   ),
				.srcAWREADY	( dwc_rs_targetAWREADY   ),
	
				.dstAWID	( dwc_cdc_targetAWID     ), 
				.dstAWADDR	( dwc_cdc_targetAWADDR   ), 
				.dstAWLEN	( dwc_cdc_targetAWLEN    ),  
				.dstAWSIZE	( dwc_cdc_targetAWSIZE   ),  
				.dstAWBURST	( dwc_cdc_targetAWBURST  ),  
				.dstAWLOCK	( dwc_cdc_targetAWLOCK   ),  
				.dstAWCACHE	( dwc_cdc_targetAWCACHE  ),  
				.dstAWPROT	( dwc_cdc_targetAWPROT   ),  
				.dstAWREGION( dwc_cdc_targetAWREGION ), 
				.dstAWQOS	( dwc_cdc_targetAWQOS    ), 
				.dstAWUSER	( dwc_cdc_targetAWUSER   ), 
				.dstAWVALID	( dwc_cdc_targetAWVALID  ), 
				.dstAWREADY	( dwc_cdc_targetAWREADY  ),

				// Write Data Channel	
				.srcWID	    ( dwc_rs_targetWID       ),
				.srcWDATA	( dwc_rs_targetWDATA     ),
				.srcWSTRB	( dwc_rs_targetWSTRB     ),
				.srcWLAST	( dwc_rs_targetWLAST     ),
				.srcWUSER	( dwc_rs_targetWUSER     ),
				.srcWVALID	( dwc_rs_targetWVALID    ),
				.srcWREADY	( dwc_rs_targetWREADY    ),
	
	            .dstWID     ( dwc_cdc_targetWID      ),
				.dstWDATA	( dwc_cdc_targetWDATA    ),
				.dstWSTRB	( dwc_cdc_targetWSTRB    ),
				.dstWLAST	( dwc_cdc_targetWLAST    ),
				.dstWUSER	( dwc_cdc_targetWUSER    ),
				.dstWVALID	( dwc_cdc_targetWVALID   ),
				.dstWREADY	( dwc_cdc_targetWREADY   ),	

				// Write Response Channel	
				.srcBID		( dwc_rs_targetBID       ),
				.srcBRESP	( dwc_rs_targetBRESP     ),
				.srcBUSER	( dwc_rs_targetBUSER     ),
				.srcBVALID	( dwc_rs_targetBVALID    ),
				.srcBREADY	( dwc_rs_targetBREADY    ),

				.dstBID		( dwc_cdc_targetBID      ),
				.dstBRESP	( dwc_cdc_targetBRESP    ),
				.dstBUSER	( dwc_cdc_targetBUSER    ),
				.dstBVALID	( dwc_cdc_targetBVALID   ),
				.dstBREADY	( dwc_cdc_targetBREADY   )

			)	;
			
    caxi4interconnect_TrgtClockDomainCrossing #
    		(
    			.ID_WIDTH                 ( ID_WIDTH                 ),
    			.ADDR_WIDTH               ( ADDR_WIDTH               ),				
    			.TARGET_DATA_WIDTH        ( TARGET_DATA_WIDTH        ),
    			.USER_WIDTH               ( USER_WIDTH               ),
    			.CLOCK_DOMAIN_CROSSING    ( CLOCK_DOMAIN_CROSSING    ),
    			.CDC_FIFO_DEPTH           ( CDC_FIFO_DEPTH           ),
    			.CDC_ADDR_RESP_FIFO_DEPTH ( CDC_ADDR_RESP_FIFO_DEPTH ),
    			.TARGET_TYPE              ( TARGET_TYPE              ),
    			.READ_INTERLEAVE          ( READ_INTERLEAVE          ),
    			.PIPE                     ( PIPE                     ),
    			.CDC_RAM_TYPE             ( CDC_RAM_TYPE             ),
    			.SYNC_RESET               ( SYNC_RESET               ),
    			.NUM_STAGES               ( NUM_STAGES               )
    		)
    trgtCDC (
    			// Global Signals
    			.XBAR_CLK           ( XBAR_CLK               ),
    			.TRGT_CLK           ( TRGT_CLK               ),
    			.tarst_sync         ( tarst_sync             ),	
    			.tsrst_sync         ( tsrst_sync             ),	
    			.arst_sync          ( arst_sync              ),	
    			.srst_sync          ( srst_sync              ),	
    
    			// Initiator Read Address Ports
    			.TARGET_ARID		( dwc_cdc_targetARID      ),
    			.TARGET_ARADDR		( dwc_cdc_targetARADDR    ),
    			.TARGET_ARLEN		( dwc_cdc_targetARLEN     ),
    			.TARGET_ARSIZE		( dwc_cdc_targetARSIZE    ),
    			.TARGET_ARBURST		( dwc_cdc_targetARBURST   ),
    			.TARGET_ARLOCK		( dwc_cdc_targetARLOCK    ),
    			.TARGET_ARCACHE		( dwc_cdc_targetARCACHE   ),
    			.TARGET_ARPROT		( dwc_cdc_targetARPROT    ),
    			.TARGET_ARREGION	( dwc_cdc_targetARREGION  ),
    			.TARGET_ARQOS		( dwc_cdc_targetARQOS     ),
    			.TARGET_ARUSER		( dwc_cdc_targetARUSER    ),
    			.TARGET_ARVALID		( dwc_cdc_targetARVALID   ),
    			.TARGET_AWQOS		( dwc_cdc_targetAWQOS     ),
    			.TARGET_AWREGION	( dwc_cdc_targetAWREGION  ),
    			.TARGET_AWID		( dwc_cdc_targetAWID      ),
    			.TARGET_AWADDR		( dwc_cdc_targetAWADDR    ),
    			.TARGET_AWLEN		( dwc_cdc_targetAWLEN     ),
    			.TARGET_AWSIZE		( dwc_cdc_targetAWSIZE    ),
    			.TARGET_AWBURST		( dwc_cdc_targetAWBURST   ),
    			.TARGET_AWLOCK		( dwc_cdc_targetAWLOCK    ),
    			.TARGET_AWCACHE		( dwc_cdc_targetAWCACHE   ),
    			.TARGET_AWPROT		( dwc_cdc_targetAWPROT    ),
    			.TARGET_AWUSER		( dwc_cdc_targetAWUSER    ),
    			.TARGET_AWVALID		( dwc_cdc_targetAWVALID   ),
    			.TARGET_WID   		( dwc_cdc_targetWID       ),
    			.TARGET_WDATA		( dwc_cdc_targetWDATA     ),
    			.TARGET_WSTRB		( dwc_cdc_targetWSTRB     ),
    			.TARGET_WLAST		( dwc_cdc_targetWLAST     ),
    			.TARGET_WUSER		( dwc_cdc_targetWUSER     ),
    			.TARGET_WVALID		( dwc_cdc_targetWVALID    ),
    			.TARGET_BREADY		( dwc_cdc_targetBREADY    ),
    			.TARGET_RREADY		( dwc_cdc_targetRREADY    ),
    			.TARGET_ARREADY 	( dwc_cdc_targetARREADY   ),
    			.TARGET_RID 		( dwc_cdc_targetRID       ),
    			.TARGET_RDATA 		( dwc_cdc_targetRDATA     ), // output from this module
    			.TARGET_RRESP 		( dwc_cdc_targetRRESP     ),
    			.TARGET_RUSER 		( dwc_cdc_targetRUSER     ),
    			.TARGET_BID 		( dwc_cdc_targetBID       ),
    			.TARGET_BRESP 		( dwc_cdc_targetBRESP     ),
    			.TARGET_BUSER 		( dwc_cdc_targetBUSER     ),
    			.TARGET_RLAST 		( dwc_cdc_targetRLAST     ),
    			.TARGET_RVALID 		( dwc_cdc_targetRVALID    ),
    			.TARGET_AWREADY 	( dwc_cdc_targetAWREADY   ),
    			.TARGET_WREADY 		( dwc_cdc_targetWREADY    ),
    			.TARGET_BVALID 		( dwc_cdc_targetBVALID    ),
    			
    			.targetARID			( cdc_prot_targetARID     ),
    			.targetARADDR		( cdc_prot_targetARADDR   ),
    			.targetARLEN		( cdc_prot_targetARLEN    ),
    			.targetARSIZE		( cdc_prot_targetARSIZE   ),
    			.targetARBURST		( cdc_prot_targetARBURST  ),
    			.targetARLOCK		( cdc_prot_targetARLOCK   ),
    			.targetARCACHE		( cdc_prot_targetARCACHE  ),
    			.targetARPROT		( cdc_prot_targetARPROT   ),
    			.targetARREGION		( cdc_prot_targetARREGION ),
    			.targetARQOS		( cdc_prot_targetARQOS    ),
    			.targetARUSER		( cdc_prot_targetARUSER   ),
    			.targetARVALID		( cdc_prot_targetARVALID  ),
    			.targetAWQOS		( cdc_prot_targetAWQOS    ),
    			.targetAWREGION		( cdc_prot_targetAWREGION ),
    			.targetAWID			( cdc_prot_targetAWID     ),
    			.targetAWADDR		( cdc_prot_targetAWADDR   ),
    			.targetAWLEN		( cdc_prot_targetAWLEN    ),
    			.targetAWSIZE		( cdc_prot_targetAWSIZE   ),
    			.targetAWBURST		( cdc_prot_targetAWBURST  ),
    			.targetAWLOCK		( cdc_prot_targetAWLOCK   ),
    			.targetAWCACHE		( cdc_prot_targetAWCACHE  ),
    			.targetAWPROT		( cdc_prot_targetAWPROT   ),
    			.targetAWUSER		( cdc_prot_targetAWUSER   ),
    			.targetAWVALID		( cdc_prot_targetAWVALID  ),
    			.targetWID		    ( cdc_prot_targetWID      ),
    			.targetWDATA	    ( cdc_prot_targetWDATA    ),
    			.targetWSTRB	    ( cdc_prot_targetWSTRB    ),
    			.targetWLAST	    ( cdc_prot_targetWLAST    ),
    			.targetWUSER	    ( cdc_prot_targetWUSER    ),
    			.targetWVALID		( cdc_prot_targetWVALID   ),
    			.targetBREADY		( cdc_prot_targetBREADY   ),
    			.targetRREADY		( cdc_prot_targetRREADY   ),
    			.targetARREADY 		( cdc_prot_targetARREADY  ),
    			.targetRID 			( cdc_prot_targetRID      ),
    			.targetRDATA 		( cdc_prot_targetRDATA    ), // Input to this module
    			.targetRRESP 		( cdc_prot_targetRRESP    ),
    			.targetRUSER 		( cdc_prot_targetRUSER    ),
    			.targetBID 			( cdc_prot_targetBID      ),
    			.targetBRESP 		( cdc_prot_targetBRESP    ),
    			.targetBUSER 		( cdc_prot_targetBUSER    ),
    			.targetRLAST 		( cdc_prot_targetRLAST    ),
    			.targetRVALID 		( cdc_prot_targetRVALID   ),
    			.targetAWREADY 		( cdc_prot_targetAWREADY  ),
    			.targetWREADY 		( cdc_prot_targetWREADY   ),
    			.targetBVALID 		( cdc_prot_targetBVALID   )
    		);
			

	//=======================================================================================================================
	// Target Protocol Converter converts an AXI4 port to AXI4 (pass-through), AXI4Lite or AXI3 target port based on
	// TARGET_TYPE.
	//=======================================================================================================================
	caxi4interconnect_TrgtProtocolConverter #
						(
							.TARGET_TYPE                ( TARGET_TYPE            ) , 	// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11
							.TARGET_NUMBER              ( TARGET_NUMBER          ),	// target number
							.ID_WIDTH                   ( ID_WIDTH               ),
							.ADDR_WIDTH                 ( ADDR_WIDTH             ),				
							.DATA_WIDTH                 ( TARGET_DATA_WIDTH      ), 
							.USER_WIDTH                 ( USER_WIDTH             ),
							.WRITE_ZERO_TARGET_ID       ( WRITE_ZERO_TARGET_ID   ),
							.READ_ZERO_TARGET_ID        ( READ_ZERO_TARGET_ID    ),				
							.TRGT_AXI4PRT_ADDRDEPTH 	( TRGT_AXI4PRT_ADDRDEPTH ),
							.TRGT_AXI4PRT_DATADEPTH 	( TRGT_AXI4PRT_DATADEPTH ),
							.MAX_TRANS                  ( MAX_TRANS              ),
							.READ_INTERLEAVE            ( READ_INTERLEAVE        ),
	      		            .PIPE                       ( PIPE                   ),
	      		            .PROTOCONV_RAM_TYPE         ( PROTOCONV_RAM_TYPE     ),
	      		            .SYNC_RESET                 ( SYNC_RESET             ),
	      		            .DWC_ENABLED                ( DWC_ENABLED            ),
	      		            .BYPASS_CROSSBAR            ( BYPASS_CROSSBAR        )
						) trgtProtConv
						(
							// Global Signals
							.ACLK                       ( TRGT_CLK               ),
							.arst_sync                  ( tarst_sync              ),				// active low reset synchronoise to RE AClk - asserted async.
							.srst_sync                  ( tsrst_sync              ),				// active low reset synchronoise to RE AClk - asserted async.
		   
							// Initiator Read Address Ports
							.TARGET_ARID		        ( arid_pipe_in           ),  
							.TARGET_ARADDR		        ( araddr_pipe_in         ),  
							.TARGET_ARLEN		        ( arlen_pipe_in          ),  
							.TARGET_ARSIZE		        ( arsize_pipe_in         ),  
							.TARGET_ARBURST		        ( arburst_pipe_in        ),  
							.TARGET_ARLOCK		        ( arlock_pipe_in         ),  
							.TARGET_ARCACHE		        ( arcache_pipe_in        ),  
							.TARGET_ARPROT		        ( arprot_pipe_in         ),  
							.TARGET_ARREGION		    ( arregion_pipe_in       ),  
							.TARGET_ARQOS		        ( arqos_pipe_in          ),  
							.TARGET_ARUSER		        ( aruser_pipe_in         ),  
							.TARGET_ARVALID		        ( arvalid_pipe_in        ),  
							.TARGET_ARREADY 		    ( arready_pipe_in        ),							
							.TARGET_AWID			    ( awid_pipe_in           ),
							.TARGET_AWADDR		        ( awaddr_pipe_in         ),
							.TARGET_AWLEN		        ( awlen_pipe_in          ),
							.TARGET_AWSIZE		        ( awsize_pipe_in         ),
							.TARGET_AWBURST		        ( awburst_pipe_in        ),
							.TARGET_AWLOCK		        ( awlock_pipe_in         ),
							.TARGET_AWCACHE		        ( awcache_pipe_in        ),
							.TARGET_AWPROT		        ( awprot_pipe_in         ),
							.TARGET_AWQOS		        ( awqos_pipe_in          ),
							.TARGET_AWREGION		    ( awregion_pipe_in       ),
							.TARGET_AWUSER		        ( awuser_pipe_in         ),
							.TARGET_AWVALID		        ( awvalid_pipe_in        ),
							.TARGET_AWREADY 		    ( awready_pipe_in        ),
							.TARGET_WID			        ( wid_pipe_in            ),
							.TARGET_WDATA		        ( wdata_pipe_in          ),
							.TARGET_WSTRB		        ( wstrb_pipe_in          ),
							.TARGET_WLAST		        ( wlast_pipe_in          ),
							.TARGET_WUSER		        ( wuser_pipe_in          ),
							.TARGET_WVALID		        ( wvalid_pipe_in         ),
							.TARGET_WREADY 		        ( wready_pipe_in         ),							
							
							.TARGET_RID 			    ( rid_pipe_in            ),
							.TARGET_RDATA 		        ( rdata_pipe_in          ), 
							.TARGET_RRESP 		        ( rresp_pipe_in          ),
							.TARGET_RLAST 		        ( rlast_pipe_in          ),
							.TARGET_RUSER 		        ( ruser_pipe_in          ),
							.TARGET_RVALID 		        ( rvalid_pipe_in         ),
							.TARGET_RREADY		        ( rready_pipe_in         ),
							.TARGET_BID 			    ( bid_pipe_in            ),
							.TARGET_BRESP 		        ( bresp_pipe_in          ),
							.TARGET_BUSER 		        ( buser_pipe_in          ),
							.TARGET_BVALID 		        ( bvalid_pipe_in         ),
							.TARGET_BREADY		        ( bready_pipe_in         ),		
							
							.int_targetARID			    ( cdc_prot_targetARID     ),
							.int_targetARADDR		    ( cdc_prot_targetARADDR   ),
							.int_targetARLEN			( cdc_prot_targetARLEN    ),
							.int_targetARSIZE		    ( cdc_prot_targetARSIZE   ),
							.int_targetARBURST		    ( cdc_prot_targetARBURST  ),
							.int_targetARLOCK		    ( cdc_prot_targetARLOCK   ),
							.int_targetARCACHE		    ( cdc_prot_targetARCACHE  ),
							.int_targetARPROT		    ( cdc_prot_targetARPROT   ),
							.int_targetARREGION		    ( cdc_prot_targetARREGION ),
							.int_targetARQOS			( cdc_prot_targetARQOS    ),
							.int_targetARUSER		    ( cdc_prot_targetARUSER   ),
							.int_targetARVALID		    ( cdc_prot_targetARVALID  ),
							.int_targetAWQOS			( cdc_prot_targetAWQOS    ),
							.int_targetAWREGION		    ( cdc_prot_targetAWREGION ),
							.int_targetAWID			    ( cdc_prot_targetAWID     ),
							.int_targetAWADDR		    ( cdc_prot_targetAWADDR   ),
							.int_targetAWLEN			( cdc_prot_targetAWLEN    ),
							.int_targetAWSIZE		    ( cdc_prot_targetAWSIZE   ),
							.int_targetAWBURST		    ( cdc_prot_targetAWBURST  ),
							.int_targetAWLOCK		    ( cdc_prot_targetAWLOCK   ),
							.int_targetAWCACHE		    ( cdc_prot_targetAWCACHE  ),
							.int_targetAWPROT		    ( cdc_prot_targetAWPROT   ),
							.int_targetAWUSER		    ( cdc_prot_targetAWUSER   ),
							.int_targetAWVALID		    ( cdc_prot_targetAWVALID  ),
							.int_targetWID			    ( cdc_prot_targetWID      ),
							.int_targetWDATA			( cdc_prot_targetWDATA    ),
							.int_targetWSTRB			( cdc_prot_targetWSTRB    ),
							.int_targetWLAST			( cdc_prot_targetWLAST    ),
							.int_targetWUSER			( cdc_prot_targetWUSER    ),
							.int_targetWVALID		    ( cdc_prot_targetWVALID   ),
							.int_targetBREADY		    ( cdc_prot_targetBREADY   ),
							.int_targetRREADY		    ( cdc_prot_targetRREADY   ),
							.int_targetARREADY 		    ( cdc_prot_targetARREADY  ),
							.int_targetRID 			    ( cdc_prot_targetRID      ),
							.int_targetRDATA 		    ( cdc_prot_targetRDATA    ), // outout from this module
							.int_targetRRESP 		    ( cdc_prot_targetRRESP    ),
							.int_targetRUSER 		    ( cdc_prot_targetRUSER    ),
							.int_targetBID 			    ( cdc_prot_targetBID      ),
							.int_targetBRESP 		    ( cdc_prot_targetBRESP    ),
							.int_targetBUSER 		    ( cdc_prot_targetBUSER    ),
							.int_targetRLAST 		    ( cdc_prot_targetRLAST    ),
							.int_targetRVALID 		    ( cdc_prot_targetRVALID   ),
							.int_targetAWREADY 		    ( cdc_prot_targetAWREADY  ),
							.int_targetWREADY 		    ( cdc_prot_targetWREADY   ),
							.int_targetBVALID 		    ( cdc_prot_targetBVALID   )

						    ); 

  end else begin //Before DWC. CDC->DWC->DWC_RS->ProtoConv
    caxi4interconnect_TrgtClockDomainCrossing #
    		(
    			.ID_WIDTH                 ( ID_WIDTH                 ),
    			.ADDR_WIDTH               ( ADDR_WIDTH               ),				
    			.TARGET_DATA_WIDTH        ( DATA_WIDTH               ),
    			.USER_WIDTH               ( USER_WIDTH               ),
    			.CLOCK_DOMAIN_CROSSING    ( CLOCK_DOMAIN_CROSSING    ),
    			.CDC_FIFO_DEPTH           ( CDC_FIFO_DEPTH           ),
    			.CDC_ADDR_RESP_FIFO_DEPTH ( CDC_ADDR_RESP_FIFO_DEPTH ),
    			.TARGET_TYPE              ( TARGET_TYPE              ),
    			.READ_INTERLEAVE          ( READ_INTERLEAVE          ),
    			.PIPE                     ( PIPE                     ),
    			.CDC_RAM_TYPE             ( CDC_RAM_TYPE             ),
    			.SYNC_RESET               ( SYNC_RESET               ),
    			.NUM_STAGES               ( NUM_STAGES               )
    		)
    trgtCDC (
    			// Global Signals
    			.XBAR_CLK           ( XBAR_CLK               ),
    			.TRGT_CLK           ( TRGT_CLK               ),
    			.tarst_sync         ( tarst_sync             ),	
    			.tsrst_sync         ( tsrst_sync             ),	
    			.arst_sync          ( arst_sync              ),	
    			.srst_sync          ( srst_sync              ),	
    
    			// Initiator Read Address Ports
    			.TARGET_ARID		( sr_dwc_targetARID      ),
    			.TARGET_ARADDR		( sr_dwc_targetARADDR    ),
    			.TARGET_ARLEN		( sr_dwc_targetARLEN     ),
    			.TARGET_ARSIZE		( sr_dwc_targetARSIZE    ),
    			.TARGET_ARBURST		( sr_dwc_targetARBURST   ),
    			.TARGET_ARLOCK		( sr_dwc_targetARLOCK    ),
    			.TARGET_ARCACHE		( sr_dwc_targetARCACHE   ),
    			.TARGET_ARPROT		( sr_dwc_targetARPROT    ),
    			.TARGET_ARREGION	( sr_dwc_targetARREGION  ),
    			.TARGET_ARQOS		( sr_dwc_targetARQOS     ),
    			.TARGET_ARUSER		( sr_dwc_targetARUSER    ),
    			.TARGET_ARVALID		( sr_dwc_targetARVALID   ),
    			.TARGET_AWQOS		( sr_dwc_targetAWQOS     ),
    			.TARGET_AWREGION	( sr_dwc_targetAWREGION  ),
    			.TARGET_AWID		( sr_dwc_targetAWID      ),
    			.TARGET_AWADDR		( sr_dwc_targetAWADDR    ),
    			.TARGET_AWLEN		( sr_dwc_targetAWLEN     ),
    			.TARGET_AWSIZE		( sr_dwc_targetAWSIZE    ),
    			.TARGET_AWBURST		( sr_dwc_targetAWBURST   ),
    			.TARGET_AWLOCK		( sr_dwc_targetAWLOCK    ),
    			.TARGET_AWCACHE		( sr_dwc_targetAWCACHE   ),
    			.TARGET_AWPROT		( sr_dwc_targetAWPROT    ),
    			.TARGET_AWUSER		( sr_dwc_targetAWUSER    ),
    			.TARGET_AWVALID		( sr_dwc_targetAWVALID   ),
    			.TARGET_WID   		( sr_dwc_targetWID       ),
    			.TARGET_WDATA		( sr_dwc_targetWDATA     ),
    			.TARGET_WSTRB		( sr_dwc_targetWSTRB     ),
    			.TARGET_WLAST		( sr_dwc_targetWLAST     ),
    			.TARGET_WUSER		( sr_dwc_targetWUSER     ),
    			.TARGET_WVALID		( sr_dwc_targetWVALID    ),
    			.TARGET_BREADY		( sr_dwc_targetBREADY    ),
    			.TARGET_RREADY		( sr_dwc_targetRREADY    ),
    			.TARGET_ARREADY 	( sr_dwc_targetARREADY   ),
    			.TARGET_RID 		( sr_dwc_targetRID       ),
    			.TARGET_RDATA 		( sr_dwc_targetRDATA     ), // output from this module
    			.TARGET_RRESP 		( sr_dwc_targetRRESP     ),
    			.TARGET_RUSER 		( sr_dwc_targetRUSER     ),
    			.TARGET_BID 		( sr_dwc_targetBID       ),
    			.TARGET_BRESP 		( sr_dwc_targetBRESP     ),
    			.TARGET_BUSER 		( sr_dwc_targetBUSER     ),
    			.TARGET_RLAST 		( sr_dwc_targetRLAST     ),
    			.TARGET_RVALID 		( sr_dwc_targetRVALID    ),
    			.TARGET_AWREADY 	( sr_dwc_targetAWREADY   ),
    			.TARGET_WREADY 		( sr_dwc_targetWREADY    ),
    			.TARGET_BVALID 		( sr_dwc_targetBVALID    ),
    			
    			.targetARID			( cdc_dwc_targetARID     ),
    			.targetARADDR		( cdc_dwc_targetARADDR   ),
    			.targetARLEN		( cdc_dwc_targetARLEN    ),
    			.targetARSIZE		( cdc_dwc_targetARSIZE   ),
    			.targetARBURST		( cdc_dwc_targetARBURST  ),
    			.targetARLOCK		( cdc_dwc_targetARLOCK   ),
    			.targetARCACHE		( cdc_dwc_targetARCACHE  ),
    			.targetARPROT		( cdc_dwc_targetARPROT   ),
    			.targetARREGION		( cdc_dwc_targetARREGION ),
    			.targetARQOS		( cdc_dwc_targetARQOS    ),
    			.targetARUSER		( cdc_dwc_targetARUSER   ),
    			.targetARVALID		( cdc_dwc_targetARVALID  ),
    			.targetAWQOS		( cdc_dwc_targetAWQOS    ),
    			.targetAWREGION		( cdc_dwc_targetAWREGION ),
    			.targetAWID			( cdc_dwc_targetAWID     ),
    			.targetAWADDR		( cdc_dwc_targetAWADDR   ),
    			.targetAWLEN		( cdc_dwc_targetAWLEN    ),
    			.targetAWSIZE		( cdc_dwc_targetAWSIZE   ),
    			.targetAWBURST		( cdc_dwc_targetAWBURST  ),
    			.targetAWLOCK		( cdc_dwc_targetAWLOCK   ),
    			.targetAWCACHE		( cdc_dwc_targetAWCACHE  ),
    			.targetAWPROT		( cdc_dwc_targetAWPROT   ),
    			.targetAWUSER		( cdc_dwc_targetAWUSER   ),
    			.targetAWVALID		( cdc_dwc_targetAWVALID  ),
    			.targetWID		    ( cdc_dwc_targetWID      ),
    			.targetWDATA	    ( cdc_dwc_targetWDATA    ),
    			.targetWSTRB	    ( cdc_dwc_targetWSTRB    ),
    			.targetWLAST	    ( cdc_dwc_targetWLAST    ),
    			.targetWUSER	    ( cdc_dwc_targetWUSER    ),
    			.targetWVALID		( cdc_dwc_targetWVALID   ),
    			.targetBREADY		( cdc_dwc_targetBREADY   ),
    			.targetRREADY		( cdc_dwc_targetRREADY   ),
    			.targetARREADY 		( cdc_dwc_targetARREADY  ),
    			.targetRID 			( cdc_dwc_targetRID      ),
    			.targetRDATA 		( cdc_dwc_targetRDATA    ), // Input to this module
    			.targetRRESP 		( cdc_dwc_targetRRESP    ),
    			.targetRUSER 		( cdc_dwc_targetRUSER    ),
    			.targetBID 			( cdc_dwc_targetBID      ),
    			.targetBRESP 		( cdc_dwc_targetBRESP    ),
    			.targetBUSER 		( cdc_dwc_targetBUSER    ),
    			.targetRLAST 		( cdc_dwc_targetRLAST    ),
    			.targetRVALID 		( cdc_dwc_targetRVALID   ),
    			.targetAWREADY 		( cdc_dwc_targetAWREADY  ),
    			.targetWREADY 		( cdc_dwc_targetWREADY   ),
    			.targetBVALID 		( cdc_dwc_targetBVALID   )
    		);  
			
	caxi4interconnect_TrgtDataWidthConverter #
						(
							.TARGET_TYPE            ( TARGET_TYPE          ) , 		// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b10
							.TARGET_NUMBER          ( TARGET_NUMBER        ),		// target number
							.MAX_TRANS		        ( MAX_TRANS            ),
							.ID_WIDTH               ( ID_WIDTH             ),
							.ADDR_WIDTH             ( ADDR_WIDTH           ),
							.DATA_WIDTH             ( DATA_WIDTH           ),
							.TARGET_DATA_WIDTH      ( TARGET_DATA_WIDTH    ),
							.USER_WIDTH             ( USER_WIDTH           ),
							.DWC_ADDR_FIFO_DEPTH    ( DWC_ADDR_FIFO_DEPTH  ),
							.DATA_FIFO_DEPTH        ( DWC_DATA_FIFO_DEPTH  ),
                            .READ_INTERLEAVE        ( READ_INTERLEAVE      ),                            
                            .PIPE                   ( PIPE                 ),							
                            .DWC_RAM_TYPE           ( DWC_RAM_TYPE         ),							
                            .SYNC_RESET             ( SYNC_RESET           )							
						)
				trgtdwc (
							// Global Signals
							.ACLK                   ( TRGT_CLK               ),
							.arst_sync              ( tarst_sync             ),				// active low reset synchronoise to RE AClk - asserted async.
							.srst_sync              ( tsrst_sync             ),				// active low reset synchronoise to RE AClk - asserted async.
		   
							// Initiator Read Address Ports
							.TARGET_ARID	        ( dwc_cdc_targetARID     ),
							.TARGET_ARADDR		    ( dwc_cdc_targetARADDR   ),
							.TARGET_ARLEN		    ( dwc_cdc_targetARLEN    ),
							.TARGET_ARSIZE		    ( dwc_cdc_targetARSIZE   ),
							.TARGET_ARBURST		    ( dwc_cdc_targetARBURST  ),
							.TARGET_ARLOCK		    ( dwc_cdc_targetARLOCK   ),
							.TARGET_ARCACHE		    ( dwc_cdc_targetARCACHE  ),
							.TARGET_ARPROT		    ( dwc_cdc_targetARPROT   ),
							.TARGET_ARREGION	    ( dwc_cdc_targetARREGION ),
							.TARGET_ARQOS		    ( dwc_cdc_targetARQOS    ),
							.TARGET_ARUSER		    ( dwc_cdc_targetARUSER   ),
							.TARGET_ARVALID		    ( dwc_cdc_targetARVALID  ),
							.TARGET_AWQOS		    ( dwc_cdc_targetAWQOS    ),
							.TARGET_AWREGION	    ( dwc_cdc_targetAWREGION ),
							.TARGET_AWID		    ( dwc_cdc_targetAWID     ),
							.TARGET_AWADDR		    ( dwc_cdc_targetAWADDR   ),
							.TARGET_AWLEN		    ( dwc_cdc_targetAWLEN    ),
							.TARGET_AWSIZE		    ( dwc_cdc_targetAWSIZE   ),
							.TARGET_AWBURST		    ( dwc_cdc_targetAWBURST  ),
							.TARGET_AWLOCK		    ( dwc_cdc_targetAWLOCK   ),
							.TARGET_AWCACHE		    ( dwc_cdc_targetAWCACHE  ),
							.TARGET_AWPROT		    ( dwc_cdc_targetAWPROT   ),
							.TARGET_AWUSER		    ( dwc_cdc_targetAWUSER   ),
							.TARGET_AWVALID		    ( dwc_cdc_targetAWVALID  ),
							.TARGET_WID             ( dwc_cdc_targetWID      ),
							.TARGET_WDATA		    ( dwc_cdc_targetWDATA    ),
							.TARGET_WSTRB		    ( dwc_cdc_targetWSTRB    ),
							.TARGET_WLAST		    ( dwc_cdc_targetWLAST    ),
							.TARGET_WUSER		    ( dwc_cdc_targetWUSER    ),
							.TARGET_WVALID		    ( dwc_cdc_targetWVALID   ),
							.TARGET_BREADY		    ( dwc_cdc_targetBREADY   ),
							.TARGET_RREADY		    ( dwc_cdc_targetRREADY   ),
							.TARGET_ARREADY 	    ( dwc_cdc_targetARREADY  ),
							.TARGET_RID 		    ( dwc_cdc_targetRID      ),
							.TARGET_RDATA 		    ( dwc_cdc_targetRDATA    ), // Input from this module
							.TARGET_RRESP 		    ( dwc_cdc_targetRRESP    ),
							.TARGET_RUSER 		    ( dwc_cdc_targetRUSER    ),
							.TARGET_BID 		    ( dwc_cdc_targetBID      ),
							.TARGET_BRESP 		    ( dwc_cdc_targetBRESP    ),
							.TARGET_BUSER 		    ( dwc_cdc_targetBUSER    ),
							.TARGET_RLAST 		    ( dwc_cdc_targetRLAST    ),
							.TARGET_RVALID 		    ( dwc_cdc_targetRVALID   ),
							.TARGET_AWREADY 	    ( dwc_cdc_targetAWREADY  ),
							.TARGET_WREADY 		    ( dwc_cdc_targetWREADY   ),
							.TARGET_BVALID 		    ( dwc_cdc_targetBVALID   ),
							
							.int_targetARID			( cdc_dwc_targetARID      ),
							.int_targetARADDR		( cdc_dwc_targetARADDR    ),
							.int_targetARLEN		( cdc_dwc_targetARLEN     ),
							.int_targetARSIZE		( cdc_dwc_targetARSIZE    ),
							.int_targetARBURST		( cdc_dwc_targetARBURST   ),
							.int_targetARLOCK		( cdc_dwc_targetARLOCK    ),
							.int_targetARCACHE		( cdc_dwc_targetARCACHE   ),
							.int_targetARPROT		( cdc_dwc_targetARPROT    ),
							.int_targetARREGION		( cdc_dwc_targetARREGION  ),
							.int_targetARQOS		( cdc_dwc_targetARQOS     ),
							.int_targetARUSER		( cdc_dwc_targetARUSER    ),
							.int_targetARVALID		( cdc_dwc_targetARVALID   ),
							.int_targetAWQOS		( cdc_dwc_targetAWQOS     ),
							.int_targetAWREGION		( cdc_dwc_targetAWREGION  ),
							.int_targetAWID			( cdc_dwc_targetAWID      ),
							.int_targetAWADDR		( cdc_dwc_targetAWADDR    ),
							.int_targetAWLEN		( cdc_dwc_targetAWLEN     ),
							.int_targetAWSIZE		( cdc_dwc_targetAWSIZE    ),
							.int_targetAWBURST		( cdc_dwc_targetAWBURST   ),
							.int_targetAWLOCK		( cdc_dwc_targetAWLOCK    ),
							.int_targetAWCACHE		( cdc_dwc_targetAWCACHE   ),
							.int_targetAWPROT		( cdc_dwc_targetAWPROT    ),
							.int_targetAWUSER		( cdc_dwc_targetAWUSER    ),
							.int_targetAWVALID		( cdc_dwc_targetAWVALID   ),
							.int_targetWID			( cdc_dwc_targetWID       ),
							.int_targetWDATA		( cdc_dwc_targetWDATA     ),
							.int_targetWSTRB		( cdc_dwc_targetWSTRB     ),
							.int_targetWLAST		( cdc_dwc_targetWLAST     ),
							.int_targetWUSER		( cdc_dwc_targetWUSER     ),
							.int_targetWVALID		( cdc_dwc_targetWVALID    ),
							.int_targetBREADY		( cdc_dwc_targetBREADY    ),
							.int_targetRREADY		( cdc_dwc_targetRREADY    ),
							.int_targetARREADY 		( cdc_dwc_targetARREADY   ),
							.int_targetRID 			( cdc_dwc_targetRID       ),
							.int_targetRDATA 		( cdc_dwc_targetRDATA     ), // Output from this module, goes to RS
							.int_targetRRESP 		( cdc_dwc_targetRRESP     ),
							.int_targetRUSER 		( cdc_dwc_targetRUSER     ),
							.int_targetBID 			( cdc_dwc_targetBID       ),
							.int_targetBRESP 		( cdc_dwc_targetBRESP     ),
							.int_targetBUSER 		( cdc_dwc_targetBUSER     ),
							.int_targetRLAST 		( cdc_dwc_targetRLAST     ),
							.int_targetRVALID 		( cdc_dwc_targetRVALID    ),
							.int_targetAWREADY 		( cdc_dwc_targetAWREADY   ),
							.int_targetWREADY 		( cdc_dwc_targetWREADY    ),
							.int_targetBVALID 		( cdc_dwc_targetBVALID    )

						)	; 			

	caxi4interconnect_RegisterSlice #

		(
			.AWCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
			.ARCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
			.RCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
			.WCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
			.BCHAN	                ( DWC_CHAN_RS_EN       ),			// 0 means no slice on channel - 1 means full slice on channel
			.ID_WIDTH   			( ID_WIDTH             ), 
			.ADDR_WIDTH      		( ADDR_WIDTH           ),
			.DATA_WIDTH 			( TARGET_DATA_WIDTH    ), 
			.SUPPORT_USER_SIGNALS 	( SUPPORT_USER_SIGNALS ),
			.USER_WIDTH 			( USER_WIDTH           )
		)
		trgt_dwc_rgsl(

				//=====================================  Global Signals   =====================================================
				.sysClk	    ( TRGT_CLK               ),
				.arst_sync	( tarst_sync             ),
				.srst_sync	( tsrst_sync             ),
  
				// Read Address Channel
				.srcARID	( dwc_cdc_targetARID     ),
				.srcARADDR	( dwc_cdc_targetARADDR   ),
				.srcARLEN	( dwc_cdc_targetARLEN    ),
				.srcARSIZE	( dwc_cdc_targetARSIZE   ),
				.srcARBURST	( dwc_cdc_targetARBURST  ),
				.srcARLOCK	( dwc_cdc_targetARLOCK   ),
				.srcARCACHE	( dwc_cdc_targetARCACHE  ),
				.srcARPROT	( dwc_cdc_targetARPROT   ),
				.srcARREGION( dwc_cdc_targetARREGION ),
				.srcARQOS	( dwc_cdc_targetARQOS    ),
				.srcARUSER	( dwc_cdc_targetARUSER   ),
				.srcARVALID	( dwc_cdc_targetARVALID  ),
				.srcARREADY	( dwc_cdc_targetARREADY  ),
	
				.dstARID	( cdc_prot_targetARID     ),
				.dstARADDR	( cdc_prot_targetARADDR   ),
				.dstARLEN	( cdc_prot_targetARLEN    ),
				.dstARSIZE	( cdc_prot_targetARSIZE   ),
				.dstARBURST	( cdc_prot_targetARBURST  ),
				.dstARLOCK	( cdc_prot_targetARLOCK   ),
				.dstARCACHE	( cdc_prot_targetARCACHE  ),
				.dstARPROT	( cdc_prot_targetARPROT   ),
				.dstARREGION( cdc_prot_targetARREGION ),
				.dstARQOS	( cdc_prot_targetARQOS    ),
				.dstARUSER	( cdc_prot_targetARUSER   ),
				.dstARVALID	( cdc_prot_targetARVALID  ),
				.dstARREADY	( cdc_prot_targetARREADY  ),
	
				// Read Data Channel	
				.srcRID		( dwc_cdc_targetRID       ),
				.srcRDATA	( dwc_cdc_targetRDATA     ), // output from this module, input to this file
				.srcRRESP	( dwc_cdc_targetRRESP     ),
				.srcRLAST	( dwc_cdc_targetRLAST     ),
				.srcRUSER	( dwc_cdc_targetRUSER     ),
				.srcRVALID	( dwc_cdc_targetRVALID    ),
				.srcRREADY	( dwc_cdc_targetRREADY    ),
	
				.dstRID		( cdc_prot_targetRID      ),
				.dstRDATA	( cdc_prot_targetRDATA    ), // input to this module, 
				.dstRRESP	( cdc_prot_targetRRESP    ),
				.dstRLAST	( cdc_prot_targetRLAST    ),
				.dstRUSER	( cdc_prot_targetRUSER    ),
				.dstRVALID	( cdc_prot_targetRVALID   ),
				.dstRREADY	( cdc_prot_targetRREADY   ),
	
				// Write Address Channel	
				.srcAWID	( dwc_cdc_targetAWID      ),
				.srcAWADDR	( dwc_cdc_targetAWADDR    ),
				.srcAWLEN	( dwc_cdc_targetAWLEN     ),
				.srcAWSIZE	( dwc_cdc_targetAWSIZE    ),
				.srcAWBURST	( dwc_cdc_targetAWBURST   ),
				.srcAWLOCK	( dwc_cdc_targetAWLOCK    ),
				.srcAWCACHE	( dwc_cdc_targetAWCACHE   ),
				.srcAWPROT	( dwc_cdc_targetAWPROT    ),
				.srcAWREGION( dwc_cdc_targetAWREGION  ),
				.srcAWQOS	( dwc_cdc_targetAWQOS     ),
				.srcAWUSER	( dwc_cdc_targetAWUSER    ),
				.srcAWVALID	( dwc_cdc_targetAWVALID   ),
				.srcAWREADY	( dwc_cdc_targetAWREADY   ),
	
				.dstAWID	( cdc_prot_targetAWID     ), 
				.dstAWADDR	( cdc_prot_targetAWADDR   ), 
				.dstAWLEN	( cdc_prot_targetAWLEN    ),  
				.dstAWSIZE	( cdc_prot_targetAWSIZE   ),  
				.dstAWBURST	( cdc_prot_targetAWBURST  ),  
				.dstAWLOCK	( cdc_prot_targetAWLOCK   ),  
				.dstAWCACHE	( cdc_prot_targetAWCACHE  ),  
				.dstAWPROT	( cdc_prot_targetAWPROT   ),  
				.dstAWREGION( cdc_prot_targetAWREGION ), 
				.dstAWQOS	( cdc_prot_targetAWQOS    ), 
				.dstAWUSER	( cdc_prot_targetAWUSER   ), 
				.dstAWVALID	( cdc_prot_targetAWVALID  ), 
				.dstAWREADY	( cdc_prot_targetAWREADY  ),

				// Write Data Channel	
				.srcWID	    ( dwc_cdc_targetWID       ),
				.srcWDATA	( dwc_cdc_targetWDATA     ),
				.srcWSTRB	( dwc_cdc_targetWSTRB     ),
				.srcWLAST	( dwc_cdc_targetWLAST     ),
				.srcWUSER	( dwc_cdc_targetWUSER     ),
				.srcWVALID	( dwc_cdc_targetWVALID    ),
				.srcWREADY	( dwc_cdc_targetWREADY    ),
	
	            .dstWID     ( cdc_prot_targetWID      ),
				.dstWDATA	( cdc_prot_targetWDATA    ),
				.dstWSTRB	( cdc_prot_targetWSTRB    ),
				.dstWLAST	( cdc_prot_targetWLAST    ),
				.dstWUSER	( cdc_prot_targetWUSER    ),
				.dstWVALID	( cdc_prot_targetWVALID   ),
				.dstWREADY	( cdc_prot_targetWREADY   ),	

				// Write Response Channel	
				.srcBID		( dwc_cdc_targetBID       ),
				.srcBRESP	( dwc_cdc_targetBRESP     ),
				.srcBUSER	( dwc_cdc_targetBUSER     ),
				.srcBVALID	( dwc_cdc_targetBVALID    ),
				.srcBREADY	( dwc_cdc_targetBREADY    ),

				.dstBID		( cdc_prot_targetBID      ),
				.dstBRESP	( cdc_prot_targetBRESP    ),
				.dstBUSER	( cdc_prot_targetBUSER    ),
				.dstBVALID	( cdc_prot_targetBVALID   ),
				.dstBREADY	( cdc_prot_targetBREADY   )

			)	;		

	caxi4interconnect_TrgtProtocolConverter #
						(
							.TARGET_TYPE                ( TARGET_TYPE            ) , 	// Protocol type = AXI4 - 2'b00, AXI4Lite - 2'b01, AXI3 - 2'b11
							.TARGET_NUMBER              ( TARGET_NUMBER          ),	// target number
							.ID_WIDTH                   ( ID_WIDTH               ),
							.ADDR_WIDTH                 ( ADDR_WIDTH             ),				
							.DATA_WIDTH                 ( TARGET_DATA_WIDTH      ), 
							.USER_WIDTH                 ( USER_WIDTH             ),
							.WRITE_ZERO_TARGET_ID       ( WRITE_ZERO_TARGET_ID   ),
							.READ_ZERO_TARGET_ID        ( READ_ZERO_TARGET_ID    ),				
							.TRGT_AXI4PRT_ADDRDEPTH 	( TRGT_AXI4PRT_ADDRDEPTH ),
							.TRGT_AXI4PRT_DATADEPTH 	( TRGT_AXI4PRT_DATADEPTH ),
							.MAX_TRANS                  ( MAX_TRANS              ),
							.READ_INTERLEAVE            ( READ_INTERLEAVE        ),
	      		            .PIPE                       ( PIPE                   ),
	      		            .PROTOCONV_RAM_TYPE         ( PROTOCONV_RAM_TYPE     ),
	      		            .SYNC_RESET                 ( SYNC_RESET             ),
	      		            .DWC_ENABLED                ( DWC_ENABLED            ),
	      		            .BYPASS_CROSSBAR            ( BYPASS_CROSSBAR        )
						)
				trgtProtConv (
							// Global Signals
							.ACLK                       ( TRGT_CLK               ),
							.arst_sync                  ( tarst_sync              ),				// active low reset synchronoise to RE AClk - asserted async.
							.srst_sync                  ( tsrst_sync              ),				// active low reset synchronoise to RE AClk - asserted async.
		   
							// Initiator Read Address Ports
							.TARGET_ARID		        ( arid_pipe_in           ),  
							.TARGET_ARADDR		        ( araddr_pipe_in         ),  
							.TARGET_ARLEN		        ( arlen_pipe_in          ),  
							.TARGET_ARSIZE		        ( arsize_pipe_in         ),  
							.TARGET_ARBURST		        ( arburst_pipe_in        ),  
							.TARGET_ARLOCK		        ( arlock_pipe_in         ),  
							.TARGET_ARCACHE		        ( arcache_pipe_in        ),  
							.TARGET_ARPROT		        ( arprot_pipe_in         ),  
							.TARGET_ARREGION		    ( arregion_pipe_in       ),  
							.TARGET_ARQOS		        ( arqos_pipe_in          ),  
							.TARGET_ARUSER		        ( aruser_pipe_in         ),  
							.TARGET_ARVALID		        ( arvalid_pipe_in        ),  
							.TARGET_ARREADY 		    ( arready_pipe_in        ),							
							.TARGET_AWID			    ( awid_pipe_in           ),
							.TARGET_AWADDR		        ( awaddr_pipe_in         ),
							.TARGET_AWLEN		        ( awlen_pipe_in          ),
							.TARGET_AWSIZE		        ( awsize_pipe_in         ),
							.TARGET_AWBURST		        ( awburst_pipe_in        ),
							.TARGET_AWLOCK		        ( awlock_pipe_in         ),
							.TARGET_AWCACHE		        ( awcache_pipe_in        ),
							.TARGET_AWPROT		        ( awprot_pipe_in         ),
							.TARGET_AWQOS		        ( awqos_pipe_in          ),
							.TARGET_AWREGION		    ( awregion_pipe_in       ),
							.TARGET_AWUSER		        ( awuser_pipe_in         ),
							.TARGET_AWVALID		        ( awvalid_pipe_in        ),
							.TARGET_AWREADY 		    ( awready_pipe_in        ),
							.TARGET_WID			        ( wid_pipe_in            ),
							.TARGET_WDATA		        ( wdata_pipe_in          ),
							.TARGET_WSTRB		        ( wstrb_pipe_in          ),
							.TARGET_WLAST		        ( wlast_pipe_in          ),
							.TARGET_WUSER		        ( wuser_pipe_in          ),
							.TARGET_WVALID		        ( wvalid_pipe_in         ),
							.TARGET_WREADY 		        ( wready_pipe_in         ),							
							
							.TARGET_RID 			    ( rid_pipe_in            ),
							.TARGET_RDATA 		        ( rdata_pipe_in          ), 
							.TARGET_RRESP 		        ( rresp_pipe_in          ),
							.TARGET_RLAST 		        ( rlast_pipe_in          ),
							.TARGET_RUSER 		        ( ruser_pipe_in          ),
							.TARGET_RVALID 		        ( rvalid_pipe_in         ),
							.TARGET_RREADY		        ( rready_pipe_in         ),
							.TARGET_BID 			    ( bid_pipe_in            ),
							.TARGET_BRESP 		        ( bresp_pipe_in          ),
							.TARGET_BUSER 		        ( buser_pipe_in          ),
							.TARGET_BVALID 		        ( bvalid_pipe_in         ),
							.TARGET_BREADY		        ( bready_pipe_in         ),		
							
							.int_targetARID			    ( cdc_prot_targetARID     ),
							.int_targetARADDR		    ( cdc_prot_targetARADDR   ),
							.int_targetARLEN			( cdc_prot_targetARLEN    ),
							.int_targetARSIZE		    ( cdc_prot_targetARSIZE   ),
							.int_targetARBURST		    ( cdc_prot_targetARBURST  ),
							.int_targetARLOCK		    ( cdc_prot_targetARLOCK   ),
							.int_targetARCACHE		    ( cdc_prot_targetARCACHE  ),
							.int_targetARPROT		    ( cdc_prot_targetARPROT   ),
							.int_targetARREGION		    ( cdc_prot_targetARREGION ),
							.int_targetARQOS			( cdc_prot_targetARQOS    ),
							.int_targetARUSER		    ( cdc_prot_targetARUSER   ),
							.int_targetARVALID		    ( cdc_prot_targetARVALID  ),
							.int_targetAWQOS			( cdc_prot_targetAWQOS    ),
							.int_targetAWREGION		    ( cdc_prot_targetAWREGION ),
							.int_targetAWID			    ( cdc_prot_targetAWID     ),
							.int_targetAWADDR		    ( cdc_prot_targetAWADDR   ),
							.int_targetAWLEN			( cdc_prot_targetAWLEN    ),
							.int_targetAWSIZE		    ( cdc_prot_targetAWSIZE   ),
							.int_targetAWBURST		    ( cdc_prot_targetAWBURST  ),
							.int_targetAWLOCK		    ( cdc_prot_targetAWLOCK   ),
							.int_targetAWCACHE		    ( cdc_prot_targetAWCACHE  ),
							.int_targetAWPROT		    ( cdc_prot_targetAWPROT   ),
							.int_targetAWUSER		    ( cdc_prot_targetAWUSER   ),
							.int_targetAWVALID		    ( cdc_prot_targetAWVALID  ),
							.int_targetWID			    ( cdc_prot_targetWID      ),
							.int_targetWDATA			( cdc_prot_targetWDATA    ),
							.int_targetWSTRB			( cdc_prot_targetWSTRB    ),
							.int_targetWLAST			( cdc_prot_targetWLAST    ),
							.int_targetWUSER			( cdc_prot_targetWUSER    ),
							.int_targetWVALID		    ( cdc_prot_targetWVALID   ),
							.int_targetBREADY		    ( cdc_prot_targetBREADY   ),
							.int_targetRREADY		    ( cdc_prot_targetRREADY   ),
							.int_targetARREADY 		    ( cdc_prot_targetARREADY  ),
							.int_targetRID 			    ( cdc_prot_targetRID      ),
							.int_targetRDATA 		    ( cdc_prot_targetRDATA    ), // outout from this module
							.int_targetRRESP 		    ( cdc_prot_targetRRESP    ),
							.int_targetRUSER 		    ( cdc_prot_targetRUSER    ),
							.int_targetBID 			    ( cdc_prot_targetBID      ),
							.int_targetBRESP 		    ( cdc_prot_targetBRESP    ),
							.int_targetBUSER 		    ( cdc_prot_targetBUSER    ),
							.int_targetRLAST 		    ( cdc_prot_targetRLAST    ),
							.int_targetRVALID 		    ( cdc_prot_targetRVALID   ),
							.int_targetAWREADY 		    ( cdc_prot_targetAWREADY  ),
							.int_targetWREADY 		    ( cdc_prot_targetWREADY   ),
							.int_targetBVALID 		    ( cdc_prot_targetBVALID   )

						    );			
  end 
endgenerate
	


genvar trgt_rs; 
generate 
    wire [ID_WIDTH-1:0] 	           arid_pipe      [NUM_RS_STAGES:0];
    wire [ADDR_WIDTH-1:0]	           araddr_pipe    [NUM_RS_STAGES:0];
    wire [7:0]        		           arlen_pipe     [NUM_RS_STAGES:0];
    wire [2:0]          	           arsize_pipe    [NUM_RS_STAGES:0];
    wire [1:0]          	           arburst_pipe   [NUM_RS_STAGES:0];
    wire [1:0]          	           arlock_pipe    [NUM_RS_STAGES:0];
    wire [3:0]           	           arcache_pipe   [NUM_RS_STAGES:0];
    wire [2:0]         		           arprot_pipe    [NUM_RS_STAGES:0];
    wire [3:0]          	           arregion_pipe  [NUM_RS_STAGES:0];
    wire [3:0]          	           arqos_pipe     [NUM_RS_STAGES:0];
    wire [USER_WIDTH-1:0]	           aruser_pipe    [NUM_RS_STAGES:0];
    wire            		           arvalid_pipe   [NUM_RS_STAGES:0];
    wire            		           arready_pipe   [NUM_RS_STAGES:0];
    wire [ID_WIDTH-1:0]   	           rid_pipe       [NUM_RS_STAGES:0];
    wire [TARGET_DATA_WIDTH-1:0]	   rdata_pipe     [NUM_RS_STAGES:0];
    wire [1:0]           	           rresp_pipe     [NUM_RS_STAGES:0];
    wire                	           rlast_pipe     [NUM_RS_STAGES:0];
    wire [USER_WIDTH-1:0] 	           ruser_pipe     [NUM_RS_STAGES:0];
    wire                 	           rvalid_pipe    [NUM_RS_STAGES:0];
    wire               		           rready_pipe    [NUM_RS_STAGES:0];
    wire [ID_WIDTH-1:0]  	           awid_pipe      [NUM_RS_STAGES:0];
    wire [ADDR_WIDTH-1:0] 	           awaddr_pipe    [NUM_RS_STAGES:0];
    wire [7:0]           	           awlen_pipe     [NUM_RS_STAGES:0];
    wire [2:0]           	           awsize_pipe    [NUM_RS_STAGES:0];
    wire [1:0]           	           awburst_pipe   [NUM_RS_STAGES:0];
    wire [1:0]           	           awlock_pipe    [NUM_RS_STAGES:0];
    wire [3:0]          	           awcache_pipe   [NUM_RS_STAGES:0];
    wire [2:0]           	           awprot_pipe    [NUM_RS_STAGES:0];
    wire [3:0]            	           awregion_pipe  [NUM_RS_STAGES:0];
    wire [3:0]           	           awqos_pipe     [NUM_RS_STAGES:0];
    wire [USER_WIDTH-1:0]              awuser_pipe    [NUM_RS_STAGES:0];
    wire                 	           awvalid_pipe   [NUM_RS_STAGES:0];
    wire                	           awready_pipe   [NUM_RS_STAGES:0];	
    wire [ID_WIDTH-1:0]                wid_pipe       [NUM_RS_STAGES:0];
    wire [TARGET_DATA_WIDTH-1:0]  	   wdata_pipe     [NUM_RS_STAGES:0];
    wire [(TARGET_DATA_WIDTH/8)-1:0]   wstrb_pipe     [NUM_RS_STAGES:0];
    wire                  	           wlast_pipe     [NUM_RS_STAGES:0];
    wire [USER_WIDTH-1:0] 	           wuser_pipe     [NUM_RS_STAGES:0];
    wire                  	           wvalid_pipe    [NUM_RS_STAGES:0];
    wire                   	           wready_pipe    [NUM_RS_STAGES:0];	
    wire [ID_WIDTH-1:0]		           bid_pipe       [NUM_RS_STAGES:0];
    wire [1:0]           	           bresp_pipe     [NUM_RS_STAGES:0];
    wire [USER_WIDTH-1:0] 	           buser_pipe     [NUM_RS_STAGES:0];
    wire      				           bvalid_pipe    [NUM_RS_STAGES:0];
    wire					           bready_pipe    [NUM_RS_STAGES:0];

    assign arid_pipe       [0]                    = arid_pipe_in     ;
    assign araddr_pipe     [0]                    = araddr_pipe_in   ;
    assign arlen_pipe      [0]                    = arlen_pipe_in    ;
    assign arsize_pipe     [0]                    = arsize_pipe_in   ;
    assign arburst_pipe    [0]                    = arburst_pipe_in  ;
    assign arlock_pipe     [0]                    = arlock_pipe_in   ;
    assign arcache_pipe    [0]                    = arcache_pipe_in  ;
    assign arprot_pipe     [0]                    = arprot_pipe_in   ;
    assign arregion_pipe   [0]                    = arregion_pipe_in ;
    assign arqos_pipe      [0]                    = arqos_pipe_in    ;
    assign aruser_pipe     [0]                    = aruser_pipe_in   ;
    assign arvalid_pipe    [0]                    = arvalid_pipe_in  ;
    assign arready_pipe_in                        = arready_pipe[0] ;

    assign rid_pipe_in                            = rid_pipe   [0]  ;
    assign rdata_pipe_in                          = rdata_pipe [0]  ;
    assign rresp_pipe_in                          = rresp_pipe [0]  ;
    assign rlast_pipe_in                          = rlast_pipe [0]  ;
    assign ruser_pipe_in                          = ruser_pipe [0]  ;
    assign rvalid_pipe_in                         = rvalid_pipe[0]  ;
    assign rready_pipe[0]                         = rready_pipe_in  ; 

    assign awid_pipe          [0]                 = awid_pipe_in    ;
    assign awaddr_pipe        [0]                 = awaddr_pipe_in  ;
    assign awlen_pipe         [0]                 = awlen_pipe_in   ;
    assign awsize_pipe        [0]                 = awsize_pipe_in  ;
    assign awburst_pipe       [0]                 = awburst_pipe_in ;
    assign awlock_pipe        [0]                 = awlock_pipe_in  ;
    assign awcache_pipe       [0]                 = awcache_pipe_in ;
    assign awprot_pipe        [0]                 = awprot_pipe_in  ;
    assign awregion_pipe      [0]                 = awregion_pipe_in;
    assign awqos_pipe         [0]                 = awqos_pipe_in   ;
    assign awuser_pipe        [0]                 = awuser_pipe_in  ;
    assign awvalid_pipe       [0]                 = awvalid_pipe_in ;
    assign awready_pipe_in                        = awready_pipe[0] ;
	
	assign wid_pipe    [0]                        = wid_pipe_in     ;
	assign wdata_pipe  [0]                        = wdata_pipe_in   ;
	assign wstrb_pipe  [0]                        = wstrb_pipe_in   ;
	assign wlast_pipe  [0]                        = wlast_pipe_in   ;
	assign wuser_pipe  [0]                        = wuser_pipe_in   ;
	assign wvalid_pipe [0]                        = wvalid_pipe_in  ;
	assign wready_pipe_in                         = wready_pipe[0]  ;
	
	assign bid_pipe_in                            = bid_pipe    [0] ;     
	assign bresp_pipe_in                          = bresp_pipe  [0] ;     
	assign buser_pipe_in                          = buser_pipe  [0] ;     
	assign bvalid_pipe_in                         = bvalid_pipe [0] ;     
	assign bready_pipe[0]                         = bready_pipe_in  ;     
    // Connect module inputs to first stage
	

    if(NUM_RS_STAGES != 0) begin 
      for(trgt_rs=0; trgt_rs<NUM_RS_STAGES; trgt_rs=trgt_rs+1) begin 
        caxi4interconnect_RegisterSlice #
	    (
	    	.AWCHAN			     (1                      ),		
	    	.ARCHAN			     (1                      ),		
	    	.RCHAN			     (1                      ),		
	    	.WCHAN			     (1                      ),		
	    	.BCHAN			     (1                      ),									 
	    	.ID_WIDTH   		 (ID_WIDTH               ),							 
	    	.ADDR_WIDTH      	 (ADDR_WIDTH             ),
	    	.DATA_WIDTH 		 (TARGET_DATA_WIDTH      ),							 
	    	.SUPPORT_USER_SIGNALS(SUPPORT_USER_SIGNALS   ),
	    	.USER_WIDTH 		 (USER_WIDTH             ), 	
	    	.READY_REG   		 ( 1                     ) 	
	    ) trgt_rs_in_inst
	    (
	    //=====================================  Global Signals   ========================================================================
	      .sysClk        (TRGT_CLK                      ),
	      .arst_sync     (tarst_sync                    ),
	      .srst_sync     (tsrst_sync                    ),
		  
	      .srcARID       (arid_pipe       [trgt_rs]    ),
	      .srcARADDR     (araddr_pipe     [trgt_rs]    ),
	      .srcARLEN      (arlen_pipe      [trgt_rs]    ),
	      .srcARSIZE     (arsize_pipe     [trgt_rs]    ),
	      .srcARBURST    (arburst_pipe    [trgt_rs]    ),
	      .srcARLOCK     (arlock_pipe     [trgt_rs]    ),
	      .srcARCACHE    (arcache_pipe    [trgt_rs]    ),
	      .srcARPROT     (arprot_pipe     [trgt_rs]    ),
	      .srcARREGION   (arregion_pipe   [trgt_rs]    ),
	      .srcARQOS      (arqos_pipe      [trgt_rs]    ),
	      .srcARUSER     (aruser_pipe     [trgt_rs]    ),
	      .srcARVALID    (arvalid_pipe    [trgt_rs]    ),
	      .srcARREADY    (arready_pipe    [trgt_rs]    ),
		  
	      .dstARID       (arid_pipe       [trgt_rs+1]  ),
	      .dstARADDR     (araddr_pipe     [trgt_rs+1]  ),
	      .dstARLEN      (arlen_pipe      [trgt_rs+1]  ),
	      .dstARSIZE     (arsize_pipe     [trgt_rs+1]  ),
	      .dstARBURST    (arburst_pipe    [trgt_rs+1]  ),
	      .dstARLOCK     (arlock_pipe     [trgt_rs+1]  ),
	      .dstARCACHE    (arcache_pipe    [trgt_rs+1]  ),
	      .dstARPROT     (arprot_pipe     [trgt_rs+1]  ),
	      .dstARREGION   (arregion_pipe   [trgt_rs+1]  ),
	      .dstARQOS      (arqos_pipe      [trgt_rs+1]  ),
	      .dstARUSER     (aruser_pipe     [trgt_rs+1]  ),
	      .dstARVALID    (arvalid_pipe    [trgt_rs+1]  ),
	      .dstARREADY    (arready_pipe    [trgt_rs+1]  ),
		  
	      .dstRID        (rid_pipe        [trgt_rs+1]  ),
	      .dstRDATA      (rdata_pipe      [trgt_rs+1]  ),
	      .dstRRESP      (rresp_pipe      [trgt_rs+1]  ),
	      .dstRLAST      (rlast_pipe      [trgt_rs+1]  ),
	      .dstRUSER      (ruser_pipe      [trgt_rs+1]  ),
	      .dstRVALID     (rvalid_pipe     [trgt_rs+1]  ),
	      .dstRREADY     (rready_pipe     [trgt_rs+1]  ),
		  
	      .srcRID        (rid_pipe        [trgt_rs]    ),
	      .srcRDATA      (rdata_pipe      [trgt_rs]    ),
	      .srcRRESP      (rresp_pipe      [trgt_rs]    ),
	      .srcRLAST      (rlast_pipe      [trgt_rs]    ),
	      .srcRUSER      (ruser_pipe      [trgt_rs]    ),
	      .srcRVALID     (rvalid_pipe     [trgt_rs]    ),
	      .srcRREADY     (rready_pipe     [trgt_rs]    ),
		  
	      .srcAWID       (awid_pipe       [trgt_rs]    ),
	      .srcAWADDR     (awaddr_pipe     [trgt_rs]    ),
	      .srcAWLEN      (awlen_pipe      [trgt_rs]    ),
	      .srcAWSIZE     (awsize_pipe     [trgt_rs]    ),
	      .srcAWBURST    (awburst_pipe    [trgt_rs]    ),
	      .srcAWLOCK     (awlock_pipe     [trgt_rs]    ),
	      .srcAWCACHE    (awcache_pipe    [trgt_rs]    ),
	      .srcAWPROT     (awprot_pipe     [trgt_rs]    ),
	      .srcAWREGION   (awregion_pipe   [trgt_rs]    ),
	      .srcAWQOS      (awqos_pipe      [trgt_rs]    ),
	      .srcAWUSER     (awuser_pipe     [trgt_rs]    ),
	      .srcAWVALID    (awvalid_pipe    [trgt_rs]    ),
	      .srcAWREADY    (awready_pipe    [trgt_rs]    ),
		  
	      .dstAWID       (awid_pipe       [trgt_rs+1]  ),
	      .dstAWADDR     (awaddr_pipe     [trgt_rs+1]  ),
	      .dstAWLEN      (awlen_pipe      [trgt_rs+1]  ),
	      .dstAWSIZE     (awsize_pipe     [trgt_rs+1]  ),
	      .dstAWBURST    (awburst_pipe    [trgt_rs+1]  ),
	      .dstAWLOCK     (awlock_pipe     [trgt_rs+1]  ),
	      .dstAWCACHE    (awcache_pipe    [trgt_rs+1]  ),
	      .dstAWPROT     (awprot_pipe     [trgt_rs+1]  ),
	      .dstAWREGION   (awregion_pipe   [trgt_rs+1]  ),
	      .dstAWQOS      (awqos_pipe      [trgt_rs+1]  ),
	      .dstAWUSER     (awuser_pipe     [trgt_rs+1]  ),
	      .dstAWVALID    (awvalid_pipe    [trgt_rs+1]  ),
	      .dstAWREADY    (awready_pipe    [trgt_rs+1]  ),
		  
	      .srcWID        (wid_pipe        [trgt_rs]    ),
	      .srcWDATA      (wdata_pipe      [trgt_rs]    ),
	      .srcWSTRB      (wstrb_pipe      [trgt_rs]    ),
	      .srcWLAST      (wlast_pipe      [trgt_rs]    ),
	      .srcWUSER      (wuser_pipe      [trgt_rs]    ),
	      .srcWVALID     (wvalid_pipe     [trgt_rs]    ),
	      .srcWREADY     (wready_pipe     [trgt_rs]    ),
		  
	      .dstWID        (wid_pipe        [trgt_rs+1]  ),
	      .dstWDATA      (wdata_pipe      [trgt_rs+1]  ),
	      .dstWSTRB      (wstrb_pipe      [trgt_rs+1]  ),
	      .dstWLAST      (wlast_pipe      [trgt_rs+1]  ),
	      .dstWUSER      (wuser_pipe      [trgt_rs+1]  ),
	      .dstWVALID     (wvalid_pipe     [trgt_rs+1]  ),
	      .dstWREADY     (wready_pipe     [trgt_rs+1]  ),
		  
	      .dstBID        (bid_pipe        [trgt_rs+1]  ),
	      .dstBRESP      (bresp_pipe      [trgt_rs+1]  ),
	      .dstBUSER      (buser_pipe      [trgt_rs+1]  ),
	      .dstBVALID     (bvalid_pipe     [trgt_rs+1]  ),
	      .dstBREADY     (bready_pipe     [trgt_rs+1]  ),
		  
	      .srcBID        (bid_pipe        [trgt_rs]    ),
	      .srcBRESP      (bresp_pipe      [trgt_rs]    ),
	      .srcBUSER      (buser_pipe      [trgt_rs]    ),
	      .srcBVALID     (bvalid_pipe     [trgt_rs]    ),
	      .srcBREADY     (bready_pipe     [trgt_rs]    )
	    );	
	  end 
	end 
	assign  TARGET_ARID	                      =  arid_pipe     [NUM_RS_STAGES];   
	assign  TARGET_ARADDR	                  =  araddr_pipe   [NUM_RS_STAGES];  
	assign  TARGET_ARLEN	                  =  arlen_pipe    [NUM_RS_STAGES];  
	assign  TARGET_ARSIZE	                  =  arsize_pipe   [NUM_RS_STAGES];  
	assign  TARGET_ARBURST	                  =  arburst_pipe  [NUM_RS_STAGES];  
	assign  TARGET_ARLOCK	                  =  arlock_pipe   [NUM_RS_STAGES];  
	assign  TARGET_ARCACHE	                  =  arcache_pipe  [NUM_RS_STAGES];  
	assign  TARGET_ARPROT	                  =  arprot_pipe   [NUM_RS_STAGES];  
	assign  TARGET_ARREGION                   =  arregion_pipe [NUM_RS_STAGES];  
	assign  TARGET_ARQOS	                  =  arqos_pipe    [NUM_RS_STAGES];  
	assign  TARGET_ARUSER	                  =  aruser_pipe   [NUM_RS_STAGES];  
	assign  TARGET_ARVALID	                  =  arvalid_pipe  [NUM_RS_STAGES];  
	assign  arready_pipe[NUM_RS_STAGES]       =  TARGET_ARREADY               ;  
	assign  rid_pipe    [NUM_RS_STAGES]       =  TARGET_RID	                  ;  
	assign  rdata_pipe  [NUM_RS_STAGES]       =  TARGET_RDATA                 ;  
	assign  rresp_pipe  [NUM_RS_STAGES]       =  TARGET_RRESP                 ;  
	assign  rlast_pipe  [NUM_RS_STAGES]       =  TARGET_RLAST                 ;  
	assign  ruser_pipe  [NUM_RS_STAGES]       =  TARGET_RUSER                 ;  
	assign  rvalid_pipe [NUM_RS_STAGES]       =  TARGET_RVALID                ;  
	assign  TARGET_RREADY                     =  rready_pipe   [NUM_RS_STAGES];  
	assign  TARGET_AWID                       =  awid_pipe     [NUM_RS_STAGES];  
	assign  TARGET_AWADDR                     =  awaddr_pipe   [NUM_RS_STAGES];  
	assign  TARGET_AWLEN	                  =  awlen_pipe    [NUM_RS_STAGES];  
	assign  TARGET_AWSIZE	                  =  awsize_pipe   [NUM_RS_STAGES];  
	assign  TARGET_AWBURST	                  =  awburst_pipe  [NUM_RS_STAGES];  
	assign  TARGET_AWLOCK                     =  awlock_pipe   [NUM_RS_STAGES];  
	assign  TARGET_AWCACHE                    =  awcache_pipe  [NUM_RS_STAGES];  
	assign  TARGET_AWPROT	                  =  awprot_pipe   [NUM_RS_STAGES];  
	assign  TARGET_AWREGION                   =  awregion_pipe [NUM_RS_STAGES];  
	assign  TARGET_AWQOS	                  =  awqos_pipe    [NUM_RS_STAGES];  
	assign  TARGET_AWUSER	                  =  awuser_pipe   [NUM_RS_STAGES];  
	assign  TARGET_AWVALID	                  =  awvalid_pipe  [NUM_RS_STAGES];  
	assign  awready_pipe  [NUM_RS_STAGES]     =  TARGET_AWREADY               ;  
	assign  TARGET_WID                        =  wid_pipe      [NUM_RS_STAGES];  
	assign  TARGET_WDATA                      =  wdata_pipe    [NUM_RS_STAGES];  
	assign  TARGET_WSTRB                      =  wstrb_pipe    [NUM_RS_STAGES];  
	assign  TARGET_WLAST                      =  wlast_pipe    [NUM_RS_STAGES];  
	assign  TARGET_WUSER                      =  wuser_pipe    [NUM_RS_STAGES];  
	assign  TARGET_WVALID                     =  wvalid_pipe   [NUM_RS_STAGES];  
	assign  wready_pipe   [NUM_RS_STAGES]     =  TARGET_WREADY                ;  
	assign  bid_pipe      [NUM_RS_STAGES]     =  TARGET_BID	                  ;  
	assign  bresp_pipe    [NUM_RS_STAGES]     =  TARGET_BRESP                 ;  
	assign  buser_pipe    [NUM_RS_STAGES]     =  TARGET_BUSER                 ;  
	assign  bvalid_pipe   [NUM_RS_STAGES]     =  TARGET_BVALID                ;  
	assign  TARGET_BREADY                     =  bready_pipe  [NUM_RS_STAGES] ;  	
endgenerate 

						
endmodule		// caxi4interconnect_TargetConvertor.v
				
