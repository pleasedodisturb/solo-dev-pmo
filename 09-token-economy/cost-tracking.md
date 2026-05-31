# Cost tracking and budgets

> You can't optimize what you don't measure — but a solo dev does not need an observability stack to measure it. Start with a free local tool and a monthly glance. Add a proxy only when you have a reason. And know the one gotcha that bites everyone: **most vendors no longer give you a hard spend cutoff.**

> **Checked 2026-05-31.** Plan/tier *dollar* prices go stale fast and are linked to live pricing, not quoted. The empirical per-day figures are Anthropic's own published numbers, dated and attributed.

## Minimum viable (start here)

For a solo dev whose spend is mostly **Claude Code**, the whole stack is two free tools, zero infra:

1. **`ccusage`** — parses your local Claude Code / Codex JSONL logs (`~/.claude/`). No API key, no network, works offline, MIT.[¹] It reads `costUSD` plus per-message input / output / `cache_creation` / `cache_read` tokens.

   ```bash
   npx ccusage@latest daily              # cost per day
   npx ccusage@latest monthly            # roll-up
   npx ccusage@latest session            # per-conversation (≈ per-project)
   npx ccusage@latest daily --breakdown  # split by model
   ```

2. **`/usage`** in Claude Code — live session tokens + a local dollar estimate, and on paid plans **attributes spend to skills, subagents, plugins, and MCP servers as percentages.**[²] This is covered in [Chapter 03 — cost and cache-hit accounting](../03-claude-code-as-operator/agent-rules.md#cost-and-cache-hit-accounting-q0326q0327); not duplicated here.

That plus a **monthly look at the vendor Console** is sufficient for most solo setups. Don't build more until one of the triggers below fires.

## Vendor dashboards (free) vs the Admin APIs (org-tier)

The free **Console pages** give you the numbers; the **programmatic APIs are mostly org-scoped overkill** for one person:

| Vendor | Free Console | Programmatic | Solo note |
|---|---|---|---|
| **Anthropic** | Usage + Cost pages, CSV export | Admin API (`/cost_report`, `/usage_report/messages`) — **requires an organization; unavailable to individual accounts**[³] | Console + ccusage is simpler |
| **OpenAI** | Usage dashboard, export ≤60 days | `/v1/organization/usage`, `/costs` — Admin key[⁴] | Export button covers it |
| **Google Cloud** | Cloud Billing reports | BigQuery billing export | No native per-request LLM view |

If you call the **API directly** (not through Claude Code), capture `usage` off every response yourself — input, output, and the two cache counters — and append to a CSV. A `tail -f` and a spreadsheet genuinely suffice at solo scale; that is the honest baseline this chapter recommends over any hosted tool.

## When to upgrade

Add real tooling only when a trigger fires — not preemptively:

| Tool | License / free tier | Add it when |
|---|---|---|
| **LiteLLM proxy** | OSS | You route **multiple providers** and need one spend view **or a hard cutoff** (see gotcha below) or disposable per-project keys[⁵] |
| **Langfuse** | MIT core; Cloud Hobby free (50k units/mo)[⁶] | You're building an **app** (not just using Claude Code) and want tracing + cost per trace |
| **Helicone** | Apache-2.0; free 10k req/mo[⁷] | You want one-line proxy observability for an app; watch the request + retention caps |
| **OpenMeter** | — | **Never, for tracking your own spend.** It's for *reselling* usage-based products[⁸] |
| **OTEL export** | built-in | You already run Grafana/Prometheus and want org-wide rollups[²] |

The LiteLLM proxy means standing up Postgres + a server; Langfuse self-host wants PostgreSQL + ClickHouse + Redis + S3.[⁶] For one developer on one provider that is **overkill** — the SDK and ccusage capture the value without the ops.

## The gotcha: budgets are alerts, not stops

The single most important fact in this file. **Most vendors removed hard spend caps.** A "budget" emails you; it does not stop the bill.

- **OpenAI** — hard budget caps were **removed**; the monthly budget is **notification-only** (email + dashboard alert; the API keeps serving, billing continues).[⁹] Per-key alerts at 80% / 95% are available, but there is **no automatic cutoff**.
- **Google Cloud** — Budgets & alerts fire at thresholds (50/80/100%); **no native hard cap.** The DIY killswitch is a **Pub/Sub topic → Cloud Function that disables billing.**[¹⁰]
- **Anthropic** — Workspace **Spend limits** *do* cap monthly workspace spend (can't be set on the Default Workspace, can't exceed the org limit), plus spend notifications; the Claude Code workspace uniquely supports per-user monthly limits.[³] On Pro/Max, cap usage credits in-CLI.

**If you need a true hard stop, front everything with a LiteLLM proxy** — `max_budget` rejects requests once spend ≥ cap, with `budget_duration` resets and concurrent windows (e.g. `$10/day AND $100/month` on one key).[⁵] That hard-cutoff need is the most common legitimate reason a solo dev stands up the proxy.

## Per-project / per-skill attribution without a full stack

- **Separate API key per project** → filter by `api_key_id` in the Usage/Cost API (Anthropic warns many-key breakdowns have perf limits).[³]
- **`ccusage session`** grouped per project directory — zero infra.[¹]
- **OTEL labels** — `OTEL_RESOURCE_ATTRIBUTES` custom tags plus built-in `skill.name` / `plugin.name` / `agent.name` / `mcp_server.name` attributes give skill/subagent/MCP-level splits.[²]
- **Anthropic workspaces** — one per project, then `group_by=workspace_id` in the Cost API.[³]

## What an agent run actually costs (published numbers)

The empirical anchors, so you can sanity-check your own bill:

- **Anthropic's published Claude Code figure:** *"around **$13 per developer per active day** and **$150–250 per developer per month**, with costs remaining **below $30 per active day for 90% of users**"* (accessed 2026-05-31).[²] Idle background token use is *"typically under $0.04 per session."*[²]
- **Simon Willison** (named practitioner), heavy use ≈ the equivalent of **$15–20/day** in API token terms via ccusage.[¹¹]
- **Multi-agent multiplies tokens, not linearly:** Anthropic measured agents using *"about **15× more tokens** than chats"*, and on their eval **token usage alone explained 80% of performance variance.**[¹²] Claude Code **Agent teams use ~7× the tokens** of a standard session (each teammate keeps its own context window).[²] This is why a single long autonomous run can spike a day's cost — see [Chapter 03 — subagent economics](../03-claude-code-as-operator/agent-rules.md#subagent-economics-q0325).

These are why caching and batch come first: at 7–15× token multipliers on agent work, a 90% cache discount on the repeated prefix is the difference between a $13 day and a $100 day.

## Plan vs API — the solo-dev call

For anyone using Claude Code **daily**, a **Max subscription beats pay-as-you-go API**, often dramatically. Practitioner break-even lands around **45–50 Sonnet interactions/day**, or as few as **10–15 Opus interactions/day**, to clear the Max-20× price; one published case reported **~93% savings** (≈$15k API-equivalent vs ~$800 on Max over 8 months).[¹³] API only wins for **sporadic** users or when you're **building a product** on the API. (Live plan prices: [claude.com/pricing](https://claude.com/pricing) — not quoted here, they move.) The `/usage` dollar figure "isn't relevant for billing" for subscribers anyway.[²]

## Related

- [Chapter 03 — cost and cache-hit accounting](../03-claude-code-as-operator/agent-rules.md#cost-and-cache-hit-accounting-q0326q0327) — `/usage`, OTEL, ccusage inside Claude Code (the in-session view)
- [Caching and batch](./caching-and-batch.md) — the levers this file measures the impact of
- [Model routing](./model-routing.md) — attribute spend per route to know if routing earns its eval cost
- [sources.md](./sources.md) — full bibliography

---

[¹]: https://github.com/ryoppippi/ccusage ; https://ccusage.com/guide/cost-modes — accessed 2026-05-31
[²]: https://code.claude.com/docs/en/costs ; https://code.claude.com/docs/en/monitoring-usage — accessed 2026-05-31
[³]: https://platform.claude.com/docs/en/manage-claude/usage-cost-api ; https://platform.claude.com/docs/en/build-with-claude/workspaces — accessed 2026-05-31
[⁴]: https://platform.openai.com/docs/api-reference/usage ; https://developers.openai.com/cookbook/examples/completions_usage_api — accessed 2026-05-31
[⁵]: https://docs.litellm.ai/docs/proxy/virtual_keys ; https://docs.litellm.ai/docs/proxy/users — accessed 2026-05-31
[⁶]: https://langfuse.com/pricing ; https://github.com/langfuse/langfuse — accessed 2026-05-31
[⁷]: https://github.com/helicone/helicone ; https://www.helicone.ai/pricing — accessed 2026-05-31 (free-tier retention cap conflicting across sources — verify live)
[⁸]: https://github.com/openmeterio/openmeter ; https://openmeter.io/use-cases/ai — accessed 2026-05-31
[⁹]: https://platform.openai.com/settings/organization/limits — accessed 2026-05-31 (hard caps removed; budget is notification-only)
[¹⁰]: https://cloud.google.com/billing/docs/how-to/budgets ; https://cloud.google.com/billing/docs/how-to/disable-billing-with-notifications — accessed 2026-05-31
[¹¹]: https://simonwillison.net/2025/Jul/14/ccusage/ — accessed 2026-05-31 (via search extraction)
[¹²]: https://www.anthropic.com/engineering/multi-agent-research-system — accessed 2026-05-31
[¹³]: practitioner aggregates (relayplane.com, findskill.ai, nxcode.io) — accessed 2026-05-31 (secondary, stale-prone; directional only)
