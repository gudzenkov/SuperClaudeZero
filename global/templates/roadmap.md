# {{PROJECT_NAME}} Roadmap

**Version**: 0.1.0
**Updated**: {{DATE}}

---

## Milestone Overview

| Milestone | Goal | Phases |
|-----------|------|--------|
| **v0** | {{V0_GOAL}} | Initial |
| **v1** | {{V1_GOAL}} | {{V1_PHASES}} |

---

# v0 Milestone

**Goal**: {{V0_GOAL_DETAIL}}

**Scope**: {{SCOPE_SUMMARY}}

---

## Initial Phase

{{PHASE_DESCRIPTION}}

### Epic: {{EPIC_NAME}}
**Depends on**: {{DEPENDENCIES}}

- [ ] {{DELIVERABLE_1}}
- [ ] {{DELIVERABLE_2}}
- [ ] {{DELIVERABLE_3}}

### Epic: {{EPIC_NAME_2}}
**Depends on**: {{DEPENDENCIES_2}}

- [ ] {{DELIVERABLE_4}}
- [ ] {{DELIVERABLE_5}}

---

## Validation Phase

Integration testing and documentation.

### Epic: Integration Validation
**Depends on**: All Initial Phase epics

- [ ] End-to-end test: {{E2E_TEST}}
- [ ] Dogfood: {{DOGFOOD_TASK}}
- [ ] Update README.md

**-> TAG: v0.1.0 **

---

# v1 Milestone

**Goal**: {{V1_GOAL_DETAIL}}

**Prerequisite**: v0.1.0  complete

---

## MVP Phase

{{MVP_DESCRIPTION}}

### Epic: {{V1_EPIC_1}}
**Depends on**: v0 complete

- [ ] {{V1_DELIVERABLE_1}}
- [ ] {{V1_DELIVERABLE_2}}

---

## Dependency Graph

```
v0 Milestone
+-- Initial Phase
|   +-- {{EPIC_1}} ----+
|   |                  |
|   +-- {{EPIC_2}} <---+
|   |
|   +-- {{EPIC_3}} (parallel)
|
+-- Validation Phase <-- All Initial Phase
    +-- Integration Validation
        -> TAG: v0.1.0

v1 Milestone
+-- MVP Phase <-- v0.1.0
    -> TAG: v1.0.0
```

---

## Progress Tracking

| Milestone | Phase | Epics | Tasks | Status |
|-----------|-------|-------|-------|--------|
| v0 | Initial | {{EPIC_COUNT}} | {{TASK_COUNT}} | Not started |
| v0 | Validation | 1 | {{VAL_TASKS}} | Not started |
| v1 | MVP | {{V1_EPICS}} | {{V1_TASKS}} | Not started |

---

## References

- **PRD**: [PRD.md](../architecture/PRD.md)
- **Architecture**: [ARCHITECTURE.md](../architecture/ARCHITECTURE.md)
- **Task Hierarchy**: [ADR-005](../architecture/adr/005-task-decomposition-hierarchy.md)
