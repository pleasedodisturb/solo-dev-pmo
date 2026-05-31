# RESEARCH-LOG — Phase P07

Append-only log of sources cited while enriching the chapter. Format per
[SEARCH-PLAYBOOK](../SEARCH-PLAYBOOK.md) § "Per-phase research log format".

## 2026-05-31 — Stop-condition re-check: tldr/cheat.sh personal cheatsheets

- **Source:** https://tealdeer-rs.github.io/tealdeer/usage_custom_pages.html ; https://github.com/chubin/cheat.sh/issues/97
- **Class:** primary
- **Surfaced fact:** tealdeer supports custom pages/patches (`custom_pages_dir`, `.page.md`/`.patch.md`) in the **constrained tldr format**; cheat.sh personal cheatsheets only via local Docker deploy. Neither obsoletes the free-form shell function.
- **Used in:** README § "Why not just use tldr / cheat.sh / cheat?"; sources.md
- **Counter-evidence:** custom pages DO cover personal sheets — but in tldr's example-only format, not free-form markdown. Documented as the key distinction.

## 2026-05-31 — cheat/cheat (chrisallenlane) is the honest competitor

- **Source:** https://github.com/cheat/cheat
- **Class:** primary
- **Surfaced fact:** v5.1.0 (2026-02), Go, 13k★. `cheatpaths` (personal + community dirs), tags, fzf, shell completion, directory-scoped `.cheat`. Does almost exactly what the author's function does, batteries-included.
- **Used in:** README comparison table + "honest competitor" hedge; version matrix; "what we'd change in 2026"
- **Counter-evidence:** strong enough that we now recommend it as the on-ramp for readers who want search/completion out of the box.

## 2026-05-31 — tldr-pages scale + clients

- **Source:** https://github.com/tldr-pages/tldr ; https://tldr.sh/tlrc/
- **Class:** primary
- **Surfaced fact:** ~59k★, 1,000+ contributors, official Rust client `tlrc`, Python/Node clients, translations.
- **Used in:** README comparison table; version matrix; sources.md

## 2026-05-31 — adjacent tools: navi, eg, bro

- **Source:** https://github.com/denisidoro/navi ; https://github.com/srsudar/eg ; http://bropages.org/
- **Class:** primary
- **Surfaced fact:** navi = interactive fzf runner with `<arg>` prompts (executing, not reading); eg = zero-config example tool; bro/bropages deprecated/archived 2022.
- **Used in:** README comparison table; version matrix ("don't adopt bro")

## 2026-05-31 — cht.sh client + tab completion

- **Source:** https://cht.sh/:intro ; https://github.com/chubin/cheat.sh
- **Class:** primary
- **Surfaced fact:** `cht.sh` client installs via curl, supports bash/zsh/fish tab completion + stealth mode.
- **Used in:** README comparison table (cheat.sh row)

## 2026-05-31 — living documentation origin

- **Source:** https://gojko.net/books/specification-by-example/ (Gojko Adzic, *Specification by Example*, Manning 2011)
- **Class:** primary (book)
- **Surfaced fact:** "living documentation" term = docs kept true as a by-product of automated examples; manual prose docs need a cheaper, deliberate discipline.
- **Used in:** living-docs.md intro + footnote

## 2026-05-31 — runbooks / playbooks (SRE)

- **Source:** https://sre.google/sre-book/being-on-call/
- **Class:** primary
- **Surfaced fact:** Google calls runbooks "playbooks"; structured runbooks cut MTTR; reused for the thin solo-dev runbook template (symptom / triage-in-order / fix / give-up).
- **Used in:** living-docs.md § "Runbooks for a team of one"; version-matrix footnote

## 2026-05-31 — doc-rot tooling: lychee

- **Source:** https://github.com/lycheeverse/lychee ; https://github.com/lycheeverse/lychee-action
- **Class:** primary
- **Surfaced fact:** fast async markdown/HTML link checker; pre-commit + CI integration for dead-link detection.
- **Used in:** cheatsheet-discipline.md § "Detecting rot"; living-docs.md footnote

## 2026-05-31 — Claude Code memory / @-imports

- **Source:** https://code.claude.com/docs/en/overview
- **Class:** primary
- **Surfaced fact:** `CLAUDE.md` read each session; `@path` imports resolve recursively (5 deep); ~200-line guidance; skills read `.claude/docs/` on demand.
- **Used in:** cheatsheet-discipline.md § "When to point an agent at your cheatsheets"
- **Counter-evidence:** capability is a reason to import *selectively*, not to auto-load everything (context cost).
