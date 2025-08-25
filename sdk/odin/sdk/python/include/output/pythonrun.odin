/* Interfaces to parse and execute pieces of python code */
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	Py_CompileString       :: proc() -> ^PyObject ---
	PyErr_Print            :: proc() ---
	PyErr_PrintEx          :: proc() ---
	PyErr_Display          :: proc() ---
	PyErr_DisplayException :: proc() ---
}
