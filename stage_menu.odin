package jam

import "core:fmt"
import rl "vendor:raylib"

Stage_Menu :: struct {
	option_index: int,
}

make_stage_menu :: proc() -> Stage {
	stage: Stage
	stage.draw = proc(o: Outline) {
		font_tip := o.fonts.tip
		font_title := o.fonts.title.xl
		font_option := o.fonts.option

		text_play: cstring = "Play"
		text_exit: cstring = "Exit"
		text_info: cstring = "TIP: Arrow keys to select menu options and Enter to choose"
		text_title: cstring = "DODGE LEGENDS"

		color_title := rl.Color{ 0xc8, 0x9b, 0x3c, 0xff }
		color_option_active := rl.Color{ 0xf0, 0xe6, 0xd2, 0xff }
		color_option_inactive := rl.Color{ 0xb5, 0xb3, 0xae, 0xff }

		position_title := rl.Vector2{ 32, 72 }
		rl.DrawTextEx(font_title, text_title, position_title, f32(font_title.baseSize), 1.0, color_title)

		measure_info := rl.MeasureTextEx(font_tip, text_info, f32(font_tip.baseSize), 1.0)
		measure_play := rl.MeasureTextEx(font_option, text_play, f32(font_option.baseSize), 1.0)
		measure_exit := rl.MeasureTextEx(font_option, text_exit, f32(font_option.baseSize), 1.0)

		position_info := rl.Vector2{ 32, (SCREEN - measure_info.y - 16) }
		position_play := rl.Vector2{ (SCREEN - measure_play.x) / 2, (SCREEN - measure_play.y) / 2 - f32(font_option.baseSize / 3 * 2) }
		position_exit := rl.Vector2{ (SCREEN - measure_exit.x) / 2, (SCREEN - measure_exit.y) / 2 + f32(font_option.baseSize / 3 * 2) }

		rl.DrawTextEx(font_tip, text_info, position_info, f32(font_tip.baseSize), 1.0, color_option_inactive)
		rl.DrawTextEx(font_option, text_play, position_play, f32(font_option.baseSize), 1.0, color_option_active if o.stages[.Menu].data.(Stage_Menu).option_index == 0 else color_option_inactive)
		rl.DrawTextEx(font_option, text_exit, position_exit, f32(font_option.baseSize), 1.0, color_option_active if o.stages[.Menu].data.(Stage_Menu).option_index == 1 else color_option_inactive)
	}
	stage.update = proc(outline: ^Outline, dt: f32) {
		data := &outline.stages[.Menu].data.(Stage_Menu)
		option_count := 2
		if rl.IsKeyPressed(.DOWN) {
			data.option_index = (data.option_index + 1) % option_count
		} else if rl.IsKeyPressed(.UP) {
			data.option_index = (data.option_index - 1)
			if data.option_index < 0 do data.option_index = option_count - 1
		} else if rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.SPACE) {
			switch data.option_index {
			case 0:
				transition_outline(outline, .Play)
			case 1:
				outline.is_running = false
			}
		}
	}
	stage.on_enter = proc(o: ^Outline) {
	}
	stage.on_leave = proc(o: ^Outline) {
	}
	stage.data = Stage_Menu{
		option_index = 0,
	}
	return stage
}
