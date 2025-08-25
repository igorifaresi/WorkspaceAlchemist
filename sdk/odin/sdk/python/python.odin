package python

import "core:c"
import "base:runtime"
import "core:fmt"

foreign import lib {
    "python-odin.lib",
    "python312.lib",
}

ABI_VERSION :: 3

Object_Ptr :: distinct rawptr
FrameObject_Ptr :: distinct rawptr
CodeObject_Ptr :: distinct rawptr
ModuleDefinition_Ptr :: distinct rawptr
EmbModule_Ptr :: distinct rawptr
CFunction :: proc "c" (Object_Ptr, Object_Ptr) -> Object_Ptr
InitModuleFunction :: proc "c" () -> Object_Ptr
ThreadState_Ptr :: distinct rawptr
IntepreterState_Ptr :: distinct rawptr

@(default_calling_convention="c", link_prefix="pyodin_")
foreign lib {
    init :: proc() ---
	//test :: proc() ---
    create_module_definition :: proc(name: cstring) -> ModuleDefinition_Ptr ---
    append_method :: proc(ptr: ModuleDefinition_Ptr, callback: CFunction, name: cstring) ---
    setup_module :: proc(ptr: ModuleDefinition_Ptr, callback: InitModuleFunction) ---
    get_py_module_ptr :: proc(ptr: ModuleDefinition_Ptr) -> EmbModule_Ptr ---
    import_code :: proc(module_name: cstring, code: cstring) -> Object_Ptr ---
    get_procedure :: proc(module: Object_Ptr, procedure_name: cstring) -> Object_Ptr ---
    call_procedure :: proc(procedure_obj: Object_Ptr) -> Object_Ptr ---
    acquire_gil :: proc() -> c.int ---
    release_gil :: proc(gstate: c.int) ---
    get_interpreter :: proc(t: ThreadState_Ptr) -> IntepreterState_Ptr ---
    create_interpreter :: proc(t: ^ThreadState_Ptr) ---
}

@(default_calling_convention="c", link_prefix="Py")
foreign lib {
	Arg_ParseTuple :: proc(args: Object_Ptr, s: cstring, #c_vararg output: ..any) ---
    Eval_GetFrame :: proc() -> FrameObject_Ptr ---
    Frame_GetBack :: proc(frame: FrameObject_Ptr) -> FrameObject_Ptr ---
    Frame_GetLineNumber :: proc(frame: FrameObject_Ptr) -> c.int ---
    Frame_GetCode :: proc(frame: FrameObject_Ptr) -> CodeObject_Ptr ---
    Object_GetAttrString :: proc(obj: Object_Ptr, attr: cstring) -> Object_Ptr ---
    Unicode_AsUTF8 :: proc(unicode: Object_Ptr) -> cstring ---
    Module_Create2 :: proc(module: EmbModule_Ptr, abi: c.int) -> Object_Ptr ---
    Capsule_GetPointer :: proc(obj: Object_Ptr, name: cstring) -> rawptr ---
    ThreadState_Get :: proc() -> ThreadState_Ptr ---
    _NewInterpreter :: proc() -> ThreadState_Ptr ---
    ThreadState_Swap :: proc(state: ThreadState_Ptr) -> ThreadState_Ptr ---
    Eval_RestoreThread :: proc(state: ThreadState_Ptr) ---
    ThreadState_Clear :: proc(state: ThreadState_Ptr) ---
    ThreadState_New :: proc(state: IntepreterState_Ptr) -> ThreadState_Ptr ---
    Eval_ReleaseLock :: proc() ---
}

get_caller_source_code_location :: proc() -> runtime.Source_Code_Location {
    //frame := Eval_GetFrame()
    //name_obj := Object_GetAttrString(cast(Object_Ptr)frame, "co_name")
    //name := Unicode_AsUTF8(name_obj)
    //fmt.println("frame name =", name)

    return {}
}
