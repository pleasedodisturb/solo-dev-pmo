# Cloud-session secret pattern

> When `rbw` isn't there: cloud Claude Code sessions, CI runners, fresh machines. The rule is the same everywhere — never put a credential into an environment you don't fully control that is more privileged or longer-lived than the task needs.

> **This file was written in exactly such an environment** — a cloud Claude Code session that cannot reach a local vault. The recipes below are the patterns that environment *should* use; mark each `TESTED LOCALLY ON: ____` after a real pass.

## The problem

The whole chapter assumes `rbw unlock` reaching a local Bitwarden agent. That assumption breaks in three common places:

- **Cloud Claude Code sessions** — an ephemeral container, cloned fresh, reclaimed after inactivity. No local vault, no agent socket. ([docs](https://code.claude.com/docs/en/claude-code-on-the-web))
- **CI runners** — GitHub Actions, etc. No human to type a master password.
- **A brand-new machine** before you've set up rbw.

Copying a long-lived personal token into any of these is the wrong move — it's exactly the static-token exposure that drove the 2025 npm wave ([supply-chain-2026](./supply-chain-2026.md)).

## The ladder (most preferred first)

### 1. Don't expose the secret at all

Most agent/CI tasks — editing docs, running tests, opening a PR — need no production credential. Scope the task so the secret never enters the environment. This is the default, not a cop-out.

### 2. OIDC / workload identity (best when a machine must talk to a cloud)

GitHub Actions can mint a short-lived OIDC token and exchange it for a cloud credential that is valid for **one job and auto-expires** — no long-lived secret stored anywhere.[¹]

```yaml
permissions:
  id-token: write          # let the job request an OIDC token
  contents: read
steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789:role/ci-deploy
      aws-region: us-east-1
      # no aws-access-key-id / secret — the OIDC trust on the cloud side issues a scoped, expiring token
```

This is *the* answer for production workload auth. Every token is scoped, auditable, and rotated per run.[¹]

### 3. Platform secret store, injected as a scoped env var

When OIDC doesn't fit, use the platform's encrypted secret store (GitHub Actions Secrets/Environments with required reviewers; the cloud session's configured environment variables). Rules:

- Use a **dedicated, least-privilege token**, never your personal one.
- Set a short expiry and rotate on a schedule.
- Confirm the platform masks it in logs.

### 4. Encrypted env file, decrypted at job start

Only if 2–3 don't fit. Keep an `age`-encrypted file in the repo, decrypt at job start with a key pulled from the platform store. The decryption key still lives in the platform store — so this buys little over (3) and adds moving parts. (Note: this is *not* the contested "commit plaintext-equivalent secrets to git" pattern the chapter rules out — the ciphertext is useless without the platform-held key.)

### 5. OS-level keyring (local fallback, no password manager)

On a machine with no rbw but a desktop keyring, the OS credential store is a reasonable stopgap:

| OS | Store | Store / retrieve |
|---|---|---|
| **Linux** | libsecret / GNOME Keyring[²] | `secret-tool store --label=linear service linear key api` / `secret-tool lookup service linear key api` |
| **macOS** | Keychain[³] | `security add-generic-password -a "$USER" -s linear-api -w` / `security find-generic-password -a "$USER" -s linear-api -w` |
| **Windows** | Credential Manager | `cmdkey /generic:linear-api /user:me /pass:<tok>` (retrieve via PowerShell `CredentialManager` module; `cmdkey` stores but won't print the secret back) |

```bash
# Linux example — prompts for the value, stores it in the keyring, reads it back
secret-tool store --label='Linear API' service linear key api
export LINEAR_API_TOKEN="$(secret-tool lookup service linear key api)"
```

**TESTED LOCALLY ON: ____ (fill in).**

## Cloud Claude Code session specifics

- The session runs in an isolated, ephemeral container with whatever env vars / secrets the **environment was configured with** (and a chosen network policy). Use that mechanism — don't paste a secret into the chat and don't commit one.
- GitHub operations go through the session's GitHub integration / MCP, not a plaintext PAT.
- If a task genuinely needs a secret, add it to the environment's secret config as a **scoped, low-privilege, short-lived** credential, reference it via env var, and **rotate it after the session** — treat anything exposed to an ephemeral cloud env as burned once the task is done.
- Never reconstruct your local `rbw` flow in the cloud. There's no vault to unlock; pretending otherwise just tempts you to paste a token.

## Anti-patterns

- Pasting a long-lived personal PAT into a CI secret "just to unblock it."
- Echoing a secret to stdout to "check it loaded" — it lands in build logs.
- Reusing one god-token across local, CI, and cloud. Scope per environment.
- Committing an `age`/`sops` file *and* its key (defeats the point — see the chapter's rule against encrypt-into-git schemes).

## Related

- [Bitwarden via rbw](./bitwarden-via-rbw.md) — the local-machine baseline this file falls back from
- [Supply chain 2026](./supply-chain-2026.md) — why static tokens are the liability OIDC removes
- [Never commit secrets](./never-commit-secrets.md) — recovery if a cloud/CI token leaks

---

[¹]: https://docs.github.com/en/actions/concepts/security/openid-connect — accessed 2026-05-31
[²]: https://wiki.archlinux.org/title/GNOME/Keyring — accessed 2026-05-31
[³]: https://ss64.com/mac/security.html — accessed 2026-05-31
