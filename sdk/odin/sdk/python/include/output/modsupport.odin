package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyArg_Parse                    :: proc() -> i32 ---
	PyArg_ParseTuple               :: proc() -> i32 ---
	PyArg_ParseTupleAndKeywords    :: proc() -> i32 ---
	PyArg_VaParse                  :: proc() -> i32 ---
	PyArg_VaParseTupleAndKeywords  :: proc() -> i32 ---
	PyArg_ValidateKeywordArguments :: proc() -> i32 ---
	PyArg_UnpackTuple              :: proc() -> i32 ---
	Py_BuildValue                  :: proc() -> ^PyObject ---
	Py_BuildValue_SizeT           :: proc() -> ^PyObject ---
	Py_VaBuildValue                :: proc() -> ^PyObject ---

	// Add an attribute with name 'name' and value 'obj' to the module 'mod.
	// On success, return 0 on success.
	// On error, raise an exception and return -1.
	PyModule_AddObjectRef :: proc(mod: ^PyObject, name: cstring, value: ^PyObject) -> i32 ---

	// Similar to PyModule_AddObjectRef() but steal a reference to 'obj'
	// (Py_DECREF(obj)) on success (if it returns 0).
	PyModule_AddObject         :: proc(mod: ^PyObject, value: ^PyObject) -> i32 ---
	PyModule_AddIntConstant    :: proc() -> i32 ---
	PyModule_AddStringConstant :: proc() -> i32 ---

	/* New in 3.9 */
	PyModule_AddType :: proc(module: ^PyObject, type: ^PyTypeObject) -> i32 ---

	/* New in 3.5 */
	PyModule_SetDocString :: proc() -> i32 ---
	PyModule_AddFunctions :: proc() -> i32 ---
	PyModule_ExecDef      :: proc(module: ^PyObject, def: ^PyModuleDef) -> i32 ---
	PyModule_Create2      :: proc(apiver: i32) -> ^PyObject ---

	/* New in 3.5 */
	PyModule_FromDefAndSpec2 :: proc(def: ^PyModuleDef, spec: ^PyObject, module_api_version: i32) -> ^PyObject ---
}
