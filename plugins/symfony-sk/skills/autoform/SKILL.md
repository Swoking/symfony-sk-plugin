---
name: symfony-sk:autoform
description: Declare AutoForms in migrations. Use when registering form keys and field labels.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# AutoForm Skill

## ⛔ CRITICAL RULES

**MANDATORY: Validate with `AskUserQuestion` BEFORE writing to migration.**

---

## Mission

Register AutoForm declarations and field labels in migrations.

---

## Functions

```php
// Register form
$this->addAutoform('FormKey', FullDtoClass::class);

// Add field labels
$this->addAutoformLabel('DtoClassName_propertyName', [
    'FR' => 'Label français',
    'EN' => 'English label',
]);
```

---

## Label Key Format

`<DtoClassName>_<propertyName>`

Example: `EventCreateDto_title`, `EventCreateDto_date`

---

## Process

1. **Identify DTO**: Name and properties
2. **Generate labels**: For each property
3. **Validate**: Use AskUserQuestion for all labels
4. **Write**: Add to migration

---

## Example Migration

```php
// Register form
$this->addAutoform('EventCreate', EventCreateDto::class);

// Field labels
$this->addAutoformLabel('EventCreateDto_title', [
    'FR' => 'Titre',
    'EN' => 'Title',
]);

$this->addAutoformLabel('EventCreateDto_date', [
    'FR' => 'Date',
    'EN' => 'Date',
]);
```

---

## Checklist

- [ ] Form registered with `addAutoform()`
- [ ] All properties have labels
- [ ] Label keys follow `DtoClassName_propertyName`
- [ ] All languages have translations
- [ ] AskUserQuestion used before writing
