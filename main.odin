package jam

import "core:fmt"
import la "core:math/linalg"
import rl "vendor:raylib"

SCREEN   :: 600
C_DARK   :: rl.Color{ 0x19, 0x19, 0x19, 0xff }
C_RED    :: rl.Color{ 0x75, 0x0e, 0x21, 0xff }
C_ORANGE :: rl.Color{ 0xe3, 0x65, 0x1d, 0xff }
C_LIME   :: rl.Color{ 0xbe, 0xd7, 0x54, 0xff }

main :: proc() {
	using rl

	SetTraceLogLevel(.WARNING)
	SetTargetFPS(60)
	SetConfigFlags({ .MSAA_4X_HINT })

	InitWindow(SCREEN, SCREEN, "DODGE!!!")
	defer CloseWindow()

	SIZE :: SCREEN / 48
	c_pos, t_pos, m_pos: [2]f32
	c_pos.x, c_pos.y = SCREEN / 2, SCREEN / 2
	t_pos = c_pos

	for !WindowShouldClose() {
		dt := GetFrameTime()
		speed: f32 = SIZE * 10
		m_pos.x, m_pos.y = f32(GetMouseX()), f32(GetMouseY())
		if IsMouseButtonPressed(.RIGHT) {
			t_pos = m_pos
		}
		if IsKeyPressed(.F) {
			t_pos = m_pos
			c_pos += la.normalize(m_pos - c_pos) * speed / 2
		} else {
			if IsMouseButtonDown(.LEFT) do speed *= 1.5
			if la.distance(c_pos, t_pos) > SIZE / 4 {
				c_pos += la.normalize(t_pos - c_pos) * speed * dt
			}
		}
		BeginDrawing()
		ClearBackground(C_DARK)
		DrawCircle(i32(t_pos.x), i32(t_pos.y), SIZE / 4, C_LIME)
		DrawCircle(i32(c_pos.x), i32(c_pos.y), SIZE, C_RED)
		EndDrawing()
	}
}
