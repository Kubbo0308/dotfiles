# ダイアログキャンセル AppleScript

## 保存ダイアログをキャンセル

全ウィンドウをループしてシート（ダイアログ）を探し、キャンセルボタンをクリックする。

```bash
osascript -e '
tell application "System Events"
  tell process "Google Chrome"
    repeat with i from 1 to (count of windows)
      if (count of sheets of window i) > 0 then
        tell sheet 1 of window i
          tell splitter group 1
            click button "キャンセル"
          end tell
        end tell
      end if
    end repeat
  end tell
end tell
'
```

## やってはいけないこと

- **Cmd+Shift+G**: 「フォルダの場所を入力」ダイアログが開くが、フォーカスがずれて後続操作が壊れる
- **Cmd+A → テキスト入力**: ファイル名フィールド以外にフォーカスが当たる場合がある
- **ファイル名にフルパスを設定**: macOSは`/`を`:`に変換するため、意図しないファイル名になる
- **key code 53 (Escape)**: ダイアログは閉じるが一時ファイルが消える場合がある。ボタンクリックの方が確実
