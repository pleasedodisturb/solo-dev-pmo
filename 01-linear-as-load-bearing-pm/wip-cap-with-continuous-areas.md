# WIP cap with continuous-area exemption

> Cap at 3 *push* projects in `started` status. Continuous-area projects (ongoing maintenance, curation) are exempt.

This section solves the most common solo-dev failure mode: 8+ projects "started," only 2-3 actually getting attention. The intervention is a WIP cap. The non-obvious nuance is the exemption rule — which is where most generic advice gets this wrong.

## The cap

**No more than 3 push projects in `started` status at any time.**

A push project = bounded work with an end state. Ship a feature, launch a thing, complete a research phase, finish a milestone.

When you start a 4th push project, the cap is the question: *which existing one do you pause, cancel, or finish before this one starts?*

That decision is the affordance. The cap exists to force the decision; not to enforce the count.

## The exemption: continuous areas

A naive read of "≤3 started projects" produces nonsense: you have to pause your Plex stack maintenance? Your awesome-list curation? Your weekly ritual system? These are *ongoing operational areas*, not bounded work.

The fix:

> **Cap applies only to push projects. Continuous-area projects are exempt and stay `started` permanently.**

What's a continuous area?

- **Operational support** — Mac setup & environment, password manager / secrets, dotfiles, home network, Plex stack, Synology / NAS, Hetzner infra, backup systems, weekly ritual system. These don't ship; they get maintained.
- **Curation / maintenance** — awesome-* lists, "things worth tracking" projects, llm-tooling-haven projects. New entries land; cap-bound them and you bottle ideas.
- **Continuous personal areas** — finance / budget (always-on), job search-as-area (when you have ongoing applications), reading list, learning queue. The work never "ships"; you just do it.

Continuous areas in Linear: structure each as a Project with no Initiative attached. (Initiatives are for outcome-bounded work.) Continuous-area projects intentionally don't have a target end state.

## Concrete recipe in Linear

Linear ships 5 fixed Project Status categories: Backlog, Planned, In Progress (named "Started" or similar), Completed, Canceled. From [Linear Project Status docs](https://linear.app/docs/project-status): *"If a workspace has any paused projects, they'll be assigned a Paused status under the Planned category."*

The Paused status is the WIP-limit lever for push projects:

1. **Started** = currently a push project AND in active work this cycle.
2. **Paused** = a push project you're not actively pushing on but will return to.
3. **Backlog / Planned** = haven't started yet.
4. **Completed / Canceled** = done.

Continuous-area projects stay **Started** permanently. They never go Paused, because pausing them means "captures route somewhere else for a while" — which violates the [single source of truth](../00-principles/single-source-of-truth.md) principle.

## Why 3, not 1, not 5

- **1 push project** is too restrictive. Solo devs naturally have one primary push, one swap-in (when primary is blocked), and one "maintenance push" (something you're slowly improving). 1 forces context-switching cost on every block.
- **5 push projects** are too many. Even at full focus, advancing 5 in a 1-week cycle means each gets ~1 day of attention — and you don't get into deep work on any.
- **3** matches the empirical: one primary push + one secondary + one micro-push. It also matches the cycle-WIP cap (5 issues / cycle; ~2 issues per push project per cycle).

If you have more than 3 push projects in flight, your cycle plan won't land. You'll either spread thin across all 3 or completely abandon some.

## Detecting cap breaches

Linear doesn't enforce caps. You build the detection.

Two saved views:

```
View: "Push projects started"
  filter: Project.status.category = In Progress
          AND Project.initiative IS NOT NULL  
          (continuous-area projects have NO initiative; this filter excludes them)
  count: should be ≤ 3
```

```
View: "All started projects (including continuous areas)"
  filter: Project.status.category = In Progress
  count: can be unbounded (typical: 3 push + 5-8 continuous areas)
```

When the first view shows > 3, the cap is breached. Action: pause one push project or accept the breach with an explicit reason (write it in the project description: "knowingly over cap because X").

For mechanical enforcement, your Monday planning script queries the count via GraphQL and refuses to add issues to a 4th started push project until you pause one.

## What "continuous area" means in your stack

If you adopt this playbook end-to-end, your Linear typically has:

**Push initiatives** (each contains 1-3 push projects):
- Job Search (typically the most time-sensitive)
- Major bounded feature / launch (one at a time)
- Cross-tool integration project (this playbook itself, if you adopt it)

**Continuous-area projects (no initiative):**
- Mac Setup & Environment
- Money & Finance
- Mega Cleanup (Layout B disk reorg, tag hygiene, ongoing)
- Plex Server Infrastructure
- Plex Server: DR & Security Hardening
- Synology Storage & Recovery
- Hetzner / cloud infra operations
- Weekly Ritual System (rituals are continuous infra, not bounded outcome)
- awesome-* list maintenance (one project per list)
- Tooling research (if always-on)

Note the asymmetry: continuous areas often outnumber push initiatives 2-3 to 1. That's normal.

## What the WIP cap is NOT for

The WIP cap doesn't address:

- **How many issues are open.** Use [snooze](./snooze-as-hibernation.md) for that.
- **How busy you feel.** "Busy" is downstream of bad estimates ([estimates-exponential](./estimates-exponential.md)) and bad cycle planning ([cycles-and-rituals](./cycles-and-rituals.md)).
- **Time-blocking.** That's [Chapter 04 — Rituals and triggers](../04-rituals-and-triggers/) territory.

The cap exists for *one* thing: forcing a deliberate "pause or proceed" decision when starting a new push project.

## Field-tested gotchas

**The over-strict audit read.** A naive reading of "≤3 started" — auditing the raw Project status field without separating push from continuous — produces a false positive. The audit will say "you're at 10 started projects, cap broken." You're not. You're at 2-3 push + 7-8 continuous. The cap holds. The fix is to write the exemption explicitly into your conventions doc so future audits respect it.

**Pausing a continuous-area project causes captures to leak.** Tickets that would route to a paused project either land in `Triage` orphaned, or in a different project where they don't belong. Continuous areas must stay Started so the routing target exists.

**The "I'll just start a 4th push" temptation is high during context-switching.** When the primary push is blocked, the urge is to "start the next thing." Resist. Either work the swap-in (which is already inside the cap) or do a continuous-area task. Don't start a new push.

**Auto-pausing is NOT the answer.** Some setups auto-pause projects when the cap is exceeded. Don't. The cap exists *to surface the question*, not to silently re-arrange. Auto-pause hides the breach.

**Project Paused != Issues Hidden.** A paused project's issues still exist; they just have a paused project context. Pause is a project-level signal, not an issue-level cull. Snooze is for issue-level.

## Innovative pattern: explicit "swap-in" project

Within the 3-cap, designate one slot as the "swap-in" — the project you work on when the primary is blocked.

Convention: project description starts with `priority: swap-in` (or use a label). This communicates intent:
- Primary push: full attention when not blocked
- Swap-in push: only worked when primary is blocked
- Maintenance push: cap slot for something you're slowly advancing

The naming makes the swap dynamic visible. Without it, you context-switch organically and lose track of which is primary.

## Innovative pattern: cycle-bound project rotation

Layer on top: **one cycle = one project focus.**

Each Monday, pick one push project as the cycle's "lead." All cycle issues should be from that lead. Other push projects' issues stay in Backlog this cycle.

Rationale: solo + 1-week cycle + 5 issue cap = you can either do 5 small things in 5 different projects, or 5 focused things in one project. The latter ships; the former churns.

Exception: blocked-on-external work. If you're blocked on the lead project (waiting on an external response), you swap to the secondary push for the duration.

Track the lead rotation in a `cycles.md` conventions file: which cycle was lead by which project. Look back monthly — projects that never rotate to lead aren't actually in-cap.

## Related

- [Linear Project Status](https://linear.app/docs/project-status) — primary docs
- [Cycles and rituals](./cycles-and-rituals.md) — cycle-level focus follows project-level cap
- [I/O rules](./io-rules.md) — Initiative ↔ Project structure
- [00 — ADHD-aware design](../00-principles/adhd-aware-design.md) — affordance #5
