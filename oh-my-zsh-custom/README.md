# Oh-My-Zsh Custom Configuration

Custom themes, plugins, and configurations for [Oh-My-Zsh](https://ohmyz.sh/).

## Directory Structure

```
oh-my-zsh-custom/
├── README.md                # This file
├── plugins.txt              # External plugins to install
├── example.zsh             # Custom shell configurations
└── themes/
    └── example.zsh-theme   # Custom theme (if any)
```

## External Plugins

Listed in `plugins.txt`:

| Plugin | Description | URL |
|--------|-------------|-----|
| zsh-syntax-highlighting | Syntax highlighting for commands | [GitHub](https://github.com/zsh-users/zsh-syntax-highlighting) |
| zsh-autosuggestions | Fish-like auto suggestions | [GitHub](https://github.com/zsh-users/zsh-autosuggestions) |
| zsh-completions | Additional completion definitions | [GitHub](https://github.com/zsh-users/zsh-completions) |

## Installation

### Automatic Installation

Use the provided script:

```bash
~/.dotfiles/.scripts/install-oh-my-zsh-plugins.sh
```

### Manual Installation

Clone plugins to `~/.oh-my-zsh/custom/plugins/`:

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-completions.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
```

## Enabling Plugins

Add plugins to `~/.zshrc`:

```bash
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
)
```

## Custom Configuration

### example.zsh

Place custom shell configurations in `example.zsh` (or create your own `.zsh` files). These are automatically sourced by Oh-My-Zsh.

Common customizations:
- Aliases
- Environment variables
- Functions
- Shell options

### Custom Themes

Place custom themes in `themes/` directory with `.zsh-theme` extension.

To use a custom theme, set in `~/.zshrc`:

```bash
ZSH_THEME="example"  # Without .zsh-theme extension
```

## Current Configuration

The main Zsh configuration is in `~/.dotfiles/zshrc`:

- **Theme**: agnoster
- **Plugins**: git, zsh-syntax-highlighting, zsh-autosuggestions
- **Tools**: zoxide (directory navigation)

## Adding New Plugins

1. Add the repository URL to `plugins.txt`
2. Run the install script or clone manually
3. Add the plugin name to the `plugins=()` array in `~/.zshrc`
4. Reload shell: `source ~/.zshrc`

## Troubleshooting

### Plugins not loading

1. Check plugin is cloned:
   ```bash
   ls ~/.oh-my-zsh/custom/plugins/
   ```

2. Verify in `~/.zshrc`:
   ```bash
   grep "plugins=" ~/.zshrc
   ```

3. Reload configuration:
   ```bash
   source ~/.zshrc
   ```

### Slow shell startup

Some plugins can slow down shell startup. Profile with:

```bash
# Add to .zshrc temporarily
zmodload zsh/zprof  # At the top
zprof               # At the bottom
```

## Resources

- [Oh-My-Zsh Documentation](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Oh-My-Zsh Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins)
- [Oh-My-Zsh Themes](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
- [zsh-users Plugins](https://github.com/zsh-users)

