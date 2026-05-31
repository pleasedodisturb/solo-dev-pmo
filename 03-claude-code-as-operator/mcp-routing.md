# MCP routing

> Which MCP for which task. Decision rules so your agent doesn't reach for the wrong tool.

The MCP ecosystem has grown to dozens of viable servers. Without routing rules, your agent will:
- Use a heavyweight browser MCP when WebFetch would suffice
- Reach for the PM tool's MCP when your CLI is faster
- Use the memory MCP to "read a file" instead of just reading the file
- Use the wrong browser MCP for a captcha-gated target

The rules below are field-tested at the "30+ MCPs across all categories" scale.

## The framing

Pick the **simplest tool that can do the job.**

| If you can do it with... | Use that, not the next tier |
|---|---|
| A built-in tool (Read, Write, WebFetch, WebSearch) | Built-in. Never reach for an MCP. |
| A CLI you already have | The CLI. MCPs that wrap CLIs add latency and obscure errors. |
| A specialized MCP for the task | The specialized MCP, not a general-purpose one. |
| Nothing in the catalog | Use the closest specialized MCP and document the gap. |

*Checked 2026-05-31 against Claude Code v2.1.158.*

## The 2026 MCP catalog (Q03.18)

The official **reference** servers shrank to seven — maintained by the MCP steering group, in `modelcontextprotocol/servers`: **Everything** (test server), **Fetch**, **Filesystem**, **Git**, **Memory** (knowledge graph), **Sequential Thinking**, **Time**.[¹] The rest were **archived and re-launched vendor-maintained**: GitHub → `github/github-mcp-server`, Slack, Postgres, Sentry, Brave, etc. now live with their vendors, not Anthropic.[¹]

Discovery in 2026: the **Anthropic Directory** (`claude.ai/directory`) lists reviewed connectors you add with `claude mcp add`; an official **registry** (`registry.modelcontextprotocol.io`) is in preview.[²] The community `punkpeye/awesome-mcp-servers` catalog still covers the long tail. Ten worth knowing: Filesystem, Git, Fetch, Memory, Sequential Thinking (reference); GitHub, Linear, Playwright (Microsoft), Zapier, n8n (vendor/community).

> **Cross-chapter flag (do not silently edit ch01):** Linear now ships an **official first-party MCP** at `https://mcp.linear.app/mcp` (OAuth 2.1, Streamable HTTP, 25+ read+write tools).[³] Chapter 01's "CLI > MCP locally" rule was written before this existed. It still holds *locally* (the CLI has no per-session context tax — see below), but the cloud-session rationale ("the MCP is for environments without CLI access") is now backed by a vendor-supported server, not a community one. Flagged for a ch01 reconciliation pass.

## When the CLI wins over an MCP (Q03.19)

The chapter's "CLI > MCP locally" rule now has hard numbers behind it. Anthropic's *Code execution with MCP* reports a five-server setup with **58 tools consumes ~55K tokens before the conversation starts**, and re-expressing those servers as code APIs the agent calls dropped one workflow from **~150,000 to ~2,000 tokens (≈98.7%)**.[⁴] Every loaded MCP server pays a per-session context tax whether or not you use it; a CLI invoked through Bash costs **zero standing tokens**, is deterministic/composable (pipes, exit codes), and the agent already knows shell idioms.

Claude Code now mitigates the tax itself: **MCP Tool Search defers tool definitions** — only tool *names* load at session start, full defs expand on demand.[⁵] So the routing rule sharpens to: **CLI for anything you'd script; MCP when you need OAuth, remote state, or a typed contract `--help` can't give you** — and let Tool Search handle the context cost of the MCPs you do enable.

## Browser tools

Top-line: WebFetch > Playwright MCP > specialized browser MCPs.

Detailed ranking in [browser-tools](./browser-tools.md). Quick rules:

- **Read a public web page** → WebFetch (built-in, ~20× more token-efficient than browser snapshots)
- **Interact with a web app (forms, clicks)** → Playwright MCP
- **Authenticated host session (LinkedIn, etc.)** → BrowserMCP + the user's real Chrome
- **Cloudflare-gated target** → CloakBrowser (sandbox-only)
- **Bulk server-rendered scrape** → Lightpanda or Obscura
- **Cloudflare-free SPA** → Playwright is fine
- **Need DevTools network panel** → chrome-devtools MCP
- **Clean markdown extraction (LLM consumer)** → Firecrawl MCP

## Code / repo tools

### Context7 — library docs

For any library, framework, SDK, API, CLI tool, or cloud service — even well-known ones. API syntax, configuration, version migration, library-specific debugging, setup instructions, CLI tool usage.

Use even when you think you know the answer. Training data may not reflect recent changes.

Workflow:
1. `mcp__context7__resolve-library-id` with the library name → returns canonical ID
2. `mcp__context7__query-docs` with the ID and your specific question → returns excerpts

Do NOT use Context7 for: refactoring, writing scripts from scratch, debugging business logic, code review, general programming concepts.

### Dash (if you use it) — locally-installed docsets

Some users (especially macOS) have Dash with many docsets installed locally. Local docsets are faster than network round-trips and often include GitHub repo docs that aren't on Context7.

Routing: if the tool / library is in your installed docsets, check Dash first. Tools:
- `list_installed_docsets` — see what's available
- `search_documentation` — search
- `load_documentation_page` — read a page

### serena (or other LSP-based) — semantic code navigation

For navigating large codebases, finding symbol usage, jumping to definitions. The right tool for "find every caller of this function" or "where is this exported from?"

Fall back to `grep` / `glob` only if the LSP-based tool can't reach the target language server.

### memory MCP — cross-project memory

Layer 4 of the memory architecture. Use `store_memory` after significant actions, `retrieve_memory` / `search_by_tag` to recall.

Always tag with `project:<name>` when scoped. One shared DB.

Do NOT use the memory MCP to "remember a file." For files, just read.

## Agent orchestration

### Browser-use MCP / Skyvern / Stagehand

These are AI-agent browser frameworks (`act/extract/observe` verbs + LLM-driven retry). Heavier than Playwright but smarter about recovery.

Use when:
- The site changes structure often (selectors drift)
- You want LLM-fallback when scripted selectors fail
- You want one tool that handles both navigation and extraction

Don't use when:
- Site structure is stable (just use Playwright)
- The cost difference matters (these are pricier)

## Cloud / external

### Linear MCP plugin vs CLI

**Local sessions: ALWAYS use CLI** (`linearis` or your wrapper) when the CLI supports the operation. GraphQL for what CLI lacks. Never the Linear MCP plugin locally.

Why: MCP bypasses team filters, rate-limit guards, and CLI caches. Local sessions have access to the CLI; using the MCP creates inconsistency between local and cloud sessions.

**Cloud sessions** (where the CLI isn't installed): the MCP is fine. That's its intended use. As of 2026 that MCP is Linear's own first-party server (`mcp.linear.app`),[³] not a third-party plugin — so the cloud path is now vendor-supported.

This rule generalizes: for any tool with both a CLI and an MCP, prefer the CLI locally. The MCP is for environments without CLI access.

### computer-use MCP

For native desktop apps (Maps, Notes, Finder, Photos, System Settings, third-party native apps) and cross-app workflows. Browsers are at "read only" tier with the screen-shot mode. For terminal/IDE typing → use the built-in Bash tool.

### Web scraping at scale (Firecrawl, Lightpanda, Obscura)

Pick by trade-off:
- **Firecrawl** — cloud, AI-friendly markdown output, costs per page, needs API key
- **Lightpanda** — local, ~1.8s per server-rendered page, doesn't render React, very low RAM
- **Obscura** — local, anti-fingerprint, low RAM, but arch-dependent (check your platform supports it)

For "I want clean markdown from 100 public pages," Firecrawl is the cleanest. For "I want bulk scrape on a budget," Lightpanda. For "I need stealth without RAM bloat," Obscura.

## When NOT to use an MCP

- **Reading a file in the current project** → built-in Read, not memory MCP
- **Running a shell command** → built-in Bash, not a CLI-wrapper MCP
- **Authenticated banking / credential / financial pages** → never any browser MCP; content goes to Anthropic's API
- **Looking up a function in the current project** → Read + grep first; LSP MCP only for cross-file
- **One-off web search** → built-in WebSearch, not a scraper MCP

## Routing precedence cheatsheet

| Need | First reach for | Fallback |
|------|----------------|----------|
| Library docs | Context7 / Dash | WebSearch |
| Read a public web page | WebFetch | Playwright MCP |
| Interact with a web app | Playwright MCP | BrowserMCP (if auth required) |
| Debug a running Chrome | chrome-devtools MCP | Playwright (driving + inspection) |
| Cross-project context recall | memory MCP | grep through Layer 3 |
| Cross-file code navigation | LSP MCP | grep / glob |
| Native desktop app | computer-use MCP | (no fallback) |
| PM tool I/O (local) | CLI | GraphQL via `curl` |
| Bulk server-rendered scrape | Lightpanda / Obscura | Playwright |
| Cloudflare-gated target | CloakBrowser (sandbox) | (no safe fallback) |
| Clean markdown extraction | Firecrawl | Playwright + manual markdown |

## New MCP categories worth a routing rule (Q03.20)

Three categories matured since the chapter was written:

- **Vision / screenshot** — Playwright MCP's *Vision Mode* adds coordinate/screenshot interaction for elements not in the accessibility tree.[⁶] Rule: reach for it **only when DOM/a11y selectors fail**.
- **Memory / vector** — `mem0` and the reference Memory (knowledge-graph) server back semantic, cross-session recall. Rule: Layer-4 only — **cross-session personalization, never "read a file."**
- **Workflow automation** — Zapier MCP (8,000+ app actions) and n8n MCP trigger existing automations with params. Rule: use to reach a SaaS you'd otherwise hand-integrate; don't rebuild a workflow the agent could call.

## Versioning your MCP registry

Maintain a `~/.claude/MCP_REGISTRY.md` listing every MCP, status (enabled/disabled), and routing notes. Update when you add/remove/toggle one or change a routing rule. The registry IS the source of truth for "what MCPs do I have?" — when debugging "why isn't tool X available," check it first. Group by Always-on (global) / Per-project (`.mcp.json`) / Disabled / Deferred.

## Field-tested gotchas

**MCP "enabled" doesn't mean "in scope."** Just because google-calendar MCP is enabled doesn't mean it's acceptable to use. Routing rules trump availability.

**Per-project MCPs in `.mcp.json` only load when you're in that repo.** When you `cd` elsewhere, they're gone. Don't write skills that depend on a per-project MCP without checking it's available.

**MCP versioning matters.** An MCP that worked last month may behave differently after an update. When troubleshooting, check the MCP version.

**Cross-MCP coordination is fragile.** Skills that orchestrate 4 MCPs in sequence are brittle. Each MCP failure compounds. Keep workflows close to single-MCP when possible.

**MCP servers running locally on the same machine compete for resources.** The 24 GB Mac Mini running 8 MCP servers can swap. The lightest MCPs (Obscura ~30 MB/tab, Lightpanda very low) vs heavier (real Chrome ~300 MB) matters.

**MCP servers can leak data to remote providers.** Read each MCP's data flow before enabling on a privacy-sensitive task. The Browser MCPs sending content to Anthropic's API is the canonical example.

## Innovative pattern: routing tests

A `routing-test.md` doc where you list common queries:

```
"List my recent Linear tickets" → CLI (linearis)
"What's the React useState API?" → Context7
"Get the page at <URL>" → WebFetch
"Submit this form on the React app" → Playwright MCP
```

When onboarding a new agent (or re-validating an existing one), feed it these queries and see if it picks the right tool. Catches routing-rule drift.

## Innovative pattern: tier escalation

Build skills that escalate through tiers:

```
/scrape <url>
  → try WebFetch
  → on fail (JS-rendered), retry with Playwright
  → on fail (Cloudflare), retry with CloakBrowser
```

Single command, smart fallback. The agent never has to think about routing for this case.

## Related

- [Browser tools](./browser-tools.md) — full ranked browser routing
- [Agent rules](./agent-rules.md) — when to spawn an agent (separate decision)
- [Chapter 01 — I/O rules](../01-linear-as-load-bearing-pm/io-rules.md) — Linear-specific CLI > MCP rule (see official-MCP flag above)
- [sources.md](./sources.md) — full bibliography

---

[¹]: https://github.com/modelcontextprotocol/servers and https://github.com/modelcontextprotocol/servers-archived — accessed 2026-05-31
[²]: https://code.claude.com/docs/en/mcp (Anthropic Directory, `claude.ai/directory`); https://blog.modelcontextprotocol.io/posts/2025-09-08-mcp-registry-preview/ — accessed 2026-05-31
[³]: https://linear.app/docs/mcp and https://linear.app/changelog/2025-05-01-mcp — accessed 2026-05-31
[⁴]: https://www.anthropic.com/engineering/code-execution-with-mcp — accessed 2026-05-31
[⁵]: https://code.claude.com/docs/en/mcp — accessed 2026-05-31
[⁶]: https://playwright.dev/mcp/vision-mode — accessed 2026-05-31
