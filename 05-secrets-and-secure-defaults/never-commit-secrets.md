# Never commit secrets

> Pre-commit hooks, secret-scanning, and recovery. Treat any committed secret as compromised — rotate first, clean up after.

## The defense in depth

1. **Cultural** — never type a secret into a tracked file.
2. **Mechanical** — pre-commit hooks reject commits containing secret patterns.
3. **Cleanup** — when one slips, rotate immediately; history rewrite is a distant second.

## Layer 1: cultural

- Env vars for secrets in code; never inline tokens.
- `.env.example` (no real secrets, committed) + `.env` (real secrets, gitignored).
- Secrets retrieved at runtime via the password-manager CLI ([Bitwarden via rbw](./bitwarden-via-rbw.md)).
- Eyeball `git diff` before every commit for token-looking strings.

The cultural layer fails first. The others exist because it does.

## Layer 2: pre-commit hooks (working config)

This `.pre-commit-config.yaml` is copy-paste-runnable. **You run it locally** — it can't be exercised in a cloud session.

> **Prerequisites.** The recipe assumes `pre-commit` is already on your PATH. On a fresh Mac it isn't — install it *first*, or `git commit` fails with `pre-commit: command not found` and first-time forkers bounce:
>
> ```bash
> pipx install pre-commit detect-secrets    # or: brew install pre-commit detect-secrets
> ```

```yaml
# .pre-commit-config.yaml — active after `pre-commit install`
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.30.1            # pin latest: github.com/gitleaks/gitleaks/releases
    hooks:
      - id: gitleaks
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.5.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
```

```bash
detect-secrets scan > .secrets.baseline   # allowlist of known safe-looking strings
git add .secrets.baseline
pre-commit install                        # wire into git commit
```

Now `git commit` runs both scanners first. **TESTED LOCALLY ON: ____ (fill in).**

### Scanner comparison (2026)

| | `gitleaks` | `detect-secrets` | TruffleHog |
|---|---|---|---|
| **Engine** | regex, 150+ rules[¹] | entropy + plugins, baseline | 800+ detectors + live verification[²] |
| **Speed** | sub-second | fast | minutes→hours (deep scan) |
| **Verifies key is live?** | no | no | **yes** (calls the provider)[²] |
| **False positives** | low–moderate | low (curated) | low *after* verification |
| **Best fit** | pre-commit gate | baseline / allowlist mgmt | CI deep scan |
| **License** | MIT | Apache-2.0 | AGPL / commercial |

**Recommendation:** `gitleaks` at pre-commit (speed), `detect-secrets` baseline to manage known false positives, **TruffleHog in CI** when you want "is this leaked key still live?" verification.[¹][²] Run the fast ones locally; run the thorough one server-side.

### GitHub Secret Scanning — when is it enough?

GitHub's built-in scanning (free on public repos) with **push protection** blocks known partner patterns *at push*, and its partner program auto-revokes some tokens (AWS, Stripe, GitHub).[³] It is **server-side, after the push leaves your laptop.** Local pre-commit still matters for: private repos without Advanced Security, custom/non-partner secret formats, and catching the secret *before* it ever reaches a remote. Use both; they don't overlap.

## Layer 3: cleanup procedure

### Step 0–2: rotate first

The moment a secret hits any remote (even a private repo with automation read access), **treat it as compromised.** Rotate it at the source (Linear, Anthropic, GitHub, AWS — revoke + create new), then update the vault:

```bash
rbw edit "Linear API" --field linear_api_key=<new-token>
exec $SHELL   # re-source to pick up the new value
```

### Step 3: sweep for stale references

```bash
grep -rn "<old-secret>" .                                  # this repo
grep -rln "<old-secret>" ~/.* 2>/dev/null                  # home dir
grep "<old-secret>" ~/.zsh_history ~/.bash_history 2>/dev/null  # shell history
```

### Step 4: rewrite history with `git filter-repo` (lowest priority)

`git filter-repo` is the recommended tool in 2026 — `git filter-branch` is deprecated, and BFG, while simpler/faster for blobs, is a narrower hammer.[⁴] This walkthrough is **written, not executed** against this repo.

```bash
# WRITTEN, NOT EXECUTED. Run ONLY after you have already rotated the secret.
pipx install git-filter-repo               # or: brew install git-filter-repo

cd /tmp && git clone --mirror git@github.com:you/repo.git   # filter-repo wants a clean mirror
cd repo.git

echo 'AKIAEXAMPLE1234==>REMOVED' > /tmp/replacements.txt    # old==>new, one per line
git filter-repo --replace-text /tmp/replacements.txt

git push --force --all
git push --force --tags
```

**Caveats everyone skips:**

- History rewrite changes every commit SHA from the touched commit forward. Collaborators must re-clone; open PRs break.
- GitHub keeps **unreachable commits reachable by SHA** for a while, and forks / PR mirrors / caches may retain the old blob. You must email GitHub Support to purge cached views.[³]
- Scrapers and search engines may already hold the value.
- **Therefore: rotation is the fix; `filter-repo` is hygiene.** Never reason "I rewrote history fast enough, so the secret is safe." It isn't.

### Step 5: document it

A dated entry in the audit log: what leaked, how, what rotation involved — so future-you and your agents avoid the same pattern.

## After a major supply-chain incident

When news breaks that a package you *might* depend on was compromised (lottie-player, axios, chalk/debug, ledger connect-kit — full inventory in [supply-chain-2026](./supply-chain-2026.md)):

1. **Scope exposure:** `npm ls <pkg>` / `pnpm why <pkg>` / lockfile grep for the bad version + dates.
2. **If you installed or built in the malicious window:** assume every secret reachable by your build/dev/CI environment is compromised.
3. **Roll back** to a known-good pinned version; `npm ci` from a clean lockfile; delete `node_modules`.
4. **Verify** with `npm audit signatures` + provenance ([supply-chain-2026](./supply-chain-2026.md)).
5. **Rotate** npm/cloud/CI credentials that lived in any environment the malicious code could read.
6. **Document** in the audit log.

## `.gitignore` baseline

```gitignore
.env
.env.local
.env.*.local
*.key
*.pem
secrets/
.linear_api_token
.anthropic_token
.aws/credentials
.netrc
*.swp
.DS_Store
```

Audit quarterly. **`.env` files that "are gitignored" but were tracked before `.gitignore`:** `git ls-files | grep .env` should return nothing; if it does, `git rm --cached .env`.

## Field-tested gotchas

**Secrets in commit messages / branch names.** Many hooks check files, not messages. `feature/token-aabbccdd` leaks a token in the ref. Habituate to clean names; add a commit-msg hook.

**Secrets in Linear ticket bodies.** Treat ticket bodies as low-trust — automation touches `route/agent` tickets. Don't paste tokens.

**GitHub auto-revoked it for you.** AWS/Stripe/GitHub tokens caught by partner scanning may already be dead — a revoked-by-GitHub email means get a new one.

## Innovative pattern: two-layer hooks + telemetry

Global pre-push hook as a backstop to per-repo pre-commit — if a repo lacks its own config, the global one still catches it:

```bash
git config --global core.hooksPath ~/.claude/git-hooks   # holds a pre-push that runs detect-secrets-hook
```

Pair with light token telemetry — each script that loads a token appends `"$(date) $0 <TOKEN> loaded"` to `~/.local/share/token-usage.log`. Weekly review surfaces surprises ("why is *this* script reading my AWS token?").

## Related

- [Bitwarden via rbw](./bitwarden-via-rbw.md) — where secrets live at rest
- [Supply chain 2026](./supply-chain-2026.md) — full incident inventory + provenance
- [Cloud-session pattern](./cloud-session-pattern.md) — secrets without `rbw`
- [Chapter 03 — Browser tools](../03-claude-code-as-operator/browser-tools.md) — never use on credential pages

---

[¹]: https://github.com/gitleaks/gitleaks — accessed 2026-05-31
[²]: https://github.com/trufflesecurity/trufflehog — accessed 2026-05-31
[³]: https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning — accessed 2026-05-31
[⁴]: https://github.com/newren/git-filter-repo — accessed 2026-05-31
