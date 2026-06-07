#!/bin/bash
# session-digest.sh — SessionStart hook.
# Surfaces pending proposals and recent unreviewed lessons as additionalContext,
# so the self-improving loop is visible at the start of every session.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib/harness-common.sh"
harness_init

PCOUNT="$(proposal_count)"

# Build a human-readable digest. Keep it short to avoid context bloat.
DIGEST=""
if [ "$PCOUNT" -gt 0 ]; then
  DIGEST="🪄 Harness: ${PCOUNT} pending change proposal(s) await review in ~/.claude/harness/proposals/:"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    bn="$(basename "$f")"
    title="$(grep -m1 '^# ' "$f" 2>/dev/null | sed 's/^# //')"
    DIGEST="${DIGEST}\n  - ${title:-$bn} ($bn)"
  done < <(find "$HARNESS_PROPOSALS" -maxdepth 1 -name '*.md' 2>/dev/null | sort)
  DIGEST="${DIGEST}\nRun /evolve to review and apply or discard them."
fi

# Accumulated negative tool feedback → surface /evolve even when no proposal is queued.
# Event-driven (not time-based): nudges once enough "bad" outcomes pile up.
EVOLVE_THRESHOLD="${HARNESS_EVOLVE_THRESHOLD:-3}"
if [ "$PCOUNT" -eq 0 ] && [ -f "$USAGE_FILE" ]; then
  BAD="$(grep -c '"outcome":"bad"' "$USAGE_FILE" 2>/dev/null || true)"
  if [ "${BAD:-0}" -ge "$EVOLVE_THRESHOLD" ]; then
    DIGEST="${DIGEST}\n🛠️ Harness: ${BAD} negative tool-feedback signal(s) accumulated. Run /evolve to improve the affected skills/agents/commands."
  fi
fi

# Recent lessons captured but possibly not yet distilled into rules.
if [ -f "$LESSONS_FILE" ]; then
  RECENT="$(tail -n 3 "$LESSONS_FILE" 2>/dev/null | jq -r '.summary // empty' 2>/dev/null || true)"
  if [ -n "$RECENT" ]; then
    DIGEST="${DIGEST}\n📒 Recent lessons on file (run /reflect to consolidate):"
    while IFS= read -r line; do
      [ -n "$line" ] && DIGEST="${DIGEST}\n  - ${line}"
    done <<< "$RECENT"
  fi
fi

if [ -z "$DIGEST" ]; then
  exit 0
fi

# Emit as SessionStart additionalContext.
CTX="$(printf '%b' "$DIGEST")"
jq -n --arg ctx "$CTX" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'
