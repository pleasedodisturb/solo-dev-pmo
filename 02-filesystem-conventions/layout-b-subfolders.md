# Layout B: subfolder categories under ~/Projects/

> Group projects into category subdirectories under `~/Projects/`. Folder leaf names stay short; the path communicates category.

## The layout

```
~/Projects/
├── awesome/          # curation lists, awesome-* repos
├── cases/            # job-application case studies / portfolio work
├── infra/            # personal infrastructure & setup
├── apps/             # bounded products (the things you ship)
├── tools/            # internal CLIs, SDKs, agents
├── research/         # research, spikes, experiments
├── media/            # published content (blogs, sites, Plex stack)
├── money/            # personal finance
├── upstream/         # OSS you clone, fork, contribute to
├── scratch/          # disposable, -temp, experiments
└── (top-level exceptions, explicitly documented)
```

## What each category means

**`awesome/`** — Curation lists. Repos that are "lists of things." E.g., `awesome-dev-funding-list`, `llm-tokens-list` (a curated list of techniques), `meta-awesome` (your own meta-awesome). Continuous-area work; never "ships."

**`cases/`** — Job-application case studies. One repo per company you've case-studied for. Each repo contains the company-specific work product (analysis, mockups, code samples). Bounded; archives after the application closes.

**`infra/`** — Personal infrastructure. Dotfiles (`dotfiles`), Mac setup automation (`mac-setup`, `mac-sync`), terminal config (`your-toolkit`), backup tools (`notes-backup`), home network. Continuous; never "complete."

**`apps/`** — Bounded products. The things you actually ship — apps, services, MVPs. One repo per product. Examples: `app-bar` (a specific product), `app-baz` (another), `learning-app`.

**`tools/`** — Internal CLIs, SDKs, agents you build for yourself. Examples: `repo-sync-tool` (a tool that keeps repos in sync), `pm-tool-mcp` (an MCP server you built), `linearis` if you wrap your own Linear CLI.

**`research/`** — Research projects, spikes, experiments. Things that are exploratory and may or may not turn into something. Examples: `learning-rust` (an active learning project), `web-research` (a benchmark), `llm-research` (a research project).

**`media/`** — Published content. Blog repos, marketing sites, Plex media stack. Examples: `personal-blog` (a blog), `dev-blog` (another blog), `media-server` (config repo for the Plex stack).

**`money/`** — Personal finance. `money` (your YNAB-adjacent ledger / scripts). Continuous.

**`upstream/`** — OSS projects you don't own but engage with. Forks you maintain (`get-shit-done`, `tmux-continuum`), vendored clones (`vendored-clone`). The "I have a relationship with this OSS project" category.

**`scratch/`** — Disposable. `*-temp` directories (per the [slug rules](./slug-rules.md) exemption), ad-hoc experiments, archived work that's no longer active, repos waiting for deletion. Anything that landed in `~/Projects/` but doesn't fit a real category.

## Top-level exceptions

Some directories sit at `~/Projects/` top level, not under a category. These should be explicitly documented and rare. Typical:

- **A meta-PM repo** that operates on *all* categories (this playbook's source repo type — typically named `command-center` or similar). Doesn't fit a category because it's about the categories.

That's usually it. One exception. Be strict — every "top-level exception" you add reduces the cleanliness of the layout.

## Layout A (rejected): flat, with prefixes

The alternative we rejected — call it **Layout A** — keeps every repo at the top level and uses name prefixes to fake categories:

```
~/Projects/
├── app-bar/
├── app-baz/
├── case-acme/
├── infra-dotfiles/
├── infra-mac-setup/
├── tool-repo-sync/
├── research-learning-rust/
└── … 25 more …
```

Rejected for one reason: **flat-with-prefixes still leaves 30+ items at top level.** The "I open `~/Projects/` and see a giant zoo" problem isn't solved. Prefixes give you *sorted* clutter, not *de-cluttered* sort.

Subfolders (Layout B) cost you one extra `cd` level. The benefit: `ls ~/Projects/` shows ~10 categories, not 30 repos. Switch into the category, find the project, work. (And if you're under ~15 repos, Layout A is genuinely fine — see the [chapter README's counter-argument](./README.md#when-flat-is-fine-the-honest-counter-argument).)

## How other heavy users organize (and why ours differs)

Most published "where do my repos live" recipes organize by **provenance** — host / org / repo — not by **purpose**. That's a real and defensible alternative, and worth seeing side by side:

| Scheme | Layout | Axis | Source |
|---|---|---|---|
| **This playbook (Layout B)** | `~/Projects/<category>/<repo>` | Purpose (apps/tools/infra/…) | — |
| dblock | `~/source/<org-or-theme>/<repo>` | Org + theme, owner-named fork dirs | [¹] |
| "GitHub Tree" (Osame) | `~/Developer/github/<org>/<repo>` | Host → org → repo | [²] |
| Piet van Zoen | `~/repos/<host>/<user>/<repo>` | Host → user → repo | [³] |
| `ghq` (tool-enforced) | `~/.ghq/<host>/<user>/<repo>` | Host → user → repo (auto) | [⁴] |

The provenance schemes have one big win: they're **mechanical** — a tool (`ghq get`, a `gclone` function) derives the path from the clone URL, so you never decide where anything goes. The cost is that browsing by *what a thing is for* is impossible; everything from `<org>` is interleaved regardless of whether it's an app, a fork, or a throwaway.

Layout B trades that automation away for intent-legibility: `ls ~/Projects/apps/` is "the things I ship." Pick provenance if you clone a lot of other people's code and rarely browse; pick purpose (Layout B) if your own small repos dominate and you browse by goal. Both beat accretion.

## Monorepos: one leaf, packages namespaced inside

A monorepo is **one disk leaf**, not a category. Its internal "projects" are namespaced *inside* the single repo, never promoted to siblings under `~/Projects/`.

```
~/Projects/apps/acme-platform/      # ONE repo = one disk leaf = one slug
├── apps/                           # internal deployables (pnpm/nx convention)
│   ├── web/
│   └── api/
├── packages/                       # internal shared code
│   └── ui/
└── pnpm-workspace.yaml
```

This matches how the workspace tools themselves frame it: pnpm calls a monorepo a workspace that "unite[s] multiple projects inside a single repository," rooted at a `pnpm-workspace.yaml`;[⁵] Nx defines a monorepo as "a single code repository that contains multiple distinct applications," organized into `apps/` and `libs/`.[⁶] The git boundary is the unit of identity, so it's the unit Layout B sorts. Don't fight it by hoisting `web/` and `api/` to `~/Projects/apps/` — they aren't separate repos and have no separate slug or remote.

Nix flakes don't change this either: a `flake.nix` is an in-repo, root-level file,[⁷] so a flake-ified repo is still exactly one disk leaf — now with two extra tracked files.

## Disk path vs GitHub repo name

With Layout B, the disk path no longer matches the GitHub repo. `~/Projects/research/learning-rust` on disk maps to `github.com/<user>/learning-rust` remote.

This is **safe** as long as:
- The leaf folder name (`learning-rust`) matches the GitHub repo name exactly (per [slug rules](./slug-rules.md)).
- Your shell launcher derives project name from `git rev-parse --show-toplevel | basename`, NOT from a directory pattern.

If your launcher hardcodes `~/Projects/*` (a one-level glob), Layout B breaks it. Fix the launcher first, then migrate.

## Subfolders are archivable as batches

Useful side effect: you can archive whole categories.

`mv ~/Projects/research/old-project ~/Projects/scratch/` — done. The project is now in scratch, will get deleted on the next scratch sweep.

`mv ~/Projects/cases/2025/* ~/Projects/scratch/old-cases/` — bulk archive an old year of cases.

With flat-prefix layout, you'd be moving 30+ folders individually. Subfolders compress the operation.

## Naming and category overlap

Some projects sit between categories. Examples:
- "Is `app-qux` an app or a research project?" — if it's headed for production, `apps/`. If it's still being figured out, `research/`.
- "Is `dotfiles` infra or tools?" — infra, because it's *your* setup, not a tool for others.
- "Is `repo-sync-tool` infra or tools?" — tools, because it's a CLI / agent that operates on infra. (Borderline.)

The rule: when in doubt, pick the category that signals **intent of use**, not **subject matter**. `app-qux` is intended to ship as a product → `apps/`. `web-research` is intended as research output → `research/`.

If a project genuinely doesn't fit any category, that's signal you need a new category (e.g., `upstream/` got added when fork-maintenance work didn't fit). Don't force-fit.

## The `research/` collision trap

Watch out: if you have a folder called `research/` *and* the category is `research/`, you get an "umbrella vs category" collision.

Concretely: you had `~/Projects/research/` as an umbrella folder containing 3 ad-hoc research dirs (`claude-time/`, `dev-funding/`, `ukrainian-book-publishers/`). Now you want `research/` as a CATEGORY containing real projects.

The conflict: which is `research/`? The umbrella or the category?

Resolution: **the category wins; the umbrella moves.** The 3 ad-hoc dirs relocate to `scratch/old-research/`. The new `research/` category is created fresh by the first real research project moving into it.

Document this in the move audit so future-you knows why `~/Projects/scratch/old-research/` exists.

## Field-tested gotchas

**Absolute paths break on migration.** Python venvs, git hooks, MCP configs, symlinks, and shell aliases all bake absolute paths. Moving `~/Projects/foo` to `~/Projects/apps/foo` breaks all of them. Run a full sweep before any move:
```bash
# In the project root being moved:
grep -rln "/Users/$USER/Projects/$OLD_NAME/" .   # what references this path?
```

**Launcher glob patterns break.** A launcher script that does `for d in ~/Projects/*/`, expects flat. Fix to `for d in ~/Projects/*/*/`, or refactor to use `git` discovery.

**`~/.claude/projects/` memory dirs encode the absolute path.** When you move a project, Claude Code's memory directory needs a corresponding move. Path encoding: `-Users-<user>-Projects-<repo>` becomes `-Users-<user>-Projects-<category>-<repo>`. Memory needs to follow.

**The `~/.zshrc` references break.** Many `.zshrc` files have aliases / functions that hardcode `~/Projects/<name>/...`. Migrate one repo at a time; sweep `.zshrc` for the old name; update.

**TitleCase folders are tempting and wrong.** `~/Projects/Money/` looks important. It's a violation of slug rules — and the tooling will fail to match it. Always lowercase. See [slug rules](./slug-rules.md) for why "grandfathered exceptions" don't last.

## Innovative pattern: category-aware launchers

Build a `c <name>` shell function that:
1. Searches across all categories for a matching project name
2. If unique match, `cd` to it
3. If multiple matches, fzf-prompts among them
4. If no match, suggests creating it under a sensible category

```bash
c() {
  local target=$(find ~/Projects -maxdepth 2 -type d -name "$1" | head -5)
  case $(echo "$target" | wc -l) in
    1) cd "$target" ;;
    *) cd "$(echo "$target" | fzf)" ;;
  esac
}
```

This lets you stay slug-aware without remembering categories.

## Innovative pattern: convention-driven CI checks

A small daily `launchd` job runs `repo-sync-tool` (or your own equivalent) that:
- Lists all folders at `~/Projects/*/*/` (depth 2)
- Checks each has a `CLAUDE.md`
- Checks each is in a category subfolder (not top-level)
- Checks each leaf-name matches slug rules
- Reports drift to `ntfy`

Convention enforcement at the filesystem level. Drift gets visible the day after.

## Sources

- [¹] https://code.dblock.org/2016/03/25/a-directory-structure-for-oss-and-work-github-clones.html — accessed 2026-05-31
- [²] https://hirok.io/posts/github-tree-structure — accessed 2026-05-31
- [³] https://piet.me/blog/organizing-git-projects/ — accessed 2026-05-31
- [⁴] https://github.com/x-motemen/ghq — accessed 2026-05-31
- [⁵] https://pnpm.io/workspaces — accessed 2026-05-31
- [⁶] https://nx.dev/docs/concepts/decisions/why-monorepos — accessed 2026-05-31
- [⁷] https://nix.dev/concepts/flakes.html — accessed 2026-05-31

## Related

- [Slug rules](./slug-rules.md) — the format the leaf names follow
- [Linear ↔ GitHub binding](./linear-github-binding.md) — bridging disk layout to PM
- [Worktree placement](./worktree-placement.md) — why worktrees live elsewhere
- [Chapter 06 — Audit pattern](../06-session-discipline/audit-and-conventions-pattern.md) — document the migration in dated audits
