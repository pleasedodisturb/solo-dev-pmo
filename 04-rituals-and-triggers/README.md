# 04 — Rituals and triggers

> Rituals that depend on you remembering will fail. Rituals fired by the system will hold.

This chapter is the affordance layer for time. Monday planning, Friday retro, morning Triage — all of it triggered mechanically, not by willpower.

## What this chapter covers

| Section | What it solves |
|---|---|
| [launchd over cron](./launchd-over-cron.md) | Time triggers that survive sleep and machine restarts |
| [ntfy notifications](./ntfy-notifications.md) | Push without Apple/Google. Works on GrapheneOS. |
| [Plaintext time layer](./plaintext-time-layer.md) | `schedule.md` as the canonical schedule. iCal export when needed. |
| [Monday planning ritual](./monday-planning.md) | Trigger + script that prepares your week |
| [Friday retro ritual](./friday-retro.md) | Companion to Linear Project Update reminders |

## The framing

Solo dev rituals fail in one of two ways:
1. **You forget** — the ritual depended on willpower
2. **The trigger fired but you ignored it** — the ritual wasn't compelling

This chapter fixes #1 mechanically. #2 requires designing the ritual to be small enough that you don't ignore it (15 minutes max).

## The four required rituals

If you adopt this playbook end-to-end:

1. **Morning Triage** — daily, 09:00, 10 minutes. Process Triage state.
2. **Monday planning** — weekly, Monday 09:00, 15 minutes. Pick cycle, commit issues.
3. **Friday retro** — weekly, Friday 16:00, 5 minutes. Linear Project Update + brief reflection.
4. **Monthly cooldown** — quarterly (every 4th cycle), 1 cycle. Tech debt, convention sweep.

Each has a mechanical trigger (launchd) + ntfy push + opens a saved view + runs a small script.

## The pattern

```
launchd plist  ──fires at scheduled time──>  shell script
                                              │
                                              ├─→ ntfy push to phone
                                              ├─→ open browser to saved view
                                              ├─→ print summary to tmux pane
                                              └─→ optionally: write a worksheet to ~/today.md
```

The launchd plist is the time guarantee. The shell script is the workflow. Both checked into your dotfiles (or `infra/launchd-rituals/`).

## What launchd gives you that cron doesn't

The single most important reason for `launchd` over `cron` on macOS: **launchd handles missed runs.**

If your Mac is asleep at 09:00 Monday (laptop in a bag), `cron` silently drops the 09:00 job. `launchd` (configured with `RunAtLoad`) fires it as soon as the machine wakes.

For laptops that sleep most of the night, this is the difference between rituals firing reliably and missing 50% of weeks.

See [launchd-over-cron](./launchd-over-cron.md) for the configuration.

## What ntfy gives you that Apple Push / FCM don't

- **Phone-agnostic** — works on GrapheneOS, vanilla Android, iOS via the ntfy app
- **Self-hostable** — run on your VPS if you want, or use `ntfy.sh` for personal volume
- **No vendor lock** — your subscriptions don't depend on Apple/Google
- **CLI-first** — `curl -d "Monday plan ready" ntfy.sh/<your-topic>` and you're done
- **Topic-based** — one topic per ritual = differentiated badges on your phone

See [ntfy-notifications](./ntfy-notifications.md) for setup.

## What plaintext time gives you

A `schedule.md` file (or directory of dated markdown files) is your canonical schedule. From there:
- iCal export (`.ics` file) for read-only subscription
- Linear due dates for hard deadlines
- launchd plists for trigger scheduling

You never enter time in 5 places. You enter it in one (`schedule.md`), and everything else derives.

## How this connects to ADHD-aware design

From [00 — ADHD-aware design](../00-principles/adhd-aware-design.md):
- *"Ritual triggers, not ritual willpower."* — This chapter is that affordance.
- *"WIP limits enforced by the system."* — The Monday script reads cycle count, refuses to add over cap.
- *"Single source of truth."* — `schedule.md` + Linear due dates = no time spread across 5 tools.

## Related

- [Chapter 00 — Calendar neutrality](../00-principles/calendar-neutrality.md) — why plaintext time
- [Chapter 01 — Cycles and rituals](../01-linear-as-load-bearing-pm/cycles-and-rituals.md) — what the Monday script does to Linear
- [Chapter 06 — Wrap and resume](../06-session-discipline/wrap-and-resume.md) — session-level rituals
