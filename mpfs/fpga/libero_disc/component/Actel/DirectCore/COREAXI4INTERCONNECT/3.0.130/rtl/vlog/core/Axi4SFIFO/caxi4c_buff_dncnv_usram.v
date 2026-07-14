`timescale 1ns / 1ns
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  Microchip Technology  Proprietary and Confidential
  Copyright (c) 2020 Microchip, All rights reserved.

   ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
   ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
   IN ADVANCE IN WRITING.

   ======================================================================
   Filename        : corejesd204c_txbuf_uram.v
   Description     : Place holder for transmit CoreJESD204C Blocks with user data
                   :
   Author          :
   Date Created    : 26-07-2022
   Last Modified By: $Author: $
   Last Modified On: $Date: 2023-09-01 12:37:32 +0530 (Fri, 01 Sep 2023) $
   Modification    : $Revision: 43978 $
  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
module caxi4c_buff_dncnv_usram #(
  parameter W_DWIDTH    = 128,
  parameter W_MEM_SIZE  = 4096,
  parameter W_ADDRWIDTH = 12,
  parameter R_DWIDTH    = 64,
  parameter R_MEM_SIZE  = 8192,
  parameter R_ADDRWIDTH = 13,
  parameter PIPE        = 2
  )(
  input  wire w_clk,
  input  wire r_clk,
  input  wire w_en,
  input  wire r_en,
  input  wire [W_ADDRWIDTH:0] w_addr,
  input  wire [R_ADDRWIDTH:0] r_addr,
  input  wire [W_DWIDTH-1:0] w_data,
  output reg  [R_DWIDTH-1:0] r_data
  );

  `define MAX(a,b) {(a) > (b) ? (a) : (b)}
  `define MIN(a,b) {(a) < (b) ? (a) : (b)}
  localparam MAXSIZE = `MAX(W_MEM_SIZE, R_MEM_SIZE);
  localparam MAXWIDTH = `MAX(W_DWIDTH, R_DWIDTH);
  localparam MINWIDTH = `MIN(W_DWIDTH, R_DWIDTH);
  localparam RATIO = MAXWIDTH / MINWIDTH;
  localparam LOG2RATIO = $clog2(RATIO);

  reg [R_ADDRWIDTH:0] r_addr_r;
  reg [MINWIDTH-1:0] ram [0:MAXSIZE-1] /* synthesis syn_raintryle = uram */;
  reg [R_DWIDTH-1:0] readb;

  genvar i;
  generate for (i = 0; i < RATIO; i = i+1)
  begin: ramwrite
    localparam [LOG2RATIO-1:0] lsbaddr = i;

    always @(posedge w_clk)
    begin
    if (w_en)
    begin
      ram[{w_addr, lsbaddr}] <= w_data[i*MINWIDTH +: MINWIDTH];
    end
    end
  end
  endgenerate

  generate
  if(PIPE != 0)
  begin : pipelined_address
    always @(posedge r_clk)
    begin
      if (r_en)
        r_addr_r <= r_addr;
    end
  end
  else
  begin : non_pipelined_address
    always @ (*)
	r_addr_r <= r_addr;
  end
  endgenerate

  always @ (*)  readb = ram[r_addr_r];

  generate
  if(PIPE == 2)
  begin : pipelined_data
    always @ (posedge r_clk)
      r_data <= readb;
  end
  else
  begin : non_pipelined_data
    always @ (*)
      r_data = readb;
  end
  endgenerate

endmodule
