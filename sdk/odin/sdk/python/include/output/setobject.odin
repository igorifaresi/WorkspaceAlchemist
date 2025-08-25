/* Set object interface */
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	PySet_New       :: proc() -> ^PyObject ---
	PyFrozenSet_New :: proc() -> ^PyObject ---
	PySet_Add       :: proc(set: ^PyObject, key: ^PyObject) -> i32 ---
	PySet_Clear     :: proc(set: ^PyObject) -> i32 ---
	PySet_Contains  :: proc(anyset: ^PyObject, key: ^PyObject) -> i32 ---
	PySet_Discard   :: proc(set: ^PyObject, key: ^PyObject) -> i32 ---
	PySet_Pop       :: proc(set: ^PyObject) -> ^PyObject ---
	PySet_Size      :: proc(anyset: ^PyObject) -> Py_ssize_t ---
}
