# PIC32MZ-DA Cross-Compilation Toolchain File (No FPU - Soft Float)
# For use with custom pic32-gcc toolchain
# Use with: cmake -DCMAKE_TOOLCHAIN_FILE=-DA-toolchain.cmake

cmake_minimum_required(VERSION 3.16)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR mips)

set(CMAKE_C_COMPILER_ID GNU)
set(CMAKE_C_COMPILER_VERSION "15.2.0")
set(CMAKE_CXX_COMPILER_ID GNU)
set(CMAKE_CXX_COMPILER_VERSION "15.2.0")

# ============================================================================
# Toolchain Paths
# ============================================================================

# Custom pic32-gcc toolchain location
if(WIN32)
    set(TOOLCHAIN_PATH "C:/pic32" CACHE PATH "Path to pic32 toolchain")
    set(TOOLCHAIN_EXT ".exe")
else()
    set(TOOLCHAIN_PATH "/opt/pic32" CACHE PATH "Path to pic32 toolchain")
    set(TOOLCHAIN_EXT "")
endif()

set(TOOLCHAIN_PREFIX "mipsisa32r2-elf-")

# Compilers - use explicit extension since CMAKE_EXECUTABLE_SUFFIX isn't set yet
set(CMAKE_C_COMPILER "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}gcc${TOOLCHAIN_EXT}")
set(CMAKE_CXX_COMPILER "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}g++${TOOLCHAIN_EXT}")
set(CMAKE_ASM_COMPILER "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}gcc${TOOLCHAIN_EXT}")

# Binary utilities
set(CMAKE_AR "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}ar${TOOLCHAIN_EXT}" CACHE FILEPATH "Archiver")
set(CMAKE_RANLIB "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}ranlib${TOOLCHAIN_EXT}" CACHE FILEPATH "Ranlib")
set(CMAKE_OBJCOPY "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}objcopy${TOOLCHAIN_EXT}" CACHE FILEPATH "Objcopy")
set(CMAKE_OBJDUMP "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}objdump${TOOLCHAIN_EXT}" CACHE FILEPATH "Objdump")
set(CMAKE_SIZE "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}size${TOOLCHAIN_EXT}" CACHE FILEPATH "Size")
set(CMAKE_NM "${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}nm${TOOLCHAIN_EXT}" CACHE FILEPATH "NM")

# ============================================================================
# DFP (Device Family Pack) Location
# ============================================================================

# Try to find DFP
if(EXISTS "${CMAKE_SOURCE_DIR}/pic32/dfp/PIC32MZ-DA")
    set(DFP_PATH "${CMAKE_SOURCE_DIR}/pic32/dfp/PIC32MZ-DA")
    message(STATUS "Using DFP: ${DFP_PATH}")
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/dfp/PIC32MZ-DA")
    set(DFP_PATH "${CMAKE_CURRENT_SOURCE_DIR}/dfp/PIC32MZ-DA")
    message(STATUS "Using DFP: ${DFP_PATH}")
else()
    #    message(WARNING "PIC32MZ-DA DFP not found in expected locations!")
    #    message(WARNING "Build may fail without device-specific headers and linker scripts.")
    #    message(WARNING "run the get-dfp.sh all script in the mipsisa32r2 directory to get the dfp's")
    set(DFP_PATH "")
endif()

# Set DFP include path for device-specific headers (xc.h, p32xxxx.h, etc.)
set(DFP_INCLUDE_PATH "")
if(DFP_PATH AND EXISTS "${DFP_PATH}/include")
    set(DFP_INCLUDE_PATH "${DFP_PATH}/include")
    message(STATUS "DFP include path: ${DFP_INCLUDE_PATH}")
endif()

# ============================================================================
# PIC32MZ-DA Specific Flags (No FPU - Soft Float)
# ============================================================================

# Architecture: microAptiv core, MIPS32r2, NO hardware FPU
set(PIC32_ARCH_FLAGS "-march=mips32r2 -EL -msoft-float ")

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

# Build include flags string
set(PIC32_INCLUDE_FLAGS "")
if(ATOM_INCLUDE_PATH)
    set(PIC32_INCLUDE_FLAGS "${PIC32_INCLUDE_FLAGS} -I${ATOM_INCLUDE_PATH}")
endif()
if(DFP_INCLUDE_PATH)
    set(PIC32_INCLUDE_FLAGS "${PIC32_INCLUDE_FLAGS} -I${DFP_INCLUDE_PATH}")
endif()
if(PIC32_PLATFORM_INCLUDE_PATH)
    set(PIC32_INCLUDE_FLAGS "${PIC32_INCLUDE_FLAGS} -I${PIC32_PLATFORM_INCLUDE_PATH}")
endif()

# ============================================================================
# Compiler Flags
# ============================================================================

# Skip compiler tests that would try to link Windows executables
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# C Flags - include atom and DFP paths
set(CMAKE_C_FLAGS_INIT "${PIC32_CPU_FLAGS} ${PIC32_INCLUDE_FLAGS} ${PIC32_WARN_FLAGS} -G0")
set(CMAKE_C_FLAGS_DEBUG_INIT "-Og -g3 -DDEBUG")
set(CMAKE_C_FLAGS_RELEASE_INIT "-O3 -DNDEBUG")
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "-Os -DNDEBUG")
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "-O3 -g -DNDEBUG")

# C++ Flags - include atom and DFP paths
set(CMAKE_CXX_FLAGS_INIT "${PIC32_CPU_FLAGS}${PIC32_INCLUDE_FLAGS} ${PIC32_WARN_FLAGS} -fno-exceptions -fno-rtti")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "-Og -g3 -DDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "-Os -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-O3 -g -DNDEBUG")

# ASM Flags
set(CMAKE_ASM_FLAGS_INIT "${PIC32_CPU_FLAGS} ${PIC32_INCLUDE_FLAGS}")

# ============================================================================
# Linker Flags
# ============================================================================

# Base linker flags
set(PIC32_LINKER_FLAGS "-nostartfiles -Wl,--gc-sections")
# -nostartfiles = We provide our own crt0.S
# --gc-sections = Remove unused code/data sections

# Float printf support (optional - adds ~10-15KB)
# Uncomment if you need printf("%f", ...) support with soft-float
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
# Build Identification - Export as CACHE variables for use in CMakeLists.txt
# ============================================================================

set(PIC32_BUILD TRUE CACHE BOOL "Building for PIC32" FORCE)
set(PIC32_FAMILY "DA" CACHE STRING "PIC32 processor family" FORCE)
set(PIC32_HAS_FPU FALSE CACHE BOOL "PIC32 has hardware FPU" FORCE)

# Export DFP_PATH so projects can use it for linker scripts, etc.
set(PIC32_DFP_PATH "${DFP_PATH}" CACHE PATH "Path to PIC32MZ-DA Device Family Pack" FORCE)
set(PIC32_DFP_INCLUDE_PATH "${DFP_INCLUDE_PATH}" CACHE PATH "Path to DFP include directory" FORCE)
set(PIC32_ATOM_INCLUDE_PATH "${ATOM_INCLUDE_PATH}" CACHE PATH "Path to atom platform headers" FORCE)
set(PIC32_TOOLCHAIN_PATH "${TOOLCHAIN_PATH}" CACHE PATH "Path to PIC32 toolchain" FORCE)

# ============================================================================
# Helper Functions
# ============================================================================

# Function to generate HEX file from ELF
function(_generate_hex TARGET)
    add_custom_command(TARGET ${TARGET} POST_BUILD
            COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${TARGET}> $<TARGET_FILE_DIR:${TARGET}>/${TARGET}.hex
            COMMENT "Generating HEX file: ${TARGET}.hex"
    )
endfunction()

# Function to generate BIN file from ELF
function(_generate_bin TARGET)
    add_custom_command(TARGET ${TARGET} POST_BUILD
            COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${TARGET}> $<TARGET_FILE_DIR:${TARGET}>/${TARGET}.bin
            COMMENT "Generating BIN file: ${TARGET}.bin"
    )
endfunction()

# Function to print size information
function(_print_size TARGET)
    add_custom_command(TARGET ${TARGET} POST_BUILD
            COMMAND ${CMAKE_SIZE} --format=berkeley $<TARGET_FILE:${TARGET}>
            COMMENT "Size of ${TARGET}:"
    )
endfunction()

# Convenience function to add all post-build steps
function(_firmware TARGET)
    _generate_hex(${TARGET})
    _generate_bin(${TARGET})
    _print_size(${TARGET})
endfunction()

# Function to add PIC32 platform include directories to a target
# Use this in your CMakeLists.txt: _add_platform_includes(your_target)
function(_add_platform_includes TARGET)
    if(PIC32_ATOM_INCLUDE_PATH)
        target_include_directories(${TARGET} PUBLIC ${PIC32_ATOM_INCLUDE_PATH})
    endif()
    if(PIC32_DFP_INCLUDE_PATH)
        target_include_directories(${TARGET} PUBLIC ${PIC32_DFP_INCLUDE_PATH})
    endif()
endfunction()
