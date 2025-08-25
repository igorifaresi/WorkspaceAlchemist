package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	/* Track an allocated memory block in the tracemalloc module.
	Return 0 on success, return -1 on error (failed to allocate memory to store
	the trace).
	
	Return -2 if tracemalloc is disabled.
	
	If memory block is already tracked, update the existing trace. */
	PyTraceMalloc_Track :: proc(domain: u32, ptr: uintptr, size: uint) -> i32 ---

	/* Untrack an allocated memory block in the tracemalloc module.
	Do nothing if the block was not tracked.
	
	Return -2 if tracemalloc is disabled, otherwise return 0. */
	PyTraceMalloc_Untrack :: proc(domain: u32, ptr: uintptr) -> i32 ---

	/* Get the traceback where a memory block was allocated.
	
	Return a tuple of (filename: str, lineno: int) tuples.
	
	Return None if the tracemalloc module is disabled or if the memory block
	is not tracked by tracemalloc.
	
	Raise an exception and return NULL on error. */
	PyTraceMalloc_GetTraceback :: proc(domain: u32, ptr: uintptr) -> ^PyObject ---

	/* Return non-zero if tracemalloc is tracing */
	PyTraceMalloc_IsTracing :: proc() -> i32 ---

	/* Clear the tracemalloc traces */
	PyTraceMalloc_ClearTraces :: proc() ---

	/* Clear the tracemalloc traces */
	PyTraceMalloc_GetTraces :: proc() -> ^PyObject ---

	/* Clear tracemalloc traceback for an object */
	PyTraceMalloc_GetObjectTraceback :: proc(obj: ^PyObject) -> ^PyObject ---

	/* Initialize tracemalloc */
	PyTraceMalloc_Init :: proc() -> i32 ---

	/* Start tracemalloc */
	PyTraceMalloc_Start :: proc(max_nframe: i32) -> i32 ---

	/* Stop tracemalloc */
	PyTraceMalloc_Stop :: proc() ---

	/* Get the tracemalloc traceback limit */
	PyTraceMalloc_GetTracebackLimit :: proc() -> i32 ---

	/* Get the memory usage of tracemalloc in bytes */
	PyTraceMalloc_GetMemory :: proc() -> uint ---

	/* Get the current size and peak size of traced memory blocks as a 2-tuple */
	PyTraceMalloc_GetTracedMemory :: proc() -> ^PyObject ---

	/* Set the peak size of traced memory blocks to the current size */
	PyTraceMalloc_ResetPeak :: proc() ---
}
