#!/usr/bin/env bash

# cmux-worktree: Integrate git worktree with cmux workspaces
# Creates isolated worktree directories with dedicated cmux workspaces

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

WORKTREE_BASE="$HOME/.worktrees"

info()  { echo -e "${BLUE}[info]${RESET} $*"; }
ok()    { echo -e "${GREEN}[ok]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[warn]${RESET} $*"; }
err()   { echo -e "${RED}[error]${RESET} $*" >&2; }

get_repo_root() {
    git rev-parse --show-toplevel 2>/dev/null || {
        err "Not inside a git repository"
        exit 1
    }
}

get_repo_name() {
    basename "$(get_repo_root)"
}

# --- Subcommands ---

cmd_new() {
    local branch_name="${1:?Branch name is required}"
    local base_branch="${2:-main}"
    local repo_name
    repo_name="$(get_repo_name)"
    local worktree_path="$WORKTREE_BASE/$repo_name/$branch_name"

    if [ -d "$worktree_path" ]; then
        err "Worktree already exists at $worktree_path"
        exit 1
    fi

    mkdir -p "$WORKTREE_BASE/$repo_name"

    # Check if branch already exists (local or remote)
    if git show-ref --verify --quiet "refs/heads/$branch_name" 2>/dev/null; then
        info "Branch '$branch_name' exists, creating worktree..."
        git worktree add "$worktree_path" "$branch_name"
    else
        info "Creating new branch '$branch_name' from '$base_branch'..."
        git worktree add -b "$branch_name" "$worktree_path" "$base_branch"
    fi

    ok "Worktree created at $worktree_path"

    # Create cmux workspace and rename it
    info "Creating cmux workspace..."
    local ws_output
    ws_output=$(cmux new-workspace --command "cd $worktree_path && exec zsh" 2>&1)
    local ws_ref
    ws_ref=$(echo "$ws_output" | grep -oE 'workspace:[0-9]+' | head -1)
    if [ -n "$ws_ref" ]; then
        cmux rename-workspace --workspace "$ws_ref" "$repo_name:$branch_name"
    else
        # Fallback: rename current workspace (new workspace should be selected)
        cmux rename-workspace "$repo_name:$branch_name"
    fi

    ok "cmux workspace '$repo_name:$branch_name' ready"
    echo ""
    echo -e "${BOLD}Worktree path:${RESET} $worktree_path"
    echo -e "${BOLD}Workspace:${RESET}    $repo_name:$branch_name"
}

cmd_list() {
    local repo_root
    repo_root="$(get_repo_root)"

    echo -e "${BOLD}Git worktrees:${RESET}"
    git -C "$repo_root" worktree list
    echo ""

    if command -v cmux &>/dev/null; then
        echo -e "${BOLD}cmux workspaces:${RESET}"
        cmux list-workspaces
    fi
}

cmd_remove() {
    local branch_name="${1:?Branch name is required}"
    local repo_name
    repo_name="$(get_repo_name)"
    local worktree_path="$WORKTREE_BASE/$repo_name/$branch_name"
    local workspace_title="$repo_name:$branch_name"

    # Close cmux workspace if it exists (find by title, close by ref)
    if command -v cmux &>/dev/null; then
        info "Closing cmux workspace '$workspace_title'..."
        local ws_ref
        ws_ref=$(cmux list-workspaces 2>/dev/null | grep -F "$workspace_title" | awk '{print $1}' | head -1)
        if [ -n "$ws_ref" ]; then
            cmux close-workspace --workspace "$ws_ref" 2>/dev/null || warn "Failed to close cmux workspace"
            ok "cmux workspace closed"
        else
            warn "cmux workspace '$workspace_title' not found"
        fi
    fi

    # Remove worktree
    if [ -d "$worktree_path" ]; then
        info "Removing worktree at $worktree_path..."
        git worktree remove "$worktree_path" --force
        ok "Worktree removed"
    else
        warn "Worktree directory not found: $worktree_path"
    fi

    # Clean up empty parent directory
    local repo_dir="$WORKTREE_BASE/$repo_name"
    if [ -d "$repo_dir" ] && [ -z "$(ls -A "$repo_dir")" ]; then
        rmdir "$repo_dir"
        info "Cleaned up empty directory $repo_dir"
    fi
}

cmd_help() {
    cat <<EOF
${BOLD}cmux-worktree${RESET} - Git worktree + cmux workspace integration

${BOLD}USAGE:${RESET}
    cmux-worktree <command> [args]

${BOLD}COMMANDS:${RESET}
    new <branch-name> [base-branch]   Create worktree + cmux workspace
                                       (default base: main)
    list                               List active worktrees and workspaces
    remove <branch-name>               Remove worktree + close cmux workspace
    help                               Show this help message

${BOLD}EXAMPLES:${RESET}
    cmux-worktree new feature/login
    cmux-worktree new hotfix/bug-123 develop
    cmux-worktree list
    cmux-worktree remove feature/login
EOF
}

# --- Main ---

command="${1:-help}"
shift || true

case "$command" in
    new)    cmd_new "$@" ;;
    list)   cmd_list ;;
    remove) cmd_remove "$@" ;;
    help)   cmd_help ;;
    *)
        err "Unknown command: $command"
        cmd_help
        exit 1
        ;;
esac
