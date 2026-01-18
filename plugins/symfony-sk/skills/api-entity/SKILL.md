---
name: symfony-sk:api-entity
description: Create or modify Doctrine entities. Use for database models.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# API Entity Skill

## Mission

Create or modify Doctrine ORM entities.

---

## Location

`api/src/Entity/<Name>.php`

---

## Template

```php
<?php

namespace App\Entity;

use App\Repository\<Name>Repository;
use Doctrine\ORM\Mapping as ORM;
use StarterKit\Entity\BaseEntity;
use Symfony\Component\Serializer\Attribute\Groups;

#[ORM\Entity(repositoryClass: <Name>Repository::class)]
#[ORM\Table(name: '<table_name>')]
class <Name> extends BaseEntity
{
    #[ORM\Column(type: 'string', length: 255)]
    #[Groups(['<feature>'])]
    private ?string $title = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['<feature>'])]
    private ?\DateTime $date = null;

    #[ORM\ManyToOne(targetEntity: User::class)]
    #[ORM\JoinColumn(nullable: false)]
    private ?User $owner = null;

    // Getters and setters...

    public function getTitle(): ?string
    {
        return $this->title;
    }

    public function setTitle(?string $title): self
    {
        $this->title = $title;
        return $this;
    }
}
```

---

## Common Column Types

| Type | Usage |
|------|-------|
| `string` | Text (specify length) |
| `text` | Long text |
| `integer` | Numbers |
| `boolean` | True/false |
| `datetime` | Date and time |
| `date` | Date only |
| `json` | JSON data |

---

## Relationships

```php
// Many-to-One
#[ORM\ManyToOne(targetEntity: User::class)]
#[ORM\JoinColumn(nullable: false)]
private ?User $owner = null;

// One-to-Many
#[ORM\OneToMany(mappedBy: 'parent', targetEntity: Child::class)]
private Collection $children;

// Many-to-Many
#[ORM\ManyToMany(targetEntity: Tag::class)]
private Collection $tags;
```

---

## Serialization Groups

Use `#[Groups(['<feature>'])]` for API output control.

---

## After Modification

**IMPORTANT**: Run `dsu` (Doctrine Schema Update) on VM after entity changes.

Use **vm-executor** agent:
```
"Run: ./scripts/dsu"
```

---

## Checklist

- [ ] Extends `BaseEntity`
- [ ] Has repository class
- [ ] Groups defined for serialization
- [ ] Getters/setters for all properties
- [ ] Run `dsu` after changes
