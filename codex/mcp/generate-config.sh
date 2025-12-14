#!/bin/bash

# Codex MCP configuration generator
# Produces config.toml from config-template.toml with machine-specific substitutions

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_FILE="${SCRIPT_DIR}/config-template.toml"
OUTPUT_FILE="${SCRIPT_DIR}/config.toml"

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Template not found: $TEMPLATE_FILE" >&2
    exit 1
fi

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
MY_BRAIN_DIR="${MY_BRAIN_DIR:-$HOME/Documents/my-brain}"
SIMPLE_TODO_DIR="${SIMPLE_TODO_DIR:-$HOME/development/simple-todo-notification}"

content=$(cat "$TEMPLATE_FILE")
content="${content//\$\{DOTFILES_DIR\}/${DOTFILES_DIR}}"

printf '%s\n' "$content" > "$OUTPUT_FILE"

append_project() {
    local project_path=$1

    # Expand leading tilde manually so we do not rely on eval
    case "$project_path" in
        "~"|"~/*")
            project_path="${HOME}${project_path#~}"
            ;;
    esac

    if [ -z "$project_path" ]; then
        return
    fi

    # Avoid duplicate entries for the same directory
    if grep -Fq "[projects.\"$project_path\"]" "$OUTPUT_FILE"; then
        return
    fi

    printf '\n[projects."%s"]\ntrust_level = "trusted"\n' "$project_path" >> "$OUTPUT_FILE"
}

append_project "$MY_BRAIN_DIR"
append_project "$SIMPLE_TODO_DIR"

if [ -n "${CODEX_EXTRA_PROJECTS:-}" ]; then
    IFS=':' read -r -a extra_projects <<< "${CODEX_EXTRA_PROJECTS}"
    for project in "${extra_projects[@]}"; do
        append_project "$project"
    done
fi

echo "Generated Codex MCP config at $OUTPUT_FILE"
