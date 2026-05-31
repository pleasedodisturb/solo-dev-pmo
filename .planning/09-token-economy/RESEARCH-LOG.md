# RESEARCH-LOG — Phase P09: Token economy (greenfield)

Append-only log of sources cited while creating chapter 09. Format per
[SEARCH-PLAYBOOK.md](../SEARCH-PLAYBOOK.md) §"Per-phase research log format".

Greenfield chapter — five new files (README + 4 sub-topics) + sources.md.
Research fanned out across four parallel clusters (caching/batch, routing,
compression, cost-tracking) + the canonical awesome-list framing.

Global access caveat: vendor doc domains (platform.claude.com, platform.openai.com,
ai.google.dev, api-docs.deepseek.com, docs.x.ai, docs.litellm.ai, openrouter.ai),
arXiv, and several vendor blogs returned **HTTP 403 to automated fetch**. Facts
from those were captured via search-index extraction of the same primary URLs and
flagged inline. The one directly-fetched primary was Anthropic's compaction doc.

---

## 2026-05-31 — Canonical stacked-pipeline framing (Q09.0, Q09.22)

- **Source:** https://github.com/pleasedodisturb/awesome-llm-token-optimization (README, "Quick Wins" / Combined pipeline)
- **Class:** practitioner / same-tier prior art (cited as primary for synthesis)
- **Surfaced fact:** "Cache prefix (90%) + route to cheapest model (60–95%) + batch non-urgent (50%) + compress prompts (5–20×) + cache responses (100% on repeats) = 95–99% cost reduction vs. naive." 14 sections; per-tool comparison claims (e.g. WebFetch ~20× vs Playwright MCP).
- **Used in:** README.md (headline framing + honest re-derivation)
- **Counter-evidence:** the 95–99% is an *envelope*, not a per-request discount; re-derived honestly — caching×batch genuinely compose (0.5×0.1=95%), routing/compression stack below but carry quality cost + prerequisites. Realistic floor ~50% for unique/urgent/terse traffic.

## 2026-05-31 — Vendor caching matrix (Q09.1–Q09.4)

- **Source:** platform.claude.com/.../prompt-caching ; openai.com/index/api-prompt-caching ; ai.google.dev/.../caching ; api-docs.deepseek.com/guides/kv_cache ; docs.x.ai ; docs.mistral.ai
- **Class:** primary (vendor docs; mostly via search extraction, 403)
- **Surfaced fact:** Anthropic 90% read (0.1×), 1.25×/2× write, 5min/1hr TTL, 1,024 (Sonnet) / 4,096 (Opus, Haiku 4.5) min, 4 breakpoints. OpenAI 50% auto, 1,024 min. Gemini ~90%, implicit on by default 2.5+. DeepSeek ~90%, 64-token granularity, automatic. xAI ~75–84% (aggregator). Mistral ~90% (aggregator).
- **Used in:** caching-and-batch.md (vendor matrix, cached-prefix pattern)
- **Counter-evidence / flag:** newest model names + per-model thresholds volatile; Gemini per-model min conflicting; xAI/Mistral % aggregator-reported.

## 2026-05-31 — Cache-aware rate limits + thinking + token-efficient tools (Q09.3–Q09.4)

- **Source:** https://www.anthropic.com/news/token-saving-updates ; prompt-caching doc
- **Class:** primary (vendor blog + docs)
- **Surfaced fact:** cache-read tokens no longer count against ITPM (since 3.7 Sonnet). Thinking blocks ride cached request content; stripped by non-tool-result user content on older models, preserved by default on Opus 4.5+/Sonnet 4.6+. token-efficient-tools-2025-02-19 = ~14% avg / up to 70% output cut; built into all Claude 4.
- **Used in:** caching-and-batch.md (rate limits, agent-loop thinking pattern)
- **Counter-evidence:** none

## 2026-05-31 — Vendor batch matrix + composition (Q09.6–Q09.8)

- **Source:** platform.claude.com/.../batch-processing ; openai.com/docs/guides/batch ; ai.google.dev/.../batch-api
- **Class:** primary
- **Surfaced fact:** all three majors = 50% in+out, ~24h. Anthropic 100k req/256MB, results 29 days; cache hits in batch best-effort (warm with 1hr TTL first). OpenAI/Google: caching + batch compose/stack.
- **Used in:** caching-and-batch.md (batch matrix, the 0.5×0.1=95% floor)
- **Counter-evidence / flag:** exact stacked effective rates are arithmetic, not vendor-stated.

## 2026-05-31 — Model routing tools (Q09.9–Q09.13)

- **Source:** github.com/lm-sys/RouteLLM (+ arXiv:2406.18665) ; github.com/BerriAI/litellm ; github.com/Not-Diamond/notdiamond-python ; openrouter.ai
- **Class:** primary (repos + paper)
- **Surfaced fact:** RouteLLM = preference-trained, "85% MT-Bench / 45% MMLU / 35% GSM8K cost cut at 95% GPT-4 quality"; **stale, last commit Aug 2024, no release**. LiteLLM active (v1.86.2, May 2026), load-balance routing + budgets, proxy=overkill solo, SDK fine. NotDiamond per-query meta-router, **SDK archived Dec 2025**, service powers OpenRouter Auto. OpenRouter no inference markup (~5.5% credit fee).
- **Used in:** model-routing.md (tool comparison, RouteLLM evidence)
- **Counter-evidence:** arXiv:2505.12601 — simple kNN can match learned routers (lightweight-first). RouteLLM stale + NotDiamond archived = **stop-condition flags surfaced**, not silently adopted.

## 2026-05-31 — Tiering + eval gate (Q09.10, Q09.13)

- **Source:** platform.claude.com/.../models/overview ; promptfoo.dev ; evidentlyai.com ; traceloop.com
- **Class:** primary (vendor model docs) + practitioner (eval tooling)
- **Surfaced fact:** Anthropic endorses 3-tier mapping (Haiku=simple/high-volume, Sonnet=default, Opus=hard reasoning). Eval gate = per-route golden set + frontier baseline + LLM-as-judge + tripwire margin; gate on cost+latency+quality together.
- **Used in:** model-routing.md (tier table, the eval-gate subsection)
- **Counter-evidence:** none

## 2026-05-31 — LLMLingua family (Q09.14)

- **Source:** github.com/microsoft/LLMLingua ; arXiv:2310.05736 / 2403.12968 / 2310.06839 ; survey 2410.12388
- **Class:** primary (repo) + academic
- **Surfaced fact:** LLMLingua "up to 20× little loss" (GSM8K/BBH/ShareGPT/Arxiv). LLMLingua-2 extractive token-classification, distilled from GPT-4, 3–6× faster, typical 2–5×. LongLLMLingua +17.1% at ~4×, +21.4% RAG at 1/4 tokens. Preserves reasoning/summarization/dialogue; **breaks code/SQL/tables/structured data**. No quantified cliff ratio (genuine gap).
- **Used in:** prompt-compression.md (LLMLingua matrix, when-to-use)
- **Counter-evidence / flag:** **maintenance-mode** — last release V0.2.2 (Apr 2024), no v3, lab pivoted to SecurityLingua. Provider-native context management has eaten the agent use case. Stop-condition flag surfaced.

## 2026-05-31 — Context discipline + compaction (Q09.15–Q09.16)

- **Source:** anthropic.com/engineering/effective-context-engineering ; anthropic.com/news/context-management ; platform.claude.com/.../compaction (direct fetch OK) ; code.claude.com/.../how-claude-code-works
- **Class:** primary (vendor blog + docs)
- **Surfaced fact:** "attention budget" / "context rot"; just-in-time retrieval. Context editing (clear_tool_uses_20250919) + memory tool (memory_20250818) shipped Sept 2025: **84% token cut / 39% perf (29% editing alone)**. Compaction primitive compact_20260112: default trigger 150K (min 50K), drops blocks before summary. Claude Code auto-compact ~95% + micro-compact. CLAUDE.md survives.
- **Used in:** prompt-compression.md (context-discipline section, three-knobs table, design-to-survive-compaction)
- **Counter-evidence:** provider-native features beat lossy compression on agent workloads — chapter ranks compression last accordingly.

## 2026-05-31 — Diminishing returns + myths (Q09.17, Q09.23)

- **Source:** promptlayer.com ; mlops.community ; ibm.com/think/llm-temperature ; arXiv:2509.13196
- **Class:** practitioner + academic
- **Surfaced fact:** shortening returns U-shaped (under-specification raises variance). Temperature ≠ token savings. Shorter system prompt not always better. Few-shot collapse: Gemma 7B 77.9→39.9, LLaMA-2 70B 68.6→21.0 with added examples (NDSS/arXiv 2025).
- **Used in:** prompt-compression.md (how-short + myth-busting)
- **Counter-evidence:** none — these ARE the counter-evidence to popular cost myths.

## 2026-05-31 — Cost tracking + budgets + empirical agent cost (Q09.18–Q09.21)

- **Source:** code.claude.com/docs/en/costs + monitoring-usage ; platform.claude.com usage-cost-api + workspaces ; github.com/ryoppippi/ccusage ; langfuse/helicone/openmeter ; platform.openai.com/settings limits ; cloud.google.com/billing
- **Class:** primary (docs + repos) + practitioner (empirical)
- **Surfaced fact:** ccusage = solo winner (local JSONL, MIT). /usage attributes to skills/subagents/plugins/MCP. Admin API requires org (not for individuals). **OpenAI removed hard budget caps** (notification-only). GCP/Anthropic standard = alerts not stops; hard stop needs LiteLLM/Pub-Sub/workspace limits. Empirical: Anthropic $13/active-day, $150–250/mo, <$30/day for 90%; idle <$0.04/session. Multi-agent 15× tokens (80% of variance); agent teams 7×. Daily Claude Code user → Max subscription beats API (~93% case).
- **Used in:** cost-tracking.md (whole file)
- **Counter-evidence / flag:** budgets-are-alerts-not-stops is the load-bearing gotcha; plan-vs-API $ figures secondary/stale-prone, linked to live pricing.

## Stop-conditions surfaced (per RESEARCH.md §7)

1. **RouteLLM stale** (no commit since Aug 2024) — flagged in model-routing.md + sources.md; cited as research artifact, not live software. Did NOT silently recommend.
2. **NotDiamond SDK archived** Dec 2025 — flagged; routed readers to the still-live hosted service via OpenRouter.
3. **LLMLingua maintenance-mode, no v3** — flagged; recommendation narrowed to RAG/batch, with provider-native context management noted as superseding the agent use case.
4. **OpenAI removed hard budget caps** (pricing-model change) — surfaced as the cost-tracking gotcha, not embedded as a stale "set a cap" recipe.
5. **Stacked 95–99% math** — re-derived honestly in README: holds as an envelope, ~50% realistic floor; no single number quietly softened — each stale/aggregator figure flagged.
6. **5 sub-topic files** — stayed within the brief's cap (README + 4 sub-topics; no overflow).
