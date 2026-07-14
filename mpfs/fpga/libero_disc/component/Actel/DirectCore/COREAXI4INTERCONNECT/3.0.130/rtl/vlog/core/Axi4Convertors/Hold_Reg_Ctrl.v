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
// SVN $Revision: 49195 $
// SVN $Date: 2025-06-22 15:17:42 +0530 (Sun, 22 Jun 2025) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_Hold_Reg_Ctrl

  (
    input wire arst_sync,
    input wire srst_sync,
    input wire clk,

	input wire src_data_valid, //!fifo_empty,
	input wire get_next_data_hold,
	
    
	output wire pass_data,
	output wire get_next_data_src, //fifo_rd_en,
	output reg  hold_data_valid //!hold_reg_empty

  );

	// Allow data into holding register when data is being taken from the holding register OR the holding register is empty.
	assign pass_data = (get_next_data_hold | !hold_data_valid);
	
	// Read more data from the source as there is data available at the source and we're passing the previous data to the holding register.
	assign get_next_data_src = (src_data_valid & pass_data); 
	
  always @(posedge clk or negedge arst_sync) begin
    if (~arst_sync | ~srst_sync) begin
       hold_data_valid <= 'b0;
			end
    else begin
    // When passing data, indicate that data in the holding register is valid if source data was valid.
			if (pass_data)	hold_data_valid <= src_data_valid;

    end
  end

endmodule

