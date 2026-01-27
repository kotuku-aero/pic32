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

#include <xc.h>
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
        mfc0 t1,_CP0_CONFIG             # cfg = t1 (t1)

        li t2,0                        # icachesize = t2 (t2)
        li t3,0                        # ilinesize = t3 (t3)
        li t5,0                        # dcachesize = t5 (t5)
        li t6,0                        # dlinesize = t6 (t6)

        /* Check that we have Config1 */
        and t0,t1,_CP0_CONFIG_M_MASK    # tmp = t0 (t0)
        mfc0 t1,_CP0_CONFIG1            # cfg = t1
        beqz t0,9f
        nop

        /* Get icache line size (log2) */
        and t0,t1,_CP0_CONFIG1_IL_MASK
        srl t0,_CP0_CONFIG1_IL_POSITION
        beqz t0,8f                      # no i-cache
        addiu t0,t0,1

        /* Get number of icache ways */
        and t4,t1,_CP0_CONFIG1_IA_MASK # iways = t4 (t4)
        srl t4,_CP0_CONFIG1_IA_POSITION
        addiu t4,t4,1
        move t2,t4                    # icachesize = iways

        /* total icache size = lines/way * linesize *ways */
        li t3,1                        # ilinesize = 1
        sll t3,t3,t0                  # ilinesize <<= tmp
        sll t2,t2,t0                  # icachesize <<= tmp

        /* get icache lines per way */
        and t0,t1,_CP0_CONFIG1_IS_MASK
        srl t0,_CP0_CONFIG1_IS_POSITION
        addiu t0,t0,6
        sll t2,t2,t0                  # icachesize <<= tmp

        /* Get dcache line size (log2) */
8:      and t0,t1,_CP0_CONFIG1_DL_MASK
        srl t0,_CP0_CONFIG1_DL_POSITION
        beqz t0,8f                      # no d-cache
        addiu t0,t0,1

        /* Get number of dcache ways */
        and t7,t1,_CP0_CONFIG1_DA_MASK # dways = t7 (t7)
        srl t7,_CP0_CONFIG1_DA_POSITION
        addiu t7,t7,1
        move t5,t7                    # dcachesize = dways

        /* Total dcache size = lines/way * linesize * ways */
        li t6,1                        # dlinesize = 1
        sll t6,t6,t0                  # dlinesize <<= tmp
        sll t5,t5,t0                  # dcachesize <<= tmp

        and t0,t1,_CP0_CONFIG1_DS_MASK
        srl t0,_CP0_CONFIG1_DS_POSITION
        addiu t0,t0,6
        sll t5,t5,t0                  # dcachesize <<= tmp

8:
9:      jr ra                          # ra = ra
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
        lw t0,__pic32_icache_size       # t0 = t0
        move a3,ra                     # a3 = a3, save_ra = ra
        bgtz t0,8f                      # already known?
        nop

        bal __size_cache
        nop
        move ra,a3                     # restore ra

..savesize:
        sw t2,__pic32_icache_size      # icachesize = t2
        sw t5,__pic32_dcache_size      # dcachesize = t5
        sw t3,__pic32_icache_linesize  # ilinesize = t3
        sw t6,__pic32_dcache_linesize  # dlinesize = t6
        sw t4,__pic32_icache_ways      # iways = t4
        sw t7,__pic32_dcache_ways      # dways = t7

8:      jr ra
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
        mfc0 t0,_CP0_CONFIG             # Load the Config register (t0 = t0)
        li t1,_CP0_CONFIG_K0_MASK       # Load the K0 mask (t1 = t1)
        and t1,t0,t1                    # Get the K0 bits of the Config register
        xori t1,t1,_CACHE_DISABLE       # Check if equal to the disable value
        beqz t1,1f                      # If 0, then disabled. Jump over and continue
        nop
        jr ra                          # If not 0, return.
        nop

1:      move $3,ra                     # save_ra = v1 = $3
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
        mfc0 t0,_CP0_STATUS
        li t1,~_CP0_STATUS_IE_MASK
        and t1,t0,t1
        or t1,t1,_CP0_STATUS_ERL_MASK
        mtc0 t1,_CP0_STATUS
        ehb

        mtc0 $0,_CP0_ERRCTL
        mtc0 $0,_CP0_TAGLO              # 4K taglo / 2*K itaglo
        ehb

        /* Initialize primary instruction cache */
        .set noreorder
4:      lui a0,%hi(__pic32_init_cache_program_base_addr)  # a0 = a0
        addiu a0,a0,%lo(__pic32_init_cache_program_base_addr)
        bne a0,$0,0f
        nop
        /* Use a default if the symbol is not defined */
        li a0,0x9D000000                # KSEG0_PROGRAM_BASE
0:      beqz t2,8f                     # icachesize = t2 (t2)
        nop
        addu a1,a0,t2                  # limit = base + icachesize (a1 = a1)
1:      cache Index_Store_Tag_I,-4(a0)  # BDSLOT: clear tag
        addu a0,a0,t3                  # a0 += ilinesize (t3 = t3)
        bne a0,a1,1b
        nop

        /* Initialize primary data cache */
        .set noreorder
8:      lui a0,%hi(__pic32_init_cache_data_base_addr)
        addiu a0,a0,%lo(__pic32_init_cache_data_base_addr)
        bne a0,$0,0f
        nop
        /* Use a default if the symbol is not defined */
        li a0,0x80000000                # KSEG_DATA_BASE

0:      beqz t5,8f                     # dcachesize = t5 (t5)
        nop
        addu a1,a0,t5                  # limit = base + dcachesize
1:      cache Index_Store_Tag_D,-4(a0)  # BDSLOT: clear tag
        addu a0,a0,t6                  # a0 += dlinesize (t6 = t6)
        bne a0,a1,1b
        nop

        .set reorder

8:      sync

        /* Store the sizes only after the caches are initialized */
4:      sw t2,__pic32_icache_size      # icachesize = t2
        sw t5,__pic32_dcache_size      # dcachesize = t5
        sw t3,__pic32_icache_linesize  # ilinesize = t3
        sw t6,__pic32_dcache_linesize  # dlinesize = t6
        sw t4,__pic32_icache_ways      # iways = t4
        sw t7,__pic32_dcache_ways      # dways = t7

        .set noreorder

        # restore status
        mtc0 t0,_CP0_STATUS
        ehb

        # Configure Cache Mode
        mfc0 t1, _CP0_CONFIG
        ori t1, t1, _CP0_CONFIG_K0_MASK
        xori t1, t1, _CP0_CONFIG_K0_MASK
        ori t1, t1, __PIC32_CACHE_MODE
        mtc0 t1, _CP0_CONFIG
        ehb

        .set reorder

        move ra, $3                    # restore ra from save_ra
        jr ra
        nop
        .size __pic32_init_cache,.-__pic32_init_cache
        .end __pic32_init_cache

#undef _CACHE_WRITEBACK_WRITEALLOCATE
#undef _CACHE_WRITETHROUGH_WRITEALLOCATE
#undef _CACHE_WRITETHROUGH_NOWRITEALLOCATE
#undef _CACHE_DISABLE

#undef _CP0_ERRCTL
#undef _CP0_TAGLO
