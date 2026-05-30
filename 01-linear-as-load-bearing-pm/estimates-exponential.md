# Estimates: exponential

> The estimate scale is a design choice. Pick exponential (1, 2, 4, 8, 16) and let the 16 be a stop sign.

## The recipe

Settings → Team → Estimates → **Exponential (1, 2, 4, 8, 16)**.

[Linear docs](https://linear.app/docs/estimates) describe the choice plainly: *"Larger estimates usually mean uncertainty. Breaking up issues into smaller ones is the best approach."*

The exponential scale enforces this. The 16-pointer is a deliberate dead-end: anything you estimate as 16 is too big to commit to as one issue and must be broken down.

## Why exponential, not Fibonacci or T-shirt

| Scale | Values | Solo + ADHD verdict |
|---|---|---|
| T-shirt (XS/S/M/L/XL) | 5 buckets, no math | Hides time-blindness. "M" is whatever you want it to be. |
| Linear (1/2/3/4/5) | Compresses the long tail | Forces "is this a 4 or a 5?" debate. Wasted decision energy. |
| Fibonacci (1/2/3/5/8/13/21) | Spreads through middle | Designed for committee planning poker. Not a solo problem. |
| **Exponential (1/2/4/8/16)** | Doubles each step | Forces "half-day / full-day / multi-day" framing. 16 is a wall. |

For solo + ADHD:
- T-shirt: too vague to detect chronic underestimation
- Fibonacci 13 / 21: useless top end — both translate to "this isn't going to ship this cycle"
- Linear 1-5: 3 and 4 become a debate
- **Exponential**: 1=hour, 2=morning, 4=half-day, 8=full-day, 16=BREAK IT UP. Clear framing.

## What each value means (calibrated)

| Estimate | Wall-clock | When to use |
|---|---|---|
| 1 | ~1 hour | Single small thing — fix a typo, update a config, file a ticket |
| 2 | ~2-3 hours | Morning's work — small feature, focused investigation |
| 4 | ~half a day | A real feature, well-scoped |
| 8 | ~1 full day of focused work | A bigger feature, will need most of the day |
| 16 | multi-day | **STOP** — this is too big; break it up before committing |

These are *focused* hours, not calendar hours. A "half-day" estimate (4) assumes 3-4 hours of actual deep work, not 8 hours of clock time with meetings and interruptions in between.

**Calibration matters.** Your first few cycles' estimates will be wildly off. Track *actuals* alongside estimates so the underestimation pattern surfaces.

## The 16-point dead-end (the differentiator)

The 16-point estimate is the unique value-add of exponential. It's not "a bigger issue" — it's a **stop sign**.

When you (or an agent) estimate something as 16:
- Do not pull it into a cycle.
- Add a `breakdown` label (or your equivalent).
- Open the issue and write 2-5 sub-issues that each estimate at ≤ 8.
- The 16-pointer becomes a parent / tracker.

If the breakdown produces sub-issues that *also* estimate at 16, repeat. If you can't break it down past 16, the work isn't ready — there are unanswered questions. Spike it first (see `/gsd-spike` workflow if you use GSD).

**Field test:** ~40% of "I'll just do it this week" plans contain a 16-point issue in disguise — labeled as 8 because labeling it 16 would surface a problem the user is avoiding. Audit cycle plans for this. The disguised-16 is the issue that always slips.

## Calibration via actuals

Linear doesn't ship actuals tracking natively. Your options:

1. **Manual:** add an `actual: X` comment on issues when you close them. Run a script weekly that scrapes comments and produces an actuals report. Crude but works.
2. **Time-tracker integration:** Toggl, Harvest, or `timewarrior` with project tags matching ticket IDs. Pull at end of cycle.
3. **Cycle-scoped self-report:** at Friday retro, for each closed issue, write down whether estimate was Low / Right / High. Three buckets, no math.

The pattern over weeks: 60-70% of estimates land in "Right," 20-30% are "Low" (underestimated), 5-10% are "High" (rare). The "Low" cluster is your signal.

Specifically, look for the task type that consistently underestimates. Common patterns:
- "Submission" / "application" tasks underestimate by 2-3× (cover letter + research + tailoring eats time)
- "Investigation" / "debug" tasks underestimate by 4-10× (you can't bound an unknown)
- "Refactor" tasks underestimate by 1.5× (adjacent code keeps needing touch)

Default rule once a pattern surfaces: for that task type, double the estimate. So an investigation that feels like "2" gets entered as "4." After 2-3 cycles of doubling, you'll know whether you've corrected.

## What to estimate on

Estimate every issue that will enter a cycle. Don't estimate Backlog or Triage items — premature.

**Required-on-cycle-entry:** when you pull a ticket from Triage / Backlog into the current cycle (or commit it for next cycle), it must have an estimate. No estimate = it stays in Backlog. Some teams enforce this with a saved view (`Cycle = current AND Estimate is empty` should always be empty).

You can also use the *estimate-required-to-cross-state-boundary* gate. Add a soft gate: when an issue moves from Backlog to Todo, prompt for an estimate. (Linear doesn't ship this natively; a small script + webhook can approximate it, or just self-enforce.)

## What NOT to estimate

- **Continuous-area issues** (operational maintenance — Plex stack updates, Mac setup tweaks). These are unbounded by nature; estimating them is theater.
- **Captures that haven't been triaged.** Estimating something you haven't yet decided to do is wasted effort.
- **Epics / parent issues.** Estimate the children; the parent inherits the sum.
- **`route/human-only` items that are pure decision tickets.** "Decide which approach to take" doesn't estimate cleanly.

## Field-tested gotchas

**"I'll estimate later" never converges.** The cost of estimating at cycle-entry time is 30 seconds per ticket. The cost of deferring is that no estimates exist, and the cap-by-estimate logic doesn't apply. Estimate at the gate.

**An estimate is a contract with future-you, not a guess.** When you estimate 4, you're committing: "if this takes 8, that's data." Make estimates discoverable: e.g., a Friday view called `This week — over-estimate` filters issues where `actual > estimate * 1.5`.

**Watch out for the "comfort-zone 8."** When everything is estimated 8, you're not estimating — you're labeling. Force yourself to have at least one 1, one 2, and one 4 per cycle. Variety in the estimate distribution is a calibration check.

**Don't change Linear's scale mid-stream.** Existing issues retain their old-scale value. If you switch from Fibonacci to Exponential, do it on a Monday after closing the prior cycle, not mid-cycle.

**Linear's *Capacity dials* compute from "velocity of the previous three completed cycles."** Once your estimates calibrate, the dial reflects your real capacity. Set future cycle plans against it. Resist the urge to "plan ambitious" — the dial is the truth.

## Innovative pattern: agent-aware estimation

When an agent (Claude Code, etc.) takes a ticket from your queue, the agent self-reports estimate at pickup time AND at close time.

In the [ticket standard](./ticket-standard.md), the `Execution Metadata` section includes `Scope: S/M/L` plus a token budget hint:
- S (estimate 1-2) — stay under 50k tokens
- M (estimate 4-8) — stay under 150k tokens
- L (estimate 16) — refuse, force breakdown

At close, the agent comments with actual tokens consumed. Over time you get agent-side calibration data alongside your own.

## Related

- [Linear Estimates](https://linear.app/docs/estimates) — primary docs (note the "break up larger issues" quote)
- [Cycles and rituals](./cycles-and-rituals.md) — the cycle cap depends on real estimates
- [Ticket standard](./ticket-standard.md) — Execution Metadata section
- [WIP cap with continuous-area exemption](./wip-cap-with-continuous-areas.md) — what the estimates feed into
