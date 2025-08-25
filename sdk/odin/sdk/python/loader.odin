// THIS FILE IS AUTO GENERATED, DO NOT EDIT

package python

import "core:fmt"
import "core:c"
import "base:runtime"

import "sdk:ui"
import py "sdk:python"

IMPLEMENT_SDK :: #config(IMPLEMENT_SDK, false)

when IMPLEMENT_SDK {

py_module: py.ModuleDefinition_Ptr
load_python_sdk :: proc() {
	py_module = py.create_module_definition("vtable")

	main_print_instance_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()

		py.Arg_ParseTuple(args, "")

		print_instance()

		return nil
	}

	main_dispatch_output_event_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		output_port_tmp: cstring

		py.Arg_ParseTuple(args, "s", &output_port_tmp)

		dispatch_output_event(cast(string)output_port_tmp)

		return nil
	}

	py.append_method(py_module, main_print_instance_python, "print_instance")
	py.append_method(py_module, main_dispatch_output_event_python, "dispatch_output_event")
	ui_cubic_bezier_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		p0_tmp_0: f32
		p0_tmp_1: f32
		p1_tmp_0: f32
		p1_tmp_1: f32
		p2_tmp_0: f32
		p2_tmp_1: f32
		p3_tmp_0: f32
		p3_tmp_1: f32
		color_tmp_0: f32
		color_tmp_1: f32
		color_tmp_2: f32
		color_tmp_3: f32
		loc := py.get_caller_source_code_location()

		py.Arg_ParseTuple(args, "(ff)(ff)(ff)(ff)(ffff)", &p0_tmp_0, &p0_tmp_1, &p1_tmp_0, &p1_tmp_1, &p2_tmp_0, &p2_tmp_1, &p3_tmp_0, &p3_tmp_1, &color_tmp_0, &color_tmp_1, &color_tmp_2, &color_tmp_3)

		ui.cubic_bezier({p0_tmp_0, p0_tmp_1}, {p1_tmp_0, p1_tmp_1}, {p2_tmp_0, p2_tmp_1}, {p3_tmp_0, p3_tmp_1}, {color_tmp_0, color_tmp_1, color_tmp_2, color_tmp_3}, loc)

		return nil
	}

	ui_button_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		text_tmp: cstring
		bounds_x_tmp: f32
		bounds_y_tmp: f32
		bounds_w_tmp: f32
		bounds_h_tmp: f32
		loc := py.get_caller_source_code_location()

		py.Arg_ParseTuple(args, "s(ffff)", &text_tmp, &bounds_x_tmp, &bounds_y_tmp, &bounds_w_tmp, &bounds_h_tmp)

		ui.button(cast(string)text_tmp, {bounds_x_tmp, bounds_y_tmp, bounds_w_tmp, bounds_h_tmp}, loc)

		return nil
	}

	ui_icon_button_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		icon_tmp: cstring
		loc := py.get_caller_source_code_location()

		py.Arg_ParseTuple(args, "s", &icon_tmp)

		ui.icon_button(cast(string)icon_tmp, loc)

		return nil
	}

	ui_cell_editor_state_from_csv_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		s_tmp: cstring

		py.Arg_ParseTuple(args, "s", &s_tmp)

		ui.cell_editor_state_from_csv(cast(string)s_tmp)

		return nil
	}

	ui_cell_editor_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		state_tmp: py.Object_Ptr
		_bounds_x_tmp: f32
		_bounds_y_tmp: f32
		_bounds_w_tmp: f32
		_bounds_h_tmp: f32
		loc := py.get_caller_source_code_location()

		py.Arg_ParseTuple(args, "O(ffff)", &state_tmp, &_bounds_x_tmp, &_bounds_y_tmp, &_bounds_w_tmp, &_bounds_h_tmp)

		ui.cell_editor(cast(^ui.Cell_Editor_State)py.Capsule_GetPointer(state_tmp, nil), {_bounds_x_tmp, _bounds_y_tmp, _bounds_w_tmp, _bounds_h_tmp}, context.allocator, loc)

		return nil
	}

	ui_checkbox_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		enabled_tmp: py.Object_Ptr
		text_tmp: cstring
		_bounds_x_tmp: f32
		_bounds_y_tmp: f32
		_bounds_w_tmp: f32
		_bounds_h_tmp: f32
		loc := py.get_caller_source_code_location()

		py.Arg_ParseTuple(args, "Os(ffff)", &enabled_tmp, &text_tmp, &_bounds_x_tmp, &_bounds_y_tmp, &_bounds_w_tmp, &_bounds_h_tmp)

		ui.checkbox(cast(^bool)py.Capsule_GetPointer(enabled_tmp, nil), cast(string)text_tmp, {_bounds_x_tmp, _bounds_y_tmp, _bounds_w_tmp, _bounds_h_tmp}, loc)

		return nil
	}

	ui_get_avaliable_space_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()

		py.Arg_ParseTuple(args, "")

		ui.get_avaliable_space()

		return nil
	}

	ui_new_container_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()

		py.Arg_ParseTuple(args, "")

		ui.new_container()

		return nil
	}

	ui_pop_id_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()

		py.Arg_ParseTuple(args, "")

		ui.pop_id()

		return nil
	}

	ui_inc_zindex_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()

		py.Arg_ParseTuple(args, "")

		ui.inc_zindex()

		return nil
	}

	ui_dec_zindex_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()

		py.Arg_ParseTuple(args, "")

		ui.dec_zindex()

		return nil
	}

	ui_get_control_rect_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		cnt_tmp: py.Object_Ptr
		bounds_x_tmp: f32
		bounds_y_tmp: f32
		bounds_w_tmp: f32
		bounds_h_tmp: f32
		name_tmp: cstring
		flags_tmp: c.long

		py.Arg_ParseTuple(args, "O(ffff)sl", &cnt_tmp, &bounds_x_tmp, &bounds_y_tmp, &bounds_w_tmp, &bounds_h_tmp, &name_tmp, &flags_tmp)

		ui.get_control_rect(cast(^ui.Container)py.Capsule_GetPointer(cnt_tmp, nil), {bounds_x_tmp, bounds_y_tmp, bounds_w_tmp, bounds_h_tmp}, cast(string)name_tmp, transmute(bit_set[ui.Control_Rect_Flags_Set; uint])(cast(u64)flags_tmp))

		return nil
	}

	ui_get_animation_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		cnt_tmp: py.Object_Ptr
		name_tmp: cstring
		initial_value_tmp: f32
		duration_tmp: f32

		py.Arg_ParseTuple(args, "Osff", &cnt_tmp, &name_tmp, &initial_value_tmp, &duration_tmp)

		ui.get_animation(cast(^ui.Container)py.Capsule_GetPointer(cnt_tmp, nil), cast(string)name_tmp, cast(f32)initial_value_tmp, cast(f32)duration_tmp)

		return nil
	}

	ui_begin_manual_layout_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		_bounds_x_tmp: f32
		_bounds_y_tmp: f32
		_bounds_w_tmp: f32
		_bounds_h_tmp: f32

		py.Arg_ParseTuple(args, "(ffff)", &_bounds_x_tmp, &_bounds_y_tmp, &_bounds_w_tmp, &_bounds_h_tmp)

		ui.begin_manual_layout({_bounds_x_tmp, _bounds_y_tmp, _bounds_w_tmp, _bounds_h_tmp})

		return nil
	}

	ui_begin_column_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		_bounds_x_tmp: f32
		_bounds_y_tmp: f32
		_bounds_w_tmp: f32
		_bounds_h_tmp: f32

		py.Arg_ParseTuple(args, "(ffff)", &_bounds_x_tmp, &_bounds_y_tmp, &_bounds_w_tmp, &_bounds_h_tmp)

		ui.begin_column({_bounds_x_tmp, _bounds_y_tmp, _bounds_w_tmp, _bounds_h_tmp})

		return nil
	}

	ui_begin_select_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		_bounds_x_tmp: f32
		_bounds_y_tmp: f32
		_bounds_w_tmp: f32
		_bounds_h_tmp: f32
		loc := py.get_caller_source_code_location()

		py.Arg_ParseTuple(args, "(ffff)", &_bounds_x_tmp, &_bounds_y_tmp, &_bounds_w_tmp, &_bounds_h_tmp)

		ui.begin_select({_bounds_x_tmp, _bounds_y_tmp, _bounds_w_tmp, _bounds_h_tmp}, loc)

		return nil
	}

	ui_slider_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		value_tmp: py.Object_Ptr
		min_tmp: f32
		max_tmp: f32
		_bounds_x_tmp: f32
		_bounds_y_tmp: f32
		_bounds_w_tmp: f32
		_bounds_h_tmp: f32
		loc := py.get_caller_source_code_location()

		py.Arg_ParseTuple(args, "Off(ffff)", &value_tmp, &min_tmp, &max_tmp, &_bounds_x_tmp, &_bounds_y_tmp, &_bounds_w_tmp, &_bounds_h_tmp)

		ui.slider(cast(^f32)py.Capsule_GetPointer(value_tmp, nil), cast(f32)min_tmp, cast(f32)max_tmp, {_bounds_x_tmp, _bounds_y_tmp, _bounds_w_tmp, _bounds_h_tmp}, loc)

		return nil
	}

	ui_textinput_python :: proc "c" (self: py.Object_Ptr, args: py.Object_Ptr) -> py.Object_Ptr {
		context = runtime.default_context()
		ctx_tmp: py.Object_Ptr
		_bounds_x_tmp: f32
		_bounds_y_tmp: f32
		_bounds_w_tmp: f32
		_bounds_h_tmp: f32
		loc := py.get_caller_source_code_location()

		py.Arg_ParseTuple(args, "O(ffff)", &ctx_tmp, &_bounds_x_tmp, &_bounds_y_tmp, &_bounds_w_tmp, &_bounds_h_tmp)

		ui.textinput(cast(^ui.Text_Editing_Context)py.Capsule_GetPointer(ctx_tmp, nil), {_bounds_x_tmp, _bounds_y_tmp, _bounds_w_tmp, _bounds_h_tmp}, loc)

		return nil
	}

	py.append_method(py_module, ui_cubic_bezier_python, "ui_cubic_bezier")
	py.append_method(py_module, ui_button_python, "ui_button")
	py.append_method(py_module, ui_icon_button_python, "ui_icon_button")
	py.append_method(py_module, ui_cell_editor_state_from_csv_python, "ui_cell_editor_state_from_csv")
	py.append_method(py_module, ui_cell_editor_python, "ui_cell_editor")
	py.append_method(py_module, ui_checkbox_python, "ui_checkbox")
	py.append_method(py_module, ui_get_avaliable_space_python, "ui_get_avaliable_space")
	py.append_method(py_module, ui_new_container_python, "ui_new_container")
	py.append_method(py_module, ui_pop_id_python, "ui_pop_id")
	py.append_method(py_module, ui_inc_zindex_python, "ui_inc_zindex")
	py.append_method(py_module, ui_dec_zindex_python, "ui_dec_zindex")
	py.append_method(py_module, ui_get_control_rect_python, "ui_get_control_rect")
	py.append_method(py_module, ui_get_animation_python, "ui_get_animation")
	py.append_method(py_module, ui_begin_manual_layout_python, "ui_begin_manual_layout")
	py.append_method(py_module, ui_begin_column_python, "ui_begin_column")
	py.append_method(py_module, ui_begin_select_python, "ui_begin_select")
	py.append_method(py_module, ui_slider_python, "ui_slider")
	py.append_method(py_module, ui_textinput_python, "ui_textinput")

	init :: proc "c" () -> py.Object_Ptr {
		return py.Module_Create2(py.get_py_module_ptr(py_module), py.ABI_VERSION)
	}

	py.setup_module(py_module, init)
}

} else {

load_python_sdk :: proc() {}

}
