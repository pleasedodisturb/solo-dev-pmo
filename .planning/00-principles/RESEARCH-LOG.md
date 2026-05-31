# RESEARCH-LOG — P00b (Principles breadth pass)

Append-only log of sources used, per `.planning/SEARCH-PLAYBOOK.md` §"Per-phase research log format". Covers the P00 follow-up brief (`RESEARCH-followup.md`). The earlier ADHD-evidence pass (PR #3) is logged in `evidence-and-citations.md` / `credits.md`, not here.

## 2026-05-31 — Claude Code native memory (Q00.5, Q00.6)

- **Source:** https://code.claude.com/docs/en/memory ; https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts
- **Class:** primary (vendor docs)
- **Surfaced fact:** Native Auto Memory: `CLAUDE.md` loaded in full ("shorter files produce better adherence"); `MEMORY.md` auto-loads first 200 lines / 25 KB; per-repo, not shared across machines; "Auto Dream" consolidation.
- **Used in:** four-layer-memory.md ("Native memory in 2026" + cap citations)
- **Counter-evidence:** none — validates the model. Resolves stop-condition risk #1 (native memory does not obsolete the 4-layer model).

## 2026-05-31 — External cap corroboration (Q00.6)

- **Source:** https://cursor.com/docs/rules
- **Class:** primary (vendor docs)
- **Surfaced fact:** Cursor advises keeping always-apply rules "under 200 words" — independent cap in the same order of magnitude as the chapter's ~150–200 line caps.
- **Used in:** four-layer-memory.md (Layer 1 cap note)
- **Counter-evidence:** none.

## 2026-05-31 — Competing memory architectures (Q00.5)

- **Source:** https://docs.cline.bot/features/memory-bank ; https://github.com/mem0ai/mem0 ; https://arxiv.org/abs/2310.08560 (MemGPT/Letta) ; https://github.com/langchain-ai/langmem ; https://github.com/garrytan/gstack
- **Class:** vendor docs / adjacent repos / academic
- **Surfaced fact:** Cline = 6 fixed markdown files; mem0 = service with user/session/agent scopes; Letta/MemGPT = OS-style virtual memory runtime; LangMem = episodic/semantic/procedural; gstack GBrain = skill-bundled memory.
- **Used in:** four-layer-memory.md (Alternatives table)
- **Counter-evidence:** none structurally beats 4-layer for solo-dev/file-sync. Resolves stop-condition risk #2: file-based ones converge with L1–L3; service-based ones are L4 backends.

## 2026-05-31 — Human-PKM ancestor (Q00.7)

- **Source:** https://notes.andymatuschak.org/Evergreen_notes
- **Class:** practitioner / primary
- **Surfaced fact:** Evergreen notes: atomic, concept-oriented, densely linked — analogous to "each fact at exactly one layer."
- **Used in:** four-layer-memory.md (Alternatives, PKM paragraph)
- **Counter-evidence:** divergence noted — evergreen notes optimize for cross-linking; agent layers optimize for partitioning/context budget.

## 2026-05-31 — SSOT origin (Q00.8)

- **Source:** https://en.wikipedia.org/wiki/Single_source_of_truth ; https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions (Nygard ADR, 2011) ; Evans, *Domain-Driven Design* (2003)
- **Class:** reference / practitioner / book
- **Surfaced fact:** SSOT = every data element mastered/edited in exactly one place; ADRs and DDD are the software-engineering lineage.
- **Used in:** single-source-of-truth.md ("Where the term comes from")
- **Counter-evidence:** none.

## 2026-05-31 — Redundancy counter-argument (Q00.9)

- **Source:** https://queue.acm.org/detail.cfm?id=1466448 (Vogels, "Eventually Consistent," ACM Queue 2008) ; Kleppmann, *Designing Data-Intensive Applications* (2017), ch. 5
- **Class:** academic / book
- **Surfaced fact:** distributed systems use replication for availability; replicas are derived/read-only and converge toward a master.
- **Used in:** single-source-of-truth.md ("The redundancy counter-argument") — reconciled as authoring (one place) vs serving (many copies).
- **Counter-evidence:** this *is* the counter-argument; reconciled rather than refuted.

## 2026-05-31 — CalDAV options (Q00.10)

- **Source:** https://radicale.org/ ; https://nextcloud.com/athome/ ; https://blog.mailfence.com/proton-calendar-support-caldav/ ; https://www.privacyguides.org/en/calendar/
- **Class:** primary / practitioner / community
- **Surfaced fact:** Radicale = lightweight file-based CalDAV (no DB, no sharing); Nextcloud = heavy groupware + web UI; Proton/Tuta = E2EE, NO full CalDAV; Fastmail = best CalDAV reliability (paid, AU).
- **Used in:** calendar-neutrality.md (CalDAV table) — **corrects** the pre-existing "Proton has CalDAV in beta" line.
- **Counter-evidence:** contradicts existing chapter content; handled additively with an explicit correction note (not a silent rewrite).

## 2026-05-31 — GrapheneOS push (Q00.11)

- **Source:** https://unifiedpush.org/ ; GrapheneOS forum threads on push without Google services
- **Class:** primary / community
- **Surfaced fact:** de-Googled push needs Sandboxed Play (FCM) or UnifiedPush; ntfy is a UnifiedPush distributor.
- **Used in:** calendar-neutrality.md ("Why ntfy specifically")
- **Counter-evidence:** none — validates the ntfy choice.

## 2026-05-31 — Privacy-community calendar consensus (Q00.12)

- **Source:** https://www.privacyguides.org/en/calendar/
- **Class:** community
- **Surfaced fact:** Privacy Guides recommends only Tuta + Proton (E2EE, no CalDAV); points CalDAV-needers to Fastmail.
- **Used in:** calendar-neutrality.md (Alternatives)
- **Counter-evidence:** none.

## 2026-05-31 — Plaintext calendar tooling (Q00.13)

- **Source:** https://github.com/pimutils/khal ; https://github.com/pimutils/vdirsyncer ; https://github.com/BartSte/khalorg
- **Class:** primary
- **Surfaced fact:** vdirsyncer syncs CalDAV to local single-`.ics` plain files; khal reads them; todoman for tasks; khalorg/khalel bridge org-mode.
- **Used in:** calendar-neutrality.md (CLI plaintext workflow)
- **Counter-evidence:** none.

## Notes / deviations

- All four sub-topic files already had a `## What this rules out` section from v0; the brief listed it as a deliverable. Treated as already-satisfied (adding a second would duplicate). Surfaced in PR #4.
- `adhd-aware-design.md` received **only** an Alternatives subsection (per brief; Sources stay in the locked `evidence-and-citations.md`). Framework citations rolled into `sources.md`.
- `evidence-and-citations.md` left untouched (locked).
