# Neovim コマンド・キーバインド一覧

このドキュメントでは、設定済みのNeovimコマンドとキーバインドを網羅的に記載しています。

## 📌 基本情報

- **Leader Key**: `Space`
- **Local Leader Key**: `\`

---

## 🎯 基本操作

### ウィンドウナビゲーション

| キー | 効果 |
|------|------|
| `<C-h>` | 左のウィンドウに移動 |
| `<C-j>` | 下のウィンドウに移動 |
| `<C-k>` | 上のウィンドウに移動 |
| `<C-l>` | 右のウィンドウに移動 |

### ウィンドウサイズ変更

| キー | 効果 |
|------|------|
| `<C-Up>` | ウィンドウの高さを減らす |
| `<C-Down>` | ウィンドウの高さを増やす |
| `<C-Left>` | ウィンドウの幅を減らす |
| `<C-Right>` | ウィンドウの幅を増やす |

### バッファ操作

| キー | 効果 |
|------|------|
| `<S-l>` | 次のバッファへ移動 |
| `<S-h>` | 前のバッファへ移動 |
| `<leader>bd` | バッファを閉じる |

### テキスト移動

| キー | モード | 効果 |
|------|--------|------|
| `<A-j>` | Visual | 選択行を下に移動 |
| `<A-k>` | Visual | 選択行を上に移動 |
| `J` | Visual Block | 選択ブロックを下に移動 |
| `K` | Visual Block | 選択ブロックを上に移動 |

### その他基本操作

| キー | 効果 |
|------|------|
| `<leader>h` | 検索ハイライトをクリア |
| `<leader>w` | ファイルを保存 |
| `<leader>q` | Neovimを終了 |
| `<leader>x` | 保存して終了 |
| `<leader>fc` | Neovim設定ファイルを開く |

---

## 📁 ファイル管理

### Telescope (ファジーファインダー)

| キー | 効果 |
|------|------|
| `<leader>ff` | ファイル検索 |
| `<leader>fg` | テキスト検索 (live grep) |
| `<leader>fb` | バッファ一覧 |
| `<leader>fh` | ヘルプタグ検索 |
| `<leader>fr` | 最近開いたファイル |
| `<leader>fw` | カーソル下の単語を検索 |
| `<leader>fc` | コマンド一覧 |
| `<leader>fk` | キーマップ一覧 |
| `<leader>ft` | カラースキーム選択 |
| `<leader>fq` | Quickfix一覧 |
| `<leader>fl` | Location list |
| `<leader>fv` | Vimオプション |
| `<leader>fa` | 自動コマンド一覧 |
| `<leader>fp` | 過去のpicker |
| `<leader>f.` | 最後のpickerを再開 |

### 検索機能

| キー | 効果 |
|------|------|
| `<leader>s/` | 現在のバッファ内を検索 |
| `<leader>sm` | マーク一覧 |
| `<leader>sr` | レジスタ一覧 |
| `<leader>sj` | ジャンプリスト |
| `<leader>sh` | 検索履歴 |
| `<leader>sc` | コマンド履歴 |
| `<leader>ss` | スペル修正候補 |
| `<leader>st` | 拡張検索 (プレビュー付き) |
| `<leader>sf` | Far.vimで検索 |
| `<leader>sr` | Far.vimで検索・置換 |
| `<C-s>` | Far.vimで検索 (Normal/Visual) |
| `<C-g>` | Far.vimで検索・置換 (Normal/Visual) |
| `<leader>rg` | Ripgrep検索 |
| `<leader>rw` | カーソル下の単語をRipgrep検索 |

### ファイルツリー (nvim-tree)

| キー | 効果 |
|------|------|
| `<C-b>` | NvimTreeをトグル |
| `<C-m>` | NvimTreeにフォーカス |
| `<leader>p` | 画像をプレビュー (nvim-tree内) |

### Oil ファイルマネージャー

| キー | 効果 |
|------|------|
| `<leader>o` | Oilを開く |
| `<leader>O` | Oilをフローティングで開く |

#### Oil内のキーバインド

| キー | 効果 |
|------|------|
| `<CR>` | ファイル/ディレクトリを選択 |
| `<C-s>` | 垂直分割で開く |
| `<C-h>` | 水平分割で開く |
| `<C-t>` | 新しいタブで開く |
| `<C-p>` | プレビュー |
| `<C-c>` | 閉じる |
| `<C-l>` | 更新 |
| `-` | 親ディレクトリへ |
| `_` | カレントディレクトリを開く |
| `g.` | 隠しファイルをトグル |
| `gP` | 自動プレビューをトグル |
| `<leader>p` | 画像をプレビュー |
| `<leader>P` | プレビューペインをクリア |
| `<leader>C` | プレビューペインを閉じる |

**Oilコマンド:**
- `:OilToggleAutoPreview` - 自動プレビューをトグル
- `:OilSetDebounceDelay <ms>` - デバウンス遅延を設定
- `:OilShowConfig` - 設定を表示
- `:OilPreviewCurrent` - 現在のアイテムをプレビュー

---

## 🔧 Git操作

### Telescope Git統合

| キー | 効果 |
|------|------|
| `<leader>gf` | Gitファイル一覧 |
| `<leader>gb` | Gitブランチ一覧 |
| `<leader>gc` | Gitコミット履歴 |
| `<leader>gs` | Git status |
| `<leader>gd` | Git差分ファイル一覧 |
| `<leader>gg` | Gitコマンドメニュー |

### GitSigns (Hunk操作)

| キー | 効果 |
|------|------|
| `]c` | 次のHunkへ移動 |
| `[c` | 前のHunkへ移動 |
| `<leader>hs` | Hunkをステージ |
| `<leader>hr` | Hunkをリセット |
| `<leader>hS` | バッファ全体をステージ |
| `<leader>hu` | Hunkステージを取り消し |
| `<leader>hR` | バッファ全体をリセット |
| `<leader>hp` | Hunkをプレビュー |
| `<leader>hb` | 行のBlameを表示 |
| `<leader>tb` | 行Blameの表示をトグル |
| `<leader>hd` | 差分を表示 |
| `<leader>td` | 削除行の表示をトグル |

### Vim-Fugitive

| キー | 効果 |
|------|------|
| `<leader>gs` | Git status |
| `<leader>ga` | すべてをステージ (git add .) |
| `<leader>gc` | コミット |
| `<leader>gp` | プッシュ |
| `<leader>gl` | プル |
| `<leader>gb` | Blame |
| `<leader>gd` | Diff split |
| `<leader>gm` | マージ |

### DiffView

| キー | 効果 |
|------|------|
| `<leader>gv` | DiffViewを開く |
| `<leader>gh` | ファイル履歴 |

### GitHub統合 (Octo.nvim)

| キー | 効果 |
|------|------|
| `<leader>ghi` | GitHub Issue一覧 |
| `<leader>ghp` | GitHub PR一覧 |
| `<leader>ghr` | PRレビュー開始 |
| `<leader>ghc` | PR作成 |

### ターミナル統合

| キー | 効果 |
|------|------|
| `<leader>gg` | Lazygitを開く |

---

## 🧠 LSP (Language Server Protocol)

### LSP基本操作

| キー | 効果 |
|------|------|
| `gd` | 定義へジャンプ |
| `K` | ホバー情報を表示 |
| `<leader>vws` | ワークスペースシンボル検索 |
| `<leader>vd` | 診断をフロート表示 |
| `[d` | 次の診断へ |
| `]d` | 前の診断へ |
| `<leader>vca` | コードアクション |
| `<leader>vrr` | 参照を表示 |
| `<leader>vrn` | シンボルをリネーム |
| `<C-h>` (Insert) | シグネチャヘルプ |

### Telescope LSP統合

| キー | 効果 |
|------|------|
| `<leader>lr` | LSP参照 |
| `<leader>ld` | LSP定義 |
| `<leader>li` | LSP実装 |
| `<leader>ls` | ドキュメントシンボル |
| `<leader>lw` | ワークスペースシンボル |
| `<leader>le` | 診断一覧 |

---

## 🔤 言語別操作

### Go言語

| キー | 効果 |
|------|------|
| `<leader>gt` | テスト実行 |
| `<leader>gT` | ファイルのテスト実行 |
| `<leader>gf` | 関数のテスト実行 |
| `<leader>gc` | カバレッジ表示 |
| `<leader>gb` | ビルド |
| `<leader>gr` | 実行 |
| `<leader>gd` | デバッグ |
| `<leader>gD` | テストデバッグ |
| `<leader>gi` | インポート整理 |
| `<leader>gI` | インポート追加 |
| `<leader>ge` | if errパターン挿入 |
| `<leader>gF` | 構造体フィールド補完 |
| `<leader>gS` | switchケース補完 |
| `<leader>gta` | タグ追加 |
| `<leader>gtr` | タグ削除 |
| `<leader>gA` | 代替ファイル(テスト⇔実装)へ移動 |
| `<leader>gV` | 代替ファイルを垂直分割で開く |
| `<leader>gH` | 代替ファイルを水平分割で開く |
| `<leader>go` | インポート整理 (LSP) |
| `<leader>gf` | フォーマット (LSP) |

### TypeScript/JavaScript

| キー | 効果 |
|------|------|
| `<leader>to` | インポート整理 |
| `<leader>tR` | ファイルをリネーム |
| `<leader>ti` | 不足しているインポートを追加 |
| `<leader>tF` | すべて修正 |
| `<leader>tu` | 未使用インポートを削除 |
| `<leader>td` | ソース定義へジャンプ |
| `<leader>tr` | ファイル参照 |

### テストランナー (Neotest)

| キー | 効果 |
|------|------|
| `<leader>tt` | テスト実行 |
| `<leader>tf` | ファイルのテスト実行 |
| `<leader>td` | テストデバッグ |
| `<leader>ts` | テストサマリーをトグル |
| `<leader>to` | テスト出力を表示 |
| `<leader>tO` | テスト出力パネルをトグル |
| `<leader>tS` | テストを停止 |

### REST API (rest.nvim)

HTTPファイル内で使用:

| キー | 効果 |
|------|------|
| `<leader>rr` | リクエスト実行 |
| `<leader>rp` | リクエストプレビュー |
| `<leader>rl` | 最後のリクエストを再実行 |

---

## 💻 ターミナル

### ToggleTerm

| キー | 効果 |
|------|------|
| `<C-\>` | ターミナルをトグル |
| `<leader>tf` | フローティングターミナル |
| `<leader>th` | 水平分割ターミナル |
| `<leader>tv` | 垂直分割ターミナル |
| `<leader>tn` | Node.js REPL |
| `<leader>tp` | Python REPL |

#### ターミナル内のキーバインド

| キー | 効果 |
|------|------|
| `<Esc>` | ノーマルモードへ |
| `jk` | ノーマルモードへ |
| `<C-h>` | 左のウィンドウへ |
| `<C-j>` | 下のウィンドウへ |
| `<C-k>` | 上のウィンドウへ |
| `<C-l>` | 右のウィンドウへ |

---

## 🎨 UI・表示

### Treesitter (構文解析)

| キー | 効果 |
|------|------|
| `gnn` | 選択開始 |
| `grn` | ノードを拡大 |
| `grc` | スコープを拡大 |
| `grm` | ノードを縮小 |
| `]m` | 次の関数へ |
| `[m` | 前の関数へ |
| `]]` | 次のクラスへ |
| `[[` | 前のクラスへ |

### テキストオブジェクト

| キー | 効果 |
|------|------|
| `af` | 関数全体を選択 (outer) |
| `if` | 関数内部を選択 (inner) |
| `ac` | クラス全体を選択 (outer) |
| `ic` | クラス内部を選択 (inner) |
| `ab` | ブロック全体を選択 (outer) |
| `ib` | ブロック内部を選択 (inner) |
| `aa` | パラメータ全体を選択 (outer) |
| `ia` | パラメータ内部を選択 (inner) |

---

## 🔍 補完・スニペット

### nvim-cmp (補完)

挿入モードで:

| キー | 効果 |
|------|------|
| `<C-n>` | 次の候補 |
| `<C-p>` | 前の候補 |
| `<C-d>` | ドキュメントを下スクロール |
| `<C-f>` | ドキュメントを上スクロール |
| `<C-Space>` | 補完を手動起動 |
| `<CR>` | 補完を確定 |
| `<Tab>` | 次の候補 / スニペット展開 |
| `<S-Tab>` | 前の候補 / スニペットジャンプ |

---

## 📚 ヘルプ・情報

### Which-key

`<leader>` を押すと自動的にキーバインド一覧が表示されます。

### カスタムコマンド

| コマンド | 効果 |
|---------|------|
| `:SearchFiles <pattern>` | ファイルからパターンを検索 |
| `:SearchReplace <pattern> <replacement> [file_mask]` | パターンを検索・置換 |
| `:OilToggleAutoPreview` | Oil自動プレビューをトグル |
| `:OilSetDebounceDelay <ms>` | Oilデバウンス遅延を設定 |
| `:OilShowConfig` | Oil設定を表示 |
| `:OilPreviewCurrent` | Oilで現在のアイテムをプレビュー |

---

## 🛠️ プラグイン管理

### Lazy.nvim

| コマンド | 効果 |
|---------|------|
| `:Lazy` | プラグインマネージャーを開く |
| `:Lazy update` | プラグインを更新 |
| `:Lazy sync` | プラグインを同期 |
| `:Lazy clean` | 未使用プラグインを削除 |
| `:Lazy check` | アップデートを確認 |

---

## 📝 備考

- このドキュメントは設定ファイルから自動生成されています
- コマンドの詳細は `:help <command>` で確認できます
- カスタムコマンドを追加した場合は、このドキュメントも更新してください

**最終更新**: 2025年10月20日
