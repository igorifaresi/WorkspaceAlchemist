/* Module object interface */
package pkg

import "core:c"

_ :: c



PyModuleDef_Base :: struct {
	ob_base: PyObject,

	/* The function used to re-initialize the module.
	This is only set for legacy (single-phase init) extension modules
	and only used for those that support multiple initializations
	(m_size >= 0).
	It is set by _PyImport_LoadDynamicModuleWithSpec()
	and _imp.create_builtin(). */
	m_init: proc "c" (void) -> ^PyObject,

	/* The module's index into its interpreter's modules_by_index cache.
	This is set for all extension modules but only used for legacy ones.
	(See PyInterpreterState.modules_by_index for more info.)
	It is set by PyModuleDef_Init(). */
	m_index: Py_ssize_t,

	/* A copy of the module's __dict__ after the first time it was loaded.
	This is only set/used for legacy modules that do not support
	multiple initializations.
	It is set by _PyImport_FixupExtensionObject(). */
	m_copy: ^PyObject,
}

/* New in 3.5 */
PyModuleDef_Slot :: struct {
	slot:  i32,
	value: rawptr,
}

PyModuleDef :: struct {
	m_base:     PyModuleDef_Base,
	m_name:     cstring,
	m_doc:      cstring,
	m_size:     Py_ssize_t,
	m_methods:  ^PyMethodDef,
	m_slots:    ^PyModuleDef_Slot,
	m_traverse: traverseproc,
	m_clear:    inquiry,
	m_free:     freefunc,
}

@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyModule_NewObject           :: proc(name: ^PyObject) -> ^PyObject ---
	PyModule_New                 :: proc(name: cstring) -> ^PyObject ---
	PyModule_GetDict             :: proc() -> ^PyObject ---
	PyModule_GetNameObject       :: proc() -> ^PyObject ---
	PyModule_GetName             :: proc() -> cstring ---
	PyModule_GetFilename         :: proc() -> cstring ---
	PyModule_GetFilenameObject   :: proc() -> ^PyObject ---
	PyModule_Clear              :: proc() ---
	PyModule_ClearDict          :: proc() ---
	PyModuleSpec_IsInitializing :: proc() -> i32 ---
	PyModule_GetDef              :: proc() -> ^PyModuleDef ---
	PyModule_GetState            :: proc() -> rawptr ---

	/* New in 3.5 */
	PyModuleDef_Init :: proc() -> ^PyObject ---
}
