package ui

import "core:math"
import "core:fmt"

@(plugin_callable)
cubic_bezier :: proc(
    p0, p1, p2, p3: [2]f32,
    color: [4]f32,
    loc := #caller_location,
) -> ^Container {
    cnt := new_container()
    //cnt.bounds = bounds

    push_id(loc)

    pulse_animation := get_animation(cnt, "pulse")
    pulse_animation.target.x = 1.5
    pulse_animation.duration = 0.4
    if pulse_animation.value.x > (pulse_animation.target.x - 0.05) {
        pulse_animation.value.x = -0.5
    }

    Point :: struct {
        p: [2]f32,
        lightness: f32,
    }

    points := make([dynamic]Point)

    for t: f32 = 0.0; t <= 1.0; t += 0.01 {
        a := math.lerp(p0, p1, t)
        b := math.lerp(p1, p2, t)
        c := math.lerp(p2, p3, t)
        d := math.lerp(a, b, t)
        e := math.lerp(b, c, t)
        p := math.lerp(d, e, t)
        //distance := math.abs(t - pulse_animation.value)
        //inv_distance := 1.0 - distance
        //lightness := math.pow(inv_distance, 15) * 7 + 1
        //append(&points, Point{ p, lightness })
        append(&points, Point{ p, 1.0 })
    }

    for i := 1; i < len(points); i += 1 {
        push_primitive(&c.primitive_buffer, Primitive_Line{
            p0 = points[i - 1].p,
            p1 = points[i].p,
            thickness = 6,
            colors = small_v_gradient(set_lightness(color, points[i].lightness)),
        })
    }

    pop_id()

    return cnt
}