# AI Engineering Ecosystem Reference

Full catalog of tools, repos, and skills for turning AI-generated code into production code. Research compiled May 2026.

---

## The Stack We Recommend (All Free at Solo/Small Team Scale)

| Layer | Tool | What it does | Cost |
|---|---|---|---|
| Spec-first | `github/spec-kit` | Structured spec workflow for any agent | Free |
| Agent guardrails | `vibe-hardener` (this repo) | Engineering standards as a skill | Free |
| PR review | CodeRabbit | AI PR review, 2M repos | Free tier |
| Code health | CodeScene Community | 25+ metrics, hotspot detection | Free |
| Static analysis | SonarQube Community | 6500+ rules, self-hosted | Free |
| Security | Semgrep | SAST, custom rules, OWASP Top 10 | Free ≤10 contributors |
| Dependency audit | `npm audit` / `pip-audit` | Built-in, no setup | Free |

Total: $0.

---

## Tier 1 — Use Today

### Spec-Driven Development

| Tool | Stars | What | Link |
|---|---|---|---|
| `github/spec-kit` | 93k | Official GitHub SDD toolkit, 29 agent integrations | github.com/github/spec-kit |
| `BMAD-METHOD` | High | 12+ specialist agents across full SDLC | github.com/bmad-code-org/BMAD-METHOD |
| Amazon Kiro | — | Spec-driven IDE (VS Code fork), EARS notation | kiro.dev |

### Claude Code Config

| Repo | What |
|---|---|
| `smartwhale8/claude-playbook` | Production-ready .claude/ template with guardrails |
| `MuhammadUsmanGM/claude-code-best-practices` | 11 CLAUDE.md templates + 4 starter kits |
| `shanraisshan/claude-code-best-practice` | "Vibe to agentic engineering" — Boris Cherny's tips |
| `affaan-m/everything-claude-code` | Hackathon winner config |

### Agent Skills

| Repo | What |
|---|---|
| `VoltAgent/awesome-agent-skills` | 1000+ skills from Anthropic, Vercel, Stripe, Netlify, etc. |
| `VoltAgent/awesome-claude-code-subagents` | 100+ specialized Claude Code subagents |
| `travisvn/awesome-claude-skills` | Curated Claude Skills list |
| `l-mb/python-refactoring-skills` | 8 Python-specific refactoring skills |
| `levnikolaevich/claude-code-skills` | Plugin suite + code knowledge graph MCP |

### Cursor

| Repo | What |
|---|---|
| `PatrickJS/awesome-cursorrules` | Curated .cursorrules + .cursor/rules/ configs |
| `murataslan1/cursor-ai-tips` | Community tips, agentic engineering workflow |

---

## Tier 2 — Evaluate Next Quarter

| Tool | Type | What | Cost |
|---|---|---|---|
| Greptile | Full-codebase review | Semantic graph, catches cross-file breaks | $0.45/file (cap $50/dev/mo) |
| Macroscope | AI PR review | Creates fix PRs automatically, self-heals CI failures | Paid |
| Graphite Agent | PR review + stacks | Stacked PRs, 55% fix rate vs 49% for humans | Paid |
| DeepSource | Static analysis | 5000+ rules, AI autofix, <5% false positives | $12-24/user/mo |
| Snyk Code | Security SAST | ~80% autofix accuracy on security vulns | Free tier |
| OpenRewrite | Mass refactoring | 5000+ deterministic recipes, Java/Python/YAML | Free |

---

## Tier 3 — Enterprise

| Tool | Type | What | Cost |
|---|---|---|---|
| Devin (Cognition) | Autonomous agent | Full autonomous refactoring, used at Nubank/Goldman | $500+/mo |
| Augment Code | Context engine | Multi-repo semantic analysis, living specs | Enterprise |
| CodeScene Team | Tech debt | AI auto-refactor + PR quality gates | $299/mo for 5 users |

---

## Agent Config File Reference

| Agent | File | Location |
|---|---|---|
| Claude Code | `CLAUDE.md` | Project root |
| Codex CLI | `AGENTS.md` | Project root |
| Gemini CLI | `GEMINI.md` | Project root |
| Cursor (modern) | `.cursor/rules/*.mdc` | `.cursor/rules/` |
| Cursor (legacy) | `.cursorrules` | Project root |
| GitHub Copilot | `copilot-instructions.md` | `.github/` |
| Windsurf | `.windsurfrules` | Project root |
| Amazon Kiro | (auto) | `.kiro/` |

**Best practice:** Maintain one `AGENTS.md` as source of truth. Symlink or auto-copy to tool-specific files. Never manually duplicate content.

---

## Vibe-Code Pattern Reference

These are the signatures that tell you a codebase was built without engineering discipline.
When you see them, the codebase needs vibe-hardener treatment.

**Immediate red flags:**
- `catch (e) {}` or `except: pass` — silent error swallow
- `sk-`, `api_key`, `password` in source files
- `as any` without comment
- `app.post('/route', async (req, res) => { /* 100 lines */ })` — business logic in routes
- `fetch(url)` with no `.ok` check and no error handling
- `console.log` throughout production code
- `.env` in `git ls-files`
- `cors()` with no config options

**Slower reveals:**
- Functions with 80+ lines
- Same logic in 3+ places
- Fetches inside `.forEach` / `for` loops
- Config values scattered throughout (not centralized)
- No `specs/` directory — features built without specs

---

## Key Papers and Posts

- GitClear longitudinal study: AI coding increased code duplication 4x from 2021-2024, refactoring dropped 60%
- Backslash Security: 69 vulnerabilities found across 15 AI-generated test apps
- CodeRabbit analysis: AI-authored PRs have 2.74x more security vulnerabilities and 3x more readability issues
- METR RCT (July 2025): Developer productivity with AI agents was lower than expected on complex tasks requiring deep context
- Addy Osmani (Google): "Vibe coding your way to a production codebase is clearly risky"

---

*vibe-hardener ecosystem reference — github.com/mohammed-bfaisal/vibe-hardener*
