# Linear ↔ GitHub binding

> Linear project description first line: `repo: <slug>`. This is how sync tooling maps Linear ↔ GitHub. Display name stays human; the tag is for machines.

## The pattern

Linear project **display name** stays human-friendly Title Case for readability:

- `Mega Cleanup`
- `Job Search`
- `Money & Finance`
- `your-product Open Source`

Each Linear project's **description first line** carries the binding tag:

```
repo: infra-cleanup

(rest of description starts here on line 3...)
```

The tag is the machine-readable bridge. The display name is the human-readable label.

## Why two names

Linear display names are seen daily. They should be pleasant: title case, spaces, punctuation.

GitHub repo names are URLs. They should be sluggable: lowercase, hyphens, ASCII.

If you force one to match the other, you lose something. Either:
- Linear display = "infra-cleanup" — ugly and hard to read
- GitHub repo = "Mega Cleanup" — broken (URLs don't allow spaces)

The `repo: <slug>` tag in the description bridges them. Linear display stays pretty; the tag tells tools which GitHub repo this Linear project maps to.

## How sync tooling consumes this

Your `repo-sync-tool` (or equivalent) reads Linear projects' descriptions, parses the first line, and derives the GitHub repo. Here's a concrete, runnable shell function that reads the tag and `cd`s you straight to the repo on disk — the everyday payoff of the binding:

```bash
# proj-cd <project-name-substring> — jump to a Linear project's repo on disk.
# Reads the `repo:` tag from the project's summary/description first line.
proj-cd() {
  local slug
  slug=$(linearis project list --json \
    | jq -r --arg q "${1:l}" '
        .[] | select((.name|ascii_downcase) | contains($q))
        | (.summary // .description) | split("\n")[]
        | select(startswith("repo: ")) | ltrimstr("repo: ") | gsub("\\s+$";"")' \
    | head -1)
  [ -z "$slug" ] && { echo "no repo: tag for '$1'"; return 1; }
  local dir
  dir=$(find ~/Projects -mindepth 2 -maxdepth 2 -type d -name "$slug" | head -1)
  [ -z "$dir" ] && { echo "repo '$slug' tagged but not on disk"; return 1; }
  cd "$dir"
}
```

`proj-cd "money"` → reads `repo: money` off the project → `cd ~/Projects/money/money`. Note it reads `.summary // .description`: in the live Linear data model the first free-text field is the project *summary*, which is where the tag actually lands (verified first-hand in this repo's own workspace). Swap `linearis` for `curl` against the Linear GraphQL API if you don't use the CLI.

This bridge enables:
- **Auto-link GitHub issues into Linear projects.** A webhook on issue-created posts to the matching project.
- **Auto-link Linear comments back into GitHub PRs.** When a Linear ticket says "ready for review," post to the matching GitHub PR.
- **Audit: are all my GitHub repos referenced in some Linear project?** List orphans.
- **Audit: are all my Linear projects pointing at existing GitHub repos?** List dead refs.

## Three legitimate variations

### 1. No `repo:` tag — continuous Area

Some Linear projects don't have a backing GitHub repo. These are continuous Areas (operational maintenance).

Examples: "Mac Setup & Environment," "Weekly Ritual System." There's no `git` repo backing these. The Linear project tracks the work; the work happens in your shell config, your `~/.claude/`, your dotfiles.

Convention: **no `repo:` tag is legitimate** for Areas. Don't fake one.

The sync tooling treats absent `repo:` as Area, not error.

### 2. Multiple `repo:` lines — multi-repo families

Some projects span multiple code repos. Common with product families that have a server + client + landing + tools, or with OSS projects you maintain a fork + the upstream.

Convention:

```
repo: app-foo
repo: app-foo-server
repo: app-foo-wiki

(rest of description starts here)
```

Sync tooling reads ALL lines starting with `repo: ` and treats them as a set.

### 3. The `family:` alternative

Some teams prefer to label families differently. Instead of multiple `repo:` lines:

```
family: app-foo
repo: app-foo-main
```

And the `family: app-foo` tag indicates this project covers all repos in the app-foo family.

Pick one approach (multiple `repo:` lines OR `family:` tag) and stick to it. Mixing is the worst outcome.

## Mapping tickets to projects

Once the Linear project ↔ GitHub repo binding exists, every ticket lives under a Linear project whose `repo:` tag (if present) tells the agent which repo to clone for the work.

For your ticket-worker agent (Claude Code subagent or similar):
```
1. Receive ticket ID
2. Look up ticket's project
3. Read project description, find `repo:` line
4. Clone github.com/<user>/<slug>
5. Create branch <ticket-id>/<short-desc>
6. Work the ticket
```

The agent doesn't need any other context to know where to work. The binding tag is the routing.

## What this fixes

Before this binding:
- Linear ticket says "Implement X." Which repo is X in? You have 30 repos.
- Agent has to ask or guess. Asking breaks autonomy; guessing breaks the build.
- Cross-references between Linear and GitHub are by-URL, hand-pasted, rot when names change.

After this binding:
- Project description first line is the truth.
- Tickets inherit the project's binding.
- Agents and humans both reach the right repo by reading the tag.
- Rename `infra-cleanup` → `infra-cleanup-v2`? Update the tag in one place; sync tooling re-validates.

## Prior art: we looked, and there isn't any

We could not find a published convention for "a machine-readable `key: value` tag as the first line of a PM tool's project description." People *do* stuff ad-hoc metadata into description fields — an MCP spec issue notes such metadata "is not machine-readable and cannot be reliably parsed"[¹] — but nobody standardizes it. Treat `repo: <slug>` as this playbook's own convention. It borrows from three honest ancestors:

- **Git trailers** (`Co-authored-by:`, `Signed-off-by:`) — RFC-822-style `key: value` lines on an otherwise free-form commit message.[²] Same colon-separated key:value-in-prose idea; ours sits at the *top* of a different field.
- **YAML front-matter** — a metadata block at the top of a Markdown file, parsed by static-site generators and GitHub Docs itself.[³] Same "metadata at the top," but a delimited block, not one line.
- **Conventional Commits** — `type(scope): description` as a structured first commit line.[⁴] Same "structured first line" shape.

## Alternatives for non-Linear users

No mainstream PM tool ships a first-class "this project tracks this repo" field — native links are all issue/PR-level (Linear branch-names + magic words, Jira Smart Commits, Trello card attachments).[⁵] If you're not on Linear, reproduce the binding:

| Tool | Mechanism | Note |
|---|---|---|
| GitHub Projects v2 | Custom **Text** or **Single-select** field named `Repo`[⁶] | Projects v2 is deliberately repo-agnostic (org/user-level)[⁷], so there's nothing native to repurpose — you add the field |
| Notion | A **URL** property, or a **relation** to a synced GitHub database[⁸] | Relation gives live issue/PR rollups |
| Trello | A **Custom Fields** text field or board **label**; or the GitHub Power-Up[⁹] | Label is the zero-setup version |

Trade-off: a structured field is validated and filterable in-UI but tool-locked and needs setup. The `repo:` tag is plain text — it survives export, works identically across tools, and a one-line regex parses it — at the cost of being a convention the tool won't enforce.

## Field tests beyond the author

- **Dogfooded here.** This playbook's own Linear project ("solo-dev-pmo Playbook") carries `repo: solo-dev-pmo` as the first line of its summary — a live instance, verified 2026-05-31, not an aspirational example.
- **It fills a confirmed gap.** Across Linear, Jira, GitHub Projects, Asana, Notion, and Trello, *none* offers a native project→repo field;[⁵] the closest, Linear's GitHub Issues Sync, binds a *team* to repos, not a project.[¹⁰] The tag isn't reinventing a wheel — there is no wheel.

## Field-tested gotchas

**Description line ordering matters.** The tag MUST be the FIRST line. If you put it second or third, parsers may miss it (some parsers look at line 0 only).

**Trailing whitespace on the tag breaks naive parsers.** `repo: foo ` (trailing space) doesn't match `slug` (no trailing space) in scripts that don't `strip()`. Either always `strip()` or always reject trailing whitespace.

**Multi-line `repo:` entries break some parsers.** Most regex-based parsers look for `^repo: ` line-by-line; that handles multi-line well. JSON-shaped parsers (someone trying to YAML-parse the description) won't. Decide and document.

**Renames are migrations.** Renaming a GitHub repo from `foo` to `foo-v2` invalidates the Linear `repo:` tag. Two steps:
1. `gh repo rename foo foo-v2`
2. Update Linear project description: `repo: foo-v2`

Skipping step 2 silently breaks the binding until your weekly audit catches it.

**Multiple Linear projects pointing at the same `repo:` slug is usually a mistake.** Means you have two Linear projects for one code repo. Either merge them or split the code repo.

## Innovative pattern: bi-directional auto-link

When a GitHub PR is opened with `G-1234` in title or body, a webhook:
1. Reads the PR body for `G-XXX` patterns
2. For each, looks up the Linear ticket
3. Adds a comment on the Linear ticket: "PR opened: [URL]"
4. Sets Linear status to `In Review`

When the PR merges:
1. Sets Linear status to `Done`
2. Comments with the merge commit SHA

This makes the binding bi-directional. You can work in either tool and the other follows.

## Innovative pattern: orphan detection

Daily script lists:

```
# GitHub repos not referenced in any Linear project:
for repo in $(gh repo list --limit 100 --json name -q '.[].name'); do
  if ! linear-search-by-tag "repo: $repo" > /dev/null; then
    echo "Orphan GitHub repo: $repo"
  fi
done

# Linear projects with broken `repo:` tags (point at non-existent GitHub repos):
linear-list-with-repo-tags | while read -r slug; do
  gh repo view "$slug" > /dev/null 2>&1 || echo "Broken Linear binding: $slug"
done
```

Run weekly; act on the report.

## Sources

- [¹] https://github.com/modelcontextprotocol/modelcontextprotocol/issues/1483 — accessed 2026-05-31
- [²] https://git-scm.com/docs/git-interpret-trailers — accessed 2026-05-31
- [³] https://docs.github.com/en/contributing/writing-for-github-docs/using-yaml-frontmatter — accessed 2026-05-31
- [⁴] https://www.conventionalcommits.org/en/v1.0.0/ — accessed 2026-05-31
- [⁵] https://linear.app/docs/github-integration — accessed 2026-05-31
- [⁶] https://docs.github.com/en/issues/planning-and-tracking-with-projects/understanding-fields/about-single-select-fields — accessed 2026-05-31
- [⁷] https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects — accessed 2026-05-31
- [⁸] https://www.notion.com/help/github — accessed 2026-05-31
- [⁹] https://support.atlassian.com/trello/docs/using-the-github-power-up/ — accessed 2026-05-31
- [¹⁰] https://linear.app/changelog/2023-12-14-github-issues-sync — accessed 2026-05-31

## Related

- [Slug rules](./slug-rules.md) — the format the `repo: <slug>` value follows
- [Layout B](./layout-b-subfolders.md) — disk location maps via `~/Projects/<category>/<slug>/`
- [Chapter 01 — I/O rules](../01-linear-as-load-bearing-pm/io-rules.md) — Linear project structure
