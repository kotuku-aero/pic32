# PIC32 Libraries for GCC MIPS Toolchain

This directory contains the PIC32 runtime libraries ported to work with the standard GCC MIPS (`mips-elf-gcc`) toolchain.

## Overview

These libraries provide essential runtime support for PIC32 microcontrollers, including:

- **libpic32**: Core runtime library with startup code, exception handlers, and system initialization
- **cppcfl**: C++ function library support
- **debugsupport**: Debugging support functions
- **dsp**: DSP library for signal processing
- **dspr2**: DSPR2 optimized DSP functions
- **ieee**: IEEE 754 floating-point support
- **math**: Math library functions
- **proc**: Processor-specific definitions and headers
- **semihosting**: Semihosting support for debug environments
- **sol**: System-on-chip libraries

## Prerequisites

You must have the `mips-elf-gcc` toolchain installed and available in your PATH:

```bash
mips-elf-gcc --version
```

The build system expects standard GNU build tools:
- GNU Make
- Bash shell (Git Bash or WSL on Windows)
- Standard Unix utilities (sed, find, etc.)

## Building the Libraries

This assumes you have installed the toolchain from
the mips32 repository.  The build system is tested to run under
MSYS2 on Windows.

### Quick Start

From the `pic32m-libs` directory:

```bash
cd /c/pic32/pic32-libs/pic32m-libs
make
```

### Installing to Toolchain

The libraries must be installed into your `mips-elf` toolchain directory tree before you can link applications:

```bash
make install
```

By default, libraries are installed to:
```
/c/pic32/atom/mips-elf/
```

The CMAKE custom toolchains in /c/pic32/cmake have references to the libraries installed
by default to /c/pic32/atom/mips-elf/.

### Customizing Installation Directory

Edit `defines.mk` to change the installation location:

```makefile
DESTROOT = /your/custom/path
```

Or set it on the command line:

```bash
make install DESTROOT=/opt/mips-toolchain
```

The installation creates this directory structure:
```
$(DESTROOT)/
└── mips-elf/
    ├── lib/               # Compiled libraries (.a files)
    │   ├── libpic32.a
    │   ├── libdsp.a
    │   ├── libm.a
    │   └── ...
    └── include/           # Header files
        └── pic32m-libs/
            ├── cp0defs.h
            ├── sys/
            └── ...
```

## Build Configuration

### Architecture Settings

The default target is configured in `defines.mk`:

```makefile
ARCH_FLAGS = -march=m14k -msoft-float
```

This builds for the MIPS M14K core with software floating-point. Adjust as needed for your specific PIC32 variant.

### Multi-Library Support

The build system automatically creates multiple library variants using GCC's multi-lib feature to support different compilation options (e.g., MIPS16, microMIPS).

### Debug Builds

Debug symbols are enabled by default. To change:

```makefile
DEBUG = -g -fvar-tracking    # Full debug info
# or
DEBUG =                       # No debug info
```

## Cleaning

Remove all build artifacts:

```bash
make clean
```

## GCC Conversion Notes

These libraries were originally written for Microchip's XC32 compiler and have been converted to work with standard GCC MIPS assembler:

- Changed `.section` directives from Microchip format (`,code`) to GCC format
- Added `$` prefix to all register names
- Converted `.frame` directives to use `$ra` instead of `$31`
- Changed section attributes to GCC-compatible flags (`"ax"` for allocatable, executable)
- Added `-mexplicit-relocs` flag required by `-mno-gpopt`

## Typical Workflow

1. **Build the toolchain** (if not already done)
2. **Build and install these libraries**:
   ```bash
   cd pic32-libs/pic32m-libs
   make
   make install
   ```
3. **Build your PIC32 application**, linking against the installed libraries:
   ```bash
   mips-elf-gcc -march=m14k -msoft-float myapp.c -lpic32 -lm -o myapp.elf
   ```

## Troubleshooting

### "mips-elf-gcc: command not found"

Ensure the `mips-elf` toolchain is in your PATH:
```bash
export PATH=/path/to/mips-elf/bin:$PATH
```

### "No such file or directory" during install

Check that `DESTROOT` in `defines.mk` points to a valid, writable directory.

### Assembly errors

If you see assembly syntax errors, ensure you're using a recent version of GNU binutils (2.35+) that properly supports MIPS assembly.

## License

Copyright (c) 2017-2025, Microchip Technology Inc. and its subsidiaries.

See individual source files for detailed license information. Most files are licensed under Apache License 2.0 or BSD-style licenses permitting redistribution.

## Contributing

When modifying assembly files, remember:
- Use `$` prefix for all register names
- Use GCC-compatible section directives
- Test with multiple optimization levels
- Verify multi-lib builds work correctly

## References

- [GCC MIPS Options](https://gcc.gnu.org/onlinedocs/gcc/MIPS-Options.html)
- [MIPS Assembly Language](https://www.mips.com/products/architectures/mips32-2/)
- [PIC32 Family Reference Manual](https://www.microchip.com/en-us/products/microcontrollers-and-microprocessors/32-bit-mcus/pic32-32-bit-mcus)
