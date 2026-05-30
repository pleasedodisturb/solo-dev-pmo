# Snooze as hibernation

> Snooze is not "remind me later." It's deliberate hibernation. Hands off until the wake date.

The mental shift: most solo devs see snooze as a soft reminder. In this playbook, snooze is the hibernation gate that turns a Backlog of 270 items into a Backlog of 70 visible + 200 deliberately asleep.

## What `snoozedUntilAt` actually does

From [Linear Triage docs](https://linear.app/docs/triage):
> *"Snooze resurfaces at a time of your choosing, or when there's new activity on that issue: whichever comes first."*

Mechanically:
- Setting `snoozedUntilAt = <future-date>` hides the issue from default views.
- It does NOT change the issue's state. A snoozed Backlog issue is still in Backlog; just hidden.
- New activity (a comment, a mention, a state change) wakes the issue immediately, even before the wake date.
- The wake date is fixed at set-time. There's no recurring snooze.

This is exactly the right semantics. Snooze = "I trust the system to wake me when needed, otherwise leave me alone until <date>."

## The use case it solves: dread-driven Backlog avoidance

The pattern this fixes: you have 270 open issues. You open Backlog, see 270 items, feel dread, close Linear. The Backlog becomes a graveyard.

The intervention: **bulk-snooze most of the Backlog with a 90-day wake date.** What's left visible is the actually-in-play ~70-80 items.

Numbers from one solo dev's actual cleanup:
- Before: 336 open issues, 228 in Backlog, opening Linear felt awful
- Action: bulk-snoozed 236 abandoned Backlog tickets to wake in ~90 days
- After: 108 in-play issues visible, Backlog skim takes 90 seconds, dread gone
- Wake date arrives 90 days later: items resurface, you triage what's still relevant (most aren't), discard rest

This is not "marking things done that aren't done." It's putting them in hibernation. They still exist; they just aren't asking for attention right now.

## The decision criteria for bulk snooze

When auditing Backlog, the question per item is:
1. **Is there a concrete next step I'd take this month if I touched this?** If yes → keep visible.
2. **Is this blocked on an external trigger (waiting on someone, waiting for a date)?** If yes → snooze to that date.
3. **Is this an "I might want this someday" capture?** If yes → snooze 90 days.
4. **Is this stale (no activity > 90 days, no realistic plan)?** If yes → snooze 180 days. If it resurfaces and still has no plan, cancel.

The 90-day default is calibrated empirically: long enough that you stop seeing it, short enough that it cycles back before it becomes archaeology. Adjust per your project pace.

## Bulk snooze via GraphQL

Linear's UI supports per-issue snooze. For bulk operations, GraphQL is the path:

```graphql
mutation {
  issueUpdate(
    id: "<issue-id>",
    input: { snoozedUntilAt: "2026-08-15T00:00:00Z" }
  ) { success issue { identifier snoozedUntilAt } }
}
```

For batches, iterate over a query result:

```bash
#!/usr/bin/env bash
# bulk-snooze: snooze all Backlog issues meeting a filter to a wake date.
TOKEN="$(rbw get "Linear API" --field linear_api_key)"
WAKE_DATE="2026-08-15T00:00:00Z"

# Query: Backlog issues with no activity in last 90 days
QUERY='query{ issues(filter:{state:{name:{eq:"Backlog"}}, updatedAt:{lt:"2026-02-28"}}){ nodes{id identifier} } }'

curl -s "https://api.linear.app/graphql" -H "Authorization: $TOKEN" -H "Content-Type: application/json" \
  -d "{\"query\":\"$QUERY\"}" \
  | jq -r '.data.issues.nodes[].id' \
  | while read -r issue_id; do
      curl -s "https://api.linear.app/graphql" -H "Authorization: $TOKEN" -H "Content-Type: application/json" \
        -d "{\"query\":\"mutation{ issueUpdate(id:\\\"$issue_id\\\",input:{snoozedUntilAt:\\\"$WAKE_DATE\\\"}){success} }\"}"
    done
```

**Dry-run first.** Before any bulk operation, run the query without the mutation to see what you're about to touch. Always.

## The "respect the wake date" rule (non-negotiable)

Once an issue is snoozed, **do not un-snooze it in bulk.** Snoozing is a deliberate hibernation choice; un-snoozing in bulk re-creates the original dread Backlog.

Specific rules:

- **Do not** query "all open tickets" and assume snoozed ones are still actionable. They aren't, until they wake.
- **Do not** bulk un-snooze "to clean up." If you must un-snooze an individual item, do it with explicit reason in a comment.
- **Do** filter snoozed items OUT of default views: `filter: { snoozedUntilAt: { null: true } }` for "what's actively in play."

Your agent (Claude Code with Linear access) should know this rule too. Document it in your Linear I/O rules doc so agents don't un-snooze when "helping organize."

## What to do when items wake

The wake date arrives. Items resurface (Linear may add a `Resurfaced` saved view; build your own if not — filter: snooze-was-set, now `snoozedUntilAt is past`).

Triage protocol for resurfaced items:
1. Is the original premise still relevant? If no → cancel.
2. Is it actionable this month? If no → snooze again, 60 days.
3. Is it actionable this week? If yes → promote to Todo + add to a cycle.
4. Is it actionable but not soon? If yes → leave in Backlog visible (don't re-snooze).

**Pattern:** the second-pass triage is much faster than the first because you've already culled. ~80% of resurfaced items either get canceled immediately or snoozed again. The 20% that come into play are the ones that were actually waiting on external triggers.

## Anti-patterns

- **Treating snooze as a deferred priority** ("I'll get to it in 90 days") — wrong. Snooze is "I have no intent to do this; wake me only if something forces the question."
- **Snoozing things that are blocking work** — these aren't snooze candidates; they're blocked, file as such with a `Blocked` relation.
- **Snoozing for < 7 days** — that's just laziness. Snooze is for genuine hibernation. Short defer = either do it now or push to Backlog without snoozing.

## Snooze vs Cancel vs Icebox

| State | Means | When |
|---|---|---|
| Snooze | "I trust the system to wake me; otherwise leave me alone" | Default hibernation, 30-180 day window |
| Cancel | "This isn't going to happen" | When you're sure |
| Icebox | "Long-term parking, not coming back soon" | Optional state for "maybe in 6+ months" — some teams skip this |
| Backlog (visible) | "Active queue, not in cycle yet" | Default for things you'll get to |

Icebox is a useful intermediate if Backlog feels too short-term. Some workflows: Backlog = within ~3 months horizon, Icebox = "maybe someday." Define the boundary in `conventions/states.md`.

## Field-tested gotchas

**Snoozed items still count in some Linear views.** Custom views with `Status = Backlog` will include snoozed items unless you add `snoozedUntilAt: { null: true }`. Audit your saved views.

**Snoozed items can wake unexpectedly.** Any mention, comment, or state change wakes them. If you @-mention yourself on an old snoozed issue to leave a note for future-you, you've woken it. Use issue description edits instead.

**"Snooze for 90 days" needs an actual date.** Linear's UI lets you pick a relative date; the API requires an absolute timestamp. If you build scripted snooze, compute the date in script (`date -v +90d` on macOS, `date -d "+90 days"` on Linux).

**Bulk snooze across multiple teams requires per-team scripts.** If your workspace has multiple teams, the filter is team-scoped. Run one bulk-snooze pass per team.

**Project snooze ≠ issue snooze.** Linear's project-level pause is different. Project pause makes the whole project Paused (a project-status category, see [WIP cap](./wip-cap-with-continuous-areas.md)). Issue snooze hibernates individual issues. Don't conflate.

## Innovative pattern: rolling 90-day backlog gate

Combined with the [Friday retro](./cycles-and-rituals.md) — every Friday, run a script that lists Backlog items > 90 days old that haven't been touched. Either:
- Promote to Todo (commit this cycle)
- Snooze 90 days
- Cancel

Run on cooldown weeks; skip on push weeks. After 6-8 weeks, the visible Backlog stabilizes at "what's actually realistic for the next 90 days." Beyond that horizon, everything is either snoozed or canceled.

## Related

- [Linear Triage](https://linear.app/docs/triage) — primary docs (snooze section)
- [Triage as inbox](./triage-as-inbox.md) — Triage items are snoozable too
- [Cycles and rituals](./cycles-and-rituals.md) — wake-date triage as a cooldown task
- [I/O rules](./io-rules.md) — `snoozedUntilAt` handling rules for agents
