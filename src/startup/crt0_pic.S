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
 *  C Runtime Startup for Position Independent Code
 *-------------------------------------------------------------------------*/

#include "xc.h"
#include <cp0defs.h>

#if !defined(PIC32_SRS_SET_COUNT)
#  if defined(__PIC32_SRS_SET_COUNT)
#    define PIC32_SRS_SET_COUNT __PIC32_SRS_SET_COUNT
#  else
#    warning PIC32_SRS_SET_COUNT not defined on build line
#    define PIC32_SRS_SET_COUNT 2
#  endif
#endif

#if defined(__PIC32MX) || defined(__PIC32MM) || defined(__PIC32MZ)
#define INIT_DATA 1
#endif

/* This file contains 32-bit assembly code */
       .set nomips16

##################################################################
# Entry point of the entire application
##################################################################
        .section .reset,"ax",@progbits
        .align 2
        .set noreorder
        .ent _reset

############################
# Begin ISA switching code #
############################

#if defined (__mips_micromips)
        .set micromips
#endif

#if (defined(__PIC32_HAS_MICROMIPS)) && (defined(__PIC32_HAS_MIPS32R2))
_reset:
        .word 0x10000004     /* MIPS32:    branch forward 0x10 bytes from here  */
                             /* MicroMIPS: ADDI32 $0, $0, 0x0007 (nop)          */
                             /* DO NOT change the relative branch               */

        .word 0x00000000     /* NOP */
__reset_micromips_isa:
        .set    micromips
        jal     _startup
        nop

        .align 2
        /* Device not in proper ISA mode */
        .set nomicromips
__reset_switch_isa:
        jal _startup
        nop

#else

_reset:
        jal _startup
        nop

#endif  /* __PIC32_HAS_MICROMIPS */

        .align 2
        .end _reset
        .globl _reset
        .size _reset, .-_reset

        .section .reset.startup,"ax",@progbits
        .align 2
        .set noreorder

#if defined (__mips_micromips)
        .set micromips
#else
        .set nomicromips
#endif

############################
# End ISA switching code   #
############################


        ##################################################################
        # Startup code
        ##################################################################
        .align 2
        .set noreorder
        .ent _startup
_startup:
        ##################################################################
        # If entered because of an NMI, jump to the NMI handler.
        ##################################################################
        mfc0    $26,_CP0_STATUS         # k0 = $26
        ext     $26,$26,19,1            # Extract NMI bit
        beqz    $26,_no_nmi
        nop
        lw	$25, %call16(_nmi_handler)($28)  # t9 = $25, gp = $28
        jr 	$25
        nop
_no_nmi:


#if (PIC32_SRS_SET_COUNT == 2)
        ##################################################################
        # Initialize Global Pointer in Shadow Set
        #   The SRSCtl's PSS field must be set to the shadow set in which
        #   to initialize the global pointer.  Since we have only a
        #   single shadow set (besides the normal), we will initialize
        #   SRSCtl<PSS> to SRSCtl<HSS>.  We then write the global pointer
        #   to the previous shadow set to ensure that on interrupt, the
        #   global pointer has been initialized.
        ##################################################################
        mfc0    $9,_CP0_SRSCTL          # t1 = $9, Read SRSCtl register
        add     $11,$9,$0               # t3 = $11, Save off current SRSCtl
        ext     $10,$9,26,4             # t2 = $10, to obtain HSS field
        ins     $9,$10,6,4              # Put HSS field
        mtc0    $9,_CP0_SRSCTL          # into SRSCtl<PSS>
        ehb                             # Clear hazard before using new SRSCTL
        wrpgpr  $28,$28                 # Set global pointer in PSS (gp = $28)
        mtc0    $11,_CP0_SRSCTL         # Restore SRSCtl
        ehb

#elif (PIC32_SRS_SET_COUNT > 2)
        ##################################################################
        # Initialize Global Pointer in Shadow Set(s)
        #   The SRSCtl PSS field must be set to the shadow set in which
        #   to initialize the global pointer.  We will initialize
        #   SRSCtl<PSS> to the number of reg sets and work down to set zero.
        #   We write the global pointer to the previous shadow set to
        #   ensure that on interrupt, the global pointer has been
        #   initialized.
        ##################################################################
        mfc0    $9,_CP0_SRSCTL          # t1 = $9, Read SRSCtl register
        add     $11,$9,$0               # t3 = $11, Save off current SRSCtl

        li      $10,(PIC32_SRS_SET_COUNT-1)  # t2 = $10

1:      ins     $9,$10,6,4              # Put next shadow set field
        mtc0    $9,_CP0_SRSCTL          # into SRSCtl<PSS>
        ehb                             # Clear hazard before using new SRSCTL
        wrpgpr  $28,$28                 # Set global pointer in PSS (gp = $28)

        addiu   $10,$10,-1              # Next lower shadow set
                                        # Loop for all sets
        bne     $10,$0,1b               # Down to zero (normal GPR set)
        nop

        mtc0    $11,_CP0_SRSCTL         # Restore SRSCtl
        ehb

#endif /* (PIC32_SRS_SET_COUNT > 2) */

        ##################################################################
        # Call the "on reset" procedure
        ##################################################################
        lw	$25, %call16(_on_reset)($28)  # t9 = $25, gp = $28
        jalr 	$25
        nop

#if defined(INIT_MMU_MZ_FIXED)
        ##################################################################
        # Initialize TLB for fixed mapping to EBI and SQI
        ##################################################################
        .extern __pic32_tlb_init_ebi_sqi
        lw	$25,%call16(__pic32_tlb_init_ebi_sqi)($28)
        jalr    $25
        nop
#endif

#if defined(INIT_L1_CACHE)
        ##################################################################
        # Initialize L1 cache register
        ##################################################################
        .extern __pic32_init_cache
        lw	$25,%call16(__pic32_init_cache)($28)
        jalr    $25
        nop
#endif

#if defined(INIT_DATA)
        ##################################################################
        # Clear uninitialized data sections
        ##################################################################
        lw	$2,%got(_bss_begin)($28)    # v0 = $2
        lw	$8,0($2)                    # t0 = $8
        lw	$2,%got(_bss_end)($28)
        lw	$9,0($2)                    # t1 = $9
        b       _bss_check
        nop

_bss_init:
        sw      $0,0x0($8)              # zero = $0
        addiu   $8,$8,4
_bss_check:
        sltu    $10,$8,$9               # t2 = $10
        bne     $10,$0,_bss_init
        nop

        ##################################################################
        # Initialize data sections
        ##################################################################
        lw	$2,%got(__data_start)($28)
        lw	$8,0($2)
        lw	$2,%got(__data_init)($28)
        lw	$9,0($2)
        lw	$2,%got(__data_end)($28)
        lw	$10,0($2)
        b       _init_check
        nop

_init_data:
        lw      $11,0x0($9)             # t3 = $11
        sw      $11,0x0($8)
        addiu   $9,$9,4
        addiu   $8,$8,4
_init_check:
        sltu    $11,$8,$10
        bne     $11,$0,_init_data
        nop
#endif

        ##################################################################
        # Initialize cp0 registers
        ##################################################################
        # Initialize Count register
        ##################################################################
        mtc0    $0,_CP0_COUNT

        ##################################################################
        # Initialize Compare register
        ##################################################################
        li      $9,-1                   # t1 = $9
        mtc0    $9,_CP0_COMPARE

        ##################################################################
        # Initialize EBase register
        ##################################################################
        lw	$2,%got(_ebase_address)($28)
        lw	$8,0($2)
        mtc0    $8,_CP0_EBASE

        ##################################################################
        # Initialize IntCtl register
        ##################################################################
        lw	$2,%got(_vector_spacing)($28)
        lw	$9,0($2)
        li      $8,0                    # t0 = $8
        ins     $8,$9,5,5
        mtc0    $8,_CP0_INTCTL

#if defined(__PIC32MM)
        ##################################################################
        # Initialize PIC32MM INTCON register for multi-vector mode
        ##################################################################
        lw	$2,%got(_vector_spacing)($28)
        lw	$9,0($2)
        lw	$2,%got(INTCON)($28)
        lw	$8,0($2)
        lw	$10,0($8)               # t2 = $10
        ins     $10,$9,16,7
#if defined(__PIC32MM) && defined(_INTCON_MVEC_MASK)
        ori     $10,$10,_INTCON_MVEC_MASK
#endif
        sw      $10,0($8)
#endif
        li      $10,0                   # Clear t2 and
        ins     $10,$9,5,5              # shift value to VS field
        mtc0    $10,_CP0_INTCTL

        ##################################################################
        # Initialize CAUSE registers
        # - Enable counting of Count register <DC = 0>
        # - Use special exception vector <IV = 1>
        # - Clear pending software interrupts <IP1:IP0 = 0>
        ##################################################################
        li      $9,0x00800000
        mtc0    $9,_CP0_CAUSE

        ##################################################################
        # Initialize STATUS register
        # - Access to Coprocessor 0 not allowed in user mode <CU0 = 0>
        # - User mode uses configured endianness <RE = 0>
        # - Preserve Bootstrap Exception vectors <BEV>
        # - Preserve soft reset <SR> and non-maskable interrupt <NMI>
        # - CorExtend enabled based on whether CorExtend User Defined
        #   Instructions have been implemented <CEE = Config<UDI>>
        # - Disable any pending interrupts <IM7..IM2 = 0, IM1..IM0 = 0>
        # - Disable hardware interrupts <IPL7:IPL2 = 0>
        # - Base mode is Kernel mode <UM = 0>
        # - Error level is normal <ERL = 0>
        # - Exception level is normal <EXL = 0>
        # - Interrupts are disabled <IE = 0>
        # - DSPr2 ASE is enabled for devices that support it <MX = 1>
        # - FPU64 is enabled for devices that support it <CU1=1> & <FR=1>
        ##################################################################
        mfc0    $8,_CP0_CONFIG
        ext     $9,$8,22,1              # Extract UDI from Config register
        sll     $9,$9,17                # Move UDI to Status.CEE location
        mfc0    $8,_CP0_STATUS
        and     $8,$8,0x00580000        # Preserve SR, NMI, and BEV
#if defined(INIT_DSPR2)
        li      $10,0x01000000          # Set the Status.MX bit to enable DSP
        or      $8,$10,$8
#endif
#if defined(INIT_FPU64)
        li      $10,0x24000000          # Set the Status.CU1 and Status.FR bits to
        or      $8,$10,$8               # enable the FPU in FR64 mode
#endif

        or      $8,$9,$8                # Include Status.CEE (from UDI)
        mtc0    $8,_CP0_STATUS

#if defined(INIT_FPU64)
                                        # FPU Control and Status
        li      $10,0x1000000           # FCSR: RM=0, FS=1, FO=0, FN=0
                                        # Enables: 0b00000 E=1, V=0, Z=0, O=0, U=0, I=0
        ctc1    $10, $31                # High perf on denormal operands & tiny results
#endif
        ehb

        ##################################################################
        # Call the "on bootstrap" procedure
        ##################################################################
        lw	$25,%call16(_on_bootstrap)($28)
        jalr    $25
        nop

        ##################################################################
        # Initialize Status<BEV> for normal exception vectors
        ##################################################################
        mfc0    $8,_CP0_STATUS
        and     $8,$8,0xffbfffff        # Clear BEV
        mtc0    $8,_CP0_STATUS

        ##################################################################
        # Call main. We do this via a thunk in the text section so that
        # a normal jump and link can be used, enabling the startup code
        # to work properly whether main is written in MIPS16 or MIPS32
        # code. I.e., the linker will correctly adjust the JAL to JALX if
        # necessary
        ##################################################################
        and     $4,$4,0                 # a0 = $4
        and     $5,$5,0                 # a1 = $5
        lw	$25,%call16(_main_entry)($28)
        jr      $25
        nop

        .globl _startup
        .end _startup

        ##################################################################
        # Boot Exception Vector Handler
        # Jumps to _bootstrap_exception_handler
        ##################################################################
        .section .bev_handler,"ax",@progbits
        .align 2
        .set noreorder
        .ent _bev_exception
_bev_exception:
	lw	$25,%call16(_bootstrap_exception_handler)($28)
        jr      $25
        nop
        .globl _bev_exception
        .end _bev_exception

        ##################################################################
        # General Exception Vector Handler
        # Jumps to _general_exception_context
        ##################################################################
        .section .gen_handler,"ax",@progbits
        .align 2
        .set noreorder
        .ent _gen_exception
_gen_exception:
0:
        lw	$25,%call16(_general_exception_context)($28)
        jr      $25
        nop

        .end _gen_exception

#if 0 /* Check for PIC */
#if defined(INIT_MMU_MZ_FIXED)
        ##################################################################
        # Simple TLB-Refill Exception Vector
        # Jumps to _simple_tlb_refill_exception_context
        ##################################################################
        .section .simple_tlb_refill_vector,"ax",@progbits
        .align 2
        .set noreorder
        .ent simple_tlb_refill_vector
simple_tlb_refill_vector:
        lw	$25,%call16(_simple_tlb_refill_exception_context)($28)
        jr      $25
        nop

        .end simple_tlb_refill_vector
#endif

#if defined(INIT_L1_CACHE)
        ##################################################################
        # Cache-Error Exception Vector Handler
        # Jumps to _cache_err_exception_context
        ##################################################################
        .section .cache_err_vector,"ax",@progbits
        .align 2
        .set noreorder
        .ent _cache_err_vector
_cache_err_vector:
	lw	$25,%call16(_cache_err_exception_context)($28)
        jr      $25
        nop

        .end _cache_err_vector
#endif
#endif /* Check for PIC */

        .section .text.main_entry,"ax",@progbits
        .align 2
        .global _main_entry
        .ent _main_entry
_main_entry:


#if 0

#if defined(CPP_INIT)
        .weak _init
        # call .init section to run constructors etc

        lw     $25,%call16(_init)($28)
        beq    $25,$0,2f
        nop
        jalr   $25
        nop

2:
#endif

#endif 
        and     $4,$4,0
        and     $5,$5,0

        ##################################################################

        # Call main
        ##################################################################
        lw	$25,%call16(main)($28)
        jalr 	$25
        nop

#if defined(CALL_EXIT)
        ##################################################################
        # Call exit()
        ##################################################################
        lw	$25,%call16(exit)($28)
        jalr    $25
        nop
#endif

        ##################################################################
        # Just in case, go into infinite loop
        # Call a software breakpoint only with -mdebugger compiler option
        ##################################################################
        .weak __exception_handler_break
__crt0_exit:
1:
        lw	$25,%call16(__exception_handler_break)($28)
        beq     $25,$0,0f
        nop
        jalr    $25
        nop

0:      b       1b
        nop

        addiu	sp,sp,32

        .set	macro
        .set	reorder

        .globl __crt0_exit
        .end _main_entry
