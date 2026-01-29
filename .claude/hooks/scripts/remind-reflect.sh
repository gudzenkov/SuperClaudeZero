#!/bin/bash
# remind-reflect.sh - Stop hook
# Prompts orchestrator to invoke /reflect for session meta-learning
# Blocking execution - includes orchestrator checklist

source "$(dirname "$0")/lib/hook-utils.sh"
parse_hook_input

# Log stop event
if [ -n "$SESSION_ID" ] && [ -d "$SESSION_LOG_DIR" ]; then
    log_event "STOP_HOOK stop_hook_active=${STOP_HOOK_ACTIVE}"
fi

# Count agents spawned this session
AGENT_COUNT=0
if [ -d "$SESSION_LOG_DIR" ]; then
    AGENT_COUNT=$(find "$SESSION_LOG_DIR" -maxdepth 1 -type d | wc -l)
    AGENT_COUNT=$((AGENT_COUNT - 1))
fi

cat << EOF
<system-reminder>
[Stop:reflect] session=${SESSION_ID:-unknown} agents_spawned=${AGENT_COUNT}

SESSION REFLECTION PROMPT:
Before session ends, consider invoking /reflect to capture:
- Lessons learned from this session
- Patterns that worked well
- Errors and their resolutions
- Blockers encountered
- Suggestions for workflow improvement

ORCHESTRATOR CHECKLIST:
- [ ] All planned tasks completed or documented as pending
- [ ] Artifacts stored in correct locations
- [ ] No uncommitted changes (if applicable)
- [ ] Next steps documented if work is incomplete

Use /reflect to persist session insights for future reference.

Session log: ${SESSION_LOG_DIR:-n/a}
Transcript: ${TRANSCRIPT_PATH:-n/a}
</system-reminder>
EOF
