# ADHD-aware design

> **The rule:** design every layer of the stack around affordances rather than sustained discipline. Solutions that require you to remember to do things daily will fail.

This is the axis that shapes everything else. It's not about adopting "ADHD apps." It's about treating ADHD-style failure modes — torrents of unchunked ideas, lost context across project switches, inability to maintain weekly rituals on willpower alone — as **stack design constraints**.

If you don't have ADHD, the same constraints still help. Neurotypical engineers running solo also forget to do things. The system that holds for ADHD holds for everyone.

> **Evidence basis.** The empirical claims below (working-memory limits, "externalize instead of relying on willpower," time blindness, the chunking rule) are graded against the peer-reviewed literature in [evidence-and-citations.md](./evidence-and-citations.md). The short version: the central "affordances, not discipline" thesis maps directly onto Barkley's well-established "externalize at the point of performance" prescription; a couple of the supporting claims are reasonable inferences from the mechanism rather than directly tested; and one claim (the anti-streak one below) is practitioner lore, flagged as such. This is field-tested practice, not clinical guidance.

## The five required affordances

A solo-engineering stack that meets this constraint has these five mechanisms. If any are missing, the system silently fails.

### 1. Single source of truth

One inbox. One capture surface. Never "remember to write it down in X."

If you have to choose where to put a thought, you'll lose half of them. Pick one — usually your PM tool's Triage state (see [Chapter 01](../01-linear-as-load-bearing-pm/)) — and route everything there. Other surfaces (Slack channels, ntfy topics, voice memos) flow *into* the one inbox; they don't *compete* with it.

See also: [Single source of truth](./single-source-of-truth.md).

### 2. Lossless capture

The friction between "I had a thought" and "the thought is recorded" must be near zero.

Concrete: a CLI command (`<your-pm>-capture` or similar) that takes a string, files it to the inbox, and returns control in < 3 seconds. No app to open. No fields to fill. The capture is messy on purpose; you triage it tomorrow.

Better to capture every fleeting idea into a messy inbox than to lose them trying to file perfectly.

### 3. Structured chunking by default

Big ideas don't sit as big tickets.

Your PM tool must encode "this is too big" as a stop signal — see [exponential estimates](../01-linear-as-load-bearing-pm/estimates-exponential.md). When you (or an agent) try to commit a multi-day chunk to a cycle, the system pushes back and forces a breakdown.

The naive "I'll break it down later" plan fails because by the time later arrives, the context has decayed. ("Break it down later" is a prospective-memory bet, and ADHD loses that bet more often — prospective-memory impairment statistically mediates part of the ADHD→procrastination link; see [evidence \[B\]](./evidence-and-citations.md).)

### 4. Ritual triggers, not ritual willpower

If something must happen on Monday or Friday — Monday planning, Friday retro — it fires from a script, a launchd job, a calendar event, or an agent. Not from you remembering.

See [Chapter 04 — Rituals and triggers](../04-rituals-and-triggers/). The pattern: `launchd` plist + ntfy push + open PM tool view at the scheduled moment. Missing the ritual is impossible because the trigger fires whether you're paying attention or not. (External momentary cues beating unaided memory is the tested part; a randomized trial found SMS reminders improved adherence for adults with ADHD — see [evidence \[B\]](./evidence-and-citations.md).)

**Anti-pattern:** streak tracking / gamification. Don't track streaks; track *whether the trigger fired*, which is separable from whether you did the thing. A streak adds a failure mode — the broken streak — that a plain "did it fire?" check doesn't have, and you lose nothing by not counting. The common rationale ("a broken streak triggers an ADHD-specific guilt/shame spiral") is **practitioner lore, not established research** — the construct it leans on (rejection-sensitive dysphoria) is unvalidated and not in the DSM-5. We keep the advice because it stands on its own as system design; we don't claim the spiral mechanism. See [evidence \[C\]](./evidence-and-citations.md).

### 5. WIP limits enforced by the system

"Try to focus on fewer things" is not a strategy. Cap *started* projects at N (typical: 3). When you try to start an Nth+1, the system surfaces the cap as a hard constraint — you have to explicitly pause or cancel something else first.

See [WIP cap with continuous-area exemption](../01-linear-as-load-bearing-pm/wip-cap-with-continuous-areas.md). Important nuance: continuous-area projects (ongoing maintenance — Plex stack, Mac setup, awesome-list curation) are exempt from the cap. The cap is on *push* work.

## What this rules out

- **Manual review rituals** — "every Monday I check the backlog." No. The system surfaces what needs review.
- **Memory-based capture** — "I'll add it to the ticket later." No. Capture now, triage later.
- **Discipline-based scheduling** — "I'll just stay focused this week." No. The cap on cycle WIP enforces focus.
- **Self-improvement framing** — "I should get better at X." No. Build a system that doesn't depend on you being better.

## What this rules in

- **Stop signals from the tool** — Exponential estimates with 16 as a "break this up" sign. WIP caps that block instead of warn. Triage as the *only* inbox.
- **Push notifications for triggers** — ntfy, system notifications, agent-posted comments.
- **Snooze as a deliberate hibernation marker** — see [snooze-as-hibernation](../01-linear-as-load-bearing-pm/snooze-as-hibernation.md). Backlog items that aren't actionable now go to sleep; the tool wakes them at the right time.
- **Agent-mediated handoff** — when you switch projects, the agent re-loads context for you. Not the reverse.

## Alternatives

Other frameworks aimed at the same problem. We borrow from several; we reject the ones whose *upkeep is itself a discipline ritual*.

| Framework | What it is | Why we didn't adopt it wholesale |
|---|---|---|
| **GTD** ([Getting Things Done](https://gettingthingsdone.com/)) | capture everything, process into next-actions | strong on lossless capture (we borrow it) — but the weekly review is a willpower ritual; we replace it with system-fired triggers ([Chapter 04](../04-rituals-and-triggers/)) |
| **[Building a Second Brain](https://www.buildingasecondbrain.com/) / PARA** | manual folder taxonomy (Projects/Areas/Resources/Archives) | manual filing is exactly the discipline tax we remove; the memory layers + one inbox auto-route instead |
| **[Bullet Journal](https://bulletjournal.com/)** | analog notebook with daily/monthly "migration" | migration is a daily ritual and analog has no triggers or push — fails the "requires remembering" test |
| **[Habitica](https://habitica.com/) / streak gamification** | RPG/streak rewards for habits | streaks add a failure mode (the broken streak); rejected — see [evidence \[C\]](./evidence-and-citations.md) |
| **Body doubling / accountability partners** | another person present to anchor focus | social-synchronous; doesn't fit solo-async work with agents. Useful adjunct, not a system. |
| **[Leantime](https://leantime.io/)** | open-source PM tool built for neurodivergence | a *tool you adopt*; this playbook is the recipe for integrating tools you already run. Complementary, not competing. |
| **EF scaffolding / "point of performance"** (Barkley) | externalize cues at the moment of need | this is our *root*, not an alternative — see [evidence \[A\]](./evidence-and-citations.md) |

**Why "affordances, not discipline" wins for this stack:** every other framework still has a human-maintained step — a review, a migration, a filing decision, a streak to protect. Each of those is a place the system fails the day you forget. The differentiator here is that the maintenance step is pushed onto the system (a trigger fires, the inbox auto-routes, the cap blocks), so there's nothing left to *remember to do*. We keep the good parts (GTD's capture, Barkley's externalization) and drop the rituals.

## Origin

This principle was named explicitly during a 2026 design conversation as the failure mode of every prior PM/organization attempt by an ADHD solo developer. The exact framing: *"adhding all over the place... torrents of ideas with no chunking, losing context across tmux panes, inability to maintain Monday planning + Friday retro rituals, no handoff structure between parallel projects."*

Every chapter in this playbook is downstream of this principle. When in doubt, ask: *"does this require the human to remember to do something?"* If yes, redesign.

## Related

- [Evidence basis and citations](./evidence-and-citations.md) — every empirical claim above, graded against the peer-reviewed literature (and the lore flagged as lore)
- [Single source of truth](./single-source-of-truth.md) — the inbox part of the rule
- [Chapter 01 — Linear as load-bearing PM](../01-linear-as-load-bearing-pm/) — the tool that implements most affordances
- [Chapter 04 — Rituals and triggers](../04-rituals-and-triggers/) — the ritual-trigger part
- Adjacent reading: [`XargsUK/awesome-adhd`](https://github.com/XargsUK/awesome-adhd), [Leantime — Open Source PM for ADHD](https://leantime.io/open-source-project-management-for-adhd-why-we-built-leantime-for-neurodivergent-productivity/)
