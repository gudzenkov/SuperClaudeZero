# Orchestrated Workflow Sequence

```
/ORCHESTRATE         BA AGENT (with /spec injected)                  HOOKS
     |                   |                                             |
     | Assess: FULL      |                                             |
     | workflow needed   |                                             |
     |                   |                                             |
     | Task tool         |                                             |
     | (subagent: BA)    |                                             |
     | BA has skills:    |                                             |
     |   [spec]          |                                             |
     |------------------>|                                             |
     |                   |                                             |
     |                   | Agent spawns with /spec                     |
     |                   | content INJECTED into context               |
     |                   |                                             |
     |                   | Executes PRD generation                     |
     |                   | (using injected instructions)               |
     |                   |----+                                        |
     |                   |    |                                        |
     |                   |<---+                                        |
     |                   |                                             |
     |                   | PRD artifact created                        |
     |                   |                                             |
     |                   | Agent completes ---------------------------->|
     |                   |                                             |
     |                   |                              SubagentStop   |
     |                   |<--------------------------------------------|
     |                   |                                             |
     |                   | remind-validate.sh                          |
     |                   |---+                                         |
     |                   |   | Self-validation                         |
     |                   |<--+                                         |
     |                   |                                             |
     |                   | remind-reflexion.sh                         |
     |                   |---+                                         |
     |                   |   | Maybe /reflexion                        |
     |                   |<--+                                         |
     |                   |                                             |
     |   Result + PRD    |                                             |
     |<------------------|                                             |
     |                   |                                             |
     | Next: Task tool   |                                             |
     | (subagent: Arch)  |                                             |
     |------------------>|...                                          |
```

## Related

- [Workflow Engine](workflow-engine.md)
- [ADR-001: Hook Behavior Pattern](../adr/001-hook-reminder-pattern.md)
