#
# init_interrupt_stacks.S
#
# Call this early in startup, before enabling interrupts
#

#include "cp0defs.h"

    .set noreorder
    .set noat

    .extern ipl4_stack
    .extern ipl5_stack
    .extern ipl6_stack

    .section .text.init_interrupt_stacks, "ax", @progbits
    .global init_interrupt_stacks
    .ent    init_interrupt_stacks

init_interrupt_stacks:
    # Save return address
    move    $t9, $ra

    # ---- Initialize Shadow Set 4 (for IPL4) ----
    mfc0    $t0, $12, 2             # SRSCtl
    li      $t1, 4
    ins     $t0, $t1, 6, 4          # PSS = 4
    mtc0    $t0, $12, 2
    ehb

    la      $t0, ipl4_stack
    addiu   $t0, $t0, (INT_STACK_SIZE * 4)  # Point to top of stack
    wrpgpr  $sp, $t0
    wrpgpr  $fp, $t0

    # ---- Initialize Shadow Set 5 (for IPL5) ----
    mfc0    $t0, $12, 2             # SRSCtl
    li      $t1, 5
    ins     $t0, $t1, 6, 4          # PSS = 5
    mtc0    $t0, $12, 2
    ehb

    la      $t0, ipl5_stack
    addiu   $t0, $t0, (INT_STACK_SIZE * 4)
    wrpgpr  $sp, $t0
    wrpgpr  $fp, $t0

    # ---- Initialize Shadow Set 6 (for IPL6) ----
    mfc0    $t0, $12, 2             # SRSCtl
    li      $t1, 6
    ins     $t0, $t1, 6, 4          # PSS = 6
    mtc0    $t0, $12, 2
    ehb

    la      $t0, ipl6_stack
    addiu   $t0, $t0, (INT_STACK_SIZE * 4)
    wrpgpr  $sp, $t0
    wrpgpr  $fp, $t0

    # ---- Restore SRSCtl.PSS to 0 (normal state) ----
    mfc0    $t0, $12, 2
    ins     $t0, $zero, 6, 4        # PSS = 0
    mtc0    $t0, $12, 2
    ehb

    # ---- Set PRISS = 0x06540000 ----
    # Maps IPL4->set4, IPL5->set5, IPL6->set6
    lui     $t0, 0xBF81
    lui     $t1, 0x0654
    sw      $t1, 0x0110($t0)

    jr      $t9
    nop

    .end    init_interrupt_stacks
