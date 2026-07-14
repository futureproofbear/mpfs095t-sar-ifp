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
// SVN $Revision: 51335 $
// SVN $Date: 2026-04-24 18:00:00 +0530 (Fri, 24 Apr 2026) $
//
//
// *********************************************************************/
`timescale 1ns / 1ns
 
 
module caxi4interconnect_DWC_DownConv_widthConvwr (
                                 //  input ports
                                 ACLK,
                                 arst_sync,
                                 srst_sync,
                                 INITIATOR_WSTRB,
                                 INITIATOR_WUSER,
								 INITIATOR_WID,
                                 INITIATOR_WDATA,
                                 INITIATOR_WVALID,
                                 wrCmdFifoEmpty,
                                 wrCmdFifoRdData,
                                 TARGET_WREADY,
                                 targetLEN_M1,
                                 initiator_ADDR_masked,
                                 second_Beat_Addr,
                                 sizeCnt_comb_EQ_SizeMax,
                                 sizeCnt_comb_P1,
                                 //  output ports
                                 INITIATOR_WREADY,
                                 wrCmdFifore,
								 TARGET_WID,
                                 TARGET_WVALID,
                                 TARGET_WLAST,
                                 TARGET_WUSER,
                                 TARGET_WDATA,
                                 TARGET_WSTRB
                                 );
 
   parameter        DATA_WIDTH_IN             = 64;
   parameter        DATA_WIDTH_OUT            = 32;
   parameter        USER_WIDTH                = 1;
   parameter        CMD_FIFO_DATA_WIDTH       = 30;
   parameter        STRB_WIDTH_IN             = 8;
   parameter        STRB_WIDTH_OUT            = 4;
   parameter        ID_WIDTH                  = 0;
//  input ports
   input            ACLK;
   wire             ACLK;
   input            arst_sync;
   input            srst_sync;
   wire             arst_sync;
   input     [STRB_WIDTH_IN - 1:0] INITIATOR_WSTRB;
   wire      [STRB_WIDTH_IN - 1:0] INITIATOR_WSTRB;
   input     [USER_WIDTH - 1:0] INITIATOR_WUSER;
   wire      [USER_WIDTH - 1:0] INITIATOR_WUSER;
   input     [ID_WIDTH-1:0]        INITIATOR_WID;
   input     [DATA_WIDTH_IN - 1:0] INITIATOR_WDATA;
   wire      [DATA_WIDTH_IN - 1:0] INITIATOR_WDATA;
   input            INITIATOR_WVALID;
   wire             INITIATOR_WVALID;
   input            wrCmdFifoEmpty;
   wire             wrCmdFifoEmpty;
   input     [CMD_FIFO_DATA_WIDTH - 1:0] wrCmdFifoRdData;
   wire      [CMD_FIFO_DATA_WIDTH - 1:0] wrCmdFifoRdData;
   input            TARGET_WREADY;
   wire             TARGET_WREADY;
   input     [7:0]  targetLEN_M1;
   wire      [7:0]  targetLEN_M1;
   input     [5:0]  initiator_ADDR_masked;
   wire      [5:0]  initiator_ADDR_masked;
   input     [5:0]  second_Beat_Addr;
   wire      [5:0]  second_Beat_Addr;
   input            sizeCnt_comb_EQ_SizeMax;
   wire             sizeCnt_comb_EQ_SizeMax;
   input     [5:0]  sizeCnt_comb_P1;
   wire      [5:0]  sizeCnt_comb_P1;
//  output ports
   output           INITIATOR_WREADY;
   wire             INITIATOR_WREADY;
   output           wrCmdFifore;
   wire             wrCmdFifore;
   output           TARGET_WVALID;
   reg              TARGET_WVALID;
   output reg [ID_WIDTH-1:0] TARGET_WID;
   output           TARGET_WLAST;
   reg              TARGET_WLAST;
   output    [USER_WIDTH - 1:0] TARGET_WUSER;
   reg       [USER_WIDTH - 1:0] TARGET_WUSER;
   output    [DATA_WIDTH_OUT - 1:0] TARGET_WDATA;
   reg       [DATA_WIDTH_OUT - 1:0] TARGET_WDATA;
   output    [STRB_WIDTH_OUT - 1:0] TARGET_WSTRB;
   reg       [STRB_WIDTH_OUT - 1:0] TARGET_WSTRB;
//  local signals
   reg       [8:0]  cnt;
   wire             cnt_match;
   reg       [5:0]  current_addr;
   wire      [5:0]  int_initiatorADDR;
   wire      [2:0]  int_targetSIZE;
   wire      [8:0]  int_targetLEN;
   wire             SameInitrTrgtSize;
   wire      [5:0]  SizeMax;
   wire      [DATA_WIDTH_OUT - 1:0] int_targetWDATA;
   wire      [STRB_WIDTH_OUT - 1:0] int_targetWSTRB;
   wire      [USER_WIDTH - 1:0] int_targetWUSER;
   reg       [5:0]  sizeCnt;
   reg       [5:0]  fixed_burst_sizecnt;
   reg              valid_data;
   reg              fixed_valid_data;
   reg              valid_data_reg;
   reg              fixed_valid_data_reg;
   wire             initiator_valid_data;
   wire             target_accept;
   reg       [DATA_WIDTH_IN - 1:0] INITIATOR_WDATA_reg;
   reg       [STRB_WIDTH_IN - 1:0] INITIATOR_WSTRB_reg;
   reg       [USER_WIDTH - 1:0] INITIATOR_WUSER_reg;
   wire             cnt_match_next;
   wire      [5:0]  maskAddr;
   wire      [3:0]  dataLoc;
   reg       [5:0]  current_addr_reg;
   reg       [5:0]  sizeCnt_reg;
   reg              hold_data;
   reg              hold_data_next;
   reg       [8:0]  cnt_next;
   reg       [ID_WIDTH-1:0] TARGET_WID_next;
   reg              TARGET_WVALID_next;
   reg              TARGET_WLAST_next;
   wire             fixed_flag;
   reg              initiator_valid_data_reg;
   wire             lastTx;
   reg              lastTx_reg;
   reg       [8:0]  cnt_plus_1;
   reg              cnt_plus_1_eq_0;
   reg              cnt_eq_0;
   reg              WVLID_FIXED_BURST_CTRL;
   wire             fixed_burst;
   reg              target_wrdone;
   reg              target_wrdone_f1;
   reg              fixed_burst_det;
   reg              fixed_burst_f1;
   reg              fixed_burst_det_reg;
   reg              wrCmdFifoEmpty_reg;
   reg              fixed_burst_dataloc_load;
   reg       [3:0]  fixed_burst_dataloc;
   reg       [3:0]  fixed_burst_dataloc_reg;
 
   always  @(*)
   begin   :widthConvWrite_comb
 
      if (wrCmdFifoEmpty)
        begin
          TARGET_WVALID_next = 1'b0;
		  TARGET_WID_next    = 0;
          TARGET_WLAST_next = 1'b0;
          hold_data_next = 1'b0;
          cnt_next = cnt;
        end
      else
        begin
          if (hold_data)
            begin
              if (TARGET_WREADY)
                begin
                  if (wrCmdFifore)
                    begin
                      TARGET_WVALID_next = 1'b0;
				      TARGET_WID_next    = 0;
                      TARGET_WLAST_next = 1'b0;
                      hold_data_next = 1'b0;
                      if (target_accept)
                        begin
                          if (TARGET_WLAST)
                            begin
                              cnt_next = 0;
                            end
                          else
                            begin
                              cnt_next = cnt + target_accept;
                            end
                        end
                      else
                        begin
                          cnt_next = cnt;
                        end
                    end
                  else
                    begin
                      if ((valid_data & ~fixed_burst) | fixed_valid_data)
                        begin
                          hold_data_next = ~TARGET_WREADY;
                          TARGET_WVALID_next = 1'b1;
					      TARGET_WID_next    = INITIATOR_WID;
                          TARGET_WLAST_next  = cnt_match_next | (cnt_match & ~target_accept);
                          if (TARGET_WREADY)
                            begin
                              if (target_accept & TARGET_WLAST)
                                begin
                                  cnt_next = 0;
                                end
                              else
                                begin
                                  cnt_next = cnt + target_accept;
                                end
                            end
                          else
                            begin
                              cnt_next = cnt;
                            end
                        end
                      else
                        begin
                          if (INITIATOR_WVALID)                          
                            begin
                              hold_data_next = ~TARGET_WREADY;
                              TARGET_WVALID_next = 1'b1;
					  	      TARGET_WID_next    = INITIATOR_WID;
                              TARGET_WLAST_next  = cnt_match_next | (cnt_match & ~target_accept);
                              if (TARGET_WREADY)
                                begin
                                  if (target_accept & TARGET_WLAST)
                                    begin
                                      cnt_next = 0;
                                    end
                                  else
                                    begin
                                      cnt_next = cnt + target_accept;
                                    end
                                end
                              else
                                begin
                                  cnt_next = cnt;
                                end
                            end
                          else
                            begin
                              TARGET_WVALID_next = 1'b0;
						      TARGET_WID_next    = 0;
                              TARGET_WLAST_next = 1'b0;
                              hold_data_next = 1'b0;
                              if (target_accept)
                                begin
                                  if (target_accept & TARGET_WLAST)
                                    begin
                                      cnt_next = 0;
                                    end
                                  else
                                    begin
                                      cnt_next = cnt + target_accept;
                                    end
                                end
                              else
                                begin
                                  cnt_next = cnt;
                                end
                            end
                        end
                    end
                end
              else
                begin
                  TARGET_WVALID_next = TARGET_WVALID;
			      TARGET_WID_next    = TARGET_WID;
                  TARGET_WLAST_next = TARGET_WLAST;
                  hold_data_next = hold_data;
                  cnt_next = cnt;
                end
            end
          else
            begin
              if (wrCmdFifore)
                begin
                  TARGET_WVALID_next = 1'b0;
			      TARGET_WID_next    = 0;
                  TARGET_WLAST_next = 1'b0;
                  hold_data_next = 1'b0;
                  if (target_accept)
                    begin
                      if (target_accept & TARGET_WLAST)
                        begin
                          cnt_next = 0;
                        end
                      else
                        begin
                          cnt_next = cnt + target_accept;
                        end
                    end
                  else
                    begin
                      cnt_next = cnt;
                    end
                end
              else
                begin
                  if ((valid_data & ~fixed_burst) | fixed_valid_data)
                    begin
                      hold_data_next = ~TARGET_WREADY;
                      TARGET_WVALID_next = 1'b1;
				      TARGET_WID_next    = INITIATOR_WID;
                      TARGET_WLAST_next  = cnt_match_next | (cnt_match & ~target_accept);
                      if (TARGET_WREADY)
                        begin
                          if (target_accept & TARGET_WLAST)
                            begin
                              cnt_next = 0;
                            end
                          else
                            begin
                              cnt_next = cnt + target_accept;
                            end
                        end
                      else
                        begin
                          cnt_next = cnt;
                        end
                    end
                  else
               begin
                  if (INITIATOR_WVALID)
                  begin
                     hold_data_next    = ~TARGET_WREADY;
                     TARGET_WVALID_next = 1'b1;
					 TARGET_WID_next    = INITIATOR_WID;
                     TARGET_WLAST_next  = cnt_match_next | (cnt_match & ~target_accept);
                     if (TARGET_WREADY)
                     begin
                        if (target_accept & TARGET_WLAST)
                        begin
                           cnt_next = 0;
                        end
                        else
                        begin
                           cnt_next = cnt + target_accept;
                        end
                     end
                     else
                     begin
                        cnt_next = cnt;
                     end
                  end
                  else
                  begin
                     TARGET_WVALID_next = 1'b0;
					 TARGET_WID_next    = 0;
                     TARGET_WLAST_next = 1'b0;
                     hold_data_next = 1'b0;
                     if (target_accept)
                     begin
                        if (target_accept & TARGET_WLAST)
                        begin
                           cnt_next = 0;
                        end
                        else
                        begin
                           cnt_next = cnt + target_accept;
                        end
                     end
                     else
                     begin
                        cnt_next = cnt;
                     end
                  end
               end
            end
         end
      end
   end
 
 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :Start9
 
      if (~arst_sync | ~srst_sync)
      begin
         TARGET_WDATA <= 0;
         TARGET_WSTRB <= 0;
         TARGET_WUSER <= 0;
      end
      else
      begin
         TARGET_WDATA <= int_targetWDATA;
         TARGET_WSTRB <= int_targetWSTRB;
         TARGET_WUSER <= int_targetWUSER;
      end
   end
 
 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :widthConvWrite_reg
 
      if (~arst_sync | ~srst_sync)
      begin
         cnt <= 0;
         cnt_plus_1 <= 1;
         cnt_eq_0 <= 1;
         cnt_plus_1_eq_0 <= 0;
         TARGET_WVALID <= 1'b0;
         TARGET_WID <= 0;
         TARGET_WLAST <= 1'b0;
         hold_data <= 1'b0;
      end
      else
      begin
         cnt <= cnt_next;
         cnt_plus_1 <= cnt_next + 1;
         cnt_eq_0 <= (cnt_next == 0);
         cnt_plus_1_eq_0 <= ((cnt_next + 1) == 0);
         TARGET_WLAST <= TARGET_WLAST_next;
		 //if(fixed_burst & target_accept & ~initiator_valid_data_reg)
         //  TARGET_WVALID <= 1'b0;
		 //else 
		   TARGET_WVALID <= TARGET_WVALID_next;
		 TARGET_WID    <= TARGET_WID_next;
         hold_data <= hold_data_next;
      end
   end
 
 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :addrCtrl_reg
 
      if (~arst_sync | ~srst_sync)
      begin
         current_addr_reg <= 0;
         sizeCnt_reg <= 0;
      end
      else
      begin
         current_addr_reg <= current_addr;
         sizeCnt_reg <= sizeCnt;
      end
   end
 
 
 
   always  @(*)
   begin   :sieCntCtrl
      if(wrCmdFifoEmpty_reg)
	    sizeCnt = 0;
      else if (target_accept)
      begin
         if (fixed_flag)
         begin
            if (SameInitrTrgtSize)
            begin
               sizeCnt = 'b0;
            end
            else
            begin
               if (cnt_eq_0 & ~fixed_burst_det)
               begin
                  if (SameInitrTrgtSize)
                  begin
                     sizeCnt = 'b0;
                  end
                  else
                  begin
                     if (sizeCnt_comb_EQ_SizeMax)
                     begin
                        sizeCnt = 0;
                     end
                     else 
                     begin
                        sizeCnt = sizeCnt_comb_P1;
                     end
                  end
               end
               else
               begin
                  if (SameInitrTrgtSize)
                  begin
                     sizeCnt = 'b0;
                  end
                  else
                  begin
                     if (SizeMax == sizeCnt_reg)
                     begin
					    if(fixed_burst & (SizeMax != sizeCnt_comb_P1))
						  sizeCnt = sizeCnt_comb_P1 ;
						else 
                          sizeCnt = 0;
                     end
                     else
                     begin
                        sizeCnt = sizeCnt_reg + 1;
                     end
                  end
               end
            end
         end
         else
         begin
            if (cnt_eq_0 & ~fixed_burst_det)
            begin
               if (SameInitrTrgtSize)
               begin
                  sizeCnt = 'b0;
               end
               else
               begin
                  if (sizeCnt_comb_EQ_SizeMax)
                  begin
                     sizeCnt = 0;
                  end
				  else 
				     sizeCnt = sizeCnt_comb_P1;
               end
            end
            else
            begin
               if (SameInitrTrgtSize)
               begin
                  sizeCnt = 'b0;
               end
               else
               begin
                  if (SizeMax == sizeCnt_reg)
                  begin
				    if(fixed_burst) 
					  sizeCnt = sizeCnt_comb_P1;
					else 
                      sizeCnt = 0;
                  end
                  else
                  begin
                     sizeCnt = sizeCnt_reg + 1;
                  end
               end
            end
         end
      end
      else
      begin
         sizeCnt = sizeCnt_reg;
      end
   end
 
 
 
   always  @(*)
   begin   :addr_ctrl
      
      if (target_accept)
      begin	  
         if (cnt_eq_0 & ~fixed_burst_det)
         begin
            if (fixed_flag)
            begin
               if (SameInitrTrgtSize)
               begin
                  current_addr = int_initiatorADDR;
               end
               else
               begin
                  if (sizeCnt_comb_EQ_SizeMax)
                  begin
                     current_addr = initiator_ADDR_masked;
                  end
                  else
                  begin
                     current_addr = second_Beat_Addr;
                  end
               end
            end
            else
            begin
               current_addr = second_Beat_Addr;
            end
         end
         else
         begin
            if (fixed_flag)
            begin
               if (SameInitrTrgtSize)
               begin
                  current_addr = int_initiatorADDR;
               end
               else
               begin
                  if (sizeCnt_reg == SizeMax)
                  begin
                     current_addr = initiator_ADDR_masked;
                  end
                  else
                  begin
                     current_addr = current_addr_reg + (1<<int_targetSIZE);
                  end
               end
            end
            else
            begin
               current_addr = current_addr_reg + (1<<int_targetSIZE);
            end
         end
      end
      else
      begin
         current_addr = current_addr_reg;
      end
   end
 
 
 
   always@(*)
   begin   :valid_data_comb
      if (wrCmdFifoEmpty)
      begin
         if (lastTx_reg)
         begin
            valid_data = 0;
         end
         else
         begin
            if (SameInitrTrgtSize)
            begin
               if (target_accept)
               begin
                  valid_data = 1'b0;
               end
               else
               begin
                  if (initiator_valid_data_reg)
                  begin
                     valid_data =  1'b1;
                  end
                  else
                  begin
                     valid_data = valid_data_reg;
                  end
               end
            end
            else
            begin
               if (sizeCnt_reg == SizeMax)
               begin
                  if (target_accept)
                  begin
                     valid_data = 1'b0;
                  end
                  else
                  begin
                     if (initiator_valid_data_reg)
                     begin
                        valid_data =  1'b1;
                     end
                     else
                     begin
                        valid_data = valid_data_reg;
                     end
                  end
               end
               else
               begin
                  if (sizeCnt_comb_EQ_SizeMax)
                  begin
                     if (cnt_eq_0)
                     begin
                        if (target_accept)
                        begin
                           valid_data = 1'b0;
                        end
                        else
                        begin
                           if (initiator_valid_data_reg)
                           begin
                              valid_data =  1'b1;
                           end
                           else
                           begin
                              valid_data = valid_data_reg;
                           end
                        end
                     end
                     else
                     begin
                        if (initiator_valid_data_reg)
                        begin
                           valid_data =  1'b1;
                        end
                        else
                        begin
                           valid_data = valid_data_reg;
                        end
                     end
                  end
                  else
                  begin
                     if (initiator_valid_data_reg)
                     begin
                        valid_data =  1'b1;
                     end
                     else
                     begin
                        valid_data = valid_data_reg;
                     end
                  end
               end
            end
         end
      end
      else
      begin
         if (SameInitrTrgtSize)
         begin
            if (target_accept)
            begin
               valid_data = 1'b0;
            end
            else
            begin
               if (initiator_valid_data_reg)
               begin
                  valid_data =  1'b1;
               end
               else
               begin
                  valid_data = valid_data_reg;
               end
            end
         end
         else
         begin
            if (sizeCnt_reg == SizeMax)
            begin
               if (target_accept)
               begin
                  valid_data = 1'b0;
               end
               else
               begin
                  if (initiator_valid_data_reg)
                  begin
                     valid_data =  1'b1;
                  end
                  else
                  begin
                     valid_data = valid_data_reg;
                  end
               end
            end
            else
            begin
               if (sizeCnt_comb_EQ_SizeMax)
               begin
                  if (cnt_eq_0)
                  begin
                     if (target_accept)
                     begin
                        valid_data = 1'b0;
                     end
                     else
                     begin
                        if (initiator_valid_data_reg)
                        begin
                           valid_data =  1'b1;
                        end
                        else
                        begin
                           valid_data = valid_data_reg;
                        end
                     end
                  end
                  else
                  begin
                     if (initiator_valid_data_reg)
                     begin
                        valid_data =  1'b1;
                     end
                     else
                     begin
                        valid_data = valid_data_reg;
                     end
                  end
               end
               else
               begin
                  if (initiator_valid_data_reg)
                  begin
                     valid_data =  1'b1;
                  end
                  else
                  begin
                     valid_data = valid_data_reg;
                  end
               end
            end
         end
      end
   end
 
 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :valid_data_register
 
      if (~arst_sync | ~srst_sync)
      begin
         valid_data_reg <= 1'b0;
         initiator_valid_data_reg <= 1'b0;
      end
      else
      begin
         valid_data_reg <= valid_data;
         initiator_valid_data_reg <= initiator_valid_data;
      end
   end
 
 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :wchan_reg
 
      if (~arst_sync | ~srst_sync)
      begin
 
         INITIATOR_WDATA_reg <= 0;
         INITIATOR_WSTRB_reg <= 0;
         INITIATOR_WUSER_reg <= 0;
      end
      else
      begin
         if (initiator_valid_data)
         begin
 
            INITIATOR_WDATA_reg <= INITIATOR_WDATA;
            INITIATOR_WSTRB_reg <= INITIATOR_WSTRB;
            INITIATOR_WUSER_reg <= INITIATOR_WUSER;
         end
      end
   end
 
 
 
   always @( posedge ACLK or negedge arst_sync )
   begin   :lastTx_flowchart
 
      if (~arst_sync | ~srst_sync)
      begin
         lastTx_reg <= 1'b1;
      end
      else
      begin
         if (wrCmdFifoEmpty)
         begin
         end
         else
         begin
            lastTx_reg <= lastTx;
         end
      end
   end

   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       fixed_burst_dataloc_load <= 1;
	 else if(wrCmdFifore & lastTx_reg)
	   fixed_burst_dataloc_load <= 1;
	 else if(target_accept)
       fixed_burst_dataloc_load <= 0;
     
  always@(*)
	if(((cnt_eq_0 & fixed_burst_dataloc_load & ~target_accept) | ((fixed_burst_dataloc_reg == SizeMax[3:0]) & target_accept)))
	  fixed_burst_dataloc = sizeCnt_comb_P1[3:0];
	else if(target_accept)
	  fixed_burst_dataloc = fixed_burst_dataloc_reg + 1;
    else 
      fixed_burst_dataloc = fixed_burst_dataloc_reg;
 
   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       fixed_burst_dataloc_reg <= 4'hF;
	 else 
	   fixed_burst_dataloc_reg <= fixed_burst_dataloc;

   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       target_wrdone <= 0;
	 else 
	   target_wrdone <= wrCmdFifore;

   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       target_wrdone_f1 <= 0;
	 else 
	   target_wrdone_f1 <= target_wrdone;	   
	   
   always @(*)
     if(target_wrdone_f1)
	   begin 
	     if(lastTx_reg)
	       fixed_burst_det = 1'b0;
	     else 
	       fixed_burst_det = fixed_burst;
	   end 
	 else 
	   fixed_burst_det = fixed_burst_det_reg;

   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       fixed_burst_det_reg <= 1'b0;
	 else if(fixed_burst)
	   fixed_burst_det_reg <= fixed_burst_det;
	 else 
	   fixed_burst_det_reg <= 1'b0;

   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       fixed_burst_f1 <= 1'b0;
	 else 
	   fixed_burst_f1 <= fixed_burst;

   always @( posedge ACLK or negedge arst_sync )
     if (~arst_sync | ~srst_sync)
       wrCmdFifoEmpty_reg <= 1'b0;
	 else 
	   wrCmdFifoEmpty_reg <= wrCmdFifoEmpty;
	   
   // Split up wrCmdFifoRdData
   assign fixed_burst = wrCmdFifoRdData[37+ID_WIDTH-1];
   assign fixed_flag = wrCmdFifoRdData[29];
   assign int_initiatorADDR = wrCmdFifoRdData[28:23];
   assign int_targetLEN = wrCmdFifoRdData[22:14];
   assign int_targetSIZE = wrCmdFifoRdData[13:11];
   assign SameInitrTrgtSize = wrCmdFifoRdData[7];
   assign SizeMax = wrCmdFifoRdData[6:1];
   assign lastTx = wrCmdFifoRdData[0];
 
   assign cnt_match = ((cnt_plus_1) == int_targetLEN);
   assign cnt_match_next = (target_accept & ((cnt_plus_1) == {1'b0, targetLEN_M1})) | (int_targetLEN == 1);
 
   assign maskAddr = ( (DATA_WIDTH_IN/8) - 1) & ((target_accept ? cnt_plus_1_eq_0 : cnt_eq_0) ? int_initiatorADDR : current_addr);
    
   // Location of data on Initiator bus
   assign dataLoc = (fixed_burst & ~SameInitrTrgtSize) ? fixed_burst_dataloc : ( maskAddr >> ($clog2(DATA_WIDTH_OUT/8)));
   //assign dataLoc = ( maskAddr >> ($clog2(DATA_WIDTH_OUT/8)));
   //assign dataLoc = fixed_burst_dataloc;

   assign int_targetWDATA = ((valid_data & ~fixed_burst) | fixed_valid_data)  ? INITIATOR_WDATA_reg[ (dataLoc*DATA_WIDTH_OUT) +: DATA_WIDTH_OUT ] : INITIATOR_WDATA[ (dataLoc*DATA_WIDTH_OUT) +: DATA_WIDTH_OUT ];
   assign int_targetWSTRB = ((valid_data & ~fixed_burst) | fixed_valid_data)  ? INITIATOR_WSTRB_reg[ (dataLoc*(DATA_WIDTH_OUT/8)) +: (DATA_WIDTH_OUT/8) ] : INITIATOR_WSTRB[ (dataLoc*(DATA_WIDTH_OUT/8)) +: (DATA_WIDTH_OUT/8) ]; 
   assign int_targetWUSER = ((valid_data & ~fixed_burst) | fixed_valid_data)  ? INITIATOR_WUSER_reg : INITIATOR_WUSER;
 
   assign wrCmdFifore = TARGET_WVALID & TARGET_WREADY & TARGET_WLAST;
   assign INITIATOR_WREADY = INITIATOR_WVALID & (~wrCmdFifore) & (~((valid_data & ~fixed_burst) | fixed_valid_data)) & (~wrCmdFifoEmpty);
 
   assign initiator_valid_data = INITIATOR_WVALID & INITIATOR_WREADY;
   assign target_accept = TARGET_WVALID & TARGET_WREADY;
   
   
   always@(posedge ACLK or negedge arst_sync)
     begin :fixburst_sizecnt
	   if (~arst_sync | ~srst_sync)
	     fixed_burst_sizecnt <= 0;
       else if((target_wrdone & lastTx_reg) | ((fixed_burst_sizecnt == (SizeMax - sizeCnt_comb_P1)) & target_accept))	     
	     fixed_burst_sizecnt <= 0;
       else if (target_accept & fixed_burst)
	     fixed_burst_sizecnt <= fixed_burst_sizecnt + 1'b1;
     end 		 

   always@(*)
     begin :fixburst_validdata
       if((target_wrdone & lastTx_reg & fixed_burst_f1) | (SameInitrTrgtSize & target_accept) | 
	      ((fixed_burst_sizecnt == (SizeMax - sizeCnt_comb_P1)) & target_accept))
	     fixed_valid_data = 0;
	   else if(initiator_valid_data_reg & fixed_burst)
		 fixed_valid_data = 1;
	   else 
	     fixed_valid_data = fixed_valid_data_reg;
     end 		 
   
   always@(posedge ACLK or negedge arst_sync)
     begin :fixburst_validdatareg
       if (~arst_sync | ~srst_sync)
	     fixed_valid_data_reg <= 0;
       else
	     fixed_valid_data_reg <= fixed_valid_data;
     end 		
	 
endmodule

