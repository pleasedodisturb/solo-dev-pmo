# RESEARCH-LOG — Phase P03: Claude Code as operator

Append-only log of sources cited while enriching chapter 03. Format per
[SEARCH-PLAYBOOK.md](../SEARCH-PLAYBOOK.md) §"Per-phase research log format".

Checked against: Claude Code docs at **code.claude.com/docs** (migrated from
docs.claude.com/en/docs/claude-code), accessed 2026-05-31.

---

## 2026-05-31 — Claude Code docs URL migration (Q03.1)

- **Source:** https://docs.claude.com/en/docs/claude-code/hooks → 301 → https://code.claude.com/docs/en/hooks
- **Class:** primary (vendor docs)
- **Surfaced fact:** The Claude Code documentation moved from `docs.claude.com/en/docs/claude-code/*` to `code.claude.com/docs/en/*`. Every chapter URL that points at the old host now redirects.
- **Used in:** README.md (version/datestamp line), sources.md
- **Counter-evidence:** none

## 2026-05-31 — Hook event list expanded dramatically (Q03.2, Q03.24)

- **Source:** https://code.claude.com/docs/en/hooks — accessed 2026-05-31
- **Class:** primary (vendor docs)
- **Surfaced fact:** The chapter lists 5 hook events (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop). Current docs enumerate ~30, including SessionEnd, SubagentStart/SubagentStop, PreCompact/PostCompact, PermissionRequest/PermissionDenied, UserPromptExpansion, PostToolUseFailure, PostToolBatch, TaskCreated/TaskCompleted, WorktreeCreate/WorktreeRemove, Elicitation, FileChanged, CwdChanged, InstructionsLoaded, MessageDisplay, ConfigChange, Notification, Setup. Blocking semantics: exit 0 = ok, exit 2 = blocking error (stderr → Claude), other non-zero = non-blocking. UserPromptSubmit has a 30s default timeout (vs 600s elsewhere) and blocks model processing — the chapter's "hooks add latency" warning understates this.
- **Used in:** skills-and-hooks.md (hook enumeration + UserPromptSubmit safe-pattern)
- **Counter-evidence:** none

## 2026-05-31 — Ground-truth checks from a live Claude Code cloud session

This phase runs *inside* a Claude Code session, so several chapter claims were
verified firsthand rather than from docs.

- **Source:** this session's environment — `claude --version`, `~/.claude/`, accessed 2026-05-31
- **Class:** primary (firsthand)
- **Surfaced facts:**
  - Claude Code version **2.1.158** — anchor the chapter's "version we checked against" here.
  - `settings.json` hook schema confirmed: `hooks → <EventName> → [{ matcher, hooks: [{ type: "command", command }] }]`. A real `Stop` hook is wired (`~/.claude/stop-hook-git-check.sh`).
  - Hook I/O model confirmed: hook reads JSON on **stdin**, checks `stop_hook_active` for recursion prevention, signals via **exit code**.
  - **Layer-3 path encoding confirmed exactly:** `~/.claude/projects/-home-user-solo-dev-pmo` — absolute path with `-` separators, as the chapter claims.
  - **Skills are directories containing `SKILL.md`** (`~/.claude/skills/session-start-hook/SKILL.md`), NOT single slash-command markdown files. The chapter's "skill anatomy" (a `name.md` with `name:`/`description:` frontmatter) is the right frontmatter but wrong container — current model is a folder + `SKILL.md`.
- **Used in:** skills-and-hooks.md (skill model), memory-architecture.md (Layer-3 encoding stays correct), README.md (version line)
- **Counter-evidence:** none — claims held up. The Layer-3 encoding claim is now firsthand-verified.
