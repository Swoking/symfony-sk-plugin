---
name: ticket-planning
description: Plan and structure ticket/issue implementation. Creates organized plans in .claude/ticket/ with vertical slice steps.
model: sonnet
---

# Ticket Planning Agent

Plan ticket implementations using vertical slice steps.

## ⚠️ Step 0: Verify Configuration

**BEFORE starting planning**, invoke the `symfony-sk:check-config` skill to ensure project is configured.

```
Skill: symfony-sk:check-config
```

If config is missing, the skill will ask the user for information.
If user cancels, STOP and inform that configuration is required.

---

## Mission

1. Understand ticket requirements
2. Create folder `.claude/ticket/<number>-<desc>/`
3. Plan implementation as vertical slices
4. Write summary.md and step-XX-*.md files
5. Validate with user

## Vertical Slice Philosophy

**A step is a COMPLETE functional slice, NOT a micro-task.**

❌ WRONG:
```
step-01: Add translation keys
step-02: Add DTO
step-03: Add error codes
```

✅ CORRECT:
```
step-01: Create form (DTO + migration: labels + form + error codes)
step-02: Create API (actions + services + migration: security)
step-03: Create front (routes + services + migration: security)
step-04: Create UI (templates + JS + migration: labels)
```

## Folder Structure

```
.claude/ticket/<ticket-number>-<short-description>/
├── summary.md
├── step-01-<name>.md
├── step-02-<name>.md
└── ...
```

## summary.md Template

```markdown
# Ticket #<number> - <title>

## Description
<Brief description>

## Progress
| Step | Description | Status |
|------|-------------|--------|
| 01 | ... | ⏳ À faire |

## Status: ⏳ À faire | 🔄 En cours | ✅ Terminé | ❌ Bloqué
```

## step-XX-*.md Template

```markdown
# Step XX - <Title>

## Objective
<What this step accomplishes>

## Files to Create/Modify
- `path/to/file.php` - <description>

## Skills to Use
- `/labels` - For translation keys
- `/error-codes` - For error codes (via vm-commands DB query)
- `/autoforms` - For form declaration
- `/api-action`, `/api-service`, `/api-dto` - For API layer
- `/front-route`, `/front-service` - For Front layer
- `/twig-template`, `/js-handler`, `/css-component` - For UI

## Migration Changes
- Labels: <keys to add>
- Error codes: <codes to add>
- Security: <zones/controllers>

## Checklist
- [ ] Files created
- [ ] Migration updated
- [ ] Tested
```

## Workflow

1. Ask for ticket number and description
2. Analyze requirements (form? API? UI?)
3. Plan vertical slices
4. Use AskUserQuestion to validate plan
5. Create files
