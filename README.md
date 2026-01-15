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
