---
name: audit-docs
description: Periodically audit every AGENTS.md, architecture doc, guide, and README against the current codebase to catch documentation drift that /update-docs missed.
---

# Audit Documentation

Run this skill periodically or when you suspect docs have drifted from reality. Unlike `/update-docs` (which is diff-based — it checks what you just changed), this skill audits docs against the **current codebase state** to catch drift introduced by PRs that didn't run `/update-docs`.

## Context

Read these two files for the full rationale and rules:

1. **`AGENTS.md`** (root) — the "Documentation Rules" section is the single source for the writing rules, line limits, and staleness window. This skill does not restate them.
2. **`docs/decisions/document-driven-development.md`** — the research backing these rules. The key finding: stale docs cause agents to generate confidently wrong code because they treat documentation as ground truth.

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

Every `AGENTS.md`, `README.md`, architecture doc, and guide has a "Last verified" date (exempt: `CLAUDE.md`, decision records, which use `Date:`, and forked/vendored READMEs or tooling boilerplate). Flag any doc where:
- The date is older than the staleness window in the root "Documentation Rules"
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
- Which docs had stale dates (past the staleness window)
- What inaccuracies were found and fixed
- What was confirmed still correct

## Rules

Follow the root `AGENTS.md` "Documentation Rules" for limits and the staleness window. While fixing, the ones most often missed:

- **Concrete code examples over prose** — if a pattern changed, show the new real code.
- **Put critical info at start/end** — don't bury important details in the middle.
- **Don't add speculative docs** — only document what exists now.
- **Describe the present, not the past** — *remove* references to removed/retired behavior rather than documenting it.
- **Cite external sources** — if a doc references an external resource, it must include the URL.
- **Reference real code** — point to actual file paths and symbols, never line numbers.
- **Enumerate before you generalize** — re-check every "all"/"every"/"N of" claim member by member.

## When to run this skill

- Before starting a large feature (ensure your context is accurate)
- After a teammate mentions docs might be stale
- When a "Last verified" date is visibly old
- As a periodic hygiene pass (e.g., monthly)

---

**Keep this skill current.** If you add a new doc category or restructure `docs/`, update this file in the same change.
