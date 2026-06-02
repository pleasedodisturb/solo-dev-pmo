# 03 — Claude Code as operator

> Claude Code (or any agentic coding tool — Cursor, Codex, Windsurf, Aider) is not a chat window. It's an operator on your stack. Design the stack so it can operate well.

> **Claude Code-first, not Claude Code-only.** Examples use Claude Code because that's where the author runs production. The patterns port to any operator agent — but the concrete recipes (skills, hooks, `/commands`, MCP wiring) need rewriting per tool. The [portability section below](#not-just-claude-code) and [Agent-platform portability](./agent-platform-portability.md) are the translation matrix.

This chapter is about the integration layer. How memory works. What goes in CLAUDE.md vs. auto-memory. Which MCP for which task. When to spawn an agent vs. inline. Browser tool routing.

> **Checked against Claude Code v2.1.158, 2026-05-31.** Docs now live at **code.claude.com/docs** (moved from `docs.claude.com/en/docs/claude-code`). Fast-moving deltas since first draft: the `Task` tool is now `Agent`; **plugins** bundle skills/hooks/MCP behind marketplaces; custom commands merged into **skills**; hook events grew from ~5 to ~30; **MCP Tool Search** defers tool definitions. Each is covered in the relevant sub-topic, not silently rewritten.

## What this chapter covers

| Section | What it solves |
|---|---|
| [Memory architecture](./memory-architecture.md) | 4 layers, each with a job. The boundary rules between them. |
| [CLAUDE.md template](./claude-md-template.md) | What the project rules file looks like. Global vs. project content split. |
| [Skills and hooks](./skills-and-hooks.md) | What skills are for, what hooks are for, where the boundary is. |
| [MCP routing](./mcp-routing.md) | Which MCP for which task. CLI > MCP for Linear locally; WebFetch > Playwright for read-only. |
| [Browser tools](./browser-tools.md) | Ranked browser-tooling decisions. WebFetch first, then specialized. |
| [Agent rules](./agent-rules.md) | When to spawn a subagent vs. inline. Token budgets. Stop conditions. |
| [Agent-platform portability](./agent-platform-portability.md) | The same patterns in Cursor, Codex, Aider, Cline, Continue. |

## The framing

There are two failure modes when integrating an agent into your stack:

1. **Under-integration:** the agent doesn't know your conventions. It writes commits without ticket prefixes, files orphan tickets, ignores your secrets policy. You spend more time correcting than getting work done.
2. **Over-integration:** the agent's rules file is 2000 lines, every session starts slowly, costs add up, and the agent gets confused by conflicting guidance.

The cure: layered rules at the right granularity, with the right routing per task. The rest of this chapter is mechanics.

## Not just Claude Code

The vocabulary here is Claude Code's, but the system isn't. Every other operator agent has the same parts under different names: a project-rules file (`CLAUDE.md` → Cursor `.cursor/rules`, Aider `CONVENTIONS.md`, Cline `.clinerules`, Continue `.continue/rules`, Codex/Copilot `AGENTS.md` — now a Linux-Foundation-stewarded standard), commands/skills, and increasingly MCP and hooks. The honest gaps: only **Cursor** also has real event hooks, and only **Codex/Cursor** also have subagents; **Aider** has neither. Read the chapter in Claude Code's terms, then [translate](./agent-platform-portability.md). The patterns are the asset; the product is swappable.

## The four memory layers (recap)

Already covered in [00 — four-layer memory](../00-principles/four-layer-memory.md). Recap for this chapter's purposes:

| Layer | Lives at | Scope | Loaded |
|---|---|---|---|
| 1. Global rules | `~/.claude/CLAUDE.md` | All projects | Always |
| 2. Project rules | `<repo>/CLAUDE.md` | One project | When working in that project |
| 3. Auto-memory | `~/.claude/projects/<encoded-path>/memory/` | One project, persistent state | Always (project-scoped) |
| 4. MCP memory | A vector store (e.g. SQLite-vec) | Cross-project, queried | On demand |

Each layer is for different content. Mixing them creates rot. See [Memory architecture](./memory-architecture.md) for the boundary rules.

## What an "operator" agent does

In this playbook's framing, Claude Code is:

- **A first-class operator on the codebase** — runs tests, modifies files, opens PRs
- **A capture and triage helper** — files tickets, drafts Project Updates, runs morning Triage with you
- **A research / spike runner** — `/gsd-spike` style workflows for exploratory work
- **A long-workflow executor** — `/gsd-plan-phase`, `/gsd-execute-phase`, `/gsd-autonomous` for multi-step work
- **A maintenance partner** — runs `gsd-audit-uat`, `gsd-cleanup`, code review

The skills and slash commands you build are the operator's interface. The rules files (CLAUDE.md, etc.) are the operator's contract. The MCPs are the operator's tools.

## What it doesn't do

To prevent scope creep:

- **Not a chat window.** Conversational drift is the failure mode that wastes the most tokens. Skills are commands; rules are rules.
- **Not a search engine.** It has WebSearch and WebFetch; use them for facts, not for browsing.
- **Not your therapist.** The "tell me everything you're feeling" mode burns context without producing output.
- **Not infallible.** Trust-but-verify on every action; agents will confidently produce broken code if not gated by your tests and review hooks.

## The "operator" contract

In one paragraph: an operator agent works within your conventions. It writes commits with ticket prefixes. It runs your test suite before pushing. It uses your CLI tools and not their MCP cousins. It respects your secrets policy. It files tickets at full quality when it discovers something. It uses your worktree placement. It honors your WIP cap. It knows when to stop and ask vs. when to proceed autonomously.

If your agent does any of these things wrong, the problem is the contract, not the agent. Tighten the rule, document the lesson, move on.

## Related

- [Chapter 01 — Linear I/O rules](../01-linear-as-load-bearing-pm/io-rules.md) — how operator reads/writes Linear
- [Chapter 02 — Filesystem conventions](../02-filesystem-conventions/) — operator respects layout + slug + worktree rules
- [Chapter 06 — Session discipline](../06-session-discipline/) — operator follows commit / PR / audit patterns
