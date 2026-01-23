/*
 * _xxc0.sx: generic MIPS Coprocessor 0 support functions copied from
 * MTK/kit/share/mipscp0.sx with modifications to support Microchip
 * devices.
 */

/*	
 * These functions allow unoptimised or MIPS16 code to get access to
 * coprocessor registers.
 */

	.set	nomips16
	.set	mips32r2

/* unsigned _xxc0 (unsigned reg, unsigned clear, unsigned set) 
      cp0reg[REG] = (cp0reg[REG] & ~CLEAR) | SET
      returns previous value of register
      warning: not atomic in face of interrupts
*/

/* Constants for stack frame calculations */
#define NARGSAVE		4
#define SZARG			4
#define SZREG			4
#define ALSZ			7
#define ALMASK			(~7)
#define ARGSIZE			(NARGSAVE*SZARG)
#define TEMPLATESZ		40
#define LOCALSIZE		TEMPLATESZ
#define FRAMESIZE(nsave)	((ARGSIZE + LOCALSIZE + ((nsave)*SZREG) + ALSZ) & ALMASK)
#define SAVEOFF(n)		(ARGSIZE + LOCALSIZE + ((n)*SZREG))
#define MTC0_OFF		28

	.section .text.xxc0_template,"ax",@progbits
	.align	2
	.globl	.xxc0_template
	.hidden	.xxc0_template
	.type	.xxc0_template, @function
.xxc0_template:
	.set noreorder
	mfc0	$2,$0,0		#  0 (v0 = $2)
	ssnop			#  4
	ssnop			#  8
	and	$3,$2,$16	# 12 (v1 = $3, v0 = $2, s0 = $16)
	or	$3,$3,$17	# 16 (v1 = $3, s1 = $17)
	beq	$3,$2,9f	# 20
	nop			# 24
	mtc0	$3,$0,0		# 28
9:	jr.hb	$15		# 32 (t7 = $15)
	nop			# 36
	.set reorder
	.size	.xxc0_template, .-(.xxc0_template)

	.section .text._xxc0,"ax",@progbits
	.align	2
	.globl	_xxc0
	.type	_xxc0, @function
	.ent	_xxc0
_xxc0:
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-FRAMESIZE(3)
	sw	$16,SAVEOFF(0)($sp)
	sw	$17,SAVEOFF(1)($sp)
	sw	$31,SAVEOFF(2)($sp)
	
	nor	$16,$0,$5		# s0 = ~a1 (not is pseudo-op for nor with $0)
	move	$17,$6			# s1 = a2
	
	/* convert REGNO to the mfc0/mtc0 cop0 rd register and select fields */
	andi	$8,$4,0x1f		# t0 = a0 & 0x1f
	sll	$8,$8,11		# t0 <<= 11
	srl	$4,$4,5			# a0 >>= 5
	andi	$4,$4,7			# a0 &= 7
	or	$4,$4,$8		# a0 = a0 | t0
	
	/* copy the template to the stack */
	lui	$8,%hi(.xxc0_template)	# t0 = address of template (high)
	addiu	$8,$8,%lo(.xxc0_template) # t0 = address of template (low)
	addiu	$9,$8,TEMPLATESZ	# t1 = t0 + TEMPLATESZ
	addiu	$10,$sp,ARGSIZE		# t2 = sp + ARGSIZE
1:	lw	$11,0($8)		# t3 = *t0
	addiu	$8,$8,4			# t0 += 4
	sw	$11,0($10)		# *t2 = t3
	addiu	$10,$10,4		# t2 += 4
	bne	$8,$9,1b		# loop if t0 != t1
	nop
	
	/* patch the mfc0 & mtc0 instructions */
	addiu	$12,$sp,ARGSIZE		# t4 = sp + ARGSIZE
	addiu	$13,$12,MTC0_OFF	# t5 = t4 + MTC0_OFF
	lw	$10,0($12)		# t2 = *t4
	lw	$11,0($13)		# t3 = *t5
	or	$10,$10,$4		# t2 |= a0
	or	$11,$11,$4		# t3 |= a0
	sw	$10,0($12)		# *t4 = t2
	sw	$11,0($13)		# *t5 = t3
	
	/* do the work */
	addiu	$12,$sp,ARGSIZE		# t4 = sp + ARGSIZE
	jalr	$15,$12			# call through t7 to t4
	nop
	
	/* return */
	lw	$31,SAVEOFF(2)($sp)
	lw	$17,SAVEOFF(1)($sp)
	lw	$16,SAVEOFF(0)($sp)
	addiu	$sp,$sp,FRAMESIZE(3)
	jr	$31
	nop
	
	.set	macro
	.set	reorder
	.end	_xxc0
	.size	_xxc0, .-_xxc0
