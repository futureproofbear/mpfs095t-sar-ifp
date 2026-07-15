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

## Open design decision — SD layout (GPT) vs current sd_pack.py
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
3. ⏳ **SAR app → HSS payload (the remaining firmware work).** App exists at
   `mpfs/fpga/libero_sar/softconsole/mpfs-hal-ddr-demo/` (250T app, eMMC scene-load). Discovery port:
   - **Scene load eMMC→SD** in `src/sar/sar_emmc.c`: set `cfg.card_type = MSS_MMC_CARD_TYPE_SD`,
     `data_bus_width = 4BIT` (microSD has 4 data lines SD_DATA0-3), and **remove** the Icicle mux
     code (GPIO0.12 select for TS3A27518E) — the Discovery wires microSD directly to MSS SDIO
     (SD→MSSIO_B4), no demux. Keep the `mss_config_clk_rst(MSS_PERIPH_EMMC/SDIO…)` clock-enable and
     single-block reads. SD is 3.3 V on the Discovery.
   - **Build as an HSS payload** (not bare-metal eNVM): compile the app for the disco-kit MSS, link at
     the payload DDR exec addr, emit `sar_app.bin`.
   - **Wrap** with `tools/hss-payload-generator` (needs a native host gcc — not the RISC-V cross-tool;
     none found on this PC yet) → `payload.bin`.
4. ⏳ `sd_pack.py --gpt` → SD image with P1(HSS payload)+P2(SARI scene); app reads scene from P2 LBA.
5. ⏳ Libero: add `hss-envm-wrapper.mpfs-disco-kit.hex` as eNVM client to the `libero_disc` design;
   re-export the **`.job`** (fabric + HSS-in-eNVM) as the single delivery artifact.
6. ⏳ On-Discovery bring-up: program `.job` once, write SD, power-cycle → HSS boots app → SAR focus.

**Done:** the two hardest infrastructure pieces — a **timing-closed fabric bitstream** and a
**built HSS SD-boot loader** — are complete and committed. Remaining is the cohesive
firmware/tooling half: the SAR app's SD scene-load port + payload packaging + GPT SD image + eNVM
bundle. None of it is blocked; the app port (step 3) is the substantial next effort.
