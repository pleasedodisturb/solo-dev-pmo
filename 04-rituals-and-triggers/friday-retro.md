# Friday retro ritual

> 16:00 Friday. Linear Project Update reminder fires. You spend 5 minutes per project picking On Track / At Risk / Off Track. That's the entire retro.

## The recipe

This ritual is mostly Linear's, not yours.

1. **Configure** Linear: Settings → Workspace → Project Updates → weekly reminder Friday 16:00, with auto-generated content on.
2. **At Friday 16:00**, Linear pushes the reminder to your Inbox + email.
3. **For each push project**, pick On Track / At Risk / Off Track + (optional) one-line note.
4. **Done.** Total time: 5 minutes for 3 push projects.

The ritual depends on you doing the small thing. Linear sends two follow-up nudges 1 and 2 working days later if you skip — those nudges are the affordance for ADHD-aware compliance.

## Why this format

[Linear's own team posts every Friday](https://linear.app/now/how-we-built-project-updates). The 3-option format is the differentiator: small enough to do, structured enough to be useful.

The 3 options carry meaning:
- **On Track** — what shipped, brief note about momentum
- **At Risk** — what slipped, why, what's the mitigation next week
- **Off Track** — what's blocked, what would unblock it, escalate to yourself

You can write more, but you don't have to. The 3-option is the floor.

## Companion script

The Linear reminder is the retro. The companion script enriches it.

```bash
#!/usr/bin/env bash
# ~/.local/bin/friday-retro — companion to Linear's Project Update reminder
set -euo pipefail

export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key)"
NTFY_TOPIC="$(rbw get 'ntfy topic' --field topic)"

WEEK=$(date +%Y-W%V)
RETRO_FILE=~/retro-$WEEK.md

# What shipped this week?
WEEK_START=$(date -v -mon +%Y-%m-%d)
SHIPPED=$(linearis issues list \
  --closed-since "$WEEK_START" \
  --format short)

# What's blocked?
BLOCKED=$(linearis issues list \
  --filter 'state.name in ["In Progress", "In Review"] AND relations.blocked' \
  --format short)

# Active cycle issues that didn't ship
CYCLE_OPEN=$(linearis issues list \
  --cycle current \
  --state-not Done \
  --format short)

# Build the retro worksheet
cat > "$RETRO_FILE" <<EOF
# Friday retro — $WEEK

## Shipped
$SHIPPED

## Open in cycle (will auto-roll Monday)
$CYCLE_OPEN

## Blocked
$BLOCKED

## Per-project status (fill in for Project Update)
### <push project 1>
- [ ] On Track / [ ] At Risk / [ ] Off Track
- Note: ...

### <push project 2>
- [ ] On Track / [ ] At Risk / [ ] Off Track
- Note: ...

## Quick reflection (optional, 2 min)
- What worked this week?
- What didn't?
- What's the next-week mitigation?
EOF

# Open Linear to project updates page
open "https://linear.app/<workspace>/initiative/updates"

# ntfy
curl -d "Friday $WEEK retro: $(echo "$SHIPPED" | wc -l) shipped, $(echo "$BLOCKED" | wc -l) blocked, $(echo "$CYCLE_OPEN" | wc -l) auto-rolling. Project Updates in browser." \
     "ntfy.sh/$NTFY_TOPIC"

# tmux open
if tmux has-session -t main 2>/dev/null; then
  tmux send-keys -t main:0.0 "less $RETRO_FILE" Enter
fi
```

Fires from launchd at 15:55 (5 minutes before Linear's reminder) so the data is ready when Linear pings.

## The 5 minutes

### 0-2 min: Per-project update

For each push project, pick On Track / At Risk / Off Track. Add one line.

The temptation is to write an essay. Resist. Three sentences max per project.

### 2-4 min: Briefly reflect

What worked? What didn't? What's the next-week mitigation?

If nothing comes to mind, skip. The Linear updates ARE the retro; reflection is bonus.

### 4-5 min: Capture takeaways

If anything from reflection deserves a ticket, file it NOW per [never-defer](../01-linear-as-load-bearing-pm/never-defer.md). Don't write "I'll fix this next week" — file the ticket.

## What this gives you

- **Provable cadence** — `git log` of retro files shows you've done it
- **Carry-forward signal** — At Risk projects this week become Monday priorities next week
- **Stakeholder visibility** if anyone watches — but you're solo; this is for future-you
- **Pattern detection** — projects that are At Risk for 3 weeks running need decisive action (split, abandon, refactor approach)

## What this doesn't give you

- A magic productivity boost
- Architectural insights (those are spikes, not retros)
- Process changes (those happen in cooldowns)

The retro is for *signal*, not *action*. Action is for Monday.

## The cooldown retro

Every 4th cycle, the cooldown cycle is the time for a bigger retro:

- 4-week patterns (what At Risk recurred?)
- Convention sweep (which conventions drifted?)
- Tech debt prioritization
- Plan the next 4 weeks at slightly higher altitude

Cooldown retro = 30-45 minutes. Friday retro = 5 minutes. Don't confuse.

## Field-tested gotchas

**Workspace timezone misconfigured.** Friday 16:00 reminder fires Thursday or Saturday. Check Settings → Workspace → Timezone.

**Reminder snoozed by Linear's UI.** A bug or accidental click can disable the reminder. Verify quarterly.

**The two follow-up nudges (1 and 2 working days later) are essential.** Don't disable them — they're the affordance for missed Fridays.

**Auto-generated content is good as a draft, but always edit.** The auto-generated draft summarizes activity. Add the human signal: how do I feel about momentum?

**Solo: nobody reads your updates.** That's fine. Write them anyway. Future-you reading them in 6 weeks is the audience.

**Don't write essays.** The point of Project Updates is that they're small. Treat the form's brevity as a feature.

## Innovative pattern: shipped/blocked alert in Slack

If you have a personal Slack workspace (or any chat), the Friday script also posts shipped/blocked to a `#weekly-retro` channel. Becomes a chronological log of weekly velocity.

For solo, post to a channel only you see. Still useful — searchable archive.

## Innovative pattern: retro-driven ticket creation

If "At Risk" on the same project for 2 weeks running, the script auto-files a `breakdown` ticket: "Project X has been At Risk for 14 days. Identify breakdown ticket."

The system surfaces the pattern before you've consciously noticed it.

## Innovative pattern: archive-and-compress retros

Quarterly: bundle all weekly retros into a quarter summary. Surface trends:
- Total shipped this quarter
- Top 3 most-blocked things
- Cooldown effectiveness (did cooldown reduce tech debt?)

Quarter summary is the "annual review" gradient — short, frequent, low-stakes.

## Related

- [Chapter 01 — Cycles and rituals](../01-linear-as-load-bearing-pm/cycles-and-rituals.md) — Project Update is the cycle's retro
- [Monday planning](./monday-planning.md) — At Risk feeds next Monday's plan
- [launchd over cron](./launchd-over-cron.md) — fires the companion script
- [Chapter 01 — Never defer](../01-linear-as-load-bearing-pm/never-defer.md) — file tickets from retro now, not later
