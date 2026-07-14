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
// SVN $Revision: 50705 $
// SVN $Date: 2026-03-04 23:39:23 +0530 (Wed, 04 Mar 2026) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns


module caxi4interconnect_CDC_grayCodeCounter #
  (
    parameter bin_rstValue = 1,
    parameter gray_rstValue = 0,
    parameter integer n_bits = 4
  )
  (
    input wire clk,
    input wire arst,
    input wire srst,

    input wire syncRst,
    input wire inc,

    output wire syncRstOut,
    output reg [n_bits-1:0] cntGray /* synthesis syn_safe_cdc = 1*/

  );
  
  reg  [n_bits-1:0]  cntBinary;
  wire [n_bits-1:0]  nextGray, cntBinary_next;

  always @ (posedge clk or negedge arst)
  begin
  if(~arst | ~srst)
    begin
        cntBinary               <= bin_rstValue;
        cntGray                 <= gray_rstValue;
    end
  else
    begin
      if (inc)
      begin
        if (!syncRst)
        begin
          cntBinary               <= bin_rstValue;
          cntGray                 <= gray_rstValue;
        end
        else
        begin
          cntBinary                 <= cntBinary_next;
          cntGray                   <= nextGray;
        end
     end	
    end
  end
  
assign cntBinary_next = cntBinary + 1;
assign syncRstOut = (cntBinary == 0) ? 1'b0 : 1'b1;

caxi4interconnect_Bin2Gray #
(
        .n_bits(n_bits)
)
 bin2gray_inst(
        .cntBinary(cntBinary),
        .nextGray(nextGray)
);

endmodule
