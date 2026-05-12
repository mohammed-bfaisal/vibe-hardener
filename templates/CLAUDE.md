# [Project Name] — Claude Code Configuration

## Stack
[Your stack: e.g. TypeScript + React + Express + PostgreSQL + Vercel]

## Skill
This project uses the `vibe-hardener` skill.
Installed at: `.claude/skills/vibe-hardener/SKILL.md`

Invoke:
- `use vibe-hardener to audit` — scan for production issues
- `use vibe-hardener to refactor [path]` — refactor to production standard
- `use vibe-hardener to security-review` — OWASP Top 10 scan
- `use vibe-hardener to spec [description]` — spec before implementing
- `use vibe-hardener to review` — pre-PR checklist

## Non-Negotiables

- Strict/typed mode always — no untyped without `// justification:` comment
- Never hardcode secrets, API keys, or config values
- All config from env vars, validated at startup (fails fast, not silently)
- Every async operation has explicit error handling — no silent catch blocks
- No `console.log` / `print()` in production code paths
- Functions under 50 lines
- No N+1 patterns
- Input validation at every API boundary
- No pushing to main without PR

## Architecture

```
[Add your project structure here]

Example:
src/routes/      → HTTP routing only
src/services/    → Business logic only
src/config/      → Env var loading, fails fast on missing vars
```

## Error Pattern

```typescript
try {
  const result = await operation();
  return { success: true, data: result };
} catch (error) {
  logger.error('context', { error });
  throw new Error(`Failed: ${error instanceof Error ? error.message : 'unknown'}`);
}
```

## Config Pattern

```typescript
// config/env.ts — single source of truth
const required = (key: string) => {
  const v = process.env[key];
  if (!v) throw new Error(`Required env var missing: ${key}`);
  return v;
};
export const config = { apiKey: required('API_KEY') };
```

## Git

- Branches: `feature/[id]-description`
- Commits: Conventional Commits
- PR before merge to main

## Specs

New features need a spec in `specs/` before implementation.
Format: `specs/YYYY-MM-DD-feature-name.md`

## Session Management

- Reset at ~50k tokens
- Start each session: "Read CLAUDE.md and specs/ before we begin"
- New feature = new session

## Available Commands

```bash
[Add your project's commands here]
```

## When Stuck

Stop. Generate a spec first. Break into smaller pieces. New session.
