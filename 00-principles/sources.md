# Sources — Chapter 00 (Principles)

Rolled-up bibliography for the four principle files, deduplicated. Per-claim inline markers live in each sub-topic file's own `## Sources` section; this is the chapter-level index.

For the **ADHD-specific** claims and their A/B/C evidence grading, the canonical doc is [`evidence-and-citations.md`](./evidence-and-citations.md) — not duplicated here. This file covers the other three axes plus the cross-cutting design sources.

Source weighting follows [`../.planning/SEARCH-PLAYBOOK.md`](../.planning/SEARCH-PLAYBOOK.md): primary docs > vendor blog > academic > practitioner > community.

## ADHD-aware design

- Full peer-reviewed grade-by-tier list: [`evidence-and-citations.md`](./evidence-and-citations.md) and the [Peer-reviewed sources section of `credits.md`](../credits.md).
- Design-theory root: Norman, D. A. (1988/2013). *The Design of Everyday Things.* Basic Books — the "affordance" concept.
- Competing frameworks (Alternatives table): [Getting Things Done](https://gettingthingsdone.com/), [Building a Second Brain / PARA](https://www.buildingasecondbrain.com/), [Bullet Journal](https://bulletjournal.com/), [Habitica](https://habitica.com/), [Leantime](https://leantime.io/).

## Four-layer memory

- [Claude Code memory & Auto Memory docs](https://code.claude.com/docs/en/memory) — native hierarchy, `MEMORY.md` 200-line/25 KB auto-load. Accessed 2026-05-31. (primary)
- [Anthropic — "Give Claude context: CLAUDE.md"](https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts) — "loaded in full… shorter files produce better adherence." Accessed 2026-05-31. (primary)
- [Cursor — Rules docs](https://cursor.com/docs/rules) — `.cursor/rules/*.mdc`; "keep always-apply rules under 200 words." Accessed 2026-05-31. (primary)
- [What Is Claude Code Auto-Memory? (MindStudio)](https://www.mindstudio.ai/blog/what-is-claude-code-auto-memory) — Auto Memory / Auto Dream mechanics. Accessed 2026-05-31. (practitioner)
- [Cline Memory Bank](https://docs.cline.bot/features/memory-bank) — 6-file structured memory. Accessed 2026-05-31. (vendor docs)
- [mem0](https://github.com/mem0ai/mem0) — memory service, user/session/agent scopes, vector+graph+KV. Accessed 2026-05-31. (adjacent)
- Packer, C. et al. (2023). [MemGPT: Towards LLMs as Operating Systems](https://arxiv.org/abs/2310.08560). arXiv:2310.08560 — now the [Letta](https://github.com/letta-ai/letta) runtime. (academic)
- [LangMem](https://github.com/langchain-ai/langmem) — episodic/semantic/procedural memory for LangGraph. Accessed 2026-05-31. (adjacent)
- [gstack GBrain](https://github.com/garrytan/gstack) — Claude Code skill-bundled memory layer. Accessed 2026-05-31. (adjacent)
- [Andy Matuschak — Evergreen notes](https://notes.andymatuschak.org/Evergreen_notes) — atomic, concept-oriented, densely linked. Accessed 2026-05-31. (practitioner/primary)

## Single source of truth

- [Single source of truth — Wikipedia](https://en.wikipedia.org/wiki/Single_source_of_truth) — "every data element is mastered (or edited) in only one place." Accessed 2026-05-31. (reference)
- Nygard, M. (2011). [Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) — ADRs; one short versioned file per decision. Accessed 2026-05-31. (practitioner/primary)
- Evans, E. (2003). *Domain-Driven Design: Tackling Complexity in the Heart of Software.* Addison-Wesley — domain model as the team's single shared reference. (book)
- Vogels, W. (2008). [Eventually Consistent](https://queue.acm.org/detail.cfm?id=1466448), *ACM Queue* 6(6). Accessed 2026-05-31. (academic)
- Kleppmann, M. (2017). *Designing Data-Intensive Applications.* O'Reilly — ch. 5, "Replication." (book)

## Calendar-vendor-neutrality

- [Privacy Guides — Calendar](https://www.privacyguides.org/en/calendar/) — recommends Tuta/Proton; the E2EE-vs-CalDAV trade-off. Accessed 2026-05-31. (community/primary)
- [Mailfence — Why Proton Calendar doesn't support CalDAV](https://blog.mailfence.com/proton-calendar-support-caldav/) — and Fastmail as the CalDAV-reliable option. Accessed 2026-05-31. (practitioner)
- [Radicale](https://radicale.org/) — lightweight file-based CalDAV/CardDAV server, no database. Accessed 2026-05-31. (primary)
- [Nextcloud](https://nextcloud.com/athome/) — Calendar with CalDAV + web UI, full groupware. Accessed 2026-05-31. (primary)
- [khal](https://github.com/pimutils/khal) + [vdirsyncer](https://github.com/pimutils/vdirsyncer) — CLI plaintext calendar over CalDAV; khalorg/khalel bridge to org-mode. Accessed 2026-05-31. (primary)
- [UnifiedPush](https://unifiedpush.org/) — Google-free push protocol; ntfy is a UnifiedPush distributor, works on GrapheneOS. Accessed 2026-05-31. (primary)

## Related

- [`evidence-and-citations.md`](./evidence-and-citations.md) — ADHD claims, A/B/C tier grading (the peer-reviewed layer)
- [`../credits.md`](../credits.md) — repo-wide source list (primary docs, adjacent repos, peer-reviewed ADHD sources)
