/*
 * mips_semihost.h
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

#ifndef _MIPS_SEMIHOST_H_
#define _MIPS_SEMIHOST_H_

#include <stdint.h>

#define MIPS_SEMIHOST_exit      1
#define MIPS_SEMIHOST_open      2
#define MIPS_SEMIHOST_close     3
#define MIPS_SEMIHOST_read      4
#define MIPS_SEMIHOST_write     5
#define MIPS_SEMIHOST_lseek     6
#define MIPS_SEMIHOST_unlink    7
#define MIPS_SEMIHOST_fstat     8
#define MIPS_SEMIHOST_argc      9
#define MIPS_SEMIHOST_argnlen   10
#define MIPS_SEMIHOST_argn      11
#define MIPS_SEMIHOST_ramrange  12
#define MIPS_SEMIHOST_plog      13
#define MIPS_SEMIHOST_assert    14
#define MIPS_SEMIHOST_expt      15
#define MIPS_SEMIHOST_pread     19
#define MIPS_SEMIHOST_pwrite    20
#define MIPS_SEMIHOST_boot_fail 23




typedef enum {
    MIPS_ERR_EPERM = 1,         /* link, unlink */
    MIPS_ERR_ENOENT = 2,        /* link, unlink, open */
    MIPS_ERR_EINTR = 4,         /* open, close, read, write */
    MIPS_ERR_EIO = 5,           /* pwrite, open, close, fstat, pread, read, write */
    MIPS_ERR_ENXIO = 6,         /* open, pread, pwrite, read, write */
    MIPS_ERR_EBADF = 9,         /* pwrite, pread, close, lseek, fstat, read, write */
    MIPS_ERR_EAGAIN = 11,       /* pread, pwrite, read, write */ /*     MIPS_ERR_EWOULDBLOCK = 11,  - pread, pwrite - */
    MIPS_ERR_ENOMEM = 12,       /* open, pread, read */
    MIPS_ERR_EACCES = 13,       /* pwrite, link, unlink, open, write */
    MIPS_ERR_EBUSY = 16,        /* unlink */
    MIPS_ERR_EEXIST = 17,       /* link, open, */
    MIPS_ERR_EXDEV = 18,        /* link */    
    MIPS_ERR_ENOTDIR = 20,      /* link, unlink, open */
    MIPS_ERR_EISDIR = 21,       /* open, pread, read */
    MIPS_ERR_EINVAL = 22,       /* lseek, pread, pwrite, open, read */
    MIPS_ERR_ENFILE = 23,       /* open */
    MIPS_ERR_EMFILE = 24,       /* open */
    MIPS_ERR_ETXTBSY = 26,      /* unlink, open */
    MIPS_ERR_EFBIG = 27,        /* pwrite, read, write */
    MIPS_ERR_ENOSPC = 28,       /* pwrite, link, open, write */
    MIPS_ERR_ESPIPE = 29,       /* lseek, pread, pwrite, read */
    MIPS_ERR_EROFS = 30,        /* link, unlink, open */
    MIPS_ERR_EMLINK = 31,       /* link, */
    MIPS_ERR_EPIPE = 32,        /* pwrite, write, write */
    MIPS_ERR_ERANGE = 34,       /* pwrite, write */
    MIPS_ERR_ENOSR = 63,        /* open */
    MIPS_ERR_EBADMSG = 77,      /* pread, read */
    MIPS_ERR_ENAMETOOLONG = 91, /* link, unlink, open */
    MIPS_ERR_ELOOP = 92,        /* open, link, unlink */
    MIPS_ERR_ECONNRESET = 104,  /* pread, pwrite, read */
    MIPS_ERR_ENOBUFS = 105,     /* pread, pwrite, read, write */
    MIPS_ERR_ENETUNREACH = 114, /* pwrite, write */
    MIPS_ERR_ENETDOWN = 115,    /* pwrite, write */
    MIPS_ERR_ETIMEDOUT = 116,   /* pread, read */
    MIPS_ERR_ENOTCONN = 128,    /* pread, read */
    MIPS_ERR_EOVERFLOW = 139    /* open, lseek, fstat, pread, read */
} MipsSemihostErr;

void mips_semihost_errno(int def);

#endif /* _MIPS_SEMIHOST_H_ */
