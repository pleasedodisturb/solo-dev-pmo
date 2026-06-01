# Agent-platform portability

> The patterns in this chapter are written in Claude Code's vocabulary, but the chapter is about *operator agents*, not one product. This file translates every pattern to the other tools a solo dev might run: Cursor, OpenAI Codex, Aider, Cline, Continue. Pick the tool; keep the system.

*Checked 2026-05-31. Vendor docs move fast; verify the exact paths against each tool's current docs.*

## The one thing that's converging: `AGENTS.md`

The biggest 2025→2026 shift is that the "project rules file" is becoming a cross-tool standard. **`AGENTS.md`** — plain markdown at repo root, no required schema — started as an OpenAI initiative (Aug 2025) and is now stewarded by the **Agentic AI Foundation under the Linux Foundation**, adopted by 60,000+ repos and read natively by Codex, Cursor, GitHub Copilot, Gemini CLI, Aider, Windsurf, Zed, Devin, Factory, and 20+ others.[¹]

The notable holdout is **Claude Code itself**, which still reads `CLAUDE.md`.[²] Practical move for a solo dev who switches tools: keep one `AGENTS.md` as the source of truth and have `CLAUDE.md` reference it (`See @AGENTS.md`), rather than maintaining two drifting files.

## Rules-file translation matrix (Q03.22)

| Tool | Canonical path | Format |
|---|---|---|
| Claude Code | `CLAUDE.md` (+ `~/.claude/CLAUDE.md` global) | Markdown |
| Cursor | `.cursor/rules/*.mdc` (legacy `.cursorrules`) | MDC: markdown + YAML frontmatter (`description`, `globs`, `alwaysApply`) |
| OpenAI Codex | `AGENTS.md` | Markdown |
| Aider | `CONVENTIONS.md` (loaded via `/read` or `.aider.conf.yml` `read:`) | Markdown |
| Cline | `.clinerules` file or `.clinerules/` folder (+ `memory-bank/*.md`) | Markdown |
| Continue | `.continue/rules/*.md` or `rules:` in `config.yaml` | Markdown / YAML |
| GitHub Copilot | `.github/copilot-instructions.md` (also reads `AGENTS.md`) | Markdown |

Sources: Cursor,[³] Aider,[⁴] Cline,[⁵] Continue,[⁶] Codex,[⁷] all accessed 2026-05-31.

The playbook's [CLAUDE.md template](./claude-md-template.md) advice — purpose line, stack, key commands, conventions, gotchas; link to global, don't duplicate — transfers verbatim to any of these. Only the filename and (for Cursor) the frontmatter change.

## Capability matrix (Q03.21)

The "operator agent" criteria from this chapter, across tools:

| | Rules file | Skills / commands | Hooks | MCP | Subagents | Sandbox | Form factor |
|---|---|---|---|---|---|---|---|
| **Claude Code** | CLAUDE.md | Skills (`SKILL.md`) + `/cmds` | Yes (~30 events) | Yes + Tool Search | Yes (`Agent` tool) | allowlist + sandbox | CLI · IDE · web · Slack |
| **Cursor** | `.cursor/rules` | `/cmds`, rules-as-context | **Yes** (1.7+, `.cursor/hooks.json`) | Yes | Background Agents (cloud) | workspace trust; cloud isolated | IDE + cloud |
| **OpenAI Codex** | AGENTS.md | `/cmds`, prompts | Not first-class | Yes (STDIO + HTTP) | **Yes** (subagents) | Seatbelt / Landlock+seccomp; r-o → workspace-write → full | CLI · cloud · IDE |
| **Aider** | CONVENTIONS.md | `/cmds` | No | Roadmap, not shipped | No | local; git-undo | CLI |
| **Cline** | `.clinerules` + Memory Bank | workflows | No | Yes (MCP Marketplace) | No (Plan/Act modes) | per-tool approval | IDE (VS Code) |
| **Continue** | `.continue/rules` | prompts/slash | No | Yes (agent mode) | No | IDE | IDE + CLI |

Sources as above plus Cursor hooks,[⁸] Codex subagents/sandbox.[⁷] Read each cell as "as of 2026-05-31"; this table dates fast.

### What this means per pattern

- **Skills/hooks symbiosis** ([skills-and-hooks](./skills-and-hooks.md)): full translation only on Claude Code and **Cursor** (the only other tool with real event hooks). Codex/Cline/Continue get the *skill* half (commands/workflows) but not the *hook* safety-net half — so on those tools, enforcement that the chapter puts in a `PreToolUse` hook has to move into CI or a git hook instead.
- **Subagent routing** ([agent-rules](./agent-rules.md)): real on Claude Code, **Codex** (subagents), and **Cursor** (cloud Background Agents). Aider/Cline/Continue are single-context — the "spawn vs inline" decision collapses to "always inline," so manage main-context bloat manually.
- **MCP routing** ([mcp-routing](./mcp-routing.md)): supported everywhere except Aider (roadmap). Cline ships an in-app MCP Marketplace; Continue exposes MCP only in agent mode.
- **Memory architecture** ([memory-architecture](./memory-architecture.md)): every tool has Layer 1/2 (rules files). For Layer 3 "where we left off," **Cline's Memory Bank** (`memory-bank/*.md` the agent maintains) is the closest analog; others rely on you writing it into the rules file or an external memory MCP for Layer 4.

## The honest caveat

Aider is the outlier: no MCP, no hooks, no subagents. It maps cleanly onto the *rules + commands* half of this chapter and nothing else. If your workflow leans hard on hooks-as-enforcement and subagent parallelism, Aider will feel like a downgrade — that's a tooling fact, not a flaw in these patterns. Don't switch tools to chase a pattern; switch patterns to fit your tool.

## Related

- [Skills and hooks](./skills-and-hooks.md) — the Claude Code mechanics these translate from
- [Agent rules](./agent-rules.md) — subagent decisions per tool
- [README](./README.md) — the portability bridge paragraph
- [sources.md](./sources.md) — full bibliography

---

[¹]: https://openai.com/index/agentic-ai-foundation/ and https://agents.md/ — accessed 2026-05-31
[²]: AGENTS.md native support is an open feature request for Claude Code; `CLAUDE.md` remains canonical (https://code.claude.com/docs/en/memory) — accessed 2026-05-31
[³]: https://cursor.com/docs/rules — accessed 2026-05-31 (via search extraction; cursor.com 403s WebFetch)
[⁴]: https://aider.chat/docs/usage/conventions.html — accessed 2026-05-31
[⁵]: https://docs.cline.bot/features/memory-bank — accessed 2026-05-31
[⁶]: https://docs.continue.dev/customize/deep-dives/rules — accessed 2026-05-31
[⁷]: https://developers.openai.com/codex/subagents and /codex/concepts/sandboxing — accessed 2026-05-31
[⁸]: https://cursor.com/docs/agent/hooks and https://www.infoq.com/news/2025/10/cursor-hooks/ — accessed 2026-05-31
