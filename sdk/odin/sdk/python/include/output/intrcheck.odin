package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyOS_InterruptOccurred :: proc() -> i32 ---

	/* Deprecated, please use PyOS_AfterFork_Child() instead */
	PyOS_AfterFork     :: proc() ---
	PyOS_IsMainThread :: proc() -> i32 ---

	/* windows.h is not included by Python.h so use void* instead of HANDLE */
	PyOS_SigintEvent :: proc() -> rawptr ---
}
