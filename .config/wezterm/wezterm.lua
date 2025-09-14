local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

config.font_size = 12.8
config.line_height = 1.2
config.font = wezterm.font 'JetBrainsMono Nerd Font Mono'
config.color_scheme = 'Catppuccin Mocha'
config.default_cursor_style = "SteadyBlock"
config.max_fps = 120
config.adjust_window_size_when_changing_font_size = false
config.scrollback_lines = 1000000
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.window_decorations = "RESIZE"

config.colors = {
  cursor_bg = "#89b4fa",      -- blue
  cursor_border = "#b4befe",  -- lavender
}
-- config.command_palette_bg_color = "#1e1e2e"
-- config.command_palette_fg_color = "#cdd6f4"
-- config.command_palette_font = wezterm.font 'JetBrainsMono Nerd Font Mono'
-- config.command_palette_font_size = 12.8
-- config.command_palette_rows = 15
config.command_palette_bg_color = "#1e1e2e"
config.command_palette_fg_color = "#cdd6f4"
config.command_palette_font_size = 12.8
config.command_palette_rows = 15


config.window_background_opacity = 0.83
config.macos_window_background_blur = 83
config.window_background_opacity = 0.83
config.macos_window_background_blur = 83
config.term = "xterm-256color"

config.keys = {
    {
        key = 'd',
        mods = 'CMD',
        action = wezterm.action.SplitHorizontal {domain = 'CurrentPaneDomain'}
    },
    {
        key = 'd',
        mods = 'CMD|SHIFT',
        action = wezterm.action.SplitVertical {domain = 'CurrentPaneDomain'}
    },
    {
        key = 'k',
        mods = 'CMD',
        action = wezterm.action.SendString 'clear\n'
    },
    {
        key = 'p',
        mods = 'CMD|SHIFT',
        action = wezterm.action.ActivateCommandPalette,
    },
}

config.window_padding = {
  left = 8,
  right = 8,
  top = 4,
  bottom = 4,
}

-- 1) Define an event that shows the rename prompt
wezterm.on('rename_tab_prompt', function(window, pane)
  window:perform_action(
    act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(win, p, line)
        if line and #line > 0 then
          win:active_tab():set_title(line)
        end
      end),
    },
    pane
  )
end)

-- 2) Add it to the Command Palette via EmitEvent
wezterm.on('augment-command-palette', function(window, pane)
  return {
    {
      brief = 'Rename tab',
      icon = 'md_rename_box',
      -- Some older builds ignore icons; keep it simple:
      action = act.EmitEvent 'rename_tab_prompt',
    },
  }
end)

return config

