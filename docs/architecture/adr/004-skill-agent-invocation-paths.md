# ADR-004: Skill-Agent Invocation Paths

**Status**: Accepted
**Version**: 1.0
**Date**: 2026-01-24
**Context**: SuperClaudeZero v0 skill/agent routing design

---

## Context

SuperClaudeZero needs to support two invocation paths for agent-backed functionality:

1. **Direct**: User invokes skill directly (e.g., `/spec "todo app"`)
2. **Orchestrated**: User invokes `/orchestrate` which chains agents through workflow

The design must avoid instruction duplication while supporting both paths.

## Decision

**Use skill-driven injection**: Agent-backed skills use `context: fork` + `agent:` to inject skill content into the specified agent.

### Two Invocation Paths

```
PATH 1: DIRECT SKILL INVOCATION
───────────────────────────────
User: /spec "todo app"
        │
        v
┌─────────────────────────────────────┐
│ /spec SKILL.md                      │
│ context: fork                       │
│ agent: business-analyst             │
└─────────────────────────────────────┘
        │
        │ Claude Code spawns agent,
        │ INJECTS skill content
        v
┌─────────────────────────────────────┐
│ BA Agent                            │
│ (skill instructions in context)     │
│                                     │
│ Executes PRD generation             │
│ SubagentStop hooks fire             │
└─────────────────────────────────────┘
        │
        v
    PRD artifact


PATH 2: ORCHESTRATED INVOCATION
───────────────────────────────
User: /orchestrate "todo app"
        │
        v
┌─────────────────────────────────────┐
│ /orchestrate SKILL.md               │
│ (runs inline)                       │
│                                     │
│ Assesses complexity → FULL workflow │
└─────────────────────────────────────┘
        │
        │ Task tool (subagent_type: business-analyst)
        v
┌─────────────────────────────────────┐
│ BA Agent                            │
│ skills: [spec]  ← loads skill       │
│                                     │
│ Executes PRD generation             │
│ SubagentStop hooks fire             │
└─────────────────────────────────────┘
        │
        v
    PRD artifact
        │
        │ Orchestrator continues with next agent...
        v
    (Architect → Developer → ...)
```

### Injection Mechanism

From Claude Code docs:
> "The full content of each skill is injected into the subagent's context, not just made available for invocation."

Both paths use **content injection**, not runtime invocation:

| Path | Injection Mechanism | Result |
|------|---------------------|--------|
| Direct (`/spec`) | Skill's `context: fork` + `agent:` | Skill content injected into BA |
| Orchestrated | Agent's `skills: [spec]` frontmatter | Skill content injected into BA |

> **Note**: No infinite loop risk - injection is a one-time load, not recursive invocation.

### Skill Definition (Agent-backed)

```yaml
# .claude/skills/spec/SKILL.md
---
name: spec
description: Generate PRD from idea or requirements
argument-hint: <idea or requirements>
context: fork
agent: business-analyst
---

# /spec Skill

Generate a Product Requirements Document from the input.

## Process
1. Analyze input for scope and complexity
2. Identify stakeholders and user personas
3. Extract functional requirements
4. Define acceptance criteria
5. Generate user stories
6. Flag open questions

## Output
Write PRD to: docs/architecture/PRD.md
```

### Agent Definition

```yaml
# .claude/agents/business-analyst.md
---
name: business-analyst
description: Requirements elicitation and PRD generation
skills:
  - spec                              # Loaded for orchestrated path
hooks:
  SubagentStop:
    - type: command
      command: "./.claude/hooks/scripts/remind-validate.sh"
    - type: command
      command: "./.claude/hooks/scripts/remind-reflexion.sh"
---

You are a Business Analyst responsible for requirements elicitation
and PRD generation.

## Boundaries
- **Will**: Generate PRDs, define acceptance criteria, ask clarifying questions
- **Won't**: Write code, make architectural decisions
```

## Rationale

### Why Skill-Driven Injection (`context: fork`)

| Benefit | Explanation |
|---------|-------------|
| **Single source of truth** | Skill contains full instructions |
| **No duplication** | Agent doesn't repeat skill content |
| **Both paths work** | Direct uses `context: fork`, orchestrated uses `skills:` |
| **Hooks always fire** | Both paths spawn agent → SubagentStop hooks run |

### Path Comparison

| Aspect | Direct (`/spec`) | Orchestrated (`/orchestrate`) |
|--------|------------------|-------------------------------|
| Entry point | User types `/spec` | User types `/orchestrate` |
| Agent spawn | Via skill's `context: fork` | Via orchestrator's Task tool |
| Skill loading | Skill injects into agent | Agent loads via `skills:` |
| Hooks | Yes (SubagentStop) | Yes (SubagentStop) |
| Chaining | Single skill | Full workflow |

## Consequences

### Positive

1. **No instruction duplication**: Skill is the single source of truth
2. **Consistent behavior**: Both paths spawn agent, both fire hooks
3. **Flexible entry**: User chooses direct (single task) or orchestrated (workflow)

### Negative

1. **Dual configuration**: Skill has `agent:`, agent has `skills:` (must stay in sync)
2. **Indirection**: Understanding requires knowing both mechanisms

### Mitigations

1. **Convention**: Agent-backed skills always specify `context: fork` + `agent:`
2. **Convention**: Corresponding agent always lists skill in `skills:`
3. **Documentation**: Clear explanation of both paths

## Multi-Skill Model (Primary + Secondary)

Agents can receive multiple skills through different injection paths - both triggered by **USER actions**, not by agents invoking skills themselves.

### Primary Skills (Agent's `skills:` list)

Skills listed in agent's `skills:` frontmatter are **fully injected** into agent context at spawn:

```yaml
# Agent definition
skills:
  - design        # Full content injected when agent spawns
```

> "The full content of each skill is injected into the subagent's context, not just made available for invocation."
> — [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents#preload-skills-into-subagents)

### Secondary Skills (User's Adhoc Skill Invocation)

When USER invokes a skill with `context: fork` + `agent:` targeting an existing agent, that skill is injected as **secondary** content:

```text
USER invokes: /analyse "investigate auth patterns"

Skill /analyse has:
  context: fork
  agent: architect       ← Targets Architect agent

Result: Architect agent spawns with BOTH:
  - /design (from skills: list) - PRIMARY
  - /analyse (from user invocation) - SECONDARY
```

**Key Point**: Skills are loaded into agent context at spawn; agents execute the loaded instructions. USER triggers loading via:
1. Direct skill invocation (`/design`) with `context: fork` - spawns agent with skill loaded
2. Orchestrator calling Task tool - agent spawns with `skills:` list loaded
3. Adhoc skill invocation (`/analyse`) targeting same agent - spawns with both skills loaded

### Configuration Example

```yaml
# .claude/agents/architect.md
---
name: architect
description: System design and architecture
skills:
  - design                    # Primary: always injected
hooks:
  SubagentStop:
    - type: command
      command: "./.claude/hooks/scripts/remind-validate.sh"
---

You are an Architect responsible for system design.
```

```yaml
# .claude/skills/analyse/SKILL.md
---
name: analyse
description: Investigation and troubleshooting
context: fork
agent: architect              # Targets Architect as SECONDARY skill
---

Investigate: $ARGUMENTS
```

### Invocation Scenarios

| User Action | Agent | Skills Injected |
|-------------|-------|-----------------|
| `/design "auth"` | Architect | /design only |
| Orchestrator → Task(architect) | Architect | /design (from `skills:`) |
| `/analyse "patterns"` | Architect | /design (primary) + /analyse (secondary) |

## Implementation Checklist

For each agent-backed skill (primary):

- [ ] Skill has `context: fork` and `agent: <agent-name>`
- [ ] Corresponding agent has `skills: [<skill-name>]`
- [ ] Agent has SubagentStop hooks configured
- [ ] Skill contains full instructions (agent is thin)

For secondary skills targeting an agent:

- [ ] Skill has `context: fork` and `agent: <target-agent>`
- [ ] Do NOT add to target agent's `skills:` list
- [ ] Skill's `disable-model-invocation` controls discoverability

## Related Decisions

- **ADR-001**: Hook Reminder Pattern (SubagentStop hooks)
- **ADR-002**: Four-Tier Memory (reflexion via hooks)
- **ADR-003**: Minimal MCP Footprint

## References

- [Claude Code Skills - Run in Subagent](https://code.claude.com/docs/en/skills#run-skills-in-a-subagent)
- [PRD.md FR1.5, FR2.3](../PRD.md)
