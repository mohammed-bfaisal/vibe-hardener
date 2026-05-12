# vibe-hardener — GitHub Copilot Instructions

Apply production engineering standards to all code suggestions in this project.

## Always Apply

- Strict/typed mode — no `any` / untyped without `// justification:` comment
- Never suggest hardcoded secrets, API keys, or config values
- All config from environment variables via central config file
- Every async operation needs explicit error handling
- No `console.log` / `print()` in production paths
- Functions under 50 lines — suggest extraction if longer
- No N+1 patterns
- Input validation on all user-facing endpoints

## Architecture

Routes do routing only. Services do business logic only.
Never put business logic in route/controller handlers.

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

```python
try:
    result = await operation()
    return {"success": True, "data": result}
except SpecificError as e:
    logger.error("context", extra={"error": str(e)})
    raise RuntimeError(f"Failed: {e}") from e
```

## Config Pattern

```typescript
// ✅ Central config with fast-fail validation
const required = (key: string) => {
  const v = process.env[key];
  if (!v) throw new Error(`Required env var missing: ${key}`);
  return v;
};
```

## Security — Always Flag

- Never pass user-controlled values directly to `fetch()`, `http.get()`, or `requests.get()` (SSRF)
- Never use user input in `path.join()`, `readFile()`, or any file path without sanitization (path traversal)
- Never use `===` / `==` to compare secrets, tokens, or passwords — use timing-safe equality
- Always use parameterized queries — never string-concatenated SQL
- Cookies with `res.cookie()` must include `httpOnly: true, secure: true, sameSite: 'strict'`

## Database

- Never `SELECT *` — always list explicit columns
- Always handle the null/not-found case at the query boundary
- Wrap multi-step operations in transactions

## React

- Never use `key={index}` on list items — use a stable unique identifier
- Never use `dangerouslySetInnerHTML` without sanitizing content
- Never mutate state directly — always return new references

## Before Suggesting New Features

If the user describes a new feature, suggest they create a spec first:
`"Before implementing, let's define acceptance criteria in specs/YYYY-MM-DD-feature-name.md"`

## Naming

- Variables: camelCase (TS/JS) / snake_case (Python)
- Types/Classes: PascalCase
- Constants: SCREAMING_SNAKE_CASE
- Booleans: isX, hasX, canX, shouldX
- Files: kebab-case (TS/JS) / snake_case (Python)
