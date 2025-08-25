/* Module definition and import interface */
package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	PyImport_GetMagicNumber              :: proc() -> c.long ---
	PyImport_GetMagicTag                 :: proc() -> cstring ---
	PyImport_ExecCodeModule              :: proc(name: cstring, co: ^PyObject) -> ^PyObject ---
	PyImport_ExecCodeModuleEx            :: proc(name: cstring, co: ^PyObject, pathname: cstring) -> ^PyObject ---
	PyImport_ExecCodeModuleWithPathnames :: proc(name: cstring, co: ^PyObject, pathname: cstring, cpathname: cstring) -> ^PyObject ---
	PyImport_ExecCodeModuleObject        :: proc(name: ^PyObject, co: ^PyObject, pathname: ^PyObject, cpathname: ^PyObject) -> ^PyObject ---
	PyImport_GetModuleDict               :: proc() -> ^PyObject ---
	PyImport_GetModule                   :: proc(name: ^PyObject) -> ^PyObject ---
	PyImport_AddModuleObject             :: proc(name: ^PyObject) -> ^PyObject ---
	PyImport_AddModule                   :: proc(name: cstring) -> ^PyObject ---
	PyImport_ImportModule                :: proc(name: cstring) -> ^PyObject ---
	PyImport_ImportModuleNoBlock         :: proc(name: cstring) -> ^PyObject ---
	PyImport_ImportModuleLevel           :: proc(name: cstring, globals: ^PyObject, locals: ^PyObject, fromlist: ^PyObject, level: i32) -> ^PyObject ---
	PyImport_ImportModuleLevelObject     :: proc(name: ^PyObject, globals: ^PyObject, locals: ^PyObject, fromlist: ^PyObject, level: i32) -> ^PyObject ---
	PyImport_GetImporter                 :: proc(path: ^PyObject) -> ^PyObject ---
	PyImport_Import                      :: proc(name: ^PyObject) -> ^PyObject ---
	PyImport_ReloadModule                :: proc(m: ^PyObject) -> ^PyObject ---
	PyImport_ImportFrozenModuleObject    :: proc(name: ^PyObject) -> i32 ---
	PyImport_ImportFrozenModule          :: proc(name: cstring) -> i32 ---
	PyImport_AppendInittab               :: proc(name: cstring, initfunc: proc "c" (void) -> ^PyObject) -> i32 ---
}
