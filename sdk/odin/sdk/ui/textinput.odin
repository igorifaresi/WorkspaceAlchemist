package ui

import "core:strings"
import "core:text/edit"
import "core:fmt"
import "core:math"

@(plugin_callable)
textinput :: proc(
    ctx: ^Text_Editing_Context,
    _bounds: Rect = {},
    loc := #caller_location,
) -> Component_Return_Rect {
    cnt := new_container_with_bounds(_bounds)

    push_id(loc)

    hover_animation := get_animation(cnt, "hover")
    focus_animation := get_animation(cnt, "focus")
    control_rect := get_control_rect(cnt, {0, 0, cnt.bounds.w, cnt.bounds.h}, "*", {.Request_Focus})

    hover_animation.target.x = control_rect.hover ? 1 : 0
    focus_animation.target.x = control_rect.focus ? 1 : 0

    if control_rect.focus {
        hover_animation.target.x = 0
        process_text_edit_ctx(ctx) 
    }

    scroll_animation := get_animation(cnt, "scroll-animation")
    
    prepared := prepare_textinput({
        ctx = ctx,
        animation = scroll_animation,
        bounds = remove_padding_rect(
            get_content_rect_from_bounds(cnt.bounds),
            {2, 2, 2, 2},
        ),
        font_kind = .Regular,
        font_size = .Medium,
    })

    push_rect(cnt, {
        bounds = {-2, -2, cnt.bounds.w + 4, cnt.bounds.h + 4},
        colors = solid_color(math.lerp(COLOR_INPUT_BORDER, COLOR_ACCENT, focus_animation.value.x)),
        roundness = 8,
        softness = 1,
    })

    c.clip_rect = {0, 0, cnt.bounds.w, cnt.bounds.h}

    push_rect(cnt, {
        bounds = {0, 0, cnt.bounds.w, cnt.bounds.h},
        colors = solid_color(set_lightness(COLOR_INPUT_BG, 1 + hover_animation.value.x * 0.5)),
        roundness = 6,
        softness = 1,
    })
    push_text(cnt, {
        pos = prepared.text_pos,
        text = prepared.text,
        colors = small_v_gradient(COLOR_TEXT),
        size = .Medium,
        kind = .Regular,
    })
    push_rect(cnt, {
        bounds = prepared.cursor_rect,
        colors = solid_color(change_alpha(COLOR_TEXT, 0.5)),
        roundness = prepared.cursor_roundness,
        softness = prepared.cursor_softness,
    })

    c.clip_rect = DEFAULT_CLIP_RECT
    
    pop_id()

    return { cnt, control_rect }
}