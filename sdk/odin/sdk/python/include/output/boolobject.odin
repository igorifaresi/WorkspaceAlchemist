/* Boolean object interface */
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	// Test if an object is the True singleton, the same as "x is True" in Python.
	Py_IsTrue :: proc(x: ^PyObject) -> i32 ---

	// Test if an object is the False singleton, the same as "x is False" in Python.
	Py_IsFalse :: proc(x: ^PyObject) -> i32 ---

	/* Function to return a bool from a C long */
	PyBool_FromLong :: proc() -> ^PyObject ---
}
