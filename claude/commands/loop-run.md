---
description: Run one iteration of a loop defined in ~/.claude/LOOP.md (loop engineering, Tier-a): /loop-run <loop-name>
---

# /loop-run — execute one loop iteration

You are the loop orchestrator for this session. The loop to run is
`$ARGUMENTS` (default: `daily-triage` if empty).

## Step 1: Load the loop definition

Read `~/.claude/LOOP.md` and locate the section for this loop. If it does not
exist, list the available loops and stop. Note its `level`, `scope`,
`out_of_scope`, `success_condition`, and report format — they are binding.
Machine-enforced caps live in `~/.claude/loops.json` (the Stop hook reads
`max_iterations` from there, not from anything you write).

## Step 2: Initialise or resume state

State dir: `~/.claude/loops/<loop-name>/`. If `state.json` is missing or its
`status` is not `running`, initialise it; the `.running` marker file is what
arms the Stop hook:

```bash
LOOP=<loop-name>
MAXI=$(jq -r --arg l "$LOOP" '.[$l].max_iterations // 3' ~/.claude/loops.json)
mkdir -p ~/.claude/loops/$LOOP
cat > ~/.claude/loops/$LOOP/state.json <<EOF
{
  "loop": "$LOOP",
  "status": "running",
  "session_id": "${CLAUDE_CODE_SESSION_ID:-}",
  "iteration": 0,
  "max_iterations": $MAXI,
  "last_verdict": "pending",
  "last_feedback": "",
  "stop_hook_blocks": 0,
  "force_stop": false,
  "started_at_epoch": $(date -u +%s),
  "records": []
}
EOF
touch ~/.claude/loops/$LOOP/.running
```

If `status` IS `running` (resuming an interrupted loop), take it over instead:
re-stamp `session_id` with `$CLAUDE_CODE_SESSION_ID`, reset
`stop_hook_blocks` to 0, recreate the `.running` marker, and read
`last_feedback` — the new iteration MUST address it.

## Step 3: Execute ONE iteration (the maker role)

Follow the loop's `scope` and report format from its LOOP.md section exactly.
For **L1 loops this is report-only**: you may write ONLY inside
`~/.claude/loops/<loop-name>/`.

## Step 4: Verify (the checker role — MANDATORY)

Launch the `loop-verifier` subagent (Agent tool) telling it which loop and
what this iteration did. Take its verdict JSON and persist it:

```bash
STATE=~/.claude/loops/$LOOP/state.json
jq --arg v "<verdict>" --arg fb "<feedback>" --arg sum "<one-line summary>" \
   --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   '.last_verdict = $v | .last_feedback = $fb | .iteration += 1 |
    .records += [{"iteration": .iteration, "finished_at": $now, "verdict": $v, "feedback": $fb, "summary": $sum}]' \
   "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
```

You must NEVER write `success` yourself — only relay the verifier's verdict.

## Step 5: End the turn

Report the iteration result and verdict to the user, then end your turn.
The `stop-loop-verifier.sh` Stop hook decides what happens next:

- verdict `continue`/`pending` -> the stop is blocked and you iterate again
  (go back to Step 3 with the verifier's feedback)
- verdict `success`/`escalate`, `max_iterations`, or `force_stop` -> the
  session ends and the hook finalises `status` and removes `.running`

Do not fight the hook: if it blocks your stop, that IS the loop working.
