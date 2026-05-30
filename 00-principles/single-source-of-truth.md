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

## Related

- [ADHD-aware design](./adhd-aware-design.md) — single source of truth is the inbox piece
- [Four-layer memory](./four-layer-memory.md) — same principle, applied to agent memory
- [Chapter 02 — Filesystem conventions](../02-filesystem-conventions/) — one slug format, one layout
