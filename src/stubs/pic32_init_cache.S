/*-------------------------------------------------------------------------
 *
 * Copyright (c) 2014, Microchip Technology Inc. and its subsidiaries ("Microchip")
 * All rights reserved.
 * 
 * This software is developed by Microchip Technology Inc. and its
 * subsidiaries ("Microchip").
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * 1.      Redistributions of source code must retain the above copyright
 *         notice, this list of conditions and the following disclaimer.
 * 2.      Redistributions in binary form must reproduce the above
 *         copyright notice, this list of conditions and the following
 *         disclaimer in the documentation and/or other materials provided
 *         with the distribution. Publication is not required when this 
 *         file is used in an embedded application.
 * 3.      Microchip's name may not be used to endorse or promote products
 *         derived from this software without specific prior written
 *         permission.
 *
 * THIS SOFTWARE IS PROVIDED BY MICROCHIP "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL MICROCHIP BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING BUT NOT LIMITED TO
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWSOEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *-------------------------------------------------------------------------*/

#include <cp0defs.h>

        /* Symbols defined in linker script */
        .weak __pic32_init_cache_program_base_addr
        .weak __pic32_init_cache_data_base_addr

/* Cache Coherency Attributes */
#define _CACHE_WRITEBACK_WRITEALLOCATE      3
#define _CACHE_WRITETHROUGH_WRITEALLOCATE   1
#define _CACHE_WRITETHROUGH_NOWRITEALLOCATE 0
#define _CACHE_DISABLE                      2

#ifndef _CP0_ERRCTL
#define _CP0_ERRCTL                         $26, 0
#endif

#ifndef _CP0_TAGLO
#define _CP0_TAGLO                          $28, 0
#endif

/* Set __PIC32_CACHE_MODE to the desired coherency attribute */
#define __PIC32_CACHE_MODE _CACHE_WRITEBACK_WRITEALLOCATE

/* ==================================== */
#define Index_Store_Tag_I 0x08
#define Index_Store_Tag_D 0x09

/* Cache size and configuration variables */
.section .sdata,"aw",@progbits
.globl __pic32_icache_size
.type __pic32_icache_size,@object
.size __pic32_icache_size,4
__pic32_icache_size:
.word -1

.globl __pic32_icache_linesize
.type __pic32_icache_linesize,@object
.size __pic32_icache_linesize,4
__pic32_icache_linesize:
.word -1

.globl __pic32_icache_ways
.type __pic32_icache_ways,@object
.size __pic32_icache_ways,4
__pic32_icache_ways:
.word 1

.globl __pic32_dcache_size
.type __pic32_dcache_size,@object
.size __pic32_dcache_size,4
__pic32_dcache_size:
.word -1

.globl __pic32_dcache_linesize
.type __pic32_dcache_linesize,@object
.size __pic32_dcache_linesize,4
__pic32_dcache_linesize:
.word -1

.globl __pic32_dcache_ways
.type __pic32_dcache_ways,@object
.size __pic32_dcache_ways,4
__pic32_dcache_ways:
.word 1

.globl __pic32_scache_size
.type __pic32_scache_size,@object
.size __pic32_scache_size,4
__pic32_scache_size:
.word -1

.globl __pic32_scache_linesize
.type __pic32_scache_linesize,@object
.size __pic32_scache_linesize,4
__pic32_scache_linesize:
.word -1

.globl __pic32_scache_ways
.type __pic32_scache_ways,@object
.size __pic32_scache_ways,4
__pic32_scache_ways:
.word 1

.section .cache_init.cache,"ax",@progbits
        .set nomips16
        .ent __size_cache
__size_cache:
        mfc0 $9,_CP0_CONFIG             # cfg = $9 (t1)

        li $10,0                        # icachesize = $10 (t2)
        li $11,0                        # ilinesize = $11 (t3)
        li $13,0                        # dcachesize = $13 (t5)
        li $14,0                        # dlinesize = $14 (t6)

        /* Check that we have Config1 */
        and $8,$9,_CP0_CONFIG_M_MASK    # tmp = $8 (t0)
        mfc0 $9,_CP0_CONFIG1            # cfg = $9
        beqz $8,9f
        nop

        /* Get icache line size (log2) */
        and $8,$9,_CP0_CONFIG1_IL_MASK
        srl $8,_CP0_CONFIG1_IL_POSITION
        beqz $8,8f                      # no i-cache
        addiu $8,$8,1

        /* Get number of icache ways */
        and $12,$9,_CP0_CONFIG1_IA_MASK # iways = $12 (t4)
        srl $12,_CP0_CONFIG1_IA_POSITION
        addiu $12,$12,1
        move $10,$12                    # icachesize = iways

        /* total icache size = lines/way * linesize *ways */
        li $11,1                        # ilinesize = 1
        sll $11,$11,$8                  # ilinesize <<= tmp
        sll $10,$10,$8                  # icachesize <<= tmp

        /* get icache lines per way */
        and $8,$9,_CP0_CONFIG1_IS_MASK
        srl $8,_CP0_CONFIG1_IS_POSITION
        addiu $8,$8,6
        sll $10,$10,$8                  # icachesize <<= tmp

        /* Get dcache line size (log2) */
8:      and $8,$9,_CP0_CONFIG1_DL_MASK
        srl $8,_CP0_CONFIG1_DL_POSITION
        beqz $8,8f                      # no d-cache
        addiu $8,$8,1

        /* Get number of dcache ways */
        and $15,$9,_CP0_CONFIG1_DA_MASK # dways = $15 (t7)
        srl $15,_CP0_CONFIG1_DA_POSITION
        addiu $15,$15,1
        move $13,$15                    # dcachesize = dways

        /* Total dcache size = lines/way * linesize * ways */
        li $14,1                        # dlinesize = 1
        sll $14,$14,$8                  # dlinesize <<= tmp
        sll $13,$13,$8                  # dcachesize <<= tmp

        and $8,$9,_CP0_CONFIG1_DS_MASK
        srl $8,_CP0_CONFIG1_DS_POSITION
        addiu $8,$8,6
        sll $13,$13,$8                  # dcachesize <<= tmp

8:
9:      jr $31                          # ra = $31
        nop
        .size __size_cache,.-__size_cache
        .end __size_cache

/*
 * void __pic32_size_cache()
 *
 * Work out size of I & D caches (assume already initialized)
 */
        .section .cache_init.pic32_size_cache,"ax",@progbits
        .set nomips16
        .globl __pic32_size_cache
        .ent __pic32_size_cache

__pic32_size_cache:
        lw $8,__pic32_icache_size       # t0 = $8
        move $7,$31                     # a3 = $7, save_ra = $31
        bgtz $8,8f                      # already known?
        nop

        bal __size_cache
        nop
        move $31,$7                     # restore ra

..savesize:
        sw $10,__pic32_icache_size      # icachesize = $10
        sw $13,__pic32_dcache_size      # dcachesize = $13
        sw $11,__pic32_icache_linesize  # ilinesize = $11
        sw $14,__pic32_dcache_linesize  # dlinesize = $14
        sw $12,__pic32_icache_ways      # iways = $12
        sw $15,__pic32_dcache_ways      # dways = $15

8:      jr $31
        nop
        .size __pic32_size_cache,.-__pic32_size_cache
        .end __pic32_size_cache

/*
 * void __pic32_init_cache()
 *
 * Work out size and initialize I & D caches.
 */
        .section .cache_init.pic32_init_cache,"ax",@progbits
        .set nomips16
        .globl __pic32_init_cache
        .ent __pic32_init_cache
__pic32_init_cache:

        /* If the cache is enabled, then return. */
        mfc0 $8,_CP0_CONFIG             # Load the Config register (t0 = $8)
        li $9,_CP0_CONFIG_K0_MASK       # Load the K0 mask (t1 = $9)
        and $9,$8,$9                    # Get the K0 bits of the Config register
        xori $9,$9,_CACHE_DISABLE       # Check if equal to the disable value
        beqz $9,1f                      # If 0, then disabled. Jump over and continue
        nop
        jr $31                          # If not 0, return.
        nop

1:      move $3,$31                     # save_ra = v1 = $3
        bal __size_cache
        nop

        /* Run uncached */
        .set noreorder
        .set nomacro

        /*
         * The caches may be in an indeterminate state, so we force an
         * invalidate, load/fill, and invalidate for each line.
         */

        /* Disable all i/u and cache exceptions */
        .set macro
        .set noreorder
        # Disable interrupts and set UM=1
        # Save current status in tmp
        mfc0 $8,_CP0_STATUS
        li $9,~_CP0_STATUS_IE_MASK
        and $9,$8,$9
        or $9,$9,_CP0_STATUS_ERL_MASK
        mtc0 $9,_CP0_STATUS
        ehb

        mtc0 $0,_CP0_ERRCTL
        mtc0 $0,_CP0_TAGLO              # 4K taglo / 2*K itaglo
        ehb

        /* Initialize primary instruction cache */
        .set noreorder
4:      lui $4,%hi(__pic32_init_cache_program_base_addr)  # a0 = $4
        addiu $4,$4,%lo(__pic32_init_cache_program_base_addr)
        bne $4,$0,0f
        nop
        /* Use a default if the symbol is not defined */
        li $4,0x9D000000                # KSEG0_PROGRAM_BASE
0:      beqz $10,8f                     # icachesize = $10 (t2)
        nop
        addu $5,$4,$10                  # limit = base + icachesize (a1 = $5)
1:      cache Index_Store_Tag_I,-4($4)  # BDSLOT: clear tag
        addu $4,$4,$11                  # a0 += ilinesize ($11 = t3)
        bne $4,$5,1b
        nop

        /* Initialize primary data cache */
        .set noreorder
8:      lui $4,%hi(__pic32_init_cache_data_base_addr)
        addiu $4,$4,%lo(__pic32_init_cache_data_base_addr)
        bne $4,$0,0f
        nop
        /* Use a default if the symbol is not defined */
        li $4,0x80000000                # KSEG_DATA_BASE

0:      beqz $13,8f                     # dcachesize = $13 (t5)
        nop
        addu $5,$4,$13                  # limit = base + dcachesize
1:      cache Index_Store_Tag_D,-4($4)  # BDSLOT: clear tag
        addu $4,$4,$14                  # a0 += dlinesize ($14 = t6)
        bne $4,$5,1b
        nop

        .set reorder

8:      sync

        /* Store the sizes only after the caches are initialized */
4:      sw $10,__pic32_icache_size      # icachesize = $10
        sw $13,__pic32_dcache_size      # dcachesize = $13
        sw $11,__pic32_icache_linesize  # ilinesize = $11
        sw $14,__pic32_dcache_linesize  # dlinesize = $14
        sw $12,__pic32_icache_ways      # iways = $12
        sw $15,__pic32_dcache_ways      # dways = $15

        .set noreorder

        # restore status
        mtc0 $8,_CP0_STATUS
        ehb

        # Configure Cache Mode
        mfc0 $9, _CP0_CONFIG
        ori $9, $9, _CP0_CONFIG_K0_MASK
        xori $9, $9, _CP0_CONFIG_K0_MASK
        ori $9, $9, __PIC32_CACHE_MODE
        mtc0 $9, _CP0_CONFIG
        ehb

        .set reorder

        move $31, $3                    # restore ra from save_ra
        jr $31
        nop
        .size __pic32_init_cache,.-__pic32_init_cache
        .end __pic32_init_cache

#undef _CACHE_WRITEBACK_WRITEALLOCATE
#undef _CACHE_WRITETHROUGH_WRITEALLOCATE
#undef _CACHE_WRITETHROUGH_NOWRITEALLOCATE
#undef _CACHE_DISABLE

#undef _CP0_ERRCTL
#undef _CP0_TAGLO
