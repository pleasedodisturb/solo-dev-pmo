# Memory architectures compared

> The playbook's [4-layer model](./memory-architecture.md) is one point in a crowded design space. This file places it against the other agent-memory systems a 2026 solo dev might encounter, so you can tell when to reach for a vector store instead of a flat file. *Checked 2026-05-31.*

## The two families

Agent memory in 2026 splits cleanly:

- **Flat-file, version-controlled, deterministic** — markdown the human (or agent) edits, committed to the repo or a dotfiles sync. Cursor rules, Aider `CONVENTIONS.md`, Cline's Memory Bank, Continue rules, and this playbook's Layers 1–3 all live here. You can `git blame` your memory; it never hallucinates a recall; it's bounded by what loads into context.
- **Vector / managed, semantic, cross-session** — an external store the agent queries by similarity. mem0, Letta (MemGPT), LangGraph/LangMem, OpenAI memory, and this playbook's Layer 4 live here. Recall crosses projects and sessions, but it's non-deterministic, needs infra, and can surface stale or wrong hits.

The playbook deliberately spans both: flat files for the 99% (Layers 1–3), a vector MCP only for genuine cross-project recall (Layer 4). The mistake most comparisons make is treating these as competitors — they're different jobs.

## The comparison (Q03.10)

| System | Where it lives | Auto vs manual | Scope | Storage |
|---|---|---|---|---|
| **This playbook L1–L3** | `~/.claude/CLAUDE.md`, repo `CLAUDE.md`, `~/.claude/projects/.../memory/` | Manual + agent-written | global / project / project-state | Flat file |
| **This playbook L4** | memory MCP (e.g. SQLite-vec) | Agent-written on insight | cross-project (tagged) | Vector |
| **Cursor rules** | `.cursor/rules/*.mdc` | Manual author; auto-*activate* (Always / glob / agent-requested / manual) | project + user | Flat file |
| **Aider** | `CONVENTIONS.md` via `/read` | Manual (you load it) | project | Flat file |
| **Cline Memory Bank** | `memory-bank/*.md` + `.clinerules` | Agent maintains on command | project-state | Flat file (agent-rewritten) |
| **Continue** | `.continue/rules` | Manual | project / global | Flat file |
| **mem0** | vector DB (Qdrant/Pinecone) + graph | Auto-extracts from conversation | user/agent/run/app IDs | Vector + graph |
| **Letta (MemGPT)** | Core (in-context block) / Recall / Archival | **Self-editing** (agent calls `memory_*`) | session + long-term | In-context + vector |
| **LangGraph / LangMem** | thread checkpoints + namespaced Store | checkpoint auto; long-term via LangMem | thread + cross-thread | Checkpoint + JSON/vector |
| **OpenAI / ChatGPT memory** | "saved memories" + history reference | auto-save + manual | per-account, cross-chat | Opaque/managed |

Sources: Cursor,[¹] Aider,[²] Cline,[³] Continue,[⁴] mem0,[⁵] Letta,[⁶] LangGraph,[⁷] OpenAI.[⁸]

## What's notable

- **Cline's Memory Bank** is the closest external analog to the playbook's Layer 3: a fixed set of markdown files (`projectbrief`, `activeContext`, `progress`, …) the agent rewrites on a "update memory bank" command. Same job as `MEMORY.md` + siblings, different ergonomics — Cline leans on the agent to maintain it; the playbook leans on conventions + a daily health check.
- **Letta is the only one that self-edits structured memory** as a first-class loop (the MemGPT idea: the agent manages its own context like an OS manages RAM). Powerful, but it's an architecture you adopt, not a file you write — overkill for a solo repo, interesting for a long-running autonomous agent.
- **mem0 / LangMem are the Layer-4 competitors.** If you outgrow a single SQLite-vec MCP, these are where you'd go — mem0 for auto-extraction, LangMem for typed semantic/episodic/procedural memory inside a LangGraph app.
- **OpenAI/ChatGPT memory is the anti-pattern for this playbook**: opaque, per-account, not version-controlled, not project-scoped. Fine for a consumer chatbot; wrong for an operator on your codebase, where you want memory you can audit and diff.

## The routing rule

Default to **flat-file, version-controlled** memory (Layers 1–3). Reach for **vector** memory (Layer 4 / mem0 / LangMem) only when recall must cross project boundaries and similarity search earns its non-determinism. Never use a vector store to "remember a file" — that's what reading the file is for. The bias is the same one driving the rest of the chapter: the smallest, most legible mechanism that does the job.

## Related

- [Memory architecture](./memory-architecture.md) — the playbook's 4 layers in detail
- [Agent-platform portability](./agent-platform-portability.md) — rules files across tools
- [sources.md](./sources.md) — full bibliography

---

[¹]: https://cursor.com/docs/rules — accessed 2026-05-31
[²]: https://aider.chat/docs/usage/conventions.html — accessed 2026-05-31
[³]: https://docs.cline.bot/features/memory-bank — accessed 2026-05-31
[⁴]: https://docs.continue.dev/customize/deep-dives/rules — accessed 2026-05-31
[⁵]: https://docs.mem0.ai/platform/overview ; https://github.com/mem0ai/mem0 — accessed 2026-05-31
[⁶]: https://docs.letta.com/concepts/letta/ — accessed 2026-05-31
[⁷]: https://docs.langchain.com/oss/python/concepts/memory — accessed 2026-05-31
[⁸]: https://help.openai.com/en/articles/11146739 — accessed 2026-05-31
