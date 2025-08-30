package render

Primitive :: struct #align(16) {
	pos0: [2]f32,
	pos1: [2]f32,
	uv0: [2]f32,
	uv1: [2]f32,
	roundness: f32,
	softness: f32,
	flags: f32,
	texture_idx: f32,
	color0: [4]f32,
	color1: [4]f32,
	color2: [4]f32,
	color3: [4]f32,
	thickness: f32,
	clip_vec: [4]f32,
	angle: f32,
}

Texture_Format :: enum {
	RGBA,
	R,
}