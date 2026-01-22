#!/usr/bin/env bash
# =============================================================================
# NitroPack - Pack Verification Script
# =============================================================================
# This script verifies that a NitroPack build contains all required components
# and has the correct structure for SD card installation.
#
# Usage:
#   ./scripts/verify_pack.sh <path-to-zip-or-directory>
#
# DISCLAIMER: For educational purposes only. Own your games!
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0
WARNINGS=0

log_pass() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((PASSED++))
}

log_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    ((FAILED++))
}

log_warn() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $1"
    ((WARNINGS++))
}

log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Check if file/directory exists
check_exists() {
    local path=$1
    local description=$2
    local required=${3:-true}
    
    if [ -e "$VERIFY_DIR/$path" ]; then
        log_pass "$description exists: $path"
        return 0
    else
        if [ "$required" = true ]; then
            log_fail "$description missing: $path"
        else
            log_warn "$description optional but missing: $path"
        fi
        return 1
    fi
}

# Check if directory is not empty
check_not_empty() {
    local path=$1
    local description=$2
    
    if [ -d "$VERIFY_DIR/$path" ] && [ "$(ls -A "$VERIFY_DIR/$path" 2>/dev/null)" ]; then
        log_pass "$description is not empty: $path"
        return 0
    else
        log_fail "$description is empty or missing: $path"
        return 1
    fi
}

# Main verification
main() {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <path-to-zip-or-directory>"
        exit 1
    fi
    
    local input=$1
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              NitroPack Verification Tool                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Handle ZIP file vs directory
    if [ -f "$input" ] && [[ "$input" == *.zip ]]; then
        log_info "Extracting ZIP for verification..."
        VERIFY_DIR=$(mktemp -d)
        unzip -q "$input" -d "$VERIFY_DIR"
        CLEANUP=true
    elif [ -d "$input" ]; then
        VERIFY_DIR="$input"
        CLEANUP=false
    else
        echo "Error: Input must be a ZIP file or directory"
        exit 1
    fi
    
    log_info "Verifying: $input"
    echo ""
    
    # ==========================================================================
    echo -e "${CYAN}--- Core CFW Components ---${NC}"
    # ==========================================================================
    
    # Atmosphere
    check_exists "atmosphere" "Atmosphere folder"
    check_exists "atmosphere/package3" "Atmosphere package3"
    check_exists "atmosphere/stratosphere.romfs" "Atmosphere stratosphere"
    check_not_empty "atmosphere/exefs_patches" "Sigpatches folder"
    
    # Hekate
    check_exists "bootloader" "Bootloader folder"
    check_exists "bootloader/hekate_ipl.ini" "Hekate config"
    check_not_empty "bootloader/payloads" "Payloads folder"
    
    # Fusee payload
    check_exists "bootloader/payloads/fusee.bin" "Fusee payload"
    
    echo ""
    # ==========================================================================
    echo -e "${CYAN}--- Configuration Files ---${NC}"
    # ==========================================================================
    
    check_exists "exosphere.ini" "Exosphere config"
    check_exists "atmosphere/config" "Atmosphere config folder" false
    check_exists "atmosphere/config/system_settings.ini" "System settings" false
    check_exists "atmosphere/config/override_config.ini" "Override config" false
    
    echo ""
    # ==========================================================================
    echo -e "${CYAN}--- Homebrew Applications ---${NC}"
    # ==========================================================================
    
    check_exists "switch" "Switch homebrew folder"
    check_exists "hbmenu.nro" "Homebrew menu"
    
    # Optional apps
    check_exists "switch/tinfoil" "Tinfoil" false
    check_exists "switch/DBI" "DBI" false
    check_exists "switch/Goldleaf" "Goldleaf" false
    check_exists "switch/JKSV" "JKSV" false
    check_exists "switch/NXThemesInstaller" "NXThemeInstaller" false
    check_exists "switch/NX-Shell" "NX-Shell" false
    
    echo ""
    # ==========================================================================
    echo -e "${CYAN}--- Additional Checks ---${NC}"
    # ==========================================================================
    
    # Check for version file
    check_exists "NitroPack_Version.txt" "Version info file" false
    
    # Check hekate binary exists somewhere
    if find "$VERIFY_DIR" -name "hekate_ctcaer*.bin" 2>/dev/null | grep -q .; then
        log_pass "Hekate binary found"
    else
        log_warn "Hekate binary not found (may be in bootloader/payloads as alternative)"
    fi
    
    # Check for boot.dat (modchip support)
    check_exists "boot.dat" "Modchip boot.dat" false
    
    # Cleanup temp directory
    if [ "$CLEANUP" = true ]; then
        rm -rf "$VERIFY_DIR"
    fi
    
    # Summary
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                      VERIFICATION SUMMARY                        ║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}Passed:${NC}   $PASSED"
    echo -e "${CYAN}║${NC}  ${RED}Failed:${NC}   $FAILED"
    echo -e "${CYAN}║${NC}  ${YELLOW}Warnings:${NC} $WARNINGS"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ $FAILED -gt 0 ]; then
        echo -e "${RED}❌ Pack verification FAILED with $FAILED errors${NC}"
        exit 1
    elif [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Pack verified with $WARNINGS warnings${NC}"
        exit 0
    else
        echo -e "${GREEN}✅ Pack verification PASSED!${NC}"
        exit 0
    fi
}

main "$@"
