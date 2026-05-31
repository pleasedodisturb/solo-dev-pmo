# Evidence basis and citations

The principles in this chapter — especially [ADHD-aware design](./adhd-aware-design.md) — make empirical claims about how ADHD brains fail and what compensates. This doc is the one place those claims are graded against the published literature.

It exists because the rest of the chapter is **field-tested practice, not clinical guidance**, and the honest move is to say exactly where the practice lines up with peer-reviewed research and where it's running on practitioner lore. We'd rather hedge a claim than dress up a blog post as a study.

> **What this doc is not:** a clinical reference, a diagnostic aid, or a treatment recommendation. It's a provenance trail for the design claims in this chapter. If you want clinical guidance, talk to a clinician.

## How to read the tiers

Every empirical claim in this chapter is tagged with one of three tiers:

| Tier | Meaning | How we treat it |
|---|---|---|
| **[A] Well-supported** | Multiple peer-reviewed studies, usually including a meta-analysis or a canonical theoretical model. | State plainly. |
| **[B] Plausible / indirect** | The *mechanism* is supported, but the specific design claim is an inference from it, not a directly tested result. | State, but flag the inferential step. |
| **[C] Practitioner lore** | Widely repeated in ADHD coaching / community writing; little or no peer-reviewed support; sometimes the underlying construct isn't validated. | Keep only if the *practical advice* stands on its own. Flag the claim as unproven. |

The point of the tiers is that a reader can trust an [A] claim, sanity-check a [B] claim against their own experience, and treat a [C] claim as "this worked for us, your mileage may vary."

## Claim-by-claim grounding

### "Working memory is finite, more so with ADHD" — [A]

The chapter's framing premise (in the top-level README and [ADHD-aware design](./adhd-aware-design.md)) is that you offload state because working memory is limited, and more limited under ADHD.

- Children: a meta-analysis of working-memory impairments across studies from 1997–2003 found medium-to-large deficits, strongest in the spatial/central-executive components (Martinussen et al., 2005).
- Adults: a meta-analytic review of 38 studies found working-memory deficits persist into adulthood, with moderate between-group effect sizes (Alderson et al., 2013).

**Honest caveat:** effect sizes are group-level. Estimates suggest only ~35–40% of *individuals* with ADHD show a measurable working-memory impairment on a given task (Kasper et al., 2012). "ADHD means you have bad working memory" is too strong; "ADHD raises the odds your working memory will let you down, so don't bet your system on it" is the defensible version — and it's also the version the design constraint needs.

### "Affordances, not discipline" / "externalize instead of relying on willpower" — [A]

This is the load-bearing thesis of the whole chapter, and it is the part with the *strongest* clinical backing.

Barkley's unifying model frames ADHD as fundamentally a disorder of behavioral inhibition and self-regulation — the executive functions that let you act on internal, self-generated, future-directed motivation are exactly the ones that are weak (Barkley, 1997a). The direct clinical corollary, which Barkley argues explicitly, is that effective support **externalizes** information, time, rules, and motivation **at the "point of performance"** — the place and moment the behavior is needed — rather than relying on internal recall or sustained willpower (Barkley, 1997b). Sticky notes, alarms, visible cues, and immediate external feedback outperform verbal instruction and delayed reward.

That is, almost verbatim, this chapter's rule. "Design every layer around affordances rather than sustained discipline" is the personal-systems restatement of Barkley's point-of-performance principle.

**Two honest notes:**
1. Barkley's prescription is about clinical and behavioral intervention; we're applying it to dev-tooling and PM-stack design. The extension is reasonable but it's *ours*, not his.
2. The word "affordance" itself comes from design theory (Norman, *The Design of Everyday Things*), not ADHD research. We're fusing a design concept with a clinical finding. Both halves are real; the fusion is the playbook's editorial move.

### "You can't maintain weekly rituals on willpower; fire them from a trigger" — [B]

Follows from the same self-regulation literature (Barkley, 1997a/b): if internally-generated, time-delayed action is the weak point, then a ritual that depends on *remembering to do it on Friday* is leaning on the broken part. Externalizing the trigger (a launchd job, a push notification) moves the load off the deficit.

Direct evidence that external prompts help, specifically in ADHD: a randomized comparison found SMS reminders improved adherence in a self-guided internet intervention for adults with ADHD (Nasri et al., 2022). That's adherence to a treatment program, not "did Friday retro fire," so we mark this **[B]** — the mechanism (external momentary cues beat unaided memory) is tested; our specific application is an inference.

### "Break it down now — by 'later,' the context has decayed" — [B]

Two threads support this:

- **Prospective memory** (remembering to do a thing you intended) is impaired in ADHD, and that impairment statistically mediates part of the link between ADHD symptoms and procrastination (Altgassen et al., 2019). "I'll break it down later" is a prospective-memory bet, and it's a bet ADHD loses more often.
- **Delay aversion / steep delay discounting**: in Sonuga-Barke's dual-pathway model, ADHD involves not just executive dysfunction but a motivational pull away from delay (Sonuga-Barke, 2002, 2003). A future breakdown is a delayed, low-salience reward; the model predicts you'll avoid it.

We mark this **[B]** because neither result *directly* tests "context decay on deferred task breakdown" — they support the surrounding mechanism, and the chunking rule is the practical inference.

### "Time blindness" / the calendar layer must externalize time — [A] for the deficit, [B] for the design move

Timing impairments in ADHD are robust: a meta-analysis of children/adolescents found consistent deficits across time-perception paradigms, with individuals perceiving durations less accurately and tending to misjudge them (Zheng et al., 2022); broader reviews report the same across the lifespan. The deficit is **[A]**.

That this justifies a *plaintext + launchd + ntfy* time layer specifically is a **[B]** design inference — the literature says "externalize time," it does not say "use ntfy." (See [calendar-neutrality](./calendar-neutrality.md), whose vendor-neutrality argument is a *values* claim, not an empirical one, and is flagged as such in that doc.)

### "ADHD + streaks = guilt spiral; don't gamify with streaks" — [C]

**This is the chapter's weakest-grounded claim, and we're flagging it loudly.**

The practical advice — *don't build your system around streak counters* — we still stand behind, because it stands on its own: a streak adds a failure mode (the broken streak) that a plain "did the trigger fire?" check doesn't have, and you lose nothing by not counting streaks. That part is just system design.

But the *stated mechanism* — "breaking a streak triggers a guilt/shame spiral specific to ADHD" — is **not established in peer-reviewed research**:

- The popular framing leans on **Rejection Sensitive Dysphoria (RSD)**, which is **not a DSM-5 diagnosis**, has no validated measure, and as of writing is supported only by a handful of small qualitative studies — it may simply be a relabeling of the broader, better-evidenced *emotional dysregulation* in ADHD rather than a distinct phenomenon (see scoping/lived-experience reviews; Bedrossian, 2024).
- The "streaks fail ADHD users" claim circulates almost entirely in **coaching blogs and product-design posts**, not studies.

What *is* peer-reviewed and adjacent: adults with ADHD report frequent criticism with real negative consequences for self-worth (Beaton et al., 2022), and emotional dysregulation is a well-documented, impairing feature of ADHD across the lifespan. So "shame/criticism land harder and are common" is defensible; "a broken Duolingo streak triggers an ADHD-specific dysphoric spiral" is an extrapolation we can't cite.

**Bottom line:** keep the advice, drop the false confidence. We've reworded the anti-pattern in [ADHD-aware design](./adhd-aware-design.md) to match.

## What we do NOT claim

- That ADHD is *only* an executive-function/working-memory disorder. It's heterogeneous; the dual-pathway and later multi-pathway models exist precisely because no single deficit fits everyone (Sonuga-Barke, 2002, 2003).
- That every person with ADHD has every deficit listed here. These are group-level, probabilistic findings. The design constraint is built to be robust to *whichever* of them bites you — that's the point of designing for affordances rather than diagnosing yourself.
- That this stack is a treatment. It is a way to run a one-person software org. If it incidentally reduces friction for an ADHD brain, good; that's design, not medicine.
- That the vendor-neutrality opinion (calendar layer) has any clinical basis. It doesn't, and [its own doc says so](./calendar-neutrality.md).

## References

Peer-reviewed unless marked otherwise. Links go to a stable record (PubMed / DOI / publisher) where one exists.

- **Alderson, R. M., Kasper, L. J., Hudec, K. L., & Patros, C. H. G. (2013).** Attention-deficit/hyperactivity disorder (ADHD) and working memory in adults: A meta-analytic review. *Neuropsychology, 27*(3), 287–302. [PubMed 23688211](https://pubmed.ncbi.nlm.nih.gov/23688211/)
- **Altgassen, M., Scheres, A., & Edel, M.-A. (2019).** Prospective memory (partially) mediates the link between ADHD symptoms and procrastination. *ADHD Attention Deficit and Hyperactivity Disorders, 11*(1), 59–71. [doi:10.1007/s12402-018-0273-x](https://doi.org/10.1007/s12402-018-0273-x)
- **Barkley, R. A. (1997a).** Behavioral inhibition, sustained attention, and executive functions: Constructing a unifying theory of ADHD. *Psychological Bulletin, 121*(1), 65–94. [doi:10.1037/0033-2909.121.1.65](https://doi.org/10.1037/0033-2909.121.1.65)
- **Barkley, R. A. (1997b).** Attention-deficit/hyperactivity disorder, self-regulation, and time: Toward a more comprehensive theory. *Journal of Developmental and Behavioral Pediatrics, 18*(4), 271–279. [PubMed 9276836](https://pubmed.ncbi.nlm.nih.gov/9276836/) — origin of the "externalize at the point of performance" prescription.
- **Beaton, D. M., Sirois, F., & Milne, E. (2022).** Experiences of criticism in adults with ADHD: A qualitative study. *PLOS ONE, 17*(2), e0263366. [doi:10.1371/journal.pone.0263366](https://doi.org/10.1371/journal.pone.0263366)
- **Kasper, L. J., Alderson, R. M., & Hudec, K. L. (2012).** Moderators of working memory deficits in children with ADHD: A meta-analytic review. *Clinical Psychology Review, 32*(7), 605–617. [PubMed 22917740](https://pubmed.ncbi.nlm.nih.gov/22917740/) — source of the "only ~35–40% show a measurable deficit" caveat.
- **Martinussen, R., Hayden, J., Hogg-Johnson, S., & Tannock, R. (2005).** A meta-analysis of working memory impairments in children with attention-deficit/hyperactivity disorder. *Journal of the American Academy of Child & Adolescent Psychiatry, 44*(4), 377–384. [doi:10.1097/01.chi.0000153228.72591.73](https://doi.org/10.1097/01.chi.0000153228.72591.73)
- **Nasri, B., Kosidou, K., et al. (2022).** The effect of SMS reminders on adherence in a self-guided internet-delivered intervention for adults with ADHD. *Frontiers in Digital Health, 4*, 821031. [doi:10.3389/fdgth.2022.821031](https://doi.org/10.3389/fdgth.2022.821031)
- **Norman, D. A. (1988/2013).** *The Design of Everyday Things.* Basic Books. — source of the "affordance" concept (design theory, not ADHD research).
- **Sonuga-Barke, E. J. S. (2002).** Psychological heterogeneity in AD/HD — a dual pathway model of behaviour and cognition. *Behavioural Brain Research, 130*(1–2), 29–36. [PubMed 11864715](https://pubmed.ncbi.nlm.nih.gov/11864715/)
- **Sonuga-Barke, E. J. S. (2003).** The dual pathway model of AD/HD: An elaboration of neuro-developmental characteristics. *Neuroscience & Biobehavioral Reviews, 27*(7), 593–604. [PubMed 14624804](https://pubmed.ncbi.nlm.nih.gov/14624804/)
- **Zheng, Q., Wang, X., Chiu, K. Y., & Shum, K. K. (2022).** Time perception deficits in children and adolescents with ADHD: A meta-analysis. *Journal of Attention Disorders, 26*(2), 267–281. [doi:10.1177/1087054720978557](https://doi.org/10.1177/1087054720978557)

### Non-peer-reviewed sources (for the [C] claim, included for honesty about provenance)

- **Bedrossian, L. (2024 / community writing on RSD).** Used here only to mark that the *lived experience* of rejection sensitivity is documented qualitatively while the **RSD construct remains unvalidated** (not in DSM-5, no standardized measure). Treat as context, not evidence.
- Coaching and product-design blog posts on "streaks and ADHD" — see [credits.md](../credits.md). These motivate the [C] claim; none are studies.

## Related

- [ADHD-aware design](./adhd-aware-design.md) — the claims graded here
- [calendar-neutrality](./calendar-neutrality.md) — explicitly a values claim, not an empirical one
- [credits.md](../credits.md) — full source list, including the non-peer-reviewed blog/coaching material
