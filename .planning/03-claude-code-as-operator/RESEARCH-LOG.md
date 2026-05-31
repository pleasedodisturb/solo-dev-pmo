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
