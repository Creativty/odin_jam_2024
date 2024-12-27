package jam

Stage_Play :: struct {
}

make_stage_play :: proc() -> Stage {
	stage: Stage
	stage.data = Stage_Play{
	}
	return stage
}
