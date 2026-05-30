# SSH agent via rbw

> Store SSH keys in Bitwarden. `rbw-ssh-agent` serves them. SSH config points at the agent socket. No keys on disk in plaintext.

## Why this pattern

Default SSH setup:
- Private keys live at `~/.ssh/id_*` in plaintext (or encrypted with a passphrase)
- SSH agent caches decrypted keys after one passphrase entry
- Keys are stolen if disk is taken; passphrases get brute-forced

The `rbw-ssh-agent` pattern:
- Private keys live in Bitwarden vault (encrypted at rest)
- `rbw-ssh-agent` retrieves keys on demand
- SSH treats it as a normal SSH agent
- Disk has no plaintext keys

Tradeoffs:
- Setup is more involved
- First SSH use after unlock has extra latency (Bitwarden retrieval)
- Vendor lock to Bitwarden (use `pass` if you'd rather)

## Setup

```bash
# Already have rbw installed?
which rbw-ssh-agent  # should be in the same install

# Add SSH key to Bitwarden
# Item type: Secure note
# Name: SSH key — laptop
# Custom field name=private_key (type=hidden), value=<PEM of private key>
# Custom field name=public_key (type=text), value=<ssh-ed25519 ...>

# Configure SSH to use rbw-ssh-agent
mkdir -p $TMPDIR/rbw-$UID
export SSH_AUTH_SOCK="$TMPDIR/rbw-$UID/ssh-agent-socket"

# Start the agent
rbw-ssh-agent &  # or via launchd, see below
```

In `~/.zshrc`:
```bash
export SSH_AUTH_SOCK="$TMPDIR/rbw-$UID/ssh-agent-socket"
```

Test:
```bash
ssh-add -L  # should list your key
ssh -T git@github.com  # should succeed
```

## Running rbw-ssh-agent under launchd

Better than `&` is launchd:

```xml
<!-- ~/Library/LaunchAgents/com.<your>.rbw-ssh-agent.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.<your>.rbw-ssh-agent</string>

  <key>ProgramArguments</key>
  <array>
    <string>/opt/homebrew/bin/rbw-ssh-agent</string>
  </array>

  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>

  <key>StandardOutPath</key>
  <string>/tmp/rbw-ssh-agent.out</string>
  <key>StandardErrorPath</key>
  <string>/tmp/rbw-ssh-agent.err</string>
</dict>
</plist>
```

Load:
```bash
launchctl load ~/Library/LaunchAgents/com.<your>.rbw-ssh-agent.plist
```

Agent restarts automatically. Survives reboots.

## SSH config integration

If you have multiple keys (different identities for personal / work / OSS contributions):

```
# ~/.ssh/config

Host github.com
  IdentityAgent ${SSH_AUTH_SOCK}
  IdentitiesOnly yes

Host gitlab.com
  IdentityAgent ${SSH_AUTH_SOCK}
  User git
```

The `IdentityAgent` directive uses the SSH agent at that socket path. `IdentitiesOnly yes` prevents SSH from trying all keys (which annoys some servers).

## Git signing via SSH key

Git commit signing with SSH keys (not GPG) — relevant if you sign commits.

```
# ~/.gitconfig
[user]
  email = <your-email>
  name = <Your Name>
  signingkey = /Users/<u>/.ssh/<key-name>.pub   # file path, NOT literal

[gpg]
  format = ssh

[commit]
  gpgsign = true
```

Important: use a **file path**, not the `key::ssh-ed25519 AAA...` literal form. Why:

- **File-path signing** reads the public key from disk and uses whatever agent serves it via `SSH_AUTH_SOCK`. If your agent dies, signing still finds the path-on-disk pubkey for fingerprint computation, then asks the (different) agent for signing.
- **`key::` literal form** ties signing to one specific exact key bytes. If your agent socket points to a different agent, signing fails.

File-path signing survives agent socket changes. Literal form does not.

## Field-tested gotchas

**`SSH_AUTH_SOCK` getting overridden.** macOS launchd may set its own agent socket; you need `~/.zshrc` to override. Verify in active sessions: `echo $SSH_AUTH_SOCK`.

**Multiple agents fighting.** Default macOS Keychain, Secretive, 1Password's agent, rbw-ssh-agent — all want `SSH_AUTH_SOCK`. Pick one; disable the others (or pin per-host in `~/.ssh/config`).

**Stale agent socket.** If you `launchctl unload` and reload the agent, the socket path may change. Check `ls $TMPDIR/rbw-$UID/` for the actual socket file name.

**Git signing fails silently in CI.** CI doesn't have your agent. Either disable signing in CI commits (`-c commit.gpgsign=false` per command, NOT globally) or set up CI's own signing.

**SSH key in Bitwarden retrieval is slow** on first call after unlock. ~1-2 seconds. Tolerable for ssh but adds up for "100 git operations in a script."

**Background agents (subagents) lack `SSH_AUTH_SOCK`.** They can't sign commits. Workaround: don't have agents sign commits; have the main session sign.

## Innovative pattern: per-host identity

Multiple SSH identities in Bitwarden:
- `SSH key — personal` (for personal GitHub, GitLab)
- `SSH key — work` (for work systems)
- `SSH key — OSS` (for OSS contributions under different identity)

Each as a separate Bitwarden entry. Each loaded into rbw-ssh-agent. SSH config picks per-host:

```
Host github-personal
  HostName github.com
  IdentityAgent ${SSH_AUTH_SOCK}
  IdentityFile ~/.ssh/personal.pub
  IdentitiesOnly yes

Host github-work
  HostName github.com
  IdentityAgent ${SSH_AUTH_SOCK}
  IdentityFile ~/.ssh/work.pub
  IdentitiesOnly yes
```

In `git remote`:
```
git@github-personal:user/personal-repo
git@github-work:org/work-repo
```

Identity follows the host alias.

## Related

- [Bitwarden via rbw](./bitwarden-via-rbw.md) — the same pattern for API tokens
- [Never commit secrets](./never-commit-secrets.md) — what NOT to put in `~/.ssh/`
- [Git signing](./git-signing.md) — the signingkey config details
