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

| # | Workstream | Status | Gated by |
|---|---|---|---|
| ① | **SD data-prep script** (`mpfs/host/sd_pack.py`) — CPHD stage → raw `SARI` SD image @ LBA 0 | **DONE + selftest passes** | — |
| ② | **095T repo base** (standalone derivative of the 250T repo) | **DONE** (this repo) | — |
| ③ | **095T build flow** — Libero project `-die MPFS095T -package FCSG325 -speed -1 -die_voltage 1.0`, DET stripped, ≤2 lanes, 62.5 MHz CCC | TODO (scaffold next) | — (pinout resolved) |
| ④ | **Discovery FCSG325 pinout `.pdc`** | **DONE** — `mpfs/fpga/constraints/sar_io_discovery.pdc` (from the reference design) | — |
| ⑤ | **Discovery MSS + LPDDR4 + SD** wired for the SAR datapath — **must ENABLE the microSD** (vendored MSS cfg ships EMMC/SD UNUSED) + FIC0 + DDR map, regen `fpga_design_config` | TODO | Discovery board to verify DDR/SD |
| ⑥ | **Firmware SD read path** — `sar_sd_load` (card_type=SD, read `SARI`@LBA 0 → DDR role addrs → JOB), mirror of the proven eMMC loader | TODO | ⑤ |
| ⑦ | **Bitstream build + timing close on 095T** → export `.job` (fabric + eNVM firmware bundled) | **GATED** | ③④ + Libero P&R (~1 h headless) |
| ⑧ | **Delivery package** — `program.bat` (`FPExpress.exe RUN_PROJECT`), FPExpress installer note, one-page operator runbook | TODO (scaffold) | ⑦ for the real `.job` |
| ⑨ | **On-silicon bring-up** — DDR train, SD read, run pipeline, verify focused image | **GATED** | Discovery board (colleague side) |

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
