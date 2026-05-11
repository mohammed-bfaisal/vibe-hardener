# vibe-hardener — Security Review Checklist

Run before any PR that touches auth, data handling, external APIs, or user input.

---

## Scan Commands

```bash
# Secrets in source
grep -r "api_key\|apikey\|password\|secret\|token\|sk-" . \
  --include="*.ts" --include="*.js" --include="*.py" \
  | grep -v "process.env\|os.environ\|import.meta.env\|config\.\|\.example"

# Secrets in git history
git log --all -p | grep "^+" | grep -iE "(api_key|apikey|password|secret|token|sk-)" | head -30

# .env tracked by git
git ls-files | grep "\.env$"

# CORS configuration (Node)
grep -rn "cors(" . --include="*.ts" --include="*.js"
# Flag: cors() with no options, or origin: '*'

# Rate limiting presence (Node)
grep -rn "rateLimit\|rate.limit\|throttle" . --include="*.ts" --include="*.js"

# Security headers (Node)
grep -rn "helmet" . --include="*.ts" --include="*.js"

# Dependency audit
npm audit --audit-level=high      # Node
pip-audit                          # Python
cargo audit                        # Rust
```

---

## 🚨 CRITICAL — Block Deploy

- [ ] No secrets in source files
- [ ] No secrets in git history
- [ ] `.env` not git-tracked: `git ls-files | grep "\.env$"` returns nothing
- [ ] Required env vars validated at startup — app fails fast, not silently in prod
- [ ] CORS not using wildcard `*` in production
- [ ] Auth enforced server-side — not client-only
- [ ] No SQL/NoSQL injection surface (parameterized queries only)
- [ ] No `eval()` or `exec()` on user-supplied input

## 🔴 HIGH — Fix Before Merge

- [ ] Input validation on ALL user-facing endpoints
- [ ] Validation happens before business logic, not after
- [ ] Validation errors return 400 with clear message (not 500)
- [ ] Auth middleware applied to ALL protected routes
- [ ] Authorization checked in service layer, not only at route level
- [ ] Error messages don't expose stack traces or internal paths to client
- [ ] No PII, passwords, or tokens logged
- [ ] All new packages verified to exist (not AI hallucinated)
- [ ] Dependency audit clean — no new critical/high CVEs
- [ ] Rate limiting on auth endpoints: login, register, password reset

## 🟡 MEDIUM — Fix This Sprint

- [ ] HTTP security headers configured (helmet or equivalent)
- [ ] File uploads (if any): MIME type whitelist + size limit + path traversal protection
- [ ] JWT/session expiry configured — not set to "never"
- [ ] HTTPS enforced in production
- [ ] Dependency lockfile committed
- [ ] No hardcoded fallback credentials "for development"

## LLM / AI API Specific

If the project calls any LLM API:

- [ ] System prompts don't contain raw user input (sanitize first)
- [ ] User-supplied content in prompts is bounded/escaped
- [ ] Model/endpoint comes from config, not user input
- [ ] LLM responses not rendered as raw HTML (XSS risk)
- [ ] Rate limiting on endpoints that trigger LLM calls
- [ ] Prompt injection surface considered for all user-influenced prompts

---

## Security Verdict

```
Date:
Reviewer:

[ ] PASS — Deploy when ready
[ ] CONDITIONAL PASS — Fix HIGH items, then deploy
[ ] BLOCKED — Critical issues must be resolved first

Critical issues found:
High issues found:
Notes:
```
