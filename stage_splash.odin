package jam

import rl "vendor:raylib"

DURATION_SPLASH :: 1.2

make_stage_splash :: proc() -> Stage {
	stage: Stage
	stage.draw = proc(scenario: Outline) {
		text: cstring : "Odin Holiday Jam"
		font := scenario.fonts.title.lg
		font_size := f32(font.baseSize)
		dims := rl.MeasureTextEx(font, text, font_size, 1.0)
		position := rl.Vector2{ (SCREEN - dims.x) / 2, (SCREEN - dims.y) / 2 }
		rl.ClearBackground({ 0xb9, 0x4d, 0x50, 0xff })
		rl.DrawTextEx(font, text, position, font_size, 1.0, rl.WHITE)
	}
	stage.update = proc(outline: ^Outline, dt: f32) {
		if (rl.GetTime() > DURATION_SPLASH) {
			transition_outline(outline, .Menu)
			return
		}
	}
	stage.on_enter = proc(scenario: ^Outline) {
	}
	stage.on_leave = proc(scenario: ^Outline) {
	}
	stage.data = nil
	return stage
}
