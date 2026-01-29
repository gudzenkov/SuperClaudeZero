# What SCZ Provides vs Claude Code Native

## SCZ Provides (Configuration)

```
+==========================================================================+
|              SCZ PROVIDES (Configuration)                                 |
+==========================================================================+
|                                                                          |
|  SKILLS (.claude/skills/)        AGENTS (.claude/agents/)               |
|  +------------------------+      +------------------------+             |
|  | spec/SKILL.md          |      | business-analyst.md    |             |
|  | design/SKILL.md        |      | architect.md           |             |
|  | plan/SKILL.md          |      | project-manager.md     |             |
|  | implement/SKILL.md     |      | developer.md           |             |
|  | validate/SKILL.md      |      | validator.md           |             |
|  | deploy/SKILL.md        |      | deployer.md            |             |
|  | document/SKILL.md      |      | tech-writer.md         |             |
|  | orchestrate/SKILL.md   |      +------------------------+             |
|  | reflexion/SKILL.md     |                                             |
|  | reflect/SKILL.md       |      HOOKS (.claude/hooks/scripts/)         |
|  | optimize/SKILL.md      |      +------------------------+             |
|  | analyse/SKILL.md       |      | inject-context.sh      |             |
|  | research/SKILL.md      |      | remind-validate.sh     |             |
|  | distill/SKILL.md      |      | remind-reflexion.sh    |             |
|  +------------------------+      | checkpoint-session.sh  |             |
|                                   +------------------------+             |
|                                                                          |
|  POLICY (global/policy/)         WORKFLOWS (global/workflows/)          |
|  +------------------------+      +------------------------+             |
|  | RULES.md               |      | SWE |             |
|  | PRINCIPLES.md          |      | meta-learning|            |
|  +------------------------+      +------------------------+             |
|                                                                          |
+==========================================================================+
```

## Claude Code Provides (Native Runtime)

```
+==========================================================================+
|              CLAUDE CODE PROVIDES (Native Runtime)                        |
+==========================================================================+
|                                                                          |
|  SKILL ROUTING                   AGENT SPAWNING                         |
|  +------------------------+      +------------------------+             |
|  | /skill -> SKILL.md      |      | Task tool with         |             |
|  | (automatic dispatch)   |      | subagent_type param    |             |
|  +------------------------+      +------------------------+             |
|                                                                          |
|  HOOK EXECUTION                  SESSION MANAGEMENT                     |
|  +------------------------+      +------------------------+             |
|  | SessionStart, Stop     |      | JSONL logs             |             |
|  | SubagentStop           |      | Session context        |             |
|  | (runs configured cmds) |      | Project isolation      |             |
|  +------------------------+      +------------------------+             |
|                                                                          |
+==========================================================================+
```

## Summary

| Component | Provider | Description |
|-----------|----------|-------------|
| Skill routing (`/skill` -> SKILL.md) | **Claude Code** | Native skill dispatch |
| Task tool (subagent spawning) | **Claude Code** | Native agent invocation |
| Hook execution | **Claude Code** | Native lifecycle events |
| Skill definitions (SKILL.md files) | **SCZ** | Instructions for each skill |
| Agent definitions (.md files) | **SCZ** | Thin wrappers with skills injected |
| Hook scripts (.sh files) | **SCZ** | Reminder scripts for validation/learning |
| Workflows (templates) | **SCZ** | Agent orchestration patterns |
| Policy (rules, principles) | **SCZ** | Behavioral guidelines |
