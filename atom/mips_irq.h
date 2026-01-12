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

#define interrupt(name) \
__attribute__((naked, section(".vector" #name))) interrupt_##name (void) { \
  asm volatile( \
      ".set push              \n" \
      ".set noreorder         \n" \
      ".set noat              \n" \
      "addiu  $sp, $sp, -24   \n" \
      "mfc0   $k0, $14        \n" \
      "mfc0   $k1, $12        \n" \
      "sw     $k0, 0($sp)     \n" \
      "sw     $k1, 4($sp)     \n" \
      "sw     $ra, 8($sp)     \n" \
      "mfhi   $k0             \n" \
      "mflo   $k1             \n" \
      "sw     $k0, 12($sp)    \n" \
      "sw     $k1, 16($sp)    \n" \
      "jal    __interrupt_" ##name## "_impl  \n" \
      "nop                    \n" \
      "lw     $k1, 16($sp)    \n" \
      "lw     $k0, 12($sp)    \n" \
      "mtlo   $k1             \n" \
      "mthi   $k0             \n" \
      "lw     $ra, 8($sp)     \n" \
      "lw     $k1, 4($sp)     \n" \
      "lw     $k0, 0($sp)     \n" \
      "addiu  $sp, $sp, 24    \n" \
      "mtc0   $k1, $12        \n" \
      "mtc0   $k0, $14        \n" \
      "ehb                    \n" \
      "eret                   \n" \
      ".set pop               \n" \
  ); } \
void __interrupt_##name##_impl

#endif
