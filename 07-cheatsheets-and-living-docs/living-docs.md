# Living docs — the broader category

> Cheatsheets are one species of *living document*: a doc whose value depends on
> tracking reality, so it has to be cheap to update and loud when it rots. This
> page names the others a solo dev actually keeps.

"Living documentation" as a term comes from Gojko Adzic's *Specification by
Example* (2011), where the docs are a by-product of automated examples that stay
true because the build fails when they drift.[¹] A solo dev rarely has that
test-derived luxury for prose docs — so the discipline has to be manual, which
means it has to be *small*. Every living-doc category below earns its place by
removing something from working memory, and each has an explicit rot signal.

## The five categories a solo dev keeps

| Category | Answers | Lives in | Rot signal |
|---|---|---|---|
| **Cheatsheets** | "How do I run X again?" | `cheats/docs/*.md` (this chapter) | `last-validated` age; command no longer works |
| **Conventions** | "How do *we* do X here?" | repo `CONVENTIONS.md` / `CLAUDE.md` (ch. 02, 06) | a PR violates a rule that isn't written down |
| **Audits** | "What did I do and why?" | append-only log (ch. 06) | gaps in the timeline |
| **Runbooks** | "It's on fire — now what?" | `runbooks/*.md` | a step is wrong *during* an incident |
| **FAQ** | "Didn't I already answer this?" | `FAQ.md` / pinned issue | the same question asked twice |

Cheatsheets, conventions, and audits are covered elsewhere — links below.
Runbooks and FAQs are the two this chapter adds.

## Runbooks for a team of one

A runbook is a cheatsheet for a *situation* instead of a *tool*: the steps to
take when something specific happens. Google SRE calls them "playbooks" and
credits them with roughly a 3× improvement in mean-time-to-repair versus
improvising — because under stress you don't reason, you follow steps.[²] You
have no on-call rotation, but you have the same failure: at 2 a.m., six months
since you last touched the deploy, you do not remember the order.

A solo runbook is deliberately thinner than the SRE template (no escalation
contacts, no severity matrix). Keep it to four parts:

```markdown
# Runbook: production deploy is stuck

<!-- last-validated: 2026-05-31 -->

## Symptom
Health check red > 2 min after `deploy.sh`; users see 502.

## Triage (in order)
1. `flyctl status -a myapp` — is it the new release or the platform?
2. `flyctl logs -a myapp | tail -50` — crash loop vs. stuck boot.

## Fix
- Crash loop: `flyctl deploy --image <last-good-sha>` (rollback).
- Stuck boot: `flyctl machine restart <id>`.

## Escalate / give up
If rollback doesn't take in 10 min, put up the static maintenance page
(`./maintenance.sh on`) and debug without the clock running.
```

The **"Triage in order"** section is the load-bearing part: it's the sequence
present-you worked out calmly, handed to panicking-future-you. The **"give up"**
line matters more solo than on a team — nobody else will tell you to stop
digging and stop the bleeding.

What deserves a runbook: anything that (a) takes you down, (b) happens rarely
enough that you forget the steps, and (c) has a known fix. Deploys, cert
renewals, DB restores, "the cron stopped firing," "I rotated a key and now X is
401." If you've debugged it twice, write the runbook the second time.

## FAQ files

The cheapest living doc: a flat list of questions present-you keeps re-answering
for future-you (or a collaborator). The trigger is literal — *the second time
you answer the same question, it becomes an FAQ entry.* Keep it as Q/A, newest
or most-asked first, one file (`FAQ.md`) until it's big enough to split. It
overlaps cheatsheets; the boundary is "a question with a story" (FAQ) vs. "a
command with a flag" (cheatsheet).

## What makes a doc "living" (vs. just a file)

1. **It has an owner trigger.** A written rule for *when* it gets updated, not
   just hope. (Cheatsheets: same-session capture. Runbooks: after the second
   incident. FAQs: after the second time answering.)
2. **It carries a freshness marker.** A `last-validated:` stamp or commit mtime,
   so staleness is visible, not silent. See
   [cheatsheet-discipline.md](./cheatsheet-discipline.md).
3. **It's cheap to change.** Plain markdown, git-tracked, no publishing
   pipeline. A doc that's expensive to edit won't be edited, and an un-edited
   living doc is a lie with a timestamp.
4. **It fails loud.** Broken links, dead commands, and stale stamps should be
   detectable by a script (`lychee`, the date-stamp hook) rather than discovered
   mid-incident.[³]

The anti-pattern is the doc with none of these: the wiki page nobody owns, no
freshness signal, three clicks to edit. It rots silently and then actively
misleads. Better to delete it than to leave it lying.

## Related

- [Cheatsheet discipline](./cheatsheet-discipline.md) — the freshness/rot mechanics
- [Chapter 02 — Filesystem conventions](../02-filesystem-conventions/README.md) — where conventions live
- [Chapter 06 — Session discipline](../06-session-discipline/README.md) — audits, `/wrap`, commit cadence

---

[1]: Gojko Adzic, *Specification by Example* (Manning, 2011) — origin of "living documentation." https://gojko.net/books/specification-by-example/ — accessed 2026-05-31
[2]: Google, *Site Reliability Engineering*, "Being On-Call" / playbooks. https://sre.google/sre-book/being-on-call/ — accessed 2026-05-31
[3]: lychee — fast async link checker for markdown/CI. https://github.com/lycheeverse/lychee — accessed 2026-05-31
