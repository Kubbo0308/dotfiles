# Self-Improving Harness

A feedback loop that turns this session's mistakes into lasting rules, and improves the
tools (skills / sub-agents / slash-commands) over time — under a tiered safety policy so it
never silently corrupts your config.

## The four pillars

1. **Failures → rules.** `/reflect` reviews a session for corrections/failures and distils
   durable rules.
2. **Context via the CLAUDE.md hierarchy.** Each rule is routed to the *narrowest* scope that
   fits: global (`~/.claude/CLAUDE.md`), repo (`./CLAUDE.md`), or a nested per-directory
   `CLAUDE.md` describing that directory's role.
3. **Tools evolve.** `/evolve` + the `harness-evolver` agent improve skill/agent/command
   definitions from accumulated usage feedback.
4. **Hooks drive it.** `SessionStart` surfaces pending work; `Stop` nudges you to `/reflect`.

## Tiered safety valve (the important part)

| Tier | What | Action |
|------|------|--------|
| **additive** | a new self-contained rule / guardrail bullet | auto-applied into the `HARNESS:LESSONS` managed markers (reversible) |
| **structural** | rewording/removing an existing rule, or editing a tool body | queued as a proposal in `proposals/` → surfaced at next SessionStart → you approve via `/evolve` |

Auto-edits ONLY ever happen between the `<!-- HARNESS:LESSONS:START -->` /
`<!-- HARNESS:LESSONS:END -->` markers. Nothing else is touched automatically.

## Layout

```
harness/
├── README.md                 # this file (committed)
├── lib/harness-common.sh     # shared helpers (committed)
├── scripts/
│   ├── record.sh             # append a lesson/usage signal to the local ledger
│   ├── apply-rule.sh         # safe additive writer for a CLAUDE.md managed section
│   └── session-digest.sh     # SessionStart: surface proposals + recent lessons
├── data/                     # LOCAL ONLY (gitignored): lessons.jsonl, usage.jsonl
└── proposals/                # LOCAL ONLY (gitignored): pending structural changes
```

Scripts are invoked as `bash <script>` (the repo blocks `chmod`, so they don't rely on the
exec bit).

## Commands

- `/reflect` — capture this session's lessons, auto-apply additive ones, queue structural ones.
- `/evolve` — review usage feedback + proposals, improve tool definitions.

## Data model

`data/lessons.jsonl` — one lesson per line:
```json
{"summary","trigger","rule","scope":"global|project|tool","target","risk":"additive|structural","ts"}
```
`data/usage.jsonl` — one tool-usage outcome per line:
```json
{"kind":"skill|agent|command","name","outcome":"good|bad","note","ts"}
```

## Privacy / git

Raw ledgers and proposals are **gitignored** (they may mention project internals). Only the
distilled rules (CLAUDE.md edits) and the harness machinery are committed. Persist changes with
the `pre-commit-checker` + `commit` subagents as usual.
