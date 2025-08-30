#+build windows

package render

import win "core:sys/windows"
import D3D11 "vendor:directx/d3d11"
import DXGI "vendor:directx/dxgi"
import D3D "vendor:directx/d3d_compiler"
import SDL "vendor:sdl2"
import glm "core:math/linalg/glsl"
import "core:fmt"
import stbtt "vendor:stb/truetype"
import "core:math"
import "core:mem"

Texture_Handle :: ^D3D11.IShaderResourceView
Shared_Texture_Handle :: win.HANDLE

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
    viewport:             D3D11.VIEWPORT,
}

Vertex :: struct #align(16) {
	idx: glm.vec2,
	screen_size: glm.vec2,			
}

d3d11_context: D3D11_Context

translate_format_to_d3d11 :: proc(format: Texture_Format) -> DXGI.FORMAT {
	switch format {
	case .RGBA:
		return .R8G8B8A8_UNORM
	case .R:
		return .R8_UNORM
	}
	return .R8G8B8A8_UNORM
}

get_pixel_size :: proc(format: Texture_Format) -> int {
	switch format {
	case .RGBA:
		return 4
	case .R:
		return 1
	}
	return 4
}

load_shared_texture :: proc(
	handle: Shared_Texture_Handle,
	format: Texture_Format,
) -> Texture_Handle {
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

load_texture :: proc(
	pixels: []byte,
	width: int,
	height: int,
	format: Texture_Format,
	allocator := context.allocator,
) -> Texture_Handle {
	using d3d11_context

	tex_data := transmute([][4]byte)pixels

	if format == .R {
		tex_data = make([][4]byte, len(pixels))
		for &p, i in tex_data {
			p[0] = 255
			p[1] = 255
			p[2] = 255
			p[3] = pixels[i]
		}
	}
	
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
    tex_srd.pSysMem     = raw_data(tex_data)
    tex_srd.SysMemPitch = cast(u32)(width * size_of([4]byte))

    tex: ^D3D11.ITexture2D
    device->CreateTexture2D(&tex_desc, &tex_srd, &tex)

	tex_srv: ^D3D11.IShaderResourceView

    tex_srv_desc := D3D11.SHADER_RESOURCE_VIEW_DESC{}
    tex_srv_desc.Format = .R8G8B8A8_UNORM
    tex_srv_desc.ViewDimension = .TEXTURE2D
    tex_srv_desc.Texture2D.MipLevels = 1

    device->CreateShaderResourceView(tex, &tex_srv_desc, &tex_srv)

    if format == .R {
		free(&tex_data[0])
	}

	return tex_srv
}

setup_d3d11_common :: proc() {
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
		{ "INDEX"     , 0, .R32G32_FLOAT, 0, cast(u32)offset_of(Vertex, idx)        , .VERTEX_DATA, 0 },
		{ "SCREENSIZE", 0, .R32G32_FLOAT, 0, cast(u32)offset_of(Vertex, screen_size), .VERTEX_DATA, 0 },
		
		{ "POS"  , 0, .R32G32_FLOAT      , 1, cast(u32)offset_of(Primitive, pos0)       , .INSTANCE_DATA, 1 },
		{ "POS"  , 1, .R32G32_FLOAT      , 1, cast(u32)offset_of(Primitive, pos1)       , .INSTANCE_DATA, 1 },
		{ "UV"   , 0, .R32G32_FLOAT      , 1, cast(u32)offset_of(Primitive, uv0)        , .INSTANCE_DATA, 1 },
		{ "UV"   , 1, .R32G32_FLOAT      , 1, cast(u32)offset_of(Primitive, uv1)        , .INSTANCE_DATA, 1 },
		{ "PARAM", 0, .R32_FLOAT         , 1, cast(u32)offset_of(Primitive, roundness)  , .INSTANCE_DATA, 1 },
		{ "PARAM", 1, .R32_FLOAT         , 1, cast(u32)offset_of(Primitive, softness)   , .INSTANCE_DATA, 1 },
		{ "PARAM", 2, .R32_FLOAT         , 1, cast(u32)offset_of(Primitive, flags)      , .INSTANCE_DATA, 1 },
		{ "PARAM", 3, .R32_FLOAT         , 1, cast(u32)offset_of(Primitive, texture_idx), .INSTANCE_DATA, 1 },
		{ "COLOR", 0, .R32G32B32A32_FLOAT, 1, cast(u32)offset_of(Primitive, color0)     , .INSTANCE_DATA, 1 },
		{ "COLOR", 1, .R32G32B32A32_FLOAT, 1, cast(u32)offset_of(Primitive, color1)     , .INSTANCE_DATA, 1 },
		{ "COLOR", 2, .R32G32B32A32_FLOAT, 1, cast(u32)offset_of(Primitive, color2)     , .INSTANCE_DATA, 1 },
		{ "COLOR", 3, .R32G32B32A32_FLOAT, 1, cast(u32)offset_of(Primitive, color3)     , .INSTANCE_DATA, 1 },
		{ "PARAM", 4, .R32_FLOAT         , 1, cast(u32)offset_of(Primitive, thickness)  , .INSTANCE_DATA, 1 },
		{ "RECT" , 0, .R32G32B32A32_FLOAT, 1, cast(u32)offset_of(Primitive, clip_vec)   , .INSTANCE_DATA, 1 },
		{ "ANGLE", 0, .R32_FLOAT         , 1, cast(u32)offset_of(Primitive, angle)      , .INSTANCE_DATA, 1 },
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

	vertex_buffer_desc := D3D11.BUFFER_DESC{
		ByteWidth      = size_of(Vertex) * 4 + size_of(Primitive) * 1024 * 16,
		Usage          = .DYNAMIC,
		BindFlags      = {.VERTEX_BUFFER},
		CPUAccessFlags = {.WRITE},
	}
	device->CreateBuffer(&vertex_buffer_desc, nil, &vertex_buffer)
}

setup_headless :: proc(width: f32, height: f32) -> Shared_Texture_Handle {
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

	setup_d3d11_common()

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

setup :: proc(native_window: DXGI.HWND) {
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

	setup_d3d11_common()
}

draw_primitives :: proc(
	primitives: []Primitive,
	textures: []Texture_Handle,
	window_width: f32,
	window_height: f32,
	headless := false,
) {
	using d3d11_context

	viewport = D3D11.VIEWPORT{ 0, 0, window_width, window_height, 0, 1 }

	mapped_subresource: D3D11.MAPPED_SUBRESOURCE
	device_context->Map(vertex_buffer, 0, .WRITE_DISCARD, {}, &mapped_subresource)

	screen_size: glm.vec2
	screen_size.x = f32(2.0 / cast(f64)window_width)
	screen_size.y = f32(-2.0 / cast(f64)window_height)

	vertex := cast([^]Vertex)(mapped_subresource.pData)
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

	vertex_instance := cast([^]Primitive)(cast(uintptr)mapped_subresource.pData + cast(uintptr)size_of(Vertex) * 4)

	mem.copy(vertex_instance, &primitives[0], len(primitives) * size_of(Primitive))

	device_context->Unmap(vertex_buffer, 0)

	///////////////////////////////////////////////////////////////////////////////////////////////

	if headless {
		device_context->ClearRenderTargetView(render_texture_view, &[4]f32{0.0, 0.0, 0.0, 0.0})
	} else {		
		device_context->ClearRenderTargetView(framebuffer_view, &[4]f32{0.0, 0.0, 0.1, 1.0})
	} 

	device_context->IASetPrimitiveTopology(.TRIANGLESTRIP)
	device_context->IASetInputLayout(input_layout)
	vbuffers := [2]^D3D11.IBuffer{ vertex_buffer, vertex_buffer }
	vertex_buffer_stride := [2]u32{size_of(Vertex), size_of(Primitive)}
	vertex_buffer_offset := [2]u32{0, 4 * size_of(Vertex)}
	device_context->IASetVertexBuffers(0, 2, &vbuffers[0], &vertex_buffer_stride[0], &vertex_buffer_offset[0])

	device_context->VSSetShader(vertex_shader, nil, 0)

	device_context->RSSetViewports(1, &viewport)
	device_context->RSSetState(rasterizer_state)

	device_context->PSSetShader(pixel_shader, nil, 0)
	device_context->PSSetShaderResources(0, cast(u32)len(textures), &textures[0])
	device_context->PSSetSamplers(0, 1, &sampler_state)

	if headless {
		device_context->OMSetRenderTargets(1, &render_texture_view, nil)
	} else {
		device_context->OMSetRenderTargets(1, &framebuffer_view, nil)
	}

	device_context->OMSetBlendState(blend_state, nil, 0xffffffff)

	///////////////////////////////////////////////////////////////////////////////////////////////

	device_context->DrawInstanced(4, cast(u32)len(primitives), 0, 0)

	if headless {
		device_context->Flush()
	} else {	
		swapchain->Present(1, {})
	}
}