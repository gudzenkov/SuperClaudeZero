# Claude Code General Rules

## Priority System

**CRITICAL**: Security, data safety, production breaks - Never compromise
**IMPORTANT**: Quality, maintainability, professionalism - Strong preference
**RECOMMENDED**: Optimization, style, best practices - Apply when practical

**Conflict Resolution**: Safety > Scope > Quality > Context

## Agent Orchestration [CRITICAL]

**Agents**: Business Analyst (`/spec`), Architect (`/design`), Project Manager (`/plan`), Developer (`/implement`), Validator (`/validate`), Deployer (`/deploy`), Tech Writer (`/document`), Meta-Agent (`/optimize`)

**Utilities**: `/orchestrate` (workflow), `/reflect` (session learning), `/reflexion` (error learning), `/analyse` (debugging), `/research` (docs), `/distill` (content distillation)

**Auto-Selection**: Keywords, file types, complexity trigger specialists. Manual: Task tool with `subagent_type`.

**Flow**: Request → Agent → `/reflexion` (issues) → `/reflect` (patterns) → `/optimize` (improvements)

## Workflow [IMPORTANT]

**Full**: `/spec` → `/design` → `/plan` → `/implement` → `/validate` → `/deploy` → `/document`
**Medium**: `/spec` → `/plan` → `/implement` → `/validate`
**Light**: `/plan` → `/implement`

**Pattern**: Understand → Plan (parallelize) → Execute → Track → Validate

- Parallel by default, sequential only for dependencies
- Validate before/after execution
- Evidence-based, discovery-first

## Planning Efficiency [CRITICAL]

- Identify concurrent operations
- Map dependencies vs parallelizable tasks
- Consider token usage and execution time

## Implementation [IMPORTANT]

- No partial features, TODO comments, mock objects, incomplete functions
- All code production-ready

## Scope Discipline [IMPORTANT]

- Build ONLY what's asked, MVP first
- No enterprise bloat, single responsibility
- YAGNI: no speculative features

## Code Organization [RECOMMENDED]

- Consistent naming conventions per language/framework
- Descriptive names, logical directory structure
- Match existing patterns, no mixed conventions

## Workspace Hygiene [IMPORTANT]

- Remove temp files after operations
- Clean build artifacts, logs, debugging outputs
- Never leave temp files that could be committed

## Failure Investigation [CRITICAL]

- Root cause analysis required
- Never skip tests or validation
- Fix underlying issues, not symptoms

## Professional Honesty [IMPORTANT]

- No marketing language or fake metrics
- Honest trade-offs and assessments
- Evidence-based, state "untested"/"MVP" when applicable

## Git Workflow [CRITICAL]

- `git status && git branch` before starting
- Feature branches only, never main/master
- Incremental commits, verify before staging
- Descriptive messages

## Tool Optimization [RECOMMENDED]

**Priority**: MCP > Native > Basic

- Parallel independent operations
- Task tool for >3 step operations
- Batch Read/Edit calls

**MCP Servers**: Serena (memory), Context7 (docs), DeepWiki (GitHub), Playwright (browser)
**Docs Flow**: Context7 → DeepWiki → WebSearch

## File Organization [IMPORTANT]

- Reports in `reports/`, tests in `tests/`/`__tests__/`, scripts in `scripts/`/`bin/`
- Never scatter test files next to source

## Safety [CRITICAL]

- Check deps before using libraries
- Follow existing patterns
- Transaction-safe batch operations
- Plan → Execute → Verify

## Temporal Awareness [CRITICAL]

- Always verify current date from `<env>`
- Never assume from knowledge cutoff
- Base all time calculations on verified date

## Quick Reference

**CRITICAL**: git status first, read before write, feature branches only, root cause analysis, absolute paths
**IMPORTANT**: /plan for >3 steps, complete implementations, MVP only, professional language, clean workspace
**RECOMMENDED**: Parallel ops, descriptive naming, MCP tools, batch operations
