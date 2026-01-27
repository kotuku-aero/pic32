/*-------------------------------------------------------------------------
 * Copyright (c) 2025, Microchip Technology Inc. and its subsidiaries ("Microchip")
 * All rights reserved.
 * This software is developed by Microchip Technology Inc. and its
 * subsidiaries ("Microchip").
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------
 *  C Runtime Startup (crt0_EF.S)
 *
 *  OVERVIEW:
 *  This is the C Runtime Startup code for PIC32MZ microcontrollers.
 *  It executes immediately after reset and is responsible for:
 *    1. Detecting NMI (Non-Maskable Interrupt) conditions
 *    2. Initializing the stack pointer and global pointer
 *    3. Setting up shadow register sets (for fast interrupts)
 *    4. Clearing BSS (uninitialized data) to zero
 *    5. Copying initialized data from flash to RAM (if applicable)
 *    6. Copying RAM functions from flash to RAM (if applicable)
 *    7. Initializing caches and TLB
 *    8. Configuring CP0 (Coprocessor 0) registers
 *    9. Calling C library initialization (__libc_init_array)
 *   10. Calling C++ constructors (if applicable)
 *   11. Jumping to main()
 *
 *  BUILD CONFIGURATION:
 *  Define the following symbols based on your PIC32 family:
 *
 *    PIC32_FAMILY_EF  - Define for PIC32MZ EF series (has FPU64 and DSPr2)
 *    PIC32_FAMILY_DA  - Define for PIC32MZ DA series (no FPU)
 *    CPP_INIT         - Define to enable C++ constructor initialization
 *    CALL_EXIT        - Define to call exit() after main() returns
 *
 *  LINKER SYMBOL DEPENDENCIES:
 *  This code requires specific symbols from the linker script:
 *    _stack, _gp, _bss_begin, _bss_end, _ebase_address, _vector_spacing
 *    _data_begin, _data_init, _data_end
 *
 *  DEBUGGING TIPS:
 *  - Set breakpoint at _reset to catch reset
 *  - Set breakpoint at _no_nmi to skip NMI handling
 *  - Set breakpoint at _main_entry to catch entry to C code
 *  - Check $sp (stack pointer) after initialization
 *  - Check $gp (global pointer) after initialization
 *-------------------------------------------------------------------------*/

#include <xc.h>
#include <cp0defs.h>

/* PIC32MZ processor has 8 shadow register sets */
#define PIC32_SRS_SET_COUNT 8

/* This file contains 32-bit assembly code */
       .set nomips16

        ##################################################################
        # Entry point of the entire application
        #
        # This reset code is ISA-agnostic: it works whether the CPU boots
        # in MIPS32 or microMIPS mode (controlled by BOOTISA config bit).
        #
        # The first word (0x10000003) is a "polyglot" instruction:
        #   - In MIPS32 mode: branch forward 0x10 bytes to __reset_switch_isa
        #   - In microMIPS mode: decoded as a NOP-like instruction
        #
        # This ensures correct startup regardless of BOOTISA setting.
        ##################################################################
        .section .reset,"ax",@progbits
        .align 2
        .set noreorder
        .ent _reset

        .set nomicromips
_reset:
        .word 0x10000003            /* MIPS32: branch +0x10; microMIPS: NOP */
        .word 0x00000000            /* NOP (delay slot / padding) */

        .set micromips
__reset_micromips_isa:
        jal _startup
        nop

        .align 2
        .set nomicromips
__reset_switch_isa:
        jal _startup
        nop

        .end _reset

        .globl _reset
        .size _reset, .-_reset

        ##################################################################
        # Startup code - Main initialization sequence
        #
        # BOOT SEQUENCE ORDER:
        #  1. NMI detection
        #  2. Stack pointer initialization
        #  3. Global pointer initialization
        #  4. Shadow register set initialization
        #  5. _on_reset() callback
        #  6. TLB initialization (if needed)
        #  7. BSS clearing
        #  8. L1 cache initialization
        #  9. Data section initialization
        # 10. CP0 register setup
        # 11. _on_bootstrap() callback
        # 12. Clear BEV
        # 13. Jump to main via _main_entry
        ##################################################################
        .section .reset.startup,"ax",@progbits
        .align 4
        .set noreorder
        .globl _startup
        .ent _startup

_startup:
        ##################################################################
        # If entered because of an NMI, jump to the NMI handler.
        ##################################################################
        mfc0    $26,_CP0_STATUS
        ehb
        ext     $26,$26,19,1            # Extract NMI bit (bit 19)
        beqz    $26,_no_nmi
        nop
        lui     $26,%hi(_nmi_handler)
        addiu   $26,$26,%lo(_nmi_handler)
        jr      $26
        nop

_no_nmi:
        .set macro

        ##################################################################
        # Initialize Stack Pointer
        ##################################################################
        lui     sp,%hi(_stack)
        addiu   sp,sp,%lo(_stack)

        ##################################################################
        # Initialize Global Pointer
        ##################################################################
        lui     $28,%hi(_gp)
        addiu   $28,$28,%lo(_gp)

        ##################################################################
        # Initialize Global Pointer in Shadow Register Sets
        ##################################################################
        mfc0    $9,_CP0_SRSCTL
        add     $11,$9,$0               # Save current SRSCtl

        li      $10,(PIC32_SRS_SET_COUNT-1)

1:      ins     $9,$10,6,4              # Set PSS field
        mtc0    $9,_CP0_SRSCTL
        ehb
        wrpgpr  $28,$28                 # Set GP in shadow set

        addiu   $10,$10,-1
        bne     $10,$0,1b
        nop

        mtc0    $11,_CP0_SRSCTL         # Restore SRSCtl
        ehb

        ##################################################################
        # Call the "on reset" procedure
        ##################################################################
        la      $8,_on_reset
        jalr    $8
        nop

        ##################################################################
        # Initialize TLB for EBI and SQI (if function exists)
        ##################################################################
        .weak __pic32_tlb_init_ebi_sqi
        lui     $8,%hi(__pic32_tlb_init_ebi_sqi)
        addiu   $8,$8,%lo(__pic32_tlb_init_ebi_sqi)
        beqz    $8,_skip_tlb_init
        nop
        jalr    $8
        nop
_skip_tlb_init:

        ##################################################################
        # Clear BSS section
        ##################################################################
        lui     $8,%hi(_bss_begin)
        addiu   $8,$8,%lo(_bss_begin)
        lui     $9,%hi(_bss_end)
        addiu   $9,$9,%lo(_bss_end)
        b       _bss_check
        nop

_bss_init:
        sw      $0,0x0($8)
        addiu   $8,$8,4
_bss_check:
        sltu    $10,$8,$9
        bne     $10,$0,_bss_init
        nop

        ##################################################################
        # Initialize L1 cache (if function exists)
        ##################################################################
        .weak __pic32_init_cache
        lui     $8,%hi(__pic32_init_cache)
        addiu   $8,$8,%lo(__pic32_init_cache)
        beqz    $8,_skip_cache_init
        nop
        jalr    $8
        nop
_skip_cache_init:

        ##################################################################
        # Copy initialized data from flash to RAM
        ##################################################################
        lui     $8,%hi(_data_begin)
        addiu   $8,$8,%lo(_data_begin)

        lui     $9,%hi(_data_init)
        addiu   $9,$9,%lo(_data_init)

        lui     $10,%hi(_data_end)
        addiu   $10,$10,%lo(_data_end)

        b       _init_check
        nop

_init_data:
        lw      $11,0x0($9)
        sw      $11,0x0($8)
        addiu   $9,$9,4
        addiu   $8,$8,4
_init_check:
        sltu    $11,$8,$10
        bne     $11,$0,_init_data
        nop

        ##################################################################
        # Initialize CP0 registers
        ##################################################################

        # Initialize Count register
        mtc0    $0,_CP0_COUNT

        # Initialize Compare register
        li      $9,-1
        mtc0    $9,_CP0_COMPARE

        # Initialize EBase register
        lui     $8,%hi(_ebase_address)
        addiu   $8,$8,%lo(_ebase_address)
        mtc0    $8,_CP0_EBASE

        # Initialize IntCtl register
        lui     $9,%hi(_vector_spacing)
        addiu   $9,$9,%lo(_vector_spacing)
        li      $8,0
        ins     $8,$9,5,5
        mtc0    $8,_CP0_INTCTL
        ehb

        li      $10,0
        ins     $10,$9,5,5
        mtc0    $10,_CP0_INTCTL

        ##################################################################
        # Initialize CAUSE register
        # - Enable Count register <DC = 0>
        # - Use special exception vector <IV = 1>
        # - Clear pending software interrupts <IP1:IP0 = 0>
        ##################################################################
        li      $9,0x00800000
        mtc0    $9,_CP0_CAUSE

        ##################################################################
        # Initialize STATUS register
        ##################################################################
        mfc0    $8,_CP0_CONFIG
        ext     $9,$8,22,1              # Extract UDI from Config register
        sll     $9,$9,17                # Move UDI to Status.CEE location
        mfc0    $8,_CP0_STATUS
        and     $8,$8,0x00580000        # Preserve SR, NMI, and BEV
        or      $8,$9,$8                # Include Status.CEE (from UDI)
        mtc0    $8,_CP0_STATUS
        ehb

        ##################################################################
        # Call the "on bootstrap" procedure
        ##################################################################
        lui     $8,%hi(_on_bootstrap)
        addiu   $8,$8,%lo(_on_bootstrap)
        jalr    $8
        nop

        ##################################################################
        # Clear BEV for normal exception vectors
        ##################################################################
        mfc0    $8,_CP0_STATUS
        and     $8,$8,0xffbfffff
        mtc0    $8,_CP0_STATUS

        ##################################################################
        # Jump to main via _main_entry thunk
        ##################################################################
        and     $4,$4,0
        and     $5,$5,0
        lui     $8,%hi(_main_entry)
        addiu   $8,$8,%lo(_main_entry)
        jr      $8
        nop

        .end _startup

        ##################################################################
        # Boot Exception Vector Handler
        ##################################################################
        .section .bev_handler,"ax",@progbits
        .align 2
        .set noreorder
        .ent _bev_exception

_bev_exception:
        lui     $26,%hi(_bootstrap_exception_handler)
        addiu   $26,$26,%lo(_bootstrap_exception_handler)
        jr      $26
        nop

        .end _bev_exception

        ##################################################################
        # General Exception Vector Handler
        ##################################################################
        .section .gen_handler,"ax",@progbits
        .align 2
        .set noreorder
        .ent _gen_exception

_gen_exception:
        lui     $26,%hi(_general_exception_context)
        addiu   $26,$26,%lo(_general_exception_context)
        jr      $26
        nop

        .end _gen_exception

        ##################################################################
        # Simple TLB-Refill Exception Vector
        ##################################################################
        .section .simple_tlb_refill_vector,"ax",@progbits
        .align 2
        .set noreorder
        .ent simple_tlb_refill_vector

simple_tlb_refill_vector:
        lui     $26,%hi(_simple_tlb_refill_exception_context)
        addiu   $26,$26,%lo(_simple_tlb_refill_exception_context)
        jr      $26
        nop

        .end simple_tlb_refill_vector

        ##################################################################
        # Cache-Error Exception Vector Handler
        ##################################################################
        .section .cache_err_vector,"ax",@progbits
        .align 2
        .set noreorder
        .ent _cache_err_vector

_cache_err_vector:
        lui     $26,%hi(_cache_err_exception_context)
        addiu   $26,$26,%lo(_cache_err_exception_context)
        jr      $26
        nop

        .end _cache_err_vector

        ##################################################################
        # Main Entry Point
        ##################################################################
        .section .text.main_entry,"ax",@progbits
        .align 2
        .ent _main_entry

_main_entry:

        ##################################################################
        # C library initialization (if function exists)
        ##################################################################
        .weak __libc_init_array
        lui     $8,%hi(__libc_init_array)
        addiu   $8,$8,%lo(__libc_init_array)
        beqz    $8,_skip_libc_init
        nop
        jalr    $8
        nop
_skip_libc_init:

#if defined(CPP_INIT)
        ##################################################################
        # C++ constructor initialization
        ##################################################################
        .weak _init
        lui     $4,%hi(_init)
        addiu   $sp,$sp,-24
        addiu   $4,$4,%lo(_init)
        beq     $4,$0,_skip_cpp_init
        nop
        sw      $31,20($sp)
        jalr    $4
        nop
_skip_cpp_init:
#endif
        and     $4,$4,0
        and     $5,$5,0

        ##################################################################
        # Call main
        ##################################################################
        lui     $8,%hi(main)
        addiu   $8,$8,%lo(main)
        jalr    $8
        nop

#if defined(CALL_EXIT)
        ##################################################################
        # Call exit()
        ##################################################################
        jal     exit
        nop
#endif

        ##################################################################
        # Infinite loop (if main returns)
        ##################################################################
        .weak __exception_handler_break
__crt0_exit:
1:
        lui     $2,%hi(__exception_handler_break)
        addiu   $2,$2,%lo(__exception_handler_break)
        beq     $2,$0,0f
        nop
        jalr    $2
        nop

0:      b       1b
        nop

        .globl __crt0_exit
        .end _main_entry
