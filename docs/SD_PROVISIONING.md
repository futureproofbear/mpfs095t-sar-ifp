# Provision the SAR scene onto a microSD card — operator runbook

The board reads the SAR scene (derived from an Umbra CPHD) from a **microSD card**. You write a
prepared image to the card on your PC — no JTAG, no board link. Two paths: use a **prebuilt image**
(simplest), or **regenerate** the image from a different CPHD (needs Python).

## What you need
- A **microSD card** (≥ ~256 MB; any modern card is fine) + a **USB microSD reader**.
- A **raw disk-imaging tool** — **[balenaEtcher](https://etcher.balena.io/)** (recommended,
  Windows/macOS/Linux) or Win32DiskImager (Windows) or `dd` (Linux/macOS).

> ⚠️ Writing a raw image **erases the whole card**. Use a dedicated card; back up anything on it first.

## Path A — prebuilt image (simplest, no Python)
The engineer ships **`sar_sd.img`** for the target scene.
1. Insert the microSD into the PC card reader.
2. Open **balenaEtcher** → **Flash from file** → select `sar_sd.img` → select the SD card → **Flash**.
   - (Win32DiskImager: pick `sar_sd.img`, pick the card's drive letter, **Write**.)
   - (Linux/macOS: `sudo dd if=sar_sd.img of=/dev/sdX bs=4M conv=fsync` — replace `/dev/sdX` with the
     card device, *not* a partition; double-check with `lsblk`.)
3. Eject the card, insert it into the **Discovery board's microSD slot**, power-cycle.
   The board reads the `SARI` superblock at LBA 0, loads the scene into DDR, and focuses it.

## Path B — regenerate from a different CPHD (needs Python)
Only if you want a scene other than the shipped one.

1. Install **Python 3.9+** and the packages: `pip install numpy sarpy` (add `scipy` if prompted).
2. From an Umbra CPHD file, stage the pipeline inputs:
   ```
   python mpfs/host/serialize_inputs.py --in <scene>.cphd --grid 8192 --deci <D> --out jtag_stage
   ```
   (`--deci` decimates so the capture fits the 8192 grid; a full-res 8192-native scene uses `--deci 1`.)
3. Pack the stage dir + the HSS payload into a **GPT SD-boot image**:
   ```
   python mpfs/host/mkpayload.py --app mpfs/fpga/sar_app/Default/sar_app.bin \
       --exec 0x1000000000 --out payload.bin
   python mpfs/host/sd_pack.py --gpt --payload payload.bin --stage jtag_stage --out sar_sd.img
   ```
   `sd_pack.py --gpt` self-verifies (GPT CRCs, HSS payload TypeId, all scene CRCs) and prints the
   partition LBAs + the **minimum microSD size** (~475 MB; any modern card is fine).
4. Write `sar_sd.img` to the card as in **Path A**.

## How the addressing works (for reference)
The card is **GPT-partitioned** for HSS SD-boot:
- **P1 @ LBA 2048** — the HSS payload (the SAR app). HSS finds it by its payload Type-GUID, loads
  it into DDR, and jumps to it.
- **P2 @ LBA 67584** (`SAR_SD_SCENE_LBA`) — a `SARI` superblock + one blob per scene (SIG signal +
  geometry tables). Each TOC entry carries the scene's absolute card LBA; the app reconstructs its
  job descriptor from the TOC and DMAs each segment to its fixed DDR address.
- **OUT @ LBA 657408** (`SAR_SD_OUT_LBA`) — raw space past the scene where the board writes the
  focused 128 MiB image back (commit-last: it invalidates the `SARO` magic, writes the image, then
  writes the superblock last, so a power cut mid-write leaves a rejected torn image, not a bad one).

You never compute addresses by hand — the engineer's tools pin these LBAs and the firmware matches
them; the operator just writes the whole image from LBA 0.

## Verify (optional)
`sd_pack.py --selftest` runs a synthetic GPT + scene round-trip (no card) to confirm the tool works.
