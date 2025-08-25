/* Descriptors */
package pkg

import "core:c"

_ :: c



getter :: proc "c" (^PyObject, rawptr) -> ^PyObject

setter :: proc "c" (^PyObject, ^PyObject, rawptr) -> i32

PyGetSetDef :: struct {
	name:    cstring,
	get:     getter,
	set:     setter,
	doc:     cstring,
	closure: rawptr,
}

/* An array of PyMemberDef structures defines the name, type and offset
of selected members of a C structure.  These can be read by
PyMember_GetOne() and set by PyMember_SetOne() (except if their READONLY
flag is set).  The array must be terminated with an entry whose name
pointer is NULL. */
PyMemberDef :: struct {
	name:   cstring,
	type:   i32,
	offset: Py_ssize_t,
	flags:  i32,
	doc:    cstring,
}

@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyDescr_NewMethod      :: proc() -> ^PyObject ---
	PyDescr_NewClassMethod :: proc() -> ^PyObject ---
	PyDescr_NewMember      :: proc() -> ^PyObject ---
	PyDescr_NewGetSet      :: proc() -> ^PyObject ---
	PyDictProxy_New        :: proc() -> ^PyObject ---
	PyWrapper_New          :: proc() -> ^PyObject ---
	PyMember_GetOne        :: proc() -> ^PyObject ---
	PyMember_SetOne        :: proc() -> i32 ---
}
