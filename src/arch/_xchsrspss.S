/*
 * _xchsrspss.sx: Generic operations on PSS field in the SRSCTL register.
 * Copied out of MTK/kit/share/mipscp0.sx with modifications to support
 * Microchip specifics.
 */

	
/*	
 * These functions allow unoptimised or MIPS16 code to get access to
 * coprocessor registers.
 */
	
#include <cp0defs.h>
#include <sys/asm.h>

	.set	nomips16
	.set	mips32r2
	
/* unsigned _xchsrspss (unsigned set) 
      SRSCTL<PSS> = SET
      returns previous value of PSS field
*/

LEAF(_xchsrspss)
	.set noreorder
	mfc0	$8,$12,2	/* t0 = SRSCTL (CP0 reg 12, sel 2) */
	ext	$2,$8,6,4	/* v0 = extract PSS field (bits 6-9) */
	ins	$8,$4,6,4	/* insert a0 into t0 PSS field */
	mtc0	$8,$12,2	/* SRSCTL = t0 */
	jr.hb	$31		/* return with hazard barrier */
	 ehb			/* execution hazard barrier (delay slot) */	
	.set reorder
END(_xchsrspss)

