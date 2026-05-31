# tmux cheatsheet
<!-- last-validated: 2026-05-31 -->

> Prefix is `C-b` unless rebound. Everything below assumes the default prefix.

## Most common

| Keys | What | When |
|---|---|---|
| `tmux new -s <name>` | Start a named session | New piece of work |
| `tmux a -t <name>` | Attach to a session | Resume |
| `C-b d` | Detach (session keeps running) | Step away |
| `C-b c` | New window | Parallel task |
| `C-b %` / `C-b "` | Split pane vertical / horizontal | Side-by-side |

## Gotchas

- **Detaching is not killing.** Sessions survive logout; list with `tmux ls`.
- **Copy mode is `C-b [`** — `q` exits it. Easy to get stuck.

## See also
- `man tmux` § KEY BINDINGS
