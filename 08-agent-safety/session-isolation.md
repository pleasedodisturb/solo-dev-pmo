# Session isolation — persistence, sandboxes, and what each actually buys

> Covers Q08.10–Q08.16. The blast-radius layer. Read the first section before anything else here, because the single most common mistake is confusing *session persistence* with *security isolation*.

## Session persistence ≠ security (read this first)

**tmux is not a sandbox.** It gives you state continuity — windows, panes, working dirs, scrollback, running agent processes survive a disconnect — and **zero** isolation. An agent inside a tmux session can `chmod` your files, read `~/.ssh`, and exfiltrate secrets exactly as it could in a bare shell. From the author's `terminal-craft` setup, stated bluntly:[¹]

> Session persistence is NOT a security boundary. It's a workspace-restoration mechanism. tmux gives you state continuity, not isolation.

So this file has two unrelated halves: **persistence** (tmux, the workspace layer) and **isolation** (Seatbelt/bubblewrap/containers/VMs, the security layer). Don't let the word "session" blur them.

## tmux as the workspace layer (Q08.10–Q08.11)

Why tmux over native terminal tabs, from `terminal-craft`'s `DECISIONS.md` (cite as the author's private setup, sanitized):[¹]

- **Persistence across disconnect.** `tmux-resurrect` (manual `<prefix> Ctrl-s`/`Ctrl-r`) + `tmux-continuum` (auto-save every 15 min, auto-restore on server start) survive laptop sleep, WiFi drops, lid close. Native tabs die with the window. What survives: layouts, working dirs, scrollback, running programs. What **doesn't**: the agent's in-memory conversation (use `--resume`), per-pane shell history, SSH connections, env vars.
- **One consistent surface.** Every Ghostty tab auto-attaches to tmux so every tab has the same status bar, flags, and shortcuts — removing "am I in tmux or not?" confusion. The Quick Terminal (`` Cmd+` ``) is the deliberate bare-shell escape hatch.
- **Prefix `Ctrl-Space`** — avoids `Ctrl-b` (Page-Up conflicts) and `Ctrl-a` (shell/Emacs beginning-of-line).
- **Rejected static session managers** (tmuxinator/smug/tmuxp): the workflow is dynamic, windows open as needed. Trigger to revisit: if you keep recreating the same layout, adopt a template.

Same-tier alternatives to tmux: **screen** (older, fewer features), **byobu** (a friendlier tmux/screen front-end), **zellij** (Rust, built-in layouts, friendlier defaults). The persistence-vs-isolation caveat applies identically to all of them — none is a security boundary.

### Hooks → tmux as a notification surface

The integration worth copying: the agent's hooks drive the tmux status bar so you get glanceable, OS-free alerts.[¹] Color per window tab:

| Color | Symbol | Meaning |
|---|---|---|
| Blue | — | Current window |
| Dim gray | — | Idle / agent working |
| Yellow | ● | New output (`monitor-activity`) |
| Red | ⬤ | Agent needs a decision |
| Green | ✓ | Agent finished |

Cross-session jumps (no prefix): `Alt+a` → next red across all sessions; `<prefix> A` → next green; `<prefix> C` → clear. The data flow is **agent-hook → tmux user-option → status-format**, one-way: the `Notification` hook sets a tmux `@alert-*` option (and plays a sound / sends a bell for dock bounce), the `Stop` hook sets the done flag, the `PreToolUse` hook clears both. tmux never needs to know anything about the agent. Rejected native macOS notifications (terminal-notifier et al.) because the status bar is always visible and has less surface area; terminal-notifier stays installed as fallback.

**Backups need a visible restore drill.** A backup that silently fails is worse than none — it stops you making manual copies. `terminal-craft`'s save-guard reads the *actual file mtime* (ground truth, not a metric the saver controls) and renders `✓ saved Nm ago` / `⚠ stale` / `✗ never` in the status bar. It also uses a state-aware skip (cold-start bypass; skip a save only when the window count is *strictly* below the last good save — the post-reboot empty-bootstrap signature — so an empty restart can't clobber yesterday's work).[¹]

### Offload to a persistent machine

For agent tasks that should outlive the laptop: SSH to an always-on box (Mini/NAS/VPS) over Tailscale, authenticate with a Secure Enclave / hardware-backed key (no plaintext key on disk — [Chapter 05](../05-secrets-and-secure-defaults/ssh-agent-via-rbw.md)), then `tmux new -As <session>` (create-or-attach). The agent keeps running across disconnect; reconnect from anywhere.[¹] This is **persistence as mobility** — still not a security boundary; the remote agent can do anything the remote shell allows.

## The OS isolation layer

### macOS: Seatbelt / `sandbox-exec` (Q08.12)

Claude Code's built-in `/sandbox` uses **Seatbelt**, Apple's kernel sandbox, on macOS — nothing to install.[²] The underlying CLI, `sandbox-exec -f profile.sb <cmd>`, uses S-expression profiles (`(version 1) (deny default) (allow file-read* (subpath "…"))`). Apple **deprecated `sandbox-exec`** years ago and prints a warning, but it remains fully functional on current macOS and is what headless tooling relies on.[³] Apple's nominal replacement, App Sandbox, needs code-signing + entitlements + an Xcode project — it's for App-Store GUI apps, not headless agents, and there's an open request for a real headless replacement.[⁴]

**Recipe (publish with care):** prefer `/sandbox` over hand-rolling. If you must hand-roll, `(deny default)` then allow only the project subpath and required reads. **Do not publish a profile that allows `file-read*` on `$HOME`** — that re-exposes `~/.ssh`. Treat any copied profile as untrusted until you read every `allow`.

### Linux: bubblewrap vs nsjail vs Firejail (Q08.13)

| Tool | Model | Fit for solo dev |
|---|---|---|
| **bubblewrap** | Unprivileged, minimal, low-level; you specify every bind mount | **Default pick.** It's also what Claude Code's sandbox uses on Linux/WSL2.[²] |
| **nsjail** | Google; very granular (namespaces, seccomp, rlimits); config-heavy | Good for CI/automation; overkill interactively |
| **Firejail** | **setuid-root**; ships profiles for common apps; easy | Convenient but the setuid model can *expand* blast radius if Firejail itself is flawed.[⁵] |

For an agent on Linux, just use Claude Code's `/sandbox` (needs `bubblewrap` + `socat`; a seccomp filter via `@anthropic-ai/sandbox-runtime` adds Unix-socket blocking).[²] On Ubuntu 24.04+ you may need an AppArmor profile to let `bwrap` create user namespaces.[²]

### Containers and VMs (Q08.14)

Claude Code documents an isolation ladder — match friction to threat:[⁶]

| Approach | Isolates | When worth the friction |
|---|---|---|
| **Sandboxed Bash** (`/sandbox`) | Bash + children only | Everyday prompt-reduction on trusted repos |
| **`@anthropic-ai/sandbox-runtime`** | Whole process (tools, hooks, MCP) — denies all write+network by default | You want full-process isolation without Docker (beta) |
| **Dev container** | Full dev env; ships a default-deny iptables firewall | Unattended / `--dangerously-skip-permissions` runs |
| **Custom container** (Docker/Podman) | Full dev env, your policy | Existing container infra; rootless Podman for least-priv |
| **VM** (Lima, Firecracker, Docker Desktop microVM, Apple Containerization) | Full OS, own kernel | Reviewing **untrusted code**; kernel-level separation |
| **Claude Code on the web** | Anthropic-managed VM | Untrusted code with zero local setup (Q08.15) |

For macOS solo devs, **Lima** (Linux VMs) and **Apple Containerization** (2026; each container in its own lightweight microVM) give VM-grade separation locally. The rule: **`--dangerously-skip-permissions` belongs only inside a container/VM/sandbox-runtime**, never on the bare host, because then the isolation boundary is the *only* thing limiting the agent.[⁶]

### The sandbox ↔ secrets intersection

Sandboxing creates a secrets problem that naive fixes re-open: if you sandbox the agent but pre-cache every secret into env vars, injection still exfiltrates them. The fix is the **credential proxy outside the boundary** — and because Seatbelt blocks Unix sockets, it talks **file-based IPC** (request/response in a tmp dir, 30 s TTL, JSONL audit), per `rbw-proxy` and llm-safe-haven's `credential-management.md`.[⁷][⁸] Detail in [agent-hardening](./agent-hardening.md) §credentials.

## Cloud session sandboxing (Q08.15)

Claude Code on the web runs each session in an **isolated Anthropic-managed VM**.[⁶][⁹] What you get for free: full VM isolation, a network proxy enforcing a **default egress allowlist**, and a separate proxy that **holds your GitHub token outside the sandbox**, issuing only scoped repo credentials inside it. What it does **not** change: your prompts and the files the agent reads are still sent to the model API (isolation isn't confidentiality from the provider), and you still must avoid granting the lethal trifecta within the allowed egress. It maps onto the local ladder as "VM tier, managed." See [Chapter 05 — cloud-session-pattern](../05-secrets-and-secure-defaults/cloud-session-pattern.md) for secret handling when `rbw` isn't present.

## Worktree-per-task as a soft sandbox (Q08.16)

**Refuted as a security boundary; endorsed as blast-radius hygiene.** A `git worktree` runs as the same user with the same filesystem rights — no isolation against an adversary. But it *does* contain *mistakes*: a botched task touches one worktree, not your main checkout, and Claude Code's sandbox special-cases worktrees (allows writes to the shared `.git` so `git commit` works, but **denies** writes to `.git/hooks` and `config`).[²] Use worktree-per-task for the same reason you'd branch-per-task — recoverability — not as a defense. Cross-link: [Chapter 02 — worktrees](../02-filesystem-conventions/README.md).

## Auditing the audit (Q08.18)

The audit log is only worth keeping if you read it. Quick recipes over `~/.claude/audit/YYYY-MM-DD.jsonl`:[⁸]

```bash
# Every Bash command the agent ran today
jq -r 'select(.tool=="Bash") | .input_preview' ~/.claude/audit/$(date +%F).jsonl

# Any tool call touching a sensitive path
grep -E '\.env|id_rsa|\.ssh|credentials' ~/.claude/audit/*.jsonl

# Tool-call counts by type (where is the agent spending its actions?)
jq -r '.tool' ~/.claude/audit/$(date +%F).jsonl | sort | uniq -c | sort -rn
```

Pair with the credential-alert log (`credential-monitor.js` flags credential-tool-piped-to-network) for an exfil tripwire.[⁸]

## Related

- [threat-model](./threat-model.md) — the threat × layer matrix this file's columns come from
- [agent-hardening](./agent-hardening.md) — the hook/permission layer that runs *inside* these boundaries
- [Chapter 02 — Filesystem conventions](../02-filesystem-conventions/README.md) — worktrees
- [Chapter 05 — cloud-session-pattern](../05-secrets-and-secure-defaults/cloud-session-pattern.md)
- [sources.md](./sources.md)

---

[1]: Author's `terminal-craft` setup (private; contains personal configuration) — `DECISIONS.md` / `GUIDE.md` patterns, sanitized — accessed 2026-05-31
[2]: https://code.claude.com/docs/en/sandboxing — accessed 2026-05-31
[3]: https://news.ycombinator.com/item?id=44283454 — sandbox-exec deprecation status discussion — accessed 2026-05-31
[4]: https://github.com/apple/containerization/issues/737 — request for a headless sandbox-exec replacement — accessed 2026-05-31
[5]: https://firejail.wordpress.com/2025/08/20/how-to-sandbox-linux-apps-with-firejail-and-bubblewrap/ ; https://news.ycombinator.com/item?id=36681912 (setuid blast-radius critique) — accessed 2026-05-31
[6]: https://code.claude.com/docs/en/sandbox-environments — accessed 2026-05-31
[7]: https://github.com/pleasedodisturb/rbw-proxy — accessed 2026-05-31
[8]: https://github.com/pleasedodisturb/llm-safe-haven — `docs/credential-management.md`, `hooks/audit-logger.js` — accessed 2026-05-31
[9]: https://code.claude.com/docs/en/claude-code-on-the-web — accessed 2026-05-31
