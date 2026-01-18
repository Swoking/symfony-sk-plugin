---
name: symfony-sk:api-repository
description: Create or modify Doctrine repositories. Use for custom database queries.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# API Repository Skill

## Mission

Create or modify Doctrine repositories for custom queries.

---

## Location

`api/src/Repository/<Name>Repository.php`

---

## Template

```php
<?php

namespace App\Repository;

use App\Entity\<Name>;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<<Name>>
 */
class <Name>Repository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, <Name>::class);
    }

    /**
     * @return <Name>[]
     */
    public function findActiveByOwner(User $owner): array
    {
        return $this->createQueryBuilder('e')
            ->andWhere('e.owner = :owner')
            ->andWhere('e.isDeleted = 0')
            ->setParameter('owner', $owner)
            ->orderBy('e.createdAt', 'DESC')
            ->getQuery()
            ->getResult();
    }

    public function findOneByKey(string $key): ?<Name>
    {
        return $this->createQueryBuilder('e')
            ->andWhere('e.key = :key')
            ->andWhere('e.isDeleted = 0')
            ->setParameter('key', $key)
            ->getQuery()
            ->getOneOrNullResult();
    }
}
```

---

## Common Patterns

### Find with conditions
```php
public function findByStatus(string $status): array
{
    return $this->createQueryBuilder('e')
        ->andWhere('e.status = :status')
        ->andWhere('e.isDeleted = 0')
        ->setParameter('status', $status)
        ->getQuery()
        ->getResult();
}
```

### Count
```php
public function countByOwner(User $owner): int
{
    return $this->createQueryBuilder('e')
        ->select('COUNT(e.id)')
        ->andWhere('e.owner = :owner')
        ->andWhere('e.isDeleted = 0')
        ->setParameter('owner', $owner)
        ->getQuery()
        ->getSingleScalarResult();
}
```

### With joins
```php
public function findWithRelations(string $key): ?<Name>
{
    return $this->createQueryBuilder('e')
        ->leftJoin('e.items', 'i')
        ->addSelect('i')
        ->andWhere('e.key = :key')
        ->setParameter('key', $key)
        ->getQuery()
        ->getOneOrNullResult();
}
```

---

## Checklist

- [ ] Extends `ServiceEntityRepository`
- [ ] Type hints in PHPDoc
- [ ] Always filter `isDeleted = 0`
- [ ] Use QueryBuilder (not raw SQL)
