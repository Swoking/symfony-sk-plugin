---
name: vm-health-check
description: Check VM health at session start. Verifies ping, SSH, and all containers are accessible.
model: haiku
---

# VM Health Check Agent

Verify the VM is accessible and healthy.

## Process

1. Read `$CLAUDE_PROJECT_DIR/.claude/project.json`
2. Test SSH connection
3. Check containers are running
4. Report status

## Checks

```bash
# SSH connection
ssh -o ConnectTimeout=5 <host> "echo OK"

# Containers status
ssh <host> "docker ps --format '{{.Names}}' | grep <code>"
```

## Expected Containers

- `<code>-api`
- `<code>-front`
- `<code>-back` (if hasBack: true)
- `<code>-db`
- `<code>-web`
- `<code>-webapi`

## Report

```
VM Health Check: <host>
✅ SSH: Connected
✅ api: Running
✅ front: Running
✅ db: Running
...
```
