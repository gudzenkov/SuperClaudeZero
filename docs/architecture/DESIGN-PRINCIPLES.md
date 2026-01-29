# SCZ Design Principles

**Version**: 0.1.0
**Purpose**: Architecture principles specific to SuperClaudeZero multi-agent orchestration

---

## Core Principles

### P1: Skill as Source of Truth

Skills contain the full instructions. Agents are thin wrappers.

**Rationale**: Avoids duplication, ensures consistency between direct invocation (`/spec`) and orchestrated invocation (Task tool).

**Application**:
- Skill SKILL.md has complete workflow
- Agent .md has role context + skill injection
- Both paths result in same behavior

### P2: Convention Over Configuration

Sensible defaults reduce configuration burden.

**Rationale**: Most projects follow similar patterns. Configuration should be optional, not required.

**Application**:
- Default artifact locations (`docs/architecture/PRD.md`)
- Standard workflow depths (Full/Medium/Light)
- Automatic hook registration

### P3: Minimal Dependencies

Fewer dependencies = easier adoption.

**Rationale**: Each external dependency is a potential failure point and maintenance burden.

**Application**:
- Minimal required MCP servers
- Prefer Claude-native tools when possible
- Optional components clearly marked

### P4: Reminder, Not Enforcement

Hooks prompt; agents decide.

**Rationale**: Agents have context humans don't. Rigid enforcement causes false positives.

**Application**:
- Stop hooks show checklists
- Agent evaluates applicability
- User is final authority

### P5: Traceability

Every artifact connects to its source.

**Rationale**: Understanding "why" requires following the chain from requirement to implementation.

**Application**:
- PRD → Architecture → Task → Commit
- Explicit references (Refs: T-001)
- Consistent ID schemes

---

## Architectural Principles

### A1: Pure Configuration

Prefer declarative configuration over runtime code.

**Rationale**: Markdown and JSON are universally readable, easy to version, simple to modify.

**Application**:
- Agents: Markdown with YAML frontmatter
- Skills: Markdown with YAML frontmatter
- Settings: JSON
- Hooks: Shell scripts (thin wrappers)

### A2: Claude-Native Structures

Use Claude Code's built-in mechanisms.

**Rationale**: Native features are maintained, documented, and integrated.

**Application**:
- `.claude/agents/` for agent definitions
- `.claude/skills/` for skill definitions
- Task tool for agent spawning
- Hook system for lifecycle events

### A3: Layered Memory

Different persistence for different needs.

**Rationale**: Not all information has the same lifetime or access pattern.

**Application**:
- Session: Automatic (Claude JSONL)
- Semantic: Project knowledge (Serena)
- Reflexion: Error learnings (Serena)
- Transient: Validation records (Serena)

### A4: Workflow Flexibility

Adapt process to complexity.

**Rationale**: Simple changes don't need full ceremony. Complex projects need structure.

**Application**:
- Light: plan → implement
- Medium: spec → plan → implement → validate
- Full: All phases
- Complexity scoring guides selection

---

## Agent Principles

### AG1: Single Domain

Each agent owns one area of expertise.

**Rationale**: Clear ownership prevents conflicts and enables specialization.

**Application**:
- Business Analyst: Requirements
- Architect: Design
- Project Manager: Planning
- Developer: Implementation

### AG2: Explicit Boundaries

Define what agents will and won't do.

**Rationale**: Prevents scope creep, clarifies handoffs.

**Application**:
- "Will" section in agent definition
- "Won't" section in agent definition
- Clear delegation via Task tool

### AG3: Tool Restrictions

Limit tools to what's needed.

**Rationale**: Reduces risk of unintended side effects.

**Application**:
- Analysts: No Write/Edit
- Architects: No Write/Edit
- Deployers: permissionMode: plan

---

## Skill Principles

### SK1: Self-Contained

Skills have everything needed to execute.

**Rationale**: No hidden dependencies or implicit context.

**Application**:
- Complete workflow in SKILL.md
- Input/output specification
- Template references
- Validation checklist

### SK2: Composable

Skills can be invoked individually or orchestrated.

**Rationale**: Flexibility for different workflows.

**Application**:
- Direct: `/spec` invokes skill
- Orchestrated: `/orchestrate` coordinates multiple
- Same skill, same behavior

### SK3: Idempotent Where Possible

Re-running produces consistent results.

**Rationale**: Safe to retry, predictable behavior.

**Application**:
- /spec on same input → same PRD structure
- /plan on same architecture → same task breakdown
- Note: /implement may vary based on existing code

---

## Development Principles

### D1: Incremental Value

Each piece provides standalone value.

**Rationale**: Partial adoption should still help.

**Application**:
- Use just /spec without orchestration
- Use just agents without workflows
- Use just hooks without skills

### D2: Explicit Over Implicit

State assumptions and decisions clearly.

**Rationale**: Implicit knowledge gets lost, causes confusion.

**Application**:
- ADRs for significant decisions
- Comments for non-obvious code
- Explicit references over assumptions
