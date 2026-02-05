# AgentOrchestrator Vision

**Version**: 0.1.0
**Updated**: 2026-01-24

---

## Problem

AI coding assistants operate in single-turn mode: no persistent memory, no structured workflows, no self-validation. Users bear the orchestration burden.

## Vision

**"From assistant to orchestrator"**

Orchestrator transforms Claude Code into an autonomous software engineering orchestrator that:
- Coordinates specialized agents through defined workflows
- Validates its own work through hooks
- Learns from mistakes via reflexion
- Persists knowledge across sessions

## Technical Architecture Vision

True multi-agent system with independent, observable agents coordinated through workflow orchestration. Strands Agents framework with L1 Workflow, L2 Graph, and L3 Swarm coordination. Subscription-based authentication via custom Claude SDK provider and CLI wrappers for other providers.

**Architecture Pillars**:
- **MCP**: Agent ↔ Tools/Resources (client-server)
- **A2A**: Orchestrator ↔ Agent (task-based coordination)
- **Strands Framework**: L1 Sequential/DAG, L2 Conditional routing, L3 Autonomous mesh

## Target Users

Solo developers and small teams who want AI-assisted development with standardized processes and built-in validation.

## OKRs

**Objective**: Transform Claude Code into a self-orchestrating development partner by v0.1.0

**Key Results**:
1. Context setup overhead → -50%
2. End-to-end workflow completion → >80%
3. Same-class error recurrence → -70%

**Initiatives**:
- Multi-agent orchestration with specialized roles
- Hook-based validation at workflow boundaries
- Reflexion-driven error pattern learning

## Principles

1. **Minimal** - Ship smallest useful system (7 agents, 14 skills, hooks)
2. **Self-contained** - No external services beyond MCPs
3. **Self-validating** - Every agent output passes validation
4. **Self-learning** - Errors captured, patterns extracted

---

See: [BLUEPRINT.md](BLUEPRINT.md) | [PRD.md](../architecture/PRD.md) | [ROADMAP.md](ROADMAP.md)
