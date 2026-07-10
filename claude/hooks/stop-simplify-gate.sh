#!/usr/bin/env bash
# Deterministic Stop-hook gate for the one-shot /simplify skill.
#
# Why this exists: the previous gate was a "prompt" hook whose LLM evaluator
# reads the *live* conversation context. After the context is compacted, an
# earlier /simplify run is no longer visible, so the evaluator wrongly concludes
# it never ran and re-nags every turn. This hook instead reads the raw session
# transcript file (which retains the Skill invocation across compaction) and
# decides deterministically.
#
# Decision:
#   1. /simplify already ran this session        -> allow stop (exit 0)
#   2. no uncommitted source files changed        -> allow stop (exit 0)
#   3. otherwise                                  -> block with a nudge
#
# Invoke as `bash stop-simplify-gate.sh` (no exec bit needed).
set -uo pipefail

input="$(cat 2>/dev/null || true)"

# transcript_path is a plain filesystem path in the hook's stdin JSON; forward
# slashes are not escaped, so a simple sed extraction is safe and dependency-free.
transcript="$(printf '%s' "$input" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"

# 1) Already-ran short-circuit. Match the Skill tool invocation input, e.g.
#    {"name":"Skill","input":{"skill":"simplify", ...
if [ -n "$transcript" ] && [ -f "$transcript" ] \
  && grep -Eq '"skill"[[:space:]]*:[[:space:]]*"simplify"' "$transcript"; then
  exit 0
fi

# 2) Only nag when application source files have uncommitted changes.
root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$root" ] && exit 0
changed="$(git -C "$root" status --porcelain 2>/dev/null \
  | grep -E '\.(ts|tsx|js|jsx|mjs|cjs|py|go|rs|sh)$' || true)"
[ -z "$changed" ] && exit 0

# 3) Block and surface the nudge.
printf '%s\n' '{"decision":"block","reason":"Run /simplify to review changed code for reuse, quality, and efficiency before completing."}'
exit 0
