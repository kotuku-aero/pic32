#ifndef __atom_pic32_h__
#define __atom_pic32_h__

#ifdef __cplusplus
#error The atom support files should not be included directly
#endif

// get the processor hardware definitions
// if there is an error that the processor can't be found then it means
// the -D__PIC32MZ2048EFH064__ is not in the project makefile

// HACK... for testing only
#define __32MZ2048EFH064__

// only works if the include path to the archiecture is set.
#include <xc.h>

// include the kotuku interrupt handling definition.  Read the pic32_gcc_README on how to port
// microchip style interrupt handlers to the mips-elf build chain
#include "mips_irq.h"

// these definitions provide a simpler and easy to understand mechanism to
// handle config bits
#include "pic32mz_config.h"

#endif
