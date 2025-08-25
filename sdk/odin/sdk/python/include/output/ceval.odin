/* Interface to random parts in ceval.c */
package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyEval_EvalCode   :: proc() -> ^PyObject ---
	PyEval_EvalCodeEx :: proc(co: ^PyObject, globals: ^PyObject, locals: ^PyObject, args: ^^PyObject, argc: i32, kwds: ^^PyObject, kwdc: i32, defs: ^^PyObject, defc: i32, kwdefs: ^PyObject, closure: ^PyObject) -> ^PyObject ---

	/* PyEval_CallObjectWithKeywords(), PyEval_CallObject(), PyEval_CallFunction
	* and PyEval_CallMethod are deprecated. Since they are officially part of the
	* stable ABI (PEP 384), they must be kept for backward compatibility.
	* PyObject_Call(), PyObject_CallFunction() and PyObject_CallMethod() are
	* recommended to call a callable object.
	*/
	PyEval_CallObjectWithKeywords :: proc(callable: ^PyObject, args: ^PyObject, kwargs: ^PyObject) -> ^PyObject ---
	PyEval_CallFunction           :: proc(callable: ^PyObject, format: cstring) -> ^PyObject ---
	PyEval_CallMethod             :: proc(obj: ^PyObject, name: cstring, format: cstring) -> ^PyObject ---
	PyEval_GetBuiltins            :: proc() -> ^PyObject ---
	PyEval_GetGlobals             :: proc() -> ^PyObject ---
	PyEval_GetLocals              :: proc() -> ^PyObject ---
	PyEval_GetFrame               :: proc() -> ^PyFrameObject ---
	Py_AddPendingCall             :: proc(func: proc "c" (rawptr) -> i32, arg: rawptr) -> i32 ---
	Py_MakePendingCalls           :: proc() -> i32 ---

	/* Protection against deeply nested recursive calls
	
	In Python 3.0, this protection has two levels:
	* normal anti-recursion protection is triggered when the recursion level
	exceeds the current recursion limit. It raises a RecursionError, and sets
	the "overflowed" flag in the thread state structure. This flag
	temporarily *disables* the normal protection; this allows cleanup code
	to potentially outgrow the recursion limit while processing the
	RecursionError.
	* "last chance" anti-recursion protection is triggered when the recursion
	level exceeds "current recursion limit + 50". By construction, this
	protection can only be triggered when the "overflowed" flag is set. It
	means the cleanup code has itself gone into an infinite loop, or the
	RecursionError has been mistakingly ignored. When this protection is
	triggered, the interpreter aborts with a Fatal Error.
	
	In addition, the "overflowed" flag is automatically reset when the
	recursion level drops below "current recursion limit - 50". This heuristic
	is meant to ensure that the normal anti-recursion protection doesn't get
	disabled too long.
	
	Please note: this scheme has its own limitations. See:
	http://mail.python.org/pipermail/python-dev/2008-August/082106.html
	for some observations.
	*/
	Py_SetRecursionLimit  :: proc() ---
	Py_GetRecursionLimit  :: proc() -> i32 ---
	Py_EnterRecursiveCall :: proc(_where: cstring) -> i32 ---
	Py_LeaveRecursiveCall :: proc() ---
	PyEval_GetFuncName    :: proc() -> cstring ---
	PyEval_GetFuncDesc    :: proc() -> cstring ---
	PyEval_EvalFrame      :: proc() -> ^PyObject ---
	PyEval_EvalFrameEx    :: proc(f: ^PyFrameObject, exc: i32) -> ^PyObject ---

	/* Interface for threads.
	
	A module that plans to do a blocking system call (or something else
	that lasts a long time and doesn't touch Python data) can allow other
	threads to run as follows:
	
	...preparations here...
	Py_BEGIN_ALLOW_THREADS
	...blocking system call here...
	Py_END_ALLOW_THREADS
	...interpret result here...
	
	The Py_BEGIN_ALLOW_THREADS/Py_END_ALLOW_THREADS pair expands to a
	{}-surrounded block.
	To leave the block in the middle (e.g., with return), you must insert
	a line containing Py_BLOCK_THREADS before the return, e.g.
	
	if (...premature_exit...) {
	Py_BLOCK_THREADS
	PyErr_SetFromErrno(PyExc_OSError);
	return NULL;
	}
	
	An alternative is:
	
	Py_BLOCK_THREADS
	if (...premature_exit...) {
	PyErr_SetFromErrno(PyExc_OSError);
	return NULL;
	}
	Py_UNBLOCK_THREADS
	
	For convenience, that the value of 'errno' is restored across
	Py_END_ALLOW_THREADS and Py_BLOCK_THREADS.
	
	WARNING: NEVER NEST CALLS TO Py_BEGIN_ALLOW_THREADS AND
	Py_END_ALLOW_THREADS!!!
	
	Note that not yet all candidates have been converted to use this
	mechanism!
	*/
	PyEval_SaveThread         :: proc() -> ^PyThreadState ---
	PyEval_RestoreThread      :: proc() ---
	PyEval_ThreadsInitialized :: proc() -> i32 ---
	PyEval_InitThreads        :: proc() ---

	/* PyEval_AcquireLock() and PyEval_ReleaseLock() are part of stable ABI.
	* They will be removed from this header file in the future version.
	* But they will be remained in ABI until Python 4.0.
	*/
	PyEval_AcquireLock   :: proc() ---
	PyEval_ReleaseLock   :: proc() ---
	PyEval_AcquireThread :: proc(tstate: ^PyThreadState) ---
	PyEval_ReleaseThread :: proc(tstate: ^PyThreadState) ---
}
