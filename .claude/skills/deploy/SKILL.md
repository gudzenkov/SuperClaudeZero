---
name: deploy
description: Build and deploy project artifacts to target environment
argument-hint: [environment] [--dry-run]
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Bash
context: fork
agent: deployer
---

# /deploy - Build and Deployment

Build and deploy project artifacts to target environment.

## Purpose

Manage releases by:
- Building production artifacts
- Deploying to environments
- Verifying deployment success
- Documenting release

## Inputs

- `$ARGUMENTS`: Target environment or --dry-run flag
- Validated code (prerequisite: /validate passed)
- `${PROJECT_NAME}`: Current project context

## Outputs

- Build artifacts
- Deployment record (Serena memory)
- Updated version/changelog if applicable

## Prerequisites

Before deploying:
1. All tests pass (`/validate` completed)
2. No blocking issues
3. Version bumped (if release)
4. Changelog updated (if release)

## Workflow

### 1. Verify Prerequisites
Check that validation passed:
- Look for recent validation report
- Confirm no blocking issues
- If prerequisites not met, stop and report

### 2. Determine Target
Parse `$ARGUMENTS`:
- `dev` / `development`: Development environment
- `staging`: Staging environment
- `prod` / `production`: Production (extra caution)
- `--dry-run`: Simulate without deploying

### 3. Build
Execute build commands:
```bash
# Common patterns
npm run build
make build
go build ./...
docker build -t app .
```

Verify build succeeds.

### 4. Stage (if applicable)
Prepare deployment package:
- Bundle artifacts
- Set environment config
- Prepare manifests

### 5. Deploy
Execute deployment:
```bash
# Examples (project-specific)
npm publish
docker push
kubectl apply -f deploy/
./deploy.sh [env]
```

**Note**: For production, require explicit user approval.

### 6. Verify Deployment
Check deployment success:
- Health check endpoints
- Smoke tests
- Service status

### 7. Document
Create deployment record:

```yaml
---
date: YYYY-MM-DD
time: HH:MM:SS
version: X.Y.Z
environment: [environment]
status: success | failed | rolled-back
deployed_by: deployer-agent
---

## Deployment Summary
- **Project**: ${PROJECT_NAME}
- **Version**: X.Y.Z
- **Environment**: [target]
- **Duration**: [time]

## Build
- Artifacts: [list]
- Size: [size]
- Hash: [hash]

## Steps Executed
1. [Step with result]
2. [Step with result]

## Verification
- [ ] Build successful
- [ ] Deployment complete
- [ ] Health check passing
- [ ] Smoke tests passed

## Rollback Info
If rollback needed:
- Previous version: X.Y.Z-1
- Rollback command: [command]

## Notes
[Observations or issues]
```

## Safety Measures

### Dry Run
Always available: `--dry-run` simulates without changes.

### Approval Gates
- Production deployments require user approval
- Destructive operations prompt for confirmation

### Rollback Plan
Before deploying:
- Note current version
- Document rollback procedure
- Test rollback if possible

## Environment Handling

| Environment | Approval | Verification |
|-------------|----------|--------------|
| dev | None | Basic |
| staging | None | Full |
| prod | Required | Full + Manual |

## Policy References

**Should-read** from `~/.claude/policy/RULES.md`:
- Safety Rules - Transaction-safe, systematic changes
