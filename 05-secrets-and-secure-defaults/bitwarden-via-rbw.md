# Bitwarden via rbw

> CLI access to Bitwarden vault. Single unlock per 24h. Scripts retrieve secrets via env vars exposed at session start.

## Why rbw

[`rbw`](https://github.com/doy/rbw) is a Rust CLI for Bitwarden written by Doy. Why this over the official `bw` CLI:

- **No Node dependency** — the official CLI requires Node; `rbw` is a single binary.
- **Background agent** — `rbw-agent` runs as a background process; you unlock once per 24h, then subsequent CLI calls are instant.
- **Stays usable when offline** — caches your last sync; works without network.
- **`rbw-ssh-agent`** — provides SSH key agent backed by Bitwarden (see [SSH agent via rbw](./ssh-agent-via-rbw.md)).

## Setup

```bash
# macOS
brew install rbw

# Configure: tells rbw where your Bitwarden server is
rbw config set email <your-email@example.com>
rbw config set base_url https://vault.bitwarden.com   # or your self-host

# First unlock — interactive password prompt
rbw unlock

# Test
rbw list
```

After setup, `rbw-agent` runs in background; subsequent calls don't prompt.

## Daily usage

```bash
# Get a password
rbw get "GitHub PAT"

# Get a specific field from a custom-field entry
rbw get "Linear API" --field linear_api_key

# List all entries (names only)
rbw list

# Search
rbw list | grep -i linear

# Lock the agent (forces next use to prompt)
rbw lock

# Unlock (interactive)
rbw unlock
```

## Storing tokens

Treat API tokens as "secure notes" in Bitwarden, with the actual token in the password field OR a custom field.

For Linear:
- **Item type:** Secure note
- **Name:** `Linear API`
- **Custom field:** name=`linear_api_key`, value=`<token>`, type=`hidden`

Then:
```bash
LINEAR_TOKEN=$(rbw get 'Linear API' --field linear_api_key)
```

For GitHub PAT:
- **Item type:** Login
- **Name:** `GitHub PAT`
- **Password field:** `<the-PAT>`

Then:
```bash
GH_TOKEN=$(rbw get "GitHub PAT")
```

The choice between password field and custom field depends on whether the entry has multiple secrets. One secret → password field. Multiple → custom fields.

## Wiring to `.zshrc`

```bash
# ~/.zshrc

# Load secrets to env on shell start
if rbw unlocked 2>/dev/null; then
  export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key 2>/dev/null)"
  export ANTHROPIC_API_KEY="$(rbw get 'Anthropic API' 2>/dev/null)"
  export GH_TOKEN="$(rbw get 'GitHub PAT' 2>/dev/null)"
  # ... etc
fi
```

The `if rbw unlocked` guard prevents shell startup from blocking when the vault isn't unlocked yet.

## Alternative implementations

If you don't use Bitwarden:

**`pass`** (the standard Unix password manager):
```bash
# Store
pass insert linear-api-token

# Retrieve
LINEAR_TOKEN=$(pass linear-api-token)
```

GPG-encrypted, git-backed. Tradeoff: requires GPG setup, no native phone app.

**1Password CLI:**
```bash
# Retrieve
LINEAR_TOKEN=$(op read 'op://Vault/Linear/credentials')
```

Slick, but vendor lock and subscription required.

**KeePassXC CLI:**
```bash
keepassxc-cli show -a Password ~/Vaults/personal.kdbx "Linear API"
```

Single-binary, offline, no cloud dep.

The pattern is the point. Pick whatever fits your trust model.

## Linear-specific recipe (as a concrete example)

```bash
# In Bitwarden:
# Item type: Secure Note
# Name: Linear API
# Custom field: linear_api_key (hidden type) = <token from linear.app/settings/api>

# In ~/.zshrc:
export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key 2>/dev/null)"

# Now any script can:
curl -H "Authorization: $LINEAR_API_TOKEN" https://api.linear.app/graphql ...
```

## Field-tested gotchas

**`rbw unlock` requires interactive input.** Cron / launchd jobs that need to unlock fail. The pattern: unlock interactively (once per 24h), let the agent serve subsequent calls.

**`rbw lock` is sometimes accidental.** Scripts that call `rbw lock` will require re-unlock. Audit your scripts.

**The 24h timeout is configurable** (`rbw config set lock_timeout 86400`) but be intentional. Shorter = more interruption; longer = bigger window if laptop is stolen.

**`rbw list` doesn't show custom field names.** You have to remember field names. Standardize: every API token entry has a field called `<service>_api_key`.

**Sync is one-way: pull from Bitwarden, edit locally needs `rbw sync` first.** If you add a new entry on phone or web, `rbw sync` before retrieving locally.

**Bitwarden custom field types matter for export/import.** Use `hidden` for secrets; `text` for usernames. UI sometimes silently changes type.

## Innovative pattern: secret rotation script

A `rotate-secret.sh` that:
1. Generates a new token via the source service's API
2. Updates the Bitwarden entry via `rbw`
3. Re-sources `.zshrc` to expose new token to env
4. Tests that the new token works

Rotation goes from "30-minute manual chore" to "1 command + a unit test."

```bash
#!/usr/bin/env bash
SERVICE=$1
case "$SERVICE" in
  linear)
    # Generate new token
    NEW_TOKEN=$(curl -X POST https://api.linear.app/oauth/token ...)
    # Update Bitwarden
    rbw edit "Linear API" --field linear_api_key="$NEW_TOKEN"
    # Re-export
    export LINEAR_API_TOKEN=$NEW_TOKEN
    # Test
    linearis whoami && echo "✓ Linear rotated"
    ;;
esac
```

## Innovative pattern: `cheatsheet` per secret entry

In your Bitwarden entry's notes field, paste the recipe for using that secret. Future-you opens the entry, sees both the token AND how to use it.

Example for Linear API entry's notes:
```
Usage:
  export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key)"
  curl -H "Authorization: $LINEAR_API_TOKEN" https://api.linear.app/graphql ...

Rotation: rotate-secret.sh linear
Source: linear.app/settings/api
```

## Related

- [SSH agent via rbw](./ssh-agent-via-rbw.md) — SSH-key version of the same pattern
- [Never commit secrets](./never-commit-secrets.md) — what to do when the secret almost-leaks
- [Chapter 01 — I/O rules](../01-linear-as-load-bearing-pm/io-rules.md) — Linear token usage
