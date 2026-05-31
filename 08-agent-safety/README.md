# 08 — Agent safety

> An agentic coding tool runs with your privileges and ingests untrusted text. Harden the defaults so a poisoned web page can't delete your work or leak your keys, and bound the blast radius when it tries.

This chapter is about the **agent's** behavior and blast radius. It is **not** about your password vault — that's [Chapter 05](../05-secrets-and-secure-defaults/README.md). The one secret-related thing that *is* here: stopping the agent from *exfiltrating* secrets (`secret-guard`, credential proxy). Securing the vault is ch05; constraining the agent's access to it is ch08.

## Threat model in 30 seconds

> Any secret an agent can read is a secret that prompt injection can exfiltrate.

Instructions and data share one channel: a fetched page, an issue body, or a dependency README lands in the same context as your prompt, and the model can't reliably tell content from command. So the question isn't "is the AI trustworthy" — it's "what can my shell do, now driven by something that obeys untrusted text." Full enumeration + the OWASP mappings: [threat-model](./threat-model.md).

## What this chapter covers

| Section | What it solves |
|---|---|
| [threat-model](./threat-model.md) | The 10 failure modes, OWASP LLM-Top-10 + Agentic mappings, the threat×layer matrix, honest prompt-injection state. |
| [agent-hardening](./agent-hardening.md) | The 5-tier scorecard, the three reference hooks, native Claude Code controls, the agent-credential proxy, permission design, cross-tool posture. |
| [session-isolation](./session-isolation.md) | Persistence ≠ security; tmux as workspace; Seatbelt/bubblewrap; container/VM ladder; cloud sessions; worktree-as-soft-sandbox. |

## Recommended reading order

1. **[threat-model](./threat-model.md)** — know what you're defending against and which layer handles it.
2. **[agent-hardening](./agent-hardening.md)** — the 60-second scorecard; get to Tier 3.
3. **[session-isolation](./session-isolation.md)** — Tier 4, when you review untrusted code or run unattended.

## The one-paragraph recommendation

Solo dev, opportunistic adversary: **target Tier 3** — hooks (audit + bash-firewall + secret-guard) + a credential proxy + explicit deny rules. That closes the accident cases and the injection-exfiltrates-a-secret case. Escalate to **Tier 4** isolation (container/VM, or Claude Code on the web) only for untrusted-code review and unattended runs. Don't pay isolation friction for routine work on repos you already trust.

## Alternatives at a glance (same-tier; details in sub-topics)

| Layer | Options (none elevated above another) |
|---|---|
| Hooks/policy | llm-safe-haven · hand-rolled hooks · native `settings.json` allow/deny · AWS Bedrock Guardrails / Azure agent policies (enterprise) |
| Credentials | rbw-proxy · 1Password Agent Hooks · Infisical Agent Vault · env-scrub (`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB`) |
| Isolation | `/sandbox` (Seatbelt/bubblewrap) · `@anthropic-ai/sandbox-runtime` · dev container · Lima / Apple Containerization / Firecracker VM · Claude Code on the web |

## Version matrix (verified May 2026)

| Tool | Version / status | Note |
|---|---|---|
| Claude Code `/sandbox` | GA; macOS Seatbelt, Linux/WSL2 bubblewrap+socat[¹] | Default read still allows `~/.ssh`; `denyRead` it. |
| `@anthropic-ai/sandbox-runtime` | beta research preview[²] | Wraps whole process; denies write+network by default. |
| llm-safe-haven | npm, MIT, active (93+ commits, updated 2026-05)[³] | 5-tier scorecard via `npx llm-safe-haven audit`. |
| rbw-proxy | pre-alpha (design stable, impl landing 2026-04)[⁴] | Sandbox-aware credential proxy; file-based IPC. |
| Apple Containerization | 2026; per-container microVM on macOS | Local VM-grade isolation. |
| OWASP LLM Top 10 | 2025 edition (LLM01–LLM10)[⁵] | Prompt injection #1 for the 2nd edition running. |

## Field tests beyond the author

The defenses here rest on external evidence, not taste. Prompt injection's intractability is the standing position of Simon Willison (the lethal trifecta)[⁶] and OWASP's #1 LLM risk;[⁵] a Jan-2026 study found 42 injection techniques at >85% success against SOTA defenses, and an Apr-2026 MCP taxonomy found no single defense covering >34% of vectors.[³] The native-sandbox boundaries (Seatbelt/bubblewrap, TLS-blind egress, `~/.ssh` readable by default) are documented by Anthropic itself.[¹] `sandbox-exec`'s deprecation-but-still-required status is a live community thread.[⁷] Where a claim is the author's own setup rather than externally validated (the `terminal-craft` patterns), it is flagged inline as such.

## What we'd change in 2026

- **Break the trifecta first, harden second.** The highest-leverage control is denying network egress for sessions that touch untrusted content — it beats any detection classifier.
- **Credential proxies are no longer optional at Tier 3.** Env-var pre-caching is the pattern the 2026 incident wave punished; move secrets out of agent-readable context.
- **Cloud sessions changed the default.** "Reviewing untrusted code?" now has a zero-setup answer (Claude Code on the web's managed VM) — reach for it before hand-building a sandbox.
- **Native > bolt-on where it overlaps.** `/sandbox` and auto-mode now cover ground that used to need custom hooks; keep hooks for what the OS layer can't see (audit trail, secret-writes, supply-chain).

## Related

- [Chapter 03 — Agent rules](../03-claude-code-as-operator/agent-rules.md) — stop conditions, the human-review layer
- [Chapter 05 — Secrets](../05-secrets-and-secure-defaults/README.md) — the human's vault (distinct problem)
- [Chapter 02 — Filesystem conventions](../02-filesystem-conventions/README.md) — worktrees as soft containment
- [sources.md](./sources.md) — full bibliography

---

[1]: https://code.claude.com/docs/en/sandboxing — accessed 2026-05-31
[2]: https://code.claude.com/docs/en/sandbox-environments — accessed 2026-05-31
[3]: https://github.com/pleasedodisturb/llm-safe-haven — accessed 2026-05-31
[4]: https://github.com/pleasedodisturb/rbw-proxy — accessed 2026-05-31
[5]: https://owasp.org/www-project-top-10-for-large-language-model-applications/ — accessed 2026-05-31
[6]: https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/ — accessed 2026-05-31
[7]: https://news.ycombinator.com/item?id=44283454 — accessed 2026-05-31
