# ADR-007: Multi-Agent Protocol Selection (A2A over ACP)

**Status**: Accepted
**Date**: 2026-02-05
**Author**: Jarvis Orchestrator Research Team
**Deciders**: Architecture Team

---

## Context

Jarvis Orchestrator requires a protocol for orchestrator-agent communication. Two candidates emerged:

- **ACP** (Agent Client Protocol) - Zed Industries
- **A2A** (Agent2Agent Protocol) - Linux Foundation

### Problem Statement

Which protocol should Jarvis use for orchestrator → agent communication to support multi-agent task delegation, observability, and long-running workflows?

### Decision Drivers

- Task-based work abstraction (explicit task IDs)
- Asynchronous execution model (non-blocking)
- Human-in-the-loop (HITL) support
- Multi-task management per agent
- Framework ecosystem compatibility
- Long-running task coordination

---

## Decision

**Use A2A Protocol exclusively for orchestrator-agent communication.**

No ACP layer. Agents implement A2A server interface directly.

---

## Rationale

### Design Intent Alignment

**ACP**: Designed for code **editors** controlling coding agents (Zed, VS Code, JetBrains)
- Session-centric (conversation model)
- Working directory context for file operations
- Synchronous request-response

**A2A**: Designed for **agent orchestration** and multi-agent workflows
- Task-centric (work model)
- Explicit task lifecycle (9-state machine)
- Asynchronous execution with polling/streaming

**Citation**: "The Agent2Agent (A2A) Protocol is an open standard designed to facilitate communication and interoperability between independent AI agent systems... Multi-Agent Workflows: Chain specialized agents together... Orchestrator agent delegates specialized tasks" - [A2A Specification](https://a2a-protocol.org/latest/specification/)

### Capability Comparison

| Requirement | ACP | A2A | Winner |
|-------------|-----|-----|--------|
| Task Delegation | ⚠️ Implicit (session) | ✅ Explicit Task object | A2A |
| Long-Running Tasks | ⚠️ Blocking session | ✅ Async polling | A2A |
| HITL | ⚠️ Manual | ✅ INPUT_REQUIRED state | A2A |
| Multi-Task per Agent | ❌ One session = one conversation | ✅ Multiple tasks per context | A2A |
| Status Monitoring | ⚠️ Stream only | ✅ tasks/get, tasks/list | A2A |
| State Machine | ❌ Implicit | ✅ 9-state lifecycle | A2A |

**Score**: A2A wins 8/12 capabilities relevant to orchestration.

### Framework Ecosystem Support

**Critical Finding**: All major orchestration frameworks support A2A natively, NOT ACP.

| Framework | A2A Support | ACP Support |
|-----------|-------------|-------------|
| Strands Agents (AWS) | ✅ Native | ❌ Not supported |
| Pydantic AI | ✅ Native (FastA2A) | ❌ Not supported |
| MS Agent Framework | ✅ Native | ❌ Not supported |
| LangGraph | ✅ Via patterns | ❌ Not supported |

Using ACP would require **custom bridges** for every framework. A2A is framework-native.

### Why Not ACP

1. **Design mismatch**: ACP designed for editor-agent, not orchestrator-agent
2. **Session model**: One session = one conversation (doesn't support concurrent tasks)
3. **Synchronous**: Blocks orchestrator for long-running tasks
4. **No task abstraction**: Can't reference specific work items
5. **Framework gap**: Requires custom adapters for Strands/Pydantic AI/etc.
6. **Redundant layer**: ACP inside A2A agents adds unnecessary abstraction

---

## Alternatives Considered

### Option 1: ACP for Orchestrator-Agent Communication

**Pros**:
- Working directory context (cwd parameter)
- MCP server configuration per session
- Session persistence and replay

**Cons**:
- Session-centric model doesn't fit orchestrator patterns
- No explicit task IDs
- Synchronous execution model
- Zero framework support
- Requires custom bridges for all orchestration frameworks

**Why Rejected**: Fundamental design mismatch. ACP optimized for editor-agent interaction, not orchestrator-agent delegation.

### Option 2: Hybrid ACP + A2A (ACP for control, A2A for peer)

**Pros**:
- Could leverage ACP session management
- A2A for agent-agent collaboration

**Cons**:
- Unnecessary complexity (two protocols for one interface)
- ACP doesn't add value for orchestration use case
- Agents need to implement both protocols
- Observation: Working directory and MCP config are **implementation details**, not protocol requirements

**Why Rejected**: Adds complexity without benefit. A2A sufficient for all orchestrator needs.

---

## Consequences

### Positive

- ✅ **Framework compatibility**: Native integration with Strands Agents, Pydantic AI, MS Agent Framework
- ✅ **Task-based model**: Explicit task IDs, state machine, lifecycle management
- ✅ **Async execution**: Non-blocking task delegation, concurrent task management
- ✅ **HITL native**: INPUT_REQUIRED/AUTH_REQUIRED states built into protocol
- ✅ **Observability**: tasks/get, tasks/list operations for monitoring
- ✅ **Single protocol**: Orchestrator-agent AND agent-agent both use A2A

### Negative

- ❌ **No working directory abstraction**: Agents manage file contexts internally (but this is implementation detail, not protocol concern)
- ❌ **No MCP config sharing**: Agents configure MCP servers internally (but same mitigation)
- ⚠️ **Learning curve**: Team must understand A2A task lifecycle vs ACP session model

### Neutral

- Working directory and MCP configuration become **agent implementation details**, not orchestrator concerns
- Agents responsible for internal file system management, tool connectivity

---

## Implementation

### Affected Components

- Orchestrator Engine (Task Management)
- Agent Lifecycle (Discovery, Spawning)
- Context Propagation (Task contexts vs sessions)
- Observability Service Plane (A2A event instrumentation)

### Migration Path

**Phase 1**: Implement A2A client in Jarvis orchestrator
**Phase 2**: Agents expose A2A server endpoints (direct implementation)
**Phase 3**: Replace any existing ACP usage with A2A task delegation
**Phase 4**: Integrate with A2A-native frameworks (Strands Agents)

### Verification

- ✅ Orchestrator successfully creates tasks via A2A message/send
- ✅ Agents transition tasks through state machine (SUBMITTED → WORKING → COMPLETED)
- ✅ HITL flow: Task reaches INPUT_REQUIRED, orchestrator provides input, task resumes
- ✅ Multi-task: Single agent handles 3+ concurrent tasks with independent states
- ✅ Observability: tasks/list returns all active tasks across agents

---

## Related

### Related ADRs

- [ADR-008](008-multi-provider-integration-strategy.md): Hybrid MCP + A2A for multi-provider OAuth
- [ADR-009](009-orchestration-framework-selection.md): Strands Agents (A2A native)
- [ADR-010](010-observability-architecture.md): A2A event instrumentation for OTEL

### Related Requirements

- ROADMAP.md: v1 MVP Phase - "A2A-MCP-Server for Gemini/Codex"
- BLUEPRINT.md: Protocol Stack - "A2A: Orchestrator ↔ Agent"

### Related Documentation

- [Multi-Agent Orchestration Research](../../analysis/Multi-Agent-Orchestration-Research.md)
- [Orchestrator-Agent Communication Analysis](../../analysis/Orchestrator-Agent-Communication.md)
- [A2A-ACP Capabilities Comparison](../../analysis/A2A-ACP-Capabilities-Comparison.md)

---

## Notes

**Historical Context**: IBM's "Agent Communication Protocol" (also called "ACP") was designed for orchestration but merged into A2A in August 2025 under Linux Foundation. It is now defunct. Zed's "Agent Client Protocol" (ACP) is a **different, separate protocol** designed for editor-agent interaction, NOT orchestration.

**Framework Principle**: Protocol defines the **interface**, not the **implementation**. How agents internally manage file systems, tools, or execution environments is an implementation detail that doesn't require exposing additional protocol layers.

---

## Revision History

| Date | Status | Notes |
|------|--------|-------|
| 2026-02-05 | Accepted | Initial proposal based on multi-agent research analysis |
