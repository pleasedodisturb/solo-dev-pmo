# RESEARCH — Phase P00: Principles

> **Stream goal:** ground the four design axes (ADHD-aware design, 4-layer memory, single source of truth, calendar-neutrality) in external evidence so they read as derived, not asserted. Audience = a skeptical reader who's never met the author.

## 0. Scope

In:
- `00-principles/README.md` + 4 sub-topic files (`adhd-aware-design.md`, `four-layer-memory.md`, `single-source-of-truth.md`, `calendar-neutrality.md`)
- Light cross-references to other chapters (only where the principle is operationalized — don't restate)

Out:
- Specific tool recipes (those live in chapters 01–07)
- The credits bibliography (curated in `credits.md` already)

## 1. What exists today

296 total lines across 5 files. README is 13 lines (a table + a single CTA sentence). Sub-topics are each 50–90 lines, each a single-page essay structure:

- **ADHD-aware design** (existing depth: pattern principles, no citations to ADHD literature)
- **Four-layer memory** (existing depth: clear layer table + cross-refs; no citation to memory-architecture prior art in agent systems)
- **Single source of truth** (existing depth: principle stated; no economic or cognitive-load citation)
- **Calendar-neutrality** (existing depth: principle + the rough recipe; no comparison to alternatives like Fastmail Calendar, Proton, CalDAV)

## 2. Honest gaps

- **Zero academic citations** for the ADHD claims. Stating "ADHD-aware design" without a single peer-reviewed source is the weakest spot in the whole playbook.
- **Memory architecture is asserted as 4-layer but never compared** to competing memory frameworks (gstack's GBrain, mem0, MemGPT, LangGraph state, Cognition's Devin sessions).
- **Single source of truth doesn't engage with the obvious counter-argument** (redundancy as resilience).
- **Calendar-neutrality doesn't explain why specifically NOT Apple/Google** with current evidence (privacy stance, lock-in stories, the GrapheneOS angle).
- **No "what does this rule out" subsection per principle** — i.e., decisions a reader would make differently if they accept the principle.

## 3. Research questions

Numbered so the downstream agent can answer them one by one and reference the IDs in commits.

### ADHD-aware design

- **Q00.1** Which peer-reviewed sources support "externalizing memory > internal recall" specifically for software developers with ADHD? (Goal: 2–3 strong citations.)
- **Q00.2** What does the academic + practitioner literature say about "affordances vs. discipline" framing? Donald Norman's *The Design of Everyday Things* is the obvious primary; are there ADHD-specific derivatives?
- **Q00.3** Are there CHI / CSCW / TOCHI papers on interruption recovery in programmers, and what's the quoted recovery cost (was it 23 minutes? 10? both?). Need primary source.
- **Q00.4** Counter-evidence: are there ADHD adults / practitioners who succeed with low-structure approaches? Worth acknowledging if so.

### Four-layer memory

- **Q00.5** How do other agent-memory architectures partition memory? Specifically: gstack/GBrain, mem0, MemGPT, LangGraph checkpointing, OpenAI's "memory" feature, Claude's `Memory` tool. Build a comparison table.
- **Q00.6** Is there a published rationale for the boundary "always-loaded ≤ 200 lines"? Or is this an empirically-derived heuristic? Find anyone else publishing similar caps.
- **Q00.7** What patterns from human-organization memory (Wikipedia, Notion's "single workspace" critique, Andy Matuschak's notes) translate or fail to translate to agent memory?

### Single source of truth

- **Q00.8** Where does the "single source of truth" framing originate in software engineering? (DDD? Domain Model? Architecture-decision records?) — get primary cite.
- **Q00.9** Counter-argument: distributed system literature treats redundancy as resilience. How does the playbook reconcile? (Likely answer: SSOT is about *authoring*; redundancy is about *replication*. Need a clean way to state this.)

### Calendar-neutrality

- **Q00.10** What's the current 2025–2026 state of CalDAV server options (Radicale, Nextcloud, Fastmail, Proton)? Quick comparison table.
- **Q00.11** Has GrapheneOS published official guidance on Calendar/Push? (Sandboxed Google Play vs. degoogled, ntfy as recommended replacement, etc.)
- **Q00.12** What do degoogle/privacy communities (r/degoogle, Privacy Guides, restoreprivacy.com) recommend in 2026 for calendar?
- **Q00.13** Are there practitioner posts on "plaintext schedule" patterns specifically? (org-mode agenda, taskwarrior, .ics-from-markdown scripts)

## 4. Per-question source plan

| Q | Source class (per SEARCH-PLAYBOOK weighting) | Specific starting points |
|---|---|---|
| Q00.1 | Academic + practitioner | Google Scholar: `"adult ADHD" "software engineer"`, `"externalizing memory" knowledge worker`. Cross-check with Leantime's blog (they cite primary sources). |
| Q00.2 | Primary (book) + practitioner | Norman, *Design of Everyday Things* (ch. on affordances). Jakob Nielsen for HCI extensions. ADHD blogs: ADDitude Magazine, CHADD.org. |
| Q00.3 | Academic | Gloria Mark, *Attention Span*, the canonical "23 minutes" cite. Also Parnin & Rugaber on interruption in programming (ICSE/FSE). |
| Q00.4 | Practitioner + community | r/ADHD_Programmers threads; Mastodon #ADHDDeveloper accounts; ADHD subreddit megathreads. |
| Q00.5 | Adjacent repos | gstack README + GBrain code; mem0 docs (mem0.ai); MemGPT paper (arXiv 2310.08560); LangGraph docs; Anthropic blog on Claude Memory. |
| Q00.6 | Practitioner | Author's CLAUDE.md global file mentions the 200-line cap — find external posts that also publish caps. Likely candidates: Simon Willison's blog, Andrej Karpathy's tweets, Steve Yegge's blog. |
| Q00.7 | Practitioner + primary | Andy Matuschak's notes on Evergreen Notes; Notion's blog on workspace organization; Wikipedia's manual of style on SSOT. |
| Q00.8 | Primary | Wikipedia "Single source of truth" article → primary citations. Evans, *Domain-Driven Design*. Michael Nygard's ADR post (`cognitect.com/blog/2011/11/15/documenting-architecture-decisions`). |
| Q00.9 | Primary + practitioner | Distributed systems texts: Kleppmann *Designing Data-Intensive Applications* ch. 5. Counter-essay: "Eventually consistent" by Vogels. |
| Q00.10 | Vendor docs + practitioner | Radicale docs, Nextcloud Calendar docs, Fastmail help, Proton Calendar product page. Comparison post: PrivacyGuides.org. |
| Q00.11 | Vendor docs | grapheneos.org documentation; GrapheneOS forum posts. |
| Q00.12 | Practitioner + community | privacyguides.org calendar recommendations 2026; r/degoogle wiki + recent threads. |
| Q00.13 | Practitioner | org-mode agenda docs; taskwarrior.org docs; awesome-* repos for plaintext PM. |

Each question gets at least one ★★★+ source. If a question can't be answered with a primary or academic source, the answer goes in the chapter as a stated heuristic with an honest "we couldn't find external validation for this" footnote.

## 5. Output requirements (what the downstream agent ships)

The agent updates files in `/Users/pleasedodisturb/Projects/playbooks/solo-dev-pmo/00-principles/`:

1. **Each sub-topic file** grows a `## Sources` section at the bottom with numbered footnote-style citations. Inline `[¹]` markers in the body.
2. **Each sub-topic file** gains a `## What this rules out` subsection — concrete decisions a reader would make differently after accepting the principle.
3. **Each sub-topic file** gains a `## Alternatives` subsection — competing frameworks with one-line summaries and an honest "why we picked this one."
4. **README.md** stays a one-screen table + CTA. The author's voice ("If you only read one, read ADHD-aware") is preserved. Don't bloat the README.
5. **New file:** `00-principles/sources.md` — full bibliography rolled up from all sub-topic citations, deduplicated.
6. **No new sub-topic files.** The four axes are deliberate; adding a 5th principle requires a roadmap-level decision.

Voice: matches the rest of the playbook — opinionated, terse, no marketing copy, no "in conclusion."

Constraints:
- Caps still apply (~250 lines per sub-topic file)
- All claims about ADHD must be cited or honestly hedged. NEVER state ADHD claims as obvious-truth.
- Cite the 23-minute interruption-recovery number ONLY against Gloria Mark's primary work; if you can't find it, don't use the number.

## 6. Per-phase search ideas (beyond SEARCH-PLAYBOOK)

### Web

- `site:scholar.google.com "ADHD" "software developer" 2020..2026`
- `site:additudemag.com "developer" OR "programmer"`
- `site:chadd.org adult workplace`
- `site:matuschak.org single source` (Andy Matuschak's evergreen notes)
- `"affordances vs discipline" site:medium.com OR site:substack.com`
- `"agent memory architecture" site:anthropic.com OR site:openai.com OR site:langchain.com`

### Social

- HN: `https://hn.algolia.com/?q=ADHD+programming` (skim comments ≥ 30 points, last 24 months)
- HN: `https://hn.algolia.com/?q=agent+memory+architecture`
- Lobsters: `https://lobste.rs/search?q=ADHD&what=stories`
- Reddit: `site:reddit.com/r/ADHD_Programmers "what worked"` (top all-time)
- Reddit: `site:reddit.com/r/ExperiencedDevs ADHD`
- Mastodon: search `#ADHDDeveloper` on elk.zone, sort by recent
- X/Twitter: `(ADHD) (developer OR programmer) min_faves:100 since:2024-01-01`

### Communities

- ADDitude Magazine — search "software" / "engineering" / "developer"
- CHADD.org adult ADHD section — workplace adaptation papers
- PrivacyGuides forum — calendar discussion threads 2025–2026
- Hacker News *Who's Hiring* threads — not for hiring, but text-search for "ADHD" in commenter histories surfaces good practitioner posts

### GitHub topics (per playbook §GitHub topics)

- `topics/adhd`, `topics/neurodiversity`, `topics/pkm`, `topics/zettelkasten`, `topics/personal-knowledge-management`

### Specific repos to skim

- `XargsUK/awesome-adhd` — already cited; mine for new entries since extraction
- `mrseth01/awesome-adhd` — alt awesome-list
- `andymatuschak/evergreen-notes` (or equivalent if URL changed)
- `mem0ai/mem0` — competing memory architecture
- `letta-ai/letta` (formerly MemGPT) — competing
- `langchain-ai/langgraph` — competing
- `garrytan/gstack` — GBrain memory layer

## 7. Stop conditions

Stop and surface for human review if:

- Any peer-reviewed claim has ambiguous evidence (e.g., the 23-minute number is widely misquoted; if Gloria Mark's original measurement was different, surface it instead of papering over).
- An ADHD-specific claim risks medicalizing the playbook (this is a stack-design playbook, not a clinical resource).
- A competing memory framework looks structurally better than the 4-layer system (would invalidate chapter 03).
- The bibliography exceeds 30 entries (sign of over-research — cap and curate).

## 8. Estimated effort

S–M phase. 3–6 hours of research + 2–3 hours of writing/editing. Single researcher agent fine; no need for parallel sub-agents.
