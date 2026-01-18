---
name: symfony-sk:api-migration
description: Generate a new empty migration file with proper naming. Use when starting a new feature that needs database/settings changes.
allowed-tools: Read, Write, Bash, Glob
---

# API Migration Skill

## Mission

Generate a new empty migration file with proper naming convention.

---

## Process

### 1. Generate via VM

Use `vm-commands` agent to generate migration:

```bash
ssh <host> ". /sk/sk.lib && . /sk/sk_switchProject <code> && ${skv___projectPath}/scripts/dmg"
```

This creates a new file like `api/migrations/Version20260118143022.php`

### 2. Get the filename

The script outputs the created filename. Parse it to get the version name.

### 3. Update description

Edit the migration to add proper description:

```php
public function getDescription(): string
{
    return '#<ticket> - <description>';
}
```

---

## Template

```php
<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use App\_Const;
use App\Migrations\AppAbstractMigration;
use Doctrine\DBAL\Schema\Schema;

final class Version<timestamp> extends AppAbstractMigration
{
    public function getDescription(): string
    {
        return '#<ticket> - <description>';
    }

    public function up(Schema $schema): void
    {
        // Labels

        // Error codes

        // Security zones

        // Controllers

        // AutoForms
    }
}
```

---

## Naming Convention

Description format: `#<ticket-number> - <short description>`

Examples:
- `#48 - Add engagement completion form`
- `#52 - Add user profile settings`

---

## Checklist

- [ ] Migration generated via `dmg` script
- [ ] Description updated with ticket number
- [ ] File extends `AppAbstractMigration`
