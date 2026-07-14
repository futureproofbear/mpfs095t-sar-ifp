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

module caxi4interconnect_TrgtAxi4ProtConvAXI4ID #
       
	(	
		parameter [0:0] 	ZERO_TARGET_ID	  	    = 1'b1,	// zero ID field		
		parameter integer 	ID_WIDTH   				= 1,		// number of bits for ID (ie AID, WID, BID) - valid 1-8 
		parameter integer 	TRGT_AXI4PRT_ADDRDEPTH	= 8,		// Number transations width - 1 => 2 transations, 2 => 4 transations, etc.
		parameter           READ_INTERLEAVE         = 1,
        parameter           PIPE                    = 0,
        parameter           PROTOCONV_RAM_TYPE      = 3,
        parameter           SYNC_RESET              = 0,
        parameter           BYPASS_CROSSBAR         = 0     // 1 - Crossbar bypassed, skip ID FIFO for pure register slice mode
	)
	(

	//=====================================  Global Signals   ========================================================================
	input  wire           			ACLK,
	input  wire          			arst_sync,
	input  wire          			srst_sync,
	
	// External side
	//Target Read Address Ports
	output wire [ID_WIDTH-1:0]      TARGET_AID,
	output wire         			TARGET_AVALID,

	input wire             			TARGET_AREADY,


	// Target Read Data Ports
	input wire [ID_WIDTH-1:0]  		TARGET_ID,	
	
	output wire               		TARGET_READY,
  	input wire                 		TARGET_VALID,
	input wire                 		TARGET_LAST,

	// Target Read Address Ports	
	input  wire [ID_WIDTH-1:0]  	int_targetAID,

	input wire                		int_targetAVALID,
	output wire                		int_targetAREADY,
	
	// Target Read Data Ports	
	output wire [ID_WIDTH-1:0]  	int_targetID,
	output wire                 	int_targetVALID,
	input wire                 		int_targetREADY
	
	);


       wire fifoEmpty;
       wire fifoFull;
       wire fifoNearlyFull;
       wire [ID_WIDTH-1:0] IDFifoOut;
       wire fifoWr;
       wire fifoRd;
       wire         cfifo_rst;

       assign       cfifo_rst = (SYNC_RESET == 0) ? arst_sync : srst_sync; 

        generate
          // FIFO only needed when: no interleaving, zeroing target ID, AND crossbar is active
          // When BYPASS_CROSSBAR=1 , skip FIFO - direct wire passthrough
          if (READ_INTERLEAVE == 0 && ZERO_TARGET_ID == 1 && BYPASS_CROSSBAR == 0) begin
            if(PIPE > 0) begin 
	          localparam  FIFO_SIZE = TRGT_AXI4PRT_ADDRDEPTH;
		      wire rdataintrlvfifo_ttrdy;
		      wire rdataintrlvfifo_itvld;

              caxi4c_coreaxi4s_fifo #
              (
                 .RESET_TYPE         (SYNC_RESET),//
                 .SYNC               (1),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
                 .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
                 .ECC                (0),// 0: ECC disable , 1: ECC enable
                 .RAM_TYPE           (0),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
                 .NUM_STAGES         (0),// To select number of synchronizer stages.
                 .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
                 .WFIFO_DEPTH        (FIFO_SIZE),
                 .RFIFO_DEPTH        (FIFO_SIZE),
                 .AXIS_TTDATA_WIDTH  (ID_WIDTH), // Bytes
                 .AXIS_ITDATA_WIDTH  (ID_WIDTH),  // Bytes
                 .AXIS_TTID_WIDTH    (1), // Bits
                 .AXIS_ITID_WIDTH    (1), // Bits
                 .AXIS_TTDEST_WIDTH  (1), // Bits
                 .AXIS_ITDEST_WIDTH  (1), // Bits
                 .AXIS_TTUSER_WIDTH  (1), // Bits
                 .AXIS_ITUSER_WIDTH  (1), // Bits
                 .ENABLE_AFULL       (1),
                 .AFULL_THR          (FIFO_SIZE-1),
                 .ENABLE_TSTRB       (0),
                 .ENABLE_TKEEP       (0),
                 .ENABLE_TLAST       (0),
                 .ENABLE_TUSER       (0),
                 .ENABLE_TDEST       (0),
                 .ENABLE_TID         (0),
                 .EOP_OFFSET         (0)
              ) rdata_interleave_fifo_fwft
              (
                 .AXI4S_ACLK         (ACLK),
                 .AXI4S_IACLK        (ACLK),
                 .AXI4S_TACLK        (ACLK),
                 .AXI4S_ARESETN      (cfifo_rst),
                 .AXI4S_IARESETN     (cfifo_rst),
                 .AXI4S_TARESETN     (cfifo_rst),
                 .AXI4S_ITREADY      (fifoRd),
                 .AXI4S_ITVALID      (rdataintrlvfifo_itvld),
                 .AXI4S_ITDATA       (IDFifoOut),
                 .AXI4S_TTVALID      (fifoWr ),
                 .AXI4S_TTDATA       (int_targetAID),
                 .ALMOST_FULL        (rdataintrlvfifo_ttrdy)
              );
		      
              assign fifoNearlyFull  = rdataintrlvfifo_ttrdy;
              assign fifoEmpty       = ~rdataintrlvfifo_itvld;  
			end else begin 
              // SAR#LINT-003: Use localparam to avoid width overflow in parameter expression
              localparam [31:0] NEARLY_FULL_VAL = TRGT_AXI4PRT_ADDRDEPTH - 1;
              caxi4interconnect_FIFO #
	          (
		      .MEM_DEPTH( TRGT_AXI4PRT_ADDRDEPTH ),
		      .DATA_WIDTH_IN ( ID_WIDTH ),
		      .DATA_WIDTH_OUT ( ID_WIDTH ), 
		      .NEARLY_FULL_THRESH ( NEARLY_FULL_VAL ),
		      .NEARLY_EMPTY_THRESH ( 0 )
	          )
              rdata_interleave_fifo (
	          .arst (arst_sync ),
	          .srst (srst_sync ),
	          .clk ( ACLK ),
	          .wr_en ( fifoWr ),
	          .rd_en ( fifoRd ),
	          .data_in ( int_targetAID ),
	          .data_out ( IDFifoOut ),
	          .zero_data ( 1'b0 ),
	          .fifo_full ( fifoFull ),
	          .fifo_empty ( fifoEmpty ),
	          .fifo_nearly_full ( fifoNearlyFull ),
	          .fifo_nearly_empty ( ),
	          .fifo_one_from_full ( )
              );
			end 
            assign fifoWr = int_targetAREADY & int_targetAVALID;
            assign fifoRd = TARGET_READY & TARGET_VALID & TARGET_LAST;
	        assign TARGET_READY = ~fifoEmpty & int_targetREADY;
  	        assign TARGET_AID = 0;
            assign int_targetID = IDFifoOut;
            assign int_targetAREADY = ~fifoNearlyFull & TARGET_AREADY;
            assign TARGET_AVALID = int_targetAVALID & ~fifoNearlyFull;
	        assign int_targetVALID = TARGET_VALID & ~fifoEmpty;	
          end else begin
	        assign int_targetAREADY = TARGET_AREADY;	
  	        assign TARGET_AID = int_targetAID;
	        assign int_targetID = TARGET_ID;
	        assign TARGET_READY = int_targetREADY;
	        assign TARGET_AVALID = int_targetAVALID;
	        assign int_targetVALID = TARGET_VALID;	
          end
        endgenerate		
endmodule
