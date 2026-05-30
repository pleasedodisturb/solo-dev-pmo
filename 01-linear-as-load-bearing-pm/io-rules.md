# I/O rules: CLI > MCP locally

> How agents (and humans) read and write to Linear. CLI for reads + simple updates, GraphQL for what CLI lacks, **never** the Linear MCP plugin in local sessions.

This section is a routing doc. It says which tool to reach for in which situation. Without it, agents will pick the wrong tool, bypass rate limits, or write to the wrong workspace.

## The hierarchy

```
Initiative          (3-ish: strategic outcome buckets)
  └── Project       (16+, mostly under one Initiative; continuous areas have no Initiative)
       └── Cycle    (1-week, auto-roll on)
            └── Issue
```

Everything in Linear maps to this hierarchy. Cross-Initiative work is rare and signals a missing Initiative.

## Authentication

Token from your password manager. Never hardcoded, never committed.

For [`rbw`](https://github.com/doy/rbw) (Bitwarden CLI):
```bash
export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key)"
```

Wire this into your shell init (`.zshrc` / `.bashrc`). Agent and CLI alike read from the env var.

Fallback for tools that look for a file: `~/.linear_api_token` (file mode 600). Some CLIs prefer this.

Alternatives: `pass`, 1Password CLI (`op read 'op://Vault/Linear/token'`), `bitwarden-cli` (`bw get item linear-token | jq -r .login.password`). The pattern is the point — secrets at rest in a password manager, exposed to env at session start.

## Tool selection

| Capability needed | First choice | Fallback |
|---|---|---|
| List / search issues | `linearis` (or your tool's CLI) | Direct GraphQL |
| Read a single issue | CLI | GraphQL |
| Create issue (simple) | CLI | GraphQL |
| Update title / desc / status / priority / assignee / project / labels | CLI | GraphQL |
| Set `estimate` | GraphQL | (CLI may not support it) |
| Set `dueDate` | GraphQL | (CLI may not support it) |
| Set `cycleId` | GraphQL | (rarely needed; auto-roll usually) |
| Set `snoozedUntilAt` | GraphQL | — |
| Create / mutate Projects | GraphQL | — |
| Create / link Initiatives | GraphQL | — |
| Use issue template | GraphQL with `templateId` | — |
| Label group manipulation | GraphQL | — |

**Local sessions: ALWAYS use CLI when supported, GraphQL when CLI lacks the field.** Never the Linear MCP plugin (`mcp__plugin_linear_linear__*`).

**Why no Linear MCP plugin locally?**
- It bypasses team filters (can write to any team you have access to)
- It bypasses rate-limit guards (can hit Linear API limits silently)
- It bypasses the CLI's caches
- It separates the I/O patterns between local and cloud sessions, making debugging hard
- Cloud sessions without CLI access *do* use the MCP — it's reserved for that case

If your tool has a CLI (`linearis`, Linear's own `linear-cli`, your own wrapper), use it. If not, use direct GraphQL.

## GraphQL examples (Linear-specific; concepts transfer)

### Querying

Lookup active cycle (every Monday script needs this — never hardcode cycle IDs):

```graphql
query {
  team(id: "<team-uuid>") {
    activeCycle { id number startsAt endsAt }
  }
}
```

Lookup project's UUID by name (build this once and cache locally — names are stable, IDs change rarely):

```graphql
query {
  projects(filter: { name: { eq: "<project-name>" } }) {
    nodes { id name }
  }
}
```

### Creating with template

```graphql
mutation {
  issueCreate(input: {
    teamId: "<team-uuid>",
    projectId: "<project-uuid>",
    templateId: "<agent-autonomous-template-uuid>",
    title: "...",
    priority: 2
  }) { success issue { identifier url } }
}
```

`templateId` references your "Agent-autonomous-ready ticket" template — see [ticket-standard](./ticket-standard.md).

### Updating an estimate

```graphql
mutation {
  issueUpdate(
    id: "<issue-id>",
    input: { estimate: 4 }
  ) { success issue { identifier estimate } }
}
```

### Snoozing

```graphql
mutation {
  issueUpdate(
    id: "<issue-id>",
    input: { snoozedUntilAt: "2026-08-15T00:00:00Z" }
  ) { success issue { identifier snoozedUntilAt } }
}
```

## Required at creation time

For any new ticket via the API:

- `title` — concise, no trailing punctuation, action verb if applicable
- `description` — fill the template (see [ticket-standard](./ticket-standard.md))
- `teamId` — always your default team's UUID
- `projectId` — **never empty.** If unsure which project, pick by domain match
- `priority` — Linear's native scale: 0=None, 1=Urgent, 2=High, 3=Medium, 4=Low

Never use ad-hoc priority labels (`urgent`, `high-priority`). Use the native priority field — these labels were deliberately deleted in setup.

## The Triage bypass

(Covered in [triage-as-inbox](./triage-as-inbox.md) but worth restating here.)

Tickets created via the API with a personal token **bypass Triage** and land directly in Backlog (or wherever `stateId` says). To intentionally route to Triage:

```graphql
mutation {
  issueCreate(input: {
    teamId: "<team-uuid>",
    stateId: "<triage-state-uuid>",
    title: "..."
  }) { success issue { identifier } }
}
```

OAuth-app-installed agents route through Triage by default. If you migrate to OAuth, the explicit `stateId` becomes redundant — but until then, your capture script must set it.

## Label group: `route/*`

Set up a `route` label group with two children (single-select):
- `route/agent` — work an autonomous agent picks up
- `route/human-only` — work explicitly off-limits to agents

Linear's single-select groups enforce mutual exclusion. Setting both is impossible.

Use these instead of standalone `agent` / `human-only` labels — the group structure prevents accidentally setting both during bulk operations.

Other functional labels (multi-select):
- Issue type: `Bug`, `Feature`, `Improvement`
- Quality / process: `quality-management`, `security`, `automation`, `documentation`, `research`, `planning`, `configuration`, `monitoring`, `maintenance`
- Domain tags: project-specific (e.g., `hetzner`, `synology`, `docker`)

What NOT to recreate:
- Priority labels (`urgent`, etc.) — native priority field replaces them
- `enhancement` → use `Feature` or `Improvement`
- Sub-service labels (e.g., `radarr`, `sonarr` for a Plex project) — covered by the project's scope; sub-service labels just clutter

## Cycle assignment

Manual cycle assignment is rare. The pattern:
- **Default:** auto-roll handles unfinished `In Progress` work between cycles
- **Manual exception:** Monday planning may pull a `Backlog` ticket into the current cycle
- **Don't:** manually assign cycles to predict future work — let the cycle plan emerge from Monday planning

When you do assign manually:
```graphql
mutation {
  issueUpdate(
    id: "<issue-id>",
    input: { cycleId: "<active-cycle-uuid>" }
  ) { success issue { identifier cycle { number } } }
}
```

## Snoozed ticket etiquette

Already covered in [snooze-as-hibernation](./snooze-as-hibernation.md). Restating the agent-facing rules:

- **Filter snoozed items out by default.** Use `filter: { snoozedUntilAt: { null: true } }` for "what's actively in play."
- **Don't bulk un-snooze.** Snoozing is deliberate hibernation.
- **Honor wake dates.** Don't query "all open tickets" and treat snoozed ones as actionable.
- **If you must un-snooze one item:** explicit reason in a comment.

## Auto-archive behavior

Closed (Done / Canceled / Duplicate) tickets archive after 1 month. They remain in the DB, just hidden from default views. To surface them:

```graphql
query {
  issues(filter: { state: { type: { in: ["completed", "canceled"] } }, archived: { eq: true } }) {
    nodes { identifier title archivedAt }
  }
}
```

Don't expect stale Done tickets to be visible by default. If you need them, filter explicitly.

## Friday Project Update reminders

Workspace-wide reminders fire weekly on the configured day/time (recommended: Friday 16:00). Two follow-up nudges land 1 and 2 working days later if you skip.

For agents running on Friday after 16:00 in a project with an outstanding update: prompt the user with a one-line "Want me to draft the Friday update for project X?" — don't auto-post without permission. The 3-option health indicator (On Track / At Risk / Off Track) is the format.

## Don't-do list (agent-targeted)

These should be in your agent's project rules or global rules:

- **Never use Linear MCP plugin locally.** CLI is preferred.
- **Never hardcode cycle UUIDs.** Query at runtime.
- **Never hardcode team UUIDs in shared scripts** without env-var fallback (`${LINEAR_TEAM_ID:?required}`).
- **Never bulk un-snooze.** Individual un-snooze with explicit comment only.
- **Never create a ticket without a project.** No orphans.
- **Never create a ticket without an estimate if it's going into a cycle.** Estimate at the gate.
- **Never set Cycle at capture time.** Captures are cycle-less; cycle assignment happens at Monday planning.
- **Never post a Project Update without user approval.** Draft and ask.

## Field-tested gotchas

**`linearis` does not currently accept `templateId` on create.** Workaround: GraphQL for template-based creates, CLI for ad-hoc updates after. Or wrap GraphQL in a `linearis-create-from-template` helper.

**Workspace timezone affects reminder fire times.** Friday 16:00 reminder in a wrong-timezone workspace fires Thursday or Saturday. Check Workspace settings.

**Pre-snoozed items in a list query can include items with past `snoozedUntilAt`** if you don't filter properly. The filter is `snoozedUntilAt is null OR snoozedUntilAt < now` for "actively in play"; just `snoozedUntilAt is null` excludes correctly-awake items.

**Bulk operations need a sleep between requests.** Linear's API rate limit is generous but not unlimited. Sleep ~100-200ms between writes for bulk passes.

**Reading a ticket via CLI uses your CLI's cache.** If you read, then a webhook updates the ticket, then you read again, you may get the stale cached version. CLIs vary; check yours. GraphQL never caches.

## Mapping for other tools

If you use Plane, Height, Tracker, or GitHub Projects:

| Linear concept | Plane | Height | GitHub Projects |
|---|---|---|---|
| Initiative | Module group | (workspaces) | (no equivalent) |
| Project | Module / Project | List | Project board |
| Cycle | Cycle | Sprint | Iteration field |
| Issue | Issue | Task | Issue / PR |
| Triage state | (custom state) | Inbox | (custom column) |
| Snooze | (no native; defer field) | (no native) | (no native; use draft) |
| Estimate scale | Configurable | Story points | Custom field |
| Auto-roll | (no native) | (no native) | (no native) |

The patterns transfer; implementations vary. For tools without snooze or auto-roll, simulate with labels + scripts.

## Related

- [Triage as inbox](./triage-as-inbox.md) — bypass behavior
- [Ticket standard](./ticket-standard.md) — template structure
- [Snooze as hibernation](./snooze-as-hibernation.md) — `snoozedUntilAt` semantics
- [Chapter 03 — MCP routing](../03-claude-code-as-operator/mcp-routing.md) — why CLI beats MCP locally (general principle)
- [Chapter 05 — Secrets via password manager](../05-secrets-and-secure-defaults/bitwarden-via-rbw.md) — token storage
