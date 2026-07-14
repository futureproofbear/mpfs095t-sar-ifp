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
// SVN $Revision: 49538 $
// SVN $Date: 2025-08-17 13:12:47 +0530 (Sun, 17 Aug 2025) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns



module caxi4interconnect_DWC_UpConv_BChannel #

	(
		parameter integer	ID_WIDTH	    = 1,
		parameter integer	USER_WIDTH	    = 1,
		parameter integer	ADDR_FIFO_DEPTH	= 3,
		parameter           READ_INTERLEAVE = 0,
        parameter           PIPE            = 0,
        parameter           DWC_RAM_TYPE    = 3,
        parameter           SYNC_RESET      = 0
	)
	(

		input wire                    arst_sync,
		input wire                    srst_sync,
		input wire                    ACLK,

		// W channel
		output wire [ID_WIDTH-1:0]    INITIATOR_BID,
		output wire [1:0] 		      INITIATOR_BRESP,
		output wire [USER_WIDTH-1:0]  INITIATOR_BUSER,
		output wire                   INITIATOR_BVALID,
		input wire                    INITIATOR_BREADY,

		// W channel
		input wire[ID_WIDTH-1:0]      TARGET_BID,
		input wire[1:0]               TARGET_BRESP,
		input wire[USER_WIDTH-1:0]    TARGET_BUSER,
		input wire                    TARGET_BVALID,
		output wire                   TARGET_BREADY,

        output wire                   bchan_cmd_fifo_full,
		input wire		   	          wr_en_cmd,
		input wire[ID_WIDTH:0]		  BRespFifoWrData
	);

	
    localparam           TOTAL_IDS   = READ_INTERLEAVE ? (2 ** ID_WIDTH) : 1;
	
	
	
	wire [TOTAL_IDS-1:0] cmd_fifo_empty_temp;
	wire                 cmd_fifo_empty;
	

	wire                 rd_en_cmd;
    
    wire                 cfifo_rst;

    assign cfifo_rst = (SYNC_RESET == 0) ? arst_sync : srst_sync; 	

genvar id_range; 
	
generate  
  if(READ_INTERLEAVE)
    begin 
	  wire [TOTAL_IDS-1:0] BRespFifoRdData;
      wire [TOTAL_IDS-1:0] cmd_fifo_full;
	  
	  assign bchan_cmd_fifo_full = (| cmd_fifo_full);
	  
      for(id_range = 0; id_range < TOTAL_IDS; id_range = id_range+1)
        begin 
	      if(PIPE > 0) begin 
            localparam  FIFO_SIZE = ($clog2(ADDR_FIFO_DEPTH) < 2) ? 4 : ADDR_FIFO_DEPTH;
		    wire [TOTAL_IDS-1:0] cmdcmdfifo_itvld;
		    wire [TOTAL_IDS-1:0] cmddcmdfifo_ttrdy;
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
             .AXIS_TTDATA_WIDTH  (1), // Bytes
             .AXIS_ITDATA_WIDTH  (1),  // Bytes
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
            ) cmd_fifo_fwft
            (
             .AXI4S_ACLK         (ACLK),
             .AXI4S_IACLK        (ACLK),
             .AXI4S_TACLK        (ACLK),
             .AXI4S_ARESETN      (cfifo_rst),
             .AXI4S_IARESETN     (cfifo_rst),
             .AXI4S_TARESETN     (cfifo_rst),
             .AXI4S_ITREADY      (rd_en_cmd & (TARGET_BID == id_range)),
             .AXI4S_ITVALID      (cmdcmdfifo_itvld[id_range]),
             .AXI4S_ITDATA       (BRespFifoRdData[id_range]),
             .AXI4S_TTVALID      (wr_en_cmd & (BRespFifoWrData[ID_WIDTH:1] == id_range) ),
             .AXI4S_TTDATA       (BRespFifoWrData[0] ),
             .ALMOST_FULL        (cmddcmdfifo_ttrdy[id_range])
            );
		
            assign cmd_fifo_full[id_range]       = cmddcmdfifo_ttrdy[id_range];
            assign cmd_fifo_empty_temp[id_range] = ~cmdcmdfifo_itvld[id_range];
	  
	      end else begin       
	        caxi4interconnect_FIFO #
	        	(
	        		.MEM_DEPTH( ADDR_FIFO_DEPTH ),
	        		.DATA_WIDTH_IN ( 1 ),
	        		.DATA_WIDTH_OUT ( 1 ), 
	        		.NEARLY_FULL_THRESH ( ADDR_FIFO_DEPTH - 1 ),
	        		.NEARLY_EMPTY_THRESH ( 0 )
	        	)
	        cmd_fifo (
	        		.arst (arst_sync ),
	        		.srst (srst_sync ),
	        		.clk ( ACLK ),
	        		.wr_en ( wr_en_cmd & (BRespFifoWrData[ID_WIDTH:1] == id_range) ),
	        		.rd_en ( rd_en_cmd & (TARGET_BID == id_range)),
	        		.data_in ( BRespFifoWrData[0] ),
	        		.data_out ( BRespFifoRdData[id_range] ),
	        		.zero_data ( 1'b0 ),
	        		.fifo_full ( ),
	        		.fifo_empty ( cmd_fifo_empty_temp[id_range] ),
	        		.fifo_nearly_full ( cmd_fifo_full[id_range] ),
	        		.fifo_nearly_empty ( ),
	        		.fifo_one_from_full ( )
	          );	      
	      end
		end 

		assign cmd_fifo_empty = INITIATOR_BVALID ? cmd_fifo_empty_temp[INITIATOR_BID] : cmd_fifo_empty_temp[TARGET_BID];

	    caxi4interconnect_DWC_brespCtrl #
		(
			.ID_WIDTH ( ID_WIDTH ),
			.USER_WIDTH ( USER_WIDTH )
		)
	    brespCtrl( 
            .TARGET_BREADY(TARGET_BREADY),
            .TARGET_BRESP(TARGET_BRESP),
            .TARGET_BUSER(TARGET_BUSER),
            .TARGET_BVALID(TARGET_BVALID),
            .TARGET_BID(TARGET_BID),
            .BRespFifoRdData(BRespFifoRdData[TARGET_BID]),
            .bresp_fifo_empty(cmd_fifo_empty),
            .brespFifore(rd_en_cmd),
            .ACLK(ACLK),
            .arst_sync(arst_sync),
            .srst_sync(srst_sync),
            .INITIATOR_BID(INITIATOR_BID),
            .INITIATOR_BREADY(INITIATOR_BREADY),
            .INITIATOR_BRESP(INITIATOR_BRESP),
            .INITIATOR_BUSER(INITIATOR_BUSER),
            .INITIATOR_BVALID(INITIATOR_BVALID) 
        );

	end 
  else 
    begin 
	
	  wire [ID_WIDTH:0] BRespFifoRdData;
	  wire              cmd_fifo_full;
	  
   	  assign bchan_cmd_fifo_full = cmd_fifo_full;

	  if(PIPE > 0) begin 
	    localparam  FIFO_SIZE = ($clog2(ADDR_FIFO_DEPTH) < 2) ? 4 : ADDR_FIFO_DEPTH;
	    wire cmdcmdfifo_itvld;
	    wire cmddcmdfifo_ttrdy;
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
         .AXIS_TTDATA_WIDTH  (1 + ID_WIDTH), // Bytes
         .AXIS_ITDATA_WIDTH  (1 + ID_WIDTH),  // Bytes
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
        ) cmd_fifo_fwft
        (
         .AXI4S_ACLK         (ACLK),
         .AXI4S_IACLK        (ACLK),
         .AXI4S_TACLK        (ACLK),
         .AXI4S_ARESETN      (cfifo_rst),
         .AXI4S_IARESETN     (cfifo_rst),
         .AXI4S_TARESETN     (cfifo_rst),
         .AXI4S_ITREADY      (rd_en_cmd),
         .AXI4S_ITVALID      (cmdcmdfifo_itvld),
         .AXI4S_ITDATA       (BRespFifoRdData),
         .AXI4S_TTVALID      (wr_en_cmd ),
         .AXI4S_TTDATA       (BRespFifoWrData ),
         .ALMOST_FULL        (cmddcmdfifo_ttrdy)
        );
	
        assign cmd_fifo_full  = cmddcmdfifo_ttrdy;
        assign cmd_fifo_empty = ~cmdcmdfifo_itvld;
	  
	  end else begin	  
	  caxi4interconnect_FIFO #
		(
			.MEM_DEPTH( ADDR_FIFO_DEPTH ),
			.DATA_WIDTH_IN ( 1 + ID_WIDTH ),
			.DATA_WIDTH_OUT ( 1 +  ID_WIDTH ), 
			.NEARLY_FULL_THRESH ( ADDR_FIFO_DEPTH - 1 ),
			.NEARLY_EMPTY_THRESH ( 0 )
		)
	    cmd_fifo (
			.arst (arst_sync ),
			.srst (srst_sync ),
			.clk ( ACLK ),
			.wr_en ( wr_en_cmd ),
			.rd_en ( rd_en_cmd ),
			.data_in ( BRespFifoWrData ),
			.data_out ( BRespFifoRdData ),
			.zero_data ( 1'b0 ),
			.fifo_full ( ),
			.fifo_empty ( cmd_fifo_empty ),
			.fifo_nearly_full ( cmd_fifo_full ),
			.fifo_nearly_empty ( ),
			.fifo_one_from_full ( )
	    );
	  end 	
	  
	  caxi4interconnect_DWC_brespCtrl #
	  (
	   .ID_WIDTH ( ID_WIDTH ),
	   .USER_WIDTH ( USER_WIDTH )
	  ) brespCtrl( 
         .TARGET_BREADY(TARGET_BREADY),
         .TARGET_BRESP(TARGET_BRESP),
         .TARGET_BUSER(TARGET_BUSER),
         .TARGET_BVALID(TARGET_BVALID),
         .TARGET_BID(BRespFifoRdData[ID_WIDTH:1]),
         .BRespFifoRdData(BRespFifoRdData[0]),
         .bresp_fifo_empty(cmd_fifo_empty),
         .brespFifore(rd_en_cmd),
         .ACLK(ACLK),
         .arst_sync(arst_sync),
         .srst_sync(srst_sync),
         .INITIATOR_BID(INITIATOR_BID),
         .INITIATOR_BREADY(INITIATOR_BREADY),
         .INITIATOR_BRESP(INITIATOR_BRESP),
         .INITIATOR_BUSER(INITIATOR_BUSER),
         .INITIATOR_BVALID(INITIATOR_BVALID) 
      );
	  	
	end 	
endgenerate
endmodule
