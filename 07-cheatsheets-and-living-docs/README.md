# 07 — Cheatsheets and living docs

> Build a `cheat <topic>` system. Keep the cheatsheets in lockstep with reality.

This chapter is the shortest because the pattern is small. The discipline is the hard part.

## What this chapter covers

| Section | What it solves |
|---|---|
| [Cheatsheet discipline](./cheatsheet-discipline.md) | When to add to cheatsheets. How to keep them current. |

## The pattern

A `cheat` shell function that takes a topic and shows the cheatsheet:

```bash
cheat() {
  local topic="$1"
  local f="$HOME/Projects/<your-cheats-repo>/docs/${topic}-cheatsheet.md"
  if [ -f "$f" ]; then
    glow "$f"   # or cat, less, bat
  else
    ls "$HOME/Projects/<your-cheats-repo>/docs/"*-cheatsheet.md \
      | xargs -n1 basename | sed 's/-cheatsheet.md//'
  fi
}
```

Then `cheat git`, `cheat zsh`, `cheat linear`, `cheat tmux`, etc. — get the cheatsheet for that topic in your terminal.

## Cheatsheet topics worth maintaining

- `git` — common ops, your aliases, gotchas
- `zsh` — shell functions, aliases, keybinds
- `tools` — CLI tools (`rbw`, `jq`, `gh`, `rg`, etc.)
- `claude-code` — flags, hooks, sandbox controls
- `linear` — `linearis` and Linear GraphQL recipes
- `tmux` — your tmux keybinds and recipes
- `<your-pm>` — PM tool CLI recipes
- `gsd` — GSD workflow commands (if you use it)

## Why a "cheatsheet system" instead of "remember things"

- You don't remember flags. You google them. Cheatsheets save the google.
- The first time you discover a gotcha, it costs 30 minutes. The second time, 5. The cheatsheet entry costs 30 seconds to write.
- Cheatsheets are searchable: `grep -l "ssh-agent" ~/Projects/<cheats>/docs/*-cheatsheet.md` finds the right one.
- The cheatsheet repo IS your living documentation of your stack.

## The maintenance problem

Cheatsheets rot. The cure is discipline (when you learn something cheatsheet-worthy, add it in the same session) and audit (`/wrap` checks recent sessions for missed cheatsheet items).

See [Cheatsheet discipline](./cheatsheet-discipline.md) for the rule.

## Related

- [Chapter 03 — Memory architecture](../03-claude-code-as-operator/memory-architecture.md) — cheatsheets vs. memory (cheatsheets are commands; memory is decisions)
- [Chapter 06 — Wrap and resume](../06-session-discipline/wrap-and-resume.md) — `/wrap` audits cheatsheet coverage
