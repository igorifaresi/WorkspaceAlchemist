/* List object interface

Another generally useful object type is a list of object pointers.
This is a mutable type: the list items can be changed, and items can be
added or removed. Out-of-range indices or non-list objects are ignored.

WARNING: PyList_SetItem does not increment the new item's reference count,
but does decrement the reference count of the item it replaces, if not nil.
It does *decrement* the reference count if it is *not* inserted in the list.
Similarly, PyList_GetItem does not increment the returned item's reference
count.
*/
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyList_New      :: proc(size: Py_ssize_t) -> ^PyObject ---
	PyList_Size     :: proc() -> Py_ssize_t ---
	PyList_GetItem  :: proc() -> ^PyObject ---
	PyList_SetItem  :: proc() -> i32 ---
	PyList_Insert   :: proc() -> i32 ---
	PyList_Append   :: proc() -> i32 ---
	PyList_GetSlice :: proc() -> ^PyObject ---
	PyList_SetSlice :: proc() -> i32 ---
	PyList_Sort     :: proc() -> i32 ---
	PyList_Reverse  :: proc() -> i32 ---
	PyList_AsTuple  :: proc() -> ^PyObject ---
}
