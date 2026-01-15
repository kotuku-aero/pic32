#ifndef __pic32mz_config_h__
#define __pic32mz_config_h__

/*
 * PIC32MZ Configuration Bits Header
 * 
 * This header replaces #pragma config directives for vanilla GCC.
 * 
 * Usage:
 *   1. Include this header in ONE .c file per project
 *   2. Define your configuration using the macros below
 *   3. The linker script must have config_BFC0FFxx sections defined
 *
 * Example:
 *   #include "pic32mz_config.h"
 *   
 *   DEVCFG3_VALUE(
 *       DEVCFG3_USERID(0x0201) |
 *       DEVCFG3_FMIIEN_ON |
 *       DEVCFG3_FETHIO_ON |
 *       DEVCFG3_PGL1WAY_ON |
 *       DEVCFG3_PMDL1WAY_ON |
 *       DEVCFG3_IOL1WAY_ON |
 *       DEVCFG3_FUSBIDIO_OFF
 *   );
 */

#include <stdint.h>

/*===========================================================================
 * Section Placement Macros
 *===========================================================================*/

#define CONFIG_WORD(name, section_name, value) \
const uint32_t __attribute__((section(section_name), used)) \
__config_##name = (value)

/* Primary configuration words - lower boot alias */
#define DEVCFG0_VALUE(val)  CONFIG_WORD(devcfg0, ".config_BFC0FFCC", val)
#define DEVCFG1_VALUE(val)  CONFIG_WORD(devcfg1, ".config_BFC0FFC8", val)
#define DEVCFG2_VALUE(val)  CONFIG_WORD(devcfg2, ".config_BFC0FFC4", val)
#define DEVCFG3_VALUE(val)  CONFIG_WORD(devcfg3, ".config_BFC0FFC0", val)

/* Boot sequence */
#define BF1SEQ0_VALUE(val)  CONFIG_WORD(bf1seq0, ".config_BFC0FF40", val)

/* Alternate boot flash 1 configuration (if needed) */
#define ABF1_DEVCFG0_VALUE(val)  CONFIG_WORD(abf1_devcfg0, ".config_BFC2FFCC", val)
#define ABF1_DEVCFG1_VALUE(val)  CONFIG_WORD(abf1_devcfg1, ".config_BFC2FFC8", val)
#define ABF1_DEVCFG2_VALUE(val)  CONFIG_WORD(abf1_devcfg2, ".config_BFC2FFC4", val)
#define ABF1_DEVCFG3_VALUE(val)  CONFIG_WORD(abf1_devcfg3, ".config_BFC2FFC0", val)
/*===========================================================================
 * DEVCFG0 - Debug and Code Protection
 * Address: 0xBFC0FFCC
 *===========================================================================*/

/* DEBUG - Background Debugger Enable */
#define DEVCFG0_DEBUG_ON            (0 << 0)    /* Debugger enabled */
#define DEVCFG0_DEBUG_OFF           (3 << 0)    /* Debugger disabled */

/* JTAGEN - JTAG Enable */
#define DEVCFG0_JTAGEN_ON           (1 << 2)
#define DEVCFG0_JTAGEN_OFF          (0 << 2)

/* ICESEL - ICE Communication Channel Select */
#define DEVCFG0_ICESEL_ICS_PGx1     (3 << 3)
#define DEVCFG0_ICESEL_ICS_PGx2     (2 << 3)

/* TRCEN - Trace Enable */
#define DEVCFG0_TRCEN_ON            (1 << 5)
#define DEVCFG0_TRCEN_OFF           (0 << 5)

/* BOOTISA - Boot ISA Selection */
#define DEVCFG0_BOOTISA_MIPS32      (1 << 6)
#define DEVCFG0_BOOTISA_MICROMIPS   (0 << 6)

/* FECCCON - Flash ECC Control */
#define DEVCFG0_FECCCON_ON          (3 << 8)    /* ECC enabled */
#define DEVCFG0_FECCCON_DYNAMIC     (2 << 8)    /* Dynamic ECC */
#define DEVCFG0_FECCCON_OFF         (1 << 8)    /* ECC disabled, locked */

/* FSLEEP - Flash Sleep Mode */
#define DEVCFG0_FSLEEP_OFF          (1 << 10)
#define DEVCFG0_FSLEEP_ON           (0 << 10)

/* DBGPER - Debug Mode CPU Peripheral Access */
#define DEVCFG0_DBGPER_PG_ALL       (7 << 12)
#define DEVCFG0_DBGPER_PG_2_1       (3 << 12)
#define DEVCFG0_DBGPER_PG_1         (1 << 12)
#define DEVCFG0_DBGPER_DENY_ALL     (0 << 12)

/* SMCLR - Soft Master Clear Enable */
#define DEVCFG0_SMCLR_MCLR_NORM     (1 << 15)
#define DEVCFG0_SMCLR_MCLR_POR      (0 << 15)

/* SOSCGAIN - Secondary Oscillator Gain Control */
#define DEVCFG0_SOSCGAIN_0          (0 << 16)
#define DEVCFG0_SOSCGAIN_1          (1 << 16)
#define DEVCFG0_SOSCGAIN_2          (2 << 16)
#define DEVCFG0_SOSCGAIN_3          (3 << 16)

/* SOSCBOOST - Secondary Oscillator Boost */
#define DEVCFG0_SOSCBOOST_ON        (1 << 18)
#define DEVCFG0_SOSCBOOST_OFF       (0 << 18)

/* POSCGAIN - Primary Oscillator Gain Control */
#define DEVCFG0_POSCGAIN_0          (0 << 19)
#define DEVCFG0_POSCGAIN_1          (1 << 19)
#define DEVCFG0_POSCGAIN_2          (2 << 19)
#define DEVCFG0_POSCGAIN_3          (3 << 19)

/* POSCBOOST - Primary Oscillator Boost */
#define DEVCFG0_POSCBOOST_ON        (1 << 21)
#define DEVCFG0_POSCBOOST_OFF       (0 << 21)

/* EJTAGBEN - EJTAG Boot Enable */
#define DEVCFG0_EJTAGBEN_NORMAL     (1 << 24)
#define DEVCFG0_EJTAGBEN_REDUCED    (0 << 24)

/* CP - Code Protect */
#define DEVCFG0_CP_OFF              (1 << 28)
#define DEVCFG0_CP_ON               (0 << 28)

/* Unused bits should be set to 1 */
#define DEVCFG0_DEFAULT             0x7FFFFFFF

/*===========================================================================
 * DEVCFG1 - Oscillator and Watchdog
 * Address: 0xBFC0FFC8
 *===========================================================================*/

/* FNOSC - Oscillator Selection */
#define DEVCFG1_FNOSC_FRC           (0 << 0)    /* Fast RC Oscillator */
#define DEVCFG1_FNOSC_SPLL          (1 << 0)    /* System PLL */
#define DEVCFG1_FNOSC_POSC          (2 << 0)    /* Primary Oscillator */
#define DEVCFG1_FNOSC_SOSC          (4 << 0)    /* Secondary Oscillator */
#define DEVCFG1_FNOSC_LPRC          (5 << 0)    /* Low Power RC Oscillator */
#define DEVCFG1_FNOSC_FRCDIV        (7 << 0)    /* FRC with Divider */

/* DMTINTV - DMT Count Window Interval */
#define DEVCFG1_DMTINTV_WIN_127_128 (7 << 3)
#define DEVCFG1_DMTINTV_WIN_63_64   (6 << 3)
#define DEVCFG1_DMTINTV_WIN_31_32   (5 << 3)
#define DEVCFG1_DMTINTV_WIN_15_16   (4 << 3)
#define DEVCFG1_DMTINTV_WIN_7_8     (3 << 3)
#define DEVCFG1_DMTINTV_WIN_3_4     (2 << 3)
#define DEVCFG1_DMTINTV_WIN_1_2     (1 << 3)
#define DEVCFG1_DMTINTV_WIN_0       (0 << 3)

/* FSOSCEN - Secondary Oscillator Enable */
#define DEVCFG1_FSOSCEN_ON          (1 << 6)
#define DEVCFG1_FSOSCEN_OFF         (0 << 6)

/* IESO - Internal External Switchover */
#define DEVCFG1_IESO_ON             (1 << 7)
#define DEVCFG1_IESO_OFF            (0 << 7)

/* POSCMOD - Primary Oscillator Configuration */
#define DEVCFG1_POSCMOD_EC          (0 << 8)    /* External clock */
#define DEVCFG1_POSCMOD_HS          (2 << 8)    /* HS oscillator */
#define DEVCFG1_POSCMOD_OFF         (3 << 8)    /* Disabled */

/* OSCIOFNC - CLKO Output Enable */
#define DEVCFG1_OSCIOFNC_OFF        (1 << 10)   /* CLKO disabled */
#define DEVCFG1_OSCIOFNC_ON         (0 << 10)   /* CLKO enabled */

/* FCKSM - Clock Switching and Monitoring Selection */
#define DEVCFG1_FCKSM_CSECME        (0 << 14)   /* Both enabled */
#define DEVCFG1_FCKSM_CSECMD        (1 << 14)   /* Switching enabled, monitoring disabled */
#define DEVCFG1_FCKSM_CSDCMD        (3 << 14)   /* Both disabled */

/* WDTPS - Watchdog Timer Postscaler */
#define DEVCFG1_WDTPS_PS1           (0 << 16)
#define DEVCFG1_WDTPS_PS2           (1 << 16)
#define DEVCFG1_WDTPS_PS4           (2 << 16)
#define DEVCFG1_WDTPS_PS8           (3 << 16)
#define DEVCFG1_WDTPS_PS16          (4 << 16)
#define DEVCFG1_WDTPS_PS32          (5 << 16)
#define DEVCFG1_WDTPS_PS64          (6 << 16)
#define DEVCFG1_WDTPS_PS128         (7 << 16)
#define DEVCFG1_WDTPS_PS256         (8 << 16)
#define DEVCFG1_WDTPS_PS512         (9 << 16)
#define DEVCFG1_WDTPS_PS1024        (10 << 16)
#define DEVCFG1_WDTPS_PS2048        (11 << 16)
#define DEVCFG1_WDTPS_PS4096        (12 << 16)
#define DEVCFG1_WDTPS_PS8192        (13 << 16)
#define DEVCFG1_WDTPS_PS16384       (14 << 16)
#define DEVCFG1_WDTPS_PS32768       (15 << 16)
#define DEVCFG1_WDTPS_PS65536       (16 << 16)
#define DEVCFG1_WDTPS_PS131072      (17 << 16)
#define DEVCFG1_WDTPS_PS262144      (18 << 16)
#define DEVCFG1_WDTPS_PS524288      (19 << 16)
#define DEVCFG1_WDTPS_PS1048576     (20 << 16)

/* WDTSPGM - Watchdog Timer Stop During Flash Programming */
#define DEVCFG1_WDTSPGM_STOP        (1 << 21)
#define DEVCFG1_WDTSPGM_RUN         (0 << 21)

/* WINDIS - Watchdog Timer Window Mode */
#define DEVCFG1_WINDIS_NORMAL       (1 << 22)   /* Non-window mode */
#define DEVCFG1_WINDIS_WINDOW       (0 << 22)   /* Window mode */

/* FWDTEN - Watchdog Timer Enable */
#define DEVCFG1_FWDTEN_ON           (1 << 23)
#define DEVCFG1_FWDTEN_OFF          (0 << 23)

/* FWDTWINSZ - Watchdog Timer Window Size */
#define DEVCFG1_FWDTWINSZ_WINSZ_75  (0 << 24)
#define DEVCFG1_FWDTWINSZ_WINSZ_50  (1 << 24)
#define DEVCFG1_FWDTWINSZ_WINSZ_37  (2 << 24)
#define DEVCFG1_FWDTWINSZ_WINSZ_25  (3 << 24)

/* DMTCNT - Deadman Timer Count Select */
#define DEVCFG1_DMTCNT_DMT8         (0 << 26)
#define DEVCFG1_DMTCNT_DMT9         (1 << 26)
#define DEVCFG1_DMTCNT_DMT10        (2 << 26)
#define DEVCFG1_DMTCNT_DMT11        (3 << 26)
#define DEVCFG1_DMTCNT_DMT12        (4 << 26)
#define DEVCFG1_DMTCNT_DMT13        (5 << 26)
#define DEVCFG1_DMTCNT_DMT14        (6 << 26)
#define DEVCFG1_DMTCNT_DMT15        (7 << 26)
#define DEVCFG1_DMTCNT_DMT16        (8 << 26)
#define DEVCFG1_DMTCNT_DMT17        (9 << 26)
#define DEVCFG1_DMTCNT_DMT18        (10 << 26)
#define DEVCFG1_DMTCNT_DMT19        (11 << 26)
#define DEVCFG1_DMTCNT_DMT20        (12 << 26)
#define DEVCFG1_DMTCNT_DMT21        (13 << 26)
#define DEVCFG1_DMTCNT_DMT22        (14 << 26)
#define DEVCFG1_DMTCNT_DMT23        (15 << 26)
#define DEVCFG1_DMTCNT_DMT24        (16 << 26)
#define DEVCFG1_DMTCNT_DMT25        (17 << 26)
#define DEVCFG1_DMTCNT_DMT26        (18 << 26)
#define DEVCFG1_DMTCNT_DMT27        (19 << 26)
#define DEVCFG1_DMTCNT_DMT28        (20 << 26)
#define DEVCFG1_DMTCNT_DMT29        (21 << 26)
#define DEVCFG1_DMTCNT_DMT30        (22 << 26)
#define DEVCFG1_DMTCNT_DMT31        (23 << 26)

/* FDMTEN - Deadman Timer Enable */
#define DEVCFG1_FDMTEN_ON           (1 << 31)
#define DEVCFG1_FDMTEN_OFF          (0 << 31)

/* Unused bits should be set to 1 */
#define DEVCFG1_DEFAULT             0xFFFFFFFF

/*===========================================================================
 * DEVCFG2 - PLL Configuration
 * Address: 0xBFC0FFC4
 *===========================================================================*/

/* FPLLIDIV - PLL Input Divider */
#define DEVCFG2_FPLLIDIV_DIV_1      (0 << 0)
#define DEVCFG2_FPLLIDIV_DIV_2      (1 << 0)
#define DEVCFG2_FPLLIDIV_DIV_3      (2 << 0)
#define DEVCFG2_FPLLIDIV_DIV_4      (3 << 0)
#define DEVCFG2_FPLLIDIV_DIV_5      (4 << 0)
#define DEVCFG2_FPLLIDIV_DIV_6      (5 << 0)
#define DEVCFG2_FPLLIDIV_DIV_7      (6 << 0)
#define DEVCFG2_FPLLIDIV_DIV_8      (7 << 0)

/* FPLLRNG - PLL Input Frequency Range */
#define DEVCFG2_FPLLRNG_BYPASS      (0 << 4)
#define DEVCFG2_FPLLRNG_RANGE_5_10  (1 << 4)    /* 5-10 MHz */
#define DEVCFG2_FPLLRNG_RANGE_8_16  (2 << 4)    /* 8-16 MHz */
#define DEVCFG2_FPLLRNG_RANGE_13_26 (3 << 4)    /* 13-26 MHz */
#define DEVCFG2_FPLLRNG_RANGE_21_42 (4 << 4)    /* 21-42 MHz */
#define DEVCFG2_FPLLRNG_RANGE_34_64 (5 << 4)    /* 34-64 MHz */

/* FPLLICLK - PLL Input Clock Source */
#define DEVCFG2_FPLLICLK_PLL_FRC    (1 << 7)    /* FRC is PLL input */
#define DEVCFG2_FPLLICLK_PLL_POSC   (0 << 7)    /* POSC is PLL input */

/* FPLLMULT - PLL Multiplier (value + 1 = actual multiplier) */
#define DEVCFG2_FPLLMULT(n)         (((n) - 1) << 8)  /* n = 1 to 128 */
#define DEVCFG2_FPLLMULT_MUL_1      (0 << 8)
#define DEVCFG2_FPLLMULT_MUL_2      (1 << 8)
#define DEVCFG2_FPLLMULT_MUL_3      (2 << 8)
#define DEVCFG2_FPLLMULT_MUL_4      (3 << 8)
#define DEVCFG2_FPLLMULT_MUL_5      (4 << 8)
#define DEVCFG2_FPLLMULT_MUL_6      (5 << 8)
#define DEVCFG2_FPLLMULT_MUL_7      (6 << 8)
#define DEVCFG2_FPLLMULT_MUL_8      (7 << 8)
#define DEVCFG2_FPLLMULT_MUL_10     (9 << 8)
#define DEVCFG2_FPLLMULT_MUL_12     (11 << 8)
#define DEVCFG2_FPLLMULT_MUL_16     (15 << 8)
#define DEVCFG2_FPLLMULT_MUL_20     (19 << 8)
#define DEVCFG2_FPLLMULT_MUL_24     (23 << 8)
#define DEVCFG2_FPLLMULT_MUL_25     (24 << 8)
#define DEVCFG2_FPLLMULT_MUL_32     (31 << 8)
#define DEVCFG2_FPLLMULT_MUL_40     (39 << 8)
#define DEVCFG2_FPLLMULT_MUL_48     (47 << 8)
#define DEVCFG2_FPLLMULT_MUL_50     (49 << 8)
#define DEVCFG2_FPLLMULT_MUL_64     (63 << 8)
#define DEVCFG2_FPLLMULT_MUL_128    (127 << 8)

/* FPLLODIV - PLL Output Divider */
#define DEVCFG2_FPLLODIV_DIV_2      (1 << 16)
#define DEVCFG2_FPLLODIV_DIV_4      (2 << 16)
#define DEVCFG2_FPLLODIV_DIV_8      (3 << 16)
#define DEVCFG2_FPLLODIV_DIV_16     (4 << 16)
#define DEVCFG2_FPLLODIV_DIV_32     (5 << 16)

/* UPLLFSEL - USB PLL Input Frequency Selection */
#define DEVCFG2_UPLLFSEL_FREQ_24MHZ (1 << 30)
#define DEVCFG2_UPLLFSEL_FREQ_12MHZ (0 << 30)

/* Unused bits should be set to 1 */
#define DEVCFG2_DEFAULT             0xFFFFFFFF

/*===========================================================================
 * DEVCFG3 - User ID and Peripheral Configuration
 * Address: 0xBFC0FFC0
 *===========================================================================*/

/* USERID - User ID (16 bits) */
#define DEVCFG3_USERID(n)           ((n) & 0xFFFF)

/* FMIIEN - Ethernet MII Enable */
#define DEVCFG3_FMIIEN_ON           (1 << 24)   /* MII enabled */
#define DEVCFG3_FMIIEN_OFF          (0 << 24)   /* RMII enabled */

/* FETHIO - Ethernet I/O Pin Selection */
#define DEVCFG3_FETHIO_ON           (1 << 25)   /* Default pins */
#define DEVCFG3_FETHIO_OFF          (0 << 25)   /* Alternate pins */

/* PGL1WAY - Permission Group Lock One Way */
#define DEVCFG3_PGL1WAY_ON          (1 << 27)
#define DEVCFG3_PGL1WAY_OFF         (0 << 27)

/* PMDL1WAY - Peripheral Module Disable One Way */
#define DEVCFG3_PMDL1WAY_ON         (1 << 28)
#define DEVCFG3_PMDL1WAY_OFF        (0 << 28)

/* IOL1WAY - Peripheral Pin Select One Way */
#define DEVCFG3_IOL1WAY_ON          (1 << 29)
#define DEVCFG3_IOL1WAY_OFF         (0 << 29)

/* FUSBIDIO - USB ID I/O */
#define DEVCFG3_FUSBIDIO_ON         (1 << 30)   /* Controlled by USB */
#define DEVCFG3_FUSBIDIO_OFF        (0 << 30)   /* Controlled by port */

/* Unused bits should be set to 1 */
#define DEVCFG3_DEFAULT             0xFFFFFFFF

/*===========================================================================
 * BF1SEQ0 - Boot Flash 1 Sequence
 * Address: 0xBFC0FF40
 *===========================================================================*/

/* TSEQ - Boot Sequence Number */
#define BF1SEQ0_TSEQ(n)             ((n) & 0xFFFF)

/* CSEQ - Complement of Boot Sequence */
#define BF1SEQ0_CSEQ(n)             (((n) & 0xFFFF) << 16)

/*===========================================================================
 * Example Configuration Matching config_kedu.c
 *
 * To replicate your current #pragma config settings:
 *
 * DEVCFG0_VALUE(
 *     DEVCFG0_DEBUG_OFF |
 *     DEVCFG0_JTAGEN_OFF |
 *     DEVCFG0_ICESEL_ICS_PGx2 |
 *     DEVCFG0_TRCEN_OFF |
 *     DEVCFG0_BOOTISA_MIPS32 |
 *     DEVCFG0_FECCCON_ON |
 *     DEVCFG0_FSLEEP_OFF |
 *     DEVCFG0_DBGPER_PG_ALL |
 *     DEVCFG0_EJTAGBEN_NORMAL |
 *     DEVCFG0_CP_OFF |
 *     DEVCFG0_POSCBOOST_ON |
 *     DEVCFG0_POSCGAIN_0
 * );
 *
 * DEVCFG1_VALUE(
 *     DEVCFG1_FNOSC_SPLL |
 *     DEVCFG1_DMTINTV_WIN_127_128 |
 *     DEVCFG1_FSOSCEN_OFF |
 *     DEVCFG1_IESO_OFF |
 *     DEVCFG1_POSCMOD_HS |
 *     DEVCFG1_OSCIOFNC_OFF |
 *     DEVCFG1_FCKSM_CSDCMD |
 *     DEVCFG1_WDTPS_PS8 |
 *     DEVCFG1_WDTSPGM_STOP |
 *     DEVCFG1_FWDTEN_OFF |
 *     DEVCFG1_WINDIS_NORMAL |
 *     DEVCFG1_FWDTWINSZ_WINSZ_50 |
 *     DEVCFG1_DMTCNT_DMT31 |
 *     DEVCFG1_FDMTEN_OFF
 * );
 *
 * DEVCFG2_VALUE(
 *     DEVCFG2_FPLLIDIV_DIV_1 |
 *     DEVCFG2_FPLLRNG_RANGE_5_10 |
 *     DEVCFG2_FPLLICLK_PLL_POSC |
 *     DEVCFG2_FPLLMULT_MUL_50 |
 *     DEVCFG2_FPLLODIV_DIV_2 |
 *     DEVCFG2_UPLLFSEL_FREQ_24MHZ
 * );
 *
 * DEVCFG3_VALUE(
 *     DEVCFG3_USERID(0x0201) |
 *     DEVCFG3_FMIIEN_ON |
 *     DEVCFG3_FETHIO_ON |
 *     DEVCFG3_PGL1WAY_ON |
 *     DEVCFG3_PMDL1WAY_ON |
 *     DEVCFG3_IOL1WAY_ON |
 *     DEVCFG3_FUSBIDIO_OFF
 * );
 *
 * BF1SEQ0_VALUE(
 *     BF1SEQ0_TSEQ(0x0000) |
 *     BF1SEQ0_CSEQ(0xFFFF)
 * );
 *
 *===========================================================================*/

#endif /* __pic32mz_config_h__ */
