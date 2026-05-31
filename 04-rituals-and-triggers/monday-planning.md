# Monday planning ritual

> 09:00 Monday. launchd fires. Browser opens to "This week." ntfy pushes to your phone. A worksheet drops to tmux. 15 minutes later, your cycle is committed.

## The recipe

A launchd plist fires `monday-plan.sh` every Monday at 09:00. The script:

1. Queries Linear for the active cycle (never hardcode IDs)
2. Lists carry-over (auto-rolled from last cycle)
3. Lists Triage items > 48h old
4. Lists projects nearing WIP cap
5. Opens "This week" saved view in browser
6. Pushes ntfy to phone with a one-line summary
7. Writes a worksheet to `~/today.md`
8. tmux pops the worksheet open in pane 0

Then you spend 15 minutes deciding:
- Which carry-overs stay
- Which Triage items get promoted
- Which 5 (max) issues land in the cycle
- Verify each has an estimate, max 2 are P0+P1
- Commit (no actual commit; just the act of finalizing the plan)

## The script

```bash
#!/usr/bin/env bash
# ~/.local/bin/monday-plan — Monday planning trigger
set -euo pipefail

# Load secrets
export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key)"
NTFY_TOPIC="$(rbw get 'ntfy topic' --field topic)"

WEEK=$(date +%Y-W%V)
WORKSHEET=~/today.md

# 1. Get active cycle
ACTIVE_CYCLE_INFO=$(linearis cycles list --active --format json)
CYCLE_NUM=$(echo "$ACTIVE_CYCLE_INFO" | jq -r '.[0].number')
CYCLE_END=$(echo "$ACTIVE_CYCLE_INFO" | jq -r '.[0].endsAt')

# 2. Carry-over from last cycle
PREV_CYCLE_NUM=$((CYCLE_NUM - 1))
CARRY_OVER=$(linearis issues list \
  --cycle "$CYCLE_NUM" \
  --filter 'created < cycle.startsAt' \
  --format short)

# 3. Stale Triage
STALE_TRIAGE=$(linearis issues list \
  --state Triage \
  --filter 'createdAt < now-48h' \
  --format short)

# 4. Project WIP check
PUSH_PROJECTS_STARTED=$(linearis projects list \
  --state Started \
  --filter 'initiative != null' \
  --format short)
PUSH_COUNT=$(echo "$PUSH_PROJECTS_STARTED" | wc -l)

# 5. Open browser
open "https://linear.app/<your-workspace>/team/<TEAM>/active"

# 6. Build worksheet
cat > "$WORKSHEET" <<EOF
# Monday $WEEK plan

**Active cycle:** #$CYCLE_NUM (ends $CYCLE_END)
**Push projects started:** $PUSH_COUNT (cap: 3)

## Carry-over from last cycle ($PREV_CYCLE_NUM)
$CARRY_OVER

→ For each: keep / descope / push to Backlog

## Stale Triage (> 48h)
$STALE_TRIAGE

→ Process now (10 min cap)

## This cycle commit checklist
- [ ] Pick at most 5 issues for cycle
- [ ] All have estimates (no empty)
- [ ] Max 2 P0+P1 combined
- [ ] No 16-point items (break them up first)
- [ ] Lead project this cycle: <name>

## Quick views
- This week: https://linear.app/<workspace>/team/<TEAM>/active
- Blocked: https://linear.app/<workspace>/team/<TEAM>/blocked
- No estimate: https://linear.app/<workspace>/team/<TEAM>/no-estimate
EOF

# 7. ntfy to phone
curl -d "Monday $WEEK plan ready — carry-over: $(echo "$CARRY_OVER" | wc -l) items, stale Triage: $(echo "$STALE_TRIAGE" | wc -l)" \
     "ntfy.sh/$NTFY_TOPIC"

# 8. tmux open worksheet
if tmux has-session -t main 2>/dev/null; then
  tmux send-keys -t main:0.0 "less $WORKSHEET" Enter
fi
```

Wire to launchd per [launchd-over-cron](./launchd-over-cron.md) (or
[systemd](./linux-systemd-variant.md) on Linux).

## Why these numbers (cadence defense)

Separate what's earned from what's preference:

- **Weekly, Monday** — defensible. The plan loads the cycle, and the cycle starts
  Monday; planning the week at its start is ordinary cycle hygiene
  ([Chapter 01](../01-linear-as-load-bearing-pm/cycles-and-rituals.md)).
- **15-minute cap** — *author preference*, but the principle is sound: fixed,
  short timeboxes beat open-ended work. Pomodoro builds discipline on a fixed
  25-minute unit;[¹] Newport's time-block planning assigns every block a fixed
  allocation instead of reacting to an open list;[²] and Parkinson's Law is the
  reason for a *hard* cap — planning expands to fill whatever time you give it.[³]
  15 is small enough that bloat can't creep in. Pick your own number, but cap it.

## The 15 minutes

The trigger fires the affordance. The 15 minutes is *your* work. What you do in it:

### 0-3 min: Carry-over decisions

Each carry-over from last cycle: keep / descope / push to Backlog.

"Keep" requires asking why it slipped. If the answer is "I underestimated," that's data — re-estimate at correct value before adding to this cycle.

"Descope" means the cycle was over-committed. Move out.

"Push to Backlog" means it doesn't need to be this week.

### 3-8 min: Triage pass

Process Triage items > 48h. For each:
- Cancel if not worth keeping
- Snooze if not actionable now
- Promote to Todo if it commits this week
- Promote to Backlog otherwise

Aim: empty the > 48h bucket entirely. Newer Triage items stay for tomorrow.

### 8-12 min: Cycle commit

Pick at most 5 issues for the cycle. Verify:
- Each has an estimate
- Max 2 are P0+P1
- No 16-pointers (those get a `breakdown` label and exit)

Commit by changing each issue's state to Todo and `cycleId` to active cycle.

### 12-15 min: Set lead project

Choose one push project as the cycle's lead (see [WIP cap with continuous-area exemption](../01-linear-as-load-bearing-pm/wip-cap-with-continuous-areas.md)).

The chosen issues should mostly come from this lead. Other push projects' issues stay in Backlog this week.

## If it takes more than 15 minutes

The cause is almost always:
- **Vague tickets** — no AC, no estimate, no clear scope. You're spending the 15 minutes writing tickets, not planning. Fix the ticket standard ([ticket-standard](../01-linear-as-load-bearing-pm/ticket-standard.md)).
- **Over-committed plan** — trying to squeeze 8 issues into a 5-cap. Descope at the gate.
- **Skipped previous Friday's retro** — you don't have the context. Fix the Friday cadence.

If the ritual takes 45 minutes consistently, it'll stop happening. Cap at 15.

## When you start skipping it

Two skipped Mondays in a row is the signal, not noise
([ritual-fatigue](./ritual-fatigue.md)). The first move is **shrink**, not
willpower: drop the full plan to a 3-item check (carry-over? stale Triage? one
lead project?) and let the rest go. The `monday-plan` telemetry (skip streak,
time-to-done) is your early-warning detector. If the skip streak survives
shrinking, the ritual may be ceremony — retire it and see what you actually miss.

## Field-tested gotchas

**The script blocks on `linearis` slow calls.** First Monday after a long absence (no cache) can be 30+ seconds. Pre-warm by running it on Sunday night.

**`rbw` may need unlocking after machine sleep.** First invocation of the morning may fail. Manual unlock then retry; or have the script `rbw unlock` interactively if needed.

**Browser tab proliferation.** The script opens "This week" every Monday. Over months, you accumulate tabs. Add `--new-window` or close existing Linear tabs first.

**`tmux send-keys` to a pane that doesn't exist.** Guard with `tmux has-session`.

**Saved view URLs change.** If you rename a saved view in Linear, the URL changes. The script's URLs break silently. Use canonical view identifiers via GraphQL.

**Plan from before your week.** Most useful if you also did a Friday retro the prior week. Without the Friday retro, Monday is harder because you don't have the wrap.

## Innovative pattern: pre-Monday Sunday eve

Run the script Sunday evening too (separate launchd plist, fires at 19:00 Sunday). Write the worksheet but skip the browser open and the ntfy.

Monday morning, the worksheet is already there. Optional — only for people who like a head start.

## Innovative pattern: auto-cancel staleware

A weekend cleanup script that:
- Cancels stale Triage items (created > 14 days ago, never moved)
- Snoozes stale Backlog items (untouched > 90 days) to wake date +90 days

Runs Sunday evening. Monday's plan sees a cleaner state.

## Innovative pattern: ritual telemetry

Each Monday plan run logs:
- Time it took (script start to "human said done")
- Carry-over count
- Triage count processed
- Issues committed to cycle

Weekly review of telemetry reveals patterns:
- "Carry-over consistently 3+" → I'm over-committing each week. Reduce the cap.
- "Triage processed jumps on Mondays after Fridays I skipped" → Friday discipline matters.
- "Time consistently > 30 min" → ticket standard slipping.

## Related

- [launchd over cron](./launchd-over-cron.md) — what fires this
- [ntfy notifications](./ntfy-notifications.md) — what pushes to phone
- [Chapter 01 — Cycles and rituals](../01-linear-as-load-bearing-pm/cycles-and-rituals.md) — the cycle structure this plans into
- [Friday retro](./friday-retro.md) — the companion ritual
- [ritual-fatigue](./ritual-fatigue.md) — when the Monday plan starts getting skipped

---

[1]: https://www.pomodorotechnique.com/ — Pomodoro Technique, fixed 25-minute work unit — accessed 2026-05-31
[2]: https://calnewport.com/deep-habits-the-importance-of-planning-every-minute-of-your-work-day/ — Cal Newport, time-block planning — accessed 2026-05-31
[3]: https://en.wikipedia.org/wiki/Parkinson%27s_law — Parkinson's Law: work expands to fill the time available (orig. C. N. Parkinson, The Economist, 1955) — accessed 2026-05-31
