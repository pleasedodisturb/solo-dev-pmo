# launchd over cron

> On macOS: launchd handles missed runs when the machine is asleep. cron silently drops them. Use launchd.

## The recipe

Time-based triggers on macOS go in `~/Library/LaunchAgents/` as `.plist` files.

Minimal plist for "fire at 09:00 every Monday":

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.<your>.monday-plan</string>

  <key>ProgramArguments</key>
  <array>
    <string>/Users/<u>/.local/bin/monday-plan</string>
  </array>

  <key>StartCalendarInterval</key>
  <dict>
    <key>Weekday</key><integer>1</integer>
    <key>Hour</key><integer>9</integer>
    <key>Minute</key><integer>0</integer>
  </dict>

  <key>StandardOutPath</key>
  <string>/tmp/monday-plan.out</string>
  <key>StandardErrorPath</key>
  <string>/tmp/monday-plan.err</string>
</dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/com.<your>.monday-plan.plist
launchctl list | grep monday-plan
```

To test immediately:
```bash
launchctl start com.<your>.monday-plan
```

To unload (e.g., when editing):
```bash
launchctl unload ~/Library/LaunchAgents/com.<your>.monday-plan.plist
```

## Why launchd, not cron

| Behavior | cron | launchd |
|---|---|---|
| Machine asleep at scheduled time | Silently drops | Fires at wake |
| Missed runs after reboot | Lost | RunAtLoad option fires once |
| Job restart on failure | No | Yes, via KeepAlive |
| Native macOS integration | No | Yes |
| Debugging | `/var/log/cron.log` (if available) | `launchctl list`, stdout/stderr paths |
| Editing format | crontab single line | XML plist file |

For laptops that sleep most nights, the "missed runs" difference is decisive. cron will silently drop your 09:00 Monday ritual roughly 50% of the time.

## Common patterns

### "Run at this specific time daily"

```xml
<key>StartCalendarInterval</key>
<dict>
  <key>Hour</key><integer>9</integer>
  <key>Minute</key><integer>0</integer>
</dict>
```

### "Run every Monday at 09:00"

```xml
<key>StartCalendarInterval</key>
<dict>
  <key>Weekday</key><integer>1</integer>
  <key>Hour</key><integer>9</integer>
  <key>Minute</key><integer>0</integer>
</dict>
```

Weekday: 0=Sunday, 1=Monday, ..., 6=Saturday.

### "Run every Friday at 16:00"

```xml
<key>StartCalendarInterval</key>
<dict>
  <key>Weekday</key><integer>5</integer>
  <key>Hour</key><integer>16</integer>
  <key>Minute</key><integer>0</integer>
</dict>
```

### "Run on a recurring interval"

```xml
<key>StartInterval</key>
<integer>3600</integer>  <!-- every 3600 seconds = 1 hour -->
```

### "Run at load AND at scheduled time"

```xml
<key>RunAtLoad</key><true/>
<key>StartCalendarInterval</key>
<dict>
  <key>Hour</key><integer>9</integer>
</dict>
```

Useful for "if I just loaded the plist after waking, run it now too."

## Where to put scripts

The script that runs:
- Should be at a stable absolute path (launchd doesn't honor `$PATH` reliably)
- Should be executable (`chmod +x`)
- Should be tested manually before wiring to launchd
- Should NOT depend on `cd` to start; use absolute paths everywhere

Common locations:
- `~/.local/bin/<script>` — your personal scripts
- `~/Projects/infra/<infra-repo>/scripts/<script>` — versioned via git

The plist `ProgramArguments` references the absolute path.

## Environment variables in launchd

launchd does NOT load your shell rc files. Your script does not have `LINEAR_API_TOKEN` set unless you set it explicitly.

Two patterns:

**a. Set env in the plist:**
```xml
<key>EnvironmentVariables</key>
<dict>
  <key>PATH</key><string>/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin</string>
  <key>LINEAR_API_TOKEN</key><string>...</string>  <!-- NOT recommended, plist is plaintext -->
</dict>
```

Plist is plaintext → never put secrets here.

**b. Have the script load secrets from your password manager:**
```bash
#!/usr/bin/env bash
export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key)"
# Now run the workflow
```

Pattern (b) is correct. The script invokes the password-manager CLI at runtime; secrets stay encrypted at rest.

This requires `rbw` (or equivalent) to be unlocked. If the machine has been sleeping, you may need to handle the unlock case — typically the agent runs and silently fails on the first invocation; you unlock interactively at next login.

## Verifying scheduled runs

A few patterns:

```bash
# What's loaded?
launchctl list | grep <your-label-prefix>

# When did it last run? When will it run next?
launchctl print user/$(id -u)/com.<your>.monday-plan

# Run it now (test)
launchctl start com.<your>.monday-plan

# Force unload + reload (after editing)
launchctl unload ~/Library/LaunchAgents/com.<your>.monday-plan.plist
launchctl load ~/Library/LaunchAgents/com.<your>.monday-plan.plist
```

For visibility: every plist should redirect stdout/stderr to a path under `/tmp/` or `~/Library/Logs/`. When debugging, those paths are your trail.

## On Linux: use systemd timers

If you're on Linux, the equivalent is `systemd` user timers:

```
# ~/.config/systemd/user/monday-plan.timer
[Unit]
Description=Monday plan trigger

[Timer]
OnCalendar=Mon *-*-* 09:00:00
Persistent=true   # the "handles missed runs" behavior

[Install]
WantedBy=timers.target
```

```
# ~/.config/systemd/user/monday-plan.service
[Unit]
Description=Monday plan workflow

[Service]
Type=oneshot
ExecStart=/home/<u>/.local/bin/monday-plan
```

Load:
```bash
systemctl --user enable monday-plan.timer
systemctl --user start monday-plan.timer
```

`Persistent=true` is the launchd equivalent — handles missed runs after machine wake.

## Field-tested gotchas

**Plist permission bits matter.** A plist owned by another user, or non-readable, won't load. Verify with `ls -la ~/Library/LaunchAgents/`.

**Editing a loaded plist requires unload-reload.** Editing in place without unloading first leaves the old version running. Unload, edit, load.

**A typo in plist XML produces "Could not parse" error.** `plutil ~/Library/LaunchAgents/foo.plist` validates the syntax before loading.

**launchd kills runs that exceed 5-second SIGTERM.** Long-running scripts get killed. For long-running, daemonize the work and have launchd just kick it off.

**`$HOME` in scripts run by launchd is set to your home, but `$PATH` is bare.** Set PATH explicitly in your script or the plist.

**LaunchAgent vs LaunchDaemon.** Agents run as your user when you're logged in. Daemons run system-wide. For personal rituals, always Agents (in `~/Library/LaunchAgents/`).

**The `StartCalendarInterval` plist semantics are picky.** A plist with both `StartInterval` AND `StartCalendarInterval` typically ignores one. Pick one.

## Innovative pattern: tmux-aware triggers

Your script checks for an active tmux session and routes output to a specific pane:

```bash
if tmux has-session -t main 2>/dev/null; then
  tmux send-keys -t main:0.0 "less /tmp/monday-plan.out" Enter
fi
```

When you arrive Monday morning, the worksheet is already open in your main tmux pane.

## Innovative pattern: ntfy on failure only

If the script succeeded, no notification. If it failed, ntfy to your phone with the error:

```bash
#!/usr/bin/env bash
set -e
{
  # Your workflow
} || {
  curl -d "Monday plan failed: $(tail -3 /tmp/monday-plan.err)" \
       ntfy.sh/<your-topic>
  exit 1
}
```

You're not pinged for routine success; you ARE pinged when something needs attention.

## Innovative pattern: chained ritual triggers

Some rituals depend on others. Friday retro should run AFTER the week's Project Updates are filed.

Solution: ritual-A fires, on success kicks ritual-B via `launchctl start`:

```bash
# In ritual-A's script
post-update.sh
launchctl start com.<your>.friday-retro
```

The dependency is expressed in the script, not in launchd config. Easier to reason about.

## Related

- [Monday planning](./monday-planning.md) — script that launchd fires
- [Friday retro](./friday-retro.md) — script that launchd fires
- [ntfy notifications](./ntfy-notifications.md) — what the script pushes
- [Chapter 06 — Session discipline](../06-session-discipline/) — wrap/resume patterns that hook into rituals
