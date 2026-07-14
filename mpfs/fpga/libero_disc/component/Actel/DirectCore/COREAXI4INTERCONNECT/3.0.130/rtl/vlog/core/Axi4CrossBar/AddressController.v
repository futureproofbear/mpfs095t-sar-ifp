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

module caxi4interconnect_AddressController # 
	(
		parameter integer NUM_INITIATORS			= 2, 				// defines number of initiators
		parameter integer NUM_INITIATORS_WIDTH		= 1, 				// defines number of bits to encode initiator number
		
		parameter integer NUM_TARGETS     		    = 2, 				// defines number of targets
		parameter integer NUM_TARGETS_WIDTH 		= 1,				// defines number of bits to encoode target number

		parameter integer ID_WIDTH   		     	= 1, 

		parameter integer ADDR_WIDTH      		    = 20,
		
		parameter [(16*32)-1:0] NUM_THREADS		    = 1,		// defined number of indpendent threads per initiator supported 
		parameter [(16*32)-1:0] OPEN_TRANS_MAX	    = 3,		// max number of outstanding transactions 

		parameter UPPER_COMPARE_BIT 	            = 15,		// Defines the upper bit of range to compare
		parameter LOWER_COMPARE_BIT 	            = 12,		// Defines lower bound of compare - bits below are dont care

		// Define memory map for targets - none for DERR target
		parameter [ ( (NUM_TARGETS-1)* (ADDR_WIDTH) )-1 : 0 ] 			SLOT_BASE_VEC = { 5'h1F, 5'h0 },		// SLOT Base per target 
		parameter [ ( (NUM_TARGETS-1)* (UPPER_COMPARE_BIT-LOWER_COMPARE_BIT))-1 : 0 ] 	SLOT_MIN_VEC  = { 2'h0, 2'h0  },		// SLOT Min per target 
		parameter [ ( (NUM_TARGETS-1)* (UPPER_COMPARE_BIT-LOWER_COMPARE_BIT))-1 : 0 ] 	SLOT_MAX_VEC  = { 3'b111, 3'b111 },		// SLOT Max per target 

		parameter integer SUPPORT_USER_SIGNALS 	    = 0,
		parameter integer AUSER_WIDTH 			    = 1,

		parameter [NUM_INITIATORS*NUM_TARGETS-1:0] 	INITIATOR_CONNECTIVITY	= { NUM_INITIATORS*NUM_TARGETS{1'b1} },					// includes caxi4interconnect_DERR_Target

		parameter HI_FREQ 			                        = 1,				// increases freq of operation at cost of added latency
        parameter WR_MODULE                                 = 1,
		parameter PIPE                                      = 1,
		parameter CROSSBAR_RAM_TYPE                         = 3,
		parameter SYNC_RESET		                        = 1,
		parameter CROSSBAR_MODE		                        = 1,
		parameter MAX_TRANS  		                        = 1,
		parameter [NUM_TARGETS-1:0] TARGET_READ_INTERLEAVE  = 1
  
	)
	(
		// Global Signals
		input  wire                                                    	sysClk,
		input  wire                                                    	arst_sync,			// active low reset synchronoise to RE AClk - asserted async.
		input  wire                                                    	srst_sync,			// active low reset synchronoise to RE AClk - asserted async.
   
		//====================== Initiator Ports  ================================================//

		// Initiator Address Ports
		input  wire [NUM_INITIATORS*ID_WIDTH-1:0]        	   				INITIATOR_AID,
		input  wire [NUM_INITIATORS*ADDR_WIDTH-1:0] 		          		INITIATOR_AADDR,		
		input  wire [NUM_INITIATORS*8-1:0]                          		INITIATOR_ALEN,
		input  wire [NUM_INITIATORS*3-1:0]                          		INITIATOR_ASIZE,
		input  wire [NUM_INITIATORS*2-1:0]                          		INITIATOR_ABURST,
		input  wire [NUM_INITIATORS*2-1:0]                          		INITIATOR_ALOCK,
		input  wire [NUM_INITIATORS*4-1:0]                          		INITIATOR_ACACHE,
		input  wire [NUM_INITIATORS*3-1:0]                          		INITIATOR_APROT,
		input  wire [NUM_INITIATORS*4-1:0]                          		INITIATOR_AQOS,
		input  wire [NUM_INITIATORS*AUSER_WIDTH-1:0]         				INITIATOR_AUSER,
		input  wire [NUM_INITIATORS-1:0]                            		INITIATOR_AVALID,
		output wire [NUM_INITIATORS-1:0]                            		INITIATOR_AREADY,
   
		//====================== Target Ports  ================================================//
   
		// Target Address Port
		output wire [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 		TARGET_AID,
		output wire [NUM_TARGETS*8-1:0]                         			TARGET_ALEN,
		
		output wire [(NUM_TARGETS-1)*ADDR_WIDTH-1:0]          			    TARGET_AADDR,		// not routed to DECERR Targets
		output wire [(NUM_TARGETS-1)*3-1:0]                      		    TARGET_ASIZE,		// not routed to DECERR Targets
		output wire [(NUM_TARGETS-1)*2-1:0]                      		    TARGET_ABURST,		// not routed to DECERR Targets
		output wire [(NUM_TARGETS-1)*2-1:0]                      		    TARGET_ALOCK,		// not routed to DECERR Targets
		output wire [(NUM_TARGETS-1)*4-1:0]                      		    TARGET_ACACHE,		// not routed to DECERR Targets
		output wire [(NUM_TARGETS-1)*3-1:0]                      		    TARGET_APROT,		// not routed to DECERR Targets
		output wire [(NUM_TARGETS-1)*4-1:0]                      		    TARGET_AQOS,			// not routed to DECERR Targets
		output wire [(NUM_TARGETS-1)*AUSER_WIDTH-1:0]        			    TARGET_AUSER,		// not routed to DECERR Targets		

		output wire [NUM_TARGETS-1:0]                           			TARGET_AVALID,
		input  wire [NUM_TARGETS-1:0]                           			TARGET_AREADY,
   
 
		//====================== DataControl Port ============================================//
		
		input wire	[NUM_INITIATORS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 	currDataTransID,	// current data transaction ID
		input wire	[(NUM_INITIATORS*NUM_TARGETS_WIDTH)-1:0] 		        currdatatrgt,	// current data transaction ID
		input wire	[NUM_INITIATORS-1:0]  									openTransDec,		// indicates thread matching currDataTransID to be decremented
		
		output wire														    dataFifoWr,
		output wire	[(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 					srcPort,
		output wire	[NUM_TARGETS_WIDTH-1:0]								    destPort,
		
		input  wire [NUM_TARGETS-1:0]                                       target_done
	);
   						 
						 
//================================================================================================
// Local Parameters
//================================================================================================

	localparam INITIATORID_WIDTH		= ( NUM_INITIATORS_WIDTH + ID_WIDTH );			// defines width initiatorID - includes infrastructure ID plus ID
                                                                                              
	localparam OUTSTNDNG_FIFO_WIDTH     = NUM_TARGETS_WIDTH + ADDR_WIDTH + INITIATORID_WIDTH + 8 + 3 + 2 + 2 + 4 + 3 + 4 + AUSER_WIDTH;
	localparam ACHNL_WIDTH              = ADDR_WIDTH + INITIATORID_WIDTH + 8 + 3 + 2 + 2 + 4 + 3 + 4 + AUSER_WIDTH;
	
	
	
//=================================================================================================
// Local Declarationes
//=================================================================================================
 
	wire 	[ADDR_WIDTH-1:0]		         initiatoraddr   [NUM_INITIATORS-1:0];
	wire 	[INITIATORID_WIDTH-1:0]	         initiatorid     [NUM_INITIATORS-1:0];
	wire 	[7:0]	                         initiatoralen   [NUM_INITIATORS-1:0];
	wire    [3-1:0]                          initiatorasize  [NUM_INITIATORS-1:0];
	wire    [2-1:0]                          initiatoraburst [NUM_INITIATORS-1:0];
	wire    [2-1:0]                          initiatoralock  [NUM_INITIATORS-1:0];
	wire    [4-1:0]                          initiatoracache [NUM_INITIATORS-1:0];
	wire    [3-1:0]                          initiatoraprot  [NUM_INITIATORS-1:0];
	wire    [4-1:0]                          initiatoraqos   [NUM_INITIATORS-1:0];
	wire    [AUSER_WIDTH-1:0]                initiatorauser  [NUM_INITIATORS-1:0];	
	wire    [NUM_TARGETS_WIDTH-1:0]          initiatortarget [NUM_INITIATORS-1:0];
	
    wire 	[ADDR_WIDTH-1:0]		         dst_intraddr   [NUM_INITIATORS-1:0];	
    wire 	[INITIATORID_WIDTH-1:0]	         dst_intrid     [NUM_INITIATORS-1:0];
    wire 	[7:0]	                         dst_intralen   [NUM_INITIATORS-1:0];
    wire    [3-1:0]                          dst_intrasize  [NUM_INITIATORS-1:0];
    wire    [2-1:0]                          dst_intraburst [NUM_INITIATORS-1:0];	
    wire    [2-1:0]                          dst_intralock  [NUM_INITIATORS-1:0];	
    wire    [4-1:0]                          dst_intracache [NUM_INITIATORS-1:0];	
    wire    [3-1:0]                          dst_intraprot  [NUM_INITIATORS-1:0];	
    wire    [4-1:0]                          dst_intraqos   [NUM_INITIATORS-1:0];	
    wire    [AUSER_WIDTH-1:0]                dst_intrauser  [NUM_INITIATORS-1:0];	
    wire    [NUM_TARGETS_WIDTH-1:0]          dst_intrtarget [NUM_INITIATORS-1:0];	
	wire    [NUM_INITIATORS-1:0]             dst_intravalid;
	wire    [NUM_INITIATORS-1:0]             dst_intraready;
	
	
	

    wire    [ADDR_WIDTH-1:0]		         outstnd_intrAddr     [NUM_INITIATORS-1:0];
    wire    [INITIATORID_WIDTH-1:0]	         outstnd_intrID       [NUM_INITIATORS-1:0];
    wire    [7:0]	                         outstnd_intralen     [NUM_INITIATORS-1:0];
    wire    [3-1:0]                          outstnd_intrasize    [NUM_INITIATORS-1:0];
    wire    [2-1:0]                          outstnd_intraburst   [NUM_INITIATORS-1:0];
    wire    [2-1:0]                          outstnd_intralock    [NUM_INITIATORS-1:0];
    wire    [4-1:0]                          outstnd_intracache   [NUM_INITIATORS-1:0];
    wire    [3-1:0]                          outstnd_intraprot    [NUM_INITIATORS-1:0];
    wire    [4-1:0]                          outstnd_intraqos     [NUM_INITIATORS-1:0];
    wire    [AUSER_WIDTH-1:0]                outstnd_intrauser 	  [NUM_INITIATORS-1:0];
    wire    [NUM_TARGETS_WIDTH-1:0]          outstnd_intrtarget   [NUM_INITIATORS-1:0];
	
    wire   [NUM_INITIATORS*ADDR_WIDTH -1:0]       intraddr   ;
    wire   [NUM_INITIATORS*ID_WIDTH-1:0]          intrid     ;
    wire   [NUM_INITIATORS*8-1:0]                 intralen   ;
    wire   [NUM_INITIATORS*3-1:0]                 intrasize  ;
    wire   [NUM_INITIATORS*2-1:0]                 intraburst ;
    wire   [NUM_INITIATORS*2-1:0]                 intralock  ;
    wire   [NUM_INITIATORS*4-1:0]                 intracache ;
    wire   [NUM_INITIATORS*3-1:0]                 intraprot  ;
    wire   [NUM_INITIATORS*4-1:0]                 intraqos   ;
    wire   [NUM_INITIATORS*AUSER_WIDTH-1:0]       intrauser  ;
    wire   [NUM_INITIATORS*NUM_TARGETS_WIDTH-1:0] intrtarget ;	
    wire   [NUM_INITIATORS-1:0]                   intraready ;	

	wire	[NUM_INITIATORS-1:0]		          initiatorValid	                     ;
	wire    [NUM_INITIATORS-1:0]                  initiatorready                         ;
	reg     [OUTSTNDNG_FIFO_WIDTH-1:0]            initiator_achnl    [NUM_INITIATORS-1:0];
	
	wire	[NUM_TARGETS_WIDTH-1:0]					transTargetID [NUM_INITIATORS-1:0];		// targetID for current transaction			
	wire	[INITIATORID_WIDTH-1:0]					transID [NUM_INITIATORS-1:0];		// targetID for current transaction			
	wire	[(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] 	dataTransID	 [NUM_INITIATORS-1:0];		// data transaction ID
	wire	[NUM_TARGETS_WIDTH-1:0]   		        datatrgt	 [NUM_INITIATORS-1:0];		// data transaction ID
	
	wire	[NUM_INITIATORS-1:0]			        validQual;					// bit-mask of valid requestors from initiators that are qualified (ie pass dependence check)
	wire	[NUM_INITIATORS-1:0]			        openTransInc;				// bit-mask to increment open transaction selected
	
	wire	[NUM_TARGETS_WIDTH-1:0]	                dst_initiatortarget [NUM_INITIATORS-1:0];		// target that requestors want to perform transaction with
	wire	[INITIATORID_WIDTH-1:0]	                dst_initiatortransid [NUM_INITIATORS-1:0];		// target that requestors want to perform transaction with

	wire	[NUM_INITIATORS-1:0]					availd_req;
	reg 	[NUM_INITIATORS-1:0]					availd_req_hold;
	wire	[NUM_INITIATORS-1:0]					requestorSel;
	wire	[NUM_INITIATORS_WIDTH-1:0]				requestorSelEnc;
	wire										    requestorSelValid;
	wire										    arbEnable;
	
	
    wire [NUM_INITIATORS-1:0]          outstnd_wrrdy;
    wire [NUM_INITIATORS-1:0]          outstnd_fifowr;
    wire [OUTSTNDNG_FIFO_WIDTH-1:0]    outstnd_fifowdata [NUM_INITIATORS-1:0];
	wire [NUM_INITIATORS-1:0]          outstnd_fifo_rvalid;
	reg  [NUM_INITIATORS-1:0]          outstnd_fiford;
	wire [OUTSTNDNG_FIFO_WIDTH-1:0]    outstnd_fifordata [NUM_INITIATORS-1:0];
	
  	wire [NUM_INITIATORS-1:0]          outstnd_fifo_empty;
   	wire [NUM_INITIATORS-1:0]          outstnd_fifo_full;
	wire [NUM_INITIATORS-1:0]          initiatorrdy;  
	wire [NUM_INITIATORS-1:0]          dst_addrrdy;  
	wire [NUM_TARGETS-2:0]             targetMatch       [NUM_INITIATORS-1:0];  
	wire [NUM_TARGETS-2:0]             dst_trgtmatch     [NUM_INITIATORS-1:0];  
    
    wire                               cfifo_rst;

    assign       cfifo_rst = (SYNC_RESET == 0) ? arst_sync : srst_sync; 	

	// Global outstanding transaction tracking for shared mode (CROSSBAR_MODE=0)
	// independent 2-bit counters for read and write paths. This centralizes the tracking
	// and eliminates race conditions that occurred with the previous combinational blocking.

	always@(*) begin 
	  outstnd_fiford = {NUM_INITIATORS{1'b0}};
	  if(arbEnable)
	    outstnd_fiford[requestorSelEnc] = 1'b1;
	end     
	
	
//================================================================================================
// Generare a caxi4interconnect_InitiatorControl for each initiator port
//================================================================================================

	
	
	genvar i;
	generate
		for (i=0; i< NUM_INITIATORS; i=i+1 )
			begin	: intrctrlBlk
	            
				caxi4interconnect_InitiatorControl # 
							(
								.NUM_TARGETS 		    ( NUM_TARGETS                                             ),
								.NUM_TARGETS_WIDTH 	    ( NUM_TARGETS_WIDTH                                       ),	
								.INITIATORID_WIDTH		( INITIATORID_WIDTH                                       ),
								.ADDR_WIDTH 		    ( ADDR_WIDTH                                              ),
								.NUM_THREADS		    ( NUM_THREADS[((i+1)*32)-1 : 32*i]                        ),
								.OPEN_TRANS_MAX		    ( OPEN_TRANS_MAX[((i+1)*32)-1 : 32*i]                     ),

								.UPPER_COMPARE_BIT	    ( UPPER_COMPARE_BIT                                       ), 
								.LOWER_COMPARE_BIT 	    ( LOWER_COMPARE_BIT                                       ),

								.SLOT_BASE_VEC 		    ( SLOT_BASE_VEC                                           ),
								.SLOT_MIN_VEC		    ( SLOT_MIN_VEC                                            ), 
								.SLOT_MAX_VEC		    ( SLOT_MAX_VEC                                            ),
								.CONNECTIVITY		    ( INITIATOR_CONNECTIVITY[ NUM_TARGETS*i +: NUM_TARGETS ]  ),
								.WR_MODULE              ( WR_MODULE                                               ),
								.ACHNL_WIDTH            ( ACHNL_WIDTH                                             ),
								.AUSER_WIDTH            ( AUSER_WIDTH                                             ),
								.TARGET_READ_INTERLEAVE ( TARGET_READ_INTERLEAVE                                  )
                            )
					intrctrl                            (
								.sysClk				    ( sysClk 			                                      ),
								.arst_sync			    ( arst_sync 		                                      ),			// active low reset synchronoise to RE AClk - asserted async.
								.srst_sync			    ( srst_sync 		                                      ),			// active low reset synchronoise to RE AClk - asserted async.
								.src_addr    			( initiatoraddr[i] 	                                      ),			// address to be decoded
								.dst_intravalid  		( dst_intravalid[i]                                       ),			// indicates Initiator has a valid address available
								.dst_intraready		    ( dst_addrrdy[i] 	                                      ),			// indicates Initiator has a valid address available
								.dst_intrid			    ( dst_intrid[i]		                                      ),			// unique ID per infrastructure Initiator port - includes infrastructure + ID
								.validQual			    ( validQual[i]		                                      ),			// Indictaes this target matched address
								.openTransInc		    ( openTransInc[i] 	                                      ),			// Increment openTransVec for thread matching currTransID
								.currTransTargetID	    ( transTargetID[i]	                                      ),			// targetID this  initiator is targetting
								.currTransID    	    ( transID[i]	                                          ),			// targetID this  initiator is targetting
								.currDataTransID	    ( dataTransID[i]	                                      ),			// current data transaction ID
								.currdatatrgt 	        ( datatrgt[i]	                                          ),			// current data transaction ID
								.openTransDec		    ( openTransDec[i] 	                                      ),
								.targetMatch		    ( targetMatch[i] 	                                      ),
								.dst_trgtmatch		    ( dst_trgtmatch[i] 	                                      )
					        ) ;	
							
                // Use localparam to avoid width overflow in parameter expression
                localparam [31:0] RS_ADDR_WIDTH = ADDR_WIDTH + NUM_TARGETS - 1;
                caxi4interconnect_RegisterSlice #
                (
                	.AWCHAN			     (1                          ),		
                	.ARCHAN			     (0                          ),		
                	.RCHAN			     (0                          ),		
                	.WCHAN			     (0                          ),		
                	.BCHAN			     (0                          ),									 
                	.ID_WIDTH   		 (INITIATORID_WIDTH          ),							 
                	.ADDR_WIDTH      	 (RS_ADDR_WIDTH              ),
                	.DATA_WIDTH 		 (0                          ),							 
                	.SUPPORT_USER_SIGNALS(0                          ),
                	.USER_WIDTH 		 (AUSER_WIDTH                ) 	
                ) addr_ctrl_rs
                (
                //=====================================  Global Signals   ========================================================================
                  .sysClk        (sysClk                             ),
                  .arst_sync     (arst_sync                          ),
                  .srst_sync     (srst_sync                          ),                  
                  .srcAWID       (initiatorid      [i]               ),
                  .srcAWADDR     ({targetMatch[i],initiatoraddr[i]}  ),
                  .srcAWLEN      (initiatoralen    [i]               ),
                  .srcAWSIZE     (initiatorasize   [i]               ),
                  .srcAWBURST    (initiatoraburst  [i]               ),
                  .srcAWLOCK     (initiatoralock   [i]               ),
                  .srcAWCACHE    (initiatoracache  [i]               ),
                  .srcAWPROT     (initiatoraprot   [i]               ),
                  .srcAWREGION   (4'd0                               ),
                  .srcAWQOS      (initiatoraqos    [i]               ),
                  .srcAWUSER     (initiatorauser   [i]               ),
                  .srcAWVALID    (initiatorValid   [i]               ),
                  .srcAWREADY    (INITIATOR_AREADY [i]               ),
																	 
                  .dstAWID       (dst_intrid       [i]               ),
                  .dstAWADDR     ({dst_trgtmatch[i],dst_intraddr[i]} ),
                  .dstAWLEN      (dst_intralen     [i]               ),
                  .dstAWSIZE     (dst_intrasize    [i]               ),
                  .dstAWBURST    (dst_intraburst   [i]               ),
                  .dstAWLOCK     (dst_intralock    [i]               ),
                  .dstAWCACHE    (dst_intracache   [i]               ),
                  .dstAWPROT     (dst_intraprot    [i]               ),
                  .dstAWREGION   (                                   ),
                  .dstAWQOS      (dst_intraqos     [i]               ),
                  .dstAWUSER     (dst_intrauser    [i]               ),
                  .dstAWVALID    (dst_intravalid   [i]               ),
                  .dstAWREADY    (dst_intraready   [i]               )		  
                );						
							
                assign  openTransInc[i]      =  dst_intravalid[i] & dst_addrrdy[i];			// set trans inc for initiator selected							
                assign 	initiatoraddr[i]	 = INITIATOR_AADDR[( (i+1)*ADDR_WIDTH)-1 :(i*ADDR_WIDTH) ];
				assign 	initiatorValid  [i]	 = INITIATOR_AVALID[i];
				assign 	initiatorid     [i]	 = { i[NUM_INITIATORS_WIDTH-1:0], INITIATOR_AID[( (i+1)*ID_WIDTH)-1 :(i*ID_WIDTH) ] };			// append infrastructure ID with ID from initiator
				assign  initiatoralen   [i]  = INITIATOR_ALEN[( (i+1)*8)-1 :(i*8) ];
 				assign  initiatorasize  [i]  = INITIATOR_ASIZE[( (i+1)*3)-1 :(i*3) ];
				assign  initiatoraburst [i]  = INITIATOR_ABURST[( (i+1)*2)-1 :(i*2) ];
				assign  initiatoralock  [i]  = INITIATOR_ALOCK[( (i+1)*2)-1 :(i*2) ];
				assign  initiatoracache [i]  = INITIATOR_ACACHE[( (i+1)*4)-1 :(i*4) ];
				assign  initiatoraprot  [i]  = INITIATOR_APROT[( (i+1)*3)-1 :(i*3) ];
				assign  initiatoraqos   [i]  = INITIATOR_AQOS[( (i+1)*4)-1 :(i*4) ];
				assign  initiatorauser  [i]  = INITIATOR_AUSER[( (i+1)*AUSER_WIDTH)-1 :(i*AUSER_WIDTH) ];
				
			    assign	dataTransID[i]	     = currDataTransID[(i+1)*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:i*(NUM_INITIATORS_WIDTH+ID_WIDTH)];		// dataTransID for this initiator
				assign	datatrgt[i]  	     = currdatatrgt[(i+1)*(NUM_TARGETS_WIDTH)-1:i*(NUM_TARGETS_WIDTH)];		
				
				
                if(NUM_THREADS[((i+1)*32)-1 : 32*i] == 1 && OPEN_TRANS_MAX[((i+1)*32)-1 : 32*i] == 1) begin //Bypass Address Register Slice and Outstanding FIFO
				
				  always@(posedge sysClk or negedge arst_sync)
				    if(~arst_sync | ~srst_sync)
					  availd_req_hold[i] <= 1'b0;
					else if(validQual[i])
					    availd_req_hold[i] <= 1'b1;
					else if(availd_req_hold[i] & outstnd_fiford[i])
					    availd_req_hold[i] <= 1'b0;				  
					  
				  // In shared mode (CROSSBAR_MODE=0), block new requests when transaction is outstanding
				  assign availd_req[i]                                        = (CROSSBAR_MODE == 0) ? 
				                                                                (validQual[i] | (availd_req_hold[i] & ~outstnd_fiford[i])):
				                                                                (validQual[i] | (availd_req_hold[i] & ~outstnd_fiford[i]));
                  assign intrtarget[i*NUM_TARGETS_WIDTH +: NUM_TARGETS_WIDTH] = transTargetID        [i]  ;
                  assign intraddr   [i*ADDR_WIDTH +: ADDR_WIDTH]              = dst_intraddr         [i]  ;
                  assign intrid     [i*ID_WIDTH +: ID_WIDTH]                  = transID[i][ID_WIDTH-1:0];  // Explicit bit-select
                  assign intralen   [i*8 +: 8]                                = dst_intralen         [i]  ;
                  assign intrasize  [i*3 +: 3]                                = dst_intrasize        [i]  ;
                  assign intraburst [i*2 +: 2]                                = dst_intraburst       [i]  ;
                  assign intralock  [i*2 +: 2]                                = dst_intralock        [i]  ;
                  assign intracache [i*4 +: 4]                                = dst_intracache       [i]  ;
                  assign intraprot  [i*3 +: 3]                                = dst_intraprot        [i]  ;
                  assign intraqos   [i*4 +: 4]                                = dst_intraqos         [i]  ;
                  assign intrauser  [i*AUSER_WIDTH +: AUSER_WIDTH]            = dst_intrauser        [i]  ;			

				  // In shared mode, block address acceptance when transaction is outstanding
				  assign dst_intraready[i]                                    = outstnd_fiford[i];
				  
				end else begin
				  
				  // pick out components of the individual initiator  
				  
				  always@(posedge sysClk or negedge arst_sync)
				    if(~arst_sync | ~srst_sync)
			          availd_req_hold[i] = 1'b0;
					else 
					  availd_req_hold[i] = 1'b0;
				  
				  // In shared mode, block address acceptance when transaction is outstanding
				  assign dst_intraready[i]        = outstnd_wrrdy[i] & dst_addrrdy[i];
				  assign dst_initiatortarget [i]  = transTargetID[i];
				  assign dst_initiatortransid[i]  = transID[i];
				  
				  always@(*)
				      initiator_achnl[i]    = {
				                                dst_initiatortarget  [i],
				                                dst_intraddr         [i],
				                                dst_initiatortransid [i],
				                                dst_intralen         [i],
				  							    dst_intrasize        [i],
				  							    dst_intraburst       [i],
				  							    dst_intralock        [i],
				  							    dst_intracache       [i],
				  							    dst_intraprot        [i],
				  							    dst_intraqos         [i],
				  							    dst_intrauser        [i]												 
				                              };
				  
				  	
				  assign outstnd_fifowr[i]    = validQual[i];
				  assign outstnd_fifowdata[i] = initiator_achnl[i];
				  	
				  // In shared mode (CROSSBAR_MODE=0), block new requests when transaction is outstanding
                  assign availd_req[i]        = outstnd_fifo_rvalid[i];
				  
				  
                  assign outstnd_intrtarget [i] = outstnd_fifordata[i][AUSER_WIDTH+4+3+4+2+2+3+8+INITIATORID_WIDTH+ADDR_WIDTH+NUM_TARGETS_WIDTH-1:AUSER_WIDTH+4+3+4+2+2+3+8+INITIATORID_WIDTH+ADDR_WIDTH];
				  assign outstnd_intrAddr   [i] = outstnd_fifordata[i][AUSER_WIDTH+4+3+4+2+2+3+8+INITIATORID_WIDTH+ADDR_WIDTH-1:AUSER_WIDTH+4+3+4+2+2+3+8+INITIATORID_WIDTH];
				  assign outstnd_intrID     [i] = outstnd_fifordata[i][AUSER_WIDTH+4+3+4+2+2+3+8+INITIATORID_WIDTH-1:AUSER_WIDTH+4+3+4+2+2+3+8];
				  assign outstnd_intralen   [i] = outstnd_fifordata[i][AUSER_WIDTH+4+3+4+2+2+3+8-1:AUSER_WIDTH+4+3+4+2+2+3];
				  assign outstnd_intrasize  [i] = outstnd_fifordata[i][AUSER_WIDTH+4+3+4+2+2+3-1:AUSER_WIDTH+4+3+4+2+2];
				  assign outstnd_intraburst [i] = outstnd_fifordata[i][AUSER_WIDTH+4+3+4+2+2-1:AUSER_WIDTH+4+3+4+2];
				  assign outstnd_intralock  [i] = outstnd_fifordata[i][AUSER_WIDTH+4+3+4+2-1:AUSER_WIDTH+4+3+4];
				  assign outstnd_intracache [i] = outstnd_fifordata[i][AUSER_WIDTH+4+3+4-1:AUSER_WIDTH+4+3];
				  assign outstnd_intraprot  [i] = outstnd_fifordata[i][AUSER_WIDTH+4+3-1:AUSER_WIDTH+4];
				  assign outstnd_intraqos   [i] = outstnd_fifordata[i][AUSER_WIDTH+4-1:AUSER_WIDTH];
				  assign outstnd_intrauser  [i] = outstnd_fifordata[i][AUSER_WIDTH-1:0];					
				  		
				  assign intrtarget [i*NUM_TARGETS_WIDTH +: NUM_TARGETS_WIDTH]  = outstnd_intrtarget [i];
				  assign intraddr   [i*ADDR_WIDTH +: ADDR_WIDTH]                = outstnd_intrAddr   [i];
				  assign intrid     [i*ID_WIDTH +: ID_WIDTH]                    = outstnd_intrID     [i][ID_WIDTH-1:0];
				  assign intralen   [i*8 +: 8]                                  = outstnd_intralen   [i];
				  assign intrasize  [i*3 +: 3]                                  = outstnd_intrasize  [i];
				  assign intraburst [i*2 +: 2]                                  = outstnd_intraburst [i];
				  assign intralock  [i*2 +: 2]                                  = outstnd_intralock  [i];
				  assign intracache [i*4 +: 4]                                  = outstnd_intracache [i];
				  assign intraprot  [i*3 +: 3]                                  = outstnd_intraprot  [i];
				  assign intraqos   [i*4 +: 4]                                  = outstnd_intraqos   [i];
				  assign intrauser  [i*AUSER_WIDTH +: AUSER_WIDTH]              = outstnd_intrauser  [i];
				  	
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
                         .WFIFO_DEPTH        (NUM_THREADS[i*32 +:32] * OPEN_TRANS_MAX[i*32 +: 32] < 5   ? 8   : 
	                                          NUM_THREADS[i*32 +:32] * OPEN_TRANS_MAX[i*32 +: 32] < 9   ? 16  :
                                              NUM_THREADS[i*32 +:32] * OPEN_TRANS_MAX[i*32 +: 32] < 17  ? 32  :  													   
									          64),
                         .RFIFO_DEPTH        (NUM_THREADS[i*32 +:32] * OPEN_TRANS_MAX[i*32 +: 32] < 5   ? 8   : 
	                                          NUM_THREADS[i*32 +:32] * OPEN_TRANS_MAX[i*32 +: 32] < 9   ? 16  :
                                              NUM_THREADS[i*32 +:32] * OPEN_TRANS_MAX[i*32 +: 32] < 17  ? 32  :  													   
									          64),
                         .AXIS_TTDATA_WIDTH  (OUTSTNDNG_FIFO_WIDTH), // Bytes
                         .AXIS_ITDATA_WIDTH  (OUTSTNDNG_FIFO_WIDTH),  // Bytes
                         .AXIS_TTID_WIDTH    (1), // Bits
                         .AXIS_ITID_WIDTH    (1), // Bits
                         .AXIS_TTDEST_WIDTH  (1), // Bits
                         .AXIS_ITDEST_WIDTH  (1), // Bits
                         .AXIS_TTUSER_WIDTH  (1), // Bits
                         .AXIS_ITUSER_WIDTH  (1), // Bits
                         .ENABLE_AFULL       (1),
                         .AFULL_THR          (4),
                         .ENABLE_TSTRB       (0),
                         .ENABLE_TKEEP       (0),
                         .ENABLE_TLAST       (0),
                         .ENABLE_TUSER       (0),
                         .ENABLE_TDEST       (0),
                         .ENABLE_TID         (0),
                         .EOP_OFFSET         (0)
                      ) outstndng_addr_fwftFif
                      (
                         .AXI4S_ACLK         (sysClk),
                         .AXI4S_IACLK        (sysClk),
                         .AXI4S_TACLK        (sysClk),
                         .AXI4S_ARESETN      (cfifo_rst),
                         .AXI4S_IARESETN     (cfifo_rst),
                         .AXI4S_TARESETN     (cfifo_rst),
				  
                         .AXI4S_ITREADY      (outstnd_fiford[i]),
                         .AXI4S_ITVALID      (outstnd_fifo_rvalid[i]),
                         .AXI4S_ITDATA       (outstnd_fifordata[i]),
                         .AXI4S_TTVALID      (outstnd_fifowr[i]),
                         .AXI4S_TTREADY      (outstnd_wrrdy[i]),
                         .AXI4S_TTDATA       (outstnd_fifowdata[i])
				  
                      );                   
				  
				  
                  end else begin 				
				  
				    assign outstnd_fifo_rvalid[i] = ~outstnd_fifo_empty[i];
				    assign outstnd_wrrdy[i]       = ~outstnd_fifo_full[i];
				    //====================================================================================================
				    // caxi4interconnect_FIFO to hold open write transactions - pushed on Address write cycle and popped on write data
				    // cycle.
				    //=====================================================================================================
				    caxi4interconnect_FifoDualPort #	(	.HI_FREQ( 1'b0 ),
				    					.NEAR_FULL ( 'd4 ),
				    					.FIFO_AWIDTH( NUM_THREADS[i*32 +:32] * OPEN_TRANS_MAX[i*32 +: 32] < 5   ? 3   : 
	                                                  NUM_THREADS[i*32 +:32] * OPEN_TRANS_MAX[i*32 +: 32] < 9   ? 4  :
                                                      NUM_THREADS[i*32 +:32] * OPEN_TRANS_MAX[i*32 +: 32] < 17  ? 5  :  													   
									                  6 
													),
				    					//.FIFO_WIDTH( NUM_INITIATORS_WIDTH )
				    					.FIFO_WIDTH( OUTSTNDNG_FIFO_WIDTH)
				    				) wrFif	(
				    					.HCLK(	sysClk ),
				    					.fifo_areset( arst_sync ),
				    					.fifo_sreset( srst_sync ),
				    
				    					// Write Port
				    					
				    					.fifoWrite (outstnd_fifowr[i] ),
				    					.fifoWrData(outstnd_fifowdata[i] ),	// pick out infrastructure ID
				    
				    					// Read Port
				    					.fifoRead(outstnd_fiford[i] ),
				    					.fifoRdData(outstnd_fifordata[i]),
				    
				    					// Status bits
				    					.fifoEmpty ( outstnd_fifo_empty[i] ) ,
				    					.fifoOneAvail(  ),
				    					.fifoRdValid( ),		// indicates read data is valid - handles clocked rd data
				    					.fifoFull( ),
				    					.fifoNearFull(outstnd_fifo_full[i]),		// use nearly full to allow cover race between "full" and arb
				    					.fifoOverRunErr(  ),
				    					.fifoUnderRunErr( )				   
				    			);
				    
                  end
				end 
			end
	endgenerate


	generate
		if (NUM_INITIATORS == 1)			// no need to arb - always initiator0
			begin	: noArb
				assign requestorSel = 1;	
				assign requestorSelEnc = 0;
				assign requestorSelValid = availd_req;
			end
		else
			begin	: rrArb
				//===========================================================================================================
				// Slot Aribrator - performs a round-robin arbitration among "qualified" valid requestors for ownership
				// of address bus.
				//============================================================================================================
				caxi4interconnect_RoundRobinArb #( .N( NUM_INITIATORS ), .N_WIDTH( NUM_INITIATORS_WIDTH ), .HI_FREQ( HI_FREQ ))
					rrArb 	(
								// global signals
								.sysClk		( sysClk ),
								.arst_sync	( arst_sync ),
								.srst_sync	( srst_sync ),
	
								.requestor		( availd_req ),
								.arbEnable		( arbEnable ),				// arb again when selected initiator asserts increment (only 1 will)						
								.grant			( requestorSel 	 ),			// bit per initiator - 1-bit should only be set
								.grantEnc		( requestorSelEnc 	),		// encoded version of requestorSel
								.grantValid		( requestorSelValid )		// asserted when grant is valid
				
							);
		
			end
	endgenerate
	
	
	//===========================================================================================================
	// Target Mux and Control - performs the MUX of "granted" requestor address vector to target and
	// controls response from target. Conditionally generate caxi4interconnect_TargetMuxController based on NUM_INITIATORS_WIDTH
	// to get aroound "elaboration" issues
	//============================================================================================================
	
	caxi4interconnect_TargetMuxController # 
		(
			.NUM_INITIATORS				( NUM_INITIATORS ), 				// defines number of initiators
			.NUM_INITIATORS_WIDTH		( NUM_INITIATORS_WIDTH ), 			// defines number of bits to encode initiator number			
			.NUM_TARGETS     			( NUM_TARGETS ), 				// defines number of targets
			.NUM_TARGETS_WIDTH 			( NUM_TARGETS_WIDTH ),  		// defines number of bits to encoode target number
			.ID_WIDTH   				( ID_WIDTH ), 
			.ADDR_WIDTH      			( ADDR_WIDTH ),		
			.SUPPORT_USER_SIGNALS 		( SUPPORT_USER_SIGNALS ),
			.AUSER_WIDTH 				( AUSER_WIDTH   ),
			.HI_FREQ 					( HI_FREQ ),
			.MAX_TRANS 					( MAX_TRANS ),
			.CROSSBAR_MODE 				( CROSSBAR_MODE )
   
		)
	trgmx	(
			// Global Signals
			.sysClk 	        ( sysClk            ),
			.arst_sync	        ( arst_sync         ),					// active low reset synchronoise to RE AClk - asserted async.
			.srst_sync	        ( srst_sync         ),					// active low reset synchronoise to RE AClk - asserted async.

			// Slot Arbitrator
			.requestorSelValid  ( requestorSelValid ),	// indicates that slot arb has selected valid requestor to drive to Target
			.requestorSelEnc    ( requestorSelEnc 	),		// encoded version of requestorSel
			.dest_targ	        ( intrtarget 		),		// target that requestors wants to perform transaction with
			.arbEnable		    ( arbEnable			),
		
			//====================== Initiator Ports  ================================================//
			.INITIATOR_AID		( intrid     ),
			.INITIATOR_AADDR	( intraddr   ),
		
			.INITIATOR_ALEN	    ( intralen    ),
			.INITIATOR_ASIZE	( intrasize   ),
			.INITIATOR_ABURST	( intraburst  ),
			.INITIATOR_ALOCK	( intralock   ),
			.INITIATOR_ACACHE	( intracache  ),
			.INITIATOR_APROT	( intraprot   ),
			.INITIATOR_AQOS	    ( intraqos    ),
			.INITIATOR_AUSER	( intrauser   ),
			.INITIATOR_AREADY	( intraready  ),
   
			//====================== Target Ports  ================================================//
			.TARGET_AID		    ( TARGET_AID        ),
			.TARGET_AADDR	    ( TARGET_AADDR      ),
			.TARGET_ALEN		( TARGET_ALEN       ),
			.TARGET_ASIZE	    ( TARGET_ASIZE      ),
			.TARGET_ABURST	    ( TARGET_ABURST     ),
			.TARGET_ALOCK	    ( TARGET_ALOCK      ),
			.TARGET_ACACHE	    ( TARGET_ACACHE     ),
			.TARGET_APROT	    ( TARGET_APROT      ),
			.TARGET_AQOS		( TARGET_AQOS       ),
			.TARGET_AUSER	    ( TARGET_AUSER      ),
			.TARGET_AVALID	    ( TARGET_AVALID     ),
			.TARGET_AREADY	    ( TARGET_AREADY     ),
			
			//====================== DataController Ports  ================================================//
			.dataFifoWr         ( dataFifoWr        ),
			.srcPort            ( srcPort           ),
			.destPort           ( destPort          ),
			.target_done        ( target_done       )
			
		); 


endmodule // caxi4interconnect_AddressController.v
