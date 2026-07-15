# Discovery Kit delivery bundle (MPFS095T)

Everything the operator needs to program the PolarFire SoC **Discovery Kit** and run the SAR
image former. No Libero, SoftConsole, or Python required to program — only **FlashPro Express**
(free) and a **microSD card**.

## Contents
- **`sar_top_095t.job`** — the signed FlashPro Express job. It contains BOTH the fabric bitstream
  (the SAR datapath: CoreFFT + resample/window/detect/corner-turn kernels, timing-closed at
  62.5 MHz) **and HSS in eNVM** (the SD-boot loader). Programmed once.
- **`program.bat`** — one-click launcher for FlashPro Express.

## Two steps

1. **Program the board** — `program.bat` (or open `sar_top_095t.job` in FlashPro Express, RUN).
   See [`../../docs/PROGRAM_THE_BOARD.md`](../../docs/PROGRAM_THE_BOARD.md). Program once.

2. **Provision the microSD** — write the SAR scene image to a card. The card is **GPT-partitioned**:
   P1 = the HSS payload (the SAR app), P2 = the `SARI` scene (derived from an Umbra CPHD). Build
   the image with `mpfs/host/sd_pack.py --gpt` (engineer) — see
   [`../../docs/SD_PROVISIONING.md`](../../docs/SD_PROVISIONING.md). Write it with balenaEtcher.

## Boot flow (what happens on power-up)
`eNVM HSS` boots → trains DDR4 → reads the microSD GPT → loads the SAR-app payload (P1) into DDR →
jumps to it → the app reads the `SARI` scene (P2) into DDR, sets the FFT engine to the **fabric
CoreFFT** path, focuses the scene, and writes the result back to the card. Progress prints on the
board's UART (115200 8N1).

> The engineer owns fabric timing closure + the signed job; the operator never edits the `.job`.
