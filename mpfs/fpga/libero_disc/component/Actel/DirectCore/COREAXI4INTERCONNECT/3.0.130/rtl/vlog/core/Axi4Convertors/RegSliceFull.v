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
// SVN $Revision: 49731 $
// SVN $Date: 2025-09-13 17:26:32 +0530 (Sat, 13 Sep 2025) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_RegSliceFull #

	(
  		parameter integer 	CHAN_WIDTH 			= 5,			//  the number of channel signals to register (outside of Valid & Ready) 
		parameter integer   READY_REG           = 0
	)	
	(

		input  wire			sysClk,
		input  wire         arst_sync,						// active high reset - async assert and sync to sysClk deassert
		input  wire         srst_sync,						// active high reset - async assert and sync to sysClk deassert
  
		//========================= to/from Initiator and Target Ports ================================================//
   
		input wire [CHAN_WIDTH-1:0]		mDat,				// channel data signals to register from "initiator" or "source"
		input wire        				mValid,				// indicates when mDat is valid
		output reg						mReady,				// indicates when taking data from "initiator" or "source"
		
		output reg [CHAN_WIDTH-1:0]		sDat,				// channel data signals registered to "target" or "sink"
		output reg						sValid,				// indicates when sDat is valid
		input wire						sReady				// indicates when target/sink taking sDat
    
	);
	
	//===============================================================================================================
	// Local Declarations
	//===============================================================================================================
	
	reg [CHAN_WIDTH-1:0]	holdDat;						// holding register for mDat - for when target/sink not ready
	reg						sDatEn;							// latch next data into sDat
	reg						holdDatSel;
	
	
	//============================================================================================
	// Declare state machine variables
	//============================================================================================
	localparam [1:0]	IDLE = 2'b00, NO_DAT = 2'b01,	ONE_DAT = 2'b11, 	TWO_DAT = 2'b10;
	
	reg [1:0]	currState, nextState;
	reg			d_mReady, d_sValid;
	
generate
  if(READY_REG) begin : gen_ready_reg_en	
	//============================================================================================
	// holdDat holds mDat when sink is not ready to take sDat - allows initiator/source to move on
	// while not losing data.
	//============================================================================================
	always @(posedge sysClk or negedge arst_sync )
		begin
			if (~arst_sync | ~srst_sync)
				holdDat <= 0;
			else if ( mValid & mReady )
				holdDat <= mDat;
		end

	
	//=============================================================================================
	// sDat has mDat clocked in or holdDat if target/sink was not ready.
	//=============================================================================================
	always @(posedge sysClk or negedge arst_sync )
		begin
			if (~arst_sync | ~srst_sync)
				sDat <= 0;
			else if ( sDatEn )			// if s/m says load next data
				begin
					sDat <= holdDatSel 	? holdDat : mDat;		// normally clock in mDat but if had been held off due to target 
																// not ready, take from holding register
				end
		end
		
		
	//===============================================================================================
	// Control State machine
	//===============================================================================================
	always @( * )
		begin
		
			d_mReady = 1;
			d_sValid = 0;
			
			holdDatSel	= 0;
			sDatEn		= 0;
			
			nextState = currState;
		
			case ( currState )
				IDLE:	
						begin					// this state ensures that we mReady is always desserted as we exit reset
							nextState = NO_DAT;
						end
				NO_DAT:
						begin
							
							if ( mValid )			// if initiator/source has data for us
								begin
									sDatEn		= 1'b1;	// latch for target/sink
									d_sValid 	= 1'b1;	// indicate to target that data available
									
									nextState 	= ONE_DAT;
								end
						end
				ONE_DAT:
						begin
						
							if ( sReady )			// if target/sink is taking available data
								begin
								
									if ( mValid )	// if source has another data available
										begin
											sDatEn 		= 1'b1;
											d_sValid 	= 1'b1;
										end
									else
										begin
											nextState	= NO_DAT;
										end
								end
							else
								begin
									d_sValid	= 1'b1;
									
									if ( mValid )
										begin
											d_mReady	= 1'b0;		// stop mReady as pipe full
											nextState	= TWO_DAT;
										end
									else
										begin
											d_mReady	= 1'b1;
										end

								end
						end
				TWO_DAT:
						begin
							holdDatSel 	= 1;
							d_sValid	= 1'b1;
							d_mReady	= 1'b0;
							
							if ( sReady )
								begin
									sDatEn 		= 1'b1;
									d_mReady	= 1'b1;
									
									nextState	= ONE_DAT;
								end
						end
				default:
					begin
			            d_mReady = 1;
			            d_sValid = 0;
			            
			            holdDatSel	= 0;
			            sDatEn		= 0;
			            
			            nextState = currState;						
					end
			endcase
	
		end
							
	//===================================================================================================
	// Sequential part of s/m
	//===================================================================================================
	always @(posedge sysClk or negedge arst_sync )
		begin
			if (~arst_sync | ~srst_sync)
				begin
					currState	<= IDLE;
				
					mReady	<= 1'b0;
					sValid	<= 1'b0;
				end
			else
				begin
					currState	<= nextState;
				
					mReady	<= d_mReady;
					sValid	<= d_sValid;
				end
				
		end
					
  end else begin : gen_ready_reg_dis			
    always @(*)
      mReady = (~sValid) | sReady;

    always @(posedge sysClk or negedge arst_sync) begin
      if (~arst_sync | ~srst_sync) begin
        sDat     <= {CHAN_WIDTH{1'b0}};
        sValid   <= 1'b0;
      end else begin
        if (mReady) begin
          sDat   <= mDat;
          sValid <= mValid;
        end
      end
    end
  end
endgenerate		
endmodule		// caxi4interconnect_RegSliceFull.v
