# SuperClaudeZero Architecture Specification

**Version**: 0.1.0
**Status**: Draft
**Date**: 2026-01-25
**Source**: [PRD.md](PRD.md)

---

## Executive Summary

This document defines the technical architecture for SuperClaudeZero (SCZ), a minimalist multi-agent orchestration framework for Claude Code. The architecture follows the Orchestrator blueprint with a lean subset focused on skills, agents, workflows, and memory.

**Key Architectural Decisions**:
- Pure markdown/JSON configuration (zero Python dependencies)
- Claude Code native structures (`.claude/agents/`, `.claude/skills/`)
- 2-3 MCP servers (Serena required, Context7 required, Playwright optional)
- Hook-based lifecycle management (reminder pattern, not enforcement)
- Four-tier memory system (Session, Semantic, Reflexion, Transient)

---

## System Overview

> **See**: [System Diagrams](diagrams/system-overview.md)

### What SCZ Provides vs Claude Code Native

| Component | Provider | Description |
|-----------|----------|-------------|
| Skill routing (`/skill` → SKILL.md) | **Claude Code** | Native skill dispatch |
| Task tool (subagent spawning) | **Claude Code** | Native agent invocation |
| Hook execution | **Claude Code** | Native lifecycle events |
| Skill definitions (SKILL.md files) | **SCZ** | Instructions for each skill |
| Agent definitions (.md files) | **SCZ** | Thin wrappers with skills injected |
| Hook scripts (.sh files) | **SCZ** | Reminder scripts for validation/learning |
| Workflows (templates) | **SCZ** | Agent orchestration patterns |
| Policy (rules, principles) | **SCZ** | Behavioral guidelines |

---

## Component Specifications

### 1. Skill System

Skills are the primary user interface. They are markdown files in `.claude/skills/` with YAML frontmatter. Claude Code natively routes `/skill` invocations to the corresponding SKILL.md file.

#### 1.1 Skill Categories

| Category | Skills | Invocation Pattern | Context |
|----------|--------|-------------------|---------|
| **Agent-backed** | spec, design, plan, implement, validate, deploy, document | `context: fork` + `agent:` injects skill into specified agent | fork |
| **Orchestration** | orchestrate | Calls agents via Task tool; agents have skills loaded via `skills:` | inline |
| **Utility** | reflexion, reflect, optimize, analyse, research, distill | Runs inline, no agent delegation | inline |

> **Key Design**: Agent-backed skills use `context: fork` to inject content into the specified agent. Both direct invocation (`/spec`) and orchestrated invocation (agent's `skills:` list) result in skill content being injected into agent context. Single source of truth, no duplication.

#### 1.2 Skill Interface Contract

```yaml
---
name: skill-name                    # Required: lowercase + hyphens
description: What this skill does   # Required: for auto-invocation
argument-hint: [target] [options]   # Optional: autocomplete hint
disable-model-invocation: false     # Optional: true = user-only
user-invocable: true                # Optional: false = hide from menu
allowed-tools: Read, Grep, Bash     # Optional: tool whitelist
model: sonnet                       # Optional: model override
context: fork                       # Agent-backed skills: fork to inject into agent
agent: business-analyst             # Agent-backed skills: target agent for injection
---

# Skill Instructions

## Purpose
[What this skill accomplishes]

## Inputs
- `$ARGUMENTS`: User-provided arguments
- `${PROJECT_NAME}`: Derived from working directory
- `${CLAUDE_SESSION_ID}`: Current session identifier
- `${AGENT_ID}`: Current agent identifier (parsed from agent JSONL logs at SessionStart; visible as `agentId` where `isSidechain: true`)

## Outputs
[Artifact type and storage location]

## Workflow
[Step-by-step execution]
```

#### 1.3 Skill-Agent Relationship

There are **two invocation paths** for agent-backed skills. Both use **content injection**.

> **See**: [Invocation Paths Diagram](diagrams/invocation-paths.md)

**Both paths use injection** (from Claude Code docs):
> "The full content of each skill is injected into the subagent's context, not just made available for invocation."

**Benefits of this design:**
- **No duplication**: Skill is single source of truth
- **Both paths spawn agent**: Hooks fire in both cases
- **Two injection mechanisms**: `context: fork` (direct) and `skills:` (orchestrated)
- **Consistent behavior**: Same agent, same hooks, same outcome

| Skill | Agent | Primary Artifact | Storage |
|-------|-------|-----------------|---------|
| `/spec` | Business Analyst | PRD | `docs/architecture/PRD.md` |
| `/design` | Architect | Architecture doc, ADR | `docs/architecture/` |
| `/plan` | Project Manager | ROADMAP, BACKLOG | `docs/objectives/ROADMAP.md`, `docs/development/` |
| `/implement` | Developer | Code, tests | Source files |
| `/validate` | Validator | Validation report | Serena memory |
| `/deploy` | Deployer | Deployment artifacts | CI/CD files |
| `/document` | Tech Writer | Documentation | `docs/`, `README.md` |

#### 1.4 Conflict Detection in /document Skill

The `/document` skill includes conflict detection to prevent silent overwrites:

**Conflict Types Detected:**
| Type | Example | Severity |
|------|---------|----------|
| **Decision Conflict** | New code contradicts ADR decision | HIGH |
| **Specification Drift** | Implementation differs from PRD | HIGH |
| **Cross-Doc Mismatch** | ARCHITECTURE says X, README says Y | MEDIUM |
| **Stale Reference** | Doc references removed component | MEDIUM |
| **Version Mismatch** | Changelog vs actual version | LOW |

**Conflict Resolution Flow:**
1. Detect inconsistency during documentation update
2. Present conflict to user via `AskUserQuestion`
3. User chooses: update old, keep old, document tentatively, or pause
4. If tentative/rejected: log to ISSUES.md with suggested agent for resolution

This ensures documentation changes are intentional and aligned with architectural decisions.

---

### 2. Agent System

Agents are specialized workers invoked via Claude Code's Task tool with `subagent_type` parameter.

#### 2.1 Agent Architecture

> **See**: [Agent-Skill Injection Diagram](diagrams/agent-skill-injection.md)

#### 2.2 Agent Specifications

| Agent | Responsibility | Tools | Disallowed | Permission Mode | Artifacts |
|-------|---------------|-------|------------|-----------------|-----------|
| **Business Analyst** | Requirements elicitation, acceptance criteria | Read, Grep, Glob, WebSearch | - | default | PRD, User Stories |
| **Architect** | System design, constraints, trade-offs | Read, Grep, Glob, WebSearch | - | default | Architecture doc, ADR |
| **Project Manager** | Planning, sequencing, decomposition | Read, Write, TaskCreate | - | default | ROADMAP, BACKLOG |
| **Developer** | Implementation, code changes | Read, Write, Edit, Bash, Task | - | default | Code, tests |
| **Validator** | Testing, acceptance criteria checking | Read, Grep, Glob, Bash | Write, Edit | default | Validation report |
| **Deployer** | Build, deploy, release | Read, Write, Bash | Edit | **plan** | Deployment artifacts |
| **Tech Writer** | Documentation, guides | Read, Write, Grep, Glob, AskUserQuestion | Edit | default | Docs, README |

**Notes on Support Agents:**

- **Validator**: Cannot modify code - reports findings only. Uses Bash for running tests.
- **Deployer**: Requires user approval for destructive operations via `permissionMode: plan`.
- **Tech Writer**: Uses `AskUserQuestion` for conflict detection - never silently overwrites docs when inconsistencies are detected.

#### 2.3 Agent with Skill Injection

Agents load skill content via `skills:` frontmatter. The skill instructions are **injected** into the agent's context. The agent definition provides:
- Specialized persona/role context
- Skill loading (`skills:` list for orchestrated path)
- Tool restrictions (`tools`, `disallowedTools`)
- Lifecycle hooks (`Stop` - agent frontmatter only supports PreToolUse, PostToolUse, Stop)
- Permission mode

```markdown
# Example: .claude/agents/business-analyst.md
---
name: business-analyst
description: Requirements elicitation and PRD generation
skills:
  - spec                              # Skill content injected for orchestrated path
hooks:
  Stop:                               # Fires when this agent finishes responding
    - hooks:
        - type: command
          command: "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scripts/remind-validate.sh"
        - type: command
          command: "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scripts/remind-reflexion.sh"
---

You are a Business Analyst responsible for requirements elicitation
and PRD generation.

## Boundaries
- **Will**: Generate PRDs, define acceptance criteria, ask clarifying questions
- **Won't**: Write code, make architectural decisions
```

> **Note**: Agent frontmatter hooks use `Stop` (fires when agent finishes). Settings-level hooks can use `SubagentStop` (fires when any subagent completes from parent's perspective).

#### 2.4 Multi-Skill Model (Primary + Adhoc)

Agents can receive skills through two mechanisms - both triggered by the **USER**, not by agents themselves.

> **See**: [Agent-Skill Mapping Diagram](diagrams/agent-skill-mapping.md) and [ADR-004](adr/004-skill-agent-invocation-paths.md)

**Example: Architect with /design (primary) + /analyse (secondary)**

```yaml
# .claude/agents/architect.md
---
name: architect
description: System design and architecture
skills:
  - design                    # Primary: always injected when agent spawns
hooks:
  Stop:
    - hooks:
        - type: command
          command: "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scripts/remind-validate.sh"
---

You are an Architect responsible for system design.
```

```yaml
# .claude/skills/analyse/SKILL.md
---
name: analyse
description: Investigation and troubleshooting
context: fork
agent: architect              # Targets Architect - injected as SECONDARY
---

Investigate the codebase for: $ARGUMENTS

## Process
1. Search for relevant patterns
2. Analyze dependencies
3. Document findings
```

**Invocation Scenarios:**

| User Action | Agent Spawned | Skills Injected |
|-------------|---------------|-----------------|
| `/design "auth system"` | Architect | /design (via `context: fork`) |
| Orchestrator calls Task(architect) | Architect | /design (via `skills:` list) |
| `/analyse "auth patterns"` | Architect | /design (primary) + /analyse (secondary) |
| `/research "OAuth specs"` | Architect | /design (primary) + /research (secondary) |

**Skill Configuration for Secondary Invocation:**

For a skill to be invokable as secondary on an agent:

```yaml
---
name: analyse
context: fork                 # Required: triggers agent spawn
agent: architect              # Required: specifies target agent
disable-model-invocation: false  # Optional: allows model to suggest (default)
---
```

#### 2.5 Agent Communication Pattern

> **See**: [Orchestrated Workflow Diagram](diagrams/orchestrated-workflow.md)

---

### 3. Workflow Engine

The workflow engine coordinates agents through defined templates.

#### 3.1 Workflow Templates

> **See**: [Workflow Engine Diagram](diagrams/workflow-engine.md)

**Workflow 1: Idea to Implementation** - Three depth levels (Full, Medium, Light) based on complexity assessment.

**Workflow 2: Session to Meta-Learning** - Session → /reflect → /optimize → Approval → Rollout cycle.

#### 3.2 Workflow Depth Selection

```python
# Pseudocode for workflow depth selection
def select_workflow_depth(request):
    complexity = assess_complexity(request)

    if complexity == "high" or is_new_product(request):
        return "full"  # Spec -> Design -> Plan -> Implement -> Validate -> Deploy -> Document
    elif complexity == "medium" or is_feature(request):
        return "medium"  # Spec -> Plan -> Implement -> Validate
    else:  # simple change
        return "light"  # Plan -> Implement

def assess_complexity(request):
    factors = {
        "new_system": 3,
        "multiple_components": 2,
        "integration_needed": 2,
        "new_api": 1,
        "ui_changes": 1,
        "simple_fix": -2,
        "documentation_only": -3
    }
    score = sum(factors.get(f, 0) for f in detect_factors(request))

    if score >= 4:
        return "high"
    elif score >= 1:
        return "medium"
    else:
        return "low"
```

---

### 4. Hook System

Hooks provide lifecycle event handling through reminder scripts.

#### 4.1 Hook Architecture

> **See**: [Hook System Diagram](diagrams/hook-system.md) and [ADR-001](adr/001-hook-reminder-pattern.md)

**Important**: Stop ≠ SessionEnd
- **Stop**: Fires when Claude finishes responding. CAN block. CAN invoke skills.
- **SessionEnd**: Fires when session actually closes. CANNOT block. Cleanup only.

#### 4.2 Hook Specifications

| Hook Event | Trigger | Blocking | Script | Purpose |
|------------|---------|----------|--------|---------|
| **SessionStart** | Session begins | No | `inject-context.sh` | Inject `PROJECT_NAME`, `SESSION_ID` |
| **Stop** (agent) | Agent finishes | **Yes** | `remind-validate.sh` | Agent self-validation |
| **Stop** (agent) | Agent finishes | **Yes** | `remind-reflexion.sh` | Agent invokes `/reflexion` if errors |
| **Stop** (main) | Claude finishes responding | **Yes** | `remind-reflect.sh` | Orchestrator checklist, invoke `/reflect` |
| **SessionEnd** | Session closes | No | `checkpoint-session.sh` | Cleanup, logging, checkpoint state |

> **Note**: Agent frontmatter only supports `PreToolUse`, `PostToolUse`, and `Stop` hooks. Settings-level hooks support additional events like `SubagentStop`, `UserPromptSubmit`, etc.

#### 4.2.1 Hook Script Paths

Hook scripts are located in `.claude/hooks/scripts/` and referenced from settings/agent frontmatter:

```json
// In settings.json (global hooks) - uses $HOME for global path
{
  "hooks": {
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
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/scripts/remind-reflect.sh"
          }
        ]
      }
    ]
  }
}
```

```yaml
# In agent frontmatter - uses $CLAUDE_PROJECT_DIR for project path
hooks:
  Stop:
    - hooks:
        - type: command
          command: "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scripts/remind-validate.sh"
        - type: command
          command: "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scripts/remind-reflexion.sh"
```

#### 4.3 Hook Script Interface

```bash
#!/bin/bash
# remind-validate.sh
# Output is injected as system reminder to agent

cat << 'EOF'
<system-reminder>
SELF-VALIDATION CHECKLIST:
Before completing, verify:
1. [ ] All acceptance criteria from requirements are met
2. [ ] Artifact schema is valid
3. [ ] No assumptions without evidence
4. [ ] Tests pass (if applicable)

If any item fails, address before completing.
</system-reminder>
EOF
```

#### 4.4 Python Script Conventions

**All Python scripts must be self-contained via uvx shebang** for zero-dependency execution:

```python
#!/usr/bin/env -S uvx --from package-name python
```

**Execution**: Always run directly (`./script.py`), never with Python interpreter (`python script.py`).

**Benefits**:
- Isolated environments per script
- Works without project venv activation

**Common shebangs**:
```bash
# Claude Agent SDK
#!/usr/bin/env -S uvx --from claude-agent-sdk,pyyaml python
```

#### 4.5 Hook Log Structure

Hook scripts log session and agent lifecycle events for observability and debugging.

**Directory Structure:**
```
logs/sessions/<session_id>/
├── session-start.jsonl      # Session start events (JSONL for resume support)
├── session-end.jsonl        # Session end events (JSONL for resume support)
├── events.log               # Human-readable event timeline
└── <agent_id>/              # Per-agent subdirectory
    ├── agent-start.json     # Agent spawn metadata (single JSON)
    └── agent-stop.jsonl     # Agent stop events (JSONL for two-phase flow)
```

**Hook Events:**

| Event | Trigger | Blocking | Log Output |
|-------|---------|----------|------------|
| `SessionStart` | Session begins | No | `session-start.jsonl` |
| `SubagentStart` | Agent spawned | No | `<agent_id>/agent-start.json`, `events.log` |
| `SubagentStop` | Agent completes | Yes | `<agent_id>/agent-stop.jsonl`, `events.log` |
| `Stop` | Claude finishes responding | Yes | - |
| `SessionEnd` | Session closes | No | `session-end.jsonl`, `events.log` |

**Key Files:**

| File | Format | Purpose |
|------|--------|---------|
| `session-start.jsonl` | JSONL | Session metadata, supports multiple resumes |
| `session-end.jsonl` | JSONL | Session end events, supports multiple resumes |
| `agent-start.json` | JSON | Agent spawn context (type, timestamp, cwd) |
| `agent-stop.jsonl` | JSONL | Agent completion events (captures two-phase flow) |
| `events.log` | Text | Chronological event timeline for debugging |

**Two-Phase SubagentStop Flow:**

The SubagentStop hook fires twice per agent completion, controlled by `stop_hook_active`:

| Phase | `stop_hook_active` | Script | Action |
|-------|-------------------|--------|--------|
| 1 (Validation) | `false` | `remind-validate.sh` | Self-validation checklist |
| 2 (Reflexion) | `true` | `remind-reflexion.sh` | Reflexion prompt if errors |

This flow enables:
1. Agent receives validation prompt first (`stop_hook_active=false`)
2. Agent responds to validation (may continue or complete)
3. Agent receives reflexion prompt second (`stop_hook_active=true`)
4. Agent decides whether to invoke `/reflexion`

Both phases are logged to `agent-stop.jsonl` as separate entries.

---

### 5. Memory System

Four-tier memory architecture for different persistence needs.

#### 5.1 Memory Architecture

> **See**: [Memory System Diagram](diagrams/memory-system.md) and [ADR-002](adr/002-four-tier-memory.md)

#### 5.2 Memory Access Patterns

**Agent Initialization Memory Loading**:

| Memory Type | Load Pattern | Content |
|-------------|--------------|---------|
| **Semantic (knowledge/)** | Auto-load at spawn | Project architecture, API patterns, domain model, conventions |
| **Reflexion (reflexion/)** | Query on error/issue | Known issues, root causes, solutions, prevention strategies |
| **Transient** | Not loaded | Ephemeral validation/reflection records |

#### 5.3 Reflexion Memory Schema

```yaml
# reflexion/2026-01-23-auth-error.md
---
date: 2026-01-23
agent: Developer
task: Implement OAuth flow
severity: high
---

## Known Issue
Authentication fails silently when refresh token expires

## Root Cause
Token refresh endpoint returns 401 but error handler swallows exception

## Solution
1. Added explicit error handling for 401 response
2. Implemented token refresh retry logic
3. Added user notification for re-authentication

## Prevention
- Always handle 401 responses explicitly in auth flows
- Add logging for token lifecycle events
- Consider adding health check for token validity
```

---

### 6. MCP Integration

Minimal MCP footprint with two required servers.

#### 6.1 MCP Architecture

> **See**: [ADR-003 - Minimal MCP Footprint](adr/003-minimal-mcp-footprint.md)

| Server | Status | Purpose |
|--------|--------|---------|
| **Serena** | Required | Session persistence, semantic memory, symbolic code operations |
| **Context7** | Required | Documentation lookup, hallucination prevention |
| **Playwright** | Optional | Browser automation for validation |

#### 6.2 MCP Usage Patterns

| Use Case | MCP Server | Tool | Skill |
|----------|------------|------|-------|
| Store reflexion | Serena | write_memory | /reflexion |
| Query past errors | Serena | read_memory | Agent init |
| Look up docs | Context7 | query-docs | /research, /design |
| Visual validation | Playwright | screenshot | /validate |
| Code navigation | Serena | find_symbol | /analyse |

---

### 7. File Structure

Detailed file organization for SCZ installation.

#### 7.1 Repository Structure

```
super-claude-zero/
├── README.md                           # Project overview
├── install.sh                          # Installer script
│
├── docs/                               # SCZ's own docs (dogfooding)
│   ├── objectives/
│   │   ├── VISION.md
│   │   ├── BLUEPRINT.md                # Technical scope, capabilities
│   │   └── ROADMAP.md
│   ├── architecture/
│   │   ├── PRD.md
│   │   ├── ARCHITECTURE.md             # This document
│   │   └── adr/
│   │       ├── 001-hook-reminder-pattern.md
│   │       ├── 002-four-tier-memory.md
│   │       ├── 003-minimal-mcp-footprint.md
│   │       └── 004-skill-agent-invocation-paths.md
│   ├── development/
│   │   └── BACKLOG.md
│   └── knowledge/
│       └── README.md
│
├── .claude/                            # Claude-native structures
│   ├── settings.json                   # Project settings
│   │
│   ├── agents/                         # Agent definitions
│   │   ├── business-analyst.md
│   │   ├── architect.md
│   │   ├── project-manager.md
│   │   ├── developer.md
│   │   ├── validator.md
│   │   ├── deployer.md
│   │   └── tech-writer.md
│   │
│   ├── skills/                         # Skill definitions
│   │   ├── orchestrate/
│   │   │   └── SKILL.md
│   │   ├── spec/
│   │   │   └── SKILL.md
│   │   ├── design/
│   │   │   └── SKILL.md
│   │   ├── plan/
│   │   │   └── SKILL.md
│   │   ├── implement/
│   │   │   └── SKILL.md
│   │   ├── validate/
│   │   │   └── SKILL.md
│   │   ├── deploy/
│   │   │   └── SKILL.md
│   │   ├── document/
│   │   │   └── SKILL.md
│   │   ├── reflexion/
│   │   │   └── SKILL.md
│   │   ├── reflect/
│   │   │   └── SKILL.md
│   │   ├── optimize/
│   │   │   └── SKILL.md
│   │   ├── analyse/
│   │   │   └── SKILL.md
│   │   ├── research/
│   │   │   └── SKILL.md
│   │   └── distill/
│   │       └── SKILL.md
│   │
│   └── hooks/                          # Hook scripts
│       ├── README.md
│       └── scripts/
│           ├── lib/
│           │   └── hook-utils.sh       # Shared library for parsing/logging
│           ├── inject-context.sh       # SessionStart: inject vars
│           ├── remind-validate.sh      # SubagentStop: agent validation
│           ├── remind-reflexion.sh     # SubagentStop: agent reflexion
│           ├── remind-reflect.sh       # Stop: orchestrator /reflect
│           └── checkpoint-session.sh   # SessionEnd: cleanup, checkpoint
│
├── global/                             # Global abstractions
│   ├── settings.json                   # Global settings template
│   ├── policy/
│   │   ├── RULES.md
│   │   └── PRINCIPLES.md
│   ├── workflows/
│   │   ├── SWE.md
│   │   └── meta-learning.md
│   └── templates/
│       ├── vision.md
│       ├── blueprint.md
│       ├── prd.md
│       ├── architecture.md
│       ├── adr.md
│       ├── roadmap.md
│       ├── backlog.md
│       └── issues.md
│
├── project/                            # Per-project templates
│   ├── settings.json
│   ├── objectives/
│   │   ├── GOALS.md.template
│   │   └── ROADMAP.md.template
│   ├── knowledge/
│   │   └── README.md
│   └── reports/
│       ├── analysis/
│       │   └── .gitkeep
│       └── research/
│           └── .gitkeep
│
└── .serena/                            # Serena MCP local storage
    └── README.md
```

#### 7.2 Installation Targets

| Source | Flag | Target | Purpose |
|--------|------|--------|---------|
| `.claude/` | `--global` | `~/.claude/` | Claude-native (agents, skills, hooks) |
| `global/` | `--global` | `~/.claude/` | Higher-level (policy, workflows, templates) |
| `project/` | `--project <path>` | `<path>/` | Per-project (objectives, knowledge, reports) |
| `docs/` | - | Not deployed | SCZ's own documentation |

#### 7.3 Installation Behavior

The `install.sh` script handles existing files intelligently:

| File Type | Behavior | Rationale |
|-----------|----------|-----------|
| `*.json` (settings, mcp) | **Patch/merge** | Preserve user customizations, add SCZ keys |
| `*.md` (agents, skills) | **Warn if different** | Don't overwrite user modifications |
| `*.sh` (hooks) | **Backup + overwrite** | Scripts should match SCZ version |
| New files | **Create** | No conflict |

##### JSON Patching (settings.json, mcp.json)

```bash
# Pseudocode for JSON merge
if [ -f "$TARGET" ]; then
    # Backup existing
    cp "$TARGET" "$TARGET.backup.$(date +%Y%m%d%H%M%S)"

    # Deep merge: SCZ defaults + user customizations
    # User values take precedence for existing keys
    jq -s '.[0] * .[1]' "$SCZ_SOURCE" "$TARGET" > "$TARGET.tmp"
    mv "$TARGET.tmp" "$TARGET"

    echo "Patched: $TARGET (backup created)"
else
    cp "$SCZ_SOURCE" "$TARGET"
    echo "Created: $TARGET"
fi
```

##### Markdown Handling (agents, skills, policies)

```bash
# Don't overwrite modified markdown files
if [ -f "$TARGET" ]; then
    if ! diff -q "$SCZ_SOURCE" "$TARGET" > /dev/null 2>&1; then
        echo "WARNING: $TARGET exists and differs from SCZ version"
        echo "  SCZ version: $SCZ_SOURCE"
        echo "  Your version preserved. Review manually if needed."
        # Optionally copy SCZ version with .scz suffix for comparison
        cp "$SCZ_SOURCE" "$TARGET.scz"
    else
        echo "Unchanged: $TARGET"
    fi
else
    cp "$SCZ_SOURCE" "$TARGET"
    echo "Created: $TARGET"
fi
```

##### Shell Script Handling (hooks)

```bash
# Always update hook scripts (backup first)
if [ -f "$TARGET" ]; then
    cp "$TARGET" "$TARGET.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backed up: $TARGET"
fi
cp "$SCZ_SOURCE" "$TARGET"
chmod +x "$TARGET"
echo "Installed: $TARGET"
```

##### Installation Summary Output

```
SCZ Installation Summary
========================
Created:  12 files
Patched:   2 files (settings.json, mcp.json)
Unchanged: 3 files
Warnings:  1 file (see above)
Backups:   ~/.claude/backups/2026-01-24/

Run 'scz doctor' to verify installation.
```

---

### 8. Artifact Storage

Where skills write their outputs.

#### 8.1 Artifact Locations

```
target-project/
├── docs/
│   ├── objectives/                  # Strategic layer
│   │   ├── VISION.md                # User-managed (why, who)
│   │   ├── BLUEPRINT.md             # User-managed (scope, capabilities)
│   │   └── ROADMAP.md               # /plan updates (milestones, phases)
│   │
│   ├── architecture/                # Specification layer
│   │   ├── PRD.md                   # /spec output
│   │   ├── ARCHITECTURE.md          # /design output
│   │   └── adr/                     # /design ADR output
│   │       └── 001-decision.md
│   │
│   └── development/                 # Execution layer
│       ├── BACKLOG.md               # Prioritized tasks
│       └── ISSUES.md                # Discovered bugs/blockers
│
├── reports/                         # Git-versioned skill outputs
│   ├── analysis/                    # /analyse output
│   │   └── 2026-01-23-auth-issue.md
│   └── research/                    # /research output
│       └── 2026-01-23-oauth-providers.md
│
├── src/                             # /implement output
│   └── ...
│
└── .serena/                         # Transient artifacts (Serena memories)
    # /validate → validation records
    # /reflect → reflection records
    # /reflexion → reflexion records
```

#### 8.2 Artifact Schema

**PRD (docs/architecture/PRD.md)**
```markdown
# [Project Name] Product Requirements Document

## Executive Summary
[Brief overview]

## Goals
### Primary Goal
[Main objective]

### Non-Goals
[Explicit exclusions]

## Functional Requirements
### FR1: [Feature Name]
[Description]
**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Non-Functional Requirements
| ID | Requirement | Target |
|----|-------------|--------|
| NFR1 | [Requirement] | [Target] |

## User Stories
### US1: [Story Title]
**As a** [role]
**I want to** [action]
**So that** [benefit]
```

**Architecture (docs/architecture/ARCHITECTURE.md)**
```markdown
# [Project Name] Architecture

## Overview
[System diagram]

## Components
### [Component Name]
- **Responsibility**: [What it does]
- **Interface**: [API/contract]
- **Dependencies**: [What it needs]

## Data Flow
[Sequence diagrams]

## Constraints
[Technical limitations]

## Risks
| Risk | Impact | Mitigation |
|------|--------|------------|

## Trade-offs
[Design decisions and alternatives considered]
```

**Backlog (docs/development/BACKLOG.md)**

> **See**: [ADR-005 Task Decomposition Hierarchy](adr/005-task-decomposition-hierarchy.md)

```markdown
# [Project Name] Backlog

## [Milestone] (e.g., v0, v1)

### [Phase]: Research | Design | Implement | Validate

#### Epic: [Name] (feature group)
- [ ] Task: [description] → `[commit message]`
- [ ] Task: [description] → `[commit message]`
- [ ] Task: [tests/validation] → `[commit message]`
```

---

## Design Decisions

Full Architecture Decision Records are maintained in the [adr/](adr/) directory:

| ADR | Title | Summary |
|-----|-------|---------|
| [ADR-001](adr/001-hook-reminder-pattern.md) | Hook Behavior Pattern | Blocking hooks (SubagentStop, Stop) for reminders; SessionEnd for cleanup |
| [ADR-002](adr/002-four-tier-memory.md) | Four-Tier Memory | Session, Semantic, Reflexion, Transient tiers with different lifecycles |
| [ADR-003](adr/003-minimal-mcp-footprint.md) | Minimal MCP Footprint | 2 required (Serena, Context7), 1 optional (Playwright) |
| [ADR-004](adr/004-skill-agent-invocation-paths.md) | Skill-Agent Invocation | Skill-driven injection via `context: fork` + agent's `skills:` list |
| [ADR-005](adr/005-task-decomposition-hierarchy.md) | Task Decomposition | Milestone → Phase → Epic → Task hierarchy for agent workflows |

**Key Design Principles**:

1. **Skill as Source of Truth**: Full instructions live in skill SKILL.md; agents are thin wrappers
2. **Load at Spawn**: Skills are loaded/injected into agent context at spawn (not invoked at runtime)
3. **Two Invocation Paths**: User invokes skill directly (`/spec` with `context: fork`) OR orchestrator spawns agent (loads via `skills:` list)
4. **Blocking Reminders**: SubagentStop/Stop hooks can block and prompt for action; agent decides response

---

## Security Considerations

### Secrets Management

- No secrets in skill/agent files
- Environment variables for API keys
- `.serena/` excluded from git (transient data)

### Permission Model

- `permissionMode: default` for most agents
- `permissionMode: plan` for Deployer (requires approval)
- `disallowedTools` to restrict dangerous operations

### Content Filtering

- Deferred to v1 (Guardrails hook)
- Current: Rely on Claude's built-in safety

---

## Performance Considerations

### Token Efficiency

- Skills are loaded on demand
- Agent context forking isolates state
- Distill skill for context reduction

### Parallel Execution

- Workflow engine runs independent steps in parallel
- Wave → Checkpoint → Wave pattern
- Agent orchestration via Task tool batching

---

## Appendix: Component Inventory

### Files (Target: ~40)

| Category | Count | Files |
|----------|-------|-------|
| Agents | 7 | business-analyst, architect, project-manager, developer, validator, deployer, tech-writer |
| Skills | 14 | orchestrate, spec, design, plan, implement, validate, deploy, document, reflexion, reflect, optimize, analyse, research, distill |
| Hooks | 5 | inject-context.sh, remind-validate.sh, remind-reflexion.sh, remind-reflect.sh, checkpoint-session.sh |
| Policy | 2 | RULES.md, PRINCIPLES.md |
| Workflows | 2 | SWE.md, meta-learning.md |
| Templates | 8 | vision.md, blueprint.md, prd.md, architecture.md, adr.md, roadmap.md, backlog.md, issues.md |
| Settings | 3 | global, project, .claude |
| Project templates | 5 | GOALS.md, ROADMAP.md, BACKLOG.md, knowledge/README.md, reports/ |
| Documentation | 6 | PRD.md, ARCHITECTURE.md, VISION.md, BLUEPRINT.md, ROADMAP.md, ADRs |
| **Total** | **~48** | |

### Dependencies

| Dependency | Type | Required |
|------------|------|----------|
| Claude Code | Runtime | Yes |
| Serena MCP | MCP Server | Yes |
| Context7 MCP | MCP Server | Yes |
| Playwright MCP | MCP Server | No |
| Bash | Shell | Yes (hooks) |

---

## Next Steps

1. **PRD Approval**: Confirm this architecture matches PRD intent
2. **Planning**: `/plan` to generate implementation tasks
3. **Implementation**: Build incrementally (agents → skills → hooks → workflows)
4. **Validation**: Test with dogfooding (SCZ building SCZ)
