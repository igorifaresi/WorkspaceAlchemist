/* File object interface (what's left of it -- see io.py) */
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyFile_FromFd             :: proc() -> ^PyObject ---
	PyFile_GetLine            :: proc() -> ^PyObject ---
	PyFile_WriteObject        :: proc() -> i32 ---
	PyFile_WriteString        :: proc() -> i32 ---
	PyObject_AsFileDescriptor :: proc() -> i32 ---
}
