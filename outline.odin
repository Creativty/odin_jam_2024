package jam

import rl "vendor:raylib"

Stage_Transition :: struct {
	intensity: f32,
	is_active: bool,
	next_stage: Stage_Kind,
}

Outline :: struct {
	fonts: Fonts,
	stages: [Stage_Kind]Stage,
	stage_index: Stage_Kind,
	transition: Stage_Transition,
	is_running: bool,
}

make_outline :: proc(fonts: Fonts) -> Outline {
	s: Outline
	s.fonts = fonts
	s.stage_index = .Splash
	s.stages[.Play] = make_stage_play()
	s.stages[.Menu] = make_stage_menu()
	s.stages[.Splash] = make_stage_splash()
	s.is_running = true
	return s
}

draw_transition :: proc(outline: Outline) {
	using rl

	DrawRectangle(0, 0, SCREEN, SCREEN, { C_DARK.r, C_DARK.g, C_DARK.b, u8(255 * outline.transition.intensity) })
}

update_transition :: proc(outline: ^Outline, dt: f32) {
	outline.transition.intensity += dt * 2
	if outline.transition.is_active {
		if outline.transition.intensity >= 1 {
			outline.stage_index = outline.transition.next_stage
			outline.transition.intensity = 0
			outline.transition.is_active = false
		}
	}
}

update_outline :: proc(outline: ^Outline, dt: f32) {
	if outline.transition.is_active  {
		update_transition(outline, dt)
	} else {
		if outline.stages[outline.stage_index].update != nil {
			outline.stages[outline.stage_index].update(outline, dt)
		}
	}
	outline.is_running = outline.is_running && !rl.WindowShouldClose()
}

transition_outline :: proc(outline: ^Outline, next: Stage_Kind) {
	assert(outline.stage_index != next, "why are you trying a transition to the same scene ?!?")
	outline.transition.intensity = 0
	outline.transition.is_active = true
	outline.transition.next_stage = next
}

draw_outline :: proc(outline: Outline) {
	if outline.stages[outline.stage_index].update != nil {
		outline.stages[outline.stage_index].draw(outline)
	}
	if outline.transition.is_active do draw_transition(outline)
}
