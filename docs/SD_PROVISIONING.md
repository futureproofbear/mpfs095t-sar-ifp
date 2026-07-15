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

2. **Get a CPHD scene.** Any Umbra open-data spotlight CPHD works — the public catalog
   `s3://umbra-open-data-catalog` (us-west-2, anonymous HTTPS, no AWS account) under
   `sar-data/tasks/<task>/<uuid>/<timestamp>_UMBRA-NN/CPHD.cphd`. Download the `CPHD.cphd` for the
   scene you want. (The reference scene used for the shipped image was the NDSU 2023-11-10 UMBRA-04
   capture.)

3. **Stage the CPHD → pipeline inputs.** The pipeline grids to **8192×8192**, so both capture
   dimensions must be ≤ 8192; decimate the one(s) that exceed it:
   ```
   python mpfs/host/serialize_inputs.py --in <scene>_CPHD.cphd --grid 8192 \
       --deci-pulse 1 --deci-sample 1 --out jtag_stage
   ```
   If it errors `scene MxN exceeds GRID_MAX 8192`, raise the decimation on the offending axis until
   both fit — `--deci-pulse` for the vector/azimuth axis, `--deci-sample` for the sample/range axis
   (e.g. a 8167×8999 capture needs `--deci-sample 2` → 8167×4500). It prints the final dims and a
   resample-geometry self-check (`corr≈1.000` = good).

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

## Verify (optional)
`python mpfs/host/sd_pack.py --selftest` runs a synthetic GPT + scene round-trip (no card, no CPHD)
to confirm the tool works. `python mpfs/host/mkpayload.py --selftest` checks the payload generator.
