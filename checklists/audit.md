# vibe-hardener — Codebase Audit Checklist

Run this when starting work on any codebase, inherited or AI-generated.

---

## Quick Scan Commands

Run these first. Results feed the manual review.

```bash
# Potential hardcoded secrets (adapt pattern to your stack)
grep -r "api_key\|apikey\|API_KEY\|password\|secret\|token\|sk-\|Bearer " . \
  --include="*.ts" --include="*.js" --include="*.py" \
  | grep -v ".env.example\|process.env\|os.environ\|import.meta.env\|config\."

# console.log / print() in source
grep -rn "console\.log\|console\.error\|console\.warn\|print(" src/ \
  --include="*.ts" --include="*.js" --include="*.tsx" --include="*.py"

# Empty catch blocks (TypeScript/JavaScript)
grep -rn "catch.*{}" . --include="*.ts" --include="*.js"

# Bare except/pass (Python)
grep -A1 "except:" . -r --include="*.py" | grep -E "^\s*pass$"

# TypeScript: untyped any
grep -rn ": any\|as any\|<any>" src/ --include="*.ts" --include="*.tsx"

# .env committed to git
git ls-files | grep "\.env$"

# N+1 pattern signals (fetch inside loop — approximate)
grep -rn "for.*await\|forEach.*await\|\.map.*await" src/ --include="*.ts" --include="*.js"

# Hardcoded URLs that should be config
grep -rn "https://" src/ --include="*.ts" --include="*.js" --include="*.py" \
  | grep -v "localhost\|example\.com\|comment\|//.*https"

# Dependency audit
npm audit --audit-level=high 2>/dev/null || pip-audit 2>/dev/null || true
```

---

## 🔴 HIGH — Fix Before Any Production Work

- [ ] No secrets in source files (scan above is clean)
- [ ] No secrets in git history: `git log --all -p | grep "^+" | grep -iE "(api_key|apikey|password|secret|token|sk-)" | head -20`
- [ ] `.env` not git-tracked: `git ls-files | grep "\.env$"` returns nothing
- [ ] Auth logic enforced server-side, not client-only
- [ ] No empty or silent catch/except blocks
- [ ] All user input validated before reaching business logic
- [ ] No SQL/NoSQL queries using string concatenation with user input

## 🟡 MEDIUM — Fix This Sprint

- [ ] All untyped `any` / missing type hints have justification comments
- [ ] No `console.log` / `print()` in production code paths
- [ ] No hardcoded configuration values (URLs, limits, timeouts, magic numbers)
- [ ] Functions under 50 lines
- [ ] No N+1 patterns (database/API calls inside loops)
- [ ] No duplicate business logic in multiple places
- [ ] JSDoc / docstrings on all exported/public functions
- [ ] `.env.example` exists with placeholder values for all required vars

## 🟢 LOW — Tech Debt Queue

- [ ] Consistent naming conventions throughout
- [ ] No commented-out code blocks
- [ ] No stale TODO/FIXME comments
- [ ] Return types on all exported functions
- [ ] No unused imports

---

## Architecture Check

- [ ] Route handlers contain routing logic only (no business logic)
- [ ] Service layer contains business logic only (no HTTP concerns)
- [ ] Config loaded centrally, not scattered throughout codebase
- [ ] No circular imports / dependencies
- [ ] Types/interfaces defined in one place, not duplicated

---

## Audit Report Template

```markdown
## Audit Report — [Project Name]
**Date:** 
**Auditor:** 
**Codebase:** [branch/commit]

### Summary
🔴 HIGH: X  |  🟡 MEDIUM: Y  |  🟢 LOW: Z
Architecture: [CLEAN / NEEDS WORK / CRITICAL]

### 🔴 HIGH Issues
| File | Line | Issue | Recommended Fix |
|------|------|-------|-----------------|
| | | | |

### 🟡 MEDIUM Issues
| File | Line | Issue | Recommended Fix |
|------|------|-------|-----------------|
| | | | |

### 🟢 LOW Issues
[List]

### Architecture Notes
[Observations on structure]

### Fix Order
1. [Most critical first]
2. 
3. 
```
