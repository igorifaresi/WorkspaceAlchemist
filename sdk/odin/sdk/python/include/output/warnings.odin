package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyErr_WarnEx     :: proc(category: ^PyObject, message: cstring, stack_level: Py_ssize_t) -> i32 ---
	PyErr_WarnFormat :: proc(category: ^PyObject, stack_level: Py_ssize_t, format: cstring) -> i32 ---

	/* Emit a ResourceWarning warning */
	PyErr_ResourceWarning :: proc(source: ^PyObject, stack_level: Py_ssize_t, format: cstring) -> i32 ---
	PyErr_WarnExplicit    :: proc(category: ^PyObject, message: cstring, filename: cstring, lineno: i32, module: cstring, registry: ^PyObject) -> i32 ---
}
