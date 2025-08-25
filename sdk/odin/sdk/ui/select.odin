package ui

import "core:math"
import "core:fmt"

select_get_avaliable_space_callback :: proc(cnt: ^Container, input: []^Container) -> [2]f32 {
    //TODO
    avaliable_space := [2]f32{ cnt.bounds.w, 0 }
    return avaliable_space
}

select_end_callback :: proc(cnt: ^Container, input: []^Container) -> ^Container {
    dropdown_animation := get_animation(cnt, "downdown-animation")

    OFFSET :: 2

    y := cnt.bounds.h + OFFSET
    children_size: f32 = 0
	for child in input {
		child.x = 0
		child.y = y
		y += child.h
		children_size += child.h
	}

    children_size += 0

    rect := Rect{0, cnt.bounds.h + OFFSET, cnt.bounds.w, children_size * dropdown_animation.value.x}
    rect_shadow := Rect{rect.x - 2, rect.y - 2, rect.w + 4, rect.h + 4}

    dropdown_control_rect := get_control_rect(cnt, rect, "dropdown", {.Dont_Passthrough})

    cnt.children_clip_rect = rect

    push_rect(cnt, {
        bounds = rect_shadow,
        colors = solid_color(COLOR_SHADOW),
        roundness = 8,
        softness = 1,
    })

    push_rect(cnt, {
        bounds = rect,
        colors = small_v_gradient(COLOR_PRIMARY, 0.7),
        roundness = 6,
        softness = 1,
    })

    dec_zindex()

    append(&cnt.children, ..input)
    return cnt
}

@(plugin_callable)
begin_select :: proc(
    _bounds: Rect = {},
    loc := #caller_location,
) -> Component_Return_Rect {
    cnt := new_container_with_bounds(_bounds)
    push_id(loc)

    hold_animation := get_animation(cnt, "hold")
    hover_animation := get_animation(cnt, "hover")
    dropdown_animation := get_animation(cnt, "downdown-animation")
    control_rect := get_control_rect(cnt, {0, 0, cnt.bounds.w, cnt.bounds.h}, "*")
    dropdown_control_rect := get_control_rect(cnt, {}, "dropdown", {})
    //dropdown_control_rect := get_control_rect(cnt, {0, cnt.bounds.h, cnt.bounds.w, 200}, "dropdown", {.Dont_Passthrough})

    hold_animation.target.x = control_rect.hold ? 1 : 0
    hover_animation.target.x = control_rect.hover ? 1 : 0
    text_pos := align_string_into_rect({0, 0, cnt.bounds.w, cnt.bounds.h}, "Apple", .Medium, .Regular, {.Vertical_Center, .Left})
    icon_pos := align_string_into_rect({cnt.bounds.w - 30, 0, 30, cnt.bounds.h}, control_rect.open ? ICON_AngleUp : ICON_AngleDown, .Medium, .Icon, {.Vertical_Center, .Horizontal_Center})    
    
    text_pos.x += HALF_PADDING

    push_rect(cnt, {
        bounds = {-2, -2, cnt.bounds.w + 4, cnt.bounds.h + 4},
        colors = solid_color(COLOR_INPUT_BORDER),
        roundness = 8,
        softness = 1,
    })

    push_rect(cnt, {
        bounds = {0, 0, cnt.bounds.w, cnt.bounds.h},
        colors = solid_color(set_lightness(COLOR_INPUT_BG, 1 + clamp(hover_animation.value.x - dropdown_animation.value.x, 0, 1) * 0.3)),
        roundness = 6,
        softness = 1,
    })
    push_text(cnt, {
        pos = text_pos,
        text = "Apple",
        colors = solid_color(math.lerp(COLOR_TEXT, COLOR_TEXT_MUTED, dropdown_animation.value.x)),
        size = .Medium,
        kind = .Regular,
    })

    push_rect(cnt, {
        bounds = {cnt.bounds.w - 30, 0, 30, cnt.bounds.h},
        colors = small_v_gradient(set_lightness(COLOR_PRIMARY, 1 + clamp(hover_animation.value.x - dropdown_animation.value.x, 0, 1) * 0.3), dropdown_animation.value.x),
        roundness = 6,
        softness = 1,
    })
    push_text(cnt, {
        pos = icon_pos,
        text = control_rect.open ? ICON_AngleUp : ICON_AngleDown,
        colors = solid_color(math.lerp(COLOR_TEXT, COLOR_TEXT_MUTED, dropdown_animation.value.x)),
        size = .Medium,
        kind = .Icon,
    })

    pop_id()

    if control_rect.open {
        dropdown_animation.target.x = 1 
    } else {
        dropdown_animation.target.x = 0
    }

    real_open := dropdown_animation.value.x > 0.01

    if real_open {
        inc_zindex()
        push_layout(Layout{
            name = "select",
            end_callback = select_end_callback,
            get_avaliable_space_callback = select_get_avaliable_space_callback,
            cnt = cnt,
        })
    }

    control_rect.open = cast(b8)real_open

    return { cnt, control_rect }
}