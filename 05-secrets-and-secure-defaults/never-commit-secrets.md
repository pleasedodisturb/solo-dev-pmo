# Never commit secrets

> Pre-commit hooks, secret-scanning, and recovery procedure. Treat any committed secret as compromised — rotate first, clean up after.

## The defense in depth

Three layers:

1. **Cultural** — never type a secret into a file that's tracked by git
2. **Mechanical** — pre-commit hooks reject commits containing secret patterns
3. **Cleanup** — when a secret slips through, rotate immediately; force-push removal is a distant second priority

## Layer 1: cultural

Habits that prevent commits in the first place:

- Use environment variables for secrets in code; never inline tokens
- Use `.env.example` (without real secrets, committed) + `.env` (with real secrets, gitignored)
- Have secrets retrieved at runtime via password manager CLI (see [Bitwarden via rbw](./bitwarden-via-rbw.md))
- Audit `git diff` before every commit — eyeball for token-looking strings

The cultural layer fails first. The other layers exist because it does.

## Layer 2: pre-commit hooks

Set up `pre-commit` (or your equivalent) with secret-detection.

`.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.5.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
```

`detect-secrets` does entropy-based pattern detection. `gitleaks` has more curated patterns. Run both.

Generate the baseline (allowlist of known-safe-secret-like strings):
```bash
detect-secrets scan > .secrets.baseline
git add .secrets.baseline
git commit -m "G-XXX: add detect-secrets baseline"
```

Install hooks:
```bash
pre-commit install
```

Now `git commit` runs both scanners before allowing the commit.

## Layer 3: cleanup procedure

When you slip and commit a secret:

### Step 0: Treat as compromised

The moment a secret hits a public repo (or even a private repo if collaborators or automation have read access), treat the secret as compromised. The next steps are damage control, not cleanup.

### Step 1: Rotate the secret immediately

Go to the source service:
- Linear: linear.app/settings/api → revoke + create new
- Anthropic: console.anthropic.com → revoke + create new
- GitHub: github.com/settings/tokens → delete + create new
- AWS: IAM console → delete + create new

Get the new secret. Old one is now dead.

### Step 2: Update your password manager

```bash
rbw edit "Linear API" --field linear_api_key=<new-token>
# Re-source zshrc to pick up new value
exec $SHELL
```

### Step 3: Sweep for stale references

```bash
# In the leaked-from repo
grep -rn "<old-secret>" .
# In your home dir
grep -rln "<old-secret>" ~/.* 2>/dev/null
# In your shell history
grep "<old-secret>" ~/.zsh_history ~/.bash_history 2>/dev/null
```

Wherever it appears, fix it.

### Step 4: Force-push removal (lowest priority)

```bash
git filter-repo --replace-text <(echo "<old-secret>=REMOVED")
git push --force origin <branch>
```

Or use BFG Repo-Cleaner.

**This is the LAST step, not the first.** GitHub indexes commits; scrapers exist. By the time you force-push, the secret has been seen. Rotation is the only real fix.

### Step 5: Document what happened

In your meta-PM audit log: a dated entry describing what leaked, how, what the rotation involved. This is so future-you (and your agents) know to avoid the same pattern.

If the leaked secret is in a public OSS repo, GitHub may auto-detect and email you. Don't ignore those emails.

## `.gitignore` patterns

```gitignore
# Secret files
.env
.env.local
.env.*.local
*.key
*.pem
secrets/
private-keys/

# Tool-specific
.linear_api_token
.anthropic_token
.aws/credentials
.docker/config.json
.netrc

# Editor backups that may contain secrets
*.swp
*~
.DS_Store
```

Audit your `.gitignore` quarterly.

## Branches and PRs that should never reach review

Some patterns are tells that someone is about to commit secrets:
- A new `.env` file in a PR
- A file `secrets.json` or `credentials.json` in a PR
- A `tokens/` directory
- A `*.pem` or `*.key` file

CI should fail loudly on these patterns. Pre-merge protection.

## Field-tested gotchas

**`.env` files that "are gitignored" but track because they were added before `.gitignore`.** Check: `git ls-files | grep .env` should return nothing. If it does, `git rm --cached .env` and `git commit -m "G-XXX: remove tracked .env"`.

**Secrets in commit messages.** Some pre-commit hooks check files but not commit messages. Add a hook for that too.

**Secrets in branch names.** Less common; still possible. "feature/with-token-aabbccdd" leaks the token. Habituate to non-token branch names.

**Secrets in Linear ticket bodies.** Linear is private by default but `route/agent` tickets get touched by automation. Treat Linear ticket bodies as "low-trust public" — don't paste tokens.

**Force-push that goes to the wrong remote.** Push to `origin <branch>` first; verify; then think about other remotes. Force-pushing to the wrong remote can amplify the leak.

**GitHub's secret scanning sometimes auto-revokes the secret.** AWS, Stripe, others. If you see a revoked-by-GitHub email, the secret was already invalidated. Get a new one.

## Innovative pattern: pre-push secret scan as global hook

In addition to pre-commit (per repo), a global pre-push hook checks any pushed commits for secrets:

```bash
# ~/.claude/git-hooks/pre-push
# Runs for every push from every repo
detect-secrets-hook --baseline .secrets.baseline $(git diff --name-only origin/$(git rev-parse --abbrev-ref HEAD) HEAD)
```

Wire via `git config --global core.hooksPath ~/.claude/git-hooks`.

Two layers — repo-level pre-commit AND global pre-push. If the repo doesn't have its own hook, the global one catches it.

## Innovative pattern: token telemetry

Every script that loads a token from rbw logs the load to a local file:

```bash
echo "$(date) $0 LINEAR_API_TOKEN loaded" >> ~/.local/share/token-usage.log
```

Weekly: review which tokens get loaded by which scripts. Surprises (e.g., "why is this script accessing my AWS token?") become visible.

## Related

- [Bitwarden via rbw](./bitwarden-via-rbw.md) — where secrets live at rest
- [SSH agent via rbw](./ssh-agent-via-rbw.md) — SSH keys specifically
- [Git signing](./git-signing.md) — the signing key is a secret too
- [Chapter 03 — Browser tools](../03-claude-code-as-operator/browser-tools.md) — never use on credential pages
