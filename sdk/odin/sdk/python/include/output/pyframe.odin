/* Limited C API of PyFrame API
*
* Include "frameobject.h" to get the PyFrameObject structure.
*/
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	/* Return the line of code the frame is currently executing. */
	PyFrame_GetLineNumber :: proc() -> i32 ---
	PyFrame_GetCode       :: proc(frame: ^PyFrameObject) -> ^PyCodeObject ---
}
