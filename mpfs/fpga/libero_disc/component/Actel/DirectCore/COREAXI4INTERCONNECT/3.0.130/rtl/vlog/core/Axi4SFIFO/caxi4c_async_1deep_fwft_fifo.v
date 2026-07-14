// Asynchronous FIFO with depth 2 and configurable width
// Features:
// - Safe clock domain crossing
// - Gray code pointers to prevent metastability issues
// - Full and empty flag generation
// - Configurable data width

module caxi4c_async_1deep_fwft_fifo 
#
(
  parameter DWIDTH          = 32,
  parameter NUM_SYNC_STAGES = 2,
  parameter RESET_TYPE      = 1
)
(
// Write clk interface
  input                     wclk, 
  input                     wrst_n, 
  input [DWIDTH-1:0]        wdata,
  output                    wready,
  input                     wvalid,
// Read clk interface       
  input                     rclk,
  input                     rrst_n,
  output reg [DWIDTH-1:0]   rdata,
  output                    rvalid,
  input                     rready
)/* synthesis syn_hier = "fixed" */;
  wire                      we; 
  wire                      rinc; 
  reg                       wptr /* synthesis syn_safe_cdc = 1*/;
  reg                       rptr /* synthesis syn_safe_cdc = 1*/;
  reg [DWIDTH-1:0]          mem [1:0]/* synthesis syn_ramstyle = "registers" */ ;
  reg [NUM_SYNC_STAGES-1:0] rptr_sync/* synthesis syn_preserve = 1*/ = 0;
  reg [NUM_SYNC_STAGES-1:0] wptr_sync/* synthesis syn_preserve = 1*/ = 0;
  wire                      wq2_rptr;
  wire                      rq2_wptr;
   
  wire                      awrst_n;
  wire                      swrst_n;
  wire                      arrst_n;
  wire                      srrst_n;
  
  wire                      re;
  
  assign awrst_n = (RESET_TYPE == 1) ? 1'b1 : wrst_n;
  assign swrst_n = (RESET_TYPE == 1) ? wrst_n : 1'b1;

  assign arrst_n = (RESET_TYPE == 1) ? 1'b1 : rrst_n;
  assign srrst_n = (RESET_TYPE == 1) ? rrst_n : 1'b1;

  assign we     = wready & wvalid;
  assign wready = ~(wq2_rptr ^ wptr);

  always @(posedge wclk or negedge awrst_n)
    if (!awrst_n | !swrst_n ) wptr <= 1'b0;
    else                      wptr <= wptr ^ we;
	
  always @(posedge wclk)
    rptr_sync <= {rptr_sync[NUM_SYNC_STAGES-2:0],rptr};
	
  assign wq2_rptr = rptr_sync[NUM_SYNC_STAGES-1];	
	
  always @(posedge wclk)
    if (we) mem [wptr] <= wdata;
	

  assign re     = rready & rvalid;
  assign rvalid = (rq2_wptr ^ rptr);

  always @(posedge rclk)
    wptr_sync <= {wptr_sync[NUM_SYNC_STAGES-2:0],wptr};

  assign rq2_wptr = wptr_sync[NUM_SYNC_STAGES-1];
  
  always @(posedge rclk or negedge arrst_n)
    if (!arrst_n | !srrst_n) begin 
      rptr  <= 1'b0;
	  rdata <= {DWIDTH{1'b0}};
	end else begin 
	  rptr  <= rptr ^ re;	
	  rdata <= mem[rptr];	
	end 
	
endmodule