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
// SVN $Revision: 51202 $
// SVN $Date: 2026-04-16 20:10:05 +0530 (Thu, 16 Apr 2026) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_RDataController # 
	(
		parameter integer NUM_INITIATORS			= 2, 				// defines number of initiators
		parameter integer NUM_INITIATORS_WIDTH		= 1, 				// defines number of bits to encode initiator number
		
		parameter integer NUM_TARGETS     		= 2, 				// defines number of targets
		parameter integer NUM_TARGETS_WIDTH 		= 1,				// defines number of bits to encoode target number

		parameter integer ID_WIDTH   			= 1, 
		parameter integer DATA_WIDTH 			= 32,

		parameter integer SUPPORT_USER_SIGNALS 	= 0,
		parameter integer USER_WIDTH 			= 1,

		parameter integer CROSSBAR_MODE			= 1,				// defines whether non-blocking (ie set 1) or shared access data path
		parameter integer OPEN_RDTRANS_MAX		= 2,

		// Add NUM_THREADS and OPEN_TRANS_MAX for proper FIFO depth calculation
		parameter [(16*32)-1:0] NUM_THREADS  	= {16{32'h1}},		// number of independent threads per initiator supported
		parameter [(16*32)-1:0] OPEN_TRANS_MAX	= {16{32'h2}},		// max number of outstanding transactions per thread

		parameter [NUM_INITIATORS*NUM_TARGETS-1:0] 		INITIATOR_READ_CONNECTIVITY 		= {NUM_INITIATORS*NUM_TARGETS{1'b1}},

		parameter	HI_FREQ						= 0, 				// used to add registers to allow a higher freq of operation at cost of latency
		parameter	RD_ARB_EN 					= 1,				// select arb or ordered rdata
        parameter   PIPE                        = 0,
        parameter   CROSSBAR_RAM_TYPE           = 3,
        parameter   SYNC_RESET                  = 0
   
	)
	(
		// Global Signals
		input  wire                                                    	    sysClk,
		input  wire                                                    	    arst_sync,			// active high reset synchronoise to RE sysClk - asserted async.
		input  wire                                                    	    srst_sync,			// active high reset synchronoise to RE sysClk - asserted async.
   
		//====================== Target Data Ports  ================================================//
  		input  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 		TARGET_ID,
		input  wire [NUM_TARGETS*DATA_WIDTH-1:0]    						TARGET_DATA,
		input  wire [NUM_TARGETS*2-1:0]                         			TARGET_RESP,
		input  wire [NUM_TARGETS-1:0]                           			TARGET_LAST,
		input  wire [NUM_TARGETS*USER_WIDTH-1:0]         			    	TARGET_USER,
		input  wire [NUM_TARGETS-1:0]                           			TARGET_VALID,
		
		output wire [NUM_TARGETS-1:0]                           			TARGET_READY,
		
		//====================== Initiator Data  Ports  ================================================//
		output wire [NUM_INITIATORS*ID_WIDTH-1:0]          				    INITIATOR_ID,
		output wire [NUM_INITIATORS*DATA_WIDTH-1:0]     					INITIATOR_DATA,
		output wire [NUM_INITIATORS*2-1:0]                          		INITIATOR_RESP,
		output wire [NUM_INITIATORS-1:0]                            		INITIATOR_LAST,
		output wire [NUM_INITIATORS*USER_WIDTH-1:0]          				INITIATOR_USER,
		output wire [NUM_INITIATORS-1:0]                            		INITIATOR_VALID,

		input  wire [NUM_INITIATORS-1:0]                            		INITIATOR_READY,
   
		//====================== DataControl Port ============================================//
		
		output wire	[NUM_INITIATORS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 	currDataTransID,	// current data transaction ID
		output wire	[(NUM_INITIATORS*NUM_TARGETS_WIDTH)-1:0]            	currdatatrgt,	// current data transaction ID
		output wire	[NUM_INITIATORS-1:0]  									openTransDec,		// indicates thread matching currDataTransID to be decremented

		//======================= Read Address Controller Port======================================//
		input wire														    rdDataFifoWr,
		input wire	[(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 				    rdSrcPort,
		input wire	[NUM_TARGETS_WIDTH-1:0]								    rdDestPort	
		
	);
   						 
						 
//================================================================================================
// Local Parameters
//================================================================================================

	localparam INITIATORID_WIDTH		= ( NUM_INITIATORS_WIDTH + ID_WIDTH );			// defines width initiatorID - includes infrastructure ID plus ID
	localparam THREAD_VEC_WIDTH		    = ( INITIATORID_WIDTH + NUM_TARGETS_WIDTH );	// defines width of per thread vector elements width

	
	//=======================================================================================================================
	// caxi4interconnect_ReadDataController arbitrates between Targets requestors (RVALID),  drivers to selected targeted Initiator based TARGET_RID
	// and "pops" open transaction with currDataTransID when openTransDec at end of transaction.
	//=======================================================================================================================     
 	genvar i;
	generate
	if (CROSSBAR_MODE == 1)			// implement full non-blocking data path for read data
		begin : MD
		
			// Local parameters
			wire [INITIATORID_WIDTH-1:0] initiatorID		[NUM_INITIATORS -1:0];					
			wire [NUM_TARGETS-1:0]		 targetReady		[NUM_INITIATORS -1:0];			// temp store of vectors from each initiator read controller
			reg [NUM_TARGETS-1:0]		 TARGET_READYVec	[NUM_INITIATORS -1:0];			// temp store of vectors from each initiator read controller

			//==========================================================================
			// Declare a caxi4interconnect_ReadDataController for each Initiator port
			//==========================================================================
			for (i=0; i< NUM_INITIATORS; i=i+1 )
				begin
				
						caxi4interconnect_ReadDataController # 
						(
							.INITIATOR_NUM					( i[3:0]                           ),					//  Explicit 4-bit width for Port number
							.NUM_INITIATORS				    ( NUM_INITIATORS                   ), 				// defines number of initiators
							.NUM_INITIATORS_WIDTH			( NUM_INITIATORS_WIDTH             ), 			// defines number of bits to encode initiator number
							.NUM_TARGETS     			    ( NUM_TARGETS                      ), 				// defines number of targets
							.NUM_TARGETS_WIDTH 			    ( NUM_TARGETS_WIDTH                ),			// defines number of bits to encoode target number
							.ID_WIDTH   				    ( ID_WIDTH                         ), 
							.DATA_WIDTH 				    ( DATA_WIDTH                       ),
							.SUPPORT_USER_SIGNALS 		    ( SUPPORT_USER_SIGNALS             ),
							.USER_WIDTH 				    ( USER_WIDTH                       ),
							.CROSSBAR_MODE				    ( CROSSBAR_MODE                    ),
							.OPEN_RDTRANS_MAX			    ( OPEN_RDTRANS_MAX                 ),
							.NUM_THREADS				    ( NUM_THREADS                      ),				// pass for FIFO depth calculation
							.OPEN_TRANS_MAX				    ( OPEN_TRANS_MAX                   ),				// pass for FIFO depth calculation
							.INITIATOR_READ_CONNECTIVITY 	( INITIATOR_READ_CONNECTIVITY[((i+1)*NUM_TARGETS)-1:i*NUM_TARGETS] ),   // which targets can be read from this initiator
							.HI_FREQ					    ( HI_FREQ                          ),
							.RD_ARB_EN					    ( RD_ARB_EN                        ),							
							.PIPE				   	        ( PIPE                             ),							
							.CROSSBAR_RAM_TYPE			    ( CROSSBAR_RAM_TYPE                ),							
							.SYNC_RESET					    ( SYNC_RESET                       )							
                        )
					rdcon	(
								// Global Signals
								.sysClk             ( sysClk                                                         ),
								.arst_sync          ( arst_sync                                                      ),			// active low reset synchronoise to RE sysClk - asserted async.
								.srst_sync          ( srst_sync                                                      ),			// active low reset synchronoise to RE sysClk - asserted async.
																		                                             
								// Target Data Ports                                                                  
								.TARGET_VALID	    ( TARGET_VALID                                                   ),
								.TARGET_ID		    ( TARGET_ID                                                      ),
								.TARGET_DATA		( TARGET_DATA                                                    ),
								.TARGET_RESP		( TARGET_RESP                                                    ),
								.TARGET_LAST		( TARGET_LAST                                                    ),
								.TARGET_USER		( TARGET_USER                                                    ),
								.TARGET_READY	    ( targetReady[i]                                                 ),

								// Initiator Data  Port  
								.initiatorID		( initiatorID[i]                                                 ),
								.INITIATOR_DATA	    ( INITIATOR_DATA[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH]                ),
								.INITIATOR_RESP	    ( INITIATOR_RESP[(i+1)*2-1:i*2]                                  ),
								.INITIATOR_LAST	    ( INITIATOR_LAST[i]                                              ),
								.INITIATOR_USER	    ( INITIATOR_USER[(i+1)*USER_WIDTH-1:i*USER_WIDTH]                ),
								.INITIATOR_VALID	( INITIATOR_VALID[i]                                             ),
								.INITIATOR_READY	( INITIATOR_READY[i]                                             ),
      
								// Data Controller  
								.currDataTransID    ( currDataTransID[(i+1)*INITIATORID_WIDTH-1:i*INITIATORID_WIDTH] ),	// indicates transaction to be decremented 
								.currdatatrgt       ( currdatatrgt[((i+1)*NUM_TARGETS_WIDTH)-1:i*NUM_TARGETS_WIDTH]  ),	// indicates transaction to be decremented 
								.openTransDec       ( openTransDec[i]                                                ),			// indicates ID of transaction to be decremented

								// Address Controller
								.rdDataFifoWr       ( rdDataFifoWr                                                   ),
								.rdSrcPort          ( rdSrcPort                                                      ),
								.rdDestPort         ( rdDestPort                                                     )
							);
							
					// Drop Infrastructure component from ID 
					assign INITIATOR_ID[(i+1)*ID_WIDTH-1:i*ID_WIDTH] = initiatorID[i][INITIATORID_WIDTH-NUM_INITIATORS_WIDTH-1:0];


					
					
					//====================================================================================================
					// "OR" all targetReadys - each vector should have only 1 bit set
					//====================================================================================================
					always @(*)
						begin
							if (i == 0)
								TARGET_READYVec[0] = targetReady[0];
							else
								// OR all targetReady vectors to allow each "active" initiator to pass its ready.
								TARGET_READYVec[i] = targetReady[i] | TARGET_READYVec[i-1];
						end
					
				end
       
                
				assign TARGET_READY = TARGET_READYVec[NUM_INITIATORS-1];
				
		end
	else
		begin : SD			// implement shared read datapath - only one read mux path

			// Declare local paramaters for shared-mode
			wire [NUM_TARGETS-1:0]			                targetReady;
											                
			wire [INITIATORID_WIDTH-1:0]	                initiatorID;
			wire [DATA_WIDTH-1:0]     		                initiatorDATA;
			wire [1:0]	                                    initiatorRESP;
			wire 				          	                initiatorLAST;
			wire [USER_WIDTH-1:0]                           initiatorUSER;

			reg	[NUM_INITIATORS-1:0]  			            currTransDec;
			
			wire [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 		dataTransID;	// current data transaction ID
			wire [NUM_TARGETS_WIDTH-1:0]            		datatrgt;	// current data transaction ID
			wire											transDec;
			
			wire 				              	            initiatorVALID;
			reg									            initiatorREADY;

			reg [NUM_INITIATORS_WIDTH-1:0]			        targetInitiator, targetInitiatorQ1;
			reg	[NUM_INITIATORS-1:0] 				        aINITIATOR_VALID;
			

	
			caxi4interconnect_ReadDataController # 
				(
					.INITIATOR_NUM					( {NUM_INITIATORS_WIDTH{1'b0} }       ),// Port number - not used in Shared Data mode
					.NUM_INITIATORS				    ( NUM_INITIATORS                      ), 				// defines number of initiators
					.NUM_INITIATORS_WIDTH			( NUM_INITIATORS_WIDTH                ), 			// defines number of bits to encode initiator number
					.NUM_TARGETS     			    ( NUM_TARGETS                         ), 				// defines number of targets
					.NUM_TARGETS_WIDTH 			    ( NUM_TARGETS_WIDTH                   ),			// defines number of bits to encoode target number
					.ID_WIDTH   				    ( ID_WIDTH                            ), 
					.DATA_WIDTH 				    ( DATA_WIDTH                          ),
					.SUPPORT_USER_SIGNALS 		    ( SUPPORT_USER_SIGNALS                ),
					.USER_WIDTH 				    ( USER_WIDTH                          ),
					.CROSSBAR_MODE				    ( CROSSBAR_MODE                       ),
					.OPEN_RDTRANS_MAX			    ( OPEN_RDTRANS_MAX                    ),
					.NUM_THREADS				    ( NUM_THREADS                         ),				// pass for FIFO depth calculation
					.OPEN_TRANS_MAX				    ( OPEN_TRANS_MAX                      ),				// pass for FIFO depth calculation
					.INITIATOR_READ_CONNECTIVITY 	( {NUM_INITIATORS*NUM_TARGETS{1'b1} } ),   // no pruning as one common path
					.HI_FREQ					    ( HI_FREQ                             ),
					.RD_ARB_EN					    ( RD_ARB_EN                           ),							
					.PIPE				   	        ( PIPE                                ),							
					.CROSSBAR_RAM_TYPE		        ( CROSSBAR_RAM_TYPE                   ),							
					.SYNC_RESET					    ( SYNC_RESET                          )							
				)
			rdcon	(
					// Global Signals
					.sysClk             ( sysClk         ),
					.arst_sync          ( arst_sync      ),			// active low reset synchronoise to RE sysClk - asserted async.
					.srst_sync          ( srst_sync      ),			// active low reset synchronoise to RE sysClk - asserted async.
								
					// Target Data Ports  
					.TARGET_VALID	    ( TARGET_VALID   ),
					.TARGET_ID		    ( TARGET_ID      ),
					.TARGET_DATA		( TARGET_DATA    ),
					.TARGET_RESP		( TARGET_RESP    ),
					.TARGET_LAST		( TARGET_LAST    ),
					.TARGET_USER		( TARGET_USER    ),
					.TARGET_READY	    ( targetReady    ),

					// Initiator Data  Port  
					.initiatorID		( initiatorID    ),
					.INITIATOR_DATA	    ( initiatorDATA  ),
					.INITIATOR_RESP	    ( initiatorRESP  ),
					.INITIATOR_LAST	    ( initiatorLAST  ),
					.INITIATOR_USER	    ( initiatorUSER  ),
					.INITIATOR_VALID	( initiatorVALID ),
					.INITIATOR_READY	( initiatorREADY ),
      
					// Data Controller  
					.currDataTransID    ( dataTransID    ),	// indicates transaction to be decremented 
					.currdatatrgt       ( datatrgt       ),	// indicates transaction to be decremented 
					.openTransDec       ( transDec       ),			// indicates ID of transaction to be decremented

					// Address Controller
					.rdDataFifoWr       ( rdDataFifoWr   ),
					.rdSrcPort          ( rdSrcPort      ),
					.rdDestPort         ( rdDestPort     )				
					) ;


			// Initiators have requests stopped when full - stop for any initiator as common data-path

			
			//=============================================================================
			// Route all "common" signals to all initiator interfaces
			//=============================================================================
			for (i=0; i< NUM_INITIATORS; i=i+1 )
				begin
					assign INITIATOR_ID[  (i+1)*ID_WIDTH-1  :i*ID_WIDTH]	= initiatorID[INITIATORID_WIDTH-NUM_INITIATORS_WIDTH-1:0];	// Strip off infrastructure ID
					assign INITIATOR_DATA[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH] 	= initiatorDATA;
					assign INITIATOR_RESP[(i+1)*2-1   		:i*2]			= initiatorRESP;
					assign INITIATOR_LAST[(i+1)*1-1		    :i*1]			= initiatorLAST;
					assign INITIATOR_USER[(i+1)*USER_WIDTH-1:i*USER_WIDTH] 	= initiatorUSER;
				end

			//================================================================================
			// Mux VALID and Reads based on Initiator target port for read
			//================================================================================
			always @(*)
				begin
	
					aINITIATOR_VALID 	                = 0;		// initialise to 0 to indicate no transaction
					
					targetInitiator                        = initiatorID[INITIATORID_WIDTH-1:ID_WIDTH];	// pick out target initiator from RID
					
					aINITIATOR_VALID[ targetInitiator ]	= initiatorVALID;
					initiatorREADY 					    = INITIATOR_READY[targetInitiator];  

					currTransDec					    = 0;
					currTransDec[ targetInitiatorQ1 ] 	    = transDec;

				end

			//======================================================================
			// Pass transDec back to approbriate initiator - needs to be clocked
			// as targetInitiator changes before transDec asserted.
			//======================================================================
			always @(posedge sysClk or negedge arst_sync)
				begin
				  if(~arst_sync | ~srst_sync)
				    targetInitiatorQ1  <= 0;
				  else 
					targetInitiatorQ1	<= targetInitiator;
				end
				
			// Data Controller  signals routed to all ports
			assign currDataTransID	=  { NUM_INITIATORS{ dataTransID } };
			assign currdatatrgt  	=  { NUM_INITIATORS{ datatrgt } };
			assign openTransDec		= currTransDec;
			
			assign INITIATOR_VALID = aINITIATOR_VALID;		
			assign TARGET_READY  = targetReady;	
				
		end
			
	endgenerate

	
endmodule // caxi4interconnect_RDataController.v
