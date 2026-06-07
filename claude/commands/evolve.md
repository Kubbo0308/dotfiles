# Evolve — improve skills / agents / commands from accumulated feedback

You are running the harness evolution loop. Use accumulated usage feedback and pending
proposals to improve the tools themselves (skills, sub-agents, slash-commands), under the
same tiered safety policy as `/reflect`.

## Step 1 — Gather inputs

First, capture any tool underperformance from the CURRENT conversation (the Stop gate may have
sent you here). For each skill/agent/command that misfired this session, record it so it persists
and feeds the cross-session backstop:
```bash
bash ~/.claude/harness/scripts/record.sh usage '{"kind":"skill|agent|command","name":"<tool>","outcome":"bad","note":"<what went wrong>"}'
```

Then read the accumulated inputs:
```bash
# Pending structural proposals (highest priority — the user may have queued these)
ls -1 ~/.claude/harness/proposals/*.md 2>/dev/null

# Usage feedback ledger (local only)
[ -f ~/.claude/harness/data/usage.jsonl ] && tail -n 50 ~/.claude/harness/data/usage.jsonl

# Which tools have repeated negative feedback?
[ -f ~/.claude/harness/data/usage.jsonl ] && jq -r 'select(.outcome=="bad") | "\(.kind)/\(.name)"' ~/.claude/harness/data/usage.jsonl 2>/dev/null | sort | uniq -c | sort -rn
```

## Step 2 — Triage

Build a short list of candidate improvements:
1. Every pending proposal in `proposals/`.
2. Any skill/agent/command with **2+ "bad" outcomes** in the usage ledger.

If the list is empty, report "Nothing to evolve" and stop.

## Step 3 — For each candidate, delegate analysis

Use the `harness-evolver` sub-agent to analyse the specific tool file against its feedback
and produce a concrete, minimal diff. Pass it the tool's file path and the relevant feedback
notes / proposal content.

## Step 4 — Apply under the tiered policy

- **additive & low-risk** (e.g. adding a clarifying constraint, an example, a guardrail bullet):
  apply the edit directly with the Edit tool, then briefly note what changed.
- **structural** (rewriting responsibilities, changing tools/model frontmatter, removing behavior):
  do NOT apply silently. Present the proposed diff to the user with AskUserQuestion (apply / revise / discard).

## Step 5 — Clean up & report

- For each applied proposal, delete its file from `~/.claude/harness/proposals/`.
- Archive the processed usage feedback so the SessionStart `/evolve` nudge resets (it
  triggers once `~/.claude/harness/data/usage.jsonl` holds ≥3 "bad" outcomes):
  ```bash
  [ -f ~/.claude/harness/data/usage.jsonl ] && cat ~/.claude/harness/data/usage.jsonl >> ~/.claude/harness/data/usage-archive.jsonl && : > ~/.claude/harness/data/usage.jsonl
  ```
- Summarise: what was changed, what still needs the user's decision.
- Remind the user to run the `commit` + `pre-commit-checker` subagents to persist changes,
  since `~/.claude` is git-managed in the dotfiles repo.
