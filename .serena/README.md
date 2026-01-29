# Serena MCP Integration

**Version**: 0.1.0

Documentation for Serena MCP usage in SuperClaudeZero.

---

## Overview

Serena MCP provides persistent memory and symbolic code operations for SCZ. It enables:
- Cross-session knowledge persistence
- Error learning capture (reflexion)
- Validation record storage
- Codebase semantic understanding

---

## Project Initialization

The SCZ installer automatically initializes Serena for new projects:

```bash
./install.sh --project /path/to/your/project
```

This runs:
```bash
uvx --from git+https://github.com/oraios/serena serena project create --name <project-name>
```

The command auto-detects programming languages and creates `.serena/project.yml`.

### Manual Initialization

If automatic initialization fails (e.g., `uvx` not installed):

```bash
cd /path/to/your/project
uvx --from git+https://github.com/oraios/serena serena project create
```

---

## Memory Tiers (ADR-002)

SCZ uses a four-tier memory architecture:

| Tier | Purpose | Storage | Lifetime |
|------|---------|---------|----------|
| **Session** | Conversation history | Claude JSONL | Session |
| **Semantic** | Project knowledge | Serena project memory | Persistent |
| **Reflexion** | Error learnings | Serena project memory | Persistent |
| **Transient** | Validation records | Serena | Session/Short-term |

---

## Memory Namespaces

SCZ uses namespaced memory for organization:

### `knowledge/`
Project-level semantic knowledge:
- Domain concepts
- Architecture patterns
- Team conventions

**Example**:
```
knowledge/api-patterns
knowledge/auth-conventions
knowledge/testing-strategy
```

### `reflexion/`
Error learnings from `/reflexion` skill:
- Known issues
- Root causes
- Solutions
- Prevention strategies

**Example**:
```
reflexion/2026-01-24-token-refresh-edge-case
reflexion/2026-01-23-db-connection-timeout
```

### `reflect/`
Session reflection records from `/reflect` skill:
- Session summaries
- Lessons learned
- Patterns identified
- Improvement suggestions

**Example**:
```
reflect/2026-01-24-session-abc123
```

### `validation/`
Transient validation records from `/validate` skill:
- Test results
- AC verification
- Quality checks

**Example**:
```
validation/T-001-2026-01-24
```

---

## Serena Tools

### Memory Operations

| Tool | Purpose |
|------|---------|
| `read_memory` | Retrieve stored knowledge |
| `write_memory` | Store new knowledge |
| `list_memories` | List available memories |
| `delete_memory` | Remove outdated memory |

### Code Operations

| Tool | Purpose |
|------|---------|
| `find_symbol` | Locate code symbols |
| `get_definition` | Get symbol definition |
| `find_references` | Find symbol usage |
| `get_hover_info` | Get type/doc info |

---

## Usage Patterns

### Storing Reflexion

```
/reflexion
-> Captures error learning
-> write_memory("reflexion/2026-01-24-issue-name", content)
```

### Retrieving Knowledge

```
/implement T-001
-> Agent needs context
-> read_memory("knowledge/api-patterns")
-> Informed implementation
```

### Session Reflection

```
/reflect
-> Analyzes session
-> write_memory("reflect/session-id", summary)
-> Available for future /optimize
```

---

## Configuration

### Global Settings (`~/.claude/settings.json`)

Serena is configured in the global settings:

```json
{
  "mcpServers": {
    "serena": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/oraios/serena", "serena", "start-mcp-server", "--context", "claude-code"],
      "env": {}
    }
  }
}
```

### Project Configuration (`.serena/project.yml`)

Auto-generated during `--project` installation. Contains:
- Project name
- Detected languages
- Analysis settings

---

## Best Practices

### 1. Namespace Consistently
Always use the appropriate namespace prefix:
- `knowledge/` for permanent project info
- `reflexion/` for error learnings
- `reflect/` for session insights
- `validation/` for temporary records

### 2. Date-Prefix Temporal Records
Include dates in reflexion and reflection keys:
```
reflexion/2026-01-24-description
reflect/2026-01-24-session-summary
```

### 3. Keep Records Focused
Each memory entry should cover one topic. Split large content into multiple entries.

### 4. Clean Up Transient Data
Validation records can be pruned after tasks complete. Don't let transient data accumulate.

### 5. Reference, Don't Duplicate
Link to code and docs rather than copying content into memory.

---

## Troubleshooting

### Memory Not Found

1. Check namespace spelling
2. Verify memory was written successfully
3. Use `list_memories` to see available entries

### Serena Not Available

1. Check `~/.claude/settings.json` configuration
2. Verify `uvx` is installed (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
3. Restart Claude Code session
4. Check `.serena/project.yml` exists in project root

### Memory Too Large

1. Split into smaller entries
2. Store summary with references
3. Use code links instead of copying

### Project Init Failed

1. Ensure `uvx` is installed
2. Run manually: `cd <project> && uvx --from git+https://github.com/oraios/serena serena project create`
3. Check for write permissions in project directory

---

## References

- [ADR-002: Four-Tier Memory](../docs/architecture/adr/002-four-tier-memory.md)
- [ADR-003: Minimal MCP Footprint](../docs/architecture/adr/003-minimal-mcp-footprint.md)
- [Serena MCP Documentation](https://github.com/oraios/serena)
