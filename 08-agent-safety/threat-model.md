# Threat model — what an agentic coding tool can do wrong

> Covers Q08.1–Q08.3. The enumeration of failure modes, the defense-in-depth matrix, and the honest state of prompt injection in 2026.

An agentic coding tool runs with **your** privileges. It can read every file you can read, run every command you can run, and reach every network host you can reach. There is no separate "agent account" with reduced rights unless you build one. So the threat model is not "what can the AI do" — it's "what can your shell do, now driven by a process that ingests untrusted text and acts on it."

The load-bearing thesis, from llm-safe-haven's threat model and echoed in Anthropic's own sandbox docs:[¹][²]

> Any secret an agent can read is a secret that prompt injection can exfiltrate.

The reason is architectural, not a bug: **instructions and data share one channel.** Tool output (a fetched web page, a dependency's README, a git issue body) lands in the same context window as your instructions, and the model cannot reliably tell "content to process" from "command to obey."[³]

**What this chapter removes from working memory:** you stop trying to remember which command is safe. The threat list below is enumerated once, mapped to a layer that handles it, and encoded in hooks/allowlists so the machine remembers instead of you.

## Q08.1 — The enumerated failure modes

| # | Failure mode | One-line description |
|---|---|---|
| 1 | **Prompt injection (indirect)** | Untrusted content the agent reads (web page, issue, dependency file) carries instructions the agent then follows.[³] |
| 2 | **Secret / credential leakage** | Agent reads `.env`, `~/.ssh`, `~/.aws/credentials`, env vars, and emits them to the model or a network call.[¹] |
| 3 | **Data exfiltration** | Agent sends private data outbound — `curl` to attacker host, DNS encoding, a PR comment, an allowlisted domain used as a drop.[¹] |
| 4 | **Arbitrary file destruction** | `rm -rf`, `git reset --hard`, `git clean -fd`, truncating redirects to system paths. |
| 5 | **Unintended commits / pushes** | Agent commits secrets, force-pushes, or pushes to a protected branch without review. |
| 6 | **Command injection** | Crafted content induces a shell command the agent runs (`base64 -d | sh`, `python -c`). |
| 7 | **Dependency / supply-chain abuse** | Agent installs a slopsquatted or compromised package; install scripts run with your rights. ([Chapter 05 — supply-chain](../05-secrets-and-secure-defaults/supply-chain-2026.md)) |
| 8 | **Config / memory poisoning** | Malicious `.claude/settings.json`, `CLAUDE.md`, or MCP config redirects the agent or silently overrides rules.[¹] |
| 9 | **Tool / MCP misuse** | An allowlisted "safe" command is abused (e.g. `ping` for DNS exfil), or a poisoned MCP server shadows a tool.[¹] |
| 10 | **Excessive agency** | Agent does more than asked — touches unrelated repos, escalates scope, acts on a side-quest it invented. |

### Two OWASP frameworks, mapped (don't conflate them)

There are **two** relevant OWASP lists in 2026, and practitioners routinely confuse them:

- **OWASP Top 10 for LLM Applications (2025)** — the LLM01–LLM10 list. App-layer risks for anything built on an LLM.[⁴]
- **OWASP Agentic Security Initiative / Agentic Threats (ASI01–ASI10)** — agent-specific, the framing llm-safe-haven's threat model adopts.[¹]

| Our failure mode | OWASP LLM Top 10 (2025)[⁴] | OWASP Agentic (ASI)[¹] |
|---|---|---|
| Prompt injection (1) | LLM01 Prompt Injection | ASI01 Agent Goal Hijacking |
| Secret leakage (2) | LLM02 Sensitive Information Disclosure | ASI03 Identity & Privilege Abuse |
| Exfiltration (3) | LLM02 / LLM05 Improper Output Handling | ASI02 Tool Misuse |
| Supply chain (7) | LLM03 Supply Chain | ASI04 Supply Chain Compromise |
| Config/memory poisoning (8) | LLM04 Data & Model Poisoning | ASI06 Memory & Context Poisoning |
| Tool/MCP misuse (9) | LLM05 / LLM06 Excessive Agency | ASI07 Insecure Inter-Agent Comms |
| Excessive agency (10) | LLM06 Excessive Agency | ASI10 Rogue Agents |

Use the **LLM Top 10** when you talk to security people (it's the lingua franca); use the **Agentic** list when you reason about *coding-agent-specific* blast radius.

## Q08.2 — Defense-in-depth matrix (threat × layer)

No single layer covers everything. The honest reading: each layer is partial, and the columns to the right are the only ones that hold when the ones to the left fail.

| Threat | OS sandbox[²] | Hooks (firewall/guard)[¹] | Permission prompts[⁵] | Isolation (container/VM)[⁶] | Human review |
|---|:---:|:---:|:---:|:---:|:---:|
| Prompt injection (1) | — | partial | partial | — | ✔ |
| Secret leakage (2) | partial† | ✔ | partial | ✔ | partial |
| Exfiltration (3) | partial‡ | ✔ | ✔ | ✔ | partial |
| File destruction (4) | ✔ | ✔ | ✔ | ✔ | ✔ |
| Bad commits/pushes (5) | partial | ✔ | ✔ | — | ✔ |
| Command injection (6) | partial | ✔ | ✔ | ✔ | partial |
| Supply chain (7) | partial | partial | partial | ✔ | partial |
| Config poisoning (8) | ✔§ | partial | — | ✔ | ✔ |
| Tool/MCP misuse (9) | — | partial | partial | partial | ✔ |
| Excessive agency (10) | — | — | ✔ | — | ✔ |

† Sandbox default read policy **still allows `~/.ssh` and `~/.aws/credentials`** — you must `denyRead` them explicitly.[²]
‡ The sandbox network proxy filters by hostname but **does not inspect TLS**, so a broad allowlist entry (e.g. `github.com`) is a usable exfil path via domain fronting.[²]
§ The sandbox denies writes to its own `settings.json` at every scope, so a sandboxed command can't rewrite its own policy.[²]

The takeaway the matrix encodes: **prompt injection and excessive agency are not solved by sandboxing.** They are bounded by human review and by *not granting the lethal trifecta in the first place* (below).

## Q08.3 — Prompt injection: the honest 2026 state

Prompt injection is **not solved**, and the people closest to it say so plainly. It has held the #1 slot on the OWASP LLM Top 10 for two consecutive editions.[⁴]

**The lethal trifecta** (Simon Willison, 2025-06-16) is the most useful mental model for solo devs.[⁷] An agent is exploitable for data theft when it simultaneously has all three:

1. **Access to private data** (your repo, secrets, env)
2. **Exposure to untrusted content** (web pages, issues, dependency text)
3. **Ability to communicate externally** (network egress, PR comments)

Remove any one leg and the exfiltration path collapses. This is why **network egress restriction is the highest-leverage single control** — it cuts leg 3 even when legs 1 and 2 are unavoidable in a coding agent.

**Why detection-based defenses underperform:** prompt-injection classifiers and guardrails are probabilistic. A January 2026 study catalogued 42 distinct injection techniques achieving **>85% success against state-of-the-art defenses**;[¹] an April 2026 MCP threat taxonomy found **no single defense covers more than 34%** of 23 documented attack vectors.[¹] Willison's standing position: a filter that blocks 99% of attacks is worthless against an adversary who will simply try the 100th.[⁷]

**What actually helps** (defense by *design*, not detection):
- **Break the trifecta** — deny network egress for sessions that touch untrusted content; or strip private data from sessions that need the network.
- **Capability/least-privilege patterns** — credential proxies that never put secrets in agent-readable context ([agent-hardening](./agent-hardening.md) §credentials).
- **Human-in-the-loop on the irreversible** — commits, pushes, deletes, outbound sends gate on approval ([agent-rules](../03-claude-code-as-operator/agent-rules.md)).
- **Dual-LLM / CaMeL-style designs** — a privileged planner that never sees untrusted content, a quarantined executor that does. Promising in research, not yet first-class in shipping coding tools.[⁷]

## What no one defends against well in 2026 (honest)

- **Indirect injection from content you *must* read.** A coding agent that can't read web pages or issues is crippled; one that does inherits leg 2 permanently.
- **TLS-blind egress allowlists.** Hostname-only filtering (the default in Claude Code's sandbox) is bypassable by domain fronting.[²]
- **Poisoned MCP servers at scale.** The ecosystem moves faster than auditing; a February 2026 study found 13.4% of audited agent skills carried critical issues.[¹]
- **Approval fatigue.** The strongest human-review layer erodes when prompts are frequent; this is a UX failure, not a config one ([agent-hardening](./agent-hardening.md) §permission design).

## Related

- [agent-hardening](./agent-hardening.md) — the hooks and permission layers that implement these defenses
- [session-isolation](./session-isolation.md) — the sandbox/container/VM column of the matrix
- [Chapter 05 — Secrets](../05-secrets-and-secure-defaults/README.md) — the human's vault (distinct from the agent's credential access)
- [Chapter 03 — Agent rules](../03-claude-code-as-operator/agent-rules.md) — stop conditions and the human-review layer
- [sources.md](./sources.md)

---

[1]: https://github.com/pleasedodisturb/llm-safe-haven — `docs/threat-model.md` (OWASP Agentic mapping, incident catalogue, research citations) — accessed 2026-05-31
[2]: https://code.claude.com/docs/en/sandboxing — accessed 2026-05-31
[3]: https://owasp.org/www-project-top-10-for-large-language-model-applications/ — LLM01:2025 Prompt Injection (shared instruction/data channel) — accessed 2026-05-31
[4]: https://owasp.org/www-project-top-10-for-large-language-model-applications/assets/PDF/OWASP-Top-10-for-LLMs-v2025.pdf — accessed 2026-05-31
[5]: https://code.claude.com/docs/en/permissions — accessed 2026-05-31
[6]: https://code.claude.com/docs/en/sandbox-environments — accessed 2026-05-31
[7]: https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/ — accessed 2026-05-31 (page blocks automated fetch from this environment; definition is the author's canonical formulation, widely mirrored)
