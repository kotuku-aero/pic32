/*
 * .dinit decompression decode
 *
 * Copyright (c) 2022 Microchip Technology Inc. and its subsidiaries.
 *
 * Subject to your compliance with these terms, you may use Microchip software and any derivatives
 * exclusively with Microchip products. It is your responsibility to comply with third party license
 * terms applicable to your use of third party software (including open source software) that may
 * accompany Microchip software.
 *
 * THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY,
 * APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND
 * FITNESS FOR A PARTICULAR PURPOSE.
 *
 * IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL
 * LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF
 * MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE FULLEST EXTENT
 * ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN ANY WAY RELATED TO THIS SOFTWARE WILL NOT
 * EXCEED THE AMOUNT OF FEES, IF ANY, THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
 *
 */
	
// #include "xc.h"
#include <cp0defs.h>
    
    .section	.text
.Ltext0:
	.align	2
	.globl	__dinit_decompress
	.set	nomips16
#if defined(__mips_micromips) || defined(__USE_MICROMIPS)
        .set micromips
#else
        .set nomicromips
#endif
	.ent	__dinit_decompress
	.type	__dinit_decompress, @function
__dinit_decompress:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
    ################################################
    # this function has three parameters:
    # a0 ($4) - source buffer (.dinit section which should be decompressed)
    # a1 ($5) - destination 
    # a2 ($6) - size of decompressed data
    ################################################
        move	$v0,$a0	 # copy $4 into $2 -> prepare return value
        move	$t6,$0	 # initialize the outer loop counter (i) with 0
.L2:
 #   for (i = 0; i < length;)
	slt	$a0,$t6,$a2	 # set register $4 if $3 < $6 (i < length)

#if defined(__mips_micromips) || defined(__USE_MICROMIPS)
	bnezc	$a0,.L6
#else
	bnel	$a0,$0,.L6	 # branch to L6 if $4 is set
	lbu	$a0,0($v0)	 # load from SRC only if the previous branch is taken!
#endif

	jr	$ra              # return to caller
	nop

.L6:
#if defined(__mips_micromips) || defined(__USE_MICROMIPS)
	lbu	$a0, 0($v0)	 # _1, *buf
	beqzc	$a0, .L7
#else
	beql	$a0, $0,.L3	 # if the value found is zero, the next byte is
				 # the number of zero which should be copied
	move	$a0, $0		 #
#endif

	sb	$a0,0($a1)	 # copy to destination
	addiu	$v0,$v0,1		 # increment source address
	addiu	$t6,$t6,1		 # increment outer loop counter
	b	.L2
	addiu	$a1,$a1,1		 # increment destination

.L5:
	sb	$0,0($a1)	 # copy 0
	addiu	$a0,$a0,1		 # increment inner loop counter
	addiu	$a1,$a1,1		 # increment dst
.L3:
	lbu	$a3,1($v0)	 # load next byte, it should contain the nb of zeros
	slt	$a3,$a0,$a3	 # if $4 < $7, $7 = 1
	bne	$a3,$0,.L5	 # if $7 == 1 jump to L5
	addu	$t7,$a0,$t6	 # t7 = i + j -> to check !!!!!

	addiu	$v0,$v0,2	 # increment source
	b	.L2	 #
	move	$t6,$t7	 # set the new value of i (outer loop counter)

.L7:
	b	.L3	 #
	move	$a0,$0	 # j,
	
	.set	macro
	.set	reorder
	.end	__dinit_decompress
.LFE0:
	.size	__dinit_decompress, .-__dinit_decompress
	.weak   __dinit_decompress_needed
    __dinit_decompress_needed = __dinit_decompress