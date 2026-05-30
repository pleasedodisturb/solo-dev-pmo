# RESEARCH — Phase P05: Secrets and secure defaults

> **Stream goal:** validate the rbw / SSH agent / signing / never-commit recipes against current 2026 threat landscape (npm supply-chain incidents, stolen-token attacks, post-quantum signing), add Linux + Windows variants, and ship working pre-commit + recovery recipes.

## 0. Scope

In:
- `05-secrets-and-secure-defaults/README.md` + 4 sub-topic files (`bitwarden-via-rbw.md`, `git-signing.md`, `never-commit-secrets.md`, `ssh-agent-via-rbw.md`)

Out:
- HSM / hardware-token deep-dive (out of audience scope — solo devs mostly software keys; mention briefly)
- Full corporate threat models (this is a solo-dev playbook)
- Linear/GitHub-specific 2FA recovery (out of band)

## 1. What exists today

819 lines across 5 files. Existing depth:

- **Bitwarden via rbw** — vault-at-rest, CLI access, 24h unlock, alternatives mentioned (`bw`, `pass`, `op`, KeePassXC)
- **SSH agent via rbw** — `rbw-ssh-agent` socket pattern, the Secretive caveat
- **Never commit secrets** — pre-commit hooks, recovery workflow, rotation
- **Git signing** — SSH signing with `key::` prefix, `no GPG`, no 1Password

## 2. Honest gaps

- **rbw is opinionated to one user.** Need clearer "here's why I pick rbw" vs "here's what most readers should pick" (some prefer `op`, some prefer `pass`).
- **No actual `pre-commit` config shipped.** Both `detect-secrets` and `gitleaks` are mentioned in credits but not configured in-chapter.
- **Recovery section asserts "force-push doesn't help"** but no walk-through of `bfg-repo-cleaner` / `git filter-repo` for actual history rewrite (with caveats).
- **Stolen-token / supply-chain context is light.** The CLAUDE.md mentions `axios@1.14.1` compromise and `npm audit signatures` — but the chapter doesn't operationalize this. 2024–2025–2026 had several huge incidents (lottiefiles, ledger-connect-kit, axios maintainer compromise). The chapter should sample these.
- **Sigstore / cosign / npm provenance** ecosystem matured in 2025. Not mentioned.
- **Passkeys** — Bitwarden / 1Password / Apple Keychain support. Worth a callout vs SSH keys for service auth.
- **SSH key types** — Ed25519 is implicit; should be explicit. Plus the case for `ssh-keygen -t ed25519-sk` (hardware-backed) for higher-stakes keys.
- **Post-quantum signing** — early 2026 has live PQ signature schemes (ML-DSA, Falcon). Probably "not yet" for git signing, but worth a sentence.
- **Cloud-session secret handling** — When you're in a cloud Claude Code session that can't run `rbw`, what do you do? (Use an OS-level keyring? Encrypted env file? CI secret store?) Not addressed.
- **Macros and gotchas:** `rbw unlock` succeeds but the agent is stale → token export fails silently. Need a diagnostic snippet.

## 3. Research questions

### CLI password-manager landscape

- **Q05.1** Current 2026 state of `rbw` — version, maintenance status, recent issues. Find recent security audits if any.
- **Q05.2** Compare `rbw` vs `bw` (official) vs `pass` vs `op` (1Password) vs `keepassxc-cli` vs `chezmoi` (secret-management features). Build a comparison table on: vault sync, CLI ergonomics, plugin/integration, audit log, threat model.
- **Q05.3** Has any major password manager had a breach in 2025–2026 that should affect the recommendation? (LastPass 2022 fallout — still relevant. 1Password 2023 incident. Bitwarden response posture.)
- **Q05.4** `pass` (the Unix password manager) — current state, GPG vs age, sync via git.

### SSH agent / key management

- **Q05.5** What's the current 2026 SSH-key best-practice baseline? (Ed25519 default; `-sk` hardware-backed when stakes are high; passphrase always.)
- **Q05.6** `rbw-ssh-agent` — current implementation, known issues, multi-key support.
- **Q05.7** Secretive (the macOS Secure Enclave SSH agent) — current version, audit, why the playbook moved away from it.
- **Q05.8** Alternatives: 1Password SSH agent, Apple Keychain SSH agent (since macOS 12), `gpg-agent` for SSH.
- **Q05.9** `SSH_AUTH_SOCK` stale-socket diagnostic — what's the right detection and fix recipe?
- **Q05.10** Hardware-backed: YubiKey + `ssh-keygen -t ed25519-sk` — full walkthrough for solo dev.

### Pre-commit + secret scanning

- **Q05.11** `detect-secrets` vs `gitleaks` vs `truffleHog` vs `secretlint` — 2026 comparison. Detection rates, false positives, ergonomics.
- **Q05.12** Pre-commit + pre-push hook patterns. Where does each scanner fit?
- **Q05.13** GitHub Secret Scanning (built-in) — when is it sufficient? When does local-side scanning still matter?
- **Q05.14** AWS / GCP / Azure / Anthropic / OpenAI key formats — what does each scanner recognize correctly?

### Recovery from leaked secret

- **Q05.15** `git filter-repo` vs `bfg-repo-cleaner` 2026 status. Which is recommended?
- **Q05.16** Force-push + history rewrite caveats — GitHub indexes old commits; archived forks; pull request mirrors. Document properly.
- **Q05.17** GitGuardian / Snyk / Anthropic / OpenAI revocation APIs — how fast can each revoke?
- **Q05.18** Real case studies of 2025–2026 leaked-secret incidents — what was actually compromised, how long from leak to detection.

### Supply-chain (npm/PyPI/cargo)

- **Q05.19** `npm audit signatures` — when did it land, what does it actually catch?
- **Q05.20** Sigstore + npm provenance + PyPI Trusted Publishers — current adoption, how solo devs benefit.
- **Q05.21** 2024–2026 supply-chain incidents inventory: lottiefiles, ledger-connect-kit, axios, polyfill.io, ueberauth, etc. Document a "after each incident, what should you do?" recipe.
- **Q05.22** Cosign / Notary v2 — for container images. Solo-dev relevance.

### Git signing 2026

- **Q05.23** SSH commit signing — Git 2.34+ established; current 2026 state, any deprecation noise?
- **Q05.24** GitHub / GitLab / Codeberg / Forgejo signing-verification — current support matrix.
- **Q05.25** Post-quantum signature schemes — NIST PQ winners (ML-DSA, Falcon, SLH-DSA). Are any in OpenSSH yet? Worth tracking, not implementing.

### Passkeys

- **Q05.26** Passkey ecosystem maturity — Apple / Google / Microsoft cross-platform sync, sharing with team members, attestation.
- **Q05.27** When does a passkey replace an SSH key, an API token, or a 2FA factor?

### Cloud / CI

- **Q05.28** Cloud Claude Code session — how to expose secrets without `rbw`? Encrypted env file? GH Actions OIDC?
- **Q05.29** OS-level keyring CLIs (`secret-tool` on Linux, `security` on macOS, `cmdkey` on Windows) — fallback when no password manager.

## 4. Per-question source plan

| Q | Source class | Specific starting points |
|---|---|---|
| Q05.1–Q05.4 | Vendor docs + practitioner | github.com/doy/rbw issues / releases. bitwarden.com/help/cli/. github.com/1Password/op cli docs. passwordstore.org. keepassxc.org/docs. |
| Q05.5–Q05.10 | Primary | OpenSSH man page. ssh-audit project. yubico.com developer docs. github.com/maxgoedjen/secretive. github.com/1Password/op-ssh-agent. Apple's macOS man pages for ssh-agent. |
| Q05.11–Q05.14 | Vendor docs + practitioner | github.com/Yelp/detect-secrets. github.com/gitleaks/gitleaks. trufflesecurity.com/trufflehog. github.com/secretlint/secretlint. docs.github.com/code-security/secret-scanning. |
| Q05.15–Q05.18 | Primary + practitioner | git-scm.com/docs/git-filter-repo. github.com/rtyley/bfg-repo-cleaner. docs.github.com on removing-sensitive-data. gitguardian.com blog. anthropic.com/security incident reports if public. |
| Q05.19–Q05.22 | Primary | docs.npmjs.com on audit signatures. sigstore.dev. pypi.org/help/Trusted-Publishers. github.com/sigstore/cosign. |
| Q05.23–Q05.25 | Primary | git-scm.com/docs/git-config (signing). docs.github.com/authentication/managing-commit-signature-verification. NIST PQC standardization announcements. github.com/openssh issue tracker for PQ. |
| Q05.26–Q05.27 | Primary + vendor | fidoalliance.org/passkeys. 1Password / Bitwarden / Apple / Google passkey docs. |
| Q05.28–Q05.29 | Practitioner | docs.github.com on GitHub Actions OIDC. specifications for keyring CLIs (secret-tool, security, cmdkey). |

## 5. Output requirements

The agent updates files in `/Users/pleasedodisturb/Projects/playbooks/solo-dev-pmo/05-secrets-and-secure-defaults/`:

1. **README.md** gains:
   - "Threat model assumed" subsection — explicit (solo dev, no insider threat, software-key baseline, hardware-key for high-stakes)
   - Brief "what this rules out" subsection
2. **`bitwarden-via-rbw.md`** gains:
   - Full comparison table (rbw, bw, pass, op, keepassxc-cli) on 6+ criteria
   - 2025–2026 vendor-incident summary
   - Honest "when to pick op or pass instead" decision tree
   - Stale-vault diagnostic snippet (`rbw unlock` succeeded but agent stale)
3. **`ssh-agent-via-rbw.md`** gains:
   - Current `rbw-ssh-agent` setup walkthrough
   - 1Password SSH agent / Apple Keychain SSH agent / Secretive comparison
   - `SSH_AUTH_SOCK` diagnostic recipe
   - YubiKey-backed key walkthrough for "high-stakes keys" (Anthropic API key signing, prod deploys)
4. **`never-commit-secrets.md`** gains:
   - Working `.pre-commit-config.yaml` shipped inline
   - `detect-secrets` vs `gitleaks` vs `truffleHog` 2026 comparison
   - Full leak-recovery walkthrough using `git filter-repo` (with caveats about GitHub indexing)
   - "After a major supply-chain incident" recipe (with `lottiefiles`, `axios` etc as named cases)
5. **`git-signing.md`** gains:
   - Updated for Git 2.34+ SSH signing — current best practice
   - GitHub / GitLab / Codeberg / Forgejo verification matrix
   - "What about post-quantum" honest "not yet, track NIST" sub-section
   - The `SSH_AUTH_SOCK` stale-socket gotcha (cross-link to ssh-agent file)
6. **New file:** `05-secrets-and-secure-defaults/cloud-session-pattern.md` — how to handle secrets in cloud Claude Code sessions / CI / where `rbw` isn't available
7. **New file:** `05-secrets-and-secure-defaults/supply-chain-2026.md` — npm/PyPI/cargo supply-chain incident hygiene, including Sigstore + provenance + audit signatures
8. **New file:** `05-secrets-and-secure-defaults/sources.md` — bibliography

Constraints:
- DO NOT recommend rolling your own crypto
- DO NOT recommend a paid product as "required" — `op` is OK as an alternative, not a primary
- DO NOT recommend committing encrypted secrets to git (avoid `git-crypt` / `transcrypt` / SOPS — separate topic, contested)
- ALL recovery walkthroughs assume "the secret IS compromised, rotate" — don't suggest "if you force-push fast enough you're OK"

## 6. Per-phase search ideas

### Web

- `site:github.com/doy/rbw issues releases`
- `site:bitwarden.com/help cli`
- `site:passwordstore.org`
- `site:1password.com/security`
- `site:keepassxc.org docs`
- `site:yubico.com ssh ed25519-sk`
- `site:github.com/Yelp/detect-secrets`
- `site:github.com/gitleaks/gitleaks`
- `site:trufflesecurity.com`
- `site:sigstore.dev`
- `npm "audit signatures"`
- `lottiefiles compromise 2024 OR 2025`
- `axios maintainer token stolen`
- `ledger-connect-kit incident`
- `polyfill.io supply chain`
- `site:docs.github.com removing-sensitive-data`
- `git filter-repo vs bfg`
- `Apple Keychain ssh-agent macOS 13 OR 14 OR 15`
- `passkey API token replacement`

### Social

- HN: `https://hn.algolia.com/?q=rbw+bitwarden`
- HN: `https://hn.algolia.com/?q=pass+password+manager`
- HN: `https://hn.algolia.com/?q=ssh+signing+git`
- HN: `https://hn.algolia.com/?q=npm+supply+chain`
- HN: `https://hn.algolia.com/?q=YubiKey+ssh`
- HN: `https://hn.algolia.com/?q=git+filter-repo`
- Lobsters: `https://lobste.rs/search?q=secret+scanning`
- Lobsters: `https://lobste.rs/search?q=ssh+signing`
- Reddit: `site:reddit.com/r/Bitwarden rbw`
- Reddit: `site:reddit.com/r/macsysadmin ssh-agent`
- Reddit: `site:reddit.com/r/git filter-repo bfg`
- Reddit: `site:reddit.com/r/cybersecurity solo developer secrets`
- X: `(supply chain) npm OR pypi (compromise OR token) min_faves:50 since:2024-01-01`
- X: handles `@gitguardian`, `@trufflesec`, `@anchore`, `@snyk_official`

### GitHub

- `topic:secret-scanning`
- `topic:password-manager`
- `topic:supply-chain-security`
- `gitleaks/gitleaks` recent releases
- `trufflesecurity/trufflehog` recent releases
- `secretive/secretive` recent activity
- `1Password/op-ssh-agent` for behavior parity check
- `sigstore/cosign` recent releases
- `astral-sh/uv` for Trusted Publishers integration patterns

### Specific

- doy/rbw issue tracker — known caveats
- maxgoedjen/secretive — alternative SSH agent
- sigstore/cosign — for git signing future
- github.com/anthropics security disclosures if public
- gitguardian.com/state-of-secrets — annual report

## 7. Stop conditions

Stop and surface if:

- A major password manager has an active, unresolved breach during research — pause the chapter, don't recommend.
- `rbw` repo is archived / unmaintained — recommend `bw` or `pass` as primary, demote rbw to "if you don't mind a smaller community."
- Git removes / deprecates SSH signing (unlikely but possible) — recommend GPG fallback explicitly.
- A widely-used pre-commit secret scanner ships a critical false-negative — flag.
- Sigstore replaces `npm audit signatures` model — restructure supply-chain section.

## 8. Estimated effort

M phase. 6–9 hours research + 5–7 hours writing. The pre-commit-config inline + filter-repo recovery walkthrough are the highest-ROI deliverables; budget time to actually test them.
