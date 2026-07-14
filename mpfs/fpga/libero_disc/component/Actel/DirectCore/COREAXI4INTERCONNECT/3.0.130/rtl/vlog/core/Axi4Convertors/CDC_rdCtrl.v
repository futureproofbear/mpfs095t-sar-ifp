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
// SVN $Revision: 49514 $
// SVN $Date: 2025-08-10 00:53:16 +0530 (Sun, 10 Aug 2025) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns
 
module caxi4interconnect_CDC_rdCtrl (
                   //  input ports
                   clk,
                   rdclk_arst,
                   rdclk_srst,
                   rdPtr_gray,
                   wrPtr_gray,
                   nextrdPtr_gray,
                   readyForOut,
 
                   //  output ports
                   infoOutValid,
                   fifoRe
                   );
 
   parameter        ADDR_WIDTH       = 3;
//  input ports
   input            clk;
   wire             clk;
   input            rdclk_arst;
   input            rdclk_srst;
   wire             rdclk_arst;
   input     [ADDR_WIDTH - 1:0] rdPtr_gray;
   wire      [ADDR_WIDTH - 1:0] rdPtr_gray;
   input     [ADDR_WIDTH - 1:0] wrPtr_gray;
   wire      [ADDR_WIDTH - 1:0] wrPtr_gray;
   input     [ADDR_WIDTH - 1:0] nextrdPtr_gray;
   wire      [ADDR_WIDTH - 1:0] nextrdPtr_gray;
   input            readyForOut;
   wire             readyForOut;
//  output ports
   output           infoOutValid;
   wire             infoOutValid;
   output           fifoRe;
   wire             fifoRe;
//  local signals
   wire             ptrsEq_rdZone;
   wire             wrEqRdP1;
   reg              empty;
 
 
   always @( posedge clk or negedge rdclk_arst )
   begin   :RdCtrl
 
      if (~rdclk_arst | ~rdclk_srst)
      begin
         empty <= 1'b1;
      end
      else
      begin
         if (ptrsEq_rdZone)
         begin
         end
         else
         begin
            if (wrEqRdP1)
            begin
               if (fifoRe)
               begin
                  empty <= 1'b1;
               end
               else
               begin
                  empty <= 1'b0;
               end
            end
            else if(wrEqRdP1 == 0)
            begin
               empty <= 1'b0;
            end
            else //if wrEqRdP1 is unknown in case when synchronous reset is used
            begin 
               empty <= 1'b1;
            end 
         end
      end
   end
 
   assign ptrsEq_rdZone = (rdPtr_gray == wrPtr_gray);
   assign wrEqRdP1 = (wrPtr_gray == nextrdPtr_gray);
 
   assign fifoRe = infoOutValid & readyForOut;
   assign infoOutValid = !empty;
 
 
endmodule

