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
- [ ] **Secrets exposure** — API keys, tokens, credentials in code or logs
- [ ] **Dependency safety** — new deps audited, no known vulnerabilities
- [ ] **Auth/authz** — permission checks not bypassed or weakened
- [ ] **CORS / CSP** — no overly permissive origins or policies

## How to review

### Direct PRs (your own work)

```bash
gh pr diff <number>  # review the diff
# Apply checklists above
# If clean: merge
# If issues found: fix before merge
```

For solo dev: you're both author and reviewer. The discipline is to look at the diff *as a stranger would*. The "I just wrote it, I know what it does" mindset is what misses bugs.

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

## Emergency bypass

When a review can't happen but a push must (broken CI, urgent hotfix), name a reason in the commit body:

```bash
PRE_PUSH_REVIEW_OVERRIDE=1 git push <args>
```

Document the bypass in the next audit so future-you remembers what happened.

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

```bash
# Set as alias / function
review-and-push() {
  gh pr diff "$1" > /tmp/pr-diff
  # Run checklist interactively
  echo "Review the diff. Press Enter when done, q to abort."
  less /tmp/pr-diff
  read -r resp < /dev/tty
  if [ "$resp" != "q" ]; then
    git commit --amend --no-edit --trailer "Reviewed-by: ..."
    git push
  fi
}
```

Lower friction than separate "open diff, review mentally, run trailer command, push."

## Innovative pattern: review delegation

A `/review-pr <number>` skill that:
1. Fetches the diff
2. Runs each checklist item against the diff
3. Reports findings (potential issues + clean items)
4. Adds the `Reviewed-by:` trailer if clean
5. Pushes

You confirm the review report; the skill handles the trailer.

## Related

- [Commit cadence](./commit-cadence.md) — when the trailer is added
- [Chapter 03 — Agent rules](../03-claude-code-as-operator/agent-rules.md) — agent review patterns
- [Chapter 05 — Git signing](../05-secrets-and-secure-defaults/git-signing.md) — separate but related discipline
