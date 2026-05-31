# Hook and script examples

> Copy-paste-runnable git hooks and Claude Code hooks that mechanically enforce the rules in this chapter. Two layers: a **framework** (pre-commit) for shareable, per-repo checks, and **raw global hooks** for personal cross-repo rules.

> **Verify on a local Claude Code install.** The Claude Code hook examples (UserPromptSubmit) are written against the [current hook contract][hooks] (re-verified 2026-05-31) but cloud sessions can't exercise hook firing. The git hooks (pre-commit/pre-push/commit-msg) are plain shell and run anywhere git does.

Out of scope here, linked instead:
- **Secret-scanning hooks** → [Chapter 05 — Secrets and secure defaults](../05-secrets-and-secure-defaults/). Don't duplicate them; that's where they're maintained.
- **Agent-spawn rules** → [Chapter 03 — Agent rules](../03-claude-code-as-operator/agent-rules.md).

## Choosing a hook manager

| Tool | Runtime | Config | Parallel | Best for |
|---|---|---|---|---|
| **[pre-commit][pc]** | Python | `.pre-commit-config.yaml` | per-hook | **Default.** Huge hook gallery, language-isolated envs, polyglot[¹] |
| **[lefthook][lh]** | Go binary | one YAML | yes, built-in | Speed-critical / polyglot monorepos; no runtime dep[²] |
| **[husky][hk]** | Node | shell in `.husky/` | no | JS/TS projects already on npm[²] |
| **simple-git-hooks** | Node | `package.json` key | no | Minimal JS projects, a couple hooks[²] |

The playbook default is **pre-commit**: the gallery (`pre-commit/pre-commit-hooks`) ships the checks you'd otherwise hand-write, and each hook runs in an isolated env so a Python linter doesn't need your Node toolchain.[¹] Reach for **lefthook** only with evidence you need it — a polyglot monorepo where pre-commit's per-hook Python startup is measurably slow; lefthook is a single Go binary with parallel execution and no runtime dependency.[²] Do **not** default to Husky unless the repo is already Node-centric — it's sequential and Node-coupled.[²]

## pre-commit framework config

`.pre-commit-config.yaml` at the repo root:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-added-large-files       # blocks accidental binaries
      - id: check-merge-conflict
      - id: no-commit-to-branch           # protects main/master by default[3]
        args: [--branch, main, --branch, master]
  - repo: local
    hooks:
      - id: branch-name-ticket            # custom, see below
        name: branch name matches <ticket>/<slug>
        entry: scripts/check-branch-name.sh
        language: script
        pass_filenames: false
        always_run: true
```

Install — note pre-commit installs **per git stage**, so wire the stages you actually use:[³]

```bash
pip install pre-commit          # or: brew install pre-commit
pre-commit install              # pre-commit stage
pre-commit install --hook-type commit-msg   # for the ticket-prefix check
pre-commit install --hook-type pre-push     # for the review-trailer check
pre-commit run --all-files      # one-off, run everything now
```

`rev:` pins the hook version — bump it deliberately (`pre-commit autoupdate`), same discipline as any dependency.

## Branch-name regex (`<ticket>/<slug>`)

`scripts/check-branch-name.sh` — enforces `G-123/short-slug` (per [Chapter 02 — slug rules](../02-filesystem-conventions/slug-rules.md)):

```bash
#!/usr/bin/env bash
set -euo pipefail
branch=$(git rev-parse --abbrev-ref HEAD)
# Allow detached HEAD and the protected branches to pass untouched.
case "$branch" in
  HEAD|main|master) exit 0 ;;
esac
if ! printf '%s' "$branch" | grep -Eq '^[A-Z]+-[0-9]+/[a-z0-9]+(-[a-z0-9]+)*$'; then
  echo "Branch '$branch' must match <TICKET>/<kebab-slug>, e.g. G-123/license-agpl3" >&2
  exit 1
fi
```

## Commit-msg ticket prefix

`scripts/check-ticket-prefix.sh` — pre-commit passes the message file as `$1` on the `commit-msg` stage:[³]

```bash
#!/usr/bin/env bash
set -euo pipefail
msg_file="$1"
subject=$(head -n1 "$msg_file")
branch=$(git rev-parse --abbrev-ref HEAD)
ticket=${branch%%/*}                       # G-123 from G-123/slug
case "$branch" in main|master|HEAD) exit 0 ;; esac
if ! printf '%s' "$subject" | grep -q "$ticket"; then
  echo "Commit subject is missing the ticket id '$ticket'." >&2
  echo "Suggested: $ticket $subject" >&2
  exit 1
fi
```

Wire it as a `local` hook with `stages: [commit-msg]`.

## Pre-push review-trailer check

The `Reviewed-by:` enforcement hook lives in full in [PR review standard](./pr-review-standard.md#mechanical-enforcement-the-pre-push-hook). Install it as a **global** raw hook so it covers every repo without per-repo config:

```bash
git config --global core.hooksPath ~/.claude/git-hooks
# place the pre-push script at ~/.claude/git-hooks/pre-push, chmod +x
```

Global `core.hooksPath` and the per-repo pre-commit framework coexist: pre-commit writes into the repo's `.git/hooks` (or integrates), while `core.hooksPath` is your personal floor. Where they overlap, run the framework from inside the global hook if you need both.

## Safe UserPromptSubmit hooks

[`UserPromptSubmit`][hooks] hooks run on **untrusted input** — the prompt text is whatever was typed (or, in automated sessions, whatever arrived from an upstream system). The contract: plain stdout is injected as context; exit 0 to allow; emit `{"decision":"block","reason":"..."}` to reject.[⁴] Safety rules:

1. **Read stdin as data, never `eval` it.** Parse the JSON with `jq -r`; don't interpolate the prompt into a shell command.
2. **Quote every expansion** and set `set -euo pipefail`.
3. **Fail open, not closed, on hook error** unless the check is security-critical — a crashing hook shouldn't brick your ability to type.

A safe "inject current branch + ticket as context" hook:

```bash
#!/usr/bin/env bash
set -euo pipefail
input=$(cat)                                   # the JSON event on stdin
prompt=$(printf '%s' "$input" | jq -r '.prompt')   # data, never executed
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-")
# Plain stdout becomes context. Do NOT shell-interpolate $prompt anywhere.
printf 'Active branch: %s (ticket: %s)\n' "$branch" "${branch%%/*}"
exit 0
```

A blocking example — refuse prompts that would push to `main` directly:

```bash
#!/usr/bin/env bash
set -euo pipefail
prompt=$(jq -r '.prompt')
if printf '%s' "$prompt" | grep -Eqi 'push .*(origin )?(main|master)\b'; then
  printf '{"decision":"block","reason":"Direct push to main is banned — open a PR (see ch.06)."}'
  exit 0
fi
echo '{}'
```

The anti-pattern to avoid: `eval "$prompt"` or `bash -c "$prompt"` anywhere in a hook. The prompt is attacker-influenceable in any automated context; treat it like a web form field.

## CI-side enforcement: when local hook vs GitHub Action

Local hooks are **bypassable** (`--no-verify`, a fresh clone without `pre-commit install`). CI is **unbypassable** but slower. Use both, for different jobs:

| Enforce… | Where | Why |
|---|---|---|
| Format/lint autofix, branch name, ticket prefix | **Local hook** | Instant feedback; fix before the push round-trip |
| Review trailer present, signed commits, conventions-CI | **CI (GitHub Action)** | Can't be skipped; the real gate before merge |
| Secret scanning | **Both** | Local for speed, CI as the [backstop](../05-secrets-and-secure-defaults/) |

Mirror the local config in CI so they don't drift: `pre-commit run --all-files` runs the *same* `.pre-commit-config.yaml` in a GitHub Action, so one config enforces in two places.[¹] A separate Action can assert the `Reviewed-by:` trailer on every commit in the PR — the unbypassable twin of the local pre-push hook.

## Related

- [PR review standard](./pr-review-standard.md) — the review-trailer hook in full
- [Commit cadence](./commit-cadence.md) — what the commit-msg hook enforces
- [Wrap and resume](./wrap-and-resume.md) — SessionStart and `/wrap`
- [Chapter 05 — Secrets and secure defaults](../05-secrets-and-secure-defaults/) — secret-scanning hooks

---

[hooks]: https://code.claude.com/docs/en/hooks
[pc]: https://pre-commit.com/
[lh]: https://github.com/evilmartians/lefthook
[hk]: https://typicode.github.io/husky/

[¹]: pre-commit framework — config, language-isolated envs, `pre-commit run --all-files`. https://pre-commit.com/ and https://github.com/pre-commit/pre-commit-hooks — accessed 2026-05-31.
[²]: Git hook framework comparison (pre-commit / lefthook / husky / simple-git-hooks; lefthook = Go binary, parallel, polyglot; husky = Node, sequential). https://www.andymadge.com/2026/03/10/git-hooks-comparison/ — accessed 2026-05-31.
[³]: pre-commit stages and `no-commit-to-branch` (protects main/master by default); `install --hook-type pre-push|commit-msg`. https://pre-commit.com/ — accessed 2026-05-31.
[⁴]: Claude Code Hooks — UserPromptSubmit input/output contract (`prompt` field, `decision: "block"`, plain stdout as context). https://code.claude.com/docs/en/hooks — accessed 2026-05-31.
