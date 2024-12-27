package jam

import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
	using rl

	SetTraceLogLevel(.WARNING)
	SetConfigFlags({ .MSAA_4X_HINT })
	SetTargetFPS(60)

	InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "DODGE!!!")
	defer CloseWindow()

	for !WindowShouldClose() {
		BeginDrawing()
		EndDrawing()
	}
}
