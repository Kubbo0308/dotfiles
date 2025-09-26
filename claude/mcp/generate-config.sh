#!/bin/bash

# MCP Configuration Generator Script
# This script generates actual config files from templates using environment variables

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"

# Check for .env.local file
ENV_FILE="${SCRIPT_DIR}/environments/.env.local"
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}Warning: .env.local not found!${NC}"
    echo "Creating .env.local from .env.example..."
    cp "${SCRIPT_DIR}/environments/.env.example" "$ENV_FILE"
    echo -e "${GREEN}Created .env.local - Please edit it with your values${NC}"
    exit 1
fi

# Load environment variables
source "$ENV_FILE"

# Function to replace environment variables in template
replace_vars() {
    local template="$1"
    local output="$2"
    
    echo "Processing: $template → $output"
    
    # Set defaults for variables
    USER_HOME="${USER_HOME:-$HOME}"
    MCP_FS_PATH_1="${MCP_FS_PATH_1:-$HOME/Desktop}"
    MCP_FS_PATH_2="${MCP_FS_PATH_2:-$HOME/Downloads}"
    
    # PostgreSQL configuration with defaults
    POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
    POSTGRES_PORT="${POSTGRES_PORT:-5432}"
    POSTGRES_DB="${POSTGRES_DB:-postgres}"
    POSTGRES_USER="${POSTGRES_USER:-postgres}"
    POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"
    
    # Construct PostgreSQL connection string
    if [ -n "$POSTGRES_USER" ] && [ -n "$POSTGRES_HOST" ] && [ -n "$POSTGRES_DB" ]; then
        if [ -n "$POSTGRES_PASSWORD" ]; then
            POSTGRES_CONNECTION_STRING="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
        else
            POSTGRES_CONNECTION_STRING="postgresql://${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
        fi
    else
        POSTGRES_CONNECTION_STRING=""
    fi
    
    # Use envsubst for proper variable substitution
    export USER_HOME MCP_FS_PATH_1 MCP_FS_PATH_2
    export GITHUB_TOKEN NOTION_API_KEY
    export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
    export CONTEXT7_API_KEY BRAVE_API_KEY
    export POSTGRES_HOST POSTGRES_PORT POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD
    export POSTGRES_CONNECTION_STRING
    
    # Use envsubst to replace variables and write output
    envsubst < "$template" > "$output"
}

# Generate Claude Desktop config
if [ -f "${SCRIPT_DIR}/claude-desktop-template.json" ]; then
    replace_vars "${SCRIPT_DIR}/claude-desktop-template.json" "${SCRIPT_DIR}/claude-desktop.json"
    echo -e "${GREEN}✓ Generated claude-desktop.json${NC}"
fi

# Generate Cursor config if template exists
if [ -f "${SCRIPT_DIR}/cursor-template.json" ]; then
    replace_vars "${SCRIPT_DIR}/cursor-template.json" "${SCRIPT_DIR}/cursor.json"
    echo -e "${GREEN}✓ Generated cursor.json${NC}"
fi

# Generate server configs if they exist
for template in "${SCRIPT_DIR}/servers/"*-template.json; do
    if [ -f "$template" ]; then
        filename=$(basename "$template" -template.json)
        replace_vars "$template" "${SCRIPT_DIR}/servers/${filename}.json"
        echo -e "${GREEN}✓ Generated servers/${filename}.json${NC}"
    fi
done

echo -e "\n${GREEN}Configuration generation complete!${NC}"
echo -e "Generated files are in: ${SCRIPT_DIR}"
echo -e "\nTo set up symbolic links, run: ${CLAUDE_DIR}/mcp/setup-links.sh"