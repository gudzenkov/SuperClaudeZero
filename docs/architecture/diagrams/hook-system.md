# Hook System Flow

```
SESSION START
      |
      v
+------------------+
| SessionStart     |
| Hook             |
| (non-blocking)   |
+--------+---------+
         |
         | inject-context.sh
         v
+------------------+
| Inject:          |
| - PROJECT_NAME   |
| - SESSION_ID     |
+------------------+
         |
         v
   [Session runs]
         |
         v
+------------------+
| Orchestrator     |
| calls agents     |
| via Task tool    |
+--------+---------+
         |
         | Agent has skill injected
         v
+------------------+
| Agent executes   |
| produces artifact|
+--------+---------+
         |
         | Agent completes
         v
+------------------+
| SubagentStop     |
| Agent hooks      |
+--------+---------+
         |
         | remind-validate.sh
         | remind-reflexion.sh
         v
+------------------+
| <system-reminder>|
| Validation list  |
| Reflexion prompt |
+--------+---------+
         |
         | Agent responds
         v
+------------------+
| Self-validate    |
| Maybe /reflexion |
+------------------+
         |
         v
   [Orchestrator continues
    with next agent...]
         |
         v
   [Claude finishes responding]
         |
         v
+------------------+
| Stop Hook        |
| settings.json    |
| (BLOCKING)       |
+--------+---------+
         |
         | remind-reflect.sh
         v
+------------------+
| <system-reminder>|
| Session reflect  |
| checklist        |
+--------+---------+
         |
         | Orchestrator may
         | invoke /reflect
         v
+------------------+
| Session learnings|
| captured         |
+------------------+
         |
         v
   [Session closes]
         |
         v
+------------------+
| SessionEnd Hook  |
| settings.json    |
| (NON-BLOCKING)   |
+--------+---------+
         |
         | checkpoint-session.sh
         v
+------------------+
| Cleanup & log:   |
| - session_id     |
| - cwd            |
| - statistics     |
+------------------+
         |
         v
   SESSION END
```

**Important**: Stop != SessionEnd
- **Stop**: Claude finishes responding (CAN block, CAN invoke skills)
- **SessionEnd**: Session closes (CANNOT block, cleanup only)

## Related

- [ADR-001: Hook Behavior Pattern](../adr/001-hook-reminder-pattern.md)
