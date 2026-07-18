#!/usr/bin/env python3
"""watch_sar_uart.py -- thin-client SAR pipeline monitor over UART (COM6).

Runs on the engineer thin client (needs only pyserial). Logs the SAR app console, timestamps every
line, and turns the diagnostic payload's progress stream into a verdict:

  * shows which STAGE is running (from the ">stage" banners), and
  * whether that stage is ADVANCING (heartbeat idx climbing = churning) or FROZEN (no new line for
    a while = stalled), and
  * decodes the final "[sar] FAIL form_image = N" timeout code to the guilty stage.

This is the JTAG-less equivalent of run_app_pc_probe.sh: on this silicon the stall is a HARD AXI freeze
(the U54 sticks on a load that never returns, so no "[sar] FAIL form_image" timeout ever prints -- a
41-min run proved it). The localization is therefore the LAST stage banner / heartbeat before the UART
goes silent: that names the stage, and STAGE_KERNEL maps it to the same AXI target the PC-probe would
name. Use with a payload built with SAR_DIAG_UART=1 (see build_sar_app.sh).

Usage:
    python mpfs/host/watch_sar_uart.py --port COM6            # 115200 8N1, live
    python mpfs/host/watch_sar_uart.py --port COM6 --stall 90 # flag a stall after 90 s of silence
    python mpfs/host/watch_sar_uart.py --replay capture.log   # re-analyze a saved log (no serial)
"""
import argparse
import sys
import time

# stage -> the AXI target whose access hard-stalls if the pipeline freezes in that stage. Mirrors the
# run_app_pc_probe.sh PC decode: a load from 0x6000_xxxx names the kernel control slave; a DDR load
# (detect is CPU-only) points at the FIC0/DDR path. This turns the "last stage before UART silence"
# into the same culprit the JTAG PC-probe would name -- without JTAG.
STAGE_KERNEL = {
    "resample":   "K_RESAMPLE @0x60003000 (or its DDR gather over FIC0)",
    "window":     "K_WINDOW @0x60001000",
    "rangeFFT":   "K_FFT @0x60004000 (or the FFT DMA S2MM over FIC0)",
    "cornerturn": "K_CORNER_TURN @0x60000000",
    "azimuthFFT": "K_FFT @0x60004000 (or the FFT DMA S2MM over FIC0)",
    "detect":     "no kernel -- CPU load/store to DDR (SIG/OUT) over FIC0 => the DDR/FIC0 path",
}

# code -> stage, from sar_seq_status_t (sar_sequencer.h). "[sar] FAIL form_image = N" prints N. NOTE:
# on this silicon the stall is a HARD AXI freeze, so this FAIL line NEVER appears (the timeout can't
# fire); it is decoded here only for a soft/spin stall on some other build.
FAIL_CODE = {
    1: "BAD_JOB (bad/missing job descriptor)",
    2: "RESAMPLE (keystone resample)",
    3: "WINDOW (2-D Hamming)",
    4: "FFT1 (range FFT feeder stalled)",
    5: "CORNER (corner-turn / transpose)",
    6: "FFT2 (azimuth FFT feeder stalled)",
    7: "DETECT (CPU magnitude)",
    8: "DMA (FFT S2MM write-back stalled)",
}


def analyze_line(line, state):
    """Update state from one console line; print a note on stage change / completion / failure."""
    s = line.strip()
    if not s:
        return
    now = time.strftime("%H:%M:%S")
    if ">" in s and "[sar]" in s:                      # stage banner: "[sar]  >resample"
        stage = s.split(">", 1)[1].strip()
        state["stage"] = stage
        state["stage_since"] = time.time()
        state["last_idx"] = None
        print(f"[{now}] >>> STAGE: {stage}")
    elif "[sar]" in s and "/" in s and any(t in s for t in ("resample", "detect", "fft")):
        # heartbeat: "[sar]   resample-1 512/8167"  -> proves the stage is ADVANCING
        try:
            idx = int(s.rsplit(None, 1)[1].split("/")[0])
            state["last_idx"] = idx
            state["last_beat"] = time.time()
        except (ValueError, IndexError):
            pass
    elif "FAIL form_image" in s:
        try:
            code = int(s.rsplit("=", 1)[1].strip().split()[0], 0)
        except (ValueError, IndexError):
            code = -1
        print(f"[{now}] *** PIPELINE FAILED: form_image = {code} -> "
              f"{FAIL_CODE.get(code, 'unknown code')}")
    elif "DONE" in s:
        print(f"[{now}] *** DONE -- pipeline completed, OUT written to card.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", help="serial port for the SAR app console (e.g. COM6)")
    ap.add_argument("--baud", type=int, default=115200)
    ap.add_argument("--replay", help="re-analyze a saved capture log instead of reading serial")
    ap.add_argument("--stall", type=float, default=120.0,
                    help="seconds of silence before flagging a STALL (default 120)")
    ap.add_argument("--log", default="sar_uart_capture.log", help="raw capture file")
    a = ap.parse_args()

    state = {"stage": None, "stage_since": 0.0, "last_idx": None, "last_beat": 0.0}

    if a.replay:
        with open(a.replay, "r", errors="replace") as f:
            for line in f:
                sys.stdout.write(line if line.endswith("\n") else line + "\n")
                analyze_line(line, state)
        return

    if not a.port:
        ap.error("--port is required (or use --replay)")
    try:
        import serial  # pyserial
    except ImportError:
        sys.exit("pyserial not installed: pip install pyserial")

    ser = serial.Serial(a.port, a.baud, timeout=1)
    print(f"# watching {a.port} @ {a.baud} 8N1 -- stall flag after {a.stall}s silence. Ctrl-C to stop.")
    buf = b""
    last_rx = time.time()
    stalled = False
    with open(a.log, "a", encoding="utf-8") as logf:
        while True:
            chunk = ser.read(256)
            now = time.time()
            if chunk:
                last_rx = now
                stalled = False
                buf += chunk
                while b"\n" in buf:
                    raw, buf = buf.split(b"\n", 1)
                    line = raw.decode("ascii", errors="replace").rstrip("\r")
                    ts = time.strftime("%H:%M:%S")
                    print(f"[{ts}] {line}")
                    logf.write(f"[{ts}] {line}\n"); logf.flush()
                    analyze_line(line, state)
            elif not stalled and (now - last_rx) > a.stall and state.get("stage"):
                held = now - state["stage_since"]
                idx = state.get("last_idx")
                kern = STAGE_KERNEL.get(state["stage"], "?")
                print(f"\n[{time.strftime('%H:%M:%S')}] !!! STALL in stage '{state['stage']}' "
                      f"(held {held:.0f}s, no UART for {a.stall:.0f}s). "
                      + (f"Last heartbeat idx={idx}. " if idx is not None else "")
                      + f"This is a HARD stall: no [sar] FAIL code will come (the U54 is frozen on an "
                        f"AXI load, so the bounded-wait timeout can never fire -- confirmed on silicon, "
                        f"41-min run). The guilty access is this stage's -> {kern}. "
                        f"(Same verdict run_app_pc_probe.sh would give from the PC, recovered over UART.)\n")
                stalled = True


if __name__ == "__main__":
    main()
