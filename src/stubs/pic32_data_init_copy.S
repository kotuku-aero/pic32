// #include "xc.h"
#include <cp0defs.h>

    .section	.text
.Ltext0:
	.align	2
	.globl	__dinit_copy
	.set	nomips16
#if defined(__mips_micromips) || defined(__USE_MICROMIPS)
        .set micromips
#else
        .set nomicromips
#endif
	.ent	__dinit_copy
	.type	__dinit_copy, @function
__dinit_copy:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
    ################################################
    # this function has three parameters:
    # a0 ($4) - source buffer (.dinit section)
    # a1 ($5) - destination (memory)
    # a2 ($6) - length
    ################################################

__loop_dinit_copy:
    lbu     $t4,0($a0)
    subu    $a2,$a2,1
    addu    $a0,$a0,1
    sb      $t4,0($a1)
    bne     $a2,$0,__loop_dinit_copy
    addu    $a1,$a1,1
    jr      $ra              # return to caller
    move	$v0,$a0

	.set	macro
	.set	reorder
	.end	__dinit_copy
.LFE0:
	.size	__dinit_copy, .-__dinit_copy
	.weak   __dinit_copy_needed
    __dinit_copy_needed = __dinit_copy
