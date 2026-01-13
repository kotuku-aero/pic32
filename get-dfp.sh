#!/bin/bash
#
# get-dfp.sh - Download and patch Microchip Device Family Packs for use with vanilla GCC
#
# This script downloads DFP files from Microchip, extracts them, and patches
# the headers to work with standard GCC (removing XC32-specific extensions).
#
# Usage:
#   ./get-dfp.sh PIC32MZ-EF          # Download and patch PIC32MZ-EF DFP
#   ./get-dfp.sh PIC32MZ-DA          # Download and patch PIC32MZ-DA DFP
#   ./get-dfp.sh all                 # Download and patch all supported DFPs
#   ./get-dfp.sh --list              # List available DFPs
#   ./get-dfp.sh --clean             # Remove downloaded/extracted files
#
# The patched DFP will be placed in the dfp/ directory alongside this script.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DFP_DIR="${SCRIPT_DIR}/dfp"
DOWNLOAD_DIR="${SCRIPT_DIR}/downloads"

# Microchip pack repository base URL
MICROCHIP_PACK_URL="https://packs.download.microchip.com"

# Supported DFPs and their versions
# Format: NAME|VERSION|FILENAME
declare -A DFP_INFO
DFP_INFO["PIC32MZ-EF"]="1.3.58|Microchip.PIC32MZ-EF_DFP.1.3.58.atpack"
DFP_INFO["PIC32MZ-DA"]="1.4.118|Microchip.PIC32MZ-DA_DFP.1.4.118.atpack"

#-----------------------------------------------------------------------------
# Utility Functions
#-----------------------------------------------------------------------------

log() {
    echo ""
    echo "========================================"
    echo "$1"
    echo "========================================"
    echo ""
}

info() {
    echo "[INFO] $1"
    echo""
}

warn() {
    echo "[WARN] $1"
    echo ""
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <DFP_NAME>

Download and patch Microchip Device Family Packs for use with vanilla GCC.

Arguments:
  DFP_NAME        Name of DFP to download (e.g., PIC32MZ-EF, PIC32MZ-DA)
  all             Download and patch all supported DFPs

Options:
  --list          List available DFPs and versions
  --clean         Remove all downloaded and extracted files
  --force         Force re-download even if files exist
  --help          Show this help message

Examples:
  $(basename "$0") PIC32MZ-EF
  $(basename "$0") all
  $(basename "$0") --list

EOF
}

list_dfps() {
    echo "Available Device Family Packs:"
    echo ""
    printf "  %-15s %-10s %s\n" "NAME" "VERSION" "FILENAME"
    printf "  %-15s %-10s %s\n" "----" "-------" "--------"
    for name in "${!DFP_INFO[@]}"; do
        IFS='|' read -r version filename <<< "${DFP_INFO[$name]}"
        printf "  %-15s %-10s %s\n" "$name" "$version" "$filename"
    done
    echo ""
}

check_prerequisites() {
    local missing=()
    
    for cmd in wget unzip sed find; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        error "Missing required tools: ${missing[*]}
Install with: pacman -S wget unzip sed findutils"
    fi
}

#-----------------------------------------------------------------------------
# Download Functions
#-----------------------------------------------------------------------------

download_dfp() {
    local name="$1"
    local force="$2"
    
    if [ -z "${DFP_INFO[$name]}" ]; then
        error "Unknown DFP: $name. Use --list to see available DFPs."
    fi
    
    IFS='|' read -r version filename <<< "${DFP_INFO[$name]}"
    
    local url="${MICROCHIP_PACK_URL}/${filename}"
    # Rename .atpack to .zip for MSYS2 unzip compatibility
    local zip_filename="${filename%.atpack}.zip"
    local download_path="${DOWNLOAD_DIR}/${zip_filename}"
    
    mkdir -p "${DOWNLOAD_DIR}"
    
    if [ -f "${download_path}" ] && [ "$force" != "yes" ]; then
        info "Using cached download: ${zip_filename}"
    else
        info "Downloading ${name} v${version}..."
        info "URL: ${url}"
        
        # Download directly to .zip filename
        if ! wget -q --show-progress -O "${download_path}" "${url}"; then
            rm -f "${download_path}"
            error "Failed to download ${filename}"
        fi
        
        info "Download complete: ${download_path}"
    fi
    
    echo "${download_path}"
}

#-----------------------------------------------------------------------------
# Extraction Functions
#-----------------------------------------------------------------------------

extract_dfp() {
    local archive="$1"
    local name="$2"
    
    local extract_dir="${DFP_DIR}/${name}"
    
    # Remove existing extraction
    if [ -d "${extract_dir}" ]; then
        info "Removing existing ${name} directory..."
        rm -rf "${extract_dir}"
    fi
    
    mkdir -p "${extract_dir}"
    
    info "Extracting ${name}..."
    
    # .atpack files are just ZIP files
    unzip -q "${archive}" -d "${extract_dir}"
    
    info "Extracted to: ${extract_dir}"
    
    echo "${extract_dir}"
}

#-----------------------------------------------------------------------------
# Patching Functions
#-----------------------------------------------------------------------------

patch_dfp() {
    local dfp_dir="$1"
    local name="$2"
    
    log "Patching ${name} headers for vanilla GCC"
    
    local include_dir="${dfp_dir}/include"
    
    if [ ! -d "${include_dir}" ]; then
        error "Include directory not found: ${include_dir}"
    fi
    
    # Count files to patch
    local file_count=$(find "${include_dir}" -name "*.h" | wc -l)
    info "Found ${file_count} header files to process"
    
    # Patch 1: Remove address() attribute (XC32-specific)
    # Changes: __attribute__((section("sfrs"),address(0xBF820000)))
    # To:      __attribute__((section("sfrs")))
    info "Removing XC32-specific address() attributes..."
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/,address(0x[0-9A-Fa-f]*)//g' {} \;
    
    # Patch 2: Remove standalone address() attribute
    # Changes: __attribute__((address(0xBF820000)))
    # To:      (nothing)
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__((address(0x[0-9A-Fa-f]*)))//g' {} \;
    
    # Patch 3: Remove unsupported() attribute (XC32-specific)
    info "Removing XC32-specific unsupported() attributes..."
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/,unsupported//g' {} \;
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__((unsupported))//g' {} \;
    
    # Patch 4: Remove space() attribute (XC32-specific for program/data space)
    info "Removing XC32-specific space() attributes..."
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/,space([^)]*)//g' {} \;
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__((space([^)]*)))//g' {} \;
        
    # Patch 5: Remove unique_section attribute
    info "Removing unique_section attributes..."
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/,unique_section//g' {} \;
    
    # Patch 6: Clean up empty attribute lists
    # Changes: __attribute__(()) to nothing
    info "Cleaning up empty attribute lists..."
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__(())//g' {} \;
    
    # Patch 7: Clean up double commas in remaining attributes
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/,,/,/g' {} \;
    
    # Patch 8: Clean up leading commas in attributes
    # Changes: __attribute__((,section to __attribute__((section
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__(( *,/__attribute__((/g' {} \;
    
    # Patch 9: Clean up trailing commas in attributes  
    # Changes: section("sfrs"),)) to section("sfrs")))
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/, *))/))/g' {} \;
    
    # Patch 10: Fix any __attribute__((section("sfrs"))) that lost the section name
    # This shouldn't happen but let's be safe
    
    info "Patching complete for ${name}"
}

#-----------------------------------------------------------------------------
# Verification Functions
#-----------------------------------------------------------------------------

verify_dfp() {
    local dfp_dir="$1"
    local name="$2"
    
    log "Verifying ${name} installation"
    
    local include_dir="${dfp_dir}/include"
    
    # Check for key files
    local key_files=(
        "xc.h"
    )
    
    local all_ok=true
    
    for file in "${key_files[@]}"; do
        if [ -f "${include_dir}/${file}" ]; then
            info "[OK] ${file}"
        else
            warn "[MISSING] ${file}"
            all_ok=false
        fi
    done
    
    # Check for processor-specific headers
    local proc_dir="${include_dir}/proc"
    if [ -d "${proc_dir}" ]; then
        local proc_count=$(find "${proc_dir}" -name "p32*.h" | wc -l)
        info "[OK] Found ${proc_count} processor-specific headers"
    else
        warn "[MISSING] proc/ directory"
        all_ok=false
    fi
    
    # Test compile a simple check (if gcc available)
    if command -v mips-elf-gcc &> /dev/null; then
        info "Testing header compilation..."
        
        local test_file=$(mktemp --suffix=.c)
        local test_out=$(mktemp --suffix=.o)
        
        cat > "${test_file}" << 'EOF'
#define __PIC32MZ__
#define __PIC32MZ2048EFH064__
#include <xc.h>
int main(void) { return 0; }
EOF
        
        if mips-elf-gcc -c -I"${include_dir}" -march=m14k -EL \
            -o "${test_out}" "${test_file}" 2>/dev/null; then
            info "[OK] Headers compile without errors"
        else
            warn "[WARN] Headers may have compilation issues"
            # Try again with output to see warnings
            mips-elf-gcc -c -I"${include_dir}" -march=m14k -EL \
                -o "${test_out}" "${test_file}" 2>&1 | head -20 || true
        fi
        
        rm -f "${test_file}" "${test_out}"
    else
        info "[SKIP] mips-elf-gcc not found, skipping compile test"
    fi
    
    if [ "$all_ok" = true ]; then
        info "Verification passed for ${name}"
    else
        warn "Verification completed with warnings for ${name}"
    fi
}

#-----------------------------------------------------------------------------
# Clean Function
#-----------------------------------------------------------------------------

clean_all() {
    log "Cleaning downloaded and extracted files"
    
    if [ -d "${DOWNLOAD_DIR}" ]; then
        info "Removing downloads directory..."
        rm -rf "${DOWNLOAD_DIR}"
    fi
    
    if [ -d "${DFP_DIR}" ]; then
        info "Removing dfp directory..."
        rm -rf "${DFP_DIR}"
    fi
    
    info "Clean complete"
}

#-----------------------------------------------------------------------------
# Main Process Function
#-----------------------------------------------------------------------------

process_dfp() {
    local name="$1"
    local force="$2"
    
    log "Processing ${name}"
    
    # Download
    local archive=$(download_dfp "$name" "$force")
    
    # Extract
    local dfp_dir=$(extract_dfp "$archive" "$name")
    
    # Patch
    patch_dfp "$dfp_dir" "$name"
    
    # Verify
    verify_dfp "$dfp_dir" "$name"
    
    log "${name} ready for use"
    echo ""
    echo "DFP installed to: ${dfp_dir}"
    echo ""
    echo "To use in your toolchain, ensure this path is set:"
    echo "  DFP_PATH=${dfp_dir}"
    echo ""
}

#-----------------------------------------------------------------------------
# Main
#-----------------------------------------------------------------------------

main() {
    local force="no"
    local action=""
    local dfp_name=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_usage
                exit 0
                ;;
            --list|-l)
                list_dfps
                exit 0
                ;;
            --clean)
                action="clean"
                shift
                ;;
            --force|-f)
                force="yes"
                shift
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                dfp_name="$1"
                shift
                ;;
        esac
    done
    
    # Handle clean action
    if [ "$action" = "clean" ]; then
        clean_all
        exit 0
    fi
    
    # Require DFP name
    if [ -z "$dfp_name" ]; then
        show_usage
        exit 1
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Process requested DFP(s)
    if [ "$dfp_name" = "all" ]; then
        for name in "${!DFP_INFO[@]}"; do
            process_dfp "$name" "$force"
        done
    else
        # Convert to uppercase for matching
        dfp_name=$(echo "$dfp_name" | tr '[:lower:]' '[:upper:]')
        process_dfp "$dfp_name" "$force"
    fi
    
    log "All done!"
    echo "Your DFPs are ready in: ${DFP_DIR}"
}

main "$@"
