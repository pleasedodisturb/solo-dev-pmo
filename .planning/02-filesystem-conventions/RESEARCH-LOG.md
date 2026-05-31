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
