# PR review standard

> Every PR passes code review + security review before merge. No exceptions. No "small change" exemption. Pre-push hook enforces.

## When to review

- **Before pushing** — review the diff locally before it leaves the machine
- **Before creating any PR**
- **Before subagents push their branches**

You always have the full diff locally. There's no reason to push first and review after.

## Code review checklist

- [ ] **Logic errors** — does the change do what it claims?
- [ ] **Unintended side effects** — could this break existing functionality?
- [ ] **Test coverage** — are new / changed paths tested?
- [ ] **Error handling** — are failure modes handled gracefully?
- [ ] **API contract** — do changes break existing consumers?

## Security review checklist

- [ ] **Injection** — SQL, command, template injection vectors
- [ ] **XSS** — user input rendered in HTML/JS without escaping
- [ ] **Path traversal** — user-controlled file paths
- [ ] **Validation gaps** — fields that lost or weakened validation
- [ ] **Secrets exposure** — API keys, tokens, credentials in code or logs (see [Chapter 05 — Secret scanning](../05-secrets-and-secure-defaults/) for the mechanical scan; this checklist is the human-judgment layer on top)
- [ ] **Dependency safety** — new deps audited, no known vulnerabilities
- [ ] **Auth/authz** — permission checks not bypassed or weakened
- [ ] **CORS / CSP** — no overly permissive origins or policies

## Merge-readiness checklist

The two checklists above are the *content* review. These six items are the *process* gate — the answer to "is this branch allowed to merge?" This is the checklist a reviewer (human or [AI — see below](#ai-assisted-self-review)) runs end to end. **It is the one this very chapter was written against** (Claude Code is the reviewer here):

- [ ] **Correctness** — code review checklist passed (or N/A: docs/license-only)
- [ ] **Security** — security review checklist passed (or N/A: no inputs). Mechanical secret scan green ([Chapter 05](../05-secrets-and-secure-defaults/))
- [ ] **Tests** — new/changed code paths covered; suite green. Docs/license exempt
- [ ] **Conventions** — follows the locked [conventions](./audit-and-conventions-pattern.md); no drift
- [ ] **Ticket-referenced** — every commit subject carries the ticket ID ([commit cadence](./commit-cadence.md))
- [ ] **Signed** — commits signed ([Chapter 05 — Git signing](../05-secrets-and-secure-defaults/git-signing.md)) and carry the `Reviewed-by:` trailer

If every box is checked or explicitly N/A-with-reason, the branch is shippable. "Shippable" for solo dev = mergeable to `main`, because `main` IS prod.

## How to review

### Direct PRs (your own work)

```bash
gh pr diff <number>  # review the diff
# Apply checklists above
# If clean: merge
# If issues found: fix before merge
```

For solo dev: you're both author and reviewer. The discipline is to look at the diff *as a stranger would*. The "I just wrote it, I know what it does" mindset is what misses bugs.

### Self-review: same vs. different from team review

The checklist is identical to a team's. What changes is the social function the review used to perform — and you have to replace it deliberately:

| Function | Team review | Solo self-review replacement |
|---|---|---|
| **Second pair of eyes** | A different brain catches your blind spots | Time-shift (review after a break) or an [AI reviewer](#ai-assisted-self-review) as the second brain |
| **Knowledge transfer** | Reviewer learns the change | The [session log + audit](./audit-and-conventions-pattern.md) carries it to future-you |
| **Gatekeeping** | Reviewer can block merge | The pre-push hook + merge-readiness checklist are the gate |
| **Accountability** | "Approved-by" names someone | You're accountable either way; the `Reviewed-by:` trailer records that the gate ran |

The trap of solo review is collapsing all four into "I looked at it." Will Larson notes most team review is fast-but-low-signal anyway[⁶] — so the bar isn't "reproduce a rigorous team"; it's "don't skip the gate just because no one's watching." The two structural aids that actually move signal: a **time gap** (review the diff cold, not while the intent is still warm in your head) and a **fresh-context reviewer** (a sub-agent or `/code-review` that never saw you write it).

### Subagent PRs

Include review in the agent prompt:

```
1. Review the diff: gh pr diff <number>
2. Check for: [security items + code quality items]
3. Report findings
4. Only merge if review passes
```

The subagent reviews its own work (or a sibling subagent reviews). For high-stakes changes, the main session reviews subagent PRs.

## The `Reviewed-by:` trailer

The trailer isn't a playbook invention — it's the Linux kernel's. The kernel's `Reviewed-by:` carries a formal **Reviewer's Statement of oversight**: by offering the tag you state that you carried out a technical review evaluating the change's readiness, and that any concerns were communicated back and resolved.[⁷] The kernel ladder of strength is worth borrowing wholesale for solo work, because each tag maps to a different gate you might apply:

| Trailer | Kernel meaning[⁷] | Solo-dev use |
|---|---|---|
| `Signed-off-by:` | Developer Certificate of Origin — you have the right to submit | Provenance; pairs with [git signing](../05-secrets-and-secure-defaults/git-signing.md) |
| `Reviewed-by:` | Technical review carried out, concerns resolved | The gate this chapter enforces |
| `Tested-by:` | Successfully tested in some environment | Record that the suite/manual test actually ran |
| `Acked-by:` | Approval without full review | When you wave through a trivial docs change |

Adoption is broader than Linux — the Git project itself, Gerrit, QEMU, and U-Boot all use these trailers[⁷] — so the convention is safe to lean on, not a one-project quirk. Git ships first-class support: `git interpret-trailers` and `git commit --trailer` parse and append them in RFC-822 `Token: value` form.[⁸]

After review passes, add the trailer to each commit being pushed:

```bash
git commit --amend --no-edit --trailer "Reviewed-by: <agent-name> (code+security)"
```

For a multi-commit branch, rebase with `-x` or amend each commit individually.

The trailer is the mechanical proof of review. Without it, the pre-push hook rejects.

## Mechanical enforcement (the pre-push hook)

A global pre-push hook checks every push for the trailer:

```bash
#!/usr/bin/env bash
# ~/.claude/git-hooks/pre-push
# Reject pushes containing commits without Reviewed-by: trailer

while read -r local_ref local_sha remote_ref remote_sha; do
  # Find new commits being pushed
  if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
    range="$local_sha"
  else
    range="$remote_sha..$local_sha"
  fi
  
  # Skip if override env var set
  if [ "${PRE_PUSH_REVIEW_OVERRIDE:-}" = "1" ]; then
    echo "Skipping review check (PRE_PUSH_REVIEW_OVERRIDE=1)"
    continue
  fi
  
  # Check each commit
  for sha in $(git rev-list "$range"); do
    if ! git log -1 --format=%B "$sha" | grep -q "Reviewed-by:"; then
      echo "Commit $sha lacks 'Reviewed-by:' trailer — review before pushing"
      exit 1
    fi
  done
done
```

Wire via `git config --global core.hooksPath ~/.claude/git-hooks`. Applies to every repo unless overridden locally.

## Emergency bypass (the escape hatch)

Discipline that can't be bypassed gets bypassed *silently* — someone uses `--no-verify` at 2am and the gate is now a lie. So the playbook ships a **loud, logged** escape hatch instead of pretending emergencies don't happen:

```bash
PRE_PUSH_REVIEW_OVERRIDE=1 git push <args>
```

Rules for using it:
1. **Name the reason in the commit body** — "BYPASS: prod down, payment webhook 500s, reviewing post-merge."
2. **It's explicit, not `--no-verify`.** `--no-verify` is banned (it silently skips *every* hook, including secret-scanning); the env var skips *only* the review gate and prints that it did.
3. **File a follow-up ticket immediately** to do the review you skipped ([never-defer](../01-linear-as-load-bearing-pm/never-defer.md)). The bypass buys time, it doesn't cancel the debt.
4. **Document it in the next [audit](./audit-and-conventions-pattern.md)** so future-you knows this commit didn't go through the gate.

**Embargoed security patches** are the one case where you *don't* open a public PR at all: commit on a private branch, push to a private remote, and only open the PR after the embargo lifts. The review still happens — just not in the open. The bypass is for the *public PR step*, not the review.

## What constitutes "passed review"

Subjective. Useful heuristics:

- All checklist items are checked or N/A with explicit reason
- No `console.log` / `print(...)` debug statements left in code
- No commented-out blocks of unused code
- No new dependencies without justification
- All new public-facing APIs documented

The bar is "this is shippable to production." For solo dev, "production" = "main branch" because main IS prod.

## Special cases

- **License / docs-only PRs:** code review skipped (no code), security review skipped (no inputs)
- **CI config changes:** review with extra care; CI is the safety net
- **Dependency updates:** check changelog, run `npm audit` / `pip-audit`, verify GitHub tags exist (slopsquatting defense)

## Subagent PR specifics

When a subagent (like `ticket-worker`) opens a PR:
- Subagent should run the review checklist itself
- Subagent reports findings in PR description
- Main session reviews subagent's report before merging
- Main session can spot-check the diff

Trust the subagent's review for routine work. Spot-check for high-stakes.

## Field-tested gotchas

**Pre-push hook + amend.** If you amend after review, the trailer needs re-adding. Add as part of `git commit --amend`.

**Multi-commit branches.** Each commit needs the trailer. `git rebase -x 'git commit --amend --no-edit --trailer "Reviewed-by: ..."'` to apply to all.

**Hook bypass with `--no-verify`.** Bypasses pre-push. Global rule: never use `--no-verify` for review skipping. If you need to skip, use the explicit `PRE_PUSH_REVIEW_OVERRIDE=1`.

**CI signing failures masquerade as "review failed."** Read the hook output carefully. Signing is separate from `Reviewed-by:`.

**Hook fails when there are no new commits.** Edge case; typically harmless. The script should `exit 0` on empty range.

**Subagent that "reviews" without actually reading the diff.** Some agents claim review pass while just running the checklist mentally. Verify by spot-checking subagent reviews against the actual diff for sample tickets.

## Innovative pattern: review-and-trailer in one command

No-AI fallback — wrap "open diff → review → trailer → push" in one function so the trailer can't be forgotten:

```bash
review-and-push() {            # review by eye in the pager, then on pass:
  gh pr diff "$1" | less
  git commit --amend --no-edit --trailer "Reviewed-by: <you> (code+security)"
  git push
}
```

## AI-assisted self-review

The "fresh-context reviewer" the [self-review table](#self-review-same-vs-different-from-team-review) calls for is now a built-in. Claude Code ships two bundled commands that read the pending diff and report findings:

- **`/code-review`** — general correctness/quality pass over the working diff.
- **`/security-review`** — spawns a `security-reviewer` sub-agent tuned to surface **HIGH-CONFIDENCE, newly-introduced** vulnerabilities only, not a general lint. It exists both as the slash command and as the open-source `anthropics/claude-code-security-review` GitHub Action.[⁹]

The leverage: the reviewer sub-agent runs in its **own context** and never watched you write the code, so it doesn't share your blind spots — the closest a solo dev gets to a second pair of eyes on demand.

**What to ask it.** Point it at the diff and the two checklists above. "Review this diff for correctness and security per `pr-review-standard.md`. Report HIGH-confidence issues, then MEDIUM, then a clean-items list." Make it cite line ranges so you can verify.

**What to ignore.** AI review's failure mode is volume — low-confidence nits and style opinions that aren't in your conventions. Triage:
- **Act on:** anything in the security checklist; correctness claims you can reproduce; missing-test-coverage flags.
- **Ignore/defer:** subjective style not in a locked convention; "consider extracting this" refactors mid-hotfix; findings the tool rates low-confidence and you can't reproduce.
- **Never** let the AI *add* the `Reviewed-by:` trailer on its own authority. **You** confirm the report, then the trailer goes on — the trailer means *you* ran the gate, the AI was an input. (This mirrors the [authorship rule](./commit-cadence.md#agent-attribution-co-authored-by): the accountable human owns the line.)

**Dogfood note:** this very chapter was reviewed with exactly this loop — Claude Code as reviewer, this checklist as the rubric — which is the bar the brief set: the checklist has to work when the reviewer is an agent.

## Innovative pattern: review delegation skill

Wrap the loop above in a `/review-pr <number>` skill (a [task skill](./wrap-and-resume.md#the-wrap-skill) with `disable-model-invocation: true`) that fetches the diff, runs each checklist item, reports findings, and — *after you confirm* — adds the `Reviewed-by:` trailer and pushes. You confirm the report; the skill handles the mechanics.

## Related

- [Commit cadence](./commit-cadence.md) — when the trailer is added
- [Chapter 03 — Agent rules](../03-claude-code-as-operator/agent-rules.md) — agent review patterns
- [Chapter 05 — Git signing](../05-secrets-and-secure-defaults/git-signing.md) — separate but related discipline
- [Hook and script examples](./hook-and-script-examples.md) — the pre-push trailer-check hook in full

---

[⁶]: Will Larson, "How to create software quality" — https://lethain.com/quality/ — accessed 2026-05-31. (Team review is often fast but low-signal; structure beats good intentions.)
[⁷]: The Linux Kernel, "Submitting patches: the essential guide" — https://docs.kernel.org/process/submitting-patches.html — accessed 2026-05-31. Reviewer's Statement of oversight and the Signed-off-by/Reviewed-by/Tested-by/Acked-by ladder.
[⁸]: `git interpret-trailers` and `git commit --trailer` — https://git-scm.com/docs/git-interpret-trailers — accessed 2026-05-31.
[⁹]: `anthropics/claude-code-security-review` (the `/security-review` command + GitHub Action) — https://github.com/anthropics/claude-code-security-review ; Claude Code code-review docs — https://code.claude.com/docs/en/code-review — accessed 2026-05-31.
