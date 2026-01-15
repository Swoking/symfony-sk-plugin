---
name: symfony-sk-autoforms
description: Create AutoForms for Symfony StarterKit. Use when creating forms with validation using DTOs. Covers form declaration in migrations, DTO creation with property attributes, and field labels.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# AutoForms

## ⛔ CRITICAL RULES - READ FIRST

**MANDATORY: You MUST use the `AskUserQuestion` tool to validate BEFORE writing ANY migration code.**

### NEVER write to migration files without user validation for:

1. **Form fields** - List of fields and their types
2. **Field labels** - Translations for ALL languages in `sk_language` table
3. **Error codes** - All validation error codes and messages (all languages)
4. **Mandatory fields** - Which fields are required

### Check available languages FIRST:

```bash
ssh <project-url> "docker exec <project-code>-db psql -U <project-code> -d <project-code> -c 'SELECT code FROM sk_language ORDER BY id;'"
```

FR and EN are the minimum, but there may be more languages.

### Validation workflow:

```
1. Gather info → Ask user about fields, types, mandatory
2. Propose → Use AskUserQuestion to show ALL labels + error codes
3. WAIT → Do not proceed until user confirms
4. Write → Only after explicit "oui/yes/ok" from user
```

### Required AskUserQuestion calls:

1. **Form structure**: Validate field list before creating DTO
2. **Field labels**: Validate ALL FR + EN translations
3. **Error codes**: Use Error Codes Agent (which validates via AskUserQuestion)

**⚠️ VIOLATION: Writing to migration without AskUserQuestion = FAILURE**

---

AutoForms are forms declared via DTOs with validation attributes. The form structure and validation is automatically generated from the DTO.

---

## Overview

To create an AutoForm:

1. **Create DTO** in `api/src/Dto/<Feature>/<Form>Dto.php`
2. **Declare form in migration** with `addAutoform()` and `addAutoformLabel()`
3. **Add return codes** via **Error Codes Agent**
4. **Use in API controller** via `initApiResult()`

---

## DTO Structure

### Location

```
api/src/Dto/<Feature>/<FormName>Dto.php
```

Example: `api/src/Dto/Event/EventCreateDto.php`

### Class Attribute

Every DTO must have the `#[Dto]` attribute with an `emptyError` code:

```php
<?php

namespace App\Dto\Event;

use StarterKit\Attribute\Dto;

#[Dto(emptyError: -28100)]
final class EventCreateDto
{
    // properties...
}
```

The `emptyError` is returned when the form data is completely empty/missing.

### Complete Example

```php
<?php

namespace App\Dto\Event;

use App\_Const;
use App\Attribute\DateProperty;
use App\Attribute\TimeProperty;
use DateTime;
use StarterKit\Attribute\Dto;
use StarterKit\Attribute\SettingProperty;
use StarterKit\Attribute\StringProperty;
use StarterKit\Attribute\TextareaProperty;

#[Dto(emptyError: -28100)]
final class EventCreateDto
{
    #[StringProperty(emptyError: -28102, invalidError: -28102, mandatory: true)]
    public ?string $title = null;

    #[SettingProperty(
        emptyError: -28103,
        invalidError: -28103,
        mandatory: true,
        group: _Const::GROUP_EVENT_CREATE_TYPE,
        onChange: 'onEventTypeChange'
    )]
    public ?string $type = null;

    #[DateProperty(emptyError: -28101, invalidError: -28101, mandatory: true)]
    public ?DateTime $date = null;

    #[TimeProperty(emptyError: -28104, invalidError: -28104, mandatory: true)]
    public ?DateTime $startAt = null;

    #[TimeProperty(emptyError: -28105, invalidError: -28105, mandatory: true)]
    public ?DateTime $endAt = null;

    #[TextareaProperty(emptyError: -28106, invalidError: -28106, mandatory: false)]
    public ?string $note = null;
}
```

---

## Property Attributes

### Common Parameters (all properties)

| Parameter | Type | Description |
|-----------|------|-------------|
| `emptyError` | int | Error code when field is empty but mandatory |
| `invalidError` | int | Error code when value format is invalid |
| `notFoundError` | int | Error code when value not found (lists/settings) |
| `mandatory` | bool | Is field required? Default: `false` |
| `hidden` | bool | Hide field in form? Default: `false` |
| `onChange` | string | JS callback function name on value change |
| `description` | string | Key in `formLabel` group for field description |
| `showWhenTrue` | string | Show field when another field is true |
| `showWhenFalse` | string | Show field when another field is false |
| `hideWhenTrue` | string | Hide field when another field is true |
| `hideWhenFalse` | string | Hide field when another field is false |

### Available Property Types

#### From StarterKit (`StarterKit\Attribute\`)

| Property | PHP Type | Form Type | Extra Parameters |
|----------|----------|-----------|------------------|
| `StringProperty` | `?string` | `string` or `list` | `list`, `matchPattern`, `default`, `emptyValue`, `enhancements`, `min`, `max` |
| `TextareaProperty` | `?string` | `textarea` | `default` |
| `BooleanProperty` | `?bool` | `boolean` | `default` |
| `IntegerProperty` | `?int` | `integer` | `default`, `min`, `max` |
| `FloatProperty` | `?float` | `float` | `default`, `min`, `max` |
| `EmailProperty` | `?string` | `email` | - |
| `PasswordProperty` | `?string` | `password` | `matchPattern` |
| `ConfirmPasswordProperty` | `?string` | `password` | `matchField` |
| `SettingProperty` | `?string` | `setting` | `group`, `emptyValue` |
| `AssetProperty` | `?string` | `asset` | - |
| `EntityProperty` | `?object` | `entity` | `entityClass` |
| `CKEditorProperty` | `?string` | `ckeditor` | - |
| `ArrayProperty` | `?array` | `array` | - |

#### From App (`App\Attribute\`)

| Property | PHP Type | Form Type | Format | Extra Parameters |
|----------|----------|-----------|--------|------------------|
| `DateProperty` | `?DateTime` | `date` | `Y-m-d` | `default` |
| `TimeProperty` | `?DateTime` | `time` | `H:i` | `default` |
| `DateTextDisplayProperty` | `?DateTime` | `date` | text display | `default` |

### StringProperty Enhancements

```php
#[StringProperty(
    mandatory: true,
    enhancements: ['trim', 'strtoupper']  // Applied to value
)]
public ?string $code = null;
```

Available: `trim`, `ltrim`, `rtrim`, `strtoupper`, `strtolower`, `ucwords`

### StringProperty with List (dropdown)

```php
#[StringProperty(
    mandatory: true,
    list: ['option1', 'option2', 'option3'],
    emptyValue: 'select_placeholder'  // Key in formLabel group
)]
public ?string $choice = null;
```

### SettingProperty (dropdown from settings)

```php
#[SettingProperty(
    mandatory: true,
    group: _Const::GROUP_EVENT_TYPE,  // Settings group to load options from
    onChange: 'onTypeChange'          // JS callback when value changes
)]
public ?string $type = null;
```

---

## onChange JavaScript Callbacks

When a field has `onChange: 'functionName'`, the JS function is called when the field value changes.

### Where to create the callback

Create the callback in a JS file loaded by the page template:

```javascript
// front/public/site/js/forms/EventCreateForm.js

function onEventTypeChange(value, formElement) {
    // value = new field value
    // formElement = the form DOM element

    if (value === 'meeting') {
        // Show/hide fields, update other values, etc.
        formElement.querySelector('[name="location"]').closest('.form-group').style.display = 'block';
    }
}
```

### Load the JS in the template

```twig
{% block jsImport %}
    <script src="{{ asset('site/js/forms/EventCreateForm.js') }}"></script>
{% endblock %}
```

---

## Prefilling Edit Forms

For edit forms, the front/back Route must:
1. Call API to `read()` the entity values
2. Pass the data to the template response

### Route Example

```php
#[Route("/engagement/{key}/edit-deadline/form", name: "engagement_edit_deadline_form", methods: ["GET"])]
public function editDeadlineForm(string $key, EngagementService $service): Response
{
    // 1. Read current values from API
    $result = $service->read($key);

    // 2. Pass data to template
    return $this->checkAuthorization($result, new JsonResponse([
        'code' => $result->getCode(),
        'message' => $result->getMessage(),
        'data' => $result->getData(),  // Contains current values for prefill
    ]));
}
```

### JS Form Handling

```javascript
// When opening edit form, fetch current values
fetch(`/engagement/${key}/edit-deadline/form`)
    .then(response => response.json())
    .then(result => {
        if (result.code === 0) {
            // Prefill form fields with result.data
            document.querySelector('[name="deadline"]').value = result.data.deadline;
        }
    });
```

---

## Migration Declaration

### Function Signatures

```php
// Register the autoform (form key → DTO class)
$this->addAutoform(string $name, string $dtoClass)

// Add field label (DtoClassName_propertyName → translations)
$this->addAutoformLabel(string $field, array $translations)
```

### Complete Migration Example

```php
<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use App\Dto\Event\EventCreateDto;
use App\Migrations\AppAbstractMigration;
use Doctrine\DBAL\Schema\Schema;

final class Version20260115160000 extends AppAbstractMigration
{
    public function getDescription(): string
    {
        return '#XX - Add EventCreate autoform';
    }

    public function up(Schema $schema): void
    {
        // 1. Register the autoform
        $this->addAutoform('EventCreate', EventCreateDto::class);

        // 2. Add field labels (DtoClassName_propertyName)
        $this->addAutoformLabel('EventCreateDto_title', [
            'FR' => 'Titre',
            'EN' => 'Title',
        ]);

        $this->addAutoformLabel('EventCreateDto_type', [
            'FR' => 'Type d\'événement',
            'EN' => 'Event type',
        ]);

        $this->addAutoformLabel('EventCreateDto_date', [
            'FR' => 'Date',
            'EN' => 'Date',
        ]);

        $this->addAutoformLabel('EventCreateDto_startAt', [
            'FR' => 'Heure de début',
            'EN' => 'Start time',
        ]);

        $this->addAutoformLabel('EventCreateDto_endAt', [
            'FR' => 'Heure de fin',
            'EN' => 'End time',
        ]);

        $this->addAutoformLabel('EventCreateDto_note', [
            'FR' => 'Notes',
            'EN' => 'Notes',
        ]);

        // 3. Add return codes via Error Codes Agent
        // (see Error Codes Agent for adding validation error codes)
    }
}
```

---

## Error Codes

Use the **Error Codes Agent** to add return codes for form validation errors.

The agent will:
1. Find the feature's code range (e.g., `-28XXX` for Event)
2. Determine the action range (e.g., `-281ZZ` for create)
3. Generate translations
4. Ask for validation before writing

### Example request to agent

> "Add error codes for EventCreateDto: emptyError for DTO, and errors for fields title, type, date, startAt, endAt, note. Feature: event, Action: create, Migration: Version20260115160000"

---

## API Controller Usage

The controller uses `initApiResult()` to validate and extract the DTO:

```php
<?php

namespace App\Controller\Event;

use App\Dto\Event\EventCreateDto;
use App\Service\EventService;
use StarterKit\Controller\BaseAction;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;

class EventCreateAction extends BaseAction
{
    #[Route("/{lang}/events", name: "event_create", methods: ["POST"])]
    public function createAction(EventService $service, Request $request, string $lang): JsonResponse
    {
        // initApiResult validates and returns the DTO
        $data = $this->initApiResult($lang, EventCreateDto::class, $request);

        // Only call service if validation passed
        if ($this->apiResult->getCode() === 0) {
            $this->apiResult = $service->create($this->apiResult, $lang, $data);
        }

        return $this->processReturnCode();
    }
}
```

---

## Checklist

Before considering an autoform complete:

- [ ] DTO created in `api/src/Dto/<Feature>/<Form>Dto.php`
- [ ] DTO has `#[Dto(emptyError: -XXXY0)]` attribute
- [ ] Each property has appropriate attribute with error codes
- [ ] Migration declares form: `addAutoform('<Key>', <Dto>::class)`
- [ ] Migration adds labels: `addAutoformLabel('<Dto>_<property>', [...])`
- [ ] Return codes added via **Error Codes Agent**
- [ ] API controller uses `initApiResult($lang, Dto::class, $request)`
- [ ] All translations provided (FR, EN)
- [ ] Migration description starts with `#<issue> - `
- [ ] Migration executed via VM agent: `./scripts/dme <VersionName>`

---

## ⚠️ Questions to Ask User - USE AskUserQuestion TOOL

**ALWAYS use `AskUserQuestion` tool before creating autoforms:**

### 1. Form Fields

```json
{
  "questions": [{
    "question": "Quels champs sont nécessaires pour ce formulaire ?",
    "header": "Champs",
    "options": [
      {"label": "Texte court", "description": "StringProperty - titre, nom, etc."},
      {"label": "Texte long", "description": "TextareaProperty - description, notes"},
      {"label": "Date", "description": "DateProperty - date de début, échéance"},
      {"label": "Heure", "description": "TimeProperty - heure de début/fin"}
    ],
    "multiSelect": true
  }]
}
```

### 2. Field Details (for each field)

```json
{
  "questions": [{
    "question": "Configuration du champ 'title' :",
    "header": "Champ",
    "options": [
      {"label": "Obligatoire", "description": "Le champ doit être rempli"},
      {"label": "Optionnel", "description": "Le champ peut être vide"}
    ],
    "multiSelect": false
  }]
}
```

### 3. Field Labels Validation

**⛔ ALWAYS validate ALL labels before writing to migration:**

```json
{
  "questions": [{
    "question": "Labels des champs du formulaire :\n\n1. EventCreateDto_title\n   • FR: Titre\n   • EN: Title\n\n2. EventCreateDto_date\n   • FR: Date\n   • EN: Date\n\n3. EventCreateDto_note\n   • FR: Notes\n   • EN: Notes\n\nCes traductions sont-elles correctes ?",
    "header": "Labels",
    "options": [
      {"label": "Oui, valider", "description": "Tous les labels sont corrects"},
      {"label": "Modifier", "description": "Changer un ou plusieurs labels"}
    ],
    "multiSelect": false
  }]
}
```

### 4. Error Codes Validation

**Use the Error Codes Agent** which will validate via AskUserQuestion:

> "Add error codes for EventCreateDto: emptyError for DTO (-28100), and errors for fields title (-28102), date (-28101), note (-28106). Feature: event, Action: create, Migration: Version20260115160000"

**⛔ NEVER write to migration file WITHOUT using AskUserQuestion first for ALL labels.**
