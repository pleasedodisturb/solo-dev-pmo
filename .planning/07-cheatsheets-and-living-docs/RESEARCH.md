# RESEARCH — Phase P07: Cheatsheets and living docs

> **Stream goal:** validate the `cheat <topic>` system against existing solo-dev knowledge-base patterns (tldr, cheat.sh, eg, dotfiles cheatsheets), surface what beats the author's pattern, and ship a portable starter `cheats/` repo skeleton.

## 0. Scope

In:
- `07-cheatsheets-and-living-docs/README.md` + 1 sub-topic file (`cheatsheet-discipline.md`)

Out:
- Memory architecture (chapter 03; cheatsheets are commands, memory is decisions)
- Wrap-and-resume audits (chapter 06; cross-link only)

## 1. What exists today

213 lines across 2 files — the shortest chapter (by design). Existing depth:

- `cheat` shell function pattern (file-based, glow renderer)
- Topic list (git, zsh, tools, claude-code, linear, tmux, gsd, etc.)
- Discipline rule: capture cheatsheet-worthy learnings same session

## 2. Honest gaps

- **No comparison to existing cheatsheet tools** — `tldr-pages`, `cheat.sh` (curl cheat.sh/...), `eg`, `bro`, `cheat` (chrisallenlane/cheat), `manly`. The author's pattern is novel-ish but doesn't claim or defend authorship.
- **No discussion of structure inside a cheatsheet file** — alphabetical? task-oriented? "Most common first"? Worth a recommended shape.
- **No template / starter** — readers can't copy a recipe. A `cheats-starter/` example dir would help.
- **No version control / sync story** — Syncthing? Git? GitHub repo? The author has it in `~/Projects/terminal-craft/docs/` (per global CLAUDE.md), but that's not generalized.
- **Discoverability beyond `cheat <topic>`** — `grep` across files works, but readers should know about `rg`-based search, fzf-pickers.
- **Living docs broader question** — the chapter is titled "Cheatsheets and living docs" but mostly covers cheatsheets. The "living docs" half is thin. What other living-doc patterns belong (conventions files, ADRs, README maintenance)?
- **Maintenance discipline measurement** — what's the leading indicator of cheatsheet rot? (Date-stamp at top? Commit-mtime check? Practitioner data on this would be good.)
- **AI-assisted cheatsheets** — does Claude Code consult the cheatsheets when relevant? Should it? Worth a sub-section.

## 3. Research questions

### Prior art on cheatsheet systems

- **Q07.1** `tldr-pages` — current status, languages, community size, integration with `tldr` CLI.
- **Q07.2** `cheat.sh` — Igor Chubin's project, current status, curl-friendly API.
- **Q07.3** `chrisallenlane/cheat` — the older Python tool, still maintained?
- **Q07.4** `eg` and `bro` — alternative example-based cheatsheets.
- **Q07.5** `tealdeer` — Rust reimplementation of tldr client. Worth recommending over `tldr`?
- **Q07.6** `manly` and `man` itself — for completeness; when does the playbook prefer man over cheat?

### Personal-knowledge-management overlap

- **Q07.7** Cheatsheets vs PKM (Obsidian, Logseq, Notion, Roam, Anytype, Memos). Where does the boundary sit?
- **Q07.8** Zettelkasten purists — would they object to cheatsheets-as-flat-files? (Probably yes; document the boundary.)
- **Q07.9** Dendron / Foam / Org-roam — markdown-PKM systems. Do any expose a "cheat" affordance well?

### Discoverability + ergonomics

- **Q07.10** `fzf` + `glow` + `cheat` integration recipes. Find 2–3 published patterns.
- **Q07.11** `ripgrep` across cheatsheets — the right search recipe.
- **Q07.12** Shell completion for `cheat <topic>` — bash/zsh/fish examples.
- **Q07.13** Editor integration — Vim/Neovim/Emacs/VS Code shortcuts that pull up cheatsheets in-buffer.

### Structure inside a cheatsheet

- **Q07.14** Shape of a good cheatsheet file. Section order (Most common → Less common → Gotchas)? Code block conventions? Find 5+ exemplary cheatsheets.
- **Q07.15** Code-block language tags — markdown rendering, syntax highlighting in `glow` / `bat` / `mdcat`.
- **Q07.16** Cross-references between cheatsheets — `[[git-cheatsheet]]` style? Forward links? Hashtags?

### Living-doc maintenance

- **Q07.17** Date-stamps at top of living-doc files — convention, value, automation (pre-commit hook updates `last-edited:`?).
- **Q07.18** "Last validated YYYY-MM-DD" — pattern for expiring stale docs.
- **Q07.19** Doc-rot indicators — broken links, deprecated commands, version-pinned recipes. What can a script detect?
- **Q07.20** Linkrot — when a cheatsheet references a vendor doc URL, what's the right resilience pattern?

### AI-agent interaction with cheatsheets

- **Q07.21** Does it make sense for Claude Code (or similar) to auto-consult cheatsheets when relevant? What's the integration pattern? (MCP server backed by cheats dir? Skill that greps + suggests?)
- **Q07.22** Counter-argument: do agent capabilities make cheatsheets obsolete? (No — but document why.)

### Living-docs broader

- **Q07.23** Beyond cheatsheets, what other living-doc categories should the chapter name? Candidates: conventions files (already chapter 02/06), runbooks, on-call docs, postmortem index, FAQ files.
- **Q07.24** Runbook patterns — solo dev with no team but still infrastructure (deployments, restarts, monitoring playbooks).

## 4. Per-question source plan

| Q | Source class | Specific starting points |
|---|---|---|
| Q07.1 | Primary | tldr.sh. github.com/tldr-pages/tldr. |
| Q07.2 | Primary | cheat.sh. github.com/chubin/cheat.sh. |
| Q07.3 | Primary | github.com/cheat/cheat. |
| Q07.4 | Primary | github.com/srsudar/eg. github.com/hubert/bro (if alive). |
| Q07.5 | Primary | github.com/tealdeer-rs/tealdeer. |
| Q07.6 | Primary | github.com/carloscuesta/manly. |
| Q07.7–Q07.9 | Vendor docs | obsidian.md, logseq.com, dendron.so, foambubble.github.io, org-roam.github.io. |
| Q07.10–Q07.13 | Practitioner | github.com/junegunn/fzf wiki. github.com/charmbracelet/glow. zsh-users/fzf-tab. Reddit r/vim r/neovim for editor recipes. |
| Q07.14–Q07.16 | Practitioner | Survey 5+ popular cheatsheet repos: github.com/devhints, github.com/awesome-cheatsheets/cheatsheets, github.com/cheat/cheatsheets. |
| Q07.17–Q07.20 | Practitioner | github.com pre-commit hooks for "last-edited". 11ty / Hugo plugins for stale-content detection. |
| Q07.21–Q07.22 | Practitioner | Search for "claude code cheatsheet skill" or "MCP cheatsheet server". Reddit r/ClaudeAI threads. |
| Q07.23–Q07.24 | Primary + practitioner | Google SRE Book runbook chapter. PagerDuty incident-response docs. github.com search `filename:RUNBOOK.md`. |

## 5. Output requirements

The agent updates files in `/Users/pleasedodisturb/Projects/playbooks/solo-dev-pmo/07-cheatsheets-and-living-docs/`:

1. **README.md** gains:
   - Comparison table — `cheat` shell function vs `tldr` vs `cheat.sh` vs `chrisallenlane/cheat`. Where the playbook's pattern wins (custom, personal), where the others win (universal recipes).
   - Honest "you could just use tldr" hedge — and when you shouldn't
   - One-paragraph "and the broader living-docs picture" callout that links to the new file below
2. **`cheatsheet-discipline.md`** gains:
   - Date-stamp / last-validated convention
   - Doc-rot detection recipe (pre-commit hook example, `link-check` integration)
   - AI-agent interaction subsection (when to point Claude at cheats; when not)
3. **New file:** `07-cheatsheets-and-living-docs/cheats-starter.md` — a complete copy-paste starter:
   - Directory structure (`cheats/docs/{git,zsh,tools,claude-code,linear,tmux}-cheatsheet.md`)
   - Sample contents for 2–3 cheats (10–20 lines each, showing the recommended shape)
   - The shell function (zsh + bash + fish variants)
   - fzf-picker integration
   - rg-search recipe
   - Pre-commit hook for date-stamping
4. **New file:** `07-cheatsheets-and-living-docs/living-docs.md` — the broader category:
   - Cheatsheets (this chapter)
   - Conventions (cross-link chapter 02 + 06)
   - Audits (cross-link chapter 06)
   - Runbooks (new — solo-dev runbook pattern)
   - FAQ files (new)
5. **New file:** `07-cheatsheets-and-living-docs/sources.md` — bibliography

Constraints:
- DO NOT make the chapter a tldr / cheat.sh review — that's adjacent prior art, link out
- DO NOT recommend a paid PKM (Notion, Roam) as primary; the cheat function is OSS-friendly
- The cheats-starter should work on a fresh machine in < 5 minutes
- Keep total chapter under 800 lines — this is the playbook's deliberately-short chapter

## 6. Per-phase search ideas

### Web

- `site:tldr.sh`
- `site:cheat.sh`
- `site:github.com/cheat/cheat`
- `site:github.com/tealdeer-rs/tealdeer`
- `"personal cheatsheet" dotfiles`
- `"cheat" shell function dotfiles README`
- `"living documentation" maintenance rot`
- `markdown last-validated pre-commit hook`
- `runbook solo dev pattern`
- `site:sre.google runbook`

### Social

- HN: `https://hn.algolia.com/?q=tldr+pages`
- HN: `https://hn.algolia.com/?q=cheat.sh`
- HN: `https://hn.algolia.com/?q=personal+knowledge+management+cli`
- HN: `https://hn.algolia.com/?q=runbook+solo`
- Lobsters: `https://lobste.rs/search?q=tldr`
- Lobsters: `https://lobste.rs/search?q=cheatsheet`
- Reddit: `site:reddit.com/r/commandline tldr cheat.sh`
- Reddit: `site:reddit.com/r/ObsidianMD personal cheatsheet`
- Reddit: `site:reddit.com/r/devops runbook template`
- X: `(tldr-pages OR cheat.sh) min_faves:30`

### GitHub

- `topic:cheatsheet` (sort stars)
- `topic:cheat-sheet`
- `topic:tldr`
- `topic:dotfiles cheat`
- `tldr-pages/tldr` — primary
- `chubin/cheat.sh` — primary
- `cheat/cheat` — primary
- `awesome-cheatsheets/cheatsheets`
- `LeCoupa/awesome-cheatsheets`
- `tealdeer-rs/tealdeer`
- Code search: `filename:.zshrc "cheat()"`
- Code search: `path:docs filename:*-cheatsheet.md`

### Specific

- devhints.io — adam cheatsheets site, full repo on github
- The Pragmatic Programmer's "Plain Text" chapter for living-docs argument
- Google SRE Book → Chapter on runbooks

## 7. Stop conditions

Stop and surface if:

- `tldr-pages` or `cheat.sh` adds personal-cheatsheet support that obsoletes the custom function pattern.
- A widely-adopted Claude Code MCP for cheatsheet auto-consultation appears — restructure the AI-interaction section.
- The cheats-starter ends up too coupled to one shell — split into per-shell starters or simplify.

## 8. Estimated effort

S phase. 3–5 hours research + 3–5 hours writing. Plus 1–2 hours to actually build & test the cheats-starter on a fresh shell. Single agent; this chapter is intentionally compact.
