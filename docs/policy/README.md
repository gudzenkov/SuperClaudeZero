# Project-Local Policies

This directory contains project-specific policies that supplement (not replace) global policies in `~/.claude/policy/`.

## Policy Hierarchy

```
~/.claude/policy/         # Global (from SCZ)
├── PRINCIPLES.md         # SW engineering principles
├── RULES.md              # Behavioral rules
└── GUIDELINES.md         # User guidance

docs/policy/              # Project-local (this directory)
├── PRINCIPLES.md         # Project-specific principles
├── RULES.md              # Project-specific rules
└── GUIDELINES.md         # Project-specific user guidance
```

## When to Use

Add project-local policies when:
- Project has unique conventions not covered by global policies
- Team has agreed on project-specific practices
- Domain-specific rules apply (e.g., healthcare, finance)

## Policy Types

| File | Purpose | Example |
|------|---------|---------|
| `PRINCIPLES.md` | Core beliefs guiding decisions | "Prefer composition over inheritance" |
| `RULES.md` | Actionable constraints | "All API endpoints must validate input" |
| `GUIDELINES.md` | Recommended practices | "Use /spec before major features" |

## Loading Order

1. Global policies loaded first
2. Project-local policies supplement/override

Project policies take precedence for conflicts.
