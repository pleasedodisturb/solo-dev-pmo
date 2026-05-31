# RESEARCH-LOG — P01 Linear as load-bearing PM

Append-only log of sources consulted while enriching chapter 01. Format per
[`SEARCH-PLAYBOOK.md`](../SEARCH-PLAYBOOK.md) §"Per-phase research log format".

All Linear primary docs accessed via Linear's official documentation-search
MCP on the date noted (linear.app blocks raw WebFetch behind Cloudflare, so the
doc-search MCP is the primary-doc channel for this phase).

---

## 2026-05-31 — Linear AI features shipped 2025–2026 (Q01.2)

- **Source:** https://linear.app/docs/linear-agent
- **Class:** primary (vendor docs)
- **Surfaced fact:** Linear shipped **Linear Agent** (public beta) — a conversational
  agent reachable via ⌘/Ctrl+J or `@Linear` mentions that can create/update issues,
  summarize work, draft and post project/status updates, and connect to external MCP
  servers. Has "Skills" (saved reusable workflows), "Guidance" (workspace/team/personal
  instruction layers), and "Automations." All plans include some Agent usage; heavier
  use (Automations) may move to usage-based pricing.
- **Used in:** `io-rules.md` (new "Linear AI features" section), `triage-as-inbox.md`
- **Counter-evidence:** none — additive feature, does not remove manual workflow.

## 2026-05-31 — Triage Intelligence / Rules / Automations (Q01.2, Q01.5)

- **Source:** https://linear.app/docs/triage-intelligence , https://linear.app/docs/triage
- **Class:** primary
- **Surfaced fact:** Triage now has three stacked automation layers: **Triage Rules**
  (deterministic if-this-then-that on issue properties), **Triage Intelligence** (LLM
  suggests/auto-applies team/project/assignee/label + duplicate detection), and **Triage
  Automations** (open-ended Linear Agent instructions). **All three are Business/Enterprise-plan
  only.** The chapter's existing reference to "Triage Intelligence" auto-suggesting is correct
  but must be marked as a paid-tier feature.
- **Used in:** `triage-as-inbox.md` (mark paid-tier; the manual morning-pass pattern is the
  free-tier baseline)
- **Counter-evidence:** the playbook's manual Triage-as-inbox does NOT require any of these.

## 2026-05-31 — Cycles: rollover + native cooldown + capacity (Q01.1, Q01.20)

- **Source:** https://linear.app/docs/use-cycles
- **Class:** primary
- **Surfaced fact:** Cycles last 1–8 weeks (1-week still supported ✓). "Any unfinished work
  rolls over to the next cycle automatically. There is no way to keep unfinished issues in a
  closed cycle." Cooldowns are now a **native per-cycle setting** ("a cooldown period after
  each cycle… Issues cannot be assigned to a cooldown"). Auto-add toggle covers "Active,
  Started, or Completed" issues; "An active status is a status in the 'Unstarted' and
  'Started' category." Capacity dial = "velocity of the previous three completed cycles" (✓
  matches chapter). New: "Start cycle today" control + subscribe-to-cycle-calendar (.ics).
- **Used in:** `cycles-and-rituals.md`
- **Counter-evidence / DELTA:** chapter claims auto-roll moves only `In Progress` and leaves
  `Todo` issues orphaned. Current docs say *all* unfinished work rolls over and the auto-add
  toggle explicitly includes "Unstarted" (Todo) statuses. The "Todo orphan" gotcha may be
  STALE. Flagged for human; updated with a "[2026: verify]" hedge rather than silent rewrite.

## 2026-05-31 — Inbox cap is 2,000 not 500 (Q01.1 DELTA)

- **Source:** https://linear.app/docs/inbox
- **Class:** primary
- **Surfaced fact:** "you can have up to 2,000 open notifications in your Inbox at one time.
  Older notifications beyond that count will not be retained."
- **Used in:** `triage-as-inbox.md` (the Triage-vs-Inbox-vs-Backlog table said 500 — corrected
  to 2,000 with a [2026-Q1: changed] marker).
- **Counter-evidence:** direct factual correction of a stale number.

## 2026-05-31 — Snooze semantics (Q01.1, Q01.3)

- **Source:** https://linear.app/docs/triage , https://linear.app/docs/inbox
- **Class:** primary
- **Surfaced fact:** Triage snooze (H) "hide[s] the issue from the triage queue to return at
  a time of your choosing, or when there's new activity on that issue: whichever comes first"
  (✓ matches chapter quote exactly). Inbox has separate *notification* snooze. Linear also now
  documents **Issue Reminders** (issue/doc/project/initiative) as a parallel deferral
  mechanism.
- **Used in:** `snooze-as-hibernation.md`, `io-rules.md`
- **Counter-evidence / hedge:** docs frame snooze primarily as a Triage/Inbox action. The
  chapter's bulk-*Backlog*-snooze via the `snoozedUntilAt` API field should be verified against
  the current GraphQL schema. Added an honest "[2026: verify against current GraphQL schema]"
  hedge + cross-reference to Issue Reminders.

## 2026-05-31 — API, webhooks, scoped keys, official MCP (Q01.3)

- **Source:** https://linear.app/docs/api-and-webhooks , https://linear.app/docs/mcp ,
  https://linear.app/docs/security-and-access
- **Class:** primary
- **Surfaced fact:** GraphQL API (no public REST; "Linear does not currently offer a REST API"
  per Customer Requests doc). **Personal API keys can now be scoped** to Read / Write / Admin /
  Create issues / Create comments AND **limited to specific teams.** Webhooks cover Issues,
  Comments, Attachments, Documents, Reactions, Projects, Project updates, Cycles, Labels, Users,
  Issue SLAs. Linear ships an **official remote MCP server** (`https://mcp.linear.app/mcp`,
  OAuth 2.1 + dynamic client registration; can also pass an API key / OAuth token in the
  `Authorization: Bearer` header, e.g. a read-only restricted key).
- **Used in:** `io-rules.md` (refine the "never use the Linear MCP locally" rationale — the
  "MCP bypasses team filters / rate-limit guards" concern is now partly addressable with a
  team-scoped, read-only API key).
- **Counter-evidence:** the official scoped-MCP path weakens (does not eliminate) the chapter's
  blanket anti-MCP stance. Reframed as a deliberate trade-off, not a hard prohibition.

## 2026-05-31 — Pricing / free-tier limits (Q01.5 — load-bearing)

- **Source:** https://linear.app/docs/billing-and-plans , https://linear.app/docs/teams ,
  https://linear.app/docs/members-roles , https://linear.app/docs/customer-requests
- **Class:** primary
- **Surfaced fact:** Free plan exists; **Free is capped at 250 issues** ("If you have over 250
  issues, you will no longer be able to create new issues"). Team limits: Free = 2, Basic = 5,
  Business/Enterprise = unlimited. On Free, all users are Admins. Triage Intelligence/Rules/
  Automations/Responsibility, Asks, private teams, guests, sub-teams = Business/Enterprise.
  Customer Requests = all plans. Education = free 1 yr for students; Startups program = up to
  6 months free Basic/Business. Exact per-seat $ not captured (pricing page is JS-gated).
- **Used in:** README "version matrix" + new pricing note; `snooze-as-hibernation.md`.
- **Counter-evidence / DELTA (important):** the snooze-as-hibernation pattern is built around a
  270–336-issue backlog. **On the Free tier's 250-issue cap, that backlog can't exist** — the
  bulk-snooze pattern presumes a paid plan. Surfaced as an explicit prerequisite.

## 2026-05-31 — Project update cadence + timezone (Q01.1 DELTA, Q01.18)

- **Source:** https://linear.app/docs/initiative-and-project-updates
- **Class:** primary
- **Surfaced fact:** Update reminders are configurable (daily / weekly / biweekly / custom day
  + time) and sent **in the lead's local timezone**; "may not be sent precisely at the chosen
  hour but will be delivered within the hour." Follow-up nudges land 1 and 2 working days later
  (✓). Reminder requires: you are project lead, project is In Progress, no update in last 24h.
  Linear's own example cadence is "weekly on Wednesdays"; the doc's "How we work" notes weekly
  updates reviewed at weekly syncs — **no Friday prescription.**
- **Used in:** `cycles-and-rituals.md` (Q01.18 attribution: Friday 16:00 is the author's pattern,
  not Linear's recommendation) + fix the workspace-timezone gotcha.
- **Counter-evidence / DELTA:** chapter's "Project Updates off-by-one with workspace timezone"
  gotcha looks stale — reminders now use the lead's *local* timezone. Softened with [2026] note.

## 2026-05-31 — Custom workflow states (Q01.4)

- **Source:** https://linear.app/docs/configuring-workflows , https://linear.app/docs/conceptual-model
- **Class:** primary
- **Surfaced fact:** Statuses fully customizable per team within fixed categories (Backlog,
  Unstarted, Started, Completed, Canceled) + Triage + Duplicate. Linear's own product team uses
  Icebox/Backlog, Todo, In Progress/In Review/Ready to Merge, Done, Canceled/Could not reproduce/
  Won't Fix. Validates the chapter's Triage + Icebox + state-machine content (incl. snooze-vs-
  Icebox table). Auto-close + auto-archive configurable per team.
- **Used in:** confirms `triage-as-inbox.md` and `snooze-as-hibernation.md` state content — no
  change needed beyond a "checked 2026-05-31" stamp.
- **Counter-evidence:** none — chapter is accurate here.

## 2026-05-31 — Estimation literature (Q01.6–9)

- **Sources:** McConnell *Software Estimation* (2006); Cohn (Mountain Goat: Fibonacci/SPIDR); Jeffries *Story Points Revisited*; Holub *#NoEstimates*; Fowler bliki; ZenHub; Atlassian; SAFe; SPACE (ACM Queue 2021); DORA. URLs in `sources.md`.
- **Class:** primary/book + practitioner + academic
- **Surfaced facts:** No author owns "1/2/4/8/16" — it's a selectable tooling option (Linear "exponential"; ZenHub doubling). Cohn's perceptibility/false-precision + McConnell's diseconomies-of-scale justify any non-linear scale. Counter-pole: Jeffries regrets story points; Holub calls estimates waste; Fowler's purpose-test is the pragmatic middle. **"16 = hard stop" is author-original in its specific number** (nearest published: Atlassian "20+ = red flag", Cohn "top of scale = split", SAFe right-sizing, SPIDR).
- **Used in:** `estimates-exponential.md`
- **Counter-evidence / honest gap:** NO empirical study of accuracy by scale type; NO controlled #NoEstimates outcome study (2018+). Stated in-file.

## 2026-05-31 — Alternatives matrix (Q01.10–12)

- **Sources:** Plane, Shortcut, Jira, Trello, GitHub Projects primary docs; Height shutdown coverage. URLs in `sources.md` + `alternatives.md`.
- **Class:** primary vendor docs + secondary (Height status)
- **Surfaced facts:** No tool matches Linear's full six-pattern set. **Plane is closest** (AGPL, self-hostable; native cycles+auto-roll, Intake/Triage, richest estimates, project updates+reminders, official MCP) — **misses only snooze.** **Height SHUT DOWN, service ended 2025-09-24** (was a transfer target in the chapter). Shortcut/GitHub ~4/6; Jira/Trello trail. GitHub Issue fields entered preview 2026-05-21.
- **Used in:** new `alternatives.md`; README "Why Linear revisited"; `io-rules.md` mapping table.
- **Counter-evidence / DELTA:** the chapter's "Height" references are now dead; reframed "Why Linear?" to "Linear or Plane."

## 2026-05-31 — Agent-ticket schemas + failure modes (Q01.16–17)

- **Sources:** AGENTS.md; Anthropic Claude Code best practices; Devin Playbooks; Cursor/Cline/Aider rules; Sweep; Augment Code; CodeRabbit. URLs in `sources.md`.
- **Class:** primary vendor docs + practitioner
- **Surfaced facts:** The 7-section+metadata+stop-conditions+token-budget bundle is a **superset**; Anthropic's guidance is closest in spirit (scope/files/verification/out-of-scope/Stop hooks). **No external ticket schema publishes a per-ticket token budget or parallel-safe/worktree/depends-on metadata** — playbook-original. Failure modes (Anthropic): trust-then-verify gap, infinite exploration; (practitioner): scope creep, hallucinated requirements.
- **Used in:** `ticket-standard.md`
- **Counter-evidence:** none; corroborates the standard's value.

## 2026-05-31 — Ritual provenance + WIP math (Q01.18–20)

- **Sources:** Shape Up (Basecamp); Anderson *Kanban* (2010); Little's Law; Kniberg & Skarin; Atlassian WIP. URLs in `sources.md`.
- **Class:** primary/book + practitioner
- **Surfaced facts:** Shape Up = 6 build + 2 cool-down (25%); playbook keeps the 25% ratio, compresses to 3+1. WIP math = Little's Law (cycle time = WIP/throughput) + Anderson's "~2 items per knowledge worker." Friday update = Linear's *internal* habit, not a product rule; weekly cadence IS Linear's recommendation; 16:00 is author's choice (Q01.18).
- **Used in:** `cycles-and-rituals.md`, `wip-cap-with-continuous-areas.md`
- **Counter-evidence:** none.

## 2026-05-31 — Practitioner field tests, counter-evidence, GTD (Q01.13–15)

- **Sources:** Lunch Pail Labs, Plum, Indie Hackers (positive); Pipada, HN sprint threads, levelsio, Melatonin (counter); David Allen GTD (official). URLs in `sources.md`.
- **Class:** practitioner + community + primary/book
- **Surfaced facts:** Positive load-bearing-PM accounts exist (strongest true-solo = Lunch Pail Labs; others are small teams). GTD is the clean lineage: "mind for ideas not holding them" (capture), tickler file (snooze), Someday/Maybe (hibernating backlog).
- **Used in:** `triage-as-inbox.md`, `snooze-as-hibernation.md`, `never-defer.md`
- **Counter-evidence:** real but structural — NO clean "adopted-then-abandoned-Linear-as-solo" case; the honest counter is "many solo devs reject heavy PM tooling (markdown/git, Post-its); sprints are a delivery-predictability tool with little value when no one needs the predictability." Stated in-file.

## 2026-05-31 — Cross-cutting verification caveat

- **All non-Linear domains returned HTTP 403 to automated full-page fetch.** External quotes are web-search extractions; widely-attested lines are cross-confirmed, others are presented as position-attributions. Recorded prominently in `sources.md`; `[2026: verify]` markers left in-text for behaviors needing live-workspace confirmation.
