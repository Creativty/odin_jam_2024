package jam

import "core:fmt"
import rl "vendor:raylib"

Play_State :: enum {
	Pause,
	Timeout,
	In_Game,
}

Stage_Play :: struct {
	state: Play_State,
	champion: Champion,
	timeout_elapsed: f32,
}

DURATION_TIMEOUT :: 3

make_stage_play :: proc() -> Stage {
	stage: Stage
	stage.update = proc(o: ^Outline, dt: f32) {
		data := &o.stages[.Play].data.(Stage_Play)
		#partial switch (data.state) {
		case .In_Game:
			update_champion(&data.champion, dt)
		case .Timeout:
			data.timeout_elapsed += dt
			if data.timeout_elapsed > DURATION_TIMEOUT {
				data.state = .In_Game
				data.timeout_elapsed = 0
			}
		}
	}
	stage.draw = proc(o: Outline) {
		data := o.stages[.Play].data.(Stage_Play)
		#partial switch (data.state) {
		case .In_Game:
			draw_champion(data.champion)
		case .Timeout:
			font := o.fonts.title.md
			text := fmt.caprintf("Starting in %d...", int(DURATION_TIMEOUT - data.timeout_elapsed))
			defer delete(text)
			measure := rl.MeasureTextEx(font, text, f32(font.baseSize), 1.0)
			position := rl.Vector2{ (SCREEN - measure.x) / 2, (SCREEN - measure.y) / 2 }
			rl.DrawTextEx(font, text, position, f32(font.baseSize), 1.0, { 0xff, 0xff, 0xff, u8(0xff * (DURATION_TIMEOUT - data.timeout_elapsed))})
		}
	}
	stage.data = Stage_Play{
		state = .Timeout,
		champion = make_champion(),
		timeout_elapsed = 0,
	}
	return stage
}
