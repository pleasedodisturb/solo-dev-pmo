# RESEARCH — Phase P09: Token economy

> **Stream goal:** create chapter 09 from scratch. Covers the cost-optimization stack for solo devs running agents heavily — caching, batching, routing, compression, accounting. **Greenfield, not enrichment.**

## 0. Scope

In:
- **NEW** `09-token-economy/README.md` — chapter overview + stacked-pipeline framing (95–99% reduction is achievable when layers compose)
- **NEW** `09-token-economy/caching-and-batch.md` — prompt caching + batch APIs (the "process-shifting" optimizations)
- **NEW** `09-token-economy/model-routing.md` — tier-based dispatch (RouteLLM, LiteLLM, NotDiamond, hand-rolled)
- **NEW** `09-token-economy/prompt-compression.md` — context-window discipline + compression (LLMLingua, context pruning)
- **NEW** `09-token-economy/cost-tracking.md` — accounting, budgets, alerting
- **NEW** `09-token-economy/sources.md` — bibliography

Out:
- Model selection for quality (chapter 03 portability)
- Specific Claude Code prompt-caching mechanics (chapter 03 enrichment already covered)
- Vendor lock-in critique (handled in chapter 00 single-source-of-truth + chapter 03 portability)

## 1. Background — chapter doesn't exist yet

Greenfield content. **Read these primary sources before drafting:**

### Existing practitioner research to cite

The user's awesome-list is **not a link directory to route around** — it is practitioner-curated research with its own stacked-pipeline derivation, source-class weighting, and cross-tool comparisons. The chapter CITES it as primary for the synthesis-level claims (stacked pipeline math, cross-tool selection, comprehensive scope) and reaches for vendor primary docs **in parallel** for the technical specifics that need a first-party source. Position as same-tier prior art alongside other awesome-lists in the alternatives tables.

| Repo | URL | Existing research to draw from + cite |
|---|---|---|
| `pleasedodisturb/awesome-llm-token-optimization` | https://github.com/pleasedodisturb/awesome-llm-token-optimization | **Cite the README's "Combined pipeline: ... 95-99% cost reduction" as the canonical reference for the stacked-pipeline claim** (Q09.22). Cite the 14 sections as the practitioner-curated cross-tool survey for caching / batch / routing / compression / KV cache / observability. The chapter doesn't re-derive the catalog — it summarizes the load-bearing patterns and points there for the full survey. |

### External primary docs (cite in parallel — these are the technical sources of record)

- **Anthropic** — prompt caching (docs.anthropic.com), token-efficient tool use, message batches, extended thinking + caching, cache-aware rate limits
- **OpenAI** — prompt caching, batch API, batch FAQ, prompt-caching cookbook
- **Google** — Gemini context caching (implicit + explicit), Vertex AI caching, Gemini batch API, Vertex batch prediction
- **DeepSeek** — KV cache (disk-based, 64-token granularity)
- **RouteLLM** (lm-sys) — paper + repo
- **LiteLLM** (BerriAI) — proxy + cost tracking
- **NotDiamond** — per-query model selection
- **LLMLingua** (Microsoft) — prompt compression paper + repo
- **OpenRouter** — model aggregator with pricing transparency
- **Helicone / LangSmith / Langfuse** — observability + cost tracking

### Same-tier adjacent reference catalogs

- `awesome-llm-token-optimization` (author's) — cite specific sections
- `awesome-llm-apps`, `awesome-llmops` — adjacent territory; cite if they cover cost topics

## 2. Honest gaps to be aware of

- **Prices change fast.** Don't quote dollar figures that will be stale in 3 months; cite percentage discounts (90%, 50%) which are sticky, and link to vendor pricing pages.
- **"95-99% reduction" headline is stacked.** Be honest: it's the multiplicative result of caching + routing + batch + compression + response cache. Most teams won't deploy all 5; document realistic single-tactic savings too.
- **Cache eviction + cold starts.** Anthropic's 5min/1hr TTL means cache misses are common for sporadic workloads. Document.
- **Model routing has a quality cost.** Cheaper models miss things; build evaluation into the recommendation, don't hand-wave it.
- **Compression has a quality cost.** LLMLingua at 5x can drop critical context.
- **Solo dev ≠ enterprise.** Don't recommend LiteLLM proxy + Helicone + Langfuse triple-stack if a `tail -f` + a CSV will do.

## 3. Research questions

### Synthesis (cite practitioner research directly)

- **Q09.0** The "Combined pipeline: caching (90%) + routing (60–95%) + batch (50%) + compression (5–20x) + response cache (100% on repeats) = 95–99% reduction" derivation is published in `pleasedodisturb/awesome-llm-token-optimization`'s README "Quick Wins" section. Cite it as the canonical reference for this chapter's headline framing. Re-derive the math honestly in the chapter; if any single number is stale or doesn't hold under realistic conditions, surface — don't quietly soften.

### Caching

- **Q09.1** Current 2026 vendor caching matrix: Anthropic / OpenAI / Google / DeepSeek / xAI / Mistral. Discount %, TTL, minimum token threshold, manual vs automatic. Build a table.
- **Q09.2** "Cached prefix pattern" — structure prompts so first ~2K tokens are the cacheable system+context. Document the pattern with code.
- **Q09.3** Cache-aware rate limits — Anthropic's 2025–2026 update (cached input tokens count differently against rate limits). Cite + recipe.
- **Q09.4** Cache + extended thinking interaction — Anthropic shipped this in 2025. What's the right pattern for agent loops?
- **Q09.5** Self-hosted KV cache for OSS models — vLLM, SGLang, TGI. Worth covering for solo dev with own GPU? Probably brief mention.

### Batch APIs

- **Q09.6** Vendor batch matrix: Anthropic / OpenAI / Google. Discount, limits, turnaround SLA.
- **Q09.7** When does batch make sense for solo dev? (Bulk scoring, overnight processing, eval runs.) Anti-patterns (anything user-facing).
- **Q09.8** Caching + batch — do they compose? Vendor-by-vendor.

### Model routing

- **Q09.9** RouteLLM / LiteLLM / NotDiamond comparison — open vs commercial, training data needs, latency overhead, observability.
- **Q09.10** "Tier the workload, not the model" — when to route by task complexity (Haiku for classification, Sonnet for synthesis, Opus for reasoning). Build a tier-to-task map.
- **Q09.11** Cross-provider routing — when does going to OpenRouter / LiteLLM beat staying with one vendor? Trade-offs: latency, billing simplicity, eval burden, data-residency.
- **Q09.12** Hand-rolled router — when is a 50-line `if-task-type: model = X` enough vs needing RouteLLM's preference-trained classifier?
- **Q09.13** Quality regression risk — what eval suite catches "router sent it to a weaker model that botched it"?

### Prompt compression + context discipline

- **Q09.14** LLMLingua 1/2 — actual performance on common tasks; when does it preserve quality vs degrade? Cite Microsoft Research paper.
- **Q09.15** Context-window management without compression — selective retrieval (RAG), conversation summarization (Anthropic's compaction), context pruning. Compare.
- **Q09.16** Auto-compaction (Claude Code, Cursor, Cline) — when it fires, what it preserves, how to design prompts to survive it.
- **Q09.17** "How short can prompts go?" — diminishing returns curve. Practitioner data.

### Cost tracking + budgets

- **Q09.18** Solo-dev cost tracking — what's the minimum viable approach? (Vendor dashboard + monthly review?) When to upgrade to LiteLLM proxy / Helicone / Langfuse / OpenMeter.
- **Q09.19** Per-project / per-skill cost attribution — patterns that work without full observability stack.
- **Q09.20** Budgets + alerts — vendor-native budget APIs (Anthropic console, OpenAI usage, Google billing alerts) vs LiteLLM budget policies.
- **Q09.21** "Cost of agents" empirical data — what does a typical Claude Code session cost? What does a typical /gsd-execute-phase cost? Practitioner-published numbers.

### Cross-cutting

- **Q09.22** The "stacked 95-99% reduction" claim — derive honestly. Show the math.
- **Q09.23** What does NOT help despite popular belief — myth-busting (e.g., "smaller temperatures save tokens" no; "shorter system prompts always help" depends).

## 4. Per-question source plan

| Q | Source class | Specific starting points |
|---|---|---|
| Q09.1–Q09.4 | Primary | docs.anthropic.com/en/docs/build-with-claude/prompt-caching; openai.com/docs/guides/prompt-caching; ai.google.dev/gemini-api/docs/caching; api-docs.deepseek.com/guides/kv_cache; anthropic.com/news/token-saving-updates. |
| Q09.5 | Primary | docs.vllm.ai; sglang.ai; huggingface.co/docs/text-generation-inference. |
| Q09.6–Q09.8 | Primary | docs.anthropic.com/en/api/creating-message-batches; openai.com/docs/guides/batch; ai.google.dev/gemini-api/docs/batch-api. |
| Q09.9–Q09.13 | Primary | github.com/lm-sys/RouteLLM; github.com/BerriAI/litellm; github.com/Not-Diamond/notdiamond-python; openrouter.ai/docs. |
| Q09.14 | Primary + academic | github.com/microsoft/LLMLingua; arXiv: Jiang et al. 2023 (LLMLingua) and 2024 (LLMLingua-2). |
| Q09.15–Q09.17 | Primary | Anthropic engineering blog on context management; Claude Code docs on compaction; Cursor docs on context; cline.bot docs on memory/context. |
| Q09.18–Q09.20 | Primary + practitioner | helicone.ai, langfuse.com, openmeter.io. LiteLLM budget policies docs. Vendor billing dashboards. |
| Q09.21 | Practitioner | HN/Reddit/X for "Claude Code session cost" published numbers. Author's own usage if shared. |
| Q09.22–Q09.23 | Synthesis | Derive from above; cite individual data points. |

## 5. Output requirements

The agent creates (NEW files) in `/Users/pleasedodisturb/Projects/playbooks/solo-dev-pmo/09-token-economy/`:

1. **`README.md`** (≤100 lines) — chapter overview; the "stacked pipeline" framing (caching × routing × batch × compression × response cache); sub-topic table; **honest "single-tactic savings" baseline** (cache alone ≈ 88%; routing alone 60–95%; batch alone 50%); cross-links to chapters 03 (operator) and 08 (safety — routing has a quality regression risk that ch08 patterns help catch)
2. **`caching-and-batch.md`** (≤250 lines) — covers Q09.1–Q09.8
   - Vendor caching matrix (table)
   - Cached prefix pattern + code example
   - Cache-aware rate limits
   - Cache + extended thinking pattern for agent loops
   - Vendor batch matrix (table)
   - When batch makes sense for solo dev; anti-patterns
   - **Alternatives table:** Anthropic / OpenAI / Google / DeepSeek / self-hosted (vLLM, SGLang) — same-tier
3. **`model-routing.md`** (≤250 lines) — covers Q09.9–Q09.13
   - Tier-the-workload table (Haiku/Sonnet/Opus mapping)
   - RouteLLM vs LiteLLM vs NotDiamond comparison
   - Hand-rolled router (when 50 lines is enough)
   - Cross-provider routing trade-offs
   - **Eval-gate** subsection — every routing decision needs an eval gate, here's the minimum
   - **Alternatives table:** hand-rolled, RouteLLM, LiteLLM, NotDiamond, OpenRouter — same-tier
4. **`prompt-compression.md`** (≤250 lines) — covers Q09.14–Q09.17
   - LLMLingua 1/2 — actual savings + when to use vs avoid
   - Selective retrieval vs summarization vs compression — three knobs, one table
   - Auto-compaction interaction (cross-link chapter 03)
   - Diminishing returns curve for prompt shortening
5. **`cost-tracking.md`** (≤250 lines) — covers Q09.18–Q09.21
   - Solo-dev minimum viable: vendor dashboard + monthly CSV export
   - When to upgrade to LiteLLM proxy / Helicone / Langfuse
   - Per-project / per-skill attribution patterns without full observability
   - Budget + alert recipes (Anthropic console, OpenAI usage limits, Google billing alerts)
   - Published cost data for typical Claude Code sessions / agent runs
6. **`sources.md`** — bibliography
7. **`RESEARCH-LOG.md`** in `.planning/09-token-economy/`

Voice + caps: same as rest of playbook. Honest about myths (Q09.23). Honest about quality regressions from routing/compression. Don't quote dollar amounts that will stale; quote percentages and link to live pricing.

Constraints:
- DO cite `pleasedodisturb/awesome-llm-token-optimization` as same-tier prior art (with other awesome-lists) — point readers there for the full catalog, but reference specific primary docs in the chapter
- DO NOT duplicate the entire awesome-list into the chapter
- DO acknowledge what cloud sessions / agent platforms already optimize for you
- DO build the stacked-pipeline math honestly
- DO include eval gates wherever routing or compression appears

## 6. Per-phase search ideas

### Web

- `site:docs.anthropic.com prompt caching batch`
- `site:openai.com/docs prompt caching batch`
- `site:ai.google.dev caching batch`
- `site:api-docs.deepseek.com kv_cache`
- `site:github.com/microsoft/LLMLingua`
- `site:github.com/lm-sys/RouteLLM`
- `site:github.com/BerriAI/litellm budget`
- `site:helicone.ai pricing`
- `site:langfuse.com cost`
- `"95% cost reduction" LLM token`
- `arxiv "prompt compression" 2024 OR 2025 OR 2026`

### Social

- HN: `https://hn.algolia.com/?q=LLM+cost+reduction`
- HN: `https://hn.algolia.com/?q=prompt+caching`
- HN: `https://hn.algolia.com/?q=LiteLLM+RouteLLM`
- HN: `https://hn.algolia.com/?q=LLMLingua`
- Lobsters: `https://lobste.rs/search?q=LLM+cost`
- Reddit: `site:reddit.com/r/LocalLLaMA cost optimization`
- Reddit: `site:reddit.com/r/ClaudeAI session cost`
- X: handles `@simonw`, `@swyx`, `@karpathy`, `@LangChainAI`, `@HeliconeAI`
- X: `(Claude Code) session cost token min_faves:30`

### GitHub

- `pleasedodisturb/awesome-llm-token-optimization` (read all 14 sections)
- `lm-sys/RouteLLM`, `BerriAI/litellm`, `Not-Diamond/notdiamond-python`, `microsoft/LLMLingua`
- `helicone/helicone`, `langfuse/langfuse`, `openmeter-io/openmeter`
- `OpenRouterTeam/openrouter-runner`
- `topic:llm-cost`, `topic:llm-observability`, `topic:llm-router`

## 7. Stop conditions

Stop and surface if:

- A vendor changes pricing model materially (e.g., Anthropic drops cache discount, OpenAI raises batch from 50%) — surface; don't silently embed a stale figure
- LLMLingua-3 or a successor materially supersedes the compression recommendation — surface
- RouteLLM or LiteLLM is unmaintained / archived — surface
- A new "agent cost optimization" framework emerges that obsoletes the chapter's structure — surface
- "Stacked 95-99%" math doesn't hold up when derived honestly — present the real number
- Chapter would exceed 5 sub-topic files

## 8. Estimated effort

M phase. 6–9 hrs research (vendor docs across 4+ vendors; the awesome-list is a starting map, not the destination) + 5–7 hrs writing. Single agent fine; sub-topics are mostly independent but the README synthesis comes last.
