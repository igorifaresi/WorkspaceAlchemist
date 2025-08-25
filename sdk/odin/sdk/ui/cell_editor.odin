package ui
/*
import "core:fmt"
import "core:encoding/csv"
import "core:strings"

@(plugin_callable)
cell_editor_state_from_csv :: proc(s: string) -> Cell_Editor_State {
    state: Cell_Editor_State

	reader: csv.Reader
    reader.comma = ';'
	csv.reader_init_with_string(&reader, s)
    
    records, err := csv.read_all(&reader)
	if err != nil {
        return {}
    }

    state.columns = make([dynamic]Cell_Editor_Column, c.persistent_allocator)
    for row, row_index in records {
        for cell, column_index in row {
            if row_index == 0 {
                column: Cell_Editor_Column
                column.header_name = strings.clone(cell, c.persistent_allocator)
                column.values = make([dynamic]string, c.persistent_allocator)
                append(&state.columns, column)
            } else {
                s := strings.clone(cell, c.persistent_allocator)
                append(&state.columns[column_index].values, s)
            }
        }
    }

    return state
}

@(plugin_callable)
cell_editor :: proc(state: ^Cell_Editor_State, _bounds: Rect, allocator := context.allocator, loc := #caller_location) -> Component_Return_Rect {
    cnt := new_container_with_bounds(_bounds, {DEFAULT_CELL_EDITOR_WIDTH, DEFAULT_CELL_EDITOR_HEIGHT})

    LINE_NUMBER_WIDTH :: 40
    LINE_HEIGHT :: DEFAULT_CELL_EDITOR_LINE_HEIGHT

    push_id(loc)

    control_rect := get_control_rect(cnt, {0, 0, cnt.bounds.w, cnt.bounds.h}, "*", {.Request_Focus})

    if !control_rect.focus {
        state.mode = .Selecting
    }

    c.clip_rect = cnt.bounds

    push_rect(&cnt.primitives, {
        bounds = {0, 0, cnt.bounds.w, cnt.bounds.h},
        colors = solid_color(COLOR_PRIMARY),
        roundness = 6,
        softness = 1,
    })

    rows_qnt := 0
    for column in state.columns {
        rows_qnt = max(rows_qnt, len(column.values))
    }

    default_cell_width := (cnt.bounds.w - LINE_NUMBER_WIDTH) / cast(f32)len(state.columns)

    {
        x: f32 = LINE_NUMBER_WIDTH
        for column, column_index in state.columns {
            cell_rect := Rect{
                x = x,
                y = 0,
                w = default_cell_width + column.width_offset,
                h = LINE_HEIGHT,
            }

            cell_text_pos := align_string_into_rect(cell_rect, column.header_name, .Small, .Regular, {.Vertical_Center, .Left})

            _, intersection := check_rect_overlap(cnt.bounds, cell_rect)

            c.clip_rect = intersection

            push_text(&cnt.primitives, {
                pos = cell_text_pos,
                text = column.header_name,
                colors = solid_color({1, 1, 1, 1}),
                size = .Small,
                kind = .Regular,
            })

            x += default_cell_width + column.width_offset

            c.clip_rect = cnt.bounds
        }
    }

    y: f32 = LINE_HEIGHT
    for row_index in 0..<rows_qnt {
        row_rect := Rect{0, y, cnt.bounds.w, LINE_HEIGHT}

        push_rect(&cnt.primitives, {
            bounds = row_rect,
            colors = solid_color(set_lightness(COLOR_INPUT_BG, (row_index % 2 == 1) ? 1.0 : 1.5)),
            roundness = 0,
            softness = 1,
        })
    
        line_number_rect := Rect{0, y, LINE_NUMBER_WIDTH, LINE_HEIGHT}
        line_str := fmt.tprintf("%d", row_index + 1000)
        line_number_pos := align_string_into_rect(line_number_rect, line_str, .Small, .Regular, {.Vertical_Center, .Horizontal_Center})
        
        push_rect(&cnt.primitives, {
            bounds = line_number_rect,
            colors = solid_color(COLOR_PRIMARY),
            roundness = 0,
            softness = 1,
        })

        push_text(&cnt.primitives, {
            pos = line_number_pos,
            text = line_str,
            colors = solid_color(COLOR_TEXT_MUTED),
            size = .Small,
            kind = .Regular,
        })

        x: f32 = LINE_NUMBER_WIDTH
        for column, column_index in state.columns {
            cell_value := ""

            if row_index < len(column.values) {
                cell_value = column.values[row_index]
            }

            cell_rect := Rect{
                x = x,
                y = y,
                w = default_cell_width + column.width_offset,
                h = LINE_HEIGHT,
            }

            _, intersection := check_rect_overlap(cnt.bounds, cell_rect)

            c.clip_rect = intersection
            
            cell_control_rect := get_control_rect(cnt, cell_rect, fmt.tprintf("cell-%d-%d", row_index, column_index))
            selected := state.selected.x == column_index && state.selected.y == row_index
            
            if cell_control_rect.click && !selected {
                state.selected.x = column_index
                state.selected.y = row_index
                state.mode = .Selecting
            }

            if cell_control_rect.double_click {
                fmt.println("Editing Cell")
                state.mode = .Editing
                text_edit_ctx_from_string(&state.edit_ctx, cell_value, allocator)
            }

            if selected {
                push_rect(&cnt.primitives, {
                    bounds = cell_rect,
                    colors = solid_color({0, 0, 1, 1}),
                    roundness = 0,
                    softness = 1,
                    thickness = 1,
                })
            }

            if selected && state.mode == .Editing {
                cell_scroll_animation := get_animation(cnt, fmt.tprintf("cell-scroll-%d-%d", row_index, column_index))

                process_text_edit_ctx(&state.edit_ctx)

                column.values[row_index] = strings.to_string(state.edit_ctx.builder)
                
                prepared := prepare_textinput({
                    ctx = &state.edit_ctx,
                    animation = cell_scroll_animation,
                    bounds = cell_rect,
                    font_kind = .Regular,
                    font_size = .Small,
                })

                push_text(&cnt.primitives, {
                    pos = prepared.text_pos,
                    text = prepared.text,
                    colors = solid_color({1, 1, 1, 1}),
                    size = .Small,
                    kind = .Regular,
                })

                push_rect(&cnt.primitives, {
                    bounds = prepared.cursor_rect,
                    colors = solid_color(change_alpha(COLOR_TEXT, 0.5)),
                    roundness = prepared.cursor_roundness,
                    softness = prepared.cursor_softness,
                })
            } else {
                cell_text_pos := align_string_into_rect(cell_rect, cell_value, .Small, .Regular, {.Vertical_Center, .Left})
                push_text(&cnt.primitives, {
                    pos = cell_text_pos,
                    text = cell_value,
                    colors = solid_color({1, 1, 1, 1}),
                    size = .Small,
                    kind = .Regular,
                })
            }

            x += default_cell_width + column.width_offset

            c.clip_rect = cnt.bounds
        }

        y += LINE_HEIGHT

        if y > cnt.bounds.h {
            break
        }
    }

    c.clip_rect = DEFAULT_CLIP_RECT
    
    {
        x: f32 = LINE_NUMBER_WIDTH
        for column, column_index in state.columns[:len(state.columns) - 1] {
            x += default_cell_width + column.width_offset

            v_separator_control_rect := get_control_rect(cnt, {
                x - 3,
                LINE_HEIGHT,
                4,
                cnt.bounds.h - LINE_HEIGHT,
            }, fmt.tprintf("v-separator-%d", column_index))
            v_separator_hover_animation := get_animation(cnt, fmt.tprintf("v-separator-hover-%d", column_index))

            v_separator_hover_animation.target = v_separator_control_rect.hover ? 1 : 0
            
            push_line(&cnt.primitives, {
                p0 = {x, LINE_HEIGHT}, 
                p1 = {x, cnt.bounds.h},
                colors = solid_color(set_lightness(COLOR_SECONDARY, 1 + v_separator_hover_animation.value)),
                thickness = 2,
            })

            if v_separator_control_rect.drag {
                state.columns[column_index].width_offset += v_separator_control_rect.drag_vector.x
            }
        }
    } 

    pop_id()

    return { cnt, control_rect }
}*/