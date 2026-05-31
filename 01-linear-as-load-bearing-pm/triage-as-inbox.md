# Triage as inbox

> Triage is not a queue you process Mondays. It's the single inbox of your whole workflow. Everything routes here. You triage out, not in.

This is the single biggest mental shift in this chapter. Most Linear users think of Triage as "where Slack-integrated issues land." It's that, but it's also where *every* capture lands — every fleeting idea, every bug you noticed but won't fix today, every "we should also do X" from a session.

## What Triage actually is

Linear's [Triage state](https://linear.app/docs/triage) is the team inbox. From the docs: *"Triage is where new issues from integrations land. From there, you decide where they go."*

The undersell is that Triage works for *any* issue regardless of where it came from. It just isn't the default for issues you create via the UI (those bypass Triage — see [the bypass gotcha](#the-triage-bypass-gotcha) below).

What makes Triage right as the inbox:

- **Tool-enforced single source of truth.** All integration sources (email, Slack, webhook) land here by default. If you route *your own captures* here too, you have one inbox.
- **Triage Intelligence** auto-suggests assignees, projects, and labels — pre-routes captures, reducing triage friction. **(Business/Enterprise plans only[³] — the manual morning pass below is the free-tier baseline and is sufficient on its own.)**
- **`snoozedUntilAt` works on Triage items.** You can defer ambiguous captures to next week without leaving Triage.
- **It's persistent and indexable.** Unlike Linear's Inbox (notification feed, hard-capped — **2,000 items** as of 2026[¹]), Triage doesn't drop items.

This is the same instinct David Allen's *Getting Things Done* is built on: "your mind is for having ideas, not holding them."[²] Triage-as-inbox is GTD's *capture* step ("collect what has your attention into a trusted external system") implemented in your PM tool — one inbox you trust, so nothing lives in your head or a Slack DM.

## Triage vs. Inbox vs. Backlog (often confused)

These are three different things in Linear. Confusing them is a top-five solo-Linear failure mode.

| State | Purpose | Hard cap | Notification semantics |
|---|---|---|---|
| **Triage** | The inbox state for issues. Items here have no Cycle, no Project assignment guarantee. | None | Items appear in views; no badge |
| **Inbox** | The notification feed. Auto-subscribes you to issues you created / are assigned / are mentioned. | **2,000 items** `[2026-Q1: changed from 500]`[¹] | Badge in sidebar |
| **Backlog** | A state for issues that are out of the active queue but kept around. | None | Items appear in views; no badge |

**Rule:** Triage is the inbox you process. Inbox (notifications) is signal, not storage. Backlog is hibernation-lite (see [snooze-as-hibernation](./snooze-as-hibernation.md) for the harder hibernation).

If you treat Inbox as your backlog (common mistake), you'll lose stuff when the 2,000 cap rolls and oldest items get dropped silently.

## The CLI capture (the affordance)

For Triage-as-inbox to work, capture friction must be < 3 seconds. You build this yourself; Linear doesn't ship it.

Pattern: a CLI command — call it `<your-pm>-capture` or `cc` (capture-to-Cmd-center) — that takes a string and files it to Triage.

```bash
# Pseudocode for the capture command
<your-pm>-capture "fix the scoring bug where pass rate spikes to 27%"
# → Files an issue in Triage with that title.
# → Returns in < 3 seconds.
# → Optionally: returns the issue URL so you can open it for detail later.
```

Implementation (Linear-specific, sketch):
```bash
#!/usr/bin/env bash
# <your-pm>-capture — minimal Linear Triage capture
# Token from password manager; never hardcoded.
TOKEN="$(rbw get "Linear API" --field linear_api_key)"   # or your secrets backend
TEAM_ID="<your-team-uuid>"
TRIAGE_STATE_ID="<your-triage-state-uuid>"  # query once, cache locally

curl -s "https://api.linear.app/graphql" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"query\":\"mutation { issueCreate(input:{teamId:\\\"$TEAM_ID\\\", title:\\\"$*\\\", stateId:\\\"$TRIAGE_STATE_ID\\\"}){success issue{identifier url}} }\"}" \
  | jq -r '.data.issueCreate.issue.url'
```

Wire it to a keybind in your terminal or shell. The moment from "I had a thought" to "the thought is filed" must be one command, no fields, no app open.

Field-tested extensions:
- `<your-pm>-capture -p <project>` adds a project hint
- `<your-pm>-capture -l <label>` adds a label
- `<your-pm>-capture --bug` adds `Bug` label
- Voice variant: pipe a `whisper` transcription into the captured title

## The Triage bypass gotcha

This is the #1 surprise. From [linear-io-rules](../03-claude-code-as-operator/) and Linear's docs:

> Issues created by an *authenticated team member account* (including via personal API token) **bypass Triage** and land directly in Backlog (or wherever the create input said). Issues from email/Slack integrations OR from an OAuth app-user route through Triage.

Practical implication:
- Your CLI capture script (using your personal API token) **bypasses Triage by default**. You must explicitly set `stateId` to your Triage state to land items there.
- Your agent (Claude Code with your token) **bypasses Triage by default** — same fix.
- An OAuth-installed Linear app *does* route through Triage. If you migrate your agent to OAuth (some setups do), behavior flips and the explicit `stateId` becomes redundant.

**Document this in your `~/.claude/docs/<pm>-io-rules.md`** so future-you / your agent doesn't get surprised when Triage suddenly fills up after an OAuth migration.

## The morning Triage pass

If Triage is the inbox, it has to get processed. Daily, not weekly.

Recipe:
1. 09:00 morning ritual (launchd + ntfy, see [Chapter 04](../04-rituals-and-triggers/)) opens the Triage saved view.
2. Process top-to-bottom. For each issue:
   - **Discard** (Cancel state) if it's not worth keeping. Don't be precious.
   - **Snooze** (`snoozedUntilAt`) if not actionable now. Set wake date 1-90 days. See [snooze-as-hibernation](./snooze-as-hibernation.md).
   - **Promote to Backlog** if it might be done but not soon.
   - **Promote to Todo + add to current cycle** if you commit to it this week.
   - **Convert to a project** if it's structural (multiple sub-issues).
3. Cap: < 10 minutes per morning. If it's taking longer, your captures are too vague (write better titles at capture time).

**Anti-pattern:** "I'll triage later." Triage backlog of 50 items is psychologically heavier than 50 items in Backlog. The whole point of Triage-as-inbox is that it's transient.

## Routing automation

Linear's Triage Intelligence (a Linear feature, [docs](https://linear.app/docs/triage); Business/Enterprise only[³]) auto-suggests assignee / project / label. Accept the suggestions when right; override when wrong. Over weeks, suggestions improve. On Free, skip this — manual labeling does the job at solo volume.

Build alongside:
- **Auto-tag captures** by prefix: a script that adds a `via-cli` label to captures, so you can audit your own capture flow.
- **Auto-route by keyword:** if the title contains "bug" → `Bug` label; "research" → research project hint.
- **Auto-prefix from tmux context:** capture-from-project-X auto-suggests project X.

But: **never auto-promote to a cycle.** Auto-promotion bypasses the morning triage gate; you'll find tickets in cycles you don't remember committing to.

## Field-tested gotchas

**Triage Intelligence learns slowly with low volume.** If you create < 5 issues a day, suggestions stay generic for weeks. Manual labeling for the first month pays off later.

**Bulk-snoozing in Triage works.** Don't bulk-promote Triage items to Backlog if you can't process them — bulk-snooze instead. Set wake = +30 days, batch-resolve on resurface. Beats letting items sit in Triage and weighing on you.

**The "I'll Triage out at the next Monday session" plan fails by Wednesday.** If you process Triage weekly, items accumulate fast enough that the weekly session takes 45 minutes and is exhausting. Daily 10-min beats weekly 45-min.

**Don't add Cycle at capture time.** Captures should be cycle-less by definition — they enter the system, get triaged, and *then* get assigned to a cycle (or not). Adding Cycle at capture defeats the gate.

## Innovative pattern: tmux-pane-aware capture

When your terminal context is project X, the capture should default to project X. tmux pane title carries the project name; your capture script reads it.

```bash
# In your capture script:
CURRENT_PROJECT="$(tmux display-message -p '#{session_name}')"
# Map session name → Linear project ID via a local YAML/JSON file
PROJECT_ID="$(jq -r ".[\"$CURRENT_PROJECT\"]" ~/.config/<your-pm>-projects.json)"
```

Captures from your `app-foo` tmux session auto-suggest the app-foo project. From `command-center`, the Command Center project. This shrinks per-capture friction from "write the title + remember which project + tag" to "write the title."

Tradeoff: the mapping needs maintenance. Worth it once you have 5+ active projects.

## What this rules out

Adopting Triage-as-inbox is a commitment, and it explicitly *forecloses* some things:

- **No second inbox.** If captures also land in a notes app, a Slack "later" channel, or your head, you no longer have a single source of truth and the trust collapses. One inbox or none.
- **No weekly batch triage.** The pattern requires a *daily* < 10-min pass. If you can only triage weekly, don't adopt this — items pile up and the inbox becomes the dread-Backlog you were avoiding.
- **No relying on the Inbox (notifications) as storage.** It drops oldest past 2,000 items.[¹] Notifications are signal, not a backlog.
- **No auto-promotion to a cycle.** Automations and AI may *suggest*; the promote-to-cycle gate stays manual.

If you can't hold the daily pass, a lighter system (a single `todo.md` per repo) is more honest than a Triage inbox you don't process — see the [counter-evidence in snooze-as-hibernation](./snooze-as-hibernation.md#field-tests-beyond-the-author).

## Field tests beyond the author

Practitioners independently describe Triage-as-inbox. A small team migrating off Jira documents using "Triage as an inbox for your team" for unprocessed/incoming issues before they enter the workflow.[⁴] Linear's own Method frames Triage as "a special inbox for your team."[⁵] The deeper lineage is GTD's *capture → clarify → organize* loop;[²] Triage is where capture lands and clarify happens. We did not find a published *solo*-specific Triage-as-inbox case study — the closest are small-team accounts; treat the solo framing as field-tested by the author and corroborated-in-principle.

## Sources

Linear claims verified via Linear's documentation-search MCP on 2026-05-31. External quotes gathered via web search (domains block automated fetch). Full notes in [`sources.md`](./sources.md).

- [1]: Linear, *Inbox* (2,000-notification cap) — https://linear.app/docs/inbox — accessed 2026-05-31
- [2]: David Allen, *Getting Things Done* — https://gettingthingsdone.com/about/ , https://gettingthingsdone.com/what-is-gtd/ — accessed 2026-05-31
- [3]: Linear, *Triage* (Triage Intelligence is Business/Enterprise) — https://linear.app/docs/triage — accessed 2026-05-31
- [4]: Indie Hackers, *Ditch Jira: How we use Linear* — https://www.indiehackers.com/post/ditch-jira-how-we-use-linear-to-build-a-better-product-677d10ac2e — accessed 2026-05-31
- [5]: Linear, *Linear Method* — https://linear.app/method/introduction — accessed 2026-05-31

## Related

- [Linear Triage](https://linear.app/docs/triage) — primary docs
- [Linear Inbox](https://linear.app/docs/inbox) — different thing, don't confuse
- [Snooze as hibernation](./snooze-as-hibernation.md) — what to do with low-priority captures
- [Ticket standard](./ticket-standard.md) — what a capture matures into
- [Chapter 04 — Rituals and triggers](../04-rituals-and-triggers/) — the morning trigger
