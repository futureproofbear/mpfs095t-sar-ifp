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
import zlib
import struct
import argparse
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import ddr_layout as L  # noqa: E402

# Raw SD data card: the 'SARI' superblock sits at the very start of the card.
SD_IN_LBA = 0

# ---------------------------------------------------------------------------
# GPT SD-boot layout (HSS reads the payload from a GPT partition; --gpt mode)
# ---------------------------------------------------------------------------
# HSS (CONFIG_SERVICE_BOOT_MMC_USE_GPT=y) walks the GPT and loads the partition
# whose TYPE GUID matches its payload GUID into DDR, then jumps to it. We lay down:
#   P1 = HSS payload (the SAR app, wrapped by hss-payload-generator)  -- 32 MiB reserve
#   P2 = the 'SARI' scene image (superblock + blobs), read by the app -- fixed base LBA
# P2's base LBA is FIXED so the app can hard-code SAR_SD_SCENE_LBA (below); the app reads
# the 'SARI' superblock there and follows the TOC's absolute card LBAs.
SECTOR = 512
_ALIGN = 2048                                   # 1 MiB partition alignment
P1_FIRST_LBA = 2048                             # HSS payload partition start
PAYLOAD_RESERVE_SECTORS = 65536                 # 32 MiB reserved for the payload (app << this)
P2_FIRST_LBA = P1_FIRST_LBA + PAYLOAD_RESERVE_SECTORS   # = 67584 -> app's SAR_SD_SCENE_LBA
SAR_SD_SCENE_LBA = P2_FIRST_LBA                 # firmware constant: where the SARI superblock is

# HSS payload partition TYPE GUID -- matched byte-for-byte to hart-software-services
# services/boot/gpt.c: {data1=0x21686148, data2=0x6449, data3=0x6E6F, data4=0x4946456465654e74}.
# HSS reads the on-disk 16 bytes into {u32,u16,u16,u64} on a little-endian hart, so we emit
# data1/2/3 little-endian and data4 as a little-endian u64 (this is HSS's own convention).
HSS_PAYLOAD_TYPE_GUID = (struct.pack("<I", 0x21686148) + struct.pack("<H", 0x6449)
                         + struct.pack("<H", 0x6E6F) + struct.pack("<Q", 0x4946456465654E74))
# P2 (SARI scene) -- arbitrary distinct type; the app finds it by fixed LBA, not by GUID.
SARI_DATA_TYPE_GUID = (struct.pack("<I", 0x53415249) + struct.pack("<H", 0x0001)
                       + struct.pack("<H", 0x0001) + b"SARSCENE")   # "SARI"...
# Deterministic disk/unique GUIDs (host tool -> reproducible images; no randomness needed).
_DISK_GUID = bytes.fromhex("53415249" "4449" "534b" "0000000000000001")
_P1_UNIQUE = bytes.fromhex("53415249" "5041" "594c" "0000000000000001")
_P2_UNIQUE = bytes.fromhex("53415249" "5343" "4e45" "0000000000000002")


def _crc32(b):
    return zlib.crc32(b) & 0xFFFFFFFF


def _gpt_part_entry(type_guid, unique_guid, first_lba, last_lba, name):
    """One 128-byte GPT partition entry."""
    nm = name.encode("utf-16-le")[:72].ljust(72, b"\0")
    return (type_guid + unique_guid + struct.pack("<QQQ", first_lba, last_lba, 0) + nm)


def _gpt_header(current_lba, backup_lba, first_usable, last_usable,
                entries_lba, entry_array_crc):
    """92-byte GPT header (padded to a sector), with self-CRC filled in."""
    hdr = bytearray(92)
    struct.pack_into("<8sII", hdr, 0, b"EFI PART", 0x00010000, 92)
    # bytes 16-19 = header CRC (zero while computing); 20-23 reserved
    struct.pack_into("<QQQQ", hdr, 24, current_lba, backup_lba, first_usable, last_usable)
    hdr[56:72] = _DISK_GUID
    struct.pack_into("<QII", hdr, 72, entries_lba, 128, 128)
    struct.pack_into("<I", hdr, 88, entry_array_crc)
    struct.pack_into("<I", hdr, 16, _crc32(bytes(hdr)))       # self CRC over the 92 bytes
    return bytes(hdr).ljust(SECTOR, b"\0")


def _protective_mbr(total_sectors):
    mbr = bytearray(SECTOR)
    # single 0xEE protective partition covering the whole disk
    rec = struct.pack("<B3sB3sII", 0x00, b"\x00\x02\x00", 0xEE, b"\xff\xff\xff",
                      1, min(total_sectors - 1, 0xFFFFFFFF))
    mbr[446:446 + 16] = rec
    mbr[510:512] = b"\x55\xaa"
    return bytes(mbr)


def build_gpt_image(sari_bytes, payload_bytes=b""):
    """Assemble a GPT SD image: P1=HSS payload, P2='SARI' scene (at SAR_SD_SCENE_LBA).
    Returns the full disk image bytes. `payload_bytes` may be empty to reserve P1 for a
    payload flashed later; the SARI scene placement (P2) is independent of it."""
    if len(payload_bytes) > PAYLOAD_RESERVE_SECTORS * SECTOR:
        raise ValueError(f"payload {len(payload_bytes)} B exceeds "
                         f"{PAYLOAD_RESERVE_SECTORS * SECTOR} B reserve")
    p1_last = P1_FIRST_LBA + PAYLOAD_RESERVE_SECTORS - 1
    sari_sectors = (len(sari_bytes) + SECTOR - 1) // SECTOR
    p2_last = P2_FIRST_LBA + sari_sectors - 1
    backup_hdr_lba = p2_last + 33                # 32-sector entry array + 1 header after P2
    total_sectors = backup_hdr_lba + 1

    entries = bytearray(128 * 128)               # 128 entries x 128 B
    entries[0:128] = _gpt_part_entry(HSS_PAYLOAD_TYPE_GUID, _P1_UNIQUE,
                                     P1_FIRST_LBA, p1_last, "HSS-PAYLOAD")
    entries[128:256] = _gpt_part_entry(SARI_DATA_TYPE_GUID, _P2_UNIQUE,
                                       P2_FIRST_LBA, p2_last, "SARI-SCENE")
    entry_crc = _crc32(bytes(entries))

    primary_hdr = _gpt_header(1, backup_hdr_lba, 34, p2_last, 2, entry_crc)
    backup_hdr = _gpt_header(backup_hdr_lba, 1, 34, p2_last, backup_hdr_lba - 32, entry_crc)

    img = bytearray(total_sectors * SECTOR)
    img[0:SECTOR] = _protective_mbr(total_sectors)               # LBA 0
    img[SECTOR:2 * SECTOR] = primary_hdr                         # LBA 1
    img[2 * SECTOR:2 * SECTOR + len(entries)] = entries          # LBA 2..33
    img[P1_FIRST_LBA * SECTOR:P1_FIRST_LBA * SECTOR + len(payload_bytes)] = payload_bytes
    img[P2_FIRST_LBA * SECTOR:P2_FIRST_LBA * SECTOR + len(sari_bytes)] = sari_bytes
    img[(backup_hdr_lba - 32) * SECTOR:(backup_hdr_lba - 32) * SECTOR + len(entries)] = entries
    img[backup_hdr_lba * SECTOR:(backup_hdr_lba + 1) * SECTOR] = backup_hdr
    return bytes(img)

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
        # GPT round-trip: SARI at P2, then re-parse the SARI back out of the disk image.
        sari, toc_g = build_sd_image(dirs, base_lba=P2_FIRST_LBA)
        disk = build_gpt_image(sari, payload_bytes=b"\xa5" * 4096)
        _verify_gpt(disk, sari, toc_g)
    print("selftest OK:")
    for t in toc:
        print(f"  scene {t['scene_id']} '{t['name']}': LBA {t['lba']:#x} "
              f"({t['byte_len']/1e6:.1f} MB blob) sig_crc={t['sig_crc']:#010x}")
    print(f"  raw image = {len(image)/1e6:.1f} MB, superblock @ LBA 0, all CRCs verified, "
          f"JOB reconstructs from every TOC entry")
    print(f"  GPT disk = {len(disk)/1e6:.1f} MB: P1 HSS-payload @ LBA {P1_FIRST_LBA}, "
          f"P2 SARI-scene @ LBA {P2_FIRST_LBA} (SAR_SD_SCENE_LBA); GPT+SARI CRCs verified")


def _verify_gpt(disk, sari, toc):
    """Confirm the GPT is well-formed (sigs, both header CRCs, partition-array CRC, the
    HSS payload TypeId, P2 base LBA) and that the SARI scene reads back intact from P2."""
    assert disk[0x1FE:0x200] == b"\x55\xaa", "no MBR signature"
    assert disk[446 + 4] == 0xEE, "MBR partition not 0xEE protective"
    hdr = disk[SECTOR:SECTOR + 92]
    assert hdr[0:8] == b"EFI PART", "bad GPT signature"
    got = struct.unpack_from("<I", hdr, 16)[0]
    assert got == _crc32(hdr[:16] + b"\0\0\0\0" + hdr[20:]), "primary header CRC bad"
    entries_lba, nent, esz = struct.unpack_from("<QII", hdr, 72)
    ent = disk[entries_lba * SECTOR: entries_lba * SECTOR + nent * esz]
    assert struct.unpack_from("<I", hdr, 88)[0] == _crc32(ent), "partition-array CRC bad"
    assert ent[0:16] == HSS_PAYLOAD_TYPE_GUID, "P1 is not the HSS payload TypeId"
    p2_first = struct.unpack_from("<Q", ent, 128 + 32)[0]
    assert p2_first == P2_FIRST_LBA == SAR_SD_SCENE_LBA, "P2 base LBA != SAR_SD_SCENE_LBA"
    # SARI reads back from P2 exactly, and its TOC still reconstructs.
    assert disk[p2_first * SECTOR: p2_first * SECTOR + len(sari)] == sari, "SARI corrupt in P2"
    verify_image(sari, toc, base_lba=P2_FIRST_LBA)


def main():
    ap = argparse.ArgumentParser(description="Pack stage dirs -> raw SD-card image (Discovery Kit)")
    ap.add_argument("--stage", action="append", default=[],
                    help="a serialize_inputs.py output dir (repeatable)")
    ap.add_argument("--out", help="output raw image path (write this to the SD card)")
    ap.add_argument("--gpt", action="store_true",
                    help="emit a GPT SD-boot image (P1=HSS payload, P2=SARI scene) instead of a "
                         "raw LBA-0 SARI image; required for the HSS SD-boot delivery")
    ap.add_argument("--payload", help="HSS payload.bin to place in P1 (with --gpt); optional -- "
                                      "P1 can be flashed separately, P2 (scene) is independent")
    ap.add_argument("--selftest", action="store_true", help="synthetic round-trip, no CPHD/board")
    a = ap.parse_args()
    if a.selftest:
        _selftest(); return
    if not a.stage or not a.out:
        ap.error("need --stage and --out (or --selftest)")

    if a.gpt:
        sari, toc = build_sd_image(a.stage, base_lba=P2_FIRST_LBA)
        verify_image(sari, toc, base_lba=P2_FIRST_LBA)
        payload = Path(a.payload).read_bytes() if a.payload else b""
        disk = build_gpt_image(sari, payload_bytes=payload)
        _verify_gpt(disk, sari, toc)
        Path(a.out).write_bytes(disk)
        print(f"wrote {a.out}  ({len(disk)/1e6:.1f} MB GPT disk, {len(toc)} scene(s))")
        print(f"  P1 HSS-payload @ LBA {P1_FIRST_LBA} "
              f"({'payload '+str(len(payload)//1024)+' KiB' if payload else 'EMPTY - flash payload.bin later'})")
        print(f"  P2 SARI-scene  @ LBA {P2_FIRST_LBA}  (firmware SAR_SD_SCENE_LBA = {P2_FIRST_LBA})")
        for t in toc:
            print(f"    scene {t['scene_id']} '{t['name']}': card LBA {t['lba']:#x} ({t['byte_len']/1e6:.1f} MB)")
        print("verified: GPT sigs/CRCs, HSS payload TypeId, P2 base LBA, all SARI blob/segment CRCs.")
        print("\nNext: write this image to a microSD card with a raw imager")
        print("  (balenaEtcher / Win32DiskImager / `dd if=%s of=/dev/sdX bs=4M`), then" % a.out)
        print("  insert the card into the Discovery board and power on -> HSS boots the payload.")
        return

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
