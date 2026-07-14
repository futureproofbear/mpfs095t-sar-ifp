`timescale 1ns / 1ns
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  Microchip Technology  Proprietary and Confidential
  Copyright (c) 2020 Microchip, All rights reserved.

   ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
   ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
   IN ADVANCE IN WRITING.

   ======================================================================
   Filename        : corejesd204c_txbuf.v
   Description     : Place holder for transmit CoreJESD204C Blocks with user data
                   :
   Author          :
   Date Created    : 26-07-2022
   Last Modified By: $Author: $
   Last Modified On: $Date: 2023-09-04 19:32:15 +0530 (Mon, 04 Sep 2023) $
   Modification    : $Revision: 43992 $
  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
module caxi4c_buff_dncnv #(
  parameter W_DWIDTH    = 128,
  parameter W_MEM_SIZE  = 2,
  parameter W_ADDRWIDTH = 1,
  parameter R_DWIDTH    = 64,
  parameter R_MEM_SIZE  = 4,
  parameter R_ADDRWIDTH = 2,
  parameter RAM_SEL     = 0,
  parameter PIPE        = 2
  )(
  input  wire w_clk,
  input  wire r_clk,
  input  wire w_en,
  input  wire r_en,
  input  wire [W_ADDRWIDTH:0] w_addr,
  input  wire [R_ADDRWIDTH:0] r_addr,
  input  wire [W_DWIDTH-1:0] w_data,
  output wire [R_DWIDTH-1:0] r_data
  );
  generate
    if(RAM_SEL == 2) //LSRAM
    begin  : txbuf_lsram
      caxi4c_buff_dncnv_lsram #(
        .W_DWIDTH( W_DWIDTH ),
        .W_MEM_SIZE ( W_MEM_SIZE ),
        .W_ADDRWIDTH ( W_ADDRWIDTH ),
        .R_DWIDTH ( R_DWIDTH ),
        .R_MEM_SIZE ( R_MEM_SIZE ),
        .R_ADDRWIDTH ( R_ADDRWIDTH ),
        .PIPE ( PIPE )
        ) u_caxi4c_buff_dncnv_lsram (
        .w_clk ( w_clk ),
        .r_clk ( r_clk ),
        .w_en  ( w_en ),
        .r_en  ( r_en ),
        .w_addr( w_addr ),
        .r_addr( r_addr ),
        .w_data( w_data ),
        .r_data( r_data )
      );
      end
      else if(RAM_SEL == 3)  //URAM
      begin : txbuf_uram
        caxi4c_buff_dncnv_usram #(
          .W_DWIDTH( W_DWIDTH ),
          .W_MEM_SIZE ( W_MEM_SIZE ),
          .W_ADDRWIDTH ( W_ADDRWIDTH ),
          .R_DWIDTH ( R_DWIDTH ),
          .R_MEM_SIZE ( R_MEM_SIZE ),
          .R_ADDRWIDTH ( R_ADDRWIDTH ),
          .PIPE ( PIPE )
          ) u_caxi4c_buff_dncnv_usram (
          .w_clk ( w_clk ),
          .r_clk ( r_clk ),
          .w_en  ( w_en ),
          .r_en  ( r_en ),
          .w_addr( w_addr ),
          .r_addr( r_addr ),
          .w_data( w_data ),
          .r_data( r_data )
        );
        end
        else begin : txbuf_reg
        caxi4c_buff_dncnv_reg #( //FPGA Resources
          .W_DWIDTH( W_DWIDTH ),
          .W_MEM_SIZE ( W_MEM_SIZE ),
          .W_ADDRWIDTH ( W_ADDRWIDTH ),
          .R_DWIDTH ( R_DWIDTH ),
          .R_MEM_SIZE ( R_MEM_SIZE ),
          .R_ADDRWIDTH ( R_ADDRWIDTH ),
          .PIPE ( PIPE )
          ) u_caxi4c_buff_dncnv_lut (
          .w_clk ( w_clk ),
          .r_clk ( r_clk ),
          .w_en  ( w_en ),
          .r_en  ( r_en ),
          .w_addr( w_addr ),
          .r_addr( r_addr ),
          .w_data( w_data ),
          .r_data( r_data )
        );
        end
      endgenerate
endmodule
