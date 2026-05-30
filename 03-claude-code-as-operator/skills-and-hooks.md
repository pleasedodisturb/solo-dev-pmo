# Skills and hooks

> Skills are commands the agent can execute. Hooks are automation triggered by agent events. Understanding the boundary is what makes the agent-as-operator pattern work.

## Skills

A skill in Claude Code (and equivalents in Cursor `.cursorrules`, Aider `/`-commands, Codex prompts) is a slash command. The user types `/skill-name`, the agent executes a defined workflow.

Skills are the agent's API to the human. Each skill should:
- Have a clear, narrow purpose
- Take optional arguments
- Reach for the same MCPs / tools every time
- Produce a deterministic output shape

### When to write a skill

Write a skill when:
- You find yourself manually triggering the same multi-step workflow weekly+
- A workflow has 5+ steps and you want a one-command trigger
- A workflow needs specific MCPs / tools that you want the agent to default to

Don't write a skill for:
- One-off workflows
- Things you could do inline in 30 seconds
- Workflows that change every time (skills are for stable shape)

### Skill anatomy

Typical structure:

```markdown
---
name: my-skill
description: One-line purpose. Use when [trigger].
---

<purpose>
What this skill does and why.
</purpose>

<context>
Pre-loaded reading the skill needs.
</context>

<process>
Step-by-step. Numbered. Each step calls a specific tool.
</process>

<success_criteria>
- [ ] Item 1
- [ ] Item 2
</success_criteria>
```

The `process` section is the meat. Each step is a `<step name="...">` block with concrete instructions.

### Skill categories worth investing in

**Capture skills** — `/capture`, `/triage`, `/file-bug`. Pre-fill ticket templates from conversation context.

**Workflow skills** — `/plan-phase`, `/execute-phase`, `/spike`, `/verify`. Multi-step product/research workflows.

**Audit skills** — `/audit-uat`, `/code-review`, `/security-review`. Reading-heavy reviews with structured output.

**Wrap/resume skills** — `/wrap` (session end + handoff doc), `/resume` (session start, load context).

**Per-domain skills** — `/linear-sync`, `/github-pr`, `/deploy`. Domain-specific orchestrations.

### Skills vs. agents

A **skill** runs in the main session — uses main context, returns results inline.

An **agent** runs in an isolated context — receives a prompt, returns a final message, doesn't see your conversation.

Skills are for workflows you'll watch / interact with. Agents are for delegating chunks where you don't need to watch.

(See [agent rules](./agent-rules.md) for when to spawn.)

## Hooks

A hook is shell code that runs in response to a Claude Code event. Events include:

- `SessionStart` — when a session begins
- `UserPromptSubmit` — when you send a message
- `PreToolUse` — before any tool call
- `PostToolUse` — after any tool call
- `Stop` — when the session ends

Hooks are configured in `~/.claude/settings.json` (global) or `<repo>/.claude/settings.json` (project).

### When to write a hook

Write a hook when:
- You want automation that runs regardless of agent compliance
- Something must happen on a specific event (not "the agent might remember")
- You want to enforce a policy mechanically

Don't write a hook for:
- Things the agent should do (use a rule instead)
- One-off automation (use a script)
- Conditional logic that's hard to express in shell

### Hook examples

**SessionStart context injection.** When a session starts, run a script that:
1. Reads recent commits
2. Reads the project's `NEXT-AGENT-PROMPT.md` if present
3. Prints them as context

The agent sees them at session start without you typing.

**PreToolUse guard.** Before any `git push` tool call:
1. Check if commits have the `Reviewed-by:` trailer
2. If not, fail loudly so the push aborts

Enforces the [PR review standard](../06-session-discipline/pr-review-standard.md) mechanically.

**PostToolUse formatter.** After any file write:
1. Run `prettier` / `ruff format` on the changed file
2. Re-stage

Auto-formats without the agent having to remember.

**UserPromptSubmit context.** When user submits a message, prepend timing info, recent file changes, or any other "always-good-to-know" context.

### Hook gotchas

**Hooks fail silently if malformed.** Test after adding. A misconfigured hook can break sessions; you'll wonder why and not realize the hook is broken.

**Hooks run in your shell.** They inherit your environment. If `LINEAR_API_TOKEN` isn't set when Claude Code starts, hooks that depend on it fail.

**Hooks add latency.** Every hook on every event runs synchronously by default. Keep them fast. A 2-second PreToolUse hook on every tool call = death.

**Hooks live globally OR per-project.** Decide explicitly. A global hook fires for every repo; project-level fires only when you're in that repo.

## Skills + hooks: the symbiosis

The pattern that works:
- **Skills** for human-triggered workflows
- **Hooks** for automation that runs regardless

Example: PR review.
- **Skill `/review`** — user triggers; agent runs code + security review per checklist; reports findings
- **Hook `pre-push`** — runs at push time; checks for `Reviewed-by:` trailer; blocks push if missing

The skill is what the user reaches for. The hook is the safety net for when the user forgets the skill.

## Building skills incrementally

Don't try to write 30 skills upfront. The pattern:

1. **Notice** a workflow you do weekly+ manually
2. **Document** it as a markdown checklist (`docs/<workflow>.md`)
3. **Promote** to a skill when the checklist stabilizes
4. **Refactor** when the skill's process drifts from reality

Most folks who try to write 30 skills upfront end up with 30 unused skills. Build organically.

## Field-tested gotchas

**Skills with too many steps don't run reliably.** A 15-step skill compounds error probability. Cap at ~7-10 steps; if you need more, split into multiple skills with a "main" orchestrator.

**Skill prompts that depend on conversation context.** "Take what we discussed and..." doesn't work — skills run with their own context. Pass arguments explicitly.

**Hooks that depend on env vars not set in Claude Code's environment.** Test by running the hook as `bash -c 'unset NICE_VAR; <hook>'` to confirm.

**Skills that write to memory inappropriately.** A skill that writes "session ran X" to MEMORY.md every invocation pollutes memory fast. Skills should only write memory when they produce a real insight, not at every run.

**Skill names colliding with built-ins.** `/help` is built-in. Naming your skill `/help-me` causes confusion. Check for collisions.

## Innovative pattern: skill registries

Maintain a `~/.claude/skills/README.md` index listing every skill, what it does, when to use it.

When you forget which skill to reach for, you `cat ~/.claude/skills/README.md` instead of guessing. Self-discoverability.

Run a daily check: `ls ~/.claude/skills/` vs. the index — list out-of-sync skills.

## Innovative pattern: skill chaining via "next-up" routing

A skill's final output section includes a "Next Up" pointer:

```markdown
## ▶ Next Up

After this skill completes, consider:
- `/related-skill-1` — when you need X
- `/related-skill-2` — when you need Y
```

The agent surfaces these to the user at completion. Helps discoverability without you remembering which skill comes next.

## Innovative pattern: hook + skill loop for ongoing audit

A daily hook fires `/audit-conventions` which:
1. Reads all your CLAUDE.md, conventions/, and global rules
2. Cross-checks against actual code patterns
3. Reports drift

You see the report at next session start. Convention rot gets visible within 24 hours.

## Related

- [Memory architecture](./memory-architecture.md) — what skills can write to vs. shouldn't
- [Agent rules](./agent-rules.md) — when a skill should spawn an agent
- [MCP routing](./mcp-routing.md) — which MCPs skills should reach for
- [Chapter 06 — Wrap and resume](../06-session-discipline/wrap-and-resume.md) — the canonical skill pair
