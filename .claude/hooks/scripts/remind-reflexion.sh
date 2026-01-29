#!/bin/bash
# remind-reflexion.sh - SubagentStop hook (phase 2: stop_hook_active=true)
# Only triggers AFTER validation, prompts agent to invoke /reflexion

source "$(dirname "$0")/lib/hook-utils.sh"
parse_hook_input

# Only trigger reflexion after validation has run (stop_hook_active=true)
if [ "$STOP_HOOK_ACTIVE" != "true" ]; then
    exit 0
fi

# Write agent-stop.jsonl (logs internally) and log reflexion prompt
if [ -n "$AGENT_ID" ] && [ -d "$AGENT_LOG_DIR" ]; then
    write_agent_stop_jsonl
    log_event "REFLEXION_PROMPT" "$AGENT_LOG_DIR"
fi

# Read agent start for output
read_agent_start

cat << EOF
<system-reminder>
[SubagentStop:reflexion] session=${SESSION_ID:-unknown} agent=${AGENT_ID:-unknown} type=${AGENT_TYPE}
Started: ${AGENT_START_TIME}

REFLEXION CHECK (post-validation):
If you encountered any of the following during this task:
- Errors that required debugging
- Wrong assumptions that needed correction
- Missing dependencies or unexpected behaviors
- Workarounds for undocumented issues

Consider invoking /reflexion to capture:
- known_issue: What went wrong
- cause: Root cause analysis
- solution: How it was resolved
- prevention: How to avoid in future

High signal/noise threshold: Only record significant learnings.

Agent log: ${AGENT_LOG_DIR:-n/a}
Transcript: ${AGENT_TRANSCRIPT_PATH:-n/a}
</system-reminder>
EOF
