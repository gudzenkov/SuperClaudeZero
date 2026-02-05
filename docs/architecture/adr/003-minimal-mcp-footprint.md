# ADR-003: Minimal MCP Footprint

**Status**: Accepted
**Version**: 1.0
**Date**: 2026-01-23
**Context**: AgentOrchestrator v0 MCP server selection

---

## Context

SuperClaude v4 used 10+ MCP servers:
- AIRIS Gateway (60+ tools)
- Tavily (web search)
- Sequential-thinking (reasoning)
- Context7 (documentation)
- Serena (code/memory)
- Playwright (browser)
- Mindbase (learning)
- Chrome DevTools (performance)
- Magic (UI components)
- Plus others via gateway

This created:
- Complex installation
- Docker dependencies
- Maintenance burden
- Token overhead from tool descriptions

AgentOrchestrator aims for minimalism: "What's the smallest MCP set that enables core workflows?"

## Decision

**Two required MCP servers, one optional**:

| Server | Status | Purpose |
|--------|--------|---------|
| **Serena** | Required | Session persistence, semantic memory, symbolic code operations |
| **Context7** | Required | Documentation lookup, hallucination prevention |
| **Playwright** | Optional | Browser automation for validation |

### Explicitly Dropped

| Server | Replacement |
|--------|-------------|
| Tavily | Claude's native `WebSearch` tool |
| Sequential-thinking | Claude's native reasoning capabilities |
| AIRIS Gateway | Individual servers as needed |
| Mindbase | Serena memories (Reflexion tier) |
| Chrome DevTools | Deferred to v1 |
| Magic | Not needed for core workflows |

## Rationale

### Serena: Why Required

Serena provides three critical capabilities:

1. **Memory Persistence**
   - `write_memory`, `read_memory`, `list_memories`
   - Required for Semantic, Reflexion, and Transient memory tiers
   - No viable alternative without external service

2. **Symbolic Code Operations**
   - `find_symbol`, `replace_symbol_body`, `insert_after_symbol`
   - Enables precise code navigation and editing
   - Superior to grep/sed for structured code

3. **Project Context**
   - `activate_project`, `get_symbols_overview`
   - Provides project-aware operations
   - Essential for multi-file understanding

### Context7: Why Required

Context7 provides hallucination prevention:

1. **Official Documentation**
   - `resolve-library-id`, `query-docs`
   - Up-to-date API references
   - Prevents outdated knowledge issues

2. **Evidence-Based Development**
   - Core principle from SuperClaude v4
   - "Never guess - always verify"
   - Context7 enables verification

### Playwright: Why Optional

Browser automation is valuable but not core:

1. **Use Cases**
   - Visual validation (`/validate` with screenshots)
   - E2E testing automation
   - UI interaction testing

2. **Why Optional**
   - Many projects don't need browser testing
   - Adds complexity (browser process)
   - Core workflows work without it

### Native Replacements

| Dropped Server | Native Capability | Trade-off |
|----------------|-------------------|-----------|
| Tavily | `WebSearch` tool | Slightly less control, but sufficient |
| Sequential-thinking | Claude's chain-of-thought | No token overhead, similar quality |

## Consequences

### Positive

1. **Simple Installation**: 2 servers instead of 10+
2. **No Docker Required**: Serena and Context7 run natively
3. **Reduced Token Overhead**: Fewer tool descriptions in context
4. **Lower Maintenance**: Fewer dependencies to update

### Negative

1. **Reduced Capability**: No specialized research tools
2. **No Observability**: No tracing/metrics (deferred to v1)
3. **Limited Browser Automation**: Optional, not integrated

### Mitigations

1. **WebSearch**: Claude's native search covers most research needs
2. **Observability**: Session logs provide basic visibility; v1 adds tracing
3. **Playwright**: Users who need it can install it

## Installation Configuration

### Required Setup

```json
// settings.json
{
  "mcpServers": {
    "serena": {
      "command": "uvx",
      "args": ["serena", "--project", "."]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    }
  }
}
```

### Optional Addition

```json
// settings.json (with Playwright)
{
  "mcpServers": {
    "serena": { ... },
    "context7": { ... },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp-server"]
    }
  }
}
```

## Capability Matrix

| Capability | Without MCPs | Serena | Context7 | Playwright |
|------------|-------------|--------|----------|------------|
| Memory persistence | No | Yes | - | - |
| Semantic code ops | Limited | Yes | - | - |
| Documentation lookup | WebSearch | - | Yes | - |
| Browser automation | No | - | - | Yes |
| Web search | WebSearch | - | - | - |
| Reasoning | Native | - | - | - |

## Migration Path

### From SuperClaude v4

1. Remove MCP servers not in minimal set
2. Update skill files to use native WebSearch
3. Migrate Mindbase patterns to Serena Reflexion tier
4. Remove Sequential-thinking prompts (use native reasoning)

### To Orchestrator v1

1. Add observability MCP (OpenTelemetry)
2. Add guardrails MCP (content filtering)
3. Consider specialized research MCPs as needed

## Alternatives Considered

### Alternative 1: Zero MCPs

Use only Claude native capabilities.

**Rejected**:
- No memory persistence
- No documentation verification
- Cannot prevent hallucinations reliably

### Alternative 2: Full AIRIS Gateway

Single gateway providing all tools.

**Rejected**:
- Docker dependency
- Complex setup
- Token overhead from 60+ tool descriptions
- Most tools unused in core workflows

### Alternative 3: Three Required (including Playwright)

Make Playwright required for validation.

**Rejected**:
- Many projects don't need browser testing
- Adds complexity for simple workflows
- Can be added when needed

## Related Decisions

- **ADR-001**: Hook Reminder Pattern (no enforcement MCP)
- **ADR-002**: Four-Tier Memory (Serena as backend)

## References

- [Serena MCP](https://github.com/oraios/serena)
- [Context7 MCP](https://github.com/context7/mcp-server)
- [Playwright MCP](https://github.com/playwright/mcp-server)
- [PRD.md MCP Dependencies](../PRD.md#mcp-dependencies)
