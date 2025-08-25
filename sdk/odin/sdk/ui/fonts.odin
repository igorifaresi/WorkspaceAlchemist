package ui

import stbtt "vendor:stb/truetype"

FONT_SIZES :: []int{14, 16, 20, 24}
FONT_RANGE_START :: 0x00
FONT_RANGE_SIZE :: 0xff
FONT_ATLAS_WIDTH :: 4096
FONT_ATLAS_HEIGHT :: 4096
FONT_OVERSAMPLING_FACTOR :: 2
FONT_ATLAS_BITMAP_SOURCE :: #load("assets/font_atlas_bitmap.bin")
FONT_ATLAS_MAP_SOURCE :: #load("assets/font_atlas_map.bin")
FONT_SOURCES :: [Font_Kind]Font_Source {
	.Regular   = {
		data = #load("assets/droid-sans-regular.ttf", []byte),
		range_start = FONT_RANGE_START,
		range_size = FONT_RANGE_SIZE,
	},
	.Italic    = {
		data = #load("assets/Roboto-Italic.ttf", []byte),
		range_start = FONT_RANGE_START,
		range_size = FONT_RANGE_SIZE,
	},
	.Bold      = {
		data = #load("assets/droid-sans-bold.ttf", []byte),
		range_start = FONT_RANGE_START,
		range_size = FONT_RANGE_SIZE,
	},
	.Monospace = {
		data = #load("assets/droid-sans-mono.ttf", []byte),
		range_start = FONT_RANGE_START,
		range_size = FONT_RANGE_SIZE,
	},
	.Icon = {
		data = #load("assets/fa-solid-900.ttf", []byte),
		range_start = ICON_FONT_RANGE_START,
		range_size = ICON_FONT_RANGE_SIZE,
	},
}

FONT_SIZES_TRANSLATION := [Font_Size]int {
	.Small = 14,
	.Medium = 16,
	.Large = 20,
	.Very_Large = 24,
}

font_palette: ^Font_Palette

load_font_palette :: proc() {
	font_palette = new(Font_Palette)
	copy_slice((cast([^]byte)font_palette)[:size_of(Font_Palette)], FONT_ATLAS_MAP_SOURCE)
}

get_font :: proc(size: Font_Size, kind: Font_Kind) -> Font {
	font := font_palette[kind][size]
	return font
}

measure_text :: proc(text: string, size: Font_Size, kind: Font_Kind = .Regular) -> [2]f32 {
	result := [2]f32{}
	font := get_font(size, kind)	
	
	metrics := font.metrics
	x : f32 = 0
	y : f32 = 0
	for r in text {
		quad: stbtt.aligned_quad
		stbtt.GetPackedQuad(raw_data(metrics[:]), FONT_ATLAS_WIDTH, FONT_ATLAS_HEIGHT, cast(i32)r - font.range_start, &x, &y, &quad, false)
	}
	result.x = x
	result.y = font.real_height

	return result	
}

generate_font_atlas :: proc() -> (bitmap: []byte, palette: ^Font_Palette) {
	palette = new(Font_Palette)
	bitmap = make([]byte, FONT_ATLAS_HEIGHT * FONT_ATLAS_WIDTH, context.temp_allocator)

    pc: stbtt.pack_context

    stbtt.PackBegin(&pc, raw_data(bitmap), FONT_ATLAS_WIDTH, FONT_ATLAS_HEIGHT, 0, 1, nil)   
    stbtt.PackSetOversampling(&pc, 2, 2)

	for source, kind in FONT_SOURCES {
		ranges := make([]stbtt.pack_range, len(FONT_SIZES), context.temp_allocator)
		qnt := 0

		for size_in_pixels, size_enum_item in FONT_SIZES_TRANSLATION {
			ranges[qnt] = {
				cast(f32)size_in_pixels,
				source.range_start,
				nil,
				source.range_size,
				raw_data(palette[kind][size_enum_item].metrics[:]),
				0,
				0,
			}

			qnt += 1

			palette[kind][size_enum_item].range_start = source.range_start
			palette[kind][size_enum_item].range_size = source.range_size
		}

		stbtt.PackFontRanges(&pc, raw_data(source.data), 0, raw_data(ranges), cast(i32)len(ranges))

		for &font in palette[kind] {
			fh_min: f32
			fh_max: f32
			for pchar in font.metrics {
				if fh_min > pchar.yoff do fh_min = pchar.yoff
				if fh_max < pchar.yoff2 do fh_max = pchar.yoff2
			}

			font.real_height = fh_max - fh_min
			font.y_offset = -fh_min
		}
	}

    stbtt.PackEnd(&pc)

	return bitmap, palette	
}
