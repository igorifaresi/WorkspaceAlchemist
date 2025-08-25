/* ByteArray object interface */
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	/* Direct API functions */
	PyByteArray_FromObject        :: proc() -> ^PyObject ---
	PyByteArray_Concat            :: proc() -> ^PyObject ---
	PyByteArray_FromStringAndSize :: proc() -> ^PyObject ---
	PyByteArray_Size              :: proc() -> Py_ssize_t ---
	PyByteArray_AsString          :: proc() -> cstring ---
	PyByteArray_Resize            :: proc() -> i32 ---
}
