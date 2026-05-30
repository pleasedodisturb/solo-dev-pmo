# RESEARCH — Phase P04: Rituals and triggers

> **Stream goal:** ground the launchd-over-cron / ntfy / plaintext-time recipes in current macOS + cross-platform evidence, add Linux + GrapheneOS variants, and field-test the ritual cadences against other practitioners.

## 0. Scope

In:
- `04-rituals-and-triggers/README.md` + 5 sub-topic files (`friday-retro.md`, `launchd-over-cron.md`, `monday-planning.md`, `ntfy-notifications.md`, `plaintext-time-layer.md`)

Out:
- Linear Project Update mechanics (chapter 01)
- Wrap/resume per-session ritual (chapter 06; only cross-reference)
- Calendar-neutrality principle (chapter 00; only cross-reference)

## 1. What exists today

1,156 lines across 6 files. Existing depth:

- **launchd over cron** — RunAtLoad missed-run handling, plist examples
- **ntfy notifications** — phone-agnostic, self-hostable, CLI-first, topic-based
- **Plaintext time layer** — `schedule.md` canonical, iCal export, Linear due dates
- **Monday planning** — weekly trigger + script
- **Friday retro** — Linear Project Update + reflection

## 2. Honest gaps

- **macOS-only.** launchd is Apple. Linux readers get nothing. Need a `systemd-timer` variant (and BSD `cron`/`anacron` honest comparison).
- **The four required rituals** (Morning Triage, Monday plan, Friday retro, Monthly cooldown) are asserted with cadence numbers (09:00, 10 min, 15 min, etc.) — need to defend the cadences or honestly call them author preference.
- **No actual launchd plist shipped.** The chapter says "see launchd-over-cron for the configuration" but the example needs to be a copy-paste-ready plist for the four rituals.
- **No actual ntfy curl shipped.** Same.
- **No actual Monday script shipped.** Same.
- **Plaintext time layer + iCal export** — the export mechanism isn't shown. (Is it a Python script with `ics`? `pandoc`? A homemade Markdown-to-ICS?) Need a working recipe.
- **GrapheneOS angle is mentioned for ntfy** but not fleshed out (which app? UnifiedPush? configuration?).
- **Apple Watch + Focus Mode interaction** — many readers' phones run Focus Mode. How do ntfy alerts get through?
- **Calendar interop** — if you maintain `schedule.md`, how does it round-trip with Google Calendar / Fastmail / Proton for shared events with collaborators?
- **No mention of `caffeinate` / `pmset`** to keep machine awake for ritual firings if needed.
- **Ritual fatigue** — what happens when rituals start being ignored? Counter-tactics (lower cadence? change channel? remove the ritual?). No discussion.

## 3. Research questions

### launchd / systemd / cron portability

- **Q04.1** Current 2026 launchd documentation — any changes since Apple's archived doc? (RunAtLoad, StartCalendarInterval, KeepAlive semantics.)
- **Q04.2** Build a launchd → systemd-timer translation table. For each launchd plist in the chapter, show the systemd timer + service unit equivalent.
- **Q04.3** Is `anacron` the BSD/Linux equivalent for missed-run handling? Or has `systemd-timer` with `Persistent=true` superseded it? Document current best practice.
- **Q04.4** Cross-platform alternative: GitHub Actions on a schedule. When does running rituals via GitHub Actions (cron-style) beat a local plist? (Tradeoff: no local context, no machine-state coupling.)
- **Q04.5** macOS gotchas with launchd 2025–2026: SIP, code-signed plists, Apple Silicon idiosyncrasies. What still bites?

### ntfy and UnifiedPush

- **Q04.6** Current ntfy.sh status: hosted vs self-hosted, throughput limits, current Android/iOS app versions.
- **Q04.7** UnifiedPush ecosystem — how does ntfy interact with UP-compatible apps (Element, Tusky, Schildichat)? Worth a routing rule.
- **Q04.8** Apple Push Service (APNs) vs ntfy — true comparison for personal use cases.
- **Q04.9** GrapheneOS specifics: what's the recommended push setup as of 2026? (Sandboxed Play vs UnifiedPush vs ntfy direct.)
- **Q04.10** Self-hosted ntfy: minimum hardware (Raspberry Pi 4? VPS at $5/mo?), Cloudflare Tunnel setup, ACME cert.
- **Q04.11** Alternatives: Pushover, Pushbullet (still alive?), Gotify, Apprise, KaiOS Push. Build a small comparison.

### Plaintext time

- **Q04.12** What plaintext-time-layer practitioners exist? (org-mode agenda + `org-icalendar-export-to-ics`. Taskwarrior + `task export`. Plain markdown + custom scripts. `khal` calendar.) Cite each.
- **Q04.13** Specifically for `markdown → ics`: any standard tools? (`pandoc-ical`? `md2ics`? home-rolled is fine, but mention prior art.)
- **Q04.14** iCal subscription URL hosting — how does the author get from `~/schedule.md` to an `.ics` URL? (GitHub raw? S3? Local + ngrok? Cloudflare R2?)
- **Q04.15** What does Google Calendar do with malformed ICS? (Important — many "plaintext to calendar" scripts produce invalid ICS that GCal silently drops.)
- **Q04.16** RFC 5545 (iCalendar) gotchas — TZID handling, RRULE complexity, attendees. Cite spec.

### Ritual cadence defense

- **Q04.17** "10 minutes for Triage" — derived or asserted? Find published timeboxing literature (Pomodoro Technique, Mark Forster's autofocus, Deep Work cadences).
- **Q04.18** "Friday 16:00" specifically — Linear recommends this. Find their post. Also: research on day-of-week effects on retrospective quality.
- **Q04.19** "Every 4th week cooldown" — Shape Up. Already in chapter 01 cross-reference, but make sure consistent here.
- **Q04.20** What do ADHD practitioners say about ritual frequency? Daily is often too much; weekly is the sweet spot. Find a citation.

### Failure modes / ritual fatigue

- **Q04.21** Ritual fatigue literature — what does behavioral-design research say about when to retire / restructure a ritual?
- **Q04.22** Counter-tactics — lower cadence, swap channel, gamify, hard-reset. Best practitioner posts.
- **Q04.23** Notification fatigue — how many ntfy topics is too many? Phone screen-time literature.

### Apple Focus Mode / DnD interaction

- **Q04.24** How do ntfy alerts get through Apple Focus Mode and Android Do Not Disturb? Cite OS docs.
- **Q04.25** Specific Focus Mode setup recipe for ntfy (allowlist app, time-of-day rules).

## 4. Per-question source plan

| Q | Source class | Specific starting points |
|---|---|---|
| Q04.1, Q04.5 | Primary | Apple archived launchd docs. man launchd.plist. macOS Big Sur+ release notes for any deprecation. Recent HN/Mastodon on launchd quirks. |
| Q04.2–Q04.4 | Primary + practitioner | systemd.timer man page. systemd.exec man page. github.com/torvalds/linux Documentation. Anacron docs. github.com/features/actions schedule syntax. |
| Q04.6–Q04.10 | Primary + practitioner | ntfy.sh docs (Philipp Heckel's project). github.com/binwiederhier/ntfy. unifiedpush.org docs. grapheneos.org docs. r/GrapheneOS recent threads. |
| Q04.11 | Vendor docs | pushover.net help. gotify.net docs. apprise on github. |
| Q04.12–Q04.13 | Primary + practitioner | orgmode.org/manual/iCalendar-Export.html. taskwarrior.org docs. khal.readthedocs.io. github search for "md2ics". |
| Q04.14 | Practitioner | github raw URLs as ics — works but stale-cache problems. Cloudflare R2 + custom domain. ngrok for local testing. |
| Q04.15–Q04.16 | Primary | RFC 5545 (iCalendar). RFC 7986 (iCalendar extensions). github.com/google/calendar docs (limited). HN threads on "google calendar dropped my ics." |
| Q04.17 | Primary (book) | *The Pomodoro Technique* (Cirillo). *Deep Work* (Newport). Mark Forster's blog. |
| Q04.18 | Primary + practitioner | linear.app/now blog post on Project Updates. Atlassian retrospective guide. Spotify Tech Blog on retros. |
| Q04.19 | Primary | basecamp.com/shapeup (already in 01 brief — cross-reference). |
| Q04.20 | Academic + practitioner | ADDitude Magazine articles on routine design. CHADD on adult ADHD scheduling. r/ADHD megathreads on weekly vs daily. |
| Q04.21–Q04.23 | Academic + practitioner | BJ Fogg, *Tiny Habits*. James Clear, *Atomic Habits*. Screen-time research (Twenge, Pew Research). |
| Q04.24–Q04.25 | Primary | support.apple.com/Focus. developer.apple.com/notifications. Google support DnD docs. |

## 5. Output requirements

The agent updates files in `/Users/pleasedodisturb/Projects/playbooks/solo-dev-pmo/04-rituals-and-triggers/`:

1. **README.md** gains:
   - "Tested on macOS Sequoia (15.x)" line
   - One-line Linux pointer for readers on non-macOS
2. **`launchd-over-cron.md`** gains:
   - Four full, copy-paste-ready plists for the four rituals (Morning Triage 09:00 daily, Monday plan 09:00, Friday retro 16:00, Monthly cooldown)
   - macOS 2025–2026 gotchas section
   - launchd vs systemd-timer vs cron vs anacron comparison table
3. **New file:** `04-rituals-and-triggers/linux-systemd-variant.md` — systemd timer + service file equivalents for each ritual
4. **`ntfy-notifications.md`** gains:
   - The actual `curl` recipes for each ritual's push
   - Self-hosting walkthrough (min hardware, Tunnel/cert)
   - GrapheneOS setup section (UnifiedPush vs direct ntfy)
   - Apple Focus Mode allowlist recipe
   - Pushover / Gotify / Apprise alternatives table
5. **`plaintext-time-layer.md`** gains:
   - Working `md → ics` recipe (Python with `ics` library; show 30-line script)
   - Hosting recommendation (GitHub raw with cache caveat, or Cloudflare R2 + custom domain)
   - RFC 5545 gotcha list (TZID, RRULE edge cases, what GCal drops)
6. **`monday-planning.md`** + **`friday-retro.md`** each gain:
   - Cadence defense (cite Pomodoro / Newport / Linear / Shape Up)
   - Worked-example script (50-line bash showing what the ritual fires)
   - Ritual fatigue contingency (when to retire / restructure)
7. **New file:** `04-rituals-and-triggers/ritual-fatigue.md` — short essay on detecting and countering ritual fatigue
8. **New file:** `04-rituals-and-triggers/sources.md` — bibliography

Constraints:
- Don't recommend macOS-only when a Linux equivalent exists
- Don't recommend paid push (Pushover) when ntfy free works
- Don't ship plists with hardcoded usernames — use `<USER>` placeholders
- Scripts that touch Linear / Bitwarden / etc. must reference the secrets pattern from chapter 05 (cross-link, don't restate)

## 6. Per-phase search ideas

### Web

- `site:developer.apple.com launchd plist`
- `man launchd.plist` (via online manpage mirrors)
- `site:systemd.io OR site:freedesktop.org systemd.timer`
- `site:ntfy.sh docs`
- `site:unifiedpush.org`
- `site:grapheneos.org notifications`
- `site:orgmode.org iCalendar-Export`
- `site:khal.readthedocs.io`
- `"markdown to ics" python OR script`
- `RFC 5545 iCalendar`
- `Linear "project updates" Friday`
- `site:basecamp.com/shapeup`

### Social

- HN: `https://hn.algolia.com/?q=launchd+vs+cron`
- HN: `https://hn.algolia.com/?q=ntfy`
- HN: `https://hn.algolia.com/?q=systemd+timer+missed`
- HN: `https://hn.algolia.com/?q=org-mode+ical`
- HN: `https://hn.algolia.com/?q=pushover+alternative`
- Lobsters: `https://lobste.rs/search?q=launchd`
- Lobsters: `https://lobste.rs/search?q=ntfy`
- Reddit: `site:reddit.com/r/macsysadmin launchd`
- Reddit: `site:reddit.com/r/selfhosted ntfy gotify`
- Reddit: `site:reddit.com/r/GrapheneOS notifications`
- Reddit: `site:reddit.com/r/orgmode agenda ical`
- X: `(launchd OR systemd) ritual personal automation min_faves:30`

### GitHub

- `topic:notification` (sort recent)
- `binwiederhier/ntfy` — ntfy repo
- `gotify/server` — Gotify
- `caronc/apprise` — Apprise (universal notification dispatcher)
- `pushover-open-client` repos
- `tom4u/macos-launchd-helpers` and similar
- `khalcalendar/khal` — khal calendar
- `bitlbee/bitlbee` — IM bridge (adjacent for ritual notification routing)
- Code search: `RunAtLoad path:LaunchAgents` for plist patterns

### Specific repos

- `binwiederhier/ntfy` — recent issues for 2025–2026 features
- `UnifiedPush/android-connector` — UnifiedPush reference impl
- `khalcalendar/khal` — terminal CalDAV
- `vdirsyncer/vdirsyncer` — CalDAV sync, useful for ICS round-trip

## 7. Stop conditions

Stop and surface if:

- ntfy.sh shuts down or makes hosted tier paid-only (changes the "free push" framing).
- Apple deprecates `RunAtLoad` semantics or changes plist location in a macOS major version.
- GrapheneOS officially removes UnifiedPush support or changes its push recommendation drastically.
- `md → ics` scripts produce so many edge cases that the playbook should pivot to recommending a real CalDAV stack instead.

## 8. Estimated effort

M phase. 6–10 hours research + 5–8 hours writing. The shipped plists / scripts / curl recipes add concrete value disproportionate to their length; budget time to test them on a fresh machine.
