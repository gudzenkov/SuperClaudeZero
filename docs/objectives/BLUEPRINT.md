# Orchestrator Design Blueprint

**Version**: 0.3.2
**Status**: Accepted

---

## Core Design

### Protocol Stack
**Active Protocols:**
- **MCP**: Agent ↔ Tools/Resources (client-server)
- **A2A**: Orchestrator ↔ Agent (task-based coordination)

**Coordination Levels:**
- **L1 (Workflow)**: Sequential/DAG execution via Strands + A2A
- **L2 (Graph)**: Conditional routing via Strands Graph + A2A
- **L3 (Swarm)**: Autonomous coordination via Strands Swarm + A2A native mesh

### Ontology Foundation
1. Data (concepts/categories/objects/properties/links/events)
  - Knowledge Base (file-based/semantic)
  - Knowledge Graph (relations)
  - Time-series (prices/metrics)
  - Analytics (OLAP)
  - Observability Data Plane (logs/traces/metrics/evals captured as immutable facts)
2. Logic
  - Incentives (Goals/Roadmap/Tasks)
  - Policy (principles/rules/guidelines/guardrails)
  - Workflow/Graph/Swarm coordination
  - ML model, LLM-function
3. Actions
  - Runtime/Orchestration/Workflow Engine execution
  - Procedures (SOP/workflows/skills)
  - Data Retrieval (KB/Graph/Mon/Evals)

---

## Core System Architecture

### Agents (7)
- Business Analyst, Architect, Project Manager, Developer, Validator, Deployer, Tech Writer

### Skills (14)
- Agent-backed (7): spec, design, plan, implement, validate, deploy, document
- Orchestration (1): orchestrate
- Utility (6): reflexion, reflect, optimize, analyse, research, distill

### Hooks (Lifecycle Events)
- **SessionStart** → Context injection & initialization
- **SubagentStop** → Agent validation & reflexion (blocking)
- **Stop** → Orchestrator checklist & reflection (blocking)
- **SessionEnd** → Cleanup, logging & state checkpoint (non-blocking)

### Memory (4-tier)
- Session (Claude JSONL logs)
- Semantic (Serena project memories)
- Reflexion (Serena: known_issues/solutions)
- Transient (Serena: validation records)

### MCP (5)

| Server | Purpose | Use When |
|--------|---------|----------|
| **Serena** | Memory, symbolic code ops | Always (required) |
| **Context7** | Library/framework API docs | Need versioned lib docs, code examples |
| **DeepWiki** | GitHub repo documentation | Need to understand external repo architecture |
| **Parallel** | Search (web research), Task (deep research, data enrichment) | Web lookups, analyst reports, batch processing |
| **Playwright** | Browser automation | E2E testing, web scraping (optional) |

**Documentation lookup priority**: Context7 → DeepWiki → Parallel Search → WebSearch

---

## Advanced Component Reference

### Runtime Engine
1. Devcontainer (local)
2. Runtime Environment (Docker/K8s/CloudRun)
3. Git Worktree Isolation (per Agent/Task)
4. Build Pipeline (GitOps/MLOps)
5. Security Controls
6. Resource Management (Token/Compute budgets)

### Orchestrator Engine
1. Agent Lifecycle
  - Discovery & registration (A2A Agent Cards, MCP for tools)
  - Spawning & termination (A2A task creation)
  - Health monitoring & recovery (A2A task status polling)
2. Task Management
  - Decomposition & delegation
  - Dependency resolution and status tracking
  - Priority & resource allocation
3. Context Propagation
  - Shared state distribution
  - Knowledge graph sync
  - Session & project context via Context Manager
4. Coordination
  - **L1 Workflow**: Hub-spoke via Strands + A2A (orchestrator delegates tasks sequentially)
  - **L2 Graph**: Conditional routing via Strands Graph + A2A (orchestrator controls flow, optional peer A2A)
  - **L3 Swarm**: Autonomous mesh via Strands Swarm + A2A native (agents collaborate via A2A peer protocol)
  - Result aggregation via A2A task artifacts and Strands state
  - Conflict resolution via policy engine
5. Control Plane
  - Execution monitoring
  - Performance tracking
  - Circuit breakers & rate limiting

### Workflow Engine
1. Engine (Strands Framework)
  - Initiation - reactive (trigger/webhook), proactive (time/event)
  - 3-tier coordination (Workflow/Graph/Swarm)
  - Framework: Strands Agents (native A2A support)
  - Native OpenTelemetry observability
  - Human-in-the-Loop (HITL): A2A INPUT_REQUIRED state + Strands Interrupt
  - Persistent & shared state (A2A task history + Strands durable agent)
  - Failure management (A2A FAILED/CANCELED states)
2. Workflow templates
  - SWE: Spec -> PRD -> Architecture -> Plan -> Backlog -> Epic/Milestone/Task
  - Meta-Learning: Session Log -> Reflection -> Meta-Opt Plan -> Assessment -> Rollout
  - Background: Sensor Agents -> Background routines
  - Autonomous: Ambient Agents -> Goal-oriented Research -> Meta-Opt Plan, Implementation

### Workflow Services
1. Data Connectors (MCP for tools, A2A-MCP for agents)
2. Context Manager
3. Agents
  - Architect
  - Project Manager
  - Developer
  - Validator
  - Deployer
  - Tech Writer
4. Commands/Skills/MCP
  - Orchestrate (default Orchestrator instructions)
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
  - Evaluate
5. Hooks (Transitioning from CC Hooks to Strands Workflow steps)
6. Observability Service Plane
  - OpenTelemetry pipeline (claude-code-otel logs/traces/metrics)
  - Prometheus (metrics) + Loki (events/logs)
  - Grafana Dashboards/alerts
7. Evaluations
  - Framework: Langfuse OR Harbor OR OpenEvals

### Security Layer
- Isolation (devcontainer/docker/VM/VPC/INET)
- Secret Manager (1P/KeePass/GCP)
- OAuth & Authentication (Hybrid A2A-MCP Bridge for Claude, Gemini, Codex)
- Policy-as-Code (OPA)
- RBAC & Agent permissions management
- Approvals (HITL)
- OpenGuardrails (Content filtering, PII/secrets redaction, command restriction)

---

## Related Documents

- [VISION.md](../objectives/VISION.md) - Why and for whom
- [PRD.md](PRD.md) - Detailed requirements and user stories
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical specification
- [ROADMAP.md](../objectives/ROADMAP.md) - Milestones, phases, epics
- [ADRs](adr/) - Architecture decision records
