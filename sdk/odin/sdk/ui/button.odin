package ui

import "base:runtime"
import "core:math"

@(plugin_callable)
button :: proc(text: string, bounds: Rect = {}, loc := #caller_location) -> Component_Return_Rect {
    return button_ex({
        text = text,
        _bounds = bounds,
        color = COLOR_PRIMARY,
        text_kind = .Regular,
        loc = loc,
    })
}

@(plugin_callable)
icon_button :: proc(icon: string, loc := #caller_location) -> Component_Return_Rect {
    return button_ex({
        text = icon,
        _bounds = { w = DEFAULT_WIDGET_HEIGHT, h = DEFAULT_WIDGET_HEIGHT },
        color = COLOR_PRIMARY,
        text_kind = .Icon,
        loc = loc,
    })
}

button_ex :: proc(
    using props: struct {
        text: string,
        _bounds: Rect,
        color: [4]f32,
        text_kind: Font_Kind,
        loc: runtime.Source_Code_Location,
    },
) -> Component_Return_Rect {
    cnt := new_container_with_bounds(_bounds)
    push_id(loc)

    hold_animation := get_animation(cnt, "hold")
    hover_animation := get_animation(cnt, "hover")
    control_rect := get_control_rect(cnt, {0, 0, cnt.bounds.w, cnt.bounds.h}, "*")

    hold_animation.target.x = control_rect.hold ? 1 : 0
    hover_animation.target.x = control_rect.hover ? 1 : 0
    text_pos := align_string_into_rect({0, 0, cnt.bounds.w, cnt.bounds.h}, text, .Medium, text_kind, {.Vertical_Center, .Horizontal_Center})
    
    push_rect(cnt, {
        bounds = {-2, -2, cnt.bounds.w + 4, cnt.bounds.h + 4},
        colors = solid_color(COLOR_SHADOW),
        roundness = 8,
        softness = 1,
    })
    push_rect(cnt, {
        bounds = {0, 0, cnt.bounds.w, cnt.bounds.h},
        colors = small_v_gradient(set_lightness(color, 1 + clamp(hover_animation.value.x - hold_animation.value.x, 0, 1) * 0.3), hold_animation.value.x),
        roundness = 6,
        softness = 1,
    })
    push_text(cnt, {
        pos = text_pos,
        text = text,
        colors = solid_color(math.lerp(COLOR_TEXT, COLOR_TEXT_MUTED, hold_animation.value.x)),
        size = .Medium,
        kind = text_kind,
    }) 

    pop_id()

    return { cnt, control_rect }
}

select_button :: proc(
    text: string,
    _bounds: Rect = {},
    loc := #caller_location,
) -> Component_Return_Rect {
    cnt := new_container_with_bounds(_bounds)
    push_id(loc)

    hold_animation := get_animation(cnt, "hold")
    hover_animation := get_animation(cnt, "hover")
    control_rect := get_control_rect(cnt, {0, 0, cnt.bounds.w, cnt.bounds.h}, "*")

    hold_animation.target.x = control_rect.hold ? 1 : 0
    hover_animation.target.x = control_rect.hover ? 1 : 0
    text_pos := align_string_into_rect({0, 0, cnt.bounds.w, cnt.bounds.h}, text, .Medium, .Regular, {.Vertical_Center, .Left})
    text_pos.x += HALF_PADDING + hover_animation.value.x * DEFAULT_PADDING
    
    c.clip_rect = {0, 0, cnt.bounds.w, cnt.bounds.h}

    push_rect(cnt, {
        bounds = {0, 0, cnt.bounds.w + 50 + hold_animation.value.x * 200, cnt.bounds.h},
        colors = horizontal_gradient(change_alpha({1, 1, 1, 0.2 + hold_animation.value.x * 0.1}, hover_animation.value.x), {}),
        roundness = 4,
        softness = 1,
    })
    push_text(cnt, {
        pos = text_pos,
        text = text,
        colors = solid_color(COLOR_TEXT),
        size = .Medium,
        kind = .Regular,
    })

    c.clip_rect = DEFAULT_CLIP_RECT

    pop_id()

    return { cnt, control_rect }
}

node_editor_button :: proc(
    enabled: ^bool,
    text: string,
    bullet_color: [4]f32,
    _bounds: Rect = {},
    loc := #caller_location,
) -> Component_Return_Rect {
    cnt := new_container_with_bounds(_bounds)

    push_id(loc)

    SIZE :: 24

    rect := get_content_rect_from_bounds(cnt.bounds)
    enabled_animation := get_animation(cnt, "open")
    hover_animation := get_animation(cnt, "hover")
    color_animation := get_animation(cnt, "color", .Color)
    marker_rect := get_center_rect(cut_rect_left(&rect, SIZE), SIZE, SIZE)

    control_rect := get_control_rect(cnt, marker_rect, "*")

    hover_animation.target.x = control_rect.hover ? 1 : 0
    color_animation.target = bullet_color

    if enabled^ {
        enabled_animation.target.x = 1
    } else {
        enabled_animation.target.x = 0
    }

    push_rect(cnt, {
        bounds = marker_rect,
        colors = small_v_gradient(set_lightness(color_animation.value, 1 + hover_animation.value.x * 0.3)),
        roundness = SIZE / 2,
        softness = 1,
        thickness = 2 + enabled_animation.value.x * SIZE
    })


    text_pos := align_string_into_rect(rect, text, .Medium, .Regular, {.Left, .Vertical_Center})
    text_pos.x += DEFAULT_PADDING
    push_text(cnt, {
        pos = text_pos,
        text = text,
        colors = small_v_gradient(COLOR_TEXT),
        size = .Medium,
        kind = .Regular,
    })

    if control_rect.click {
        enabled^ = !enabled^
    }
    
    pop_id()

    return { cnt, control_rect }
}