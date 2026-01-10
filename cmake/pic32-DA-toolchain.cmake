# PIC32MZ-DA Cross-Compilation Toolchain File (No FPU - Soft Float)
# For use with custom mips-elf-gcc toolchain
# Use with: cmake -DCMAKE_TOOLCHAIN_FILE=pic32-DA-toolchain.cmake

cmake_minimum_required(VERSION 3.16)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR mips)

# ============================================================================
# Toolchain Paths
# ============================================================================

# Custom mips-elf-gcc toolchain location
if(WIN32)
    set(TOOLCHAIN_PATH "C:/pic32" CACHE PATH "Path to mips-elf toolchain")
else()
    set(TOOLCHAIN_PATH "/opt/pic32" CACHE PATH "Path to mips-elf toolchain")
endif()

set(TOOLCHAIN_PREFIX "mips-elf-")

# Compilers
set(CMAKE_C_COMPILER "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}gcc${CMAKE_EXECUTABLE_SUFFIX}")
set(CMAKE_CXX_COMPILER "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}g++${CMAKE_EXECUTABLE_SUFFIX}")
set(CMAKE_ASM_COMPILER "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}gcc${CMAKE_EXECUTABLE_SUFFIX}")

# Binary utilities
set(CMAKE_AR "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}ar${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Archiver")
set(CMAKE_RANLIB "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}ranlib${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Ranlib")
set(CMAKE_OBJCOPY "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}objcopy${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Objcopy")
set(CMAKE_OBJDUMP "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}objdump${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Objdump")
set(CMAKE_SIZE "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}size${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Size")
set(CMAKE_NM "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}nm${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "NM")

# ============================================================================
# DFP (Device Family Pack) Location
# ============================================================================

# Try to find DFP in multiple locations (in priority order):
# 1. Git submodule location (for CI/CD and version-controlled builds)
# 2. Alongside toolchain
# 3. MPLABX installation (system-wide)

if(EXISTS "${CMAKE_SOURCE_DIR}/xc32/dfp/PIC32MZ-DA")
    set(DFP_PATH "${CMAKE_SOURCE_DIR}/xc32/dfp/PIC32MZ-DA")
    message(STATUS "Using DFP from git submodule: ${DFP_PATH}")
elseif(EXISTS "${TOOLCHAIN_PATH}/dfp/PIC32MZ-DA")
    set(DFP_PATH "${TOOLCHAIN_PATH}/dfp/PIC32MZ-DA")
    message(STATUS "Using DFP from toolchain: ${DFP_PATH}")
elseif(EXISTS "C:/Program Files/Microchip/MPLABX/v6.20/packs/Microchip/PIC32MZ-DA_DFP/1.5.231")
    set(DFP_PATH "C:/Program Files/Microchip/MPLABX/v6.20/packs/Microchip/PIC32MZ-DA_DFP/1.5.231")
    message(STATUS "Using DFP from MPLABX: ${DFP_PATH}")
else()
    message(WARNING "PIC32MZ-DA DFP not found in expected locations!")
    message(WARNING "Build may fail without device-specific headers and linker scripts.")
endif()

# ============================================================================
# PIC32MZ-DA Specific Flags (No FPU - Soft Float)
# ============================================================================

# Architecture: microAptiv core, MIPS32r2, NO hardware FPU
set(PIC32_ARCH_FLAGS "-march=m14k -msoft-float")

# Additional MIPS flags
set(PIC32_MIPS_FLAGS "-mno-mips16 -mno-micromips -EL")
# -EL = Little endian (PIC32 is little endian)
# -mno-mips16 = Don't use MIPS16 ASE
# -mno-micromips = Use standard MIPS32 (not compressed microMIPS)
# Change to -mmicromips if you want smaller code size

# Warning and optimization defaults
set(PIC32_WARN_FLAGS "-Wall -Wextra")

# Combine architecture flags
set(PIC32_CPU_FLAGS "${PIC32_ARCH_FLAGS} ${PIC32_MIPS_FLAGS}")

# ============================================================================
# Compiler Flags
# ============================================================================

# Skip compiler tests that would try to link Windows executables
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# C Flags
set(CMAKE_C_FLAGS_INIT "${PIC32_CPU_FLAGS} ${PIC32_WARN_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG_INIT "-Og -g3 -DDEBUG")
set(CMAKE_C_FLAGS_RELEASE_INIT "-O2 -DNDEBUG")
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "-Os -DNDEBUG")
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "-O2 -g -DNDEBUG")

# C++ Flags
set(CMAKE_CXX_FLAGS_INIT "${PIC32_CPU_FLAGS} ${PIC32_WARN_FLAGS} -fno-exceptions -fno-rtti")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "-Og -g3 -DDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-O2 -DNDEBUG")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "-Os -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-O2 -g -DNDEBUG")

# ASM Flags
set(CMAKE_ASM_FLAGS_INIT "${PIC32_CPU_FLAGS}")

# ============================================================================
# Linker Flags
# ============================================================================

# Base linker flags
set(PIC32_LINKER_FLAGS "-nostartfiles -Wl,--gc-sections")
# -nostartfiles = We provide our own crt0.S
# --gc-sections = Remove unused code/data sections

# Float printf support (optional - adds ~10-15KB)
# Uncomment if you need printf("%f", ...) support
# set(PIC32_LINKER_FLAGS "${PIC32_LINKER_FLAGS} -u _printf_float")

# Float scanf support (optional - adds ~5-10KB)
# Uncomment if you need scanf("%f", ...) support
# set(PIC32_LINKER_FLAGS "${PIC32_LINKER_FLAGS} -u _scanf_float")

set(CMAKE_EXE_LINKER_FLAGS_INIT "${PIC32_CPU_FLAGS} ${PIC32_LINKER_FLAGS}")

# ============================================================================
# Search Paths
# ============================================================================

set(CMAKE_FIND_ROOT_PATH "${TOOLCHAIN_PATH}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# ============================================================================
# Build Identification
# ============================================================================

set(PIC32_BUILD TRUE CACHE BOOL "Building for PIC32" FORCE)
set(PIC32_FAMILY "DA" CACHE STRING "PIC32 processor family" FORCE)
set(PIC32_HAS_FPU FALSE CACHE BOOL "PIC32 has hardware FPU" FORCE)

# ============================================================================
# Helper Functions
# ============================================================================

# Function to generate HEX file from ELF
function(pic32_generate_hex TARGET)
    add_custom_command(TARGET ${TARGET} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${TARGET}> $<TARGET_FILE_DIR:${TARGET}>/${TARGET}.hex
        COMMENT "Generating HEX file: ${TARGET}.hex"
    )
endfunction()

# Function to generate BIN file from ELF
function(pic32_generate_bin TARGET)
    add_custom_command(TARGET ${TARGET} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${TARGET}> $<TARGET_FILE_DIR:${TARGET}>/${TARGET}.bin
        COMMENT "Generating BIN file: ${TARGET}.bin"
    )
endfunction()

# Function to print size information
function(pic32_print_size TARGET)
    add_custom_command(TARGET ${TARGET} POST_BUILD
        COMMAND ${CMAKE_SIZE} --format=berkeley $<TARGET_FILE:${TARGET}>
        COMMENT "Size of ${TARGET}:"
    )
endfunction()

# Convenience function to add all post-build steps
function(pic32_firmware TARGET)
    pic32_generate_hex(${TARGET})
    pic32_generate_bin(${TARGET})
    pic32_print_size(${TARGET})
endfunction()
