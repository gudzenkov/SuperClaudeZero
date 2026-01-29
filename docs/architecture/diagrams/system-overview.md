# SuperClaudeZero System Diagrams

## High-Level Architecture

```
                                    USER
                                      |
                                      | /orchestrate, /spec, /design, etc.
                                      v
+=========================================================================+
|                      CLAUDE CODE (Native Runtime)                        |
|                                                                          |
|  Built-in capabilities (NOT SCZ components):                            |
|  - Skill routing: /skill -> ~/.claude/skills/skill/SKILL.md              |
|  - Task tool: spawns subagents with subagent_type                       |
|  - Hook execution: runs lifecycle event scripts                         |
|                                                                          |
+=========================================================================+
                                      |
          +---------------------------+---------------------------+
          |                           |                           |
          v                           v                           v
+-------------------+     +-------------------+     +-------------------+
|                   |     |                   |     |                   |
|      SKILLS       |     |      AGENTS       |     |      HOOKS        |
|  (SCZ provides)   |     |  (SCZ provides)   |     |  (SCZ provides)   |
|                   |     |                   |     |                   |
| Agent-backed (7): |     | With skills       |     | Lifecycle:        |
| spec, design,     |<--->| injected:         |     | - SessionStart    |
| plan, implement,  |     |                   |     | - SubagentStop    |
| validate, deploy, |     | BA, Architect,    |     | - Stop            |
| document          |     | PM, Developer,    |     | - SessionEnd      |
|                   |     | Validator,        |     |                   |
| Orchestration:    |     | Deployer,         |     |                   |
| orchestrate       |     | Tech Writer       |     |                   |
|                   |     |                   |     |                   |
| Utility (6):      |     | (skill content    |     |                   |
| reflexion,reflect,|     | injected, not     |     |                   |
| optimize, analyse,|     | invoked)          |     |                   |
| research, distill|     |                   |     |                   |
+-------------------+     +-------------------+     +-------------------+
          |                           |                           |
          +---------------------------+---------------------------+
                                      |
                                      v
+=========================================================================+
|                            MCP SERVERS                                   |
|  +----------------+  +----------------+  +------------------+           |
|  |    Serena      |  |   Context7     |  |   Playwright     |           |
|  | (memory, code) |  | (documentation)|  | (browser, opt)   |           |
|  +----------------+  +----------------+  +------------------+           |
+=========================================================================+
                                      |
                                      v
+=========================================================================+
|                        TARGET PROJECT REPO                               |
|  +----------------+  +----------------+  +------------------+           |
|  |  docs/         |  |  reports/      |  |  .serena/        |           |
|  |  (artifacts)   |  |  (analysis)    |  |  (transient)     |           |
|  +----------------+  +----------------+  +------------------+           |
+=========================================================================+
```

---

## Detailed Diagrams

| Diagram | Description |
|---------|-------------|
| [Invocation Paths](invocation-paths.md) | Two paths for skill-agent invocation (direct vs orchestrated) |
| [Agent-Skill Injection](agent-skill-injection.md) | How skills are injected into agent context |
| [Orchestrated Workflow](orchestrated-workflow.md) | Sequence diagram for orchestrator calling agents |
| [Workflow Engine](workflow-engine.md) | Full/Medium/Light workflow depth selection |
| [Memory System](memory-system.md) | Four-tier memory architecture (Session, Semantic, Reflexion, Transient) |
| [Hook System](hook-system.md) | Hook lifecycle flow from SessionStart to SessionEnd |
| [Agent-Skill Mapping](agent-skill-mapping.md) | Mapping of agents to skills and artifacts |
| [Installation Mapping](installation-mapping.md) | How SCZ files map to installation targets |
| [SCZ vs Native](scz-vs-native.md) | What SCZ provides vs Claude Code native capabilities |
