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



module caxi4interconnect_DWC_DownConv_preCalcCmdFifoWrCtrl #
(
  parameter DATA_WIDTH_OUT = 32,
  parameter DATA_WIDTH_IN = 32,
  parameter ADDR_WIDTH = 32,
  parameter USER_WIDTH = 32,
  parameter ID_WIDTH = 32,
  parameter WRITE_ENABLE = 1
)
  (
   input wire clk,
   input wire arst_sync,
   input wire srst_sync,


   input wire     [7:0]               INITIATOR_ALEN_in,
   input wire                         INITIATOR_AVALID_in,
   input wire     [ID_WIDTH - 1:0]    INITIATOR_AID_in,
   input wire     [ADDR_WIDTH - 1:0]  INITIATOR_AADDR_in,
   input wire     [1:0]               INITIATOR_ABURST_in,
   input wire     [3:0]               INITIATOR_ACACHE_in,
   input wire     [1:0]               INITIATOR_ALOCK_in,
   input wire     [2:0]               INITIATOR_ASIZE_in,
   input wire     [2:0]               INITIATOR_APROT_in,
   input wire     [3:0]               INITIATOR_AQOS_in,
   input wire     [3:0]               INITIATOR_AREGION_in,
   input wire     [USER_WIDTH - 1:0]  INITIATOR_AUSER_in,
   
   input wire      INITIATOR_AREADY_in, // from wrCmdFifoWriteCtrl

    
    output reg     [7:0]               INITIATOR_ALEN_out,
    output wire                        INITIATOR_AVALID_out, // Direct output from caxi4interconnect_Hold_Reg_Ctrl
    output reg     [ID_WIDTH - 1:0]    INITIATOR_AID_out,
    output reg     [ADDR_WIDTH - 1:0]  INITIATOR_AADDR_out,
    output reg     [1:0]               INITIATOR_ABURST_out,
    output reg     [3:0]               INITIATOR_ACACHE_out,
    output reg     [1:0]               INITIATOR_ALOCK_out,
    output reg     [2:0]               INITIATOR_ASIZE_out,
    output reg     [2:0]               INITIATOR_APROT_out,
    output reg     [3:0]               INITIATOR_AQOS_out,
    output reg     [3:0]               INITIATOR_AREGION_out,
    output reg     [USER_WIDTH - 1:0]  INITIATOR_AUSER_out,
    
    output wire                        INITIATOR_AREADY_out, // to the source, direct output from caxi4interconnect_Hold_Reg_Ctrl
    
    
    output reg [ADDR_WIDTH - 1:0]  INITIATOR_AADDR_mux_pre,
    
    output reg [4:0]               to_boundary_initiator_pre,
    output reg [5:0]               mask_addr_pre,
    output reg [2:0]               ASIZE_pre,
    output reg [12:0]              tot_len_pre,
    output reg [8:0]               max_length_comb_pre,
    output reg [8:0]               length_comb_pre,
    output reg [2:0]               WrapLogLen_comb_pre,
    output reg [5:0]               sizeMax_pre,
    output reg                     SameInitrTrgtSize_pre,
    output reg [5:0]               sizeCnt_comb_pre,
    output reg                     fixed_burst_pre,
    output reg [6:0]               unaligned_fixed_len_iter_pre
  );

  localparam   INITIATOR_MAX_SIZE      = $clog2(DATA_WIDTH_IN/8);
  localparam   [5:0] INITIATOR_SIZE_MAX_MASK = (1<<INITIATOR_MAX_SIZE)-1;
  localparam   MAX_SIZE             = (DATA_WIDTH_IN/DATA_WIDTH_OUT) - 1;
  
  wire [4:0]   addr_beat;

  wire [4:0]   to_boundary_initiator;
  wire [5:0]   mask_addr;
  
  wire         reduce_tx_size;
  
  wire [12:0]  tot_len_aligned;
  wire [5:0]   len_offset;
  wire [5:0]   fixed_burst_length_offset;
  wire [12:0]  tot_incr_len;
  wire [12:0]  tot_len;
  wire [5:0]   mask_len;
  
  wire [2:0]   WrapLogLen_comb;
  wire [8:0]   max_length_comb;
  wire [8:0]   max_length_fixed_burst;
  wire [8:0]   length_comb;
  
  wire [2:0]   ASIZE;
  wire [2:0]   sizeDiff;
  wire [5:0]   SizeMax;
  wire [5:0]   fixed_burst_sizemax;
  wire         SameInitrTrgtSize;
  
  wire [5:0]   sizeCnt_comb;
  wire [5:0]   mask_sizeCnt;

  wire [1:0]   INCR, FIXED;
  
  wire         pass_data;
  wire [ADDR_WIDTH - 1:0]  INITIATOR_AADDR_mux;
  
  wire                     fixed_burst;
  wire [6:0]               unaligned_fixed_len_iter;  
  
  always @ (posedge clk or negedge arst_sync)
  begin
  if (~arst_sync | ~srst_sync)
    begin
    
      INITIATOR_ALEN_out               <= 0;
      INITIATOR_AID_out                <= 0;
      INITIATOR_AADDR_out              <= 0;
      INITIATOR_ABURST_out             <= 0;
      INITIATOR_ACACHE_out             <= 0;
      INITIATOR_ALOCK_out              <= 0;
      INITIATOR_ASIZE_out              <= 0;
      INITIATOR_APROT_out              <= 0;
      INITIATOR_AQOS_out               <= 0;
      INITIATOR_AREGION_out            <= 0;
      INITIATOR_AUSER_out              <= 0;
        
        
        
      INITIATOR_AADDR_mux_pre          <= 0; 
      to_boundary_initiator_pre           <= 0;
      mask_addr_pre                    <= 0;
      ASIZE_pre                        <= 0;
      tot_len_pre                      <= 0;
      max_length_comb_pre              <= 0;
      length_comb_pre                  <= 0;
      WrapLogLen_comb_pre              <= 0;
      sizeMax_pre                      <= 0;
      SameInitrTrgtSize_pre              <= 0;
      sizeCnt_comb_pre                 <= 0;
	  
      fixed_burst_pre                  <= 0;
      unaligned_fixed_len_iter_pre     <= 0;	  
      
    end
  else
    begin
    if (pass_data)
      begin
          
                  
        INITIATOR_ALEN_out               <= INITIATOR_ALEN_in;
        INITIATOR_AID_out                <= INITIATOR_AID_in;
        INITIATOR_AADDR_out              <= INITIATOR_AADDR_in;
        INITIATOR_ABURST_out             <= INITIATOR_ABURST_in ;
        INITIATOR_ACACHE_out             <= INITIATOR_ACACHE_in;
        INITIATOR_ALOCK_out              <= INITIATOR_ALOCK_in;
        INITIATOR_ASIZE_out              <= INITIATOR_ASIZE_in;
        INITIATOR_APROT_out              <= INITIATOR_APROT_in;
        INITIATOR_AQOS_out               <= INITIATOR_AQOS_in;
        INITIATOR_AREGION_out            <= INITIATOR_AREGION_in;
        INITIATOR_AUSER_out              <= INITIATOR_AUSER_in;
        
        
        to_boundary_initiator_pre           <= to_boundary_initiator;
        mask_addr_pre                    <= mask_addr;
        ASIZE_pre                        <= ASIZE;
        tot_len_pre                      <= tot_len;
        max_length_comb_pre              <= max_length_comb;
        length_comb_pre                  <= length_comb;
        WrapLogLen_comb_pre              <= WrapLogLen_comb;
        sizeMax_pre                      <= SizeMax;
        SameInitrTrgtSize_pre              <= SameInitrTrgtSize;
        sizeCnt_comb_pre                 <= sizeCnt_comb;
        INITIATOR_AADDR_mux_pre          <= INITIATOR_AADDR_mux;
		
        fixed_burst_pre                  <= fixed_burst;
        unaligned_fixed_len_iter_pre     <= unaligned_fixed_len_iter;
      end
    end
  end
  

  assign addr_beat = {1'b0, INITIATOR_AADDR_in[INITIATOR_ASIZE_in+:4]} & INITIATOR_ALEN_in[4:0];

  assign to_boundary_initiator = (INITIATOR_ALEN_in[4:0] + 5'b1) - addr_beat;
  assign mask_addr = (6'h3f << ASIZE);


  assign reduce_tx_size = (INITIATOR_ASIZE_in > $clog2(DATA_WIDTH_OUT/8));

  // compute the total length as function of the initiator transfer size, data widths and burst length
  // if the initiator and target transfer sizes differ, the total length of a fixed burst is the initiator length shifted by sizeDiff

  assign tot_len_aligned = (({5'b0, INITIATOR_ALEN_in} + 13'd1) << (INITIATOR_ASIZE_in-$clog2(DATA_WIDTH_OUT/8)));

  assign len_offset = ((INITIATOR_AADDR_in[5:0] & mask_len) >> $clog2(DATA_WIDTH_OUT/8));

  assign tot_incr_len = tot_len_aligned - len_offset;
  
  assign unaligned_fixed_len_iter = reduce_tx_size & fixed_burst ? ((1<<sizeDiff)-len_offset) : 1'b1;

  assign tot_len = reduce_tx_size ? (INITIATOR_ABURST_in == FIXED) ? ({5'b0, INITIATOR_ALEN_in} + 13'd1) : tot_incr_len : ({5'b0, INITIATOR_ALEN_in} + 13'd1);
  assign mask_len = (6'b0 | ((6'b1 << INITIATOR_ASIZE_in) - 1'b1));

  assign WrapLogLen_comb = (INITIATOR_ALEN_in == 8'h0f) ? 3'h4 :
        ((INITIATOR_ALEN_in == 8'h07) ? 3'h3 :
        ((INITIATOR_ALEN_in == 8'h03) ? 3'h2 : 3'h1));

  assign max_length_fixed_burst = tot_len[8:0];
  
  assign max_length_comb = (INITIATOR_ABURST_in == INCR) ? 9'h100 : ((INITIATOR_ABURST_in == FIXED) ? tot_len[8:0] : (9'h010 << sizeDiff));
 
  assign length_comb =  max_length_comb;
  // combinatorial calculation of the target transfer size.
  // if a initiator beat has to be split, utilize the full width of the target data bus otherwise pass the initiator transfer size through
  assign ASIZE = (reduce_tx_size) ? $clog2(DATA_WIDTH_OUT/8) : INITIATOR_ASIZE_in;

  assign sizeDiff = INITIATOR_ASIZE_in - ASIZE;
  assign fixed_burst_sizemax = fixed_burst_length_offset + (6'b1 << sizeDiff) - len_offset - 1'b1;
  assign SizeMax = fixed_burst & WRITE_ENABLE ? fixed_burst_sizemax : (6'b0 | ((6'b1 << sizeDiff) - 1'b1));
  assign SameInitrTrgtSize = fixed_burst ? (((1<<sizeDiff)-1 == len_offset) | (INITIATOR_ASIZE_in == ASIZE)) : (INITIATOR_ASIZE_in == ASIZE);

  assign fixed_burst_length_offset = ((INITIATOR_AADDR_in[5:0] & ((1<<INITIATOR_MAX_SIZE)-1)) >> $clog2(DATA_WIDTH_OUT/8));
  
  assign sizeCnt_comb = fixed_burst & WRITE_ENABLE  ? fixed_burst_length_offset : ((INITIATOR_AADDR_in[5:0] & mask_sizeCnt) >> ASIZE);


  assign mask_sizeCnt = (6'b0 | ((6'b1 << INITIATOR_ASIZE_in) - 1'b1));

  assign INITIATOR_AADDR_mux = ((INITIATOR_ABURST_in == FIXED) && (~SameInitrTrgtSize)) ? {INITIATOR_AADDR_in[ADDR_WIDTH-1:6], (INITIATOR_AADDR_in[5:0] & mask_addr)} : INITIATOR_AADDR_in;

  assign INCR  = 2'b01;
  assign FIXED = 2'b00;
  
  assign fixed_burst = ((INITIATOR_ABURST_in == FIXED)) ;


caxi4interconnect_Hold_Reg_Ctrl DWC_DownConv_Calc_Hold_Reg_Ctrl (

                .arst_sync(arst_sync), // input
                .srst_sync(srst_sync), // input
                .clk(clk), // input

                .src_data_valid( INITIATOR_AVALID_in ), // input
                .get_next_data_hold( INITIATOR_AREADY_in ), // input

                .pass_data( pass_data ), // output // Control the holding register
                .get_next_data_src( INITIATOR_AREADY_out ), // output
                .hold_data_valid( INITIATOR_AVALID_out ) // output
);

endmodule
