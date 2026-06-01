# Agent hardening — hooks, permissions, and the 60-second scorecard

> Covers Q08.4–Q08.9 (+ the cross-cutting "good enough for solo" argument). How to configure an agentic coding tool so the dangerous defaults are closed before you ever point it at untrusted content.

Hardening is **configuration, not vigilance.** You set it up once; the machine enforces it every session. The unit of work is a *hook* (a script the tool runs before/after a tool call) plus a *permission policy* (what auto-approves, what gates, what's denied outright).

**What this removes from working memory:** the "is this command safe?" decision. It's pre-decided in an allowlist and a firewall hook.

## Q08.4 — The tier scorecard

llm-safe-haven ships a five-level scorecard you can run in ~60 seconds (`npx llm-safe-haven audit`). Each tier is a concrete config delta, not a vibe:[¹]

| Tier | Name | What it actually configures |
|---|---|---|
| 0 | Exposed | Nothing. Defaults. Agent can read `.env`/`~/.ssh`, run any command. |
| 1 | Basic | Security hooks installed (the three below). |
| 2 | Guarded | + audit logging + `.env` exposure scanning. |
| 3 | Hardened | + credential proxy + explicit deny rules. |
| 4 | Fortified | + container isolation + network egress restriction. |

**The solo-dev recommendation: target Tier 3.** (Argued at the bottom of this file.) Tier 4 is worth it for untrusted-code review and unattended runs — see [session-isolation](./session-isolation.md).

### Is the "60-second hardening" reproducible on a fresh machine? (Q08.17)

Yes, end-to-end, with one supply-chain caveat. On a clean box with Node and Claude Code installed:[¹]

```bash
npx llm-safe-haven --dry-run   # 1. preview the hooks + settings.json deltas, write nothing
npx llm-safe-haven             # 2. detect agents, install the three hooks, wire settings.json
npx llm-safe-haven audit       # 3. print the tier score (target: Tier 3)
npx llm-safe-haven scan        # 4. find any exposed .env files to clean up
```

It detects the installed agent and writes hooks to `~/.claude/hooks/` + registers them in `settings.json`; `audit --json` gives a CI-checkable score. **The honest caveat:** `npx` runs an npm package's install path, so the "fresh machine" step inherits the supply-chain risk this very chapter warns about — pin the version, run `--dry-run` first, and verify per [Chapter 05 — supply-chain](../05-secrets-and-secure-defaults/supply-chain-2026.md) before trusting it on a machine with live credentials. Tiers 3–4 (credential proxy, container/network) are **not** part of the 60-second run — they need the `rbw-proxy` daemon and an isolation boundary, which are deliberate, not turnkey.

## Q08.5–Q08.7 — The three reference hooks

These are llm-safe-haven's published reference implementation. The chapter discusses the *pattern*; the actual code lives in `hooks/` in the repo.[²]

**`audit-logger.js` (Q08.5)** — a passive `PostToolUse` observer over all tools. Appends one JSON line per tool call to `~/.claude/audit/YYYY-MM-DD.jsonl` (mode `0600`): timestamp, `session_id` (from `CLAUDE_SESSION_ID`), tool name, project dir, sanitized input preview. Inputs for Write/Edit/MultiEdit/Bash are **redacted** (only `file_path` survives; content stripped); other tools truncate to 200 chars. Design principle: *"never blocks — this is a passive observer."*[²] Review it by reading the daily file (recipes in [session-isolation](./session-isolation.md) §audit).

**`bash-firewall.js` (Q08.6)** — a `PreToolUse` **denylist** (no allowlist; it blocks dangerous patterns, lets everything else through). Reads `{tool_input:{command}}` from stdin; blocks with `{"decision":"block","reason":...}`. Default blocks:[²]
- `rm -rf` targeting `/`, `~`, `$HOME`, `/home/`, `/Users/`; `chmod 777` recursive/root; `dd`/`mkfs` to devices; fork bombs
- Force-push (`-f`/`--force`/`--force-with-lease`) to protected branches (`main,master`); `git reset --hard`; `git clean -f`
- Redirects to `/etc/ /usr/ /System/ /Library/`
- Exfil: `curl`/`wget`/`nc` combined with `.env`/`id_rsa`/`id_ed25519`/`.pem`/`.key`/`credentials.json`; `cat <secret> | curl`; `base64 -d | sh`; `python3 -c`/`node -e` referencing secrets
- `curl -k`/`wget --no-check-certificate` writing to `/tmp/` (the May-2026 postinstall-worm signature)

**Failure modes to know:** it's an *opinionated denylist*, so it's leaky by construction — a novel exfil phrasing it doesn't pattern-match passes. Too-tight additions create friction; too-loose gives false confidence. A 3-second stdin timeout **fails closed** (blocks). Extend by pushing a `null`-or-reason function onto `ALL_CHECKS`.[²]

**`secret-guard.js` (Q08.7)** — **regex-based** (not AST), 16 patterns: AWS `AKIA…`, GitHub PAT/OAuth/fine-grained, Slack, OpenAI, Anthropic `sk-ant-…`, Stripe, RSA/EC/OpenSSH private keys, generic `api_key=`/`password=` assignments, credential-bearing connection strings.[²] Allowlists (skips) `.env.example`/`.template`/`.sample`, `README.md`, `*.test.js`/`*.spec.js`, `tests/`, `__tests__/`, `fixtures/`, `mocks/`. Fail-closed on timeout/parse error. **Honest limitation, from its own comments:** real secrets placed in test files are *not* caught. It is a guardrail against the agent *writing* a secret into a tracked file — **not** a replacement for [`gitleaks`/`detect-secrets`](../05-secrets-and-secure-defaults/never-commit-secrets.md) in your pre-commit hook (Chapter 05). Run both: secret-guard at agent-time, gitleaks at commit-time.

## Q08.8 — Native Claude Code hardening (complementary, not duplicative)

Claude Code's first-party controls in 2026 cover ground the hooks don't, and vice-versa. Use both.[³][⁴]

- **`settings.json` permission rules** — `allow` / `deny` / `ask` for every tool (Bash, Read, Edit, WebFetch, MCP). Deny rules are always respected, even under the sandbox.[⁴]
- **Permission modes** — `default`, `acceptEdits`, `plan`, **auto mode** (a classifier reviews each action and blocks escalation/hostile-content-driven actions), and `--dangerously-skip-permissions` (removes review entirely — only safe inside isolation, see [session-isolation](./session-isolation.md)).[³]
- **Built-in Bash sandbox** (`/sandbox`) — OS-level filesystem + network isolation (Seatbelt/bubblewrap). Covered in [session-isolation](./session-isolation.md). **Caveat that intersects with secret-guard:** the sandbox's default read policy *still allows* `~/.ssh` and `~/.aws/credentials` — add them to `denyRead`.[³]
- **`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1`** — strips Anthropic/cloud-provider creds from subprocess env. Note it only covers *those* keys; third-party tokens stay exposed.[³]

**The complement, not duplicate, rule:** native permissions/sandbox handle *what a command can touch*; llm-safe-haven's hooks add *audit trail*, *secret-write prevention*, and *supply-chain-aware* blocks the OS layer doesn't know about. Neither subsumes the other.

## Credentials: the agent angle (distinct from Chapter 05)

Chapter 05 secures the *human's* vault. This is the *agent's* access to it — a different problem. The thesis: env vars and `.env` files put plaintext secrets in reach of any shell command and thus of injection.[⁵]

The **credential-proxy pattern** (llm-safe-haven `docs/credential-management.md`, reference implementation in `rbw-proxy`):[⁵][⁶] a proxy **outside** the sandbox holds the secrets; the agent requests them by IPC, the proxy validates against a per-project manifest, returns a short-lived token (Mode A) or injects the credential at the network layer so the agent never sees plaintext (Mode B). Because Claude Code's Seatbelt sandbox **blocks Unix-domain sockets**, the working IPC is **file-based**: request/response JSON in a tmp dir, 30-second TTL, every access appended to a JSONL audit log.

> Design documented in `pleasedodisturb/rbw-proxy` (pre-alpha as of 2026-04 — daemon + client + manifest loader still landing; the architecture and rationale are stable, the implementation is in progress).[⁶]

This is the sandbox-aware variant of Chapter 05's `rbw` recipe (which assumes unrestricted IPC). Cross-link: [Chapter 05 — bitwarden-via-rbw](../05-secrets-and-secure-defaults/bitwarden-via-rbw.md).

## Permission design that survives daily use

The failure mode of permissions isn't being too loose — it's **approval fatigue** making you turn them off. The author's `terminal-craft` setup encodes a middle path (cite as the author's private setup, sanitized):[⁷]

- **Reject both extremes.** `--dangerously-skip-permissions` (one injected web page → `rm -rf` or exfil) *and* prompt-everything (50+ Enter presses/session → you disable it). Choose a **structured allowlist** (~130 rules) + explicit deny + per-project profiles.
- **WebFetch is an explicit domain allowlist (~40 domains), not "allow all."** Every fetched page enters context; a random search-result domain is the **#1 prompt-injection vector**. Allowlist moderated sources (GitHub, MDN, StackOverflow, npm, vendor docs); gate the rest.
- **`trash` aliased over `rm`.** Real `rm` stays at `/bin/rm`. Catches the one truly-unrecoverable case: a file that exists but isn't yet committed.
- **Three-layer cascade** — `~/.claude/settings.json` (global) → `settings.local.json` (machine) → `<project>/.claude/settings.local.json` (per-project) — with **profiles** (`permissive` / `standard` / `restricted`) applied per project via an init helper. Client/shared repos get `restricted` (global baseline only); personal projects get `permissive`.

## Q08.9 — Cross-tool hardening posture (2026)

Only Claude Code has a rich hook system; the others lean on ignore-files and workspace trust, which is why a tool like llm-safe-haven exists to paper the gap.[¹]

| Tool | Native hardening | Gap llm-safe-haven fills |
|---|---|---|
| **Claude Code** | Hooks, `settings.json` allow/deny/ask, `/sandbox`, env scrub | Audit log, secret-guard, supply-chain blocks |
| **Cursor** | `.cursorignore`, workspace trust | No hook layer; shell-builtin bypass (CVE-2026-22708)[¹] |
| **Windsurf** | `.codeiumignore` | Zero-click MCP config injection history[¹] |
| **Cline / Continue / Aider / Codex CLI** | Agent-specific ignore files | No firewall; Cline's `ping`-as-safe DNS-exfil (Aug 2025)[¹] |

Ignore-files stop a file from being *indexed*; they don't stop a *command* from reading it. That's the structural reason ignore-file-only tools are weaker than hook-capable ones.

## Alternatives (same-tier prior art — none elevated)

| Approach | What you get | Cost / caveat |
|---|---|---|
| **llm-safe-haven hooks** (this chapter) | Turnkey audit + firewall + secret-guard, 60-sec scorecard, multi-tool | Denylist is leaky by design; npm-distributed (verify, pin) |
| **rbw-proxy** | Sandbox-aware credential isolation | Pre-alpha; design stable, impl landing[⁶] |
| **Hand-rolled hooks** | Exactly your policy | You maintain it; easy to leave gaps |
| **Manual `settings.json` allow/deny** | No extra deps; first-party | No audit log, no secret-write guard |
| **Native `/sandbox` + auto mode** | OS-enforced, first-party, maintained | Bash-only; doesn't audit; reads `~/.ssh` by default[³] |
| **AWS Bedrock Guardrails / Azure agent policies** | Managed, policy-driven, enterprise audit | Cloud lock-in, cost, overkill for solo; not a local-shell control |
| **gVisor / nsjail under the agent** | Kernel-level syscall isolation | Heavy; see [session-isolation](./session-isolation.md) |

## The "good enough" argument (Q08.19)

Solo dev with an opportunistic (not targeted) adversary: **Tier 3 is the baseline.** Tiers 1–2 (hooks + audit + env scan) close the accident cases — the agent deleting uncommitted work, writing a key into a file, the obvious exfil one-liner. Tier 3 (credential proxy + deny rules) closes the *injection-exfiltrates-a-secret* case, which is the one that actually costs you money. Go to **Tier 4** (isolation) when you (a) review untrusted code, (b) run unattended / `--dangerously-skip-permissions`, or (c) handle data whose leak is unacceptable. Don't pay Tier-4 friction for routine work on your own trusted repos.

## Related

- [threat-model](./threat-model.md) — which threat each control maps to
- [session-isolation](./session-isolation.md) — Tier 4, the sandbox/container/VM layer
- [Chapter 05 — never-commit-secrets](../05-secrets-and-secure-defaults/never-commit-secrets.md) — gitleaks at commit-time (complements secret-guard)
- [Chapter 03 — Skills and hooks](../03-claude-code-as-operator/skills-and-hooks.md) — how hooks are wired
- [sources.md](./sources.md)

---

[1]: https://github.com/pleasedodisturb/llm-safe-haven — README (tier scorecard, supported-agent matrix) — accessed 2026-05-31
[2]: https://github.com/pleasedodisturb/llm-safe-haven/tree/main/hooks — `audit-logger.js`, `bash-firewall.js`, `secret-guard.js` — accessed 2026-05-31
[3]: https://code.claude.com/docs/en/sandboxing — accessed 2026-05-31
[4]: https://code.claude.com/docs/en/permissions — accessed 2026-05-31
[5]: https://github.com/pleasedodisturb/llm-safe-haven/blob/main/docs/credential-management.md — accessed 2026-05-31
[6]: https://github.com/pleasedodisturb/rbw-proxy — accessed 2026-05-31
[7]: Author's `terminal-craft` setup (private; contains personal configuration) — patterns sanitized for inclusion, accessed 2026-05-31
