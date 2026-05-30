# Naming & Layout Conventions (example)

> A `conventions/naming.md` example. Drop in your meta-PM repo at `conventions/naming.md` and adapt to your setup.

Canonical rules for `~/Projects/`, GitHub repos, and how they bind to your PM tool.

**Status:** locked v1.0 (<date>).

**Authority:** This file is the source of truth. Tooling reads from here for drift detection.

---

## 1. Locked rules

### 1.1 Slug format

The canonical slug = the disk folder leaf name AND the GitHub repo name. They must always match.

| Rule | Example ✓ | Counter-example ✗ |
|---|---|---|
| All lowercase | `infra-cleanup` | `Infra-Cleanup`, `InfraCleanup` |
| Words separated by `-` only | `learning-rust` | `learning_python`, `learningPython` |
| Acronyms lowercased | `mac-setup`, `llm-research` | `macOS-setup`, `LLM-research` |
| ASCII letters + digits + `-` only | `case-acme` | `café-app`, `case.acme` |
| No leading/trailing `-` | `your-toolkit` | `-your-toolkit`, `your-toolkit-` |
| No double `--` | `repo-sync-tool` | `repo--sync` |

**No grandfathered TitleCase exceptions.** Original-name TitleCase repos migrate as part of normal cleanup; rename blast radius is usually smaller than it looks.

### 1.2 Worktree placement

Git worktrees live in:

```
~/.claude/worktrees/<repo-slug>/<branch-name>/
```

NOT in `~/Projects/<name>-<ticket>/`. Worktrees pollute `~/Projects/` and break category cleanliness.

### 1.3 Scratch / throwaway

Folders ending in `-temp` are throwaway and exempt from rules. Live in `~/Projects/scratch/`.

### 1.4 PM tool ↔ GitHub binding

Each PM tool project's description first line carries:

```
repo: infra-cleanup
```

Sync tooling reads this. Display name stays human (e.g., "Mega Cleanup"); the tag is for machines.

Variations:
- **No `repo:` tag** = continuous Area (Mac Setup, Money, etc.)
- **Multiple `repo:` lines** = multi-repo family
- **`family: <name>`** = alternative to multiple `repo:` lines

---

## 2. Disk layout — Layout B (subfolders)

```
~/Projects/
├── awesome/          # curation lists
├── cases/            # job-application case studies
├── infra/            # personal infrastructure
├── apps/             # bounded products
├── tools/            # internal CLIs / SDKs
├── research/         # research, spikes, experiments
├── media/            # published content (blogs, Plex stack)
├── money/            # finance
├── upstream/         # OSS forks + vendored clones
├── scratch/          # disposable
└── (top-level exceptions, see §3)
```

Disk path ≠ GitHub repo name. A subfolder/<slug> on disk maps to `<slug>` on GitHub.

Launcher scripts (e.g., `c <name>`) should derive project name from `git rev-parse --show-toplevel | basename`, NOT from a `~/Projects/*` glob.

---

## 3. Subfolder categories

### 3.1 What goes where

| Subdir | Meaning |
|---|---|
| `awesome/` | Curation lists |
| `cases/` | Job-application case studies |
| `infra/` | Personal infrastructure / setup |
| `apps/` | Bounded products |
| `tools/` | Internal tools / SDKs / CLIs |
| `research/` | Research, spikes, experiments |
| `media/` | Published content |
| `money/` | Finance |
| `upstream/` | OSS forks + vendored clones |
| `scratch/` | Disposable / temp |

### 3.2 Top-level exceptions

- **Your meta-PM repo** — operates on the other categories; top-level exception.

Be strict — every top-level exception you add reduces layout cleanliness.

---

## 4. Open questions

These need decisions but aren't blocking:

- **PM "Areas" model** — continuous life-domains as Projects (no Initiative) or as labels?
- **Multi-repo product families** — multiple `repo:` lines OR `family:` tag?
- **Archived projects** — `~/Projects/archive/` subdirectory or `-archive` suffix?

---

## Changelog

- **v1.0 (<date>):** initial lock. Cite the audit that justified this.
