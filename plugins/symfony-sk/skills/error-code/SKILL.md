---
name: symfony-sk:error-code
description: Add error codes with translations to migrations. Use for validation errors and service errors.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Error Code Skill

## ⛔ CRITICAL RULES

**MANDATORY: Validate with `AskUserQuestion` BEFORE writing to migration.**

---

## Mission

Add return codes to migrations for form validation and service errors.

---

## Code Convention: `-XXYZZ`

| Part | Meaning |
|------|---------|
| XX | Feature (e.g., 28 = Event) |
| Y | Action (1=create, 2=read, 3=update, 4=delete, 5+=partial) |
| ZZ | Error index (00=form empty, 01-99=specific) |

Example: `-28105` = Event feature, create action, error #5

---

## Process

1. **Check cache** for feature codes
2. **Query DB** if cache missing/stale (via vm-commands)
3. **Update cache** with results
4. **Find next available** code in action range
5. **Generate translations**
6. **Validate**: Use AskUserQuestion
7. **Write**: Add to migration
8. **Update cache** with new code

---

## Function

```php
$this->addReturnCode(-28105, [
    'FR' => 'Titre requis',
    'EN' => 'Title required',
]);
```

---

## Identify Feature Code

Determine the feature code (XX in -XXYZZ) from:

1. **Current migration** - Look for existing `-XXxxx` codes
2. **DTO/Controller name** - `EventCreateDto` → search Event codes
3. **User context** - "pour engagement" → search engagement codes
4. **DB query** - Find which XX is used for this domain

---

## Cache Mechanism

Cache file: `$CLAUDE_PROJECT_DIR/.claude/cache/error-codes.json`

```json
{
  "updated": "2026-01-18T14:30:00Z",
  "codes": {
    "-28100": "Event - Form empty",
    "-28101": "Event - Title required",
    "-30100": "Engagement - Form empty"
  }
}
```

### Usage

1. **Read cache** before proposing new code
2. **Query DB** if cache missing or > 1 hour old
3. **Update cache** after DB query
4. **Add new code** to cache after creation

This avoids proposing duplicate codes.

---

## Query Existing Codes

**Use the `vm-commands` agent to run DB queries:**

```sql
-- All codes for a feature (XX = 28)
SELECT keyname FROM sk_settings
WHERE groupname='returnCode' AND keyname LIKE '-28%'
ORDER BY keyname;

-- All codes (for full cache)
SELECT keyname, textvalue FROM sk_settings
WHERE groupname='returnCode'
ORDER BY keyname;
```

The VM agent executes via SSH on the project VM.

---

## AskUserQuestion Format

```json
{
  "questions": [{
    "question": "Code proposé : -28105\n\nTraductions :\n• FR : Titre requis\n• EN : Title required\n\nCorrect ?",
    "header": "Code",
    "options": [
      {"label": "Oui, valider", "description": "Correct"},
      {"label": "Modifier", "description": "Changer"}
    ],
    "multiSelect": false
  }]
}
```

---

## Checklist

- [ ] Searched existing codes first
- [ ] Code follows -XXYZZ convention
- [ ] All languages have translations
- [ ] AskUserQuestion used before writing
