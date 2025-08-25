/* Weak references objects for Python. */
package pkg





PyWeakReference :: struct {
}

@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyWeakref_NewRef    :: proc(ob: ^PyObject, callback: ^PyObject) -> ^PyObject ---
	PyWeakref_NewProxy  :: proc(ob: ^PyObject, callback: ^PyObject) -> ^PyObject ---
	PyWeakref_GetObject :: proc(ref: ^PyObject) -> ^PyObject ---
}
