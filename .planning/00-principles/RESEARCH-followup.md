# RESEARCH (P00 follow-up) — Principles breadth pass

> **Stream goal:** close the breadth gap left by the first P00 pass (PR #3). The original brief asked for enrichment across all 4 axes; the first session shipped only the ADHD-evidence pass for `adhd-aware-design.md`. This brief covers the other 3 axes + the alternatives / rules-out subsections that were skipped.

**Read alongside:** the original `.planning/00-principles/RESEARCH.md` defines the source plan, voice, citation discipline, and output contract. This file is a **delta** — it doesn't restate things; it lists what's still missing.

## 0. Scope

In:
- `00-principles/four-layer-memory.md` — full enrichment per original brief Q00.5–Q00.7
- `00-principles/single-source-of-truth.md` — full enrichment per Q00.8–Q00.9
- `00-principles/calendar-neutrality.md` — full enrichment per Q00.10–Q00.13
- `00-principles/adhd-aware-design.md` — **only** the "Alternatives" + "What this rules out" subsections (the citations layer already shipped)
- `00-principles/evidence-and-citations.md` — leave as-is (don't disturb the A/B/C tier system already shipped)

Out:
- The ADHD-evidence layer (already shipped in PR #3)
- New 5th principle (chapter's 4-axis structure is deliberate)
- Anything outside `00-principles/`

## 1. What's already done (PR #3 by the prior session)

- `adhd-aware-design.md` — evidence-graded with A/B/C tiers (Barkley, Martinussen, Alderson, Zheng, Nasri, Altgassen, Sonuga-Barke, Beaton); RSD/streak claim honestly hedged
- New `evidence-and-citations.md` with full tier-by-tier reference list
- `README.md` gained a one-liner about the evidence doc
- `credits.md` — Peer-reviewed sources (ADHD research) section
- `extraction-sheet.md` — research pass recorded

## 2. What still needs to ship

Per the original brief's §5 "Output requirements":

### For each of `four-layer-memory.md` / `single-source-of-truth.md` / `calendar-neutrality.md`:

1. A `## Sources` section at the bottom with numbered footnote citations + inline `[¹]` markers
2. A `## What this rules out` subsection — concrete decisions a reader would make differently
3. A `## Alternatives` subsection — competing frameworks with one-line summaries + honest "why we picked this"

### For `adhd-aware-design.md`:

1. A `## What this rules out` subsection (it has Sources via evidence-and-citations; doesn't need its own)
2. An `## Alternatives` subsection — competing ADHD-design frameworks (low-stim productivity systems, RSD-aware design schools, "executive-function scaffolding" framings)

### For `00-principles/sources.md` (new):

A rolled-up bibliography deduplicated across all 4 axes. Don't duplicate `evidence-and-citations.md`; this is the broader bibliography that points to it.

## 3. Research questions (delta from original brief)

These map 1:1 to the original Q-numbering for traceability:

### Four-layer memory (deferred from first pass)

- **Q00.5** How do other agent-memory architectures partition memory? Build a comparison table covering: gstack GBrain, mem0, Letta (formerly MemGPT), LangGraph state, Cursor `.cursorrules`, Aider `CONVENTIONS.md`, Cline memory, OpenAI memory, Claude's first-party auto-memory (now shipped — cross-flag with chapter 03).
- **Q00.6** Where do other practitioners publish memory-layer caps (≤ 200 lines, ≤ 150 lines)? Find at least one external practitioner cap + cite. Likely candidates: Simon Willison, Andrej Karpathy, Steve Yegge, Anthropic engineering blog.
- **Q00.7** Patterns from human-organization memory (Andy Matuschak's evergreen notes, Notion "single workspace," Wikipedia MoS) — what translates to agent memory, what doesn't?

### Single source of truth (deferred)

- **Q00.8** SSOT origin in software engineering — primary cites (Wikipedia article's primary refs, Evans DDD, Nygard ADR post).
- **Q00.9** Counter-argument: distributed-systems redundancy (Kleppmann ch.5, Vogels "Eventually consistent"). Reconcile: SSOT is about *authoring*, redundancy is about *replication*.

### Calendar neutrality (deferred)

- **Q00.10** CalDAV server options 2026 (Radicale, Nextcloud, Fastmail, Proton). Comparison table.
- **Q00.11** GrapheneOS official Calendar/Push guidance 2026 — sandboxed Play vs degoogled, ntfy as recommended.
- **Q00.12** Degoogle/privacy community recommendations 2026 (PrivacyGuides, r/degoogle, restoreprivacy).
- **Q00.13** Plaintext-schedule patterns specifically (org-mode agenda, taskwarrior, .ics-from-markdown, khal).

### Cross-axis output (Alternatives + What-this-rules-out)

Apply to all 4 axes; no new research questions, just synthesis from what the original Source Plan in `.planning/00-principles/RESEARCH.md` §4 already mapped.

## 4. Per-question source plan

**Use the original `.planning/00-principles/RESEARCH.md` §4 verbatim** — it already maps Q00.5–Q00.13 to specific starting points. Don't re-derive. If a source 403s or is gone, document and fall back per `.planning/SEARCH-PLAYBOOK.md`.

For the new Alternatives subsections, use **adjacent-repo research recipes** from `.planning/SEARCH-PLAYBOOK.md` §"GitHub topic searches" + §"Specific repos to skim".

## 5. Output requirements (delta)

The agent updates files in `/Users/pleasedodisturb/Projects/playbooks/solo-dev-pmo/00-principles/`:

1. **`four-layer-memory.md`** — add Sources + What-this-rules-out + Alternatives sections; cite Q00.5–7 evidence
2. **`single-source-of-truth.md`** — same shape; cite Q00.8–9 (Nygard, Evans, Kleppmann, Vogels)
3. **`calendar-neutrality.md`** — same shape; cite Q00.10–13 (Radicale, Nextcloud, GrapheneOS, PrivacyGuides, org-mode/khal)
4. **`adhd-aware-design.md`** — add ONLY Alternatives + What-this-rules-out (Sources via `evidence-and-citations.md` already done)
5. **NEW `00-principles/sources.md`** — rolled-up bibliography, deduplicated, links to `evidence-and-citations.md` for the ADHD-specific tiers
6. **`README.md`** — stays a one-screen table + CTA (do NOT bloat); optionally add a one-liner pointing readers at sources.md
7. **DO NOT modify** `evidence-and-citations.md` (the A/B/C tier work is locked)
8. **DO NOT modify** `credits.md` or `extraction-sheet.md` unless adding new entries (don't move existing ones)

Voice: same as rest of playbook — terse, opinionated, no marketing copy.

Caps: ≤ 250 lines per sub-topic file. After this pass, sub-topic file sizes should land around 130–200 lines each (currently 57–113).

## 6. Per-phase search ideas

Use `.planning/SEARCH-PLAYBOOK.md` + the original `.planning/00-principles/RESEARCH.md` §6. Specifically high-value for this pass:

- `letta-ai/letta`, `mem0ai/mem0`, `langchain-ai/langgraph` — for Q00.5 comparison table
- `andymatuschak/notes` (Evergreen Notes) — for Q00.7
- `Nick-Pochet/awesome-degoogle`, `PrivacyGuides/privacyguides.org` — for Q00.10–12
- `khalcalendar/khal`, `pimutils/vdirsyncer` — for Q00.13

## 7. Stop conditions

Same as original brief, plus:

- If the cross-flagged "Claude native auto-memory" (P03 surfaced) materially changes the 4-layer model's recommendation, surface for the author. Do NOT silently downgrade the 4-layer pattern; the chapter takes a position.
- If a memory-architecture comparison (Q00.5) reveals that one of the competitors structurally beats the 4-layer model for solo-dev use, surface honestly — don't paper over.
- If `evidence-and-citations.md` would need edits to stay consistent with new sources, surface rather than edit (the A/B/C tier work is from a different research pass and is locked).

## 8. Estimated effort

S phase. 2–4 hrs research + 2–3 hrs writing. Smaller than the original P00 brief because:
- ADHD-evidence pass already done (the heaviest research lift)
- 3 untouched axes are smaller scope (no peer-reviewed bar — software-engineering primary docs suffice)
- Output requirements are mostly adding 2–3 subsections per file

Single agent, no need for parallel sub-agents.
