---
name: spec
description: Generate a Product Requirements Document from an idea or feature request
argument-hint: <idea or feature description>
user-invocable: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - AskUserQuestion
context: fork
agent: business-analyst
---

# /spec - Product Requirements Specification

Generate a comprehensive PRD from the provided idea or feature description.

## Purpose

Transform a rough idea into a structured Product Requirements Document with:
- Clear goals and non-goals
- Functional and non-functional requirements
- User stories with acceptance criteria
- Testable success metrics

## Inputs

- `$ARGUMENTS`: The idea or feature description to specify
- `${PROJECT_NAME}`: Current project context
- Existing docs (if any): `docs/architecture/PRD.md`, `docs/objectives/VISION.md`

## Outputs

PRD written to `docs/architecture/PRD.md`

## Workflow

### 1. Understand the Request
Read `$ARGUMENTS` and any existing context. Ask clarifying questions:
- Who is the target user?
- What problem does this solve?
- What does success look like?
- Are there constraints or dependencies?

### 2. Research Context
- Check existing `docs/` for related requirements
- Search for similar solutions or patterns
- Look up best practices if applicable

### 3. Define Scope
**Goals**: What this feature/product WILL do
**Non-Goals**: What this explicitly WON'T do (prevents scope creep)

### 4. Write Requirements

**Functional Requirements (FRs)**:
```
### FR1: [Feature Name]
[Description of the feature]

**Acceptance Criteria:**
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
```

**Non-Functional Requirements (NFRs)**:
| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR1 | [Quality attribute] | [Target value] | [How to verify] |

### 5. Create User Stories
```
### US1: [Story Title]
**As a** [role/persona]
**I want to** [action/capability]
**So that** [benefit/value]

**Acceptance Criteria:**
- [ ] Given [context], when [action], then [result]
```

### 6. Validate Completeness
Before completing, verify:
- [ ] All user-facing features have stories
- [ ] All stories have acceptance criteria
- [ ] NFRs cover performance, security, reliability
- [ ] Goals and non-goals are clear
- [ ] Requirements are testable

## Template Reference

Use the PRD template structure:
```markdown
# [Project/Feature Name] Product Requirements Document

**Version**: 0.1.0
**Date**: [date]
**Author**: Business Analyst Agent

---

## Executive Summary
[Brief overview - what, why, for whom]

## Goals
### Primary Goal
[Main objective]

### Secondary Goals
- [Goal 1]
- [Goal 2]

### Non-Goals
- [Explicit exclusion 1]
- [Explicit exclusion 2]

## Functional Requirements
[FR sections]

## Non-Functional Requirements
[NFR table]

## User Stories
[US sections]

## Dependencies
[External dependencies]

## Open Questions
[Unresolved items for user clarification]
```
