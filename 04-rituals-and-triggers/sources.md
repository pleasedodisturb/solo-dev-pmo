# Sources — Chapter 04: Rituals and triggers

Chapter-root reference file: bibliography + version matrix + field-test notes.
Bibliography rollup for the chapter. All accessed **2026-05-31**. Class per the
[SEARCH-PLAYBOOK](../.planning/SEARCH-PLAYBOOK.md) weighting: ★★★★★ primary docs,
★★★★ vendor/eng blog or peer-reviewed, ★★★ practitioner/adjacent, ★★ community.

> **Methodology caveat.** This pass ran in a Linux cloud container; many vendor
> doc hosts (Apple, ntfy.sh, IETF, freedesktop, Linear, Basecamp) returned HTTP
> 403 to the automated fetcher. Where a primary page could not be fetched
> directly, claims were verified against upstream **source files** on
> `raw.githubusercontent.com` (the actual sources of those doc sites) or
> corroborated across multiple search extracts. Items resting only on secondary
> extraction are noted in the per-phase [RESEARCH-LOG](../.planning/04-rituals-and-triggers/RESEARCH-LOG.md).

## Scheduling: launchd / systemd / cron / GitHub Actions

- ★★★★★ `launchd.plist(5)` (Apple OSS source) — https://raw.githubusercontent.com/apple-oss-distributions/launchd/main/man/launchd.plist.5 — RunAtLoad/StartCalendarInterval/KeepAlive semantics; missed-run coalescing on wake.
- ★★★★★ `systemd.timer(5)` — https://raw.githubusercontent.com/systemd/systemd/main/man/systemd.timer.xml — `OnCalendar=`, `Persistent=` single catch-up.
- ★★★★★ `systemd.time(7)` — https://raw.githubusercontent.com/systemd/systemd/main/man/systemd.time.xml — calendar-event syntax + shorthand normalization.
- ★★★★★ GitHub Actions — events that trigger workflows — https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows — `schedule`: 5-min floor, high-load delay/drops, default-branch-only, 60-day auto-disable.
- ★★★★ ArchWiki — systemd/Timers — https://wiki.archlinux.org/title/Systemd/Timers — `Persistent=`/`RandomizedDelaySec=`.
- ★★★★ ArchWiki — systemd/User — https://wiki.archlinux.org/title/Systemd/User — `loginctl enable-linger`.
- ★★★★ Debian — `systemd.cron(7)` — https://manpages.debian.org/testing/systemd-cron/systemd.cron.7.en.html — `PERSISTENT=` crontab translation; anacron contrast.
- ★★★ launchctl reference (ss64) — https://ss64.com/mac/launchctl.html — load/unload legacy, bootstrap/bootout/print/enable current.
- ★★★ launchd.info — https://www.launchd.info/ — SIGTERM→SIGKILL after ExitTimeOut.
- ★★★ jujens.eu, "Systemd Timers" (2025) — https://www.jujens.eu/posts/en/2025/Feb/01/systemd-timers/ — anacron min-interval vs systemd wall-clock.
- ★★★ "Where is my PATH, launchD?" — https://lucaspin.medium.com/where-is-my-path-launchd-fc3fc5449864 — bare launchd PATH.
- ★★★★★ Apple Developer Forums — FDA from a launchd daemon — https://developer.apple.com/forums/thread/661178 — TCC GUI-session prompts, code-signing; also thread/804548 (Apple-Silicon-vs-Intel FDA divergence).
- ★★★ hackyboiz — macOS SIP bypass (2025) — https://hackyboiz.github.io/2025/05/11/clalxk/MacOS_SIP-Bypass_en/ — SIP strips injected env vars.
- ★★ systemd issue #24984 (counter-evidence) — https://github.com/systemd/systemd/issues/24984 — Persistent timer can miss a run.

## Push notifications: ntfy / UnifiedPush / GrapheneOS / Focus

- ★★★★★ ntfy repo — https://github.com/binwiederhier/ntfy — Apache-2.0; hosted or self-host.
- ★★★★★ ntfy issue #1167 — https://github.com/binwiederhier/ntfy/issues/1167 — **free-tier limits: 250 msg/day, 5 emails/day, 2 MB/attachment, no reserved topics** (the flagged-risk check: free tier is alive).
- ★★★★★ ntfy `docs/config.md` — https://raw.githubusercontent.com/binwiederhier/ntfy/main/docs/config.md — self-host config; iOS `upstream-base-url: https://ntfy.sh` requirement.
- ★★★★★ ntfy `docs/publish.md` — https://raw.githubusercontent.com/binwiederhier/ntfy/main/docs/publish.md — priority 1–5 → Android channels.
- ★★★★★ ntfy install docs — https://docs.ntfy.sh/install/ — single-binary self-host, TLS/ACME.
- ★★★★★ ntfy issue #1680 — https://github.com/binwiederhier/ntfy/issues/1680 — iOS Focus/DnD piercing (priority 4/5) **not yet fully wired** (don't promise it).
- ★★★★★ UnifiedPush — ntfy distributor — https://unifiedpush.org/users/distributors/ntfy/ (+ /users/apps/) — distributor/connector model, supported apps.
- ★★★★★ GrapheneOS usage — https://grapheneos.org/usage — sandboxed Play/FCM vs UnifiedPush; battery exception.
- ★★★★★ Apple — `UNNotificationInterruptionLevel` — https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel — passive/active/timeSensitive/critical.
- ★★★★★ Apple — Focus notification allow/silence — https://support.apple.com/guide/iphone/allow-or-silence-notifications-for-a-focus-iph21d43af5b/ios.
- ★★★★★ Apprise — https://github.com/caronc/apprise — BSD-2 dispatch library, 100+ backends.
- ★★★★★ Pushover pricing — https://pushover.net/pricing — one-time ~$5/platform. Gotify — https://gotify.net/ (MIT, no first-party iOS).
- ★★★ ntfy behind Cloudflare Tunnel — https://noted.lol/ntfy/.

## Plaintext time / iCalendar

- ★★★★★ RFC 5545 — https://datatracker.ietf.org/doc/html/rfc5545 — §3.1 folding, §3.3.5 DATE-TIME/TZID, §3.6.1 VEVENT required props, §3.8.5.3 RRULE, §3.8.7.2 DTSTAMP-UTC.
- ★★★★★ RFC 7986 — https://datatracker.ietf.org/doc/html/rfc7986 — §5.7 REFRESH-INTERVAL, NAME/COLOR.
- ★★★★★ Microsoft — X-PUBLISHED-TTL (MS-OXCICAL) — https://learn.microsoft.com/en-us/openspecs/exchange_server_protocols/ms-oxcical/1fc7b244-ecd1-4d28-ac0c-2bb4df855a1f.
- ★★★★★ `icalendar` (PyPI) — https://pypi.org/project/icalendar/ — 7.1.2 (2026-05-22), Production/Stable; cf. `ics` https://pypi.org/project/ics/ (0.7.3 beta).
- ★★★★★ org-mode iCalendar export — https://orgmode.org/manual/iCalendar-Export.html.
- ★★★★★ vdirsyncer config — https://vdirsyncer.pimutils.org/en/stable/config.html — two-way CalDAV; Fastmail tested. khal — https://khal.readthedocs.io/.
- ★★★★★ Fastmail CalDAV — https://www.fastmail.help/hc/en-us/articles/360058752754 . Proton (no CalDAV) — https://proton.me/support/calendar.
- ★★★★ Taskwarrior `task export` — https://taskwarrior.org/docs/commands/export/ . todo.txt — https://github.com/todotxt/todo.txt.
- ★★★ Google subscribed-ICS refresh ~12–24h + `#fragment` trick — https://gist.github.com/gene1wood/02ed0d36f62d791518e452f55344240d.
- ★★★ GitHub Pages cache-control — https://github.com/orgs/community/discussions/11884 ; raw staleness — https://news.ycombinator.com/item?id=34761284.
- ★★ Google Calendar silent-drop on bad UID — https://issuetracker.google.com/issues/137168934 . mdcal (representative md→ics) — https://github.com/RealOrangeOne/mdcal.

## Cadence defense & ritual fatigue

- ★★★★ Linear — how we built Project Updates (weekly, Friday) — https://linear.app/now/how-we-built-project-updates.
- ★★★★ Basecamp Shape Up — cooldown (2 wks per 6-wk cycle) — https://basecamp.com/shapeup.
- ★★★★ Pomodoro Technique (fixed 25-min unit) — https://www.pomodorotechnique.com/.
- ★★★★ Cal Newport — time-block planning — https://calnewport.com/deep-habits-the-importance-of-planning-every-minute-of-your-work-day/.
- ★★★ Parkinson's Law (locator) — https://en.wikipedia.org/wiki/Parkinson%27s_law (orig. The Economist, 1955).
- ★★★ Atlassian retrospective play (30–60 min team retro) — https://www.atlassian.com/team-playbook/plays/retrospective.
- ★★★★ BJ Fogg — Fogg Behavior Model (B=MAP) — https://www.behaviormodel.org/.
- ★★★★ James Clear — habit tracker / "never miss twice" — https://jamesclear.com/habit-tracker ; habit stacking — https://jamesclear.com/habit-stacking.
- ★★★★ Alarm fatigue (NCBI Bookshelf) — https://www.ncbi.nlm.nih.gov/books/NBK555522/ — 85–99% of ICU alarms false/insignificant.
- ★★★★ Mark, Gudith & Klocke, "The Cost of Interrupted Work" (CHI '08) — https://dl.acm.org/doi/10.1145/1357054.1357072.
- ★★★★ EF/cognitive-scaffolding interventions in ADHD (PMC) — https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8505290/.
- ★★★ ADHD routines without burnout — https://greaterocchadd.org/helping-adults-with-adhd-build-consistent-routines-without-burnout/.

## Honesty flags carried into the chapter

- **ntfy free tier** is confirmed alive (issue #1167) — the "free push" framing ships.
- **Exact ntfy paid prices** not printed — third-party sources conflict ($6/$12/$25 vs $5/$10/$20); verify in the live upgrade dialog.
- **ntfy priority-5 piercing iOS Focus** is *not* promised — per issue #1680 it isn't wired yet; the manual Focus allowlist is the reliable path.
- **"10-min / 16:00 / 5-min"** cadences are labeled author preference; only the *short-fixed-timebox*, *weekly-Friday (Linear)*, and *cooldown (Shape Up)* shapes are presented as defensible.
- **"Every-4th-week cooldown"** flagged as an adaptation of Shape Up's 2-weeks-per-6.
- **macOS plists / ntfy curl recipes** are written-but-untested against live launchd / a live device this pass; the `md→ics` exporter **was** run and verified.

## Version matrix (as of 2026-05-31)

| Tool | Version | Notes |
|---|---|---|
| macOS | Sequoia 15.x | launchd patterns target this; `bootstrap`/`bootout` since macOS 11 |
| systemd | distro-dependent | `Persistent=` available since v212; `OnCalendar=` widely shipped |
| ntfy server | 2.23.0 (2026-05-17) | Apache-2.0; hosted or self-host |
| ntfy Android app | ~1.24.0 | `io.heckel.ntfy`; F-Droid build ships without FCM — *version search-extracted, verify* |
| ntfy iOS app | App Store id 1625396347 | build number not confirmable from this env |
| `icalendar` (Python) | 7.1.2 (2026-05-22) | Production/Stable — **the one we use** |
| `ics.py` (Python) | 0.7.3 (2026-04-15) | beta, weak on recurrence — **not used** |
| Pushover | one-time ~$5/platform | proprietary; verify live |
| Gotify | (MIT) | no first-party iOS app |

## Field tests beyond the author

What has external validation, and what doesn't:

- **launchd / systemd missed-run-on-wake** — *vendor-documented behavior*, not an
  author claim: `launchd.plist(5)` and `systemd.timer(5)` both specify it. Solid.
- **ntfy + UnifiedPush on GrapheneOS** — corroborated beyond the author by multiple
  2026 GrapheneOS forum threads and independent practitioner write-ups
  (davd.io, eugenemdavis.net). The GrapheneOS path is field-confirmed.
- **org-mode `ox-icalendar`** — decades-proven text→iCalendar prior art; our
  `md→ics` exporter is a thin re-implementation of a well-trodden pattern.
- **Honest gap:** the specific *cadences* (10-min triage, 15-min Monday, 5-min
  Friday, every-4th-week cooldown) have **no independent field validation** beyond
  the author plus the general timeboxing / Shape Up literature. They are presented
  as defensible *shapes* with author-chosen *numbers*, not measured optima. The
  plists and curl recipes have not been independently re-run by a third party.

## What we'd change in 2026

- **Lead with `bootstrap`/`bootout`/`kickstart`**, not the legacy `load`/`unload`
  most older docs still show.
- **Use the `icalendar` library**, not a hand-rolled emitter or `ics.py` — it gets
  CRLF/folding/VTIMEZONE right, which is where Google silently drops feeds.
- **Add a GitHub Actions `on: schedule` option** for stateless/cloud rituals that
  shouldn't depend on the laptop being awake — a path the original macOS-only
  framing didn't offer.
- **Don't trust ntfy priority to pierce iOS Focus yet** — wire the manual Focus
  allowlist and revisit when ntfy issue #1680 ships.
- **Prefer UnifiedPush-first routing** on Android/GrapheneOS over a direct ntfy
  socket, for battery.
- **Emit `REFRESH-INTERVAL` + `X-PUBLISHED-TTL`** on published `.ics` rather than
  hoping clients poll on a useful interval.
