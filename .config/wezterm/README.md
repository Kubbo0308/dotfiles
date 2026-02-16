# WezTerm Configuration

[WezTerm](https://wezfurlong.org/wezterm/) terminal emulator configuration with modular Lua setup.

## Directory Structure

```
config/wezterm/
├── wezterm.lua              # Main configuration entry point
└── config/
    ├── keybind.lua         # Key bindings
    ├── background.lua      # Background settings
    └── your_name.gif       # Background animation
```

## Features

### Color Scheme
- **Theme**: Tokyo Night
- Customized tab title colors (gold for active, gray for inactive)

### Font Configuration
Fallback font chain for optimal display:

1. `Liga SFMono Nerd Font` - Primary (ligatures + icons)
2. `SF Mono` - Fallback sans ligatures
3. `PlemolJP Console NF` - Japanese text
4. `Hiragino Kaku Gothic ProN` - Additional Japanese

**Font Size**: 16.0pt

### Modular Architecture

The configuration is split into modules for easier maintenance:

| Module | Purpose |
|--------|---------|
| `wezterm.lua` | Main config, merges all modules |
| `config/keybind.lua` | Key bindings and leader key |
| `config/background.lua` | Background image/animation |

## Customization

### Change Color Scheme

Edit `wezterm.lua`:
```lua
config.color_scheme = "Tokyo Night"  -- or other scheme
```

Available schemes: https://wezfurlong.org/wezterm/colorschemes/

### Modify Key Bindings

Edit `config/keybind.lua`:
```lua
return {
    leader = { key = "a", mods = "CTRL" },
    keys = {
        { key = "v", mods = "LEADER", action = wezterm.action.SplitVertical },
        { key = "h", mods = "LEADER", action = wezterm.action.SplitHorizontal },
        -- Add more bindings...
    }
}
```

### Change Background

Edit `config/background.lua`:
```lua
return {
    background = {
        {
            source = { File = wezterm.config_dir .. "/config/your_name.gif" },
            -- Configuration options...
        }
    }
}
```

### Change Font

Edit `wezterm.lua`:
```lua
config.font = wezterm.font_with_fallback({
    { family = "Your Font Name", weight = "Regular" },
    -- Fallbacks...
})
config.font_size = 16.0
```

## Tab Title Format

Active and inactive tabs have different styling:
- **Active tab**: Gold background (#ae8b2d), white text
- **Inactive tab**: Gray background (#5c6d74), white text

## Installation

The configuration is automatically linked via the dotfiles install script:

```bash
~/.config/wezterm → ~/.dotfiles/config/wezterm
```

## Troubleshooting

### Fonts not displaying correctly

1. Verify fonts are installed:
   ```bash
   wezterm ls-fonts
   ```

2. Check for font availability:
   ```bash
   fc-list | grep "SFMono"
   ```

### Configuration not loading

1. Check syntax:
   ```bash
   wezterm show-keys  # Validates config
   ```

2. View logs:
   ```bash
   wezterm cli debug-log
   ```

## Resources

- [WezTerm Documentation](https://wezfurlong.org/wezterm/)
- [Configuration Reference](https://wezfurlong.org/wezterm/config/files.html)
- [Color Schemes](https://wezfurlong.org/wezterm/colorschemes/)
- [Key Binding Reference](https://wezfurlong.org/wezterm/config/keys.html)

