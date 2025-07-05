local wezterm = require("wezterm")
local config = {}

-- Get the directory of this configuration file
local script_dir = os.getenv("HOME") .. "/.config/wezterm/config/"

-- Background image configuration
config.background = {
    {
        source = { 
            File = script_dir .. "your_name.gif" 
        },
        -- Make the image subtle so text remains readable
        opacity = 0.95,
        hsb = { 
            brightness = 1.0,
            hue = 1.0,
            saturation = 0.8
        }
    },
    -- Add a semi-transparent overlay for better text readability
    {
        source = { 
            Color = "rgba(0, 0, 0, 0.7)" 
        },
        height = "100%",
        width = "100%",
    }
}

config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.colors = {
    tab_bar = {
        inactive_tab_edge = "none",
    },
}

return config
