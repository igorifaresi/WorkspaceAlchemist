package main

import "core:fmt"
import "core:strings"
import "base:runtime"
import "vendor:glfw"
import "core:unicode/utf8"
import "core:text/edit"
import "core:mem"
import "core:math"
import "core:sync"
import "core:time"
import win32 "core:sys/windows"

import "sdk:ipc"
import "sdk:ui"
import "sdk:http"
import py "sdk:python"

running := true
mousepos: [2]f32
mouse_pressed_table: [8]bool
text_input_buffer: strings.Builder
shift_pressed: bool
ctrl_pressed: bool
text_edit_commands: [32]edit.Command
text_edit_commands_qnt: int
delta_time: f32 = 0.016
window_height: f32 = 600
window_width: f32 = 600
begin_frame_semaphore: sync.Sema

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {
	context = runtime.default_context()
	mousepos.x = cast(f32)xpos
	mousepos.y = cast(f32)ypos
}

mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()
	mouse_pressed_table[button] = action != 0
}

char_callback :: proc "c" (window: glfw.WindowHandle, codepoint: rune) {
	context = runtime.default_context()
	strings.write_rune(&text_input_buffer, codepoint)
}

window_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	context = runtime.default_context()
	window_width = cast(f32)width
	window_height = cast(f32)height
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	context = runtime.default_context()

	push_cmd :: proc(cmd: edit.Command) {
		fmt.println(cmd)
		text_edit_commands[text_edit_commands_qnt] = cmd
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

c: ui.Context
c2: ui.Context

main :: proc() {
	//fmt.println("server", ipc.create_shared_memory("YourMama1"))
	//fmt.println("server", ipc.create_shared_memory("YourMama2"))
	//fmt.println("server", ipc.create_shared_memory("YourMama3"))
	//fmt.println("server", ipc.create_named_pipe("pipe-foo"))
	//fmt.println("server", ipc.create_named_pipe("pipe-bar"))

	/*process := ipc.create_process("clang")

	fmt.println(process)

	time.sleep(10 * time.Second)
	ipc.close_process(&process)*/
    
	//load_python_sdk()
	//py.init()
	/*module := py.import_code("test", `
import vtable
def foo():
	print('hellope')	
`)
	p := py.get_procedure(module, "foo")
	py.call_procedure(p)*/

	instantiate_module("test")
	//instantiate_module("test")
	//instantiate_module("test")

	//panic("Deu certo")

	//generate_sdks()

	glfw.WindowHint(glfw.RESIZABLE, 1)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3) 
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	
	if !glfw.Init() {
		fmt.println("Failed to initialize GLFW")
		return
	}
	defer glfw.Terminate()

	window := glfw.CreateWindow(600, 600, "Yay", nil, nil)
	defer glfw.DestroyWindow(window)

	// If the window pointer is invalid
	if window == nil {
		fmt.println("Unable to create window")
		return
	}
	
	glfw.MakeContextCurrent(window)

	glfw.SwapInterval(1)

	glfw.SetMouseButtonCallback(window, mouse_button_callback)
	glfw.SetCursorPosCallback(window, cursor_pos_callback)
	glfw.SetCharCallback(window, char_callback)
	glfw.SetKeyCallback(window, key_callback)
	glfw.SetWindowSizeCallback(window, window_size_callback)

	ui.setup_render_opengl3_3(glfw.gl_set_proc_address)
	ui.init_context(&c, context.allocator)
	ui.init_context(&c2, context.allocator)
	ui.set_context(&c)

	/*builder: strings.Builder
	strings.write_string(&builder, "Yay")
	edit_state: edit.State
	edit.init(&edit_state, context.allocator, context.allocator)
	edit.setup_once(&edit_state, &builder)*/

	ctx: ui.Text_Editing_Context
	ui.text_edit_ctx_from_string(&ctx, "Yay")

	data, err := mem.alloc_bytes(1024 * 1024 * 1024)
	arena: mem.Arena
	mem.arena_init(&arena, data)
	context.allocator = mem.arena_allocator(&arena)

	csv := `Username; Identifier;First name;Last name
booker12;9012;Rachel;Booker
grey07;2070;Laura;Grey
johnson81;4081;Craig;Johnson
jenkins46;9346;Mary;Jenkins
smith79;5079;Jamie;Smith
`


	table_ctx := ui.cell_editor_state_from_csv(csv)
	fmt.println(table_ctx)
	
	last_left_pressed := false
	last_mouse_pos := mousepos
	f: f32
	b: bool
	last_time: f32 = cast(f32)glfw.GetTime()
	w: [3]ui.Rect
	last_primtive_count := 0

	for &item, index in w {
		item = {100 * cast(f32)index, 200 * cast(f32)index, 400, 400}
	}

	for !glfw.WindowShouldClose(window) && running {
		//time.sleep(1 * time.Second)

		//for RGFW.window_checkEvent(win) != nil {}
		glfw.PollEvents()

		connections := [1][4][2]f32{}
		for &conn, index in connections {
			half_size := (w[index + 1].x - w[index].x) / 2
			conn[0] = {w[index].x + w[index].w, w[index].y + w[index].h / 2}
			conn[1] = {w[index].x + w[index].w / 2 + half_size, w[index].y + w[index].h / 2}
			conn[2] = {w[index].x + w[index].w / 2 + half_size, w[index + 1].y + w[index + 1].h / 2}
			conn[3] = {w[index + 1].x        , w[index + 1].y + w[index + 1].h / 2}
		}

		new_time: f32 = cast(f32)glfw.GetTime()
		delta_time = new_time - last_time
		last_time = new_time

		//fmt.println(c.viewport)
		//fmt.println(c.clip_rect)

		last_left_pressed = c.io.left_pressed
		last_mouse_pos = c.io.mouse_pos

		c.io.mouse_pos.x = mousepos.x
		c.io.mouse_pos.y = mousepos.y
		c.io.mouse_change.x = mousepos.x - last_mouse_pos.x
		c.io.mouse_change.y = mousepos.y - last_mouse_pos.y
		c.io.left_pressed = mouse_pressed_table[0]
		c.io.left_click = !last_left_pressed && mouse_pressed_table[0]
		c.io.input_text = strings.to_string(text_input_buffer)
		c.io.text_edit_commands = text_edit_commands[:text_edit_commands_qnt]
		c.io.delta_time = delta_time
		c.io.viewport = {0, 0, window_width, window_height}

		for id in instances {
			instances[id].blocked = false
		}

		text_edit_commands_qnt = 0
		text_input_buffer = strings.Builder{}

		ui.begin_frame_opengl3_3(window_width, window_height)

		ui.begin_ui()

		for &item, index in w {
			ui.push_id(index)

			ui.inc_zindex()

			ui.begin_window(&item, { options = {} })
			{




				ui.begin_column()
				{
					if index != 0 {
						if ui.button("Açaí").drag {
							fmt.println("Dragged 1")
						}

						if c:= ui.button("Click Here"); c.click {
							fmt.println("Clicked 2: ", c.uptime)
						}

						ui.slider(&f, 0, 100)

						ui.checkbox(&b, "Check here!")

						ui.textinput(&ctx)

						ui.icon_button(ui.ICON_House)

						if ui.begin_select().open {
							for i in 0..<5 {
								ui.push_id(i)

								if ui.select_button(fmt.tprintf("Option %d", i)).click {
									fmt.println("-> Clicked select item")
								}

								ui.pop_id()
							}

							ui.end()
						}

						if ui.icon_button(ui.ICON_House).click {
							fmt.println("HOME")
						}
					} else {
						ui.cell_editor(&table_ctx, { w = -1, h = -1 }, c.persistent_allocator)
					}

					ui.end()
				}
				
				ui.end()
			}

			ui.pop_id()
		}

		/*ui.sync_contexts(&c2, )
		ui.begin_ui(&c2)
		{
			ui.begin_column(&c2)
			{
				ui.button(&c2, fmt.tprintf("Delta time: %f", delta_time), {0, 0, 400, 30})
				ui.button(&c2, fmt.tprintf("Primitive Count: %d", last_primtive_count), {0, 0, 400, 30})

				ui.end(&c2)
			}
		}

		ui.merge_contexts(&c2)*/

		for conn in connections {
			ui.cubic_bezier(conn[0], conn[1], conn[2], conn[3], {0.07, 0.07, 0.6, 1.0})
		}
		
		ui.end_ui()

		last_primtive_count = len(c.primitive_buffer)

		ui.draw_ui_primitives_opengl3_3(c.primitive_buffer[:], window_width, window_height)

		//edit.end(&edit_state)

		glfw.SwapBuffers(window)

		//fmt.println("offset", arena.offset)
		//fmt.println("peak_used", arena.peak_used)
		//fmt.println("temp_count", arena.temp_count)

		mem.arena_free_all(&arena)
		//RGFW.window_swapBuffers(win)
	}


	//RGFW.window_close(win);
}