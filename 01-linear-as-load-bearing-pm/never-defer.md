# Never defer ticket creation

> When you notice a ticket-worthy issue, file the ticket NOW in full agent-autonomous quality. Never "I'll file this next session." That phrase is a recipe for forgetting forever.

This is the most important behavioral rule in this chapter. Most other rules are about config or process. This one is about a recurring 3-minute decision that compounds into either a working system or a graveyard of half-thoughts.

## The rule

If you spot a ticket-worthy thing while doing other work — a bug, a follow-up, a research finding, a "we should also do X" — **file the ticket in this session, in full quality, before continuing the original work.**

The cost: ~3 minutes (or zero if you delegate to a background agent).
The alternative cost: the issue gets lost across session boundaries, context compaction, and project switches. Months pass. The same issue gets re-discovered, re-evaluated, re-discussed — burning hours every time.

## Why this rule exists

The exact origin: a solo dev's recurring failure mode of "next session: file ticket X" notes that never materialized. The framing that named it: *"What you said in number one, file new linear ticket later is basically a recipe for forgetting this forever and this is not okay. Tickets are cheap. Create high quality tickets even if you see an issue and you may postpone it. Create it once and then carry on. Create it through a background agent. It's easy. Just hand off. But never defer."*

The deferral feels rational ("I'm in the middle of something"). It isn't. The "in the middle of something" focus is precisely what makes you forget. By the time the current task ends, the captured insight has decayed.

This is the operational form of GTD's founding claim: "your mind is for having ideas, not holding them."[¹] David Allen's whole system rests on an "inverse relationship between things on your mind and those things getting done" — get the open loop into a trusted external system *now* so your head is clear for the current task.[¹] Never-defer is that principle with teeth: the trusted system only stays trusted if you file *immediately*, at full quality, instead of holding "I'll write it up later" in working memory (where it rots).

## What counts as ticket-worthy

File the ticket NOW when you notice:

- A bug surfaced during work you're not fixing right now
- A pattern of issues that warrants a refactor
- A research finding that implies future implementation
- A user-facing decision needing follow-up after an external trigger
- A "we should also do X next" insight from any session
- A missing test, missing documentation, or missing error case
- A dependency you'd like to add but isn't blocking current work
- A convention that should be documented but isn't yet
- A spike you should do later before committing to an implementation
- An edge case the current code doesn't handle but should

The "I noticed this" moment is the signal. Don't wait for "I'm sure this is worth it" — file the ticket and let the prioritization happen at Monday planning.

## How to apply

1. **File at full quality** — agent-autonomous-ready per [ticket-standard](./ticket-standard.md). The whole point: filing it in shitty form just defers the problem to "future me writes a real spec." Write the real spec now.

2. **Channel:** PM tool first (Linear, Plane, etc.). If the work touches an OSS / public project, file a GitHub Issue too (and link the Linear ticket to it).

3. **If filing is itself 30+ minutes:** delegate to a background agent. The agent prompt should include:
   - The bug / finding context
   - The ticket-standard spec format
   - Access to the PM tool's CLI + token
   - "File the ticket as <project>, return the URL"
   
   Hand off. Don't postpone.

4. **If you're waiting on a user decision before filing:** still file the ticket. Mark it `Backlog` with the question in the description. The ticket exists; the decision unblocks it later.

## The capture-vs-ticket distinction

There's a difference between:

- **Capture** (Triage) — a thought, rough, < 30 seconds to record. May or may not mature into a ticket.
- **Ticket** (Backlog / Cycle) — agent-autonomous-ready, full template, ~3 minutes to write.

The Never-Defer rule applies to *ticket-worthy* things — items you know are real, with enough scope to warrant the full spec. Quick capture for things you're not sure about is still fine.

The distinction: would-you-bet-money-on-this-being-real-work? Yes → file the ticket. No → quick capture, let morning Triage decide.

## Anti-patterns to never write

Stop and check yourself if you ever type these:

- ❌ "Next session: file Linear ticket for X"
- ❌ "Worth a follow-up Linear ticket"
- ❌ "TODO: create issue when we get to it"
- ❌ "Will track separately later"
- ❌ "Note for next batch: file ticket"
- ❌ "Adding to my mental TODO"
- ❌ "Reminder to myself: handle X next week"

If you find yourself typing any of these, stop. File the ticket in this turn instead. The 3-minute cost is always cheaper than the cost of forgetting.

## Counter-rule

There IS one exception: if your collaborator (or you, deliberately) says *"don't file a ticket for this"* or *"we'll think about it later,"* respect that.

Only an explicit deferral overrides the file-now rule. Implicit "I'll get to it" is not deferral; it's forgetting.

## Field-tested cost numbers

Some data from real audits:

- **Cost of filing a quality ticket:** 2-5 minutes (less with templates pre-filled)
- **Cost of deferring (the failure mode):** ~30-90 minutes the next time the same issue gets re-discovered (re-discover + re-context + re-discuss + half-write a half-spec + lose interest again)
- **Failure-mode rate:** in one engineer's audit, ~80% of "I'll file next session" notes never materialized
- **Net expected value of deferring vs. filing now:** strongly negative

## What this enables

This rule is what makes the agent-autonomous-ready ticket standard *worth* having. If half your tickets are stubs that "got filed in shitty form to clear the mental load," your agents can't pick them up and you don't trust the Backlog.

When every filed ticket is at the standard, the Backlog becomes a reliable source of work — for you OR for your agents. That trust is what makes the whole system load-bearing.

## Innovative pattern: "filing budget" per session

Pre-allocate a "filing budget" at session start: e.g., 15 minutes for ticket filing during this session.

If you blow past the budget on filings, two things become visible:
1. You're noticing more issues than your project is shipping — scope is sprawling.
2. The current work is generating an abnormal number of follow-ups — investigate why.

Either is useful signal. The budget doesn't constrain how much you file; it makes the volume visible.

## Innovative pattern: "filing companion" agent

Spawn a background agent at session start whose only job is to file tickets you direct to it.

You: *"In a comment: 'Need to fix the broken pagination on the dashboard.' File this."*
Agent: writes the full spec, files it, replies with the URL.
You: keep working.

Pre-filling the agent with the ticket-standard format makes this near-instant. The 3-minute filing cost goes to the background; you stay in flow.

## What this rules out

- **No "mental TODO."** The moment you trust your memory instead of the system, the system stops being the single source of truth and you're back to forgetting.
- **No low-quality "placeholder" tickets to clear the thought.** A stub just defers the real spec to future-you. File it at the [ticket standard](./ticket-standard.md), or quick-*capture* it to Triage and let the morning pass mature it — but don't file a half-ticket and call it done.
- **No implicit deferral.** Only an *explicit* "don't file this" (yours or a collaborator's) overrides the rule. "I'll get to it" is not deferral; it's forgetting.

## Field tests beyond the author

No external write-up publishes this exact "never defer ticket creation" rule by name — it's the author's framing. Its grounding is GTD's capture discipline ("get everything out of your head into a trusted system")[¹] and the broader practitioner consensus that *captured-immediately* beats *captured-later*. The honest status: the rule is author-original in wording, GTD-derived in principle, and field-tested at one engineer's scale; the cost numbers below are from that engineer's audits, not an external study.

## Sources

External quotes gathered via web search 2026-05-31; the GTD lines are cross-confirmed across the official site, Wikipedia, and Wikiquote. Full notes in [`sources.md`](./sources.md).

- [1]: David Allen, *Getting Things Done* — https://gettingthingsdone.com/about/ ; "inverse relationship" via https://en.wikipedia.org/wiki/Getting_Things_Done — accessed 2026-05-31

## Related

- [Ticket standard](./ticket-standard.md) — what "full quality" means
- [Triage as inbox](./triage-as-inbox.md) — where captures land before maturing
- [00 — ADHD-aware design](../00-principles/adhd-aware-design.md) — affordance #2: lossless capture
- [Chapter 06 — Session discipline](../06-session-discipline/) — applies to commits, PRs, etc.
