# Provision the SAR scene onto a microSD card — operator runbook

The board reads its SAR scene from a **microSD card** that you prepare on a PC — no JTAG, no board
link. The card is a **GPT SD-boot** image: the SAR app (HSS payload) + the scene + a reserved output
region. Two paths:
- **Path A — prebuilt image** (simplest): flash a `sar_sd.img` the engineer produced.
- **Path B — generate it yourself** (needed when the image is too big to transfer, or you want a
  different scene): stage a CPHD and pack the card with the tools + prebuilt payload in this repo.
  **No SoftConsole / Libero / firmware build required** — the app payload ships prebuilt.

## What you need
- A **microSD card** (**≥ ~475 MB**; any modern card is fine) + a **USB microSD reader**.
- A **raw disk-imaging tool** — **[balenaEtcher](https://etcher.balena.io/)** (recommended,
  Windows/macOS/Linux) or Win32DiskImager (Windows) or `dd` (Linux/macOS).
- For **Path B only**: **Python 3.9+** with `numpy` + `sarpy` (`pip install numpy sarpy`), and a CPHD.

> ⚠️ Writing a raw image **erases the whole card**. Use a dedicated card; back up anything on it first.

## Path A — prebuilt image (simplest, no Python)
The engineer sends **`sar_sd.img`** for the target scene (it is large, ~180 MB+, so it is delivered
out-of-band — a file transfer or a GitHub Release asset, not committed to the repo).
1. Insert the microSD into the PC card reader.
2. Open **balenaEtcher** → **Flash from file** → select `sar_sd.img` → select the SD card → **Flash**.
   - (Win32DiskImager: pick `sar_sd.img`, pick the card's drive letter, **Write**.)
   - (Linux/macOS: `sudo dd if=sar_sd.img of=/dev/sdX bs=4M conv=fsync` — replace `/dev/sdX` with the
     card device, *not* a partition; double-check with `lsblk`.)
3. Eject the card, insert it into the **Discovery board's microSD slot**, power-cycle. HSS boots the
   app, which loads the scene into DDR and focuses it.

## Path B — generate the image yourself (needs Python, no firmware build)
Everything you need is in this repo: the pack tools (`mpfs/host/`) **and the prebuilt app payload**
(`mpfs/deliver/payload.bin`, 43 KB — you do NOT build the firmware). You only add a scene.

1. **Install Python deps** (once): `pip install numpy sarpy` (add `scipy` if prompted).

2. **Get a CPHD scene.** Any Umbra open-data spotlight `CPHD.cphd` works — the exact scene is **not
   required** to run the system; a specific one is only needed to reproduce the shipped reference
   image. Catalog: `s3://umbra-open-data-catalog` (us-west-2, anonymous HTTPS, no AWS account),
   layout `sar-data/tasks/<task>/<uuid>/<timestamp>_UMBRA-NN/CPHD.cphd`.

   The **exact scene the shipped image was built from** (download this to reproduce it):
   ```
   https://umbra-open-data-catalog.s3.us-west-2.amazonaws.com/sar-data/tasks/North+Dakota+State+University+Plot/8d5a3c80-a3dc-47b2-bf31-f3921b8c0f39/2023-11-10-16-16-44_UMBRA-04/2023-11-10-16-16-44_UMBRA-04_CPHD.cphd
   ```
   task `North Dakota State University Plot`, uuid `8d5a3c80-a3dc-47b2-bf31-f3921b8c0f39`, capture
   `2023-11-10-16-16-44_UMBRA-04`; native 8167 pulses × ~9000 samples.

3. **Stage the CPHD → pipeline inputs.** The pipeline grids to a fixed **8192×8192**, so both capture
   dimensions must be ≤ 8192. For the NDSU scene above the sample axis is ~9000 (> 8192), so decimate
   it by 2:
   ```
   python mpfs/host/serialize_inputs.py --in 2023-11-10-16-16-44_UMBRA-04_CPHD.cphd --grid 8192 \
       --deci-pulse 1 --deci-sample 2 --out jtag_stage
   ```
   If it errors `scene MxN exceeds GRID_MAX 8192`, raise decimation on the offending axis until both
   fit — `--deci-pulse` for the pulse/azimuth axis, `--deci-sample` for the sample/range axis
   (8167×~9000 → `--deci-sample 2` → 8167×4500). It prints the final dims and a resample-geometry
   self-check (`corr≈1.000` = good). Decimation (not cropping) is required because CPHD axes are phase
   history, not image pixels — cropping them degrades focus over the whole image rather than selecting
   a sub-scene.

4. **Pack the GPT SD-boot image** (prebuilt payload + your staged scene):
   ```
   python mpfs/host/sd_pack.py --gpt --payload mpfs/deliver/payload.bin \
       --stage jtag_stage --out sar_sd.img
   ```
   It self-verifies (GPT sigs/CRCs, HSS payload Type-GUID, P2 base LBA, every scene blob/segment CRC)
   and prints the partition LBAs + the **minimum microSD size** (~475 MB).

5. **Write `sar_sd.img` to the card** as in **Path A**.

## How the addressing works (for reference)
The card is **GPT-partitioned** for HSS SD-boot:
- **P1 @ LBA 2048** — the HSS payload (`payload.bin`, the prebuilt SAR app). HSS finds it by its
  payload Type-GUID, loads it into DDR, and jumps to it.
- **P2 @ LBA 67584** (`SAR_SD_SCENE_LBA`) — a `SARI` superblock + one blob per scene (SIG signal +
  geometry tables). Each TOC entry carries the scene's absolute card LBA; the app reconstructs its
  job descriptor from the TOC and DMAs each segment to its fixed DDR address.
- **OUT @ LBA 657408** (`SAR_SD_OUT_LBA`) — raw space past the scene where the board writes the
  focused 128 MiB image back (commit-last: it invalidates the `SARO` magic, writes the image, then
  writes the superblock last, so a power cut mid-write leaves a rejected torn image, not a bad one).

You never compute addresses by hand — the tools pin these LBAs and the firmware matches them; you
just write the whole image to the card.

## Verify the provisioning tools (optional)
`python mpfs/host/sd_pack.py --selftest` runs a synthetic GPT + scene round-trip (no card, no CPHD)
to confirm the tool works. `python mpfs/host/mkpayload.py --selftest` checks the payload generator.

## Run the scene on the board (after power-on — engineer thin client)
Everything here is done on the **engineer thin client** (the laptop with the microSD reader + UART),
not the Libero host. No JTAG, no debugger.

1. Insert the provisioned microSD into the **Discovery board's microSD slot**.
2. Connect the board's **UART** to the laptop (FTDI USB-UART; enumerates as **COM4** here) and open a
   terminal at **115200 8N1** (PuTTY / Tera Term, or a logged read). Start capturing to a file so the
   run is recoverable.
3. Power-cycle the board. HSS boots from eNVM, trains DDR, loads the SAR-app payload (P1), which loads
   the `SARI` scene (P2), focuses it on the fabric CoreFFT, and writes the image back to the OUT region.
4. Watch the UART. A good run prints and then stops:
   ```
   [sar] Discovery microSD autonomous boot
   [sar] FFTMODE=1 (fabric CoreFFT)
   [sar] init microSD... ok
   [sar] load scene from SD (P2)... ok
   [sar] focus pipeline... ok
   [sar] save OUT to SD... ok
   [sar] DONE
   ```
   `[sar] DONE` after `save OUT to SD... ok` means the focused image is committed to the card — the
   board has finished writing its output back to the SD card (no host transfer needed; the board is
   the writer). If the log hangs or resets before `[sar]` ever appears, the SAR app never started —
   that is the HSS bring-up blocker, see [DISCOVERY_BRINGUP_ISSUES.md](DISCOVERY_BRINGUP_ISSUES.md).

Then pull the image back and check it (next two sections).

## Verify the FOCUSED IMAGE came back (after a board run — fully headless)
The board narrates its run on the UART (115200 8N1); the sequence ends in `[sar] DONE` once it has
written the focused image to the card's OUT region (LBA 657408). To pull that image back to the PC
and confirm it byte-for-byte (no Libero/JTAG):

1. Power off the board, move the microSD to the PC reader.
2. Identify the card's physical drive number (Windows, no admin tools needed):
   ```
   echo list disk | diskpart      # the card = the disk whose size matches (e.g. Disk 2 -> PhysicalDrive2)
   ```
3. Dump the OUT region (git-bash, **run the terminal as Administrator** — raw sector access needs it).
   132 MiB = SARO superblock + the 128 MiB image + margin:
   ```
   dd if=//./PhysicalDrive2 of=out.bin bs=512 skip=657408 count=270336
   ```
4. Parse + validate CRC + render a preview PNG:
   ```
   python mpfs/host/read_sd_out.py --img out.bin --base-lba 657408 --out focused
   ```
   It prints the SARO TOC (scene_id, run_seq, dims), reports `CRC32 ... [MATCH]` when the on-card image
   matches the CRC the firmware wrote, and emits `focused.bin` (raw 8192×8192 uint16) + `focused.png`
   (log-scaled preview). A `[MISMATCH]` or an "OUT region is empty" message means the run did not commit
   a good image — re-check the UART. `python mpfs/host/read_sd_out.py --selftest` proves the reader
   itself (synthetic round-trip, no card).

## Is the focused image correct? (not just intact)
`CRC32 [MATCH]` only proves **integrity** — the bytes on the card are exactly what the firmware wrote,
with no torn/corrupt sectors. It does not prove the pipeline focused the *right* image. Two checks, in
increasing rigour:

1. **Visual sanity (quick).** Open `focused.png`. A correct run shows a **sharply focused** scene with
   recognizable ground features (for the NDSU plot: field parcels, roads, edges). A uniformly smeared,
   streaked, or noise-like image means the pipeline ran but mis-focused (resample geometry, scaling, or
   corner-turn) — capture it and compare against the reference below.
2. **Bit-accurate reference (rigorous).** The board-free emulator `mpfs/host/silicon_emulator.py` is a
   fixed-point mirror of the on-silicon datapath and equals the float golden (corr 1.0), so it predicts
   the exact OUT the board should produce. Point it at the **same CPHD + same `--deci`/`--grid`** used
   to build the card, then diff its output against `focused.bin`. The shipped emulator wires in the two
   dev scenes (`--scene centerfield|ship`); for the Discovery NDSU scene add that CPHD to its `SCENES`
   map (same pattern) and run with `--deci 2 --grid 8192`. Method + the orientation/transpose pitfall to
   watch for: the `sar-verification-methodology` skill and [PROJECT_SOURCE_OF_TRUTH.md](PROJECT_SOURCE_OF_TRUTH.md).

Note: the SAR datapath (RTL + firmware) is **unchanged** from the 250T build that was proven on silicon
(corr ~0.97 vs golden, phase-exact FFT); only the wrapper/board/storage differ. So for Discovery
bring-up, a `[MATCH]` plus a cleanly focused `focused.png` is normally sufficient — reach for the full
emulator diff only if the image looks wrong.

## Diagnose a focus-pipeline stall (thin client, no JTAG)
If the app boots but never reaches `[sar] DONE` (stuck at `focus pipeline...`), use the **diagnostic
payload** to see which stage is running and whether it is *advancing* or *frozen* — no Libero, no JTAG,
no board programming, just a card re-flash + UART.

1. **Get the diagnostic payload** (built with `SAR_DIAG_UART`, streams live progress on the app UART):
   ```
   git pull            # brings mpfs/deliver/payload_debug.bin
   ```
2. **Pack a diagnostic card** (same as Path B, but point `--payload` at the debug payload):
   ```
   python mpfs/host/sd_pack.py --gpt --payload mpfs/deliver/payload_debug.bin \
       --stage jtag_stage --out sar_sd_debug.img
   ```
   Write `sar_sd_debug.img` to the card (balenaEtcher), insert, power-cycle.
3. **Watch the app UART (COM6)** with the monitor (needs only `pyserial`):
   ```
   pip install pyserial
   python mpfs/host/watch_sar_uart.py --port COM6 --stall 120
   ```
   It timestamps every line, prints `>>> STAGE: <name>` at each stage, and flags a **STALL** if the
   UART goes quiet for `--stall` seconds inside a stage. Reading it:
   - a `>stage` banner then a `resample-1 512/8167 … 1024/8167 …` counter **climbing** → that stage is
     **churning (just slow)** — resample legitimately takes ~100 s;
   - a banner then the counter **frozen** and the UART **goes silent** → that stage **hard-stalled**.

> **This board's stall is a HARD AXI freeze — do NOT wait for a `FAIL` code.** A 41-min run
> (`DISCOVERY_BRINGUP_ISSUES.md` Issue #4) proved the U54 sticks on an AXI load that never returns, so
> the `[sar] FAIL form_image = SAR_SEQ_TIMEOUT_*` line **never prints** (the bounded-wait timeout can't
> fire when the CPU is frozen mid-load). The localization is the **last banner/heartbeat before the UART
> goes silent** — that names the stalled stage, and the stage maps to the guilty AXI target (the same
> verdict `run_app_pc_probe.sh` gives from the PC, here over UART with no JTAG):
>
> | last stage before silence | guilty access |
> |---|---|
> | `resample` | `K_RESAMPLE @0x60003000` (or its DDR gather over FIC0) |
> | `window` | `K_WINDOW @0x60001000` |
> | `rangeFFT` / `azimuthFFT` | `K_FFT @0x60004000` (or the FFT DMA S2MM over FIC0) |
> | `cornerturn` | `K_CORNER_TURN @0x60000000` |
> | `detect` | CPU→DDR only (no kernel) → the **DDR/FIC0** path |

The stages emit `resample → window → rangeFFT → cornerturn → azimuthFFT → detect`. The production
`payload.bin` is unaffected — it has no diagnostic prints (the instrumentation is compile-guarded off by
default).
