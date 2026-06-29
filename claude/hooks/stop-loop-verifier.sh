#!/bin/bash
# Stop hook: loop-engineering continuation gate (Tier-a, see ~/.claude/LOOP.md).
#
# Idle sessions: no <loop>/.running marker exists -> exits 0 with zero
# subprocess spawns. /loop-run creates the marker; finish() removes it.
#
# Loop sessions: blocks session exit until the verifier verdict terminates
# the loop, a cap is hit, or force_stop is set in the loop's state.json.
#
# Ownership: /loop-run stamps session_id from $CLAUDE_CODE_SESSION_ID at
# init. If the stamp is empty (env var unavailable), the first session that
# stops within CLAIM_WINDOW_SECS of loop start claims the loop as fallback.
# Other sessions are never blocked.

LOOPS_DIR="$HOME/.claude/loops"
LOOPS_CONFIG="$HOME/.claude/loops.json"
CLAIM_WINDOW_SECS=1800

# Zero-cost idle check (shell builtins only).
MARKER_FOUND=""
for m in "$LOOPS_DIR"/*/.running; do
  [ -e "$m" ] && MARKER_FOUND=1 && break
done
[ -n "$MARKER_FOUND" ] || exit 0

INPUT=$(cat)
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty')
[ -n "$SESSION_ID" ] || exit 0

STATE_FILE=""
for m in "$LOOPS_DIR"/*/.running; do
  [ -e "$m" ] || continue
  f="$(dirname "$m")/state.json"
  if [ ! -f "$f" ]; then
    rm -f "$m" # orphan marker: no state file
    continue
  fi
  IFS=$'\t' read -r STATUS OWNER STARTED <<< \
    "$(jq -r '[.status // "", .session_id // "", (.started_at_epoch // 0)] | @tsv' "$f")"
  if [ "$STATUS" != "running" ]; then
    rm -f "$m" # self-heal: loop already finalised
    continue
  fi
  if [ "$OWNER" = "$SESSION_ID" ]; then
    STATE_FILE="$f"
    break
  fi
  if [ -z "$OWNER" ]; then
    NOW=$(date -u +%s)
    if [ $((NOW - STARTED)) -le "$CLAIM_WINDOW_SECS" ]; then
      jq --arg sid "$SESSION_ID" '.session_id = $sid' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
      STATE_FILE="$f"
      break
    fi
  fi
done
[ -n "$STATE_FILE" ] || exit 0

MARKER="$(dirname "$STATE_FILE")/.running"

IFS=$'\t' read -r LOOP_NAME ITERATION VERDICT FORCE_STOP BLOCKS MAX_ITER <<< \
  "$(jq -r '[.loop // "unknown", .iteration // 0, .last_verdict // "pending",
             .force_stop // false, .stop_hook_blocks // 0, .max_iterations // 3] | @tsv' "$STATE_FILE")"

# The iteration cap comes from committed config when available; the value in
# agent-writable state.json is only a fallback.
if [ -f "$LOOPS_CONFIG" ]; then
  CFG_MAX=$(jq -r --arg l "$LOOP_NAME" '.[$l].max_iterations // empty' "$LOOPS_CONFIG")
  [ -n "$CFG_MAX" ] && MAX_ITER=$CFG_MAX
fi
BLOCK_CAP=$((MAX_ITER * 2)) # stall backstop: blocked stops with no iteration progress

finish() {
  jq --arg s "$1" --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '.status = $s | .finished_at = $now' \
    "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  rm -f "$MARKER"
  printf '{"systemMessage":"[loop:%s] %s"}\n' "$LOOP_NAME" "$2"
  exit 0
}

# Kill switch always wins.
[ "$FORCE_STOP" = "true" ] && finish "stopped" "force_stop set - loop halted by human."

# Terminal verdicts end the loop regardless of caps: success on the final
# iteration must finalise as success, not escalated.
case "$VERDICT" in
  success)
    finish "success" "verifier verdict: success after $ITERATION iteration(s). Loop complete."
    ;;
  escalate | blocked)
    finish "escalated" "verifier verdict: $VERDICT - human attention required."
    ;;
esac

# No-progress / stuck detection: a loop that returns the SAME `continue`
# feedback two iterations running is not converging - escalate to a human
# instead of burning the remaining iteration budget. Enforced here (machine
# layer), not left to the verifier's judgment alone.
STUCK=$(jq -r '(.records // []) as $r |
  if ($r | length) >= 2
     and ($r[-1].verdict == "continue") and ($r[-2].verdict == "continue")
     and ($r[-1].feedback == $r[-2].feedback) and (($r[-1].feedback // "") != "")
  then "stuck" else "" end' "$STATE_FILE")
[ "$STUCK" = "stuck" ] && finish "escalated" "stuck loop: identical 'continue' feedback two iterations running - no progress, escalating to human."

# Caps apply only to non-terminal verdicts.
[ "$BLOCKS" -ge "$BLOCK_CAP" ] && finish "escalated" "stop-hook block cap ($BLOCK_CAP) reached - escalating to human."
[ "$ITERATION" -ge "$MAX_ITER" ] && finish "escalated" "max_iterations ($MAX_ITER) reached without success - escalating to human."

# verdict pending/continue -> demand another iteration.
REASON="[loop:$LOOP_NAME] iteration $ITERATION/$MAX_ITER, last_verdict=$VERDICT. Loop not finished: (1) if this iteration's work is unverified, run the loop-verifier subagent and write its verdict to .last_verdict in $STATE_FILE; (2) increment .iteration; (3) on verdict=continue start the next iteration per ~/.claude/LOOP.md. A success/escalate verdict ends the loop at the next stop."
jq '.stop_hook_blocks = ((.stop_hook_blocks // 0) + 1)' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
jq -cn --arg reason "$REASON" '{decision: "block", reason: $reason}'
exit 0
