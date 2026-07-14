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
// SVN $Revision: 46137 $
// SVN $Date: 2024-02-23 01:29:51 +0530 (Fri, 23 Feb 2024) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns
module caxi4interconnect_TrgtClockDomainCrossing #

	(
		parameter integer ADDR_WIDTH      		 = 20,
		parameter integer ID_WIDTH 			     = 1, 
		parameter integer TARGET_DATA_WIDTH		 = 32,
		parameter integer USER_WIDTH 			 = 1,
	    parameter CLOCK_DOMAIN_CROSSING          = 1'b0,
	    parameter CDC_FIFO_DEPTH                 = 16,
	    parameter CDC_ADDR_RESP_FIFO_DEPTH       = 16,
		parameter TARGET_TYPE                    = 0,
		parameter READ_INTERLEAVE                = 0,
	    parameter PIPE                           = 1,
	    parameter CDC_RAM_TYPE                   = 3,
        parameter SYNC_RESET                     = 0,
        parameter NUM_STAGES                     = 2
	)
	(

	//=====================================  Global Signals   ========================================================================
	input  wire           			TRGT_CLK,
	input  wire                     XBAR_CLK,
	input  wire          			tarst_sync,
	input  wire          			tsrst_sync,
	input  wire          			arst_sync,
	input  wire          			srst_sync,
 
	//=====================================  Connections to/from Crossbar   ==========================================================
 
	output wire [ID_WIDTH-1:0] 		targetARID,
	output wire [ADDR_WIDTH-1:0]	targetARADDR,
	output wire [7:0]        		targetARLEN,
	output wire [2:0]          		targetARSIZE,
	output wire [1:0]          		targetARBURST,
	output wire [1:0]          		targetARLOCK,
	output wire [3:0]           	targetARCACHE,
	output wire [2:0]         		targetARPROT,
	output wire [3:0]          		targetARREGION,
	output wire [3:0]          		targetARQOS,
	output wire [USER_WIDTH-1:0]	targetARUSER,
	output wire            			targetARVALID,
	input wire             			targetARREADY,

	// Initiator Read Data Ports	
	input wire [ID_WIDTH-1:0]   	targetRID,
	input wire [TARGET_DATA_WIDTH-1:0]		targetRDATA,
	input wire [1:0]           		targetRRESP,
	input wire                		targetRLAST,
	input wire [USER_WIDTH-1:0] 	targetRUSER,
	input wire                 		targetRVALID,
	output wire               		targetRREADY,

	// Initiator Write Address Ports	
	output wire [ID_WIDTH-1:0]  	targetAWID,
	output wire [ADDR_WIDTH-1:0] 	targetAWADDR,
	output wire [7:0]           	targetAWLEN,
	output wire [2:0]           	targetAWSIZE,
	output wire [1:0]           	targetAWBURST,
	output wire [1:0]           	targetAWLOCK,
	output wire [3:0]          		targetAWCACHE,
	output wire [2:0]           	targetAWPROT,
	output wire [3:0]            	targetAWREGION,
	output wire [3:0]           	targetAWQOS,
	output wire [USER_WIDTH-1:0]   	targetAWUSER,
	output wire                 	targetAWVALID,
	input wire                		targetAWREADY,
	
	// Initiator Write Data Ports	
	output wire [ID_WIDTH-1:0]  		    targetWID,
	output wire [TARGET_DATA_WIDTH-1:0]      targetWDATA,
	output wire [(TARGET_DATA_WIDTH/8)-1:0]	targetWSTRB,
	output wire                  		targetWLAST,
	output wire [USER_WIDTH-1:0] 		targetWUSER,
	output wire                  		targetWVALID,
	input wire                   		targetWREADY,
			
	// Initiator Write Response Ports	
	input  wire [ID_WIDTH-1:0]		targetBID,
	input  wire [1:0]           	targetBRESP,
	input  wire [USER_WIDTH-1:0] 	targetBUSER,
	input  wire      				targetBVALID,
	output wire						targetBREADY,

	//================================================= External Side Ports  ================================================//

	// Initiator Read Address Ports	
	input  wire [ID_WIDTH-1:0]  	TARGET_ARID,
	input  wire [ADDR_WIDTH-1:0]	TARGET_ARADDR,
	input  wire [7:0]           	TARGET_ARLEN,
	input  wire [2:0]        		TARGET_ARSIZE,
	input  wire [1:0]           	TARGET_ARBURST,
	input  wire [1:0]         		TARGET_ARLOCK,
	input  wire [3:0]          		TARGET_ARCACHE,
	input  wire [2:0]         		TARGET_ARPROT,
	input  wire [3:0]          		TARGET_ARREGION,
	input  wire [3:0]          		TARGET_ARQOS,
	input  wire [USER_WIDTH-1:0]	TARGET_ARUSER,
	input  wire                		TARGET_ARVALID,
	output wire                		TARGET_ARREADY,
	
	// Initiator Read Data Ports	
	output wire [ID_WIDTH-1:0]  	TARGET_RID,
	output wire [TARGET_DATA_WIDTH-1:0]  	TARGET_RDATA,
	output wire [1:0]           	TARGET_RRESP,
	output wire                  	TARGET_RLAST,
	output wire [USER_WIDTH-1:0] 	TARGET_RUSER,
	output wire               		TARGET_RVALID,
	input wire                 		TARGET_RREADY,
	
	// Initiator Write Address Ports	
	input  wire [ID_WIDTH-1:0]   	TARGET_AWID,
	input  wire [ADDR_WIDTH-1:0] 	TARGET_AWADDR,
	input  wire [7:0]           	TARGET_AWLEN,
	input  wire [2:0]           	TARGET_AWSIZE,
	input  wire [1:0]           	TARGET_AWBURST,
	input  wire [1:0]            	TARGET_AWLOCK,
	input  wire [3:0]          		TARGET_AWCACHE,
	input  wire [2:0]           	TARGET_AWPROT,
	input  wire [3:0]           	TARGET_AWREGION,
	input  wire [3:0]           	TARGET_AWQOS,
	input  wire [USER_WIDTH-1:0] 	TARGET_AWUSER,
	input  wire                  	TARGET_AWVALID,
	output wire                		TARGET_AWREADY,
	
	// Initiator Write Data Ports	
	input wire [ID_WIDTH-1:0]   	      TARGET_WID,
	input wire [TARGET_DATA_WIDTH-1:0]     TARGET_WDATA,
	input wire [(TARGET_DATA_WIDTH/8)-1:0] TARGET_WSTRB,
	input wire                   	TARGET_WLAST,
	input wire [USER_WIDTH-1:0] 	TARGET_WUSER,
	input wire                  	TARGET_WVALID,
	output wire                  	TARGET_WREADY,
	
	// Initiator Write Response Ports	
	output wire [ID_WIDTH-1:0]		TARGET_BID,
	output wire [1:0]           	TARGET_BRESP,
	output wire [USER_WIDTH-1:0]  	TARGET_BUSER,
	output wire      				TARGET_BVALID,
	input wire						TARGET_BREADY
	) ;

    localparam ADDR_CHAN_WIDTH = ID_WIDTH + ADDR_WIDTH + 8 + 3 + 2 + 2 + 4 + 3 + 4 + 4 + USER_WIDTH;
	localparam WCHAN_WIDTH = (TARGET_TYPE == 2'b11) ? TARGET_DATA_WIDTH + TARGET_DATA_WIDTH/8 + 1 + USER_WIDTH + ID_WIDTH: 
	                                                 TARGET_DATA_WIDTH + TARGET_DATA_WIDTH/8 + 1 + USER_WIDTH;
	localparam BCHAN_WIDTH = ID_WIDTH + 2 + USER_WIDTH;
	localparam RCHAN_WIDTH = ID_WIDTH + TARGET_DATA_WIDTH + 2 + 1 + USER_WIDTH;
	
	wire       cfifo_trst; //Target reset
	wire       cfifo_arst; //Crossbar reset
	
	assign     cfifo_trst = (SYNC_RESET == 0) ? tarst_sync : tsrst_sync;
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
                   .AXI4S_ACLK         (TRGT_CLK),
                   .AXI4S_IACLK        (TRGT_CLK),
                   .AXI4S_TACLK        (XBAR_CLK ),
                   .AXI4S_ARESETN      (cfifo_trst),
                   .AXI4S_IARESETN     (cfifo_trst),
                   .AXI4S_TARESETN     (cfifo_arst ),
                   .AXI4S_ITREADY      (targetAWREADY),
                   .AXI4S_ITVALID      (targetAWVALID),
                   .AXI4S_ITDATA       ({targetAWID, targetAWADDR, targetAWLEN, targetAWSIZE, targetAWBURST, targetAWLOCK, targetAWCACHE,  targetAWPROT, targetAWQOS, targetAWREGION, targetAWUSER}),
                   .AXI4S_TTVALID      (TARGET_AWVALID),
                   .AXI4S_TTDATA       ({TARGET_AWID, TARGET_AWADDR, TARGET_AWLEN, TARGET_AWSIZE, TARGET_AWBURST, TARGET_AWLOCK, TARGET_AWCACHE,  TARGET_AWPROT, TARGET_ARQOS, TARGET_AWREGION, TARGET_AWUSER}),
                   .AXI4S_TTREADY      (TARGET_AWREADY)
                );
		      if(TARGET_TYPE == 2'b11) begin    //AXI3 
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
                   .AXI4S_ACLK         (TRGT_CLK),
                   .AXI4S_IACLK        (TRGT_CLK),
                   .AXI4S_TACLK        (XBAR_CLK ),
                   .AXI4S_ARESETN      (cfifo_trst),
                   .AXI4S_IARESETN     (cfifo_trst),
                   .AXI4S_TARESETN     (cfifo_arst ),
                   .AXI4S_ITREADY      (targetWREADY),
                   .AXI4S_ITVALID      (targetWVALID),
                   .AXI4S_ITDATA       ({targetWID,targetWDATA, targetWSTRB, targetWLAST, targetWUSER}),
                   .AXI4S_TTVALID      (TARGET_WVALID),
                   .AXI4S_TTDATA       ({TARGET_WID,TARGET_WDATA, TARGET_WSTRB, TARGET_WLAST, TARGET_WUSER}),
                   .AXI4S_TTREADY      (TARGET_WREADY)
                );
			  end else begin 
			    assign targetWID   = 0;
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
                   .AXI4S_ACLK         (TRGT_CLK),
                   .AXI4S_IACLK        (TRGT_CLK ),
                   .AXI4S_TACLK        (XBAR_CLK),
                   .AXI4S_ARESETN      (cfifo_trst),
                   .AXI4S_IARESETN     (cfifo_trst),
                   .AXI4S_TARESETN     (cfifo_arst ),
                   .AXI4S_ITREADY      (targetWREADY),
                   .AXI4S_ITVALID      (targetWVALID),
                   .AXI4S_ITDATA       ({targetWDATA, targetWSTRB, targetWLAST, targetWUSER}),
                   .AXI4S_TTVALID      (TARGET_WVALID),
                   .AXI4S_TTDATA       ({TARGET_WDATA, TARGET_WSTRB, TARGET_WLAST, TARGET_WUSER}),
                   .AXI4S_TTREADY      (TARGET_WREADY)
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
                 .AXI4S_ACLK         (TRGT_CLK),
                 .AXI4S_IACLK        (TRGT_CLK),
                 .AXI4S_TACLK        (XBAR_CLK ),
                 .AXI4S_ARESETN      (cfifo_trst),
                 .AXI4S_IARESETN     (cfifo_trst),
                 .AXI4S_TARESETN     (cfifo_arst  ),
                 .AXI4S_ITREADY      (targetARREADY),
                 .AXI4S_ITVALID      (targetARVALID),
                 .AXI4S_ITDATA       ({targetARID, targetARADDR, targetARLEN, targetARSIZE, targetARBURST, targetARLOCK, targetARCACHE,  targetARPROT, targetARQOS, targetARREGION, targetARUSER}),
                 .AXI4S_TTVALID      (TARGET_ARVALID),
                 .AXI4S_TTDATA       ({TARGET_ARID, TARGET_ARADDR, TARGET_ARLEN, TARGET_ARSIZE, TARGET_ARBURST, TARGET_ARLOCK, TARGET_ARCACHE,  TARGET_ARPROT, TARGET_ARQOS, TARGET_ARREGION, TARGET_ARUSER}),
                 .AXI4S_TTREADY      (TARGET_ARREADY)
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
                 .AXI4S_ACLK         (TRGT_CLK),
                 .AXI4S_IACLK        (XBAR_CLK ),
                 .AXI4S_TACLK        (TRGT_CLK ),
                 .AXI4S_ARESETN      (cfifo_trst),
                 .AXI4S_IARESETN     (cfifo_arst ),
                 .AXI4S_TARESETN     (cfifo_trst ),
                 .AXI4S_ITREADY      (TARGET_RREADY),
                 .AXI4S_ITVALID      (TARGET_RVALID),
                 .AXI4S_ITDATA       ({TARGET_RID, TARGET_RDATA, TARGET_RRESP, TARGET_RLAST, TARGET_RUSER}),
                 .AXI4S_TTVALID      (targetRVALID),
                 .AXI4S_TTDATA       ({targetRID, targetRDATA, targetRRESP, targetRLAST, targetRUSER}),
                 .AXI4S_TTREADY      (targetRREADY)
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
                 .AXI4S_ACLK         (TRGT_CLK),
                 .AXI4S_IACLK        (XBAR_CLK ),
                 .AXI4S_TACLK        (TRGT_CLK ),
                 .AXI4S_ARESETN      (cfifo_trst),
                 .AXI4S_IARESETN     (cfifo_arst),
                 .AXI4S_TARESETN     (cfifo_trst  ),
                 .AXI4S_ITREADY      (TARGET_BREADY),
                 .AXI4S_ITVALID      (TARGET_BVALID),
                 .AXI4S_ITDATA       ({TARGET_BID, TARGET_BRESP, TARGET_BUSER}),
                 .AXI4S_TTVALID      (targetBVALID),
                 .AXI4S_TTDATA       ({targetBID, targetBRESP, targetBUSER}),
                 .AXI4S_TTREADY      (targetBREADY)
              );	
		   end else begin 

             caxi4interconnect_CDC_FIFO #
	           (
                 .MEM_DEPTH (CDC_ADDR_RESP_FIFO_DEPTH),
                 .DATA_WIDTH  ( ADDR_CHAN_WIDTH ),
				 .INITIATOR_BCHAN (0),
				 .NUM_SYNC_STAGES (NUM_STAGES               ),
				 .RESET_TYPE      (SYNC_RESET               )
               )
	           cdc_AWChan
               (
    	         .arst (arst_sync),
    	         .srst (srst_sync),
    	         .rdclk_arst (tarst_sync),
    	         .rdclk_srst (tsrst_sync),
                 .clk_rd (TRGT_CLK),
                 .clk_wr (XBAR_CLK),

                 .infoInValid (TARGET_AWVALID),
                 .readyForOut (targetAWREADY),

                 .infoIn ({TARGET_AWID, TARGET_AWADDR, TARGET_AWLEN, TARGET_AWSIZE, TARGET_AWBURST, TARGET_AWLOCK, TARGET_AWCACHE,  TARGET_AWPROT, TARGET_AWQOS, TARGET_AWREGION, TARGET_AWUSER}),

                 .infoOut ({targetAWID, targetAWADDR, targetAWLEN, targetAWSIZE, targetAWBURST, targetAWLOCK, targetAWCACHE,  targetAWPROT, targetAWQOS, targetAWREGION, targetAWUSER}),
                 .readyForInfo (TARGET_AWREADY),
                 .infoOutValid (targetAWVALID)
		       );

		if(TARGET_TYPE == 2'b11)         //AXI3
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
    	     .arst (arst_sync),
    	     .srst (srst_sync),
    	     .rdclk_arst (tarst_sync),
    	     .rdclk_srst (tsrst_sync),
             .clk_rd (TRGT_CLK),
             .clk_wr (XBAR_CLK),

             .infoInValid (TARGET_WVALID),
             .readyForOut (targetWREADY),

             .infoIn ({TARGET_WID,TARGET_WDATA, TARGET_WSTRB, TARGET_WLAST, TARGET_WUSER}),

             .infoOut ({targetWID,targetWDATA, targetWSTRB, targetWLAST, targetWUSER}),
             .readyForInfo (TARGET_WREADY),
             .infoOutValid (targetWVALID)
		    );
		  end 
		else 
		  begin 
		   assign targetWID = 0;
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
    	     .arst (arst_sync),
    	     .srst (srst_sync),
    	     .rdclk_arst (tarst_sync),
    	     .rdclk_srst (tsrst_sync),
             .clk_rd (TRGT_CLK),
             .clk_wr (XBAR_CLK),

             .infoInValid (TARGET_WVALID),
             .readyForOut (targetWREADY),

             .infoIn ({TARGET_WDATA, TARGET_WSTRB, TARGET_WLAST, TARGET_WUSER}),

             .infoOut ({targetWDATA, targetWSTRB, targetWLAST, targetWUSER}),
             .readyForInfo (TARGET_WREADY),
             .infoOutValid (targetWVALID)
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
    	         .arst (arst_sync),
    	         .srst (srst_sync),
    	         .rdclk_arst (tarst_sync),
    	         .rdclk_srst (tsrst_sync),
                 .clk_rd (TRGT_CLK),
                 .clk_wr (XBAR_CLK),

                 .infoInValid (TARGET_ARVALID),
                 .readyForOut (targetARREADY),

                 .infoIn ({TARGET_ARID, TARGET_ARADDR, TARGET_ARLEN, TARGET_ARSIZE, TARGET_ARBURST, TARGET_ARLOCK, TARGET_ARCACHE,  TARGET_ARPROT, TARGET_ARQOS, TARGET_ARREGION, TARGET_ARUSER}),

                 .infoOut ({targetARID, targetARADDR, targetARLEN, targetARSIZE, targetARBURST, targetARLOCK, targetARCACHE,  targetARPROT, targetARQOS, targetARREGION, targetARUSER}),
                 .readyForInfo (TARGET_ARREADY),
                 .infoOutValid (targetARVALID)
		       );

	       caxi4interconnect_CDC_FIFO #
	           (
                 .MEM_DEPTH (CDC_FIFO_DEPTH),
                 .DATA_WIDTH  ( RCHAN_WIDTH ),
				 .INITIATOR_BCHAN (0),
				 .NUM_SYNC_STAGES (NUM_STAGES               ),
				 .RESET_TYPE      (SYNC_RESET               )
               )
	       cdc_RChan
               (
    	         .arst (tarst_sync ),
    	         .srst (tsrst_sync ),
    	         .rdclk_arst (arst_sync),
    	         .rdclk_srst (srst_sync),				 
                 .clk_wr (TRGT_CLK),
                 .clk_rd (XBAR_CLK),

                 .infoInValid (targetRVALID),
                 .readyForOut (TARGET_RREADY),

                 .infoOut ({TARGET_RID, TARGET_RDATA, TARGET_RRESP, TARGET_RLAST, TARGET_RUSER}),

                 .infoIn ({targetRID, targetRDATA, targetRRESP, targetRLAST, targetRUSER}),
                 .readyForInfo (targetRREADY),
                 .infoOutValid (TARGET_RVALID)
		       );

	       caxi4interconnect_CDC_FIFO #
	           (
                 .MEM_DEPTH (CDC_ADDR_RESP_FIFO_DEPTH),
                 .DATA_WIDTH  ( BCHAN_WIDTH ),
				 .INITIATOR_BCHAN (0),
				 .NUM_SYNC_STAGES (NUM_STAGES               ),
				 .RESET_TYPE      (SYNC_RESET               )
               )
	           cdc_BChan
               (
    	         .arst (tarst_sync ),
    	         .srst (tsrst_sync ),
    	         .rdclk_arst (arst_sync),
    	         .rdclk_srst (srst_sync),	
                 .clk_wr (TRGT_CLK),
                 .clk_rd (XBAR_CLK),

                 .infoInValid (targetBVALID),
                 .readyForOut (TARGET_BREADY),

                 .infoOut ({TARGET_BID, TARGET_BRESP, TARGET_BUSER}),

                 .infoIn ({targetBID, targetBRESP, targetBUSER}),
                 .readyForInfo (targetBREADY),
                 .infoOutValid (TARGET_BVALID)
		       );
		end 
	end
	else begin
		//====================================== ASSIGNEMENTS =================================================
		//from Initiator to crossbar & Target
		
		assign targetAWID =	TARGET_AWID;
		assign targetAWADDR = TARGET_AWADDR;
		assign targetAWLEN = TARGET_AWLEN;
		assign targetAWSIZE = TARGET_AWSIZE;
		assign targetAWBURST = TARGET_AWBURST;	
		assign targetAWLOCK = TARGET_AWLOCK;
		assign targetAWCACHE = TARGET_AWCACHE;	
		assign targetAWPROT = TARGET_AWPROT;
		assign targetAWREGION = TARGET_AWREGION;
		assign targetAWQOS = TARGET_AWQOS;
		assign targetAWUSER = TARGET_AWUSER;
		assign targetAWVALID = TARGET_AWVALID;	
		assign targetWID = TARGET_WID;
		assign targetWDATA = TARGET_WDATA;
		assign targetWSTRB = TARGET_WSTRB;
		assign targetWLAST = TARGET_WLAST;
		assign targetWUSER = TARGET_WUSER;
		assign targetWVALID = TARGET_WVALID;
		assign targetBREADY = TARGET_BREADY;
		assign targetARID = TARGET_ARID;
		assign targetARADDR = TARGET_ARADDR;
		assign targetARLEN = TARGET_ARLEN;
		assign targetARSIZE = TARGET_ARSIZE;
		assign targetARBURST = TARGET_ARBURST;	
		assign targetARLOCK = TARGET_ARLOCK;
		assign targetARCACHE = TARGET_ARCACHE;	
		assign targetARPROT = TARGET_ARPROT;
		assign targetARREGION = TARGET_ARREGION;
		assign targetARQOS = TARGET_ARQOS;
		assign targetARUSER = TARGET_ARUSER;
		assign targetARVALID = TARGET_ARVALID;	
		assign targetRREADY = TARGET_RREADY;
		//			
		//from crossbar to TARGET
		assign TARGET_AWREADY = targetAWREADY;	
		assign TARGET_WREADY = targetWREADY;
		assign TARGET_BID = targetBID;
		assign TARGET_BRESP =	targetBRESP;
		assign TARGET_BUSER =	targetBUSER;
		assign TARGET_BVALID = targetBVALID;	
		assign TARGET_ARREADY = targetARREADY;	
					
		assign TARGET_RID = targetRID;
		assign TARGET_RDATA =	targetRDATA;
		assign TARGET_RRESP =	targetRRESP;
		assign TARGET_RLAST =	targetRLAST;
		assign TARGET_RUSER =	targetRUSER;
		assign TARGET_RVALID = targetRVALID;
	  end		
	endgenerate
endmodule	
