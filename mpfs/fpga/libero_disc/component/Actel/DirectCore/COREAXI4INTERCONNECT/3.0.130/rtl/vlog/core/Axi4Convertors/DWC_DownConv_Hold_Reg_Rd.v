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



module caxi4interconnect_DWC_DownConv_Hold_Reg_Rd (
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
          mask_intrSize,
          mask_trgtSize,
          sizeCnt_comb_EQ_SizeMax,
          initiator_ADDR_masked,
          second_Beat_Addr,
          sizeCnt_comb_P1,
          targetSize_one_hot_hold,
          sizeMax_extend
          );

  parameter integer  CMD_FIFO_DATA_WIDTH = 29;
  parameter integer  ID_WIDTH = 29;

  input ACLK;
  input arst_sync;
  input srst_sync;

  input wire [CMD_FIFO_DATA_WIDTH-1:0] DWC_DownConv_hold_data_in;
  input wire DWC_DownConv_hold_fifo_empty;
  input wire DWC_DownConv_hold_get_next_data;


  output wire DWC_DownConv_hold_fifo_rd_en;
  output reg [CMD_FIFO_DATA_WIDTH-1:0] DWC_DownConv_hold_data_out;
  output wire DWC_DownConv_hold_reg_empty;
  
  
  output reg [5:0]  mask_intrSize;
  output reg [5:0]  mask_trgtSize;
  output reg        sizeCnt_comb_EQ_SizeMax;
  output reg [5:0]  initiator_ADDR_masked;
  output reg [5:0]  second_Beat_Addr;
  output reg [5:0]  sizeCnt_comb_P1;
  output reg [6:0]  targetSize_one_hot_hold;
  output reg [5:0]  sizeMax_extend;


  wire DWC_DownConv_hold_reg_empty_inv;

  wire DWC_DownConv_pass_data;

  always @(posedge ACLK or negedge arst_sync) begin
    if (~arst_sync | ~srst_sync) begin
      DWC_DownConv_hold_data_out <= 0;
      
      // Set decoded outputs to 0
          mask_intrSize              <= 0;
          mask_trgtSize              <= 0;
          sizeCnt_comb_EQ_SizeMax   <= 0;
          initiator_ADDR_masked        <= 0;
          second_Beat_Addr          <= 0;
          sizeCnt_comb_P1           <= 0;
          targetSize_one_hot_hold    <= 0;
          sizeMax_extend            <= 0;
          

          
    end
    else begin
      if (DWC_DownConv_pass_data)
        begin
        DWC_DownConv_hold_data_out <= DWC_DownConv_hold_data_in;
      
      // Assign decoded outputs
          mask_intrSize              <= ( (1 << DWC_DownConv_hold_data_in[10:8]) - 1 ) & ( ~(( 1 << DWC_DownConv_hold_data_in[13:11] ) -1) );  // ((( 1<< initiatorSize) -1) & (~((1 << mask_trgtSize) -1)))
          mask_trgtSize              <= ( ~((1 << DWC_DownConv_hold_data_in[13:11]) - 1) );  // (~(1 << mask_trgtSize) -1)
          sizeCnt_comb_EQ_SizeMax   <= ( DWC_DownConv_hold_data_in[(35+ID_WIDTH):(30+ID_WIDTH)] == DWC_DownConv_hold_data_in[6:1] ); // (sizeCnt_comb == SizeMax)
          initiator_ADDR_masked        <= ( DWC_DownConv_hold_data_in[28:23] & ( ~( (1 << DWC_DownConv_hold_data_in[10:8]) - 1 ) ) );  // ( initiatorAddr & (~( 1<< initiatorSize) -1) )
          second_Beat_Addr          <= ( DWC_DownConv_hold_data_in[28:23] + ( 1 << DWC_DownConv_hold_data_in[13:11] ) );  // ( initiatorAddr + (1 << targetSize) )
          sizeCnt_comb_P1           <= DWC_DownConv_hold_data_in[37+ID_WIDTH-1] ? ( DWC_DownConv_hold_data_in[(35+ID_WIDTH):(30+ID_WIDTH)]) : 
		                                                                          ( DWC_DownConv_hold_data_in[(35+ID_WIDTH):(30+ID_WIDTH)] + 1 );  // ( sizeCnt_comb + 1 )
          targetSize_one_hot_hold    <= ( 1 << DWC_DownConv_hold_data_in[13:11] ); // ( 1 << targetSize )
          sizeMax_extend            <= ( DWC_DownConv_hold_data_in[6:1] << DWC_DownConv_hold_data_in[13:11] );// ( sizeMax << targetSize )
        end
    end
  end

  

  

  assign DWC_DownConv_hold_reg_empty = !DWC_DownConv_hold_reg_empty_inv;
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
