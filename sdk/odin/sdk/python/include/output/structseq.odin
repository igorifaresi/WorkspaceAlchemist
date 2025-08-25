/* Named tuple object interface */
package pkg

import "core:c"

_ :: c



PyStructSequence_Field :: struct {
	name: cstring,
	doc:  cstring,
}

PyStructSequence_Desc :: struct {
	name:          cstring,
	doc:           cstring,
	fields:        ^PyStructSequence_Field,
	n_in_sequence: i32,
}

PyStructSequence :: PyTupleObject

@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyStructSequence_InitType  :: proc(type: ^PyTypeObject, desc: ^PyStructSequence_Desc) ---
	PyStructSequence_InitType2 :: proc(type: ^PyTypeObject, desc: ^PyStructSequence_Desc) -> i32 ---
	PyStructSequence_NewType   :: proc(desc: ^PyStructSequence_Desc) -> ^PyTypeObject ---
	PyStructSequence_New       :: proc(type: ^PyTypeObject) -> ^PyObject ---
	PyStructSequence_SetItem   :: proc() ---
	PyStructSequence_GetItem   :: proc() -> ^PyObject ---
}
