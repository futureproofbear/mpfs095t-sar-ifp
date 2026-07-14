`timescale 1ns / 1ns
///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: MICROSEMI
//
// IP Core: COREAXI4INTERCONNECT
//
//  Description  : The AMBA AXI4 Interconnect core connects one or more AXI memory-mapped initiator devices to one or
//                 more memory-mapped target devices. The AMBA AXI protocol supports high-performance, high-frequency
//                 system designs.
//
//     Abstract  : This module "pushes" open transactions - counts open transactions and records targetID per
//                 thread which are open. It "pops" a transaction when it has completed as indicated by
//                 DataController.
//
//  COPYRIGHT 2017 BY MICROSEMI 
//  THE INFORMATION CONTAINED IN THIS DOCUMENT IS SUBJECT TO LICENSING RESTRICTIONS 
//  FROM MICROSEMI CORP.  IF YOU ARE NOT IN POSSESSION OF WRITTEN AUTHORIZATION FROM 
//  MICROSEMI FOR USE OF THIS FILE, THEN THE FILE SHOULD BE IMMEDIATELY DESTROYED AND 
//  NO BACK-UP OF THE FILE SHOULD BE MADE. 
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

module caxi4interconnect_TransactionController #
(
//=================================================================================================
// Parameter Declarations
//=================================================================================================

	parameter NUM_TARGETS_WIDTH 	= 2,		// defines number of bits to encoode target number

	parameter INITIATORID_WIDTH		= 4,		// defines number of bits to in initiatorID - includes Infrastructure ID + requestor ID
	
	parameter NUM_THREADS			= 1,		// defined number of indpendent threads per initiator supported 
	
	parameter OPEN_TRANS_MAX		= 3,		// max number of outstanding transactions 

	parameter  WR_MODULE            = 1

)
(
//================================================================================================
// I/O Declarations
//================================================================================================

	input								sysClk,
	input								arst_sync,
	input								srst_sync,
	
	//========= Dependancy Checker  Port ======================//
	
	input	[NUM_TARGETS_WIDTH-1:0] 	currTransTargetID,					// matched targetID
	input	[INITIATORID_WIDTH-1:0]		currTransID,						// ID for current transaction

	output	reg                			threadValid,						// indicates matched currTransID and threadCount and threadtargetID valid

	//========= caxi4interconnect_TargetMuxController Port ======================//
	input								openTransInc,						// Increment openTransVec for thread matching currTransID

	//========= DataControl Port =============================//
	input	[INITIATORID_WIDTH-1:0]		currDataTransID,					// current data transaction ID
	input	[NUM_TARGETS_WIDTH-1:0]		currdatatrgt,					// current data transaction ID
	input								openTransDec,						// indicates thread matching currDataTransID to be decremented

  // Query Interface
    input  wire                         query_valid,      // Query for specific transaction
    input  wire [NUM_TARGETS_WIDTH-1:0] query_target_id,  // Query target ID
    input  wire [INITIATORID_WIDTH-1:0] query_trans_id  // Query target ID
);
    // =========================================================================
    // Internal Storage
    // =========================================================================
    
	localparam integer NUM_THREADS_WIDTH =  (NUM_THREADS == 1) ? 1 : $clog2(NUM_THREADS);
	localparam integer OPEN_TRANS_WIDTH  =  (OPEN_TRANS_MAX == 1) ? 1 : $clog2(OPEN_TRANS_MAX);
    
    
    // =========================================================================
    // Thread Matching Logic
    // =========================================================================    
    
    genvar k;
    generate
	  if(NUM_THREADS == 1 && OPEN_TRANS_MAX == 1) begin 
	  
        always@(posedge sysClk or negedge arst_sync)
          if(~arst_sync | ~srst_sync)
		    threadValid <= 1'b1;
		  else if(openTransInc ^ openTransDec) begin 
		    if(openTransInc)
			  threadValid <= 1'b0;
			else 
			  threadValid <= 1'b1;			  
		  end 
		    
	  end else begin 
	  
        wire [NUM_THREADS-1:0]         complete_match;      // Complete match
        wire [NUM_THREADS-1:0]         query_match;         // Complete match
        wire [NUM_THREADS-1:0]         trans_id_match;      // trans id match
	    
	    reg                            match_found;
	    reg  [NUM_THREADS_WIDTH-1:0]   match_idx;
        // Find free thread slot
        reg  [NUM_THREADS_WIDTH-1:0]   free_idx;
        reg                            free_found;	
	    
	    reg  [NUM_THREADS-1:0]         thread_avail;
	    
	    
		
        // Thread storage arrays
        reg [INITIATORID_WIDTH-1:0]    thread_trans_id      [0:NUM_THREADS-1];
        reg [NUM_TARGETS_WIDTH-1:0]    thread_target_id     [0:NUM_THREADS-1];
        reg [OPEN_TRANS_WIDTH:0]       active_thread_count  [0:NUM_THREADS-1];
        reg [NUM_THREADS-1:0]          active_thread;     // Which threads are active	    
	    
	    integer                        mh_idx, f_thrd_idx, j, thrd_idx;	
	  
        for (k = 0; k < NUM_THREADS; k = k + 1) begin : gen_match
          // Combined Read/Write tracking

          assign complete_match[k]        = active_thread[k]                        && 
                                            (thread_trans_id[k] == currDataTransID) && 
										    (thread_target_id[k] == currdatatrgt);        
									      
          
		  //Find the new request is for the existing target by comparing the target id with the existing thread
		  assign query_match[k]           = query_valid                             && 
		                                    active_thread[k]                        && 										
                                            (thread_trans_id[k] == query_trans_id)  &&  
                                            (thread_target_id[k] == query_target_id);                                              

		  //Find the new request is for the existing target by comparing the target id with the existing thread
		  assign trans_id_match[k]        = active_thread[k]                        && 										
                                            (thread_trans_id[k] == query_trans_id);  
                                            

        end
		
        //Find the new request is for the existing thread by comparing the target id and target number with the existing thread
	    
        always @(*) begin
            match_found = 1'b0;
            match_idx = 0;
            for (mh_idx = 0; mh_idx < NUM_THREADS; mh_idx = mh_idx + 1) begin
                if (active_thread[mh_idx] && thread_trans_id[mh_idx] == query_trans_id && thread_target_id[mh_idx] == query_target_id) begin
                    match_found = 1'b1;
                    match_idx = mh_idx[NUM_TARGETS_WIDTH-1:0];
                end
            end
        end	
	    
        //Find the free thread
	    
        always @(*) begin
            free_found = 1'b0;
            free_idx = 0;
            for (f_thrd_idx = NUM_THREADS-1; f_thrd_idx >= 0; f_thrd_idx = f_thrd_idx - 1) begin
                if (!active_thread[f_thrd_idx]) begin
                    free_found = 1'b1;
                    free_idx = f_thrd_idx[NUM_TARGETS_WIDTH-1:0];
                end
            end
        end	
    	  
	
        always@(posedge sysClk or negedge arst_sync)
          if(~arst_sync | ~srst_sync) begin 
            for (j = 0; j < NUM_THREADS; j = j + 1) begin
              active_thread[j]          <= 0;
              active_thread_count[j]    <= 0;
              thread_trans_id[j]        <= 0;
              thread_target_id[j]       <= 0;
	        end 
	      end else begin 
	        if(openTransInc) begin 
	    	  if(match_found & ~(openTransDec & complete_match[match_idx])) begin //If new request is for the existing thread then increment thread count 
	    	    active_thread_count[match_idx] <= active_thread_count[match_idx] + 1'b1;
	    	  end else if(free_found) begin //Create a new thread if new request received is not matching with the existing thread target id
	    	    active_thread[free_idx]                      <= 1'b1;
	    	    active_thread_count[free_idx]                <= 1;
	    		thread_trans_id[free_idx]                    <= query_trans_id;
	    		thread_target_id[free_idx]                   <= query_target_id;
	    	  end 
	    	end 
	    	if(openTransDec) begin //Decrement the thread count when response is received 
              for (j = 0; j < NUM_THREADS; j = j + 1) begin 
	    	    if(complete_match[j] & ~(openTransInc & match_found & (match_idx == j))) begin 
	    		  active_thread_count[j] <= active_thread_count[j] - 1'b1;
	    		  if(active_thread_count[j] == 1) //Clear the existing thread. 
	    		    active_thread[j] <= 1'b0;
	    		end 
	    	  end 
	    	end 
	      end 	
        // =========================================================================
        // Output Assignments
        // =========================================================================    
	    //Except the new transactions when below two conditions are satisfied 
	    //(1) When thread count is not equal to maximum supported outstanding xfer
	    //(2) New request doesn't match with the active thread trans id and target id
	    always@(*) begin 
	      for (thrd_idx = 0; thrd_idx < NUM_THREADS; thrd_idx = thrd_idx + 1) begin 
            if(
	            (active_thread_count[thrd_idx] != OPEN_TRANS_MAX) 
	            && (query_match[thrd_idx] | 
	    		   (~active_thread[thrd_idx] & ~(| trans_id_match)))
	          )
	          thread_avail[thrd_idx]   = 1'b1;
	        else 
	          thread_avail[thrd_idx]   = 1'b0;		
	      end
        end 	  
	
        always@(*)  
          threadValid = (| thread_avail); 		
	  end 
    endgenerate    	
endmodule
										
