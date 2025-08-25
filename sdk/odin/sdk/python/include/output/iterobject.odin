package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	PySeqIter_New  :: proc() -> ^PyObject ---
	PyCallIter_New :: proc() -> ^PyObject ---
}
