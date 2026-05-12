# Project Agent Configuration
# Universal source of truth for AI coding agents.
# Rename or symlink to: CLAUDE.md / AGENTS.md / GEMINI.md as needed.
# Run install.sh to place automatically for all agents.

## Project
[Replace with your project name and one-line description]

## Stack
[Replace with your stack: e.g. TypeScript + Express + PostgreSQL + Vercel]

## Active Skill
This project uses the `vibe-hardener` skill.
Installed at: `.claude/skills/vibe-hardener/SKILL.md`

Invoke:
- `use vibe-hardener to audit` → full codebase audit
- `use vibe-hardener to refactor [path]` → production-grade refactor
- `use vibe-hardener to security-review` → OWASP Top 10 scan
- `use vibe-hardener to spec [description]` → spec before implementing
- `use vibe-hardener to review` → pre-PR checklist

---

## Non-Negotiables (MUST — always apply)

- MUST use strict/typed mode for the project language
- MUST never hardcode API keys, secrets, or config values in source
- MUST load all config from environment variables, validated at startup
- MUST handle errors explicitly — no empty catch blocks, no silent swallows
- MUST write meaningful variable names — no single letters outside loops
- MUST keep functions under 50 lines — extract if longer
- MUST validate user input at every API/service boundary
- MUST NOT commit .env files
- MUST NOT use `any` / untyped without a `// justification:` comment
- MUST NOT write N+1 patterns (query/fetch inside a loop)
- MUST NOT add packages without verifying they exist
- MUST NOT push directly to main — PR required

## Anti-Patterns (always flag these)

- Business logic in HTTP route handlers
- HTTP concerns in service/business logic
- Config loaded inline wherever needed (not centrally)
- Broad exception catches with no specificity
- `console.log` / `print()` in production code paths
- Magic numbers/strings not extracted to constants
- Duplicate logic across files

## Architecture

```
[Customize this for your project structure]

Example:
src/routes/      → HTTP routing only
src/services/    → Business logic only
src/utils/       → Pure utility functions
src/types/       → Types and interfaces
src/config/      → Env var loading (fails fast on missing vars)
src/middleware/  → Framework middleware
```

## Error Handling Pattern

```typescript
// TypeScript
try {
  const result = await operation();
  return { success: true, data: result };
} catch (error) {
  logger.error('operation context', { relevantData, error });
  throw new Error(`Failed: ${error instanceof Error ? error.message : 'unknown'}`);
}
```

```python
# Python
try:
    result = await operation()
    return {"success": True, "data": result}
except SpecificError as e:
    logger.error("operation context", extra={"data": relevant_data, "error": str(e)})
    raise RuntimeError(f"Failed: {e}") from e
```

## Config Pattern (Fail Fast)

```typescript
// TypeScript — fails at startup, not silently in production
const required = (key: string) => {
  const v = process.env[key];
  if (!v) throw new Error(`Required env var missing: ${key}`);
  return v;
};
```

```python
# Python
import os
def required(key: str) -> str:
    v = os.environ.get(key)
    if not v: raise ValueError(f"Required env var missing: {key}")
    return v
```

## Git Workflow

- Branches: `feature/[id]-short-description`
- Commits: Conventional Commits — `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`
- PR required before merging to main
- No force pushes to main

## Specs

New features require a spec file before implementation.
Format: `specs/YYYY-MM-DD-feature-name.md`
Use: `"use vibe-hardener to spec [description]"` to generate.

## Session Management

- Reset at ~50k tokens to prevent context rot
- Start each session: "Read AGENTS.md and relevant spec before we begin"
- One feature per session where possible

## When in Doubt

Stop. Do not implement. Generate a spec first, or break the task into smaller pieces.
