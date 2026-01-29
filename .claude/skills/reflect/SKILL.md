---
name: reflect
description: Capture session-level learnings, patterns, and insights for meta-improvement
argument-hint: [optional focus area]
user-invocable: true
allowed-tools:
  - Read
  - Grep
  - Glob
---

# /reflect - Session Meta-Learning

Capture session-level insights for continuous improvement.

## Purpose

Analyze the current session to:
- Document lessons learned
- Identify effective patterns
- Note blockers and their resolutions
- Suggest workflow improvements
- Enable cross-session learning

## Inputs

- `$ARGUMENTS`: Optional focus area for reflection
- `${PROJECT_NAME}`: Current project context
- `${CLAUDE_SESSION_ID}`: Session identifier
- Current conversation history and outcomes

## Outputs

Reflection record stored in Serena project memory under `reflect/` namespace.

## Workflow

### 1. Review Session
Analyze what happened in this session:
- What tasks were attempted?
- What was accomplished?
- What challenges arose?
- How were they resolved?

### 2. Identify Patterns

**What Worked Well**:
- Effective approaches
- Useful tools or techniques
- Successful collaboration patterns

**What Could Improve**:
- Inefficient paths taken
- Missing information that caused delays
- Communication gaps

### 3. Extract Lessons
Generalizable insights:
- Workflow improvements
- Better tool usage
- Knowledge gaps to address
- Process optimizations

### 4. Note Blockers
If work is incomplete:
- What blocked progress?
- What's needed to continue?
- Suggested next steps

### 5. Suggest Optimizations
Based on session experience:
- Agent instruction improvements
- Skill enhancements
- Workflow modifications
- Tool recommendations

### 6. Store Reflection
Create a reflection record with the schema below.

## Reflection Schema

```yaml
# reflect/YYYY-MM-DD-session-summary.md
---
date: YYYY-MM-DD
session_id: ${CLAUDE_SESSION_ID}
project: ${PROJECT_NAME}
duration_estimate: [short | medium | long]
completion: [full | partial | blocked]
---

## Session Summary
[Brief overview of what was done]

## Tasks Completed
- [x] [Task 1]
- [x] [Task 2]
- [ ] [Task 3 - incomplete]

## Lessons Learned

### What Worked
- [Effective approach 1]
- [Useful technique 2]

### What Could Improve
- [Inefficiency observed]
- [Better approach identified]

## Patterns Identified
- [Recurring pattern worth noting]
- [Anti-pattern to avoid]

## Blockers Encountered
| Blocker | Resolution | Time Impact |
|---------|------------|-------------|
| [Description] | [How resolved] | [Low/Medium/High] |

## Suggestions for Improvement

### Workflow
- [Workflow suggestion]

### Agent Instructions
- [Agent improvement idea]

### Skills
- [Skill enhancement idea]

## Next Steps
If session is incomplete:
1. [Next action 1]
2. [Next action 2]

## Related Reflexions
- [Link to related error learnings]
```

## Example

```yaml
---
date: 2026-01-24
session_id: abc123
project: super-claude-zero
duration_estimate: long
completion: partial
---

## Session Summary
Implemented core agents and skills for SuperClaudeZero v0. Created hook scripts, agent definitions, and skill files.

## Tasks Completed
- [x] Hook scripts (inject-context, remind-validate, remind-reflexion, remind-reflect)
- [x] Core agents (business-analyst, architect, project-manager, developer)
- [x] Agent-backed skills (spec, design, plan, implement)
- [ ] Utility skills (reflexion, reflect)
- [ ] Orchestrate skill
- [ ] Settings and installer

## Lessons Learned

### What Worked
- Reading ARCHITECTURE.md thoroughly before implementing provided clear guidance
- Creating all hook scripts in parallel saved time
- Following the existing pattern from BACKLOG.md task details ensured consistency

### What Could Improve
- Could have used Task tool to parallelize agent creation
- Should check for existing templates before writing new files

## Patterns Identified
- Agent definitions follow consistent structure: frontmatter → role description → boundaries → process → output format
- Skills reference agents via `context: fork` and `agent:` for injection

## Blockers Encountered
| Blocker | Resolution | Time Impact |
|---------|------------|-------------|
| None significant | - | - |

## Suggestions for Improvement

### Workflow
- Consider generating all agents from a template to ensure consistency

### Agent Instructions
- Add explicit examples in skill files for common use cases

## Next Steps
1. Complete utility skills (reflexion, reflect)
2. Implement orchestrate skill
3. Create settings.json files
4. Build install.sh
```

## Validation Checklist
- [ ] Session summary is accurate
- [ ] Tasks status correctly reflects completion
- [ ] Lessons are actionable
- [ ] Suggestions are specific and implementable
- [ ] Next steps are clear if incomplete
