#!/bin/bash

# Claude Code CLI MCP Setup Script
# This script configures all MCP servers for Claude Code CLI

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up MCP servers for Claude Code CLI...${NC}\n"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_FILE="${SCRIPT_DIR}/environments/.env.local"

# Load environment variables if .env.local exists
if [ -f "$ENV_FILE" ]; then
    echo -e "${GREEN}Loading environment variables from .env.local${NC}"
    source "$ENV_FILE"
else
    echo -e "${YELLOW}Warning: .env.local not found. Using default values.${NC}"
    # Set defaults
    UVX_PATH="${HOME}/.local/bin/uvx"
    SERENA_PROJECT_PATH="${HOME}/.dotfiles"
    CHROME_HEADLESS="false"
    CHROME_VIEWPORT="1280x720"
    CHROME_DEBUG_PORT="9222"
fi

echo ""

# Function to add MCP server (user scope for global availability)
add_mcp_server() {
    local name=$1
    shift
    local command=("$@")

    echo -e "${GREEN}Adding MCP server: ${name} (user scope)${NC}"

    # Remove existing server if it exists (check both scopes)
    claude mcp remove "${name}" -s user 2>/dev/null || true
    claude mcp remove "${name}" -s local 2>/dev/null || true

    # Add the server with user scope (available in all projects)
    if claude mcp add --scope user "${name}" -- "${command[@]}"; then
        echo -e "${GREEN}✓ Successfully added ${name}${NC}\n"
    else
        echo -e "${RED}✗ Failed to add ${name}${NC}\n"
        return 1
    fi
}

# Add Serena MCP with SSE transport (allows sharing across Claude Code sessions)
SERENA_PORT="${SERENA_PORT:-8765}"
SERENA_URL="http://127.0.0.1:${SERENA_PORT}/sse"

echo -e "${GREEN}Adding MCP server: serena (SSE transport)${NC}"

# Remove existing server if it exists
claude mcp remove "serena" -s user 2>/dev/null || true
claude mcp remove "serena" -s local 2>/dev/null || true

# Add Serena with SSE transport
if claude mcp add --transport sse --scope user "serena" "${SERENA_URL}"; then
    echo -e "${GREEN}✓ Successfully added serena${NC}"
    echo -e "${YELLOW}Note: Start Serena server with: ${SCRIPT_DIR}/serena-wrapper.sh start${NC}\n"
else
    echo -e "${RED}✗ Failed to add serena${NC}\n"
fi

# Add Playwright MCP
add_mcp_server "playwright" \
    npx -y "@playwright/mcp@latest"

# Add Chrome DevTools MCP
add_mcp_server "chrome-devtools" \
    npx -y "chrome-devtools-mcp@latest" \
    --isolated=true \
    --headless="${CHROME_HEADLESS}" \
    --viewport="${CHROME_VIEWPORT}"

# Add Filesystem MCP
add_mcp_server "filesystem" \
    npx -y "@modelcontextprotocol/server-filesystem" \
    "${HOME}/Desktop" \
    "${HOME}/Downloads"

# Add Context7 MCP
add_mcp_server "context7" \
    npx -y "@upstash/context7-mcp"

# Add PostgreSQL MCP (if connection string is set)
if [ -n "${POSTGRES_CONNECTION_STRING}" ]; then
    add_mcp_server "postgres" \
        npx -y "@modelcontextprotocol/server-postgres" \
        "${POSTGRES_CONNECTION_STRING}"
else
    echo -e "${YELLOW}Skipping PostgreSQL MCP (no connection string set)${NC}\n"
fi

echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}MCP Setup Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}\n"

# List all configured servers
echo -e "${GREEN}Configured MCP servers:${NC}"
claude mcp list

echo -e "\n${GREEN}Setup complete! All MCP servers are ready to use.${NC}"
echo -e "${YELLOW}Note: You may need to restart Claude Code for changes to take effect.${NC}"
