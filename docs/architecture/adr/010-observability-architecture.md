# ADR-010: Observability Architecture (OpenTelemetry Trace Propagation)

**Status**: Accepted
**Date**: 2026-02-05
**Author**: Jarvis Orchestrator Research Team
**Deciders**: Architecture Team

---

## Context

In BYOL (Bring-Your-Own-License) multi-agent orchestration, agents run as separate processes with subscription OAuth. Without explicit instrumentation, traces become fragmented: orchestrator trace ends when sending request, agent starts new disconnected trace. This "black box" view prevents full lifecycle analysis, debugging, and meta-optimization.

### Problem Statement

How to achieve unified, end-to-end observability in Jarvis multi-agent system where orchestrator and agents are decoupled processes communicating via A2A/MCP protocols?

### Decision Drivers

- End-to-end trace visibility (orchestrator → agents → tools)
- Support for multi-protocol environment (A2A, MCP, ACP)
- W3C Trace Context standard compliance
- Minimal agent instrumentation overhead
- Production debugging and performance tuning
- Meta-optimization and learning (session-level analysis)

---

## Decision

**Implement OpenTelemetry trace context propagation across protocol boundaries using W3C Trace Context standard.**

Use `traceparent` injection in protocol metadata (A2A `_meta`, ACP env vars, MCP commands) to link orchestrator and agent spans into unified trace.

---

## Rationale

### The Core Problem: Disconnected Traces

**Without Trace Propagation**:
```
[Orchestrator]
  Span: workflow.execute (id: abc123)
    Span: send_task_to_agent (id: def456) [END]

[Agent Process - NEW TRACE]
  Span: process_task (id: xyz789) [ORPHANED]
    Span: tool.execute (id: ghi012)
```

**Result**: Cannot correlate orchestrator request with agent execution. Missing:
- Total latency (orchestrator → agent → tools → response)
- Bottleneck identification (which agent/tool is slow?)
- Failure attribution (where did error originate?)

**With Trace Propagation**:
```
Trace ID: abc123 (UNIFIED)

[Orchestrator]
  Span: workflow.execute
    Span: send_task_to_agent
      [Agent Process - SAME TRACE]
        Span: process_task (parent: send_task_to_agent)
          Span: tool.execute
```

**Result**: Single trace ID across all agents and protocols. Full end-to-end visibility.

### W3C Trace Context Standard

**Mechanism**: Pass `traceparent` string from caller to callee.

**Format**:
```
traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01
             ││ └─────────────┬──────────────┘ └────────┬────────┘ └┬
             ││               trace-id (32 hex chars)    parent-span-id │
             │└─ version                                              sampled flag
             └─ version prefix
```

**Citation**: "Trace Context standardizes propagation of distributed tracing context across service boundaries" - [W3C Trace Context Specification](https://www.w3.org/TR/trace-context/)

### Implementation Patterns by Protocol

#### Pattern 1: A2A Protocol (Agent-to-Agent)

**Mechanism**: Inject `traceparent` in `_meta` field of A2A messages.

```json
{
  "message": {
    "role": "agent",
    "parts": [{"text": "Can you handle the database query?"}]
  },
  "_meta": {
    "traceparent": "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
  }
}
```

**Required**:
- Sending agent: `inject_trace_context(message["_meta"])`
- Receiving agent: `extract_trace_context(message["_meta"])` → continue trace

**Use Case**: L2 Graph (optional peer messaging), L3 Swarm (always required)

#### Pattern 2: ACP Protocol (Orchestrator-to-Agent via Zed)

**Mechanism**: Inject `traceparent` in environment variables when spawning agent.

**Option A: Environment Variable (Recommended)**:
```python
# Orchestrator spawns agent with traceparent
env = {
    "OTEL_TRACEPARENT": current_traceparent,
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://collector:4318"
}
subprocess.Popen(["gemini", "--experimental-acp"], env=env)
```

**Option B: ACP `_meta` Field (Advanced)**:
```json
POST /session/new
{
  "cwd": "/project",
  "mcpServers": [...],
  "_meta": {
    "observability": {
      "traceparent": "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
    }
  }
}
```

**Agent Requirements**:
- Read `OTEL_TRACEPARENT` env var on startup OR `_meta.observability.traceparent`
- Initialize OTEL tracer with parent context
- Propagate to all internal spans

**Use Case**: Direct ACP orchestration (if used)

#### Pattern 3: MCP Protocol (Hybrid MCP + A2A)

**Mechanism**: A2A-MCP bridge propagates `traceparent` between protocols.

```
[Orchestrator] → MCP command (traceparent in metadata) →
  [A2A-MCP Bridge] → A2A message (_meta.traceparent) →
    [External Agent CLI]
```

**Bridge Responsibility**:
- Extract `traceparent` from MCP command metadata
- Inject `traceparent` into A2A message `_meta`
- Start bridge span as child of orchestrator span

**Use Case**: Hybrid MCP + A2A architecture (ADR-008)

### Unified OTEL Collector Configuration

**All agents export to centralized collector**:

```yaml
# otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 10s
    send_batch_size: 1024

  # Enrich spans with protocol metadata
  attributes:
    actions:
      - key: protocol.type
        from_attribute: net.protocol.name  # "a2a", "acp", "mcp"
      - key: agent.id
        from_attribute: service.name

exporters:
  otlp/jaeger:
    endpoint: jaeger:4317

  otlp/datadog:
    endpoint: datadog-agent:4317

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [attributes, batch]
      exporters: [otlp/jaeger, otlp/datadog]
```

**Benefits**:
- Protocol-agnostic (A2A, ACP, MCP all export to same collector)
- Vendor-agnostic (works with Jaeger, Datadog, AWS X-Ray, Grafana)
- Enrichment with protocol/agent metadata

### Why This Approach

**vs Manual Correlation**:
- ❌ Fragile (requires unique IDs in logs, error-prone)
- ❌ No standard tooling support
- ❌ High manual effort

**vs Application-Level Instrumentation Only**:
- ❌ Misses agent-internal operations
- ❌ No visibility into tool calls, LLM requests
- ❌ Requires access to agent internals

**vs No Observability**:
- ❌ Black box agent execution
- ❌ Impossible to debug distributed failures
- ❌ No performance optimization

**✅ W3C Trace Context**:
- ✅ Industry standard (OTEL, Jaeger, Datadog support)
- ✅ Works across process boundaries
- ✅ Minimal agent instrumentation (read env var or metadata)
- ✅ Full lifecycle visibility

---

## Alternatives Considered

### Option 1: No Trace Propagation (Baseline)

Each component (orchestrator, agents) emits independent traces to OTEL.

**Pros**:
- Zero custom instrumentation
- Agents work independently

**Cons**:
- ❌ **Fragmented traces** (cannot correlate orchestrator → agent)
- ❌ No end-to-end latency visibility
- ❌ Debugging distributed failures impossible
- ❌ No performance optimization data

**Why Rejected**: Defeats purpose of observability. Cannot analyze full workflow.

### Option 2: Manual Log Correlation via Unique IDs

Pass custom `request_id` in protocol messages, correlate via log aggregation.

**Pros**:
- No OTEL dependency
- Works with existing logging

**Cons**:
- ❌ Not a standard (requires custom tooling)
- ❌ Misses span relationships (no parent-child)
- ❌ No automatic timeline visualization
- ❌ Fragile (requires discipline to pass IDs everywhere)

**Why Rejected**: Reinvents wheel. W3C Trace Context is industry standard.

### Option 3: Application-Level Instrumentation Only

Instrument orchestrator only, treat agents as black boxes.

**Pros**:
- Simpler (no agent-side changes)
- Orchestrator visibility sufficient for basic monitoring

**Cons**:
- ❌ **No agent-internal visibility** (tool calls, LLM requests, reasoning)
- ❌ Cannot identify which agent/tool is bottleneck
- ❌ Missing failure attribution (agent errors appear as orchestrator timeouts)

**Why Rejected**: Critical visibility gap. Jarvis requires deep agent observability for meta-optimization.

---

## Consequences

### Positive

- ✅ **End-to-end traces**: Single trace ID from orchestrator → agents → tools
- ✅ **Standard compliance**: W3C Trace Context (works with all OTEL backends)
- ✅ **Protocol agnostic**: Works with A2A, ACP, MCP
- ✅ **Minimal overhead**: ~20ms bridge latency (if using MCP), negligible agent instrumentation
- ✅ **Production debugging**: Full visibility into distributed failures
- ✅ **Performance optimization**: Identify bottlenecks across agents
- ✅ **Meta-optimization**: Session-level analysis for learning

### Negative

- ⚠️ **Agent instrumentation required**: Agents must read `traceparent` and configure OTEL
- ⚠️ **Bridge complexity**: MCP bridge must propagate trace context (if using Hybrid architecture)
- ⚠️ **Protocol support**: Requires `_meta` field support (A2A has, ACP has, MCP extension)
- ⚠️ **External agent dependencies**: CLIs (Claude Code, ChatGPT, gemini-cli) must support OTEL

### Neutral

- OTEL collector required (but already planned for observability)
- Trace storage costs (Jaeger/Datadog/etc.) scale with traffic

---

## Implementation

### Affected Components

- Orchestrator Engine (Trace context injection)
- Agent Lifecycle (OTEL SDK initialization with parent context)
- A2A-MCP Bridge (Trace propagation between protocols)
- Observability Service Plane (OTEL collector, backends)

### Migration Path

**Phase 1: Orchestrator Instrumentation**
```python
from opentelemetry import trace
from opentelemetry.propagate import inject

tracer = trace.get_tracer(__name__)

# Start orchestrator span
with tracer.start_as_current_span("workflow.execute") as span:
    # Inject traceparent for agent
    carrier = {}
    inject(carrier)  # Adds "traceparent" key

    # Send to agent (A2A example)
    send_a2a_message(
        message={"role": "user", "parts": [...]},
        _meta={"traceparent": carrier["traceparent"]}
    )
```

**Phase 2: Agent Instrumentation**
```python
from opentelemetry import trace
from opentelemetry.propagate import extract

# Agent receives message
def process_message(message):
    # Extract parent trace context
    carrier = {"traceparent": message["_meta"]["traceparent"]}
    ctx = extract(carrier)

    # Start agent span as child
    with tracer.start_as_current_span("agent.process", context=ctx):
        # Agent logic here
        result = execute_task(message["parts"][0]["text"])
        return result
```

**Phase 3: MCP Bridge Propagation**
```python
# A2A-MCP Bridge
def handle_mcp_command(mcp_cmd):
    # Extract from MCP metadata
    carrier = {"traceparent": mcp_cmd.get("metadata", {}).get("traceparent")}
    ctx = extract(carrier)

    # Bridge span
    with tracer.start_as_current_span("bridge.translate", context=ctx):
        # Translate MCP → A2A
        a2a_msg = translate_to_a2a(mcp_cmd)

        # Inject for A2A agent
        inject(a2a_msg["_meta"])

        send_a2a_message(a2a_msg)
```

**Phase 4: OTEL Collector Deployment**
- Deploy collector with config (see Rationale section)
- Configure exporters (Jaeger, Datadog, AWS X-Ray)
- Set up dashboards for trace visualization

### Verification

- ✅ Orchestrator starts trace with unique `trace_id`
- ✅ Agent span has same `trace_id`, parent `span_id` = orchestrator span
- ✅ Tool call spans nested under agent span
- ✅ Full trace visible in Jaeger/Datadog (orchestrator → agent → tool)
- ✅ Latency breakdown shows time in each component
- ✅ Errors attributed to correct agent/tool

---

## Related

### Related ADRs

- [ADR-007](007-multi-agent-protocol-selection.md): A2A protocol (requires `_meta` trace propagation)
- [ADR-008](008-multi-provider-integration-strategy.md): MCP bridge (must propagate `traceparent`)
- [ADR-009](009-orchestration-framework-selection.md): Strands Agents (native OTEL support)

### Related Requirements

- ROADMAP.md: v1 MVP Phase - "OTEL (claude-code-otel) for Orchestrator"
- BLUEPRINT.md: Observability - "OpenTelemetry pipeline (claude-code-otel logs/traces/metrics)"

### Related Documentation

- [Multi-Agent Observability Analysis](../../analysis/Multi-Agent-Orchestration-Observability.md)
- [W3C Trace Context Specification](https://www.w3.org/TR/trace-context/)
- [OpenTelemetry Python SDK](https://opentelemetry-python.readthedocs.io/)

---

## Notes

**Protocol-Specific Events to Instrument**:

**ACP Events**:
- `POST /agent/initialize` - Capability negotiation
- `POST /session/new` - Session creation
- `POST /session/prompt` - User prompt processing
- Agent-to-orchestrator notifications

**A2A Events**:
- Agent Card discovery
- Task creation and state transitions (`SUBMITTED → WORKING → COMPLETED`)
- Message exchanges (agent-to-agent)
- Artifact generation

**MCP Events**:
- Tool discovery
- Tool execution
- Resource access
- Prompt/completion pairs

**Example: End-to-End Trace** (L3 Swarm):
```
Trace ID: 4bf92f3577b34da6a3ce929d0e0e4736

[Orchestrator] workflow.execute (root span)
  ├─[ACP] POST /session/new → Agent A (acp.session.create)
  │   └─[Agent A] internal.reasoning (agent.reasoning)
  │       └─[A2A] Agent A → Agent B: request_database_query (a2a.message.send)
  │           └─[Agent B] database.query (agent.tool.execution)
  │               └─[A2A] Agent B → Agent A: query_result (a2a.message.response)
  ├─[ACP] POST /session/new → Agent C (acp.session.create)
  │   └─[Agent C] file.analysis (agent.tool.execution)
  └─[ACP] aggregate_results (orchestrator.aggregation)
```

---

## Revision History

| Date | Status | Notes |
|------|--------|-------|
| 2026-02-05 | Accepted | Initial proposal based on observability analysis |
