# SSH agent via rbw

> Store SSH keys in Bitwarden. `rbw-ssh-agent` serves them. SSH config points at the agent socket. No keys on disk in plaintext.

> **Cloud caveat:** every agent/`ssh-keygen` recipe must run on a real machine. Written in a cloud session that can't run an SSH agent. **TESTED LOCALLY ON: ____ (fill in).**

## Why this pattern

Default SSH leaves private keys at `~/.ssh/id_*` (plaintext, or passphrase-encrypted). The `rbw-ssh-agent` pattern keeps keys in the Bitwarden vault (encrypted at rest), retrieves them on demand, and presents a normal SSH agent — so disk has no plaintext keys, and a new machine rehydrates from the vault.

Tradeoffs: more setup; first SSH use after unlock has retrieval latency; you're tied to Bitwarden (use `pass`/`gpg-agent` if you'd rather).

## SSH key baseline (2026)

Before any agent question, get the key itself right:

- **Ed25519 by default.** `ssh-keygen -t ed25519`. Smaller, faster, no RSA key-size debates. RSA only for legacy hosts that reject Ed25519.
- **Always a passphrase**, even for vault-stored keys — defense in depth if the key ever lands on disk.
- **`-sk` (hardware-backed) for high-stakes keys.** Production deploy, release-signing, root-of-trust. Not every key — see [YubiKey walkthrough](#yubikey-ed25519-sk-high-stakes-keys) below.
- **Separate keys per purpose.** Auth vs signing should not be the same key where you can avoid it.[¹]

## Setup

```bash
which rbw-ssh-agent   # ships with rbw

# Add SSH key to Bitwarden (Secure note, or a native SSH-key entry on rbw >= 1.14.0):
#   private_key (hidden) = <PEM>,  public_key (text) = ssh-ed25519 AAAA...

mkdir -p "$TMPDIR/rbw-$UID"
export SSH_AUTH_SOCK="$TMPDIR/rbw-$UID/ssh-agent-socket"
rbw-ssh-agent &   # or via launchd (below)
```

In `~/.zshrc`: `export SSH_AUTH_SOCK="$TMPDIR/rbw-$UID/ssh-agent-socket"`. Test: `ssh-add -L` lists your key; `ssh -T git@github.com` succeeds. **TESTED LOCALLY ON: ____ (fill in).**

## Running rbw-ssh-agent under launchd

Better than `&`. Minimal plist at `~/Library/LaunchAgents/com.<your>.rbw-ssh-agent.plist` with `ProgramArguments` → `/opt/homebrew/bin/rbw-ssh-agent`, `RunAtLoad` and `KeepAlive` true. Load with `launchctl load <plist>`. Survives reboots, restarts on crash. (Full plist pattern: [Chapter 04 — launchd](../04-rituals-and-triggers/launchd-over-cron.md).)

## SSH config integration

```
# ~/.ssh/config
Host github.com
  IdentityAgent ${SSH_AUTH_SOCK}
  IdentitiesOnly yes
```

`IdentityAgent` points at the agent socket; `IdentitiesOnly yes` stops SSH offering every key (which annoys some servers and can lock you out after too many attempts).

## SSH agent comparison

You will have several agents fighting over `SSH_AUTH_SOCK`. Pick one; disable the rest.

| Agent | Key storage | Backed up / portable? | Hardware-backed | Cost |
|---|---|---|---|---|
| **`rbw-ssh-agent`** | Bitwarden vault | yes (vault syncs) | no (software) | free |
| **1Password SSH agent** | 1Password vault | yes (vault syncs) | no (software) | paid |
| **Apple Keychain / Secure Enclave**[²] | Secure Enclave (macOS Sequoia+) | **no** (non-exportable) | yes | free |
| **Secretive**[³] | Secure Enclave | **no** (non-exportable) | yes | free |
| **`gpg-agent`** | GPG keyring | yes (export GPG key) | optional (smartcard) | free |

**Why the playbook uses a vault agent, not Secretive/Secure Enclave for daily keys:** Secure Enclave keys are *non-exportable by design* — you cannot back them up or move them to a new laptop.[³] That breaks the chapter's core model: *the vault is the source of truth and any machine rehydrates from it.* Secure Enclave keys are excellent for a single-machine high-stakes key you're willing to lose on hardware death — but then you reach for a [YubiKey](#yubikey-ed25519-sk-high-stakes-keys) (portable hardware) instead. Apple's native Secure Enclave SSH also only does 256-bit ECDSA and shows an unfriendly `ctccardtoken` Touch ID prompt.[²]

## SSH_AUTH_SOCK diagnostic

When signing or `ssh -T` mysteriously fails, the socket is usually the culprit:

```bash
ssh-sock-check() {
  echo "SSH_AUTH_SOCK=${SSH_AUTH_SOCK:-<unset>}"
  [ -z "$SSH_AUTH_SOCK" ] && { echo "unset — no agent in this shell"; return 1; }
  [ ! -S "$SSH_AUTH_SOCK" ] && { echo "stale path — not a live socket"; return 2; }
  ssh-add -L >/dev/null 2>&1 || { echo "socket up but agent has no keys / not responding"; return 3; }
  ssh-add -L
}
```

Fixes by case: **unset** → re-source `~/.zshrc`. **stale path** → the agent was reloaded and the socket name changed; check `ls "$TMPDIR/rbw-$UID/"` for the real name, or `launchctl kickstart -k gui/$UID/com.<your>.rbw-ssh-agent`. **no keys** → vault locked (`rbw unlock`) or agent didn't load the key. **TESTED LOCALLY ON: ____ (fill in).**

## YubiKey ed25519-sk (high-stakes keys)

For the keys whose compromise would be catastrophic — prod deploy, release signing, the key that can push to `main` of your money-maker — back the key with a YubiKey. Requires YubiKey firmware ≥ 5.2.3 (FIDO2) and OpenSSH ≥ 8.2.[⁴]

### Prerequisites (macOS)

Apple's bundled `/usr/bin/ssh-keygen` is **not linked against libfido2** and silently fails with `No FIDO SecurityKeyProvider specified / Key enrollment failed: invalid format`. Install Homebrew's OpenSSH (which IS linked) plus the dylib + manager:

```bash
brew install libfido2 openssh ykman
```

Then either put `/opt/homebrew/bin` ahead of `/usr/bin` in `$PATH`, or call the binary explicitly: `/opt/homebrew/bin/ssh-keygen …`. `ykman` is what lets you list and delete resident FIDO credentials so you can free YubiKey slots without a factory reset (`ykman fido credentials list` / `ykman fido credentials delete <id>`).

Sanity check before running the recipe:

```bash
which ssh-keygen                  # expect /opt/homebrew/bin/ssh-keygen
ls /opt/homebrew/lib/libfido2.dylib   # exists
ykman list                        # YubiKey detected, firmware ≥ 5.2.3
```

### Generate the key

```bash
# Non-resident: a small key handle lives on disk; signing needs the YubiKey + touch.
ssh-keygen -t ed25519-sk -O verify-required -C "deploy@prod"

# Resident: discoverable on the key itself; rehydrate on a new machine later.
ssh-keygen -t ed25519-sk -O resident -O verify-required -C "deploy@prod"
```

### ⚠️ OTP-into-PIN foot-gun (lifetime PIN attempt budget)

When ssh-keygen prompts `Enter PIN for authenticator:`, **type your PIN — DO NOT touch the YubiKey yet.** Touching the key while focus is in the PIN prompt outputs the YubiKey's 44-character OTP (a long string starting `cccccc…`) which gets typed as the PIN attempt. The FIDO PIN budget is **8 lifetime wrong attempts** before the FIDO function locks; two accidental OTP-touches can burn most of it.

Correct interaction order:

1. Prompt: `Enter PIN for authenticator:` → **type the PIN** (default for a brand-new YubiKey is no PIN — just Enter)
2. After PIN accepted: `You may need to touch your authenticator` → **NOW touch the key**

Recovery if PIN-locked: removing + re-inserting the key resets the per-session counter, so you get fresh attempts. If you exhaust all 8 lifetime tries → `ykman fido reset` is the only fix and **it wipes every FIDO credential on the key** (passkeys + resident SSH keys included).

### Agent compatibility (the FIDO dead end)

`rbw-ssh-agent` — the agent this chapter recommends for daily software keys — **does not accept FIDO keys.** `ssh-add ~/.ssh/id_ed25519_sk` returns `Could not add identity: agent refused operation`. This isn't a rbw-ssh-agent bug; it's by design — rbw is a vault for software keys, FIDO key material lives on the hardware token and doesn't fit that model.

That means FIDO keys live **outside the unified-agent pattern** the rest of this chapter recommends. Two paths:

1. **Agent-less** — the production-design intent for hardware-backed keys: touch on every operation, no caching, no agent-compromise blast radius. Documented below.
2. **Side-channel agent** — Homebrew's stock `ssh-agent` started in a subshell or as a separate launchd job, with its own `SSH_AUTH_SOCK` you switch to when using the FIDO key. More plumbing, less touch-friction. Worth it only if you sign 20+ commits a day with the FIDO key; for the "twice-a-day deploy" use case, agent-less wins.

### Use the key without an agent (the production pattern)

Yubico treats the agent as optional in their `-sk` documentation — touch-per-operation IS the intent. Two integration points:

**Pattern 1 — SSH auth via `~/.ssh/config` `IdentityFile`:**

```sshconfig
# Default: software key (rbw-served) for daily git, sshing around
Host *
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes

# High-stakes: FIDO key, no agent, touch every time
Host github-prod prod-deploy
  HostName github.com
  IdentityFile ~/.ssh/id_ed25519_sk
  IdentitiesOnly yes
  AddKeysToAgent no
```

Use the high-stakes host alias only for the operations you want to gate on touch:

```bash
git remote set-url origin git@github-prod:user/<repo>.git
# or one-off:
ssh github-prod   # PIN + touch
```

**Pattern 2 — Git signing via file path (no agent, no rbw):**

```bash
# Global: every commit signed with the FIDO key (maximally strict)
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519_sk.pub
git config --global commit.gpgsign true

# OR per-repo: only sign with FIDO in high-stakes repos
cd ~/Projects/<high-stakes-repo>
git config gpg.format ssh
git config user.signingkey ~/.ssh/id_ed25519_sk.pub
git config commit.gpgsign true
```

`user.signingkey` here is the **`.pub` file path** — git reads the file directly, no agent involved. Each `git commit` prompts for PIN + touch. Verify with `git verify-commit HEAD` after your first signed commit; expect `Good "git" signature with ED25519-SK key`.

This is the pattern that closes the chapter's recipe: generate the key → register the `.pub` with GitHub (Authentication and/or Signing key) → wire either Pattern 1 or Pattern 2 (or both) into `~/.ssh/config` and `git config`. The agent step is **omitted on purpose**.

### Cleanup + slot management

YubiKey 5 has ~25 FIDO resident-credential slots. `ykman` lists + deletes:

```bash
ykman fido credentials list      # PIN-prompts once; lists all resident
                                 # credentials (RP, user, credential ID)
ykman fido credentials delete <credential-id>   # frees the slot
```

Disk-side handle and YubiKey-side credential are separate:

- Delete just the disk handle → key unusable from this machine, but credential stays on YubiKey (rehydrate later via `ssh-keygen -K`)
- Delete just the YubiKey credential → handle on disk becomes inert
- Wipe both for clean removal: `trash ~/.ssh/<key>{,.pub}` + `ykman fido credentials delete <id>`

To re-download resident-credential stubs on a fresh machine: `ssh-keygen -K` writes them into the current directory.

### Notes

- `-O verify-required` adds a PIN on top of the mandatory physical touch.
- The private key material never leaves the YubiKey; only a non-secret handle is on disk.
- Add the `.pub` to GitHub (Authentication and/or Signing key).
- **Use sparingly.** Every operation needs a physical touch — fine for a deploy you do twice a day, miserable for a script doing 100 git operations. Daily keys stay software (`rbw`).
- **Verified 2026-06-02** on macOS Sequoia + YubiKey 5C NFC firmware 5.2.7 (Homebrew openssh 10.3p1 + libfido2). The FIDO-provider gap, PIN foot-gun, and rbw-ssh-agent FIDO-incompatibility were all caught during this verification — see [`.planning/audits/2026-06-02-deferred-verify-followup.md`](../.planning/audits/2026-06-02-deferred-verify-followup.md) for the full session.

## Git signing via SSH key

The signing key is just another SSH key served by this agent. Config and gotchas (file-path vs `key::`, `allowed_signers`, the stale-socket trap) live in [Git signing](./git-signing.md).

## Field-tested gotchas

**`SSH_AUTH_SOCK` getting overridden.** macOS launchd sets its own socket; your `~/.zshrc` must override. Verify in live shells: `echo $SSH_AUTH_SOCK`.

**Multiple agents fighting.** Keychain, Secretive, 1Password, rbw all want the socket. Pick one; pin per-host in `~/.ssh/config` if you must mix.

**Retrieval latency on first call after unlock.** ~1–2s for Bitwarden retrieval. Tolerable for interactive SSH, painful for "100 git ops in a loop."

**Background agents (subagents) lack `SSH_AUTH_SOCK`.** They can't sign. Have the main session do commits, not subagents.

## Innovative pattern: per-host identity

Multiple identities (`personal` / `work` / `OSS`) as separate vault entries, all loaded into the agent, selected per host alias in `~/.ssh/config`:

```
Host github-personal
  HostName github.com
  IdentityAgent ${SSH_AUTH_SOCK}
  IdentityFile ~/.ssh/personal.pub
  IdentitiesOnly yes
```

Then `git@github-personal:user/repo`. Identity follows the host alias — no `--global` juggling.

## Related

- [Bitwarden via rbw](./bitwarden-via-rbw.md) — the same pattern for API tokens
- [Never commit secrets](./never-commit-secrets.md) — what NOT to put in `~/.ssh/`
- [Git signing](./git-signing.md) — the signingkey config details

---

[¹]: https://docs.gitlab.com/user/project/repository/signed_commits/ssh/ — accessed 2026-05-31
[²]: https://gatezh.com/posts/macos-secure-enclave-ssh-keys/ — accessed 2026-05-31
[³]: https://github.com/maxgoedjen/secretive — accessed 2026-05-31
[⁴]: https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html — accessed 2026-05-31
