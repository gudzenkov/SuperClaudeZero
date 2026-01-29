# ADR-002: Four-Tier Memory System

**Status**: Accepted
**Version**: 1.0
**Date**: 2026-01-23
**Context**: SuperClaudeZero v0 memory architecture

---

## Context

SuperClaudeZero needs to manage different types of information with varying:
- **Persistence**: How long data lives
- **Access patterns**: Who reads/writes and when
- **Structure**: Schema requirements
- **Volume**: Amount of data generated

Previous approaches (SuperClaude v4) mixed all memory into single storage, causing:
- Noise in semantic searches
- Difficulty pruning transient data
- Unclear data lifecycle

## Decision

**Implement Four-Tier Memory Architecture**:

| Tier | Storage | Lifetime | Purpose |
|------|---------|----------|---------|
| **Session** | Claude JSONL | Session | Transcript history |
| **Semantic** | Serena memories | Persistent | Project knowledge |
| **Reflexion** | Serena memories | Persistent | Error patterns |
| **Transient** | Serena memories | Ephemeral | Validation records |

### Tier Specifications

#### Tier 1: Session Memory

```
Storage: ~/.claude/projects/<project-slug>/sessions/
Format: JSONL (Claude native, automatic)
Access: CLAUDE_SESSION_ID variable
Lifetime: Session duration (auto-cleanup)
```

**Content**: Full conversation transcript, tool calls, responses.

**Usage**: `/reflect` can reference via `CLAUDE_SESSION_ID` for meta-learning.

#### Tier 2: Semantic Memory

```
Storage: Serena project memories
Format: Markdown files
Access: write_memory, read_memory, list_memories
Lifetime: Persistent (manual deletion)
Load: AUTO-LOAD at agent init
```

**Content**:
- Project architecture decisions
- Domain knowledge
- Best practices
- Integration patterns
- Code conventions

**Naming Convention**: `knowledge/{topic}.md`

**Agent Init**: Auto-loaded into agent context at spawn. Provides project-specific knowledge without explicit queries.

#### Tier 3: Reflexion Memory

```
Storage: Serena project memories
Format: Structured YAML in markdown
Access: /reflexion skill
Lifetime: Persistent (promotes to guidelines)
Load: QUERY ad-hoc when encountering errors/issues
```

**Content**:
```yaml
# reflexion/{date}-{slug}.md
---
date: 2026-01-23
agent: Developer
task: Implement OAuth flow
severity: high
---

## Known Issue
[What went wrong]

## Root Cause
[Why it happened]

## Solution
[What fixed it]

## Prevention
[How to avoid in future]
```

**Agent Init**: NOT auto-loaded. Queried ad-hoc when agent encounters errors or issues matching known patterns.

**Query Pattern**: When agent hits an error → query `reflexion/*` for matching known_issue → apply documented solution/prevention.

#### Tier 4: Transient Memory

```
Storage: Serena project memories
Format: Structured markdown
Access: /validate, /reflect skills
Lifetime: Ephemeral (prunable)
Load: NOT loaded at agent init
```

**Content**:
- Validation records
- Reflection records
- Intermediate artifacts

**Naming Convention**: `{type}/{date}-{session-id}.md`

**Pruning**: Can be deleted after N days or N entries.

**Agent Init**: NOT loaded. Only accessed by /reflect and /optimize for analysis.

### Agent Init Memory Loading Summary

| Tier | Load Pattern | When | Content |
|------|--------------|------|---------|
| **Session** | N/A | Automatic | Claude manages |
| **Semantic** | **AUTO-LOAD** | At agent spawn | Project knowledge, patterns, decisions, conventions |
| **Reflexion** | **QUERY AD-HOC** | On error/issue | Known issues, causes, solutions, prevention |
| **Transient** | Not loaded | Never | Ephemeral validation/reflection records |

## Rationale

### Separation of Concerns

| Data Type | Why Separate Tier? |
|-----------|-------------------|
| Session | Already managed by Claude, high volume |
| Semantic | Long-term value, manually curated |
| Reflexion | Structured, queryable, reusable |
| Transient | High volume, low long-term value |

### Query Efficiency

Separating tiers allows targeted queries:
- "Find past errors with authentication" → Reflexion tier only
- "What do we know about the API design?" → Semantic tier only
- "What validations ran today?" → Transient tier only

### Storage Optimization

```
Session:     ~10MB per session (auto-cleaned)
Semantic:    ~100KB total (grows slowly)
Reflexion:   ~500KB total (10-50 entries)
Transient:   ~1MB total (pruned weekly)
```

## Consequences

### Positive

1. **Clear lifecycle**: Each tier has defined persistence rules
2. **Efficient queries**: Target specific tier for faster results
3. **Easy pruning**: Transient tier can be cleaned without affecting knowledge
4. **Structured learning**: Reflexion tier builds queryable error database

### Negative

1. **Serena dependency**: All non-session tiers require Serena MCP
2. **Namespace management**: Must maintain consistent naming conventions
3. **Migration**: Moving data between tiers requires explicit action

### Mitigations

1. **Serena required**: Document as hard dependency in installation
2. **Naming conventions**: Enforce in skill implementations
3. **Promotion path**: `/reflect` + `/optimize` can promote transient → semantic

## Implementation Details

### Directory Structure (Serena)

```
.serena/
├── knowledge/              # Tier 2: Semantic
│   ├── architecture.md
│   ├── api-patterns.md
│   └── domain-model.md
├── reflexion/              # Tier 3: Reflexion
│   ├── 2026-01-20-auth-error.md
│   └── 2026-01-22-deploy-failure.md
├── validation/             # Tier 4: Transient
│   ├── 2026-01-23-abc123.md
│   └── 2026-01-23-def456.md
└── reflection/             # Tier 4: Transient
    └── 2026-01-23-session-summary.md
```

### Skill Access Patterns

| Skill | Reads | Writes |
|-------|-------|--------|
| `/spec` | Semantic | - |
| `/design` | Semantic, Reflexion | - |
| `/implement` | Reflexion | - |
| `/validate` | - | Transient |
| `/reflexion` | - | Reflexion |
| `/reflect` | Session, Transient | Transient |
| `/optimize` | All tiers | Semantic |

## Alternatives Considered

### Alternative 1: Single Flat Storage

All memories in one Serena namespace.

**Rejected**:
- Noise in searches
- Difficult to prune
- No clear lifecycle

### Alternative 2: File-Based Memory

Use project files instead of Serena.

**Rejected**:
- Pollutes git history
- No semantic search
- Harder to query programmatically

### Alternative 3: External Database

Use SQLite or similar for structured storage.

**Rejected**:
- Additional dependency
- Complexity for v0
- Serena already provides needed capabilities

## Related Decisions

- **ADR-001**: Hook Reminder Pattern (triggers reflexion writes)
- **ADR-003**: Minimal MCP Footprint (Serena as memory backend)

## References

- [Serena MCP Documentation](https://github.com/oraios/serena)
- [PRD.md FR5: Memory System](../PRD.md#fr5-memory-system)
