# Cheatsheet discipline

> When you learn something daily-use worthy, propose a cheatsheet edit in the same response — don't just save a memory and move on.

## The rule

Cheatsheets are useful only if they reflect current reality. When new features ship or new gotchas surface, the cheatsheet must move in lockstep — otherwise it silently rots, and future-you has to re-discover the same things.

## Origin

A real example: a new `CLAUDE_DEADMAN_THRESHOLD=N` launch-time bypass + `c --research N` wrapper shipped. The canonical doc was updated, but `claude-code-cheatsheet.md` and `zsh-cheatsheet.md` were not. Next day: "how do I set the budget for new agents now?" The user had to re-find the answer.

That's the cost. The discipline is the cure.

## What counts as "daily-use worthy"

Something you'll plausibly grep for or invoke `cheat` on within the next 90 days:

- A new flag, env var, alias, or shell function (especially after shipping a feature)
- A gotcha that cost time to discover (the failure mode + the fix)
- A "use X not Y" substitution (`rg` over `grep`, `glow` over `less`, etc.)
- A command sequence used more than once (verification recipes, lookup recipes)
- A version pin or installed-vs-not-installed tool note

## What does NOT count

- **One-shot project state** ("we're on phase 4") → goes in MEMORY.md (Layer 3), not cheatsheets
- **Narrative / situational context** → memory, not cheatsheet
- **Internal codebase patterns derivable from `git grep`** → no doc needed
- **Speculation** ("X *might* be useful later") → wait until confirmed

## How to apply

### In-session

When you notice cheatsheet-worthy content, add it to the relevant cheatsheet **immediately**. Pick by topic:

- `claude-code-cheatsheet.md` — Claude Code CLI flags, hooks, sandbox controls
- `zsh-cheatsheet.md` — shell functions, aliases, keybinds
- `tools-cheatsheet.md` — CLI tools (`rbw`, `jq`, `gh`, `rg`, etc.)
- `gsd-cheatsheet.md` — GSD workflow commands
- `linear-cheatsheet.md` — Linear / `linearis` CLI
- `git-cheatsheet.md` — git ops and conventions
- `tmux-cheatsheet.md`, `ghostty-cheatsheet.md`, `window-management-cheatsheet.md`, `workflow-cheatsheet.md` — self-explanatory

### Keep entries terse

One row / one bullet. Link to fuller docs.

```markdown
| Command | What it does | When to use |
|---|---|---|
| `rg -F "literal string"` | Search with NO regex interpretation | When pattern contains `.`, `*`, `?` |
| `gh pr view <N> --json reviewers` | List PR reviewers | Checking review status without opening browser |
```

### Audit at /wrap

A `/wrap` Phase 1.5 step "Cheatsheet Sweep" walks the conversation looking for missed items. Catch the things you almost forgot to write down.

### Daily cadence

Optionally: a launchd job that scans recent sessions for `cheat`-worthy content; until that lands, `/wrap` is the only safety net.

## Where edits land

Cheatsheets live in a repo (e.g., `~/Projects/<your-cheats>/docs/*-cheatsheet.md`). Git-tracked. Every edit goes through branch + PR + merge per global Git Workflow rule. No "small change" exemption. Bundle related cheatsheet edits into one ticket where it makes sense.

## Sample cheatsheet structure

```markdown
# Git Cheatsheet

## Common ops

| Command | What | When |
|---|---|---|
| `git switch <branch>` | Switch branches (newer than `git checkout`) | Modern git, > 2.23 |
| `git restore <file>` | Discard changes (newer than `git checkout`) | Same |
| `git switch -c <branch>` | Create and switch | New branch |

## My aliases

- `gst` → `git status`
- `gco` → `git checkout`
- `gca` → `git commit --amend --no-edit`

## Gotchas

- **`--no-verify` skips pre-commit AND pre-push hooks.** Never use unless explicit override.
- **`git reset --hard` is destructive.** No undo without reflog.
- **Force-push to main is forbidden by global rule.** Don't.

## Recipes

### Commit with ticket prefix and trailer
```bash
git commit -m "G-XXX: short subject

Body.

Reviewed-by: <agent> (code+security)"
```

### Add review trailer to existing commits
```bash
git rebase -x 'git commit --amend --no-edit --trailer "Reviewed-by: <agent> (code+security)"' main..HEAD
```

## See also
- `~/.claude/CLAUDE.md` § Git Workflow
- `~/.claude/docs/pr-review-standard.md`
```

The format: tables for "command → what → when," sections for "gotchas," "recipes," "see also." Optimized for `cheat git` lookup.

## Field-tested gotchas

**Cheatsheet entries that rot.** The flag changed, the syntax changed, the env var renamed. Audit quarterly: read your own cheatsheets and verify each command still works.

**Multiple cheatsheets covering the same topic.** "Is this in `git` or `workflow`?" — when topics overlap, pick a canonical home and cross-reference.

**Cheatsheet too long.** A 1000-line `git-cheatsheet.md` is hard to scan. Split into `git-basics`, `git-rewriting-history`, `git-hooks`, etc.

**Adding an entry but not testing it.** Cheatsheet entries are claims about how something works. Run the command before checking in.

## Innovative pattern: cheatsheet from cheat history

`cheat` shell function logs lookups:

```bash
cheat() {
  local topic="$1"
  echo "$(date) $topic" >> ~/.local/share/cheat-history
  # ... show the cheatsheet
}
```

Weekly review of cheat-history reveals:
- Most-looked-up topics → expand those cheatsheets
- Topics looked up that don't exist → write new cheatsheets
- Cheatsheets never accessed → audit relevance

## Innovative pattern: cheatsheet-driven onboarding doc

When someone joins (collaborator, contractor, future-you on a new machine), point them at `~/Projects/<cheats>/docs/`. The cheatsheets ARE the onboarding doc.

For solo dev: the cheatsheets ARE the onboarding doc for future-you on a fresh setup.

## Related

- [Chapter 06 — Wrap and resume](../06-session-discipline/wrap-and-resume.md) — `/wrap` audits cheatsheet coverage
- [Chapter 03 — Memory architecture](../03-claude-code-as-operator/memory-architecture.md) — cheatsheets ≠ memory
- [Chapter 06 — Commit cadence](../06-session-discipline/commit-cadence.md) — cheatsheet edits are commits, follow the cadence
