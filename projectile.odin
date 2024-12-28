package jam

Projectile_Shape :: enum {
	Circle,
	Rectangle,
}

Projectile :: struct {
	shape: Projectile_Shape,
	base_size: f32,
	base_speed: f32,
	position, target: [2]f32,
}

make_projectile :: proc() -> Projectile {
	p: Projectile
	return p
}

update_projectile :: proc(p: ^Projectile, dt: f32) {
}

draw_projectile :: proc(p: Projectile) {
}
