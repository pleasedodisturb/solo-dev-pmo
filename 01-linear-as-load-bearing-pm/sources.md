# Sources — Chapter 01

Bibliography for the Linear chapter, rolled up from the per-file footnotes. All accessed **2026-05-31** (M1 grounded-research pass, phase P01).

> **Verification caveat (read before reusing quotes).** Linear's primary docs were verified through Linear's official documentation-search MCP. **All other source domains blocked automated full-page fetch (HTTP 403)** during research, so external quotes were gathered from web-search extractions, not full-page reads. Widely-attested quotes (the GTD aphorism, Holub's #NoEstimates line, Jeffries' "a little sorry," the Shape Up cool-down rationale) are cross-confirmed across multiple sources and safe; anything else is presented as an *attribution of a documented position* rather than a guaranteed-verbatim quote. Before printing any ≤25-word quotation verbatim, spot-check it against the live page (or the print book for McConnell/Cohn/Anderson). Several claims carry explicit `[2026: verify]` markers in-text where the underlying behavior should be confirmed against a live workspace.

## Source classes (per SEARCH-PLAYBOOK weighting)

Primary docs ★★★★★ · vendor blog ★★★★ · academic ★★★★ · practitioner ★★★ · adjacent repo ★★★ · community ★★ · AI-generated ★

---

## Linear primary docs (★★★★★ — verified via docs MCP 2026-05-31)

- *Cycles* — https://linear.app/docs/use-cycles
- *Estimates* — https://linear.app/docs/estimates
- *Triage* — https://linear.app/docs/triage
- *Triage Intelligence* — https://linear.app/docs/triage-intelligence
- *Linear Agent* — https://linear.app/docs/linear-agent
- *Initiative and Project updates* — https://linear.app/docs/initiative-and-project-updates
- *Inbox* — https://linear.app/docs/inbox
- *Issue status / workflows* — https://linear.app/docs/configuring-workflows
- *Project status* — https://linear.app/docs/project-status
- *API & Webhooks* — https://linear.app/docs/api-and-webhooks
- *MCP server* — https://linear.app/docs/mcp
- *Security & Access* (scoped API keys) — https://linear.app/docs/security-and-access
- *Billing and plans* / *Teams* / *Members and roles* (free-tier limits) — https://linear.app/docs/billing-and-plans · https://linear.app/docs/teams · https://linear.app/docs/members-roles
- *Customer Requests* (GraphQL-only / no REST) — https://linear.app/docs/customer-requests
- *Linear for Startups* — https://linear.app/startups

## Linear vendor blog / method (★★★★)

- *How we built Project Updates* — https://linear.app/now/how-we-built-project-updates
- *Linear Method* — https://linear.app/method/introduction · https://linear.app/method/building-with-momentum

## Estimation literature (Q01.6–9)

- McConnell, *Software Estimation: Demystifying the Black Art* (2006) — https://www.oreilly.com/library/view/software-estimation-demystifying/0735605351/ — primary/book ★★★★★
- Cohn, *Why the Fibonacci Sequence Works* — https://www.mountaingoatsoftware.com/blog/why-the-fibonacci-sequence-works-well-for-estimating — practitioner ★★★
- Cohn, *Estimating with Story Points* — https://www.mountaingoatsoftware.com/agile/agile-estimation-estimating-with-story-points — practitioner ★★★
- Cohn, *SPIDR (splitting stories)* — https://www.mountaingoatsoftware.com/blog/five-simple-but-powerful-ways-to-split-user-stories — practitioner ★★★
- Jeffries, *Story Points Revisited* — https://ronjeffries.com/articles/019-01ff/story-points/Index.html — practitioner ★★★
- Holub, *#NoEstimates: An Introduction* — https://holub.com/noestimates-an-introduction/ — practitioner ★★★
- Fowler, *Purpose Of Estimation* / *Xp Velocity* — https://martinfowler.com/bliki/PurposeOfEstimation.html · https://martinfowler.com/bliki/XpVelocity.html — practitioner ★★★
- ZenHub, *Story Point Estimation* (doubling scale) — https://blog.zenhub.com/how-to-estimate-software-development-projects-with-story-points/ — vendor blog ★★★★
- Atlassian, *Decomposing user stories* ("20+ = red flag") — https://www.atlassian.com/blog/jira/break-decomposing-user-stories-jira — vendor ★★★★
- Scaled Agile, *Right-Sizing Features* — https://framework.scaledagile.com/right-sizing-features-for-safe-program-increments/ — vendor ★★★
- Forsgren et al., *The SPACE of Developer Productivity*, ACM Queue 2021 — https://queue.acm.org/detail.cfm?id=3454124 — academic ★★★★
- DORA, *Four Keys* — https://dora.dev/guides/dora-metrics-four-keys/ — primary ★★★★
- *No empirical study of accuracy by scale type, and no controlled #NoEstimates outcome study, was found (2018+).* Stated honestly in `estimates-exponential.md`.

## Alternatives / competitive tools (Q01.10–12)

- Plane — https://github.com/makeplane/plane (AGPL-3.0) · cycles https://docs.plane.so/core-concepts/cycles · intake https://docs.plane.so/intake/overview · estimates https://docs.plane.so/core-concepts/issues/estimates · updates https://docs.plane.so/communication-and-collaboration/project-updates · API https://developers.plane.so/api-reference/introduction · MCP (MIT) https://github.com/makeplane/plane-mcp-server · editions https://developers.plane.so/self-hosting/editions-and-versions
- Shortcut — automations/iterations https://help.shortcut.com/hc/en-us/articles/17472009334932-Automations · estimates https://help.shortcut.com/hc/en-us/articles/25819408141844-Estimating-Work-Overview · API https://developer.shortcut.com/api/rest/v3 · MCP https://help.shortcut.com/hc/en-us/articles/36443434285844-MCP-Server
- Jira/Atlassian — Fibonacci https://www.atlassian.com/agile/project-management/fibonacci-story-points · snooze declined https://jira.atlassian.com/browse/JSDCLOUD-12377 · Rovo MCP https://github.com/atlassian/atlassian-mcp-server · rate limits https://www.atlassian.com/blog/platform/evolving-api-rate-limits
- Trello — REST/webhooks https://developer.atlassian.com/cloud/trello/guides/rest-api/api-introduction/ · estimates via Power-Up https://developer.atlassian.com/cloud/trello/guides/power-ups/building-a-power-up-part-two/
- GitHub Projects — iteration field https://docs.github.com/en/issues/planning-and-tracking-with-projects/understanding-fields/about-iteration-fields · Issue fields preview https://github.blog/changelog/2026-05-21-issue-fields-are-now-in-public-preview-for-all-organizations/ · status updates https://docs.github.com/en/issues/planning-and-tracking-with-projects/sharing-project-updates · `gh project` https://cli.github.com/manual/gh_project · MCP https://github.com/github/github-mcp-server
- **Height — SHUT DOWN** (service ended 2025-09-24) — https://www.creativerly.com/height-app-is-shutting-down/ · https://alternativeto.net/news/2025/3/height-project-management-tool-to-shut-down-by-september-2025/ — secondary ★★

## Agent-ticket schemas (Q01.16–17)

- AGENTS.md — https://agents.md/ — primary ★★★★
- Anthropic, *Best practices for Claude Code* — https://code.claude.com/docs/en/best-practices — primary ★★★★★
- Cognition, *Creating Playbooks (Devin)* — https://docs.devin.ai/product-guides/creating-playbooks — primary ★★★★
- Cursor *Rules* https://cursor.com/docs/rules · Cline *Memory Bank* https://docs.cline.bot/features/memory-bank · Aider *Conventions* https://aider.chat/docs/usage/conventions.html — primary ★★★★
- Sweep docs — https://docs.sweep.dev/ — primary ★★★★
- Augment Code, *AI Spec Template* — https://www.augmentcode.com/guides/ai-spec-template — practitioner ★★★
- CodeRabbit, *The hidden cost of AI coding agents* — https://www.coderabbit.ai/blog/the-hidden-cost-of-ai-coding-agents-isnt-from-ai-at-all — vendor blog ★★★

## Ritual provenance & WIP math (Q01.18–20)

- Basecamp, *Shape Up* (Ryan Singer) — https://basecamp.com/shapeup/0.3-chapter-01 · https://basecamp.com/shapeup/3.6-chapter-15 — primary/book ★★★★★
- Anderson, *Kanban* (2010) — Kanban Method practices https://djaa.com/revisiting-the-principles-and-general-practices-of-the-kanban-method/ · quotes https://www.goodreads.com/work/quotes/12821559 — primary/book ★★★★★
- Little's Law applied to Kanban — https://getnave.com/blog/kanban-littles-law/ — practitioner ★★★
- Kniberg & Skarin, *Kanban and Scrum* (2010) — https://www.infoq.com/minibooks/kanban-scrum-minibook/ — primary/book ★★★★
- Atlassian, *WIP limits for kanban* — https://www.atlassian.com/agile/kanban/wip-limits — vendor ★★★★

## Practitioner field tests & counter-evidence (Q01.13–15)

- Lunch Pail Labs, *How I use Linear* (solo founder) — https://lunchpaillabs.com/blog/managing-projects-at-lpl-with-linear — practitioner ★★★
- Plum, *How we use Linear* (small team) — https://build.plumhq.com/how-we-use-linear/ — practitioner ★★★
- Indie Hackers, *Ditch Jira: How we use Linear* — https://www.indiehackers.com/post/ditch-jira-how-we-use-linear-to-build-a-better-product-677d10ac2e — community ★★
- Counter-evidence: Pankaj Pipada, *Markdown/Git task system for solo devs* — https://pankajpipada.com/posts/2024-08-13-taskmgmt-2/ ; HN *Why sprints take the joy out* https://news.ycombinator.com/item?id=42022932 ; HN *I don't believe in sprints* https://news.ycombinator.com/item?id=33093941 ; levelsio https://levels.io/100-days-of-shipping/ ; Melatonin *How to not get stuck (solo dev)* https://melatonin.dev/blog/dev-therapy-part-i-how-to-not-get-stuck-as-a-solo-dev/ — practitioner/community ★★–★★★
- GTD: David Allen, *Getting Things Done* — https://gettingthingsdone.com/about/ · https://gettingthingsdone.com/what-is-gtd/ · *Mind like water* https://gettingthingsdone.com/2012/05/david-allen-defines-mind-like-water/ · Wikipedia https://en.wikipedia.org/wiki/Getting_Things_Done — primary/book ★★★★

## Honest "no external validation found"

Per HANDOFF citation discipline, where no external source was found we say so in-file rather than fabricate:

- **A solo-specific** (vs small-team) Linear cycles/triage case study — not found; small-team accounts corroborate the ritual.
- **A solo dev who adopted then abandoned Linear cycles specifically** — not found; the real counter-evidence is structural (sprints as a delivery-predictability tool) and minimalist-by-choice (markdown/git, Post-its).
- **A prior author publishing "16 on a doubling scale = hard stop"** — not found; principle is borrowed (Cohn/Atlassian/SAFe), the specific number is author-original.
- **An external ticket schema with a per-ticket token budget / parallel-safe metadata** — not found; appears playbook-original.
- **Empirical accuracy-by-scale-type and #NoEstimates outcome studies** — not found.
