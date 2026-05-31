# ROADMAP — Milestone M1: Depth via grounded research

Eight phases, one per chapter. Each phase is independent — they can be picked up in parallel by separate `gsd-phase-researcher` agents.

## Phase index

| Phase | Folder | RESEARCH brief | Owner role |
|---|---|---|---|
| P00 | [`00-principles/`](./00-principles/) | [RESEARCH.md](./00-principles/RESEARCH.md) | gsd-phase-researcher |
| P01 | [`01-linear-as-load-bearing-pm/`](./01-linear-as-load-bearing-pm/) | [RESEARCH.md](./01-linear-as-load-bearing-pm/RESEARCH.md) | gsd-phase-researcher |
| P02 | [`02-filesystem-conventions/`](./02-filesystem-conventions/) | [RESEARCH.md](./02-filesystem-conventions/RESEARCH.md) | gsd-phase-researcher |
| P03 | [`03-claude-code-as-operator/`](./03-claude-code-as-operator/) | [RESEARCH.md](./03-claude-code-as-operator/RESEARCH.md) | gsd-phase-researcher |
| P04 | [`04-rituals-and-triggers/`](./04-rituals-and-triggers/) | [RESEARCH.md](./04-rituals-and-triggers/RESEARCH.md) | gsd-phase-researcher |
| P05 | [`05-secrets-and-secure-defaults/`](./05-secrets-and-secure-defaults/) | [RESEARCH.md](./05-secrets-and-secure-defaults/RESEARCH.md) | gsd-phase-researcher |
| P06 | [`06-session-discipline/`](./06-session-discipline/) | [RESEARCH.md](./06-session-discipline/RESEARCH.md) | gsd-phase-researcher |
| P07 | [`07-cheatsheets-and-living-docs/`](./07-cheatsheets-and-living-docs/) | [RESEARCH.md](./07-cheatsheets-and-living-docs/RESEARCH.md) | gsd-phase-researcher |
| P08 | [`08-agent-safety/`](./08-agent-safety/) | [RESEARCH.md](./08-agent-safety/RESEARCH.md) | gsd-phase-researcher (greenfield — creates new chapter) |
| P09 | [`09-token-economy/`](./09-token-economy/) | [RESEARCH.md](./09-token-economy/RESEARCH.md) | gsd-phase-researcher (greenfield — creates new chapter) |

## Shared assets

- [`SEARCH-PLAYBOOK.md`](./SEARCH-PLAYBOOK.md) — web/social/community search recipes used by every phase. Each per-phase RESEARCH.md references this rather than restating it.
- [`HANDOFF.md`](./HANDOFF.md) — instructions for the downstream agent that picks up a phase (output contract, stop conditions, commit rules).
- [`CLOUD-PROMPTS.md`](./CLOUD-PROMPTS.md) — copy-paste blocks for spawning Claude Code cloud sessions per phase.

## Phase ordering

Phases can run **in parallel** — no hard dependencies between them. Suggested wave structure if you serialize:

1. **Wave 1 (foundations):** P00 — principles are referenced everywhere; lock language first.
2. **Wave 2 (parallelizable):** P01, P02, P03, P05 — independent infra-layer chapters.
3. **Wave 3 (parallelizable):** P04, P06, P07 — depend on glossary established in Wave 2 but otherwise independent.

In Auto mode with parallel agents, just fire all 8 with the explicit instruction to defer cross-chapter language alignment to a final pass.

## Definition of done (per phase)

- [ ] All RESEARCH.md research questions answered with cited source
- [ ] At least 5 external sources cited (primary docs, adjacent repos, peer-reviewed work, practitioner blogs, community posts)
- [ ] Alternatives table added (or expanded) to chapter README
- [ ] "Field tests beyond the author" subsection added
- [ ] "What we'd change in 2026" subsection added
- [ ] Version matrix added where tools have releases
- [ ] PR opened against `main`, links to phase RESEARCH.md in the description

## Definition of done (milestone)

- All 8 phase PRs merged
- README's chapter table reflects new depth (no chapter regresses)
- A `RESEARCH-LOG.md` at repo root summarizes what changed and links the source bibliography
- Adjacent repo maintainers (gstack, solo-founder-playbook, awesome-adhd) optionally pinged with cross-link offers
