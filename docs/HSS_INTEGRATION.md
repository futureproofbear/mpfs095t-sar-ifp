# HSS SD-boot integration — plan + build recipe (MPFS095T Discovery Kit)

Status checkpoint for the Hart Software Services (HSS) SD-boot path on the Discovery Kit. Feasibility
is **confirmed**; the cross-compile is gated on the fabric timing verdict (no point booting a fabric
that failed timing). Everything below is verified against the local sources, not assumed.

## Boot model (confirmed from the disco-kit def_config)
HSS lives in **eNVM** (programmed once as part of the `.job`). On power-up it:
1. trains DDR4 (`CONFIG_SERVICE_DDR=y`),
2. reads the **GPT-partitioned microSD** (`CONFIG_SERVICE_MMC=y`, `CONFIG_SERVICE_BOOT_MMC_USE_GPT=y`),
3. loads the **HSS payload** (our SAR app) to DDR and jumps to it
   (`CONFIG_SERVICE_BOOT_DDR_TARGET_ADDR=0x103FC00000`).

`CONFIG_SERVICE_BOOT_USE_PAYLOAD` is **not** set → payload comes from the SD GPT partition, it is NOT
embedded in the HSS image. This removes the bare-metal "microSD disabled" blocker: HSS owns the SD/MMC
+ DDR bring-up, the app just runs the SAR pipeline.

## Prerequisites (all present locally — verified)
- HSS source: `polarfire-soc/hart-software-services` with board `boards/mpfs-disco-kit`
  (references `MPFS_DISCOVERY_KIT_MSS_mss_cfg.xml` — the SAME MSS the fabric build uses).
- Payload generator source: `hart-software-services/tools/hss-payload-generator`.
- RISC-V toolchain: `C:/Microchip/SoftConsole-v2022.2-RISC-V-747/riscv-unknown-elf-gcc`.

## Build recipe
```bash
export SC_INSTALL_DIR="C:/Microchip/SoftConsole-v2022.2-RISC-V-747"
export PATH="$SC_INSTALL_DIR/riscv-unknown-elf-gcc/bin:$PATH"
export FPGENPROG="C:/Microchip/Libero_SoC_2025.2/Libero_SoC/Designer/bin64/fpgenprog.exe"
cd polarfire-soc/hart-software-services
make BOARD=mpfs-disco-kit defconfig        # seeds .config from boards/mpfs-disco-kit/def_config
# SoftConsole toolchain (>=2021.3) needs CONFIG_CC_USE_SOFTCONSOLE=y in .config before building:
grep -q CONFIG_CC_USE_SOFTCONSOLE=y .config || echo CONFIG_CC_USE_SOFTCONSOLE=y >> .config
make BOARD=mpfs-disco-kit                   # -> Default/hss.elf, hss.hex (eNVM client for the .job)
```
The `hss.hex` becomes an **eNVM client** in the Libero design (or programmed via `make program`), so
the delivered `.job` carries fabric bitstream + HSS in eNVM.

## Payload = the SAR app (hss-payload-generator)
`tools/hss-payload-generator` consumes a YAML manifest (binary + hart entry + load address) and emits
`payload.bin`. Manifest sketch:
```yaml
set-name: 'sar-app'
hart-entry-points: {u54_1: '0x1000000000'}   # DDR exec addr for the SAR app (match app .lds)
payloads:
  sar_app.bin: {exec-addr: '0x1000000000', owner-hart: u54_1, priv-mode: prv_m}
```
The SAR app binary is the existing u54 firmware (the same pipeline proven on the 250T eMMC M3 path),
recompiled against the disco-kit MSS config.

## SD layout (GPT) vs current sd_pack.py — RESOLVED: option A
`sd_pack.py --gpt` is done (P1 = HSS payload, P2 = 'SARI' scene at fixed LBA 67584 = the app's
`SAR_SD_SCENE_LBA`). The app reads the scene from P2; output-persist (P3) LBA is still to be pinned.
Original analysis retained below.

### (original) Open design decision — SD layout (GPT) vs current sd_pack.py
`sd_pack.py` today writes a **raw `SARI` superblock at LBA 0**, which **collides with a GPT**. For the
HSS path the SD must be GPT-partitioned. Two clean options:

- **A (recommended): two GPT partitions.** P1 = HSS payload (`payload.bin`, the app). P2 = a data
  partition holding the raw `SARI` image (scene). The app reads the scene from P2's first LBA via the
  MMC driver. `sd_pack.py` gains a `--gpt` mode that lays down a protective MBR + GPT with these two
  partitions and drops `SARI` at P2's start. Keeps scene addressing self-describing (TOC unchanged),
  just offset by the P2 base LBA.
- **B: single payload, scene appended.** One HSS-payload partition; scene bytes appended after the app
  and found by a known offset. Simpler GPT, but couples app image size to scene offset — more brittle.

Decision pending; **A** is preferred (decouples app from scene, matches how HSS expects a data
partition). This is the main `sd_pack.py` change for the Discovery delivery.

## Sequence to finish the delivery — STATUS (2026-07-15)
1. ✅ **Fabric bitstream DONE + timing-closed.** `mpfs/fpga/libero_disc/export/SAR_TOP_disc.job`
   (5.75 MB). I/O overflow resolved (stripped MSS to DDR4+FIC_0+MMUART_0+SD; User-I/O 8/80,
   MSS-I/O 63/102 on dedicated banks). Timing MET @ 62.5 MHz: setup 0 viol, hold 0 viol. Detect
   kernel needed `CLOCK_PERIOD 2.5` (re-pipelined 26→37 stages) + multi-pass P&R on -1 @ 1.0 V.
2. ✅ **HSS built for `mpfs-disco-kit`.** `mpfs/fpga/hss/build_hss.sh` (needs `CONFIG_CC_USE_SOFTCONSOLE=y`
   for the SoftConsole riscv64-unknown-elf gcc 8.3.0). eNVM hex: `mpfs/fpga/hss/out/hss-envm-wrapper.mpfs-disco-kit.hex`.
   MSS reconciliation: HSS's disco-kit MSS xml is **byte-identical to the stripped fabric MSS** on all
   DDR/clock/SD/UART params (only disabled peripherals differ, which HSS never touches) — verified.
3. ✅ **SAR app → HSS payload (firmware done, board-free).** Built cleanly at
   `mpfs/fpga/sar_app/` (`build_sar_app.sh` → `Default/sar_app.elf` + `sar_app.bin`, 41 KB raw;
   text 37 KB / bss 133 KB). Details:
   - **Scene load eMMC→SD**: new `src/sar/sar_sd.c` (`sar_sd_init/load_scene/save_out`) mirrors the
     eMMC M3 path but `card_type = MSS_MMC_CARD_TYPE_SD`, `data_bus_width = 4BIT`, `3.3 V`, and **no**
     Icicle GPIO0.12 mux (Discovery wires SD directly to MSS SDIO). Keeps the
     `mss_config_clk_rst(MSS_PERIPH_EMMC…)` clock-enable + single-block synchronous reads. Scene
     'SARI' superblock read at `SAR_SD_SCENE_LBA = 67584` (GPT P2 base, pinned by `sd_pack.py --gpt`);
     TOC carries absolute card LBAs. FIC0 non-coherence handled with `flush_l2_cache` per transfer.
   - **Autonomous boot**: `u54_1.c` `#ifdef SAR_SD_BOOT` runs init SD → **FFTMODE=1 (fabric CoreFFT,
     written unconditionally at 0xB0059110)** → load scene → `sar_form_image` → save OUT, logging over
     MMUART_0. The Icicle JTAG/mailbox harness is preserved under `#else` (unchanged).
   - **HSS payload build**: linked at DDR exec addr **`0x1000000000`** (`sar_app.ld`; aliases the
     32-bit `0x80000000` window on the disco SEG config, so app code sits in DDR phys [0,128 MiB),
     clear of SIG@`0x88000000`). Payload MSS config `mpfs/fpga/sar_app/config` sets
     `MPFS_HAL_FIRST_HART = LAST_HART = 1` + `IMAGE_LOADED_BY_BOOTLOADER = 1` (no re-train of HSS's DDR).
   - **Wrap** with `tools/hss-payload-generator` (manifest `mpfs/fpga/sar_app/sar_app.yaml`; needs a
     native host gcc — none on this PC yet) → `payload.bin`. Board validation of runtime still pending.
4. ⏳ `sd_pack.py --gpt` → SD image with P1(HSS payload)+P2(SARI scene); app reads scene from P2 LBA.
5. ✅ **Libero: eNVM client added + `.job` re-exported (2026-07-17).** `hss-envm-wrapper.mpfs-disco-kit.hex`
   imported as the `BOOT_MODE_1_ENVM_CLIENT` and the delivery job regenerated via
   `mpfs/fpga/build_disc_bootable.tcl` (`configure_envm` → `GENERATEPROGRAMMINGDATA` → `export_prog_job`,
   FABRIC_SNVM+ENVM; **no re-P&R** — the timing-closed fabric is reused). Output installed to
   `mpfs/deliver/sar_top_095t.job`. **This HSS build has Mi-V IHC disabled** (`# CONFIG_USE_IHC_V2 is not
   set`, via `build_hss.sh`) — the fix for the first-boot IHC hang, so the delivered `.job` carries it.
   See [DISCOVERY_BRINGUP_ISSUES.md](DISCOVERY_BRINGUP_ISSUES.md) Issue #1a.
6. ⏳ On-Discovery bring-up: program the new `.job`, write SD, power-cycle → HSS boots past IHC → app →
   SAR focus. Board confirmation (`[sar] DONE`) is the only remaining step.

**Done:** the two hardest infrastructure pieces — a **timing-closed fabric bitstream** and a
**built HSS SD-boot loader** — are complete and committed. Remaining is the cohesive
firmware/tooling half: the SAR app's SD scene-load port + payload packaging + GPT SD image + eNVM
bundle. None of it is blocked; the app port (step 3) is the substantial next effort.
