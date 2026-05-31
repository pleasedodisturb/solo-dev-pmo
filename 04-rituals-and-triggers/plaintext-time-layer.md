# Plaintext time layer

> Your schedule lives in a markdown file. Export to iCal when a phone needs to see
> it. Calendar apps consume; you author in text.

## The recipe

One `schedule.md` (or a `schedules/` dir of dated files) is canonical. Format you
control, edit in any editor.

```markdown
## Week of 2026-06-01

### Monday
- 09:00 — Monday planning (15m)
- 09:30 — Deep work: Linear cycle plan (150m)
- 13:00 — Submission window: Company X (60m)

### Friday
- 16:00 — Linear Project Update (5m)
```

## Why plaintext

- **Diff-able** — `git diff schedule.md` shows the week-to-week delta.
- **Grep-able** — "when did I last block for X?" is one `grep`.
- **Scriptable** — export to `.ics`, push to ntfy, sync anywhere.
- **No lock, no sync vendor** — git/Syncthing moves it; no service holds it.

What it doesn't give: a calendar UI, drag-and-drop, cross-calendar conflict
detection. If those matter, use Fantastical/GCal and accept the lock. See
[Chapter 00 — Calendar neutrality](../00-principles/calendar-neutrality.md).

## Prior art (you're not the first)

| Tool | What it is |
|---|---|
| **org-mode** + `ox-icalendar` | the mature analog: timestamps → `VEVENT`, even emits `X-PUBLISHED-TTL`[¹] |
| **khal** + **vdirsyncer** | events as per-event `.ics` files in a `vdir`; two-way CalDAV sync[²] |
| **Taskwarrior** `task export` | JSON only; `.ics` is a community add-on[³] |
| **todo.txt** | philosophical precedent — plaintext, but no time dimension[⁴] |

org-mode is the closest design ancestor; khal+vdirsyncer is the path if you want
genuine two-way sync rather than one-way publish.

## md → ics: a working exporter

There is **no de-facto-standard `md → ics` tool** — home-rolled on top of a real
library is the norm.[⁵] Use the **`icalendar`** library, **not `ics.py`**: `ics.py`
is friendlier but beta and weak on recurrence/edge cases, while `icalendar` is
production-stable, actively released (7.1.2, 2026-05-22), and gives the
property-level control you need to satisfy strict consumers like Google
Calendar.[⁶]

```python
#!/usr/bin/env python3
# schedule-to-ics.py — parse schedule.md → a correct, subscribable .ics
# deps: pip install icalendar   (>=6; uses zoneinfo)
import re, sys, hashlib
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
from icalendar import Calendar, Event

TZ = ZoneInfo("America/New_York")           # your local zone
WEEKDAYS = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]

def parse(path):
    week = day = None
    for line in open(path, encoding="utf-8"):
        if m := re.match(r"##\s+Week of (\d{4}-\d{2}-\d{2})", line):
            week = datetime.strptime(m[1], "%Y-%m-%d").date()
        elif m := re.match(r"###\s+(\w+)", line):
            day = WEEKDAYS.index(m[1]) if m[1] in WEEKDAYS else None
        elif (m := re.match(r"-\s+(\d{2}):(\d{2})\s+[—-]\s+(.+?)\s+\((\d+)m\)", line)) \
                and week is not None and day is not None:
            h, mi, title, dur = int(m[1]), int(m[2]), m[3], int(m[4])
            start = datetime.combine(week + timedelta(days=day),
                                     datetime.min.time(), TZ).replace(hour=h, minute=mi)
            yield title, start, start + timedelta(minutes=dur)

cal = Calendar()
cal.add("prodid", "-//solo-dev-pmo//schedule.md exporter//EN")
cal.add("version", "2.0")
cal.add("method", "PUBLISH")
cal.add("name", "My Schedule"); cal.add("x-wr-calname", "My Schedule")
cal.add("refresh-interval", timedelta(hours=12), parameters={"VALUE": "DURATION"})
cal.add("x-published-ttl", "PT12H")
for title, start, end in parse(sys.argv[1]):
    ev = Event()
    uid = hashlib.sha1(f"{start.isoformat()}-{title}".encode()).hexdigest()
    ev.add("uid", f"{uid}@solo-dev-pmo")          # stable + unique (§3.8.4.7)
    ev.add("dtstamp", datetime.now(timezone.utc)) # REQUIRED, UTC (§3.8.7.2)
    ev.add("dtstart", start); ev.add("dtend", end)
    ev.add("summary", title)
    cal.add_component(ev)
cal.add_missing_timezones()                       # emits VTIMEZONE for the TZID
sys.stdout.buffer.write(cal.to_ical())            # CRLF + 75-octet folding, done
```

`cal.to_ical()` handles CRLF line endings and 75-octet folding for you — the two
things hand-rolled emitters get wrong. `add_missing_timezones()` writes the
`VTIMEZONE` your `TZID` references. Run: `python schedule-to-ics.py schedule.md > schedule.ics`.

## RFC 5545 gotchas (why the script does what it does)

The spec is strict and Google Calendar **fails silently** on violations —
dropping the bad event, or the whole feed, with nothing in any log.[⁷] The
load-bearing rules:[⁸]

- **`UID` + `DTSTAMP` are REQUIRED** in every `VEVENT` (§3.6.1); `DTSTAMP` MUST be
  UTC (§3.8.7.2). Missing/duplicate `UID` makes Google drop or *collapse* events.
- **`TZID` needs a matching `VTIMEZONE`** (§3.3.5). Use a real zone + emit the
  component (the script's `add_missing_timezones()`), or use UTC `Z` times.
- **Lines ≤ 75 octets, folded with CRLF + space; terminate with CRLF not LF**
  (§3.1). The single most common silent-corruption source.
- **Prefer explicit dated events over `RRULE`** for simple weekly recurrence
  (§3.8.5.3). RRULE's BYDAY/UNTIL/COUNT interactions diverge across clients; one
  `VEVENT` per occurrence (each with its own `UID`) sidesteps the bugs.
- **Refresh hints:** RFC 7986 `REFRESH-INTERVAL;VALUE=DURATION` (§5.7) is the
  standards-track hint; `X-PUBLISHED-TTL` is the de-facto one. Emit **both** —
  Outlook/Apple honor them; Google ignores both and polls on its own clock.[⁹]

## Hosting the `.ics`

Subscription is **one-way (read-only)**: the phone shows your schedule, you edit
in `schedule.md`. The dominant constraint is refresh lag, not origin cache.

- **Google Calendar refreshes a subscribed URL only every ~12–24h** (undocumented,
  throttled, no manual refresh button). Force a fresh fetch by re-subscribing with
  a changed URL fragment (`…/schedule.ics#2`).[¹⁰]
- **Apple/Outlook** refresh promptly and honor `X-PUBLISHED-TTL`/`REFRESH-INTERVAL`.

Because Google polls only ~daily, the real differentiators are **URL stability**
and a **custom domain**:

| Host | Verdict |
|---|---|
| **GitHub Pages** | cheap default — stable URL, custom domain, `max-age=600`[¹¹] |
| **Cloudflare R2 + custom domain** | most control — you set `Cache-Control`, clean HTTPS on your domain |
| GitHub **raw** | works but ~5-min IP cache + occasional stale content; no custom domain[¹¹] |
| local + ngrok / `cloudflared` | dev/testing only — URL churns, host must stay up |

For urgent same-day changes, don't fight the lag — push via
[ntfy](./ntfy-notifications.md) instead.

## Two-way sync with collaborators

A hosted `.ics` is read-only. True two-way editing needs **CalDAV** — sync a local
vdir (e.g. khal's store) against a CalDAV server with **vdirsyncer**.[²]
**Fastmail** has full CalDAV (vdirsyncer-tested).[¹²] **Proton Calendar has no
CalDAV** as of 2026 — Proton users are stuck with read-only ICS import.[¹³]

## Field-tested gotchas

- **Split when long.** Past ~6 weekly headers, go to `schedules/2026-Q2.md`; the
  exporter globs the dir.
- **Test render on the actual phone** — clients lay out `.ics` differently.
- **Validate before publish** — every `VEVENT` needs `UID` + `DTSTAMP`, CRLF
  endings, a `VTIMEZONE` for any `TZID`. The script above enforces all three.

## Related

- [Chapter 00 — Calendar neutrality](../00-principles/calendar-neutrality.md) — why plaintext
- [launchd over cron](./launchd-over-cron.md) — reads the schedule, fires triggers
- [Friday retro](./friday-retro.md) — the weekly review against plan

---

[1]: https://orgmode.org/manual/iCalendar-Export.html — org `ox-icalendar`, `X-PUBLISHED-TTL` via `org-icalendar-ttl` — accessed 2026-05-31
[2]: https://vdirsyncer.pimutils.org/en/stable/config.html — vdirsyncer two-way CalDAV sync of a local vdir (khal store) — accessed 2026-05-31
[3]: https://taskwarrior.org/docs/commands/export/ — `task export` emits JSON; ICS is third-party — accessed 2026-05-31
[4]: https://github.com/todotxt/todo.txt — todo.txt plaintext task format (no time dimension) — accessed 2026-05-31
[5]: https://github.com/RealOrangeOne/mdcal — representative tiny md→ics project; no maintained standard exists — accessed 2026-05-31
[6]: https://pypi.org/project/icalendar/ — `icalendar` 7.1.2 (2026-05-22), Production/Stable; cf. https://pypi.org/project/ics/ (0.7.3, beta) — accessed 2026-05-31
[7]: https://issuetracker.google.com/issues/137168934 — Google Calendar overriding/dropping events on bad UID, no logs — accessed 2026-05-31
[8]: https://datatracker.ietf.org/doc/html/rfc5545 — RFC 5545 §3.1, §3.3.5, §3.6.1, §3.8.5.3, §3.8.7.2 — accessed 2026-05-31
[9]: https://datatracker.ietf.org/doc/html/rfc7986 — RFC 7986 §5.7 REFRESH-INTERVAL; X-PUBLISHED-TTL is the de-facto sibling — accessed 2026-05-31
[10]: https://gist.github.com/gene1wood/02ed0d36f62d791518e452f55344240d — Google subscribed-ICS refresh is ~12–24h; the `#fragment` re-subscribe trick — accessed 2026-05-31
[11]: https://github.com/orgs/community/discussions/11884 — GitHub Pages `Cache-Control: max-age=600`; cf. raw staleness https://news.ycombinator.com/item?id=34761284 — accessed 2026-05-31
[12]: https://www.fastmail.help/hc/en-us/articles/360058752754 — Fastmail native CalDAV/CardDAV — accessed 2026-05-31
[13]: https://proton.me/support/calendar — Proton Calendar, no CalDAV as of 2026 — accessed 2026-05-31
