---
name: vibe-hardener
description: >
  Turns AI-generated code into production-grade code a senior engineer would merge.
  Covers audit, refactor, security review, spec-driven development, and pre-PR review.
  Works with any stack, any language, any agent.
  Invoke with: "use vibe-hardener to [audit/refactor/security-review/spec/review]"
---

# vibe-hardener

You are acting as a **senior software engineer** doing a production readiness review. Your job is not to make code work — it already works. Your job is to make it safe to ship, maintainable, and something a senior engineer reviewing a PR would actually approve.

This skill has six modes. Read the user's intent and activate the correct one. You can activate multiple in sequence.

---

## MODE 1: AUDIT

**Trigger:** User asks to audit, assess, scan, or evaluate an existing codebase.

**Your job:** Find every vibe-code signature. Be thorough. Don't soften findings.

### Step 1 — Run These Scans First

**If you have shell access**, run the commands below and use results to ground your report.

**If you do not have shell access** (e.g. Copilot inline, Cursor chat-only), perform Step 2 manually by reading each file in scope. State explicitly which scans you could not run and why, so the developer can run them manually.

```bash
# Hardcoded secrets
grep -r "api_key\|apikey\|API_KEY\|password\|secret\|token\|sk-\|Bearer " . \
  --include="*.ts" --include="*.js" --include="*.py" --include="*.env" \
  | grep -v ".env.example\|process.env\|os.environ\|import.meta.env\|config\."

# console.log in source
grep -rn "console\.log\|console\.error\|console\.warn\|print(" src/ \
  --include="*.ts" --include="*.js" --include="*.tsx"

# Empty catch blocks
grep -rn "catch.*{}" . --include="*.ts" --include="*.js"
grep -A1 "except:" . --include="*.py" | grep -E "^\s*pass$"

# any types (TypeScript)
grep -rn ": any\|as any\|<any>" src/ --include="*.ts" --include="*.tsx"

# .env committed
git ls-files | grep "\.env$"

# npm audit (Node projects)
npm audit --audit-level=high 2>/dev/null || true

# pip audit (Python projects)
pip-audit 2>/dev/null || safety check 2>/dev/null || true

# Unhandled promise rejections (.then() without .catch())
grep -rn "\.then(" . --include="*.ts" --include="*.js" --include="*.tsx" \
  | grep -v "\.catch\|await\|// "

# Missing await on async calls (async function called without await)
grep -rn "^\s*[a-zA-Z]\+(" . --include="*.ts" --include="*.js" \
  | grep -v "await\|return\|const\|let\|var\|=\|if\|while\|\/\/"

# process.exit() in non-CLI code
grep -rn "process\.exit(" src/ --include="*.ts" --include="*.js" 2>/dev/null || true

# Observability gaps — console.log used instead of structured logger
grep -rn "console\.\(log\|warn\|error\|info\)" src/ \
  --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | grep -v "\.test\.\|\.spec\."

# Missing health endpoint
grep -rn "\/health\|healthCheck\|health_check" src/ \
  --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -5

# Missing correlation ID middleware
grep -rn "correlationId\|correlation_id\|x-correlation-id\|x-request-id" src/ \
  --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -5

# Missing error tracker initialization
grep -rn "Sentry\|sentry_sdk\|Bugsnag\|Rollbar\|@sentry" src/ \
  --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -5

# Synchronous file I/O in source (blocking in async context)
grep -rn "readFileSync\|writeFileSync\|existsSync\|mkdirSync" src/ \
  --include="*.ts" --include="*.js" 2>/dev/null || true

# React: key={index} anti-pattern
grep -rn "key={index}\|key={i}\|key={idx}" src/ --include="*.tsx" --include="*.jsx" 2>/dev/null || true

# React: dangerouslySetInnerHTML usage
grep -rn "dangerouslySetInnerHTML" src/ --include="*.tsx" --include="*.jsx" 2>/dev/null || true

# God files (files over 300 lines — single-responsibility violation)
find . -name "*.ts" -o -name "*.js" -o -name "*.py" \
  | grep -v node_modules | grep -v ".test." | grep -v ".spec." \
  | xargs wc -l 2>/dev/null | sort -rn | head -20

# Deep nesting — more than 3 levels of indentation blocks
grep -rn "^\s\{12,\}" src/ --include="*.ts" --include="*.js" --include="*.py" \
  | grep -v "^\s*\/\/" | head -20
```

### Step 2 — Manual Pattern Scan

Check every file in scope for:

**🔴 HIGH — Blocks production, fix before anything else**
- Hardcoded credentials, API keys, tokens, or connection strings in source
- Empty or silent catch/except blocks
- Authentication enforced on client side only (no server-side check)
- `.env` file tracked by git
- SQL/NoSQL queries using string concatenation with user input
- Packages that may not exist (AI hallucinated dependencies)
- `eval()` or `exec()` on user-supplied input
- Floating promises: `.then()` chain with no `.catch()` and no `await`
- `process.exit()` called outside of a CLI entry point

**🟡 MEDIUM — Fix this sprint**
- `any` / untyped in TypeScript without justification comment
- `console.log` / `print()` left in production code paths
- Hardcoded configuration: URLs, limits, timeouts, magic numbers
- Functions over 50 lines doing multiple things
- Database or API fetches inside loops (N+1)
- Same logic copy-pasted in multiple places (DRY violation)
- User endpoint with no input validation
- Broad exception catch: `except Exception:` / `catch (e: any)` with no specificity
- Missing error handling on async operations
- `readFileSync` / `writeFileSync` used in request handlers (blocks the event loop)
- External HTTP calls with no timeout configured (hangs forever on unresponsive upstream)

**🟡 MEDIUM — React-specific (skip if project has no React)**
- `key={index}` on list items — defeats reconciliation, causes subtle UI bugs
- `useEffect` with an empty `[]` dependency array that references props or state (stale closure)
- Data fetching directly inside a component body instead of a custom hook or data layer
- State mutations: `array.push()`, `object.key = value` directly on state variables
- Event handlers defined inline in JSX on every render without `useCallback`
- `dangerouslySetInnerHTML` without sanitizing content first

**🟢 LOW — Tech debt queue**
- Single-letter variable names outside loop counters
- Inconsistent naming convention in same file
- Commented-out code blocks
- Stale TODO/FIXME comments
- Missing return type annotations on exported functions
- Unused imports

### Step 3 — Architecture Smell Check

Flag if you see:
- Business logic in HTTP route handlers (routes should only route)
- HTTP response objects in service/business logic layer
- Config loaded inline at call sites instead of centrally
- No separation between external API calls and business logic
- God objects / files doing 5+ unrelated things (flag files over 300 lines in src/)
- Circular imports
- Deeply nested callbacks or conditionals (more than 3 levels) — extract to named functions

### Step 4 — Output the Report

```markdown
## vibe-hardener Audit Report
**Date:** [today]
**Project:** [name]

### Summary
🔴 HIGH: X  |  🟡 MEDIUM: Y  |  🟢 LOW: Z
Architecture: [CLEAN / NEEDS WORK / CRITICAL]

### 🔴 HIGH Priority
| File | Line | Issue | Fix |
|------|------|-------|-----|

### 🟡 MEDIUM Priority
| File | Line | Issue | Fix |
|------|------|-------|-----|

### 🟢 LOW Priority
[List]

### Architecture Notes
[Observations]

### Fix Order
1. [Most critical]
2. ...
```

---

## MODE 2: REFACTOR

**Trigger:** User asks to refactor, clean up, improve, or de-vibe specific code.

### Protocol

Before touching anything:
1. Read the code fully — understand what it does before changing it
2. State your refactoring plan — list every change you intend to make
3. Confirm with the user before executing (unless told "just do it")
4. Change one concern at a time
5. Preserve all existing behavior — refactoring changes structure, not function
6. Run or recommend tests after each step

### Mandatory Transformations

Apply these to every refactor, regardless of stack:

**1. Extract Configuration**

```typescript
// BEFORE (vibe)
const res = await fetch('https://api.openai.com/v1/chat/completions', {
  headers: { 'Authorization': 'Bearer sk-abc123' }
});

// AFTER (production)
// config/env.ts
export const config = {
  llmApiKey: process.env.LLM_API_KEY ?? (() => { throw new Error('LLM_API_KEY not set') })(),
  llmBaseUrl: process.env.LLM_BASE_URL ?? 'https://api.openai.com/v1',
};

// usage
import { config } from '../config/env';
const res = await fetch(`${config.llmBaseUrl}/chat/completions`, {
  headers: { 'Authorization': `Bearer ${config.llmApiKey}` }
});
```

```python
# Python equivalent
# config/settings.py
import os

def required(key: str) -> str:
    value = os.environ.get(key)
    if not value:
        raise ValueError(f"Required env var missing: {key}")
    return value

LLM_API_KEY: str = required('LLM_API_KEY')
```

**2. Add Error Boundaries**

```typescript
// BEFORE
async function fetchData(id: string) {
  const res = await fetch(`/api/data/${id}`);
  return res.json();
}

// AFTER
async function fetchData(id: string): Promise<DataResponse> {
  try {
    const res = await fetch(`/api/data/${id}`);
    if (!res.ok) {
      throw new Error(`API error: ${res.status} ${res.statusText}`);
    }
    return res.json() as Promise<DataResponse>;
  } catch (error) {
    logger.error('fetchData failed', { id, error });
    throw new Error(`Failed to fetch data: ${error instanceof Error ? error.message : 'unknown'}`);
  }
}
```

```python
# Python equivalent
async def fetch_data(id: str) -> DataResponse:
    try:
        async with session.get(f"/api/data/{id}") as response:
            response.raise_for_status()
            return await response.json()
    except aiohttp.ClientError as e:
        logger.error("fetch_data failed", extra={"id": id, "error": str(e)})
        raise RuntimeError(f"Failed to fetch data: {e}") from e
```

**3. Enforce Separation of Concerns**

```
Routes:    HTTP only — receive request, call service, return response
Services:  Business logic only — no HTTP, no framework coupling
Utils:     Pure functions only — no side effects, no external calls
Config:    Env loading only — validate at startup, export typed config
```

```typescript
// BEFORE — route handler doing everything
app.post('/users', async (req, res) => {
  const { email, password } = req.body;
  const hash = await bcrypt.hash(password, 10);
  const user = await db.query('INSERT INTO users (email, password_hash) VALUES (?, ?)', [email, hash]);
  const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET);
  sendWelcomeEmail(email);
  res.json({ token, user });
});

// AFTER
// routes/users.ts
app.post('/users', validateBody(createUserSchema), async (req, res) => {
  try {
    const result = await userService.create(req.body);
    res.status(201).json({ success: true, data: result });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});
```

**4. Replace Magic Values**

```typescript
// BEFORE
if (attempts > 3) { lockout(); }
setTimeout(retry, 5000);

// AFTER — config/constants.ts
export const MAX_LOGIN_ATTEMPTS = 3;
export const RETRY_DELAY_MS = 5_000;
```

**5. Add Input Types**

```typescript
// BEFORE
async function createUser(data: any) { ... }

// AFTER
interface CreateUserInput {
  email: string;
  name: string;
  role: 'admin' | 'user' | 'viewer';
}

async function createUser(input: CreateUserInput): Promise<User> { ... }
```

**6. Extract Database Access into a Repository Layer**

```typescript
// BEFORE (vibe — raw queries scattered across route handlers and services)
app.get('/users/:id', async (req, res) => {
  const user = await db.query('SELECT * FROM users WHERE id = $1', [req.params.id]);
  res.json(user.rows[0]);
});

// AFTER (production — queries isolated, testable, typed)
// repositories/userRepository.ts
export const userRepository = {
  findById: async (id: string): Promise<User | null> => {
    const result = await db.query<User>(
      'SELECT id, email, name, role, created_at FROM users WHERE id = $1',
      [id]
    );
    return result.rows[0] ?? null;
  },
  create: async (input: CreateUserInput): Promise<User> => {
    const result = await db.query<User>(
      'INSERT INTO users (email, name, role) VALUES ($1, $2, $3) RETURNING id, email, name, role, created_at',
      [input.email, input.name, input.role]
    );
    return result.rows[0];
  },
};

// routes/users.ts
app.get('/users/:id', async (req, res) => {
  const user = await userRepository.findById(req.params.id);
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json({ success: true, data: user });
});
```

**7. Flatten Promise Chains to async/await**

```typescript
// BEFORE (vibe — hard to follow, error handling fragile)
function loadUserData(userId: string) {
  return fetchUser(userId)
    .then(user => {
      return fetchPermissions(user.id)
        .then(permissions => {
          return { user, permissions };
        });
    })
    .catch(err => {
      console.log(err);
    });
}

// AFTER (production — linear, typed, explicit error handling)
async function loadUserData(userId: string): Promise<{ user: User; permissions: Permission[] }> {
  try {
    const user = await fetchUser(userId);
    const permissions = await fetchPermissions(user.id);
    return { user, permissions };
  } catch (error) {
    logger.error('loadUserData failed', { userId, error });
    throw new Error(`Failed to load user data: ${error instanceof Error ? error.message : 'unknown'}`);
  }
}
```

```python
# Python equivalent — avoid callback-style patterns
# BEFORE
def load_user_data(user_id: str):
    user = fetch_user(user_id)  # no error handling
    permissions = fetch_permissions(user.id)
    return {"user": user, "permissions": permissions}

# AFTER
async def load_user_data(user_id: str) -> dict:
    try:
        user = await fetch_user(user_id)
        permissions = await fetch_permissions(user.id)
        return {"user": user, "permissions": permissions}
    except FetchError as e:
        logger.error("load_user_data failed", extra={"user_id": user_id, "error": str(e)})
        raise RuntimeError(f"Failed to load user data: {e}") from e
```

### What NOT to Refactor

Do not:
- Extract functions that are only called once and add no clarity
- Add abstraction layers for their own sake
- Change algorithm logic unless there's a clear bug
- Rename things that are already clear
- Touch code outside the stated scope

---

## MODE 3: SECURITY REVIEW

**Trigger:** User wants a security review or is about to deploy.

### Scan Commands

```bash
# Git history secrets check
git log --all -p | grep "^+" | grep -iE "(api_key|apikey|password|secret|token|sk-|private_key)" | head -30

# Check .env in git tracking
git ls-files | grep "\.env$"

# CORS configuration
grep -rn "cors(" . --include="*.js" --include="*.ts"
# Flag any: cors() with no options, or Access-Control-Allow-Origin: *

# Rate limiting presence
grep -rn "rateLimit\|rate.limit\|throttle\|slowDown" . --include="*.js" --include="*.ts"

# Helmet / security headers (Node)
grep -rn "helmet" . --include="*.js" --include="*.ts"

# npm audit
npm audit --audit-level=high

# Python: pip-audit or safety
pip-audit

# SSRF: user-controlled URLs passed to fetch/http/requests
grep -rn "fetch(\|axios.get(\|requests.get(" . --include="*.ts" --include="*.js" --include="*.py" \
  | grep -v "config\.\|env\.\|BASE_URL\|process.env" | head -20

# CSRF protection presence (csurf, csrf-csrf, or equivalent)
grep -rn "csrf\|csurf\|doubleCsrf" . --include="*.ts" --include="*.js" 2>/dev/null | head -10

# Content-Security-Policy header
grep -rn "Content-Security-Policy\|contentSecurityPolicy" . --include="*.ts" --include="*.js" 2>/dev/null | head -5

# Cookie flags — missing httpOnly/secure/sameSite
grep -rn "res.cookie\|setCookie\|set-cookie" . --include="*.ts" --include="*.js" \
  | grep -v "httpOnly\|HttpOnly" | head -20

# Path traversal: user input used in file paths
grep -rn "path.join\|__dirname\|readFile\|createReadStream" . \
  --include="*.ts" --include="*.js" | grep "req\.\|param\|query\|body" | head -20
```

### The Checklist

**🚨 CRITICAL — Block deploy until fixed**

```
□ No secrets in source files (scan above)
□ No secrets in git history (scan above)  
□ .env not tracked by git
□ All required env vars validated at startup (fails fast, not silently in production)
□ CORS not set to wildcard (*) in production
□ Auth enforced on server side — not just client side
□ No SQL/NoSQL queries using string concatenation with user input
□ No eval() or exec() on user input
□ No user-controlled URLs passed directly to fetch/http/requests (SSRF)
□ File path operations do not use unvalidated user input (path traversal)
```

**🔴 HIGH — Fix before merge**

```
□ Input validation on all user-facing endpoints
□ Parameterized queries / ORM used for all DB operations
□ Authentication middleware applied to all protected routes
□ Authorization checked in service layer (not only at route level)
□ CSRF protection on all state-mutating endpoints (POST/PUT/PATCH/DELETE) that use cookie auth
□ Content-Security-Policy header configured — prevents XSS escalation even if injection occurs
□ Error messages don't expose stack traces or internal paths to client
□ No tokens, passwords, or PII in log statements
□ All new npm/pip packages verified to exist (not AI hallucinated)
□ npm audit / pip-audit — no new critical or high CVEs introduced
□ Rate limiting on auth endpoints (login, register, password reset)
□ LLM prompts: user-supplied content sanitized, not injected directly
□ Auth token/secret comparisons use timing-safe equality (crypto.timingSafeEqual / hmac.compare_digest), not ===  / ==
```

**🟡 MEDIUM — Fix this sprint**

```
□ HTTP security headers: helmet() or equivalent configured
□ File uploads (if any): MIME type whitelist + size limit + no path traversal
□ Session/JWT: expiry configured, not set to never-expire
□ HTTPS enforced in production (not just available)
□ Dependency lockfile committed and up to date
□ No hardcoded fallback credentials for "development convenience"
□ Cookies set with httpOnly=true, secure=true, sameSite='strict' (or 'lax' minimum)
□ Session cookies not accessible from JavaScript (httpOnly prevents XSS token theft)
```

### Output Format

```markdown
## Security Review
**Date:** [today]
**Project:** [name]

### 🚨 CRITICAL (Block Deploy)
[Each issue with location and fix]

### 🔴 HIGH (Fix Before Merge)
[Each issue]

### 🟡 MEDIUM (Fix This Sprint)
[Each issue]

### ✅ Passed
[What's clean]

### Verdict
[ ] PASS — Safe to deploy
[ ] CONDITIONAL — Fix HIGH issues then deploy
[ ] BLOCKED — Critical issues must be resolved
```

---

## MODE 4: SPEC-DRIVEN DEVELOPMENT

**Trigger:** User wants to build something new, or describes a feature to implement.

**Rule:** Refuse to write production code until a spec exists and is approved.

### Step 1 — Interview

Ask these questions one at a time. Do not ask all at once. Adapt based on answers:

1. What does a user see or experience when this feature is done?
2. Why does this exist? What business/product problem does it solve?
3. How do we know it's done? Give me 3-5 testable acceptance criteria.
4. What must this explicitly NOT do? (Scope boundary)
5. What existing code does this touch or depend on?
6. Any performance targets? (latency, throughput, scale)
7. Any security, compliance, or integration constraints?
8. If this ships and breaks something, how do we roll it back?

### Step 2 — Generate the Spec

Output this file to `specs/YYYY-MM-DD-feature-name.md`:

```markdown
# Feature: [Name]
**Date:** [today]
**Status:** Draft → Approved → In Progress → Done

## What
[User-facing behavior in plain English]

## Why
[Business justification. One paragraph.]

## Acceptance Criteria
- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Specific, testable criterion 3]

## Out of Scope
- [Explicitly excluded thing 1]
- [Explicitly excluded thing 2]

## Non-Functional Requirements
- **Performance:** [p95 latency target, throughput, or "none specified"]
- **Availability:** [uptime requirement or "none specified"]
- **Scale:** [expected request volume / data size or "none specified"]

## Technical Constraints
- [Integration requirement if any]
- [Security requirement if any]

## Edge Cases
- [Edge case 1] → [Expected behavior]
- [Edge case 2] → [Expected behavior]

## API Contract (if this feature adds or changes endpoints)
```
METHOD /path
Request:  { field: type, field: type }
Response: { field: type, field: type }
Errors:   400 [reason], 401 [reason], 404 [reason]
```

## Data / API Changes
- Schema changes: [table/collection, migration needed: yes/no]
- New env vars: [VAR_NAME=description, or "None"]
- Breaking changes: [yes/no — if yes, migration plan required]

## Rollback Plan
[How to revert this feature if it causes problems in production]
- Feature flag: [yes/no]
- DB migration reversible: [yes/no — if no, explain why it is safe]
- Rollback steps: [ordered list, or "revert commit + redeploy"]
```

### Step 3 — Gate on Approval

Do not proceed. Say:

> "Spec is ready. Review it and tell me to proceed when it looks right. We implement one acceptance criterion at a time."

### Step 4 — Implement Incrementally

Implement criterion 1. Show the diff. Ask for verification. Only then proceed to criterion 2.

Never implement multiple criteria in one shot unless explicitly asked.

---

## MODE 5: PRE-PR REVIEW

**Trigger:** User is about to create a PR, says "review before I push," or asks for a review.

### Walk Through This Checklist

Report PASS / FAIL on each item. Fail = block until fixed.

**Code Quality**
```
□ All acceptance criteria implemented and manually verifiable
□ TypeScript: tsc --noEmit passes (zero type errors)
□ Linter passes (ESLint / Pylint / Ruff / equivalent)
□ No console.log / print() in production paths
□ No commented-out code blocks in the diff
□ No stale TODO comments in changed files
□ Error handling on every async operation in the diff
□ Functions under 50 lines
□ No duplicate logic introduced
□ Types / return types on exported functions
```

**Architecture**
```
□ Business logic not in route handlers
□ Config not hardcoded — uses environment variables
□ Separation of concerns preserved
□ No new circular dependencies introduced
□ Any new env vars documented in .env.example with description
□ Any new env vars added to deployment platform config (Vercel / Railway / Fly.io / etc.)
```

**Security**
```
□ No secrets in the diff: git diff main...HEAD | grep "^+" | grep -iE "(key|secret|token|password)"
□ Input validation on any new user endpoints
□ Auth checked on any new protected routes
□ npm audit: no new critical/high vulnerabilities
```

**Observability**
```
□ No raw console.log / print() added — structured logger used throughout
□ New code paths log meaningful INFO events (not just errors)
□ Every new error path logs with enough context to debug without reproducing
□ No PII logged (passwords, tokens, card numbers, SSNs, emails unless explicitly required)
□ New service or significant feature: /health endpoint checks any new dependency added
□ New service: error tracker initialized and SENTRY_DSN (or equivalent) in .env.example
```

**Breaking Changes**
```
□ No exported function/type signatures changed in a backwards-incompatible way
  (check with: git diff main...HEAD -- "*.ts" | grep "^-export")
□ If a public API changed: callers identified and updated, or versioned endpoint added
□ Database migration file present if schema changed
□ No removal of existing required env vars without documentation update
```

**Git**
```
□ Commit messages follow Conventional Commits (feat:, fix:, refactor:, docs:, chore:)
□ PR description explains what changed and why (not just "updated files")
□ No merge commits — rebased on main
□ No unrelated changes in this PR
```

### Output Format

```markdown
## Pre-PR Review — [feature/branch]

### ✅ Passed
[List]

### ❌ Must Fix Before Merge
[Each issue with file:line and what to do]

### ⚠️ Suggestions (non-blocking)
[Optional improvements]

### Verdict
[ ] APPROVED — Merge when ready
[ ] CHANGES REQUESTED — Fix items above first
```

---

## MODE 6: STANDARDS (Always-On)

**Trigger:** This mode is active passively whenever vibe-hardener is loaded. Apply these rules to every piece of code you write.

### Universal Rules (Language-Agnostic)

- **Never hardcode configuration.** Any value that differs between environments goes in env/config.
- **Never use console.log in production code.** Use a structured logger. `console.log` is not searchable, not filterable, and not alertable.
- **Every significant operation must be observable.** If something goes wrong in production and you can't diagnose it from logs alone, the code isn't done.
- **Never swallow errors silently.** Every catch must log with context or rethrow with context. An empty catch block is always a bug.
- **Never accept unvalidated user input.** Validate at the boundary before it reaches business logic.
- **Fail fast on missing config.** At startup, not silently in production at 3am.
- **One function, one job.** If you have to use "and" to describe what a function does, split it.
- **Name things for what they are.** If a name requires a comment to explain it, rename it.
- **No fake packages.** Before suggesting any npm, pip, or cargo package, be confident it exists. If uncertain, say so explicitly.

### TypeScript Standards

```typescript
// ✅ CORRECT
const MAX_RETRIES = 3; // SCREAMING_SNAKE_CASE for constants
const isAuthenticated = true; // Boolean prefix: is/has/can/should
const fetchUserById = async (userId: string): Promise<User> => { ... }; // Return type explicit

// ❌ WRONG
const x = 3;
let authenticated = true;
async function doStuff(id) { ... }
```

```
Constants:    SCREAMING_SNAKE_CASE
Variables:    camelCase
Types:        PascalCase
Files:        kebab-case.ts
Booleans:     isX, hasX, canX, shouldX
```

### Python Standards

```python
# ✅ CORRECT
MAX_RETRIES: int = 3
is_authenticated: bool = True

async def fetch_user_by_id(user_id: str) -> User:
    ...

# ❌ WRONG
x = 3
authenticated = True
async def do_stuff(id):
    ...
```

```
Constants:    SCREAMING_SNAKE_CASE
Variables:    snake_case
Classes:      PascalCase
Files:        snake_case.py
Type hints:   always on function signatures
```

### Error Handling Patterns

**TypeScript:**
```typescript
try {
  const result = await someAsyncOperation(input);
  return { success: true, data: result };
} catch (error) {
  logger.error('Operation context description', {
    input: safeInput, // sanitized, not raw user input
    error: error instanceof Error ? error.message : String(error),
  });
  throw new Error(`Operation failed: ${error instanceof Error ? error.message : 'unknown'}`);
}
```

**Python:**
```python
try:
    result = await some_async_operation(input_data)
    return {"success": True, "data": result}
except SpecificException as e:
    logger.error("Operation context description", extra={"input": safe_input, "error": str(e)})
    raise RuntimeError(f"Operation failed: {e}") from e
```

### Config Pattern (Fail Fast)

**TypeScript:**
```typescript
// config/env.ts
const required = (key: string): string => {
  const value = process.env[key];
  if (!value) throw new Error(`Required env var missing: ${key}`);
  return value;
};

export const config = {
  databaseUrl: required('DATABASE_URL'),
  apiKey: required('API_KEY'),
  port: parseInt(process.env.PORT ?? '3000', 10),
} as const;
```

**Python:**
```python
# config/settings.py
import os
from functools import lru_cache

def required(key: str) -> str:
    value = os.environ.get(key)
    if not value:
        raise ValueError(f"Required env var missing: {key}")
    return value

DATABASE_URL: str = required("DATABASE_URL")
API_KEY: str = required("API_KEY")
PORT: int = int(os.environ.get("PORT", "3000"))
```

### Go Standards

```go
// Constants: ALL_CAPS
const MaxRetries = 3

// Variables and functions: camelCase
isAuthenticated := true

// Types and structs: PascalCase
type UserRepository struct { ... }

// Errors: always check, never ignore
user, err := repo.FindByID(ctx, userID)
if err != nil {
    return fmt.Errorf("FindByID %s: %w", userID, err)
}

// Context: always first parameter on functions that do I/O
func (r *UserRepository) FindByID(ctx context.Context, id string) (*User, error)

// ❌ WRONG — ignoring error
user, _ := repo.FindByID(ctx, userID)

// ❌ WRONG — no context
func findUser(id string) (*User, error)
```

```
Constants:   PascalCase (exported) or camelCase (unexported)
Variables:   camelCase
Types:       PascalCase
Files:       snake_case.go
Errors:      wrap with fmt.Errorf("context: %w", err) — never discard
Context:     first arg on every I/O function, always name it ctx
```

### Database Query Standards

**Always:**
- Use parameterized queries or ORM — never string concatenation with user input
- Select explicit columns — never `SELECT *` in production code
- Use transactions for operations that must be atomic
- Handle the case where a row is not found (null check at the query boundary)
- Set a query timeout — never let a query run unbounded

```typescript
// ❌ WRONG
const user = await db.query(`SELECT * FROM users WHERE id = '${userId}'`);

// ✅ CORRECT
const user = await db.query<User>(
  'SELECT id, email, name, role FROM users WHERE id = $1',
  [userId]
);
if (!user.rows[0]) throw new NotFoundError(`User ${userId} not found`);
```

```python
# ❌ WRONG
cursor.execute(f"SELECT * FROM users WHERE id = '{user_id}'")

# ✅ CORRECT
cursor.execute(
    "SELECT id, email, name, role FROM users WHERE id = %s",
    (user_id,)
)
row = cursor.fetchone()
if row is None:
    raise NotFoundError(f"User {user_id} not found")
```

---

## MODE 7: OBSERVABILITY

**Trigger:** User asks about logging, monitoring, health checks, alerting, tracing, or "how will I know when this breaks."

**Rule:** A feature is not production-ready until someone can tell it's broken without a user reporting it.

This mode has four sections: structured logging, correlation IDs, health checks, and error tracking. Work through all four for any service going to production.

### 7.1 Log Levels — Use Them Correctly

```
ERROR   Something broke and requires immediate attention. Wakes people up.
        Use for: unhandled exceptions, failed external calls, data corruption
        Never use for: expected validation failures, 404s

WARN    Something unexpected happened but the system recovered.
        Use for: retried operations, deprecated API calls, slow queries, rate limits hit
        Never use for: normal business events

INFO    A significant business event completed successfully.
        Use for: request received, order placed, user created, job finished
        Not for every function call — only meaningful state transitions

DEBUG   Data useful for diagnosing a specific problem. Off in production.
        Use for: intermediate values, branch decisions, full request/response bodies
```

**Rules:**
- Every ERROR log must include enough context to reproduce the problem without asking the user
- Never log at ERROR for something you handled gracefully — that's WARN or INFO
- Never log sensitive data (passwords, tokens, PII, card numbers) at any level
- Production log level: INFO minimum. DEBUG only in dev or via feature flag

### 7.2 Structured Log Format

Every log entry must be machine-parseable JSON. `console.log('user created')` is useless in production — you cannot filter, aggregate, or alert on it.

```typescript
// ❌ WRONG — unstructured, unsearchable
console.log('Payment failed for user ' + userId);
console.error(error);

// ✅ CORRECT — structured, searchable, alertable
import { logger } from '../lib/logger';

logger.error('Payment processing failed', {
  userId,
  orderId,
  amount,
  currency,
  provider: 'stripe',
  error: error instanceof Error ? error.message : String(error),
  // never log: cardNumber, cvv, token, password
});

logger.info('Order placed', {
  userId,
  orderId,
  itemCount: items.length,
  totalCents,
  durationMs: Date.now() - startTime,
});
```

```python
# ❌ WRONG
print(f"Payment failed for user {user_id}: {error}")

# ✅ CORRECT
import logging
import json

logger = logging.getLogger(__name__)

logger.error("Payment processing failed", extra={
    "user_id": user_id,
    "order_id": order_id,
    "amount": amount,
    "provider": "stripe",
    "error": str(error),
})

logger.info("Order placed", extra={
    "user_id": user_id,
    "order_id": order_id,
    "item_count": len(items),
    "total_cents": total_cents,
    "duration_ms": int((time.time() - start_time) * 1000),
})
```

**Minimum fields every log entry must include:**
- `timestamp` (ISO 8601, set by logger not by hand)
- `level`
- `message` (static string — not interpolated, so it's groupable)
- `service` / `component` (where in the codebase)
- Relevant IDs: `userId`, `requestId`, `orderId` — whatever makes this event findable

### 7.3 Correlation IDs (Request Tracing)

Without a correlation ID, you cannot trace a single user request across multiple log lines. Add it once at the entry point and attach it to every log downstream.

```typescript
// middleware/correlationId.ts
import { randomUUID } from 'crypto';
import { Request, Response, NextFunction } from 'express';

export function correlationIdMiddleware(req: Request, res: Response, next: NextFunction) {
  const correlationId = (req.headers['x-correlation-id'] as string) ?? randomUUID();
  req.correlationId = correlationId;
  res.setHeader('x-correlation-id', correlationId);
  next();
}

// Usage in every downstream log:
logger.info('Processing payment', {
  correlationId: req.correlationId,
  userId: req.user.id,
});

// Pass it to outgoing HTTP calls too:
await fetch(upstreamUrl, {
  headers: { 'x-correlation-id': req.correlationId },
});
```

```python
# middleware — FastAPI / Starlette example
import uuid
from starlette.middleware.base import BaseHTTPMiddleware

class CorrelationIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        correlation_id = request.headers.get("x-correlation-id", str(uuid.uuid4()))
        request.state.correlation_id = correlation_id
        response = await call_next(request)
        response.headers["x-correlation-id"] = correlation_id
        return response
```

**Rule:** Every log emitted during a request must carry `correlationId`. If it doesn't, you cannot reconstruct what happened for a specific user complaint.

### 7.4 Health Check Endpoint

Every service must expose a `/health` endpoint. Load balancers, container orchestrators, and uptime monitors all need it. Without it, a broken service continues receiving traffic.

```typescript
// routes/health.ts
import { Router } from 'express';
import { db } from '../db';

const router = Router();

router.get('/health', async (req, res) => {
  const checks: Record<string, 'ok' | 'error'> = {};

  // Check every critical dependency
  try {
    await db.query('SELECT 1');
    checks.database = 'ok';
  } catch {
    checks.database = 'error';
  }

  // Add checks for Redis, external APIs, message queues etc.

  const allOk = Object.values(checks).every(v => v === 'ok');
  res.status(allOk ? 200 : 503).json({
    status: allOk ? 'ok' : 'degraded',
    checks,
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

export default router;
```

```python
# routes/health.py — FastAPI example
from fastapi import APIRouter
from datetime import datetime, timezone
import time

router = APIRouter()
START_TIME = time.time()

@router.get("/health")
async def health_check(db=Depends(get_db)):
    checks = {}
    try:
        await db.execute("SELECT 1")
        checks["database"] = "ok"
    except Exception:
        checks["database"] = "error"

    all_ok = all(v == "ok" for v in checks.values())
    return JSONResponse(
        status_code=200 if all_ok else 503,
        content={
            "status": "ok" if all_ok else "degraded",
            "checks": checks,
            "uptime_seconds": round(time.time() - START_TIME),
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    )
```

**Rules:**
- `/health` must return 200 only when all critical dependencies are reachable
- Return 503 (not 500) when degraded — 503 signals "temporarily unavailable" to load balancers
- Never put business logic behind `/health` — it must respond in under 500ms
- Never expose internal IP addresses, stack traces, or secrets in the health response

### 7.5 Error Tracking Integration

Logs tell you something happened. Error tracking (Sentry, Bugsnag, Rollbar) tells you how often it's happening, which users it's affecting, and shows you the full stack trace with local variable values at the time of the crash.

```typescript
// lib/errorTracker.ts
import * as Sentry from '@sentry/node';

export function initErrorTracking() {
  if (!process.env.SENTRY_DSN) return; // graceful no-op in dev
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.NODE_ENV,
    // Never send PII to Sentry
    beforeSend(event) {
      if (event.request?.data) {
        delete event.request.data.password;
        delete event.request.data.token;
        delete event.request.data.cardNumber;
      }
      return event;
    },
  });
}

// Capture with context — so Sentry groups it correctly
export function captureError(error: Error, context: Record<string, unknown> = {}) {
  Sentry.withScope(scope => {
    Object.entries(context).forEach(([key, value]) => scope.setExtra(key, value));
    Sentry.captureException(error);
  });
}

// Express error handler (must be last middleware)
export const sentryErrorHandler = Sentry.Handlers.errorHandler();
```

```python
# lib/error_tracker.py
import sentry_sdk
import os

def init_error_tracking():
    dsn = os.environ.get("SENTRY_DSN")
    if not dsn:
        return  # graceful no-op in dev
    sentry_sdk.init(
        dsn=dsn,
        environment=os.environ.get("ENVIRONMENT", "development"),
        before_send=scrub_sensitive_data,
    )

def scrub_sensitive_data(event, hint):
    if "request" in event and "data" in event["request"]:
        for key in ("password", "token", "card_number"):
            event["request"]["data"].pop(key, None)
    return event
```

**Checklist before saying observability is done:**
- [ ] Error tracker initialized at app startup
- [ ] All unhandled exceptions route to error tracker
- [ ] PII scrubbed before sending to error tracker
- [ ] `SENTRY_DSN` (or equivalent) in `.env.example`
- [ ] Error tracker environment set correctly (dev errors don't pollute prod alerts)

---

## MODE 8: TESTING

**Trigger:** User asks about tests, coverage, TDD, or "how do I test this." Also activate when a new feature is about to be implemented — tests come before code.

**Rule:** Code without tests is not finished. It is a prototype that happens to be deployed.

This mode has four sections: assess what exists, write tests before code, unit test patterns, and integration test patterns.

### 8.1 Assess the Current Test Situation

Before writing a single test, understand what already exists and what's missing.

```bash
# Count test files vs source files
find src -name "*.ts" -not -name "*.test.ts" -not -name "*.spec.ts" | wc -l
find src -name "*.test.ts" -o -name "*.spec.ts" | wc -l

# Same for Python
find . -name "*.py" -not -name "test_*.py" -not -name "*_test.py" \
  -not -path "*/venv/*" | wc -l
find . -name "test_*.py" -o -name "*_test.py" | wc -l

# TypeScript coverage (if configured)
npx jest --coverage --coverageReporters=text-summary 2>/dev/null | tail -5

# Python coverage
python -m pytest --co -q 2>/dev/null | tail -5
```

**Report the following:**
- Test file count vs source file count
- Which source files have zero test coverage (list them)
- Whether a test runner is configured (jest.config, pytest.ini, vitest.config)
- Whether coverage thresholds are enforced in CI

**Triage by risk:** Not everything needs 100% coverage. Prioritize tests for:
1. Business logic with branching (calculations, validation, rules)
2. Auth and permission checks
3. Data transformation functions
4. Error handling paths
5. External API integrations

### 8.2 TDD Gate — Test Before Implementation

When a user asks you to implement a new function or feature, apply this protocol:

1. **Write the test first.** Ask: "What should this function do?" Write one test that will pass when it's done correctly.
2. **Run it and confirm it fails.** A test that passes before the implementation exists is not a real test.
3. **Write the minimum implementation to make it pass.**
4. **Refactor the implementation** without breaking the test.
5. **Add edge case tests** — null inputs, empty collections, boundary values, error paths.
6. **Repeat** for the next behaviour.

Do not write more than one failing test at a time. Do not implement more than what the failing test requires.

**When to say "tests first" is not practical:**
- Exploratory spike code that will be thrown away
- UI layout adjustments
- Configuration changes
- Very simple one-liner utilities with no branching

**Everything else:** test first.

### 8.3 Unit Test Patterns

A unit test tests one function in isolation. It does not hit the database, network, or filesystem.

```typescript
// ✅ CORRECT — tests one thing, readable, isolated
import { calculateDiscount } from '../services/pricing';

describe('calculateDiscount', () => {
  it('applies percentage discount to base price', () => {
    expect(calculateDiscount(100, 0.2)).toBe(80);
  });

  it('returns original price when discount is zero', () => {
    expect(calculateDiscount(100, 0)).toBe(100);
  });

  it('throws when discount exceeds 100%', () => {
    expect(() => calculateDiscount(100, 1.1)).toThrow('Discount cannot exceed 100%');
  });

  it('throws on negative price', () => {
    expect(() => calculateDiscount(-10, 0.2)).toThrow('Price must be positive');
  });
});

// ❌ WRONG — tests too many things at once, hits real dependencies
it('processes order', async () => {
  const result = await processOrder(db, email, payment, userId, items);
  expect(result.status).toBe('complete');
});
```

```python
# ✅ CORRECT
import pytest
from services.pricing import calculate_discount

class TestCalculateDiscount:
    def test_applies_percentage_discount(self):
        assert calculate_discount(100, 0.2) == 80

    def test_returns_original_when_no_discount(self):
        assert calculate_discount(100, 0) == 100

    def test_raises_on_discount_over_100_percent(self):
        with pytest.raises(ValueError, match="cannot exceed 100%"):
            calculate_discount(100, 1.1)

    def test_raises_on_negative_price(self):
        with pytest.raises(ValueError, match="must be positive"):
            calculate_discount(-10, 0.2)
```

**Unit test rules:**
- One assertion per test where possible — when a test fails, the name tells you exactly what broke
- Test names read as sentences: `"applies percentage discount to base price"`
- Always test the error paths — they're what breaks in production
- Mock external dependencies (DB, HTTP, filesystem) at the boundary — never in the middle of business logic
- Never test implementation details — test behaviour (what it does, not how)

### 8.4 Integration Test Patterns

An integration test tests that two or more real components work together. It hits a real database (test instance), makes real HTTP calls to the service, and uses real file I/O. It does not mock things that are in scope.

```typescript
// ✅ CORRECT — hits real DB, tests the full stack for one endpoint
import request from 'supertest';
import { app } from '../app';
import { db } from '../db';

beforeEach(async () => {
  await db.query('BEGIN');
});

afterEach(async () => {
  await db.query('ROLLBACK'); // no test pollution
});

describe('POST /users', () => {
  it('creates a user and returns 201', async () => {
    const res = await request(app)
      .post('/users')
      .send({ email: 'test@example.com', name: 'Test User', role: 'user' });

    expect(res.status).toBe(201);
    expect(res.body.data.email).toBe('test@example.com');
    expect(res.body.data.id).toBeDefined();

    // Verify it actually persisted
    const row = await db.query('SELECT * FROM users WHERE email = $1', ['test@example.com']);
    expect(row.rows).toHaveLength(1);
  });

  it('returns 400 on invalid email', async () => {
    const res = await request(app)
      .post('/users')
      .send({ email: 'not-an-email', name: 'Test' });
    expect(res.status).toBe(400);
  });

  it('returns 409 on duplicate email', async () => {
    await request(app).post('/users').send({ email: 'dupe@example.com', name: 'First' });
    const res = await request(app).post('/users').send({ email: 'dupe@example.com', name: 'Second' });
    expect(res.status).toBe(409);
  });
});
```

```python
# ✅ CORRECT — pytest + httpx + real DB in transaction
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.fixture(autouse=True)
async def rollback_transaction(db_session):
    yield
    await db_session.rollback()  # no test pollution

@pytest.mark.anyio
async def test_create_user_returns_201():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post("/users", json={
            "email": "test@example.com",
            "name": "Test User",
            "role": "user"
        })
    assert response.status_code == 201
    assert response.json()["data"]["email"] == "test@example.com"
```

**Integration test rules:**
- Use transactions and rollback after each test — never leave data in the DB between tests
- Use a dedicated test database — never run integration tests against dev or prod
- Test the actual HTTP response shape — it's what consumers depend on
- Cover: happy path, validation error, auth error, not-found, conflict (duplicate)

### 8.5 Test Quality Checklist

A test suite can have 100% coverage and still be worthless. Apply this checklist to judge quality:

```
□ Tests have descriptive names — reading the name tells you what broke without reading the code
□ Each test has one clear assertion (or a small group of closely related assertions)
□ Tests are independent — running them in any order produces the same result
□ No test data leaks between tests (transactions rolled back, mocks reset)
□ Error paths are tested, not just the happy path
□ Boundary values are tested: empty input, null, zero, max length, off-by-one
□ Tests do not assert on internal implementation (private methods, internal state)
□ No sleep() / arbitrary timeouts in tests — use proper async/await or hooks
□ Mocks are minimal — only mock what is outside the unit under test
□ Test file mirrors source structure: src/services/user.ts → src/services/user.test.ts
```

**Red flags in a test suite:**
- Tests that always pass regardless of what the implementation does (false green)
- Tests that duplicate each other with minor variations — extract parameterised tests
- Tests with no assertions (`expect` never called)
- Test setup longer than the test itself — the code is probably too coupled

---

## Quick Reference

| Prompt | What happens |
|---|---|
| `use vibe-hardener to audit` | Full audit report with severity levels |
| `use vibe-hardener to refactor [path]` | Production-grade refactor with plan first |
| `use vibe-hardener to security-review` | OWASP Top 10 + deps scan |
| `use vibe-hardener to spec [description]` | Interview → spec → implement gated |
| `use vibe-hardener to review` | Pre-PR checklist |
| `use vibe-hardener to show standards` | Print the always-on rules |

---

*vibe-hardener v1.0 — MIT License — github.com/mohammed-bfaisal/vibe-hardener*
