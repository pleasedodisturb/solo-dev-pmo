# RESEARCH-LOG — Phase P04: Rituals and triggers

Append-only log of sources cited while enriching the chapter. Format per
[`SEARCH-PLAYBOOK.md`](../SEARCH-PLAYBOOK.md) §"Per-phase research log format".

Branch: `claude/sleepy-darwin-G1ysf` (session-assigned). Started 2026-05-31.

Environment note: this pass was researched and written in a Linux cloud
container. **No macOS was available**, so every `launchd` plist and every
`launchctl` invocation is written-but-untested against real launchd — flagged
inline and in the PR. The `ntfy` curl recipes are likewise untested against a
live phone/topic; push delivery must be verified locally.

---

<!-- entries appended below as research lands, newest first -->

## 2026-05-31 — ritual cadence defense + ritual fatigue (Q04.17–Q04.23)

- **Source:** behaviormodel.org (Fogg B=MAP); jamesclear.com (never-miss-twice, habit-stacking); NCBI Bookshelf NBK555522 (alarm fatigue); ACM CHI'08 1357054.1357072 (interruption cost); pomodorotechnique.com; calnewport.com; en.wikipedia.org/wiki/Parkinson%27s_law; linear.app/now; atlassian.com retrospective; basecamp.com/shapeup; PMC8505290 (EF scaffolding).
- **Class:** primary (books/peer-reviewed/vendor) + practitioner.
- **Surfaced fact:** Short fixed timeboxes are defensible (Pomodoro/Newport/Parkinson) but the exact 10/15/5-minute figures are author preference. Weekly-Friday is Linear's documented internal convention, not a researched optimum; 5-min runs against Atlassian's 30-min team floor (legit solo scale-down). Shape Up cooldown = 2 wks/6-wk cycle; our every-4th-week is an adaptation. Ritual fatigue is cleanly explained by B=MAP; alarm-fatigue literature (85–99% false ICU alarms) grounds the "fewer, higher-signal channels" rule.
- **Used in:** monday-planning.md, friday-retro.md, ritual-fatigue.md (new).
- **Counter-evidence:** "weekly beats daily" is NOT directly supported — ADHD sources encourage *daily* routines kept small; reframed to "smallest daily ritual that survives." No peer-reviewed day-of-week retro effect found. Could not retrieve a citable r/ADHD_Programmers permalink — omitted rather than fabricated.

## 2026-05-31 — plaintext time / md→ics / RFC 5545 (Q04.12–Q04.16)

- **Source:** RFC 5545 + RFC 7986 (datatracker.ietf.org); icalendar/ics PyPI; orgmode.org ox-icalendar; vdirsyncer/khal docs; Fastmail/Proton support; Google issue tracker 137168934; gene1wood gist (Google refresh lag); MS-OXCICAL (X-PUBLISHED-TTL).
- **Class:** primary (specs/libs/vendor) + practitioner.
- **Surfaced fact:** No standard md→ics tool exists — home-rolled on `icalendar` (production-stable, chosen over beta ics.py) is the move. RFC 5545 requires UID+UTC-DTSTAMP per VEVENT, TZID needs a VTIMEZONE, lines ≤75 octets CRLF-folded; Google silently drops violations. Explicit dated VEVENTs beat RRULE. Emit REFRESH-INTERVAL + X-PUBLISHED-TTL; Google still polls ~12–24h. Two-way needs CalDAV (Fastmail yes, Proton no).
- **Used in:** plaintext-time-layer.md.
- **Counter-evidence:** Google publishes no authoritative malformed-ICS spec — behavior reconstructed from issue trackers. **Exporter was run end-to-end in-container and produced valid ICS (sanity-tested).**

## 2026-05-31 — ntfy / UnifiedPush / GrapheneOS / Focus (Q04.6–Q04.11, Q04.24–25)

- **Source:** github.com/binwiederhier/ntfy (repo, issues #1167/#1680, docs config/publish), docs.ntfy.sh/install, unifiedpush.org, grapheneos.org/usage, developer.apple.com UNNotificationInterruptionLevel, support.apple.com Focus, pushover.net, gotify.net, github.com/caronc/apprise.
- **Class:** primary (vendor docs/maintainer) + practitioner.
- **Surfaced fact (FLAGGED RISK RESOLVED):** ntfy.sh free tier is ALIVE — 250 msg/day, 5 emails/day, 2 MB/attachment, no reserved topics (issue #1167). Self-hosted iOS instant push needs `upstream-base-url: https://ntfy.sh`. GrapheneOS: UnifiedPush(ntfy) > sandboxed-Play/FCM > standalone, all gated on a battery exception. iOS Focus pierced reliably only via manual allowlist (priority-5 not yet wired, issue #1680).
- **Used in:** ntfy-notifications.md.
- **Counter-evidence:** exact paid-tier prices unverifiable from primary (live page 403; third-party figures conflict) — not printed. ntfy curl recipes untested against a live device this pass.

## 2026-05-31 — launchd / systemd / cron / GH Actions (Q04.1–Q04.5)

- **Source:** apple-oss launchd.plist(5) source; systemd.timer(5)/systemd.time(7) upstream XML; GitHub Actions schedule docs; ArchWiki Timers/User; Debian systemd-cron; Apple Developer Forums (TCC/FDA threads 661178/804548); launchd.info; ss64 launchctl; systemd issue #24984.
- **Class:** primary (man sources/vendor docs) + practitioner + community.
- **Surfaced fact:** launchd coalesces missed runs on wake; "StartCalendarInterval implies RunAtLoad" is folklore (NOT in current man page). `launchctl load/unload` are legacy → `bootstrap/bootout/kickstart/print`. systemd `Persistent=true` = single catch-up (parity with launchd), `OnCalendar=` only, needs `loginctl enable-linger` for headless. anacron superseded by persistent timers except for min-interval spacing. GH Actions schedule: 5-min floor, high-load delay/drops, default-branch-only, 60-day disable.
- **Used in:** launchd-over-cron.md, linux-systemd-variant.md (new).
- **Counter-evidence:** systemd #24984 — Persistent can miss under edge conditions (documented, ntfy nudge as backstop). SIGTERM grace default is "system-defined" (5/10/20s reports conflict) — not hardcoded. Many primary doc hosts 403'd the fetcher; verified via upstream source files instead.
