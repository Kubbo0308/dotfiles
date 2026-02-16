# Neovimコマンドヘルプ機能の使い方

## 🎯 概要

Neovim内から簡単にコマンド一覧を参照できるヘルプ機能を追加しました。

## 📚 利用可能なコマンド

### ユーザーコマンド

| コマンド | 説明 |
|---------|------|
| `:CommandsHelp` | フローティングウィンドウでコマンドヘルプを表示 |
| `:CommandsHelpSplit` | 分割ウィンドウでコマンドヘルプを表示 |
| `:CommandsSearch [query]` | コマンドを検索 (Telescope利用) |
| `:CommandsCategories` | コマンドカテゴリから選択して検索 |

### キーバインド

#### メインヘルプキー

| キー | 効果 |
|------|------|
| `<leader>?h` | コマンドヘルプをフローティング表示 |
| `<leader>?s` | コマンドヘルプを分割表示 |
| `<leader>?f` | コマンドを検索 |
| `<leader>?c` | カテゴリから選択 |

#### 代替キー

| キー | 効果 |
|------|------|
| `<leader>hc` | コマンドヘルプ表示 |
| `<leader>hs` | コマンド検索 |

## 🚀 使い方

### 1. ヘルプを開く (推奨)

```vim
" フローティングウィンドウで開く (見やすい)
<leader>?h

" または
:CommandsHelp
```

フローティングウィンドウが開き、全コマンド一覧がMarkdown形式で表示されます。

**ヘルプウィンドウ内の操作:**
- `q` または `<Esc>`: ヘルプを閉じる
- `j/k`: 上下にスクロール
- `/`: 検索モード
- `n/N`: 次/前の検索結果

### 2. 分割ウィンドウで開く

```vim
<leader>?s

" または
:CommandsHelpSplit
```

垂直分割でヘルプが開きます。

### 3. コマンドを検索

```vim
<leader>?f

" または
:CommandsSearch

" 特定のワードで検索
:CommandsSearch telescope
:CommandsSearch git
```

Telescopeを使ってコマンドをインタラクティブに検索できます。

### 4. カテゴリから選択

```vim
<leader>?c

" または
:CommandsCategories
```

以下のカテゴリから選択できます:
- 基本操作
- ファイル管理
- Git操作
- LSP
- 言語別操作
- ターミナル
- UI・表示
- 補完・スニペット
- ヘルプ・情報
- プラグイン管理

## 📝 使用例

### 例1: Gitコマンドを探す

1. `<leader>?f` でコマンド検索を開く
2. "git" と入力
3. Git関連のコマンドが一覧表示される

### 例2: カテゴリからコマンドを探す

1. `<leader>?c` でカテゴリ選択を開く
2. "Git操作" を選択
3. Git関連のコマンドセクションが表示される

### 例3: ヘルプをサッと確認

1. `<leader>?h` でフローティングヘルプを開く
2. `/telescope` で検索
3. Telescopeのキーバインドを確認
4. `q` でヘルプを閉じる

## 🎨 カスタマイズ

### キーバインドの変更

`~/.config/nvim/lua/plugins/help-commands.lua` を編集:

```lua
-- 例: <F1>でヘルプを開く
vim.keymap.set("n", "<F1>", "<cmd>CommandsHelp<cr>", { desc = "Commands help" })

-- 例: <leader>hh でヘルプを開く
vim.keymap.set("n", "<leader>hh", "<cmd>CommandsHelp<cr>", { desc = "Commands help" })
```

### ウィンドウサイズの変更

`open_commands_help_float()` 関数内の以下の行を編集:

```lua
local width = math.floor(vim.o.columns * 0.8)  -- 0.8 を変更 (80%表示)
local height = math.floor(vim.o.lines * 0.8)   -- 0.8 を変更 (80%表示)
```

## 🔄 ドキュメントの更新

新しいキーバインドやコマンドを追加した場合:

1. `~/.config/nvim/COMMANDS.md` を編集
2. 該当するカテゴリに新しいコマンドを追加
3. Neovimを再起動 (または `:source $MYVIMRC`)
4. `:CommandsHelp` で更新されたドキュメントを確認

## 🐛 トラブルシューティング

### ヘルプが表示されない

```vim
" ファイルの存在確認
:echo stdpath('config') .. '/COMMANDS.md'

" 手動でファイルを開く
:e ~/.config/nvim/COMMANDS.md
```

### 検索機能が動作しない

Telescopeがインストールされているか確認:

```vim
:Telescope
```

Telescopeがない場合は、vimgrepにフォールバックします。

## 📖 関連ドキュメント

- メインドキュメント: `~/.config/nvim/COMMANDS.md`
- プラグイン設定: `~/.config/nvim/lua/plugins/help-commands.lua`
- Neovim公式ヘルプ: `:help`
- Which-key (キーバインド一覧): `<leader>` を押すと表示

## 💡 ヒント

- **素早くヘルプを確認**: `<leader>?h` を覚えておけば十分です
- **Which-keyと併用**: `<leader>` を押すとWhich-keyがポップアップするので、そこからもキーバインドを確認できます
- **検索を活用**: 大量のコマンドがあるので、`/` で検索するのが効率的です
- **カテゴリから探す**: 何を探しているかわからない場合は、カテゴリから探すのがおすすめです

---

**Happy Vimming! 🎉**
