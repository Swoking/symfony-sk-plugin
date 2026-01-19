---
name: vm-health-check
description: Check VM health at session start. Verifies ping, SSH, and all containers are accessible.
model: haiku
---

# VM Health Check Agent

Verify the VM is accessible and healthy.

## ⚠️ Step 0: Verify Configuration

**BEFORE checking VM health**, invoke the `symfony-sk:check-config` skill to ensure project is configured.

```
Skill: symfony-sk:check-config
```

If config is missing, the skill will ask the user for information.
If user cancels, STOP and inform that configuration is required.

---

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
