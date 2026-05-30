# Calendar-vendor-neutrality

> The time layer of your stack must work without depending on Google Calendar, Apple Calendar, iCloud, or Fantastical.

This is a strong opinion. You may not share it. Read this anyway and decide.

## The problem

The default solo-dev "calendar" recommendation is Google Calendar + Fantastical (on Mac) or Apple Calendar (on iOS). This makes your time layer dependent on:

1. **Two big-tech vendors** — Google and Apple. If you're trying to reduce dependency on either, you can't recommend them.
2. **One ecosystem (Apple)** for the prettiest UI — Fantastical is Mac/iOS only. If your phone is GrapheneOS / non-Apple, Fantastical doesn't reach you.
3. **Vendor lock-in for what should be open data** — your schedule is a list of timestamps and strings. It shouldn't require an API key.

If you accept those, GCal + Fantastical is fine. If you don't, you need an alternative architecture.

## The pattern that holds

| Layer | Tool | Why |
|---|---|---|
| Scheduled time-blocks | `schedule.md` (plaintext) | Diff-able, grep-able, scriptable. No app. |
| Reminders / time triggers | `launchd` (macOS) or `cron` (Linux) | OS-level. Doesn't need a sync vendor. |
| Push notifications | `ntfy` (self-hosted or `ntfy.sh`) | Works on any phone with the ntfy app, including GrapheneOS. No Apple Push, no FCM. |
| External calendar visibility | iCal `.ics` export | Read-only subscription URL anything understands |
| Hard deadlines | PM tool due dates (Linear, Plane, etc.) | The PM tool already knows what's due |
| CalDAV when needed | Proton Calendar (has CalDAV in beta) | Encrypted, EU-hosted, no vendor lock |

## Concrete recipe

1. **Plaintext schedule** at `~/schedule.md` (or `~/Documents/schedule.md`, anywhere syncable). Format:
   ```
   ## 2026-06-03 Mon
   09:00 — Monday planning (PM tool view)
   10:00 — Deep work block 1 (focus on <ticket-id>)
   13:00 — Submission window: <company-X>
   16:00 — Friday-style midweek check-in
   ```
2. **launchd** (or cron) plists that fire scripts at chosen times. See [Chapter 04](../04-rituals-and-triggers/launchd-over-cron.md) for why `launchd` over `cron` on macOS — `launchd` handles missed runs when the machine is asleep; cron silently drops them.
3. **ntfy notifications** for each ritual trigger. The script that runs at 09:00 Monday opens your PM tool's planning view *and* pushes an ntfy notification to your phone. If you're at the desk, you see the view; if you're not, you get the push.
4. **iCal export** for things that need to be visible to other people / other tools. Convert `schedule.md` to `.ics` with a small script. Host the `.ics` file anywhere (local web server, Github Pages, your `nginx`); subscribe from any client.
5. **PM tool due dates** for hard deadlines. The PM tool is already in your flow; reuse it.

## What this rules out

- **Google Calendar MCP** — even though it may be enabled in your agent config. The MCP being present ≠ the tool being acceptable.
- **Fantastical, BusyCal, Things 3** — Apple ecosystem lock-in.
- **iCloud Calendar** — same.
- **Reclaim, Motion, Cron (Notion Calendar)** — built on top of GCal.

## What this rules in

- **Plaintext** — the substrate everything else converts to/from.
- **OS-level scheduling** — launchd / cron / systemd timers.
- **Self-hostable push** — ntfy works for solo dev volume; bigger volume justifies running your own ntfy server.
- **iCal export** — universally readable subscription format.

## Why this is opinionated

This is *not* a technical claim that GCal can't work — it can. It's a constraint that if your broader goal is "reduce dependency on Google and Apple," then your calendar layer can't undermine that goal.

If you don't share that goal, your time layer can be different. Use GCal + Fantastical, get the prettier UI. But the rest of this playbook still works.

## Related

- [Chapter 04 — Rituals and triggers](../04-rituals-and-triggers/) — full launchd / ntfy / plaintext recipes
- [`degoogle` topic on GitHub](https://github.com/topics/degoogle) — adjacent reading on dependency reduction
