"""Pack serialize_inputs.py stage dir(s) into a RAW SD-card image for the Discovery Kit.

Delivery flow (no JTAG, no Libero for the operator):
  1. engineer runs this to produce `sar_sd.img` from a CPHD scene's stage dir;
  2. the operator writes `sar_sd.img` to a microSD card from a PC card reader with a
     raw disk imager (balenaEtcher / Win32DiskImager / `dd`), starting at LBA 0;
  3. the operator inserts the card into the Discovery board and powers on; the
     firmware reads the 'SARI' superblock at LBA 0, walks the TOC, and DMAs each
     scene segment from the card into its DDR role address -- no host link needed.

This is the SD sibling of `emmc_pack.py`. It reuses the SAME self-describing 'SARI'
superblock + blob/segment layout (ddr_layout.py) and the JOB-from-TOC contract; the
ONLY difference is the base LBA: the eMMC image starts at 0x80000 (past the boot
area), the SD image starts at **LBA 0** because a dedicated raw data card has no boot
area to protect. TOC entries carry ABSOLUTE card LBAs so the firmware seeks directly.

Usage:
    python sd_pack.py --stage jtag_stage [--stage other ...] --out sar_sd.img
    python sd_pack.py --selftest                      # synthetic round-trip, no CPHD
"""
import sys
import json
import struct
import argparse
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import ddr_layout as L  # noqa: E402

# Raw SD data card: the 'SARI' superblock sits at the very start of the card.
SD_IN_LBA = 0

# role name -> stage filename, in role-id order (index == role id). Mirror of emmc_pack.
ROLE_FILES = [(name, f"{name}.bin") for name in
              ["sig", "f0", "df", "pr", "tans", "invorder",
               "krgrid", "kcgrid", "hamr", "hamc"]]


def read_stage(stage_dir):
    """Read a stage dir -> (ordered segs [(role_id, bytes)], layout dict)."""
    stage_dir = Path(stage_dir)
    layout = json.loads((stage_dir / "layout.json").read_text())
    segs = []
    for name, fn in ROLE_FILES:
        p = stage_dir / fn
        if not p.exists():
            raise FileNotFoundError(f"{p} missing (role '{name}')")
        segs.append((L.EMMC_ROLE[name], p.read_bytes()))
    sig_crc = L.crc32(segs[0][1])
    if sig_crc != layout["crc32"]["sig"]:
        raise ValueError(f"{stage_dir}: sig.bin CRC {sig_crc:#010x} != "
                         f"layout {layout['crc32']['sig']:#010x}")
    return segs, layout


def build_sd_image(stage_dirs, base_lba=SD_IN_LBA):
    """Build the raw SD image. Returns (image_bytes, toc). The image maps 1:1 onto the
    card starting at `base_lba` (default 0), so writing it raw places every blob at the
    absolute LBA recorded in its TOC entry."""
    scenes = [read_stage(d) for d in stage_dirs]

    super_bytes_probe = L.pack_in_super([b"\0" * 88] * len(scenes))
    lba = base_lba + len(super_bytes_probe) // L.EMMC_BLK

    blobs, entries, toc = [], [], []
    for sid, (segs, layout) in enumerate(scenes):
        blob = L.pack_blob(segs)
        blobs.append(blob)
        byte_len = len(blob)
        blob_crc = L.crc32(blob)
        M, N = layout["dims"]["M"], layout["dims"]["N"]
        fft_r, fft_a = layout["fft_len"]["R"], layout["fft_len"]["A"]
        exp = layout["bfp_input"]["exp"]
        sig_len = layout["sizes"]["sig"]
        sig_crc = layout["crc32"]["sig"]
        name = layout["scene"]
        entries.append(L.pack_in_entry(sid, lba, byte_len, blob_crc, M, N,
                                       fft_r, fft_a, exp, sig_len, sig_crc, name))
        toc.append({"scene_id": sid, "name": name, "lba": lba,
                    "byte_len": byte_len, "blob_crc": blob_crc,
                    "M": M, "N": N, "fft_r": fft_r, "fft_a": fft_a,
                    "bfp_exp": exp, "sig_len": sig_len, "sig_crc": sig_crc})
        lba += byte_len // L.EMMC_BLK

    superblock = L.pack_in_super(entries)
    image = bytearray(superblock)
    for blob in blobs:
        image += blob
    return bytes(image), toc


def verify_image(image, toc, base_lba=SD_IN_LBA):
    """Re-parse the image and confirm every blob/segment CRC + that each TOC entry
    reconstructs a JOB. Raises on any mismatch."""
    magic, version, count, _ = struct.unpack_from(L.EMMC_SUPER_HDR_FMT, image, 0)
    assert magic == L.EMMC_IN_MAGIC, "bad superblock magic"
    assert version == L.EMMC_VERSION, f"superblock version {version} != {L.EMMC_VERSION}"
    assert count == len(toc), "superblock count mismatch"
    esz = struct.calcsize(L.EMMC_IN_ENTRY_FMT)
    hdr = struct.calcsize(L.EMMC_SUPER_HDR_FMT)
    for i, t in enumerate(toc):
        ent = struct.unpack_from(L.EMMC_IN_ENTRY_FMT, image, hdr + i * esz)
        job = L.job_from_in_entry(ent, L.OUT_DTYPE_UINT16)
        assert len(job) == L.JOB_BYTES, "reconstructed JOB wrong size"
        boff = (t["lba"] - base_lba) * L.EMMC_BLK
        blob = image[boff:boff + t["byte_len"]]
        assert L.crc32(blob) == t["blob_crc"], f"scene {i} blob CRC mismatch"
        bmagic, bver, seg_count, total = struct.unpack_from(L.EMMC_BLOB_HDR_FMT, blob, 0)
        assert bmagic == L.EMMC_BLOB_MAGIC and total == len(blob), "bad blob header"
        segoff = struct.calcsize(L.EMMC_BLOB_HDR_FMT)
        sig_seg_crc = None
        for s in range(seg_count):
            role, off, ln, crc = struct.unpack_from(L.EMMC_SEG_FMT, blob, segoff + s * 16)
            assert L.crc32(blob[off:off + ln]) == crc, f"scene {i} seg {role} CRC mismatch"
            assert off % L.EMMC_BLK == 0, "segment not block-aligned"
            if role == L.EMMC_ROLE["sig"]:
                sig_seg_crc = crc
        assert sig_seg_crc == t["sig_crc"], f"scene {i} SIG seg CRC != TOC sig_crc"


def _selftest():
    """Synthetic round-trip -- proves pack/parse/reconstruct without a CPHD or board."""
    import numpy as np
    import tempfile

    def fake_stage(tmp, name, M, N):
        d = Path(tmp) / name
        d.mkdir(parents=True, exist_ok=True)
        Mp = Np = L.GRID_MAX
        sig = (np.arange(M * N * 2, dtype=np.int16)).tobytes()
        bins = {"sig": sig, "f0": np.zeros(M, np.float32).tobytes(),
                "df": np.ones(M, np.float32).tobytes(), "pr": np.zeros(M, np.float32).tobytes(),
                "tans": np.linspace(0, 1, M, dtype=np.float32).tobytes(),
                "invorder": np.arange(M, dtype=np.int32).tobytes(),
                "krgrid": np.zeros(Np, np.float32).tobytes(), "kcgrid": np.zeros(Mp, np.float32).tobytes(),
                "hamr": np.zeros(Np, np.int16).tobytes(), "hamc": np.zeros(Mp, np.int16).tobytes()}
        for nm, b in bins.items():
            (d / f"{nm}.bin").write_bytes(b)
        layout = {"scene": name, "dims": {"M": M, "N": N}, "fft_len": {"R": Np, "A": Mp},
                  "deci": {"pulse": 1, "sample": 1}, "bfp_input": {"lsb": 0.015625, "exp": -6},
                  "sizes": {"sig": len(sig)}, "crc32": {"sig": L.crc32(sig)}}
        (d / "layout.json").write_text(json.dumps(layout))
        return str(d)

    with tempfile.TemporaryDirectory() as tmp:
        dirs = [fake_stage(tmp, "sceneA", 5634, 4319)]
        image, toc = build_sd_image(dirs)
        verify_image(image, toc)
    print("selftest OK:")
    for t in toc:
        print(f"  scene {t['scene_id']} '{t['name']}': LBA {t['lba']:#x} "
              f"({t['byte_len']/1e6:.1f} MB blob) sig_crc={t['sig_crc']:#010x}")
    print(f"  image = {len(image)/1e6:.1f} MB, superblock @ LBA 0, all CRCs verified, "
          f"JOB reconstructs from every TOC entry")


def main():
    ap = argparse.ArgumentParser(description="Pack stage dirs -> raw SD-card image (Discovery Kit)")
    ap.add_argument("--stage", action="append", default=[],
                    help="a serialize_inputs.py output dir (repeatable)")
    ap.add_argument("--out", help="output raw image path (write this to the SD card, LBA 0)")
    ap.add_argument("--selftest", action="store_true", help="synthetic round-trip, no CPHD/board")
    a = ap.parse_args()
    if a.selftest:
        _selftest(); return
    if not a.stage or not a.out:
        ap.error("need --stage and --out (or --selftest)")
    image, toc = build_sd_image(a.stage)
    verify_image(image, toc)
    Path(a.out).write_bytes(image)
    print(f"wrote {a.out}  ({len(image)/1e6:.1f} MB, {len(toc)} scene(s), 'SARI' superblock @ LBA 0)")
    for t in toc:
        print(f"  scene {t['scene_id']} '{t['name']}': card LBA {t['lba']:#x} ({t['byte_len']/1e6:.1f} MB)")
    print("verified: all blob/segment CRCs, JOB reconstructs from every TOC entry.")
    print("\nNext: write this image to a microSD card from LBA 0 with a raw imager")
    print("  (balenaEtcher / Win32DiskImager / `dd if=%s of=/dev/sdX bs=4M`), then" % a.out)
    print("  insert the card into the Discovery board and power on.")


if __name__ == "__main__":
    main()
