# Skills and hooks

> Skills are commands the agent can execute. Hooks are automation triggered by agent events. Understanding the boundary is what makes the agent-as-operator pattern work.

*Checked against Claude Code v2.1.158 (2026-05-31).* The naming below is Claude Code's, but the shapes map to other tools — see [agent-platform-portability](./agent-platform-portability.md).

## Skills

A **skill** is a `SKILL.md` file in its own directory — personal (`~/.claude/skills/<name>/SKILL.md`), project (`.claude/skills/<name>/SKILL.md`), or bundled in a plugin.[¹] The user types `/name`, or — new in the 2026 model — the agent invokes it itself when the task matches the skill's `description`.

Two 2026 changes the chapter used to miss:

- **Custom commands merged into skills.**[¹] A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy`. Old `commands/*.md` keep working; skills add a directory for supporting files, frontmatter, and model-invocation.
- **Skills follow the [Agent Skills open standard](https://agentskills.io)** (`agentskills.io`),[¹] which other AI tools implement — so a well-written `SKILL.md` is closer to portable than a bespoke slash command.

Each skill should have a narrow purpose, take optional `$ARGUMENTS`, reach for the same tools every time, and produce a deterministic output shape.

### Skill discovery: who invokes it (Q03.3)

This is the biggest shift from the "skills are just slash commands" mental model:

| Mode | How it fires | Set via |
|---|---|---|
| Model-invoked | Agent reads the `description` and uses the skill when relevant — no typing | default |
| Explicit-only | Only `/name` triggers it | `disable-model-invocation: true` |

**Progressive disclosure** is why this scales: only each skill's `name` + `description` sit in context; the body loads only when the skill runs.[¹] "Long reference material costs almost nothing until you need it" — which is the real answer to skill bloat (see [field tests](#field-tested-gotchas)). The `description` is now load-bearing: it's the agent's only signal for *when* to reach for the skill. Write it as "Does X. Use when Y."

### Skill anatomy

```markdown
---
name: my-skill
description: One-line purpose. Use when [trigger].
disable-model-invocation: false   # true = /command only
allowed-tools: Read, Grep, Bash   # optional: restrict the skill's tools
---

What this skill does. Step-by-step, numbered, each step naming a tool.
Use $ARGUMENTS for user input passed after the skill name.
```

The body is the meat. Cap steps at ~7–10; a 15-step skill compounds error probability — split into an orchestrator + sub-skills.

### Skill categories worth investing in

- **Capture** — `/capture`, `/triage`, `/file-bug`. Pre-fill ticket templates from context.
- **Workflow** — `/plan-phase`, `/execute-phase`, `/spike`, `/verify`. Multi-step product/research flows.
- **Audit** — `/audit-uat`, `/code-review`, `/security-review`. Reading-heavy, structured output.
- **Wrap/resume** — `/wrap` (session end + handoff), `/resume` (session start, load context).
- **Per-domain** — `/linear-sync`, `/github-pr`, `/deploy`.

### Skills vs. agents

A **skill** runs in the main session — uses main context, returns inline. An **agent** (subagent) runs in an isolated context, returns a final message, doesn't see your conversation. Skills are for workflows you watch; agents for chunks you delegate. A skill can even *run in a subagent* via Claude Code's invocation control.[¹] (See [agent rules](./agent-rules.md).)

## Plugins (the bundling layer — Q03.5)

New since the chapter was written: a **plugin** is a directory with a `.claude-plugin/plugin.json` manifest that packages skills, agents, hooks, MCP servers, and more for sharing/versioning.[²] It doesn't replace skills or hooks — it distributes them.

| Plugin dir | Holds |
|---|---|
| `skills/` | Skills as `<name>/SKILL.md` |
| `agents/` | Subagent definitions |
| `hooks/hooks.json` | Hook config (same shape as `settings.json`) |
| `.mcp.json` | MCP servers |
| `.lsp.json`, `monitors/`, `bin/`, `settings.json` | LSP, watchers, PATH execs, defaults |

Plugin skills are namespaced (`/my-plugin:deploy`) to avoid collisions. Install from marketplaces via `/plugin`; Anthropic ships a curated `claude-plugins-official` (auto-available) and a `claude-community` marketplace.[²] **For the solo dev:** keep personal config standalone in `.claude/` for short names and fast iteration; reach for a plugin only when you want to share across machines/projects or version it. This is how bundles like gstack ship 65+ skills as one install.

## Hooks

A hook is shell code that runs on a Claude Code event. Configured in `~/.claude/settings.json` (global) or `.claude/settings.json` (project); a hook reads event JSON on **stdin** and signals via **exit code**.[¹] Verified live: the schema is `hooks → <Event> → [{ matcher, hooks: [{ type: "command", command }] }]`.[³]

### The event list (Q03.2)

The chapter once listed five events. v2.1.158 exposes ~30.[¹] The ones you'll actually wire:

| Event | Fires | Can block? |
|---|---|---|
| `SessionStart` / `SessionEnd` | session begins/resumes; terminates | no |
| `UserPromptSubmit` | before Claude processes your prompt — inject context or block | yes |
| `PreToolUse` / `PostToolUse` | before/after a tool runs | pre: yes / post: no |
| `PostToolUseFailure` | after a tool errors — remediation context | no |
| `Stop` / `SubagentStop` | main agent / subagent finishes responding | yes |
| `SubagentStart` | a subagent spawns | no |
| `PreCompact` / `PostCompact` | around context compaction | pre: yes |
| `PermissionRequest` / `PermissionDenied` | auto-approve/deny; allow retry | yes / retry |
| `Notification` | Claude Code emits a notification | no |

Plus `UserPromptExpansion`, `PostToolBatch`, `TaskCreated/Completed`, `FileChanged`, `CwdChanged`, `WorktreeCreate/Remove`, `ConfigChange`, `InstructionsLoaded`, `Elicitation` — see the [hooks reference](https://code.claude.com/docs/en/hooks).[¹]

**Blocking model:**[¹] exit `0` = ok (stdout JSON processed, plain text added as context); exit `2` = blocking error (stderr fed to Claude, action blocked where the event supports it); other non-zero = non-blocking (stderr shown, execution continues). `PreToolUse` can also return JSON `permissionDecision: allow|deny|ask`.

### UserPromptSubmit: the silent-block trap (Q03.24)

`UserPromptSubmit` runs **before every prompt and blocks model processing**, so it ships with a **30-second default timeout** (vs 600s elsewhere).[¹] A slow or wedged hook here stalls the whole session, and a non-zero exit silently erases the prompt. Safe pattern:

```bash
#!/usr/bin/env bash
# UserPromptSubmit hook — must be fast and fail-open
input=$(cat)                       # event JSON on stdin
context=$(timeout 3 ~/.claude/bin/gather-context.sh 2>/dev/null) || exit 0
echo "$context"                    # stdout (exit 0) = added as context
exit 0                             # NEVER exit non-zero unless you mean to block
```

Rules: keep it under a few seconds, set an explicit `timeout` if you must run longer, and `exit 0` on every error path so a failing context-gatherer never eats the user's prompt. If validation can wait, move it to `PostToolUse` instead.[¹]

### When to write a hook

When you want automation that runs regardless of agent compliance, must happen on a specific event, or enforces a policy mechanically. **Not** for things the agent should do (use a skill/rule), one-off automation (use a script), or logic that's awkward in shell.

### Hook gotchas

- **Hooks fail silently if malformed.** Test after adding; a broken hook can wedge sessions.
- **Hooks inherit your shell env.** If `LINEAR_API_TOKEN` isn't set when Claude Code starts, hooks depending on it fail. Test with `bash -c 'unset VAR; <hook>'`.
- **Hooks add latency.** Every hook on every matched event runs synchronously. A 2-second `PreToolUse` on every tool call is death.
- **Global vs per-project.** A global hook fires for every repo; project-level only in that repo. Decide explicitly.

## Skills + hooks: the symbiosis

- **Skills** for human-triggered (or model-triggered) workflows.
- **Hooks** for automation that runs regardless.

Example — PR review: skill `/review` runs code + security review on demand; hook on `PreToolUse` (matcher `Bash`, guarding `git push`) blocks the push if the `Reviewed-by:` trailer is missing. The skill is what you reach for; the hook is the safety net for when you forget.

## Building skills incrementally

Don't write 30 skills upfront — you'll get 30 unused skills. Notice a workflow you do weekly+, document it as a markdown checklist, promote it to a skill when the shape stabilizes, refactor when it drifts.

## Field-tested gotchas

**Skill bloat is real but progressive disclosure blunts it.** Because only `name` + `description` load until a skill runs,[¹] dozens of installed skills cost little context — *if* descriptions are crisp. The failure mode isn't token cost; it's the agent picking the wrong skill when two descriptions overlap. Keep descriptions disjoint; audit collisions.

**Skill prompts that depend on conversation context don't work.** "Take what we discussed and…" fails — skills run with their own context. Pass `$ARGUMENTS` explicitly.

**Skills that write to memory every run pollute it.** Write memory only on a real insight, not at every invocation.

**Skill names colliding with built-ins.** `/help`, `/compact`, `/code-review` are built in.[¹] Check before naming; plugin skills sidestep this via namespacing.

## Innovative pattern: skill registries

Maintain a `~/.claude/skills/README.md` index — every skill, what it does, when to use it. `cat` it when you forget which to reach for. Run a daily check: `ls ~/.claude/skills/` vs. the index, list out-of-sync entries. (In the 2026 model, good `description` fields do much of this work automatically — but a human-readable index still helps *you*.)

## Innovative pattern: skill chaining via "next-up" routing

A skill's final output names what comes next:

```markdown
## ▶ Next Up
- `/related-skill-1` — when you need X
- `/related-skill-2` — when you need Y
```

The agent surfaces these at completion. Discoverability without you remembering the sequence.

## Related

- [Memory architecture](./memory-architecture.md) — what skills can write to vs. shouldn't
- [Agent rules](./agent-rules.md) — when a skill should spawn an agent
- [MCP routing](./mcp-routing.md) — which MCPs skills should reach for
- [Agent-platform portability](./agent-platform-portability.md) — skills/hooks in Cursor, Aider, Cline, Continue
- [Chapter 06 — Wrap and resume](../06-session-discipline/wrap-and-resume.md) — the canonical skill pair

---

[¹]: https://code.claude.com/docs/en/skills and https://code.claude.com/docs/en/hooks — accessed 2026-05-31
[²]: https://code.claude.com/docs/en/plugins — accessed 2026-05-31
[³]: Ground-truth from this Claude Code v2.1.158 session (`~/.claude/settings.json`, `~/.claude/stop-hook-git-check.sh`) — 2026-05-31
