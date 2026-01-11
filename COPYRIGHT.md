# PIC32 Toolchain - Copyright and License Information

This toolchain is a collection of free software components, each with its own
license. This document provides attribution and license information for all
components included in this distribution.

## Summary

| Component | License | Copyright Holder |
|-----------|---------|------------------|
| GCC | GPL-3.0-or-later with Runtime Library Exception | Free Software Foundation |
| Binutils | GPL-3.0-or-later | Free Software Foundation |
| GDB | GPL-3.0-or-later | Free Software Foundation |
| Newlib | BSD/MIT/Public Domain (mixed) | Various (see below) |
| GMP | LGPL-3.0-or-later or GPL-2.0-or-later | Free Software Foundation |
| MPFR | LGPL-3.0-or-later | Free Software Foundation |
| MPC | LGPL-3.0-or-later | INRIA |
| Microchip DFP | BSD-3-Clause | Microchip Technology Inc. |

---

## GNU Compiler Collection (GCC)

**Version:** 15.2.0  
**License:** GPL-3.0-or-later with GCC Runtime Library Exception  
**Website:** https://gcc.gnu.org/

```
Copyright (C) Free Software Foundation, Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```

### GCC Runtime Library Exception

The GCC Runtime Library Exception allows you to use the runtime libraries
(libgcc, libstdc++, etc.) in your own programs without those programs being
subject to the GPL, provided certain conditions are met. This means firmware
compiled with this toolchain is NOT required to be GPL-licensed.

See: https://www.gnu.org/licenses/gcc-exception-3.1.html

---

## GNU Binutils

**Version:** 2.44  
**License:** GPL-3.0-or-later  
**Website:** https://www.gnu.org/software/binutils/

```
Copyright (C) Free Software Foundation, Inc.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
MA 02110-1301, USA.
```

---

## GNU Debugger (GDB)

**Version:** 15.2  
**License:** GPL-3.0-or-later  
**Website:** https://www.gnu.org/software/gdb/

```
Copyright (C) Free Software Foundation, Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```

---

## Newlib C Library

**Version:** 4.5.0.20241231  
**License:** Mixed (BSD, MIT, Public Domain)  
**Website:** https://sourceware.org/newlib/

Newlib is a collection of software from several sources, each with its own
license. The licenses are all BSD-compatible or more permissive.

```
Copyright (c) 1994-2024 Red Hat, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

    Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

    The name of Red Hat may not be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
```

### Additional Newlib Contributors

Newlib also includes code from:
- University of California, Berkeley (BSD License)
- Sun Microsystems (permissive license)
- Hewlett-Packard Company (permissive license)
- Various individual contributors

See the COPYING.NEWLIB file in the Newlib source distribution for complete
license details.

---

## GNU Multiple Precision Arithmetic Library (GMP)

**Version:** 6.3.0  
**License:** LGPL-3.0-or-later or GPL-2.0-or-later (dual licensed)  
**Website:** https://gmplib.org/

```
Copyright 1991, 1996, 1999, 2000, 2007 Free Software Foundation, Inc.

This file is part of the GNU MP Library.

The GNU MP Library is free software; you can redistribute it and/or modify
it under the terms of either:

  * the GNU Lesser General Public License as published by the Free
    Software Foundation; either version 3 of the License, or (at your
    option) any later version.

or

  * the GNU General Public License as published by the Free Software
    Foundation; either version 2 of the License, or (at your option) any
    later version.

or both in parallel, as here.

The GNU MP Library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.
```

**Note:** GMP is statically linked into GCC during the build process and is
not distributed separately in this toolchain.

---

## GNU MPFR Library

**Version:** 4.2.2  
**License:** LGPL-3.0-or-later  
**Website:** https://www.mpfr.org/

```
Copyright 2000-2024 Free Software Foundation, Inc.

The MPFR Library is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

The MPFR Library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public License
along with the MPFR Library; see the file COPYING.LESSER.  If not, see
https://www.gnu.org/licenses/ or write to the Free Software Foundation, Inc.,
51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
```

**Note:** MPFR is statically linked into GCC during the build process and is
not distributed separately in this toolchain.

---

## GNU MPC Library

**Version:** 1.3.1  
**License:** LGPL-3.0-or-later  
**Website:** https://www.multiprecision.org/mpc/

```
Copyright (C) INRIA 2003-2024

This file is part of GNU MPC.

GNU MPC is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

GNU MPC is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for
more details.

You should have received a copy of the GNU Lesser General Public License
along with this program. If not, see http://www.gnu.org/licenses/ .
```

**Note:** MPC is statically linked into GCC during the build process and is
not distributed separately in this toolchain.

---

## Microchip Device Family Packs (DFP)

**License:** BSD-3-Clause (Modified BSD License)  
**Copyright:** Microchip Technology Inc.

The Device Family Packs (DFP) included in the `dfp/` directory contain
device-specific header files, linker scripts, and startup code for PIC32
microcontrollers.

```
Copyright (c) 2024 Microchip Technology Inc. and its subsidiaries.

Subject to your compliance with these terms, you may use Microchip software
and any derivatives exclusively with Microchip products. It is your
responsibility to comply with third party license terms applicable to your
use of third party software (including open source software) that may
accompany Microchip software.

THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
PARTICULAR PURPOSE.

IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
```

### DFP Usage Terms

From the Microchip DFP source files:

> Redistribution and use in source and binary forms, with or without
> modification, are permitted provided that the following conditions are met:
>
> 1. Redistributions of source code must retain the above copyright notice,
>    this list of conditions and the following disclaimer.
>
> 2. Redistributions in binary form must reproduce the above copyright notice,
>    this list of conditions and the following disclaimer in the documentation
>    and/or other materials provided with the distribution.
>
> 3. The name of Microchip may not be used to endorse or promote products
>    derived from this software without specific prior written permission.
>
> **Publication is not required when this file is used in an embedded
> application.**

This means:
- You can freely use the DFP files in your embedded products
- No attribution is required in your final firmware/product
- Source distributions should retain the copyright notices

---

## MSYS2 Runtime Libraries (Windows Build)

The Windows build may include runtime DLLs from MSYS2/MinGW-w64:

- `libgcc_s_seh-1.dll` - GCC runtime (GPL with Runtime Exception)
- `libstdc++-6.dll` - C++ standard library (GPL with Runtime Exception)
- `libwinpthread-1.dll` - POSIX threads (MIT/X11 License)

These libraries are covered by their respective licenses which permit
redistribution.

---

## Your Firmware

**Important:** Firmware compiled using this toolchain is NOT subject to GPL
licensing requirements due to the GCC Runtime Library Exception. You are free
to use any license for your own code.

The only requirements are:
1. If you modify and redistribute the toolchain itself, those modifications
   must be under GPL
2. If you redistribute the Microchip DFP files in source form, retain the
   copyright notices

---

## Full License Texts

The complete text of the licenses referenced above can be found at:

- **GPL-3.0:** https://www.gnu.org/licenses/gpl-3.0.html
- **LGPL-3.0:** https://www.gnu.org/licenses/lgpl-3.0.html
- **GPL-2.0:** https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
- **GCC Runtime Library Exception:** https://www.gnu.org/licenses/gcc-exception-3.1.html
- **BSD-3-Clause:** https://opensource.org/licenses/BSD-3-Clause

---

## Contact

This toolchain is maintained by Kotuku Aerospace Limited.

- Website: https://kotuku.aero
- Repository: https://github.com/kotuku-aero/pic32
- Build Scripts: https://github.com/kotuku-aero/mip32
