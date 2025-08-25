package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyDict_New              :: proc() -> ^PyObject ---
	PyDict_GetItem          :: proc(mp: ^PyObject, key: ^PyObject) -> ^PyObject ---
	PyDict_GetItemWithError :: proc(mp: ^PyObject, key: ^PyObject) -> ^PyObject ---
	PyDict_SetItem          :: proc(mp: ^PyObject, key: ^PyObject, item: ^PyObject) -> i32 ---
	PyDict_DelItem          :: proc(mp: ^PyObject, key: ^PyObject) -> i32 ---
	PyDict_Clear            :: proc(mp: ^PyObject) ---
	PyDict_Next             :: proc(mp: ^PyObject, pos: ^Py_ssize_t, key: ^^PyObject, value: ^^PyObject) -> i32 ---
	PyDict_Keys             :: proc(mp: ^PyObject) -> ^PyObject ---
	PyDict_Values           :: proc(mp: ^PyObject) -> ^PyObject ---
	PyDict_Items            :: proc(mp: ^PyObject) -> ^PyObject ---
	PyDict_Size             :: proc(mp: ^PyObject) -> Py_ssize_t ---
	PyDict_Copy             :: proc(mp: ^PyObject) -> ^PyObject ---
	PyDict_Contains         :: proc(mp: ^PyObject, key: ^PyObject) -> i32 ---

	/* PyDict_Update(mp, other) is equivalent to PyDict_Merge(mp, other, 1). */
	PyDict_Update :: proc(mp: ^PyObject, other: ^PyObject) -> i32 ---

	/* PyDict_Merge updates/merges from a mapping object (an object that
	supports PyMapping_Keys() and PyObject_GetItem()).  If override is true,
	the last occurrence of a key wins, else the first.  The Python
	dict.update(other) is equivalent to PyDict_Merge(dict, other, 1).
	*/
	PyDict_Merge :: proc(mp: ^PyObject, other: ^PyObject, override: i32) -> i32 ---

	/* PyDict_MergeFromSeq2 updates/merges from an iterable object producing
	iterable objects of length 2.  If override is true, the last occurrence
	of a key wins, else the first.  The Python dict constructor dict(seq2)
	is equivalent to dict={}; PyDict_MergeFromSeq(dict, seq2, 1).
	*/
	PyDict_MergeFromSeq2    :: proc(d: ^PyObject, seq2: ^PyObject, override: i32) -> i32 ---
	PyDict_GetItemString    :: proc(dp: ^PyObject, key: cstring) -> ^PyObject ---
	PyDict_SetItemString    :: proc(dp: ^PyObject, key: cstring, item: ^PyObject) -> i32 ---
	PyDict_DelItemString    :: proc(dp: ^PyObject, key: cstring) -> i32 ---
	PyObject_GenericGetDict :: proc() -> ^PyObject ---
}
