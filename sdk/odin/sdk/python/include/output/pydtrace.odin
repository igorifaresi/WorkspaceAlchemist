/* Static DTrace probes interface */
package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	/* Without DTrace, compile to nothing. */
	PyDTrace_LINE                           :: proc(arg0: cstring, arg1: cstring, arg2: i32) ---
	PyDTrace_FUNCTION_ENTRY                 :: proc(arg0: cstring, arg1: cstring, arg2: i32) ---
	PyDTrace_FUNCTION_RETURN                :: proc(arg0: cstring, arg1: cstring, arg2: i32) ---
	PyDTrace_GC_START                       :: proc(arg0: i32) ---
	PyDTrace_GC_DONE                        :: proc(arg0: Py_ssize_t) ---
	PyDTrace_INSTANCE_NEW_START             :: proc(arg0: i32) ---
	PyDTrace_INSTANCE_NEW_DONE              :: proc(arg0: i32) ---
	PyDTrace_INSTANCE_DELETE_START          :: proc(arg0: i32) ---
	PyDTrace_INSTANCE_DELETE_DONE           :: proc(arg0: i32) ---
	PyDTrace_IMPORT_FIND_LOAD_START         :: proc(arg0: cstring) ---
	PyDTrace_IMPORT_FIND_LOAD_DONE          :: proc(arg0: cstring, arg1: i32) ---
	PyDTrace_AUDIT                          :: proc(arg0: cstring, arg1: rawptr) ---
	PyDTrace_LINE_ENABLED                   :: proc() -> i32 ---
	PyDTrace_FUNCTION_ENTRY_ENABLED         :: proc() -> i32 ---
	PyDTrace_FUNCTION_RETURN_ENABLED        :: proc() -> i32 ---
	PyDTrace_GC_START_ENABLED               :: proc() -> i32 ---
	PyDTrace_GC_DONE_ENABLED                :: proc() -> i32 ---
	PyDTrace_INSTANCE_NEW_START_ENABLED     :: proc() -> i32 ---
	PyDTrace_INSTANCE_NEW_DONE_ENABLED      :: proc() -> i32 ---
	PyDTrace_INSTANCE_DELETE_START_ENABLED  :: proc() -> i32 ---
	PyDTrace_INSTANCE_DELETE_DONE_ENABLED   :: proc() -> i32 ---
	PyDTrace_IMPORT_FIND_LOAD_START_ENABLED :: proc() -> i32 ---
	PyDTrace_IMPORT_FIND_LOAD_DONE_ENABLED  :: proc() -> i32 ---
	PyDTrace_AUDIT_ENABLED                  :: proc() -> i32 ---
}
