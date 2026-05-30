# RESEARCH — Phase P06: Session discipline

> **Stream goal:** validate the commit/PR/audit/wrap+resume rules against external practitioner conventions, add concrete hook + script examples, and connect to current 2026 agent-session ergonomics (auto-compaction, session handoff, multi-machine continuity).

## 0. Scope

In:
- `06-session-discipline/README.md` + 4 sub-topic files (`audit-and-conventions-pattern.md`, `commit-cadence.md`, `pr-review-standard.md`, `wrap-and-resume.md`)

Out:
- Branch / slug naming details (chapter 02)
- Ticket-references-in-commits (chapter 01)
- Secret-leak prevention (chapter 05)
- Agent rules (chapter 03)

## 1. What exists today

825 lines across 5 files. Existing depth:

- **Commit cadence** — commit per meaningful change, ticket prefix, push immediately on feature branches, thorough messages
- **PR review standard** — referenced via `~/.claude/docs/pr-review-standard.md` (private to author)
- **Audit + conventions** — dated audits (`audits/YYYY-MM-DD-*.md`), locked conventions (`conventions/*.md`), the boundary
- **Wrap and resume** — `/wrap` session-end ritual, `SessionStart` hook session-start ritual, handoff doc

## 2. Honest gaps

- **`pr-review-standard.md` content isn't inlined.** It points to an author-private doc. Public readers can't actually follow the rule.
- **No working pre-commit / pre-push hook config shipped.** Branch-name regex check, signed-commit check, `Reviewed-by:` trailer check — all mentioned, none demonstrated.
- **`/wrap` and `/resume` are presumably Claude Code slash commands** — but no implementation shown. (Probably skills? Hooks? A combination?) Need an example.
- **Multi-machine continuity** — playbook mentions "Vitalik works across multiple sessions and machines." Need a sub-section on how multi-machine works (Syncthing, push-after-commit discipline).
- **Auto-compaction interaction** — Claude Code compacts context. How does `/wrap` interact with mid-compaction state? When should you wrap before compaction triggers?
- **Conventional Commits, semantic commits, gitmojis** — well-known commit conventions. The playbook is opinionated but doesn't situate itself against them.
- **PR review at the solo-dev scale** — most "PR review standard" docs assume a reviewer who is another human. What's the modification for "I'm both author and reviewer"?
- **Audit log as event log** — what's the relationship to `gsd-` style structured audits? Worth a comparison.

## 3. Research questions

### Commit cadence + messages

- **Q06.1** Conventional Commits — current spec version, adoption. How does it differ from the playbook's "title + ticket + body" pattern?
- **Q06.2** Semantic-release / changesets / release-please — toolchains that consume commit messages. Does the playbook break them? Reconcile.
- **Q06.3** Gitmoji and emoji-prefix commits — popularity, who uses, who avoids.
- **Q06.4** Commit-per-meaningful-change vs squash-on-merge — current practitioner consensus.
- **Q06.5** "WIP commits" on long branches — the right pattern. Reset to upstream + squash? Force-push your branch? Document.

### PR review at solo-dev scale

- **Q06.6** Self-review checklists — find 3+ practitioner posts. e.g., Will Larson, Lara Hogan, Charity Majors.
- **Q06.7** AI-assisted self-review — the playbook references "code + security review on the diff." Find published patterns (claude /security-review skill, github copilot autoreview, sweep/cody review skills, codium).
- **Q06.8** "Reviewed-by:" trailer convention — origin (Linux kernel), other adopters.
- **Q06.9** What does the Linux kernel review process teach the solo dev? (Signed-off-by, Reviewed-by, Tested-by, Reported-by trailers.)
- **Q06.10** Pre-push hook patterns specifically — what to enforce, what to leave optional.

### Audit / conventions pattern

- **Q06.11** ADR (Architecture Decision Records) — Michael Nygard's original post, current practice 2026. How does the playbook's "conventions = locked rules, audits = dated events" map to ADRs?
- **Q06.12** Git-as-event-log patterns — append-only conventions in event-sourcing literature.
- **Q06.13** Living documentation — Cyrille Martraire's *Living Documentation* book; how the playbook fits.

### Wrap / resume / handoff

- **Q06.14** Claude Code's `SessionStart` hook + context-loading patterns — current best practice.
- **Q06.15** What's the published pattern for "session handoff" in agentic tools? (Cursor `.history`, Cline persistent memory, Aider context save.) Compare.
- **Q06.16** Multi-machine continuity — Syncthing in 2026 vs alternatives (Resilio, rsync over SSH, Git as sync mechanism). How does the playbook keep `~/.claude/projects/` consistent?
- **Q06.17** Auto-compaction in Claude Code — when does it fire, what state does it preserve, how does `/wrap` complement it?
- **Q06.18** "Last session left X, this session starts Y" handoff doc structure — find practitioner examples beyond the author.

### Mechanical enforcement

- **Q06.19** Pre-commit framework — current 2026 state, alternatives (lefthook, husky, simple-git-hooks).
- **Q06.20** Branch-name regex hooks — published patterns for `<ticket>/<slug>` enforcement.
- **Q06.21** CI-side commit enforcement — when does it make sense to enforce via CI (GitHub Action checking trailer presence) vs local hook?

### Edge cases

- **Q06.22** What about commits that genuinely need to bypass discipline? (Emergency hotfix, security patch with embargo.) Document the escape hatch.
- **Q06.23** What about pair sessions where Claude Code did most of the work? Attribution conventions — Co-Authored-By, etc.
- **Q06.24** Long-running branches that drift from main — the rebase-vs-merge debate in solo-dev context.

## 4. Per-question source plan

| Q | Source class | Specific starting points |
|---|---|---|
| Q06.1 | Primary | conventionalcommits.org spec. semver.org. |
| Q06.2 | Vendor docs | semantic-release.gitbook.io. changesets/changesets on github. googleapis/release-please. |
| Q06.3 | Practitioner | gitmoji.dev. Surveys on adoption. |
| Q06.4–Q06.5 | Practitioner | martinfowler.com on commit hygiene. dpc.pw posts on git-flow. github engineering blog. |
| Q06.6 | Practitioner | lethain.com (Will Larson). larahogan.me. charity.wtf. |
| Q06.7 | Vendor docs + practitioner | docs.github.com/copilot. cursor.com features. anthropic.com/news on /security-review. codium.ai. |
| Q06.8–Q06.9 | Primary | kernel.org documentation on patch submission. tools/lib/traceevent for actual trailer usage examples. |
| Q06.10 | Practitioner | pre-commit.com hook gallery. github.com/pre-commit/pre-commit-hooks. |
| Q06.11 | Primary | cognitect.com/blog/2011/11/15/documenting-architecture-decisions (Nygard's original). github.com/joelparkerhenderson/architecture-decision-record (current canonical). |
| Q06.12 | Primary (book) | Cyrille Martraire, *Living Documentation*. Eric Evans on event sourcing. |
| Q06.13 | Primary (book) | Same source as Q06.12. |
| Q06.14 | Primary | docs.claude.com hooks documentation. |
| Q06.15 | Vendor docs | cursor.com `.history` docs. cline.bot memory docs. aider.chat session save docs. |
| Q06.16 | Vendor docs | syncthing.net docs. resilio.com docs. |
| Q06.17 | Primary | docs.claude.com on context management / compaction. anthropic.com/engineering posts. |
| Q06.18 | Practitioner | search github for "session-handoff.md" or "WRAP.md" patterns. |
| Q06.19 | Primary | pre-commit.com. evilmartians/lefthook. typicode/husky. toplenboren/simple-git-hooks. |
| Q06.20 | Practitioner | github.com search for branch-name pre-commit hooks. |
| Q06.21 | Vendor docs | docs.github.com/actions, gitlab.com/ci docs. |
| Q06.22–Q06.24 | Practitioner | dpc.pw, martinfowler.com on rebase-vs-merge in solo context. |

## 5. Output requirements

The agent updates files in `/Users/pleasedodisturb/Projects/playbooks/solo-dev-pmo/06-session-discipline/`:

1. **README.md** gains:
   - Brief situation against Conventional Commits / Gitmoji (one paragraph)
   - "Self-review at solo-dev scale" callout
2. **`commit-cadence.md`** gains:
   - Conventional Commits compatibility note (the playbook's pattern is super-set-compatible)
   - WIP-commits-on-long-branches recipe (rebase + squash before merge)
   - Co-Authored-By attribution example when Claude Code did most of the work
3. **`pr-review-standard.md`** gains:
   - **The full checklist inlined** (current chapter points to a private author doc — readers can't follow). Include: correctness, security (cross-ref chapter 05), tests, conventions, ticket-referenced, signed.
   - Self-review framing — what's the same vs different from team review
   - AI-assisted review pattern (skill spawn, what to ask, what to ignore)
   - Bypass / emergency-hotfix escape hatch
4. **`audit-and-conventions-pattern.md`** gains:
   - Explicit ADR comparison — when audit, when convention, when ADR
   - Cite Nygard
   - Example of each (one audit, one convention, one ADR equivalent if appropriate)
   - Reference Cyrille Martraire for the "living documentation" angle
5. **`wrap-and-resume.md`** gains:
   - **Actual /wrap implementation** — either as a skill, a hook, or both. Show the file.
   - **Actual SessionStart hook** that surfaces the handoff doc — show the file.
   - Multi-machine continuity walkthrough (Syncthing + commit-push discipline)
   - Auto-compaction interaction note
   - Handoff doc template (concrete markdown structure)
6. **New file:** `06-session-discipline/hook-and-script-examples.md` — pre-commit / pre-push / branch-name regex examples; pre-commit framework config; safe-pattern for UserPromptSubmit hooks
7. **New file:** `06-session-discipline/sources.md` — bibliography

Constraints:
- DO NOT inline the secret-scanning hooks (chapter 05 territory — link only)
- DO NOT inline the agent-spawn rules (chapter 03 territory — link only)
- DO NOT recommend Husky over pre-commit unless evidence supports it
- The PR review checklist must work even if Claude Code is the reviewer (solo-dev scale assumes this)

## 6. Per-phase search ideas

### Web

- `site:conventionalcommits.org spec`
- `site:semantic-release.gitbook.io`
- `site:pre-commit.com hook gallery`
- `gitmoji adoption 2025 OR 2026`
- `site:cognitect.com architecture decision record`
- `Michael Nygard ADR`
- `living documentation Martraire`
- `site:lethain.com self review`
- `site:martinfowler.com commit hygiene`
- `Linux kernel "Reviewed-by:" trailer`
- `pre-push hook signed commit`
- `Claude Code SessionStart hook example`
- `Cursor .history Cline aider session`

### Social

- HN: `https://hn.algolia.com/?q=conventional+commits`
- HN: `https://hn.algolia.com/?q=ADR+architecture+decision`
- HN: `https://hn.algolia.com/?q=pre-commit+hooks`
- HN: `https://hn.algolia.com/?q=self+review+solo`
- Lobsters: `https://lobste.rs/search?q=git+hooks`
- Lobsters: `https://lobste.rs/search?q=conventional+commits`
- Reddit: `site:reddit.com/r/git conventional commits`
- Reddit: `site:reddit.com/r/programming self code review`
- Reddit: `site:reddit.com/r/ExperiencedDevs PR review checklist`
- Reddit: `site:reddit.com/r/ClaudeAI sessionstart resume`
- X: handles `@martinfowler`, `@lethain`, `@charity_majors`, `@karpathy`

### GitHub

- `topic:pre-commit-hooks`
- `topic:conventional-commits`
- `topic:adr` (architecture decision records)
- Code search: `filename:CONTRIBUTING.md "Reviewed-by"`
- Code search: `filename:.pre-commit-config.yaml branch-name`
- `joelparkerhenderson/architecture-decision-record` — canonical ADR repo
- `pre-commit/pre-commit-hooks` — core hooks
- `evilmartians/lefthook` — alternative
- `cocogitto/cocogitto` — commit-convention enforcement
- Code search: `filename:CLAUDE.md "/wrap"` to see other practitioners' wrap rituals
- Code search: `filename:WRAP.md` or `filename:SESSION.md` for handoff doc patterns

### Specific

- claude-code-skills repos (e.g., garrytan/gstack) for /wrap, /resume, /session implementations
- awesome-claude-code list for relevant skills
- Linux kernel `Documentation/process/submitting-patches.rst`

## 7. Stop conditions

Stop and surface if:

- Claude Code changes the hook contract in a way that breaks the /wrap implementation pattern.
- Conventional Commits major version revision (2.0?) lands during research — affects compatibility note.
- A widely-adopted alternative to pre-commit emerges with material advantage — re-rank.
- The "Reviewed-by:" trailer convention turns out to be Linux-kernel-only with no broader adoption — soften the language.

## 8. Estimated effort

M phase. 5–8 hours research + 5–7 hours writing. The shipped /wrap + SessionStart hook examples are the chapter's signature deliverable; budget time to test them in a real Claude Code session.
