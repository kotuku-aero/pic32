/*	$OpenBSD: cdefs.h,v 1.2 1999/01/27 04:46:04 imp Exp $	*/
/*	$NetBSD: cdefs.h,v 1.3 1995/05/03 06:04:54 mellon Exp $	*/

/*
 * Copyright (c) 1995 Carnegie-Mellon University.
 * All rights reserved.
 *
 * Author: Chris G. Demetriou
 * 
 * Permission to use, copy, modify and distribute this software and
 * its documentation is hereby granted, provided that both the copyright
 * notice and this permission notice appear in all copies of the
 * software, derivative works or modified versions, and any portions
 * thereof, and that both notices appear in supporting documentation.
 * 
 * CARNEGIE MELLON ALLOWS FREE USE OF THIS SOFTWARE IN ITS "AS IS" 
 * CONDITION.  CARNEGIE MELLON DISCLAIMS ANY LIABILITY OF ANY KIND 
 * FOR ANY DAMAGES WHATSOEVER RESULTING FROM THE USE OF THIS SOFTWARE.
 * 
 * Carnegie Mellon requests users of this software to return to
 *
 *  Software Distribution Coordinator  or  Software.Distribution@CS.CMU.EDU
 *  School of Computer Science
 *  Carnegie Mellon University
 *  Pittsburgh PA 15213-3890
 *
 * any improvements or extensions that they make and grant Carnegie the
 * rights to redistribute these changes.
 */

#ifndef _MIPS_CDEFS_H_
#define	_MIPS_CDEFS_H_

#define	_C_LABEL(x)	_STRING(x)

/* We don't support indirect references */
/*#define	__indr_reference(sym,alias)*/

#ifdef __STDC__

#define __weak_alias(alias,sym)                         		\
    __asm__(".weakext " #alias "; " #alias "= " __STRING(sym))
#define	__warn_references(sym,msg)					\
    __asm__(".section .gnu.warning." #sym " ; .ascii \"" msg "\" ; .previous")

#else

#define __weak_alias(alias,sym)                         		\
    __asm__(".weakext alias ; alias = sym")
#define	__warn_references(sym,msg)					\
    __asm__(".section .gnu.warning.sym ; .ascii msg ; .previous")

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

#endif /* !_MIPS_CDEFS_H_ */
