# ADR-005: Task Decomposition Hierarchy

**Status**: Accepted
**Version**: 1.1
**Date**: 2026-01-24
**Context**: Defining work breakdown structure for agent-driven development

---

## Context

SWE agent engineering requires a task decomposition model that:
- Aligns with git-native workflows (atomic commits)
- Supports parallel execution within phases
- Provides natural verification checkpoints
- Scales granularity based on complexity

Traditional hierarchies (Epic → Story → Task) are feature-centric and designed for human sprint cycles. Agent workflows need version-centric, commit-boundary-aware decomposition.

---

## Decision

Adopt a **four-level hierarchy**:

```
Milestone (Release)
└── Phase (Workflow Stage)
    └── Epic (Feature Group)
        └── Task (Atomic Commit)
```

### Level Definitions

| Level | Definition | Example | Git Artifact |
|-------|------------|---------|--------------|
| **Milestone** | Shippable release version | v0, v1, v2 | Tag |
| **Phase** | Workflow stage within milestone | Research, Design, Implement, Validate | — |
| **Epic** | Group of related tasks | "Authentication", "API Layer" | — |
| **Task** | Atomic, testable, committable unit | "implement config loader" | Commit |

### Task Invariants

Every Task:
1. **Atomic** — single coherent change
2. **Testable** — has validation criteria
3. **Committable** — leaves codebase in consistent state

### Epic Composition

Epics group related Tasks that together deliver a feature:

```
Epic: <feature-name>
├── Task: <change-1> → commit
├── Task: <change-2> → commit
├── Task: <change-3> → commit
└── Task: <tests> → commit
```

---

## Rationale

### Why Not Epic → Story → Task?
- Feature-centric, not version-centric
- No commit boundary awareness
- Designed for sprint cycles, not agent sessions

### Why Not Task Graph Terminology (Frontier, Barrier)?
- Execution-level abstraction (for schedulers)
- Not intuitive for planning
- Separates "what" from "when"

### Why This Hierarchy?
- **Milestone as Release**: Clear scope, shippable increment
- **Phase as Workflow**: Natural gates (no implement before design)
- **Epic as Feature Group**: Logical grouping of related work
- **Task as Commit**: Git-native, atomic, verifiable

---

## Consequences

### Positive
- Git-native workflow (every Task = valid commit)
- Clear verification points (phase transitions)
- Flexible granularity (Epics scale with complexity)
- Agent-friendly (unambiguous success criteria per Task)

### Negative
- Requires discipline to maintain Task atomicity
- Phase gates may slow parallel work across phases

### Neutral
- Compatible with existing CI/CD (commits trigger pipelines)
- Maps to traditional PM tools (Milestone ≈ Epic, Phase ≈ —, Epic ≈ Story, Task ≈ Task)

---

## Examples

### Generic Structure

```
<version> (Milestone)
├── Research Phase
│   └── Epic: <research-area>
│       └── Task: <analysis> → "docs: <description>"
│
├── Design Phase
│   └── Epic: <design-area>
│       └── Task: <specification> → "docs: <description>"
│
├── Implement Phase
│   ├── Epic: <feature-group-1>
│   │   ├── Task: <component-a> → "feat(<scope>): <description>"
│   │   └─ Task: <component-b> → "feat(<scope>): <description>"
│   └── Epic: <feature-group-2>
│       ├── Task: <component-x> → "feat(<scope>): <description>"
│       └── Task: <component-y> → "feat(<scope>): <description>"
│
└── Validate Phase
    └── Epic: <validation-area>
        └── Task: <tests> → "test: <description>"
    → TAG: <version>
```

---

## Related

- [ROADMAP.md](../../objectives/ROADMAP.md) — applies this hierarchy
- [ARCHITECTURE.md](../ARCHITECTURE.md) — system specification
