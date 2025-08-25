#version 330 core

layout(location=0) in vec2 vertex_idx;
layout(location=1) in vec2 pos0;
layout(location=2) in vec2 pos1;
layout(location=3) in vec2 uv0;
layout(location=4) in vec2 uv1;
layout(location=5) in float roundness;
layout(location=6) in float softness;
layout(location=7) in uint flags;
layout(location=8) in vec4 color0;
layout(location=9) in vec4 color1;
layout(location=10) in vec4 color2;
layout(location=11) in vec4 color3;
layout(location=12) in float thickness;
layout(location=13) in vec4 clip_vec;
layout(location=14) in float angle;

out vec2 fs_pos;
out vec2 fs_uv;
out vec4 fs_color;
flat out vec2 fs_rect_center;
flat out vec2 fs_rect_half_size;
flat out float fs_roundness;
flat out float fs_softness;
flat out uint fs_flags;
flat out float fs_thickness;
flat out vec4 fs_clip_vec;

uniform mat4 u_transform;

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, s, -s, c);
	return m * v;
}

void main() {	
	vec2 pos = vec2(vertex_idx.x > 0 ? pos1.x : pos0.x, vertex_idx.y > 0 ? pos1.y : pos0.y);
	vec2 uv = vec2(vertex_idx.x > 0 ? uv1.x : uv0.x, vertex_idx.y > 0 ? uv0.y : uv1.y);
	vec4 color = vertex_idx.x > 0 ? 
		(vertex_idx.y > 0 ? color3 : color1) : (vertex_idx.y > 0 ? color2 : color0);

	fs_rect_half_size = (pos1 - pos0) * 0.5; 

	vec2 offset_vec = vec2(-pos0.x, -pos0.y);
	vec2 rotated_vec = rotate(pos + offset_vec, angle);
	vec2 restaured_vec = rotated_vec - offset_vec;

	gl_Position = u_transform * vec4(restaured_vec, 0.0, 1.0);
	
	fs_pos = pos;
    fs_uv = uv;
	fs_color = color;
	fs_rect_center = (pos1 + pos0) * 0.5;
	fs_roundness = roundness;
	fs_softness = softness;
	fs_flags = flags;
	fs_thickness = thickness;
	fs_clip_vec = clip_vec;
}