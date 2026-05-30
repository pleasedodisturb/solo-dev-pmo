# Audit and conventions pattern

> Two complementary documents per topic. Conventions = locked rules (edited in-place). Audits = dated snapshots (append-only). Together they form a complete picture: rules + their history.

This pattern is the meta-PM repo's structural backbone. It lets future-you reconstruct context from `git log` alone — no recomputation needed.

## The two file types

### Conventions

- **Path:** `conventions/<topic>.md`
- **No date prefix** — the filename IS the topic
- **Edited in-place** — when rules change, you edit
- **Locked once decided** — frequent edits are signal of unclear rules
- **The canonical answer** to "what's our rule for X?"

Examples:
- `conventions/naming.md` — slug format, layout, Linear↔GitHub binding
- `conventions/cycles.md` — cycle length, WIP cap, estimate scale
- `conventions/states.md` — Backlog vs Icebox vs Triage distinctions

### Audits

- **Path:** `audits/YYYY-MM-DD-<slug>.md`
- **Date prefix** — sorts chronologically
- **Append-only** — never edit (write a new audit if old one is wrong)
- **One per session** that changed PM tool / disk state
- **The history** of what was done and why

Examples:
- `audits/2026-05-18-linear-hygiene-execution.md`
- `audits/2026-05-29-phase1-disk-reorg-batch3.md`
- `audits/2026-05-29-app-bar-money-exception-removed.md`

## Why two file types

**Conventions answer "what."** Audits answer "when, why, by whom."

Rules change over time. Without conventions, you re-derive from audits every session (expensive, error-prone). Without audits, you have rules but no history (debugging is impossible).

Together:
- Open `conventions/naming.md` → current truth
- `git log audits/` → full history
- `git log conventions/naming.md` → history of the rule itself

## When to write each

### Write a convention when:

- A decision is final and applies forever (until explicitly revisited)
- Multiple future audits will reference this rule
- The rule is the kind of thing you'd want to find by topic, not by date

### Write an audit when:

- Any session changed PM tool state (created projects, snoozed tickets, restructured)
- Any session executed a step in a multi-session migration (phase work)
- You discovered something worth recording (a Linear feature behavior you didn't know about)
- You committed to a non-obvious approach (the "why we did X this way" record)

## Audit anatomy

```markdown
# <Title>

Date: 2026-05-18. <One-line context: what was the goal?>

## Baseline

<What was the state before? Cite numbers, screenshots, paths.>

## Changes made

1. <Change>: <command / link to what was done>. Outcome: <observed>.
2. <Change>: <command / link>. Outcome: <observed>.

## Decisions

<Decisions made during this session. Why we picked X over Y.>

## Verification

<How we know the changes worked. Commands run, paths verified.>

## Followups

<Tickets filed for further work. Outstanding questions for future sessions.>

## Sources

<Links to primary docs, prior research, related audits.>
```

The structure is recipe-like. Future-you opens an audit and knows what happened in 90 seconds.

## Convention anatomy

```markdown
# <Topic>

Canonical rules for <scope>.

**Status:** locked v<N>.<M> (<date>). <Brief status note>

**Authority:** This file is the source of truth. <How tooling consumes this.>

---

## 1. <Section>

<The rules, each numbered or tabulated.>

| Rule | Example ✓ | Counter-example ✗ |
|---|---|---|
| ... | ... | ... |

---

## 2. <Section>

...

## Changelog

- **v1.0 (date):** initial
- **v1.1 (date):** <what changed and why> — see `audits/<date>-<slug>.md`
- **v1.2 (date):** <what changed> — see `audits/<date>-<slug>.md`
```

The changelog links each version bump to the audit that justified it. The link makes "why did v1.1 happen?" answerable in two clicks.

## Working state vs. audit vs. memory

Three places, three jobs:

| Where | What |
|---|---|
| **Audits / Conventions (in this repo)** | Decisions and history of decisions. Cross-session, durable, versioned. |
| **Auto-memory (Layer 3)** | "Where we left off" working state. Per-machine, persists across sessions. |
| **In-conversation context** | Ephemeral. Lost at session end unless wrapped. |

When in doubt:
- Decision worth recording forever → audit
- Rule that supersedes previous rule → convention update (and audit explaining why)
- Current state of in-progress work → auto-memory
- Notes you're keeping for the next 5 minutes → conversation context

## How this enables "rebuild context from `git log` alone"

The promise: any future session (or any external collaborator who joined later) can run `git log --oneline audits/` and reconstruct the entire history of decisions and state changes.

Without this pattern, history is in:
- Tool's edit history (PM tool's activity feed, harder to read)
- Chat transcripts (lost)
- Memory of who was there (none, solo)

With the pattern, history is in your repo. `git log` IS the log. `git diff` between two convention versions shows what changed and when. The repo is a verifiable timeline of decisions.

## Field-tested gotchas

**Audits that get edited.** The rule is append-only. If an audit is wrong, write a NEW audit superseding it. Don't edit history.

**Conventions that pile up changelog entries.** A convention file with a 50-entry changelog is hard to read. At some point, archive old entries to a sibling history file.

**Audits without verification sections.** "We did X" without "we verified X worked" leaves doubt. Always document verification, even if it's just "ran `linearis issues list`, see attached output."

**Multi-session work spread across multiple audits.** Phase 1's plan in one audit, Phase 1 batch 1 execution in another, Phase 1 batch 2 in a third. Convention: write a `phase1-execution-plan.md` audit that the per-batch audits link back to.

**Conventions referenced by tools but missing.** `repo-sync-tool` reads `conventions/naming.md`; if the file isn't there, the tool fails. Conventions are part of the runtime contract.

## Innovative pattern: convention-driven CI

A daily script:
1. Reads all conventions
2. For each rule, runs a verification check against your actual state
3. Reports drift via ntfy

E.g., `conventions/naming.md` says lowercase slugs; CI checks every `~/Projects/*/*/` dir name matches.

Drift visible within 24 hours.

## Innovative pattern: audit cross-linking

Each audit links to:
- The convention it depends on or affects (`conventions/cycles.md`)
- Sibling audits in the same multi-session phase
- The PM tool tickets it executed

`grep -l "G-732" audits/` finds every audit related to ticket G-732. Full traceability.

## Innovative pattern: convention version locking

When you "lock v1.0" of a convention, also tag the repo:

```bash
git tag conventions/naming-v1.0 -m "Lock v1.0 of naming convention"
git push --tags
```

Anyone (including future-you) can `git checkout conventions/naming-v1.0` to see the convention as it was when locked. Useful for "we tooled around the old version of this convention; what was it?"

## Related

- [Chapter 02 — Filesystem conventions](../02-filesystem-conventions/) — the conventions files for layout/slug
- [Chapter 01 — Cycles and rituals](../01-linear-as-load-bearing-pm/cycles-and-rituals.md) — the conventions files for cycles
- [Wrap and resume](./wrap-and-resume.md) — the per-session companion to per-topic audits
