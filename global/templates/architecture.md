# {{PROJECT_NAME}} Architecture

**Version**: 0.1.0
**Date**: {{DATE}}
**Author**: Architect Agent
**Source**: [PRD.md](PRD.md)
**Status**: Draft

---

## Executive Summary

{{SUMMARY}}

---

## Overview

### System Context

```
┌─────────────────────────────────────────────────────────┐
│                    {{SYSTEM_NAME}}                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   {{SYSTEM_DIAGRAM}}                                     │
│                                                          │
└─────────────────────────────────────────────────────────┘
         │                              │
         ▼                              ▼
    [External 1]                   [External 2]
```

### Key Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| {{DECISION}} | {{CHOICE}} | {{RATIONALE}} |

See [ADRs](adr/) for detailed decision records.

---

## Components

### {{COMPONENT_1_NAME}}

**Responsibility**: {{SINGLE_RESPONSIBILITY}}

**Interface**:
```
{{INTERFACE_DEFINITION}}
```

**Dependencies**:
- {{DEPENDENCY_1}}
- {{DEPENDENCY_2}}

**Artifacts**:
- {{OUTPUT_1}}

### {{COMPONENT_2_NAME}}

**Responsibility**: {{SINGLE_RESPONSIBILITY}}

**Interface**:
```
{{INTERFACE_DEFINITION}}
```

**Dependencies**:
- {{DEPENDENCY}}

<!-- Add more components as needed -->

---

## Data Flow

### Primary Flow: {{FLOW_NAME}}

```
[User] ──▶ [Component A] ──▶ [Component B] ──▶ [Output]
              │                    │
              ▼                    ▼
          [Store 1]           [Store 2]
```

**Steps**:
1. {{STEP_1}}
2. {{STEP_2}}
3. {{STEP_3}}

### Secondary Flow: {{FLOW_NAME}}

{{FLOW_DESCRIPTION}}

---

## Data Model

### Entities

| Entity | Description | Storage |
|--------|-------------|---------|
| {{ENTITY}} | {{DESCRIPTION}} | {{STORAGE}} |

### Relationships

```
{{ENTITY_1}} ──1:N──▶ {{ENTITY_2}}
```

---

## Interfaces

### External APIs

| Endpoint | Method | Purpose |
|----------|--------|---------|
| {{ENDPOINT}} | {{METHOD}} | {{PURPOSE}} |

### Internal Contracts

| Interface | Provider | Consumer |
|-----------|----------|----------|
| {{INTERFACE}} | {{PROVIDER}} | {{CONSUMER}} |

---

## Constraints

### Technical Constraints

- {{TECHNICAL_CONSTRAINT}}

### Business Constraints

- {{BUSINESS_CONSTRAINT}}

### Regulatory Constraints

- {{REGULATORY_CONSTRAINT}}

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| {{RISK_DESCRIPTION}} | Low/Medium/High | Low/Medium/High | {{MITIGATION_STRATEGY}} |

---

## Trade-offs

### {{TRADE_OFF_NAME}}

**Context**: {{SITUATION}}

**Options Considered**:
1. **{{OPTION_1}}**: {{DESCRIPTION}}
   - Pros: {{PROS}}
   - Cons: {{CONS}}

2. **{{OPTION_2}}**: {{DESCRIPTION}}
   - Pros: {{PROS}}
   - Cons: {{CONS}}

**Decision**: {{CHOSEN_OPTION}}

**Rationale**: {{WHY}}

---

## Security Considerations

### Authentication

{{AUTH_APPROACH}}

### Authorization

{{AUTHZ_APPROACH}}

### Data Protection

{{DATA_PROTECTION_APPROACH}}

---

## Performance Considerations

### Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| {{METRIC}} | {{TARGET}} | {{HOW}} |

### Optimization Strategies

- {{STRATEGY}}

---

## Deployment

### Environments

| Environment | Purpose | Configuration |
|-------------|---------|---------------|
| Development | {{PURPOSE}} | {{CONFIG}} |
| Staging | {{PURPOSE}} | {{CONFIG}} |
| Production | {{PURPOSE}} | {{CONFIG}} |

### Infrastructure

{{INFRASTRUCTURE_DESCRIPTION}}

---

## Design Decisions

| ADR | Title | Status |
|-----|-------|--------|
| [ADR-001](adr/001-{{NAME}}.md) | {{TITLE}} | {{STATUS}} |

---

## Appendix

### Glossary

| Term | Definition |
|------|------------|
| {{TERM}} | {{DEFINITION}} |

### References

- {{REFERENCE}}

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1.0  | {{DATE}} | Architect | Initial architecture |
