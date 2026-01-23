/*-------------------------------------------------------------------------
 *
 * Copyright (c) 2022, Microchip Technology Inc. and its subsidiaries ("Microchip")
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

    /* ISA mode selection */
    .set     nomips16
#if defined(__mips_micromips) || defined(__USE_MICROMIPS)
    .set     micromips
#else
    .set     nomicromips
#endif

    .section .text.dinit.startup,"ax",@progbits
    .align   2
    .globl   __pic32_data_init

    .set     noreorder
    .set     noat

    .ent     __pic32_data_init
    .type    __pic32_data_init, @function

__pic32_data_init:
        move    $3,$31                  # v1 = ra (save return address)
        
        ##################################################################
        # Call data initialization implementation (if function exists)
        ##################################################################
        .weak __pic32_data_init_impl
        lui     $8,%hi(__pic32_data_init_impl)  # t0 = $8
        addiu   $8,$8,%lo(__pic32_data_init_impl)
        beqz    $8,_skip_data_init
        nop
        jalr    $8
        nop
_skip_data_init:
        move    $31,$3                  # ra = v1 (restore return address)
        jr      $31
        nop
        
    .set      macro
    .set      reorder
    .end      __pic32_data_init
    .size     __pic32_data_init, .-__pic32_data_init
