# RESEARCH — Phase P03: Claude Code as operator

> **Stream goal:** verify the chapter against the current Claude Code feature set + 2026 agent-tooling landscape, broaden from "Claude Code specifically" to "agentic coding tools in general," and add hard data on memory, MCP, and browser-tool trade-offs.

## 0. Scope

In:
- `03-claude-code-as-operator/README.md` + 6 sub-topic files (`agent-rules.md`, `browser-tools.md`, `claude-md-template.md`, `mcp-routing.md`, `memory-architecture.md`, `skills-and-hooks.md`)

Out:
- Linear API specifics (chapter 01)
- Filesystem/worktree placement (chapter 02)
- Commit / PR hooks (chapter 06)
- Secrets pattern (chapter 05) — but cross-reference safely

## 1. What exists today

1,384 lines across 7 files. Currently the second-deepest chapter. Existing depth:

- **Memory architecture** — 4 layers, boundary rules, content typology, caps (Layer 1 ≤ 200, Layer 3 ≤ 150)
- **CLAUDE.md template** — referenced via repo-bootstrap doc
- **Skills and hooks** — boundary between them, when each fires
- **MCP routing** — CLI > MCP for known tools, WebFetch > Playwright for read-only, Dash-first for installed docsets
- **Browser tools** — ranked tier list (WebFetch > Playwright > chrome-devtools > browser-use > Obscura > CloakBrowser > Firecrawl > Lightpanda > BrowserMCP), TLS fingerprinting 2025–2026 note
- **Agent rules** — spawn vs inline, token budgets, stop conditions, escalation rule

## 2. Honest gaps

- **Tied to Claude Code semantics.** Skills, hooks, slash commands — these are Claude-specific naming. Need a tool-agnostic restatement (skills = "commands the agent can invoke"; hooks = "shell triggers on events"; etc.) so Cursor/Codex/Aider/Cline users can map.
- **Browser-tool tier list dates fast.** 2025–2026 fingerprinting landscape (JA3/JA4, browser-impersonate, curl-impersonate, primp library) is moving. Need a recheck.
- **MCP ecosystem moved 2024 → 2026.** Number of MCPs, official MCP registry, Anthropic's own MCP catalog — refresh.
- **No empirical evidence for memory layer caps.** "Layer 1 ≤ 200 lines" is asserted. Need an Anthropic engineering blog post or measurement showing degradation past N tokens.
- **Hooks documentation is post-`SessionStart`-era** but the chapter doesn't enumerate all hook events (UserPromptSubmit, SessionEnd, PreToolUse, PostToolUse, etc.).
- **Skill discovery / surfacing** isn't covered — important now that bundles can install dozens of skills (gstack: 65+).
- **Subagent / Task tool** isn't deeply covered. When to spawn vs inline is mentioned but not measured.
- **Agent SDK** (formerly Claude SDK) — out of scope for the playbook? Or briefly mention as the "build your own agent" path?
- **Cost / token accounting** — touched in CLAUDE.md global rules but not in this chapter. Worth a sub-section.
- **No benchmark of Claude Code vs. Cursor vs. Codex vs. Aider vs. Cline vs. Continue** as "operator" platforms. Affects portability claim.

## 3. Research questions

### Claude Code platform refresh

- **Q03.1** Re-read docs.claude.com/en/docs/claude-code. Diff against the chapter's claims. File a delta list. Anchor on a specific Claude Code version.
- **Q03.2** Enumerate all hook events (UserPromptSubmit, SessionStart, SessionEnd, PreToolUse, PostToolUse, Stop, SubagentStop, etc.) with one-line semantics each.
- **Q03.3** What's the current skill-discovery model? (Auto-surfacing from name match; explicit /command invocation; SkillSearch tool?) Update the chapter.
- **Q03.4** Current MCP registry / catalog status. Where do users discover MCPs in 2026?
- **Q03.5** Plugin system — Claude Code shipped a plugin system. How does it interact with skills/hooks? Worth a sub-section.
- **Q03.6** Subagent (Task tool) — what's the current model? Token budget per subagent? Foreground vs background?
- **Q03.7** Claude Agent SDK — relationship to Claude Code. Is the chapter affected if a reader wants to build their own operator on top of the SDK?

### Memory architecture defense

- **Q03.8** Find published material on context-degradation past N tokens. Anthropic engineering blog? Independent benchmarks (e.g., RULER, NIAH variants)? Cite specific caps.
- **Q03.9** How does Claude's prompt caching interact with the 4-layer model? Specifically: do Layer 1 (global) + Layer 2 (project) get cached? Update MCP-routing section if so.
- **Q03.10** Compare to other agent-memory architectures: gstack GBrain, mem0, MemGPT/Letta, LangGraph state, OpenAI memory, Cursor's `.cursorrules`, Aider's `CONVENTIONS.md`, Cline's memory. Build a structured comparison table.
- **Q03.11** What does Anthropic recommend for project-rules file size? Find their guidance and reconcile with the playbook's caps.

### Browser-tool tier refresh

- **Q03.12** 2025–2026 anti-bot landscape: Cloudflare Turnstile updates, DataDome JA4, Akamai Bot Manager. What changed since the chapter was written? (TLS fingerprinting note may need expansion.)
- **Q03.13** New browser tools to evaluate: `primp` (Python TLS-impersonate library), `curl-impersonate` updates, Playwright stealth plugins (2026 versions), Patchright, Hero browser, Camoufox.
- **Q03.14** Is `Obscura` still maintained? Last commit? If abandoned, the tier list needs updating.
- **Q03.15** CloakBrowser MCP — closed-source binary concern is in the chapter; has any open alternative emerged?
- **Q03.16** Firecrawl pricing / availability in 2026 — has it changed? Self-hosted Firecrawl maturity.
- **Q03.17** What's the current LightPanda / Servo / Ladybird state for headless browsing? Any new entrant?

### MCP routing refresh

- **Q03.18** Best official MCPs as of 2026: filesystem, git, github, slack, linear (Anthropic-released?), notion, postgres, sqlite. Enumerate with versions.
- **Q03.19** When does CLI win over MCP? (Latency? Predictability? Cost?) Find or measure.
- **Q03.20** New MCP categories: vision MCPs (screenshot analysis), memory MCPs (vector stores), workflow MCPs (n8n, Zapier-MCP). Worth a routing rule each?

### Agent ecosystem comparison

- **Q03.21** Build a Claude Code vs Cursor vs Codex vs Aider vs Cline vs Continue comparison on the "operator agent" criteria: rules file, skills/commands, hooks, MCP support, subagents, sandbox model, IDE integration.
- **Q03.22** Which of these support project-level rules? CLAUDE.md → .cursorrules → CONVENTIONS.md → .clinerules → continuedev/config.json. Make the playbook patterns translate.

### Skills, hooks, subagents

- **Q03.23** What's the published evidence on skill bloat? gstack has 65+; awesome-claude-code lists hundreds. Is there a point of diminishing return?
- **Q03.24** Hook failures — what's the official guidance for hooks that block UserPromptSubmit (which most settings.json examples warn about)?
- **Q03.25** Subagent token-budget defaults — Anthropic's recommendation vs measured.

### Cost / accounting

- **Q03.26** What current 2026 best-practice exists for tracking Claude Code costs (cache hits, tool calls, subagent spawns)? Anthropic admin API endpoints, billing dashboards.
- **Q03.27** Prompt-cache hit-rate optimization in agent settings — what helps, what hurts.

## 4. Per-question source plan

| Q | Source class | Specific starting points |
|---|---|---|
| Q03.1–Q03.7 | Primary | docs.claude.com/en/docs/claude-code (re-crawl). anthropic.com/news for release posts. github.com/anthropics/claude-code if/when public. |
| Q03.8–Q03.11 | Primary + academic | anthropic.com/engineering blog. arXiv RULER paper. nelson_jhu NIAH variants. Cross-reference with Cursor docs, Aider docs, Cline (cline.bot/docs), Continue (docs.continue.dev). |
| Q03.12–Q03.17 | Primary + practitioner | cloudflare.com/blog (turnstile updates), datadome.co/blog (JA4 posts), recent HN threads on bot detection, github.com/lwthiker/curl-impersonate, primp PyPI, github.com/patchright, github.com/daijro/camoufox. |
| Q03.18–Q03.20 | Primary | github.com/modelcontextprotocol/servers official catalog. anthropic.com MCP registry if released. github.com/punkpeye/awesome-mcp-servers (community catalog). |
| Q03.21–Q03.22 | Primary | cursor.com docs, openai.com/codex docs, aider.chat docs, cline.bot docs, docs.continue.dev. Direct comparison; cite version. |
| Q03.23 | Practitioner | gstack repo for inspiration, HN/Lobsters on agent-skill bloat. |
| Q03.24 | Primary | docs.claude.com hook documentation. github.com/anthropics issue tracker if visible. |
| Q03.25 | Primary | docs.claude.com subagent / Task tool docs. anthropic.com/news for relevant updates. |
| Q03.26–Q03.27 | Primary + practitioner | anthropic.com console docs (admin API). Simon Willison's blog on prompt caching. Anthropic engineering blog on cache. |

## 5. Output requirements

The agent updates files in `/Users/pleasedodisturb/Projects/playbooks/solo-dev-pmo/03-claude-code-as-operator/`:

1. **README.md** gains:
   - "Claude Code version we checked against" datestamp
   - One paragraph translating the chapter to other agents (Cursor, Codex, Aider, Cline) — the agent-platform-portability bridge
2. **`memory-architecture.md`** gains:
   - Empirical evidence for "always-loaded ≤ 200 lines" if findable; honest hedge if not
   - Comparison-to-others table (gstack GBrain, mem0, Letta, LangGraph state, Cursor `.cursorrules`, Aider conventions, Cline memory)
   - Prompt-caching interaction note
3. **`claude-md-template.md`** gains:
   - The actual template inlined (don't rely on the user reading global rules)
   - Cursor `.cursorrules` and Aider `CONVENTIONS.md` translation examples
4. **`skills-and-hooks.md`** gains:
   - Enumeration of all hook events with one-line semantics
   - The "UserPromptSubmit hooks can block silently" warning, with safe-pattern recipe
   - Skill-discovery model update
   - Plugin system (if applicable)
5. **`mcp-routing.md`** gains:
   - Refreshed MCP catalog (top 10 with brief notes)
   - "When CLI wins over MCP" subsection with evidence
   - New MCP categories (vision, memory, workflow)
6. **`browser-tools.md`** gains:
   - 2026 anti-bot landscape update (JA4 specifically)
   - New entries (primp, curl-impersonate updates, Camoufox, Patchright)
   - Obscura maintenance status; update tier if changed
   - CloakBrowser open-alternatives note
7. **`agent-rules.md`** gains:
   - Subagent token-budget evidence
   - Comparison to other tools' subagent models
   - Cost / cache-hit accounting subsection
8. **New file:** `03-claude-code-as-operator/agent-platform-portability.md` — explicit translation matrix for the 6 other agentic coding tools
9. **New file:** `03-claude-code-as-operator/sources.md` — bibliography

Constraints:
- DO NOT vendor-lock to Claude Code. Add the portability bridge.
- DO NOT cite Anthropic marketing pages; only docs + engineering blog.
- DO NOT claim "Claude Code is the best agent" — playbook stays opinionated about *patterns*, not products.
- Caps still apply (~250 lines per sub-topic file).

## 6. Per-phase search ideas

### Web

- `site:docs.claude.com claude-code hooks`
- `site:anthropic.com/news claude-code`
- `site:anthropic.com/engineering`
- `site:cursor.com docs rules`
- `site:aider.chat docs conventions`
- `site:cline.bot docs memory`
- `site:docs.continue.dev`
- `"MCP server" registry 2026`
- `site:cloudflare.com/blog turnstile bot 2025 OR 2026`
- `site:datadome.co JA4`
- `TLS fingerprinting JA4 bypass 2026`
- `"prompt cache" hit rate Anthropic engineering`

### Social

- HN: `https://hn.algolia.com/?q=Claude+Code`
- HN: `https://hn.algolia.com/?q=MCP+model+context+protocol`
- HN: `https://hn.algolia.com/?q=Cursor+vs+Aider`
- HN: `https://hn.algolia.com/?q=agent+memory+architecture`
- HN: `https://hn.algolia.com/?q=JA4+fingerprint+bypass`
- Lobsters: `https://lobste.rs/search?q=claude+code`
- Lobsters: `https://lobste.rs/search?q=MCP+server`
- Reddit: `site:reddit.com/r/ClaudeAI skills hooks`
- Reddit: `site:reddit.com/r/cursor rules`
- Reddit: `site:reddit.com/r/LocalLLaMA agent comparison`
- X/Twitter: handles `@AnthropicAI`, `@alexalbert__`, `@simonw`, `@swyx`, `@karpathy`
- X/Twitter: `(Claude Code) (skill OR hook OR MCP) min_faves:50 since:2024-06-01`

### GitHub

- `topic:claude-code` (sort stars + recent)
- `topic:mcp-server` (sort stars + recent)
- `topic:claude-skills`
- `filename:CLAUDE.md` (code search) — survey 30+ project-level CLAUDE.md files
- `filename:.cursorrules` (code search) — equivalent for Cursor
- `filename:CONVENTIONS.md path:.aider` — Aider patterns
- `filename:.clinerules` — Cline patterns
- `org:anthropics` for any official examples
- `org:modelcontextprotocol` for MCP registry

### Specific repos to skim

- `anthropics/anthropic-cookbook` for current patterns
- `modelcontextprotocol/servers` for official MCP catalog
- `punkpeye/awesome-mcp-servers` for community catalog
- `garrytan/gstack` — direct comparison for "operator" framing
- `cline/cline` — competing agent
- `Aider-AI/aider`
- `continuedev/continue`
- `cursorsh/cursor` (if public examples exist)
- `lwthiker/curl-impersonate`
- `daijro/camoufox`
- `Kaliiiiiiiiii-Vinyzu/patchright-python`

### Anthropic-specific

- docs.claude.com/en/docs/claude-code — full re-crawl
- docs.claude.com/en/api — admin API for cost tracking
- anthropic.com/engineering — blog
- anthropic.com/news — release announcements

## 7. Stop conditions

Stop and surface if:

- Claude Code shipped a feature that obsoletes a chapter section entirely (e.g., built-in 4-layer memory replacing the manual `~/.claude/projects/.../memory/` directory). Don't silently rewrite.
- The browser-tool tier list inverts (e.g., Lightpanda overtakes Playwright for headless ergonomics). Re-rank explicitly.
- An MCP becomes "official Linear MCP from Linear" — affects chapter 01's CLI > MCP rule. Cross-flag.
- An agent platform (Cursor especially) ships subagents in a way that makes Claude Code's model look behind. Just document the difference; don't recommend switching.

## 8. Estimated effort

L phase. 10–16 hours research + 8–12 hours writing. Largest output volume of any phase. Parallelize: one sub-agent on Claude Code/Anthropic refresh (Q03.1–Q03.11, Q03.18–Q03.20, Q03.24–Q03.27), one on browser-tools 2026 (Q03.12–Q03.17), one on agent-platform comparison (Q03.21–Q03.22).
