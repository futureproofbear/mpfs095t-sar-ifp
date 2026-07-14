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
module caxi4interconnect_DWC_DownConv_readWidthConv( INITIATOR_ARADDR,
                      INITIATOR_ARBURST,
                      INITIATOR_ARCACHE,
                      INITIATOR_ARID,
                      INITIATOR_ARLEN,
                      INITIATOR_ARLOCK,
                      INITIATOR_ARPROT,
                      INITIATOR_ARQOS,
                      INITIATOR_ARREADY,
                      INITIATOR_ARREGION,
                      INITIATOR_ARSIZE,
                      INITIATOR_ARUSER,
                      INITIATOR_ARVALID,
                      INITIATOR_RDATA,
                      INITIATOR_RID,
                      INITIATOR_RLAST,
                      INITIATOR_RREADY,
                      INITIATOR_RRESP,
                      INITIATOR_RUSER,
                      INITIATOR_RVALID,
                      TARGET_RDATA,
                      TARGET_RID,
                      TARGET_RLAST,
                      TARGET_RREADY,
                      TARGET_RRESP,
                      TARGET_RUSER,
                      TARGET_RVALID,
                      TARGET_ARADDR,
                      TARGET_ARBURST,
                      TARGET_ARCACHE,
                      TARGET_ARID,
                      TARGET_ARLEN,
                      TARGET_ARLOCK,
                      TARGET_ARPROT,
                      TARGET_ARQOS,
                      TARGET_ARREADY,
                      TARGET_ARREGION,
                      TARGET_ARVALID,
                      TARGET_ASIZE,
                      TARGET_AUSER,
                      ACLK,
                      arst_sync, 
                      srst_sync 
					  );

parameter DATA_WIDTH_IN       = 32; 
parameter ADDR_FIFO_DEPTH     = 3; 
parameter CMD_FIFO_DATA_WIDTH = 29; 
parameter DATA_WIDTH_OUT      = 32; 
parameter ADDR_WIDTH          = 20; 
parameter ID_WIDTH            = 1; 
parameter USER_WIDTH          = 1; 
parameter READ_INTERLEAVE     = 0; 
parameter PIPE                = 1;
parameter DWC_RAM_TYPE        = 3;
parameter SYNC_RESET          = 0;



localparam  TOTAL_IDS   = READ_INTERLEAVE ? (2 ** ID_WIDTH) : 1;


// Port: INITIATOR_ARChan

input [ADDR_WIDTH-1:0] INITIATOR_ARADDR;
input [1:0]    INITIATOR_ARBURST;
input [3:0]    INITIATOR_ARCACHE;
input [ID_WIDTH-1:0] INITIATOR_ARID;
input [7:0]    INITIATOR_ARLEN;
input [1:0]    INITIATOR_ARLOCK;
input [2:0]    INITIATOR_ARPROT;
input [3:0]    INITIATOR_ARQOS;
output         INITIATOR_ARREADY;
input [3:0]    INITIATOR_ARREGION;
input [2:0]    INITIATOR_ARSIZE;
input [USER_WIDTH-1:0] INITIATOR_ARUSER;
input          INITIATOR_ARVALID;

// Port: INITIATOR_RChan

output [DATA_WIDTH_OUT-1:0] INITIATOR_RDATA;   
output [ID_WIDTH-1:0]       INITIATOR_RID;     
output                      INITIATOR_RLAST;
input                       INITIATOR_RREADY;
output [1:0]                INITIATOR_RRESP;
output [USER_WIDTH-1:0]     INITIATOR_RUSER;
output                      INITIATOR_RVALID;

// Port: TARGET_RChan

input [DATA_WIDTH_IN-1:0] TARGET_RDATA;
input [ID_WIDTH-1:0] TARGET_RID;
input          TARGET_RLAST;
output         TARGET_RREADY;
input [1:0]    TARGET_RRESP;
input [USER_WIDTH-1:0] TARGET_RUSER;
input          TARGET_RVALID;

// Port: TARGET_ARChan

output [ADDR_WIDTH-1:0] TARGET_ARADDR;
output [1:0]   TARGET_ARBURST;
output [3:0]   TARGET_ARCACHE;
output [ID_WIDTH-1:0] TARGET_ARID;
output [7:0]   TARGET_ARLEN;
output [1:0]   TARGET_ARLOCK;
output [2:0]   TARGET_ARPROT;
output [3:0]   TARGET_ARQOS;
input          TARGET_ARREADY;
output [3:0]   TARGET_ARREGION;
output         TARGET_ARVALID;
output [2:0]   TARGET_ASIZE;
output [USER_WIDTH-1:0] TARGET_AUSER;

// Port: system

input          ACLK;
input          arst_sync;
input          srst_sync;



/// I/O_End <<<---



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

wire from_ctrl_TARGET_ARREADY;



wire     [7:0]               int_INITIATOR_ARLEN;
wire                         int_INITIATOR_ARVALID;
wire     [ID_WIDTH - 1:0]    int_INITIATOR_ARID;
wire     [ADDR_WIDTH - 1:0]  int_INITIATOR_ARADDR;
wire     [1:0]               int_INITIATOR_ARBURST;
wire     [3:0]               int_INITIATOR_ARCACHE;
wire     [1:0]               int_INITIATOR_ARLOCK;
wire     [2:0]               int_INITIATOR_ARSIZE;
wire     [2:0]               int_INITIATOR_ARPROT;
wire     [3:0]               int_INITIATOR_ARQOS;
wire     [3:0]               int_INITIATOR_ARREGION;
wire     [USER_WIDTH - 1:0]  int_INITIATOR_ARUSER;

wire                           int_INITIATOR_ARREADY; // from wrCmdFifoWriteCtrl
wire [ID_WIDTH-1:0]            INITIATOR_SEL;
wire [TOTAL_IDS-1:0]           INITIATOR_RVALID_Temp;
wire [CMD_FIFO_DATA_WIDTH-1:0] CmdFifowrData;
wire [ADDR_WIDTH - 1:0]        INITIATOR_ARADDR_mux;
wire                           wr_en;
wire                           cmdfifo_full;
wire                           fixed_burst;
wire [6:0]                     unaligned_fixed_len_iter;

wire                           cfifo_rst;

assign cfifo_rst = (SYNC_RESET == 0) ? arst_sync : srst_sync; 
 
/// Components_Start --->>>
genvar i;

generate// File: caxi4interconnect_FIFO.v

if(READ_INTERLEAVE)
  begin 
  
    
    wire [CMD_FIFO_DATA_WIDTH-1:0] rdCmdFifoReadData [TOTAL_IDS-1:0];
    wire [TOTAL_IDS-1:0]           rdCmdFifore;
    wire [TOTAL_IDS-1:0]           rdCmdFifoEmpty;

    
    wire [CMD_FIFO_DATA_WIDTH-1:0] preHold_rdCmdFifoReadData [TOTAL_IDS-1:0];
    wire [TOTAL_IDS-1:0]		   preHold_rdCmdFifoEmpty;
    wire [TOTAL_IDS-1:0] 		   postHold_rdCmdFifore;
  
    wire [5:0]           mask_intrSize              [TOTAL_IDS-1:0] ;
    wire [5:0]           mask_trgtSize              [TOTAL_IDS-1:0];
    wire [TOTAL_IDS-1:0] sizeCnt_comb_EQ_SizeMax;
    wire [5:0]           initiator_ADDR_masked        [TOTAL_IDS-1:0];
    wire [5:0]           second_Beat_Addr          [TOTAL_IDS-1:0];
    wire [5:0]           sizeCnt_comb_P1           [TOTAL_IDS-1:0];
    wire [6:0]           targetSize_one_hot         [TOTAL_IDS-1:0];
    wire [5:0]           sizeMax_extend            [TOTAL_IDS-1:0];

    
    wire [DATA_WIDTH_OUT - 1:0]       shifted_intr_mask_bit  [ TOTAL_IDS-1:0];
    wire [DATA_WIDTH_IN - 1:0]        shifted_trgt_mask_bit  [ TOTAL_IDS-1:0];
    wire [(DATA_WIDTH_OUT / 8) - 1:0] shifted_intr_mask_byte [ TOTAL_IDS-1:0];
    wire [(DATA_WIDTH_IN / 8) - 1:0]  shifted_trgt_mask_byte [ TOTAL_IDS-1:0];
    
    
    wire [DATA_WIDTH_OUT-1:0] INITIATOR_RDATA_Temp   [TOTAL_IDS-1:0];
    wire [ID_WIDTH-1:0]       INITIATOR_RID_Temp     [TOTAL_IDS-1:0];
    wire [TOTAL_IDS-1:0]      INITIATOR_RLAST_Temp;
    wire [1:0]                INITIATOR_RRESP_Temp   [TOTAL_IDS-1:0];
    wire [USER_WIDTH-1:0]     INITIATOR_RUSER_Temp   [TOTAL_IDS-1:0];
    
    wire [TOTAL_IDS-1:0]      TARGET_RREADY_Temp;
    reg  [TOTAL_IDS-1:0]      TARGET_RVALID_Temp;
    reg  [TOTAL_IDS-1:0]      TARGET_RLAST_Temp;
    reg  [DATA_WIDTH_IN-1:0]  TARGET_RDATA_Temp    [TOTAL_IDS-1:0];
    

    wire [TOTAL_IDS-1:0]      INITIATOR_DATA_READY_n;
    wire [TOTAL_IDS-1:0]      INITIATOR_DATA_READY;
	
    wire [TOTAL_IDS-1:0]      CmdFifoNearlyFull; 
	

	
    //reg  [ID_WIDTH:0]         id_range;
    integer                   id_range;
  
    for(i=0;i<TOTAL_IDS;i=i+1)
      begin 
		
	  if(PIPE > 0) begin 
	    localparam  FIFO_SIZE = ($clog2(ADDR_FIFO_DEPTH) < 2) ? 4 : ADDR_FIFO_DEPTH;
        wire [TOTAL_IDS-1:0]           cmdfifowrdata_wrrdy; 
        wire [TOTAL_IDS-1:0]           posthold_rdcmdfifo_rdvld; 			
		
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
           .AXI4S_ITREADY      (postHold_rdCmdFifore[i]),
           .AXI4S_ITVALID      (posthold_rdcmdfifo_rdvld[i]),
           .AXI4S_ITDATA       (preHold_rdCmdFifoReadData[i][CMD_FIFO_DATA_WIDTH-1:0]),
           .AXI4S_TTVALID      ((wr_en & (CmdFifowrData[30+ID_WIDTH-1:30] == i))),
           .AXI4S_TTDATA       (CmdFifowrData[CMD_FIFO_DATA_WIDTH-1:0]),
           .ALMOST_FULL        (cmdfifowrdata_wrrdy[i])
        );	    
		assign preHold_rdCmdFifoEmpty[i] = ~posthold_rdcmdfifo_rdvld[i];
		assign CmdFifoNearlyFull[i]      = cmdfifowrdata_wrrdy[i];
	  end else begin 

        defparam rdCmdFifo.DATA_WIDTH_IN = CMD_FIFO_DATA_WIDTH;
        defparam rdCmdFifo.DATA_WIDTH_OUT = CMD_FIFO_DATA_WIDTH;
        defparam rdCmdFifo.MEM_DEPTH = ADDR_FIFO_DEPTH;
        defparam rdCmdFifo.NEARLY_FULL_THRESH = ADDR_FIFO_DEPTH-1;
    
        caxi4interconnect_FIFO rdCmdFifo( .data_in(CmdFifowrData[CMD_FIFO_DATA_WIDTH-1:0]),
                        .fifo_full(),
                        .fifo_nearly_full(CmdFifoNearlyFull[i]),
                        .fifo_one_from_full(),
                        .wr_en((wr_en & (CmdFifowrData[30+ID_WIDTH-1:30] == i))),
                        .zero_data(1'b0),
                        .data_out(preHold_rdCmdFifoReadData[i][CMD_FIFO_DATA_WIDTH-1:0]),
                        .fifo_empty(preHold_rdCmdFifoEmpty[i]),
                        .fifo_nearly_empty(),
                        .rd_en(postHold_rdCmdFifore[i]),
                        .clk(ACLK),
                        .arst(arst_sync),
                        .srst(srst_sync)
						);
      end 
						
    // File: caxi4interconnect_DWC_DownConv_Hold_Reg_Rd.v
    
        defparam caxi4interconnect_DWC_DownConv_Hold_Reg_Rd.CMD_FIFO_DATA_WIDTH = CMD_FIFO_DATA_WIDTH;
        defparam caxi4interconnect_DWC_DownConv_Hold_Reg_Rd.ID_WIDTH = ID_WIDTH;
    
        caxi4interconnect_DWC_DownConv_Hold_Reg_Rd caxi4interconnect_DWC_DownConv_Hold_Reg_Rd(
                            .ACLK           (ACLK), // INPUT
                            .arst_sync       (arst_sync), // INPUT
                            .srst_sync       (srst_sync), // INPUT
        
                            .DWC_DownConv_hold_data_in        (preHold_rdCmdFifoReadData[i][CMD_FIFO_DATA_WIDTH-1:0]), // INPUT
                            .DWC_DownConv_hold_fifo_empty     (preHold_rdCmdFifoEmpty[i]), // INPUT
        
                            .DWC_DownConv_hold_get_next_data  (rdCmdFifore[i]), // INPUT
        
                            .DWC_DownConv_hold_fifo_rd_en    (postHold_rdCmdFifore[i]), // OUTPUT
                            .DWC_DownConv_hold_data_out      (rdCmdFifoReadData[i][CMD_FIFO_DATA_WIDTH-1:0]), // OUTPUT
                            .DWC_DownConv_hold_reg_empty     (rdCmdFifoEmpty[i]), // OUTPUT
        
                            .mask_trgtSize              ( mask_trgtSize[i]), // OUTPUT
                            .mask_intrSize              ( mask_intrSize[i]), // OUTPUT
                            .sizeCnt_comb_EQ_SizeMax   ( sizeCnt_comb_EQ_SizeMax[i] ), // OUTPUT
                            .initiator_ADDR_masked        ( initiator_ADDR_masked[i] ), // OUTPUT
                            .second_Beat_Addr          ( second_Beat_Addr[i] ), // OUTPUT
                            .sizeCnt_comb_P1           ( sizeCnt_comb_P1[i]), // OUTPUT
                            .targetSize_one_hot_hold    ( targetSize_one_hot[i]), // OUTPUT
                            .sizeMax_extend            ( sizeMax_extend[i]) // OUTPUT
                             );
        
    // File: widthConvrd.v
    
        defparam widthConvrd.DATA_WIDTH_IN = DATA_WIDTH_IN;
        defparam widthConvrd.DATA_WIDTH_OUT = DATA_WIDTH_OUT;
        defparam widthConvrd.ID_WIDTH = ID_WIDTH;
        defparam widthConvrd.USER_WIDTH = USER_WIDTH;
        defparam widthConvrd.CMD_FIFO_DATA_WIDTH = CMD_FIFO_DATA_WIDTH;
        defparam widthConvrd.READ_INTERLEAVE = READ_INTERLEAVE;
    
        caxi4interconnect_DWC_DownConv_widthConvrd widthConvrd( 
                                 .INITIATOR_RDATA        ( INITIATOR_RDATA_Temp[i] ),
                                 .INITIATOR_RID          ( INITIATOR_RID_Temp[i] ),
                                 .INITIATOR_RLAST        ( INITIATOR_RLAST_Temp[i] ),
                                 .INITIATOR_RREADY       ( INITIATOR_RREADY ),
                                 .INITIATOR_RRESP        ( INITIATOR_RRESP_Temp[i] ),
                                 .INITIATOR_RUSER        ( INITIATOR_RUSER_Temp[i] ),
                                 .INITIATOR_RVALID       ( INITIATOR_RVALID_Temp[i] ),
                                 .TARGET_RDATA         ( TARGET_RDATA_Temp[i] ),
                                 .TARGET_RLAST         ( TARGET_RLAST_Temp[i] ),
                                 .TARGET_RREADY        ( TARGET_RREADY_Temp[i] ),
                                 .TARGET_RRESP         ( TARGET_RRESP ),
                                 .TARGET_RUSER         ( TARGET_RUSER ),
                                 .TARGET_RVALID        ( TARGET_RVALID_Temp[i] ),
        						 .TARGET_RID           ( TARGET_RID    ),
                                 .rdCmdFifoReadData   ( rdCmdFifoReadData[i] ),
                                 .rdCmdFifore         ( rdCmdFifore[i] ),
                                 .rdCmdFifoEmpty      ( rdCmdFifoEmpty[i]),// | INITIATOR_DATA_READY[i] ),
                                 .ACLK                ( ACLK ),
                                 .arst_sync            ( arst_sync ),
                                 .srst_sync            ( srst_sync ),
                                 .shifted_trgt_mask_bit( shifted_trgt_mask_bit[i] ),
                                 .shifted_intr_mask_bit( shifted_intr_mask_bit[i] ),
                                 .shifted_trgt_mask_byte( shifted_trgt_mask_byte[i] ),
                                 .shifted_intr_mask_byte( shifted_intr_mask_byte[i] ),
        
                                 .mask_intrSize            ( mask_intrSize[i] ),
                                 .mask_trgtSize            ( mask_trgtSize[i] ),
                                 .sizeCnt_comb_EQ_SizeMax ( sizeCnt_comb_EQ_SizeMax[i] ),
                                 .initiator_ADDR_masked      ( initiator_ADDR_masked[i] ),
                                 .second_Beat_Addr        ( second_Beat_Addr[i] ),
                                 .sizeCnt_comb_P1         ( sizeCnt_comb_P1[i] ),
                                 .targetSize_one_hot       ( targetSize_one_hot[i] ),
                                 .sizeMax_extend          ( sizeMax_extend[i] ),
    							 .initiator_hold             (INITIATOR_RVALID & ~INITIATOR_RREADY)
                                 );
    
        defparam byte2bit_inst.DATA_WIDTH_IN = DATA_WIDTH_IN;
        defparam byte2bit_inst.DATA_WIDTH_OUT = DATA_WIDTH_OUT;
    
        caxi4interconnect_byte2bit byte2bit_inst( 
                                 .shifted_trgt_mask_bit( shifted_trgt_mask_bit[i] ),
                                 .shifted_intr_mask_bit( shifted_intr_mask_bit[i] ),
                                 .shifted_trgt_mask_byte( shifted_trgt_mask_byte[i] ),
                                 .shifted_intr_mask_byte( shifted_intr_mask_byte[i] )
        );	
      end   //END for loop 
	  
//Selection logic

      assign INITIATOR_RVALID                = (| INITIATOR_RVALID_Temp);
      assign INITIATOR_RDATA                 = INITIATOR_RDATA_Temp[INITIATOR_SEL];
      assign INITIATOR_RID                   = INITIATOR_RID_Temp  [INITIATOR_SEL];
      assign INITIATOR_RLAST                 = INITIATOR_RLAST_Temp[INITIATOR_SEL];
      assign INITIATOR_RRESP                 = INITIATOR_RRESP_Temp[INITIATOR_SEL];
      assign INITIATOR_RUSER                 = INITIATOR_RUSER_Temp[INITIATOR_SEL];
      assign TARGET_RREADY                 = INITIATOR_RVALID & ~INITIATOR_RREADY ? TARGET_RREADY_Temp[INITIATOR_RID] : TARGET_RREADY_Temp[TARGET_RID];
      
      always@(*)
        begin 
          TARGET_RVALID_Temp            = 0;
          TARGET_RVALID_Temp[TARGET_RID] = TARGET_RVALID; 
       
          TARGET_RLAST_Temp             = 0;
          TARGET_RLAST_Temp[TARGET_RID]  = TARGET_RLAST;  
        end 
      
      always@(*)
        begin 
          for(id_range=0; id_range<TOTAL_IDS;id_range=id_range+1)
      	  begin 
              TARGET_RDATA_Temp[id_range] = 0;
      	  end 
          TARGET_RDATA_Temp[TARGET_RID]    = TARGET_RDATA; 
        end   

      assign cmdfifo_full     = (| CmdFifoNearlyFull);
	end     //END Read Interleave	
  else 
	begin 

      wire [CMD_FIFO_DATA_WIDTH-1:0] rdCmdFifoReadData;
      wire           rdCmdFifore;
      wire           rdCmdFifoEmpty;
      
      wire [CMD_FIFO_DATA_WIDTH-1:0] preHold_rdCmdFifoReadData;
      wire			 preHold_rdCmdFifoEmpty;
      wire 			 postHold_rdCmdFifore;
	
      wire [5:0]  mask_intrSize;
      wire [5:0]  mask_trgtSize;
      wire        sizeCnt_comb_EQ_SizeMax;
      wire [5:0]  initiator_ADDR_masked;
      wire [5:0]  second_Beat_Addr;
      wire [5:0]  sizeCnt_comb_P1;
      wire [6:0]  targetSize_one_hot;
      wire [5:0]  sizeMax_extend;

      wire      [DATA_WIDTH_OUT - 1:0] shifted_intr_mask_bit;
      wire      [DATA_WIDTH_IN - 1:0] shifted_trgt_mask_bit;
      wire   [(DATA_WIDTH_OUT / 8) - 1:0] shifted_intr_mask_byte;
      wire    [(DATA_WIDTH_IN / 8) - 1:0] shifted_trgt_mask_byte;
	  
      wire                      CmdFifoNearlyFull;   
	  
	if(PIPE > 0) begin 
	
	   localparam  FIFO_SIZE = ($clog2(ADDR_FIFO_DEPTH) < 2) ? 4 : ADDR_FIFO_DEPTH;
	   
       wire        cmdfifowrdata_wrrdy; 
       wire        posthold_rdcmdfifo_rdvld; 			
	   
	
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
          .AXI4S_ITREADY      (postHold_rdCmdFifore),
          .AXI4S_ITVALID      (posthold_rdcmdfifo_rdvld),
          .AXI4S_ITDATA       (preHold_rdCmdFifoReadData[CMD_FIFO_DATA_WIDTH-1:0]),
          .AXI4S_TTVALID      (wr_en ),
          .AXI4S_TTDATA       (CmdFifowrData[CMD_FIFO_DATA_WIDTH-1:0]),
          .ALMOST_FULL        (cmdfifowrdata_wrrdy)
       );	    
	  assign preHold_rdCmdFifoEmpty    = ~posthold_rdcmdfifo_rdvld;
	  assign CmdFifoNearlyFull         = cmdfifowrdata_wrrdy;
	end else begin	  
      defparam rdCmdFifo.DATA_WIDTH_IN = CMD_FIFO_DATA_WIDTH;
      defparam rdCmdFifo.DATA_WIDTH_OUT = CMD_FIFO_DATA_WIDTH;
      defparam rdCmdFifo.MEM_DEPTH = ADDR_FIFO_DEPTH;
      defparam rdCmdFifo.NEARLY_FULL_THRESH = ADDR_FIFO_DEPTH-1;
      
      caxi4interconnect_FIFO rdCmdFifo( .data_in(CmdFifowrData[CMD_FIFO_DATA_WIDTH-1:0]),
                      .fifo_full(),
                      .fifo_nearly_full(CmdFifoNearlyFull),
                      .fifo_one_from_full(),
                      .wr_en(wr_en),
                      .zero_data(1'b0),
                      .data_out(preHold_rdCmdFifoReadData[CMD_FIFO_DATA_WIDTH-1:0]),
                      .fifo_empty(preHold_rdCmdFifoEmpty),
                      .fifo_nearly_empty(),
                      .rd_en(postHold_rdCmdFifore),
                      .clk(ACLK),
                      .arst(arst_sync),
                      .srst(srst_sync) );
	end   
// File: caxi4interconnect_DWC_DownConv_Hold_Reg_Rd.v

      defparam caxi4interconnect_DWC_DownConv_Hold_Reg_Rd.CMD_FIFO_DATA_WIDTH = CMD_FIFO_DATA_WIDTH;
      defparam caxi4interconnect_DWC_DownConv_Hold_Reg_Rd.ID_WIDTH = ID_WIDTH;
      
      caxi4interconnect_DWC_DownConv_Hold_Reg_Rd caxi4interconnect_DWC_DownConv_Hold_Reg_Rd(
                          .ACLK            (ACLK), // INPUT
                          .arst_sync       (arst_sync), // INPUT
                          .srst_sync       (srst_sync), // INPUT
      
                          .DWC_DownConv_hold_data_in        (preHold_rdCmdFifoReadData[CMD_FIFO_DATA_WIDTH-1:0]), // INPUT
                          .DWC_DownConv_hold_fifo_empty     (preHold_rdCmdFifoEmpty), // INPUT
      
                          .DWC_DownConv_hold_get_next_data  (rdCmdFifore), // INPUT
      
                          .DWC_DownConv_hold_fifo_rd_en    (postHold_rdCmdFifore), // OUTPUT
                          .DWC_DownConv_hold_data_out      (rdCmdFifoReadData[CMD_FIFO_DATA_WIDTH-1:0]), // OUTPUT
                          .DWC_DownConv_hold_reg_empty     (rdCmdFifoEmpty), // OUTPUT
      
                          .mask_trgtSize              ( mask_trgtSize), // OUTPUT
                          .mask_intrSize              ( mask_intrSize), // OUTPUT
                          .sizeCnt_comb_EQ_SizeMax   ( sizeCnt_comb_EQ_SizeMax ), // OUTPUT
                          .initiator_ADDR_masked        ( initiator_ADDR_masked ), // OUTPUT
                          .second_Beat_Addr          ( second_Beat_Addr ), // OUTPUT
                          .sizeCnt_comb_P1           ( sizeCnt_comb_P1), // OUTPUT
                          .targetSize_one_hot_hold    ( targetSize_one_hot), // OUTPUT
                          .sizeMax_extend            ( sizeMax_extend) // OUTPUT
                           );
						   
      defparam widthConvrd.DATA_WIDTH_IN = DATA_WIDTH_IN;
      defparam widthConvrd.DATA_WIDTH_OUT = DATA_WIDTH_OUT;
      defparam widthConvrd.ID_WIDTH = ID_WIDTH;
      defparam widthConvrd.USER_WIDTH = USER_WIDTH;
      defparam widthConvrd.CMD_FIFO_DATA_WIDTH = CMD_FIFO_DATA_WIDTH;
														 

      caxi4interconnect_DWC_DownConv_widthConvrd widthConvrd( 
                               .INITIATOR_RDATA        ( INITIATOR_RDATA ),
                               .INITIATOR_RID          ( INITIATOR_RID ),
                               .INITIATOR_RLAST        ( INITIATOR_RLAST ),
                               .INITIATOR_RREADY       ( INITIATOR_RREADY ),
                               .INITIATOR_RRESP        ( INITIATOR_RRESP ),
                               .INITIATOR_RUSER        ( INITIATOR_RUSER ),
                               .INITIATOR_RVALID       ( INITIATOR_RVALID ),
                               .TARGET_RDATA         ( TARGET_RDATA ),
                               .TARGET_RLAST         ( TARGET_RLAST ),
                               .TARGET_RREADY        ( TARGET_RREADY ),
                               .TARGET_RRESP         ( TARGET_RRESP ),
                               .TARGET_RUSER         ( TARGET_RUSER ),
                               .TARGET_RVALID        ( TARGET_RVALID ),
							   .TARGET_RID           (rdCmdFifoReadData[30+ID_WIDTH-1:30]),
      												 
                               .rdCmdFifoReadData   ( rdCmdFifoReadData ),
                               .rdCmdFifore         ( rdCmdFifore ),
                               .rdCmdFifoEmpty      ( rdCmdFifoEmpty ),
                               .ACLK                ( ACLK ),
                               .arst_sync            ( arst_sync ),
                               .srst_sync            ( srst_sync ),
                               .shifted_trgt_mask_bit( shifted_trgt_mask_bit ),
                               .shifted_intr_mask_bit( shifted_intr_mask_bit ),
                               .shifted_trgt_mask_byte( shifted_trgt_mask_byte ),
                               .shifted_intr_mask_byte( shifted_intr_mask_byte ),
      
                               .mask_intrSize            ( mask_intrSize ),
                               .mask_trgtSize            ( mask_trgtSize ),
                               .sizeCnt_comb_EQ_SizeMax ( sizeCnt_comb_EQ_SizeMax ),
                               .initiator_ADDR_masked      ( initiator_ADDR_masked ),
                               .second_Beat_Addr        ( second_Beat_Addr ),
                               .sizeCnt_comb_P1         ( sizeCnt_comb_P1 ),
                               .targetSize_one_hot       ( targetSize_one_hot ),
                               .sizeMax_extend          ( sizeMax_extend ),
							   .initiator_hold             ( 1'b0)
                               );
      
      defparam byte2bit_inst.DATA_WIDTH_IN = DATA_WIDTH_IN;
      defparam byte2bit_inst.DATA_WIDTH_OUT = DATA_WIDTH_OUT;
      
      caxi4interconnect_byte2bit byte2bit_inst( 
                               .shifted_trgt_mask_bit( shifted_trgt_mask_bit ),
                               .shifted_intr_mask_bit( shifted_intr_mask_bit ),
                               .shifted_trgt_mask_byte( shifted_trgt_mask_byte ),
                               .shifted_intr_mask_byte( shifted_intr_mask_byte )
      );	
	  
	  assign cmdfifo_full = CmdFifoNearlyFull;
	end 
endgenerate

//One hot to Binary conversion

genvar k,l;
generate
  if(READ_INTERLEAVE)
    begin 
      for (k=0; k<ID_WIDTH; k=k+1)
        begin 
      	  wire [TOTAL_IDS-1:0] tmp_mask;
      	  for (l=0; l<TOTAL_IDS; l=l+1)
      	    begin
      		  assign tmp_mask[l] = l[k];
      	    end	
      	  assign INITIATOR_SEL[k] = |(tmp_mask & INITIATOR_RVALID_Temp);
        end	
	end 
endgenerate

  




// File: CmdFifoWriteCtrl.v

defparam rdCmdFifoWriteCtrl.ADDR_WIDTH = ADDR_WIDTH;
defparam rdCmdFifoWriteCtrl.CMD_FIFO_DATA_WIDTH = CMD_FIFO_DATA_WIDTH;
defparam rdCmdFifoWriteCtrl.ID_WIDTH = ID_WIDTH;
defparam rdCmdFifoWriteCtrl.TOTAL_IDS = TOTAL_IDS;
defparam rdCmdFifoWriteCtrl.USER_WIDTH = USER_WIDTH;
defparam rdCmdFifoWriteCtrl.DATA_WIDTH_IN = DATA_WIDTH_OUT;
defparam rdCmdFifoWriteCtrl.DATA_WIDTH_OUT = DATA_WIDTH_IN;
defparam rdCmdFifoWriteCtrl.READ_INTERLEAVE = READ_INTERLEAVE;

caxi4interconnect_DWC_DownConv_CmdFifoWriteCtrl rdCmdFifoWriteCtrl( 
                                     .INITIATOR_AADDR        ( int_INITIATOR_ARADDR ),
                                     .INITIATOR_ABURST       ( int_INITIATOR_ARBURST ),
                                     .INITIATOR_ACACHE       ( int_INITIATOR_ARCACHE ),
                                     .INITIATOR_AID          ( int_INITIATOR_ARID  ),
                                     .INITIATOR_ALOCK        ( int_INITIATOR_ARLOCK ),
                                     .INITIATOR_APROT        ( int_INITIATOR_ARPROT ),
                                     .INITIATOR_AQOS         ( int_INITIATOR_ARQOS ),
                                     .INITIATOR_AREADY       ( int_INITIATOR_ARREADY ),
                                     .INITIATOR_AREGION      ( int_INITIATOR_ARREGION ),
                                     .INITIATOR_ASIZE        ( int_INITIATOR_ARSIZE ),
                                     .INITIATOR_AUSER        ( int_INITIATOR_ARUSER ),
                                     .INITIATOR_AVALID       ( int_INITIATOR_ARVALID ),
                                     .CmdFifoNearlyFull   ( cmdfifo_full ),
                                     .FifoWe              ( wr_en ),
                                     .CmdFifoWrData       ( CmdFifowrData[CMD_FIFO_DATA_WIDTH-1:0] ),
                                     .brespFifoWrData     ( ),
                                     .brespFifoNearlyFull ( 1'b0 ),
                                     .ACLK                ( ACLK ),
                                     .arst_sync            ( arst_sync ),
                                     .srst_sync            ( srst_sync ),
                                     
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
                                     .INITIATOR_AADDR_mux            ( INITIATOR_ARADDR_mux ),
									 .fixed_burst                 ( fixed_burst),
									 .unaligned_fixed_len_iter    ( unaligned_fixed_len_iter),
                                     
                                     .TARGET_AADDR         ( TARGET_ARADDR ),
                                     .TARGET_ABURST        ( TARGET_ARBURST ),
                                     .TARGET_ACACHE        ( TARGET_ARCACHE ),
                                     .TARGET_AID           ( TARGET_ARID ),
                                     .TARGET_ALEN          ( TARGET_ARLEN ),
                                     .TARGET_ALOCK         ( TARGET_ARLOCK ),
                                     .TARGET_APROT         ( TARGET_ARPROT ),
                                     .TARGET_AQOS          ( TARGET_ARQOS ),
                                     .TARGET_AREADY        ( TARGET_ARREADY ),
                                     .TARGET_AREGION       ( TARGET_ARREGION[3:0] ),
                                     .TARGET_ASIZE         ( TARGET_ASIZE ),
                                     .TARGET_AUSER         ( TARGET_AUSER ),
                                     .TARGET_AVALID        ( TARGET_ARVALID) 
                                     );


// File: caxi4interconnect_DWC_DownConv_preCalcCmdFifoWrCtrl.v

caxi4interconnect_DWC_DownConv_preCalcCmdFifoWrCtrl #
                                 (
                                .DATA_WIDTH_OUT ( DATA_WIDTH_IN ), // DATA_WIDTH_IN as it is in the read direction
                                .DATA_WIDTH_IN ( DATA_WIDTH_OUT ), // DATA_WIDTH_OUT as it is in the read direction
                                .ADDR_WIDTH( ADDR_WIDTH ),
                                .USER_WIDTH( USER_WIDTH ),
                                .ID_WIDTH( ID_WIDTH ),
								.WRITE_ENABLE (1'b0)   // 1 - Write 0 - Read 

                                )
    DWC_DownConv_preCalcCmdFifoWrCtrl_inst  (
                                .clk( ACLK ),
                                .arst_sync( arst_sync ),
                                .srst_sync( srst_sync ),
                                
                                
                                 .INITIATOR_ALEN_in    (  INITIATOR_ARLEN ),
                                 .INITIATOR_AADDR_in   ( INITIATOR_ARADDR ),
                                 .INITIATOR_ABURST_in  ( INITIATOR_ARBURST ),
                                 .INITIATOR_ACACHE_in  ( INITIATOR_ARCACHE ),
                                 .INITIATOR_AID_in     ( INITIATOR_ARID ),
                                 .INITIATOR_ALOCK_in   ( INITIATOR_ARLOCK ),
                                 .INITIATOR_APROT_in   ( INITIATOR_ARPROT ),
                                 .INITIATOR_AQOS_in    ( INITIATOR_ARQOS ),
                                 .INITIATOR_AREGION_in ( INITIATOR_ARREGION ),
                                 .INITIATOR_ASIZE_in   ( INITIATOR_ARSIZE ),
                                 .INITIATOR_AUSER_in   ( INITIATOR_ARUSER ),
                                 .INITIATOR_AVALID_in  ( INITIATOR_ARVALID ),
                                 
                                 .INITIATOR_AREADY_in  (  int_INITIATOR_ARREADY ), // from ctrl

                                 .INITIATOR_ALEN_out   ( int_INITIATOR_ARLEN  ),
                                 .INITIATOR_AADDR_out  ( int_INITIATOR_ARADDR ),
                                 .INITIATOR_ABURST_out ( int_INITIATOR_ARBURST ),
                                 .INITIATOR_ACACHE_out ( int_INITIATOR_ARCACHE ),
                                 .INITIATOR_AID_out    ( int_INITIATOR_ARID ),
                                 .INITIATOR_ALOCK_out  ( int_INITIATOR_ARLOCK ),
                                 .INITIATOR_APROT_out  ( int_INITIATOR_ARPROT ),
                                 .INITIATOR_AQOS_out   ( int_INITIATOR_ARQOS ),
                                 .INITIATOR_AREGION_out( int_INITIATOR_ARREGION ),
                                 .INITIATOR_ASIZE_out  ( int_INITIATOR_ARSIZE ),
                                 .INITIATOR_AUSER_out  ( int_INITIATOR_ARUSER ),
                                 .INITIATOR_AVALID_out ( int_INITIATOR_ARVALID ),
                                 .INITIATOR_AADDR_mux_pre ( INITIATOR_ARADDR_mux ),

                                 .INITIATOR_AREADY_out ( INITIATOR_ARREADY ), // to source

                                 
                                // .to_boundary_conv_pre           ( to_boundary_conv_pre ),
                                .to_boundary_initiator_pre           ( to_boundary_initiator_pre ),
                                .mask_addr_pre                  ( mask_addr_pre ),
                                .ASIZE_pre                      ( ASIZE_pre ),
                                // .tot_len_M_to_boundary_conv_pre ( tot_len_M_to_boundary_conv_pre ),
                                // .to_boundary_conv_M1_pre        ( to_boundary_conv_M1_pre ),
                                .tot_len_pre                    ( tot_len_pre ),
                                .max_length_comb_pre            ( max_length_comb_pre ),
                                .length_comb_pre                ( length_comb_pre ),
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
