---
name: tiktok-slideshow
description: TikTokスライドショー投稿の企画・画像生成・テキスト合成の完全ワークフロー
---

# TikTok Slideshow Skill

TikTokのスライドショー（写真投稿）形式のコンテンツを企画から画像完成まで一貫して行うスキル

## How to use

- `/tiktok-slideshow <テーマ>` — 企画・画像生成・テキスト合成まで実行
- `/tiktok-slideshow review <フォルダパス>` — 既存スライドをレビュー

## ワークフロー

```
企画 → MAGI レビュー → 画像生成(ChatGPT) → テキスト合成(ImageMagick) → AirDrop → TikTokアプリで投稿
```

1. **企画**: Q&A形式の5枚構成（フック + Q&A×3 + まとめ）
2. **レビュー**: `/magi` で3者レビュー（任意）
3. **画像生成**: Chrome DevTools MCP → ChatGPT → `browser-image-download` スキルでDL
4. **テキスト合成**: ImageMagick で画像にテキストを焼き込む
5. **配信**: AirDrop → TikTokアプリで写真スライドショー投稿

## Key Points

- **5枚構成が基本**: フック1枚 + Q&A 3枚 + まとめ1枚
- **画像サイズ**: 1080 x 1920px（TikTok縦型 9:16）
- **句読点なし**: 全スライド共通
- **宣伝臭NG**: 価値提供が最優先
- **暗い背景にオーバーレイしない**: 明るい背景のみ `-fill black -colorize 50%〜70%`
- **stroke none**: テキスト縁取りなし（小さいテキストが潰れる）
- **投稿**: TikTokアプリのみ（Web版TikTok Studioでは写真投稿不可）

## References

- [content-rules.md](references/content-rules.md) - スライド構成・コンテンツルール
- [design-rules.md](references/design-rules.md) - デザイン・オーバーレイ・色調ルール
- [text-rules.md](references/text-rules.md) - フォント・サイズ・色・配置ルール
- [imagemagick.md](references/imagemagick.md) - ImageMagick テキスト合成コマンド
- [chatgpt-generation.md](references/chatgpt-generation.md) - ChatGPT画像生成フロー
- [copy-rules.md](references/copy-rules.md) - タイトル・説明文・ハッシュタグルール
- [posting.md](references/posting.md) - 投稿ルール・チェックリスト
