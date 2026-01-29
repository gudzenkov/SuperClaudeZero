#!/bin/bash
# hook-utils.sh - Shared utilities for Claude Code hooks
# Source this file in hook scripts: source "$(dirname "$0")/lib/hook-utils.sh"

set -euo pipefail

# Ensure jq is available
if ! command -v jq &> /dev/null; then
    echo "jq required for hook parsing" >&2
    exit 1
fi

# Read hook input from stdin (call once, store in global)
HOOK_INPUT="${HOOK_INPUT:-$(cat)}"

# =============================================================================
# Common fields (available in all events)
# =============================================================================
parse_common() {
    HOOK_EVENT=$(echo "$HOOK_INPUT" | jq -r '.hook_event_name // empty')
    SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty')
    TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty')
    CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty')
    PERMISSION_MODE=$(echo "$HOOK_INPUT" | jq -r '.permission_mode // empty')

    # Derived paths - sanitize PROJECT_NAME to prevent command injection
    PROJECT_NAME="$(basename "$CWD" | sed 's/[^a-zA-Z0-9_-]//g')"
    SESSION_LOG_DIR="${CWD}/logs/sessions/${SESSION_ID}"
}

# =============================================================================
# Event-specific parsers
# =============================================================================

# SessionStart: source, model, agent_type (if started with --agent)
parse_session_start() {
    parse_common
    SOURCE=$(echo "$HOOK_INPUT" | jq -r '.source // empty')
    MODEL=$(echo "$HOOK_INPUT" | jq -r '.model // empty')
    AGENT_TYPE=$(echo "$HOOK_INPUT" | jq -r '.agent_type // empty')  # Present if --agent flag used
}

# SubagentStart: agent_id, agent_type
parse_subagent_start() {
    parse_common
    AGENT_ID=$(echo "$HOOK_INPUT" | jq -r '.agent_id // empty')
    AGENT_TYPE=$(echo "$HOOK_INPUT" | jq -r '.agent_type // empty')
    AGENT_LOG_DIR="${SESSION_LOG_DIR}/${AGENT_ID}"
}

# SubagentStop: agent_id, agent_transcript_path, stop_hook_active
parse_subagent_stop() {
    parse_common
    AGENT_ID=$(echo "$HOOK_INPUT" | jq -r '.agent_id // empty')
    AGENT_TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.agent_transcript_path // empty')
    STOP_HOOK_ACTIVE=$(echo "$HOOK_INPUT" | jq -r '.stop_hook_active // false')
    AGENT_LOG_DIR="${SESSION_LOG_DIR}/${AGENT_ID}"
}

# Stop: stop_hook_active
parse_stop() {
    parse_common
    STOP_HOOK_ACTIVE=$(echo "$HOOK_INPUT" | jq -r '.stop_hook_active // false')
}

# SessionEnd: reason
parse_session_end() {
    parse_common
    REASON=$(echo "$HOOK_INPUT" | jq -r '.reason // empty')
}

# Setup: trigger (init or maintenance)
parse_setup() {
    parse_common
    TRIGGER=$(echo "$HOOK_INPUT" | jq -r '.trigger // empty')
    export TRIGGER
}

# =============================================================================
# Auto-parser: call appropriate parser based on hook_event_name
# =============================================================================
parse_hook_input() {
    # First get the event name
    HOOK_EVENT=$(echo "$HOOK_INPUT" | jq -r '.hook_event_name // empty')

    case "$HOOK_EVENT" in
        SessionStart)   parse_session_start ;;
        SubagentStart)  parse_subagent_start ;;
        SubagentStop)   parse_subagent_stop ;;
        Stop)           parse_stop ;;
        SessionEnd)     parse_session_end ;;
        Setup)          parse_setup ;;
        *)              parse_common ;;
    esac
}

# =============================================================================
# Log directory helpers
# =============================================================================

# Ensure session log directory exists
ensure_session_dir() {
    mkdir -p "$SESSION_LOG_DIR"
}

# Ensure agent log directory exists
ensure_agent_dir() {
    mkdir -p "$AGENT_LOG_DIR"
}

# Read agent start context (for SubagentStop hooks)
read_agent_start() {
    local agent_start_file="${AGENT_LOG_DIR}/agent-start.jsonl"
    if [ -f "$agent_start_file" ]; then
        # Read first line of JSONL
        local first_line
        first_line=$(head -1 "$agent_start_file")
        AGENT_TYPE=$(echo "$first_line" | jq -r '.agent_type // "unknown"')
        AGENT_START_TIME=$(echo "$first_line" | jq -r '.timestamp // "unknown"')
    else
        AGENT_TYPE="unknown"
        AGENT_START_TIME="unknown"
    fi
}

# =============================================================================
# JSON writers
# =============================================================================

# Session events use JSONL (append) to preserve history across resumes
write_session_start_jsonl() {
    ensure_session_dir
    local ts
    ts=$(date -Iseconds)
    # Append as single-line JSON to JSONL file
    jq -c -n \
        --arg event "SessionStart" \
        --arg timestamp "$ts" \
        --arg session_id "$SESSION_ID" \
        --arg project "$PROJECT_NAME" \
        --arg cwd "$CWD" \
        --arg source "$SOURCE" \
        --arg model "${MODEL:-}" \
        --arg agent_type "${AGENT_TYPE:-}" \
        --arg permission_mode "$PERMISSION_MODE" \
        --arg transcript_path "$TRANSCRIPT_PATH" \
        '{event: $event, timestamp: $timestamp, session_id: $session_id, project: $project, cwd: $cwd, source: $source, model: $model, agent_type: $agent_type, permission_mode: $permission_mode, transcript_path: $transcript_path}' \
        >> "${SESSION_LOG_DIR}/session-start.jsonl"
    # Log to session events
    echo "${ts} SESSION_START source=${SOURCE}" >> "${SESSION_LOG_DIR}/events.log"
}

write_agent_start_jsonl() {
    ensure_agent_dir
    local ts
    ts=$(date -Iseconds)
    # Append as single-line JSON to JSONL file
    jq -c -n \
        --arg event "SubagentStart" \
        --arg timestamp "$ts" \
        --arg session_id "$SESSION_ID" \
        --arg agent_id "$AGENT_ID" \
        --arg agent_type "$AGENT_TYPE" \
        --arg project "$PROJECT_NAME" \
        --arg cwd "$CWD" \
        '{event: $event, timestamp: $timestamp, session_id: $session_id, agent_id: $agent_id, agent_type: $agent_type, project: $project, cwd: $cwd}' \
        >> "${AGENT_LOG_DIR}/agent-start.jsonl"
    # Log to session events
    echo "${ts} AGENT_START agent=${AGENT_ID} type=${AGENT_TYPE}" >> "${SESSION_LOG_DIR}/events.log"
}

# Agent stop uses JSONL to capture both stop events (validation + reflexion)
write_agent_stop_jsonl() {
    read_agent_start
    local ts
    ts=$(date -Iseconds)
    # Append as single-line JSON to JSONL file
    jq -c -n \
        --arg event "SubagentStop" \
        --arg timestamp "$ts" \
        --arg session_id "$SESSION_ID" \
        --arg agent_id "$AGENT_ID" \
        --arg agent_type "$AGENT_TYPE" \
        --arg agent_start_time "$AGENT_START_TIME" \
        --arg agent_transcript_path "$AGENT_TRANSCRIPT_PATH" \
        --arg transcript_path "$TRANSCRIPT_PATH" \
        --arg cwd "$CWD" \
        --arg permission_mode "$PERMISSION_MODE" \
        --argjson stop_hook_active "$STOP_HOOK_ACTIVE" \
        '{event: $event, timestamp: $timestamp, session_id: $session_id, agent_id: $agent_id, agent_type: $agent_type, agent_start_time: $agent_start_time, agent_transcript_path: $agent_transcript_path, transcript_path: $transcript_path, cwd: $cwd, permission_mode: $permission_mode, stop_hook_active: $stop_hook_active}' \
        >> "${AGENT_LOG_DIR}/agent-stop.jsonl"
    # Log to session events
    echo "${ts} AGENT_STOP agent=${AGENT_ID} type=${AGENT_TYPE} stop_hook_active=${STOP_HOOK_ACTIVE}" >> "${SESSION_LOG_DIR}/events.log"
}

write_session_end_jsonl() {
    local ts
    ts=$(date -Iseconds)
    local agent_count=0
    if [ -d "$SESSION_LOG_DIR" ]; then
        # Validate and canonicalize path to prevent directory traversal
        local safe_dir
        safe_dir="$(readlink -f "$SESSION_LOG_DIR")"
        if [[ "$safe_dir" == "$CWD"/logs/sessions/* ]]; then
            agent_count=$(find "$safe_dir" -maxdepth 1 -type d 2>/dev/null | wc -l)
            agent_count=$((agent_count - 1))
        fi
    fi
    # Append as single-line JSON to JSONL file
    jq -c -n \
        --arg event "SessionEnd" \
        --arg timestamp "$ts" \
        --arg session_id "$SESSION_ID" \
        --arg project "$PROJECT_NAME" \
        --arg reason "$REASON" \
        --argjson agents_spawned "$agent_count" \
        --arg transcript_path "$TRANSCRIPT_PATH" \
        '{event: $event, timestamp: $timestamp, session_id: $session_id, project: $project, reason: $reason, agents_spawned: $agents_spawned, transcript_path: $transcript_path}' \
        >> "${SESSION_LOG_DIR}/session-end.jsonl"
    # Log to session events
    echo "${ts} SESSION_END reason=${REASON} agents=${agent_count}" >> "${SESSION_LOG_DIR}/events.log"
}

# =============================================================================
# Event logging
# =============================================================================

log_event() {
    local event_name="$1"
    local log_dir="${2:-$SESSION_LOG_DIR}"
    echo "$(date -Iseconds) ${event_name}" >> "${log_dir}/events.log"
}
