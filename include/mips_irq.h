#ifndef __mips_irq_h__
#define __mips_irq_h__

/* This file implements decorations for code compiled using the mips-elf chain
 * and implements non-nested interrupts using the secondary register sets
 *
 * This macro is designed to use the interrupt names that match the section names
 * so for example to handle an interrupt for _I2C1_MASTER_VECTOR
 *
 * void interrupt(_I2C1_MASTER_VECTOR)
 *   {
 *   // code to handle _I2C1_MASTER_VECTOR.  Note that no floating point operations
 *   // are allowed and only interrupt safe system calls are allowed
 *   }
 */

#define interrupt_handler(vector) \
__attribute__((section(".vector_" #vector))) \
__vector_dispatch_##vector(void) { \
__asm__ __volatile__ ( \
".set push\n" \
".set noreorder\n" \
"j __isr_impl_" #vector "\n" \
"nop\n" \
".set pop\n" \
); \
} \
__attribute__((interrupt, keep_interrupts_masked)) \
void __isr_impl_##vector (void)

#endif
