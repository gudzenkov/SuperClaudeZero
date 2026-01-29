# Agent-Skill Mapping

```
+==========================================================================+
|                      AGENT-SKILL RELATIONSHIPS                            |
+==========================================================================+

ORCHESTRATION: Calls agents via Task tool, agents have skills injected

+-------------+     Task tool    +-------------+     skills: [...]
| /orchestrate| ---------------> |   Agents    | ---------------> (injected)
+-------------+                  +-------------+


AGENT-BACKED SKILLS: Skill content injected into agent

+-------------+   has injected   +-------------+     produces
|  BA Agent   | <--------------- |   /spec     | ---------------> PRD
+-------------+                  +-------------+

+-------------+   has injected   +-------------+     produces
| Arch Agent  | <--------------- |   /design   | ---------------> Architecture
+-------------+                  +-------------+

+-------------+   has injected   +-------------+     produces
|  PM Agent   | <--------------- |   /plan     | ---------------> Tasks
+-------------+                  +-------------+

+-------------+   has injected   +-------------+     produces
|  Dev Agent  | <--------------- |  /implement | ---------------> Code
+-------------+                  +-------------+

+-------------+   has injected   +-------------+     produces
|  Val Agent  | <--------------- |  /validate  | ---------------> Report
+-------------+                  +-------------+

+-------------+   has injected   +-------------+     produces
|Deploy Agent | <--------------- |   /deploy   | ---------------> CI/CD
+-------------+                  +-------------+

+-------------+   has injected   +-------------+     produces
|Writer Agent | <--------------- |  /document  | ---------------> Docs
+-------------+                  +-------------+


EXTENDED SKILLS (spawn Architect agent with a secondary skill)

+-------------+    context:fork   +-------------+
| /analyse    | ----------------> |  Architect  |
| /research   |    agent: arch    |  (+ /design)|
+-------------+                   +-------------+


UTILITY SKILLS (inline, no agent spawn)

+-------------+                  +-------------+
| /reflexion  | ----------------> |   Serena    |
| /reflect    |   (direct)       |   Memory    |
| /optimize   |                  +-------------+
| /distill    |
+-------------+
```

## Multi-Skill Model

| User Action | Agent | Skills Injected |
|-------------|-------|-----------------|
| `/design "auth"` | Architect | /design only |
| Orchestrator -> Task(architect) | Architect | /design (from `skills:`) |
| `/analyse "patterns"` | Architect | /design (primary) + /analyse (secondary) |

## Related

- [ADR-004: Skill-Agent Invocation Paths](../adr/004-skill-agent-invocation-paths.md)
