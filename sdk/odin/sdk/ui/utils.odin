package ui

import "core:fmt"
import "core:text/edit"
import "core:strings"
import "core:math"

new_container_with_bounds :: proc(_bounds: Rect, default_size: [2]f32 = {}) -> ^Container {
    bounds := resolve_bounds(_bounds, default_size)
    cnt := new_container()
    cnt.bounds = bounds
    return cnt
}

resolve_bounds :: proc(bounds: Rect, default_size: [2]f32 = {}) -> Rect {
    r := bounds

    is_zero :: proc(f: f32) -> bool {
        is := f < 0.001 && f > -0.001
        return is
    }

    if is_zero(bounds.w) {
        r.w = !is_zero(default_size.x) ? default_size.x : -1
    }

    if is_zero(bounds.h) {
        r.h = !is_zero(default_size.y) ? default_size.y : DEFAULT_WIDGET_HEIGHT
    }

    if r.w < 0 && r.h < 0 {
        size := get_avaliable_space()
        r.w = size.x
        r.h = size.y
    } else if r.w < 0 {
        r.w = get_avaliable_space().x
    } else if r.h < 0 {
        r.h = get_avaliable_space().y
    }

    return r
}

text_edit_ctx_from_string :: proc(ctx: ^Text_Editing_Context, s: string, allocator := context.allocator) {
    strings.builder_init(&ctx.builder, allocator)
	strings.write_string(&ctx.builder, s)
	edit.init(&ctx.state, allocator, allocator)
	edit.setup_once(&ctx.state, &ctx.builder)
}

process_text_edit_ctx :: proc(ctx: ^Text_Editing_Context) {
    if len(c.io.input_text) > 0 {
        edit.input_text(&ctx.state, c.io.input_text)
    }

    if len(c.io.text_edit_commands) > 0 {
        for cmd in c.io.text_edit_commands {
            edit.perform_command(&ctx.state, cmd)
        }    
    }
}

Prepared_Textinput :: struct {
    text: string,
    cursor_rect: Rect,
    cursor_roundness: f32,
    cursor_softness: f32,
    text_pos: [2]f32,
}

Prepare_Textinput_Params :: struct {
    ctx: ^Text_Editing_Context,
    animation: ^Animation,
    bounds: Rect,
    font_kind: Font_Kind,
    font_size: Font_Size,
}

prepare_textinput :: proc(using params: Prepare_Textinput_Params) -> Prepared_Textinput {
    prepared: Prepared_Textinput

    prepared.text = strings.to_string(ctx.builder)

    cursor_x_min := measure_text(prepared.text[:min(ctx.state.selection[0], ctx.state.selection[1])], font_size, font_kind).x
    cursor_x_max := measure_text(prepared.text[:max(ctx.state.selection[0], ctx.state.selection[1])], font_size, font_kind).x

    difference_right := (cursor_x_max + animation.value.x) - bounds.w
    if difference_right > -DEFAULT_PADDING {
        animation.target.x = animation.value.x - difference_right - DEFAULT_PADDING - 1
    }

    difference_left := (cursor_x_min + animation.value.x)
    if difference_left < DEFAULT_PADDING {
        animation.target.x = min(0, animation.value.x + (DEFAULT_PADDING - difference_left) - 1)
    }
    
    prepared.text_pos = align_string_into_rect(bounds, prepared.text, font_size, font_kind, {.Vertical_Center, .Left})
    prepared.text_pos.x += animation.value.x 

    prepared.cursor_rect.x = bounds.x + animation.value.x + cursor_x_min
    prepared.cursor_rect.y = bounds.y
    prepared.cursor_rect.w = max(cursor_x_max - cursor_x_min, CURSOR_WIDTH)
    prepared.cursor_rect.h = bounds.h

    prepared.cursor_roundness = prepared.cursor_rect.w < (CURSOR_WIDTH + 0.01) ? 0 : 4
    prepared.cursor_softness = prepared.cursor_rect.w < (CURSOR_WIDTH + 0.01) ? 0 : 1

    return prepared
}

iso_padding :: proc(offset: f32) -> Padding {
    padding := Padding{offset, offset, offset, offset}
    return padding
}

solid_color :: proc(c: [4]f32) -> [4][4]f32 {
    colors := [4][4]f32{
        [4]f32{c.r, c.g, c.b, c.a},
        [4]f32{c.r, c.g, c.b, c.a},
        [4]f32{c.r, c.g, c.b, c.a},
        [4]f32{c.r, c.g, c.b, c.a},
    }

    return colors
}

horizontal_gradient :: proc(a: [4]f32, b: [4]f32) -> [4][4]f32 {
    colors := [4][4]f32{
        [4]f32{a.r, a.g, a.b, a.a},
        [4]f32{b.r, b.g, b.b, b.a},
        [4]f32{a.r, a.g, a.b, a.a},
        [4]f32{b.r, b.g, b.b, b.a},
    }

    return colors
}

vertical_gradient :: proc(a: [4]f32, b: [4]f32) -> [4][4]f32 {
    colors := [4][4]f32{
        [4]f32{a.r, a.g, a.b, a.a},
        [4]f32{a.r, a.g, a.b, a.a},
        [4]f32{b.r, b.g, b.b, b.a},
        [4]f32{b.r, b.g, b.b, b.a},
    }

    return colors
}

set_lightness :: proc(c: [4]f32, lightness: f32) -> [4]f32 {
    color := c
    color.r *= lightness
    color.g *= lightness
    color.b *= lightness
    return color
}

change_alpha :: proc(c: [4]f32, alpha: f32) -> [4]f32 {
    color := c
    color.a = alpha * c.a
    return color
}

small_v_gradient :: proc(c: [4]f32, factor: f32 = 0.0) -> [4][4]f32 {
    colors := [4][4]f32{
        [4]f32{c.r + 0.10 * (1 - factor), c.g + 0.10 * (1 - factor), c.b + 0.10 * (1 - factor), c.a},
        [4]f32{c.r + 0.10 * (1 - factor), c.g + 0.10 * (1 - factor), c.b + 0.10 * (1 - factor), c.a},
        [4]f32{c.r + 0.05 * factor      , c.g + 0.05 * factor      , c.b + 0.05 * factor      , c.a},
        [4]f32{c.r + 0.05 * factor      , c.g + 0.05 * factor      , c.b + 0.05 * factor      , c.a},
    }

    return colors
}

check_rect_overlap :: proc(a: Rect, b: Rect) -> (bool, Rect) {
    x1 := max(a.x, b.x)
    y1 := max(a.y, b.y)
    x2 := min(a.x + a.w, b.x + b.w)
    y2 := min(a.y + a.h, b.y + b.h)

    if !(x1 < x2 && y1 < y2) {
        return false, Rect{}
    }

    intersection := Rect{
        x = x1,
        y = y1,
        w = x2 - x1,
        h = y2 - y1,
    }

    return true, intersection
}

push_rect :: proc(cnt: ^Container, rect: Primitive_Rect) {
    push_primitive(&cnt.primitives, rect)
}

push_text :: proc(cnt: ^Container, text: Primitive_Text) {    
    push_primitive(&cnt.primitives, text)
}

push_texture :: proc(cnt: ^Container, texture: Primitive_Texture) {    
    push_primitive(&cnt.primitives, texture)
}

push_line :: proc(cnt: ^Container, line: Primitive_Line) {    
    push_primitive(&cnt.primitives, line)
}

align_string_into_rect :: proc(
    bounds: Rect,
    text: string,
    size: Font_Size,
    kind: Font_Kind,
    alignment: Alignment,
) -> (pos: [2]f32) {
    size := measure_text(text, size, kind)

    if .Left in alignment {
        pos.x = bounds.x
    }
    
    if .Horizontal_Center in alignment {
        pos.x = bounds.x + bounds.w / 2 - size.x / 2
    }

    if .Right in alignment {
        pos.x = bounds.x + bounds.w - size.x
    }

    if .Top in alignment {
        pos.y = bounds.y
    }

    if .Vertical_Center in alignment {
        pos.y = bounds.y + bounds.h / 2 - size.y / 2
    }

    if .Bottom in alignment {
        pos.y = bounds.y + bounds.h - size.y
    }
    
    return pos
}

get_content_rect_from_bounds :: proc(bounds: Rect) -> Rect {
    return {0, 0, bounds.w, bounds.h}
}

get_center_rect :: proc(src: Rect, width: f32, height: f32) -> Rect {
    x := (src.w / 2 - width / 2) + src.x
    y := (src.h / 2 - height / 2) + src.y
    return { x, y, width, height }
}

get_rect_center_point :: proc(r: Rect) -> [2]f32 {
    x := r.w / 2 + r.x
    y := r.h / 2 + r.y
    return { x, y }
}

cut_rect_left :: proc(src: ^Rect, amount: f32) -> (cut: Rect) {
    cut = Rect{ src.x, src.y, amount, src.h }
    src.x += amount
    src.w -= amount
    return cut
}

cut_rect_top :: proc(src: ^Rect, amount: f32) -> (cut: Rect) {
    cut = Rect{ src.x, src.y, src.w, amount }
    src.y += amount
    src.h -= amount
    return cut
}

cut_rect_right :: proc(src: ^Rect, amount: f32) -> (cut: Rect) {
    cut = Rect{ src.x + src.w - amount, src.h, amount, src.h }
    src.w -= amount
    return cut
}

cut_rect_bottom :: proc(src: ^Rect, amount: f32) -> (cut: Rect) {
    cut = Rect{ src.x, src.y + src.h - amount, src.w, amount }
    src.h -= amount
    return cut
}

scale_rect :: proc(src: Rect, amount_in_units: f32) -> Rect {
    result: Rect
    result.x = src.x - amount_in_units
    result.y = src.y - amount_in_units
    result.w = src.w + amount_in_units * 2
    result.h = src.h + amount_in_units * 2
    return result
}

trim_rect :: proc(src: Rect, amount_in_units: f32) -> Rect {
    result: Rect
    result.x = src.x + amount_in_units
    result.y = src.y + amount_in_units
    result.w = src.w - amount_in_units * 2
    result.h = src.h - amount_in_units * 2
    return result
}

offset_rect :: proc(src: Rect, offset: [2]f32) -> Rect {
    result := src
    result.x += offset.x
    result.y += offset.y
    return result
}

remove_padding_rect :: proc(src: Rect, padding: Padding) -> Rect {
    result: Rect
    result.x = src.x + padding.right
    result.y = src.y + padding.top
    result.w = src.w - padding.left - padding.right
    result.h = src.h - padding.bottom - padding.top
    return result
}

is_mouse_inside :: proc(bounds: Rect) -> bool {
    horizontal_inside := c.io.mouse_pos.x >= bounds.x && c.io.mouse_pos.x <= (bounds.x + bounds.w)
    vertical_inside := c.io.mouse_pos.y >= bounds.y && c.io.mouse_pos.y <= (bounds.y + bounds.h)
    return horizontal_inside && vertical_inside
}