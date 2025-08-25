package ui
/*
import "core:fmt"
import "core:math"
import "core:mem"
import "core:math/linalg"
import glm "core:math/linalg/glsl"
import "core:time"
import "core:sort"

import gl "vendor:OpenGL"
import stbtt "vendor:stb/truetype"

VERTEX_SOURCE :: #load("assets/vertex.vs", string)
FRAGMENT_SOURCE :: #load("assets/frag.fs", string)

GL_UI_Context :: struct {
	vao, vbo, vboi, ebo, program, font_atlas_texture: u32,
	uniforms: map[string]gl.Uniform_Info,
}

GL_UI_Primitive :: struct {
	pos0: [2]f32,
	pos1: [2]f32,
	uv0: [2]f32,
	uv1: [2]f32,
	roundness: f32,
	softness: f32,
	flags: u32,
	color0: [4]f32,
	color1: [4]f32,
	color2: [4]f32,
	color3: [4]f32,
	thickness: f32,
	clip_vec: [4]f32,
	angle: f32,
}

gl_ui_context: GL_UI_Context

draw_ui_primitives_opengl3_3 :: proc(primitives: []Primitive, window_width: f32, window_height: f32) {
	using gl_ui_context

	u_transform := linalg.matrix_ortho3d_f32(0, window_width, window_height, 0, -1, 1)
	gl.UniformMatrix4fv(uniforms["u_transform"].location, 1, false, &u_transform[0, 0])

	gl_primitives := make([]GL_UI_Primitive, 1024 * 64)
	defer delete(gl_primitives)

	gl_prim_count := 0

	for prim in primitives {
		switch prim.kind {
		case .Texture:
		case .Line:
			dx := prim.line.p0.x - prim.line.p1.x
			dy := prim.line.p0.y - prim.line.p1.y
			distance := math.sqrt(dx * dx + dy * dy) + 2
			angle := math.atan2(dy, dx) + math.PI

			gl_primitives[gl_prim_count].pos0 = { prim.line.p0.x, prim.line.p0.y }
			gl_primitives[gl_prim_count].pos1 = { prim.line.p0.x, prim.line.p0.y } + { distance, prim.line.thickness }
			gl_primitives[gl_prim_count].roundness = 0
			gl_primitives[gl_prim_count].softness = 1.5
			gl_primitives[gl_prim_count].color0 = prim.line.colors[0]
			gl_primitives[gl_prim_count].color1 = prim.line.colors[1]
			gl_primitives[gl_prim_count].color2 = prim.line.colors[2]
			gl_primitives[gl_prim_count].color3 = prim.line.colors[3]
			gl_primitives[gl_prim_count].thickness = 9999
			gl_primitives[gl_prim_count].angle = angle
			gl_primitives[gl_prim_count].clip_vec = {
				cast(f32)(prim.clip_rect.x),
				cast(f32)(prim.clip_rect.y),
				cast(f32)(prim.clip_rect.w + prim.clip_rect.x),
				cast(f32)(prim.clip_rect.h + prim.clip_rect.y),
			}
			gl_prim_count += 1
		case .Rect:
			gl_primitives[gl_prim_count].pos0 = { prim.rect.bounds.x, prim.rect.bounds.y }
			gl_primitives[gl_prim_count].pos1 = { prim.rect.bounds.x, prim.rect.bounds.y } + { prim.rect.bounds.w, prim.rect.bounds.h }
			gl_primitives[gl_prim_count].roundness = prim.rect.roundness
			gl_primitives[gl_prim_count].softness = prim.rect.softness
			gl_primitives[gl_prim_count].color0 = prim.rect.colors[0]
			gl_primitives[gl_prim_count].color1 = prim.rect.colors[1]
			gl_primitives[gl_prim_count].color2 = prim.rect.colors[2]
			gl_primitives[gl_prim_count].color3 = prim.rect.colors[3]
			gl_primitives[gl_prim_count].thickness = prim.rect.thickness < 0.001 ? 9999 : prim.rect.thickness
			gl_primitives[gl_prim_count].clip_vec = {
				cast(f32)(prim.clip_rect.x),
				cast(f32)(prim.clip_rect.y),
				cast(f32)(prim.clip_rect.w + prim.clip_rect.x),
				cast(f32)(prim.clip_rect.h + prim.clip_rect.y),
			}
			gl_prim_count += 1
		case .Text:
			font := get_font(prim.text.size, prim.text.kind)

			metrics := font.metrics

			x := cast(f32)prim.text.pos.x
			y := cast(f32)prim.text.pos.y
			for r, idx in prim.text.text {
				quad: stbtt.aligned_quad
				stbtt.GetPackedQuad(raw_data(metrics[:]), FONT_ATLAS_WIDTH, FONT_ATLAS_HEIGHT, cast(i32)r - font.range_start, &x, &y, &quad, false)

				gl_primitives[gl_prim_count].pos0 = [2]f32{quad.x0, quad.y0 + font.y_offset}
				gl_primitives[gl_prim_count].pos1 = [2]f32{quad.x1, quad.y1 + font.y_offset}
				gl_primitives[gl_prim_count].uv0 = [2]f32{quad.s0, quad.t1}
				gl_primitives[gl_prim_count].uv1 = [2]f32{quad.s1, quad.t0}
				gl_primitives[gl_prim_count].color0 = prim.text.colors[0]
				gl_primitives[gl_prim_count].color1 = prim.text.colors[1]
				gl_primitives[gl_prim_count].color2 = prim.text.colors[2]
				gl_primitives[gl_prim_count].color3 = prim.text.colors[3]
				gl_primitives[gl_prim_count].flags = 1
				gl_primitives[gl_prim_count].clip_vec = {
					cast(f32)(prim.clip_rect.x),
					cast(f32)(prim.clip_rect.y),
					cast(f32)(prim.clip_rect.w + prim.clip_rect.x),
					cast(f32)(prim.clip_rect.h + prim.clip_rect.y),
				}

				gl_prim_count += 1
			}
		}
	}

	gl.BindTexture(gl.TEXTURE_2D, font_atlas_texture)
	gl.BindBuffer(gl.ARRAY_BUFFER, vboi)	
	gl.BufferData(gl.ARRAY_BUFFER, gl_prim_count * size_of(gl_primitives[0]), raw_data(gl_primitives), gl.DYNAMIC_DRAW)

	gl.DrawElementsInstanced(gl.TRIANGLES, 6, gl.UNSIGNED_SHORT, nil, cast(i32)gl_prim_count)
}

generate_font_texture :: proc(bitmap: []byte, tex: ^u32) {
	gl.GenTextures(1, tex)
	gl.BindTexture(gl.TEXTURE_2D, tex^)
	
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)

	gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RED, FONT_ATLAS_WIDTH, FONT_ATLAS_HEIGHT, 0, gl.RED, gl.UNSIGNED_BYTE, raw_data(bitmap))
	//gl.GenerateMipmap(gl.TEXTURE_2D)
}

begin_frame_opengl3_3 :: proc(window_width: f32, window_height: f32) {
	gl.Viewport(0, 0, cast(i32)window_width, cast(i32)window_height)
	//gl.ClearColor(0.24, 0.25, 0.46, 1.0)
	gl.ClearColor(0.0, 0.0, 0.1, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)
}

setup_render_opengl3_3 :: proc(set_proc_address: proc(p: rawptr, name: cstring)) {
	setup_opengl(set_proc_address)
	setup_render_context()
	generate_font_texture(FONT_ATLAS_BITMAP_SOURCE, &gl_ui_context.font_atlas_texture)
}

setup_opengl :: proc(set_proc_address: proc(p: rawptr, name: cstring)) {
	gl.load_up_to(3, 3, set_proc_address)

	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
}

setup_render_context :: proc() {
	using gl_ui_context

	program_tmp, program_ok := gl.load_shaders_source(VERTEX_SOURCE, FRAGMENT_SOURCE)
	if !program_ok {
		fmt.eprintln("Failed to create GLSL program")
		return
	}

	program = program_tmp
	
	gl.UseProgram(program)
	
	uniforms = gl.get_uniforms_from_program(program)
	
	gl.GenVertexArrays(1, &vao)
	gl.GenBuffers(1, &vbo)
	gl.GenBuffers(1, &ebo)
	gl.GenBuffers(1, &vboi)
		
	vertices := []f32{
		0, 1,
		0, 0,
		1, 0,
		1, 1,
	}
	
	indices := []u16{
		0, 1, 2,
		2, 3, 0,
	}

	// vbo	
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, len(vertices)*size_of(vertices[0]), raw_data(vertices), gl.STATIC_DRAW)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 2, gl.FLOAT, false, size_of([2]f32), 0)

	// vboi
	gl.BindBuffer(gl.ARRAY_BUFFER, vboi)
	
	// pos1
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(1, 2, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, pos0))
	gl.VertexAttribDivisor(1, 1)

	// pos2
	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(2, 2, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, pos1))
	gl.VertexAttribDivisor(2, 1)

	// uv0
	gl.EnableVertexAttribArray(3)
	gl.VertexAttribPointer(3, 2, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, uv0))
	gl.VertexAttribDivisor(3, 1)

	// uv1
	gl.EnableVertexAttribArray(4)
	gl.VertexAttribPointer(4, 2, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, uv1))
	gl.VertexAttribDivisor(4, 1)

	// roundness
	gl.EnableVertexAttribArray(5)
	gl.VertexAttribPointer(5, 1, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, roundness))
	gl.VertexAttribDivisor(5, 1)

	// softness
	gl.EnableVertexAttribArray(6)
	gl.VertexAttribPointer(6, 1, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, softness))
	gl.VertexAttribDivisor(6, 1)

	// flags
	gl.EnableVertexAttribArray(7)
	gl.VertexAttribIPointer(7, 1, gl.UNSIGNED_INT, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, flags))
	gl.VertexAttribDivisor(7, 1)

	// color0
	gl.EnableVertexAttribArray(8)
	gl.VertexAttribPointer(8, 4, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, color0))
	gl.VertexAttribDivisor(8, 1)

	// color1
	gl.EnableVertexAttribArray(9)
	gl.VertexAttribPointer(9, 4, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, color1))
	gl.VertexAttribDivisor(9, 1)

	// color2
	gl.EnableVertexAttribArray(10)
	gl.VertexAttribPointer(10, 4, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, color2))
	gl.VertexAttribDivisor(10, 1)
	
	// color3
	gl.EnableVertexAttribArray(11)
	gl.VertexAttribPointer(11, 4, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, color3))
	gl.VertexAttribDivisor(11, 1)

	// border size
	gl.EnableVertexAttribArray(12)
	gl.VertexAttribPointer(12, 1, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, thickness))
	gl.VertexAttribDivisor(12, 1)
	
	// clip_vec
	gl.EnableVertexAttribArray(13)
	gl.VertexAttribPointer(13, 4, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, clip_vec))
	gl.VertexAttribDivisor(13, 1)

	// angle
	gl.EnableVertexAttribArray(14)
	gl.VertexAttribPointer(14, 1, gl.FLOAT, false, size_of(GL_UI_Primitive), offset_of(GL_UI_Primitive, angle))
	gl.VertexAttribDivisor(14, 1)

	// ebo
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices)*size_of(indices[0]), raw_data(indices), gl.STATIC_DRAW)
}
*/