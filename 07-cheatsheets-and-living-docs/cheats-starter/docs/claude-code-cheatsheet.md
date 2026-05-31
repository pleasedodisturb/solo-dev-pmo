# claude-code cheatsheet
<!-- last-validated: 2026-05-31 -->

> Claude Code CLI flags and memory-file conventions I reach for.

## Most common

| Command | What | When |
|---|---|---|
| `claude` | Start an interactive session | Default |
| `claude -c` | Continue the most recent session | Resume context |
| `claude -p "<prompt>"` | One-shot, print, non-interactive | Scripts / pipes |
| `/clear` | Reset context in-session | Topic switch |

## Conventions

- `CLAUDE.md` is read at session start; keep it under ~200 lines.
- Pull in detail with `@path/to/file.md` imports (resolved recursively).

## Gotchas

- **`CLAUDE.md` bloat slows every turn.** Move detail into imported files.

## See also
- `claude --help`
