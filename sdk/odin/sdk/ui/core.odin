package ui

import sa "core:container/small_array"
import "core:hash"
import "core:math"
import "core:fmt"
import "core:strings"
import "core:text/edit"
import "core:sort"
import "base:runtime"

c: ^Context

set_context :: proc(ref: ^Context) {
    c = ref
}

get_context :: proc() -> ^Context {
    return c
}

init_context :: proc(context_to_setup: ^Context, persistent_allocator: runtime.Allocator) {
    context_to_setup.persistent_allocator = persistent_allocator
    context_to_setup.control_rect_state_table = make(map[ID]Control_Rect_State, persistent_allocator)
    context_to_setup.animation_state_table = make(map[ID]Animation_State, persistent_allocator)
}

@(plugin_callable)
get_avaliable_space :: proc() -> [2]f32 {
    if c.layout_stack.len > 0 {
        layout := c.layout_stack.data[c.layout_stack.len - 1]
        avaliable_space := layout.get_avaliable_space_callback(layout.cnt, layout.buffered_containers[:])
        return avaliable_space
    }
    return {}
}

push_primitive :: proc(
    buffer: ^[dynamic]Primitive,
    _specific: $T,
) {
    specific := _specific

    transparency := get_transparency_value()
    specific.colors[0].a *= transparency 
    specific.colors[1].a *= transparency 
    specific.colors[2].a *= transparency 
    specific.colors[3].a *= transparency 

    primitive := Primitive{
        clip_rect = { c.clip_rect.x, c.clip_rect.y, c.clip_rect.w, c.clip_rect.h },
        u = specific,
        zindex = c.zindex,
    }

    append(buffer, primitive)
}

is_id_dragged :: proc(id: ID) -> b8 {
    for it in c.dragged_ids.data[0 : c.dragged_ids.len] {
        if id == it do return true
    }
    return false
}

push_transparency :: proc(value: f32) {
    sa.push_back(&c.transparency_values, value)
}

pop_transparency :: proc() {
    sa.pop_back(&c.transparency_values)
}

get_transparency_value :: proc() -> f32 {
    value := f32(1)
    for v in sa.slice(&c.transparency_values) {
        value *= v
    }
    return value
}

@(plugin_callable)
new_container :: proc() -> ^Container {
    cnt: Container

    cnt.animations = make([dynamic]Animation, c.frame_allocator)
    cnt.control_rects = make([dynamic]Control_Rect, c.frame_allocator)
    cnt.primitives = make([dynamic]Primitive, c.frame_allocator)
    cnt.children = make([dynamic]^Container, c.frame_allocator)
    
    reserve(&cnt.animations, 8)
    reserve(&cnt.control_rects, 8)
    reserve(&cnt.primitives, 8)

    append(&c.containers, cnt)

    ptr := &c.containers[len(c.containers) - 1]
    
    if c.layout_stack.len > 0 {
        append(&c.layout_stack.data[c.layout_stack.len - 1].buffered_containers, ptr)
    }

    ptr.children_clip_rect = DEFAULT_CLIP_RECT

    return ptr
}

merge_contexts :: proc(destination: ^Context, source: ^Context) {
    if destination.layout_stack.len > 0 {
        actual_c := get_context()
        set_context(source)
        root := end()
        set_context(actual_c)

        fix_zindex :: proc(destination: ^Context, container: ^Container) {
            for &p in container.primitives {
                p.zindex += destination.zindex + 1
            }

            for &control_rect in container.control_rects {
                control_rect.zindex += destination.zindex + 1
            }

            for child in container.children {
                fix_zindex(destination, child)
            }
        }

        fix_zindex(destination, root)

        append(&destination.layout_stack.data[destination.layout_stack.len - 1].buffered_containers, root)
    }
}

sync_contexts :: proc(destination: ^Context, source: ^Context) {
    destination.io = source.io
    destination.focused_id = source.focused_id
    destination.dragged_ids = source.dragged_ids 
}

hash_bytes :: proc(s: $T) -> ID {
    v := s
    bytes := (transmute([^]byte)&v)[0 : size_of(T)]
    crc := cast(u64)hash.crc32(bytes)
    fnv := cast(u64)hash.fnv32a(bytes)
    result := (crc << 32) | fnv
    return result
}

hash_with_id_stack :: proc(s: $T) -> ID {
    id := hash_bytes(s)
    hashed_stack := hash_bytes(c.id_stack)
    result := ((id + hashed_stack) * (id + hashed_stack + 1)) / 2 + hashed_stack
    return result
}

push_id :: proc(s: $T) {
    sa.push_back(&c.id_stack, hash_bytes(s))
}

@(plugin_callable)
pop_id :: proc() {
    sa.pop_back(&c.id_stack)
}

@(plugin_callable)
inc_zindex :: proc() {
    c.zindex += 1
}

@(plugin_callable)
dec_zindex :: proc() {
    c.zindex -= 1
}

@(plugin_callable)
get_control_rect :: proc(cnt: ^Container, bounds: Rect, name: string, flags: Control_Rect_Flags = {}) -> Control_Rect_State {
    id: ID = 0
    already_exists := false
    for &control_rect in cnt.control_rects {
        if control_rect.name == name {
            control_rect.flags = flags
            control_rect.bounds = bounds
            already_exists = true
            break
        }
    }

    if !already_exists {
        id = hash_with_id_stack(raw_data(name)[:len(name)])
        append(&cnt.control_rects, Control_Rect{ c = c, id = id, bounds = bounds, flags = flags, zindex = c.zindex, name = name })
    }

    state, found := c.control_rect_state_table[id]

    if !found {
        state = Control_Rect_State{}
    }

    state.focus       = c.focused_id == id
    state.drag_vector = state.hold ? c.io.mouse_change : {}
    state.drag        = state.drag_vector.x != 0 || state.drag_vector.y != 0
    state.id          = id

    return state
}

@(plugin_callable)
get_animation :: proc(
    cnt: ^Container,
    name: string,
    kind: Animation_Kind = .X,
    duration: f32 = 0.25,
    initial_value: union { f32, [2]f32, [3]f32, [4]f32 } = 0.0,
) -> ^Animation {
    for &animation, index in cnt.animations {
        if animation.name == name {
            return &cnt.animations[index]
        }
    }

    id := hash_with_id_stack(raw_data(name)[:len(name)])
    state, found := c.animation_state_table[id]

    if !found {
        switch v in initial_value {
        case f32:
            state.value = {v  , 0.0, 0.0, 0.0}
        case [2]f32:
            state.value = {v.x, v.y, 0.0, 0.0}
        case [3]f32:
            state.value = {v.x, v.y, v.z, 0.0}
        case [4]f32:
            state.value = v
        }
        state.duration = duration
    }

    append(&cnt.animations, Animation{
        c        = c,
        id       = id,
        target   = state.target,
        value    = state.value,
        name     = name,
        duration = state.duration,
        kind     = kind,
    })
    
    return &cnt.animations[len(cnt.animations) - 1]
}

push_layout :: proc(layout: Layout) {
    layout_to_add := layout
    layout_to_add.buffered_containers = make([dynamic]^Container, c.frame_allocator)
    sa.push_back(&c.layout_stack, layout_to_add)
}

pop_layout :: proc() -> ^Container {
    layout := sa.pop_back(&c.layout_stack)
    result := layout.end_callback(layout.cnt, layout.buffered_containers[:])

    return result
}

end :: pop_layout

begin_frame :: proc(frame_allocator: runtime.Allocator) {
    c.frame_allocator = frame_allocator

    c.containers = make([dynamic]Container, c.frame_allocator)
    c.primitive_buffer = make([dynamic]Primitive, c.frame_allocator)

    reserve(&c.containers, 1024)
    reserve(&c.primitive_buffer, 1024)

    c.clip_rect = DEFAULT_CLIP_RECT
    c.zindex = 0
    c.frame_counter += 1

    begin_manual_layout(c.io.viewport)
}

end_frame :: proc() {
    if !c.io.left_pressed {
        sa.clear(&c.dragged_ids)
    }

    focus_setted := false
    root := end()

    control_rects := make([dynamic]^Control_Rect, c.frame_allocator)
    get_control_rects_with_right_pos(root.children[:], { root.bounds.x, root.bounds.y }, &control_rects)

	z_sort_proc_cr :: proc(a: ^Control_Rect, b: ^Control_Rect) -> int {
		if a.zindex > b.zindex {
			return -1
		} else if a.zindex < b.zindex {
			return 1
		}
		return 0
	}
	sort.bubble_sort_proc(control_rects[:], z_sort_proc_cr)

    process_control_rects(&focus_setted, control_rects[:])
    process_animations_and_primitives(root.children[:], { root.bounds.x, root.bounds.y }, DEFAULT_CLIP_RECT, &focus_setted)

    if c.io.left_click && !focus_setted {
        c.focused_id = 0
    }

    z_sort_proc_primitive :: proc(a: Primitive, b: Primitive) -> int {
        if a.zindex > b.zindex {
            return 1
        } else if a.zindex < b.zindex {
            return -1
        }
        return 0
    }
    sort.bubble_sort_proc(c.primitive_buffer[:], z_sort_proc_primitive)
}

process_control_rects :: proc(
    focus_setted: ^bool,
    control_rects: []^Control_Rect,
) {
    disabled: b8 = false
    for control_rect in control_rects { 
        state, found := control_rect.c.control_rect_state_table[control_rect.id]

        bounds := control_rect.bounds

        is_new: b8 = false

        if !found {
            state = Control_Rect_State{}
            is_new = true
        }

        inside := is_mouse_inside(bounds)
        left_click := c.io.left_click
        left_pressed := c.io.left_pressed

        prev_state := state

        state.click        = cast(b8)(left_click && inside && !is_new && !disabled)
        state.hover        = cast(b8)inside
        state.hold         = is_id_dragged(control_rect.id)
        state.open         = state.click ? !state.open : state.open
        state.uptime       += c.io.delta_time
        state.release      = (prev_state.click || prev_state.hold) && !is_id_dragged(control_rect.id) && !is_new
        state.double_click = state.click && (state.uptime - state.last_click_uptime) <= DOUBLE_CLICK_TIME_LIMIT 

        if disabled {
            state = Control_Rect_State{}
        } 

        if state.click {
            fmt.println("clicked", control_rect.name)
        }

        if state.release {
            fmt.println("release", control_rect.name)
        }

        if state.click {
            sa.push_back(&c.dragged_ids, control_rect.id)
            state.last_click_uptime = state.uptime
        }

        state.last_bounds = bounds

        if state.click || state.hold {
            state.movable_marker_pos.x = (cast(f32)c.io.mouse_pos.x - cast(f32)bounds.x) / cast(f32)bounds.w
            state.movable_marker_pos.y = (cast(f32)c.io.mouse_pos.y - cast(f32)bounds.y) / cast(f32)bounds.h
            
            state.movable_marker_pos.x = clamp(state.movable_marker_pos.x, 0, 1)
            state.movable_marker_pos.y = clamp(state.movable_marker_pos.y, 0, 1)
        }

        if state.click && .Request_Focus in control_rect.flags {
            c.focused_id = control_rect.id
            focus_setted^ = true
        }

        if (state.click || state.hover) && .Dont_Passthrough in control_rect.flags {
            //TODO: Resolve this
            disabled = true
        }

        control_rect.c.control_rect_state_table[control_rect.id] = state
    }
}

get_control_rects_with_right_pos :: proc(
    containers: []^Container,
    father_pos: [2]f32,
    buffer: ^[dynamic]^Control_Rect,
) {
    for cnt in containers {
        for &control_rect in cnt.control_rects { 
            control_rect.bounds.x += cnt.x + father_pos.x
            control_rect.bounds.y += cnt.y + father_pos.y
            append(buffer, &control_rect)
        }       

        get_control_rects_with_right_pos(cnt.children[:], { cnt.bounds.x, cnt.bounds.y } + father_pos, buffer)
    }
}

process_animations_and_primitives :: proc(
    containers: []^Container,
    father_pos: [2]f32,
    father_clip_rect: Rect,
    focus_setted: ^bool,
) {
    for it in containers {
        /*children_clip_rect := cnt.children_clip_rect
        children_clip_rect.x = cnt.x + father_pos.x
        children_clip_rect.y = cnt.y + father_pos.y

        intersect, intersection := check_rect_overlap(father_clip_rect, children_clip_rect)

        if !intersect {
            continue
        }*/

        cnt := it^

        cnt.x += father_pos.x
        cnt.y += father_pos.y

        for primitive in cnt.primitives {
            p := primitive

            p.clip_rect.x += cnt.x
            p.clip_rect.y += cnt.y

            intersect, intersection := check_rect_overlap(father_clip_rect, p.clip_rect)

            if !intersect {
                continue
            }

            p.clip_rect = intersection

            switch &prim in p.u {
            case Primitive_Rect:
                prim.bounds.x += cnt.x
                prim.bounds.y += cnt.y
            case Primitive_Texture:
                prim.bounds.x += cnt.x
                prim.bounds.y += cnt.y
            case Primitive_Text:
                prim.pos.x += cnt.x
                prim.pos.y += cnt.y
            case Primitive_Line:
                prim.p0.x += cnt.x
                prim.p0.y += cnt.y
                prim.p1.x += cnt.x
                prim.p1.y += cnt.y
            }

            append(&c.primitive_buffer, p)
        }

        for animation in cnt.animations {
            speed_factor := 1.0 / (animation.duration + math.F32_EPSILON)

            switch animation.kind {
            case .X:
                new_value := math.lerp(animation.value.x, animation.target.x, 1 - math.pow(2.0, -4.0 * c.io.delta_time * speed_factor))
                animation.c.animation_state_table[animation.id] = Animation_State{ value = {new_value, 0, 0, 0}, target = animation.target.x, duration = animation.duration }
            case .Position:
            case .Color:            
                r := math.lerp(animation.value.r, animation.target.r, 1 - math.pow(2.0, -4.0 * c.io.delta_time * speed_factor))
                g := math.lerp(animation.value.g, animation.target.g, 1 - math.pow(2.0, -4.0 * c.io.delta_time * speed_factor))
                b := math.lerp(animation.value.b, animation.target.b, 1 - math.pow(2.0, -4.0 * c.io.delta_time * speed_factor))
                a := math.lerp(animation.value.a, animation.target.a, 1 - math.pow(2.0, -4.0 * c.io.delta_time * speed_factor))
                
                animation.c.animation_state_table[animation.id] = Animation_State{ value = {r, g, b, a}, target = animation.target.x, duration = animation.duration }
            } 
        }

        c_rect := cnt.children_clip_rect
        c_rect.x += cnt.x
        c_rect.y += cnt.y

        intersect, intersection := check_rect_overlap(father_clip_rect, c_rect)

        process_animations_and_primitives(
            cnt.children[:],
            { cnt.bounds.x, cnt.bounds.y },
            intersection,
            focus_setted,
        )
    }
}