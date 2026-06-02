# Brew→native dependency map — scoping recommendation

*Scoping for G-836. Research artifact — recommendation only, not the execution.*

## What was actually checked

Grepped every chapter (excluding `.planning/`) for install commands and tool
references, then probed a live macOS 15 / arm64 box (`command -v`, `brew deps`,
`brew info --json`) for bundling, dependency depth, and tap provenance. Two
findings up front that the seed list got wrong:

- **`jq` is no longer a brew dependency on current macOS.** It ships at
  `/usr/bin/jq` (`jq-1.7.1-apple`, root-owned, Apple-signed). The playbook
  references `jq` 21 times but never tells you to `brew install` it — correct,
  because you don't need to.
- **`git` is bundled too** (`/usr/bin/git`, Xcode Command Line Tools). Not on
  the dependency list, but worth noting: the playbook leans on git everywhere
  and never asks you to brew it.
- **`pre-commit` and `detect-secrets` are pipx-first** in the playbook
  (`pipx install …  # or: brew install …`). They are PyPI packages, not native
  to brew's trust story — different provenance than the homebrew/core formulae.

All 13 brew-installed formulae cited come from **`homebrew/core`** — the
official, audited tap with reproducible bottles. Zero third-party taps. The
trust surface is therefore the *upstream project*, not the tap.

## Per-tool inventory

| Tool | brew cmd | macOS-bundled alt? | Native-alt install cost | Dep depth | Trust surface |
|---|---|---|---|---|---|
| **rbw** | `brew install rbw` | No | None — no native Bitwarden CLI; official `bw` is a separate npm/snap install | shallow (5) | homebrew/core; upstream `doy/rbw` (single maintainer, Rust) |
| **ntfy (CLI)** | `brew install ntfy` *(or single binary)* | No | Single static binary from docs.ntfy.sh/install (curl + chmod); or just `curl` to the topic URL — **the publish path is plain HTTP, no CLI required** | n/a (cited as binary) | upstream `binwiederhier/ntfy`; self-hostable |
| **libfido2** | `brew install libfido2` | No | None practical — would need manual build of the C lib | shallow (3) | homebrew/core; Yubico-maintained |
| **openssh** | `brew install openssh` | **Partial** — `/usr/bin/ssh` & `ssh-keygen` ship (OpenSSH 10.x) but are **not** linked against libfido2 → `-sk` keygen fails with `No FIDO SecurityKeyProvider specified` | The native binaries work for everything *except* FIDO; brew's build is needed only for hardware-key flows | moderate (12) | homebrew/core; OpenSSH upstream |
| **ykman** | `brew install ykman` | No | `pipx install yubikey-manager` (same tool, PyPI) — comparable friction | deep (12) | homebrew/core; Yubico-maintained |
| **gitleaks** | `brew install gitleaks` | No | Single Go binary from GitHub releases (download + chmod) | none (0) | homebrew/core; `gitleaks/gitleaks` |
| **detect-secrets** | `pipx install` *(or brew)* | No | pipx is the documented path; brew is the alternate | n/a (pipx) | PyPI / Yelp; brew formula mirrors it |
| **pre-commit** | `pipx install` *(or brew)* | No | pipx (documented) or `pip install` | n/a (pipx) | PyPI; brew formula mirrors it |
| **pipx** | `brew install pipx` | No | `python3 -m pip install --user pipx` (Python 3 ships via CLT/Xcode) | moderate (9) | homebrew/core |
| **gh** | `brew install gh` | No | Signed `.pkg`/binary from GitHub releases | none (0) | homebrew/core; GitHub-official |
| **jq** | *(not cited as brew)* | **Yes** — `/usr/bin/jq` (`jq-1.7.1-apple`) | Zero — already present | none (0) | Apple-signed system binary |
| **fzf** | `brew install fzf` | No | Go binary from releases; or git-clone install script | none (0) | homebrew/core; `junegunn/fzf` |
| **bat** | `brew install bat` | No (`cat` is the *fallback*, not equivalent) | Rust binary from releases | shallow (6) | homebrew/core; `sharkdp/bat` |
| **glow** | `brew install glow` | No (`cat`/`less` fallback) | Go binary from releases | none (0) | homebrew/core; `charmbracelet/glow` |
| **trash** | `brew install trash` | No (`rm` exists but is destructive — that's the whole point) | Small binary; or AppleScript `tell Finder to delete` | none (0) | homebrew/core; `ali-rantakari/trash` |
| **lychee** | `brew install lychee` | No | Rust binary from releases; or `cargo install` | none (0) | homebrew/core; `lycheeverse/lychee` |
| **git-filter-repo** | `pipx install` *(or brew)* | No | Single Python script on PATH; pipx documented | n/a (pipx/script) | PyPI; brew formula mirrors it |

Dep depth = `brew deps <formula>` transitive count on a current arm64 box;
"shallow" ≤6, "moderate" 7–12, "deep" >12. **Most security/convenience tools
are zero-dependency single binaries** — the cost of `brew install gitleaks` is
one bottle, not a tree.

## Pattern analysis

Three clean buckets fall out:

**1. No native alternative (brew or an equivalent-friction manual install is the
only path).** `rbw`, `libfido2`, `ntfy` CLI, `ykman`, `gitleaks`, `lychee`,
`gh`, `git-filter-repo`, `pre-commit`, `detect-secrets`, `pipx`. For these the
"native alternative" is a manual GitHub-release download + chmod, or a pipx/PyPI
install — *more* friction than brew, not less. brew is correctly the path of
least resistance.

**2. Pure convenience over a native path (the playbook already degrades
gracefully).** `bat` (over `cat`), `glow` (over `cat`/`less`), `fzf` (optional
picker). The cheats system already auto-detects `glow → bat → mdcat → less →
cat` and the fzf picker falls back to a plain list. **These are explicitly
optional today** — the playbook does not require them.

**3. Security-driven, justify the add.** `gitleaks`, `detect-secrets`,
`libfido2` (FIDO hardware keys), `rbw` (secrets out of plaintext), `trash`
(non-destructive delete). The *reason to install* is the security posture, not
convenience. These deserve a one-line "why" at the point of recommendation —
which chapter 05 already does.

**4. Bundled-but-partial — the one genuine foot-gun.** `openssh`. The native
`/usr/bin/ssh` works for normal SSH but silently can't do FIDO `-sk` keys
(`No FIDO SecurityKeyProvider specified`), which is *exactly* what chapter 05's
YubiKey recipe needs. This is the single case where "macOS bundles it" is
actively misleading, and it's already documented in
`feedback_yubikey_fido_gotchas.md` and chapter 05.

## Recommendation

**(d) — Skip the dedicated cross-cutting dependency map. Add lightweight inline
gating instead.**

Rationale, honest about ROI:

- **The inventory undercuts the premise.** The fear was "brew recommended
  liberally without discussing when native works." But the evidence shows the
  playbook is *already* well-behaved: convenience tools (`bat`/`glow`/`fzf`)
  degrade gracefully and are optional; security tools carry their justification
  inline; `jq`/`git` are correctly never brewed. There is no liberal-brew
  problem to solve.
- **A standalone `dependency-map.md` would rot.** Pinned dep counts, tap names,
  and "macOS bundles X" facts drift with every macOS and Homebrew release (jq
  becoming bundled is the live proof). A cross-cutting table is a maintenance
  liability the size of its own audit cycle.
- **Nearly every tool resolves to the same answer:** "brew is the right path;
  the native alternative is more friction." A whole page to say that 13 times is
  negative ROI. The interesting cases are the *exceptions*, and exceptions
  belong next to the recipe that hits them, not in a far-away appendix.
- **The two facts genuinely worth capturing are local, not global:**
  1. **openssh partial-bundling** → already in chapter 05; add a one-line
     "why brew openssh when macOS has ssh?" callout if it isn't crisp.
  2. **A short framing principle** ("prefer the bundled tool when it's truly
     equivalent; brew when it isn't; gate every *new* security tool with a
     one-line why") → fits as a brief callout in **chapter 02
     (filesystem-conventions / dependency hygiene)**, ~6–10 lines, not a sub-doc.

So: not (a) a new sub-topic, not (c) an appendix. A small inline principle in
ch02 + the existing ch05 openssh note covers the real signal. This is the
"insufficient ROI for a dedicated spot" outcome the ticket explicitly allows.

## Followup execution ticket (draft)

**Title:** `G-xxx: ch02 — add "dependency gating" callout + verify ch05 openssh-vs-bundled-ssh note`

**Problem.** The playbook recommends `brew install` across chapters with no
single sentence on *when the bundled macOS tool already suffices* vs *when brew
is genuinely required*. The G-836 inventory found the playbook is already
well-behaved (graceful degradation for convenience tools; bundled `jq`/`git`
correctly never brewed), so a full dependency map is overkill — but two small
gaps remain: no stated gating principle, and the openssh partial-bundling
foot-gun should be crisp at its recipe.

**Goal.** Capture the one reusable principle inline and make the one genuine
foot-gun unmissable, without adding a rot-prone cross-cutting table.

**Acceptance criteria.**
- [ ] Chapter 02 gains a short (~6–10 line) callout: "prefer the bundled tool
      when truly equivalent (`jq`, `git`, plain `ssh`); reach for brew when it
      isn't (FIDO openssh, `rbw`, scanners); gate every *new* security tool
      with a one-line why." Tone matches existing ch02 prose.
- [ ] Chapter 05 `ssh-agent-via-rbw.md` states *why* `brew install openssh` is
      needed despite `/usr/bin/ssh` existing (bundled binary lacks libfido2 →
      `No FIDO SecurityKeyProvider specified`). Verify the existing text already
      says this; tighten if not.
- [ ] No new standalone `dependency-map.md` / appendix created (explicit
      non-goal — see G-836 scoping).
- [ ] `lychee` link-check passes on edited files.

**Scope estimate.** XS — docs-only, two files, ~30–45 min. No code, no tests
beyond the existing lychee link check.

**Stop condition.** If editing reveals the openssh "why" is already crisp in
ch05, drop that AC and ship the ch02 callout alone.
