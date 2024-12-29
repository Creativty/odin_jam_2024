package jam

import "core:fmt"
import "core:math"
import la "core:math/linalg"
import rl "vendor:raylib"

Projectile_Shape :: enum {
	Circle,
	Rectangle,
}

Projectile :: struct {
	shape: Projectile_Shape,
	base_size: f32,
	base_speed: f32,
	position, target: [2]f32,
	do_delete: bool,
}

make_projectile :: proc(position, target: [2]f32) -> Projectile {
	p: Projectile
	p.target = target
	p.position = position
	p.base_size = 8
	p.base_speed = p.base_size * 50
	return p
}

update_projectile :: proc(p: ^Projectile, dt: f32) {
	epsilon := p.base_size / 4
	if la.distance(p.position, p.target) > epsilon {
		p.position += la.normalize(p.target - p.position) * p.base_speed * dt
	} else {
		p.do_delete = true
	}
}

draw_projectile :: proc(p: Projectile) {
	using rl

	if p.do_delete do return
	DrawCircle(i32(p.position.x), i32(p.position.y), p.base_size, C_ORANGE)
}

proj_close, proj_flat, proj_orig: [2]f32

angle_radians :: proc(origin: [2]f32, point: [2]f32) -> f32 {
	vec_unit := la.normalize0(point - origin)
	return math.atan2(vec_unit.y, vec_unit.x)
}

hit_test_projectile :: proc(p: Projectile, c: Champion) -> bool {
	rect := rl.Rectangle{
		x = c.position.x - c.size,
		y = c.position.y - c.size,
		width = c.size * 2,
		height = c.size * 2,
	}

	rot_rad := angle_radians(c.position, c.target)

	x_orig := (rect.x + rect.width  / 2)
	y_orig := (rect.y + rect.height / 2)
	proj_orig = [2]f32{ x_orig, y_orig }

	x_flat := math.cos(rot_rad) * (p.position.x - x_orig) - math.sin(rot_rad) * (p.position.y - y_orig) + x_orig
	y_flat := math.sin(rot_rad) * (p.position.x - x_orig) + math.cos(rot_rad) * (p.position.y - y_orig) + y_orig
	proj_flat = [2]f32{ x_flat, y_flat }

	x_close: f32
	if x_flat < rect.x do x_close = rect.x
	else if x_flat > rect.x + rect.width do x_close = rect.x + rect.width
	else do x_close = x_flat

	y_close: f32
	if y_flat < rect.y do y_close = rect.y
	else if y_flat > rect.y + rect.height do y_close = rect.y + rect.height
	else do y_close = y_flat

	proj_close = [2]f32{ x_close, y_close }
	dist := la.distance([2]f32{ x_close, y_close }, [2]f32{ x_flat, y_flat })
	return dist <= p.base_size
}
