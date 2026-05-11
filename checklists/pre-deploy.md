# vibe-hardener — Pre-Deploy Checklist

Run before every production deployment.

**Project:**  
**Branch:**  
**Deploy date:**  
**Deployed by:**  

---

## Code Quality

- [ ] All acceptance criteria from `specs/` verified manually
- [ ] Type checker clean: `tsc --noEmit` / `mypy` / equivalent — zero errors
- [ ] Tests passing: zero failures
- [ ] Linter clean: `eslint` / `ruff` / `clippy` / equivalent — zero errors
- [ ] No `console.log` / `print()` in production code paths
- [ ] No commented-out code blocks in the diff
- [ ] No hardcoded config values (URLs, limits, timeouts)
- [ ] No untyped `any` without justification comment

## Environment

- [ ] All required env vars set in deployment platform (Vercel / Railway / Fly.io / etc.)
- [ ] `.env` NOT committed: `git ls-files | grep "\.env$"` returns nothing
- [ ] `.env.example` updated with any new vars added in this release
- [ ] App fails fast on missing required vars (not silently in prod)

## Security

- [ ] No secrets in diff: `git diff main...HEAD | grep "^+" | grep -iE "(key|secret|token|password)"`
- [ ] Dependency audit clean — no NEW critical/high CVEs: `npm audit` / `pip-audit`
- [ ] Input validation on any new user endpoints
- [ ] Auth on any new protected routes

## Dependencies

- [ ] Lockfile committed (`package-lock.json` / `poetry.lock` / `Cargo.lock`)
- [ ] All new packages verified to exist — not AI hallucinated
- [ ] No packages removed that are still used

## Git

- [ ] Branch up to date with main (rebased, not merged)
- [ ] Commit messages follow Conventional Commits
- [ ] PR has clear description: what changed and why
- [ ] Diff reviewed line by line (self-review minimum)

## Documentation

- [ ] README updated if setup steps or env vars changed
- [ ] Spec file in `specs/` reflects what was actually built
- [ ] `.env.example` up to date

## Functional

- [ ] Feature works end-to-end in staging/preview environment
- [ ] Edge cases from spec tested manually
- [ ] Existing features not broken (smoke test adjacent functionality)
- [ ] Error states tested: what happens when dependencies are down

## Rollback

- [ ] Know which commit to revert to if this breaks something
- [ ] Database migrations are reversible (or backup exists)

---

## Sign-Off

All items above checked: **YES / NO**

Skipped items and why:
```
Item: 
Reason: 
Accepted risk: 
```

Approved to deploy: **YES / NO**
