#!/bin/bash
# record.sh — append a structured learning signal to the local ledger.
# Usage:
#   record.sh lesson '{"summary":"...","trigger":"...","rule":"...","scope":"global|project|tool","target":"path-or-name","risk":"additive|structural"}'
#   record.sh usage  '{"kind":"skill|agent|command","name":"...","outcome":"good|bad","note":"..."}'
#
# These ledgers are LOCAL ONLY (gitignored). Distilled rules are written to CLAUDE.md
# (which IS committed) by apply-rule.sh / proposals.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib/harness-common.sh"

KIND="${1:-}"
OBJ="${2:-}"

if [ -z "$KIND" ] || [ -z "$OBJ" ]; then
  echo "usage: record.sh <lesson|usage> '<json>'" >&2
  exit 1
fi

case "$KIND" in
  lesson) append_jsonl "$LESSONS_FILE" "$OBJ" && echo "recorded lesson" ;;
  usage)  append_jsonl "$USAGE_FILE"  "$OBJ" && echo "recorded usage"  ;;
  *) echo "unknown kind: $KIND (expected lesson|usage)" >&2; exit 1 ;;
esac
