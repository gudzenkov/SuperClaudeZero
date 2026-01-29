# Software Engineering Workflow

**Version**: 0.1.0
**Purpose**: Guide development from idea to deployment

---

## Workflow Overview

Three workflow depths based on project complexity:

| Depth | Phases | Use When |
|-------|--------|----------|
| **Full** | spec → design → plan → implement → validate → deploy → document | New product, complex system |
| **Medium** | spec → plan → implement → validate | New feature, moderate complexity |
| **Light** | plan → implement | Simple change, bug fix |

---

## Workflow Definitions

### Full Workflow

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌───────────┐
│  /spec  │───▶│ /design │───▶│  /plan  │───▶│/implement │
└─────────┘    └─────────┘    └─────────┘    └───────────┘
     │              │              │               │
     ▼              ▼              ▼               ▼
   PRD.md      ARCH.md +      ROADMAP.md      Code +
               ADRs           BACKLOG.md      Tests
                                                   │
                                                   ▼
                              ┌──────────┐    ┌─────────┐    ┌──────────┐
                              │/validate │───▶│ /deploy │───▶│/document │
                              └──────────┘    └─────────┘    └──────────┘
                                   │               │               │
                                   ▼               ▼               ▼
                              Validation      Deployed         README +
                               Report         Artifacts         Guides
```

**Phases**:

1. **Specification** (`/spec` → Business Analyst)
   - Input: Idea or feature description
   - Output: `docs/architecture/PRD.md`
   - Activities: Requirements elicitation, acceptance criteria definition

2. **Design** (`/design` → Architect)
   - Input: PRD
   - Output: `docs/architecture/ARCHITECTURE.md`, `docs/architecture/adr/`
   - Activities: System design, component definition, trade-off analysis

3. **Planning** (`/plan` → Project Manager)
   - Input: Architecture
   - Output: `docs/objectives/ROADMAP.md`, `docs/development/BACKLOG.md`
   - Activities: Task decomposition, prioritization, dependency mapping

4. **Implementation** (`/implement` → Developer)
   - Input: Task from backlog
   - Output: Code, tests
   - Activities: Coding, testing, code review prep

5. **Validation** (`/validate` → Validator)
   - Input: Implementation
   - Output: Validation report (Serena memory)
   - Activities: Testing, AC verification, quality checks

6. **Deployment** (`/deploy` → Deployer)
   - Input: Validated code
   - Output: Deployed artifacts
   - Activities: Build, deploy, release verification

7. **Documentation** (`/document` → Tech Writer)
   - Input: Deployed feature
   - Output: `docs/`, `README.md`
   - Activities: User docs, API docs, guides

---

### Medium Workflow

```
┌─────────┐    ┌─────────┐    ┌───────────┐    ┌──────────┐
│  /spec  │───▶│  /plan  │───▶│/implement │───▶│/validate │
└─────────┘    └─────────┘    └───────────┘    └──────────┘
     │              │               │               │
     ▼              ▼               ▼               ▼
   PRD.md      BACKLOG.md      Code + Tests    Validation
```

**Phases**:

1. **Specification** (`/spec` → Business Analyst)
   - Streamlined PRD with focus on acceptance criteria
   - Skip detailed user personas if obvious

2. **Planning** (`/plan` → Project Manager)
   - Direct to BACKLOG (skip formal ROADMAP)
   - Focus on task breakdown

3. **Implementation** (`/implement` → Developer)
   - Standard implementation with tests

4. **Validation** (`/validate` → Validator)
   - AC verification, test execution

---

### Light Workflow

```
┌─────────┐    ┌───────────┐
│  /plan  │───▶│/implement │
└─────────┘    └───────────┘
     │               │
     ▼               ▼
  Task def      Code + Tests
```

**Phases**:

1. **Planning** (`/plan` → Project Manager)
   - Quick task definition with acceptance criteria
   - May be single task, no epic structure needed

2. **Implementation** (`/implement` → Developer)
   - Straightforward implementation

---

## Complexity Assessment

Use this scoring to select workflow depth:

| Factor | Score | Examples |
|--------|-------|----------|
| New system/product | +3 | "Build a CLI tool", "Create a new service" |
| Multiple components | +2 | "Frontend + backend", "Multiple microservices" |
| External integration | +2 | "Connect to Stripe", "OAuth integration" |
| New API design | +1 | "New REST endpoints", "GraphQL schema" |
| UI changes | +1 | "New dashboard", "Form redesign" |
| Database changes | +1 | "New tables", "Schema migration" |
| Simple bug fix | -2 | "Fix null check", "Handle edge case" |
| Documentation only | -3 | "Update README", "Add comments" |
| Configuration change | -2 | "Update env vars", "Change settings" |

**Scoring Thresholds**:
- **Score >= 4**: Full workflow
- **Score 1-3**: Medium workflow
- **Score <= 0**: Light workflow

---

## Decision Points

The orchestrator should consult the user at these points:

### Mandatory Checkpoints
1. **Workflow Selection**: Before starting, confirm depth is appropriate
2. **Scope Changes**: If spec reveals larger scope than expected
3. **Architecture Trade-offs**: When decisions have significant long-term impact
4. **Blockers**: When unable to proceed without guidance

### Optional Checkpoints
1. **Phase Transitions**: "PRD complete. Ready to proceed to design?"
2. **Implementation Choices**: "Two approaches possible: A or B. Preference?"
3. **Validation Failures**: "Tests failing. Should I fix or investigate further?"

---

## Artifact Flow

Each phase produces artifacts consumed by subsequent phases:

```
/spec
  └─▶ PRD.md
        └─▶ /design
              └─▶ ARCHITECTURE.md, ADRs
                    └─▶ /plan
                          └─▶ ROADMAP.md, BACKLOG.md
                                └─▶ /implement
                                      └─▶ Code, Tests
                                            └─▶ /validate
                                                  └─▶ Report
                                                        └─▶ /deploy
                                                              └─▶ /document
```

**Traceability**: Each artifact should reference its source:
- PRD → User request
- Architecture → PRD requirements
- Tasks → Architecture components
- Code → Task IDs
- Commits → Task IDs

---

## Error Handling

If a phase fails or is blocked:

1. **Document the blocker** in the artifact
2. **Assess severity**:
   - Critical: Cannot proceed (stop workflow)
   - High: Needs resolution before next phase
   - Medium: Can proceed with caveat
   - Low: Note for later
3. **Invoke /reflexion** if significant learning
4. **Consult user** for critical/high blockers
5. **Continue or halt** based on guidance

---

## Parallel Execution

Where dependencies allow, phases can run in parallel:

```
/spec ────────────────────────┐
                              ├──▶ /design
/analyse (existing code) ─────┘
```

```
/implement (task 1) ──────────┐
                              ├──▶ /validate
/implement (task 2) ──────────┘
```

Use the Wave → Checkpoint → Wave pattern for parallel tasks.

---

## Workflow Selection Examples

| Request | Score | Workflow |
|---------|-------|----------|
| "Build a project management app" | +3 (new) +2 (components) = 5 | Full |
| "Add user authentication" | +2 (integration) +1 (API) = 3 | Medium |
| "Implement dark mode toggle" | +1 (UI) = 1 | Medium |
| "Fix typo in error message" | -2 (simple fix) = -2 | Light |
| "Add retry logic to API calls" | 0 | Light |
| "Build analytics dashboard" | +3 (new) +1 (UI) +1 (API) = 5 | Full |
