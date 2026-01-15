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
 *  C Runtime Startup
 *-------------------------------------------------------------------------*/

#ifdef __LIBBUILD__
	# Replace the standard debugging information with a simple filename. This 
	# prevents the library build directory from showing up in MPLAB IDE. It 
	# also effectively disables source-line debugging.
	.file 1 "libpic32/startup/crti.s"
	.loc 1 0
#endif

/* 4 slots for argument spill area.  1 for cpreturn, 1 for stack.
   Return spill offset of 40 and 20.  Aligned to 16 bytes for n32.  */

	.section .init, code
	.globl	_init
	.type	_init,@function
_init:
	addu	$sp,$sp,-32
	sw	$31,20($sp)
	
	.section .fini, code
	.globl	_fini
	.type	_fini,@function
_fini:
	addu	$sp,$sp,-32
	sw	$31,20($sp)
