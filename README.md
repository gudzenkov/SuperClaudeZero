# AgentOrchestrator

Minimalist multi-agent orchestration framework for Claude Code.
Inspired by SuperClaude.

**Version**: 0.1.0  | **Status**: v0 Initial Phase Complete

---

## Overview

AgentOrchestrator transforms Claude Code from a single-turn assistant into an orchestrated multi-agent system with:

- **7 Specialized Agents**: Business Analyst, Architect, Project Manager, Developer, Validator, Deployer, Tech Writer
- **14 Skills**: Workflow commands from `/spec` to `/deploy`
- **3 Workflow Depths**: Full, Medium, Light based on complexity
- **Hook System**: Lifecycle events for validation and learning
- **Memory Integration**: Serena MCP for persistent knowledge

---

## Quick Start

### Prerequisites

- **uv**: Required for Python operations and Serena MCP (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- **jq**: Required for JSON merging during installation (`apt install jq` or `brew install jq`)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/orchestrator.git
cd orchestrator

# Install globally (agents, skills, hooks, workflows)
./install.sh --global

# Install project templates to a target project
./install.sh --project /path/to/your/project

# Install both
./install.sh --all /path/to/your/project

# Overwrite existing markdown files during reinstall
./install.sh --global --overwrite
```

### What Gets Installed

**`--global` installs to `~/.claude/`:**
- `agents/` - Agent definitions (7 files)
- `skills/` - Skill definitions (14 directories)
- `hooks/scripts/` - Hook scripts (5 files) + shared library
- `settings.json` - Hook and MCP configuration
- `policy/` - PRINCIPLES.md, RULES.md, GUIDELINES.md
- `workflows/` - SWE.md, meta-learning.md
- `templates/` - Vision, Blueprint, PRD, Architecture, ADR, Roadmap, Backlog, Issues

**`--project` installs to `<path>/`:**
- `.claude/settings.json` - Project settings with prompt-based hook examples
- `.serena/project.yml` - Auto-generated via `uvx` (language auto-detection)
- `docs/policy/` - RULES.md, GUIDELINES.md templates
- `docs/knowledge/` - Project knowledge base
- `reports/` - Analysis and research directories

### Basic Usage

```bash
# Start a new Claude Code session in your project
cd /path/to/your/project
claude

# Use the orchestrator for guided workflows
/orchestrate Build a CLI tool for managing tasks

# Or use individual skills directly
/spec Build a task management CLI
/design
/plan
/implement T-001
```

---

## Skills Reference

### Workflow Skills (Agent-Backed)

| Skill | Agent | Purpose | Output |
|-------|-------|---------|--------|
| `/spec` | Business Analyst | Requirements elicitation | `docs/architecture/PRD.md` |
| `/design` | Architect | System architecture | `docs/architecture/ARCHITECTURE.md`, ADRs |
| `/plan` | Project Manager | Task decomposition | `docs/objectives/ROADMAP.md`, `docs/development/BACKLOG.md` |
| `/implement` | Developer | Code implementation | Source files, tests |
| `/validate` | Validator | Testing and verification | Validation report |
| `/deploy` | Deployer | Build and deployment | Deployment artifacts |
| `/document` | Tech Writer | Documentation | `docs/`, `README.md` |

### Utility Skills (Inline)

| Skill | Purpose | Output |
|-------|---------|--------|
| `/orchestrate` | Guided workflow orchestration | Coordinates agents |
| `/reflexion` | Error learning capture | Serena memory |
| `/reflect` | Session meta-learning | Serena memory |
| `/optimize` | System improvement proposals | Meta-opt plan |
| `/analyse` | Code investigation | `reports/analysis/` |
| `/research` | Documentation lookup | `reports/research/` |
| `/distill` | Content distillation (5-level granularity) | Replace original |

---

## Agents Reference

| Agent | Domain | Key Tools | Boundaries |
|-------|--------|-----------|------------|
| **Business Analyst** | Requirements | Read, Grep, Glob, WebSearch | No code, no architecture |
| **Architect** | Design | Read, Grep, Glob, WebSearch | No implementation |
| **Project Manager** | Planning | Read, Write, TaskCreate | No code, no design |
| **Developer** | Implementation | Read, Write, Edit, Bash, Task | No architecture decisions |
| **Validator** | Testing | Read, Grep, Glob, Bash | No fixes, no writes |
| **Deployer** | Deployment | Read, Write, Bash | No code changes, `permissionMode: plan` |
| **Tech Writer** | Documentation | Read, Write, Grep, Glob, AskUserQuestion | No code, no Edit |

### Agent Details

**Validator**: Runs tests, verifies acceptance criteria, checks code quality. Cannot modify code - reports findings only.

**Deployer**: Manages build and deployment operations. Runs in `permissionMode: plan` requiring user approval for destructive operations.

**Tech Writer**: Creates and maintains documentation. Uses `AskUserQuestion` for conflict detection - never silently overwrites docs when inconsistencies are detected between documents, code, or ADR decisions.

---

## Workflow Depths

Orchestrator assesses complexity and recommends appropriate workflow depth:

### Full Workflow
**Use when**: New product, complex system, multiple components

```
/spec -> /design -> /plan -> /implement -> /validate -> /deploy -> /document
```

### Medium Workflow
**Use when**: New feature, moderate complexity

```
/spec -> /plan -> /implement -> /validate
```

### Light Workflow
**Use when**: Simple change, bug fix

```
/plan -> /implement
```

---

## Project Structure

After installation, your project will have:

```
your-project/
├── .claude/
│   └── settings.json     # Project settings with prompt-based hooks
├── .serena/
│   └── project.yml       # Auto-generated Serena project config
├── docs/
│   ├── objectives/       # VISION.md, BLUEPRINT.md, ROADMAP.md
│   ├── architecture/     # PRD.md, ARCHITECTURE.md, adr/
│   ├── development/      # BACKLOG.md, ISSUES.md
│   └── knowledge/        # Project knowledge base
└── reports/
    ├── analysis/         # /analyse outputs
    └── research/         # /research outputs
```

---

## Artifact Hierarchy

Orchestrator follows a layered artifact structure:

```
Strategic (locked after PRD)
├── VISION.md        # Why, target users, success metrics
└── BLUEPRINT.md     # Technical scope, capabilities, feature matrix

Specification (changes with approval)
├── PRD.md           # Features, user stories, acceptance criteria
├── ARCHITECTURE.md  # System design, risks, dependencies
└── adr/             # Decision rationale, alternatives, consequences

Execution (changes frequently)
├── ROADMAP.md       # Milestones, phases, epics + dependencies
├── BACKLOG.md       # Prioritized tasks from ROADMAP epics
└── ISSUES.md        # Discovered bugs, blockers, tech debt
```

---

## MCP Requirements

| Server | Purpose | Required |
|--------|---------|----------|
| **Serena** | Memory persistence, symbolic code ops | Yes |
| **Context7** | Documentation lookup | Yes |
| **DeepWiki** | GitHub repository documentation | Yes |
| **Playwright** | Browser automation | Optional |

MCP servers are pre-configured in `settings.json`. Serena requires `uvx` for dynamic project initialization.

---

## Hook System

Orchestrator uses Claude Code hooks for lifecycle management.

### Global Hooks (command-based)

Installed to `~/.claude/settings.json`:

| Event | Script | Purpose |
|-------|--------|---------|
| SessionStart | `inject-context.sh` | Inject context, log session start |
| SubagentStart | `inject-context.sh` | Inject context, log agent start |
| SubagentStop | `remind-validate.sh`, `remind-reflexion.sh` | Validation + reflexion prompt |
| Stop | `remind-reflect.sh` | Prompt /reflect for session learning |
| SessionEnd | `checkpoint-session.sh` | Cleanup and logging |

### Project Hooks (prompt-based)

Installed to `.claude/settings.json`:

| Event | Type | Purpose |
|-------|------|---------|
| Stop | prompt | Evaluate task completion before stopping |
| SubagentStop | prompt | Validate subagent completion |

Prompt-based hooks use Claude to evaluate conditions and return JSON responses.

Hooks provide **reminders**, not enforcement. Agents decide whether to act (ADR-001).

---

## Configuration

### Global Settings (`~/.claude/settings.json`)

Installed by `--global` flag. Contains:
- Hook configurations (command-based)
- MCP server definitions (Serena, Context7, DeepWiki)
- Default permissions

### Project Settings (`.claude/settings.json`)

Installed by `--project` flag. Contains:
- Project-specific hooks (prompt-based examples)
- Inherits MCP and permissions from global

---

## Policy Files

Three-tier policy structure:

| Location | Purpose | Installed To |
|----------|---------|--------------|
| `global/policy/` | Framework-wide policies for all projects | `~/.claude/policy/` |
| `docs/policy/` | Orchestrator project-specific policies | Not installed |
| `project/docs/policy/` | Project template (RULES.md, GUIDELINES.md) | `<project>/docs/policy/` |

**Policy files**:
- `PRINCIPLES.md` - Core software engineering principles
- `RULES.md` - Actionable behavioral rules with priorities
- `GUIDELINES.md` - Usage guidance and best practices

Projects can customize `<project>/docs/policy/` files to supplement (not replace) global policies.

---

## Templates

Orchestrator provides templates for all artifact types in `~/.claude/templates/`:

| Template | Purpose | Output Location |
|----------|---------|-----------------|
| `vision.md` | Project vision and OKRs | `docs/objectives/VISION.md` |
| `blueprint.md` | Technical scope and capabilities | `docs/objectives/BLUEPRINT.md` |
| `prd.md` | Product requirements document | `docs/architecture/PRD.md` |
| `architecture.md` | System architecture | `docs/architecture/ARCHITECTURE.md` |
| `adr.md` | Architectural decision records | `docs/architecture/adr/` |
| `roadmap.md` | Milestones, phases, epics | `docs/objectives/ROADMAP.md` |
| `backlog.md` | Prioritized task list | `docs/development/BACKLOG.md` |
| `issues.md` | Bugs, blockers, tech debt | `docs/development/ISSUES.md` |

---

## Development

### Task Hierarchy (ADR-005)

```
Milestone (v0, v1)     -> Git Tag
└── Phase (Initial, Validation)
    └── Epic (Hook System, Core Agents, ...)
        └── Task (atomic, testable) -> Git Commit
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Use Orchestrator to plan and implement (`/orchestrate your feature`)
4. Submit a pull request

---

## Documentation

- [Vision](docs/objectives/VISION.md) - Project vision and goals
- [Blueprint](docs/objectives/BLUEPRINT.md) - Technical scope
- [PRD](docs/architecture/PRD.md) - Product requirements
- [Architecture](docs/architecture/ARCHITECTURE.md) - System design
- [ADRs](docs/architecture/adr/) - Architectural decisions
- [Roadmap](docs/objectives/ROADMAP.md) - Milestones and phases
- [Backlog](docs/development/BACKLOG.md) - Task tracking
- [Serena Integration](.serena/README.md) - Memory system guide
- [Hook System](.claude/hooks/README.md) - Hook documentation
- [Principles](global/policy/PRINCIPLES.md) - Software engineering principles
- [Rules](docs/policy/RULES.md) - Behavioral rules
- [Guidelines](docs/policy/GUIDELINES.md) - User guidance

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Acknowledgments

Built for Claude Code by Anthropic.
