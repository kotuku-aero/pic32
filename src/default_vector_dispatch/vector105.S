	.weak __vector_dispatch_105
	.section .vector_105, "ax"
	.align	2
	.set	nomips16
	.ent	__vector_dispatch_105
__vector_dispatch_105:
#ifdef __PIC__
	lw	$25,%call16(_DefaultInterrupt)($28)
	jr	$25
	nop
#else
	j	_DefaultInterrupt
#endif
	.end	__vector_dispatch_105
	.size	__vector_dispatch_105, .-__vector_dispatch_105

