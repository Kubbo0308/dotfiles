#!/usr/bin/env bash

# macOS app defaults (machine-local UserDefaults, not covered by symlinks)
# Run once per machine. Safe to re-run.

set -e

echo "🖥  Applying macOS app defaults..."

# --- cmux: open links in the default browser (Chrome), not the built-in browser ---
# cmux intercepts terminal link clicks AND `open https://...` (via its own `open`
# shim first in PATH) and opens URLs in its internal WebKit browser by default.
if [[ -d "/Applications/cmux.app" ]]; then
    defaults write com.cmuxterm.app browserOpenTerminalLinksInCmuxBrowser -bool false
    defaults write com.cmuxterm.app browserInterceptTerminalOpenCommandInCmuxBrowser -bool false
    defaults write com.cmuxterm.app browserOpenSidebarPullRequestLinksInCmuxBrowser -bool false
    echo "✅ cmux: terminal links / open command / PR links → default browser"
else
    echo "⏭  cmux not installed, skipping"
fi

echo "✅ macOS defaults applied"
