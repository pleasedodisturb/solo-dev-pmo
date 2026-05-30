# Commit cadence

> Commit after every meaningful change. Don't batch. Push immediately on non-main branches. Every commit has a ticket prefix and a body.

## The rules

1. **Commit after every meaningful change.** If you edited 2+ files or completed a logical unit of work, commit now.
2. **Every commit references a ticket.** Prefix the subject with the ticket ID (`G-123: ...`).
3. **Push after committing on feature branches.** Unpushed branches are invisible to other sessions / machines.
4. **Commit messages are thorough.** Title + body. No one-liners.
5. **WIP checkpoint commits OK on long branches.** Squash before merge if you care.
6. **No notable change in 15+ min of active work → checkpoint anyway.** Better WIP-on-a-branch than no record.

## Commit message format

```
<ticket-id>: <concise title in imperative mood>

<2-4 line body explaining what changed and why. Reference affected
files / areas. The "why" matters more than the "what" — the diff
already shows what.>

Co-Authored-By: <agent-name> <noreply@<host>>
```

Concrete example:

```
G-732: rename pm-system → command-center

Renames the meta-PM repo to align with its broader scope. Previously
called pm-system; that name was too narrow as we extend into
calendar, ritual triggers, and agentic handoff.

Affected:
- Disk path: ~/Projects/pm-system → ~/Projects/command-center
- Claude Code memory dir renamed
- GitHub repo renamed via gh repo rename
- In-repo references swept via grep

Co-Authored-By: claude-opus-4-7 <noreply@anthropic.com>
```

## Why ticket prefixes

`git log --grep="G-732"` returns every commit related to this ticket. Across all your branches, all your repos (if you alias). The ticket trail through code is searchable.

Without prefix, the ticket-to-code link is lost the moment the branch merges.

## Why bodies, not one-liners

A year from now, you'll `git blame` a line and want to know why. The one-liner "fix scoring" is useless. The body that says "scoring pass rate spiked to 27% due to rule weight misconfig in `rules.py:87`" tells future-you everything.

The "I'll write a real body next time" plan never holds. Habits commit cadence.

## Push timing

After committing on a feature branch:
- **Push immediately.** Treat unpushed local commits as fragile (your disk fails, your laptop is stolen — the work disappears).
- **Don't wait for "I'll push at the end of the session."** Sessions end abruptly. Push now.

For commits on `main` (which you shouldn't be doing — see [README rules](./README.md)), pushing is required because main is the integration branch.

## Quick command shortcuts

Many solo devs have a `push` shortcut that does the full sequence:

```bash
# git status + diff to understand changes
# Apply code+security review per checklist
# Stage relevant files (not secrets, not build artifacts)
# Write thorough commit message
# Commit and push
# Update memory if state changed
```

The shortcut prevents the "I'll just push without reviewing this time" temptation.

## When to NOT commit

- **You're mid-experiment.** Commit when the experiment lands at a coherent state. Don't commit "what if I try this" half-thoughts.
- **The change is purely local-config.** `.env` updates, IDE config — those don't need commits.
- **You're about to revert.** If you'll undo in 30 seconds, don't commit.

The "commit after every meaningful change" rule has "meaningful" doing real work. Most things are meaningful. Some aren't.

## When you discover you should've committed earlier

`git stash` to save current state, then `git commit -p` (interactive add) to commit only the earlier-meaningful piece, then `git stash pop` to bring back the rest.

OR: commit everything as one big commit, mention in the body "this is two changes; will split if we need to revert one." Don't split retroactively if you don't need to.

## Field-tested gotchas

**The `git add -A` trap.** Adds files you don't want (build artifacts, log files, accidentally-created files). Prefer explicit `git add <file>` or careful `git add -p`.

**Unpushed branches getting lost to laptop crash.** Push immediately. Don't trust local-only.

**Commit during a rebase that's not yet resolved.** Doesn't commit; aborts the rebase. Confusing first time.

**Conflicting commits when you `git pull` after an unpushed local commit.** Either merge or rebase locally; don't `git pull --force`.

**Subagent commits without reviewing them.** Agent prompts should include the review step OR the agent should NOT commit (have main session commit instead).

## Innovative pattern: per-session commit checkpoint

A `/checkpoint` skill that:
- Runs `git status` and `git diff`
- Identifies if there's meaningful work uncommitted
- Drafts a commit message
- Asks "commit now?"

Fires every 15 minutes during active sessions. Catches the "I forgot to commit" pattern.

## Innovative pattern: ticket-aware commit subjects

A pre-commit hook that:
- Reads the current branch name (`<ticket-id>/<desc>`)
- Verifies the commit subject starts with `<ticket-id>:`
- Rejects if missing

Auto-fixes if you forgot the prefix:
```bash
# Commit fails. The hook outputs:
# Error: commit subject missing G-1234 prefix.
# Suggested: G-1234: <original subject>
```

You retry with the fixed subject. Mechanical enforcement.

## Related

- [PR review standard](./pr-review-standard.md) — review before push
- [Wrap and resume](./wrap-and-resume.md) — session-level discipline
- [Chapter 02 — Slug rules](../02-filesystem-conventions/slug-rules.md) — branch naming
- [Chapter 03 — Agent rules](../03-claude-code-as-operator/agent-rules.md) — agents follow same rules
