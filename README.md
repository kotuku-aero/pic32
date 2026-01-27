# PIC32 Toolchain

The purpose of this repository is to provide a toolchain for compiling
C/C++ code for the PIC32 microcontroller family not using the Microchip
provided tools (xc32).

This has many benefits including:

- Uses the standard GCC toolchain.
- Supports the PIC32MZ-EF and PIC32MZ-DA processors (other processor families can be added if needed).
- Supports the MIPS32R2 architecture.
- Standard GDB debugger so other tools such as Segger JLink can be used.
- Projects can be built to use CMake to provide cross-platform support.  The [diy-efis](https://github.com/kotuku-aero/diy-efis.git) project has been ported to use this toolchain.
- Supports the MSYS2 environment on Windows for building.
- GCC Compiler is not limited to -O2 optimizations, any GCC optimization level can be used.
- Supports the DFP library.
- Completely open source with build scripts in the [mips32](https://github.com/kotuku-aero/mips32) repository.
- Third party IDEs can be used to debug the code.  The primary IDE used for development is [CLion](https://www.jetbrains.com/clion/), which is free for open source projects. 

## Quick Install

1. Clone this repository to `C:\pic32` (Windows) or `/opt/pic32` (Linux/MSYS2)
2. Download the latest gcc mips-elf release from [Releases](../../releases)
3. Extract to `C:\pic32` (Windows) or `/opt/pic32` (Linux/MSYS2). Note this will expand to the same directory that is included in this repository, so the built libraries exist in the same directory as the toolchain.
4. Add `C:\pic32\bin` (Windows) or `/opt/pic32/bin` (Linux/MSYS2) to your PATH.
5. Run the get-dfp script in `C:\pic32` (or `/c/pic32` in MSYS2) to populate the DFP library. This will remove all Microchip-specific attributes from the files so they will compile with standard GCC. It downloads the DFP library from Microchip's website.

## Components

| Component | Version |
|-----------|---------|
| GCC | 15.2.0  |
| Binutils | 2.44    |
| Newlib | 4.5.0   |
| GDB | 15.2    |

## Toolchain Structure

The toolchain uses a consolidated structure with newlib as the base C library and Microchip-specific libraries integrated:

- **`mips-elf/`** - Main toolchain directory
  - `bin/` - Compiler, linker, and binary utilities
  - `lib/` - Standard libraries (newlib) + PIC32 libraries (libpic32.a, libdsp.a, etc.)
  - `include/` - Standard C headers (newlib) and PIC32-specific headers in `pic32/` subdirectory

This structure allows easy GCC updates by rebuilding newlib and copying the PIC32 libraries back.

## CMake Integration

Use the provided toolchain files:
```cmake
# For PIC32MZ-EF (with FPU)
cmake -DCMAKE_TOOLCHAIN_FILE=cmake/pic32-EF-toolchain.cmake ..

# For PIC32MZ-DA (no FPU, soft-float)
cmake -DCMAKE_TOOLCHAIN_FILE=cmake/pic32-DA-toolchain.cmake ..
```

### Required Linker Symbol Definitions

The PIC32 startup code (crt0.S) requires specific linker symbols that are not provided by the Microchip DFP linker scripts. These must be defined via linker command-line options in your CMake project:

```cmake
target_link_options(your_target PRIVATE
    -T${PIC32_LINKER_SCRIPT}
    # Required symbols for crt0_EF.S data initialization
    -Wl,--defsym=__data_start=0x80000000
    -Wl,--defsym=__data_init=0x80000000
    -Wl,--defsym=__data_end=0x80000000
    # Required symbols for crt0_EF.S RAM function support
    -Wl,--defsym=__ramfunc_begin=0
    -Wl,--defsym=__ramfunc_end=0
    -Wl,--defsym=__ramfunc_load=0
    -Wl,--defsym=__ramfunc_length=0
    -Wl,--gc-sections
    -Wl,-Map=${CMAKE_BINARY_DIR}/your_target.map
)
```

**Why these are needed:**
- The crt0.S startup code expects double-underscore symbols (`__data_start`, etc.) but Microchip DFP linker scripts only provide single-underscore versions (`_data_start`, etc.)
- The current configuration sets all data symbols to `0x80000000` (start of KSEG0 RAM), making the data copy loop execute zero times since start == end
- This is appropriate because the DFP linker scripts don't use `AT>` clauses to copy data from flash to RAM
- RAM function symbols are all set to 0 since RAM functions are not currently used

**Alternative approach:**
For cleaner project files, consider adding these to your toolchain file as a common linker options variable:
```cmake
# In cmake/pic32-DA-toolchain.cmake
set(PIC32_COMMON_LINK_OPTIONS
    -Wl,--gc-sections
    -Wl,--defsym=__data_start=0x80000000
    -Wl,--defsym=__data_init=0x80000000
    -Wl,--defsym=__data_end=0x80000000
    -Wl,--defsym=__ramfunc_begin=0
    -Wl,--defsym=__ramfunc_end=0
    -Wl,--defsym=__ramfunc_load=0
    -Wl,--defsym=__ramfunc_length=0
    CACHE STRING "Common PIC32 linker options"
)
```

Then in your application:
```cmake
target_link_options(your_target PRIVATE
    ${PIC32_COMMON_LINK_OPTIONS}
    -T${PIC32_LINKER_SCRIPT}
    -Wl,--defsym=_stack=0xA00A0000  # Application-specific
    -Wl,-Map=${CMAKE_BINARY_DIR}/your_target.map
)
```

### Newlib System Call Stubs

Newlib (the standard C library) requires POSIX-like system call implementations. Since PIC32 is a bare-metal environment with no operating system, you must provide stub implementations for these functions:

**Required stubs:**
- `sbrk()` - Memory allocation (heap expansion)
- `_exit()` - Program termination
- `close()`, `fstat()`, `isatty()`, `lseek()`, `read()`, `write()` - File I/O
- `kill()`, `getpid()` - Process management

**Reference Implementation:**
A minimal reference implementation is provided in `src/newlib_stubs.c`. This file contains:
- Detailed comments explaining each function
- Simple implementations suitable for basic embedded applications
- Suggestions for customization (e.g., connecting `write()` to UART for printf support)
- Alternative implementation examples in comments

**Using the reference implementation:**

1. Add to your project's library:
```cmake
# In your CMakeLists.txt
add_library(your_stubs_lib STATIC
    ${CMAKE_SOURCE_DIR}/libs/pic32/src/newlib_stubs.c
)
```

2. Link after standard libraries:
```cmake
target_link_libraries(your_target PRIVATE
    # ... your application libraries ...
    c           # newlib libc
    m           # libm (math)
    gcc         # libgcc (compiler support)
    your_stubs_lib  # MUST come after c/m/gcc
)
```

**Critical linking order:**
The newlib stubs library **must** be linked after `c`, `m`, and `gcc` to properly resolve the undefined references that newlib creates. If you have your own libraries that need these stubs, link them twice - once at the beginning and once at the end:

```cmake
target_link_libraries(your_target PRIVATE
    your_app_libs   # Your libraries (first occurrence)
    c m gcc         # Standard libraries
    your_app_libs   # Your libraries again (to provide stubs)
)
```

**Customization:**
The reference implementation is intentionally minimal. You'll likely want to customize:
- `write()` - Connect to UART for printf/debug output
- `read()` - Connect to UART for scanf/input
- `sbrk()` - Implement proper heap management if you use malloc
- `_exit()` - Jump to bootloader or trigger specific shutdown behavior

## Building from Source

See the [mips32](https://github.com/kotuku-aero/mips32) repository for toolchain build instructions.

To rebuild the PIC32-specific libraries (pic32m-libs):
```bash
cd pic32-libs/pic32m-libs
./build-libs.sh
```
## get-dfp

The get-dfp script is currently set up for 2 device types: PIC32MZ-EF
and PIC32MZ-DA processors. All variants are supported in these device packs
from Microchip. The script will remove all Microchip-specific attributes from
the files so they will compile with standard GCC.

The script is intended to run on MSYS2 on Windows. Please install MSYS2
before running the script. It may run on WSL but has not been tested, as
MSYS2 is used for the mips-elf build chain as well.
