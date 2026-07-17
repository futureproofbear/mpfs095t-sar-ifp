#!/usr/bin/env bash
# run_app_pc_probe.sh -- Is the SAR app's hart (U54_1) CHURNING or STUCK?
#
# The COM4 UART heartbeat is the E51 (HSS) hart -- it proves HSS is alive and says NOTHING about
# the app. The app runs on U54_1. This probe halts U54_1, samples its PC N times, and symbolizes
# each sample against sar_app.elf, which tells you definitively:
#
#   PC advances through sar_coeffs_pass1/2 / sar_cpu_fft / detect -> CPU is CHURNING (just slow)
#   PC pinned in a tight poll loop inside sar_form_image /        -> CPU is WAITING on a stalled
#     resample_2pass / fft_fabric_pass (see NOTE)                    fabric kernel (fabric is the bug)
#   PC identical on a load/store every sample, no progress        -> hard AXI/DDR stall (bus never
#                                                                    replied; suspect DDR/FIC)
#
# NOTE: sar_k_wait() is `static inline` -- it is NOT a symbol in the ELF. A poll will symbolize to the
# ENCLOSING function (sar_form_image / resample_2pass / fft_fabric_pass) + offset. Use `x/i $pc` to
# recognise it: a poll loop is a load from 0x6000_xxxx (kernel AXI4-Lite reg) + a branch back.
#
# NOTE: "silent for N minutes" is NOT proof of a hang. sar_k_wait's budget is
# SAR_DEFAULT_SPINS = 0x40000000 (~1.07e9 polls, sar_sequencer.c:30). Each poll is an AXI4-Lite read
# over FIC0, so the budget is worth MANY MINUTES of wall clock. Before assuming a hard hang, let the
# run go to completion -- a stalled kernel eventually returns SAR_SEQ_TIMEOUT_{WINDOW,CORNER,DETECT},
# which names the guilty stage for free (no JTAG, no rebuild).
#
# RUN THIS WHILE THE BOARD IS SITTING AT "focus pipeline...". It halts and resumes the app hart, so
# do not run it during a run you care about finishing.
#
# JTAG hygiene (project rule -- a killed transfer WEDGES the FlashPro6, needing a J33 re-plug):
# attach-in-place, no reset, telnet-4444 `shutdown`, never taskkill.
#
# Usage: run_app_pc_probe.sh [NSAMPLES] [SLEEP_SEC]
set -u
N="${1:-6}"
NAP="${2:-2}"
HERE="$(cd "$(dirname "$0")" && pwd)"
GDBSCRIPT="$HERE/jtag_full/app_pc_probe.gen.gdb"
GDBLOG="$HERE/jtag_full/app_pc_probe.log"
OOLOG="${GDBLOG%.log}.openocd.log"
NEW="/c/Users/lkwangsi/Tools/openocd-new/xpack-openocd-0.12.0-4"
SC="/c/Microchip/SoftConsole-v2022.2-RISC-V-747"
GDB="$SC/riscv-unknown-elf-gcc/bin/riscv64-unknown-elf-gdb.exe"
# The SD-boot SAR app payload (symbols for PC resolution). Linked at DDR exec addr 0x1000000000.
ELF="$HERE/../fpga/sar_app/Default/sar_app.elf"
PY="C:/ProgramData/Anaconda3-2025.12-1/python.exe"

[ -f "$ELF" ] || { echo "!! missing app ELF: $ELF (build mpfs/fpga/sar_app first)"; exit 1; }

cat > "$GDBSCRIPT" <<GDBEOF
set pagination off
set confirm off
set architecture riscv:rv64
set mem inaccessible-by-default off
target extended-remote localhost:3333

set \$i = 0
while \$i < $N
  monitor mpfs.hart1_u54_1 arp_halt
  thread 2
  printf "\n=== U54_1 PC SAMPLE %d ===\n", \$i
  printf "PC = 0x%016lx\n", \$pc
  info symbol \$pc
  x/i \$pc
  bt 6
  monitor resume
  shell sleep $NAP
  set \$i = \$i + 1
end

monitor resume
monitor shutdown
GDBEOF

"$NEW/bin/openocd.exe" -s "$NEW/openocd/scripts" --command "set DEVICE MPFS" \
  -c "telnet_port 4444" -f board/microchip_riscv_efp6.cfg -l "$OOLOG" >/dev/null 2>&1 &
OO_PID=$!
sleep 14
"$GDB" -batch "$ELF" -x "$GDBSCRIPT" </dev/null > "$GDBLOG" 2>&1
echo "GDB_RC=$?" >> "$GDBLOG"

# clean shutdown via telnet -- never taskkill (that is what wedges the FlashPro6)
"$PY" - <<'PYEOF' 2>/dev/null || true
import socket,time
try:
    s=socket.create_connection(('127.0.0.1',4444),timeout=3); time.sleep(0.3)
    try: s.recv(4096)
    except Exception: pass
    s.sendall(b'shutdown\n'); time.sleep(0.5); s.close()
except Exception: pass
PYEOF
wait "$OO_PID" 2>/dev/null

echo ">>> U54_1 PC samples (full log: $GDBLOG):"
grep -aE "SAMPLE|^PC = |is in |No symbol|=>|\\$pc" "$GDBLOG" | head -60
echo
echo ">>> VERDICT GUIDE:"
echo "    PC advances across samples (sar_coeffs_pass*/renorm/detect) -> CPU churning, just slow"
echo "    PC pinned in sar_k_wait / poll loop                          -> fabric kernel stalled"
echo "    PC identical on a load/store every sample                    -> AXI/DDR stall"
