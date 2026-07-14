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




module caxi4interconnect_DWC_UpConv_RChannel #

  (
    parameter integer       ID_WIDTH        = 1,
    parameter integer       USER_WIDTH      = 1,
    parameter integer       DATA_FIFO_DEPTH = 1024,
    parameter integer       ADDR_FIFO_DEPTH = 3,
    parameter integer       DATA_WIDTH_IN   = 32,
    parameter integer       DATA_WIDTH_OUT  = 32,
	parameter               READ_INTERLEAVE = 1,
	parameter integer       TOTAL_IDS       = (2 ** ID_WIDTH),
    parameter               PIPE            = 1,
    parameter               DWC_RAM_TYPE    = 3,
    parameter               SYNC_RESET      = 0

  )
  (

    input wire arst_sync,
    input wire srst_sync,
    input wire ACLK,

    // Input Write channel
    // Address R channel
    input wire [ID_WIDTH-1:0]             arid_intrr,
    input wire [5:0]                      araddr_intrr,
    input wire [7:0]                      arlen_intrr,

    // R channel
    input wire  [ID_WIDTH-1:0]            TARGET_RID,
    input wire  [DATA_WIDTH_IN-1:0]       TARGET_RDATA,
    input wire  [USER_WIDTH-1:0]          TARGET_RUSER,
    input wire                            TARGET_RLAST,
    input wire                            TARGET_RVALID,
    input wire  [1:0]                     TARGET_RRESP,
    output wire                           TARGET_RREADY,

    // R channel
    output wire [ID_WIDTH-1:0]            INITIATOR_RID,
    output wire [DATA_WIDTH_OUT-1:0]      INITIATOR_RDATA,
    output wire [USER_WIDTH-1:0]          INITIATOR_RUSER,
    output wire                           INITIATOR_RLAST,
    output wire                           INITIATOR_RVALID,
    output wire[1:0]                      INITIATOR_RRESP,
    input wire                            INITIATOR_RREADY,
    input wire [2:0]                      INITIATOR_RSIZE,

    output wire [TOTAL_IDS-1:0]           cmd_fifo_full,
    input wire                            wr_en_cmd,
    input wire                            extend_wrap,
    input wire                            wrap_flag,
    input wire [4:0]                      to_boundary_initiator,
    input wire				              fixed_flag
   );
  
  
    wire                 cfifo_rst;

    assign cfifo_rst = (SYNC_RESET == 0) ? arst_sync : srst_sync; 	

    localparam [31:0] EXTRA_DATA_WIDTH_ID = USER_WIDTH + ID_WIDTH + 2;
    localparam [31:0] EXTRA_DATA_WIDTH_USER = USER_WIDTH + 2;
    localparam [31:0] NEARLY_FULL_THRESH_VAL = DATA_FIFO_DEPTH - 1;
	
genvar i,k,l;   
generate

  if(READ_INTERLEAVE)
    begin 

      wire [TOTAL_IDS-1:0] rd_en_cmd_intr;
      wire [TOTAL_IDS-1:0] rd_en_cmd_intr_out;
      wire [TOTAL_IDS-1:0] rd_cmd_intr_fifo_full;
	    						 
      wire [TOTAL_IDS-1:0] rd_cmd_intr_fifo_empty;
      
      wire [TOTAL_IDS-1:0] rd_en_data;
      
      wire [TOTAL_IDS-1:0] data_hold;
      
      wire [($clog2(DATA_WIDTH_IN/DATA_WIDTH_OUT)-1):0] rd_src [TOTAL_IDS-1:0];
      
      wire [ID_WIDTH-1:0]             arid_intrr_out    [TOTAL_IDS-1:0];
      wire [5:0]                      araddr_intrr_out  [TOTAL_IDS-1:0];
      wire [7:0]                      arlen_intrr_out   [TOTAL_IDS-1:0];
      wire [2:0]                      INITIATOR_RSIZE_out [TOTAL_IDS-1:0];
      
      wire [TOTAL_IDS-1:0]            extend_wrap_out;
      wire [TOTAL_IDS-1:0]            wrap_flag_out;
      wire [4:0]                      to_boundary_initiator_out [TOTAL_IDS-1:0];
      wire [TOTAL_IDS-1:0]            fixed_flag_out;
      wire [5:0]                      rd_src_top       [TOTAL_IDS-1:0];
      
      
      
      wire [(DATA_WIDTH_OUT+ID_WIDTH+USER_WIDTH+2)-1:0]  fifo_data_out [TOTAL_IDS-1:0];
	    										
      
      wire [TOTAL_IDS-1:0]            data_fifo_empty;
	    				  
	    						   
      wire [TOTAL_IDS-1:0]            data_fifo_full;
      
//      wire [TOTAL_IDS-1:0]            rresp_fifo_empty;
	    				   
      //wire [TOTAL_IDS-1:0]            rresp_fifo_full;
      
      wire     [9:0]               addr_in [TOTAL_IDS-1:0];
      wire     [ID_WIDTH - 1:0]    arid_in [TOTAL_IDS-1:0];
      wire     [7:0]               INITIATOR_RLEN_in   [TOTAL_IDS-1:0];
      wire     [2:0]               INITIATOR_RSIZE_in  [TOTAL_IDS-1:0];
      wire     [TOTAL_IDS-1:0]     fixed_flag_in;
      wire     [TOTAL_IDS-1:0]     wrap_flag_in;
      wire     [4:0]               to_wrap_boundary_in [TOTAL_IDS-1:0];
      
      wire     [TOTAL_IDS-1:0]     INITIATOR_RLEN_eq_0_out;
      
      
      wire     [9:0]               mask_pre [TOTAL_IDS-1:0];
      wire     [9:0]               rd_src_shift_pre [TOTAL_IDS-1:0];
      
      wire     [TOTAL_IDS-1:0]     TARGET_RREADY_out;
      //wire     [1:0]               INITIATOR_RRESP_out [TOTAL_IDS-1:0];
      
      wire     [DATA_WIDTH_OUT-1:0] INITIATOR_RDATA_out [TOTAL_IDS-1:0];
      wire     [USER_WIDTH-1:0]     INITIATOR_RUSER_out [TOTAL_IDS-1:0];
      wire     [ID_WIDTH-1:0]       INITIATOR_RID_out   [TOTAL_IDS-1:0];
      wire     [TOTAL_IDS-1:0]      INITIATOR_RVALID_out;
      wire     [TOTAL_IDS-1:0]      INITIATOR_RLAST_out;
      wire     [ID_WIDTH-1:0]       INITIATOR_SEL;
      wire     [TOTAL_IDS-1:0]      INITIATOR_DATA_VALID_GRANT;
      reg                           arb_enable;
      reg      [ID_WIDTH-1:0]       count;
      reg                           count_dis;
      wire     [ID_WIDTH-1:0]       TARGET_RID_SEL;
      reg                           first_arb_comp;

	
      for (i=0; i<TOTAL_IDS; i=i+1)
        begin 	
		if(PIPE > 0) begin 
		  localparam  FIFO_SIZE = ($clog2(ADDR_FIFO_DEPTH) < 2) ? 4 : ADDR_FIFO_DEPTH;
		  wire [TOTAL_IDS-1:0] rdcmdfifo_itvld;
		  wire [TOTAL_IDS-1:0] rdcmdfifo_ttrdy;
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
             .AXIS_TTDATA_WIDTH  (18 + ID_WIDTH + 1 + 1 + 5), // Bytes
             .AXIS_ITDATA_WIDTH  (18 + ID_WIDTH + 1 + 1 + 5),  // Bytes
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
          ) rd_cmd_intr_fwft
          (
             .AXI4S_ACLK         (ACLK),
             .AXI4S_IACLK        (ACLK),
             .AXI4S_TACLK        (ACLK),
             .AXI4S_ARESETN      (cfifo_rst),
             .AXI4S_IARESETN     (cfifo_rst),
             .AXI4S_TARESETN     (cfifo_rst),
             .AXI4S_ITREADY      (rd_en_cmd_intr_out[i]),
             .AXI4S_ITVALID      (rdcmdfifo_itvld[i]),
             .AXI4S_ITDATA       ({to_boundary_initiator_out[i], extend_wrap_out[i], wrap_flag_out[i], fixed_flag_out[i], INITIATOR_RSIZE_out[i], arid_intrr_out[i], araddr_intrr_out[i], arlen_intrr_out[i]} ),
             .AXI4S_TTVALID      ((wr_en_cmd & (arid_intrr == i))),
             .AXI4S_TTDATA       ({to_boundary_initiator, extend_wrap, wrap_flag, fixed_flag, INITIATOR_RSIZE, arid_intrr, araddr_intrr, arlen_intrr}),
             .ALMOST_FULL        (rdcmdfifo_ttrdy[i])
          );
        assign cmd_fifo_full[i]         = rdcmdfifo_ttrdy[i];
        assign rd_cmd_intr_fifo_empty[i] = ~rdcmdfifo_itvld[i];
		
		end else begin 
	      caxi4interconnect_FIFO #
	  	  (
	  		.MEM_DEPTH            ( ADDR_FIFO_DEPTH ),
	  		.DATA_WIDTH_IN        ( 18 + ID_WIDTH + 1 + 1 + 5 ),
	  		.DATA_WIDTH_OUT       ( 18 + ID_WIDTH + 1 + 1 + 5 ), 
	  		.NEARLY_FULL_THRESH   ( ADDR_FIFO_DEPTH - 1 ), // Setting nearly full thresh to allow for 1 left in caxi4interconnect_FIFO
	  		.NEARLY_EMPTY_THRESH  ( 1 )
	  	  )
	      rd_cmd_intr (
	  		.arst                  (arst_sync ),
	  		.srst                  (srst_sync ),
	  		.clk                  ( ACLK ),
	  		.wr_en                ( (wr_en_cmd & (arid_intrr == i))),
	  		.rd_en                ( rd_en_cmd_intr_out[i] ),
	  		.data_in              ( {to_boundary_initiator, extend_wrap, wrap_flag, fixed_flag, INITIATOR_RSIZE, arid_intrr, araddr_intrr, arlen_intrr} ),
	  		.data_out             ( {to_boundary_initiator_out[i], extend_wrap_out[i], wrap_flag_out[i], fixed_flag_out[i], INITIATOR_RSIZE_out[i], arid_intrr_out[i], araddr_intrr_out[i], arlen_intrr_out[i]} ),
	  		.zero_data            ( 1'b0 ),
	  		.fifo_full            ( rd_cmd_intr_fifo_full[i] ),
	  		.fifo_empty           ( rd_cmd_intr_fifo_empty[i] ),
	  		.fifo_nearly_full     ( cmd_fifo_full[i]),
	  		.fifo_nearly_empty    ( ),
	  		.fifo_one_from_full   ( )
	      );
        end 
	      caxi4interconnect_FIFO_downsizing #
	      (
	      		.MEM_DEPTH( DATA_FIFO_DEPTH ),
 	      		.DATA_WIDTH_IN ( DATA_WIDTH_IN ),
	      		.DATA_WIDTH_OUT ( DATA_WIDTH_OUT ),
                .EXTRA_DATA_WIDTH ( EXTRA_DATA_WIDTH_ID ),	//ID_WIDTH and Response width added
		        .NEARLY_FULL_THRESH ( NEARLY_FULL_THRESH_VAL ),
	      		.NEARLY_EMPTY_THRESH ( 1 ),
	      		.PIPE ( PIPE ),
	      		.DWC_RAM_TYPE ( DWC_RAM_TYPE ),
	      		.SYNC_RESET ( SYNC_RESET )
	      )
	      data_fifo (
		     .arst_sync ( arst_sync ),
		     .srst_sync ( srst_sync ),
		     .clk ( ACLK ),
             .rd_src ( rd_src[i] ),
		     .wr_en (TARGET_RREADY & TARGET_RVALID & (TARGET_RID == i)),
		     .rd_en ( rd_en_data[i] ),
		     .data_in ( {TARGET_RRESP,TARGET_RID,TARGET_RUSER,TARGET_RDATA} ),  //TARGET_RID and TARGET_RRESP are stroed into fifo
		     .data_out ( fifo_data_out[i]),
             .data_hold ( data_hold[i] ),
		     .fifo_full ( ),
		     .fifo_empty ( data_fifo_empty[i]),
		     .fifo_nearly_full ( data_fifo_full[i] ),
		     .fifo_nearly_empty ( ),
		     .fifo_one_from_full ( )
          );	  		

         caxi4interconnect_DWC_UpConv_RChan_Ctrl #
         (
             .DATA_WIDTH_IN        ( DATA_WIDTH_IN ),
             .DATA_WIDTH_OUT       ( DATA_WIDTH_OUT ),
             .ID_WIDTH             ( ID_WIDTH )
         )
         RChan_Ctrl     
         (
             .ACLK                 ( ACLK ),
             .arst_sync             ( arst_sync ),
             .srst_sync             ( srst_sync ),
             .data_empty           ( data_fifo_empty[i] | INITIATOR_DATA_VALID_GRANT[i]), // At a time only one INITIATOR_RVALID should be asserted
             .rd_src               ( rd_src[i] ),
             .data_hold            ( data_hold[i] ),
             .rd_en_data           ( rd_en_data[i] ),
             .rd_en_cmd            ( rd_en_cmd_intr[i] ),
             .addr                 ( addr_in[i] ),
             .arid                 ( arid_in[i] ),
             //.arid                 ( INITIATOR_RID),
             .INITIATOR_RLEN_eq_0     ( INITIATOR_RLEN_eq_0_out[i]),
             .mask_pre             (mask_pre[i]),
             .rd_src_shift_pre     (rd_src_shift_pre[i]),
             .INITIATOR_RLEN          ( INITIATOR_RLEN_in[i]),
             .INITIATOR_RREADY        ( INITIATOR_RREADY ),
             .INITIATOR_RLAST         ( INITIATOR_RLAST_out[i] ),
             .INITIATOR_RVALID        ( INITIATOR_RVALID_out[i] ),
             .INITIATOR_RID           (  ),
             .INITIATOR_RSIZE         ( INITIATOR_RSIZE_in[i]),
             .TARGET_RREADY         ( TARGET_RREADY_out[i] ),
             .TARGET_RLAST          ( TARGET_RLAST ),
             .TARGET_RVALID         ( TARGET_RVALID ),
             .space_in_data_fifo   ( ~( data_fifo_full[i] ) ),
             //.space_in_rresp_fifo  ( ~( rresp_fifo_full[i] ) ),
             .fixed_flag	         ( fixed_flag_in[i] ),
             .wrap_flag	         ( wrap_flag_in[i]),
             .rd_src_top           (rd_src_top[i]),
             .to_wrap_boundary	 ( to_wrap_boundary_in[i] )
         );  


         caxi4interconnect_DWC_UpConv_preCalcRChan_Ctrl #
           (
             .DATA_WIDTH_IN        ( DATA_WIDTH_IN ),
             .DATA_WIDTH_OUT       ( DATA_WIDTH_OUT ),
             .USER_WIDTH           ( USER_WIDTH ),
             .ID_WIDTH             ( ID_WIDTH )
         
           ) preCalcRChan_Ctrl
           (
             .clk( ACLK ),
             .arst_sync( arst_sync ),
             .srst_sync( srst_sync ),
             .addr_in( araddr_intrr_out[i] ),
             .arid_in( arid_intrr_out[i] ),
             .INITIATOR_RLEN_in( arlen_intrr_out[i] ),
             .INITIATOR_RSIZE_in( INITIATOR_RSIZE_out[i]),
             .fixed_flag_in( fixed_flag_out[i] ),
             .wrap_flag_in( wrap_flag_out[i] ),
             .extend_wrap_in( extend_wrap_out[i] ),
             .to_wrap_boundary_in( to_boundary_initiator_out[i] ),												
             .rd_cmd_intr_fifo_empty_in(rd_cmd_intr_fifo_empty[i]), 
             .rd_en_cmd_intr_in(rd_en_cmd_intr[i]), 
             .addr_out(addr_in[i]),
             .arid_out(arid_in[i]),
             .INITIATOR_RLEN_out(INITIATOR_RLEN_in[i]),
             .INITIATOR_RSIZE_out(INITIATOR_RSIZE_in[i]),
             .fixed_flag_out(fixed_flag_in[i]),
             .wrap_flag_out(wrap_flag_in[i]),
             .to_wrap_boundary_out(to_wrap_boundary_in[i]),
		     .rd_cmd_intr_fifo_empty_out (),
             .rd_en_cmd_intr_out(rd_en_cmd_intr_out[i]),
	         .mask_pre             (mask_pre[i]),
             .rd_src_shift_pre     (rd_src_shift_pre[i]),
	         .rd_src_top           (rd_src_top[i]),	 
             .INITIATOR_RLEN_eq_0_out(INITIATOR_RLEN_eq_0_out[i])
           );

//Storing TARGET_RRESP in data_fifo and disabled rresp_fifo.
	   
/*     
       caxi4interconnect_FIFO_downsizing #
       (
           .MEM_DEPTH( DATA_FIFO_DEPTH ),
           .DATA_WIDTH_IN ( 2 ),
           .DATA_WIDTH_OUT ( 2 ),
           .NEARLY_FULL_THRESH ( DATA_FIFO_DEPTH -1 ),
           .NEARLY_EMPTY_THRESH ( 0 ),
           .EXTRA_DATA_WIDTH ( 0 )
       )
       rresp_fifo (
           .rst ( arst_sync ),
           .clk ( ACLK ),
           .rd_src ( 2'b0 ),
           .wr_en ( (TARGET_RREADY & TARGET_RVALID & (TARGET_RID == i))),
           .rd_en ( rd_en_data[i] ),
           .data_in ( TARGET_RRESP ),
           .data_out ( INITIATOR_RRESP_out[i] ),
           .data_hold ( data_hold[i] ),
           .fifo_full ( ),
           .fifo_empty ( rresp_fifo_empty[i] ),
           .fifo_nearly_full ( rresp_fifo_full[i] ),
           .fifo_nearly_empty ( ),
           .fifo_one_from_full ( )
       );
*/	
        end //END for loop 

        assign INITIATOR_RDATA        = fifo_data_out[INITIATOR_SEL][DATA_WIDTH_OUT-1: 0];
        assign INITIATOR_RUSER        = fifo_data_out[INITIATOR_SEL][DATA_WIDTH_OUT+USER_WIDTH-1:DATA_WIDTH_OUT];
        assign INITIATOR_RID          = fifo_data_out[INITIATOR_SEL][DATA_WIDTH_OUT+USER_WIDTH+ID_WIDTH-1:DATA_WIDTH_OUT+USER_WIDTH];//Read Initiator RID from FIFO
        assign INITIATOR_RRESP        = fifo_data_out[INITIATOR_SEL][(DATA_WIDTH_OUT+USER_WIDTH+ID_WIDTH+2)-1:DATA_WIDTH_OUT+USER_WIDTH+ID_WIDTH];	
        assign INITIATOR_RVALID       = (| INITIATOR_RVALID_out);
        assign INITIATOR_RLAST        = (INITIATOR_RLAST_out[INITIATOR_SEL]);
        assign TARGET_RID_SEL       = TARGET_RVALID ? TARGET_RID : 0;
        //assign TARGET_RREADY        = (& TARGET_RREADY_out);//[TARGET_RID_SEL]);	
        assign TARGET_RREADY        = (TARGET_RREADY_out[TARGET_RID_SEL]);	
		
        caxi4interconnect_DWC_RChannel_TrgtRid_Arb # 
        (
          .ID_WIDTH        (ID_WIDTH),
          .TOTAL_IDS       (TOTAL_IDS)	
        ) DWC_UpConv_RChan_TrgtRid_Arb
        (
          .ACLK            (ACLK),
          .arst_sync        (arst_sync),
          .srst_sync        (srst_sync),
      	  .req_n           (data_fifo_empty),
      	  .arb_ctrl        (INITIATOR_RVALID_out),
      	  .grant_n         (INITIATOR_DATA_VALID_GRANT)
        );
		
       //One hot to binary conversion 		
		
        for (k=0; k<ID_WIDTH; k=k+1)
          begin 
   	        wire [TOTAL_IDS-1:0] tmp_mask;
   	        for (l=0; l<TOTAL_IDS; l=l+1)
   	          begin
   	  	        assign tmp_mask[l] = l[k];
   	          end	
   	        assign INITIATOR_SEL[k] = |(tmp_mask & INITIATOR_RVALID_out);
          end	

    end //END Read Inteleave	
  else 
    begin 
	
	
      wire rd_en_cmd_intr;
      wire rd_en_cmd_intr_out;
      wire rd_cmd_intr_fifo_full;
      wire rd_cmd_intr_fifo_empty;
      wire rd_cmd_intr_fifo_empty_out;
      
      wire rd_en_data;
      
      wire data_hold;
      
      wire [($clog2(DATA_WIDTH_IN/DATA_WIDTH_OUT)-1):0] rd_src;
      
      wire [ID_WIDTH-1:0]             arid_intrr_out;
      wire [5:0]                      araddr_intrr_out;
      wire [7:0]                      arlen_intrr_out;
      wire [2:0]                      INITIATOR_RSIZE_out;
      
      wire                            extend_wrap_out;
      wire                            wrap_flag_out;
      wire [4:0]                      to_boundary_initiator_out;
      wire				              fixed_flag_out;
      wire      [5:0]                 rd_src_top;
      
      
      
      wire [(DATA_WIDTH_OUT+USER_WIDTH+2)-1:0]  fifo_data_out;
      wire [25+ID_WIDTH-1:0]       intrr_cmd_out;
      
      wire data_fifo_empty;
      wire data_fifo_full;
      wire data_fifo_one_from_full;
      wire data_fifo_nearly_full;
      
      wire rresp_fifo_empty;
      wire rresp_fifo_full;
      wire rresp_fifo_one_from_full;
      
      wire     [9:0]               addr_in;
      wire     [ID_WIDTH - 1:0]    arid_in;
      wire     [7:0]               INITIATOR_RLEN_in;
      wire     [2:0]               INITIATOR_RSIZE_in;
      wire                         fixed_flag_in;
      wire                         wrap_flag_in;
      wire     [4:0]               to_wrap_boundary_in;
      
      wire                         INITIATOR_RLEN_eq_0_out;
      
      
      wire     [9:0]               mask_pre;
      wire     [9:0]               rd_src_shift_pre;
	
	  if(PIPE > 0) begin 
	    localparam  FIFO_SIZE = ($clog2(ADDR_FIFO_DEPTH) < 2) ? 4 : ADDR_FIFO_DEPTH;
		wire rdcmdfifo_itvld;
		wire rdcmdfifo_ttrdy;
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
           .AXIS_TTDATA_WIDTH  (18 + ID_WIDTH + 1 + 1 + 5), // Bytes
           .AXIS_ITDATA_WIDTH  (18 + ID_WIDTH + 1 + 1 + 5),  // Bytes
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
        ) rd_cmd_intr_fwft
        (
           .AXI4S_ACLK         (ACLK),
           .AXI4S_IACLK        (ACLK),
           .AXI4S_TACLK        (ACLK),
           .AXI4S_ARESETN      (cfifo_rst),
           .AXI4S_IARESETN     (cfifo_rst),
           .AXI4S_TARESETN     (cfifo_rst),
           .AXI4S_ITREADY      (rd_en_cmd_intr_out),
           .AXI4S_ITVALID      (rdcmdfifo_itvld),
           .AXI4S_ITDATA       ({to_boundary_initiator_out, extend_wrap_out, wrap_flag_out, fixed_flag_out, INITIATOR_RSIZE_out, arid_intrr_out, araddr_intrr_out, arlen_intrr_out} ),
           .AXI4S_TTVALID      (wr_en_cmd ),
           .AXI4S_TTDATA       ({to_boundary_initiator, extend_wrap, wrap_flag, fixed_flag, INITIATOR_RSIZE, arid_intrr, araddr_intrr, arlen_intrr}),
           .ALMOST_FULL        (rdcmdfifo_ttrdy)
        );
		
      assign cmd_fifo_full         = rdcmdfifo_ttrdy;
      assign rd_cmd_intr_fifo_empty = ~rdcmdfifo_itvld;
	  
	  end else begin 
      caxi4interconnect_FIFO #
      (
      			.MEM_DEPTH            ( ADDR_FIFO_DEPTH ),
      			.DATA_WIDTH_IN        ( 18 + ID_WIDTH + 1 + 1 + 5 ),
      			.DATA_WIDTH_OUT       ( 18 + ID_WIDTH + 1 + 1 + 5 ), 
      			.NEARLY_FULL_THRESH   ( ADDR_FIFO_DEPTH - 1 ), // Setting nearly full thresh to allow for 1 left in caxi4interconnect_FIFO
      			.NEARLY_EMPTY_THRESH  ( 1 )
      )
      	rd_cmd_intr (
      			.arst                  (arst_sync ),
      			.srst                  (srst_sync ),
      			.clk                  ( ACLK ),
      			.wr_en                ( wr_en_cmd ),
      			.rd_en                ( rd_en_cmd_intr_out ),
      			.data_in              ( {to_boundary_initiator, extend_wrap, wrap_flag, fixed_flag, INITIATOR_RSIZE, arid_intrr, araddr_intrr, arlen_intrr} ),
      			.data_out             ( {to_boundary_initiator_out, extend_wrap_out, wrap_flag_out, fixed_flag_out, INITIATOR_RSIZE_out, arid_intrr_out, araddr_intrr_out, arlen_intrr_out} ),
      			.zero_data            ( 1'b0 ),
      			.fifo_full            ( rd_cmd_intr_fifo_full ),
      			.fifo_empty           ( rd_cmd_intr_fifo_empty ),
      			.fifo_nearly_full     ( cmd_fifo_full ),
      			.fifo_nearly_empty    ( ),
      			.fifo_one_from_full   ( )
      );
      end 
	  caxi4interconnect_FIFO_downsizing #
	  (
	  		.MEM_DEPTH( DATA_FIFO_DEPTH ),
 	  		.DATA_WIDTH_IN ( DATA_WIDTH_IN ),
	  		.DATA_WIDTH_OUT ( DATA_WIDTH_OUT ),
            .EXTRA_DATA_WIDTH ( EXTRA_DATA_WIDTH_USER), //2 for storing TARGET_RRESP	
	  		.NEARLY_FULL_THRESH ( NEARLY_FULL_THRESH_VAL ),
	  		.NEARLY_EMPTY_THRESH ( 1 ),
	      	.PIPE ( PIPE ),
			.DWC_RAM_TYPE ( DWC_RAM_TYPE ),						   
	      	.SYNC_RESET ( SYNC_RESET )
	  )
	  data_fifo (
	  		.arst_sync ( arst_sync ),
	  		.srst_sync ( srst_sync ),
	  		.clk ( ACLK ),
            .rd_src ( rd_src ),
	  		.wr_en ( TARGET_RREADY & TARGET_RVALID ),
	  		.rd_en ( rd_en_data ),
	  		.data_in ( {TARGET_RRESP,TARGET_RUSER, TARGET_RDATA} ),
	  		.data_out ( fifo_data_out ),
            .data_hold ( data_hold ),
	  		.fifo_full ( ),
	  		.fifo_empty ( data_fifo_empty ),
	  		.fifo_nearly_full ( data_fifo_full ),
	  		.fifo_nearly_empty ( ),
	  		.fifo_one_from_full ( data_fifo_one_from_full )
	  );

      caxi4interconnect_DWC_UpConv_RChan_Ctrl #
      (
          .DATA_WIDTH_IN        ( DATA_WIDTH_IN ),
          .DATA_WIDTH_OUT       ( DATA_WIDTH_OUT ),
          .ID_WIDTH             ( ID_WIDTH )
      )
          RChan_Ctrl     
      (
          .ACLK                 ( ACLK ),
          .arst_sync            ( arst_sync ),
          .srst_sync            ( srst_sync ),
          .data_empty           ( data_fifo_empty),
          .rd_src               ( rd_src ),
          .data_hold            ( data_hold ),
          .rd_en_data           ( rd_en_data ),
          .rd_en_cmd            ( rd_en_cmd_intr ),
          .addr                 ( addr_in ),
          .arid                 ( arid_in ),
	    											 
          .INITIATOR_RLEN_eq_0     ( INITIATOR_RLEN_eq_0_out),
	      .mask_pre             (mask_pre),
          .rd_src_shift_pre     (rd_src_shift_pre),
          .INITIATOR_RLEN          ( INITIATOR_RLEN_in),
          .INITIATOR_RREADY        ( INITIATOR_RREADY ),
          .INITIATOR_RLAST         ( INITIATOR_RLAST ),
          .INITIATOR_RVALID        ( INITIATOR_RVALID ),
          .INITIATOR_RID           ( INITIATOR_RID ),
          .INITIATOR_RSIZE         ( INITIATOR_RSIZE_in),
          .TARGET_RREADY         ( TARGET_RREADY ),
          .TARGET_RLAST          ( TARGET_RLAST ),
          .TARGET_RVALID         ( TARGET_RVALID ),
          .space_in_data_fifo   ( ~( data_fifo_full ) ),
          //.space_in_rresp_fifo  ( ~( rresp_fifo_full ) ),
          .fixed_flag	          ( fixed_flag_in ),
          .wrap_flag	          ( wrap_flag_in),
	     .rd_src_top              (rd_src_top),
          .to_wrap_boundary	    ( to_wrap_boundary_in )
      );
  

      caxi4interconnect_DWC_UpConv_preCalcRChan_Ctrl #
      (
         .DATA_WIDTH_IN        ( DATA_WIDTH_IN ),
         .DATA_WIDTH_OUT       ( DATA_WIDTH_OUT ),
         .USER_WIDTH           ( USER_WIDTH ),
         .ID_WIDTH             ( ID_WIDTH )
      
      ) preCalcRChan_Ctrl
      (
         .clk( ACLK ),
         .arst_sync( arst_sync ),
         .srst_sync( srst_sync ),
         .addr_in( araddr_intrr_out ),
         .arid_in( arid_intrr_out ),
         .INITIATOR_RLEN_in( arlen_intrr_out ),
         .INITIATOR_RSIZE_in( INITIATOR_RSIZE_out),
         .fixed_flag_in( fixed_flag_out ),
         .wrap_flag_in( wrap_flag_out ),
         .extend_wrap_in( extend_wrap_out ),
         .to_wrap_boundary_in( to_boundary_initiator_out ),
	     	 
         .rd_cmd_intr_fifo_empty_in(rd_cmd_intr_fifo_empty), 
         .rd_en_cmd_intr_in(rd_en_cmd_intr), 
	     
         .addr_out(addr_in),
         .arid_out(arid_in),
         .INITIATOR_RLEN_out(INITIATOR_RLEN_in),
         .INITIATOR_RSIZE_out(INITIATOR_RSIZE_in),
         .fixed_flag_out(fixed_flag_in),
         .wrap_flag_out(wrap_flag_in),
         .to_wrap_boundary_out(to_wrap_boundary_in),
         .rd_cmd_intr_fifo_empty_out(rd_cmd_intr_fifo_empty_out), 
         .rd_en_cmd_intr_out(rd_en_cmd_intr_out),
	     .mask_pre             (mask_pre),
         .rd_src_shift_pre     (rd_src_shift_pre),
	     .rd_src_top           (rd_src_top),
         .INITIATOR_RLEN_eq_0_out(INITIATOR_RLEN_eq_0_out)
      );
/*	   
      caxi4interconnect_FIFO_downsizing #
      (
            .MEM_DEPTH( DATA_FIFO_DEPTH ),
            .DATA_WIDTH_IN ( 2 ),
            .DATA_WIDTH_OUT ( 2 ),
            .NEARLY_FULL_THRESH ( DATA_FIFO_DEPTH -1 ),
            .NEARLY_EMPTY_THRESH ( 0 ),
            .EXTRA_DATA_WIDTH ( 0 )
      )
      rresp_fifo (
            .rst ( arst_sync ),
            .clk ( ACLK ),
            .rd_src ( 2'b0 ),
            .wr_en ( TARGET_RREADY & TARGET_RVALID ),
            .rd_en ( rd_en_data ),
            .data_in ( TARGET_RRESP ),
            .data_out ( INITIATOR_RRESP ),
            .data_hold ( data_hold ),
            .fifo_full ( ),
            .fifo_empty ( rresp_fifo_empty ),
            .fifo_nearly_full ( rresp_fifo_full ),
            .fifo_nearly_empty ( ),
            .fifo_one_from_full ( rresp_fifo_one_from_full )
      );
*/	  
		
	  assign INITIATOR_RRESP = fifo_data_out[(DATA_WIDTH_OUT+USER_WIDTH+2)-1:DATA_WIDTH_OUT+USER_WIDTH];	
	  assign INITIATOR_RDATA = fifo_data_out[DATA_WIDTH_OUT-1: 0];					
      assign INITIATOR_RUSER = fifo_data_out[DATA_WIDTH_OUT+:USER_WIDTH];	  
	end  
  
endgenerate
	  
endmodule	
	
