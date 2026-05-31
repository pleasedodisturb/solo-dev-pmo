# 07 — Cheatsheets and living docs

> Build a `cheat <topic>` system. Keep the cheatsheets in lockstep with reality.

This chapter is the shortest because the pattern is small. The discipline is the hard part.

## What this chapter covers

| Section | What it solves |
|---|---|
| [Cheatsheet discipline](./cheatsheet-discipline.md) | When to add to cheatsheets. How to keep them current. |
| [cheats-starter](./cheats-starter.md) | Copy-paste skeleton — function, samples, hook (tested). |
| [Living docs](./living-docs.md) | The broader category: runbooks, FAQs, conventions, audits. |

## The pattern

A `cheat` shell function that takes a topic and shows the cheatsheet:

```bash
cheat() {
  local dir="${CHEATS_DIR:-$HOME/cheats/docs}"
  local f="$dir/${1}-cheatsheet.md"
  if [ -f "$f" ]; then
    glow "$f"   # or bat, less, cat — see cheats-starter.md for auto-detect
  else
    ls "$dir/"*-cheatsheet.md | xargs -n1 basename | sed 's/-cheatsheet.md//'
  fi
}
```

Then `cheat git`, `cheat zsh`, `cheat linear`, `cheat tmux`, etc. — get the cheatsheet for that topic in your terminal. The full, tested version (bash + zsh + fish, fzf picker, search, hook) is in [cheats-starter.md](./cheats-starter.md).

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

## Why not just use tldr / cheat.sh / cheat?

This is prior art, and it's good. Be honest about it:

| Tool | What it is | Best for | Personal cheatsheets? |
|---|---|---|---|
| **this `cheat` fn** | 8-line shell fn over your `*.md` | *Your* recipes, gotchas, free-form prose + tables | Yes — it's the whole point |
| [`tldr` / `tealdeer`](https://tealdeer-rs.github.io/tealdeer/) | Community example pages (59k★, ~thousands of pages) | "How do I use `tar`?" — universal commands | Yes, but in the **constrained tldr format** (`> desc`, `- example:` + one-line code spans) |
| [`cheat.sh`](https://github.com/chubin/cheat.sh) | `curl cht.sh/<cmd>`, no install | Zero-setup lookups, in-editor | Via local Docker deploy only |
| [`cheat/cheat`](https://github.com/cheat/cheat) | Go binary, `cheatpaths`, tags, fzf, completion | Batteries-included personal sheets | Yes — its core feature |
| [`navi`](https://github.com/denisidoro/navi) | Interactive `fzf` runner with `<arg>` prompts | *Executing* parameterised commands, not reading | Yes, in `.cheat` syntax |

**You could just use `tldr`** for universal commands — and you should; don't
write a `tar` cheatsheet the world already maintains. The free-form function
earns its place for the half of your notes that *aren't* a single command:
multi-step recipes, "use X not Y" rules, your aliases, the gotcha that cost you
an afternoon, prose. tldr/tealdeer custom pages can't hold those without
fighting the format.

**The honest competitor is [`cheat/cheat`](https://github.com/cheat/cheat)**
(v5.1.0, Feb 2026) — it does almost exactly what this function does, with
search, tags, and completion built in, over plain markdown. If you want
batteries included, use it. The shell function wins on exactly three axes: zero
dependencies (nothing to install on a fresh box — it degrades to `cat`), total
format freedom (any markdown `glow` renders), and it's *yours* (8 lines you can
read in full). Pick the function when those matter; pick `cheat/cheat` when they
don't. (Re-checked May 2026: neither `tldr` nor `cheat.sh` has shipped anything
that obsoletes the free-form pattern — they solve the *universal-command*
problem, not the *personal-notes* one.)

## The maintenance problem

Cheatsheets rot. The cure is discipline (when you learn something cheatsheet-worthy, add it in the same session) and audit (`/wrap` checks recent sessions for missed cheatsheet items).

See [Cheatsheet discipline](./cheatsheet-discipline.md) for the rule.

## And the broader living-docs picture

Cheatsheets are one kind of *living document* — a doc whose value depends on
tracking reality. The same freshness discipline applies to runbooks ("it's on
fire, now what?"), FAQ files, conventions (ch. 02/06), and audits (ch. 06).
[Living docs](./living-docs.md) names the full set and adds the two this chapter
owns: the solo-dev runbook and the FAQ file.

## Related

- [Chapter 03 — Memory architecture](../03-claude-code-as-operator/memory-architecture.md) — cheatsheets vs. memory (cheatsheets are commands; memory is decisions)
- [Chapter 06 — Wrap and resume](../06-session-discipline/wrap-and-resume.md) — `/wrap` audits cheatsheet coverage
