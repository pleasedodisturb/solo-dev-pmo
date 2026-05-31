# Single source of truth

One inbox. One canonical doc per topic. One naming convention. One way to do each thing.

Duplication is debt. Pay it down by deleting copies, not by keeping them in sync.

## At the capture level

You have one inbox — typically your PM tool's Triage state. Every thought, every bug, every "I should do X later" lands there. Not in Slack DMs. Not in a notes app. Not in a TODO comment in code. Not in a tmux scratch pane.

When something else *generates* a capture (an email, a Slack message, a CLI command, a script crash), the capture is routed *into* the one inbox.

This holds even when it's inconvenient. The cost of "I'll put this in the better place" is that half the time, you forget. The cost of "everything goes in the one inbox" is that the inbox gets messy. The messy inbox is recoverable; the lost thought isn't.

See [Chapter 01 — Triage as inbox](../01-linear-as-load-bearing-pm/triage-as-inbox.md).

## At the doc level

Every topic has one canonical doc. When you need to update the topic, you update that one doc. References to the topic from other docs are *links*, not copies.

Concrete examples:
- Linear ticket quality standard lives in *one* doc. The project CLAUDE.md links to it. The agent rules link to it. The session summary skill links to it. None of them inline the spec.
- Naming conventions live in *one* `conventions/naming.md`. Tooling that needs to validate naming reads from there.
- The MCP routing table lives in *one* `~/.claude/docs/mcp-routing.md`. The agent-rules doc links to it.

When you find yourself about to write "as documented in X, the rule is Y" — link to X, don't restate Y. The link survives doc edits; the restated rule rots.

## At the convention level

For each recurring decision, there's one convention. Slug format (lowercase + `-`, no underscores). Worktree placement (`~/.claude/worktrees/<repo>/<branch>/`). Branch naming (`<ticket-id>/<description>`). Audit filename (`YYYY-MM-DD-<slug>.md`).

Conventions live in a `conventions/` folder, are edited in-place (no date prefix), and are linked from everywhere they're enforced.

## What this rules out

- **Cross-posting to multiple channels** — "I'll write this in the doc and also in the ticket and also in the chat." No. Pick one canonical home, link from the others.
- **Inline restatement** — "as the rule says, do X." If you have to restate it, you'll forget to update it.
- **Multiple `TODO.md` files across projects** — one PM tool, one inbox.
- **Multiple `NOTES.md` files in one repo** — one auto-memory location, one structure.

## What this rules in

- **Links over copies** — every reference is a hyperlink to the canonical home.
- **Mechanical enforcement where possible** — pre-commit hooks that check for slug format, ticket prefix in commit messages, etc.
- **The 4 memory layers** — see [Four-layer memory](./four-layer-memory.md). Each fact lives at *exactly one* layer.

## Why this matters

Duplication doesn't fail the day you create it. It fails three weeks later when one copy gets updated and the others don't. By then, "what's the real rule?" requires reading both copies, comparing, and guessing.

Solo, you don't have someone to ask. The canonical doc is the only authority. If there are two of them, there's no authority.

## Where the term comes from

"Single source of truth" is an established information-architecture term: every data element is *mastered in exactly one place* and referenced elsewhere by link, never copied.[¹] The same instinct shows up wherever people fight documentation rot — Michael Nygard's Architecture Decision Records record each decision once, in one short versioned file, precisely so the rationale isn't re-stated and left to rot across wikis.[²] Domain-Driven Design makes the domain model the canonical reference the whole team speaks from.[³] We generalize the idea past code: one inbox, one doc per topic, one convention file.

## The redundancy counter-argument (and why it doesn't apply)

The obvious objection: distributed systems treat *redundancy as resilience*. Replicas, caches, backups — copies everywhere, on purpose. Werner Vogels' "eventually consistent" replicas[⁴] and the replication chapter of Kleppmann's *Designing Data-Intensive Applications*[⁵] are built on having many copies.

These don't contradict SSOT; they operate on a different axis:

- **SSOT governs authoring** — where a fact is *edited*. Exactly one place.
- **Replication governs serving** — how a fact is *delivered* for availability. Many copies.

Replicas are *derived and read-only*: they converge toward the master, they don't independently author truth. The playbook's rule is about authoring (don't edit the same fact in two places). Caching a rendered copy, syncing a doc across machines, exporting an `.ics` — that's replication, and it's fine, as long as exactly one copy is the writable master. The failure mode SSOT prevents is *two writable copies*, which is exactly what multi-master systems need CRDTs to survive — overkill when you're the only writer.

## Alternatives

| Approach | One-liner | Why not it (as the principle) |
|---|---|---|
| **Single source of truth** (this) | one writable home per fact; everything else links | — |
| **Eventual consistency / replication**[⁴][⁵] | many replicas converge over time | solves serving/availability, not authoring; complementary |
| **System of record vs. system of reference** | one system masters data, others serve curated views | useful at org scale; collapses to "one home" at solo scale |
| **CRDTs / multi-master** | concurrent edits merge automatically | overkill solo — you're the only writer |
| **"The code is the source of truth" (DDD)**[³] | the domain model is canonical | aligned; we generalize beyond code to docs + inbox |

## Sources

[1]: https://en.wikipedia.org/wiki/Single_source_of_truth — SSOT: "every data element is mastered (or edited) in only one place." Accessed 2026-05-31.
[2]: https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions — Michael Nygard, "Documenting Architecture Decisions" (ADRs; one short file per decision). Accessed 2026-05-31.
[3]: Eric Evans, *Domain-Driven Design: Tackling Complexity in the Heart of Software* (Addison-Wesley, 2003) — the domain model as the team's single shared reference.
[4]: https://queue.acm.org/detail.cfm?id=1466448 — Werner Vogels, "Eventually Consistent," ACM Queue 6(6), 2008. Accessed 2026-05-31.
[5]: Martin Kleppmann, *Designing Data-Intensive Applications* (O'Reilly, 2017), ch. 5 "Replication."

## Related

- [ADHD-aware design](./adhd-aware-design.md) — single source of truth is the inbox piece
- [Four-layer memory](./four-layer-memory.md) — same principle, applied to agent memory
- [Chapter 02 — Filesystem conventions](../02-filesystem-conventions/) — one slug format, one layout
