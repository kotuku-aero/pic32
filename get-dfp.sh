#!/bin/bash
#
# get-dfp.sh - Download and patch Microchip Device Family Packs for use with vanilla GCC
#
# This script downloads DFP files from Microchip, extracts them, and patches
# the headers and linker scripts to work with standard GCC (removing XC32-specific extensions).
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
# NOTE: All logging goes to stderr (&2) so that functions can return values via stdout
#-----------------------------------------------------------------------------

log() {
    echo "" >&2
    echo "========================================" >&2
    echo "$1" >&2
    echo "========================================" >&2
    echo "" >&2
}

info() {
    echo "[INFO] $1" >&2
}

warn() {
    echo "[WARN] $1" >&2
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
        
        # Download directly to .zip filename (wget output goes to stderr)
        if ! wget --show-progress -O "${download_path}" "${url}"; then
            rm -f "${download_path}"
            error "Failed to download ${filename}"
        fi
        
        info "Download complete: ${download_path}"
    fi
    
    # Return the path via stdout
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
    
    info "Extracting ${name} from ${archive}..."
    
    # .atpack files are just ZIP files
    unzip -q "${archive}" -d "${extract_dir}"
    
    info "Extracted to: ${extract_dir}"
    
    # Return the path via stdout
    echo "${extract_dir}"
}

#-----------------------------------------------------------------------------
# Header Patching Functions
#-----------------------------------------------------------------------------

patch_headers() {
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
    
    # =========================================================================
    # PHASE 1: Remove XC32-specific attributes
    # =========================================================================
    
    # Patch 1: Remove address() attribute (XC32-specific)
    # Changes: __attribute__((section("sfrs"),address(0xBF820000)))
    # To:      __attribute__((section("sfrs")))
    info "Removing XC32-specific address() attributes..."
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/,\s*address(0x[0-9A-Fa-f]*)//g' {} \;
    
    # Patch 2: Remove standalone address() attribute
    # Changes: __attribute__((address(0xBF820000)))
    # To:      (nothing)
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__((address(0x[0-9A-Fa-f]*)))//g' {} \;
    
    # Patch 3: Remove unsupported() attribute (XC32-specific)
    info "Removing XC32-specific unsupported() attributes..."
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/,\s*unsupported//g' {} \;
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__((unsupported))//g' {} \;
    
    # Patch 4: Remove space() attribute (XC32-specific for program/data space)
    info "Removing XC32-specific space() attributes..."
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/,\s*space([^)]*)//g' {} \;
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__((space([^)]*)))//g' {} \;
        
    # Patch 5: Remove unique_section attribute
    info "Removing unique_section attributes..."
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/,\s*unique_section//g' {} \;

    # =========================================================================
    # PHASE 2: Remove section() attributes from extern declarations
    # Standard GCC doesn't allow storage class specifiers on extern declarations
    # The actual memory placement is handled by the linker script
    # =========================================================================
    
    info "Removing section() attributes from extern declarations..."
    
    # Patch 6: Remove section("sfrs") attribute - this is the most common
    # Changes: extern volatile uint32_t FOO __attribute__((section("sfrs")));
    # To:      extern volatile uint32_t FOO;
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__((section("sfrs")))//g' {} \;
    
    # Patch 7: Remove any other section attributes that might remain
    # Changes: __attribute__((section("...")))
    # To:      (nothing)
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__((section("[^"]*")))//g' {} \;

    # =========================================================================
    # PHASE 3: Clean up any malformed attribute remnants
    # =========================================================================
    
    info "Cleaning up attribute remnants..."
    
    # Patch 8: Clean up empty attribute lists
    # Changes: __attribute__(()) to nothing
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__(())//g' {} \;
    
    # Patch 9: Clean up double commas in remaining attributes
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/,,/,/g' {} \;
    
    # Patch 10: Clean up leading commas in attributes
    # Changes: __attribute__((,section to __attribute__((section
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/__attribute__((\s*,/__attribute__((/g' {} \;
    
    # Patch 11: Clean up trailing commas in attributes  
    # Changes: section("sfrs"),)) to section("sfrs")))
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/,\s*))/))/g' {} \;
    
    # Patch 12: Clean up multiple spaces left behind
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/  \+/ /g' {} \;
    
    # Patch 13: Clean up space before semicolon
    find "${include_dir}" -name "*.h" -exec sed -i \
        's/ \+;/;/g' {} \;
    
    info "Header patching complete for ${name}"
}

#-----------------------------------------------------------------------------
# Linker Script Patching Functions
#-----------------------------------------------------------------------------

patch_linker_scripts() {
    local dfp_dir="$1"
    local name="$2"
    
    log "Patching ${name} linker scripts for vanilla GCC"
    
    # Find all linker scripts in the DFP
    local ld_count=$(find "${dfp_dir}" -name "*.ld" | wc -l)
    info "Found ${ld_count} linker scripts to process"
    
    # =========================================================================
    # PHASE 1: Fix architecture specification
    # =========================================================================
    
    info "Fixing OUTPUT_ARCH for vanilla GNU ld..."
    
    # Change OUTPUT_ARCH(pic32mx) to OUTPUT_ARCH(mips)
    # XC32 uses pic32mx which vanilla ld doesn't recognize
    find "${dfp_dir}" -name "*.ld" -exec sed -i \
        's/OUTPUT_ARCH(pic32mx)/OUTPUT_ARCH(mips)/g' {} \;
    
    # Also handle OUTPUT_ARCH(pic32mz) if present
    find "${dfp_dir}" -name "*.ld" -exec sed -i \
        's/OUTPUT_ARCH(pic32mz)/OUTPUT_ARCH(mips)/g' {} \;

    # =========================================================================
    # PHASE 2: Fix OPTIONAL() directives that vanilla ld might not handle
    # =========================================================================
    
    info "Fixing OPTIONAL() directives..."
    
    # Remove OPTIONAL() wrapper but keep the content
    find "${dfp_dir}" -name "*.ld" -exec sed -i \
       's/OPTIONAL(\([^)]*\))//g' {} \;

    info "Fixing OUTPUT_FORMAT() directives..."

    find "${dfp_dir}" -name "*.ld" -exec sed -i \
           's/OUTPUT_FORMAT("elf32-tradlittlemips")/OUTPUT_FORMAT("elf32-littlemips")/g' {} \;


    # =========================================================================
    # PHASE 4: Add custom sections for vanilla GCC compatibility
    # These sections are needed for features like:
    # - .coherent: DMA buffers in uncached memory (KSEG1)
    # - .config_*: Configuration bits
    # =========================================================================
    
    info "Adding custom sections to linker scripts..."
    
    # Process each linker script that contains SECTIONS
    find "${dfp_dir}" -name "*.ld" | while read -r ldfile; do
        if grep -q "^SECTIONS" "$ldfile" 2>/dev/null; then
            patch_single_linker_script "$ldfile"
        fi
    done
    
    info "Linker script patching complete for ${name}"
}

patch_single_linker_script() {
    local ldfile="$1"
    local basename_ld=$(basename "$ldfile")
    
    info "  Patching sections in: ${basename_ld}"
    
    # Create a temporary file for the patched content
    local tmpfile=$(mktemp)
    
    # -------------------------------------------------------------------------
    # Strategy: Append our custom sections before the final closing brace
    # of the SECTIONS block. We do this by:
    # 1. Finding the line number of the last '}' that closes SECTIONS
    # 2. Inserting our sections before that line
    # -------------------------------------------------------------------------
    
    # Check if .coherent already exists
    if ! grep -q '\.coherent' "$ldfile"; then
        # Find if kseg1_data_mem is defined (for coherent section)
        if grep -q 'kseg1_data_mem' "$ldfile"; then
            # Add coherent section - insert before the last closing brace
            # Use awk for more reliable multi-line insertion
            awk '
            /^}[[:space:]]*$/ && !done {
                print ""
                print "  /* =================================================================="
                print "   * Coherent (uncached) data section for DMA buffers"
                print "   * Use: __attribute__((section(\".coherent\"))) or __attribute__((coherent))"
                print "   * This places data in KSEG1 (uncached) memory region"
                print "   * =================================================================== */"
                print "  .coherent (NOLOAD) :"
                print "  {"
                print "    . = ALIGN(16);"
                print "    _coherent_begin = .;"
                print "    *(.coherent)"
                print "    *(.coherent.*)"
                print "    . = ALIGN(16);"
                print "    _coherent_end = .;"
                print "  } > kseg1_data_mem"
                print ""
                done = 1
            }
            { print }
            ' "$ldfile" > "$tmpfile" && mv "$tmpfile" "$ldfile"
        fi
    fi
    
    # Check if config sections already exist
    if ! grep -q '\.config_BFC0FFC0' "$ldfile"; then
        # Add configuration bit sections
        awk '
        /^}[[:space:]]*$/ && !config_done {
            print ""
            print "  /* =================================================================="
            print "   * Configuration bit sections for vanilla GCC"  
            print "   * Use the macros in pic32mz_config.h to define configuration words"
            print "   * =================================================================== */"
            print "  .config_BFC0FFC0 0xBFC0FFC0 : { KEEP(*(.config_BFC0FFC0)) }"
            print "  .config_BFC0FFC4 0xBFC0FFC4 : { KEEP(*(.config_BFC0FFC4)) }"
            print "  .config_BFC0FFC8 0xBFC0FFC8 : { KEEP(*(.config_BFC0FFC8)) }"
            print "  .config_BFC0FFCC 0xBFC0FFCC : { KEEP(*(.config_BFC0FFCC)) }"
            print "  .config_BFC0FFD0 0xBFC0FFD0 : { KEEP(*(.config_BFC0FFD0)) }"
            print "  .config_BFC0FFD4 0xBFC0FFD4 : { KEEP(*(.config_BFC0FFD4)) }"
            print "  .config_BFC0FFD8 0xBFC0FFD8 : { KEEP(*(.config_BFC0FFD8)) }"
            print "  .config_BFC0FFDC 0xBFC0FFDC : { KEEP(*(.config_BFC0FFDC)) }"
            print "  .config_BFC0FFE0 0xBFC0FFE0 : { KEEP(*(.config_BFC0FFE0)) }"
            print "  .config_BFC0FFE4 0xBFC0FFE4 : { KEEP(*(.config_BFC0FFE4)) }"
            print "  .config_BFC0FFE8 0xBFC0FFE8 : { KEEP(*(.config_BFC0FFE8)) }"
            print "  .config_BFC0FFEC 0xBFC0FFEC : { KEEP(*(.config_BFC0FFEC)) }"
            print "  .config_BFC0FFF0 0xBFC0FFF0 : { KEEP(*(.config_BFC0FFF0)) }"
            print "  .config_BFC0FFF4 0xBFC0FFF4 : { KEEP(*(.config_BFC0FFF4)) }"
            print "  .config_BFC0FFF8 0xBFC0FFF8 : { KEEP(*(.config_BFC0FFF8)) }"
            print "  .config_BFC0FFFC 0xBFC0FFFC : { KEEP(*(.config_BFC0FFFC)) }"
            print "  /* Boot Flash sequence */"
            print "  .config_BFC0FF40 0xBFC0FF40 : { KEEP(*(.config_BFC0FF40)) }"
            print ""
            config_done = 1
        }
        { print }
        ' "$ldfile" > "$tmpfile" && mv "$tmpfile" "$ldfile"
    fi
    
    # Clean up temp file if it still exists
    rm -f "$tmpfile" 2>/dev/null || true
}

#-----------------------------------------------------------------------------
# Startup File Patching Functions
#-----------------------------------------------------------------------------

patch_startup_files() {
    local dfp_dir="$1"
    local name="$2"

    log "Patching ${name} startup files for vanilla GCC"

    # Find all assembly startup files in the DFP
    local asm_count=$(find "${dfp_dir}" -path "*/xc32/startup/*.S" | wc -l)
    info "Found ${asm_count} startup assembly files to process"

    if [ $asm_count -eq 0 ]; then
        info "No startup files found, skipping..."
        return
    fi

    # =========================================================================
    # PHASE 1: Convert XC32-specific section attributes to GNU syntax
    # =========================================================================

    info "Converting XC32 section attributes to standard GNU syntax..."

    # Patch 1: Convert .section NAME,code,keep to .section NAME,"ax",@progbits
    # The "ax" flags mean: a=allocatable, x=executable
    # @progbits means the section contains data (not @nobits which is BSS)
    find "${dfp_dir}" -path "*/xc32/startup/*.S" -exec sed -i \
        's/\.section \([^,]*\),code,keep/.section \1,"ax",@progbits/g' {} \;

    # Patch 2: Convert .section NAME,code (at end of line) to .section NAME,"ax",@progbits
    # Handles cases like: .section .gen_handler,code
    find "${dfp_dir}" -path "*/xc32/startup/*.S" -exec sed -i \
        's/\.section \([^,]*\),code$/\.section \1,"ax",@progbits/g' {} \;

    # Patch 2b: Convert .section NAME, code$ (with optional space, at end of line)
    # Handles cases like: .section .text.general_exception, code
    find "${dfp_dir}" -path "*/xc32/startup/*.S" -exec sed -i \
        's/\.section \([^,]*\), *code$/\.section \1,"ax",@progbits/g' {} \;

    # Patch 3: Handle any remaining standalone ,keep attributes
    # (shouldn't be needed after above patches, but just in case)
    find "${dfp_dir}" -path "*/xc32/startup/*.S" -exec sed -i \
        's/,keep//g' {} \;

    info "Startup file patching complete for ${name}"
}

#-----------------------------------------------------------------------------
# Main Patching Entry Point
#-----------------------------------------------------------------------------

patch_dfp() {
    local dfp_dir="$1"
    local name="$2"

    # Patch headers first
    patch_headers "$dfp_dir" "$name"

    # Then patch linker scripts
    patch_linker_scripts "$dfp_dir" "$name"

    # Finally patch startup assembly files
    patch_startup_files "$dfp_dir" "$name"
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
    
    # Check linker script patching
    info "Verifying linker script patches..."
    local sample_ld=$(find "${dfp_dir}" -name "*.ld" -print -quit)
    if [ -n "$sample_ld" ]; then
        if grep -q "OUTPUT_ARCH(mips)" "$sample_ld"; then
            info "[OK] OUTPUT_ARCH patched to 'mips'"
        else
            warn "[WARN] OUTPUT_ARCH may not be patched correctly"
        fi
        
        if grep -q "\.coherent" "$sample_ld"; then
            info "[OK] .coherent section added"
        else
            info "[INFO] .coherent section not added (may not have kseg1_data_mem)"
        fi
        
        if grep -q "\.config_BFC0FFC0" "$sample_ld"; then
            info "[OK] Configuration bit sections added"
        else
            warn "[WARN] Configuration bit sections may not be added"
        fi
    fi
    
    # Test compile a simple check (if gcc available)
    if command -v mips-elf-gcc &> /dev/null; then
        info "Testing header compilation..."
        
        local test_file=$(mktemp --suffix=.c)
        local test_out=$(mktemp --suffix=.o)
        
        # Test with the short processor define that Microchip headers expect
        cat > "${test_file}" << 'EOF'
#define __PIC32MZ__
#define __32MZ2048EFH064__
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
    
    # Download - capture return value
    local archive
    archive=$(download_dfp "$name" "$force")
    
    info "Archive path: ${archive}"
    
    # Extract - capture return value
    local dfp_dir
    dfp_dir=$(extract_dfp "$archive" "$name")
    
    info "DFP directory: ${dfp_dir}"
    
    # Patch (no return value needed)
    patch_dfp "$dfp_dir" "$name"
    
    # Verify (no return value needed)
    verify_dfp "$dfp_dir" "$name"
    
    log "${name} ready for use"
    info "DFP installed to: ${dfp_dir}"
    info "To use in your toolchain, ensure this path is set:"
    info "  DFP_PATH=${dfp_dir}"
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
    info "Your DFPs are ready in: ${DFP_DIR}"
}

main "$@"
