module caxi4interconnect_TargetMuxController #(
    parameter integer NUM_INITIATORS = 4,
    parameter integer NUM_INITIATORS_WIDTH = 2,
    parameter integer NUM_TARGETS = 4,
    parameter integer NUM_TARGETS_WIDTH = 2,
    parameter integer ID_WIDTH = 1,
    parameter integer ADDR_WIDTH = 32,
    parameter integer SUPPORT_USER_SIGNALS = 0,
    parameter integer AUSER_WIDTH = 1,
    parameter integer HI_FREQ = 1,
    parameter integer MAX_TRANS = 1,
    parameter integer CROSSBAR_MODE = 1
	
)(
    input  wire sysClk,
    input  wire arst_sync, // active low async reset
    input  wire srst_sync, // active low async reset

    input  wire requestorSelValid,
    input  wire [NUM_INITIATORS_WIDTH-1:0] requestorSelEnc,
    input  wire [NUM_INITIATORS*NUM_TARGETS_WIDTH-1:0] dest_targ,
    output wire arbEnable,

    input  wire [NUM_INITIATORS*ID_WIDTH-1:0] INITIATOR_AID,
    input  wire [NUM_INITIATORS*ADDR_WIDTH-1:0] INITIATOR_AADDR,
    input  wire [NUM_INITIATORS*8-1:0] INITIATOR_ALEN,
    input  wire [NUM_INITIATORS*3-1:0] INITIATOR_ASIZE,
    input  wire [NUM_INITIATORS*2-1:0] INITIATOR_ABURST,
    input  wire [NUM_INITIATORS*2-1:0] INITIATOR_ALOCK,
    input  wire [NUM_INITIATORS*4-1:0] INITIATOR_ACACHE,
    input  wire [NUM_INITIATORS*3-1:0] INITIATOR_APROT,
    input  wire [NUM_INITIATORS*4-1:0] INITIATOR_AQOS,
    input  wire [NUM_INITIATORS*AUSER_WIDTH-1:0] INITIATOR_AUSER,
    output reg  [NUM_INITIATORS-1:0] INITIATOR_AREADY,

    output reg  [NUM_TARGETS-1:0] TARGET_AVALID,
    input  wire [NUM_TARGETS-1:0] TARGET_AREADY,
    output reg  [NUM_TARGETS*8-1:0] TARGET_ALEN,
    output reg  [NUM_TARGETS*(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] TARGET_AID,
    output reg  [(NUM_TARGETS-1)*ADDR_WIDTH-1:0] TARGET_AADDR,
    output reg  [(NUM_TARGETS-1)*3-1:0] TARGET_ASIZE,
    output reg  [(NUM_TARGETS-1)*2-1:0] TARGET_ABURST,
    output reg  [(NUM_TARGETS-1)*2-1:0] TARGET_ALOCK,
    output reg  [(NUM_TARGETS-1)*4-1:0] TARGET_ACACHE,
    output reg  [(NUM_TARGETS-1)*3-1:0] TARGET_APROT,
    output reg  [(NUM_TARGETS-1)*4-1:0] TARGET_AQOS,
    output reg  [(NUM_TARGETS-1)*AUSER_WIDTH-1:0] TARGET_AUSER,

    output reg dataFifoWr,
    output reg [(NUM_INITIATORS_WIDTH+ID_WIDTH)-1:0] srcPort,
    output reg [NUM_TARGETS_WIDTH-1:0] destPort,
	
	input  wire [NUM_TARGETS-1:0]     target_done
);

    localparam INITIATORID_WIDTH		= ( NUM_INITIATORS_WIDTH + ID_WIDTH );
    localparam MAX_TRANS_WIDTH		    = (( $clog2(MAX_TRANS)) < 2) ? 2 : $clog2(MAX_TRANS);
    // Internal signals
    reg [NUM_INITIATORS_WIDTH+ID_WIDTH-1:0] muxed_AID;
    reg [ADDR_WIDTH-1:0] muxed_AADDR;
    reg [7:0] muxed_ALEN;
    reg [2:0] muxed_ASIZE;
    reg [1:0] muxed_ABURST;
    reg [1:0] muxed_ALOCK;
    reg [3:0] muxed_ACACHE;
    reg [2:0] muxed_APROT;
    reg [3:0] muxed_AQOS;
    reg [AUSER_WIDTH-1:0] muxed_AUSER;
    reg [NUM_TARGETS_WIDTH-1:0] muxed_target;
    reg [NUM_TARGETS_WIDTH-1:0] targetdest;
	
	reg [INITIATORID_WIDTH-1:0]       			targetAID;			// append infrastructure ID to AID from initiator
	reg [ADDR_WIDTH-1:0]          				targetAADDR;
	reg [8-1:0]                         		targetALEN;
	reg [3-1:0]                         		targetASIZE;
	reg [2-1:0]                         		targetABURST;
	reg [2-1:0]                         		targetALOCK;
	reg [4-1:0]                         		targetACACHE;
	reg [3-1:0]                         		targetAPROT;
	reg [4-1:0]                         		targetAQOS;
	reg [AUSER_WIDTH-1:0] 	       	  			targetAUSER;
	reg [NUM_TARGETS-1:0]                       targetAVALID;
	

    // Per-target busy and owner tracking
    reg [NUM_TARGETS-1:0] target_busy;
    reg [NUM_TARGETS*NUM_INITIATORS_WIDTH-1:0] target_owner; // packed array
	reg [NUM_TARGETS-1:0] target_busy_en;
	reg [MAX_TRANS_WIDTH:0] target_busy_cnt [0:NUM_TARGETS-1];

    integer t;

    // Mux logic for selected initiator
    always @(*) begin
        muxed_AID    = {requestorSelEnc, INITIATOR_AID[requestorSelEnc*ID_WIDTH +: ID_WIDTH]};
        muxed_AADDR  = INITIATOR_AADDR[requestorSelEnc*ADDR_WIDTH +: ADDR_WIDTH];
        muxed_ALEN   = INITIATOR_ALEN[requestorSelEnc*8 +: 8];
        muxed_ASIZE  = INITIATOR_ASIZE[requestorSelEnc*3 +: 3];
        muxed_ABURST = INITIATOR_ABURST[requestorSelEnc*2 +: 2];
        muxed_ALOCK  = INITIATOR_ALOCK[requestorSelEnc*2 +: 2];
        muxed_ACACHE = INITIATOR_ACACHE[requestorSelEnc*4 +: 4];
        muxed_APROT  = INITIATOR_APROT[requestorSelEnc*3 +: 3];
        muxed_AQOS   = INITIATOR_AQOS[requestorSelEnc*4 +: 4];
        muxed_AUSER  = INITIATOR_AUSER[requestorSelEnc*AUSER_WIDTH +: AUSER_WIDTH];
        muxed_target = dest_targ[requestorSelEnc*NUM_TARGETS_WIDTH +: NUM_TARGETS_WIDTH];
    end

generate 
  if(CROSSBAR_MODE == 1) begin 
    always @(posedge sysClk or negedge arst_sync)
      begin
	    if(~arst_sync | ~srst_sync)
	    	begin
	    		targetAID	    <= 0;
	    		targetAADDR 	<= 0;
	    		targetALEN  	<= 0;
	    		targetASIZE 	<= 0;
	    		targetABURST	<= 0;
	    		targetALOCK	    <= 0;
	    		targetACACHE	<= 0;
	    		targetAPROT	    <= 0;
	    		targetAQOS	    <= 0;
	    		targetAUSER	    <= 0;	    
	    		targetAVALID	<= 0;
	    		targetdest   	<= 0;
	    	end
	    else
	    	begin
	    
	    		targetAID	    <= muxed_AID;
	    		targetAADDR 	<= muxed_AADDR;
	    		targetALEN  	<= muxed_ALEN;
	    		targetASIZE 	<= muxed_ASIZE;
	    		targetABURST	<= muxed_ABURST;
	    		targetALOCK	    <= muxed_ALOCK;
	    		targetACACHE	<= muxed_ACACHE;
	    		targetAPROT	    <= muxed_APROT;
	    		targetAQOS	    <= muxed_AQOS;
	    		targetAUSER	    <= muxed_AUSER;
	    		targetdest	    <= muxed_target;
	    
	    		targetAVALID	<= 0;		// initialise to 0 to indicate no transaction
                if (requestorSelValid && ~arbEnable && (!target_busy[muxed_target] ||
                   (target_busy[muxed_target] && target_owner[muxed_target*NUM_INITIATORS_WIDTH +: NUM_INITIATORS_WIDTH] == requestorSelEnc)))	    
	    		    begin
	    			  targetAVALID[ muxed_target ] <= 1'b1;  // set target target valid bit  
	    			end
	    	end
      end	
	  
	end else begin 
	
	reg cb_shared_busy; 

    always @(posedge sysClk or negedge arst_sync)
      begin
	    if(~arst_sync | ~srst_sync)
		  cb_shared_busy <= 1'b0;
		else if(| target_done)
		  cb_shared_busy <= 1'b0;
		else if(| target_busy_en)
		  cb_shared_busy <= 1'b1;
	  end 
	
    always @(posedge sysClk or negedge arst_sync)
      begin
	    if(~arst_sync | ~srst_sync)
	    	begin
	    		targetAID	    <= 0;
	    		targetAADDR 	<= 0;
	    		targetALEN  	<= 0;
	    		targetASIZE 	<= 0;
	    		targetABURST	<= 0;
	    		targetALOCK	    <= 0;
	    		targetACACHE	<= 0;
	    		targetAPROT	    <= 0;
	    		targetAQOS	    <= 0;
	    		targetAUSER	    <= 0;	    
	    		targetAVALID	<= 0;
	    		targetdest   	<= 0;
	    	end
	    else
	    	begin
	    
	    		targetAID	    <= muxed_AID;
	    		targetAADDR 	<= muxed_AADDR;
	    		targetALEN  	<= muxed_ALEN;
	    		targetASIZE 	<= muxed_ASIZE;
	    		targetABURST	<= muxed_ABURST;
	    		targetALOCK	    <= muxed_ALOCK;
	    		targetACACHE	<= muxed_ACACHE;
	    		targetAPROT	    <= muxed_APROT;
	    		targetAQOS	    <= muxed_AQOS;
	    		targetAUSER	    <= muxed_AUSER;
	    		targetdest	    <= muxed_target;
	    
	    		targetAVALID	<= 0;		// initialise to 0 to indicate no transaction
                if (requestorSelValid && ~arbEnable && ~cb_shared_busy)	    
	    		    begin
	    			  targetAVALID[ muxed_target ] <= 1'b1;  // set target target valid bit  
	    			end
	    	end
      end	
	
	end 
endgenerate
	  
      genvar i;
      generate
      
      	// Route signals that go to external ports
      	for (i=0; i< NUM_TARGETS-1; i=i+1 )
      		begin
			  always@(*) begin 
      			TARGET_AID[(i+1)*INITIATORID_WIDTH-1:i*INITIATORID_WIDTH]	= targetAID;
      			TARGET_AADDR[ (i+1)*ADDR_WIDTH-1:i*ADDR_WIDTH] 		        = targetAADDR;
      			TARGET_ALEN[(i+1)*8-1:i*8]               				    = targetALEN;
      			TARGET_ASIZE[(i+1)*3-1:i*3]                      		    = targetASIZE;
      			TARGET_ABURST[(i+1)*2-1:i*2]                  		        = targetABURST;
      			TARGET_ALOCK[(i+1)*2-1:i*2]                       	        = targetALOCK;
      			TARGET_ACACHE[(i+1)*4-1:i*4]                      	        = targetACACHE;
      			TARGET_APROT[(i+1)*3-1:i*3]                       	        = targetAPROT;
      			TARGET_AQOS[(i+1)*4-1:i*4]                        	        = targetAQOS;
      			TARGET_AUSER[(i+1)*AUSER_WIDTH-1:i*AUSER_WIDTH]   	        = targetAUSER;
			  end 
      		end      		
      endgenerate	  

    // Assign TARGET_AID and TARGET_ALEN for DERR target (last index)
    // Other signals (AADDR, ASIZE, etc.) are not routed to DERR target
    always @(*) begin
        TARGET_AID[NUM_TARGETS*INITIATORID_WIDTH-1:(NUM_TARGETS-1)*INITIATORID_WIDTH] = targetAID;
        TARGET_ALEN[NUM_TARGETS*8-1:(NUM_TARGETS-1)*8]                                = targetALEN;
    end

    always@(*) TARGET_AVALID	= targetAVALID;

    always @(*) begin     
      target_busy_en = TARGET_AVALID & TARGET_AREADY; 
    end

    always @(posedge sysClk or negedge arst_sync) begin
        if (!arst_sync || !srst_sync) begin
		  for (t = 0; t < NUM_TARGETS; t = t + 1) begin
            target_busy_cnt[t] <= 0;
		  end 
        end else begin
            for (t = 0; t < NUM_TARGETS; t = t + 1) begin
                // Transaction completes: clear busy
                if (target_done[t] ^ target_busy_en[t]) begin
				  if(target_busy_en[t])
                    target_busy_cnt[t] <= target_busy_cnt[t] + 1'b1;
				  else 
				    target_busy_cnt[t] <= target_busy_cnt[t] - 1'b1;
                end
            end
        end
    end


    always @(posedge sysClk or negedge arst_sync) begin
        if (!arst_sync || !srst_sync) begin
            target_busy <= 0;
            target_owner <= 0;
        end else begin
            for (t = 0; t < NUM_TARGETS; t = t + 1) begin
                // Transaction completes: clear busy
                if (target_done[t] && (target_busy_cnt[t] == 1) && ~target_busy_en[t]) begin
                    target_busy[t] <= 0;
                end
                // New transaction starts: set busy and owner
                // Match comparison widths by truncating genvar t
                else if (requestorSelValid && ~arbEnable && muxed_target == t[NUM_TARGETS_WIDTH-1:0] && !target_busy[t]) begin
                    target_busy[t] <= 1;
                    target_owner[t*NUM_INITIATORS_WIDTH +: NUM_INITIATORS_WIDTH] <= requestorSelEnc;
                end
                // If pipelined request from same owner, keep busy and owner
                // Match comparison widths by truncating genvar t
                else if (requestorSelValid && muxed_target == t[NUM_TARGETS_WIDTH-1:0] && target_busy[t] &&
                         target_owner[t*NUM_INITIATORS_WIDTH +: NUM_INITIATORS_WIDTH] == requestorSelEnc) begin
                    target_busy[t] <= 1;
                    // owner remains the same
                end
            end
        end
    end

    // AREADY logic
    always @(*) begin
        INITIATOR_AREADY = 0;
        if (requestorSelValid & arbEnable) begin
          INITIATOR_AREADY[requestorSelEnc] = 1'b1;
        end
    end
	
    assign arbEnable = | (TARGET_AREADY & TARGET_AVALID);

    // HI_FREQ logic for dataFifoWr, srcPort, destPort
    generate
        if (HI_FREQ) begin : hi_freq_block
            always @(posedge sysClk or negedge arst_sync) begin
                if (!arst_sync || !srst_sync) begin
                    dataFifoWr <= 0;
                    srcPort    <= 0;
                    destPort   <= 0;
                end else begin
                    dataFifoWr <= arbEnable;
                    srcPort    <= targetAID;
                    destPort   <= targetdest;                      
                end
            end
        end else begin : lo_freq_block
            always @(*) begin
              dataFifoWr = arbEnable;
              srcPort    = targetAID;
              destPort   = targetdest;
            end
        end
    endgenerate

endmodule
