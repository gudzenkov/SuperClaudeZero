# ADR-006: Policy Modularization

**Status**: Accepted
**Version**: 1.1
**Date**: 2026-01-25
**Context**: SuperClaudeZero v0 policy loading strategy

---

## Context

SuperClaudeZero defines operational policies in three files:

| File | Tokens | Purpose |
|------|--------|---------|
| `PRINCIPLES.md` | ~640 | Universal engineering philosophy |
| `RULES.md` | ~4,200 | Specific behavioral rules by area |
| `GUIDELINES.md` | ~740 | User-facing workflow guidance |

Currently these files are installed to `~/.claude/policy/` but **never loaded** - Claude Code only auto-loads `CLAUDE.md` files.

Loading all policies (~5,600 tokens) into every agent/skill wastes context, especially for agents that don't need implementation-specific rules (e.g., Business Analyst doesn't need Git workflow rules).

## Decision

**Reference-based policy loading with two tiers**:

### Tier 1: PRINCIPLES.md (Must-Read)
- Loaded via reference in global `~/.claude/CLAUDE.md`
- All agents and skills inherit engineering philosophy
- Universal: SOLID, DRY/KISS/YAGNI, decision frameworks, quality philosophy

### Tier 2: RULES.md Sections (Should-Read)
- Referenced from individual agent and skill definitions
- Agents/skills specify which sections apply to them
- Section-level granularity enables minimal context loading

### RULES.md Section Structure

| Section | Tokens | Relevant To |
|---------|--------|-------------|
| Rule Priority System | ~150 | All (header) |
| Agent Orchestration | ~500 | Orchestrator, All agents |
| Workflow Rules | ~350 | All agents |
| Planning Efficiency | ~180 | PM, Orchestrator |
| Implementation Completeness | ~200 | Developer |
| Scope Discipline | ~200 | Developer, BA |
| Code Organization | ~200 | Developer |
| Workspace Hygiene | ~200 | Developer, Deployer |
| Failure Investigation | ~240 | Validator, Developer |
| Professional Honesty | ~220 | Tech Writer, All |
| Git Workflow | ~240 | Developer, Deployer |
| Tool Optimization | ~400 | All agents |
| File Organization | ~240 | Developer, Tech Writer |
| Safety Rules | ~160 | Developer, Deployer |
| Temporal Awareness | ~200 | All agents |
| Quick Reference | ~800 | Developer |

### Agent -> Section Mapping

Per PRD FR1, SuperClaudeZero has 7 specialized agents plus orchestration:

| Agent | Skill | RULES Sections |
|-------|-------|----------------|
| Business Analyst | `/spec` | Agent Orchestration, Workflow Rules, Scope Discipline, Professional Honesty |
| Architect | `/design` | Agent Orchestration, Workflow Rules, Professional Honesty |
| Project Manager | `/plan` | Agent Orchestration, Workflow Rules, Planning Efficiency |
| Developer | `/implement` | Agent Orchestration, Workflow Rules, Implementation, Scope, Code Org, Git, Tools, Safety, File Org, Quick Ref |
| Validator | `/validate` | Agent Orchestration, Workflow Rules, Failure Investigation, Professional Honesty |
| Deployer | `/deploy` | Agent Orchestration, Workflow Rules, Safety Rules, Git Workflow, Workspace Hygiene |
| Tech Writer | `/document` | Agent Orchestration, Workflow Rules, Professional Honesty, File Organization |

The main orchestrator (`/orchestrate`) inherits all sections as it coordinates all agents.

### Skill -> Section Mapping

| Skill | Additional Sections |
|-------|---------------------|
| /spec | Scope Discipline |
| /design | Professional Honesty |
| /plan | Planning Efficiency |
| /implement | Implementation, Git, Safety |
| /validate | Failure Investigation |
| /deploy | Safety Rules |
| /document | File Organization, Professional Honesty |
| /reflexion | Agent Orchestration (tactical learning) |
| /reflect | Agent Orchestration (strategic learning) |
| /optimize | Agent Orchestration (meta-optimization) |
| /research | Tool Optimization (MCP selection) |
| /analyse | Failure Investigation |

## Rationale

### Why Reference-Based (Not Split Files)

1. **Simpler maintenance**: Single RULES.md to edit
2. **No loader mechanism needed**: References are human-readable
3. **Incremental adoption**: Can add actual loading later
4. **Self-documenting**: Each agent shows its applicable rules

### Why Section Granularity

1. **Token efficiency**: Developer needs ~2,400 tokens, Architect needs ~640
2. **Relevance**: Agents only see rules that apply to them
3. **Clarity**: Clear mapping of responsibilities

### Why Must-Read vs Should-Read

1. **PRINCIPLES**: Universal mindset, applies everywhere
2. **RULES**: Operational specifics, context-dependent
3. **GUIDELINES**: User-facing, not for agents

## Consequences

### Positive

1. **Reduced context**: 46-74% token savings per agent
2. **Clear ownership**: Each agent knows its rules
3. **Maintainable**: Single source of truth
4. **Extensible**: Easy to add new sections

### Negative

1. **Manual sync**: References must be updated when sections change
2. **No enforcement**: References are advisory, not loaded
3. **Learning curve**: Contributors must understand section mapping

### Mitigations

1. **Section anchors**: Use stable section names as anchors
2. **Future loading**: Can add loader mechanism in v1
3. **Documentation**: This ADR documents the mapping

## Implementation

### Phase 1: Add References (v0)

1. Add PRINCIPLES reference to global CLAUDE.md
2. Add `## Policy References` section to each agent
3. Add `## Policy References` section to relevant skills

### Phase 2: Align with PRD MCP Requirements (v0)

Per PRD, MCP dependencies are:

| Server | Purpose | Priority |
|--------|---------|----------|
| Serena | Session persistence, semantic memory, symbolic code operations | Required |
| Context7 | Documentation lookup, prevents hallucination | Required |
| DeepWiki | GitHub repository documentation | Required |
| Playwright | Browser automation for validation | Optional |

RULES.md `Tool Optimization` section includes:
- MCP Server Priority table aligned with PRD
- Documentation Tool Selection decision tree

### Phase 3: Loader Mechanism (v1)

Consider adding policy injection via:
- SessionStart hook reading referenced sections
- Agent template with `{{#each policies}}` expansion
- Or keep as human-readable references

## Token Impact

| Agent | Monolithic | With References | Savings |
|-------|------------|-----------------|---------|
| Business Analyst | 4,840 | 640 + refs | 87% |
| Architect | 4,840 | 640 + refs | 87% |
| Project Manager | 4,840 | 1,020 + refs | 79% |
| Developer | 4,840 | 2,400 + refs | 50% |
| Validator | 4,840 | 1,100 + refs | 77% |
| Deployer | 4,840 | 1,000 + refs | 79% |
| Tech Writer | 4,840 | 1,100 + refs | 77% |

## Alternatives Considered

### Alternative 1: Split into Multiple Files

Create `rules/implementation.md`, `rules/git.md`, etc.

**Rejected**:
- More files to maintain
- Requires loader mechanism
- Harder to see full picture

### Alternative 2: Inject All via Hook

SessionStart hook cats all policy files.

**Rejected**:
- 5,600 tokens on every session
- No agent-specific filtering
- Heavy context overhead

### Alternative 3: No References

Keep policies as documentation only.

**Rejected**:
- Agents don't know which rules apply
- No path to future loading
- Disconnected from implementation

## Related Decisions

- **ADR-003**: Minimal MCP Footprint (Context7, DeepWiki, Serena)
- **ADR-004**: Skill-Agent Invocation Paths
- **PRD FR1**: Agent System (7 agents)
- **PRD FR2**: Skill Interface (14 skills)
- **PRD MCP Dependencies**: Serena, Context7, DeepWiki (Required), Playwright (Optional)

## References

- [PRINCIPLES.md](../../../global/policy/PRINCIPLES.md)
- [RULES.md](../../../global/policy/RULES.md)
- [GUIDELINES.md](../../../global/policy/GUIDELINES.md)
- [PRD.md](../PRD.md)
