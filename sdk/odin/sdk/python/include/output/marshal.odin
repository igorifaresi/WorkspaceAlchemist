/* Interface for marshal.c */
package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyMarshal_ReadObjectFromString   :: proc() -> ^PyObject ---
	PyMarshal_WriteObjectToString    :: proc() -> ^PyObject ---
	PyMarshal_ReadLongFromFile       :: proc() -> c.long ---
	PyMarshal_ReadShortFromFile      :: proc() -> i32 ---
	PyMarshal_ReadObjectFromFile     :: proc() -> ^PyObject ---
	PyMarshal_ReadLastObjectFromFile :: proc() -> ^PyObject ---
	PyMarshal_WriteLongToFile        :: proc() ---
	PyMarshal_WriteObjectToFile      :: proc() ---
}
