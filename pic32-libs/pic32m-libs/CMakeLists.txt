cmake_minimum_required(VERSION 3.15)
project(pic32m-libs NONE)

# Set the toolchain prefix
set(TOOLCHAIN_PREFIX "mips-elf" CACHE STRING "Toolchain prefix")

# Determine install locations
if(NOT CMAKE_INSTALL_PREFIX)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/../../atom/" CACHE PATH "Install prefix" FORCE)
endif()

set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/${TOOLCHAIN_PREFIX}/lib" CACHE PATH "Library install directory")
set(INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/${TOOLCHAIN_PREFIX}/include" CACHE PATH "Include install directory")

# List of library subdirectories to build
set(LIB_SUBDIRS
    cppcfl
    semihosting
    debugsupport
    dsp
    dspr2
    libpic32
)

# Custom target to build all libraries using existing Makefiles
add_custom_target(build_pic32m_libs ALL
    COMMAND ${CMAKE_COMMAND} -E echo "Building pic32m-libs..."
    COMMAND ${CMAKE_MAKE_PROGRAM} -C ${CMAKE_CURRENT_SOURCE_DIR} all
    COMMENT "Building PIC32M libraries using existing Makefiles"
    VERBATIM
)

# Install headers from include/ directory
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
    DESTINATION ${INSTALL_INCLUDE_DIR}/pic32m-libs
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN ".svn" EXCLUDE
)

# Install machine headers (create machine -> mips symlink)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/mips/
    DESTINATION ${INSTALL_INCLUDE_DIR}/pic32m-libs/machine
    FILES_MATCHING PATTERN "*.h"
)

# Install proc headers
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/proc/
    DESTINATION ${INSTALL_INCLUDE_DIR}/pic32m-libs/proc
    FILES_MATCHING PATTERN "*.h"
)

# Install sys headers
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/sys/
    DESTINATION ${INSTALL_INCLUDE_DIR}/pic32m-libs/sys
    FILES_MATCHING PATTERN "*.h"
)

# Install libraries (all .a files from subdirectories)
# Note: These will be built by the Makefile wrapper
foreach(subdir ${LIB_SUBDIRS})
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${subdir})
        file(GLOB_RECURSE lib_files "${CMAKE_CURRENT_SOURCE_DIR}/${subdir}/*.a")
        if(lib_files)
            install(FILES ${lib_files}
                DESTINATION ${INSTALL_LIB_DIR}
            )
        endif()
    endif()
endforeach()

# Install all .a files from the build directory after make completes
install(CODE "
    file(GLOB_RECURSE built_libs \"${CMAKE_CURRENT_SOURCE_DIR}/*/*.a\")
    foreach(lib \${built_libs})
        file(INSTALL DESTINATION \"${INSTALL_LIB_DIR}\"
             TYPE FILE FILES \"\${lib}\")
    endforeach()
    message(STATUS \"Installed PIC32M libraries to ${INSTALL_LIB_DIR}\")
")

# Clean target
add_custom_target(clean_pic32m_libs
    COMMAND ${CMAKE_MAKE_PROGRAM} -C ${CMAKE_CURRENT_SOURCE_DIR} clean
    COMMENT "Cleaning PIC32M libraries"
)

# Print configuration summary
message(STATUS "PIC32M Libraries Configuration:")
message(STATUS "  Install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  Library dir: ${INSTALL_LIB_DIR}")
message(STATUS "  Include dir: ${INSTALL_INCLUDE_DIR}")
message(STATUS "  Building libraries: ${LIB_SUBDIRS}")
