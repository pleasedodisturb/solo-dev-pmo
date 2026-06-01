# Sources — Chapter 03

Bibliography for the P03 research enrichment. All sources accessed **2026-05-31** unless noted. Weighted per [SEARCH-PLAYBOOK](../.planning/SEARCH-PLAYBOOK.md): primary docs > vendor blog > academic > practitioner > community. Per-question provenance is in [`.planning/03-claude-code-as-operator/RESEARCH-LOG.md`](../.planning/03-claude-code-as-operator/RESEARCH-LOG.md).

## Primary — Claude Code / Anthropic docs

- Hooks — https://code.claude.com/docs/en/hooks
- Skills — https://code.claude.com/docs/en/skills
- Plugins — https://code.claude.com/docs/en/plugins
- Subagents — https://code.claude.com/docs/en/sub-agents
- Memory (CLAUDE.md) — https://code.claude.com/docs/en/memory
- MCP — https://code.claude.com/docs/en/mcp
- Prompt caching — https://code.claude.com/docs/en/prompt-caching
- Costs — https://code.claude.com/docs/en/costs
- Monitoring / OTEL — https://code.claude.com/docs/en/monitoring-usage
- Agent SDK — https://code.claude.com/docs/en/agent-sdk/overview
- Changelog / overview — https://code.claude.com/docs/en/changelog
- Usage & Cost Admin API — https://platform.claude.com/docs/en/build-with-claude/usage-cost-api
- Prompt caching (API spec) — https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- *Ground-truth:* this Claude Code v2.1.158 session (`~/.claude/settings.json`, path encoding, `SKILL.md` layout)

## Primary — other agent platforms

- Cursor rules / hooks — https://cursor.com/docs/rules · https://cursor.com/docs/agent/hooks
- OpenAI Codex (subagents, sandboxing, AGENTS.md) — https://developers.openai.com/codex/subagents
- Aider conventions — https://aider.chat/docs/usage/conventions.html
- Cline Memory Bank — https://docs.cline.bot/features/memory-bank
- Continue rules — https://docs.continue.dev/customize/deep-dives/rules
- AGENTS.md standard — https://agents.md/
- Linear MCP (official) — https://linear.app/docs/mcp · https://linear.app/changelog/2025-05-01-mcp

## Primary — MCP / memory ecosystem

- MCP reference servers — https://github.com/modelcontextprotocol/servers · …/servers-archived
- MCP registry (preview) — https://blog.modelcontextprotocol.io/posts/2025-09-08-mcp-registry-preview/
- Playwright MCP vision mode — https://playwright.dev/mcp/vision-mode
- mem0 — https://docs.mem0.ai/platform/overview · https://github.com/mem0ai/mem0
- Letta (MemGPT) — https://docs.letta.com/concepts/letta/
- LangGraph / LangMem — https://docs.langchain.com/oss/python/concepts/memory
- OpenAI memory — https://help.openai.com/en/articles/11146739

## Vendor engineering blogs

- Code execution with MCP (58 tools≈55K tokens; 150K→2K) — https://www.anthropic.com/engineering/code-execution-with-mcp
- Writing effective tools for agents — https://www.anthropic.com/engineering/writing-tools-for-agents
- Effective context engineering ("attention budget", context rot) — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Multi-agent research system (~15× tokens) — https://www.anthropic.com/engineering/multi-agent-research-system
- Lessons from building Claude Code: prompt caching — https://claude.com/blog/lessons-from-building-claude-code-prompt-caching-is-everything
- OpenAI co-founds Agentic AI Foundation (Linux Foundation) — https://openai.com/index/agentic-ai-foundation/

## Academic

- RULER (effective context length), arXiv:2404.06654
- NoLiMa (non-lexical long-context), arXiv:2502.05167
- "Lost in the Middle," Liu et al., TACL 2024 (arXiv:2307.03172)
- TLS-fingerprint bot detection (CatBoost AUC 0.998), arXiv:2602.09606 (2026-02-10)

## Practitioner / industry

- Chroma "Context Rot" (18 models) — https://www.trychroma.com/research/context-rot
- Post-quantum TLS bot detection — https://scrapfly.io/blog/posts/post-quantum-tls-bot-detection
- JA3→JA4+ 2026 — https://packet.guru/blog/TLS-Fingerprinting-JA3-JA4
- DataDome JA4+ 2026 — https://www.startertutorials.com/blog/bypassing-datadome-in-2026-the-ultimate-engine-level-guide.html
- Firecrawl self-host limits — https://filipkonecny.com/2026/03/29/firecrawl-limitations/
- ccusage — https://dev.to/stevengonsalvez/ccusage-finally-know-how-much-claude-code-is-actually-costing-you-1873
- Cursor hooks (1.7) — https://www.infoq.com/news/2025/10/cursor-hooks/

## Tool repos (browser / scraping)

- primp — https://github.com/deedy5/primp
- curl-impersonate (stale) / curl_cffi (active fork) — https://github.com/lwthiker/curl-impersonate · https://github.com/lexiforest/curl_cffi
- Patchright — https://github.com/Kaliiiiiiiiii-Vinyzu/patchright
- Camoufox — https://github.com/daijro/camoufox
- nodriver — https://github.com/ultrafunkamsterdam/nodriver
- rebrowser-patches — https://github.com/rebrowser/rebrowser-patches
- Obscura — https://github.com/h4ckf0r0day/obscura
- CloakBrowser — https://github.com/CloakHQ/CloakBrowser
- Firecrawl — https://github.com/mendableai/firecrawl
- Lightpanda — https://github.com/lightpanda-io/browser · Servo https://servo.org/ · Ladybird https://ladybird.org/

## Community / comparison

- gstack (operator framing, ~31 skills) — https://github.com/garrytan/gstack
- awesome-mcp-servers — https://github.com/punkpeye/awesome-mcp-servers

## Verification caveats

- **WebFetch 403'd** on `cursor.com`, `agents.md`, `aider.chat`, `docs.cline.bot`, `docs.continue.dev`, and several vendor blogs/Chroma; those rows rest on WebSearch extraction of the same primary pages. Re-verify exact Cursor MDC frontmatter keys and the AGENTS.md governance detail against live pages before any print edition.
- The **AUC-0.998 JA4 paper** is research-grade, not a vendor-deployed metric — cited as such.
- `registry.modelcontextprotocol.io` not independently re-fetched; docs route users to the Anthropic Directory (`claude.ai/directory`).
- The brief's "gstack 65+ skills" figure is inflated — current docs show ~31 core.
