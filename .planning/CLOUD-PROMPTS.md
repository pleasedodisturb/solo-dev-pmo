# CLOUD-PROMPTS — copy-paste handoff for Claude Code cloud

Spawn one cloud Claude Code session per phase. Point each at this repo. Paste the matching block below.

Each prompt is self-contained — it tells the agent everything it needs (HANDOFF.md routing, output contract, commit rules, cloud-specific Linear/secrets adjustments).

## How to use

1. Open Claude Code cloud (claude.ai/code, or the cloud session entry in your client)
2. Point it at this repo: `https://github.com/pleasedodisturb/solo-dev-pmo`
3. For each phase you want worked, open a fresh cloud session and paste the matching block
4. Sessions are independent — all 8 can run in parallel
5. Each session opens its own draft PR; you merge locally

## Cloud-specific adjustments (already baked into each prompt)

- **Linear:** use `mcp__plugin_linear_linear__*` MCP — no `linearis` CLI in cloud
- **Secrets:** no `rbw` access — research-only phases don't need any; if a chapter recipe needs API testing (chapter 05 mostly), the agent should write the recipe but defer testing to a local pass
- **Memory:** Layer 3 (`~/.claude/projects/.../memory/`) is unavailable in cloud — commit any cross-session context to the repo or to MCP Memory Service (Layer 4)
- **No Syncthing, no rbw-ssh-agent:** signing falls back to the cloud session's default (likely none) — the human merges the PR locally with their signing key

---

## P00 — Principles

```
You are picking up phase P00 of the solo-dev-pmo playbook research milestone.

Read in this order:
  1. .planning/HANDOFF.md           ← startup contract (READ FIRST, it tells you everything)
  2. .planning/PROJECT.md           ← project + milestone context
  3. .planning/ROADMAP.md           ← where P00 fits
  4. .planning/SEARCH-PLAYBOOK.md   ← shared search recipes — don't restate per-phase
  5. .planning/00-principles/RESEARCH.md  ← your full assignment
  6. 00-principles/README.md + all sub-topic files in 00-principles/  ← what you're enriching

Then execute the brief end-to-end per its §5 "Output requirements" and §7 "Stop conditions".

Cloud-specific notes:
- Linear: use mcp__plugin_linear_linear__* MCP (no linearis CLI in cloud).
- Secrets: don't try rbw — none needed for this phase.
- Branch: P00/<short-description>. Open a draft PR on first meaningful commit.
- Every commit must end with the Co-Authored-By trailer per .planning/HANDOFF.md.
- NEVER commit to main directly. NEVER force-push.

Effort estimate: S–M (3–6 hrs research + 2–3 hrs writing). Single agent fine.
Biggest risk per the brief's §7: ADHD claims without peer-reviewed citation. Hedge honestly rather than fabricate.

When done: mark the PR ready for review and summarize in the PR body what shipped vs what was hedged.
```

---

## P01 — Linear as load-bearing PM

```
You are picking up phase P01 of the solo-dev-pmo playbook research milestone.

Read in this order:
  1. .planning/HANDOFF.md
  2. .planning/PROJECT.md
  3. .planning/ROADMAP.md
  4. .planning/SEARCH-PLAYBOOK.md
  5. .planning/01-linear-as-load-bearing-pm/RESEARCH.md  ← your full assignment
  6. 01-linear-as-load-bearing-pm/README.md + all 8 sub-topic files  ← what you're enriching

Then execute the brief end-to-end per its §5 "Output requirements" and §7 "Stop conditions".

Cloud-specific notes:
- Linear: use mcp__plugin_linear_linear__* MCP. You'll likely query it for current API behavior — that's expected.
- Branch: P01/<short-description>. This is the SHOWCASE chapter — open a draft PR early and commit per research question (use Q01.N in commit titles, e.g., "P01/Q01.10: alternatives matrix vs Plane/Height/Shortcut").
- Every commit must end with the Co-Authored-By trailer per .planning/HANDOFF.md.
- NEVER commit to main directly. NEVER force-push.

Effort estimate: L (8–14 hrs research + 6–10 hrs writing). If your client supports subagents, the brief's §8 suggests splitting: one on Linear primary-doc refresh (Q01.1–5), one on alternatives matrix (Q01.10–12), one on practitioner/counter-evidence (Q01.13–15).
Biggest risk per the brief's §7: Linear shipped features in 2025–2026 that materially change a load-bearing pattern — surface to the human, don't silently rewrite history.

When done: mark the PR ready for review and summarize in the PR body what shipped vs what was hedged.
```

---

## P02 — Filesystem conventions

```
You are picking up phase P02 of the solo-dev-pmo playbook research milestone.

Read in this order:
  1. .planning/HANDOFF.md
  2. .planning/PROJECT.md
  3. .planning/ROADMAP.md
  4. .planning/SEARCH-PLAYBOOK.md
  5. .planning/02-filesystem-conventions/RESEARCH.md  ← your full assignment
  6. 02-filesystem-conventions/README.md + all sub-topic files  ← what you're enriching

Then execute the brief end-to-end per its §5 "Output requirements" and §7 "Stop conditions".

Cloud-specific notes:
- Linear: use mcp__plugin_linear_linear__* MCP if you need to verify Linear↔GitHub binding behavior.
- Branch: P02/<short-description>. Open a draft PR on first meaningful commit.
- Every commit must end with the Co-Authored-By trailer per .planning/HANDOFF.md.
- NEVER commit to main directly. NEVER force-push.

Effort estimate: M (5–8 hrs research + 4–6 hrs writing).
Biggest risk per the brief's §7: 5-phase migration recipe is too dangerous to publish without disclaimers — add a prominent safety section if you ship it.

When done: mark the PR ready for review and summarize in the PR body what shipped vs what was hedged.
```

---

## P03 — Claude Code as operator

```
You are picking up phase P03 of the solo-dev-pmo playbook research milestone.

Read in this order:
  1. .planning/HANDOFF.md
  2. .planning/PROJECT.md
  3. .planning/ROADMAP.md
  4. .planning/SEARCH-PLAYBOOK.md
  5. .planning/03-claude-code-as-operator/RESEARCH.md  ← your full assignment
  6. 03-claude-code-as-operator/README.md + all 6 sub-topic files  ← what you're enriching

Then execute the brief end-to-end per its §5 "Output requirements" and §7 "Stop conditions".

Cloud-specific notes:
- You ARE a Claude Code cloud session — perfect for ground-truth checks against the chapter's claims about hooks, skills, MCP, subagents. Test the behaviors yourself where reasonable.
- For agent-platform comparison (Q03.21–22), fetch docs from cursor.com, aider.chat, cline.bot, docs.continue.dev.
- Branch: P03/<short-description>. Commit per question (use Q03.N format). Open a draft PR early.
- Every commit must end with the Co-Authored-By trailer per .planning/HANDOFF.md.
- NEVER commit to main directly. NEVER force-push.

Effort estimate: L (10–16 hrs research + 8–12 hrs writing). LARGEST output volume of any phase. If subagents available, split per brief §8: one on Claude Code/Anthropic refresh, one on browser-tools 2026, one on agent-platform comparison.
Biggest risk per the brief's §7: Claude Code shipped a feature that obsoletes a chapter section entirely. Surface, don't silently rewrite.

When done: mark the PR ready for review and summarize in the PR body what shipped vs what was hedged.
```

---

## P04 — Rituals and triggers

```
You are picking up phase P04 of the solo-dev-pmo playbook research milestone.

Read in this order:
  1. .planning/HANDOFF.md
  2. .planning/PROJECT.md
  3. .planning/ROADMAP.md
  4. .planning/SEARCH-PLAYBOOK.md
  5. .planning/04-rituals-and-triggers/RESEARCH.md  ← your full assignment
  6. 04-rituals-and-triggers/README.md + all sub-topic files  ← what you're enriching

Then execute the brief end-to-end per its §5 "Output requirements" and §7 "Stop conditions".

Cloud-specific notes:
- You CANNOT test launchd plists in cloud (no macOS). Write the plists carefully and mark them "untested on actual launchd — verify locally."
- Same for ntfy curl recipes: write them, but flag that the human must test push delivery locally with their topic + device.
- Linear: not needed for this phase.
- Branch: P04/<short-description>. Open a draft PR on first meaningful commit.
- Every commit must end with the Co-Authored-By trailer per .planning/HANDOFF.md.
- NEVER commit to main directly. NEVER force-push.

Effort estimate: M (6–10 hrs research + 5–8 hrs writing).
Biggest risk per the brief's §7: ntfy.sh changes its free-tier model — re-check current pricing before shipping.

When done: mark the PR ready for review. In the PR body, list which scripts/plists need a local verification pass and which were sanity-tested.
```

---

## P05 — Secrets and secure defaults

```
You are picking up phase P05 of the solo-dev-pmo playbook research milestone.

Read in this order:
  1. .planning/HANDOFF.md
  2. .planning/PROJECT.md
  3. .planning/ROADMAP.md
  4. .planning/SEARCH-PLAYBOOK.md
  5. .planning/05-secrets-and-secure-defaults/RESEARCH.md  ← your full assignment
  6. 05-secrets-and-secure-defaults/README.md + all sub-topic files  ← what you're enriching

Then execute the brief end-to-end per its §5 "Output requirements" and §7 "Stop conditions".

Cloud-specific notes:
- This is the HIGHEST-RISK chapter for cloud handoff: you cannot test rbw, ssh-agent, or git signing in a cloud session. Write all recipes with explicit "TESTED LOCALLY ON ____" placeholders that the human fills in.
- For pre-commit / gitleaks / detect-secrets config: you CAN write working YAML; the human runs it locally.
- For the leak-recovery walkthrough using git filter-repo: do NOT execute filter-repo on the real repo. Write the walkthrough only.
- For supply-chain (2024–2026 incident inventory): do real research — these are public incidents with rich coverage.
- Linear: not needed.
- Branch: P05/<short-description>. Open a draft PR early.
- Every commit must end with the Co-Authored-By trailer per .planning/HANDOFF.md.
- NEVER commit to main directly. NEVER force-push. NEVER touch real secrets in any commit.

Effort estimate: M (6–9 hrs research + 5–7 hrs writing).
Biggest risk per the brief's §7: rbw repo unmaintained, or major PW-manager breach during research — pause and surface for the human.

When done: mark the PR ready for review. In the PR body, list every recipe that needs a local verification pass and what command to run.
```

---

## P06 — Session discipline

```
You are picking up phase P06 of the solo-dev-pmo playbook research milestone.

Read in this order:
  1. .planning/HANDOFF.md
  2. .planning/PROJECT.md
  3. .planning/ROADMAP.md
  4. .planning/SEARCH-PLAYBOOK.md
  5. .planning/06-session-discipline/RESEARCH.md  ← your full assignment
  6. 06-session-discipline/README.md + all sub-topic files  ← what you're enriching

Then execute the brief end-to-end per its §5 "Output requirements" and §7 "Stop conditions".

Cloud-specific notes:
- The /wrap + SessionStart hook examples are the chapter's signature deliverable. You CAN write them, but cannot fully verify hook firing in a cloud session. Mark them "verify on local Claude Code install."
- The PR review checklist that the chapter inlines must work for "Claude Code is the reviewer" — i.e., you, in this very session, should be able to follow it. Eat your own dog food while writing.
- Linear: useful for Q06 references to ticket-prefix conventions. Use Linear MCP if needed.
- Branch: P06/<short-description>. Open a draft PR early.
- Every commit must end with the Co-Authored-By trailer per .planning/HANDOFF.md.
- NEVER commit to main directly. NEVER force-push.

Effort estimate: M (5–8 hrs research + 5–7 hrs writing).
Biggest risk per the brief's §7: Claude Code changes the hook contract — re-check docs.claude.com/en/docs/claude-code/hooks before shipping the /wrap example.

When done: mark the PR ready for review. In the PR body, note which hook/script examples are verified-in-cloud vs need a local test.
```

---

## P07 — Cheatsheets and living docs

```
You are picking up phase P07 of the solo-dev-pmo playbook research milestone.

Read in this order:
  1. .planning/HANDOFF.md
  2. .planning/PROJECT.md
  3. .planning/ROADMAP.md
  4. .planning/SEARCH-PLAYBOOK.md
  5. .planning/07-cheatsheets-and-living-docs/RESEARCH.md  ← your full assignment
  6. 07-cheatsheets-and-living-docs/README.md + sub-topic file  ← what you're enriching

Then execute the brief end-to-end per its §5 "Output requirements" and §7 "Stop conditions".

Cloud-specific notes:
- You CAN test the shell `cheat()` function in a cloud bash/zsh — please do, and ship a verified-working version.
- For the cheats-starter directory: write 2-3 sample cheatsheets (~10-20 lines each, recommended shape).
- Linear: not needed.
- Branch: P07/<short-description>. Open a draft PR on first meaningful commit.
- Every commit must end with the Co-Authored-By trailer per .planning/HANDOFF.md.
- NEVER commit to main directly. NEVER force-push.

Effort estimate: S (3–5 hrs research + 3–5 hrs writing + 1–2 hrs testing the starter).
Biggest risk per the brief's §7: tldr-pages adds personal-cheatsheet support that obsoletes the custom-function pattern — re-check current state before shipping.

When done: mark the PR ready for review. In the PR body, confirm the cheats-starter was tested in a fresh shell.
```

---

## P00b — Principles (follow-up: breadth pass)

The first P00 session (PR #3) closed the ADHD-evidence risk but only touched `adhd-aware-design.md`. This follow-up closes the breadth gap on the other 3 axes + adds Alternatives / "What this rules out" subsections.

```
You are picking up the P00 follow-up phase of the solo-dev-pmo playbook research milestone.

Read in this order:
  1. .planning/HANDOFF.md                              ← startup contract (READ FIRST)
  2. .planning/PROJECT.md                              ← project + milestone context
  3. .planning/ROADMAP.md                              ← where P00 fits
  4. .planning/SEARCH-PLAYBOOK.md                      ← shared search recipes
  5. .planning/00-principles/RESEARCH-followup.md      ← YOUR ASSIGNMENT (delta brief)
  6. .planning/00-principles/RESEARCH.md               ← original brief; the followup is a DELTA — read for source plan + voice
  7. 00-principles/README.md + all sub-topic files     ← what you're enriching
  8. 00-principles/evidence-and-citations.md           ← LOCKED — do not modify

Then execute the followup brief end-to-end per its §5 "Output requirements" and §7 "Stop conditions".

Cloud-specific notes:
- Linear: use mcp__plugin_linear_linear__* MCP if needed (probably not for this phase).
- Secrets: don't try rbw — none needed.
- Branch: P00b/<short-description>. Open a draft PR on first meaningful commit.
- Every commit must end with the Co-Authored-By trailer per .planning/HANDOFF.md.
- NEVER commit to main directly. NEVER force-push.
- DO NOT touch evidence-and-citations.md (LOCKED from prior pass).
- DO NOT touch adhd-aware-design.md's existing content — only ADD the Alternatives + What-this-rules-out subsections at the bottom.

Effort estimate: S (2–4 hrs research + 2–3 hrs writing). Single agent fine.

Biggest risks per the followup brief's §7:
1. Claude's first-party auto-memory (now shipped per chapter 03's enrichment) might affect the 4-layer model's recommendation. Surface honestly, don't silently rewrite — the chapter takes a position.
2. If a memory-architecture competitor (mem0/Letta/LangGraph) structurally beats the 4-layer model for solo-dev use, surface for human decision.

When done: mark the PR ready for review and summarize in the PR body what shipped vs what was hedged.
```

---

## After all phases ship

Run locally:

1. `git fetch --all` to pull all 8 branches
2. Local verification pass for P04 (launchd, ntfy), P05 (rbw, signing, pre-commit hooks), P06 (hooks fire), P07 (starter works on your shell)
3. Merge PRs in order: P00 first (foundations), then P01/P02/P03/P05 (parallel), then P04/P06/P07 (parallel)
4. Final pass for voice / terminology drift across chapters (per ROADMAP.md "Phase ordering")
5. Update root README's chapter status table if depth increased materially
6. Optionally: ping adjacent-repo maintainers (gstack, solo-founder-playbook, awesome-adhd) with cross-link offers per ROADMAP.md "Definition of done (milestone)"

## If the cloud session gets stuck

Per HANDOFF.md §"Stop conditions": the agent should surface to the human rather than fabricate. If you see a PR where the agent hedged honestly ("we couldn't find external validation for X"), that's correct behavior — don't push the agent to invent a citation.
