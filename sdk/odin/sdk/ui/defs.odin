package ui

import sa "core:container/small_array"
import "core:text/edit"
import "core:strings"
import stbtt "vendor:stb/truetype"
import "base:runtime"

FRAME_ARENA_SUGGESTED_SIZE :: 1024 * 1024 * 24
COLOR_PRIMARY :: [4]f32{0.19, 0.20, 0.21, 1.0}
COLOR_SECONDARY :: [4]f32{0.39, 0.40, 0.41, 1.0}
COLOR_TEXT :: [4]f32{0.8, 0.8, 0.8, 1.0} 
COLOR_TEXT_MUTED :: [4]f32{0.6, 0.6, 0.6, 1.0}
COLOR_ACCENT :: [4]f32{0.4, 0.4, 0.4, 1.0}
COLOR_INPUT_BG :: [4]f32{0.08, 0.08, 0.08, 1}
COLOR_INPUT_BORDER :: [4]f32{0.05, 0.05, 0.05, 1}
COLOR_SHADOW :: [4]f32{0, 0, 0, 0.1}
DEFAULT_PADDING :: 10
HALF_PADDING :: 5
SHADOW_SIZE :: 2
DOUBLE_CLICK_TIME_LIMIT :: 0.5
CURSOR_WIDTH :: 2
DEFAULT_WIDGET_HEIGHT :: 30
DEFAULT_SLIDER_HEIGHT :: 20
DEFAULT_CLIP_RECT :: Rect{-9999, -9999, 3 * 9999, 3 * 9999}
ID_STACK_SIZE :: 32
LAYOUT_STACK_SIZE :: 16
MAX_DRAGGED_IDS :: 16
MAX_TRANSPARENCY_VALUES :: 16
DEFAULT_CELL_EDITOR_HEIGHT :: 200
DEFAULT_CELL_EDITOR_WIDTH :: 200
DEFAULT_CELL_EDITOR_LINE_HEIGHT :: 20
WHITE :: [4]f32{1, 1, 1, 1}
BLACK :: [4]f32{0, 0, 0, 1}
SOLID_WHITE :: [4][4]f32{WHITE, WHITE, WHITE, WHITE}
SOLID_BLACK :: [4][4]f32{BLACK, BLACK, BLACK, BLACK}

ID :: u64

Window_Option :: enum {
    No_Internal_Borders,
}

Window_Option_Set :: bit_set[Window_Option; u32]

Window_Props :: struct {
    options: Window_Option_Set,
}

Cell_Editor_Column :: struct {
    header_name: string,
    values: [dynamic]string,
    width_offset: f32,
}

Cell_Editor_State :: struct {
    columns: [dynamic]Cell_Editor_Column,
    edit_ctx: Text_Editing_Context,
    selected: [2]int,
    mode: enum {
        Selecting,
        Editing,
    }
}

Text_Editing_Context :: struct {
    builder: strings.Builder,
    state: edit.State,
}

Alignment_Set :: enum {
    Left,
    Horizontal_Center,
    Right,
    Top,
    Vertical_Center,
    Bottom,
}

Alignment :: bit_set[Alignment_Set; uint]

Animation_Kind :: enum {
    X,
    Position,
    Color,
}

Animation :: struct {
    c: ^Context, // useful for merging different contexts
    id: ID,
    target: [4]f32,
    value: [4]f32,
    duration: f32,
    name: string,
    kind: Animation_Kind,
}

Animation_State :: struct {
    target: [4]f32,
    value: [4]f32,
    duration: f32,
}

Control_Rect_Flags_Set :: enum {
    Request_Focus,
    Dont_Passthrough,
}

Control_Rect_Flags :: bit_set[Control_Rect_Flags_Set; uint]

Control_Rect :: struct {
    c: ^Context, // useful for merging different contexts
    id: ID,
    name: string,
    bounds: Rect,
    flags: Control_Rect_Flags,
    zindex: int,
}

Control_Rect_State :: struct {
    click, hover, release, hold, drag, focus, open, double_click: b8,
    drag_vector: [2]f32,

    // A marker that is moved when a click or hold event is triggered inside the box
    // useful for creating sliders and color pickers. The values range from 0 to 1:
    //
    // (0, 0)                        (1, 0)
    //   -------------------------------
    //   |                             |
    //   |                             |
    //   -------------------------------
    // (0, 1)                        (1, 1)
    //
    movable_marker_pos: [2]f32,
    uptime: f32,
    last_click_uptime: f32,
    last_bounds: Rect,
    id: ID,
}

IO :: struct {
    mouse_pos: [2]f32,
    mouse_change: [2]f32,
    left_click: bool,
    left_pressed: bool,
    input_text: string,
    text_edit_commands: []edit.Command,
    delta_time: f32,
    viewport: Rect,
}

Rect :: struct {
    x, y, w, h: f32,
}

Padding :: struct {
    top, right, bottom, left: f32,
}

Container :: struct {
    using bounds: Rect,
    control_rects: [dynamic]Control_Rect,
    animations: [dynamic]Animation,
    primitives: [dynamic]Primitive,
    children: [dynamic]^Container,
    children_clip_rect: Rect,
    props_ptr: rawptr,
}

Component_Return_Rect :: struct {
    container: ^Container,
    using value: Control_Rect_State,
}

Component_Return_Rect_With_Extra :: struct($T: typeid) {
    container: ^Container,
    using value: Control_Rect_State,
    using extra: T,
}

Font_Kind :: enum {
	Regular,
	Italic,
	Bold,
	Monospace,
	Icon,
}

Font_Size :: enum {
	Small,
	Medium,
	Large,
	Very_Large,
}

Primitive_Rect :: struct {
	bounds: Rect,
	roundness: f32,
	softness: f32,
	thickness: f32,
	colors: [4][4]f32,
}

Primitive_Texture :: struct {
    bounds: Rect,
    handle: rawptr,
    uv0: [2]f32,
    uv1: [2]f32,
    colors: [4][4]f32,
}

Primitive_Text :: struct {
	pos: [2]f32,
	text: string,
	size: Font_Size,
	kind: Font_Kind,
	colors: [4][4]f32,
}

Primitive_Line :: struct {
    p0: [2]f32,
    p1: [2]f32,
    thickness: f32,
	colors: [4][4]f32,
}

Primitive :: struct {
	zindex: int,
	clip_rect: Rect,
	u: union {
		Primitive_Rect,
		Primitive_Text,
        Primitive_Line,
        Primitive_Texture,
	},
}

Layout :: struct {
    name: string,
    buffered_containers: [dynamic]^Container,
    cnt: ^Container,
    end_callback: proc(cnt: ^Container, input: []^Container) -> ^Container,
    get_avaliable_space_callback: proc(cnt: ^Container, input: []^Container) -> [2]f32,
}

Context :: struct {
    id_stack: sa.Small_Array(ID_STACK_SIZE, ID),
    layout_stack: sa.Small_Array(LAYOUT_STACK_SIZE, Layout),
    control_rect_state_table: map[ID]Control_Rect_State,
    animation_state_table: map[ID]Animation_State,
    persistent_allocator: runtime.Allocator,
    frame_allocator: runtime.Allocator,
    io: IO,
    primitive_buffer: [dynamic]Primitive,
    containers: [dynamic]Container,
    dragged_ids: sa.Small_Array(MAX_DRAGGED_IDS, ID),
    transparency_values: sa.Small_Array(MAX_TRANSPARENCY_VALUES, f32),
    focused_id: ID,
    clip_rect: Rect,
    zindex: int,
    cnt: ^Container,
    frame_counter: int,
}

Font_Source :: struct {
	data: []byte,
	range_start: i32,
	range_size: i32,
}

Font :: struct {
	real_height: f32,
	y_offset: f32,
	metrics: [ICON_FONT_RANGE_SIZE]stbtt.packedchar, //largest font map
	range_start: i32,
	range_size: i32,
}

Font_Size_Array :: [Font_Size]Font

Font_Palette :: [Font_Kind]Font_Size_Array
