---
name: optimize
description: Propose improvements to Orchestrator agents, skills, and workflows based on session learnings
argument-hint: [focus area]
user-invocable: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - AskUserQuestion
---

# /optimize - System Optimization

Propose improvements to Orchestrator components based on accumulated learnings.

## Purpose

Analyze session patterns and propose:
- Agent instruction refinements
- Skill workflow improvements
- Hook prompt adjustments
- Rule additions or modifications

## Inputs

- `$ARGUMENTS`: Optional focus area for optimization
- Reflection records from Serena memory
- Reflexion records from Serena memory
- Current agent/skill/hook definitions
- `${PROJECT_NAME}`: Current project context

## Outputs

Meta-Optimization Plan (requires user approval before application).

## Workflow

### 1. Gather Evidence
Load learning artifacts:
- Recent reflection records (`/reflect` outputs)
- Reflexion records (`/reflexion` outputs)
- Session patterns if available

### 2. Identify Patterns
Analyze for recurring themes:
- Repeated errors across sessions
- Common blockers or friction points
- Frequently needed clarifications
- Successful approaches worth standardizing

### 3. Map to Components
For each pattern, identify relevant Orchestrator component:
- Agent instructions → `.claude/agents/*.md`
- Skill workflows → `.claude/skills/*/SKILL.md`
- Hook prompts → `.claude/hooks/scripts/*.sh`
- Rules → `global/policy/RULES.md`
- Workflows → `global/workflows/*.md`

### 4. Draft Proposals
For each improvement:
```markdown
### Proposal: [Title]

**Target**: [Component path]
**Pattern**: [What triggered this]
**Current**: [Existing content]
**Proposed**: [New content]
**Rationale**: [Why this improves things]
**Risk**: Low | Medium | High
```

### 5. Create Optimization Plan
Compile all proposals:
```yaml
---
date: YYYY-MM-DD
type: meta-optimization
status: proposed
---

## Summary
[Overview of proposed changes]

## Evidence
- [Reflection/reflexion references]

## Proposals
[List of proposals]

## Implementation Order
1. [First change]
2. [Second change]

## Rollback Plan
[How to undo]
```

### 6. Request Approval
Present plan to user via `AskUserQuestion`:
- Summary of changes
- Risk assessment
- Option to approve all, select some, or reject

### 7. Apply (If Approved)
Only after explicit user approval:
- Backup current versions
- Apply changes
- Log modifications
- Verify syntax

## Optimization Categories

### Agent Optimization
- Add missing guidance
- Clarify boundaries
- Improve tool recommendations
- Add common patterns

### Skill Optimization
- Streamline workflows
- Add missing steps
- Improve templates
- Clarify inputs/outputs

### Hook Optimization
- Refine reminder text
- Add/remove checklist items
- Adjust timing

### Rule Optimization
- Add rules for recurring issues
- Clarify existing rules
- Add anti-patterns

## Safety Constraints

1. **User Approval Required**: No automatic changes
2. **Backup Before Modify**: Always create backup
3. **Incremental Changes**: Small, focused modifications
4. **Reversible**: Clear rollback path
5. **Logged**: All changes recorded

## Anti-Patterns to Avoid

- Over-optimization (changing what works)
- Premature generalization (one instance ≠ pattern)
- Complexity creep (simpler is better)
- Breaking existing workflows

## Validation

Before proposing:
- [ ] Pattern appears in multiple sessions
- [ ] Change is specific and actionable
- [ ] Risk is assessed honestly
- [ ] Rollback is possible
- [ ] User approval mechanism in place
