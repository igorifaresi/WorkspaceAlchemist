/* Float object interface */
/*
PyFloatObject represents a (double precision) floating-point number.
*/
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyFloat_GetMax  :: proc() -> f64 ---
	PyFloat_GetMin  :: proc() -> f64 ---
	PyFloat_GetInfo :: proc() -> ^PyObject ---

	/* Return Python float from string PyObject. */
	PyFloat_FromString :: proc() -> ^PyObject ---

	/* Return Python float from C double. */
	PyFloat_FromDouble :: proc() -> ^PyObject ---

	/* Extract C double from Python float.  The macro version trades safety for
	speed. */
	PyFloat_AsDouble :: proc() -> f64 ---
}
