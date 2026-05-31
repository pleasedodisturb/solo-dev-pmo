# CLAUDE.md template

> Every repo you own MUST have a `CLAUDE.md` at root. If you enter one missing it, create it immediately. For repos you don't own, never commit one — use Layer 3 auto-memory instead.

## Why every repo gets one

A `CLAUDE.md` at the repo root is the agent's contract for this project. Without it, the agent has to discover everything (tech stack, key commands, conventions) every session. That discovery:
- Costs tokens
- Doesn't always succeed
- Misses project-specific gotchas

The file is small (<150 lines) and pays back in every session that touches the project.

## The template

```markdown
# <project-name>

<one-line purpose: what this project is for>

See `~/.claude/CLAUDE.md` for global conventions (git workflow, commit discipline, PM tool, testing).

## Stack

<list the tech stack: language + version + key frameworks>

## Key commands

- `<cmd>` — <what it does>
- `<cmd>` — <what it does>

## Conventions

<project-specific conventions that override or extend global>

## Architecture notes

<the 3-5 things an agent needs every time it touches this repo>

## Gotchas

<the landmines specific to this project>

## Project-specific MCP / tooling

<any MCP enabled per-project, any project-specific agent rules>
```

Keep project CLAUDE.md focused on what's unique to that project — don't duplicate global rules, reference them.

## What goes in each section

### Project name + purpose

The first paragraph is what the project IS. One sentence. Not its full architecture.

Examples:
- ✓ "A meta-program-management system to manage, audit, review, and optimize the whole solo-dev workflow."
- ✓ "A FastAPI service that scores job postings against a candidate profile."
- ❌ "This is a comprehensive..." (too vague)
- ❌ "Built with FastAPI, uvicorn..." (that's stack, not purpose)

### Pointer to global

A single line:
```
See `~/.claude/CLAUDE.md` for global conventions (git workflow, commit discipline, PM tool, testing).
```

This is the affordance that lets the agent know "global rules apply here" without re-stating them.

### Stack

Bullet list of what runs. Be specific about versions when they matter (Python 3.12 vs Python 3.11 — matters; FastAPI vs Flask — matters).

```markdown
## Stack

- Python 3.12 via `uv`
- FastAPI for the API
- SQLAlchemy 2.x async for DB layer
- PostgreSQL 16
- pytest + pytest-asyncio for tests
- ruff for lint, mypy for types
```

If your stack includes deprecated patterns, note them: `Some routes still use sync handlers — these are legacy; new routes async.`

### Key commands

The 5-10 commands you (or the agent) run constantly:

```markdown
## Key commands

- `uv run pytest` — full test suite
- `uv run uvicorn src.main:app --reload` — local dev server
- `uv run ruff check && uv run mypy src` — lint + typecheck
- `make migrate` — apply alembic migrations
- `make seed` — seed dev DB
```

The agent reads this and knows how to run, test, deploy without grepping the README.

### Conventions

Project-specific. Two patterns:

**Override of global rules:** *"This project uses single-quotes in JSON output; global rules said double, but this matches the legacy clients."*

**Extension of global rules:** *"Beyond global commit rules, this repo requires every commit to update CHANGELOG.md."*

Don't duplicate global rules. Don't list every convention; list the ones the agent would otherwise guess wrong.

### Architecture notes

The 3-5 things that, without knowing them, will lead the agent to write bad code.

Examples:
- "All DB writes go through `services/` layer; never instantiate models in routes."
- "Authentication is via JWT, but admin routes bypass in dev. NEVER deploy with `DEBUG=true`."
- "The /tasks endpoint exposes an internal-only API; protect with `@internal_only` decorator."

These are the "you can't unsee this" rules.

### Gotchas

Specific landmines. Each one is a "you'll learn this the hard way otherwise" item:

- "Alembic autogenerate misses enum changes; manual ops required."
- "The Pinecone client v3 has a breaking change in `.upsert` signature from v2; we pin v3.0.1."
- "Running the test suite in parallel with `pytest -n auto` flakes the integration tests; use `-n 0` or `make test`."

### Project-specific MCP / tooling

Some repos enable per-project MCP via `.mcp.json`. Some require specific environment variables. Some have project-specific agents in `.claude/agents/`.

If any of those exist, list here so the agent knows where to look.

## Keep it small — now vendor-confirmed

Anthropic's guidance matches the playbook's cap: "**target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence.**"[¹] Two 2026 nuances: (1) CLAUDE.md loads in **full** regardless of length — `@import`ed files still enter context at launch, so imports aid organization, not cost. (2) For file-specific guidance, use **path-scoped rules** (`.claude/rules/*.md` with `paths:` frontmatter), which load only when a matching file is touched — the right home for "rules the agent needs only when editing `migrations/`."[¹] Move multi-step procedures to [skills](./skills-and-hooks.md), not into CLAUDE.md.

## Translating to other tools (Q03.22)

The same project-rules file under each tool's name (full matrix in [agent-platform-portability](./agent-platform-portability.md)):

```text
Cursor   → .cursor/rules/stack.mdc      Aider → CONVENTIONS.md (load via .aider.conf.yml: read: CONVENTIONS.md)
Cline    → .clinerules/                 Continue → .continue/rules/stack.md
Codex / Copilot → AGENTS.md
```

Cursor uses MDC (markdown + frontmatter); the rest are plain markdown like CLAUDE.md. Cursor example:

```markdown
---
description: Project stack and conventions
globs: ["src/**/*.py"]
alwaysApply: true
---
- Python 3.12 via uv; FastAPI; SQLAlchemy 2.x async. All async endpoints.
- `uv run pytest` for tests; never instantiate AsyncSession inline.
```

**Portability move:** if you switch tools, keep one `AGENTS.md` as source of truth (now a Linux-Foundation-stewarded standard read by Codex, Cursor, Copilot, Aider, and 20+ tools) and have `CLAUDE.md` reference it (`See @AGENTS.md`) rather than maintaining two.[²]

## For repos you don't own (OSS contributions, vendored deps)

**Don't commit a CLAUDE.md.** Two reasons:
1. The upstream maintainer doesn't want your tooling files in their repo.
2. It'll be rejected at PR review and signal that you don't know the project's norms.

Instead, put your CLAUDE.md content in Layer 3 auto-memory:

```
~/.claude/projects/-Users-<u>-Projects-upstream-<repo>/memory/project_overview.md
```

This gets loaded when you work in that project, without polluting the upstream repo.

Same goes for `.planning/` directories, `.claude/` subdirs — never in other people's repos.

## Post-rename cleanup

When you rename or move a project, run the checklist BEFORE any other work. Absolute paths survive renames and silently corrupt sessions.

The full checklist (from global ops doc):

1. **`.git/config` `core.hooksPath`** — if set to old path, unset (`git config --local --unset core.hooksPath`) or repoint.
2. **`.venv` shebangs** — `grep -l '/<OLD-NAME>/' .venv/bin/*` should return nothing. Fix: rewrite shebangs in-place (avoids dep drift) or recreate venv. Also update `.venv/pyvenv.cfg`'s `command =` line.
3. **`~/.gitconfig` signing** — prefer file-path `signingkey = /Users/<u>/.ssh/<key>` over `key::<pubkey>` literal form. File-path signing doesn't depend on SSH agent socket.
4. **`~/.zshrc` `SSH_AUTH_SOCK`** — must point to a live agent socket.
5. **MCP configs, Python pyvenv.cfg `home=` line, `~/.ssh/config` `IdentityAgent`, any symlinks into the project** — audit for the old name.

**Verify:** `git commit --allow-empty -m verify && git reset --soft HEAD~1` must succeed without overrides.

Skipping any of these costs hours later when an unexplained signing failure happens, or the venv breaks mid-test.

## Field-tested gotchas

**Bloating with global content.** Tempting to copy-paste global rules into the project CLAUDE.md so it's "self-contained." Don't. When global rules change, you'd need to update N project CLAUDE.md files. Link.

**Out-of-date conventions.** Conventions in CLAUDE.md drift from actual code. Quarterly: read your own CLAUDE.md from-scratch and check each convention is still true. Update or delete.

**Architecture notes that don't match reality.** A common pattern: CLAUDE.md says "all DB writes via `services/`" but the codebase has 12 routes that don't. Either fix the code or fix the convention.

**Project rules vs. conventions confusion.** Some teams split: `CLAUDE.md` for "rules I want my agent to follow" and `CONVENTIONS.md` for "rules for human contributors." For solo work, one file is enough.

## Innovative pattern: CLAUDE.md test script

A `test-claude-md.sh` script in each repo that verifies the claims in CLAUDE.md:

```bash
#!/usr/bin/env bash
# Verify each Key commands entry actually works
# Verify each Convention is followed by a quick grep
# Verify the gotchas referenced (e.g., specific file paths) still exist

set -e
uv run pytest --collect-only > /dev/null  # tests exist
uv run uvicorn --help > /dev/null         # uvicorn installed
test -d services/                          # services dir exists
grep -l "DEBUG=true" .env.example          # not in real .env
```

CI can run this; it catches CLAUDE.md rot.

## Innovative pattern: CLAUDE.md generator

A `gsd-init` style command:
- Detects language / framework
- Lists key commands by inspecting `package.json` / `pyproject.toml` / `Makefile`
- Pre-fills the template with these
- Leaves Conventions / Architecture / Gotchas blank for you to fill

Bootstraps from "empty project" to "CLAUDE.md present" in 30 seconds. The Gotchas section is the only one that requires real authorship.

## Related

- [Chapter 02 — Slug rules](../02-filesystem-conventions/slug-rules.md) — project names in CLAUDE.md
- [Memory architecture](./memory-architecture.md) — Layer 2 in context
- [Agent-platform portability](./agent-platform-portability.md) — rules files in other tools
- [Chapter 06 — Audit pattern](../06-session-discipline/audit-and-conventions-pattern.md) — convention files vs. CLAUDE.md

---

[¹]: https://code.claude.com/docs/en/memory — accessed 2026-05-31
[²]: https://agents.md/ ; https://openai.com/index/agentic-ai-foundation/ — accessed 2026-05-31
