#!/bin/bash
# harness-common.sh — shared helpers for the self-improving harness.
# Source this from any harness script: source "$(dirname "$0")/../lib/harness-common.sh"

# Resolve the harness root regardless of caller location (~/.claude is a symlink).
HARNESS_ROOT="${HARNESS_ROOT:-$HOME/.claude/harness}"
HARNESS_DATA="$HARNESS_ROOT/data"
HARNESS_PROPOSALS="$HARNESS_ROOT/proposals"
LESSONS_FILE="$HARNESS_DATA/lessons.jsonl"
USAGE_FILE="$HARNESS_DATA/usage.jsonl"

# Managed-section markers. Auto-applied lessons live ONLY between these in a CLAUDE.md.
HARNESS_LESSONS_START="<!-- HARNESS:LESSONS:START -->"
HARNESS_LESSONS_END="<!-- HARNESS:LESSONS:END -->"

harness_ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
harness_date() { date -u +"%Y-%m-%d"; }

harness_init() {
  mkdir -p "$HARNESS_DATA" "$HARNESS_PROPOSALS"
}

# append_jsonl <file> <json-object-string>
# Adds .ts automatically; validates JSON with jq before writing.
append_jsonl() {
  local file="$1" obj="$2"
  harness_init
  if ! echo "$obj" | jq empty 2>/dev/null; then
    echo "harness: invalid JSON, not recorded" >&2
    return 1
  fi
  echo "$obj" | jq -c --arg ts "$(harness_ts)" '. + {ts: $ts}' >> "$file"
}

# Ensure a CLAUDE.md has the managed lessons section; create it at EOF if missing.
ensure_lessons_section() {
  local file="$1"
  [ -f "$file" ] || return 1
  if ! grep -qF "$HARNESS_LESSONS_START" "$file"; then
    {
      echo ""
      echo "## Learned Lessons (auto-maintained by harness — additive only)"
      echo ""
      echo "$HARNESS_LESSONS_START"
      echo "$HARNESS_LESSONS_END"
      echo ""
    } >> "$file"
  fi
}

# Count pending proposals.
proposal_count() {
  harness_init
  find "$HARNESS_PROPOSALS" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' '
}
