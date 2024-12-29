package jam

import "core:fmt"
import "core:math"
import "core:math/rand"
import la "core:math/linalg"
import rl "vendor:raylib"

DURATION_TIMEOUT  :: 0.8
DURATION_SPAWNER  :: 4
DURATION_POSTGAME :: 8

Play_State :: enum {
	Pause,
	Timeout,
	In_Game,
	Post_Game,
}

Stage_Play :: struct {
	score: int,
	state: Play_State,
	champion: Champion,
	particles: [dynamic]Particle,
	projectiles: [dynamic]Projectile,
	pause_option: int,
	spawner_active: bool,
	spawner_elapsed: f32,
	timeout_elapsed: f32,
	postgame_elapsed: f32,
}

make_stage_play :: proc() -> Stage {
	stage: Stage
	stage.data = Stage_Play{
		state = .Timeout,
		champion = make_champion(),
		spawner_active = true,
	}
	stage.update = proc(o: ^Outline, dt: f32) {
		data := &o.stages[.Play].data.(Stage_Play)
		if !rl.IsWindowFocused() && (data.state == .In_Game || data.state == .Timeout) {
			data.pause_option = 0
			data.state = .Pause
		}
		switch (data.state) {
		case .Pause:
			update_pause(o, data)
		case .Timeout:
			update_timeout(o, data, dt)
		case .In_Game:
			update_in_game(o, data, dt)
		case .Post_Game:
			update_post_game(o, data, dt)
		}
	}
	stage.draw = proc(o: Outline) {
		data := o.stages[.Play].data.(Stage_Play)
		switch (data.state) {
		case .Pause:
			draw_pause(o, data)
		case .Timeout:
			draw_timeout(o, data)
		case .In_Game:
			draw_in_game(o, data)
		case .Post_Game:
			draw_post_game(o, data)
		}
	}
	return stage
}

update_pause :: proc(o: ^Outline, data: ^Stage_Play) {
	COUNT_PAUSE_OPTIONS :: 2
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

draw_pause :: proc(o: Outline, data: Stage_Play) {
	font_pause := o.fonts.title.xl
	font_option := o.fonts.option

	text_quit : cstring = "Back to menu"
	text_pause : cstring = "PAUSED"
	text_resume : cstring = "Resume"

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

update_timeout :: proc(o: ^Outline, data: ^Stage_Play, dt: f32) {
	if data.timeout_elapsed > DURATION_TIMEOUT {
		data.state = .In_Game
		data.timeout_elapsed = 0
		return
	}
	data.timeout_elapsed += dt
}

draw_timeout :: proc(o: Outline, data: Stage_Play) {
	font := o.fonts.title.md
	text := fmt.caprintf("Prepare to start in %d...", int(DURATION_TIMEOUT - data.timeout_elapsed))
	defer delete(text)
	measure := rl.MeasureTextEx(font, text, f32(font.baseSize), 1.0)
	position := rl.Vector2{ (SCREEN - measure.x) / 2, (SCREEN - measure.y) / 2 }
	rl.DrawTextEx(font, text, position, f32(font.baseSize), 1.0, { 0xff, 0xff, 0xff, u8(0xff * (DURATION_TIMEOUT - data.timeout_elapsed))})
}

update_projectiles :: proc(o: ^Outline, data: ^Stage_Play, dt: f32) -> (dead_projectiles: [dynamic]^Projectile, hit: bool){
	dead_projectiles = make([dynamic]^Projectile)
	for i in 0..<len(data.projectiles) {
		projectile := &data.projectiles[i]
		if (projectile.do_delete) do append(&dead_projectiles, projectile)
		else if hit_test_projectile(projectile^, data.champion) {
			hit = true
			data.state = .Post_Game
			break
		}
		update_projectile(projectile, dt)
	}
	return
}

update_in_game :: proc(o: ^Outline, data: ^Stage_Play, dt: f32) {
	if rl.IsKeyPressed(.ESCAPE) {
		data.pause_option = 0
		data.state = .Pause
		return
	}
	data.spawner_active = data.spawner_active || data.spawner_elapsed >= DURATION_SPAWNER
	data.spawner_elapsed += dt
	if data.spawner_active {
		// Spawn
		CENTER :: SCREEN / 2
		MAGNITUDE :: SCREEN
		count := 3 + data.score / 9
		offset := rand.float32() * 0.05
		for i in 0..<count {
			rads := 2 * math.PI * ((f32(i) + offset) / f32(count))
			x, y := math.cos(rads), math.sin(rads)
			target := [2]f32{ CENTER, CENTER } - [2]f32{ x, y } * MAGNITUDE
			position := [2]f32{ CENTER, CENTER } + [2]f32{ x, y } * MAGNITUDE
			append(&data.projectiles, make_projectile(position, target))
		}
		// Reset
		data.spawner_active = false
		data.spawner_elapsed = 0
	}

	dead_projectiles, hit := update_projectiles(o, data, dt)
	defer delete(dead_projectiles)
	if hit do return

	for projectile in dead_projectiles { // Delete projectiles marked as do_delete
		for i in 0..<len(data.projectiles) {
			match := &data.projectiles[i]
			if match == projectile {
				data.score += 1
				unordered_remove(&data.projectiles, i)
				break
			}
		}
	}
	update_champion(&data.champion, dt)
	//update_particles(&data.particles, dt)
}

draw_in_game :: proc(o: Outline, data: Stage_Play) {
	draw_champion(data.champion)
	for p in data.projectiles do draw_projectile(p)
	{
		text_line := fmt.caprintf("You have %d points", data.score)
		defer delete(text_line)
		measure := draw_text_debug(o, text_line, { 16, 16 })
	}
	{
		text_line := fmt.caprintf("fps: %d / 120, projectiles: %d", rl.GetFPS(), len(data.projectiles))
		defer delete(text_line)
		measure := draw_text_debug(o, text_line, { 16, 32 })
	}
	{
		angle := math.to_degrees(angle_radians(data.champion.position, data.champion.target))
		text_line := fmt.caprintf("angle: %4.2f degrees", angle)
		defer delete(text_line)
		measure := draw_text_debug(o, text_line, { 16, 48 })
	}
}

update_post_game :: proc(o: ^Outline, data: ^Stage_Play, dt: f32) {
	data.postgame_elapsed += dt
	if rl.IsKeyPressed(.SPACE) {
		data.postgame_elapsed += DURATION_POSTGAME
	}
	if data.postgame_elapsed >= DURATION_POSTGAME {
		transition_outline(o, .Menu)
		data.postgame_elapsed = 0
	}
}

draw_post_game :: proc(o: Outline, data: Stage_Play) {
	using rl

	draw_in_game(o, data)
	DrawRectangle(0, 0, SCREEN, SCREEN, { 0x75, 0x0e, 0x21, 0x21 })
}
