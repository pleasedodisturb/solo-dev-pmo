# git cheatsheet
<!-- last-validated: 2026-05-31 -->

> Daily git ops, my aliases, and the gotchas that have bitten me.

## Most common

| Command | What | When |
|---|---|---|
| `git switch -c <branch>` | Create + switch to a branch | Starting work |
| `git restore <file>` | Discard unstaged changes to a file | Undo, keep branch |
| `git commit --amend --no-edit` | Fold staged changes into last commit | Forgot a file |
| `git log --oneline -10` | Compact recent history | Quick orientation |

## Gotchas

- **`git reset --hard` is destructive** — no undo without `git reflog`.
- **`--no-verify` skips pre-commit AND pre-push hooks.** Never use it as a shortcut.

## Recipes

Undo the last commit but keep the changes staged:

    git reset --soft HEAD~1

## See also
- `git help <verb>` for the canonical reference
