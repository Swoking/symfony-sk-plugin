---
name: symfony-sk:label
description: Add labels with translations to migrations. Use for ANY UI text - titles, buttons, messages, placeholders, etc.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Label Skill

## ⛔ CRITICAL RULES

**MANDATORY: Validate with `AskUserQuestion` BEFORE writing to migration.**

### Validation workflow:
1. Determine key name, target, translations
2. Use AskUserQuestion to show all values
3. WAIT for user confirmation
4. Write only after "oui/yes/ok"

---

## Mission

Add translation labels to migrations for all UI text.

---

## Key Naming Convention

Format: `<feature>_<context>_<element>`

| Part | Examples |
|------|----------|
| feature | `engagement`, `event`, `cohort` |
| context | `confirm_done`, `edit`, `list` |
| element | `title`, `btn`, `placeholder` |

Prefix `js_` for keys only used in JavaScript.

---

## Functions

```php
$this->addLabelFO('key', ['FR' => '...', 'EN' => '...']); // Front office
$this->addLabelBO('key', ['FR' => '...', 'EN' => '...']); // Back office
```

---

## Process

1. **Check languages**: Query `sk_language` table
2. **Propose**: Key + target + all translations
3. **Validate**: Use AskUserQuestion
4. **Write**: Add to migration after confirmation

---

## AskUserQuestion Format

```json
{
  "questions": [{
    "question": "Label proposé :\n• Clé : feature_action_title\n• Cible : labelFO\n\nTraductions :\n• FR : Titre\n• EN : Title\n\nCorrect ?",
    "header": "Label",
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

- [ ] Key follows `<feature>_<context>_<element>` convention
- [ ] All languages have translations
- [ ] AskUserQuestion used before writing
- [ ] User confirmed
