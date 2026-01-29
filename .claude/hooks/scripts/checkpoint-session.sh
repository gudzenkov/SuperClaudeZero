#!/bin/bash
# checkpoint-session.sh - SessionEnd hook
# Non-blocking execution - cleanup and logging only
# Cannot invoke skills (SessionEnd cannot block)

source "$(dirname "$0")/lib/hook-utils.sh"
parse_hook_input

# Write session end to session log directory (JSONL for append on resume)
if [ -n "$SESSION_ID" ] && [ -d "$SESSION_LOG_DIR" ]; then
    write_session_end_jsonl
fi

# Output minimal confirmation (non-blocking, goes to verbose mode)
echo "Session checkpoint: ${SESSION_ID} ended (${REASON}) at $(date -Iseconds)"
