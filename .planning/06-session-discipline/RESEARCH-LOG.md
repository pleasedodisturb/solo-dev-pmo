# RESEARCH-LOG — P06 Session discipline

Append-only. Sources cited as the chapter was enriched. Format per SEARCH-PLAYBOOK §"Per-phase research log format".

## 2026-05-31 — Claude Code hook contract (the biggest risk per brief §7)

- **Source:** https://code.claude.com/docs/en/hooks (redirected from docs.claude.com/en/docs/claude-code/hooks)
- **Class:** primary
- **Surfaced fact:** `SessionStart` matchers are `startup|resume|clear|compact`; output injects via `hookSpecificOutput.additionalContext` (string) OR plain stdout. `SessionEnd` exists now (matchers `clear|resume|logout|prompt_input_exit|...`) but has NO blocking capability — cleanup/logging only. `PreCompact` matchers are `manual|auto`. `UserPromptSubmit` supports `additionalContext` + `decision:"block"`.
- **Used in:** wrap-and-resume.md (SessionStart hook), hook-and-script-examples.md (UserPromptSubmit safe pattern)
- **Counter-evidence:** none. Contract is intact and richer than the existing chapter assumed (chapter predates `SessionEnd`).

## 2026-05-31 — Conventional Commits spec

- **Source:** https://www.conventionalcommits.org/en/v1.0.0/
- **Class:** primary
- **Surfaced fact:** Current spec is v1.0.0. Structure = `type(scope)!: description` + body + footers. Footers "follow a convention similar to git trailer format." `BREAKING CHANGE:` must be uppercase; `!` is shorthand. Types beyond feat/fix are allowed.
- **Used in:** commit-cadence.md (superset-compat note), README.md
- **Counter-evidence:** none. No 2.0 revision landed (brief §7 watch item clear).

## 2026-05-31 — Linux kernel trailers

- **Source:** https://docs.kernel.org/process/submitting-patches.html
- **Class:** primary
- **Surfaced fact:** `Reviewed-by:` carries a formal Reviewer's Statement of oversight (technical review carried out, concerns communicated back). `Signed-off-by:` = DCO. `Acked-by:`/`Tested-by:` weaker. This is broader than Linux: Git ships `Documentation/SubmittingPatches` and `git interpret-trailers`; Gerrit uses sign-off too.
- **Used in:** pr-review-standard.md, sources.md
- **Counter-evidence:** `Reviewed-by:` adoption beyond kernel is real (Gerrit, Git project, QEMU, U-Boot) — brief §7 "soften if kernel-only" does NOT trigger.

## 2026-05-31 — ADR (Nygard)

- **Source:** https://github.com/joelparkerhenderson/architecture-decision-record + martinfowler.com/bliki/ArchitectureDecisionRecord.html
- **Class:** primary (canonical repo) + practitioner
- **Surfaced fact:** Nygard 2011 template = Title/Status/Context/Decision/Consequences. ADRs are immutable once accepted; a reversed decision is marked `superseded` and linked, not deleted. Maps cleanly to the playbook's audit (dated, append-only) + convention (locked rule) split.
- **Used in:** audit-and-conventions-pattern.md
- **Counter-evidence:** none.

## 2026-05-31 — pre-commit framework + alternatives

- **Source:** https://pre-commit.com/ ; github.com/pre-commit/pre-commit-hooks ; evilmartians/lefthook ; andymadge.com git-hooks-comparison
- **Class:** primary + practitioner
- **Surfaced fact:** `pre-commit` installs per stage via `pre-commit install --hook-type pre-push|commit-msg`. Ships `no-commit-to-branch` (protects main/master by default). Lefthook = Go binary, parallel, language-agnostic, single YAML. Husky = Node-coupled, sequential. simple-git-hooks = minimal.
- **Used in:** hook-and-script-examples.md, README version matrix
- **Counter-evidence:** Lefthook is faster for polyglot; but pre-commit's hook gallery + language isolation keeps it the default recommendation (brief constraint: don't prefer Husky without evidence — upheld).

## 2026-05-31 — Claude Code auto-compaction

- **Source:** https://code.claude.com/docs/en/costs
- **Class:** primary
- **Surfaced fact:** Auto-compaction summarizes conversation history when approaching context limits. `/compact [instructions]` runs it manually; CLAUDE.md can hold standing compact instructions. `/clear` resets; `/rewind` restores checkpoints. Background jobs summarize for `--resume`.
- **Used in:** wrap-and-resume.md (auto-compaction interaction)
- **Counter-evidence:** none.

## 2026-05-31 — Agent session handoff (other tools)

- **Source:** docs.cline.bot/features/memory-bank ; aider.chat/docs/usage/commands.html ; Cursor memory-bank community
- **Class:** vendor docs + community
- **Surfaced fact:** Cline "Memory Bank" = structured markdown (`activeContext.md`, `progress.md`, etc.) re-read each session. Aider persists chat history + can `/save`/`/load` context. Cursor memory-bank is a community rules pattern. All converge on the same idea the playbook ships: durable markdown handoff, not tool-proprietary state.
- **Used in:** wrap-and-resume.md (field tests beyond the author)
- **Counter-evidence:** none — convergent evolution validates the pattern.

## 2026-05-31 — Multi-machine continuity

- **Source:** https://docs.syncthing.net/users/syncing.html ; resilio/rsync comparisons
- **Class:** primary + practitioner
- **Surfaced fact:** Syncthing = P2P continuous sync, conflict files named `*.sync-conflict-<date>-<time>-<modifiedBy>.<ext>`. The playbook's answer is "git is the sync layer for anything in a repo; Syncthing only for un-versioned `~/.claude/` state."
- **Used in:** wrap-and-resume.md (multi-machine walkthrough)
- **Counter-evidence:** Syncthing conflict-copies can bite `~/.claude/projects/` if two machines run live — documented as gotcha.

## 2026-05-31 — AI-assisted self-review

- **Source:** https://github.com/anthropics/claude-code-security-review ; code.claude.com/docs/en/code-review
- **Class:** primary
- **Surfaced fact:** `/security-review` is a real bundled command spawning a `security-reviewer` subagent focused on HIGH-CONFIDENCE, newly-introduced vulns only. Also `/code-review`. Open-source GitHub Action mirror exists.
- **Used in:** pr-review-standard.md (AI-assisted review pattern)
- **Counter-evidence:** none.

## 2026-05-31 — Co-authored-by convention

- **Source:** https://docs.github.com/.../creating-a-commit-with-multiple-authors
- **Class:** primary
- **Surfaced fact:** `Co-authored-by: name <email>` trailer, blank line before trailers, use GitHub no-reply email. Multiple co-authors = one line each, no blank lines between.
- **Used in:** commit-cadence.md (agent attribution)
- **Counter-evidence:** none.
</content>
