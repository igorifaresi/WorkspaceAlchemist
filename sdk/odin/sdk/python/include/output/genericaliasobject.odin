// Implementation of PEP 585: support list[int] etc.
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	Py_GenericAlias :: proc() -> ^PyObject ---
}
