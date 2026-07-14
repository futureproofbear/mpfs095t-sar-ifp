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
// SVN $Revision: 49831 $
// SVN $Date: 2025-10-06 23:11:13 +0530 (Mon, 06 Oct 2025) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns


module caxi4interconnect_CDC_FIFO #

  (
    parameter integer  MEM_DEPTH         = 4,
    parameter integer  DATA_WIDTH        = 20,
    parameter integer  INITIATOR_BCHAN   = 0,
    parameter integer  RESET_TYPE        = 0,
    parameter integer  NUM_SYNC_STAGES   = 2
  )
  (
    input wire arst,
    input wire srst,
    input wire rdclk_arst,
    input wire rdclk_srst,
    input wire clk_wr,
    input wire clk_rd,

    input wire infoInValid,
    input wire readyForOut,

    input wire [DATA_WIDTH-1:0] infoIn,

    output wire [DATA_WIDTH-1:0] infoOut,
    output wire readyForInfo,
    output wire infoOutValid
  );

  genvar i;
  localparam FIFO_ADDR_WIDTH = (MEM_DEPTH < 4) ? 2 : $clog2(MEM_DEPTH);

  reg [FIFO_ADDR_WIDTH-1:0] wrPtr_s1, wrPtr_s2 /* synthesis syn_preserve = 1 */;
  reg [FIFO_ADDR_WIDTH-1:0] rdPtr_s1, rdPtr_s2 /* synthesis syn_preserve = 1 */;
  wire [FIFO_ADDR_WIDTH-1:0] wrPtr /* synthesis syn_keep=1 */;
  wire [FIFO_ADDR_WIDTH-1:0] rdPtr /* synthesis syn_keep=1 */;

  wire [FIFO_ADDR_WIDTH-1:0] wrPtrP1, wrPtrP2;
  wire [FIFO_ADDR_WIDTH-1:0] rdPtrP1;

  wire fifoWe;
  wire fifoRe;
  wire syncRstWrCnt;
  wire syncRstRdCnt;

generate 
  if(MEM_DEPTH > 1) begin 

    caxi4interconnect_RAM_BLOCK #
       (
          .MEM_DEPTH    ( 2**(FIFO_ADDR_WIDTH) ),
          .ADDR_WIDTH   ( FIFO_ADDR_WIDTH ),
          .DATA_WIDTH   ( DATA_WIDTH ),
          .INITIATOR_BCHAN (INITIATOR_BCHAN)		
       ) ram 
	   (
          .clk          ( clk_wr  ),
          .wr_en        ( fifoWe  ),
          .wr_addr      ( wrPtr   ),
          .rd_addr      ( rdPtr   ),
          .data_in      ( infoIn  ),
          .data_out     ( infoOut )
       );

  // Write clock domain
    caxi4interconnect_CDC_grayCodeCounter #
      (
	    .bin_rstValue  ( 1               ),
        .gray_rstValue ( 0               ),
        .n_bits        ( FIFO_ADDR_WIDTH )
      )  wrGrayCounter
      (    
        .clk           (clk_wr           ),
	    .arst          (arst             ),
	    .srst          (srst             ),
	    .syncRst       (1'b1             ),
	    .inc           (fifoWe           ),
	    .cntGray       (wrPtr            ),
	    .syncRstOut    (syncRstWrCnt     )
      );

    caxi4interconnect_CDC_grayCodeCounter #
    (
	   .bin_rstValue  ( 2               ),
       .gray_rstValue ( 1               ),
       .n_bits        ( FIFO_ADDR_WIDTH )
    ) wrGrayCounterP1
    (    
       .clk           (clk_wr           ),
	   .arst          (arst             ),
	   .srst          (srst             ),
	   .syncRst       (syncRstWrCnt     ),
	   .inc           (fifoWe           ),
	   .cntGray       (wrPtrP1          ),
	   .syncRstOut    (                 )
    );

    caxi4interconnect_CDC_grayCodeCounter #
    (
	  .bin_rstValue  ( 3               ),
      .gray_rstValue ( 3               ),
      .n_bits        ( FIFO_ADDR_WIDTH )
    ) wrGrayCounterP2
    (    
      .clk           (clk_wr           ),
	  .arst          (arst             ),
	  .srst          (srst             ),
	  .syncRst       (syncRstWrCnt     ),
	  .inc           (fifoWe           ),
	  .cntGray       (wrPtrP2          ),
	  .syncRstOut    (                 )
    );

    always @(posedge clk_wr or negedge arst) begin
      if(~arst | ~srst) begin
	    rdPtr_s1 <= 0;
	    rdPtr_s2 <= 0;
      end
      else begin
	    rdPtr_s1 <= rdPtr;
	    rdPtr_s2 <= rdPtr_s1;
      end
    end

    caxi4interconnect_CDC_wrCtrl #
	(
      .ADDR_WIDTH ( FIFO_ADDR_WIDTH )
    ) CDC_wrCtrl_inst 
	(
	  .clk            (clk_wr       ),
	  .arst           (arst         ),
	  .srst           (srst         ),
	  .wrPtr_gray     (wrPtrP1      ),
	  .rdPtr_gray     (rdPtr_s2     ),
	  .nextwrPtr_gray (wrPtrP2      ),
	  .readyForInfo   (readyForInfo ),

	  .infoInValid    (infoInValid  ),
	  .fifoWe         (fifoWe       )
    );


  // read clock domain
    caxi4interconnect_CDC_grayCodeCounter #
    (
	  .bin_rstValue  ( 1               ),
      .gray_rstValue ( 0               ),
      .n_bits        ( FIFO_ADDR_WIDTH )
    ) rdGrayCounter
                     (    
      .clk           (clk_rd           ),
	  .arst          (rdclk_arst       ),
	  .srst          (rdclk_srst       ),
	  .syncRst       (1'b1             ),
	  .inc           (fifoRe           ),
	  .cntGray       (rdPtr            ),
	  .syncRstOut    (syncRstRdCnt     )
    );

    caxi4interconnect_CDC_grayCodeCounter #
    (
	  .bin_rstValue  ( 2               ),
      .gray_rstValue ( 1               ),
      .n_bits        ( FIFO_ADDR_WIDTH )
    ) rdGrayCounterP1
    (    
      .clk           (clk_rd           ),
	  .arst          (rdclk_arst       ),
	  .srst          (rdclk_srst       ),
	  .syncRst       (syncRstRdCnt     ),
	  .inc           (fifoRe           ),
	  .cntGray       (rdPtrP1          ),
	  .syncRstOut    (                 )
    );

    always @(posedge clk_rd or negedge rdclk_arst) begin
      if (~rdclk_arst | ~rdclk_srst) begin
	    wrPtr_s1 <= 0;
	    wrPtr_s2 <= 0;
      end
      else begin
	    wrPtr_s1 <= wrPtr;
	    wrPtr_s2 <= wrPtr_s1;
      end
    end

    caxi4interconnect_CDC_rdCtrl # 
	(
      .ADDR_WIDTH     ( FIFO_ADDR_WIDTH )
    ) CDC_rdCtrl_inst
	(
	  .clk            (clk_rd           ),
	  .rdclk_arst     (rdclk_arst       ),
	  .rdclk_srst     (rdclk_srst       ),
	  .rdPtr_gray     (rdPtr            ),
	  .wrPtr_gray     (wrPtr_s2         ),
	  .nextrdPtr_gray (rdPtrP1          ),
	  .readyForOut    (readyForOut      ),

	  .infoOutValid   (infoOutValid     ),
	  .fifoRe         (fifoRe           )
    );
  end else begin 
    wire   wrst_n = RESET_TYPE ? srst : arst; 
    wire   rrst_n = RESET_TYPE ? rdclk_srst : rdclk_arst; 
  
    caxi4c_async_1deep_fwft_fifo #
    (
      .DWIDTH          (DATA_WIDTH       ),
      .NUM_SYNC_STAGES (NUM_SYNC_STAGES  ),
      .RESET_TYPE      (RESET_TYPE       )
    ) u_async_cdc_1deep_fifo            
    (	      
      .wclk            (clk_wr           ), 
      .wrst_n          (wrst_n           ), 
      .wdata           (infoIn           ),
      .wready          (readyForInfo     ),
      .wvalid          (infoInValid      ),
      .rclk            (clk_rd           ),
      .rrst_n          (rrst_n           ),
      .rdata           (infoOut          ),
      .rvalid          (infoOutValid     ),
      .rready          (readyForOut      )
    );    
  end 
endgenerate

endmodule

