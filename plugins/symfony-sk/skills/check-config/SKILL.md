---
name: symfony-sk:check-config
description: Verify project configuration before using other skills/agents. Creates .claude/project.json if missing.
allowed-tools: Read, Write, Edit, Glob, AskUserQuestion
user-invocable: false
---

# Check Config Skill

## Mission

Verify that the project is properly configured for Symfony StarterKit plugin. This skill is called automatically by agents before they start their work.

---

## Verification Steps

### 1. Check if `.claude/project.json` exists

```bash
# File should exist at project root
.claude/project.json
```

### 2. If missing, gather information

Use `AskUserQuestion` to collect:

```json
{
  "questions": [
    {
      "question": "Quel est le code du projet ? (préfixe des containers Docker, ex: kotchi, myproject)",
      "header": "Code projet",
      "options": [
        {"label": "Entrer le code", "description": "Je vais saisir le code du projet"}
      ],
      "multiSelect": false
    },
    {
      "question": "Quelle est l'URL/hostname de la VM du projet ? (ex: kotchi2, myproject.dev)",
      "header": "URL VM",
      "options": [
        {"label": "Pas de VM", "description": "Développement local uniquement"},
        {"label": "Entrer l'URL", "description": "Je vais saisir l'URL de la VM"}
      ],
      "multiSelect": false
    },
    {
      "question": "Le projet a-t-il un back office ?",
      "header": "Back office",
      "options": [
        {"label": "Oui", "description": "Le projet a front + back office"},
        {"label": "Non", "description": "Uniquement front office"}
      ],
      "multiSelect": false
    }
  ]
}
```

### 3. Create `.claude/project.json`

After collecting answers, create the file:

```json
{
  "projectCode": "<user-provided-code>",
  "projectUrl": "<user-provided-url-or-null>",
  "hasBack": true|false,
  "ssh": {
    "host": "<projectUrl>",
    "password": "<ask-if-needed>"
  }
}
```

### 4. Verify required fields

| Field | Required | Description |
|-------|----------|-------------|
| `projectCode` | Yes | Docker container prefix |
| `projectUrl` | No | SSH hostname (null if local) |
| `hasBack` | Yes | Boolean for back office |

---

## Return Values

After verification, return the config for the calling agent:

```
CONFIG_OK:
- projectCode: <code>
- projectUrl: <url>
- hasBack: <true/false>
```

Or if user cancels:

```
CONFIG_CANCELLED: User declined to configure project
```

---

## Usage by Agents

Agents should call this skill at the start:

```markdown
## Step 0: Verify Configuration

Before starting, invoke the `symfony-sk:check-config` skill to ensure project is configured.

If config is missing, the skill will ask the user for information.
If user cancels, STOP and inform user that configuration is required.
```

---

## SSH Configuration (Optional)

If `projectUrl` is provided and SSH is needed:

1. Check if `.claude/project.json` has `ssh.password`
2. If missing, ask user for SSH password
3. Store in project.json (this file should be in .gitignore)

---

## Checklist

- [ ] `.claude/project.json` exists
- [ ] `projectCode` is set
- [ ] `hasBack` is set (boolean)
- [ ] If remote VM: `projectUrl` is set
