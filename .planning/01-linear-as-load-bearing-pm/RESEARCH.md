# RESEARCH — Phase P01: Linear as load-bearing PM

> **Stream goal:** the showcase chapter — refresh against current 2026 Linear primary docs, add explicit comparison-to-alternatives so the patterns read as "transferable to Plane/Height/Shortcut" not "Linear-vendor-captured," and field-test against other practitioners.

## 0. Scope

In:
- `01-linear-as-load-bearing-pm/README.md` + all 8 sub-topic files (`cycles-and-rituals.md`, `estimates-exponential.md`, `io-rules.md`, `never-defer.md`, `snooze-as-hibernation.md`, `ticket-standard.md`, `triage-as-inbox.md`, `wip-cap-with-continuous-areas.md`)

Out:
- Mechanical commit/PR rules (chapter 06)
- The agent-rules side of ticket execution (chapter 03)
- Linear's Slack/Asana/Jira import migration paths (not the playbook's audience)

## 1. What exists today

1,388 total lines — the most fleshed-out chapter. Existing depth:

- **Cycles + rituals:** 1-week cycles, cooldown-every-4th, Friday 16:00 reminder, auto-roll
- **Estimates:** exponential scale 1/2/4/8/16, 16-pointer as "stop"
- **I/O rules:** CLI > MCP for local, Initiative→Project→Cycle→Issue hierarchy, Triage bypass for API-created tickets
- **Never-defer:** detailed rule against deferred ticket creation
- **Snooze:** `snoozedUntilAt` semantics, bulk-snooze pattern
- **Ticket standard:** 7-section + execution metadata schema (agent-autonomous-ready)
- **Triage:** Triage-as-inbox pattern
- **WIP cap:** continuous-area exemption to the WIP cap

All grounded in Linear primary docs at extraction time. The author runs this at production scale.

## 2. Honest gaps

- **Date-anchored content needs a 2026 refresh.** Linear shipped features in 2025–2026 (e.g., AI features, customer requests, Linear Slack integration v2) that may or may not affect the patterns. Need a documented "checked against vendor docs on YYYY-MM-DD" stamp.
- **Vendor lock-in concern.** The chapter reads as 100% Linear-specific. The pattern *is* portable but the chapter doesn't demonstrate that. Need explicit Plane / Height / Shortcut / Jira / Linear-self-hosted (none yet) comparison.
- **The 7-section ticket standard isn't reproduced inline** in the playbook — it links to `~/.claude/docs/linear-ticket-standard.md` which doesn't exist in the public repo. Need to inline the schema with an example.
- **"Field tests beyond the author" — empty.** No external practitioner is cited as having tried this pattern. Need at least 2–3 external case-study citations or honest "no external validation yet."
- **Agent-API workflow is mentioned but not detailed.** What does `linearis` actually look like? Is the public version usable, or is it author-only? The chapter should be honest about that.
- **Estimates as "exponential" need defense.** Why not Fibonacci? Why not t-shirt sizes? Multiple PM cultures argue this — the chapter asserts but doesn't defend.
- **The 16-pointer-as-stop-sign needs a citation.** This is a non-obvious claim; readers will ask "where did this come from."

## 3. Research questions

### Linear primary docs refresh

- **Q01.1** Re-read all 10 Linear primary docs cited in `credits.md`. What changed since the chapter was written? File a delta list.
- **Q01.2** Has Linear shipped AI-assisted Triage, AI Project Updates, or AI cycle planning in 2025–2026? If so, how does that interact with the playbook's manual rituals?
- **Q01.3** What's the current state of Linear's API? (Webhooks 2.0? GraphQL schema changes? API-key vs OAuth changes? Agent-friendly endpoints?) Cross-check the I/O rules.
- **Q01.4** Does Linear now support custom workflow states more flexibly? (Affects Triage and the cycle state machine.)
- **Q01.5** What's the current Linear pricing model? Are any patterns blocked on a paid tier? (Important for the audience — solo devs often use free tier.)

### Estimation defense

- **Q01.6** Where does the exponential estimate scale (1/2/4/8/16) come from? Steve McConnell's *Software Estimation*? Cohn's *Agile Estimating and Planning*? Find primary cite.
- **Q01.7** Compare exponential vs Fibonacci vs t-shirt vs hours. What's the case literature for each? Find 2–3 practitioner posts arguing the trade-offs.
- **Q01.8** Empirical: any 2020+ studies on estimation accuracy by scale type? (DORA / SPACE / accelerate literature is candidates.)
- **Q01.9** The "16-pointer as stop sign" — who else publishes this rule? Is it author-original, or is there a Mike Cohn / Allen Holub / Ron Jeffries antecedent?

### Adjacent / competitive PM tools

- **Q01.10** Build a Linear / Plane / Height / Shortcut / Jira / Trello / GitHub Projects comparison table. Specifically, which playbook patterns are blocked or simplified on each.
  - Cycles → which tools have a native sprint/cycle primitive with auto-roll?
  - Triage → which have an inbox state distinct from "Open"?
  - Snooze → which have a native `snoozedUntilAt`?
  - Estimates → which support exponential? Fibonacci? Custom?
  - Project Updates → which have a "weekly status with reminder" primitive?
  - API-friendliness → CLI quality, GraphQL completeness, webhook richness
- **Q01.11** Does any tool match Linear's full feature set for these patterns? (If not, the chapter's "Why Linear specifically?" section gets stronger.)
- **Q01.12** Is Plane (the OSS Linear-alike) a viable substitute? What does it miss?

### Practitioner field tests

- **Q01.13** Find 3+ blog posts, talks, or threads where a solo founder / small team adopted a "load-bearing PM tool" pattern. Quote and credit. ("Linear blog featured customers" is OK if the pattern matches.)
- **Q01.14** Find counter-evidence — solo devs who tried Linear's cycle ritual and abandoned it. What broke?
- **Q01.15** Find the GTD / "trusted system" literature angle (David Allen's "your mind is for having ideas, not holding them") — which is the lifestyle layer of the same point.

### Ticket standard validation

- **Q01.16** The 7-section + execution-metadata standard — does anyone else publish a similar schema for agent-autonomous tickets? Look in Linear blog, GitHub issue templates from agent-heavy repos (Cline, Aider, sweep.dev, sweep-ai), Cursor docs, Devin docs.
- **Q01.17** What's the failure mode when a ticket is *not* agent-autonomous-ready? Document with examples.

### Cycle ritual provenance

- **Q01.18** "Friday 16:00 retro" — is this Linear's recommendation, the author's pattern, or both? Get clean attribution.
- **Q01.19** "Cycle WIP cap = 5, max 2 P0+P1" — derive or cite the numbers. Kanban literature (Anderson, *Kanban*) has WIP-limit math.
- **Q01.20** "Every 4th week = cooldown" — Shape Up (Basecamp) has a 6-week + 2-week cooldown pattern. Compare; cite.

## 4. Per-question source plan

| Q | Source class | Specific starting points |
|---|---|---|
| Q01.1–Q01.5 | Primary | linear.app/docs/* (all 10 URLs in credits.md). linear.app/changelog. linear.app/now blog. Verify HTML against archived versions if there's doubt about timing. |
| Q01.6 | Primary (book) | McConnell, *Software Estimation: Demystifying the Black Art* (2006). Cohn, *Agile Estimating and Planning* (2005). |
| Q01.7 | Practitioner | Allen Holub's anti-estimation posts. Ron Jeffries on #NoEstimates. Henrik Kniberg on t-shirt sizes. martinfowler.com on estimation. |
| Q01.8 | Academic | DORA reports (Google Cloud's annual DORA report). SPACE framework paper (Forsgren et al. 2021). Accelerate book chapters on metrics. |
| Q01.9 | Practitioner | Search HN + Lobsters for "estimate cap" or "story point ceiling." May come back empty; if so, claim the rule as author-original and present field evidence. |
| Q01.10–Q01.12 | Vendor docs | plane.so/docs, height.app, shortcut.com/help, atlassian.com/jira docs, github.com/features/issues. For each: enumerate the playbook patterns and check support. |
| Q01.13–Q01.15 | Practitioner | levelsio's blog/tweets ("the indie hacker workflow"). Tyler Tringas (TinySeed) on solo PM. swyx's blog. Pieter Levels' "12 startups in 12 months." For counter-evidence: search "I stopped using Linear" on HN/Reddit. |
| Q01.16 | Practitioner + vendor | Cline (cline.bot) docs on task structure. Aider docs on conventions files. sweep.dev's issue templates. cursor.so docs. cognition.ai/devin docs. |
| Q01.17 | Practitioner | Failure modes from agent-heavy practitioners' postmortems. |
| Q01.18 | Primary + practitioner | linear.app/now blog post on Project Updates (already in credits). Author's audit log (referenced in extraction-sheet.md). |
| Q01.19 | Primary (book) | Anderson, *Kanban: Successful Evolutionary Change for Your Technology Business* (2010). Klipp, *The Phoenix Project* for context. |
| Q01.20 | Primary | basecamp.com/shapeup book (free online). 6-week cycle + 2-week cooldown rationale. |

## 5. Output requirements (what the downstream agent ships)

The agent updates files in `/Users/pleasedodisturb/Projects/playbooks/solo-dev-pmo/01-linear-as-load-bearing-pm/`:

1. **README.md** gains:
   - A "Linear version we checked against" datestamp + version note at top
   - A "Why Linear specifically? (revisited 2026)" subsection with the comparison table from Q01.10
   - A "Adopting these patterns in other tools" subsection — which tools support which patterns
2. **`ticket-standard.md`** gains:
   - The full 7-section + execution-metadata schema reproduced inline (don't link out to author's private docs)
   - A fully worked example ticket (anonymized)
   - Failure-mode case study (agent picks up an underspecified ticket and what happens)
3. **`estimates-exponential.md`** gains:
   - The McConnell / Cohn / Holub citations
   - A defense of exponential vs Fibonacci vs t-shirt
   - The 16-pointer-as-stop rule with sourced antecedents (or honest "author-original")
4. **`cycles-and-rituals.md`** gains:
   - Cite Shape Up for the cooldown idea
   - Cite Anderson for the WIP-limit math
5. **`io-rules.md`** gains:
   - 2026 Linear API check — anything that changed (webhooks, GraphQL schema)
   - A field on Linear AI features and how the playbook chooses to engage / not engage with them
6. **`triage-as-inbox.md`, `snooze-as-hibernation.md`, `wip-cap-with-continuous-areas.md`, `never-defer.md`** — each gains:
   - At least 1 external practitioner citation OR honest "we couldn't find external validation"
   - A "what this rules out" subsection
7. **New file:** `01-linear-as-load-bearing-pm/alternatives.md` — the Plane/Height/Shortcut/Jira pattern-support matrix from Q01.10
8. **New file:** `01-linear-as-load-bearing-pm/sources.md` — bibliography
9. **`credits.md` (root)** — add new sources if any (don't move existing ones)

Voice: showcase chapter; can be slightly longer-form than other chapters, but still ≤ 250 lines per sub-topic.

Constraints:
- DO NOT remove existing material that's still correct
- DO NOT add Linear vendor sales-copy. We cite docs and engineering blog, not the homepage.
- The 7-section ticket standard is the author's distinct contribution — preserve attribution
- If a Linear feature deprecated, mark the affected pattern with a "[2026-Q1: changed]" note rather than silently rewriting history

## 6. Per-phase search ideas

### Web

- `site:linear.app/docs` (recrawl all)
- `site:linear.app/now` (engineering blog)
- `site:linear.app/changelog 2025` and `2026`
- `site:plane.so docs cycle estimate triage`
- `site:height.app docs`
- `site:shortcut.com help`
- `"load bearing" Linear OR PM OR sprint`
- `"cycle planning" solo founder 2025 OR 2026`
- `"agent autonomous" ticket template`
- `"story point" "16" maximum cap`
- `"shape up" cooldown solo dev`
- `site:basecamp.com/shapeup`
- `site:martinfowler.com estimation`
- `"WIP limit" solo developer Anderson kanban`
- `site:cline.bot OR site:aider.chat OR site:sweep.dev issue template agent`

### Social

- HN: `https://hn.algolia.com/?q=Linear+app+cycles`
- HN: `https://hn.algolia.com/?q=story+points+useless`
- HN: `https://hn.algolia.com/?q=shape+up+basecamp`
- HN: `https://hn.algolia.com/?q=solo+founder+PM`
- Lobsters: `https://lobste.rs/search?q=Linear+app&what=stories`
- Reddit: `site:reddit.com/r/ExperiencedDevs Linear app`
- Reddit: `site:reddit.com/r/Entrepreneur solo PM tool 2026`
- Reddit: `site:reddit.com/r/agile NoEstimates`
- X/Twitter: `(Linear app) (cycle OR triage) min_faves:50 since:2024-01-01`
- X/Twitter: handles `@karrigan`, `@swyx`, `@levelsio`, `@dhh`, `@joelhooks`

### Linear-internal (community)

- Linear Community Slack (invite-only): channels `#general`, `#integrations`, `#api`
- Linear's customer-story page — find solo-/small-team stories: `linear.app/customers`

### GitHub

- `topic:linear-app` repos sorted by stars
- Search code: `path:.linear filename:*.md` (find linear-config patterns)
- Repos using Linear API: `"@linear/sdk" extension:json` (find non-trivial integrations)

### Cycle/agile prior art

- Shape Up book — basecamp.com/shapeup/0.3-chapter-01
- Kanban book references — leanpub Mike Burrows, *Kanban from the Inside*
- DORA report — services.google.com/fh/files/misc/state-of-devops-2024.pdf (and 2025 when out)

## 7. Stop conditions

Stop and surface if:

- Linear shipped something in 2025–2026 that materially changes a load-bearing pattern (e.g., killed snooze, deprecated cycle auto-roll, removed Initiative hierarchy). Don't silently rewrite — flag for human decision.
- A competing tool (Plane especially) demonstrably exceeds Linear on the playbook patterns — surface so the "Why Linear?" framing can be honestly re-litigated.
- The "16-pointer = stop" rule turns out to be widely-published by someone else under a different name. Re-attribute.
- Reproducing the 7-section ticket standard inline would exceed the file's 250-line cap. Surface for the author to decide between split and trim.

## 8. Estimated effort

L phase. 8–14 hours of research + 6–10 hours of writing/editing. This is the showcase chapter; budget accordingly. Consider parallelizing: one sub-agent does Linear primary doc refresh (Q01.1–Q01.5), one does alternatives matrix (Q01.10–Q01.12), one does practitioner / counter-evidence (Q01.13–Q01.15), then merge.
