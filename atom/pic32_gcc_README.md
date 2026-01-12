# PIC32MZ Vanilla GCC Support

This project provides headers and utilities to build PIC32MZ firmware using a standard `mips-elf-gcc` toolchain instead of Microchip's XC32 compiler.

## Overview

Microchip's XC32 compiler is based on GCC but includes proprietary extensions for interrupt handling, configuration bits, and device-specific features. This project provides drop-in replacements for those extensions using standard GCC attributes and inline assembly.

**Everything here is also compatible with XC32** - you can use these headers with either toolchain, making it easier to migrate projects or maintain compatibility.

## Components

| File | Replaces | Purpose |
|------|----------|---------|
| `mips_irq.h` | `__attribute__((interrupt(IPLnSRS)))` | Interrupt handler declaration |
| `pic32mz_config.h` | `#pragma config` | Device configuration bits |
| `init_interrupt_stacks.S` | XC32 startup code | Shadow register set stack initialization |

## Quick Start

### Interrupt Handlers

**XC32 style:**
```c
void __attribute__((interrupt(IPL4SRS), vector(_TIMER_2_VECTOR))) timer2_isr(void)
{
    IFS0CLR = _IFS0_T2IF_MASK;
    timer2_ticks++;
}
```

**With mips_irq.h:**
```c
#include "mips_irq.h"

void interrupt(_TIMER_2_VECTOR)
{
    IFS0CLR = _IFS0_T2IF_MASK;
    timer2_ticks++;
}
```

The `interrupt()` macro generates a naked function with the proper prologue/epilogue for shadow register set operation. Your handler code is compiled as a normal C function, giving you full compiler optimization.

### Configuration Bits

**XC32 style:**
```c
#pragma config FNOSC = SPLL
#pragma config POSCMOD = HS
#pragma config FPLLMULT = MUL_50
#pragma config FPLLODIV = DIV_2
```

**With pic32mz_config.h:**
```c
#include "pic32mz_config.h"

DEVCFG1_VALUE(
    DEVCFG1_FNOSC_SPLL |
    DEVCFG1_POSCMOD_HS |
    DEVCFG1_FCKSM_CSDCMD |
    DEVCFG1_WDTPS_PS8 |
    DEVCFG1_FWDTEN_OFF
);

DEVCFG2_VALUE(
    DEVCFG2_FPLLIDIV_DIV_1 |
    DEVCFG2_FPLLRNG_RANGE_5_10 |
    DEVCFG2_FPLLICLK_PLL_POSC |
    DEVCFG2_FPLLMULT_MUL_50 |
    DEVCFG2_FPLLODIV_DIV_2
);
```

Include `pic32mz_config.h` in **one** source file per project. The macros place const values in the appropriate linker sections.

### Shadow Register Stack Initialization

PIC32MZ devices have multiple shadow register sets that provide zero-overhead context save for interrupts. Each set needs its own stack pointer.

**In your startup code:**
```c
extern void init_interrupt_stacks(void);

void startup(void)
{
    // Early initialization...
    
    init_interrupt_stacks();  // Set up shadow register stacks
    
    // Continue startup, enable interrupts later...
}
```

**Define stacks in C:**
```c
#define INT_STACK_SIZE 128  // 128 words = 512 bytes

uint32_t ipl4_stack[INT_STACK_SIZE] __attribute__((aligned(8)));
uint32_t ipl5_stack[INT_STACK_SIZE] __attribute__((aligned(8)));
uint32_t ipl6_stack[INT_STACK_SIZE] __attribute__((aligned(8)));
```

## Detailed Component Documentation

### mips_irq.h

The `interrupt()` macro expands to:

1. A naked function placed in `.vector_<name>` section
2. Assembly prologue saving: EPC, Status, ra, hi, lo
3. A `jal` to your implementation function
4. Assembly epilogue restoring context and executing `eret`

**Requirements:**
- Shadow register sets must be configured via PRISS register
- Interrupts must be non-nested (each IPL has dedicated shadow set)
- Handler must be `void function(void)` with no parameters

**Restrictions in interrupt handlers:**
- No floating-point operations (FPU registers not saved)
- No DSP instructions (DSP accumulators not saved)
- No blocking calls or malloc/free
- Only `*_from_isr()` safe functions for RTOS interaction

### pic32mz_config.h

Configuration bits are stored in flash at fixed addresses. The header provides:

| Macro | Address | Purpose |
|-------|---------|---------|
| `DEVCFG0_VALUE()` | 0xBFC0FFCC | Debug, code protect, oscillator boost |
| `DEVCFG1_VALUE()` | 0xBFC0FFC8 | Oscillator selection, watchdog timer |
| `DEVCFG2_VALUE()` | 0xBFC0FFC4 | PLL configuration |
| `DEVCFG3_VALUE()` | 0xBFC0FFC0 | User ID, peripheral pin config |
| `BF1SEQ0_VALUE()` | 0xBFC0FF40 | Boot sequence number |

Alternate boot flash configurations (ABF1, BF2, ABF2) are also supported.

**Important:** The linker script must define the corresponding `.config_BFC0FFxx` sections and memory regions. The standard Microchip linker scripts already include these.

### init_interrupt_stacks.S

This assembly file:

1. Sets SRSCtl.PSS to select each shadow set
2. Uses `wrpgpr` to write stack pointers to shadow registers
3. Configures the PRISS register to map IPL levels to shadow sets

**Default configuration:**
- IPL4 → Shadow set 4
- IPL5 → Shadow set 5
- IPL6 → Shadow set 6
- PRISS = 0x06540000

Modify the assembly file if you need different IPL-to-shadow-set mapping.

## Linker Script Requirements

Your linker script needs:

1. **Config sections** (already in Microchip scripts):
```
.config_BFC0FFC0 : { KEEP(*(.config_BFC0FFC0)) } > config_BFC0FFC0
.config_BFC0FFC4 : { KEEP(*(.config_BFC0FFC4)) } > config_BFC0FFC4
.config_BFC0FFC8 : { KEEP(*(.config_BFC0FFC8)) } > config_BFC0FFC8
.config_BFC0FFCC : { KEEP(*(.config_BFC0FFCC)) } > config_BFC0FFCC
```

2. **Vector sections** for interrupts:
```
.vectors _ebase_address + 0x200 :
{
    KEEP(*(.vector_*))
} > kseg0_program_mem
```

## Toolchain Setup

### Using mips-elf-gcc

```bash
# Install a MIPS bare-metal toolchain
# Many package managers have mips-elf-gcc or mipsel-elf-gcc

# Compile with appropriate flags
mips-elf-gcc -march=m5101 -EL -msoft-float \
    -D__PIC32MZ__ \
    -D__PIC32_SRS_SET_COUNT=8 \
    -I/path/to/these/headers \
    -T your_linker_script.ld \
    -o firmware.elf source.c
```

### Using XC32

These headers work with XC32 unchanged. You can mix `#pragma config` and the macro-based approach if migrating incrementally.

```bash
xc32-gcc -mprocessor=32MZ2048EFH064 \
    -I/path/to/these/headers \
    -o firmware.elf source.c
```

## XC32 Feature Comparison

| XC32 Feature | This Project | Notes |
|--------------|--------------|-------|
| `__attribute__((interrupt(IPLn)))` | `interrupt()` macro | Equivalent functionality |
| `__attribute__((vector(n)))` | Section placement | Via linker script |
| `#pragma config` | `DEVCFGn_VALUE()` macros | Equivalent functionality |
| `__builtin_disable_interrupts()` | Inline asm | See cp0 access macros |
| `__builtin_mfc0()` | Inline asm | See cp0 access macros |
| `__attribute__((coherent))` | kseg1 addressing | Place in uncached segment |
| `__attribute__((persistent))` | Section + linker | Omit from .bss clear |
| `__attribute__((ramfunc))` | Section + startup copy | Manual implementation |
| Device headers (`<xc.h>`) | Your own headers | Generate from .PIC files |

## Limitations

1. **Device headers** - You need PIC32MZ register definitions. These can be generated from Microchip's .PIC files or written manually.

2. **Startup code** - A complete crt0.S for vanilla GCC requires more work (cache init, TLB setup, .data/.bss initialization). This project focuses on the interrupt and config bit replacements.

3. **FPU/DSP in ISRs** - The minimal prologue doesn't save FPU or DSP state. If you need these in interrupts, extend the prologue or use a separate handler approach.

## License

This project is provided under the MIT license. Use freely in commercial and open-source projects.

## Contributing

Contributions welcome:
- Additional device support (PIC32MX, PIC32MK)
- Extended configuration bit coverage
- Startup code improvements
- Documentation and examples

## References

- [MIPS32 Architecture Documentation](https://www.mips.com/products/architectures/mips32-2/)
- [PIC32MZ EF Family Datasheet](https://www.microchip.com/en-us/products/microcontrollers-and-microprocessors/32-bit-mcus/pic32-32-bit-mcus/pic32mz-ef)
- [XC32 Compiler User's Guide](https://www.microchip.com/en-us/tools-resources/develop/mplab-xc-compilers)
