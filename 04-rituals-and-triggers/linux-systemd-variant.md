# Linux variant: systemd timers

> The chapter's triggers are written for macOS `launchd`. On Linux the
> equivalent is **systemd user timers**. Same guarantee — missed runs fire on
> the next wake — different syntax. This file is the 1:1 translation.

`launchd` is Apple-only. Everything in [launchd-over-cron](./launchd-over-cron.md)
maps onto a `systemd` **user** timer + service pair. Use this file instead of
the plists if you're on Linux; the shell scripts ([Monday](./monday-planning.md),
[Friday](./friday-retro.md)) are identical.

## The translation table

`launchd` `StartCalendarInterval` dict → systemd `OnCalendar=` expression. Both
coalesce missed runs on wake (see "Missed runs" below).[¹][²]

| Ritual | launchd `StartCalendarInterval` | systemd `OnCalendar=` |
|---|---|---|
| Daily 09:00 | `{ Hour = 9; Minute = 0; }` | `*-*-* 09:00:00` |
| Mon 09:00 | `{ Weekday = 1; Hour = 9; Minute = 0; }` | `Mon *-*-* 09:00:00` |
| Fri 16:00 | `{ Weekday = 5; Hour = 16; Minute = 0; }` | `Fri *-*-* 16:00:00` |
| Monthly, 1st 00:00 | `{ Day = 1; Hour = 0; Minute = 0; }` | `*-*-01 00:00:00` |

Weekday differs: launchd uses integers (`0`/`7` = Sunday, `1` = Monday); systemd
uses names (`Mon`, `Fri`) and ranges (`Mon..Fri`). Steps use `/` (`*:0/15` = every
15 min). `systemd.time(7)` normalizes shorthand: `daily` → `*-*-* 00:00:00`,
`weekly` → `Mon *-*-* 00:00:00`, `monthly` → `*-*-01 00:00:00`.[²]

## The unit pair

A timer needs a matching service of the same name. Files live in
`~/.config/systemd/user/`.

`~/.config/systemd/user/monday-plan.service`:

```ini
[Unit]
Description=Monday planning ritual

[Service]
Type=oneshot
ExecStart=%h/.local/bin/monday-plan
```

`~/.config/systemd/user/monday-plan.timer`:

```ini
[Unit]
Description=Fire Monday planning ritual

[Timer]
OnCalendar=Mon *-*-* 09:00:00
Persistent=true
RandomizedDelaySec=30

[Install]
WantedBy=timers.target
```

`%h` expands to `$HOME` — no hardcoded username (the systemd equivalent of the
plist `<USER>` placeholder rule). The other three rituals are the same two files
with a different `OnCalendar=` and `ExecStart=` (`daily-triage`, `friday-retro`,
`monthly-cooldown`).

## Enable and verify

```bash
systemctl --user daemon-reload
systemctl --user enable --now monday-plan.timer

# What's scheduled, and when does each fire next?
systemctl --user list-timers

# Run the service now (test, bypasses the clock)
systemctl --user start monday-plan.service

# Logs — journald captures stdout/stderr, no /tmp redirect needed
journalctl --user -u monday-plan.service -n 50
```

`list-timers` is the systemd answer to `launchctl print` — it shows `NEXT`,
`LAST`, and the unit for every active timer.

## Missed runs: `Persistent=true`

This is the line that buys you the launchd "fires on wake" guarantee. From the
`systemd.timer(5)` man page: with `Persistent=true`, "the service unit is
triggered immediately if it would have been triggered at least once during the
time when the timer was inactive ... useful to catch up on missed runs of the
service when the system was powered down."[¹]

Two caveats, both load-bearing:

1. **Only one catch-up.** If the machine slept through *several* scheduled
   firings, `systemd` fires the service **once** on wake, not once per missed
   slot.[¹] launchd coalesces identically[³] — so this is parity, not a
   regression, but don't expect five Monday runs after a two-week vacation.
2. **`OnCalendar=` only.** `Persistent=` has no effect on monotonic timers
   (`OnBootSec=`/`OnActiveSec=`). It needs a wall-clock `OnCalendar=`.[¹]

`RandomizedDelaySec=` jitters the start so a pile of timers don't all fire at the
exact same second.[⁴] Optional for personal use; cheap insurance.

> **Known edge case.** systemd issue #24984 documents a Persistent timer failing
> to trigger after a missed calendar run under specific conditions.[⁵] Persistent
> is "best effort," not a hard guarantee. For a ritual you cannot miss, keep the
> ntfy nudge ([ntfy-notifications](./ntfy-notifications.md)) as the backstop.

## The lingering gotcha

User timers run only while you have an active login session. If you want rituals
to fire on a headless box, or before you log in, enable **lingering** once:

```bash
sudo loginctl enable-linger "$USER"
```

Without this, `systemctl --user` timers are stopped when your last session ends
and a 09:00 timer won't fire on a machine you haven't logged into yet.[⁶] This is
the single most common "my systemd timer never ran" cause.

## anacron: still needed?

For always-on or frequently-on machines, **systemd timers with `Persistent=true`
supersede `anacron`** for missed-run catch-up, and add journald logging and
dependency ordering.[⁴][⁷] anacron keeps one distinct behavior: it guarantees a
**minimum spacing** between runs (a "weekly" job runs at most once per ~6 days),
whereas a persistent weekly timer targets the wall-clock slot and fires at boot
if missed.[⁸] These diverge only for weekly/monthly jobs on machines that are off
unpredictably.

| Need | Use |
|---|---|
| Run on your machine, catch up missed slots, get logs | systemd timer + `Persistent=true` |
| Laptop off for days, want "at most once per interval" spacing | anacron (or `systemd-cron`'s `PERSISTENT=`)[⁷] |
| Run in the cloud regardless of machine state | GitHub Actions `on: schedule` (see [launchd-over-cron](./launchd-over-cron.md)) |

## Secrets

Same rule as the plists: **never put tokens in the unit file.** A unit's
`Environment=` is world-readable to your user and shows in `systemctl --user
show`. Have the script load secrets from your password manager at runtime — see
[Chapter 05 — Bitwarden via rbw](../05-secrets-and-secure-defaults/bitwarden-via-rbw.md).
Under systemd the script also won't inherit your interactive `PATH`; set it in
the script or add `Environment=PATH=...` to the `[Service]` (non-secret only).

## Related

- [launchd over cron](./launchd-over-cron.md) — the macOS originals this mirrors
- [Monday planning](./monday-planning.md) / [Friday retro](./friday-retro.md) — the scripts `ExecStart=` runs
- [Chapter 05 — Secure defaults](../05-secrets-and-secure-defaults/) — runtime secret loading

---

[1]: https://raw.githubusercontent.com/systemd/systemd/main/man/systemd.timer.xml — `systemd.timer(5)`, `Persistent=`/`OnCalendar=` semantics — accessed 2026-05-31
[2]: https://raw.githubusercontent.com/systemd/systemd/main/man/systemd.time.xml — `systemd.time(7)`, calendar-event syntax + shorthand normalization — accessed 2026-05-31
[3]: https://raw.githubusercontent.com/apple-oss-distributions/launchd/main/man/launchd.plist.5 — `launchd.plist(5)`, StartCalendarInterval coalesces missed runs on wake — accessed 2026-05-31
[4]: https://wiki.archlinux.org/title/Systemd/Timers — Arch Wiki, `Persistent=`/`RandomizedDelaySec=` guidance — accessed 2026-05-31
[5]: https://github.com/systemd/systemd/issues/24984 — upstream: Persistent timer fails to trigger after missed calendar run (counter-evidence) — accessed 2026-05-31
[6]: https://wiki.archlinux.org/title/Systemd/User — Arch Wiki, `loginctl enable-linger` for user units without an active session — accessed 2026-05-31
[7]: https://manpages.debian.org/testing/systemd-cron/systemd.cron.7.en.html — Debian `systemd.cron(7)`, `PERSISTENT=` crontab translation — accessed 2026-05-31
[8]: https://www.jujens.eu/posts/en/2025/Feb/01/systemd-timers/ — practitioner, anacron min-interval vs systemd wall-clock distinction — accessed 2026-05-31
