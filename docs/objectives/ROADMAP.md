# SuperClaudeZero Roadmap

**Version**: 0.3.2
**Updated**: 2026-01-24

---

## Milestone Overview

| Milestone | Goal | Phases |
|-----------|------|--------|
| **v0** | Minimal viable multi-agent orchestration | Initial → Validation |
| **v1** | Full Orchestrator vision | MVP → Foundation → Factory |

---

# v0 Milestone

**Goal**: Minimal viable multi-agent orchestration framework for Claude Code.

**Scope**: 7 agents, 14 skills, 5 hooks, 2 workflows, 8 templates, 2 policies

---

## Initial Phase

Core orchestration with file-based memory and MD workflow templates.

### Epic: Hook System
**Depends on**: None

- [x] `inject-context.sh` (SessionStart)
- [x] `remind-validate.sh` (SubagentStop)
- [x] `remind-reflexion.sh` (SubagentStop)
- [x] `remind-reflect.sh` (Stop)
- [x] `checkpoint-session.sh` (SessionEnd)

### Epic: Core Agents
**Depends on**: Hook System

- [x] `business-analyst.md`
- [x] `architect.md`
- [x] `project-manager.md`
- [x] `developer.md`

### Epic: Support Agents
**Depends on**: Hook System

- [x] `validator.md`
- [x] `deployer.md`
- [x] `tech-writer.md`

### Epic: Agent-Backed Skills
**Depends on**: Core Agents, Support Agents

- [x] `spec/SKILL.md`
- [x] `design/SKILL.md`
- [x] `plan/SKILL.md`
- [x] `implement/SKILL.md`
- [x] `validate/SKILL.md`
- [x] `deploy/SKILL.md`
- [x] `document/SKILL.md`

### Epic: Utility Skills
**Depends on**: None

- [x] `reflexion/SKILL.md`
- [x] `reflect/SKILL.md`
- [x] `optimize/SKILL.md`
- [x] `analyse/SKILL.md`
- [x] `research/SKILL.md`
- [x] `distill/SKILL.md`

### Epic: Orchestration
**Depends on**: Agent-Backed Skills

- [x] `orchestrate/SKILL.md`

### Epic: Policy
**Depends on**: None

- [x] `RULES.md`
- [x] `PRINCIPLES.md`

### Epic: Workflows
**Depends on**: None

- [x] `SWE.md`
- [x] `meta-learning.md`

### Epic: Templates
**Depends on**: None

- [x] `vision.md`
- [x] `blueprint.md`
- [x] `prd.md`
- [x] `architecture.md`
- [x] `adr.md`
- [x] `roadmap.md`
- [x] `backlog.md`
- [x] `issues.md`

### Epic: Settings & Installer
**Depends on**: None

- [x] Global `settings.json`
- [x] Project `settings.json`
- [x] `.claude/settings.json`
- [x] `install.sh` (global + project modes)

---

## Validation Phase

Integration testing and documentation.

### Epic: Integration Validation
**Depends on**: All Initial Phase epics

- [x] End-to-end test: `/orchestrate` workflow
- [x] Dogfood: use SCZ to build SCZ docs
- [x] Update README.md

**→ TAG: v0.1.0 ✅**

---

# v1 Milestone (Orchestrator)

**Goal**: Full Orchestrator vision with observability, execution engine, and advanced workflows.

**Prerequisite**: v0.1.0  complete

---

## MVP Phase

File-based KB, local Devcontainer, Basic Workflow Engine with MD templates.

> **Note**: v0 components carry forward. This phase adds execution environment.

### Epic: Local Execution Environment
**Depends on**: v0 complete

- [ ] Devcontainer configuration
- [ ] Development environment setup
- [ ] Basic build integration

### Epic: Enhanced Memory
**Depends on**: v0 Memory System

- [ ] File-based Knowledge Base structure
- [ ] Improved Serena memory organization
- [ ] Session context management

---

## Foundation Phase

Ontology, Graph DB, Observability, Context Manager, Cloud Runtime.

**Prerequisite**: MVP Phase complete

### Epic: Data Foundation
**Depends on**: Enhanced Memory

- [ ] Ontology schema (entities, relationships)
- [ ] Knowledge GraphDB integration
- [ ] Observability DB (logs/traces/metrics)

### Epic: Context Manager
**Depends on**: Data Foundation

- [ ] Dynamic context loading
- [ ] Token budget management
- [ ] Priority-based context selection

### Epic: Cloud Runtime
**Depends on**: Local Execution Environment

- [ ] Remote Devcontainer support
- [ ] VM/K8s runtime configuration
- [ ] Environment isolation

### Epic: Build Pipeline
**Depends on**: Cloud Runtime

- [ ] GitOps integration
- [ ] MLOps integration
- [ ] CI/CD workflow definitions
- [ ] Artifact registry management

### Epic: Observability
**Depends on**: Data Foundation

- [ ] OpenTelemetry integration
- [ ] Sub-agent span tracking
- [ ] Metrics collection

---

## Factory Phase

Security, Resource Management, Evaluations, DAG Workflow Engine.

**Prerequisite**: Foundation Phase complete

### Epic: Security Controls
**Depends on**: Cloud Runtime

- [ ] Devcontainer isolation
- [ ] Cross-container restrictions
- [ ] Runtime/CI/Cloud permissions escalation
- [ ] Execution environment boundaries

### Epic: Guardrails
**Depends on**: Security Controls

- [ ] Command restriction in "Bypass permissions" mode
- [ ] Content filtering
- [ ] PII/secrets redaction
- [ ] Policy enforcement hooks

### Epic: Resource Management
**Depends on**: Observability

- [ ] Token budget allocation
- [ ] Compute resource limits
- [ ] Cost tracking

### Epic: Evaluations
**Depends on**: Observability

- [ ] Automated quality assessment
- [ ] Output validation framework
- [ ] Benchmark integration

### Epic: DAG Workflow Engine
**Depends on**: Context Manager, Resource Management

- [ ] DAG execution engine
- [ ] Reactive triggers (webhook/event)
- [ ] Proactive triggers (scheduled)
- [ ] Human-in-the-loop (HITL) gates
- [ ] Durable execution (failure recovery)
- [ ] Persistent & shared state

### Epic: Autonomous Agents
**Depends on**: DAG Workflow Engine, Guardrails

- [ ] Sensor/Ambient agent framework
- [ ] Background monitoring
- [ ] Proactive suggestions

**→ TAG: v1.0.0**

---

## Dependency Graph

```
v0 Milestone
├── Initial Phase
│   ├── Hook System ─────────────────┬──────────────────────┐
│   │                                │                      │
│   ├── Core Agents ◄────────────────┤                      │
│   │                                │                      │
│   ├── Support Agents ◄─────────────┘                      │
│   │                                                       │
│   ├── Agent-Backed Skills ◄── Core + Support Agents       │
│   │                                                       │
│   ├── Utility Skills (parallel) ──────────────────────────┤
│   ├── Policy (parallel) ──────────────────────────────────┤
│   ├── Workflows (parallel) ───────────────────────────────┤
│   ├── Templates (parallel) ───────────────────────────────┤
│   ├── Settings & Installer (parallel) ────────────────────┘
│   │
│   └── Orchestration ◄── Agent-Backed Skills
│
└── Validation Phase ◄── All Initial Phase epics
    └── Integration Validation
        → TAG: v0.1.0

v1 Milestone
├── MVP Phase ◄── v0.1.0
├── Foundation Phase ◄── MVP
└── Factory Phase ◄── Foundation
    → TAG: v1.0.0
```

---

## Progress Tracking

| Milestone | Phase | Epics | Tasks | Status |
|-----------|-------|-------|-------|--------|
| v0 | Initial | 10 | 40 | ✅ Complete |
| v0 | Validation | 1 | 3 | ✅ Complete |
| v1 | MVP | 2 | 6 | 🔲 Not started |
| v1 | Foundation | 5 | 15 | 🔲 Not started |
| v1 | Factory | 6 | 23 | 🔲 Not started |

---

## References

- **PRD**: [PRD.md](../architecture/PRD.md)
- **Architecture**: [ARCHITECTURE.md](../architecture/ARCHITECTURE.md)
- **Blueprint**: [BLUEPRINT.md](BLUEPRINT.md)
- **Task Hierarchy**: [ADR-005](../architecture/adr/005-task-decomposition-hierarchy.md)
