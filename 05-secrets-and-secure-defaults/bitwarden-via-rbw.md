# Bitwarden via rbw

> CLI access to Bitwarden vault. Single unlock per 24h. Scripts retrieve secrets via env vars exposed at session start.

> **Cloud caveat:** every `rbw`/agent recipe below is shell that must run on a real machine with a vault. Written in a cloud session that can't run `rbw`. **TESTED LOCALLY ON: ____ (fill in).**

## Why rbw

[`rbw`](https://github.com/doy/rbw) is a Rust CLI for Bitwarden by Jesse Luehrs (doy). Why this over the official `bw` CLI:

- **No Node dependency** — the official CLI requires Node; `rbw` is a single binary.
- **Background agent** — `rbw-agent` holds keys in memory like `ssh-agent`; you unlock once per 24h, subsequent calls are instant.
- **Stays usable offline** — caches your last sync; works without network.
- **`rbw-ssh-agent`** — SSH agent backed by Bitwarden (see [SSH agent via rbw](./ssh-agent-via-rbw.md)). As of 1.14.0 (2025-08) rbw also has native SSH-key vault entries.[¹]

**Honest maintenance status (verified May 2026):** rbw is **feature-complete, not abandoned**. Latest is 1.15.0 (2025-12-31).[¹] The maintainer fixes regressions and merges feature PRs but won't self-drive new features. That's a *stable*, one-maintainer project — fine for a personal tool, but if you need a vendor SLA or a big community, pick `op` or official `bw`. This is the single biggest honest caveat in the chapter.

## Setup

```bash
# macOS
brew install rbw

rbw config set email <your-email@example.com>
rbw config set base_url https://vault.bitwarden.com   # or your self-host

rbw unlock   # interactive password prompt
rbw list     # test
```

After setup, `rbw-agent` runs in background; subsequent calls don't prompt.

## Daily usage

```bash
rbw get "GitHub PAT"                          # get a password
rbw get "Linear API" --field linear_api_key   # get a custom field
rbw list                                       # all entry names
rbw list | grep -i linear                      # search
rbw lock                                        # force next use to prompt
rbw unlock                                      # interactive
```

## Storing tokens

Treat API tokens as "secure notes" with the token in the password field OR a custom field.

For Linear: Secure note named `Linear API`, custom field `linear_api_key` (type `hidden`). For a GitHub PAT: a Login named `GitHub PAT` with the PAT in the password field. One secret → password field. Multiple → custom fields.

```bash
LINEAR_TOKEN=$(rbw get 'Linear API' --field linear_api_key)
GH_TOKEN=$(rbw get "GitHub PAT")
```

## Wiring to `.zshrc`

```bash
# ~/.zshrc — the `if rbw unlocked` guard stops shell start from blocking when locked
if rbw unlocked 2>/dev/null; then
  export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key 2>/dev/null)"
  export ANTHROPIC_API_KEY="$(rbw get 'Anthropic API' 2>/dev/null)"
  export GH_TOKEN="$(rbw get 'GitHub PAT' 2>/dev/null)"
fi
```

## CLI password-manager comparison

The pattern transfers to any of these. The differences that actually matter:

| | `rbw` | `bw` (official) | `pass` | `op` (1Password) | `keepassxc-cli` |
|---|---|---|---|---|---|
| **Backend / sync** | Bitwarden cloud or self-host | Bitwarden cloud or self-host | git repo you manage | 1Password cloud | one `.kdbx` file you sync (Syncthing/Dropbox) |
| **Runtime deps** | single Rust binary | Node.js | shell + GPG (or `age`) | single binary | single binary |
| **Persistent agent** | yes (`rbw-agent`) | no (`BW_SESSION` env) | `gpg-agent` | yes (`op` daemon) | no |
| **Native SSH agent** | yes (`rbw-ssh-agent`) | no | via `gpg-agent` | yes | via KeePassXC GUI |
| **Offline** | cached | cached | always | cached | always (local file) |
| **GUI / phone app** | use Bitwarden apps | use Bitwarden apps | third-party only | first-class | KeePassXC + third-party mobile |
| **Cost** | free | free | free | paid subscription | free |
| **Support** | one maintainer, unofficial | vendor-backed | community | vendor-backed | community |

### When to pick something else (decision tree)

- **Pick `op`** if you already pay for 1Password and want the smoothest CLI + GUI + SSH-agent + secret-reference (`op://`) story. Best ergonomics, full stop — at the cost of subscription + proprietary lock. `op` is fine as an *alternative*, never a *required* dep.
- **Pick `pass`** if you want zero cloud trust, already live in GPG (or `age` via the `passage` fork), and will manage your own git sync. Most transparent, most fiddly. See [pass details](#pass-the-unix-password-manager).
- **Pick `keepassxc-cli`** if you want a single encrypted file you fully control and sync yourself, plus a solid GUI.
- **Pick official `bw`** if you want Bitwarden but only a vendor-supported client and don't mind Node + manual `BW_SESSION` handling.
- **Pick `rbw`** (the default here) if you want Bitwarden's sync and free tier, a fast single binary, and agent ergonomics — and you accept the one-maintainer, feature-complete reality above.

### `pass` (the Unix password manager)

```bash
pass insert linear-api-token        # store (prompts, GPG-encrypts)
LINEAR_TOKEN=$(pass linear-api-token)  # retrieve
```

GPG-encrypted, git-backed. Modern setups can swap GPG for [`age`](https://github.com/FiloSottile/age) via the [`passage`](https://github.com/FiloSottile/passage) fork — simpler key management, no GPG web-of-trust baggage. Tradeoff: you run your own sync; no official phone app.

## 2025–2026 password-manager incident review

No manager is breach-proof. None of the below changes the recommendation — they reinforce *CLI-first usage, a strong master password, and keeping clients updated*.

- **LastPass (2022, still relevant).** Encrypted vaults were exfiltrated and are still being brute-forced years later — the reason a high-iteration KDF and a long master password matter regardless of vendor.[²]
- **DEF CON 33 clickjacking (Aug 2025).** Marek Tóth demonstrated stealing passwords/TOTP/cards from six managers' **browser extensions** (incl. Bitwarden, 1Password, LastPass) via autofill clickjacking; Bitwarden fixed it in 2025.8.0.[³] **CLI-first usage (`rbw`) sidesteps the browser-extension attack surface entirely** — a real point in its favor.
- **Cloud-vault recovery-attack study (Feb 2026).** Academic researchers reported 25 recovery-flow attacks across cloud managers (Bitwarden 12, LastPass 7, Dashlane 6, 1Password 2). Coordinated 90-day disclosure; remediation underway; **no evidence of in-the-wild exploitation.**[⁴]

Differentiators that survive these: (a) strong KDF / high iteration count, (b) minimal browser-extension surface, (c) responsive disclosure handling.

## Field-tested gotchas

**`rbw unlock` requires interactive input.** Cron / launchd jobs can't unlock. Unlock interactively once per 24h; let the agent serve the rest.

**The 24h timeout is configurable** (`rbw config set lock_timeout 86400`). Shorter = more interruption; longer = bigger stolen-laptop window.

**`rbw list` doesn't show custom field names.** Standardize: every API-token entry has a field `<service>_api_key`.

**Edits made on phone/web need `rbw sync` first.** rbw reads its local cache.

### Stale-vault diagnostic (`rbw unlocked` lies)

The nastiest failure: `rbw unlock` succeeded earlier, `rbw unlocked` still reports unlocked, but `rbw get` returns empty — so your `.zshrc` exports an **empty** token and downstream calls fail silently with a confusing 401. Trigger: laptop sleep/resume, or entries changed server-side without a local `rbw sync`.

```bash
# rbw-diagnose: distinguish "locked" from "unlocked but stale"
rbw-diagnose() {
  if ! rbw unlocked 2>/dev/null; then
    echo "vault LOCKED — run: rbw unlock"; return 1
  fi
  if ! rbw get "Anthropic API" >/dev/null 2>&1; then
    echo "agent reports unlocked but retrieval FAILED — stale agent"
    echo "fix: rbw lock && rbw sync && rbw unlock"; return 2
  fi
  echo "vault OK"
}
```

Fix sequence is always: `rbw lock && rbw sync && rbw unlock`. **TESTED LOCALLY ON: ____ (fill in).**

## Innovative pattern: cheatsheet per secret entry

In each entry's notes field, paste the recipe for using that secret. Future-you opens the entry and sees both the token AND how to use it:

```
Usage: export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key)"
Rotation: rotate-secret.sh linear
Source: linear.app/settings/api
```

A `rotate-secret.sh` that generates a new token, `rbw edit`s the entry, re-exports, and runs a smoke test turns rotation from a 30-minute chore into one command.

## Related

- [SSH agent via rbw](./ssh-agent-via-rbw.md) — SSH-key version of the same pattern
- [Never commit secrets](./never-commit-secrets.md) — what to do when the secret almost-leaks
- [Cloud-session pattern](./cloud-session-pattern.md) — when `rbw` isn't available at all
- [Chapter 01 — I/O rules](../01-linear-as-load-bearing-pm/io-rules.md) — Linear token usage

---

[¹]: https://github.com/doy/rbw/blob/main/CHANGELOG.md — accessed 2026-05-31
[²]: https://blog.lastpass.com/posts/notice-of-recent-security-incident — accessed 2026-05-31
[³]: https://www.bleepingcomputer.com/news/security/major-password-managers-can-leak-logins-in-clickjacking-attacks/ — accessed 2026-05-31
[⁴]: https://thehackernews.com/2026/02/study-uncovers-25-password-recovery.html — accessed 2026-05-31
