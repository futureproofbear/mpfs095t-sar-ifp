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



module caxi4interconnect_DWC_UpConv_preCalcAChannel #
(
  parameter DATA_WIDTH_OUT = 32,
  parameter ADDR_WIDTH = 32,
  parameter USER_WIDTH = 32,
  parameter ID_WIDTH = 32
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
	  
    output reg        [7:0]  alen_wrap_pre,  
    output reg        [7:0]  alen_sec_wrap_pre,   
    output reg        [4:0]  to_boundary_initiator_pre,
    output reg        [9:0]  mask_wrap_addr_pre,  
    output reg       [2:0]   sizeDiff_pre,
    output reg               unaligned_wrap_burst_comb_pre,
    output reg        [5:0]  len_offset_pre,
    output reg               wrap_tx_pre,
    output reg               fixed_flag_comb_pre
   

  );

  
   wire [1:0]   INCR, FIXED, WRAP;
  
   wire         pass_data;
  
   wire        [4:0]  to_boundary_initiator;
   wire        [9:0]  mask_wrap_addr;  
   wire       [2:0]   sizeDiff;
   wire               unaligned_wrap_burst_comb;
   wire        [5:0]  len_offset;
   wire               wrap_tx;
   wire               fixed_flag_comb;   
   
   wire      [5:0]  mask;
   wire      [4:0]  addr_beat;
  
  
   assign to_boundary_initiator =  (INITIATOR_ALEN_in[4:0] + 5'b1) - addr_beat;
   assign mask_wrap_addr = (({2'b00, INITIATOR_ALEN_in} + 10'd1) << INITIATOR_ASIZE_in) - 10'd1;
   assign sizeDiff = ($clog2(DATA_WIDTH_OUT/8) - INITIATOR_ASIZE_in);
   assign unaligned_wrap_burst_comb = ~((INITIATOR_AADDR_in[9:0] & mask_wrap_addr) == 0);
   assign len_offset = (INITIATOR_AADDR_in[5:0] & mask) >> INITIATOR_ASIZE_in;
   assign wrap_tx = unaligned_wrap_burst_comb & (INITIATOR_ABURST_in == WRAP);
   assign fixed_flag_comb = (INITIATOR_ABURST_in == FIXED);
		 
  
   // use initiator address when INITIATOR_AVALID is asserted otherwise use the latched version
   assign addr_beat = {1'b0, INITIATOR_AADDR_in[INITIATOR_ASIZE_in+:4]} & INITIATOR_ALEN_in[4:0];
   assign mask = (DATA_WIDTH_OUT/8) - 1; 
		 
   assign INCR  = 2'b01;
   assign FIXED = 2'b00;
   assign WRAP = 2'b10;
  
  
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
        
        to_boundary_initiator_pre        <= 0;
        mask_wrap_addr_pre            <= 0;
        sizeDiff_pre                  <= 0;
        unaligned_wrap_burst_comb_pre <= 0;
        len_offset_pre                <= 0;
        wrap_tx_pre                   <= 0;
        fixed_flag_comb_pre           <= 0;
        alen_sec_wrap_pre             <= 0;
        alen_wrap_pre             <= 0;
   
    end
  else
    begin
    if (pass_data)
      begin
	  
        INITIATOR_ALEN_out                  <= INITIATOR_ALEN_in;
        INITIATOR_AID_out                   <= INITIATOR_AID_in;
        INITIATOR_AADDR_out                 <= INITIATOR_AADDR_in;
        INITIATOR_ABURST_out                <= INITIATOR_ABURST_in ;
        INITIATOR_ACACHE_out                <= INITIATOR_ACACHE_in;
        INITIATOR_ALOCK_out                 <= INITIATOR_ALOCK_in;
        INITIATOR_ASIZE_out                 <= INITIATOR_ASIZE_in;
        INITIATOR_APROT_out                 <= INITIATOR_APROT_in;
        INITIATOR_AQOS_out                  <= INITIATOR_AQOS_in;
        INITIATOR_AREGION_out               <= INITIATOR_AREGION_in;
        INITIATOR_AUSER_out                 <= INITIATOR_AUSER_in;
        
        to_boundary_initiator_pre        <= to_boundary_initiator;
        mask_wrap_addr_pre            <= mask_wrap_addr;
        sizeDiff_pre                  <= sizeDiff;
        unaligned_wrap_burst_comb_pre <= unaligned_wrap_burst_comb;
        len_offset_pre                <= len_offset;
        wrap_tx_pre                   <= wrap_tx;
        fixed_flag_comb_pre           <= fixed_flag_comb;
		alen_sec_wrap_pre             <= (INITIATOR_ALEN_in - {3'b000, to_boundary_initiator}) >> sizeDiff;
		alen_wrap_pre                 <= (({3'b000, to_boundary_initiator} - 8'b1) >>  sizeDiff);
	  
      end
    end
  end
  
  



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
