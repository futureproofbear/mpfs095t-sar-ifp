#!/bin/bash
# Chained board-free Discovery (MPFS095T/FCSG325) SAR fabric build:
#   Stage 1 create project + assemble SAR_TOP  ->  Stage 2 synth/P&R/timing-gate/export.
# Uses the proven FFV flow (5 HLS kernels + Verilog feeder), retargeted to the 095T.
FPGA="c:/Users/lkwangsi/Documents/github/mpfs095t-sar-ifp/mpfs/fpga"
cd "$FPGA" || exit 2
LIBERO="/c/Microchip/Libero_SoC_2025.2/Libero_SoC/Designer/bin/libero.exe"
[ -f "$LIBERO" ] || LIBERO="/c/Microchip/Libero_SoC_2025.2/Libero_SoC/Designer/bin64/libero.exe"
export LM_LICENSE_FILE='C:\Users\lkwangsi\Documents\github\polarfire-soc\License.dat'
run(){ "$LIBERO" "SCRIPT:$1" "LOGFILE:$2" >/dev/null 2>&1; }

echo "[$(date +%H:%M:%S)] STAGE 1/2: create libero_disc + assemble SAR_TOP"
run "$FPGA/create_fresh_project_disc.tcl" "$FPGA/disc_create.log"
if ! grep -qE "FRESH_PROJECT_DONE|SARTOP330_DONE" "$FPGA/disc_create.log" 2>/dev/null; then
  echo "[$(date +%H:%M:%S)] STAGE 1 FAILED -- tail:"; tail -40 "$FPGA/disc_create.log"; exit 1
fi
echo "[$(date +%H:%M:%S)] STAGE 1 OK"

echo "[$(date +%H:%M:%S)] STAGE 2/2: synth + P&R + VERIFYTIMING gate + export"
run "$FPGA/build_disc.tcl" "$FPGA/disc_build.log"
echo "[$(date +%H:%M:%S)] STAGE 2 result:"
grep -aE "SYN_OK|PNR_OK|VT_OK|SETUP nviol|HOLD nviol|TIMING_MET|TIMING_NOT_MET|BITSTREAM_DONE|FFV_BUILD_DONE|_RC:" "$FPGA/disc_build.log" | tail -20
