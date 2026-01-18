---
name: symfony-sk:front-api-service
description: Create Api services for calling the backend API. Use for HTTP calls to API layer.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Front API Service Skill

## Mission

Create API client services that call the backend API.

---

## Location

- Front: `front/src/Service/Api/Api<Feature>.php`
- Back: `back/src/Service/Api/Api<Feature>.php`

---

## Template

```php
<?php

namespace App\Service\Api;

use StarterKit\Model\ApiResult;
use StarterKit\Service\BaseApiService;

class Api<Feature> extends BaseApiService
{
    public function read(string $lang, string $key): ApiResult
    {
        $this->setGetMethod();
        $this->setSecureByUser();
        $this->setApiRoute($lang."/<feature>/".$key);

        return $this->callApi();
    }

    public function update(string $lang, string $key, array $data): ApiResult
    {
        $this->setPutMethod();
        $this->setSecureByUser();
        $this->callNeedDataInBody();
        $this->setBody($data);
        $this->setApiRoute($lang."/<feature>/".$key);

        return $this->callApi();
    }

    public function delete(string $lang, string $key): ApiResult
    {
        $this->setDeleteMethod();
        $this->setSecureByUser();
        $this->setApiRoute($lang."/<feature>/".$key);

        return $this->callApi();
    }
}
```

---

## Available Methods

### HTTP Methods
- `setGetMethod()`
- `setPostMethod()`
- `setPutMethod()`
- `setDeleteMethod()`

### Authentication
- `setSecureByUser()` - User token
- `setSecureByApiKey()` - API key
- (none) - Public

### Request Body
- `callNeedDataInBody()` - Required before `setBody()`
- `setBody(array $data)`

---

## Key Rules

1. **Extends `BaseApiService`**
2. **No constructor** (parent handles it)
3. **Routes start with `$lang."/..."`**
4. **Call `callNeedDataInBody()` before `setBody()`**

---

## Checklist

- [ ] Extends `BaseApiService`
- [ ] `$lang` is first parameter
- [ ] Routes start with `$lang."/..."`
- [ ] `setSecureByUser()` for authenticated endpoints
- [ ] `callNeedDataInBody()` before `setBody()`
