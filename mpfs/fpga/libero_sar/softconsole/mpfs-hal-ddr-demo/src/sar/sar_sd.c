/*******************************************************************************
 * sar_sd.c -- microSD scene load + output persist (Discovery Kit autonomous boot).
 *
 * SD sibling of sar_emmc.c's Milestone-3 path (see sar_sd.h). Self-describing
 * 'SARI' superblock + blob/segment layout (ddr_sar_layout.h); TOC entries carry
 * ABSOLUTE card LBAs so blobs are seeked directly. FIC0 is NON-COHERENT: the
 * SDMMC master DMAs physical DDR while the CPU works through L2, so every
 * card<->DDR transfer is paired with flush_l2_cache() (clean+invalidate on this
 * platform, serving both directions).
 ******************************************************************************/
#include "mpfs_hal/mss_hal.h"                 /* flush_l2_cache, read_csr(mhartid) */
#include "mpfs_hal/common/mss_peripherals.h" /* mss_config_clk_rst, MSS_PERIPH_EMMC */
#include "drivers/mss/mss_mmc/mss_mmc.h"      /* MSS_MMC_* */
#include "sar_sd.h"
#include "ddr_sar_layout.h"
#include "../ddr_test/ddr_packet_test.h"      /* ddr_pkt_crc32 (IEEE-802.3, == host) */
#include <string.h>

#define SAR_SD_BLK_BYTES 512u

/* Small DDR scratch for superblock / blob-header reads, inside SCRATCH (free at
 * boot before the pipeline runs). Mirrors sar_emmc SB scratch placement. */
#define SAR_SD_SB_SCRATCH_ADDR   ((uint64_t)SAR_SCRATCH_ADDR + 0x04000000ULL)

/* ---- SD init: microSD, 4-bit, 3.3 V, default speed, NO board mux ------------
 * The Discovery wires the microSD DIRECTLY to the MSS SDIO pads (SD->MSSIO_B4);
 * there is no TS3A27518E mux and no GPIO select (that was Icicle-eMMC only).
 * Turn ON the SDMMC peripheral clock + release its reset BEFORE any SDHCI
 * register access -- the block is clock-gated at reset and not enabled by boot;
 * without this the first register access dead-buses the hart un-haltably. */
mss_mmc_status_t sar_sd_init(void)
{
    uint32_t hart = (uint32_t)read_csr(mhartid);
    mss_mmc_cfg_t cfg;

    (void)mss_config_clk_rst(MSS_PERIPH_EMMC, (uint8_t)hart, PERIPHERAL_ON);

    cfg.clk_rate       = MSS_MMC_CLOCK_25MHZ;
    cfg.card_type      = MSS_MMC_CARD_TYPE_SD;          /* microSD (not eMMC) */
    cfg.data_bus_width = MSS_MMC_DATA_WIDTH_4BIT;       /* SD_DATA0-3 (4 lines) */
    cfg.bus_speed_mode = MSS_SDCARD_MODE_DEFAULT_SPEED; /* conservative bring-up */
    cfg.bus_voltage    = MSS_MMC_3_3V_BUS_VOLTAGE;      /* SD is 3.3 V on Discovery */

    return MSS_MMC_init(&cfg);
}

/* ---- synchronous single-block helpers (SDMA hangs on this platform) ---------*/
static mss_mmc_status_t sd_rd_blocks(uint32_t lba, uintptr_t dst, uint32_t nblocks)
{
    mss_mmc_status_t st = MSS_MMC_TRANSFER_SUCCESS;
    for (uint32_t i = 0u; i < nblocks; i++) {
        st = MSS_MMC_single_block_read(lba + i,
                 (uint32_t *)(dst + (uintptr_t)i * SAR_SD_BLK_BYTES));
        if (st != MSS_MMC_TRANSFER_SUCCESS) break;
    }
    return st;
}
static mss_mmc_status_t sd_wr_blocks(uintptr_t src, uint32_t lba, uint32_t nblocks)
{
    mss_mmc_status_t st = MSS_MMC_TRANSFER_SUCCESS;
    for (uint32_t i = 0u; i < nblocks; i++) {
        st = MSS_MMC_single_block_write(
                 (const uint32_t *)(src + (uintptr_t)i * SAR_SD_BLK_BYTES), lba + i);
        if (st != MSS_MMC_TRANSFER_SUCCESS) break;
    }
    return st;
}
static inline uint32_t bytes_to_blocks(uint32_t n)
{ return (n + SAR_SD_BLK_BYTES - 1u) / SAR_SD_BLK_BYTES; }

/* ---- scene load: 'SARI' @ SAR_SD_SCENE_LBA -> DDR role addrs + JOB ---------- */
uint32_t sar_sd_load_scene(uint32_t scene_idx)
{
    uint32_t hart = (uint32_t)read_csr(mhartid);
    uintptr_t sbuf = (uintptr_t)SAR_SD_SB_SCRATCH_ADDR;
    mss_mmc_status_t st;

    /* superblock -> TOC entry (read enough blocks to cover toc[scene_idx]) */
    uint32_t sb_blocks = bytes_to_blocks(16u + (scene_idx + 1u) * (uint32_t)sizeof(sar_emmc_in_entry_t));
    st = sd_rd_blocks(SAR_SD_SCENE_LBA, sbuf, sb_blocks);
    if (st != MSS_MMC_TRANSFER_SUCCESS) return SAR_SD_ERR_IO;
    flush_l2_cache(hart);   /* SDMMC wrote physical DDR -> refetch fresh from DDR */

    sar_emmc_in_super_t *sb = (sar_emmc_in_super_t *)sbuf;
    if (sb->magic != SAR_EMMC_IN_MAGIC || scene_idx >= sb->count) return SAR_SD_ERR_MAGIC;
    sar_emmc_in_entry_t *e = &sb->toc[scene_idx];
    uint32_t blob_lba = (uint32_t)e->lba;   /* ABSOLUTE card LBA (already P2-based) */
    uint32_t sig_len  = e->sig_len;
    uint32_t sig_crc_exp = e->sig_crc;
    /* stash the job-semantic fields before we reuse sbuf for the blob header */
    uint32_t jM = e->M, jN = e->N, jFR = e->fft_r, jFA = e->fft_a;
    int32_t  jExp = e->bfp_in_exp; uint32_t jSigCrc = e->sig_crc;

    /* blob header + segment table (fits in the first block: 16B hdr + 10*16B) */
    st = sd_rd_blocks(blob_lba, sbuf, 1u);
    if (st != MSS_MMC_TRANSFER_SUCCESS) return SAR_SD_ERR_IO;
    flush_l2_cache(hart);
    sar_emmc_blob_hdr_t *bh = (sar_emmc_blob_hdr_t *)sbuf;
    if (bh->magic != SAR_EMMC_BLOB_MAGIC) return SAR_SD_ERR_MAGIC;
    sar_emmc_seg_t *segs = (sar_emmc_seg_t *)(sbuf + sizeof(sar_emmc_blob_hdr_t));
    uint32_t nseg = bh->seg_count;

    /* scatter each segment to its role DDR address */
    for (uint32_t s = 0u; s < nseg; s++) {
        uint64_t dst = sar_emmc_role_addr(segs[s].role);
        if (dst == 0u) return SAR_SD_ERR_PARAM;
        uint32_t seg_lba = blob_lba + segs[s].blob_off / SAR_SD_BLK_BYTES;
        st = sd_rd_blocks(seg_lba, (uintptr_t)dst, bytes_to_blocks(segs[s].byte_len));
        if (st != MSS_MMC_TRANSFER_SUCCESS) return SAR_SD_ERR_IO;
    }
    flush_l2_cache(hart);   /* make L2 coherent (CPU coeffs + FIC0 SIG) */

    /* verify SIG region against the TOC (loopback: card -> DDR faithful) */
    if (ddr_pkt_crc32((const void *)(uintptr_t)SAR_SIG_ADDR, sig_len) != sig_crc_exp)
        return SAR_SD_ERR_CRC;

    /* reconstruct the JOB (mirror of sar_emmc_load / host job_from_in_entry) */
    sar_job_t *job = (sar_job_t *)(uintptr_t)SAR_JOB_ADDR;
    job->magic = SAR_JOB_MAGIC;
    job->M = jM; job->N = jN; job->fft_r = jFR; job->fft_a = jFA;
    job->out_dtype = SAR_OUT_DTYPE_UINT16; job->bfp_in_exp = jExp;
    job->sig_len = sig_len; job->sig_crc = jSigCrc; job->reserved = 0u;
    job->sig_addr = SAR_SIG_ADDR; job->kr_addr = SAR_KR_ADDR; job->kc_addr = SAR_KC_ADDR;
    job->tanphi_addr = SAR_TANPHI_ADDR; job->win_addr = SAR_WIN_ADDR;
    job->out_addr = SAR_OUT_ADDR; job->scratch_addr = SAR_SCRATCH_ADDR;
    flush_l2_cache(hart);   /* push JOB to DDR (read via sar_job_load) */
    (void)sig_crc_exp;
    return SAR_SD_PASS;
}

/* ---- output persist: OUT image -> card @ SAR_SD_OUT_LBA (commit-last) --------
 * CRASH-SAFE ordering: INVALIDATE superblock magic -> write IMAGE -> COMMIT the
 * real superblock LAST, so a power drop mid-write leaves the reader rejecting a
 * torn image rather than trusting a half-written one (same as sar_emmc_save_out). */
uint32_t sar_sd_save_out(uint32_t rows, uint32_t cols, uint32_t scene_id, uint32_t run_seq)
{
    uint32_t hart = (uint32_t)read_csr(mhartid);
    uintptr_t sbuf = (uintptr_t)SAR_SD_SB_SCRATCH_ADDR;
    mss_mmc_status_t st;

    uint32_t byte_len = rows * cols * 2u;   /* uint16 image */
    if (rows == 0u || cols == 0u || (byte_len % SAR_SD_BLK_BYTES) != 0u) return SAR_SD_ERR_PARAM;

    /* OUT is fabric-written (FIC0 non-coherent) -> flush so the SDMMC master
     * reads the real image from DDR, then CRC the same bytes. */
    flush_l2_cache(hart);
    uint32_t out_crc = ddr_pkt_crc32((const void *)(uintptr_t)SAR_OUT_ADDR, byte_len);

    uint32_t sb_blocks = bytes_to_blocks((uint32_t)sizeof(sar_emmc_out_super_t));
    uint32_t img_lba = SAR_SD_OUT_LBA + sb_blocks;

    /* 1) invalidate: zero the first block of the superblock region (magic -> 0) */
    memset((void *)sbuf, 0, SAR_SD_BLK_BYTES);
    flush_l2_cache(hart);
    st = sd_wr_blocks(sbuf, SAR_SD_OUT_LBA, 1u);
    if (st != MSS_MMC_TRANSFER_SUCCESS) return SAR_SD_ERR_IO;

    /* 2) write the image payload (the long, interruptible part) */
    st = sd_wr_blocks((uintptr_t)SAR_OUT_ADDR, img_lba, bytes_to_blocks(byte_len));
    if (st != MSS_MMC_TRANSFER_SUCCESS) return SAR_SD_ERR_IO;

    /* 3) build + write the real superblock LAST = the commit point */
    memset((void *)sbuf, 0, (size_t)sb_blocks * SAR_SD_BLK_BYTES);
    sar_emmc_out_super_t *sb = (sar_emmc_out_super_t *)sbuf;
    sb->magic = SAR_EMMC_OUT_MAGIC; sb->version = SAR_EMMC_VERSION; sb->count = 1u;
    sar_emmc_out_entry_t *oe = &sb->toc[0];
    oe->valid = 1u; oe->scene_id = scene_id; oe->run_seq = run_seq;
    oe->out_dtype = SAR_OUT_DTYPE_UINT16; oe->lba = img_lba; oe->byte_len = byte_len;
    oe->rows = rows; oe->cols = cols; oe->out_crc = out_crc;
    flush_l2_cache(hart);   /* push superblock scratch to DDR for the SDMMC read */
    st = sd_wr_blocks(sbuf, SAR_SD_OUT_LBA, sb_blocks);
    if (st != MSS_MMC_TRANSFER_SUCCESS) return SAR_SD_ERR_IO;

    return SAR_SD_PASS;
}
