package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyOS_mystrnicmp :: proc() -> i32 ---
	PyOS_mystricmp  :: proc() -> i32 ---
}
