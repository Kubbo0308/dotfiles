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
