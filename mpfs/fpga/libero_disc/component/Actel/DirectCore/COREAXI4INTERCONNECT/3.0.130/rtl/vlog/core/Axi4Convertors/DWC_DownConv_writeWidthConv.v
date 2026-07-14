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
// SVN $Revision: 51335 $
// SVN $Date: 2026-04-24 18:00:00 +0530 (Fri, 24 Apr 2026) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_DWC_DownConv_writeWidthConv( INITIATOR_AWREADY,
                       INITIATOR_AWADDR,
                       INITIATOR_AWBURST,
                       INITIATOR_AWCACHE,
                       INITIATOR_AWID,
                       INITIATOR_AWLEN,
                       INITIATOR_AWLOCK,
                       INITIATOR_AWPROT,
                       INITIATOR_AWQOS,
                       INITIATOR_AWREGION,
                       INITIATOR_AWSIZE,
                       INITIATOR_AWUSER,
                       INITIATOR_AWVALID,
                       TARGET_BID,
                       TARGET_BREADY,
                       TARGET_BRESP,
                       TARGET_BUSER,
                       TARGET_BVALID,
                       TARGET_AWADDR,
                       TARGET_AWBURST,
                       TARGET_AWCACHE,
                       TARGET_AWID,
                       TARGET_AWLEN,
                       TARGET_AWLOCK,
                       TARGET_AWPROT,
                       TARGET_AWQOS,
                       TARGET_AWREADY,
                       TARGET_AWREGION,
                       TARGET_AWSIZE,
                       TARGET_AWUSER,
                       TARGET_AWVALID,
                       INITIATOR_BID,
                       INITIATOR_BREADY,
                       INITIATOR_BRESP,
                       INITIATOR_BUSER,
                       INITIATOR_BVALID,
					   INITIATOR_WID,
                       INITIATOR_WDATA,
                       INITIATOR_WLAST,
                       INITIATOR_WREADY,
                       INITIATOR_WSTRB,
                       INITIATOR_WUSER,
                       INITIATOR_WVALID,
					   TARGET_WID,
                       TARGET_WDATA,
                       TARGET_WLAST,
                       TARGET_WREADY,
                       TARGET_WSTRB,
                       TARGET_WUSER,
                       TARGET_WVALID,
                       ACLK,
                       arst_sync, 
                       srst_sync 
					   );

parameter CMD_FIFO_DATA_WIDTH = 29; 
parameter DATA_WIDTH_IN       = 32; 
parameter DATA_WIDTH_OUT      = 32; 
parameter ADDR_FIFO_DEPTH     = 5; 
parameter ADDR_WIDTH          = 20; 
parameter ID_WIDTH            = 1; 
parameter USER_WIDTH          = 1; 
parameter STRB_WIDTH_IN       = 64; 
parameter STRB_WIDTH_OUT      = 4; 
parameter READ_INTERLEAVE     = 0; 
parameter PIPE                = 0;
parameter DWC_RAM_TYPE        = 0; 
parameter SYNC_RESET          = 0;


localparam     TOTAL_IDS = READ_INTERLEAVE ? (2 ** ID_WIDTH) : 1;


// Port: INITIATOR_AWChan

output         INITIATOR_AWREADY;
input [ADDR_WIDTH-1:0] INITIATOR_AWADDR;
input [1:0]    INITIATOR_AWBURST;
input [3:0]    INITIATOR_AWCACHE;
input [ID_WIDTH-1:0] INITIATOR_AWID;
input [7:0]    INITIATOR_AWLEN;
input [1:0]    INITIATOR_AWLOCK;
input [2:0]    INITIATOR_AWPROT;
input [3:0]    INITIATOR_AWQOS;
input [3:0]    INITIATOR_AWREGION;
input [2:0]    INITIATOR_AWSIZE;
input [USER_WIDTH-1:0] INITIATOR_AWUSER;
input          INITIATOR_AWVALID;

// Port: TARGET_BChan

input [ID_WIDTH-1:0] TARGET_BID;
output         TARGET_BREADY;
input [1:0]    TARGET_BRESP;
input [USER_WIDTH-1:0] TARGET_BUSER;
input          TARGET_BVALID;

// Port: TARGET_AWChan

output [ADDR_WIDTH-1:0] TARGET_AWADDR;
output [1:0]   TARGET_AWBURST;
output [3:0]   TARGET_AWCACHE;
output [ID_WIDTH-1:0] TARGET_AWID;
output [7:0]   TARGET_AWLEN;
output [1:0]   TARGET_AWLOCK;
output [2:0]   TARGET_AWPROT;
output [3:0]   TARGET_AWQOS;
input          TARGET_AWREADY;
output [3:0]   TARGET_AWREGION;
output [2:0]   TARGET_AWSIZE;
output [USER_WIDTH-1:0] TARGET_AWUSER;
output         TARGET_AWVALID;

// Port: INITIATOR_BChan

output [ID_WIDTH-1:0] INITIATOR_BID;
input          INITIATOR_BREADY;
output [1:0]   INITIATOR_BRESP;
output [USER_WIDTH-1:0] INITIATOR_BUSER;
output         INITIATOR_BVALID;

// Port: INITIATOR_WChan

input [ID_WIDTH-1:0]      INITIATOR_WID;
input [DATA_WIDTH_IN-1:0] INITIATOR_WDATA;
input          INITIATOR_WLAST;
output         INITIATOR_WREADY;
input [STRB_WIDTH_IN-1:0] INITIATOR_WSTRB;
input [USER_WIDTH-1:0] INITIATOR_WUSER;
input          INITIATOR_WVALID;

// Port: TARGET_WChan

output [ID_WIDTH-1:0]       TARGET_WID;
output [DATA_WIDTH_OUT-1:0] TARGET_WDATA;
output         TARGET_WLAST;
input          TARGET_WREADY;
output [STRB_WIDTH_OUT-1:0] TARGET_WSTRB;
output [USER_WIDTH-1:0] TARGET_WUSER;
output         TARGET_WVALID;

// Port: system

input          ACLK;
input          arst_sync;
input          srst_sync;


wire                  brespFifoEmpty;
wire [TOTAL_IDS-1:0]  brespFifoEmpty_temp;
wire [ID_WIDTH:0]     brespFifoWrData;
wire [TOTAL_IDS-1:0]  brespFifoNearlyFull;
wire           brespFifore;
wire           brespFifowe;
wire           wrCmdFifoEmpty;
wire           wrCmdFifoNearlyFull;
wire [CMD_FIFO_DATA_WIDTH-1:0] wrCmdFifoRdData;
wire           wrCmdFifore;
wire           wrCmdFifowe;
wire [CMD_FIFO_DATA_WIDTH-1:0] wrCmdFifowrData;


// wire [8:0]	to_boundary_conv_pre;
wire [4:0]	to_boundary_initiator_pre;
wire [5:0]  mask_addr_pre;
wire [2:0]	ASIZE_pre;
wire [12:0]	tot_len_M_to_boundary_conv_pre;
wire [7:0]	to_boundary_conv_M1_pre;
wire [12:0]	tot_len_pre;
wire [8:0]	max_length_comb_pre;
wire [8:0]	length_comb_pre;
wire 				tot_len_GT_max_length_comb_pre;
wire [12:0]	tot_len_M_max_length_comb_pre;
wire [7:0]	tot_axi_len_pre;
wire [2:0]	wrap_log_len_comb_pre;
wire [5:0]	sizeMax_pre;
wire 				SameInitrTrgtSize_pre;
wire [5:0]	sizeCnt_comb_pre;
wire            fixed_burst;
wire [6:0]      unaligned_fixed_len_iter;
wire INITIATOR_AWVALID_reg;
wire from_ctrl_INITIATOR_READY;
wire to_ctrl_INITIATOR_AWVALID;

wire     [7:0]               int_INITIATOR_AWLEN;
wire                         int_INITIATOR_AWVALID;
wire     [ID_WIDTH - 1:0]    int_INITIATOR_AWID;
wire     [ADDR_WIDTH - 1:0]  int_INITIATOR_AWADDR;
wire     [1:0]               int_INITIATOR_AWBURST;
wire     [3:0]               int_INITIATOR_AWCACHE;
wire     [1:0]               int_INITIATOR_AWLOCK;
wire     [2:0]               int_INITIATOR_AWSIZE;
wire     [2:0]               int_INITIATOR_AWPROT;
wire     [3:0]               int_INITIATOR_AWQOS;
wire     [3:0]               int_INITIATOR_AWREGION;
wire     [USER_WIDTH - 1:0]  int_INITIATOR_AWUSER;

wire                         int_INITIATOR_AWREADY; // from wrCmdFifoWriteCtrl

wire [7:0] targetLen_M1;
wire [5:0] initiator_ADDR_masked;
wire [5:0] second_Beat_Addr;
wire       sizeCnt_comb_EQ_SizeMax;
wire [5:0] sizeCnt_comb_P1;


/// I/O_End <<<---



wire [CMD_FIFO_DATA_WIDTH-1:0] preHold_wrCmdFifoRdData;
wire						   preHold_wrCmdFifoEmpty;
wire 						   postHold_wrCmdFifore;
wire [ADDR_WIDTH - 1:0]        INITIATOR_AWADDR_mux;
wire                           wrcmd_full;
wire                           bresp_full;

wire                           cfifo_rst;

assign cfifo_rst = (SYNC_RESET == 0) ? arst_sync : srst_sync; 


/// Components_Start --->>>

generate 
// File: caxi4interconnect_FIFO.v
	if(PIPE > 0) begin 
	   localparam  FIFO_SIZE = ($clog2(ADDR_FIFO_DEPTH) < 2) ? 4 : ADDR_FIFO_DEPTH;
	   wire        wrcmdfifowrdata_wrrdy; 
	   wire        prehold_wrcmdfiforddata_rdvld; 
	
       caxi4c_coreaxi4s_fifo #
       (
          .RESET_TYPE         (SYNC_RESET),//
          .SYNC               (1),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
          .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
          .ECC                (0),// 0: ECC disable , 1: ECC enable
          .RAM_TYPE           (DWC_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
          .NUM_STAGES         (0),// To select number of synchronizer stages.
          .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
          .WFIFO_DEPTH        (FIFO_SIZE),
          .RFIFO_DEPTH        (FIFO_SIZE),
          .AXIS_TTDATA_WIDTH  (CMD_FIFO_DATA_WIDTH), // Bytes
          .AXIS_ITDATA_WIDTH  (CMD_FIFO_DATA_WIDTH),  // Bytes
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
       ) rdCmdFifo_fwft
       (
          .AXI4S_ACLK         (ACLK),
          .AXI4S_IACLK        (ACLK),
          .AXI4S_TACLK        (ACLK),
          .AXI4S_ARESETN      (cfifo_rst),
          .AXI4S_IARESETN     (cfifo_rst),
          .AXI4S_TARESETN     (cfifo_rst),
          .AXI4S_ITREADY      (postHold_wrCmdFifore),
          .AXI4S_ITVALID      (prehold_wrcmdfiforddata_rdvld),
          .AXI4S_ITDATA       (preHold_wrCmdFifoRdData[CMD_FIFO_DATA_WIDTH-1:0]),
          .AXI4S_TTVALID      (wrCmdFifowe ),
          .AXI4S_TTDATA       (wrCmdFifowrData[CMD_FIFO_DATA_WIDTH-1:0]),
          .ALMOST_FULL        (wrcmdfifowrdata_wrrdy)
       );	    
	  assign preHold_wrCmdFifoEmpty    = ~prehold_wrcmdfiforddata_rdvld;
	  assign wrCmdFifoNearlyFull       = wrcmdfifowrdata_wrrdy;
	end else begin	
      defparam wrCmdFifo.DATA_WIDTH_IN = CMD_FIFO_DATA_WIDTH;
      defparam wrCmdFifo.DATA_WIDTH_OUT = CMD_FIFO_DATA_WIDTH;
      defparam wrCmdFifo.MEM_DEPTH = ADDR_FIFO_DEPTH;
      defparam wrCmdFifo.NEARLY_FULL_THRESH = ADDR_FIFO_DEPTH-1;

      caxi4interconnect_FIFO wrCmdFifo( 
                  .data_in(wrCmdFifowrData[CMD_FIFO_DATA_WIDTH-1:0]),
                  .fifo_full(),
                  .fifo_nearly_full(wrCmdFifoNearlyFull),
                  .fifo_one_from_full(),
                  .wr_en(wrCmdFifowe),
                  .zero_data(1'b0),
                  .data_out(preHold_wrCmdFifoRdData[CMD_FIFO_DATA_WIDTH-1:0]),
                  .fifo_empty(preHold_wrCmdFifoEmpty),
                  .fifo_nearly_empty(),
                  .rd_en(postHold_wrCmdFifore),
                  .clk(ACLK),
                  .arst(arst_sync), 
                  .srst(srst_sync) 
				  );

    end 
endgenerate 

// File: caxi4interconnect_DWC_DownConv_Hold_Reg_Wr.v

defparam caxi4interconnect_DWC_DownConv_Hold_Reg_Wr.CMD_FIFO_DATA_WIDTH = CMD_FIFO_DATA_WIDTH;
defparam caxi4interconnect_DWC_DownConv_Hold_Reg_Wr.ID_WIDTH = ID_WIDTH;

caxi4interconnect_DWC_DownConv_Hold_Reg_Wr caxi4interconnect_DWC_DownConv_Hold_Reg_Wr(
                .ACLK(ACLK), // INPUT
                .arst_sync(arst_sync), // INPUT
                .srst_sync(srst_sync), // INPUT
                
                .DWC_DownConv_hold_data_in(preHold_wrCmdFifoRdData[CMD_FIFO_DATA_WIDTH-1:0]), // INPUT
                .DWC_DownConv_hold_fifo_empty(preHold_wrCmdFifoEmpty), // INPUT

                .DWC_DownConv_hold_get_next_data(wrCmdFifore), // INPUT

                .DWC_DownConv_hold_fifo_rd_en(postHold_wrCmdFifore), // OUTPUT
                .DWC_DownConv_hold_data_out(wrCmdFifoRdData[CMD_FIFO_DATA_WIDTH-1:0]), // OUTPUT
                .DWC_DownConv_hold_reg_empty(wrCmdFifoEmpty), // OUTPUT

                .targetLen_M1               ( targetLen_M1), // OUTPUT
                .initiator_ADDR_masked        ( initiator_ADDR_masked ), // OUTPUT
                .second_Beat_Addr          ( second_Beat_Addr ), // OUTPUT
                .sizeCnt_comb_EQ_SizeMax   ( sizeCnt_comb_EQ_SizeMax ), // OUTPUT
                .sizeCnt_comb_P1           ( sizeCnt_comb_P1) // OUTPUT
                );

// File: widthConvwr.v

defparam widthConvwr.ID_WIDTH = ID_WIDTH;
defparam widthConvwr.DATA_WIDTH_IN = DATA_WIDTH_IN;
defparam widthConvwr.DATA_WIDTH_OUT = DATA_WIDTH_OUT;
defparam widthConvwr.CMD_FIFO_DATA_WIDTH = CMD_FIFO_DATA_WIDTH;
defparam widthConvwr.STRB_WIDTH_IN = STRB_WIDTH_IN;
defparam widthConvwr.USER_WIDTH = USER_WIDTH;
defparam widthConvwr.STRB_WIDTH_OUT = STRB_WIDTH_OUT;

caxi4interconnect_DWC_DownConv_widthConvwr widthConvwr(
                         .ACLK(ACLK),
                         .arst_sync(arst_sync),
                         .srst_sync(srst_sync),
                         .wrCmdFifoEmpty(wrCmdFifoEmpty),
                         .wrCmdFifoRdData(wrCmdFifoRdData),
                         .wrCmdFifore(wrCmdFifore),
						 .INITIATOR_WID (INITIATOR_WID),
                         .INITIATOR_WDATA(INITIATOR_WDATA),
                         .INITIATOR_WREADY(INITIATOR_WREADY),
                         .INITIATOR_WSTRB(INITIATOR_WSTRB),
                         .INITIATOR_WUSER(INITIATOR_WUSER),
                         .INITIATOR_WVALID(INITIATOR_WVALID),
						 .TARGET_WID  (TARGET_WID),
                         .TARGET_WDATA(TARGET_WDATA),
                         .TARGET_WLAST(TARGET_WLAST),
                         .TARGET_WREADY(TARGET_WREADY),
                         .TARGET_WSTRB(TARGET_WSTRB),
                         .TARGET_WUSER(TARGET_WUSER),
                         .TARGET_WVALID(TARGET_WVALID),
                         
                         .targetLEN_M1               ( targetLen_M1),
                         .initiator_ADDR_masked        ( initiator_ADDR_masked ),
                         .second_Beat_Addr          ( second_Beat_Addr ),
                         .sizeCnt_comb_EQ_SizeMax   ( sizeCnt_comb_EQ_SizeMax ),
                         .sizeCnt_comb_P1           ( sizeCnt_comb_P1)
          );

genvar id_range; 
	
generate  

  if(READ_INTERLEAVE)
    begin 
  
      wire [TOTAL_IDS-1:0]  BRespFifoRdData;
	  
      defparam brespCtrl.ID_WIDTH = ID_WIDTH;
      defparam brespCtrl.USER_WIDTH = USER_WIDTH;

      caxi4interconnect_DWC_brespCtrl brespCtrl(
                           .TARGET_BREADY(TARGET_BREADY),
                           .TARGET_BRESP(TARGET_BRESP),
                           .TARGET_BUSER(TARGET_BUSER),
                           .TARGET_BVALID(TARGET_BVALID),
                           .TARGET_BID(TARGET_BID),
                           .BRespFifoRdData(BRespFifoRdData[TARGET_BID]),
                           .bresp_fifo_empty(brespFifoEmpty),
                           .brespFifore(brespFifore),
                           .ACLK(ACLK),
                           .arst_sync(arst_sync),
                           .srst_sync(srst_sync),
      
                           .INITIATOR_BID(INITIATOR_BID),
                           .INITIATOR_BREADY(INITIATOR_BREADY),
                           .INITIATOR_BRESP(INITIATOR_BRESP),
                           .INITIATOR_BUSER(INITIATOR_BUSER),
                           .INITIATOR_BVALID(INITIATOR_BVALID) );

      for(id_range = 0; id_range < TOTAL_IDS; id_range = id_range+1)
        begin 
	    
	    if(PIPE > 0) begin 
           localparam  FIFO_SIZE = ($clog2(ADDR_FIFO_DEPTH) < 2) ? 4 : ADDR_FIFO_DEPTH;
	       wire [TOTAL_IDS-1:0]  brespfifowrdata_wrrdy; 
	       wire [TOTAL_IDS-1:0]  brespfiforddata_rdvld; 
	    
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
           ) BrespCmdFifo_fwft
           (
              .AXI4S_ACLK         (ACLK),
              .AXI4S_IACLK        (ACLK),
              .AXI4S_TACLK        (ACLK),
              .AXI4S_ARESETN      (cfifo_rst),
              .AXI4S_IARESETN     (cfifo_rst),
              .AXI4S_TARESETN     (cfifo_rst),
              .AXI4S_ITREADY      (brespFifore & (TARGET_BID == id_range)),
              .AXI4S_ITVALID      (brespfiforddata_rdvld[id_range]),
              .AXI4S_ITDATA       (BRespFifoRdData[id_range]),
              .AXI4S_TTVALID      (wrCmdFifowe & (brespFifoWrData[ID_WIDTH:1] == id_range)),
              .AXI4S_TTDATA       (brespFifoWrData[0]),
              .ALMOST_FULL        (brespfifowrdata_wrrdy[id_range])
           );	    
	      assign brespFifoEmpty_temp[id_range] = ~brespfiforddata_rdvld[id_range];
	      assign brespFifoNearlyFull[id_range] = brespfifowrdata_wrrdy[id_range];
	    end else begin			
		
          caxi4interconnect_FIFO BrespCmdFifo( 
                       .data_in(brespFifoWrData[0]),
                       .fifo_full(),
                       .fifo_nearly_full(brespFifoNearlyFull[id_range]),
                       .fifo_one_from_full(),
                       .wr_en(wrCmdFifowe & (brespFifoWrData[ID_WIDTH:1] == id_range)),
                       .zero_data(1'b0),
                       .data_out(BRespFifoRdData[id_range]),
                       .fifo_empty(brespFifoEmpty_temp[id_range]),
                       .fifo_nearly_empty(),
                       .rd_en(brespFifore & (TARGET_BID == id_range)),
                       .clk(ACLK),
                       .arst(arst_sync),
                       .srst(srst_sync)
					   );
	    			   
          defparam BrespCmdFifo.DATA_WIDTH_IN = 1;
          defparam BrespCmdFifo.DATA_WIDTH_OUT = 1;
          defparam BrespCmdFifo.MEM_DEPTH = ADDR_FIFO_DEPTH;
          defparam BrespCmdFifo.NEARLY_FULL_THRESH = ADDR_FIFO_DEPTH-1;				   
        end 	 
		
        assign brespFifoEmpty = INITIATOR_BVALID ? brespFifoEmpty_temp[INITIATOR_BID] : brespFifoEmpty_temp[TARGET_BID];		
		assign wrcmd_full     = wrCmdFifoNearlyFull;
		assign bresp_full     = (|brespFifoNearlyFull);
	  end 
	end 
  else 
    begin 
	
	  wire [ID_WIDTH:0]   BRespFifoRdData;
	  
	  defparam brespCtrl.ID_WIDTH = ID_WIDTH;
      defparam brespCtrl.USER_WIDTH = USER_WIDTH;
  
	  caxi4interconnect_DWC_brespCtrl brespCtrl(
                     .TARGET_BREADY(TARGET_BREADY),
                     .TARGET_BRESP(TARGET_BRESP),
                     .TARGET_BUSER(TARGET_BUSER),
                     .TARGET_BVALID(TARGET_BVALID),
                     .TARGET_BID(BRespFifoRdData[ID_WIDTH:1]),										   
                     .BRespFifoRdData(BRespFifoRdData[0]),
                     .bresp_fifo_empty(brespFifoEmpty),
                     .brespFifore(brespFifore),
                     .ACLK(ACLK),
                     .arst_sync(arst_sync),
                     .srst_sync(srst_sync),

                     .INITIATOR_BID(INITIATOR_BID),
                     .INITIATOR_BREADY(INITIATOR_BREADY),
                     .INITIATOR_BRESP(INITIATOR_BRESP),
                     .INITIATOR_BUSER(INITIATOR_BUSER),
                     .INITIATOR_BVALID(INITIATOR_BVALID) );
					 
	  if(PIPE > 0) begin 
	     localparam  FIFO_SIZE = ($clog2(ADDR_FIFO_DEPTH) < 2) ? 4 : ADDR_FIFO_DEPTH;
	     wire  brespfifowrdata_wrrdy; 
	     wire  brespfiforddata_rdvld; 
	    
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
            .AXIS_TTDATA_WIDTH  (1+ID_WIDTH), // Bytes
            .AXIS_ITDATA_WIDTH  (1+ID_WIDTH),  // Bytes
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
         ) BrespCmdFifo_fwft
         (
            .AXI4S_ACLK         (ACLK),
            .AXI4S_IACLK        (ACLK),
            .AXI4S_TACLK        (ACLK),
            .AXI4S_ARESETN      (cfifo_rst),
            .AXI4S_IARESETN     (cfifo_rst),
            .AXI4S_TARESETN     (cfifo_rst),
            .AXI4S_ITREADY      (brespFifore),
            .AXI4S_ITVALID      (brespfiforddata_rdvld),
            .AXI4S_ITDATA       (BRespFifoRdData),
            .AXI4S_TTVALID      (wrCmdFifowe),
            .AXI4S_TTDATA       (brespFifoWrData),
            .ALMOST_FULL        (brespfifowrdata_wrrdy)
         );	    
	     assign brespFifoEmpty      = ~brespfiforddata_rdvld;
	     assign brespFifoNearlyFull = brespfifowrdata_wrrdy;
	  end else begin	
// File: caxi4interconnect_FIFO.v

      defparam BrespCmdFifo.DATA_WIDTH_IN = 1+ID_WIDTH;
      defparam BrespCmdFifo.DATA_WIDTH_OUT = 1+ID_WIDTH;
      defparam BrespCmdFifo.MEM_DEPTH = ADDR_FIFO_DEPTH;
      defparam BrespCmdFifo.NEARLY_FULL_THRESH = ADDR_FIFO_DEPTH-1;
	  
      caxi4interconnect_FIFO BrespCmdFifo( 
                         .data_in(brespFifoWrData),
                         .fifo_full(),
                         .fifo_nearly_full(brespFifoNearlyFull),
                         .fifo_one_from_full(),
                         .wr_en(wrCmdFifowe),
                         .zero_data(1'b0),
                         .data_out(BRespFifoRdData),
                         .fifo_empty(brespFifoEmpty),
                         .fifo_nearly_empty(),
                         .rd_en(brespFifore),
                         .clk(ACLK),
                         .arst(arst_sync), 
                         .srst(srst_sync) 
						 );
	  end 
	  
      assign wrcmd_full     = wrCmdFifoNearlyFull;
	  assign bresp_full     = brespFifoNearlyFull;
	  

	end 
	
endgenerate 	

// File: CmdFifoWriteCtrl.v

defparam wrCmdFifoWriteCtrl.ADDR_WIDTH = ADDR_WIDTH;
defparam wrCmdFifoWriteCtrl.CMD_FIFO_DATA_WIDTH = CMD_FIFO_DATA_WIDTH;
defparam wrCmdFifoWriteCtrl.ID_WIDTH = ID_WIDTH;
defparam wrCmdFifoWriteCtrl.USER_WIDTH = USER_WIDTH;
defparam wrCmdFifoWriteCtrl.DATA_WIDTH_IN = DATA_WIDTH_IN;
defparam wrCmdFifoWriteCtrl.DATA_WIDTH_OUT = DATA_WIDTH_OUT;
defparam wrCmdFifoWriteCtrl.READ_INTERLEAVE = READ_INTERLEAVE;

caxi4interconnect_DWC_DownConv_CmdFifoWriteCtrl wrCmdFifoWriteCtrl( 
                                     .INITIATOR_AADDR(int_INITIATOR_AWADDR),
                                     .INITIATOR_ABURST(int_INITIATOR_AWBURST),
                                     .INITIATOR_ACACHE(int_INITIATOR_AWCACHE),
                                     .INITIATOR_AID(int_INITIATOR_AWID),
                                     .INITIATOR_ALOCK(int_INITIATOR_AWLOCK),
                                     .INITIATOR_APROT(int_INITIATOR_AWPROT),
                                     .INITIATOR_AQOS(int_INITIATOR_AWQOS),
                                     
                                     .INITIATOR_AREADY(int_INITIATOR_AWREADY), // output from module
                                     
                                     .INITIATOR_AREGION(int_INITIATOR_AWREGION),
                                     .INITIATOR_ASIZE(int_INITIATOR_AWSIZE),
                                     .INITIATOR_AUSER(int_INITIATOR_AWUSER),
                                     .INITIATOR_AVALID(int_INITIATOR_AWVALID),
                                     .CmdFifoNearlyFull(wrcmd_full),
                                     .FifoWe(wrCmdFifowe),
                                     .CmdFifoWrData(wrCmdFifowrData[CMD_FIFO_DATA_WIDTH-1:0]),
                                     .brespFifoWrData(brespFifoWrData),
                                     .brespFifoNearlyFull(bresp_full),
                                     .ACLK(ACLK),
                                     .arst_sync(arst_sync),
                                     .srst_sync(srst_sync),

                                     // .to_boundary_conv            ( to_boundary_conv_pre ),
                                     .to_boundary_initiator            ( to_boundary_initiator_pre ),
                                     .mask_addr                   ( mask_addr_pre ),
                                     .ASIZE                       ( ASIZE_pre ),
                                     // .tot_len_M_to_boundary_conv  ( tot_len_M_to_boundary_conv_pre ),
                                     // .to_boundary_conv_M1         ( to_boundary_conv_M1_pre ),
                                     .tot_len                     ( tot_len_pre ),
                                     .max_length_comb             ( max_length_comb_pre ),
                                     .length_comb                 ( length_comb_pre ),
                                     // .tot_len_GT_max_length_comb  ( tot_len_GT_max_length_comb_pre ),
                                     // .tot_len_M_max_length_comb   ( tot_len_M_max_length_comb_pre ),
                                     // .tot_axi_len                 ( tot_axi_len_pre ),
                                     .WrapLogLen_comb             ( wrap_log_len_comb_pre ),
                                     .SizeMax                     ( sizeMax_pre ),
                                     .SameInitrTrgtSize              ( SameInitrTrgtSize_pre ),
                                     .sizeCnt_comb                ( sizeCnt_comb_pre ),
                                     .INITIATOR_AADDR_mux (INITIATOR_AWADDR_mux),
				                     .fixed_burst                 ( fixed_burst),
                                     .unaligned_fixed_len_iter    (unaligned_fixed_len_iter),

                                     .TARGET_AADDR(TARGET_AWADDR),
                                     .TARGET_ABURST(TARGET_AWBURST),
                                     .TARGET_ACACHE(TARGET_AWCACHE),
                                     .TARGET_AID(TARGET_AWID),
                                     .TARGET_ALEN(TARGET_AWLEN),
                                     .TARGET_ALOCK(TARGET_AWLOCK),
                                     .TARGET_APROT(TARGET_AWPROT),
                                     .TARGET_AQOS(TARGET_AWQOS),
                                     .TARGET_AREADY(TARGET_AWREADY),
                                     .TARGET_AREGION(TARGET_AWREGION),
                                     .TARGET_ASIZE(TARGET_AWSIZE), // Longest path is here
                                     .TARGET_AUSER(TARGET_AWUSER),
                                     .TARGET_AVALID(TARGET_AWVALID) 
                                     );

// File: caxi4interconnect_DWC_DownConv_preCalcCmdFifoWrCtrl.v

caxi4interconnect_DWC_DownConv_preCalcCmdFifoWrCtrl #
                                 (
                                .DATA_WIDTH_OUT ( DATA_WIDTH_OUT ),
                                .DATA_WIDTH_IN ( DATA_WIDTH_IN ),
                                .ADDR_WIDTH( ADDR_WIDTH ),
                                .USER_WIDTH( USER_WIDTH ),
                                .ID_WIDTH( ID_WIDTH ),
								.WRITE_ENABLE (1'b1)   // 1 - Write 0 - Read 

                                )
    DWC_DownConv_preCalcCmdFifoWrCtrl_inst  (
                                .clk( ACLK ),
                                .arst_sync( arst_sync ),
                                .srst_sync( srst_sync ),
                                
                                
                                 .INITIATOR_ALEN_in    ( INITIATOR_AWLEN ),
                                 .INITIATOR_AADDR_in   (INITIATOR_AWADDR),
                                 .INITIATOR_ABURST_in  (INITIATOR_AWBURST),
                                 .INITIATOR_ACACHE_in  (INITIATOR_AWCACHE),
                                 .INITIATOR_AID_in     (INITIATOR_AWID),
                                 .INITIATOR_ALOCK_in   (INITIATOR_AWLOCK),
                                 .INITIATOR_APROT_in   (INITIATOR_AWPROT),
                                 .INITIATOR_AQOS_in    (INITIATOR_AWQOS),
                                 .INITIATOR_AREGION_in (INITIATOR_AWREGION),
                                 .INITIATOR_ASIZE_in   (INITIATOR_AWSIZE),
                                 .INITIATOR_AUSER_in   (INITIATOR_AWUSER),
                                 .INITIATOR_AVALID_in  (INITIATOR_AWVALID),
                                 
                                 .INITIATOR_AREADY_in(int_INITIATOR_AWREADY), // from ctrl

                                 .INITIATOR_ALEN_out(int_INITIATOR_AWLEN ),
                                 .INITIATOR_AADDR_out(int_INITIATOR_AWADDR),
                                 .INITIATOR_ABURST_out(int_INITIATOR_AWBURST),
                                 .INITIATOR_ACACHE_out(int_INITIATOR_AWCACHE),
                                 .INITIATOR_AID_out(int_INITIATOR_AWID),
                                 .INITIATOR_ALOCK_out(int_INITIATOR_AWLOCK),
                                 .INITIATOR_APROT_out(int_INITIATOR_AWPROT),
                                 .INITIATOR_AQOS_out(int_INITIATOR_AWQOS),
                                 .INITIATOR_AREGION_out(int_INITIATOR_AWREGION),
                                 .INITIATOR_ASIZE_out(int_INITIATOR_AWSIZE),
                                 .INITIATOR_AUSER_out(int_INITIATOR_AWUSER),
                                 .INITIATOR_AVALID_out(int_INITIATOR_AWVALID),

                                 .INITIATOR_AREADY_out(INITIATOR_AWREADY), // to source

                                .INITIATOR_AADDR_mux_pre (INITIATOR_AWADDR_mux),                                
                                // .to_boundary_conv_pre           ( to_boundary_conv_pre ),
                                .to_boundary_initiator_pre           ( to_boundary_initiator_pre ),
                                .mask_addr_pre                  ( mask_addr_pre ),
                                .ASIZE_pre                      ( ASIZE_pre ),
                                // .tot_len_M_to_boundary_conv_pre ( tot_len_M_to_boundary_conv_pre ),
                                // .to_boundary_conv_M1_pre        ( to_boundary_conv_M1_pre ),
                                .tot_len_pre                    ( tot_len_pre ),
                                .max_length_comb_pre            ( max_length_comb_pre ),
																.length_comb_pre								( length_comb_pre ),
                                // .tot_len_GT_max_length_comb_pre ( tot_len_GT_max_length_comb_pre ),
                                // .tot_len_M_max_length_comb_pre  ( tot_len_M_max_length_comb_pre ),
                                // .tot_axi_len_pre                ( tot_axi_len_pre ),
                                .WrapLogLen_comb_pre            ( wrap_log_len_comb_pre ),
                                .sizeMax_pre                    ( sizeMax_pre ),
                                .SameInitrTrgtSize_pre             ( SameInitrTrgtSize_pre ),
                                .sizeCnt_comb_pre               ( sizeCnt_comb_pre ),
                                .fixed_burst_pre                ( fixed_burst),
                                .unaligned_fixed_len_iter_pre   ( unaligned_fixed_len_iter)
                                );




/// Components_End <<<---


endmodule
