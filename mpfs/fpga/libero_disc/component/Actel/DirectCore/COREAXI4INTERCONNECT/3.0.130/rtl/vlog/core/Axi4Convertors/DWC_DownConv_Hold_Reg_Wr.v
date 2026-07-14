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
// SVN $Revision: 50783 $
// SVN $Date: 2026-03-16 01:41:25 +0530 (Mon, 16 Mar 2026) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns



module caxi4interconnect_DWC_DownConv_Hold_Reg_Wr (
          // Inputs
          ACLK,
          arst_sync,
          srst_sync,

          DWC_DownConv_hold_data_in,
          DWC_DownConv_hold_fifo_empty,

          DWC_DownConv_hold_get_next_data,

          // Outputs
          DWC_DownConv_hold_fifo_rd_en,
          DWC_DownConv_hold_data_out,
          DWC_DownConv_hold_reg_empty,
          
          // Decoded outputs
          targetLen_M1,
          initiator_ADDR_masked,
          second_Beat_Addr,
          sizeCnt_comb_EQ_SizeMax,
          sizeCnt_comb_P1
          );

  parameter integer  CMD_FIFO_DATA_WIDTH = 29;
  parameter integer  ID_WIDTH = 1;

  input wire  ACLK;
  input wire  arst_sync;
  input wire  srst_sync;

  input wire [CMD_FIFO_DATA_WIDTH-1:0] DWC_DownConv_hold_data_in;
  input wire  DWC_DownConv_hold_fifo_empty;

  input wire  DWC_DownConv_hold_get_next_data;

  output wire DWC_DownConv_hold_fifo_rd_en;
  output reg  [CMD_FIFO_DATA_WIDTH-1:0] DWC_DownConv_hold_data_out;
  output wire DWC_DownConv_hold_reg_empty;
  
  output reg [7:0] targetLen_M1;
  output reg [5:0] initiator_ADDR_masked;
  output reg [5:0] second_Beat_Addr;
  output reg       sizeCnt_comb_EQ_SizeMax;
  output reg [5:0] sizeCnt_comb_P1;

  wire DWC_DownConv_hold_reg_empty_inv;
  wire [8:0] targetLen_M1_calc;

  wire DWC_DownConv_pass_data;
  
  
  
  always @(posedge ACLK or negedge arst_sync) begin
    if (~arst_sync | ~srst_sync) begin
      DWC_DownConv_hold_data_out <= 0;
      
      // Set decoded outputs to 0
          targetLen_M1              <= 0;
          initiator_ADDR_masked       <= 0;
          second_Beat_Addr         <= 0;
          sizeCnt_comb_EQ_SizeMax  <= 0;
          sizeCnt_comb_P1          <= 0;
      
      
    end
    else begin
      if (DWC_DownConv_pass_data)
        begin
        DWC_DownConv_hold_data_out <= DWC_DownConv_hold_data_in;
      
      // Assign decoded outputs
          targetLen_M1              <= targetLen_M1_calc[7:0];
          initiator_ADDR_masked       <= ( DWC_DownConv_hold_data_in[28:23] & (~(( ~((6'b1 << DWC_DownConv_hold_data_in[10:8]) - 1'b1) ))) );
          second_Beat_Addr         <= ( DWC_DownConv_hold_data_in[28:23] + ( 6'b1 << DWC_DownConv_hold_data_in[13:11] ) );
          sizeCnt_comb_EQ_SizeMax  <= ( (DWC_DownConv_hold_data_in[(35+ID_WIDTH):(30+ID_WIDTH)]) == (DWC_DownConv_hold_data_in[6:1]) );
          sizeCnt_comb_P1          <= DWC_DownConv_hold_data_in[37+ID_WIDTH-1] ? ( DWC_DownConv_hold_data_in[(35+ID_WIDTH):(30+ID_WIDTH)]) : 
		                                                                         ( DWC_DownConv_hold_data_in[(35+ID_WIDTH):(30+ID_WIDTH)] + 1'b1 );
      end
      
    end
  end
  
  
  assign DWC_DownConv_hold_reg_empty = !DWC_DownConv_hold_reg_empty_inv;
  assign targetLen_M1_calc = DWC_DownConv_hold_data_in[22:14] - 1'b1;
  
caxi4interconnect_Hold_Reg_Ctrl DWC_DownConv_Hold_Reg_Ctrl (

      .arst_sync(arst_sync), // input
      .srst_sync(srst_sync), // input
      .clk(ACLK), // input

      .src_data_valid( !DWC_DownConv_hold_fifo_empty ), // input
      .get_next_data_hold( DWC_DownConv_hold_get_next_data ), // input
    
      .pass_data( DWC_DownConv_pass_data ), // output // Control the holding register
      .get_next_data_src( DWC_DownConv_hold_fifo_rd_en ), // output
      .hold_data_valid( DWC_DownConv_hold_reg_empty_inv ) // output
);

endmodule
