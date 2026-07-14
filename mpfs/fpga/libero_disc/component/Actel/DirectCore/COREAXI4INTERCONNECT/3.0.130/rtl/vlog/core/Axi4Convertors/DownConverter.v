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
// SVN $Revision: 49195 $
// SVN $Date: 2025-06-22 15:17:42 +0530 (Sun, 22 Jun 2025) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4interconnect_DownConverter( INITIATOR_ARADDR,
                      INITIATOR_ARBURST,
                      INITIATOR_ARCACHE,
                      INITIATOR_ARID,
                      INITIATOR_ARLEN,
                      INITIATOR_ARLOCK,
                      INITIATOR_ARPROT,
                      INITIATOR_ARQOS,
                      INITIATOR_ARREADY,
                      INITIATOR_ARREGION,
                      INITIATOR_ARSIZE,
                      INITIATOR_ARUSER,
                      INITIATOR_ARVALID,
                      INITIATOR_RDATA,
                      INITIATOR_RID,
                      INITIATOR_RLAST,
                      INITIATOR_RREADY,
                      INITIATOR_RRESP,
                      INITIATOR_RUSER,
                      INITIATOR_RVALID,
                      INITIATOR_AWADDR,
                      INITIATOR_AWBURST,
                      INITIATOR_AWCACHE,
                      INITIATOR_AWID,
                      INITIATOR_AWLEN,
                      INITIATOR_AWLOCK,
                      INITIATOR_AWPROT,
                      INITIATOR_AWQOS,
                      INITIATOR_AWREADY,
                      INITIATOR_AWREGION,
                      INITIATOR_AWSIZE,
                      INITIATOR_AWUSER,
                      INITIATOR_AWVALID,
					  INITIATOR_WID,
                      INITIATOR_WDATA,
                      INITIATOR_WLAST,
                      INITIATOR_WREADY,
                      INITIATOR_WSTRB,
                      INITIATOR_WUSER,
                      INITIATOR_WVALID,
                      ACLK,
                      arst_sync,
                      srst_sync,
                      TARGET_BID,
                      TARGET_BREADY,
                      TARGET_BRESP,
                      TARGET_BUSER,
                      TARGET_BVALID,
                      TARGET_ARADDR,
                      TARGET_ARBURST,
                      TARGET_ARCACHE,
                      TARGET_ARID,
                      TARGET_ARLEN,
                      TARGET_ARLOCK,
                      TARGET_ARPROT,
                      TARGET_ARQOS,
                      TARGET_ARREADY,
                      TARGET_ARREGION,
                      TARGET_ARSIZE,
                      TARGET_ARUSER,
                      TARGET_ARVALID,
                      TARGET_AWADDR,
                      TARGET_AWBURST,
                      TARGET_AWCACHE,
                      TARGET_AWID,
                      TARGET_AWLEN,
                      TARGET_AWLOCK,
                      TARGET_AWPROT,
                      TARGET_AWQOS,
                      TARGET_AWREADY,
                      TARGET_AWREGION,
                      TARGET_AWSIZE,
                      TARGET_AWUSER,
                      TARGET_AWVALID,
                      TARGET_RDATA,
                      TARGET_RID,
                      TARGET_RLAST,
                      TARGET_RREADY,
                      TARGET_RRESP,
                      TARGET_RUSER,
                      TARGET_RVALID,
					  TARGET_WID,
                      TARGET_WDATA,
                      TARGET_WLAST,
                      TARGET_WREADY,
                      TARGET_WSTRB,
                      TARGET_WUSER,
                      TARGET_WVALID,
                      INITIATOR_BID,
                      INITIATOR_BREADY,
                      INITIATOR_BRESP,
                      INITIATOR_BUSER,
                      INITIATOR_BVALID );

parameter ADDR_FIFO_DEPTH = 5; 
parameter DATA_WIDTH_IN = 32; 
parameter DATA_WIDTH_OUT = 32; 
parameter ADDR_WIDTH = 20; 
parameter ID_WIDTH = 1; 
parameter USER_WIDTH = 1; 
parameter STRB_WIDTH_IN = 64; 
parameter STRB_WIDTH_OUT = 4; 
parameter READ_INTERLEAVE = 0; 
parameter PIPE = 0; 
parameter DWC_RAM_TYPE = 3; 
parameter SYNC_RESET = 0; 

// Port: INITIATOR_ARChan

input [ADDR_WIDTH-1:0] INITIATOR_ARADDR;
input [1:0]    INITIATOR_ARBURST;
input [3:0]    INITIATOR_ARCACHE;
input [ID_WIDTH-1:0] INITIATOR_ARID;
input [7:0]    INITIATOR_ARLEN;
input [1:0]    INITIATOR_ARLOCK;
input [2:0]    INITIATOR_ARPROT;
input [3:0]    INITIATOR_ARQOS;
output         INITIATOR_ARREADY;
input [3:0]    INITIATOR_ARREGION;
input [2:0]    INITIATOR_ARSIZE;
input [USER_WIDTH-1:0] INITIATOR_ARUSER;
input          INITIATOR_ARVALID;

// Port: INITIATOR_RChan

output [DATA_WIDTH_IN-1:0] INITIATOR_RDATA;
output [ID_WIDTH-1:0] INITIATOR_RID;
output         INITIATOR_RLAST;
input          INITIATOR_RREADY;
output [1:0]   INITIATOR_RRESP;
output [USER_WIDTH-1:0] INITIATOR_RUSER;
output         INITIATOR_RVALID;

// Port: INITIATOR_AWChan

input [ADDR_WIDTH-1:0] INITIATOR_AWADDR;
input [1:0]    INITIATOR_AWBURST;
input [3:0]    INITIATOR_AWCACHE;
input [ID_WIDTH-1:0] INITIATOR_AWID;
input [7:0]    INITIATOR_AWLEN;
input [1:0]    INITIATOR_AWLOCK;
input [2:0]    INITIATOR_AWPROT;
input [3:0]    INITIATOR_AWQOS;
output         INITIATOR_AWREADY;
input [3:0]    INITIATOR_AWREGION;
input [2:0]    INITIATOR_AWSIZE;
input [USER_WIDTH-1:0] INITIATOR_AWUSER;
input          INITIATOR_AWVALID;

// Port: INITIATOR_WChan

input [ID_WIDTH-1:0]      INITIATOR_WID;
input [DATA_WIDTH_IN-1:0] INITIATOR_WDATA;
input          INITIATOR_WLAST;
output         INITIATOR_WREADY;
input [STRB_WIDTH_IN-1:0] INITIATOR_WSTRB;
input [USER_WIDTH-1:0] INITIATOR_WUSER;
input          INITIATOR_WVALID;

// Port: system

input          ACLK;
input          arst_sync;
input          srst_sync;

// Port: TARGET_BChan

input [ID_WIDTH-1:0] TARGET_BID;
output         TARGET_BREADY;
input [1:0]    TARGET_BRESP;
input [USER_WIDTH-1:0] TARGET_BUSER;
input          TARGET_BVALID;

// Port: TARGET_ARChan

output [ADDR_WIDTH-1:0] TARGET_ARADDR;
output [1:0]   TARGET_ARBURST;
output [3:0]   TARGET_ARCACHE;
output [ID_WIDTH-1:0] TARGET_ARID;
output [7:0]   TARGET_ARLEN;
output [1:0]   TARGET_ARLOCK;
output [2:0]   TARGET_ARPROT;
output [3:0]   TARGET_ARQOS;
input          TARGET_ARREADY;
output [3:0]   TARGET_ARREGION;
output [2:0]   TARGET_ARSIZE;
output [USER_WIDTH-1:0] TARGET_ARUSER;
output         TARGET_ARVALID;

// Port: TARGET_AWChan

output [ADDR_WIDTH-1:0] TARGET_AWADDR;
output [1:0]   TARGET_AWBURST;
output [3:0]   TARGET_AWCACHE;
output [ID_WIDTH-1:0] TARGET_AWID;
output [7:0]   TARGET_AWLEN;
output [1:0]   TARGET_AWLOCK;
output [2:0]   TARGET_AWPROT;
output [3:0]   TARGET_AWQOS;
input          TARGET_AWREADY;
output [3:0]   TARGET_AWREGION;
output [2:0]   TARGET_AWSIZE;
output [USER_WIDTH-1:0] TARGET_AWUSER;
output         TARGET_AWVALID;

// Port: TARGET_RChan

input [DATA_WIDTH_OUT-1:0] TARGET_RDATA;
input [ID_WIDTH-1:0] TARGET_RID;
input          TARGET_RLAST;
output         TARGET_RREADY;
input [1:0]    TARGET_RRESP;
input [USER_WIDTH-1:0] TARGET_RUSER;
input          TARGET_RVALID;

// Port: TARGET_WChan

output [ID_WIDTH-1:0]       TARGET_WID;
output [DATA_WIDTH_OUT-1:0] TARGET_WDATA;
output         TARGET_WLAST;
input          TARGET_WREADY;
output [STRB_WIDTH_OUT-1:0] TARGET_WSTRB;
output [USER_WIDTH-1:0] TARGET_WUSER;
output         TARGET_WVALID;

// Port: INITIATOR_BChan

output [ID_WIDTH-1:0] INITIATOR_BID;
input          INITIATOR_BREADY;
output [1:0]   INITIATOR_BRESP;
output [USER_WIDTH-1:0] INITIATOR_BUSER;
output         INITIATOR_BVALID;



/// I/O_End <<<---






/// Components_Start --->>>

// write data width conversion
// File: writeWidthConv.v

defparam writeWidthConv.CMD_FIFO_DATA_WIDTH = 37+ID_WIDTH;
defparam writeWidthConv.DATA_WIDTH_IN = DATA_WIDTH_IN;
defparam writeWidthConv.DATA_WIDTH_OUT = DATA_WIDTH_OUT;
defparam writeWidthConv.ADDR_FIFO_DEPTH = ADDR_FIFO_DEPTH;
defparam writeWidthConv.ADDR_WIDTH = ADDR_WIDTH;
defparam writeWidthConv.ID_WIDTH = ID_WIDTH;
defparam writeWidthConv.USER_WIDTH = USER_WIDTH;
defparam writeWidthConv.STRB_WIDTH_IN = STRB_WIDTH_IN;
defparam writeWidthConv.STRB_WIDTH_OUT = STRB_WIDTH_OUT;
defparam writeWidthConv.READ_INTERLEAVE = READ_INTERLEAVE;
defparam writeWidthConv.PIPE = PIPE;
defparam writeWidthConv.DWC_RAM_TYPE = DWC_RAM_TYPE;
defparam writeWidthConv.SYNC_RESET = SYNC_RESET;


caxi4interconnect_DWC_DownConv_writeWidthConv writeWidthConv( .INITIATOR_AWREADY(INITIATOR_AWREADY),
                               .INITIATOR_AWADDR(INITIATOR_AWADDR),
                               .INITIATOR_AWBURST(INITIATOR_AWBURST),
                               .INITIATOR_AWCACHE(INITIATOR_AWCACHE),
                               .INITIATOR_AWID(INITIATOR_AWID),
                               .INITIATOR_AWLEN(INITIATOR_AWLEN),
                               .INITIATOR_AWLOCK(INITIATOR_AWLOCK),
                               .INITIATOR_AWPROT(INITIATOR_AWPROT),
                               .INITIATOR_AWQOS(INITIATOR_AWQOS),
                               .INITIATOR_AWREGION(INITIATOR_AWREGION),
                               .INITIATOR_AWSIZE(INITIATOR_AWSIZE),
                               .INITIATOR_AWUSER(INITIATOR_AWUSER),
                               .INITIATOR_AWVALID(INITIATOR_AWVALID),
                               .TARGET_BID(TARGET_BID),
                               .TARGET_BREADY(TARGET_BREADY),
                               .TARGET_BRESP(TARGET_BRESP),
                               .TARGET_BUSER(TARGET_BUSER),
                               .TARGET_BVALID(TARGET_BVALID),
                               .TARGET_AWADDR(TARGET_AWADDR),
                               .TARGET_AWBURST(TARGET_AWBURST),
                               .TARGET_AWCACHE(TARGET_AWCACHE),
                               .TARGET_AWID(TARGET_AWID),
                               .TARGET_AWLEN(TARGET_AWLEN),
                               .TARGET_AWLOCK(TARGET_AWLOCK),
                               .TARGET_AWPROT(TARGET_AWPROT),
                               .TARGET_AWQOS(TARGET_AWQOS),
                               .TARGET_AWREADY(TARGET_AWREADY),
                               .TARGET_AWREGION(TARGET_AWREGION),
                               .TARGET_AWSIZE(TARGET_AWSIZE),
                               .TARGET_AWUSER(TARGET_AWUSER),
                               .TARGET_AWVALID(TARGET_AWVALID),
                               .INITIATOR_BID(INITIATOR_BID),
                               .INITIATOR_BREADY(INITIATOR_BREADY),
                               .INITIATOR_BRESP(INITIATOR_BRESP),
                               .INITIATOR_BUSER(INITIATOR_BUSER),
                               .INITIATOR_BVALID(INITIATOR_BVALID),
							   .INITIATOR_WID (INITIATOR_WID),
                               .INITIATOR_WDATA(INITIATOR_WDATA),
                               .INITIATOR_WLAST(INITIATOR_WLAST),
                               .INITIATOR_WREADY(INITIATOR_WREADY),
                               .INITIATOR_WSTRB(INITIATOR_WSTRB),
                               .INITIATOR_WUSER(INITIATOR_WUSER),
                               .INITIATOR_WVALID(INITIATOR_WVALID),
							   .TARGET_WID  (TARGET_WID),
                               .TARGET_WDATA(TARGET_WDATA),
                               .TARGET_WLAST(TARGET_WLAST),
                               .TARGET_WREADY(TARGET_WREADY),
                               .TARGET_WSTRB(TARGET_WSTRB),
                               .TARGET_WUSER(TARGET_WUSER),
                               .TARGET_WVALID(TARGET_WVALID),
                               .ACLK(ACLK),
                               .arst_sync(arst_sync), 
                               .srst_sync(srst_sync) 
							   );

// read width converter
// File: readWidthConv.v

defparam readWidthConv.DATA_WIDTH_IN = DATA_WIDTH_OUT;
defparam readWidthConv.ADDR_FIFO_DEPTH = ADDR_FIFO_DEPTH;
defparam readWidthConv.CMD_FIFO_DATA_WIDTH = 37+ID_WIDTH;
defparam readWidthConv.DATA_WIDTH_OUT = DATA_WIDTH_IN;
defparam readWidthConv.ADDR_WIDTH = ADDR_WIDTH;
defparam readWidthConv.ID_WIDTH = ID_WIDTH;
defparam readWidthConv.USER_WIDTH = USER_WIDTH;
defparam readWidthConv.READ_INTERLEAVE = READ_INTERLEAVE;
defparam readWidthConv.PIPE       = PIPE;
defparam readWidthConv.DWC_RAM_TYPE  = DWC_RAM_TYPE;
defparam readWidthConv.SYNC_RESET = SYNC_RESET;

caxi4interconnect_DWC_DownConv_readWidthConv readWidthConv( .INITIATOR_ARADDR(INITIATOR_ARADDR),
                             .INITIATOR_ARBURST(INITIATOR_ARBURST),
                             .INITIATOR_ARCACHE(INITIATOR_ARCACHE),
                             .INITIATOR_ARID(INITIATOR_ARID),
                             .INITIATOR_ARLEN(INITIATOR_ARLEN),
                             .INITIATOR_ARLOCK(INITIATOR_ARLOCK),
                             .INITIATOR_ARPROT(INITIATOR_ARPROT),
                             .INITIATOR_ARQOS(INITIATOR_ARQOS),
                             .INITIATOR_ARREADY(INITIATOR_ARREADY),
                             .INITIATOR_ARREGION(INITIATOR_ARREGION),
                             .INITIATOR_ARSIZE(INITIATOR_ARSIZE),
                             .INITIATOR_ARUSER(INITIATOR_ARUSER),
                             .INITIATOR_ARVALID(INITIATOR_ARVALID),
                             .INITIATOR_RDATA(INITIATOR_RDATA),
                             .INITIATOR_RID(INITIATOR_RID),
                             .INITIATOR_RLAST(INITIATOR_RLAST),
                             .INITIATOR_RREADY(INITIATOR_RREADY),
                             .INITIATOR_RRESP(INITIATOR_RRESP),
                             .INITIATOR_RUSER(INITIATOR_RUSER),
                             .INITIATOR_RVALID(INITIATOR_RVALID),
                             .TARGET_RDATA(TARGET_RDATA),
                             .TARGET_RID(TARGET_RID),
                             .TARGET_RLAST(TARGET_RLAST),
                             .TARGET_RREADY(TARGET_RREADY),
                             .TARGET_RRESP(TARGET_RRESP),
                             .TARGET_RUSER(TARGET_RUSER),
                             .TARGET_RVALID(TARGET_RVALID),
                             .TARGET_ARADDR(TARGET_ARADDR),
                             .TARGET_ARBURST(TARGET_ARBURST),
                             .TARGET_ARCACHE(TARGET_ARCACHE),
                             .TARGET_ARID(TARGET_ARID),
                             .TARGET_ARLEN(TARGET_ARLEN),
                             .TARGET_ARLOCK(TARGET_ARLOCK),
                             .TARGET_ARPROT(TARGET_ARPROT),
                             .TARGET_ARQOS(TARGET_ARQOS),
                             .TARGET_ARREADY(TARGET_ARREADY),
                             .TARGET_ARREGION(TARGET_ARREGION),
                             .TARGET_ARVALID(TARGET_ARVALID),
                             .TARGET_ASIZE(TARGET_ARSIZE),
                             .TARGET_AUSER(TARGET_ARUSER),
                             .ACLK(ACLK),
                             .arst_sync(arst_sync), 
                             .srst_sync(srst_sync) 
							 );




/// Components_End <<<---


endmodule

