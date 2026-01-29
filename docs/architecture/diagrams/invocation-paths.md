# Skill-Agent Invocation Paths

```
+==========================================================================+
|                    TWO INVOCATION PATHS                                   |
|                  (Both spawn agent, both fire hooks)                     |
+==========================================================================+

PATH 1: DIRECT SKILL INVOCATION        PATH 2: ORCHESTRATED INVOCATION
(User -> Skill -> Agent)                 (User -> Orchestrator -> Agent)

User: /spec "todo app"                 User: /orchestrate "todo app"
        |                                      |
        v                                      v
+-------------------+              +-------------------+
| /spec SKILL.md    |              | /orchestrate SKILL|
| context: fork     |              | (runs inline)     |
| agent: BA         |              +---------+---------+
+---------+---------+                        |
          |                                  |
          | Claude Code sees                 | Task tool call
          | context:fork, spawns             | (subagent_type: BA)
          | agent, INJECTS skill             |
          v                                  v
+-------------------+              +-------------------+
| BA AGENT          |              | BA AGENT          |
| (skill content    |              | skills: [spec]    |
|  injected via     |              | (skill content    |
|  context:fork)    |              |  loaded via list) |
+---------+---------+              +---------+---------+
          |                                  |
          | Executes with                    | Executes with
          | injected instructions            | injected instructions
          v                                  v
+-------------------+              +-------------------+
| PRD artifact      |              | PRD artifact      |
| + SubagentStop    |              | + SubagentStop    |
|   hooks fire      |              |   hooks fire      |
+-------------------+              +-------------------+

KEY INSIGHT: Both paths spawn agent, both fire hooks. Skill is single source of truth.
             Injection mechanism differs: context:fork vs skills: frontmatter.
```

## Related

- [ADR-004: Skill-Agent Invocation Paths](../adr/004-skill-agent-invocation-paths.md)
