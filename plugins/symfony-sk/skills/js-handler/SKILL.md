---
name: symfony-sk:js-handler
description: Create JavaScript handlers for pages. Use for DOM interactions and API calls.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# JavaScript Handler Skill

## Mission

Create JavaScript handlers following the project's strict standards.

---

## Location

`front/public/site/js/<feature>/<name>.js`

---

## Standards

**MANDATORY: Read and apply ALL rules from:**

`.claude/rules/javascript-standards.md`

---

## Quick Reference

1. **IIFE** - `(function() { 'use strict'; ... })();`
2. **No `var`** - `const` default, `let` if reassignment
3. **Declare locally** - Variables closest to usage
4. **Assertions** - Validate at function entry, throw explicit errors
5. **Max 60 lines** - Per function
6. **Check returns** - `response.ok`, null, undefined
7. **No empty catch** - Log with context or re-throw
8. **No mutation** - Return new objects
9. **Object mapping** - Over `switch` when possible
10. **Bounded loops** - Prefer `map`/`filter`/`reduce`

---

## Translations

```javascript
// Twig: {{ ['key1', 'key2'] | tradJS }}
// JS: window.trad.key1
```

---

## Checklist

See `.claude/rules/javascript-standards.md` for complete checklist.
