package jam

import "core:fmt"
import "core:math"
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

	rot_rad := angle_radians(c.position, c.target)
	rot_deg := math.to_degrees(rot_rad)

	rec_target := Rectangle{
		x = c.target.x,
		y = c.target.y,
		width = c.size,
		height = c.size,
	}
	DrawRectanglePro(rec_target, c.size / 2, rot_deg, C_LIME) // TODO(XENOBAS): Replace with particles

	rec_champion := Rectangle {
		x = c.position.x,
		y = c.position.y,
		width = c.size * 2,
		height = c.size * 2,
	}
	DrawRectanglePro(rec_champion, c.size, rot_deg, rl.WHITE)
}

update_champion :: proc(c: ^Champion, dt: f32) {
	using rl

	mouse := GetMousePosition()
	epsilon := c.size / 4
	if IsMouseButtonPressed(.RIGHT) do c.target = mouse
	if la.distance(c.position, c.target) > epsilon {
		c.position += la.normalize(c.target - c.position) * (c.speed_base * c.speed_modifier) * dt
	}
}
