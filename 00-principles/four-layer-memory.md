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

**Cap it.** Keep it under ~200 lines. When a new rule gets long, outsource the details to a sibling doc and add a one-line reference. The agent loads this file *every* session, so token cost compounds.[¹][²] (Not an arbitrary number: Claude Code loads `CLAUDE.md` in full regardless of length but Anthropic notes "shorter files produce better adherence"[²]; Cursor's own docs tell you to keep always-apply rules "under 200 words"[³]. Independent caps, same order of magnitude.)

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

**Cap it.** The index file (often `MEMORY.md`) loads into context every session — keep it under ~150 lines. Real memory content lives in sibling files; the index just points at them. (Claude Code's native Auto Memory landed on almost exactly this design: it auto-loads "the first 200 lines of `MEMORY.md`, or the first 25 KB, whichever comes first" and leaves the rest on disk[¹]. See [Native memory in 2026](#native-memory-in-2026-the-model-stopped-being-hand-rolled).)

Update when project state changes materially. "Materially" = decisions made, blockers found, narrative context that future sessions need.

## Layer 4 — Cross-project memory

What it's for: searchable memory that crosses project boundaries. Preferences ("I prefer Sonnet over Haiku for X"). Gotchas that apply globally. Decisions that came up in one project but inform others.

Implemented as an MCP memory service backed by a vector DB (SQLite-vec, Chroma, etc.). One shared DB across all projects. This is the one layer Claude Code does *not* ship natively (see [Alternatives](#alternatives)), so it's the layer worth bolting on with an external service.

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

## Native memory in 2026 — the model stopped being hand-rolled

When this chapter was first written, all four layers were hand-built on top of plain files and an MCP. In 2026 Claude Code shipped **native Auto Memory**, and most of the model is now first-party:

- **Layer 1 + Layer 2** are the native `CLAUDE.md` hierarchy — user (`~/.claude/CLAUDE.md`), project (`<repo>/CLAUDE.md`), with `@path` imports for the "pointers, not inlining" rule.[¹]
- **Layer 3** is now native **Auto Memory**: an agent-written `MEMORY.md` notebook per git repo, enabled by default, auto-loaded up to 200 lines / 25 KB, with a consolidation pass ("Auto Dream") that prunes stale notes.[¹][⁴]
- **Layer 4** is the gap. Claude Code's memory is per-repo and *not* shared across projects or machines by design[¹]; cross-project recall still needs an external service (see Alternatives).

This **validates the model rather than retiring it** — the native cap (200 lines) lands on the same heuristic this chapter published, and the user/project/notebook split is the same scope-by-lifecycle partition. What changed: you write less plumbing. What didn't: the boundary rules, and the need to add Layer 4 yourself. We did **not** downgrade the 4-layer recommendation; if anything, native support strengthens it.

## Alternatives

Other agent-memory architectures and how they map to the four layers. The honest summary: the file-based ones converge with Layers 1–3; the service-based ones are candidate **Layer 4** backends. None replaces the whole model for a solo dev syncing plain files across machines.

| System | Memory model | Maps to | Solo-dev fit |
|---|---|---|---|
| **Claude Code native** (CLAUDE.md + Auto Memory)[¹] | Hierarchical instruction files + agent-written `MEMORY.md`, 200-line/25 KB auto-load | L1, L2, L3 | Native — this is the substrate the playbook now sits on |
| **Cline Memory Bank**[⁵] | 6 fixed markdown files (`projectbrief`, `productContext`, `activeContext`, `systemPatterns`, `techContext`, `progress`) | L2 + L3 (prescriptive taxonomy) | Strong if you want a fixed file set; no L1 global or L4 cross-project |
| **Cursor rules** (`.cursor/rules/*.mdc`)[³] | Glob-scoped rule files with frontmatter | L2 only, path-targeted | Good for per-path rules; not a memory store |
| **mem0**[⁶] | Service: vector + graph + KV, scopes user/session/agent | Candidate **L4** | Use as the L4 backend; not a replacement for L1–L3 |
| **Letta / MemGPT**[⁷] | OS-style virtual memory: core (RAM) / archival (disk) / recall (history); agents run inside the Letta runtime | Automates L1 + L4 | Heavier — you adopt a runtime, not just files |
| **LangMem / LangGraph**[⁸] | episodic / semantic / procedural, tied to LangGraph state | L3 + L4 for LangGraph apps | Only if you're already on LangGraph |
| **gstack GBrain**[⁹] | Claude Code skill-bundled memory layer | L3 / L4-ish within gstack | Adopt with gstack |

**Why we keep the 4-layer framing:** it's the only one that names *scope-by-lifecycle* (a fact lives at exactly one layer) and stays sync-agnostic (plain files over Syncthing/git, no runtime to adopt). The service-based systems are better at L4 than a DIY SQLite-vec MCP — if you outgrow the DIY L4, reach for mem0 or Letta there specifically, and leave L1–L3 on the native files.

This chapter's structural ancestor is human PKM, not agent frameworks: Matuschak's evergreen-notes principles — atomic, concept-oriented, one note per idea — are the same "each fact at exactly one layer" rule applied to a human knowledge base.[¹⁰] What doesn't translate: evergreen notes are densely *cross-linked* for serendipity; agent memory layers are deliberately *partitioned* to control what loads into a finite context window.

## Sources

[1]: https://code.claude.com/docs/en/memory — Claude Code memory & Auto Memory docs. Accessed 2026-05-31.
[2]: https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts — "Give Claude context: CLAUDE.md" ("loaded in full… shorter files produce better adherence"). Accessed 2026-05-31.
[3]: https://cursor.com/docs/rules — Cursor "Rules" docs (`.cursor/rules/*.mdc`, "keep always-apply rules under 200 words"). Accessed 2026-05-31.
[4]: https://www.mindstudio.ai/blog/what-is-claude-code-auto-memory — practitioner write-up of Auto Memory / Auto Dream mechanics (corroborates [1]). Accessed 2026-05-31.
[5]: https://docs.cline.bot/features/memory-bank — Cline Memory Bank (6-file structure). Accessed 2026-05-31.
[6]: https://github.com/mem0ai/mem0 — mem0 memory service (user/session/agent scopes; vector+graph+KV). Accessed 2026-05-31.
[7]: https://arxiv.org/abs/2310.08560 — Packer et al., "MemGPT: Towards LLMs as Operating Systems" (2023); now the Letta runtime (github.com/letta-ai/letta). Accessed 2026-05-31.
[8]: https://github.com/langchain-ai/langmem — LangMem (episodic/semantic/procedural) for LangGraph. Accessed 2026-05-31.
[9]: https://github.com/garrytan/gstack — gstack GBrain memory layer. Accessed 2026-05-31.
[10]: https://notes.andymatuschak.org/Evergreen_notes — Andy Matuschak, evergreen notes (atomic, concept-oriented, densely linked). Accessed 2026-05-31.

## Related

- Chapter 03 — Claude Code as operator → details on each layer's mechanics
- Auto-memory rules: every project you start needs Layer 3 set up first session
- See also: [`feedback_adhd_framing`](./adhd-aware-design.md) — single source of truth at the *capture* level; this is single source of truth at the *memory* level
