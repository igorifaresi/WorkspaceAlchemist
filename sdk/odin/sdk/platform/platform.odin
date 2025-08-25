package platform

import "core:strings"
import "core:text/edit"
import DXGI "vendor:directx/dxgi"

Input :: struct {
	mouse_pos: [2]f32,
	mouse_change: [2]f32,
	mouse_left_pressed: bool,
	mouse_left_click: bool,
	text_input_buffer: strings.Builder,
	shift_pressed: bool,
	ctrl_pressed: bool,
	text_edit_commands: []edit.Command,
	delta_time: f32,
	window_height: f32,
	window_width: f32,
}

Window_Creation_Option :: enum {
	Hidden,
}

Window_Creation_Flags :: bit_set[Window_Creation_Option]

Platform :: struct {
	create_window: proc(width: int, height: int, name: string, flags: Window_Creation_Flags = {}),
	create_hidden_window: proc(width: int, height: int, name: string) -> (surface_handle: rawptr), 
	should_close: proc() -> bool,
	begin_frame: proc(),
	end_frame: proc(),
	get_frame_input: proc() -> Input,
	gl_set_proc_address: proc(p: rawptr, name: cstring),
	get_dxgi_window: proc() -> DXGI.HWND,
}