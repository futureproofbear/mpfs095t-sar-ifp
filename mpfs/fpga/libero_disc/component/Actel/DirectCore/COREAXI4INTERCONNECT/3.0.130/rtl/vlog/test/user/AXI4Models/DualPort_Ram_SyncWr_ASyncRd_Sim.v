// ********************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2024 Microchip Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description:  COREAXI4INTERCONNECT. 
//
// SVN Revision Information:
// SVN $Revision: 48159 $
// SVN $Date: 2025-01-07 19:27:50 +0530 (Tue, 07 Jan 2025) $
//
//
// Notes:
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_DualPort_RAM_SyncWr_ASyncRd_Sim (
					// AHB global signals
					HCLK,

					// Write Port
					fifoWrAddr,	
					fifoWrite,
					fifoWrStrb,					
					fifoWrData,

					// Read Port
					fifoRdAddr,
					fifoRdData
				   
				);

   

//============================================
// Parameter Declarations
//============================================

	parameter FIFO_AWIDTH = 9;
	
	parameter FIFO_WIDTH = 8;
	
	localparam [32:0] FIFO_DEPTH = 1 << FIFO_AWIDTH;

	localparam NUM_BYTES = (FIFO_WIDTH/8);
	
	localparam ADDR_NC_BITS = 	$clog2(FIFO_WIDTH/8);

//============================================================================
// I/O ports
//============================================================================

	input HCLK;								// ahb system clock

	
// Write Port signals
	input [FIFO_WIDTH-1:0]					fifoWrData;		// Data to be written to ram
	input [FIFO_AWIDTH+ADDR_NC_BITS-1:0] 	fifoWrAddr;		// Addr to be written to in RAM
	input [NUM_BYTES - 1:0]					fifoWrStrb ;		// One strobe per byte

	input fifoWrite;						// Indicates address defined by fifoWrAddr to be written

 // Read Port signals
	output [FIFO_WIDTH-1:0]					fifoRdData;	// Data to be written to ram
	input  [FIFO_AWIDTH+ADDR_NC_BITS-1:0] 	fifoRdAddr;	// Addr to be read from RAM

   
//============================================
// I/O Declarations
//============================================

	wire [FIFO_WIDTH-1:0]		fifoRdData;		// Data to be read from register

	
//============================================
// Local Declarations
//============================================

	localparam [FIFO_WIDTH-1:0]	element = { FIFO_WIDTH{1'b1} };
	
	reg [FIFO_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

	integer j;
	
	initial // Read the memory contents in the file
            // ram_init.txt. 
		begin
			for (j=0; j<FIFO_DEPTH; j=j+1)
				begin
					mem[j] = { FIFO_WIDTH{ 1'b1 } };		// set to all 1s
				end
		end

	wire [FIFO_AWIDTH -1 :0]	fifoRdAddr_nc; 
	wire [FIFO_AWIDTH -1 :0]	fifoWrAddr_nc; 
	
	wire [FIFO_WIDTH - 1:0]		fifoRdModWrData;
	wire [FIFO_WIDTH - 1:0]		fifoWrDataIn;
	
	
//========================================================================================
// Generate Byte Write Lanes
//========================================================================================
	
	assign fifoRdModWrData = mem[fifoWrAddr_nc];	// Read the Data in the Location to be Written
	
	genvar i;										// Select Stored Read Data if it is not	
	generate										// Select the Input Byte if Strobe is Active, 
		for (i = 0; i < NUM_BYTES; i = i + 1)
			begin
				assign fifoWrDataIn[((i+1)*8) -1:(i*8) ] = fifoWrStrb[i] ? fifoWrData[((i+1)*8) -1:(i*8)] : fifoRdModWrData[((i+1)*8) -1:(i*8)];
			end								
	endgenerate
	

//====================================================================================
// Infer dual port ram - one sync write port - once async read port
//==================================================================================

	assign fifoRdAddr_nc = fifoRdAddr[ADDR_NC_BITS+: FIFO_AWIDTH];	// Address Bus Connection
	assign fifoWrAddr_nc = fifoWrAddr[ADDR_NC_BITS+: FIFO_AWIDTH];	// Based on Data Bus Width	- drop bits for bytes stored in each RAM location

	assign fifoRdData = mem[fifoRdAddr_nc];	

//====================================================================================
// Infer RAM - Read Data Before Writing - Read Modify Write
//====================================================================================
	
	always@ ( posedge HCLK )
	begin

		if (fifoWrite)
			mem[fifoWrAddr_nc] <= fifoWrDataIn;

	end

	
`ifdef VERBOSE
	//=============================================================================================
	// Display data begin written into RAM
	//=============================================================================================
	always @( negedge HCLK )
		begin	
			if ( fifoWrite )		
				begin
					$display( "%t, %m, fifoWrAddr=%h (%d), fifoWrAddr_nc=%h (%d) , fifoWrDataIn= %d (%h), fifoRdMOrgData = %d (%h), fifoWrStrb= %h", 
									$time, fifoWrAddr, fifoWrAddr, fifoWrAddr_nc, fifoWrAddr_nc, fifoWrDataIn, fifoWrDataIn, fifoRdModWrData, fifoRdModWrData, fifoWrStrb );
				end
		end

	reg [FIFO_AWIDTH -1 :0]	fifoRdAddr_ncQ1; 
	
	//=============================================================================================
	// Display data read from RAM
	//=============================================================================================
	always @( negedge HCLK )
		begin	
			
			if ( fifoRdAddr_ncQ1 !== fifoRdAddr_nc )		// if address changed		
				begin
					$display( "%t, %m, memRdAddr=%h (%d), fifoRdAddr_nc=%h (%d), fifoRdData= %d (%h)", 
									$time, fifoRdAddr, fifoRdAddr, fifoRdAddr_nc, fifoRdAddr_nc, fifoRdData, fifoRdData );
				end

			fifoRdAddr_ncQ1 <= fifoRdAddr_nc;
			
		end				
`endif

	
endmodule // caxi4interconnect_DualPort_RAM_SyncWr_ASyncRd.v