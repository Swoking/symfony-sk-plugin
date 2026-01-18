---
name: symfony-sk:setting
description: Add settings to sk_settings table. Use for configuration values.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Setting Skill

## ⛔ CRITICAL RULES

**MANDATORY: Validate with `AskUserQuestion` BEFORE writing to migration.**

---

## Mission

Add configuration settings to the sk_settings table.

---

## Functions

```php
// Single language setting
$this->addSetting(null, 'group', 'key', 'textValue', 0);
$this->addSetting('FR', 'group', 'key', 'textValue', 0);

// All languages at once
$this->addSkSettingsForAllLanguage('group', 'key',
    ['FR' => 'Texte FR', 'EN' => 'Text EN'],
    ['FR' => 0, 'EN' => 0]
);
```

---

## Common Groups

| Group | Usage |
|-------|-------|
| `returnCode` | Error messages |
| `labelFO` | Front office translations |
| `labelBO` | Back office translations |
| `formLabel` | Form field labels |
| Custom | Feature-specific settings |

---

## Process

1. **Identify group and key**
2. **Determine value**: Text and/or integer
3. **Check if multilingual**
4. **Validate**: Use AskUserQuestion
5. **Write**: Add to migration

---

## Checklist

- [ ] Group name is valid
- [ ] Key is unique in group
- [ ] Multilingual if needed
- [ ] AskUserQuestion used before writing
