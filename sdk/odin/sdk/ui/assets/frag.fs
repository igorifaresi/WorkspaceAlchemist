#version 330 core

in vec2 fs_pos;
in vec2 fs_uv;
in vec4 fs_color;
flat in vec2 fs_rect_center;
flat in vec2 fs_rect_half_size;
flat in float fs_roundness;
flat in float fs_softness;
flat in uint  fs_flags;
flat in float fs_thickness;
flat in vec4 fs_clip_vec;

out vec4 FragColor;
uniform sampler2D tex;

float rounded_rect_sdf(vec2 sample_pos, vec2 rect_center, vec2 rect_half_size, float r) {
    vec2 d2 = (abs(rect_center - sample_pos) - rect_half_size + vec2(r, r));
    return min(max(d2.x, d2.y), 0.0) + length(max(d2, 0.0)) - r;
}

void main() {
    if (fs_pos.x >= fs_clip_vec[0] && fs_pos.x <= fs_clip_vec[2] 
    &&  fs_pos.y >= fs_clip_vec[1] && fs_pos.y <= fs_clip_vec[3]) {
        if (fs_flags == uint(1)) {
            vec4 c = texture(tex, fs_uv);
            FragColor = vec4(fs_color.rgb, c.r * fs_color.a);
        } else {
            vec2 softness_padding = vec2(max(0, fs_softness * 2 - 1), max(0, fs_softness * 2 - 1));
            float dist = rounded_rect_sdf(fs_pos, fs_rect_center, fs_rect_half_size - softness_padding, fs_roundness);
            dist = dist < -fs_thickness ? 2.0 : dist;
            float sdf_factor = 1.0 - smoothstep(0, 2 * fs_softness, dist);
            FragColor = vec4(fs_color.rgb, sdf_factor * fs_color.a);
        }
    } else {
        FragColor = vec4(0, 0, 0, 0);
    }
}
