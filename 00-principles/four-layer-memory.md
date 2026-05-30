# 4-layer memory architecture

Solo engineering with AI agents involves a lot of context — preferences, conventions, project state, lessons learned. The mistake is to dump it all in one place. The pattern that works is **four layers, each with a defined scope and lifecycle**.

| Layer | Lives at | Scope | Loaded into agent context | Synced via |
|---|---|---|---|---|
| **1. Global rules** | `~/.claude/CLAUDE.md` (or equivalent) | All projects, all sessions | Always | Syncthing / dotfiles repo |
| **2. Project rules** | `<repo>/CLAUDE.md` | One project, all sessions in that project | When working in that project | Git (committed to repo) |
| **3. Auto-memory** | `~/.claude/projects/<encoded-path>/memory/` | One project, persistent "where we left off" | Always (project-scoped) | Syncthing |
| **4. Cross-project memory** | A vector-searchable store (MCP memory service, e.g. SQLite-vec) | All projects, queried on demand | On `retrieve_memory` calls | Syncthing / sync of DB file |

Each layer has a job. Mixing them creates rot.

## Layer 1 — Global rules

What it's for: rules that hold across *every* project. Git workflow conventions. PM tool I/O rules. Secrets policy. Tool-routing decisions (which MCP for which task).

What it's NOT for: project-specific tech stacks, current state, narratives.

**Cap it.** Keep it under ~200 lines. When a new rule gets long, outsource the details to a sibling doc and add a one-line reference. The agent loads this file *every* session, so token cost compounds.

Example: instead of writing the full PR review checklist inline, reference a sibling doc:
```
- **Review before push:** see ~/.claude/docs/pr-review-standard.md
```

## Layer 2 — Project rules

What it's for: rules specific to *one* project. Project-specific tech stack. Conventions that override or extend the global rules. Key commands (build, test, deploy). Architecture notes that an agent needs every time it touches the repo.

What it's NOT for: duplicating global rules (just reference them), current sprint state, narratives.

Every project you own MUST have one. When you enter a project missing it, create it before doing other work. For projects you don't own (vendored repos, OSS forks you contribute to), don't commit a project CLAUDE.md — use Layer 3 instead.

## Layer 3 — Auto-memory

What it's for: the "where we left off" file for one project. Current state, in-progress decisions, blockers, narrative context from recent sessions. Lessons learned that are project-specific.

Lives in a per-project directory keyed by the absolute path (Claude Code's convention: `~/.claude/projects/-Users-<u>-Projects-<repo>/memory/`).

**Cap it.** The index file (often `MEMORY.md`) loads into context every session — keep it under ~150 lines. Real memory content lives in sibling files; the index just points at them.

Update when project state changes materially. "Materially" = decisions made, blockers found, narrative context that future sessions need.

## Layer 4 — Cross-project memory

What it's for: searchable memory that crosses project boundaries. Preferences ("I prefer Sonnet over Haiku for X"). Gotchas that apply globally. Decisions that came up in one project but inform others.

Implemented as an MCP memory service backed by a vector DB (SQLite-vec, Chroma, etc.). One shared DB across all projects.

**Tag everything with `project:<name>`** so memories don't bleed across projects when you query. Cross-project memories (general preferences, global gotchas) can skip the project tag.

Use `store_memory` after significant actions; use `retrieve_memory` / `search_by_tag` to recall. Never use it as a file storage — for files, read the file.

## Boundary rules

- **A rule that applies to all projects** → Layer 1.
- **A rule that applies to one project** → Layer 2 (committed) or Layer 3 (per-machine).
- **Current state of one project** → Layer 3. Never Layer 1 or 2 (they get out of date).
- **A lesson learned that's worth searching for later** → Layer 4 with tags.
- **A narrative from the user that future sessions need** → Layer 3 immediately. Don't filter by "is this project state" — narratives ARE state.

## What this rules out

- **One giant `CLAUDE.md` with everything in it.** Loads slowly, decays fast, mixes scopes.
- **Memory written to chat history and lost.** Chat history is ephemeral; memory persists.
- **State written to memory but loaded by reading the whole DB.** That's why Layer 4 is search-only.

## What this rules in

- **Layered scope** — each rule lives at exactly one layer.
- **Cap by lines** — Layer 1 ~200, Layer 3 index ~150. Cap prevents rot.
- **Pointers, not inlining** — Layer 1 references siblings instead of inlining them.

## Why this matters for solo engineering

In a team setting, the team is part of the memory — you can ask someone. Solo, the only memory across sessions is the file system. The 4 layers are how you keep "what I know" structured enough that future-you (or your agent) can find it.

If you treat it as one bucket, you'll either over-load Layer 1 (slow, expensive) or under-record Layer 3 (lose context every session). Both fail silently.

## Related

- Chapter 03 — Claude Code as operator → details on each layer's mechanics
- Auto-memory rules: every project you start needs Layer 3 set up first session
- See also: [`feedback_adhd_framing`](./adhd-aware-design.md) — single source of truth at the *capture* level; this is single source of truth at the *memory* level
