#!/bin/bash
# remind-validate.sh - SubagentStop hook (phase 1: stop_hook_active=false)
# Outputs validation checklist, writes to agent-stop.jsonl
# Blocking execution - agent decides whether to act

source "$(dirname "$0")/lib/hook-utils.sh"
parse_hook_input

# Only trigger validation on the first stop event (stop_hook_active=false)
if [ "$STOP_HOOK_ACTIVE" != "false" ]; then
    exit 0
fi

# Write agent-stop.jsonl (logs internally) and log validation prompt
if [ -n "$AGENT_ID" ] && [ -d "$AGENT_LOG_DIR" ]; then
    write_agent_stop_jsonl
    log_event "VALIDATION_PROMPT" "$AGENT_LOG_DIR"
fi

# Read agent start for output
read_agent_start

cat << EOF
<system-reminder>
[SubagentStop:validate] session=${SESSION_ID:-unknown} agent=${AGENT_ID:-unknown} type=${AGENT_TYPE}
Started: ${AGENT_START_TIME}

SELF-VALIDATION CHECKLIST:
Before completing, verify:
1. [ ] All acceptance criteria from requirements are met
2. [ ] Artifact schema is valid (check templates if applicable)
3. [ ] No assumptions made without evidence (verify via docs/code)
4. [ ] Tests pass (if applicable)
5. [ ] Output stored in correct location

If any item fails, address before completing.
If unable to verify, note the gap explicitly.

Agent log: ${AGENT_LOG_DIR:-n/a}
</system-reminder>
EOF
