# cheats-starter — copy-paste skeleton

> A zero-dependency personal cheatsheet system you can stand up on a fresh
> machine in under five minutes. Everything here is in
> [`cheats-starter/`](./cheats-starter/) as runnable files — this page is the
> narrated version.

The whole system is: a directory of `*-cheatsheet.md` files, an eight-line
shell function, and one optional git hook. No binary to install, no config
format to learn, no daemon. The cheatsheets are plain markdown you fully
control and git-track.

## Directory structure

```
cheats/                       # a git repo
├── cheat.sh                  # bash/zsh function (source from .bashrc/.zshrc)
├── cheat.fish                # fish variant
├── hooks/
│   └── pre-commit            # refreshes "last-validated:" stamps
└── docs/
    ├── git-cheatsheet.md
    ├── tmux-cheatsheet.md
    ├── claude-code-cheatsheet.md
    └── …                     # one file per topic
```

## The recommended cheatsheet shape

Order entries by access frequency, not alphabetically — the thing you reach
for daily goes at the top. The shape below renders well in `glow`, `bat`, and
plain `cat`, and greps cleanly. (Verified sample:
[`docs/git-cheatsheet.md`](./cheats-starter/docs/git-cheatsheet.md).)

```markdown
# git cheatsheet
<!-- last-validated: 2026-05-31 -->

> Daily git ops, my aliases, and the gotchas that have bitten me.

## Most common

| Command | What | When |
|---|---|---|
| `git switch -c <branch>` | Create + switch to a branch | Starting work |
| `git restore <file>` | Discard unstaged changes to a file | Undo, keep branch |

## Gotchas

- **`git reset --hard` is destructive** — no undo without `git reflog`.

## See also
- `git help <verb>` for the canonical reference
```

Four parts, every time: a one-line `>` summary (the picker reads it), a
**Most common** table (`command | what | when`), a **Gotchas** section (the
expensive-to-rediscover failures), and **See also**. The
`<!-- last-validated: -->` stamp is what the rot tooling keys off
(see [cheatsheet-discipline.md](./cheatsheet-discipline.md)).

## The shell function (bash / zsh)

Source [`cheat.sh`](./cheats-starter/cheat.sh) from your `~/.bashrc` or
`~/.zshrc`. It auto-detects a renderer (`glow` → `bat` → `mdcat` → `less` →
`cat`) so it degrades gracefully on a bare machine:

```bash
cheat() {
  local dir="${CHEATS_DIR:-$HOME/cheats/docs}"
  local topic="$1"
  local f="$dir/${topic}-cheatsheet.md"

  if [ -z "$topic" ] || [ ! -f "$f" ]; then
    [ -n "$topic" ] && printf 'No cheatsheet for "%s". Available topics:\n' "$topic"
    [ -z "$topic" ] && printf 'Usage: cheat <topic>. Available topics:\n'
    for c in "$dir"/*-cheatsheet.md; do
      [ -e "$c" ] || { printf '  (none yet in %s)\n' "$dir"; return 1; }
      printf '  %s\n' "$(basename "$c" -cheatsheet.md)"
    done
    return 1
  fi

  if   command -v glow  >/dev/null 2>&1; then glow -p "$f"
  elif command -v bat   >/dev/null 2>&1; then bat --style=plain --paging=auto -l md "$f"
  elif command -v mdcat >/dev/null 2>&1; then mdcat "$f" | ${PAGER:-less -R}
  elif command -v less  >/dev/null 2>&1; then less "$f"
  else cat "$f"
  fi
}
```

Set the location once: `export CHEATS_DIR="$HOME/cheats/docs"`.

## The fish variant

fish needs different syntax; the behaviour is identical. Full file:
[`cheat.fish`](./cheats-starter/cheat.fish). Load it with
`source ~/cheats/cheat.fish` and `set -Ux CHEATS_DIR ~/cheats/docs`.

## fzf picker

`cheat-fzf` (bundled in [`cheat.sh`](./cheats-starter/cheat.sh)) fuzzy-picks a
topic with a live preview, then hands the choice to `cheat`. It falls back to
the plain topic list when `fzf` isn't installed, so it's safe to always define:

```bash
cheat-fzf   # type to filter; Enter renders the selection
```

The picker feeds fzf `topic⇥summary` rows built from each file's `>` line, with
a `glow`/`cat` preview window.

## Search across cheatsheets (ripgrep)

`cheat <topic>` is for when you know the topic. When you don't, search the
content:

```bash
# Which cheatsheet mentions this? (list files only)
rg -l 'reflog' "$CHEATS_DIR"

# Show matches with their section heading and line number
rg --heading -n -i 'detach' "$CHEATS_DIR"

# Literal search when the pattern has regex metacharacters
rg -F 'git reset --hard' "$CHEATS_DIR"
```

Bind it to a function if you grep often: `cheats() { rg --heading -n -i "$*" "$CHEATS_DIR"; }`.

## Date-stamp pre-commit hook

[`hooks/pre-commit`](./cheats-starter/hooks/pre-commit) refreshes the
`last-validated:` stamp on any cheatsheet you touch, then re-stages it — so the
stamp tracks "last time I actually looked at this," not "last time I created the
file." Install it:

```bash
ln -sf ../../hooks/pre-commit ~/cheats/.git/hooks/pre-commit
```

```bash
#!/usr/bin/env bash
set -euo pipefail
today=$(date +%F)
changed=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\-cheatsheet\.md$' || true)
[ -z "$changed" ] && exit 0
while IFS= read -r f; do
  [ -f "$f" ] || continue
  grep -q 'last-validated:' "$f" \
    && sed -i -E "s/last-validated: [0-9]{4}-[0-9]{2}-[0-9]{2}/last-validated: ${today}/" "$f"
  git add "$f"
done <<< "$changed"
```

(Prefer the [pre-commit framework](https://pre-commit.com)? Wrap this as a
local hook; the logic is identical.)

## Verified

Every snippet on this page was run on a fresh Linux container (bash 5.2, zsh,
fish; no `glow`/`bat`/`fzf` installed) before shipping: the function lists and
renders topics in all three shells via the `cat`/`less` fallback, the picker
degrades to the plain list without `fzf`, and the hook rewrote a stale
`2020-01-01` stamp to the current date and re-staged the file.

## Related

- [README](./README.md) — where this pattern wins vs. `tldr` / `cheat.sh` / `cheat/cheat`
- [Cheatsheet discipline](./cheatsheet-discipline.md) — keeping the files honest
- [Living docs](./living-docs.md) — the broader category this sits inside
