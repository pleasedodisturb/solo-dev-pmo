# Prompt compression and context discipline

> Compression shrinks the *variable* input that caching can't help with. It works — but it's the lossiest lever in the chapter, and for agent/chat workloads the provider has largely eaten its lunch. Reach for it last, behind an eval gate, and mostly for fixed RAG/batch prompts.

> **Checked 2026-05-31.** Headline ratios below are from the LLMLingua papers (arXiv); the provider-native numbers from Anthropic. Several arXiv/blog pages 403 to automated fetch — verbatim quotes are flagged where extraction-sourced.

## LLMLingua — token-level compression

Microsoft's LLMLingua family drops low-information tokens from a prompt before it reaches the model:

| Variant | Method | Headline | Paper |
|---|---|---|---|
| **LLMLingua** | Small LM scores token perplexity, iterative drop + budget controller | "up to **20× compression** with little performance loss"[¹] | arXiv 2310.05736, EMNLP 2023 |
| **LLMLingua-2** | Extractive token *classification* (keep/drop), distilled from GPT-4 on MeetingBank, BERT-size | **3–6× faster** than v1, task-agnostic; typical operating ratios **2–5×**[²] | arXiv 2403.12968, ACL 2024 Findings |
| **LongLLMLingua** | Long-context reordering + compression | **+17.1%** quality at **~4× fewer tokens** (NaturalQuestions); **+21.4%** RAG quality at **1/4 tokens**[³] | arXiv 2310.06839, ACL 2024 |

The 20× is a **ceiling on the friendly tasks**, not a default. LongLLMLingua's measured ~4× at break-even-or-better quality is the honest operating point for RAG.

```python
# LLMLingua-2 — the task-agnostic, faster classifier. Compress a retrieved chunk, not your code.
from llmlingua import PromptCompressor
c = PromptCompressor("microsoft/llmlingua-2-xlm-roberta-large-meetingbank",
                     use_llmlingua2=True)
out = c.compress_prompt(retrieved_context, rate=0.33)   # ~3x; keep an eval gate on rate
print(out["compressed_prompt"], out["origin_tokens"], out["compressed_tokens"])
```

### When it preserves quality vs degrades it

- **Preserves well:** chain-of-thought reasoning, summarization, dialogue, RAG context — the small LM keeps numbers, units, and reasoning steps. The high ratios apply here.
- **Degrades — don't compress these:** **code, SQL, tables, JSON, any syntax-sensitive or exact-recall input.** Perplexity-based dropping breaks structure. If you must compress structured input, use the *extractive* LLMLingua-2, never the original's token-dropping.[⁴]
- **The cliff is content-dependent, not a fixed ratio.** We found **no quantified "ratio X breaks it" figure** — that's a genuine gap. So you cannot set a safe global rate by reading a number; you set it per task type and **prove it with an eval gate** (same discipline as [routing](./model-routing.md#the-eval-gate)). A compression `rate` is a routing-class decision: it can silently botch output.

### Maintenance + supersession (surfaced per stop-conditions)

LLMLingua is in **maintenance, not active development**: last tagged release **V0.2.2 (Apr 2024)**, some 2025 issue activity, and the lab's newer output is SecurityLingua (a jailbreak guardrail), not a compression successor. **There is no LLMLingua-3.**[⁵] More important for this chapter's recommendation: **provider-native context management has eaten most of the agent/chat use case** (below). LLMLingua's remaining sweet spot is **fixed RAG/batch pipelines on reasoning/summarization content** — not interactive agents, not code.

## Context discipline without compression (prefer this)

For agent and chat workloads, the better lever is managing *what enters and stays in* context, not squeezing tokens after the fact. Anthropic frames it as an **"attention budget"**: attention is n² over tokens, so a fuller window dilutes it — **"context rot"** degrades retrieval and accuracy well below the technical max.[⁶] The remedies are structural:

- **Just-in-time retrieval** — pull context on demand instead of pre-loading everything.[⁶]
- **Compaction** — summarize near the limit (below).
- **Structured note-taking / memory** — persist state *outside* the window.[⁶]
- **Sub-agents** — focused agents return condensed results, keeping the parent lean (see [Chapter 03 — agent rules](../03-claude-code-as-operator/agent-rules.md#subagent-economics-q0325)).

### Anthropic context editing + memory tool (shipped Sept 2025)

Two first-party features now do for free what compression approximated:

- **Context editing** (`clear_tool_uses_20250919`) — automatically clears stale tool calls/results as the model nears its limit, with a `keep` parameter for how many recent results to retain.[⁷]
- **Memory tool** (`memory_20250818`) — store/retrieve information across turns and sessions, outside the window.[⁷]

Anthropic's internal 100-turn web-search benchmark: memory + context editing together gave **84% token reduction and 39% performance improvement**; **context editing alone = 29% improvement.**[⁷] That a *no-quality-cost* provider feature beats lossy token compression on the agent use case is exactly why compression ranks last here.

### Auto-compaction — design to survive it

The API compaction primitive (`compact_20260112`) fires when input exceeds a **default 150,000 tokens (min 50,000, configurable)**; it generates a `<summary>`, **drops all message blocks before the compaction point**, and keeps the summary plus everything after.[⁸] **Claude Code** wraps this: a full auto-compact near ~95% of the window, plus an earlier "micro-compact" that selectively clears old tool outputs (file reads, greps) while keeping conversation (threshold is version-dependent — verify).[⁹] **Cursor** leans on codebase indexing + on-demand retrieval and nudges you to a fresh chat; **Cline** has `/smol` (in-place summary) plus a Memory Bank of markdown files.[¹⁰]

**Design implication:** durable rules belong in **`CLAUDE.md`** (which survives compaction), not in conversation history (which gets summarized or dropped). This is the cross-link to [Chapter 03 — cache-hit hygiene](../03-claude-code-as-operator/agent-rules.md#cost-and-cache-hit-accounting-q0326q0327): `/compact` also breaks your cache prefix, so save it for natural breaks.

## Three knobs, one table

| Knob | Controls | Best when | Trade-off |
|---|---|---|---|
| **Selective retrieval (RAG)** | what *enters* context | large/changing corpora, need provenance | retrieval miss = missing context; infra + latency |
| **Summarization / compaction** | what *stays* as context ages | long agent/chat sessions | lossy — early detail vanishes; summary quality varies |
| **Token compression (LLMLingua)** | squeezes a chosen *block* | fixed RAG/batch prompts, reasoning content | breaks code/structured data; extra model; maintenance-mode |

They compose: RAG selects → compress the retrieved chunks → compaction manages the running history. Anthropic's own guidance favors retrieval + compaction + memory over token-level compression for agents.[⁶]

## How short can prompts go?

The returns curve is **U-shaped**, not monotonic. Shortening helps until **under-specification** — strip constraints and format cues and output *variance* rises; "long, hierarchical prompts are more consistent, short prompts generate more variance."[¹¹] But bloat hurts too (context rot). The move is **strategic placement** — static instructions in the cached system prefix, volatile context injected late — not blanket shortening. There's no clean public dataset quantifying the exact cliff; treat this as directional.[¹¹]

## Myths to bust (Q09.23)

- **"Lower temperature saves tokens" — false.** Temperature changes sampling, not the tokenizer or per-token price. It only affects cost *indirectly*: higher temperature can produce longer outputs. The rate is unchanged.[¹²]
- **"A shorter system prompt always helps" — false / it depends.** Minimizing a system prompt raises variance; the fix is structuring (static vs injected), not deletion.[¹¹]
- **"Cut few-shot examples to save tokens, harmless" — context-dependent, backfires both ways.** Models lean on examples for format/distribution cues, so removing them can degrade output — *and* too many examples can cause "few-shot collapse" (one NDSS 2025 study: vuln-ID accuracy **Gemma 7B 77.9%→39.9%**, **LLaMA-2 70B 68.6%→21.0%** with added examples).[¹³] Tune example count empirically; don't strip purely for budget, don't assume more is safer.

## Related

- [Caching and batch](./caching-and-batch.md) — caching handles the *static* prefix; compression handles the *variable* input
- [Model routing](./model-routing.md) — the other lossy lever; same eval-gate rule
- [Chapter 03 — agent rules](../03-claude-code-as-operator/agent-rules.md#cost-and-cache-hit-accounting-q0326q0327) — `/compact`, cache hygiene, sub-agent context isolation
- [sources.md](./sources.md) — full bibliography

---

[¹]: https://arxiv.org/abs/2310.05736 ; https://github.com/microsoft/LLMLingua — accessed 2026-05-31 (arXiv 403 to automated fetch; claim via abstract extraction)
[²]: https://arxiv.org/abs/2403.12968 ; https://aclanthology.org/2024.findings-acl.57/ — accessed 2026-05-31
[³]: https://arxiv.org/abs/2310.06839 — accessed 2026-05-31
[⁴]: https://arxiv.org/html/2410.12388v2 (Prompt Compression survey) — accessed 2026-05-31
[⁵]: https://github.com/microsoft/LLMLingua/releases — accessed 2026-05-31 (last release V0.2.2, Apr 2024; no v3)
[⁶]: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — accessed 2026-05-31 (403 direct; quotes extraction-sourced — verify verbatim before print)
[⁷]: https://www.anthropic.com/news/context-management ; https://platform.claude.com/docs/en/build-with-claude/context-editing — accessed 2026-05-31
[⁸]: https://platform.claude.com/docs/en/build-with-claude/compaction — accessed 2026-05-31 (direct fetch verified)
[⁹]: https://code.claude.com/docs/en/how-claude-code-works — accessed 2026-05-31 (compact % version-dependent)
[¹⁰]: https://apidog.com/blog/cline-memory-cursor/ — accessed 2026-05-31 (secondary)
[¹¹]: https://blog.promptlayer.com/why-llms-get-distracted-and-how-to-write-shorter-prompts/ ; https://mlops.community/blog/the-impact-of-prompt-bloat-on-llm-output-quality — accessed 2026-05-31
[¹²]: https://www.ibm.com/think/topics/llm-temperature — accessed 2026-05-31
[¹³]: https://arxiv.org/html/2509.13196v1 (Over-prompting / few-shot collapse) — accessed 2026-05-31
