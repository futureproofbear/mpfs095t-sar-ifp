# SAR image former — PolarFire SoC Discovery Kit (`mpfs095t-sar-ifp`)

A spotlight-mode **Synthetic Aperture Radar image-formation processor**: it turns an Umbra
open-data CPHD (radar phase history) into a focused magnitude image, running on a **PolarFire SoC
Discovery Kit (MPFS095T-FCSG325)**. The FPGA fabric does the FFTs (CoreFFT) and the
resample/window/detect/corner-turn kernels; the RISC-V cores drive the pipeline. It boots and runs
**standalone from a microSD card** — no JTAG, no host link at run time.

This repo is **self-contained**: it is the Discovery-Kit SD-boot delivery derivative of the
`mpfs250t-sar-ifp` (Icicle / MPFS250T) development repo. Same SAR datapath, retargeted wrapper. You
do **not** need any sibling checkout.

---

## Status (2026-07-15)

**The board-free build is COMPLETE.** Everything that can be built without the physical board is done,
committed, and timing-closed:

- ✅ **Fabric bitstream + HSS SD-boot loader** — bundled and timing-closed into a single signed
  programming job, [`mpfs/deliver/sar_top_095t.job`](mpfs/deliver/). Program once with FlashPro
  Express. No Libero build needed.
- ✅ **SAR app firmware** — ported to SD-boot and built; ships **prebuilt** as
  [`mpfs/deliver/payload.bin`](mpfs/deliver/payload.bin) (43 KB). You do **not** compile firmware.
- ✅ **Pure-Python microSD tooling** — turn a CPHD scene into a bootable card image with no compiler.

**What remains is board-side only:** program the `.job`, write a microSD, power on, and confirm the
UART reaches `[sar] DONE`. The underlying SAR datapath is already **proven on 250T silicon** (focused
image, corr ~0.97 vs golden; phase-exact fabric FFT) — see [HANDOFF.md](HANDOFF.md).

---

## Taking over this project? Start here

Read these two files first, in order:

1. **This README** — what the project is, the repo map, and how to generate the microSD image.
2. **[HANDOFF.md](HANDOFF.md)** — the SAR *design* and its *verified state* (what is proven on silicon,
   what is open/next). This is the engineering handoff.

Then pick your role:

| You are… | Your goal | Follow |
|----------|-----------|--------|
| **Operator** | Program a board + run a scene | Program the `.job`, then write a microSD (below). No build tools. |
| **Engineer** | Change the design, rebuild, or debug on silicon | [HANDOFF.md](HANDOFF.md) → [`docs/DISCOVERY_PORT.md`](docs/DISCOVERY_PORT.md) → the runbooks in [`docs/fpga/`](docs/fpga/). Start the Claude Code session with the `project-orientation` skill. |

Everything the board needs is in [`mpfs/deliver/`](mpfs/deliver/): the programming job, the launcher,
the prebuilt app payload, and its README.

---

## Repository map

```
mpfs095t-sar-ifp/
├── README.md            ← you are here (start here)
├── HANDOFF.md           ← SAR design + verified state (read second)
├── CLAUDE.md            ← engineering discipline for this repo
├── mpfs/
│   ├── deliver/         ← THE DELIVERY: sar_top_095t.job, program.bat, payload.bin
│   ├── host/            ← pure-Python host tools (build the SD image, emulator, dumps)
│   └── fpga/            ← Libero design, HLS kernels, SAR app source (engineer only)
├── src/
│   └── form_image_pfa.py  ← laptop golden reference (download CPHD → focus → GeoTIFF)
├── docs/                ← all documentation (index below)
├── reference/           ← vendor IP user guides, datasheets
└── .claude/             ← Claude Code skills + agents (accumulated project knowledge)
```

### Documentation index

The `docs/` tree is large; you do not need all of it. The ones that matter, grouped:

| To… | Read |
|-----|------|
| **Generate the microSD `.img`** | [`docs/SD_PROVISIONING.md`](docs/SD_PROVISIONING.md) (full detail; recipe also below) |
| **Program the board** | [`docs/PROGRAM_THE_BOARD.md`](docs/PROGRAM_THE_BOARD.md) |
| Understand the Discovery-Kit port + boot flow | [`docs/DISCOVERY_PORT.md`](docs/DISCOVERY_PORT.md), [`docs/HSS_INTEGRATION.md`](docs/HSS_INTEGRATION.md) |
| Understand the SAR architecture + validation | [`docs/fpga/SAR_ARCHITECTURE_REPORT.md`](docs/fpga/SAR_ARCHITECTURE_REPORT.md) |
| Rebuild the fabric / bring up on silicon (engineer) | [`docs/fpga/LIBERO_HEADLESS_PLAYBOOK.md`](docs/fpga/LIBERO_HEADLESS_PLAYBOOK.md), [`docs/fpga/SILICON_ISO_TEST_RUNBOOK.md`](docs/fpga/SILICON_ISO_TEST_RUNBOOK.md), [`docs/fpga/SMARTDEBUG_RUNBOOK.md`](docs/fpga/SMARTDEBUG_RUNBOOK.md) |
| Find the authoritative status / avoid re-deriving | [`docs/PROJECT_SOURCE_OF_TRUTH.md`](docs/PROJECT_SOURCE_OF_TRUTH.md) |

---

## Run the delivery: two steps

### 1. Program the board (once)

Run [`mpfs/deliver/program.bat`](mpfs/deliver/program.bat) (or open `sar_top_095t.job` in **FlashPro
Express** and hit RUN). Needs only the free FlashPro Express tool + a FlashPro programmer. Details:
[`docs/PROGRAM_THE_BOARD.md`](docs/PROGRAM_THE_BOARD.md).

### 2. Generate the microSD image (`sar_sd.img`)

The board reads its scene from a **GPT-partitioned microSD**: P1 = the prebuilt SAR app, P2 = the
scene (from a CPHD), plus a reserved region where the board writes the focused image back. You build
that card image on a PC with the pure-Python tools in this repo — **no firmware build, no SoftConsole,
no Libero.**

**Prerequisites (once):**
```bash
pip install numpy sarpy          # add scipy if prompted
```

**Step A — get a CPHD scene.** Any Umbra open-data spotlight `CPHD.cphd` works — the exact scene is
**not required** to run the system; a specific one is only needed to reproduce the shipped reference
image. Catalog: `s3://umbra-open-data-catalog` (us-west-2, anonymous HTTPS — no AWS account), layout
`sar-data/tasks/<task>/<uuid>/<timestamp>_UMBRA-NN/`.

The **exact scene the shipped image was built from** (download this to reproduce it):
```
https://umbra-open-data-catalog.s3.us-west-2.amazonaws.com/sar-data/tasks/North+Dakota+State+University+Plot/8d5a3c80-a3dc-47b2-bf31-f3921b8c0f39/2023-11-10-16-16-44_UMBRA-04/2023-11-10-16-16-44_UMBRA-04_CPHD.cphd
```
| field | value |
|-------|-------|
| task | `North Dakota State University Plot` |
| uuid | `8d5a3c80-a3dc-47b2-bf31-f3921b8c0f39` |
| capture | `2023-11-10-16-16-44_UMBRA-04` |
| native dims | 8167 pulses × ~9000 samples → stage with `--deci-sample 2` (below) |

**Step B — stage the CPHD into pipeline inputs.** The pipeline grids to a fixed 8192×8192, so both
capture dimensions must be ≤ 8192. For the NDSU scene above the sample axis is ~9000 (> 8192), so
decimate it by 2:
```bash
python mpfs/host/serialize_inputs.py --in 2023-11-10-16-16-44_UMBRA-04_CPHD.cphd --grid 8192 \
    --deci-pulse 1 --deci-sample 2 --out jtag_stage
```
If it errors `scene MxN exceeds GRID_MAX 8192`, raise decimation on the offending axis until both fit
(`--deci-pulse` = pulse/azimuth axis, `--deci-sample` = sample/range axis). It prints the final dims
and a geometry self-check (`corr≈1.000` = good).

> **Why decimate, not crop to 8192?** The CPHD axes are *phase history* (pulses × frequency samples),
> not image pixels — cropping them does **not** crop the output to a sub-scene; it uniformly shrinks
> the aperture/bandwidth and degrades focus over the *whole* image. Decimation (uniform downsample)
> keeps the entire scene in frame at coarser resolution, which is why the tool only offers `--deci-*`
> and no crop knob.

**Step C — pack the bootable card image** (prebuilt payload + your staged scene):
```bash
python mpfs/host/sd_pack.py --gpt --payload mpfs/deliver/payload.bin \
    --stage jtag_stage --out sar_sd.img
```
It self-verifies (GPT signatures/CRCs, payload GUID, every scene-blob CRC) and prints the minimum
microSD size (~475 MB).

**Step D — write `sar_sd.img` to a microSD** (≥ ~475 MB) with **[balenaEtcher](https://etcher.balena.io/)**
(Flash from file → select image → select card → Flash), Win32DiskImager, or `dd`. ⚠️ This erases the
whole card — use a dedicated one.

Insert the card into the board's microSD slot and power-cycle. Progress prints on the UART (115200
8N1); success is `[sar] DONE`.

> Full walkthrough, both the prebuilt-image path and the generate-it-yourself path, and how the GPT
> addressing works: **[`docs/SD_PROVISIONING.md`](docs/SD_PROVISIONING.md)**.
> Quick check that the tools work without a card: `python mpfs/host/sd_pack.py --selftest`.

---

## Run board-free (laptop reference + silicon emulator)

You can develop and validate the whole SAR pipeline without any hardware.

**Golden reference** — download a CPHD, focus it with the Polar Format Algorithm, write a detected
GeoTIFF:
```bash
python src/form_image_pfa.py
```
First run downloads the ~196 MB CPHD into `data/` (anonymous HTTPS). Key knobs at the top of the file:
`MODE` (`"pfa"` ~12 s / `"quicklook"` ~7 s), `DECIMATE_PULSE`/`DECIMATE_SAMPLE`, `ESTIMATE_ONLY`,
`SAVE_GEOTIFF`.

**Bit-accurate silicon emulator** — a fixed-point mirror of the on-silicon datapath (value-equals the
golden); predicts exactly what the board produces:
```bash
python mpfs/host/silicon_emulator.py
```

## Requirements

- **Program + provision (operator):** FlashPro Express (free) + a FlashPro programmer; a microSD card
  (≥ ~475 MB) + reader; balenaEtcher. For generating the image: Python 3.9+ with `numpy` + `sarpy`.
- **Laptop reference:** `numpy`, `scipy`, `matplotlib`, `sarpy`, `rasterio`, `pyproj`.
- **Fabric rebuild / silicon bring-up (engineer):** Microchip Libero + SoftConsole + a FlashPro6.
  See [`docs/fpga/`](docs/fpga/).
