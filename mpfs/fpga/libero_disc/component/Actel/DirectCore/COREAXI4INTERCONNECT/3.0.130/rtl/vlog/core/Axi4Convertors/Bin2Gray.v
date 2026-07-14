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
// SVN $Revision: 49159 $
// SVN $Date: 2025-06-13 01:46:17 +0530 (Fri, 13 Jun 2025) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns


module caxi4interconnect_Bin2Gray #
  (
  parameter integer n_bits = 4
  )
  (
   input wire [n_bits-1:0]  cntBinary,

   output wire [n_bits-1:0] nextGray
  );

  genvar i;
  generate
  for (i = 0; i < (n_bits-1) ; i = i + 1) 
    begin
      assign nextGray[i] = cntBinary[i] ^ cntBinary[i+1];
    end
  endgenerate

  assign nextGray[n_bits-1] = cntBinary[n_bits-1];

endmodule
