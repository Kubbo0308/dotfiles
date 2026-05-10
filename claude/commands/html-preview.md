# /html-preview

Convert the previous assistant message (or specified content) into a self-contained rich HTML page, upload it to GCS, and return a signed URL the user can share.

## Steps

1. **Determine the source content (Markdown)**:
   - **Default**: the most recent assistant message in this conversation (the one immediately before the user invoked `/html-preview`).
   - If `$ARGUMENTS` includes `--from-message N` (1-based, counting backwards from the latest), use that older message instead.
   - If `$ARGUMENTS` includes `--content-from-file <path>`, use that file directly (skip step 2).
   - If the most recent assistant message is mostly a single tool-call result (e.g. a long Read/Bash output), prefer the assistant's own narrative text over the raw tool output. Use judgment.

2. **Pipe the content into the CLI via stdin** (using `-f -`) — no temp file needed. The raw markdown identified in step 1 is the body — do NOT reformat, summarize, or wrap. Publish exactly what the user saw.

3. **Determine the title**:
   - First positional argument in `$ARGUMENTS` if quoted: e.g. `/html-preview "週次レポート"` → title = `週次レポート`.
   - If `--title <text>` is in `$ARGUMENTS`, use that.
   - Otherwise infer a concise 3-8 word title from the content's first heading or main subject. Avoid generic titles like "Report" or "Output".

4. **Run the CLI** via Bash, piping the markdown into stdin:
   ```bash
   cat <<'HP_EOF' | html-preview --title "<TITLE>" -f - [pass-through flags]
   <markdown content from step 1>
   HP_EOF
   ```
   - If `html-preview` is not on PATH (wrapper not installed), use the project-local tsx directly:
     ```bash
     cat <<'HP_EOF' | "$HOME/.dotfiles/claude/tools/html-preview/node_modules/.bin/tsx" \
       "$HOME/.dotfiles/claude/tools/html-preview/bin/html-preview.ts" \
       --title "<TITLE>" -f - [pass-through flags]
     <markdown content from step 1>
     HP_EOF
     ```

5. **Pass-through flags** from `$ARGUMENTS` to the CLI:
   - `--expires <N>` — Signed URL validity in days (1-7, default 7)
   - `--allow-secrets` — skip secret detection
   - `--open` — open in browser after upload
   - `--dry-run` — generate locally only, no upload
   - `--slug <text>` — custom URL slug

6. **Show the result** to the user (concise):
   - The signed URL (preserved from CLI stdout)
   - Expiration (preserved)
   - One-line status (e.g. "公開しました ✨")

7. **Cleanup**: nothing to clean — content was piped via stdin.

## Error handling

| Exit code | Meaning | Action |
|---|---|---|
| 0 | Success | Show URL and expiration. |
| 2 | Config missing | Tell the user to run Phase 1 GCP setup. |
| 3 | Secrets detected | The CLI already printed redacted findings to stderr. Show them, then ask: "これら検出は意図的？ `--allow-secrets` で迂回できるけど、本物が混じってないか確認してから判断してね。" |
| 4 | Upload error | The CLI's error message is already user-friendly (auth/network/etc.). Relay it. |
| 5 | Input error | File not found etc. Relay the message. |
| 1 | Generic | Relay the error message. |

## Notes for Claude

- This command publishes content via GCS Signed URL. Anyone with the URL can view it for the validity period (default 7 days, max 7), then GCS auto-deletes after 30 days.
- The bucket is fully private — only signed URLs work.
- If the user seems to want to publish sensitive content, mention the "URL knows it = anyone can view it" model before proceeding.
- Don't add commentary to the content unless the user asks. Publish as-is.

## Arguments

$ARGUMENTS
