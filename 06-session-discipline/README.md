# 06 — Session discipline

> Every commit references a ticket. Every push goes through review. Every session ends with a wrap. The discipline isn't aspirational; it's mechanically enforced where possible.

This chapter is about the per-session rules. Most are short. All are enforced by hooks where possible, by habit where not.

## What this chapter covers

| Section | What it solves |
|---|---|
| [Commit cadence](./commit-cadence.md) | When to commit. What goes in messages. Push timing. |
| [PR review standard](./pr-review-standard.md) | The checklist. Pre-push hook enforcement. |
| [Audit and conventions pattern](./audit-and-conventions-pattern.md) | Why dated audits + locked conventions, and how they relate. |
| [Wrap and resume](./wrap-and-resume.md) | The session-end + session-start ritual. |

## The framing

A session is a unit of work between two `git log` entries. The discipline ensures:

- Every commit traces to a ticket (`git log --grep="G-97"` finds the trail)
- Every commit was reviewed (`Reviewed-by:` trailer)
- Every session leaves enough breadcrumbs for the next session to resume (auto-memory updates, wrap doc)

Without discipline, sessions drift. Code lands without context. Tickets close without trace. Next session re-discovers the same state.

## The rules

### Git workflow (non-negotiable)

- **NEVER commit directly to main / master.** All changes go through branches and PRs. No exceptions.
- **NEVER force-push to main / master.** Not even to "fix" a bad commit. Fix forward.
- **Branch naming:** `<ticket-id>/<short-description>` (e.g., `G-240/license-agpl3`).
- **PR for every change**, even small ones (license file, docs typo).
- **Tests required** for code changes. Docs / license changes exempt.
- **Pre-push review** before push (see [PR review standard](./pr-review-standard.md)).
- **CI/CD passes** before merge. Don't bypass checks.

### Commit cadence

- **Commit after every meaningful change.** Don't batch.
- **Every commit references a Linear ticket** — prefix subject with ticket ID.
- **Push after committing on non-main branches.** Unpushed branches are invisible to other sessions.
- **Commit messages are thorough.** Title (concise) + blank line + body explaining what + why. No `fix stuff` one-liners.
- **WIP commits are OK on long branches.** Squash before merge if you prefer.

### Memory updates

After committing, if project state changed:
- Update Layer 3 auto-memory (current state, blockers)
- Store to Layer 4 if cross-project relevant
- Narratives count as state — save them too

### Session boundaries

- Each session ends with `/wrap` writing a handoff doc and updating MEMORY.md
- Each session starts with `SessionStart` hook loading the handoff doc into context
- Auto-rolled work AND not-yet-shipped work both surface at session start

## Why mechanical enforcement

Cultural rules ("we commit per meaningful change") fail 30% of the time. Mechanical rules (pre-push hooks, branch-name regex) fail < 1%.

Where you can mechanize:
- Pre-commit hook validating slug format in branch name
- Pre-push hook checking `Reviewed-by:` trailer
- CI hook checking signed commits

Where you can't:
- "Was this commit meaningful?" — no script can answer this
- "Did you update memory after the commit?" — script can prompt but not decide

The mechanical enforcement is the floor. Habit is the ceiling.

## Related

- [Chapter 02 — Slug rules](../02-filesystem-conventions/slug-rules.md) — branch naming
- [Chapter 01 — Ticket standard](../01-linear-as-load-bearing-pm/ticket-standard.md) — what every commit references
- [Chapter 03 — Agent rules](../03-claude-code-as-operator/agent-rules.md) — agents follow the same discipline
- [Chapter 05 — Git signing](../05-secrets-and-secure-defaults/git-signing.md) — signing is a separate but related discipline
