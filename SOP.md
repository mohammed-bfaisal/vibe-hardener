# AI Engineering Standard Operating Procedure

**Use this as a template for your team. Customize the stack section. Keep everything else.**

---

## 1. The Problem This SOP Solves

AI agents produce code that works but fails on architecture, security, and maintainability. Left unchecked, a team of developers using AI agents will accumulate technical debt faster than a team writing code manually — because the feedback loop is faster but the quality filter is missing.

This SOP is the quality filter.

---

## 2. The Golden Rule

> **Never push AI-generated code to production without running it through this SOP.**

Vibe coding (generate → accept → push) is permitted for:
- Local throwaway prototypes
- Exploring an API's shape
- Generating boilerplate that gets fully reviewed before use

Everything that touches a shared repo goes through this SOP.

---

## 3. Your Stack (Customize This Section)

Replace this section with your actual stack. The rest of the SOP is stack-agnostic.

```
Frontend:   [e.g. Vite + React + TypeScript]
Backend:    [e.g. Express / FastAPI / Rails]
Database:   [e.g. PostgreSQL / MongoDB]
Deployment: [e.g. Vercel / Railway / Fly.io]
External APIs: [e.g. OpenAI / Stripe / Twilio]
```

---

## 4. Phase 1 — Spec Before Code

No production feature begins without a spec. This is non-negotiable.

### 4.1 The Spec File

Create a `specs/` directory at the repo root. Each feature gets one file:

```
specs/YYYY-MM-DD-feature-name.md
```

Use the vibe-hardener spec protocol: tell your agent `"use vibe-hardener to spec [description]"` — it will interview you and generate this automatically.

Manual format:

```markdown
# Feature: [Name]
**Date:** 
**Status:** Draft → Approved → In Progress → Done

## What
[User-facing behavior in plain English]

## Why
[Business justification]

## Acceptance Criteria
- [ ] [Testable criterion — specific enough to verify]
- [ ] [Testable criterion]
- [ ] [Testable criterion]

## Out of Scope
- [Thing this does NOT cover]

## Technical Constraints
[Performance, security, integration requirements]

## Edge Cases
- [Edge case] → [Expected behavior]

## Data / API Changes
[Schema changes, new endpoints, new env vars — or "None"]
```

### 4.2 Spec Gate

Before handing to an agent for implementation:
- [ ] Every acceptance criterion is independently testable
- [ ] Scope is bounded — "out of scope" section exists
- [ ] Edge cases are listed
- [ ] Breaking changes are flagged

No spec = no implementation.

---

## 5. Phase 2 — Agent Configuration

Every project using an AI agent MUST have an `AGENTS.md` (or `CLAUDE.md`) at the root.

### 5.1 Minimum Required Config

Copy `templates/AGENTS.md` from this repo and customize:

```markdown
# Project: [Name]
# Stack: [Your stack]

## Non-Negotiables (MUST)
- MUST use [language] strict/typed mode
- MUST never hardcode secrets, API keys, or config values
- MUST load all config from environment variables
- MUST handle errors explicitly — no silent catch blocks
- MUST keep functions under 50 lines
- MUST validate user input at API boundaries

## Anti-Patterns (MUST NOT)
- MUST NOT commit .env files
- MUST NOT use untyped/any without justification
- MUST NOT write N+1 query patterns
- MUST NOT push directly to main

## Architecture
[Your project structure]

## Git Workflow
- Branches: feature/[id]-description
- Commits: Conventional Commits (feat:, fix:, refactor:, docs:, chore:)
- PR required before merge to main
```

### 5.2 Agent-Specific Placement

| Agent | Where to put the config |
|---|---|
| Claude Code | `CLAUDE.md` at root (or symlink from `AGENTS.md`) |
| Codex CLI | `AGENTS.md` at root |
| Cursor | `.cursor/rules/` directory |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Windsurf | `.windsurfrules` at root |
| Gemini CLI | `GEMINI.md` at root |

Run `bash install.sh` from vibe-hardener to place everything automatically.

### 5.3 Session Management

- Reset context at ~50k tokens (context rot is real)
- Start each session: "Read AGENTS.md and specs/ before we begin"
- New feature = new session
- Use `/compact focus on [task]` before compacting to preserve context

---

## 6. Phase 3 — Development Loop

```
1. Create spec in specs/
2. Get spec approved
3. Open AI agent session → agent reads AGENTS.md + spec
4. Agent generates implementation plan → review it
5. Implement one acceptance criterion at a time
6. Run tests after each criterion
7. Review diff before accepting changes (every time)
8. Run checklist (checklists/pre-deploy.md)
9. PR → review → merge
```

### 6.1 Mandatory Checkpoints

The agent MUST stop and wait for human confirmation before:
- Writing to any database
- Adding any new dependency
- Modifying authentication or authorization logic
- Adding new environment variables
- Deleting any existing files or exports

### 6.2 When to Stop and Restart

If an agent produces a diff:
- Larger than ~200 lines for a simple task
- That modifies code you didn't ask about
- That adds a dependency you didn't ask for
- That you don't fully understand

**Stop. Reject the change. Break the task into smaller pieces. New session.**

---

## 7. Phase 4 — Code Standards

### 7.1 Configuration (All Stacks)

All config must:
1. Live in one place (e.g. `config/env.ts` or `config/settings.py`)
2. Fail fast at startup if required vars are missing
3. Never be scattered across the codebase

```typescript
// TypeScript — config/env.ts
const required = (key: string) => {
  const v = process.env[key];
  if (!v) throw new Error(`Required env var missing: ${key}`);
  return v;
};
export const config = {
  apiKey: required('API_KEY'),
  dbUrl: required('DATABASE_URL'),
} as const;
```

```python
# Python — config/settings.py
import os
def required(key: str) -> str:
    v = os.environ.get(key)
    if not v: raise ValueError(f"Required env var missing: {key}")
    return v

API_KEY: str = required("API_KEY")
DATABASE_URL: str = required("DATABASE_URL")
```

### 7.2 Error Handling (All Stacks)

Every operation that can fail must:
1. Catch explicitly (not bare `except:` or empty `catch`)
2. Log with context
3. Re-throw or return a typed error response

Never swallow errors silently.

### 7.3 Architecture (All Stacks)

```
HTTP layer:       receives request → calls service → returns response
Business layer:   logic only, no HTTP/framework coupling
Data layer:       DB/external API calls only
Config layer:     env var loading, validated at startup
```

Business logic in the HTTP layer is always a refactoring target.

---

## 8. Phase 5 — Security

Run `checklists/security.md` before any PR that touches auth, data handling, external APIs, or user input.

### Non-Negotiable Minimum

- No secrets in source (scan: `grep -r "api_key\|password\|secret" src/`)
- No secrets in git history
- `.env` not committed
- Auth enforced server-side (not just client-side)
- Input validated at every user-facing endpoint
- Dependencies audited (`npm audit` / `pip-audit`)

For the full checklist, see `checklists/security.md`.

---

## 9. Phase 6 — Pre-Deploy

Run `checklists/pre-deploy.md` before every production deployment.

Mandatory passes before deploying:
- [ ] Linter / type checker clean
- [ ] Tests passing
- [ ] No secrets in diff
- [ ] All env vars set in deployment platform
- [ ] `npm audit` / `pip-audit` — no new critical CVEs
- [ ] Feature tested end-to-end in staging

---

## 10. Using the vibe-hardener Skill

The `vibe-hardener` skill automates enforcement of this SOP.

| Prompt | What it does |
|---|---|
| `use vibe-hardener to audit` | Full codebase scan with severity report |
| `use vibe-hardener to refactor [path]` | Refactor to production standard |
| `use vibe-hardener to security-review` | OWASP Top 10 + dependency scan |
| `use vibe-hardener to spec [description]` | Generate spec before implementing |
| `use vibe-hardener to review` | Pre-PR checklist |

---

## 11. Escalation

If something doesn't fit the SOP, doesn't pass checklist, or makes you uneasy — do not ship it. The cost of shipping something uncertain is always higher than the cost of slowing down.

---

## 12. Maintenance

This document should be updated when:
- The stack changes materially
- A production incident reveals a gap
- A new pattern proves itself over time

Keep the SOP and `SKILL.md` in sync. The skill is the executable form of this document.

---

*vibe-hardener SOP — MIT License*
