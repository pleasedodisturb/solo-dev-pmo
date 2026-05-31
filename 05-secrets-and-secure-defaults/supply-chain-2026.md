# Supply chain 2026

> A solo dev installs hundreds of transitive dependencies. One compromised maintainer token runs code in your dev/CI environment. The 2024–2026 incidents below show the pattern, and the defenses (provenance, `audit signatures`, OIDC publishing) that finally exist to counter it.

## Why this is in a secrets chapter

The 2025 npm worms didn't exploit a memory bug — they **stole credentials**. Shai-Hulud bundled TruffleHog to harvest tokens from infected machines and republished packages with the victims' own npm tokens.[¹] Supply-chain hygiene *is* secret hygiene: the blast radius of a bad `npm install` is "every secret reachable from your shell."

## Incident inventory (2023–2026)

| Incident | When | Vector | Payload / impact | Lesson |
|---|---|---|---|---|
| **Ledger connect-kit** | Dec 2023 | Phished ex-employee npm account; an API key bypassed 2FA[²] | Angel Drainer wallet-drainer; ~$700k; live ~5h | Revoke ex-staff registry access; automation keys bypass 2FA |
| **xz-utils** (CVE-2024-3094) | Mar 2024 | Multi-year social engineering of a burned-out maintainer[³] | Backdoor in liblzma targeting sshd; caught by luck (500 ms login delay) | Maintainer trust/burnout is an attack surface |
| **polyfill.io** | Jun 2024 | Domain + GitHub sold to a malicious buyer[⁴] | CDN served malware to 100k+ sites; mobile redirects | Ownership change = supply-chain risk; self-host or use SRI |
| **lottie-player** | Oct 2024 | Compromised npm **automation token** bypassed 2FA[⁵] | Crypto-drainer popup; one user lost ~$723k (10 BTC) | Kill automation tokens; they skip 2FA |
| **Nx / s1ngularity** | Aug 2025 | Vulnerable GitHub Actions workflow leaked a publish token[⁶] | Malicious Nx versions; notable for using local AI CLIs to find secrets | CI workflow = token custody |
| **qix / chalk-debug** | Sep 2025 | Phish (`npmjs.help`) of a maintainer[⁷] | 18 pkgs incl `chalk`/`debug` (2.6B weekly dl); crypto-clipper | Even huge-download packages are one phish away |
| **Shai-Hulud worm** | Sep 2025 | Self-replicating; stolen maintainer tokens[¹] | First self-propagating npm worm; 500+ packages; TruffleHog credential harvest | Postinstall scripts are RCE; tokens enable worms |
| **Shai-Hulud 2.0** | Nov 2025 | Pre-install execution; ~25k repos[⁸] | Destructive fallback (attempts to wipe `$HOME`) | `--ignore-scripts` by default; lifecycle scripts are the entry |

## Defenses that actually exist now

The good news: 2024–2025 shipped the countermeasures.

- **`npm audit signatures`** — verifies each installed package's ECDSA registry signature against npm's published keys. ECDSA registry signing replaced PGP in Jul 2022.[⁹] Run it in CI; it catches tampered/forged registry artifacts.
- **npm Trusted Publishing + provenance** — GA Jul 2025. Publish from GitHub Actions / GitLab CI via OIDC and npm **auto-generates Sigstore provenance by default**, no `--provenance` flag, no long-lived token.[¹⁰] Consumers can verify a package was built from the claimed source + workflow.
- **PyPI Trusted Publishers + attestations** — GA Nov 2024. Publishing via OIDC auto-applies Sigstore signatures with zero workflow changes; 20k+ attestations uploaded, ~5% of the top 360 projects.[¹¹]
- **Sigstore / cosign** — keyless signing (OIDC identity + transparency log, no key to steal). `cosign verify` checks npm provenance, GitHub artifact attestations, and container images.[¹²]
- **Registry hardening** — post-2025, npm is deprecating long-lived classic tokens, pushing granular short-expiry tokens, requiring 2FA for high-impact publishers, and steering everyone to trusted publishing. The throughline: **kill long-lived publish tokens.**

Adoption is still partial — even Sigstore's own ecosystem shows only single-digit-percent provenance coverage of npm deps[¹¹] — so provenance is a *positive signal when present*, not yet a universal gate.

### cosign for container images (solo-dev relevance)

If you publish container images, sign them keylessly and verify on pull:

```bash
cosign sign   <registry>/<image>@sha256:<digest>   # keyless: prompts OIDC, logs to Rekor
cosign verify <registry>/<image>@sha256:<digest> \
  --certificate-identity-regexp '.*' --certificate-oidc-issuer-regexp '.*'
```

If you don't ship images, skip this — it's the one part of the chapter that's genuinely optional for most solo devs. **TESTED LOCALLY ON: ____ (fill in).**

## Solo-dev hygiene checklist

1. **Pin and lock.** Exact versions, commit lockfiles, `npm ci` (not `npm install`) in CI.
2. **`--ignore-scripts` by default.** Allowlist only the packages that genuinely need lifecycle scripts. Most of the 2025 worms ran via pre/postinstall.
3. **Verify in CI.** `npm audit signatures`; check provenance where available.
4. **Publish via OIDC.** Your own packages go out through Trusted Publishing — never a long-lived token sitting on your laptop.
5. **Add a release cooldown.** Don't auto-upgrade to a version published in the last few days; most malicious versions are unpublished within hours. (Renovate `minimumReleaseAge`, or a scanner like socket.dev.)
6. **Shrink the dep graph.** Fewer, better-maintained deps = smaller attack surface.
7. **Rotate after exposure.** Any token that lived in an environment a compromised build could read is burned — rotate it. (Procedure: [never-commit-secrets](./never-commit-secrets.md#after-a-major-supply-chain-incident).)

## ADHD-aware note

This chapter removes from working memory the question *"is this dependency safe?"* You don't adjudicate it per-install. You set the defaults once — lockfiles, `--ignore-scripts`, `audit signatures` in CI, cooldown on upgrades — and let the machinery hold the vigilance you can't.

## Related

- [Never commit secrets](./never-commit-secrets.md) — the post-incident rotation recipe
- [Cloud-session pattern](./cloud-session-pattern.md) — OIDC publishing, no static tokens
- [Bitwarden via rbw](./bitwarden-via-rbw.md) — where rotated tokens land

---

[¹]: https://unit42.paloaltonetworks.com/npm-supply-chain-attack/ — accessed 2026-05-31
[²]: https://www.ledger.com/blog/security-incident-report — accessed 2026-05-31
[³]: https://en.wikipedia.org/wiki/XZ_Utils_backdoor — accessed 2026-05-31
[⁴]: https://blog.qualys.com/vulnerabilities-threat-research/2024/06/28/polyfill-io-supply-chain-attack — accessed 2026-05-31
[⁵]: https://snyk.io/blog/lottie-player-npm-package-compromised-crypto-wallet-theft/ — accessed 2026-05-31
[⁶]: https://www.cisa.gov/news-events/alerts/2025/09/23/widespread-supply-chain-compromise-impacting-npm-ecosystem — accessed 2026-05-31
[⁷]: https://www.huntress.com/blog/axios-npm-compromise — accessed 2026-05-31
[⁸]: https://unit42.paloaltonetworks.com/npm-supply-chain-attack/ — accessed 2026-05-31
[⁹]: https://docs.npmjs.com/about-registry-signatures/ — accessed 2026-05-31
[¹⁰]: https://docs.npmjs.com/trusted-publishers/ — accessed 2026-05-31
[¹¹]: https://blog.sigstore.dev/pypi-attestations-ga/ — accessed 2026-05-31
[¹²]: https://blog.sigstore.dev/cosign-verify-bundles/ — accessed 2026-05-31
