#!/bin/bash
# codex-query.sh - Query OpenAI Codex CLI from Claude Code
#
# Usage:
#   ./codex-query.sh "your prompt here"
#   echo "prompt" | ./codex-query.sh -
#   ./codex-query.sh -i image.png "describe this"
#
# Options:
#   -i FILE    Attach image file
#   -m MODEL   Specify model (default: gpt-5-codex)
#   --search   Enable web search
#   --json     Output raw JSON (for parsing)
#   -          Read prompt from stdin

set -euo pipefail

IMAGES=()
MODEL=""
SEARCH=""
JSON_OUTPUT=""
PROMPT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i)
            IMAGES+=("-i" "$2")
            shift 2
            ;;
        -m)
            MODEL="-m $2"
            shift 2
            ;;
        --search)
            SEARCH="--search"
            shift
            ;;
        --json)
            JSON_OUTPUT="--json"
            shift
            ;;
        -)
            PROMPT=$(cat)
            shift
            ;;
        *)
            PROMPT="$1"
            shift
            ;;
    esac
done

if [[ -z "$PROMPT" ]]; then
    echo "Error: No prompt provided" >&2
    echo "Usage: $0 [-i image] [-m model] [--search] [--json] <prompt|->" >&2
    exit 1
fi

# Build command
CMD=(codex exec)
[[ -n "$MODEL" ]] && CMD+=($MODEL)
[[ -n "$SEARCH" ]] && CMD+=($SEARCH)
[[ ${#IMAGES[@]} -gt 0 ]] && CMD+=("${IMAGES[@]}")
CMD+=(-a never --sandbox read-only)
[[ -n "$JSON_OUTPUT" ]] && CMD+=(--json)
CMD+=("$PROMPT")

# Execute
OUTPUT=$("${CMD[@]}" 2>&1) || true

# Handle output
if [[ -n "$JSON_OUTPUT" ]]; then
    # Return raw JSON
    echo "$OUTPUT"
else
    # Check for errors
    if echo "$OUTPUT" | grep -q '"type":"error"'; then
        ERROR_MSG=$(echo "$OUTPUT" | grep '"type":"error"' | head -1 | sed 's/.*"message":"\([^"]*\)".*/\1/')
        echo "Error: $ERROR_MSG" >&2
        exit 1
    fi

    # Extract and display final message content
    echo "$OUTPUT" | grep -v '^\[' | grep -v '^{' || echo "$OUTPUT"
fi

