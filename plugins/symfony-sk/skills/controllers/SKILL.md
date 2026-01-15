---
name: symfony-sk-controllers
description: Create controllers and services for Symfony StarterKit. Use when creating new routes, API endpoints, or connecting front/back to API. Handles the full data flow from request to response.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Controllers & Services

## ⛔ CRITICAL RULES - READ FIRST

**MANDATORY: You MUST use the `AskUserQuestion` tool to validate BEFORE writing ANY migration code.**

### NEVER write to migration files without user validation for:

1. **Security zone** - Zone name + translations for ALL languages
2. **Security level** - visitor/user/app_right
3. **Profile access** - Which profiles get access
4. **ALL translations** - Every label, for ALL languages in `sk_language` table

### Check available languages FIRST:

```bash
ssh <project-url> "docker exec <project-code>-db psql -U <project-code> -d <project-code> -c 'SELECT code FROM sk_language ORDER BY id;'"
```

FR and EN are the minimum, but there may be more languages.

### Validation workflow:

```
1. Gather info → Ask user about security zone, level, profiles
2. Propose → Use AskUserQuestion to show ALL values before writing
3. WAIT → Do not proceed until user confirms
4. Write → Only after explicit "oui/yes/ok" from user
```

### Required AskUserQuestion calls:

1. **Before creating security zone**: Validate zone name + translations
2. **Before setting profiles**: Validate which profiles get access
3. **Before any label/translation**: Validate FR + EN text

**⚠️ VIOLATION: Writing to migration without AskUserQuestion = FAILURE**

---

This skill covers the creation of controllers and services across the front/back/API architecture.

---

## Data Flow

```
Request → Route (front/back) → Service/Bll → ApiService → Action (API) → Service → Response
              ↓                    ↓              ↓            ↓           ↓
         *Route.php          *Service.php    Api*.php    *Action.php   *Service.php
```

### Layer Responsibilities

| Layer | Location | Naming | Role |
|-------|----------|--------|------|
| Route | `front/src/Controller/` | `*Route.php` | Handle HTTP request, call service, return response |
| Service/Bll | `front/src/Service/Bll/` | `*Service.php` | Business logic, transform data, call API |
| ApiService | `front/src/Service/Api/` | `Api*.php` | Configure and execute API calls |
| Action | `api/src/Controller/` | `*Action.php` | Validate input, call service, return JSON |
| Service | `api/src/Service/` | `*Service.php` | Core business logic, database operations |

---

## Naming Conventions

### URL Patterns

Format: `/<feature>/{key}/<action>`

| Pattern | Example |
|---------|---------|
| Action on entity | `/engagement/{key}/done` |
| Create new | `/engagement/new` |
| Read entity | `/engagement/{key}` |
| List entities | `/engagements` |
| Partial action | `/engagement/{key}/edit-deadline` |

### Service Organization

**One service = one feature**

| Feature | Service |
|---------|---------|
| Engagement actions | `EngagementService` |
| Dashboard (lists engagements, events, etc.) | `DashboardService` |
| Event management | `EventService` |

If a feature needs data from another feature, inject that API service:

```php
// DashboardService needs engagement and event data
class DashboardService
{
    public function __construct(
        private readonly HelperService $helper,
        private readonly ApiEngagement $apiEngagement,
        private readonly ApiEvent      $apiEvent,
    ) {}

    public function getOverview(): array
    {
        $lang = $this->helper->getLanguage();
        $engagements = $this->apiEngagement->list($lang);
        $events = $this->apiEvent->list($lang);
        // ...
    }
}
```

---

## HTTP Methods

### Front/Back Controllers
**ONLY use GET or POST** - never PUT, DELETE, PATCH, etc.

```php
#[Route('/feature/{key}/do-something', name: 'feature_do_something', methods: ['POST'])]
```

### API Controllers
**Can use any HTTP method** (GET, POST, PUT, DELETE, PATCH)

```php
#[Route('/{lang}/feature/{key}', name: 'feature_update', methods: ['PUT'])]
```

---

## Controller Patterns

### Front/Back Route Controller

Extends `BaseRoute`. Inject services directly in method (no constructor).

```php
<?php

namespace App\Controller\Feature;

use App\Service\Bll\FeatureService;
use StarterKit\Controller\BaseRoute;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class FeatureDoSomethingRoute extends BaseRoute
{
    #[Route("/feature/{key}/do-something", name: "feature_do_something", methods: ["POST"])]
    public function doSomething(string $key, FeatureService $service): Response
    {
        $result = $service->doSomething($key);
        return $this->checkAuthorization($result, new JsonResponse([
            'code' => $result->getCode(),
            'message' => $result->getMessage(),
            'data' => $result->getData(),
        ]));
    }
}
```

**Key points:**
- Extends `BaseRoute`
- Inject service directly in method parameters
- Use `$this->checkAuthorization($result, <response>)` to handle auth errors
- Return `JsonResponse` with code, message, data

### API Action Controller (no body)

Extends `BaseAction`. Inject services directly in method (no constructor).

```php
<?php

namespace App\Controller\Feature;

use App\Service\FeatureService;
use StarterKit\Controller\BaseAction;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

class FeatureDoSomethingAction extends BaseAction
{
    #[Route("/{lang}/feature/{key}/do-something", name: "feature_do_something", methods: ["POST"])]
    public function doSomethingAction(FeatureService $service, string $lang, string $key): JsonResponse
    {
        $this->initApiResult($lang);

        $this->apiResult = $service->doSomething($this->apiResult, $lang, $key);

        return $this->processReturnCode();
    }
}
```

**Key points:**
- Extends `BaseAction`
- Route uses `{lang}` parameter (not `{_locale}`)
- Call `$this->initApiResult($lang)` first
- **ALWAYS pass `$lang` to service** - API has no other way to know user's language
- Pass `$this->apiResult` to service and reassign result
- Return `$this->processReturnCode()`

### API Action with DTO (request body)

For forms with validation, see the **AutoForms skill** for DTO creation.

`initApiResult` handles DTO extraction and validation:

```php
<?php

namespace App\Controller\Feature;

use App\Dto\Feature\FeatureCreateDto;
use App\Service\FeatureService;
use StarterKit\Controller\BaseAction;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;

class FeatureNewAction extends BaseAction
{
    #[Route("/{lang}/feature", name: "feature_new", methods: ["POST"])]
    public function newAction(FeatureService $service, Request $request, string $lang): JsonResponse
    {
        $data = $this->initApiResult($lang, FeatureCreateDto::class, $request);

        if ($this->apiResult->getCode() === 0) {
            $this->apiResult = $service->create($this->apiResult, $lang, $data);
        }

        return $this->processReturnCode();
    }
}
```

**Key points:**
- `initApiResult($lang, DTO::class, $request)` validates and returns the DTO
- Check `$this->apiResult->getCode() === 0` before calling service
- **ALWAYS pass `$lang` to service** - API has no other way to know user's language
- If validation fails, `processReturnCode()` returns the error

---

## Service Patterns

### Front/Back Service (Bll)

```php
<?php

namespace App\Service\Bll;

use App\Service\Api\ApiFeature;
use StarterKit\Model\ApiResult;
use StarterKit\Service\Bll\HelperService;

class FeatureService
{
    public function __construct(
        private readonly HelperService $helper,
        private readonly ApiFeature    $api,
    ) {
        $this->helper->logDebug("[Kotchi App] - Service - FeatureService - Load");
    }

    public function doSomething(string $key): ApiResult
    {
        $this->helper->logDebug("[Kotchi App] - Service - FeatureService - DoSomething");

        return $this->api->doSomething($this->helper->getLanguage(), $key);
    }

    public function doSomethingWithData(string $key, array $data): ApiResult
    {
        $this->helper->logDebug("[Kotchi App] - Service - FeatureService - DoSomethingWithData");

        return $this->api->doSomethingWithData($this->helper->getLanguage(), $key, $data);
    }
}
```

### Front/Back API Service

```php
<?php

namespace App\Service\Api;

use StarterKit\Model\ApiResult;
use StarterKit\Service\BaseApiService;

class ApiFeature extends BaseApiService
{
    // GET request (no body)
    public function read(string $lang, string $key): ApiResult
    {
        $this->setGetMethod();
        $this->setSecureByUser();
        $this->setApiRoute($lang."/feature/".$key);

        return $this->callApi();
    }

    // POST request without body
    public function doSomething(string $lang, string $key): ApiResult
    {
        $this->setPostMethod();
        $this->setSecureByUser();
        $this->setApiRoute($lang."/feature/".$key."/do-something");

        return $this->callApi();
    }

    // POST/PUT request with body
    public function update(string $lang, string $key, array $data): ApiResult
    {
        $this->setPutMethod();
        $this->setSecureByUser();
        $this->callNeedDataInBody();
        $this->setBody($data);
        $this->setApiRoute($lang."/feature/".$key);

        return $this->callApi();
    }

    // DELETE request
    public function delete(string $lang, string $key): ApiResult
    {
        $this->setDeleteMethod();
        $this->setSecureByUser();
        $this->setApiRoute($lang."/feature/".$key);

        return $this->callApi();
    }
}
```

### API Service

**IMPORTANT**: Always include `$lang` parameter - API has no other way to know user's language for error messages.

Use the **Error Codes Agent** to add return codes for service errors.

```php
<?php

namespace App\Service;

use App\Dto\Feature\FeatureCreateDto;
use App\Entity\Feature;
use App\Repository\FeatureRepository;
use Doctrine\ORM\EntityManagerInterface;
use Psr\Log\LoggerInterface;
use StarterKit\Entity\ApiResult;
use StarterKit\Service\BaseService;
use StarterKit\Service\Helper\HelperService;
use Symfony\Component\EventDispatcher\EventDispatcherInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerInterface;

class FeatureService extends BaseService
{
    public function __construct(
                         EntityManagerInterface   $em,
                         LoggerInterface          $logger,
                         HelperService            $helper,
                         EventDispatcherInterface $dispatcher,
        private readonly NormalizerInterface      $normalizer,
        private readonly FeatureRepository        $featureRepository,
    ) {
        parent::__construct($em, $logger, $helper, $dispatcher);
    }

    public function doSomething(ApiResult $apiResult, string $lang, string $key): ApiResult
    {
        $user = $this->helper->getUserLogged();

        $feature = $this->featureRepository->findOneBy([
            'key' => $key,
            'owner' => $user,
            'isDeleted' => 0
        ]);

        if (!$feature) {
            return $this->helper->setReturnCode($apiResult, $lang, -30201, [$key]);
        }

        // Do something with the feature
        $feature->setSomething(true);
        $this->entityManager->flush();

        $apiResult->setData($this->normalize($feature));
        $apiResult->setContext(['key' => $key]);

        return $apiResult;
    }

    public function create(ApiResult $apiResult, string $lang, FeatureCreateDto $data): ApiResult
    {
        $user = $this->helper->getUserLogged();

        $feature = new Feature();
        $this->helper->initNewEntity($feature);
        $feature->setTitle($data->title);
        $feature->setOwner($user);

        $this->entityManager->persist($feature);
        $this->entityManager->flush();

        $apiResult->setData($this->normalize($feature));
        $apiResult->setContext(['form' => 'FeatureCreate']);

        return $apiResult;
    }

    private function normalize(mixed $data): array
    {
        return $this->normalizer->normalize($data, null, ['groups' => ['feature']]);
    }
}
```

---

## Security Registration (Migrations)

**IMPORTANT**: Always ask the user for:
1. **Security zone** name, French description, and English description
2. **Profiles** that should have access to the controller

### Constants Reference

**In migrations, prefer `self::` constants from SkAbstractMigration:**

```php
// Services (self::)
self::SERVICE_FRONT   // 0 - Front office
self::SERVICE_BACK    // 1 - Back office
self::SERVICE_API     // 2 - API

// Security Levels (self::)
self::SECURITY_LEVEL_NOACCESS     // 0 - No access
self::SECURITY_LEVEL_READONLY     // 1 - Read only
self::SECURITY_LEVEL_FULLACCESS   // 2 - Full access
```

**For profiles and security zones, use `_Const::` or `Constants::`:**

```php
// Profiles (_Const::) - check api/src/_Const.php for all
_Const::PROFILE_ADMIN
_Const::PROFILE_COACH
_Const::PROFILE_CHIEF
_Const::PROFILE_ATTENDANT

// Security Zones (_Const::) - check api/src/_Const.php for all
_Const::SECZONE_OWN_ENGAGEMENT
_Const::SECZONE_PATH
// etc.

// Public zone (Constants:: from StarterKit)
Constants::SECZONE_ANONYMOUS   // For public/visitor access
```

### Function Signatures

```php
// Register a security zone (translations for all languages)
$this->addSkSecurityZone(string $keyname, array $translations)

// Register a controller in a security zone
$this->addSkControllers(int $service, string $controllerName, string $securityZone)

// Grant a profile access to a security zone
$this->addSkAppRights(string $profile, string $securityZone, int $securityLevel)
```

### Adding a New Security Zone

**Step 1**: Add the constant in `api/src/_Const.php`:

```php
const SECZONE_FEATURE = 'feature_operation';
```

**Step 2**: Use it in the migration:

```php
<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use App\_Const;
use App\Migrations\AppAbstractMigration;
use Doctrine\DBAL\Schema\Schema;

final class Version20260115150000 extends AppAbstractMigration
{
    public function getDescription(): string
    {
        return '#XX - Add feature controllers and security';
    }

    public function up(Schema $schema): void
    {
        // 1. Register security zone (translations for all languages)
        $this->addSkSecurityZone(_Const::SECZONE_FEATURE, [
            'FR' => 'Gestion des fonctionnalités',
            'EN' => 'Feature management',
        ]);

        // 2. Register controllers in the security zone
        $this->addSkControllers(self::SERVICE_FRONT, 'FeatureDoSomethingRoute', _Const::SECZONE_FEATURE);
        $this->addSkControllers(self::SERVICE_API, 'FeatureDoSomethingAction', _Const::SECZONE_FEATURE);

        // 3. Grant rights to profiles (one call per profile)
        $this->addSkAppRights(_Const::PROFILE_ADMIN, _Const::SECZONE_FEATURE, self::SECURITY_LEVEL_FULLACCESS);
        $this->addSkAppRights(_Const::PROFILE_COACH, _Const::SECZONE_FEATURE, self::SECURITY_LEVEL_READONLY);
    }
}
```

### Security Level Guide

| Level | Constant | Use Case |
|-------|----------|----------|
| 0 | `SECURITY_LEVEL_NOACCESS` | Explicitly deny access |
| 1 | `SECURITY_LEVEL_READONLY` | Read-only access (GET requests) |
| 2 | `SECURITY_LEVEL_FULLACCESS` | Full access (all methods) |

### Public Routes

For public routes (no authentication required), use `Constants::SECZONE_ANONYMOUS`:

```php
use StarterKit\Constants;

$this->addSkControllers(self::SERVICE_FRONT, 'LoginRoute', Constants::SECZONE_ANONYMOUS);
$this->addSkControllers(self::SERVICE_API, 'HealthCheckAction', Constants::SECZONE_ANONYMOUS);
```

---

## Checklist

Before considering a controller complete:

- [ ] Front/Back Route created (`*Route.php` extends `BaseRoute`)
- [ ] Front/Back Service method added (`Service/Bll/*Service.php`)
- [ ] Front/Back API Service method added (`Service/Api/Api*.php`)
- [ ] API Action created (`*Action.php` extends `BaseAction`)
- [ ] API Service method added (`Service/*Service.php`) with `$lang` parameter
- [ ] DTO created if needed (see **AutoForms skill**)
- [ ] Error codes added via **Error Codes Agent**
- [ ] Migration created with:
  - [ ] Security zone registered (if new)
  - [ ] Controllers registered (`addSkControllers`)
  - [ ] App rights granted (`addSkAppRights`)
- [ ] Migration description starts with `#<issue> - `
- [ ] Migration executed via VM agent: `./scripts/dme <VersionName>`

---

## ⚠️ Questions to Ask User - USE AskUserQuestion TOOL

**ALWAYS use `AskUserQuestion` tool before creating controllers:**

### 1. Security Zone Selection

```json
{
  "questions": [{
    "question": "Quelle zone de sécurité utiliser pour ce controller ?",
    "header": "Zone",
    "options": [
      {"label": "engagement", "description": "Zone existante pour les engagements"},
      {"label": "event", "description": "Zone existante pour les événements"},
      {"label": "Nouvelle zone", "description": "Créer une nouvelle zone de sécurité"}
    ],
    "multiSelect": false
  }]
}
```

### 2. Security Level

```json
{
  "questions": [{
    "question": "Quel niveau de sécurité pour ce controller ?",
    "header": "Sécurité",
    "options": [
      {"label": "visitor", "description": "Accès public sans authentification"},
      {"label": "user", "description": "Utilisateur connecté requis"},
      {"label": "app_right", "description": "Profils spécifiques avec droits"}
    ],
    "multiSelect": false
  }]
}
```

### 3. Profile Access (if app_right)

```json
{
  "questions": [{
    "question": "Quels profils doivent avoir accès ?",
    "header": "Profils",
    "options": [
      {"label": "admin", "description": "Administrateurs"},
      {"label": "coach", "description": "Coachs"},
      {"label": "chief", "description": "Responsables"},
      {"label": "attendant", "description": "Participants"}
    ],
    "multiSelect": true
  }]
}
```

### 4. Zone Translations (if new zone)

```json
{
  "questions": [{
    "question": "Nouvelle zone de sécurité :\n• Code: feature\n• FR: Fonctionnalité\n• EN: Feature\n\nCes traductions sont-elles correctes ?",
    "header": "Zone",
    "options": [
      {"label": "Oui, valider", "description": "Les traductions sont correctes"},
      {"label": "Modifier", "description": "Changer les traductions"}
    ],
    "multiSelect": false
  }]
}
```

### 5. Labels/Translations Validation

**⛔ ALWAYS validate ALL labels before writing to migration:**

```json
{
  "questions": [{
    "question": "Labels à ajouter :\n\n1. feature_title (labelFO)\n   • FR: Titre\n   • EN: Title\n\n2. feature_description (labelFO)\n   • FR: Description\n   • EN: Description\n\nCes valeurs sont-elles correctes ?",
    "header": "Labels",
    "options": [
      {"label": "Oui, valider", "description": "Tous les labels sont corrects"},
      {"label": "Modifier", "description": "Changer un ou plusieurs labels"}
    ],
    "multiSelect": false
  }]
}
```

**⛔ NEVER write to migration file WITHOUT using AskUserQuestion first.**

---

## Common Patterns

### Simple action (no data)

```
POST /feature/{key}/done → FeatureDoneRoute → service->markDone($key) → api->markDone() → FeatureDoneAction → service->markDone()
```

### Action with form data

```
POST /feature/{key}/update → FeatureUpdateRoute → service->update($key, $data) → api->update() → FeatureUpdateAction → service->update()
```

### Read data (for form prefill)

```
GET /feature/{key} → FeatureReadRoute → service->read($key) → api->read() → FeatureReadAction → service->read()
```
