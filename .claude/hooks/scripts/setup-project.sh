#!/bin/bash
# setup-project.sh - Setup hook (runs on --init, --init-only, --maintenance)
# One-time project initialization, separate from per-session context

source "$(dirname "$0")/lib/hook-utils.sh"

# Parse Setup-specific fields
TRIGGER=$(echo "$HOOK_INPUT" | jq -r '.trigger // empty')  # "init" or "maintenance"
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty')

PROJECT_NAME="${CWD##*/}"
SESSION_LOG_DIR="${CWD}/logs/sessions/${SESSION_ID}"

# Ensure log directory exists
mkdir -p "$SESSION_LOG_DIR"

# Log setup event
echo "$(date -Iseconds) SETUP trigger=${TRIGGER}" >> "${SESSION_LOG_DIR}/events.log"

# Project-specific initialization
case "$TRIGGER" in
    init)
        # First-time project setup
        # Check for required directories
        [ ! -d "${CWD}/logs" ] && mkdir -p "${CWD}/logs/sessions"
        [ ! -d "${CWD}/.serena/memories" ] && mkdir -p "${CWD}/.serena/memories"

        # Output context for Claude
        cat << EOF
<system-reminder>
[Setup:init] Project ${PROJECT_NAME} initialized
- Log directory: logs/sessions/
- Memory directory: .serena/memories/
</system-reminder>
EOF
        ;;
    maintenance)
        # Periodic maintenance tasks
        # Clean old session logs (older than 30 days)
        # find "${CWD}/logs/sessions" -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null || true

        cat << EOF
<system-reminder>
[Setup:maintenance] Project ${PROJECT_NAME} maintenance complete
</system-reminder>
EOF
        ;;
esac
