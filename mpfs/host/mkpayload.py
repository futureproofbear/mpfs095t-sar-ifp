"""mkpayload.py -- generate an HSS boot payload from a raw SAR-app binary, in pure Python.

HSS (Hart Software Services) loads a "payload" from the SD card's HSS-payload GPT partition
into DDR and jumps to it. The payload is the `struct HSS_BootImage` container defined in
hart-software-services/include/hss_types.h. The vendor tool `hss-payload-generator` builds it,
but that tool needs a NATIVE host C compiler; this machine has only the RISC-V cross-gcc, so we
reproduce the exact on-disk format here (byte-for-byte to hss_types.h, `#pragma pack(8)`, RV64
`size_t`/`uintptr_t` = 8 B; CRC32 == zlib; PAD_SIZE = 8).

Layout (matches tools/hss-payload-generator/generate_payload.c):
  [HSS_BootImage header, 1632 B] [pad8]
  [chunk table: N BootChunkDesc + 1 zero sentinel] [pad8]
  [zi table: M BootZIChunkDesc + 1 zero sentinel] [pad8]
  [blob data: each chunk's bytes, each padded to 8]
`headerCrc` = crc32 over the 1632-B header with the headerCrc field zeroed. Each chunk carries
its own crc32 over its blob. We emit ONE load chunk (the whole app .bin -> its DDR exec address,
owned by U54_1) and no ZI chunks (the app's own crt0 clears .bss).

Usage:
    python mkpayload.py --app sar_app.bin --exec 0x1000000000 --out payload.bin
    python mkpayload.py --selftest
"""
import zlib
import struct
import argparse
from pathlib import Path

# --- constants from hss_types.h -------------------------------------------------
MAGIC = 0xB007C0DE
VERSION = 2
PAD_SIZE = 8
NAME_LEN = 256
NUM_U54 = 4                       # hart[MAX_NUM_HARTS-1], E51 not counted
HART_E51, HART_U54_1 = 0, 1       # enum HSSHartId
PRV_U, PRV_S, PRV_M = 0, 1, 3
BOOT_FLAG_SKIP_OPENSBI = 0x40     # bare-metal mpfs-hal app (no OpenSBI/Linux)

# struct sizes (pack(8), 64-bit) -- verified against hss_types.h field-by-field
HART_ENTRY = 8 + 1 + 1 + 6 + 8 + 8 + 8 + NAME_LEN          # = 296
BOOTIMAGE_SZ = 4 + 4 + 8 + 4 + 4 + 8 + 8 + NUM_U54 * HART_ENTRY + NAME_LEN + 8 + (48 + 96)  # 1632
CHUNK_SZ = 4 + 4 + 8 + 8 + 8 + 4 + 4                        # = 40  (owner,pad,load,exec,size,crc,pad)
ZICHUNK_SZ = 4 + 4 + 8 + 8                                  # = 24  (owner,pad,exec,size)


def _crc32(b):
    return zlib.crc32(b) & 0xFFFFFFFF


def _pad(n, to=PAD_SIZE):
    return (-n) % to


def _hart_entry(entry_point, priv, flags, num_chunks, first_chunk, last_chunk, name):
    nm = name.encode()[:NAME_LEN].ljust(NAME_LEN, b"\0")
    return (struct.pack("<Q", entry_point) + struct.pack("<BB", priv, flags) + b"\0" * 6
            + struct.pack("<QQQ", num_chunks, first_chunk, last_chunk) + nm)


def _boot_image(header_crc, chunk_off, zi_off, harts, set_name, image_len):
    b = struct.pack("<IIQ", MAGIC, VERSION, BOOTIMAGE_SZ)          # magic, version, headerLength
    b += struct.pack("<I", header_crc) + b"\0" * 4                 # headerCrc + pad
    b += struct.pack("<QQ", chunk_off, zi_off)                     # chunk/zi table offsets
    for h in harts:
        b += h
    b += set_name.encode()[:NAME_LEN].ljust(NAME_LEN, b"\0")
    b += struct.pack("<Q", image_len)
    b += b"\0" * (48 + 96)                                         # signature (unsigned image)
    assert len(b) == BOOTIMAGE_SZ, (len(b), BOOTIMAGE_SZ)
    return b


def _chunk(owner, load_addr, exec_addr, size, crc):
    return (struct.pack("<I", owner) + b"\0" * 4
            + struct.pack("<QQQ", load_addr, exec_addr, size) + struct.pack("<I", crc) + b"\0" * 4)


def build_payload(app_bytes, exec_addr, entry=None, hart=HART_U54_1,
                  set_name="sar", priv=PRV_M, flags=BOOT_FLAG_SKIP_OPENSBI):
    """One load chunk (the whole app -> exec_addr, owned by `hart`), no ZI chunks."""
    if entry is None:
        entry = exec_addr
    # table geometry (one real chunk + sentinel; zero real zi + sentinel)
    chunk_off = BOOTIMAGE_SZ + _pad(BOOTIMAGE_SZ)
    chunk_tbl_bytes = (1 + 1) * CHUNK_SZ                            # 1 chunk + sentinel
    zi_off = chunk_off + chunk_tbl_bytes + _pad(chunk_tbl_bytes)
    zi_tbl_bytes = (0 + 1) * ZICHUNK_SZ                            # just the sentinel
    blob_off = zi_off + zi_tbl_bytes + _pad(zi_tbl_bytes)

    load_addr = blob_off                                           # file offset of the app blob
    chunk = _chunk(hart, load_addr, exec_addr, len(app_bytes), _crc32(app_bytes))
    sentinel_chunk = b"\0" * CHUNK_SZ                              # size==0 terminates the table
    sentinel_zi = b"\0" * ZICHUNK_SZ

    total_len = blob_off + len(app_bytes) + _pad(len(app_bytes))

    harts = []
    for hid in range(1, NUM_U54 + 1):                             # U54_1..U54_4
        if hid == hart:
            harts.append(_hart_entry(entry, priv, flags, 1, 0, 0, "u54_%d" % hid))
        else:
            harts.append(_hart_entry(0, 0, 0, 0, 0, 0, ""))

    # header CRC over the header with headerCrc == 0
    hdr0 = _boot_image(0, chunk_off, zi_off, harts, set_name, total_len)
    hdr = _boot_image(_crc32(hdr0), chunk_off, zi_off, harts, set_name, total_len)

    img = bytearray(total_len)
    img[0:BOOTIMAGE_SZ] = hdr
    img[chunk_off:chunk_off + CHUNK_SZ] = chunk
    img[chunk_off + CHUNK_SZ:chunk_off + 2 * CHUNK_SZ] = sentinel_chunk
    img[zi_off:zi_off + ZICHUNK_SZ] = sentinel_zi
    img[blob_off:blob_off + len(app_bytes)] = app_bytes
    return bytes(img)


def parse_payload(img):
    """Mirror of HSS dump_payload.c: re-read the container and return a dict, checking CRC."""
    magic, version, hlen = struct.unpack_from("<IIQ", img, 0)
    assert magic == MAGIC, f"bad magic {magic:#x}"
    hcrc = struct.unpack_from("<I", img, 16)[0]
    shadow = bytearray(img[:BOOTIMAGE_SZ])
    struct.pack_into("<I", shadow, 16, 0)                          # zero headerCrc field
    assert _crc32(bytes(shadow)) == hcrc, "headerCrc mismatch"
    chunk_off, zi_off = struct.unpack_from("<QQ", img, 24)
    chunks = []
    off = chunk_off
    while True:
        owner, load, ex, sz, crc = (struct.unpack_from("<I", img, off)[0],
                                    struct.unpack_from("<Q", img, off + 8)[0],
                                    struct.unpack_from("<Q", img, off + 16)[0],
                                    struct.unpack_from("<Q", img, off + 24)[0],
                                    struct.unpack_from("<I", img, off + 32)[0])
        if sz == 0:
            break
        assert _crc32(img[load:load + sz]) == crc, "chunk blob CRC mismatch"
        chunks.append({"owner": owner, "load": load, "exec": ex, "size": sz})
        off += CHUNK_SZ
    return {"version": version, "chunk_off": chunk_off, "zi_off": zi_off, "chunks": chunks}


def _selftest():
    app = bytes(range(256)) * 40 + b"SAREND"          # 10246 B dummy app
    img = build_payload(app, exec_addr=0x1000000000, set_name="sar")
    info = parse_payload(img)
    assert len(info["chunks"]) == 1, "expected 1 chunk"
    c = info["chunks"][0]
    assert c["owner"] == HART_U54_1 and c["exec"] == 0x1000000000 and c["size"] == len(app)
    assert img[c["load"]:c["load"] + c["size"]] == app, "blob not recoverable"
    print("selftest OK:")
    print(f"  BootImage header = {BOOTIMAGE_SZ} B, chunk_off={info['chunk_off']}, "
          f"zi_off={info['zi_off']}, payload = {len(img)} B")
    print(f"  1 chunk: U54_1 -> exec {c['exec']:#x}, {c['size']} B, blob@{c['load']}, "
          f"headerCrc + chunk CRC verified, parse-back matches")


def main():
    ap = argparse.ArgumentParser(description="Build an HSS boot payload from a raw SAR-app binary")
    ap.add_argument("--app", help="raw app binary (objcopy -O binary of the linked .elf)")
    ap.add_argument("--exec", type=lambda x: int(x, 0), help="DDR exec/load address (e.g. 0x1000000000)")
    ap.add_argument("--entry", type=lambda x: int(x, 0), help="entry point (default = --exec)")
    ap.add_argument("--hart", type=int, default=HART_U54_1, help="owner hart (1=U54_1, default)")
    ap.add_argument("--set-name", default="sar", help="payload set name")
    ap.add_argument("--out", help="output payload.bin")
    ap.add_argument("--selftest", action="store_true", help="build + parse-back round-trip, no app")
    a = ap.parse_args()
    if a.selftest:
        _selftest(); return
    if not (a.app and a.exec and a.out):
        ap.error("need --app, --exec and --out (or --selftest)")
    app = Path(a.app).read_bytes()
    img = build_payload(app, a.exec, entry=a.entry, hart=a.hart, set_name=a.set_name)
    parse_payload(img)                                # self-verify before writing
    Path(a.out).write_bytes(img)
    print(f"wrote {a.out}  ({len(img)} B payload; app {len(app)} B -> exec {a.exec:#x}, "
          f"entry {(a.entry or a.exec):#x}, owner U54_{a.hart})")
    print("place this in the SD card's HSS-payload partition (sd_pack.py --gpt --payload).")


if __name__ == "__main__":
    main()
