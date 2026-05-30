# ntfy notifications

> Push notifications without Apple Push or Google FCM. Works on any phone with the ntfy app.

## Why ntfy

The alternatives:
- **Apple Push (APNs)** — requires Apple Developer account, iOS/macOS only
- **Google FCM** — requires Firebase setup, Google account
- **Email** — slow, mixed with other email noise
- **SMS** — costs money per message, no group/topic structure
- **ntfy** — HTTP POST → phone push. Self-hostable or free public service. Works everywhere.

For solo dev:
- **Free for personal volume** at `ntfy.sh`
- **Self-hostable** for stricter requirements (`docker run binwiederhier/ntfy serve`)
- **Phone-app available** for iOS, Android, GrapheneOS, and as a web subscription
- **CLI-first** — `curl -d "message" ntfy.sh/<topic>` and done

## The recipe

1. Pick a unique topic name. Treat it like a password (anyone who knows the topic can publish or subscribe).
   - Don't use guessable names like `monday-plan`. Use long, unpredictable strings: `vtl-monday-z7k4f9q`.
   - Store it in your password manager.

2. Install the ntfy app on your phone. Subscribe to your topic.

3. Publish from any script:
   ```bash
   curl -d "Monday plan ready" ntfy.sh/<your-topic>
   ```

4. Wire to launchd / rituals.

## Concrete patterns

### Send a simple notification

```bash
curl -d "Monday plan ready — open browser to <URL>" ntfy.sh/<your-topic>
```

### With a title and priority

```bash
curl \
  -H "Title: Monday Plan" \
  -H "Priority: high" \
  -d "Open This Week view to start" \
  ntfy.sh/<your-topic>
```

Priority: 1 (min) → 5 (max). Default is 3.

### With a tag (emoji on phone)

```bash
curl \
  -H "Title: Friday Retro" \
  -H "Tags: clipboard,calendar" \
  -d "Linear Project Update reminder fired — review at 16:30" \
  ntfy.sh/<your-topic>
```

[Tag emoji reference](https://docs.ntfy.sh/emojis/).

### With an action link (clickable button)

```bash
curl \
  -H "Title: Monday Plan" \
  -H "Actions: view, Open This Week, <URL>" \
  -d "Click to open Linear" \
  ntfy.sh/<your-topic>
```

The "Open This Week" button on the phone notification jumps to the URL.

## Loading the topic from your password manager

The topic IS sensitive — leaks let anyone push to your phone. Store it in your password manager.

```bash
#!/usr/bin/env bash
NTFY_TOPIC="$(rbw get 'ntfy topic' --field topic)"
curl -d "$*" "ntfy.sh/$NTFY_TOPIC"
```

Wire as `ntfy-send` in `~/.local/bin/`. Now scripts everywhere can `ntfy-send "message"`.

## Self-hosting

For stricter privacy, run your own ntfy:

```bash
docker run \
  -v ~/ntfy-config:/etc/ntfy \
  -v ~/ntfy-cache:/var/cache/ntfy \
  -p 80:80 \
  -d --restart unless-stopped \
  binwiederhier/ntfy serve \
  --base-url https://ntfy.<your-domain>
```

The trade-off:
- **Public `ntfy.sh`** — zero setup, but topic visibility risk if leaked
- **Self-hosted with auth** — requires server, but isolated from public ntfy traffic

For personal solo-dev volume, `ntfy.sh` with a long, well-protected topic is sufficient.

## Multiple topics for differentiated badges

Subscribe to one topic per ritual category. Phone shows separate notification feeds:

| Topic | Used for |
|---|---|
| `<prefix>-monday-plan` | Weekly Monday trigger |
| `<prefix>-friday-retro` | Weekly Friday trigger |
| `<prefix>-triage-pending` | Triage > 48h old alert |
| `<prefix>-script-errors` | Any launchd script failure |
| `<prefix>-claude-blocked` | Agent hit a checkpoint, needs human |

When your phone buzzes, the topic tells you which kind of attention is needed without opening the app.

## Common script patterns

### Notify on failure only

```bash
#!/usr/bin/env bash
set -e
{
  # Your workflow
  ...
} || {
  ntfy-send "Script <name> failed: $(tail -3 /tmp/script.err)"
  exit 1
}
```

Success: silent. Failure: pinged.

### Notify with structured info

```bash
ntfy-send "<<< Triage pending >>>
Items in Triage > 48h: 7
Top: $(linearis issues list --state Triage --order created --limit 1)
Open: linear.app/<workspace>/team/<team>/triage"
```

The multi-line body renders well on phone.

### Conditional notifications

```bash
TRIAGE_COUNT=$(linearis issues list --state Triage --format json | jq '.[] | select(.createdAt < (now - 48*3600)) | .id' | wc -l)

if [ "$TRIAGE_COUNT" -gt 5 ]; then
  ntfy-send "Triage pile-up: $TRIAGE_COUNT old items"
fi
```

Only ping when threshold crossed.

## Field-tested gotchas

**Topic is the only auth.** Anyone with the topic can publish. Keep it long and protected.

**Public `ntfy.sh` has no rate limit per user**, but excessive use can get IP-throttled. Personal volume is fine.

**Phone app battery drain.** Stays connected via push. Negligible in practice on modern phones.

**Self-hosted ntfy without TLS leaks topic + payload.** If you self-host, terminate TLS (nginx in front, Caddy, etc.).

**ntfy doesn't store messages for offline subscribers by default.** If your phone is off when a message arrives, it's gone. Use `Cache-Control: max-age=86400` headers if you need history.

**Background agents on certain setups can't run `ntfy-send`** — see [browser-tools gotchas](../03-claude-code-as-operator/browser-tools.md). Run notifications from the main session.

## Innovative pattern: ntfy as a sub-protocol for agent ↔ human handoff

Long-running agent flows that hit a checkpoint:
```bash
# Inside the agent's workflow
ntfy-send "Agent: $TICKET_ID hit checkpoint — needs decision. View: $TICKET_URL"
# Wait for some signal that the human responded
```

The phone push is the agent ↔ human bridge. You're at lunch; phone buzzes; you decide; agent continues.

## Innovative pattern: ntfy + iCal subscription

Convert ntfy publish history into an `.ics` feed. Past notifications become calendar events viewable in any calendar app.

```bash
# After every ntfy-send, also write to ~/.local/share/ntfy-history/<topic>.ics
```

Useful for "what alerts fired in the past week?"

## Related

- [launchd over cron](./launchd-over-cron.md) — what fires the script that ntfys
- [Monday planning](./monday-planning.md) — uses ntfy as the morning push
- [Chapter 05 — Bitwarden via rbw](../05-secrets-and-secure-defaults/bitwarden-via-rbw.md) — store the topic securely
- [00 — Calendar neutrality](../00-principles/calendar-neutrality.md) — why ntfy over APNs / FCM
