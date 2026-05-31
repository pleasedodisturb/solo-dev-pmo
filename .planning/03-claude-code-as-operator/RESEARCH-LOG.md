# RESEARCH-LOG — Phase P03: Claude Code as operator

Append-only log of sources cited while enriching chapter 03. Format per
[SEARCH-PLAYBOOK.md](../SEARCH-PLAYBOOK.md) §"Per-phase research log format".

Checked against: Claude Code docs at **code.claude.com/docs** (migrated from
docs.claude.com/en/docs/claude-code), accessed 2026-05-31.

---

## 2026-05-31 — Claude Code docs URL migration (Q03.1)

- **Source:** https://docs.claude.com/en/docs/claude-code/hooks → 301 → https://code.claude.com/docs/en/hooks
- **Class:** primary (vendor docs)
- **Surfaced fact:** The Claude Code documentation moved from `docs.claude.com/en/docs/claude-code/*` to `code.claude.com/docs/en/*`. Every chapter URL that points at the old host now redirects.
- **Used in:** README.md (version/datestamp line), sources.md
- **Counter-evidence:** none

## 2026-05-31 — Hook event list expanded dramatically (Q03.2, Q03.24)

- **Source:** https://code.claude.com/docs/en/hooks — accessed 2026-05-31
- **Class:** primary (vendor docs)
- **Surfaced fact:** The chapter lists 5 hook events (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop). Current docs enumerate ~30, including SessionEnd, SubagentStart/SubagentStop, PreCompact/PostCompact, PermissionRequest/PermissionDenied, UserPromptExpansion, PostToolUseFailure, PostToolBatch, TaskCreated/TaskCompleted, WorktreeCreate/WorktreeRemove, Elicitation, FileChanged, CwdChanged, InstructionsLoaded, MessageDisplay, ConfigChange, Notification, Setup. Blocking semantics: exit 0 = ok, exit 2 = blocking error (stderr → Claude), other non-zero = non-blocking. UserPromptSubmit has a 30s default timeout (vs 600s elsewhere) and blocks model processing — the chapter's "hooks add latency" warning understates this.
- **Used in:** skills-and-hooks.md (hook enumeration + UserPromptSubmit safe-pattern)
- **Counter-evidence:** none

## 2026-05-31 — Ground-truth checks from a live Claude Code cloud session

This phase runs *inside* a Claude Code session, so several chapter claims were
verified firsthand rather than from docs.

- **Source:** this session's environment — `claude --version`, `~/.claude/`, accessed 2026-05-31
- **Class:** primary (firsthand)
- **Surfaced facts:**
  - Claude Code version **2.1.158** — anchor the chapter's "version we checked against" here.
  - `settings.json` hook schema confirmed: `hooks → <EventName> → [{ matcher, hooks: [{ type: "command", command }] }]`. A real `Stop` hook is wired (`~/.claude/stop-hook-git-check.sh`).
  - Hook I/O model confirmed: hook reads JSON on **stdin**, checks `stop_hook_active` for recursion prevention, signals via **exit code**.
  - **Layer-3 path encoding confirmed exactly:** `~/.claude/projects/-home-user-solo-dev-pmo` — absolute path with `-` separators, as the chapter claims.
  - **Skills are directories containing `SKILL.md`** (`~/.claude/skills/session-start-hook/SKILL.md`), NOT single slash-command markdown files. The chapter's "skill anatomy" (a `name.md` with `name:`/`description:` frontmatter) is the right frontmatter but wrong container — current model is a folder + `SKILL.md`.
- **Used in:** skills-and-hooks.md (skill model), memory-architecture.md (Layer-3 encoding stays correct), README.md (version line)
- **Counter-evidence:** none — claims held up. The Layer-3 encoding claim is now firsthand-verified.

## 2026-05-31 — Skills / plugins model (Q03.3, Q03.5)

- **Source:** code.claude.com/docs/en/skills, /plugins — primary — accessed 2026-05-31
- **Surfaced facts:** Skills are `SKILL.md` directories, model-invoked by `description` OR explicit `/name` (`disable-model-invocation`); progressive disclosure (only name+desc load until used; `description`+`when_to_use` capped ~1,536 chars). Custom commands MERGED into skills. Follows Agent Skills open standard (agentskills.io). Plugins = `.claude-plugin/plugin.json` bundling skills/agents/`hooks.json`/`.mcp.json`/`.lsp.json`/monitors/bin/settings; namespaced `/plugin:skill`; official `claude-plugins-official` + `claude-community` marketplaces.
- **Used in:** skills-and-hooks.md
- **Counter-evidence:** none

## 2026-05-31 — Claude Code platform refresh (Q03.1, Q03.6, Q03.7, Q03.26, Q03.27)

- **Source:** code.claude.com/docs/en/{changelog,sub-agents,agent-sdk/overview,costs,monitoring-usage,prompt-caching}; platform.claude.com admin API — primary — accessed 2026-05-31
- **Surfaced facts:** `Task` tool renamed `Agent` (v2.1.63). Subagents: fresh isolated context, summary-only return, can't nest, foreground-blocks/background-auto-denies, built-in Explore(Haiku)/Plan/general-purpose, per-agent `model:`. Agent SDK = renamed Claude Code SDK (Python/TS `query()`); from 2026-06-15 SDK/`-p` usage draws a separate Agent SDK credit. Cost: `/usage` attributes spend to skills/subagents/plugins/MCP; OTEL `claude_code.cost.usage`/`token.usage`; Admin API cost/usage reports; ccusage (practitioner). Caching: stable-prefix system→CLAUDE.md→convo; 1h TTL free on subscription; mid-session CLAUDE.md edits don't apply until restart.
- **Used in:** README.md, agent-rules.md, claude-md-template.md
- **Counter-evidence:** none

## 2026-05-31 — Context-degradation evidence (Q03.8, Q03.11)

- **Source:** anthropic.com/engineering/effective-context-engineering (vendor-blog, 403→snippets); arXiv:2404.06654 RULER, arXiv:2502.05167 NoLiMa (academic); trychroma.com/research/context-rot (practitioner, 403→snippets); code.claude.com/docs/en/memory (primary)
- **Surfaced facts:** Anthropic docs state "target under 200 lines per CLAUDE.md … reduce adherence" — VALIDATES the playbook's Layer-1 cap. Context rot: attention budget, RULER effective-context-length << advertised, NoLiMa 11/12 models <50% at 32K, Chroma 18-model degradation. Nuance: CLAUDE.md loads in FULL (no truncation); 200-line/25KB cap applies to auto-memory MEMORY.md.
- **Used in:** memory-architecture.md, claude-md-template.md
- **Counter-evidence:** none — converging multi-source support.

## 2026-05-31 — Agent-platform comparison + AGENTS.md (Q03.10, Q03.21, Q03.22)

- **Source:** cursor.com/docs, developers.openai.com/codex, aider.chat/docs, docs.cline.bot, docs.continue.dev (primary, several via WebSearch due to 403); agents.md + openai.com/index/agentic-ai-foundation (primary); infoq cursor-hooks (secondary)
- **Surfaced facts:** Rules-file matrix (CLAUDE.md/.cursor.mdc/AGENTS.md/CONVENTIONS.md/.clinerules/.continue). AGENTS.md = Linux-Foundation Agentic AI Foundation standard, 60k+ repos, 20+ tools; Claude Code holdout. DELTAS: Codex now has subagents; Cursor now has real hooks (1.7+). Aider = no MCP/hooks/subagents. Memory comparison: flat-file (Cursor/Aider/Cline/Continue) vs vector (mem0/Letta/LangGraph/OpenAI).
- **Used in:** agent-platform-portability.md, memory-comparison.md, claude-md-template.md, README.md
- **Counter-evidence/caveat:** vendor docs 403'd WebFetch; rows via search extraction. Re-verify before print.

## 2026-05-31 — MCP catalog + CLI-vs-MCP + Linear flag (Q03.18, Q03.19, Q03.20, Q03.23)

- **Source:** github.com/modelcontextprotocol/servers(+archived) (repo); anthropic.com/engineering/code-execution-with-mcp, /writing-tools-for-agents (vendor-blog); code.claude.com/docs/en/mcp; linear.app/docs/mcp (primary)
- **Surfaced facts:** Reference servers down to 7; rest archived→vendor-maintained. Anthropic Directory (claude.ai/directory) + registry preview. **STOP-CONDITION: official first-party Linear MCP (mcp.linear.app)** — cross-flagged for ch01, NOT edited there. CLI>MCP evidence: 58 tools≈55K tokens; code-execution 150K→2K (98.7%). MCP Tool Search defers tool defs. Skill/tool bloat: SKILL.md <500 lines, ~15 tools/server diminishing returns; gstack ~31 skills (brief's "65+" inflated).
- **Used in:** mcp-routing.md, skills-and-hooks.md
- **Counter-evidence:** none

## 2026-05-31 — Browser-tools 2026 (Q03.12–Q03.17)

- **Source:** arXiv:2602.09606 (academic); scrapfly.io PQ-TLS, packet.guru JA4, datadome guide (practitioner); GitHub repos primp/curl_cffi/patchright/camoufox/nodriver/obscura/CloakBrowser/firecrawl/lightpanda (primary)
- **Surfaced facts:** JA3 dead, JA4+ standard; TLS-dominance now cited (CatBoost AUC 0.998). NEW axis: post-quantum TLS (X25519MLKEM768, ~57% of connections, Akamai default Jan-2026) — missing PQ key share = pre-HTTP tell, widens impersonation gap. curl-impersonate stale → curl_cffi active; primp/Patchright/Camoufox/nodriver active; Python>Node stealth. Obscura active but young 0.1.x. CloakBrowser binary-only/wrapper-MIT; Camoufox = open alt. Firecrawl AGPL, self-host subset. Lightpanda beta (no heavy SPA); Servo embeddable; Ladybird alpha Jul-2026.
- **Used in:** browser-tools.md
- **Counter-evidence:** thesis holds *stronger* post-PQ-TLS; refined to "soft/non-JS targets only for impersonation libs, if PQ-current."

## 2026-05-31 — STOP-CONDITION watch + cap overflow

- **Linear official MCP** (above) — affects ch01 CLI>MCP rule. Cross-flagged in mcp-routing.md; ch01 NOT edited. Needs human reconciliation pass.
- **Native auto-memory / subagent `memory:`** — Claude Code now ships first-party auto-memory + per-subagent persistent memory (`memory: user|project|local`, loads first 200 lines/25KB of MEMORY.md). Does NOT obsolete the manual 4-layer model (the `~/.claude/projects/.../memory/` path still works and is firsthand-verified this session), but it is an additive native feature the chapter could later lean on. Surfaced, not rewritten — matches RESEARCH.md §7 stop condition.
- **No chapter section was fully obsoleted.** Plugins/Tool Search/Agent rename are additive or renames, covered in place.
- **Cap overflow:** memory-architecture.md was 337 lines (pre-existing, over the ~250 soft cap). Split the Q03.10 comparison into memory-comparison.md and trimmed the duplicate global-CLAUDE.md outline → 304. Still over; getting under 250 would cut field-tested gotchas/patterns. Flagged for human call, not silently gutted.
