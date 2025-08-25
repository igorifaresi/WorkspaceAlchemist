package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyOS_string_to_double :: proc(str: cstring, endptr: ^^u8, overflow_exception: ^PyObject) -> f64 ---

	/* The caller is responsible for calling PyMem_Free to free the buffer
	that's is returned. */
	PyOS_double_to_string                 :: proc(val: f64, format_code: u8, precision: i32, flags: i32, type: ^i32) -> cstring ---
	Py_string_to_number_with_underscores :: proc(str: cstring, len: Py_ssize_t, what: cstring, obj: ^PyObject, arg: rawptr, innerfunc: proc "c" (cstring, Py_ssize_t, rawptr) -> ^PyObject) -> ^PyObject ---
	Py_parse_inf_or_nan                  :: proc(p: cstring, endptr: ^^u8) -> f64 ---
}
