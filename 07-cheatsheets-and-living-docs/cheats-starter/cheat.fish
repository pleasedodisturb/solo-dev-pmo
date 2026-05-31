# cheat <topic> — render a personal cheatsheet from $CHEATS_DIR (fish).
# Renderer auto-detected: glow > bat > mdcat > less > cat.
# Override location: set -Ux CHEATS_DIR ~/path/to/cheats/docs
function cheat --description 'Show a personal cheatsheet'
    set -l dir (test -n "$CHEATS_DIR"; and echo $CHEATS_DIR; or echo $HOME/cheats/docs)
    set -l topic $argv[1]
    set -l f "$dir/$topic-cheatsheet.md"

    if test -z "$topic"; or not test -f "$f"
        test -n "$topic"; and printf 'No cheatsheet for "%s". Available topics:\n' "$topic"
        test -z "$topic"; and printf 'Usage: cheat <topic>. Available topics:\n'
        set -l found 0
        for c in $dir/*-cheatsheet.md
            test -e "$c"; or continue
            set found 1
            printf '  %s\n' (string replace -r '\-cheatsheet\.md$' '' (basename $c))
        end
        test $found -eq 0; and printf '  (none yet in %s)\n' "$dir"
        return 1
    end

    if command -q glow
        glow -p "$f"
    else if command -q bat
        bat --style=plain --paging=auto -l md "$f"
    else if command -q mdcat
        mdcat "$f"
    else if command -q less
        less "$f"
    else
        cat "$f"
    end
end
