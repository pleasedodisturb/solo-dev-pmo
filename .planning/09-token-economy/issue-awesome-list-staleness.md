# Draft issue — awesome-llm-token-optimization staleness pass

> **Not for this repo.** This is a ready-to-file GitHub issue body for the external
> repo `pleasedodisturb/awesome-llm-token-optimization`, surfaced while using that
> list as the canonical reference during P09 (chapter 09 — token economy). It lives
> here only because this session's GitHub write access is scoped to `solo-dev-pmo`
> and can't file it there directly.
>
> **File it with:**
> ```bash
> gh issue create \
>   --repo pleasedodisturb/awesome-llm-token-optimization \
>   --title "Staleness pass: NotDiamond SDK archived, RouteLLM unmaintained (+ optional notes)" \
>   --body-file .planning/09-token-economy/issue-awesome-list-staleness.md
> ```
> (The `gh` front-matter title/lines above this divider are dropped if you use
> `--body-file` on the body section below; paste from the title line for the web UI.)

---

**Title:** Staleness pass: NotDiamond SDK archived, RouteLLM unmaintained (+ optional notes)

Surfaced while using this list as a reference. Two entries are now misleading to a reader who'd install/adopt them; two more are optional polish. Verified 2026-05-31.

## Stale — worth fixing

### 1. NotDiamond (Model Routing → Frameworks)
The `Not-Diamond/notdiamond-python` SDK was **archived (read-only) on 2025-12-11** (last release v0.4.12, Nov 2025). The current bullet reads as an adoptable tool:

> NotDiamond - Per-query best-model selection.

The hosted service is still live (it powers OpenRouter's Auto router), so the entry is worth keeping — just flag the SDK state. Suggested:

```markdown
- **NotDiamond** - Per-query best-model selection. *(Python SDK archived Dec 2025; hosted service still live — also powers OpenRouter's Auto router.)*
```
Source: https://github.com/Not-Diamond/notdiamond-python (archived banner)

### 2. RouteLLM (Model Routing → Frameworks)
Last commit **2024-08-10**, no tagged release — effectively a research artifact. Current bullet implies maintained software:

> RouteLLM - Open-source LLM router by LMSYS. Trains routers from preference data; 2x+ cost reduction.

Suggested (also tightens the headline number to the paper's actual claim):

```markdown
- **RouteLLM** - Open-source LLM router by LMSYS. Trains routers from preference data; up to ~85% cost cut on MT-Bench at ~95% GPT-4 quality (arXiv:2406.18665). *(Research-grade — no commits since Aug 2024.)*
```
Sources: https://github.com/lm-sys/RouteLLM/commits/main · https://arxiv.org/abs/2406.18665

## Optional polish

### 3. LLMLingua (Prompt Compression)
Claims are accurate to the papers, but the repo is maintenance-mode (last release V0.2.2, Apr 2024; no v3; the lab's newer output is SecurityLingua), and provider-native context editing (Anthropic `context_editing` / compaction, shipped 2025) now covers most of the agent use case. Optional tag:

```markdown
- **LLMLingua** - Up to 20x compression. Coarse-to-fine iterative method. *(Maintenance-mode; best for fixed RAG/batch prompts on reasoning/summarization content — not code or structured data.)*
```

### 4. Quick Wins "95-99%" headline
The combined-pipeline number is a genuine *envelope*, not a per-request discount — caching×batch compose multiplicatively (0.5 × 0.1 = 95% on the cached+batched slice), but routing and compression only stack on tasks that qualify and carry a quality cost. Optional caveat under the line:

```markdown
*Envelope — assumes the workload is repetitive (cache hits), non-urgent (batch), tier-able (routing), and verbose (compression headroom). Realistic floor ≈50% if traffic is unique, urgent, and already terse.*
```

---
Happy to PR any/all of these if useful.
