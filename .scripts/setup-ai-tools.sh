#!/bin/bash

# Setup AI Tools Configuration
# Creates symbolic links for Antigravity, Gemini CLI, and Codex CLI configurations

set -e

DOTFILES_DIR="${HOME}/.dotfiles"

echo "🚀 Setting up AI Tools configurations..."

# ============================================
# Antigravity Setup
# ============================================
echo ""
echo "📦 Setting up Antigravity..."

# Global skills directory
ANTIGRAVITY_SKILLS_DIR="${HOME}/.gemini/antigravity/skills"
mkdir -p "${ANTIGRAVITY_SKILLS_DIR}"

# Link skills
for skill in "${DOTFILES_DIR}/antigravity/skills"/*; do
    if [ -d "$skill" ]; then
        skill_name=$(basename "$skill")
        target="${ANTIGRAVITY_SKILLS_DIR}/${skill_name}"
        if [ -L "$target" ]; then
            rm "$target"
        fi
        ln -sf "$skill" "$target"
        echo "  ✓ Linked skill: ${skill_name}"
    fi
done

# Project-level .agent directory (optional - uncomment if needed)
# mkdir -p "${HOME}/.agent/skills"
# ln -sf "${DOTFILES_DIR}/antigravity/skills"/* "${HOME}/.agent/skills/"

echo "✅ Antigravity setup complete!"

# ============================================
# Gemini CLI Setup
# ============================================
echo ""
echo "🔷 Setting up Gemini CLI..."

GEMINI_DIR="${HOME}/.gemini"
mkdir -p "${GEMINI_DIR}/commands"

# Link system.md
if [ -f "${DOTFILES_DIR}/gemini/system.md" ]; then
    ln -sf "${DOTFILES_DIR}/gemini/system.md" "${GEMINI_DIR}/system.md"
    echo "  ✓ Linked system.md"
fi

# Link commands
for cmd in "${DOTFILES_DIR}/gemini/commands"/*.toml; do
    if [ -f "$cmd" ]; then
        cmd_name=$(basename "$cmd")
        ln -sf "$cmd" "${GEMINI_DIR}/commands/${cmd_name}"
        echo "  ✓ Linked command: ${cmd_name}"
    fi
done

# Create .env for system.md activation
ENV_FILE="${GEMINI_DIR}/.env"
if [ ! -f "$ENV_FILE" ] || ! grep -q "GEMINI_SYSTEM_MD" "$ENV_FILE" 2>/dev/null; then
    echo "GEMINI_SYSTEM_MD=1" >> "$ENV_FILE"
    echo "  ✓ Enabled custom system prompt"
fi

echo "✅ Gemini CLI setup complete!"

# ============================================
# Codex CLI Setup
# ============================================
echo ""
echo "🤖 Setting up Codex CLI..."

CODEX_DIR="${HOME}/.codex"

# Check if ~/.codex is already a symlink to dotfiles
if [ -L "${CODEX_DIR}" ]; then
    CODEX_TARGET=$(readlink "${CODEX_DIR}")
    if [[ "${CODEX_TARGET}" == *"dotfiles"* ]]; then
        echo "  ✓ ~/.codex already linked to dotfiles"
        echo "  ✓ AGENTS.md available at ${CODEX_DIR}/AGENTS.md"
        echo "  ✓ Prompts available at ${CODEX_DIR}/prompts/"
    fi
else
    # Create directory and link files
    mkdir -p "${CODEX_DIR}/prompts"

    # Link AGENTS.md
    if [ -f "${DOTFILES_DIR}/codex/AGENTS.md" ]; then
        ln -sf "${DOTFILES_DIR}/codex/AGENTS.md" "${CODEX_DIR}/AGENTS.md"
        echo "  ✓ Linked AGENTS.md"
    fi

    # Link prompts
    for prompt in "${DOTFILES_DIR}/codex/prompts"/*.md; do
        if [ -f "$prompt" ]; then
            prompt_name=$(basename "$prompt")
            ln -sf "$prompt" "${CODEX_DIR}/prompts/${prompt_name}"
            echo "  ✓ Linked prompt: ${prompt_name}"
        fi
    done
fi

echo "✅ Codex CLI setup complete!"

# ============================================
# Summary
# ============================================
echo ""
echo "=========================================="
echo "🎉 All AI Tools configured successfully!"
echo "=========================================="
echo ""
echo "Configuration locations:"
echo "  • Antigravity: ~/.gemini/antigravity/skills/"
echo "  • Gemini CLI:  ~/.gemini/commands/ + ~/.gemini/system.md"
echo "  • Codex CLI:   ~/.codex/AGENTS.md + ~/.codex/prompts/"
echo ""
echo "Usage:"
echo "  • Antigravity: Skills auto-discovered by description"
echo "  • Gemini CLI:  /command-name (e.g., /orchestrator)"
echo "  • Codex CLI:   /prompts:name (e.g., /prompts:orchestrator)"
echo ""
echo "wonderful!!"
