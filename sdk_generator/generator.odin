package sdk_generator

import odin_docs "core:odin/doc-format"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"

DOCS_SOURCE :: #load("../client/docs.odin-doc")

Struct :: struct {
    name: string,
    fields: [dynamic]Field,
}

Field :: struct {
    name: string,
    type_name: string,
    type_package: string,
    is_pointer: bool,
    is_bit_set: bool,
    bit_set_int_type_name: string,
    number_of_dimensions: int,
    dimensions_size: [8]int,
    init_string: string,
    _struct: Maybe(Struct),
}

Attribute :: struct {
    name: string,
    value: string,
}

Procedure :: struct {
    name: string,
    attributes: [dynamic]Attribute,
    params: [dynamic]Field,
    output: [dynamic]Field,
}

Package :: struct {
    name: string,
    fullpath: string,
    procedures: [dynamic]Procedure,
    structs: [dynamic]Struct,
}

w :: strings.write_string

parse_odin_doc :: proc() -> []Package {
    packages: [dynamic]Package
    
    docs, err := odin_docs.read_from_bytes(DOCS_SOURCE)
    if err != .None {
        panic("Error reading odin docs")
    }

    types := odin_docs.from_array(&docs.base, docs.types)
    entities := odin_docs.from_array(&docs.base, docs.entities)

    clone_str :: proc(doc: ^odin_docs.Header_Base, s: odin_docs.String) -> string {
        str_from_file := odin_docs.from_string(doc, s)
        str := strings.clone(str_from_file)
        return str
    }

    parse_field :: proc(
        docs: ^odin_docs.Header,
        entity_idx: odin_docs.Entity_Index,
        type_idx_to_package_name: map[int]string, 
        type_idx_to_struct: map[int]Struct,
    ) -> Field {
        types := odin_docs.from_array(&docs.base, docs.types)
        entities := odin_docs.from_array(&docs.base, docs.entities)

        param: Field

        param_entity := entities[entity_idx]
        param.name = clone_str(&docs.base, param_entity.name)
        param.init_string = clone_str(&docs.base, param_entity.init_string)
        param.type_package = type_idx_to_package_name[cast(int)param_entity.type]
        if s, ok := type_idx_to_struct[cast(int)param_entity.type]; ok do param._struct = s
        param_type := types[param_entity.type]

        if param_type.kind == .Pointer {
            pointer_type := types[odin_docs.from_array(&docs.base, param_type.types)[0]]
            param.type_name = clone_str(&docs.base, pointer_type.name)
            param.type_package = type_idx_to_package_name[cast(int)odin_docs.from_array(&docs.base, param_type.types)[0]]
            if s, ok := type_idx_to_struct[cast(int)odin_docs.from_array(&docs.base, param_type.types)[0]]; ok do param._struct = s
            param.is_pointer = true
        } else if param_type.kind == .Bit_Set {
            real_type := types[odin_docs.from_array(&docs.base, param_type.types)[0]]
            param.type_name = clone_str(&docs.base, real_type.name)
            param.is_bit_set = true
            param.type_package = type_idx_to_package_name[cast(int)odin_docs.from_array(&docs.base, param_type.types)[0]]

            if len(odin_docs.from_array(&docs.base, param_type.types)) > 1 {
                int_type := types[odin_docs.from_array(&docs.base, param_type.types)[1]]
                param.bit_set_int_type_name = clone_str(&docs.base, int_type.name)
            }   

            if s, ok := type_idx_to_struct[cast(int)odin_docs.from_array(&docs.base, param_type.types)[0]]; ok do param._struct = s
        } else if param_type.kind == .Array {
            param.number_of_dimensions = 1
            param.dimensions_size[0] = cast(int)param_type.elem_counts[0]
            param.type_package = type_idx_to_package_name[cast(int)odin_docs.from_array(&docs.base, param_type.types)[0]]
            if s, ok := type_idx_to_struct[cast(int)odin_docs.from_array(&docs.base, param_type.types)[0]]; ok do param._struct = s
            array_type := types[odin_docs.from_array(&docs.base, param_type.types)[0]]
            
            if array_type.kind == .Array {
                param.number_of_dimensions = 2
                param.dimensions_size[1] = cast(int)array_type.elem_counts[0]
                param.type_package = type_idx_to_package_name[cast(int)odin_docs.from_array(&docs.base, array_type.types)[0]]
                if s, ok := type_idx_to_struct[cast(int)odin_docs.from_array(&docs.base, array_type.types)[0]]; ok do param._struct = s
                array_type = types[odin_docs.from_array(&docs.base, array_type.types)[0]]
            }
            
            param.type_name = clone_str(&docs.base, array_type.name)
        } else {
            param.type_name = clone_str(&docs.base, param_type.name)
        }

        //fmt.println(param_entity.type)
        //fmt.println(param)

        return param
    }  

    type_idx_to_package_name := make(map[int]string)


    for doc_pkg in odin_docs.from_array(&docs.base, docs.pkgs) {
        for scope in odin_docs.from_array(&docs.base, doc_pkg.entries) {
            e := entities[scope.entity]

            if e.kind == .Type_Name {
                t := types[cast(int)e.type]
                if t.kind != .Basic {
                    type_idx_to_package_name[cast(int)e.type] = clone_str(&docs.base, doc_pkg.name) 
                }
            }
        }
    }

    type_idx_to_struct := make(map[int]Struct)

    for doc_pkg in odin_docs.from_array(&docs.base, docs.pkgs) {
        for scope in odin_docs.from_array(&docs.base, doc_pkg.entries) {
            e := entities[scope.entity]

            if e.kind == .Type_Name { 
                name := clone_str(&docs.base, e.name)
                t := types[e.type]
                
                if t.kind == .Named {
                    struct_entity := types[odin_docs.from_array(&docs.base, t.types)[0]]
                    if struct_entity.kind == .Struct {
                        s: Struct
                        s.name = name
                        //fmt.println(name, t.kind, struct_entity.kind)
                        for field_idx in odin_docs.from_array(&docs.base, struct_entity.entities) {
                            field := parse_field(docs, field_idx, type_idx_to_package_name, type_idx_to_struct)
                            //fmt.println("\t", field)
                            append(&s.fields, field)
                        }

                        type_idx_to_struct[cast(int)e.type] = s
                    }
                }
            }
        }
    }

    for doc_pkg in odin_docs.from_array(&docs.base, docs.pkgs) {
        pkg: Package 
        
        pkg.name = clone_str(&docs.base, doc_pkg.name)
        pkg.fullpath = clone_str(&docs.base, doc_pkg.fullpath)

        for scope in odin_docs.from_array(&docs.base, doc_pkg.entries) {
            e := entities[scope.entity]

            if e.kind == .Procedure {
                p: Procedure

                for doc_attribute in odin_docs.from_array(&docs.base, e.attributes) {
                    attribute: Attribute
                    attribute.name = clone_str(&docs.base, doc_attribute.name)
                    attribute.value = clone_str(&docs.base, doc_attribute.value)
                    append(&p.attributes, attribute)
                }

                p.name = clone_str(&docs.base, e.name)
                
                proc_type := types[e.type]
                input := types[odin_docs.from_array(&docs.base, proc_type.types)[0]]
                output := types[odin_docs.from_array(&docs.base, proc_type.types)[1]]

                for input_param_idx in odin_docs.from_array(&docs.base, input.entities) {
                    param := parse_field(docs, input_param_idx, type_idx_to_package_name, type_idx_to_struct)
                    append(&p.params, param)
                }


                for output_param_idx in odin_docs.from_array(&docs.base, output.entities) {
                    param := parse_field(docs, output_param_idx, type_idx_to_package_name, type_idx_to_struct)
                    append(&p.output, param)
                }


                append(&pkg.procedures, p)
            }
        }

        append(&packages, pkg)
    }

    return packages[:]
}

main :: proc() {
    fmt.println("Parsing ODIN DOC")

	packages := parse_odin_doc()

    fmt.println("Generating SDK")

	s := generate_python_loader(packages)
    ok := os.write_entire_file("sdk/odin/python/loader.odin", transmute([]u8)s)

    fmt.println("SDK generated")
}