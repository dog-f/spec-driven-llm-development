---
name: update-docs
description: After completing a feature or code change, audit and update all affected documentation (AGENTS.md files, architecture docs, guides) to keep them in sync with the code.
---

# Update Documentation

Run this skill after finishing a feature, bug fix, or refactoring that changes how the code works. The goal is to ensure no documentation is left stale by your changes.

## Context

Read these two files for the full rationale and rules:

1. **`AGENTS.md`** (root) — see the "Documentation Rules" section for the 10 writing rules and maintenance call to action.
2. **`docs/decisions/document-driven-development-for-llms.md`** — the research backing these rules. The key finding: stale docs cause agents to generate confidently wrong code because they treat documentation as ground truth (Aghajani et al., ICSE 2019: ~39% of documentation defects are up-to-dateness issues).

## Workflow

1. **Identify what changed.** Run `git diff main --stat` (or `git diff HEAD~N --stat` if working from recent commits) to see all modified files. If you recently rebased onto or merged from main, also check what main introduced (e.g., `git log main --not main@{1} --stat`) — those changes could invalidate claims in docs your branch touches.

2. **Map changes to docs.** For each modified service or package, check whether its `AGENTS.md` still accurately describes:
   - Source layout (new files/directories added or removed?)
   - Key patterns (did the code pattern change?)
   - API routes (new endpoints, changed paths, removed routes?)
   - Common pitfalls (any new gotchas discovered during implementation?)

   Also check the root `README.md` — it's the human-facing equivalent of `AGENTS.md` and covers local dev setup, commit conventions, Docker commands, and workflow checks. If your changes affect any of those (new make targets, changed ports, new services), update it too.

3. **Check architecture docs.** If your changes affect:
   - Inter-service communication → update `docs/architecture/messaging.md` or `docs/architecture/system-overview.md`
   - Data models or stores → update `docs/architecture/data-stores.md`
   - Auth patterns → update `docs/architecture/inter-service-auth.md`
   - Core domain logic or processing pipeline → update relevant architecture docs
   - Deployment config → update `docs/architecture/deployment.md`
   - Framework usage → update framework-specific architecture docs

4. **Check guides.** If your changes alter the pattern shown in any guide under `docs/guides/`, update the guide to show the new pattern with real code.

5. **Check specs.** If your changes complete the implementation of a spec in `docs/specs/todo/`, move it to `docs/specs/implemented/` and fix any references:
   ```bash
   git grep -l "docs/specs/todo/spec-name.md" | xargs sed -i '' 's|docs/specs/todo/spec-name.md|docs/specs/implemented/spec-name.md|g'
   ```

6. **Update "Last verified" dates.** For every doc you confirm is still accurate (even if unchanged), update its "Last verified" line to today's date. This applies to every `AGENTS.md`, `README.md`, and architecture doc. Exempt: forked/vendored READMEs and tooling boilerplate — do not stamp those.

7. **Report.** Summarize what you updated and what you confirmed was already correct.

## Rules (from the research)

- **Concrete code examples over prose** — if a pattern changed, show the new real code, not a description of it.
- **Keep docs concise** — under 200 lines; up to 300 for particularly complex services/packages. Don't pad to fill space. This length limit applies to **agent-facing** docs (`AGENTS.md`, architecture docs). **User-facing `README.md` files are exempt** — they may be longer and carry richer instructional/graphical content. READMEs must still be fully accurate and dated; only the style/length pedantry is relaxed.
- **Put critical info at start/end** — don't bury new important details in the middle of a doc.
- **Don't add speculative docs** — only document what exists now, not what might exist later.
- **Describe the present, not the past** — when updating a doc, *remove* references to removed/retired behavior rather than documenting it.
- **Cite external sources** — if a doc references an external resource (wiki, ticket, thread), it must include the URL. Vague references are dead ends for agents.

---

**Keep this skill current.** If you add a new architecture doc, guide category, or restructure `docs/`, update this file in the same change.
