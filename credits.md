# Credits

Sources, primary docs, and adjacent repos this playbook draws from or points to.

## Primary docs

These are first-party docs cited throughout. They're the ground truth this playbook is grounded in.

### Linear

- [Linear Triage](https://linear.app/docs/triage)
- [Linear Cycles](https://linear.app/docs/use-cycles)
- [Linear Estimates](https://linear.app/docs/estimates)
- [Linear Custom Views](https://linear.app/docs/custom-views)
- [Linear Filters](https://linear.app/docs/filters)
- [Linear Inbox](https://linear.app/docs/inbox)
- [Linear Project Status](https://linear.app/docs/project-status)
- [Linear Initiative and Project Updates](https://linear.app/docs/initiative-and-project-updates)
- [Linear Method](https://linear.app/method/introduction)
- [How we built Project Updates — Linear blog](https://linear.app/now/how-we-built-project-updates)

### Tooling

- [`rbw` — Rust CLI for Bitwarden](https://github.com/doy/rbw)
- [`ntfy`](https://ntfy.sh) — push notification service
- [`launchd` on macOS](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html) — Apple's docs on LaunchAgents/Daemons
- [`detect-secrets`](https://github.com/Yelp/detect-secrets) — pre-commit secret scanner
- [`gitleaks`](https://github.com/gitleaks/gitleaks) — secret scanner
- [Claude Code](https://docs.claude.com/en/docs/claude-code) — the agentic coding tool this playbook is opinionated about
- [`gh`](https://cli.github.com) — GitHub CLI

### MCP / agent ecosystem

- [Context7 MCP](https://github.com/upstash/context7) — library docs MCP
- [Playwright MCP](https://github.com/microsoft/playwright-mcp) — browser interaction MCP
- [chrome-devtools MCP](https://github.com/anthropics/chrome-devtools-mcp) — DevTools MCP
- [browser-use](https://github.com/browser-use/browser-use) — Python AI-browser-agent framework
- [Obscura](https://github.com/h4ckf0r0day/obscura) — lightweight headless engine (Rust+V8)
- [CloakBrowser MCP](https://github.com/cloakbrowser/cloakbrowsermcp) — stealth Chromium
- [Firecrawl MCP](https://github.com/mendableai/firecrawl-mcp-server) — cloud markdown scraping
- [Lightpanda](https://github.com/lightpanda-io/browser) — Zig-based headless
- [BrowserMCP](https://github.com/browsermcp/mcp) — real Chrome via extension

## Adjacent repos (related, not duplicating)

These cover adjacent territory. We link to them rather than duplicating.

### Solo dev / opinionated stack

- [`garrytan/gstack`](https://github.com/garrytan/gstack) — Claude Code as software factory; 65+ skills + GBrain memory. Covers Claude Code skill organization deeply; this playbook covers the PM / filesystem / ritual layers gstack doesn't.
- [`yayashuxue/solo-founder-playbook`](https://github.com/yayashuxue/solo-founder-playbook) — Founder business strategy via 6 Claude Code skills (idea evaluation, growth, plan roasting). Pure business layer; this playbook is the engineering layer.
- [`nopara73/ForeverAloneProgramming`](https://github.com/nopara73/ForeverAloneProgramming) — Software development methodology (Agile Unified Process variant) for solo devs. Methodology-flavored; this playbook is stack-integrated.
- [`fawazahmed0/the-solo-developers-manifesto`](https://github.com/fawazahmed0/the-solo-developers-manifesto) — Manifesto-style guidance.
- [`Solo-Entrepreneur/solopreneur`](https://github.com/Solo-Entrepreneur/solopreneur) — "How to Start a Startup" AI Agent Skill.

### ADHD resources

- [`XargsUK/awesome-adhd`](https://github.com/XargsUK/awesome-adhd) — General ADHD apps, books, communities, content. The lifestyle layer; this playbook is the engineering-stack layer.
- [`mrseth01/awesome-adhd`](https://github.com/mrseth01/awesome-adhd) — Same niche.
- [Leantime](https://leantime.io/) — Open-source PM platform built with neurodiversity in mind. A *tool* you adopt; this playbook is the recipe for integrating existing tools.

### Claude Code ecosystem

- [`hesreallyhim/awesome-claude-code`](https://github.com/hesreallyhim/awesome-claude-code) — Curated list of Claude Code skills/hooks/commands/plugins (28.5k★). The marketplace; this playbook is the recipe book.
- [`VoltAgent/awesome-claude-code-subagents`](https://github.com/VoltAgent/awesome-claude-code-subagents) — Subagent prompts archive.
- [`danielrosehill/Claude-Code-Projects-Index`](https://github.com/danielrosehill/Claude-Code-Projects-Index) — Index of Claude Code starter templates.
- [`quemsah/awesome-claude-plugins`](https://github.com/quemsah/awesome-claude-plugins) — Plugin metrics.

### General topics

- [`degoogle` topic on GitHub](https://github.com/topics/degoogle) — adjacent reading for [calendar neutrality](./00-principles/calendar-neutrality.md)
- [`solo-founder` topic on GitHub](https://github.com/topics/solo-founder)
- [`solopreneur` topic on GitHub](https://github.com/topics/solopreneur)
- [`adhd` topic on GitHub](https://github.com/topics/adhd)

## Blog posts and articles

- [Managing ADHD as a Software Developer — Jarrod Servilla](https://jarrod-servilla.medium.com/managing-adhd-as-a-software-developer-a1d08d6535a2)
- [ADHD-Proofing Your Developer Workflow — Super Productivity](https://super-productivity.com/blog/adhd-developer-productivity-guide/)
- [Unlocking Solo-Dev Superpowers with Claude Code — Nuttakit Kundum](https://nuttakitkundum.medium.com/unlocking-solo-dev-superpowers-with-claude-code-and-github-flow-991978f7543b)
- [The One-Person Unicorn — NxCode](https://www.nxcode.io/resources/news/one-person-unicorn-context-engineering-solo-founder-guide-2026)
- [Managing Projects with ADHD — Leantime](https://leantime.io/managing-projects-with-adhd-skip-personal-project-planners/)

## Chapter 01 research sources (added in M1 P01 grounded-research pass)

Added 2026-05-31. Full bibliography + verification caveat: [`01-linear-as-load-bearing-pm/sources.md`](./01-linear-as-load-bearing-pm/sources.md).

### PM-tool alternatives (chapter 01)

- [Plane](https://github.com/makeplane/plane) — open-source (AGPL-3.0) Linear-alike; the closest substitute (self-hostable; misses native snooze)
- [Shortcut](https://shortcut.com) — iterations + auto-move automation; official MCP
- [GitHub Projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects) — iteration field, status updates, `gh project`, official MCP
- [Jira](https://www.atlassian.com/software/jira) / [Trello](https://trello.com) — Atlassian; Rovo MCP (Trello out of scope)
- Height — **shut down 2025-09-24** ([coverage](https://alternativeto.net/news/2025/3/height-project-management-tool-to-shut-down-by-september-2025/)); no longer a viable target

### Estimation, agile-method & PKM references (chapter 01)

- Steve McConnell, *Software Estimation: Demystifying the Black Art* (2006)
- Mike Cohn — [Mountain Goat Software](https://www.mountaingoatsoftware.com) (Fibonacci rationale, SPIDR splitting)
- Ron Jeffries, [*Story Points Revisited*](https://ronjeffries.com/articles/019-01ff/story-points/Index.html)
- Allen Holub, [*#NoEstimates*](https://holub.com/noestimates-an-introduction/)
- Martin Fowler, [bliki: estimation/velocity](https://martinfowler.com/bliki/PurposeOfEstimation.html)
- Forsgren et al., [*The SPACE of Developer Productivity*](https://queue.acm.org/detail.cfm?id=3454124) (ACM Queue, 2021); [DORA](https://dora.dev)
- David J. Anderson, *Kanban* (2010); Kniberg & Skarin, [*Kanban and Scrum*](https://www.infoq.com/minibooks/kanban-scrum-minibook/)
- Basecamp, [*Shape Up*](https://basecamp.com/shapeup) (Ryan Singer) — cycles + cool-down
- David Allen, [*Getting Things Done*](https://gettingthingsdone.com) — capture / trusted system / tickler file
- [AGENTS.md](https://agents.md/), [Anthropic Claude Code best practices](https://code.claude.com/docs/en/best-practices) — agent-task structuring

## Tools mentioned in passing

These show up in chapters but aren't load-bearing:

- [`uv`](https://github.com/astral-sh/uv) — Python package manager
- [`ruff`](https://github.com/astral-sh/ruff) — Python linter
- [`pre-commit`](https://pre-commit.com) — git hook framework
- [`fzf`](https://github.com/junegunn/fzf) — fuzzy finder
- [`rg` (ripgrep)](https://github.com/BurntSushi/ripgrep) — better grep
- [`glow`](https://github.com/charmbracelet/glow) — markdown renderer for terminal
- [`bat`](https://github.com/sharkdp/bat) — `cat` with syntax highlighting
- [`tmux`](https://github.com/tmux/tmux/wiki) — terminal multiplexer
- [`jq`](https://jqlang.org) — JSON CLI

## Influences

- The "agents as first-class operators" framing draws from the broader 2026 conversation around solo founders + AI agents — see [The Solo Founder AI Agent Stack — mean.ceo](https://blog.mean.ceo/the-solo-founder-ai-agent-stack-that-is-replacing-entire-startup-teams/).
- The "audit + conventions" pattern is loosely inspired by ADR (Architecture Decision Record) practices — see [ADR GitHub org](https://adr.github.io).
- The "single source of truth" principle is borrowed from systems thinking / DRY in software, generalized to organizational design.
- "Affordances not discipline" framing draws from Don Norman's *The Design of Everyday Things* (1988) applied to personal systems.

## Acknowledgments

- The original solo-dev ADHD failure modes that motivated this playbook were named openly by the author of the source repo (`command-center`). The patterns are field-tested at the 12+ month / 30+ repo / 270+ ticket scale.
- Many gotchas in this playbook were learned from real incidents — bad migrations, leaked secrets, broken PRs, missed Fridays. The lessons are real.

## License

[Pick at fork time.]

Suggested:
- **Prose / chapters** — Creative Commons BY 4.0. Attribution preserves "field-tested by [the author]" credit. Lets others remix/extend.
- **Code examples / scripts** — MIT. Permissive; matches the patterns shipped in `gstack`, `solo-founder-playbook`, etc.
