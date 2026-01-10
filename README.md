# PIC32 Toolchain

## Quick Install

1. Download the latest release from [Releases](../../releases)
2. Extract to `C:\pic32` (Windows) or `/opt/pic32` (Linux)
3. Add `C:\pic32\bin` to your PATH

## Components

| Component | Version |
|-----------|---------|
| GCC | 15.2.0 |
| Binutils | 2.44 |
| Newlib | 4.5.0 |
| GDB | 16.2 |

## CMake Integration

Use the provided toolchain files:
```cmake
cmake -DCMAKE_TOOLCHAIN_FILE=cmake/pic32-EF-toolchain.cmake ..
## Building from Source

See [mips32](https://gitea.kotuku.aero/kotuku/mips32) repository.

