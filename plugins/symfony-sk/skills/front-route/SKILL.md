---
name: symfony-sk:front-route
description: Create front/back Route controllers extending BaseRoute. Use for pages and form endpoints.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Front Route Skill

## Mission

Create Route controllers for front or back office.

---

## Location

- Front: `front/src/Controller/<Feature>/<Name>Route.php`
- Back: `back/src/Controller/<Feature>/<Name>Route.php`

---

## HTTP Methods

**CRITICAL: Only GET or POST** - Never PUT, DELETE, PATCH in front/back.

---

## Template

```php
<?php

namespace App\Controller\<Feature>;

use App\Service\Bll\<Feature>Service;
use StarterKit\Controller\BaseRoute;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class <Feature><Action>Route extends BaseRoute
{
    #[Route("/<feature>/{key}/<action>", name: "<feature>_<action>", methods: ["POST"])]
    public function <action>(string $key, <Feature>Service $service): Response
    {
        $result = $service-><method>($key);

        return $this->checkAuthorization($result, new JsonResponse([
            'code' => $result->getCode(),
            'message' => $result->getMessage(),
            'data' => $result->getData(),
        ]));
    }
}
```

---

## Key Rules

1. **Extends `BaseRoute`**
2. **Inject services in method parameters** (NOT constructor)
3. **Wrap response with `$this->checkAuthorization()`**
4. **Only GET or POST methods**

---

## Patterns

### JSON Response (API-like)
```php
return $this->checkAuthorization($result, new JsonResponse([
    'code' => $result->getCode(),
    'message' => $result->getMessage(),
    'data' => $result->getData(),
]));
```

### Page Render
```php
return $this->checkAuthorization($result, $this->render('feature/page.html.twig', [
    'data' => $result->getData(),
]));
```

---

## Checklist

- [ ] Extends `BaseRoute`
- [ ] Service injected in method parameter
- [ ] HTTP method is GET or POST only
- [ ] Response wrapped with `checkAuthorization()`
- [ ] Registered in security zone
