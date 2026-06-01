# AUDIT — solo-dev-pmo (2026-06-01 ~13:00 UTC)

Scope: main branch HEAD `157c4c5`. Covers chapters 00–08, root scaffolding (README.md, credits.md, extraction-sheet.md, SANITIZATION-SCAN.md), and `.planning/` contracts (HANDOFF.md, PROJECT.md, ROADMAP.md, CLOUD-PROMPTS.md, SEARCH-PLAYBOOK.md).

## Summary

- Total findings: 11 (0 CRITICAL / 0 HIGH / 6 MEDIUM / 5 LOW)
- One-line verdict: **minor fixes recommended** — playbook is ship-ready; the listed items are polish, not blockers. No broken links, no secret leaks, no orphan chapter-09 references, dangerous recipes all carry the right warnings, datestamps consistent.

## Findings

### CRITICAL
None.

### HIGH
None.

### MEDIUM

#### F1: PROJECT.md still claims "Eight chapters (00–07)"
- **File:** `.planning/PROJECT.md`:7
- **What:** Says "Eight chapters (00–07), each currently a working README + 3–6 sub-topic files." Reality: 9 chapters (00–08) on main; chapter 09 was just extracted out. Also `.planning/ROADMAP.md` references chapter 08 and its phase brief exists.
- **Why it matters:** PROJECT.md is the contract doc downstream agents read first per HANDOFF.md §"Before you start". Stale framing misleads future research passes about the chapter inventory.
- **Suggested fix:** Update §"What it is" to "Nine chapters (00–08)…" and reflect chapter 08 (Agent safety) as shipped. Also drop the M1 milestone framing or mark it complete.

#### F2: credits.md says "4-tier scorecard"; chapter 08 says "5-tier"
- **File:** `credits.md`:91 vs `08-agent-safety/README.md`:18,45 and `08-agent-safety/agent-hardening.md`:11
- **What:** credits.md describes llm-safe-haven as having a "4-tier security scorecard"; chapter 08 consistently says "5-tier scorecard" / "five-level scorecard" (Tier 0 Exposed → Tier 4 Fortified).
- **Why it matters:** Numeric inconsistency for an externally-published tool that the playbook cites as primary substance. Readers comparing the two will distrust one or both.
- **Suggested fix:** Change credits.md to "5-tier security scorecard" to match the chapter and llm-safe-haven's actual tier count.

#### F3: Four sub-topic / scaffolding files exceed file caps
- **Files:** `03-claude-code-as-operator/memory-architecture.md` (304 lines), `01-linear-as-load-bearing-pm/io-rules.md` (299), `SANITIZATION-SCAN.md` (275), `01-linear-as-load-bearing-pm/ticket-standard.md` (256)
- **What:** HANDOFF.md §"Voice + style" sets sub-topic cap at ≤250 lines; chapter READMEs at ≤100. All four are over by 6–54 lines.
- **Why it matters:** Cap is the contract enforced on every research pass; exceeding it silently sets precedent for further drift. memory-architecture.md is +54 (notable).
- **Suggested fix:** Either tighten the four files to ≤250 (extract examples or "Innovative pattern" sections into siblings) or update HANDOFF.md to acknowledge load-bearing chapters may run to 300 with explicit cap-exception list.

#### F4: Two chapter READMEs exceed 100-line cap
- **Files:** `05-secrets-and-secure-defaults/README.md` (114 lines), `01-linear-as-load-bearing-pm/README.md` (106)
- **What:** HANDOFF.md says chapter READMEs stay ≤100. Both are slightly over.
- **Why it matters:** Same as F3 — silently relaxes a stated rule.
- **Suggested fix:** Either trim each by ~10 lines (the "What we'd change in 2026" / version-matrix sections are good trim candidates) or amend HANDOFF.md to allow ~120 for showcase chapters.

#### F5: Cline Memory Bank URL inconsistency across chapters
- **Files:** `00-principles/four-layer-memory.md`:115 + `00-principles/sources.md`:21 + `06-session-discipline/README.md`:53 + `06-session-discipline/wrap-and-resume.md`:242 use `https://docs.cline.bot/features/memory-bank`; `01-linear-as-load-bearing-pm/sources.md`:66 + `01-linear-as-load-bearing-pm/ticket-standard.md`:247 + `03-claude-code-as-operator/agent-platform-portability.md`:68 + `03-claude-code-as-operator/memory-comparison.md`:52 + `03-claude-code-as-operator/sources.md`:27 use `https://docs.cline.bot/prompting/cline-memory-bank`.
- **Why it matters:** Two different canonical URLs for the same vendor doc; one is bound to 404 after a doc reorg. Single-source-of-truth violation in the playbook's own citations.
- **Suggested fix:** Pick one (verify which is current — `/features/memory-bank` looks like the more recent product-section URL) and `replace_all` across the repo.

#### F6: P08 chapter table omits `threat-model.md` as a listed section
- **File:** `08-agent-safety/README.md`:16–20
- **What:** The "What this chapter covers" table lists threat-model, agent-hardening, session-isolation (good). But the README itself is 76 lines and there's no `sources.md` row in that table — yet `08-agent-safety/sources.md` exists and is cited from the README ("see also: sources.md"). Minor structural gap for consistency with how other chapter READMEs surface their sources.md.
- **Why it matters:** Other chapter READMEs (00, 02, 03, 06, 07) explicitly link to sources.md in the section table or in Related. Chapter 08's only mention is at the bottom Related.
- **Suggested fix:** Add a Related-style sources.md link to chapter 08's table or to the recommended reading order. Cosmetic but improves cross-chapter consistency.

### LOW

#### F7: HANDOFF.md still scopes work to "P00–P07" only
- **File:** `.planning/HANDOFF.md`:11
- **What:** "Phase ID: `P00`–`P07`". P08 exists and shipped; ROADMAP.md and CLOUD-PROMPTS.md both include P08.
- **Why it matters:** Trivially out of date; if a new researcher reads HANDOFF.md cold they'd think P08 isn't a valid phase ID.
- **Suggested fix:** Update to `P00`–`P08` (and consider acknowledging P00b follow-up as a documented variant).

#### F8: ROADMAP.md says "Eight phases" then lists nine in the index
- **File:** `.planning/ROADMAP.md`:3 vs lines 7–17
- **What:** Header reads "Eight phases, one per chapter." Index table lists P00 through P08 = nine rows.
- **Why it matters:** Internal contradiction in a contract doc.
- **Suggested fix:** Change "Eight phases" to "Nine phases" and update the "Wave 2 / Wave 3" parallelization advice to include P08 (or note P08 was added later and runs greenfield).

#### F9: Footnote definition style is inconsistent across chapters
- **Files:** Ch02 uses `- [¹] URL` (dash-prefixed superscript, no colon); Ch01 alternatives.md uses `- [1]: URL` (numeric, with colon); Ch03/Ch05/Ch08 use `[1]: URL` (numeric, with colon, no dash); Ch00 mixes both.
- **Why it matters:** All footnotes resolve, but the format inconsistency makes future find-and-replace tooling brittle and shows the playbook drifting from any one citation grammar.
- **Suggested fix:** Pick one: `[N]: URL` (matches CommonMark reference-link style and is the dominant format). Migrate ch02's `- [¹] URL` lines into `[¹]: URL` (or normalize all superscripts to numeric).

#### F10: SANITIZATION-SCAN.md never gets shipped — but cap-relevant
- **File:** `SANITIZATION-SCAN.md`:1
- **What:** The "## 10. The push-day procedure" section advises forks to delete this file before publishing — but the main repo still ships it. That's intentional (it's the meta-doc for forkers), but the file itself isn't called out as "this is for forkers, the original keeps it." Also at 275 lines it tips the cap (see F3).
- **Why it matters:** A reader scanning the root might assume the playbook was authored against this scan and that the scan's placeholders (`<your-username>` etc.) are still active concerns in the original — but the original was already sanitized at v0. Tiny clarity gap.
- **Suggested fix:** Add a 2-line preamble: "This doc is for **forkers**. The original repo has already passed this scan." Or move into `examples/` with a README pointer.

#### F11: gstack "65+ skills" vs "~31 core" contradiction
- **Files:** `README.md`:27,57 and `credits.md`:68 claim gstack has "65+ skills"; `03-claude-code-as-operator/sources.md`:91 says "The brief's 'gstack 65+ skills' figure is inflated — current docs show ~31 core."
- **Why it matters:** The audit caveat exists in the sources.md but the public-facing README and credits.md keep the inflated number. Reader sees "65+" everywhere and only discovers the correction if they read ch03/sources.md.
- **Suggested fix:** Either reword to "ships dozens of skills" (vague-but-honest), or land the corrected number ("ships ~31 core skills") in README + credits.md. Sources.md already has the receipts; surface them.

## Audit method

- Files read in full: 64 markdown files (all chapter READMEs, all sub-topic files in 00–08, all sources.md, all .planning/ contract docs, root scaffolding files, examples/README + conventions-naming).
- Files spot-checked: examples/ scripts (CLAUDE.md.template, ticket-template.md verified extant by `ls`), cheats-starter/ tree verified extant.
- Dimensions covered: integrity (cross-chapter + within-chapter link resolution via python walker; footnote completeness; datestamp recency); coherence (terminology, README chapter status table, orphan ch09 search across all files, credits.md ↔ chapter 08 alignment); security (regex sweep for sk-/ghp_/xoxb-/AKIA/api-key patterns — zero hits; dangerous recipes all warned; personal-username path leaks limited to `.planning/RESEARCH.md` files which are not published as chapters); mistakes (file caps via `wc -l`; markdown well-formedness via reading; TODO/FIXME/XXX search — none in published content, only in deliberate anti-pattern call-outs).
- Time bound: ~1 pass, top-to-bottom.
- Caveats: External link liveness not verified (per audit brief). Footnote-reference validator caught false positives where the playbook uses `- [¹] URL` (no colon) definitions; manual spot-checks of ch02 + ch01/alternatives confirm all inline refs resolve. Did not exhaustively diff every Linear product claim against current vendor docs.
