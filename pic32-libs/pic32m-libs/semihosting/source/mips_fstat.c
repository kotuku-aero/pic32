/*
 * mips_fstat.c
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
#include <sys/stat.h>


typedef struct uhi_stat
{
    int16_t     uhi_st_dev;
    uint16_t    uhi_st_ino;
    uint32_t    uhi_st_mode;
    uint16_t    uhi_st_nlink;
    uint16_t    uhi_st_uid;
    uint16_t    uhi_st_gid;
    int16_t     uhi_st_rdev;
    uint64_t    uhi_st_size;
    uint64_t    uhi_st_atime;
    uint64_t    uhi_st_spare1;
    uint64_t    uhi_st_mtime;
    uint64_t    uhi_st_spare2;
    uint64_t    uhi_st_ctime;
    uint64_t    uhi_st_spare3;
    uint64_t    uhi_st_blksize;
    uint64_t    uhi_st_blocks;
    uint64_t    uhi_st_spare4[2];
} Mips_stat;



int
fstat(int fd, struct stat *restrict statbuf)
{
    Mips_stat mips_stat;
    /* copy the argument, so that it is not overwritten*/
    volatile struct stat *cpy_statbuf = statbuf; 

    register uintptr_t r_r0 asm("$4") = fd;
    register uintptr_t r_r1 asm("$5") = (uintptr_t) &mips_stat;
    register intptr_t ret1 asm("$2");
    register uintptr_t ret2 asm("$3");

    __asm__ __volatile__("li   $7, %0" : : "O" (MIPS_SEMIHOST_fstat));
    __asm__ __volatile__("move  $25, $7");

    __asm__ __volatile__ ("\tsdbbp 1" 
                            : "=r" (ret1) , "=r" (ret2)
                            : "r" (r_r0), "r" (r_r1)); 

    if (ret1 != 0)
        mips_semihost_errno(ret2);
    else
    {
        statbuf = cpy_statbuf;
        statbuf->st_dev = mips_stat.uhi_st_dev;
        statbuf->st_ino = mips_stat.uhi_st_ino;
        statbuf->st_mode = mips_stat.uhi_st_mode;
        statbuf->st_nlink = mips_stat.uhi_st_nlink;
        statbuf->st_uid = mips_stat.uhi_st_uid;
        statbuf->st_gid = mips_stat.uhi_st_gid;
        statbuf->st_rdev = mips_stat.uhi_st_rdev;
        statbuf->st_size = mips_stat.uhi_st_size;
        statbuf->st_blksize = mips_stat.uhi_st_blksize;
        statbuf->st_blocks = mips_stat.uhi_st_blocks;
        statbuf->st_atime = mips_stat.uhi_st_atime;
        statbuf->st_mtime = mips_stat.uhi_st_mtime;
        statbuf->st_ctime = mips_stat.uhi_st_ctime;        
    } 

    return ret1;
}
