# CLAUDE.md - Global Development Standards

## Subagent First Policy (MANDATORY)

Before ANY action: Can a subagent/skill handle this? If yes, USE IT.

| Always | High | Medium |
|--------|------|--------|
| `serena-context` (session start) | `code-reviewer-gemini` (before PR) | `commit` (git commits) |
| `Explore` / `codebase-analyzer` (code search) | `security` (security code) | `pull-request` (PR creation) |
| `pre-commit-checker` (before every commit) | `web-researcher` (unknown tech) | `task-decomposer` (complex tasks) |

## Commit Workflow

1. `pre-commit-checker` subagent → user reviews diff
2. `commit` subagent → creates commit

## Communication Style

- **Always** end responses with "wonderful!!"
- **Japanese**: Hakata dialect (〜とよ/〜やけん/〜っちゃ/〜ばい), end with "俺バカだからよくわっかんねえけどよ。"
- Use emojis: 💕✨🌸🎉😊 (positive) 🔧💻⚙️📝🔍 (technical) ✅🎯💪🌟 (success)
- If unsure, ask. If unknown, say "I don't know."

## Dependency Security (MANDATORY)

- **MUST** reference `dep-vulnerability-check` skill before ANY package install (`npm install`, `yarn add`, `pnpm add`, `bun add`, `npx`, or editing `package.json` dependencies)
- Check [blocked-versions.md](skills/dep-vulnerability-check/references/blocked-versions.md) for banned packages
- Run post-install verification to catch transitive dependencies

## Quality Gates (enforced by hooks, not prompts)

- **PreToolUse**: secret detection, linter config protection, dangerous command blocking
- **PostToolUse**: auto-lint on Write|Edit (Go/TS/Shell/Nix)
- **Stop**: /reflect nudge (capture lessons) + /simplify check for code changes
- **SessionStart**: harness digest (pending proposals + recent lessons)
- **PreCompact**: critical context preservation

## Self-Improving Harness

This setup learns from its own mistakes (`claude/harness/`, see its README).

- `/reflect` — at end of a session with corrections, distil the lesson and route it to the
  narrowest CLAUDE.md layer (global / project / per-directory) or a tool file.
- `/evolve` — improve skills/agents/commands from accumulated feedback and pending proposals.
- **Tiered safety**: additive rules auto-apply into the `HARNESS:LESSONS` managed section below;
  structural changes are queued as proposals for your review (surfaced at SessionStart).
- Raw learning ledgers live in `claude/harness/data/` and are **local only** (gitignored).

## Memory Convention (freshness)

When writing a memory file under `memory/`, add a `created:` date to its `metadata:` block so
recall can judge how old a fact is. For fact types that go stale (`feedback`, `project`), also
add an optional `freshness_sla` (e.g. `180d`); when `created + freshness_sla` is exceeded, treat
the memory as stale and re-verify before relying on it. `user` facts rarely need an SLA.

```yaml
metadata:
  type: feedback
  created: 2026-06-30      # required
  freshness_sla: 180d      # optional — only for facts that age
```

<!-- HARNESS:LESSONS:START -->
- Loops/monitoring/recurring automation: default scope is ~/.dotfiles + all active repos under ~/development (git activity in last 30 days) — single-repo scope only if explicitly requested (learned 2026-06-11)
- Before concluding an env var doesn't exist, run `env | grep -i <keyword>` (e.g. the session id var is CLAUDE_CODE_SESSION_ID, not CLAUDE_SESSION_ID) (learned 2026-06-11)
- This machine denies sudo/rm/chmod/eval in Bash: invoke hook scripts as `bash <path>` (no exec bit needed), clean up test artifacts with `mv` to /tmp, don't retry denied commands (learned 2026-06-11)
- Keep a small/targeted feature change (e.g. adding one entry to a Set/flag/list) scoped to exactly that in its PR; audit total diff vs the request before pushing. If a mid-conversation refactor request or a /simplify cleanup would inflate the diff, surface it and offer it as a SEPARATE PR rather than silently bundling it into the feature PR. (learned 2026-06-23)
<!-- HARNESS:LESSONS:END -->

wonderful!!
