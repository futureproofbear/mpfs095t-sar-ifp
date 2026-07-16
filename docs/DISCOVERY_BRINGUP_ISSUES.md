# Discovery Kit bring-up — developer issue list (HSS SD-boot hang)

Handoff for the developer on the **Libero SoC host** (builds + programming). First on-silicon boot of
the delivered `mpfs/deliver/sar_top_095t.job` on a PolarFire SoC Discovery Kit (MPFS095T-FCSG325)
**fails**: HSS boot-loops and the SAR app never starts. This doc is self-contained — symptom, what is
already ruled out, the open question, and a ranked set of issues with concrete steps and acceptance
criteria. Full context: [DISCOVERY_PORT.md](DISCOVERY_PORT.md) workstream ⑨.

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

## The open question (what the first diagnostic must answer)

Is the hang **DDR training itself**, or the **step right after it** (DDR scrub / MMC controller /
payload handoff)? The UART silence is ambiguous because DDR-training prints are gated by
`DEBUG_DDR_INIT`, and the HSS build shipped with prints off. Issue #1 resolves this directly.

---

## Issue #1 — [P0, BLOCKER] HSS hangs after Mi-V IHC init; make it tell us where

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
Then the engineer pulls the card and runs `python mpfs/host/read_sd_out.py --img out.bin
--base-lba 657408 --out focused` (full procedure in [SD_PROVISIONING.md](SD_PROVISIONING.md)); a
`CRC32 ... [MATCH]` + a sensible `focused.png` closes workstream ⑨.

## Reference

- UART capture: 115200 8N1 on the FTDI USB-UART (enumerates as **COM4** on the engineer laptop);
  any terminal (PuTTY / Tera Term) or a logged serial read works.
- Boot flow + addresses: [HSS_INTEGRATION.md](HSS_INTEGRATION.md), [DISCOVERY_PORT.md](DISCOVERY_PORT.md).
- Firmware: `mpfs/fpga/libero_sar/softconsole/mpfs-hal-ddr-demo/src/sar/sar_sd.c`,
  `.../application/hart1/u54_1.c` (the `#ifdef SAR_SD_BOOT` autonomous path).
