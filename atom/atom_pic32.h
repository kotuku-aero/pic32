#ifndef __atom_pic32_h__
#define __atom_pic32_h__

#ifdef __cplusplus
#error The atom support files should not be included directly
#endif
/* Fix missing BSD macros in newlib for GCC 15 */
#ifndef __pure
#define __pure __attribute__((__pure__))
#endif

#ifndef __pure2
#define __pure2 __attribute__((__const__))
#endif

#ifndef __dead2
#define __dead2 __attribute__((__noreturn__))
#endif

#ifndef __unused
#define __unused __attribute__((__unused__))
#endif

#ifndef __malloc_like
#define __malloc_like __attribute__((__malloc__))
#endif

#ifndef __result_use_check
#define __result_use_check __attribute__((__warn_unused_result__))
#endif

#ifndef __alloc_size
#define __alloc_size(x) __attribute__((__alloc_size__(x)))
#endif

#ifndef __alloc_size2
#define __alloc_size2(n, m) __attribute__((__alloc_size__(n, m)))
#endif

#ifndef __returns_twice
#define __returns_twice __attribute__((__returns_twice__))
#endif

#ifndef __nonnull
#define __nonnull(params) __attribute__((__nonnull__ params))
#endif
#ifndef __ASMNAME
#define __ASMNAME(cname) __XSTRING(cname)
#endif

#ifndef __XSTRING
#define __XSTRING(x) __STRING(x)
#endif

#ifndef __STRING
#define __STRING(x) #x
#endif

#ifndef __alloc_align
#define __alloc_align(x) __attribute__((__alloc_align__(x)))
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
#include <xc.h>
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
