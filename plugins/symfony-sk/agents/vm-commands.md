---
name: vm-commands
description: Execute commands on the project VM via SSH. Use for running scripts, migrations, cache clear, rebuild containers, or any command that must run on the remote server.
model: haiku
---

# VM Commands Agent

Execute commands on the project's remote VM.

## ⚠️ Step 0: Verify Configuration

**BEFORE executing any command**, invoke the `symfony-sk:check-config` skill to ensure project is configured.

```
Skill: symfony-sk:check-config
```

If config is missing, the skill will ask the user for information.
If user cancels, STOP and inform that configuration is required.

---

## Configuration

Read from `$CLAUDE_PROJECT_DIR/.claude/project.json`:

```json
{
  "code": "project-code",
  "ssh": { "host": "hostname" }
}
```

## Command Pattern

```bash
ssh <host> ". /sk/sk.lib && . /sk/sk_switchProject <code> && ${skv___projectPath}/scripts/<script>"
```

**Variables after `sk_switchProject`:**
- `${skv___projectPath}` - Project root
- `${skv___project}` - Project code

## Available Scripts

| Script | Args | Description |
|--------|------|-------------|
| `dmm` | - | Execute pending migrations |
| `dmg` | - | Generate new migration |
| `dme` | `<Version>` | Re-execute specific migration |
| `cc` | `all` | Clear all caches |

## Container Commands

```bash
# Method 1: go script
ssh <host> ". /sk/sk.lib && . /sk/sk_switchProject <code> && ${skv___projectPath}/scripts/go <container> -e '<cmd>'"

# Method 2: docker exec (complex commands)
ssh <host> "docker exec --workdir /var/www/html/<container> <code>-<container> <command>"
```

| Container | Workdir |
|-----------|---------|
| api | /var/www/html/api |
| front | /var/www/html/front |
| back | /var/www/html/back |
| db | - |

## Database Query

```bash
ssh <host> "docker exec <code>-db psql -U <code> -d <code> -c '<SQL>'"
```

---

## ⚠️ Interactive Shell Errors

Some scripts use `go` which runs `docker exec -it` (interactive flag) but don't actually need it.

**When you get an error about interactive terminal / TTY:**

1. **Read the error message** to understand what command was being run
2. **Try executing the command directly** using `docker exec` without `-it`:
   ```bash
   ssh <host> "docker exec --workdir /var/www/html/<container> <code>-<container> <command>"
   ```
3. **If it still fails**, ask the user to run it manually
