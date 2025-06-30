# 🎨 Colorful Editor Like VSCode - Complete Setup Guide

Your NeoVim has been transformed into a colorful, VSCode-like editor with modern syntax highlighting! Here's everything you need to know.

## 🚀 What's New

### ✅ Installed Plugins

#### Core Syntax Highlighting
- **nvim-treesitter**: Modern syntax highlighting using AST parsing
- **nvim-treesitter-textobjects**: Enhanced text objects for better code navigation
- **vscode.nvim**: Official VSCode Dark+ theme port

#### Visual Enhancements
- **rainbow-delimiters.nvim**: Colorful parentheses, brackets, and braces
- **indent-blankline.nvim**: Beautiful indent guides
- **nvim-colorizer.lua**: Live color preview for hex codes
- **lualine.nvim**: VSCode-style status line
- **vim-illuminate**: Highlight similar words under cursor
- **vim-matchup**: Better bracket matching with Treesitter

## 🎯 Features Enabled

### 1. Advanced Syntax Highlighting
- **Treesitter parsing** for Go, TypeScript, JavaScript, TSX, JSON, YAML, Markdown, and more
- **Semantic highlighting** with LSP integration
- **Context-aware** highlighting based on code structure (not just regex)
- **Incremental selection** with `gnn`, `grn`, `grc`, `grm`

### 2. VSCode-Like Appearance
- **VSCode Dark+ theme** with enhanced colors for Go and TypeScript
- **Custom highlight groups** for better function, variable, and type visibility
- **Consistent color scheme** across all UI elements
- **Professional status line** with git branch, diagnostics, and file info

### 3. Visual Code Navigation
- **Rainbow brackets** in 7 different colors
- **Indent guides** with scope highlighting
- **Word illumination** - highlights all instances of word under cursor
- **Enhanced bracket matching** with Treesitter integration

### 4. Color Features
- **Live hex color preview** - see colors like `#FF0000` highlighted
- **Multiple color format support** - RGB, hex codes, CSS colors
- **Real-time color updates** as you type

## 🎨 Color Showcase

### Go Language Colors
```go
// Functions: Golden (#DCDCAA)
func NewUserRepository() UserService {
    // Types: Teal (#4EC9B0)  
    return &userRepository{
        // Variables: Light blue (#9CDCFE)
        users: make(map[int]*User),
    }
}

// Keywords: Blue (#569CD6)
const MaxRetries = 3

// Strings: Brown (#CE9178)
log.Printf("Created user: %+v", user)

// Comments: Green italic (#6A9955)
// This is a beautifully colored comment
```

### TypeScript Colors
```typescript
// Interfaces: Light green (#B8D7A3)
interface User {
    // Properties: Light blue (#9CDCFE)
    id: number;
    name: string;
}

// Classes: Teal (#4EC9B0)
class UserService {
    // Methods: Golden (#DCDCAA)
    async getUser(id: number): Promise<User> {
        // Variables: Light blue (#9CDCFE)
        const user = await this.apiClient.get(`/users/${id}`);
        return user.data;
    }
}

// JSX Elements: Blue (#569CD6)
const UserCard = () => (
    <div className="user-card">
        <h3 style={{ color: '#007bff' }}>User Name</h3>
    </div>
);
```

## 🔧 Usage Guide

### Treesitter Commands
```vim
:TSInstall <language>        " Install parser for specific language
:TSUpdate                    " Update all parsers
:TSUninstall <language>      " Remove parser
:TSModuleInfo                " Show module status
:checkhealth nvim-treesitter " Check Treesitter health
```

### Text Objects (Enhanced with Treesitter)
```vim
" Function text objects
af  " Select entire function (outer)
if  " Select function body (inner)

" Class text objects  
ac  " Select entire class (outer)
ic  " Select class body (inner)

" Block text objects
ab  " Select entire block (outer)
ib  " Select block content (inner)

" Parameter text objects
aa  " Select parameter with comma (outer)
ia  " Select parameter only (inner)
```

### Movement Commands
```vim
" Function/Class navigation
]m  " Next function start
[m  " Previous function start
]]  " Next class start
[[  " Previous class start
]M  " Next function end
[M  " Previous function end
```

### Incremental Selection
```vim
gnn  " Start selection
grn  " Expand selection to next node
grc  " Expand selection to next scope
grm  " Shrink selection to previous node
```

### Color Commands
```vim
:ColorizerToggle        " Toggle color highlighting
:ColorizerAttachToBuffer " Enable colors for current buffer
:ColorizerDetachFromBuffer " Disable colors for current buffer
```

## 🎯 Language-Specific Features

### Go Programming
- **Function highlighting**: Function names in golden color
- **Type highlighting**: Struct types in teal
- **Interface highlighting**: Interface types with distinct colors
- **Method highlighting**: Method calls clearly distinguished
- **Pointer highlighting**: Pointer operators clearly visible
- **Package highlighting**: Import paths and package names

### TypeScript/React
- **Interface highlighting**: TypeScript interfaces in light green
- **Generic highlighting**: Type parameters clearly marked
- **JSX highlighting**: React components with proper tag colors
- **Hook highlighting**: React hooks with consistent styling
- **Type annotation highlighting**: Clear distinction for type annotations
- **Import highlighting**: ES6 imports with proper syntax colors

### Universal Features
- **String highlighting**: Consistent string colors across languages
- **Comment highlighting**: Italic comments in green
- **Number highlighting**: Distinct color for numeric literals
- **Boolean highlighting**: Clear true/false highlighting
- **Operator highlighting**: Mathematical and logical operators
- **Punctuation highlighting**: Brackets, commas, semicolons

## 🔍 Visual Indicators

### Rainbow Brackets
Brackets are colored in this order:
1. 🔴 Red - Outermost level
2. 🟡 Yellow - Second level  
3. 🔵 Blue - Third level
4. 🟠 Orange - Fourth level
5. 🟢 Green - Fifth level
6. 🟣 Violet - Sixth level
7. 🔵 Cyan - Seventh level

### Indent Guides
- **Thin gray lines** show indentation levels
- **Bright blue lines** highlight current scope
- **Smart detection** works with spaces and tabs

### Word Illumination
- **Subtle highlighting** of similar words when cursor is on a symbol
- **LSP-aware** - uses language server for accurate matching
- **Configurable delay** - highlights appear after brief pause

## 🛠️ Customization

### Change Colorscheme
If you want to try a different theme, edit `/Users/takesupasankyu/.config/nvim/lua/plugins/colorscheme.lua`:

```lua
-- Uncomment one of these alternatives:

-- Tokyo Night (modern dark theme)
vim.cmd("colorscheme tokyonight")

-- Nightfox (customizable theme)  
vim.cmd("colorscheme carbonfox")

-- Or keep VSCode theme (current)
vim.cmd("colorscheme vscode")
```

### Adjust Colors
You can customize specific highlighting in the colorscheme configuration:

```lua
group_overrides = {
  -- Make functions more prominent
  ['@function.go'] = { fg = '#FFD700', bold = true },
  
  -- Change comment style
  ['@comment'] = { fg = '#7C7C7C', italic = false },
  
  -- Customize string colors
  ['@string'] = { fg = '#A3BE8C' },
}
```

### Toggle Features
```vim
" Toggle rainbow brackets
:RainbowToggle

" Toggle indent guides  
:IBLToggle

" Toggle word illumination
:IlluminateToggle

" Toggle colorizer
:ColorizerToggle
```

## 📁 Test Files

I've created test files to showcase the colorful highlighting:

### `test_highlighting.go`
- Comprehensive Go code with all language features
- Interfaces, structs, methods, functions
- Error handling, HTTP handlers, constants
- Color hex codes for colorizer testing

### `test_highlighting.ts`
- TypeScript/React code with modern features  
- Interfaces, classes, generics, hooks
- JSX components with styled elements
- Advanced TypeScript patterns

## 🚨 Troubleshooting

### If Colors Don't Appear
1. **Check termguicolors**: `:set termguicolors?` should show `termguicolors`
2. **Verify Treesitter**: `:checkhealth nvim-treesitter`
3. **Check LSP**: `:LspInfo` should show attached servers
4. **Restart NeoVim**: Sometimes needed after installing plugins

### If Treesitter Errors Occur
```vim
:TSUpdate          " Update all parsers
:TSInstall! go     " Reinstall Go parser
:TSInstall! typescript  " Reinstall TypeScript parser
```

### Performance Issues
```vim
" Check startup time
nvim --startuptime startup.log

" Disable features for large files
:set syntax=off    " Temporarily disable highlighting
```

## 🎉 Enjoy Your Colorful Editor!

Your NeoVim now rivals VSCode in terms of visual appeal and functionality. The colorful syntax highlighting makes code more readable, and the visual enhancements help with navigation and understanding code structure.

**Key Benefits:**
- ✅ **Faster than VSCode** - Native performance
- ✅ **More accurate highlighting** - AST-based parsing
- ✅ **Highly customizable** - Every color can be tweaked
- ✅ **Consistent experience** - Same colors across all file types
- ✅ **Professional appearance** - Ready for any development environment

Happy coding with your beautiful, colorful NeoVim editor! 🎨✨