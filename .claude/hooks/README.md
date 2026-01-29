# SuperClaudeZero Hook System

**Version**: 0.1.0

Documentation for SCZ hook scripts and lifecycle events.

---

## Overview

SCZ uses Claude Code hooks to inject context, prompt validation, and capture session learnings. Hooks follow the **reminder pattern** (ADR-001): they prompt agents but don't enforce behavior.

SCZ supports two hook types:
- **Command-based hooks**: Shell scripts installed globally (`~/.claude/`) - shared across all projects
- **Prompt-based hooks**: Claude evaluation installed per-project (`.claude/`) - portable with the codebase

---

## Hook Events

| Event | When Fired | Blocking | Purpose |
|-------|------------|----------|---------|
| `Setup` | `--init` or `--maintenance` | No | One-time project initialization |
| `SessionStart` | Session begins | No | Inject context, log session start |
| `SubagentStart` | Subagent spawned | No | Inject context, log agent start |
| `SubagentStop` | Agent completes | Yes | Validation reminders, reflexion prompt |
| `Stop` | Main session stops | Yes | Session reflection prompt |
| `SessionEnd` | Session terminates | No | Cleanup and logging |

### Blocking vs Non-Blocking

- **Blocking**: Hook output is shown to the agent, which can act on it before completing
- **Non-Blocking**: Hook runs but doesn't interrupt the workflow

### Hook Input (stdin JSON)

Command-based hooks receive JSON input via stdin containing:

```json
{
  "session_id": "<uuid>",
  "transcript_path": "/path/to/.claude/projects/.../session.jsonl",
  "cwd": "/path/to/project",
  "permission_mode": "default",
  "hook_event_name": "SessionStart"
}
```

**Event-specific fields**:
- `Setup`: `trigger` ("init" or "maintenance")
- `SessionStart`: `source`, `model`, `agent_type` (if started with --agent)
- `SubagentStart`: `agent_id`, `agent_type`
- `SubagentStop`: `agent_id`, `agent_transcript_path`, `stop_hook_active`
- `Stop`: `stop_hook_active`
- `SessionEnd`: `reason`

**Important**: Session data is passed via stdin, not environment variables. Use `jq` to parse:

```bash
HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty')
```

---

## Shared Library: hook-utils.sh

All hook scripts use a shared library at `hooks/scripts/lib/hook-utils.sh` for:

- **Input Parsing**: Auto-detect event type and parse appropriate fields
- **Log Directory Management**: Create and manage session/agent log directories
- **JSON Writers**: Write structured logs for events (JSONL for append, JSON for single)

### Usage

Source the library at the start of any hook script:

```bash
#!/bin/bash
source "$(dirname "$0")/lib/hook-utils.sh"
parse_hook_input

# Now use parsed variables:
echo "Session: $SESSION_ID"
echo "Event: $HOOK_EVENT"
echo "Project: $PROJECT_NAME"
```

### Available Functions

| Function | Purpose |
|----------|---------|
| `parse_hook_input` | Auto-detect event and parse all fields |
| `parse_common` | Parse fields available in all events |
| `parse_setup` | Parse Setup-specific fields |
| `parse_session_start` | Parse SessionStart-specific fields |
| `parse_subagent_start` | Parse SubagentStart-specific fields |
| `parse_subagent_stop` | Parse SubagentStop-specific fields |
| `parse_stop` | Parse Stop-specific fields |
| `parse_session_end` | Parse SessionEnd-specific fields |
| `ensure_session_dir` | Create session log directory |
| `ensure_agent_dir` | Create agent log directory |
| `read_agent_start` | Load agent start context for SubagentStop |
| `write_session_start_jsonl` | Append session start to JSONL |
| `write_agent_start_jsonl` | Append agent start to JSONL |
| `write_agent_stop_jsonl` | Append agent stop to JSONL (both phases) |
| `write_session_end_jsonl` | Append session end to JSONL |
| `log_event` | Write timestamped event to log |

### Parsed Variables

After calling `parse_hook_input`, these variables are available:

**Common (all events)**:
- `HOOK_EVENT`: Event name
- `SESSION_ID`: Session identifier
- `TRANSCRIPT_PATH`: Path to session transcript
- `CWD`: Current working directory
- `PERMISSION_MODE`: Permission level
- `PROJECT_NAME`: Derived from CWD
- `SESSION_LOG_DIR`: Path to session logs

**SessionStart additions**:
- `SOURCE`: Session source
- `MODEL`: Model name
- `AGENT_TYPE`: Agent type (if --agent flag used)

**SubagentStart/SubagentStop additions**:
- `AGENT_ID`: Agent identifier
- `AGENT_TYPE`: Agent type
- `AGENT_LOG_DIR`: Path to agent logs
- `AGENT_TRANSCRIPT_PATH`: Agent transcript path (SubagentStop only)
- `STOP_HOOK_ACTIVE`: Whether stop hook is active (SubagentStop only)

**SessionEnd additions**:
- `REASON`: Termination reason

---

## Global Hooks (Command-Based)

Installed to `~/.claude/settings.json` via `--global`.

### setup-project.sh

**Event**: `Setup`
**Blocking**: No
**Triggers**: `claude --init` or `claude --maintenance`

One-time project initialization, separate from per-session context:

- **init**: Creates required directories (`logs/sessions/`, `.serena/memories/`)
- **maintenance**: Reserved for periodic cleanup tasks (e.g., old log removal)

**Usage**:
```bash
# First-time project setup
claude --init

# Periodic maintenance (user-triggered)
claude --maintenance
```

**Output Format**:
```xml
<system-reminder>
[Setup:init] Project my-project initialized
- Log directory: logs/sessions/
- Memory directory: .serena/memories/
</system-reminder>
```

---

### inject-context.sh

**Events**: `SessionStart`, `SubagentStart`
**Blocking**: No

Handles both session and agent initialization:

- **SessionStart**: Logs session start to `logs/sessions/<session_id>/session-start.jsonl`
- **SubagentStart**: Logs agent start to `logs/sessions/<session_id>/<agent_id>/agent-start.json`

**Output Format**:
```xml
<system-reminder>
[SessionStart] session=<uuid> agent=n/a type=n/a
Log: logs/sessions/<session_id>/
</system-reminder>
```

For SubagentStart:
```xml
<system-reminder>
[SubagentStart] session=<uuid> agent=<agent_id> type=<agent_type>
Log: logs/sessions/<session_id>/<agent_id>/
</system-reminder>
```

---

### remind-reflect.sh

**Event**: `Stop`
**Blocking**: Yes

Prompts the orchestrator to invoke `/reflect` for session meta-learning before session ends. Includes orchestrator checklist:
- All tasks completed or documented
- Artifacts in correct locations
- No uncommitted changes
- Next steps documented

---

### remind-validate.sh

**Event**: `SubagentStop`
**Blocking**: Yes
**Condition**: Only fires when `stop_hook_active=false` (first phase)

Outputs validation checklist reminder for agent self-check before completing:
- Acceptance criteria met
- Artifact schema valid
- No unverified assumptions
- Tests pass (if applicable)
- Output in correct location

Writes first entry to `agent-stop.jsonl`.

---

### remind-reflexion.sh

**Event**: `SubagentStop`
**Blocking**: Yes
**Condition**: Only fires when `stop_hook_active=true` (second phase)

Prompts agent to invoke `/reflexion` if errors were encountered during the task:
- Errors that required debugging
- Wrong assumptions that needed correction
- Missing dependencies or unexpected behaviors
- Workarounds for undocumented issues

High signal/noise threshold: Only significant learnings are recorded.

Writes second entry to `agent-stop.jsonl`.

---

### checkpoint-session.sh

**Event**: `SessionEnd`
**Blocking**: No

Performs cleanup at session termination:
- Logs session end timestamp to `logs/sessions/<session_id>/session-end.jsonl`
- Records agent count and termination reason
- Cannot invoke skills (SessionEnd is non-blocking)

---

## Two-Phase SubagentStop Flow

The SubagentStop event fires twice per agent completion, controlled by the `stop_hook_active` field:

| Phase | `stop_hook_active` | Script | Action |
|-------|-------------------|--------|--------|
| 1 (Validation) | `false` | `remind-validate.sh` | Self-validation checklist |
| 2 (Reflexion) | `true` | `remind-reflexion.sh` | Reflexion prompt if errors |

**Flow**:
1. Agent completes task and attempts to stop
2. SubagentStop fires with `stop_hook_active=false`
3. `remind-validate.sh` outputs validation checklist, writes to `agent-stop.jsonl`
4. Agent responds to validation (may continue or complete)
5. SubagentStop fires again with `stop_hook_active=true`
6. `remind-reflexion.sh` outputs reflexion prompt, appends to `agent-stop.jsonl`
7. Agent decides whether to invoke `/reflexion`

Both phases are logged to `agent-stop.jsonl` as separate JSONL entries.

---

## Project Hooks (Prompt-Based)

Installed to `.claude/settings.json` via `--project`. These are **portable alternatives** to global command-based hooks - they travel with the codebase and don't require script installation.

Prompt-based hooks use Claude to evaluate conditions and return JSON responses. They provide intelligent evaluation without requiring shell scripts on the user's machine.

### Stop Hook

**Event**: `Stop`
**Type**: prompt

Evaluates whether Claude should stop working:

```json
{
  "type": "prompt",
  "prompt": "Analyze the conversation and determine if: 1. All user-requested tasks are complete 2. Any errors need to be addressed 3. Follow-up work is needed\n\nRespond with JSON: {\"ok\": true} to allow stopping, or {\"ok\": false, \"reason\": \"your explanation\"} to continue working.",
  "timeout": 30
}
```

---

### SubagentStop Hook

**Event**: `SubagentStop`
**Type**: prompt

Validates subagent completion:

```json
{
  "type": "prompt",
  "prompt": "Check if: - The subagent completed its assigned task - Any errors occurred that need fixing - Additional context gathering is needed\n\nReturn: {\"ok\": true} to allow stopping, or {\"ok\": false, \"reason\": \"explanation\"} to continue."
}
```

---

## Log Structure

Hooks write structured logs to `logs/sessions/` in the project directory:

```
logs/sessions/<session_id>/
├── session-start.jsonl      # Session start events (JSONL for resume tracking)
├── session-end.jsonl        # Session end events (JSONL for resume tracking)
├── events.log               # Timestamped event log
└── <agent_id>/              # Per-agent directory
    ├── agent-start.jsonl    # Agent start events (JSONL for consistency)
    └── agent-stop.jsonl     # Agent stop events (JSONL for two-phase flow)
```

### File Formats

| File | Format | Append Pattern | Purpose |
|------|--------|----------------|---------|
| `session-start.jsonl` | JSONL | Append per resume | Track session resumes |
| `session-end.jsonl` | JSONL | Append per resume | Track session ends |
| `agent-start.jsonl` | JSONL | Append | Agent start context |
| `agent-stop.jsonl` | JSONL | Append per phase | Track both SubagentStop phases |
| `events.log` | Text | Append | Human-readable event timeline |

### JSONL Format

Session and agent stop files use JSONL (JSON Lines) format for append support:

```json
{"event":"SessionStart","timestamp":"2025-01-25T10:00:00+00:00","session_id":"abc123",...}
{"event":"SessionStart","timestamp":"2025-01-25T11:00:00+00:00","session_id":"abc123",...}
```

Each line is a complete JSON object. This allows:
- Multiple session resumes to be tracked
- Both SubagentStop phases to be recorded
- Easy parsing with `jq` or line-by-line processing

---

## Configuration

### Global Configuration (`~/.claude/settings.json`)

```json
{
  "hooks": {
    "Setup": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/scripts/setup-project.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/scripts/inject-context.sh"
          }
        ]
      }
    ],
    "SubagentStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/scripts/inject-context.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/scripts/remind-validate.sh"
          },
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/scripts/remind-reflexion.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/scripts/remind-reflect.sh"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/scripts/checkpoint-session.sh"
          }
        ]
      }
    ]
  }
}
```

### Project Configuration (`.claude/settings.json`)

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Analyze the conversation and determine if all tasks are complete...",
            "timeout": 30
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if the subagent completed its assigned task..."
          }
        ]
      }
    ]
  }
}
```

---

## Adding Custom Hooks

### Command-Based Hook

1. Create script in `~/.claude/hooks/scripts/`
2. Source hook-utils: `source "$(dirname "$0")/lib/hook-utils.sh"`
3. Call `parse_hook_input` to parse stdin JSON
4. Make executable: `chmod +x script.sh`
5. Add to `~/.claude/settings.json` under appropriate event
6. Output `<system-reminder>` tags for agent visibility

**Example**:
```bash
#!/bin/bash
# my-custom-hook.sh

source "$(dirname "$0")/lib/hook-utils.sh"
parse_hook_input

cat << EOF
<system-reminder>
Custom reminder for session ${SESSION_ID}
Project: ${PROJECT_NAME}
</system-reminder>
EOF
```

### Prompt-Based Hook

1. Add to `.claude/settings.json` under appropriate event
2. Define prompt that evaluates conditions
3. Return JSON with `ok` boolean and optional `reason`

**Example**:
```json
{
  "type": "prompt",
  "prompt": "Your evaluation prompt here. Return: {\"ok\": true} or {\"ok\": false, \"reason\": \"explanation\"}",
  "timeout": 30
}
```

---

## Design Principles

### Reminder, Not Enforcement (ADR-001)

Hooks **suggest** actions; agents **decide** whether to act. This avoids:
- False positives from rigid enforcement
- Blocking legitimate workflows
- Removing agent judgment

### Minimal Output

Hook output consumes context tokens. Keep reminders concise and actionable.

### Idempotent Scripts

Scripts should be safe to run multiple times without side effects.

### Prompt Timeout

Prompt-based hooks should include a timeout to prevent blocking indefinitely.

### Shared Utilities

Use `hook-utils.sh` for consistent parsing and logging across all hooks.

### JSONL for Append Support

All event files use JSONL format for consistency and append support:
- Session events (`session-start.jsonl`, `session-end.jsonl`)
- Agent events (`agent-start.jsonl`, `agent-stop.jsonl`)

---

## Troubleshooting

### Hook Not Firing

1. Check `settings.json` configuration
2. For command hooks: verify script is executable (`chmod +x`)
3. For command hooks: check script path uses `"$HOME"` for global hooks
4. For prompt hooks: verify JSON syntax
5. Check event name matches exactly (case-sensitive)

### Output Not Visible

1. For command hooks: ensure output uses `<system-reminder>` tags
2. For blocking hooks: output appears before agent completion
3. For non-blocking hooks: output may not be visible in conversation

### Script Errors

1. Test script manually: `echo '{"hook_event_name":"SessionStart","session_id":"test","cwd":"/tmp"}' | ~/.claude/hooks/scripts/hook-name.sh`
2. Check for syntax errors
3. Ensure proper shebang (`#!/bin/bash`)
4. Verify `jq` is installed: `which jq`

### Prompt Hook Returns Error

1. Verify JSON response format: `{"ok": true}` or `{"ok": false, "reason": "..."}`
2. Check timeout is sufficient for evaluation
3. Simplify prompt if evaluation is too complex

### Log Files Not Created

1. Verify project has write permissions
2. Check `logs/sessions/` directory can be created
3. Test with: `mkdir -p logs/sessions/test && rm -r logs/sessions/test`

### Two-Phase Flow Issues

1. Check `stop_hook_active` value in hook input
2. First phase: `stop_hook_active=false` (validation)
3. Second phase: `stop_hook_active=true` (reflexion)
4. Verify both scripts check for correct phase

---

## References

- [ADR-001: Hook Reminder Pattern](../../docs/architecture/adr/001-hook-reminder-pattern.md)
- [Claude Code Hooks Documentation](https://docs.anthropic.com/claude-code/hooks)
