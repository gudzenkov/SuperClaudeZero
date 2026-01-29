# ADR-001: Hook Behavior Pattern

**Status**: Accepted
**Version**: 1.0
**Date**: 2026-01-24 (revised)
**Context**: SuperClaudeZero v0 hook system design

---

## Context

SuperClaudeZero needs lifecycle event handling for:
1. Session initialization (inject context variables)
2. Agent completion (validate, learn from errors)
3. Session end (checkpoint state)

Different hook types have different capabilities:
- **SubagentStop**: Can block - agent hasn't completed yet
- **SessionEnd**: Cannot block - session is ending, too late

## Decision

**Use blocking hooks (SubagentStop, Stop) to surface reminders; agent decides action. SessionEnd for cleanup only.**

> **Clarification**: "Blocking" means the hook output is injected and the agent/orchestrator must acknowledge it before completing. However, the hook content is a **reminder** (checklist, prompt) - the agent decides whether to act on it. This is distinct from hard enforcement (v1 Guardrails) which would reject non-compliant responses.

### Hook Capabilities

> **Important**: Stop ≠ SessionEnd
> - **Stop**: Fires when Claude finishes responding. CAN block. CAN invoke skills.
> - **SessionEnd**: Fires when session actually closes. CANNOT block. Cleanup only.

| Hook Event | Trigger | Blocking | Can Invoke Skills | Use For |
|------------|---------|----------|-------------------|---------|
| **SessionStart** | Session begins | No | No | Inject context variables |
| **SubagentStop** | Agent completes | **Yes** | **Yes** | Agent validation, reflexion |
| **Stop** | Claude finishes responding | **Yes** | **Yes** | Orchestrator checklist, `/reflect` |
| **SessionEnd** | Session closes | No | No | Cleanup, logging, checkpoint |

### Hook Implementation

```yaml
# Agent frontmatter - path relative to project root
hooks:
  SubagentStop:
    - type: command
      command: "./.claude/hooks/scripts/remind-validate.sh"
    - type: command
      command: "./.claude/hooks/scripts/remind-reflexion.sh"
```

```yaml
# Global settings.json - path relative to ~/.claude/
hooks:
  Stop:
    - type: command
      command: "./hooks/scripts/remind-reflect.sh"
  SessionEnd:
    - type: command
      command: "./hooks/scripts/checkpoint-session.sh"
```

### SubagentStop Scripts (Blocking)

```bash
# remind-validate.sh - Agent MUST respond before completing
cat << 'EOF'
<system-reminder>
SELF-VALIDATION CHECKLIST:
Before completing, verify:
1. [ ] All acceptance criteria from requirements are met
2. [ ] Artifact schema is valid
3. [ ] No assumptions without evidence
4. [ ] Tests pass (if applicable)

You MUST address this checklist before completing.
</system-reminder>
EOF
```

```bash
# remind-reflexion.sh - Agent should invoke /reflexion if errors occurred
cat << 'EOF'
<system-reminder>
REFLEXION CHECK:
If you encountered errors or unexpected behavior during this task:
1. Invoke /reflexion to document the issue
2. Include root cause and prevention steps

This helps prevent similar issues in future sessions.
</system-reminder>
EOF
```

### Stop Script (Blocking - Orchestrator Reflection)

```bash
# remind-reflect.sh - Prompt orchestrator to invoke /reflect
#!/bin/bash

cat << 'EOF'
<system-reminder>
SESSION REFLECTION:
Before ending, consider invoking /reflect to:
1. Analyze session outcomes and learnings
2. Capture patterns for future sessions
3. Update knowledge base with insights

This improves future session performance.
</system-reminder>
EOF
```

### SessionEnd Script (Non-blocking - Cleanup)

```bash
# checkpoint-session.sh - Capture state for later analysis
#!/bin/bash
# Output session state (optional, for external tooling)

cat << EOF
{
  "session_id": "${CLAUDE_SESSION_ID}",
  "project": "${PROJECT_NAME}",
  "cwd": "$(pwd)",
  "timestamp": "$(date -Iseconds)"
}
EOF
```

## Rationale

### SubagentStop: Agent-Level Enforcement

SubagentStop fires **when an agent completes**. The agent must process the hook output, so we can:
- Present validation checklists the agent must address
- Prompt for `/reflexion` invocation if errors occurred
- Block until the agent responds appropriately

### Stop: Orchestrator-Level Reflection

Stop fires **when Claude finishes responding** (but session is still active). We can:
- Prompt the orchestrator to invoke `/reflect`
- Present session-level checklists
- Block until reflection is considered

### SessionEnd: Cleanup Only

SessionEnd fires **as the session actually closes**. It's too late to:
- Invoke skills (no agent to run them)
- Request user input
- Block for any action

Use SessionEnd only for passive state capture, logging statistics, or cleanup tasks.

## Consequences

### Positive

1. **SubagentStop enforcement**: Agent validation and reflexion actually happen
2. **Stop enforcement**: Orchestrator-level `/reflect` can be prompted
3. **Clear capability model**: Know what each hook can do
4. **SessionEnd cleanup**: Non-blocking state capture for external analysis

### Negative

1. **SubagentStop blocking**: May slow agent completion
2. **Stop blocking**: May delay session if reflection is long
3. **SessionEnd limitations**: Cannot invoke skills at session close

### Mitigations

1. **Keep hook scripts fast**: Minimize SubagentStop and Stop latency
2. **Stop prompts reflection**: User is reminded to `/reflect` automatically
3. **External tooling**: Process SessionEnd checkpoints asynchronously

## Alternatives Considered

### Alternative 1: Pure Reminder (No Enforcement)

All hooks just suggest; agent decides.

**Rejected**: SubagentStop CAN enforce, and validation is important enough to require it.

### Alternative 2: All Reflection at SessionEnd

Try to invoke `/reflect` at SessionEnd.

**Rejected**: SessionEnd cannot block or invoke skills - too late.

### Alternative 3: No SessionEnd Hook

Skip session end hook entirely.

**Rejected**: State checkpointing and cleanup have value for external analysis and debugging.

## Related Decisions

- **ADR-002**: Four-Tier Memory (Reflexion storage)
- **ADR-003**: Minimal MCP Footprint
- **ADR-004**: Skill-Agent Invocation Paths (SubagentStop hooks fire for both paths)

## References

- [Claude Code Hooks Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [PRD.md FR3: Hooks System](../PRD.md#fr3-hooks-system)
