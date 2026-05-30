# Slug rules

> The canonical slug = the disk folder leaf name AND the GitHub repo name. They must always match. One deterministic format. No exceptions.

## The rules

| Rule | Example ✓ | Counter-example ✗ |
|---|---|---|
| All lowercase | `infra-cleanup` | `Infra-Cleanup`, `InfraCleanup` |
| Words separated by `-` only | `learning-rust` | `learning_python`, `learningPython` |
| Acronyms lowercased | `mac-setup`, `llm-research` | `macOS-setup`, `LLM-research` |
| ASCII letters + digits + `-` only | `case-acme` | `café-app`, `case.acme` |
| No leading/trailing `-` | `your-toolkit` | `-your-toolkit`, `your-toolkit-` |
| No double `--` | `repo-sync-tool` | `repo--sync` |

## Why one format

Tooling: a `repo-sync-tool` script (or your equivalent) checks for drift. It needs ONE pattern to validate. Adding "but TitleCase is allowed for these specific repos" multiplies regex complexity by N, and the script becomes a leaky enforcer.

Also: GitHub repo URLs preserve the original case but compare case-insensitively. `Infra-Cleanup` on disk → `github.com/<user>/Infra-Cleanup` works in browsers, breaks in scripts that do exact-match.

Pick one format. Enforce it everywhere.

## No grandfathered TitleCase exceptions

Tempting: "but I'd like `~/Projects/Money/` capitalized — it's important."

This temptation has a specific failure mode. Original v1 of a real solo-dev's convention carved out `app-bar/` and `Money/` as exceptions because rename blast radius "looked huge" — counts of 391 and 255 references in scripts.

On 2026-05-29 measurement, those numbers conflated three categories:

| Category | Real cost | Apparent cost |
|---|---|---|
| References *inside* the artifact being moved | Zero work (moves with the artifact) | High (inflates the count) |
| JSONL session transcripts (append-only, never edited) | Zero work (no need to update) | High (inflates the count) |
| Actual external editable references | Real work | Real work |

Actual rename work after demolishing the inflation: **13 files for app-bar, 17 files for Money.** ~30 minutes each.

The grandfathered exceptions weren't justified. Don't grandfather. Migrate.

## `-temp` exemption

Folders ending in `-temp` are throwaway and exempt from these rules.

```
~/Projects/scratch/mac-mini-cleanup-temp/    # OK, exempt
~/Projects/scratch/app-foo-wiki-temp/        # OK, exempt
```

The `-temp` suffix is the signal: this folder doesn't need a convention because it's not going to live long. Don't bother with conventions for things you're about to delete.

Non-`-temp` scratch folders (no git, no clear purpose) get a one-time audit before deletion or formal adoption.

## Disk leaf MUST match GitHub repo name

A project on disk at `~/Projects/research/learning-rust/` MUST have a GitHub repo at `github.com/<user>/learning-rust`.

This rule is what makes sync tooling possible. Without it, you'd need a mapping table somewhere; with it, `git remote get-url origin | basename` produces the slug.

When you create a new repo:
1. Decide the slug. Apply rules.
2. `mkdir ~/Projects/<category>/<slug>` and `cd` in.
3. `git init` and create files.
4. `gh repo create <slug> --public --source=. --push` — note no leading user spec; uses default.

When you rename a repo:
1. Disk: `mv ~/Projects/<category>/<old-slug> ~/Projects/<category>/<new-slug>`.
2. GitHub: `gh repo rename <old-slug> <new-slug>` (from inside the repo, before the disk `mv` since `gh` doesn't depend on cwd).
3. Local remote: `git remote set-url origin git@github.com:<user>/<new-slug>.git`.
4. Sweep references: `grep -rn "<old-slug>"` and update everything in your repo/dotfiles/scripts that names it.
5. Audit Claude Code memory dir name and rename if needed.

## Branch naming

Same lowercase + `-` rule, but with a ticket prefix:

```
<ticket-id>/<short-description>
```

Examples:
- `G-240/license-agpl3` ✓
- `G-1234/fix-scoring-bug` ✓
- `feature/scoring` ✗ (no ticket ID)
- `G-240-license-agpl3` ✗ (uses `-`, not `/`, separator)

The `<ticket-id>/<desc>` form lets git tooling group all branches for one ticket. Branches without a ticket prefix get rejected at PR review.

## Commit subject prefix

Every commit references a ticket:

```
G-240: add CC BY 4.0 license

Adds CC BY 4.0 prose license, MIT for code.
Fixes the OSS-compliance requirement.

Co-Authored-By: claude-opus-4-7 <noreply@anthropic.com>
```

The prefix lets you `git log --grep="G-240"` to find all work for one ticket. Non-prefixed commits are noise.

For ticket-less work (one-off cleanup, docs typo): no exception. Either it's worth a ticket or it shouldn't be a commit on its own.

## File and directory naming inside a repo

Inside a repo, use the language ecosystem's convention:
- Python: `snake_case.py`
- JS/TS: `kebab-case.ts` typically, sometimes `camelCase`
- Markdown docs: `kebab-case.md`
- Shell scripts: `kebab-case.sh`

The slug rules apply at the project boundary (disk leaf, GitHub repo name). Inside the repo, follow ecosystem norms.

## Convention files inside the meta-PM repo

Convention files live at:

```
conventions/<topic>.md
```

E.g., `conventions/naming.md`, `conventions/states.md`, `conventions/cycles.md`.

No date prefix (they're edited in-place, not append-only). The filename IS the canonical name of the rule. Link to it from CLAUDE.md and from everywhere the rule is enforced.

## Audit files inside the meta-PM repo

Audits live at:

```
audits/YYYY-MM-DD-<slug>.md
```

E.g., `audits/2026-05-18-linear-hygiene-execution.md`.

Date prefix because they're append-only. Each audit is one session of work; the filename communicates time-of-record.

Don't edit old audits. If you discover later that an audit was wrong, write a NEW audit that supersedes it.

## Field-tested gotchas

**Typos in slugs propagate.** Real example: `pm-systme` was the original slug for a `command-center` predecessor. The typo lived in GitHub URL, disk path, in-repo refs, and Claude Code memory dir for ~2 weeks before getting fixed. Renaming required updating ALL of those.

**Renames are not "just a `mv`."** Five places that hold the old name:
1. Disk path
2. GitHub repo
3. Local git remote URL
4. Claude Code memory directory
5. In-repo references (CLAUDE.md, scripts, docs)

Plus:
6. `.zshrc` aliases, shell functions
7. Symlinks anywhere on disk pointing at the old path
8. MCP configs (Claude Code's `.mcp.json`)
9. Launchd plists that reference the path
10. Cron jobs

A rename script that hits all 10 places is worth writing. See [Chapter 06 — post-rename cleanup](../06-session-discipline/) — and warn-before-renaming should be a global rule.

**Case-insensitive collision on macOS.** macOS HFS+ and APFS are case-insensitive by default. `~/Projects/foo/` and `~/Projects/Foo/` are the same folder. The slug rules prevent this by mandating lowercase, but you may encounter remnants from before you adopted the rule.

**GitHub `Discussion` URLs are case-sensitive in some places.** Edge case but worth knowing.

## Innovative pattern: pre-commit hook validation

In your meta-PM repo, a pre-commit hook validates that any added repo references match slug rules:

```bash
#!/usr/bin/env bash
# .githooks/pre-commit — flag slug rule violations
git diff --cached --name-only \
  | xargs grep -l 'repo:' \
  | while read -r file; do
      grep -E '^repo: [^a-z0-9-]' "$file" && echo "Bad slug in $file" && exit 1
    done
```

Catches typos before they land in the repo.

## Innovative pattern: drift detector daily

A daily launchd job runs:
```bash
for d in ~/Projects/*/*/; do
  slug=$(basename "$d")
  if ! [[ $slug =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "$slug violates slug rules" | ntfy-send
  fi
done
```

Drift gets visible within 24 hours instead of accumulating for months.

## Related

- [Layout B](./layout-b-subfolders.md) — the category subfolders the slugs live in
- [Linear ↔ GitHub binding](./linear-github-binding.md) — `repo: <slug>` tag
- [Chapter 06 — Audit pattern](../06-session-discipline/audit-and-conventions-pattern.md) — how conventions are managed
