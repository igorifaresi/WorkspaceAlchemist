/* Capsule objects let you wrap a C "void *" pointer in a Python
object.  They're a way of passing data through the Python interpreter
without creating your own custom type.

Capsules are used for communication between extension modules.
They provide a way for an extension module to export a C interface
to other extension modules, so that extension modules can use the
Python import mechanism to link to one another.

For more information, please see "c-api/capsule.html" in the
documentation.
*/
package pkg

import "core:c"

_ :: c



PyCapsule_Destructor :: proc "c" (^PyObject)

@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyCapsule_New           :: proc(pointer: rawptr, name: cstring, destructor: PyCapsule_Destructor) -> ^PyObject ---
	PyCapsule_GetPointer    :: proc(capsule: ^PyObject, name: cstring) -> rawptr ---
	PyCapsule_GetDestructor :: proc(capsule: ^PyObject) -> PyCapsule_Destructor ---
	PyCapsule_GetName       :: proc(capsule: ^PyObject) -> cstring ---
	PyCapsule_GetContext    :: proc(capsule: ^PyObject) -> rawptr ---
	PyCapsule_IsValid       :: proc(capsule: ^PyObject, name: cstring) -> i32 ---
	PyCapsule_SetPointer    :: proc(capsule: ^PyObject, pointer: rawptr) -> i32 ---
	PyCapsule_SetDestructor :: proc(capsule: ^PyObject, destructor: PyCapsule_Destructor) -> i32 ---
	PyCapsule_SetName       :: proc(capsule: ^PyObject, name: cstring) -> i32 ---
	PyCapsule_SetContext    :: proc(capsule: ^PyObject, _context: rawptr) -> i32 ---
	PyCapsule_Import        :: proc(name: cstring, no_block: i32) -> rawptr ---
}
