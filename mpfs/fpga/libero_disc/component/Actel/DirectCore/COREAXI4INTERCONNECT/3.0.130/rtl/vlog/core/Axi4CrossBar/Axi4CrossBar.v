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
// SVN $Revision: 51339 $
// SVN $Date: 2026-04-26 06:25:24 -0400 (Sun, 26 Apr 2026) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns
module caxi4interconnect_Axi4CrossBar #
  (
		
		parameter integer NUM_INITIATORS			                                              = 8, 				// defines number of initiator ports 	- valid 1-4
        parameter integer NUM_INITIATORS_WIDTH		                                              = 1,		// defined to be 0 to cause compile error for invalid values	
		parameter integer NUM_TARGETS     		                                                  = 8, 				// defines number of targets	valid 1-8

		parameter integer ID_WIDTH   			                                                  = 1, 				// number of bits for ID (ie AID and WID) - valid 1 - 8

		parameter integer ADDR_WIDTH      		                                                  = 9,				// valid values - 16-64
		parameter integer DATA_WIDTH 			                                                  = 8,				// valid widths - 32, 64, 128
		 
		parameter [(16*32)-1:0] NUM_THREADS  	                                                  = 1,				// defined number of indpendent threads per initiator supported - valid range 1-8
		parameter [(16*32)-1:0] OPEN_TRANS_MAX			                                          = 2,				// max number of outstanding transactions per thread - valid range 1-8
		
		parameter integer OPEN_WRTRANS_MAX			                                              = 3,				// max number of outstanding read transactions per initiator - valid range 1-8
		parameter integer OPEN_RDTRANS_MAX			                                              = 3,				// max number of outstanding read transactions per initiator - valid range 1-8

		parameter UPPER_COMPARE_BIT 			                                                  = 4,				// Defines the upper bit of range to compare
		parameter LOWER_COMPARE_BIT 			                                                  = 1,				// Defines lower bound of compare - bits below are dont care


		parameter [ ( NUM_TARGETS* (ADDR_WIDTH))-1 : 0 ] 			SLOT_BASE_VEC                 = { 5'h1F, 5'h1E, 5'h1D, 5'h1C, 5'h1B, 5'h1A, 5'h19, 5'h18, 
                                                                                                      5'h17, 5'h16, 5'h15, 5'h14, 5'h13, 5'h12, 5'h11, 5'h10, 
                                                                                                      5'hF, 5'hE, 5'hD, 5'hC, 5'hB, 5'hA, 5'h9, 5'h8, 5'h7, 
                                                                                                      5'h6, 5'h5, 5'h4, 5'h3, 5'h2, 5'h1, 5'h0  },
																												//			0,
	
		parameter [ ( NUM_TARGETS* (UPPER_COMPARE_BIT-LOWER_COMPARE_BIT))-1 : 0 ] 	SLOT_MIN_VEC  = { NUM_TARGETS{ 3'b0 }  },	// SLOT Min per target 
		parameter [ ( NUM_TARGETS* (UPPER_COMPARE_BIT-LOWER_COMPARE_BIT))-1 : 0 ] 	SLOT_MAX_VEC  = { NUM_TARGETS{ 3'b111 } },	// SLOT Max per target 

		parameter integer SUPPORT_USER_SIGNALS 	                                                  = 0,					// indicates where user signals upport - 0 mean no, 1 means yes
		parameter integer USER_WIDTH 			                                                  = 1,					// defines the number of bits for USER signals RUSER and WUSER

		parameter integer CROSSBAR_MODE			                                                  = 1,					// defines whether non-blocking (ie set 1) or shared access data path

		parameter [NUM_INITIATORS*NUM_TARGETS-1:0] 		INITIATOR_WRITE_CONNECTIVITY 		      = {NUM_INITIATORS*NUM_TARGETS{1'b1}},	// bit per port indicating if a initiator can write to a target port
		parameter [NUM_INITIATORS*NUM_TARGETS-1:0] 		INITIATOR_READ_CONNECTIVITY 		      = {NUM_INITIATORS*NUM_TARGETS{1'b1}},	// bit per initiator port indicating if a initiator can initiator can read from a target port
	
						
		parameter 	HI_FREQ		                                                                  = 1,			// used to add registers to allow a higher freq of operation at cost of latency
		parameter	RD_ARB_EN 	                                                                  = 1,			// select arb or ordered rdata
		parameter   READ_INTERLEAVE                                                               = 1,
		parameter   PIPE                                                                          = 0,
		parameter   CROSSBAR_RAM_TYPE                                                             = 3,
		parameter   SYNC_RESET                                                                    = 1,
		parameter   MAX_TRANS                                                                     = 2,
		parameter   [NUM_TARGETS-1:0] TARGET_READ_INTERLEAVE                                      = 0		
   )
  (
  
   // Global Signals
   input  wire                                                 ACLK,
   input  wire                                                 arst_sync,
   input  wire                                                 srst_sync,
   
   //================================================= Initiator Ports  ================================================//

   // Initiator Write Address Ports
   input  wire [NUM_INITIATORS*ID_WIDTH-1:0]        	   		INITIATOR_AWID,
   input  wire [NUM_INITIATORS*ADDR_WIDTH-1:0] 		          	INITIATOR_AWADDR,
   input  wire [NUM_INITIATORS*8-1:0]                          	INITIATOR_AWLEN,
   input  wire [NUM_INITIATORS*3-1:0]                          	INITIATOR_AWSIZE,
   input  wire [NUM_INITIATORS*2-1:0]                          	INITIATOR_AWBURST,
   input  wire [NUM_INITIATORS*2-1:0]                          	INITIATOR_AWLOCK,
   input  wire [NUM_INITIATORS*4-1:0]                          	INITIATOR_AWCACHE,
   input  wire [NUM_INITIATORS*3-1:0]                          	INITIATOR_AWPROT,
   input  wire [NUM_INITIATORS*4-1:0]				            INITIATOR_AWREGION,
   input  wire [NUM_INITIATORS*4-1:0]                          	INITIATOR_AWQOS,				// not used
   input  wire [NUM_INITIATORS*USER_WIDTH-1:0]         			INITIATOR_AWUSER,				// not used
   input  wire [NUM_INITIATORS-1:0]                            	INITIATOR_AWVALID,
   output wire [NUM_INITIATORS-1:0]                            	INITIATOR_AWREADY,

   // Initiator Write Data Ports
   input  wire [NUM_INITIATORS*ID_WIDTH-1:0]                    INITIATOR_WID,
   input  wire [NUM_INITIATORS*DATA_WIDTH-1:0]     				INITIATOR_WDATA,
   input  wire [NUM_INITIATORS*DATA_WIDTH/8-1:0]   				INITIATOR_WSTRB,
   input  wire [NUM_INITIATORS-1:0]                             INITIATOR_WLAST,
   input  wire [NUM_INITIATORS*USER_WIDTH-1:0]          		INITIATOR_WUSER,
   input  wire [NUM_INITIATORS-1:0]                           	INITIATOR_WVALID,
   output wire [NUM_INITIATORS-1:0]	               	            INITIATOR_WREADY,
 
	// Initiator Write Response Ports
   output wire [NUM_INITIATORS*ID_WIDTH-1:0]           			INITIATOR_BID,
   output wire [NUM_INITIATORS*2-1:0]                          	INITIATOR_BRESP,
   output wire [NUM_INITIATORS*USER_WIDTH-1:0]          		INITIATOR_BUSER,
   output wire [NUM_INITIATORS-1:0]                            	INITIATOR_BVALID,
   input  wire [NUM_INITIATORS-1:0]                            	INITIATOR_BREADY,

   // Initiator Read Address Ports
   input  wire [NUM_INITIATORS*ID_WIDTH-1:0]           			INITIATOR_ARID,
   input  wire [NUM_INITIATORS*ADDR_WIDTH-1:0]           		INITIATOR_ARADDR,
   input  wire [NUM_INITIATORS*8-1:0]                          	INITIATOR_ARLEN,
   input  wire [NUM_INITIATORS*3-1:0]                          	INITIATOR_ARSIZE,
   input  wire [NUM_INITIATORS*2-1:0]                          	INITIATOR_ARBURST,
   input  wire [NUM_INITIATORS*2-1:0]                          	INITIATOR_ARLOCK,
   input  wire [NUM_INITIATORS*4-1:0]                          	INITIATOR_ARCACHE,
   input  wire [NUM_INITIATORS*3-1:0]                          	INITIATOR_ARPROT,
   input  wire [NUM_INITIATORS*4-1:0]							INITIATOR_ARREGION,
   input  wire [NUM_INITIATORS*4-1:0]                          	INITIATOR_ARQOS,		// not used
   input  wire [NUM_INITIATORS*USER_WIDTH-1:0]         			INITIATOR_ARUSER,
   input  wire [NUM_INITIATORS-1:0]                            	INITIATOR_ARVALID,
   output wire [NUM_INITIATORS-1:0]                            	INITIATOR_ARREADY,

   // Initiator Read Data Ports
   output wire [NUM_INITIATORS*ID_WIDTH-1:0]          			INITIATOR_RID,
   output wire [NUM_INITIATORS*DATA_WIDTH-1:0]     				INITIATOR_RDATA,
   output wire [NUM_INITIATORS*2-1:0]                          	INITIATOR_RRESP,
   output wire [NUM_INITIATORS-1:0]                            	INITIATOR_RLAST,
   output wire [NUM_INITIATORS*USER_WIDTH-1:0]          		INITIATOR_RUSER,
   output wire [NUM_INITIATORS-1:0]                            	INITIATOR_RVALID,
   input  wire [NUM_INITIATORS-1:0]                            	INITIATOR_RREADY,
   
   //======================================== target Ports  ================================================//
   
   // target Write Address Port
   output wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] TARGET_AWID,
   output wire [NUM_TARGETS*ADDR_WIDTH-1:0]          			 TARGET_AWADDR,
   output wire [NUM_TARGETS*8-1:0]                         		 TARGET_AWLEN,
   output wire [NUM_TARGETS*3-1:0]                         		 TARGET_AWSIZE,
   output wire [NUM_TARGETS*2-1:0]                         		 TARGET_AWBURST,
   output wire [NUM_TARGETS*2-1:0]                         		 TARGET_AWLOCK,
   output wire [NUM_TARGETS*4-1:0]                         		 TARGET_AWCACHE,
   output wire [NUM_TARGETS*3-1:0]                         		 TARGET_AWPROT,
   output wire [NUM_TARGETS*4-1:0]                         		 TARGET_AWREGION,			// not used
   output wire [NUM_TARGETS*4-1:0]                         		 TARGET_AWQOS,			// not used
   output wire [NUM_TARGETS*USER_WIDTH-1:0]  	      	  		 TARGET_AWUSER,
   output wire [NUM_TARGETS-1:0]                           		 TARGET_AWVALID,
   input  wire [NUM_TARGETS-1:0]                           		 TARGET_AWREADY,
   
   // target Write Data Ports
   output wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] TARGET_WID,
   output wire [NUM_TARGETS*DATA_WIDTH-1:0]    					 TARGET_WDATA,
   output wire [NUM_TARGETS*DATA_WIDTH/8-1:0]  					 TARGET_WSTRB,
   output wire [NUM_TARGETS-1:0]                           		 TARGET_WLAST,
   output wire [NUM_TARGETS*USER_WIDTH-1:0]	         			 TARGET_WUSER,
   output wire [NUM_TARGETS-1:0]                           		 TARGET_WVALID,
   input  wire [NUM_TARGETS-1:0]                           		 TARGET_WREADY,

   // target Write Response Ports
   input  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] TARGET_BID,
   input  wire [NUM_TARGETS*2-1:0]                         		 TARGET_BRESP,
   input  wire [NUM_TARGETS*USER_WIDTH-1:0]         			 TARGET_BUSER,
   input  wire [NUM_TARGETS-1:0]                           		 TARGET_BVALID,
   output wire [NUM_TARGETS-1:0]                           		 TARGET_BREADY,
   
   // target Read Address Port
   output wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] TARGET_ARID,
   output wire [NUM_TARGETS*ADDR_WIDTH-1:0]          			 TARGET_ARADDR,
   output wire [NUM_TARGETS*8-1:0]                         		 TARGET_ARLEN,
   output wire [NUM_TARGETS*3-1:0]                         		 TARGET_ARSIZE,
   output wire [NUM_TARGETS*2-1:0]                         		 TARGET_ARBURST,
   output wire [NUM_TARGETS*2-1:0]                         		 TARGET_ARLOCK,
   output wire [NUM_TARGETS*4-1:0]                         		 TARGET_ARCACHE,
   output wire [NUM_TARGETS*3-1:0]                         		 TARGET_ARPROT,
   output wire [NUM_TARGETS*4-1:0]                         		 TARGET_ARREGION,			// not used
   output wire [NUM_TARGETS*4-1:0]                         		 TARGET_ARQOS,			// not used
   output wire [NUM_TARGETS*USER_WIDTH-1:0]	        			 TARGET_ARUSER,
   output wire [NUM_TARGETS-1:0]                           		 TARGET_ARVALID,
   input  wire [NUM_TARGETS-1:0]                           		 TARGET_ARREADY,
   
   // target Read Data Ports
   input  wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] TARGET_RID,
   input  wire [NUM_TARGETS*DATA_WIDTH-1:0]    					 TARGET_RDATA,
   input  wire [NUM_TARGETS*2-1:0]                         		 TARGET_RRESP,
   input  wire [NUM_TARGETS-1:0]                           		 TARGET_RLAST,
   input  wire [NUM_TARGETS*USER_WIDTH-1:0]	         			 TARGET_RUSER,			// not used
   input  wire [NUM_TARGETS-1:0]                           		 TARGET_RVALID,
   output wire [NUM_TARGETS-1:0]                           		 TARGET_RREADY
   
   
   );

   
   //=======================================================================================================================
   // Local variables
   //=======================================================================================================================

	localparam	integer	NUM_TARGETS_INT	  = NUM_TARGETS +1;					// defines number of internal target ports - includes internal DERR target
			
    localparam integer NUM_TARGETS_WIDTH  = (NUM_TARGETS_INT == 1) ? 1 : $clog2(NUM_TARGETS_INT); // defines number of bits to encode number of targets number

						

		
	localparam INITIATORID_WIDTH		  = ( NUM_INITIATORS_WIDTH + ID_WIDTH );			// defines width initiatorID - includes infrastructure port number plus ID

																																		
	wire	[NUM_INITIATORS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]	currRDataTransID;	// current data transaction ID
	wire	[(NUM_INITIATORS*NUM_TARGETS_WIDTH)-1:0]               	currrdatatrgt;	// current data transaction ID
	wire	[NUM_INITIATORS-1:0]  									openRTransDec;		// indicates thread matching currDataTransID to be decremented

	wire	[NUM_INITIATORS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0]	currWDataTransID;	// current data transaction ID
	wire	[(NUM_INITIATORS*NUM_TARGETS_WIDTH)-1:0] 	        	currwdatatrgt;	// current data transaction ID
	wire	[NUM_INITIATORS-1:0]  									openWTransDec;		// indicates thread matching currDataTransID to be decremented
	
	
	wire														    dataFifoWr;
	wire	[(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 					srcPort;
	wire	[NUM_TARGETS_WIDTH-1:0]								    destPort;

	wire														    rdDataFifoWr;
	wire	[(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 					rdSrcPort;
	wire	[NUM_TARGETS_WIDTH-1:0]								    rdDestPort;


	//=========================================================================
	// DERR target declarations
	//=========================================================================
	wire [NUM_INITIATORS_WIDTH+ID_WIDTH-1:0]          				DERR_ARID;
	wire [7:0]   	                       						    DERR_ARLEN;
	wire 	                            						    DERR_ARVALID;
	wire 		                           						    DERR_ARREADY;
	
	wire [NUM_INITIATORS_WIDTH+ID_WIDTH-1:0] 						DERR_RID;
	wire [DATA_WIDTH-1:0]    									    DERR_RDATA;
	wire [1:0]                         							    DERR_RRESP;
	wire                            							    DERR_RLAST;
	wire [USER_WIDTH-1:0]         								    DERR_RUSER;
	wire                           								    DERR_RVALID;		
	wire		                           						    DERR_RREADY;
	
	wire [NUM_INITIATORS_WIDTH+ID_WIDTH-1:0]        	   			DERR_AWID;
	wire [7:0]   	                       						    DERR_AWLEN;
	wire 	                            						    DERR_AWVALID;
	wire 		                           						    DERR_AWREADY;

	wire [NUM_INITIATORS_WIDTH+ID_WIDTH-1:0]                        DERR_WID;
	wire [DATA_WIDTH-1:0]    									    DERR_WDATA;
	wire [(DATA_WIDTH/8)-1:0]               					    DERR_WSTRB;
	wire                            							    DERR_WLAST;
	wire [USER_WIDTH-1:0]         								    DERR_WUSER;
	wire                            							    DERR_WVALID;
	wire		                          						    DERR_WREADY;
		
	wire [NUM_INITIATORS_WIDTH+ID_WIDTH-1:0] 						DERR_BID;
	wire [1:0]                         							    DERR_BRESP;
	wire [USER_WIDTH-1:0]         								    DERR_BUSER;
	wire 	                           							    DERR_BVALID;
	wire 					               						    DERR_BREADY;


//=====================================================================================
// function to compute connectiviry map with caxi4interconnect_DERR_Target inserted.
//=====================================================================================
function [NUM_INITIATORS*(NUM_TARGETS+1)-1:0] new_connectivity;

input  [NUM_INITIATORS*NUM_TARGETS-1:0] connectivity;

reg  [NUM_INITIATORS*(NUM_TARGETS+1)-1:0] new_map;
integer i;

begin

	for (i=0; i< NUM_INITIATORS; i=i+1 )
		begin
			new_map[ (i*(NUM_TARGETS+1) ) +: (NUM_TARGETS+1)] = { 1'b1, connectivity[(i*NUM_TARGETS) +: NUM_TARGETS] };
		end
	
	new_connectivity = new_map;
end

endfunction


//=======================================================================================	
// Build new connectivity map adding in caxi4interconnect_DERR_Target
//=======================================================================================
localparam [NUM_INITIATORS*(NUM_TARGETS+1)-1:0]	INITIATOR_READ_CONNECTIVITY_INT = new_connectivity( INITIATOR_READ_CONNECTIVITY );
localparam [NUM_INITIATORS*(NUM_TARGETS+1)-1:0]	INITIATOR_WRITE_CONNECTIVITY_INT = new_connectivity( INITIATOR_WRITE_CONNECTIVITY );


//==================================================================================
// If only 1 Initiator and 1 target generate a pass through
//==================================================================================


    
	//  Width matches NUM_TARGETS (external targets only, DERR target managed separately)
	wire  [NUM_TARGETS-1:0] target_wr_done;
	wire  [NUM_TARGETS-1:0] target_rd_done;
	
    assign target_wr_done = TARGET_BVALID & TARGET_BREADY;
    assign target_rd_done = TARGET_RVALID & TARGET_RREADY & TARGET_RLAST;
	  
	//=======================================================================================================================
	// caxi4interconnect_AddressController arbitrates between Initiator requestors (ARVALID),  drivers to selected targeted target the initiator read
	// address cycle, push outstanding transaction into openTransVec transaction complete. It pops the transaction defined by
	// currDataTransID when openTransDec is asserted.
	//=======================================================================================================================  
  	caxi4interconnect_AddressController # 
		    (
			.NUM_INITIATORS			    ( NUM_INITIATORS                   ), 				// defines number of initiators
			.NUM_INITIATORS_WIDTH	    ( NUM_INITIATORS_WIDTH             ), 			// defines number of bits to encode initiator number
			.NUM_TARGETS     		    ( NUM_TARGETS_INT                  ), 			// defines number of targets - includes DERR target
			.NUM_TARGETS_WIDTH 		    ( NUM_TARGETS_WIDTH                ),			// defines number of bits to encoode target number
			.ID_WIDTH   			    ( ID_WIDTH                         ), 
			.ADDR_WIDTH      		    ( ADDR_WIDTH                       ),
			.NUM_THREADS			    ( NUM_THREADS                      ),			// defined number of indpendent threads per initiator supported 
			.OPEN_TRANS_MAX			    ( OPEN_TRANS_MAX                   ),			// max number of outstanding transactions 
			.UPPER_COMPARE_BIT 		    ( UPPER_COMPARE_BIT                ),		// Defines the upper bit of range to compare
			.LOWER_COMPARE_BIT 		    ( LOWER_COMPARE_BIT                ),		// Defines lower bound of compare - bits below are dont care
			.SLOT_BASE_VEC 			    ( SLOT_BASE_VEC                    ),			// SLOT Base per target 
			.SLOT_MIN_VEC  			    ( SLOT_MIN_VEC                     ),			// SLOT Min per target 
			.SLOT_MAX_VEC  			    ( SLOT_MAX_VEC                     ),			// SLOT Max per target 
			.SUPPORT_USER_SIGNALS 	    ( SUPPORT_USER_SIGNALS             ),
			.AUSER_WIDTH 			    ( USER_WIDTH                       ),
			.INITIATOR_CONNECTIVITY 	( INITIATOR_READ_CONNECTIVITY_INT  ),		// DERR target is included
			.HI_FREQ                    ( HI_FREQ                          ),
			.WR_MODULE                  (1'b0                              ),       // jhayes : Parameter to indicate a read caxi4interconnect_AddressController.
			.PIPE                       (PIPE                              ),						
			.CROSSBAR_RAM_TYPE          (CROSSBAR_RAM_TYPE                 ),						
			.SYNC_RESET				    (SYNC_RESET                        ),
		    .CROSSBAR_MODE			    ( CROSSBAR_MODE                    ),  
		    .MAX_TRANS   			    ( MAX_TRANS                        ),  
		    .TARGET_READ_INTERLEAVE     ( TARGET_READ_INTERLEAVE           )  
		    ) 
	arcon	(
				// Global Signals
				.sysClk          ( ACLK                             ),
				.arst_sync       ( arst_sync                        ),			// active low reset synchronoise to RE AClk - asserted async.
				.srst_sync       ( srst_sync                        ),			// active low reset synchronoise to RE AClk - asserted async.
   
				// Initiator Address Ports
				.INITIATOR_AID   ( INITIATOR_ARID                   ),
				.INITIATOR_AADDR ( INITIATOR_ARADDR                 ),
		
				.INITIATOR_ALEN  ( INITIATOR_ARLEN                  ),
				.INITIATOR_ASIZE ( INITIATOR_ARSIZE                 ),
				.INITIATOR_ABURST( INITIATOR_ARBURST                ),
				.INITIATOR_ALOCK ( INITIATOR_ARLOCK                 ),
				.INITIATOR_ACACHE( INITIATOR_ARCACHE                ),
				.INITIATOR_APROT ( INITIATOR_ARPROT                 ),
				.INITIATOR_AQOS  ( INITIATOR_ARQOS                  ),
				.INITIATOR_AUSER ( INITIATOR_ARUSER                 ),
				.INITIATOR_AVALID( INITIATOR_ARVALID                ),
				.INITIATOR_AREADY( INITIATOR_ARREADY                ),
   
				// target Address Port
				.TARGET_AID      ( { DERR_ARID, TARGET_ARID }       ),
				.TARGET_AADDR    ( TARGET_ARADDR                    ),
				.TARGET_ALEN     ( { DERR_ARLEN, TARGET_ARLEN }     ),
				.TARGET_ASIZE    ( TARGET_ARSIZE                    ),
				.TARGET_ABURST   ( TARGET_ARBURST                   ),
				.TARGET_ALOCK    ( TARGET_ARLOCK                    ),
				.TARGET_ACACHE   ( TARGET_ARCACHE                   ),
				.TARGET_APROT    ( TARGET_ARPROT                    ),
				.TARGET_AQOS     ( TARGET_ARQOS                     ),
				.TARGET_AUSER    ( TARGET_ARUSER                    ),
				.TARGET_AVALID   ( { DERR_ARVALID, TARGET_ARVALID } ),
				.TARGET_AREADY   ( { DERR_ARREADY, TARGET_ARREADY } ),
   
			// DataControl Port 
				.currDataTransID ( currRDataTransID                 ),	// current data transaction ID
				.currdatatrgt    ( currrdatatrgt                    ),	// current data transaction ID
				.openTransDec    ( openRTransDec                    ),			// indicates thread matching currDataTransID to be decremented
				.dataFifoWr      ( rdDataFifoWr                     ),
				.srcPort         ( rdSrcPort                        ),
				.destPort        ( rdDestPort                       ),
				.target_done     ( target_rd_done                   )
			);
   
   
   
	//=======================================================================================================================
	// DataController arbitrates between targets requestors (RVALID),  drivers to selected targeted Initiator based TARGET_RID
	// and "pops" open transaction with currDataTransID when openTransDec at end of transaction.
	//=======================================================================================================================     
 						 
	caxi4interconnect_RDataController # 
			(
				.NUM_INITIATORS			     ( NUM_INITIATORS                  ), 				// defines number of initiators
				.NUM_INITIATORS_WIDTH		 ( NUM_INITIATORS_WIDTH            ), 			// defines number of bits to encode initiator number
				.NUM_TARGETS     		     ( NUM_TARGETS_INT                 ), 			// defines number of targets - includes DERR target
				.NUM_TARGETS_WIDTH 		     ( NUM_TARGETS_WIDTH               ),			// defines number of bits to encoode target number
				.ID_WIDTH   			     ( ID_WIDTH                        ), 
				.DATA_WIDTH 			     ( DATA_WIDTH                      ),
				.SUPPORT_USER_SIGNALS 	     ( SUPPORT_USER_SIGNALS            ),
				.USER_WIDTH 			     ( USER_WIDTH                      ),
				.CROSSBAR_MODE			     ( CROSSBAR_MODE                   ),				// defines whether non-blocking (ie set 1) or shared access data path
				.OPEN_RDTRANS_MAX		     ( OPEN_RDTRANS_MAX                ),
				.NUM_THREADS			     ( NUM_THREADS                     ),				// pass NUM_THREADS for FIFO depth calculation
				.OPEN_TRANS_MAX			     ( OPEN_TRANS_MAX                  ),				// pass OPEN_TRANS_MAX for FIFO depth calculation
				.INITIATOR_READ_CONNECTIVITY ( INITIATOR_READ_CONNECTIVITY_INT ),		// DERR target is always "readable"
				.HI_FREQ				     ( HI_FREQ                         ),
				.RD_ARB_EN				     ( RD_ARB_EN                       ),						
				.PIPE				         ( PIPE                            ),						
				.CROSSBAR_RAM_TYPE		     ( CROSSBAR_RAM_TYPE               ),						
				.SYNC_RESET				     ( SYNC_RESET                      )			
			)
	rDCon	(
				// Global Signals
				.sysClk             ( ACLK                            ),
				.arst_sync          ( arst_sync                       ),			// active low reset synchronoise to RE AClk - asserted async.
				.srst_sync          ( srst_sync                       ),			// active low reset synchronoise to RE AClk - asserted async.

				// target Data Ports  
				.TARGET_VALID	    ( { DERR_RVALID, TARGET_RVALID 	} ),
				.TARGET_ID		    ( { DERR_RID, TARGET_RID 		} ),
				.TARGET_DATA		( { DERR_RDATA, TARGET_RDATA 	} ),
				.TARGET_RESP		( { DERR_RRESP, TARGET_RRESP 	} ),
				.TARGET_LAST		( { DERR_RLAST, TARGET_RLAST 	} ),
				.TARGET_USER		( { DERR_RUSER, TARGET_RUSER 	} ),
				.TARGET_READY	    ( { DERR_RREADY, TARGET_RREADY 	} ),
		
				// Initiator Data  Ports  
				.INITIATOR_ID		( INITIATOR_RID                   ),
				.INITIATOR_DATA	    ( INITIATOR_RDATA                 ),
				.INITIATOR_RESP	    ( INITIATOR_RRESP                 ),
				.INITIATOR_LAST	    ( INITIATOR_RLAST                 ),
				.INITIATOR_USER	    ( INITIATOR_RUSER                 ),
				.INITIATOR_VALID	( INITIATOR_RVALID                ),
				.INITIATOR_READY	( INITIATOR_RREADY                ),
      
				// Data Controller  
				.currDataTransID    ( currRDataTransID                ),	// indicates transaction to be decremented 
				.currdatatrgt       ( currrdatatrgt                   ),	// indicates transaction to be decremented 
				.openTransDec       ( openRTransDec                   ),			// indicates ID of transaction to be decremented

				// Address Controller
				.rdDataFifoWr       ( rdDataFifoWr                    ),
				.rdSrcPort          ( rdSrcPort                       ),
				.rdDestPort         ( rdDestPort                      )
			);
   						   
   
 
	//=======================================================================================================================
	// caxi4interconnect_AddressController arbitrates between Initiator requestors (AWVALID),  drives to selected targeted target the initiator read
	// address cycle, push outstanding transaction into openTransVec transaction complete. It pops the transaction defined by
	// currDataTransID when openTransDec is asserted.
	//=======================================================================================================================  
  	caxi4interconnect_AddressController # 
	    	(
			.NUM_INITIATORS			    ( NUM_INITIATORS                   ), 				// defines number of initiators
			.NUM_INITIATORS_WIDTH		( NUM_INITIATORS_WIDTH             ), 			// defines number of bits to encode initiator number
			.NUM_TARGETS     		    ( NUM_TARGETS_INT                  ), 			// defines number of targets
			.NUM_TARGETS_WIDTH 		    ( NUM_TARGETS_WIDTH                ),			// defines number of bits to encoode target number
			.ID_WIDTH   			    ( ID_WIDTH                         ), 
			.ADDR_WIDTH      		    ( ADDR_WIDTH                       ),
			.NUM_THREADS			    ( NUM_THREADS                      ),			// defined number of indpendent threads per initiator supported 
			.OPEN_TRANS_MAX			    ( OPEN_TRANS_MAX                   ),			// max number of outstanding transactions 
			.UPPER_COMPARE_BIT 		    ( UPPER_COMPARE_BIT                ),		// Defines the upper bit of range to compare
			.LOWER_COMPARE_BIT 		    ( LOWER_COMPARE_BIT                ),		// Defines lower bound of compare - bits below are dont care
			.SLOT_BASE_VEC 			    ( SLOT_BASE_VEC                    ),			// SLOT Base per target 
			.SLOT_MIN_VEC  			    ( SLOT_MIN_VEC                     ),			// SLOT Min per target 
			.SLOT_MAX_VEC  			    ( SLOT_MAX_VEC                     ),			// SLOT Max per target 
			.SUPPORT_USER_SIGNALS 	    ( SUPPORT_USER_SIGNALS             ),
			.AUSER_WIDTH 			    ( USER_WIDTH                       ),
			.INITIATOR_CONNECTIVITY 	( INITIATOR_WRITE_CONNECTIVITY_INT ), 		// DERR target is included
			.HI_FREQ                    ( HI_FREQ                          ),
            .WR_MODULE                  ( 1'b1                             ),       // jhayes : Parameter to indicate a read caxi4interconnect_AddressController.
			.PIPE                       ( PIPE                             ),                                                 // jhayes : Parameter to indicate a write caxi4interconnect_AddressController.
			.CROSSBAR_RAM_TYPE          ( CROSSBAR_RAM_TYPE                ),
			.SYNC_RESET                 ( SYNC_RESET                       ),
			.CROSSBAR_MODE		        ( CROSSBAR_MODE                    ),                                                 // jhayes : Parameter to indicate a write caxi4interconnect_AddressController.
			.MAX_TRANS  		        ( MAX_TRANS                        )                                                 // jhayes : Parameter to indicate a write caxi4interconnect_AddressController.
            )
	awcon	(
				// Global Signals
				.sysClk          ( ACLK                             ),
				.arst_sync       ( arst_sync                        ),			// active low reset synchronoise to RE AClk - asserted async.
				.srst_sync       ( srst_sync                        ),			// active low reset synchronoise to RE AClk - asserted async.
   
				// Initiator Address Ports
				.INITIATOR_AID   ( INITIATOR_AWID                   ),
				.INITIATOR_AADDR ( INITIATOR_AWADDR                 ),
		
				.INITIATOR_ALEN  ( INITIATOR_AWLEN                  ),
				.INITIATOR_ASIZE ( INITIATOR_AWSIZE                 ),
				.INITIATOR_ABURST( INITIATOR_AWBURST                ),
				.INITIATOR_ALOCK ( INITIATOR_AWLOCK                 ),
				.INITIATOR_ACACHE( INITIATOR_AWCACHE                ),
				.INITIATOR_APROT ( INITIATOR_AWPROT                 ),
				.INITIATOR_AQOS  ( INITIATOR_AWQOS                  ),
				.INITIATOR_AUSER ( INITIATOR_AWUSER                 ),
				.INITIATOR_AVALID( INITIATOR_AWVALID                ),
				.INITIATOR_AREADY( INITIATOR_AWREADY                ),
   
				// target Address Port
				.TARGET_AID      (  { DERR_AWID, TARGET_AWID }      ),
				.TARGET_AADDR    ( TARGET_AWADDR                    ),
				.TARGET_ALEN     ( { DERR_AWLEN, TARGET_AWLEN }     ),
				.TARGET_ASIZE    ( TARGET_AWSIZE                    ),
				.TARGET_ABURST   ( TARGET_AWBURST                   ),
				.TARGET_ALOCK    ( TARGET_AWLOCK                    ),
				.TARGET_ACACHE   ( TARGET_AWCACHE                   ),
				.TARGET_APROT    ( TARGET_AWPROT                    ),
				.TARGET_AQOS     ( TARGET_AWQOS                     ),
				.TARGET_AUSER    ( TARGET_AWUSER                    ),
				.TARGET_AVALID   ( { DERR_AWVALID, TARGET_AWVALID } ),
				.TARGET_AREADY   ( { DERR_AWREADY, TARGET_AWREADY } ),
   
			// DataControl Port 
				.currDataTransID ( currWDataTransID                 ),		// current data transaction ID
				.currdatatrgt    ( currwdatatrgt                    ),		// current data transaction ID
				.openTransDec    ( openWTransDec                    ),				// indicates thread matching currDataTransID to be decremented
				.dataFifoWr      ( dataFifoWr                       ),
				.srcPort         ( srcPort                          ),
				.destPort        ( destPort                         ),
				.target_done     ( target_wr_done                   )
			);
   
 

//====================================================================================================
 // caxi4interconnect_WDataController stores write address transactions and uses them to select order initiator write data
 // transactions will be performed.
 //=================================================================================================== 
    caxi4interconnect_WDataController # 
			(
				.NUM_INITIATORS				    ( NUM_INITIATORS                   ),	
				.NUM_INITIATORS_WIDTH		    ( NUM_INITIATORS_WIDTH             ),
				.NUM_TARGETS 				    ( NUM_TARGETS_INT                  ),
				.NUM_TARGETS_WIDTH 			    ( NUM_TARGETS_WIDTH                ),
				.ID_WIDTH  					    ( ID_WIDTH                         ),
				.DATA_WIDTH					    ( DATA_WIDTH                       ),
				.OPEN_WRTRANS_MAX			    ( OPEN_WRTRANS_MAX                 ),
				.NUM_THREADS				    ( NUM_THREADS                      ),				// pass NUM_THREADS for FIFO depth calculation
				.OPEN_TRANS_MAX				    ( OPEN_TRANS_MAX                   ),				// pass OPEN_TRANS_MAX for FIFO depth calculation
				.SUPPORT_USER_SIGNALS		    ( SUPPORT_USER_SIGNALS             ),
				.USER_WIDTH 				    ( USER_WIDTH                       ),
				.CROSSBAR_MODE				    ( CROSSBAR_MODE                    ),					// defines whether non-blocking (ie set 1) or shared access data path
				.INITIATOR_WRITE_CONNECTIVITY	( INITIATOR_WRITE_CONNECTIVITY_INT ),	// DERR target is always writable
				.HI_FREQ					    ( HI_FREQ                          ),
				.PIPE					        ( PIPE                             ),
				.SYNC_RESET				        ( SYNC_RESET                       ),
				.CROSSBAR_RAM_TYPE 			    ( CROSSBAR_RAM_TYPE                )
            )
	wDCon(
				// Global Signals
				.sysClk			    ( ACLK                             ),
				.arst_sync          ( arst_sync                        ),			// active low reset synchronoise to RE AClk - asserted async.
				.srst_sync          ( srst_sync                        ),			// active low reset synchronoise to RE AClk - asserted async.

				// WrFifo Ports  
				.dataFifoWr         ( dataFifoWr                       ),
				.srcPort            ( srcPort                          ),
				.destPort           ( destPort                         ),

				//  Initiator Data  Ports  
				.INITIATOR_WVALID	( INITIATOR_WVALID                 ),
				.INITIATOR_WID      ( INITIATOR_WID                    ),
				.INITIATOR_WDATA	( INITIATOR_WDATA                  ),
				.INITIATOR_WSTRB	( INITIATOR_WSTRB                  ),
				.INITIATOR_WLAST	( INITIATOR_WLAST                  ),
				.INITIATOR_WUSER	( INITIATOR_WUSER                  ),
				.INITIATOR_WREADY	( INITIATOR_WREADY                 ),

				// target Data Ports  
				.TARGET_WID         ( { DERR_WID   , TARGET_WID     }  ),
				.TARGET_WVALID	    ( { DERR_WVALID, TARGET_WVALID 	}  ),
				.TARGET_WDATA	    ( { DERR_WDATA, TARGET_WDATA 	}  ),
				.TARGET_WSTRB	    ( { DERR_WSTRB, TARGET_WSTRB 	}  ),
				.TARGET_WLAST	    ( { DERR_WLAST, TARGET_WLAST 	}  ),
				.TARGET_WUSER	    ( { DERR_WUSER, TARGET_WUSER 	}  ),
				.TARGET_WREADY	    ( { DERR_WREADY, TARGET_WREADY	}  ) 	
			);


   
	
	//=======================================================================================================================
	// DataController arbitrates between targets response requestors (BVALID),  drivers to selected targeted Initiator based 
	// TARGET_BID and "pops" open transaction with currDataTransID when openTransDec at end of transaction.
	//=======================================================================================================================     
 						 
	caxi4interconnect_RespController # 
			(
				.NUM_INITIATORS			        ( NUM_INITIATORS                    ), 				// defines number of initiators
				.NUM_INITIATORS_WIDTH		    ( NUM_INITIATORS_WIDTH              ), 			// defines number of bits to encode initiator number
				.NUM_TARGETS     		        ( NUM_TARGETS_INT                   ), 				// defines number of targets - including DERR target
				.NUM_TARGETS_WIDTH 		        ( NUM_TARGETS_WIDTH                 ),			// defines number of bits to encoode target number
				.ID_WIDTH   			        ( ID_WIDTH                          ), 
				.SUPPORT_USER_SIGNALS 	        ( SUPPORT_USER_SIGNALS              ),
				.USER_WIDTH 			        ( USER_WIDTH                        ),
				.INITIATOR_WRITE_CONNECTIVITY 	( INITIATOR_WRITE_CONNECTIVITY_INT  ), 		// DERR target is always writable
				.INITIATOR_READ_CONNECTIVITY 	( INITIATOR_READ_CONNECTIVITY_INT   )          // DERR target is always readable
			)
	rcon	(
				// Global Signals
				.sysClk             ( ACLK                            ),
				.arst_sync          ( arst_sync                       ),			// active low reset synchronoise to RE AClk - asserted async.
				.srst_sync          ( srst_sync                       ),			// active low reset synchronoise to RE AClk - asserted async.

				//====================== target Data Ports  ================================================//
				.TARGET_VALID	    ( { DERR_BVALID, TARGET_BVALID	} ),
				.TARGET_ID		    ( { DERR_BID, TARGET_BID 		} ),
				.TARGET_RESP		( { DERR_BRESP, TARGET_BRESP 	} ),
				.TARGET_USER		( { DERR_BUSER, TARGET_BUSER 	} ),
				.TARGET_READY	    ( { DERR_BREADY, TARGET_BREADY 	} ),
		
				//====================== Initiator Data  Ports  ================================================//
				.INITIATOR_ID		( INITIATOR_BID                   ),
				.INITIATOR_RESP	    ( INITIATOR_BRESP                 ),
				.INITIATOR_USER	    ( INITIATOR_BUSER                 ),
				.INITIATOR_VALID	( INITIATOR_BVALID                ),
				.INITIATOR_READY	( INITIATOR_BREADY                ),
      
				//====================== Data Controller  ================================================//
				.currDataTransID    ( currWDataTransID                ),	// indicates transaction to be decremented 
				.currdatatrgt       ( currwdatatrgt                   ),	// indicates transaction to be decremented 
				.openTransDec       ( openWTransDec                   )			// indicates ID of transaction to be decremented

            );
   						   

	//=======================================================================================================================
	// caxi4interconnect_DERR_Target provides an internal target for decode errors - provides decerr response to initiators
	//=======================================================================================================================     
						   
	caxi4interconnect_DERR_Target # 
			( 	
				.ID_WIDTH	( INITIATORID_WIDTH ), 	// includes infrastrucre ID
				.DATA_WIDTH	( DATA_WIDTH        ),
				.USER_WIDTH ( USER_WIDTH        ),
				.RESP_CODE  ( 2'b11             )
			)
		derr
			(
				// Global Signals
				.sysClk		 ( ACLK             ),
				.arst_sync   ( arst_sync        ),			// active low reset synchronoise to RE AClk - asserted async.
				.srst_sync   ( srst_sync        ),			// active low reset synchronoise to RE AClk - asserted async.
				
				//====================== Read Address Ports  ================================================//
				.DERR_ARID	 ( 	DERR_ARID 	    ),
				.DERR_ARLEN	 ( 	DERR_ARLEN 	    ),
				.DERR_ARVALID( 	DERR_ARVALID    ),
				.DERR_ARREADY( 	DERR_ARREADY    ),

				//====================== Read Data Ports  ================================================//
				.DERR_RID    ( 		DERR_RID	),
				.DERR_RDATA  ( 	DERR_RDATA 	    ),
				.DERR_RRESP  ( 	DERR_RRESP 	    ),
				.DERR_RLAST  ( 	DERR_RLAST 	    ),
				.DERR_RUSER  ( 	DERR_RUSER 	    ),
				.DERR_RVALID (	DERR_RVALID     ),		
				.DERR_RREADY (	DERR_RREADY     ),
		
				//====================== Write  Address Ports  ================================================//
				.DERR_AWID   ( 	DERR_AWID 	    ),
				.DERR_AWLEN  ( 	DERR_AWLEN 	    ),
				.DERR_AWVALID( 	DERR_AWVALID    ),
				.DERR_AWREADY( 	DERR_AWREADY    ),

				//====================== Write  Data Ports  ================================================//
				.DERR_WID    ( DERR_WID         ),
				.DERR_WDATA  ( DERR_WDATA       ),
				.DERR_WSTRB  ( DERR_WSTRB       ),
				.DERR_WLAST  ( DERR_WLAST       ),
				.DERR_WUSER  ( DERR_WUSER       ),
				.DERR_WVALID ( DERR_WVALID      ),
		
				.DERR_WREADY ( DERR_WREADY      ),
		
				//====================== Write Resp Ports  ================================================//
				.DERR_BID    ( 		DERR_BID	),
				.DERR_BRESP  ( 	DERR_BRESP 	    ),
				.DERR_BUSER  ( 	DERR_BUSER 	    ),
				.DERR_BVALID ( 	DERR_BVALID     ),
				.DERR_BREADY (	DERR_BREADY     )
 
	);

	assign TARGET_ARREGION 	= 0; // not used (andreag: set default value as define in page A10-115 of AXI specs)
	assign TARGET_AWREGION 	= 0; // not used (andreag: set default value as define in page A10-113 of AXI specs)
	
endmodule		// caxi4interconnect_Axi4CrossBar
