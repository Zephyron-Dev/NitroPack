#!/usr/bin/env bash
# =============================================================================
# NitroPack - Standalone Assembly Script
# =============================================================================
# This script can be run locally to build NitroPack without GitHub Actions.
# It fetches the latest releases of all CFW components and assembles them
# into an SD-card-ready ZIP file.
#
# Usage:
#   ./scripts/assemble_pack.sh [options]
#
# Options:
#   -o, --output DIR    Output directory (default: ./build)
#   -v, --version VER   Override version string
#   -c, --clean         Clean build directory before starting
#   -h, --help          Show this help message
#
# Requirements:
#   - curl, wget, unzip, jq, zip
#   - GitHub personal access token (optional, for higher rate limits)
#     Set via GITHUB_TOKEN environment variable
#
# DISCLAIMER: For educational purposes only. Own your games!
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PACK_NAME="NitroPack"
OUTPUT_DIR="./build"
VERSION=""
CLEAN_BUILD=false

# GitHub repositories
declare -A REPOS=(
    ["atmosphere"]="Atmosphere-NX/Atmosphere"
    ["hekate"]="CTCaer/hekate"
    ["tesla"]="WerWolv/Tesla-Menu"
    ["ovlloader"]="WerWolv/nx-ovlloader"
    ["dbi"]="rashevskyv/dbi"
    ["nxthemes"]="exelix11/SwitchThemeInjector"
    ["goldleaf"]="XorTroll/Goldleaf"
    ["jksv"]="Zephyron-Dev/JKSV"
    ["nxshell"]="joel16/NX-Shell"
    ["checkpoint"]="Zephyron-Dev/Checkpoint"
    ["hbappstore"]="fortheusers/hb-appstore"
    ["oc_switchcraft"]="halop/OC-Switchcraft-EOS"
)

# Version tracking
declare -A VERSIONS

# =============================================================================
# Helper Functions
# =============================================================================

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                  ║"
    echo "║     ███╗   ██╗██╗████████╗██████╗  ██████╗ ██████╗  █████╗  ██████╗██╗  ██╗ ║"
    echo "║     ████╗  ██║██║╚══██╔══╝██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔════╝██║ ██╔╝ ║"
    echo "║     ██╔██╗ ██║██║   ██║   ██████╔╝██║   ██║██████╔╝███████║██║     █████╔╝  ║"
    echo "║     ██║╚██╗██║██║   ██║   ██╔══██╗██║   ██║██╔═══╝ ██╔══██║██║     ██╔═██╗  ║"
    echo "║     ██║ ╚████║██║   ██║   ██║  ██║╚██████╔╝██║     ██║  ██║╚██████╗██║  ██╗ ║"
    echo "║     ╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ║"
    echo "║                                                                  ║"
    echo "║            Ultimate Nintendo Switch CFW Bundle Builder           ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -o, --output DIR    Output directory (default: ./build)"
    echo "  -v, --version VER   Override version string"
    echo "  -c, --clean         Clean build directory before starting"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  GITHUB_TOKEN        GitHub personal access token (optional)"
    echo ""
    echo "Example:"
    echo "  $0 --output ./my-build --version v2024.01.15"
}

check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing=()
    
    for cmd in curl wget unzip jq zip; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing[*]}"
        echo "Please install them using your package manager:"
        echo "  Ubuntu/Debian: sudo apt install ${missing[*]}"
        echo "  macOS: brew install ${missing[*]}"
        exit 1
    fi
    
    log_success "All dependencies found"
}

# =============================================================================
# GitHub API Functions
# =============================================================================

# Get auth header if token is available
get_auth_header() {
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        echo "-H \"Authorization: Bearer $GITHUB_TOKEN\""
    else
        echo ""
    fi
}

# Fetch latest release info from GitHub
get_latest_release() {
    local repo=$1
    local auth_header=""
    
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        auth_header="-H \"Authorization: Bearer $GITHUB_TOKEN\""
    fi
    
    curl -sL \
        -H "Accept: application/vnd.github+json" \
        ${auth_header} \
        "https://api.github.com/repos/${repo}/releases/latest"
}

# Get download URL for an asset matching a pattern
get_asset_url() {
    local release_info=$1
    local pattern=$2
    
    echo "$release_info" | jq -r ".assets[] | select(.name | test(\"$pattern\")) | .browser_download_url" | head -1
}

# Get release tag
get_release_tag() {
    local release_info=$1
    echo "$release_info" | jq -r '.tag_name // empty'
}

# Download file with progress
download_file() {
    local url=$1
    local output=$2
    local name=$3
    
    log_info "Downloading $name..."
    
    if wget -q --show-progress -O "$output" "$url"; then
        log_success "Downloaded $name"
        return 0
    else
        log_error "Failed to download $name"
        return 1
    fi
}

# =============================================================================
# Component Download Functions
# =============================================================================

download_atmosphere() {
    log_info "Fetching Atmosphere release info..."
    
    local release_info=$(get_latest_release "${REPOS[atmosphere]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["atmosphere"]=$version
    
    log_info "Atmosphere version: $version"
    
    # Download main package
    local atmo_url=$(get_asset_url "$release_info" "atmosphere-.*\\.zip$")
    if [ -n "$atmo_url" ] && [ "$atmo_url" != "null" ]; then
        download_file "$atmo_url" "$DOWNLOADS/atmosphere.zip" "Atmosphere"
    else
        log_error "Could not find Atmosphere download URL"
        return 1
    fi
    
    # Download fusee.bin
    local fusee_url=$(get_asset_url "$release_info" "^fusee\\.bin$")
    if [ -n "$fusee_url" ] && [ "$fusee_url" != "null" ]; then
        download_file "$fusee_url" "$DOWNLOADS/fusee.bin" "fusee.bin"
    fi
}

download_hekate() {
    log_info "Fetching Hekate release info..."
    
    local release_info=$(get_latest_release "${REPOS[hekate]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["hekate"]=$version
    
    log_info "Hekate version: $version"
    
    local hekate_url=$(get_asset_url "$release_info" "hekate_ctcaer.*\\.zip$")
    if [ -n "$hekate_url" ] && [ "$hekate_url" != "null" ]; then
        download_file "$hekate_url" "$DOWNLOADS/hekate.zip" "Hekate"
    else
        log_error "Could not find Hekate download URL"
        return 1
    fi
}

download_tesla() {
    log_info "Fetching Tesla Menu release info..."
    
    local release_info=$(get_latest_release "${REPOS[tesla]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["tesla"]=$version
    
    log_info "Tesla Menu version: $version"
    
    local tesla_url=$(get_asset_url "$release_info" "ovlmenu\\.ovl$")
    if [ -n "$tesla_url" ] && [ "$tesla_url" != "null" ]; then
        download_file "$tesla_url" "$DOWNLOADS/ovlmenu.ovl" "Tesla Menu"
    else
        log_warning "Could not find Tesla Menu download URL"
    fi
}

download_ovlloader() {
    log_info "Fetching nx-ovlloader release info..."
    
    local release_info=$(get_latest_release "${REPOS[ovlloader]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["ovlloader"]=$version
    
    log_info "nx-ovlloader version: $version"
    
    local ovl_url=$(get_asset_url "$release_info" "nx-ovlloader\\.zip$")
    if [ -n "$ovl_url" ] && [ "$ovl_url" != "null" ]; then
        download_file "$ovl_url" "$DOWNLOADS/nx-ovlloader.zip" "nx-ovlloader"
    else
        log_warning "Could not find nx-ovlloader download URL"
    fi
}

download_dbi() {
    log_info "Fetching DBI release info..."
    
    local release_info=$(get_latest_release "${REPOS[dbi]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["dbi"]=$version
    
    log_info "DBI version: $version"
    
    # Try direct NRO first
    local dbi_url=$(get_asset_url "$release_info" "DBI\\.nro$")
    if [ -n "$dbi_url" ] && [ "$dbi_url" != "null" ]; then
        download_file "$dbi_url" "$DOWNLOADS/DBI.nro" "DBI"
    else
        # Try zip package
        dbi_url=$(get_asset_url "$release_info" "\\.zip$")
        if [ -n "$dbi_url" ] && [ "$dbi_url" != "null" ]; then
            download_file "$dbi_url" "$DOWNLOADS/dbi.zip" "DBI"
        else
            log_warning "Could not find DBI download URL"
        fi
    fi
}

download_nxthemes() {
    log_info "Fetching NXThemeInstaller release info..."
    
    local release_info=$(get_latest_release "${REPOS[nxthemes]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["nxthemes"]=$version
    
    log_info "NXThemeInstaller version: $version"
    
    local nxt_url=$(get_asset_url "$release_info" "NXThemesInstaller\\.nro$")
    if [ -n "$nxt_url" ] && [ "$nxt_url" != "null" ]; then
        download_file "$nxt_url" "$DOWNLOADS/NXThemesInstaller.nro" "NXThemeInstaller"
    else
        log_warning "Could not find NXThemeInstaller download URL"
    fi
}

download_goldleaf() {
    log_info "Fetching Goldleaf release info..."
    
    local release_info=$(get_latest_release "${REPOS[goldleaf]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["goldleaf"]=$version
    
    log_info "Goldleaf version: $version"
    
    local gl_url=$(get_asset_url "$release_info" "Goldleaf\\.nro$")
    if [ -n "$gl_url" ] && [ "$gl_url" != "null" ]; then
        download_file "$gl_url" "$DOWNLOADS/Goldleaf.nro" "Goldleaf"
    else
        log_warning "Could not find Goldleaf download URL"
    fi
}

download_jksv() {
    log_info "Fetching JKSV release info..."
    
    local release_info=$(get_latest_release "${REPOS[jksv]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["jksv"]=$version
    
    log_info "JKSV version: $version"
    
    local jksv_url=$(get_asset_url "$release_info" "JKSV\\.nro$")
    if [ -n "$jksv_url" ] && [ "$jksv_url" != "null" ]; then
        download_file "$jksv_url" "$DOWNLOADS/JKSV.nro" "JKSV"
    else
        log_warning "Could not find JKSV download URL"
    fi
}

download_nxshell() {
    log_info "Fetching NX-Shell release info..."
    
    local release_info=$(get_latest_release "${REPOS[nxshell]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["nxshell"]=$version
    
    log_info "NX-Shell version: $version"
    
    local nxs_url=$(get_asset_url "$release_info" "NX-Shell\\.nro$")
    if [ -n "$nxs_url" ] && [ "$nxs_url" != "null" ]; then
        download_file "$nxs_url" "$DOWNLOADS/NX-Shell.nro" "NX-Shell"
    else
        log_warning "Could not find NX-Shell download URL"
    fi
}

download_checkpoint() {
    log_info "Fetching Checkpoint release info..."
    
    local release_info=$(get_latest_release "${REPOS[checkpoint]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["checkpoint"]=$version
    
    log_info "Checkpoint version: $version"
    
    local cp_url=$(get_asset_url "$release_info" "Checkpoint\\.nro$")
    if [ -n "$cp_url" ] && [ "$cp_url" != "null" ]; then
        download_file "$cp_url" "$DOWNLOADS/Checkpoint.nro" "Checkpoint"
    else
        log_warning "Could not find Checkpoint download URL"
    fi
}

download_hbappstore() {
    log_info "Fetching HB App Store release info..."
    
    local release_info=$(get_latest_release "${REPOS[hbappstore]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["hbappstore"]=$version
    
    log_info "HB App Store version: $version"
    
    local hb_url=$(get_asset_url "$release_info" "appstore\\.nro$")
    if [ -n "$hb_url" ] && [ "$hb_url" != "null" ]; then
        download_file "$hb_url" "$DOWNLOADS/appstore.nro" "HB App Store"
    else
        log_warning "Could not find HB App Store download URL"
    fi
}

download_oc_switchcraft() {
    log_info "Fetching OC Switchcraft EOS release info..."
    
    local release_info=$(get_latest_release "${REPOS[oc_switchcraft]}")
    local version=$(get_release_tag "$release_info")
    VERSIONS["oc_switchcraft"]=$version
    
    log_info "OC Switchcraft EOS version: $version"
    
    local oc_url=$(get_asset_url "$release_info" "\\.zip$")
    if [ -n "$oc_url" ] && [ "$oc_url" != "null" ]; then
        download_file "$oc_url" "$DOWNLOADS/oc-switchcraft.zip" "OC Switchcraft EOS"
    else
        log_warning "Could not find OC Switchcraft EOS download URL"
    fi
}

# =============================================================================
# Assembly Functions
# =============================================================================

extract_and_assemble() {
    log_info "Extracting and assembling pack..."
    
    # Extract Atmosphere (base structure)
    if [ -f "$DOWNLOADS/atmosphere.zip" ]; then
        log_info "  → Extracting Atmosphere..."
        unzip -q -o "$DOWNLOADS/atmosphere.zip" -d "$PACK_DIR/"
    fi
    
    # Extract Hekate
    if [ -f "$DOWNLOADS/hekate.zip" ]; then
        log_info "  → Extracting Hekate..."
        unzip -q -o "$DOWNLOADS/hekate.zip" -d "$PACK_DIR/"
    fi
    
    # Extract nx-ovlloader (Tesla sysmodule)
    if [ -f "$DOWNLOADS/nx-ovlloader.zip" ]; then
        log_info "  → Extracting nx-ovlloader..."
        unzip -q -o "$DOWNLOADS/nx-ovlloader.zip" -d "$PACK_DIR/"
    fi
    
    # Extract OC Switchcraft EOS (overclocking)
    if [ -f "$DOWNLOADS/oc-switchcraft.zip" ]; then
        log_info "  → Extracting OC Switchcraft EOS..."
        unzip -q -o "$DOWNLOADS/oc-switchcraft.zip" -d "$PACK_DIR/"
    fi
    
    # Extract DBI if zip exists
    if [ -f "$DOWNLOADS/dbi.zip" ]; then
        log_info "  → Extracting DBI..."
        mkdir -p "$EXTRACTED/dbi"
        unzip -q -o "$DOWNLOADS/dbi.zip" -d "$EXTRACTED/dbi/"
        mkdir -p "$PACK_DIR/switch/DBI"
        find "$EXTRACTED/dbi" -name "*.nro" -exec cp {} "$PACK_DIR/switch/DBI/" \;
        find "$EXTRACTED/dbi" -name "*.ini" -exec cp {} "$PACK_DIR/switch/DBI/" \; 2>/dev/null || true
    elif [ -f "$DOWNLOADS/DBI.nro" ]; then
        mkdir -p "$PACK_DIR/switch/DBI"
        cp "$DOWNLOADS/DBI.nro" "$PACK_DIR/switch/DBI/"
    fi
    
    # Create directories and copy standalone NROs
    log_info "  → Organizing homebrew apps..."
    
    # Tesla Menu overlay
    if [ -f "$DOWNLOADS/ovlmenu.ovl" ]; then
        mkdir -p "$PACK_DIR/switch/.overlays"
        cp "$DOWNLOADS/ovlmenu.ovl" "$PACK_DIR/switch/.overlays/"
    fi
    
    if [ -f "$DOWNLOADS/NXThemesInstaller.nro" ]; then
        mkdir -p "$PACK_DIR/switch/NXThemesInstaller"
        cp "$DOWNLOADS/NXThemesInstaller.nro" "$PACK_DIR/switch/NXThemesInstaller/"
    fi
    
    if [ -f "$DOWNLOADS/Goldleaf.nro" ]; then
        mkdir -p "$PACK_DIR/switch/Goldleaf"
        cp "$DOWNLOADS/Goldleaf.nro" "$PACK_DIR/switch/Goldleaf/"
    fi
    
    if [ -f "$DOWNLOADS/JKSV.nro" ]; then
        mkdir -p "$PACK_DIR/switch/JKSV"
        cp "$DOWNLOADS/JKSV.nro" "$PACK_DIR/switch/JKSV/"
    fi
    
    if [ -f "$DOWNLOADS/NX-Shell.nro" ]; then
        mkdir -p "$PACK_DIR/switch/NX-Shell"
        cp "$DOWNLOADS/NX-Shell.nro" "$PACK_DIR/switch/NX-Shell/"
    fi
    
    if [ -f "$DOWNLOADS/Checkpoint.nro" ]; then
        mkdir -p "$PACK_DIR/switch/Checkpoint"
        cp "$DOWNLOADS/Checkpoint.nro" "$PACK_DIR/switch/Checkpoint/"
    fi
    
    if [ -f "$DOWNLOADS/appstore.nro" ]; then
        mkdir -p "$PACK_DIR/switch/appstore"
        cp "$DOWNLOADS/appstore.nro" "$PACK_DIR/switch/appstore/"
    fi
    
    # Copy fusee.bin to payloads
    if [ -f "$DOWNLOADS/fusee.bin" ]; then
        mkdir -p "$PACK_DIR/bootloader/payloads"
        cp "$DOWNLOADS/fusee.bin" "$PACK_DIR/bootloader/payloads/"
    fi
    
    # Copy Hekate payload to root as payload.bin (for modchips/autoboot)
    HEKATE_BIN=$(find "$PACK_DIR/bootloader" -name "hekate_ctcaer_*.bin" 2>/dev/null | head -1)
    if [ -n "$HEKATE_BIN" ]; then
        cp "$HEKATE_BIN" "$PACK_DIR/payload.bin"
        log_success "Copied Hekate to payload.bin"
    fi
    
    log_success "Base assembly complete"
}

apply_configs() {
    log_info "Applying NitroPack configurations..."
    
    # Create hekate_ipl.ini
    cat > "$PACK_DIR/bootloader/hekate_ipl.ini" << 'EOF'
# NitroPack - Hekate Configuration
# https://github.com/Zephyron-Dev/NitroPack

[config]
autoboot=0
autoboot_list=0
bootwait=3
backlight=100
autohosoff=0
autonogc=1
updater2p=1
bootprotect=0

[Atmosphere (CFW)]
payload=bootloader/payloads/fusee.bin
icon=bootloader/res/icon_payload.bmp

[Stock (OFW)]
fss0=atmosphere/package3
stock=1
emummc_force_disable=1
icon=bootloader/res/icon_switch.bmp
EOF

    # Create exosphere.ini
    cat > "$PACK_DIR/exosphere.ini" << 'EOF'
# NitroPack - Exosphere Configuration
# Blanks serial number for additional ban protection
# NOTE: This is NOT a guarantee against bans!

[exosphere]
debugmode=1
debugmode_user=0
disable_user_exception_handlers=0
enable_user_pmu_access=0
blank_prodinfo_sysmmc=0
blank_prodinfo_emummc=1
allow_writing_to_cal_sysmmc=0
log_port=0
log_baud_rate=115200
log_inverted=0
EOF

    # Create atmosphere configs
    mkdir -p "$PACK_DIR/atmosphere/config"
    
    # System settings
    cat > "$PACK_DIR/atmosphere/config/system_settings.ini" << 'EOF'
# NitroPack - Atmosphere System Settings

[atmosphere]
; Power menu reboot options
power_menu_reboot_function = payload

[eupld]
; Disable error uploads to Nintendo
upload_enabled = u8!0x0

[ro]
; Enable easier homebrewing
ease_nro_restriction = u8!0x1
EOF

    # Override config
    cat > "$PACK_DIR/atmosphere/config/override_config.ini" << 'EOF'
# NitroPack - Override Configuration

[hbl_config]
; Open homebrew menu by holding R and launching Album
program_id=010000000000100D
override_any_app=true
override_any_app_key=R
override_any_app_address_space=39_bit
EOF

    # Tesla config
    mkdir -p "$PACK_DIR/config/tesla"
    cat > "$PACK_DIR/config/tesla/config.ini" << 'EOF'
[tesla]
; Key combo: L + Down + R3 (click right stick)
key_combo=L+DDOWN+RSTICK
EOF

    # Create hosts directory
    mkdir -p "$PACK_DIR/atmosphere/hosts"
    cat > "$PACK_DIR/atmosphere/hosts/emummc.txt" << 'EOF'
# NitroPack - DNS Blocking (emuMMC)
# Uncomment lines below to block Nintendo servers

# Nintendo servers (uncomment to block)
#127.0.0.1 *nintendo.*
#127.0.0.1 *nintendo-europe.com
#127.0.0.1 *nintendoswitch.*
#127.0.0.1 95.216.149.205
#127.0.0.1 *conntest.nintendowifi.net
#127.0.0.1 *ctest.cdn.nintendo.net
EOF

    log_success "Configurations applied"
}

create_version_file() {
    log_info "Creating version file..."
    
    # Determine version
    if [ -z "$VERSION" ]; then
        VERSION="v$(date +%Y.%m.%d)"
    fi
    
    cat > "$PACK_DIR/NitroPack_Version.txt" << EOF
╔══════════════════════════════════════════════════════════════════╗
║                         N I T R O P A C K                        ║
║               Ultimate Nintendo Switch CFW Bundle                ║
╠══════════════════════════════════════════════════════════════════╣
║  Version:     ${VERSION}
║  Build Date:  $(date +"%Y-%m-%d %H:%M:%S %Z")
╠══════════════════════════════════════════════════════════════════╣
║  COMPONENT VERSIONS                                              ║
╠══════════════════════════════════════════════════════════════════╣
║  Atmosphere:        ${VERSIONS[atmosphere]:-N/A}
║  Hekate:            ${VERSIONS[hekate]:-N/A}
║  Tesla Menu:        ${VERSIONS[tesla]:-N/A}
║  nx-ovlloader:      ${VERSIONS[ovlloader]:-N/A}
║  DBI:               ${VERSIONS[dbi]:-N/A}
║  NXThemeInstaller:  ${VERSIONS[nxthemes]:-N/A}
║  Goldleaf:          ${VERSIONS[goldleaf]:-N/A}
║  JKSV:              ${VERSIONS[jksv]:-N/A}
║  NX-Shell:          ${VERSIONS[nxshell]:-N/A}
║  Checkpoint:        ${VERSIONS[checkpoint]:-N/A}
║  HB App Store:      ${VERSIONS[hbappstore]:-N/A}
║  OC Switchcraft:    ${VERSIONS[oc_switchcraft]:-N/A}
╠══════════════════════════════════════════════════════════════════╣
║  DISCLAIMER: For educational purposes only. Own your games!      ║
╚══════════════════════════════════════════════════════════════════╝
EOF

    log_success "Version file created"
}

create_zip() {
    log_info "Creating final ZIP package..."
    
    local zip_name="${PACK_NAME}-${VERSION}.zip"
    local zip_path="${OUTPUT_DIR}/${zip_name}"
    
    cd "$PACK_DIR"
    zip -r -9 "$zip_path" .
    cd - > /dev/null
    
    # Generate checksums
    cd "$OUTPUT_DIR"
    sha256sum "$zip_name" > "${zip_name}.sha256"
    md5sum "$zip_name" > "${zip_name}.md5"
    cd - > /dev/null
    
    log_success "Package created: $zip_path"
    log_info "Size: $(du -h "$zip_path" | cut -f1)"
    
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    BUILD COMPLETE ✅                             ║${NC}"
    echo -e "${GREEN}╠══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${NC}  Output: ${CYAN}${zip_path}${NC}"
    echo -e "${GREEN}║${NC}  Size:   ${CYAN}$(du -h "$zip_path" | cut -f1)${NC}"
    echo -e "${GREEN}║${NC}  SHA256: ${CYAN}${zip_name}.sha256${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════╝${NC}"
}

# =============================================================================
# Main Script
# =============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -v|--version)
                VERSION="$2"
                shift 2
                ;;
            -c|--clean)
                CLEAN_BUILD=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Print banner
    print_banner
    
    # Check dependencies
    check_dependencies
    
    # Setup directories
    DOWNLOADS="${OUTPUT_DIR}/downloads"
    EXTRACTED="${OUTPUT_DIR}/extracted"
    PACK_DIR="${OUTPUT_DIR}/pack"
    
    if [ "$CLEAN_BUILD" = true ] && [ -d "$OUTPUT_DIR" ]; then
        log_info "Cleaning build directory..."
        rm -rf "$OUTPUT_DIR"
    fi
    
    mkdir -p "$DOWNLOADS" "$EXTRACTED" "$PACK_DIR"
    mkdir -p "$PACK_DIR"/{atmosphere,bootloader,config,switch}
    
    echo ""
    log_info "Build directory: $OUTPUT_DIR"
    echo ""
    
    # Download all components
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                      DOWNLOADING COMPONENTS                       ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    download_atmosphere
    download_hekate
    download_tesla
    download_ovlloader
    download_dbi
    download_nxthemes
    download_goldleaf
    download_jksv
    download_nxshell
    download_checkpoint
    download_hbappstore
    download_oc_switchcraft
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                         ASSEMBLING PACK                           ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Assemble pack
    extract_and_assemble
    apply_configs
    create_version_file
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                        CREATING PACKAGE                           ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Create final ZIP
    create_zip
    
    echo ""
    echo -e "${YELLOW}⚠️  DISCLAIMER: For educational purposes only. Own your games!${NC}"
    echo ""
}

# Run main function
main "$@"
