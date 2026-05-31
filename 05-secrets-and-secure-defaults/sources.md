# Sources — Chapter 05: Secrets and secure defaults

Bibliography rollup for the P05 research-enrichment pass. All accessed **2026-05-31**. Weighted per [`SEARCH-PLAYBOOK.md`](../.planning/SEARCH-PLAYBOOK.md): primary docs > vendor blog > practitioner > community.

## Password managers (rbw, alternatives, incidents)

| Source | Class | Used in |
|---|---|---|
| [doy/rbw CHANGELOG](https://github.com/doy/rbw/blob/main/CHANGELOG.md) | primary | README, bitwarden-via-rbw |
| [Bitwarden CLI help](https://bitwarden.com/help/cli/) | vendor doc | bitwarden-via-rbw |
| [`passage` (age-backed pass)](https://github.com/FiloSottile/passage) | primary | bitwarden-via-rbw |
| [LastPass 2022 incident notice](https://blog.lastpass.com/posts/notice-of-recent-security-incident) | vendor | bitwarden-via-rbw |
| [DEF CON 33 password-manager clickjacking (BleepingComputer)](https://www.bleepingcomputer.com/news/security/major-password-managers-can-leak-logins-in-clickjacking-attacks/) | practitioner | README, bitwarden-via-rbw |
| [Feb 2026 cloud-vault recovery-attack study (The Hacker News)](https://thehackernews.com/2026/02/study-uncovers-25-password-recovery.html) | practitioner | bitwarden-via-rbw |

## SSH keys & agents

| Source | Class | Used in |
|---|---|---|
| [OpenSSH post-quantum status](https://www.openssh.com/pq.html) | primary | README, git-signing |
| [GitLab SSH signed commits](https://docs.gitlab.com/user/project/repository/signed_commits/ssh/) | vendor doc | ssh-agent-via-rbw, git-signing |
| [macOS Secure Enclave SSH keys (Gatezh)](https://gatezh.com/posts/macos-secure-enclave-ssh-keys/) | practitioner | ssh-agent-via-rbw |
| [maxgoedjen/secretive](https://github.com/maxgoedjen/secretive) | primary | ssh-agent-via-rbw |
| [Yubico — Securing SSH with FIDO2](https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html) | vendor doc | ssh-agent-via-rbw |

## Pre-commit & secret scanning

| Source | Class | Used in |
|---|---|---|
| [gitleaks/gitleaks](https://github.com/gitleaks/gitleaks) + [releases](https://github.com/gitleaks/gitleaks/releases) | primary | README, never-commit-secrets |
| [Yelp/detect-secrets](https://github.com/Yelp/detect-secrets/releases) | primary | README, never-commit-secrets |
| [trufflesecurity/trufflehog](https://github.com/trufflesecurity/trufflehog) | primary | never-commit-secrets |
| [GitHub Secret Scanning docs](https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning) | vendor doc | never-commit-secrets |
| [newren/git-filter-repo](https://github.com/newren/git-filter-repo) | primary | never-commit-secrets |

## Git signing & post-quantum

| Source | Class | Used in |
|---|---|---|
| [GitHub commit signature verification](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification) | vendor doc | git-signing |
| [Forgejo instance signing](https://forgejo.org/docs/latest/admin/advanced/signing/) | vendor doc | git-signing |

## Passkeys

| Source | Class | Used in |
|---|---|---|
| [State of passkeys 2025 (Biometric Update)](https://www.biometricupdate.com/202501/state-of-passkeys-2025-passkeys-move-to-mainstream) | practitioner | git-signing |
| [Apple cross-platform passkey export/import (FIDO Alliance)](https://fidoalliance.org/mobileidworld-apple-introduces-cross-platform-passkey-import-export-features-across-operating-systems/) | vendor | git-signing |

## Cloud / CI secret handling

| Source | Class | Used in |
|---|---|---|
| [GitHub Actions OIDC](https://docs.github.com/en/actions/concepts/security/openid-connect) | vendor doc | cloud-session-pattern |
| [Claude Code on the web docs](https://code.claude.com/docs/en/claude-code-on-the-web) | vendor doc | cloud-session-pattern |
| [Arch Wiki — GNOME Keyring](https://wiki.archlinux.org/title/GNOME/Keyring) | community | cloud-session-pattern |
| [macOS `security` man (ss64)](https://ss64.com/mac/security.html) | practitioner | cloud-session-pattern |

## Supply chain (2024–2026 incidents + provenance)

| Source | Class | Used in |
|---|---|---|
| [Unit 42 — Shai-Hulud npm worm](https://unit42.paloaltonetworks.com/npm-supply-chain-attack/) | practitioner | supply-chain-2026 |
| [Ledger security incident report](https://www.ledger.com/blog/security-incident-report) | vendor | supply-chain-2026 |
| [XZ Utils backdoor (Wikipedia rollup)](https://en.wikipedia.org/wiki/XZ_Utils_backdoor) | community | supply-chain-2026 |
| [Polyfill.io attack (Qualys)](https://blog.qualys.com/vulnerabilities-threat-research/2024/06/28/polyfill-io-supply-chain-attack) | practitioner | supply-chain-2026 |
| [Lottie-player compromise (Snyk)](https://snyk.io/blog/lottie-player-npm-package-compromised-crypto-wallet-theft/) | practitioner | supply-chain-2026 |
| [CISA — Sept 2025 npm compromise alert](https://www.cisa.gov/news-events/alerts/2025/09/23/widespread-supply-chain-compromise-impacting-npm-ecosystem) | primary | supply-chain-2026 |
| [Huntress — axios/qix npm compromise](https://www.huntress.com/blog/axios-npm-compromise) | practitioner | supply-chain-2026 |
| [npm ECDSA registry signatures](https://docs.npmjs.com/about-registry-signatures/) | vendor doc | supply-chain-2026 |
| [npm Trusted Publishers](https://docs.npmjs.com/trusted-publishers/) | vendor doc | supply-chain-2026 |
| [PyPI attestations GA (Sigstore blog)](https://blog.sigstore.dev/pypi-attestations-ga/) | vendor | supply-chain-2026 |
| [cosign verify bundles (Sigstore blog)](https://blog.sigstore.dev/cosign-verify-bundles/) | vendor | supply-chain-2026 |

## Notes on weighting

- Where only practitioner/community coverage existed (incident write-ups, the XZ rollup), it's flagged as such; primary advisories (CISA, vendor incident reports) are preferred where available.
- Password-manager incident sources are deliberately mixed-class so the recommendation rests on the *pattern across* reports, not any single outlet.
