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
module caxi4interconnect_RdFifoDualPort (
					// Bus global signals
					HCLK,
					fifo_areset,
					fifo_sreset,
					
					// Write Port
					fifoWrite,
					fifoWrData,

					// Read Port
					fifoRead,
					fifoRdData,
					targetValidQual,
					
					// Status bits
					fifoEmpty,
					fifoOneAvail,
					fifoRdValid,
					requestorSelValid,
					fifoFull,
					fifoNearFull,
					fifoOverRunErr,
					fifoUnderRunErr
				   
				);

   

//============================================
// Parameter Declarations
//============================================

	parameter HI_FREQ	= 1;			// used to add registers to allow a higher freq of operation at cost of latency
	parameter NEAR_FULL	= 2;			// used to define how close to full full the nearFull signal is asserted.

	parameter FIFO_AWIDTH = 1;			// Defines depth of caxi4interconnect_FIFO creates - 2^FIFO_AWIDTH of depth.
	
	parameter FIFO_WIDTH  = 3;
	parameter NUM_TARGETS = 8;
    parameter PIPE        = 0;
    parameter CROSSBAR_RAM_TYPE = 3;
    parameter SYNC_RESET  = 0;


//============================================================================
// I/O Declarations
//============================================================================

// Inputs - AHB
	input HCLK;								// ahb system clock
	input fifo_areset;						// reset - active high
	input fifo_sreset;						// reset - active high

	
// Write Port signals
	input [FIFO_WIDTH-1:0]	fifoWrData;		// Data to be written to ram
	input fifoWrite;						// Push data into caxi4interconnect_FIFO (ie write)

 // Read Port signals
	input  fifoRead;							// Pop (ie read) caxi4interconnect_FIFO
	output [FIFO_WIDTH-1:0]	 fifoRdData;		// Data to be read from ram
	input  [NUM_TARGETS-1:0]  targetValidQual;	
	
	output					 requestorSelValid;

 // Status bits
 	output fifoEmpty;
	output fifoOneAvail;					// indicates one entry in caxi4interconnect_FIFO
	output fifoRdValid;						// indicates data on fifRdData is valid - used to validate data in cases when pipeline
											// stages added to fifoRdData path.
	output fifoFull;		
	output fifoNearFull;					// indicates reached NEAR_FULL level from full and held asserted until caxi4interconnect_FIFO falls below thresholld 
											// ie held asserted when above level.
	output fifoOverRunErr;
	output fifoUnderRunErr;			
   

//============================================
// I/O Declarations
//============================================

	reg	fifoOverRunErr, fifoUnderRunErr;								// Error status bits
	reg fifoEmpty, fifoOneAvail, fifoRdValid, fifoFull, fifoNearFull;	// Empty and Full status bits

	wire  [NUM_TARGETS-1:0]	targetValidQual;	
	reg						requestorSelValid;
	
//============================================
// Local Declarations
//============================================

	reg [FIFO_AWIDTH-1:0] fifoWrAddr;			// Addr to be written to in RAM
	reg [FIFO_AWIDTH-1:0] fifoRdAddr;			// Addr to be read from RAM

	reg [FIFO_AWIDTH:0] fifoSpace;				// Amount of space left in caxi4interconnect_FIFO

	reg					fifoReadQ1;
	
	wire                fwft_fifo_rst = (SYNC_RESET) ? fifo_sreset : fifo_areset;
	
localparam	nearFullSpace = HI_FREQ ? NEAR_FULL : 'd1;		// handle pipelining cases

//====================================================================================
// Create read and write pointers (ie addresses for RAM) and space counter for caxi4interconnect_FIFO.
//====================================================================================


	
//==================================================================
// Declare Dual port RAM - generate from FFs if less than 64 memory
// elements.
//==================================================================
generate
  if(PIPE > 0) begin : mem_nonpipe_pipe

   always@(*)
     requestorSelValid = fifoRdValid & targetValidQual[fifoRdData];

	if (  (( 1<< FIFO_AWIDTH ) * FIFO_WIDTH ) <= 'd64 )	begin 
  
    wire         fifofull_fwft;
    wire         fifoempty_fwft;
    wire         fifonearfull_fwft;
    wire         fifooverrunerr_fwft;
    wire         fifounderrunerr_fwft;
	
    always@(*) begin 
	  fifoFull        = fifofull_fwft;
	  fifoEmpty       = fifoempty_fwft;
	  fifoNearFull    = fifonearfull_fwft;
	  fifoOverRunErr  = fifooverrunerr_fwft;
	  fifoUnderRunErr = fifounderrunerr_fwft;
	end 

    caxi4c_corefifo # 
	(
	 .FAMILY        (28),
	 .SYNC          (1), 
	 .RE_POLARITY   (0), 
	 .WE_POLARITY   (0), 
	 .RWIDTH        (FIFO_WIDTH), 
	 .WWIDTH        (FIFO_WIDTH), 
	 .RDEPTH        (2**FIFO_AWIDTH), 
	 .WDEPTH        (2**FIFO_AWIDTH), 
	 .READ_DVALID   (1), 
	 .WRITE_ACK     (0), 
	 .CTRL_TYPE     (CROSSBAR_RAM_TYPE), 
	 .ESTOP         (1), 
	 .FSTOP         (1), 
	 .AE_STATIC_EN  (0), 
	 .AF_STATIC_EN  (1), 
	 .AF_DYN_EN     (0), 
	 .AEVAL         (0), 
	 .AFVAL         ((2**FIFO_AWIDTH)-NEAR_FULL), 
	 .PIPE          (PIPE), 
	 .PREFETCH      (0), 
	 .FWFT          (1), 
	 .ECC           (0), 
	 .OVERFLOW_EN   (1), 
	 .UNDERFLOW_EN  (1), 
	 .WRCNT_EN      (0), 
	 .RDCNT_EN      (0), 
	 .NUM_STAGES    (0),
     .SYNC_RESET	(SYNC_RESET),
     .RAM_OPT		(0),
     .DIE_SIZE		(30)  
	) dpff_fwft
	(
                   // Clocks and Reset
     .CLK                 (HCLK),          // Single Clock for synchronous operation
     .WCLOCK              (HCLK),       // write Clock
     .RCLOCK              (HCLK),       // Read Clock
     .RESET_N             (fwft_fifo_rst),        // Reset active low
     .WRESET_N            (fwft_fifo_rst),
     .RRESET_N            (fwft_fifo_rst),
     .DATA                (fifoWrData),         // Input Write data
     .WE                  (fifoWrite),           // Write Enable
     .RE                  (fifoRead),           // Read Enable
     .Q                   (fifoRdData),            // Output Read data
     .FULL                (fifofull_fwft),         // Full flag
     .EMPTY               (fifoempty_fwft),        // Empty flag
     .AFULL               (fifonearfull_fwft),        // Almost Full flag
     .AF_THRSHLD          (),
     .AEMPTY              (),       // Almost Empty flag
     .OVERFLOW            (fifooverrunerr_fwft),     // Overflow indicates write failure
     .UNDERFLOW           (fifounderrunerr_fwft),    // Underflow indicates read failure
     .WACK                (),         // Write Acknowledge
     .DVLD                (fifoRdValid),         // Read Data valid
     .WRCNT               (),        // No.of remaining elements in write domain
     .RDCNT               (),        // No.of remaining elements in read domain
     .MEMWE               (),        // Memory Write enable
     .MEMRE               (),        // Memory Read enable
     .MEMWADDR            (),     // Memory Write Address
     .MEMRADDR            (),     // Memory Read Address
     .MEMWD               (),        // Memory Write Data
     .MEMRD               ({FIFO_WIDTH{1'b0}}),        // Memory Read Data
     .SB_CORRECT          (),   // One-bit correct flag
     .DB_DETECT           ()// Detect flag
    );  	
    end else begin 
    wire         fifofull_fwft;
    wire         fifoempty_fwft;
    wire         fifonearfull_fwft;
    wire         fifooverrunerr_fwft;
    wire         fifounderrunerr_fwft;
	
    always@(*) begin 
	  fifoFull     = fifofull_fwft;
	  fifoEmpty    = fifoempty_fwft;
	  fifoNearFull = fifonearfull_fwft;
	  fifoOverRunErr = fifooverrunerr_fwft;
	  fifoUnderRunErr = fifounderrunerr_fwft;
	end 
	  
    caxi4c_corefifo # 
	(
	 .FAMILY        (26),
	 .SYNC          (1), 
	 .RE_POLARITY   (0), 
	 .WE_POLARITY   (0), 
	 .RWIDTH        (FIFO_WIDTH), 
	 .WWIDTH        (FIFO_WIDTH), 
	 .RDEPTH        (2**FIFO_AWIDTH), 
	 .WDEPTH        (2**FIFO_AWIDTH), 
	 .READ_DVALID   (1), 
	 .WRITE_ACK     (0), 
	 .CTRL_TYPE     (CROSSBAR_RAM_TYPE), 
	 .ESTOP         (1), 
	 .FSTOP         (1), 
	 .AE_STATIC_EN  (0), 
	 .AF_STATIC_EN  (1), 
	 .AF_DYN_EN     (0), 
	 .AEVAL         (0), 
	 .AFVAL         ((2**FIFO_AWIDTH)-NEAR_FULL), 
	 .PIPE          (PIPE), 
	 .PREFETCH      (0), 
	 .FWFT          (1), 
	 .ECC           (0), 
	 .OVERFLOW_EN   (1), 
	 .UNDERFLOW_EN  (1), 
	 .WRCNT_EN      (0), 
	 .RDCNT_EN      (0), 
	 .NUM_STAGES    (0),
     .SYNC_RESET	(SYNC_RESET),
     .RAM_OPT		(0),
     .DIE_SIZE		(30)  
	) dpram_fwft
	(
                   // Clocks and Reset
     .CLK                 (HCLK),          // Single Clock for synchronous operation
     .WCLOCK              (HCLK),       // write Clock
     .RCLOCK              (HCLK),       // Read Clock
     .RESET_N             (fwft_fifo_rst),        // Reset active low
     .WRESET_N            (fwft_fifo_rst),
     .RRESET_N            (fwft_fifo_rst),
     .DATA                (fifoWrData),         // Input Write data
     .WE                  (fifoWrite),           // Write Enable
     .RE                  (fifoRead),           // Read Enable
     .Q                   (fifoRdData),            // Output Read data
     .FULL                (fifofull_fwft),         // Full flag
     .EMPTY               (fifoempty_fwft),        // Empty flag
     .AFULL               (fifonearfull_fwft),        // Almost Full flag
     .AF_THRSHLD          (0),
     .AEMPTY              (),       // Almost Empty flag
     .OVERFLOW            (fifooverrunerr_fwft),     // Overflow indicates write failure
     .UNDERFLOW           (fifounderrunerr_fwft),    // Underflow indicates read failure
     .WACK                (),         // Write Acknowledge
     .DVLD                (fifoRdValid),         // Read Data valid
     .WRCNT               (),        // No.of remaining elements in write domain
     .RDCNT               (),        // No.of remaining elements in read domain
     .MEMWE               (),        // Memory Write enable
     .MEMRE               (),        // Memory Read enable
     .MEMWADDR            (),     // Memory Write Address
     .MEMRADDR            (),     // Memory Read Address
     .MEMWD               (),        // Memory Write Data
     .MEMRD               ({FIFO_WIDTH{1'b0}}),        // Memory Read Data
     .SB_CORRECT          (),   // One-bit correct flag
     .DB_DETECT           ()// Detect flag
    );  	
    end 
  end else begin : mem_async_rd 	
  `ifdef VERBOSE
  initial
  begin
  		if (HI_FREQ)
  			begin
  				$display( "Module has HI_FREQ assert: %m ");
  			end
  end
  `endif 
  	
  	
  always @( posedge HCLK or negedge fifo_areset )
  begin
  	if (~fifo_areset | ~fifo_sreset)
  		begin
  		
  			fifoWrAddr <= 0;					// Addr to be written to in RAM
  			fifoRdAddr <= 0;					// Addr to be read from RAM
  
  			fifoSpace 		<= { 1'b1, { FIFO_AWIDTH{1'b0} } };	// Initialise space "empty"
  			fifoEmpty 		<= 1;
  			
  			fifoFull  		<= 0;
  			fifoNearFull 	<= 1'b0;			// One from full
  		
  			fifoOverRunErr  <= 0;
  			fifoUnderRunErr <= 0;
  			
  		end
  	else
  		begin
  		
  			fifoOverRunErr  <= 0;			// errors bit only asserted for 1 clock tick
  			fifoUnderRunErr <= 0;
  		
  			case( { fifoRead, fifoWrite }  )			// handle writing/reading combinations
  			2'b00:  
  					begin				// do nothing if no
  					end					// read or write
  			2'b01:		// write only on caxi4interconnect_FIFO
  					begin
  					
  						fifoEmpty  <= 1'b0;								// doing write so will not be empty 
  						
  						if ( fifoSpace == (nearFullSpace + 1) )			// reaching NEAR_FULL level
  							begin
  								fifoWrAddr 	 <= fifoWrAddr + 1'b1;
  								fifoSpace  	 <= fifoSpace - 1'b1;	
  								fifoNearFull <= 1'b1;				// Reached NEAR_FULL level
  							end
  						else if ( fifoSpace == 1 )						// one last entry can be written
  							begin
  								fifoWrAddr 	<= fifoWrAddr + 1'b1;
  								fifoSpace  	<= fifoSpace - 1'b1;	
  								fifoFull 	<= 1'b1;					// set full
  							end
  						else if ( fifoSpace != 0 )						// space for entry
  							begin
  								fifoWrAddr <= fifoWrAddr + 1'b1;	
  								fifoSpace  <= fifoSpace - 1'b1;	
  							end
  						else
  							begin
  								fifoOverRunErr <= 1'b1;					// trying to write a full caxi4interconnect_FIFO
  								// synthesis translate_off
  								$display( "%t Module has fifoOverRunErr assert: %m ", $time );
  								$stop;
  								// synthesis translate_on
  							end
  					end
  								
  			2'b10:		// read only on caxi4interconnect_FIFO
  					begin
  					
  						fifoFull  <= 1'b0;								// doing read so will not be full 
  
  						if ( fifoSpace == nearFullSpace )				// doing read at NEAR_FULL level of space
  							begin
  								fifoNearFull <= 1'b0;				
  								fifoRdAddr <= fifoRdAddr + 1'b1;
  								fifoSpace  <= fifoSpace + 1'b1;	
  								
  								if ( fifoSpace == { 1'b0, { FIFO_AWIDTH{1'b1} } }  )	// if only of depth of 2 for caxi4interconnect_FIFO
  									begin
  										fifoEmpty  <= 1'b1;								// set empty 
  									end
  							end
  						else if ( fifoSpace == { 1'b0, { FIFO_AWIDTH{1'b1} } }  )		// one last entry can be read
  							begin
  								fifoRdAddr <= fifoRdAddr + 1'b1;
  								fifoSpace  <= fifoSpace + 1'b1;	
  								fifoEmpty  <= 1'b1;										// set empty 
  							end
  						else if ( fifoSpace != {1'b1, { FIFO_AWIDTH{1'b0} } }  )		// entry to be read
  							begin
  								fifoRdAddr <= fifoRdAddr + 1'b1;	
  								fifoSpace  <= fifoSpace + 1'b1;	
  							end
  						else
  							begin
  								fifoUnderRunErr <= 1'b1;					// trying to read from an empty caxi4interconnect_FIFO
  								// synthesis translate_off
  								$display( "%t Module has fifoUnderRunErr assert: %m ", $time );
  								$stop;
  								// synthesis translate_on
  							end
  					end					
  			2'b11:		// simultaneous read and write 
  					begin
  
  						fifoRdAddr <= fifoRdAddr + 1'b1;					// only need to incremenet rd/write addresses
  						fifoWrAddr <= fifoWrAddr + 1'b1;					// space does not change nor do caxi4interconnect_FIFO status bits.
  
  					end								
  			endcase
  		end
  		
  
  end
  
  always @( posedge HCLK or negedge fifo_areset )
  begin
  	if (~fifo_areset | ~fifo_sreset)
  		begin
  			fifoRdValid		<= 0;
  			fifoReadQ1		<= 0;
  			requestorSelValid <= 0;
  		end
  	else
  		begin
  			fifoReadQ1	<= fifoRead;				
  			
  			case( { fifoRead, fifoWrite }  )			// handle writing/reading combinations
  				2'b00:  
  						begin				// do nothing if no
  							fifoRdValid 	  <= !fifoEmpty;		// set if data already in firo
  							requestorSelValid <= !fifoEmpty & targetValidQual[fifoRdData];
  						end					// read or write
  				2'b01:		// write only on caxi4interconnect_FIFO
  						begin
  							if ( HI_FREQ )
  								begin
  									fifoRdValid <= !fifoEmpty;		// set if data alread in firo
  									requestorSelValid <= !fifoEmpty & targetValidQual[fifoRdData];
  								end
  							else
  								begin
  									fifoRdValid <= 1;
  									requestorSelValid <= targetValidQual[fifoRdData];
  								end
  						end
  				2'b10:		// read only on caxi4interconnect_FIFO
  						begin
  							if ( HI_FREQ )
  								begin
  									fifoRdValid <= fifoReadQ1 & !fifoEmpty;			// bubble on a read - but only on first read and data in caxi4interconnect_FIFO
  									requestorSelValid <= fifoReadQ1 & !fifoEmpty & targetValidQual[fifoRdData];								
  								end
  							else
  								begin
  									if ( fifoSpace == { 1'b0, { FIFO_AWIDTH{1'b1} } }  )	// only 1 entry and reading
  										begin
  											fifoRdValid 		<= 0;
  											requestorSelValid 	<= 0;								
  										end
  								end
  						end					
  				2'b11:		// simultaneous read and write 
  						begin
  							if ( HI_FREQ )
  								begin
  									fifoRdValid <= fifoReadQ1 & !fifoEmpty;			// bubble on a read - but only on first read
  									requestorSelValid <= fifoReadQ1 & !fifoEmpty & targetValidQual[fifoRdData];								
  								end
  							else
  								begin
  									fifoRdValid <= 1;
  									requestorSelValid <= targetValidQual[fifoRdData];
  								end
  
  						end								
  				endcase
  		end
  end
  
  
  
  //=====================================================================
  // Decode when only one entry in caxi4interconnect_FIFO
  //=====================================================================
  always @( posedge HCLK or negedge fifo_areset  )
  	begin
  		if (~fifo_areset | ~fifo_sreset)
  			begin
  				fifoOneAvail	<= 0;
  			end
  		else
  			begin
  				if ( ( fifoSpace == {1'b1, { FIFO_AWIDTH{1'b0} } }  ) & fifoWrite & !fifoRead )			// caxi4interconnect_FIFO empty and writing one in
  					begin
  						fifoOneAvail <= 1'b1;
  					end
  				else if ( ( fifoSpace == {1'b0, { FIFO_AWIDTH{1'b1} } }  ) & fifoWrite & !fifoRead )	// caxi4interconnect_FIFO 1-entry and writing one in
  					begin
  						fifoOneAvail <= 1'b0;
  					end				
  				else if ( ( fifoSpace == ( {1'b0, { FIFO_AWIDTH{1'b1} } } -1'b1) ) & !fifoWrite & fifoRead )	// two entries in caxi4interconnect_FIFO
  					begin
  						fifoOneAvail <= 1'b0;
  					end					
  				else if ( ( fifoSpace == {1'b0, { FIFO_AWIDTH{1'b1} } }  ) & !fifoWrite & fifoRead )	// moving to empty
  					begin
  						fifoOneAvail <= 1'b0;
  					end
  			end
  	end
    
    if (  (( 1<< FIFO_AWIDTH ) * FIFO_WIDTH ) <= 'd64 )	begin 
		caxi4interconnect_DualPort_FF_SyncWr_SyncRd #( 	.HI_FREQ(  HI_FREQ ),
										.FIFO_AWIDTH( FIFO_AWIDTH ),
										.FIFO_WIDTH ( FIFO_WIDTH )
									)
				DPFF(
										// AHB global signals
										.HCLK( HCLK ),

										// Write Port
										.fifoWrAddr( fifoWrAddr ),	
										.fifoWrite ( fifoWrite  ),
										.fifoWrData( fifoWrData ),

										// Read Port
										.fifoRdAddr( fifoRdAddr ),
										.fifoRdData( fifoRdData )
				   
									) ;

	end else begin
	
			reg [FIFO_AWIDTH-1:0] d_fifoRdAddr;			// Addr to be read from RAM

			//=======================================================================
			// Create "pipeline" address for Block RAM to allow dual-port
			// sync read and sync write to be inferred.
			//=======================================================================
			always @(*)
				begin

					d_fifoRdAddr = fifoRdAddr;
	
					if ( fifoRead )
						begin
							if ( fifoWrite )									// can always increment as writing and reading 
								d_fifoRdAddr = fifoRdAddr + 1'b1;							
							else if ( fifoSpace != {1'b1, { FIFO_AWIDTH{1'b0} } }  )		// as long as entry to be read
								d_fifoRdAddr = fifoRdAddr + 1'b1;	
						end

				end
			
			caxi4interconnect_DualPort_RAM_SyncWr_SyncRd #( 	.FIFO_AWIDTH( FIFO_AWIDTH ),
											.FIFO_WIDTH ( FIFO_WIDTH )
										)
						DPRam(
											// AHB global signals
											.HCLK( HCLK ),

											// Write Port
											.fifoWrAddr( fifoWrAddr ),	
											.fifoWrite ( fifoWrite  ),
											.fifoWrData( fifoWrData ),

											// Read Port
											.fifoRdAddr( d_fifoRdAddr ),
											.fifoRdData( fifoRdData )
				   
										);

		end
	end 
endgenerate


endmodule // caxi4interconnect_RdFifoDualPort.v
