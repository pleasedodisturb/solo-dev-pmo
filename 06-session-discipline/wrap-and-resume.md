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

## The `/wrap` skill

> **Verify on a local Claude Code install.** The skill below is written against the [current skills contract][skills]; this was authored in a cloud session where slash-command firing can't be fully exercised.

Custom commands are now [skills][skills] — a file at `.claude/commands/wrap.md` *or* `.claude/skills/wrap/SKILL.md` both create `/wrap`.[¹] Use a skill so you get frontmatter and [dynamic context injection][skills] (the `` !`cmd` `` syntax runs a command and inlines its output before Claude sees the body):

```markdown
---
description: End-of-session wrap — verify clean tree, write the handoff doc, update memory.
disable-model-invocation: true   # only ever run on purpose, with /wrap
allowed-tools: Bash(git status:*) Bash(git log:*) Read Write
argument-hint: "[optional one-line session summary]"
---

## Session state (injected)

- Branch: !`git rev-parse --abbrev-ref HEAD`
- Uncommitted: !`git status --porcelain | wc -l` file(s)
- Unpushed: !`git log @{u}.. --oneline 2>/dev/null | wc -l` commit(s)
- Recent: !`git log --oneline -5`

## Do this, in order

1. **Refuse to proceed silently if the tree is dirty or unpushed.** If the
   counts above are non-zero, stop and tell me — wrapping over uncommitted
   work loses it. (Commit + push per ./commit-cadence.md, then continue.)
2. File any followups I named as Linear tickets (never-defer).
3. Write `NEXT-AGENT-PROMPT.md` using the template in this chapter. Keep < 100 lines.
4. Write `docs/sessions/<today>-<slug>.md` (the per-session log).
5. Update `MEMORY.md` if durable state changed.
6. Print a 3-line summary: what shipped, what's open, what's next. Use $ARGUMENTS as the headline if I passed one.
```

`disable-model-invocation: true` is the load-bearing line: it stops Claude auto-firing `/wrap` mid-task — it only runs when you type it.[²] Scope `allowed-tools` tightly so the wrap can't, say, push on its own.

## The SessionStart hook

> **Verify on a local Claude Code install.** Hook *contract* re-verified against the docs (2026-05-31); hook *firing* can't be exercised in a cloud session.

The complement: a [`SessionStart` hook][hooks] that injects the handoff into context before your first prompt. The current contract gives `SessionStart` four matchers — `startup | resume | clear | compact` — and two ways to inject context: plain stdout, or a JSON `hookSpecificOutput.additionalContext` string.[³] Plain stdout is enough here:

```bash
#!/usr/bin/env bash
# ~/.claude/scripts/session-start-context.sh — stdout is injected as context.
# Wire under SessionStart matcher "startup|resume" (NOT "compact" — see below).
[ -f NEXT-AGENT-PROMPT.md ] && { echo "=== HANDOFF ==="; cat NEXT-AGENT-PROMPT.md; }
latest=$(ls -t docs/sessions/*.md 2>/dev/null | head -1)
[ -n "$latest" ] && { echo "=== LAST SESSION ($latest) ==="; cat "$latest"; }
echo "=== GIT ==="; git -c color.ui=false status -sb 2>/dev/null
```

Wire it in `.claude/settings.json` (project) or `~/.claude/settings.json` (global):

```json
{ "hooks": { "SessionStart": [ {
  "matcher": "startup|resume",
  "hooks": [ { "type": "command", "command": "~/.claude/scripts/session-start-context.sh" } ]
} ] } }
```

Match `startup|resume` but **not `compact`**: on a compaction-triggered restart you don't want to re-inject the whole handoff on top of Claude's fresh summary — that's redundant context. See [Auto-compaction interaction](#auto-compaction-interaction).

## The discipline

The cycle: **start** by reading what the hook loaded (don't ask "what was I doing?" — read it); **work**; **end** with `/wrap` before close, no skipping. `/wrap` is 5-15 minutes; skipping it costs the next session 15-30 of rediscovery. Net negative.

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

- **< 15-minute sessions** (quick check, single commit, lookup): skip — the log is empty, the handoff is "no change."
- **Research/reading only** (no code): often still worth it — the handoff is "I read X, learned Y; next take action Z."
- **Major state changes** (migration, phase completion): write a full [audit](./audit-and-conventions-pattern.md) *alongside* `/wrap`. The audit is durable; the handoff is for the next session.

## Auto-compaction interaction

Claude Code auto-compacts: when the conversation approaches the context limit, it summarizes history in place so the session can continue.[⁴] This is *not* a substitute for `/wrap` — they solve different problems:

| | Auto-compaction | `/wrap` |
|---|---|---|
| Scope | Within one session | Across sessions / machines |
| Persistence | In-memory summary, lost on exit | Files in the repo, durable |
| Trigger | Token pressure, automatic | You, on purpose |

The discipline: **`/wrap` before you compact, not after.** Two reasons. First, a wrap written from the full, un-summarized transcript is sharper than one written from Claude's own compacted summary (compaction is lossy — it optimizes for continuing, not for handoff). Second, if you can *see* compaction coming (status line shows context filling[⁴]), wrapping first means the durable handoff is written from peak context. A `PreCompact` hook (matchers `manual|auto`[³]) can nudge you — fire a notification when auto-compaction is about to run so you can `/wrap` first if the session was load-bearing.

You can also bias what compaction keeps: `/compact Focus on the open ticket and the wrap checklist`, or a standing instruction in `CLAUDE.md`.[⁴] And `/clear` between unrelated tasks beats letting one long session compact repeatedly — cheaper context, less lossy.

## Multi-machine continuity

Working a branch on the laptop, continuing on the desktop. Two sync layers, and the rule is **don't confuse them**:

1. **Anything in a git repo syncs via git.** This is the whole point of "push after every commit" ([commit cadence](./commit-cadence.md)). The handoff doc, session logs, audits, conventions all live in-repo, so a `git push` on the laptop and `git pull` on the desktop *is* the handoff transfer. No extra tooling. This is the [Cline/Cursor "memory bank" idea][cline] — durable markdown the next context re-reads — except git is the transport, so it's already multi-machine.
2. **Un-versioned `~/.claude/` state** (the SessionStart script, settings, raw `~/.claude/projects/` transcripts) lives outside any repo. If you want it on both machines, sync it with [Syncthing][st] (P2P, continuous, no cloud).[⁵]

The Syncthing gotcha that bites: if two machines run live sessions writing the *same* file, Syncthing can't merge — it renames the loser `*.sync-conflict-<date>-<time>-<id>.<ext>` and you silently lose an edit.[⁵] So: **don't Syncthing your active repos** (git already handles those, better) — scope Syncthing to dotfiles and settings only, and avoid running two live Claude sessions against the same synced project at once.

The net rule: *if it's a decision or work product, it's in a repo and git is the sync. Syncthing is only for the config that isn't.*

## Field-tested gotchas

**`/wrap` skipped → next session pays 30 min.** The pattern: you're tired at end of session, "I'll just wrap quickly," skip. Next session opens to "nothing in handoff," wastes time rebuilding context.

**Handoff doc that's too long.** A 500-line NEXT-AGENT-PROMPT.md doesn't get read; the next session skims and misses things. Cap at 100 lines.

**Session log without the "Surprises" section.** Surprises are the most useful future-context. Don't omit.

**SessionStart hook that fails silently.** If the hook errors, no context loads and you don't notice. Test it directly: `bash ~/.claude/scripts/session-start-context.sh` should produce output. SessionStart should load the LATEST session only — older ones stay reachable via `ls docs/sessions/` but aren't auto-injected.

## Innovative patterns

- **`/resume` is now built in.** Claude Code ships `/resume` for returning to a session, and runs background jobs that summarize prior conversations to power `claude --resume`.[⁴] You no longer need a custom resume skill for *session* resume — but a custom `/reground` (re-read `NEXT-AGENT-PROMPT.md` + latest session doc + `MEMORY.md`, print a 2-paragraph "you are here") is still useful mid-session after a context switch, because it re-reads the *durable* handoff, not the in-memory transcript.
- **Handoff diff.** Have `/wrap` diff the new `NEXT-AGENT-PROMPT.md` against the previous one — surfaces what closed, what's new, what's still pending. Week-over-week progress for free.
- **Wrap stats.** Log duration / files changed / commits / tickets touched / followups filed per wrap. Weekly aggregation answers "how much am I shipping?" and "is my followup rate sustainable?"

## Related

- [Chapter 03 — Memory architecture](../03-claude-code-as-operator/memory-architecture.md) — what MEMORY.md is
- [Chapter 03 — Skills and hooks](../03-claude-code-as-operator/skills-and-hooks.md) — how SessionStart hook is wired
- [Hook and script examples](./hook-and-script-examples.md) — runnable hook/script companions
- [Commit cadence](./commit-cadence.md) — `/wrap` enforces commits before close
- [Audit and conventions pattern](./audit-and-conventions-pattern.md) — session log ≠ audit (audit is for state-changing sessions)

---

[skills]: https://code.claude.com/docs/en/skills
[hooks]: https://code.claude.com/docs/en/hooks
[cline]: https://docs.cline.bot/features/memory-bank
[st]: https://docs.syncthing.net/users/syncing.html

[¹]: Claude Code Skills — "Custom commands have been merged into skills"; `.claude/commands/x.md` and `.claude/skills/x/SKILL.md` both create `/x`. https://code.claude.com/docs/en/skills — accessed 2026-05-31.
[²]: Skills frontmatter reference — `disable-model-invocation`, `allowed-tools`, `argument-hint`. https://code.claude.com/docs/en/skills — accessed 2026-05-31.
[³]: Claude Code Hooks reference — SessionStart matchers `startup|resume|clear|compact`, `hookSpecificOutput.additionalContext`, PreCompact matchers `manual|auto`. https://code.claude.com/docs/en/hooks — accessed 2026-05-31.
[⁴]: Claude Code, "Manage costs effectively" — auto-compaction, `/compact`, CLAUDE.md compact instructions, `/resume` background summarization. https://code.claude.com/docs/en/costs — accessed 2026-05-31.
[⁵]: Syncthing docs — continuous P2P sync and `*.sync-conflict-*` conflict handling. https://docs.syncthing.net/users/syncing.html — accessed 2026-05-31.
