# Document-Driven Development for LLM Coding Agents: Terminology, Evidence, and Optimization Guidelines

_Compiled 2026-07-13. Synthesized from two multi-source, adversarially-verified research passes. Sources are labeled **EMPIRICAL** (peer-reviewed study or controlled experiment) vs **CONVENTION/ADVOCACY** (vendor/practitioner framing, not yet proven), and marked **[Free]** where openly viewable._

---

## Executive summary

- **The practice has names, but no single canonical one.** The best current label for "write the spec/plan first, then let the agent generate against it" is **Spec-Driven Development (SDD)**; the best label for "docs as persistent agent memory" is **context engineering**. Both build on a 15-year documentation-first lineage (README-Driven Development, ADRs).
- **The general thesis is well-motivated and supported by _adjacent_ evidence, but not directly proven.** Providing curated documentation/context measurably improves LLM code generation in study after study — but **no published study tests the exact compound claim** that human/AI-authored ADRs persisted in git improve a downstream coding _agent's_ output.
- **Concrete optimization guidelines exist**, split into a strong empirical tier and a weaker convention tier (below). The single most reliable guideline: **curate hard and position critical content at the start/end of context — more context is not better.**
- **Document _structure/format_ for agents is the biggest empirical hole** — a claim that a standards-derived template improves LLM-generated architecture docs was refuted during verification.
- **The recommended move: measure it on your own repo via controlled ablation** — the evidence is strong on _mechanism_ but silent on _your specific practice_.

---

## 1. Terminology

There is no universally-accepted name for the exact "AI-generated ADRs as human-readable reference + agent memory" practice. It blends several named traditions:

| Term                                   | Origin / author                                                                                   | Fit                                                                                                                                   | Type       |
| -------------------------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| **Spec-Driven Development (SDD)**      | GitHub **Spec Kit** (open-source, MIT, Sept 2025) & AWS **Kiro** IDE                              | Closest current match — markdown specs become the primary artifact; code is generated against them, before code is written            | CONVENTION |
| **Context engineering**                | Amplified by **Andrej Karpathy** (June 2025); first posted by Shopify CEO Tobi Lütke days earlier | Best fit for "docs as persistent LLM context"                                                                                         | CONVENTION |
| **Architecture Decision Record (ADR)** | **Michael Nygard, 2011** (confirmed by Martin Fowler)                                             | The specific artifact — 5 sections: Title, Status, Context, Decision, Consequences. Originally for human readers                      | Practice   |
| **README-Driven Development (RDD)**    | **Tom Preston-Werner** (GitHub co-founder), 2010                                                  | Philosophical ancestor: "Write your README first… before you write any code." Explicitly a subset of Documentation-Driven Development | Practice   |

**Note on GitHub's own framing (CONVENTION, no cited data):** Spec Kit states _"Specifications don't serve code—code serves specifications"_ and _"the specification becomes the primary artifact."_ GitHub labels Spec Kit _"our experiment."_ Critics call SDD _"reinvented waterfall"_ (Scott Logic) or _"BDD with branding"_ (Bryan Finster).

---

## 2. Does the general thesis hold? (Evidence that docs/context help LLMs)

### Supports the thesis — EMPIRICAL

- **RAG of API documentation improved LLM code-gen pass rates by 83%–220%** for less-common Python libraries. — Chen et al., arXiv:2503.15231 **[Free]**
- **Repository-level retrieved context beat the in-file baseline by >10%.** — RepoCoder, arXiv:2303.12570 **[Free]**
- **Retrieved documentation as context consistently improved NL-to-code generation** across models/languages. — DocPrompting, arXiv:2207.05987 **[Free]**
- **GitHub Copilot RCT: task completed 55.8% faster** (implementing an HTTP server in JS). — Peng et al., arXiv:2302.06590 **[Free]**

### Cuts against / qualifies the thesis — EMPIRICAL

- **Documentation _format_ had NO significant effect on human architecture comprehension** (n=65); prior exposure to source code dominated. — Ernst & Robillard, _Empirical Software Engineering_ 2023, arXiv:2305.17286 **[Free preprint]** _(This is the strongest, most rigorous single study in the set — weight it.)_
- **METR RCT (July 2025): experienced open-source devs were ~19% SLOWER with AI tools** on 246 real tasks in their own repos — despite believing they were faster. — metr.org **[Free]**
- **Docs are routinely stale/ambiguous/incomplete** and must be complemented by expert humans ("walking architecture"). — Rukmono et al. 2025 (arXiv:2503.08628) **[Free]**; Aghajani et al., ICSE 2019 (see §5).

### The critical caveat

**No study tests the specific compound claim.** The RAG studies concern _automated retrieval of API reference docs_, not _signed-off human/AI architecture specs persisted in git_. Anyone claiming the practice is "proven" is overreaching. It is well-motivated; it is not validated.

---

## 3. Optimization guidelines

### TIER A — Empirically grounded (do these)

**A1. Position critical content at the START or END of context — never the middle.**
LLM accuracy follows a U-shaped "lost in the middle" curve: with content fixed and only position varied, accuracy fell ~15–20 points (75.8% → ~53.8% → 63.2% across a 20-doc set) across six model families.
→ _Source:_ **Liu et al., "Lost in the Middle," TACL 2024** (peer-reviewed), arXiv:2307.03172 **[Free]**. Corroborated by RULER (COLM 2024, arXiv:2404.06654) and Chroma "context rot" (18 frontier models).
→ _Caveat:_ magnitude has narrowed on newest frontier models for _simple_ retrieval; treat as risk-reduction, not a law. Still bites on multi-hop reasoning and as context grows. **EMPIRICAL.**

**A2. More context is not better — budget and curate; don't dump the repo.**
Adding documents dilutes attention and pushes signal into low-attention middle positions; retriever accuracy saturates (20→50 docs improved GPT-3.5 only ~1.5%).
→ _Source:_ Liu et al., TACL 2024 (above) + ICLR 2025 "Long-Context LLMs Meet RAG." **[Free]. EMPIRICAL.**

**A3. Favor concrete code EXAMPLES over descriptive prose and parameter lists.**
Ablation of API-doc components: removing examples caused the largest quality drop; removing parameter lists _slightly improved_ output.
→ _Source:_ **Chen et al., "When LLMs Meet API Documentation," arXiv:2503.15231** (Mar 2025) **[Free]**.
→ _Caveat:_ scope = API-usage completion on unfamiliar Python libs; finding is "**add** examples, don't strip prose." Generalizing to ADRs is untested. **EMPIRICAL (scoped).**

**A4. Prefer actual in-repo code / API definitions over generic "similar code."**
In-context code and relevant API definitions significantly helped; naively retrieved "similar" snippets added noise and **degraded full-function generation by up to 15%**.
→ _Source:_ **Gu et al., "What to Retrieve for Effective RACG," arXiv:2503.20589** (Mar 2025); corroborated by CodeRAG-Bench (NAACL 2025, arXiv:2406.14497) **[Free]**.
→ _Caveat:_ verified 2-1 (hedged); negative result bounded to full-function _generation_ — similar-code retrieval still helps _completion_. **EMPIRICAL (scoped).**

**A5. Put exact interfaces + explicit requirements in the task.**
Specifying exact expected class/function names + a structured requirements list vs. leaving them implicit swung pass rates ~3× (GPT-5 25.9%→8.4%; Claude Opus 4.1 22.7%→8.2%).
→ _Source:_ **SWE-Bench Pro (Scale AI), arXiv:2509.16941** (Nov 2025) **[Free]**.
→ _Caveat:_ bundles requirements+interface (can't isolate identifiers); partly a unit-test false-negative artifact; vendor preprint. **EMPIRICAL (scoped).**

**A6. For AI-GENERATED ADRs, compose retrieval + examples + fine-tuning — don't one-shot prompt.**
"Simply prompting the LLM does not produce quality architecture decisions." The DRAFT method (few-shot + RAG + fine-tuning combined) beat every standalone approach on 4,911 ADRs.
→ _Source:_ **Dhar et al., "DRAFT-ing Architectural Design Decisions using LLMs," arXiv:2504.08207** (Apr 2025) **[Free]**.
→ _Caveat:_ preprint, no significance testing; retrieval and few-shot did **not** each help independently (that sub-claim was refuted) — only the _combination_ worked. **EMPIRICAL (preprint).**

**A7. Treat stale/incomplete docs as a defect class to manage (docs-as-code).**
A 162-type taxonomy from 878 mined artifacts found up-to-dateness (~39% of artifacts) and completeness (~55% of content issues) as the top problems.
→ _Source:_ **Aghajani et al., "Software Documentation Issues Unveiled," ICSE 2019** (peer-reviewed) **[Free preprint]**.
→ _Caveat:_ measured _human-facing_ docs pre-LLM; harm-to-agents is inferred. **EMPIRICAL.**

### TIER B — Sound conventions, not yet proven

**B1. Staged `spec → plan → tasks` decomposition** with "multi-step refinement over one-shot generation."
→ _Source:_ GitHub Spec Kit (open repo) **[Free]**. **CONVENTION** — no controlled study validates it; critics dispute the "executable spec" promise.

**B2. Loading an ADR into context ≠ the agent obeying it.** Compliance is probabilistic and degrades as context grows.
→ Framing from vendor blog (mnemehq) **CONVENTION**, but the _mechanism_ is EMPIRICAL: instruction-following decays with turns/length (Multi-IF, arXiv:2410.15553: o1-preview 88%→71% by turn 3 **[Free]**) and via the lost-in-the-middle effect. Implication: don't assume "file in `docs/adr/`" = "in the agent's working context." Verify/enforce, don't just inform.

### NOT established (honest holes)

- **Document structure/format for agents.** Ernst & Robillard found format didn't help _human_ comprehension; and a claim that an ISO-42010/C4/SEI-derived **template** improves LLM-generated architecture docs was **REFUTED (0-3)** in verification. "Atomic one-decision-per-file ADRs / MADR vs Nygard / chunking" are reasonable retrieval heuristics with **zero surviving empirical support**. Don't over-invest in template debates.

---

## 4. Design Principles (Plain-Language Summary)

These are the 10 actionable rules distilled from the research above. Each maps to one or more empirical findings in §3.

1. **Layered retrieval — scope context to the task at hand.** Root `AGENTS.md` → per-service `AGENTS.md` → architecture docs → guides. The agent reads deeper only when needed. Flooding all documentation into context degrades output; a layered approach lets the agent pull precisely what it needs. _(See A1, A2)_

2. **Keep docs fresh — update "Last verified" dates.** Up-to-dateness is the #1 documentation problem (~39% of defects). When you touch code that a doc describes, update the doc and its date. _(See A7)_

3. **Put critical information at the start or end of a document, never buried in the middle.** LLM accuracy follows a U-shaped curve — content in the middle of context gets ~20% lower accuracy than content at the edges. _(See A1)_

4. **Curate hard — less is more.** Adding documents dilutes attention. The root doc stays under 200 lines. Per-service docs stay under 150 lines. Don't dump information "just in case." _(See A2)_

5. **Use concrete code examples over abstract prose.** In ablation studies, removing examples caused the largest quality drop in LLM output; removing parameter descriptions slightly _improved_ it. Show real file paths and real code. _(See A3)_

6. **Reference actual in-repo code over generic "similar" patterns.** Naively retrieved "similar" snippets degrade generation quality by up to 15%. Point to the real implementation. _(See A4)_

7. **Specify exact interfaces and explicit requirements.** Providing exact function names, class names, and structured requirements vs. leaving them implicit swung pass rates ~3×. Be specific about what exists and what to call things. _(See A5)_

8. **Don't over-invest in document format/template debates.** Document _structure_ for agents has zero surviving empirical support as a factor. Use descriptive names, keep content clear, and move on. _(See §3 "Not established")_

9. **Cite external sources with links, not vague references.** If documentation mentions a wiki page, ticket, or thread, include the actual URL. "Per the docs" is as useless as "per the code somewhere" — an agent cannot follow up on a dead reference. _(Corollary of A3, A4, A5)_

10. **Describe the present, not the past.** Document what the code does *now*. When updating a doc, *remove* references to removed or retired behavior and drop negations about things that no longer exist unless the leftover is a genuine artifact a reader will actually encounter. A reader who never knew the old design is only confused by it. _(See A7 — staleness is a defect class)_

---

## 5. Measurement — how to actually prove it for your repo

No source provides a turnkey team-level recipe, but every empirical study above _is_ the method: **run a controlled ablation.** Take ~20–50 representative tasks, run the agent with docs vs. without (and good-position vs. buried), compare pass rates on a fixed test set. This mirrors the Pass@1 deltas in Chen et al., Gu et al., and SWE-Bench Pro. Given evidence is strong on mechanism but absent on this specific practice, an internal ablation is the only way to convert "should help" into "does help, by X%" — and would put you ahead of the published literature.

---

## 6. Claims refuted during verification (do NOT rely on these)

- Retrieval and few-shot each **independently** improving ADR quality — only the DRAFT _combination_ is supported (0-3).
- Context overflow as Claude Sonnet 4's _dominant_ failure mode (0-3).
- An ISO-42010/C4/SEI-derived **template** improving LLM-generated architecture-doc quality (0-3) — i.e., document-template benefit for LLM output is **not** established.
- Karpathy as the _originator_ of "context engineering" (he amplified; Tobi Lütke posted first).

---

## 7. Full source list

### Empirical — peer-reviewed

- **Liu et al.**, "Lost in the Middle: How Language Models Use Long Contexts," _TACL_ 2024. arXiv:2307.03172 · aclanthology.org/2024.tacl-1.9 — **[Free]**
- **Ernst & Robillard**, "A Study of Documentation for Software Architecture," _Empirical Software Engineering_ 2023. DOI 10.1007/s10664-023-10347-2 · arXiv:2305.17286 — **[Free preprint]** (journal page paywalled)
- **Aghajani et al.**, "Software Documentation Issues Unveiled," _ICSE_ 2019. DOI 10.1109/ICSE.2019.00122 · USI preprint (inf.usi.ch/phd/aghajani) — **[Free preprint]**
- **Peng et al.**, "The Impact of AI on Developer Productivity: Evidence from GitHub Copilot," 2023. arXiv:2302.06590 — **[Free]**
- **CodeRAG-Bench**, NAACL 2025 Findings. arXiv:2406.14497 — **[Free]**
- **RULER**, COLM 2024. arXiv:2404.06654 — **[Free]**
- **Shahin, Liang & Khayyambashi**, "Architectural design decision visualization…," _ECSA_ 2011. DOI 10.1145/2031759.2031762 · ResearchGate pub 220757160 — **[Free on ResearchGate]** (ACM PDF paywalled)

### Empirical — arXiv preprints (peer-review status varies)

- **Chen et al.**, "When LLMs Meet API Documentation…," Mar 2025. arXiv:2503.15231 — **[Free]**
- **Gu et al.**, "What to Retrieve for Effective Retrieval-Augmented Code Generation," Mar 2025. arXiv:2503.20589 — **[Free]**
- **Dhar et al.**, "DRAFT-ing Architectural Design Decisions using LLMs," Apr 2025. arXiv:2504.08207 — **[Free]**
- **SWE-Bench Pro** (Scale AI), Nov 2025. arXiv:2509.16941 — **[Free]**
- **RepoCoder**, EMNLP 2023. arXiv:2303.12570 — **[Free]**
- **DocPrompting**, ICLR 2023. arXiv:2207.05987 — **[Free]**
- **Multi-IF** (instruction-following degradation), 2024. arXiv:2410.15553 — **[Free]**
- **Rukmono et al.**, "From Expert to Novice…," 2025. arXiv:2503.08628 — **[Free]**
- **"An Empirical Study of Retrieval-Augmented Code Generation,"** _ACM TOSEM_ 2025. arXiv:2501.13742 · DOI 10.1145/3717061 — **[Free preprint]**

### Primary sources — practitioner / vendor (CONVENTION)

- Tom Preston-Werner, "Readme Driven Development," 2010 — tom.preston-werner.com/2010/08/23/readme-driven-development — **[Free]**
- Michael Nygard, "Documenting Architecture Decisions," 2011 — cognitect.com/blog/2011/11/15/documenting-architecture-decisions — **[Free]**
- GitHub Spec Kit — github.com/github/spec-kit — **[Free]**
- AWS Kiro — kiro.dev/docs/specs — **[Free]**
- Andrej Karpathy on context engineering (via Simon Willison) — simonwillison.net/2025/Jun/27/context-engineering — **[Free]**
- Anthropic, "Effective context engineering for AI agents" — anthropic.com/engineering — **[Free]**
- METR RCT, July 2025 — metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study — **[Free]**
- Chroma, "Context Rot" (via Redis blog restatement) — redis.io/blog/context-rot — **[Free]**
- mnemehq, "How AI Coding Agents Use ADRs" — mnemehq.com/insights/how-ai-coding-agents-use-adrs — **[Free, advocacy]**

### CMU / SEI (Free at sei.cmu.edu / resources.sei.cmu.edu)

- SEI, _AI-Augmented Software Engineering_ program page
- SEI, _Documenting Software Architectures: Views and Beyond_ (2nd ed.)
- SEI Blog, "Application of LLMs in Software Engineering: Overblown Hype or Disruptive Change?"
- SEI, "The Future of Software Engineering and Acquisition with Generative AI"
- SEI Blog, "10 Benefits and 10 Challenges of Applying LLMs to DoD Software Acquisition"

---

## Appendix A — Reference implementation: a real-world monorepo doc structure

A working instance of this practice observed in a production monorepo. It is a live example of docs-as-code: the conventions below are enforced in-repo (a GitHub Action warns on PRs missing a changelog) and the AI memory file is version-controlled alongside the code. Folder contents are described by _purpose_, not by dumping the individual markdowns.

### Directory tree (documentation-bearing paths)

```
project/
├── agents.md                 # Primary AI memory / project context file
├── CLAUDE.md → agents.md     # Symlink: Claude Code reads the same memory file
├── README.md                 # Human-facing project readme
├── docs/                     # Internal docs, numbered by lifecycle stage
│   ├── 00-RFC/               # Request-for-comments proposals (earliest stage)
│   ├── 01-spec/              # Feature specifications (largest set, ~26 files)
│   ├── 02-cli/               # CLI reference (auth, command tree)
│   ├── 02-implementation/    # Implementation notes (deploy templates, knowledge store)
│   ├── 03-architecture/      # Architecture docs (auth flow, state machines, integrations)
│   ├── 04-guides/            # How-to / operational guides (local dev, queues, data fetching)
│   ├── 05-architecture/      # More architecture docs (runtime, infrastructure decisions)
│   ├── 05-implementation/    # Design/implementation plans (~13 files)
│   ├── 06-plan/              # Forward-looking plans & upcoming specs
│   ├── 07-feedback/          # Retrospective learnings
│   ├── plans/                # Additional standalone plans
│   ├── changelog/            # One markdown per PR (~705 files); subdirs mirror branch names
│   │   ├── feat/ feature/ fix/ chore/ refactor/ test/ ci/ docs/ ...   # conventional prefixes
│   │   └── [dev-name]/ [tool-name]/ ...                               # dev-/tool-named branches
│   ├── releases/             # Release notes, YYYY-MM-DD.N.md, git-tagged release/...
│   └── deployment-behaviour-tests.md   # (one loose top-level doc)
```

### Purpose of each area

**`agents.md` (+ `CLAUDE.md` symlink) — the persistent agent memory file.** The single highest-signal document: a concise project overview, `apps/` and `packages/` tables (path + purpose per component), the tooling/task-runner cheatsheet, and hard architectural _rules_ written for the agent (e.g. "K8s for live status, DB for what-we-deployed"; "never call `api.*` directly in components"). It also documents the changelog and release conventions themselves. Notably it hedges its own freshness — a stale-prone task list carries `<!-- regenerate with moon query tasks -->`. This is the file that maps directly onto guideline **A2** (curate, don't dump) and the `AGENTS.md`/`CLAUDE.md` convention in **§3 Tier B**.

**`docs/` — the internal, numbered lifecycle.** The `NN-` prefixes encode an intended flow from proposal → spec → implementation → architecture → guides → plan → feedback:

- **`00-RFC/`** — proposals opened for discussion before a spec is committed.
- **`01-spec/`** — the committed specifications; the largest folder and the closest artifact to the "PR-as-plan, signed off before code" step.
- **`02-cli/` / `02-implementation/`** — reference material and implementation notes that accompany a spec being built.
- **`03-architecture/` & `05-architecture/`** — durable architecture descriptions (authentication, component interactions, state machines, runtime model, infrastructure trade-offs).
- **`04-guides/`** — operational how-tos for humans and agents (local development, message queues, cert generation, data-fetching conventions).
- **`05-implementation/` / `06-plan/` / `plans/`** — design plans and forward-looking work.
- **`07-feedback/`** — retrospective "what we learned" notes (a lightweight, in-repo lessons-learned store).

> _Observation (not a criticism):_ the numbering has drifted — **architecture** appears at both `03-` and `05-`, and **implementation** at both `02-` and `05-`. This is exactly the kind of taxonomy drift the guidelines warn about (**§3 "Not established"** / **A7 freshness**): the ordinal scheme signals intent but is no longer a strict lifecycle. For agent retrieval this matters less than for humans, but it does dilute the "one obvious place" property.

**`docs/changelog/` — per-PR design log, git-native.** Every PR must add `docs/changelog/{branch-name}-YYYY-MM-DD.md`; the filename mirrors the branch, so branches with slashes (`fix/…`, `dev-name/…`) become subdirectories. This is why the "categories" are a mix of conventional prefixes (`feat`, `fix`, `chore`, `refactor`) and developer-/tool-named branches — **the folder tree is auto-derived from git branch names, not a curated ontology.** Entries are required to describe **Summary / Design / Migration** ("explain the system, not the patch"), making them design memory rather than diffs — and a GitHub Action enforces their presence and syncs them into the PR description.

**`docs/releases/` — human-rollup layer.** Release notes (`YYYY-MM-DD.N.md`, git-tagged `release/…`) are _synthesized from the changelog files in a commit range_ — a public section (observable behavior, no internal jargon) plus an internal appendix (commit range, component names, DB/queue changes). This is a two-tier separation of stable/public narrative from volatile/internal detail.

### How it maps to the guidelines

| Practice in the repo | Guideline |
| --- | --- |
| `agents.md` as a curated, high-signal memory file (not a repo dump) | **A2**, **§3 Tier B** (`AGENTS.md`/`CLAUDE.md`) |
| Changelog/spec kept in git, PR-enforced, reviewed like code | **A7** (docs-as-code / freshness), **B1** (spec-first) |
| Changelogs describe design & decisions, not file diffs | ADR-style decision memory (**§1**) |
| Releases synthesized _from_ changelogs (two-tier narrative) | Stable-vs-volatile separation (Spec Kit `spec→plan→tasks`, **B1**) |
| `<!-- regenerate … -->` freshness hedge on drift-prone lists | **A7** (staleness management) |
| Numbered-folder drift (dup `architecture`/`implementation`) | Cautionary re: **§3 "Not established"** (structure/format for agents is unproven) |

_Not yet visible in this structure (consistent with the report's gaps):_ there is no in-repo eval/ablation harness measuring whether these docs improve the agent's output (**§5**), and the folder taxonomy is a human-facing convention with no evidence it is optimal for agent _retrieval_.

---

## Method note

Compiled from two independent deep-research passes (fan-out web search → source extraction → 3-vote adversarial verification → synthesis). Across both passes ~200 agent calls fetched ~38 sources and verified ~50 falsifiable claims; only claims surviving verification are reported here. Claims that failed verification are listed in §6. This is a fast-moving field — most arXiv preprints post-date early 2025 and benchmark numbers age quickly; re-check before citing as settled.
