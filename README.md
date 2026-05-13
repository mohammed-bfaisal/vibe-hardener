<div align="center">

# 🔩 vibe-hardener

### One skill file that turns AI-generated slop into code a senior engineer would actually merge.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Works with Claude Code](https://img.shields.io/badge/Claude%20Code-✓-blueviolet)](https://claude.ai/code)
[![Works with Cursor](https://img.shields.io/badge/Cursor-✓-blue)](https://cursor.sh)
[![Works with Codex CLI](https://img.shields.io/badge/Codex%20CLI-✓-green)](https://openai.com/codex)
[![Works with Windsurf](https://img.shields.io/badge/Windsurf-✓-cyan)](https://codeium.com/windsurf)
[![Works with any agent](https://img.shields.io/badge/Any%20Agent-✓-orange)]()

</div>

---

## The problem

You vibe-coded something. It works. You're about to push it. Then a senior engineer looks at it and finds:

- Hardcoded API keys
- Silent catch blocks that swallow every error
- Business logic living inside route handlers
- `any` types everywhere
- No input validation on user endpoints
- N+1 query patterns in three places
- `console.log` left in production paths

This happens because AI agents optimize for *working code*, not *production code*. They're extremely good at making something function. They're not trying to make it maintainable, secure, or reviewable.

**vibe-hardener closes that gap.**

---

## How it works

`SKILL.md` is a large instruction file — 3,000+ lines of engineering standards, checklists, patterns, and protocols. When you install it, your agent loads it into its context. When you invoke a mode, the agent follows that mode's protocol exactly as if a senior engineer had written it out as a task.

There's no plugin, no extension, no API. It's instructions in natural language that any AI agent can follow. That's why it works everywhere.

```
You say:              "use vibe-hardener to audit"
The agent reads:      MODE 1 in SKILL.md — runs scan commands, applies
                      the manual pattern checklist, produces a graded report
You get back:         A list of every issue with file:line, severity, and fix
```

Each mode is self-contained. The agent won't start executing until it has read the mode's protocol — so you always see the plan before anything changes.

**The skill covers 14 areas:**

| Mode | Invoke with | What it does |
|------|-------------|--------------|
| 1 | `audit` | Scan for vibe-code signatures — severity-graded report with file:line |
| 2 | `refactor [path]` | Transform to production standards — plan shown before execution |
| 3 | `security-review` | OWASP Top 10 scan — CRITICAL/HIGH/MEDIUM report |
| 4 | `spec "description"` | Interview → spec file → approval gate → then code |
| 5 | `review` | Pre-PR checklist: quality, arch, security, testing, deps, git |
| 6 | `show standards` | Print always-on rules (TS, Python, Go, error patterns, DB) |
| 7 | `observability` | Structured logging, correlation IDs, health check, error tracking |
| 8 | `testing` | TDD gate, unit + integration test patterns, test quality checklist |
| 9 | `performance` | DB indexes, caching, bundle size, memory leaks, pagination |
| 10 | `api-design` | HTTP status codes, error shape, idempotency, versioning, OpenAPI |
| 11 | `dependency-hygiene` | Unused deps, license scan, lockfile check, native replacements |
| 12 | `db-migrations` | Lock analysis, expand/migrate/contract, ORM rules, approval gate |
| 13 | `cicd` | Dockerfile, container security, .env.example, GitHub Actions |
| 14 | `llm-engineering` | Prompt injection, cost control, output validation, prompt versioning |

---

## Where to start

**You have existing code and want to know what's wrong:**
```
use vibe-hardener to audit
```
Runs grep scans + a manual pattern pass. Gives you a HIGH/MEDIUM/LOW report with exact file locations. Start here.

**You're about to build a new feature:**
```
use vibe-hardener to spec "describe what you want to build"
```
Forces a spec before a single line of code. You'll answer 8 questions, get a written spec with acceptance criteria and rollback plan, approve it, then the agent implements it. Prevents the "I have 300 lines of code I don't fully understand" problem.

**You're about to push a PR:**
```
use vibe-hardener to review
```
Runs the full pre-PR checklist: code quality, architecture, security, testing, observability, dependencies, and git hygiene. Catch everything before a human reviewer does.

**You're about to deploy:**
```
use vibe-hardener to security-review
```
Dedicated OWASP Top 10 pass. More thorough than the audit on the security surface specifically.

**You're about to run a database migration:**
```
use vibe-hardener to db-migrations
```
Reviews the migration for lock risk before it runs. A bad migration can lock a table for minutes in production.

---

## Install

### Claude Code

The skill is already pre-placed in this repo at `.claude/skills/vibe-hardener/SKILL.md`. If you cloned the repo, it's already there.

To install into your own project:

```bash
mkdir -p .claude/skills/vibe-hardener
curl -o .claude/skills/vibe-hardener/SKILL.md \
  https://raw.githubusercontent.com/mohammed-bfaisal/vibe-hardener/main/SKILL.md
```

Then invoke: `use vibe-hardener to [mode]`

### Cursor

```bash
mkdir -p .cursor/rules
curl -o .cursor/rules/vibe-hardener.mdc \
  https://raw.githubusercontent.com/mohammed-bfaisal/vibe-hardener/main/SKILL.md
```

Then invoke: `use vibe-hardener to [mode]` in the Cursor chat.

### Codex CLI / Gemini CLI / any agent that reads AGENTS.md

```bash
curl -o AGENTS.md \
  https://raw.githubusercontent.com/mohammed-bfaisal/vibe-hardener/main/SKILL.md
```

The agent reads `AGENTS.md` automatically at session start.

### Windsurf

```bash
curl -o .windsurfrules \
  https://raw.githubusercontent.com/mohammed-bfaisal/vibe-hardener/main/SKILL.md
```

### GitHub Copilot

```bash
mkdir -p .github
curl -o .github/copilot-instructions.md \
  https://raw.githubusercontent.com/mohammed-bfaisal/vibe-hardener/main/templates/copilot-instructions.md
```

Note: Copilot reads this as passive guidance — it doesn't support invocable modes. The experience is weaker than Claude Code or Cursor.

### Automated (all agents at once)

```bash
git clone https://github.com/mohammed-bfaisal/vibe-hardener.git
cd your-project
bash /path/to/vibe-hardener/install.sh
```

The installer detects which agents you have configured and places the skill in every right location.

### Verify it worked

In Claude Code or Cursor, type:
```
use vibe-hardener to show standards
```
If you get back a formatted list of engineering rules, the skill is loaded.

---

## Usage

All modes follow the same invocation pattern: `use vibe-hardener to [mode]`

```
use vibe-hardener to audit
→ Scans your codebase, reports every vibe-code signature with file:line and severity

use vibe-hardener to refactor src/api/users.ts
→ States the plan, waits for your approval, then refactors one concern at a time

use vibe-hardener to security-review
→ Full OWASP Top 10 scan + dependency audit — CRITICAL/HIGH/MEDIUM report

use vibe-hardener to spec "add rate limiting to the auth endpoint"
→ Interviews you, generates specs/YYYY-MM-DD-feature.md, gates on approval before writing code

use vibe-hardener to review
→ Pre-PR checklist — catch everything before you push

use vibe-hardener to observability
→ Structured logging, correlation IDs, /health endpoint, Sentry/Bugsnag setup

use vibe-hardener to testing
→ TDD gate + unit/integration test patterns + test quality checklist

use vibe-hardener to performance
→ DB index review, cache opportunities, bundle size, memory leaks, pagination gaps

use vibe-hardener to api-design
→ HTTP status codes, error shape, idempotency, versioning, OpenAPI documentation

use vibe-hardener to dependency-hygiene
→ Unused deps, license scan, lockfile check, native platform replacements

use vibe-hardener to db-migrations
→ Review pending migrations for lock risk, destructive ops, and ORM pitfalls before they run

use vibe-hardener to cicd
→ Dockerfile audit, container security, .env.example check, GitHub Actions workflow generation

use vibe-hardener to llm-engineering
→ Prompt injection scan, cost control, output schema validation, prompt versioning setup
```

### In any agent (without skill support)

Reference it directly in your prompt:

```
"Using vibe-hardener standards, audit this codebase for production readiness"
"Following the vibe-hardener spec protocol, help me plan this feature before implementing"
"Review this diff using vibe-hardener's pre-PR checklist"
```

---

## What the audit catches

Runs scan commands first (grep, git log, npm audit, depcheck), then a manual pattern pass. If your agent has no shell access it falls back to reading files directly and tells you which scans to run manually.

**HIGH — blocks production**
- Hardcoded secrets, API keys, tokens in source
- Empty or silent catch blocks
- Client-side-only auth (no server enforcement)
- `.env` committed to git
- SQL/NoSQL queries built with string concatenation
- User-controlled URLs passed to server-side HTTP clients (SSRF)
- Unvalidated user input in file path operations (path traversal)
- Floating `.then()` chains with no `.catch()` (unhandled rejections)
- `process.exit()` outside CLI entry points

**MEDIUM — fix this sprint**
- Untyped `any` without justification
- `console.log` / `print()` in production paths
- Hardcoded config values (URLs, limits, timeouts, magic numbers)
- Functions over 50 lines
- Functions with cyclomatic complexity >10 — a 40-line function with 18 execution paths is unmaintainable (line count alone misses this)
- N+1 query/fetch patterns
- Duplicate business logic
- No input validation on endpoints
- `readFileSync` / `writeFileSync` in request handlers (blocks event loop)
- External HTTP calls with no timeout
- List endpoints with no `limit` parameter (unbounded result sets)
- Event listeners added without corresponding cleanup (memory leak)
- No structured logger — `console.log` used instead of a loggable, alertable logger
- No `/health` endpoint (load balancers and monitors need it)
- No correlation ID middleware (can't trace a request across log lines)
- React: `key={index}` on lists, stale `useEffect` deps, direct state mutation, `dangerouslySetInnerHTML`

**Architecture smells**
- God files over 300 lines
- Business logic in route handlers
- Framework objects (`Request`, `Response`, ORM sessions) crossing layer boundaries into service or domain code
- Deep nesting (3+ levels)
- Circular imports
- Config scattered instead of centrally loaded

**Dependency hygiene**
- Packages declared in `package.json` but not imported anywhere (dead weight)
- GPL/AGPL licensed packages in a commercial project (legal risk)
- No lockfile committed (`package-lock.json`, `poetry.lock`, etc.)
- Floating versions (`*` or `latest`) on production dependencies

**LOW — tech debt**
- Inconsistent naming conventions
- Commented-out code
- Stale TODO/FIXME comments
- Missing return types on exported functions

---

## What the security review covers

Beyond the audit, the dedicated security mode runs targeted scans and walks a full checklist:

**CRITICAL (block deploy)**
- Secrets in source and git history
- CORS wildcard in production
- SSRF and path traversal
- SQL injection via string concatenation
- `eval()` / `exec()` on user input

**HIGH (fix before merge)**
- Missing CSRF protection on cookie-auth endpoints
- No Content-Security-Policy header
- Auth token comparisons using `===` instead of timing-safe equality
- Missing rate limiting on auth endpoints
- LLM prompts with unsanitized user input

**Medium**
- Cookie flags (`httpOnly`, `secure`, `sameSite`)
- JWT/session expiry not configured
- Missing `helmet()` or equivalent headers
- Dependency vulnerabilities (`npm audit` / `pip-audit`)

---

## What the refactor does

```typescript
// BEFORE (what your agent generated)
app.post('/api/process', async (req, res) => {
  const data = req.body;
  try {
    const result = await fetch('https://api.openai.com/v1/...', {
      headers: { Authorization: 'Bearer sk-abc123hardcoded' }
    });
    const json = await result.json();
    // 60 more lines of business logic
    res.json(json);
  } catch (e) {
    // silent
  }
});

// AFTER (what vibe-hardener produces)
// routes/process.ts
app.post('/api/process', validateBody(processSchema), async (req, res) => {
  try {
    const result = await processService.execute(req.body);
    res.json({ success: true, data: result });
  } catch (error) {
    logger.error('Process endpoint failed', { error });
    res.status(500).json({ success: false, error: 'Processing failed' });
  }
});

// services/processService.ts
export const processService = {
  execute: async (input: ProcessInput): Promise<ProcessResult> => {
    // business logic here, properly typed, properly bounded
  }
};
```

Every refactor follows a fixed protocol: read first, state the plan, confirm before executing, one concern at a time. Transformations applied: config extraction, error boundaries, separation of concerns, magic value constants, input types, Promise chain flattening, repository isolation, resilience patterns (retry/timeout/fallback), black-box interface design, and linting config generation if missing.

---

## What the spec protocol does

Instead of telling your agent "add user authentication" and getting 300 lines of code you don't fully understand, vibe-hardener intercepts and forces a spec first:

```
You: use vibe-hardener to spec "add user authentication"

Agent: Before implementing, let me ask:
  1. What does the user see when this is done?
  2. Why does this exist — what problem does it solve?
  3. Acceptance criteria — give me 3-5 testable ones.
  4. What must this NOT do? (scope boundary)
  5. What existing code does this touch?
  6. Any performance targets?
  7. Any security or compliance constraints?
  8. If this ships and breaks something, how do we roll it back?

[After you answer, it generates specs/2026-05-13-user-auth.md]
[The spec includes: acceptance criteria, NFRs, API contract shape, edge cases, rollback plan]
[Only after you approve the spec does it write a single line of code]
```

---

## What the observability mode does

Walks through four areas for any service going to production:

- **Log levels** — defines when to use ERROR vs WARN vs INFO vs DEBUG, with rules against logging PII at any level
- **Structured logging** — replaces `console.log('thing happened')` with machine-parseable JSON logs your monitoring stack can filter, aggregate, and alert on
- **Correlation IDs** — adds middleware that stamps every request with a trace ID and attaches it to every downstream log line, so you can reconstruct exactly what happened for one user
- **Health check endpoint** — `/health` that returns 200 only when all critical dependencies (DB, Redis, etc.) are reachable, and 503 otherwise — required by load balancers and uptime monitors
- **Error tracking** — Sentry/Bugsnag initialization with PII scrubbing so errors surface automatically without waiting for a user to report them

---

## What the testing mode does

- **Assess first** — counts test files vs source files, identifies which source files have zero coverage, checks whether a test runner is configured and whether coverage thresholds are enforced in CI
- **TDD gate** — refuses to implement new business logic without writing a failing test first; defines exactly when tests-first isn't practical (spikes, layout tweaks, config)
- **Unit test patterns** — one assertion per test, test names that read as sentences, always test error paths, mock only at the boundary (never inside business logic)
- **Integration test patterns** — hits a real database, wraps each test in a transaction and rolls back after so tests never pollute each other, covers happy path + 400 + 401 + 404 + 409
- **Test quality checklist** — catches false-green tests, tests with no assertions, `sleep()` in tests, setup longer than the test itself

---

## What the performance mode does

- **Database index analysis** — queries `pg_stat_user_tables` to find sequential scans on large tables, checks every WHERE/JOIN ON/ORDER BY clause for missing indexes, and validates with `EXPLAIN ANALYZE` before shipping
- **Caching** — identifies repeated DB queries and expensive operations called on every request, provides a cache-aside pattern with Redis including TTL discipline and invalidation strategy
- **Bundle size** — detects whole-library imports (full lodash, all of moment), replaces with named imports or native APIs, lazy-loads routes and heavy components
- **Memory leak detection** — finds event listeners added without removal, `setInterval` without `clearInterval`, and React `useEffect` subscriptions missing cleanup returns
- **Pagination** — finds every list endpoint returning unbounded results and applies cursor-based pagination with a hard max on the `limit` parameter

---

## What the API design mode does

- **HTTP status codes** — enforces correct semantics: 201 for creates, 204 for deletes, 400 for client errors, 404 for not-found, 409 for conflicts, 422 for validation failures — flags the common `200` for everything anti-pattern
- **Consistent error shape** — every endpoint returns `{ error: "MACHINE_CODE", message: "human text" }` through a centralised error handler, never ad-hoc `{ message }` or `{ errors }` per route
- **Idempotency** — payment endpoints, order creation, and any operation with real-world side effects get an `Idempotency-Key` header check that prevents duplicate records on network retries
- **Versioning** — URL path versioning (`/api/v1`, `/api/v2`), `Deprecation: true` + `Sunset: <date>` headers on old versions, keep v(n-1) running for 3 months after v(n) ships
- **OpenAPI documentation** — generates specs from code (zod-to-openapi, tsoa, FastAPI auto-docs) rather than maintaining them by hand where they inevitably diverge

---

## What the dependency hygiene mode does

- **Unused package detection** — runs `depcheck` / `knip` to find packages declared in `package.json` but never imported, and packages imported but missing from `package.json`
- **License scan** — runs `license-checker` and flags any GPL/AGPL/SSPL dependency in a commercial project before it creates a legal obligation to open-source your codebase
- **Lockfile discipline** — checks the lockfile is committed, identifies floating `*` / `latest` versions, and sets rules for which packages need exact pinning (auth libraries, crypto, validators)
- **Native platform replacements** — maps common bloated packages to their zero-cost native equivalents: lodash → native array methods, moment → `Intl.DateTimeFormat`, uuid → `crypto.randomUUID()`, node-fetch → global `fetch`, mkdirp → `fs.mkdir({ recursive: true })`

---

## What the database migrations mode does

Safe migrations are the highest-stakes operation in a production system — a bad migration can lock a table for minutes and take the service down.

- **Lock analysis** — identifies operations that hold `ACCESS EXCLUSIVE` locks (blocking all reads and writes) vs `SHARE UPDATE EXCLUSIVE` (blocking only DDL), and flags any migration with a long-duration lock on a high-traffic table
- **Expand/migrate/contract** — enforces the three-phase pattern for zero-downtime schema changes: add new column (expand), backfill data, deploy code that writes to both, then remove old column (contract)
- **Safe patterns** — `CREATE INDEX CONCURRENTLY` instead of `CREATE INDEX`, `ADD COLUMN` with a separate `ALTER COLUMN SET DEFAULT` to avoid table rewrites, `DROP COLUMN` only after code no longer references it
- **ORM-specific rules** — Prisma shadow database discipline, Alembic `--autogenerate` review before running, Django `RunPython` with `atomic=False` for large backfills
- **Approval gate** — reviews migration, states lock type and estimated risk, asks for explicit sign-off before running anything

---

## What the CI/CD mode does

- **Dockerfile** — generates a multi-stage build (build stage + lean runtime stage) that strips devDependencies, reduces image size, and fails the build if the app exits unexpectedly
- **Container security** — adds non-root user (`RUN addgroup/adduser`, `USER appuser`), pins base image to a digest not a moving tag, adds `.dockerignore` to exclude `.git`, `node_modules`, `.env`, test files
- **`.env.example`** — enforces the standard: `.env` is gitignored, `.env.example` is committed with every key and a safe placeholder value, and CI fails if `.env.example` is out of sync with required env vars
- **GitHub Actions** — generates a workflow with `npm ci` (not `npm install`), split lint + test + build jobs, matrix strategy for Node/Python version coverage, concurrency cancellation (stop old run when new push arrives), and coverage threshold enforcement

---

## What the LLM engineering mode does

For codebases that call AI APIs — the four failure modes that ship silently:

- **Prompt injection** — flags every place where user-supplied content is interpolated directly into the system prompt string. User input must be isolated in a clearly bounded `[USER INPUT]` block, never in the instruction half of the system message.
- **Cost control** — identifies unbounded loops that call AI APIs (token spend scales with iteration count), enforces per-request token budgets with `max_tokens`, and adds iteration caps so a runaway agent loop doesn't drain the budget silently
- **Output validation** — AI responses are untyped text; treating them as structured data without validation causes silent data corruption. Every AI output must be parsed and validated with zod (TypeScript) or pydantic (Python) before use, with a defined fallback for malformed responses
- **Prompt versioning** — prompts longer than 2 lines belong in their own versioned file (`prompts/summarisation-v2.ts`), not inline in application code. Adds rules for naming, unit-testing prompt content, and logging which version was used per call so regressions can be traced

---

## What the standards mode enforces

Always-on rules applied to every file the agent touches, without needing an invocation:

- **TypeScript** — strict/typed mode, no `any` without justification, explicit return types on exported functions, `isX`/`hasX`/`canX` boolean naming, `SCREAMING_SNAKE_CASE` constants
- **Python** — type hints on all function signatures, `snake_case` variables, `PascalCase` classes, `SCREAMING_SNAKE_CASE` constants
- **Go** — errors always checked and wrapped with `fmt.Errorf("context: %w", err)`, `context.Context` as first argument on all I/O functions
- **Error handling** — catch → log with context → rethrow with context. No empty catch blocks. No untyped `catch (e)`.
- **Config** — one central config file validates all env vars at startup with fast-fail. No `process.env.X` scattered through the codebase.
- **Interface boundaries** — routes do routing only, services accept plain domain types (never `Request`/`Response`), repositories hide ORM details from callers
- **Database schema** — `NOT NULL`, `CHECK`, `UNIQUE`, and `REFERENCES` constraints at DB level (not just ORM hooks), one model per table, enum addition order enforced (DB constraint first, then code)

---

## The SOP

`SOP.md` is a complete AI Engineering Standard Operating Procedure — the full workflow from spec to deploy. It's written to be team-adopted, not just personal.

It covers:
- Spec-before-code protocol with mandatory approval gate
- Agent configuration, session management, and context rot prevention
- Code quality standards with concrete ❌/✅ examples (TypeScript, Python, Go)
- Security review process (full OWASP Top 10 surface)
- Pre-deploy checklist
- Mandatory human checkpoints before DB writes, auth changes, and new dependencies
- How to recognize when an agent has gone off-track and when to start over

Use it as a template for your team's engineering culture document.

---

## Repo structure

```
vibe-hardener/
├── SKILL.md                              # ← The skill. This is the main thing.
├── AGENTS.md                             # Universal agent config (CLAUDE.md / AGENTS.md)
├── SOP.md                                # AI Engineering Standard Operating Procedure
├── install.sh                            # Auto-installer for all agents
│
├── .claude/skills/vibe-hardener/
│   └── SKILL.md                          # Pre-placed for Claude Code
│
├── .cursor/rules/
│   └── vibe-hardener.mdc                 # Pre-placed for Cursor
│
├── checklists/
│   ├── audit.md                          # Codebase audit with scan commands
│   ├── security.md                       # Security review with scan commands
│   └── pre-deploy.md                     # Pre-deployment sign-off
│
├── templates/
│   ├── CLAUDE.md                         # Drop-in for new projects
│   ├── AGENTS.md                         # Drop-in for new projects
│   └── copilot-instructions.md           # Drop-in for GitHub Copilot
│
└── docs/
    └── ecosystem.md                      # Full tool ecosystem reference
```

---

## Limitations

**What this does:** Gives your agent better instructions. Shifts the probability of good output. Catches the patterns it can.

**What this doesn't do:**

- It doesn't guarantee production-safe output. An agent can read "never hardcode secrets" and still hardcode one in a long session with context drift. Review diffs — always.
- The audit is pattern-based, not semantic. It finds secrets named `api_key`. It won't find one named `auth_token_internal`. Use a dedicated secrets scanner (truffleHog, gitleaks) for anything that matters.
- GitHub Copilot reads the instructions file as passive guidance — it doesn't support invocable modes. The experience is weaker there than in Claude Code or Cursor.
- Nothing here replaces a human security review for anything handling money, PII, or authentication.

---

## Philosophy

> "AI agents are exceptional at pattern completion. They are not trying to read your mind about security, maintainability, or architecture. That's on you — unless you give them the context."

vibe-hardener is that context. It doesn't replace your agent. It gives your agent the senior engineer's judgment layer that training data alone doesn't provide.

The gap between "it works on my machine" and "it's safe to ship" is exactly what this closes.

---

## Contributing

PRs welcome. If you find a vibe-code pattern this doesn't catch, or a refactoring pattern it doesn't apply — open an issue or a PR.

The goal: a skill file comprehensive enough that any agent using it would produce code that passes a senior engineer's review without notes.

---

## License

MIT — use it, fork it, ship it.

---

<div align="center">
  <sub>Built by <a href="https://github.com/mohammed-bfaisal">mbf</a></sub>
</div>
