# Git signing

> Sign commits with an SSH key. Use file-path signing (not `key::` literal). The agent socket matters.

## Why sign

- **Provable authorship** — verified commits show a green checkmark on GitHub
- **Tamper detection** — modified history would fail signature verification
- **Compliance** — some projects (especially OSS) require signed commits

For solo dev: optional but cheap once set up. Verified commits look professional and protect against worst-case "your account got compromised and someone pushed unsigned commits."

## SSH signing setup

Modern git supports signing with SSH keys (not GPG). Faster, simpler, no GPG.

```
# ~/.gitconfig

[user]
  name = Your Name
  email = your-email@example.com
  signingkey = /Users/<u>/.ssh/<key-name>.pub

[gpg]
  format = ssh

[gpg "ssh"]
  allowedSignersFile = ~/.ssh/allowed_signers

[commit]
  gpgsign = true
```

Create the allowed-signers file:
```
# ~/.ssh/allowed_signers
your-email@example.com ssh-ed25519 AAA...<pubkey contents>
```

The `allowed_signers` file lets `git verify-commit` work locally. Without it, signed commits still work but local verification fails.

## File path vs `key::` literal

The `signingkey` setting can be:

**a. File path** — `signingkey = /Users/<u>/.ssh/<key>.pub`. **Recommended.**

**b. `key::` literal** — `signingkey = key::ssh-ed25519 AAA...`. **Avoid.**

Why file-path is better:
- **Survives agent socket changes.** File-path signing reads the pubkey from disk for fingerprint and asks whatever's at `SSH_AUTH_SOCK` for the actual signing. If your agent dies and restarts (different socket), file-path still works.
- **The `key::` literal form ties signing to exact key bytes.** If you accidentally point `SSH_AUTH_SOCK` at a different agent (Secretive, macOS Keychain, etc.), git tries to sign with the literal-named key but the agent doesn't have it. Signing fails.

Always file-path. If your dotfiles have `key::`, fix them.

## SSH_AUTH_SOCK considerations

Git signing uses `SSH_AUTH_SOCK` to reach the signing agent. The socket must point at an agent that has your signing key loaded.

The likely tangle:
- macOS sets `SSH_AUTH_SOCK` to its built-in keychain agent
- You also have rbw-ssh-agent at `$TMPDIR/rbw-$UID/ssh-agent-socket`
- 1Password's CLI agent at yet another path
- Secretive at another

Pick ONE for signing. Set `SSH_AUTH_SOCK` to point at it in `~/.zshrc`:

```bash
export SSH_AUTH_SOCK="$TMPDIR/rbw-$UID/ssh-agent-socket"
```

Verify:
```bash
ssh-add -L  # should show the signing key
git commit --allow-empty -m "test signing"  # should succeed
```

## Verifying signed commits

```bash
# On the local repo
git log --show-signature

# A specific commit
git verify-commit <sha>
```

If verification fails, check:
- `allowed_signers` file is present
- The signing key's pubkey matches what's in `allowed_signers`
- The signature uses the right format (`ssh`)

## GitHub-side setup

For verified-on-GitHub commits:

1. Go to github.com/settings/keys
2. Add a new SSH key, type **Signing key** (NOT authentication key — same key can be both, but the dropdown distinguishes)
3. Paste your pubkey contents

Now commits signed with that key show up as "Verified" on GitHub.

## Field-tested gotchas

**Signing failure on push, not on commit.** The default pre-push hook checks signatures. If a commit was made without signing (or the agent wasn't available), the push fails. Fix: ensure agent is running before committing.

**Subagents don't have your agent.** Subagents that try to commit fail to sign. Workaround: don't have subagents commit; have main session do the commits. OR pass `-c commit.gpgsign=false` for subagent commits (escape hatch only).

**`PRE_PUSH_REVIEW_OVERRIDE=1` doesn't bypass signing.** Signing is enforced at commit, not push (separate from the review trailer hook). If you need to commit without signing for some reason, use `-c commit.gpgsign=false` per command.

**CI fails on unsigned commits if you have signing required on the branch.** Either disable signing in CI commits or have CI sign with its own key.

**The `allowed_signers` file path is a config you can get wrong.** `~/.ssh/allowed_signers` doesn't exist by default. Either create it or specify a different path in gitconfig.

**Key path with `~/` doesn't expand in git config.** Use the full `/Users/<u>/.ssh/<key>` path. Git doesn't expand tilde.

**Migrated user (laptop transfer, name change) doesn't update gitconfig automatically.** The `signingkey = /Users/<old-name>/.ssh/key.pub` points at a path that doesn't exist on the new machine. Update gitconfig as part of post-rename cleanup ([repo-bootstrap](../03-claude-code-as-operator/claude-md-template.md)).

## Innovative pattern: per-repo signing identity

Some users sign different repos with different keys (personal vs OSS, etc.).

```
# In a specific repo
git config --local user.signingkey /Users/<u>/.ssh/oss-key.pub
git config --local user.email oss-email@example.com
```

The repo-local config overrides global. Useful when you want commits in an OSS repo to be attributed to your OSS identity, not your personal one.

## Innovative pattern: signing as PR-merge gate

CI verifies that all commits on a PR branch have valid signatures from `allowed_signers`:

```yaml
# In GitHub Actions
- name: Verify signatures
  run: |
    git log --show-signature ${{ github.base_ref }}..HEAD \
      | grep -q "Good signature" || exit 1
```

Unsigned commits block merge. Stronger than the GitHub-side "Verified" badge.

## Related

- [SSH agent via rbw](./ssh-agent-via-rbw.md) — where the signing key lives
- [Never commit secrets](./never-commit-secrets.md) — the signing key is a secret too
- [Chapter 06 — PR review standard](../06-session-discipline/pr-review-standard.md) — `Reviewed-by:` trailer enforcement (separate from signing)
