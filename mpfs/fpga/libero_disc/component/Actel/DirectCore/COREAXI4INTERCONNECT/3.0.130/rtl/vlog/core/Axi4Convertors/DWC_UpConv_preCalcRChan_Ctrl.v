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



module caxi4interconnect_DWC_UpConv_preCalcRChan_Ctrl #
(
  parameter DATA_WIDTH_IN = 32,
  parameter DATA_WIDTH_OUT = 32,
  parameter USER_WIDTH = 32,
  parameter ID_WIDTH = 32
)
  (
   input wire clk,
   input wire arst_sync,
   input wire srst_sync,

   input wire     [5:0]               addr_in,
   input wire     [ID_WIDTH - 1:0]    arid_in,
   input wire     [7:0]               INITIATOR_RLEN_in,
   input wire     [2:0]               INITIATOR_RSIZE_in,
   input wire                         fixed_flag_in,
   input wire                         wrap_flag_in,
   input wire                         extend_wrap_in,
   input wire     [4:0]               to_wrap_boundary_in,
   
   input wire      rd_cmd_intr_fifo_empty_in, 
   input wire      rd_en_cmd_intr_in, 
    
   output reg     [9:0]               addr_out,
   output reg     [ID_WIDTH - 1:0]    arid_out,
   output reg     [7:0]               INITIATOR_RLEN_out,
   output reg     [2:0]               INITIATOR_RSIZE_out,
   output reg                         fixed_flag_out,
   output reg                         wrap_flag_out,
   output reg     [4:0]               to_wrap_boundary_out,
   output reg                         INITIATOR_RLEN_eq_0_out,
   
   
   output reg     [9:0]               mask_pre,
   output reg     [9:0]               rd_src_shift_pre,
   output reg     [5:0]               rd_src_top,
   
   output wire      rd_cmd_intr_fifo_empty_out, 
   output wire      rd_en_cmd_intr_out 

  );
  
  wire pass_data;
  wire INITIATOR_RLEN_eq_0;
  
   wire      [2:0]  size_in;
   wire      [2:0]  size_out;
   wire      [2:0]  size_diff;
   
  /* wire      [9:0]  log_wrap_len;
   wire      [9:0]  shift_wrap_mask;
   wire      [9:0]  mask_wrap_addr;
  
   assign log_wrap_len = (INITIATOR_RLEN_in == 8'h0f) ? (10'b100) : ((INITIATOR_RLEN_in == 8'h07) ? (10'b011) : ((INITIATOR_RLEN_in == 8'h03) ? (10'b010) : 10'b01));
   assign shift_wrap_mask = (log_wrap_len + INITIATOR_RSIZE_in);
   assign mask_wrap_addr = (10'h3ff << shift_wrap_mask);*/
   
   
   assign INITIATOR_RLEN_eq_0 = (INITIATOR_RLEN_in == 0);
   
   assign size_in = $clog2(DATA_WIDTH_IN/8);   // Data width as quotient
   assign size_out = INITIATOR_RSIZE_in; 	       // just initiator size
   
   assign size_diff = (size_in - size_out);   // difference in sizes
     
  always @ (posedge clk or negedge arst_sync)
  begin
  if (~arst_sync | ~srst_sync)
    begin

	
        addr_out               <= 0;
        arid_out               <= 0;
        INITIATOR_RLEN_out        <= 0;
        INITIATOR_RSIZE_out       <= 0;
        fixed_flag_out         <= 0;
        wrap_flag_out          <= 0;
        to_wrap_boundary_out   <= 0;
   
        INITIATOR_RLEN_eq_0_out   <= 0;
        mask_pre               <= 0;
        rd_src_shift_pre       <= 0;
		
        rd_src_top             <= 0;    // top of rd_src (max value)
   
    end
  else
    begin
    if (pass_data)
      begin
	  
        addr_out               <= ({4'b0000, addr_in}  >> INITIATOR_RSIZE_in) ;
        arid_out               <= arid_in;
        INITIATOR_RLEN_out        <= INITIATOR_RLEN_in;
        INITIATOR_RSIZE_out       <= INITIATOR_RSIZE_in;
        fixed_flag_out         <= fixed_flag_in;
        wrap_flag_out          <= wrap_flag_in & extend_wrap_in;
        to_wrap_boundary_out   <= to_wrap_boundary_in;
		
        INITIATOR_RLEN_eq_0_out     <= INITIATOR_RLEN_eq_0;
   
        mask_pre               <= ((10'b1 << $clog2(DATA_WIDTH_IN/8)) - 10'b1) >> INITIATOR_RSIZE_in; // mask for read source
        rd_src_shift_pre       <= ($clog2(DATA_WIDTH_OUT/8) - INITIATOR_RSIZE_in);
		
        rd_src_top             <= (6'b0 | ((6'b1 << size_diff) - 6'b1));    // top of rd_src (max value)
	  
      end
    end
  end
  
  
caxi4interconnect_Hold_Reg_Ctrl DWC_DownConv_Calc_Hold_Reg_Ctrl (

                .arst_sync(arst_sync), // input
                .srst_sync(srst_sync), // input
                .clk(clk), // input

                .src_data_valid( ~rd_cmd_intr_fifo_empty_in ), // input
                .get_next_data_hold( rd_en_cmd_intr_in ), // input

                .pass_data( pass_data ), // output // Control the holding register
                .get_next_data_src( rd_en_cmd_intr_out ), // output
                .hold_data_valid( rd_cmd_intr_fifo_empty_out ) // output
				
	  
);

endmodule
