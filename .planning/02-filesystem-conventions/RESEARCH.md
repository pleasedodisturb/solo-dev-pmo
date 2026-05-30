# RESEARCH — Phase P02: Filesystem conventions

> **Stream goal:** validate the Layout B + slug + worktree + Linear↔GitHub binding rules against external practitioner conventions, surface counter-evidence, and add a clean "migration recipe" for readers cleaning up a 30-50 repo chaos.

## 0. Scope

In:
- `02-filesystem-conventions/README.md` + 4 sub-topic files (`layout-b-subfolders.md`, `slug-rules.md`, `linear-github-binding.md`, `worktree-placement.md`)

Out:
- Anything about repo *content* (chapter 03 handles CLAUDE.md, chapter 06 handles commit cadence)
- Shell-launcher implementation (touched lightly in chapter 07)

## 1. What exists today

787 lines across 5 files. Existing depth:

- **Layout B subfolders** — categorized subfolders under `~/Projects/`: apps, tools, infra, research, playbooks, awesome, media, money, cases, upstream, scratch. Plus exceptions.
- **Slug rules** — lowercase + `-` only, ASCII, no `--`, `-temp` exemption, disk leaf = GitHub repo name
- **Linear↔GitHub binding** — `repo: <slug>` as first line of Linear project description; multi-repo via multi-line
- **Worktree placement** — `~/.claude/worktrees/<repo>/<branch>/`, never in `~/Projects/`

## 2. Honest gaps

- **"Why subfolder categories instead of flat?"** is asserted but the trade-off isn't fully spelled out. Some practitioners (e.g., dhh, levelsio publicly) prefer flat. Need a defended position.
- **No version of "Layout A"** is shown. The chapter mentions "Layout B" but never shows the rejected Layout A — so the framing reads incomplete.
- **The 11 categories are author-chosen** with no comparison to other practitioners' categorizations. Need at least one external taxonomy comparison.
- **Linear↔GitHub binding `repo:` tag is novel** but undefended — nobody else publishes this pattern. Need to claim authorship clearly OR find prior art.
- **Worktree placement at `~/.claude/worktrees/`** ties strongly to Claude Code. What about non-Claude-Code users? Need an alternative recommendation.
- **No tooling shown.** A `repo-sync` or `project-pick` script would make the chapter concrete. Even a 20-line zsh function example would help.
- **The 5-phase migration recipe** is solid but lacks an actual TSV manifest example.
- **Edge cases:** monorepos (where one git-toplevel hosts many "projects"), Nix flakes, polyrepo orgs.

## 3. Research questions

### Layout & taxonomy

- **Q02.1** Who else publishes a "categorized ~/Projects layout" recipe? Find 3+ practitioner posts. Likely candidates: dotfiles repos with README; HN profile pages; Plain-text-project / org-mode users.
- **Q02.2** What are the historical taxonomies for "code directory" organization? (Unix Filesystem Hierarchy Standard, `~/Code` vs `~/src` vs `~/dev` conventions, GOPATH legacy, Cargo workspaces.) Build a short history.
- **Q02.3** Counter-argument: who advocates flat `~/Projects/` and why? (Discoverability via `fzf`? "I only have 12 repos"?)
- **Q02.4** What's the per-category load? Does the author's split (apps/tools/infra/research/playbooks/awesome/media/money/cases/upstream/scratch) match other heavy-user splits?

### Slug rules

- **Q02.5** Which projects in popular ecosystems (npm, PyPI, Homebrew, GitHub) enforce slug rules? Cite the regex. (npm: `^(?:@[a-z0-9-_]+\/)?[a-z0-9-_]+$`. Homebrew: docs/Formula-Cookbook.) These give legitimacy to the lowercase-plus-hyphens rule.
- **Q02.6** "Disk leaf = GitHub repo name" — what breaks if they diverge? Find a real horror story (preferably from HN postmortems).
- **Q02.7** Are there scripts in popular dotfiles repos that assume `basename $(pwd)` = repo name? Survey 5+ public dotfiles.
- **Q02.8** The `-temp` exemption — is there a common convention for throwaway scripts? (`-tmp`, `-scratch`, `.tmp` prefix?) Pick the one with most precedent.

### Linear↔GitHub binding

- **Q02.9** How do other tools (Jira, Asana, Trello, ClickUp, GitHub Projects, Notion) handle the "which repo does this project track" link? Find docs.
- **Q02.10** Has anyone published a similar "first-line tag in project description" convention? Likely search: "machine-readable project metadata" + "PM tool description."
- **Q02.11** What's the alternative for non-Linear users? (GitHub Projects + custom field; Notion + relation; Trello + label.) Show one or two alternatives.
- **Q02.12** GitHub Issues now supports project-level metadata (since Projects v2). Could it replace the `repo:` tag? Trade-offs.

### Worktree placement

- **Q02.13** What do other heavy `git worktree` users recommend? (Drew DeVault, Junio Hamano's docs, recent HN threads.) Where do they put worktrees?
- **Q02.14** What happens to `.git/info/exclude`, `.envrc`, IDE config, and Claude Code's `.claude/` when worktrees live outside the source tree? Edge cases.
- **Q02.15** Is there a `direnv` recipe that makes worktree-elsewhere ergonomic?
- **Q02.16** How does this interact with Apple's Time Machine + iCloud Drive scanning if `~/.claude/` is iCloud-synced (it often is via Syncthing — but iCloud users exist)?

### Migration / cleanup

- **Q02.17** Find migration postmortems — "I renamed 50 repos and here's what broke." HN, blog posts.
- **Q02.18** Python venv shebangs encode absolute paths. What's the canonical fix for "moved repo, venv now broken"? (uv recreates; pip --upgrade --force-reinstall?)
- **Q02.19** Same question for Node modules with absolute paths in `.bin/` symlinks.
- **Q02.20** Same question for `.envrc` direnv files with hardcoded paths.

### Monorepos & flakes

- **Q02.21** How does Layout B handle a monorepo with N "projects" inside? Suggest a convention. (Probably: monorepo is one disk leaf; "projects" inside are namespaced under it.)
- **Q02.22** Nix flake users: does the `flake.nix` pattern affect Layout B? Likely not, but document.

## 4. Per-question source plan

| Q | Source class | Specific starting points |
|---|---|---|
| Q02.1–Q02.4 | Practitioner + community | Survey: github.com/topics/dotfiles top 50 sorted by stars. Read each `README.md` for layout discussion. HN search: "my ~/Projects layout." dotfiles managers like chezmoi/yadm READMEs. |
| Q02.5 | Primary | npm naming rules: github.com/npm/validate-npm-package-name. Homebrew Formula Cookbook. PyPA PEP 508 / PEP 503. GitHub repo naming rules (docs.github.com/repositories). |
| Q02.6–Q02.8 | Practitioner | HN search for repo-rename horror. dotfiles repo READMEs surveyed in Q02.1. |
| Q02.9–Q02.12 | Vendor docs | jira docs (atlassian.com), asana help, notion help, trello docs, github.com/features/issues, docs.github.com/projects v2. |
| Q02.13–Q02.16 | Primary + practitioner | git-scm.com/docs/git-worktree (primary). drew.devault.com on git workflows. HN: "git worktree workflow." direnv.net docs. |
| Q02.17–Q02.20 | Practitioner | HN postmortems. PyPA discussion forum on venv paths. uv docs (astral.sh/uv). nodejs.org discussion on .bin paths. |
| Q02.21–Q02.22 | Practitioner + primary | nx.dev / pnpm workspace docs for monorepo conventions. nix.dev for flake conventions. |

## 5. Output requirements

The agent updates files in `/Users/pleasedodisturb/Projects/playbooks/solo-dev-pmo/02-filesystem-conventions/`:

1. **README.md** gains:
   - Brief "history of `~/Projects` conventions" callout box (Q02.2)
   - Counter-argument acknowledgment for flat layouts (Q02.3) — short subsection
2. **`layout-b-subfolders.md`** gains:
   - Explicit "Layout A (rejected)" section showing the flat alternative
   - Comparison table to ≥ 2 other practitioner taxonomies
   - Monorepo handling subsection (Q02.21)
3. **`slug-rules.md`** gains:
   - References to npm/Homebrew/GitHub slug rules with quoted regex
   - At least one real horror story for disk-leaf ≠ repo-name divergence
4. **`linear-github-binding.md`** gains:
   - "Alternatives for non-Linear users" subsection (GitHub Projects v2, Notion relation, Trello label)
   - Honest "we couldn't find prior art for the `repo:` first-line pattern" OR a citation if found
   - Inline 15–20 line shell function that reads the `repo:` tag from Linear and `cd`s to the project
5. **`worktree-placement.md`** gains:
   - "For non-Claude-Code users" subsection
   - Direnv recipe for worktree-elsewhere ergonomics
   - The Time-Machine / iCloud sync caveat
6. **New file:** `02-filesystem-conventions/migration-recipe.md` — the full 5-phase recipe blown out with:
   - A TSV manifest example
   - The Python venv recreation script
   - The Node .bin symlink fix
   - The direnv path-update script
7. **New file:** `02-filesystem-conventions/sources.md` — bibliography

Constraints:
- Caps still apply (~250 lines per sub-topic; `migration-recipe.md` may go to 300 because it ships scripts)
- DO NOT recommend a specific dotfiles manager (chezmoi vs yadm vs stow) — outside chapter scope; mention as "see your dotfiles tool"
- DO NOT recommend a specific shell launcher (`fzf`, `zoxide`, `z`) — chapter 07 territory

## 6. Per-phase search ideas

### Web

- `site:github.com/topics/dotfiles sort:stars`
- `"my projects folder" layout dotfiles`
- `"~/Projects" organize categorize`
- `"git worktree" workflow personal`
- `npm package naming rules`
- `homebrew formula naming`
- `"monorepo" "individual projects" naming convention`
- `direnv "git worktree"`

### Social

- HN: `https://hn.algolia.com/?q=%22~/Projects%22+layout`
- HN: `https://hn.algolia.com/?q=git+worktree+workflow`
- HN: `https://hn.algolia.com/?q=I+renamed+my+repos`
- HN: `https://hn.algolia.com/?q=python+venv+path+broken`
- Lobsters: `https://lobste.rs/search?q=worktree`
- Lobsters: `https://lobste.rs/search?q=dotfiles+layout`
- Reddit: `site:reddit.com/r/git worktree workflow`
- Reddit: `site:reddit.com/r/commandline ~/Projects organize`
- X: `(git worktree) workflow min_faves:30`

### GitHub

- `topic:dotfiles` (sort stars, top 100). Read top-20's READMEs for layout sections.
- `filename:.envrc path:Projects` — practical direnv-in-projects patterns
- `filename:Brewfile path:dotfiles` — adjacent (tool inventory hints)
- Search code: `"git worktree add"` in dotfile-shaped repos

### Specific repos to skim

- `chezmoi/chezmoi` README and example dotfiles
- `twpayne/chezmoi`
- `holman/dotfiles` (canonical)
- `mathiasbynens/dotfiles`
- `paulirish/dotfiles`
- `drwpow/dotfiles`
- `sindresorhus/dotfiles`
- `direnv/direnv` cookbook

## 7. Stop conditions

Stop and surface if:

- A widely-adopted convention contradicts the playbook's slug rules (e.g., a popular tool that requires camelCase in disk paths). Surface to the author.
- The `repo:` first-line binding turns out to be brittle in a 2025–2026 Linear API change. Reconsider.
- The 5-phase migration recipe is too dangerous to publish without disclaimer (e.g., risks of mass-rename on user data). Add safety section.
- iCloud / Time Machine interaction with `~/.claude/worktrees/` produces real data-loss reports. Add prominent warning.

## 8. Estimated effort

M phase. 5–8 hours research + 4–6 hours writing. Migration-recipe sub-file is the longest single deliverable.
