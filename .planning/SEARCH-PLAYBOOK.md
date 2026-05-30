# SEARCH-PLAYBOOK — shared search recipes

Every per-phase RESEARCH.md references this file. Don't restate recipes; link to the relevant section.

## Source classes & weighting

| Class | Weight | Examples |
|---|---|---|
| Primary vendor docs | ★★★★★ | Linear docs, Apple launchd docs, Bitwarden help, GitHub API docs, Claude Code docs |
| Vendor engineering blogs | ★★★★ | linear.app/now, github.blog, anthropic.com/news, stripe.com/blog |
| Peer-reviewed / academic | ★★★★ | ACM, IEEE, arXiv (for ADHD + workflow research specifically) |
| Practitioner long-form | ★★★ | personal blogs, Substack, Medium engineering posts |
| Adjacent / forked repos | ★★★ | gstack, awesome-claude-code, solo-founder-playbook, Leantime |
| Community discussion | ★★ | HN comment threads, Lobsters, Reddit r/ADHD_Programmers, Mastodon, X/Twitter, Discord excerpts |
| AI-generated content | ★ | Generally avoid; cite only if it surfaced a primary source |

Bias: when a primary doc disagrees with a community post, primary wins. When a vendor blog disagrees with a practitioner post, prefer the one with reproducible code/config.

## Tool routing for research

Per `~/.claude/docs/mcp-routing.md` (loaded via global CLAUDE.md):

1. **WebFetch first** when you have a known URL — cheapest, no JS render.
2. **WebSearch** when discovering — pulls fresh results.
3. **context7 / Dash** for library docs when the tool is well-known. Dash first (local, fast) → context7 fallback. Verify against primary if version-specific.
4. **Firecrawl** for cloud markdown when WebFetch chokes on JS.
5. **Playwright / chrome-devtools** only when interaction is needed (forms, JS-rendered content). Almost never for research.
6. **Browser MCPs** ranked in `~/.claude/docs/browser-tools.md` — read it before reaching for one.

For Linear/GitHub/etc. data: prefer the CLI (`linearis`, `gh`) over MCPs when running locally. MCPs are for cloud sessions.

## GitHub topic searches

Run these to find adjacent prior art, gotchas, and counter-evidence:

```
# Solo developer / single-engineer setups
https://github.com/topics/solo-developer
https://github.com/topics/solo-founder
https://github.com/topics/solopreneur
https://github.com/topics/one-person-startup

# Claude Code / AI agent ecosystem
https://github.com/topics/claude-code
https://github.com/topics/claude-skills
https://github.com/topics/mcp-server
https://github.com/topics/ai-agents
https://github.com/topics/llm-agent

# Workflow patterns
https://github.com/topics/dotfiles
https://github.com/topics/personal-knowledge-management
https://github.com/topics/pkm
https://github.com/topics/zettelkasten
https://github.com/topics/cli-tool

# ADHD / neurodiverse tooling
https://github.com/topics/adhd
https://github.com/topics/neurodiversity
https://github.com/topics/productivity

# Cycle-/sprint-style PM
https://github.com/topics/project-management
https://github.com/topics/linear-app
https://github.com/topics/issue-tracker
```

Sort by stars + recent activity. Discard anything not touched in 18 months unless it's a methodology / book-style repo.

GitHub Code Search recipes (find configs, not just READMEs):

```
# launchd plists for personal rituals
filename:*.plist path:LaunchAgents "RunAtLoad"

# ntfy in personal scripts
"ntfy.sh" extension:sh
"ntfy.sh" extension:zsh

# rbw usage patterns
"rbw get" extension:sh
"rbw unlock" filename:.zshrc OR filename:.bashrc

# Linear API patterns
"api.linear.app/graphql" extension:sh
"linearis" extension:md

# Claude Code CLAUDE.md examples
filename:CLAUDE.md "MCP"
filename:CLAUDE.md "memory layer"
```

## HN / Lobsters / Reddit recipes

**Hacker News (via Algolia):**

```
https://hn.algolia.com/?q=Linear+app+workflow
https://hn.algolia.com/?q=Claude+Code+skills
https://hn.algolia.com/?q=solo+founder+AI+agents
https://hn.algolia.com/?q=ADHD+programmer
https://hn.algolia.com/?q=launchd+vs+cron
https://hn.algolia.com/?q=ntfy
https://hn.algolia.com/?q=rbw+bitwarden
https://hn.algolia.com/?q=git+worktree
https://hn.algolia.com/?q=password+manager+CLI
```

Filter to comments (not just stories) — comments often contain the gotcha. Skim points threshold ≥ 30 for stories, ≥ 10 for comments.

**Lobsters:**

```
https://lobste.rs/search?q=Claude+Code&what=stories
https://lobste.rs/search?q=Linear+PM&what=stories
https://lobste.rs/search?q=worktree&what=stories
https://lobste.rs/search?q=launchd&what=stories
https://lobste.rs/t/practices
```

Higher signal-to-noise than HN for tooling specifics. Skim 2 years back.

**Reddit (use site: search via WebSearch — Reddit's own search is poor):**

```
site:reddit.com "Linear" "cycles" workflow
site:reddit.com r/ADHD_Programmers "tools that worked"
site:reddit.com r/ClaudeAI "skills"
site:reddit.com r/Bitwarden "rbw"
site:reddit.com r/macsysadmin launchd
site:reddit.com r/git worktree workflow
site:reddit.com r/selfhosted ntfy
```

Reddit insight tier: r/ADHD_Programmers > r/ExperiencedDevs > r/programming. Avoid r/Productivity (low signal).

## Mastodon / X / Bluesky

Hashtag + handle searches. Recent posts only (≤ 6 months) — workflow conversations rot fast.

**Mastodon (federated; use mastodon.social search or elk.zone):**

```
#ClaudeCode
#AIAgents
#SoloDev
#ADHDDeveloper
#Linear (warning: overloaded — filter)
```

**X / Twitter (no API; use nitter mirrors via WebFetch or browser tools):**

Handles worth tailing for solo-dev + AI-agent flow:
- `@AnthropicAI`, `@alexalbert__` (Anthropic)
- `@karrigan`, `@swyx`, `@dsiroker` (AI workflow practitioners)
- `@karpathy` (general agent-systems thinking)
- `@levelsio` (solo-founder ops)
- `@dhh` (opinion-piece source; pro/contra)

Search recipes:
- `(Claude Code) (skill OR hook) min_faves:50`
- `(solo founder) (agent OR AI) min_faves:30`
- `(Linear app) (cycle OR triage) min_faves:20`

**Bluesky:**

- Custom feeds: "AI tooling," "Devs"
- Tags: `#ai`, `#devtools`

## Discord / Slack archives (read-only)

- **Linear Community Slack** — invite-gated; search via google: `site:linear-community.slack.com "cycle"` (limited)
- **Anthropic Discord** — channel logs not indexed publicly; for live questions only, not historical research
- **Claude Builders Discord** — same

If a question MUST be asked live, post in Anthropic Discord #claude-code or Linear Community Slack #general — do not paste secrets, do not paste full transcripts.

## Academic / structured sources

- **Google Scholar** — ADHD + software-engineering productivity (filter ≥ 2020)
  - `"context switching" "software developers"`
  - `"externalizing memory" ADHD adults`
  - `"interruption recovery" programmers`
- **ACM Digital Library** — paywall but abstracts free; same queries
- **arXiv** — cs.HC, cs.SE for HCI / SE workflow papers

## Anti-patterns (do not cite)

- Generic productivity blogs ("10 tips for solo founders!") — almost always SEO-spam
- Listicles with no code, no config, no reproduction
- LinkedIn thought-leadership posts unless the author is named & specific
- AI-generated medium posts (telltales: "in this article we will explore...", no specific tooling)
- Vendor sales pages (different from vendor docs and engineering blogs)

## Per-phase research log format

Each `gsd-phase-researcher` should append a `RESEARCH-LOG.md` to its phase folder as it works:

```markdown
## YYYY-MM-DD — <topic>

- **Source:** <URL or citation>
- **Class:** primary / vendor-blog / practitioner / community / academic
- **Surfaced fact:** <one-liner>
- **Used in:** <which sub-topic file gets updated>
- **Counter-evidence:** <if any — none is OK>
```

Bibliography rolls up into the chapter README's "Sources" section at end of phase.
