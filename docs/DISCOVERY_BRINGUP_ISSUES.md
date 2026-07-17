# Discovery Kit bring-up — developer issue list (HSS SD-boot hang)

Handoff for the developer on the **Libero SoC host** (builds + programming). First on-silicon boot of
the delivered `mpfs/deliver/sar_top_095t.job` on a PolarFire SoC Discovery Kit (MPFS095T-FCSG325)
**fails**: HSS boot-loops and the SAR app never starts. This doc is self-contained — symptom, what is
already ruled out, the **root cause** (found 2026-07-17), and a ranked set of issues with concrete steps
and acceptance criteria. **Read the 2026-07-17 board update immediately below first** — the IHC hang is
now confirmed fixed on silicon and the blocker has moved. Full context:
[DISCOVERY_PORT.md](DISCOVERY_PORT.md) workstream ⑨.

> **▶ 2026-07-17 — BOARD UPDATE (engineer laptop, live COM4/COM6 capture of the new IHC-free `.job`).**
> The bring-up has moved **two stages forward**; the issue list below is now largely historical.
>
> - **Issue #1a CONFIRMED FIXED on silicon.** The `Initializing Mi-V IHC` line **never appears** and the
>   old ~28.7 s reset is gone. HSS boots all the way through to its service **superloop** — COM4 prints a
>   `[t] loop N took … ticks (max …)` heartbeat with the uptime climbing, i.e. DDR trained and the payload
>   loaded. (Multiple clean power-on boots; timestamps restart at `[0.xx]` on each real reset.)
> - **The SAR app now launches.** COM6 shows `… load scene from SD (P2)... ok` followed by
>   `[sar] focus pipeline...` → the HSS→payload handoff and the microSD scene load both work.
> - **NEW BLOCKER — the focus pipeline does not finish.** No run has reached `save OUT`/`DONE`, and
>   `read_sd_out.py` confirms the card OUT region is **empty** (`magic=0x00000000`, PhysicalDrive1). One run
>   printed `focus pipeline... ok` (a completion), yet another ran **9.5 min undisturbed stuck at
>   `focus pipeline...`** with no `ok` and no `[sar] FAIL`. The stall is therefore **intermittent** — the
>   fingerprint of marginal timing / shared-interconnect contention, not a deterministic logic bug.
>   → **new focus of the loop: [Issue #4](#issue-4--p0-current-blocker-focus-pipeline-stalls-intermittently-no-save-out).**
>   Issues #1/#2/#3 are moot unless a future rebuild regresses HSS.
>
> **⚠ UART port correction:** HSS prints on **COM4**, but the **SAR app (`[sar] …`) prints on COM6** — a
> *different* FlashPro5 channel (a separate MMUART instance). The old symptom below assumed the app would
> appear on COM4; it does not. **Watch COM6 for the app**, COM4 for HSS.

## Who does what (two machines)

| Machine | Has | Does |
|---|---|---|
| **Engineer laptop** (thin client) | microSD reader, UART terminal (COM4), Python (`numpy`/`PIL`/`pyserial`), this repo | Capture UART, provision/read the SD card, verify the focused image |
| **Libero host** (developer — YOU) | Libero SoC 2025.2, SoftConsole 2022.2 RISC-V gcc, HSS source, `fpgenprog`, FlashPro | Edit/rebuild HSS, re-export the `.job`, program the board |

The bring-up is a loop between the two: **you** rebuild + program on the Libero host, the engineer
power-cycles + captures the UART and reports back.

## Confirmed symptom (captured live, COM4 @ 115200 8N1)

Every boot HSS prints only this, then the MSS is fully reset ~28.7 s later, forever:

```
HSS: decompressing from eNVM to L2 Scratch ... Passed
[0.43] wdog_service monitoring [u54_1] [u54_2] [u54_3] [u54_4]
[0.50] beu_service :: [init] -> [monitoring]
[0.57] Initializing Mi-V IHC V2        <-- last line every cycle, then silence -> reset
```

Internal timestamps restart each cycle (0.43 / 0.50 / 0.57) → it is a real hardware/watchdog reset,
not a software loop. There is **no** DDR-training output, **no** MMC/GPT boot, **no** HSS version
banner, **no** "Press a key to enter CLI" prompt. `u54_1()`'s `[sar] …` banner never appears, so the
SAR app (scene load / pipeline / save-out) is entirely untested — the failure is upstream in HSS's
own bring-up.

## Ruled out (do not re-investigate)

- **The microSD** — identical hang with the card removed. Not the SD image, `SARI` scene,
  `sd_pack.py`, or the SAR payload.
- **FIC embedded DLL** — `FIC_0/1/2/3_EMBEDDED_DLL_USED false` is already set in
  `mpfs/fpga/mss_discovery/DISCOVERY_SAR_MSS.cfg`.
- **DDR type** — our MSS and the vendored `boards/mpfs-discovery-kit` MSS both set
  `DDR_SDRAM_TYPE DDR4`, `DDR4_CLOCK_DDR 800` (DDR4-1600).
- **Fabric clock / CCC / PLL** — the MSS boots on its own 80 MHz SCB clock before MSS clock config,
  independent of the fabric CCC (confirmed in the proven 250T bring-up). The DDR hang is not gated on
  the fabric clock.

## Root cause (found 2026-07-17, from the HSS source on the build machine)

The hang is **not** DDR — DDR training is never reached. It is HSS's **Mi-V IHC init poking a fabric
IHC IP that this bitstream does not contain**. Evidence, all from
`polarfire-soc/hart-software-services`:

- `HSS_IHCInit` is entry **#1** in `application/hart0/hss_registry.c: globalInitFunctions[]` (gated by
  `CONFIG_USE_IHC_V2`), a few entries **ahead of `HSS_LogoInit`** (the banner). The boot stops at the IHC
  print with **no logo, no version banner, no DDR output after it** → IHC init never returns.
- The disco-kit defconfig **enables it**: `boards/mpfs-disco-kit/def_config:133` → `CONFIG_USE_IHC_V2=y`.
- IHC init writes fabric registers: `IHC_global_init()` (`baremetal/drivers/fpga_ip/miv_ihc/miv_ihc.c`)
  dereferences `ihc_base_address[][]`, built on `COMMON_AHB_BASE_ADD 0x50000000` — a **fabric** address.
- Our fabric design instantiates **no IHC IP** (`grep -ri IHC mpfs/**/*.{v,cfg,tcl}` → only docs). So the
  AXI access to `0x50000000` gets no slave response → the E51 stalls → watchdog resets at ~28.7 s.
- The SAR app does not use IHC: E51 (`application/hart0/e51.c`) wakes **U54_1 only** and idles; there is
  no AMP/RPMsg peer. IHC is dead weight for this design.

This also corrects one "ruled out" item: the fabric-clock argument was scoped to **DDR** only. IHC is a
**fabric** peripheral, so fabric presence/readiness was never actually ruled out for this hang.

**Do Issue #1a first — it is a one-line config change that is very likely the fix, not just a probe.**

---

## Issue #1a — [P0, ROOT CAUSE] Disable Mi-V IHC in the HSS build

> **✅ APPLIED + BOARD-CONFIRMED 2026-07-17. The `Initializing Mi-V IHC` line is gone and HSS boots
> through to its superloop on silicon (see the top board update) — this fix is verified, not just applied.
> Delivered `.job` sha256 `e32ed6443675d4656523848bdcb3331c50462befdabb8ba22a15802387063868`.**
>
> HSS was **clean-rebuilt** with `# CONFIG_USE_IHC_V2 is not set` (via `build_hss.sh`) and the delivery
> `.job` re-exported with the new HSS in eNVM (no fabric re-P&R). Proven IHC-free before shipping:
> ```
> riscv64-unknown-elf-nm  build/hss-l2scratch.elf | grep -i ihc          # empty
> riscv64-unknown-elf-strings build/hss-l2scratch.elf | grep -i "Mi-V IHC" # empty
> objcopy -I ihex -O binary <embedded.hex> b.bin; strings b.bin | grep -i ihc  # empty
> ```
> And the eNVM data really changed in the job: `bitstream_digest` `98a78d7c…` (original, IHC) →
> `8647ecec…` (new); `program_envm0=true`. Since the fabric P&R is unchanged, the digest delta *is* the
> eNVM/HSS content.
>
> **⚠ The trap that cost a board cycle: `make clean` is mandatory.** An incremental rebuild after
> flipping the Kconfig linked stale objects and shipped a binary that was IHC-free but not the final
> one; more importantly, a bare `export_prog_job` without regenerating programming data reuses the old
> eNVM. `build_hss.sh` now always `make clean`s, and the export (`build_disc_bootable.tcl`) does
> `configure_envm` → `GENERATEPROGRAMMINGDATA` → `export_prog_job`, not a bare export.
>
> **On-board litmus test:** the new HSS binary contains **no** "Initializing Mi-V IHC" string, so it
> physically cannot print that line. On the next boot with the new `.job`:
> - line **gone** → new eNVM is running. If it now hangs later (DDR/SD), that is a *different* issue → Issue #1.
> - line **still there** → the chip is still running the OLD eNVM: either the wrong/old `.job` was
>   programmed (check the sha256 above) or FlashPro programmed FABRIC only and skipped eNVM (ensure the
>   PROGRAM action includes the eNVM component). Not a code problem.
>
> The steps below are retained for reproducibility / a fresh HSS clone.

**Goal:** stop HSS initializing a fabric IHC block the bitstream doesn't have. The app never needed it.

Steps (Libero host):
1. In the HSS source, edit `boards/mpfs-disco-kit/def_config` and turn IHC off:
   ```diff
   -CONFIG_USE_IHC_V2=y
   +# CONFIG_USE_IHC_V2 is not set
   ```
   (`CONFIG_HSS_USE_IHC` is already unset; this removes `HSS_IHCInit` from `globalInitFunctions[]`.)
2. Rebuild HSS and re-export the `.job` (recipe below in Issue #1 / [HSS_INTEGRATION.md](HSS_INTEGRATION.md)).
   `make BOARD=mpfs-disco-kit` picks up the changed defconfig — confirm `.config` no longer has
   `CONFIG_USE_IHC_V2`.
3. Program, power-cycle, capture COM4.

**Decision tree:**
- Boots past `Initializing Mi-V IHC` → prints the HSS logo/banner and proceeds to DDR/MMC → **IHC was
  the blocker.** Continue to the acceptance criteria; if it now stops somewhere in DDR/MMC, go to
  Issue #1 (turn DDR prints on) — but that is a *new*, later hang, not this one.
- Still stops at the exact same point → IHC was not the (sole) trigger; fall through to Issue #1.

Do this **in the same rebuild** as Issue #1 (disable IHC *and* enable DDR prints) to spend one
program-and-boot cycle instead of two.

## Issue #1 — [P1, FALLBACK] HSS hangs after Mi-V IHC init; make it tell us where

**Goal:** turn on DDR-training telemetry so the boot log shows whether DDR trains and where it stops.

Steps (Libero host):
1. In the HSS source, edit the disco-kit board's mpfs-hal config
   `boards/mpfs-disco-kit/mpfs_hal_config/mss_sw_config.h` and ensure these are **defined**
   (uncommented):
   ```c
   #define DEBUG_DDR_INIT
   #define DEBUG_DDR_RD_RW_FAIL
   #define DEBUG_DDR_CFG_DDR_SGMII_PHY   /* add: dumps the SGMII/DDR PHY training detail */
   #define DEBUG_DDR_DDRCFG              /* add: dumps the DDR controller config */
   ```
   (Reference: the vendored bare-metal analog in this repo,
   `mpfs/fpga/libero_sar/softconsole/mpfs-hal-ddr-demo/src/boards/mpfs-discovery-kit/platform_config/envm-scratchpad-release/mpfs_hal_config/mss_sw_config.h`
   lines ~203-207, where `DEBUG_DDR_INIT` is already on.)
2. Rebuild HSS (recipe from [HSS_INTEGRATION.md](HSS_INTEGRATION.md)):
   ```bash
   export SC_INSTALL_DIR="C:/Microchip/SoftConsole-v2022.2-RISC-V-747"
   export PATH="$SC_INSTALL_DIR/riscv-unknown-elf-gcc/bin:$PATH"
   cd <hss>/hart-software-services
   make BOARD=mpfs-disco-kit defconfig
   grep -q CONFIG_CC_USE_SOFTCONSOLE=y .config || echo CONFIG_CC_USE_SOFTCONSOLE=y >> .config
   make BOARD=mpfs-disco-kit           # -> Default/hss.hex
   ```
3. Re-export the `.job` with the new `hss.hex` as the eNVM client (same Libero design as the delivered
   job), and program the board.
4. Engineer captures COM4 again on power-up.

**Decision tree from the new log:**
- DDR-training lines print, then hang mid-training / a `*_FAIL` line → **DDR training is the bug**
  → go to Issue #2 (validate/fix the DDR4 config).
- DDR training completes ("training pass" / a DDR write-read PASS), then hang before/around the MMC
  or payload-load step → the bug is **after DDR** (MMC controller access or payload handoff)
  → open a follow-up with that log; suspect the SDMMC controller enable in HSS's MMC service.
- Still nothing after "Initializing Mi-V IHC V2" even with prints on → HSS is faulting *at* the
  transition into the service superloop (e.g. an exception before DDR) → capture the E51 mcause/mepc
  (HSS trap handler) or attach a debugger to the E51 at that point.

## Issue #2 — [P1] DDR4 config has never been validated on this silicon

Only reachable if Issue #1 shows DDR training is the hang. The vendored Discovery MSS DDR config is a
starting point, **not verified against a real board** (noted in DISCOVERY_PORT.md risk gate 3).

Steps (Libero host):
1. Build Microchip's stock `mpfs-hal-ddr-demo` for `BOARD=mpfs-disco-kit` (DDR test with prints on)
   and program it standalone. This is a pure DDR bring-up, no HSS, no fabric dependency.
   - Trains + read/write PASS → the DDR4 config is fine; the hang is elsewhere (back to Issue #1's
     "after DDR" branch).
   - Hangs / fails → it is the DDR4 parameters vs the **actual memory device** on this board. Get the
     board's DRAM part number (schematic / Kit user guide) and regenerate the MSS DDR settings for
     that exact device (`pfsoc_mss -GENERATE`), then rebuild HSS.
2. Confirm the DRAM is genuinely DDR4 (not LPDDR4) for this board revision from the schematic — the
   DDR4-vs-LPDDR4 question was flipped once during the port on documentary evidence, never on silicon.

## Issue #3 — [P2, FALLBACK] Drop HSS: ship a boot-mode-1 eNVM app that reads the SD directly

If HSS bring-up becomes a rabbit hole, switch to the **proven** boot model from the 250T repo
(`futureproofbear/mpfs250t-sar-ifp`), which never used HSS: the SAR app runs from eNVM at power-up,
trains DDR itself via bare-metal `mpfs-hal`, and reads its data from the card.

- The SD driver already exists: `sar_sd.c` (`card_type=SD`, 4-bit, 3.3 V) — the same one the app uses
  today. Only the *loader* changes (eNVM boot-mode-1 app instead of HSS payload), not the SD/scene
  logic.
- Package the app ELF as an eNVM client in the `.job` (or program via `mpfsBootmodeProgrammer.jar
  --bootmode 1` + `fpgenprog`, as the 250T did). Still a single `.job`; the colleague still only
  programs it and inserts the card. This removes the unproven HSS layer entirely.
- This is a real firmware/linker effort (boot-mode-1 startup, eNVM placement, DDR self-train), so it
  is the fallback, not the first move.

## Issue #4 — [P0, CURRENT BLOCKER] Focus pipeline stalls intermittently (no save-out)

**Symptom (COM6, IHC-free `.job`, 2026-07-17):** the app reaches `[sar] focus pipeline...` and then, on a
stuck run, prints nothing further for **9.5+ min** with the board left untouched — no `ok`, no
`[sar] FAIL … = 0x…` — while HSS keeps heartbeating on COM4 (the board is alive, only the U54 app is
wedged). A *separate* run printed `focus pipeline... ok`, so the stall is **intermittent**.
`read_sd_out.py` confirms the card OUT region is empty → no image was ever formed or saved.

**Why the UART can't localize it yet:** `sar_form_image()` (`sar_sequencer.c`) prints only
`focus pipeline...` at the start and `ok` at the very end — **no per-stage output** — so the exact stalling
stage is invisible from the console. The per-stage waits are bounded (`spins = 0x40000000`) and *would*
eventually return `SAR_SEQ_TIMEOUT_*` → `[sar] FAIL form_image = <code>`; not seeing a FAIL in 9.5 min means
either the hart is **hard-stalled on a fabric AXI load that never returns** (so the bounded-wait code never
runs) or the timeout is longer than observed. Either way the stall is in the **fabric datapath**, not the
CPU sequencer.

**Prime suspect — the FFT/DMA streaming path.** The sequencer's own comments flag exactly this as a
shared-interconnect contention stall (range/azimuth FFT: *"the DMA is still flushing transform t's output
while the feeder pulls t+1's input over the shared interconnect → CoreFFT drops BUF_READY and the pipeline
locks up"*). Intermittency fits a timing/arbitration race there. The corner-turn transpose (256 MiB
DDR↔DDR over the same non-coherent FIC0) is the second suspect.

Steps to localize (ranked):
1. **Make the stalling stage visible.** Either (a) add one UART line before/after each stage
   (resample / window / rangeFFT / cornerturn / azimuthFFT / detect) in `sar_form_image` and rebuild the
   **payload only** (no fabric re-P&R; re-pack the card with `sd_pack.py`), or (b) read
   `SAR_PROG @ 0xB0059100` (`pass / idx / total / heartbeat`) live over SmartDebug — shows the stalling
   stage *and* whether its index is still advancing, with no rebuild.
2. **A/B the FFT path.** `u54_1.c` hard-writes `SAR_FFTMODE=1` (fabric CoreFFT) at boot; flip that one
   line to `0` (CPU `sar_cpu_fft`, the always-correct fallback) + payload rebuild. If the pipeline then
   completes, the fabric FFT streaming/re-arm is the culprit (slow but proves it out).
3. Once the stage is known, **gate its timing**: confirm P&R **hold** on that kernel's clock domain and
   the FIC0 path (intermittent ⇒ suspect a marginal hold or a CDC), and check that kernel's AXI handshake
   against its golden TB before changing RTL (project rule: read the reference before fixing).

**Acceptance:** a run reaches `[sar] save OUT to SD... ok → DONE`, and `read_sd_out.py` returns
`CRC32 … [MATCH]` with a clean `focused.png`.

---

## Acceptance criteria (how the engineer confirms a fix)

A good boot prints this on COM4 and stops:
```
[sar] Discovery microSD autonomous boot
[sar] FFTMODE=1 (fabric CoreFFT)
[sar] init microSD... ok
[sar] load scene from SD (P2)... ok
[sar] focus pipeline... ok
[sar] save OUT to SD... ok
[sar] DONE
```
Then the engineer pulls the card and reads the image back with `read_sd_out.py` — full run-and-verify
procedure (power-on → UART → dump OUT → CRC + render → is-it-correct) in
[SD_PROVISIONING.md](SD_PROVISIONING.md) §§ "Run the scene on the board" / "Verify the FOCUSED IMAGE" /
"Is the focused image correct?". A `CRC32 ... [MATCH]` (image on the card is intact) **plus** a cleanly
focused `focused.png` (image is correct, not just intact) closes workstream ⑨.

## Reference

- UART capture: 115200 8N1 on the FlashPro5 USB-UART. Three ports enumerate (COM4/5/6 on the engineer
  laptop): **HSS prints on COM4**, the **SAR app (`[sar] …`) prints on COM6** (COM5 idle). Watch COM6 for
  the app. Any terminal (PuTTY / Tera Term) or a logged serial read works; a headless multi-port capture
  that reconnects through the USB re-enumeration a power-cycle causes is in
  `scratchpad/capture.py` (session-local).
- Boot flow + addresses: [HSS_INTEGRATION.md](HSS_INTEGRATION.md), [DISCOVERY_PORT.md](DISCOVERY_PORT.md).
- Firmware: `mpfs/fpga/libero_sar/softconsole/mpfs-hal-ddr-demo/src/sar/sar_sd.c`,
  `.../application/hart1/u54_1.c` (the `#ifdef SAR_SD_BOOT` autonomous path).
