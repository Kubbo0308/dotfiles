# ImageMagick テキスト合成

## 前提ツール

- `brew install imagemagick`

## フォント変数

```bash
FONT="/System/Library/Fonts/ヒラギノ角ゴシック W7.ttc"
FONT_MID="/System/Library/Fonts/ヒラギノ角ゴシック W5.ttc"
FONT_Q="/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc"
```

## 基本コマンド構造

```bash
magick "${INPUT}" \
  -resize 1080x1920^ -gravity center -extent 1080x1920 \
  # デフォルトで60%暗くする（ChatGPT生成画像は暗め指定でも明るいことが多い）
  -fill black -colorize 60% \
  # Qテキスト（ティール）
  -font "${FONT}" -fill "#14B8A6" -stroke none -gravity center \
  -pointsize 60 -annotate +0-550 "Q  質問文" \
  # Aテキスト（白 太字）
  -font "${FONT}" -fill white -stroke none \
  -pointsize 86 -annotate +0-400 "A  回答1行目" \
  -pointsize 86 -annotate +0-290 "回答2行目" \
  # 説明文（白）
  -font "${FONT_MID}" -fill white -stroke none \
  -pointsize 54 -annotate +0-120 "説明文1行目" \
  # 強調文（ティール 大きめ）
  -font "${FONT}" -fill "#14B8A6" \
  -pointsize 60 -annotate +0+170 "強調したいフレーズ" \
  "${OUTPUT}"
```
