# 09 — Token economy

> Running agents heavily is the single most expensive line item in this whole stack. This chapter is the cost-optimization layer: caching, batch, routing, compression, accounting — and an honest accounting of what stacking them actually buys.

The patterns are vendor-agnostic; examples use Anthropic / OpenAI / Google / DeepSeek because that's where the prices are published. The framing — and the canonical cross-tool catalog — is `pleasedodisturb/awesome-llm-token-optimization`, cited here as same-tier prior art; this chapter summarizes the **load-bearing** patterns and points there for the full 14-section survey.

> **Checked 2026-05-31.** Every figure is a **percentage** (sticky) linked to live pricing, not a dollar amount (stale in a quarter). Vendor doc pages 403 to automated fetch; model-specific minimums are flagged for re-verification where that mattered.

## What this chapter covers

| Section | What it solves |
|---|---|
| [Caching and batch](./caching-and-batch.md) | The two no-quality-cost levers. 90% off cached reads, 50% off async batch. |
| [Model routing](./model-routing.md) | Tier the workload — cheap model for cheap tasks. 60–95% off, *with* an eval gate. |
| [Prompt compression](./prompt-compression.md) | Shrink the variable input. LLMLingua, context discipline, auto-compaction. |
| [Cost tracking](./cost-tracking.md) | Measure it. Minimum-viable accounting → when to add a real stack. |

## The stacked pipeline

The headline framing, from the canonical survey:[¹]

> *Cache prefix (90%) + route to cheapest model (60–95%) + batch non-urgent (50%) + compress prompts (5–20×) + cache responses (100% on repeats) = 95–99% cost reduction vs. naive.*

**That 95–99% is a real envelope — but it is not a single request's discount.** Each lever applies to a different slice, so re-derive it honestly:

- **Caching × batch genuinely compose** and multiply: `0.5 (batch) × 0.1 (cache read) = 0.05` → **95% off** the cached, batched slice. Both vendor-native, both zero-quality-cost. ([proof](./caching-and-batch.md#do-caching-and-batch-compose))
- **Routing** drops the *per-token rate* underneath that by 60–95% when a cheaper model suffices — but only on tasks that route down, and only behind an [eval gate](./model-routing.md#the-eval-gate).
- **Compression** shrinks the *token count* of the variable input 2–5× in practice (the 20× is a benchmark ceiling, not a default), again behind a quality gate.
- **Response cache** is the 100%: an identical repeated request costs nothing because you never call the API.

So 95–99% is reachable **only for a workload that is repetitive (cache hits), non-urgent (batch), tier-able (routing), and verbose (compression headroom)** — and only after you've gated the two lossy levers. Most solo setups deploy one or two and bank the single-tactic savings below. If your traffic is unique, urgent, and already terse, your realistic ceiling is closer to 50%. The honest claim is: *the math holds; the prerequisites rarely all do at once.*

## Single-tactic baselines (deploy in this order)

| Tactic | Realistic saving alone | Quality cost | Effort |
|---|---|---|---|
| **Prompt caching** | ~88–90% on the cached slice | none | low — order prompt static→dynamic |
| **Batch** | 50% on non-urgent work | none | low — async submit |
| **Model routing** | 60–95% on tasks that route down | **yes** — needs eval gate | medium |
| **Compression** | ~50% typical (2× input) | **yes** — needs eval gate | medium |
| **Response cache** | 100% on exact repeats | none | low — hash + KV store |

Order matters: **caching and batch first** (free savings, no risk), routing and compression second (real savings, real quality risk, real eval cost).

## What the platform already does for you

Don't re-implement what your agent host already optimizes. **Claude Code caches automatically** with a stable system→memory→conversation prefix, exposes `/usage` cost attribution, and auto-compacts context — covered in [Chapter 03 — cost and cache-hit accounting](../03-claude-code-as-operator/agent-rules.md#cost-and-cache-hit-accounting-q0326q0327), not duplicated here. This chapter is the layer **below** that: the API-level economics when you call models directly, build pipelines, or run anything outside a managed session.

## The ADHD cut — what this removes from working memory

Cost anxiety is a background tax: *"am I burning money right now?"* This chapter replaces that vigilance with **two defaults and one number**. Default 1: order every prompt static→dynamic so caching just happens. Default 2: batch anything you're not watching. The one number: a cache read:write ratio in your statusline. Set those once and stop thinking about cost until the [monthly review](./cost-tracking.md) — the discipline lives in the config, not your head.

## Related

- [Chapter 03 — Claude Code as operator](../03-claude-code-as-operator/agent-rules.md) — in-session cost/cache mechanics (not duplicated here)
- [Chapter 08 — Agent safety](../08-agent-safety/) — eval gates that catch routing/compression regressions
- [Chapter 00 — Single source of truth](../00-principles/) — why vendor lock-in is a separate concern from cost
- [sources.md](./sources.md) — full bibliography

---

[¹]: https://github.com/pleasedodisturb/awesome-llm-token-optimization — "Quick Wins" / Combined pipeline section — accessed 2026-05-31
