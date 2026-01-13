# PIC32 Toolchain

## Quick Install

1. Download the latest release from [Releases](../../releases)
2. Extract to `C:\pic32` (Windows) or `/opt/pic32` (MSYS2)
3. Add `C:\pic32\bin` to your PATH
4. run the get-dfp script in /c/opt/pic32

## Components

| Component | Version |
|-----------|---------|
| GCC | 15.2.0  |
| Binutils | 2.44    |
| Newlib | 4.5.0   |
| GDB | 15.2    |

## CMake Integration

Use the provided toolchain files:
```cmake
cmake -DCMAKE_TOOLCHAIN_FILE=cmake/pic32-EF-toolchain.cmake ..
## Building from Source

See [mips32](https://github.com/kotuku-aero/mips32) repository.
```
## get-dfp

The get-dfp script is currently set up for 2 device types.  The PIC32MZ-EF
and PIC32MZ-DA processors.  All variants are supported in these device packs
from Microchip.  The script will remove all microchip specific attributes from
the files so they will compile with standard GCC.

The script is intended to run on MSYS2 on windows.  Please install MSYS2
before running the script.  It may run on WSL but has not been tested as
MSYS2 is used for the mips-elf build chain as well.
