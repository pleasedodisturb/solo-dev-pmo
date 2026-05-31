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

## CalDAV & calendar options in 2026

The "CalDAV when needed" row above names Proton, but that now needs a correction: **Proton and Tuta deliberately don't offer full CalDAV** — they end-to-end-encrypt everything and accept the interoperability cost.[¹][²] If you actually need CalDAV sync, the realistic 2026 options:

| Option | Vendor-neutral | Plaintext | CalDAV | Notes |
|---|---|---|---|---|
| `schedule.md` + launchd + ntfy + `.ics` (this playbook) | yes | yes | export-only | the default pick; no server to run |
| **Radicale**[³] | yes (self-host) | yes (plain files, no DB) | yes | ~90% lighter than Nextcloud; great for one user; no sharing/multi-cal |
| **Nextcloud Calendar**[⁴] | yes (self-host) | no (DB) | yes | full groupware + web UI; heavier |
| **Fastmail**[²] | no (hosted) | no | yes (best reliability) | paid, AU jurisdiction |
| **Proton / Tuta Calendar**[¹][²] | yes (privacy) | no | no (E2EE, no full CalDAV) | encrypted but not interoperable |
| **GCal + Fantastical** | no | no | yes | the thing this chapter avoids |

For a CLI-first plaintext workflow, **vdirsyncer + khal** front-ends any CalDAV server: vdirsyncer syncs each event to a local single-`.ics` plain-text file, khal reads them, `todoman` handles tasks, and `khalel`/`khalorg` bridge to org-mode.[⁵] That's the "plaintext schedule" idea above, with two-way CalDAV sync bolted on.

## Why ntfy specifically (the GrapheneOS test)

The push layer is the load-bearing part of vendor-neutrality, because notifications are where Google/Apple usually re-enter through the back door. On a de-Googled phone (GrapheneOS), there are two ways to get push: run **Sandboxed Google Play** so apps can reach FCM, or use **UnifiedPush**, the open push protocol that needs no Google services.[⁶] ntfy is a UnifiedPush distributor — which is exactly why it's the pick: it delivers to a de-Googled phone without FCM or Apple Push.[⁶] If your push tool only speaks FCM/APNs, your "vendor-neutral" stack has a Google/Apple dependency hiding in the notification path.

## Alternatives (the honest "why not the easy thing")

The easy thing is GCal + Fantastical, and it works — better UI, zero setup, reliable push. We reject it only because of the stated goal (reduce Google/Apple dependency); if you don't hold that goal, take the easy thing and the rest of the playbook is unaffected (see "Why this is opinionated" above). What the privacy-community consensus confirms: there's no single drop-in that's simultaneously pretty, hosted, free, *and* vendor-neutral — Privacy Guides itself only lands on Tuta/Proton (E2EE, no CalDAV) and points CalDAV-needers at Fastmail.[¹][²] The plaintext-first stack is how you keep all four properties, at the cost of a little assembly.

## Sources

[1]: https://www.privacyguides.org/en/calendar/ — Privacy Guides calendar recommendations (Tuta, Proton; E2EE-vs-CalDAV trade-off). Accessed 2026-05-31.
[2]: https://blog.mailfence.com/proton-calendar-support-caldav/ — Proton Calendar lacking CalDAV; Fastmail as the CalDAV-reliable option. Accessed 2026-05-31.
[3]: https://radicale.org/ — Radicale, lightweight file-based CalDAV/CardDAV server (no database). Accessed 2026-05-31.
[4]: https://nextcloud.com/athome/ — Nextcloud Calendar (CalDAV + web UI, full groupware). Accessed 2026-05-31.
[5]: https://github.com/pimutils/khal — khal CLI calendar (syncs via vdirsyncer; plain `.ics` files); khalorg/khalel bridge to org-mode. Accessed 2026-05-31.
[6]: https://unifiedpush.org/ — UnifiedPush (Google-free push protocol); ntfy is a UnifiedPush distributor and works on GrapheneOS. Accessed 2026-05-31.

## Related

- [Chapter 04 — Rituals and triggers](../04-rituals-and-triggers/) — full launchd / ntfy / plaintext recipes
- [`degoogle` topic on GitHub](https://github.com/topics/degoogle) — adjacent reading on dependency reduction
