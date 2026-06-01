# HANDOFF — instructions for downstream GSD agents

A `gsd-phase-researcher` (or `gsd-discuss-phase` → `gsd-plan-phase` chain) picks up one phase and works it to completion. This doc is the agent's startup contract.

## You are picking up

Exactly one phase folder under `.planning/`. Identified by:

- Phase ID: `P00`–`P08` (chapter 09 was authored but extracted to `extract/token-economy` branch)
- Folder: `.planning/<NN>-<slug>/`
- Brief: `.planning/<NN>-<slug>/RESEARCH.md`

If you weren't told which phase, look at `.planning/ROADMAP.md` for the index and ASK the human which one to pick up.

## Before you start

1. Read `.planning/PROJECT.md` (project + milestone context, ≤ 5 minutes)
2. Read `.planning/ROADMAP.md` (where your phase fits)
3. Read `.planning/SEARCH-PLAYBOOK.md` (shared search recipes — don't restate per-phase)
4. Read your phase's `RESEARCH.md` (the brief — your full assignment)
5. Read the existing chapter files (`<NN>-<slug>/README.md` + sub-topic files) so you know what you're enriching, not regenerating

## What you produce

Per the phase's RESEARCH.md §5 ("Output requirements"). Generally:

- Edits to existing chapter files (README, sub-topic files) adding source-grounded content
- 0–3 new files inside the chapter folder (alternatives, migration recipe, etc. — phase-specific)
- A `sources.md` file at the chapter root (bibliography rollup)
- A `RESEARCH-LOG.md` inside `.planning/<NN>-<slug>/` (append-only log of sources you cited as you went, per SEARCH-PLAYBOOK §"Per-phase research log format")

## Tool routing (always)

Per `~/.claude/docs/mcp-routing.md` and `SEARCH-PLAYBOOK.md` §"Tool routing for research":

- **WebFetch first** when URL is known
- **WebSearch** for discovery
- **Dash docs MCP** for installed docsets (faster than context7 for common tools)
- **context7 MCP** for library docs not in Dash
- **Firecrawl** when WebFetch chokes on JS
- **Playwright / chrome-devtools** only when interaction is needed (almost never for research)

For Linear/GitHub data: `linearis` CLI > Linear MCP. `gh` CLI > GitHub MCP.

## Commit + branch discipline

Per the playbook's own `06-session-discipline/` chapter, which is the dogfooded standard:

- **Branch:** `<phase-id>/<short-description>` — e.g., `P03/agent-portability-bridge`. If the project has Linear tickets per phase, use the Linear ID instead.
- **Commit per meaningful change.** Don't batch the whole phase into one commit.
- **Commit message format:** title (≤ 70 chars, references the research question ID where applicable, e.g., "P03/Q03.8: cite Anthropic context-degradation evidence"), blank line, body explaining what and why.
- **Co-Authored-By trailer** on every commit you make (you are not the human author):
  ```
  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
  ```
- **Push after every commit.** The human may be reviewing in parallel on another machine.
- **One PR per phase** unless the phase is huge — open early as a draft so the human can follow along.
- **NEVER commit to `main` directly.** No exceptions.
- **NEVER force-push** unless explicitly asked.

## Citation discipline (the bar)

Every external claim you add to the chapter cites a source per the SEARCH-PLAYBOOK weighting:

- Primary docs > vendor blog > academic > practitioner > community
- Inline marker: `[¹]` `[²]` etc.
- Footnote at bottom of file: `[1]: <URL or full citation> — accessed YYYY-MM-DD`
- All citations also roll into the chapter's `sources.md`
- If you can't find a citation, write the claim with an honest hedge ("we couldn't find external validation; this is the author's experience") — do NOT fabricate.

## Voice + style (must match the playbook)

- Opinionated, not hedged. The playbook picks a side.
- Terse. No marketing copy. No "in conclusion" or "let's dive into."
- Tables for comparisons. Numbered lists for procedures.
- Code blocks must be copy-paste-runnable on a fresh machine (or labeled `pseudo-code` clearly).
- Caps: ≤ 250 lines per sub-topic file. Chapter README stays ≤ 100 lines. **Documented overage exceptions** (load-bearing content judged worth the breach at merge time; do not regress, do not extend):
  - `01-linear-as-load-bearing-pm/io-rules.md` ≤ 310 — 2026 API refresh + AI-features section
  - `01-linear-as-load-bearing-pm/ticket-standard.md` ≤ 270 — 7-section schema inlined + failure case
  - `03-claude-code-as-operator/memory-architecture.md` ≤ 310 — field-tested gotchas + vendor evidence
  - `01-linear-as-load-bearing-pm/README.md` ≤ 120 — showcase chapter
  - `05-secrets-and-secure-defaults/README.md` ≤ 120 — milestone DoD subsections live there
  - Other files exceeding the cap = surface per stop conditions, don't silently breach.
- Cross-references between chapters use the form: `[Chapter 03 — Memory architecture](../03-claude-code-as-operator/memory-architecture.md)`.
- No emojis. No screenshots (markdown only; asciinema/SVG OK if absolutely needed).

## Stop conditions (escalate to human)

The per-phase RESEARCH.md §7 lists phase-specific stop conditions. Always-applicable ones:

- A claim you can't cite + can't honestly hedge — surface, don't fabricate.
- A primary vendor doc disagrees with current chapter content in a way that would require restructuring a sub-topic file — surface the diff, propose options, wait for human call.
- Chapter would exceed file caps (250 lines/sub-topic) after your additions — surface, propose split.
- You discover a different chapter has a related claim that's wrong / stale — surface the cross-chapter dependency; don't silently edit another chapter outside your phase.
- A new sub-topic file would exceed 3 net new files for the phase — surface, get permission.

## What "done" looks like

The phase's RESEARCH.md §5 + the ROADMAP.md "Definition of done (per phase)" both met. Specifically:

- [ ] All RESEARCH.md research questions answered with citation OR honest hedge
- [ ] ≥ 5 external sources cited (most phases should hit 10–20)
- [ ] Alternatives / comparison content added
- [ ] "Field tests beyond the author" addressed (or honest "no external validation yet")
- [ ] "What we'd change in 2026" reflected where relevant
- [ ] Version matrix added if tools have releases
- [ ] sources.md rolled up
- [ ] RESEARCH-LOG.md complete
- [ ] PR opened against `main`, links to the phase brief + the chapter changes

## Parallel safety

Phases are designed to be independent. Two agents on two phases at the same time = fine, no merge conflicts expected. The only cross-phase risk is voice / terminology drift — if you coin a new term or rename a concept, surface to the human so a final pass can align.

Do NOT edit files outside your phase's chapter folder without first surfacing.

## Quick start command

If the human invokes you via the standard GSD machinery, you'll be told the phase ID. Otherwise, accept it as the first message, then:

```
1. Read .planning/PROJECT.md
2. Read .planning/ROADMAP.md
3. Read .planning/SEARCH-PLAYBOOK.md
4. Read .planning/<NN-slug>/RESEARCH.md
5. Read <NN-slug>/*.md (existing chapter content)
6. Create branch <phase>/<short-desc>
7. Begin Q-by-Q research per the brief, committing per question
8. Open draft PR at first meaningful commit
9. Iterate until §5 outputs ship
10. Mark PR ready for review; surface for human merge
```
