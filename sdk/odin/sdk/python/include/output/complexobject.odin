/* Complex number structure */
package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyComplex_FromDoubles  :: proc(real: f64, imag: f64) -> ^PyObject ---
	PyComplex_RealAsDouble :: proc(op: ^PyObject) -> f64 ---
	PyComplex_ImagAsDouble :: proc(op: ^PyObject) -> f64 ---
}
