# cheats-starter

A zero-dependency personal cheatsheet skeleton. Copy this directory anywhere,
point `$CHEATS_DIR` at `docs/`, and `cheat <topic>` works.

## Install (< 5 minutes)

```bash
# 1. Put this somewhere git-tracked, e.g. ~/cheats
cp -r cheats-starter ~/cheats

# 2. Tell your shell where the docs live and load the function.
#    bash/zsh — add to ~/.bashrc or ~/.zshrc:
export CHEATS_DIR="$HOME/cheats/docs"
source "$HOME/cheats/cheat.sh"

#    fish — add to ~/.config/fish/config.fish:
#    set -Ux CHEATS_DIR ~/cheats/docs
#    source ~/cheats/cheat.fish

# 3. (optional) date-stamp hook
ln -sf ../../hooks/pre-commit ~/cheats/.git/hooks/pre-commit
```

Optional renderers — the function auto-detects them, falling back to `less`/`cat`:
`glow` (recommended), `bat`, or `mdcat`. Optional `fzf` enables `cheat-fzf`.

## Use

```bash
cheat            # list available topics
cheat git        # render docs/git-cheatsheet.md
cheat-fzf        # fuzzy-pick a topic (needs fzf)
rg -l 'reflog' "$CHEATS_DIR"   # search across all cheatsheets
```

## Add a topic

Create `docs/<topic>-cheatsheet.md`, follow the shape of the samples
(one-line `>` summary, "Most common" table, "Gotchas", "See also", and a
`<!-- last-validated: YYYY-MM-DD -->` stamp). Commit it.
