# Follow-up local-verify — chapter 05 deferred items (2026-06-02)

Scope: the 4 chapter-05 items from `2026-06-01-local-verify.md` §"Findings deferred to user" (items #4, #5, #6, #7). Verified end-to-end on the author's actual macOS environment (zsh, rbw vault unlocked, rbw-ssh-agent socket active, signing key configured) under ticket G-817.

## Summary

- Verified: 3 of 4 (items #4, #5, #7) — all PASS
- Deferred (needs physical hardware): 1 of 4 (item #6 — YubiKey enrolment)
- Net verdict: **chapter 05 is launch-safe** on this hardware profile
- Self-recursive bonus: the chapter-05 pre-commit hook (now installed on this very repo) blocked the *first* draft of this audit doc because it contained a canonical AWS test-credential string. That's the recipe working as advertised.

## Item #4 — pre-commit + detect-secrets blocks fake AWS key — **PASS**

**Setup performed:**

```bash
TMP=$(mktemp -d -t verify-pre-commit-XXXXX)
cd "$TMP" && git init -q
pipx install pre-commit detect-secrets   # neither was pre-installed
```

`.pre-commit-config.yaml` matches the chapter's recipe (detect-secrets v1.5.0, `--baseline .secrets.baseline`). Baseline created; hook installed.

**Attack:** committed a file containing canonical AWS test credentials (the textbook `AKIA…EXAMPLE` access-key + matching secret-key strings — content omitted from this writeup so this audit doesn't itself trip the same hook).

**Result:** commit blocked. detect-secrets caught both fingerprints (`Base64 High Entropy String` + `Secret Keyword`). Mitigation guidance + `pragma: allowlist secret` escape hatch shown in the hook output. Non-zero exit. ✓

**Caveat for the chapter:** the recipe assumes `pre-commit` is already installed. On a fresh Mac, the prerequisite step is `pipx install pre-commit detect-secrets` (which the chapter mentions but is easy to skip). Worth bolding in chapter 05 `never-commit-secrets.md` prereqs. Not a bug; a documentation polish for a future revision.

## Item #5 — rbw end-to-end — **PASS**

**Setup performed:**

```bash
rbw unlocked                                       # exit 0 → vault unlocked
rbw get "Linear API" --field linear_api_key        # returned 49-char token
ssh-add -l                                         # exit 0 → ssh-agent populated
```

All three exit codes per the chapter's `rbw-diagnose` pattern: 0 / 0 / 0.

**Result:** vault retrieval works end-to-end. Recipe matches reality on this machine. ✓

## Item #7 — git SSH signing end-to-end — **PASS** (with one principal-matching note)

**SSH_AUTH_SOCK check (chapter 05 git-signing.md gotcha):**

```
SSH_AUTH_SOCK = $TMPDIR/rbw-$UID/ssh-agent-socket
expected      = $TMPDIR/rbw-$UID/ssh-agent-socket
```

Match. The chapter's "if `SSH_AUTH_SOCK` points to Secretive, export the rbw socket before commits" gotcha is NOT active here — current shell already has the right socket.

**Git config:**

| Origin | Key | Value (sanitized) |
|---|---|---|
| `~/.gitconfig-local` | `user.signingkey` | `~/.ssh/id_ed25519_<host>` |
| `~/.gitconfig` | `gpg.format` | `ssh` |
| `~/.gitconfig` | `commit.gpgsign` | `true` |

**Test:** signed empty commit in a throwaway repo + `git verify-commit HEAD`.

**Result:**

```
Good "git" signature with ED25519 key SHA256:<fingerprint>
No principal matched.
```

Signature **verified Good** — chapter 05's signing recipe works end-to-end. ✓

**Surfaced finding:** the `No principal matched` line. Signature is valid but the signing key isn't listed in an `~/.ssh/allowed_signers` file mapping it to a named principal. Verification still succeeds (the "Good signature" comes first); principal matching is an optional hardening layer.

For the chapter: this is worth a callout in `git-signing.md` — readers following the recipe will see the warning and may think the signing is broken. Suggested addition:

```markdown
> If you see `No principal matched`, your signature IS valid — the warning means your key isn't bound to a named identity in `~/.ssh/allowed_signers`. To silence: add `<your-email> ssh-ed25519 AAAA...` to `~/.ssh/allowed_signers` and `git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers`.
```

This is a chapter-polish ticket, not a chapter bug.

## Item #6 — YubiKey ed25519-sk — **DEFERRED**

Requires physical YubiKey inserted + touch enrolment. Can't be verified without the hardware. Recipe (`ssh-keygen -t ed25519-sk -O verify-required -C "deploy@prod"`) is standard OpenSSH and well-tested upstream; no chapter-specific risk.

**Action for user:** when you next have YubiKey accessible:

```bash
ssh-keygen -t ed25519-sk -O resident -O verify-required -C "deploy@prod"
# Touch the key to enrol
ssh-add -L | grep ed25519-sk   # confirms the resident key is visible
```

If the chapter's recipe fails here, file a follow-up.

## Verdict

Chapter 05 is **launch-safe** on the author's current hardware. The 3 verified items (`pre-commit + detect-secrets`, `rbw end-to-end`, `git SSH signing`) all work as documented. Two chapter-polish opportunities surfaced (pre-commit prerequisite bolding, principal-matching footnote in `git-signing.md`) — neither is a launch blocker.

Item #6 (YubiKey) remains user-hands.
