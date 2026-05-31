# 06 — Session discipline

> Every commit references a ticket. Every push goes through review. Every session ends with a wrap. The discipline isn't aspirational; it's mechanically enforced where possible.

This chapter is about the per-session rules. Most are short. All are enforced by hooks where possible, by habit where not.

## What this chapter covers

| Section | What it solves |
|---|---|
| [Commit cadence](./commit-cadence.md) | When to commit. Message format. Conventional Commits compat. Push timing. |
| [PR review standard](./pr-review-standard.md) | The full merge-readiness checklist. Self-review. AI-assisted review. Pre-push enforcement. |
| [Audit and conventions pattern](./audit-and-conventions-pattern.md) | Dated audits + locked conventions, and how they map to ADRs. |
| [Wrap and resume](./wrap-and-resume.md) | The session-end + session-start ritual. The `/wrap` skill and SessionStart hook. |
| [Hook and script examples](./hook-and-script-examples.md) | Copy-paste-runnable git + Claude Code hooks. |

## The framing

A session is a unit of work between two `git log` entries. The discipline ensures every commit traces to a ticket (`git log --grep="G-97"`), every commit was reviewed (`Reviewed-by:` trailer), and every session leaves breadcrumbs (wrap doc, memory) so the next session resumes instead of rediscovering. Without it, sessions drift: code lands without context, tickets close without trace.

**What this removes from working memory:** "what was I doing?", "did I review this?", "which ticket was this for?", "is this pushed?" — all answered by the repo, not your head.

## The rules (non-negotiable)

- **NEVER commit directly to / force-push `main`.** Branches and PRs only. Fix forward.
- **Branch naming:** `<ticket-id>/<short-description>` (e.g., `G-240/license-agpl3`).
- **PR for every change**; **tests** for code changes (docs/license exempt); **pre-push review** before push; **CI passes** before merge.
- **Commit per meaningful change**, ticket-prefixed, pushed immediately on feature branches, with a real body — not `fix stuff`.
- **Each session** ends with `/wrap` and starts with the SessionStart hook loading the handoff.

Cultural rules ("we commit per meaningful change") fail ~30% of the time; mechanical rules (pre-push hooks, branch-name regex) fail <1%. Mechanize the floor ([hook examples](./hook-and-script-examples.md)); habit is the ceiling.

## Against Conventional Commits / Gitmoji

The `<ticket>: <title>` format is a **super-set** of [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/): you can run both (`G-732 feat(pm): …`) — the ticket is for `grep`, the `feat:` type is for release tooling. Adopt the type prefix only if [semantic-release/Changesets](./commit-cadence.md#conventional-commits-compatibility) consume it; otherwise it's ceremony. **Gitmoji** is rejected — emojis don't `grep`, render inconsistently, and the playbook bans them. Details in [commit cadence](./commit-cadence.md#conventional-commits-compatibility).

## Self-review at solo-dev scale

> You're both author and reviewer. The trap is collapsing the four things team review did — second eyes, knowledge transfer, gatekeeping, accountability — into "I looked at it." Replace them deliberately: a **time gap** (review cold, not while intent is warm), an **[AI reviewer](./pr-review-standard.md#ai-assisted-self-review)** as the fresh-context second brain (`/code-review`, `/security-review`), the **pre-push hook** as the gate, and the **`Reviewed-by:` trailer** as the record. The [merge-readiness checklist](./pr-review-standard.md#merge-readiness-checklist) is written to work even when the reviewer is Claude Code.

## Alternatives considered

| Decision | We picked | We rejected | Why |
|---|---|---|---|
| Commit convention | Ticket-prefix (CC super-set) | Bare Conventional Commits; Gitmoji | Ticket trace is the daily query; CC type only if release tooling needs it |
| Decision records | Audit + convention split | Monolithic ADR per decision | Solo devs query "the rule now" > "the rule in March"; split keeps the live rule one file |
| Hook manager | pre-commit | Husky, lefthook, simple-git-hooks | Gallery + language isolation; lefthook only if polyglot speed proven |
| Multi-machine sync | git (repo) + Syncthing (dotfiles) | Syncthing-everything; Resilio; rsync | git already versions+merges repo content; Syncthing conflict-copies lose edits |
| Session handoff | Durable in-repo markdown | Tool-proprietary session state | Survives tool changes; rides git to other machines |

## Field tests beyond the author

Convergent evolution validates the durable-markdown handoff: [Cline's Memory Bank](https://docs.cline.bot/features/memory-bank) (structured `activeContext.md`/`progress.md` re-read each session), [Aider's](https://aider.chat/docs/usage/commands.html) chat-history save/restore, and the Cursor "memory bank" community pattern all independently land on the same idea. The `Reviewed-by:` trailer is borrowed wholesale from the [Linux kernel](https://docs.kernel.org/process/submitting-patches.html) and is used beyond it (Git, Gerrit, QEMU, U-Boot). ADRs are field-tested at scale via the [canonical template repo](https://github.com/joelparkerhenderson/architecture-decision-record). No external validation yet for the specific `/wrap`-skill-plus-SessionStart-hook combination — that's the chapter's novel synthesis.

## What we'd change in 2026

- **Lean on `SessionEnd`.** The hook didn't exist when this chapter was first written; a `SessionEnd` hook can now *prompt* the wrap mechanically instead of relying on you to type `/wrap`.
- **`/resume` is built in now** — drop the custom resume skill; keep a `/reground` that re-reads the durable handoff.
- **Mirror local hooks into CI.** `pre-commit run --all-files` in a GitHub Action makes the gate unbypassable; the local hook is just for speed.

## Version matrix

| Tool | Pin / version | Note |
|---|---|---|
| Claude Code hooks | contract verified 2026-05-31 | `SessionStart`/`PreCompact`/`SessionEnd`; see [hooks](https://code.claude.com/docs/en/hooks) |
| Conventional Commits | v1.0.0 | No 2.0; super-set-compatible |
| pre-commit | `pre-commit-hooks` rev `v5.0.0` | Pin `rev:`, bump via `autoupdate` |
| Syncthing | continuous P2P | dotfiles only, not active repos |

## Related

- [Chapter 02 — Slug rules](../02-filesystem-conventions/slug-rules.md) — branch naming
- [Chapter 01 — Ticket standard](../01-linear-as-load-bearing-pm/ticket-standard.md) — what every commit references
- [Chapter 03 — Agent rules](../03-claude-code-as-operator/agent-rules.md) — agents follow the same discipline
- [Chapter 05 — Git signing](../05-secrets-and-secure-defaults/git-signing.md) — signing is a separate but related discipline
- [Sources](./sources.md) — chapter bibliography
