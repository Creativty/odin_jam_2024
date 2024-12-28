package jam

import rl "vendor:raylib"

Fonts :: struct {
	title: struct {
		xl: rl.Font,
		lg: rl.Font,
		md: rl.Font,
		sm: rl.Font,
	},
	option, debug, tip: rl.Font,
}

load_fonts :: proc() -> Fonts {
	fonts: Fonts
	// TODO(XENOBAS): Fix this font throws a warning on load or paint idk
	fonts.title.sm = rl.LoadFontEx("assets/League.otf", 24, nil, 127)
	fonts.title.md = rl.LoadFontEx("assets/League.otf", 32, nil, 127)
	fonts.title.lg = rl.LoadFontEx("assets/League.otf", 48, nil, 127)
	fonts.title.xl = rl.LoadFontEx("assets/League.otf", 64, nil, 127)
	fonts.tip = rl.LoadFontEx("assets/beaufort/BeaufortforLOL-Medium.otf", 24, nil, 127)
	fonts.debug = rl.LoadFontEx("assets/spiegel/Spiegel-SemiBold.otf", 16, nil, 127)
	fonts.option = rl.LoadFontEx("assets/beaufort/BeaufortforLOL-Bold.otf", 64, nil, 127)
	return fonts
}

unload_fonts :: proc(fonts: Fonts) {
	rl.UnloadFont(fonts.title.xl)
	rl.UnloadFont(fonts.title.lg)
	rl.UnloadFont(fonts.title.md)
	rl.UnloadFont(fonts.title.sm)
	rl.UnloadFont(fonts.tip)
	rl.UnloadFont(fonts.debug)
	rl.UnloadFont(fonts.option)
}
