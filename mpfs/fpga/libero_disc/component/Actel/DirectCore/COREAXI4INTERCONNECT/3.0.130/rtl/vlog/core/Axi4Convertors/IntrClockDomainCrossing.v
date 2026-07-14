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
module caxi4interconnect_IntrClockDomainCrossing #

	(
		parameter integer ADDR_WIDTH      		= 20,
		parameter integer ID_WIDTH 			    = 16, 
		parameter integer INITIATOR_DATA_WIDTH	= 32,
		parameter integer USER_WIDTH 			= 1,
		parameter CLOCK_DOMAIN_CROSSING         = 1'b0,
		parameter CDC_FIFO_DEPTH                = 16,
		parameter CDC_ADDR_RESP_FIFO_DEPTH      = 1,
		parameter INITIATOR_TYPE                = 0,
		parameter READ_INTERLEAVE               = 0,
        parameter PIPE                          = 1,
        parameter CDC_RAM_TYPE                  = 1,
        parameter SYNC_RESET                    = 0,
        parameter NUM_STAGES                    = 2
	)
	(

	//=====================================  Global Signals   ========================================================================
	input  wire           			INITR_CLK,
	input  wire                     XBAR_CLK,
	input  wire          			iarst_sync,
	input  wire          			isrst_sync,
	input  wire          			arst_sync,
	input  wire          			srst_sync,
 
	//=====================================  Connections to/from Crossbar   ==========================================================
 
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
	input wire [INITIATOR_DATA_WIDTH-1:0]		int_initiatorRDATA,
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
	output wire [INITIATOR_DATA_WIDTH-1:0]  		int_initiatorWDATA,
	output wire [(INITIATOR_DATA_WIDTH/8)-1:0]	int_initiatorWSTRB,
	output wire                  		int_initiatorWLAST,
	output wire [USER_WIDTH-1:0] 		int_initiatorWUSER,
	output wire                  		int_initiatorWVALID,
	input wire                   		int_initiatorWREADY,
			
	// Initiator Write Response Ports	
	input  wire [ID_WIDTH-1:0]		int_initiatorBID,
	input  wire [1:0]           	int_initiatorBRESP,
	input  wire [USER_WIDTH-1:0] 	int_initiatorBUSER,
	input  wire      				int_initiatorBVALID,
	output wire						int_initiatorBREADY,

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

    localparam integer ADDR_CHAN_WIDTH = ID_WIDTH + ADDR_WIDTH + 8 + 3 + 2 + 2 + 4 + 3 + 4 + 4 + USER_WIDTH;
	//For AXI3 Initiator stored WID in the fifo. 
	localparam integer WCHAN_WIDTH = (INITIATOR_TYPE == 2'b11) ? INITIATOR_DATA_WIDTH + INITIATOR_DATA_WIDTH/8 + 1 + USER_WIDTH + ID_WIDTH: 
	                                                          INITIATOR_DATA_WIDTH + INITIATOR_DATA_WIDTH/8 + 1 + USER_WIDTH;
	localparam integer BCHAN_WIDTH = ID_WIDTH + 2 + USER_WIDTH;
	localparam integer RCHAN_WIDTH = ID_WIDTH + INITIATOR_DATA_WIDTH + 2 + 1 + USER_WIDTH;

	
	wire       cfifo_irst; //Initiator reset
	wire       cfifo_arst; //Crossbar reset
	
	assign     cfifo_irst = (SYNC_RESET == 0) ? iarst_sync : isrst_sync;
	assign     cfifo_arst = (SYNC_RESET == 0) ? arst_sync  : srst_sync;
		

    generate
         if (CLOCK_DOMAIN_CROSSING) begin
		   if(PIPE > 0) begin 
                caxi4c_coreaxi4s_fifo #
                (
                   .RESET_TYPE         (SYNC_RESET),//
                   .SYNC               (0),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
                   .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
                   .ECC                (0),// 0: ECC disable , 1: ECC enable
                   .RAM_TYPE           (CDC_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
                   .NUM_STAGES         (NUM_STAGES),// To select number of synchronizer stages.
                   .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
                   .WFIFO_DEPTH        (CDC_ADDR_RESP_FIFO_DEPTH),
                   .RFIFO_DEPTH        (CDC_ADDR_RESP_FIFO_DEPTH),
                   .AXIS_TTDATA_WIDTH  (ADDR_CHAN_WIDTH), // Bytes
                   .AXIS_ITDATA_WIDTH  (ADDR_CHAN_WIDTH),  // Bytes
                   .AXIS_TTID_WIDTH    (1), // Bits
                   .AXIS_ITID_WIDTH    (1), // Bits
                   .AXIS_TTDEST_WIDTH  (1), // Bits
                   .AXIS_ITDEST_WIDTH  (1), // Bits
                   .AXIS_TTUSER_WIDTH  (1), // Bits
                   .AXIS_ITUSER_WIDTH  (1), // Bits
                   .ENABLE_AFULL       (0),
                   .AFULL_THR          (2),
                   .ENABLE_TSTRB       (0),
                   .ENABLE_TKEEP       (0),
                   .ENABLE_TLAST       (0),
                   .ENABLE_TUSER       (0),
                   .ENABLE_TDEST       (0),
                   .ENABLE_TID         (0),
                   .EOP_OFFSET         (0)
                ) cdc_fwftAWChan
                (
                   .AXI4S_ACLK         (INITR_CLK),
                   .AXI4S_IACLK        (XBAR_CLK),
                   .AXI4S_TACLK        (INITR_CLK),
                   .AXI4S_ARESETN      (cfifo_irst),
                   .AXI4S_IARESETN     (cfifo_arst),
                   .AXI4S_TARESETN     (cfifo_irst),
                   .AXI4S_ITREADY      (int_initiatorAWREADY),
                   .AXI4S_ITVALID      (int_initiatorAWVALID),
                   .AXI4S_ITDATA       ({int_initiatorAWID, int_initiatorAWADDR, int_initiatorAWLEN, int_initiatorAWSIZE, int_initiatorAWBURST, int_initiatorAWLOCK, int_initiatorAWCACHE,  int_initiatorAWPROT, int_initiatorAWQOS, int_initiatorAWREGION, int_initiatorAWUSER}),
                   .AXI4S_TTVALID      (INITIATOR_AWVALID),
                   .AXI4S_TTDATA       ({INITIATOR_AWID, INITIATOR_AWADDR, INITIATOR_AWLEN, INITIATOR_AWSIZE, INITIATOR_AWBURST, INITIATOR_AWLOCK, INITIATOR_AWCACHE,  INITIATOR_AWPROT, INITIATOR_ARQOS, INITIATOR_AWREGION, INITIATOR_AWUSER}),
                   .AXI4S_TTREADY      (INITIATOR_AWREADY)
                );
		      if(INITIATOR_TYPE == 2'b11) begin    //AXI3 
                caxi4c_coreaxi4s_fifo #
                (
                   .RESET_TYPE         (SYNC_RESET),//
                   .SYNC               (0),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
                   .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
                   .ECC                (0),// 0: ECC disable , 1: ECC enable
                   .RAM_TYPE           (CDC_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
                   .NUM_STAGES         (NUM_STAGES),// To select number of synchronizer stages.
                   .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
                   .WFIFO_DEPTH        (CDC_FIFO_DEPTH),
                   .RFIFO_DEPTH        (CDC_FIFO_DEPTH),
                   .AXIS_TTDATA_WIDTH  (WCHAN_WIDTH), // Bytes
                   .AXIS_ITDATA_WIDTH  (WCHAN_WIDTH),  // Bytes
                   .AXIS_TTID_WIDTH    (1), // Bits
                   .AXIS_ITID_WIDTH    (1), // Bits
                   .AXIS_TTDEST_WIDTH  (1), // Bits
                   .AXIS_ITDEST_WIDTH  (1), // Bits
                   .AXIS_TTUSER_WIDTH  (1), // Bits
                   .AXIS_ITUSER_WIDTH  (1), // Bits
                   .ENABLE_AFULL       (0),
                   .AFULL_THR          (2),
                   .ENABLE_TSTRB       (0),
                   .ENABLE_TKEEP       (0),
                   .ENABLE_TLAST       (0),
                   .ENABLE_TUSER       (0),
                   .ENABLE_TDEST       (0),
                   .ENABLE_TID         (0),
                   .EOP_OFFSET         (0)
                ) cdc_fwftWChan
                (
                   .AXI4S_ACLK         (INITR_CLK),
                   .AXI4S_IACLK        (XBAR_CLK),
                   .AXI4S_TACLK        (INITR_CLK),
                   .AXI4S_ARESETN      (cfifo_irst),
                   .AXI4S_IARESETN     (cfifo_arst),
                   .AXI4S_TARESETN     (cfifo_irst),
                   .AXI4S_ITREADY      (int_initiatorWREADY),
                   .AXI4S_ITVALID      (int_initiatorWVALID),
                   .AXI4S_ITDATA       ({int_initiatorWID,int_initiatorWDATA, int_initiatorWSTRB, int_initiatorWLAST, int_initiatorWUSER}),
                   .AXI4S_TTVALID      (INITIATOR_WVALID),
                   .AXI4S_TTDATA       ({INITIATOR_WID,INITIATOR_WDATA, INITIATOR_WSTRB, INITIATOR_WLAST, INITIATOR_WUSER}),
                   .AXI4S_TTREADY      (INITIATOR_WREADY)
                );
			  end else begin 
			    assign int_initiatorWID   = 0;
                caxi4c_coreaxi4s_fifo #
                (
                   .RESET_TYPE         (SYNC_RESET),//
                   .SYNC               (0),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
                   .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
                   .ECC                (0),// 0: ECC disable , 1: ECC enable
                   .RAM_TYPE           (CDC_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
                   .NUM_STAGES         (NUM_STAGES),// To select number of synchronizer stages.
                   .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
                   .WFIFO_DEPTH        (CDC_FIFO_DEPTH),
                   .RFIFO_DEPTH        (CDC_FIFO_DEPTH),
                   .AXIS_TTDATA_WIDTH  (WCHAN_WIDTH), // Bytes
                   .AXIS_ITDATA_WIDTH  (WCHAN_WIDTH),  // Bytes
                   .AXIS_TTID_WIDTH    (1), // Bits
                   .AXIS_ITID_WIDTH    (1), // Bits
                   .AXIS_TTDEST_WIDTH  (1), // Bits
                   .AXIS_ITDEST_WIDTH  (1), // Bits
                   .AXIS_TTUSER_WIDTH  (1), // Bits
                   .AXIS_ITUSER_WIDTH  (1), // Bits
                   .ENABLE_AFULL       (0),
                   .AFULL_THR          (2),
                   .ENABLE_TSTRB       (0),
                   .ENABLE_TKEEP       (0),
                   .ENABLE_TLAST       (0),
                   .ENABLE_TUSER       (0),
                   .ENABLE_TDEST       (0),
                   .ENABLE_TID         (0),
                   .EOP_OFFSET         (0)
                ) cdc_fwftWChan
                (
                   .AXI4S_ACLK         (INITR_CLK),
                   .AXI4S_IACLK        (XBAR_CLK),
                   .AXI4S_TACLK        (INITR_CLK),
                   .AXI4S_ARESETN      (cfifo_irst),
                   .AXI4S_IARESETN     (cfifo_arst),
                   .AXI4S_TARESETN     (cfifo_irst),
                   .AXI4S_ITREADY      (int_initiatorWREADY),
                   .AXI4S_ITVALID      (int_initiatorWVALID),
                   .AXI4S_ITDATA       ({int_initiatorWDATA, int_initiatorWSTRB, int_initiatorWLAST, int_initiatorWUSER}),
                   .AXI4S_TTVALID      (INITIATOR_WVALID),
                   .AXI4S_TTDATA       ({INITIATOR_WDATA, INITIATOR_WSTRB, INITIATOR_WLAST, INITIATOR_WUSER}),
                   .AXI4S_TTREADY      (INITIATOR_WREADY)
				);
			  end 

              caxi4c_coreaxi4s_fifo #
              (
                 .RESET_TYPE         (SYNC_RESET),//
                 .SYNC               (0),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
                 .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
                 .ECC                (0),// 0: ECC disable , 1: ECC enable
                 .RAM_TYPE           (CDC_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
                 .NUM_STAGES         (NUM_STAGES),// To select number of synchronizer stages.
                 .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
                 .WFIFO_DEPTH        (CDC_ADDR_RESP_FIFO_DEPTH),
                 .RFIFO_DEPTH        (CDC_ADDR_RESP_FIFO_DEPTH),
                 .AXIS_TTDATA_WIDTH  (ADDR_CHAN_WIDTH), // Bytes
                 .AXIS_ITDATA_WIDTH  (ADDR_CHAN_WIDTH),  // Bytes
                 .AXIS_TTID_WIDTH    (1), // Bits
                 .AXIS_ITID_WIDTH    (1), // Bits
                 .AXIS_TTDEST_WIDTH  (1), // Bits
                 .AXIS_ITDEST_WIDTH  (1), // Bits
                 .AXIS_TTUSER_WIDTH  (1), // Bits
                 .AXIS_ITUSER_WIDTH  (1), // Bits
                 .ENABLE_AFULL       (0),
                 .AFULL_THR          (2),
                 .ENABLE_TSTRB       (0),
                 .ENABLE_TKEEP       (0),
                 .ENABLE_TLAST       (0),
                 .ENABLE_TUSER       (0),
                 .ENABLE_TDEST       (0),
                 .ENABLE_TID         (0),
                 .EOP_OFFSET         (0)
              ) cdc_fwftARChan
              (
                 .AXI4S_ACLK         (INITR_CLK),
                 .AXI4S_IACLK        (XBAR_CLK),
                 .AXI4S_TACLK        (INITR_CLK),
                 .AXI4S_ARESETN      (cfifo_irst),
                 .AXI4S_IARESETN     (cfifo_arst),
                 .AXI4S_TARESETN     (cfifo_irst),
                 .AXI4S_ITREADY      (int_initiatorARREADY),
                 .AXI4S_ITVALID      (int_initiatorARVALID),
                 .AXI4S_ITDATA       ({int_initiatorARID, int_initiatorARADDR, int_initiatorARLEN, int_initiatorARSIZE, int_initiatorARBURST, int_initiatorARLOCK, int_initiatorARCACHE,  int_initiatorARPROT, int_initiatorARQOS, int_initiatorARREGION, int_initiatorARUSER}),
                 .AXI4S_TTVALID      (INITIATOR_ARVALID),
                 .AXI4S_TTDATA       ({INITIATOR_ARID, INITIATOR_ARADDR, INITIATOR_ARLEN, INITIATOR_ARSIZE, INITIATOR_ARBURST, INITIATOR_ARLOCK, INITIATOR_ARCACHE,  INITIATOR_ARPROT, INITIATOR_ARQOS, INITIATOR_ARREGION, INITIATOR_ARUSER}),
                 .AXI4S_TTREADY      (INITIATOR_ARREADY)
              );
			  
              caxi4c_coreaxi4s_fifo #
              (
                 .RESET_TYPE         (SYNC_RESET),//
                 .SYNC               (0),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
                 .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
                 .ECC                (0),// 0: ECC disable , 1: ECC enable
                 .RAM_TYPE           (CDC_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
                 .NUM_STAGES         (NUM_STAGES),// To select number of synchronizer stages.
                 .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
                 .WFIFO_DEPTH        (CDC_FIFO_DEPTH),
                 .RFIFO_DEPTH        (CDC_FIFO_DEPTH),
                 .AXIS_TTDATA_WIDTH  (RCHAN_WIDTH), // Bytes
                 .AXIS_ITDATA_WIDTH  (RCHAN_WIDTH),  // Bytes
                 .AXIS_TTID_WIDTH    (1), // Bits
                 .AXIS_ITID_WIDTH    (1), // Bits
                 .AXIS_TTDEST_WIDTH  (1), // Bits
                 .AXIS_ITDEST_WIDTH  (1), // Bits
                 .AXIS_TTUSER_WIDTH  (1), // Bits
                 .AXIS_ITUSER_WIDTH  (1), // Bits
                 .ENABLE_AFULL       (0),
                 .AFULL_THR          (2),
                 .ENABLE_TSTRB       (0),
                 .ENABLE_TKEEP       (0),
                 .ENABLE_TLAST       (0),
                 .ENABLE_TUSER       (0),
                 .ENABLE_TDEST       (0),
                 .ENABLE_TID         (0),
                 .EOP_OFFSET         (0)
              ) cdc_fwftRChan
              (
                 .AXI4S_ACLK         (INITR_CLK),
                 .AXI4S_IACLK        (INITR_CLK ),
                 .AXI4S_TACLK        (XBAR_CLK),
                 .AXI4S_ARESETN      (cfifo_irst),
                 .AXI4S_IARESETN     (cfifo_irst),
                 .AXI4S_TARESETN     (cfifo_arst ),
                 .AXI4S_ITREADY      (INITIATOR_RREADY),
                 .AXI4S_ITVALID      (INITIATOR_RVALID),
                 .AXI4S_ITDATA       ({INITIATOR_RID, INITIATOR_RDATA, INITIATOR_RRESP, INITIATOR_RLAST, INITIATOR_RUSER}),
                 .AXI4S_TTVALID      (int_initiatorRVALID),
                 .AXI4S_TTDATA       ({int_initiatorRID, int_initiatorRDATA, int_initiatorRRESP, int_initiatorRLAST, int_initiatorRUSER}),
                 .AXI4S_TTREADY      (int_initiatorRREADY)
              );	

              caxi4c_coreaxi4s_fifo #
              (
                 .RESET_TYPE         (SYNC_RESET),//
                 .SYNC               (0),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
                 .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
                 .ECC                (0),// 0: ECC disable , 1: ECC enable
                 .RAM_TYPE           (CDC_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
                 .NUM_STAGES         (NUM_STAGES),// To select number of synchronizer stages.
                 .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
                 .WFIFO_DEPTH        (CDC_ADDR_RESP_FIFO_DEPTH),
                 .RFIFO_DEPTH        (CDC_ADDR_RESP_FIFO_DEPTH),
                 .AXIS_TTDATA_WIDTH  (BCHAN_WIDTH), // Bytes
                 .AXIS_ITDATA_WIDTH  (BCHAN_WIDTH),  // Bytes
                 .AXIS_TTID_WIDTH    (1), // Bits
                 .AXIS_ITID_WIDTH    (1), // Bits
                 .AXIS_TTDEST_WIDTH  (1), // Bits
                 .AXIS_ITDEST_WIDTH  (1), // Bits
                 .AXIS_TTUSER_WIDTH  (1), // Bits
                 .AXIS_ITUSER_WIDTH  (1), // Bits
                 .ENABLE_AFULL       (0),
                 .AFULL_THR          (2),
                 .ENABLE_TSTRB       (0),
                 .ENABLE_TKEEP       (0),
                 .ENABLE_TLAST       (0),
                 .ENABLE_TUSER       (0),
                 .ENABLE_TDEST       (0),
                 .ENABLE_TID         (0),
                 .EOP_OFFSET         (0)
              ) cdc_fwftBChan
              (
                 .AXI4S_ACLK         (INITR_CLK),
                 .AXI4S_IACLK        (INITR_CLK ),
                 .AXI4S_TACLK        (XBAR_CLK),
                 .AXI4S_ARESETN      (cfifo_irst),
                 .AXI4S_IARESETN     (cfifo_irst),
                 .AXI4S_TARESETN     (cfifo_arst ),
                 .AXI4S_ITREADY      (INITIATOR_BREADY),
                 .AXI4S_ITVALID      (INITIATOR_BVALID),
                 .AXI4S_ITDATA       ({INITIATOR_BID, INITIATOR_BRESP, INITIATOR_BUSER}),
                 .AXI4S_TTVALID      (int_initiatorBVALID),
                 .AXI4S_TTDATA       ({int_initiatorBID, int_initiatorBRESP, int_initiatorBUSER}),
                 .AXI4S_TTREADY      (int_initiatorBREADY)
              );				  
		   end else begin 
             caxi4interconnect_CDC_FIFO #
	           (
                 .MEM_DEPTH       (CDC_ADDR_RESP_FIFO_DEPTH ),
                 .DATA_WIDTH      (ADDR_CHAN_WIDTH          ),
				 .INITIATOR_BCHAN (0                        ),
				 .NUM_SYNC_STAGES (NUM_STAGES               ),
				 .RESET_TYPE      (SYNC_RESET               )
               ) cdc_AWChan
               (
    	         .arst (iarst_sync),
				 .srst (isrst_sync),
    	         .rdclk_arst (arst_sync),
    	         .rdclk_srst (srst_sync),
                 .clk_wr (INITR_CLK),
                 .clk_rd (XBAR_CLK),

                 .infoInValid (INITIATOR_AWVALID),
                 .readyForOut (int_initiatorAWREADY),

                 .infoIn ({INITIATOR_AWID, INITIATOR_AWADDR, INITIATOR_AWLEN, INITIATOR_AWSIZE, INITIATOR_AWBURST, INITIATOR_AWLOCK, INITIATOR_AWCACHE,  INITIATOR_AWPROT, INITIATOR_ARQOS, INITIATOR_AWREGION, INITIATOR_AWUSER}),

                 .infoOut ({int_initiatorAWID, int_initiatorAWADDR, int_initiatorAWLEN, int_initiatorAWSIZE, int_initiatorAWBURST, int_initiatorAWLOCK, int_initiatorAWCACHE,  int_initiatorAWPROT, int_initiatorAWQOS, int_initiatorAWREGION, int_initiatorAWUSER}),
                 .readyForInfo (INITIATOR_AWREADY),
                 .infoOutValid (int_initiatorAWVALID)
			   );

           if(INITIATOR_TYPE == 2'b11)         //AXI3
		     begin 
	           caxi4interconnect_CDC_FIFO #
	           (
                 .MEM_DEPTH (CDC_FIFO_DEPTH),
                 .DATA_WIDTH  ( WCHAN_WIDTH ),
				 .INITIATOR_BCHAN (0),
				 .NUM_SYNC_STAGES (NUM_STAGES               ),
				 .RESET_TYPE      (SYNC_RESET               )
               )
	           cdc_WChan
               (
    	         .arst (iarst_sync),
				 .srst (isrst_sync),
    	         .rdclk_arst (arst_sync),
				 .rdclk_srst (srst_sync),
                 .clk_wr (INITR_CLK),
                 .clk_rd (XBAR_CLK),

                 .infoInValid (INITIATOR_WVALID),
                 .readyForOut (int_initiatorWREADY),

                 .infoIn ({INITIATOR_WID,INITIATOR_WDATA, INITIATOR_WSTRB, INITIATOR_WLAST, INITIATOR_WUSER}),

                 .infoOut ({int_initiatorWID,int_initiatorWDATA, int_initiatorWSTRB, int_initiatorWLAST, int_initiatorWUSER}),
                 .readyForInfo (INITIATOR_WREADY),
                 .infoOutValid (int_initiatorWVALID)
		       );
			 end 
		   else 
		     begin 
			 
			   assign int_initiatorWID   = 0;
			   
	           caxi4interconnect_CDC_FIFO #
	           (
                 .MEM_DEPTH (CDC_FIFO_DEPTH),
                 .DATA_WIDTH  ( WCHAN_WIDTH ),
				 .INITIATOR_BCHAN (0),
				 .NUM_SYNC_STAGES (NUM_STAGES               ),
				 .RESET_TYPE      (SYNC_RESET               )
               )
	           cdc_WChan
               (
    	         .arst (iarst_sync),
				 .srst (isrst_sync),
    	         .rdclk_arst (arst_sync),
				 .rdclk_srst (srst_sync),
                 .clk_wr (INITR_CLK),
                 .clk_rd (XBAR_CLK),

                 .infoInValid (INITIATOR_WVALID),
                 .readyForOut (int_initiatorWREADY),

                 .infoIn ({INITIATOR_WDATA, INITIATOR_WSTRB, INITIATOR_WLAST, INITIATOR_WUSER}),

                 .infoOut ({int_initiatorWDATA, int_initiatorWSTRB, int_initiatorWLAST, int_initiatorWUSER}),
                 .readyForInfo (INITIATOR_WREADY),
                 .infoOutValid (int_initiatorWVALID)
		       );
			 end 

            caxi4interconnect_CDC_FIFO #
	       (
                 .MEM_DEPTH (CDC_ADDR_RESP_FIFO_DEPTH),
                 .DATA_WIDTH  ( ADDR_CHAN_WIDTH ),
				 .INITIATOR_BCHAN (0),
				 .NUM_SYNC_STAGES (NUM_STAGES               ),
				 .RESET_TYPE      (SYNC_RESET               )
               )
	       cdc_ARChan
               (
    	         .arst (iarst_sync),
				 .srst (isrst_sync),
    	         .rdclk_arst (arst_sync),
				 .rdclk_srst (srst_sync),
                 .clk_wr (INITR_CLK),
                 .clk_rd (XBAR_CLK),

                 .infoInValid (INITIATOR_ARVALID),
                 .readyForOut (int_initiatorARREADY),

                 .infoIn ({INITIATOR_ARID, INITIATOR_ARADDR, INITIATOR_ARLEN, INITIATOR_ARSIZE, INITIATOR_ARBURST, INITIATOR_ARLOCK, INITIATOR_ARCACHE,  INITIATOR_ARPROT, INITIATOR_ARQOS, INITIATOR_ARREGION, INITIATOR_ARUSER}),

                 .infoOut ({int_initiatorARID, int_initiatorARADDR, int_initiatorARLEN, int_initiatorARSIZE, int_initiatorARBURST, int_initiatorARLOCK, int_initiatorARCACHE,  int_initiatorARPROT, int_initiatorARQOS, int_initiatorARREGION, int_initiatorARUSER}),
                 .readyForInfo (INITIATOR_ARREADY),
                 .infoOutValid (int_initiatorARVALID)
		);

	       caxi4interconnect_CDC_FIFO #
	       (
                 .MEM_DEPTH   (CDC_FIFO_DEPTH),
                 .DATA_WIDTH  ( RCHAN_WIDTH ),
				 .INITIATOR_BCHAN (0),
				 .NUM_SYNC_STAGES (NUM_STAGES               ),
				 .RESET_TYPE      (SYNC_RESET               )
               )
	       cdc_RChan
               (
    	         .arst (arst_sync),
				 .srst (srst_sync),
    	         .rdclk_arst (iarst_sync),
				 .rdclk_srst (isrst_sync),
                 .clk_rd (INITR_CLK),
                 .clk_wr (XBAR_CLK),

                 .infoInValid (int_initiatorRVALID),
                 .readyForOut (INITIATOR_RREADY),

                 .infoOut ({INITIATOR_RID, INITIATOR_RDATA, INITIATOR_RRESP, INITIATOR_RLAST, INITIATOR_RUSER}),

                 .infoIn ({int_initiatorRID, int_initiatorRDATA, int_initiatorRRESP, int_initiatorRLAST, int_initiatorRUSER}),
                 .readyForInfo (int_initiatorRREADY),
                 .infoOutValid (INITIATOR_RVALID)
		);

	       caxi4interconnect_CDC_FIFO #
	       (
                 .MEM_DEPTH (CDC_ADDR_RESP_FIFO_DEPTH),
                 .DATA_WIDTH  ( BCHAN_WIDTH ),
				 .INITIATOR_BCHAN (1),
				 .NUM_SYNC_STAGES (NUM_STAGES               ),
				 .RESET_TYPE      (SYNC_RESET               )
               )
	       cdc_BChan
               (
    	         .arst (arst_sync),
    	         .srst (srst_sync),
    	         .rdclk_arst (iarst_sync),
				 .rdclk_srst (isrst_sync),
                 .clk_rd (INITR_CLK),
                 .clk_wr (XBAR_CLK),

                 .infoInValid (int_initiatorBVALID),
                 .readyForOut (INITIATOR_BREADY),

                 .infoOut ({INITIATOR_BID, INITIATOR_BRESP, INITIATOR_BUSER}),

                 .infoIn ({int_initiatorBID, int_initiatorBRESP, int_initiatorBUSER}),
                 .readyForInfo (int_initiatorBREADY),
                 .infoOutValid (INITIATOR_BVALID)
		       );
		end 
	end
	else begin
		//====================================== ASSIGNEMENTS =================================================
		//from Initiator to crossbar & Target
		  assign int_initiatorAWID =	INITIATOR_AWID;
		  assign int_initiatorAWADDR = INITIATOR_AWADDR;
		  assign int_initiatorAWLEN = INITIATOR_AWLEN;
		  assign int_initiatorAWSIZE = INITIATOR_AWSIZE;
		  assign int_initiatorAWBURST = INITIATOR_AWBURST;	
		  assign int_initiatorAWLOCK = INITIATOR_AWLOCK;
		  assign int_initiatorAWCACHE = INITIATOR_AWCACHE;	
		  assign int_initiatorAWPROT = INITIATOR_AWPROT;
		  assign int_initiatorAWREGION = INITIATOR_AWREGION;
		  assign int_initiatorAWQOS = INITIATOR_AWQOS;
		  assign int_initiatorAWUSER = INITIATOR_AWUSER;
		  assign int_initiatorAWVALID = INITIATOR_AWVALID;	
		  assign int_initiatorWID   = INITIATOR_WID;
		  assign int_initiatorWDATA = INITIATOR_WDATA;
		  assign int_initiatorWSTRB = INITIATOR_WSTRB;
		  assign int_initiatorWLAST = INITIATOR_WLAST;
		  assign int_initiatorWUSER = INITIATOR_WUSER;
		  assign int_initiatorWVALID = INITIATOR_WVALID;
		  assign int_initiatorBREADY = INITIATOR_BREADY;
		  assign int_initiatorARID = INITIATOR_ARID;
		  assign int_initiatorARADDR = INITIATOR_ARADDR;
		  assign int_initiatorARLEN = INITIATOR_ARLEN;
		  assign int_initiatorARSIZE = INITIATOR_ARSIZE;
		  assign int_initiatorARBURST = INITIATOR_ARBURST;	
		  assign int_initiatorARLOCK = INITIATOR_ARLOCK;
		  assign int_initiatorARCACHE = INITIATOR_ARCACHE;	
		  assign int_initiatorARPROT = INITIATOR_ARPROT;
		  assign int_initiatorARREGION = INITIATOR_ARREGION;
		  assign int_initiatorARQOS = INITIATOR_ARQOS;
		  assign int_initiatorARUSER = INITIATOR_ARUSER;
		  assign int_initiatorARVALID = INITIATOR_ARVALID;	
		  assign int_initiatorRREADY = INITIATOR_RREADY;
		  //			
		  //from crossbar to INITIATOR
		  assign INITIATOR_AWREADY = int_initiatorAWREADY;	
		  assign INITIATOR_WREADY = int_initiatorWREADY;
		  assign INITIATOR_BID = int_initiatorBID;
		  assign INITIATOR_BRESP =	int_initiatorBRESP;
		  assign INITIATOR_BUSER =	int_initiatorBUSER;
		  assign INITIATOR_BVALID = int_initiatorBVALID;	
		  assign INITIATOR_ARREADY = int_initiatorARREADY;	
		  			
		  assign INITIATOR_RID = int_initiatorRID;
		  assign INITIATOR_RDATA =	int_initiatorRDATA;
		  assign INITIATOR_RRESP =	int_initiatorRRESP;
		  assign INITIATOR_RLAST =	int_initiatorRLAST;
		  assign INITIATOR_RUSER =	int_initiatorRUSER;
		  assign INITIATOR_RVALID = int_initiatorRVALID;
	  end
	endgenerate
endmodule	
