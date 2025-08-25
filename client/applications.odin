package main

import "core:container/small_array"
import "core:thread"
import "core:time"
import "core:fmt"
import "core:sync"
import "core:bytes"
import "core:strings"
import "core:strconv"
import "core:image/png"
import "core:image"
import "core:os"
import D3D11 "vendor:directx/d3d11"
import win "core:sys/windows"
import "vendor:stb/rect_pack"

import "sdk:sdk"
import "sdk:sdk/ui"
import "sdk:sdk/ipc"

ICON_ATLAS_WIDTH :: 4096
ICON_ATLAS_HEIGHT :: 4096

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

Application_Instance :: struct {
    id: int,
    name: string,
    command_line: string,
    blocked: bool,
    ready: bool,
    rect: ui.Rect,
    surface_texture: rawptr,
    surface_handle: win.HANDLE,
    mail_box: [dynamic]Event,
    mail_box_lock: sync.Mutex,
    output_connections: map[string][dynamic]Connection,
    output_connections_lock: sync.Mutex,
}

Application_Manifest :: struct {
    icon_uv0: [2]f32,
    icon_uv1: [2]f32,
}

manifests: small_array.Small_Array(64, Application_Manifest)
instances: small_array.Small_Array(64, Application_Instance)
instances_counter := 0
@(thread_local) my_instance: ^Application_Instance

/*
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
}*/

read_all_manifests :: proc() {
    manifests = {}

    handle, open_err := os.open("applications")
    if open_err != nil {
        panic("Error opening src modules folder")
    }

    files, dir_err := os.read_dir(handle, 1024)
    if dir_err != nil {
        panic("Unable to read dir")
    }

    atlas := make([]byte, ICON_ATLAS_WIDTH * ICON_ATLAS_HEIGHT * size_of([4]byte))

    pack: rect_pack.Context
    rects: [dynamic]rect_pack.Rect
    imgs: [dynamic]^image.Image
    nodes := make([]rect_pack.Node, ICON_ATLAS_WIDTH)
    
    rect_pack.init_target(
        &pack,
        ICON_ATLAS_WIDTH,
        ICON_ATLAS_HEIGHT,
        &nodes[0],
        cast(i32)len(nodes),
    )

    for f in files {
        if f.is_dir {
            path := strings.concatenate({
                "applications\\", f.name, "\\icon.png"
            })

            img, img_err := image.load_from_file(path) 
            
            if img_err != nil {
                panic("Image load error")
            }

            append(&rects, rect_pack.Rect{
                w = cast(rect_pack.Coord)img.width,
                h = cast(rect_pack.Coord)img.height,
            })

            append(&imgs, img)
        }
    }

    rect_pack.pack_rects(&pack, &rects[0], cast(i32)len(rects))

    for r, i in rects {
        for y in 0..<r.h {
            for x in 0..<r.w {
                pixel := bytes.buffer_next(&imgs[i].pixels, 4)
                idx := (y * ICON_ATLAS_WIDTH + x) * size_of([4]byte)
                
                atlas[idx + 0] = pixel[0]
                atlas[idx + 1] = pixel[1]
                atlas[idx + 2] = pixel[2]
                atlas[idx + 3] = pixel[3]
            }
        }
    }

    ui.load_texture(atlas, ICON_ATLAS_WIDTH, ICON_ATLAS_HEIGHT)

    fmt.println(rects)
}

instantiate_loop :: proc(ptr: rawptr) {
    instance := cast(^Application_Instance)ptr

    pipe := ipc.create_named_pipe(sdk.generate_main_pipe_name(instance.id))
    process := ipc.create_process(instance.command_line)

    ipc.wait_for_client(&pipe)

    tmp: uintptr  
    ipc.receive_object_pipe(&pipe, &tmp)
    instance.surface_handle = transmute(win.HANDLE)tmp

    for {
        for sync.atomic_compare_exchange_strong(&instance.blocked, false, true) {
            time.sleep(1 * time.Millisecond)
        }
        io_copy := c.io
        io_copy.mouse_pos -= {instance.rect.x, instance.rect.y + ui.get_window_title_height()}
        io_copy.viewport = {0, 0, instance.rect.w, instance.rect.h}
        ipc.send_object_pipe(&pipe, io_copy)
    }

    ipc.close_process(&process)
}

instantiate_application :: proc(name: string) {
    instance: Application_Instance
    instance.name = name
    instance.id = instances_counter
    instance.rect.x = 50 * cast(f32)instances_counter
    instance.rect.y = 50 * cast(f32)instances_counter 
    instance.rect.w = 400
    instance.rect.h = 400
    instance.command_line = strings.concatenate({
        "applications\\", instance.name, "\\app.exe ", fmt.tprintf("%d", instance.id)
    })

    small_array.push(&instances, instance)

    top := &instances.data[instances.len - 1]

    instances_counter += 1

    thread.create_and_start_with_data(top, instantiate_loop)
}