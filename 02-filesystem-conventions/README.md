# 02 — Filesystem conventions

> Disk layout is a system design choice. If you have 30+ projects in `~/Projects/`, the layout you pick determines whether `cd` is friction or affordance.

This chapter is opinionated about how to organize a working `~/Projects/` directory across many small repos. The conventions are field-tested at the 30-50 repo scale (solo dev with 5+ years of accumulation).

## What this chapter covers

| Section | What it solves |
|---|---|
| [Layout B (subfolder categories)](./layout-b-subfolders.md) | Flat zoo vs categorized. Picking the lesser pain. |
| [Slug rules](./slug-rules.md) | Lowercase, hyphens, ASCII only. The format machines can sync. |
| [Linear ↔ GitHub binding](./linear-github-binding.md) | `repo: <slug>` tag in the project description. The bridge between PM and code. |
| [Worktree placement](./worktree-placement.md) | Worktrees out of `~/Projects/`; they go in `~/.claude/worktrees/<repo>/<branch>/`. |

## The problem this chapter solves

You start with `~/Projects/foo/`, `~/Projects/bar/`. A year later, you have:

- 30+ folders at top level — most you can't remember what they do
- Inconsistent naming — `Infra-Cleanup`, `pm-system`, `app-foo-onboarding`
- Git worktrees scattered between `~/Projects/` and `~/.claude/worktrees/`
- Linear projects referring to "the app-foo work" — but is that `app-foo/`, `app-foo-server/`, or `app-foo-wiki-temp/`?
- A `~/Projects/research/` folder that has both *real research projects* and *the research category subfolder*

Every one of these problems compounds. The cure is conventions, locked, and tooled.

## The four locks

To live in this chapter, you commit to:

1. **One canonical slug format.** Lowercase + `-` only. Applies to disk leaf names AND GitHub repo names. They must match.
2. **One disk layout.** Subfolder categories under `~/Projects/` (Layout B). Top-level exceptions documented explicitly.
3. **One Linear ↔ GitHub binding mechanism.** `repo: <slug>` as the FIRST line of the Linear project's description.
4. **One worktree home.** `~/.claude/worktrees/<repo>/<branch>/`. Never in `~/Projects/`.

When you adopt this, the disk becomes scriptable. Repo-sync-tool tooling, project pickers, and Claude Code's launcher all derive everything from these four rules.

## Why "conventions" instead of "structure"

Convention files (`conventions/naming.md`, `conventions/states.md`) are durable rules edited in-place. They have no date prefix. They're versioned via git so changes are visible, but they're the always-current source of truth.

This is different from:
- **Architecture decisions** — those live in ADRs (numbered, immutable once decided).
- **Audit notes** — those live in dated files (`audits/YYYY-MM-DD-*.md`), append-only.
- **Project state** — that lives in auto-memory (Layer 3).

The convention file is the canonical answer to "what's our rule for X?" Open the file, get the current rule.

## A short history of `~/Projects` conventions

There is no RFC for where code lives on disk — `~/Code`, `~/src`, `~/dev`, and `~/Projects` are all informal, per-practitioner habits. The one era that *did* dictate layout was Go's `GOPATH`: from 2009–2018 all code had to live under `$GOPATH/src/<host>/<user>/<repo>`, where the on-disk path mirrored the import path.[¹] Go 1.11 (2018) introduced modules and explicitly freed projects from that tree — "the `go` command enables the use of modules when the current directory or any parent directory has a `go.mod`, provided the directory is outside `$GOPATH/src`."[²] Tools like `ghq` later generalized the `host/user/repo` idea to every VCS host.[³]

The takeaway for this chapter: once the language stopped *forcing* a layout, the choice became yours — and a thought-out convention beats accretion. Layout B is one defensible choice, not the only one.

## When flat is fine (the honest counter-argument)

Categories are not free, and not everyone needs them. Two honest counter-positions:

- **Fuzzy finders make hierarchy optional.** Once `fzf`/`zoxide` index your tree, you jump by frecency or fuzzy match, not by remembering folders — so the retrieval value of categories shrinks.[⁴] If your launcher is good, a flat `~/Projects/` with 15 repos is genuinely fine.
- **Hierarchy can discourage the right code.** Mark Seemann argues flat structures stop you from agonizing over "which folder does this belong in"; nesting "subtly discourage[s] developers from introducing code that doesn't fit."[⁵] (His argument is about files inside a project, but it transfers.)

Our position: **below ~15 repos, stay flat.** Layout B earns its one-extra-`cd` cost only once `ls ~/Projects/` stops being scannable — empirically around 30+. Adopt it when you feel the zoo, not before.

## How to bootstrap if you're starting fresh

1. Read [Layout B](./layout-b-subfolders.md) — pick categories that match your work.
2. Read [Slug rules](./slug-rules.md) — start enforcing on new repos immediately.
3. Existing repos: do NOT mass-rename. Migrate opportunistically — when you touch a repo for other reasons, rename to convention as part of that touch.
4. Wire your shell launcher (`c <name>`, `z <name>`, FZF-based) to derive project name from `$(git rev-parse --show-toplevel | basename)`. This way layout changes don't break the launcher.

## How to bootstrap if you're cleaning up

You probably have 30+ projects in chaos. Migration approach:

1. **Phase 1: enumerate.** `find ~/Projects -maxdepth 1 -type d` — list everything.
2. **Phase 2: categorize.** For each folder, assign to a category (or scratch). Use a TSV manifest, not a script — categorization needs human judgment.
3. **Phase 3: validate the categorization.** Some folders won't fit; that's signal that your categories need a new one (e.g., `upstream/` for OSS forks).
4. **Phase 4: move in atomic batches.** Don't try to migrate everything at once. Batches of 5-7 with verification scripts that confirm the move didn't break anything.
5. **Phase 5: audit and lock.** Final pass for the orphans. Document the locked rules in `conventions/naming.md`.

Field-tested timing: 30-50 repos = 2-3 weeks of weekend work for careful migration. Don't rush; broken absolute paths in venvs, hooks, MCP configs, and symlinks are slow to diagnose later.

## Related

- [Chapter 03 — CLAUDE.md template](../03-claude-code-as-operator/claude-md-template.md) — every project gets one at the repo root
- [Chapter 06 — Audit and conventions pattern](../06-session-discipline/audit-and-conventions-pattern.md) — how the convention files relate to dated audits
- [Migration recipe](./migration-recipe.md) — the cleanup procedure, blown out with safety rules and fix scripts
- [Sources](./sources.md) — full bibliography for this chapter

## Sources

- [¹] https://go.dev/wiki/GOPATH — accessed 2026-05-31
- [²] https://go.dev/blog/using-go-modules — accessed 2026-05-31
- [³] https://github.com/x-motemen/ghq — accessed 2026-05-31
- [⁴] https://thoughtbot.com/blog/tools-i-like-zoxide — accessed 2026-05-31
- [⁵] https://blog.ploeh.dk/2023/05/29/favour-flat-code-file-folders/ — accessed 2026-05-31
