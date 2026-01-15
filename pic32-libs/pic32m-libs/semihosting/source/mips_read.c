/*
 * mips_read.c
 *
 * Copyright (c) 2025 Microchip Technology Inc. and its subsidiaries.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
#include "mips_semihost.h"
#include <unistd.h>

ssize_t
read(int fd, void *buf, size_t count)
{
    register volatile uintptr_t r_r0 asm("$4") = fd;
    register volatile uintptr_t r_r1 asm("$5") = (uintptr_t) buf;
    register volatile uintptr_t r_r2 asm("$6") = count;

    register intptr_t ret1 asm("$2");
    register uintptr_t ret2 asm("$3");


    /*
     * waiting for input
     */
    do {
        __asm__ __volatile__("li   $7, %0" : : "O" (MIPS_SEMIHOST_read));
        __asm__ __volatile__("move $25, $7");

        __asm__ __volatile__("\tsdbbp 1"
                : "=r" (ret1), "=r" (ret2)
                : "r" (r_r0) , "r" (r_r1), "r" (r_r2)); 

    } while ((ret1 < 0) && (fd == 0));

    if (ret1 == -1)
            mips_semihost_errno(ret2);               

    return ret1;
}
