# Diff Processing Reference

Processing `gh pr diff` output to get accurate line numbers for inline comments.

## The Line Number Problem

When posting inline comments via GitHub API, you need the exact line number in the new file. The raw diff output doesn't show these numbers directly, making it difficult to target the correct line.

## Solution: AWK Script for Line Numbers

This script processes diff output to show line numbers matching GitHub's web interface:

```bash
gh pr diff NUMBER --repo OWNER/REPO | awk '
  /^diff --git/ {
    # Extract filename from diff header
    match($0, /b\/(.+)$/, arr)
    current_file = arr[1]
    in_hunk = 0
    next
  }
  /^@@/ {
    # Parse hunk header: @@ -old_start,old_count +new_start,new_count @@
    match($0, /\+([0-9]+)(,([0-9]+))?/, arr)
    new_line = arr[1]
    in_hunk = 1
    print "--- " current_file " ---"
    print $0
    next
  }
  in_hunk {
    if (/^-/) {
      # Deleted line (no line number in new file)
      print "     - " substr($0, 2)
    } else if (/^\+/) {
      # Added line
      printf "%4d + %s\n", new_line, substr($0, 2)
      new_line++
    } else if (/^ /) {
      # Context line
      printf "%4d   %s\n", new_line, substr($0, 2)
      new_line++
    }
  }
'
```

## Output Format

```
--- src/main.go ---
@@ -10,6 +10,8 @@ func main() {
  10   func main() {
  11       config := loadConfig()
  12 +     logger := setupLogger(config)
  13 +     defer logger.Close()
  14       app := NewApp(config)
       - oldFunction()
  15       app.Run()
  16   }
```

### Line Markers

| Marker | Meaning | Has Line Number |
|--------|---------|-----------------|
| `+` | Added line | Yes (new file line) |
| `-` | Deleted line | No |
| (space) | Context line | Yes (new file line) |

## Understanding Hunk Headers

The `@@ -10,6 +12,8 @@` header means:
- `-10,6`: Starting at line 10 in old file, 6 lines of context
- `+12,8`: Starting at line 12 in new file, 8 lines of context

The AWK script extracts the `+12` part to track new file line numbers.

## Using Line Numbers for Comments

After processing, use the displayed line number for the `line` parameter:

```bash
# If the AWK output shows:
#   42 + newVariable := "value"

# Post comment on that line:
gh api repos/OWNER/REPO/pulls/NUMBER/comments \
  --method POST \
  -f body="Consider using a constant here" \
  -f commit_id="$(gh api repos/OWNER/REPO/pulls/NUMBER --jq '.head.sha')" \
  -f path="src/main.go" \
  -F line=42 \
  -f side=RIGHT
```

## Side Parameter

| Value | Use Case |
|-------|----------|
| `RIGHT` | Comment on added or modified lines (lines with `+` or context) |
| `LEFT` | Comment on deleted lines (lines with `-`) |

## Compact One-Liner

For quick use in scripts:

```bash
gh pr diff NUMBER --repo OWNER/REPO | awk '/^diff --git/{match($0,/b\/(.+)$/,a);f=a[1];h=0;next}/^@@/{match($0,/\+([0-9]+)/,a);n=a[1];h=1;print"--- "f" ---";print;next}h{if(/^-/)print"     - "substr($0,2);else if(/^\+/){printf"%4d + %s\n",n,substr($0,2);n++}else if(/^ /){printf"%4d   %s\n",n,substr($0,2);n++}}'
```

## Alternative: Per-File Processing

To process a specific file only:

```bash
gh pr diff NUMBER --repo OWNER/REPO -- path/to/file.go | awk '
  /^@@/ {
    match($0, /\+([0-9]+)/, arr)
    new_line = arr[1]
    in_hunk = 1
    print $0
    next
  }
  in_hunk {
    if (/^-/) {
      print "     - " substr($0, 2)
    } else if (/^\+/) {
      printf "%4d + %s\n", new_line, substr($0, 2)
      new_line++
    } else if (/^ /) {
      printf "%4d   %s\n", new_line, substr($0, 2)
      new_line++
    }
  }
'
```
