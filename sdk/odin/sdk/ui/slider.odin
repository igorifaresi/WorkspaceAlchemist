package ui

import "core:math"

@(plugin_callable)
slider :: proc(
    value: ^f32,
    min: f32,
    max: f32,
    _bounds: Rect = {},
    loc := #caller_location,
) -> Component_Return_Rect {
    cnt := new_container_with_bounds(_bounds, {-1, DEFAULT_SLIDER_HEIGHT})

    push_id(loc)

    BAR_HEIGHT :: 4
    POINTER_SIZE :: 20

    hover_animation := get_animation(cnt, "hover")
    hold_animation := get_animation(cnt, "hold")
    control_rect := get_control_rect(cnt, {0, 0, cnt.bounds.w, cnt.bounds.h}, "*")

    hover_animation.target.x = control_rect.hover ? 1 : 0
    hold_animation.target.x = control_rect.hold ? 1 : 0
    
    pointer_x := ((value^ - min) / (max - min)) * (cnt.bounds.w - POINTER_SIZE)

    if control_rect.click || control_rect.hold {
        value^ = control_rect.movable_marker_pos.x * (max - min) + min
    }

    push_rect(cnt, {
        bounds = {0 - 2, cnt.bounds.h / 2 - BAR_HEIGHT / 2 - 2, cnt.bounds.w + 4, BAR_HEIGHT + 4},
        colors = solid_color(COLOR_SHADOW),
        roundness = 4,
        softness = 1,
    }) 
    push_rect(cnt, {
        bounds = {0, cnt.bounds.h / 2 - BAR_HEIGHT / 2, cnt.bounds.w, BAR_HEIGHT},
        colors = small_v_gradient(COLOR_PRIMARY, 1),
        roundness = 3,
        softness = 1,
    }) 
    push_rect(cnt, {
        bounds = {pointer_x - 2, -2, POINTER_SIZE + 4, POINTER_SIZE + 4},
        colors = solid_color(COLOR_SHADOW),
        roundness = POINTER_SIZE / 2 + 2,
        softness = 1,
    })
    push_rect(cnt, {
        bounds = {pointer_x, 0, POINTER_SIZE, POINTER_SIZE},
        colors = small_v_gradient(set_lightness(COLOR_PRIMARY, 1 + clamp(hover_animation.value.x - hold_animation.value.x, 0, 1) * 0.3), hold_animation.value.x),
        roundness = POINTER_SIZE / 2,
        softness = 1,
    })

    pop_id()

    return { cnt, control_rect }
}