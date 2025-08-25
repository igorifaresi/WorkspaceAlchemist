package ui

import "core:fmt"

get_window_title_height :: proc() -> f32 {
    return cast(f32)(DEFAULT_PADDING * 2 + measure_text(ICON_House, .Medium, .Icon).y)
}

window_get_avaliable_space_callback :: proc(cnt: ^Container, input: []^Container) -> [2]f32 {
    props := cast(^Window_Props)cnt.props_ptr

    padding: f32 = DEFAULT_PADDING
    if .No_Internal_Borders in props.options {
        padding = 0
    }

    title_height := get_window_title_height()
    
    return {cnt.bounds.w - padding * 2, cnt.bounds.h - title_height - padding * 2}
}

window_end_callback :: proc(cnt: ^Container, input: []^Container) -> ^Container {
    props := cast(^Window_Props)cnt.props_ptr

    padding: f32 = DEFAULT_PADDING
    if .No_Internal_Borders in props.options {
        padding = 0
    }

    height := get_window_title_height() 

    y: f32 = height + padding
	for child in input {
		child.x = padding
		child.y = y
		y += child.h + padding
	}

    dec_zindex()
    dec_zindex()
    dec_zindex()

    push_rect(cnt, {
        bounds = {-2, -2, cnt.bounds.w + 4, cnt.bounds.h + 4},
        colors = solid_color([4]f32{0, 0, 0, 0.2}),
        roundness = 15,
        softness = 1,
    })

    push_rect(cnt, {
        bounds = {0, 0, cnt.bounds.w, cnt.bounds.h},
        colors = solid_color({0.14, 0.15, 0.16, 1.0}),
        roundness = 12,
        softness = 1,
    })

    pop_transparency()

    append(&cnt.children, ..input)
    return cnt
}

begin_window :: proc(_bounds: Rect, props: Window_Props = {}, loc := #caller_location) -> Rect {
    cnt := new_container_with_bounds(_bounds)
    
    props_ptr := new(Window_Props, c.frame_allocator)
    props_ptr^ = props
    cnt.props_ptr = props_ptr

    push_id(loc)

    height := get_window_title_height()

    title_size := measure_text("MY WINDOW", .Large, .Bold)
    icon_size := measure_text(ICON_House, .Medium, .Icon)
    close_icon_size := measure_text(ICON_Xmark, .Large, .Icon)

    //TODO: this ugly
    inc_zindex()
    inc_zindex()

    get_control_rect(cnt, {0, 0, cnt.bounds.w, cnt.bounds.h}, "window-body", {.Dont_Passthrough})
    fade_in_animation := get_animation(cnt, "fade-in", .X, 0.125)
    fade_in_animation.target.x = 1

    push_transparency(fade_in_animation.value.x)

    inc_zindex()

    title_rect := get_control_rect(cnt, {0, 0, cnt.bounds.w, height}, "window-title")

    if title_rect.drag {
        cnt.bounds.x += title_rect.drag_vector.x
        cnt.bounds.y += title_rect.drag_vector.y
    }

    c.clip_rect = {0, 0, cnt.bounds.w, height + 2}

    push_rect(cnt, {
        bounds = {0, 0, cnt.bounds.w, 60},
        colors = solid_color(COLOR_SHADOW),
        roundness = 8,
        softness = 1,
    })

    inc_zindex()

    push_text(cnt, {
        pos = {DEFAULT_PADDING, height - icon_size.y - DEFAULT_PADDING},
        text = ICON_House,
        colors = small_v_gradient(COLOR_TEXT),
        size = .Medium,
        kind = .Icon,
    })

    push_text(cnt, {
        pos = {icon_size.x + DEFAULT_PADDING * 2, height - title_size.y + 3 - DEFAULT_PADDING},
        text = "My Window",
        colors = solid_color(COLOR_TEXT),
        size = .Large,
        kind = .Italic,
    })

    push_text(cnt, {
        pos = {cnt.bounds.w - DEFAULT_PADDING - close_icon_size.x - 2, height / 2 - close_icon_size.y / 2},
        text = ICON_Xmark,
        colors = small_v_gradient(COLOR_SECONDARY),
        size = .Large,
        kind = .Icon,
    })

    dec_zindex()


    c.clip_rect = {0, 0, cnt.bounds.w, height}

    push_rect(cnt, {
        bounds = {0, 0, cnt.bounds.w, 60},
        colors = horizontal_gradient(COLOR_SECONDARY, COLOR_PRIMARY),
        roundness = 12,
        softness = 1,
    })

    c.clip_rect = DEFAULT_CLIP_RECT

    dec_zindex()

    pop_id()

    inc_zindex()

    push_layout(Layout{
        name = "window",
        end_callback = window_end_callback,
        get_avaliable_space_callback = window_get_avaliable_space_callback,
        cnt = cnt,
    })

    return cnt.bounds
}