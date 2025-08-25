/* Bytes object interface */
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyBytes_FromStringAndSize :: proc() -> ^PyObject ---
	PyBytes_FromString        :: proc() -> ^PyObject ---
	PyBytes_FromObject        :: proc() -> ^PyObject ---
	PyBytes_FromFormatV       :: proc() -> ^PyObject ---
	PyBytes_FromFormat        :: proc() -> ^PyObject ---
	PyBytes_Size              :: proc() -> Py_ssize_t ---
	PyBytes_AsString          :: proc() -> cstring ---
	PyBytes_Repr              :: proc() -> ^PyObject ---
	PyBytes_Concat            :: proc() ---
	PyBytes_ConcatAndDel      :: proc() ---
	PyBytes_DecodeEscape      :: proc() -> ^PyObject ---

	/* Provides access to the internal data buffer and size of a bytes object.
	Passing NULL as len parameter will force the string buffer to be
	0-terminated (passing a string with embedded NUL characters will
	cause an exception).  */
	PyBytes_AsStringAndSize :: proc(obj: ^PyObject, s: ^^u8, len: ^Py_ssize_t) -> i32 ---
}
