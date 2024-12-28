package jam

import rl "vendor:raylib"

draw_text_debug :: proc(o: Outline, text: cstring, position: rl.Vector2) -> rl.Vector2 {
	font := o.fonts.debug
	measure := rl.MeasureTextEx(font, text, f32(font.baseSize), 1.0)
	rl.DrawTextEx(font, text, position, f32(font.baseSize), 1.0, rl.WHITE)
	return measure
}
