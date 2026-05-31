# Sources — Chapter 09

Bibliography for the P09 greenfield research. All sources accessed **2026-05-31** unless noted. Weighted per [SEARCH-PLAYBOOK](../.planning/SEARCH-PLAYBOOK.md): primary docs > vendor blog > academic > practitioner > community. Per-question provenance is in [`.planning/09-token-economy/RESEARCH-LOG.md`](../.planning/09-token-economy/RESEARCH-LOG.md).

> **Fetch caveat:** Vendor doc domains (`platform.claude.com`, `platform.openai.com`, `ai.google.dev`, `api-docs.deepseek.com`, `docs.x.ai`, `docs.litellm.ai`, `openrouter.ai`), arXiv, and several vendor blogs return **HTTP 403 to automated fetch** from this environment. Figures from those pages were captured via search-index extraction of the same primary URLs and are flagged inline in each sub-topic. **Re-verify the volatile rows** (newest model names + per-model cache thresholds, xAI/Mistral cache %, stacked effective rates) against the live pages before any print edition.

## Same-tier prior art (cited as primary for synthesis)

- `pleasedodisturb/awesome-llm-token-optimization` — Quick Wins / Combined-pipeline derivation (canonical headline framing, Q09.0/22) + 14-section cross-tool catalog — https://github.com/pleasedodisturb/awesome-llm-token-optimization
- `BerriAI/awesome-llmops`, `Shubhamsaboo/awesome-llm-apps` — adjacent reference catalogs (cost/observability sections)

## Primary — caching

- Anthropic prompt caching — https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- Anthropic token-saving updates (cache-aware rate limits, token-efficient tools) — https://www.anthropic.com/news/token-saving-updates
- OpenAI prompt caching — https://platform.openai.com/docs/guides/prompt-caching ; https://openai.com/index/api-prompt-caching/
- Google Gemini context caching — https://ai.google.dev/gemini-api/docs/caching ; implicit caching — https://developers.googleblog.com/gemini-2-5-models-now-support-implicit-caching/
- DeepSeek KV cache (disk, 64-token) — https://api-docs.deepseek.com/guides/kv_cache
- xAI Grok prompt caching — https://docs.x.ai/developers/advanced-api-usage/prompt-caching
- Mistral API (caching) — https://docs.mistral.ai/api
- vLLM Automatic Prefix Caching — https://docs.vllm.ai/en/stable/design/prefix_caching/
- SGLang / RadixAttention — https://lmsys.org/blog/2024-01-17-sglang/

## Primary — batch

- Anthropic Message Batches — https://platform.claude.com/docs/en/build-with-claude/batch-processing ; https://www.anthropic.com/news/message-batches-api
- OpenAI Batch — https://platform.openai.com/docs/guides/batch ; FAQ https://help.openai.com/en/articles/9197833-batch-api-faq
- Google Gemini Batch — https://ai.google.dev/gemini-api/docs/batch-api

## Primary — model routing

- RouteLLM repo — https://github.com/lm-sys/RouteLLM (last commit Aug 2024; stale)
- RouteLLM paper (85% MT-Bench cost cut at 95% GPT-4 quality) — arXiv:2406.18665 — https://arxiv.org/abs/2406.18665
- "When Simple kNN Beats Complex Learned Routers" — arXiv:2505.12601 — https://arxiv.org/abs/2505.12601
- LiteLLM repo + routing docs — https://github.com/BerriAI/litellm ; https://docs.litellm.ai/docs/routing
- NotDiamond Python SDK — https://github.com/Not-Diamond/notdiamond-python (archived Dec 2025)
- OpenRouter docs / pricing / auto-router — https://openrouter.ai/docs ; https://openrouter.ai/pricing ; https://openrouter.ai/openrouter/auto
- Anthropic model selection (tiering) — https://platform.claude.com/docs/en/about-claude/models/overview ; https://claude.com/resources/tutorials/choosing-the-right-claude-model
- Router-vs-gateway maturity guidance — https://atlan.com/know/llm/model-router-vs-model-gateway/

## Primary — prompt compression + context discipline

- LLMLingua repo + releases — https://github.com/microsoft/LLMLingua ; https://github.com/microsoft/LLMLingua/releases (last V0.2.2, Apr 2024)
- LLMLingua paper — arXiv:2310.05736 (EMNLP 2023) — https://arxiv.org/abs/2310.05736
- LLMLingua-2 paper — arXiv:2403.12968 (ACL 2024 Findings) — https://arxiv.org/abs/2403.12968
- LongLLMLingua paper — arXiv:2310.06839 (ACL 2024) — https://arxiv.org/abs/2310.06839
- Prompt-compression survey — arXiv:2410.12388 — https://arxiv.org/html/2410.12388v2
- Anthropic context engineering (attention budget, context rot) — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Anthropic context editing + memory tool (84% token cut) — https://www.anthropic.com/news/context-management ; https://platform.claude.com/docs/en/build-with-claude/context-editing
- Anthropic compaction primitive (`compact_20260112`, 150K trigger) — https://platform.claude.com/docs/en/build-with-claude/compaction
- Claude Code internals (auto-compact) — https://code.claude.com/docs/en/how-claude-code-works
- Over-prompting / few-shot collapse — arXiv:2509.13196 — https://arxiv.org/html/2509.13196v1

## Primary — cost tracking + budgets

- Claude Code costs (`/usage`, $13/active-day, 7× agent teams) — https://code.claude.com/docs/en/costs
- Claude Code monitoring / OTEL — https://code.claude.com/docs/en/monitoring-usage
- Anthropic Usage & Cost Admin API — https://platform.claude.com/docs/en/manage-claude/usage-cost-api
- Anthropic workspaces (spend limits) — https://platform.claude.com/docs/en/build-with-claude/workspaces
- OpenAI usage/cost API — https://platform.openai.com/docs/api-reference/usage ; cookbook https://developers.openai.com/cookbook/examples/completions_usage_api
- OpenAI limits (hard caps removed) — https://platform.openai.com/settings/organization/limits
- Google Cloud budgets + billing killswitch — https://cloud.google.com/billing/docs/how-to/budgets ; https://cloud.google.com/billing/docs/how-to/disable-billing-with-notifications
- LiteLLM budgets/keys — https://docs.litellm.ai/docs/proxy/virtual_keys ; https://docs.litellm.ai/docs/proxy/users
- ccusage — https://github.com/ryoppippi/ccusage ; https://ccusage.com/guide/cost-modes
- Langfuse — https://langfuse.com/pricing ; https://github.com/langfuse/langfuse
- Helicone — https://github.com/helicone/helicone ; https://www.helicone.ai/pricing
- OpenMeter — https://github.com/openmeterio/openmeter ; https://openmeter.io/use-cases/ai

## Vendor engineering blogs

- Anthropic multi-agent research system (15× tokens; 80% variance) — https://www.anthropic.com/engineering/multi-agent-research-system

## Academic

- RouteLLM (2406.18665) · kNN routing (2505.12601) · LLMLingua (2310.05736) · LLMLingua-2 (2403.12968) · LongLLMLingua (2310.06839) · compression survey (2410.12388) · over-prompting (2509.13196)

## Practitioner / community

- Simon Willison on ccusage / Claude Code spend — https://simonwillison.net/2025/Jul/14/ccusage/
- promptfoo LLM-as-judge (eval gate) — https://www.promptfoo.dev/docs/guides/llm-as-a-judge/
- Evidently / Traceloop eval-gate CI — https://www.evidentlyai.com/llm-guide/llm-as-a-judge ; https://www.traceloop.com/blog/automated-prompt-regression-testing-with-llm-as-a-judge-and-ci-cd
- Prompt-shortening returns — https://blog.promptlayer.com/why-llms-get-distracted-and-how-to-write-shorter-prompts/ ; https://mlops.community/blog/the-impact-of-prompt-bloat-on-llm-output-quality
- LLM temperature ≠ token savings — https://www.ibm.com/think/topics/llm-temperature
- Plan-vs-API economics (secondary, stale-prone) — relayplane.com/blog/claude-code-max-vs-api-2026 ; findskill.ai ; nxcode.io
- OpenAI removed hard budget caps — https://grafient.ai/blog/openai-removed-hard-budget-limits

## Verification caveats

- **All vendor doc domains + arXiv 403 to automated fetch.** The one directly-fetched primary was Anthropic's compaction doc (`compact_20260112`, 150K trigger — reliable). Everything else on those domains is search-extraction; verbatim quotes need a live re-check before print.
- **Volatile rows flagged for re-verification:** newest Anthropic model names + their per-model cache minimums; Gemini per-model thresholds (1,024 vs 2,048 vs 4,096 — conflicting); xAI/Mistral cached-input percentages (aggregator-reported); stacked effective rates (arithmetic, not vendor-stated).
- **Stale-software flags (per stop-conditions):** RouteLLM — no commit since Aug 2024, no release; NotDiamond Python SDK — archived read-only Dec 2025 (hosted service lives on via OpenRouter Auto); LLMLingua — last release V0.2.2 (Apr 2024), no v3, lab pivoted to SecurityLingua; TGI — maintenance mode late 2025.
- **Pricing-model gotcha (per stop-conditions):** OpenAI removed *hard* budget caps — monthly budget is notification-only. Neither GCP, Vertex, nor the standard Anthropic individual API offers a true hard spend cutoff. Documented in cost-tracking.md as the load-bearing gotcha.
- **`$` figures intentionally minimized.** Only Anthropic's own published per-day Claude Code averages are quoted (dated, attributed); all plan/tier prices link to live pages.
