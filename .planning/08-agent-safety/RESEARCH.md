# RESEARCH — Phase P08: Agent safety (hardening + session sandboxing)

> **Stream goal:** create chapter 08 from scratch. Covers (a) hardening an agentic coding tool against doing bad things, and (b) sandboxing the blast radius via session isolation. **This is greenfield, not enrichment** — no existing chapter content to preserve.

## 0. Scope

In:
- **NEW** `08-agent-safety/README.md` — chapter overview, threat model, 4 sub-topic table
- **NEW** `08-agent-safety/agent-hardening.md` — security hooks, scorecard, the "60-second hardening" pattern
- **NEW** `08-agent-safety/session-isolation.md` — tmux as sandbox, session persistence, blast-radius containment
- **NEW** `08-agent-safety/threat-model.md` — what an agentic coding tool can do wrong + how to detect
- **NEW** `08-agent-safety/sources.md` — bibliography

Out:
- The HUMAN's secrets management (chapter 05 territory; cross-link only)
- Operator-contract rules (chapter 03; cross-link only)
- Specific tool reviews of competing agents (chapter 03 portability section)

## 1. Background — chapter doesn't exist yet

This is greenfield content. **Read these primary sources before drafting:**

### User's repos (canonical references, same-tier as external prior art per author preference)

| Repo | URL | Why it matters here |
|---|---|---|
| `pleasedodisturb/llm-safe-haven` | https://github.com/pleasedodisturb/llm-safe-haven | Published npm tool; hardens any AI coding agent in 60 seconds. 4-tier security scorecard. Ships hooks: `audit-logger.js`, `bash-firewall.js`, `secret-guard.js`. Covers Claude Code / Cursor / Windsurf / Cline / Continue / Aider / Codex CLI. Docs: threat-model, credential-management, supply-chain-defense. |
| `pleasedodisturb/terminal-craft` | https://github.com/pleasedodisturb/terminal-craft | Ghostty + tmux + Claude Code workspace doc + configs + hooks + mkdocs site. The session-isolation patterns (tmux session persistence, visual alerts, hook routing) — sandboxing via process + window discipline rather than VM/container. |

### External prior art (cite alongside, per "same-tier" framing)

- **Claude Code sandbox docs** — `docs.claude.com` on `--sandbox`, permission modes, `claude-code-sandbox` (cloud)
- **Anthropic engineering blog** — posts on Claude Code safety + permission model
- **Cursor / Cline / Aider** sandbox documentation (cross-tool comparison)
- **AWS Bedrock / Vertex AI / Azure OpenAI** agent guardrails — enterprise framings of the same problem
- **OpenAI Realtime sandbox** + GPT Engineer / Devin / sweep.dev safety posture
- **gVisor / nsjail / Firecracker / Bubblewrap** — Linux sandboxing primitives that some setups layer underneath
- **macOS Seatbelt / sandbox-exec** — Apple's native sandbox; what Claude Code's `--sandbox` actually uses
- **NIST AI RMF 1.0** and **OWASP LLM Top 10 (2025)** — formal safety frameworks; cite where they map

## 2. Honest gaps to be aware of

(Pre-emptive — these are issues the brief expects the agent to navigate)

- **Sandboxing is platform-specific.** macOS has Seatbelt; Linux has Bubblewrap/nsjail; Windows has different primitives. Chapter must not assume macOS-only.
- **"Hardening" overlaps with chapter 05 (secrets)**. Differentiate clearly: ch 05 = human's vault/signing; ch 08 = agent's behavior. Specifically, `secret-guard.js` from llm-safe-haven prevents the AGENT from exfiltrating secrets — this is ch 08, not ch 05.
- **`bash-firewall.js` is an opinionated allowlist.** What it allows/blocks needs to be discussed honestly — too tight = friction, too loose = no protection.
- **Cloud sessions (Claude Code cloud, Anthropic-managed) ALREADY sandbox.** The local-hardening discussion needs to acknowledge what cloud gives you for free vs what you still need to configure.
- **Sandbox != isolation != safety.** Tmux gives session persistence, NOT a security boundary (agent can still chmod files, exfiltrate, etc.). Be honest about what each layer actually buys.

## 3. Research questions

### Threat model

- **Q08.1** What can an agentic coding tool do wrong? Enumerate (data exfil, secret leakage, arbitrary file deletion, dependency hijack, command injection from prompt, supply-chain abuse, unintended commits, prompt injection from external content). Cross-check against llm-safe-haven `docs/threat-model.md` + OWASP LLM Top 10 (2025).
- **Q08.2** Which threats are addressed by which layer (sandbox / hooks / permission prompts / human review)? Build a defense-in-depth matrix.
- **Q08.3** Prompt-injection specifically — what does the current 2025–2026 research say? Cite Simon Willison's work + academic papers (arXiv).

### Agent hardening (drawing on llm-safe-haven)

- **Q08.4** llm-safe-haven's 4-tier scorecard: what does each tier actually configure? Document the deltas.
- **Q08.5** `audit-logger.js` — what does it log, how does it interact with Claude Code hooks, how does the user review the audit?
- **Q08.6** `bash-firewall.js` — the default allowlist; what's blocked; how to extend safely; failure modes.
- **Q08.7** `secret-guard.js` — pattern-based or AST-based? False-positive rate? How does it relate to `gitleaks`/`detect-secrets` (chapter 05)?
- **Q08.8** Beyond llm-safe-haven: what additional hardening does Claude Code's native `settings.json` permissions / hooks ecosystem provide in 2026? Don't duplicate llm-safe-haven — complement it.
- **Q08.9** Cross-tool — Cursor / Cline / Aider hardening posture in 2026. Where are gaps llm-safe-haven fills vs where each tool has native answers?

### Session isolation (drawing on terminal-craft)

- **Q08.10** Why tmux over native terminal tabs? terminal-craft's argument; cross-check with HN/Lobsters discussions.
- **Q08.11** Session persistence vs sandbox security — be explicit that tmux gives ONE not the OTHER.
- **Q08.12** macOS Seatbelt / sandbox-exec — what's the practical recipe? Does Claude Code's `--sandbox` use it?
- **Q08.13** Linux: Bubblewrap, nsjail, Firejail comparison. Which fit the solo-dev profile?
- **Q08.14** Container / VM isolation: Docker, Podman, Lima, Apple Containerization (2026). When is the extra friction worth it?
- **Q08.15** Cloud session sandbox model (Claude Code cloud, Anthropic-managed) — what's actually isolated, what isn't, how does it map onto local patterns.
- **Q08.16** Worktree placement (cross-link chapter 02) — does worktree-per-task act as a soft sandbox? Argue or refute.

### Cross-cutting

- **Q08.17** "60-second hardening" — is that pattern reproducible end-to-end on a fresh machine? Document the steps.
- **Q08.18** Auditing the audit — how does a solo dev actually review llm-safe-haven's audit log? Recipes.
- **Q08.19** What level of safety is "good enough" for solo dev? Tier-3 baseline argument; when to go higher.

## 4. Per-question source plan

| Q | Source class | Specific starting points |
|---|---|---|
| Q08.1–Q08.3 | Primary + academic | OWASP LLM Top 10 (2025): owasp.org/www-project-top-10-for-large-language-model-applications. Simon Willison's blog (simonwillison.net) tagged `prompt-injection`. arXiv for prompt-injection research. llm-safe-haven `docs/threat-model.md`. |
| Q08.4–Q08.7 | Primary (user repo) | github.com/pleasedodisturb/llm-safe-haven — `hooks/`, `docs/`, `lib/`, `manifests/`. Verify by reading source. |
| Q08.8 | Primary | docs.claude.com on hooks, settings.json, permissions, sandbox modes. |
| Q08.9 | Primary | cursor.com, cline.bot, aider.chat security/permissions docs. |
| Q08.10–Q08.11 | Primary (user repo) + practitioner | github.com/pleasedodisturb/terminal-craft — README, DECISIONS.md, GUIDE.md. Lobsters/HN on tmux workflows. |
| Q08.12 | Primary | Apple's `sandbox-exec` man page; opensource.apple.com for libsandbox sources; HN posts on macOS Seatbelt reverse-engineering. |
| Q08.13 | Primary | bubblewrap docs (github.com/containers/bubblewrap), nsjail (github.com/google/nsjail), Firejail (firejail.wordpress.com). |
| Q08.14 | Vendor docs | docker, podman, lima (lima-vm.io), Apple Containerization (developer.apple.com/Containerization-2026). |
| Q08.15 | Primary | docs.claude.com on cloud sessions. Anthropic engineering blog. |
| Q08.16 | Primary | git-scm.com worktree docs (cross-link to chapter 02). |
| Q08.17–Q08.19 | Practitioner | Cross-check from llm-safe-haven's published instructions + terminal-craft GUIDE.md. Solo-dev practitioner blogs. |

## 5. Output requirements

The agent creates (NEW files) in `/Users/pleasedodisturb/Projects/playbooks/solo-dev-pmo/08-agent-safety/`:

1. **`README.md`** (≤100 lines) — chapter overview, threat-model-in-30-seconds, sub-topic table, "what this chapter is NOT" (not chapter 05's secrets), recommended-reading order, cross-links to chapters 02/03/05
2. **`agent-hardening.md`** (≤250 lines) — covers Q08.4–Q08.9
   - The 4-tier scorecard pattern; what each tier configures
   - `audit-logger.js` / `bash-firewall.js` / `secret-guard.js` philosophy + cited from llm-safe-haven
   - Native Claude Code hardening (settings.json, permission modes, hooks) — complementary, not duplicative
   - Cross-tool comparison: Cursor / Cline / Aider hardening
   - **Alternatives table** with llm-safe-haven as same-tier prior art alongside hand-rolled hooks, manual settings.json, native sandbox flags, enterprise tools (AWS Bedrock guardrails, Azure agent policies)
3. **`session-isolation.md`** (≤250 lines) — covers Q08.10–Q08.16
   - "Session persistence ≠ security" — opening clarification
   - tmux as workspace (cite terminal-craft; same-tier with screen, byobu, zellij)
   - macOS Seatbelt + Claude Code `--sandbox` integration
   - Linux: Bubblewrap / nsjail / Firejail comparison
   - Container/VM (Docker, Podman, Lima, Apple Containerization) — when worth the friction
   - Cloud session sandboxing (Claude Code cloud) — what's free, what's still needed
   - Worktree-per-task as soft sandbox (cross-link chapter 02)
4. **`threat-model.md`** (≤250 lines) — covers Q08.1–Q08.3
   - Enumerated threats with one-line description each
   - Defense-in-depth matrix (threat × layer)
   - Prompt injection specifically — current 2025–2026 state with citations
   - "What no one defends against well in 2026" (honest)
5. **`sources.md`** — bibliography by source class
6. **`RESEARCH-LOG.md`** in `.planning/08-agent-safety/`

Voice + caps: same as rest of playbook. Don't make it scary; make it actionable. Cite the user's repos in alternatives tables as same-tier prior art alongside external tools — neither elevated nor demoted.

Constraints:
- DO NOT duplicate chapter 05 content (vault, signing, scanning)
- DO NOT recommend an enterprise tool as primary (solo-dev playbook)
- DO acknowledge what cloud sessions handle for you
- DO be honest about "this is sandboxing-shaped but not actually a security boundary" where relevant (tmux esp.)

## 6. Per-phase search ideas

### Web

- `site:owasp.org "LLM Top 10" 2025 OR 2026`
- `site:simonwillison.net prompt injection`
- `site:docs.claude.com sandbox permission settings.json hooks`
- `site:anthropic.com/engineering safety claude code`
- `site:github.com/pleasedodisturb/llm-safe-haven docs`
- `site:github.com/pleasedodisturb/terminal-craft DECISIONS.md`
- `tmux sandbox security boundary`
- `macOS sandbox-exec recipe`
- `bubblewrap nsjail Firejail comparison 2026`
- `lima vs apple containerization 2026`
- `arxiv "prompt injection" 2025 OR 2026`

### Social

- HN: `https://hn.algolia.com/?q=claude+code+sandbox`
- HN: `https://hn.algolia.com/?q=prompt+injection`
- HN: `https://hn.algolia.com/?q=tmux+security`
- HN: `https://hn.algolia.com/?q=bubblewrap`
- Lobsters: `https://lobste.rs/search?q=sandbox+agent`
- Lobsters: `https://lobste.rs/search?q=prompt+injection`
- Reddit: `site:reddit.com/r/ClaudeAI sandbox safety`
- Reddit: `site:reddit.com/r/LocalLLaMA prompt injection`
- X: handles `@simonw`, `@karpathy`, `@AnthropicAI`, `@nicholasthompson`

### GitHub

- `pleasedodisturb/llm-safe-haven` (read hooks/, docs/, manifests/)
- `pleasedodisturb/terminal-craft` (read DECISIONS.md, configs/, hooks/)
- `topic:llm-security`, `topic:prompt-injection`, `topic:ai-safety`
- `containers/bubblewrap`, `google/nsjail`, `netblue30/firejail`
- `lima-vm/lima` (Linux VMs on macOS — relevant for sandboxing recipe)
- `anthropics/claude-code-sandbox` (if public)

## 7. Stop conditions

Stop and surface if:

- llm-safe-haven appears unmaintained / archived (check last commit + npm version) — re-decide whether to feature it as primary example
- Claude Code shipped first-party hardening that obsoletes llm-safe-haven's value proposition — surface honestly, don't suppress
- OWASP LLM Top 10 had a major 2026 revision that contradicts the threat enumeration — defer to OWASP
- A specific recipe (e.g., `sandbox-exec` invocation) is dangerous to publish without warning — add prominent caveat
- Chapter would exceed 4 sub-topic files

## 8. Estimated effort

M phase. 6–9 hrs research (the user's two repos take time to absorb) + 5–7 hrs writing. Single agent fine; the 4 sub-topics are not parallelizable since they cross-reference.
