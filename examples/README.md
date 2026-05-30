# Examples

Concrete artifacts referenced throughout the playbook. Copy, adapt, drop into place.

| File | Where to put it | What it is |
|---|---|---|
| `global-CLAUDE.md.template` | `~/.claude/CLAUDE.md` | Layer 1 global rules template |
| `CLAUDE.md.template` | `<repo>/CLAUDE.md` | Layer 2 project rules template |
| `MEMORY.md.template` | `~/.claude/projects/<encoded>/memory/MEMORY.md` | Layer 3 auto-memory index template |
| `ticket-template.md` | PM tool's issue template setting | 7-section agent-autonomous-ready ticket |
| `launchd-monday-plan.plist` | `~/Library/LaunchAgents/com.<your>.monday-plan.plist` | Monday 09:00 trigger |
| `monday-plan.sh` | `~/.local/bin/monday-plan` | The script the launchd plist fires |
| `pre-push-review-hook` | `~/.claude/git-hooks/pre-push` (+ `git config --global core.hooksPath ~/.claude/git-hooks`) | Block pushes lacking Reviewed-by trailer |
| `.gitignore.secrets` | Append to your `.gitignore` | Secrets-focused gitignore patterns |
| `conventions-naming.md` | `<meta-pm-repo>/conventions/naming.md` | Slug + layout + worktree convention example |
| `conventions-cycles.md` | `<meta-pm-repo>/conventions/cycles.md` | Cycle cadence + WIP + estimates convention example |

## Adaptation notes

These are **starting points**, not drop-in-and-go. Every example has placeholders to replace:

- `<your-workspace>`, `<TEAM>` — your PM tool identifiers
- `<u>`, `YOU` — your username
- `<your-pm>`, `linearis` — your PM tool's CLI name
- `<your-ntfy-topic>` — your ntfy topic
- `<example-project>`, `<bounded-project>` — your real project names
- `rbw` — your password manager CLI (could be `op`, `pass`, `keepassxc`)

Edit before deploying. Hard-coded examples won't work as-is.

## Read order

For a fresh setup, copy in this order:

1. `global-CLAUDE.md.template` → `~/.claude/CLAUDE.md` (your global rules)
2. `conventions-naming.md` → `<meta-pm-repo>/conventions/naming.md` (your slug rules)
3. `conventions-cycles.md` → `<meta-pm-repo>/conventions/cycles.md` (your cycle conventions)
4. `ticket-template.md` → PM tool template setting (your ticket spec)
5. `MEMORY.md.template` → per-project Layer 3 (start one per active project)
6. `.gitignore.secrets` → append to project `.gitignore`s
7. `pre-push-review-hook` → install as global hook (mechanical enforcement)
8. `launchd-monday-plan.plist` + `monday-plan.sh` → Monday ritual (last, after Linear setup done)
9. `CLAUDE.md.template` → `<repo>/CLAUDE.md` for each new project you create

## What's NOT in examples

Things the playbook references but doesn't ship as drop-in:

- `~/.claude/skills/<name>/SKILL.md` — skills are too tool-specific (Claude Code, Cursor, etc.)
- `~/.zshrc` snippets — shell-specific
- Friday retro script — analogous to monday-plan.sh; build similarly
- `.pre-commit-config.yaml` — pre-commit framework specific; consult their docs

If you want examples for these, file an issue / PR.
