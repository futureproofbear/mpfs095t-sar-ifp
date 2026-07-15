/*******************************************************************************
 * sar_sd.h -- microSD scene load + output persist for the Discovery Kit
 * (MPFS095T) autonomous HSS-payload boot.
 *
 * SD sibling of sar_emmc.c's Milestone-3 path. Same self-describing 'SARI'
 * superblock + blob/segment layout (ddr_sar_layout.h) and the JOB-from-TOC
 * contract; the ONLY differences from the Icicle eMMC path are:
 *   - the card is a microSD (card_type SD, 4-bit bus, 3.3 V, NO Icicle TS3A27518E
 *     mux -- the Discovery wires SD directly to the MSS SDIO pads);
 *   - the 'SARI' superblock lives at SAR_SD_SCENE_LBA (GPT partition P2 base),
 *     not the eMMC INPUT LBA. TOC entries carry ABSOLUTE card LBAs, so each blob
 *     segment is seeked directly (no partition math) -- see sd_pack.py --gpt.
 *
 * Single-block, MIE-off, synchronous SDMMC primitives (SDMA has known hangs on
 * this platform); FIC0 is non-coherent so every card<->DDR transfer is paired
 * with the correct flush_l2_cache().
 ******************************************************************************/
#ifndef SAR_SD_H_
#define SAR_SD_H_

#include <stdint.h>
#include "drivers/mss/mss_mmc/mss_mmc.h"   /* mss_mmc_status_t */

/* GPT P2 base LBA: where the 'SARI' superblock lives on the card. FIXED by
 * sd_pack.py --gpt (P1 = 32 MiB HSS-payload reserve at LBA 2048, P2 follows).
 * Coordinated constant -- keep in lock-step with sd_pack.py SAR_SD_SCENE_LBA. */
#define SAR_SD_SCENE_LBA   67584u

/* Output region base LBA (commit-last SAVEOUT target). OPEN COORDINATION ITEM:
 * sd_pack.py currently lays down P1 (payload) + P2 (SARI scene) only; a reserved
 * output region / partition (P3) at this LBA must be pinned in sd_pack.py before
 * on-card save is exercised -- exactly parallel to SAR_SD_SCENE_LBA. Placeholder
 * chosen well past any P2 scene; the value is board-side, not a build constraint. */
#ifndef SAR_SD_OUT_LBA
#define SAR_SD_OUT_LBA     0x2000000u   /* 16 GiB-in reserve; pin in sd_pack.py P3 */
#endif

/* verdict / fail codes (compact, SD-local). */
enum {
    SAR_SD_PASS       = 0u,
    SAR_SD_ERR_PARAM  = 1u,
    SAR_SD_ERR_INIT   = 2u,
    SAR_SD_ERR_MAGIC  = 3u,   /* bad SARI / SARB / SARO magic */
    SAR_SD_ERR_IO     = 4u,   /* block read/write failure */
    SAR_SD_ERR_CRC    = 5u    /* segment / sig / out CRC mismatch */
};

/* Init the MSS SDMMC controller for a microSD card (card_type SD, 4-bit, 3.3 V,
 * default-speed / 25 MHz). Enables the SDMMC peripheral clock + releases its
 * reset BEFORE any SDHCI register access. NO board mux (Discovery wires SD
 * directly). Returns the MSS_MMC_init() status (MSS_MMC_INIT_SUCCESS == 0). */
mss_mmc_status_t sar_sd_init(void);

/* Load scene `scene_idx` (usually 0) from the 'SARI' image at SAR_SD_SCENE_LBA:
 * read the superblock + the scene's blob header/segment table, scatter each
 * segment to its role DDR address, verify the SIG loopback CRC, and rebuild the
 * sar_job_t at SAR_JOB_ADDR from the TOC. Assumes sar_sd_init() already ran.
 * Returns SAR_SD_PASS (0) or a fail code. */
uint32_t sar_sd_load_scene(uint32_t scene_idx);

/* Persist the full OUT image (SAR_OUT_ADDR, rows x cols uint16) to the card at
 * SAR_SD_OUT_LBA using the crash-safe commit-last ordering (invalidate magic ->
 * write image -> write superblock LAST). Assumes sar_sd_init() already ran.
 * Returns SAR_SD_PASS (0) or a fail code. */
uint32_t sar_sd_save_out(uint32_t rows, uint32_t cols, uint32_t scene_id, uint32_t run_seq);

#endif /* SAR_SD_H_ */
