# AgentOrchestrator User Guidelines

Concise guidance for users working with Orchestrator workflows.

---

## Workflow Selection

| Scenario | Approach |
|----------|----------|
| New product/complex system | `/orchestrate` → guided full workflow |
| Single skill needed | `/spec`, `/design`, `/plan`, `/implement` directly |
| Quick change, known scope | `/plan` → `/implement` |
| Investigation/debugging | `/analyse` |
| Documentation lookup | `/research` |

## Documentation Lookup

| Need | Tool | Example |
|------|------|---------|
| Library API docs | Context7 | "How to use Pydantic validators" |
| Repo understanding | DeepWiki | "How does FastAPI handle middleware" |
| Specific URL | WebFetch | User-provided doc link |
| General search | WebSearch | "Best auth practices 2026" |

**Default**: `/research` skill uses Context7 first, falls back to DeepWiki/WebSearch.

## Skill Invocation

```bash
# Guided orchestration (recommended for new work)
/orchestrate Build a CLI tool for managing tasks

# Direct skill invocation
/spec Build a task management CLI       # → PRD
/design                                  # → ARCHITECTURE
/plan                                    # → ROADMAP, BACKLOG
/implement T-001                         # → Code

# Utility skills
/analyse Why is authentication failing?  # Investigation
/research OAuth2 best practices          # Documentation lookup
/reflect                                 # Session learning capture
```

## Agent Self-Validation

Agents automatically self-validate via SubagentStop hooks:
- Acceptance criteria checked
- Artifact schema validated
- `/reflexion` prompted for error capture

**You don't need to remind agents to validate** - hooks handle this.

## Session Learning

- Use `/reflect` at session end to persist insights
- Use `/reflexion` after errors for root cause capture
- Learnings stored in Serena memory for future sessions

## Documentation Updates

After significant changes, use `/document` to:
1. Analyze session changes (git + unstaged)
2. Classify by impact area
3. Update docs in correct propagation order

## Task Hierarchy

Follow the standard decomposition:
```
Milestone → Phase → Epic → Task
(Release)   (Stage)  (Feature) (Atomic work)
```

Each **Task** should be:
- Atomic (single commit)
- Testable (clear acceptance)
- Traceable (refs requirement)

## Best Practices

1. **Start with context** - Let SessionStart hooks inject project context
2. **Use orchestration first** - `/orchestrate` determines appropriate workflow depth
3. **Trust agent boundaries** - Agents know what they will/won't do
4. **Capture learnings** - `/reflect` after sessions, `/reflexion` after errors
5. **Keep artifacts current** - Use `/document` after significant changes

## Project Setup

For new projects:
```bash
# Install Orchestrator to your project
./install.sh --project /path/to/project

# Creates:
# - .claude/settings.json (project hooks)
# - .serena/project.yml (memory config)
# - docs/knowledge/ (project knowledge base)
# - reports/ (skill outputs)
```

## Local Customization

Add project-local policies in `docs/policy/`:
```
docs/policy/
├── PRINCIPLES.md   # Project-specific principles
├── RULES.md        # Project-specific rules
└── GUIDELINES.md   # Project-specific user guidance
```

These supplement (not replace) global policies in `~/.claude/policy/`.
