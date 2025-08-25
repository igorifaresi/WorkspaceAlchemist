package sdk_generator

import "core:fmt"
import "core:strings"
import "core:strconv"

generate_python_loader :: proc(packages: []Package) -> string {
    b: strings.Builder

    strings.builder_init(&b)

    w(&b, "// THIS FILE IS AUTO GENERATED, DO NOT EDIT\n\n")
    w(&b, "package python\n\n") 
    w(&b, "import \"core:fmt\"\n") 
    w(&b, "import \"core:c\"\n") 
    w(&b, "import \"base:runtime\"\n\n") 

    w(&b, "import \"sdk:ui\"\n") 
    w(&b, "import py \"sdk:python\"\n\n") 

    w(&b, "IMPLEMENT_PYTHON_LOADER :: #config(IMPLEMENT_PYTHON_LOADER, false)\n\n") 
    w(&b, "when IMPLEMENT_PYTHON_LOADER {\n\n") 
    
    w(&b, "py_module: py.ModuleDefinition_Ptr\n")
    w(&b, "load_python_sdk :: proc() {\n")
    w(&b, "\tpy_module = py.create_module_definition(\"vtable\")\n\n")
    for pkg in packages {
        for p in pkg.procedures[:] {
            found_attribute := false
            for attribute in p.attributes {
                if attribute.name == "plugin_callable" {
                    found_attribute = true
                    break
                }
            }

            if !found_attribute {
                continue
            }

            w(&b, "\t")
            w(&b, pkg.name)
            w(&b, "_")
            w(&b, p.name)
            w(&b, "_python :: proc \"c\" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {\n")

            w(&b, "\t\tcontext = runtime.default_context()\n")

            for param in p.params {
                process_field :: proc(b: ^strings.Builder, field: Field) {
                    if field.is_pointer {
                        w(b, "\t\t")
                        w(b, field.name)
                        w(b, "_tmp: py.Object_Ptr\n")
                    } else if field.is_bit_set {
                        w(b, "\t\t")
                        w(b, field.name)
                        w(b, "_tmp: c.long\n")
                    } else {
                        switch field.type_name {
                        case "int", "i32", "i64", "u32", "u64":
                            if field.number_of_dimensions == 0 {
                                w(b, "\t\t")
                                w(b, field.name)
                                w(b, "_tmp: c.int\n")
                            } else {
                                for i in 0..<field.dimensions_size[0] {
                                    w(b, "\t\t")
                                    w(b, field.name)
                                    w(b, "_tmp_")
                                    w(b, fmt.tprintf("%d", i))
                                    w(b, ": int\n")
                                }
                            }
                        case "f32", "f64":
                            if field.number_of_dimensions == 0 {
                                w(b, "\t\t")
                                w(b, field.name)
                                w(b, "_tmp: f32\n")
                            } else {
                                for i in 0..<field.dimensions_size[0] {
                                    w(b, "\t\t")
                                    w(b, field.name)
                                    w(b, "_tmp_")
                                    w(b, fmt.tprintf("%d", i))
                                    w(b, ": f32\n")
                                }
                            }
                        case "untyped string":
                            w(b, "\t\t")
                            w(b, field.name)
                            w(b, "_tmp: cstring\n")
                        case "Allocator":
                        case "Source_Code_Location":
                            w(b, "\t\tloc := py.get_caller_source_code_location()\n")
                        case:
                            if s, ok := field._struct.?; ok {
                                for struct_field in s.fields[:] {
                                    w(b, "\t\t")
                                    w(b, field.name)     
                                    w(b, "_")     
                                    w(b, struct_field.name)     
                                    w(b, "_tmp: ")     
                                    w(b, struct_field.type_name)
                                    w(b, "\n")     
                                }
                            }
                        }
                    }
                }

                process_field(&b, param)
            }

            w(&b, "\n")
            w(&b, "\t\tpy.Arg_ParseTuple(args, \"")

            for param in p.params {
                process_field :: proc(b: ^strings.Builder, field: Field) {
                    if field.is_pointer {
                        w(b, "O")
                    } else if field.is_bit_set {
                        w(b, "l")
                    } else {
                        switch field.type_name {
                        case "int", "i32", "i64", "u32", "u64":
                            if field.number_of_dimensions == 0 {
                                w(b, "i")
                            } else {
                                w(b, "(")
                                for _ in 0..<field.dimensions_size[0] {
                                    w(b, "i")
                                }
                                w(b, ")")
                            }
                        case "f32", "f64":
                            if field.number_of_dimensions == 0 {
                                w(b, "f")
                            } else {
                                w(b, "(")
                                for _ in 0..<field.dimensions_size[0] {
                                    w(b, "f")
                                }
                                w(b, ")")
                            }
                        case "untyped string":
                            if field.number_of_dimensions == 0 {
                                w(b, "s")
                            } else {
                                w(b, "(")
                                for _ in 0..<field.dimensions_size[0] {
                                    w(b, "s")
                                }
                                w(b, ")")
                            }
                        case "Source_Code_Location":
                        case "Allocator":
                        case:
                            if s, ok := field._struct.?; ok {
                                w(b, "(")
                                for struct_field in s.fields[:] {
                                    process_field(b, struct_field)
                                }
                                w(b, ")")
                            }
                        }
                    }
                }

                process_field(&b, param)
            }

            w(&b, "\"")
            
            for param in p.params {
                if param.number_of_dimensions == 0 {
                    if param.type_name != "Source_Code_Location" && param.type_name != "Allocator" {
                        if s, ok := param._struct.?; ok && !param.is_pointer {
                            for field in s.fields[:] {
                                w(&b, ", &")
                                w(&b, param.name)     
                                w(&b, "_")     
                                w(&b, field.name)     
                                w(&b, "_tmp")      
                            }
                        } else {
                            w(&b, ", &")
                            w(&b, param.name)
                            w(&b, "_tmp") 
                        }
                    }
                } else {
                    for i in 0..<param.dimensions_size[0] {
                        w(&b, ", &")
                        w(&b, param.name)
                        w(&b, "_tmp_") 
                        w(&b, fmt.tprintf("%d", i))
                    }
                }
            }

            w(&b, ")\n\n")

            w(&b, "\t\t")
            if pkg.name != "main" {
                w(&b, pkg.name)
                w(&b, ".")
            }
            w(&b, p.name)
            w(&b, "(")
            for param, param_index in p.params {
                if param_index != 0 {
                    w(&b, ", ")
                }

                if param.is_pointer {
                    w(&b, "cast(^")
                    if len(param.type_package) > 0 {
                        w(&b, param.type_package)
                        w(&b, ".")
                    }
                    w(&b, param.type_name)
                    w(&b, ")py.Capsule_GetPointer(")
                    w(&b, param.name)
                    w(&b, "_tmp, nil)")
                } else if param.is_bit_set {
                    w(&b, "transmute(bit_set[")
                    if len(param.type_package) > 0 {
                        w(&b, param.type_package)
                        w(&b, ".")
                    }
                    w(&b, param.type_name)
                    if len(param.bit_set_int_type_name) > 0 {
                        w(&b, "; ")
                        w(&b, param.bit_set_int_type_name)
                    }
                    w(&b, "])(cast(u64)")
                    w(&b, param.name)
                    w(&b, "_tmp)")
                } else {
                    if param.number_of_dimensions == 0 {
                        if param.type_name != "Source_Code_Location" && param.type_name != "Allocator" {
                            if s, ok := param._struct.?; ok && !param.is_pointer {
                                w(&b, "{")
                                for field, field_index in s.fields[:] {
                                    if field_index != 0 {
                                        w(&b, ", ")
                                    }

                                    w(&b, param.name)     
                                    w(&b, "_")     
                                    w(&b, field.name)     
                                    w(&b, "_tmp")      
                                }
                                w(&b, "}")
                            } else {
                                w(&b, "cast(")
                                if len(param.type_package) > 0 {
                                    w(&b, param.type_package)
                                    w(&b, ".")
                                }
                                w(&b, param.type_name == "untyped string" ? "string" : param.type_name)
                                w(&b, ")")
                                w(&b, param.name)
                                w(&b, "_tmp") 
                            }
                        } else if param.type_name == "Source_Code_Location" {
                            w(&b, "loc")
                        } else if param.type_name == "Allocator" {
                            w(&b, "context.allocator")
                        }
                    } else {
                        w(&b, "{")
                        for i in 0..<param.dimensions_size[0] {
                            if i != 0 {
                                w(&b, ", ")
                            }

                            w(&b, param.name)
                            w(&b, "_tmp_") 
                            w(&b, fmt.tprintf("%d", i))
                        }
                        w(&b, "}")
                    }
                }
            }
            w(&b, ")\n\n")

            w(&b, "\t\treturn nil\n")
            w(&b, "\t}\n\n")
        }
 
        for p in pkg.procedures[:] {
            found_attribute := false
            for attribute in p.attributes {
                if attribute.name == "plugin_callable" {
                    found_attribute = true
                    break
                }
            }

            if !found_attribute {
                continue
            }

            w(&b, "\tpy.append_method(py_module, ")
            w(&b, pkg.name)
            w(&b, "_")
            w(&b, p.name)
            w(&b, "_python, \"")
            if pkg.name != "main" {
                w(&b, pkg.name)
                w(&b, "_")
            }
            w(&b, p.name)
            w(&b, "\")\n")
        }
    }

    w(&b, "\n")
    w(&b, "\tinit :: proc \"c\" () -> py.Object_Ptr {\n") 
    w(&b, "\t\treturn py.Module_Create2(py.get_py_module_ptr(py_module), py.ABI_VERSION)\n")
    w(&b, "\t}\n\n")

    w(&b, "\tpy.setup_module(py_module, init)\n")
    w(&b, "}\n\n")


    w(&b, "} else {\n\n")
    w(&b, "load_python_sdk :: proc() {}\n\n")
    w(&b, "}\n")
    
    output := strings.to_string(b)

    return output
}