# Wrap and resume

> Every session ends with `/wrap` writing a handoff doc. Every session starts with the handoff loaded into context. Sessions don't lose continuity.

## The pattern

```
session end:
  /wrap → writes NEXT-AGENT-PROMPT.md + docs/sessions/<date>-<slug>.md + updates MEMORY.md

session start:
  SessionStart hook reads NEXT-AGENT-PROMPT.md + latest session doc → injects into context
```

The next session has full context of where you (or the agent) left off. No 10-minute "what was I working on?" rediscovery.

## What `/wrap` writes

### `NEXT-AGENT-PROMPT.md`

Top-level handoff doc the next session reads. Short, action-oriented.

```markdown
# Next Session Handoff

## Status as of <date>

<2-3 sentence summary of where things stand.>

## What's done

- <bullet>
- <bullet>

## What's in progress

- <ticket id> <description> — <current state>

## Blockers / open questions

- <question 1>
- <question 2>

## Next session should:

1. <Specific next action>
2. <Specific next action>

## Files of interest

- <path> — <why>
- <path> — <why>

## Linked tickets

- <ticket id> — <one-line>
```

Read in 30-90 seconds. Action items first.

### `docs/sessions/<date>-<slug>.md`

Per-session log. More detail than NEXT-AGENT-PROMPT, less than an audit.

```markdown
# Session: <slug>

Date: <date>
Duration: <approx>
Branch: <branch>
Ticket: <ticket id>

## What I did

<More detailed than the handoff. Step-by-step or block-by-block.>

## Decisions

<Why I picked X over Y.>

## Surprises

<What I learned that I didn't expect.>

## Followups filed

- <ticket id> — <why>
- <ticket id> — <why>

## Status at end

<Where things stand. What's the next handoff.>
```

Useful for "I want to remember what happened on the day I worked on ticket G-732."

### `MEMORY.md` updates

If anything from the session is worth surfacing every future session, update MEMORY.md:

- New entry in the index pointing at a new memory file
- Updated state in `project_priorities.md`
- New `feedback_<topic>.md` capturing a lesson learned

The index always reflects the most current state.

## What SessionStart reads

A SessionStart hook script:

```bash
#!/usr/bin/env bash
# ~/.claude/scripts/session-start-context.sh
# Output is injected into Claude Code's context at session start

# 1. The handoff (always)
if [ -f NEXT-AGENT-PROMPT.md ]; then
  cat NEXT-AGENT-PROMPT.md
fi

# 2. The latest session log (always)
ls -t docs/sessions/*.md 2>/dev/null | head -1 | xargs cat 2>/dev/null

# 3. Anything else relevant
# e.g., git status, recent commits, active branch
```

Wire via Claude Code's SessionStart hook in `~/.claude/settings.json`.

## The discipline

The cycle:
- **Start session:** read what loaded automatically. Don't ask "what was I doing?" — read it.
- **Work:** do the thing.
- **End session:** `/wrap` before close. Don't skip.

`/wrap` is 5-15 minutes. Skipping it costs the next session 15-30 minutes of rediscovery. Net negative.

## What `/wrap` SHOULD NOT skip

The skill enforces:
- [ ] All meaningful changes committed (no uncommitted work)
- [ ] Branch pushed (no local-only state)
- [ ] Any followups identified are filed as tickets (per [never-defer](../01-linear-as-load-bearing-pm/never-defer.md))
- [ ] MEMORY.md updated if state changed
- [ ] NEXT-AGENT-PROMPT.md written
- [ ] Session log written

If any are skipped, the skill warns. You either fix or override (and document why).

## When `/wrap` would be overkill

For < 15-minute sessions (quick check, single commit, look-up question): skip `/wrap`. The session log would be empty. The handoff would just be "no change."

For sessions that produce only research / reading (no code changes): the handoff is "I read X and learned Y; next time take action Z." Often worth writing.

For sessions that produce major state changes (a migration, a phase completion): write a full audit alongside `/wrap`. The audit is durable; the handoff is for the next session.

## Field-tested gotchas

**`/wrap` skipped → next session pays 30 min.** The pattern: you're tired at end of session, "I'll just wrap quickly," skip. Next session opens to "nothing in handoff," wastes time rebuilding context.

**Handoff doc that's too long.** A 500-line NEXT-AGENT-PROMPT.md doesn't get read; the next session skims and misses things. Cap at 100 lines.

**Session log without the "Surprises" section.** Surprises are the most useful future-context. Don't omit.

**MEMORY.md updates that conflict.** If you run two sessions in parallel (one for project X, one for project Y), the MEMORY.md updates might race. Lock per project; each project has its own MEMORY.md anyway (Layer 3).

**SessionStart hook that fails silently.** If the hook errors, no context loads, and you don't know. Test the hook regularly: `bash ~/.claude/scripts/session-start-context.sh` should produce output.

**Trying to read 5 sessions back.** SessionStart should load the LATEST session, not all of them. Older sessions are reachable via `ls docs/sessions/` but not auto-loaded.

## Innovative pattern: `/resume` complement

A `/resume` skill the user can run mid-session if context got compacted or they need a refresh:

```
/resume

Reads NEXT-AGENT-PROMPT.md
Reads latest 3 session docs
Reads MEMORY.md
Outputs a 2-paragraph "you are here" summary
```

When you context-switched and came back, `/resume` re-grounds you.

## Innovative pattern: handoff diff

When `/wrap` runs, it diffs the new NEXT-AGENT-PROMPT.md against the previous one. Surfaces:
- What was open before but is now closed
- What's new
- What's still pending

Helpful for tracking progress week-over-week.

## Innovative pattern: wrap stats

Each `/wrap` logs:
- Session duration
- Files changed
- Commits made
- Tickets touched
- Followups filed

Weekly aggregation answers: "how much am I shipping?" and "is my followup-filing rate sustainable?"

## Related

- [Chapter 03 — Memory architecture](../03-claude-code-as-operator/memory-architecture.md) — what MEMORY.md is
- [Chapter 03 — Skills and hooks](../03-claude-code-as-operator/skills-and-hooks.md) — how SessionStart hook is wired
- [Commit cadence](./commit-cadence.md) — `/wrap` enforces commits before close
- [Audit and conventions pattern](./audit-and-conventions-pattern.md) — session log ≠ audit (audit is for state-changing sessions)
