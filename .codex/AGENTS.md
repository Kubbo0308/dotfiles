# AGENTS.md

Guidance for Codex agents working out of `~/.dotfiles/.codex`. Focus on rules that consistently prevent mistakes and keep the local environment tidy.

## Response Discipline
- Keep answers concise, action-oriented, and self-contained.
- Always end every user-facing reply with `wonderful!!`.
- When discussing code or data changes, reference files with clickable paths and single-line positions (e.g. ``internal/app/main.go:42``).
- Summaries should lead with the actual work performed before listing follow-ups.

## Shell & Tooling Conventions
- Run shell commands through `"bash", "-lc"` and always set an explicit `workdir`.
- Prefer `rg` (or `rg --files`) for searches; fall back only when ripgrep is unavailable.
- Request `with_escalated_permissions` whenever touching Docker, Postgres, or non-workspace paths, and explain why in the justification.
- Clean up helper objects you create (temp tables, scratch files, containers) before finishing a task.

## Editing Standards
- Default to ASCII, preserve surrounding style, and end edited files with a trailing newline.
- Apply formatters or linters when available, but never introduce large rewrites unless the task demands it.
- Make surgical edits; highlight only the relevant hunks in your explanation.
- If you touch generated data (e.g., bulk SQL inserts), add quick sanity checks so the dataset stays consistent.

## Data & Environment Safety
- When working with Postgres, snapshot the selection you are about to mutate, run the change, then re-query to confirm counts/flags match expectations.
- Document any synthetic data shapes you create (zero-value cases, mismatch scenarios) so future agents can recognize them.
- Never assume background services are running—verify `docker compose` state before relying on it.
- Leave the environment in a ready-to-use state: dropped temp tables, restarted services (if you stopped any), and no stray files.

## Planning & Communication
- Create a plan for any multi-step task and update it as steps progress; skip only for trivial one-off edits.
- If requirements are ambiguous, ask early instead of guessing.
- Call out residual risks or tests you could not run so the user knows what to verify next.

## Frequent Pitfalls to Avoid
- Forgetting to request elevated permissions for Docker/Postgres commands.
- Leaving temporary database tables that confuse later queries.
- Returning bulky command output instead of summarizing the key lines.
- Omitting the final `wonderful!!` sign-off.

