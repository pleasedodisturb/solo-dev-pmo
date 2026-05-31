# RESEARCH-LOG — P05 Secrets and secure defaults

Append-only log of sources cited during the P05 enrichment pass. Format per [SEARCH-PLAYBOOK.md](../SEARCH-PLAYBOOK.md) §"Per-phase research log format". Bibliography rolls up in [`05-secrets-and-secure-defaults/sources.md`](../../05-secrets-and-secure-defaults/sources.md).

## 2026-05-31 — STOP-condition pre-checks

- **Source:** https://github.com/doy/rbw/blob/main/CHANGELOG.md
- **Class:** primary
- **Surfaced fact:** rbw 1.15.0 (2025-12-31); feature-complete, maintainer fixes regressions + merges PRs; native SSH-key vault entries since 1.14.0. NOT archived.
- **Used in:** README, bitwarden-via-rbw
- **Counter-evidence:** one-maintainer project — flagged honestly, not a stop trigger.

- **Source:** thehackernews.com/2026/02/study-uncovers-25-password-recovery.html; bleepingcomputer.com clickjacking
- **Class:** practitioner
- **Surfaced fact:** Feb 2026 recovery-attack study (Bitwarden 12 / LastPass 7 / Dashlane 6 / 1Password 2) under coordinated disclosure, no in-the-wild exploitation; Aug 2025 DEF CON 33 clickjacking fixed in Bitwarden 2025.8.0.
- **Used in:** bitwarden-via-rbw, README
- **Counter-evidence:** none active/unresolved → STOP condition NOT triggered; recommendation stands.

## 2026-05-31 — CLI password-manager landscape (Q05.1–4)

- **Source:** Bitwarden CLI help; FiloSottile/passage; LastPass 2022 notice
- **Class:** vendor / primary
- **Surfaced fact:** rbw vs bw vs pass vs op vs keepassxc-cli differentiators; pass can swap GPG for age via passage; LastPass vaults still being brute-forced.
- **Used in:** bitwarden-via-rbw
- **Counter-evidence:** none.

## 2026-05-31 — SSH keys & agents (Q05.5–10)

- **Source:** openssh.com/pq.html; yubico FIDO2 SSH; gatezh Secure Enclave; maxgoedjen/secretive; gitlab signed-commits
- **Class:** primary / vendor / practitioner
- **Surfaced fact:** Ed25519 baseline; ed25519-sk resident/non-resident + `ssh-keygen -K` rehydrate; Secure Enclave keys non-exportable (breaks vault-rehydrate model); OpenSSH 8.7 broke signing, fixed 8.8.
- **Used in:** ssh-agent-via-rbw, git-signing
- **Counter-evidence:** none.

## 2026-05-31 — Pre-commit & scanning (Q05.11–18)

- **Source:** gitleaks/detect-secrets/trufflehog repos + releases; GitHub Secret Scanning docs; newren/git-filter-repo
- **Class:** primary / vendor
- **Surfaced fact:** gitleaks 8.30.1, detect-secrets 1.5.0 current; TruffleHog verifies live keys; GH scanning is server-side post-push; filter-repo is the recommended history-rewrite tool (filter-branch deprecated).
- **Used in:** never-commit-secrets, README
- **Counter-evidence:** none. filter-repo walkthrough WRITTEN, NOT EXECUTED per cloud constraint.

## 2026-05-31 — Git signing, PQ, passkeys (Q05.23–27)

- **Source:** GitHub/GitLab/Forgejo signing docs; openssh.com/pq.html; biometricupdate state-of-passkeys; FIDO Alliance CXF
- **Class:** vendor / practitioner
- **Surfaced fact:** SSH signing first-class on all four forges; NIST FIPS 203/204/205 finalized; OpenSSH 10.0 ships PQ key-exchange but NOT PQ signatures; passkeys replace password+TOTP for humans, not SSH keys/tokens.
- **Used in:** git-signing
- **Counter-evidence:** none — Git did NOT deprecate SSH signing → STOP condition NOT triggered.

## 2026-05-31 — Cloud / CI (Q05.28–29)

- **Source:** GitHub Actions OIDC docs; Claude Code on the web docs; secret-tool/security/cmdkey references
- **Class:** vendor / community
- **Surfaced fact:** OIDC issues per-job expiring tokens (no static secret); OS keyrings as local fallback.
- **Used in:** cloud-session-pattern
- **Counter-evidence:** none.

## 2026-05-31 — Supply chain (Q05.19–22)

- **Source:** Unit42 Shai-Hulud; Ledger incident report; XZ backdoor; Qualys polyfill; Snyk lottie-player; CISA Sept-2025 alert; Huntress axios/qix; npm registry-signatures + trusted-publishers; Sigstore PyPI/cosign blogs
- **Class:** primary / vendor / practitioner
- **Surfaced fact:** full 2023–2026 incident inventory; npm audit signatures (ECDSA since Jul 2022); npm Trusted Publishing GA Jul 2025 w/ auto-provenance; PyPI attestations GA Nov 2024; cosign keyless.
- **Used in:** supply-chain-2026, never-commit-secrets
- **Counter-evidence:** Sigstore did NOT replace the audit-signatures model → STOP condition NOT triggered; both coexist. Provenance adoption still single-digit % of npm deps — flagged as "signal, not gate".
