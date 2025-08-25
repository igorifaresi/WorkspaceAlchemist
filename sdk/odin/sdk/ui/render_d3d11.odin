#+build windows

package ui

import win "core:sys/windows"
import D3D11 "vendor:directx/d3d11"
import DXGI "vendor:directx/dxgi"
import D3D "vendor:directx/d3d_compiler"
import SDL "vendor:sdl2"
import glm "core:math/linalg/glsl"
import "core:fmt"
import stbtt "vendor:stb/truetype"
import "core:math"

shaders_hlsl := #load("assets/shader.hlsl")

D3D11_DEBUG :: #config(D3D11_DEBUG, true)

D3D11_Context :: struct {
    device:              ^D3D11.IDevice,
    device_context:      ^D3D11.IDeviceContext,
	swapchain:           ^DXGI.ISwapChain,
	framebuffer:         ^D3D11.ITexture2D,
	framebuffer_view:    ^D3D11.IRenderTargetView,
	render_texture_view: ^D3D11.IRenderTargetView,
	input_layout:        ^D3D11.IInputLayout,
	vertex_buffer:       ^D3D11.IBuffer,
	pixel_shader:        ^D3D11.IPixelShader,
	vertex_shader:       ^D3D11.IVertexShader,
	rasterizer_state:    ^D3D11.IRasterizerState,
    sampler_state:       ^D3D11.ISamplerState,
    blend_state:         ^D3D11.IBlendState,
    font_atlas_srv:      ^D3D11.IShaderResourceView,
    viewport:             D3D11.VIEWPORT,
}

D3D11_Vertex :: struct #align(16) {
	idx: glm.vec2,
	screen_size: glm.vec2,			
}

D3D11_UI_Primitive :: struct #align(16) {
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

d3d11_context: D3D11_Context

load_shared_texture :: proc(handle: win.HANDLE) -> rawptr {
	using d3d11_context
	
	resource: ^DXGI.IResource
	device->OpenSharedResource(handle, D3D11.IResource_UUID, (^rawptr)(&resource))
	
	tex: ^D3D11.ITexture2D
	resource->QueryInterface(D3D11.ITexture2D_UUID, (^rawptr)(&tex))
	resource->Release()

	tex_srv: ^D3D11.IShaderResourceView

	srv_desc := D3D11.SHADER_RESOURCE_VIEW_DESC{}
    srv_desc.Format = .R8G8B8A8_UNORM
    srv_desc.ViewDimension = .TEXTURE2D
    srv_desc.Texture2D.MipLevels = 1

    device->CreateShaderResourceView(tex, &srv_desc, &tex_srv)

	return tex_srv
}

load_texture :: proc(pixels: []byte, width: int, height: int) -> rawptr {
	using d3d11_context
	
    tex_desc := D3D11.TEXTURE2D_DESC{}
    tex_desc.Width            = cast(u32)width
    tex_desc.Height           = cast(u32)height
    tex_desc.MipLevels        = 1
    tex_desc.ArraySize        = 1
    tex_desc.Format           = .R8G8B8A8_UNORM
    tex_desc.SampleDesc.Count = 1
    tex_desc.Usage            = .IMMUTABLE
    tex_desc.BindFlags        = {.SHADER_RESOURCE}

    tex_srd: D3D11.SUBRESOURCE_DATA
    tex_srd.pSysMem     = raw_data(pixels)
    tex_srd.SysMemPitch = cast(u32)width

    tex: ^D3D11.ITexture2D
    device->CreateTexture2D(&tex_desc, &tex_srd, &tex)

	tex_srv: ^D3D11.IShaderResourceView

    tex_srv_desc := D3D11.SHADER_RESOURCE_VIEW_DESC{}
    tex_srv_desc.Format = .R8G8B8A8_UNORM
    tex_srv_desc.ViewDimension = .TEXTURE2D
    tex_srv_desc.Texture2D.MipLevels = 1

    device->CreateShaderResourceView(tex, &tex_srv_desc, &tex_srv)

	return tex_srv
}

setup_render_d3d11_common :: proc() {
	using d3d11_context

	///////////////////////////////////////////////////////////////////////////////////////////////

	error_msg: ^D3D11.IBlob

	vs_blob: ^D3D11.IBlob
	D3D.Compile(raw_data(shaders_hlsl), len(shaders_hlsl), "shaders.hlsl", nil, nil, "VsMain", "vs_5_0", 0, 0, &vs_blob, &error_msg)
	if vs_blob == nil {
		if error_msg != nil {
			fmt.println("Error compiling shader:", cast(cstring)error_msg->GetBufferPointer())
		}
	}

	assert(vs_blob != nil)

	device->CreateVertexShader(vs_blob->GetBufferPointer(), vs_blob->GetBufferSize(), nil, &vertex_shader)

	input_element_desc := [?]D3D11.INPUT_ELEMENT_DESC{
		{ "INDEX"     , 0, .R32G32_FLOAT, 0, cast(u32)offset_of(D3D11_Vertex, idx)        , .VERTEX_DATA, 0 },
		{ "SCREENSIZE", 0, .R32G32_FLOAT, 0, cast(u32)offset_of(D3D11_Vertex, screen_size), .VERTEX_DATA, 0 },
		
		{ "POS"  , 0, .R32G32_FLOAT      , 1, cast(u32)offset_of(D3D11_UI_Primitive, pos0)       , .INSTANCE_DATA, 1 },
		{ "POS"  , 1, .R32G32_FLOAT      , 1, cast(u32)offset_of(D3D11_UI_Primitive, pos1)       , .INSTANCE_DATA, 1 },
		{ "UV"   , 0, .R32G32_FLOAT      , 1, cast(u32)offset_of(D3D11_UI_Primitive, uv0)        , .INSTANCE_DATA, 1 },
		{ "UV"   , 1, .R32G32_FLOAT      , 1, cast(u32)offset_of(D3D11_UI_Primitive, uv1)        , .INSTANCE_DATA, 1 },
		{ "PARAM", 0, .R32_FLOAT         , 1, cast(u32)offset_of(D3D11_UI_Primitive, roundness)  , .INSTANCE_DATA, 1 },
		{ "PARAM", 1, .R32_FLOAT         , 1, cast(u32)offset_of(D3D11_UI_Primitive, softness)   , .INSTANCE_DATA, 1 },
		{ "PARAM", 2, .R32_FLOAT         , 1, cast(u32)offset_of(D3D11_UI_Primitive, flags)      , .INSTANCE_DATA, 1 },
		{ "PARAM", 3, .R32_FLOAT         , 1, cast(u32)offset_of(D3D11_UI_Primitive, texture_idx), .INSTANCE_DATA, 1 },
		{ "COLOR", 0, .R32G32B32A32_FLOAT, 1, cast(u32)offset_of(D3D11_UI_Primitive, color0)     , .INSTANCE_DATA, 1 },
		{ "COLOR", 1, .R32G32B32A32_FLOAT, 1, cast(u32)offset_of(D3D11_UI_Primitive, color1)     , .INSTANCE_DATA, 1 },
		{ "COLOR", 2, .R32G32B32A32_FLOAT, 1, cast(u32)offset_of(D3D11_UI_Primitive, color2)     , .INSTANCE_DATA, 1 },
		{ "COLOR", 3, .R32G32B32A32_FLOAT, 1, cast(u32)offset_of(D3D11_UI_Primitive, color3)     , .INSTANCE_DATA, 1 },
		{ "PARAM", 4, .R32_FLOAT         , 1, cast(u32)offset_of(D3D11_UI_Primitive, thickness)  , .INSTANCE_DATA, 1 },
		{ "RECT" , 0, .R32G32B32A32_FLOAT, 1, cast(u32)offset_of(D3D11_UI_Primitive, clip_vec)   , .INSTANCE_DATA, 1 },
		{ "ANGLE", 0, .R32_FLOAT         , 1, cast(u32)offset_of(D3D11_UI_Primitive, angle)      , .INSTANCE_DATA, 1 },
	}

	device->CreateInputLayout(&input_element_desc[0], len(input_element_desc), vs_blob->GetBufferPointer(), vs_blob->GetBufferSize(), &input_layout)

	ps_blob: ^D3D11.IBlob
	D3D.Compile(raw_data(shaders_hlsl), len(shaders_hlsl), "shaders.hlsl", nil, nil, "PsMain", "ps_5_0", 0, 0, &ps_blob, &error_msg)
	if ps_blob == nil {
		if error_msg != nil {
			fmt.println("Error compiling shader:", cast(cstring)error_msg->GetBufferPointer())
		}
	}

	assert(ps_blob != nil)

	device->CreatePixelShader(ps_blob->GetBufferPointer(), ps_blob->GetBufferSize(), nil, &pixel_shader)

	///////////////////////////////////////////////////////////////////////////////////////////////

	rasterizer_desc := D3D11.RASTERIZER_DESC{
		FillMode = .SOLID,
		CullMode = .NONE,
	}
	device->CreateRasterizerState(&rasterizer_desc, &rasterizer_state)

	///////////////////////////////////////////////////////////////////////////////////////////////

    sampler_desc := D3D11.SAMPLER_DESC{
    	Filter = .MIN_MAG_MIP_LINEAR,
		AddressU = .BORDER,
		AddressV = .BORDER,
    	AddressW = .BORDER,
    }
    device->CreateSamplerState(&sampler_desc, &sampler_state)

	///////////////////////////////////////////////////////////////////////////////////////////////

	blend_desc: D3D11.BLEND_DESC
	blend_desc.AlphaToCoverageEnable = false
	blend_desc.IndependentBlendEnable = false
	blend_desc.RenderTarget[0] = {
		BlendEnable           = true,
		SrcBlend              = .SRC_ALPHA,
		DestBlend             = .INV_SRC_ALPHA,
		BlendOp               = .ADD,
		SrcBlendAlpha         = .ONE,
		DestBlendAlpha        = .DEST_ALPHA,
		BlendOpAlpha          = .ADD,
		RenderTargetWriteMask = cast(u8)D3D11.COLOR_WRITE_ENABLE_ALL,
	}
    device->CreateBlendState(&blend_desc, &blend_state)

    ///////////////////////////////////////////////////////////////////////////////////////////////

    font_atlas_desc := D3D11.TEXTURE2D_DESC{}
    font_atlas_desc.Width            = cast(u32)FONT_ATLAS_WIDTH
    font_atlas_desc.Height           = cast(u32)FONT_ATLAS_HEIGHT
    font_atlas_desc.MipLevels        = 1
    font_atlas_desc.ArraySize        = 1
    font_atlas_desc.Format           = .R8_UNORM
    font_atlas_desc.SampleDesc.Count = 1
    font_atlas_desc.Usage            = .IMMUTABLE
    font_atlas_desc.BindFlags        = {.SHADER_RESOURCE}

    font_atlas_srd: D3D11.SUBRESOURCE_DATA
    font_atlas_srd.pSysMem     = raw_data(FONT_ATLAS_BITMAP_SOURCE)
    font_atlas_srd.SysMemPitch = cast(u32)FONT_ATLAS_WIDTH

    font_atlas: ^D3D11.ITexture2D
    device->CreateTexture2D(&font_atlas_desc, &font_atlas_srd, &font_atlas)

    srv_desc := D3D11.SHADER_RESOURCE_VIEW_DESC{}
    srv_desc.Format = .R8_UNORM
    srv_desc.ViewDimension = .TEXTURE2D
    srv_desc.Texture2D.MipLevels = 1

    device->CreateShaderResourceView(font_atlas, &srv_desc, &font_atlas_srv)

	///////////////////////////////////////////////////////////////////////////////////////////////	

	vertex_buffer_desc := D3D11.BUFFER_DESC{
		ByteWidth      = size_of(D3D11_Vertex) * 4 + size_of(D3D11_UI_Primitive) * 1024 * 16,
		Usage          = .DYNAMIC,
		BindFlags      = {.VERTEX_BUFFER},
		CPUAccessFlags = {.WRITE},
	}
	device->CreateBuffer(&vertex_buffer_desc, nil, &vertex_buffer)
}

setup_render_d3d11_headless :: proc(width: f32, height: f32) -> win.HANDLE {
	using d3d11_context

	///////////////////////////////////////////////////////////////////////////////////////////////

	feature_levels := [?]D3D11.FEATURE_LEVEL{._11_0}

	when D3D11_DEBUG {
	    D3D11.CreateDevice(nil, .HARDWARE, nil, {.BGRA_SUPPORT, .DEBUG},  &feature_levels[0], len(feature_levels), D3D11.SDK_VERSION, &device, nil, &device_context)

	    {
	        info: ^D3D11.IInfoQueue
	        device->QueryInterface(D3D11.IInfoQueue_UUID, (^rawptr)(&info))
	        info->SetBreakOnSeverity(.CORRUPTION, true)
	        info->SetBreakOnSeverity(.ERROR, true)
	        info->Release()
	    }

	    {
	        info: ^DXGI.IInfoQueue
	        hr := DXGI.DXGIGetDebugInterface1(0, DXGI.IInfoQueue_UUID, (^rawptr)(&info))
	        assert(hr == 0)
	        info->SetBreakOnSeverity(DXGI.DEBUG_ALL, .CORRUPTION, true)
	        info->SetBreakOnSeverity(DXGI.DEBUG_ALL, .ERROR, true)
	        info->Release()
	    }
	} else {
	    D3D11.CreateDevice(nil, .HARDWARE, nil, {.BGRA_SUPPORT},  &feature_levels[0], len(feature_levels), D3D11.SDK_VERSION, &device, nil, &device_context)
	}

	///////////////////////////////////////////////////////////////////////////////////////////////

	setup_render_d3d11_common()

	///////////////////////////////////////////////////////////////////////////////////////////////	

	render_texture_desc := D3D11.TEXTURE2D_DESC{}
	render_texture_desc.Width            = cast(u32)width
	render_texture_desc.Height           = cast(u32)height
	render_texture_desc.MipLevels        = 1
	render_texture_desc.ArraySize        = 1
	render_texture_desc.Format           = .R8G8B8A8_UNORM
	render_texture_desc.SampleDesc.Count = 1
	render_texture_desc.Usage            = .DEFAULT
	render_texture_desc.BindFlags        = {.RENDER_TARGET, .SHADER_RESOURCE}
	render_texture_desc.MiscFlags       = {.SHARED}

	render_texture: ^D3D11.ITexture2D
	device->CreateTexture2D(&render_texture_desc, nil, &render_texture)
	device->CreateRenderTargetView(render_texture, nil, &render_texture_view)

	handle: win.HANDLE
	resource: ^DXGI.IResource
	status2 := render_texture->QueryInterface(DXGI.IResource_UUID, (^rawptr)(&resource))
	status := resource->GetSharedHandle(&handle)

	return handle
}

setup_render_d3d11 :: proc(native_window: DXGI.HWND) {
	using d3d11_context

	///////////////////////////////////////////////////////////////////////////////////////////////

	feature_levels := [?]D3D11.FEATURE_LEVEL{._11_0}

	swapchain_desc := DXGI.SWAP_CHAIN_DESC{
		BufferDesc = {
			Format = .B8G8R8A8_UNORM,
		},
		SampleDesc = {
			Count   = 1,
			Quality = 0,
		},
		BufferUsage = {.RENDER_TARGET_OUTPUT},
		BufferCount = 2,
		SwapEffect  = .DISCARD,
		Windowed    = true,
		OutputWindow = native_window,
	}

	when D3D11_DEBUG {
	    D3D11.CreateDeviceAndSwapChain(nil, .HARDWARE, nil, {.BGRA_SUPPORT, .DEBUG},  &feature_levels[0], len(feature_levels), D3D11.SDK_VERSION, &swapchain_desc, &swapchain, &device, nil, &device_context)

	    {
	        info: ^D3D11.IInfoQueue
	        device->QueryInterface(D3D11.IInfoQueue_UUID, (^rawptr)(&info))
	        info->SetBreakOnSeverity(.CORRUPTION, true)
	        info->SetBreakOnSeverity(.ERROR, true)
	        info->Release()
	    }

	    {
	        info: ^DXGI.IInfoQueue
	        hr := DXGI.DXGIGetDebugInterface1(0, DXGI.IInfoQueue_UUID, (^rawptr)(&info))
	        assert(hr == 0)
	        info->SetBreakOnSeverity(DXGI.DEBUG_ALL, .CORRUPTION, true)
	        info->SetBreakOnSeverity(DXGI.DEBUG_ALL, .ERROR, true)
	        info->Release()
	    }
	} else {
	    D3D11.CreateDeviceAndSwapChain(nil, .HARDWARE, nil, {.BGRA_SUPPORT},  &feature_levels[0], len(feature_levels), D3D11.SDK_VERSION, &swapchain_desc, &swapchain, &device, nil, &device_context)
	}

    swapchain->GetDesc(&swapchain_desc);

	swapchain->GetBuffer(0, D3D11.ITexture2D_UUID, (^rawptr)(&framebuffer))

	device->CreateRenderTargetView(framebuffer, nil, &framebuffer_view)

	setup_render_d3d11_common()
}

textures_srvs: [64]^D3D11.IShaderResourceView

draw_ui_primitives_d3d11 :: proc(primitives: []Primitive, window_width: f32, window_height: f32, render_to_texture := false) {
	using d3d11_context

	viewport = D3D11.VIEWPORT{ 0, 0, window_width, window_height, 0, 1 }

	mapped_subresource: D3D11.MAPPED_SUBRESOURCE
	device_context->Map(vertex_buffer, 0, .WRITE_DISCARD, {}, &mapped_subresource)

	screen_size: glm.vec2
	screen_size.x = f32(2.0 / cast(f64)window_width)
	screen_size.y = f32(-2.0 / cast(f64)window_height)

	vertex := cast([^]D3D11_Vertex)(mapped_subresource.pData)
	vertex[0] = { 
		idx = {0, 0},
		screen_size = screen_size,
	}
	vertex[1] = { 
		idx = {0, 1},
		screen_size = screen_size,
	}
	vertex[2] = { 
		idx = {1, 0},
		screen_size = screen_size,
	}
	vertex[3] = { 
		idx = {1, 1},
		screen_size = screen_size,
	}

	instance_qnt := 0
	textures_qnt := 0
	vertex_instance := cast([^]D3D11_UI_Primitive)(cast(uintptr)mapped_subresource.pData + cast(uintptr)size_of(D3D11_Vertex) * 4)

	for it in primitives {
		switch prim in it.u {
		case Primitive_Line:
			dx := prim.p0.x - prim.p1.x
			dy := prim.p0.y - prim.p1.y
			distance := math.sqrt(dx * dx + dy * dy) + 2
			angle := math.atan2(dy, dx) + math.PI

			vertex_instance[instance_qnt] = {}
			vertex_instance[instance_qnt].pos0 = {
				prim.p0.x,
				prim.p0.y - prim.thickness / 2,
			}
			vertex_instance[instance_qnt].pos1 = {
				prim.p0.x,
				prim.p0.y - prim.thickness / 2
			} + { distance, prim.thickness }
			vertex_instance[instance_qnt].roundness = 0
			vertex_instance[instance_qnt].softness = 1.5
			vertex_instance[instance_qnt].color0 = prim.colors[0]
			vertex_instance[instance_qnt].color1 = prim.colors[1]
			vertex_instance[instance_qnt].color2 = prim.colors[2]
			vertex_instance[instance_qnt].color3 = prim.colors[3]
			vertex_instance[instance_qnt].thickness = 9999
			vertex_instance[instance_qnt].angle = angle
			vertex_instance[instance_qnt].clip_vec = {
				cast(f32)(it.clip_rect.x),
				cast(f32)(it.clip_rect.y),
				cast(f32)(it.clip_rect.w + it.clip_rect.x),
				cast(f32)(it.clip_rect.h + it.clip_rect.y),
			}
			instance_qnt += 1
		case Primitive_Texture:
			vertex_instance[instance_qnt] = {}
			vertex_instance[instance_qnt].pos0 = { prim.bounds.x, prim.bounds.y }
			vertex_instance[instance_qnt].pos1 = { prim.bounds.x, prim.bounds.y } + { prim.bounds.w, prim.bounds.h }
			vertex_instance[instance_qnt].uv0 = [2]f32{0, 1}
			vertex_instance[instance_qnt].uv1 = [2]f32{1, 0}
			vertex_instance[instance_qnt].color0 = prim.colors[0]
			vertex_instance[instance_qnt].color1 = prim.colors[1]
			vertex_instance[instance_qnt].color2 = prim.colors[2]
			vertex_instance[instance_qnt].color3 = prim.colors[3]
			vertex_instance[instance_qnt].flags = 2
			vertex_instance[instance_qnt].texture_idx = cast(f32)textures_qnt
			vertex_instance[instance_qnt].clip_vec = {
				cast(f32)(it.clip_rect.x),
				cast(f32)(it.clip_rect.y),
				cast(f32)(it.clip_rect.w + it.clip_rect.x),
				cast(f32)(it.clip_rect.h + it.clip_rect.y),
			}

			textures_srvs[textures_qnt] = cast(^D3D11.IShaderResourceView)prim.handle
			instance_qnt += 1
			textures_qnt += 1
		case Primitive_Rect:
			vertex_instance[instance_qnt] = {}
			vertex_instance[instance_qnt].pos0 = { prim.bounds.x, prim.bounds.y }
			vertex_instance[instance_qnt].pos1 = { prim.bounds.x, prim.bounds.y } + { prim.bounds.w, prim.bounds.h }
			vertex_instance[instance_qnt].roundness = prim.roundness
			vertex_instance[instance_qnt].softness = prim.softness
			vertex_instance[instance_qnt].color0 = prim.colors[0]
			vertex_instance[instance_qnt].color1 = prim.colors[1]
			vertex_instance[instance_qnt].color2 = prim.colors[2]
			vertex_instance[instance_qnt].color3 = prim.colors[3]
			vertex_instance[instance_qnt].flags = 0
			vertex_instance[instance_qnt].thickness = prim.thickness < 0.001 ? 9999 : prim.thickness
			vertex_instance[instance_qnt].clip_vec = {
				cast(f32)(it.clip_rect.x),
				cast(f32)(it.clip_rect.y),
				cast(f32)(it.clip_rect.w + it.clip_rect.x),
				cast(f32)(it.clip_rect.h + it.clip_rect.y),
			}
			instance_qnt += 1
		case Primitive_Text:
			font := get_font(prim.size, prim.kind)

			metrics := font.metrics

			x := prim.pos.x
			y := prim.pos.y
			for r, idx in prim.text {
				quad: stbtt.aligned_quad
				stbtt.GetPackedQuad(raw_data(metrics[:]), FONT_ATLAS_WIDTH, FONT_ATLAS_HEIGHT, cast(i32)r - font.range_start, &x, &y, &quad, false)

				vertex_instance[instance_qnt] = {}
				vertex_instance[instance_qnt].pos0 = [2]f32{quad.x0, quad.y0 + font.y_offset}
				vertex_instance[instance_qnt].pos1 = [2]f32{quad.x1, quad.y1 + font.y_offset}
				vertex_instance[instance_qnt].uv0 = [2]f32{quad.s0, quad.t1}
				vertex_instance[instance_qnt].uv1 = [2]f32{quad.s1, quad.t0}
				vertex_instance[instance_qnt].color0 = prim.colors[0]
				vertex_instance[instance_qnt].color1 = prim.colors[1]
				vertex_instance[instance_qnt].color2 = prim.colors[2]
				vertex_instance[instance_qnt].color3 = prim.colors[3]
				vertex_instance[instance_qnt].flags = 1
				vertex_instance[instance_qnt].clip_vec = {
					cast(f32)(it.clip_rect.x),
					cast(f32)(it.clip_rect.y),
					cast(f32)(it.clip_rect.w + it.clip_rect.x),
					cast(f32)(it.clip_rect.h + it.clip_rect.y),
				}

				instance_qnt += 1
			}
		}
	}

	device_context->Unmap(vertex_buffer, 0)

	///////////////////////////////////////////////////////////////////////////////////////////////

	if render_to_texture {
		device_context->ClearRenderTargetView(render_texture_view, &[4]f32{0.0, 0.0, 0.0, 0.0})
	} else {		
		device_context->ClearRenderTargetView(framebuffer_view, &[4]f32{0.0, 0.0, 0.1, 1.0})
	} 

	device_context->IASetPrimitiveTopology(.TRIANGLESTRIP)
	device_context->IASetInputLayout(input_layout)
	vbuffers := [2]^D3D11.IBuffer{ vertex_buffer, vertex_buffer }
	vertex_buffer_stride := [2]u32{size_of(D3D11_Vertex), size_of(D3D11_UI_Primitive)}
	vertex_buffer_offset := [2]u32{0, 4 * size_of(D3D11_Vertex)}
	device_context->IASetVertexBuffers(0, 2, &vbuffers[0], &vertex_buffer_stride[0], &vertex_buffer_offset[0])

	device_context->VSSetShader(vertex_shader, nil, 0)

	device_context->RSSetViewports(1, &viewport)
	device_context->RSSetState(rasterizer_state)

	device_context->PSSetShader(pixel_shader, nil, 0)
	device_context->PSSetShaderResources(0, 1, &font_atlas_srv)

	if textures_qnt > 0 {
		device_context->PSSetShaderResources(1, cast(u32)textures_qnt, &textures_srvs[0])
	}

	device_context->PSSetSamplers(0, 1, &sampler_state)

	if render_to_texture {
		device_context->OMSetRenderTargets(1, &render_texture_view, nil)
	} else {
		device_context->OMSetRenderTargets(1, &framebuffer_view, nil)
	}

	device_context->OMSetBlendState(blend_state, nil, 0xffffffff)

	///////////////////////////////////////////////////////////////////////////////////////////////

	device_context->DrawInstanced(4, cast(u32)instance_qnt, 0, 0)

	if render_to_texture {
		device_context->Flush()
	} else {	
		swapchain->Present(1, {})
	}
}