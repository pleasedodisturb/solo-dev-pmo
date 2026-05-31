# Sources — Chapter 07

Bibliography rollup for the cheatsheets-and-living-docs chapter. Weighting per
[SEARCH-PLAYBOOK](../.planning/SEARCH-PLAYBOOK.md): primary docs > vendor blog >
practitioner > community. All accessed 2026-05-31.

## Prior-art cheatsheet tools (primary)

- **tldr-pages** — collaborative cheatsheets, ~59k★, 1,000+ contributors, official Rust client `tlrc`. https://github.com/tldr-pages/tldr · https://tldr.sh/
- **tealdeer** — fast Rust tldr client; custom pages + patches via `custom_pages_dir` (`.page.md` / `.patch.md`, tldr format). https://tealdeer-rs.github.io/tealdeer/usage_custom_pages.html
- **cheat.sh** (Igor Chubin) — `curl cht.sh/<cmd>`; tab-completion client `cht.sh`; private cheatsheets via local Docker. https://github.com/chubin/cheat.sh · https://cht.sh/:intro
- **cheat/cheat** (chrisallenlane) — Go, v5.1.0 (2026-02), `cheatpaths`, tags, fzf, shell completion, directory-scoped `.cheat`. https://github.com/cheat/cheat
- **navi** (denisidoro) — interactive `fzf` cheatsheet runner with `<arg>` prompts. https://github.com/denisidoro/navi
- **eg** (srsudar) — example-based, zero-config, custom dirs. https://github.com/srsudar/eg
- **bro / bropages** — deprecated/archived 2022 (do not adopt). http://bropages.org/

## Discoverability + ergonomics (practitioner)

- **fzf** — fuzzy finder, used by `cheat-fzf` picker. https://github.com/junegunn/fzf
- **glow** — markdown renderer (Charm). https://github.com/charmbracelet/glow
- **ripgrep** — search across cheatsheets. https://github.com/BurntSushi/ripgrep

## Living docs + maintenance

- **Gojko Adzic, *Specification by Example* (Manning, 2011)** — origin of "living documentation." https://gojko.net/books/specification-by-example/
- **Google, *Site Reliability Engineering*** — playbooks/runbooks, on-call, freshness. https://sre.google/sre-book/being-on-call/
- **lychee** — fast async link checker for markdown/HTML/CI; pre-commit hook. https://github.com/lycheeverse/lychee
- **pre-commit** — hook framework. https://pre-commit.com

## AI-agent interaction

- **Claude Code docs** — `CLAUDE.md` memory, `@`-imports (recursive, ~200-line guidance), skills reading `.claude/docs/`. https://code.claude.com/docs/en/overview

## Notes on evidence gaps

- No external study measuring **cheatsheet rot rates** was found; the
  `last-validated` / 6-month-threshold practice is adapted from living-docs and
  SRE freshness conventions, not a cheatsheet-specific source. Flagged as such in
  [cheatsheet-discipline.md](./cheatsheet-discipline.md) § "Field tests beyond the author."
- **Re-check (stop condition):** as of May 2026, neither `tldr-pages` nor
  `cheat.sh` has shipped personal-cheatsheet support that obsoletes the free-form
  shell-function pattern. `tealdeer` custom pages and `cheat/cheat` cheatpaths
  exist and are credible alternatives, but solve the constrained-format /
  batteries-included cases — not the zero-dependency free-form-markdown case. See
  README § "Why not just use tldr / cheat.sh / cheat?"
