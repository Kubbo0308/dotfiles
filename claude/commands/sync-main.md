# Sync Main

Mainブランチに同期してセッションをリセットする準備をします。

## Process

1. **変更状況の確認**
   ```bash
   git status
   ```

2. **変更がある場合、ユーザーに選択肢を提示**

   AskUserQuestionツールを使って以下の選択肢を提示:
   - **stash**: 変更を一時退避 (`git stash push -m "auto-stash before sync-main"`)
   - **commit**: その場でコミット（コミットメッセージを確認）
   - **cancel**: 操作を中止

3. **選択に応じた処理**
   - stash選択時: `git stash push -m "auto-stash before sync-main: $(date +%Y-%m-%d_%H:%M:%S)"`
   - commit選択時: 変更内容を確認し、適切なコミットメッセージでコミット
   - cancel選択時: 処理を中止してメッセージを表示

4. **mainブランチに切り替え**
   ```bash
   git checkout main
   ```

5. **最新を取得**
   ```bash
   git pull
   ```

6. **完了メッセージ**
   - 現在のブランチを表示
   - stashした場合は復元コマンドを案内: `git stash pop`

## Usage

```
/sync-main
```

Then run `/clear` to start a fresh session.

## Notes

- 未コミットの変更がある場合は必ずユーザーに確認を取る
- 強制的な操作は行わない
- stashした内容は `git stash list` で確認可能
