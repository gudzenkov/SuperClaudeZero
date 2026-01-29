# Installation Target Mapping

```
REPOSITORY                              INSTALLATION TARGETS

super-claude-zero/
|
+-- .claude/                ---------------------> ~/.claude/
|   +-- agents/                                   +-- agents/
|   |   +-- *.md            [warn if different]   |   +-- *.md
|   +-- skills/                                   +-- skills/
|   |   +-- */SKILL.md      [warn if different]   |   +-- */SKILL.md
|   +-- hooks/                                    +-- hooks/
|       +-- scripts/*.sh    [backup + overwrite]      +-- scripts/*.sh
|
+-- global/                 ---------------------> ~/.claude/
|   +-- settings.json       [patch/merge]         +-- settings.json
|   +-- policy/                                   +-- policy/
|   |   +-- RULES.md        [warn if different]   |   +-- RULES.md
|   |   +-- PRINCIPLES.md   [warn if different]   |   +-- PRINCIPLES.md
|   +-- workflows/                                +-- workflows/
|   |   +-- *.md            [warn if different]   |   +-- *.md
|   +-- templates/                                +-- templates/
|       +-- *.md            [warn if different]       +-- *.md
|
+-- project/                ---------------------> <target-project>/
    +-- settings.json       [patch/merge]         +-- .claude/settings.json
    +-- objectives/                               +-- docs/objectives/
    |   +-- *.md.template   [create only]         |   +-- *.md
    +-- knowledge/                                +-- docs/knowledge/
    |   +-- README.md       [create only]         |   +-- README.md
    +-- reports/                                  +-- reports/
        +-- */              [create only]             +-- */
```

## Installation Behavior by File Type

| File Type | Behavior |
|-----------|----------|
| `*.json` (settings, mcp) | **PATCH**: Deep merge, preserve user keys, backup first |
| `*.md` (agents, skills) | **WARN**: If exists and different, warn + create .scz copy. Don't overwrite user changes. |
| `*.sh` (hooks) | **BACKUP + OVERWRITE**: Scripts must match SCZ version. Backup to ~/.claude/backups/ |
| New files | **CREATE**: No conflict, just copy |
| `*.template` (project init) | **CREATE ONLY**: Skip if target exists. User owns these. |
