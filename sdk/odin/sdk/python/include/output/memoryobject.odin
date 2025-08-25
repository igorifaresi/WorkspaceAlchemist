/* Memory view object. In Python this is available as "memoryview". */
package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyMemoryView_FromObject    :: proc(base: ^PyObject) -> ^PyObject ---
	PyMemoryView_FromMemory    :: proc(mem: cstring, size: Py_ssize_t, flags: i32) -> ^PyObject ---
	PyMemoryView_FromBuffer    :: proc(info: ^Py_buffer) -> ^PyObject ---
	PyMemoryView_GetContiguous :: proc(base: ^PyObject, buffertype: i32, order: u8) -> ^PyObject ---
}
