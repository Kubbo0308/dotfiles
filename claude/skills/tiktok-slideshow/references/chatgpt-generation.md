# ChatGPT画像生成フロー

## 操作手順

```
1. mcp__chrome-devtools__list_pages で ChatGPT タブを探す
2. mcp__chrome-devtools__navigate_page で https://chatgpt.com/ を開く（新規チャット）
3. mcp__chrome-devtools__take_snapshot で入力欄の uid を取得
4. 1枚ずつ以下を繰り返す:
   a. mcp__chrome-devtools__fill でプロンプトを入力
   b. mcp__chrome-devtools__press_key で Enter 送信
   c. sleep 35 で生成完了を待つ
   d. mcp__chrome-devtools__take_screenshot で結果確認
5. 全枚数生成後 mcp__chrome-devtools__take_snapshot でDLボタンの uid を取得
6. browser-image-download スキルの手順で1枚ずつダウンロード
```

## プロンプトテンプレート

```
TikTokスライドショー用の縦型画像(1080x1920px)を生成してください

{具体的な画像の説明} フォトリアル テキストなし
```

- 2枚目以降は「次のスライド画像をお願いします」で始める
- 全スライド共通の色調・世界観を最初のプロンプトで指定する
