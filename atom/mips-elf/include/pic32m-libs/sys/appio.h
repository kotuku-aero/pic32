/*-------------------------------------------------------------------------
 * Copyright (c) 2025, Microchip Technology Inc. and its subsidiaries ("Microchip")
 * All rights reserved.
 * This software is developed by Microchip Technology Inc. and its
 * subsidiaries ("Microchip").
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------
 *             APPIN/APPOUT Debug Support API definitions
 *-------------------------------------------------------------------------*/
#include <xc.h>

#undef __DISCARD
#define __DISCARD __attribute__((weak,unique_section,noinline,nomips16))

#ifndef __APPIO_H
#ifdef __cplusplus
extern "C"
  {
#endif
#define __APPIO_H

#if defined(__LIBBUILD__)
#define __DEBUG
#endif

#if defined(_APPIO_DEBUG)
#define __APPIO_DEBUG
#endif

#if defined(__APPIO_DEBUG) && defined(PIC32_STARTER_KIT)
#error Cannot define both __APPIO_DEBUG and PIC32_STARTER_KIT simultanously
#endif

#if defined(__APPIO_DEBUG)
#define __ENABLEIO_APPIO_DEBUG
#include <string.h>
#include <stdio.h>
#endif

#if defined(PIC32_STARTER_KIT)
#define __ENABLEIO_STARTERKIT_DEBUG
#include <string.h>
#include <stdio.h>
#endif

/* Use APPIO and STARTERKIT_IO only for debug builds */
#if !defined(__DEBUG)
#undef __ENABLEIO_APPIO_DEBUG
#undef __ENABLEIO_STARTERKIT_DEBUG
#endif

#if defined(__ENABLEIO_APPIO_DEBUG)

/* Device-specific header file must be included before here */
#if !defined(__APPO) && !defined(__APPI)
#error Selected device does not support APPIO debugging.
#endif

#if defined (__APPO)
#define DBINIT() DBAPPIO_INIT()
#define DBAPPIO_INIT() (_appio_init(), \
  setvbuf(stdout,NULL,_IONBF,0), \
  setvbuf(stdin,NULL,_IOFBF,1))
extern void _appio_init(void);

#define DBPRINTF printf
#define DBPUTC _appio_putc
#define DBPUTWORD _appio_putword
  __asm__(" .pushsection .__pic32_sk_init, info \n"
           "  .equ __fake_appio_init, _appio_init \n"
           "  .popsection ");
    void __DISCARD __attribute__((nomips16,noinline)) _appio_putc (char c) {}
    void __DISCARD __attribute__((nomips16,noinline)) _mon_putc (char c) __attribute__((alias("_appio_putc")));
    extern void _appio_putword (unsigned int w);
    void __DISCARD __attribute__((nomips16,noinline)) _appio_write (const char * s, unsigned int count) {}
    void __DISCARD __attribute__((nomips16,noinline)) _mon_write (const char * s, unsigned int count) __attribute__((alias("_appio_write")));
#else
#define DBPRINTF(ignore,...) ((void)0)
#define DBPUTC(ignore)       ((void)0)
#define DBPUTWORD(ignore)    ((void)0)
#endif /* __APPO */

#if defined (__APPI)
#ifndef DBINIT
#define DBINIT() DBAPPIO_INIT()
#define DBAPPIO_INIT() (_appio_init(), \
  setvbuf(stdout,NULL,_IONBF,0), \
  setvbuf(stdin,NULL,_IOFBF,1))
#endif
#define DBSCANF scanf
#define DBGETC _appio_getc
#define DBGETS(s,len) _appio_gets(s, len)
#define DBGETWORD _appio_getword
    int __DISCARD _appio_getc (int canblock) {}
    int __DISCARD _mon_getc (int canblock) __attribute__((alias("_appio_getc")));
    extern unsigned int _appio_getword (int canblock);
#else
#define DBSCANF(ignore,...) ((void)0)
#define DBGETC(ignore)      ((void)0)
#define DBGETWORD(ignore)   ((void)0)
#endif /* __APPI */

    /* !__ENABLEIO_APPIO_DEBUG */
#else
#if defined(__ENABLEIO_STARTERKIT_DEBUG)
extern char __pic32mxsk_stdout_buf[256];
#define DBINIT()      (_pic32mxsk_init(), setvbuf (stdout, __pic32mxsk_stdout_buf, _IOLBF, sizeof(__pic32mxsk_stdout_buf)))
#define DBPUTC(c)     db_puts(c,1)
#define DBPUTS(s)     db_puts(s, strlen(s))
#define DBPRINTF      printf
/* scanf not supported in SK */
#define DBSCANF(ignore,...)       ((void)0)
#define DBGETS(s,len) db_gets(s, len)
#define DBGETC(c)     db_gets(c,1)

    /* Debug function prototypes */
    extern void _pic32mxsk_init (void);
   __asm__(" .pushsection .__pic32_sk_init, info \n"
	   "  .equ __fake_pic32mxsk_init, _pic32mxsk_init \n"
           "  .popsection ");
    void __DISCARD __attribute__ ((noinline,nomips16)) _p32mxsk_write (const char * s, unsigned int count) {}
    void __DISCARD __attribute__ ((noinline,nomips16)) _p32mxsk_putc (char c) {}
    int  __DISCARD __attribute__ ((noinline,nomips16)) _p32mxsk_getc (int canblock) {}

    extern void  __attribute__ ((noinline,nomips16)) db_puts (const unsigned char *s, int len);
    extern void  __attribute__ ((noinline,nomips16)) db_gets (unsigned char *s, int len);
    void __DISCARD __attribute__((nomips16,noinline)) _mon_write (const char * s, unsigned int count) __attribute__((alias("_p32mxsk_write")));
    void __DISCARD __attribute__((nomips16,noinline)) _mon_putc (char c) __attribute__((alias("_p32mxsk_putc")));
    int __DISCARD __attribute__((nomips16,noinline)) _mon_getc (int canblock) __attribute__((alias("_p32mxsk_getc")));

#else /* !(defined(__ENABLEIO_STARTERKIT_DEBUG)) */
#define DBINIT()                ((void)0)
#define DBPUTC(ignore)          ((void)0)
#define DBPUTS(ignore)          ((void)0)
#define DBPRINTF(ignore,...)    ((void)0)
#define DBSCANF(ignore,...)     ((void)0)
#define DBGETC(ignore)          ((void)0)
#define DBGETS(ignore,ignore2)  ((void)0)
#define DBAPPIO_INIT(ignore)    ((void)0)
#define DBGETWORD(ignore)       ((void)0)
#define DBPUTWORD(ignore)       ((void)0)
#endif
#endif /* __ENABLEIO_APPIO_DEBUG */

#ifdef __cplusplus
  }
#endif

#undef __DISCARD

#endif /* __APPIO_H */
