# Sources — Chapter 06: Session discipline

Bibliography rollup for the P06 enrichment. All accessed 2026-05-31 unless noted. Weighting per [SEARCH-PLAYBOOK](../.planning/SEARCH-PLAYBOOK.md) source classes.

## Primary — vendor docs (★★★★★)

| # | Source | Used for |
|---|---|---|
| 1 | [Claude Code — Hooks reference](https://code.claude.com/docs/en/hooks) | SessionStart/PreCompact/UserPromptSubmit contract; matchers; `additionalContext` |
| 2 | [Claude Code — Skills](https://code.claude.com/docs/en/skills) | `/wrap` skill; commands-are-skills; `disable-model-invocation`, `allowed-tools` |
| 3 | [Claude Code — Manage costs (compaction)](https://code.claude.com/docs/en/costs) | Auto-compaction, `/compact`, `/clear`, `/resume` background summarization |
| 4 | [Claude Code — Code review](https://code.claude.com/docs/en/code-review) | `/code-review`, `/security-review` |
| 5 | [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) | Commit-format super-set note; BREAKING CHANGE; footer/trailer convention |
| 6 | [Linux Kernel — Submitting patches](https://docs.kernel.org/process/submitting-patches.html) | `Reviewed-by:` Reviewer's Statement; Signed-off-by/Tested-by/Acked-by ladder |
| 7 | [git-interpret-trailers](https://git-scm.com/docs/git-interpret-trailers) | Trailer format; `git commit --trailer` |
| 8 | [GitHub Docs — Commit with multiple authors](https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors) | `Co-authored-by:` attribution rules |
| 9 | [pre-commit.com](https://pre-commit.com/) | Framework config, per-stage install, `no-commit-to-branch` |
| 10 | [pre-commit/pre-commit-hooks](https://github.com/pre-commit/pre-commit-hooks) | Core hook gallery (trailing-whitespace, check-added-large-files, etc.) |
| 11 | [Syncthing — Understanding synchronization](https://docs.syncthing.net/users/syncing.html) | Multi-machine continuity; `*.sync-conflict-*` handling |
| 12 | [Cline — Memory Bank](https://docs.cline.bot/features/memory-bank) | Field test: structured-markdown session memory (convergent with the playbook) |

## Primary — canonical repos / engineering (★★★★)

| # | Source | Used for |
|---|---|---|
| 13 | [Nygard, "Documenting Architecture Decisions" (2011)](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions.html) | Original ADR template — Title/Status/Context/Decision/Consequences; superseded-not-deleted |
| 14 | [joelparkerhenderson/architecture-decision-record](https://github.com/joelparkerhenderson/architecture-decision-record) | Canonical ADR templates; confirms Nygard format is still standard |
| 15 | [anthropics/claude-code-security-review](https://github.com/anthropics/claude-code-security-review) | `/security-review` subagent + GitHub Action; high-confidence-only review |
| 16 | [semantic-release](https://semantic-release.gitbook.io/semantic-release/) | Toolchain that consumes commit types → SemVer |
| 17 | [changesets/changesets](https://github.com/changesets/changesets) | Alternative release-versioning toolchain |
| 18 | [evilmartians/lefthook](https://github.com/evilmartians/lefthook) | Hook-manager alternative (Go, parallel, polyglot) |

## Practitioner / community (★★★)

| # | Source | Used for |
|---|---|---|
| 19 | [Will Larson — "How to create software quality"](https://lethain.com/quality/) | Self-review: team review is often fast-but-low-signal; structure > intentions |
| 20 | [Martin Fowler — Architecture Decision Record](https://martinfowler.com/bliki/ArchitectureDecisionRecord.html) | ADR adoption framing |
| 21 | [Andy Madge — Git hook frameworks comparison (2026)](https://www.andymadge.com/2026/03/10/git-hooks-comparison/) | pre-commit vs lefthook vs husky vs simple-git-hooks |
| 22 | [Gitmoji](https://gitmoji.dev/) | Emoji-commit convention (rejected, with reasons) |
| 23 | [aider — in-chat commands](https://aider.chat/docs/usage/commands.html) | Field test: session save/restore in another agentic tool |

## Books (★★★★)

| # | Source | Used for |
|---|---|---|
| 24 | Cyrille Martraire, *Living Documentation* (Addison-Wesley, 2019) | Repo-as-living-document; git log as generated, drift-proof history |

## Notes on stop-condition watch items (brief §7)

- **Hook contract change** — re-verified 2026-05-31; intact, now includes `SessionEnd`. The `/wrap` + SessionStart examples hold. **Not triggered.**
- **Conventional Commits 2.0** — current is still v1.0.0; no revision landed. **Not triggered.**
- **pre-commit superseded** — lefthook is faster for polyglot but pre-commit's gallery + isolation keep it the default. Re-rank not warranted. **Not triggered.**
- **`Reviewed-by:` kernel-only** — adoption confirmed across Git, Gerrit, QEMU, U-Boot; language kept firm, not softened. **Not triggered.**
