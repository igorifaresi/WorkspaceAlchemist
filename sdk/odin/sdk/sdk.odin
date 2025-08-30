package sdk

import "core:fmt"
import "core:os"
import "core:mem/tlsf"
import "core:mem"
import "core:time"
import "core:strconv"

import "ui"
import "ipc"
import "platform"
import "render"

generate_main_pipe_name :: proc(instance_id: int) -> string {
    return fmt.tprintf("wa-pipe-%d", instance_id)
}

easy_start_ui_module :: proc(update: proc()) {
	c: ui.Context

	instance_id := strconv.atoi(os.args[1])

    fmt.println("Hello from test module! ", instance_id)

    pipe := ipc.open_named_pipe(generate_main_pipe_name(instance_id))

    ui.load_font_palette()
    handle := render.setup_headless(400, 400)
    ipc.send_object_pipe(&pipe, transmute(uintptr)handle)
    ui.init_context(&c, context.allocator)
    ui.set_context(&c)

    data, err := mem.alloc_bytes(ui.FRAME_ARENA_SUGGESTED_SIZE)
    arena: mem.Arena
    mem.arena_init(&arena, data)
    frame_allocator := mem.arena_allocator(&arena)

    for {
        ipc.receive_object_pipe(&pipe, &c.io)

        ui.begin_frame(frame_allocator)
        update()
        ui.end_frame()
        render.draw_primitives(
            ui.generate_render_primitives(),
            c.io.viewport.w,
            c.io.viewport.h,
            true,
        )

        mem.arena_free_all(&arena)
    }
}