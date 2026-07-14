# Program the Discovery board — operator runbook (no Libero)

One page. You program a **pre-built, pre-verified** FlashPro Express job (`.job`) onto the
PolarFire SoC **Discovery Kit (MPFS095T)**. You do **not** need Libero, SoftConsole, or any design
tool — only **FlashPro Express** (free) and a USB cable.

## Prerequisites (one-time)
- **FlashPro Express** installed — Microchip's free standalone programmer (part of the free
  "Programming and Debug" download; *not* Libero). Includes the FlashPro USB driver.
- A **USB cable** to the Discovery Kit's embedded FlashPro (the board's programming USB port).
- The delivery files (shipped): **`sar_top_095t.job`** (the bitstream + firmware bundle) and this
  runbook. (`program.bat` is an optional convenience.)

## Program it (GUI — recommended for first time)
1. Plug the board's programming USB into your PC. Power the board on.
2. Launch **FlashPro Express**.
3. **Project → Import** (or "Open Job Project") → select **`sar_top_095t.job`**.
4. FlashPro Express shows the connected programmer + the target device (MPFS095T). If it shows
   "programmer not connected," re-seat the USB / check the board is powered.
5. Click **RUN** (the "PROGRAM" action is selected by default in a job).
6. Wait for **`PROGRAM PASSED`** (green). This takes ~1–2 minutes.
7. **Power-cycle** the board (off, then on). Done — the fabric + firmware are now loaded.

## Program it (one-click — optional)
Double-click **`program.bat`** (in the delivery folder next to the `.job`). It locates FlashPro
Express and runs the job non-interactively. On success it prints `PROGRAM PASSED`. If it can't find
FlashPro Express, edit the `FPEXPRESS` path at the top of `program.bat`.

## After programming
The board is ready. Next, provision the SAR scene onto a microSD card and insert it — see
[`SD_PROVISIONING.md`](SD_PROVISIONING.md). On power-up with a provisioned card, the board loads the
scene from SD and focuses it.

## Troubleshooting
- **"No programmer detected"** → re-plug the programming USB; confirm the board is powered; only one
  programming tool may own the FlashPro at a time (close any Libero/SoftConsole session).
- **`PROGRAM FAILED` / verify error** → re-seat USB and retry once; if it persists, the `.job` may be
  for a different device revision — report it to the engineer (do not modify the `.job`).
- You never edit the `.job`. It is signed + pre-verified; the engineer owns timing closure.
