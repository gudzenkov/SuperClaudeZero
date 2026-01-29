# Orchestrator Design Blueprint

**Version**: 0.2.1
**Status**: Accepted

---

## Milestone & Phase Overview

| Milestone | Phase | Scope |
|-----------|-------|-------|
| **v0** | Phase Zero | Core orchestration, file-based memory, MD workflow templates |
| **v1** | MVP | File-based KB, local Devcontainer, enhanced workflows |
| **v1** | Foundation | Ontology, Graph DB, Observability, Context Manager, Cloud Runtime |
| **v1** | Factory | Security, Resource Management, Evaluations, DAG Workflow Engine |

---

## v0 Milestone: Phase Zero

### Agents (7)
- Business Analyst, Architect, Project Manager, Developer, Validator, Deployer, Tech Writer

### Skills (14)
- Agent-backed (7): spec, design, plan, implement, validate, deploy, document
- Orchestration (1): orchestrate
- Utility (6): reflexion, reflect, optimize, analyse, research, distill

### Hooks (4 events, 5 scripts)
- SessionStart → Inject project context, parse AGENT_ID
- SubagentStop → Agent validation + reflexion [blocking]
- Stop → Orchestrator checklist, `/reflect` [blocking]
- SessionEnd → Cleanup, logging, checkpoint [non-blocking]

### Memory (4-tier)
- Session (Claude JSONL logs)
- Semantic (Serena project memories)
- Reflexion (Serena: known_issues/solutions)
- Transient (Serena: validation records)

### MCP (4)

| Server | Purpose | Use When |
|--------|---------|----------|
| **Serena** | Memory, symbolic code ops | Always (required) |
| **Context7** | Library/framework API docs | Need versioned lib docs, code examples |
| **DeepWiki** | GitHub repo documentation | Need to understand external repo architecture |
| **Playwright** | Browser automation | E2E testing, web scraping (optional) |

**Documentation lookup priority**: Context7 → DeepWiki → WebSearch

---

## v1 Milestone: Orchestrator Orchestrator

### MVP Phase
File-based knowledge base, local Devcontainer, enhanced workflows

### Foundation Phase
Ontology, Knowledge Graph DB, Observability DB, Context Manager, Cloud Runtime, Build Pipeline

### Factory Phase
Security Controls, Guardrails, Resource Management, Evaluations, DAG Engine, Autonomous Agents

---

## Full v1 Component Reference

### Data Foundation
- Objectives (Goals/Roadmap/Backlog)
- Ontology (entities)
- Policy (principles/rules/guidelines)
- Procedures (SOP/workflows/skills)
- Knowledge Base (file-based/semantic)
- Knowledge GraphDB (relations)
- Observability DB (logs/traces/metrics/evals)

### Core
1. Orchestrator
2. Context Manager
3. Agents
  - Business Analyst
  - Architect
  - Project Manager
  - Developer
  - Validator
  - Deployer
  - Tech Writer
4. Skills
  - Orchestrate
  - Spec (requirements, acceptance criteria, PRD)
  - Design (architecture/constraints/risks/trade-offs/ADR)
  - Plan (dependencies, backlog, phases)
  - Implement (code, tests, build)
  - Validate (quality, acceptance criteria)
  - Deploy (build, release)
  - Document (docs, guides)
  - Reflexion (error patterns/known issues/solutions)
  - Reflect (session meta-learning)
  - Optimize (fine-tune orchestrator/agent/policy instructions)
  - Analyse (investigation/troubleshooting)
  - Research (parallel MCP)
  - Distill (compaction/distillation/adjustable granularity)
5. Hooks
  - SessionStart -> Inject project & session-id
  - SubagentStop -> Agent validation, Reflexion [blocking]
  - Stop -> Orchestrator checklist, /reflect [blocking]
  - SessionEnd -> Cleanup, logging, state checkpoint [non-blocking]
  - Guardrails (content filtering, PII/secrets redaction, enforce policy) [v1]

### Monitoring
6. Observability
  - ccswarm (OpenTelemetry tracing, Langfuse metrics, sub-agent span)
  - Disler Custom Observability (sub-agent hooks)
  - OpenTelemetry (logs/traces/metrics, no sub-agent span)
7. Evaluations
  - Harbor

### Execution Engine
- Devcontainer (local/remote)
- Runtime Environment (VM/K8s)
- Build Pipeline (GitOps/MLOps)
- Security Controls
- Resource Management

### Workflow Engine
1. DAG Engine
   - Reactive (trigger/webhook) ↔ Proactive (time/event)
   - Frameworks (Claude Agent SDK / Pydantic AI / A2A / ACP)
  - Human-in-the-Loop (HITL)
  - Persistent & shared state
  - Failure management (Durable Execution)
2. Autonomous Agents
  - Sensor/Ambient Agents

---

## Related Documents

- [VISION.md](../objectives/VISION.md) - Why and for whom
- [PRD.md](PRD.md) - Detailed requirements and user stories
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical specification
- [ROADMAP.md](../objectives/ROADMAP.md) - Milestones, phases, epics
- [ADRs](adr/) - Architecture decision records
