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
// SVN $Revision: 44682 $
// SVN $Date: 2023-10-28 01:51:11 +0530 (Sat, 28 Oct 2023) $
//
//
// *********************************************************************/
 
module caxi4interconnect_AHB_SM_Undefburst (
               iarst_sync,
               isrst_sync,
               ACLK,
               int_initiatorAWID,
               int_initiatorAWADDR,
               int_initiatorAWLEN,
               int_initiatorAWSIZE,
               int_initiatorAWBURST,
               int_initiatorAWLOCK,
               int_initiatorAWCACHE,
               int_initiatorAWPROT,
               int_initiatorAWQOS,
               int_initiatorAWREGION,
               int_initiatorAWUSER,
               int_initiatorAWVALID,
               int_initiatorAWREADY,
               int_initiatorARID,
               int_initiatorARADDR,
               int_initiatorARLEN,
               int_initiatorARSIZE,
               int_initiatorARBURST,
               int_initiatorARLOCK,
               int_initiatorARCACHE,
               int_initiatorARPROT,
               int_initiatorARQOS,
               int_initiatorARREGION,
               int_initiatorARUSER,
               int_initiatorARVALID,
               int_initiatorARREADY,
               int_initiatorWDATA,
               int_initiatorWLAST,
               int_initiatorWSTRB,
               int_initiatorWUSER,
               int_initiatorWVALID,
               int_initiatorWID,
               int_initiatorWREADY,
               int_initiatorRID,
               int_initiatorRDATA,
               int_initiatorRLAST,
               int_initiatorRRESP,
               int_initiatorRUSER,
               int_initiatorRVALID,
               int_initiatorRREADY,
               int_initiatorBID,
               int_initiatorBRESP,
               int_initiatorBUSER,
               int_initiatorBVALID,
               int_initiatorBREADY,
               INITIATOR_HADDR,
               INITIATOR_HSEL,
               INITIATOR_HBURST,
               INITIATOR_HMASTLOCK,
               INITIATOR_HPROT,
               INITIATOR_HSIZE,
               INITIATOR_HNONSEC,
               INITIATOR_HTRANS,
               INITIATOR_HWDATA,
               INITIATOR_HWRITE,
               INITIATOR_HRDATA,
               INITIATOR_HRESP,
               INITIATOR_HREADY
               );
 
   parameter        USER_WIDTH           = 1;
   parameter        DEF_BURST_LEN        = 0;
   parameter        ADDR_WIDTH           = 20;
   parameter        DATA_WIDTH           = 32;
   parameter        ID_WIDTH             = 1;
   parameter [1:0]  BRESP_CHECK_MODE     = 2'b00;
   parameter        LOG_BYTE_WIDTH       = 2;
   parameter        BRESP_CNT_WIDTH      = 'h8;
   
   localparam       ADDR_LSB_POS       = $clog2(DATA_WIDTH/8);   
   localparam       AXI4_LEN_VEC_LIMIT = (13 - ADDR_LSB_POS) < 8 ? (13 - ADDR_LSB_POS) : 8;   
   
   input            iarst_sync;
   input            isrst_sync;
   wire             iarst_sync;
   input            ACLK;
   wire             ACLK;
   output    [ID_WIDTH - 1:0] int_initiatorAWID;
   wire      [ID_WIDTH - 1:0] int_initiatorAWID;
   output    [ADDR_WIDTH - 1:0] int_initiatorAWADDR;
   wire      [ADDR_WIDTH - 1:0] int_initiatorAWADDR;
   output    [7:0]  int_initiatorAWLEN;
   wire      [7:0]  int_initiatorAWLEN;
   output    [2:0]  int_initiatorAWSIZE;
   wire      [2:0]  int_initiatorAWSIZE;
   output    [1:0]  int_initiatorAWBURST;
   wire      [1:0]  int_initiatorAWBURST;
   output    [1:0]  int_initiatorAWLOCK;
   wire      [1:0]  int_initiatorAWLOCK;
   output    [3:0]  int_initiatorAWCACHE;
   wire      [3:0]  int_initiatorAWCACHE;
   output    [2:0]  int_initiatorAWPROT;
   wire      [2:0]  int_initiatorAWPROT;
   output    [3:0]  int_initiatorAWQOS;
   wire      [3:0]  int_initiatorAWQOS;
   output    [3:0]  int_initiatorAWREGION;
   wire      [3:0]  int_initiatorAWREGION;
   output    [USER_WIDTH - 1:0] int_initiatorAWUSER;
   wire      [USER_WIDTH - 1:0] int_initiatorAWUSER;
   output           int_initiatorAWVALID;
   reg              int_initiatorAWVALID;
   input            int_initiatorAWREADY;
   wire             int_initiatorAWREADY;
   output    [ID_WIDTH - 1:0] int_initiatorARID;
   wire      [ID_WIDTH - 1:0] int_initiatorARID;
   output    [ADDR_WIDTH - 1:0] int_initiatorARADDR;
   wire      [ADDR_WIDTH - 1:0] int_initiatorARADDR;
   output    [7:0]  int_initiatorARLEN;
   wire      [7:0]  int_initiatorARLEN;
   output    [2:0]  int_initiatorARSIZE;
   wire      [2:0]  int_initiatorARSIZE;
   output    [1:0]  int_initiatorARBURST;
   wire      [1:0]  int_initiatorARBURST;
   output    [1:0]  int_initiatorARLOCK;
   wire      [1:0]  int_initiatorARLOCK;
   output    [3:0]  int_initiatorARCACHE;
   wire      [3:0]  int_initiatorARCACHE;
   output    [2:0]  int_initiatorARPROT;
   wire      [2:0]  int_initiatorARPROT;
   output    [3:0]  int_initiatorARQOS;
   wire      [3:0]  int_initiatorARQOS;
   output    [3:0]  int_initiatorARREGION;
   wire      [3:0]  int_initiatorARREGION;
   output    [USER_WIDTH - 1:0] int_initiatorARUSER;
   wire      [USER_WIDTH - 1:0] int_initiatorARUSER;
   output           int_initiatorARVALID;
   reg              int_initiatorARVALID;
   input            int_initiatorARREADY;
   wire             int_initiatorARREADY;
   output    [DATA_WIDTH - 1:0] int_initiatorWDATA;
   wire      [DATA_WIDTH - 1:0] int_initiatorWDATA;
   output           int_initiatorWLAST;
   reg              int_initiatorWLAST;
   output    [(DATA_WIDTH / 8) - 1:0] int_initiatorWSTRB;
   reg       [(DATA_WIDTH / 8) - 1:0] int_initiatorWSTRB;
   output    [USER_WIDTH - 1:0] int_initiatorWUSER;
   wire      [USER_WIDTH - 1:0] int_initiatorWUSER;
   output           int_initiatorWVALID;
   reg              int_initiatorWVALID;
   output    [ID_WIDTH-1:0] int_initiatorWID;
   input            int_initiatorWREADY;
   wire             int_initiatorWREADY;
   input     [ID_WIDTH - 1:0] int_initiatorRID;
   wire      [ID_WIDTH - 1:0] int_initiatorRID;
   input     [DATA_WIDTH - 1:0] int_initiatorRDATA;
   wire      [DATA_WIDTH - 1:0] int_initiatorRDATA;
   input            int_initiatorRLAST;
   wire             int_initiatorRLAST;
   input     [1:0]  int_initiatorRRESP;
   wire      [1:0]  int_initiatorRRESP;
   input     [USER_WIDTH - 1:0] int_initiatorRUSER;
   wire      [USER_WIDTH - 1:0] int_initiatorRUSER;
   input            int_initiatorRVALID;
   wire             int_initiatorRVALID;
   output           int_initiatorRREADY;
   reg              int_initiatorRREADY;
   input     [ID_WIDTH - 1:0] int_initiatorBID;
   wire      [ID_WIDTH - 1:0] int_initiatorBID;
   input     [1:0]  int_initiatorBRESP;
   wire      [1:0]  int_initiatorBRESP;
   input     [USER_WIDTH - 1:0] int_initiatorBUSER;
   wire      [USER_WIDTH - 1:0] int_initiatorBUSER;
   input            int_initiatorBVALID;
   wire             int_initiatorBVALID;
   output           int_initiatorBREADY;
   reg              int_initiatorBREADY;
   input     [31:0] INITIATOR_HADDR;
   wire      [31:0] INITIATOR_HADDR;
   input            INITIATOR_HSEL;
   wire             INITIATOR_HSEL;
   input     [2:0]  INITIATOR_HBURST;
   wire      [2:0]  INITIATOR_HBURST;
   input            INITIATOR_HMASTLOCK;
   wire             INITIATOR_HMASTLOCK;
   input     [6:0]  INITIATOR_HPROT;
   wire      [6:0]  INITIATOR_HPROT;
   input     [2:0]  INITIATOR_HSIZE;
   wire      [2:0]  INITIATOR_HSIZE;
   input            INITIATOR_HNONSEC;
   wire             INITIATOR_HNONSEC;
   input     [1:0]  INITIATOR_HTRANS;
   wire      [1:0]  INITIATOR_HTRANS;
   input     [DATA_WIDTH - 1:0] INITIATOR_HWDATA;
   wire      [DATA_WIDTH - 1:0] INITIATOR_HWDATA;
   input            INITIATOR_HWRITE;
   wire             INITIATOR_HWRITE;
   output    [DATA_WIDTH - 1:0] INITIATOR_HRDATA;
   reg       [DATA_WIDTH - 1:0] INITIATOR_HRDATA;
   output           INITIATOR_HRESP;
   reg              INITIATOR_HRESP;
   output           INITIATOR_HREADY;
   reg              INITIATOR_HREADY;
   reg       [8:0]  ph_cnt;                             //  current data phase
   reg              ahb_write_op;
   wire             NONSEQ;
   wire             BUSY;
   wire             IDLE;
   wire             SEQ;
   wire             count_match;
   reg       [7:0]  exp_burst_len;
   reg       [8:0]  latched_exp_burst_len;
   wire             new_cycle;
   wire             end_cycle;
   reg              cycle_in_progress;
   reg       [DATA_WIDTH - 1:0] int_initiatorRDATA_hold;
   reg       [LOG_BYTE_WIDTH - 1:0] haddr_latched;
   reg       [2:0]  hsize_latched;
   reg              valid_data_avail;
   reg              zero_strb;
   wire      [6:0]  size_bytes;
   wire      [(DATA_WIDTH / 8) - 1:0] pre_shifted_strobes;
   wire      [LOG_BYTE_WIDTH - 1:0] num_of_bytes_to_shift;
   wire      [(DATA_WIDTH / 8) - 1:0] initiatorSTRB;
   wire             check_end;
   wire             check_all;
   wire             checkendonly;
   reg              setwrcntto1;
   reg       [BRESP_CNT_WIDTH - 1:0] wrcnt;
   reg              wrerr;
   wire             wrcntmax;
   wire             decwrcnt;
   wire             incrwrcnt;
   reg       [9:0]  ph_cnt_plus_1;
 
   parameter AXI_EXTEND       = 3'b000,
             DATA_TRANSF      = 3'b001,
             ERROR            = 3'b010,
             WAIT_BVALID      = 3'b011,
             WAIT_LAST_BVALID = 3'b100;
 
 
   reg [2:0] visual_AHB_SM_current, visual_AHB_SM_next;
 
   reg       [8:0]  visual_ph_cnt_next;
   reg              visual_ahb_write_op_next;
   reg       [8:0]  visual_latched_exp_burst_len_next;
   reg              visual_cycle_in_progress_next;
   reg       [DATA_WIDTH - 1:0] visual_int_initiatorRDATA_hold_next;
   reg       [LOG_BYTE_WIDTH - 1:0] visual_haddr_latched_next;
   reg       [2:0]  visual_hsize_latched_next;
   reg              visual_valid_data_avail_next;
   reg              visual_zero_strb_next;
   reg       int_initiatorBREADY_reg;
   reg       [DATA_WIDTH - 1:0] INITIATOR_HRDATA_reg;
   wire [12:0]                  axi_len_limit;
   wire [13:0]                  defburst_len_bytes;
   wire                         axi_cross_4kaddr;
 
   always @( posedge ACLK or negedge iarst_sync )
     begin
        if(~iarst_sync | ~isrst_sync) begin
           int_initiatorBREADY_reg <= 1'b0;
           INITIATOR_HRDATA_reg <= {DATA_WIDTH{1'b0}};
        end else begin
           int_initiatorBREADY_reg <= int_initiatorBREADY;
           INITIATOR_HRDATA_reg <= INITIATOR_HRDATA;
        end
     end
 
   // Combinational process
   always  @(ph_cnt or ahb_write_op or latched_exp_burst_len or cycle_in_progress or int_initiatorRDATA_hold or haddr_latched or hsize_latched or valid_data_avail or zero_strb or count_match or
             int_initiatorWREADY or check_end or wrcnt or wrerr or new_cycle or INITIATOR_HWRITE or int_initiatorAWREADY or exp_burst_len or INITIATOR_HADDR or INITIATOR_HSIZE or int_initiatorARREADY or
             int_initiatorRVALID or check_all or end_cycle or int_initiatorRDATA or int_initiatorRRESP or wrcntmax or BUSY or int_initiatorBVALID or int_initiatorBRESP or visual_AHB_SM_current or INITIATOR_HRDATA_reg or int_initiatorBREADY_reg)
   begin : AHB_SM_comb
      int_initiatorAWVALID                      = 1'b0;
      int_initiatorARVALID                      = 1'b0;
      int_initiatorWLAST                        = 1'b0;
      int_initiatorWVALID                       = 1'b0;
      int_initiatorRREADY                       = 1'b0;
      INITIATOR_HRESP                           = 1'b0;
      INITIATOR_HREADY                          = 1'b0;
      setwrcntto1                            = 1'b0;
      visual_ph_cnt_next                     = ph_cnt;
      visual_ahb_write_op_next               = ahb_write_op;
      visual_latched_exp_burst_len_next      = latched_exp_burst_len;
      visual_cycle_in_progress_next          = cycle_in_progress;
      visual_int_initiatorRDATA_hold_next       = int_initiatorRDATA_hold;
      visual_haddr_latched_next = haddr_latched;
      visual_hsize_latched_next = hsize_latched;
      visual_valid_data_avail_next = valid_data_avail;
      visual_zero_strb_next = zero_strb;
      int_initiatorBREADY = int_initiatorBREADY_reg;
	  INITIATOR_HRDATA = INITIATOR_HRDATA_reg;
 
      case (visual_AHB_SM_current)
         AXI_EXTEND:
            begin
               INITIATOR_HRDATA = int_initiatorRDATA_hold;
               if (ahb_write_op)
               begin
                  int_initiatorWVALID = 1;
                  int_initiatorWLAST = count_match;
                  if (int_initiatorWREADY)
                  begin
                     visual_ph_cnt_next = ph_cnt + 1;
                     if (count_match)
                     begin
                        if (check_end)
                        begin
                           if (ahb_write_op)
                           begin
                              int_initiatorBREADY = 1'b1;
                              if (wrcnt == 0)
                              begin
                                 if (wrerr)
                                 begin
                                    //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                                    visual_cycle_in_progress_next = 1'b0;
                                    INITIATOR_HRESP = 1'b1;
                                    visual_AHB_SM_next = ERROR;
                                 end
                                 else if (new_cycle)
                                 begin
                                    if (INITIATOR_HWRITE)
                                    begin
                                       int_initiatorAWVALID = 1;
                                       if (int_initiatorAWREADY)
                                       begin
                                          visual_cycle_in_progress_next = 1;
                                          INITIATOR_HREADY = 1;
                                          visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                          visual_ahb_write_op_next = INITIATOR_HWRITE;
                                          visual_ph_cnt_next = 0;
                                          visual_valid_data_avail_next = 1;
                                          visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                          visual_hsize_latched_next = INITIATOR_HSIZE;
                                          visual_zero_strb_next = 1'b0;
                                          setwrcntto1 = INITIATOR_HWRITE;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                       else
                                       begin
                                          visual_cycle_in_progress_next = 1'b0;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                    end
                                    else
                                    begin
                                       int_initiatorARVALID = 1;
                                       if (int_initiatorARREADY)
                                       begin
                                          visual_cycle_in_progress_next = 1;
                                          INITIATOR_HREADY = 1;
                                          visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                          visual_ahb_write_op_next = INITIATOR_HWRITE;
                                          visual_ph_cnt_next = 0;
                                          visual_valid_data_avail_next = 1;
                                          visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                          visual_hsize_latched_next = INITIATOR_HSIZE;
                                          visual_zero_strb_next = 1'b0;
                                          setwrcntto1 = INITIATOR_HWRITE;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                       else
                                       begin
                                          visual_cycle_in_progress_next = 1'b0;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                    end
                                 end
                                 else
                                 begin
                                    INITIATOR_HREADY = 1;
                                    visual_cycle_in_progress_next = 0;
                                    visual_valid_data_avail_next = 0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                              else
                              begin
                                 visual_AHB_SM_next = WAIT_LAST_BVALID;
                              end
                           end
                           else if (new_cycle)
                           begin
                              if (INITIATOR_HWRITE)
                              begin
                                 int_initiatorAWVALID = 1;
                                 if (int_initiatorAWREADY)
                                 begin
                                    visual_cycle_in_progress_next = 1;
                                    INITIATOR_HREADY = 1;
                                    visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                    visual_ahb_write_op_next = INITIATOR_HWRITE;
                                    visual_ph_cnt_next = 0;
                                    visual_valid_data_avail_next = 1;
                                    visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                    visual_hsize_latched_next = INITIATOR_HSIZE;
                                    visual_zero_strb_next = 1'b0;
                                    setwrcntto1 = INITIATOR_HWRITE;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                                 else
                                 begin
                                    visual_cycle_in_progress_next = 1'b0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                              else
                              begin
                                 int_initiatorARVALID = 1;
                                 if (int_initiatorARREADY)
                                 begin
                                    visual_cycle_in_progress_next = 1;
                                    INITIATOR_HREADY = 1;
                                    visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                    visual_ahb_write_op_next = INITIATOR_HWRITE;
                                    visual_ph_cnt_next = 0;
                                    visual_valid_data_avail_next = 1;
                                    visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                    visual_hsize_latched_next = INITIATOR_HSIZE;
                                    visual_zero_strb_next = 1'b0;
                                    setwrcntto1 = INITIATOR_HWRITE;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                                 else
                                 begin
                                    visual_cycle_in_progress_next = 1'b0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                           end
                           else
                           begin
                              INITIATOR_HREADY = 1;
                              visual_cycle_in_progress_next = 0;
                              visual_valid_data_avail_next = 0;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                        end
                        else if (new_cycle)
                        begin
                           if (INITIATOR_HWRITE)
                           begin
                              int_initiatorAWVALID = 1;
                              if (int_initiatorAWREADY)
                              begin
                                 visual_cycle_in_progress_next = 1;
                                 INITIATOR_HREADY = 1;
                                 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                 visual_ahb_write_op_next = INITIATOR_HWRITE;
                                 visual_ph_cnt_next = 0;
                                 visual_valid_data_avail_next = 1;
                                 visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                 visual_hsize_latched_next = INITIATOR_HSIZE;
                                 visual_zero_strb_next = 1'b0;
                                 setwrcntto1 = INITIATOR_HWRITE;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                              else
                              begin
                                 visual_cycle_in_progress_next = 1'b0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                           else
                           begin
                              int_initiatorARVALID = 1;
                              if (int_initiatorARREADY)
                              begin
                                 visual_cycle_in_progress_next = 1;
                                 INITIATOR_HREADY = 1;
                                 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                 visual_ahb_write_op_next = INITIATOR_HWRITE;
                                 visual_ph_cnt_next = 0;
                                 visual_valid_data_avail_next = 1;
                                 visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                 visual_hsize_latched_next = INITIATOR_HSIZE;
                                 visual_zero_strb_next = 1'b0;
                                 setwrcntto1 = INITIATOR_HWRITE;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                              else
                              begin
                                 visual_cycle_in_progress_next = 1'b0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                        end
                        else
                        begin
                           INITIATOR_HREADY = 1;
                           visual_cycle_in_progress_next = 0;
                           visual_valid_data_avail_next = 0;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                     else
                     begin
                        visual_AHB_SM_next = AXI_EXTEND;
                     end
                  end
                  else
                  begin
                     visual_AHB_SM_next = AXI_EXTEND;
                  end
               end
               else if (int_initiatorRVALID)
               begin
                  int_initiatorRREADY = 1;
                  visual_ph_cnt_next = ph_cnt + 1;
                  if (count_match)
                  begin
                     if (check_end)
                     begin
                        if (ahb_write_op)
                        begin
                           int_initiatorBREADY = 1'b1;
                           if (wrcnt == 0)
                           begin
                              if (wrerr)
                              begin
                                 //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                                 visual_cycle_in_progress_next = 1'b0;
                                 INITIATOR_HRESP = 1'b1;
                                 visual_AHB_SM_next = ERROR;
                              end
                              else if (new_cycle)
                              begin
                                 if (INITIATOR_HWRITE)
                                 begin
                                    int_initiatorAWVALID = 1;
                                    if (int_initiatorAWREADY)
                                    begin
                                       visual_cycle_in_progress_next = 1;
                                       INITIATOR_HREADY = 1;
                                       visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                       visual_ahb_write_op_next = INITIATOR_HWRITE;
                                       visual_ph_cnt_next = 0;
                                       visual_valid_data_avail_next = 1;
                                       visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                       visual_hsize_latched_next = INITIATOR_HSIZE;
                                       visual_zero_strb_next = 1'b0;
                                       setwrcntto1 = INITIATOR_HWRITE;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                    else
                                    begin
                                       visual_cycle_in_progress_next = 1'b0;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                 end
                                 else
                                 begin
                                    int_initiatorARVALID = 1;
                                    if (int_initiatorARREADY)
                                    begin
                                       visual_cycle_in_progress_next = 1;
                                       INITIATOR_HREADY = 1;
                                       visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                       visual_ahb_write_op_next = INITIATOR_HWRITE;
                                       visual_ph_cnt_next = 0;
                                       visual_valid_data_avail_next = 1;
                                       visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                       visual_hsize_latched_next = INITIATOR_HSIZE;
                                       visual_zero_strb_next = 1'b0;
                                       setwrcntto1 = INITIATOR_HWRITE;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                    else
                                    begin
                                       visual_cycle_in_progress_next = 1'b0;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                 end
                              end
                              else
                              begin
                                 INITIATOR_HREADY = 1;
                                 visual_cycle_in_progress_next = 0;
                                 visual_valid_data_avail_next = 0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                           else
                           begin
                              visual_AHB_SM_next = WAIT_LAST_BVALID;
                           end
                        end
                        else if (new_cycle)
                        begin
                           if (INITIATOR_HWRITE)
                           begin
                              int_initiatorAWVALID = 1;
                              if (int_initiatorAWREADY)
                              begin
                                 visual_cycle_in_progress_next = 1;
                                 INITIATOR_HREADY = 1;
                                 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                 visual_ahb_write_op_next = INITIATOR_HWRITE;
                                 visual_ph_cnt_next = 0;
                                 visual_valid_data_avail_next = 1;
                                 visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                 visual_hsize_latched_next = INITIATOR_HSIZE;
                                 visual_zero_strb_next = 1'b0;
                                 setwrcntto1 = INITIATOR_HWRITE;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                              else
                              begin
                                 visual_cycle_in_progress_next = 1'b0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                           else
                           begin
                              int_initiatorARVALID = 1;
                              if (int_initiatorARREADY)
                              begin
                                 visual_cycle_in_progress_next = 1;
                                 INITIATOR_HREADY = 1;
                                 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                 visual_ahb_write_op_next = INITIATOR_HWRITE;
                                 visual_ph_cnt_next = 0;
                                 visual_valid_data_avail_next = 1;
                                 visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                 visual_hsize_latched_next = INITIATOR_HSIZE;
                                 visual_zero_strb_next = 1'b0;
                                 setwrcntto1 = INITIATOR_HWRITE;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                              else
                              begin
                                 visual_cycle_in_progress_next = 1'b0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                        end
                        else
                        begin
                           INITIATOR_HREADY = 1;
                           visual_cycle_in_progress_next = 0;
                           visual_valid_data_avail_next = 0;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                     else if (new_cycle)
                     begin
                        if (INITIATOR_HWRITE)
                        begin
                           int_initiatorAWVALID = 1;
                           if (int_initiatorAWREADY)
                           begin
                              visual_cycle_in_progress_next = 1;
                              INITIATOR_HREADY = 1;
                              visual_latched_exp_burst_len_next = exp_burst_len + 1;
                              visual_ahb_write_op_next = INITIATOR_HWRITE;
                              visual_ph_cnt_next = 0;
                              visual_valid_data_avail_next = 1;
                              visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                              visual_hsize_latched_next = INITIATOR_HSIZE;
                              visual_zero_strb_next = 1'b0;
                              setwrcntto1 = INITIATOR_HWRITE;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                           else
                           begin
                              visual_cycle_in_progress_next = 1'b0;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                        end
                        else
                        begin
                           int_initiatorARVALID = 1;
                           if (int_initiatorARREADY)
                           begin
                              visual_cycle_in_progress_next = 1;
                              INITIATOR_HREADY = 1;
                              visual_latched_exp_burst_len_next = exp_burst_len + 1;
                              visual_ahb_write_op_next = INITIATOR_HWRITE;
                              visual_ph_cnt_next = 0;
                              visual_valid_data_avail_next = 1;
                              visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                              visual_hsize_latched_next = INITIATOR_HSIZE;
                              visual_zero_strb_next = 1'b0;
                              setwrcntto1 = INITIATOR_HWRITE;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                           else
                           begin
                              visual_cycle_in_progress_next = 1'b0;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                        end
                     end
                     else
                     begin
                        INITIATOR_HREADY = 1;
                        visual_cycle_in_progress_next = 0;
                        visual_valid_data_avail_next = 0;
                        visual_AHB_SM_next = DATA_TRANSF;
                     end
                  end
                  else
                  begin
                     visual_AHB_SM_next = AXI_EXTEND;
                  end
               end
               else
               begin
                  visual_AHB_SM_next = AXI_EXTEND;
               end
            end
 
         DATA_TRANSF:
            begin
               INITIATOR_HRDATA = int_initiatorRDATA_hold;
               int_initiatorBREADY = (check_all) ? 1'b0 : 1'b1;
               if (end_cycle)
               begin
                  if (cycle_in_progress)
                  begin
                     if (valid_data_avail)
                     begin
                        if (ahb_write_op)
                        begin
                           int_initiatorWVALID = 1;
                           int_initiatorWLAST = count_match;
                           if (int_initiatorWREADY)
                           begin
                              visual_ph_cnt_next = ph_cnt + 1;
                              if (count_match)
                              begin
                                 if (check_end)
                                 begin
                                    if (ahb_write_op)
                                    begin
                                       int_initiatorBREADY = 1'b1;
                                       if (wrcnt == 0)
                                       begin
                                          if (wrerr)
                                          begin
                                             //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                                             visual_cycle_in_progress_next = 1'b0;
                                             INITIATOR_HRESP = 1'b1;
                                             visual_AHB_SM_next = ERROR;
                                          end
                                          else if (new_cycle)
                                          begin
                                             if (INITIATOR_HWRITE)
                                             begin
                                                int_initiatorAWVALID = 1;
                                                if (int_initiatorAWREADY)
                                                begin
                                                  visual_cycle_in_progress_next = 1;
                                                  INITIATOR_HREADY = 1;
                                                  visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                                  visual_ahb_write_op_next = INITIATOR_HWRITE;
                                                  visual_ph_cnt_next = 0;
                                                  visual_valid_data_avail_next = 1;
                                                  visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                                  visual_hsize_latched_next = INITIATOR_HSIZE;
                                                  visual_zero_strb_next = 1'b0;
                                                  setwrcntto1 = INITIATOR_HWRITE;
                                                  visual_AHB_SM_next = DATA_TRANSF;
                                                end
                                                else
                                                begin
                                                  visual_cycle_in_progress_next = 1'b0;
                                                  visual_AHB_SM_next = DATA_TRANSF;
                                                end
                                             end
                                             else
                                             begin
                                                int_initiatorARVALID = 1;
                                                if (int_initiatorARREADY)
                                                begin
                                                  visual_cycle_in_progress_next = 1;
                                                  INITIATOR_HREADY = 1;
                                                  visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                                  visual_ahb_write_op_next = INITIATOR_HWRITE;
                                                  visual_ph_cnt_next = 0;
                                                  visual_valid_data_avail_next = 1;
                                                  visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                                  visual_hsize_latched_next = INITIATOR_HSIZE;
                                                  visual_zero_strb_next = 1'b0;
                                                  setwrcntto1 = INITIATOR_HWRITE;
                                                  visual_AHB_SM_next = DATA_TRANSF;
                                                end
                                                else
                                                begin
                                                  visual_cycle_in_progress_next = 1'b0;
                                                  visual_AHB_SM_next = DATA_TRANSF;
                                                end
                                             end
                                          end
                                          else
                                          begin
                                             INITIATOR_HREADY = 1;
                                             visual_cycle_in_progress_next = 0;
                                             visual_valid_data_avail_next = 0;
                                             visual_AHB_SM_next = DATA_TRANSF;
                                          end
                                       end
                                       else
                                       begin
                                          visual_AHB_SM_next = WAIT_LAST_BVALID;
                                       end
                                    end
                                    else if (new_cycle)
                                    begin
                                       if (INITIATOR_HWRITE)
                                       begin
                                          int_initiatorAWVALID = 1;
                                          if (int_initiatorAWREADY)
                                          begin
                                             visual_cycle_in_progress_next = 1;
                                             INITIATOR_HREADY = 1;
                                             visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                             visual_ahb_write_op_next = INITIATOR_HWRITE;
                                             visual_ph_cnt_next = 0;
                                             visual_valid_data_avail_next = 1;
                                             visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                             visual_hsize_latched_next = INITIATOR_HSIZE;
                                             visual_zero_strb_next = 1'b0;
                                             setwrcntto1 = INITIATOR_HWRITE;
                                             visual_AHB_SM_next = DATA_TRANSF;
                                          end
                                          else
                                          begin
                                             visual_cycle_in_progress_next = 1'b0;
                                             visual_AHB_SM_next = DATA_TRANSF;
                                          end
                                       end
                                       else
                                       begin
                                          int_initiatorARVALID = 1;
                                          if (int_initiatorARREADY)
                                          begin
                                             visual_cycle_in_progress_next = 1;
                                             INITIATOR_HREADY = 1;
                                             visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                             visual_ahb_write_op_next = INITIATOR_HWRITE;
                                             visual_ph_cnt_next = 0;
                                             visual_valid_data_avail_next = 1;
                                             visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                             visual_hsize_latched_next = INITIATOR_HSIZE;
                                             visual_zero_strb_next = 1'b0;
                                             setwrcntto1 = INITIATOR_HWRITE;
                                             visual_AHB_SM_next = DATA_TRANSF;
                                          end
                                          else
                                          begin
                                             visual_cycle_in_progress_next = 1'b0;
                                             visual_AHB_SM_next = DATA_TRANSF;
                                          end
                                       end
                                    end
                                    else
                                    begin
                                       INITIATOR_HREADY = 1;
                                       visual_cycle_in_progress_next = 0;
                                       visual_valid_data_avail_next = 0;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                 end
                                 else if (new_cycle)
                                 begin
                                    if (INITIATOR_HWRITE)
                                    begin
                                       int_initiatorAWVALID = 1;
                                       if (int_initiatorAWREADY)
                                       begin
                                          visual_cycle_in_progress_next = 1;
                                          INITIATOR_HREADY = 1;
                                          visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                          visual_ahb_write_op_next = INITIATOR_HWRITE;
                                          visual_ph_cnt_next = 0;
                                          visual_valid_data_avail_next = 1;
                                          visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                          visual_hsize_latched_next = INITIATOR_HSIZE;
                                          visual_zero_strb_next = 1'b0;
                                          setwrcntto1 = INITIATOR_HWRITE;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                       else
                                       begin
                                          visual_cycle_in_progress_next = 1'b0;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                    end
                                    else
                                    begin
                                       int_initiatorARVALID = 1;
                                       if (int_initiatorARREADY)
                                       begin
                                          visual_cycle_in_progress_next = 1;
                                          INITIATOR_HREADY = 1;
                                          visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                          visual_ahb_write_op_next = INITIATOR_HWRITE;
                                          visual_ph_cnt_next = 0;
                                          visual_valid_data_avail_next = 1;
                                          visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                          visual_hsize_latched_next = INITIATOR_HSIZE;
                                          visual_zero_strb_next = 1'b0;
                                          setwrcntto1 = INITIATOR_HWRITE;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                       else
                                       begin
                                          visual_cycle_in_progress_next = 1'b0;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                    end
                                 end
                                 else
                                 begin
                                    INITIATOR_HREADY = 1;
                                    visual_cycle_in_progress_next = 0;
                                    visual_valid_data_avail_next = 0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                              else
                              begin
                                 visual_zero_strb_next = 1'b1;
                                 //  AXI data are always valid because we are extending the transaction.
                                 //  We don't rely anymore upon AHB control signals
                                 visual_valid_data_avail_next = 1'b1;
                                 visual_AHB_SM_next = AXI_EXTEND;
                              end
                           end
                           else
                           begin
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                        end
                        else if (int_initiatorRVALID)
                        begin
                           int_initiatorRREADY = 1;
                           INITIATOR_HRDATA = int_initiatorRDATA;
                           visual_int_initiatorRDATA_hold_next = int_initiatorRDATA;
                           INITIATOR_HRESP = int_initiatorRRESP[1];
                           visual_ph_cnt_next = ph_cnt + 1;
                           if (int_initiatorRRESP[1])
                           begin
                              //  AHB transaction is aborted and AXI transaction end only if count_match is asserted.
                              //  If count_match is low, we have to wait all read data from the AXI side and finish up the transaction
                              visual_cycle_in_progress_next = ~(count_match);
                              INITIATOR_HRESP = 1'b1;
                              visual_AHB_SM_next = ERROR;
                           end
                           else if (count_match)
                           begin
                              if (check_end)
                              begin
                                 if (ahb_write_op)
                                 begin
                                    int_initiatorBREADY = 1'b1;
                                    if (wrcnt == 0)
                                    begin
                                       if (wrerr)
                                       begin
                                          //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                                          visual_cycle_in_progress_next = 1'b0;
                                          INITIATOR_HRESP = 1'b1;
                                          visual_AHB_SM_next = ERROR;
                                       end
                                       else if (new_cycle)
                                       begin
                                          if (INITIATOR_HWRITE)
                                          begin
                                             int_initiatorAWVALID = 1;
                                             if (int_initiatorAWREADY)
                                             begin
                                                visual_cycle_in_progress_next = 1;
                                                INITIATOR_HREADY = 1;
                                                visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                                visual_ahb_write_op_next = INITIATOR_HWRITE;
                                                visual_ph_cnt_next = 0;
                                                visual_valid_data_avail_next = 1;
                                                visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                                visual_hsize_latched_next = INITIATOR_HSIZE;
                                                visual_zero_strb_next = 1'b0;
                                                setwrcntto1 = INITIATOR_HWRITE;
                                                visual_AHB_SM_next = DATA_TRANSF;
                                             end
                                             else
                                             begin
                                                visual_cycle_in_progress_next = 1'b0;
                                                visual_AHB_SM_next = DATA_TRANSF;
                                             end
                                          end
                                          else
                                          begin
                                             int_initiatorARVALID = 1;
                                             if (int_initiatorARREADY)
                                             begin
                                                visual_cycle_in_progress_next = 1;
                                                INITIATOR_HREADY = 1;
                                                visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                                visual_ahb_write_op_next = INITIATOR_HWRITE;
                                                visual_ph_cnt_next = 0;
                                                visual_valid_data_avail_next = 1;
                                                visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                                visual_hsize_latched_next = INITIATOR_HSIZE;
                                                visual_zero_strb_next = 1'b0;
                                                setwrcntto1 = INITIATOR_HWRITE;
                                                visual_AHB_SM_next = DATA_TRANSF;
                                             end
                                             else
                                             begin
                                                visual_cycle_in_progress_next = 1'b0;
                                                visual_AHB_SM_next = DATA_TRANSF;
                                             end
                                          end
                                       end
                                       else
                                       begin
                                          INITIATOR_HREADY = 1;
                                          visual_cycle_in_progress_next = 0;
                                          visual_valid_data_avail_next = 0;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                    end
                                    else
                                    begin
                                       visual_AHB_SM_next = WAIT_LAST_BVALID;
                                    end
                                 end
                                 else if (new_cycle)
                                 begin
                                    if (INITIATOR_HWRITE)
                                    begin
                                       int_initiatorAWVALID = 1;
                                       if (int_initiatorAWREADY)
                                       begin
                                          visual_cycle_in_progress_next = 1;
                                          INITIATOR_HREADY = 1;
                                          visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                          visual_ahb_write_op_next = INITIATOR_HWRITE;
                                          visual_ph_cnt_next = 0;
                                          visual_valid_data_avail_next = 1;
                                          visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                          visual_hsize_latched_next = INITIATOR_HSIZE;
                                          visual_zero_strb_next = 1'b0;
                                          setwrcntto1 = INITIATOR_HWRITE;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                       else
                                       begin
                                          visual_cycle_in_progress_next = 1'b0;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                    end
                                    else
                                    begin
                                       int_initiatorARVALID = 1;
                                       if (int_initiatorARREADY)
                                       begin
                                          visual_cycle_in_progress_next = 1;
                                          INITIATOR_HREADY = 1;
                                          visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                          visual_ahb_write_op_next = INITIATOR_HWRITE;
                                          visual_ph_cnt_next = 0;
                                          visual_valid_data_avail_next = 1;
                                          visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                          visual_hsize_latched_next = INITIATOR_HSIZE;
                                          visual_zero_strb_next = 1'b0;
                                          setwrcntto1 = INITIATOR_HWRITE;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                       else
                                       begin
                                          visual_cycle_in_progress_next = 1'b0;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                    end
                                 end
                                 else
                                 begin
                                    INITIATOR_HREADY = 1;
                                    visual_cycle_in_progress_next = 0;
                                    visual_valid_data_avail_next = 0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                              else if (new_cycle)
                              begin
                                 if (INITIATOR_HWRITE)
                                 begin
                                    int_initiatorAWVALID = 1;
                                    if (int_initiatorAWREADY)
                                    begin
                                       visual_cycle_in_progress_next = 1;
                                       INITIATOR_HREADY = 1;
                                       visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                       visual_ahb_write_op_next = INITIATOR_HWRITE;
                                       visual_ph_cnt_next = 0;
                                       visual_valid_data_avail_next = 1;
                                       visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                       visual_hsize_latched_next = INITIATOR_HSIZE;
                                       visual_zero_strb_next = 1'b0;
                                       setwrcntto1 = INITIATOR_HWRITE;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                    else
                                    begin
                                       visual_cycle_in_progress_next = 1'b0;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                 end
                                 else
                                 begin
                                    int_initiatorARVALID = 1;
                                    if (int_initiatorARREADY)
                                    begin
                                       visual_cycle_in_progress_next = 1;
                                       INITIATOR_HREADY = 1;
                                       visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                       visual_ahb_write_op_next = INITIATOR_HWRITE;
                                       visual_ph_cnt_next = 0;
                                       visual_valid_data_avail_next = 1;
                                       visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                       visual_hsize_latched_next = INITIATOR_HSIZE;
                                       visual_zero_strb_next = 1'b0;
                                       setwrcntto1 = INITIATOR_HWRITE;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                    else
                                    begin
                                       visual_cycle_in_progress_next = 1'b0;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                 end
                              end
                              else
                              begin
                                 INITIATOR_HREADY = 1;
                                 visual_cycle_in_progress_next = 0;
                                 visual_valid_data_avail_next = 0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                           else
                           begin
                              visual_zero_strb_next = 1'b1;
                              //  AXI data are always valid because we are extending the transaction.
                              //  We don't rely anymore upon AHB control signals
                              visual_valid_data_avail_next = 1'b1;
                              visual_AHB_SM_next = AXI_EXTEND;
                           end
                        end
                        else
                        begin
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                     else if (count_match)
                     begin
                        if (check_end)
                        begin
                           if (ahb_write_op)
                           begin
                              int_initiatorBREADY = 1'b1;
                              if (wrcnt == 0)
                              begin
                                 if (wrerr)
                                 begin
                                    //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                                    visual_cycle_in_progress_next = 1'b0;
                                    INITIATOR_HRESP = 1'b1;
                                    visual_AHB_SM_next = ERROR;
                                 end
                                 else if (new_cycle)
                                 begin
                                    if (INITIATOR_HWRITE)
                                    begin
                                       int_initiatorAWVALID = 1;
                                       if (int_initiatorAWREADY)
                                       begin
                                          visual_cycle_in_progress_next = 1;
                                          INITIATOR_HREADY = 1;
                                          visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                          visual_ahb_write_op_next = INITIATOR_HWRITE;
                                          visual_ph_cnt_next = 0;
                                          visual_valid_data_avail_next = 1;
                                          visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                          visual_hsize_latched_next = INITIATOR_HSIZE;
                                          visual_zero_strb_next = 1'b0;
                                          setwrcntto1 = INITIATOR_HWRITE;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                       else
                                       begin
                                          visual_cycle_in_progress_next = 1'b0;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                    end
                                    else
                                    begin
                                       int_initiatorARVALID = 1;
                                       if (int_initiatorARREADY)
                                       begin
                                          visual_cycle_in_progress_next = 1;
                                          INITIATOR_HREADY = 1;
                                          visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                          visual_ahb_write_op_next = INITIATOR_HWRITE;
                                          visual_ph_cnt_next = 0;
                                          visual_valid_data_avail_next = 1;
                                          visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                          visual_hsize_latched_next = INITIATOR_HSIZE;
                                          visual_zero_strb_next = 1'b0;
                                          setwrcntto1 = INITIATOR_HWRITE;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                       else
                                       begin
                                          visual_cycle_in_progress_next = 1'b0;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                    end
                                 end
                                 else
                                 begin
                                    INITIATOR_HREADY = 1;
                                    visual_cycle_in_progress_next = 0;
                                    visual_valid_data_avail_next = 0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                              else
                              begin
                                 visual_AHB_SM_next = WAIT_LAST_BVALID;
                              end
                           end
                           else if (new_cycle)
                           begin
                              if (INITIATOR_HWRITE)
                              begin
                                 int_initiatorAWVALID = 1;
                                 if (int_initiatorAWREADY)
                                 begin
                                    visual_cycle_in_progress_next = 1;
                                    INITIATOR_HREADY = 1;
                                    visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                    visual_ahb_write_op_next = INITIATOR_HWRITE;
                                    visual_ph_cnt_next = 0;
                                    visual_valid_data_avail_next = 1;
                                    visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                    visual_hsize_latched_next = INITIATOR_HSIZE;
                                    visual_zero_strb_next = 1'b0;
                                    setwrcntto1 = INITIATOR_HWRITE;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                                 else
                                 begin
                                    visual_cycle_in_progress_next = 1'b0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                              else
                              begin
                                 int_initiatorARVALID = 1;
                                 if (int_initiatorARREADY)
                                 begin
                                    visual_cycle_in_progress_next = 1;
                                    INITIATOR_HREADY = 1;
                                    visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                    visual_ahb_write_op_next = INITIATOR_HWRITE;
                                    visual_ph_cnt_next = 0;
                                    visual_valid_data_avail_next = 1;
                                    visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                    visual_hsize_latched_next = INITIATOR_HSIZE;
                                    visual_zero_strb_next = 1'b0;
                                    setwrcntto1 = INITIATOR_HWRITE;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                                 else
                                 begin
                                    visual_cycle_in_progress_next = 1'b0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                           end
                           else
                           begin
                              INITIATOR_HREADY = 1;
                              visual_cycle_in_progress_next = 0;
                              visual_valid_data_avail_next = 0;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                        end
                        else if (new_cycle)
                        begin
                           if (INITIATOR_HWRITE)
                           begin
                              int_initiatorAWVALID = 1;
                              if (int_initiatorAWREADY)
                              begin
                                 visual_cycle_in_progress_next = 1;
                                 INITIATOR_HREADY = 1;
                                 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                 visual_ahb_write_op_next = INITIATOR_HWRITE;
                                 visual_ph_cnt_next = 0;
                                 visual_valid_data_avail_next = 1;
                                 visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                 visual_hsize_latched_next = INITIATOR_HSIZE;
                                 visual_zero_strb_next = 1'b0;
                                 setwrcntto1 = INITIATOR_HWRITE;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                              else
                              begin
                                 visual_cycle_in_progress_next = 1'b0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                           else
                           begin
                              int_initiatorARVALID = 1;
                              if (int_initiatorARREADY)
                              begin
                                 visual_cycle_in_progress_next = 1;
                                 INITIATOR_HREADY = 1;
                                 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                 visual_ahb_write_op_next = INITIATOR_HWRITE;
                                 visual_ph_cnt_next = 0;
                                 visual_valid_data_avail_next = 1;
                                 visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                 visual_hsize_latched_next = INITIATOR_HSIZE;
                                 visual_zero_strb_next = 1'b0;
                                 setwrcntto1 = INITIATOR_HWRITE;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                              else
                              begin
                                 visual_cycle_in_progress_next = 1'b0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                        end
                        else
                        begin
                           INITIATOR_HREADY = 1;
                           visual_cycle_in_progress_next = 0;
                           visual_valid_data_avail_next = 0;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                     else
                     begin
                        visual_zero_strb_next = 1'b1;
                        //  AXI data are always valid because we are extending the transaction.
                        //  We don't rely anymore upon AHB control signals
                        visual_valid_data_avail_next = 1'b1;
                        visual_AHB_SM_next = AXI_EXTEND;
                     end
                  end
                  else if (new_cycle)
                  begin
                     if (INITIATOR_HWRITE)
                     begin
                        int_initiatorAWVALID = 1;
                        if (int_initiatorAWREADY)
                        begin
                           visual_cycle_in_progress_next = 1;
                           INITIATOR_HREADY = 1;
                           visual_latched_exp_burst_len_next = exp_burst_len + 1;
                           visual_ahb_write_op_next = INITIATOR_HWRITE;
                           visual_ph_cnt_next = 0;
                           visual_valid_data_avail_next = 1;
                           visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                           visual_hsize_latched_next = INITIATOR_HSIZE;
                           visual_zero_strb_next = 1'b0;
                           setwrcntto1 = INITIATOR_HWRITE;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                        else
                        begin
                           visual_cycle_in_progress_next = 1'b0;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                     else
                     begin
                        int_initiatorARVALID = 1;
                        if (int_initiatorARREADY)
                        begin
                           visual_cycle_in_progress_next = 1;
                           INITIATOR_HREADY = 1;
                           visual_latched_exp_burst_len_next = exp_burst_len + 1;
                           visual_ahb_write_op_next = INITIATOR_HWRITE;
                           visual_ph_cnt_next = 0;
                           visual_valid_data_avail_next = 1;
                           visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                           visual_hsize_latched_next = INITIATOR_HSIZE;
                           visual_zero_strb_next = 1'b0;
                           setwrcntto1 = INITIATOR_HWRITE;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                        else
                        begin
                           visual_cycle_in_progress_next = 1'b0;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                  end
                  else
                  begin
                     INITIATOR_HREADY = 1'b1;
                     visual_AHB_SM_next = DATA_TRANSF;
                  end
               end
               else if (check_end)
               begin
                  if (wrcntmax)
                  begin
                     visual_AHB_SM_next = DATA_TRANSF;
                  end
                  else if (valid_data_avail)
                  begin
                     if (ahb_write_op)
                     begin
                        int_initiatorWVALID = 1;
                        int_initiatorWLAST = count_match;
                        if (int_initiatorWREADY)
                        begin
                           visual_ph_cnt_next = ph_cnt + 1;
                           if (BUSY)
                           begin
                              visual_valid_data_avail_next = 0;
                              INITIATOR_HREADY = 1;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                           else if (count_match)
                           begin
                              if (INITIATOR_HWRITE)
                              begin
                                 if (check_all)
                                 begin
                                    if (wrcnt[0] == 0)
                                    begin
                                       int_initiatorAWVALID = 1;
                                       if (int_initiatorAWREADY)
                                       begin
                                          visual_ph_cnt_next = 0;
                                          INITIATOR_HREADY = 1;
                                          visual_valid_data_avail_next = 1;
										  visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                          visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                          visual_hsize_latched_next = INITIATOR_HSIZE;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                       else
                                       begin
                                          visual_valid_data_avail_next = 1'b0;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                    end
                                    else
                                    begin
                                       int_initiatorBREADY = 1'b1;
                                       if (int_initiatorBVALID)
                                       begin
                                          if (int_initiatorBRESP[1])
                                          begin
                                             //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                                             visual_cycle_in_progress_next = 1'b0;
                                             INITIATOR_HRESP = 1'b1;
                                             visual_AHB_SM_next = ERROR;
                                          end
                                          else
                                          begin
                                             int_initiatorAWVALID = 1;
                                             if (int_initiatorAWREADY)
                                             begin
                                                visual_ph_cnt_next = 0;
                                                INITIATOR_HREADY = 1;
                                                visual_valid_data_avail_next = 1;
												visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                                visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                                visual_hsize_latched_next = INITIATOR_HSIZE;
                                                visual_AHB_SM_next = DATA_TRANSF;
                                             end
                                             else
                                             begin
                                                visual_valid_data_avail_next = 1'b0;
                                                visual_AHB_SM_next = DATA_TRANSF;
                                             end
                                          end
                                       end
                                       else
                                       begin
                                          visual_AHB_SM_next = WAIT_BVALID;
                                       end
                                    end
                                 end
                                 else
                                 begin
                                    int_initiatorAWVALID = 1;
                                    if (int_initiatorAWREADY)
                                    begin
                                       visual_ph_cnt_next = 0;
                                       INITIATOR_HREADY = 1;
                                       visual_valid_data_avail_next = 1;
									   visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                       visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                       visual_hsize_latched_next = INITIATOR_HSIZE;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                    else
                                    begin
                                       visual_valid_data_avail_next = 1'b0;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                 end
                              end
                              else
                              begin
                                 int_initiatorARVALID = 1;
                                 if (int_initiatorARREADY)
                                 begin
                                    visual_ph_cnt_next = 0;
                                    INITIATOR_HREADY = 1;
                                    visual_valid_data_avail_next = 1;
									visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                    visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                    visual_hsize_latched_next = INITIATOR_HSIZE;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                                 else
                                 begin
                                    visual_valid_data_avail_next = 1'b0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                           end
                           else
                           begin
                              INITIATOR_HREADY = 1;
                              visual_valid_data_avail_next = 1;
                              visual_haddr_latched_next = INITIATOR_HADDR[5:0];
                              visual_hsize_latched_next = INITIATOR_HSIZE;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                        end
                        else
                        begin
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                     else if (int_initiatorRVALID)
                     begin
                        int_initiatorRREADY = 1;
                        INITIATOR_HRDATA = int_initiatorRDATA;
                        visual_int_initiatorRDATA_hold_next = int_initiatorRDATA;
                        visual_ph_cnt_next = ph_cnt + 1;
                        if (int_initiatorRRESP[1])
                        begin
                           //  AHB transaction is aborted and AXI transaction end only if count_match is asserted.
                           //  If count_match is low, we have to wait all read data from the AXI side and finish up the transaction
                           visual_cycle_in_progress_next = ~(count_match);
                           INITIATOR_HRESP = 1'b1;
                           visual_AHB_SM_next = ERROR;
                        end
                        else if (BUSY)
                        begin
                           visual_valid_data_avail_next = 0;
                           INITIATOR_HREADY = 1;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                        else if (count_match)
                        begin
                           if (INITIATOR_HWRITE)
                           begin
                              if (check_all)
                              begin
                                 if (wrcnt[0] == 0)
                                 begin
                                    int_initiatorAWVALID = 1;
                                    if (int_initiatorAWREADY)
                                    begin
                                       visual_ph_cnt_next = 0;
                                       INITIATOR_HREADY = 1;
                                       visual_valid_data_avail_next = 1;
									   visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                       visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                       visual_hsize_latched_next = INITIATOR_HSIZE;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                    else
                                    begin
                                       visual_valid_data_avail_next = 1'b0;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                 end
                                 else
                                 begin
                                    int_initiatorBREADY = 1'b1;
                                    if (int_initiatorBVALID)
                                    begin
                                       if (int_initiatorBRESP[1])
                                       begin
                                          //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                                          visual_cycle_in_progress_next = 1'b0;
                                          INITIATOR_HRESP = 1'b1;
                                          visual_AHB_SM_next = ERROR;
                                       end
                                       else
                                       begin
                                          int_initiatorAWVALID = 1;
                                          if (int_initiatorAWREADY)
                                          begin
                                             visual_ph_cnt_next = 0;
                                             INITIATOR_HREADY = 1;
                                             visual_valid_data_avail_next = 1;
											 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                             visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                             visual_hsize_latched_next = INITIATOR_HSIZE;
                                             visual_AHB_SM_next = DATA_TRANSF;
                                          end
                                          else
                                          begin
                                             visual_valid_data_avail_next = 1'b0;
                                             visual_AHB_SM_next = DATA_TRANSF;
                                          end
                                       end
                                    end
                                    else
                                    begin
                                       visual_AHB_SM_next = WAIT_BVALID;
                                    end
                                 end
                              end
                              else
                              begin
                                 int_initiatorAWVALID = 1;
                                 if (int_initiatorAWREADY)
                                 begin
                                    visual_ph_cnt_next = 0;
                                    INITIATOR_HREADY = 1;
                                    visual_valid_data_avail_next = 1;
									visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                    visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                    visual_hsize_latched_next = INITIATOR_HSIZE;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                                 else
                                 begin
                                    visual_valid_data_avail_next = 1'b0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                           end
                           else
                           begin
                              int_initiatorARVALID = 1;
                              if (int_initiatorARREADY)
                              begin
                                 visual_ph_cnt_next = 0;
                                 INITIATOR_HREADY = 1;
                                 visual_valid_data_avail_next = 1;
								 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                 visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                 visual_hsize_latched_next = INITIATOR_HSIZE;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                              else
                              begin
                                 visual_valid_data_avail_next = 1'b0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                        end
                        else
                        begin
                           INITIATOR_HREADY = 1;
                           visual_valid_data_avail_next = 1;
                           visual_haddr_latched_next = INITIATOR_HADDR[5:0];
                           visual_hsize_latched_next = INITIATOR_HSIZE;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                     else
                     begin
                        visual_AHB_SM_next = DATA_TRANSF;
                     end
                  end
                  else if (BUSY)
                  begin
                     visual_valid_data_avail_next = 0;
                     INITIATOR_HREADY = 1;
                     visual_AHB_SM_next = DATA_TRANSF;
                  end
                  else if (count_match)
                  begin
                     if (INITIATOR_HWRITE)
                     begin
                        if (check_all)
                        begin
                           if (wrcnt[0] == 0)
                           begin
                              int_initiatorAWVALID = 1;
                              if (int_initiatorAWREADY)
                              begin
                                 visual_ph_cnt_next = 0;
                                 INITIATOR_HREADY = 1;
                                 visual_valid_data_avail_next = 1;
								 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                 visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                 visual_hsize_latched_next = INITIATOR_HSIZE;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                              else
                              begin
                                 visual_valid_data_avail_next = 1'b0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                           else
                           begin
                              int_initiatorBREADY = 1'b1;
                              if (int_initiatorBVALID)
                              begin
                                 if (int_initiatorBRESP[1])
                                 begin
                                    //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                                    visual_cycle_in_progress_next = 1'b0;
                                    INITIATOR_HRESP = 1'b1;
                                    visual_AHB_SM_next = ERROR;
                                 end
                                 else
                                 begin
                                    int_initiatorAWVALID = 1;
                                    if (int_initiatorAWREADY)
                                    begin
                                       visual_ph_cnt_next = 0;
                                       INITIATOR_HREADY = 1;
                                       visual_valid_data_avail_next = 1;
									   visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                       visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                       visual_hsize_latched_next = INITIATOR_HSIZE;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                    else
                                    begin
                                       visual_valid_data_avail_next = 1'b0;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                 end
                              end
                              else
                              begin
                                 visual_AHB_SM_next = WAIT_BVALID;
                              end
                           end
                        end
                        else
                        begin
                           int_initiatorAWVALID = 1;
                           if (int_initiatorAWREADY)
                           begin
                              visual_ph_cnt_next = 0;
                              INITIATOR_HREADY = 1;
                              visual_valid_data_avail_next = 1;
							  visual_latched_exp_burst_len_next = exp_burst_len + 1;
                              visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                              visual_hsize_latched_next = INITIATOR_HSIZE;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                           else
                           begin
                              visual_valid_data_avail_next = 1'b0;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                        end
                     end
                     else
                     begin
                        int_initiatorARVALID = 1;
                        if (int_initiatorARREADY)
                        begin
                           visual_ph_cnt_next = 0;
                           INITIATOR_HREADY = 1;
                           visual_valid_data_avail_next = 1;
						   visual_latched_exp_burst_len_next = exp_burst_len + 1;
                           visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                           visual_hsize_latched_next = INITIATOR_HSIZE;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                        else
                        begin
                           visual_valid_data_avail_next = 1'b0;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                  end
                  else
                  begin
                     INITIATOR_HREADY = 1;
                     visual_valid_data_avail_next = 1;
                     visual_haddr_latched_next = INITIATOR_HADDR[5:0];
                     visual_hsize_latched_next = INITIATOR_HSIZE;
                     visual_AHB_SM_next = DATA_TRANSF;
                  end
               end
               else if (valid_data_avail)
               begin
                  if (ahb_write_op)
                  begin
                     int_initiatorWVALID = 1;
                     int_initiatorWLAST = count_match;
                     if (int_initiatorWREADY)
                     begin
                        visual_ph_cnt_next = ph_cnt + 1;
                        if (BUSY)
                        begin
                           visual_valid_data_avail_next = 0;
                           INITIATOR_HREADY = 1;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                        else if (count_match)
                        begin
                           if (INITIATOR_HWRITE)
                           begin
                              if (check_all)
                              begin
                                 if (wrcnt[0] == 0)
                                 begin
                                    int_initiatorAWVALID = 1;
                                    if (int_initiatorAWREADY)
                                    begin
                                       visual_ph_cnt_next = 0;
                                       INITIATOR_HREADY = 1;
                                       visual_valid_data_avail_next = 1;
									   visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                       visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                       visual_hsize_latched_next = INITIATOR_HSIZE;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                    else
                                    begin
                                       visual_valid_data_avail_next = 1'b0;
                                       visual_AHB_SM_next = DATA_TRANSF;
                                    end
                                 end
                                 else
                                 begin
                                    int_initiatorBREADY = 1'b1;
                                    if (int_initiatorBVALID)
                                    begin
                                       if (int_initiatorBRESP[1])
                                       begin
                                          //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                                          visual_cycle_in_progress_next = 1'b0;
                                          INITIATOR_HRESP = 1'b1;
                                          visual_AHB_SM_next = ERROR;
                                       end
                                       else
                                       begin
                                          int_initiatorAWVALID = 1;
                                          if (int_initiatorAWREADY)
                                          begin
                                             visual_ph_cnt_next = 0;
                                             INITIATOR_HREADY = 1;
                                             visual_valid_data_avail_next = 1;
											 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                             visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                             visual_hsize_latched_next = INITIATOR_HSIZE;
                                             visual_AHB_SM_next = DATA_TRANSF;
                                          end
                                          else
                                          begin
                                             visual_valid_data_avail_next = 1'b0;
                                             visual_AHB_SM_next = DATA_TRANSF;
                                          end
                                       end
                                    end
                                    else
                                    begin
                                       visual_AHB_SM_next = WAIT_BVALID;
                                    end
                                 end
                              end
                              else
                              begin
                                 int_initiatorAWVALID = 1;
                                 if (int_initiatorAWREADY)
                                 begin
                                    visual_ph_cnt_next = 0;
                                    INITIATOR_HREADY = 1;
                                    visual_valid_data_avail_next = 1;
									visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                    visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                    visual_hsize_latched_next = INITIATOR_HSIZE;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                                 else
                                 begin
                                    visual_valid_data_avail_next = 1'b0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                           end
                           else
                           begin
                              int_initiatorARVALID = 1;
                              if (int_initiatorARREADY)
                              begin
                                 visual_ph_cnt_next = 0;
                                 INITIATOR_HREADY = 1;
                                 visual_valid_data_avail_next = 1;
								 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                 visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                 visual_hsize_latched_next = INITIATOR_HSIZE;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                              else
                              begin
                                 visual_valid_data_avail_next = 1'b0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                        end
                        else
                        begin
                           INITIATOR_HREADY = 1;
                           visual_valid_data_avail_next = 1;
                           visual_haddr_latched_next = INITIATOR_HADDR[5:0];
                           visual_hsize_latched_next = INITIATOR_HSIZE;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                     else
                     begin
                        visual_AHB_SM_next = DATA_TRANSF;
                     end
                  end
                  else if (int_initiatorRVALID)
                  begin
                     int_initiatorRREADY = 1;
                     INITIATOR_HRDATA = int_initiatorRDATA;
                     visual_int_initiatorRDATA_hold_next = int_initiatorRDATA;
                     visual_ph_cnt_next = ph_cnt + 1;
                     if (int_initiatorRRESP[1])
                     begin
                        //  AHB transaction is aborted and AXI transaction end only if count_match is asserted.
                        //  If count_match is low, we have to wait all read data from the AXI side and finish up the transaction
                        visual_cycle_in_progress_next = ~(count_match);
                        INITIATOR_HRESP = 1'b1;
                        visual_AHB_SM_next = ERROR;
                     end
                     else if (BUSY)
                     begin
                        visual_valid_data_avail_next = 0;
                        INITIATOR_HREADY = 1;
                        visual_AHB_SM_next = DATA_TRANSF;
                     end
                     else if (count_match)
                     begin
                        if (INITIATOR_HWRITE)
                        begin
                           if (check_all)
                           begin
                              if (wrcnt[0] == 0)
                              begin
                                 int_initiatorAWVALID = 1;
                                 if (int_initiatorAWREADY)
                                 begin
                                    visual_ph_cnt_next = 0;
                                    INITIATOR_HREADY = 1;
                                    visual_valid_data_avail_next = 1;
									visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                    visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                    visual_hsize_latched_next = INITIATOR_HSIZE;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                                 else
                                 begin
                                    visual_valid_data_avail_next = 1'b0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                              else
                              begin
                                 int_initiatorBREADY = 1'b1;
                                 if (int_initiatorBVALID)
                                 begin
                                    if (int_initiatorBRESP[1])
                                    begin
                                       //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                                       visual_cycle_in_progress_next = 1'b0;
                                       INITIATOR_HRESP = 1'b1;
                                       visual_AHB_SM_next = ERROR;
                                    end
                                    else
                                    begin
                                       int_initiatorAWVALID = 1;
                                       if (int_initiatorAWREADY)
                                       begin
                                          visual_ph_cnt_next = 0;
                                          INITIATOR_HREADY = 1;
                                          visual_valid_data_avail_next = 1;
										  visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                          visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                          visual_hsize_latched_next = INITIATOR_HSIZE;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                       else
                                       begin
                                          visual_valid_data_avail_next = 1'b0;
                                          visual_AHB_SM_next = DATA_TRANSF;
                                       end
                                    end
                                 end
                                 else
                                 begin
                                    visual_AHB_SM_next = WAIT_BVALID;
                                 end
                              end
                           end
                           else
                           begin
                              int_initiatorAWVALID = 1;
                              if (int_initiatorAWREADY)
                              begin
                                 visual_ph_cnt_next = 0;
                                 INITIATOR_HREADY = 1;
                                 visual_valid_data_avail_next = 1;
								 visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                 visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                 visual_hsize_latched_next = INITIATOR_HSIZE;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                              else
                              begin
                                 visual_valid_data_avail_next = 1'b0;
                                 visual_AHB_SM_next = DATA_TRANSF;
                              end
                           end
                        end
                        else
                        begin
                           int_initiatorARVALID = 1;
                           if (int_initiatorARREADY)
                           begin
                              visual_ph_cnt_next = 0;
                              INITIATOR_HREADY = 1;
                              visual_valid_data_avail_next = 1;
							  visual_latched_exp_burst_len_next = exp_burst_len + 1;
                              visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                              visual_hsize_latched_next = INITIATOR_HSIZE;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                           else
                           begin
                              visual_valid_data_avail_next = 1'b0;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                        end
                     end
                     else
                     begin
                        INITIATOR_HREADY = 1;
                        visual_valid_data_avail_next = 1;
                        visual_haddr_latched_next = INITIATOR_HADDR[5:0];
                        visual_hsize_latched_next = INITIATOR_HSIZE;
                        visual_AHB_SM_next = DATA_TRANSF;
                     end
                  end
                  else
                  begin
                     visual_AHB_SM_next = DATA_TRANSF;
                  end
               end
               else if (BUSY)
               begin
                  visual_valid_data_avail_next = 0;
                  INITIATOR_HREADY = 1;
                  visual_AHB_SM_next = DATA_TRANSF;
               end
               else if (count_match)
               begin
                  if (INITIATOR_HWRITE)
                  begin
                     if (check_all)
                     begin
                        if (wrcnt[0] == 0)
                        begin
                           int_initiatorAWVALID = 1;
                           if (int_initiatorAWREADY)
                           begin
                              visual_ph_cnt_next = 0;
                              INITIATOR_HREADY = 1;
                              visual_valid_data_avail_next = 1;
							  visual_latched_exp_burst_len_next = exp_burst_len + 1;
                              visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                              visual_hsize_latched_next = INITIATOR_HSIZE;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                           else
                           begin
                              visual_valid_data_avail_next = 1'b0;
                              visual_AHB_SM_next = DATA_TRANSF;
                           end
                        end
                        else
                        begin
                           int_initiatorBREADY = 1'b1;
                           if (int_initiatorBVALID)
                           begin
                              if (int_initiatorBRESP[1])
                              begin
                                 //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                                 visual_cycle_in_progress_next = 1'b0;
                                 INITIATOR_HRESP = 1'b1;
                                 visual_AHB_SM_next = ERROR;
                              end
                              else
                              begin
                                 int_initiatorAWVALID = 1;
                                 if (int_initiatorAWREADY)
                                 begin
                                    visual_ph_cnt_next = 0;
                                    INITIATOR_HREADY = 1;
                                    visual_valid_data_avail_next = 1;
									visual_latched_exp_burst_len_next = exp_burst_len + 1;
                                    visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                                    visual_hsize_latched_next = INITIATOR_HSIZE;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                                 else
                                 begin
                                    visual_valid_data_avail_next = 1'b0;
                                    visual_AHB_SM_next = DATA_TRANSF;
                                 end
                              end
                           end
                           else
                           begin
                              visual_AHB_SM_next = WAIT_BVALID;
                           end
                        end
                     end
                     else
                     begin
                        int_initiatorAWVALID = 1;
                        if (int_initiatorAWREADY)
                        begin
                           visual_ph_cnt_next = 0;
                           INITIATOR_HREADY = 1;
                           visual_valid_data_avail_next = 1;
						   visual_latched_exp_burst_len_next = exp_burst_len + 1;
                           visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                           visual_hsize_latched_next = INITIATOR_HSIZE;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                        else
                        begin
                           visual_valid_data_avail_next = 1'b0;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                  end
                  else
                  begin
                     int_initiatorARVALID = 1;
                     if (int_initiatorARREADY)
                     begin
                        visual_ph_cnt_next = 0;
                        INITIATOR_HREADY = 1;
                        visual_valid_data_avail_next = 1;
						visual_latched_exp_burst_len_next = exp_burst_len + 1;
                        visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                        visual_hsize_latched_next = INITIATOR_HSIZE;
                        visual_AHB_SM_next = DATA_TRANSF;
                     end
                     else
                     begin
                        visual_valid_data_avail_next = 1'b0;
                        visual_AHB_SM_next = DATA_TRANSF;
                     end
                  end
               end
               else
               begin
                  INITIATOR_HREADY = 1;
                  visual_valid_data_avail_next = 1;
                  visual_haddr_latched_next = INITIATOR_HADDR[5:0];
                  visual_hsize_latched_next = INITIATOR_HSIZE;
                  visual_AHB_SM_next = DATA_TRANSF;
               end
            end
 
         ERROR:
            begin
               visual_valid_data_avail_next = 1'b0;
               INITIATOR_HRESP = 1'b1;
               INITIATOR_HREADY = 1'b1;
               visual_AHB_SM_next = DATA_TRANSF;
            end
 
         WAIT_BVALID:
            begin
               int_initiatorBREADY = 1'b1;
               if (int_initiatorBVALID)
               begin
                  if (int_initiatorBRESP[1])
                  begin
                     //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                     visual_cycle_in_progress_next = 1'b0;
                     INITIATOR_HRESP = 1'b1;
                     visual_AHB_SM_next = ERROR;
                  end
                  else
                  begin
                     int_initiatorAWVALID = 1;
                     if (int_initiatorAWREADY)
                     begin
                        visual_ph_cnt_next = 0;
                        INITIATOR_HREADY = 1;
                        visual_valid_data_avail_next = 1;
						visual_latched_exp_burst_len_next = exp_burst_len + 1;
                        visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                        visual_hsize_latched_next = INITIATOR_HSIZE;
                        visual_AHB_SM_next = DATA_TRANSF;
                     end
                     else
                     begin
                        visual_valid_data_avail_next = 1'b0;
                        visual_AHB_SM_next = DATA_TRANSF;
                     end
                  end
               end
               else
               begin
                  visual_AHB_SM_next = WAIT_BVALID;
               end
            end
 
         WAIT_LAST_BVALID:
            begin
               int_initiatorBREADY = 1'b1;
               if (wrcnt == 0)
               begin
                  if (wrerr)
                  begin
                     //  AXI is completed and AHB transaction aborted. Next time around no cyckle will be in progress
                     visual_cycle_in_progress_next = 1'b0;
                     INITIATOR_HRESP = 1'b1;
                     visual_AHB_SM_next = ERROR;
                  end
                  else if (new_cycle)
                  begin
                     if (INITIATOR_HWRITE)
                     begin
                        int_initiatorAWVALID = 1;
                        if (int_initiatorAWREADY)
                        begin
                           visual_cycle_in_progress_next = 1;
                           INITIATOR_HREADY = 1;
                           visual_latched_exp_burst_len_next = exp_burst_len + 1;
                           visual_ahb_write_op_next = INITIATOR_HWRITE;
                           visual_ph_cnt_next = 0;
                           visual_valid_data_avail_next = 1;
                           visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                           visual_hsize_latched_next = INITIATOR_HSIZE;
                           visual_zero_strb_next = 1'b0;
                           setwrcntto1 = INITIATOR_HWRITE;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                        else
                        begin
                           visual_cycle_in_progress_next = 1'b0;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                     else
                     begin
                        int_initiatorARVALID = 1;
                        if (int_initiatorARREADY)
                        begin
                           visual_cycle_in_progress_next = 1;
                           INITIATOR_HREADY = 1;
                           visual_latched_exp_burst_len_next = exp_burst_len + 1;
                           visual_ahb_write_op_next = INITIATOR_HWRITE;
                           visual_ph_cnt_next = 0;
                           visual_valid_data_avail_next = 1;
                           visual_haddr_latched_next = INITIATOR_HADDR[LOG_BYTE_WIDTH - 1:0];
                           visual_hsize_latched_next = INITIATOR_HSIZE;
                           visual_zero_strb_next = 1'b0;
                           setwrcntto1 = INITIATOR_HWRITE;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                        else
                        begin
                           visual_cycle_in_progress_next = 1'b0;
                           visual_AHB_SM_next = DATA_TRANSF;
                        end
                     end
                  end
                  else
                  begin
                     INITIATOR_HREADY = 1;
                     visual_cycle_in_progress_next = 0;
                     visual_valid_data_avail_next = 0;
                     visual_AHB_SM_next = DATA_TRANSF;
                  end
               end
               else
               begin
                  visual_AHB_SM_next = WAIT_LAST_BVALID;
               end
            end
 
         default:
            begin
               visual_AHB_SM_next = DATA_TRANSF;
            end
      endcase
   end
 
   always  @(posedge ACLK or negedge iarst_sync)
   begin : caxi4interconnect_AHB_SM
 
      if(~iarst_sync | ~isrst_sync)
      begin
         cycle_in_progress <= 0;
         latched_exp_burst_len <= 0;
         ahb_write_op <= 0;
         ph_cnt <= 0;
         valid_data_avail <= 0;
         haddr_latched <= 0;
         hsize_latched <= 0;
         zero_strb <= 0;
         int_initiatorRDATA_hold <= 'h0;
         visual_AHB_SM_current <= DATA_TRANSF;
      end
      else
      begin
         ph_cnt <= visual_ph_cnt_next;
         ahb_write_op <= visual_ahb_write_op_next;
         latched_exp_burst_len <= visual_latched_exp_burst_len_next;
         cycle_in_progress <= visual_cycle_in_progress_next;
         int_initiatorRDATA_hold <= visual_int_initiatorRDATA_hold_next;
         haddr_latched <= visual_haddr_latched_next;
         hsize_latched <= visual_hsize_latched_next;
         valid_data_avail <= visual_valid_data_avail_next;
         zero_strb <= visual_zero_strb_next;
         visual_AHB_SM_current <= visual_AHB_SM_next;
      end
   end
 
 
 
   always  @(zero_strb or initiatorSTRB)
   begin   :strb_gen
 
      if (zero_strb)
      begin
         int_initiatorWSTRB = 0;
      end
      else
      begin
         int_initiatorWSTRB = initiatorSTRB;
      end
   end
 
 
 
   always @( posedge ACLK or negedge iarst_sync )
   begin   :bresp_cnt
 
      if(~iarst_sync | ~isrst_sync)
      begin
         wrcnt <= 'h0;
         wrerr <= 1'b0;
      end
      else
      begin
         if (setwrcntto1)
         begin
            wrcnt <= 'h1;
            wrerr <= 1'b0;
         end
         else
         begin
            if (incrwrcnt)
            begin
               if (decwrcnt)
               begin
                  wrerr <= (wrerr & checkendonly) | int_initiatorBRESP[1];
               end
               else
               begin
                  wrcnt <= wrcnt + 1;
               end
            end
            else
            begin
               if (decwrcnt)
               begin
                  wrerr <= (wrerr & checkendonly) | int_initiatorBRESP[1];
                  wrcnt <= wrcnt - 1;
               end
            end
         end
      end
   end
 
 
 
   always @( posedge ACLK or negedge iarst_sync )
   begin   :ph_plus_1_gen
 
      if(~iarst_sync | ~isrst_sync)
      begin
         ph_cnt_plus_1 <= 0;
      end
      else
      begin
         ph_cnt_plus_1 <= (visual_ph_cnt_next + 1'b1);
      end
   end
 
           // Write Data Channel
           assign int_initiatorWDATA = INITIATOR_HWDATA;
           assign int_initiatorWUSER = 'b0;
 
           // Write Address Channel
		   generate
		   if(ADDR_WIDTH > 'd32) begin
		       assign int_initiatorAWADDR = {{(ADDR_WIDTH-32){1'b0}}, INITIATOR_HADDR};
		   end else begin
		       assign int_initiatorAWADDR = INITIATOR_HADDR[ADDR_WIDTH-1:0];  
		   end
           endgenerate 
           assign int_initiatorAWSIZE = INITIATOR_HSIZE;
           assign int_initiatorAWID = 'b0;
           assign int_initiatorAWQOS = 'b0;
           assign int_initiatorAWREGION = 'b0;
           assign int_initiatorAWUSER = 'b0;
           assign int_initiatorAWCACHE = {INITIATOR_HPROT[5], INITIATOR_HPROT[5], INITIATOR_HPROT[3], INITIATOR_HPROT[2]};
           assign int_initiatorAWLOCK = { 1'b0, INITIATOR_HMASTLOCK};
           assign int_initiatorAWLEN = exp_burst_len;
           assign int_initiatorAWBURST = ((INITIATOR_HBURST[2:1] == 2'b00) || (INITIATOR_HBURST[0] == 1'b1)) ? 2'h1 : 2'h2;
           assign int_initiatorAWPROT = {~INITIATOR_HPROT[0], INITIATOR_HNONSEC, INITIATOR_HPROT[1]};
 
           // Read Address Channel
		   generate
		   if(ADDR_WIDTH > 'd32) begin
		       assign int_initiatorARADDR = {{(ADDR_WIDTH-32){1'b0}}, INITIATOR_HADDR};
		   end else begin
		       assign int_initiatorARADDR = INITIATOR_HADDR[ADDR_WIDTH-1:0];  
		   end
           endgenerate 
		   

           assign int_initiatorARSIZE = INITIATOR_HSIZE;
           assign int_initiatorARID = 'b0;
           assign int_initiatorARQOS = 'b0;
           assign int_initiatorARREGION = 'b0;
           assign int_initiatorARUSER = 'b0;
           assign int_initiatorARCACHE = {INITIATOR_HPROT[5], INITIATOR_HPROT[5], INITIATOR_HPROT[3], INITIATOR_HPROT[2]};
           assign int_initiatorARLOCK = { 1'b0, INITIATOR_HMASTLOCK};
           assign int_initiatorARLEN = exp_burst_len;
           assign int_initiatorARBURST = ((INITIATOR_HBURST[2:1] == 2'b00) || (INITIATOR_HBURST[0] == 1'b1)) ? 2'h1 : 2'h2;
           assign int_initiatorARPROT = {~INITIATOR_HPROT[0], INITIATOR_HNONSEC, INITIATOR_HPROT[1]};
 
           //assign count_match = ((ph_cnt + valid_data_avail) == latched_exp_burst_len);
           assign count_match = ((valid_data_avail ? ph_cnt_plus_1 : ph_cnt) == latched_exp_burst_len);
 
           assign SEQ = (INITIATOR_HTRANS == 2'b11);
           assign NONSEQ = (INITIATOR_HTRANS == 2'b10);
           assign BUSY = (INITIATOR_HTRANS == 2'b01);
        	assign IDLE = (INITIATOR_HTRANS == 2'b00);
 
 
           // compute burst length
           always @(*) begin
                   if (INITIATOR_HBURST[2:1] == 2'b01) begin
                           exp_burst_len = 8'h3;   // INCR4 or WRAP4
                   end
                   else if (INITIATOR_HBURST[2:1] == 2'b10) begin
                           exp_burst_len = 8'h7;   // INCR8 or WRAP8
                   end
                   else if (INITIATOR_HBURST[2:1] == 2'b11) begin
                           exp_burst_len = 8'hf;   // INCR16 or WRAP16
                   end
                   else if (INITIATOR_HBURST == 3'b000) begin
                           exp_burst_len = 8'h0;   // SINGLE
                   end
                   else if (INITIATOR_HBURST == 3'b001) begin
				     if(axi_cross_4kaddr)
					       exp_burst_len = (axi_len_limit >> INITIATOR_HSIZE)-1;  // INCR (undefined length)
					 else
                           exp_burst_len = DEF_BURST_LEN[7:0];  // INCR (undefined length)
                   end
                   else begin
                           exp_burst_len = 8'h00;
                   end
           end
 
   	assign end_cycle = NONSEQ | IDLE ;
   	assign new_cycle = INITIATOR_HSEL & NONSEQ;
   	
   	assign size_bytes = 1 << hsize_latched; // 4 for a 32-bit transfer size
   	assign pre_shifted_strobes = (1 << size_bytes) - 1; // 0xF for a 32-bit transfer size
   	assign num_of_bytes_to_shift = haddr_latched; // haddr_latched[2:0] for a 64 bit bus
   	assign initiatorSTRB = pre_shifted_strobes << num_of_bytes_to_shift; // 0xF0 for 32-bit transfer size and haddr_latched equal to 0x4 on a 64-bit bus
   	
   	assign check_end = BRESP_CHECK_MODE[1];
   	assign check_all = (BRESP_CHECK_MODE == 2'b11);
   	assign checkendonly = (BRESP_CHECK_MODE == 2'b10);
   	
   	assign wrcntmax = (wrcnt == ((2**(BRESP_CNT_WIDTH)) - 1));
   	assign incrwrcnt = int_initiatorAWVALID && int_initiatorAWREADY;
   	assign decwrcnt = int_initiatorBREADY && int_initiatorBVALID;
	assign int_initiatorWID = 0;
	
	assign axi_len_limit      = (1<<12) - int_initiatorAWADDR[11:0]; 
	assign defburst_len_bytes = ((DEF_BURST_LEN[7:0] + 1) << INITIATOR_HSIZE);
	assign axi_cross_4kaddr   = (defburst_len_bytes > axi_len_limit);	
	
 
 
endmodule

