package ui

import "core:math"

@(plugin_callable)
texture :: proc(
    handle: rawptr,
    _bounds: Rect = {},
    colors: [4][4]f32 = {{1, 1, 1, 1}, {1, 1, 1, 1}, {1, 1, 1, 1}, {1, 1, 1, 1}},
    loc := #caller_location,
) -> Component_Return_Rect {
    cnt := new_container_with_bounds(_bounds, {-1, -1})

    push_id(loc)

    control_rect := get_control_rect(cnt, {0, 0, cnt.bounds.w, cnt.bounds.h}, "*")

    fade_in_animation := get_animation(cnt, "fade-in")
    fade_in_animation.target.x = 1

    push_transparency(fade_in_animation.value.x)

    push_texture(cnt, {
        bounds = cnt.bounds,
        handle = handle,
        colors = colors,
    })

    pop_transparency()

    pop_id()

    return { cnt, control_rect }
}