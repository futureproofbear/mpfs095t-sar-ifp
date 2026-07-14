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
module caxi4interconnect_byte2bit (
                                 //  input ports
                                 shifted_trgt_mask_bit,
                                 shifted_intr_mask_bit,
 
                                 //  output ports
                                 shifted_trgt_mask_byte,
                                 shifted_intr_mask_byte
                                 );
 
   parameter        DATA_WIDTH_IN             = 32;
   parameter        DATA_WIDTH_OUT            = 32;
//  output ports
   output     [DATA_WIDTH_IN - 1:0] shifted_trgt_mask_bit;
   wire      [DATA_WIDTH_IN - 1:0] shifted_trgt_mask_bit;
   output     [DATA_WIDTH_OUT - 1:0] shifted_intr_mask_bit;
   wire      [DATA_WIDTH_OUT - 1:0] shifted_intr_mask_bit;
//  input ports
   input    [(DATA_WIDTH_IN / 8) - 1:0] shifted_trgt_mask_byte;
   wire      [(DATA_WIDTH_IN / 8) - 1:0] shifted_trgt_mask_byte;
   input    [(DATA_WIDTH_OUT / 8) - 1:0] shifted_intr_mask_byte;
   wire      [(DATA_WIDTH_OUT / 8) - 1:0] shifted_intr_mask_byte;

   genvar i;

   generate
     for (i=0;i<(DATA_WIDTH_IN/8);i=i+1) begin
       assign shifted_trgt_mask_bit[(8*i)+:8] = {8{shifted_trgt_mask_byte[i]}};
     end
   endgenerate

   generate
     for (i=0;i<(DATA_WIDTH_OUT/8);i=i+1) begin
       assign shifted_intr_mask_bit[(8*i)+:8] = {8{shifted_intr_mask_byte[i]}};
     end
   endgenerate

endmodule

