/* Interfaces to configure, query, create & destroy the Python runtime */
package pkg

import "core:c"

_ :: c



/* Signals */
PyOS_sighandler_t :: proc "c" (i32)

@(default_calling_convention="c", link_prefix="")
foreign lib {
	/* Initialization and finalization */
	Py_Initialize    :: proc() ---
	Py_InitializeEx  :: proc() ---
	Py_Finalize      :: proc() ---
	Py_FinalizeEx    :: proc() -> i32 ---
	Py_IsInitialized :: proc() -> i32 ---

	/* Subinterpreter support */
	Py_NewInterpreter :: proc() -> ^PyThreadState ---
	Py_EndInterpreter :: proc() ---

	/* Py_PyAtExit is for the atexit module, Py_AtExit is for low-level
	* exit functions.
	*/
	Py_AtExit :: proc(func: proc "c" (void)) -> i32 ---
	Py_Exit   :: proc() ---

	/* Bootstrap __main__ (defined in Modules/main.c) */
	Py_Main      :: proc(argc: i32, argv: ^^wchar_t) -> i32 ---
	Py_BytesMain :: proc(argc: i32, argv: ^^u8) -> i32 ---

	/* In pathconfig.c */
	Py_SetProgramName     :: proc() ---
	Py_GetProgramName     :: proc() -> ^wchar_t ---
	Py_SetPythonHome      :: proc() ---
	Py_GetPythonHome      :: proc() -> ^wchar_t ---
	Py_GetProgramFullPath :: proc() -> ^wchar_t ---
	Py_GetPrefix          :: proc() -> ^wchar_t ---
	Py_GetExecPrefix      :: proc() -> ^wchar_t ---
	Py_GetPath            :: proc() -> ^wchar_t ---
	Py_SetPath            :: proc() ---
	Py_CheckPython3      :: proc() -> i32 ---

	/* In their own files */
	Py_GetVersion   :: proc() -> cstring ---
	Py_GetPlatform  :: proc() -> cstring ---
	Py_GetCopyright :: proc() -> cstring ---
	Py_GetCompiler  :: proc() -> cstring ---
	Py_GetBuildInfo :: proc() -> cstring ---
	PyOS_getsig     :: proc() -> PyOS_sighandler_t ---
	PyOS_setsig     :: proc() -> PyOS_sighandler_t ---
}
