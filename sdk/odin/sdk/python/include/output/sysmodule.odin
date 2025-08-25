/* System module interface */
package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	PySys_GetObject              :: proc() -> ^PyObject ---
	PySys_SetObject              :: proc() -> i32 ---
	PySys_SetArgv                :: proc() ---
	PySys_SetArgvEx              :: proc() ---
	PySys_SetPath                :: proc() ---
	PySys_WriteStdout            :: proc(format: cstring) ---
	PySys_WriteStderr            :: proc(format: cstring) ---
	PySys_FormatStdout           :: proc(format: cstring) ---
	PySys_FormatStderr           :: proc(format: cstring) ---
	PySys_ResetWarnOptions       :: proc() ---
	PySys_AddWarnOption          :: proc() ---
	PySys_AddWarnOptionUnicode   :: proc() ---
	PySys_HasWarnOptions         :: proc() -> i32 ---
	PySys_AddXOption             :: proc() ---
	PySys_GetXOptions            :: proc() -> ^PyObject ---
	PyUnstable_PerfMapState_Init :: proc() -> i32 ---
	PyUnstable_WritePerfMapEntry :: proc(code_addr: rawptr, code_size: u32, entry_name: cstring) -> i32 ---
	PyUnstable_PerfMapState_Fini :: proc() ---
}
