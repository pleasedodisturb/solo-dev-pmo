# ntfy notifications

> Push to your phone over plain HTTP, no Apple Push or Google FCM account. Works
> on iOS, Android, and GrapheneOS.

> **Untested-in-this-pass caveat.** The `curl` recipes below are written but
> **not delivery-tested** against a live topic/device in this research pass. Test
> each on your own topic + phone before wiring to a ritual.

## Why ntfy

| Channel | Account needed | Self-host | Cost |
|---|---|---|---|
| Apple Push (APNs) | Apple Developer | no | — |
| Google FCM | Firebase/Google | no | — |
| SMS | carrier | no | per-message |
| **ntfy** | **none** | **yes** | **free tier** |

ntfy is Apache-2.0; use the hosted `ntfy.sh` or run the same binary yourself.[¹]

### Is ntfy.sh still free? (re-checked 2026-05-31)

Yes. `ntfy.sh` still has a **no-signup free tier**: publish/subscribe to a topic
with no account. The maintainer's stated free limits are **250 messages/day,
5 emails/day, 0 phone calls, 2 MB/attachment, no reserved topics**.[²] Paid tiers
(higher caps, reserved topics, phone calls) are **additive**, not a replacement —
the free push the rest of this chapter relies on is intact. (Exact paid prices
move; check the live upgrade dialog rather than trusting a cached number.[²])

## The recipe

1. Pick an **unguessable** topic — anyone who knows it can publish *and*
   subscribe. Treat it like a password (`vtl-triage-z7k4f9q`, not `triage`).
   Store it in your password manager
   ([Chapter 05](../05-secrets-and-secure-defaults/bitwarden-via-rbw.md)).
2. Install the ntfy app, subscribe to the topic.
3. Publish from any script: `curl -d "message" ntfy.sh/<topic>`.

### Per-ritual curl recipes

```bash
# Morning Triage (daily) — low priority, just a nudge
curl -H "Title: Morning Triage" -H "Tags: sunrise" -H "Priority: low" \
     -d "Triage pass — 10 min cap." "ntfy.sh/$NTFY_TOPIC"

# Monday plan — high priority with a click-through to your saved view
curl -H "Title: Monday plan" -H "Priority: high" \
     -H "Actions: view, Open This Week, https://linear.app/<ws>/team/<TEAM>/active" \
     -d "Cycle plan ready. 15 min." "ntfy.sh/$NTFY_TOPIC"

# Friday retro — default priority, calendar tag
curl -H "Title: Friday retro" -H "Tags: calendar" \
     -d "Project Updates due — pick On/At-Risk/Off Track." "ntfy.sh/$NTFY_TOPIC"

# Monthly cooldown — max priority (you don't want to miss this one)
curl -H "Title: Cooldown week" -H "Priority: max" -H "Tags: broom" \
     -d "Tech-debt + convention sweep this cycle." "ntfy.sh/$NTFY_TOPIC"
```

Priority is `min|low|default|high|max` (1–5); each maps to a separate Android
notification channel.[³] Wrap the topic-from-password-manager lookup once as
`ntfy-send` in `~/.local/bin/` so scripts everywhere can call it:

```bash
#!/usr/bin/env bash
NTFY_TOPIC="$(rbw get 'ntfy topic' --field topic)"
curl -d "$*" "ntfy.sh/$NTFY_TOPIC"
```

## Differentiated badges: one topic per ritual

| Topic | Used for |
|---|---|
| `<prefix>-triage` | daily Triage nudge |
| `<prefix>-monday` | Monday plan |
| `<prefix>-friday` | Friday retro |
| `<prefix>-errors` | any launchd/timer script failure |
| `<prefix>-claude` | agent hit a checkpoint, needs a human |

The buzz pattern tells you the attention type before you open the app — but keep
the count small: every extra channel dilutes the signal of all the others (see
[ritual-fatigue](./ritual-fatigue.md) on alert fatigue).

## Self-hosting

A single Go binary + SQLite; it runs on a **Raspberry Pi or a $5/mo VPS**.[⁴]

```bash
docker run -d --restart unless-stopped \
  -p 80:80 \
  -v /etc/ntfy:/etc/ntfy \
  -v /var/cache/ntfy:/var/cache/ntfy \
  binwiederhier/ntfy serve --base-url https://ntfy.<your-domain>
```

- **TLS:** ntfy supports native ACME/Let's Encrypt, or terminate TLS at a reverse
  proxy (Caddy/nginx). Self-hosting **without** TLS leaks the topic and payload.[⁴]
- **No open ports?** A **Cloudflare Tunnel** exposes a home instance without port
  forwarding (verify large-attachment/WebSocket behavior on the free tunnel).[⁵]
- **iOS instant-push caveat (must-do).** A self-hosted server needs
  `upstream-base-url: "https://ntfy.sh"` in its config for iOS *instant* delivery
  — your server sends a poll-request (message-ID + topic-URL hash only) to
  ntfy.sh, which relays via APNs; the phone then fetches the real message from
  *your* server. Set it to `https://ntfy.sh`, not your own host. Without it, iOS
  delivery degrades to hours.[⁶] (Android is unaffected — it holds its own socket.)

For solo volume, hosted `ntfy.sh` + a long topic is enough. Self-host only if you
need the payload off public infrastructure.

## GrapheneOS and UnifiedPush

UnifiedPush splits push into a **distributor** app (holds one connection; ntfy can
be it) and **connector** apps that register for an endpoint — so apps don't each
keep their own socket (the battery win).[⁷] Supported apps include Element,
SchildiChat, FluffyChat, Tusky, Fedilab, Molly.[⁷]

GrapheneOS push, ranked by current guidance:[⁸]

1. **UnifiedPush with ntfy as distributor** — works out of the box, best
   battery/privacy; only for apps that support UnifiedPush.
2. **Sandboxed Google Play + FCM** — install Play from the GrapheneOS App Store,
   grant it an **unrestricted-battery** exception; covers FCM-only apps.
3. **ntfy app standalone** — fine for your own ritual topics; without Play
   services, grant it a battery exception so the connection survives.

The dominant failure mode on GrapheneOS (and stock Android) is battery
optimization killing the connection — grant the distributor unrestricted battery.

## Getting through Focus / Do Not Disturb

**iOS — manual allowlist (reliable today):**
1. Settings → Focus → *(your Focus)* → **Apps → Allowed Notifications** → add **ntfy**.
2. Same Focus → **Options** → enable **Time Sensitive Notifications**.
3. Settings → Notifications → **ntfy** → **Time Sensitive Notifications** ON.

> **Don't rely on priority alone.** ntfy holds Apple's Critical-Alerts
> entitlement, but per the maintainer the priority-5 → interruption-level wiring
> is **not yet fully shipped** — priority 5 does not reliably pierce iOS Focus
> today.[⁹] Use the manual allowlist above; treat priority-5 piercing as a bonus,
> not a guarantee, and re-check on your installed app version.

**Android — DnD exception:** Settings → Notifications → **Do Not Disturb → Apps**
→ allow ntfy; or long-press a ntfy notification → channel → **Override Do Not
Disturb**. Publish ritual alerts at priority 4–5 so they land on the high/max
channel.[³]

## Alternatives

| Service | Cost | Self-host | iOS | License |
|---|---|---|---|---|
| **ntfy** | free tier (250/day) + paid; free self-hosted | yes | yes (APNs relay) | Apache-2.0 |
| Pushover | one-time ~$5/platform | no | yes | proprietary |
| Pushbullet | free tier; Pro ~$5/mo | no | weak | proprietary |
| Gotify | free (self-host only) | yes | **no first-party app** | MIT |
| Apprise | free (it's a dispatch *library*) | n/a | via backend | BSD-2 |

[Apprise](https://github.com/caronc/apprise) is the right tool when you want one
config to fan out to several of the above; it's not itself an endpoint.[¹⁰]
Gotify's missing first-party iOS app is the disqualifier for an iOS-centric
setup.[¹⁰] None beats ntfy's free + self-hostable + cross-platform combination for
this use case, so the chapter stays on ntfy.

## Field-tested gotchas

- **Topic is the only auth.** Long and protected, always.
- **Offline = missed.** ntfy doesn't store for offline subscribers by default;
  publish with `Cache: yes` / a `Cache-Control` window if you need history.
- **Background agents may not reach `ntfy-send`** — run notifications from the
  main session (see [Chapter 03](../03-claude-code-as-operator/browser-tools.md)).

## Related

- [launchd over cron](./launchd-over-cron.md) / [linux-systemd-variant](./linux-systemd-variant.md) — what fires the script that pushes
- [Monday planning](./monday-planning.md) — uses ntfy as the morning push
- [ritual-fatigue](./ritual-fatigue.md) — too many topics is its own failure mode
- [Chapter 05 — Bitwarden via rbw](../05-secrets-and-secure-defaults/bitwarden-via-rbw.md) — store the topic securely

---

[1]: https://github.com/binwiederhier/ntfy — ntfy repo, Apache-2.0, hosted-or-self-host — accessed 2026-05-31
[2]: https://github.com/binwiederhier/ntfy/issues/1167 — maintainer: free-tier limits (250 msg/day, 5 emails/day, 2 MB attach, no reserved topics) — accessed 2026-05-31
[3]: https://raw.githubusercontent.com/binwiederhier/ntfy/main/docs/publish.md — priority 1–5 → Android notification channels — accessed 2026-05-31
[4]: https://docs.ntfy.sh/install/ — self-host install (single binary), TLS/ACME — accessed 2026-05-31
[5]: https://noted.lol/ntfy/ — practitioner: ntfy behind a Cloudflare Tunnel — accessed 2026-05-31
[6]: https://raw.githubusercontent.com/binwiederhier/ntfy/main/docs/config.md — iOS instant notifications require `upstream-base-url: https://ntfy.sh` on self-hosted servers — accessed 2026-05-31
[7]: https://unifiedpush.org/users/distributors/ntfy/ — UnifiedPush distributor/connector model; ntfy as distributor; supported apps at /users/apps/ — accessed 2026-05-31
[8]: https://grapheneos.org/usage — GrapheneOS notifications: sandboxed Play/FCM vs UnifiedPush; battery exception — accessed 2026-05-31
[9]: https://github.com/binwiederhier/ntfy/issues/1680 — maintainer: iOS Focus/DnD piercing (priority 4/5) not yet fully configured — accessed 2026-05-31
[10]: https://github.com/caronc/apprise — Apprise: notification dispatch library (BSD-2), fans out to 100+ backends incl. ntfy/Gotify/Pushover — accessed 2026-05-31
