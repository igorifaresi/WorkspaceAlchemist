#+feature dynamic-literals

package main

import "core:thread"
import "core:time"
import "core:fmt"
import "core:sync"
import "core:strings"
import py "sdk:python"

Event_Kind :: enum {
    Empty,
    String,
    Number,
}

Event :: struct {
    kind: Event_Kind,
    from_instance: int,
    from_port: string,
    to_instance: int,
    to_port: string,
}

Connection :: struct {
    destination_instance: int,
    destination_port: string,
}

Module_Kind :: enum {
    Python,
    Native,
    Executable,
}

Module_Definition :: struct {
    name: cstring,
    kind: Module_Kind,
    code: cstring,
}

Module_Instance :: struct {
    id: int,
    def: ^Module_Definition,
    py_thread_state: py.ThreadState_Ptr,
    blocked: bool,
    mail_box: [dynamic]Event,
    mail_box_lock: sync.Mutex,
    output_connections: map[string][dynamic]Connection,
    output_connections_lock: sync.Mutex,
}

modules: map[string]^Module_Definition
instances: map[int]^Module_Instance
instances_counter := 0
@(thread_local) my_instance: ^Module_Instance

regist_module_python :: proc(name: cstring, code: cstring) {
    m := new(Module_Definition)

    
    m.name = name
    m.code = code
    modules[cast(string)name] = m
}

@(plugin_callable)
print_instance :: proc() {
    fmt.println("Hello from instance: ", my_instance)
}

@(plugin_callable)
dispatch_output_event :: proc(output_port: string) {
    connections: [dynamic]Connection

    {
        sync.lock(&my_instance.output_connections_lock)
        defer sync.unlock(&my_instance.output_connections_lock)

        item, ok := my_instance.output_connections[output_port]

        if !ok {
            return
        }

        connections = item 
    }

    for conn in connections {
        destination, ok := instances[conn.destination_instance]

        if !ok {
            return
        }

        sync.lock(&destination.mail_box_lock)
        defer sync.unlock(&destination.mail_box_lock)

        event := Event{
            kind = .Empty,
            from_instance = my_instance.id,
            from_port = output_port,
            to_instance = destination.id,
            to_port = conn.destination_port,
        }

        append(&destination.mail_box, event)
    }
}

instantiate_module :: proc(name: string) {
    loop_python :: proc(ptr: rawptr) {
        instance := cast(^Module_Instance)ptr
        my_instance = instance

        py.ThreadState_Swap(instance.py_thread_state)

        module_name := fmt.tprintf("%s%d", instance.def.name, instance.id) 

        module := py.import_code(strings.clone_to_cstring(module_name), instance.def.code)
	    update_procedure := py.get_procedure(module, "update")

        for {
            for sync.atomic_compare_exchange_strong(&instance.blocked, false, true) {}
            py.call_procedure(update_procedure)
        }
    }

    if def, ok := modules[name]; ok {
        instance := new(Module_Instance)
        instance.def = def
        instance.id = instances_counter
        instance.output_connections["saida"] = [dynamic]Connection{
            {0, "entrada"},
        }
                
        switch def.kind {
        case .Python:
            save_tstate := py.ThreadState_Get()

            py.create_interpreter(&instance.py_thread_state)            
            py.ThreadState_Swap(save_tstate)
            
            thread.create_and_start_with_data(instance, loop_python)
        case .Native:
        case .Executable:
        }

        instances[instance.id] = instance
        instances_counter += 1
    }
}