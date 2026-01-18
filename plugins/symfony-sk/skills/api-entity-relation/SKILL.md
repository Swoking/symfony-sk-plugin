---
name: symfony-sk:api-entity-relation
description: Add a relation between two existing entities. Use when linking entities with ManyToOne, OneToMany, or ManyToMany relationships.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# API Entity Relation Skill

## Mission

Add a relationship between two existing Doctrine entities.

---

## Relation Types

### ManyToOne (N:1)

One entity references another. Most common.

```
Task -> Event (many tasks belong to one event)
```

### OneToMany (1:N)

Inverse of ManyToOne. Collection on the "one" side.

```
Event -> Tasks (one event has many tasks)
```

### ManyToMany (N:N)

Both sides have collections. Requires join table.

```
Event <-> Tags (events have tags, tags have events)
```

---

## Templates

### ManyToOne (owning side)

Add to the entity that holds the foreign key:

```php
use App\Entity\<Target>;

#[ORM\ManyToOne(targetEntity: <Target>::class)]
#[ORM\JoinColumn(nullable: false)]
private ?<Target> $<target> = null;

public function get<Target>(): ?<Target>
{
    return $this-><target>;
}

public function set<Target>(?<Target> $<target>): static
{
    $this-><target> = $<target>;
    return $this;
}
```

### OneToMany (inverse side)

Add to the entity that has the collection:

```php
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;

// In constructor
$this-><targets> = new ArrayCollection();

// Property
#[ORM\OneToMany(targetEntity: <Target>::class, mappedBy: '<source>', cascade: ['persist', 'remove'])]
private Collection $<targets>;

public function get<Targets>(): Collection
{
    return $this-><targets>;
}

public function add<Target>(<Target> $<target>): static
{
    if (!$this-><targets>->contains($<target>)) {
        $this-><targets>->add($<target>);
        $<target>->set<Source>($this);
    }
    return $this;
}

public function remove<Target>(<Target> $<target>): static
{
    if ($this-><targets>->removeElement($<target>)) {
        if ($<target>->get<Source>() === $this) {
            $<target>->set<Source>(null);
        }
    }
    return $this;
}
```

### ManyToMany

Owning side:
```php
#[ORM\ManyToMany(targetEntity: <Target>::class, inversedBy: '<sources>')]
#[ORM\JoinTable(name: '<source>_<target>')]
private Collection $<targets>;
```

Inverse side:
```php
#[ORM\ManyToMany(targetEntity: <Source>::class, mappedBy: '<targets>')]
private Collection $<sources>;
```

---

## Process

1. **Identify relation type** (ManyToOne, OneToMany, ManyToMany)
2. **Identify owning side** (the one with the foreign key)
3. **Add property + methods** to owning side
4. **Add inverse property + methods** if bidirectional
5. **Add constructor initialization** for collections
6. **Run `dsu`** to update schema

---

## After Modification

```bash
ssh <host> "docker exec <code>-api ./scripts/dsu"
```

---

## Checklist

- [ ] Relation type identified
- [ ] Owning side determined
- [ ] Property added with ORM attributes
- [ ] Getter/setter added
- [ ] Constructor initializes collections (if applicable)
- [ ] Inverse side added (if bidirectional)
- [ ] `mappedBy` / `inversedBy` match property names
- [ ] Schema updated via `dsu`
