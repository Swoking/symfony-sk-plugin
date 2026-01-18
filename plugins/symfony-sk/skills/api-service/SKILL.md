---
name: symfony-sk:api-service
description: Create or modify API services extending BaseService. Use for business logic.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# API Service Skill

## Mission

Create API services that handle business logic, database operations, and return ApiResult.

---

## Location

`api/src/Service/<Name>Service.php`

---

## Template

```php
<?php

namespace App\Service;

use App\Repository\<Entity>Repository;
use Doctrine\ORM\EntityManagerInterface;
use Psr\Log\LoggerInterface;
use StarterKit\Entity\ApiResult;
use StarterKit\Service\BaseService;
use StarterKit\Service\Helper\HelperService;
use Symfony\Component\EventDispatcher\EventDispatcherInterface;

class <Feature>Service extends BaseService
{
    public function __construct(
                         EntityManagerInterface $em,
                         LoggerInterface        $logger,
                         HelperService          $helper,
                         EventDispatcherInterface $dispatcher,
        private readonly <Entity>Repository     $repository,
    ) {
        parent::__construct($em, $logger, $helper, $dispatcher);
    }

    public function read(ApiResult $apiResult, string $lang, string $key): ApiResult
    {
        $entity = $this->repository->findOneBy(['key' => $key, 'isDeleted' => 0]);

        if (!$entity) {
            // Array contains values to inject in message placeholders (%%1%%, %%2%%, etc.)
            return $this->helper->setReturnCode($apiResult, $lang, -XXXXX, [$key]);
        }

        $apiResult->setData($this->normalize($entity));
        return $apiResult;
    }

    public function create(ApiResult $apiResult, string $lang, <Dto> $data): ApiResult
    {
        $entity = new <Entity>();
        $this->helper->initNewEntity($entity);
        // Set properties from $data

        $this->entityManager->persist($entity);
        $this->entityManager->flush();

        $apiResult->setData($this->normalize($entity));
        return $apiResult;
    }

    private function normalize(mixed $data): array
    {
        return $this->normalizer->normalize($data, null, ['groups' => ['<feature>']]);
    }
}
```

---

## Key Rules

1. **Extends `BaseService`**
2. **Methods MUST have `$lang` parameter** (requested language for translations/localized data)
3. **Return `ApiResult`**
4. **Use `$this->helper->setReturnCode()` for errors**
5. **Use error codes from `/error-code` skill**

---

## Error Handling with setReturnCode

```php
// Signature: setReturnCode(ApiResult $apiResult, string $lang, int $code, array $params = [])
// $params contains values to inject into message placeholders

// Example: Error message "User %%1%% not found" with email in array
return $this->helper->setReturnCode($apiResult, $lang, -30201, [$user->getEmail()]);
// Result: "User test@test.com not found"

// Example: Multiple placeholders "%%1%% cannot be assigned to %%2%%"
return $this->helper->setReturnCode($apiResult, $lang, -30202, [$taskName, $userName]);
```

Use **vm-executor** agent to find existing error codes or `/error-code` skill to create new ones.

---

## Checklist

- [ ] Extends `BaseService`
- [ ] Constructor calls `parent::__construct()`
- [ ] All methods have `$lang` parameter
- [ ] Error codes used for failures
- [ ] Returns `ApiResult`
