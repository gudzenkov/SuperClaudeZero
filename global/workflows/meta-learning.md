# Meta-Learning Workflow

**Version**: 0.1.0
**Purpose**: Session learning and system optimization

---

## Workflow Overview

The meta-learning workflow captures session insights and proposes system improvements.

```
Session Work → /reflect → /optimize → User Approval → Rollout
```

---

## Workflow Triggers

### Explicit Trigger
User invokes `/reflect` or `/optimize` directly.

### Suggested Trigger
Stop hook (`remind-reflect.sh`) suggests reflection at session end.

### Automatic Trigger (Future)
Pattern detection triggers optimization proposals.

---

## Phases

### Phase 1: Session Reflection (`/reflect`)

Capture session-level learnings.

```
┌─────────────────────────────────────────┐
│              /reflect                    │
├─────────────────────────────────────────┤
│ Input:  Current session context          │
│         ${CLAUDE_SESSION_ID}             │
│                                          │
│ Process:                                 │
│   1. Review session activities           │
│   2. Identify what worked well           │
│   3. Note what could improve             │
│   4. Extract patterns                    │
│   5. Document blockers                   │
│                                          │
│ Output: Reflection record (Serena)       │
│         - Lessons learned                │
│         - Patterns identified            │
│         - Improvement suggestions        │
└─────────────────────────────────────────┘
```

**Reflection Record Schema**:
```yaml
---
date: YYYY-MM-DD
session_id: ${CLAUDE_SESSION_ID}
project: ${PROJECT_NAME}
completion: full | partial | blocked
---

## Summary
[What was accomplished]

## What Worked
- [Effective approach]

## What Could Improve
- [Inefficiency or gap]

## Patterns
- [Recurring pattern worth noting]

## Suggestions
- [Specific improvement idea]
```

### Phase 2: System Optimization (`/optimize`)

Propose improvements to Orchestrator components.

```
┌─────────────────────────────────────────┐
│              /optimize                   │
├─────────────────────────────────────────┤
│ Input:  Reflection records               │
│         Reflexion records                │
│         Current agent/skill definitions  │
│                                          │
│ Process:                                 │
│   1. Analyze reflection patterns         │
│   2. Review reflexion prevention items   │
│   3. Identify improvement opportunities  │
│   4. Draft proposed changes              │
│   5. Create optimization plan            │
│                                          │
│ Output: Meta-Opt Plan file               │
│         - Proposed changes               │
│         - Rationale                      │
│         - Risk assessment                │
└─────────────────────────────────────────┘
```

**Optimization Plan Schema**:
```yaml
---
date: YYYY-MM-DD
type: meta-optimization
status: proposed | approved | applied | rejected
---

## Optimization Summary
[What improvements are proposed]

## Analysis

### Reflection Patterns
- [Pattern from multiple sessions]
- [Recurring issue]

### Reflexion Prevention Items
- [Error prevention that could be systematized]

## Proposed Changes

### Change 1: [Component]
**Current**: [What exists now]
**Proposed**: [What should change]
**Rationale**: [Why this improves things]
**Risk**: Low | Medium | High

### Change 2: [Component]
...

## Implementation
1. [Step to apply changes]
2. [Verification step]

## Rollback
[How to undo if needed]
```

### Phase 3: User Approval

**Critical**: No changes applied without explicit user approval.

```
┌─────────────────────────────────────────┐
│           User Approval Gate             │
├─────────────────────────────────────────┤
│                                          │
│ Present optimization plan to user:       │
│                                          │
│ "Based on session analysis, I propose:   │
│  1. [Change 1 summary]                   │
│  2. [Change 2 summary]                   │
│                                          │
│ Apply these optimizations?"              │
│                                          │
│ Options:                                 │
│   - Yes, apply all                       │
│   - Apply selected (1, 2, ...)           │
│   - No, reject                           │
│   - Modify first                         │
│                                          │
└─────────────────────────────────────────┘
```

### Phase 4: Rollout

Apply approved changes.

```
┌─────────────────────────────────────────┐
│              Rollout                     │
├─────────────────────────────────────────┤
│                                          │
│ For each approved change:                │
│   1. Backup current version              │
│   2. Apply modification                  │
│   3. Verify syntax/structure             │
│   4. Log change with timestamp           │
│                                          │
│ Output:                                  │
│   - Modified files                       │
│   - Backup references                    │
│   - Change log entry                     │
│                                          │
└─────────────────────────────────────────┘
```

---

## Optimization Targets

What can be optimized:

| Target | Location | Example Change |
|--------|----------|----------------|
| Agent instructions | `.claude/agents/*.md` | Add clarifying guidance |
| Skill workflows | `.claude/skills/*/SKILL.md` | Improve process steps |
| Hook prompts | `.claude/hooks/scripts/*.sh` | Refine reminder text |
| Rules | `global/policy/RULES.md` | Add new rule from pattern |
| Workflow templates | `global/workflows/*.md` | Adjust decision criteria |

---

## Safety Measures

### Backup Before Change
Always create backup before modifying:
```bash
cp file.md file.md.backup.$(date +%Y%m%d%H%M%S)
```

### Change Logging
Record all meta-optimizations:
```
~/.claude/logs/meta-opt.log
YYYY-MM-DD HH:MM:SS | [component] | [change summary] | [status]
```

### Rollback Capability
Every optimization must include rollback instructions.

### Approval Gate
No automatic application - user must explicitly approve.

---

## Example Flow

```
Session: Implementing OAuth feature
├── Encountered: Token refresh edge case
├── Resolved: Added explicit 401 handling
└── /reflexion captured the learning

Session End:
├── remind-reflect.sh suggests /reflect
└── User invokes /reflect

/reflect:
├── Reviews session
├── Notes OAuth pattern
├── Suggests: "Add auth error handling to Developer agent instructions"
└── Stores reflection record

Later: User invokes /optimize

/optimize:
├── Reads reflection records
├── Reads reflexion records
├── Finds pattern: Auth errors recurring
├── Proposes: Add auth checklist to Developer agent
└── Creates optimization plan

User Review:
├── Reviews proposed change
├── Approves modification
└── Change applied to developer.md

Result: Future sessions benefit from learned pattern
```

---

## Metrics (Future)

Track optimization effectiveness:
- Sessions between similar errors
- Time to resolution trends
- User approval rate
- Rollback frequency
