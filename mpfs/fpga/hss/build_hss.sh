#!/bin/bash
# build_hss.sh -- build Hart Software Services (HSS) for the PolarFire SoC Discovery Kit.
# HSS is the SD-boot loader: it trains DDR4, reads the GPT-partitioned microSD, loads the
# SAR app payload into DDR, and jumps to it. Output hss.hex becomes an eNVM client in the
# fabric .job. See docs/HSS_INTEGRATION.md.
#
# Prereqs (Windows, git-bash): SoftConsole v2022.2 (RISC-V gcc + make + python), Libero (fpgenprog).
set -e

SC="/c/Microchip/SoftConsole-v2022.2-RISC-V-747"
export SC_INSTALL_DIR="C:/Microchip/SoftConsole-v2022.2-RISC-V-747"
export PATH="$SC/build_tools/bin:$SC/riscv-unknown-elf-gcc/bin:$SC/python3:$PATH"
export FPGENPROG="C:/Microchip/Libero_SoC_2025.2/Libero_SoC/Designer/bin64/fpgenprog.exe"

HSS="${HSS_SRC:-/c/Users/lkwangsi/Documents/github/polarfire-soc/hart-software-services}"
MAKE="$SC/build_tools/bin/make.exe"
BOARD="mpfs-disco-kit"

cd "$HSS"
echo "[hss] defconfig for $BOARD"
"$MAKE" BOARD="$BOARD" defconfig
# SoftConsole v2022.2 ships the riscv64-unknown-elf- gcc 8.3.0 toolchain; HSS selects it only
# when CONFIG_CC_USE_SOFTCONSOLE is set (else it defaults to riscv-none-elf- and fails). See
# application/rules.mk. defconfig does not set it, so force it on the build invocation.
grep -q '^CONFIG_CC_USE_SOFTCONSOLE=y' .config || echo 'CONFIG_CC_USE_SOFTCONSOLE=y' >> .config
echo "[hss] building..."
"$MAKE" BOARD="$BOARD" CONFIG_CC_USE_SOFTCONSOLE=y -j4
echo "[hss] build done. Artifacts:"
ls -la "$HSS"/Default/hss.* 2>/dev/null || ls -la "$HSS"/hss.* 2>/dev/null
