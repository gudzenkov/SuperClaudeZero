---
name: research
description: Research external documentation, patterns, and best practices
argument-hint: <topic to research>
user-invocable: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - mcp__context7__resolve-library-id
  - mcp__context7__query-docs
---

# /research - External Research

Research documentation, patterns, and best practices from external sources.

## Purpose

Prevent hallucination by:
- Looking up official documentation
- Researching best practices
- Finding verified solutions
- Gathering external knowledge

## Inputs

- `$ARGUMENTS`: Topic to research
- `${PROJECT_NAME}`: Current project context

## Outputs

Research summary at `reports/research/YYYY-MM-DD-topic.md`

## Workflow

### 1. Define Research Question
From `$ARGUMENTS`:
- What specific information is needed?
- What would answer this question?
- What sources are authoritative?

### 2. Identify Sources
For the topic:
- Official documentation?
- Library/framework docs?
- Best practice guides?
- Community resources?

### 3. Search Official Docs First
Use Context7 MCP for library documentation:
```
1. resolve-library-id for library name
2. query-docs with specific question
```

### 4. Web Search if Needed
Use WebSearch for:
- Topics not covered by Context7
- Recent developments
- Community solutions
- Comparisons

### 5. Verify Information
Cross-reference findings:
- Multiple sources agree?
- Official docs support this?
- Is information current?

### 6. Synthesize Findings
Combine research into actionable summary:
- Key facts
- Best practices
- Code examples
- Caveats

### 7. Document
Create research report:

```markdown
# Research: [Topic]

**Date**: YYYY-MM-DD
**Query**: [Original question]
**Summary**: [Key takeaway]

---

## Question
[What we needed to find out]

## Sources Consulted

| Source | Type | Relevance |
|--------|------|-----------|
| [URL/Name] | Official Docs | High |
| [URL/Name] | Tutorial | Medium |

## Findings

### Key Points
1. [Important finding 1]
2. [Important finding 2]
3. [Important finding 3]

### Best Practices
- [Practice 1]
- [Practice 2]

### Code Examples
\`\`\`language
// Example from research
\`\`\`

### Caveats
- [Limitation or warning]

## Recommendations
Based on research:
1. [Recommendation 1]
2. [Recommendation 2]

## References
- [Source 1 with link]
- [Source 2 with link]
```

## Research Strategies

### Library/Framework Research
1. Use Context7 first (authoritative)
2. Check official docs site
3. Review GitHub issues/discussions
4. Search for tutorials

### Best Practice Research
1. Official style guides
2. Industry standards
3. Community consensus
4. Case studies

### Problem-Solving Research
1. Exact error message search
2. Stack Overflow (verify votes/dates)
3. GitHub issues
4. Official troubleshooting guides

### Comparative Research
1. Feature comparison
2. Performance benchmarks
3. Community adoption
4. Maintenance status

## Anti-Hallucination Rules

1. **Cite sources**: Always note where information came from
2. **Verify recency**: Check dates on information
3. **Cross-reference**: Multiple sources for important facts
4. **Admit uncertainty**: If unsure, say so
5. **Official first**: Prefer official docs over blogs

## Policy References

**Should-read** from `~/.claude/policy/RULES.md`:
- Tool Optimization - MCP tool selection priority

### Documentation Tool Selection

| Need | Tool | Priority |
|------|------|----------|
| Library/framework API docs | Context7 | 1st |
| GitHub repo understanding | DeepWiki | 2nd |
| User-provided URL | WebFetch | — |
| General discovery/current events | WebSearch | Last |

**Default flow**: Context7 → DeepWiki → WebSearch (only if others fail)
