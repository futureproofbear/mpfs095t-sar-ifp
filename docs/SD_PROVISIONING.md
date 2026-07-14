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
3. Pack the stage dir into a raw SD image:
   ```
   python mpfs/host/sd_pack.py --stage jtag_stage --out sar_sd.img
   ```
   It self-verifies (all CRCs, JOB reconstructs) and prints the card LBAs.
4. Write `sar_sd.img` to the card as in **Path A**.

## How the addressing works (for reference)
`sd_pack.py` produces a self-describing image: a **`SARI` superblock at LBA 0** with a table of
contents, then one **blob per scene** (SIG signal + geometry tables). Each TOC entry carries the
scene's absolute card LBA + the metadata the board needs; the board reconstructs its job descriptor
from the TOC and DMAs each segment to its fixed DDR address. You never compute addresses by hand —
the image is written from LBA 0 and the board finds everything from the superblock.

## Verify (optional)
`sd_pack.py --selftest` runs a synthetic round-trip (no card) to confirm the tool is working.
