# Alternatives: which patterns survive on which tool

> The playbook uses Linear, but the patterns are the point. This file is the honest "what's blocked where" matrix so you can adopt the chapter on Plane, Shortcut, Jira, Trello, or GitHub Projects without pretending the mapping is free.

**Checked against vendor docs on 2026-05-31.** Tool features move fast; re-verify the cells that matter to you before committing. Where a vendor doc was silent we wrote "not documented" (absence of evidence) rather than "no" (positive evidence of absence) — the distinction is preserved below.

## The six load-bearing patterns

Every cell answers: *can this tool support the playbook pattern natively?*

| Pattern | **Linear** | **Plane** | **Shortcut** | **Jira** | **Trello** | **GitHub Projects** |
|---|---|---|---|---|---|---|
| Cycles + **auto-roll** | Yes, always-on[¹] | Yes (auto-roll *toggle*)[²] | Iterations + auto-move automation[³] | Sprints, *prompted* at close[⁴] | No native (Power-Up)[⁵] | Iteration field, *manual* move[⁶] |
| **Triage** intake state | Yes[⁷] | Yes (Intake/Triage)[⁸] | No (convention) | No (custom workflow) | No native | No (convention) |
| **Snooze** until date | Yes[⁷] | Not documented | Not documented | No — declined feature[⁹] | No native | No |
| **Estimates** | Fib/Exp/t-shirt/custom[¹⁰] | Points (Fib/t-shirt/custom)/categories/time[¹¹] | Points (Fib, editable)[¹²] | Points(Fib)/hours/custom[¹³] | Power-Up only[¹⁴] | Number/Issue fields (preview)[¹⁵] |
| **Project updates** + health + reminder | Yes (health+reminder+nudge)[¹⁶] | Yes (health + automated reminder)[¹⁷] | Partial (OKR health, no reminder)[¹⁸] | No native (separate Atlas product)[¹³] | No native | Partial (health, no reminder)[¹⁹] |
| **API / CLI / MCP** | GraphQL + webhooks + official MCP[²⁰] | REST + webhooks + official MCP[²¹] | REST + webhooks + official MCP[²²] | REST + GraphQL + Rovo MCP[²³] | REST + webhooks, no MCP[²⁴] | GraphQL + `gh` CLI + official MCP[²⁵] |

## What each tool blocks or simplifies

- **Plane** — the closest substitute, and the only open-source/self-hostable one. Matches cycles+auto-roll, a real Intake/Triage state, the *richest* estimate options, and project updates with health + automated reminders. **Blocks:** snooze (no documented per-issue hibernate-until-date — the biggest functional gap), and the AI-triage depth (Linear's Triage Intelligence / Agent). Auto-roll is opt-in rather than always-on (minor).
- **Shortcut** — Iterations + the *Auto-Move Stories* automation approximate auto-roll (depends on non-overlapping iterations). **Blocks:** a first-class Triage inbox, snooze, and a reminder-driven weekly update cadence (health lives on Objectives/Key Results, not a nudged weekly post).
- **Jira** — flexible estimates (points *and* hours) and a mature API. **Blocks:** native Triage (build a workflow status), snooze (an explicitly *declined* feature request[⁹]), and native weekly health updates (that's Atlassian's separate Atlas product, not Jira Software). Heaviest config burden.
- **Trello** — nothing on this list is native. Sprints, triage, snooze, estimates, and status updates all require Power-Ups or convention. Fine as a board, wrong as a load-bearing PM layer for this playbook.
- **GitHub Projects** — strong for agents (`gh` CLI + GraphQL + official MCP) and gaining ground: native status updates with health (Inactive/On track/At risk/Off track/Complete) and Issue fields in public preview (2026-05-21). **Blocks:** auto-roll (manual bulk-move between iterations), a Triage state, snooze, and *scheduled* update reminders (`gh project` still can't even create status updates[¹⁹]). If you already live in GitHub, fake Triage with a Status option and snooze with labels + a scheduled query.

For tools without snooze or auto-roll, the [I/O rules](./io-rules.md) "Mapping for other tools" table shows the label-plus-script simulation.

## Q01.11 — Does any tool match Linear's full set?

**No.** Across all six patterns, **Plane is the only tool that comes close** — it natively covers five of six, missing only snooze. Shortcut and GitHub Projects match ~4/6 but lack a true Triage inbox, snooze, and (Shortcut) reminder-driven updates. Jira and Trello trail further. So the chapter's "Why Linear specifically?" framing holds in 2026 — but it is now **"Linear or Plane,"** not "Linear alone." If snooze-as-hibernation is load-bearing for you, that single feature is currently the strongest Linear-specific argument.

## Q01.12 — Is Plane a viable substitute?

**Yes — the most viable in this set, and the answer if self-hosting or open-source matters.** Plane ships as **Plane Cloud** (free tier) and **self-hosted** (Docker/Kubernetes), in Community / Commercial / Airgapped editions. **License: Community Edition is AGPL-3.0; the MCP server is MIT.**[²⁶]

What Plane **misses vs Linear:**
- **Snooze** — no documented per-issue hibernate-until-date. The biggest gap; the whole [snooze-as-hibernation](./snooze-as-hibernation.md) pattern needs a label+script workaround.
- **Always-on auto-roll** — Plane's is an opt-in toggle (functionally equivalent once enabled).
- **AI triage maturity** — Linear's Triage Intelligence, Triage Rules, Triage Responsibility (PagerDuty/Opsgenie rotation), and multi-step reminder nudges are deeper than Plane's Intake + Workflow automations.

What Plane **matches or exceeds:** cycles + burndown, a real Intake/Triage state, the richest estimate options of any tool here, project updates with health + automated reminders, an official MCP server (55+ tools), REST API + webhooks, and an open-source/self-host story Linear has no answer to.

## Status checks that change a 2026 tool choice

- **Height — SHUT DOWN.** After pivoting to "Height 2.0 / autonomous PM" (Oct 2024), Height announced shutdown in March 2025; **final day of service was 2025-09-24.**[²⁷] The original chapter listed Height as a transfer target — **do not pick it for a new build.** (Flagged to the author; chapter references updated.)
- **Shortcut — independent and operating** (no acquisition; launched an AI tool "Korey" Sept 2025).[²²]
- **Jira / Trello — Atlassian-owned**, both now reachable via Atlassian **Rovo MCP** (Trello is *not* in Rovo MCP scope). API rate-limit enforcement tightens from **2026-03-02**.[²³]
- **GitHub Projects — actively expanding** (native status updates 2024; Issue fields preview May 2026; official MCP server).[²⁵]

## ADHD-aware note

What does picking the *right* tool remove from working memory? The difference between Linear/Plane and the others is whether the affordances (auto-roll, snooze, triage inbox, nudged updates) are *the tool's job* or *yours*. On Trello/Jira/GitHub you rebuild them with scripts and discipline — which is exactly the working-memory tax this playbook exists to avoid. Pick a tool whose defaults are the affordances.

## Sources

External vendor claims gathered via web search on 2026-05-31 (vendor domains block automated full-page fetch); Linear claims verified via Linear's documentation-search MCP. Full bibliography + verification caveat in [`sources.md`](./sources.md).

- [1]: https://linear.app/docs/use-cycles — [2]: https://docs.plane.so/core-concepts/cycles , https://plane.so/changelog/release-v-1-16-0-introducing-milestones-and-recurring-cycles — [3]: https://help.shortcut.com/hc/en-us/articles/17472009334932-Automations , https://www.shortcut.com/product/sprints — [4]: https://www.atlassian.com/agile/project-management/fibonacci-story-points — [5]: https://placker.com/agile-practices-with-trello.html — [6]: https://docs.github.com/en/issues/planning-and-tracking-with-projects/understanding-fields/about-iteration-fields , https://github.com/orgs/community/discussions/16222
- [7]: https://linear.app/docs/triage — [8]: https://docs.plane.so/intake/overview — [9]: https://jira.atlassian.com/browse/JSDCLOUD-12377 — [10]: https://linear.app/docs/estimates — [11]: https://docs.plane.so/core-concepts/issues/estimates — [12]: https://help.shortcut.com/hc/en-us/articles/25819408141844-Estimating-Work-Overview — [13]: https://www.atlassian.com/agile/project-management/fibonacci-story-points — [14]: https://developer.atlassian.com/cloud/trello/guides/power-ups/building-a-power-up-part-two/
- [15]: https://github.blog/changelog/2026-05-21-issue-fields-are-now-in-public-preview-for-all-organizations/ — [16]: https://linear.app/docs/initiative-and-project-updates — [17]: https://docs.plane.so/communication-and-collaboration/project-updates — [18]: https://help.shortcut.com/hc/en-us/articles/23291814285716-The-Objectives-Page — [19]: https://docs.github.com/en/issues/planning-and-tracking-with-projects/sharing-project-updates , https://github.com/cli/cli/issues/9743 — [20]: https://linear.app/docs/api-and-webhooks , https://linear.app/docs/mcp
- [21]: https://developers.plane.so/api-reference/introduction , https://github.com/makeplane/plane-mcp-server — [22]: https://developer.shortcut.com/api/rest/v3 , https://help.shortcut.com/hc/en-us/articles/36443434285844-MCP-Server , https://www.shortcut.com/about — [23]: https://github.com/atlassian/atlassian-mcp-server , https://www.atlassian.com/blog/platform/evolving-api-rate-limits — [24]: https://developer.atlassian.com/cloud/trello/guides/rest-api/api-introduction/ — [25]: https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-api-to-manage-projects , https://cli.github.com/manual/gh_project , https://github.com/github/github-mcp-server — [26]: https://github.com/makeplane/plane , https://developers.plane.so/self-hosting/editions-and-versions — [27]: https://www.creativerly.com/height-app-is-shutting-down/ , https://alternativeto.net/news/2025/3/height-project-management-tool-to-shut-down-by-september-2025/

## Related

- [README — Why Linear specifically? (revisited 2026)](./README.md)
- [I/O rules — Mapping for other tools](./io-rules.md)
- [Snooze as hibernation](./snooze-as-hibernation.md) — the pattern most tools can't match
