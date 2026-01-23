// #include "xc.h"
#include <cp0defs.h>

    .section	.text
.Ltext0:
	.align	2
	.globl	__dinit_clear
	.set	nomips16
#if defined(__mips_micromips) || defined(__USE_MICROMIPS)
        .set micromips
#else
        .set nomicromips
#endif
	.ent	__dinit_clear
	.type	__dinit_clear, @function
__dinit_clear:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
    ################################################
    # this function has three parameters:
    # a0 ($4) - source buff - not used, added for similarity with the other functions
    # a1 ($5) - destination (memory)
    # a2 ($6) - length
    ################################################

__loop_dinit_clear:
    subu    $a2,$a2,1
    sb      $0,($a1)
    bne     $a2,$0,__loop_dinit_clear
    addu    $a1,$a1,1
    jr	$ra              # return to caller
    move	$v0,$a0


	.set	macro
	.set	reorder
	.end	__dinit_clear
.LFE0:
	.size	__dinit_clear, .-__dinit_clear
	.weak   __dinit_clear_needed
    __dinit_clear_needed = __dinit_clear
