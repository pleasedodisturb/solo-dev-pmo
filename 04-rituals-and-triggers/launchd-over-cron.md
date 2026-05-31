# launchd over cron

> On macOS, launchd coalesces missed runs when the machine was asleep; cron
> silently drops them. Use launchd. On Linux, use systemd timers —
> [linux-systemd-variant](./linux-systemd-variant.md).

> **Untested-in-this-pass caveat.** The plists below were written and validated
> for XML well-formedness but **not run against a live launchd** during this
> research pass (no macOS available). Verify locally with `plutil` + a manual
> `launchctl kickstart` before trusting them. See the chapter README.

## The recipe

Per-user time triggers live in `~/Library/LaunchAgents/` as `.plist` files. One
agent = one plist. The canonical full plist (Morning Triage, daily 09:00):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.<USER>.daily-triage</string>
  <key>ProgramArguments</key>
  <array>
    <string>/Users/<USER>/.local/bin/daily-triage</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>9</integer>
    <key>Minute</key><integer>0</integer>
  </dict>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
  </dict>
  <key>StandardOutPath</key><string>/tmp/daily-triage.out</string>
  <key>StandardErrorPath</key><string>/tmp/daily-triage.err</string>
</dict>
</plist>
```

`PATH` is set explicitly because launchd does **not** source your shell profile;
agents get a bare `/usr/bin:/bin:/usr/sbin:/sbin` with **no** `/opt/homebrew/bin`
or `/usr/local/bin`.[¹] Use `<USER>` placeholders — never ship a hardcoded
username.

## The four rituals: copy-paste plists

All four share the structure above. Only `Label`, the script path, and
`StartCalendarInterval` change. `Weekday`: `0`/`7` = Sunday, `1` = Monday … `6` =
Saturday.[²]

| Ritual | Label suffix | `StartCalendarInterval` dict |
|---|---|---|
| Morning Triage (daily 09:00) | `daily-triage` | `Hour=9  Minute=0` |
| Monday plan (Mon 09:00) | `monday-plan` | `Weekday=1  Hour=9  Minute=0` |
| Friday retro (Fri 16:00) | `friday-retro` | `Weekday=5  Hour=16  Minute=0` |
| Monthly cooldown (1st, 09:00) | `monthly-cooldown` | `Day=1  Hour=9  Minute=0` |

So the Friday plist's interval block is:

```xml
<key>StartCalendarInterval</key>
<dict>
  <key>Weekday</key><integer>5</integer>
  <key>Hour</key><integer>16</integer>
  <key>Minute</key><integer>0</integer>
</dict>
```

The "every 4th week cooldown" the chapter describes can't be expressed in a
single `StartCalendarInterval` (launchd has no "every N weeks"). Fire monthly on
the 1st as above and have the script no-op on non-cooldown months, or compute the
cooldown week in the script. Don't fake it in the plist.

## Loading a plist (modern + legacy)

`launchctl load`/`unload` are now grouped under **"LEGACY SUBCOMMANDS"**; the
current verbs are `bootstrap`/`bootout` with a **domain target**.[²]

```bash
# Modern (macOS 11+): bootstrap into the GUI domain for your uid
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.<USER>.daily-triage.plist
launchctl bootout   gui/$(id -u) ~/Library/LaunchAgents/com.<USER>.daily-triage.plist

# Run once now, ignoring the clock (replaces `launchctl start`)
launchctl kickstart -k gui/$(id -u)/com.<USER>.daily-triage

# Inspect state (replaces `launchctl list <label>`)
launchctl print gui/$(id -u)/com.<USER>.daily-triage

# Legacy form, still works, still everywhere in old docs:
launchctl load   ~/Library/LaunchAgents/com.<USER>.daily-triage.plist
launchctl unload ~/Library/LaunchAgents/com.<USER>.daily-triage.plist
```

Gotcha: `launchctl disable` persists across boots and is **not** undone by
`bootstrap` — you must `enable` first.[²]

## Why launchd, not cron — and how Linux compares

The decisive property: **missed-run handling.** Per `launchd.plist(5)`,
`StartCalendarInterval` "will start the job the next time the computer wakes up …
those events will be coalesced into one event upon wake from sleep" — unlike cron,
which skips invocations while asleep.[³] For a laptop that sleeps overnight, cron
drops your 09:00 Monday ritual roughly half the time.

| Behavior | cron | launchd | systemd timer | anacron |
|---|---|---|---|---|
| Asleep at fire time | drops | fires on wake[³] | fires on wake (`Persistent=`)[⁴] | catches up on next run |
| Multiple missed runs | all lost | **one** coalesced[³] | **one** catch-up[⁴] | one per interval |
| Sub-day precision | yes | yes | yes | no (daily+ only) |
| Per-run logging | weak | stdout/err paths | journald | mail/log |
| Config | crontab line | XML plist | INI units | anacrontab |

launchd and systemd both coalesce to a **single** catch-up, not one run per missed
slot — parity, not a quirk. Full Linux mapping:
[linux-systemd-variant](./linux-systemd-variant.md).

## Cloud alternative: GitHub Actions `on: schedule`

When a ritual needs **no local machine state**, a scheduled GitHub Actions
workflow runs even when your laptop is off. Tradeoffs, from the GitHub docs:[⁵]

- Shortest interval is **5 minutes**; the `schedule` event **can be delayed**
  during high load (notably on the hour) and queued jobs may be **dropped** — so
  schedule at an offset (`17 9 * * *`, not `0 9`).
- Runs only on the **default branch**'s latest commit, in **UTC**.
- **Auto-disabled after 60 days** of no repository activity (an email warns you).

Use GitHub Actions for stateless/cloud rituals (a digest email, a Linear API
sweep). Use a local plist/timer for anything that must touch **your** files,
LAN, or local credentials — the cloud runner can't.

## Environment variables and secrets

launchd does not load your rc files. A plist's `EnvironmentVariables` is
**plaintext** — never put a token there. Load secrets at runtime from your
password manager instead:

```bash
#!/usr/bin/env bash
export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key)"
```

See [Chapter 05 — Bitwarden via rbw](../05-secrets-and-secure-defaults/bitwarden-via-rbw.md).
After a long sleep `rbw` may be locked; the first morning run fails silently and
you unlock interactively at next login. Guard scripts with `set -euo pipefail`
and ntfy-on-failure (below).

## macOS 2025–2026 gotchas

**"StartCalendarInterval implies RunAtLoad" is folklore.** The archived Apple
guide and many blogs assert it; the **current** `launchd.plist(5)` does not.[³]
If you want a catch-up at load time, set `RunAtLoad` explicitly:

```xml
<key>RunAtLoad</key><true/>
```

**Bare `$PATH`.** No Homebrew paths. Set `PATH` in the plist or the script.[¹]

**TCC / Full Disk Access.** An agent that touches protected paths (Desktop,
Documents, Mail) needs FDA granted manually in System Settings → Privacy. TCC
prompts only appear in a GUI login session; an agent with no session is
**default-denied** when no record exists.[⁶]

**Code-signing identity matters.** TCC ties grants to a stable code-signing
identity; ad-hoc/re-signed helpers get inconsistent Full Disk Access.[⁶]

**SIP ignores injected env vars.** `DYLD_*`, `BASH_ENV`, etc. are stripped for
SIP-protected processes — deliberate hardening, don't fight it.[⁷]

**Don't hardcode a SIGTERM grace number.** Stopping a job sends `SIGTERM` then
`SIGKILL` after `ExitTimeOut`; the default is "system-defined" and sources
disagree (5 vs 10 vs 20 s).[⁸] Set `ExitTimeOut` explicitly if it matters; never
set it to `0` (interpreted as infinity, can stall shutdown).

**Apple Silicon vs Intel FDA divergence.** On macOS 15.x, app-bundled-daemon FDA
toggles have been reported to persist on Apple Silicon but flip back on Intel.[⁶]
Re-verify after OS updates.

**Validate before loading.** `plutil ~/Library/LaunchAgents/foo.plist` catches XML
typos that otherwise fail with an opaque parse error. Editing a loaded plist
needs `bootout` then `bootstrap` — in-place edits leave the old version running.

## Innovative patterns (condensed)

- **ntfy on failure only.** Wrap the workflow; on non-zero exit, push the last
  error lines to your phone (silent on success). See
  [ntfy-notifications](./ntfy-notifications.md).
- **tmux-aware output.** If `tmux has-session -t main`, `send-keys` the worksheet
  into pane 0 so it's open when you arrive.
- **Chained triggers.** Express ritual ordering in the script (`launchctl
  kickstart` the next ritual on success), not in launchd config.

## Related

- [linux-systemd-variant](./linux-systemd-variant.md) — the Linux equivalents
- [Monday planning](./monday-planning.md) / [Friday retro](./friday-retro.md) — the scripts launchd fires
- [ntfy notifications](./ntfy-notifications.md) — what the script pushes
- [Chapter 05 — Secure defaults](../05-secrets-and-secure-defaults/) — runtime secret loading

---

[1]: https://lucaspin.medium.com/where-is-my-path-launchd-fc3fc5449864 — practitioner: launchd gives a bare PATH, no Homebrew dirs — accessed 2026-05-31
[2]: https://ss64.com/mac/launchctl.html — launchctl reference: load/unload legacy, bootstrap/bootout/print/enable current — accessed 2026-05-31
[3]: https://raw.githubusercontent.com/apple-oss-distributions/launchd/main/man/launchd.plist.5 — `launchd.plist(5)`: StartCalendarInterval coalesces missed runs on wake; RunAtLoad default false — accessed 2026-05-31
[4]: https://raw.githubusercontent.com/systemd/systemd/main/man/systemd.timer.xml — `systemd.timer(5)`: `Persistent=` single catch-up — accessed 2026-05-31
[5]: https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows — GitHub Actions `schedule`: 5-min floor, high-load delay/drops, default-branch-only, 60-day disable — accessed 2026-05-31
[6]: https://developer.apple.com/forums/thread/661178 — Apple DTS: FDA from a launchd daemon, GUI-session prompts, code-signing attribution (see also thread/804548 for Apple-Silicon-vs-Intel divergence) — accessed 2026-05-31
[7]: https://hackyboiz.github.io/2025/05/11/clalxk/MacOS_SIP-Bypass_en/ — SIP strips injected env vars from protected processes — accessed 2026-05-31
[8]: https://www.launchd.info/ — practitioner: SIGTERM→SIGKILL after ExitTimeOut (cites 20s; man page says system-defined) — accessed 2026-05-31
