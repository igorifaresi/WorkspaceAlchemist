package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	PySlice_New             :: proc(start: ^PyObject, stop: ^PyObject, step: ^PyObject) -> ^PyObject ---
	PySlice_FromIndices    :: proc(start: Py_ssize_t, stop: Py_ssize_t) -> ^PyObject ---
	PySlice_GetLongIndices :: proc(self: ^PySliceObject, length: ^PyObject, start_ptr: ^^PyObject, stop_ptr: ^^PyObject, step_ptr: ^^PyObject) -> i32 ---
	PySlice_GetIndices      :: proc(r: ^PyObject, length: Py_ssize_t, start: ^Py_ssize_t, stop: ^Py_ssize_t, step: ^Py_ssize_t) -> i32 ---
	PySlice_GetIndicesEx    :: proc(r: ^PyObject, length: Py_ssize_t, start: ^Py_ssize_t, stop: ^Py_ssize_t, step: ^Py_ssize_t, slicelength: ^Py_ssize_t) -> i32 ---
	PySlice_Unpack          :: proc(slice: ^PyObject, start: ^Py_ssize_t, stop: ^Py_ssize_t, step: ^Py_ssize_t) -> i32 ---
	PySlice_AdjustIndices   :: proc(length: Py_ssize_t, start: ^Py_ssize_t, stop: ^Py_ssize_t, step: Py_ssize_t) -> Py_ssize_t ---
}
