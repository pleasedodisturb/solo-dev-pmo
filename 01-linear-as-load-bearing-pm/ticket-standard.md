# Agent-autonomous-ready ticket standard

> Every ticket must be pickup-able with only the ticket ID. If an agent (or your future self) needs context outside the ticket to make progress, the ticket is incomplete.

This is the most opinionated section of this chapter and the most field-tested. It's also the one with no published equivalent I found in the [landscape audit](../).

## The contract

A ticket is "agent-autonomous-ready" when:

1. **An autonomous agent, given only the ticket ID, can complete the work without asking questions.**
2. **You, opening the ticket 6 weeks from now with zero context, can complete the work without asking questions.**

If either fails, the ticket isn't done — even if work was completed. Half-spec tickets that "worked anyway" are landmines for the next time something similar comes up.

## The 7 required sections

Every actionable ticket has these. Templates make this enforceable — set up an issue template in your tool and use it for every create.

### 1. Problem / Goal (with evidence)

What's broken or what we're building. **With evidence** — logs, screenshots, data, output.

> ❌ "Fix scoring bug"
> ✓ "Scoring pass rate is 27% when healthy is 5-8%. Output of `python -m scorer.diagnose` attached below shows top-5 candidate rules are misweighted; specifically rule_id=14 weights at 0.6 should be ≤ 0.2."

The evidence proves the problem exists and gives the agent something to verify against.

### 2. Context (why now)

Why this matters. What triggered it. Upstream / downstream dependencies.

> "This issue blocks the daily scan cron (G-583); the scan is set to pause when pass rate exceeds 15%. Other dependent flows: email digest, dashboard widget."

Context prevents the "yes this is broken but is it worth fixing?" question. The agent doesn't have to make that judgment.

### 3. Acceptance Criteria (numbered, testable, binary)

Each AC must be verifiable by running a command or checking a condition. "Works better" is not an AC.

> 1. Pass rate for daily scan is between 3-10% (run: `python -m scorer.test --daily`).
> 2. No regression in `pytest tests/scorer/` (all 47 tests pass).
> 3. New unit test for `apply_hard_caps()` covers ≥5 cap-rule scenarios.

Binary. Either the command passes or it doesn't. No interpretation.

### 4. Verification Commands

Exact shell commands or queries. The agent should be able to run these and confirm success without judgment.

> ```
> pytest tests/scorer/ -v
> python -m scorer.test --daily --output /tmp/test-results.json
> jq '.pass_rate' /tmp/test-results.json   # should be 0.03-0.10
> ```

Including expected outputs (where deterministic) is even better.

### 5. Files to Investigate / Modify

Specific paths and what to look for in each.

> - `src/scorer/rules.py` — rule_id=14 weight definition near line 87
> - `src/scorer/aggregator.py` — applies the rule weights; check the `apply_hard_caps()` call
> - `tests/scorer/test_rules.py` — add test case here for new behavior

This lets the agent skip the discovery phase. For "investigate" tickets where files aren't yet known, list the *likely* starting points.

### 6. Constraints (what NOT to break)

Backwards compatibility, performance budgets, related systems that must keep working.

> - Don't break `pytest tests/integration/` — the dashboard depends on the current API shape.
> - `apply_hard_caps()` is called in 3 other places (see `git grep apply_hard_caps`). Behavior change here must update all callers OR be backward-compatible.
> - Daily-scan duration budget: < 90s; this fix must not increase runtime.

Constraints are landmines made explicit.

### 7. Definition of Done (checklist)

What needs to be checked before the ticket can close.

> - [ ] Code fix applied + tests pass locally
> - [ ] Commit with ticket ID prefix
> - [ ] PR opened against main
> - [ ] PR review (per `~/.claude/docs/pr-review-standard.md`)
> - [ ] Linear status moved to `In Review`, then `Done` on merge

Standardized DoD makes "is this really done?" decidable.

## Execution Metadata (for orchestration)

Beyond the 7 sections, the ticket carries metadata that tells an agent *how* to approach the work:

| Field | Values | Use |
|---|---|---|
| **Scope** | S (< 30 min), M (30 min - 2 hr), L (2+ hr — consider splitting) | Maps to estimate; also a token budget hint |
| **Parallel-safe** | yes / no — and if no, list conflicting tickets | Lets multiple agents run safely |
| **Worktree** | recommended / required / not-needed | Required when parallel execution might happen |
| **Depends on** | List of ticket IDs (`G-XXX`) that must merge first | Prevents agents building on uncommitted work |
| **Branch from** | `main` (default) or feature branch | Override only when chaining |
| **PR target** | `main` (default) or feature branch | Where the PR lands |

## Test Requirements

Even simple. Three fields:

- **Run before starting:** exact command to verify baseline (e.g., `pytest tests/test_scorer.py -v`)
- **Write tests for:** which new code (specific, not "add tests")
- **Run after fix:** exact command to verify nothing broke

If no tests needed (docs change, config update), write that explicitly: *"No tests required — docs only."* Silence is not consent.

## Environment Prerequisites

Skip if none. Otherwise:

- **Servers to start** (e.g., `uvicorn app.main:app --port 8000`)
- **Migrations to run** (e.g., `alembic upgrade head`)
- **API keys or secrets** (e.g., "needs OPENAI_API_KEY from password manager")
- **Special dependencies** (e.g., "needs Docker running for sandbox-test")

The agent can run these without asking. Skipping this field means the agent has to discover them by failure.

## Stop Conditions

Explicit "you are DONE when..." + token budget.

> *"You are DONE when:
> - All 3 AC are satisfied (run verification commands).
> - PR is opened and review trailer present.
> Do NOT also: refactor adjacent rules (separate ticket), improve test framework (separate ticket), rewrite the scorer in TypeScript (very separate ticket).*
> *Token budget: stay under 80k tokens."*

Stop conditions prevent scope creep. Token budgets prevent runaway agents. Without these, agents wander.

## Optional sections

Add when valuable:

- **Input / output examples** — before/after state for the change
- **Root cause hypotheses** (ranked by likelihood) — if it's a bug investigation
- **Related tickets** — links to upstream / downstream
- **Pre-flight checklist** — verify branch clean, deps installed, etc.

## Project linking (non-negotiable)

Every ticket MUST be linked to a project. No orphans. From the project linking rule:

If a ticket doesn't fit any existing project, either:
1. Create a new project for the domain, OR
2. Explicitly note in the description: "Standalone — no project" with a reason.

Set the project in the same operation as the create. Don't create-then-link — half of those never get linked.

## The completeness contract

Before any ticket leaves Backlog (i.e., before it enters a cycle or gets assigned), verify:

1. Project linked
2. All 7 required sections filled
3. Execution metadata present
4. Test requirements specified
5. Stop conditions defined

Tickets failing this contract stay in Backlog until completed. Incomplete tickets in a cycle waste agent tokens and produce bad output.

**Exception:** epics and tracking-only tickets (e.g., "Follow up: Company X") don't need Verification Commands or Files to Modify, but still need Project, AC, and DoD.

## Anti-patterns (never write tickets like this)

- ❌ "Fix the bug" — which bug? where? how do we know it's fixed?
- ❌ "Improve scoring" — improve how? target? acceptable?
- ❌ "Update docs" — which? what changed? new truth?
- ❌ Tickets that require reading a conversation transcript to understand
- ❌ No scope estimate — agent burns 200k tokens on a 20-line fix
- ❌ No stop conditions — agent "improves" adjacent code, introduces bugs
- ❌ No test requirements — agent skips tests, fix breaks silently
- ❌ No project linked — orphans get lost, no domain filtering, no project progress

## Field-tested gotchas

**Filling the template at 80% feels productive but ships landmines.** The missing 20% is always "verification commands" or "stop conditions" — and those are exactly what stops an agent from going off the rails. Strictly: if a field would be empty, write the explicit rationale ("No tests required — docs only"). Silence is ambiguous.

**The "I'll add the AC when I pick this up" plan never holds.** You won't. The AC needs to exist at file-time to be useful as a contract. If you don't know the AC yet, you're not ready to file the ticket — you're ready to file a spike instead.

**Agents take Verification Commands literally.** If your verification command produces output the agent can't interpret, it'll "succeed" on the command exit code and miss a regression. Pair verification commands with expected outputs (where deterministic) or grep for an expected line.

**Scope estimate L (16+) means break it up, NOT "throw a bigger budget at it."** If an agent burns through a 300k-token budget on an L ticket, the ticket was broken, not the agent. See [estimates-exponential](./estimates-exponential.md).

## Innovative pattern: the "self-verify" footer

End every ticket with a self-verification block the agent can include in its final comment:

> ```
> ## Agent self-verify (paste output)
> 
> $ <verification command 1>
> [paste]
> 
> $ <verification command 2>
> [paste]
> 
> ## Diff summary
> $ git diff --stat main...HEAD
> [paste]
> ```

The agent fills this on close. You skim the comment instead of re-running verification yourself. Trust-but-verify at a glance.

## Innovative pattern: paired tickets for spike → implementation

When a ticket starts as "investigate X," split into two from the start:
- **Spike ticket** — research, no AC beyond "produce a recommendation"
- **Implementation ticket** — depends-on the spike, AC = "apply the recommendation"

The pairing makes the spike → implementation flow explicit. Without it, spike tickets sprawl ("now I'll also fix it...") and lose the breakpoint where you'd normally pause for a human decision.

## Related

- [I/O rules](./io-rules.md) — how to create/update tickets via CLI / GraphQL
- [Never defer](./never-defer.md) — file the full ticket NOW, not later
- [Estimates: exponential](./estimates-exponential.md) — Scope ↔ Estimate mapping
- [PR review standard](../06-session-discipline/pr-review-standard.md) — what DoD checklist references
