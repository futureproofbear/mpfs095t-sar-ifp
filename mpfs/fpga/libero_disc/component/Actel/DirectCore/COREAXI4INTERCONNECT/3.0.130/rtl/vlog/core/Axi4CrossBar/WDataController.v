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
// SVN $Revision: 51465 $
// SVN $Date: 2026-05-07 06:31:35 -0400 (Thu, 07 May 2026) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_WDataController # 
	(
		parameter integer NUM_INITIATORS			                                    = 2, 				// defines number of initiators
		parameter integer NUM_INITIATORS_WIDTH		                                    = 1, 				// defines number of bits to encode initiator number
		
		parameter integer NUM_TARGETS     		                                        = 2, 				// defines number of targets
		parameter integer NUM_TARGETS_WIDTH 		                                    = 1,				// defines number of bits to encoode target number

		parameter integer ID_WIDTH   			                                        = 1, 
		parameter integer DATA_WIDTH 			                                        = 32,
												    
		parameter OPEN_WRTRANS_MAX				                                        = 3,				// 
		
		parameter [(16*32)-1:0] NUM_THREADS  	                                        = {16{32'h1}},	// number of independent threads per initiator supported
		parameter [(16*32)-1:0] OPEN_TRANS_MAX	                                        = {16{32'h2}},	// max number of outstanding transactions per thread
												    
		parameter integer SUPPORT_USER_SIGNALS 	                                        = 0,
		parameter integer USER_WIDTH 			                                        = 1,
												    
		parameter integer CROSSBAR_MODE			                                        = 1,				// defines whether non-blocking (ie set 1) or shared access data path

		parameter [NUM_TARGETS*NUM_INITIATORS-1:0] INITIATOR_WRITE_CONNECTIVITY 		= {NUM_TARGETS*NUM_INITIATORS{1'b1}},
		
		parameter	HI_FREQ						                                        = 1,					// increases freq of operation at cost of added latency
												    
	    parameter   PIPE                                                                = 1,
	    parameter   CROSSBAR_RAM_TYPE                                                   = 3,
        parameter   SYNC_RESET                                                          = 0
   
	)
	(
		// Global Signals
		input  wire                                                    	sysClk,
		input  wire                                                    	arst_sync,			// active low reset synchronoise to RE AClk - asserted async.
		input  wire                                                    	srst_sync,			// active low reset synchronoise to RE AClk - asserted async.
   
		//====================== target Data Ports  ================================================//
		output  reg [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]   TARGET_WID,
		output  reg [NUM_TARGETS*DATA_WIDTH-1:0]    					TARGET_WDATA,
		output  reg [NUM_TARGETS*(DATA_WIDTH/8)-1:0]                 	TARGET_WSTRB,
		output  reg [NUM_TARGETS-1:0]                           		TARGET_WLAST,
		output  reg [NUM_TARGETS*USER_WIDTH-1:0]         				TARGET_WUSER,
		output  reg [NUM_TARGETS-1:0]                           		TARGET_WVALID,
		
		input wire [NUM_TARGETS-1:0]                           			TARGET_WREADY,
		
		//====================== Initiator Data  Ports  ================================================//
		input wire [NUM_INITIATORS * ID_WIDTH-1:0]            			INITIATOR_WID,
		input wire [NUM_INITIATORS*DATA_WIDTH-1:0]     					INITIATOR_WDATA,
		input wire [NUM_INITIATORS*(DATA_WIDTH/8)-1:0]     				INITIATOR_WSTRB,
		input wire [NUM_INITIATORS-1:0]                            		INITIATOR_WLAST,
		input wire [NUM_INITIATORS*USER_WIDTH-1:0]          			INITIATOR_WUSER,
		input wire [NUM_INITIATORS-1:0]                            		INITIATOR_WVALID,

		output wire [NUM_INITIATORS-1:0]                              	INITIATOR_WREADY,
   
		//======================= Write Address Controller Port======================================//
		input wire														dataFifoWr,
		input wire	[(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 				srcPort,
		input wire	[NUM_TARGETS_WIDTH-1:0]								destPort
		
	);
   						 
						 
//================================================================================================
// Local Parameters and declarations
//================================================================================================

	localparam INITIATORID_WIDTH	= ( NUM_INITIATORS_WIDTH + ID_WIDTH );			// defines width initiatorID - includes infrastructure ID plus ID
	localparam THREAD_VEC_WIDTH		= ( INITIATORID_WIDTH + NUM_TARGETS_WIDTH );	// defines width of per thread vector elements width

	localparam STRB_WIDTH			= (DATA_WIDTH/8);							    // defines width of write strobes 
	
	// - CROSSBAR_MODE=1: Per-initiator FIFO needs depth based on OPEN_WRTRANS_MAX
	// - CROSSBAR_MODE=0: Shared mode now enforces single outstanding transaction via
	//                    AddressController's shared_mode_busy signal, so minimal depth is sufficient.
	// For shared mode, depth=4 provides safety margin.
	// For crossbar mode, calculate based on OPEN_WRTRANS_MAX with minimum depth=8.
	localparam OPEN_WRTRANS_MAX_FIFO_DEPTH = (CROSSBAR_MODE == 0) ? 4 :   // Shared mode: minimal depth (single outstanding)
	                                         (OPEN_WRTRANS_MAX < 5 ) ? 8 :
	                                         (OPEN_WRTRANS_MAX < 9 ) ? 16 : 
	                                         (OPEN_WRTRANS_MAX < 17) ? 32 : 
											 64;
	



	wire [(NUM_INITIATORS-1)*CROSSBAR_MODE:0]	wrFifoEmpty, wrFifoRdValid;
	wire [(NUM_INITIATORS-1)*CROSSBAR_MODE:0]	wrfifo_itvld;
	
    wire         cfifo_rst;

    assign       cfifo_rst = (SYNC_RESET == 0) ? arst_sync : srst_sync; 	
	
	//=======================================================================================================================
	// Store write address transactions - per initiator in crossbar mode or shared in shared-access mode. 
	//=======================================================================================================================     
 	integer trgt_mux;
	genvar i;
	generate
	if (CROSSBAR_MODE == 1)			// implement full non-blocking data path for read data
		begin	:	iWrConXB

			// Local declarations for crossbar mode
			wire [NUM_INITIATORS-1:0]	  wrAddrInitiatorWr;
			reg  [NUM_INITIATORS-1:0]	  dataFifoRd;
			

			wire [NUM_INITIATORS_WIDTH+NUM_TARGETS_WIDTH-1:0] wrfifoRdData	[NUM_INITIATORS-1:0]; 
	
			wire [NUM_INITIATORS-1:0]		fifoOverRunErr;
			wire [NUM_INITIATORS-1:0]		fifoUnderRunErr;
			
			reg  [NUM_TARGETS_WIDTH:0]	    dsttarg [NUM_INITIATORS-1:0];
			reg  [NUM_TARGETS_WIDTH:0]	    dsttarg_reg [NUM_INITIATORS-1:0];
			reg  [NUM_INITIATORS-1:0]       intr_wrdy;			
					
			//======================================================================================
			// In Crossbar mode data paths are non-blocking so need per target fifos as well
			//======================================================================================
			for (i=0; i < NUM_INITIATORS; i=i+1)
			  begin	: iWrConFif
				
					// Pick out Infrastructure component of srcPort and use to qualify write per initiator
				assign wrAddrInitiatorWr[i] = dataFifoWr & (srcPort[NUM_INITIATORS_WIDTH+ID_WIDTH-1:ID_WIDTH] == i[NUM_INITIATORS_WIDTH-1:0]);		
				
					
			    if(PIPE > 0) begin 
                    caxi4c_coreaxi4s_fifo #
                    (
                       .RESET_TYPE         (SYNC_RESET),//
                       .SYNC               (1),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
                       .PIPE               (PIPE),// 1: Address pipeline 2: address and data pipeline 
                       .ECC                (0),// 0: ECC disable , 1: ECC enable
                       .RAM_TYPE           (CROSSBAR_RAM_TYPE),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
                       .NUM_STAGES         (0),// To select number of synchronizer stages.
                       .READ_MODE          (0),// 0: flow through mode  1: wait for tlast
                       .WFIFO_DEPTH        (OPEN_WRTRANS_MAX_FIFO_DEPTH),
                       .RFIFO_DEPTH        (OPEN_WRTRANS_MAX_FIFO_DEPTH),
                       .AXIS_TTDATA_WIDTH  (NUM_INITIATORS_WIDTH+NUM_TARGETS_WIDTH), // Bytes
                       .AXIS_ITDATA_WIDTH  (NUM_INITIATORS_WIDTH+NUM_TARGETS_WIDTH),  // Bytes
                       .AXIS_TTID_WIDTH    (1), // Bits
                       .AXIS_ITID_WIDTH    (1), // Bits
                       .AXIS_TTDEST_WIDTH  (1), // Bits
                       .AXIS_ITDEST_WIDTH  (1), // Bits
                       .AXIS_TTUSER_WIDTH  (1), // Bits
                       .AXIS_ITUSER_WIDTH  (1), // Bits
                       .ENABLE_AFULL       (0),
                       .AFULL_THR          (OPEN_WRTRANS_MAX_FIFO_DEPTH-1),
                       .ENABLE_TSTRB       (0),
                       .ENABLE_TKEEP       (0),
                       .ENABLE_TLAST       (0),
                       .ENABLE_TUSER       (0),
                       .ENABLE_TDEST       (0),
                       .ENABLE_TID         (0),
                       .EOP_OFFSET         (0)
                    ) wr_fwftFif
                    (
                       .AXI4S_ACLK         (sysClk),
                       .AXI4S_IACLK        (sysClk),
                       .AXI4S_TACLK        (sysClk),
                       .AXI4S_ARESETN      (cfifo_rst),
                       .AXI4S_IARESETN     (cfifo_rst),
                       .AXI4S_TARESETN     (cfifo_rst),

                       .AXI4S_ITREADY      (dataFifoRd[i]),
                       .AXI4S_ITVALID      (wrfifo_itvld[i]),
                       .AXI4S_ITDATA       (wrfifoRdData[i]),
                       .AXI4S_TTVALID      (wrAddrInitiatorWr[i]),
                       .AXI4S_TTDATA       ({srcPort[INITIATORID_WIDTH-1:ID_WIDTH],destPort})

                    );
                    assign wrFifoEmpty[i]   = ~wrfifo_itvld[i];
					assign wrFifoRdValid[i] = wrfifo_itvld[i];
					
					//synthesis translate_off
					  wire [3:0] initiator_num = srcPort[INITIATORID_WIDTH-1:ID_WIDTH];
					  wire [NUM_TARGETS_WIDTH-1:0] trgt_num = destPort;
					  wire [4:0] id_num        = srcPort[ID_WIDTH-1:0];
					//synthesis translate_on

                    
                end else begin 				
					
					//====================================================================================================
					// caxi4interconnect_FIFO to hold open write transactions - pushed on Address write cycle and popped on write data
					// cycle.
					//=====================================================================================================
					caxi4interconnect_FifoDualPort #	(	.HI_FREQ( 1'b0 ),
										.NEAR_FULL ( 'd2 ),
										.FIFO_AWIDTH( $clog2(OPEN_WRTRANS_MAX_FIFO_DEPTH) ),
										//.FIFO_WIDTH( NUM_INITIATORS_WIDTH )
										.FIFO_WIDTH( NUM_INITIATORS_WIDTH+NUM_TARGETS_WIDTH)
									)
						wrFif	(
										.HCLK(	sysClk ),
										.fifo_areset( arst_sync ),
										.fifo_sreset( srst_sync ),
					
										// Write Port
										
										.fifoWrite( wrAddrInitiatorWr[i] ),
										.fifoWrData( {srcPort[INITIATORID_WIDTH-1 : ID_WIDTH ],destPort} ),	// pick out infrastructure ID

										// Read Port
										.fifoRead( dataFifoRd[i] ),
										.fifoRdData( wrfifoRdData[i] ),
					
										// Status bits
										.fifoEmpty ( wrFifoEmpty[i] ) ,
										.fifoOneAvail(  ),
										.fifoRdValid( wrFifoRdValid[i] ),		// indicates read data is valid - handles clocked rd data
										.fifoFull(  ),
										.fifoNearFull( 	 ),		// use nearly full to allow cover race between "full" and arb
										.fifoOverRunErr( fifoOverRunErr[i] ),
										.fifoUnderRunErr( fifoUnderRunErr[i] )				   
								);
 
                end 
	          end 	              				
		    
			always @(*) begin
              // Default assignments
              intr_wrdy               = {NUM_INITIATORS{1'b0}};
              dataFifoRd              = {NUM_INITIATORS{1'b0}};
              TARGET_WVALID           = {NUM_TARGETS{1'b0}};
              TARGET_WDATA            = {(NUM_TARGETS*DATA_WIDTH){1'b0}};
              TARGET_WSTRB            = {(NUM_TARGETS*(DATA_WIDTH/8)){1'b0}};
              TARGET_WLAST            = {NUM_TARGETS{1'b0}};
              TARGET_WUSER            = {(NUM_TARGETS*USER_WIDTH){1'b0}};			
              TARGET_WID              = {(NUM_TARGETS*INITIATORID_WIDTH){1'b0}};			
              for (trgt_mux = 0; trgt_mux < NUM_INITIATORS; trgt_mux = trgt_mux + 1) begin			  
                dsttarg[trgt_mux]     = 0;
			  end 		      
              // For each initiator, check if it has outstanding transaction and valid data
              for (trgt_mux = 0; trgt_mux < NUM_INITIATORS; trgt_mux = trgt_mux + 1) begin
                  if (!wrFifoEmpty[trgt_mux] && INITIATOR_WVALID[trgt_mux]) begin
                    // Route data to the selected target if target is ready
					  dsttarg[trgt_mux]     = {1'b0,wrfifoRdData[trgt_mux][NUM_TARGETS_WIDTH-1:0]};	
                      TARGET_WVALID[dsttarg[trgt_mux]]                                     = 1'b1;
                      TARGET_WDATA[dsttarg[trgt_mux]*DATA_WIDTH +: DATA_WIDTH]             = INITIATOR_WDATA[trgt_mux*DATA_WIDTH +: DATA_WIDTH];
                      TARGET_WSTRB[dsttarg[trgt_mux]*STRB_WIDTH +: STRB_WIDTH]             = INITIATOR_WSTRB[trgt_mux*STRB_WIDTH +: STRB_WIDTH];
                      TARGET_WLAST[dsttarg[trgt_mux]]                                      = INITIATOR_WLAST[trgt_mux];
                      TARGET_WUSER[dsttarg[trgt_mux]*USER_WIDTH +: USER_WIDTH]             = INITIATOR_WUSER[trgt_mux*USER_WIDTH +: USER_WIDTH];
                      // Explicit bit-select for trgt_mux (integer) to match NUM_INITIATORS_WIDTH
                      TARGET_WID[dsttarg[trgt_mux]*INITIATORID_WIDTH +: INITIATORID_WIDTH] = {trgt_mux[NUM_INITIATORS_WIDTH-1:0],
					                                                                         INITIATOR_WID[trgt_mux*ID_WIDTH +: ID_WIDTH]};
                      
                      intr_wrdy[trgt_mux] = TARGET_WREADY[dsttarg[trgt_mux]];										  
                      // If this is the last beat, pop the FIFO
                      if (INITIATOR_WLAST[trgt_mux] & intr_wrdy[trgt_mux])
                        dataFifoRd[trgt_mux] = 1'b1;     
                  end
              end
            end		
            assign INITIATOR_WREADY = intr_wrdy;

		end
	else
		begin	: iWrConSh		// implement shared write datapath - only one write mux path
	
			//==================================================================
			// Local declarations for shared-access mode
			//==================================================================
			wire 					       		                wrAddrInitiatorWr;
			wire 							                    dataFifoRd;
			
			wire [NUM_INITIATORS_WIDTH + NUM_TARGETS_WIDTH-1:0] wrfifoRdData;
	
			wire 							                    fifoOverRunErr;
			wire 							                    fifoUnderRunErr;
			wire 							                    wrInitiatorValid;		
	
			wire 					    	                    targetWVALID;
			wire [INITIATORID_WIDTH-1:0]                        targetWID;
			wire [DATA_WIDTH-1:0]			                    targetWDATA;
			wire [(DATA_WIDTH/8)-1:0] 		                    targetWSTRB;
			wire 					                            targetWLAST;
			wire [USER_WIDTH-1:0]			                    targetWUSER;
		
			wire [NUM_TARGETS_WIDTH-1:0]                    	desttarget;
			wire [NUM_INITIATORS_WIDTH*NUM_TARGETS-1:0]	        srcInitiator;		
			reg [NUM_TARGETS-1:0]			                    aTARGET_WVALID;
		
			//==================================================================
		
		
			// All write transactions go into same caxi4interconnect_FIFO in shared-access mode
			assign wrAddrInitiatorWr = dataFifoWr;	
	
	
			if(PIPE > 0) begin 
                caxi4c_coreaxi4s_fifo #
                (
                   .RESET_TYPE         (SYNC_RESET                              ),//
                   .SYNC               (1                                       ),// Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
                   .PIPE               (PIPE                                    ),// 1: Address pipeline 2: address and data pipeline 
                   .ECC                (0                                       ),// 0: ECC disable , 1: ECC enable
                   .RAM_TYPE           (0                                       ),// 0 - Fabric 3 - uSRAM 2 - LSRAM 4 - Inferred by the tool
                   .NUM_STAGES         (0                                       ),// To select number of synchronizer stages.
                   .READ_MODE          (0                                       ),// 0: flow through mode  1: wait for tlast
                   .WFIFO_DEPTH        (OPEN_WRTRANS_MAX_FIFO_DEPTH             ),
                   .RFIFO_DEPTH        (OPEN_WRTRANS_MAX_FIFO_DEPTH             ),
                   .AXIS_TTDATA_WIDTH  (NUM_INITIATORS_WIDTH + NUM_TARGETS_WIDTH), // Bytes
                   .AXIS_ITDATA_WIDTH  (NUM_INITIATORS_WIDTH + NUM_TARGETS_WIDTH),  // Bytes
                   .AXIS_TTID_WIDTH    (1                                       ), // Bits
                   .AXIS_ITID_WIDTH    (1                                       ), // Bits
                   .AXIS_TTDEST_WIDTH  (1                                       ), // Bits
                   .AXIS_ITDEST_WIDTH  (1                                       ), // Bits
                   .AXIS_TTUSER_WIDTH  (1                                       ), // Bits
                   .AXIS_ITUSER_WIDTH  (1                                       ), // Bits
                   .ENABLE_AFULL       (0                                       ),
                   .AFULL_THR          (OPEN_WRTRANS_MAX_FIFO_DEPTH-1           ),
                   .ENABLE_TSTRB       (0                                       ),
                   .ENABLE_TKEEP       (0                                       ),
                   .ENABLE_TLAST       (0                                       ),
                   .ENABLE_TUSER       (0                                       ),
                   .ENABLE_TDEST       (0                                       ),
                   .ENABLE_TID         (0                                       ),
                   .EOP_OFFSET         (0                                       )
                ) wr_fwftFif
                (
                   .AXI4S_ACLK         (sysClk                                                ),
                   .AXI4S_IACLK        (sysClk                                                ),
                   .AXI4S_TACLK        (sysClk                                                ),
                   .AXI4S_ARESETN      (cfifo_rst                                             ),
                   .AXI4S_IARESETN     (cfifo_rst                                             ),
                   .AXI4S_TARESETN     (cfifo_rst                                             ),
                   .AXI4S_ITREADY      (dataFifoRd                                            ),
                   .AXI4S_ITVALID      (wrfifo_itvld                                          ),
                   .AXI4S_ITDATA       (wrfifoRdData                                          ),
                   .AXI4S_TTVALID      (wrAddrInitiatorWr                                        ),
                   .AXI4S_TTDATA       ({ srcPort[INITIATORID_WIDTH-1 : ID_WIDTH ], destPort} )
                );
                assign wrFifoEmpty      = ~wrfifo_itvld;
		   	    assign wrFifoRdValid    = wrfifo_itvld;   
              end else begin 				
			    //====================================================================================================
			    // caxi4interconnect_FIFO to hold open write transactions - pushed on Address write cycle and popped on write data
			    // cycle.
			    //=====================================================================================================
			    caxi4interconnect_FifoDualPort #	
				            (	    
							        .HI_FREQ    ( 1'b0                                     ),		// no pipeline on data
			    					.FIFO_AWIDTH( (OPEN_WRTRANS_MAX_FIFO_DEPTH < 5) ? 4 : $clog2(OPEN_WRTRANS_MAX_FIFO_DEPTH)      ),
			    					.FIFO_WIDTH ( NUM_INITIATORS_WIDTH + NUM_TARGETS_WIDTH )
			    			)
			    	wrFif	(
			    					.HCLK           ( sysClk                                                  ),
			    					.fifo_areset    ( arst_sync                                               ),
			    					.fifo_sreset    ( srst_sync                                               ),
			    		
			    					// Write Port
			    					.fifoWrite      ( wrAddrInitiatorWr                                          ),
			    					.fifoWrData     ( { srcPort[INITIATORID_WIDTH-1 : ID_WIDTH ], destPort }  ),	// Pick out infrastructure ID and destPort
			    
			    					// Read Port
			    					.fifoRead       ( dataFifoRd                                              ),		// pop when any bit set
			    					.fifoRdData     ( wrfifoRdData                                            ),
			    		
			    					// Status bits
			    					.fifoEmpty      ( wrFifoEmpty                                             ) ,
			    					.fifoOneAvail   (                                                         ),
			    					.fifoRdValid    ( wrFifoRdValid                                           ),
			    					.fifoFull       (                                                         ),
			    					.fifoNearFull   (                                                         ),				// use 1 from full to allow cover race between "full" and arb
			    					.fifoOverRunErr ( fifoOverRunErr                                          ),
			    					.fifoUnderRunErr( fifoUnderRunErr                                         )
			    	   		);
              end 
	
			// Initiators have requests stopped when full - stop for any initiator as common data-path
	
	
			// Src Initiator has request when not empty and wrtite connective to target target
			assign wrInitiatorValid = !wrFifoEmpty & wrFifoRdValid;
			
			assign srcInitiator = wrfifoRdData[NUM_INITIATORS_WIDTH+NUM_TARGETS_WIDTH-1: NUM_TARGETS_WIDTH];
			assign desttarget = wrfifoRdData[NUM_TARGETS_WIDTH-1: 0];
			
		
			//===================================================================================================
			// caxi4interconnect_WriteDataMux muxes the selected requesting initiator to the target port
			//=================================================================================================== 
			caxi4interconnect_WriteDataMux # 
				(
					.NUM_INITIATORS				( NUM_INITIATORS       ),	
					.NUM_INITIATORS_WIDTH		( NUM_INITIATORS_WIDTH ),
					.NUM_TARGETS 				( NUM_TARGETS          ),
					.NUM_TARGETS_WIDTH 			( NUM_TARGETS_WIDTH    ),
					.ID_WIDTH  					( ID_WIDTH             ),
					.DATA_WIDTH					( DATA_WIDTH           ),
					.SUPPORT_USER_SIGNALS		( SUPPORT_USER_SIGNALS ),
					.USER_WIDTH 				( USER_WIDTH           ),
					.HI_FREQ					( HI_FREQ              )
				)
			wrDMux(
					// Global Signals
					.sysClk			    ( sysClk                    ),
					.arst_sync		    ( arst_sync                 ),				
					.srst_sync		    ( srst_sync                 ),				
	
					// WrFifo Ports  
					.dataFifoRd		    ( dataFifoRd                ),
					.wrInitiatorValid      ( wrInitiatorValid             ),
					.srcInitiator		    ( srcInitiator                 ),
	
					//  Initiator Data  Ports  
					.INITIATOR_WVALID	( INITIATOR_WVALID          ),
					.INITIATOR_WID      ( INITIATOR_WID             ),
					.INITIATOR_WDATA	( INITIATOR_WDATA           ),
					.INITIATOR_WSTRB	( INITIATOR_WSTRB           ),
					.INITIATOR_WLAST	( INITIATOR_WLAST           ),
					.INITIATOR_WUSER	( INITIATOR_WUSER           ),
					.INITIATOR_WREADY	( INITIATOR_WREADY          ),
	
					// target Data Ports  
					.TARGET_WVALID	    ( targetWVALID              ),
					.TARGET_WID         ( targetWID                 ),
					.TARGET_WDATA	    ( targetWDATA               ),
					.TARGET_WSTRB	    ( targetWSTRB               ),
					.TARGET_WLAST	    ( targetWLAST               ),
					.TARGET_WUSER	    ( targetWUSER               ),
					.TARGET_WREADY	    ( TARGET_WREADY[desttarget]  )	
				);				
				
			//====================================================================================
			// Route output of DataMux to individual target ports
			//====================================================================================	
			for (i=0; i< NUM_TARGETS; i=i+1 )
				begin
				  always@(*) begin 
					TARGET_WDATA[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH]               = targetWDATA;
					TARGET_WSTRB[(i+1)*STRB_WIDTH-1:i*STRB_WIDTH]               = targetWSTRB;
					TARGET_WLAST[(i+1)*1-1:i*1]                                 = targetWLAST;
					TARGET_WUSER[(i+1)*USER_WIDTH-1:i*USER_WIDTH]               = targetWUSER;
					TARGET_WID  [(i+1)*INITIATORID_WIDTH-1:i*INITIATORID_WIDTH] = targetWID;	  
				  end 
				end
	
			//================================================================================
			// Mux VALID based on Initiator target port for read
			//================================================================================
			always @(*)
				begin
					aTARGET_WVALID 	= 0;							// initialise to 0 to indicate no transaction - only one can be active
					aTARGET_WVALID[ desttarget ]	= targetWVALID;		// targetWVALID held deasserted unless valid transaction available
				end				
	
			always@(*) 	TARGET_WVALID	= aTARGET_WVALID;
	
				
		end
			
	endgenerate
	
endmodule // caxi4interconnect_WDataController.v
