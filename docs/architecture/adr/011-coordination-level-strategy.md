# ADR-011: Coordination Level Strategy (Progressive L1→L2→L3)

**Status**: Accepted
**Date**: 2026-02-05
**Author**: Jarvis Orchestrator Research Team
**Deciders**: Architecture Team

---

## Context

Jarvis Orchestrator design includes three coordination levels:
- **L1 (Workflow)**: Sequential/DAG execution, hub-spoke
- **L2 (Graph)**: Conditional routing with optional peer messaging
- **L3 (Swarm)**: Autonomous agent collaboration

Each level increases complexity and autonomy but requires different protocol patterns, observability approaches, and testing strategies.

### Problem Statement

In which order should Jarvis implement coordination levels to minimize risk, validate patterns, and achieve production stability?

### Decision Drivers

- Risk management (incremental complexity)
- Pattern validation (learn before scaling)
- Production stability (prove L1 before L2, L2 before L3)
- Team learning curve (protocols, frameworks)
- Customer value delivery (L1 provides immediate value)

---

## Decision

**Implement coordination levels progressively: L1 → L2 → L3.**

Start with L1 Workflow (hub-spoke, ACP-only optional, A2A primary), validate observability and patterns, then add L2 Graph (conditional routing), and finally L3 Swarm (autonomous collaboration) only after L2 is production-stable.

---

## Rationale

### Complexity Progression

| Level | Pattern | Protocols | Orchestrator Role | Observability |
|-------|---------|-----------|-------------------|---------------|
| **L1** | Sequential/DAG | A2A orchestrator→agent | Full control (hub-spoke) | Simple (linear traces) |
| **L2** | Conditional routing | A2A primary + optional A2A peer | Flow controller | Medium (tree traces) |
| **L3** | Autonomous mesh | A2A native mesh | Minimal (spawn + escalation) | Complex (mesh traces) |

**Key Insight**: Each level adds protocol complexity and reduces orchestrator control.

**Citation**: "L1: ACP only - orchestrator controls all coordination. L2: ACP primary, A2A optional for direct peer messaging. L3: A2A primary - agents autonomously collaborate, orchestrator provides minimal control" - [A2A-ACP Analysis](../../analysis/A2A-ACP-Analysis.md)

### Risk Management

**L1 → L2 → L3 Minimizes Risk**:

**L1 Risks** (Lowest):
- ✅ Simple linear flow (easy to debug)
- ✅ Orchestrator has full visibility
- ✅ No peer-to-peer coordination (no race conditions)
- ⚠️ Framework integration learning curve

**L2 Risks** (Medium):
- ⚠️ Conditional routing logic (complexity)
- ⚠️ Optional peer messaging (new protocol pattern)
- ⚠️ Orchestrator vs peer decision boundary (design trade-off)
- ✅ Still orchestrator-controlled (fallback to mediation)

**L3 Risks** (Highest):
- ❌ Autonomous agent decision-making (unpredictable)
- ❌ Peer mesh coordination (distributed consensus)
- ❌ Limited orchestrator visibility (agents negotiate internally)
- ❌ Complex failure modes (agent conflicts, deadlocks)

**Progressive Strategy**: Validate L1 patterns before adding L2 complexity, validate L2 before attempting L3.

### Pattern Validation

**L1 Validates**:
- A2A protocol implementation (orchestrator client, agent server)
- OTEL trace propagation (ADR-010)
- Strands Agents framework integration (ADR-009)
- Task state management (SUBMITTED → WORKING → COMPLETED)
- Error handling and retries

**L2 Validates** (builds on L1):
- Conditional routing logic
- Optional A2A peer messaging (efficiency vs complexity trade-off)
- Router function design patterns
- Observability for branching workflows

**L3 Validates** (builds on L2):
- Agent mesh coordination
- Autonomous task delegation
- Conflict resolution policies
- Observability for distributed agent collaboration

**Key Point**: Cannot validate L3 patterns without L1/L2 foundation.

### Customer Value Delivery

**L1 Provides Immediate Value**:
- ✅ Sequential SWE workflows (spec → design → plan → implement → validate)
- ✅ Simple orchestration use cases (80% of initial requirements)
- ✅ Proves architecture viability
- ✅ Faster time to production

**L2 Adds Conditional Routing**:
- ✅ Dynamic workflow routing (e.g., complexity-based agent selection)
- ✅ Error recovery patterns (retry with different agent)
- ⚠️ Not required for MVP (can defer to v1 Foundation)

**L3 Enables Advanced Patterns**:
- ✅ Autonomous multi-agent research
- ✅ Collaborative problem-solving
- ⚠️ High-risk, defer to v1 Factory phase (per ROADMAP)

**Strategy**: Ship L1 to production quickly, gather feedback, then enhance with L2/L3.

### Protocol Usage by Level

| Level | Orchestrator → Agent | Agent ↔ Agent | Complexity |
|-------|---------------------|---------------|------------|
| **L1** | A2A (task delegation) | ❌ Not used | **Low** (single protocol, hub-spoke) |
| **L2** | A2A (routing) | ⚠️ Optional (efficiency) | **Medium** (conditional routing + optional peer) |
| **L3** | A2A (spawn + escalation) | ✅ Always (mesh) | **High** (distributed coordination) |

**Key Decision**:
- L1: A2A only (orchestrator controls everything)
- L2: A2A primary, optional A2A peer messaging (evaluate trade-off)
- L3: A2A mesh (agents control coordination)

**Rationale**: Simplifies L1 implementation (single protocol pattern), defers peer messaging complexity to L2.

### Framework Capabilities (Strands Agents)

**Strands Agents Supports All Levels**:

**L1: Workflow**:
```python
workflow = Workflow([agent_a, agent_b, agent_c])
workflow.run("task description")
```

**L2: Graph**:
```python
graph = Graph()
graph.add_conditional_edge(agent_a, router_fn, {
    "analyze": agent_b,
    "implement": agent_c
})
graph.run("task description")
```

**L3: Swarm**:
```python
swarm = Swarm([agent_a, agent_b, agent_c])
swarm.coordinate("task description")
```

**Strategy**: Implement L1 Workflow first (simplest API), add L2 Graph when routing needed, add L3 Swarm only after L2 proven.

### Why Not Skip to L3

**Arguments for "Build L3 First"**:
- L3 is most powerful (autonomous collaboration)
- L1/L2 are "subsets" of L3 capabilities
- Avoid rework (build ultimate architecture upfront)

**Why This Fails**:
- ❌ **Complexity risk**: L3 failure modes unknown without L1/L2 experience
- ❌ **No foundation**: Cannot debug L3 mesh coordination without understanding L1 traces
- ❌ **Delayed value**: 8-12 weeks to L3 vs 3-4 weeks to L1 production
- ❌ **Over-engineering**: May not need L3 for 80% of use cases

**Counterargument**: "L1 is not a subset of L3 - it's a different coordination pattern." Hub-spoke (L1) requires different observability, error handling, and orchestrator logic than mesh (L3).

---

## Alternatives Considered

### Option 1: All Levels Simultaneously

Implement L1, L2, L3 in parallel to "future-proof" architecture.

**Pros**:
- Complete feature set upfront
- No incremental releases

**Cons**:
- ❌ **Massive complexity**: Debugging three coordination patterns at once
- ❌ **Delayed production**: Significant delay to ship anything
- ❌ **Wasted effort**: May never need L3 (over-engineering)
- ❌ **No learning**: Cannot validate patterns before scaling

**Why Rejected**: High risk, delayed value, violates incremental delivery.

### Option 2: L3 First (Swarm-Native)

Build L3 autonomous swarm, implement L1/L2 as "degraded modes" (constrained L3).

**Pros**:
- Most powerful capabilities upfront
- Single architecture (no incremental transitions)

**Cons**:
- ❌ **Unvalidated patterns**: L3 mesh coordination unproven
- ❌ **Complex debugging**: Distributed failures hard to diagnose without L1 baseline
- ❌ **Team learning curve**: Steep (mesh coordination + A2A peer + observability)
- ❌ **Delayed production**: High delivery risk

**Why Rejected**: Too risky. Need L1 foundation to understand agent behavior before attempting L3 autonomy.

### Option 3: L1 Only (Forever)

Implement L1 Workflow, skip L2/L3 indefinitely.

**Pros**:
- Simplest architecture (hub-spoke only)
- Fastest time to production
- No peer messaging complexity

**Cons**:
- ❌ **Limited capabilities**: No conditional routing (L2), no autonomous swarms (L3)
- ❌ **Scalability limits**: Hub-spoke bottleneck for large agent meshes
- ❌ **Miss advanced use cases**: Collaborative problem-solving, autonomous research

**Why Rejected**: Limits long-term vision (BLUEPRINT specifies L1/L2/L3 support). But validates phased approach (start L1, defer L2/L3).

---

## Consequences

### Positive

- ✅ **Risk mitigation**: Incremental complexity, validate patterns before scaling
- ✅ **Faster time to value**: L1 production in 3-4 weeks (vs 8-12 for L3)
- ✅ **Learning foundation**: Understand agent behavior in L1 before attempting L3 autonomy
- ✅ **Pattern validation**: Prove OTEL, A2A, Strands integration at each level
- ✅ **Flexibility**: Can stop at L1 or L2 if L3 not needed

### Negative

- ⚠️ **Incremental releases**: Must ship L1, then L2, then L3 (not one big release)
- ⚠️ **API evolution**: Strands Workflow → Graph → Swarm API changes (manageable)
- ⚠️ **Deferred capabilities**: Conditional routing (L2) and swarms (L3) not in MVP

### Neutral

- Aligns with ROADMAP phasing (v0 MVP = L1, v1 Foundation = L2, v1 Factory = L3)
- Each level provides production value (not just stepping stones)

---

## Implementation

### Affected Components

- Orchestrator Engine (Coordination logic per level)
- Workflow Engine (Strands Workflow → Graph → Swarm)
- Observability Service Plane (Trace patterns per level)
- Policy Engine (Escalation rules, conflict resolution for L3)

### Migration Path

**Phase 1: L1 Workflow** (v0 MVP)
```python
# Strands Workflow
workflow = Workflow([
    ("spec", business_analyst),
    ("design", architect),
    ("implement", developer)
])

result = workflow.run("Build authentication module")
```

**Validation Criteria**:
- ✅ Sequential task execution works
- ✅ A2A protocol orchestrator→agent verified
- ✅ OTEL traces show linear workflow
- ✅ Error handling and retries functional
- ✅ Production deployment successful

**Phase 2: L2 Graph** (v1 Foundation)
```python
# Strands Graph
graph = Graph()
graph.add_agent("analyst", business_analyst)
graph.add_agent("architect", architect)
graph.add_agent("developer", developer)

graph.add_conditional_edge("analyst", complexity_router, {
    "simple": "developer",      # Skip architecture for simple tasks
    "complex": "architect"       # Route through architect for complex
})

result = graph.run("Add OAuth to API")
```

**Validation Criteria**:
- ✅ Conditional routing logic works
- ✅ Optional A2A peer messaging evaluated (efficiency vs complexity)
- ✅ OTEL traces show branching workflows
- ✅ Router function patterns documented

**Phase 3: L3 Swarm** (v1 Factory)
```python
# Strands Swarm
swarm = Swarm([business_analyst, architect, developer])

# Agents autonomously coordinate
result = swarm.coordinate("Research and implement real-time collaboration")
```

**Validation Criteria**:
- ✅ Agent mesh coordination works
- ✅ A2A peer messaging functional
- ✅ Conflict resolution policies effective
- ✅ OTEL traces show distributed collaboration
- ✅ Autonomous task delegation successful

### Verification Per Level

**L1**:
- Sequential execution: `spec → design → plan → implement`
- No peer messaging
- Linear OTEL traces

**L2**:
- Conditional routing: `analyst → [router] → architect OR developer`
- Optional peer messaging: `developer ↔ architect` (direct A2A)
- Branching OTEL traces

**L3**:
- Autonomous delegation: `analyst → [decides] → architect + developer` (agents negotiate)
- Mesh peer messaging: All agents can message all peers
- Mesh OTEL traces (complex topology)

---

## Related

### Related ADRs

- [ADR-007](007-multi-agent-protocol-selection.md): A2A for orchestrator-agent (used in all levels)
- [ADR-009](009-orchestration-framework-selection.md): Strands Agents (supports L1/L2/L3)
- [ADR-010](010-observability-architecture.md): OTEL trace propagation (complexity increases per level)

### Related Requirements

- ROADMAP.md: v0 MVP (L1), v1 Foundation (L2), v1 Factory (L3)
- BLUEPRINT.md: Coordination Levels - "L1 (Workflow), L2 (Graph), L3 (Swarm)"

### Related Documentation

- [A2A-ACP Analysis](../../analysis/A2A-ACP-Analysis.md#multi-agent-coordination-levels)
- [Multi-Agent Orchestration Research](../../analysis/Multi-Agent-Orchestration-Research.md)
- [Strands Agents Documentation](https://strandsagents.com/)

---

## Notes

**When to Move to Next Level**:

**L1 → L2 Criteria**:
- ✅ L1 in production with stable performance
- ✅ Team understands A2A protocol patterns
- ✅ OTEL observability validated
- ✅ Use case requiring conditional routing identified (otherwise defer L2)

**L2 → L3 Criteria**:
- ✅ L2 conditional routing stable
- ✅ Optional A2A peer messaging evaluated (decision on efficiency vs complexity)
- ✅ Use case requiring autonomous swarm identified (otherwise defer L3)
- ✅ Team ready for distributed coordination complexity

**Trade-Off Decision Point**: At L2, evaluate whether A2A peer messaging provides enough efficiency gain to justify complexity. If not, keep L2 simple (orchestrator-mediated only) and defer peer messaging to L3.

**Anti-Pattern**: Don't rush to L3 for "completeness." Only implement if validated use case exists.

---

## Revision History

| Date | Status | Notes |
|------|--------|-------|
| 2026-02-05 | Accepted | Initial proposal aligned with ROADMAP phasing |
