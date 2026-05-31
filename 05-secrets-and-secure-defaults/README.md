# 05 — Secrets and secure defaults

> All secrets live in a password manager. Zero plaintext in config files. Tokens exposed to environment at session start, not at rest.

This chapter is short because the principle is simple. The mechanics matter though.

## What this chapter covers

| Section | What it solves |
|---|---|
| [Bitwarden via rbw](./bitwarden-via-rbw.md) | The CLI-first password manager pattern. Full alternatives table + 2025–2026 incident review. |
| [SSH agent via rbw](./ssh-agent-via-rbw.md) | SSH key signing without leaving keys in plaintext on disk. Agent comparison + YubiKey. |
| [Never commit secrets](./never-commit-secrets.md) | Pre-commit hooks (working YAML), secret-scanner comparison, `git filter-repo` recovery. |
| [Git signing](./git-signing.md) | Commit signing with SSH keys, forge verification matrix, post-quantum status. |
| [Cloud-session pattern](./cloud-session-pattern.md) | Secrets when `rbw` isn't there: cloud agents, CI, OIDC, OS keyrings. |
| [Supply chain 2026](./supply-chain-2026.md) | npm/PyPI/cargo incident hygiene: provenance, `audit signatures`, post-incident recipe. |

## Threat model assumed

This chapter is written for **one specific threat model**. If yours differs, the recommendations shift.

| Assumption | Implication |
|---|---|
| **Solo operator, no insider threat.** | No need for shared-vault access control, break-glass, or per-user audit. One vault, one human. |
| **Software keys are the baseline.** | Keys live encrypted-at-rest in a vault; decrypted in memory on use. Good enough for almost everything. |
| **Hardware keys for high-stakes only.** | Production deploy keys, signing keys, root-of-trust → YubiKey / Secure Enclave. Not every key. ([ssh-agent-via-rbw](./ssh-agent-via-rbw.md)) |
| **The laptop is the trust boundary.** | A stolen-but-locked laptop should leak nothing. A stolen-and-unlocked laptop is game over — that's what the 24h vault timeout bounds. |
| **Adversary is opportunistic, not targeted.** | Scrapers, leaked-token harvesters, drive-by supply-chain worms — not a nation-state spending two years on you (though [xz](./supply-chain-2026.md) shows that line is thinner than it used to be). |

What this rules out as out-of-scope: corporate insider threat, HSM/KMS fleets, multi-tenant secret distribution, and "encrypt secrets into git" schemes (`git-crypt`/`SOPS` — a separate, contested topic we deliberately don't cover).

## The principle

Every secret you have should:
- Live at rest in a password manager
- Be exposed to your shell environment at session start (or on demand)
- Never appear in plaintext files (`.env`, `~/.linear_api_token`, etc.) EXCEPT as a fallback
- Never appear in commits, anywhere, ever

## The CLI pattern

`rbw` (a Rust CLI for Bitwarden) is one good implementation. Alternatives, with the full decision tree in [bitwarden-via-rbw](./bitwarden-via-rbw.md):
- `bw` (official Bitwarden CLI) — heavier, Node-based
- `pass` (the Unix password manager) — git-backed, GPG-encrypted
- 1Password CLI (`op`) — paid, vendor lock, but the best ergonomics
- `keepassxc-cli` — single-binary, offline, no cloud

Pick one. The pattern that matters:
1. Vault at rest is encrypted
2. CLI accesses vault with a single unlock (24h timeout typical)
3. Shell scripts call the CLI to expose secrets to env at runtime
4. Never grep your `.env` files for secrets — they shouldn't be there

## Token export pattern in `.zshrc`

```bash
# ~/.zshrc — only load when the vault is already unlocked, so shell start never blocks
if rbw unlocked 2>/dev/null; then
  export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key 2>/dev/null)"
  export ANTHROPIC_API_KEY="$(rbw get 'Anthropic API' 2>/dev/null)"
fi
```

Boot → `rbw unlock` once (interactive, once per 24h) → open terminal → tokens load. See [bitwarden-via-rbw](./bitwarden-via-rbw.md) for the stale-vault gotcha.

## Why this matters

- **Lost laptop:** secrets aren't in plaintext, so a stolen-but-locked laptop doesn't immediately leak access.
- **Accidental commit:** CLI-retrieved env vars mean no `.env` file to accidentally commit.
- **Rotation:** rotating a secret means updating one vault entry, not 5 scattered plaintext files.
- **Multi-machine:** Bitwarden sync (or `pass` via git) gives the same vault everywhere.

## What this rules out

- `.env` files with real secrets; `~/.<tool>-token` files; `~/.<tool>.config` JSON with API keys
- Hardcoded tokens in scripts
- Secrets pasted into tickets, commit messages, or chat

If a secret slips through anyway, the recovery procedure (rotate first, history-rewrite last) lives in [never-commit-secrets](./never-commit-secrets.md).

## Version matrix (verified May 2026)

| Tool | Version | Note |
|---|---|---|
| `rbw` | 1.15.0 (2025-12-31)[¹] | Feature-complete; native SSH-key vault entries since 1.14.0. |
| Bitwarden clients | 2025.8.0+[²] | DEF CON 33 clickjacking fix. |
| OpenSSH | 10.0 (Apr 2025)[³] | PQ key exchange default; PQ *signatures* not yet. |
| Git | ≥ 2.34 for SSH signing | OpenSSH ≥ 8.8 (8.7 has broken signing). |
| `gitleaks` | 8.30.1 (2026-03-21)[⁴] | Pin the tag in `.pre-commit-config.yaml`. |
| `detect-secrets` | 1.5.0[⁵] | Baseline workflow; current latest. |

## Field tests beyond the author

The patterns here aren't author-only. `rbw` ships in Arch, Homebrew, nixpkgs and Debian with a steady release cadence through 2025[¹]. The "rotate first, clean up second" doctrine is the explicit guidance in GitHub's own removing-sensitive-data docs and every post-incident write-up we cite in [supply-chain-2026](./supply-chain-2026.md). SSH commit signing (vs GPG) is the path GitHub, GitLab, Codeberg and Forgejo all document as first-class today ([git-signing](./git-signing.md)). Where a claim is the author's own taste rather than externally validated, it's flagged inline.

## What we'd change in 2026

- **OIDC over long-lived tokens** wherever a machine talks to a cloud. The 2025 npm wave (qix, Shai-Hulud) was a stolen-static-token story end to end. See [cloud-session-pattern](./cloud-session-pattern.md).
- **Provenance is now table stakes.** `npm audit signatures`, PyPI Trusted Publishers, Sigstore attestations all went GA. [supply-chain-2026](./supply-chain-2026.md).
- **Hardware-backed keys got easy.** `ssh-keygen -t ed25519-sk` + a $25 key is no longer exotic; use it for your highest-stakes key.
- **Passkeys for the human, keys for the machine.** Passkeys replaced our 2FA-app dependence for service logins; they do *not* replace SSH keys or API tokens ([git-signing](./git-signing.md) §passkeys).

## Related

- [Chapter 03 — MCP routing](../03-claude-code-as-operator/mcp-routing.md) — never use browser MCPs on credential pages
- [Chapter 06 — Audit pattern](../06-session-discipline/audit-and-conventions-pattern.md) — audit log captures all secret-related changes

---

[¹]: https://github.com/doy/rbw/blob/main/CHANGELOG.md — accessed 2026-05-31
[²]: https://www.bleepingcomputer.com/news/security/major-password-managers-can-leak-logins-in-clickjacking-attacks/ — accessed 2026-05-31
[³]: https://www.openssh.com/pq.html — accessed 2026-05-31
[⁴]: https://github.com/gitleaks/gitleaks/releases — accessed 2026-05-31
[⁵]: https://github.com/Yelp/detect-secrets/releases — accessed 2026-05-31
