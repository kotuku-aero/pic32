cmake_minimum_required(VERSION 3.20)

# ============================================================================
# PIC32 Support Library (libpic32)
# ============================================================================
# This builds the MIPS32r2 support libraries for PIC32 processors.
# Variants are controlled by the toolchain file:
#   - PIC32MZ-DA: Little-endian, soft-float
#   - PIC32MZ-EF: Little-endian, hard-float (FPU64)
#
# Produces:
#   - lib/libpic32.a         (Release build)
#   - lib/libpic32_debug.a   (Debug build)
# ============================================================================

project(pic32_support
    LANGUAGES C CXX ASM
    VERSION 1.0.0
    DESCRIPTION "PIC32 MIPS32r2 Support Library"
)

# Verify we're using a PIC32 toolchain
if(NOT PIC32_BUILD)
    message(FATAL_ERROR 
        "This CMakeLists.txt requires a PIC32 toolchain file.\n"
        "Use: cmake -DCMAKE_TOOLCHAIN_FILE=pic32-DA-toolchain.cmake\n"
        "  or cmake -DCMAKE_TOOLCHAIN_FILE=pic32-EF-toolchain.cmake"
    )
endif()

# ============================================================================
# Build Configuration
# ============================================================================

# Library-specific compiler flags
set(LIBPIC32_OPTIM_FLAGS 
    "-O3"
    "-fno-strict-aliasing"      # Library aliases extensively
    "-fno-optimize-sibling-calls"
)

set(LIBPIC32_DEBUG_FLAGS
    "-Og"                        # Debug-friendly optimization
    "-g3"                        # Maximum debug info
    "-fvar-tracking"            # Track variables through optimization
)


# ============================================================================
# Processor Variant Selection
# ============================================================================

# Available processor variants
if(PIC32_FAMILY STREQUAL "EF")
    set(DEFAULT_PROCESSOR "-D__32MZ2048EFH064__")
else()
    set(DEFAULT_PROCESSOR "-D__32MZ2064DAR176__")
endif()



set(LIBPIC32_PLATFORM_FLAGS
    "-ffreestanding"
    "-ffunction-sections"
    "-fdata-sections"
    "-mno-gpopt"                # Disable GP optimization
    "-mexplicit-relocs"         # Explicit relocations
        "-D_ABIO32"             # 32bit abi
)

set(LIBPIC32_DEFINES
    "-D_GNU_SOURCE"
    "-D__LIBBUILD__"
)

# ============================================================================
# Include Directories
# ============================================================================

# Public headers that will be installed
set(LIBPIC32_PUBLIC_INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}/../include
)

# Private headers for building the library
set(LIBPIC32_PRIVATE_INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

set(ARCH_SOURCES
        src/arch/_sync.c
        src/arch/_xchsrspss.S
        src/arch/_xxc0.S
        src/arch/divsi.c
#        src/arch/gmon.c
#        src/arch/gmon.h
        src/arch/mulsi.c
        src/arch/mulsidi.c
        src/arch/multab.c
        src/arch/setjmp.S
)

set(CPPCFL_SOURCES
    src/cppcfl/cp_dcword_common.c
    src/cppcfl/cp_flp_dc.c
)

set(CPPCFL_HEADERS
    src/cppcfl/cpflp-internal.h
)

set(DEBUGSUPPORT_SOURCES
        src/debugsupport/appio.c
        src/debugsupport/db_utils.c
)

set(DEFAULTVECTORS_SOURCES
        src/default_vector_dispatch/defaultinterrupt.c
        src/default_vector_dispatch/vector0.S
        src/default_vector_dispatch/vector1.S
        src/default_vector_dispatch/vector10.S
        src/default_vector_dispatch/vector100.S
        src/default_vector_dispatch/vector101.S
        src/default_vector_dispatch/vector102.S
        src/default_vector_dispatch/vector103.S
        src/default_vector_dispatch/vector104.S
        src/default_vector_dispatch/vector105.S
        src/default_vector_dispatch/vector106.S
        src/default_vector_dispatch/vector107.S
        src/default_vector_dispatch/vector108.S
        src/default_vector_dispatch/vector109.S
        src/default_vector_dispatch/vector11.S
        src/default_vector_dispatch/vector110.S
        src/default_vector_dispatch/vector111.S
        src/default_vector_dispatch/vector112.S
        src/default_vector_dispatch/vector113.S
        src/default_vector_dispatch/vector114.S
        src/default_vector_dispatch/vector115.S
        src/default_vector_dispatch/vector116.S
        src/default_vector_dispatch/vector117.S
        src/default_vector_dispatch/vector118.S
        src/default_vector_dispatch/vector119.S
        src/default_vector_dispatch/vector12.S
        src/default_vector_dispatch/vector120.S
        src/default_vector_dispatch/vector121.S
        src/default_vector_dispatch/vector122.S
        src/default_vector_dispatch/vector123.S
        src/default_vector_dispatch/vector124.S
        src/default_vector_dispatch/vector125.S
        src/default_vector_dispatch/vector126.S
        src/default_vector_dispatch/vector127.S
        src/default_vector_dispatch/vector128.S
        src/default_vector_dispatch/vector129.S
        src/default_vector_dispatch/vector13.S
        src/default_vector_dispatch/vector130.S
        src/default_vector_dispatch/vector131.S
        src/default_vector_dispatch/vector132.S
        src/default_vector_dispatch/vector133.S
        src/default_vector_dispatch/vector134.S
        src/default_vector_dispatch/vector135.S
        src/default_vector_dispatch/vector136.S
        src/default_vector_dispatch/vector137.S
        src/default_vector_dispatch/vector138.S
        src/default_vector_dispatch/vector139.S
        src/default_vector_dispatch/vector14.S
        src/default_vector_dispatch/vector140.S
        src/default_vector_dispatch/vector141.S
        src/default_vector_dispatch/vector142.S
        src/default_vector_dispatch/vector143.S
        src/default_vector_dispatch/vector144.S
        src/default_vector_dispatch/vector145.S
        src/default_vector_dispatch/vector146.S
        src/default_vector_dispatch/vector147.S
        src/default_vector_dispatch/vector148.S
        src/default_vector_dispatch/vector149.S
        src/default_vector_dispatch/vector15.S
        src/default_vector_dispatch/vector150.S
        src/default_vector_dispatch/vector151.S
        src/default_vector_dispatch/vector152.S
        src/default_vector_dispatch/vector153.S
        src/default_vector_dispatch/vector154.S
        src/default_vector_dispatch/vector155.S
        src/default_vector_dispatch/vector156.S
        src/default_vector_dispatch/vector157.S
        src/default_vector_dispatch/vector158.S
        src/default_vector_dispatch/vector159.S
        src/default_vector_dispatch/vector16.S
        src/default_vector_dispatch/vector160.S
        src/default_vector_dispatch/vector161.S
        src/default_vector_dispatch/vector162.S
        src/default_vector_dispatch/vector163.S
        src/default_vector_dispatch/vector164.S
        src/default_vector_dispatch/vector165.S
        src/default_vector_dispatch/vector166.S
        src/default_vector_dispatch/vector167.S
        src/default_vector_dispatch/vector168.S
        src/default_vector_dispatch/vector169.S
        src/default_vector_dispatch/vector17.S
        src/default_vector_dispatch/vector170.S
        src/default_vector_dispatch/vector171.S
        src/default_vector_dispatch/vector172.S
        src/default_vector_dispatch/vector173.S
        src/default_vector_dispatch/vector174.S
        src/default_vector_dispatch/vector175.S
        src/default_vector_dispatch/vector176.S
        src/default_vector_dispatch/vector177.S
        src/default_vector_dispatch/vector178.S
        src/default_vector_dispatch/vector179.S
        src/default_vector_dispatch/vector18.S
        src/default_vector_dispatch/vector180.S
        src/default_vector_dispatch/vector181.S
        src/default_vector_dispatch/vector182.S
        src/default_vector_dispatch/vector183.S
        src/default_vector_dispatch/vector184.S
        src/default_vector_dispatch/vector185.S
        src/default_vector_dispatch/vector186.S
        src/default_vector_dispatch/vector187.S
        src/default_vector_dispatch/vector188.S
        src/default_vector_dispatch/vector189.S
        src/default_vector_dispatch/vector19.S
        src/default_vector_dispatch/vector190.S
        src/default_vector_dispatch/vector191.S
        src/default_vector_dispatch/vector192.S
        src/default_vector_dispatch/vector193.S
        src/default_vector_dispatch/vector194.S
        src/default_vector_dispatch/vector195.S
        src/default_vector_dispatch/vector196.S
        src/default_vector_dispatch/vector197.S
        src/default_vector_dispatch/vector198.S
        src/default_vector_dispatch/vector199.S
        src/default_vector_dispatch/vector2.S
        src/default_vector_dispatch/vector20.S
        src/default_vector_dispatch/vector200.S
        src/default_vector_dispatch/vector201.S
        src/default_vector_dispatch/vector202.S
        src/default_vector_dispatch/vector203.S
        src/default_vector_dispatch/vector204.S
        src/default_vector_dispatch/vector205.S
        src/default_vector_dispatch/vector206.S
        src/default_vector_dispatch/vector207.S
        src/default_vector_dispatch/vector208.S
        src/default_vector_dispatch/vector209.S
        src/default_vector_dispatch/vector21.S
        src/default_vector_dispatch/vector210.S
        src/default_vector_dispatch/vector211.S
        src/default_vector_dispatch/vector212.S
        src/default_vector_dispatch/vector213.S
        src/default_vector_dispatch/vector214.S
        src/default_vector_dispatch/vector215.S
        src/default_vector_dispatch/vector216.S
        src/default_vector_dispatch/vector217.S
        src/default_vector_dispatch/vector218.S
        src/default_vector_dispatch/vector219.S
        src/default_vector_dispatch/vector22.S
        src/default_vector_dispatch/vector220.S
        src/default_vector_dispatch/vector221.S
        src/default_vector_dispatch/vector222.S
        src/default_vector_dispatch/vector223.S
        src/default_vector_dispatch/vector224.S
        src/default_vector_dispatch/vector225.S
        src/default_vector_dispatch/vector226.S
        src/default_vector_dispatch/vector227.S
        src/default_vector_dispatch/vector228.S
        src/default_vector_dispatch/vector229.S
        src/default_vector_dispatch/vector23.S
        src/default_vector_dispatch/vector230.S
        src/default_vector_dispatch/vector231.S
        src/default_vector_dispatch/vector232.S
        src/default_vector_dispatch/vector233.S
        src/default_vector_dispatch/vector234.S
        src/default_vector_dispatch/vector235.S
        src/default_vector_dispatch/vector236.S
        src/default_vector_dispatch/vector237.S
        src/default_vector_dispatch/vector238.S
        src/default_vector_dispatch/vector239.S
        src/default_vector_dispatch/vector24.S
        src/default_vector_dispatch/vector240.S
        src/default_vector_dispatch/vector241.S
        src/default_vector_dispatch/vector242.S
        src/default_vector_dispatch/vector243.S
        src/default_vector_dispatch/vector244.S
        src/default_vector_dispatch/vector245.S
        src/default_vector_dispatch/vector246.S
        src/default_vector_dispatch/vector247.S
        src/default_vector_dispatch/vector248.S
        src/default_vector_dispatch/vector249.S
        src/default_vector_dispatch/vector25.S
        src/default_vector_dispatch/vector250.S
        src/default_vector_dispatch/vector251.S
        src/default_vector_dispatch/vector252.S
        src/default_vector_dispatch/vector253.S
        src/default_vector_dispatch/vector254.S
        src/default_vector_dispatch/vector255.S
        src/default_vector_dispatch/vector26.S
        src/default_vector_dispatch/vector27.S
        src/default_vector_dispatch/vector28.S
        src/default_vector_dispatch/vector29.S
        src/default_vector_dispatch/vector3.S
        src/default_vector_dispatch/vector30.S
        src/default_vector_dispatch/vector31.S
        src/default_vector_dispatch/vector32.S
        src/default_vector_dispatch/vector33.S
        src/default_vector_dispatch/vector34.S
        src/default_vector_dispatch/vector35.S
        src/default_vector_dispatch/vector36.S
        src/default_vector_dispatch/vector37.S
        src/default_vector_dispatch/vector38.S
        src/default_vector_dispatch/vector39.S
        src/default_vector_dispatch/vector4.S
        src/default_vector_dispatch/vector40.S
        src/default_vector_dispatch/vector41.S
        src/default_vector_dispatch/vector42.S
        src/default_vector_dispatch/vector43.S
        src/default_vector_dispatch/vector44.S
        src/default_vector_dispatch/vector45.S
        src/default_vector_dispatch/vector46.S
        src/default_vector_dispatch/vector47.S
        src/default_vector_dispatch/vector48.S
        src/default_vector_dispatch/vector49.S
        src/default_vector_dispatch/vector5.S
        src/default_vector_dispatch/vector50.S
        src/default_vector_dispatch/vector51.S
        src/default_vector_dispatch/vector52.S
        src/default_vector_dispatch/vector53.S
        src/default_vector_dispatch/vector54.S
        src/default_vector_dispatch/vector55.S
        src/default_vector_dispatch/vector56.S
        src/default_vector_dispatch/vector57.S
        src/default_vector_dispatch/vector58.S
        src/default_vector_dispatch/vector59.S
        src/default_vector_dispatch/vector6.S
        src/default_vector_dispatch/vector60.S
        src/default_vector_dispatch/vector61.S
        src/default_vector_dispatch/vector62.S
        src/default_vector_dispatch/vector63.S
        src/default_vector_dispatch/vector64.S
        src/default_vector_dispatch/vector65.S
        src/default_vector_dispatch/vector66.S
        src/default_vector_dispatch/vector67.S
        src/default_vector_dispatch/vector68.S
        src/default_vector_dispatch/vector69.S
        src/default_vector_dispatch/vector7.S
        src/default_vector_dispatch/vector70.S
        src/default_vector_dispatch/vector71.S
        src/default_vector_dispatch/vector72.S
        src/default_vector_dispatch/vector73.S
        src/default_vector_dispatch/vector74.S
        src/default_vector_dispatch/vector75.S
        src/default_vector_dispatch/vector76.S
        src/default_vector_dispatch/vector77.S
        src/default_vector_dispatch/vector78.S
        src/default_vector_dispatch/vector79.S
        src/default_vector_dispatch/vector8.S
        src/default_vector_dispatch/vector80.S
        src/default_vector_dispatch/vector81.S
        src/default_vector_dispatch/vector82.S
        src/default_vector_dispatch/vector83.S
        src/default_vector_dispatch/vector84.S
        src/default_vector_dispatch/vector85.S
        src/default_vector_dispatch/vector86.S
        src/default_vector_dispatch/vector87.S
        src/default_vector_dispatch/vector88.S
        src/default_vector_dispatch/vector89.S
        src/default_vector_dispatch/vector9.S
        src/default_vector_dispatch/vector90.S
        src/default_vector_dispatch/vector91.S
        src/default_vector_dispatch/vector92.S
        src/default_vector_dispatch/vector93.S
        src/default_vector_dispatch/vector94.S
        src/default_vector_dispatch/vector95.S
        src/default_vector_dispatch/vector96.S
        src/default_vector_dispatch/vector97.S
        src/default_vector_dispatch/vector98.S
        src/default_vector_dispatch/vector99.S


)

set(DSP_SOURCES
        src/dsp/src/fft16.S
        src/dsp/src/fft16_setup.c
        src/dsp/src/fft16c16.c
        src/dsp/src/fft16c32.c
        src/dsp/src/fft16c64.c
        src/dsp/src/fft16c128.c
        src/dsp/src/fft16c256.c
        src/dsp/src/fft16c512.c
        src/dsp/src/fft16c1024.c
        src/dsp/src/fft16c2048.c
        src/dsp/src/fft16c4096.c
        src/dsp/src/fft32.S
        src/dsp/src/fft32_setup.c
        src/dsp/src/fft32c16.c
        src/dsp/src/fft32c32.c
        src/dsp/src/fft32c64.c
        src/dsp/src/fft32c128.c
        src/dsp/src/fft32c256.c
        src/dsp/src/fft32c512.c
        src/dsp/src/fft32c1024.c
        src/dsp/src/fft32c2048.c
        src/dsp/src/fft32c4096.c
        src/dsp/src/fft_setup.S
        src/dsp/src/fir16.S
        src/dsp/src/fir16_setup.c
        src/dsp/src/h264_iqt.S
        src/dsp/src/h264_iqt_setup.c
        src/dsp/src/h264_mc_luma.S
        src/dsp/src/iir16.S
        src/dsp/src/iir16_setup.c
        src/dsp/src/lms16.S
        src/dsp/src/vec_abs16.S
        src/dsp/src/vec_abs32.S
        src/dsp/src/vec_add16.S
        src/dsp/src/vec_add32.S
        src/dsp/src/vec_addc16.S
        src/dsp/src/vec_addc32.S
        src/dsp/src/vec_dotp16.S
        src/dsp/src/vec_dotp32.S
        src/dsp/src/vec_mul16.S
        src/dsp/src/vec_mul32.S
        src/dsp/src/vec_mulc16.S
        src/dsp/src/vec_mulc32.S
        src/dsp/src/vec_sub16.S
        src/dsp/src/vec_sub32.S
        src/dsp/src/vec_sum_squares16.S
        src/dsp/src/vec_sum_squares32.S
#        src/dsp/src/x4.c
        src/dsp/wrapper/mchp_fft16.c
        src/dsp/wrapper/mchp_fft32.c
        src/dsp/wrapper/mchp_fir.c
        src/dsp/wrapper/mchp_inittwid16.c
        src/dsp/wrapper/mchp_inittwid32.c
        src/dsp/wrapper/mchp_vadd16.c
        src/dsp/wrapper/mchp_vadd32.c
        src/dsp/wrapper/mchp_vdot16.c
        src/dsp/wrapper/mchp_vdot32.c
        src/dsp/wrapper/mchp_vmul16.c
        src/dsp/wrapper/mchp_vmul32.c
        src/dsp/wrapper/mchp_vpow16.c
        src/dsp/wrapper/mchp_vpow32.c
        src/dsp/wrapper/mchp_vscl16.c
        src/dsp/wrapper/mchp_vscl32.c
        src/dsp/wrapper/mchp_vsub16.c
        src/dsp/wrapper/mchp_vsub32.c
)

set(DSP_HEADERS
        src/dsp/include/dsplib_util.h
        src/dsp/include/fftc.h
        src/dsp/include/mips_pc.h
        src/dsp/include/mips_unaligned.h
)

set(DSPR_SOURCES
        src/dspr2/fft16.S
        src/dspr2/fft16_setup.c
        src/dspr2/fft32.S
        src/dspr2/fft32_setup.c
        src/dspr2/fir16-be.S
        src/dspr2/fir16-le.S
        src/dspr2/fir16_setup.c
        src/dspr2/h264_iqt-be.S
        src/dspr2/h264_iqt-le.S
        src/dspr2/h264_iqt_setup.c
        src/dspr2/h264_mc_luma.c
        src/dspr2/iir16.S
        src/dspr2/iir16_setup.c
        src/dspr2/lms16.S
        src/dspr2/vec_abs16.S
        src/dspr2/vec_abs32.S
        src/dspr2/vec_add16.S
        src/dspr2/vec_add32.S
        src/dspr2/vec_addc16.S
        src/dspr2/vec_addc32.S
        src/dspr2/vec_dotp16.S
        src/dspr2/vec_dotp32.S
        src/dspr2/vec_mul16.S
        src/dspr2/vec_mul32.S
        src/dspr2/vec_mulc16.S
        src/dspr2/vec_mulc32.S
        src/dspr2/vec_sub16.S
        src/dspr2/vec_sub32.S
        src/dspr2/vec_sum_squares16.S
        src/dspr2/vec_sum_squares32.S
)

set(STARTUP_SOURCES
        src/startup/cache-err-exception.S
        src/startup/crt0.S
        src/startup/crt0_pic.S
        src/startup/crti.S
        src/startup/crtn.S
        src/startup/debug-exception-return.S
        src/startup/defs.inc
        src/startup/general-exception.S
        src/startup/simple-tlb-refill-exception.S
        src/startup/software-debug-break.c
)

set(STUBS_SOURCES
        src/stubs/default-bootstrap-exception-handler.c
        src/stubs/default-cache-err-exception-handler.c
        src/stubs/default-general-exception-handler.c
        src/stubs/default-nmi-handler.S
        src/stubs/default-on-bootstrap.c
        src/stubs/default-on-reset.c
        src/stubs/default-simple-tlb-refill-exception-handler.c
        src/stubs/pic32_data_init_clear.S
        src/stubs/pic32_data_init_copy.S
        src/stubs/pic32_data_init_copy_emb.S
        src/stubs/pic32_data_init_copy_val.S
        src/stubs/pic32_data_init_core.S
        src/stubs/pic32_data_init_decompress.S
        src/stubs/pic32_data_init_wrapper.S
        src/stubs/pic32_init_cache.S
        src/stubs/pic32_init_tlb_ebi_sqi.S
        src/stubs/pic32_software_reset.S
)

# Combine all sources
set(LIBPIC32_SOURCES
        ${ARCH_SOURCES}
        ${CPPCFL_SOURCES}
        ${DEBUGSUPPORT_SOURCES}
        ${DEFAULTVECTORS_SOURCES}
        ${DSP_SOURCES}
        ${DSPR2_SOURCES}
        ${STARTUP_SOURCES}
        ${STUBS_SOURCES}
)

# ============================================================================
# Library Target - Release Build
# ============================================================================

add_library(pic32_release STATIC ${LIBPIC32_SOURCES})

# Set output name
set_target_properties(pic32_release PROPERTIES
    OUTPUT_NAME "pic32"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib"
)

# Include directories
target_include_directories(pic32_release
    PUBLIC
        ${LIBPIC32_PUBLIC_INCLUDES}
        ${PIC32_DFP_PATH}/include}
    PRIVATE
        ${LIBPIC32_PRIVATE_INCLUDES}
)

# Compile options
target_compile_options(pic32_release PRIVATE
    ${LIBPIC32_OPTIM_FLAGS}
    ${LIBPIC32_PLATFORM_FLAGS}
        ${DEFAULT_PROCESSOR}
)

# Compile definitions
target_compile_definitions(pic32_release PRIVATE
    ${LIBPIC32_DEFINES}
    NDEBUG=1
)

# Architecture-specific flags are already set by toolchain file via CMAKE_C_FLAGS_INIT

# Strip debug symbols from objects before archiving (matches original behavior)
add_custom_command(TARGET pic32_release POST_BUILD
    COMMAND ${CMAKE_STRIP} -X $<TARGET_OBJECTS:pic32_release>
    COMMENT "Stripping debug symbols from release objects"
    VERBATIM
)

# ============================================================================
# Library Target - Debug Build
# ============================================================================

add_library(pic32_debug STATIC ${LIBPIC32_SOURCES})

# Set output name
set_target_properties(pic32_debug PROPERTIES
    OUTPUT_NAME "pic32_debug"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib"
)

# Include directories
target_include_directories(pic32_debug
    PUBLIC
        ${LIBPIC32_PUBLIC_INCLUDES}
        ${PIC32_DFP_PATH}/include}
    PRIVATE
        ${LIBPIC32_PRIVATE_INCLUDES}
)

# Compile options - use debug flags instead of optimization
target_compile_options(pic32_debug PRIVATE
    ${LIBPIC32_DEBUG_FLAGS}
    ${LIBPIC32_PLATFORM_FLAGS}
        ${DEFAULT_PROCESSOR}
)

# Compile definitions
target_compile_definitions(pic32_debug PRIVATE
    ${LIBPIC32_DEFINES}
    DEBUG=1
    __DEBUG=1
)

# ============================================================================
# Configuration Summary
# ============================================================================

message(STATUS "")
message(STATUS "========================================")
message(STATUS "PIC32 Support Library (libpic32)")
message(STATUS "========================================")
message(STATUS "  Processor Family: ${PIC32_FAMILY}")
message(STATUS "  Hardware FPU:     ${PIC32_HAS_FPU}")
message(STATUS "  Toolchain:        ${CMAKE_C_COMPILER}")

if(PIC32_FAMILY STREQUAL "DA")
    message(STATUS "  Configuration:    Little-endian, soft-float")
    message(STATUS "  Library path:     lib/el/sof/")
elseif(PIC32_FAMILY STREQUAL "EF")
    message(STATUS "  Configuration:    Little-endian, hard-float (FPU64)")
    message(STATUS "  Library path:     lib/el/mfp64/")
endif()

message(STATUS "")
message(STATUS "  Build Outputs:")
message(STATUS "    Release: lib/libpic32.a")
message(STATUS "    Debug:   lib/libpic32_debug.a")
message(STATUS "")
message(STATUS "  Source modules:")
message(STATUS "    - cppcfl (${CMAKE_CURRENT_LIST_DIR}/src/cppcfl/profiling)")
message(STATUS "")
message(STATUS "========================================")
message(STATUS "")

# ============================================================================
# Helper Targets
# ============================================================================

# Build only release
add_custom_target(release
    DEPENDS pic32_release
    COMMENT "Building release version only"
)

# Build only debug
add_custom_target(debug
    DEPENDS pic32_debug
    COMMENT "Building debug version only"
)

# Show configuration without building
add_custom_target(show-config
    COMMAND ${CMAKE_COMMAND} -E echo "PIC32 Family: ${PIC32_FAMILY}"
    COMMAND ${CMAKE_COMMAND} -E echo "Has FPU: ${PIC32_HAS_FPU}"
    COMMAND ${CMAKE_COMMAND} -E echo "DFP Path: ${PIC32_DFP_PATH}"
    COMMAND ${CMAKE_COMMAND} -E echo "Toolchain: ${PIC32_TOOLCHAIN_PATH}"
    COMMENT "Displaying build configuration"
)

# ============================================================================
# Link Script Support (Optional)
# ============================================================================
# If you need to export libraries with specific link directories for your
# applications to use, you can create an interface library:

add_library(pic32_interface INTERFACE)

target_include_directories(pic32_interface INTERFACE
    $<BUILD_INTERFACE:${LIBPIC32_PUBLIC_INCLUDES}>
    $<INSTALL_INTERFACE:include>
)

# Link the appropriate library variant based on CMAKE_BUILD_TYPE
target_link_libraries(pic32_interface INTERFACE
    $<$<CONFIG:Debug>:pic32_debug>
    $<$<CONFIG:Release>:pic32_release>
    $<$<CONFIG:RelWithDebInfo>:pic32_release>
    $<$<CONFIG:MinSizeRel>:pic32_release>
)

# Export so other parts of the build can use target_link_libraries(myapp pic32_interface)
install(TARGETS pic32_interface
    EXPORT pic32_targets
    COMPONENT libraries
)

install(EXPORT pic32_targets
    FILE pic32-targets.cmake
    NAMESPACE pic32::
    DESTINATION lib/cmake/pic32
    COMPONENT libraries
)

################################################################################
# Organize in IDE
################################################################################
set_target_properties(pic32_interface PROPERTIES FOLDER "libs")
