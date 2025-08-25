/* Method object interface */
package pkg

import "core:c"

_ :: c



PyCFunction :: proc "c" (^PyObject, ^PyObject) -> ^PyObject

PyCFunctionFast :: proc "c" (^PyObject, ^^PyObject, Py_ssize_t) -> ^PyObject

PyCFunctionWithKeywords :: proc "c" (^PyObject, ^PyObject, ^PyObject) -> ^PyObject

PyCFunctionFastWithKeywords :: proc "c" (^PyObject, ^^PyObject, Py_ssize_t, ^PyObject) -> ^PyObject

PyCMethod :: proc "c" (^PyObject, ^PyTypeObject, ^^PyObject, uint, ^PyObject) -> ^PyObject

PyMethodDef :: struct {
	ml_name:  cstring,     /* The name of the built-in function/method */
	ml_meth:  PyCFunction, /* The C function that implements it */
	ml_flags: i32,         /* Combination of METH_xxx flags, which mostly
                               describe the args expected by the C func */
	ml_doc:   cstring,     /* The __doc__ attribute, or NULL */
}

@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyCFunction_GetFunction :: proc() -> PyCFunction ---
	PyCFunction_GetSelf     :: proc() -> ^PyObject ---
	PyCFunction_GetFlags    :: proc() -> i32 ---
	PyCFunction_Call        :: proc() -> ^PyObject ---

	/* PyCFunction_New is declared as a function for stable ABI (declaration is
	* needed for e.g. GCC with -fvisibility=hidden), but redefined as a macro
	* that calls PyCFunction_NewEx. */
	PyCFunction_New :: proc() -> ^PyObject ---

	/* PyCFunction_NewEx is similar: on 3.9+, this calls PyCMethod_New. */
	PyCFunction_NewEx :: proc() -> ^PyObject ---
	PyCMethod_New     :: proc() -> ^PyObject ---
}
