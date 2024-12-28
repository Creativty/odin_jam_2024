package jam

import math "core:math"
import la "core:math/linalg"
import rl "vendor:raylib"

Champion :: struct {
	size: f32,
	target: [2]f32,
	position: [2]f32,
	speed_base: f32,
	speed_modifier: f32,
	speed_modifier_millis: f32,
	magnitude_flash: f32,
}

make_champion :: proc() -> Champion {
	c: Champion
	c.size = SCREEN / 48
	c.position = SCREEN / 2
	c.speed_base = SCREEN / 48 * 10
	c.target = c.position
	c.speed_modifier = 1
	c.speed_modifier_millis = 0.0
	c.magnitude_flash = c.size * 4

	return c
}

draw_champion :: proc(c: Champion) {
	using rl

	rec := Rectangle {
		x = c.position.x,
		y = c.position.y,
		width = c.size * 2,
		height = c.size * 2,
	}
	rot_vec := la.normalize(c.position - c.target)
	rot_rad := math.atan2(rot_vec.y, rot_vec.x)
	rot_deg := rot_rad * 180 / math.PI
	DrawRectangle(i32(c.target.x), i32(c.target.y), i32(c.size / 2), i32(c.size / 2), C_LIME)
	DrawRectanglePro(rec, c.size, rot_deg, C_RED)
	// DrawCircle(i32(c.position.x), i32(c.position.y), c.size, C_RED)
}

update_champion :: proc(c: ^Champion, dt: f32) {
	using rl

	mouse := GetMousePosition()
	if IsMouseButtonPressed(.RIGHT) do c.target = mouse
	if IsKeyPressed(.F) { // Flash
		c.position += la.normalize(mouse - c.position) * c.magnitude_flash
	} else {
		epsilon := c.size / 4
		if la.distance(c.position, c.target) > epsilon {
			c.position += la.normalize(c.target - c.position) * (c.speed_base * c.speed_modifier) * dt
		}
	}
}
