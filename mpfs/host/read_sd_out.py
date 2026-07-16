#!/usr/bin/env python3
"""read_sd_out.py -- read the focused SAR image back off the microSD (headless verify).

The board writes its focused image to a 'SARO' superblock at SAR_SD_OUT_LBA (=657408)
after an autonomous run (see sar_sd.c:sar_sd_save_out + u54_1.c). This tool reads that
region back on the PC, validates the SARO magic + CRC32 (the same IEEE-802.3 CRC the
firmware computes), and dumps the image as raw uint16 (.bin) + a log-scaled PNG.

This closes workstream (9)'s "verify focused image" from a PC, with no Libero/JTAG.

Usage (fully headless):
    # 1) dump the OUT region off the card (git-bash; PhysicalDriveN = the SD card)
    #    132 MiB = SARO super + 128 MiB image + margin:
    dd if=//./PhysicalDriveN of=out.bin bs=512 skip=657408 count=270336

    # 2) parse + verify + render (file starts AT the OUT region -> --base-lba 657408)
    python mpfs/host/read_sd_out.py --img out.bin --base-lba 657408 --out focused

    # -- or, if you dumped/imaged the WHOLE card to a file, base-lba defaults to 0:
    python mpfs/host/read_sd_out.py --img wholecard.img --out focused

    # -- or read the card device directly (needs admin/root; whole-sector reads):
    python mpfs/host/read_sd_out.py --device //./PhysicalDriveN --out focused

    python mpfs/host/read_sd_out.py --selftest      # synthetic round-trip, no card
"""
import sys
import zlib
import struct
import argparse
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from sd_pack import SAR_SD_OUT_LBA, SECTOR  # noqa: E402  (single source of truth)

SAR_EMMC_OUT_MAGIC = 0x5341524F  # 'SARO' (ddr_sar_layout.h)
SAR_OUT_DTYPE_UINT16 = 0
SAR_OUT_DTYPE_UINT8 = 1

# sar_emmc_out_super_t / _out_entry_t (packed, little-endian; ddr_sar_layout.h)
_SUPER_HDR = struct.Struct("<IIII")          # magic, version, count, reserved  (16 B)
_OUT_ENTRY = struct.Struct("<IIIIQQIIII")    # valid, scene_id, run_seq, out_dtype,
#                                              lba, byte_len, rows, cols, out_crc, reserved (48 B)
_SUPER_SPAN_SECTORS = (_SUPER_HDR.size + 64 * _OUT_ENTRY.size + SECTOR - 1) // SECTOR  # = 7


def _crc32(b):
    return zlib.crc32(b) & 0xFFFFFFFF


def _read_sectors(src, base_lba, lba, nbytes):
    """Read nbytes starting at absolute card `lba` from a source whose byte 0 == `base_lba`.
    Reads/​seeks in whole sectors (Windows raw devices require sector-aligned I/O)."""
    off = (lba - base_lba) * SECTOR
    if off < 0:
        raise ValueError(f"LBA {lba} is before the file's base LBA {base_lba}")
    nsec = (nbytes + SECTOR - 1) // SECTOR
    src.seek(off)
    data = src.read(nsec * SECTOR)
    if len(data) < nbytes:
        raise EOFError(f"short read at LBA {lba}: wanted {nbytes} B, got {len(data)} B "
                       f"(source too small / wrong --base-lba?)")
    return data[:nbytes]


def read_out(src, base_lba, scene=None):
    """Parse the SARO superblock and return (entry_dict, image_bytes). Raises on bad magic/CRC."""
    sb = _read_sectors(src, base_lba, SAR_SD_OUT_LBA, _SUPER_SPAN_SECTORS * SECTOR)
    magic, version, count, _ = _SUPER_HDR.unpack_from(sb, 0)
    if magic != SAR_EMMC_OUT_MAGIC:
        if magic == 0:
            raise ValueError(
                "OUT region is empty (magic=0x00000000): the board has NOT committed an "
                "image here yet. Re-check the UART -- did it print '[sar] save OUT to SD... ok' "
                "and '[sar] DONE'? (commit-last means a torn/failed run also leaves magic=0.)")
        raise ValueError(f"bad SARO magic 0x{magic:08X} (expected 0x{SAR_EMMC_OUT_MAGIC:08X}) "
                         f"-- wrong LBA/--base-lba, or not a SAR OUT region")

    entries = []
    for i in range(count):
        v = _OUT_ENTRY.unpack_from(sb, _SUPER_HDR.size + i * _OUT_ENTRY.size)
        keys = ("valid", "scene_id", "run_seq", "out_dtype",
                "lba", "byte_len", "rows", "cols", "out_crc", "reserved")
        entries.append(dict(zip(keys, v)))
    valid = [e for e in entries if e["valid"]]
    if not valid:
        raise ValueError(f"SARO has version={version} count={count} but no valid TOC entry")
    e = valid[scene] if scene is not None else valid[-1]  # newest run by default

    if e["out_dtype"] != SAR_OUT_DTYPE_UINT16:
        raise ValueError(f"unsupported out_dtype={e['out_dtype']} (only uint16 rendered)")
    if e["byte_len"] != e["rows"] * e["cols"] * 2:
        raise ValueError(f"byte_len {e['byte_len']} != rows*cols*2 ({e['rows']}x{e['cols']})")

    img = _read_sectors(src, base_lba, e["lba"], e["byte_len"])
    got = _crc32(img)
    e["crc_ok"] = (got == e["out_crc"])
    e["crc_got"] = got
    return e, img


def render_png(arr, path):
    """Log-scaled 8-bit grayscale of a magnitude image (percentile-clipped for contrast)."""
    from PIL import Image
    a = np.log1p(arr.astype(np.float32))
    lo, hi = np.percentile(a, (1.0, 99.5))
    if hi <= lo:
        hi = lo + 1.0
    u8 = np.clip((a - lo) * (255.0 / (hi - lo)), 0, 255).astype(np.uint8)
    Image.fromarray(u8, "L").save(path)


def _report(e):
    print(f"  SARO valid    : scene_id={e['scene_id']} run_seq={e['run_seq']} "
          f"dtype={e['out_dtype']}")
    print(f"  image         : {e['rows']} x {e['cols']} uint16  "
          f"({e['byte_len']/(1<<20):.0f} MiB) @ LBA {e['lba']}")
    tag = "MATCH" if e["crc_ok"] else "MISMATCH"
    print(f"  CRC32         : firmware 0x{e['out_crc']:08X}  vs  read 0x{e['crc_got']:08X}  "
          f"[{tag}]")


def _selftest():
    import io
    rows = cols = 16
    arr = (np.arange(rows * cols, dtype=np.uint16) * 257).reshape(rows, cols)
    img = arr.tobytes()
    img_lba = SAR_SD_OUT_LBA + _SUPER_SPAN_SECTORS

    sb = bytearray(_SUPER_SPAN_SECTORS * SECTOR)
    _SUPER_HDR.pack_into(sb, 0, SAR_EMMC_OUT_MAGIC, 1, 1, 0)
    _OUT_ENTRY.pack_into(sb, _SUPER_HDR.size, 1, 7, 3, SAR_OUT_DTYPE_UINT16,
                         img_lba, len(img), rows, cols, _crc32(img), 0)

    # synthetic "card" whose byte 0 == the OUT LBA (base_lba = SAR_SD_OUT_LBA -> tiny)
    buf = bytearray(sb)
    buf += img.ljust(SECTOR, b"\0")
    src = io.BytesIO(bytes(buf))
    e, got_img = read_out(src, base_lba=SAR_SD_OUT_LBA)
    assert e["crc_ok"], "selftest CRC mismatch"
    assert np.array_equal(np.frombuffer(got_img, "<u2").reshape(rows, cols), arr), "image mismatch"
    _report(e)

    # negative: an all-zero OUT region must be reported as "not written yet"
    try:
        read_out(io.BytesIO(bytes(_SUPER_SPAN_SECTORS * SECTOR)), base_lba=SAR_SD_OUT_LBA)
        assert False, "empty region should have raised"
    except ValueError as ex:
        assert "empty" in str(ex)
    print("  selftest: PASS (round-trip + empty-region detection)")


def main():
    ap = argparse.ArgumentParser(description="Read the focused SAR image back off the microSD OUT region")
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--img", help="raw file (whole card, or a dd dump of the OUT region)")
    g.add_argument("--device", help="raw card device, e.g. //./PhysicalDriveN or /dev/sdX (needs admin)")
    ap.add_argument("--base-lba", type=int, default=0,
                    help="card LBA that byte 0 of --img corresponds to (use 657408 for an OUT-region "
                         "dump made with 'dd ... skip=657408'; default 0 = whole card)")
    ap.add_argument("--scene", type=int, default=None,
                    help="TOC index of the run to read (default: newest valid entry)")
    ap.add_argument("--out", default="focused", help="output basename -> <out>.bin + <out>.png")
    ap.add_argument("--no-png", action="store_true", help="skip PNG render (write raw .bin only)")
    ap.add_argument("--selftest", action="store_true", help="synthetic round-trip, no card/board")
    args = ap.parse_args()

    if args.selftest:
        _selftest()
        return
    if not (args.img or args.device):
        ap.error("need --img, --device, or --selftest")

    path = args.img or args.device
    with open(path, "rb") as src:
        e, img = read_out(src, args.base_lba, args.scene)
    _report(e)

    bin_path = f"{args.out}.bin"
    Path(bin_path).write_bytes(img)
    print(f"  wrote         : {bin_path}  (raw {e['rows']}x{e['cols']} uint16)")

    if not args.no_png:
        arr = np.frombuffer(img, "<u2").reshape(e["rows"], e["cols"])
        png_path = f"{args.out}.png"
        render_png(arr, png_path)
        print(f"  wrote         : {png_path}  (log-scaled 8-bit preview)")

    if not e["crc_ok"]:
        print("  WARNING: CRC mismatch -- the on-card image is torn/corrupt (see UART for the run).")
        sys.exit(2)


if __name__ == "__main__":
    main()
