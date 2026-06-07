# Reflect — capture failures & distill durable rules

You are running the harness reflection loop. Review THIS session and turn mistakes
into lasting rules. Be honest and specific; skip if nothing durable was learned.

## Step 1 — Scan the session for learning signals

Look for:
- **Corrections**: the user told you to do something differently, said "違う", reverted your change, or re-explained a requirement you missed.
- **Failures**: a command/test failed because of a wrong assumption; you retried the same thing multiple times.
- **Tool feedback**: a skill / sub-agent / slash-command underperformed or gave a wrong-shaped result.
- **Confirmed good patterns**: an approach the user explicitly praised and wants repeated.

If none exist, say "No durable lesson this session" and stop. Do NOT manufacture lessons.

## Step 2 — For each lesson, decide SCOPE (the CLAUDE.md hierarchy)

| Scope | Target file |
|-------|-------------|
| Universal (applies across every project) | `~/.claude/CLAUDE.md` (global) |
| This repository only | `./CLAUDE.md` at the repo root |
| One directory's role/convention | a nested `CLAUDE.md` in that directory (create if useful) |
| A specific tool's behavior | the skill / agent / command file (defer to `/evolve`) |

Routing rule: prefer the **narrowest** scope that fully captures the lesson. Project-specific
details must NOT go global.

## Step 3 — Decide RISK tier (the safety valve)

- **additive** — a new, self-contained rule (a bullet that adds guidance). → auto-apply.
- **structural** — rewording/removing/contradicting an existing rule, or anything touching
  a skill/agent/command body. → write a proposal, do NOT edit directly.

## Step 4 — Record every lesson to the local ledger

For each lesson run:
```bash
bash ~/.claude/harness/scripts/record.sh lesson '{"summary":"<one line>","trigger":"<what happened>","rule":"<the rule to follow next time>","scope":"global|project|tool","target":"<file path or tool name>","risk":"additive|structural"}'
```

## Step 5 — Apply (tiered policy)

- **additive** → write it straight into the managed section:
  ```bash
  bash ~/.claude/harness/scripts/apply-rule.sh --file <target CLAUDE.md> --text "<the rule, one concise line>"
  ```
  (This only ever appends inside the `HARNESS:LESSONS` markers — safe & reversible.)
- **structural** → create `~/.claude/harness/proposals/<short-slug>.md` describing: the problem,
  the exact file + change proposed, and why. It will be surfaced at next SessionStart and applied via `/evolve`.

## Step 6 — Report

Summarise: lessons captured, what was auto-applied (with file), what was queued as a proposal.
Remind the user that proposals need their review.
