# Agent rules

> When to spawn a subagent vs. work inline. How to budget tokens. When to stop.

The agentic-coding tool gives you two execution modes:
1. **Inline** — work happens in the main session, you see every step
2. **Subagent** — spawn an isolated context, agent works, returns a final message

Choosing between them is the highest-leverage agent decision. Get it wrong and you either burn tokens on coordination (over-spawning) or burn tokens on context bloat (under-spawning).

*Checked 2026-05-31 against Claude Code v2.1.158.* The spawning tool was **renamed `Task` → `Agent` in v2.1.63** (old `Task(...)` still aliases).[¹] A subagent "starts with a fresh, isolated context window — it does not see your conversation history, the skills you've invoked, or the files Claude has read," and only a summary returns to the parent, leaving the parent's cache prefix intact.[¹] Subagents **cannot spawn subagents.** Built-ins worth knowing: **Explore** (Haiku, read-only, skips CLAUDE.md to stay small), **Plan** (read-only), **general-purpose** (all tools). Per-subagent `model:` accepts `sonnet|opus|haiku|inherit` (default inherit); **foreground blocks and forwards permission prompts to you, background runs concurrently and auto-denies anything that would prompt.**[¹]

## When to spawn a subagent

Spawn when:

- **Work consumes more than 20% of the main session's projected context budget.** Subagents have their own context.
- **Work touches files unrelated to the current main-session focus** — a tangential research detour. Keep main lean.
- **Two or more independent investigations can run concurrently** — parallelize.
- **Background research that doesn't block the main thread.**
- **Work needs isolated permissions** — tighter allowlist than the current project's.
- **Long-running phase execution** — spawn from inside a `git worktree` so parallel branch switches don't poison main.

## When NOT to spawn

Stay inline when:

- **One-file edits with clear context** — spawning adds round-trip latency and handoff cost.
- **Anything requiring shell tools (CLI browser tools, Bash)** — background agents lack permission inheritance for CLI commands in many setups.
- **Cross-machine work** (Mac Mini target from MacBook session, or vice versa) — must run on the target host.
- **Destructive operations** (mass file deletion, git history rewrite) — keep inline so a human can interrupt before damage.
- **PM tool ticket creation** — keep inline so each ticket is reviewed before filing (per [never-defer](../01-linear-as-load-bearing-pm/never-defer.md)) AND so CLI rate-limit guards see writes serialized.

## Specialized agents

One-line catalog of common specialized agents you might invoke:

| Agent | Purpose |
|---|---|
| `gsd-planner` | Translates phase CONTEXT.md + RESEARCH.md into PLAN.md |
| `gsd-executor` | Executes a PLAN.md atomically, commits per task, writes SUMMARY.md |
| `gsd-verifier` | Phase verification, goal-backward audit against PLAN's must-haves |
| `gsd-debugger` | Investigation / bug-hunt mode; reads code without writing |
| `gsd-researcher` | Research-heavy survey work |
| `gsd-phase-researcher` | Research aggregation for a specific phase |
| `gsd-project-researcher` | Broader project-wide research |
| `gsd-doc-writer` | Drafts documentation |
| `gsd-code-fixer` | Applies a targeted code fix |
| `gsd-code-reviewer` | Code + security review pass |
| `gsd-security-auditor` | Security-focused review |
| `gsd-plan-checker` | Pre-execution audit of PLAN.md |
| `gsd-integration-checker` | Post-execution audit that artifacts integrate |
| `gsd-codebase-mapper` | Produces code map for unfamiliar repo |
| `ticket-worker` | Implements a single ticket end-to-end in isolated worktree |

Use specialized agents when their name matches the task; reach for a generic Task spawn otherwise.

## Token-budget rules

| Tier | When | Models |
|---|---|---|
| SIMPLE | Classification, keyword extraction, formatting | Haiku, small models |
| STANDARD | Generation, analysis | Sonnet |
| COMPLEX | Deep reasoning, multi-step planning | Opus |

- **WebFetch before browser tools** — cheaper and faster than Playwright / BrowserMCP for read-only.
- **Prompt caching headers** when calling Anthropic API directly — `cache_control: {"type": "ephemeral"}` on system blocks for 90% cost reduction on repeated prompts.
- **Batch non-urgent work** via Batch API (50% discount) — discovery sweeps, bulk scoring.
- **Open-source models via Together.ai** for simple tasks — no middleman markup.
- **Capture token usage from every API response** — when writing or modifying provider code, extract and pass through `TokenUsage` (input/output/cache tokens).

## Subagent economics (Q03.25)

There is **no documented hard per-subagent token cap** — guidance is proportional, not a fixed budget.[¹] The numbers that matter:

- Anthropic's multi-agent research system used **~15× more tokens than a single chat**, and **token usage alone explained ~80% of the performance variance** on their eval — spawning helps when "the question is large, the directions are independent, and the answer is worth a lot of tokens."[²]
- Claude Code's own docs measure **agent teams at ~7× the tokens** of a standard session, because each teammate keeps its own context window.[³]

So the spawn decision is an economic one: parallelism buys wall-clock and isolation but costs a multiple of the tokens. Defaults that keep it sane: **Sonnet (or Haiku) for teammates, not Opus; keep teams small (cost ≈ team size); focused spawn prompts** (teammates auto-load CLAUDE.md + MCP + skills, so a fat global config taxes every spawn); clean up idle teammates. `maxTurns` in agent frontmatter is the indirect cap.[¹] These are the evidence behind the chapter's S/M/L heuristics below, not replacements for them.

## Cost and cache-hit accounting (Q03.26–Q03.27)

You can't optimize spawn economics without measuring them. The 2026 toolchain:

- **`/usage`** (the `/cost` successor) shows per-session tokens + a local dollar estimate, and on paid plans **attributes spend to individual skills, subagents, plugins, and MCP servers** as percentages.[³]
- **OpenTelemetry** (`CLAUDE_CODE_ENABLE_TELEMETRY=1`) exports `claude_code.cost.usage` and `claude_code.token.usage` broken down by `skill.name` / `plugin.name` / `agent.name` — the org-wide path.[⁴]
- **Admin API** (`/v1/organizations/cost_report`, `/usage_report/claude_code`) for per-user aggregates; **`ccusage`** parses local JSONL logs with no API access.[⁴]

**Cache-hit hygiene is the cheapest cost lever.** Claude Code caches automatically with the stable-prefix order *system prompt → CLAUDE.md + memory → conversation*; an exact-prefix match is required, so anything that changes an early block recomputes everything after it.[⁵] **Helps:** pick model, effort level, and MCP servers at session *start*; save `/compact` for natural breaks; use `/rewind` (truncates to a cached prefix). **Hurts:** switching model/effort mid-session, MCP connect/disconnect, `/compact`, upgrading Claude Code. Watch `cache_read_input_tokens` (~0.1× rate) vs `cache_creation_input_tokens` in a statusline — a high read:creation ratio is healthy.[⁵] Editing CLAUDE.md mid-session is cache-safe but **won't take effect until restart/compact.**[⁵]

## Subagents in other tools (Q03.21)

Not every operator agent has this lever. **Codex** has subagents and **Cursor** has cloud Background Agents; **Aider, Cline, and Continue are single-context** — there the "spawn vs inline" decision collapses to "always inline," so you manage main-context bloat by hand. Full matrix in [agent-platform-portability](./agent-platform-portability.md).

## Worktree / branching rules

- **Long workflows use `git worktree`.** Spawn at the start of any plan-phase / execute-phase / autonomous flow, before the first commit, so parallel branch switches in main don't poison.
- **Branch naming: `<ticket-id>/<short-description>`.** Branches without ticket prefix rejected at review.
- **Every commit references a ticket** — prefix with ticket ID so `git log --grep="G-97"` finds it. Body explains what + why.
- **PR per branch, base off `main`** unless explicitly working off a feature branch. Branching off long-running feature branch and PR'ing to main produces unreviewable diffs.
- **Never force-push to main / master, never `git update-ref` a protected branch.** Absolute prohibitions. If HEAD has drifted onto a protected ref inside a worktree, HALT rather than self-recover.

## Stop conditions

The agent halts (returns to human) when:

- **Dead-man counter hits 500** — session is hard-capped. Reset procedure documented separately.
- **Pre-flight check fails** (e.g., `docker ps` doesn't respond for a sandboxed run) — halt with blocker; don't paper over missing prereq.
- **User decision required** and `--interactive` not passed — write clear blocker to SUMMARY (gate type `human-action`, exact verification command) and halt. Never guess on a Rule 4 architectural decision.
- **Architectural change discovered mid-execution** — Rule 4 of the deviation rules. Stop, return a checkpoint, wait for user decision. Do not implement major structural changes autonomously.
- **Package install failed** for a referenced npm/pip/cargo package — checkpoint with `gate="blocking-human"`. A failed install may indicate a slopsquatted or hallucinated package name; never auto-substitute an alternative.

## The Rule 4 escalation

If the agent encounters an "architectural decision" it didn't have when planning:
- Stop
- Document the unforeseen choice
- Surface as a checkpoint with options + recommendations
- Wait for human

This is the most important rule. Without it, agents make unilateral architectural calls that are expensive to undo.

## Sandbox vs unsandboxed

Many setups run agents in a sandboxed mode (e.g., file write restricted to `.planning/` and the repo only; Bash restricted to a allowlist).

Use sandbox by default. Lift sandbox only when:
- Task requires writes outside the repo (rare; usually a sign of a bad task spec)
- Task requires shell ops not in allowlist
- You explicitly approve

Sandboxed agents that fail "I can't write to X" are signaling that X shouldn't be in the work. Resolve at the spec, not by lifting sandbox.

## Field-tested gotchas

**Agent over-spawning.** Spawning 5 subagents for a 3-file task is slower than inline. The handoff cost (each subagent loads context, runs, summarizes) exceeds the savings for small tasks.

**Agent under-spawning.** Doing a 30-file refactor inline blows main context. Spawn a `gsd-executor` instead.

**Parallel subagents that touch the same files.** Race condition. Mark tasks `parallel-safe: no` in tickets; agent checks before spawning.

**The "I'll just check one more thing" agent drift.** Agents told "investigate X" sometimes wander into "and Y looks interesting." Stop conditions in the prompt prevent this.

**Token budgets exceeded.** S = stay under 50k, M = under 150k, L = under 300k. Agents that blow these had bad ticket specs (no scope, no AC).

**Agent confidence misleading.** Agents will confidently produce broken code. Trust-but-verify on every action.

## Innovative pattern: agent-self-verify footer

Every agent ends its work with a self-verify block:

```
## Self-verify (paste output)

$ <verification command>
[paste]

$ git diff --stat main...HEAD  
[paste]
```

You skim the comment instead of re-running. Trust-but-verify at a glance.

## Innovative pattern: dead-letter queue for blocked agents

Agents that hit a blocker write to `.planning/blocked.md` with the blocker details. A daily script:
- Reads blocked.md
- Files PM tool tickets for each entry (one ticket per blocker, agent-autonomous-ready spec)
- Notifies via ntfy

Blocked work doesn't get forgotten; it routes to your inbox.

## Innovative pattern: agent telemetry per session

Each agent run logs:
- Ticket ID worked on
- Token consumption (input / output / cache)
- Tool calls per type
- Time to complete

Aggregate weekly. Identify expensive-vs-cheap agent patterns. Cost optimization data without per-call overhead.

## Related

- [MCP routing](./mcp-routing.md) — which tools agents use
- [Skills and hooks](./skills-and-hooks.md) — how agents are invoked
- [Agent-platform portability](./agent-platform-portability.md) — subagent models in other tools
- [Chapter 06 — Session discipline](../06-session-discipline/) — what agents commit and how
- [Chapter 01 — Ticket standard](../01-linear-as-load-bearing-pm/ticket-standard.md) — Execution Metadata feeds agent decisions
- [sources.md](./sources.md) — full bibliography

---

[¹]: https://code.claude.com/docs/en/sub-agents — accessed 2026-05-31
[²]: https://www.anthropic.com/engineering/multi-agent-research-system — accessed 2026-05-31
[³]: https://code.claude.com/docs/en/costs — accessed 2026-05-31
[⁴]: https://code.claude.com/docs/en/monitoring-usage ; https://platform.claude.com/docs/en/api/admin/cost_report — accessed 2026-05-31
[⁵]: https://code.claude.com/docs/en/prompt-caching — accessed 2026-05-31
