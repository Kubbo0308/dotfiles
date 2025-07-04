# Git Commands in Neovim

This document outlines all the Git-related commands available in our Neovim configuration.

## **Core Git Commands in Neovim**

### **Telescope Git Integration**
- `<leader>gf` - **Git files** (tracked files only)
- `<leader>gb` - **Git branches** (switch branches)
- `<leader>gc` - **Git commits** (browse commit history)
- `<leader>gs` - **Git status** (see changed files)
- `<leader>gd` - **Git diff files** (files with diffs + live preview)
- `<leader>gg` - **Git commands** (show all git commands)

### **Git Fugitive Commands**
- `:Git` or `:G` - Open git command interface
- `:Gstatus` - Show git status
- `:Gdiff` - Show diff of current file
- `:Gblame` - Show git blame for current file
- `:Glog` - Show git log
- `:Gwrite` - Stage current file (`git add`)
- `:Gread` - Checkout current file (`git checkout`)
- `:Gcommit` - Open commit buffer

### **GitHub Integration (Octo.nvim)**
- `<leader>ghi` - **List GitHub issues**
- `<leader>ghp` - **List GitHub PRs**
- `<leader>ghr` - **Start PR review**
- `<leader>ghc` - **Create PR**

### **Git Blame**
- `<leader>ghb` - **Git blame current line**
- `<leader>gho` - **Toggle git blame** (show/hide)
- `<leader>ghu` - **Open commit URL** in browser

### **GitSigns (Hunk Management)**
- `]c` - **Next hunk** (git change)
- `[c` - **Previous hunk** (git change)
- `<leader>hs` - **Stage hunk**
- `<leader>hr` - **Reset hunk**
- `<leader>hS` - **Stage buffer**
- `<leader>hu` - **Undo stage hunk**
- `<leader>hR` - **Reset buffer**
- `<leader>hp` - **Preview hunk**
- `<leader>hb` - **Blame line**
- `<leader>hd` - **Diff this**
- `<leader>hD` - **Diff this (cached)**
- `<leader>tb` - **Toggle current line blame**
- `<leader>td` - **Toggle deleted**

## **Advanced Git Workflows**

### **Interactive Rebase**
- `:Git rebase -i HEAD~3` - Interactive rebase last 3 commits

### **Merge Conflicts**
- `:Gdiff` - 3-way diff for merge conflicts
- `:diffget //2` - Get change from target branch
- `:diffget //3` - Get change from merge branch

### **Branch Management**
- `:Git checkout -b feature/new-branch` - Create new branch
- `:Git merge feature/branch` - Merge branch

## **Pro Tips**

1. **Use `<leader>gd`** for quick diff overview with live preview
2. **Use GitSigns** for line-by-line staging (`<leader>hs`)
3. **Use Telescope** for visual git navigation (`<leader>gc`, `<leader>gb`)
4. **Use Octo.nvim** for GitHub workflows directly in Neovim
5. **Use `<leader>gg`** to access all git commands quickly

## **Common Workflows**

### **Making a Commit**
1. `<leader>gd` - Review changes
2. `<leader>hs` - Stage hunks individually, or
3. `:Gwrite` - Stage entire file
4. `:Gcommit` - Open commit buffer
5. Write commit message and save

### **Reviewing Changes**
1. `<leader>gd` - See all files with changes
2. `<leader>hp` - Preview individual hunks
3. `<leader>ghb` - See who last modified a line
4. `:Gdiff` - Full diff view for current file

### **Branch Operations**
1. `<leader>gb` - Switch between branches
2. `<leader>gc` - Review commit history
3. `:Git checkout -b feature/new-feature` - Create new branch
4. `<leader>ghi` - Check related GitHub issues

### **GitHub Integration**
1. `<leader>ghp` - List pull requests
2. `<leader>ghr` - Start reviewing a PR
3. `<leader>ghc` - Create a new PR
4. `<leader>ghu` - Open commit in browser

## **Keyboard Shortcuts Summary**

| Command | Action |
|---------|--------|
| `<leader>gf` | Git tracked files |
| `<leader>gb` | Git branches |
| `<leader>gc` | Git commits |
| `<leader>gs` | Git status |
| `<leader>gd` | Git diff files |
| `<leader>gg` | Git commands menu |
| `<leader>ghi` | GitHub issues |
| `<leader>ghp` | GitHub PRs |
| `<leader>ghr` | Start PR review |
| `<leader>ghc` | Create PR |
| `<leader>ghb` | Git blame current line |
| `<leader>gho` | Toggle git blame |
| `<leader>ghu` | Open commit URL |
| `]c` / `[c` | Next/Previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |