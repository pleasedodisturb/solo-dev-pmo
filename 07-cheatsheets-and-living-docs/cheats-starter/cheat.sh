# cheat <topic> — render a personal cheatsheet from $CHEATS_DIR.
# Works in bash and zsh. Renderer auto-detected: glow > bat > mdcat > less > cat.
# Override the location with: export CHEATS_DIR="$HOME/path/to/cheats/docs"
cheat() {
  local dir="${CHEATS_DIR:-$HOME/cheats/docs}"
  local topic="$1"
  local f="$dir/${topic}-cheatsheet.md"

  if [ -z "$topic" ] || [ ! -f "$f" ]; then
    [ -n "$topic" ] && printf 'No cheatsheet for "%s". Available topics:\n' "$topic"
    [ -z "$topic" ] && printf 'Usage: cheat <topic>. Available topics:\n'
    # List topics, one per line, derived from filenames.
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

# cheat-fzf — fuzzy-pick a topic (needs fzf). Renders the selection with `cheat`.
# Falls back to plain `cheat` (list) if fzf is missing.
cheat-fzf() {
  local dir="${CHEATS_DIR:-$HOME/cheats/docs}"
  command -v fzf >/dev/null 2>&1 || { cheat; return; }
  local pick
  pick=$(
    for c in "$dir"/*-cheatsheet.md; do
      [ -e "$c" ] || continue
      local t d
      t=$(basename "$c" -cheatsheet.md)
      d=$(sed -n 's/^> //p' "$c" | head -1)
      printf '%s\t%s\n' "$t" "$d"
    done | fzf --with-nth=1.. --delimiter='\t' \
               --preview "f=\"$dir/{1}-cheatsheet.md\"; \
                 command -v glow >/dev/null 2>&1 && glow -s dark \"\$f\" || cat \"\$f\"" \
           | cut -f1
  )
  [ -n "$pick" ] && cheat "$pick"
}
