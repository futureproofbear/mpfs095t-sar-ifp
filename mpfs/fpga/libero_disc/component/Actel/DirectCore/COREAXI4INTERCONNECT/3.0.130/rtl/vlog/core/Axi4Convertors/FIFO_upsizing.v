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
// SVN $Revision: 49962 $
// SVN $Date: 2025-10-24 17:13:52 +0530 (Fri, 24 Oct 2025) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns



module caxi4interconnect_FIFO_upsizing #

  (
    parameter integer  MEM_DEPTH           = 1024,
    parameter integer  DATA_WIDTH_IN       = 36,
    parameter integer  DATA_WIDTH_OUT      = 640,
    parameter integer  EXTRA_DATA_WIDTH    = 8,
    parameter integer  NEARLY_FULL_THRESH  = 512,
    parameter integer  NEARLY_EMPTY_THRESH = 128,
    parameter          PIPE                = 1,
    parameter          DWC_RAM_TYPE        = 3,
    parameter          SYNC_RESET          = 0
  )
  (
      clk,
      arst_sync,
      srst_sync,

      zero_data,
      wr_en,
      rd_en,
      pass_data, 
      data_in,
      zero_out_data,

      data_out,
      fifo_full,
      fifo_empty,
      fifo_nearly_full,
      fifo_nearly_empty,
      fifo_one_from_full
  );

  genvar i;
  localparam FIFO_SIZE = ($clog2(MEM_DEPTH) < 2) ? 4 : MEM_DEPTH;
  localparam FIFO_ADDR_WIDTH = ($clog2(MEM_DEPTH) < 2) ? 2 : $clog2(MEM_DEPTH);
  localparam NEARLY_EMPTY = ($clog2(MEM_DEPTH) < 2) ? 1 : NEARLY_EMPTY_THRESH;
  localparam NEARLY_FULL = ($clog2(MEM_DEPTH) < 2) ? 3 : NEARLY_FULL_THRESH;
  

   
     input clk;
     input arst_sync;
     input srst_sync;

     input [((DATA_WIDTH_OUT/DATA_WIDTH_IN)-1):0] zero_data;
     input [((DATA_WIDTH_OUT/DATA_WIDTH_IN)-1):0] wr_en;
     input rd_en;
     input pass_data; 
     input [(DATA_WIDTH_IN + EXTRA_DATA_WIDTH)-1:0] data_in;
     input zero_out_data;

     output [(DATA_WIDTH_OUT + EXTRA_DATA_WIDTH)-1:0] data_out;
     output fifo_full;
     output fifo_empty;
     output fifo_nearly_full;
     output fifo_nearly_empty;
     output fifo_one_from_full;
  
  
     wire clk;
     wire arst_sync;

     wire [((DATA_WIDTH_OUT/DATA_WIDTH_IN)-1):0] zero_data;
     wire [((DATA_WIDTH_OUT/DATA_WIDTH_IN)-1):0] wr_en;
     wire rd_en;
     wire pass_data; 
     wire [(DATA_WIDTH_IN + EXTRA_DATA_WIDTH)-1:0] data_in;
     wire zero_out_data;

     wire [(DATA_WIDTH_OUT + EXTRA_DATA_WIDTH)-1:0] data_out;
     wire fifo_full;
     wire fifo_empty;
     wire fifo_nearly_full;
     wire fifo_nearly_empty;
     wire fifo_one_from_full;
  
  
  
  wire [FIFO_ADDR_WIDTH-1:0] wr_addr;
  wire [FIFO_ADDR_WIDTH-1:0] rd_addr;


  wire [(DATA_WIDTH_OUT + EXTRA_DATA_WIDTH)-1:0]  data_out_int;
  wire [(DATA_WIDTH_OUT + EXTRA_DATA_WIDTH)-1:0]  data_out_mux;
  reg [(DATA_WIDTH_OUT + EXTRA_DATA_WIDTH)-1:0]   data_out_next;
  reg [(DATA_WIDTH_OUT + EXTRA_DATA_WIDTH)-1:0]   data_out_reg;

  wire [(DATA_WIDTH_IN)-1:0] data_in_fifo [(DATA_WIDTH_OUT/DATA_WIDTH_IN)-1:0];
  wire [(DATA_WIDTH_OUT/DATA_WIDTH_IN)-1:0] wr_en_fifo;
  
  wire [(DATA_WIDTH_OUT/DATA_WIDTH_IN)-1:0] upsizingfifo_itvld;
  wire [(DATA_WIDTH_OUT/DATA_WIDTH_IN)-1:0] upsizingfifo_afull;
  wire [(DATA_WIDTH_OUT/DATA_WIDTH_IN)-1:0] upsizingfifo_aempty;
  
  wire         cfifo_rst;

  assign       cfifo_rst = (SYNC_RESET == 0) ? arst_sync : srst_sync;     

  generate
    for (i=0; i<(DATA_WIDTH_OUT/DATA_WIDTH_IN); i=i+1) begin
	  if(PIPE > 0) begin 
    
        caxi4c_coreaxi4s_fifo #
        (
           .RESET_TYPE         (SYNC_RESET),//
           .SYNC               (1),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
           .PIPE               (1),// 1: Address pipeline 2: address and data pipeline 
           .ECC                (0),// 0: ECC disable , 1: ECC enable
           .RAM_TYPE           (DWC_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
           .NUM_STAGES         (0),// To select number of synchronizer stages.
           .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
           .WFIFO_DEPTH        (FIFO_SIZE),
           .RFIFO_DEPTH        (FIFO_SIZE),
           .AXIS_TTDATA_WIDTH  (DATA_WIDTH_IN) , // Bytes
           .AXIS_ITDATA_WIDTH  (DATA_WIDTH_IN),  // Bytes
           .AXIS_TTID_WIDTH    (1), // Bits
           .AXIS_ITID_WIDTH    (1), // Bits
           .AXIS_TTDEST_WIDTH  (1), // Bits
           .AXIS_ITDEST_WIDTH  (1), // Bits
           .AXIS_TTUSER_WIDTH  (1), // Bits
           .AXIS_ITUSER_WIDTH  (1), // Bits
           .ENABLE_AFULL       (1),
           .ENABLE_AEMPTY      (1),
           .AFULL_THR          (NEARLY_FULL),
           .AEMPTY_THR         (NEARLY_EMPTY),
           .ENABLE_TSTRB       (0),
           .ENABLE_TKEEP       (0),
           .ENABLE_TLAST       (0),
           .ENABLE_TUSER       (0),
           .ENABLE_TDEST       (0),
           .ENABLE_TID         (0),
           .EOP_OFFSET         (0)
        ) fifo_upsizing_fwft
        (
           .AXI4S_ACLK         (clk),
           .AXI4S_IACLK        (clk),
           .AXI4S_TACLK        (clk),
           .AXI4S_ARESETN      (cfifo_rst),
           .AXI4S_IARESETN     (cfifo_rst),
           .AXI4S_TARESETN     (cfifo_rst),
           .AXI4S_ITREADY      (rd_en),
           .AXI4S_ITVALID      (upsizingfifo_itvld[i]),
           .AXI4S_ITDATA       (data_out_int[DATA_WIDTH_IN*(i+1)-1:DATA_WIDTH_IN*i]),
           .AXI4S_TTVALID      (wr_en_fifo[i]),
           .AXI4S_TTDATA       (data_in_fifo[i]),
           .ALMOST_FULL        (upsizingfifo_afull[i]),
           .ALMOST_EMPTY       (upsizingfifo_aempty[i])
        );
		        

	  end else begin 
	  
        caxi4interconnect_RAM_BLOCK #
          (
            .MEM_DEPTH    ( FIFO_SIZE ),
            .ADDR_WIDTH   ( FIFO_ADDR_WIDTH ),
            .DATA_WIDTH   ( DATA_WIDTH_IN) 
          )
        ram (
            .clk          ( clk ),
            .wr_en        ( wr_en_fifo[i] ),
            .rd_addr      ( rd_addr[FIFO_ADDR_WIDTH-1:0] ),
            .wr_addr      ( wr_addr[FIFO_ADDR_WIDTH-1:0] ),
            .data_in      ( data_in_fifo[i] ),
            .data_out     ( data_out_int[DATA_WIDTH_IN*(i+1)-1:DATA_WIDTH_IN*i] )
        );
	  end 
    end
  endgenerate  
  generate
    if(PIPE > 0) begin 
	  assign fifo_empty         = ~(upsizingfifo_itvld[(DATA_WIDTH_OUT/DATA_WIDTH_IN)-1]);
	  assign fifo_nearly_full   = upsizingfifo_afull [(DATA_WIDTH_OUT/DATA_WIDTH_IN)-1];
	  assign fifo_nearly_empty  = upsizingfifo_aempty[(DATA_WIDTH_OUT/DATA_WIDTH_IN)-1];
	  assign fifo_full          = 1'b0;
	  assign fifo_one_from_full = 1'b0;
	end else begin 
        caxi4interconnect_FIFO_CTRL #
        (
            .FIFO_SIZE          (FIFO_SIZE),
            .NEARLY_FULL        (NEARLY_FULL),
            .NEARLY_EMPTY       (NEARLY_EMPTY),
            .ADDRESS_WIDTH      (FIFO_ADDR_WIDTH)
        )
        fifo_ctrl_inst (
           // Inputs
       	    .clk 				  ( clk ),
       	    .arst   			  ( arst_sync ),
       	    .srst   			  ( srst_sync ),
       	    .wr_rqst			  ( wr_en_fifo[(DATA_WIDTH_OUT/DATA_WIDTH_IN)-1] ),  // request to write to the caxi4interconnect_FIFO if writing to the top RAM
       		  																	  // successful if not full
       	    .rd_rqst			  ( rd_en ), // request to read from the caxi4interconnect_FIFO, successful if not empty 
       	  
           // Outputs	  
       	    .wrptr			      ( wr_addr ),
       	    .rdptr			      ( rd_addr ),
            .fifo_full            ( fifo_full ),
            .fifo_empty           ( fifo_empty ),
            .fifo_nearly_full     ( fifo_nearly_full ),
            .fifo_nearly_empty    ( fifo_nearly_empty ),
            .fifo_one_from_full   ( fifo_one_from_full )
        );	
    end 
  endgenerate	  

  
  generate
  
    if (EXTRA_DATA_WIDTH > 0)
    begin
      if(PIPE > 0) begin 	    
        caxi4c_coreaxi4s_fifo #
        (
           .RESET_TYPE         (SYNC_RESET),//
           .SYNC               (1),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
           .PIPE               (1),// 1: Address pipeline 2: address and data pipeline 
           .ECC                (0),// 0: ECC disable , 1: ECC enable
           .RAM_TYPE           (DWC_RAM_TYPE),// 0 - Fabric 1 - uSRAM 2 - LSRAM
           .NUM_STAGES         (0),// To select number of synchronizer stages.
           .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
           .WFIFO_DEPTH        (FIFO_SIZE),
           .RFIFO_DEPTH        (FIFO_SIZE),
           .AXIS_TTDATA_WIDTH  (EXTRA_DATA_WIDTH) , // Bytes
           .AXIS_ITDATA_WIDTH  (EXTRA_DATA_WIDTH),  // Bytes
           .AXIS_TTID_WIDTH    (1), // Bits
           .AXIS_ITID_WIDTH    (1), // Bits
           .AXIS_TTDEST_WIDTH  (1), // Bits
           .AXIS_ITDEST_WIDTH  (1), // Bits
           .AXIS_TTUSER_WIDTH  (1), // Bits
           .AXIS_ITUSER_WIDTH  (1), // Bits
           .ENABLE_AFULL       (0),
           .ENABLE_AEMPTY      (0),
           .AFULL_THR          (FIFO_SIZE-1),
           .AEMPTY_THR         (1),
           .ENABLE_TSTRB       (0),
           .ENABLE_TKEEP       (0),
           .ENABLE_TLAST       (0),
           .ENABLE_TUSER       (0),
           .ENABLE_TDEST       (0),
           .ENABLE_TID         (0),
           .EOP_OFFSET         (0)
        ) fifo_upsizing_fwft
        (
           .AXI4S_ACLK         (clk),
           .AXI4S_IACLK        (clk),
           .AXI4S_TACLK        (clk),
           .AXI4S_ARESETN      (cfifo_rst),
           .AXI4S_IARESETN     (cfifo_rst),
           .AXI4S_TARESETN     (cfifo_rst),
           .AXI4S_ITREADY      (rd_en),
           .AXI4S_ITDATA       (data_out_int[DATA_WIDTH_OUT +: EXTRA_DATA_WIDTH]),
           .AXI4S_TTVALID      (wr_en_fifo[(DATA_WIDTH_OUT/DATA_WIDTH_IN)-1]),
           .AXI4S_TTDATA       (data_in[DATA_WIDTH_IN +:EXTRA_DATA_WIDTH]),
           .ALMOST_FULL        (),
           .ALMOST_EMPTY       ()
        );		        

	  end else begin 
        caxi4interconnect_RAM_BLOCK #
          (
            .MEM_DEPTH  ( FIFO_SIZE ),
            .ADDR_WIDTH ( FIFO_ADDR_WIDTH ),
            .DATA_WIDTH ( EXTRA_DATA_WIDTH ) 
          )
        user_block (
            .clk         ( clk ),
            .wr_en       ( wr_en_fifo[(DATA_WIDTH_OUT/DATA_WIDTH_IN)-1] ),
            .rd_addr     ( rd_addr[FIFO_ADDR_WIDTH-1:0] ),
            .wr_addr     ( wr_addr[FIFO_ADDR_WIDTH-1:0] ),
            .data_in     ( data_in[DATA_WIDTH_IN +:EXTRA_DATA_WIDTH] ),
            .data_out    ( data_out_int[DATA_WIDTH_OUT +: EXTRA_DATA_WIDTH] )
        );
	  end 
    end
  endgenerate

  assign data_out_mux = (zero_out_data) ? { data_out_reg[DATA_WIDTH_OUT +: EXTRA_DATA_WIDTH], {DATA_WIDTH_OUT{1'b0}}} : data_out_int;

  generate
    for (i=0; i<(DATA_WIDTH_OUT/DATA_WIDTH_IN); i=i+1) begin
      assign data_in_fifo[i] = (zero_data[i]) ? 'b0 :  data_in[DATA_WIDTH_IN-1:0]; // concatenate user_data_in and data_in
      assign wr_en_fifo[i] = zero_data[i] | wr_en[i];
    end
  endgenerate

  always @(posedge clk or negedge arst_sync) begin
    if (~arst_sync | ~srst_sync)
          data_out_reg <= 'b0;
    else 
          data_out_reg <= data_out_next;    
  end

  always @(*) begin
    if (pass_data) begin
          data_out_next = data_out_mux;
    end
    else begin
          data_out_next = data_out_reg;
    end
  end


  assign data_out = data_out_reg;




endmodule

