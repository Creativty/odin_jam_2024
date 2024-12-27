package jam

import rl "vendor:raylib"

Fonts :: struct {
	title: struct {
		xl: rl.Font,
		lg: rl.Font,
		md: rl.Font,
	},
	option: rl.Font,
	league, spiegel, beaufort: rl.Font,
}

load_fonts :: proc() -> Fonts {
	fonts: Fonts
	fonts.league = rl.LoadFontEx("assets/League.otf", 32, nil, 127)
	fonts.title.xl = rl.LoadFontEx("assets/League.otf", 64, nil, 127)
	fonts.title.lg = rl.LoadFontEx("assets/League.otf", 48, nil, 127)
	fonts.title.md = rl.LoadFontEx("assets/League.otf", 32, nil, 127)
	fonts.option = rl.LoadFontEx("assets/beaufort/BeaufortforLOL-Regular.otf", 48, nil, 127)
	fonts.spiegel = rl.LoadFontEx("assets/spiegel/Spiegel-Regular.otf", 16, nil, 127)
	fonts.beaufort = rl.LoadFontEx("assets/beaufort/BeaufortforLOL-Regular.otf", 24, nil, 127)
	return fonts
}

unload_fonts :: proc(fonts: Fonts) {
	rl.UnloadFont(fonts.title.xl)
	rl.UnloadFont(fonts.title.lg)
	rl.UnloadFont(fonts.title.md)
	rl.UnloadFont(fonts.option)
	rl.UnloadFont(fonts.league)
	rl.UnloadFont(fonts.spiegel)
	rl.UnloadFont(fonts.beaufort)
}
