package jam

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

hit_test_projectile :: proc(p: Projectile, c: Champion) -> bool {
	rect := rl.Rectangle {
		x = c.position.x,
		y = c.position.y,
		width = c.size * 2,
		height = c.size * 2,
	}
	rot_vec := la.normalize(c.position - c.target)
	rot_rad := math.atan2(rot_vec.y, rot_vec.x)
	rot_deg := rot_rad * 180 / math.PI

	x_flat := math.cos(rot_deg) * (p.position.x - c.position.x) - math.sin(rot_deg) * (p.position.y - c.position.y) + c.position.x
	y_flat := math.sin(rot_deg) * (p.position.x - c.position.x) + math.cos(rot_deg) * (p.position.y - c.position.y) + c.position.y

	x_close: f32
	if x_flat < rect.x do x_close = rect.x
	else if x_flat > rect.x + rect.width do x_close = rect.x + rect.width
	else do x_close = x_flat

	y_close: f32
	if y_flat < rect.y do y_close = rect.y
	else if y_flat > rect.y + rect.height do y_close = rect.y + rect.height
	else do y_close = y_flat

	return la.distance([2]f32{ x_close, y_close }, [2]f32{ x_flat, y_flat }) <= p.base_size
}
