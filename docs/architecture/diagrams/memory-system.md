# Memory System Architecture

```
+=========================================================================+
|                          MEMORY SYSTEM                                   |
+=========================================================================+

TIER 1: SESSION (Automatic)
+--------------------------------------------------+
| Storage: ~/.claude/projects/<slug>/sessions/      |
| Format:  JSONL (Claude native)                   |
| Access:  CLAUDE_SESSION_ID                       |
| Writes:  Automatic                               |
| Reads:   /reflect                                |
+--------------------------------------------------+
         |
         v

TIER 2: SEMANTIC (Manual)
+--------------------------------------------------+
| Storage: Serena memories (knowledge/)            |
| Format:  Markdown                                |
| Writes:  /optimize                               |
| Reads:   Auto-load at agent spawn                |
+--------------------------------------------------+
         |
         ^

TIER 3: REFLEXION (SubagentStop)
+--------------------------------------------------+
| Storage: Serena memories (reflexion/)            |
| Format:  Structured YAML in markdown             |
| Writes:  Agent (via /reflexion)                  |
| Reads:   Query ad-hoc on errors/issues           |
+--------------------------------------------------+
         |
         v

TIER 4: TRANSIENT (Ephemeral)
+--------------------------------------------------+
| Storage: Serena memories (validation/,reflection/)|
| Format:  Structured markdown                     |
| Writes:  /validate, /reflect                     |
| Reads:   /optimize (for analysis)               |
| Lifecycle: Prunable                              |
+--------------------------------------------------+
```

## Agent Init Memory Loading

| Tier | Load Pattern | Content |
|------|--------------|---------|
| **Session** | N/A (Claude manages) | Full conversation transcript |
| **Semantic** | **AUTO-LOAD** at spawn | Project knowledge, patterns, decisions, conventions |
| **Reflexion** | **QUERY AD-HOC** on error | Known issues, causes, solutions, prevention |
| **Transient** | Not loaded | Ephemeral validation/reflection records |

## Related

- [ADR-002: Four-Tier Memory System](../adr/002-four-tier-memory.md)
