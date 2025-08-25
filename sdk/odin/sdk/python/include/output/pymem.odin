/* The PyMem_ family:  low-level memory allocation interfaces.
See objimpl.h for the PyObject_ memory family.
*/
package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	/* Functions
	
	Functions supplying platform-independent semantics for malloc/realloc/
	free.  These functions make sure that allocating 0 bytes returns a distinct
	non-NULL pointer (whenever possible -- if we're flat out of memory, NULL
	may be returned), even if the platform malloc and realloc don't.
	Returned pointers must be checked for NULL explicitly.  No action is
	performed on failure (no exception is set, no warning is printed, etc).
	*/
	PyMem_Malloc  :: proc(size: uint) -> rawptr ---
	PyMem_Calloc  :: proc(nelem: uint, elsize: uint) -> rawptr ---
	PyMem_Realloc :: proc(ptr: rawptr, new_size: uint) -> rawptr ---
	PyMem_Free    :: proc(ptr: rawptr) ---
}
