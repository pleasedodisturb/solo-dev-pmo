# Local-verify pass — solo-dev-pmo v0.1 (2026-06-01)

Scope: chapters 04/05/06/07 shipped recipes. Run on macOS (Darwin 25.5.0, arm64, zsh), `rbw` 1.15.0 present, `gh` authenticated, Claude Code running. `fish` not installed; `pre-commit` CLI not installed; `python3-yaml` not installed (used Ruby's `psych` instead).

## Summary

- Recipes tested: 24
- Recipes passed: 23
- Recipes flagged (real bug to fix): **1** — cheats-starter pre-commit hook fails silently on macOS BSD `sed`
- Recipes deferred (need user's phone / Linear / secrets / hardware / CC firing): ~14 (counted below)

## Chapter 04 — Rituals and triggers

### launchd plists
- `daily-triage.plist` (canonical daily 09:00 from `launchd-over-cron.md`) :: **PASS** :: `plutil -lint` → OK.
- `friday-retro.plist` (Weekday=5, Hour=16) :: **PASS** :: `plutil -lint` → OK.
- Monday/monthly-cooldown plists share identical structure with only `StartCalendarInterval` differing; covered by the two tested above.

### systemd units (Linux variant)
- `monday-plan.service` :: **PASS (syntax-sanity)** :: required `[Unit]` + `[Service]` sections present; `Type=oneshot`, `ExecStart=` set; `%h` placeholder consistent with chapter rule.
- `monday-plan.timer` :: **PASS (syntax-sanity)** :: `[Unit]` + `[Timer]` + `[Install]` all present; `OnCalendar=`, `Persistent=true`, `WantedBy=timers.target` all set. Not runtime-tested (no systemd on macOS, per scope).

### ntfy curl recipes
- All four per-ritual curl invocations (`Morning Triage`, `Monday plan` with Actions header, `Friday retro`, `Monthly cooldown`) :: **PASS (`bash -n`)**.
- `ntfy-send` wrapper script :: **PASS (`bash -n`)**.
- Delivery to phone :: **DEFERRED** :: requires user's topic + user's phone with ntfy app.

### md→ics exporter (`schedule-to-ics.py`)
- AST parse :: **PASS** :: `python3 -c "ast.parse(...)"` ok.
- Required imports (`re`, `sys`, `hashlib`, `datetime`, `zoneinfo`, `icalendar`) :: present.
- Runtime :: **DEFERRED** :: `icalendar` library not installed locally; chapter explicitly says `pip install icalendar`. AST is valid.

### Monday/Friday scripts
- `monday-plan.sh` (full ~/.local/bin script) :: **PASS (`bash -n`)**.
- `friday-retro.sh` :: **PASS (`bash -n`)**.
- Runtime execution :: **DEFERRED** :: scripts call `rbw get`, `linearis`, real `open`, and write to `~/today.md`/`~/retro-*.md` — not safe to actually run.

## Chapter 05 — Secrets and secure defaults

### `.pre-commit-config.yaml`
- YAML structure :: **PASS** :: validated via Ruby psych (`yaml` module not installed on system python). Two repos, gitleaks v8.30.1 and detect-secrets v1.5.0 both parse correctly.
- `pre-commit` CLI installed? :: **NO** :: deferred — user installs via `pipx`/`brew` per chapter.
- gitleaks/detect-secrets GitHub URLs :: **PASS** :: HTTP 200.

### rbw setup snippets
- `bash -n` on every rbw snippet in `bitwarden-via-rbw.md` (setup, daily usage, zshrc guard, `rbw-diagnose` function) :: **PASS**.
- `rbw` present :: **YES** :: `/opt/homebrew/bin/rbw` version 1.15.0 — matches chapter's "Latest is 1.15.0" claim.
- `rbw unlock` not exercised (would prompt for master password).

### ssh-agent via rbw
- `bash -n` on setup, `ssh-sock-check` diagnostic, YubiKey ed25519-sk recipes :: **PASS**.
- Socket-path consistency :: **PASS** :: chapter sets `SSH_AUTH_SOCK="$TMPDIR/rbw-$UID/ssh-agent-socket"` — exactly what user's CLAUDE.md says.
- YubiKey `ssh-keygen -t ed25519-sk` syntax sanity :: **PASS** :: flags match OpenSSH docs.
- Hardware run :: **DEFERRED** :: requires user's YubiKey + interactive touch.

### git filter-repo walkthrough
- Walkthrough explicitly labeled "WRITTEN, NOT EXECUTED" :: **PASS** :: ch.05/never-commit-secrets.md line 87 says exactly that. No execution attempted.

### cloud-session-pattern (OIDC + keyring CLIs)
- `bash -n` on `secret-tool` + macOS `security` snippets :: **PASS**.
- OIDC YAML snippet shape :: looks correct (`permissions: { id-token: write }`, `aws-actions/configure-aws-credentials@v4`).

### URL liveness sanity
- gitleaks, detect-secrets, lychee, ntfy, rbw GitHub URLs :: all **HTTP 200** (HEAD via curl).

## Chapter 06 — Session discipline

### `/wrap` skill
- Author's local CC install has `~/.claude/skills/wrap/SKILL.md` :: **PRESENT**.
- Skill frontmatter (`disable-model-invocation`, `allowed-tools`, `argument-hint`) shape extracted from chapter :: **PASS** :: matches the Skills contract.
- Actual firing of `/wrap` :: **DEFERRED** :: cannot exercise inside the current session without disrupting state.

### SessionStart hook
- `~/.claude/scripts/session-start-context.sh` exists on user's system :: **PRESENT** (2751 bytes, executable).
- Chapter-shipped version :: **PASS (`bash -n`)**.
- Hook firing :: **DEFERRED** :: can't restart this session to test.

### Pre-commit / pre-push / commit-msg / UserPromptSubmit hook examples (hook-and-script-examples.md)
- `check-branch-name.sh` :: **PASS (`bash -n`)**.
- `check-ticket-prefix.sh` :: **PASS (`bash -n`)**.
- `session-start-context.sh` :: **PASS (`bash -n`)**.
- `user-prompt-context.sh` (safe context injector) :: **PASS (`bash -n`)**.
- `user-prompt-block.sh` (block direct push to main) :: **PASS (`bash -n`)**.

### Branch-name regex test
Pattern: `^[A-Z]+-[0-9]+/[a-z0-9]+(-[a-z0-9]+)*$`

| Input | Expected | Got |
|---|---|---|
| `G-777/foo-bar` | pass | **PASS** |
| `G-1/license-agpl3` | pass | **PASS** |
| `feature_bad` | fail | **FAIL (correct)** |
| `main` | fail at regex; but script `case` short-circuits | regex fails (correct); script returns 0 for main |
| `g-1/lower` | fail | **FAIL (correct)** |
| `G-/empty` | fail | **FAIL (correct)** |
| `G-1/UPPER` | fail | **FAIL (correct)** |

Regex behaves exactly as claimed.

## Chapter 07 — Cheatsheets and living docs

### `cheat.sh` shell function — TESTED in `/tmp/cheat-test/`
- test 1: `cheat` with no args lists topics → **PASS** (prints "Usage: cheat <topic>. Available topics:" and lists `claude-code`, `git`, `tmux`).
- test 2: `cheat git` renders the topic → **PASS** (rendered via `glow` since installed; readable output).
- test 3: `cheat doesnotexist` falls back to topic listing with `No cheatsheet for "doesnotexist"` and exit code 1 → **PASS**.

### `cheat.fish` — `fish` not installed
- Static read confirms structure mirrors `cheat.sh`; **UNTESTED ON THIS SHELL** (no fish binary). Flagged for user with fish to syntax-check (`fish -n cheat.fish`).

### Pre-commit hook for date-stamping (`cheats-starter/hooks/pre-commit`) — **REAL BUG FOUND**
- `bash -n` :: **PASS**.
- Functional test in a `/tmp` git repo with a stale `last-validated: 2024-01-15` stamp + `git commit` triggering the hook :: **FAIL**.
- **Root cause:** the hook uses GNU-style `sed -i -E "s/..."`. On macOS BSD `sed`, the `-i` flag *requires* a backup-extension argument; BSD sed therefore parses `-E` as the extension, the `s/...{4}...` script falls back to BRE (where `{4}` is literal), no match, file unchanged. A spurious `*-E` backup file is left behind. Reproduces 100%.
- Fix options (both cross-platform):
  - `sed -i.bak -E "..." && rm -f "$f.bak"` (works on both BSD and GNU), or
  - `perl -pi -e 's/last-validated: \d{4}-\d{2}-\d{2}/last-validated: '"$today"'/' "$f"` (preferred — no platform branching).
- Severity: silent failure of a hook whose *job* is to keep stamps fresh. Users on macOS would believe the stamp is being bumped while it never moves.

## Findings that need fixing

1. **`07-cheatsheets-and-living-docs/cheats-starter/hooks/pre-commit` is broken on macOS.** Replace the `sed -i -E` line with a portable equivalent (`perl -pi -e` recommended). This is a shipped artifact, not just documentation — a PR is warranted. The chapter even uses macOS as the primary target, so this is high-impact.

(Nothing else failed verification.)

## Findings deferred to user

These can only be verified hands-on; explicit commands to run:

1. **Load a plist and kickstart it** (chapter 04):
   `plutil ~/Library/LaunchAgents/com.<u>.daily-triage.plist`
   `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.<u>.daily-triage.plist`
   `launchctl kickstart -k gui/$(id -u)/com.<u>.daily-triage`
   Then check `/tmp/daily-triage.out` and `.err`.

2. **ntfy delivery to your phone** (chapter 04):
   `curl -H "Title: test" -d "verify" "ntfy.sh/<your-topic>"` — confirm buzz on phone with the four priority levels.

3. **md→ics exporter** (chapter 04): `pip install icalendar` then `python3 schedule-to-ics.py schedule.md > /tmp/sched.ics`. Subscribe in Apple Calendar/Google Calendar; verify events render with correct TZ and the `X-PUBLISHED-TTL` is honored.

4. **`pre-commit install`** (chapter 05): in a throwaway repo, `pipx install pre-commit detect-secrets`, `detect-secrets scan > .secrets.baseline`, `pre-commit install`, then attempt to commit a fake AWS key — should be rejected.

5. **rbw end-to-end** (chapter 05): `rbw unlock`, `rbw get "Linear API" --field linear_api_key`, plus the `rbw-diagnose` function in a real shell.

6. **YubiKey ed25519-sk** (chapter 05): `ssh-keygen -t ed25519-sk -O verify-required -C "deploy@prod"` with key inserted; touch to enrol; `ssh-add -L` confirms.

7. **Git SSH signing end-to-end** (chapter 05): make a signed commit with `git commit -S`; verify with `git verify-commit HEAD`. Confirm `SSH_AUTH_SOCK` matches `$TMPDIR/rbw-$UID/ssh-agent-socket`.

8. **`/wrap` skill** (chapter 06): type `/wrap` at end of next real session; confirm the dirty-tree guard fires, `NEXT-AGENT-PROMPT.md` is written, and `disable-model-invocation` prevents auto-firing.

9. **SessionStart hook** (chapter 06): open a fresh Claude Code session in a repo with `NEXT-AGENT-PROMPT.md`; confirm the handoff is injected into context.

10. **UserPromptSubmit blocking hook** (chapter 06): wire `user-prompt-block.sh`, then submit a prompt containing "push origin main" — should be blocked.

11. **Branch-name + ticket-prefix hooks via `pre-commit install --hook-type commit-msg`** (chapter 06): create a branch `bad_name`, attempt a commit — both hooks should fire and block.

12. **`cheat.fish`** (chapter 07): if user installs fish, run `fish -n /path/to/cheat.fish` to syntax-check, then source and call `cheat git`.

13. **lychee link-check** (chapter 07): `lychee docs/` against the cheats dir; verify dead URLs surface.

14. **Self-hosted ntfy on a VPS/Pi** (chapter 04, self-hosting section): only relevant if user actually self-hosts.

---

**Verdict:** v0.1 is in good shape — one real bug (macOS `sed -i -E` in the cheats pre-commit hook), everything else passes syntax/structure checks. The remaining ~14 items require user hands-on and were explicitly flagged in their chapters as "verify locally."
