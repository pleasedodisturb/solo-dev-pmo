# Plaintext time layer

> Your schedule lives in a markdown file. iCal export when needed. Calendar apps consume; don't author there.

## The recipe

A single `schedule.md` (or directory of dated markdown files) is the canonical schedule. Format you control. Edit in any text editor.

```markdown
# Schedule

## Week of 2026-06-01

### Monday
- 09:00 — Monday planning (15m)
- 09:30 — Deep work block 1 (focus: Linear cycle plan)
- 12:00 — Lunch
- 13:00 — Submission window: Company X
- 16:00 — End focus, review what landed

### Tuesday
- 09:00 — Triage pass (10m)
- 09:30 — Deep work block (focus: G-1234 implementation)
...

### Friday
- 09:00 — Triage pass (10m)
- 15:00 — Prep for Project Update
- 16:00 — Linear Project Update reminder fires
- 16:30 — Friday retro reflection (5m)
```

That's it. No app. No vendor.

## Why plaintext

- **Diff-able.** `git diff schedule.md` shows what changed week to week.
- **Grep-able.** "When did I last block for X?" — `grep -B1 X schedule.md`.
- **Scriptable.** Convert to `.ics`, push to ntfy, sync to anywhere with a regex.
- **Editor-native.** Any text editor edits it. Your existing keybindings work.
- **No sync vendor.** Syncthing / dotfiles / git move it between machines.
- **No lock.** Schedule data is not held hostage by any service.

## What plaintext doesn't give you

- A pretty calendar UI
- Drag-and-drop for time blocks
- Smart conflict detection across multiple calendars
- Native phone calendar app integration without an extra step

If those matter, plaintext isn't for you. Use Fantastical or GCal. But understand the trade.

## iCal export when needed

For visibility from a phone calendar app (or sharing with someone), generate an `.ics` from `schedule.md`:

```python
# Pseudocode for plaintext → ics
import icalendar
cal = icalendar.Calendar()
for entry in parse_schedule("schedule.md"):
    ev = icalendar.Event()
    ev.add("summary", entry.title)
    ev.add("dtstart", entry.start)
    ev.add("dtend", entry.end)
    cal.add_component(ev)
with open("schedule.ics", "wb") as f:
    f.write(cal.to_ical())
```

Host the `.ics` at any URL. Subscribe from any calendar app (Proton Calendar, Tutanota, Apple Calendar, GCal — they all consume `.ics` subscriptions).

Subscription is one-way (read-only): your phone calendar shows your schedule but you edit in `schedule.md`.

## Hosting the `.ics`

Options:

**a. GitHub Pages / static host:**
```bash
git add schedule.ics
git commit -m "G-1234: weekly schedule update"
git push
# Phone calendar subscribes to https://<user>.github.io/<repo>/schedule.ics
```

Visible to anyone with the URL. Don't put sensitive info in event titles.

**b. Local nginx:**
```nginx
server {
  listen 443 ssl;
  server_name schedule.<your-domain>;
  
  root /var/www/schedule;
  
  location / {
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;
  }
}
```

Auth-gated. More privacy.

**c. Just a script:**
```bash
python schedule-to-ics.py > /Volumes/syncthing/schedule.ics
```

Sync the file to your phone via Syncthing; phone calendar reads from local file.

## Hard deadlines: PM tool due dates

Plaintext is great for time-blocks. For hard deadlines (this submission is due 2026-06-15), use your PM tool's due date field.

The PM tool is already in your flow. Don't split deadlines between `schedule.md` and Linear.

## Cycles: 1 file per quarter

Once `schedule.md` gets too long (> 6 weeks of weekly headers), split:
```
schedules/
  2026-Q2.md
  2026-Q3.md
  2026-Q4.md
```

The `.ics` export script reads all files in `schedules/` and generates a combined `.ics`.

## Templates

A template per common day:

```markdown
### template: focus-day
- 09:00 — Triage pass (10m)
- 09:30 — Deep work block 1 (focus: <ticket>)
- 12:00 — Lunch
- 13:00 — Deep work block 2 (focus: <ticket>)
- 16:00 — End focus, review
```

Copy-paste into the current week, fill the `<ticket>` placeholders. 30 seconds to plan a day.

## Field-tested gotchas

**Calendar subscriptions cache aggressively.** A change in `schedule.md` may not propagate to your phone calendar for 6+ hours. For urgent changes, use ntfy instead.

**Different calendar apps render `.ics` differently.** Test on your phone before depending on visual layout.

**Timezone bugs.** Always specify timezone explicitly in `.ics` events. UTC + your local conversion is the standard pattern.

**Recurring events.** `.ics` `RRULE` syntax is verbose. For weekly recurring (Monday plan, Friday retro), generate explicit dated events instead — easier to debug.

**Editor renders schedule.md poorly.** If your editor doesn't handle long markdown well, split into per-week files (`schedules/2026-W22.md`).

## Innovative pattern: parse-and-act

A daily script reads today's entries from `schedule.md` and:
- Sets a tmux pane title to show "current block"
- ntfys 5 minutes before each entry starts
- Tags entries that pass without you touching the tmux session as "missed"

The `schedule.md` becomes interactive without leaving plaintext.

## Innovative pattern: weekly review against schedule

Friday retro script:
```bash
# What was planned vs. what happened?
TODAY=$(date +%Y-%m-%d)
WEEK_START=$(date -v -mon +%Y-%m-%d)
grep -A 1 "$WEEK_START" schedule.md  # planned
git log --since="$WEEK_START" --until="$TODAY" --oneline  # actual commits
linearis issues list --closed-since "$WEEK_START"  # actual ticket closures
```

Pipes into a "this week: plan vs. actual" summary you read in 2 minutes.

## Related

- [00 — Calendar neutrality](../00-principles/calendar-neutrality.md) — why plaintext
- [launchd over cron](./launchd-over-cron.md) — what reads the schedule and fires triggers
- [Friday retro](./friday-retro.md) — the weekly review against plan
