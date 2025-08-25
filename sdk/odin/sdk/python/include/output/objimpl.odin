/* The PyObject_ memory family:  high-level object memory interfaces.
See pymem.h for the low-level PyMem_ family.
*/
package pkg

import "core:c"

_ :: c



/* Visit all live GC-capable objects, similar to gc.get_objects(None). The
* supplied callback is called on every such object with the void* arg set
* to the supplied arg. Returning 0 from the callback ends iteration, returning
* 1 allows iteration to continue. Returning any other value may result in
* undefined behaviour.
*
* If new objects are (de)allocated by the callback it is undefined if they
* will be visited.

* Garbage collection is disabled during operation. Explicitly running a
* collection in the callback may lead to undefined behaviour e.g. visiting the
* same objects multiple times or not at all.
*/
gcvisitobjects_t :: proc "c" (^PyObject, rawptr) -> i32

@(default_calling_convention="c", link_prefix="")
foreign lib {
	/* Functions to call the same malloc/realloc/free as used by Python's
	object allocator.  If WITH_PYMALLOC is enabled, these may differ from
	the platform malloc/realloc/free.  The Python object allocator is
	designed for fast, cache-conscious allocation of many "small" objects,
	and with low hidden memory overhead.
	
	PyObject_Malloc(0) returns a unique non-NULL pointer if possible.
	
	PyObject_Realloc(NULL, n) acts like PyObject_Malloc(n).
	PyObject_Realloc(p != NULL, 0) does not return  NULL, or free the memory
	at p.
	
	Returned pointers must be checked for NULL explicitly; no action is
	performed on failure other than to return NULL (no warning it printed, no
	exception is set, etc).
	
	For allocating objects, use PyObject_{New, NewVar} instead whenever
	possible.  The PyObject_{Malloc, Realloc, Free} family is exposed
	so that you can exploit Python's small-block allocator for non-object
	uses.  If you must use these routines to allocate object memory, make sure
	the object gets initialized via PyObject_{Init, InitVar} after obtaining
	the raw memory.
	*/
	PyObject_Malloc  :: proc(size: uint) -> rawptr ---
	PyObject_Calloc  :: proc(nelem: uint, elsize: uint) -> rawptr ---
	PyObject_Realloc :: proc(ptr: rawptr, new_size: uint) -> rawptr ---
	PyObject_Free    :: proc(ptr: rawptr) ---

	/* Functions */
	PyObject_Init    :: proc() -> ^PyObject ---
	PyObject_InitVar :: proc() -> ^PyVarObject ---
	PyObject_New    :: proc() -> ^PyObject ---
	PyObject_NewVar :: proc() -> ^PyVarObject ---

	/* C equivalent of gc.collect(). */
	PyGC_Collect :: proc() -> Py_ssize_t ---

	/* C API for controlling the state of the garbage collector */
	PyGC_Enable                :: proc() -> i32 ---
	PyGC_Disable               :: proc() -> i32 ---
	PyGC_IsEnabled             :: proc() -> i32 ---
	PyUnstable_GC_VisitObjects :: proc(callback: gcvisitobjects_t, arg: rawptr) ---
	PyObject_GC_Resize        :: proc() -> ^PyVarObject ---
	PyObject_GC_New           :: proc() -> ^PyObject ---
	PyObject_GC_NewVar        :: proc() -> ^PyVarObject ---

	/* Tell the GC to track this object.
	*
	* See also private _PyObject_GC_TRACK() macro. */
	PyObject_GC_Track :: proc() ---

	/* Tell the GC to stop tracking this object.
	*
	* See also private _PyObject_GC_UNTRACK() macro. */
	PyObject_GC_UnTrack     :: proc() ---
	PyObject_GC_Del         :: proc() ---
	PyObject_GC_IsTracked   :: proc() -> i32 ---
	PyObject_GC_IsFinalized :: proc() -> i32 ---
}
