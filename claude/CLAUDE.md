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
- Lead investigations/answers with the result (cause → fix, terse). Stop-hook skills (/simplify, /evolve, /reflect) may run, but keep their execution logs and triage out of the reply — at most one line saying it was recorded. The user does not read ceremony dumps. (learned 2026-06-30)
- Before publishing factual claims to an outward artifact (GitHub issue/PR/doc), verify each claim against the full source — don't assert from one filtered sample. Reading robots.txt / structured config through a narrow grep hides structural scope (e.g. which User-agent a `Disallow: /` belongs to); read the whole file before stating scope. (learned 2026-07-01) (learned 2026-07-01)
- When the user scopes a question to a subset or exclusion (e.g. 'X以外' / the others), keep follow-up answers within that scope until they explicitly change it. (learned 2026-07-01) (learned 2026-07-01)
- When asked to remove/soften a trait (a tone, framing, technique), don't discard adjacent legitimate goals with it — separate the goal from the objectionable method, ban only the method, and explicitly preserve the goal (e.g. 'drive action' survives even when 'fear-based framing' is banned). (learned 2026-07-01)
- Rendering HTML→PNG with headless Chrome --screenshot: it may not exit after writing the file (webfont fetch hang). Wrap each invocation in a hard subprocess timeout (~15s) and treat the written PNG as success; use a fresh --user-data-dir per run. (learned 2026-07-02)
- Run-once Stop-hook review gates (/simplify etc.) count as done-for-the-session after one firing, BUT if that firing only reviewed a throwaway/scratch script and substantive shipping code was written afterward, re-run the review on the real code instead of citing the earlier run — don't spend the session's one review on incidental code. (learned 2026-07-04) (learned 2026-07-04)
- Before concluding a Docker DB lost its data, run 'docker volume ls' for dangling volumes: the official postgres image auto-creates an anonymous volume, so 'docker rm' without -v leaves data recoverable by mounting that volume in a temp container. Add a named volume to compose to prevent recurrence. (learned 2026-07-04) (learned 2026-07-04)
- プラットフォームの制限/仕様/価格などユーザーが自分のアプリ・アカウントで直接確認できる事実は、公式一次情報かユーザーの観測を優先する。二次情報(マーケ/まとめブログ)の楽観値を見出しに断定しない。ロールアウトが不均一な機能は保守的/観測済みの値を先に述べ、拡大は条件付きで添える。(learned 2026-07-04) (learned 2026-07-04)
- CI install/build failure that does not reproduce locally: reproduce in the ACTUAL environment early — Docker with the CI-pinned tool version, and vary that version — instead of guessing from lockfile/registry inspection. Check first whether CI's tool version matches the repo's declared packageManager/engines (a mismatch, e.g. CI bun 1.3.8 vs packageManager bun 1.3.14, can fail 'Failed to install N packages' with no named culprit). (learned 2026-07-04) (learned 2026-07-04)
- ユーザーの明示指示(並び順・形式・対象)は実際に反映し、成果物で反映済みか検証してから完了報告する。既存が偶然合致していても「維持」で済ませない。頼まれた対象(例:税額テーブル)を別物(手取りテーブル)にすり替えない。コミット前に各明示要求と成果物を1対1で照合する。(learned 2026-07-05) (learned 2026-07-04)
- On a timeout error, first determine whether the work is slow-but-bounded or genuinely hung before raising the limit — raising maxDuration/timeout only fixes bounded-but-slow work; for a hang it just wastes more time+cost. Do not declare a timeout/perf config change fixed until validated against an actual run in the real (prod) environment; local success does not prove prod behavior (browser/anti-bot/env differ). (learned 2026-07-05) (learned 2026-07-05)
- When a user reports a production value/bug, first confirm which code version is actually deployed (merge/deploy state) before attributing the symptom to an 'old'/discarded version — an observed prod artifact is evidence about the LIVE code. For env-specific failures (passes locally, fails in prod), local re-runs can't confirm the cause; add prod-side observability (log raw intermediate values) and verify there instead of re-running local. (learned 2026-07-06)
- When diagnosing an intermittent success/failure, confirm the failing and passing observations were controlled (same target URL/entity, comparable time) and differed ONLY in the hypothesized variable BEFORE asserting that variable is the cause. Don't infer the differentiator from a single log line; ask which conditions each observation actually ran under. (learned 2026-07-07) (learned 2026-07-06)
- Before concluding a datastore/resource is empty or absent, verify the exact object name (table/schema/column) and list what actually exists — a failed lookup or empty result is as often a wrong-identifier bug (e.g. sub_genre vs subgenre) as truly-absent data. For code that matches/transforms real data, run it end-to-end against the real datastore before calling it verified; unit tests + eyeballed mappings miss integration bugs like wrong lookup keys or upstream row-shape pollution. (learned 2026-07-08) (learned 2026-07-07)
- When you have already flagged a path as risky and a proven-simpler alternative meets the same goal, lead with the safe primitive instead of shipping the risky option behind a fallback — especially for env-specific behavior you can't reproduce locally (anti-bot, headless navigation, persistent connections). A fallback is only safety if you've verified it actually triggers AND recovers; a catchAll that re-issues an operation which can itself hang/conflict (e.g. a 2nd navigation while the 1st is still in flight) is not real safety. (learned 2026-07-08) (learned 2026-07-08)
- Before building a new verification mechanism (canary route, probe endpoint, test harness) to check whether an external dependency is reachable/works from a given runtime or egress, first grep for an existing code path that already exercises that same capability in production and reuse its evidence/mechanism; build a bespoke probe only for the genuinely-untested delta (e.g. a different host/subdomain). (learned 2026-07-09)
- When creating a PR (gh pr create / pull-request subagent), always add the user as an assignee (--assignee @me). (learned 2026-07-09)
- When a scraped/API value disagrees with what a live UI shows, first dump the full data object (all sibling fields) and read the actual rendered UI, then reconcile field-by-field, before theorizing about experiments/caching/phantom values — the gap is usually a sibling field (e.g. tax-inclusive total vs fees-only pre_tax_total). Validate price-field choices on samples WITH non-zero tax/fees; tax=0 data hides total-vs-pretax bugs. (learned 2026-07-09)
- For a multi-source comparison/aggregation feature, all sources must use the SAME selection/extraction rule or the comparison is biased — read how the peer sources already do it before picking the rule for a new source. Ground the choice in the stated requirement and product goal; never add an unstated constraint (e.g. 'reserved-seat only') and rationalize it post-hoc. (learned 2026-07-09)
- Before recommending a design that depends on a specific data field, verify the exact endpoint/API version you will query actually returns it — related/summary endpoints expose different field sets (a coarse summary may omit fields the granular endpoint has). When a spec cites a field set, check which endpoint it came from before treating those as the only options. (learned 2026-07-10)
- When reproducing a design from a reference image, crop/zoom the actual image to inspect layout/spacing/color/typography (don't rely on a downscaled glance or your own low-res screenshot), AND check for an existing design system on a sibling/peer page and reuse its components/patterns before building anything bespoke. (learned 2026-07-10) (learned 2026-07-10)
- When a color/tint/spacing question against a reference image is ambiguous, sample the actual pixel values (e.g. ImageMagick `magick img -format '%[pixel:p{x,y}]' info:`) at the specific regions and match those exact values, rather than eyeballing a downscaled view. (learned 2026-07-11) (learned 2026-07-10)
<!-- HARNESS:LESSONS:END -->

wonderful!!
