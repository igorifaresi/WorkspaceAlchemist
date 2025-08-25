package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	Py_HashDouble  :: proc() -> Py_hash_t ---
	Py_HashPointer :: proc() -> Py_hash_t ---

	// Similar to _Py_HashPointer(), but don't replace -1 with -2
	Py_HashPointerRaw :: proc() -> Py_hash_t ---
	Py_HashBytes      :: proc() -> Py_hash_t ---
	PyHash_GetFuncDef  :: proc() -> ^PyHash_FuncDef ---
}
