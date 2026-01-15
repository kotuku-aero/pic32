/*
 * mips_errno.c
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

extern int errno;

void
mips_semihost_errno(int def)
{
    MipsSemihostErr err = (MipsSemihostErr)def;

    switch (err) {
        case MIPS_ERR_EPERM: 
        case MIPS_ERR_ENOENT:
        case MIPS_ERR_EINTR:
        case MIPS_ERR_EIO:
        case MIPS_ERR_ENXIO:
        case MIPS_ERR_EBADF:
        case MIPS_ERR_EAGAIN: 
        case MIPS_ERR_ENOMEM:
        case MIPS_ERR_EACCES:
        case MIPS_ERR_EBUSY:
        case MIPS_ERR_EEXIST: 
        case MIPS_ERR_EXDEV:
        case MIPS_ERR_ENOTDIR:
        case MIPS_ERR_EISDIR:
        case MIPS_ERR_EINVAL: 
        case MIPS_ERR_ENFILE: 
        case MIPS_ERR_EMFILE: 
        case MIPS_ERR_ETXTBSY: 
        case MIPS_ERR_EFBIG:
        case MIPS_ERR_ENOSPC: 
        case MIPS_ERR_ESPIPE: 
        case MIPS_ERR_EROFS: 
        case MIPS_ERR_EMLINK: 
        case MIPS_ERR_EPIPE: 
        case MIPS_ERR_ERANGE: 
        case MIPS_ERR_ENOSR: 
        case MIPS_ERR_EBADMSG: 
        case MIPS_ERR_ENAMETOOLONG: 
        case MIPS_ERR_ELOOP: 
        case MIPS_ERR_ECONNRESET: 
        case MIPS_ERR_ENOBUFS:
        case MIPS_ERR_ENETUNREACH: 
        case MIPS_ERR_ENETDOWN:
        case MIPS_ERR_ETIMEDOUT: 
        case MIPS_ERR_ENOTCONN:
        case MIPS_ERR_EOVERFLOW: 
            errno = err;
            break;
        default: 
            errno = def; 
    }
}
