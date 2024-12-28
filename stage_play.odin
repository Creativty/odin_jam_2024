package jam

import "core:fmt"
import rl "vendor:raylib"

DURATION_TIMEOUT :: 3
COUNT_PAUSE_OPTIONS :: 2

Play_State :: enum {
	Pause,
	Timeout,
	In_Game,
}

Stage_Play :: struct {
	score: int,
	state: Play_State,
	champion: Champion,
	projectiles: [dynamic]Projectile,
	pause_option: int,
	timeout_elapsed: f32,
}

update_pause :: proc(o: ^Outline, data: ^Stage_Play) {
	if rl.IsKeyPressed(.ESCAPE) || (rl.IsKeyPressed(.ENTER) && data.pause_option == 0) {
		data.state = .Timeout
		return
	} else if rl.IsKeyPressed(.ENTER) && data.pause_option == 1 {
		transition_outline(o, .Menu)
		return
	}
	if rl.IsKeyPressed(.UP) do data.pause_option += 1
	if rl.IsKeyPressed(.DOWN) do data.pause_option -= 1
	if data.pause_option >= COUNT_PAUSE_OPTIONS do data.pause_option = 0
	if data.pause_option < 0 do data.pause_option = COUNT_PAUSE_OPTIONS - 1
}

update_timeout :: proc(o: ^Outline, data: ^Stage_Play, dt: f32) {
	if data.timeout_elapsed > DURATION_TIMEOUT {
		data.state = .In_Game
		data.timeout_elapsed = 0
		return
	}
	data.timeout_elapsed += dt
}

update_in_game :: proc(o: ^Outline, data: ^Stage_Play, dt: f32) {
	if rl.IsKeyPressed(.ESCAPE) {
		data.pause_option = 0
		data.state = .Pause
		return
	}
	update_champion(&data.champion, dt)
}

draw_pause :: proc(o: Outline, data: Stage_Play) {
	font_pause := o.fonts.title.xl
	font_option := o.fonts.option

	text_pause : cstring = "PAUSED"
	text_resume : cstring = "Resume"
	text_quit : cstring = "Back to menu"

	measure_pause := rl.MeasureTextEx(font_pause, text_pause, f32(font_pause.baseSize), 1.0)
	measure_resume := rl.MeasureTextEx(font_option, text_resume, f32(font_option.baseSize), 1.0)
	measure_quit := rl.MeasureTextEx(font_option, text_quit, f32(font_option.baseSize), 1.0)

	position_pause := rl.Vector2{ (SCREEN - measure_pause.x) / 2, (SCREEN - measure_pause.y) / 2 - 128 }
	position_resume := rl.Vector2{ (SCREEN - measure_resume.x) / 2, (SCREEN - measure_resume.y) / 2 + 48 }
	position_quit := rl.Vector2{ (SCREEN - measure_quit.x) / 2, (SCREEN - measure_quit.y) / 2 + 128 }

	color_resume := rl.WHITE if data.pause_option == 0 else rl.GRAY
	color_quit := rl.WHITE if data.pause_option == 1 else rl.GRAY

	rl.DrawTextEx(font_pause, text_pause, position_pause, f32(font_pause.baseSize), 1.0, rl.WHITE)
	rl.DrawTextEx(font_option, text_resume, position_resume, f32(font_option.baseSize), 1.0, color_resume)
	rl.DrawTextEx(font_option, text_quit, position_quit, f32(font_option.baseSize), 1.0, color_quit)
}

draw_timeout :: proc(o: Outline, data: Stage_Play) {
	font := o.fonts.title.md
	text := fmt.caprintf("Prepare to start in %d...", int(DURATION_TIMEOUT - data.timeout_elapsed))
	defer delete(text)
	measure := rl.MeasureTextEx(font, text, f32(font.baseSize), 1.0)
	position := rl.Vector2{ (SCREEN - measure.x) / 2, (SCREEN - measure.y) / 2 }
	rl.DrawTextEx(font, text, position, f32(font.baseSize), 1.0, { 0xff, 0xff, 0xff, u8(0xff * (DURATION_TIMEOUT - data.timeout_elapsed))})
}

make_stage_play :: proc() -> Stage {
	stage: Stage
	stage.data = Stage_Play{
		state = .Timeout,
		champion = make_champion(),
		timeout_elapsed = 0,
	}
	stage.update = proc(o: ^Outline, dt: f32) {
		data := &o.stages[.Play].data.(Stage_Play)
		#partial switch (data.state) {
		case .Pause:
			update_pause(o, data)
		case .In_Game:
			update_in_game(o, data, dt)
		case .Timeout:
			update_timeout(o, data, dt)
		}
	}
	stage.draw = proc(o: Outline) {
		data := o.stages[.Play].data.(Stage_Play)
		#partial switch (data.state) {
		case .Pause:
			draw_pause(o, data)
		case .In_Game:
			draw_champion(data.champion)
		case .Timeout:
			draw_timeout(o, data)
		}
	}
	return stage
}
