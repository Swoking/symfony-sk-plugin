---
name: symfony-sk:security-zone
description: Create security zones and assign rights to profiles. Use when registering controllers.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Security Zone Skill

## ⛔ CRITICAL RULES

**MANDATORY: Validate with `AskUserQuestion` BEFORE writing to migration.**

---

## Mission

Create security zones, register controllers, and assign profile access rights.

---

## Functions

```php
// Create zone with translations
$this->addSkSecurityZone(_Const::SECZONE_FEATURE, [
    'FR' => 'Gestion des fonctionnalités',
    'EN' => 'Feature management',
]);

// Register controller
$this->addSkControllers(self::SERVICE_FRONT, 'ControllerName', _Const::SECZONE_FEATURE);
$this->addSkControllers(self::SERVICE_API, 'ActionName', _Const::SECZONE_FEATURE);

// Grant access
$this->addSkAppRights(_Const::PROFILE_ADMIN, _Const::SECZONE_FEATURE, self::SECURITY_LEVEL_FULLACCESS);
```

---

## Constants

### Services
- `self::SERVICE_FRONT` (0)
- `self::SERVICE_BACK` (1)
- `self::SERVICE_API` (2)

### Security Levels
- `self::SECURITY_LEVEL_NOACCESS` (0)
- `self::SECURITY_LEVEL_READONLY` (1)
- `self::SECURITY_LEVEL_FULLACCESS` (2)

### Public Zone
- `Constants::SECZONE_ANONYMOUS` - For public routes

---

## Process

1. **Define zone**: Name + translations
2. **Add constant**: In `api/src/_Const.php`
3. **Register controllers**: Front, back, and/or API
4. **Assign rights**: Per profile
5. **Validate**: Use AskUserQuestion

---

## Checklist

- [ ] Zone constant added to `_Const.php`
- [ ] Zone has translations for all languages
- [ ] All controllers registered
- [ ] Rights assigned to profiles
- [ ] AskUserQuestion used before writing
