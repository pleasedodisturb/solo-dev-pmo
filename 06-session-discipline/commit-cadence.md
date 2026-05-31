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

## Conventional Commits compatibility

The playbook's `<ticket>: <title>` pattern is a **super-set** of [Conventional Commits v1.0.0][cc]: the spec mandates a `type(scope)!: description` subject plus body and footers, where footers "follow a convention similar to git trailer format."[¹] Nothing stops you running both:

```
G-732 feat(pm): rename pm-system → command-center
```

`G-732` is the ticket; `feat(pm):` is the Conventional Commits type+scope. A `commitlint`/`cocogitto` parser reads the type; `git log --grep="G-732"` reads the ticket. The two namespaces don't collide.

When to bother: only if a downstream toolchain consumes the type. [semantic-release][sr] and [Changesets][cs] derive the next SemVer bump and changelog from commit types[²] — if you ship a versioned library, adopt the type prefix so releases automate. If you don't publish releases, the type is ceremony; keep the ticket prefix and a plain imperative title.

**Gitmoji** (`✨ feat`, `🐛 fix`) is the emoji-prefixed alternative — same intent, different surface.[³] The playbook rejects it: emojis don't `grep` cleanly, render inconsistently in `git log` across terminals, and the chapter bans emojis project-wide. If you like the visual scan, that's a `git log` alias's job, not the stored message's.

> `BREAKING CHANGE:` (uppercase, in a footer) and the `!` shorthand are the one Conventional Commits convention worth adopting unconditionally — they're how a human *and* a release tool both spot an API break.[¹]

## Agent attribution (Co-Authored-By)

When Claude Code (or any agent) wrote most of a commit, attribute it with a [`Co-authored-by:` trailer][ghco] — the same mechanism GitHub uses to credit pair work:[⁴]

```
G-410 feat(api): add idempotency keys to payment intents

<body>

Co-authored-by: Claude Opus 4.7 <noreply@anthropic.com>
```

Rules that matter (per GitHub docs):[⁴]
- Trailer goes after a **blank line** following the body.
- One `Co-authored-by:` line per author; no blank lines between multiple.
- Use a **no-reply email** for the agent — keeps a real human's inbox out of the trailer and renders the avatar on GitHub.

Who is `author` vs `co-author`? Convention in this playbook: **you** are the commit author (you ran the session, you reviewed, you're accountable); the agent is the co-author. Don't invert it — the accountable human owns the authorship line. This is the commit-level echo of the [`Reviewed-by:` trailer](./pr-review-standard.md): attribution is cheap, and future-you wants to know which commits an agent drove.

## WIP commits on long branches

Rule 5 ("WIP checkpoint commits OK") needs a discipline so the branch doesn't ship 40 `wip` commits into `main`'s history. The pattern:

1. **During the branch:** commit freely. `git commit -m "wip: trying the retry-backoff approach"`. Cheap checkpoints beat lost work.
2. **Before review/merge:** clean the history. Two options, pick by audience:
   - **Squash-on-merge** (GitHub "Squash and merge"): the branch's commits collapse into one on `main`. Simplest; the PR is the unit. Good default for solo work.[⁵]
   - **Interactive rebase** when the branch is genuinely several logical changes worth keeping separate:
     ```bash
     git fetch origin main
     git rebase -i origin/main      # mark wip commits "fixup"/"squash"
     git push --force-with-lease     # never bare --force; see below
     ```
3. **Add the `Reviewed-by:` trailer** to the surviving commit(s) after the squash, not before — squashing drops trailers from fixup'd commits.

`--force-with-lease` (not `--force`) refuses to overwrite if someone/another machine pushed in the meantime — the multi-machine safety net. Bare `--force` is banned (see [README rules](./README.md)).

For the rebase-vs-merge debate in solo context, see [Long-running branches that drift](#long-running-branches-that-drift-from-main) below.

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

## Long-running branches that drift from main

A branch open for days drifts from `main`. The solo-dev resolution differs from the team default:

- **Teams** often prefer merge commits to preserve "what was actually integrated when." Multiple people share the branch, so rewriting history breaks their clones.
- **Solo** (or solo + agents on the same disk): **rebase**. You own every clone. A linear history is easier to `git bisect` and reads as a clean story. `git fetch origin main && git rebase origin/main` keeps your branch on top of latest.[⁵]

The one exception: if a branch is shared across machines via push (you started it on the laptop, continued on the desktop), treat it as shared — rebase only with `--force-with-lease`, and only when you're certain no other machine has un-pulled commits. When in doubt, merge `main` into the branch instead of rebasing; uglier history, zero risk.

## Related

- [PR review standard](./pr-review-standard.md) — review before push
- [Wrap and resume](./wrap-and-resume.md) — session-level discipline
- [Chapter 02 — Slug rules](../02-filesystem-conventions/slug-rules.md) — branch naming
- [Chapter 03 — Agent rules](../03-claude-code-as-operator/agent-rules.md) — agents follow same rules

---

[cc]: https://www.conventionalcommits.org/en/v1.0.0/
[sr]: https://semantic-release.gitbook.io/semantic-release/
[cs]: https://github.com/changesets/changesets
[ghco]: https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors

[¹]: Conventional Commits v1.0.0 specification — https://www.conventionalcommits.org/en/v1.0.0/ — accessed 2026-05-31.
[²]: semantic-release, "How it works" (commit-message-driven SemVer) — https://semantic-release.gitbook.io/semantic-release/ ; Changesets — https://github.com/changesets/changesets — accessed 2026-05-31.
[³]: Gitmoji convention — https://gitmoji.dev/ ; semantic-release-gitmoji (emoji-as-release-type) — https://github.com/momocow/semantic-release-gitmoji — accessed 2026-05-31.
[⁴]: GitHub Docs, "Creating a commit with multiple authors" — https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors — accessed 2026-05-31.
[⁵]: Practitioner consensus on squash-on-merge vs rebase for linear history; see Git docs on `git rebase` and `--force-with-lease` — https://git-scm.com/docs/git-rebase — accessed 2026-05-31.
