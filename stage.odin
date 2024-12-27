package jam

Stage :: struct {
	draw: #type proc(scenario: Outline),
	update: #type proc(scenario: ^Outline, dt: f32),
	on_enter: Maybe(proc(scenario: ^Outline)),
	on_leave: Maybe(proc(scenario: ^Outline)),
	data: union {
		Stage_Menu,
		Stage_Play,
	}
}

Stage_Kind :: enum {
	Splash,
	Menu,
	Play,
}
