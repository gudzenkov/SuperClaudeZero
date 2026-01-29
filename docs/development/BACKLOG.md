# SuperClaudeZero Backlog

**Version**: 0.1.0
**Updated**: 2026-01-24 (48/50 tasks done)
**Scope**: v0 Milestone

---

## Tasks

| ID | Milestone | Phase | Epic | Task | User Story | Priority | Status |
|----|-----------|-------|------|------|------------|----------|:------:|
| T-001 | v0 | Initial | Hook System | inject-context.sh | FR5.4, FR5.6 | P0 | ✅ |
| T-002 | v0 | Initial | Hook System | remind-validate.sh | FR3.1, FR6 | P0 | ✅ |
| T-003 | v0 | Initial | Hook System | remind-reflexion.sh | FR3.1, FR7.1 | P0 | ✅ |
| T-004 | v0 | Initial | Hook System | remind-reflect.sh | FR3.2, FR8.1 | P0 | ✅ |
| T-005 | v0 | Initial | Hook System | checkpoint-session.sh | FR3.3, FR5.3.1 | P1 | ✅ |
| T-006 | v0 | Initial | Core Agents | business-analyst.md | FR1, US1 | P0 | ✅ |
| T-007 | v0 | Initial | Core Agents | architect.md | FR1, US2 | P0 | ✅ |
| T-008 | v0 | Initial | Core Agents | project-manager.md | FR1, US3 | P0 | ✅ |
| T-009 | v0 | Initial | Core Agents | developer.md | FR1 | P0 | ✅ |
| T-010 | v0 | Initial | Support Agents | validator.md | FR1 | P1 | ✅ |
| T-011 | v0 | Initial | Support Agents | deployer.md | FR1 | P1 | ✅ |
| T-012 | v0 | Initial | Support Agents | tech-writer.md | FR1 | P1 | ✅ |
| T-013 | v0 | Initial | Agent-Backed Skills | spec/SKILL.md | FR2, US1 | P0 | ✅ |
| T-014 | v0 | Initial | Agent-Backed Skills | design/SKILL.md | FR2, US2 | P0 | ✅ |
| T-015 | v0 | Initial | Agent-Backed Skills | plan/SKILL.md | FR2, US3 | P0 | ✅ |
| T-016 | v0 | Initial | Agent-Backed Skills | implement/SKILL.md | FR2 | P0 | ✅ |
| T-017 | v0 | Initial | Agent-Backed Skills | validate/SKILL.md | FR2, FR6 | P1 | ✅ |
| T-018 | v0 | Initial | Agent-Backed Skills | deploy/SKILL.md | FR2 | P1 | ✅ |
| T-019 | v0 | Initial | Agent-Backed Skills | document/SKILL.md | FR2 | P1 | ✅ |
| T-020 | v0 | Initial | Utility Skills | reflexion/SKILL.md | FR2, FR7 | P0 | ✅ |
| T-021 | v0 | Initial | Utility Skills | reflect/SKILL.md | FR2, FR8.1 | P0 | ✅ |
| T-022 | v0 | Initial | Utility Skills | optimize/SKILL.md | FR2, FR8.2 | P2 | ✅ |
| T-023 | v0 | Initial | Utility Skills | analyse/SKILL.md | FR2, US6 | P1 | ✅ |
| T-024 | v0 | Initial | Utility Skills | research/SKILL.md | FR2 | P1 | ✅ |
| T-025 | v0 | Initial | Utility Skills | distill/SKILL.md | FR2 | P2 | ✅ |
| T-026 | v0 | Initial | Orchestration | orchestrate/SKILL.md | FR2, FR4, US4 | P0 | ✅ |
| T-027 | v0 | Initial | Policy | RULES.md | PRD | P1 | ✅ |
| T-028 | v0 | Initial | Policy | PRINCIPLES.md | PRD | P1 | ✅ |
| T-029 | v0 | Initial | Workflows | SWE.md | FR4 | P0 | ✅ |
| T-030 | v0 | Initial | Workflows | meta-learning.md | FR4, FR8 | P1 | ✅ |
| T-031 | v0 | Initial | Templates | prd.md | FR4.4 | P1 | ✅ |
| T-032 | v0 | Initial | Templates | architecture.md | FR4.4 | P1 | ✅ |
| T-033 | v0 | Initial | Templates | adr.md | FR4.4 | P1 | ✅ |
| T-034 | v0 | Initial | Templates | roadmap.md | FR4.4 | P1 | ✅ |
| T-047 | v0 | Initial | Templates | backlog.md | FR4.4 | P1 | ✅ |
| T-048 | v0 | Initial | Templates | issues.md | FR4.4 | P2 | ✅ |
| T-049 | v0 | Initial | Templates | vision.md | FR4.4 | P2 | ✅ |
| T-050 | v0 | Initial | Templates | blueprint.md | FR4.4 | P2 | ✅ |
| T-035 | v0 | Initial | Settings & Installer | global/settings.json | FR3 | P0 | ✅ |
| T-036 | v0 | Initial | Settings & Installer | project/settings.json | PRD | P1 | ✅ |
| T-037 | v0 | Initial | Settings & Installer | .claude/settings.json | PRD | P0 | ✅ |
| T-038 | v0 | Initial | Settings & Installer | install.sh | PRD, NFR3 | P0 | ✅ |
| T-039 | v0 | Validation | Integration | E2E /orchestrate test | US4 | P0 | ⏳ |
| T-040 | v0 | Validation | Integration | Dogfood SCZ docs | PRD | P1 | ✅ |
| T-041 | v0 | Validation | Integration | Update README.md | PRD | P0 | ✅ |
| T-042 | v0 | Initial | Policy | DESIGN-PRINCIPLES.md | PRD | P1 | ✅ |
| T-043 | v0 | Initial | Hooks | .claude/hooks/README.md | PRD | P2 | ✅ |
| T-044 | v0 | Initial | Project Templates | project/ structure | PRD | P1 | ✅ |
| T-045 | v0 | Initial | Memory | .serena/README.md | PRD | P2 | ✅ |
| T-046 | v0 | Initial | Settings | Fix $schema in settings.json | PRD | P0 | ✅ |

---

## Task Details

### T-001: inject-context.sh
**AC**:
- Injects `PROJECT_NAME` derived from cwd (e.g., `/workspace/super-claude` → `super-claude`)
- Injects `CLAUDE_SESSION_ID` for skill reference
- Non-blocking execution
- Output format compatible with Claude Code SessionStart hook

---

### T-002: remind-validate.sh
**AC**:
- Outputs `<system-reminder>` with validation checklist
- Checklist includes: acceptance criteria, artifact schema, evidence check, tests
- Blocking execution (SubagentStop)
- Agent decides whether to act on reminder

---

### T-003: remind-reflexion.sh
**AC**:
- Outputs `<system-reminder>` prompting `/reflexion` if errors encountered
- Blocking execution (SubagentStop)
- Only reminds; agent decides whether to invoke skill

---

### T-004: remind-reflect.sh
**AC**:
- Outputs `<system-reminder>` prompting `/reflect` for session meta-learning
- Blocking execution (Stop event)
- Includes orchestrator checklist items

---

### T-005: checkpoint-session.sh
**AC**:
- Non-blocking execution (SessionEnd)
- Logs session end timestamp
- Optional: captures session summary for external analysis
- Does not invoke skills (SessionEnd cannot block)

---

### T-006: business-analyst.md
**AC**:
- Valid agent frontmatter (name, description, skills, hooks)
- `skills:` includes `spec`
- `hooks.SubagentStop` references remind-validate.sh, remind-reflexion.sh
- Boundaries defined (Will: PRDs, criteria / Won't: code, architecture)
- Tools: Read, Grep, Glob, WebSearch

---

### T-007: architect.md
**AC**:
- Valid agent frontmatter
- `skills:` includes `design`
- `hooks.SubagentStop` configured
- Boundaries: Will (architecture, ADRs) / Won't (implementation)
- Tools: Read, Grep, Glob, WebSearch

---

### T-008: project-manager.md
**AC**:
- Valid agent frontmatter
- `skills:` includes `plan`
- `hooks.SubagentStop` configured
- Boundaries: Will (planning, decomposition) / Won't (implementation)
- Tools: Read, Write, TaskCreate, TaskUpdate

---

### T-009: developer.md
**AC**:
- Valid agent frontmatter
- `skills:` includes `implement`
- `hooks.SubagentStop` configured
- Boundaries: Will (code, tests) / Won't (design decisions)
- Tools: Read, Write, Edit, Bash, Task

---

### T-010: validator.md
**AC**:
- Valid agent frontmatter
- `skills:` includes `validate`
- `hooks.SubagentStop` configured
- Boundaries: Will (testing, validation) / Won't (fixes)
- Tools: Read, Grep, Bash

---

### T-011: deployer.md
**AC**:
- Valid agent frontmatter
- `skills:` includes `deploy`
- `hooks.SubagentStop` configured
- `permissionMode: plan` (requires approval)
- Boundaries: Will (build, deploy) / Won't (code changes)
- Tools: Read, Write, Bash

---

### T-012: tech-writer.md
**AC**:
- Valid agent frontmatter
- `skills:` includes `document`
- `hooks.SubagentStop` configured
- Boundaries: Will (docs, guides) / Won't (code)
- Tools: Read, Write, Grep

---

### T-013: spec/SKILL.md
**AC**:
- Valid skill frontmatter with `context: fork`, `agent: business-analyst`
- Inputs: `$ARGUMENTS` (idea description)
- Outputs: PRD at `docs/architecture/PRD.md`
- Workflow: clarifying questions → goals → requirements → user stories → AC
- Template reference: `global/templates/prd.md`

---

### T-014: design/SKILL.md
**AC**:
- Valid skill frontmatter with `context: fork`, `agent: architect`
- Inputs: PRD from context or `$ARGUMENTS`
- Outputs: Architecture at `docs/architecture/ARCHITECTURE.md`, ADRs at `docs/architecture/adr/`
- Workflow: read PRD → components → constraints → risks → trade-offs → ADRs
- Template references: architecture.md, adr.md

---

### T-015: plan/SKILL.md
**AC**:
- Valid skill frontmatter with `context: fork`, `agent: project-manager`
- Inputs: Architecture from context or `$ARGUMENTS`
- Outputs: Updates to `docs/objectives/ROADMAP.md`, `docs/development/BACKLOG.md`
- Workflow: read architecture → decompose → prioritize → dependencies
- Follows ADR-005 hierarchy (Milestone → Phase → Epic → Task)
- Template references: roadmap.md, backlog.md

---

### T-016: implement/SKILL.md
**AC**:
- Valid skill frontmatter with `context: fork`, `agent: developer`
- Inputs: Task from backlog or `$ARGUMENTS`
- Outputs: Code, tests in source files
- Workflow: read task → implement → test → commit message suggestion

---

### T-017: validate/SKILL.md
**AC**:
- Valid skill frontmatter with `context: fork`, `agent: validator`
- Inputs: Code/artifact from context or `$ARGUMENTS`
- Outputs: Validation report to Serena memory
- Workflow: read AC → run tests → check schema → report

---

### T-018: deploy/SKILL.md
**AC**:
- Valid skill frontmatter with `context: fork`, `agent: deployer`
- Inputs: Build target or `$ARGUMENTS`
- Outputs: Deployment artifacts
- Workflow: build → deploy → verify

---

### T-019: document/SKILL.md
**AC**:
- Valid skill frontmatter with `context: fork`, `agent: tech-writer`
- Inputs: Component/feature or `$ARGUMENTS`
- Outputs: Documentation at `docs/`, `README.md`
- Workflow: read code → extract API → write docs

---

### T-020: reflexion/SKILL.md
**AC**:
- Valid skill frontmatter (inline, no agent delegation)
- Captures: known_issues, cause, solution, prevention
- Outputs: Serena project memory (reflexion record)
- High signal/noise threshold (only significant issues)

---

### T-021: reflect/SKILL.md
**AC**:
- Valid skill frontmatter (inline)
- Analyzes current session via `${CLAUDE_SESSION_ID}`
- Captures: lessons learned, patterns, errors, blockers
- Outputs: Serena memory (reflection record)

---

### T-022: optimize/SKILL.md
**AC**:
- Valid skill frontmatter (inline)
- Proposes fine-tuned orchestrator/agent/skill instructions
- Outputs: Meta-Opt Plan file (requires user approval)
- References prevention items from /reflexion

---

### T-023: analyse/SKILL.md
**AC**:
- Valid skill frontmatter (inline)
- Investigation workflow: search → analyze → document
- Outputs: Analysis report at `reports/analysis/`
- Identifies root cause where possible

---

### T-024: research/SKILL.md
**AC**:
- Valid skill frontmatter (inline)
- Parallel MCP search (Context7, WebSearch)
- Outputs: Research summary at `reports/research/`
- Prevents hallucination via documentation lookup

---

### T-025: distill/SKILL.md
**AC**:
- Valid skill frontmatter (inline)
- Distillation with 5-level granularity (L1-L5)
- Quality loss estimation before execution
- Outputs: Distilled context (inline, not stored)
- Preserves semantic meaning

---

### T-026: orchestrate/SKILL.md
**AC**:
- Valid skill frontmatter (inline, calls agents via Task tool)
- Implements workflow depth selection (Full/Medium/Light)
- Calls agents per workflow template
- Consults user at key decision points
- References workflow templates from `global/workflows/`

---

### T-027: RULES.md
**AC**:
- Generalized from SuperClaude v4 RULES.md
- Rule priority system (Critical/Important/Recommended)
- Removed v4-specific command references
- Universal behavioral rules retained

---

### T-028: PRINCIPLES.md
**AC**:
- Generic SWE principles migrated from SuperClaude v4
- Includes: SOLID, DRY, KISS, YAGNI
- Decision framework, quality philosophy
- Systems thinking principles

---

### T-029: SWE.md
**AC**:
- Full workflow: /spec → /design → /plan → /implement → /validate → /deploy → /document
- Medium workflow: /spec → /plan → /implement → /validate
- Light workflow: /plan → /implement
- Complexity assessment criteria
- Decision points for user consultation

---

### T-030: meta-learning.md
**AC**:
- Workflow: Session → /reflect → /optimize → Approval → Rollout
- Triggers: explicit user request or Stop hook suggestion
- Approval gate before any instruction modifications

---

### T-031: prd.md
**AC**:
- Standard PRD structure (summary, goals, non-goals, FRs, NFRs, user stories)
- Placeholder tokens for skill to fill
- Acceptance criteria format

---

### T-032: architecture.md
**AC**:
- Standard architecture structure (overview, components, data flow, constraints, risks, trade-offs)
- Diagram placeholders
- Component specification format

---

### T-033: adr.md
**AC**:
- Standard ADR structure (context, decision, rationale, consequences)
- Status field (Proposed/Accepted/Deprecated)
- Related ADR references

---

### T-034: roadmap.md
**AC**:
- Milestone overview table (milestone, goal, phases)
- Phase and epic structure with dependencies
- Dependency graph visualization
- Progress tracking table
- References to PRD, Architecture, ADR-005

---

### T-047: backlog.md
**AC**:
- Task table (ID, milestone, phase, epic, task, user story, priority, status)
- Task details section with acceptance criteria
- Priority and status legends
- References to ROADMAP, PRD, Architecture

---

### T-048: issues.md
**AC**:
- Issue types: Bug, Blocker, Tech Debt
- Summary table with counts
- Detailed issue format (severity, status, description, resolution)
- Severity guide

---

### T-049: vision.md
**AC**:
- Problem statement section
- Vision tagline and description
- Target users
- Success metrics table
- Guiding principles

---

### T-050: blueprint.md
**AC**:
- Milestone & phase overview table
- Component breakdown per milestone
- Feature matrix (what ships when)
- Technical constraints
- Related documents links

---

### T-035: global/settings.json
**AC**:
- Hook configuration for SessionStart, Stop, SessionEnd
- References hook scripts at `./hooks/scripts/`
- MCP server configuration (Serena, Context7)

---

### T-036: project/settings.json
**AC**:
- Per-project settings template
- Minimal configuration (inherits from global)
- Placeholder for project-specific overrides

---

### T-037: .claude/settings.json
**AC**:
- SCZ project settings (dogfooding)
- Hook configurations specific to SCZ development
- MCP server references

---

### T-038: install.sh
**AC**:
- `--global` flag: installs `.claude/` + `global/` to `~/.claude/`
- `--project <path>` flag: installs `project/` to target
- `--all <path>` flag: both targets
- JSON patching for settings.json (merge, don't overwrite)
- MD file handling (warn if different, don't overwrite)
- SH file handling (backup + overwrite)
- Installation summary output
- Completes in <30 seconds (NFR3)

---

### T-039: E2E /orchestrate test
**AC**:
- Run `/orchestrate "test feature"` end-to-end
- Verify workflow depth selection works
- Verify agent invocations via Task tool
- Verify artifact generation
- No blocking errors

---

### T-040: Dogfood SCZ docs
**AC**:
- Use SCZ agents/skills to update SCZ's own documentation
- Verify /spec, /design, /plan skills work
- Capture feedback for improvement

---

### T-041: Update README.md
**AC**:
- Installation instructions (install.sh usage)
- Quick start guide
- Skill reference table
- Agent reference table
- MCP requirements

---

### T-042: DESIGN-PRINCIPLES.md
**AC**:
- SCZ-specific architecture principles
- Includes: Skill as Source of Truth, Convention over Config, Minimal MCP
- Agent/Skill/Development principles
- Location: `docs/architecture/DESIGN-PRINCIPLES.md`

---

### T-043: .claude/hooks/README.md
**AC**:
- Documents hook scripts and their purposes
- Lists all hook events and when they fire
- Explains blocking vs non-blocking
- Location: `.claude/hooks/README.md`

---

### T-044: project/ structure
**AC**:
- `project/objectives/GOALS.md.template` - project goals template
- `project/objectives/ROADMAP.md.template` - roadmap template
- `project/knowledge/README.md` - knowledge base instructions
- `project/reports/analysis/.gitkeep` - analysis output directory
- `project/reports/research/.gitkeep` - research output directory

---

### T-045: .serena/README.md
**AC**:
- Documents Serena MCP usage for SCZ
- Explains memory tiers (semantic, reflexion, transient)
- Location: `.serena/README.md`

---

### T-046: Fix $schema in settings.json
**AC**:
- Add valid $schema to `.claude/settings.json`
- Add valid $schema to `global/settings.json`
- Add valid $schema to `project/settings.json`
- Schema: `https://json.schemastore.org/claude-code-settings.json`

---

## Legends

### Priority

| Priority | Meaning |
|----------|---------|
| P0 | Critical path - blocks other tasks |
| P1 | Important - core functionality |
| P2 | Nice to have - can defer |

### Status

| Icon | Meaning |
|:----:|---------|
| ✅ | Done - implemented and committed |
| ⏳ | Pending - not yet started |
| 🔄 | In Progress - actively being worked on |
| 🚫 | Blocked - waiting on dependency |

---

## References

- **ROADMAP**: [ROADMAP.md](../objectives/ROADMAP.md)
- **PRD**: [PRD.md](../architecture/PRD.md)
- **Architecture**: [ARCHITECTURE.md](../architecture/ARCHITECTURE.md)
- **Task Hierarchy**: [ADR-005](../architecture/adr/005-task-decomposition-hierarchy.md)
