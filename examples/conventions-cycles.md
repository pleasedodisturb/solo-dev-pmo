# Cycle Conventions (example)

> A `conventions/cycles.md` example. Drop in your meta-PM repo at `conventions/cycles.md` and adapt to your tool.

State and cycle semantics that all rituals depend on.

**Status:** locked v1.0 (<date>).

**Authority:** This file is the source of truth for "how do cycles work in our system?"

---

## 1. Cadence

- **1-week cycles, Monday → Sunday.** Not 2 weeks (Linear Method default).
- **Cooldown cycle every 4th week.** Tech debt + convention sweep + post-mortem.
- **Auto-roll on.** Incomplete `In Progress` work cascades into next cycle automatically.
- **Auto-assign-completed on.** Completed work auto-attributes to current cycle.
- **Lock to active = off.** Issues span cycles when needed.

Why 1-week (not 2):
- Solo + ADHD needs tighter feedback loop than 2 weeks
- 26 feedback loops per year instead of 13
- 1-week chronic underestimation discovered week 1, corrected week 2

---

## 2. Cycle WIP cap

- **≤5 issues** per cycle
- **Max 2 of P0+P1** combined

Mechanical enforcement:
- Saved view `Cycle = current AND Assignee = me`; count > 5 = red
- Monday planning script refuses to add when at cap

---

## 3. Estimate scale

- **Exponential (1, 2, 4, 8, 16)** — not Fibonacci, not T-shirt
- 1 = ~1h, 2 = ~3h, 4 = ~half-day, 8 = ~full day, **16 = BREAK IT UP**
- Required on cycle entry; saved view `Cycle = current AND Estimate is empty` should be empty

---

## 4. WIP cap on projects (Layer 1: project tier)

- **≤3 push projects in `Started` status**
- **Continuous-area projects are exempt** (operational maintenance, curation)
- Push projects have an Initiative; continuous-area do not

Continuous-area exempt class (example for your stack):
- Operational support (OS setup, password manager, dotfiles, network)
- Always-on maintenance (any awesome-* / curation projects)
- Personal finance
- Ritual systems

---

## 5. Project Update reminders

- **Friday 16:00 weekly** (Linear ships this natively for Project Updates)
- Two follow-up nudges 1 and 2 working days later if skipped — **don't disable**
- 3-option health indicator (On Track / At Risk / Off Track) + 1-line note
- This IS the Friday retro; no separate retro ritual needed

---

## 6. Snooze semantics

- **`snoozedUntilAt` = deliberate hibernation marker**, not soft reminder
- Bulk-snooze most of Backlog to 90 days for solo workspaces > 200 issues
- **Hands off snoozed items** — don't bulk un-snooze
- Filter snoozed OUT of default views (`snoozedUntilAt is null`)

---

## 7. Triage workflow

- Triage state = THE inbox (not Inbox notifications)
- API-created tickets bypass Triage by default — set `stateId` explicitly for capture flows
- Triage processed daily (10 min cap), not weekly

---

## Changelog

- **v1.0 (<date>):** initial lock from `audits/<date>-cycle-cadence-decision.md`.
