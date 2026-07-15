# MPFS095T / Discovery Kit port — plan, status, and delivery

**Goal.** Ship the SAR image former to the **PolarFire SoC Discovery Kit (MPFS095T-FCSG325)** as a
delivery product: the engineer builds a signed FlashPro Express `.job`; a non-engineer colleague
programs it (no Libero) and loads a CPHD-derived scene onto a **microSD card** from a PC.

This repo (`mpfs095t-sar-ifp`) is a **standalone derivative** of `mpfs250t-sar-ifp`: the datapath
RTL/HLS and firmware are shared (identical source); only the *wrapper* (device, pinout, MSS config,
storage) is retargeted. `mpfs250t-sar-ifp` remains the dev/debug repo (Icicle, JTAG, eMMC).

## Confirmed decisions (2026-07-14)

| Decision | Choice |
|---|---|
| Delivery board | **Discovery Kit — MPFS095T-FCSG325**, LPDDR4 |
| Build ownership | **We build** the signed FlashPro Express `.job`; colleague **only programs** (free FPExpress, no Libero) |
| SD data model | **Raw-sector image** (`SARI` superblock @ LBA 0); colleague images the card on a PC (balenaEtcher / `dd`) |
| Repo scope | **Standalone** — shared build sources + the 095T build flow + SD tooling + delivery package |

## Why 095T is the binding constraint (from `docs/fpga/DUAL_FIT_AND_DELIVERY.md`)

The 095T is ~37% of the 250T fabric. Estimated fit of the current design on 095T: **~35% 4LUT,
~27% LSRAM (the binding resource), ~6% DSP** — *estimated, not yet built*. Design rules to stay in
budget: strip the bypassed fabric DET kernel (CPU detect ships → frees ~3.8 K LUT), cap parallel
lanes at **≤ 2**, keep the DDR map in the shared cached `0x8000_0000` window, omit the 16k-FFT
combine from the delivery build. **Actual P&R + timing closure at 62.5 MHz is the make-or-break gate.**

## Documentation-check findings (2026-07-14, before finalising the design)

Checked the Discovery reference design + MSS configs + our proven 250T flow. Results:

- **DDR = DDR4** (authoritative: `DDR_SDRAM_TYPE DDR4`, `DDR4_CLOCK_DDR 800` in the reference MSS
  `.cfg`). NOT LPDDR4 (the `DUAL_FIT_AND_DELIVERY.md` claim is **wrong** — corrected there) and NOT
  DDR3 (those params are inactive template defaults). The MSS DDR controller + timing are DDR4-1600.
- **FIC0 embedded DLL is ENABLED** in the vendored + reference Discovery MSS (`FIC_0_EMBEDDED_DLL_USED
  true`). On the 250T this DLL-enabled config **hung the data-plane**; our fix (`mss_nodll`) bypasses
  it. → the Discovery MSS must set `FIC_0/1/2_EMBEDDED_DLL_USED false` for the 62.5 MHz path.
- **microSD is DISABLED everywhere available** (`SD_PORTS_DISABLE true`, `EMMC UNUSED` in BOTH the
  vendored config and the authoritative reference — the reference design runs without SD). **BLOCKER:**
  enabling the microSD correctly needs the Discovery **SD-boot MSS config** (Microchip Discovery
  Linux/HSS BSP) or the Kit schematic — **not present in the local materials**. Do NOT guess the SD
  MSSIO; it would likely fail DDR/SD bring-up and waste a build.
- **Libero SoC 2025.2 is installed**; the reference build flow is the standard SYNTHESIZE → PLACEROUTE
  → VERIFYTIMING (same gated flow as our 250T build).

**Design decision:** de-risk the make-or-break unknown FIRST — build the SAR fabric for **fit + timing
on the 095T with the current (SD-disabled) MSS + the FIC-DLL bypass**. That proves the design fits the
095T LSRAM budget and closes at 62.5 MHz *without* depending on the unresolved SD config.

**SD/boot model — SWITCHED TO HSS (2026-07-14, confirmed).** Instead of a bare-metal SDMMC driver, use
Microchip's **Hart Software Services (HSS)** — the proven Discovery SD-boot layer. HSS (on E51) owns DDR
init + SDMMC + reading the card; our SAR U54 app + the scene data become an **HSS payload**
(`hss-payload-generator`) that HSS loads into DDR from the microSD, then starts the app. This removes
the bare-metal SD-enable blocker (no SD MSS surgery), keeps the fabric bitstream + pipeline unchanged,
and is the vendor-standard flow. Source is local: `github/polarfire-soc/hart-software-services` (+ bare-
metal examples, PolarFire SoC docs, Icicle baremetal/linux MSS cfgs). `sd_pack.py` will produce/feed an
HSS boot image instead of the raw SARI image; the `.job` bundles fabric + HSS in eNVM.

**Fabric build prerequisite (found 2026-07-14):** the per-kernel HLS outputs
(`hls_*/hls_output/scripts/libero/create_hdl_plus.tcl`) are **gitignored** and 4 of the 6 are absent on
disk (`corner_turn`, `detect`, `fft_feeder`, `fft_unloader`; only `window` + `resample` remain). The HLS
C++ source + Makefiles + `config.tcl` ARE in the repo, and **SmartHLS + Libero 2025.2 + `License.dat`
are installed**, so the build sequence is: (1) `shls hw` regenerate the 4 kernels → (2)
`create_fresh_project_disc.tcl` (device `MPFS095T/FCSG325/-1/1.0V` + the regenerated Discovery MSS `.cxz`
+ `sar_io_discovery.pdc`, DET buildable but bypassed) → (3) Libero SYNTH → P&R → VERIFYTIMING gate →
export. ~2–3 h headless; the make-or-break is LSRAM fit + 62.5 MHz closure.

## Discovery hardware facts (from the Microchip reference design)

Source: `github/polarfire-soc/polarfire-soc-discovery-kit-reference-design` (the vendor Libero flow).

- **Device / build target:** `-die {MPFS095T} -package {FCSG325} -speed {-1} -die_voltage {1.0}
  -part_range {EXT}` (note: differs from the 250T's `STD` / `1.05 V`).
- **Fabric pins we use** (`sar_io_discovery.pdc`): `REF_CLK_50MHz` → **R18** (LVCMOS18); debug MMUART
  on the FTDI USB-UART → **W21** (FTDI TXD → SoC RX) / **Y21** (FTDI RXD ← SoC TX). Bank0 = 1.8 V,
  Bank1 = 3.3 V.
- **DDR + microSD are MSS-dedicated** (no fabric pins) — configured in the MSS `.cfg`. **The microSD
  is currently `UNUSED` in the vendored Discovery MSS config** (`EMMC UNUSED`, `EMMC_SD_SWITCHING
  DISABLED`) → it must be enabled (same procedure as the Icicle eMMC-enable). The Discovery microSD
  is a direct card slot (no SD/eMMC demux mux like the Icicle), which simplifies the enable.
- **CoreFFT fits the 095T:** the reference design itself instantiates a `COREFFT_C0` on this device —
  supporting evidence for the fit budget.
- **MSS regen:** `pfsoc_mss -GENERATE -CONFIGURATION_FILE:MPFS_DISCOVERY_KIT_MSS.cfg` → the `.cxz`
  component (same headless flow we used on the Icicle).

## Workstreams and status

> **▶ 2026-07-15: workstreams ①–⑧ are DONE (board-free build complete). Only ⑨ (on-board) remains.**
> The plan below is retained for context; the SD path became **GPT SD-boot via HSS** (not raw LBA 0),
> and the FFT runs on **fabric CoreFFT**.

| # | Workstream | Status | Gated by |
|---|---|---|---|
| ① | **SD data-prep** (`mpfs/host/sd_pack.py --gpt` + `mkpayload.py`) — CPHD stage → GPT SD-boot image (P1 HSS payload, P2 `SARI` scene @ LBA 67584, OUT @ 657408) | **DONE + selftests pass** | — |
| ② | **095T repo base** (standalone derivative of the 250T repo) | **DONE** (this repo) | — |
| ③ | **095T build flow** — Libero `-die MPFS095T -package FCSG325 -speed -1 -die_voltage 1.0`, 62.5 MHz CCC | **DONE** — `create_fresh_project_disc.tcl` + `build_disc.tcl` | — |
| ④ | **Discovery FCSG325 pinout `.pdc`** | **DONE** — `mpfs/fpga/constraints/sar_io_discovery.pdc` | — |
| ⑤ | **Discovery MSS + DDR4 + SD** wired for SAR — stripped to DDR4+FIC_0+MMUART_0+SD (unused peripherals disabled to fit FCSG325 I/O), regen `fpga_design_config` | **DONE** — `mss_discovery/DISCOVERY_SAR_MSS.cfg` | — |
| ⑥ | **Firmware SD read path** — `sar_sd.c` (`card_type=SD`, 4-bit, no Icicle mux; `SARI`@LBA 67584 → DDR → JOB) + autonomous boot (FFTMODE=1 fabric) | **DONE** — commit `83ef8ff` | board to validate runtime |
| ⑦ | **Bitstream build + timing close on 095T** → export `.job` (fabric + HSS eNVM bundled) | **DONE** — timing MET @62.5 MHz (setup +ve, hold +ve), `mpfs/deliver/sar_top_095t.job` | — |
| ⑧ | **Delivery package** — operator runbooks + one-click launcher + delivery bundle | **DONE** — `mpfs/deliver/` (`.job` + `program.bat` + `README.md`), `docs/PROGRAM_THE_BOARD.md`, `docs/SD_PROVISIONING.md` | — |
| ⑨ | **On-Discovery bring-up** — program `.job`, write `--gpt` SD, DDR train, SD read, run pipeline, verify focused image | **PENDING** | Discovery board (colleague/engineer side) |

## The critical path / risk gates

1. **Discovery pinout (④)** blocks the build — you cannot P&R a board-correct bitstream without the
   FCSG325 pin assignments. Fastest source: the public **PolarFire SoC Discovery Kit reference
   design** (Microchip `polarfire-soc` GitHub) or the Kit schematic/user guide. Next action item.
2. **Fit + timing (⑦)** — LSRAM ~27% is *estimated*; only P&R proves it fits AND closes at 62.5 MHz.
   Board-independent, so we run it headless here once ④ exists. If it overflows LSRAM, fall back to
   1 lane / strip the 16k combine (already planned).
3. **Discovery DDR (LPDDR4) + SD bring-up (⑤⑥⑨)** need the actual Discovery board — done colleague-side
   or when we have one. The vendored `boards/mpfs-discovery-kit/` MSS config is a start, not verified.

## Documentation needed

**To obtain (blocks the build / bring-up):**
- **PolarFire SoC Discovery Kit — schematic + user guide** (FCSG325 pinout; how the microSD is wired
  to the MSS SDMMC; DDR/UART/REFCLK pins). → workstream ④.
- **MPFS095T datasheet** — exact LSRAM/DSP/LUT counts to confirm the fit budget binds where expected.
- **FlashPro Express user guide** — the `.job` production + `RUN_PROJECT` CLI for `program.bat`. → ⑧.
- Confirm the vendored Discovery **LPDDR4 MSS config** matches the colleague's board revision.

**We will produce (for the colleague):**
- `docs/SD_PROVISIONING.md` — run `sd_pack.py`, image the card, insert + power on.
- `docs/PROGRAM_THE_BOARD.md` — one-page FlashPro Express operator runbook.
- A handoff skill mirroring `emmc-onboard-pipeline`, retargeted to SD + Discovery.

## Prerequisite software — the colleague (operator side)

The whole point of the delivery model: **no FPGA tools, no license.** Tiered by task:

**Tier 0 — program the board (always).**
- **FlashPro Express** — Microchip's free, standalone production programmer (part of the free
  "Programming and Debug" tools; no Libero license). Used to run the `.job`.
- **FlashPro / embedded-programmer USB driver** (bundled with FPExpress / the Microchip programming
  tools) + a USB cable to the Discovery Kit's embedded FlashPro.

**Tier 1 — prepare the SD card (always).**
- A **microSD card** (≥ ~256 MB; any modern card) + a **USB microSD reader**.
- A **raw disk-imaging tool**: **balenaEtcher** (recommended, cross-platform) or Win32DiskImager
  (Windows) or `dd` (Linux/macOS) — to write `sar_sd.img` to the card from LBA 0.

**Tier 2 — regenerate the SD data from a *different* CPHD (ONLY if the colleague builds the image
themselves; NOT needed if we ship a prebuilt `sar_sd.img`).**
- **Python 3.9+** and pip packages: **numpy**, **sarpy** (CPHD reader), and **scipy** if the
  reference pipeline uses it. (`sd_pack.py` alone needs only numpy; the CPHD→stage step
  `serialize_inputs.py` is what pulls in sarpy.)
- The repo's host scripts (shipped): `serialize_inputs.py`, `sd_pack.py`, `ddr_layout.py`, and the
  reference modules they import.

**Explicitly NOT needed:** Libero SoC, SoftConsole, SmartHLS, any FPGA/HLS design tool, any license.

> **Recommendation:** ship a **prebuilt `sar_sd.img`** for the target scene alongside the `.job`, so
> the colleague's baseline is just Tier 0 + Tier 1 (no Python). Keep the Tier-2 Python path documented
> for when they want to run a *different* CPHD scene.

## Immediate next steps
1. Obtain the Discovery pinout (④) — unblocks the build.
2. Scaffold the 095T build TCL (③) + `program.bat` (⑧) + operator runbooks (headless, doable now).
3. Write the firmware SD loader (⑥) mirroring the proven eMMC loader.
4. When ④ lands: headless P&R + timing gate (⑦) → the `.job`.
5. Colleague: image an SD card (`sd_pack.py`), program the `.job`, power on, verify (⑨).
