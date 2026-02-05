# CLAUDE.md

Guidance for Claude Code when working with AgentOrchestrator.

---

## Artifact Layers

```
┌─────────────────────────────────────────────────────────────────────┐
│  STRATEGIC (locked after PRD)                                       │
│  VISION ───▶ BLUEPRINT                                              │
├─────────────────────────────────────────────────────────────────────┤
│  SPECIFICATION (changes with approval)                              │
│  PRD ───▶ ARCHITECTURE ───▶ ADR                                     │
├─────────────────────────────────────────────────────────────────────┤
│  EXECUTION (changes frequently)                                     │
│  ROADMAP ───▶ BACKLOG                                               │
└─────────────────────────────────────────────────────────────────────┘
```

## Artifact Definitions

| Artifact | Layer | Contains |
|----------|-------|----------|
| **VISION** | Strategic | Why, target users, success metrics |
| **BLUEPRINT** | Strategic | Technical scope, capabilities, feature matrix |
| **PRD** | Specification | Features, user stories, acceptance criteria |
| **ARCHITECTURE** | Specification | System design, risks, dependencies |
| **ADR** | Specification | Decision rationale, alternatives, consequences |
| **ROADMAP** | Execution | Milestones, phases, epics + dependencies |
| **BACKLOG** | Execution | Prioritized tasks from ROADMAP epics |
| **ISSUES** | Execution | Discovered bugs, blockers, tech debt |

## Artifact Locations

```
docs/
├── objectives/           # Strategic
│   ├── VISION.md
│   ├── BLUEPRINT.md
│   └── ROADMAP.md
├── architecture/         # Specification
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   ├── adr/
│   └── diagrams/
└── development/          # Execution
    ├── BACKLOG.md        # Prioritized tasks
    └── ISSUES.md         # Discovered bugs/blockers
```

## Skill → Agent → Artifact

| Skill | Agent | Creates |
|-------|-------|---------|
| `/spec` | Business Analyst | PRD |
| `/design` | Architect | ARCHITECTURE, ADRs |
| `/plan` | Project Manager | ROADMAP, BACKLOG |
| `/implement` | Developer | Code, Tests |
| `/validate` | Validator | Validation Report |
| `/deploy` | Deployer | Deployment Artifacts |
| `/document` | Tech Writer | Documentation, README |

## Workflow

```
/spec → PRD → /design → ARCHITECTURE + ADRs → /plan → ROADMAP + BACKLOG → /implement → /validate → /deploy → /document
```

## Task Hierarchy (ADR-005)

```
Milestone (Release)      → Tag
└── Phase (Workflow)     → —
    └── Epic (Feature)   → —
        └── Task (Atomic) → Commit
```

| Level | Definition | Git Artifact |
|-------|------------|--------------|
| Milestone | Shippable release | Tag |
| Phase | Research, Design, Implement, Validate | — |
| Epic | Group of related tasks | — |
| Task | Atomic, testable, committable | Commit |

## Traceability

```
US-001 → COMP-003 → ADR-005 → EPIC-007 → TASK-015 → commit [refs: US-001]
```

---

## Change Impact Classification

Changes are classified by two orthogonal dimensions: **Area** (what changed) and **Criticality** (severity).

### Impact Areas

| Area | Boundary | Entry Point |
|------|----------|-------------|
| **System** | Core functionality broken (hooks, MCP, install, agents) | ISSUES |
| **Product** | Vision, goals, target users, success metrics | VISION |
| **Solution** | Capabilities, feature matrix, technical scope | BLUEPRINT |
| **Specification** | Features, requirements, user stories, acceptance criteria | PRD |
| **Architecture** | Components, patterns, dependencies, decisions | ARCHITECTURE |
| **Development** | Task organization, priorities, status | ROADMAP/BACKLOG |
| **Documentation** | All docs: arch docs, policies, knowledge, guides | Varies |

### Criticality Levels

| Level | Definition | Response |
|-------|------------|----------|
| **CRITICAL** | Blocking, broken functionality, data loss risk | Immediate action required |
| **HIGH** | Significant impact, major feature affected | Address in current session |
| **MEDIUM** | Moderate impact, standard priority | Address in current sprint |
| **LOW** | Minor, cosmetic, can defer | Backlog for later |

### Propagation Paths by Area

```
SYSTEM        → ISSUES → BACKLOG
PRODUCT       → VISION → BLUEPRINT → PRD → ARCHITECTURE → ADR → ROADMAP → BACKLOG
SOLUTION      → BLUEPRINT → PRD → ARCHITECTURE → ADR → ROADMAP → BACKLOG
SPECIFICATION → PRD → ARCHITECTURE → ADR → ROADMAP → BACKLOG
ARCHITECTURE  → ARCHITECTURE → ADR → ROADMAP → BACKLOG
DEVELOPMENT   → ROADMAP → BACKLOG (or BACKLOG only)
DOCUMENTATION → Direct to target doc (README, CLAUDE.md, docs/policy/, docs/knowledge/)
```

### Examples (Area × Criticality)

| Change | Area | Criticality | Path |
|--------|------|-------------|------|
| Hooks not firing | System | CRITICAL | ISSUES → BACKLOG |
| New target user segment | Product | HIGH | VISION → BLUEPRINT → ... → BACKLOG |
| New capability added | Solution | HIGH | BLUEPRINT → PRD → ARCH → ROADMAP → BACKLOG |
| New skill behavior | Specification | MEDIUM | PRD → ARCHITECTURE → BACKLOG |
| New hook utils library | Architecture | MEDIUM | ARCHITECTURE → BACKLOG |
| Component refactor | Architecture | HIGH | ARCHITECTURE → ADR → BACKLOG |
| Task completed | Development | LOW | BACKLOG |
| ARCHITECTURE.md outdated | Documentation | MEDIUM | ARCHITECTURE.md directly |
| README typo | Documentation | LOW | README.md directly |
| Policy update | Documentation | MEDIUM | docs/policy/ or global/policy/ |

### Policy Locations

Three-tier policy structure:

```
global/policy/              # Framework policies (→ ~/.claude/policy/)
├── PRINCIPLES.md           # SW engineering principles
├── RULES.md                # Agent behavioral rules
└── GUIDELINES.md           # User guidance

docs/policy/                # Orchestrator project-specific policies
├── PRINCIPLES.md           # Orchestrator-specific principles
├── RULES.md                # Orchestrator-specific rules
└── GUIDELINES.md           # Orchestrator-specific user guidance

project/docs/policy/        # Project template (→ <project>/docs/policy/)
├── RULES.md                # Template for project rules
└── GUIDELINES.md           # Template for project guidelines
```

**Installation flow**:
- `./install.sh --global` → `global/policy/` → `~/.claude/policy/` (all projects)
- `./install.sh --project <path>` → `project/docs/policy/` → `<path>/docs/policy/` (per-project)

---

## Development

```bash
# UV required for all Python operations
uv run pytest                    # Run tests
uv pip install package           # Install dependencies

# Installation
./install.sh --global            # Install to ~/.claude/
./install.sh --project <path>    # Install project templates
./install.sh --all <path>        # Both
```

### Python Script Convention

**All Python scripts must be self-contained via uvx shebang**:

```python
#!/usr/bin/env -S uvx --from package-name python
```

- **Execute directly**: `./script.py` (NOT `python script.py`)
- uvx automatically installs dependencies in isolated environment
- No manual dependency management required

Example shebangs:
- Claude SDK: `#!/usr/bin/env -S uvx --from claude-agent-sdk python`
- Multiple deps: `#!/usr/bin/env -S uvx --from "package1,package2" python`

---

## MCP Dependencies

| Server | Purpose | Required |
|--------|---------|----------|
| **Serena** | Memory persistence, symbolic code operations | Yes |
| **Context7** | Documentation lookup | Yes |
| **DeepWiki** | GitHub repository documentation | Yes |
| **Playwright** | Browser automation | Optional |
