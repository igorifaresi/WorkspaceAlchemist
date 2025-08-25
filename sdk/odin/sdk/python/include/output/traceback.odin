package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	/* Traceback interface */
	PyTraceBack_Here  :: proc() -> i32 ---
	PyTraceBack_Print :: proc() -> i32 ---
}
