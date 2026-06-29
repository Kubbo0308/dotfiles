# LOOP.md — Loop Definitions (Loop Engineering, Tier-a)

Loops that may run on this machine, in the sense of
[loop-engineering](https://github.com/cobusgreyling/loop-engineering):
a loop = harness + schedule + state + verification chain. The human designs
the loop; the loop prompts the agent.

## Ground rules (apply to every loop)

- **L1 before L2 before L3.** A new loop runs report-only (L1) until its triage
  quality is proven over 1-2 weeks. Never start a loop at auto-fix level.
- **Maker/checker split.** The session doing the work never grades itself.
  The `loop-verifier` subagent issues the verdict; default stance is REJECT.
- **Hard caps.** Every loop's `max_iterations` lives in the committed
  `~/.claude/loops.json` — the Stop hook (`hooks/stop-loop-verifier.sh`)
  reads it from there, NOT from agent-writable runtime state. The hook also
  caps consecutive blocked stops at 2x max_iterations, so a loop can never
  spin forever.
- **Stuck detection (no-progress).** The Stop hook escalates automatically when
  the verifier returns the *same* `continue` feedback two iterations running —
  a loop that is not converging hands off to a human instead of burning its
  remaining budget. This is enforced at the machine layer, not left to the
  verifier's judgment. (See *Design rationale* below.)
- **Cost budget.** A loop's de-facto token budget is `max_iterations` × its
  per-iteration cost. Each loop carries a `cost_tier` (low / med / high); the
  human sizes `max_iterations` and schedule frequency against it. Agentic loops
  run ~4x (single-agent) to ~15x (multi-agent) the tokens of a plain chat, so
  treat cost as a first-class design input, not an afterthought.
- **Context budget.** Iterations of one `/loop-run` share a single session, so
  context *accumulates* across them — caps are deliberately small to stay ahead
  of context rot. Prefer a fresh `/loop-run` (clean context) over a high
  `max_iterations` for long jobs; lean on `STATE.md` as the durable spine that
  survives a context reset, not on in-session memory.
- **Kill switch.** `jq '.force_stop = true' ~/.claude/loops/<name>/state.json`
  (then save over it) halts the loop at its next stop.
- **State is the artifact.** Runtime state lives in `~/.claude/loops/<name>/`
  (gitignored): `state.json` (machine state) and `STATE.md` (human-readable
  triage report).
- **One active loop at a time.** Session ownership is claimed by the first
  session that stops after `/loop-run`; concurrent normal sessions are never
  gated.

## How a loop runs

1. `/loop-run <loop-name>` initialises `~/.claude/loops/<name>/state.json`
   and executes one iteration in the current session.
2. At end of turn the Stop hook reads the state: verdict `continue`/`pending`
   blocks the stop and demands verification + the next iteration;
   `success`/`escalate` (or any cap) lets the session end and finalises status.
3. For recurring execution wrap it in the built-in scheduler:
   `/loop 1d /loop-run daily-triage`.

## Runtime state

The canonical `state.json` schema is the init heredoc in
`commands/loop-run.md` (Step 2). The fields a human touches:

- `force_stop` — set `true` to kill the loop at its next stop
- `status` — `running | success | escalated | stopped`
- `last_verdict` / `records` — the verifier's audit trail

A `.running` marker file next to `state.json` arms the Stop hook; the hook
removes it when the loop finalises.

---

## daily-triage

- level: **L1 (report-only — never edits anything outside its own loop dir)**
- cost_tier: **low** (cheap read-only signals, summarised one line per repo)
- schedule: manual, or `/loop 1d /loop-run daily-triage`
- max_iterations: see `loops.json`
- implementer: main session (report-only triage)
- verifier: `loop-verifier` subagent
- success_condition: `STATE.md` in the loop dir contains a current, structured
  triage (High-Priority / Watch / Noise) with a fresh `Last run` timestamp
- targets: `~/.dotfiles` + every repo under `~/development` with a `.git`
  dir touched in the last 30 days (active repos)
- scope (read-only signals to triage, per active repo):
  - `git status` (uncommitted work) / recent commits / stale local branches
  - open PRs and CI/workflow health (`gh` CLI, if a remote exists)
  - TODO/FIXME count (`rg -c 'TODO|FIXME'` — count only, keep it cheap)
  - dependency advisories (report only — no upgrades)
  - harness health: pending proposals in `~/.dotfiles/claude/harness/proposals/`
- overlap rule: daily-triage is the umbrella morning report. Where a
  dedicated loop covers a signal deeper (pr-babysitter, ci-sweeper,
  dependency-sweeper, post-merge-cleanup), summarise to one line per repo
  and defer detail to that loop's own STATE.md — do not duplicate its work.
- out_of_scope: ANY file modification outside `~/.claude/loops/daily-triage/`;
  architectural proposals; opening PRs/issues
- triage discipline: one line per item; only put something in High-Priority if
  a reasonable engineer would want to know about it today — when in doubt,
  Watch or Noise. Never invent work; never propose architecture changes.
- report format (`STATE.md` in the loop dir):

  ```markdown
  # daily-triage — STATE

  Last run: <ISO8601 UTC>  |  Iteration: <n>

  ## High-Priority (waiting on human)
  - <one line per item, each traceable to a real signal>

  ## Watch
  - ...

  ## Noise
  - ...
  ```

### L1 -> L2 graduation criteria (do not skip)

1. Two weeks of L1 runs with <20% noise in High-Priority.
2. A `loop-implementer` agent + worktree isolation proven on manual fixes.
3. Path denylist documented here before any auto-fix is enabled.
4. Exempt active loop sessions from the prompt-type Stop gates
   (reflect/evolve/simplify) in settings.json — otherwise every blocked stop
   of a code-editing loop re-triggers them mid-cycle.

---

## pr-babysitter

- level: **L1 (report-only)**
- cost_tier: **high** (per-PR CI + review queries, short schedule = many runs)
- schedule: manual, or `/loop 6h /loop-run pr-babysitter`
- implementer: main session (report-only)
- verifier: `loop-verifier` subagent
- success_condition: `STATE.md` lists every open PR authored by or assigned
  to Kubbo0308 with its blocker classified, fresh `Last run` timestamp
- scope (read-only signals, via `gh`):
  - `gh search prs --author Kubbo0308 --state open` and review-requested PRs
  - per PR: CI status, review state, days since last activity
  - classify: failing-CI / awaiting-review >24h / awaiting-author / mergeable
- out_of_scope: commenting, merging, pushing, re-requesting review — report only
- report format: same High-Priority / Watch / Noise structure as daily-triage;
  High-Priority = mergeable-but-forgotten or failing-CI on an active PR

## ci-sweeper

- level: **L1 (report-only)**
- cost_tier: **high** (scans many repos' run logs; keep to log heads only)
- schedule: manual, or `/loop 1d /loop-run ci-sweeper`
- implementer: main session (report-only)
- verifier: `loop-verifier` subagent
- success_condition: `STATE.md` lists failing/erroring workflow runs across
  Kubbo0308-owned repos with a one-line failure classification each
- scope (read-only signals, via `gh`):
  - `gh repo list Kubbo0308 --limit 30` then `gh run list` on repos with
    recent pushes (last 14 days)
  - classify each failure: code / flake / infra / config (from the run log
    head — do not download full logs for every run)
- out_of_scope: re-running workflows, editing code, opening issues
- report format: High-Priority = red default-branch on an active repo;
  Watch = red feature branches; Noise = stale repos

## dependency-sweeper

- level: **L1 (report-only)**
- cost_tier: **med** (audit/list per active project; bounded by 30-day filter)
- schedule: manual, or `/loop 1d /loop-run dependency-sweeper`
- implementer: main session (report-only)
- verifier: `loop-verifier` subagent
- success_condition: `STATE.md` lists security advisories and major-version
  lag for ACTIVE projects (mtime of lockfile/manifest within 30 days) under
  `~/development` and `~/.dotfiles`
- scope (read-only signals):
  - find active projects: `package.json` / `go.mod` modified in last 30 days
  - npm projects: `npm audit --json` (read-only; NEVER `npm audit fix`)
  - go projects: `go list -m -u all 2>/dev/null | grep '\['` (available updates)
  - cross-check anything alarming against
    `claude/skills/dep-vulnerability-check/references/blocked-versions.md`
- out_of_scope: installing, upgrading, or editing any manifest/lockfile
- report format: High-Priority = critical/high advisory in an active project;
  Watch = moderate advisories + major-version lag; Noise = dev-only lows

## post-merge-cleanup

- level: **L1 (report-only)**
- cost_tier: **low** (local git inspection only, no network)
- schedule: manual, or `/loop 1d /loop-run post-merge-cleanup`
- implementer: main session (report-only)
- verifier: `loop-verifier` subagent
- success_condition: `STATE.md` inventories merge debt across local repos
- scope (read-only signals, for `~/.dotfiles` + repos under `~/development`
  with a `.git` dir touched in the last 30 days):
  - local branches already merged into the default branch (`git branch --merged`)
  - branches whose upstream is gone (`git branch -vv | grep ': gone'`)
  - stale worktrees (`git worktree list`)
  - repos with uncommitted changes sitting >7 days (mtime heuristic)
- out_of_scope: deleting branches/worktrees, committing, stashing — report only
- report format: High-Priority = uncommitted work at risk; Watch = deletable
  merged/gone branches per repo; Noise = everything else

---

## Design rationale & sources

This harness follows the 2025-2026 loop-engineering consensus: *design the loop
and stay the engineer; don't become the person who just presses start.*
The choices above map to current best practice:

- **Termination is layered, not single.** A loop ends on any of: verifier
  `success`/`escalate`, `max_iterations`, the 2x block-cap stall backstop, the
  new same-feedback stuck-detector, or the human kill switch. Multiple
  independent stop conditions are the documented guardrail against runaway
  loops. — [Agentic Loops: From ReAct to Loop Engineering](https://datasciencedojo.com/blog/agentic-loops-explained-from-react-to-loop-engineering-2026-guide/)
- **The kill switch lives below the agent.** `max_iterations` is read from the
  committed `loops.json` by the Stop hook, never from agent-writable state — a
  prompt-level kill switch can be argued around; an infra-level one cannot.
  — [AI Agent Guardrails: Kill Switches, Escalation, Recovery](https://www.codebridge.tech/articles/ai-agent-guardrails-for-production-kill-switches-escalation-paths-and-safe-recovery)
- **Maker ≠ checker.** A session never grades its own work; the `loop-verifier`
  subagent does, default-REJECT. Put *something that can say no* in every loop.
  — [Building Effective AI Agents (Anthropic)](https://www.anthropic.com/research/building-effective-agents)
- **State is the artifact; context is a budget.** Iterations share a session, so
  caps stay small and `STATE.md` carries continuity across context resets,
  hedging context rot. — [Effective Context Engineering for AI Agents (Anthropic)](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- **Start at L1.** Maintenance loops (triage, PR-babysitting, CI, deps) run
  report-only until proven, then graduate per the documented criteria.
  — [cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering)

Deferred until the first L2 loop exists (intentionally not built yet): the L2
verifier checklist, worktree isolation for the implementer, an escalation packet
(proposed action + evidence + cost estimate + risk flags) at each human gate,
and a multi-judge panel for high-risk auto-fix decisions.
