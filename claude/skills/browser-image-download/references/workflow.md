# ダウンロードワークフロー

## 1枚のダウンロード手順

### Step 1: DLボタンクリック

```
mcp__chrome-devtools__click でダウンロードボタンの uid をクリック
```

### Step 2: 一時ファイル待ち & コピー

```bash
sleep 4
TMPFILE=$(find ~/Downloads -maxdepth 1 -name ".com.google.Chrome*" -type f)
cp "$TMPFILE" "${DEST_DIR}/${FILENAME}"
```

- 4秒待ってから一時ファイルを探す
- 見つからない場合はもう少し待つ（最大10秒）
- 複数残っている場合は `-mmin -1` で直近のみ取得

### Step 3: ダイアログキャンセル

[applescript.md](applescript.md) のスクリプトを実行

### Step 4: 次の画像へ（Step 1に戻る）

## 複数枚の例（5枚）

```bash
DEST="/path/to/output/folder"

# Slide 1
# → mcp__chrome-devtools__click uid
sleep 4
TMPFILE=$(find ~/Downloads -maxdepth 1 -name ".com.google.Chrome*" -type f)
cp "$TMPFILE" "${DEST}/slide1.png"
# → AppleScript でキャンセル

# Slide 2〜5 も同様に繰り返す
```

## 注意事項

- **一時ファイルの寿命**: ダイアログをキャンセルすると一時ファイルは削除される 必ずキャンセル前にコピーすること
- **複数の一時ファイル**: 前回の残骸の可能性がある 事前にクリーンアップするか `-mmin -1` で絞り込む
- **ダイアログの場所**: シートはwindow 1ではなくwindow 2に出ることがある 全windowをループして探す
