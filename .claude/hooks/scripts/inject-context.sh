#!/bin/bash
# inject-context.sh - SessionStart/SubagentStart hook
# Non-blocking execution

source "$(dirname "$0")/lib/hook-utils.sh"
parse_hook_input

case "$HOOK_EVENT" in
    SessionStart)
        write_session_start_jsonl
        ;;
    SubagentStart)
        [ -z "$AGENT_ID" ] && { echo "Missing agent_id" >&2; exit 1; }
        write_agent_start_jsonl
        ;;
esac

# Output context for Claude (SessionStart stdout goes to context)
cat << EOF
<system-reminder>
[${HOOK_EVENT}] session=${SESSION_ID} agent=${AGENT_ID:-n/a} type=${AGENT_TYPE:-n/a}
Log: logs/sessions/${SESSION_ID}/${AGENT_ID:-}
</system-reminder>
EOF
