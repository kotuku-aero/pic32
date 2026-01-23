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
 *  Macros for L1 Cache management
 *-------------------------------------------------------------------------*/

#pragma once
#ifndef __SYS_L1CACHE_H
#define __SYS_L1CACHE_H

/* See also sys/kmem.h for other kseg translation macros */
#ifndef _XC_H
#include <xc.h>
#endif

#ifndef _STDLIB_H_
#include <stdlib.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__PIC32_HAS_L1CACHE)
/*  Access a KSEG0 Virtual Address variable as uncached (KSEG1) */
#  define __PIC32_UNCACHED_VAR(v) __PIC32_KVA0_TO_KVA1_VAR(v)
/*  Access a KSEG0 Virtual Address pointer as uncached (KSEG1) */
#  define __PIC32_UNCACHED_PTR(v) __PIC32_KVA0_TO_KVA1_PTR(v)
/*  Access a KSEG1 Virtual Address variable as cached (KSEG0) */
#  define __PIC32_CACHED_VAR(v) __PIC32_KVA1_TO_KVA0_VAR(v)
/*  Access a KSEG1 Virtual Address pointer as cached (KSEG0) */
#  define __PIC32_CACHED_PTR(v) __PIC32_KVA1_TO_KVA0_PTR(v)
#else
#  define __PIC32_UNCACHED_VAR(v) (v)
#  define __PIC32_UNCACHED_PTR(v) (v)
#  define __PIC32_CACHED_VAR(v) (v)
#  define __PIC32_CACHED_PTR(v) (v)
#endif

/* Helper macros used by those above. */

/*  Convert a KSEG0 Virtual Address variable or pointer to a KSEG1 virtual 
 *  address access.
 */
#  define __PIC32_KVA0_TO_KVA1_VAR(v) (*(__typeof__(v)*)((unsigned long)&(v) | 0x20000000u))
#  define __PIC32_KVA0_TO_KVA1_PTR(v) ((__typeof__(v)*)((unsigned long)(v) | 0x20000000u))
#  define __PIC32_KVA1_TO_KVA0_VAR(v) (*(__typeof__(v)*)((unsigned long)&(v) & ~0x20000000u))
#  define __PIC32_KVA1_TO_KVA0_PTR(v) ((__typeof__(v)*)((unsigned long)(v) & ~0x20000000u))
    
static __inline__ void * __pic32_alloc_coherent (size_t size)
{
  void *retptr;
  retptr = malloc (size);
  if (retptr == NULL) {
    return NULL;
  }
  /* malloc returns a cached pointer, but convert it to an uncached pointer */
  return __PIC32_UNCACHED_PTR (retptr);
}

static __inline__ void * __pic32_realloc_coherent (void *p, size_t size)
{
  void *retptr;
  retptr = realloc(p, size);
  if (retptr == NULL) {
    return NULL;
  }
  /* realloc returns a cached pointer, but convert it to an uncached pointer */
  return __PIC32_UNCACHED_PTR (retptr);  
}

static __inline__ void * __pic32_calloc_coherent  (size_t num, size_t size)
{
  void *retptr;
  retptr = calloc(num,size);
  if (retptr == NULL) {
    return NULL;
  }
  /* calloc returns a cached pointer, but convert it to an uncached pointer */
  return __PIC32_UNCACHED_PTR (retptr);  
}

static __inline__ void __pic32_free_coherent (void* ptr)
{
  /* Convert back to a cached pointer before calling free. */
  free (__PIC32_CACHED_PTR (ptr));
}

#ifdef __cplusplus
}
#endif

#endif /* __SYS_L1CACHE_H */
