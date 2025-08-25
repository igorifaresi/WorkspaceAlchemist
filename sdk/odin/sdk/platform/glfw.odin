package platform

import "base:runtime"
import "core:strings"
import "core:text/edit"
import "core:fmt"
import "vendor:glfw"
import DXGI "vendor:directx/dxgi"

@(private="file") window: glfw.WindowHandle
mouse_pressed_table: [8]bool
last_mouse_left_pressed: bool
text_edit_commands_buffer: [32]edit.Command
text_edit_commands_qnt := 0
last_mouse_pos: [2]f32
last_time: f32
@(private="file") input: Input

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {
	using input

	context = runtime.default_context()
	mouse_pos.x = cast(f32)xpos
	mouse_pos.y = cast(f32)ypos
}

mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	using input

	context = runtime.default_context()
	mouse_pressed_table[button] = action != 0
}

char_callback :: proc "c" (window: glfw.WindowHandle, codepoint: rune) {
	using input

	context = runtime.default_context()
	strings.write_rune(&text_input_buffer, codepoint)
}

window_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	using input

	context = runtime.default_context()
	window_width = cast(f32)width
	window_height = cast(f32)height
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	using input

	context = runtime.default_context()

	push_cmd :: proc(cmd: edit.Command) {
		text_edit_commands_buffer[text_edit_commands_qnt] = cmd
		text_edit_commands_qnt += 1
	}

	if key == glfw.KEY_LEFT_SHIFT || key == glfw.KEY_RIGHT_SHIFT {
		shift_pressed = action != 0

	} else if key == glfw.KEY_LEFT_CONTROL || key == glfw.KEY_RIGHT_CONTROL {
		ctrl_pressed = action != 0	
	
	} else if shift_pressed && !ctrl_pressed && (action == glfw.PRESS || action == glfw.REPEAT) {
		switch key {
		case glfw.KEY_LEFT:  push_cmd(.Select_Left)
		case glfw.KEY_RIGHT: push_cmd(.Select_Right)
		case glfw.KEY_UP:    push_cmd(.Select_Up)
		case glfw.KEY_DOWN:  push_cmd(.Select_Down)
		}

	} else if ctrl_pressed && !shift_pressed && action == glfw.PRESS {
		switch key {
		case glfw.KEY_Z:         push_cmd(.Undo)
		case glfw.KEY_Y:         push_cmd(.Redo)
		case glfw.KEY_X:         push_cmd(.Cut)
		case glfw.KEY_C:         push_cmd(.Copy)
		case glfw.KEY_V:         push_cmd(.Paste)
		case glfw.KEY_A:         push_cmd(.Select_All)
		case glfw.KEY_BACKSPACE: push_cmd(.Delete_Word_Left)
		case glfw.KEY_DELETE:    push_cmd(.Delete_Word_Right)
		case glfw.KEY_LEFT:      push_cmd(.Word_Left)
		case glfw.KEY_RIGHT:     push_cmd(.Word_Right)	
		}

	} else if shift_pressed && ctrl_pressed && (action == glfw.PRESS || action == glfw.REPEAT) {
		switch key {
		case glfw.KEY_LEFT:  push_cmd(.Select_Word_Left)
		case glfw.KEY_RIGHT: push_cmd(.Select_Word_Right)
		}

	} else if !shift_pressed && !ctrl_pressed && (action == glfw.PRESS || action == glfw.REPEAT) {
		switch key {
		case glfw.KEY_LEFT:      push_cmd(.Left)
		case glfw.KEY_RIGHT:     push_cmd(.Right)
		case glfw.KEY_UP:        push_cmd(.Up)
		case glfw.KEY_DOWN:      push_cmd(.Down)
		case glfw.KEY_BACKSPACE: push_cmd(.Backspace)
		case glfw.KEY_DELETE:    push_cmd(.Delete)
		}
	}
}

create_window_glfw :: proc(
	width: int,
	height: int,
	name: string,
	flags: Window_Creation_Flags,
) {	
	glfw.WindowHint(glfw.RESIZABLE, 1)

	if .Hidden in flags {
		glfw.WindowHint(glfw.VISIBLE, false)
		fmt.println("Hidden")
	}
	
	if !glfw.Init() {
		panic("Failed to initialize GLFW")
	}

	window = glfw.CreateWindow(
		cast(i32)width,
		cast(i32)height,
		strings.clone_to_cstring(name),
		nil,
		nil,
	)

	if window == nil {
		panic("Unable to create window")
	}
	
	glfw.MakeContextCurrent(window)

	glfw.SwapInterval(1)

	glfw.SetMouseButtonCallback(window, mouse_button_callback)
	glfw.SetCursorPosCallback(window, cursor_pos_callback)
	glfw.SetCharCallback(window, char_callback)
	glfw.SetKeyCallback(window, key_callback)
	glfw.SetWindowSizeCallback(window, window_size_callback)

	input.window_width = cast(f32)width
	input.window_height = cast(f32)height
}

create_window_glfw_opengl_3_3 :: proc(
	width: int,
	height: int,
	name: string,
	flags: Window_Creation_Flags,
) {	
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3) 
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	
	create_window_glfw(width, height, name, flags)
}

create_window_glfw_d3d11 :: proc(
	width: int,
	height: int,
	name: string,
	flags: Window_Creation_Flags,
) {	
	glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
	
	create_window_glfw(width, height, name, flags)
}

should_close_glfw :: proc() -> bool {
	return cast(bool)glfw.WindowShouldClose(window)
}

get_frame_input_glfw :: proc() -> Input {
	input.mouse_left_pressed = mouse_pressed_table[0]
	input.text_edit_commands = text_edit_commands_buffer[:text_edit_commands_qnt]
	input.mouse_left_click = !last_mouse_left_pressed && mouse_pressed_table[0] 
	input.mouse_change = input.mouse_pos - last_mouse_pos

	ret := input
		
	text_edit_commands_qnt = 0
	input.text_input_buffer = strings.Builder{}

	return ret
}

begin_frame_glfw :: proc() {
	glfw.PollEvents()

	new_time: f32 = cast(f32)glfw.GetTime()
	input.delta_time = new_time - last_time
	last_time = new_time
}

end_frame_opengl_3_3_glfw :: proc() {
	last_mouse_left_pressed = input.mouse_left_pressed
	last_mouse_pos = input.mouse_pos

	glfw.SwapBuffers(window)
}

end_frame_d3d11_glfw :: proc() {
	last_mouse_left_pressed = input.mouse_left_pressed
	last_mouse_pos = input.mouse_pos
}

get_dxgi_window_glfw :: proc() -> DXGI.HWND {
	return DXGI.HWND(glfw.GetWin32Window(window))
}

get_glfw_opengl_3_3_platform :: proc() -> Platform {
	platform := Platform {
		create_window = create_window_glfw_opengl_3_3,
		begin_frame = begin_frame_glfw,
		end_frame = end_frame_opengl_3_3_glfw,
		get_frame_input = get_frame_input_glfw,
		should_close = should_close_glfw,
		gl_set_proc_address = glfw.gl_set_proc_address,
		get_dxgi_window = get_dxgi_window_glfw,
	}

	return platform
}

get_glfw_d3d11_platform :: proc() -> Platform {
	platform := Platform {
		create_window = create_window_glfw_d3d11,
		begin_frame = begin_frame_glfw,
		end_frame = end_frame_d3d11_glfw,
		get_frame_input = get_frame_input_glfw,
		should_close = should_close_glfw,
		gl_set_proc_address = glfw.gl_set_proc_address,
		get_dxgi_window = get_dxgi_window_glfw,
	}

	return platform
}