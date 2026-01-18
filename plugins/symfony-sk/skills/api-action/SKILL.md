---
name: symfony-sk:api-action
description: Create API Action controllers extending BaseAction. Use for API endpoints.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# API Action Skill

## Mission

Create API controller actions that handle HTTP requests, validate DTOs, and return JSON.

---

## Location

`api/src/Controller/<Feature>/<Name>Action.php`

---

## Template - Without DTO

```php
<?php

namespace App\Controller\<Feature>;

use App\Service\<Feature>Service;
use StarterKit\Controller\BaseAction;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

class <Feature><Action>Action extends BaseAction
{
    #[Route("/{lang}/<route>", name: "<feature>_<action>", methods: ["POST"])]
    public function <action>Action(<Feature>Service $service, string $lang, string $key): JsonResponse
    {
        $this->initApiResult($lang);

        $this->apiResult = $service-><method>($this->apiResult, $lang, $key);

        return $this->processReturnCode();
    }
}
```

---

## Template - With DTO

```php
<?php

namespace App\Controller\<Feature>;

use App\Dto\<Feature>\<Feature><Action>Dto;
use App\Service\<Feature>Service;
use StarterKit\Controller\BaseAction;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;

class <Feature><Action>Action extends BaseAction
{
    #[Route("/{lang}/<route>", name: "<feature>_<action>", methods: ["POST"])]
    public function <action>Action(<Feature>Service $service, Request $request, string $lang): JsonResponse
    {
        $data = $this->initApiResult($lang, <Feature><Action>Dto::class, $request);

        if ($this->apiResult->getCode() === 0) {
            $this->apiResult = $service-><method>($this->apiResult, $lang, $data);
        }

        return $this->processReturnCode();
    }
}
```

---

## Key Rules

1. **Extends `BaseAction`**
2. **Route starts with `/{lang}/`**
3. **ALWAYS pass `$lang` to service**
4. **Check `getCode() === 0` before calling service with DTO**
5. **Return `$this->processReturnCode()`**

---

## HTTP Methods

| Action | Method |
|--------|--------|
| List/Read | GET |
| Create | POST |
| Update | PUT |
| Delete | DELETE |
| Custom | POST |

---

## Checklist

- [ ] Extends `BaseAction`
- [ ] Route starts with `/{lang}/`
- [ ] `$lang` passed to service
- [ ] Returns `processReturnCode()`
- [ ] Registered in security zone (use `/security-zone`)
