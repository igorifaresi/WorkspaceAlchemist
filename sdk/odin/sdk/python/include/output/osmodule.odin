/* os module interface */
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyOS_FSPath :: proc(path: ^PyObject) -> ^PyObject ---
}
