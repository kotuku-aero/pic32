#ifndef __atom_pic32_h__
#define __atom_pic32_h__

#ifdef __cplusplus
#error The atom support files should not be included directly
#endif

#ifdef DEBUG
#undef DEBUG
#define RESTART_DEBUG
#endif

/* Now include the actual platform headers */
#ifndef __ASSEMBLER__

// get the processor hardware definitions
// if there is an error that the processor can't be found then it means
// the -D__PIC32MZ2048EFH064__ is not in the project makefile

// only works if the include path to the archiecture is set.

#ifdef DEBUG
#undef DEBUG
#define DEBUG_HIDDEN
#endif

#include <xc.h>

#ifdef DEBUG_HIDDEN
#define DEBUG
#undef DEBUG_HIDDEN
#endif

#endif

#ifdef RESTART_DEBUG
#define DEBUG
#endif

// include the kotuku interrupt handling definition.  Read the pic32_gcc_README on how to port
// microchip style interrupt handlers to the mips-elf build chain
#include "mips_irq.h"

// these definitions provide a simpler and easy to understand mechanism to
// handle config bits
#include "pic32mz_config.h"

/* Read from CP0 register */
#define _atom_mfc0(reg, sel) \
__extension__ ({ \
uint32_t __result; \
__asm__ __volatile__ ( \
"mfc0 %0, $" #reg ", " #sel \
: "=r" (__result) \
); \
__result; \
})

/* Write to CP0 register */
#define _atom_mtc0(reg, sel, val) \
do { \
__asm__ __volatile__ ( \
"mtc0 %0, $" #reg ", " #sel \
: \
: "r" ((uint32_t)(val)) \
: "memory" \
); \
} while (0)

/* Common CP0 registers for PIC32MZ */
#define _CP0_EPC        14
#define _CP0_EPC_SELECT 0

#define _CP0_CAUSE        13
#define _CP0_CAUSE_SELECT 0

#define _CP0_BADVADDR        8
#define _CP0_BADVADDR_SELECT 0

#define _CP0_STATUS        12
#define _CP0_STATUS_SELECT 0

#define _CP0_COUNT        9
#define _CP0_COUNT_SELECT 0

#define _CP0_COMPARE        11
#define _CP0_COMPARE_SELECT 0

/* Compatibility macros */
#define __builtin_mfc0(reg, sel) _atom_mfc0(reg, sel)
#define __builtin_mtc0(reg, sel, val) _atom_mtc0(reg, sel, val)

// Place in uncached/coherent memory section
#define __coherent __attribute__((section(".coherent")))

#endif
