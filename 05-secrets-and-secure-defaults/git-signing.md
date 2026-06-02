# Git signing

> Sign commits with an SSH key. Use file-path signing (not `key::` literal). The agent socket matters.

> **Cloud caveat:** signing recipes need a real agent with your key. Written in a cloud session that can't sign. **TESTED LOCALLY ON: ____ (fill in).**

## Why sign

- **Provable authorship** — verified commits show a green checkmark on the forge.
- **Tamper detection** — modified history fails verification.
- **Account-compromise floor** — someone who pushes as you can't produce your signature.

For a solo dev: optional but cheap once set up.

## SSH signing setup (Git 2.34+)

Modern git signs with SSH keys, no GPG. Requires **Git ≥ 2.34** and **OpenSSH ≥ 8.8** — note OpenSSH **8.7 shipped broken signing**, so don't sit on it.[¹]

```
# ~/.gitconfig
[user]
  name = Your Name
  email = your-email@example.com
  signingkey = /Users/<u>/.ssh/<key-name>.pub   # FILE PATH, not key:: literal
[gpg]
  format = ssh
[gpg "ssh"]
  allowedSignersFile = ~/.ssh/allowed_signers
[commit]
  gpgsign = true
```

```
# ~/.ssh/allowed_signers
your-email@example.com ssh-ed25519 AAA...<pubkey contents>
```

The `allowed_signers` file lets `git verify-commit` work locally. Without it, signing still works but local verification fails.

## File path vs `key::` literal

Use a **file path** (`signingkey = /Users/<u>/.ssh/<key>.pub`). Avoid the `key::ssh-ed25519 AAA...` literal.

- **File-path signing** reads the pubkey from disk for the fingerprint, then asks whatever's at `SSH_AUTH_SOCK` to sign. If your agent dies and restarts on a different socket, file-path still works.
- **`key::` literal** ties signing to exact key bytes. Point `SSH_AUTH_SOCK` at a different agent (Secretive, Keychain, 1Password) and signing fails.

If your dotfiles have `key::`, fix them.

## SSH_AUTH_SOCK considerations

Signing reaches the agent via `SSH_AUTH_SOCK`, which several agents fight over. Pick one and pin it in `~/.zshrc`:

```bash
export SSH_AUTH_SOCK="$TMPDIR/rbw-$UID/ssh-agent-socket"
```

When signing fails for no obvious reason, it's almost always a stale or wrong socket — run `ssh-sock-check` from [SSH agent via rbw](./ssh-agent-via-rbw.md#ssh_auth_sock-diagnostic) before debugging anything else.

```bash
ssh-add -L                               # should show the signing key
git commit --allow-empty -m "test sig"   # should succeed
git log --show-signature -1              # should verify
```

> **Seeing `No principal matched`?** Your signature is still valid — `git log --show-signature` found a Good signature but couldn't match your key to a named identity in `~/.ssh/allowed_signers`. To bind it (and silence the line): add `your-email@example.com ssh-ed25519 AAAA...` to `~/.ssh/allowed_signers`, then `git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers`.

## Forge verification matrix

All four verify SSH-signed commits, given Git ≥ 2.34 on the signer's side. What differs is setup:

| Forge | SSH-signed verification | Gotcha |
|---|---|---|
| **GitHub** | Yes — add the key at Settings → SSH keys as a **Signing key** (separate from Authentication).[²] | Same key can be both, but the dropdown distinguishes. |
| **GitLab** | Yes — add SSH key with Usage "Signing".[³] | `user.email` must match a **verified** account email or the badge won't show. |
| **Codeberg / Forgejo** | Yes — Forgejo needs Git ≥ 2.34 and `ssh-keygen` ≥ 8.2p1.[⁴] | Self-hosted instances need signing configured admin-side; some older UI quirks around the Verified badge. |

The local guarantee (`allowed_signers` + `git verify-commit`) is independent of any forge — it works even on a repo you never push.

## What about post-quantum?

**Short answer: nothing to do yet; don't change your signing key.**

NIST finalized the PQ standards in Aug 2024 — ML-KEM (FIPS 203), ML-DSA (FIPS 204), SLH-DSA (FIPS 205). OpenSSH 10.0 (Apr 2025) made the hybrid `mlkem768x25519-sha256` the **default key exchange**[¹] — but that's transport encryption, not signatures. **PQ signature algorithms (ML-DSA) are not yet in OpenSSH**; they're still in competing RFC drafts.[¹] So git SSH signing has no PQ option today.

That's fine. "Harvest-now-decrypt-later" threatens *encryption* (recorded traffic decrypted once quantum lands), not *signatures* — forging a signature requires breaking the algorithm *now*, and no one is spending a quantum computer on your commit history. Your Ed25519 signing key is good. **Track [openssh.com/pq.html](https://www.openssh.com/pq.html); re-evaluate only when OpenSSH ships ML-DSA signing.**

## Passkeys vs SSH keys vs API tokens

Passkeys matured fast — Apple, Google and Microsoft have fully integrated them, and >95% of iOS/Android devices are passkey-ready (state-of-passkeys, Jan 2025).[⁵] Cross-ecosystem sync still doesn't exist (Apple and Google don't sync to each other), but the FIDO Credential Exchange Format (CXF), shipping in iOS 18.4 / macOS 15.4, lets you export/import between managers — including Bitwarden and 1Password, which store passkeys too.[⁶]

What a passkey **does** and **doesn't** replace:

| Replace this with a passkey? | Verdict |
|---|---|
| Password + TOTP 2FA at a **login prompt** (GitHub, cloud console, Linear) | **Yes** — the sweet spot. One passkey replaces both the password and the authenticator code. |
| An **SSH key** | **No** — SSH auth is a different protocol. (A FIDO2 security key can back *both* an SSH `-sk` key and a passkey, but they're distinct credentials.) |
| An **API token** | **No** — machine-to-API auth uses tokens / OIDC; passkeys require interactive human presence. |

Rule of thumb: **passkeys for the human at a login prompt; SSH keys and tokens for the machine.**

## Field-tested gotchas

**Subagents don't have your agent.** Background agents that try to commit can't sign. Have the main session commit, or pass `-c commit.gpgsign=false` for subagent commits (escape hatch only).

**`~/` doesn't expand in git config.** Use the full `/Users/<u>/.ssh/<key>` path; git won't expand the tilde.

**Migrated machine / renamed user.** `signingkey = /Users/<old>/.ssh/key.pub` points at a path that no longer exists. Update gitconfig in post-rename cleanup.

**CI has no agent.** CI commits can't sign with your key — either disable signing for CI commits or give CI its own key.

## Innovative pattern: signing as a PR-merge gate

CI verifies every commit on the branch carries a good signature from `allowed_signers` — stronger than the forge's "Verified" badge:

```yaml
- name: Verify signatures
  run: git log --show-signature ${{ github.base_ref }}..HEAD | grep -q "Good signature" || exit 1
```

Per-repo signing identity (personal vs OSS) via `git config --local user.signingkey ...` overrides the global key.

## Related

- [SSH agent via rbw](./ssh-agent-via-rbw.md) — where the signing key lives + the socket diagnostic
- [Never commit secrets](./never-commit-secrets.md) — the signing key is a secret too
- [Chapter 06 — PR review standard](../06-session-discipline/pr-review-standard.md) — `Reviewed-by:` trailer (separate from signing)

---

[¹]: https://www.openssh.com/pq.html — accessed 2026-05-31
[²]: https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification — accessed 2026-05-31
[³]: https://docs.gitlab.com/user/project/repository/signed_commits/ssh/ — accessed 2026-05-31
[⁴]: https://forgejo.org/docs/latest/admin/advanced/signing/ — accessed 2026-05-31
[⁵]: https://www.biometricupdate.com/202501/state-of-passkeys-2025-passkeys-move-to-mainstream — accessed 2026-05-31
[⁶]: https://fidoalliance.org/mobileidworld-apple-introduces-cross-platform-passkey-import-export-features-across-operating-systems/ — accessed 2026-05-31
