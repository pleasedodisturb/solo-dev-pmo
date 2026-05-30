# 05 — Secrets and secure defaults

> All secrets live in a password manager. Zero plaintext in config files. Tokens exposed to environment at session start, not at rest.

This chapter is short because the principle is simple. The mechanics matter though.

## What this chapter covers

| Section | What it solves |
|---|---|
| [Bitwarden via rbw](./bitwarden-via-rbw.md) | The CLI-first password manager pattern. Alternatives noted. |
| [SSH agent via rbw](./ssh-agent-via-rbw.md) | SSH key signing without leaving keys in plaintext on disk. |
| [Never commit secrets](./never-commit-secrets.md) | Pre-commit hooks, secret scanning, recovery if you slip. |
| [Git signing](./git-signing.md) | Commit signing with SSH keys, gotchas about agent dependence. |

## The principle

Every secret you have should:
- Live at rest in a password manager
- Be exposed to your shell environment at session start (or on demand)
- Never appear in plaintext files (`.env`, `~/.linear_api_token`, etc.) EXCEPT as a fallback
- Never appear in commits, anywhere, ever

## The CLI pattern

`rbw` (a Rust CLI for Bitwarden) is one good implementation. Alternatives:
- `bw` (official Bitwarden CLI) — heavier, Node-based
- `pass` (the Unix password manager) — git-backed, GPG-encrypted
- 1Password CLI (`op`) — vendor lock but well-built
- KeePassXC CLI

Pick one. The pattern that matters:
1. Vault at rest is encrypted
2. CLI accesses vault with a single unlock (24h timeout typical)
3. Shell scripts call the CLI to expose secrets to env at runtime
4. Never grep your `.env` files for secrets — they shouldn't be there

## Token export pattern in `.zshrc`

```bash
# ~/.zshrc

# Linear API token
export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key 2>/dev/null)"

# Anthropic API key (for direct API calls)
export ANTHROPIC_API_KEY="$(rbw get 'Anthropic API' 2>/dev/null)"

# ... other tokens
```

Or wrap in a `load-tokens.sh` sourced at session start.

The vault must be unlocked for these to succeed. The pattern:
1. Boot machine
2. `rbw unlock` (interactive password prompt; once per 24h)
3. Open terminal → tokens load automatically
4. 24h later, repeat

## Why this matters

- **Lost laptop scenario:** if your secrets aren't in plaintext, a stolen laptop doesn't immediately leak access. The attacker needs the vault password.
- **Accidental commit scenario:** if your secrets are in a CLI-retrieved env var, no `.env` file accidentally gets committed.
- **Rotation scenario:** rotating a secret means updating one vault entry, not 5 plaintext files scattered across your home dir.
- **Multi-machine scenario:** Bitwarden sync (or pass via git) gives you the same vault on every machine.

## What this rules out

- `.env` files with real secrets
- `~/.<tool>-token` files containing tokens
- `~/.<tool>.config` JSON with API keys
- Hardcoded tokens in scripts
- Secrets pasted into tickets, commit messages, or chat

## Recovery if you slip

If you accidentally commit a secret:
1. **Treat the secret as compromised.** Even if you force-push to remove it, assume it's been seen.
2. **Rotate the secret immediately.** Generate a new one in the source service (Linear, Anthropic, GitHub, etc.).
3. **Update the vault** with the new secret.
4. **Sweep your scripts** for any places that might have hardcoded the old secret.
5. **Revoke the old secret** in the source service if possible.

Don't try to clean up by force-pushing alone. GitHub indexes old commits; even after force-push, the secret has been scraped.

## Related

- [Chapter 03 — MCP routing](../03-claude-code-as-operator/mcp-routing.md) — never use browser MCPs on credential pages
- [Chapter 06 — Audit pattern](../06-session-discipline/audit-and-conventions-pattern.md) — audit log captures all secret-related changes
