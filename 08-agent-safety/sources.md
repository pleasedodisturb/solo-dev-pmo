# Sources — Chapter 08: Agent safety

Bibliography for the P08 greenfield pass. All accessed **2026-05-31**. Weighted per [`SEARCH-PLAYBOOK.md`](../.planning/SEARCH-PLAYBOOK.md): primary docs > vendor blog > academic > practitioner > community.

## Practitioner research repos (primary substance)

These are cited as primary sources for substance, positioned as same-tier prior art in alternatives tables — not elevated above external tools.

| Source | Class | Used in |
|---|---|---|
| [pleasedodisturb/llm-safe-haven](https://github.com/pleasedodisturb/llm-safe-haven) — README (5-tier scorecard, agent-support matrix) | primary (practitioner) | README, agent-hardening, threat-model |
| [llm-safe-haven `docs/threat-model.md`](https://github.com/pleasedodisturb/llm-safe-haven/blob/main/docs/threat-model.md) — OWASP Agentic mapping, incident catalogue, academic citations | primary (practitioner) | threat-model |
| [llm-safe-haven `docs/credential-management.md`](https://github.com/pleasedodisturb/llm-safe-haven/blob/main/docs/credential-management.md) — credential-proxy pattern, Mode A/B, manifest | primary (practitioner) | agent-hardening, session-isolation |
| [llm-safe-haven `docs/supply-chain-defense.md`](https://github.com/pleasedodisturb/llm-safe-haven/blob/main/docs/supply-chain-defense.md) — agent-supply-chain pattern | primary (practitioner) | agent-hardening (cross-link ch05) |
| [llm-safe-haven `hooks/`](https://github.com/pleasedodisturb/llm-safe-haven/tree/main/hooks) — `audit-logger.js`, `bash-firewall.js`, `secret-guard.js` reference implementation | primary (practitioner) | agent-hardening, session-isolation |
| [pleasedodisturb/rbw-proxy](https://github.com/pleasedodisturb/rbw-proxy) — sandbox-aware credential proxy (pre-alpha; design stable) | primary (practitioner) | agent-hardening, session-isolation |
| Author's `terminal-craft` setup (private; personal config) — `DECISIONS.md` / `GUIDE.md` patterns, sanitized | practitioner (author, not publicly verifiable) | session-isolation |

## Vendor / primary docs

| Source | Class | Used in |
|---|---|---|
| [Claude Code — Sandboxing (sandboxed Bash tool)](https://code.claude.com/docs/en/sandboxing) | primary | all four files |
| [Claude Code — Sandbox environments (isolation ladder)](https://code.claude.com/docs/en/sandbox-environments) | primary | session-isolation, README |
| [Claude Code — Permissions](https://code.claude.com/docs/en/permissions) | primary | agent-hardening, threat-model |
| [Claude Code on the web](https://code.claude.com/docs/en/claude-code-on-the-web) | primary | session-isolation |
| [`@anthropic-ai/sandbox-runtime`](https://github.com/anthropic-experimental/sandbox-runtime) | primary | session-isolation |
| [containers/bubblewrap](https://github.com/containers/bubblewrap) | primary | session-isolation |
| [apple/containerization #737 — headless sandbox-exec replacement](https://github.com/apple/containerization/issues/737) | primary | session-isolation |

## Safety frameworks

| Source | Class | Used in |
|---|---|---|
| [OWASP Top 10 for LLM Applications (2025)](https://owasp.org/www-project-top-10-for-large-language-model-applications/) + [PDF](https://owasp.org/www-project-top-10-for-large-language-model-applications/assets/PDF/OWASP-Top-10-for-LLMs-v2025.pdf) | primary | threat-model, README |
| OWASP Agentic Security Initiative / Agentic Threats (ASI01–ASI10) — via llm-safe-haven mapping | primary | threat-model |

## Practitioner / community

| Source | Class | Used in |
|---|---|---|
| [Simon Willison — The lethal trifecta (2025-06-16)](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/) | practitioner | threat-model, README |
| [Simon Willison — prompt-injection tag](https://simonwillison.net/tags/prompt-injection/) | practitioner | threat-model |
| [Firejail — sandboxing with Firejail and bubblewrap (2025-08-20)](https://firejail.wordpress.com/2025/08/20/how-to-sandbox-linux-apps-with-firejail-and-bubblewrap/) | practitioner | session-isolation |
| [HN — Firejail setuid blast-radius critique](https://news.ycombinator.com/item?id=36681912) | community | session-isolation |
| [HN — sandbox-exec deprecation status](https://news.ycombinator.com/item?id=44283454) | community | session-isolation |
| [Docker — sandboxes (microVM)](https://docs.docker.com/ai/sandboxes/) | vendor doc | session-isolation |

## Notes on weighting

- The user's repos (llm-safe-haven, rbw-proxy, terminal-craft) are cited as **primary substance** but positioned as **same-tier prior art** in alternatives tables alongside gVisor/nsjail, native `/sandbox`, and enterprise guardrails — neither elevated nor demoted, per the phase brief.
- `terminal-craft` is private; its patterns are flagged inline as the author's setup and are **not publicly verifiable**. Where a reader needs a verifiable equivalent, the public Claude Code hook/sandbox docs are cited alongside.
- The academic figures in threat-model (42 techniques >85%; 13.4% of skills; no defense >34%) are cited *via* llm-safe-haven's threat-model doc, which aggregates the arXiv/ACM/IEEE primaries; the doc is the accessed source.
- Simon Willison's lethal-trifecta page blocks automated fetch from this environment; the definition cited is his canonical, widely-mirrored formulation.
