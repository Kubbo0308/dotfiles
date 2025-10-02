#!/bin/zsh

# PR Review Script for WezTerm
# Creates 3 panes for Claude Code, Cursor CLI, and Gemini CLI review

# Check if PR number or URL is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 pr-number-or-url [repo-owner/repo-name]"
    echo "Examples:"
    echo "  $0 123"
    echo "  $0 123 owner/repo"
    echo "  $0 https://github.com/owner/repo/pull/123"
    exit 1
fi

PR_INPUT="$1"
REPO=""

# Parse PR number and repo from GitHub URL if provided
if [[ "$PR_INPUT" =~ ^https?://github.com/([^/]+/[^/]+)/pull/([0-9]+)/?$ ]]; then
    REPO="${match[1]}"
    PR_NUMBER="${match[2]}"
elif [[ "$PR_INPUT" =~ ^[0-9]+$ ]]; then
    PR_NUMBER="$PR_INPUT"
    # Use second argument as repo if provided
    if [ $# -ge 2 ]; then
        REPO="$2"
    else
        # Try to get repo from current git remote
        if git remote get-url origin &>/dev/null; then
            REPO=$(git remote get-url origin | sed -E 's|.*github.com[:/]([^/]+/[^/]+)(\.git)?.*|\1|')
        fi
    fi
else
    echo "Error: Invalid PR number or URL format"
    exit 1
fi

# Check if repository was determined
if [ -z "$REPO" ]; then
    echo "Error: Could not determine repository. Please specify it as a second argument."
    echo "Usage: $0 pr-number owner/repo"
    exit 1
fi

# Set the prompt file path
PROMPT_FILE="${HOME}/.script/pr-review-prompt.md"

# Check if prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: Review prompt file not found at $PROMPT_FILE"
    exit 1
fi

# Read the prompt template and escape special characters for shell
PROMPT_TEMPLATE=$(cat "$PROMPT_FILE")

# Build the full prompt
FULL_PROMPT="Repository: ${REPO}
Pull Request: #${PR_NUMBER}

以下のghコマンドを実行してPull Requestを取得し、日本語でレビューしてください：
1. gh pr view ${PR_NUMBER} --repo ${REPO}
2. gh pr diff ${PR_NUMBER} --repo ${REPO}

${PROMPT_TEMPLATE}"

echo "Creating review session for PR #${PR_NUMBER}..."
echo "Repository: $REPO"

# Check if we're already in WezTerm
if [ -z "$WEZTERM_PANE" ]; then
    echo "Error: This script must be run from within WezTerm"
    exit 1
fi

# Define WezTerm CLI path
WEZTERM_CLI="/Applications/WezTerm.app/Contents/MacOS/wezterm"

# Split current pane vertically to create 3 vertical columns
echo "Setting up WezTerm panes for PR review..."

# Get the current (left) pane ID
LEFT_PANE=$WEZTERM_PANE

# Split the current pane to create a middle pane
MIDDLE_PANE=$($WEZTERM_CLI cli split-pane --right)

# Split the middle pane to create a right pane
RIGHT_PANE=$($WEZTERM_CLI cli split-pane --right --pane-id $MIDDLE_PANE)

echo "Pane IDs: Left=$LEFT_PANE, Middle=$MIDDLE_PANE, Right=$RIGHT_PANE"

# Create temporary files for prompts to avoid quoting issues
TEMP_DIR=$(mktemp -d)
CLAUDE_PROMPT_FILE="$TEMP_DIR/claude_prompt.txt"
CURSOR_PROMPT_FILE="$TEMP_DIR/cursor_prompt.txt"
GEMINI_PROMPT_FILE="$TEMP_DIR/gemini_prompt.txt"

echo "$FULL_PROMPT" > "$CLAUDE_PROMPT_FILE"
echo "$FULL_PROMPT" > "$CURSOR_PROMPT_FILE"
echo "$FULL_PROMPT" > "$GEMINI_PROMPT_FILE"

# Send commands to each pane with proper Enter key presses
echo "Starting Claude Code in left pane..."
$WEZTERM_CLI cli send-text --pane-id $LEFT_PANE --no-paste "clear && echo 'Claude AI Review:' && echo ''"
$WEZTERM_CLI cli send-text --pane-id $LEFT_PANE --no-paste $'\r'
sleep 0.5
$WEZTERM_CLI cli send-text --pane-id $LEFT_PANE --no-paste "claude \"\$(cat $CLAUDE_PROMPT_FILE)\""
$WEZTERM_CLI cli send-text --pane-id $LEFT_PANE --no-paste $'\r'

# Check if cursor-agent is available and start it in top-right pane
CURSOR_AGENT_PATH=""
if command -v cursor-agent &> /dev/null; then
    CURSOR_AGENT_PATH=$(command -v cursor-agent)
elif [ -f "$HOME/.local/bin/cursor-agent" ]; then
    CURSOR_AGENT_PATH="$HOME/.local/bin/cursor-agent"
fi

if [ -n "$CURSOR_AGENT_PATH" ]; then
    echo "Starting Cursor Agent in middle pane..."
    $WEZTERM_CLI cli send-text --pane-id $MIDDLE_PANE --no-paste "clear && echo 'Cursor Agent Review:' && echo ''"
    $WEZTERM_CLI cli send-text --pane-id $MIDDLE_PANE --no-paste $'\r'
    sleep 0.5
    # Use environment variables to prevent shell config conflicts with cursor-agent
    $WEZTERM_CLI cli send-text --pane-id $MIDDLE_PANE --no-paste "env PAGER='head -n 10000 | cat' COMPOSER_NO_INTERACTION=1 $CURSOR_AGENT_PATH \"\$(cat $CURSOR_PROMPT_FILE)\""
    $WEZTERM_CLI cli send-text --pane-id $MIDDLE_PANE --no-paste $'\r'
else
    echo "Cursor Agent not found, showing message in middle pane..."
    $WEZTERM_CLI cli send-text --pane-id $MIDDLE_PANE --no-paste "clear && echo 'Cursor Agent not found. Install with: curl https://cursor.com/install -fsS | bash'"
    $WEZTERM_CLI cli send-text --pane-id $MIDDLE_PANE --no-paste $'\r'
fi

# Check if gemini is available and start it in right pane
if command -v gemini &> /dev/null; then
    echo "Starting Gemini in right pane..."
    GEMINI_PATH=$(command -v gemini)
    $WEZTERM_CLI cli send-text --pane-id $RIGHT_PANE --no-paste "clear && echo 'Gemini AI Review:' && echo ''"
    $WEZTERM_CLI cli send-text --pane-id $RIGHT_PANE --no-paste $'\r'
    sleep 0.5
    $WEZTERM_CLI cli send-text --pane-id $RIGHT_PANE --no-paste "env -u ASDF_DIR -u ASDF_DATA_DIR $GEMINI_PATH --sandbox --yolo --prompt \"\$(cat $GEMINI_PROMPT_FILE)\""
    $WEZTERM_CLI cli send-text --pane-id $RIGHT_PANE --no-paste $'\r'
else
    echo "Gemini not found, showing message in right pane..."
    $WEZTERM_CLI cli send-text --pane-id $RIGHT_PANE --no-paste "clear && echo 'Gemini not found. You can install it or use another AI tool.'"
    $WEZTERM_CLI cli send-text --pane-id $RIGHT_PANE --no-paste $'\r'
fi

# Focus on the left pane (Claude)
$WEZTERM_CLI cli activate-pane --pane-id $LEFT_PANE

echo "PR review session created successfully!"
echo "- Left column: Claude Code"
echo "- Middle column: Cursor Agent"
echo "- Right column: Gemini CLI"
echo "Temporary files: $TEMP_DIR"
echo "Note: Temporary files will remain for the session duration."