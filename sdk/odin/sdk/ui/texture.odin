package ui

import "core:math"
import "core:fmt"

import "../render"

texture :: proc(
    handle: render.Texture_Handle,
    _bounds: Rect = {},
    colors := SOLID_WHITE,
    uv0: [2]f32 = {0, 0},
    uv1: [2]f32 = {1, 1},
    loc := #caller_location,
) -> Component_Return_Rect {
    cnt := new_container_with_bounds(_bounds, {-1, -1})

    push_id(loc)

    control_rect := get_control_rect(cnt, {0, 0, cnt.bounds.w, cnt.bounds.h}, "*")

    fade_in_animation := get_animation(cnt, "fade-in")
    fade_in_animation.target.x = 1

    push_transparency(fade_in_animation.value.x)

    push_texture(cnt, {
        bounds = {0, 0, cnt.bounds.w, cnt.bounds.h},
        handle = handle,
        colors = colors,
        uv0    = uv0,
        uv1    = uv1,
    })

    pop_transparency()

    pop_id()

    return { cnt, control_rect }
}