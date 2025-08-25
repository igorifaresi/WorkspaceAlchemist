struct vertexdesc
{
	float2 idx      : INDEX;
	float2 rn_screensize : SCREENSIZE;
    float2 pos0     : POS0;
	float2 pos1     : POS1;
	float2 uv0      : UV0;
	float2 uv1      : UV1;
	float roundness : PARAM0;
	float softness  : PARAM1;
	float flags     : PARAM2;
	float texture_idx : PARAM3;
	float4 color0   : COLOR0;
	float4 color1   : COLOR1;
	float4 color2   : COLOR2;
	float4 color3   : COLOR3;
	float thickness : PARAM4;
	float4 clip_vec  : RECT;
	float angle     : ANGLE;
};

struct pixeldesc
{
    float4 position   : SV_POSITION;
    float2 screen_pos : POS;
	float2 uv         : UV;
    float4 color      : COLOR;
	nointerpolation float2 rect_center    : SIZE0;
	nointerpolation float2 rect_half_size : SIZE1;
	nointerpolation float roundness       : PARAM0;
	nointerpolation float softness        : PARAM1;
	nointerpolation uint flags            : FLAGS;
	nointerpolation uint texture_idx      : PARAM2;
	nointerpolation float thickness       : PARAM3;
	nointerpolation float4 clip_vec       : RECT;
};

Texture2D<float> font_atlas : register(t0);
SamplerState    font_atlas_sampler : register(s0);
Texture2D<float4> ext_textures[8] : register(t1);

float2 rotate(float2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	float2x2 m = {c, s, -s, c};
	float2 result = mul(v, m);
    return result;
}

pixeldesc VsMain(vertexdesc vertex)
{
    pixeldesc output;

	float2 pos = float2(vertex.idx.x > 0 ? vertex.pos1.x : vertex.pos0.x, vertex.idx.y > 0 ? vertex.pos1.y : vertex.pos0.y);
	float2 uv = float2(vertex.idx.x > 0 ? vertex.uv1.x : vertex.uv0.x, vertex.idx.y > 0 ? vertex.uv0.y : vertex.uv1.y);
	float4 color = vertex.idx.x > 0 ? (vertex.idx.y > 0 ? vertex.color3 : vertex.color1) : (vertex.idx.y > 0 ? vertex.color2 : vertex.color0);

	float2 offset_vec = float2(-vertex.pos0.x, -vertex.pos0.y);
	float2 rotated_vec = rotate(pos + offset_vec, vertex.angle);
	float2 restaured_vec = rotated_vec - offset_vec;

	output.rect_half_size = (vertex.pos1 - vertex.pos0) * 0.5;
	//output.position = float4(pos * vertex.rn_screensize - float2(1, -1), 0.0, 1.0);
	output.position = float4(restaured_vec * vertex.rn_screensize - float2(1, -1), 0.0, 1.0);
	output.screen_pos = pos;
    output.uv = uv;
	output.color = color;
	output.rect_center = (vertex.pos1 + vertex.pos0) * 0.5;
	output.roundness = vertex.roundness;
	output.softness = vertex.softness;
	output.flags = vertex.flags;
	output.texture_idx = vertex.texture_idx;
	output.thickness = vertex.thickness;
	output.clip_vec = vertex.clip_vec;

    return output;
}


float rounded_rect_sdf(float2 sample_pos, float2 rect_center, float2 rect_half_size, float r)
{
    float2 d2 = abs(rect_center - sample_pos) - rect_half_size + float2(r, r);
    return min(max(d2.x, d2.y), 0.0) + length(max(d2, 0.0)) - r;
}

float4 PsMain(pixeldesc pixel) : SV_TARGET
{
	if (pixel.screen_pos.x >= pixel.clip_vec.x && pixel.screen_pos.x <= pixel.clip_vec.z
	&&  pixel.screen_pos.y >= pixel.clip_vec.y && pixel.screen_pos.y <= pixel.clip_vec.w) {
		if (pixel.flags == 1) {
			float r = font_atlas.Sample(font_atlas_sampler, pixel.uv);
			return float4(pixel.color.r, pixel.color.g, pixel.color.b, r * pixel.color.a);
		}

		if (pixel.flags == 2) {
			switch (pixel.texture_idx) {
			case 0: { return ext_textures[0].Sample(font_atlas_sampler, pixel.uv) * pixel.color; } break;
			case 1: { return ext_textures[1].Sample(font_atlas_sampler, pixel.uv) * pixel.color; } break;
			case 2: { return ext_textures[2].Sample(font_atlas_sampler, pixel.uv) * pixel.color; } break;
			case 3: { return ext_textures[3].Sample(font_atlas_sampler, pixel.uv) * pixel.color; } break;
			case 4: { return ext_textures[4].Sample(font_atlas_sampler, pixel.uv) * pixel.color; } break;
			case 5: { return ext_textures[5].Sample(font_atlas_sampler, pixel.uv) * pixel.color; } break;
			case 6: { return ext_textures[6].Sample(font_atlas_sampler, pixel.uv) * pixel.color; } break;
			case 7: { return ext_textures[7].Sample(font_atlas_sampler, pixel.uv) * pixel.color; } break;
			}
		}

        float2 softness_padding = float2(max(0, pixel.softness * 2 - 1), max(0, pixel.softness * 2 - 1));
        float dist = rounded_rect_sdf(
        	pixel.screen_pos,
        	pixel.rect_center,
        	pixel.rect_half_size - softness_padding,
        	pixel.roundness
        );
        dist = dist < -pixel.thickness ? -1 * (dist - pixel.thickness) : dist;
        float sdf_factor = 1.0 - smoothstep(0, 2 * pixel.softness, dist);
        return float4(pixel.color.rgb, sdf_factor * pixel.color.a);
	}

	return float4(0, 0, 0, 0);
    //return pixel.color;
}