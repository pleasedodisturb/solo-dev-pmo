# RESEARCH-LOG — P08 Agent safety

Append-only log of sources cited, per SEARCH-PLAYBOOK §"Per-phase research log format".

## 2026-05-31 — llm-safe-haven (primary practitioner repo)

- **Source:** https://github.com/pleasedodisturb/llm-safe-haven (README, `docs/threat-model.md`, `docs/credential-management.md`, `docs/supply-chain-defense.md`, `hooks/{audit-logger,bash-firewall,secret-guard}.js`)
- **Class:** primary (practitioner)
- **Surfaced facts:** 5-tier scorecard (0 Exposed → 4 Fortified); three reference hooks and their exact behavior (audit-logger PostToolUse JSONL `0600` redacting Write/Edit/Bash; bash-firewall denylist + block patterns + 3s fail-closed; secret-guard 16 regex patterns, test-dir allowlist, won't catch secrets in test files); OWASP Agentic (ASI01–ASI10) mapping; credential-proxy pattern (Mode A token / Mode B network injection, manifest, Seatbelt-blocks-Unix-sockets→file-IPC); supply-chain agent-config-as-persistence pattern.
- **Used in:** threat-model.md, agent-hardening.md, session-isolation.md, README.md
- **Counter-evidence / risk check:** repo is **active** (93+ commits, updated 2026-05-29), not archived — the "unmaintained" stop condition does NOT trigger. Native Claude Code sandbox does NOT obsolete it (complementary: OS isolation vs audit/secret-guard/supply-chain). Surfaced honestly in agent-hardening §Q08.8.

## 2026-05-31 — rbw-proxy (primary practitioner repo)

- **Source:** https://github.com/pleasedodisturb/rbw-proxy
- **Class:** primary (practitioner)
- **Surfaced fact:** sandbox-aware credential proxy — file-based IPC (because Seatbelt blocks Unix sockets), per-project secret manifest, 30s-TTL response files, JSONL audit, proxy MUST live outside the sandbox. Pre-alpha (design stable, impl landing 2026-04).
- **Used in:** agent-hardening.md §credentials, session-isolation.md §sandbox-secrets-intersection
- **Counter-evidence:** implementation incomplete — flagged with the exact status caveat the author provided.

## 2026-05-31 — terminal-craft (author's private setup)

- **Source:** Author's `terminal-craft` (`DECISIONS.md`/`GUIDE.md`); repo is **private** — patterns pasted/sanitized by author.
- **Class:** practitioner (author, not publicly verifiable)
- **Surfaced facts:** persistence≠security thesis; tmux-over-tabs rationale (Ctrl-Space prefix, no static session manager, every-tab-auto-attaches, Quick Terminal escape hatch); hooks→tmux-user-option→status-format alert routing (color/symbol table, cross-session jumps); state-aware save-guard + visible-restore-drill principle; offload-to-persistent-machine (SSH+Tailscale+Secure Enclave, `tmux new -As`); 3-layer permission cascade + permissive/standard/restricted profiles; WebFetch domain allowlist as #1 injection control; `trash`-over-`rm`.
- **Used in:** session-isolation.md (primary), agent-hardening.md §permission-design
- **Counter-evidence / handling:** STOP CONDITION HIT — repo private, GitHub MCP scoped to solo-dev-pmo only, raw fetch 404. Surfaced to human via AskUserQuestion; human chose "paste the content". Cited as author's setup, flagged not-publicly-verifiable; public Claude Code docs cited alongside where a verifiable equivalent exists.

## 2026-05-31 — Claude Code native sandbox docs (primary vendor)

- **Source:** https://code.claude.com/docs/en/sandboxing ; https://code.claude.com/docs/en/sandbox-environments ; https://code.claude.com/docs/en/claude-code-on-the-web
- **Class:** primary (vendor)
- **Surfaced facts:** `/sandbox` uses Seatbelt (macOS) / bubblewrap+socat (Linux/WSL2); seccomp via @anthropic-ai/sandbox-runtime; default read STILL allows `~/.ssh` + `~/.aws/credentials`; network proxy is TLS-blind (domain-fronting exfil risk); settings.json write-protected under sandbox; `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` covers only Anthropic/cloud keys; isolation ladder (Bash sandbox → sandbox-runtime → dev container w/ default-deny iptables → custom container → VM/Firecracker → web); `--dangerously-skip-permissions` only safe inside isolation; cloud session = Anthropic-managed VM, egress allowlist, GitHub token held outside sandbox issuing scoped creds; worktree special-casing (allows shared `.git`, denies hooks/config).
- **Used in:** all four files
- **Counter-evidence:** none — this is the authoritative source; used to set honest boundaries on what each layer buys.

## 2026-05-31 — OWASP + prompt-injection state of the art

- **Source:** OWASP LLM Top 10 (2025) https://owasp.org/www-project-top-10-for-large-language-model-applications/ (+PDF); Simon Willison lethal trifecta https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/
- **Class:** primary (framework) + practitioner
- **Surfaced facts:** LLM01–LLM10 2025 list (prompt injection #1, 2nd edition running); lethal trifecta = private data + untrusted content + external comms; detection/guardrails underperform; design-pattern defenses (dual-LLM/CaMeL) promising but not first-class.
- **Used in:** threat-model.md, README.md
- **Counter-evidence:** Willison page blocks automated fetch from this env (403); cited canonical formulation, flagged in footnote. OWASP 2025 list confirmed current — no 2026 revision contradicting the enumeration (stop condition does NOT trigger).

## 2026-05-31 — Linux/macOS sandbox primitives

- **Source:** github.com/containers/bubblewrap; firejail.wordpress.com (2025-08-20); HN 36681912 (Firejail setuid critique); HN 44283454 (sandbox-exec deprecation); apple/containerization#737; docs.docker.com/ai/sandboxes
- **Class:** primary + community
- **Surfaced facts:** bubblewrap unprivileged/minimal (and what CC uses); Firejail setuid-root can expand blast radius; nsjail granular/CI-oriented; sandbox-exec deprecated-but-functional, App Sandbox needs entitlements (not headless); Lima/Apple Containerization/Firecracker for VM-grade local isolation.
- **Used in:** session-isolation.md
- **Counter-evidence:** sandbox-exec deprecation flagged as a publish caveat (don't allow `file-read*` on `$HOME`).

## Stop-condition outcomes

- **llm-safe-haven unmaintained?** NO — active, surfaced in chapter.
- **Claude Code first-party hardening obsoletes it?** NO — complementary; documented honestly in agent-hardening §Q08.8.
- **OWASP 2026 revision contradicting enumeration?** NO — 2025 list current.
- **terminal-craft inaccessible (private)?** YES — surfaced to human; resolved by author paste; cited as author's setup with honest hedge.
- **Dangerous recipe (sandbox-exec)?** Caveat added (no `$HOME` read-allow; prefer `/sandbox`).
- **>4 sub-topic files?** NO — exactly 3 sub-topics + README + sources, within cap.
