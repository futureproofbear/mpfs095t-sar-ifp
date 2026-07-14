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
// SVN $Revision: 47415 $
// SVN $Date: 2024-09-15 15:58:24 +0530 (Sun, 15 Sep 2024) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns
module caxi4interconnect_ResetSync  # 
    (
	    parameter         SYNC_RESET = 0,
	    parameter integer FAMILY     = 26
	)
	(
		input  wire             	sysClk,
		input  wire                 sysReset_L,			// active low reset synchronoise to RE AClk - asserted async.

		output wire					arst_sync,			// active low sysReset synchronised to sysClk
		output wire					srst_sync			// active low sysReset synchronised to sysClk
	) /* synthesis syn_preserve = 1 syn_noprune = 1*/ ;
   						 
						 
//================================================================================================
// Local Parameters
//================================================================================================

localparam NUM_STAGES     = 3;	
	

reg  [NUM_STAGES-1:0]  sync_ff = 0;

generate 
  if(SYNC_RESET == 0)
    begin 
      always @( posedge sysClk or negedge sysReset_L) 
        if (!sysReset_L) sync_ff <= 0;
        else             sync_ff <= {sync_ff[NUM_STAGES-2:0],1'b1}; 		

	  assign srst_sync = 1;
	  
      if(FAMILY == 28)	  
	    CLKINT I_CLKINT( .A(sync_ff[NUM_STAGES-1]), .Y(arst_sync) );
	  else 
	    assign arst_sync = sync_ff[NUM_STAGES-1];

    end 
  else 
    begin
      always @( posedge sysClk) 
        sync_ff <= {sync_ff[NUM_STAGES-2:0],sysReset_L};
		  
      assign srst_sync = sync_ff[NUM_STAGES-1];		  
	  assign arst_sync = 1;
	end
endgenerate	

endmodule // caxi4interconnect_ResetSycnc.v
