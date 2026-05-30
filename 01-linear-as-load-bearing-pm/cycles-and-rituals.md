# Cycles and rituals

> The cycle is the heartbeat. The ritual is the trigger that hits it.

Most PM tool advice for solo devs is "use whatever sprint cadence feels right." That's a recipe for no cadence at all. This section is opinionated.

## The recipe

1. **1-week cycles, Monday → Sunday.** Not 2 weeks.
2. **Auto-roll on.** Incomplete `In Progress` work cascades into next cycle automatically. You never manually carry over.
3. **Auto-assign-completed on.** Issues you mark Done get auto-attributed to the current cycle.
4. **Lock to active = off.** Issues can span cycles when they need to.
5. **A cooldown cycle every 4th week** for tech-debt / housekeeping. Optional but recommended.
6. **Project Update reminder = Friday 16:00 weekly.** With Linear's auto-generated content on.
7. **Cycle WIP cap = 5 issues, max 2 of P0+P1 combined.** Anything more is a planning failure.

Each of these is a choice. The next sections explain why.

## Why 1-week, not 2-week (Linear Method default)

[Linear Method](https://linear.app/method/introduction) prescribes 2-week cycles: *"Create momentum — don't sprint."* That's correct advice for a team. Wrong cadence for solo + ADHD.

The reason: feedback loop latency. A 2-week cycle means a 2-week loop between "I set the plan" and "I see whether the plan held." If your time-estimation is broken (chronic underestimation is the ADHD baseline), 2 weeks of bad estimates compounds before you see the data. 1-week cycles give you 26 feedback loops per year instead of 13. You correct twice as fast.

Concrete: if a typical "submission" task takes 2× your gut estimate, you discover that fact in week 1 of a 1-week cycle (you missed your plan) and adjust week 2. In a 2-week cycle, you don't discover it until day 9, by which point the cycle is shot AND your next 2-week plan is already overcommitted.

**Counter-argument:** 1-week cycles add planning overhead. True — but the Monday plan is supposed to be 15 minutes, not 2 hours. If your Monday planning takes 2 hours, the planning surface is too detailed (or your tickets are too vague — see [ticket-standard](./ticket-standard.md)).

## Why auto-roll over manual carry-over

Linear setting: `cycleIssueAutoAssignStarted = true`. From [Linear Cycles docs](https://linear.app/docs/use-cycles): *"There is no way to keep unfinished issues in a closed cycle"* — Linear forces a decision (carry over or drop). Auto-roll makes that decision automatic in your favor.

Without auto-roll, Friday becomes "triage what didn't get done." That triage requires:
1. Remember what was in the cycle.
2. Decide for each whether to carry, drop, snooze, or descope.
3. Manually re-assign cycles.

Three decision points × 5+ tickets × ADHD = the work doesn't happen and the tool decays.

With auto-roll: at midnight Sunday → Monday, in-progress work flows forward automatically. The "decision" becomes: at Monday's planning ritual, you look at the carryover and either keep, descope, or push down to Backlog. One decision per ticket, not three.

**Important:** auto-roll only handles `In Progress`. Issues that were planned but never started (`Todo` state) stay assigned to the old cycle and become orphans. Filter for these in Monday planning (saved view: `Cycle = previous AND State = Todo`).

## Why a cooldown cycle every 4th week

[Linear Cycles docs](https://linear.app/docs/use-cycles) describe cooldowns as a buffer for tech debt. For solo + ADHD, repurpose them: **the cooldown is your Friday-retro buffer at cycle scale.** Three weeks of push, one week of breathing room.

What goes in cooldown:
- Tech debt items you've been parking
- Convention updates (rewrite a doc that's getting stale)
- "Cheatsheet sweep" — review terminal cheatsheets / personal docs for missed updates
- The post-mortem from the prior 3 cycles ("what kept slipping?")
- Bulk-snooze a portion of Backlog that's been ignored

Treat cooldown as a *scheduled* slack week. It is not "no work week." It's "non-push work week."

Anti-pattern: skipping cooldown because you're behind on push work. The cycle after you skip cooldown is always worse than the one before. Tech debt and convention rot compound.

## Why Friday 16:00 Project Update reminders

[Linear Project Updates](https://linear.app/docs/initiative-and-project-updates) support workspace-wide weekly reminders. Linear's own team posts every Friday — [their blog explains why](https://linear.app/now/how-we-built-project-updates).

For solo + ADHD: **the Project Update reminder IS your Friday retro trigger.**

Linear ships a 3-option health indicator: On Track / At Risk / Off Track + free-text. The structure is the retro:
- *On Track* — what shipped, brief note
- *At Risk* — what slipped, why, what's the next-week mitigation
- *Off Track* — what's blocked, what would unblock it, escalate to yourself

This is the entire retro. Three options, no essay. Fire-and-forget for projects that are fine; thought-provoking for projects that aren't.

Two follow-up nudges land 1 and 2 working days later if you skip. **Don't disable the nudges** — the nudges are the affordance.

**Field note:** A "weekly retro that takes 15 minutes" is the kind of thing solo devs swear they'll do and never do. Linear's reminder + 3-option structure is the only retro format I've seen actually survive 6 months solo. The format being *small enough to do at 16:01 on a Friday* is the feature.

## The Monday planning ritual

Linear doesn't have a built-in Monday planner. You build it. See [Chapter 04 — Monday planning](../04-rituals-and-triggers/monday-planning.md) for the launchd plist + script.

What it does:
- Fires at 09:00 Monday.
- Opens your "This week" saved view in the browser.
- Pushes ntfy: *"Monday plan: review carry-over from last week, pull 5 issues into this cycle."*
- Optionally: prints a one-page summary (auto-rolled issues, no-cycle issues, stale issues) into a tmux pane.

What you do in the 15 minutes after:
- Look at auto-rolled issues. Keep / descope / push to Backlog.
- Pick at most 5 issues for this cycle. Confirm each has an estimate. Confirm at most 2 are P0+P1.
- If anything wants estimate 16, force a breakdown before pulling it in.

If this takes more than 15 minutes, the friction is in the tickets (vague, no AC, no estimates). Tighten the [ticket standard](./ticket-standard.md), not the ritual.

## Cycle WIP cap rationale

The cap is 5 issues / max 2 P0+P1. Numbers chosen empirically (one engineer at full focus completes 3-5 properly-scoped issues per 1-week cycle; 2 high-priority items already crowd a week).

Why mechanical cap? Because soft caps don't work. Soft cap = "I'll try to keep it small." Hard cap = "the saved view turns red when I exceed it; my Monday script blocks adding more than 5."

How to enforce in Linear: no native cap, but two affordances together approximate one:
1. A saved view `Cycle = current AND Assignee = me` with count visible — when > 5, you see it red.
2. Your Monday script reads the count via GraphQL and refuses to add more.

## Saved views you build

The six views your "This week" page should let you reach in one click:

| View name | Filter | Why |
|---|---|---|
| **This week** | `Cycle = current AND Assignee = me` | Default landing page (set in Account → Preferences) |
| **Blocked** | Blocked issue-relation present | Surfaces what to unblock first |
| **No estimate** | `Estimate is empty AND State in [Todo, In Progress]` | Monday cleanup target |
| **No cycle** | `Cycle is empty AND State in [In Progress, Todo]` | These are orphans; either commit or push to Backlog |
| **Stale** | `Updated before -14d AND State != Backlog` | Will rot if not touched |
| **Resurfaced** | Snoozed items waking up this week | These came back; act on them |

Set "This week" as your default landing view (Settings → Account → Preferences → Default workspace view). When you open Linear, you don't see the firehose — you see what you committed to this week.

## Field-tested gotchas

**The Monday script must read the active cycle ID at runtime.** Cycle UUIDs change every week. Don't hardcode any cycle ID anywhere. GraphQL:
```graphql
query { team(id: "<team-uuid>") { activeCycle { id number startsAt endsAt } } }
```

**Project Updates have an off-by-one with the workspace timezone.** If your reminder is set for Friday 16:00 and your workspace timezone is wrong, the reminder fires Thursday or Saturday. Check Settings → Workspace → Timezone before scheduling.

**Auto-roll silently leaves orphans for issues in `Todo` state.** Auto-roll only moves `In Progress`. A ticket you planned but never started stays in the closed cycle. Your Monday view *must* include `Cycle = previous AND State = Todo` so you see the orphans.

**Cycle count > 5 in current cycle while it's Monday morning is a planning failure, not a reminder to work harder.** When the cap is breached, descope. Don't try to "just push through" — you're encoding the failure mode the cap was meant to prevent.

## Related

- [Linear Cycles](https://linear.app/docs/use-cycles) — primary docs
- [Linear Project Updates](https://linear.app/docs/initiative-and-project-updates) — Friday retro mechanism
- [Estimates: exponential](./estimates-exponential.md) — the WIP cap depends on real estimates
- [Chapter 04 — Monday planning](../04-rituals-and-triggers/monday-planning.md) — the script that fires
- [Chapter 04 — Friday retro](../04-rituals-and-triggers/friday-retro.md) — companion to the Project Update
