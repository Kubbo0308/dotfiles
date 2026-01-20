#!/bin/bash

# Serena MCP Server Launcher
# This script ensures a single Serena HTTP server is running and can be shared
# across multiple Claude Code sessions.
#
# Usage:
#   ./serena-wrapper.sh start    - Start Serena if not running
#   ./serena-wrapper.sh stop     - Stop running Serena server
#   ./serena-wrapper.sh status   - Check if Serena is running
#   ./serena-wrapper.sh restart  - Restart Serena server
#   ./serena-wrapper.sh url      - Print the Serena URL (for MCP config)

set -e

# Configuration
SERENA_PORT="${SERENA_PORT:-8765}"
SERENA_HOST="${SERENA_HOST:-127.0.0.1}"
SERENA_PID_FILE="${HOME}/.cache/serena/serena.pid"
SERENA_LOG_FILE="${HOME}/.cache/serena/serena.log"
UVX_PATH="${UVX_PATH:-${HOME}/.local/bin/uvx}"
SERENA_CONTEXT="${SERENA_CONTEXT:-claude-code}"

# Ensure cache directory exists
mkdir -p "${HOME}/.cache/serena"

# Function to check if Serena is running and healthy
is_serena_running() {
    # First check if port is in use
    if lsof -ti :${SERENA_PORT} >/dev/null 2>&1; then
        # Port is in use, check if it's Serena SSE endpoint
        if curl -s --max-time 2 -H "Accept: text/event-stream" "http://${SERENA_HOST}:${SERENA_PORT}/sse" 2>/dev/null | grep -q "endpoint"; then
            return 0
        fi
    fi

    # Also check PID file
    if [ -f "$SERENA_PID_FILE" ]; then
        local pid=$(cat "$SERENA_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            # Process exists, give it a moment and check endpoint
            sleep 1
            if curl -s --max-time 2 -H "Accept: text/event-stream" "http://${SERENA_HOST}:${SERENA_PORT}/sse" 2>/dev/null | grep -q "endpoint"; then
                return 0
            fi
        fi
    fi
    return 1
}

# Function to start Serena server
start_serena_server() {
    if is_serena_running; then
        echo "[serena] Already running on http://${SERENA_HOST}:${SERENA_PORT}"
        return 0
    fi

    echo "[serena] Starting Serena MCP server on http://${SERENA_HOST}:${SERENA_PORT}..."

    # Kill any existing process using the same port
    local existing_pid=$(lsof -ti :${SERENA_PORT} 2>/dev/null || true)
    if [ -n "$existing_pid" ]; then
        echo "[serena] Cleaning up stale process on port ${SERENA_PORT}..."
        kill $existing_pid 2>/dev/null || true
        sleep 1
    fi

    # Remove stale PID file
    rm -f "$SERENA_PID_FILE"

    # Start Serena with SSE transport in background
    nohup "$UVX_PATH" \
        --from "git+https://github.com/oraios/serena" \
        serena start-mcp-server \
        --context "$SERENA_CONTEXT" \
        --transport sse \
        --host "$SERENA_HOST" \
        --port "$SERENA_PORT" \
        --project-from-cwd \
        >> "$SERENA_LOG_FILE" 2>&1 &

    local pid=$!
    echo $pid > "$SERENA_PID_FILE"
    echo "[serena] Started with PID $pid"

    # Wait for server to be ready
    echo "[serena] Waiting for server to be ready..."
    local max_attempts=30
    local attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if curl -s --max-time 2 -H "Accept: text/event-stream" "http://${SERENA_HOST}:${SERENA_PORT}/sse" 2>/dev/null | grep -q "endpoint"; then
            echo "[serena] Server is ready!"
            return 0
        fi
        sleep 0.5
        attempt=$((attempt + 1))
    done

    echo "[serena] Warning: Server may still be starting. Check logs at $SERENA_LOG_FILE"
    return 0
}

# Function to stop Serena server
stop_serena_server() {
    echo "[serena] Stopping Serena server..."

    # Kill process from PID file
    if [ -f "$SERENA_PID_FILE" ]; then
        local pid=$(cat "$SERENA_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
            echo "[serena] Stopped process $pid"
        fi
        rm -f "$SERENA_PID_FILE"
    fi

    # Also kill any process on the port
    local existing_pid=$(lsof -ti :${SERENA_PORT} 2>/dev/null || true)
    if [ -n "$existing_pid" ]; then
        kill $existing_pid 2>/dev/null || true
        echo "[serena] Cleaned up process on port ${SERENA_PORT}"
    fi

    echo "[serena] Stopped"
}

# Function to show status
show_status() {
    if is_serena_running; then
        echo "[serena] Running on http://${SERENA_HOST}:${SERENA_PORT}"
        if [ -f "$SERENA_PID_FILE" ]; then
            echo "[serena] PID: $(cat "$SERENA_PID_FILE")"
        fi
        return 0
    else
        echo "[serena] Not running"
        return 1
    fi
}

# Main logic
case "${1:-start}" in
    start)
        start_serena_server
        ;;
    stop)
        stop_serena_server
        ;;
    restart)
        stop_serena_server
        sleep 1
        start_serena_server
        ;;
    status)
        show_status
        ;;
    url)
        echo "http://${SERENA_HOST}:${SERENA_PORT}/sse"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|url}"
        exit 1
        ;;
esac

