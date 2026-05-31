# Migration recipe: cleaning up 30–50 repos into Layout B

> You have a `~/Projects/` zoo and want [Layout B](./layout-b-subfolders.md). This is the full procedure — five phases, a manifest format, and the post-move fix scripts. It moves and renames directories, so read the safety section first; it is not optional.

---

## ⚠️ Read this first — why this is dangerous

Moving a project directory is **not** a `mv`. It silently breaks every tool that baked the *old absolute path* into a file: Python venvs, `node_modules`, `direnv`, git worktrees, shell command caches, and Spotlight's index. Most of these fail *later*, quietly, far from the move — which is what makes a careless migration a multi-day debugging sink.

The non-negotiable rules:

1. **Back up before you touch anything.** A full Time Machine snapshot or a `git push` of every repo. This recipe has no undo.
2. **Clean working tree, pushed, before each move.** Untracked or uncommitted work is the one thing a move can *lose* (a half-applied move, a typo'd `mv`). `git status` clean + `git push` first, every repo.
3. **Move whole repos as a unit.** The `.git` directory travels with the repo. Never move sub-pieces. Git **remote URLs survive** a move (they're URLs, not paths); local absolute paths do not.
4. **One repo, or atomic batches of 5–7, with verification between.** Never migrate everything in one shot.
5. **Never mass-rename with a script on day one.** Categorization needs human judgment (Phase 2). Scripts come *after* the manifest is reviewed.
6. **Remove worktrees before moving their repo.** Git stores absolute paths in worktree links and can `git worktree repair` a moved worktree — but if you move **both** the repo *and* its worktrees, "links are severed in both directions and no repair is possible."[⁵] Delete worktrees first (they're disposable), migrate, recreate.
7. **Plan to recreate, not relocate.** venvs and `node_modules` are disposable build artifacts — rebuild them at the destination; don't try to preserve them.

Field-tested timing: **30–50 repos = 2–3 weekends** of careful work. Broken absolute paths in venvs, hooks, MCP configs, and symlinks are slow to diagnose later — the slowness is the cost you're buying down by going slow now.

---

## The five phases

### Phase 1 — Enumerate

List everything at top level. Don't categorize yet; just inventory.

```bash
find ~/Projects -maxdepth 1 -mindepth 1 -type d | sort > /tmp/projects-inventory.txt
wc -l /tmp/projects-inventory.txt
```

### Phase 2 — Categorize into a TSV manifest

Human judgment, not a script. One row per repo. A TSV (tab-separated) manifest is the source of truth for the whole migration — review it, commit it to your meta-PM repo, *then* act on it.

```tsv
current_path	slug	category	action	notes
~/Projects/Infra-Cleanup	infra-cleanup	infra	move+rename	TitleCase → slug
~/Projects/app-foo	app-foo	apps	move	already slugged
~/Projects/pm-systme	command-center	infra	move+rename	fix old typo slug
~/Projects/random-spike	random-spike-temp	scratch	move+rename	dead; delete after 30d
~/Projects/research	-	-	split	umbrella dir → scratch/old-research/
```

Columns: where it is now, the target [slug](./slug-rules.md), the target [category](./layout-b-subfolders.md), the action (`move`, `move+rename`, `split`, `delete`, `leave`), and a note. Every row gets a human decision.

### Phase 3 — Validate the categorization

Read the manifest top to bottom. Two checks:

- **Orphans.** A repo that fits no category is a signal your taxonomy is incomplete (this is how `upstream/` got added — fork-maintenance work fit nowhere). Add the category; don't force-fit.
- **Collisions.** Watch the umbrella-vs-category trap (`research/` the umbrella vs `research/` the category — see [Layout B](./layout-b-subfolders.md#the-research-collision-trap)). Resolve in the manifest before moving.

### Phase 4 — Move in atomic batches

For each repo, sweep for the old absolute path *before* moving, move with guardrails, verify after. Don't proceed to the next batch until the current one is green.

```bash
# 1. Pre-move sweep: who hardcodes this absolute path?
OLD="$HOME/Projects/Infra-Cleanup"
grep -rln "$OLD" ~ 2>/dev/null    # .zshrc, .envrc, launchd plists, MCP configs, symlinks…

# 2. Guarded move (refuses dirty trees and repos with live worktrees):
move_repo() {                      # move_repo <src> <dest>
  local src="$1" dest="$2"
  git -C "$src" diff --quiet && git -C "$src" diff --cached --quiet \
    || { echo "UNCOMMITTED in $src — skipping"; return 1; }
  [ -n "$(git -C "$src" worktree list | tail -n +2)" ] \
    && { echo "$src has worktrees — remove them first"; return 1; }
  mkdir -p "$(dirname "$dest")"
  mv "$src" "$dest"
  git -C "$dest" rev-parse --git-dir >/dev/null 2>&1 \
    && echo "ok: $dest" || echo "BROKEN git at $dest"
}

move_repo "$HOME/Projects/Infra-Cleanup" "$HOME/Projects/infra/infra-cleanup"
```

If the slug also changes on GitHub, rename the remote repo too — but mind the redirect caveat: GitHub keeps `clone`/`fetch`/`push` redirects after a rename, **but if you ever create a new repo with the old name, the redirect breaks**, and GitHub Actions references are *not* redirected.[⁶]

```bash
gh repo rename infra-cleanup --repo <user>/Infra-Cleanup   # GitHub side
git -C ~/Projects/infra/infra-cleanup remote set-url origin \
  git@github.com:<user>/infra-cleanup.git                  # local remote
```

Then run the post-move fix scripts below for that repo before moving on.

### Phase 5 — Audit and lock

Final pass for orphans, then write the locked rules into `conventions/naming.md` and record the migration in a dated `audits/YYYY-MM-DD-projects-migration.md` (see [Chapter 06](../06-session-discipline/audit-and-conventions-pattern.md)). Document *why* `scratch/old-research/` exists so future-you doesn't re-litigate it.

---

## Post-move fix scripts

Run these in each moved repo. They assume you took rule #7 to heart: recreate, don't relocate.

### Python venvs — recreate, never relocate

Python venvs are non-relocatable **by design**: script shebangs "contain the absolute paths to their environment's interpreters … environments are inherently non-portable," and the docs are explicit that "if … you need to move the environment … you should recreate it at the desired location and delete the one at the old location."[¹] So delete and rebuild:

```bash
# wipe every venv under the moved repo, then rebuild
find . -maxdepth 3 -name pyvenv.cfg -exec sh -c 'rm -rf "$(dirname "$1")"' _ {} \;
uv venv && uv sync                       # if using uv
# or: python -m venv .venv && .venv/bin/pip install -e .
```

If you genuinely must move a venv in place, `uv` offers an opt-in `uv venv --relocatable` (avoids hardcoded absolute paths in activation scripts).[²] For a bulk migration, recreate is simpler and more robust.

### Node — wipe and reinstall

`node_modules` is non-portable and disposable: `.bin/` entries and `npm link` symlinks point at absolute paths in the global store, so they dangle after a move.[³] Never commit it; regenerate it:

```bash
rm -rf node_modules
npm ci          # or: pnpm install / yarn install
```

### direnv `.envrc` — derive paths, don't hardcode

An `.envrc` that hardcodes an absolute path breaks on move; the direnv stdlib is built to derive paths from `$PWD` so they self-heal. `layout python` "creates and loads a virtualenv environment under `$PWD/.direnv/python-$version`."[⁴]

```bash
# BAD  (absolute — breaks when the repo moves):
#   layout python /Users/me/Projects/foo/.venv
# GOOD (derived from $PWD — survives any move):
layout python
# or, for an existing .venv:
export VIRTUAL_ENV="$PWD/.venv"
layout python-venv
```

```bash
direnv allow      # re-approve after editing .envrc
```

### git worktrees — repair (or, better, recreate)

If you moved a main repo that had worktrees (and did *not* move the worktrees themselves), point them back:

```bash
git -C ~/Projects/infra/infra-cleanup worktree repair
```

If both moved, repair is impossible[⁵] — `git worktree prune` and recreate. This is exactly why safety rule #6 says remove worktrees *before* moving.

### Shell and Spotlight — flush stale caches

After binaries relocate, the shell may still invoke old paths, and Spotlight/`mdfind` may return stale hits until reindex:

```bash
hash -r                 # forget cached command locations[⁷]
sudo mdutil -E /        # rebuild Spotlight index if mdfind is stale[⁸]
```

---

## What survives a move, and what doesn't

| Thing | Survives a whole-repo move? | Fix |
|---|---|---|
| Git history, branches, remotes | ✅ Yes (remotes are URLs) | none |
| Python venv | ❌ No (absolute shebangs)[¹] | recreate |
| `node_modules` / `.bin` | ❌ No (absolute symlinks)[³] | `rm -rf` + reinstall |
| `.envrc` with hardcoded paths | ❌ No | switch to `$PWD`-derived `layout`[⁴] |
| git worktrees | ⚠️ Only if repo OR worktrees move, not both[⁵] | `git worktree repair` |
| Shell command hash | ❌ Stale | `hash -r`[⁷] |
| Spotlight / `mdfind` index | ⚠️ Stale until reindex | `mdutil -E`[⁸] |
| GitHub repo refs (renamed) | ⚠️ Redirected, but fragile[⁶] | update remote; never reuse old name |

---

## Sources

- [¹] https://docs.python.org/3/library/venv.html — accessed 2026-05-31
- [²] https://docs.astral.sh/uv/ — accessed 2026-05-31
- [³] https://github.com/npm/cli/issues/4308 — accessed 2026-05-31
- [⁴] https://direnv.net/man/direnv-stdlib.1.html — accessed 2026-05-31
- [⁵] https://git-scm.com/docs/git-worktree — accessed 2026-05-31
- [⁶] https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository — accessed 2026-05-31
- [⁷] https://ss64.com/mac/hash.html — accessed 2026-05-31
- [⁸] https://support.apple.com/en-us/102321 — accessed 2026-05-31

## Related

- [Layout B](./layout-b-subfolders.md) — the target structure
- [Slug rules](./slug-rules.md) — the naming the manifest's `slug` column follows
- [Worktree placement](./worktree-placement.md) — why worktrees are disposable and live outside `~/Projects/`
- [Chapter 06 — Audit pattern](../06-session-discipline/audit-and-conventions-pattern.md) — record the migration as a dated audit
