# [Project Name] — Agent Configuration
# Universal source of truth — symlink as CLAUDE.md, AGENTS.md, GEMINI.md as needed.

## Project
[Name and one-line description]

## Stack
[e.g. TypeScript + React + Express + PostgreSQL + Vercel]

## Skill
vibe-hardener skill installed at: `.claude/skills/vibe-hardener/SKILL.md`

---

## Non-Negotiables (MUST)

- MUST use strict/typed mode
- MUST never hardcode secrets or config values
- MUST load all config from env vars (fail fast if missing)
- MUST handle errors explicitly — no empty catch blocks
- MUST keep functions under 50 lines
- MUST validate user input at all endpoints
- MUST NOT commit .env files
- MUST NOT use untyped/any without justification comment
- MUST NOT write N+1 patterns
- MUST NOT add unverified packages
- MUST NOT push directly to main

## Architecture

```
[Your structure here]
```

## Error Pattern

```
Catch → Log with context → Rethrow with context
Never: silent swallow
Never: untyped catch (e)
```

## Config Pattern

```
One central config file → validates all env vars at startup → exported typed constants
Never: process.env.X scattered throughout codebase
```

## Git

- Branches: `feature/[id]-description`
- Commits: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`
- PR required before main

## Specs

Features need `specs/YYYY-MM-DD-name.md` before implementation.
