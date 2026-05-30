# Agent-autonomous-ready ticket template

Copy this into your PM tool's issue template (Linear: Settings → Team → Templates → Issue templates).

---

## Problem / Goal

<What's broken or what we're building. WITH EVIDENCE — logs, screenshots, data. "Fix bug" is not a goal; "Pass rate spikes to 27% when healthy is 5-8%; output of <command> attached" is.>

## Context

<Why this matters now. What triggered it. Upstream / downstream dependencies. Other tickets it relates to.>

## Acceptance Criteria

<Numbered, testable, binary. Each AC verifiable by running a command or checking a condition.>

1. <AC>
2. <AC>
3. <AC>

## Verification Commands

<Exact shell commands or queries. Agent runs these to confirm success.>

```
<command 1>
<command 2>
```

Expected outputs (where deterministic):
- <command 1> → <expected line / value>

## Files to Investigate / Modify

- `<path>` — <what to look for / change>
- `<path>` — <what to look for / change>

## Constraints (what NOT to break)

- <Backward-compat requirement>
- <Performance budget>
- <Related system that must keep working>

## Definition of Done

- [ ] Code fix applied
- [ ] Tests pass locally (`<test command>`)
- [ ] Commit with ticket ID prefix
- [ ] PR opened against `main`
- [ ] PR review per global standard
- [ ] Status moved to `In Review`, then `Done` on merge

## Execution Metadata

- **Scope:** S (< 30m) / M (30m-2h) / L (2+h, consider splitting) — pick one
- **Parallel-safe:** yes / no (and if no, list conflicting tickets)
- **Worktree:** recommended / required / not-needed
- **Depends on:** <ticket IDs that must merge first>
- **Branch from:** main (default) / <feature branch>
- **PR target:** main (default) / <feature branch>

## Test Requirements

- **Run before starting:** `<baseline test command>`
- **Write tests for:** <specific code; e.g., "unit test for apply_hard_caps() with 5 cap-rule scenarios">
- **Run after fix:** `<post-fix test command>`
- If no tests needed (docs / config): write explicitly "No tests required"

## Environment Prerequisites

<Skip if none.>

- Servers to start: `<command>`
- Migrations: `<command>`
- API keys / secrets: `<which from password manager>`
- Special deps: `<e.g., needs Docker running>`

## Stop Conditions

You are DONE when:
- All AC satisfied (run verification commands)
- PR opened, review trailer added
- <Other DoD items>

Do NOT also:
- <Adjacent temptation 1>
- <Adjacent temptation 2>

Token budget: <S = under 50k / M = under 150k / L = under 300k>

---

## Agent self-verify (paste output before closing)

```
$ <verification command 1>
<paste>

$ <verification command 2>
<paste>

$ git diff --stat main...HEAD
<paste>
```
