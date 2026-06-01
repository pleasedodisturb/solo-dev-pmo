# PROJECT — solo-dev-pmo

## What it is

A published playbook (this repo) describing the PMO function — coordination, conventions, rituals, audit trail — sized for a solo developer working with N AI agents in the loop. Live at https://github.com/pleasedodisturb/solo-dev-pmo.

Nine chapters (00–08) on `main`, each a working README + 3–6 sub-topic files extracted from one solo developer's 12-month working setup. Chapter 09 (Token economy) was authored in this milestone but extracted to `extract/token-economy` branch for later move to a dedicated repo. Milestone M1 (depth + breadth via grounded research) is **shipped**: all chapter PRs merged 2026-05-31 → 2026-06-01.

## Audience

- Solo founders / solo engineers who use AI agents heavily, not occasionally
- ADHD-aware practitioners who want affordances, not discipline
- Readers who already use a PM tool, a code host, a terminal, and have a calendar/secrets problem

Explicitly NOT for: enterprise teams, AI-skeptics, people looking for a links list.

## What's different about this playbook

(From the README's "unique axes" section — repeated here so downstream agents don't re-derive.)

1. ADHD-aware design as a stack-design constraint (not "use these ADHD apps")
2. 4-layer memory architecture with boundary rules
3. Linear as load-bearing PM — exponential estimates, 1-week cycles, snooze-as-hibernation, Triage-as-inbox
4. Agent-autonomous-ready ticket standard (7-section + execution metadata)
5. Cross-tool integration as one coherent system

## Adjacent / prior art (do not duplicate)

- `garrytan/gstack` — Claude Code skills factory (we cover the PM/filesystem/ritual layer it assumes)
- `yayashuxue/solo-founder-playbook` — business strategy (different layer)
- `hesreallyhim/awesome-claude-code` — directory (we're a recipe book)
- `XargsUK/awesome-adhd` — general ADHD content (we're stack-design)
- `nopara73/ForeverAloneProgramming` — methodology-flavored
- `fawazahmed0/the-solo-developers-manifesto` — manifesto-style
- Leantime — ADHD-friendly PM tool (we're tool-integration recipes)

Full source list: [`credits.md`](../credits.md).

## Completed milestone (M1)

**M1 — Depth via grounded research. SHIPPED 2026-06-01.** Every chapter currently leans heavily on the author's primary source material (global agent instructions + auto-memory + audit log + conventions). This milestone re-grounds each chapter against external primary sources (vendor docs, peer-reviewed work where relevant, adjacent repos, and current 2025–2026 community practice) and adds:

- An honest "alternatives" table per chapter (what we picked, what we rejected, why)
- A "field tests beyond the author" subsection (other practitioners' confirmations / counter-evidence)
- A "what we'd change if we were starting over today" subsection
- A "version matrix" where tools have releases (Linear shipped X in 2026-Q1, rbw at version N, Claude Code at version Y, etc.)

The deliverable for each phase is **enrichment-grade content** that survives an external reviewer asking "where's the evidence?"

## Constraints

- **No vendor capture.** Even for Linear (the showcase chapter), the patterns must read as transferable to Plane/Height/Shortcut where possible. Vendor-specific mechanics get called out explicitly.
- **No paid tools as required deps.** Optional yes; required no. `rbw`, `ntfy`, `launchd`, `gh`, Claude Code — these are the baseline.
- **No screenshots.** Markdown only. (Asciinema / SVG is OK if absolutely needed, but the bar is high.)
- **No author-only anecdotes that can't be field-tested by a reader.** Every claim needs to be reproducible by a fresh adopter.
- **ADHD-aware framing is mandatory, not optional.** Every chapter must explicitly answer "what does this chapter remove from working memory?"
- **One-page-readable.** Each sub-topic file caps at ~250 lines so it stays one-shot scannable.

## Out of scope for M1

- Business strategy (out-of-band; covered by solo-founder-playbook)
- Tooling marketplace (out-of-band; covered by awesome-claude-code)
- Quantitative productivity claims with no source (banned outright)
- Marketing copy / launch posts (separate milestone)

## Project-wide success criteria

A reader who has never met the author can fork this repo, follow it end-to-end, and stand up the entire system in 2–3 weekends with no need to DM the author for clarification.
