# Ritual fatigue

> A mechanical trigger fixes "I forgot." It does nothing for "it fired and I
> ignored it." That second failure is ritual fatigue, and it's the one that kills
> a system. This file is how you detect and counter it.

[launchd](./launchd-over-cron.md) guarantees the ritual *fires*. It cannot make
the ritual *worth doing*. When you start swiping the Monday push away unread, the
trigger is working and the ritual is dead. Don't add discipline — diagnose.

## Diagnose with B=MAP

BJ Fogg's behavior model: a behavior happens only when **Motivation, Ability, and
a Prompt** converge at the same moment. Remove any one and it doesn't fire.[¹] An
ignored ritual is almost always one of three specific failures — name which:

| Leg | Symptom | Fix |
|---|---|---|
| **Ability** | "it's too much right now" | make it smaller — cut the 15-min plan to a 3-item check |
| **Motivation** | "I don't see the point anymore" | re-connect it to an outcome, or retire it |
| **Prompt** | "I swipe it away on autopilot" | re-anchor: change channel, change time, stack it on an existing habit |

Fogg's load-bearing insight: **raising Ability (making it smaller/easier) is more
sustainable than summoning Motivation**, which fluctuates.[¹] When in doubt, shrink
the ritual before you blame yourself.

## Detect it early: never miss twice

James Clear's rule: "Missing once is an accident. Missing twice is the start of a
new habit."[²] One skipped Friday retro is noise. Two in a row is the signal —
that's your trigger to diagnose, not next quarter. The cheapest detector is the
ritual telemetry the scripts already log (skip streak, time-to-complete, carry-over
count — see [Monday planning](./monday-planning.md)): a rising skip streak is
fatigue made visible before you've consciously noticed it.

## Counter-tactics (each maps to a principle)

1. **Make it smaller.** The most reliable fix — raise Ability.[¹] A ritual you
   resent at 15 minutes you'll still do at 3.
2. **Habit-stack onto an anchor.** Clear's formula: *"After [existing habit], I
   will [ritual]."* Hang the Triage pass on the first coffee, not on a clock.[³]
3. **Re-anchor the prompt.** A dead prompt is a top failure mode.[¹] Swap the
   channel (ntfy → calendar block → tmux banner), or move the time.
4. **Lower the cadence.** If a *daily* ritual is the thing being skipped, drop it
   to weekly rather than abandoning it. ADHD routines fail most often from being
   too ambitious to sustain, not too sparse.[⁴]
5. **Hard reset.** Delete the plist, sit with the gap a week, rebuild only what you
   missed. If you didn't miss it, it was ceremony — let it stay dead.

## When to retire vs restructure

Restructure when the *outcome* still matters but the *form* has gone stale
(shrink, re-anchor, re-channel). Retire when the outcome itself no longer
matters — a ritual that survives only because it's automated is overhead, not
signal. Killing a dead ritual is a feature; the audit trail
([Chapter 06](../06-session-discipline/)) remembers what you stopped and why.

## The special case: alert fatigue

Rituals push to your phone, so they're subject to a second, measurable decay.
Clinical alarm-fatigue research is blunt: in ICUs **85–99% of alarms are false or
clinically insignificant**, and the volume desensitizes clinicians into missing
the real ones.[⁵] The transferable rule: **a high false-positive rate is what
destroys the signal of *every* alert**, not just the noisy one.

So [ntfy topics](./ntfy-notifications.md) are a budget, not a free resource. Every
low-signal channel you add dilutes attention to all the others. There's no magic
maximum (that number is your call), but the principle is firm: **fewer channels,
higher signal.** A ritual whose notification you reliably ignore should lose its
push before it teaches you to ignore the ones that matter. Interruption itself has
a cost — interrupted work is completed faster but with more stress and effort.[⁶]

## ADHD framing — what this removes from working memory

The whole point of an automated ritual is to **offload remembering onto the
system** so executive function isn't spent on "what was I supposed to do today?"
— the externalize-working-memory principle ADHD scaffolding research
supports.[⁷] Ritual fatigue is what happens when that offload silently breaks: the
system still fires, but you've stopped acting, and now you're carrying the guilt
*and* not getting the benefit. Detecting fatigue early (never-miss-twice + skip
telemetry) keeps the working-memory savings real instead of theoretical. The
honest target is **the smallest ritual that survives** — not the most thorough one
you'll abandon in a month.

## Related

- [Monday planning](./monday-planning.md) / [Friday retro](./friday-retro.md) — the rituals this protects, with their own fatigue-contingency notes
- [ntfy notifications](./ntfy-notifications.md) — channel budget / alert fatigue
- [Chapter 00 — ADHD-aware design](../00-principles/adhd-aware-design.md) — ritual triggers, not ritual willpower

---

[1]: https://www.behaviormodel.org/ — BJ Fogg, Fogg Behavior Model (B=MAP); Ability over Motivation — accessed 2026-05-31
[2]: https://jamesclear.com/habit-tracker — James Clear, "never miss twice" — accessed 2026-05-31
[3]: https://jamesclear.com/habit-stacking — James Clear, habit stacking ("After [habit], I will…"), credited to Fogg — accessed 2026-05-31
[4]: https://greaterocchadd.org/helping-adults-with-adhd-build-consistent-routines-without-burnout/ — ADHD routines fail from over-ambition; keep them small/sustainable — accessed 2026-05-31
[5]: https://www.ncbi.nlm.nih.gov/books/NBK555522/ — alarm fatigue: 85–99% of ICU alarms false/insignificant; desensitization — accessed 2026-05-31
[6]: https://dl.acm.org/doi/10.1145/1357054.1357072 — Mark, Gudith & Klocke (CHI '08), "The Cost of Interrupted Work" — accessed 2026-05-31
[7]: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8505290/ — cognitive-scaffolding/EF interventions reduce ADHD symptoms — accessed 2026-05-31
