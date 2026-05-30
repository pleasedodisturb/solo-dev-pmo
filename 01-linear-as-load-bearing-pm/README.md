# 01 — Linear as load-bearing PM

> Make your project management tool the backbone of the system. Not a side-channel. Not a place you forget to update. The load-bearing layer that every other layer references.

This chapter is the showcase. It's the most fleshed-out section of this playbook because the gap between "I use Linear" and "Linear is load-bearing for my whole workflow" is the largest delta most solo devs can make in a week.

## Why Linear specifically?

This chapter uses [Linear](https://linear.app) as the working example because:

- It's a working tool the author runs at production scale solo.
- Every recommendation here is grounded in primary Linear docs (cited inline).
- The features Linear ships — exponential estimates, Triage as inbox state, weekly Project Updates with reminders, snooze, auto-roll cycles — map cleanly onto ADHD-aware design constraints.

**The patterns transfer.** If you use [Plane](https://plane.so), [Tracker](https://tracker.org), [Height](https://height.app), [GitHub Projects](https://github.com/features/issues), or build your own: the *patterns* (Triage as inbox, exponential estimates, snooze as hibernation, weekly retros as auto-reminders, agent-autonomous tickets) hold. Implementation maps differ.

If your tool can't do something here — for instance, GitHub Issues has no Triage state — you fake it with a label or a column. The principle, not the feature, is what matters.

## What this chapter covers

| Section | What it solves |
|---|---|
| [Cycles and rituals](./cycles-and-rituals.md) | 1-week cycles, auto-roll, weekly Project Updates as auto-retro. Solves: weekly rhythm without daily willpower. |
| [Triage as inbox](./triage-as-inbox.md) | Triage state is the single capture surface. Solves: lossless capture, single source of truth. |
| [Estimates: exponential](./estimates-exponential.md) | 1/2/4/8/16 scale where 16 = "break it up." Solves: time-blindness + structured chunking. |
| [Snooze as hibernation](./snooze-as-hibernation.md) | `snoozedUntilAt` is a deliberate hibernation marker. Solves: 200+ Backlog tickets without dread. |
| [WIP cap with continuous-area exemption](./wip-cap-with-continuous-areas.md) | ≤3 *started* push projects; ongoing maintenance projects exempt. Solves: scope spread. |
| [Agent-autonomous-ready ticket standard](./ticket-standard.md) | 7 sections + execution metadata + stop conditions. Solves: handing tickets to agents safely. |
| [I/O rules (CLI > MCP locally)](./io-rules.md) | How Claude reads/writes Linear. CLI for reads + simple updates, GraphQL for what CLI lacks, never the Linear MCP locally. |
| [Never defer ticket creation](./never-defer.md) | File the ticket NOW in full quality, even if you're not doing the work today. Solves: forgetting forever. |

## The before/after

| Before | After |
|---|---|
| ~270 open issues, no structure | 100 in-play / 200 hibernating, clear separation |
| 92% issues never in a cycle | Active cycle has 5-10 issues max |
| 97% issues without estimates | Every cycle-bound issue estimated, 16-pointers force breakdown |
| 8 "started" projects, only 6 with In Progress issues | 3 push projects + N continuous-area exempt |
| No Monday plan / Friday retro ritual | Both triggered by launchd + ntfy + Project Update reminder |
| Tickets unusable by agents (no AC, no verification) | Every ticket pickup-able with only its ID |
| Linear-only-when-I-remember | Linear is the inbox; everything routes there |

## Required Linear setup

Before you can adopt this chapter end-to-end, your Linear workspace needs:

- **Cycles enabled** — Settings → Team → Cycles. 1-week, lock=off, auto-assign-started=on, auto-assign-completed=on.
- **Triage enabled** — Settings → Team → Triage. This becomes your inbox.
- **Exponential estimates** — Settings → Team → Estimates → "Exponential (1, 2, 4, 8, 16)."
- **Project Update reminders** — Settings → Workspace → Project Updates → weekly Friday 16:00 (or your retro time).
- **Auto-archive** — Settings → Workspace → 1 month for closed issues.
- **An issue template** named something like `Agent-autonomous-ready ticket` with the sections from [the ticket standard](./ticket-standard.md).
- **A `route` label group** with `route/agent` and `route/human-only` children (single-select).

Specific config recipes are in each sub-section.

## What you build alongside Linear

The setup above is Linear-side. To make Linear *load-bearing*, you also need:

- A **CLI capture tool** that takes a string and files it to Triage in < 3 seconds. (Chapter scope: this chapter shows the pattern; implementation can be a bash wrapper around your tool's CLI / GraphQL.)
- A **ritual trigger** — launchd job that fires Monday morning + Friday afternoon, opens a saved view, pushes ntfy. See [Chapter 04](../04-rituals-and-triggers/).
- An **auto-roll cycle setting** so you never manually triage carry-over.
- **Saved views** for: This week, Blocked, No estimate, No cycle, Stale, Resurfaced. Set "This week" as your default landing view.

Once those are wired, Linear stops being "the tool I forget to update" and starts being "the tool that surfaces what I need to do today."

## Primary sources (cited throughout)

- [Linear Triage](https://linear.app/docs/triage)
- [Linear Cycles](https://linear.app/docs/use-cycles)
- [Linear Estimates](https://linear.app/docs/estimates)
- [Linear Custom Views](https://linear.app/docs/custom-views)
- [Linear Filters](https://linear.app/docs/filters)
- [Linear Inbox](https://linear.app/docs/inbox)
- [Linear Project Status](https://linear.app/docs/project-status)
- [Linear Project Updates](https://linear.app/docs/initiative-and-project-updates)
- [Linear Method](https://linear.app/method/introduction)
- [How we built Project Updates — Linear blog](https://linear.app/now/how-we-built-project-updates)
