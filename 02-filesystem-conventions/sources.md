# Sources — Chapter 02: Filesystem conventions

Bibliography for the externally-grounded claims in this chapter (M1 research
milestone, phase P02). Weighting per
[`.planning/SEARCH-PLAYBOOK.md`](../.planning/SEARCH-PLAYBOOK.md): primary docs >
vendor blog > academic > practitioner > community. All URLs accessed
**2026-05-31**.

> Sourcing note: several primary docs (`go.dev`, `git-scm.com`, `linear.app`,
> `support.atlassian.com`, `docs.python.org`, `peps.python.org`) rate-limited
> automated fetching during research. Where a page couldn't be rendered
> directly, the quoted text was taken from the project's canonical raw source
> (e.g. `raw.githubusercontent.com/git/git/.../*.adoc`, `python/peps`,
> `npm/validate-npm-package-name`) — which is the same text the rendered page
> shows — or from search-engine extracts, flagged inline in the chapter where
> exact wording matters.

## README — history & flat-layout counter-argument

- [primary] Go Wiki: GOPATH — https://go.dev/wiki/GOPATH — `$GOPATH/src/<host>/<user>/<repo>` layout; disk path mirrors import path.
- [primary] Using Go Modules (Go 1.11) — https://go.dev/blog/using-go-modules — modules let projects live outside `$GOPATH/src`.
- [community/tool] ghq — https://github.com/x-motemen/ghq — generalizes `host/user/repo` cloning to all VCS hosts.
- [vendor-blog] thoughtbot, "Tools I like: zoxide" — https://thoughtbot.com/blog/tools-i-like-zoxide — frecency-based jumping reduces the value of manual hierarchy.
- [practitioner] Mark Seemann, "Favour flat code file folders" — https://blog.ploeh.dk/2023/05/29/favour-flat-code-file-folders/ — hierarchies "subtly discourage" code that doesn't fit.

## Layout B — taxonomies, monorepo, flakes

- [practitioner] dblock, "A directory structure for OSS and work GitHub clones" — https://code.dblock.org/2016/03/25/a-directory-structure-for-oss-and-work-github-clones.html — `~/source` grouped by org/theme.
- [practitioner] Hiroki Osame, "GitHub Tree" — https://hirok.io/posts/github-tree-structure — `~/Developer/github/<org>/<repo>`.
- [practitioner] Piet van Zoen, "Organizing git projects" — https://piet.me/blog/organizing-git-projects/ — `~/repos/<host>/<user>/<repo>`.
- [community/tool] ghq — https://github.com/x-motemen/ghq — tool-enforced `host/user/repo`.
- [primary] pnpm workspaces — https://pnpm.io/workspaces — a workspace "unite[s] multiple projects inside a single repository."
- [primary] Nx, "Why monorepos" — https://nx.dev/docs/concepts/decisions/why-monorepos — "a single code repository that contains multiple distinct applications."
- [primary] nix.dev, Flakes — https://nix.dev/concepts/flakes.html — `flake.nix` is a root-of-repo, in-repo file.

## Slug rules — registry naming + rename horror story

- [primary] npm `validate-npm-package-name` — https://github.com/npm/validate-npm-package-name — lowercase, url-safe, ≤214 chars, banned chars.
- [primary] PEP 508 — https://peps.python.org/pep-0508/ — name regex `^([A-Z0-9]|[A-Z0-9][A-Z0-9._-]*[A-Z0-9])$` (re.IGNORECASE).
- [primary] PEP 503 — https://peps.python.org/pep-0503/ — normalize: lowercase + collapse runs of `[-_.]` to one `-`.
- [primary] Homebrew Formula Cookbook — https://docs.brew.sh/Formula-Cookbook — "Filenames should be all lowercase."
- [primary] Docker `distribution/reference` — https://github.com/distribution/reference — image path component grammar `[a-z0-9]+`, lowercase-only.
- [community] github-limits — https://github.com/dead-claudia/github-limits — GitHub repo-name char set, ≤100 code points, invalid→single hyphen, case-insensitive uniqueness.
- [community] logrus "Case change breaks builds?" — https://github.com/sirupsen/logrus/issues/451 — `Sirupsen`→`sirupsen` import-collision breakage.
- [community] golang/dep #806 — https://github.com/golang/dep/issues/806 — downstream blast radius of the same rename.

## Linear ↔ GitHub binding — alternatives & prior art

- [community] MCP spec issue #1483 — https://github.com/modelcontextprotocol/modelcontextprotocol/issues/1483 — ad-hoc description metadata "is not machine-readable and cannot be reliably parsed."
- [primary] git-interpret-trailers — https://git-scm.com/docs/git-interpret-trailers — RFC-822-style `key: value` trailer lines (conceptual ancestor).
- [primary] GitHub Docs, YAML front-matter — https://docs.github.com/en/contributing/writing-for-github-docs/using-yaml-frontmatter — metadata block at top of a file.
- [primary] Conventional Commits 1.0.0 — https://www.conventionalcommits.org/en/v1.0.0/ — `type(scope): description` structured first line.
- [primary] Linear GitHub integration — https://linear.app/docs/github-integration — linking is issue/PR-level (branch names, magic words).
- [primary] GitHub Docs, single-select fields — https://docs.github.com/en/issues/planning-and-tracking-with-projects/understanding-fields/about-single-select-fields — custom `Repo` field option.
- [primary] GitHub Docs, about projects — https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects — Projects v2 is user/org-level, repo-agnostic.
- [primary] Notion GitHub help — https://www.notion.com/help/github — URL/relation property to a synced GitHub DB.
- [primary] Trello GitHub Power-Up — https://support.atlassian.com/trello/docs/using-the-github-power-up/ — attach branch/PR to a card.
- [primary] Linear GitHub Issues Sync changelog — https://linear.app/changelog/2023-12-14-github-issues-sync — binds a *team* (not a project) to repos.
- [primary, dogfooded] This repo's Linear project ("solo-dev-pmo Playbook", workspace `abandoned-yachts`) — summary first line is `repo: solo-dev-pmo`; verified via Linear MCP 2026-05-31.

## Worktree placement — docs, direnv, cloud-sync caveat

- [primary] git-worktree — https://git-scm.com/docs/git-worktree — `.git` file with absolute `gitdir:` pointer; sibling-path example; `extensions.worktreeConfig`; both-moved repair impossible.
- [primary] gitrepository-layout — https://git-scm.com/docs/gitrepository-layout — `info/exclude` lives under the common dir (shared across worktrees).
- [primary] direnv stdlib — https://direnv.net/man/direnv-stdlib.1.html — `source_env`/`source_up`; `layout python` derives under `$PWD`; parent `.envrc` not security-rechecked.
- [vendor-blog] "Git worktrees with bare repos" — https://medium.com/@miladpw/git-worktrees-with-bare-repos-a-clean-setup-for-modern-development-c5b251ee7b73 — bare-repo + sibling-worktrees layout.
- [practitioner] josh.fail, git + iCloud — https://josh.fail/2022/a-solution-for-git-repos-and-icloud/ — iCloud corrupts `.git`.
- [community] Dropbox forum — https://www.dropboxforum.com/discussions/101001014/why-am-i-getting-conflicted-copies-when-using-git-commands-onmacos-ventura-with-/708318 — conflicted copies from git in Dropbox.
- [practitioner] sqlpey, git + Dropbox — https://sqlpey.com/git/git-dropbox-safe-practices/ — sync/atomicity mismatch; selective-sync exclude unreliable.
- [practitioner] heissenberger, exclude node_modules from Time Machine — https://www.heissenberger.at/en/blog/macos-exclude-node_modules-folder-from-time-machine/ — `tmutil addexclusion`.
- [practitioner] mjtsai, Spotlight indexing running wild — https://mjtsai.com/blog/2025/07/21/spotlight-indexing-running-wild/ — many small churning files amplify indexing cost.

## Migration recipe — what breaks on a move, and the fixes

- [primary] Python venv docs — https://docs.python.org/3/library/venv.html — venvs "inherently non-portable"; recreate + delete if moved.
- [primary] uv — https://docs.astral.sh/uv/ — opt-in `uv venv --relocatable`.
- [community] npm/cli #4308 — https://github.com/npm/cli/issues/4308 — `.bin` symlinks regenerated by reinstall; remedy is remove + reinstall.
- [primary] direnv stdlib — https://direnv.net/man/direnv-stdlib.1.html — `layout python` derives venv under `$PWD/.direnv` (don't hardcode).
- [primary] git-worktree — https://git-scm.com/docs/git-worktree — `git worktree repair`; both-moved is unrepairable.
- [primary] GitHub Docs, renaming a repository — https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository — redirects for clone/fetch/push, but reusing the old name breaks them; Actions refs not redirected.
- [practitioner] ss64, `hash` — https://ss64.com/mac/hash.html — `hash -r` flushes cached command paths.
- [primary/vendor] Apple Support 102321 — https://support.apple.com/en-us/102321 — rebuild the Spotlight index.
- [community] lerna #423 — https://github.com/lerna/lerna/issues/423 — moving a project folder invalidates absolute-path symlinks.
