package ui

import "core:fmt"

// manual

manual_layout_get_avaliable_space_callback :: proc(cnt: ^Container, input: []^Container) -> [2]f32 {
    avaliable_space := [2]f32{ cnt.bounds.w, cnt.bounds.h }
    return avaliable_space
}

manual_layout_end_callback :: proc(cnt: ^Container, input: []^Container) -> ^Container {
    append(&cnt.children, ..input)
    return cnt
}

begin_manual_layout :: proc(_bounds: Rect) {
    cnt := new_container_with_bounds(_bounds)
    push_layout(Layout{
        name = "manual",
        end_callback = manual_layout_end_callback,
        get_avaliable_space_callback = manual_layout_get_avaliable_space_callback,
        cnt = cnt,
    })
}

// column

column_get_avaliable_space_callback :: proc(cnt: ^Container, input: []^Container) -> [2]f32 {
    used_height: f32 = 0
	for child in input {
		used_height += child.h + DEFAULT_PADDING
	}
    
    return { cnt.bounds.w, cnt.bounds.h - used_height }
}

column_end_callback :: proc(cnt: ^Container, input: []^Container) -> ^Container {
    y: f32 = 0
	for child in input {
		child.x = 0
		child.y = y
		y += child.h + DEFAULT_PADDING
	}

    cnt.bounds.h = y

    append(&cnt.children, ..input)
    return cnt
}

begin_column :: proc(_bounds: Rect = {}) {
    cnt := new_container_with_bounds(_bounds, {-1, -1})

    push_layout(Layout{
        name = "column",
        end_callback = column_end_callback,
        get_avaliable_space_callback = column_get_avaliable_space_callback,
        cnt = cnt,
    })
}

// row

row_get_avaliable_space_callback :: proc(cnt: ^Container, input: []^Container) -> [2]f32 {
    used_width: f32 = 0
    for child in input {
        used_width += child.w
    }
    
    return { cnt.bounds.w - used_width, cnt.bounds.h }
}

row_end_callback :: proc(cnt: ^Container, input: []^Container) -> ^Container {
    x: f32 = 0
    h: f32 = 0
    for child in input {
        child.x = x
        child.y = 0
        x += child.w
        h = max(h, child.h)
    }

    cnt.bounds.w = x
    cnt.bounds.h = h

    append(&cnt.children, ..input)
    return cnt
}

begin_row :: proc(_bounds: Rect = {}) {
    cnt := new_container_with_bounds(_bounds, {-1, -1})

    push_layout(Layout{
        name = "row",
        end_callback = row_end_callback,
        get_avaliable_space_callback = row_get_avaliable_space_callback,
        cnt = cnt,
    })
}
