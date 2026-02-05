# ADR-009: Orchestration Framework Selection (Strands Agents)

**Status**: Accepted
**Date**: 2026-02-05
**Author**: Jarvis Orchestrator Research Team
**Deciders**: Architecture Team

---

## Context

Jarvis requires an orchestration framework to manage multi-agent workflows, coordinate task execution, and provide observability. Multiple production-ready frameworks are available with varying multi-agent capabilities, cloud integrations, and protocol support.

### Problem Statement

Which orchestration framework should Jarvis adopt for production multi-agent coordination (L1 Workflow, L2 Graph, L3 Swarm)?

### Decision Drivers

- Native A2A protocol support (per ADR-007)
- Multi-agent primitives (Swarm, Graph, Workflow)
- Production maturity and adoption
- Native OpenTelemetry observability
- Multi-provider model support (Claude, OpenAI, Gemini)
- Cloud deployment flexibility (AWS, Azure, GCP)
- Coordination level support (L1/L2/L3)

---

## Decision

**Use Strands Agents as primary orchestration framework for Jarvis.**

Combine with Hybrid MCP + A2A architecture (ADR-008) for multi-provider OAuth subscriptions.

---

## Rationale

### Framework Comparison Matrix

| Framework | A2A Support | Multi-Agent | Production | Observability | Cloud | Jarvis Coverage |
|-----------|-------------|-------------|------------|---------------|-------|-----------------|
| **Strands Agents** | ✅ Native | ✅ Swarm/Graph/Workflow | ✅ AWS Q, Glue | ✅ Native OTEL | AWS/Any | **70%** |
| MS Agent Framework | ✅ Native | ⚠️ Typed workflows | ✅ Azure | ✅ Zero-code OTEL | Azure/Any | 80%* |
| Pydantic AI | ✅ FastA2A | ⚠️ Graph-based | ⚠️ Growing | ✅ Logfire | Any | 85%** |
| Prefect | ❌ No | ❌ No | ✅ Enterprise | ⚠️ Flow-level | Any | N/A*** |

\* MS Agent Framework scores higher but Azure-centric, Claude-only OAuth
\*\* Pydantic AI scores higher but lacks workflow scheduling (needs Prefect)
\*\*\* Prefect not agent-native (orchestrates any Python code)

### Multi-Agent Native Design

**Strands Agents Primitives**:
```python
# L1: Workflow (Sequential/DAG)
workflow = Workflow([agent_a, agent_b, agent_c])

# L2: Graph (Conditional routing)
graph = Graph()
graph.add_conditional_edge(agent_a, router, {
    "analyze": agent_b,
    "implement": agent_c
})

# L3: Swarm (Autonomous collaboration)
swarm = Swarm([agent_a, agent_b, agent_c])
swarm.coordinate_autonomously()
```

**Native A2A Protocol**:
- Agent discovery via A2A AgentCard
- Peer-to-peer communication
- Agent mesh networks for L3 swarms

**Citation**: "Strands Agents SDK provides multi-agent primitives: Agents-as-Tools, Swarms, Graphs, Workflows with native A2A protocol for cross-platform agent discovery" - [Strands Documentation](https://strandsagents.com/)

### Production Maturity

**In Production**:
- Amazon Q (AWS AI assistant)
- AWS Glue (data integration)
- Kiro (community platform)

**Version**: v1.0 released July 2025 (production-ready)
**GitHub**: 4,972 stars, 615 forks (Python SDK)

**Citation**: "Strands Agents 1.0: Production-ready multi-agent orchestration made simple... Already used by multiple AWS production services" - [AWS Blog](https://aws.amazon.com/blogs/opensource/introducing-strands-agents-1-0-production-ready-multi-agent-orchestration-made-simple/)

### Native Observability

**First-Class OTEL Support**:
- Zero-code setup (native integration)
- Full agent reasoning traces
- Tool call spans with token usage
- Sub-agent delegation tracking
- Integrates with any OTEL backend (Jaeger, Datadog, AWS X-Ray)

**Jarvis Requirement**: Per ADR-010, unified observability is critical for meta-optimization.

### Multi-Provider Flexibility

**Native Providers**:
- Amazon Bedrock (Claude, Nova, Titan, Llama)
- Anthropic API (direct)
- OpenAI API (direct)
- Gemini Live (direct)

**Via LiteLLM**: Ollama, Cohere, Mistral, Stability, Writer (10+ total)

**Hybrid Integration**: Combine with ADR-008 (Hybrid MCP + A2A) to add subscription OAuth for Claude/OpenAI/Gemini.

### Cloud Flexibility

**Deployment Options**:
- AWS: EKS, Lambda, EC2, Fargate, Bedrock AgentCore
- Azure: AKS, Container Apps
- GCP: GKE, Cloud Run
- On-premises: Docker, K8s

**Not AWS-locked**: Runs anywhere despite AWS origin.

### Why Strands Over Alternatives

**vs MS Agent Framework**:
- ✅ Multi-provider (10+ via Bedrock/LiteLLM) vs Azure-centric
- ✅ Cloud agnostic vs Azure-optimized
- ✅ Multi-agent swarm native vs typed workflow only
- ❌ No native Claude SDK (but works with Hybrid MCP + A2A)

**vs Pydantic AI**:
- ✅ Multi-agent primitives built-in vs graph-based only
- ✅ Workflow scheduling included vs needs Prefect
- ✅ Production-proven vs growing adoption
- ❌ Less type safety vs FastAPI-style DX

**vs Prefect + Pydantic AI**:
- ✅ Single framework vs two-framework complexity
- ✅ Agent-native vs orchestrates any Python code
- ❌ Less polished HITL vs Prefect pause_flow_run

---

## Alternatives Considered

### Option 1: MS Agent Framework (Azure-Native)

**Pros**:
- ✅ Native Claude Agent SDK with subscription OAuth
- ✅ A2A + MCP integration built-in
- ✅ Zero-code OTEL (env vars only)
- ✅ Checkpointing for long-running workflows
- ✅ Middleware architecture (security, PII filtering)

**Cons**:
- ❌ Azure-centric (best experience on Azure)
- ❌ Claude-only OAuth (OpenAI/Gemini require API keys)
- ❌ Less multi-provider breadth (vs Strands 10+ models)
- ❌ Framework lock-in to MS ecosystem

**Why Rejected**: Azure commitment required. Jarvis targets cloud-agnostic deployment. Multi-provider OAuth solved via ADR-008 (Hybrid MCP + A2A).

### Option 2: Prefect + Pydantic AI (Best-of-Breed)

**Pros**:
- ✅ Best HITL (Prefect pause_flow_run with UI forms)
- ✅ Best type safety (Pydantic models)
- ✅ FastA2A reference implementation (Pydantic team)
- ✅ Best observability (Logfire)
- ✅ Cloud agnostic

**Cons**:
- ❌ Two frameworks (complexity)
- ❌ Prefect not agent-native (orchestrates any Python code)
- ❌ No subscription OAuth (API keys only)
- ❌ Manual A2A integration (not built-in to Prefect)

**Why Rejected**: Two-framework complexity. Strands provides integrated solution. HITL gap acceptable (Strands Interrupt primitive exists, though less polished).

### Option 3: Strands Agents + Prefect (AWS-Native Hybrid)

**Pros**:
- ✅ Strands multi-agent + Prefect HITL (best of both)
- ✅ A2A protocol support
- ✅ AWS production-proven

**Cons**:
- ❌ Two frameworks (same complexity as Pydantic AI option)
- ❌ Additional integration layer

**Why Rejected**: Adds complexity. Strands Interrupt primitive sufficient for MVP. Can revisit if HITL becomes critical gap.

---

## Consequences

### Positive

- ✅ **Single framework**: Integrated multi-agent, workflow, observability
- ✅ **Multi-agent native**: Swarm, Graph, Workflow primitives built-in
- ✅ **A2A protocol**: Native support for agent discovery and collaboration
- ✅ **Production-proven**: Used by Amazon Q, AWS Glue
- ✅ **Native OTEL**: First-class observability with zero-code setup
- ✅ **Multi-provider**: 10+ model providers via Bedrock + LiteLLM
- ✅ **Cloud agnostic**: Runs on AWS, Azure, GCP, on-prem

### Negative

- ⚠️ **HITL less mature**: Interrupt primitive exists but not as polished as Prefect
- ⚠️ **AWS-centric docs**: Less guidance for non-AWS deployments (though framework is cloud-agnostic)
- ⚠️ **No native Claude subscription OAuth**: Solved via ADR-008 (Hybrid MCP + A2A)
- ⚠️ **Learning curve**: Team must learn Strands SDK and A2A protocol

### Neutral

- Strands provides workflow scheduling (unlike Pydantic AI which needs Prefect)
- S3-backed session management (cloud-agnostic alternative: Redis/PostgreSQL)

---

## Implementation

### Affected Components

- Orchestrator Engine (Strands Workflow/Graph/Swarm integration)
- Agent Lifecycle (Strands agent registration and spawning)
- Workflow Engine (Strands execution engine)
- Observability Service Plane (Strands OTEL instrumentation)
- Context Propagation (Strands session management)

### Migration Path

**Phase 1: POC Setup**
```python
# Install Strands Agents
pip install strands-agents

# Create basic workflow
from strands_agents import Workflow, Agent

# Define agents
analyst = Agent(model="anthropic.claude-3-sonnet", tools=[...])
developer = Agent(model="anthropic.claude-3-sonnet", tools=[...])

# L1 Workflow
workflow = Workflow([
    ("analyze", analyst),
    ("implement", developer)
])

# Execute
result = workflow.run("Build authentication module")
```

**Phase 2: Multi-Agent Integration**
```python
# L2 Graph with conditional routing
from strands_agents import Graph

graph = Graph()
graph.add_agent("analyst", analyst)
graph.add_agent("architect", architect)
graph.add_agent("developer", developer)

graph.add_conditional_edge("analyst", router_fn, {
    "architecture_needed": "architect",
    "implementation_ready": "developer"
})

# L3 Swarm for autonomous collaboration
from strands_agents import Swarm

swarm = Swarm([analyst, architect, developer])
swarm.coordinate("Design and implement auth system")
```

**Phase 3: Observability Integration**
```python
# Configure OTEL exporter
import os
os.environ["OTEL_EXPORTER_OTLP_ENDPOINT"] = "http://collector:4318"

# Strands auto-instruments - no additional code needed!
```

**Phase 4: Hybrid MCP + A2A**
- Integrate A2A-MCP bridge (per ADR-008)
- Configure Strands as MCP client
- Connect to external agents (Claude Code CLI, ChatGPT CLI, gemini-cli)

### Verification

- ✅ Strands workflow executes L1 sequential tasks
- ✅ Strands graph routes conditionally in L2
- ✅ Strands swarm coordinates autonomously in L3
- ✅ OTEL traces show full agent execution with sub-spans
- ✅ A2A agent discovery works via AgentCard
- ✅ Session management persists state (S3 or Redis backend)

---

## Related

### Related ADRs

- [ADR-007](007-multi-agent-protocol-selection.md): A2A protocol for orchestrator-agent communication
- [ADR-008](008-multi-provider-integration-strategy.md): Hybrid MCP + A2A for multi-provider OAuth
- [ADR-010](010-observability-architecture.md): OTEL trace propagation (Strands native support)
- [ADR-011](011-coordination-level-strategy.md): L1→L2→L3 progressive implementation

### Related Requirements

- ROADMAP.md: v1 POC Phase - "Strands Framework Integration"
- BLUEPRINT.md: Workflow Engine - "Framework: Strands Agents (native A2A support)"

### Related Documentation

- [Multi-Agent Orchestration Research](../../analysis/Multi-Agent-Orchestration-Research.md#1-strands-agents-aws-open-source)
- [Strands Agents Documentation](https://strandsagents.com/)
- [AWS Blog: Strands Agents 1.0](https://aws.amazon.com/blogs/opensource/introducing-strands-agents-1-0-production-ready-multi-agent-orchestration-made-simple/)

---

## Notes

**Framework Flexibility**: While Strands Agents is selected as primary framework, the architecture remains flexible:
- A2A protocol support means agents work with any A2A-compatible orchestrator
- MCP integration via ADR-008 enables framework switching without losing subscription benefits
- Can re-evaluate if requirements shift (e.g., Azure commitment → MS Agent Framework)

**HITL Gap Mitigation**: Strands Interrupt primitive provides basic HITL support. For production, evaluate:
- Custom HITL UI on top of Interrupt primitive
- Strands + Prefect hybrid (if HITL becomes critical bottleneck)
- Wait for Strands HITL maturity improvements

---

## Revision History

| Date | Status | Notes |
|------|--------|-------|
| 2026-02-05 | Accepted | Initial proposal based on multi-agent research analysis |
