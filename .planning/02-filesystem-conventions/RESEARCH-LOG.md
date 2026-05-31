# RESEARCH-LOG — Phase P02: Filesystem conventions

Append-only log of sources cited while enriching the `02-filesystem-conventions/`
chapter. Format per `.planning/SEARCH-PLAYBOOK.md` §"Per-phase research log format".
Bibliography rolls up into `02-filesystem-conventions/sources.md`.

---

## 2026-05-31 — Phase kickoff + methodology

- **Approach:** Five parallel research streams, one per question cluster
  (layout/taxonomy, slug rules, PM↔repo binding, worktree placement,
  migration breakage). Each stream returns citation-ready facts (URL +
  source class + quotable detail), which then get woven into the chapter
  with inline `[¹]` markers and footnotes.
- **Citation bar:** Primary vendor docs > vendor blog > academic >
  practitioner > community (per SEARCH-PLAYBOOK weighting). Where no
  external source exists, the claim is hedged honestly rather than
  fabricated.

## 2026-05-31 — Linear↔GitHub binding, verified first-hand

- **Source:** This playbook's own Linear workspace — project
  "solo-dev-pmo Playbook" (`abandoned-yachts`), retrieved via Linear MCP.
- **Class:** primary (dogfooded instance)
- **Surfaced fact:** The project's summary field literally begins with
  `repo: solo-dev-pmo` as its first line — a live, in-production instance
  of the `repo:` first-line binding convention this chapter documents.
  Confirms the pattern is real and currently in use, not aspirational.
- **Used in:** `linear-github-binding.md` — "Field tests beyond the author".
- **Counter-evidence:** none. Note the tag lives in Linear's *summary*
  field (the short blurb), which is the first free-text field a reader/parser
  sees; `description` was empty for this project.

## 2026-05-31 — Layout & taxonomy (Q02.1–4, 21–22)

- **Surfaced facts:** Most published "where repos live" recipes organize by
  *provenance* (host/org/repo: dblock, GitHub-Tree, van Zoen, ghq), not by
  *purpose* like Layout B — a real alternative worth contrasting. GOPATH
  (2009–2018) forced disk=import-path; Go 1.11 modules freed it (verified the
  exact go.dev wording first-hand). Flat-layout counter-argument is well
  supported via fuzzy-finder discoverability (zoxide) + Seemann; the strict
  "flat because I only have 12 repos" claim had **no** named source (hedged).
  Monorepo = one leaf, packages namespaced inside (pnpm/nx). Flakes are
  in-repo, orthogonal to layout.
- **Used in:** README.md (history + flat counter-arg), layout-b-subfolders.md
  (Layout A, taxonomy table, monorepo, flakes).

## 2026-05-31 — Slug rules (Q02.5–8)

- **Surfaced facts:** Exact registry regexes pulled from primary raw sources —
  npm rules, PEP 508 name regex, PEP 503 normalization, Docker
  `distribution/reference` grammar, GitHub limits. Our lowercase+hyphen rule is
  the strict *intersection* of all five. Horror story: the
  `Sirupsen`→`sirupsen` logrus rename caused ecosystem-wide
  case-insensitive-import-collision breakage — the canonical evidence for
  "disk leaf must equal canonical name, lowercased."
- **Used in:** slug-rules.md ("every registry agrees" table + horror story).
- **Counter-evidence:** none contradicting the rule. Homebrew is laxer (allows
  `_`), noted as slug-*like*; we stay stricter on purpose.

## 2026-05-31 — Linear↔GitHub binding (Q02.9–12)

- **Surfaced facts:** **No prior art** for "`repo:` as first line of a PM
  project description" — claim authorship; closest ancestors are git trailers,
  YAML front-matter, Conventional Commits. No PM tool (Linear, Jira, GitHub
  Projects, Asana, Notion, Trello) ships a native project→repo field; links are
  issue/PR-level. Non-Linear equivalents: GitHub Projects v2 custom field,
  Notion relation, Trello label/Power-Up.
- **Used in:** linear-github-binding.md (prior-art, alternatives table, field
  tests, `proj-cd` shell function).

## 2026-05-31 — Worktree placement (Q02.13–16)

- **Surfaced facts:** Git allows worktrees anywhere (`.git` file holds an
  absolute `gitdir:`); docs' default is a *sibling*; bare-repo+sibling is the
  popular clean variant. `info/exclude` + config are shared across worktrees
  unless `extensions.worktreeConfig`. direnv: worktree isn't a child of main,
  so resolve `.envrc` via `git rev-parse --git-common-dir`. **iCloud/Dropbox
  corrupt live `.git`** (widely reported) — strong caveat; also Time
  Machine/Spotlight churn. No Syncthing evidence either way (hedged).
- **Used in:** worktree-placement.md (non-CC subsection, direnv recipe,
  cloud-sync caveat, shared-config gotcha). Corrected a stale "backed up by
  Syncthing" line that contradicted the new caveat.

## 2026-05-31 — Migration breakage (Q02.17–20)

- **Surfaced facts:** Python venvs non-relocatable *by design* (docs say
  recreate); `uv venv --relocatable` is the opt-in. node_modules disposable —
  wipe + reinstall. direnv: derive from `$PWD`, don't hardcode. git worktrees:
  `repair`, but both-moved is unrepairable. GitHub rename redirects are fragile
  (don't reuse old name; Actions not redirected). `hash -r` + Spotlight rebuild
  for stale caches. No single viral "mass-rename postmortem"; evidence is
  issue-tracker + primary-doc (stronger for *what* breaks).
- **Used in:** migration-recipe.md (new file) — safety section + fix scripts.

## 2026-05-31 — Honest hedges carried into the chapter

- No named practitioner for "flat because I only have N repos" — chapter states
  the discoverability variant only.
- GitHub does not enumerate its repo-name grammar in official prose; cited the
  community `github-limits` catalog.
- No prior art for the `repo:` first-line tag — chapter claims authorship.
- No Syncthing-specific git-corruption evidence — chapter says "don't assume."
- Method caveat: automated fetch was rate-limited on several primary domains;
  load-bearing quotes were taken from canonical raw sources or re-verified.
