# Worktree placement

> Git worktrees do NOT live in `~/Projects/<name>-<ticket>/`. They live in `~/.claude/worktrees/<repo-slug>/<branch-name>/`.

## The rule

Worktrees out of `~/Projects/`. They go in:

```
~/.claude/worktrees/<repo-slug>/<branch-name>/
```

Concrete examples:
```
~/.claude/worktrees/app-foo/feature-onboarding/
~/.claude/worktrees/command-center/G-732/rename
~/.claude/worktrees/app-bar/G-892/cv-export
```

The branch name segment can use `/` because filesystems allow it; matches git's branch naming.

## Why not in `~/Projects/`

The naive pattern is `~/Projects/<repo>-<ticket>/` for worktrees. Three problems:

1. **It pollutes `~/Projects/`.** A 30-project tree balloons to 50+ when active worktrees are in there. The category cleanup from [Layout B](./layout-b-subfolders.md) is undone.
2. **Your launcher confuses worktree dirs for projects.** `c app-foo-N123` would `cd` into the worktree, not the main checkout. Path ambiguity.
3. **Worktrees aren't projects.** They're transient branches of an existing project. Treating them as siblings of projects is a category error.

## Why `~/.claude/worktrees/`

Specifically `~/.claude/` because:
- It's already the Claude Code config directory. Agents that work with worktrees are at home there.
- Aligns with `your-toolkit`'s existing `.claude/worktrees/` pattern (if you use a similar dotfiles setup).
- It's outside `~/Projects/` so the layout there stays clean.
- Backed up by your existing dotfiles sync (Syncthing, dotfiles, etc.).

If you don't have `~/.claude/`, pick a parallel dir: `~/Code-worktrees/` or `~/.git-worktrees/`. The point is "not in `~/Projects/`."

## When to use worktrees

A worktree is the right choice when:

- **Parallel agent execution** — multiple agents working different tickets simultaneously. Each needs an isolated checkout.
- **Long workflows (GSD plan-phase, execute-phase)** — the working tree shouldn't shift under you mid-workflow. A worktree pins the branch.
- **A hot-fix while a feature branch is in progress** — your main checkout has uncommitted changes; switching branches there would lose them. Worktree the hotfix.
- **Reviewing a PR locally without losing local state** — worktree the PR branch, review, drop.

NOT for:

- **Quick one-off branch work** — `git checkout -b foo`, work, merge, delete. Faster than worktree setup.
- **Long-running parallel development** that's never going to merge — that's a fork, not a worktree.

## Creating a worktree

```bash
cd ~/Projects/<category>/<repo>
git worktree add ~/.claude/worktrees/<repo>/<branch-name> -b <branch-name>
cd ~/.claude/worktrees/<repo>/<branch-name>
# work
```

For ticket-based branches:
```bash
git worktree add ~/.claude/worktrees/<repo>/G-1234/short-desc -b G-1234/short-desc
```

The created branch derives from current HEAD (typically `main`). To branch from elsewhere:
```bash
git worktree add ~/.claude/worktrees/<repo>/foo -b foo origin/feature-base
```

## Cleaning up

```bash
# Delete the worktree (its directory)
git worktree remove ~/.claude/worktrees/<repo>/<branch>

# Optionally delete the branch
git -C ~/Projects/<category>/<repo> branch -D <branch>
```

A worktree's branch is just a branch in the main repo's git store. Removing the worktree dir doesn't delete the branch. Garbage-collect both.

If a worktree dir is deleted manually (bypassing `git worktree remove`):
```bash
git -C ~/Projects/<category>/<repo> worktree prune
```

## Worktree-aware launcher

Your `c <name>` shell function should be worktree-aware:

```bash
c() {
  local target=$(find ~/Projects -maxdepth 3 -type d -name "$1" 2>/dev/null \
               | head -5)
  if [ -z "$target" ]; then
    # Try worktrees
    target=$(find ~/.claude/worktrees -maxdepth 3 -type d -name "$1" 2>/dev/null | head -5)
  fi
  case $(echo "$target" | wc -l) in
    1) cd "$target" ;;
    *) cd "$(echo "$target" | fzf)" ;;
  esac
}
```

You can `c <repo>` to go to main, `c <branch>` to go to a worktree. Both reachable.

## Long-workflow rule

For long workflows (any GSD `plan-phase`, `execute-phase`, `autonomous`), spawn the worktree **before** the first commit, not after.

Why: long workflows make branch switches in the main checkout dangerous. If you start work in main, then need to `git checkout feature-X` for an unrelated check, your in-progress state is at risk. Worktree first means the main checkout stays clean.

## Field-tested gotchas

**Worktree paths break Python venvs.** `.venv` symlinks reference absolute paths. A worktree created without recreating the venv has a broken venv. Either:
1. Symlink the main checkout's `.venv` into the worktree (fragile, works for read-only)
2. Recreate `.venv` in the worktree (slower setup, robust)
3. Use a tool that handles this (`uv`, `pdm`, etc.)

**Worktree paths break `.envrc` (direnv).** `direnv` watches the cwd; worktree dir doesn't have an `.envrc` until you copy or symlink one. Plan for this in your worktree setup script.

**Multiple worktrees of the same branch is forbidden by git.** Can't have two worktrees both checked out to `G-1234/foo`. If you need parallelism, branch off (`G-1234/foo-parallel`).

**Worktree prune doesn't delete branches.** It only prunes references to deleted worktrees. The branch lives until you `git branch -D` it. Track this in your cleanup script.

**Background agents lack permission inheritance for `cd ~/.claude/worktrees/...`.** If your agent rules restrict where Bash can run, ensure worktree paths are allowed.

**The path-encoding for Claude Code memory.** A worktree at `~/.claude/worktrees/foo/bar/` may not have a corresponding memory dir. Some setups symlink memory back to the main checkout's memory; others give worktrees independent memory. Decide which.

## Innovative pattern: ticket-worktree pairing

A `ticket-worktree-start` script:
```bash
#!/usr/bin/env bash
# Usage: ticket-worktree-start G-1234
TICKET="$1"
INFO=$(linearis issue show "$TICKET" --json)
SLUG=$(echo "$INFO" | jq -r '.project.repo')   # uses the repo: tag binding
DESC=$(echo "$INFO" | jq -r '.title' | tr -c 'a-z0-9' '-' | head -c 30)

cd ~/Projects/$(repo-find "$SLUG")
git worktree add ~/.claude/worktrees/$SLUG/$TICKET/$DESC -b $TICKET/$DESC
cd ~/.claude/worktrees/$SLUG/$TICKET/$DESC

# Drop the ticket spec as a local README for the agent
echo "$INFO" | jq -r '.description' > .TICKET.md
```

Start: `ticket-worktree-start G-1234`. End: you're in a worktree branched correctly, with the ticket spec in `.TICKET.md` for your agent's context. Total setup time: ~5 seconds.

## Innovative pattern: parallel-safe enforcement

Tickets marked `parallel-safe: yes` in their [execution metadata](../01-linear-as-load-bearing-pm/ticket-standard.md) can run in worktrees concurrently. Tickets marked `parallel-safe: no` (because they touch the same files) cannot.

Your `ticket-worker` agent checks before spawning:
```bash
if ticket_field "$TICKET" "parallel-safe" == "no"; then
  # Check if any other agent is working on conflicting tickets
  active_branches=$(git -C ~/Projects/$REPO worktree list | tail -n +2 | awk '{print $3}')
  for active in $active_branches; do
    if ticket_conflicts "$TICKET" "$active"; then
      echo "Refusing to parallelize $TICKET with $active"
      exit 1
    fi
  done
fi
```

System-enforced parallel safety. Beats the "two agents racing on the same file" failure mode.

## Related

- [Layout B](./layout-b-subfolders.md) — what `~/Projects/` looks like (worktrees are out of scope there)
- [Chapter 01 — Ticket standard](../01-linear-as-load-bearing-pm/ticket-standard.md) — `Worktree` execution metadata field
- [Chapter 06 — Session discipline](../06-session-discipline/) — long workflow rules
