---
name: symfony-sk-labels
description: Create labels and translations for Symfony StarterKit. Use when adding ANY text in Twig templates or JavaScript files - titles, buttons, error messages, placeholders, alt text, descriptions, validation messages, tooltips, etc.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Labels & Translations

## ⛔ CRITICAL RULES - READ FIRST

**MANDATORY: You MUST use the `AskUserQuestion` tool to validate BEFORE writing ANY migration code.**

### NEVER write to migration files without user validation for:

1. **Label keys** - Always show proposed key name
2. **ALL translations** - Show translations for ALL languages in `sk_language` table
3. **Target group** - Confirm labelFO vs labelBO

### Check available languages FIRST:

```bash
ssh <project-url> "docker exec <project-code>-db psql -U <project-code> -d <project-code> -c 'SELECT code FROM sk_language ORDER BY id;'"
```

FR and EN are the minimum, but there may be more languages.

### Validation workflow:

```
1. Determine → Key name, target, translations
2. Propose → Use AskUserQuestion to show all values
3. WAIT → Do not proceed until user confirms
4. Write → Only after explicit "oui/yes/ok" from user
```

**⚠️ VIOLATION: Writing to migration without AskUserQuestion = FAILURE**

---

**ALL text in the application MUST use translation keys.** Never hardcode text directly in templates or JS.

This includes:
- Titles, headings, descriptions
- Button labels
- Form labels and placeholders
- Error and success messages
- Validation messages
- Tooltips
- Alt text
- Any string displayed to users

---

## Twig Usage

### Basic usage (default group)

```twig
{{ 'my_translation_key' | cache }}
```

The `cache` filter automatically uses:
- `labelFO` group in **front** container
- `labelBO` group in **back** container

### Custom settings group

```twig
{{ 'asset_logo' | cache('assetAlt') }}
{{ 'january' | cache('month') }}
```

---

## JavaScript Usage

For text needed in JS files, use the `tradJS` filter in a Twig block:

```twig
{% block jsImport %}
    {{ ['engagement_confirm_title', 'engagement_confirm_cancel'] | tradJS }}
{% endblock %}
```

This populates `window.trad` object:
```javascript
// In JS, access translations via:
window.trad.engagement_confirm_title
```

### Where to place jsImport

Place `jsImport` in the template where the JS element will be used/positioned.

If the same key is added in multiple templates, it's fine - the value will just be overwritten with the same translation. No performance issue.

### With custom settings group

```twig
{% block jsImport %}
    {{ [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] | tradJS('month') }}
    {{ [0, 1, 2, 3, 4, 5, 6] | tradJS('day') }}
{% endblock %}
```

---

## Key Naming Convention

Format: `<feature>_<context>_<element>`

| Part | Description | Examples |
|------|-------------|----------|
| `feature` | Application feature | `engagement`, `event`, `cohort`, `path` |
| `context` | Where it's used | `confirm_done`, `edit_deadline`, `list`, `popin` |
| `element` | What it is | `title`, `description`, `submit_btn`, `cancel_btn`, `placeholder` |

### JS-specific keys

Prefix with `js_` for keys exclusively used in JavaScript:

```
js_engagement_edit_deadline_step1_question
```

---

## Available Settings Groups

| Group | Usage |
|-------|-------|
| `labelFO` | Front office text (default in front) |
| `labelBO` | Back office text (default in back) |
| `month` | Month names (keys: 1-12) |
| `day` | Day names (keys: 0-6, 0=Sunday) |
| `assetAlt` | Asset alt text |
| `language` | Language names |
| `profile` | User profile names |
| `returnCode` | Error code messages (usually from API) |

**Note**: Any group in `sk_settings` table can be used for labels.

---

## Checking if a Key Exists

To verify if a label key already exists, use the **VM Commands Agent** to query the database:

```sql
SELECT keyname, textvalue
FROM sk_settings
WHERE groupname = '<group>'
AND keyname = '<key>';
```

Example for labelFO:
> "Execute database query: SELECT keyname, textvalue FROM sk_settings WHERE groupname='labelFO' AND keyname='engagement_confirm_done_title';"

**Important**: The `groupname` varies depending on where the label is used:
- `labelFO` for front office
- `labelBO` for back office
- Other groups as needed (`month`, `day`, etc.)

---

## Adding Labels to Migration

**Use the Labels Agent** to add translations to migrations.

The agent will:
1. Propose a key following the naming convention
2. Generate FR/EN translations
3. **Use AskUserQuestion for validation**
4. Add to the specified migration only after confirmation

### ⚠️ ALWAYS Validate with AskUserQuestion

**Before writing ANY label to migration, use AskUserQuestion:**

```json
{
  "questions": [{
    "question": "Label proposé :\n• Clé : engagement_confirm_done_title\n• Cible : labelFO\n\nTraductions :\n• FR : Confirmer la complétion\n• EN : Confirm completion\n\nCes valeurs sont-elles correctes ?",
    "header": "Label",
    "options": [
      {"label": "Oui, valider", "description": "La clé et les traductions sont correctes"},
      {"label": "Modifier la clé", "description": "Changer le nom de la clé"},
      {"label": "Modifier FR", "description": "Changer la traduction française"},
      {"label": "Modifier EN", "description": "Changer la traduction anglaise"}
    ],
    "multiSelect": false
  }]
}
```

**⛔ NEVER write to migration file WITHOUT using AskUserQuestion first.**

### How to call the agent

> "Add a label for the engagement completion modal title. Migration: Version20260115120000"

Or for multiple labels:

> "Add labels for the engagement confirmation modal (title, description, confirm button, cancel button). Migration: Version20260115120000"

### Migration Functions Reference

```php
// Front office (labelFO group)
$this->addLabelFO('key', ['FR' => '...', 'EN' => '...']);

// Back office (labelBO group)
$this->addLabelBO('key', ['FR' => '...', 'EN' => '...']);
```

---

## Checklist

Before considering labels complete:

- [ ] ALL text uses `{{ 'key' | cache }}`
- [ ] JS text uses `tradJS` filter in `jsImport` block (in template where element is used)
- [ ] Labels added via **Labels Agent** (validated before writing)
- [ ] FR translation provided
- [ ] EN translation provided
- [ ] Key follows naming convention: `<feature>_<context>_<element>`
- [ ] Migration executed via VM agent: `./scripts/dme <VersionName>`
