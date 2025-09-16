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
ENV_FILE="${CLAUDE_DIR}/environments/.env.local"
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}Warning: .env.local not found!${NC}"
    echo "Creating .env.local from .env.example..."
    cp "${CLAUDE_DIR}/environments/.env.example" "$ENV_FILE"
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
    
    # Read template and replace variables
    content=$(cat "$template")
    
    # Replace common variables with proper defaults
    USER_HOME="${USER_HOME:-$HOME}"
    MCP_FS_PATH_1="${MCP_FS_PATH_1:-$HOME/Desktop}"
    MCP_FS_PATH_2="${MCP_FS_PATH_2:-$HOME/Downloads}"
    
    content="${content//\$\{USER_HOME\}/${USER_HOME}}"
    content="${content//\$\{MCP_FS_PATH_1\}/${MCP_FS_PATH_1}}"
    content="${content//\$\{MCP_FS_PATH_2\}/${MCP_FS_PATH_2}}"
    content="${content//\${GITHUB_TOKEN}/${GITHUB_TOKEN}}"
    content="${content//\${NOTION_API_KEY}/${NOTION_API_KEY}}"
    content="${content//\${AWS_ACCESS_KEY_ID}/${AWS_ACCESS_KEY_ID}}"
    content="${content//\${AWS_SECRET_ACCESS_KEY}/${AWS_SECRET_ACCESS_KEY}}"
    content="${content//\${AWS_REGION}/${AWS_REGION}}"
    content="${content//\${CONTEXT7_API_KEY}/${CONTEXT7_API_KEY}}"
    content="${content//\${BRAVE_API_KEY}/${BRAVE_API_KEY}}"
    
    # Write output
    echo "$content" > "$output"
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