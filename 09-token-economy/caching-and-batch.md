# Caching and batch — the process-shifting wins

> The two cheapest levers, because neither costs you quality. Caching reuses a computed prefix; batch trades latency for a discount. Both are vendor-native — no extra infra, no eval gate, no router.

> **Checked 2026-05-31.** Percentages below are sticky; the *dollar* rates behind them are not — every figure links to live pricing. Vendor docs serve 403 to automated fetch, so a few model-specific minimums are flagged for re-verification against the live table before you rely on them.

## Why these come first

Routing and compression buy savings by *changing what the model sees* — so both carry a quality-regression risk and need an [eval gate](./model-routing.md#the-eval-gate). Caching and batch don't. The model runs the identical prompt; you just pay less for it. Deploy these two before you touch anything that can degrade output.

## Vendor caching matrix

Prompt caching stores the KV-computation of a prompt prefix so a later request with the **same prefix** skips recompute. You pay a reduced "cache read" rate on the hit.

| Vendor | Read discount | Write cost | TTL | Min tokens | Manual / auto |
|---|---|---|---|---|---|
| **Anthropic** | **90% off** (0.1× input)[¹] | 1.25× (5 min) / 2× (1 hr)[¹] | 5 min default, 1 hr opt[¹] | 1,024 (Sonnet) / 4,096 (Opus, Haiku 4.5)[¹] | Both — up to 4 `cache_control` breakpoints[¹] |
| **OpenAI** | **50% off** cached input[²] | none | ~5–10 min idle, ≤1 hr[²] | 1,024, then +128[²] | Automatic[²] |
| **Google Gemini** | **~90% off** (0.1× input)[³] | implicit: none / explicit: hourly storage[³] | explicit 1 hr default[³] | ~1,024 (Flash) / ~2,048 (Pro) — verify[³] | Both (implicit on by default, 2.5+)[³] |
| **DeepSeek** | **~90% off** (cache-hit 0.1× miss)[⁴] | none | disk-based, automatic[⁴] | 64-token granularity[⁴] | Automatic[⁴] |
| **xAI Grok** | ~75–84% off (per model)[⁵] | none | automatic[⁵] | — | Automatic[⁵] |
| **Mistral** | ~90% off (0.1× input)[⁶] | none | automatic[⁶] | — | Automatic[⁶] |

Read the column that matters: **Anthropic and Google bill cache hits at one-tenth of input — a 90% cut on the cached slice.** OpenAI's automatic 50% is half that but needs zero code. (xAI/Mistral percentages are aggregator-reported; treat as directional.)

## The cached-prefix pattern

Caching only pays off if your prefix is *stable and front-loaded*. Order the prompt **static → dynamic**: system instructions, then tools, then long context, then the volatile user turn last. An exact-prefix match is required — one changed byte early recomputes everything after it.

```python
# Anthropic: cache the system + tool blocks, leave the user turn uncached
import anthropic
client = anthropic.Anthropic()

resp = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system=[
        {"type": "text", "text": LONG_STATIC_INSTRUCTIONS},
        {"type": "text", "text": PROJECT_CONTEXT,
         "cache_control": {"type": "ephemeral"}},   # breakpoint: everything above is cached
    ],
    messages=[{"role": "user", "content": user_turn}],  # volatile — never in the cached prefix
)
u = resp.usage
print(u.cache_creation_input_tokens, u.cache_read_input_tokens, u.input_tokens)
```

Watch the **`cache_read_input_tokens : cache_creation_input_tokens` ratio** — a high read:write ratio means the cache is earning its keep. This is the same hygiene Claude Code applies automatically; see [Chapter 03 — cost and cache-hit accounting](../03-claude-code-as-operator/agent-rules.md#cost-and-cache-hit-accounting-q0326q0327).

## Cache-aware rate limits

Anthropic shipped a 2025 change that makes caching *more* than a cost lever: **cache-read tokens no longer count against your input-tokens-per-minute (ITPM) limit.**[⁷] A cache-heavy agent loop gets effectively higher throughput, not just a cheaper bill. Same release bundled auto-read of the longest cached prefix and token-efficient tool use.[⁷]

## Cache + extended thinking (agent loops)

In a tool-use loop, thinking blocks **can't be marked `cache_control` directly**, but they ride along in the cached request content when they appear in prior assistant turns.[¹] The trap on older models: adding non-tool-result user content **strips previous thinking blocks**, invalidating the cache for everything after. On **Opus 4.5+ / Sonnet 4.6+** thinking blocks are preserved by default and the cache stays warm across the loop.[¹] Pattern: keep tool-result turns contiguous, don't interleave fresh user content mid-loop, and stay on a model that preserves thinking.

**Token-efficient tool use** is a related free win: beta header `token-efficient-tools-2025-02-19` cut output tokens ~14% avg / up to 70% on Claude 3.7 Sonnet — and it's **built into all Claude 4 models** (don't send the header).[⁷]

## Vendor batch matrix

Batch APIs take work you don't need *now*, run it asynchronously, and hand back a **50% discount** for the wait.

| Vendor | Discount | Turnaround | Limits |
|---|---|---|---|
| **Anthropic** Message Batches | **50%** in+out[⁸] | ≤24 h (expires at 24 h)[⁸] | 100k requests / 256 MB; results kept 29 days[⁸] |
| **OpenAI** Batch | **50%** in+out, all models[⁹] | 24 h window (most 1–6 h)[⁹] | per-tier enqueued-token cap[⁹] |
| **Google** Gemini/Vertex Batch | **50%**[¹⁰] | ~24 h target[¹⁰] | per-model[¹⁰] |

The 50% is uniform across all three majors — a rare case where the vendors agree.

## When batch makes sense for a solo dev

Batch is for **anything not blocking a human keystroke**:

- **Eval runs** — golden-set regression suites (the [eval gate](./model-routing.md#the-eval-gate) itself; run it nightly at half price).
- **Bulk scoring / labeling** — classify a backlog, tag a corpus, score a dataset.
- **Overnight processing** — summarize the day's docs, generate embeddings, backfill.

**Anti-patterns:** anything user-facing or interactive. A 24 h SLA means batch is useless for a chat turn, a code-completion, or a `/gsd` step you're watching. Don't batch the critical path.

## Do caching and batch compose?

Yes, on all three majors — and this is the load-bearing fact under the [stacked pipeline](./README.md#the-stacked-pipeline):

- **OpenAI:** independent and stackable; cached input inside a batch gets both discounts.[²]
- **Anthropic:** caching works with Batches, but hits are **best-effort** (concurrent, any-order). Warm the cache with one 1-hour-TTL request first, then submit the batch.[¹]
- **Google:** Batch Mode supports implicit caching; the cached portion bills at cache rate on top of the 50%.[³]

`0.5 (batch) × 0.1 (cache read) = 0.05` — **95% off** the cached, batched slice from these two composable, no-quality-cost levers alone. Everything in [routing](./model-routing.md) and [compression](./prompt-compression.md) stacks *below* this floor.

## Self-hosted KV cache (brief)

If you run OSS models on your own GPU, prefix caching is already there: **vLLM** Automatic Prefix Caching (block-level KV reuse, on by default in recent builds), **SGLang** RadixAttention (token-level radix-tree reuse, on by default).[¹¹] **TGI** has it too but Hugging Face moved TGI to maintenance mode in late 2025 and points new deploys at vLLM/SGLang[¹¹] — don't start there. For most solo devs this is out of scope; the hosted caching above is free and zero-ops.

## Alternatives table (same-tier)

| Option | Caching | Batch | Best for |
|---|---|---|---|
| **Anthropic** | 90% read, 4 breakpoints, 1 hr TTL | 50%, 24 h | Agent loops, long cached context |
| **OpenAI** | 50% automatic, zero code | 50%, 24 h | Lowest-effort caching |
| **Google Gemini** | 90% read, implicit on by default | 50%, 24 h | Huge context, implicit hits |
| **DeepSeek** | ~90%, 64-token granularity, automatic | — | Cheapest base rate + auto cache |
| **Self-host (vLLM/SGLang)** | prefix cache on by default | n/a (you schedule) | Own-GPU, data residency |

## Related

- [Model routing](./model-routing.md) — the next layer; carries a quality cost, needs an eval gate
- [Prompt compression](./prompt-compression.md) — shrink the variable input that caching can't help
- [Cost tracking](./cost-tracking.md) — measure the read:write ratio and the batch savings
- [Chapter 03 — cost and cache-hit accounting](../03-claude-code-as-operator/agent-rules.md#cost-and-cache-hit-accounting-q0326q0327) — Claude Code's automatic caching
- [sources.md](./sources.md) — full bibliography

---

[¹]: https://platform.claude.com/docs/en/build-with-claude/prompt-caching — accessed 2026-05-31 (403 to automated fetch; figures via search index — re-verify newest model thresholds against live table)
[²]: https://platform.openai.com/docs/guides/prompt-caching ; https://openai.com/index/api-prompt-caching/ — accessed 2026-05-31
[³]: https://ai.google.dev/gemini-api/docs/caching ; https://developers.googleblog.com/gemini-2-5-models-now-support-implicit-caching/ — accessed 2026-05-31 (per-model minimums conflicting across sources — verify)
[⁴]: https://api-docs.deepseek.com/guides/kv_cache — accessed 2026-05-31
[⁵]: https://docs.x.ai/developers/advanced-api-usage/prompt-caching — accessed 2026-05-31 (percentages aggregator-reported)
[⁶]: https://docs.mistral.ai/api — accessed 2026-05-31 (caching % aggregator-reported — confirm on live docs)
[⁷]: https://www.anthropic.com/news/token-saving-updates — accessed 2026-05-31
[⁸]: https://platform.claude.com/docs/en/build-with-claude/batch-processing ; https://www.anthropic.com/news/message-batches-api — accessed 2026-05-31
[⁹]: https://platform.openai.com/docs/guides/batch ; https://help.openai.com/en/articles/9197833-batch-api-faq — accessed 2026-05-31
[¹⁰]: https://ai.google.dev/gemini-api/docs/batch-api — accessed 2026-05-31
[¹¹]: https://docs.vllm.ai/en/stable/design/prefix_caching/ ; https://lmsys.org/blog/2024-01-17-sglang/ — accessed 2026-05-31
