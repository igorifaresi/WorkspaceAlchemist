package ui

import "core:fmt"
import "base:runtime"

label :: proc(text: string, bounds: Rect = {}) {
    label_ex({
        text = text,
        _bounds = bounds,
        color = COLOR_TEXT,
        text_kind = .Regular,
    })
}


label_ex :: proc(
    using props: struct {
        text: string,
        _bounds: Rect,
        color: [4]f32,
        text_kind: Font_Kind,
        loc: runtime.Source_Code_Location,
    },
) {
    cnt := new_container_with_bounds(_bounds)

    push_text(cnt, {
        pos = {0, 0},
        text = text,
        colors = solid_color(color),
        size = .Medium,
        kind = text_kind,
    })
}