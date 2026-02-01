local wezterm = require("wezterm")

return {
	font = wezterm.font("JetBrainsMono Nerd Font"),
	font_size = 12.0,
	bidi_enabled = true,
	front_end = "OpenGL",
	enable_wayland = false,

	colors = {
		background = "#282828",
		foreground = "#ebdbb2",
		cursor_bg = "#ebdbb2",
		cursor_fg = "#282828",

		ansi = {
			"#282828",
			"#cc241d",
			"#98971a",
			"#d79921",
			"#458588",
			"#b16286",
			"#689d6a",
			"#a89984",
		},
		brights = {
			"#928374",
			"#fb4934",
			"#b8bb26",
			"#fabd2f",
			"#83a598",
			"#d3869b",
			"#8ec07c",
			"#ebdbb2",
		},
	},

	window_background_opacity = 1.0,
	enable_scroll_bar = false,
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

	term = "xterm-256color",
}
