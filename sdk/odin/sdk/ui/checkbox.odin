package ui

@(plugin_callable)
checkbox :: proc(
    enabled: ^bool,
    text: string,
    _bounds: Rect = {},
    loc := #caller_location,
) -> Component_Return_Rect {
    cnt := new_container_with_bounds(_bounds)

    push_id(loc)

    rect := get_content_rect_from_bounds(cnt.bounds)
    enabled_animation := get_animation(cnt, "open")
    hover_animation := get_animation(cnt, "hover")
    marker_rect := get_center_rect(cut_rect_left(&rect, DEFAULT_WIDGET_HEIGHT), DEFAULT_WIDGET_HEIGHT, DEFAULT_WIDGET_HEIGHT)

    control_rect := get_control_rect(cnt, marker_rect, "*")

    hover_animation.target.x = control_rect.hover ? 1 : 0

    push_rect(cnt, {
        bounds = marker_rect,
        thickness = 2,
        colors = small_v_gradient(set_lightness(COLOR_PRIMARY, 1 + hover_animation.value.x * 0.3)),
        roundness = 6,
        softness = 1,
    })

    if enabled^ {
        enabled_animation.target.x = 1
    } else {
        enabled_animation.target.x = 0
    }

    if enabled_animation.value.x > 0.01 {
        icon_pos := align_string_into_rect({0, 0, DEFAULT_WIDGET_HEIGHT, DEFAULT_WIDGET_HEIGHT}, ICON_Check, .Large, .Icon, {.Vertical_Center, .Horizontal_Center})

        c.clip_rect = {0, 0, DEFAULT_WIDGET_HEIGHT * enabled_animation.value.x, DEFAULT_WIDGET_HEIGHT}

        push_text(cnt, {
            pos = icon_pos,
            text = ICON_Check,
            colors = small_v_gradient(COLOR_SECONDARY),
            size = .Large,
            kind = .Icon,
        })

        c.clip_rect = DEFAULT_CLIP_RECT
    }

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