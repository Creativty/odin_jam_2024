package jam

import "core:fmt"
import "core:time"
import "core:math/rand"
import rl "vendor:raylib"

main :: proc() {
	rl.SetTraceLogLevel(.WARNING)
	rl.SetTargetFPS(120)
	rl.SetConfigFlags({ .MSAA_4X_HINT })

	rl.InitWindow(SCREEN, SCREEN, "DODGE")
	defer rl.CloseWindow()

	fonts := load_fonts()
	defer unload_fonts(fonts)

	rl.SetExitKey(.KEY_NULL)

	seed := time.now()
	rand.reset(u64(seed._nsec))

	champ := make_champion()
	outline := make_outline(fonts)
	for outline.is_running {
		dt := rl.GetFrameTime()
		update_outline(&outline, dt)

		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(C_DARK)
		draw_outline(outline)
	}
}
