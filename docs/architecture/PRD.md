# SuperClaudeZero Product Requirements Document

**Version**: 0.1.0
**Status**: Accepted
**Scope**: v0 Milestone
**Date**: 2026-01-22

---

## Executive Summary

SuperClaudeZero is a lean, self-contained multi-agent orchestration framework for Claude Code. It strips away the complexity of SuperClaude v4.2.0 (30+ commands, personas, modes, Python dependencies) in favor of a minimal architecture based on the **Orchestrator** blueprint.

**Core Architecture:**
- **Main Orchestrator** (Claude itself) with `/orchestrate` skill as control loop
- **7 Agents** (specialized workers invoked via Task tool)
- **14 Skills** (7 agent-backed + 1 orchestration + 6 utility)
- **5 Hook Events** (lifecycle events with 5 scripts)
- **2 Workflow Templates** (agent chains producing artifacts)
- **2-3 MCP servers** (minimal external dependencies)

---

## Goals

### Primary Goal
Create a minimalist orchestration layer where the **main Claude agent** coordinates specialized **agents** through defined **workflows**, producing concrete **artifacts** at each stage.

### Secondary Goals
1. Enable SWE pipeline via workflow: Spec → PRD → Architecture → Plan → Backlog
2. Build in self-validation (agent end hooks) and meta-learning (session end hooks)
3. Maintain cross-session memory via Serena MCP
4. Keep installation trivial (copy files, done)

### Non-Goals
- Full compatibility with SuperClaude v4 commands
- Python package distribution
- Plugin marketplace
- Capability-routing layer (v5 concept)

---

## Architecture Overview (from Orchestrator Blueprint)

```text
┌─────────────────────────────────────────────────────────────────┐
│                    MAIN ORCHESTRATOR (Claude)                    │
│                    /orchestrate skill loop                       │
├─────────────────────────────────────────────────────────────────┤
│  SKILLS (7 agent-backed + 1 orchestration + 6 utility)           │
│  Agent: /spec /design /plan /implement /validate /deploy /document│
│  Orch: /orchestrate  Util: /reflexion /reflect /optimize /analyse /research /distill
├─────────────────────────────────────────────────────────────────┤
│  SUB-AGENTS (via Task tool, slim wrappers invoking skills)       │
│  BA │ Architect │ PM │ Developer │ Validator │ Deployer │ Writer│
├─────────────────────────────────────────────────────────────────┤
│  HOOKS (5 events, 5 scripts)                                       │
│  SessionStart │ SubagentStart │ SubagentStop │ Stop │ SessionEnd
├─────────────────────────────────────────────────────────────────┤
│  WORKFLOWS (flexible depth)                                      │
│  Full: Spec→PRD→Architecture→Plan→Milestone/Phase/TaskGroup     │
│  Light: Roadmap→Plan→Task                                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Functional Requirements

### FR1: Agent System

> **Terminology**: Claude Code's Task tool uses `subagent_type` to invoke agents defined in `.claude/agents/`. This PRD uses "agent" consistently; "sub-agent" in diagrams refers to the Task tool invocation pattern.

Seven agents, each with clear responsibilities:

| Agent | Responsibility | Artifacts Produced |
| --------- | -------------- | ------------------ |
| **Business Analyst** | Requirements elicitation, acceptance criteria | PRD, User Stories |
| **Architect** | System design, constraints, trade-offs | Architecture doc, ADR |
| **Project Manager** | Planning, sequencing, decomposition | ROADMAP, BACKLOG |
| **Developer** | Implementation, code changes | Code, tests |
| **Validator** | Testing, acceptance criteria checking | Validation report |
| **Deployer** | Build, deploy, release | Deployment artifacts |
| **Tech Writer** | Documentation, guides | Docs, README |

**FR1.1**: Each agent defined in `.claude/agents/<name>.md`
**FR1.2**: Agents invoked via Claude Code's Task tool with `subagent_type` parameter
**FR1.3**: Agents have explicit boundaries (will do / won't do)
**FR1.4**: Agents produce typed artifacts
**FR1.5**: Agents invoke corresponding skills but can use multiple skills and tools directly

#### Agent Frontmatter (complete per Anthropic docs)

```yaml
---
name: agent-identifier                    # Required: lowercase + hyphens
description: When Claude should delegate  # Required: triggers auto-delegation
tools: Read, Grep, Glob, Bash, Task       # Optional: inherits all if omitted
disallowedTools: Write, Edit              # Optional: tools to deny
model: inherit                            # Optional: sonnet|opus|haiku|inherit (default: inherit)
permissionMode: default                   # Optional: default|acceptEdits|dontAsk|bypassPermissions|plan
skills:                                   # Optional: skills to preload into agent context
  - api-conventions
  - error-handling-patterns
hooks:                                    # Optional: lifecycle hooks
  SubagentStop:                           # Runs when agent completes
    - type: command
      command: "./.claude/hooks/scripts/remind-validate.sh"
    - type: command
      command: "./.claude/hooks/scripts/remind-reflexion.sh"
---

You are [agent role]. Your task is to invoke the [skill-name] skill and...
```

### FR2: Skill Interface

> **Note**: SuperClaudeZero uses skills exclusively (`.claude/skills/`). Skills support additional features over legacy commands: context forking, agent delegation, and lifecycle hooks.

Fourteen user-facing skills:

> **Note**: Agent-backed skills have 1:1 mapping with Agents. Agents can invoke other skills internally.

**Agent-backed skills** (1:1 with agents):

| Skill | Purpose | Agent | Output | Storage |
| ----- | ------- | ----- | ------ | ------- |
| `/spec` | Idea → requirements, acceptance criteria | BA | PRD | File |
| `/design` | PRD → architecture, constraints, risks, ADR | Architect | Architecture doc | File |
| `/plan` | Architecture → sequencing, decomposition | PM | ROADMAP, BACKLOG | File |
| `/implement` | Code implementation, tests, build | Developer | Code, tests | File |
| `/validate` | Quality assessment, acceptance criteria validation | Validator | Validation record | Serena |
| `/deploy` | Build, deploy, release | Deployer | Deployment artifacts | File |
| `/document` | Documentation, guides | Tech Writer | Docs, README | File |

**Orchestration skill**:

| Skill | Purpose | Output |
| ----- | ------- | ------ |
| `/orchestrate` | Main control loop, calls agents per workflow | Workflow execution |

**Utility skills** (run inline, no agent delegation):

| Skill | Purpose | Output | Storage |
| ----- | ------- | ------ | ------- |
| `/reflexion` | Tactical: capture known_issues/solutions after agent task | Reflexion record | Serena (project) |
| `/reflect` | Session meta-learning | Reflection record | Serena |
| `/optimize` | Fine-tune orchestrator/agent/policy instructions (requires approval) | Meta-Opt Plan | File |
| `/analyse` | Investigation, troubleshooting | Analysis report | File |
| `/research` | Parallel MCP search, documentation | Research summary | File |
| `/distill` | Content distillation with 5-level granularity (files/policy/knowledge/memory) | Distilled content | Replace original (git-versioned) or Serena (archive old) |

> **FR7 Reflexion**: Agent reminded to invoke `/reflexion` at SubagentStop → Serena project memory
> **FR8 Meta-Learning**: `/reflect` → `/optimize` → fine-tune instructions; prevention items → rules/guidelines

#### /distill Skill Specification

**Purpose**: Reduce content size while preserving critical information, with quality loss estimation before execution.

**Content Types** (extensible):
- Files (source code, configs)
- Policy (PRINCIPLES.md, RULES.md, GUIDELINES.md)
- Knowledge (project knowledge base)
- Memory (Serena memories)
- Artifacts (PRD, Architecture docs)
- Session logs (JSONL transcripts)

**Granularity Levels** (5):

| Level | Name | Target Reduction | Preserves |
|-------|------|------------------|-----------|
| 1 | `essence` | ~90% | Identity only |
| 2 | `summary` | ~75% | + Behavior |
| 3 | `condensed` | ~50% | + Reasoning |
| 4 | `detailed` | ~25% | + Context |
| 5 | `minimal` | ~10% | Dedup/formatting only |

**Criticality Heuristics** (guidance, extend by pattern `Critical > Important > Helpful > Context > Lossy`):
```
Policy:    Rules > Priority > Rationale > Examples > Detection
Code:      Signatures > Logic > Types > Comments > Formatting
Memory:    Facts > Decisions > Reasoning > Timestamps > Verbose
Artifacts: Requirements > Criteria > Rationale > Background > Examples
```

**Workflow**:
1. Analyze content, measure tokens (Python script)
2. Estimate critical information loss per level (heuristic)
3. Present table: Tokens before/after, Reduction %, Critical Loss %
4. User confirms level
5. Execute distillation
6. Output: Replace original (git-versioned files) or create new version (Serena memory, archive old)

**Invocation**:
```
/distill <path|type> [level]           # Specific item or all of type
/distill global/policy/RULES.md        # Single file
/distill --all policy                  # All policy files
/distill --all memory                  # All Serena memories
```

**Out of scope**: Conversation context (use built-in `/compact`)

**FR2.1**: Skills installed from `.claude/skills/` to `~/.claude/skills/`
**FR2.2**: Skills with `disable-model-invocation: false` (default) can be auto-invoked by Claude
**FR2.3**: Agents are slim wrappers that invoke corresponding skills
**FR2.4**: `/orchestrate` calls agents per defined workflows; agents invoke skills

#### Skill Frontmatter (complete per Anthropic docs)

```yaml
---
name: skill-name                          # Optional: uses directory name if omitted
description: What this skill does         # Recommended: Claude uses for auto-invocation
argument-hint: [arg1] [arg2]              # Optional: shown during autocomplete
disable-model-invocation: false           # Optional: true = only user can invoke (default: false)
user-invocable: true                      # Optional: false = hide from / menu (default: true)
allowed-tools: Read, Grep, Bash(git:*)    # Optional: tools Claude can use
model: sonnet                             # Optional: model to use
context: fork                             # Optional: run in forked subagent context
agent: Explore                            # Optional: subagent type when context: fork
hooks:                                    # Optional: lifecycle hooks
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./.claude/hooks/scripts/validate.sh"
---

Skill instructions with:
- Arguments: $ARGUMENTS (or appended as "ARGUMENTS: <value>")
- Session ID: ${CLAUDE_SESSION_ID}
- Dynamic context: !`shell command here`
- File references: see [reference.md](reference.md)
```

#### Skill Directory Structure

```text
.claude/skills/
└── my-skill/
    ├── SKILL.md           # Main instructions (required)
    ├── template.md        # Template for Claude to fill in
    ├── examples/
    │   └── sample.md      # Example output
    └── scripts/
        └── validate.sh    # Script Claude can execute
```

### FR3: Hooks System

Five lifecycle hook events for v0 (implemented via 5 scripts):

| Hook Event | Trigger | Blocking | Action | Implementation |
| ---------- | ------- | -------- | ------ | -------------- |
| **SessionStart** | Session begins | No | Inject project context, session-id | `settings.json` → `hooks.SessionStart` → `inject-context.sh` |
| **SubagentStart** | Subagent spawned | No | Log agent_id, agent_type to session logs | `settings.json` → `hooks.SubagentStart` → `inject-context.sh` |
| **SubagentStop** | Agent completes | **Yes** | Agent-specific validation and `/reflexion` | Agent `hooks.SubagentStop` → `remind-validate.sh`, `remind-reflexion.sh` |
| **Stop** | Claude finishes responding | **Yes** | Orchestrator checklist, `/reflect` | `settings.json` → `hooks.Stop` → `remind-reflect.sh` |
| **SessionEnd** | Session closes | No | Cleanup, logging, checkpoint state | `settings.json` → `hooks.SessionEnd` → `checkpoint-session.sh` |

> **Note**: Stop ≠ SessionEnd. Stop fires when Claude finishes responding (can block, can invoke skills). SessionEnd fires when session actually closes (cannot block).

**Session Logging**: Hooks write to `logs/sessions/<session_id>/` with nested `<agent_id>/` subdirectories for subagent artifacts.

**FR3.1**: SessionStart/SubagentStart hooks run `inject-context.sh` (non-blocking, logs to `logs/sessions/`)
**FR3.2**: SubagentStop hook runs `remind-validate.sh` and `remind-reflexion.sh` (blocking, agent-scoped)
**FR3.3**: Stop hook runs `remind-reflect.sh` (blocking, can invoke `/reflect`)
**FR3.4**: SessionEnd hook runs `checkpoint-session.sh` (non-blocking, cleanup only)
**FR3.5**: Hooks output reminders; agent/orchestrator decides whether to invoke skills

### FR4: Workflow Templates

Two primary workflows:

**Workflow 1: Idea to Implementation** (full)

```text
/spec → PRD → /design → Architecture → /plan → Tasks → /implement → Code → /validate → /deploy → /document
```

**Workflow 2: Session to Meta-learning**

```text
Session Log → /reflect → Reflection Record → /optimize → Meta-Opt Plan (approved) → Rollout fine-tuned Orchestrator/Agent/Skill instructions
```

**Workflow flexibility**: Small or low-complexity requests can skip steps:

```text
# Full workflow (new product)
Idea → /spec → /design → /plan → /implement → /validate → /deploy → /document

# Medium workflow (feature from roadmap)
Roadmap item → /spec → /plan → /implement → /validate

# Light workflow (small change)
Roadmap item → /plan → /implement
```

**FR4.1**: Full workflow defined in `global/workflows/<name>.md`; Light workflow embedded as fallback
**FR4.2**: Each step produces artifact file in target project repo
**FR4.3**: `/orchestrate` determines appropriate workflow depth based on complexity
**FR4.4**: Templates renamed during install (skipped if file already exists)

### FR5: Memory System

Four-tier memory:

| Layer | Storage | Purpose | Trigger |
| ----- | ------- | ------- | ------- |
| **Session** | Claude logs (JSONL) | Transcript history | Automatic |
| **Semantic** | Serena memories | Project knowledge, patterns | Manual |
| **Reflexion** | Serena memories (project) | Error patterns, known issues, solutions learned (tactical) | SubagentStop |
| **Transient** | Serena memories (project) | Validation records | /validate |

**FR5.1**: `/reflect` writes to Serena memories
**FR5.2**: SessionStart hook loads relevant memories at session start
**FR5.3**: Stop hook invokes `/reflect` for session meta-learning (blocking, can invoke skills)
**FR5.3.1**: SessionEnd hook captures session state for external analysis (non-blocking, cleanup only)

#### Session Context Injection

The SessionStart hook injects context variables for skills and agents:

| Context | Variable | Source |
| ------- | -------- | ------ |
| **Project name** | `PROJECT_NAME` | Derived from working directory by init hook script |
| **Session ID** | `CLAUDE_SESSION_ID` | Injected by init hook script |
| **Agent ID** | `AGENT_ID` | Parsed from agent JSONL logs at SessionStart (visible as `agentId` where `isSidechain: true`) |

**FR5.4**: SessionStart hook injects `PROJECT_NAME` (derived from cwd path-based slug, e.g., `/workspace/super-claude` → `super-claude`)
**FR5.5**: Session logs location: `~/.claude/projects/<project-slug>/`
**FR5.6**: SessionStart hook injects `CLAUDE_SESSION_ID` for skills to reference
**FR5.7**: `/reflect` can reference session transcript via `CLAUDE_SESSION_ID`
**FR5.8**: `AGENT_ID` is parsed from agent JSONL logs at SessionStart (visible as `agentId` where `isSidechain: true`)

### FR6: Self-Validation

Reminded via SubagentStop hook to prompt Agent for final validation:

**FR6.1**: Requirements checklist validation
**FR6.2**: Acceptance criteria checking
**FR6.3**: Output artifact schema validation

### FR7: Reflexion (Tactical)

**FR7.1**: SubagentStop hook reminds agent to invoke `/reflexion`
**FR7.2**: `/reflexion` captures to Serena project memory (high signal/noise):
  - `known_issues` - Significant issues encountered
  - `cause` - Root cause analysis
  - `solution` - What fixed it
  - `prevention` - How to avoid next time
**FR7.3**: Future tasks in same project query Reflexion memory on errors/issues
**FR7.4**: Prevention items can be promoted to rules/guidelines via `/reflect`

### FR8: Meta-Learning (Strategic)

Adhoc improvement cycle via `/reflect` + `/optimize`:

**FR8.1**: `/reflect` analyzes session, captures lessons learned → Serena
**FR8.2**: `/optimize` proposes fine-tuned orchestrator/agent/skill instructions
**FR8.3**: User approval required before rollout

---

## Non-Functional Requirements

| ID | Requirement | Target |
| -- | ----------- | ------ |
| NFR1 | Zero Python dependencies | Pure markdown/JSON config |
| NFR2 | MCP footprint | 2-3 servers |
| NFR3 | Installation time | <30 seconds |
| NFR4 | Claude Code compatibility | Works with vanilla Claude Code |
| NFR5 | Self-contained | No external services beyond MCPs |
| NFR6 | File count | ~40 files total |

---

## MCP Dependencies

Minimal set:

| Server | Purpose | Priority |
| ------ | ------- | -------- |
| **Serena** | Session persistence, semantic memory, symbolic code operations | Required |
| **Context7** | Documentation lookup, prevents hallucination | Required |
| **Playwright** | Browser automation for validation | Optional |

### Explicitly Dropped (from SuperClaude v4)
- Morphllm, Kazuki, Agiletec, Airis Gateway
- Tavily (use Claude's native WebSearch)
- Sequential-thinking (use native reasoning)

---

## File Structure

Three nested layers + SCZ's own docs (SCZ dogfoods itself).

```text
super-claude-zero/
├── README.md
├── install.sh                   # Installer (--global | --project targets)
│
│   # ════════════════════════════════════════════════════════════════
│   # SCZ DOCS (SCZ using itself as target project - "dogfooding")
│   # ════════════════════════════════════════════════════════════════
│
├── docs/
│   ├── objectives/              # Goals/Roadmap
│   │   ├── BLUEPRINT.md         # Blueprint reference
│   │   └── ROADMAP.md           # Managed by User
│   ├── architecture/            # Design docs
│   │   ├── PRD.md               # This document
│   │   └── adr/                 # Architecture Decision Records
│   ├── development/             # Current work
│   │   └── BACKLOG.md
│   └── knowledge/               # SCZ knowledge base
│       └── README.md
│
│   # ════════════════════════════════════════════════════════════════
│   # .claude/ - CLAUDE-NATIVE (maps to Claude Code structures)
│   # ════════════════════════════════════════════════════════════════
│
├── .claude/
│   ├── settings.json            # Claude Code settings
│   │
│   ├── agents/                  # → Task tool subagent_type (slim wrappers)
│   │   ├── business-analyst.md  # BA for /spec
│   │   ├── architect.md
│   │   ├── project-manager.md
│   │   ├── developer.md
│   │   ├── validator.md
│   │   ├── deployer.md
│   │   └── tech-writer.md
│   │
│   ├── skills/                  # → ~/.claude/skills/
│   │   ├── orchestrate/         # Orchestration
│   │   │   └── SKILL.md
│   │   ├── spec/                # Agent-backed (BA)
│   │   │   └── SKILL.md
│   │   ├── design/              # Agent-backed (Architect)
│   │   │   └── SKILL.md
│   │   ├── plan/                # Agent-backed (PM)
│   │   │   └── SKILL.md
│   │   ├── implement/           # Agent-backed (Developer)
│   │   │   └── SKILL.md
│   │   ├── validate/            # Agent-backed (Validator)
│   │   │   └── SKILL.md
│   │   ├── deploy/              # Agent-backed (Deployer)
│   │   │   └── SKILL.md
│   │   ├── document/            # Agent-backed (Tech Writer)
│   │   │   └── SKILL.md
│   │   ├── reflexion/           # Utility (reminded at SubagentStop)
│   │   │   └── SKILL.md
│   │   ├── reflect/             # Utility (inline)
│   │   │   └── SKILL.md
│   │   ├── optimize/            # Utility (inline, requires approval)
│   │   │   └── SKILL.md
│   │   ├── analyse/             # Utility (inline)
│   │   │   └── SKILL.md
│   │   ├── research/            # Utility (inline)
│   │   │   └── SKILL.md
│   │   └── distill/             # Utility (content distillation)
│   │       └── SKILL.md
│   │
│   └── hooks/                   # → Claude Code hooks
│       └── README.md
│
│   # ════════════════════════════════════════════════════════════════
│   # global/ - HIGHER-LEVEL ABSTRACTIONS (deployed to ~/.claude/)
│   # ════════════════════════════════════════════════════════════════
│
├── global/
│   ├── settings.json            # Global settings template
│   ├── policy/                  # Principles/Rules/Guidelines
│   │   ├── RULES.md
│   │   └── PRINCIPLES.md
│   ├── workflows/               # SOP/Workflow definitions
│   │   ├── SWE.md
│   │   └── meta-learning.md
│   └── templates/               # Artifact templates
│       ├── vision.md
│       ├── blueprint.md
│       ├── prd.md
│       ├── architecture.md
│       ├── adr.md
│       ├── roadmap.md
│       ├── backlog.md
│       └── issues.md
│
│   # ════════════════════════════════════════════════════════════════
│   # project/ - PER-PROJECT TEMPLATES (instantiated in target repo)
│   # ════════════════════════════════════════════════════════════════
│
├── project/                     # ══ PER-PROJECT TEMPLATES ══
│   ├── settings.json            # Project settings template
│   ├── objectives/              # Goals/Roadmap
│   │   ├── GOALS.md.template
│   │   └── ROADMAP.md.template
│   ├── knowledge/               # Knowledge Base setup
│   │   └── README.md            # Instructions (Serena memories)
│   └── reports/                 # Skill output reports (git-versioned)
│       ├── analysis/            # /analyse output
│       │   └── .gitkeep
│       └── research/            # /research output
│           └── .gitkeep
│
└── .serena/                     # Local storage for Serena MCP (transient artifacts)
    └── README.md                # /validate, /reflect, /reflexion → stored here
```

**Installation targets:**

```bash
install.sh --global                    # .claude/ + global/ → ~/.claude/
install.sh --project <path>            # project/ → <path>/ (rel or abs)
install.sh --all <path>                # Both targets
```

**Abstraction layers:**

| Layer | Contents | Install Flag | Target |
| ----- | -------- | ------------ | ------ |
| `.claude/` | agents, skills, hooks, settings | `--global` | `~/.claude/` (CC-native) |
| `global/` | policy, workflows, templates | `--global` | `~/.claude/` (higher-level) |
| `project/` | objectives, knowledge, reports | `--project <path>` | `<path>/` (per-project) |
| `docs/` | SCZ's own project docs (dogfooding) | - | Not deployed |

**Data Foundation mapping:**

| Data Category | SCZ Location | Deployed via | Target |
| --------------- | ------------ | ------------ | ------ |
| Policy | `global/policy/` | `--global` | `~/.claude/policy/` |
| Procedures (workflows) | `global/workflows/` | `--global` | `~/.claude/workflows/` |
| Procedures (skills) | `.claude/skills/` | `--global` | `~/.claude/skills/` |
| Actors | `.claude/agents/` | `--global` | `~/.claude/agents/` |
| Objectives | `project/objectives/` | `--project <path>` | `<path>/objectives/` |
| Knowledge Base | `project/knowledge/` | `--project <path>` | `<path>/knowledge/` + Serena |
| Reports (file) | `project/reports/` | `--project <path>` | `<path>/reports/` (analysis, research) |
| Transient | Serena memories (project) | - | Serena (validation, reflection, reflexion) |

**Total: ~40 files**

### Artifact Storage Location

Artifacts are written to the **target project repo**, not SuperClaudeZero:

```text
# Working on project "my-app"
my-app/
├── docs/
│   ├── objectives/
│   │   └── ROADMAP.md       # Managed by user
│   ├── architecture/
│   │   ├── PRD.md           # Generated by /spec
│   │   ├── ARCHITECTURE.md  # Generated by /design
│   │   └── adr/             # ADR files from /design
│   └── development/
│       └── BACKLOG.md       # Generated by /plan
├── reports/                 # Git-versioned skill outputs
│   ├── analysis/            # /analyse output
│   │   └── 2026-01-23-auth-issue.md
│   └── research/            # /research output
│       └── 2026-01-23-oauth-providers.md
└── .serena/                 # Transient artifacts (Serena memories)
    # /validate → validation records
    # /reflect → reflection records
    # /reflexion → reflexion records

# Working on SuperClaudeZero itself
super-claude-zero/
├── docs/
│   ├── architecture/PRD.md  # This PRD (meta!)
│   └── ...
```

---

## User Stories

### US1: Idea to PRD
**As a** developer
**I want to** describe an idea and get a structured PRD
**So that** I have clear requirements before implementation

**Acceptance Criteria:**
- [ ] `/spec "build a CLI todo app"` produces PRD
- [ ] PRD contains: goals, functional requirements, acceptance criteria, user stories
- [ ] PRD identifies open questions for user

### US2: PRD to Architecture
**As a** developer
**I want to** take a PRD and generate architecture
**So that** I understand system design before coding

**Acceptance Criteria:**
- [ ] `/design` reads recent PRD from context
- [ ] Output contains: high-level design, components, constraints, risks, trade-offs, ADR
- [ ] Design references requirements traceability

### US3: Architecture to Tasks
**As a** developer
**I want to** break architecture into actionable tasks
**So that** I can implement incrementally

**Acceptance Criteria:**
- [ ] `/plan` reads recent architecture from context
- [ ] Output is Milestone → Phase → Epic → Task hierarchy (see [ADR-005](adr/005-task-decomposition-hierarchy.md))
- [ ] Dependencies between tasks are marked

### US4: End-to-End Orchestration
**As a** developer
**I want** Claude to orchestrate the full workflow
**So that** I don't manually chain commands

**Acceptance Criteria:**
- [ ] `/orchestrate "build a CLI todo app"` runs full workflow
- [ ] User consulted at key decision points
- [ ] Final output is implementation-ready task list with deliverable artifacts

### US5: Session Reflection
**As a** developer
**I want to** reflect on my session to capture learnings
**So that** future sessions benefit from experience

**Acceptance Criteria:**
- [ ] `/reflect` analyzes current session
- [ ] Errors/blockers captured with solutions
- [ ] Patterns stored in Serena memory

### US6: Code Analysis
**As a** developer
**I want to** investigate issues in codebase
**So that** I can troubleshoot effectively

**Acceptance Criteria:**
- [ ] `/analyse <issue>` produces investigation report
- [ ] Root cause identified where possible
- [ ] Suggested fixes provided

---

## Migration from SuperClaude v4

### Command Migration

| SuperClaude v4 | SuperClaudeZero | Notes |
| -------------- | --------------- | ----- |
| `/sc:brainstorm` | `/spec` | Renamed |
| `/sc:spec-panel` | `/design` | Renamed |
| `/sc:workflow` | `/plan` | Renamed |
| `/sc:reflect` | `/reflect` | Same |
| `/sc:pm` + `/sc:agent` | `/orchestrate` | Merged as command |
| `/sc:analyze` | `/analyse` | Renamed |
| `/sc:research` | `/research` | Same |
| `/sc:spawn` | (dropped) | Use native Task tool |
| `/sc:task` | `/orchestrate` | Absorbed |
| All other `/sc:*` | (dropped) | Simplified |
| Personas | Agents | Structural change |
| Modes | (dropped) | Not needed |
| Python package | (dropped) | Pure config |

### Behavioral Rules Generalization

SuperClaude v4 RULES.md contains valuable principles but with v4-specific references. Generalization needed:

| v4 Rule Section | Keep/Adapt | Notes |
| --------------- | ---------- | ----- |
| Rule Priority System | **Keep as-is** | Universal (Critical/Important/Recommended) |
| Agent Orchestration | **Adapt** | Remove persona references, align with agents |
| Workflow Rules | **Adapt** | Remove `/sc:load`/`/sc:save`, use SCZ commands |
| Planning Efficiency | **Keep as-is** | Universal parallelization principles |
| Implementation Completeness | **Keep as-is** | Universal |
| Scope Discipline | **Keep as-is** | Universal |
| Code Organization | **Keep as-is** | Universal |
| Workspace Hygiene | **Keep as-is** | Universal |
| Failure Investigation | **Keep as-is** | Universal |
| Professional Honesty | **Keep as-is** | Universal |
| Git Workflow | **Keep as-is** | Universal |
| Tool Optimization | **Adapt** | Remove MorphLLM, Magic references; keep parallelization |
| File Organization | **Adapt** | Remove `claudedocs/` specific references |
| Safety Rules | **Keep as-is** | Universal |
| Temporal Awareness | **Keep as-is** | Universal |
| Quick Reference | **Adapt** | Update tool matrix for SCZ MCP stack |

**Generalization principle**: Keep behavioral rules, remove implementation-specific commands/tools

---

## Design Decisions (Resolved)

| Question | Decision |
| -------- | -------- |
| Hook implementation | Hooks remind agents (validate, reflexion, reflect); agent decides |
| Artifact storage | Files in target project repo (or SCZ repo if improving SCZ itself) |
| Agent granularity | Keep all 7 agents |
| Workflow rigidity | Flexible - small/low-complexity can skip steps (e.g., roadmap → plan → task) |

---

## Next Steps

1. **User validation**: Confirm this PRD matches intent
2. **Design phase**: `/design` to create architecture specification
3. **Planning phase**: `/plan` to break into implementation tasks
4. **Implementation**: Build commands and agents incrementally

---

## Appendix: Orchestrator Blueprint Reference

This PRD is based on the Orchestrator blueprint ([BLUEPRINT.md](../objectives/BLUEPRINT.md)):

SuperClaudeZero [v0] implements a **lean subset** focused on:
- Skills and Agents (Actors)
- Two core Workflows
- Embedded Hooks (SessionStart, SubagentStop, Stop, SessionEnd)
- Serena-based Memory

Orchestrator [v1] features below are out of scope for this PRD:
- **Data Foundation**: Ontology, Policy, Procedures, Incentives, Knowledge Base, Knowledge Graph, Observability
- **Execution Engine**: Devcontainer, Runtime, Build Pipeline, Security Controls
- **Workflow Engine**: DAG, Reactive/Proactive triggers, HITL, Persistent state
