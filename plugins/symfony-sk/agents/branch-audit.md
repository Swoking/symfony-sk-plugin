---
name: branch-audit
description: Full audit of all modified files in the current branch. Run before PR/merge to ensure quality.
model: sonnet
---

# Branch Audit Agent

Comprehensive audit of all branch changes before merge.

## ⚠️ Step 0: Verify Configuration

**BEFORE running audits**, invoke the `symfony-sk:check-config` skill to ensure project is configured.

```
Skill: symfony-sk:check-config
```

If config is missing, the skill will ask the user for information.
If user cancels, STOP and inform that configuration is required.

---

## Mission

1. Get all modified files (since branch diverged from parent)
2. Launch audit agents in parallel
3. Aggregate results
4. Report pass/fail

## Process

### 1. Get Modified Files

```bash
# Find parent branch
if git show-ref --verify --quiet refs/heads/develop; then
    PARENT="develop"
else
    PARENT=$(git remote show origin 2>/dev/null | grep 'HEAD branch' | cut -d' ' -f5 || echo "main")
fi

# Get merge base
MERGE_BASE=$(git merge-base $PARENT HEAD)

# Get modified files
git diff --name-only $MERGE_BASE HEAD
```

### 2. Categorize & Launch Audits

| File Type | Audits |
|-----------|--------|
| `*.php` | code-audit, security-audit, side-effects-audit |
| `*.php` (migrations) | + translation-audit |
| `*.js`, `*.ts` | code-audit, security-audit |
| `*.twig` | code-audit |
| `*.css`, images, fonts | **SKIP** |

### 3. Run Global Review

After file audits, launch `review-audit` for overall assessment.

### 4. Aggregate & Report

```
═══════════════════════════════════════════════════════
           BRANCH AUDIT REPORT
═══════════════════════════════════════════════════════

Branch: feature/my-feature
Files: 12 | Audits: 36

═══════════════════════════════════════════════════════
                    SUMMARY
═══════════════════════════════════════════════════════

✅ Code Audit:        8/8 passed
⚠️ Security Audit:    7/8 (1 warning)
✅ Side Effects:      8/8 passed
🔴 Translations:      1/2 (1 critical)
⭐ Global Review:     4/5

═══════════════════════════════════════════════════════
                 CRITICAL ISSUES
═══════════════════════════════════════════════════════

1. [translation-audit] Version20260116.php
   Missing: ES, DE translations

═══════════════════════════════════════════════════════
                   CONCLUSION
═══════════════════════════════════════════════════════

🔴 AUDIT FAILED - Fix critical issues before merge
```

## Pass/Fail

- **✅ PASSED**: No critical issues
- **🔴 FAILED**: Any critical issue

### Critical (must fix)
- Missing translations
- SQL injection
- Hardcoded credentials
- Missing `$lang` in API service

### Warning (review)
- Missing type hints
- Performance concerns
- Code style

## Skip Audit

If user says "skip audit" / "ignorer audit":
```
⚠️ Audit skipped at user request.
```
