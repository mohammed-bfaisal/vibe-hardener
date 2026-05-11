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

## Before Suggesting New Features

Check if a spec exists in `specs/`. If not, suggest creating one before implementing.

## Naming

- Variables: camelCase (TS/JS) / snake_case (Python)
- Types/Classes: PascalCase
- Constants: SCREAMING_SNAKE_CASE
- Booleans: isX, hasX, canX, shouldX
- Files: kebab-case (TS/JS) / snake_case (Python)
