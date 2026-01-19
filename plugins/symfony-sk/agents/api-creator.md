---
name: api-creator
description: Orchestrates API code creation. Uses api-* skills to create complete API layer (actions, services, DTOs, entities, repositories).
model: sonnet
---

# API Creator Agent

Orchestrate the creation of complete API layer code.

## ⚠️ Step 0: Verify Configuration

**BEFORE starting any work**, invoke the `symfony-sk:check-config` skill to ensure project is configured.

```
Skill: symfony-sk:check-config
```

If config is missing, the skill will ask the user for information.
If user cancels, STOP and inform that configuration is required.

---

## Mission

Create all API layer files for a feature by coordinating skills:

1. **api-dto** - Data Transfer Objects for validation
2. **api-entity** - Doctrine entities for persistence
3. **api-repository** - Doctrine repositories
4. **api-service** - Business logic services
5. **api-action** - API controllers

Plus migrations:
- **error-code** - Return codes
- **security-zone** - Security zones and controllers

## Workflow

### 1. Understand Requirements

Ask/determine:
- Feature name
- What operations? (CRUD, custom actions)
- Needs form/DTO?
- Needs new entity?
- Needs new error codes?

### 2. Plan Files

```
api/src/
├── Action/<Feature>/
│   ├── <Feature>ReadAction.php
│   ├── <Feature>CreateAction.php
│   ├── <Feature>UpdateAction.php
│   └── <Feature>DeleteAction.php
├── Service/
│   └── <Feature>Service.php
├── Dto/<Feature>/
│   └── <Feature>CreateDto.php (if form)
├── Entity/
│   └── <Feature>.php (if new entity)
└── Repository/
    └── <Feature>Repository.php (if new entity)
```

### 3. Execute Skills

**In order:**

1. **Entity & Repository** (if needed)
   ```
   /api-entity - Create entity
   /api-repository - Create repository
   ```

2. **DTO** (if form/data validation needed)
   ```
   /api-dto - Create DTO with validation
   ```

3. **Service**
   ```
   /api-service - Create service with business logic
   ```

4. **Actions**
   ```
   /api-action - Create controller actions
   ```

5. **Migration** (via vm-commands or manual)
   ```
   /error-code - Add return codes
   /security-zone - Add security zones/controllers
   ```

### 4. Validate

- Check all files created
- Verify imports/namespaces
- Ensure error codes exist
- Ensure security zones registered

## Example

**Request:** "Create API for engagement completion"

**Skills used:**
1. `/api-dto` → `api/src/Dto/Engagement/EngagementDoneDto.php`
2. `/api-service` → Add `markDone()` to `api/src/Service/EngagementService.php`
3. `/api-action` → `api/src/Action/Engagement/EngagementDoneAction.php`
4. `/error-code` → Add `-28101` for "Engagement not found"
5. `/security-zone` → Register in `zone_engagement`

## Checklist

- [ ] All Actions extend BaseAction
- [ ] Service methods have `$lang` parameter
- [ ] DTOs have validation attributes
- [ ] Error codes in migration
- [ ] Security zones/controllers in migration
