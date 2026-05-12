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

## What it is

A single `SKILL.md` file — an agent skill — that gives any AI coding agent the context, rules, and workflows of a senior software engineer. Drop it into any project and your agent will:

- **Audit** — scan for vibe-code signatures with runnable grep commands and a severity-graded report
- **Refactor** — transform to production standards: config extraction, error boundaries, SRP, typed inputs, Promise flattening, repository pattern
- **Security review** — full OWASP Top 10 pass including SSRF, path traversal, timing attacks, CSRF, CSP, cookie flags
- **Spec** — interview you, produce a complete spec (acceptance criteria, NFRs, API contract, rollback plan), then gate on approval before writing code
- **Pre-PR review** — checklist covering code quality, architecture, security, breaking changes, and git hygiene

Works with TypeScript, JavaScript, Python, and Go. Degrades gracefully when the agent has no shell access.

It's not a linter. It's not a static analysis tool. It's the engineering judgment layer that AI agents are missing.

---

## Works with every major agent

| Agent | How it loads |
|---|---|
| **Claude Code** | `.claude/skills/vibe-hardener/SKILL.md` |
| **Codex CLI** | `AGENTS.md` at project root |
| **Cursor** | `.cursor/rules/vibe-hardener.mdc` |
| **GitHub Copilot** | `.github/copilot-instructions.md` |
| **Windsurf** | `.windsurfrules` |
| **Gemini CLI** | `GEMINI.md` at project root |
| **Any agent** | `SKILL.md` at project root — reference it manually |

---

## Install

### Automated (recommended)

```bash
# Clone the repo
git clone https://github.com/mohammed-bfaisal/vibe-hardener.git

# Run the installer in your project directory
cd your-project
bash /path/to/vibe-hardener/install.sh
```

The installer detects which agents you have configured and places the skill in every right location automatically.

### Manual — Claude Code

```bash
mkdir -p .claude/skills/vibe-hardener
curl -o .claude/skills/vibe-hardener/SKILL.md \
  https://raw.githubusercontent.com/mohammed-bfaisal/vibe-hardener/main/SKILL.md
```

### Manual — Any other agent

```bash
# Download AGENTS.md as your project's universal agent config
curl -o AGENTS.md \
  https://raw.githubusercontent.com/mohammed-bfaisal/vibe-hardener/main/AGENTS.md
```

---

## Usage

### In Claude Code

```
use vibe-hardener to audit
→ Scans your codebase, reports every vibe-code signature with file:line and severity

use vibe-hardener to refactor src/api/users.ts
→ Refactors to production standard with plan shown before execution

use vibe-hardener to security-review
→ Full OWASP Top 10 scan + dependency audit guidance

use vibe-hardener to spec "add rate limiting to the auth endpoint"
→ Generates a proper spec before a single line of code is written

use vibe-hardener to review
→ Pre-PR checklist — catch everything before you push
```

### In any agent

Reference it directly in your prompt:

```
"Using vibe-hardener standards, audit this codebase for production readiness"
"Following the vibe-hardener spec protocol, help me plan this feature before implementing"
"Review this diff using vibe-hardener's pre-PR checklist"
```

---

## What the audit catches

Runs scan commands first (grep, git log, npm audit), then a manual pattern pass. If your agent has no shell access it falls back to reading files directly and tells you which scans to run manually.

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
- N+1 query/fetch patterns
- Duplicate business logic
- No input validation on endpoints
- `readFileSync` / `writeFileSync` in request handlers (blocks event loop)
- External HTTP calls with no timeout
- React: `key={index}` on lists, stale `useEffect` deps, direct state mutation, `dangerouslySetInnerHTML`

**Architecture smells**
- God files over 300 lines
- Business logic in route handlers
- Deep nesting (3+ levels)
- Circular imports
- Config scattered instead of centrally loaded

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

Every refactor follows a fixed protocol: read first, state the plan, confirm before executing, one concern at a time. Transformations applied: config extraction, error boundaries, separation of concerns, magic value constants, input types, Promise chain flattening, and database repository isolation.

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

[After you answer, it generates specs/2026-05-12-user-auth.md]
[The spec includes: acceptance criteria, NFRs, API contract shape, edge cases, rollback plan]
[Only after you approve the spec does it write a single line of code]
```

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
