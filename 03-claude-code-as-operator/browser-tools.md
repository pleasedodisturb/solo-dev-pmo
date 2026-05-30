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

**TLS fingerprinting (JA3/JA4) is the dominant axis in 2025–2026, not JS.** A 2026 paper reports AUC 0.998 for bot/human classification on JA4 features alone. For hard targets (Cloudflare/Akamai/DataDome), real Chrome via BrowserMCP or CloakBrowser is the only safe option.

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
