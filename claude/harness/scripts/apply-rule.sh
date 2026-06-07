#!/bin/bash
# apply-rule.sh — SAFE, additive-only writer for the tiered auto-apply policy.
# Inserts a single bullet into the managed HARNESS:LESSONS section of a CLAUDE.md.
# It NEVER edits anything outside the managed markers, and dedups identical bullets.
# Structural changes must go through proposals/, not this script.
#
# Usage: apply-rule.sh --file <CLAUDE.md> --text "the rule, one line"
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib/harness-common.sh"

FILE="" ; TEXT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --file) FILE="$2"; shift 2 ;;
    --text) TEXT="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$FILE" ] || [ -z "$TEXT" ]; then
  echo "usage: apply-rule.sh --file <CLAUDE.md> --text \"...\"" >&2
  exit 1
fi
if [ ! -f "$FILE" ]; then
  echo "apply-rule: target not found: $FILE" >&2
  exit 1
fi

# Collapse to a single line; strip leading bullet markers the caller may have added.
TEXT="$(printf '%s' "$TEXT" | tr '\n' ' ' | sed -E 's/^[[:space:]]*[-*][[:space:]]*//; s/[[:space:]]+$//')"
BULLET="- ${TEXT} (learned $(harness_date))"

ensure_lessons_section "$FILE"

# Dedup: skip if the same lesson text already exists in the section.
if grep -qF "$TEXT" "$FILE"; then
  echo "apply-rule: already present, skipped"
  exit 0
fi

# Insert the bullet immediately before the END marker (additive only).
TMP="$(mktemp)"
awk -v end="$HARNESS_LESSONS_END" -v bullet="$BULLET" '
  $0 ~ end && !done { print bullet; done=1 }
  { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "apply-rule: added to $FILE"
