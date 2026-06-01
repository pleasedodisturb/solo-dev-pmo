# solo-dev-pmo

*The Project Management Office function for a solo developer. Run by one human + N AI agents. Designed for affordances, not discipline.*

> "PMO" is the org function that, in larger companies, coordinates work across teams — owns the PM tool config, the conventions, the rituals, the audit trail. This repo is that function, sized for one engineer.

**Status:** v0.1 — 9 chapters on `main`, milestone M1 (depth via grounded research) shipped 2026-05-31 → 2026-06-01. Cross-chapter audit passed (0 critical / 0 high findings; see [`.planning/audits/`](./.planning/audits/)). Every empirical claim is sourced or honestly hedged.

---

## Why this exists

You wake up. You are the founder, the engineer, the PM, ops, security, and QA. There is no one to escalate to and no one to delegate to except the AI agents you've started running heavily — Claude Code, Cursor, Codex. They're a force multiplier when you trust them, but the trust requires infrastructure: rules they follow, conventions they respect, rituals that fire on a clock instead of on willpower.

That infrastructure is what this playbook documents. Not the tools themselves — those have docs. The **integration layer** between them: how Linear, Claude Code, tmux, launchd, ntfy, your shell, your password manager, and your filesystem cohere into one operating system for a one-person org. The whole stack is designed against a single constraint: **affordances, not discipline.** Anything that requires you to remember it daily will fail. Anything the system enforces will hold.

## What you get

Over weeks (not days) of adoption, you'll have:

- A **PM tool that holds work for you** — no orphan tickets, no dropped balls, weekly retros that fire automatically (chapter 01)
- A **filesystem layout that scales past 30+ repos** without becoming a graveyard (chapter 02)
- An **agent rules layer** that survives weeks of autonomous execution without escalation (chapter 03)
- A **rituals layer** on a clock — Monday plan, Friday retro, daily Triage — none depending on willpower (chapter 04)
- A **secrets baseline** with zero plaintext in your config files (chapter 05)
- A **session discipline** — every commit traces to a ticket, every PR self-reviews, every session ends with a handoff doc (chapter 06)
- A **`cheat <topic>` system** that beats googling the same flag for the third time (chapter 07)
- A **safety baseline** for agent work — honest about what tmux gives you (workspace continuity, not security) and what the OS sandbox does or doesn't catch (chapter 08)

## What this is NOT

- **Not an awesome-list of links.** Adjacent prior art (see [`credits.md`](./credits.md)) covers that well — `awesome-claude-code`, `awesome-adhd`, `gstack`, `solo-founder-playbook`. We point at them and don't duplicate them.
- **Not a founder/startup playbook.** Business strategy (idea evaluation, growth, monetization) is covered by `yayashuxue/solo-founder-playbook` and we link there. This is about the engineering-org layer underneath.
- **Not a Claude Code skill bundle.** `garrytan/gstack` ships ~31 core skills (the "65+" figure circulates from earlier marketing; current docs show the smaller number); this ships zero. We describe *how to think about* skills/hooks/MCPs, not which specific ones to install.
- **Not theoretical.** Every chapter is extracted from a working system that one engineer runs day-to-day for 12+ months. Provenance is tracked in [`extraction-sheet.md`](./extraction-sheet.md).

## Quickstart

1. **5 minutes:** read this README + skim [`00-principles/`](./00-principles/) — the four design axes shaping every chapter.
2. **30 minutes:** read [`01-linear-as-load-bearing-pm/`](./01-linear-as-load-bearing-pm/) — the showcase chapter. Strongest unique-axis material; sets the load-bearing-PM-tool framing every other chapter rests on.
3. **2–3 hours:** skim the remaining chapter READMEs; pick 1–2 that match your sharpest current pain.
4. **2–3 weekends:** fork, adapt, run. Pick the migration order from the chapter you skimmed. Don't try to adopt everything at once.

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
| 08 | [Agent safety](./08-agent-safety/) | ✓ | Threat model (OWASP LLM/Agentic + lethal trifecta), agent hardening (audit/firewall/secret-guard + credential proxy), session isolation (tmux ≠ sandbox, Seatbelt/bubblewrap, containers/VM, cloud-session sandbox) |

Every chapter is substantive (README + sub-topics + field-tested gotchas + innovative patterns). Forking and adapting is the intended use; PRs back are welcome for new chapters, depth-expansion, or honest corrections.

## Positioning

The closest adjacent repos:

- **[`garrytan/gstack`](https://github.com/garrytan/gstack)** — Claude Code as a software factory. ~31 core skills (the often-quoted "65+" predates a 2026 consolidation), GBrain memory layer. Zero PM tool integration, no ADHD framing, no cross-tool/filesystem conventions. *We are complementary, not competing — this playbook teaches the org layer that gstack assumes you already have.*
- **[`yayashuxue/solo-founder-playbook`](https://github.com/yayashuxue/solo-founder-playbook)** — Six Claude Code skills for founder strategy (idea evaluation, growth, plan roasting). Zero engineering workflow. *Different layer; we don't overlap.*
- **[`hesreallyhim/awesome-claude-code`](https://github.com/hesreallyhim/awesome-claude-code)** — Directory of Claude Code skills, hooks, slash-commands, plugins. *That's the marketplace; this is the recipe book.*
- **[`XargsUK/awesome-adhd`](https://github.com/XargsUK/awesome-adhd)** — General ADHD apps, books, content. No dev/PM content. *Different audience; we link to it for the lifestyle layer.*

The unique axes this playbook owns:

1. **ADHD-aware design as a stack-design constraint** — not "use these ADHD apps" but "design every layer of your stack so it requires no daily discipline to maintain."
2. **4-layer memory architecture** — global rules → project rules → auto-memory → MCP cross-project memory, with the boundary rules between them.
3. **Linear as load-bearing PM** — exponential estimates, 1-week cycles, snooze-as-hibernation, Triage-as-inbox, weekly project updates as auto-retro. End-to-end recipe, grounded in primary docs.
4. **Agent-autonomous-ready ticket standard** — a 7-section + execution-metadata + stop-conditions ticket schema that lets you hand any ticket to an agent with only its ID.
5. **Agent safety grounded in practitioner research** — chapter 08 cites [`pleasedodisturb/llm-safe-haven`](https://github.com/pleasedodisturb/llm-safe-haven) (4-tier→5-tier scorecard + reference hooks) and [`pleasedodisturb/rbw-proxy`](https://github.com/pleasedodisturb/rbw-proxy) (credential-proxy for sandboxed agents) as same-tier prior art alongside OWASP LLM Top 10 + the lethal-trifecta framing.
6. **Cross-tool integration** — Linear + Claude Code + tmux + launchd + ntfy + filesystem-layout as one coherent system, not isolated tools.

## Contributing

Two paths:

- **Fork and adapt** is the default use. Sanitize before publishing your fork — see [`SANITIZATION-SCAN.md`](./SANITIZATION-SCAN.md) for the checklist.
- **PRs back to this repo** are welcome for: new chapters that fill an obvious gap, depth-expansion of existing chapters (with sources cited per the chapter's own discipline — see [`.planning/HANDOFF.md`](./.planning/HANDOFF.md) §"Citation discipline"), and honest corrections of stale vendor claims or broken cross-links. Issues for chapter-scope discussion are also welcome.

The provenance discipline is in [`extraction-sheet.md`](./extraction-sheet.md). The audit baseline for the playbook's current state is [`.planning/audits/2026-06-01-cross-chapter-audit.md`](./.planning/audits/2026-06-01-cross-chapter-audit.md).

## License

Dual-licensed: prose under [**CC BY 4.0**](https://creativecommons.org/licenses/by/4.0/), code samples + scripts under [**MIT**](https://opensource.org/licenses/MIT). Full text + attribution guidance in [`LICENSE`](./LICENSE).

## Credits

See [`credits.md`](./credits.md) for sources, primary docs, peer-reviewed citations (ADHD research), and adjacent repos that this playbook draws from or points to.
