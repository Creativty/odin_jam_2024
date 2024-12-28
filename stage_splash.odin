package jam

import rl "vendor:raylib"

DURATION_SPLASH :: 1.2

make_stage_splash :: proc() -> Stage {
	stage: Stage
	stage.draw = proc(scenario: Outline) {
		text_jam: cstring : "Odin Holiday Jam"
		text_made: cstring : "Made by XENOBAS for"

		font_jam := scenario.fonts.title.lg
		font_made := scenario.fonts.title.md

		measure_jam := rl.MeasureTextEx(font_jam, text_jam, f32(font_jam.baseSize), 1.0)
		measure_made := rl.MeasureTextEx(font_made, text_made, f32(font_made.baseSize), 1.0)

		position_jam := rl.Vector2{ (SCREEN - measure_jam.x) / 2, (SCREEN - measure_jam.y) / 2 }
		position_made := rl.Vector2{ (SCREEN - measure_made.x) / 2, (SCREEN - measure_made.y) / 2 - f32(font_made.baseSize) * 2 }

		rl.ClearBackground({ 0xb9, 0x4d, 0x50, 0xff })
		rl.DrawTextEx(font_jam, text_jam, position_jam, f32(font_jam.baseSize), 1.0, rl.WHITE)
		rl.DrawTextEx(font_made, text_made, position_made, f32(font_made.baseSize), 1.0, rl.WHITE)
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
