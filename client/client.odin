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
import "core:container/small_array"
import win32 "core:sys/windows"

import "sdk:sdk/platform"
import "sdk:sdk/ipc"
import "sdk:sdk/ui"
import "sdk:sdk/http"

running := true

c: ui.Context

plat: platform.Platform

draw_icon :: proc(
	manifest: Application_Manifest,
	rect: ui.Rect = {},
	loc := #caller_location,
) {
	ui.texture(icon_atlas, rect, uv0=manifest.icon_uv0, uv1=manifest.icon_uv1, loc=loc)
}

app_bar_button :: proc(
	manifest: Application_Manifest,
	_bounds: ui.Rect = {},
	loc := #caller_location,
) -> ui.Component_Return_Rect {
	cnt := ui.new_container_with_bounds(_bounds, {64, 64})

	ui.push_id(loc)

	control_rect := ui.get_control_rect(cnt, {0, 0, cnt.bounds.w, cnt.bounds.h}, "*")

	hover_animation := ui.get_animation(cnt, "hover")

	hover_animation.target.x = control_rect.hover ? 1 : 0

	icon_bounds := ui.Rect{
		x = 0,
		y = hover_animation.value.x * cnt.bounds.h / 4,
		w = cnt.bounds.w,
		h = cnt.bounds.h,
	}

	ui.push_texture(cnt, {
		bounds = ui.scale_rect(ui.offset_rect(icon_bounds, {1, 2}), 2),
		colors = ui.solid_color(ui.COLOR_SHADOW),
		handle = icon_atlas,
		uv0 = manifest.icon_uv0,
		uv1 = manifest.icon_uv1,
	})

	ui.push_texture(cnt, {
		bounds = icon_bounds,
		colors = ui.vertical_gradient(
			ui.WHITE,
			math.lerp(ui.WHITE, [4]f32{1.5, 1.5, 1.5, 1}, hover_animation.value.x),
		),
		handle = icon_atlas,
		uv0 = manifest.icon_uv0,
		uv1 = manifest.icon_uv1,
	})	

	ui.pop_id()

	return { cnt, control_rect }
}

app_bar_more_apps_button :: proc(
	_bounds: ui.Rect = {},
	loc := #caller_location,
) -> ui.Component_Return_Rect {
	cnt := ui.new_container_with_bounds(_bounds, {64, 64})

	ui.push_id(loc)

	hover_animation := ui.get_animation(cnt, "hover")


	button_rect := ui.trim_rect({0, 0, cnt.bounds.w, cnt.bounds.h}, 10)
	control_rect := ui.get_control_rect(cnt, button_rect, "*")

	hover_animation.target.x = control_rect.hover ? 1 : 0

	for y in 0..<3 {
		for x in 0..<3 {
			GAP :: 4
			SPACING :: 1

			spacing := SPACING + hover_animation.value.x * GAP

			cell_rect := ui.Rect{
				x = (button_rect.w / 3) * f32(x) + max(0, f32(x) * spacing) + button_rect.x,
				y = (button_rect.h / 3) * f32(y) + max(0, f32(y) * spacing) + button_rect.y,
				w = button_rect.w / 3 - SPACING * 3,
				h = button_rect.h / 3 - SPACING * 3,
			}

			cell_rect.x -= hover_animation.value.x * (GAP / 2 + SPACING * 2)
			cell_rect.y -= hover_animation.value.x * (GAP / 2 + SPACING * 2)

			c := math.lerp(ui.WHITE, ui.WHITE, hover_animation.value.x)

			ui.push_rect(cnt, {
		        bounds = cell_rect,
				colors = ui.solid_color(c),
				roundness = 1,
		        softness = 1,
		    })
		}
	}

	ui.pop_id()

	return { cnt, control_rect }
}

main :: proc() {
	main_allocator_mutex: mem.Mutex_Allocator
	temp_allocator_mutex: mem.Mutex_Allocator

	mem.mutex_allocator_init(&main_allocator_mutex, context.allocator)
	mem.mutex_allocator_init(&temp_allocator_mutex, context.temp_allocator)

	context.allocator = mem.mutex_allocator(&main_allocator_mutex)
	context.temp_allocator = mem.mutex_allocator(&temp_allocator_mutex)

	plat = platform.get_glfw_d3d11_platform()
	plat.create_window(1200, 600, "Yay")

	ui.load_font_palette()
		
	ui.setup_render_d3d11(plat.get_dxgi_window())	
	ui.init_context(&c, context.allocator)
	ui.set_context(&c)

	read_all_manifests()

	//instantiate_module("test")
	//instantiate_module("test")
	//instantiate_module("test")

	data, err := mem.alloc_bytes(ui.FRAME_ARENA_SUGGESTED_SIZE)
	frame_arena: mem.Arena
	mem.arena_init(&frame_arena, data)
	frame_allocator := mem.arena_allocator(&frame_arena)

	last_time: f32 = cast(f32)glfw.GetTime()

	for !plat.should_close() && running {
		plat.begin_frame()

		input := plat.get_frame_input()

		c.io.mouse_pos.x = input.mouse_pos.x
		c.io.mouse_pos.y = input.mouse_pos.y
		c.io.mouse_change.x = input.mouse_change.x
		c.io.mouse_change.y = input.mouse_change.y
		c.io.left_pressed = input.mouse_left_pressed
		c.io.left_click = input.mouse_left_click
		c.io.input_text = strings.to_string(input.text_input_buffer)
		c.io.text_edit_commands = input.text_edit_commands
		c.io.delta_time = input.delta_time
		c.io.viewport = {0, 0, input.window_width, input.window_height}

		for &it in small_array.slice(&instances) {
			it.blocked = false
		}

		for &it in small_array.slice(&instances) {
			if !it.ready && it.surface_handle != nil {
				it.surface_texture = ui.load_shared_texture(it.surface_handle)
        		it.ready = true
			}
		}

		ui.begin_frame(frame_allocator)

		@(static) connection_mode := false
		@(static) v1_id: ui.ID
		@(static) v2_id: ui.ID
		@(static) v1_pos: [2]f32
		@(static) v2_pos: [2]f32
		@(static) color := [4]f32{0.4, 0.4, 0.4, 1.0}
		@(static) b1: bool
		@(static) b2: bool

		ui.begin_column({ 10, 200, 300, -1 })
		{
			if ui.button("Spawn test window").release {
				instantiate_application("test")
				fmt.println("YAY")
			}
			
			if ui.button("Spawn 3d-demo").release {
				instantiate_application("3d-demo")
				fmt.println("YAY")
			}

			if !connection_mode {
				if ui.button("Connection mode").release {
					connection_mode = true
				}
			} else {
				if ui.button("View mode").release {
					connection_mode = false
				}
			}
		}
		ui.end()

		for &it in small_array.slice(&instances) {
			ui.inc_zindex()
			ui.inc_zindex()
			ui.inc_zindex()
			ui.inc_zindex()

			ui.push_id(it.id)
			{
				it.rect = ui.begin_window(it.rect, { options = connection_mode ? {} : {.No_Internal_Borders} })	
				{
					ui.begin_column()
					
					if it.ready && !connection_mode {
						ui.texture(it.surface_texture, { w = it.rect.w, h = it.rect.h })
					}

					if connection_mode {
						output := ui.node_editor_button(&b1, "Output", {0.27, 0.27, 0.8, 1.0})
						if output.click {
							v1_id = output.id
						}

						if v1_id == output.id {
							v1_pos = ui.get_rect_center_point(output.last_bounds)
						}

						input := ui.node_editor_button(&b2, "Input", color)

						if input.click {
							v2_id = input.id
							color = {0.27, 0.27, 0.8, 1.0}
						}

						if v2_id == input.id {
							v2_pos = ui.get_rect_center_point(input.last_bounds)
						}
					}

					ui.end()
				}
				ui.end()
			}
			ui.pop_id()
		}

		if connection_mode {
			ui.inc_zindex()
			ui.inc_zindex()
			ui.inc_zindex()
			ui.inc_zindex()
			ui.inc_zindex()
			ui.cubic_bezier(v1_pos, v1_pos + {200, 0}, v2_pos - {200, 0}, v2_pos, {0.27, 0.27, 0.8, 1.0})
		}

		//ui.texture(icon_atlas, { w = 512, h = 512 })

		ui.begin_row()
		{
			for manifest, i in small_array.slice(&manifests) {
				ui.push_id(i)
				app_bar_button(manifest)
				ui.pop_id()
			}
			app_bar_more_apps_button()
		}
		ui.end()

		ui.end_frame()

		ui.draw_ui_primitives_d3d11(c.primitive_buffer[:], input.window_width, input.window_height, false)

		plat.end_frame()
		mem.arena_free_all(&frame_arena)
	}

}