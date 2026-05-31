# Cheatsheet discipline

> When you learn something daily-use worthy, propose a cheatsheet edit in the same response — don't just save a memory and move on.

## The rule

Cheatsheets are useful only if they reflect current reality. When new features ship or new gotchas surface, the cheatsheet must move in lockstep — otherwise it silently rots, and future-you has to re-discover the same things.

## Origin

A real example: a new `CLAUDE_DEADMAN_THRESHOLD=N` launch-time bypass + `c --research N` wrapper shipped. The canonical doc was updated, but `claude-code-cheatsheet.md` and `zsh-cheatsheet.md` were not. Next day: "how do I set the budget for new agents now?" The user had to re-find the answer.

That's the cost. The discipline is the cure.

## What counts as "daily-use worthy"

Something you'll plausibly grep for or invoke `cheat` on within the next 90 days:

- A new flag, env var, alias, or shell function (especially after shipping a feature)
- A gotcha that cost time to discover (the failure mode + the fix)
- A "use X not Y" substitution (`rg` over `grep`, `glow` over `less`, etc.)
- A command sequence used more than once (verification recipes, lookup recipes)
- A version pin or installed-vs-not-installed tool note

## What does NOT count

- **One-shot project state** ("we're on phase 4") → goes in MEMORY.md (Layer 3), not cheatsheets
- **Narrative / situational context** → memory, not cheatsheet
- **Internal codebase patterns derivable from `git grep`** → no doc needed
- **Speculation** ("X *might* be useful later") → wait until confirmed

## How to apply

### In-session

When you notice cheatsheet-worthy content, add it to the relevant cheatsheet **immediately**. Pick by topic:

- `claude-code-cheatsheet.md` — Claude Code CLI flags, hooks, sandbox controls
- `zsh-cheatsheet.md` — shell functions, aliases, keybinds
- `tools-cheatsheet.md` — CLI tools (`rbw`, `jq`, `gh`, `rg`, etc.)
- `gsd-cheatsheet.md` — GSD workflow commands
- `linear-cheatsheet.md` — Linear / `linearis` CLI
- `git-cheatsheet.md` — git ops and conventions
- `tmux-cheatsheet.md`, `ghostty-cheatsheet.md`, `window-management-cheatsheet.md`, `workflow-cheatsheet.md` — self-explanatory

### Keep entries terse

One row / one bullet. Link to fuller docs.

```markdown
| Command | What it does | When to use |
|---|---|---|
| `rg -F "literal string"` | Search with NO regex interpretation | When pattern contains `.`, `*`, `?` |
| `gh pr view <N> --json reviewers` | List PR reviewers | Checking review status without opening browser |
```

### Audit at /wrap

A `/wrap` Phase 1.5 step "Cheatsheet Sweep" walks the conversation looking for missed items. Catch the things you almost forgot to write down.

### Daily cadence

Optionally: a launchd job that scans recent sessions for `cheat`-worthy content; until that lands, `/wrap` is the only safety net.

## Where edits land

Cheatsheets live in a repo (e.g., `~/Projects/<your-cheats>/docs/*-cheatsheet.md`). Git-tracked. Every edit goes through branch + PR + merge per global Git Workflow rule. No "small change" exemption. Bundle related cheatsheet edits into one ticket where it makes sense.

## Sample cheatsheet structure

```markdown
# Git Cheatsheet

## Common ops

| Command | What | When |
|---|---|---|
| `git switch <branch>` | Switch branches (newer than `git checkout`) | Modern git, > 2.23 |
| `git restore <file>` | Discard changes (newer than `git checkout`) | Same |
| `git switch -c <branch>` | Create and switch | New branch |

## My aliases

- `gst` → `git status`
- `gco` → `git checkout`
- `gca` → `git commit --amend --no-edit`

## Gotchas

- **`--no-verify` skips pre-commit AND pre-push hooks.** Never use unless explicit override.
- **`git reset --hard` is destructive.** No undo without reflog.
- **Force-push to main is forbidden by global rule.** Don't.

## Recipes

### Commit with ticket prefix and trailer
```bash
git commit -m "G-XXX: short subject

Body.

Reviewed-by: <agent> (code+security)"
```

### Add review trailer to existing commits
```bash
git rebase -x 'git commit --amend --no-edit --trailer "Reviewed-by: <agent> (code+security)"' main..HEAD
```

## See also
- `~/.claude/CLAUDE.md` § Git Workflow
- `~/.claude/docs/pr-review-standard.md`
```

The format: tables for "command → what → when," sections for "gotchas," "recipes," "see also." Optimized for `cheat git` lookup.

## Last-validated stamp

Put a freshness marker at the top of every cheatsheet so staleness is *visible* rather than silent:

```markdown
# git cheatsheet
<!-- last-validated: 2026-05-31 -->
```

`last-validated` means "the last time I confirmed these commands still work" —
not "last edited." The distinction matters: a file you edited yesterday to fix a
typo wasn't *validated* yesterday. Refresh the stamp when you touch an entry or
when a quarterly audit re-confirms it. The
[cheats-starter pre-commit hook](./cheats-starter/hooks/pre-commit) bumps the
stamp automatically on any cheatsheet you commit, so the floor is "stamp ≥ last
real edit." An HTML comment keeps it invisible in rendered output but greppable
(see the stale-stamp scan below).

## Detecting rot (automation)

The leading indicator of rot is *age of the stamp*. Two cheap scans catch the rest:

1. **Stale-stamp scan** — `rg -l 'last-validated: 202[0-4]' "$CHEATS_DIR"` lists
   everything not validated since 2024; tighten the regex to your threshold.
2. **Dead-link scan** — cheatsheets cite vendor docs and URLs rot. Run
   [`lychee`](https://github.com/lycheeverse/lychee)[¹] in CI or as a pre-commit
   hook (`lycheeverse/lychee-pre-commit`). For linkrot resilience, link to a
   *stable* doc root over a deep-versioned URL, and keep the canonical command
   (`git help rebase`) next to any external link so the entry survives the link
   dying.

A dead *command* is harder to detect than a dead link — there's no general
checker. That's what the quarterly read-through and "test before you commit"
are for.

## When to point an agent at your cheatsheets

Claude Code already knows public command syntax better than any cheatsheet you'd
write — so **don't** feed it a `tar` cheatsheet. Point it at the cheatsheets that
encode *your* decisions, which it can't infer:

- **Do** `@`-import the load-bearing ones into `CLAUDE.md` — your aliases,
  `linearis` recipes, deploy gotchas. Imports resolve recursively, so
  `@cheats/docs/linear-cheatsheet.md` keeps the root file lean.[²]
- **Do** let a skill grep the cheats dir (`rg "$query" "$CHEATS_DIR"`) when the
  agent needs a project-specific recipe — same `rg` recipe a human uses.
- **Don't** auto-load all of them. A 2,000-line dump of public command syntax
  burns context for negative value; keep `CLAUDE.md` under ~200 lines and import
  selectively.[²]
- **Don't** treat agent capability as a reason to stop writing cheatsheets. The
  agent doesn't know your aliases or last week's decision — and *you* still
  `cheat git` when the agent isn't in the loop.

Virtuous loop: when the agent discovers a gotcha mid-session, have it propose the
cheatsheet edit in the same response — the discipline rule applies to it too.

## Field-tested gotchas

**Cheatsheet entries that rot.** The flag changed, the syntax changed, the env var renamed. Audit quarterly: read your own cheatsheets and verify each command still works.

**Multiple cheatsheets covering the same topic.** "Is this in `git` or `workflow`?" — when topics overlap, pick a canonical home and cross-reference.

**Cheatsheet too long.** A 1000-line `git-cheatsheet.md` is hard to scan. Split into `git-basics`, `git-rewriting-history`, `git-hooks`, etc.

**Adding an entry but not testing it.** Cheatsheet entries are claims about how something works. Run the command before checking in.

## Innovative pattern: cheatsheet from cheat history

`cheat` shell function logs lookups:

```bash
cheat() {
  local topic="$1"
  echo "$(date) $topic" >> ~/.local/share/cheat-history
  # ... show the cheatsheet
}
```

Weekly review of cheat-history reveals:
- Most-looked-up topics → expand those cheatsheets
- Topics looked up that don't exist → write new cheatsheets
- Cheatsheets never accessed → audit relevance

## Innovative pattern: cheatsheet-driven onboarding doc

When someone joins (collaborator, contractor, future-you on a new machine), point them at `~/Projects/<cheats>/docs/`. The cheatsheets ARE the onboarding doc.

For solo dev: the cheatsheets ARE the onboarding doc for future-you on a fresh setup.

## Version matrix (prior-art tools, May 2026)

| Tool | Version / status | Note |
|---|---|---|
| `tldr` (repo) | 59k★, 1,000+ contributors, ~thousands of pages | community pages; supports local custom pages |
| `tealdeer` (Rust client) | 1.8.x | custom pages via `custom_pages_dir`, tldr format |
| `cheat.sh` | actively maintained; local Docker for private | `curl cht.sh/<cmd>`, no install |
| `cheat/cheat` | 5.1.0 (Feb 2026), 13k★ | `cheatpaths`, tags, fzf, shell completion |
| `navi` | 2.x | interactive `fzf` runner, `<arg>` prompts |
| `eg` | maintained | example-based, zero-config |
| `bro` / bropages | **deprecated** (archived 2022) | don't adopt |

## Field tests beyond the author

The free-form-markdown + shell-function pattern is widespread in dotfiles repos
(`cheat()` over a `~/cheats` dir is a common idiom), and `cheat/cheat`'s
`cheatpaths` is the same idea productised — independent convergence on "personal
markdown + a lookup command." We found no external study measuring cheatsheet
rot rates; the `last-validated` practice is borrowed from living-documentation
and SRE runbook freshness conventions[³], not a cheatsheet-specific source. Treat
the 6-month threshold as a starting default, not an evidenced number.

## What we'd change in 2026

- **Recommend `cheat/cheat` as the on-ramp.** For a reader who wants search +
  completion out of the box it's less to maintain; keep the function for the
  zero-dependency / total-freedom case.
- **Stop hand-rolling `cheat-history`.** `cheat/cheat` and `navi` give usage
  signal for free; build the logging shim only if you stay on the bare function.
- **Lean harder on `@`-imports.** Agent consultation wasn't an original design
  input; today the load-bearing cheatsheets should be written to be imported.

## Related

- [cheats-starter](./cheats-starter.md) — the tested skeleton these rules apply to
- [Living docs](./living-docs.md) — runbooks and FAQs share this freshness discipline
- [Chapter 06 — Wrap and resume](../06-session-discipline/wrap-and-resume.md) — `/wrap` audits cheatsheet coverage
- [Chapter 03 — Memory architecture](../03-claude-code-as-operator/memory-architecture.md) — cheatsheets ≠ memory
- [Chapter 06 — Commit cadence](../06-session-discipline/commit-cadence.md) — cheatsheet edits are commits, follow the cadence

---

[1]: lychee — fast async link checker for markdown/HTML/CI. https://github.com/lycheeverse/lychee — accessed 2026-05-31
[2]: Claude Code memory & `@`-imports (recursive, ~200-line CLAUDE.md guidance). https://code.claude.com/docs/en/overview — accessed 2026-05-31
[3]: Google, *Site Reliability Engineering* — playbook/runbook freshness. https://sre.google/sre-book/being-on-call/ — accessed 2026-05-31
