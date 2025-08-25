/* Copyright (c) 2008-2009, Google Inc.
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are
* met:
*
*     * Redistributions of source code must retain the above copyright
* notice, this list of conditions and the following disclaimer.
*     * Neither the name of Google Inc. nor the names of its
* contributors may be used to endorse or promote products derived from
* this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
* OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
* THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* ---
* Author: Kostya Serebryany
* Copied to CPython by Jeffrey Yasskin, with all macros renamed to
* start with _Py_ to avoid colliding with users embedding Python, and
* with deprecated macros removed.
*/
/* This file defines dynamic annotations for use with dynamic analysis
tool such as valgrind, PIN, etc.

Dynamic annotation is a source code annotation that affects
the generated code (that is, the annotation is not a comment).
Each such annotation is attached to a particular
instruction and/or to a particular object (address) in the program.

The annotations that should be used by users are macros in all upper-case
(e.g., _Py_ANNOTATE_NEW_MEMORY).

Actual implementation of these macros may differ depending on the
dynamic analysis tool being used.

See https://code.google.com/p/data-race-test/  for more information.

This file supports the following dynamic analysis tools:
- None (DYNAMIC_ANNOTATIONS_ENABLED is not defined or zero).
Macros are defined empty.
- ThreadSanitizer, Helgrind, DRD (DYNAMIC_ANNOTATIONS_ENABLED is 1).
Macros are defined as calls to non-inlinable empty functions
that are intercepted by Valgrind. */
package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	AnnotateRWLockCreate         :: proc(file: cstring, line: i32, lock: ^volatile void) ---
	AnnotateRWLockDestroy        :: proc(file: cstring, line: i32, lock: ^volatile void) ---
	AnnotateRWLockAcquired       :: proc(file: cstring, line: i32, lock: ^volatile void, is_w: c.long) ---
	AnnotateRWLockReleased       :: proc(file: cstring, line: i32, lock: ^volatile void, is_w: c.long) ---
	AnnotateBarrierInit          :: proc(file: cstring, line: i32, barrier: ^volatile void, count: c.long, reinitialization_allowed: c.long) ---
	AnnotateBarrierWaitBefore    :: proc(file: cstring, line: i32, barrier: ^volatile void) ---
	AnnotateBarrierWaitAfter     :: proc(file: cstring, line: i32, barrier: ^volatile void) ---
	AnnotateBarrierDestroy       :: proc(file: cstring, line: i32, barrier: ^volatile void) ---
	AnnotateCondVarWait          :: proc(file: cstring, line: i32, cv: ^volatile void, lock: ^volatile void) ---
	AnnotateCondVarSignal        :: proc(file: cstring, line: i32, cv: ^volatile void) ---
	AnnotateCondVarSignalAll     :: proc(file: cstring, line: i32, cv: ^volatile void) ---
	AnnotatePublishMemoryRange   :: proc(file: cstring, line: i32, address: ^volatile void, size: c.long) ---
	AnnotateUnpublishMemoryRange :: proc(file: cstring, line: i32, address: ^volatile void, size: c.long) ---
	AnnotatePCQCreate            :: proc(file: cstring, line: i32, pcq: ^volatile void) ---
	AnnotatePCQDestroy           :: proc(file: cstring, line: i32, pcq: ^volatile void) ---
	AnnotatePCQPut               :: proc(file: cstring, line: i32, pcq: ^volatile void) ---
	AnnotatePCQGet               :: proc(file: cstring, line: i32, pcq: ^volatile void) ---
	AnnotateNewMemory            :: proc(file: cstring, line: i32, address: ^volatile void, size: c.long) ---
	AnnotateExpectRace           :: proc(file: cstring, line: i32, address: ^volatile void, description: cstring) ---
	AnnotateBenignRace           :: proc(file: cstring, line: i32, address: ^volatile void, description: cstring) ---
	AnnotateBenignRaceSized      :: proc(file: cstring, line: i32, address: ^volatile void, size: c.long, description: cstring) ---
	AnnotateMutexIsUsedAsCondVar :: proc(file: cstring, line: i32, mu: ^volatile void) ---
	AnnotateTraceMemory          :: proc(file: cstring, line: i32, arg: ^volatile void) ---
	AnnotateThreadName           :: proc(file: cstring, line: i32, name: cstring) ---
	AnnotateIgnoreReadsBegin     :: proc(file: cstring, line: i32) ---
	AnnotateIgnoreReadsEnd       :: proc(file: cstring, line: i32) ---
	AnnotateIgnoreWritesBegin    :: proc(file: cstring, line: i32) ---
	AnnotateIgnoreWritesEnd      :: proc(file: cstring, line: i32) ---
	AnnotateEnableRaceDetection  :: proc(file: cstring, line: i32, enable: i32) ---
	AnnotateNoOp                 :: proc(file: cstring, line: i32, arg: ^volatile void) ---
	AnnotateFlushState           :: proc(file: cstring, line: i32) ---

	/* Return non-zero value if running under valgrind.
	
	If "valgrind.h" is included into dynamic_annotations.c,
	the regular valgrind mechanism will be used.
	See http://valgrind.org/docs/manual/manual-core-adv.html about
	RUNNING_ON_VALGRIND and other valgrind "client requests".
	The file "valgrind.h" may be obtained by doing
	svn co svn://svn.valgrind.org/valgrind/trunk/include
	
	If for some reason you can't use "valgrind.h" or want to fake valgrind,
	there are two ways to make this function return non-zero:
	- Use environment variable: export RUNNING_ON_VALGRIND=1
	- Make your tool intercept the function RunningOnValgrind() and
	change its return value.
	*/
	RunningOnValgrind :: proc() -> i32 ---
}
