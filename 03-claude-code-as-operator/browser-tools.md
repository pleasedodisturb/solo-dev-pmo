# Browser tools (ranked)

> Pick the simplest tool that can do the job. WebFetch first; specialized only when needed.

The 2026 browser-tool landscape has 8+ viable options. Without rules, agents pick the wrong one and waste tokens, hit rate limits, or burn through credit on simple reads.

## The ranked tier list

Numbered top-to-bottom by what to reach for FIRST.

### 1. WebFetch (built-in, no MCP)

**Use when:** read-only data extraction from public pages.

- Zero setup. Built into Claude Code / similar tools.
- AI-summarized output. Token-efficient (~20× more so than browser snapshots).
- Cannot interact. Cannot follow JS-rendered routes. Cannot do auth.

The floor against which every other browser tool is justified. **First reach for any "read and extract" task.**

### 2. Playwright MCP

**Use when:** you need to interact with a web app — forms, clicks, dropdowns.

- Clean Chromium baseline. ~28 tools.
- `browser_fill_form` batches multiple fields in one call (massive win on forms).
- Accessibility-tree snapshots beat screenshot tools on token efficiency.
- Default interaction driver.

The right tool for "submit this form" and "navigate this site." Not stealth.

### 3. chrome-devtools MCP

**Use when:** you need to debug a running Chrome — network panel, perf trace, console capture.

- Drives + inspects via full DevTools Protocol.
- Pairs with Playwright as the debugger seat.
- Only tool that exposes DevTools to the agent.

Writes a harmless stderr warning ("exposes content of the browser instance") on every launch — ignore it.

### 4. browser-use MCP (Python agent framework)

**Use when:** the site changes structure and you want LLM-driven retry / extract / observe.

- `act/extract/observe` verbs plus a `retry_with_browser_use_agent` LLM-driven escape hatch.
- ~95K stars on GitHub. De-facto leader in AI-browser-agents mid-2026.
- Heavier than Playwright; better for self-healing.

### 5. Obscura

**Use when:** bulk server-rendered scrape with low RAM budget.

- Lightweight headless (~70 MB binary, ~30 MB RAM/tab).
- Built-in stealth + 3,520-domain tracker blocklist.
- The killer feature for low-RAM hosts: many parallel agents without Chrome's per-tab footprint.

Constraints:
- Not for React SPAs (it's not full Chromium)
- Not for screenshot-required flows
- Not for captcha targets
- **Do NOT enable `--stealth` on macOS** — Sec-CH-UA-Platform-* client hints leak the real OS regardless of JS UA spoof.

### 6. CloakBrowser MCP

**Use when:** target is Cloudflare-gated, captcha-prone, or hard-fingerprinted.

- Patched-Chromium stealth with ~58 source-level C++ fingerprint patches (canvas, WebGL, audio, fonts, GPU, automation signals).
- Passes Cloudflare Turnstile, reCAPTCHA v3, FingerprintJS, BrowserScan **without solving CAPTCHAs** — it prevents them from appearing.
- Sandbox-only. Closed-source binary touches cookies; never point at authenticated personal sessions.

### 7. Firecrawl MCP

**Use when:** clean markdown extraction for an LLM consumer.

- Cloud markdown-clean scraping. AI-first output.
- 96% coverage / 0.638 F1 on independent 1000-URL benchmark.
- ~7s average run time.

Needs an API key. Cloud-only (no local fallback). Reach when output cleanliness matters more than cost.

### 8. Lightpanda

**Use when:** bulk scrape of server-rendered HTML, no React.

- Zig-based headless engine, ~1.8s/page on server-rendered HTML, very low RAM.
- **Cannot render React/SPA pages** (returns empty).
- Right for scraping news sites, blogs, RSS-style content.

### 9. BrowserMCP (via Chrome extension)

**Use when:** authenticated host session in real Chrome (LinkedIn, Greenhouse logged in, kleinanzeigen, etc.).

- Drives the user's real Chrome via a browser extension.
- Only tool that can interact with authenticated host sessions.
- Project-level via `.mcp.json` (not global).

**NEVER use on banking or credential pages** — content goes to Anthropic's API.

Connection is fragile (extension disconnects mid-test); have a fallback plan.

## Capability matrix

| Tool | JS-render | Stealth | Network-intercept | RAM budget | When |
|------|-----------|---------|--------------------|------------|------|
| WebFetch | no | n/a | no | zero | static HTML reads |
| Playwright | yes (Chromium) | no | yes | ~300 MB | interactive forms |
| chrome-devtools | yes (real Chrome) | inherits | yes (full) | uses existing Chrome | debugging |
| browser-use | yes (Playwright) | partial | yes | ~300 MB | self-healing flows |
| Obscura | yes (Rust+V8) | yes | partial | ~30 MB/tab | bulk + stealth |
| CloakBrowser | yes (patched) | yes (C++ patches) | yes | ~200 MB | captcha bypass |
| Firecrawl | yes (cloud) | partial | no | zero local | clean markdown |
| Lightpanda | no | no | no | very low | server-rendered bulk |
| BrowserMCP | yes (real Chrome) | inherits | partial | host-only | authenticated host |

## 2026 landscape refresh (Q03.12–Q03.17)

*Checked 2026-05-31.* Two things changed enough to update the chapter.

**The detection axis moved again: post-quantum TLS.** JA3 is effectively dead (Chrome randomizes extension order; JA4 sorts before hashing and is randomization-resistant), and **JA4+ is the 2026 standard** — DataDome adopted it, Cloudflare/Akamai layer it under behavioral + token challenges.[¹] The "TLS fingerprinting dominates" claim now has a primary citation: a 2026 paper classifies bot-vs-human on JA4 features alone at **CatBoost AUC 0.998 / F1 0.97**[²] (research-grade, not a vendor stat). The *new* tell is **post-quantum**: ~57% of real browser connections now carry an `X25519MLKEM768` key share, and Akamai made PQ default for origin connections in Jan-2026 — so a client claiming modern Chrome but **missing the PQ key share is a pre-HTTP red flag**.[³] This *widens* the gap for pinned-fingerprint impersonation libs, not narrows it.

**Tool maintenance matrix** (verify before adopting — these move monthly):

| Tool | State 2026-05-31 | Note |
|---|---|---|
| `primp` | active (v1.3.1) | request-level TLS/JA4 impersonation; no JS[⁴] |
| `curl-impersonate` (lwthiker) | **stale** (v0.6.1, 2024-03) | superseded → |
| `curl_cffi` (lexiforest) | **active** (v0.15.x) | the live curl-impersonate line; best non-JS TLS impersonation[⁵] |
| Patchright | active (v1.60) | undetected Playwright drop-in; patches CDP, not a JS shim[⁶] |
| Camoufox | active (v150, new maintainers) | Firefox, C++-level spoofing; leading **open-source** anti-detect[⁷] |
| nodriver | active | successor to undetected-chromedriver; CDP-direct[⁸] |
| rebrowser-patches | maintained | fixes the `runtime.enable` CDP leak shims miss[⁹] |
| playwright-stealth / puppeteer-extra-stealth | Python active / **Node stagnant** | JS shims; still fail CreepJS-grade adversaries |

Net: **Python > Node for stealth in 2026.** The chapter's `playwright-stealth`-is-a-shim warning still holds; Patchright/Camoufox/nodriver are the real-engine answers below it.

**Status corrections to the tier list:**
- **Obscura** (#5) is real and active (`h4ckf0r0day/obscura`, ~14k★) but a **young 0.1.x single-maintainer** project — keep the ranking, but treat it as promising-not-battle-tested.[¹⁰]
- **CloakBrowser** (#6) active (v0.3.31, Chromium 146; 58 C++ patches). Precision: the **wrapper is MIT, the patched Chromium is binary-only** — "closed-source" is right in spirit. The **open-source equivalent is Camoufox** (Firefox-based, full source).[⁷][¹¹]
- **Firecrawl** (#7) is AGPL-3.0 with a free tier (~1k credits/mo); **self-host is a subset** — `/agent` and `/browser` and the managed anti-bot proxy network are cloud-only, so self-hosted Firecrawl is weak on hard targets.[¹²]
- **Lightpanda** (#8) actively developed but still beta: runs simple JS, **still not reliable for heavy React/SPA**. New engines to watch: **Servo** shipped an embeddable crate + headless `servo-shot` (Apr-2026); **Ladybird** targets first alpha Jul-2026 (not yet usable for scraping).[¹³]

**Verdict:** "JA3/JA4 dominant, real-browser-only for hard targets" holds *more firmly* in 2026 — PQ-TLS widened the gap. Refinement: impersonation libs (`curl_cffi`, `primp`) are excellent for **soft / non-JS / API-style targets, but only if kept PQ-TLS-current**; hard, actively-defended targets remain real-Chrome/Firefox-only.

## Recipes — "if you're trying to X, use Y"

- **Reading static HTML from a public page** → WebFetch (cheapest, 20× more efficient)
- **Filling a multi-field form on a React SPA** → Playwright MCP + `browser_fill_form`
- **Scraping a set of server-rendered pages where React isn't required** → Lightpanda (1.8s/page) or Obscura
- **Bypassing Cloudflare/Akamai/DataDome captcha-gated targets** → CloakBrowser (sandbox-only); Stagehand once wired
- **Interacting with an authenticated personal account** (LinkedIn, Greenhouse logged in) → BrowserMCP + real Chrome
- **Debugging a running Chrome session** → chrome-devtools MCP
- **Clean markdown for an LLM** → Firecrawl

## Field-tested gotchas

**BrowserMCP not connecting?** Ask user to launch the Chrome Agent profile and click "Connect" on the extension. Users forget. Always prompt.

**Greenhouse forms use React Select (not native `<select>`).** Use type + Enter, not `select_option`.

**Lever career pages (`jobs.lever.co`) are 404 / CSS-only as of mid-2026.** Don't waste cycles.

**Background agents don't inherit Bash permissions.** CLI browser tools (lightpanda fetch, etc.) must run in the main session.

**Never `--stealth` Obscura on macOS.** Sec-CH-UA-Platform-* client hints leak the real OS.

**TLS fingerprinting (JA3/JA4) is the dominant axis in 2025–2026, not JS.** A 2026 paper reports AUC 0.998 for bot/human classification on JA4 features alone[²]; by 2026 post-quantum TLS is an additional pre-HTTP tell (see [2026 refresh](#2026-landscape-refresh-q0312q0317)). For hard targets (Cloudflare/Akamai/DataDome), real Chrome via BrowserMCP or CloakBrowser is the only safe option.

**Headless-vs-headful JS detection is essentially over.** Chromium's new headless reached fingerprint parity mid-2025. `playwright-stealth` is a JS shim and does not pass CreepJS-grade adversaries.

**Headless Playwright Chromium leaks three classic signals today:**
1. `HeadlessChrome/...` token in UA
2. SwiftShader software renderer in WebGL (vs Apple Metal in headed)
3. `navigator.plugins.length=0` (vs 5 in headed)

All three independently fingerprintable.

**CloakBrowser is sandbox-only.** The patched binary is closed-source and touches cookies on launch; never point it at an authenticated personal session.

**chrome-devtools MCP writes stderr "exposes content" warning** on every launch. Not a failure; harmless.

## Innovative pattern: cascade routing

A `/scrape <url>` skill that:
1. Tries WebFetch first
2. If output is empty / 403 / JS-rendered indicator → Playwright
3. If Playwright hits Cloudflare → CloakBrowser
4. Final fallback → manual prompt for credentials via BrowserMCP

One command. Smart fallback. The agent never has to think about routing for this case.

## Innovative pattern: privacy-tagged URLs

Maintain a regex set of "never browser tools" hosts:
- `*.bank.com`, `*.financial.com`
- Your password manager URLs
- Internal company sites

Hook on PreToolUse blocks any browser tool call to a matched URL. Hard guard.

## Related

- [MCP routing](./mcp-routing.md) — the bigger routing picture
- [Memory architecture](./memory-architecture.md) — browser tools don't write to memory; results go to context only
- [Chapter 05 — Secrets](../05-secrets-and-secure-defaults/) — why never browser tools on credential pages
- [sources.md](./sources.md) — full bibliography

---

[¹]: https://packet.guru/blog/TLS-Fingerprinting-JA3-JA4 ; https://www.startertutorials.com/blog/bypassing-datadome-in-2026-the-ultimate-engine-level-guide.html — accessed 2026-05-31
[²]: "When Handshakes Tell the Truth: Detecting Web Bad Bots via TLS Fingerprints," arXiv:2602.09606 (2026-02-10) — accessed 2026-05-31
[³]: https://scrapfly.io/blog/posts/post-quantum-tls-bot-detection ; https://chromestatus.com/feature/5257822742249472 — accessed 2026-05-31
[⁴]: https://github.com/deedy5/primp — accessed 2026-05-31
[⁵]: https://github.com/lexiforest/curl_cffi (active fork of https://github.com/lwthiker/curl-impersonate) — accessed 2026-05-31
[⁶]: https://github.com/Kaliiiiiiiiii-Vinyzu/patchright — accessed 2026-05-31
[⁷]: https://github.com/daijro/camoufox — accessed 2026-05-31
[⁸]: https://github.com/ultrafunkamsterdam/nodriver — accessed 2026-05-31
[⁹]: https://github.com/rebrowser/rebrowser-patches — accessed 2026-05-31
[¹⁰]: https://github.com/h4ckf0r0day/obscura — accessed 2026-05-31
[¹¹]: https://github.com/CloakHQ/CloakBrowser — accessed 2026-05-31
[¹²]: https://github.com/mendableai/firecrawl ; https://filipkonecny.com/2026/03/29/firecrawl-limitations/ — accessed 2026-05-31
[¹³]: https://github.com/lightpanda-io/browser ; https://servo.org/ ; https://ladybird.org/ — accessed 2026-05-31
