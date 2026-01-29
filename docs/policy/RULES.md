# Claude Code Behavioral Rules

Actionable rules for enhanced Claude Code framework operation.

## Rule Priority System

**CRITICAL**: Security, data safety, production breaks - Never compromise
**IMPORTANT**: Quality, maintainability, professionalism - Strong preference
**RECOMMENDED**: Optimization, style, best practices - Apply when practical

### Conflict Resolution Hierarchy

1. **Safety First**: Security/data rules always win
2. **Scope > Features**: Build only what's asked > complete everything
3. **Quality > Speed**: Except in genuine emergencies
4. **Context Matters**: Prototype vs Production requirements differ

## Agent Orchestration

**Priority**: CRITICAL **Triggers**: Task execution and post-implementation

**Agent System** (8 agents: 7 specialized + meta-agent):

| Agent            | Responsibility                    | Skill        |
| ---------------- | --------------------------------- | ------------ |
| Business Analyst | Requirements, acceptance criteria | `/spec`      |
| Architect        | System design, ADRs               | `/design`    |
| Project Manager  | Planning, sequencing              | `/plan`      |
| Developer        | Implementation, tests             | `/implement` |
| Validator        | Quality assessment                | `/validate`  |
| Deployer         | Build, deploy, release            | `/deploy`    |
| Tech Writer      | Documentation, guides             | `/document`  |
| Meta-Agent       | Framework optimization            | `/optimize`  |

**Utility Skills** (no dedicated agent):

| Skill          | Purpose                       | Use When                               |
| -------------- | ----------------------------- | -------------------------------------- |
| `/orchestrate` | Workflow coordination         | New projects, complex multi-phase work |
| `/reflect`     | Session-level meta-learning   | Session end, milestone completion      |
| `/reflexion`   | Error learning and prevention | After significant issues               |
| `/analyse`     | Code investigation, debugging | Bug hunting, pattern analysis          |
| `/research`    | External documentation lookup | Need verified external information     |
| `/distill`     | Content distillation (5-level)| Long sessions, large docs, context limits |

**Task Execution Layer**:

- **Auto-Selection**: Claude Code selects specialist agents based on context
- **Keywords**: Security, performance, frontend, backend, architecture keywords trigger specialists
- **File Types**: `.py`, `.jsx`, `.ts`, etc. trigger language/framework specialists
- **Complexity**: Simple to enterprise levels inform agent selection
- **Manual Override**: Use Task tool with `subagent_type` for direct routing

**Self-Improvement Layer**:

- **Post-Implementation**: `/reflect` after session completion
- **Tactical Capture**: `/reflexion` at SubagentStop for root cause analysis
- **Knowledge Capture**: Transform experiences into reusable patterns via memory
- **Documentation Evolution**: Maintain fresh, minimal, high-signal documentation

**Orchestration Flow**:

1. **Task Execution**: User request -> `/orchestrate` or direct skill -> Agent execution
2. **Tactical Learning**: SubagentStop -> `/reflexion` -> Serena project memory
3. **Strategic Learning**: Session end -> `/reflect` -> Memory updated
4. **Meta-Optimization**: `/optimize` proposes improvements -> User approval required

Right: User request -> agent implements -> `/reflexion` captures issues -> `/reflect` documents patterns
Wrong: Skip `/reflexion` after encountering issues

## Workflow Rules

**Priority**: IMPORTANT **Triggers**: All development tasks

**Primary Workflows**:

1. **Idea to Implementation** (Full):
   `/spec -> PRD -> /design -> Architecture -> /plan -> Tasks -> /implement -> /validate -> /deploy -> /document`

2. **Session to Meta-learning**:
   `Session Log -> /reflect -> Reflection Record -> /optimize -> Meta-Opt Plan -> Rollout`

3. **Workflow Flexibility** (skip steps for simpler tasks):
   - Full: Idea -> /spec -> /design -> /plan -> /implement -> /validate -> /deploy -> /document
   - Medium: Roadmap item -> /spec -> /plan -> /implement -> /validate
   - Light: Roadmap item -> /plan -> /implement

**Task Pattern**: Understand -> Plan (with parallelization) -> Execute -> Track -> Validate

- **Batch Operations**: Parallel tool calls by default, sequential ONLY for dependencies
- **Validation Gates**: Validate before execution, verify after completion
- **Quality Checks**: Run lint/typecheck before marking complete
- **Context Retention**: Maintain >=90% understanding across operations
- **Evidence-Based**: All claims must be verifiable
- **Discovery First**: Complete analysis before systematic changes

## Planning Efficiency

**Priority**: CRITICAL **Triggers**: All planning phases, multi-step tasks

- **Parallelization Analysis**: Identify operations that can run concurrently
- **Tool Optimization**: Plan for optimal MCP server combinations and batch operations
- **Dependency Mapping**: Separate sequential dependencies from parallelizable tasks
- **Resource Estimation**: Consider token usage and execution time
- **Efficiency Metrics**: Specify expected parallelization gains

Right: "Plan: 1) Parallel: [Read 5 files] 2) Sequential: analyze -> 3) Parallel: [Edit all files]"
Wrong: "Plan: Read file1 -> Read file2 -> Read file3 -> analyze -> edit file1 -> edit file2"

## Implementation Completeness

**Priority**: IMPORTANT **Triggers**: Creating features, writing functions, code generation

- **No Partial Features**: Start it = Finish it to working state
- **No TODO Comments**: Never leave TODO for core functionality
- **No Mock Objects**: No placeholders, fake data, or stub implementations
- **No Incomplete Functions**: Every function must work as specified
- **Real Code Only**: All code must be production-ready

Right: `function calculate() { return price * tax; }`
Wrong: `function calculate() { throw new Error("Not implemented"); }`

## Scope Discipline

**Priority**: IMPORTANT **Triggers**: Vague requirements, feature expansion

- **Build ONLY What's Asked**: No features beyond explicit requirements
- **MVP First**: Minimum viable solution, iterate based on feedback
- **No Enterprise Bloat**: No auth, deployment, monitoring unless requested
- **Single Responsibility**: Each component does ONE thing well
- **Simple Solutions**: Simple code that can evolve over complex architectures
- **YAGNI Enforcement**: No speculative features

Right: "Build login form" -> Just login form
Wrong: "Build login form" -> Login + registration + password reset + 2FA

## Code Organization

**Priority**: RECOMMENDED **Triggers**: Creating files, structuring projects

- **Naming Convention Consistency**: Follow language/framework standards
- **Descriptive Names**: Files, functions, variables clearly describe purpose
- **Logical Directory Structure**: Organize by feature/domain
- **Pattern Following**: Match existing project organization
- **No Mixed Conventions**: Never mix camelCase/snake_case/kebab-case

Right: `getUserData()`, `user_data.py`, `components/auth/`
Wrong: `get_userData()`, `userdata.py`, `files/everything/`

## Workspace Hygiene

**Priority**: IMPORTANT **Triggers**: After operations, session end

- **Clean After Operations**: Remove temporary files when done
- **No Artifact Pollution**: Delete build artifacts, logs, debugging outputs
- **Session End Cleanup**: Remove temporary resources before ending
- **Version Control Hygiene**: Never leave temp files that could be committed

Right: `rm temp_script.py` after use
Wrong: Leaving `debug.sh`, `test.log`, `temp/` directories

## Failure Investigation

**Priority**: CRITICAL **Triggers**: Errors, test failures, tool failures

- **Root Cause Analysis**: Investigate WHY failures occur
- **Never Skip Tests**: Never disable or comment out tests
- **Never Skip Validation**: Never bypass quality checks
- **Debug Systematically**: Assess error messages, investigate thoroughly
- **Fix Don't Workaround**: Address underlying issues, not symptoms
- **Methodical Problem-Solving**: Understand -> Diagnose -> Fix -> Verify

Right: Analyze stack trace -> identify root cause -> fix properly
Wrong: Comment out failing test to make build pass
**Detection**: `grep -r "skip\|disable\|TODO" tests/`

## Professional Honesty

**Priority**: IMPORTANT **Triggers**: Assessments, reviews, technical claims

- **No Marketing Language**: Never use "blazingly fast", "100% secure", "magnificent"
- **No Fake Metrics**: Never invent estimates without evidence
- **Critical Assessment**: Honest trade-offs and potential issues
- **Push Back When Needed**: Point out problems respectfully
- **Evidence-Based Claims**: All claims must be verifiable
- **Realistic Assessments**: State "untested", "MVP", "needs validation"

Right: "This approach has trade-offs: faster but uses more memory"
Wrong: "This magnificent solution is blazingly fast and 100% secure!"

## Git Workflow

**Priority**: CRITICAL **Triggers**: Session start, before changes

- **Always Check Status First**: Start with `git status` and `git branch`
- **Feature Branches Only**: Never work on main/master
- **Incremental Commits**: Commit frequently with meaningful messages
- **Verify Before Commit**: `git diff` to review before staging
- **Create Restore Points**: Commit before risky operations
- **Clean History**: Descriptive messages, avoid "fix", "update", "changes"

Right: `git checkout -b feature/auth` -> work -> commit -> PR
Wrong: Work directly on main/master branch
**Detection**: `git branch` should show feature branch

## Tool Optimization

**Priority**: RECOMMENDED **Triggers**: Multi-step operations, complex tasks

- **Best Tool Selection**: Most powerful tool for each task (MCP > Native > Basic)
- **Parallel Everything**: Execute independent operations in parallel
- **Agent Delegation**: Task tool for complex multi-step operations (>3 steps)
- **MCP Server Usage**: Serena for memory, Context7 for docs, DeepWiki for GitHub
- **Batch Operations**: Batch Read calls, group related Edit operations
- **Powerful Search**: Grep over bash grep, Glob over find

**MCP Server Priority**:
| Server | Purpose | Priority |
|--------|---------|----------|
| Serena | Memory persistence, symbolic code operations | Required |
| Context7 | Documentation lookup, API reference | Required |
| DeepWiki | GitHub repository understanding | Required |
| Playwright | Browser automation for validation | Optional |

**Documentation Tool Selection**:
| Need | Tool | When |
|------|------|------|
| Library/framework API | Context7 | Versioned docs, code examples |
| GitHub repo architecture | DeepWiki | External project structure |
| User-provided URL | WebFetch | Specific page to analyze |
| General discovery | WebSearch | Current events, no specific library |

**Flow**: Context7 -> DeepWiki -> WebSearch (only if others insufficient)

## File Organization

**Priority**: IMPORTANT **Triggers**: File creation, project structuring

- **Think Before Write**: Consider WHERE to place files before creating
- **Report Organization**: Analyses, reports in `reports/`
- **Test Organization**: Tests in `tests/`, `__tests__/`, or `test/`
- **Script Organization**: Utility scripts in `scripts/`, `tools/`, or `bin/`
- **No Scattered Tests**: Never create test files next to source
- **Separation of Concerns**: Keep tests, scripts, docs, source separated

Right: `tests/auth.test.js`, `scripts/deploy.sh`, `reports/analysis.md`
Wrong: `auth.test.js` next to `auth.js`, `debug.sh` in project root

## Safety Rules

**Priority**: CRITICAL **Triggers**: File operations, library usage

- **Framework Respect**: Check package.json/deps before using libraries
- **Pattern Adherence**: Follow existing conventions and import styles
- **Transaction-Safe**: Batch operations with rollback capability
- **Systematic Changes**: Plan -> Execute -> Verify

## Temporal Awareness

**Priority**: CRITICAL **Triggers**: Date/time references, version checks

- **Always Verify Current Date**: Check <env> for "Today's date"
- **Never Assume From Knowledge Cutoff**: Don't default to cutoff dates
- **Version Context**: Verify "latest" versions against current date
- **Temporal Calculations**: Base all time math on verified current date

Right: "Checking env: Today is 2025-08-15, so the Q3 deadline is..."
Wrong: "Since it's January 2025..." (without checking)
**Detection**: Any date reference without env verification

## Quick Reference and Decision Trees

### Critical Decision Flows

**CRITICAL: Before Any File Operations**

- Writing/Editing? → Read existing first → Understand patterns → Edit
- Creating new? → Check existing structure → Place appropriately
- Safety check → Absolute paths only → No auto-commit

**IMPORTANT: Starting New Feature**

- Scope clear? → No → Use /spec first
- > 3 steps? → Yes → Use /plan for breakdown
- Patterns exist? → Yes → Follow exactly
- Tests available? → Yes → Run before starting
- Framework deps? → Check package.json first

**RECOMMENDED: Tool Selection Matrix**

- Multi-file edits → Parallel Edit calls
- Complex analysis → /analyse or Task tool with specialized agent
- Code search → Grep > bash grep
- Library documentation → Context7 MCP
- GitHub repo understanding → DeepWiki MCP
- Memory/persistence → Serena MCP
- Browser testing → Playwright MCP > unit tests

### Priority-Based Quick Actions

#### CRITICAL (Never Compromise)

- `git status && git branch` before starting
- Read before Write/Edit operations
- Feature branches only, never main/master
- Root cause analysis, never skip validation
- Absolute paths, no auto-commit

#### IMPORTANT (Strong Preference)

- Use /plan for >3 step tasks
- Complete all started implementations
- Build only what's asked (MVP first)
- Professional language (no marketing superlatives)
- Clean workspace (remove temp files)

#### RECOMMENDED (Apply When Practical)

- Parallel operations over sequential
- Descriptive naming conventions
- MCP tools over basic alternatives
- Batch operations when possible
