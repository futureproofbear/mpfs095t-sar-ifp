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



module caxi4interconnect_RAM_BLOCK #

	(
		parameter integer	MEM_DEPTH	 = 1024,
		parameter integer	ADDR_WIDTH	 = 10,
		parameter integer	DATA_WIDTH	 = 32,
		parameter integer	INITIATOR_BCHAN = 0
	)
	(
		input wire clk,

		input wire wr_en,
		input wire [ADDR_WIDTH-1:0] rd_addr,
		input wire [ADDR_WIDTH-1:0] wr_addr,
		input wire [DATA_WIDTH-1:0] data_in,

		output wire [DATA_WIDTH-1:0] data_out
	);

	
	
	
	generate 
	  if(INITIATOR_BCHAN)
	    begin
	      reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0] /* synthesis syn_raintryle = "uram" */;
		  
		  assign data_out = mem[rd_addr];
		  
	      always @(posedge clk) 
		    begin
		      if (wr_en) 
			    begin
			      mem[wr_addr] <= data_in;
		        end
	        end
        end		
	  else 
	    begin 
	      reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0];
		  
		  assign data_out = mem[rd_addr];
		  
	      always @(posedge clk) 
		    begin
		      if (wr_en) 
			    begin
			      mem[wr_addr] <= data_in;
		        end
	        end
		end 
	endgenerate
endmodule
