# solo-dev-pmo

*The Project Management Office function for a solo developer. Run by one human + N AI agents. Designed for affordances, not discipline.*

> "PMO" is the org function that, in larger companies, coordinates work across teams — owns the PM tool config, the conventions, the rituals, the audit trail. This repo is that function, sized for one engineer.

---

## What this is

A playbook for the human who is the founder, engineer, PM, ops, security, and QA — usually with one or more AI agents (Claude Code, Cursor, Codex, ...) in the loop. It's not an `awesome-*` list of links. It's an opinionated end-to-end system that you can fork, adapt, and run.

It assumes:

- You are one person doing all the roles.
- You use AI agents heavily, not occasionally.
- Your working memory is finite (more so if you have ADHD, but everyone benefits from offloading).
- You have a project management tool, a code host, a terminal, a calendar problem, and a secrets problem.
- You'd rather build affordances than rely on discipline.

If those don't describe you, this probably isn't for you.

## What this is NOT

- **Not an awesome-list of links.** Adjacent prior art (see [`credits.md`](./credits.md)) covers that well — `awesome-claude-code`, `awesome-adhd`, `gstack`, `solo-founder-playbook`. We point at them and don't duplicate them.
- **Not a founder/startup playbook.** Business strategy (idea evaluation, growth, monetization) is covered by `yayashuxue/solo-founder-playbook` and we link there. This is about the engineering-org layer underneath.
- **Not a Claude Code skill bundle.** `garrytan/gstack` ships 65+ skills; this ships zero. We describe *how to think about* skills/hooks/MCPs, not which specific ones to install.
- **Not theoretical.** Every chapter is extracted from a working system that one engineer runs day-to-day for 12+ months. Provenance is tracked in [`extraction-sheet.md`](./extraction-sheet.md).

## Quickstart

1. Skim [`00-principles/`](./00-principles/) — four design axes that shape every chapter. ~10 minutes.
2. Read the lead chapter: [`01-linear-as-load-bearing-pm/`](./01-linear-as-load-bearing-pm/) — the most fleshed out, and the strongest unique-axis material. ~30 minutes.
3. Skim the remaining chapter READMEs to find what applies to you. Skip what doesn't.
4. Fork. Adapt. Run.

## Chapters

| # | Chapter | Status | What it covers |
|---|---------|--------|----------------|
| 00 | [Principles](./00-principles/) | ✓ | ADHD-aware design, 4-layer memory, single source of truth, calendar-neutrality |
| 01 | [Linear as load-bearing PM](./01-linear-as-load-bearing-pm/) | ✓ **fully fleshed** | Cycles, Triage, Estimates, Snooze, WIP, Ticket standard, I/O rules, Never-defer |
| 02 | [Filesystem conventions](./02-filesystem-conventions/) | ✓ | Layout B subfolders, slug rules, Linear↔GitHub binding, worktree placement |
| 03 | [Claude Code as operator](./03-claude-code-as-operator/) | ✓ | Memory architecture, CLAUDE.md template, skills/hooks, MCP routing, browser tools, agent rules |
| 04 | [Rituals and triggers](./04-rituals-and-triggers/) | ✓ | launchd over cron, ntfy, plaintext time layer, Monday plan / Friday retro |
| 05 | [Secrets and secure defaults](./05-secrets-and-secure-defaults/) | ✓ | Secrets via password manager CLI, SSH agent, never-commit-secrets, signing |
| 06 | [Session discipline](./06-session-discipline/) | ✓ | Commit cadence, PR review standard, audit + conventions pattern, /wrap and /resume |
| 07 | [Cheatsheets and living docs](./07-cheatsheets-and-living-docs/) | ✓ | `cheat <topic>` system, cheatsheet maintenance discipline |

Every chapter is substantive (README + sub-topics + field-tested gotchas + innovative patterns). Open issues / PRs welcome for new chapters or depth-expansion of existing ones.

## Positioning

The closest adjacent repos:

- **[`garrytan/gstack`](https://github.com/garrytan/gstack)** — Claude Code as a software factory. 65+ skills, GBrain memory layer. Zero PM tool integration, no ADHD framing, no cross-tool/filesystem conventions. *We are complementary, not competing — this playbook teaches the org layer that gstack assumes you already have.*
- **[`yayashuxue/solo-founder-playbook`](https://github.com/yayashuxue/solo-founder-playbook)** — Six Claude Code skills for founder strategy (idea evaluation, growth, plan roasting). Zero engineering workflow. *Different layer; we don't overlap.*
- **[`hesreallyhim/awesome-claude-code`](https://github.com/hesreallyhim/awesome-claude-code)** — Directory of Claude Code skills, hooks, slash-commands, plugins. *That's the marketplace; this is the recipe book.*
- **[`XargsUK/awesome-adhd`](https://github.com/XargsUK/awesome-adhd)** — General ADHD apps, books, content. No dev/PM content. *Different audience; we link to it for the lifestyle layer.*

The unique axes this playbook owns:

1. **ADHD-aware design as a stack-design constraint** — not "use these ADHD apps" but "design every layer of your stack so it requires no daily discipline to maintain."
2. **4-layer memory architecture** — global rules → project rules → auto-memory → MCP cross-project memory, with the boundary rules between them.
3. **Linear as load-bearing PM** — exponential estimates, 1-week cycles, snooze-as-hibernation, Triage-as-inbox, weekly project updates as auto-retro. End-to-end recipe, grounded in primary docs.
4. **Agent-autonomous-ready ticket standard** — a 7-section + execution-metadata + stop-conditions ticket schema that lets you hand any ticket to an agent with only its ID.
5. **Cross-tool integration** — Linear + Claude Code + tmux + launchd + ntfy + filesystem-layout as one coherent system, not isolated tools.

## License

[Pick at fork time. Suggested: CC BY 4.0 for the prose, MIT for any code examples.]

## Credits

See [`credits.md`](./credits.md) for sources, primary docs, and adjacent repos that this playbook draws from or points to.
