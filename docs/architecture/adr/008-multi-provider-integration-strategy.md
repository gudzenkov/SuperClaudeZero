# ADR-008: Multi-Provider Integration Strategy (Hybrid MCP + A2A)

**Status**: Accepted
**Date**: 2026-02-05
**Author**: Jarvis Orchestrator Research Team
**Deciders**: Architecture Team

---

## Context

Jarvis requires multi-provider agent support (Claude, OpenAI Codex, Gemini) with cost-effective authentication. API-based access is expensive for agentic workloads with heavy caching ($3-15/MTok). Subscription plans offer significant cost savings ($17-249/mo flat rate).

### Problem Statement

How to integrate multiple AI providers (Claude, OpenAI, Gemini) with OAuth subscription billing while maintaining framework flexibility and minimizing vendor lock-in?

### Decision Drivers

- Cost optimization (subscription vs API with caching)
- Multi-provider OAuth support (Claude + OpenAI + Gemini)
- Framework flexibility (no vendor lock-in)
- Cloud agnostic deployment (AWS, Azure, GCP)
- Minimal custom bridge complexity

---

## Decision

**Adopt Hybrid MCP + A2A Architecture (Option E) as primary integration strategy.**

Use A2A-MCP bridge to enable MCP-native agents (Claude Code CLI, ChatGPT CLI, gemini-cli) to participate in A2A orchestration with OAuth subscription auth.

---

## Rationale

### Coverage & Cost Analysis

| Option | Coverage | OAuth Support | Cost Savings |
|--------|----------|---------------|--------------|
| Hybrid MCP + A2A | **90%** (highest) | ✅ Claude + OpenAI + Gemini | **36x** (all 3 providers) |
| MS Agent Framework | 80% | ✅ Claude only (native SDK) | 36x (Claude only) |
| Strands Agents | 70% | ❌ API keys only | 0x (API rates) |
| Prefect + Pydantic AI | 85% | ❌ API keys only | 0x (API rates) |

**Hybrid MCP + A2A is the ONLY option providing multi-provider OAuth subscriptions.**

### Architecture Pattern

```
Orchestration Layer (Strands/Pydantic AI/MS Agent FW)
  ↓ MCP Client
A2A-MCP Bridge Server
  ↓ A2A Protocol
External Agents with OAuth Subscriptions:
  ├─ Claude Code CLI/SDK (Pro $17-20/mo, Max $100/mo)
  ├─ ChatGPT CLI (Plus $20/mo, Pro $200/mo)
  └─ gemini-cli (AI Plus $7.99/mo, AI Pro $19.99/mo)
```

**Key Mechanism**:
- Orchestrator speaks MCP to bridge
- Bridge translates MCP ↔ A2A
- External agents use subscription OAuth (not API keys)

### Cost Comparison

**API Baseline** (PAYG):
- Claude Sonnet: $3/MTok input, $15/MTok output
- Heavy agentic usage: $100-500/mo/developer

**Subscription** (OAuth):
- Claude Pro: $20/mo + ChatGPT Plus: $20/mo + Gemini AI Pro: $19.99/mo = **$60/mo total**
- Savings: 2-8x typical, **up to 36x with optimal prompt caching**

### Framework Flexibility

**Critical Advantage**: Works with ANY orchestrator supporting MCP.

| Framework | Integration |
|-----------|-------------|
| Strands Agents | ✅ MCP client → A2A-MCP bridge |
| Pydantic AI | ✅ MCP client → A2A-MCP bridge |
| MS Agent Framework | ✅ MCP client → A2A-MCP bridge |
| LangGraph | ✅ MCP client → A2A-MCP bridge |

**No vendor lock-in**: Switch orchestration frameworks without losing subscription benefits.

### Why Not Alternatives

**MS Agent Framework** (Option D):
- ✅ Native Claude Agent SDK with subscription OAuth
- ❌ **Claude-only** OAuth (OpenAI/Gemini require API keys)
- ❌ Azure-centric (best experience on Azure)
- ⚠️ Framework lock-in to MS Agent Framework

**Strands Agents** (Option C):
- ✅ AWS production-proven, native A2A
- ❌ **Zero subscription OAuth** (API keys only)
- ❌ No cost savings (PAYG rates)

**Prefect + Pydantic AI** (Option A):
- ✅ Best type safety, HITL, observability
- ❌ **Zero subscription OAuth** (API keys only)
- ❌ Two-framework complexity

---

## Alternatives Considered

### Option 1: Direct API Integration (Baseline)

Use Anthropic API, OpenAI API, Gemini API directly via framework integrations.

**Pros**:
- Simplest integration (native to frameworks)
- No additional bridge layer

**Cons**:
- **0x cost savings** (API PAYG rates)
- Expensive for agentic workloads ($100-500/mo/dev)
- No subscription benefits

**Why Rejected**: Cost prohibitive for heavy agentic usage.

### Option 2: MS Agent Framework with Native Claude SDK

**Pros**:
- ✅ Native Claude Agent SDK with subscription OAuth
- ✅ A2A + MCP integration built-in
- ✅ 36x cost savings for Claude
- Zero-code OTEL observability

**Cons**:
- ❌ **Claude-only** subscription OAuth (OpenAI/Gemini still API keys)
- Azure-centric architecture (best on Azure)
- Framework lock-in to MS Agent Framework
- Python-only (Claude SDK not available for .NET yet)

**Why Rejected**: Jarvis requires **multi-provider** OAuth (Claude + OpenAI + Gemini), not just Claude.

### Option 3: Strands Agents Standalone (AWS-Native)

**Pros**:
- Production-proven (Amazon Q, AWS Glue)
- Native A2A protocol support
- Multi-provider via Bedrock + LiteLLM (10+ models)
- Native OTEL observability

**Cons**:
- ❌ **API keys only** (no subscription OAuth)
- ❌ No cost savings (PAYG rates)
- AWS-optimized (vendor preference)

**Why Rejected**: No subscription economics. Cost disadvantage vs Hybrid approach.

---

## Consequences

### Positive

- ✅ **Multi-provider OAuth**: Claude + OpenAI + Gemini all with subscription auth
- ✅ **36x cost savings** across all three providers (subscription + caching vs API)
- ✅ **Framework flexibility**: Use ANY MCP-compatible orchestrator (Strands, Pydantic AI, etc.)
- ✅ **Cloud agnostic**: Runs on AWS, Azure, GCP, on-prem
- ✅ **No vendor lock-in**: Switch frameworks without losing subscription benefits
- ✅ **Community pattern**: A2A-MCP-Server (131 GitHub stars), active development

### Negative

- ⚠️ **Additional bridge layer**: A2A-MCP-Server adds ~20ms latency (minimal overhead)
- ⚠️ **External agent management**: Must run/monitor external CLIs (Claude Code CLI, ChatGPT CLI, gemini-cli)
- ⚠️ **Authentication setup**: One-time OAuth for each CLI (claude login, ChatGPT account, Google account)
- ⚠️ **SDK limitation**: Only Claude supports SDK subscription auth; OpenAI/Gemini require CLIs
- ⚠️ **Gemini provisioning**: Community reports Ultra plan users hitting free tier limits (bug under investigation)

### Neutral

- MCP bridge provides protocol translation only (stateless, minimal complexity)
- External agents run as separate processes (lifecycle management required)

---

## Implementation

### Affected Components

- Orchestrator Engine (MCP client integration)
- Agent Lifecycle (External agent spawning, monitoring)
- Observability Service Plane (Bridge event instrumentation)
- Security Layer (OAuth token management per CLI)

### Migration Path

**Phase 1: Custom Provider Integration (POC)**
*Goal: Fast concept validation using native/custom providers.*
- Implement custom Strands provider for Claude (using Claude Agent SDK)
- Validate orchestration logic and A2A protocol patterns
- **Note**: Uses direct API/SDK integration for speed, postponing bridge complexity.

**Phase 2: Bridge Setup & External Auth (MVP)**
*Goal: Enable multi-provider OAuth subscription savings.*
```bash
# Install A2A-MCP bridge
npx -y @regismesquita/mcp_a2a

# Claude Code CLI OAuth
claude login  # Pro/Max subscription

# ChatGPT CLI OAuth
chatgpt login  # Plus/Pro subscription

# Gemini CLI OAuth
gemini-cli auth  # AI Plus/Pro/Ultra subscription
```

**Phase 3: Orchestrator Integration**
```python
# Configure as MCP server in orchestrator
# Example with Strands Agents:

# 1. Register external agent via MCP bridge
register_agent(url="http://localhost:41242")

# 2. Send tasks to agent
task_id = send_message(
    agent_url="http://localhost:41242",
    message="Write a Python function for data validation"
)
```

**Phase 4: Multi-Agent Deployment**
- Deploy bridge for each provider (Claude, OpenAI, Gemini)
- Configure orchestrator with multiple MCP endpoints
- Set up usage limits and cost tracking
- Run evaluations to benchmark cost savings

### Verification

- ✅ Orchestrator sends MCP command to bridge
- ✅ Bridge translates to A2A protocol message
- ✅ External agent (Claude CLI with OAuth) processes task
- ✅ Results flow back through bridge to orchestrator
- ✅ Usage billed to subscription (not API PAYG)
- ✅ Cost tracking shows 10x+ savings vs API baseline

---

## Related

### Related ADRs

- [ADR-007](007-multi-agent-protocol-selection.md): A2A for orchestrator-agent communication
- [ADR-009](009-orchestration-framework-selection.md): Strands Agents (MCP-compatible)
- [ADR-010](010-observability-architecture.md): Bridge event instrumentation

### Related Requirements

- ROADMAP.md: v1 POC Phase - "A2A-MCP-Server for Gemini/Codex"
- BLUEPRINT.md: MCP - "Parallel: Search, Task (deep research)"

### Related Documentation

- [Multi-Agent Orchestration Research](../../analysis/Multi-Agent-Orchestration-Research.md#option-e-hybrid-mcp--a2a-architecture)
- [A2A-MCP Bridge GitHub](https://github.com/GongRzhe/A2A-MCP-Server)
- [Claude Subscription Cost Analysis](https://www.reddit.com/r/ClaudeAI/comments/1qpcj8q/claude_subscriptions_are_up_to_36x_cheaper_than/)

---

## Notes

**OAuth Subscription Support by Tool Type**:

| Provider | CLI (OAuth) | Agent SDK (OAuth) | Client SDK (API Only) |
|----------|-------------|-------------------|----------------------|
| Anthropic | ✅ Claude Code CLI | ✅ Claude Agent SDK | ❌ Anthropic Client SDK |
| OpenAI | ✅ ChatGPT CLI | ❌ OpenAI Agents SDK | ❌ OpenAI Client SDK |
| Google | ✅ gemini-cli | ❌ Gemini ADK | ❌ Google Gen AI SDK |

**Key Distinction**: Only **CLIs** and **Agent SDKs** support subscription OAuth. Basic **Client SDKs** are API wrappers (always API keys/PAYG).

**36x Calculation**: Community benchmarks show subscription + caching can reduce effective cost to ~$0.08/MTok vs $3/MTok API baseline = 37.5x. Actual savings depend on caching effectiveness for workload.

---

## Revision History

| Date | Status | Notes |
|------|--------|-------|
| 2026-02-05 | Accepted | Initial proposal based on multi-agent research analysis |
