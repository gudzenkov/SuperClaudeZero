# Workflow Engine: Idea to Implementation

```
                    ORCHESTRATOR DECISION
                           |
          +----------------+----------------+
          |                |                |
          v                v                v
       [FULL]          [MEDIUM]          [LIGHT]
          |                |                |
          v                v                v
    BA Agent           BA Agent         PM Agent
    (+/spec)           (+/spec)         (+/plan)
          |                |                |
          v                v                v
        PRD              PRD             Tasks
          |                |                |
          v                v                v
    Arch Agent         PM Agent         Dev Agent
    (+/design)         (+/plan)         (+/implement)
          |                |                |
          v                v                v
    Architecture       Tasks             Code
          |                |                |
          v                v                |
    PM Agent           Dev Agent            |
    (+/plan)           (+/implement)        |
          |                |                |
          v                v                |
       Tasks            Code               |
          |                |                |
          v                v                |
    Dev Agent          Val Agent            |
    (+/implement)      (+/validate)         |
          |                |                |
          v                v                |
        Code           Report              |
          |                                |
          v                                |
    Val Agent                              |
    (+/validate)                           |
          |                                |
          v                                |
       Report                              |
          |                                |
          v                                |
    Deployer Agent                         |
    (+/deploy)                             |
          |                                |
          v                                |
     Artifacts                             |
          |                                |
          v                                |
    Writer Agent                           |
    (+/document)                           |
          |                                |
          v                                v
        Docs                           COMPLETE

(+/skill) = Agent has skill content injected via skills: frontmatter
```

## Workflow Depth Selection

| Depth | Use Case | Stages |
|-------|----------|--------|
| **FULL** | New product, complex system | spec -> design -> plan -> implement -> validate -> deploy -> document |
| **MEDIUM** | Feature from roadmap | spec -> plan -> implement -> validate |
| **LIGHT** | Small change, bug fix | plan -> implement |
