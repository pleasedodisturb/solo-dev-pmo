# Extraction sheet

Provenance overview: where the patterns in this repo came from and what shape the source material took.

This file exists so future maintainers (or readers curious about the origin of a claim) can understand the synthesis process. The actual personal source repository has been redacted; what's preserved is the pattern-to-source-type map.

## Source types

The patterns in this playbook were extracted from one solo developer's working setup. The originating material lived in five places:

- **Global agent instructions** — a `~/.claude/CLAUDE.md` file (~200 lines, Layer 1) + ~13 sibling reference docs at `~/.claude/docs/*.md` covering specific topics (PM tool I/O rules, browser tooling, MCP routing, agent rules, ticket standard, never-defer rule, PR review standard, repo bootstrap, etc.)
- **Project-level rules** — a `CLAUDE.md` at the meta-PM repo's root (Layer 2)
- **Auto-memory** — Layer 3 files at `~/.claude/projects/<encoded-path>/memory/` capturing feedback (lessons learned), project state, and references
- **Audit log** — dated `audits/YYYY-MM-DD-<slug>.md` files in the meta-PM repo, recording each session that changed the PM tool's state or executed a migration step
- **Conventions** — locked `conventions/<topic>.md` files in the meta-PM repo, edited in-place when rules change

The combination of all five was the substrate for this playbook.

## Pattern → source-type map

### Principles (00)

| Pattern | Source-type |
|---|---|
| ADHD-aware design framing | Auto-memory (feedback) |
| Four-layer memory architecture | Global agent instructions |
| Single source of truth | Cross-cut from auto-memory + global PM I/O rules |
| Calendar-vendor-neutrality | Auto-memory (feedback) |
| Evidence grading + peer-reviewed ADHD citations | New (P00 research-grounding pass — peer-reviewed literature, with explicit hedging where the source claims were practitioner lore) |

### Linear as load-bearing PM (01)

| Pattern | Source-type |
|---|---|
| 1-week cycles, Mon→Sun, auto-roll | Audit log (research session grounded in Linear primary docs) |
| Cooldown every 4th week | Same |
| Friday 16:00 Project Update reminders | Same |
| Cycle WIP cap = 5, max 2 P0+P1 | Same |
| Triage as inbox | Same |
| Triage bypass for API-created tickets | Global agent instructions (PM I/O rules doc) |
| `snoozedUntilAt` semantics | Same |
| Bulk-snooze backlog pattern | Audit log (described in research session) |
| Exponential estimate scale 1/2/4/8/16 | Audit log (research session) |
| The 16-pointer as stop sign | Same |
| WIP cap on push projects + continuous-area exempt | Auto-memory (feedback memory documenting an audit correction) |
| Agent-autonomous-ready ticket 7-section standard | Global agent instructions (ticket standard doc) |
| Execution metadata (Scope, Parallel-safe, Worktree, etc.) | Same |
| CLI > MCP for PM tool locally | Global agent instructions (PM I/O rules doc) |
| Initiative → Project → Cycle → Issue hierarchy | Same |
| Never-defer ticket creation | Global agent instructions (never-defer doc) |

### Filesystem conventions (02)

| Pattern | Source-type |
|---|---|
| Layout B subfolder categories | Project conventions doc |
| 10 category subfolders | Same |
| Slug format rules (lowercase + `-`, ASCII, no `--`) | Same |
| `-temp` exemption | Same |
| Worktree at `~/.claude/worktrees/<repo>/<branch>/` | Same |
| `repo: <slug>` first-line tag in PM tool project description | Same |
| Multi-`repo:` lines for multi-repo families | Same |
| Top-level exception (the meta-PM repo) | Same |
| Grandfathered TitleCase exception removal narrative | Audit log |
| `upstream/` category addition | Audit log |
| Post-rename cleanup checklist | Global agent instructions (repo-bootstrap doc) |

### Claude Code as operator (03)

| Pattern | Source-type |
|---|---|
| 4-layer memory architecture detail | Global agent instructions |
| Memory cap rules (Layer 1 ≤ 200, Layer 3 ≤ 150) | Same |
| The 4 memory types (user/feedback/project/reference) | Same |
| CLAUDE.md template | Global agent instructions (repo-bootstrap doc) |
| Don't commit CLAUDE.md to other people's repos | Same |
| MCP routing table | Global agent instructions (MCP routing doc) |
| WebFetch > Playwright > specialized | Same |
| Browser tool ranked tier list | Global agent instructions (browser-tools doc) |
| BrowserMCP authenticated host caveats | Same |
| CloakBrowser sandbox-only rule | Same |
| Never `--stealth` Obscura on macOS | Same |
| TLS fingerprinting dominance | Same |
| Agent spawn rules | Global agent instructions (agent-rules doc) |
| Specialized agent catalog | Same |
| Token-budget tiers (S/M/L) | Same |
| Worktree + branch + commit + PR rules | Same |
| Stop conditions | Same |
| Rule 4 escalation (architectural change mid-execution) | Same |

### Rituals and triggers (04)

| Pattern | Source-type |
|---|---|
| launchd over cron rationale | Global agent instructions + general macOS knowledge |
| ntfy as Apple-Push-free alternative | Auto-memory (feedback) + project CLAUDE.md |
| Plaintext schedule.md + iCal export | Auto-memory (feedback) |
| Monday planning script structure | New synthesis (composed from audit + cycle research) |
| Friday retro = Linear Project Update + nudges | Audit log (Linear research session) |

### Secrets and secure defaults (05)

| Pattern | Source-type |
|---|---|
| Password-manager-CLI pattern (rbw / pass / op / etc.) | Global agent instructions |
| Once-per-24h unlock | Same |
| Tokens to env via `.zshrc` | Same |
| Alternative password managers documented | New (broadened from the source's rbw-specific recipe to a general pattern) |
| SSH agent backed by password manager | Global agent instructions |
| File-path signing > `key::` literal | Global agent instructions (post-rename cleanup section) |
| Never commit secrets — pre-commit + pre-push hooks | Global agent instructions (PR review standard) + new pre-commit recipe |
| Recovery procedure (rotate first, clean up second) | New synthesis |

### Session discipline (06)

| Pattern | Source-type |
|---|---|
| Commit cadence rules | Global agent instructions |
| Every commit references a ticket | Same |
| Push after committing on feature branches | Same |
| Thorough commit messages | Same |
| PR review checklist (code + security) | Global agent instructions (PR review standard) |
| `Reviewed-by:` trailer + global pre-push hook | Same |
| Audits = dated, conventions = locked-in-place | Project conventions + project CLAUDE.md |
| Wrap and resume pattern | Global agent instructions + general session-skill knowledge |

### Cheatsheets (07)

| Pattern | Source-type |
|---|---|
| `cheat <topic>` shell function | Global agent instructions (cheatsheet discipline doc) |
| Cheatsheet maintenance discipline | Same |
| When to add to cheatsheets vs memory vs nothing | Same |

## Sanitization process

The original source material referenced specific personal identifiers (the developer's name, PM workspace name, team UUID, specific project names, ticket IDs, dates, password-manager entry names, ntfy topics, hardware specifics, and a specific phone OS choice). All of these were replaced with placeholders during extraction:

| Type of identifier | Replaced with |
|---|---|
| Workspace name | `<your-workspace>` |
| Team key / UUID | `<TEAM>` / `<team-uuid>` |
| Project names | `<bounded-project>`, `<continuous-area>`, or neutral example names (`app-foo`, `app-bar`, etc.) |
| Ticket IDs | Illustrative `G-XXX` / `G-1234` placeholders |
| Cycle UUIDs | "query at runtime, do not hardcode" |
| ntfy topic | `<your-ntfy-topic>` |
| Template UUID | `<...-uuid>` placeholders |
| Username | `<u>` / `YOU` in paths; `<your-name>` in prose |
| Email | `<your-email@example.com>` |
| Hardware specifics | Generalized to "non-Apple non-Google phone" / "dedicated agent runner" / etc. |
| Specific dates | Kept where they're "audit illustration"; generalized where they'd date the doc unhelpfully |

The published recipe stays transferable; the personal context stays in the original source.

## What was deliberately included (novel content)

Beyond the source patterns:

- **Evidence-and-citations grading** ([`00-principles/evidence-and-citations.md`](./00-principles/evidence-and-citations.md)) — a P00 research pass that grades each empirical ADHD claim against the peer-reviewed literature (tiers A/B/C), grounds the well-supported ones, and explicitly flags the practitioner-lore ones (notably the anti-streak rationale) rather than asserting them. The original source material made these claims without citation; this pass added the provenance and the hedges.
- **Innovative pattern callouts** at the end of each section — extensions that flow from the source patterns but weren't in the originals
- **Field-tested gotcha callouts** — reframed from audit history into transferable lessons
- **Competitor analysis** in the top-level README — synthesized from a landscape audit done as part of this extraction
- **"What this rules in / rules out" framing** — restructures the patterns into action vs. prohibition
- **Chapter ordering** (Principles → PM → Filesystem → Operator → Rituals → Secrets → Discipline → Cheatsheets) — a deliberate read-top-to-bottom narrative

## Related

- [credits.md](./credits.md) — external sources and adjacent repos
- [SANITIZATION-SCAN.md](./SANITIZATION-SCAN.md) — recipes for scanning your own fork before publishing
