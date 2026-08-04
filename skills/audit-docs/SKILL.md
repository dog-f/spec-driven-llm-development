# Audit Documentation

Run this skill periodically or when you suspect docs have drifted from reality. Unlike `/update-docs` (which is diff-based — it checks what you just changed), this skill audits docs against the **current codebase state** to catch drift introduced by PRs that didn't run `/update-docs`.

## Context

Read these two files for the full rationale and rules:

1. **`AGENTS.md`** (root) — see the "Documentation Rules" section for the 10 writing rules and maintenance call to action.
2. **`docs/decisions/document-driven-development-system.md`** — the research backing these rules. The key finding: stale docs cause agents to generate confidently wrong code because they treat documentation as ground truth.

## Workflow

### 1. Collect all docs

Gather every documentation file that makes claims about the codebase:

```bash
# All AGENTS.md files
find . -name "AGENTS.md" -not -path "./node_modules/*"

# Architecture docs
ls docs/architecture/*.md

# Guides
ls docs/guides/*.md

# Repo-owned READMEs (exclude forked/vendored libraries + tooling boilerplate)
git ls-files '**/README.md' 'README.md' | grep -viE 'node_modules|\.changeset'
```

### 2. Check "Last verified" dates

Every `AGENTS.md`, `README.md`, and architecture doc has a "Last verified" date (forked/vendored READMEs and tooling boilerplate are exempt). Flag any doc where:
- The date is older than 1 month from today
- The date is missing entirely

Report these as stale candidates — they need verification even if the content might still be correct. READMEs are held to the same accuracy bar; only their length/style rules are relaxed.

### 3. Verify claims against the codebase

For each doc, validate its concrete claims. Check systematically:

**Source layout sections:**
- Do the listed files and directories actually exist?
- Are there new files/directories not mentioned?
- Have any listed files been removed or renamed?

**Route/API tables:**
- Do the listed routes exist in the router file?
- Are there new routes not documented?
- Have controller names or paths changed?

**Package counts and lists:**
- Does the stated package/service count match reality?
- Are all packages/services listed? Are any listed that no longer exist?

**Code patterns and technology claims:**
- Do referenced imports, SDKs, or libraries still appear in `package.json`?
- Do named classes, functions, or modules still exist?
- Are version numbers or SDK names still accurate?

**External service references:**
- Do listed clients, database connections, or message queues still exist in the bootstrap?

**Inter-doc consistency:**
- Does the root `AGENTS.md` service/package count match the actual directories?
- Do architecture docs reference patterns that still exist?

### 4. Verify specs status

Check whether any specs in `docs/specs/todo/` have actually been implemented:
- For each spec, check if the described routes, models, or features now exist in the codebase
- If fully implemented, move to `docs/specs/implemented/` and fix references

Check whether any specs in `docs/specs/implemented/` describe features that have been removed or reverted.

### 5. Fix inaccuracies

For each inaccuracy found:
- Update the doc to match the current codebase
- Update the "Last verified" date to today
- Follow the writing rules (concrete examples, keep it short, critical info at edges)

### 6. Update verified dates

For docs you confirmed are still accurate (no changes needed), update their "Last verified" date to today.

### 7. Report

Summarize:
- How many docs were audited
- Which docs had stale dates (>1 month)
- What inaccuracies were found and fixed
- What was confirmed still correct

## Rules (from the research)

- **Concrete code examples over prose** — if a pattern changed, show the new real code.
- **Keep docs concise** — under 200 lines; up to 300 for particularly complex services/packages. This applies to **agent-facing** docs (`AGENTS.md`, architecture docs). **User-facing `README.md` files are exempt** from the length limit but must still be fully accurate and dated.
- **Put critical info at start/end** — don't bury important details in the middle.
- **Don't add speculative docs** — only document what exists now.
- **Describe the present, not the past** — when fixing a doc, *remove* references to removed/retired behavior rather than documenting it.
- **Cite external sources** — if a doc references an external resource, it must include the URL.
- **Reference real code** — point to actual file paths and implementations, not abstract descriptions.

## When to run this skill

- Before starting a large feature (ensure your context is accurate)
- After a teammate mentions docs might be stale
- When a "Last verified" date is visibly old
- As a periodic hygiene pass (e.g., monthly)

---

**Keep this skill current.** If you add a new doc category or restructure `docs/`, update this file in the same change.
