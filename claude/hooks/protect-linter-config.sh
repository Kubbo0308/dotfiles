#!/bin/bash
# PreToolUse Hook: Protect linter/formatter config files from agent modification
# Harness Engineering: prevent agents from weakening quality gates
source "$(dirname "$0")/lib/file-guard.sh"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Associative array for O(1) lookup
declare -A PROTECTED_SET=(
  # ESLint
  [".eslintrc"]=1 [".eslintrc.js"]=1 [".eslintrc.cjs"]=1 [".eslintrc.json"]=1 [".eslintrc.yml"]=1
  ["eslint.config.js"]=1 ["eslint.config.mjs"]=1 ["eslint.config.ts"]=1
  # Biome / Oxlint
  ["biome.json"]=1 ["biome.jsonc"]=1 [".oxlintrc.json"]=1
  # Prettier
  [".prettierrc"]=1 [".prettierrc.js"]=1 [".prettierrc.json"]=1 ["prettier.config.js"]=1
  # Python
  ["pyproject.toml"]=1
  # Go
  [".golangci.yml"]=1 [".golangci.yaml"]=1 ["golangci.yml"]=1
  # Rust
  ["clippy.toml"]=1 [".clippy.toml"]=1 ["rustfmt.toml"]=1 [".rustfmt.toml"]=1
  # General
  [".editorconfig"]=1
  # Lefthook
  ["lefthook.yml"]=1 ["lefthook.yaml"]=1 [".lefthook.yml"]=1
)

if [[ -n "${PROTECTED_SET[$BASENAME]+x}" ]]; then
  jq -n --arg path "$FILE_PATH" \
    '{hookSpecificOutput:{additionalContext:("BLOCKED: " + $path + " is a linter/formatter config. Modifying quality gate configs is not allowed without explicit user approval.")}}' >&2
  exit 2
fi

exit 0
