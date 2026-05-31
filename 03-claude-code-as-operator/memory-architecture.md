# Memory architecture (the 4 layers in detail)

Already introduced in [00 — four-layer memory](../00-principles/four-layer-memory.md). This file is the operational detail.

## Layer 1 — Global rules

**File:** `~/.claude/CLAUDE.md`

**Purpose:** rules that hold across *every* project.

**Loaded:** every session, regardless of project.

**Cap:** ~200 lines. Cap is non-negotiable; exceed it and load time / token cost compound.

> **This cap is now vendor-confirmed (Q03.11, Q03.8).** Anthropic's own docs say: "target under 200 lines per CLAUDE.md file. Longer files consume more context and **reduce adherence**."[¹] The deeper reason is *context rot*: Anthropic's context-engineering guidance describes a finite "attention budget" with diminishing returns,[²] and independent benchmarks converge on degradation well before the window fills — RULER's "effective context length" is far below the advertised max,[³] NoLiMa found 11 of 12 models drop below 50% of short-context performance by 32K tokens,[⁴] and Chroma's *Context Rot* study saw all 18 tested frontier models degrade as input grows.[⁵] Always-loaded rules compete for that budget on *every* turn — so Layer 1 stays small not for load time alone, but because a bloated always-on context measurably lowers how well the agent follows any single rule in it.

### What goes here

- Git workflow rules (branch naming, commit message format, push rules)
- Secret management policy
- PM tool I/O rules (link to siblings; don't inline)
- Testing requirements
- Memory-system explanation
- Routing decisions (which MCP for which task — link to sibling)
- Personal info (name, email, who-you-are paragraph)
- High-stakes lessons learned (the ones that apply to every project)

### What does NOT go here

- Project-specific tech stack
- Current project state
- Project-specific conventions
- Anything project-scoped

### The discipline rule

> Keep this file under 200 lines. When adding a new rule, outsource the details to `~/.claude/docs/<rule-name>.md` and add a one-line reference here. Only the rule trigger and file pointer belong inline.

Concrete example. Instead of writing the full pre-push review checklist inline:

```markdown
- **Review before push (Non-Negotiable):** See `~/.claude/docs/pr-review-standard.md`.
```

The trigger ("Review before push") is inline; the detail is outsourced.

This works because the agent reads `~/.claude/CLAUDE.md` every session but only reads the sibling docs when needed. Inlining the full content of the sibling would slow every session AND make the global rules harder to scan.

### Example structure

A full, copy-pasteable Layer-1 outline lives in [`examples/global-CLAUDE.md.template`](../examples/global-CLAUDE.md.template) — short sections (Memory, Secrets, Testing, PM tool, Tools, MCP, Browser, Git, Session/Research/Lessons discipline, Gotchas, Who-I-Am), each a few lines that point elsewhere for detail. The file should read top-to-bottom in under two minutes.

## Layer 2 — Project rules

**File:** `<repo>/CLAUDE.md`

**Purpose:** rules specific to ONE project. Tech stack, key commands, project-specific conventions.

**Loaded:** when working in that project.

**Cap:** typically 50-150 lines.

### What goes here

- Project name and one-line purpose
- Pointer back to global rules: `See ~/.claude/CLAUDE.md for global conventions.`
- Project-specific tech stack (Python 3.12, FastAPI, ...)
- Key commands (build, test, lint, deploy, run-locally)
- Project-specific conventions that override or extend global
- Architecture notes the agent needs every time it touches the repo
- Project-specific gotchas

### What does NOT go here

- Duplicating global rules — link to them
- Current project state ("we're on phase 3") — that's auto-memory
- Narratives — those are auto-memory

### Example (Python project)

```markdown
# <project-name>

<one-line purpose>

See `~/.claude/CLAUDE.md` for global conventions (git workflow, commit discipline, PM tool, testing).

## Stack
- Python 3.12 via uv
- FastAPI for the API
- SQLAlchemy 2.x async for DB
- PostgreSQL 16
- pytest + pytest-asyncio for tests

## Key commands
- `uv run pytest` — full test suite
- `uv run uvicorn src.main:app --reload` — local dev
- `uv run ruff check` — lint
- `make migrate` — apply alembic migrations

## Conventions
- All async endpoints; no sync routes
- Use `app.deps.get_session()` for DB sessions, never instantiate `AsyncSession` inline
- Tests live in `tests/`, mirror `src/` structure

## Gotchas
- Alembic autogenerate doesn't see enum changes; manual handling required
- The /admin route bypasses auth in dev; never deploy with DEBUG=true

## Project-specific MCP
- This repo's `.mcp.json` enables `mcp__plugin_linear_linear__*` for cloud sessions
- Locally, use `linearis` CLI per global rules
```

## Layer 3 — Auto-memory

**Path:** `~/.claude/projects/<encoded-project-path>/memory/`

**Encoded path:** Claude Code encodes the absolute path with `-` separators. Project `~/Projects/research/learning-rust/` becomes `-Users-<user>-Projects-research-learning-rust`.

**Purpose:** the "where we left off" file for this project. Narrative, current state, decisions, blockers.

**Loaded:** every session in that project.

**Structure:**

```
memory/
├── MEMORY.md                    # index — links to other files
├── project_overview.md          # the project's purpose, scope
├── project_priorities.md        # what matters now and why
├── feedback_<topic>.md          # lessons learned, per topic
├── reference_<topic>.md         # pointers to external resources
└── ...
```

**Cap:** `MEMORY.md` ≤ 150 lines. Sibling files unbounded (only the index loads automatically; siblings load when referenced).

### MEMORY.md as an index

The index points at the real memory content:

```markdown
# <project> — Auto-memory Index

- [Project overview](project_overview.md) — one-line summary
- [Active priorities](project_priorities.md) — what matters now
- [ADHD framing](feedback_adhd_framing.md) — ADHD-aware design constraints
- [No Google calendar](feedback_no_google_calendar.md) — time layer constraints
- [WIP cap exemption](feedback_wip_cap_continuous_area_exempt.md) — continuous areas exempt from cap
```

One line per memory file. The line gives just enough context to know whether to follow the link.

### The 4 memory types

(From global CLAUDE.md):

| Type | When to save | Body structure |
|---|---|---|
| `user` | When you learn about the user — role, preferences, knowledge | Plain description |
| `feedback` | When user corrects your approach OR confirms a non-obvious approach worked | Rule + **Why:** + **How to apply:** |
| `project` | When you learn about ongoing work, goals, initiatives, bugs | Fact/decision + **Why:** + **How to apply:** |
| `reference` | When you learn about external resources and their purpose | Plain pointer |

Mark each memory file with `type:` in frontmatter:
```yaml
---
name: feedback_<topic>
description: <one-line summary>
metadata:
  type: feedback
---
```

The frontmatter is mechanical — your tooling can grep for `type: feedback` to surface all feedback memories.

### What goes in auto-memory

- Current state of the project — what's in progress, what's blocked
- Narratives the user told you that future sessions need
- Lessons learned per topic
- Decisions made and the reasoning
- Pointers to external resources

### What does NOT go in auto-memory

- Code patterns (read the code)
- Git history (use `git log`)
- Anything in the project's CLAUDE.md (don't duplicate)
- Anything ephemeral (this-conversation-only state)

## Layer 4 — Cross-project memory

**Backed by:** an MCP memory service (e.g., `~/.mcp_memory/memory.db`, SQLite-vec).

**Purpose:** searchable memory that crosses project boundaries.

**Loaded:** on demand via `retrieve_memory` / `search_by_tag` MCP calls.

### What goes here

- Preferences ("I prefer Sonnet over Haiku for routine tasks")
- Gotchas that apply globally
- Decisions that came up in one project but inform others
- Research findings that might be relevant elsewhere

### Tagging discipline

**Always tag memories with `project:<name>`** when the memory is project-scoped. Without tags, retrieving "what do I know about X?" pulls hits from all projects, with no way to filter.

Cross-project memories (preferences, general gotchas) skip the project tag — they're meant to surface everywhere.

### When to store vs. when to skip

Store to Layer 4 after:
- Significant decisions
- Research conclusions
- State changes that matter cross-project

Skip Layer 4 for:
- File contents (just read the file)
- Things already in Layer 1/2/3 (don't duplicate)
- One-conversation context (ephemeral)

## Prompt caching and the layers (Q03.9)

The 4-layer model and prompt caching reinforce each other. Claude Code caches automatically with a **stable-prefix order: system prompt → project context (CLAUDE.md + auto-memory + unscoped rules) → conversation.**[⁶] So **Layers 1 and 2 cache automatically** as part of that prefix and cache-*hit* on every turn — as long as the prefix doesn't change. On a Claude subscription, Claude Code requests the **1-hour cache TTL** for free; cache reads bill at ~0.1× input rate.[⁶]

Two consequences for how you treat memory:

- **Editing CLAUDE.md mid-session is cache-safe but doesn't take effect until restart/`/compact`** — the running session keeps the cached prefix.[⁶] Don't expect a live edit to change behavior immediately.
- **Layer 4 (on-demand MCP recall) deliberately sits *after* the cached prefix** — it's a tool call, not always-on context, so querying it doesn't invalidate the Layer 1/2 cache. This is another reason cross-project memory belongs in Layer 4, not stuffed into Layer 1.

Keeping Layers 1–2 small and stable is therefore doubly paid back: less attention budget spent (above) **and** a higher cache-hit rate. See [agent-rules — cost and cache accounting](./agent-rules.md#cost-and-cache-hit-accounting-q0326q0327).

## How this compares to other agent-memory systems

The 4-layer model is one design among many (mem0, Letta, LangGraph, Cursor/Aider/Cline memory). The full structured comparison — and when to reach for a vector store instead of a flat file — is in [memory-comparison](./memory-comparison.md).

## Boundary rules

| Situation | Layer |
|---|---|
| A rule that applies to all projects | 1 |
| A rule that applies to one project | 2 (committed to repo) or 3 (per-machine) |
| Current state of one project | 3, never 1 or 2 |
| A lesson learned worth searching later | 4 (tag with project if scoped) |
| A narrative from the user | 3, immediately |

## Field-tested gotchas

**The 200-line Layer 1 cap is enforced retroactively.** If you let it grow to 400, every future session loads slowly. Audit monthly: if Layer 1 > 250 lines, refactor — extract details to sibling docs.

**Layer 2 duplication of Layer 1.** Tempting to inline global rules in project CLAUDE.md "so it's all visible." Don't — link instead. When global rules change, you'd otherwise have N project CLAUDE.md to update.

**Layer 3 "MEMORY.md as everything" anti-pattern.** Writing all narratives into MEMORY.md instead of separate files makes the index unreadable. MEMORY.md should be ~10-15 link lines, max.

**Layer 4 tag drift.** If you stop tagging consistently, retrieval becomes unreliable. Either always tag or never tag — mixing is the worst.

**Re-encoding when projects move.** Rename `~/Projects/foo/` to `~/Projects/apps/foo/` and the memory dir at `~/.claude/projects/-Users-<u>-Projects-foo/` doesn't follow. Either move the memory dir to match the new encoding, or symlink. If you skip this, the project loses its memory.

**Stale memories.** A memory written in February referencing "we're on Phase 3" is stale by April. Mark memories with a date; have a quarterly sweep to invalidate stale ones.

## Innovative pattern: memory health check

Daily launchd job runs:
```bash
# Layer 1 size check
wc -l ~/.claude/CLAUDE.md | awk '$1 > 200 { print "Layer 1 over cap: " $1 }'

# Layer 3 index check across all projects
for d in ~/.claude/projects/*/memory/; do
  if [ -f "$d/MEMORY.md" ]; then
    lines=$(wc -l < "$d/MEMORY.md")
    [ $lines -gt 150 ] && echo "$d MEMORY.md over cap: $lines"
  fi
done
```

Surfaces cap violations within 24 hours.

## Innovative pattern: cross-layer linkage discipline

Memory files link to each other with `[[name]]` syntax. The mapper script reads all memories, builds a graph, and reports unlinked memories (orphans) and broken links.

Layer 3 memories often reference Layer 1 rules: `Per [global rule on testing](~/.claude/CLAUDE.md#testing)`. When Layer 1 changes, Layer 3 references should be revalidated.

## Related

- [00 — four-layer memory](../00-principles/four-layer-memory.md) — the principles version
- [CLAUDE.md template](./claude-md-template.md) — what Layer 2 looks like
- [Memory comparison](./memory-comparison.md) — vs mem0, Letta, LangGraph, Cursor/Aider/Cline
- [Chapter 06 — Session discipline](../06-session-discipline/) — when to write memory vs. when not
- [sources.md](./sources.md) — full bibliography

---

[¹]: https://code.claude.com/docs/en/memory — accessed 2026-05-31
[²]: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — accessed 2026-05-31
[³]: RULER, arXiv:2404.06654 — accessed 2026-05-31
[⁴]: NoLiMa, arXiv:2502.05167 — accessed 2026-05-31
[⁵]: https://www.trychroma.com/research/context-rot — accessed 2026-05-31
[⁶]: https://code.claude.com/docs/en/prompt-caching — accessed 2026-05-31
