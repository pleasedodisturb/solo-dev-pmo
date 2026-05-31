# Model routing — tier the workload, not the model

> Most requests don't need your most expensive model. Routing sends each task to the cheapest model that can do it. The savings are real (60–95%) and the risk is real: a router that sends hard work to a weak model botches it silently. **Every routing decision needs an eval gate.**

> **Checked 2026-05-31.** Two of the named tools moved since the canonical surveys were written: **RouteLLM has had no commit since Aug 2024**, and the **NotDiamond Python SDK was archived Dec 2025** (the hosted service lives on). Flagged inline — don't adopt either as live software without checking its state.

## Tier the workload

The durable pattern — endorsed by Anthropic's own model guidance[¹] — is three tiers mapped to task *complexity*, not to a fixed model name:

| Tier | Task type | Model class | Why |
|---|---|---|---|
| **Cheap** | Classification, extraction, formatting, routing, simple summaries | Haiku-class | High-volume, latency-sensitive, low-ambiguity[¹] |
| **Mid** | Generation, synthesis, everyday coding, analysis | Sonnet-class | The default daily driver — start here if unsure[¹] |
| **Frontier** | Multi-step reasoning, long-horizon agentic work, hard debugging | Opus / o-series / Gemini Pro | Genuinely needs deep thinking; costs the most per token[¹] |

Model version numbers churn (Haiku 4.5, Sonnet 4.6, Opus 4.8…); the **tier mapping is the asset**, not the version string. Route by what the task *is*, and re-pin the model names each quarter.

## The tools

| Tool | Type | Cost model | Training data | Status 2026 | Solo-dev fit |
|---|---|---|---|---|---|
| **Hand-rolled** | `if task_type → model` | free | none | yours | **Start here** |
| **RouteLLM** | preference-trained router | OSS | Chatbot Arena prefs | **stale** (Aug 2024)[²] | Research artifact, not live SW |
| **LiteLLM** | gateway + load-balance | OSS | none | active (v1.86, May 2026)[³] | SDK yes, proxy = overkill |
| **NotDiamond** | per-query meta-router | commercial API | hosted/custom | SDK **archived** Dec 2025[⁴] | Service via OpenRouter only |
| **OpenRouter** | aggregator + auto-route | ~5.5% credit fee[⁵] | n/a (Auto = NotDiamond)[⁵] | active | One key, many models |

### RouteLLM

A framework that routes each query between a strong and a weak model using a preference-trained classifier (matrix-factorization default, plus BERT / causal-LLM variants).[²] The headline claim from the paper (arXiv 2406.18665): **"cost reductions of over 85% on MT Bench, 45% on MMLU, and 35% on GSM8K compared to using only GPT-4, while still achieving 95% of GPT-4's performance."**[⁶] That is the canonical evidence that routing can cut cost ~85% at ~95% quality — but **the repo's last commit is August 2024 with no tagged release.**[²] Cite the result; treat the code as a reference implementation, not maintained software.

### LiteLLM

A unified gateway/SDK across 100+ providers in OpenAI format, actively maintained.[³] Its router does **deployment load-balancing** — `latency-based`, `usage-based`, `cost-based`, `least-busy`, plus fallbacks[³] — which is *which copy of a model*, distinct from task-complexity tiering. The **SDK** (one `completion()` call + fallbacks + per-call cost logging) is the right amount of LiteLLM for a solo dev. The **proxy server** — DB-backed spend tables, per-key/team/org budgets — is built for multi-team cost attribution and is overkill solo. See [cost-tracking](./cost-tracking.md#when-to-upgrade).

### NotDiamond / OpenRouter

NotDiamond picks the best model per prompt via a hosted meta-router; the **Python SDK was archived Dec 2025**[⁴] but the service still runs — it powers **OpenRouter's `openrouter/auto`** router.[⁵] OpenRouter itself is a clean way to reach many models behind one key with **no markup on inference** (fees are ~5.5% on credit purchase, percentages per the brief; see live [pricing](https://openrouter.ai/pricing)).[⁵] Trade-offs vs going direct: an extra network hop and a meta-model step add latency; one bill simplifies billing; **non-deterministic model selection complicates your eval baseline**; and prompts transit a third party (default no-retention, but a residency consideration).[⁵]

## The hand-rolled router (when 50 lines is enough)

A static dispatch is sufficient when (a) tasks separate cleanly by type at ingest, (b) cost isn't yet your dominant line item, and (c) you have no preference/eval data to train on.

```python
# 50-line tier router. No training, no service, fully inspectable.
TIER = {
    "classify":  "claude-haiku-4-5",
    "extract":   "claude-haiku-4-5",
    "format":    "claude-haiku-4-5",
    "generate":  "claude-sonnet-4-6",
    "synthesize":"claude-sonnet-4-6",
    "reason":    "claude-opus-4-8",
    "debug":     "claude-opus-4-8",
}
def route(task_type: str) -> str:
    return TIER.get(task_type, "claude-sonnet-4-6")  # safe default = mid tier
```

Graduate to a trained router (RouteLLM-class) only when difficulty is **mixed within a route** — so static dispatch over- or under-provisions — *and* you have labeled data *and* the savings justify the eval+maintenance overhead. Even then, a kNN/similarity baseline may match the learned router (arXiv 2505.12601, "When Simple kNN Beats Complex Learned Routers")[⁷] — so prove the complex router beats the cheap one on *your* data before shipping it. The progression that practitioners converge on: **direct calls → gateway for visibility → routing for cost**, added only once cost is a real budget line.[⁸]

## The eval gate

Routing's whole premise is "a cheaper model is good enough *here*." The failure mode is silent: the router sends a hard task to the weak model and the weak model produces confident garbage. **No routing change ships without passing a golden-set regression.** The minimum:

1. **Per-route golden set** — a handful (10–50) of representative inputs per route, with gold outputs where they exist.
2. **A baseline** — the frontier model's output on the same set.
3. **An LLM-as-judge** scoring each candidate output against the baseline/rubric.[⁹]
4. **A tripwire** — the config fails if the cheap model's judge score drops below the baseline by more than a set margin on *any* route.
5. **Gate on cost + latency too**, not just quality — a routing change can regress all three.[¹⁰]

```bash
# promptfoo: assert the routed (cheap) output stays within quality margin of frontier
npx promptfoo eval -c routing-eval.yaml   # model-graded; run nightly via Batch API (50% off)
```

Run it on the [Batch API](./caching-and-batch.md#vendor-batch-matrix) overnight for half price — the eval suite is itself the textbook batch workload. For narrow semantic-equivalence checks, an embedding-similarity or classifier judge is cheaper and more stable than a full LLM judge.[⁹] This gate is also where [Chapter 08 — agent safety](../08-agent-safety/) patterns catch a routing regression before it reaches a user.

## Alternatives table (same-tier)

| Option | Savings | Quality risk | Eval burden | When |
|---|---|---|---|---|
| **Hand-rolled dispatch** | depends on mix | low (you control it) | per-route golden set | Default; cleanly typed tasks |
| **RouteLLM** | up to ~85%[⁶] | medium (learned) | preference data + golden set | Mixed difficulty within a route; have data |
| **LiteLLM** (SDK) | provider arbitrage + fallback | low | golden set | Multi-provider, want one interface |
| **NotDiamond** (via OpenRouter) | per-query optimal | medium | non-deterministic baseline | Don't want to build/train a router |
| **OpenRouter** | no inference markup | low | non-deterministic if Auto | Many models, one key/bill |

## Related

- [Caching and batch](./caching-and-batch.md) — deploy these first; no quality cost, no eval gate
- [Prompt compression](./prompt-compression.md) — the other quality-cost lever; same eval-gate rule
- [Cost tracking](./cost-tracking.md) — attribute spend per route to know if routing is worth it
- [Chapter 03 — token-budget tiers](../03-claude-code-as-operator/agent-rules.md#token-budget-rules) — the same S/M/L tiering inside Claude Code
- [Chapter 08 — agent safety](../08-agent-safety/) — eval gates catch routing regressions
- [sources.md](./sources.md) — full bibliography

---

[¹]: https://platform.claude.com/docs/en/about-claude/models/overview ; https://claude.com/resources/tutorials/choosing-the-right-claude-model — accessed 2026-05-31
[²]: https://github.com/lm-sys/RouteLLM ; https://github.com/lm-sys/RouteLLM/commits/main — accessed 2026-05-31 (last commit Aug 2024, no releases — stale)
[³]: https://github.com/BerriAI/litellm ; https://docs.litellm.ai/docs/routing — accessed 2026-05-31 (v1.86.2, May 2026)
[⁴]: https://github.com/Not-Diamond/notdiamond-python — accessed 2026-05-31 (archived read-only Dec 2025)
[⁵]: https://openrouter.ai/docs ; https://openrouter.ai/pricing ; https://openrouter.ai/openrouter/auto — accessed 2026-05-31
[⁶]: https://arxiv.org/abs/2406.18665 — "RouteLLM: Learning to Route LLMs with Preference Data", Ong et al. — accessed 2026-05-31
[⁷]: https://arxiv.org/abs/2505.12601 — "Rethinking Predictive Modeling for LLM Routing" — accessed 2026-05-31
[⁸]: https://atlan.com/know/llm/model-router-vs-model-gateway/ — accessed 2026-05-31
[⁹]: https://www.promptfoo.dev/docs/guides/llm-as-a-judge/ ; https://www.evidentlyai.com/llm-guide/llm-as-a-judge — accessed 2026-05-31
[¹⁰]: https://www.traceloop.com/blog/automated-prompt-regression-testing-with-llm-as-a-judge-and-ci-cd — accessed 2026-05-31
