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

## Peer-reviewed sources (ADHD research)

The ADHD claims in [Chapter 00 — Principles](./00-principles/) are grounded in these, and graded by evidence tier in [00-principles/evidence-and-citations.md](./00-principles/evidence-and-citations.md). Listed separately from the blog posts below **on purpose** — these are studies; those are not.

- Alderson, R. M., Kasper, L. J., Hudec, K. L., & Patros, C. H. G. (2013). ADHD and working memory in adults: A meta-analytic review. *Neuropsychology, 27*(3), 287–302. [PubMed 23688211](https://pubmed.ncbi.nlm.nih.gov/23688211/)
- Altgassen, M., Scheres, A., & Edel, M.-A. (2019). Prospective memory (partially) mediates the link between ADHD symptoms and procrastination. *ADHD Atten Def Hyp Disord, 11*(1), 59–71. [doi:10.1007/s12402-018-0273-x](https://doi.org/10.1007/s12402-018-0273-x)
- Barkley, R. A. (1997). Behavioral inhibition, sustained attention, and executive functions: Constructing a unifying theory of ADHD. *Psychological Bulletin, 121*(1), 65–94. [doi:10.1037/0033-2909.121.1.65](https://doi.org/10.1037/0033-2909.121.1.65)
- Barkley, R. A. (1997). ADHD, self-regulation, and time: Toward a more comprehensive theory. *J Dev Behav Pediatr, 18*(4), 271–279. [PubMed 9276836](https://pubmed.ncbi.nlm.nih.gov/9276836/) — the "externalize at the point of performance" prescription that the "affordances, not discipline" axis rests on.
- Beaton, D. M., Sirois, F., & Milne, E. (2022). Experiences of criticism in adults with ADHD: A qualitative study. *PLOS ONE, 17*(2), e0263366. [doi:10.1371/journal.pone.0263366](https://doi.org/10.1371/journal.pone.0263366)
- Kasper, L. J., Alderson, R. M., & Hudec, K. L. (2012). Moderators of working memory deficits in children with ADHD: A meta-analytic review. *Clinical Psychology Review, 32*(7), 605–617. [PubMed 22917740](https://pubmed.ncbi.nlm.nih.gov/22917740/)
- Martinussen, R., Hayden, J., Hogg-Johnson, S., & Tannock, R. (2005). A meta-analysis of working memory impairments in children with ADHD. *J Am Acad Child Adolesc Psychiatry, 44*(4), 377–384. [doi:10.1097/01.chi.0000153228.72591.73](https://doi.org/10.1097/01.chi.0000153228.72591.73)
- Nasri, B., Kosidou, K., et al. (2022). The effect of SMS reminders on adherence in a self-guided internet-delivered intervention for adults with ADHD. *Frontiers in Digital Health, 4*, 821031. [doi:10.3389/fdgth.2022.821031](https://doi.org/10.3389/fdgth.2022.821031)
- Sonuga-Barke, E. J. S. (2002). Psychological heterogeneity in AD/HD — a dual pathway model of behaviour and cognition. *Behavioural Brain Research, 130*(1–2), 29–36. [PubMed 11864715](https://pubmed.ncbi.nlm.nih.gov/11864715/)
- Sonuga-Barke, E. J. S. (2003). The dual pathway model of AD/HD: An elaboration of neuro-developmental characteristics. *Neurosci Biobehav Rev, 27*(7), 593–604. [PubMed 14624804](https://pubmed.ncbi.nlm.nih.gov/14624804/)
- Zheng, Q., Wang, X., Chiu, K. Y., & Shum, K. K. (2022). Time perception deficits in children and adolescents with ADHD: A meta-analysis. *Journal of Attention Disorders, 26*(2), 267–281. [doi:10.1177/1087054720978557](https://doi.org/10.1177/1087054720978557)

Non-clinical design source for the "affordance" concept itself: Norman, D. A. (1988/2013). *The Design of Everyday Things.* Basic Books.

## Adjacent repos (related, not duplicating)

These cover adjacent territory. We link to them rather than duplicating.

### Solo dev / opinionated stack

- [`garrytan/gstack`](https://github.com/garrytan/gstack) — Claude Code as software factory; ~31 core skills (the "65+" figure circulates from earlier marketing) + GBrain memory. Covers Claude Code skill organization deeply; this playbook covers the PM / filesystem / ritual layers gstack doesn't.
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

### Agent safety + hardening

Same-tier prior art for chapter 08 (Agent safety). Listed alongside external alternatives, not above them.

- [`pleasedodisturb/llm-safe-haven`](https://github.com/pleasedodisturb/llm-safe-haven) — Published npm tool that hardens AI coding agents in 60 seconds. 5-tier security scorecard (Tier 0 Exposed → Tier 4 Fortified); ships `audit-logger.js` / `bash-firewall.js` / `secret-guard.js` hooks; supports Claude Code / Cursor / Windsurf / Cline / Continue / Aider / Codex CLI. Cited in [chapter 08 — agent-hardening](./08-agent-safety/agent-hardening.md).
- [`pleasedodisturb/terminal-craft`](https://github.com/pleasedodisturb/terminal-craft) — Ghostty + tmux + Claude Code workspace patterns. Session persistence + visual alerts + hook routing. Cited in [chapter 08 — session-isolation](./08-agent-safety/session-isolation.md). Note: tmux is session-shaped, not security-shaped — the chapter is explicit about that.
- [`pleasedodisturb/rbw-proxy`](https://github.com/pleasedodisturb/rbw-proxy) — Credential proxy for AI coding agents sandboxed behind Seatbelt/bubblewrap (file-based IPC, per-project secret manifests, audit logging). Cited in [chapter 08 — session-isolation](./08-agent-safety/session-isolation.md) as the sandbox↔secrets intersection pattern.

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

Dual-licensed:

- **Prose / chapters** — [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/). Share, adapt, use commercially with attribution.
- **Code examples / scripts** (anything in `examples/`, code blocks in chapters, the `cheats-starter/` directory under chapter 07, plists, shell hooks, Python scripts) — [MIT License](https://opensource.org/licenses/MIT). Permissive; matches the patterns shipped in `gstack`, `solo-founder-playbook`, etc.

Full text + attribution guidance: [`LICENSE`](./LICENSE).
