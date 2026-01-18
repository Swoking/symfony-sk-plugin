---
name: symfony-sk:api-dto
description: Create DTOs with validation attributes for form data. Use when receiving structured input.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# API DTO Skill

## Mission

Create Data Transfer Objects with validation attributes for API input.

---

## Location

`api/src/Dto/<Feature>/<Name>Dto.php`

---

## Template

```php
<?php

namespace App\Dto\<Feature>;

use StarterKit\Attribute\Dto;
use StarterKit\Attribute\StringProperty;
use StarterKit\Attribute\IntegerProperty;
use App\Attribute\DateProperty;
use App\Attribute\TimeProperty;

#[Dto(emptyError: -XXXXX)]
final class <Name>Dto
{
    #[StringProperty(emptyError: -XXXXY, invalidError: -XXXXY, mandatory: true)]
    public ?string $title = null;

    #[DateProperty(emptyError: -XXXXZ, invalidError: -XXXXZ, mandatory: true)]
    public ?\DateTime $date = null;

    #[StringProperty(emptyError: -XXXXW, invalidError: -XXXXW, mandatory: false)]
    public ?string $description = null;
}
```

---

## Property Attributes

### From StarterKit (`StarterKit\Attribute\`)

| Attribute | PHP Type | Usage |
|-----------|----------|-------|
| `StringProperty` | `?string` | Text, lists |
| `TextareaProperty` | `?string` | Long text |
| `IntegerProperty` | `?int` | Numbers |
| `BooleanProperty` | `?bool` | Yes/No |
| `EmailProperty` | `?string` | Email validation |
| `SettingProperty` | `?string` | Dropdown from settings |

### From App (`App\Attribute\`)

| Attribute | PHP Type | Usage |
|-----------|----------|-------|
| `DateProperty` | `?\DateTime` | Date (Y-m-d) |
| `TimeProperty` | `?\DateTime` | Time (H:i) |

---

## Common Parameters

| Parameter | Description |
|-----------|-------------|
| `emptyError` | Error code when empty but mandatory |
| `invalidError` | Error code when format invalid |
| `mandatory` | Required field (true/false) |
| `hidden` | Hide in form |
| `onChange` | JS callback function name |

---

## Error Code Allocation

Use `/error-code` skill to allocate codes. Query existing codes first via **vm-executor** agent.

Convention `-XXYZZ`:
- `XX` = Feature code
- `Y` = Action index
- `ZZ` = Unique error number (not necessarily sequential, just unique in the range)

**Note**: Each DTO/form needs unique codes. If a feature already has codes `-28100` to `-28105`, the next ones could be `-28106`, `-28107`, etc.

---

## Checklist

- [ ] `#[Dto(emptyError: -XXXXX)]` on class
- [ ] Each property has attribute with error codes
- [ ] Error codes allocated via `/error-code` skill (query existing first)
- [ ] Register form via `/autoform` skill
