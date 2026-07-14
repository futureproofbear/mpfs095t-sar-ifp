// ********************************************************************/
// Actel Corporation Proprietary and Confidential
//  Copyright 2011 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: doubleSync.v
//
//
//
// Revision Information:
// Date     Description
//
// SVN Revision Information:
// SVN $Revision: 44143 $
// SVN $Date: 2023-09-21 20:36:05 +0530 (Thu, 21 Sep 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ********************************************************************/

`timescale 1ns / 1ns

module caxi4c_corefifo_NstagesSync(
                  clk,
                  //rstn,
                  arstn,//added in v3.0
                  srstn,//added in v3.0
                  inp,
                  sync_out
                  );

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
  parameter NUM_STAGES = 2;
  parameter ADDRWIDTH = 3;
  parameter SYNC_RESET = 0;

input clk;
//input rstn;commented in v3.0
input arstn;//added in v3.0
input srstn;//added in v3.0
input [ADDRWIDTH : 0 ] inp;
output [ADDRWIDTH : 0 ] sync_out;

//reg [WIDTH -1:0] signal_out;

reg [ADDRWIDTH : 0 ] shift_reg /* synthesis syn_preserve = 1*/;
reg [ADDRWIDTH : 0 ] shift_mem_reg [NUM_STAGES-2:0] ;


integer i;
generate 
  if(SYNC_RESET == 0) begin 

    always @ ( posedge clk or negedge arstn) 
      begin	
        if (!arstn) 
    		shift_reg <= 'h0;
    	else
    		shift_reg <= inp;
    
      end 
    
    always @ ( posedge clk or negedge arstn) 
      begin	
        if (!arstn) 
          begin
            for(i = 0; i < NUM_STAGES-1 ; i = i+1) 
              begin
    		      shift_mem_reg[i] <= 0;
              end
          end
     /// signal_out <= 'h0;
        else
          begin  
    	      for(i = 0; i < NUM_STAGES-1 ; i = i+1)
              begin 	  
    	          if(i == 0)
    	  	      shift_mem_reg[i] <= shift_reg;
    	          else 
    	  	      shift_mem_reg[i] <= shift_mem_reg[i-1];
              end 
          end
      end 
    
    assign sync_out = shift_mem_reg[NUM_STAGES-2];
  end else begin 
    always @ ( posedge clk) 
      begin	
  	    shift_reg <= inp;    
      end 
    
    always @ ( posedge clk) 
      begin	
        if (!srstn) 
          begin
            for(i = 0; i < NUM_STAGES-1 ; i = i+1) 
              begin
    		      shift_mem_reg[i] <= 0;
              end
          end
     /// signal_out <= 'h0;
        else
          begin  
    	      for(i = 0; i < NUM_STAGES-1 ; i = i+1)
              begin 	  
    	          if(i == 0)
    	  	      shift_mem_reg[i] <= shift_reg;
    	          else 
    	  	      shift_mem_reg[i] <= shift_mem_reg[i-1];
              end 
          end
      end 
    
    assign sync_out = shift_mem_reg[NUM_STAGES-2];

  end 
endgenerate
   
endmodule // corefifo_doubleSync

   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------
